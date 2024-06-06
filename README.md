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

Compile with make:

```bash
make
```

After compile, execute the binary:

```code
./speed
```

You should get t