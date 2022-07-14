/*
 * tosdelay.h - header for tosdelay.c
 * based on delay.h from EmuTOS
 *
 * Copyright (C) 2013 The EmuTOS development team
 *
 * Authors:
 *  RFB    Roger Burrows
 *  LVL    Laurent Vogel
 *
 * Modified by Claude Labelle to include delay_loop() found
 * in asm.h from EmuTOS.
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */

#ifndef tosdelay_h
#define tosdelay_h

//#include "portab.h"

/*
 * this is the value to pass to the inline function delay_loop()
 * to get a delay of 1 millisecond.  other delays may be obtained
 * by multiplying or dividing as appropriate.  when calculating
 * shorter delays, rounding up is not necessary: because of the
 * instructions used in the loop (see below), the number of loops
 * executed is one more than this count (iff count >= 0).
 */
extern ulong loopcount_1_msec;

extern ulong delay_1usec;

/*
 * function prototypes
 */
static inline void set_tos_delay(void);
static inline void init_delay(void);
static inline void calibrate_delay(void);
static inline int getmCPU(void);

/*
 * Loops for the specified count; for a 1 millisecond delay on the
 * current system, use the value in the global 'loopcount_1_msec'.
 */

#define delay_loop(count)                                      \
	__extension__                                          \
	({                                                     \
		ulong _count = (count);                        \
		__asm__ volatile                               \
		(                                              \
			"0:\n\t"                               \
			"subq.l #1,%0\n\t"                     \
			"jpl    0b"                            \
			: "=d"(_count)      /* outputs */      \
			: "0"(_count)       /* inputs  */      \
			: "cc", "memory"    /* clobbered */    \
		);                                             \
	})

#endif /* tosdelay_h */
