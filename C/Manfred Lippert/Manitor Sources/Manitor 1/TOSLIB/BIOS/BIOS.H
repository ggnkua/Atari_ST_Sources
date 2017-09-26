/*----------------------------------------------------------------------------------------
	bios.h, part of TOS Linker for CodeWarrior

	Bios system calls for TOS
	
	21.10.1998 by Manfred Lippert
	based on mgx_dos.h from Andreas Kromke

	last change: 31.1.2000

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#ifndef __TOS_bios_h_
#define __TOS_bios_h_

#ifndef __PORTAB__
#include <portab.h>
#endif

#if !TARGET_TOS
	#error Bios-Lib used in Non-TOS Project
#endif
#if !MC68K
	#error Bios-Lib used in Non-68K Project
#endif

/* Device Identifiers  (BIOS) */

#define PRT		0
#define AUX		1
#define CON		2
#define MIDI	3
#define IKBD	4
#define RAWCON	5

typedef struct __md {
	struct __md		*m_link;
	void				*m_start;
	int32				m_length;
	struct baspag	*m_own;
} MD;

typedef struct {		/* used by Getmpb */
	MD *mp_mfl;
	MD *mp_mal;
	MD *mp_rover;
} MPB;

typedef struct {		/* used by Getbpb */
	int16 recsiz;
	int16 clsiz;
	int16 clsizb;
	int16 rdlen;
	int16 fsiz;
	int16 fatrec;
	int16 datrec;
	int16 numcl;
	int16 bflags;
} BPB;

extern C_CALL int32 CDECL	Bconin(int16 dev);
extern C_CALL void CDECL	Bconout(int16 dev, int16 c);
extern C_CALL int16 CDECL	Bconstat(int16 dev);
extern C_CALL int32 CDECL	Bcostat(int16 dev);
extern C_CALL int32 CDECL	Drvmap(void);
extern C_CALL BPB*  CDECL	Getbpb(int16 dev);
extern C_CALL void CDECL	Getmpb(MPB *ptr);
extern C_CALL int32 CDECL	Kbshift(int16 mode);
extern C_CALL int32 CDECL	Mediach(int16 dev);
extern C_CALL int32 CDECL	Rwabs(int16 rwflag, void *buf, int16 count, int16 recno, int16 dev, int32 lrecno);
extern C_CALL void CDECL	(*Setexc(int16 number, void (*exchdlr)() )) ();
extern C_CALL int32 CDECL	Tickcal(void);

#endif
