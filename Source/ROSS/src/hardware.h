/**
 * @file hardware.h
 * @brief Hardware definitions, special function registers, and functions
 *
 * @license BSD-3-Clause
 */

#ifndef ROSS_HARDWARE_H
#define ROSS_HARDWARE_H

#define ROM_START 0x0000
#define ROM_END 0x7FFF

#define PROGRAM_RAM_START 0x8000
#define PROGRAM_RAM_END 0xF7FF

#define STACK_START 0xF800
#define STACK_END 0xF97F

#define OS_RAM_START 0xF980
#define OS_RAM_END 0xF9FF

#define IO_BUFFER_START 0xFA00
#define IO_BUFFER_END 0xFBFF

#define FB_START 0xFC00
#define FB_END 0xFFFF

volatile __sfr __at(0x00) ctc_channel_0;
volatile __sfr __at(0x01) ctc_channel_1;
volatile __sfr __at(0x02) ctc_channel_2;
volatile __sfr __at(0x03) ctc_channel_3;

volatile __sfr __at(0x04) pio_channel_a_data;
volatile __sfr __at(0x05) pio_channel_b_data;
volatile __sfr __at(0x06) pio_channel_a_command;
volatile __sfr __at(0x07) pio_channel_b_command;

volatile __sfr __at(0x08) lcd_left_control;
volatile __sfr __at(0x09) lcd_left_data;
volatile __sfr __at(0x0A) lcd_right_control;
volatile __sfr __at(0x0B) lcd_right_data;

static inline void ei(void)
{
	__asm__(
		"\tei"
	);
}

static inline void di(void)
{
	__asm__(
		"\tdi"
	);
}

static inline void halt(void)
{
	__asm__(
		"\thalt"
	);
}

#endif //ROSS_HARDWARE_H