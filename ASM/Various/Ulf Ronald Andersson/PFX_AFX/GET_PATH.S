;----------------------------------------------------------------------------
getdrvpath_ia1:
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a1,-(sp)
	move	curr_drive,d0
	bmi.s	.get_drive
	gemdos	Mediach,d0
	tst.l	d0
	bne.s	.get_drive
	move	curr_drive(pc),d0
	bra.s	.put_drive
;
.get_drive:
	gemdos	Dgetdrv
.put_drive:
	move.b	d0,curr_drive
	add	#'A',d0
	move.l	(sp),a1
	move.b	d0,(a1)+
	move.b	#':',(a1)+
	sub	#'A',d0
.get_path:
	addq	#1,d0
	gemdos	Dgetpath,(a1),d0
	move.l	(sp)+,a0
.pass_str:
	tst.b	(a0)+
	bne.s	.pass_str
	subq	#1,a0
	move.b	#'\',(a0)+
	move.b	#'*',(a0)+
	move.b	#'.',(a0)+
	move.b	#'*',(a0)+
	clr.b	(a0)
	movem.l	(sp)+,d0-d2/a0-a2
	rts
;------------------------------------
curr_drive:	dc.w	-1
;----------------------------------------------------------------------------
