// #include <iostream>
// #include <vector>
// #include <string>
// #include <opencv2/opencv.hpp>
// #include "Vzense_soc.h"
// #include "verilated.h"

// #include <cstdio>
// extern "C" {
//     #include <jpeglib.h>
// }

// const std::string C_RESET  = "\033[0m";
// const std::string C_GREEN  = "\033[32m"; 
// const std::string C_CYAN   = "\033[36m"; 
// const std::string C_YELLOW = "\033[33m"; 
// const std::string C_RED    = "\033[31m"; 
// const std::string C_MAGENTA= "\033[35m"; 

// void tick(Vzense_soc* top) { top->clk = 1; top->eval(); top->clk = 0; top->eval(); }

// void run_blur(Vzense_soc* top, const std::string& filename) {
//     top->core_sel = 1;
//     cv::Mat img = cv::imread(filename, cv::IMREAD_COLOR);
//     if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }
    
//     std::cout << C_CYAN << "[System] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " Color Image.\n";
//     std::vector<cv::Mat> bgr(3), out_bgr(3);
//     cv::split(img, bgr);
//     for(int i=0; i<3; i++) out_bgr[i] = cv::Mat(img.rows, img.cols, CV_8UC1);
//     std::string c_names[3] = {"Blue", "Green", "Red"};

//     for (int c = 0; c < 3; c++) {
//         std::cout << C_GREEN << "[Hardware] " << C_RESET << "Processing " << c_names[c] << " Channel...\n";
//         top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
        
//         top->ext_mem_select = 0; top->ext_we = 1;
//         for (int y = 0; y < img.rows; y++) {
//             for (int x = 0; x < img.cols; x++) {
//                 top->ext_addr = (y * img.cols) + x;
//                 top->ext_din = bgr[c].at<uchar>(y, x);
//                 tick(top);
//             }
//         }
        
//         top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
//         top->start = 1; tick(top); top->start = 0;
        
//         uint64_t cycles = 0;
//         while (top->done == 0) { tick(top); cycles++; }
        
//         top->ext_mem_select = 1; top->ext_we = 0;
//         for (int y = 0; y < img.rows; y++) {
//             for (int x = 0; x < img.cols; x++) {
//                 top->ext_addr = (y * img.cols) + x; tick(top);
//                 out_bgr[c].at<uchar>(y, x) = top->ext_dout;
//             }
//         }
//         std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
//     }
//     cv::Mat out_img; cv::merge(out_bgr, out_img);
//     cv::imwrite("output_blur.jpg", out_img);
//     std::cout << C_CYAN << "[System] Saved output_blur.jpg\n" << C_RESET;
// }

// void run_sobel(Vzense_soc* top, const std::string& filename) {
//     top->core_sel = 2;
//     cv::Mat img = cv::imread(filename, cv::IMREAD_GRAYSCALE);
//     if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }
    
//     std::cout << C_CYAN << "[System] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " Grayscale Image.\n";
//     top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
    
//     top->ext_mem_select = 0; top->ext_we = 1;
//     for (int y = 0; y < img.rows; y++) {
//         for (int x = 0; x < img.cols; x++) {
//             top->ext_addr = (y * img.cols) + x;
//             top->ext_din = img.at<uchar>(y, x);
//             tick(top);
//         }
//     }
    
//     std::cout << C_GREEN << "[Hardware] " << C_RESET << "Running Gradient Magnitude Convolution...\n";
//     top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
//     top->start = 1; tick(top); top->start = 0;
    
//     uint64_t cycles = 0;
//     while (top->done == 0) { tick(top); cycles++; }
    
//     cv::Mat out_img(img.rows, img.cols, CV_8UC1);
//     top->ext_mem_select = 1; top->ext_we = 0;
//     for (int y = 0; y < img.rows; y++) {
//         for (int x = 0; x < img.cols; x++) {
//             top->ext_addr = (y * img.cols) + x; tick(top);
//             out_img.at<uchar>(y, x) = top->ext_dout;
//         }
//     }
    
