import serial
import time
from PIL import Image


COM_PORT = 'COM5' 
BAUD_RATE = 115200
WIDTH, HEIGHT = 256, 256
TOTAL_PIXELS = WIDTH * HEIGHT

INPUT_IMAGE = 'test_image.jpg'
OUTPUT_IMAGE = 'fpga_edge_result.png'

def main():
    
    print(f"[*] Opening and processing {INPUT_IMAGE}...")
    try:
        img = Image.open(INPUT_IMAGE)
    except FileNotFoundError:
        print(f"[!] Error: Could not find {INPUT_IMAGE} in the current directory.")
        return


    img_gray = img.convert('L')
    
    
    img_resized = img_gray.resize((WIDTH, HEIGHT))
    
    
    pixel_data = bytearray(img_resized.tobytes())
    print(f"[*] Image flattened. Total bytes to send: {len(pixel_data)}")

    
    print(f"[*] Opening {COM_PORT} at {BAUD_RATE} baud...")
    try:
        ser = serial.Serial(COM_PORT, BAUD_RATE, timeout=10) 
    except Exception as e:
        print(f"[!] Failed to open port {COM_PORT}. Check Device Manager!")
        print(e)
        return

    ser.reset_input_buffer()
    ser.reset_output_buffer()

    print("[*] Streaming pixels to the FPGA...")
    start_time = time.time()
    

    ser.write(pixel_data)
    
    print("[*] Waiting for hardware accelerator to process...")
    
    received_data = ser.read(TOTAL_PIXELS)
    
    end_time = time.time()
    ser.close()

    if len(received_data) != TOTAL_PIXELS:
        print(f"[!] Error: Expected {TOTAL_PIXELS} bytes, but only received {len(received_data)}.")
        print("[!] The hardware FSM might be stuck or out of sync.")
        return

    print(f"[*] Success! Received full image back in {end_time - start_time:.2f} seconds.")

    print(f"[*] Reconstructing image...")
    
    out_img = Image.new('L', (WIDTH, HEIGHT))
    
    out_img.frombytes(received_data)
    
    out_img.save(OUTPUT_IMAGE)
    print(f"[*] Edge-detected image saved as {OUTPUT_IMAGE}!")
    
    out_img.show()

if __name__ == "__main__":
    main()