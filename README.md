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

Copied 1 GiB from GPU 0 to GPU 1 in 89ms (11.29 GB/s)
Copied 1 GiB from GPU 0 to GPU 2 in 1068ms (0.94 GB/s)
Copied 1 GiB from GPU 0 to GPU 3 in 101ms (9.94 GB/s)

[ Device 1: NVIDIA GeForce RTX 4090]

Copied 1 GiB from GPU 1 to GPU 0 in 88ms (11.32 GB/s)
Copied 1 GiB from GPU 1 to GPU 2 in 1214ms (0.82 GB/s)
Copied 1 GiB from GPU 1 to GPU 3 in 91ms (11.04 GB/s)

[ Device 2: NVIDIA GeForce RTX 4090]

Copied 1 GiB from GPU 2 to GPU 0 in 1213ms (0.82 GB/s)
Copied 1 GiB from GPU 2 to GPU 1 in 1213ms (0.82 GB/s)
Copied 1 GiB from GPU 2 to GPU 3 in 1257ms (0.80 GB/s)

[ Device 3: NVIDIA GeForce RTX 4090]

Copied 1 GiB from GPU 3 to GPU 0 in 96ms (10.45 GB/s)
Copied 1 GiB from GPU 3 to GPU 1 in 98ms (10.25 GB/s)
Copied 1 GiB from GPU 3 to GPU 2 in 1417ms (0.71 GB/s)
```