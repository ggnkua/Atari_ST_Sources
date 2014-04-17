/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/baspag88.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:07:18 $	$Locker: kbad $
* =======================================================================
*  $Log:	baspag88.h,v $
* Revision 2.2  89/04/26  18:07:18  mui
* aes30
* 
* Revision 2.1  89/02/22  05:18:10  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:26:26  lozben
* Initial revision
*
*************************************************************************
*/
/*	BASPAG88.H	1/28/84 - 12/15/84	Lee Jay Lorenzen	*/

						/* in BASE88.C		*/
EXTERN PD	*rlr, *drl, *nrl;
EXTERN EVB	*eul, *dlr, *zlr;

#if I8086
EXTERN UWORD	elinkoff;
#else
EXTERN LONG	elinkoff;
#endif

/*	EXTERN BYTE	dodisp;		*/
EXTERN BYTE	indisp;
EXTERN BYTE	infork;
EXTERN WORD	fpt, fph, fpcnt;		/* forkq tail, head, 	*/
						/*   count		*/
EXTERN SPB	wind_spb;
EXTERN CDA	*cda;
EXTERN WORD	curpid;
