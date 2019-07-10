/*
 * modem.h -- defines and stuff for dealing with the modem in Fnordadel
 *
 * 91Apr29 AA	Extracted from ctdl.h and elsewhere
 */

#ifndef _MODEM_H
#define _MODEM_H

/*
 * modem stuff:
 *
 * If you change the number of baud rates supported here, you need to
 * modify the mCCs strings in struct config, findBaud(), and grabCC()
 * in SYSDEP.C, and setBaud() in LIBDEP.C
 */
#define NUMBAUDS	5

#define ONLY_300	0	/* 300 baud only	*/
#define UPTO1200	1	/* +1200 baud		*/
#define UPTO2400	2	/* +2400 baud		*/
#define UPTO9600	3	/* +9600 baud		*/
#define UPTO19200	4	/* +19200 baud		*/

#endif
