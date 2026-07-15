#!/bin/bash

# Exit on any error
set -e

# Force execution from the root of the repository
cd "$(dirname "$0")/.."

echo -e "\033[36m[System] Cleaning previous builds...\033[0m"
rm -rf obj_dir

echo -e "\033[36m[System] Compiling SiliconVision RTL Suite...\033[0m"

verilator -Wall -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-PINCONNECTEMPTY -Wno-DECLFILENAME -Wno-GENUNNAMED -Wno-UNUSEDSIGNAL -Wno-PINMISSING \
    --cc \
    rtl/sv_soc.v \
    rtl/sys_array_blur.v \
    rtl/sys_array_edge.v \
    rtl/hist_eq.v \
    rtl/dither_hw.v \
    rtl/jpeg_encoder_hw.v rtl/rgb_ycbcr.v rtl/quantizer.v rtl/kernel_row_dct.v rtl/pe_dct.v rtl/sys_matrix.v rtl/reg.v rtl/skew_buff.v \
    --top-module sv_soc \
    --exe host/main_sim.cpp \
    -CFLAGS "$(pkg-config --cflags opencv4) -O3" \
    -LDFLAGS "$(pkg-config --libs opencv4) -ljpeg" \
    --build

echo -e "\033[32m[System] Compilation successful. Booting CLI...\033[0m"
./obj_dir/Vsv_soc
