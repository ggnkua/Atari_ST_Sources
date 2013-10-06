*****************************************************************
*	Keyboard program v2.1		*
*				*
* Done by Michael PRIVAT			*
* Any problem : Send an E-Mail to privat@essi.fr	*
*				*
* 03.11.1995				*
*****************************************************************

*****************************************************************
** This special Keyboard Routine allows to manage all Keys in
** the same Time.
**
** It is useful if you want to code a game and to play with the
** keyboard.
** See the following example to see how to use it
*****************************************************************
*****************************************************************

	OPT	d+,x+,t+,c+
	OPT	o+,o1+,o2+,o3+,o4+,o5+,o6+,o7+,o8+

Send_IKBD	MACRO
	moveq	#\1,d0
	bsr	Send_byte_to_IKBD
	ENDM

*****************************************************************
*****************************************************************


	SECTION	TEXT

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp

	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp

	move.w	#1,-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#$2700,sr
	lea	Save_all(pc),a0
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$44e.w,(a0)+
	move.l	$ffff8240.w,(a0)+
	move.l	$ffff8244.w,(a0)+
	move.w	$ffff820e.w,(a0)+
	move.w	$ffff8264.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	move.l	$fffffa12.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	clr.w	$ffff820e.w
	clr.w	$ffff8264.w

	clr.l	$fffffa06.w
	clr.l	$fffffa12.w

	Send_IKBD	$80	; Reset IKBD
	Send_IKBD	$01

	Send_IKBD	$12	; No mouse

	move.l	#VBL,$70.w
	move.l	#IKBD,$118.w
	move.b	#$40,$fffffa17.w
	move.l	#$ff01ff40,$fffffa06.w
	move.l	#$ff01ff40,$fffffa12.w

****************************************************************
Begin:

	stop	#$2300

****************************************************************
Main:
	bsr	Test_KBD

	move.l	$466.w,d0
.Wait_Vsync:
	cmp.l	$466.w,d0
	beq.s	.Wait_Vsync

	cmp.w	#$39,Key_code	; [SPACE] to Exit
	beq.s	Exit
	bra.s	Main

****************************************************************
Exit:
	move.w	#$2700,sr
	lea	Save_all(pc),a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$44e.w
	move.l	(a0)+,$ffff8240.w
	move.l	(a0)+,$ffff8244.w
	move.w	(a0)+,$ffff820e.w
	move.w	(a0)+,$ffff8264.w
	move.l	(a0)+,$fffffa06.w
	move.l	(a0)+,$fffffa12.w
	move.b	(a0)+,$fffffa17.w

	Send_IKBD	$80
	Send_IKBD	$01

	stop	#$2300

	move.w	#$040,$ffff8242.w

	clr.w	-(sp)
	trap	#1

	illegal

*****************************************************************
*****************************************************************
Test_KBD:
	tst.b	$1c+KBD_map
	beq.s	.Not_Return
	nop	** Here 'Return' Key is pressed
.Not_Return:
	tst.b	$10+KBD_map
	beq.s	.Not_A_key
	nop	** Here 'A' Key is pressed
.Not_A_key:
	rts
*****************************************************************
Send_byte_to_IKBD:
	btst	#1,$fffffc00.w
	beq.s	Send_byte_to_IKBD	; ACIA CTS ?
	move.b	d0,$fffffc02.w		; Yes !

	move.w	#32768-1,d0
.Wait_IKBD_recieve_ID:
	btst	#0,$fffffc00.w
	bne.s	.Recept_IKBD_reply_ID	; Exit or ...
	dbf	d0,.Wait_IKBD_recieve_ID	; Time out.
.Recept_IKBD_reply_ID:
	move.b	$fffffc02.w,d0
	rts

*****************************************************************
VBL:
	addq.l	#1,$466.w
	rte
*****************************************************************
IKBD:
	btst	#0,$fffffc00.w
	beq.s	.IKBD_end

	move.w	d0,-(sp)
	pea	(a0)

	lea	KBD_map(pc),a0
	clr.w	d0
	move.b	$fffffc02.w,d0
	blt.s	.Key_flushed
	move.w	d0,Key_code
	st	(a0,d0.w)

	move.l	(sp)+,a0
	move.w	(sp)+,d0
.IKBD_end:
	rte
.Key_flushed:
	sf	-128(a0,d0.w)
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	rte

*****************************************************************
*****************************************************************

	SECTION	DATA
Key_code:
	dc.w	0
KBD_map:
	dcb.b	128,0
Save_all:
	ds.l	20

*****************************************************************
	SECTION	BSS
Old_KBD:
	ds.l	1
