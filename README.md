# SiliconVision: RTL Image Processing Accelerator Suite

![Verilog](https://img.shields.io/badge/RTL-Verilog-blue.svg)
![C++](https://img.shields.io/badge/Host-C%2B%2B17-00599C.svg)
![Verilator](https://img.shields.io/badge/Simulation-Verilator-orange.svg)
![OpenCV](https://img.shields.io/badge/Library-OpenCV_4-green.svg)

SiliconVision is a cycle-accurate Hardware/Software Co-design project that implements a custom System-on-Chip (SoC) for high-performance image processing. The hardware is written in structural and behavioral Verilog, simulated via **Verilator**, and orchestrated by a unified C++ host application acting as a pseudo-DMA controller. 

Rather than relying on software libraries for pixel manipulation, the C++ host decodes image data and streams it into the simulated dual-port BRAM, allowing the RTL to handle the heavy mathematical workloads.

---

## 🧠 System Architecture

The core of the system is the `sv_soc` (System-on-Chip) hardware multiplexer. It dynamically routes clock signals, memory access, and execution states to one of five dedicated hardware accelerators based on the C++ host's commands. 

This architecture embraces **Time-Multiplexing**. Instead of wasting FPGA silicon on massive 24-bit RGB processing arrays, the SoC utilizes lean 8-bit computational cores. The C++ host automatically splits color images into independent channels (Red, Green, Blue), streams them sequentially through the hardware, and recombines the results, maximizing silicon efficiency.

### Hardware IP Cores

1. **Gaussian Blur (2D Systolic Array):** A spatial convolution engine utilizing a 2D window for low-pass filtering.
2. **Sobel Edge Detector (2D Systolic Array):** Hardware gradient magnitude calculation for high-frequency feature extraction.
3. **Histogram Equalizer:** A multi-stage pipeline utilizing internal block RAM for PDF/CDF calculation and dynamic contrast stretching.
4. **JPEG Compressor (2D Systolic Array):** A highly optimized 64-node systolic mesh that computes the 2D Discrete Cosine Transform (DCT). It maps mathematical coefficients directly into libjpeg's Huffman encoding buffers for true hardware compression.
5. **Floyd-Steinberg Dithering:** A strictly causal error-diffusion engine. To bypass multi-write BRAM bottlenecks, this core utilizes a custom **3-stage sliding-window shift register** and a dedicated Line Buffer, allowing 1-pixel-per-clock processing.

---

## 📂 Repository Structure

```text
SiliconVision/
├── rtl/                    # Verilog Hardware IP Cores
│   ├── sv_soc.v            # Top-level SoC Multiplexer
│   ├── sys_array_blur.v    # Spatial Convolution Core
│   ├── sys_array_edge.v    # Gradient Magnitude Core
│   ├── hist_eq.v           # Histogram Core
│   ├── dither_hw.v         # Error Diffusion Core
│   ├── jpeg_encoder_hw.v   # JPEG/DCT Top Module
│   └── *.v                 # Sub-modules (Quantizer, PE matrices, etc.)
├── host/                   # C++ Software Driver
│   └── main_sim.cpp            # Host CLI and DMA orchestrator
├── scripts/                # Build Automation
│   └── build_sim.sh            # Verilator compilation script
└── test_images/            # Sample inputs for simulation
