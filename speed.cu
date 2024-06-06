#include <iostream>
#include <cuda.h>
#include <curand.h>
#include <cuda_runtime.h>
#include <curand_kernel.h>

#define CUDA_CALL(x) do { \
    cudaError_t err = (x); \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
        throw std::runtime_error("CUDA error"); \
    } \
} while (0)

#define CURAND_CALL(x) do { \
    curandStatus_t err = (x); \
    if (err != CURAND_STATUS_SUCCESS) { \
        std::cerr << "CURAND Error at " << __FILE__ << ":" << __LINE__ << std::endl; \
        throw std::runtime_error("CURAND error"); \
    } \
} while (0)

#define CUDA_DEVICE(x) do { \
    cudaError_t err = cudaSetDevice(x); \
    if (err != cudaSuccess) { \
        if (err == cudaErrorInvalidDevice) { \
            std::cerr << "CUDA Error: Invalid Device " << x << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
        } else { \
            std::cerr << "CUDA Error: " << cudaGetErrorString(err) << " at " << __FILE__ << ":" << __LINE__ << std::endl; \
        } \
        throw std::runtime_error("Device does not exist"); \
    } \
} while(0)

void enablePeerAccess(int gpuFrom, int gpuTo) {
    int canAccessPeer;
    CUDA_CALL(cudaDeviceCanAccessPeer(&canAccessPeer, gpuFrom, gpuTo));
    if (canAccessPeer) {
        CUDA_CALL(cudaSetDevice(gpuFrom));
        cudaError_t err = cudaDeviceEnablePeerAccess(gpuTo, 0);
        if (err == cudaErrorPeerAccessAlreadyEnabled) {
            err = cudaSuccess;
        }
        CUDA_CALL(err);

        CUDA_CALL(cudaSetDevice(gpuTo));
        err = cudaDeviceEnablePeerAccess(gpuFrom, 0);
        if (err == cudaErrorPeerAccessAlreadyEnabled) {
            err = cudaSuccess;
        }
        CUDA_CALL(err);
    }
}

float* allocateTestData(int gpu, size_t size, bool fill = false) {
    float* data = nullptr;
    CUDA_DEVICE(gpu);
    CUDA_CALL(cudaMalloc((void**)&data, size * sizeof(float)));
    
    if(fill) {
        curandGenerator_t gen;
        CURAND_CALL(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT));
        CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, 1234ULL));
        CURAND_CALL(curandGenerateUniform(gen, data, size));
        CURAND_CALL(curandDestroyGenerator(gen));
    }
    
    return data;
}

void moveTestData(float* gpu1Data, float* gpu2Data, int gpuFrom, int gpuTo, size_t size) {
    enablePeerAccess(gpuFrom, gpuTo);
    
    CUDA_CALL(cudaSetDevice(gpuFrom));
    
    cudaEvent_t start, stop;
    CUDA_CALL(cudaEventCreate(&start));
    CUDA_CALL(cudaEventCreate(&stop));
    
    CUDA_CALL(cudaEventRecord(start, 0));    
    CUDA_CALL(cudaMemcpyPeer(gpu2Data, gpuTo, gpu1Data, gpuFrom, size * sizeof(float)));    
    CUDA_CALL(cudaEventRecord(stop, 0));
    CUDA_CALL(cudaEventSynchronize(stop));
    
    float milliseconds = 0;
    CUDA_CALL(cudaEventElapsedTime(&milliseconds, start, stop));
    
    std::cout << "Copied " << ((size / 1024 / 1024) * 4) << " MiB from GPU " << gpuFrom << " to GPU " << gpuTo << " in " << milliseconds << " ms" << std::endl;
    
    CUDA_CALL(cudaEventDestroy(start));
    CUDA_CALL(cudaEventDestroy(stop));

}

void test(int gpu0, int gpu1) {

    const size_t dataSize = 1024 * 1024 * 1024 / 4;

    float* gpu0Data = allocateTestData(gpu0, dataSize, true);
    float* gpu1Data = allocateTestData(gpu1, dataSize, false);

    moveTestData(gpu0Data, gpu1Data, gpu0, gpu1, dataSize);

    CUDA_CALL(cudaFree(gpu0Data));
    CUDA_CALL(cudaFree(gpu1Data));
}

int main() {

    int num_devices = 0;
    cudaGetDeviceCount(&num_devices);
    if (num_devices == 0) {
        std::cerr << "No CUDA devices found." << std::endl;
        return -1;
    }

    std::cout << "Total devices found:" << num_devices << std::endl;
    for(int i = 0; i < num_devices; i++) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, i);
        std::cout << std::endl << "[ Device " << i << ": " << prop.name << "]" << std::endl << std::endl;
        for(int j = 0; j < num_devices; j++) {
            if(i != j) {
                test(i, j);
            }
        }
    }
    return 0;
}