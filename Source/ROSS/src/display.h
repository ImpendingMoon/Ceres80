/**
 * @file display.h
 * @brief Functions and variables relating to the Display set of System Calls
 * Internal header, not for application use
 * @license GPL-3.0-or-later
 */

#ifndef ROSS_DISPLAY_H
#define ROSS_DISPLAY_H

void lcd_init(void);

void fb_clear(void) __sdcccall(0);

void fb_flush(void) __sdcccall(0);

#endif // ROSS_DISPLAY_H
