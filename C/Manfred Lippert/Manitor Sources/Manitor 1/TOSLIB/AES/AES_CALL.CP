/*----------------------------------------------------------------------------------------
	aes_call.cp, part of TOS Linker for CodeWarrior

	Low level AES system calls for TOS
	CodeWarrior version
	
	27.10.1998 by Manfred Lippert
	based on MT_AES from Andreas Kromke

	last change: 17.11.1998

	Don't edit this file.

	If you have to make any changes on this file, please contact:
	mani@mani.de
----------------------------------------------------------------------------------------*/

#include <aes.h>

#ifndef __MWERKS__
	#error This Source (aescall.cp) is for Metrowerks CodeWarrior only
#endif

#define sizeof_AESPB 24

// PARMDATA:
#define APD_contrl		0	// int16 contrl[5];
#define APD_intin		10	// int16 intin[16];
#define APD_intout		42	// int16 intout[16];
#define APD_addrin		74	// void *addrin[16];
#define APD_addrout		138	// void *addrout[16];
#define sizeof_PARMDATA	202

asm void _mt_aes(__A0(PARMDATA *d), __A1(int16 *ctrldata), int16 *global)
{
	move.l	a2,-(sp)
	lea		-sizeof_AESPB(sp),sp		// space for AESPB
	movea.l	sp,a2
	move.l	a0,(a2)+					// set AESPB:contrl pointer to PARMDATA:contrl field

	move.l	(a1)+,(a0)+					// fill out PARMDATA:contrl[0/1]
	move.l	(a1)+,(a0)+					// fill out PARMDATA:contrl[2/3]
	clr.w	(a0)+						// fill out PARMDATA:contrl[4]
						
	move.l	sizeof_AESPB+8(sp),(a2)+	// set AESPB:global pointer to global
	move.l	a0,(a2)+					// set AESPB:intin pointer to PARMDATA:intin field
	lea		APD_intout-APD_intin(a0),a0	// intout field
	move.l	a0,(a2)+					// set AESPB:intout pointer to PARMDATA:intout field
	lea		APD_addrin-APD_intout(a0),a0
	move.l	a0,(a2)+					// etc...
	lea		APD_addrout-APD_addrin(a0),a0
	move.l	a0,(a2)+	

	move.w	#200,d0
	move.l	sp,d1
	trap	#2

	lea		sizeof_AESPB(sp),sp
	movea.l	(sp)+,a2
	rts
}
