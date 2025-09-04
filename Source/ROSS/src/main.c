/**
 * @file main.c
 * @brief The main entrypoint for ROSS
 *
 * @license GPL-3.0-or-later
 */

#include <string.h>


#include "display.h"
#include "hardware.h"
#include "system.h"

int main(void)
{
	// ctc_init();
	// ei();

	lcd_init();

	volatile uint8* fb = (uint8*) FB_START;

	__critical {
		memset((uint8*)fb, 0xAA, 1024);
	}

	fb_flush();

	return 0;
}



void isr(void) __naked
{
	__asm__(
		"\texx \n"
		"\tex af, af'"
	);

	++system_uptime;

	__asm__(
		"\texx \n"
		"\tex af, af'\n"
		"\tei\n"
		"\treti"
	);
}
