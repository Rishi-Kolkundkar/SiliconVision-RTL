#!/bin/bash

# Exit on any error
set -e

echo -e "\033[36m[System] Cleaning previous builds...\033[0m"
rm -rf obj_dir

echo -e "\033[36m[System] Compiling SiliconVision RTL Suite...\033[0m"

verilator -Wall -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-PINCONNECTEMPTY -Wno-DECLFILENAME -Wno-GENUNNAMED -Wno-UNUSEDSIGNAL -Wno-PINMISSING \
    --cc \
    sv_soc.v \
    sys_array_blur.v \
    sys_array_edge.v \
    hist_eq.v \
    dither_hw.v \
    jpeg_encoder_hw.v rgb_ycbcr.v quantizer.v kernel_row_dct.v pe_dct.v sys_matrix.v reg.v skew_buff.v \
    --top-module sv_soc \
    --exe main_sim.cpp \
    -CFLAGS "$(pkg-config --cflags opencv4) -O3" \
    -LDFLAGS "$(pkg-config --libs opencv4) -ljpeg" \
    --build

echo -e "\033[32m[System] Compilation successful. Booting CLI...\033[0m"
./obj_dir/Vsv_soc