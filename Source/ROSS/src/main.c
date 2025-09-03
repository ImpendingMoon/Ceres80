/**
 * @file main.c
 * @brief The main entrypoint for ROSS
 *
 * @license GPL-3.0-or-later
 */

#include "hardware.h"
#include "system.h"

int main(void)
{
	ctc_init();
	ei();

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
