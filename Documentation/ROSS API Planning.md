# Rom Operating System S (ROSS) API Planning

## Notes

### Timing & Scheduling
- **System Tick**: The system timer operates at 100 Hz, resulting in a tick period of 10 milliseconds. This tick is used in all time-based operations.

### Resource Restrictions
- **IY Register**: The IY register is reserved for use by the operating system and should not be accessed by application code.

## Calling Convention:

- System calls are made by calling address `0x0008`, such as with `RST 08h`
- The call number is placed in A.
- Parameters use the sdcccall(0) convention.
    - Parameters are placed on the stack, right to left.
    - 8-bit return values are passed in `L`, 16-bit in `HL`, 24-bit in `EHL`, 32-bit in `DEHL`.
    - No system call returns a value larger than 32 bits.
    - All stack parameters are cleaned up by the caller.

## Data Structures:

### Typedefs
```c
typedef signed char int8;
typedef unsigned char uint8;
typedef signed int int16;
typedef unsigned int uint16;
typedef signed long int32;
typedef unsigned long uint32;
```

### ButtonState:
```c
struct ButtonState
{
    uint8 pressed; // Bitmask of buttons currently pressed
    uint8 changed; // Bitmask of buttons changed since last read
};
```
Buttons are, from LSB to MSB: Left (0), Right, Up, Down, A, B, Start, Select (7)

### Point:
```c
struct Point
{
    uint8 x;
    uint8 y;
};
```

### Bitmap:
```c
struct Bitmap
{
    uint8 x; // Bitmap width in tiles (8 pixels)
    uint8 y; // Bitmap height in pixels
    uint8* data; // Pointer to pixel data
};
```

### Sprite:
```c
typedef Bitmap Sprite;
```
Sprites treat the `x` field as pixels, not tiles.

### Strings:
C-style NULL-terminated ASCII.

## System Calls

### System

- `0x00`: `void exit(void)`
    - Exits the program.

- `0x00`: `int get_version(void)`
    - Returns the current ROSS version.
    
- `0x02`: `void sleep(unsigned int ticks)`
    - Pauses execution for at least an amount of ticks.
    
- `0x03`: `unsigned long get_uptime(void)`
    - Returns then number of ticks the system has been running.
    
### Math and Conversion

- `0x10`: `int random(void)`
    - Returns a random 16-bit integer.
    
- `0x11`: `int mulbyte(unsigned char a, unsigned char b)`
    - 8-bit multiplication

- `0x12`: `int divsbyte(char a, char b)`
    - Signed 8-bit division
    
- `0x13`: `int divubyte(unsigned char a, unsigned char b)`
    
### User I/O

- `0x20`: `ButtonState read_buttons(void)`
    - Reads the current button state with debouncing.

- `0x21`: `void wait_for_buttons(char bitmask)`
    - Waits for any button set to 1 in the bitmask to be pressed.
    
- `0x21`: `void fb_clear(void)`
    - Clears the framebuffer.
    
- `0x22`: `void fb_flush(void)`
    - Copies the framebuffer to the LCD.
    
- `0x23`: `void draw_bitmap(Point point, Bitmap* bitmap)`
    - Draws a bitmap using XOR.
    - X coordinates and bitmap widths are in bytes (8 pixel) steps. For fine-grained X coordinates, use `draw_sprite`.
    
- `0x24`: `void draw_sprite(Point point, Sprite* sprite)`
    - Draws a sprite using XOR.
    - X coordinates and sprite widths are in pixels.
    - Much slower than draw_bitmap.