//     std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
//     cv::imwrite("output_sobel.jpg", out_img);
//     std::cout << C_CYAN << "[System] Saved output_sobel.jpg\n" << C_RESET;
// }

// void run_video(Vzense_soc* top) {
//     top->core_sel = 2; // Uses Sobel Edge
//     cv::VideoCapture cap(0); 
//     if (!cap.isOpened()) { std::cerr << C_RED << "Error: Could not open webcam!" << C_RESET << "\n"; return; }

//     int width = 320, height = 240;
//     top->img_width = width; top->img_height = height;

//     std::cout << C_MAGENTA << "\n[LIVE DEMO] Starting Hardware Edge Detection stream.\n" << C_RESET;
//     std::cout << "Make sure your terminal has GUI access to spawn OpenCV windows.\n";
//     std::cout << "Press 'q' in the video window to stop.\n\n";

//     cv::Mat frame, gray, out_img(height, width, CV_8UC1);

//     while (true) {
//         cap >> frame; if (frame.empty()) break;
//         cv::resize(frame, frame, cv::Size(width, height));
//         cv::cvtColor(frame, gray, cv::COLOR_BGR2GRAY);

//         top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
//         top->ext_mem_select = 0; top->ext_we = 1;
//         for (int y = 0; y < height; y++) {
//             for (int x = 0; x < width; x++) {
//                 top->ext_addr = (y * width) + x;
//                 top->ext_din = gray.at<uchar>(y, x);
//                 tick(top); 
//             }
//         }
        
//         top->ext_we = 0; top->start = 1; tick(top); top->start = 0;
//         while (top->done == 0) tick(top);

//         top->ext_mem_select = 1;
//         for (int y = 0; y < height; y++) {
//             for (int x = 0; x < width; x++) {
//                 top->ext_addr = (y * width) + x; tick(top);
//                 out_img.at<uchar>(y, x) = top->ext_dout;
//             }
//         }

//         cv::imshow("Hardware Output (Real-Time)", out_img);
//         if ((char)cv::waitKey(1) == 'q') break; 
//     }
//     cap.release(); cv::destroyAllWindows();
// }

// void run_histogram(Vzense_soc* top, const std::string& filename) {
//     top->core_sel = 3;
//     cv::Mat img = cv::imread(filename, cv::IMREAD_GRAYSCALE);
//     if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }
    
//     std::cout << C_CYAN << "[System] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " Grayscale Image.\n";
//     top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
    
//     top->ext_mem_select = 0; top->ext_we = 1;
//     for (int y = 0; y < img.rows; y++) {
//         for (int x = 0; x < img.cols; x++) {
//             top->ext_addr = (y * img.cols) + x;
//             top->ext_din = img.at<uchar>(y, x); tick(top);
//         }
//     }
    
//     std::cout << C_GREEN << "[Hardware] " << C_RESET << "Running Spatial CDF Distribution...\n";
//     top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
//     top->start = 1; tick(top); top->start = 0;
    
//     uint64_t cycles = 0;
//     while (top->done == 0) { tick(top); cycles++; }
    
//     cv::Mat out_img(img.rows, img.cols, CV_8UC1);
//     top->ext_mem_select = 1; 
//     for (int y = 0; y < img.rows; y++) {
//         for (int x = 0; x < img.cols; x++) {
//             top->ext_addr = (y * img.cols) + x; tick(top); 
//             out_img.at<uchar>(y, x) = top->ext_dout;
//         }
//     }
    
//     std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
//     cv::imwrite("output_equalized.jpg", out_img);
//     std::cout << C_CYAN << "[System] Saved output_equalized.jpg\n" << C_RESET;
// }

