/*
 * sozobon eXtended version headerfile for ATARI TOS bindings
 * you will need this file for os related programs (ACCs using malloc() or
 * Malloc(), TOS version dependant programs, etc.)
 *
 */

#ifndef _ATARI_H
#define _ATARI_H

/*
 * some useful OS related functions:
 * in extended.lib
 *
 */
#ifndef _BASEP_H
#include	<basepage.h>
#endif

extern BASEPAGE *Getbpact_pd();
extern unsigned int	GetTOSvers( long *OS_date, unsigned int *OS_conf,
									unsigned int *OS_dosdate);
extern int	Getcookie( long cookie, long *value );


#ifdef _OSBIND_H
#error "include osbind.h only after including atari.h"
#endif

#ifndef _ERRNO_H
#include	<errno.h>
#endif

	/* for a fast include define _SYSSTRUC in your source file, and the rest
	 *		is skipped.	
	 * Maybe we should use a NEED_SYSSTRUC define in the sorcecode, to
	 * switch on including the following stuff?
	 */
#ifndef _SYSSTRUC
#define	_SYSSTRUC

	/* gemdos	*/

#ifndef _OS_HEADER
#include	<osheader.h>
#endif

	/* constants and structs	*/

#include <file.h>
	/* something for MiNT	*/

#ifndef SEEK_SET
/* Fseek()  and lseek()  */
#define	SEEK_SET	0		/* from beginning of file */
#define	SEEK_CUR	1		/* from current location */
#define	SEEK_END	2		/* from end of file */
#endif

		/* Fopen() modes	*/
#define	FO_READ		0x00
#define	FO_RDONLY	0x00
#define	FO_WRITE	0x01
#define	FO_WRONLY	0x01
#define	FO_RANDW	0x02
#define	FO_RDWR		0x02
	/* add sharing modes for file-locking (cookie '_FLK')	*/
#define	FO_COMPAT	0x00
#define	FO_DENYRW	0x10	/* deny both, read and write	*/
#define	FO_DENYW	0x20
#define	FO_DENYR	0x30
#define	FO_DENYNONE	0x40
	/* lock-inherit flag	*/
#define	FO_INHERIT	0x80

		/* Fattrib() modes	*/
#define	FA_READ		0
#define	FA_WRITE	1

	/* file attributes	*/
#ifndef FA_NORMAL
		/* only Fcreate()/Fattrib()	*/
#define	FA_NORMAL	0x00
		/* Fcreate()/Fattrib()/Fsfirst()/Fsnext()	*/
#define FA_RDONLY	0x01
#define FA_HIDDEN	0x02
#define FA_SYSTEM	0x04
#define FA_LABEL	0x08
		/* only Fattrib()/Fsfirst/Fsnext:	*/
#define FA_DIREC	0x10
#define FA_DIR		0x10
#define FA_ARCH		0x20
#define FA_CHANGED	0x20
#endif
		/* combinations for Fsfirst()/Fsnext()	*/
#define FA_ATTRIB (FA_DIREC|FA_RDONLY|FA_HIDDEN|FA_SYSTEM)
#define FA_FILE (FA_ARCH|FA_RDONLY|FA_HIDDEN|FA_SYSTEM)
#define FA_OTHER (FA_LABEL|FA_DIREC)
/* 		usage of Fsfirst():
 * Fsfirst(path, FA_FILE|FA_OTHER)
 * 		and test dta->d_attrib:
 * if ( !(dta->d_attrib & FA_OTHER) )
 *			 it is an ordinary file	
 * else
 *			 label or directory	
 */
	/* struct used by Fsfirst()/Fsnext()/Fgetdta()/Fsetdta()	*/
typedef struct Dta {
	char	d_reserved[21];
	char	d_attrib;
	unsigned short	d_time;
	unsigned short	d_date;
	long	d_length;
	char	d_fname[14];
}	DTA;

		/* Flock() constants	*/
#define	FL_LOCK		0
#define	FL_UNLOCK	1

		/* Mxalloc() constants	*/
#define	MX_STONLY	0
#define	MX_ALTONLY	1
#define	MX_PREFST	2
#define	MX_PREFALT	3

	/* struct filled by Dfree()	*/
typedef struct Diskinfo {
	long	b_free;
	long	b_total;
	long	b_secsiz;
	long	b_clsiz;
} DISKINFO;

	/* Fdatime() constants	*/
#define	FD_READ		0
#define	FD_WRITE	1
	/* struct filled/used by Fdatime()	*/
typedef struct Dostime {
  unsigned short time;
  unsigned short date;
} DOSTIME;

	/* Pexec() modes	*/
#define	PE_LOADGO		0	/* load & go */
#define	PE_LOAD			3	/* just load */
#define	PE_GO			4	/* just go (env & TPA owned by parent) */
#define	PE_CBASEPAGE	5	/* just create basepage */
#define	PE_GO_FREE		6	/* just go, then free  */
#define	PE_CBASEP_PRGFLAGS	7	/* create basepage, respecting prgflags */


	/* bios	- for more structures, see bios.h	*/

	/* Device codes for Bconin(), Bconout(), Bcostat(), Bconstat() */
#define _PRT    0
#define _AUX    1
#define _CON    2
#define _MIDI   3
#define _IKBD   4
#define _RAWCON 5

	/* xbios	*/

typedef struct Keytab {
	char *unshift;
	char *shift;
	char *capslock;
} KEYTAB;

	/* if you wite OS related Programs you will need an osbind.h
		include:	
	 */

#include <osbind.h>

#endif	/* _SYSSTRUC	*/

#endif	/* _ATARI_H	*/
