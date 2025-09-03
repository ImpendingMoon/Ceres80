/**
 * @file system.h
 * @brief Functions and variables relating to the System set of System Calls
 * Internal header, not for application use
 * @license BSD-3-Clause
 */

#ifndef ROSS_SYSTEM_H
#define ROSS_SYSTEM_H

extern const int ross_version;
extern unsigned long uptime;

void ctc_init(void);

void exit(void) __naked;

int get_version(void) __sdcccall(0);

void sleep(unsigned int ticks) __sdcccall(0);

unsigned long get_uptime(void) __sdcccall(0);

#endif //ROSS_SYSTEM_H
