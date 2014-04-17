/*	DISPVARS.H		4/22/91			D.Mui		*/

#ifndef _DISPVARS_H_
#define _DISPVARS_H_

					/* in GEMBASE.C			*/
EXTERN	PD	*rlr,*drl,*nrl;
EXTERN	PD	*slr;
EXTERN	PD	*plr;			/* system pd list		*/
EXTERN	PD	*clr;
EXTERN	PD	*currpd;

EXTERN	EVB	*eul, *tel, *zel;

EXTERN	WORD	fpt, fph, fpcnt;	/* forkq tail, head, count	*/
EXTERN	WORD	cpdid;			/* critical error process	*/
EXTERN	WORD	spdid;

#endif