// void run_jpeg(Vzense_soc* top, const std::string& filename) {
//     top->core_sel = 4;
//     cv::Mat img = cv::imread(filename, cv::IMREAD_COLOR); 
//     if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }

//     int pad_r = (8 - (img.rows % 8)) % 8;
//     int pad_c = (8 - (img.cols % 8)) % 8;
//     cv::copyMakeBorder(img, img, 0, pad_r, 0, pad_c, cv::BORDER_REPLICATE);

//     std::cout << C_CYAN << "[System] " << C_RESET << "Loaded & Padded " << img.cols << "x" << img.rows << " RGB Image.\n";
//     top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;

//     top->ext_mem_select = 0; top->ext_we = 1;
//     for (int y = 0; y < img.rows; y++) {
//         for (int x = 0; x < img.cols; x++) {
//             top->ext_addr = (y * img.cols) + x;
//             cv::Vec3b pixel = img.at<cv::Vec3b>(y, x);
//             top->ext_din = (pixel[2] << 16) | (pixel[1] << 8) | pixel[0]; 
//             tick(top);
//         }
//     }
    
//     std::cout << C_GREEN << "[Hardware] " << C_RESET << "Running 2D Systolic DCT & Quantization...\n";
//     top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
//     top->start = 1; tick(top); top->start = 0;

//     uint64_t cycles = 0;
//     while (top->done == 0) { tick(top); cycles++; }
//     std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";

//     std::cout << C_CYAN << "[System] " << C_RESET << "Encoding LibJPEG Huffman headers...\n";
    
//     jpeg_compress_struct cinfo; jpeg_error_mgr jerr;
//     cinfo.err = jpeg_std_error(&jerr); jpeg_create_compress(&cinfo);
//     cinfo.mem->max_memory_to_use = 1024L * 1024L * 1024L; 

//     FILE* outfile = fopen("output_compressed.jpg", "wb");
//     jpeg_stdio_dest(&cinfo, outfile);

//     cinfo.image_width = img.cols; cinfo.image_height = img.rows;
//     cinfo.input_components = 3; cinfo.in_color_space = JCS_YCbCr;
//     jpeg_set_defaults(&cinfo); jpeg_set_quality(&cinfo, 50, TRUE);

//     int mb_width = img.cols / 8; int mb_height = img.rows / 8;
//     cinfo.jpeg_width = img.cols; cinfo.jpeg_height = img.rows;
//     cinfo.max_h_samp_factor = 1; cinfo.max_v_samp_factor = 1; cinfo.total_iMCU_rows = mb_height; 

//     for (int ci = 0; ci < 3; ci++) {
//         cinfo.comp_info[ci].component_index = ci;
//         cinfo.comp_info[ci].h_samp_factor = 1; cinfo.comp_info[ci].v_samp_factor = 1;
//         cinfo.comp_info[ci].width_in_blocks = mb_width; cinfo.comp_info[ci].height_in_blocks = mb_height;
//     }
//     cinfo.optimize_coding = TRUE; 

//     jvirt_barray_ptr coef_arrays[3];
//     for (int ci = 0; ci < 3; ci++) 
//         coef_arrays[ci] = (cinfo.mem->request_virt_barray)((j_common_ptr)&cinfo, JPOOL_IMAGE, TRUE, mb_width, mb_height, mb_height);
//     (cinfo.mem->realize_virt_arrays)((j_common_ptr)&cinfo);

//    top->ext_mem_select = 1; 
//     for (int by = 0; by < mb_height; by++) {
//         JBLOCKARRAY buf_Y  = (cinfo.mem->access_virt_barray)((j_common_ptr)&cinfo, coef_arrays[0], by, 1, TRUE);
//         JBLOCKARRAY buf_Cb = (cinfo.mem->access_virt_barray)((j_common_ptr)&cinfo, coef_arrays[1], by, 1, TRUE);
//         JBLOCKARRAY buf_Cr = (cinfo.mem->access_virt_barray)((j_common_ptr)&cinfo, coef_arrays[2], by, 1, TRUE);

