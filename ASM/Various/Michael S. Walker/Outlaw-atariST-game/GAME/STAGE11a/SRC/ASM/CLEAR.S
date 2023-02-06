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

  		xdef		_ClearScreen

base		equ		8

*	--------------- void ClearScreen(void *frame_buffer) ------
*	Whites out the given frame_buffer
*	------------------------------------------------

_ClearScreen:	link		a6,#0
		movem.l		d0-1/a0,-(sp)
		movea.l		base(a6),a0
		move.w		#7999,d0
		clr.l		d1
fill_loop:	move.l		d1,(a0)+        ; strangely, faster than clr
		dbra		d0,fill_loop
		movem.l		(sp)+,d0-1/a0
		unlk		a6
		rts
