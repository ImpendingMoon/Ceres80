# Ceres80 Rom Operating SyStem (ROSS) API Planning

## Notes

### Timing & Scheduling
- **System Tick**: The system timer operates at 100 Hz, resulting in a tick period of 10 milliseconds. This tick is used in all time-based operations.

### Coroutines and Timers
- **Coroutine Support**: ROSS supports up to four concurrent coroutines.
- **Timer Support**: ROSS supports up to two concurrent timers.
- **Entry Point**: The initial program entry point is automatically registered within coroutine slot 0.
- **Coroutine Restrictions**: ROSS does not support chained yielding (i.e., Coroutine A yields to B, which yields back to A). This limitation is due to only one return value being stored per coroutine slot.
- **Timer Context**: Timers continue counting and may trigger during execution of coroutines.
- **Timer Exit Convention**: Timer callbacks execute inside of the interrupt service routine context, and should exit using the `EI` and `RETI` instructions.

### Resource Restrictions
- **IY Register**: The IY register is reserved for use by the operating system and should not be accessed by application code.
- **Peripheral Devices**: Peripheral devices should only be accessed through the relevant system calls.

### Storage
- **Filesystem**: ROSS uses a USTAR filesystem written as the only partition on the SD Card
- **Filesystem Limitations**: ROSS impliments a limited, read-only USTAR driver. This driver does not support directory structures, symbolic links, or hard links.

## Data Structs

Sprites:
```
sprite_t {
    char width,  // Width of the sprite in 8-pixel pages
    char height, // Height of the sprite in pixels
    char* pixels // Pointer to pixel data, 1bpp
}
```

Strings: C-style null-terminated ASCII

## Errors:

- 0: Success
- 1: General Failure
- 2: Out of Bounds
- 3: Already Exists
- 4: Does not Exist

## Calling Convention:

- System calls are made by calling address `$0008`, such as with `RST 08h`
- The call number is placed in A.
- Parameters use registers in order left-to-right as defined. If part of a larger register is used, it is skipped.
- Stack parameters are pushed by the caller in order left-to-right as defined.
- All registers except AF are preserved by the callee.

- Return Registers:
    - 8-bit: A
    - 16-bit: DE
    - 32-bit: HLDE
- Parameter Registers:
    - 8-bit: L->H->D->E->C->B->Stack
    - 16-bit: HL->DE->BC->Stack
    - 32-bit: HLDE->Stack

## Control:

`$00` void exit()
    - Exits the program.

`$01` int get_firmware_version()
    - Returns the firmware version.

`$02` void sleep(int ticks)
    - Pauses execution for an amount of ticks

`$03` long get_uptime()
    - Gets the amount of ticks the system has been running

`$04` error_t register_timer(byte slot, void* func, int interval)
    - Registers a timer that will run after an amount of ticks

`$05` error_t pause_timer(byte slot)
    - Pauses the registered timer

`$06` error_t remove_timer(byte slot)
    - Removes the registered timer

`$07` error_t register_coroutine(byte slot, void* func, void* stack_pointer)
    - Registers a coroutine

`$08` error_t remove_coroutine(byte slot)
    - Removes the registered coroutine

`$09` error_t yield(byte slot)
    - Yields execution to a registered coroutine

`$0A` error_t resume()
    - Returns execution to the previous context

`$0B` byte current_routine()
    - Returns the current coroutine slot

## Math:
`$10` int mul8(byte a, byte b)
    - Multiplies two unsigned integers

`$11` (byte, byte) div8(byte a, byte b)
    - Divides two unsigned integers
    - Returns quotient and remainder

`$12` long mul16(int a, int b)
    - Multiplies two unsigned 16-bit integers

`$13` (int, int) div16(int a, int b)
    - Divides two unsigned 16-bit integers
    - Returns quotient and remainder

`$14` int rand()
    - Returns a random 16-bit integer

`$15` error_t atoi(char* str)
    - ASCII to 16-bit integer

`$16` error_t itoa(int a, char* str)
    - 16-bit integer to ASCII

`$17` error_t htoa(char* str)
    - Hexadecimal ASCII to 16-bit integer

`$18` error_t atoh(int a, char* str)
    - 16-bit integer to Hexadecimal ASCII

## Storage

`$20` error_t sd_init()
    - Initializes the SD Card

`$21` error_t sd_read_sector(long address, void* buf)
    - Reads a 512 byte sector from the SD Card

`$22` error_t sd_write_sector(long address, void* buf)
    - Writes a 512 byte sector to the SD Card

## Filesystem

`$23` error_t fs_list_start_sectors(long* buf, byte limit, byte offset)
    - Returns an array of file start sectors, max 128 entries/512 bytes.

`$24` error_t fs_get_file_struct(long sector, void* buf)
    - Loads a file's 512-byte USTAR header

`$25` error_t fs_get_filename(long sector, void* buf)
    - Loads a file's filename, up to 100 characters

`$26` error_t fs_load_file_clusters(long sector, void* buf)
    - Loads a number of file clusters into memory 

## Display

`$30` error_t draw_sprite(byte x, byte y, sprite_t* sprite)
    - Draws a bitmap sprite using XOR

`$31` error_t draw_char(byte x, byte y, char c)
    - Draws a character

`$32` error_t draw_string(byte x, byte y, char* str)
    - Draws a string of characters

`$33` void draw_clear()
    - Clears the screen

`$34` void flush_lcd()
    - Copies the framebuffer to the LCD

## Input

`$35` (byte, byte) read_buttons()
    - Reads the current button state with debouncing
    - First byte is buttons down bitmask, second byte is buttons changed
