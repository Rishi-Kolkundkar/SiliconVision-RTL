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
## 🔌 Physical FPGA Deployment (Synthesis)

While the `main` branch is dedicated to Verilator simulation and C++ Co-design, physical FPGA synthesis has been successfully implemented for the **Sobel Edge Detector** core. 

To maintain a clean, bloat-free repository, all physical implementation files (Xilinx/Vivado) are isolated on a dedicated deployment branch. This branch utilizes **Tcl scripting** for project recreation rather than uploading bloated `.xpr` project files, adhering strictly to industry standards for Electronic Design Automation (EDA) version control.

### Accessing the Hardware Branch
To view the physical constraints (`.xdc`), synthesis-ready Verilog, and the automated Vivado build scripts, fetch and check out the deployment branch:

```bash
git fetch origin
git checkout fpga-deployment
```

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
```
## Environment and Dependencies
Preferred Operating System: Linux (Ubuntu/Debian) is the highly preferred and native environment for this project due to its seamless integration with Verilator and GNU Make.

For Windows Users: It is strongly recommended to run this project via WSL2 (Windows Subsystem for Linux) rather than attempting a native Windows MSYS2/MinGW port. WSL provides the exact Linux toolchain required for Verilator to compile the structural Verilog correctly.

## Installation Commands (Ubuntu / Debian / WSL)
Before building the project, you must install the required hardware simulation and image processing libraries. Open your terminal and run:
```text
sudo apt-get update
sudo apt-get install -y verilator libopencv-dev libjpeg-dev build-essential pkg-config
```
## 🚀 Build and Run Guide
The project features a streamlined bash script that automatically compiles the Verilog RTL into C++ models, links the OpenCV and libjpeg libraries, and boots the CLI application.
1. Clone the repository:
   ```text
   git clone [https://github.com/Rishi-Kolkundkar/SiliconVision-RTL.git](https://github.com/Rishi-Kolkundkar/SiliconVision-RTL.git)
   cd SiliconVision-RTL
   ```
2. Make the build script executable:
    ```text
     chmod +x scripts/build_sim.sh
   ```
3. Compile the SoC and boot the CLI:
    ```text
     ./scripts/build_sim.sh
   ```
    
