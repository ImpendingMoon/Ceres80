from PIL import Image
import sys

def convert_image_to_binary(input_image_path, output_file_path, threshold=128):
    """
    Converts an image to a packed binary format suitable for monochrome displays.

    :param input_image_path: Path to the input image.
    :param output_file_path: Path to the output binary file.
    :param threshold: Grayscale threshold for binarization (default 128).
    """
    try:
        # Open the image
        image = Image.open(input_image_path).convert("L")  # Convert to grayscale

        # Convert to monochrome using the threshold
        binary_image = image.point(lambda p: 255 if p > threshold else 0, '1')

        # Get the pixel data
        pixels = binary_image.load()
        width, height = binary_image.size

        # Open the output file in binary write mode
        with open(output_file_path, "wb") as binary_file:
            for y in range(height):
                byte = 0
                for x in range(width):
                    # Set the bit if the pixel is black (value 0)
                    if pixels[x, y] == 0:
                        byte |= (1 << (7 - (x % 8)))

                    # Write the byte to the file when 8 bits are collected or at the end of a row
                    if (x % 8 == 7) or (x == width - 1):
                        binary_file.write(byte.to_bytes(1, 'big'))
                        byte = 0

        print(f"Image successfully converted and saved to {output_file_path}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert_image_to_binary.py <input_image_path> <output_file_path>")
    else:
        input_image_path = sys.argv[1]
        output_file_path = sys.argv[2]
        convert_image_to_binary(input_image_path, output_file_path)
