/****************************************************************************\
|*		CLIP.C																*|
|*--------------------------------------------------------------------------*|
|*	by Russ Wetmore															*|
|*		Last revision:	11/04/86 15:03:12									*|
\****************************************************************************/

/* Uncomment the proper line for your flavour of C */
#define MEGAMAX 1
/* #define ALCYON 1 */

/*------------------------------*\
|*	includes					*|
\*------------------------------*/
#include "osbind.h"
#include "clip.h"

/*------------------------------*\
|*	locals						*|
\*------------------------------*/
GLOBAL	LONG	clp__Tmp;


/*------------------------------*\
|*	clipboard					*|	TRAP #10 funnel
\*------------------------------*/
	LOCAL
	VOID
xyzzy()
{
#ifdef MEGAMAX
	asm {
	clipboard:
		move.L	(A7)+,clp__Tmp(A4)		; Save off return address
		trap	#10
		move.L	clp__Tmp(A4),-(A7)		; (D0 should hold result, if any
		rts
	}
#endif
#ifdef ALCYON
	asm(".globl _clipboar");			/* (Alcyon idents only 8 chars)		*/
	asm("_clipboar:");
	asm("move.L (SP)+,_clp__Tmp");		/* This is safest way to do this	*/
	asm("trap #10");					/* In case you include labels at	*/
	asm("move.L _clp__Tmp,-(SP)");		/* link time for debugging purposes	*/
	asm("rts");
#endif
}


/*------------------------------*\
|*	trapStatus					*|	Fetch magic number (in supervisor mode)
\*------------------------------*/
	LOCAL
	VOID
trapStatus()
{
#ifdef MEGAMAX
	asm {
		suba.L	A0,A0					; Zero out A0
		movea.L	0xA8(A0),A0				; Fetch vector to trap dispatcher
		move.L	2(A0),clp__Tmp(A4)		; Fetch magic number from routine
	}
#endif
#ifdef ALCYON
	asm("suba.L A0,A0");
	asm("movea.L $A8(A0),A0");
	asm("move.L 2(A0),_clp__Tmp");
#endif
}

/*------------------------------*\
|*	InfoClip					*|	Special intervention for this call
\*------------------------------*/
	GLOBAL
	WORD
InfoClip(info)
	clipInfo *info;
{
	Supexec(trapStatus);				/* Fetch vector & get magic number	*/
	if ( clp__Tmp != 0xFDB97531 )		/* If it's not what we're expecting	*/
		return ( 0 );					/* ...blow it off and inform bozo	*/

	(VOID)clipboard(0, info);			/* Go ahead and make the call		*/
	return ( -1 );						/* Show success						*/
}
