/*
//
// Copyright (C) 2009, 2010, 2011 Jean-Francois DEL NERO
//
// This file is part of the HxCFloppyEmulator file selector.
//
// HxCFloppyEmulator file selector may be used and distributed without restriction
// provided that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// HxCFloppyEmulator file selector is free software; you can redistribute it
// and/or modify  it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// HxCFloppyEmulator file selector is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//   See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with HxCFloppyEmulator file selector; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mint/osbind.h>
#include <mint/sysvars.h>

#include <time.h>

#include "atari_hw.h"

static unsigned char floppydrive;
static unsigned char datacache[512*9];
static unsigned char valid_cache;

WORD fdcDmaMode = 0;

// extern
extern unsigned char fExit;


#define asm_nop(void) __asm("nop");


void su_fdcRegSet(WORD reg, WORD data)
{
	DMA->control = reg | fdcDmaMode;

	asm_nop();
	asm_nop();
	DMA->data    = data;
	asm_nop();
	asm_nop();
}
void su_fdcSendCommandWait(WORD command)
{
	long timeout = (*_hz_200) + 200*3;      /* 3-second timeout */
	MFP *mfp = MFP_BASE;
	su_fdcRegSet(0x80, command);

	while (!(                               /* wait until */
	        (0x20 != (mfp->gpip & 0x20))    /* next interrupt */
			|| ((*_hz_200) > timeout)       /* or timeout */
	));
}
WORD su_fdcRegGet(WORD reg)
{
	DMA->control = reg | fdcDmaMode;
	asm_nop();
	asm_nop();
	return DMA->data;
}

void su_fdcWait(void)
{
	long timeout = (*_hz_200) + 200*3;	/* 3-second timeout */
	DMA->control = 0x80 | fdcDmaMode;

	while (!(                                        /* wait until */
		    (FDC_BUSY != (DMA->data & FDC_BUSY))     /* no more busy */
		    || ((*_hz_200) > timeout)                /* or timeout */
    ));
}

void su_fdcSelectDriveASide0()
{
	UBYTE data;
	__asm("\tmove.w sr,-(a7)\n"
		  "\tor.w #0x700,sr\n"
		   :::"%sp"
		 );

	PSG->regdata = 14;      /* select register 14 */
	data = PSG->regdata;
	data = data & 0xf8;     /* clear bits */
	if (0 == floppydrive)
	{
		data = data | 5;        /* select drive A, side 0 */
	} else {
		data = data | 3;        /* select drive B, side 0 */
	}

	PSG->write = data;

	__asm("\tmove.w (a7)+,sr\n" ::: "%sp");

}




void su_fdcLock(void)
{
/*
Set floppy lock, so the system VBL won't interfere
inhibit MFP interrupt
set the bit 5 of fffa01 as input (0)
enable changing of bit 5 of fffa01 (gpip) to poll the interrupt bit of the WDC
see the steem source at
https://github.com/btuduri/Steem-Engine/blob/629d8b98df7245c8645b0ad41f90ed395d427531/steem/code/iow.cpp
*/

	__asm("\tst 0x43e.w\n");
	__asm("\tbclr #7,0xfffffa09.w\n");
	__asm("\tbclr #5, 0xfffffa05.w\n");

	su_fdcWait();
}
void su_fdcUnlock(void)
{
	su_fdcWait();

	__asm("\tsf 0x43e.w\n");
}


void su_headinit(void)
{
	su_fdcLock();
	su_fdcSelectDriveASide0();
	su_fdcRegSet(0x86, 255);        /* data : track number */
	su_fdcSendCommandWait(0x13);    /* SEEK, no verify, 3ms */
/*    su_fdcUnlock(); */
/*    Crawcin(); */
}






void su_jumptotrack0(void)
{
	su_fdcLock();
	su_fdcRegSet(0x86, 0);          /* data : track number */
	su_fdcSendCommandWait(0x13);    /* SEEK, no verify, 3ms */
	su_fdcUnlock();
}



void su_fdcDmaAdrSet(unsigned char *adr)
{
	DMA->addr_low  = ((unsigned long) adr) & 0xff;
	DMA->addr_med  = ((unsigned long) adr>>8) & 0xff;
	DMA->addr_high = ((unsigned long) adr>>16) & 0xff;
}
void su_fdcDmaReadMode(void)
{
	DMA->control = 0x90;
	DMA->control = 0x190;
	DMA->control = 0x90;
	fdcDmaMode = 0x0;
}
void su_fdcDmaWriteMode(void)
{
	DMA->control = 0x190;
	DMA->control = 0x90;
	DMA->control = 0x190;
	fdcDmaMode = 0x100;
}

