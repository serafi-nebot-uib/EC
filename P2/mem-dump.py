import sys
import binascii

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("ERROR: file name not specified")
        exit(-1)

    with open(sys.argv[1], "rb") as f:
        data = f.read()
        data = [data[i:i + 16] for i in range(0, len(data), 16)]
        idx = 0x1000
        for row in data:
            print(f"{idx:08x}: ", end="")
            print(" ".join([f"{x:02X}" for x in row]))
            idx += 16
