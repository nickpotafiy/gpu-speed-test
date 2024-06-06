# GPU Speed Test

Simple utility for testing and benchmarking the communication speed between GPUs over the PCIe bus.

## Key Features

- **Peer-to-Peer Communication Testing**: Evaluate the data transfer speed between every GPU.
- **CUDA Support**: Leverage CUDA for precise and efficient performance measurements.
- **Compatibility**: Supports a variety of NVIDIA GPUs, including RTX 3080, 3090, and 4090.

## How to Install & Use

Start off by cloning the repo:

```bash
git clone https://github.com/nickpotafiy/gpu-speed-test.git
cd gpu-speed-test
```

Install [Nvidia CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit) and make.

```bash
sudo apt install make
```

Compile with make:

```bash
make
```

After compile, execute the binary:

```code
./speed
```

You should get output like this:

```bash
Total devices found: 4

[ Device 0: NVIDIA GeForce RTX 4090]

Copied 1024 MiB from GPU 0 to GPU 1 in 88.3087 ms
Copied 1024 MiB from GPU 0 to GPU 2 in 87.0562 ms
Copied 1024 MiB from GPU 0 to GPU 3 in 98.5456 ms

[ Device 1: NVIDIA GeForce RTX 4090]

Copied 1024 MiB from GPU 1 to GPU 0 in 98.5968 ms
Copied 1024 MiB from GPU 1 to GPU 2 in 87.6707 ms
Copied 1024 MiB from GPU 1 to GPU 3 in 96.4554 ms

[ Device 2: NVIDIA GeForce RTX 4090]

Copied 1024 MiB from GPU 2 to GPU 0 in 88.5677 ms
Copied 1024 MiB from GPU 2 to GPU 1 in 88.7254 ms
Copied 1024 MiB from GPU 2 to GPU 3 in 96.4843 ms

[ Device 3: NVIDIA GeForce RTX 4090]

Copied 1024 MiB from GPU 3 to GPU 0 in 118.64 ms
Copied 1024 MiB from GPU 3 to GPU 1 in 96.6471 ms
Copied 1024 MiB from GPU 3 to GPU 2 in 106.842 ms
```