//         for (int bx = 0; bx < mb_width; bx++) {
//             for (int y = 0; y < 8; y++) {
//                 for (int x = 0; x < 8; x++) {
//                     top->ext_addr = ((by * 8) + y) * img.cols + ((bx * 8) + x); tick(top); 
//                     uint32_t packed = top->ext_dout;
                    
//                     // THE FIX: Explicitly cast the extracted bytes back to SIGNED 8-bit integers (int8_t)
//                     buf_Y[0][bx][y*8+x]  = (JCOEF) (int8_t) ((packed >> 16) & 0xFF);
//                     buf_Cb[0][bx][y*8+x] = (JCOEF) (int8_t) ((packed >> 8)  & 0xFF);
//                     buf_Cr[0][bx][y*8+x] = (JCOEF) (int8_t) (packed         & 0xFF);
//                 }
//             }
//         }
//     }

//     jpeg_write_coefficients(&cinfo, coef_arrays);
//     jpeg_finish_compress(&cinfo); fclose(outfile); jpeg_destroy_compress(&cinfo);
    
//     std::cout << C_CYAN << "[System] Saved output_compressed.jpg\n" << C_RESET;
// }

// void run_dither(Vzense_soc* top, const std::string& filename) {
//     top->core_sel = 5;
//     cv::Mat img = cv::imread(filename, cv::IMREAD_COLOR); 
//     if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }

//     std::cout << C_CYAN << "[System] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " RGB Image.\n";
//     std::vector<cv::Mat> bgr(3), out_bgr(3);
//     cv::split(img, bgr);
//     for(int i=0; i<3; i++) out_bgr[i] = cv::Mat(img.rows, img.cols, CV_8UC1);
//     std::string c_names[3] = {"Blue", "Green", "Red"};

//     for(int c=0; c<3; c++) {
//         std::cout << C_GREEN << "[Hardware] " << C_RESET << "Diffusing errors for " << c_names[c] << "...\n";
//         top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
        
//         top->ext_mem_select = 0; top->ext_we = 1;
//         for (int y = 0; y < img.rows; y++) {
//             for (int x = 0; x < img.cols; x++) {
//                 top->ext_addr = (y * img.cols) + x;
//                 top->ext_din = bgr[c].at<uchar>(y, x); tick(top);
//             }
//         }
        
//         top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
//         top->start = 1; tick(top); top->start = 0;
        
//         uint64_t cycles = 0;
//         while (top->done == 0) { tick(top); cycles++; }
        
//         top->ext_mem_select = 1; 
//         for (int y = 0; y < img.rows; y++) {
//             for (int x = 0; x < img.cols; x++) {
//                 top->ext_addr = (y * img.cols) + x; tick(top);
//                 out_bgr[c].at<uchar>(y, x) = top->ext_dout & 0xFF; 
//             }
//         }
//         std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
//     }

//     cv::Mat out_img; cv::merge(out_bgr, out_img);
//     cv::imwrite("output_dither.png", out_img);
//     std::cout << C_CYAN << "[System] Saved output_dither.png\n" << C_RESET;
// }

// int main(int argc, char** argv) {
//     Verilated::commandArgs(argc, argv);
//     Vzense_soc* top = new Vzense_soc;
//     std::string target = "test_image.jpg"; 

