# Ceres80 Memory Map

## Memory
`$0000`-`$7FFF`: Firmware ROM
`$8000`-`$F7FF`: Program RAM
`$F800`-`$F97F`: Initial Stack
`$F980`-`$F9FF`: Firmware memory
`$FA00`-`$FBFF`: I/O Buffer
`$FC00`-`$FFFF`: Framebuffer

## Ports

### CTC
`$00`: Channel 0
`$01`: Channel 1*
`$02`: Channel 2*
`$03`: Channel 3*

### PIO
`$04`: Channel A Data
	- Buttons
`$05`: Channel B Data
	- SD Card
`$06`: Channel A Control*
`$07`: Channel B Control

### LCD
`$08`: Left Side Control
`$09`: Left Side Data
`$0A`: Right Side Control
`$0B`: Right Size Data

*Do not use
