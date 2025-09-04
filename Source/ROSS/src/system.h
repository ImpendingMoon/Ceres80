/**
 * @file system.h
 * @brief Functions and variables relating to the System set of System Calls
 * Internal header, not for application use
 * @license GPL-3.0-or-later
 */

#ifndef ROSS_SYSTEM_H
#define ROSS_SYSTEM_H

#include "typedefs.h"

extern const int16 ross_version;
extern uint32 system_uptime;

void ctc_init(void);

void exit(void) __naked;

int get_version(void) __sdcccall(0);

void sleep(unsigned int ticks) __sdcccall(0);

unsigned long get_uptime(void) __sdcccall(0);

#endif //ROSS_SYSTEM_H
