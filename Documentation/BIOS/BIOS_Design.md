# Ceres80 BIOS Design 0.1

## Data Structures

- Sprite Structure
```c
sprite_t {
    byte width, // Width in 8-pixel pages
    byte height, // Height in pixels
    byte* data // Pointer to pixel data
};
```
The most significant bit is the leftmost bit.

- Character Map Structure
Each character glyph is an 8x8 bitmap sprite.

The character map is a contiguous array of 93 sprites representing printable
ASCII characters from `'!'` to `'~'`, in order. This structure uses 744 bytes.


## Calling Convention

The Ceres80 BIOS uses the following calling convention:

- Call Number: A

Parameters:
- 8-bit: L, H, E, D, C, B
- 16-bit: HL, DE, BC
- 32-bit: HLDE

Return Values:
- 8-bit: A, L, E, D, C, B
- 16-bit: HL, DE, BC
- 32-bit: HLDE

All non-return registers except for `AF` are preserved by the function.

## Control

1. 0x00 - Exit
- Exits the program and returns to the shell. Functionally equivalent to RST $00.
- Parameters: None
- Returns: N/A

3. 0x01 - Get BIOS Version
- Gets the current BIOS version as three integers
- Parameters: None
- Returns:
    - A: Major Version
    - L: Minor Version
    - H: Patch Version

4. 0x02 - Get System Ticks
- Gets the number of milliseconds the system has been running
- Resets on program exit
- Parameters: None
- Returns:
    - HLDE: System Ticks

5. 0x03 - Sleep
- Halts the system for at least a number of milliseconds
- Parameters:
    - HL: Number of milliseconds to sleep
- Returns: None

6. 0x04 - Register Alarm Function
- Sets a function to call after at least a number of milliseconds
- Setting to a NULL pointer ($0000) clears the alarm function
- The alarm function is called in the interrupt service routine and with the
alternate register set. The function is responsible for exchanging registers,
enabling interrupts, and returning using `RETI`.
- Parameters:
    - HL: Address of function
    - E: Repeat
        - 0: Clear alarm after it is called
        - 1: Repeat alarm until it is changed
- Returns: None

## Video

1. 0x10 - Set Draw Mode
- Sets the bitwise operation used by drawing functions
- Parameters:
    - L: Mode
        - 0: OR
        - 1: XOR
        - 2: AND
        - 3: CLEAR
- Returns: None

2. 0x11 - Draw Pixel
- Draws a pixel to the framebuffer
- Parameters:
    - L: X
    - H: Y
- Returns:
    - A: Status
        - 0: Success
        - 1: Out of Bounds

3. 0x12 - Draw Line
- Draws a line to the framebuffer
- Parameters:
    - L: X1
    - H: Y1
    - E: X2
    - D: Y2
- Returns:
    - A: Status
        - 0: Success
        - 1: Out of Bounds

4. 0x13 - Draw Box
- Draws a box to the framebuffer
- Parameters:
    - L: X1
    - H: Y1
    - E: X2
    - D: Y2
- Returns:
    - A: Status
        - 0: Success
        - 1: Out of Bounds

5. 0x14 - Draw Filled Box
- Draws a filled box to the framebuffer
- Parameters:
    - L: X1
    - H: Y1
    - E: X2
    - D: Y2
- Returns:
    - A: Status
        - 0: Success
        - 1: Out of Bounds

5. 0x15 - Draw Sprite
- Draws a sprite to the framebuffer
- Sprites must be aligned to an 8-pixel page
- Parameters:
    - L: X Page
    - H: Y
    - DE: Pointer to bitmap object
- Returns
    - A: Status
        - 0: Success
        - 1: Out of Bounds

6. 0x16 - Draw Character
- Draws an ASCII character to the framebuffer
- Characters must be aligned to an 8-pixel page
- Parameters:
    - L: X Page
    - H: Y
    - E: Character
- Returns:
    - A: Status
        - 0: Success
        - 1: Out of Bounds

7. 0x17 - Draw Character String
- Draws a string of ASCII characters to the framebuffer
- Characters must be aligned to an 8-pixel page
- Parameters:
    - L: X Page
    - H: Y
    - DE: Pointer to a null-terminated string
- Returns:
    - A: Status
        - 0: Success
        - 1: Out of Bounds

8. 0x18 - Set Character Map
- Changes the ASCII character map used by the BIOS
- Set to NULL ($0000) to reset to default
- Parameters:
    - HL: Pointer to character map
- Returns: None

9. 0x19 - Clear Screen
- Clears the framebuffer
- Parameters: None
- Returns: None
        
10. 0x1A - Render
- Renders the contents of the framebuffer on the LCD display
- Parameters: None
- Returns: None

## Input

1. 0x20 - Get Button State
- Reads the buttons and returns a bitmask for the current state of the buttons
and which buttons have changed since the last read.
- The bitmask from bit 0 to bit 7 is:
    - Left (0), Right, Up, Down, A, B, Start, Select (7)
- Parameters: None
- Returns:
    - A: Current Button State
    - L: Changed Buttons

## Storage
        
6. 0x30 - Init SD Card
- Initializes the SD Card and selects the first compatible partition
- Parameters: None
- Returns:
    - A: Status
        - 0: Ready
        - 1: Already Initialized
        - 2: No Card
        - 3: Unknown Filesystem
        - 4: Unknown Error
    - HLDE: Total Sectors
    - BC: Root Directory Cluster

2. 0x31 - Read Sector
- Reads a sector/cluster from the disk using a Logical Block Address
- Partition offsets are handled by the BIOS
- Parameters:
    - HLDE: LBA
    - BC: Pointer to a 512-byte data buffer
- Returns:
    - A: Status
        - 0: Success
        - 1: No Disk/Uninitialized Disk
        - 2: Unknown Error

3. 0x32 - Write Sector
- Writes a sector/cluster to the disk using a Logical Block Address
- Partition offsets are handled by the BIOS
- Certain sectors (such as the BPB and Boot Sector) are software protected
- Parameters:
    - HLDE: LBA
    - BC: Pointer to a 512-byte data buffer
- Returns:
    - A: Status
        - 0: Success
        - 1: No Disk/Uninitialized Disk
        - 2: Unknown Error
        
## Math

1. 0x40 - Multiply 8-bit
- Multiplies two unsigned 8-bit integers into one 16-bit integer using a
bit-shift algorithm
- Parameters:
    - L: Multiplicand
    - H: Multiplier
- Returns:
    - HL: Product

2. 0x41 - Divide 8-bit
- Divides two unsigned 8-bit integers into two 8-bit integers using a bit-shift
algorithm
- Parameters:
    - L: Dividend
    - H: Divisor
- Returns:
    - A: Quotient
    - L: Remainder

## Conversion

1. 0x50 - ASCII to Integer
- Converts an ASCII string to a 16-bit integer
- Parameters:
    - HL: Pointer to a null-terminated string
- Returns:
    - A: Status
        - 0: Success, Unsigned Result
        - 1: Success, Signed Result
        - 2: Out of Bounds, Unsigned Result
        - 3: Out of Bounds, Signed Result
        - 4: Not A Number
    - HL: Converted Integer

2. 0x51 - Integer to ASCII
- Converts an unsigned 16-bit integer into a decimal ASCII string
- Parameters:
    - HL: Number to convert
    - DE: Pointer to a 6-byte character buffer
- Returns: None
    
3. 0x52 - Integer to Hex
- Converts an unsigned 16-bit integer into a hexadecimal ASCII string
- Parameters:
    - HL: Number to convert
    - DE: Pointer to a 5-byte character buffer
- Returns: None
