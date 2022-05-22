;-------------------------------------------------------
; Animation Display Routines (C) E.S.D. '90-'92
;
; Enter with :
;
;	A0   : Pointer to DLT Animation.
;	A1   : Pointer to Screen (or similar)
;
;--------------------------------------------------------
play_dlt:	move.w	(a0)+,d0		;number of deltas
		beq	.eos			;zero = end of seq
		move.w	d0,d1
		asr.w	#3,d0			;/8
		and.w	#7,d1
		asl.w	#3,d1			;x8
		neg.w	d1
		jmp	.next(pc,d1.w)
.loop:		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
.next:		dbra	d0,.loop
.eos:		rts