void read9sectors(unsigned char *adr)
{
	void * old_ssp;
	WORD sectorNumber;

	old_ssp = (void *) Super(0L);

	su_fdcDmaReadMode();
	su_fdcDmaAdrSet(adr);
	su_fdcRegSet(0x90, 9);                   /* sector count : 9 sectors */

	for (sectorNumber = 0; sectorNumber<=8; sectorNumber++)
	{
		su_fdcRegSet(0x84, sectorNumber);
		su_fdcSendCommandWait(0x88);         /* READ SECTOR, no spinup */
	}

	Super(old_ssp);
}

void write1sector(WORD sectorNumber, unsigned char *adr)
{
	void *old_ssp;

	old_ssp = (void *) Super(0L);

	su_fdcDmaWriteMode();
	su_fdcDmaAdrSet(adr);
	su_fdcRegSet(0x90, 1);              /* sector count : 1 sector */

	su_fdcRegSet(0x84, sectorNumber);
	su_fdcSendCommandWait(0xa8);        /* WRITE SECTOR, no spinup */

	Super(old_ssp);
}

unsigned char writesector(unsigned char sectornum,unsigned char * data)
{
	valid_cache=0;

	write1sector(sectornum, data);

	return 1;
}

unsigned char readsector(unsigned char sectornum,unsigned char * data,unsigned char invalidate_cache)
{
	if(!valid_cache || invalidate_cache)
	{
		read9sectors(datacache);
		valid_cache=0xFF;
	}

	memcpy((void*)data,&datacache[sectornum*512],512);
	return 1;

}

void su_toggleConterm()
{
	#define CONTERM *((unsigned char *) 0x484)

	static unsigned char oldconterm = 0xff;
	if (0xff == oldconterm) {
		oldconterm = CONTERM;
		CONTERM &= 0xFA;                /* disable key sound and bell */
		CONTERM |= 8;					/* enable keyboard function to return shift/alt/ctrl status */
	} else {
		CONTERM = oldconterm;
	}
}

void restore_atari_hw(void)
{
	my_Supexec((LONG *) su_jumptotrack0);
	my_Supexec((LONG *) su_toggleConterm);
}

void init_atari_hw(void)
{
	my_Supexec((LONG *) su_toggleConterm);
}

void init_atari_fdc(unsigned char drive)
{
	valid_cache=0;
	floppydrive=drive;
	my_Supexec((LONG *) su_headinit);
}

#if(0)
unsigned char Keyboard()
{
	return 0;
}
#endif

#if(0)
int kbhit()
{
	return 0;
}
#endif

#if(0)
void flush_char()
{
}
#endif

unsigned long get_char()
{
	unsigned long key;

	key = Crawcin();
	if ( ((unsigned short) (key>>16)) == 0x83e) { /* Alt F4 */
		fExit=1;
	}

	return key;
}


unsigned long su_get_hz200()
{
	return *_hz_200;
}
unsigned long get_hz200()
{
	return	(unsigned long) my_Supexec((LONG *) su_get_hz200);
}

void su_reboot()
{
	__asm("\tmove.l 4.w,a0");
	__asm("\tjmp (a0)");
}


#if(0)
unsigned long read_long_odd(unsigned char * adr)
{
	unsigned long ret = 0;
	ret |= ((unsigned long) *(adr)<<24);
	ret |= ((unsigned long) *(adr+1)<<16);
	ret |= ((unsigned long) *(adr+2)<<8);
	ret |= ((unsigned long) *(adr+3));
	return ret;
}
#endif
unsigned long read_long_lsb(unsigned char * adr)
{
	unsigned long ret = 0;
	ret |= ((unsigned long) *(adr++));
	ret |= ((unsigned long) *(adr++)<<8);
	ret |= ((unsigned long) *(adr++)<<16);
	ret |= ((unsigned long) *(adr)<<24);
	return ret;
}
#if(0)
void write_long_odd(unsigned char * adr, unsigned long value)
{
	*(adr)   = (value >> 24) & 0xff;
	*(adr+1) = (value >> 16) & 0xff;
	*(adr+2) = (value >>  8) & 0xff;
	*(adr+3) = (value      ) & 0xff;
}
#endif
