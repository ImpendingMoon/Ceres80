/**
 * @file math.h
 * @brief Functions and variables relating to the Math set of System Calls
 *
 * @license GPL-3.0-or-later
 */

#ifndef ROSS_MATH_H
#define ROSS_MATH_H

void rand_init(void);

int random(void) __sdcccall(0);

#endif // ROSS_MATH_H
