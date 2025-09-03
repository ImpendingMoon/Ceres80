/**
 * @file system.c
 * @brief Functions and variables relating to the System set of System Calls
 *
 * @license BSD-3-Clause
 */

#include "system.h"
#include <stdint.h>
#include "hardware.h"

const int ross_version = 0;
unsigned long uptime = 0;

void ctc_init(void)
{
	// Enable interrupts, prescaler = 256, time constant follows
	const uint8_t setup_command = 0b10100111;
	const uint8_t time_constant = 239;

	ctc_channel_0 = setup_command;
	ctc_channel_0 = time_constant;
}



void exit(void) __naked
{
	__asm__(
		"\trst 0x00"
	);
}



int get_version(void) __sdcccall(0)
{
	return ross_version;
}



void sleep(unsigned int ticks) __sdcccall(0)
{
	do
	{
		halt();
		ticks--;
	} while(ticks != 0);
}



unsigned long get_uptime(void) __sdcccall(0)
{
	return uptime;
}