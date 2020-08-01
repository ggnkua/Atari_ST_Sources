/* @(#) bios.h, XdLibs, include files
 * 
 * some rarely used structures from BIOS
 * 
 */

#ifndef _BIOS_H
#define _BIOS_H

typedef struct	Bpb {
	unsigned short	recsiz;
	unsigned short	clsiz;
	unsigned short	clsizb;
	unsigned short	rdlen;
	unsigned short	fsiz;
	unsigned short	fatrec;
	unsigned short	datrec;
	unsigned short	numcl;
	unsigned short	bflags;
} BPB;

	/* xbios	*/
typedef struct Iorec {
	long ibuf;
	short ibufsiz;
	short ibufhd;
	short ibuftl;
	short ibuflow;
	short ibufhi;
} IOREC;


typedef struct Kbdvecs {
	void (*midivec)();
	void (*vkbderr)();
	void (*vmiderr)();
	void (*statvec)();
	void (*mousevec)();
	void (*clockvec)();
	void (*joyvec)();
	void (*midisys)();
	void (*ikbdsys)();
	short drvstat;
}	KBDVECS;


#endif /* _BIOS_H */
