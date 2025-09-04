/**
 * @file display.c
 * @brief Functions and variables relating to the Display set of System Calls
 *
 * @license GPL-3.0-or-later
 */

#define FB_WIDTH_PX 128
#define FB_HEIGHT_PX 64
#define FB_WIDTH_TILES 16
#define FB_HEIGHT_TILES 8
#define PX_PER_TILE 8

#define LCD_CMD_SET_X 0b10111000
#define LCD_CMD_SET_Y 0b01000000
#define LCD_CMD_SET_Z 0b11000000
#define LCD_CMD_ON 0b00111111

#include "display.h"
#include "hardware.h"
#include "typedefs.h"
#include <string.h>
#include <stdbool.h>

volatile uint8* framebuffer = (uint8*) FB_START;

void lcd_wait(void)
{
	do
	{
		// Busy wait to not overwhelm the LCD
		for(volatile char i = 0; i < 10; i++);
	} while(
		// Check BSY and RST bits of both controllers
		(lcd_left_control & 0b1001000) != 0
		&& (lcd_right_control & 0b1001000) != 0
	);
}



void lcd_init(void)
{
	lcd_wait();
	lcd_left_control = LCD_CMD_SET_X;
	lcd_right_control = LCD_CMD_SET_X;

	lcd_wait();
	lcd_left_control = LCD_CMD_SET_Y;
	lcd_right_control = LCD_CMD_SET_Y;

	lcd_wait();
	lcd_left_control = LCD_CMD_SET_Z;
	lcd_right_control = LCD_CMD_SET_Z;

	lcd_wait();
	lcd_left_control = LCD_CMD_ON;
	lcd_right_control = LCD_CMD_ON;
}



void fb_clear(void) __sdcccall(0)
{
	__critical {
		memset((uint8*)framebuffer, 0, 1024);
	}
}



void rotate_out_tile(const uint8* tile, const bool to_left)
{
	// A bitwise transposition is larger and slower than this loop,
	// since the Z80 can't rotate multiple bits at a time
	for (uint8 col = 0; col < PX_PER_TILE; col++)
	{
		uint8 out_col = 0;

		for (uint8 row = 0; row < PX_PER_TILE; row++)
		{
			const uint8 row_msb = *tile << row & 0b10000000;
			out_col = (out_col >> 1) | row_msb;
			tile += FB_WIDTH_TILES;
		}

		if (to_left)
		{
			lcd_left_data = out_col;
		}
		else
		{
			lcd_right_data = out_col;
		}
	}
}



void fb_flush(void) __sdcccall(0)
{
	// This LCD controller tends to clobber registers on data writes
	// Manually reset registers, don't assume they will be where they should
	// as documented in the datasheet
	lcd_wait();
	lcd_left_control = LCD_CMD_SET_Z;
	lcd_right_control = LCD_CMD_SET_Z;

	// Use running pointer instead of recalculating index
	uint8* current_tile = (uint8*)framebuffer;

	// Loop leaves current_tile at the start of the second row in the tile,
	// add width * 7 to skip to the first row of the next tile
	uint8 stride = FB_WIDTH_TILES * 7;

	// This is a large enough critical period that the timer is likely going
	// to miss a tick. Unfortunately unless we want to talk to the LCD directly
	// when drawing (which is very slow for a common task), this is necessary
	// work.
	__critical {
		for (uint8 row = 0; row < FB_HEIGHT_TILES; row++)
		{
			lcd_wait();
			lcd_left_control = LCD_CMD_SET_X | row;
			lcd_right_control = LCD_CMD_SET_X | row;

			// Send left half of the row to left half of the LCD
			lcd_wait();
			lcd_left_control = LCD_CMD_SET_Y;
			lcd_wait();
			for (uint8 col = 0; col < FB_WIDTH_TILES / 2; col++)
			{
				rotate_out_tile(current_tile, true);
				current_tile++;
			}

			// Send right half of the row to right half of the LCD
			lcd_right_control = LCD_CMD_SET_Y;
			lcd_wait();
			for (uint8 col = 0; col < FB_WIDTH_TILES / 2; col++)
			{
				rotate_out_tile(current_tile, false);
				current_tile++;
			}

			current_tile += stride;
		}
	}
}
