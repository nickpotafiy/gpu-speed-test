#include <iostream>
#include <cuda.h>
#include <curand.h>
#include <cuda_runtime.h>
#include <curand_kernel.h>
#include <string>

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

std::string formatDouble(double value, int precision) {
    char buffer[100];
    char format[10];
    snprintf(format, sizeof(format), "%%.%df", precision);
    snprintf(buffer, sizeof(buffer), format, value);
    return std::string(buffer);
}

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
    CUDA_CALL(cudaMalloc((void**)&data, size));
    
    if(fill) {
        curandGenerator_t gen;
        CURAND_CALL(curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT));
        CURAND_CALL(curandSetPseudoRandomGeneratorSeed(gen, 1234ULL));
        CURAND_CALL(curandGenerateUniform(gen, data, size / sizeof(float)));
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
    CUDA_CALL(cudaMemcpyPeer(gpu2Data, gpuTo, gpu1Data, gpuFrom, size));    
    CUDA_CALL(cudaEventRecord(stop, 0));
    CUDA_CALL(cudaEventSynchronize(stop));
    
    float milliseconds = 0;
    CUDA_CALL(cudaEventElapsedTime(&milliseconds, start, stop));
    
    float sizeInMB = size / (1024 * 1024);
    float sizeInGB = sizeInMB / 1024;
    float timeInSeconds = milliseconds / 1000.0;
    float speedGBps = sizeInGB / timeInSeconds;

    std::cout << "Copied " << (sizeInGB) << " GiB from GPU " << gpuFrom << " to GPU " 
        << gpuTo << " in " << formatDouble(milliseconds, 0) << "ms (" << formatDouble(speedGBps, 2)
        << " GB/s)" << std::endl;
    
    CUDA_CALL(cudaEventDestroy(start));
    CUDA_CALL(cudaEventDestroy(stop));

}

void test(int gpu0, int gpu1) {

    const size_t dataSize = 1024 * 1024 * 1024;

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
    for(int i = 0; i < num_devices; i++) {
        try{
            CUDA_CALL(cudaSetDevice(i));
        }catch(std::runtime_error e) {
            std::cerr << "Error setting device " << i << ": " << e.what() << std::endl;
            return -1;
        }
    }

    std::cout << "Total devices found: " << num_devices << std::endl;
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