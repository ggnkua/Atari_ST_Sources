/*
 * archiver.h -- structures for managing generalised ARC program handling
 *
 * 91Apr29 AA	Moved in former arc68k.h
 * 91Jan24 AA	Created.
 */

#ifndef _ARCHIVER_H
#define _ARCHIVER_H

#include "door.h"	/* for DOORSIZE */

struct archiver {
	char extension[4];
	char doorname[DOORSIZE];
	struct doorway *doorptr;
} ;

extern struct archiver *archTab;

#define ARCMAGIC	26
#define ARCVERSION	9
#define AFLEN		13

struct arcH {
    char  a_name[AFLEN];
    long  a_size;
    long  a_timestamp;
    short a_crc;
    long  a_length;
} ;

#endif
