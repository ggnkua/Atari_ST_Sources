*	Trap14.s		02/28/85 - 05/21/85	Derek Mui	
*	combine trap14 trap13 with trp14 and trp13	3/4/86	D.Mui
*	Added save mouse form function	1/6/87	- 1/7/87Derek Mui
*	Take out s68	2/9/88				D.Mui
*	Rename maddr to _maddr		6/25/90		D.Mui
*	Use MAC to assemble		6/28/90		D.Mui
* 	assemble with MAS 900801 kbad (removed zeropage a0 from mediach)
*	Move trap to here		9/5/90		D.Mui
*	Rename to traps.s		9/5/90		D.Mui	
*	Fix at mediach at dooldr 	12/11/90	D.Mui
*	Fix at mediach at remove extra slash at the beginning 4/5/91 D.Mui
*	Add the new names (gemdos, bios, xbios) for trap functions
*	so that we cam get rid of osbind.o 3/10/93	Eric Smith
*	Removed gr_mouse declaration - its not used 3/19/93 C.Gee

	.globl	_trap
	.globl	_gemdos
	.globl	_DOS_AX
	.globl 	_trap14
	.globl	_xbios
	.globl 	_trap13
	.globl	_bios
*	.globl 	_gr_mouse
	.globl 	_getmouse
	.globl 	_putmouse
	.globl 	_LBCOPY
	.globl 	_maddr		; used by gembind:graf_mouse as a flag
	.globl	_kickit

	.text


_kickit:
	move.l	4(a7),d1
	move.w	#201,d0
	trap	#2
	rts


*****************************************
*	AES function to call GEMDOS	*
*****************************************
* For the three trap calls, we now save d2 and a2, since Lattice does
* not preserve them.
* DLF/CJG	3/2/93
*
* The safe way to do this is as follows:

_gemdos:
_trap:
	movem.l	d2/a2,-(sp)
	clr.w	_DOS_AX
	movem.l	12(sp),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(sp)
	trap	#1
	add.l	#24,sp
	move.w	d0,_DOS_AX
	movem.l	(sp)+,d2/a2
	rts


*********************************
*	Trap13 and Trap14 	*
*********************************

_bios:
_trap13:
	movem.l	d2/a2,-(sp)
	movem.l	12(sp),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(sp)
	trap	#13
	add.l	#24,sp
	movem.l	(sp)+,d2/a2
	rts

_xbios:
_trap14:
	movem.l	d2/a2,-(sp)
	movem.l	12(sp),d0-d2/a0-a2
	movem.l	d0-d2/a0-a2,-(sp)
	trap	#14
	add.l	#24,sp
	movem.l	(sp)+,d2/a2
	rts


*********************************
*	Get Mouse		*
*********************************

_getmouse:
	.dc.w	$A000
	suba.l	#$358,a0
	move.l	a0,_maddr		; save the mouse block address
	lea	mform,a1		; destination
	move.w	#36,d0			; size ( - 1 for dbra )
getmcp:
	move.w	(a0)+,(a1)+
	dbra	d0,getmcp
	rts

*********************************
*	Putmouse		*
*********************************

_putmouse:
	lea	mform,a0		; from our form
	move.l	_maddr,a1		; back to the line-a
	move.w	#36,d0			; size ( - 1 for dbra )
putmcp:
	move.w	(a0)+,(a1)+
	dbra	d0,putmcp
	clr.l	_maddr			; no longer in use...
	rts

	.bss
	.even

		.ds.l	1
_maddr:		.ds.l	1
mform:		.ds.w	37
trp13ret:	.ds.l	1
trp14ret:	.ds.l	1
retsav:		.ds.l	1

	.end
