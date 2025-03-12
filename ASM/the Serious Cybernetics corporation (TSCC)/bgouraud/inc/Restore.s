;=======================
;=
;= Falcon 030 system restore
;=
;=======================

		section	text
Sys.Exit       	move.w	sr,d0
		move.w	#$2700,sr	; Stop IRQs

		lea	Save.mfp,a0
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa1d.w
		move.b	(a0)+,$fffffa25.w
		move.l	(a0)+,$70.w
		move.l	(a0),$110.w
				
		move.w	d0,sr

		lea	$fffffc00.w,a0	; Mouse on
.ikbd		btst.b  #1,(a0)         ; IKBD ready ?
                beq.s   .ikbd
                
                move.b  #8,2(a0)

		lea.l	Save.videl,a0	; Restore videl vars.
		clr.w	$ffff8266.w
		
		move.l	(a0)+,$ffff8200.w
		move.w	(a0)+,$ffff820c.w
		move.l	(a0)+,$ffff8282.w
		move.l	(a0)+,$ffff8286.w
		move.l	(a0)+,$ffff828a.w
		move.l	(a0)+,$ffff82a2.w
		move.l	(a0)+,$ffff82a6.w
		move.l	(a0)+,$ffff82aa.w
		move.w	(a0)+,$ffff82c0.w
		move.w	(a0)+,$ffff82c2.w
		move.l	(a0)+,$ffff820e.w
		move.w	(a0)+,$ffff820a.w
		move.b	(a0)+,$ffff8256.w
		tst.b	(a0)+		; ST comptaible mode?
		bne.s	.ok
		
		move.w	(a0),$ffff8266.w
		bra.s	.done
		
.ok	 	move.w	2(a0),$ffff8260.w
		lea.l	Save.videl+32,a0
		move.w	(a0)+,$ffff82c2.w
		move.l	(a0),$ffff820e.w

.done 	      	move.l	Save.usp,-(sp)	; Back to user mode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

Term		clr.w	-(sp)
		trap	#1