//     while (true) {
//         std::cout << "\n" << C_MAGENTA << "==========================================================" << C_RESET << "\n";
//         std::cout << C_GREEN << "  ZENSE VISION: RTL Image Processing Accelerator Suite" << C_RESET << "\n";
//         std::cout << C_MAGENTA << "==========================================================" << C_RESET << "\n";
//         std::cout << "Target File: " << C_YELLOW << target << C_RESET << "\n\n";
//         std::cout << "Select Accelerator Core:\n";
//         std::cout << "  [1] Gaussian Blur (Spatial Convolution)\n";
//         std::cout << "  [2] Sobel Edge Detection (Gradient Magnitude)\n";
//         std::cout << "  [3] Live Webcam Edge Detection\n";
//         std::cout << "  [4] Histogram Equalization (Contrast Stretching)\n";
//         std::cout << "  [5] JPEG Compression (2D DCT)\n";
//         std::cout << "  [6] Floyd-Steinberg Dithering (Error Diffusion)\n";
//         std::cout << "  [7] Change Target Image\n";
//         std::cout << "  [0] Exit\n\n";
//         std::cout << "zense-os> ";

//         int choice;
//         if (!(std::cin >> choice)) break;

//         switch (choice) {
//             case 0: std::cout << C_CYAN << "Powering down cores. Goodbye.\n" << C_RESET; delete top; return 0;
//             case 1: run_blur(top, target); break;
//             case 2: run_sobel(top, target); break;
//             case 3: run_video(top); break;
//             case 4: run_histogram(top, target); break;
//             case 5: run_jpeg(top, target); break;
//             case 6: run_dither(top, target); break;
//             case 7: 
//                 std::cout << "Enter new filename (e.g. image.png): ";
//                 std::cin >> target;
//                 break;
//             default: std::cout << C_RED << "Invalid core selection.\n" << C_RESET;
//         }
//     }
//     delete top;
//     return 0;
// }

#include <iostream>
#include <vector>
#include <string>
#include <opencv2/opencv.hpp>
#include "Vsv_soc.h"
#include "verilated.h"

#include <cstdio>
extern "C" {
    #include <jpeglib.h>
}

// --- ANSI Color Codes for Premium UX ---
const std::string C_RESET  = "\033[0m";
const std::string C_GREEN  = "\033[32m"; 
const std::string C_CYAN   = "\033[36m"; 
const std::string C_YELLOW = "\033[33m"; 
const std::string C_RED    = "\033[31m"; 
const std::string C_MAGENTA= "\033[35m"; 

void tick(Vsv_soc* top) { top->clk = 1; top->eval(); top->clk = 0; top->eval(); }

void run_blur(Vsv_soc* top, const std::string& filename) {
    top->core_sel = 1;
    cv::Mat img = cv::imread(filename, cv::IMREAD_COLOR);
    if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }
    
    std::cout << C_CYAN << "[Host] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " Color Image.\n";
    std::vector<cv::Mat> bgr(3), out_bgr(3);
    cv::split(img, bgr);
    for(int i=0; i<3; i++) out_bgr[i] = cv::Mat(img.rows, img.cols, CV_8UC1);
    std::string c_names[3] = {"Blue", "Green", "Red"};

    for (int c = 0; c < 3; c++) {
        std::cout << C_GREEN << "[Hardware] " << C_RESET << "Processing " << c_names[c] << " Channel...\n";
        top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
        
        top->ext_mem_select = 0; top->ext_we = 1;
        for (int y = 0; y < img.rows; y++) {
            for (int x = 0; x < img.cols; x++) {
                top->ext_addr = (y * img.cols) + x;
                top->ext_din = bgr[c].at<uchar>(y, x);
                tick(top);
            }
        }
        
        top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
        top->start = 1; tick(top); top->start = 0;
        
        uint64_t cycles = 0;
        while (top->done == 0) { tick(top); cycles++; }
        
        top->ext_mem_select = 1; top->ext_we = 0;
        for (int y = 0; y < img.rows; y++) {
            for (int x = 0; x < img.cols; x++) {
                top->ext_addr = (y * img.cols) + x; tick(top);
                out_bgr[c].at<uchar>(y, x) = top->ext_dout;
            }
        }
        std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
    }
    cv::Mat out_img; cv::merge(out_bgr, out_img);
    cv::imwrite("output_blur.jpg", out_img);
    std::cout << C_CYAN << "[Host] Saved output_blur.jpg\n" << C_RESET;
}

