**********************************  alone.s  **********************************
*
* $Revision: 3.0 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/alone.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/03 15:04:53 $     $Locker:  $
* =============================================================================
*
* $Log:	alone.s,v $
* Revision 3.0  91/01/03  15:04:53  lozben
* New generation VDI
* 
* Revision 2.2  90/02/16  12:20:32  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.1  89/02/21  17:17:43  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

*+
* alone.s - this file should be linked in when building screen.prg.
*
* author: Slavik Lozben
*-
		.globl	_vblqueue
		.globl	_v_bas_ad
		.globl	save_row
		.globl	con_state
		.globl	sshiftmd
		.globl	ringbel
		.globl	myvq_key_s
		.globl	kbshift

_vblqueue	.equ	$456
_v_bas_ad	.equ	$44e
save_row	.equ	$4ac		; Row from escape Y command
con_state	.equ	$4a8		; Present state of the conout state machine
sshiftmd	.equ	$44c
conterm		.equ	$484
_sysbase	.equ	$4f2		; -> base of os

*+
* Return Shift, Control, Alt State
*-
myvq_key_s:	move.l	_sysbase,a0	; a0 -> base of os
		move.l	$24(a0),a0	; a0 -> kbshift
		move.b	(a0),kbshift	; kbshift <- current shift mode
		jmp	_vq_key_s	; go to the old guy

kbshift:	dc.w	0

*+
* Ring the bell, and return
*-
ringbel:	movea.l	#0,a5
		btst.b	#$2,conterm	; see if bell is disabled
		beq	rgbel
	
		move.l	#bellsnd,-(sp)	; push ptr to data for bell
		move.w	#32,-(sp)	; push func #
		trap	#14		; xbios
		addq.l	#$6,sp		; clean stack
rgbel:		rts

		.even
bellsnd:	.dc.b	0,$34
		.dc.b	1,0
		.dc.b	2,0
		.dc.b	3,0
		.dc.b	4,0
		.dc.b	5,0
		.dc.b	6,0
		.dc.b	7,$FE
		.dc.b	8,$10		;enable envelope, ch a
		.dc.b	9,0
		.dc.b	10,0
		.dc.b	11,0
		.dc.b	12,$10
		.dc.b	13,9		;envelope single attack
		.dc.b	255,0
	.end
