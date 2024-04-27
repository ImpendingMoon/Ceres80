import sys

def convert_file_to_c_header(input_file, output_file="data.hpp"):
    try:
        with open(input_file, 'rb') as f:
            data = f.read()
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found.")
        return
    except Exception as e:
        print(f"Error reading input file: {e}")
        return

    size = len(data)

    try:
        with open(output_file, 'w') as header_file:
            header_file.write(f"#ifndef ARDUINO_EEPROM_PROGRAMMER_DATA_HPP\n")
            header_file.write(f"#define ARDUINO_EEPROM_PROGRAMMER_DATA_HPP\n")
            header_file.write(f"\n")
            header_file.write(f"#include <stdint.h>\n")
            header_file.write(f"\n")
            header_file.write(f"const uint16_t DATA_SIZE = {size};\n")
            header_file.write(f"const PROGMEM uint8_t DATA[DATA_SIZE] =\n")
            header_file.write(f"{{")

            for i in range(size):
                if i % 8 == 0:
                    header_file.write("\n")
                
                header_file.write(f"0x{data[i]:02X}, ")
                
                if i == size - 1:
                    header_file.write("\n")
                

            header_file.write(f"}};\n")
            header_file.write(f"\n#endif //ARDUINO_EEPROM_PROGRAMMER_DATA_HPP\n")

        print(f"File '{output_file}' created successfully.")
    except Exception as e:
        print(f"Error writing output file: {e}")

if __name__ == "__main__":
    if len(sys.argv) == 2:
        input_file = sys.argv[1]
        convert_file_to_c_header(input_file)
    elif len(sys.argv) == 3:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        convert_file_to_c_header(input_file, output_file)
    else:
        print("Usage: python convert_to_c_header.py <input_file> [output_file]")