void run_sobel(Vsv_soc* top, const std::string& filename) {
    top->core_sel = 2;
    cv::Mat img = cv::imread(filename, cv::IMREAD_GRAYSCALE);
    if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }
    
    std::cout << C_CYAN << "[Host] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " Grayscale Image.\n";
    top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
    
    top->ext_mem_select = 0; top->ext_we = 1;
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            top->ext_addr = (y * img.cols) + x;
            top->ext_din = img.at<uchar>(y, x);
            tick(top);
        }
    }
    
    std::cout << C_GREEN << "[Hardware] " << C_RESET << "Running Gradient Magnitude Convolution...\n";
    top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
    top->start = 1; tick(top); top->start = 0;
    
    uint64_t cycles = 0;
    while (top->done == 0) { tick(top); cycles++; }
    
    cv::Mat out_img(img.rows, img.cols, CV_8UC1);
    top->ext_mem_select = 1; top->ext_we = 0;
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            top->ext_addr = (y * img.cols) + x; tick(top);
            out_img.at<uchar>(y, x) = top->ext_dout;
        }
    }
    
    std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
    cv::imwrite("output_sobel.jpg", out_img);
    std::cout << C_CYAN << "[Host] Saved output_sobel.jpg\n" << C_RESET;
}

void run_histogram(Vsv_soc* top, const std::string& filename) {
    top->core_sel = 3;
    cv::Mat img = cv::imread(filename, cv::IMREAD_GRAYSCALE);
    if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }
    
    std::cout << C_CYAN << "[Host] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " Grayscale Image.\n";
    top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
    
    top->ext_mem_select = 0; top->ext_we = 1;
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            top->ext_addr = (y * img.cols) + x;
            top->ext_din = img.at<uchar>(y, x); tick(top);
        }
    }
    
    std::cout << C_GREEN << "[Hardware] " << C_RESET << "Running Spatial CDF Distribution...\n";
    top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
    top->start = 1; tick(top); top->start = 0;
    
    uint64_t cycles = 0;
    while (top->done == 0) { tick(top); cycles++; }
    
    cv::Mat out_img(img.rows, img.cols, CV_8UC1);
    top->ext_mem_select = 1; 
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            top->ext_addr = (y * img.cols) + x; tick(top); 
            out_img.at<uchar>(y, x) = top->ext_dout;
        }
    }
    
    std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
    cv::imwrite("output_equalized.jpg", out_img);
    std::cout << C_CYAN << "[Host] Saved output_equalized.jpg\n" << C_RESET;
}

