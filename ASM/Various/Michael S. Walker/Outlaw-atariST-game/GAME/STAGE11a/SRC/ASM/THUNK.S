*  Michael S. Walker <mwalk762@mtroyal.ca>
* 	    _    _
*        | |  | |	OUTLAW. 
*       -| |  | |- 
*   _    | |- | |
* -| |   | |  | |- 	
*  |.|  -| ||/  |
*  | |-  |  ___/ 
* -|.|   | | |
*  |  \_|| |
*   \____  |
*    |   | |- 
*        | |
*       -| |
*        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.

	xdef	_Vbl
	xdef	_Ikbd
	xref	_do_VBL_ISR
	xref	_do_IKBD_ISR

*
*   -------------------  void Vbl(void) -----
*	VBL Wrapper
*   ----------------------------------------------------- 

_Vbl:
	movem.l	d0-d2/a0-a2,-(sp)
	jsr	_do_VBL_ISR
	movem.l	(sp)+,d0-d2/a0-a2
	rte

*   -------------------  void Ikbd(void) -----
*	IKBD Wrapper
*   ----------------------------------------------------- 

_Ikbd:
	movem.l	d0-d2/a0-a2,-(sp)
	jsr	_do_IKBD_ISR
	movem.l	(sp)+,d0-d2/a0-a2
	rte
