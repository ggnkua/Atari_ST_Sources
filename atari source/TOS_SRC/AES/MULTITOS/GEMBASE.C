/*	GEMBASE.C				9/25/92	D.Mui		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"

GLOBAL	PD	*rlr;		/* processes ready to run list		*/
GLOBAL	PD	*drl;		/* processes' event is satisfied and 	*/
				/* ready to run list			*/
GLOBAL	PD	*nrl;		/* processes waiting for event list	*/
GLOBAL	PD	*slr;		/* process waiting for screen list	*/
GLOBAL	PD	*plr;		/* all the processes list		*/
GLOBAL	PD	*clr;		/* critical processes pending list	*/

GLOBAL	PD	*alr;		/* start up processes list		*/
GLOBAL	PD	*tlr;		/* terminate process list		*/


GLOBAL	PD	*currpd;	/* current running pd		*/

GLOBAL	EVB	*eul;		/* empty event block list	*/
GLOBAL	EVB	*tel;		/* timer event block list	*/
GLOBAL	EVB	*zel;		/* zombie event block list	*/

GLOBAL	WORD	spdid;		/* current wind update screen owner id	*/
GLOBAL	WORD	cpdid;		/* critical process 		*/
GLOBAL	WORD	fpt,fph,fpcnt;	/* forkq tail, head, 	*/
				/*   count		*/