void run_jpeg(Vsv_soc* top, const std::string& filename) {
    top->core_sel = 4;
    cv::Mat img = cv::imread(filename, cv::IMREAD_COLOR); 
    if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }

    int pad_r = (8 - (img.rows % 8)) % 8;
    int pad_c = (8 - (img.cols % 8)) % 8;
    cv::copyMakeBorder(img, img, 0, pad_r, 0, pad_c, cv::BORDER_REPLICATE);

    std::cout << C_CYAN << "[Host] " << C_RESET << "Loaded & Padded " << img.cols << "x" << img.rows << " RGB Image.\n";
    top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;

    top->ext_mem_select = 0; top->ext_we = 1;
    for (int y = 0; y < img.rows; y++) {
        for (int x = 0; x < img.cols; x++) {
            top->ext_addr = (y * img.cols) + x;
            cv::Vec3b pixel = img.at<cv::Vec3b>(y, x);
            top->ext_din = (pixel[2] << 16) | (pixel[1] << 8) | pixel[0]; 
            tick(top);
        }
    }
    
    std::cout << C_GREEN << "[Hardware] " << C_RESET << "Running 2D Systolic DCT & Quantization...\n";
    top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
    top->start = 1; tick(top); top->start = 0;

    uint64_t cycles = 0;
    while (top->done == 0) { tick(top); cycles++; }
    std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";

    std::cout << C_CYAN << "[Host] " << C_RESET << "Encoding LibJPEG Huffman headers...\n";
    
    jpeg_compress_struct cinfo; jpeg_error_mgr jerr;
    cinfo.err = jpeg_std_error(&jerr); jpeg_create_compress(&cinfo);
    cinfo.mem->max_memory_to_use = 1024L * 1024L * 1024L; 

    FILE* outfile = fopen("output_compressed.jpg", "wb");
    jpeg_stdio_dest(&cinfo, outfile);

    cinfo.image_width = img.cols; cinfo.image_height = img.rows;
    cinfo.input_components = 3; cinfo.in_color_space = JCS_YCbCr;
    jpeg_set_defaults(&cinfo); jpeg_set_quality(&cinfo, 50, TRUE);

    int mb_width = img.cols / 8; int mb_height = img.rows / 8;
    cinfo.jpeg_width = img.cols; cinfo.jpeg_height = img.rows;
    cinfo.max_h_samp_factor = 1; cinfo.max_v_samp_factor = 1; cinfo.total_iMCU_rows = mb_height; 

    for (int ci = 0; ci < 3; ci++) {
        cinfo.comp_info[ci].component_index = ci;
        cinfo.comp_info[ci].h_samp_factor = 1; cinfo.comp_info[ci].v_samp_factor = 1;
        cinfo.comp_info[ci].width_in_blocks = mb_width; cinfo.comp_info[ci].height_in_blocks = mb_height;
    }
    cinfo.optimize_coding = TRUE; 

    jvirt_barray_ptr coef_arrays[3];
    for (int ci = 0; ci < 3; ci++) 
        coef_arrays[ci] = (cinfo.mem->request_virt_barray)((j_common_ptr)&cinfo, JPOOL_IMAGE, TRUE, mb_width, mb_height, mb_height);
    (cinfo.mem->realize_virt_arrays)((j_common_ptr)&cinfo);

    top->ext_mem_select = 1; 
    for (int by = 0; by < mb_height; by++) {
        JBLOCKARRAY buf_Y  = (cinfo.mem->access_virt_barray)((j_common_ptr)&cinfo, coef_arrays[0], by, 1, TRUE);
        JBLOCKARRAY buf_Cb = (cinfo.mem->access_virt_barray)((j_common_ptr)&cinfo, coef_arrays[1], by, 1, TRUE);
        JBLOCKARRAY buf_Cr = (cinfo.mem->access_virt_barray)((j_common_ptr)&cinfo, coef_arrays[2], by, 1, TRUE);

        for (int bx = 0; bx < mb_width; bx++) {
            for (int y = 0; y < 8; y++) {
                for (int x = 0; x < 8; x++) {
                    top->ext_addr = ((by * 8) + y) * img.cols + ((bx * 8) + x); tick(top); 
                    uint32_t packed = top->ext_dout;
                    
                    buf_Y[0][bx][y*8+x]  = (JCOEF) (int8_t) ((packed >> 16) & 0xFF);
                    buf_Cb[0][bx][y*8+x] = (JCOEF) (int8_t) ((packed >> 8)  & 0xFF);
                    buf_Cr[0][bx][y*8+x] = (JCOEF) (int8_t) (packed         & 0xFF);
                }
            }
        }
    }

    jpeg_write_coefficients(&cinfo, coef_arrays);
    jpeg_finish_compress(&cinfo); fclose(outfile); jpeg_destroy_compress(&cinfo);
    
    std::cout << C_CYAN << "[Host] Saved output_compressed.jpg\n" << C_RESET;
}

