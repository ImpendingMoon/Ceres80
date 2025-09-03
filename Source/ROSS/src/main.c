/**
 * @file main.c
 * @brief The main entrypoint for ROSS
 *
 * @license BSD-3-Clause
 */

#include "hardware.h"
#include "system.h"

volatile unsigned long system_uptime = 0;



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
