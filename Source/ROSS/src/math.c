/**
 * @file math.c
 * @brief Functions and variables relating to the Math set of System Calls
 *
 * @license GPL-3.0-or-later
 */

#include "math.h"
#include "system.h"

unsigned int rng_state_1;
unsigned int rng_state_2;

void rand_init(void)
{
	do
	{
		rng_state_1 = system_uptime;
		rng_state_2 = system_uptime * 2;

		rng_state_1 ^= rng_state_2;
		rng_state_2 ^= rng_state_1;
	} while (rng_state_1 != 0  && rng_state_2 != 0);
}
