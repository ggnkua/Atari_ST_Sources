*
*	FULLSCREEN ROUT v 2.1
*

*	Coded by:	PeyloW of T.O.Y.S.

*	Gives a resolution of 448*272 on 'STe'

*	Do only use this code if you know what to do
*	coz I take no responsibility for any of your
*	hardware.

*	Have fun !!!


	clr.l	-(sp)		; Super thanks...
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)		; Save old stack
	
	
	move.l	$70,-(sp)		; Old VBL
	
	move.b	#$12,$fffffc02.w	; Kill mouse
	
	move.w	sr,-(sp)		; Save guess what

	move.w	$fffffa08.w,-(sp)	; save timers
	
	clr.b	$fffffa09.w		; Timers off
	
	move.w	#$2300,sr		; Dont ask

	move.l	#vbl,$70.w		; Turn full screen on
	

loop:	cmp.b	#$39,$fffffc02.w	; Wait for space
	bne	loop	
	
	
	
	move.w	(sp)+,$fffffa08.w	; Restore everything
	
	move.w	(sp)+,sr

	move.l	(sp)+,$70.w
		
		
	move.w	#$fff,$ffff8240.w
	
	move.b	#8,$fffffc02.w	; arise mouse from the dead
	

	move.w	#32,-(sp)		; Back to user
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)		; And exit
	trap	#1
	


vbl:	move.l	#1430,d0		; Wait a hell of a time
wait1	dbra	d0,wait1

	move.b	#0,$ffff820a	; 60 Hz kills upper border

	dcb.w	14,$4e71		; Wait ($4e71=nop)

	move.b	#2,$ffff820a	; back to 50Hz

	lea	$ffff8209,a0	; a0=low videopointer
	clr.l	d0
	move.l	#16,d1
wait2	move.b	(a0),d0		; Has screen started???
	beq.s	wait2		; No,   try ones more
	move.w	#$707,$ffff8240.w
	sub.b	d0,d1
	lsr.w	d1,d0		; Do the sync
	move.w	#$0,$ffff8240.w
	
	lea	$ffff820a,a0	; a0=Hz register	
	lea	$ffff8260,a1	; a1=rezolution
	clr.l	d0		; d0=low or 60Hz
	moveq.l	#2,d1		; d1=high or 50Hz

	dcb.w	77,$4e71		; nops, nops, nops



	REPT	228		; 227 lines to go

	dcb.w	2,$4e71
	
	move.b	d1,(a1)		; High kills left border
	move.b	d0,(a1)
	
	dcb.w	91,$4e71		

	move.b	d0,(a0)		; 60Hz kills right
	move.b	d1,(a0)	

	dcb.w	27,$4e71

	ENDR


	move.b	d0,(a0)		; 60Hz for lower border
	move.b	d1,(a1)		; High for left
	move.b	d0,(a1)
	move.b	d1,(a0)	
	
	dcb.w	89,$4e71

	move.b	d0,(a0)		; Right as usaul
	move.b	d1,(a0)	

	dcb.w	27,$4e71

	REPT	35		; 35 more lines gives
*				; a total of 264 lines.
	dcb.w	2,$4e71
	move.b	d1,(a1)
	move.b	d0,(a1)
	
	dcb.w	91,$4e71

	move.b	d0,(a0)
	move.b	d1,(a0)	

	dcb.w	27,$4e71

	ENDR


	rte			; Well,  thats all folks
	
	
	
