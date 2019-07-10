/*
 * dateread.h: defines for reading from dates.
 * 
 * 91Jan08 AA	Hacked to use time_t's, also to allow BEFORE *and* AFTER
 */

#ifndef _DATEREAD_H
#define _DATEREAD_H

#define	dEVERY	0x00		/* read every message */
#define	dBEFORE	0x01		/* read messages before a date */
#define	dAFTER	0x02		/* read messages after a date */

#endif
