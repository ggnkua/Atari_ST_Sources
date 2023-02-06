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

	xdef	_GetBuffer
	xdef	_SetBuffer

VDL_VBM   equ	$FFFF8203	; Video base address
VDL_VBH   equ	$FFFF8201
VDL_VBL   equ	$FFFF820D                     
VCOUNT_HI equ	$FFFF8205	; Video display counter
VCOUNT_MI equ	$FFFF8207
VCOUNT_LO equ	$FFFF8209      

* test driver

test:
	clr.l	-(sp)		; Super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_ssp

	jsr	_GetBuffer
	move.l	d0,-(sp)
	jsr	_SetBuffer

	move.l	old_ssp,-(sp)	; User
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	nop
old_ssp:	ds.l      1

*   -------------------------- (UINT32*) GetBuffer(void) -----
*   Note: It is assumed that this will be called with MySuper(0).
*	  
*	===========#==#=======#==============#
*	$FFFF8201.B|RW|VDL_VBH|Video Base Hi|  %xxxxxxx_ | STE,F
*	$FFFF8203.B|RW|VDL_VBM|Video Base Mi|  %xxxxxxx_ | STE,F
*	===========#==#=======#==============#
*	$FFFF820D.B|RW|VDL_VBL|Video Base Lo # %xxxxxxx_ | STE,F 
*	===========#==#=======#==============#

_GetBuffer:
	move.l	d1,-(sp)

	clr.l	d0		; clear register for high and mid byte
	clr.l	d1		; clear register for low byte

	move.b	(VDL_VBH),d0	; move the byte at $FFFF8201.B into palce	
	move.b	(VDL_VBM),d1	; move the byte at $FFFF8203.B into place

	lsl.l	#8,d0		; return (UINT8 *)((*VIDEO_BASE_ADDR_HIGH << 16) |
	lsl.l	#8,d0		; (*VIDEO_BASE_ADDR_MED << 8); 
	lsl.l	#8,d1
	or.l	d1,d0
	move.l	(sp)+,d1

	rts
	nop
	
*	-----------------(VOID) SetBuffer(UINT32*) -----
*	===========#==#=======#==============#
*	$FFFF8201.B|RW|VDL_VBH|Video Base Hi|	%xxxxxxx_ | STE,F
*	$FFFF8203.B|RW|VDL_VBM|Video Base Mi|	%xxxxxxx_ | STE,F
*	===========#==#=======#==============#
*	$FFFF820D.B|RW|VDL_VBL|Video Base Lo #	%xxxxxxx_ | STE,F 
*	===========#==#=======#==============#
*	------------------------------------------------------

_SetBuffer:
SCRBUF	equ 8
	link	a6,#0
	move.l	d0,-(sp)
	move.l	SCRBUF(a6),d0

	lsr.l	#8,d0		; (*scrbuf >> 8) & 0xFF
	move.b	d0,(VDL_VBM)	; *VIDEO_BASE_ADDR_MID  

	lsr.l	#8,d0		; (*scrbuf >> 16) & 0xFF
	move.b	d0,(VDL_VBH)	; *VIDEO_BASE_ADDR_HIGH  
	move.l	(sp)+,d0

	unlk	a6
	rts