void run_dither(Vsv_soc* top, const std::string& filename) {
    top->core_sel = 5;
    cv::Mat img = cv::imread(filename, cv::IMREAD_COLOR); 
    if (img.empty()) { std::cerr << C_RED << "Error loading image." << C_RESET << "\n"; return; }

    std::cout << C_CYAN << "[Host] " << C_RESET << "Loaded " << img.cols << "x" << img.rows << " RGB Image.\n";
    std::vector<cv::Mat> bgr(3), out_bgr(3);
    cv::split(img, bgr);
    for(int i=0; i<3; i++) out_bgr[i] = cv::Mat(img.rows, img.cols, CV_8UC1);
    std::string c_names[3] = {"Blue", "Green", "Red"};

    for(int c=0; c<3; c++) {
        std::cout << C_GREEN << "[Hardware] " << C_RESET << "Diffusing errors for " << c_names[c] << "...\n";
        top->reset = 1; top->clk = 0; top->start = 0; top->eval(); tick(top); top->reset = 0;
        
        top->ext_mem_select = 0; top->ext_we = 1;
        for (int y = 0; y < img.rows; y++) {
            for (int x = 0; x < img.cols; x++) {
                top->ext_addr = (y * img.cols) + x;
                top->ext_din = bgr[c].at<uchar>(y, x); tick(top);
            }
        }
        
        top->ext_we = 0; top->img_width = img.cols; top->img_height = img.rows;
        top->start = 1; tick(top); top->start = 0;
        
        uint64_t cycles = 0;
        while (top->done == 0) { tick(top); cycles++; }
        
        top->ext_mem_select = 1; 
        for (int y = 0; y < img.rows; y++) {
            for (int x = 0; x < img.cols; x++) {
                top->ext_addr = (y * img.cols) + x; tick(top);
                out_bgr[c].at<uchar>(y, x) = top->ext_dout & 0xFF; 
            }
        }
        std::cout << C_YELLOW << "   >> Cycles: " << cycles << C_RESET << "\n";
    }

    cv::Mat out_img; cv::merge(out_bgr, out_img);
    cv::imwrite("output_dither.png", out_img);
    std::cout << C_CYAN << "[Host] Saved output_dither.png\n" << C_RESET;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vsv_soc* top = new Vsv_soc;
    std::string target = "test_image.jpg"; 

    while (true) {
        std::cout << "\n" << C_MAGENTA << "==========================================================" << C_RESET << "\n";
        std::cout << C_GREEN << "  SiliconVision: FPGA Image Processing Accelerator Suite" << C_RESET << "\n";
        std::cout << C_MAGENTA << "==========================================================" << C_RESET << "\n";
        std::cout << "Target File: " << C_YELLOW << target << C_RESET << "\n\n";
        std::cout << "Select Accelerator Core:\n";
        std::cout << "  [1] Gaussian Blur (Spatial Convolution)\n";
        std::cout << "  [2] Sobel Edge Detection (Gradient Magnitude)\n";
        std::cout << "  [3] Histogram Equalization (Contrast Stretching)\n";
        std::cout << "  [4] JPEG Compression (2D DCT)\n";
        std::cout << "  [5] Floyd-Steinberg Dithering (Error Diffusion)\n";
        std::cout << "  [6] Change Target Image\n";
        std::cout << "  [0] Exit\n\n";
        std::cout << "sv-cli> ";

        int choice;
        if (!(std::cin >> choice)) break;

        switch (choice) {
            case 0: std::cout << C_CYAN << "Powering down cores. Goodbye.\n" << C_RESET; delete top; return 0;
            case 1: run_blur(top, target); break;
            case 2: run_sobel(top, target); break;
            case 3: run_histogram(top, target); break;
            case 4: run_jpeg(top, target); break;
            case 5: run_dither(top, target); break;
            case 6: 
                std::cout << "Enter new filename (e.g. image.png): ";
                std::cin >> target;
                break;
            default: std::cout << C_RED << "Invalid core selection.\n" << C_RESET;
        }
    }
    delete top;
    return 0;
}
