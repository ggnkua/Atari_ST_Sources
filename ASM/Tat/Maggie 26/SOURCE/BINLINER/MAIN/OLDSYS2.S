save_old_system:
	bsr	save_loading_vectors
	lea	old_system_data(PC),A6
	movec	cacr,d0
	move.l	d0,(a6)+
	BSR	save_old_vectors
	BSR	save_old_mfp
	BSR	save_old_video
	RTS

restore_old_system:
	lea	old_system_data(PC),A6
	move.l	(a6)+,d0
	movec	d0,cacr
	BSR	restore_old_vectors
	BSR	restore_old_mfp
	BSR	restore_old_video

	JSR	tracker_player+16
	RTS

save_old_video
	BSR	save_old_colours
	MOVE.W	#$FFFF,-(A7)
	MOVE.W	#$58,-(A7)
	TRAP	#$E
	ADDQ.L	#4,A7
	MOVE.W	D0,(A6)+
	MOVE.B	$FFFF8007.W,(A6)+
	MOVE.B	$FFFF8201.W,(A6)+
	MOVE.B	$FFFF8203.W,(A6)+
	MOVE.B	$FFFF820D.W,(A6)+
	MOVE.W	$FFFF820A.W,(A6)+
	MOVE.W	$FFFF820E.W,(A6)+
	MOVE.W	$FFFF8210.W,(A6)+

	MOVE.W	$FFFF8264.W,(A6)+
	MOVE.W	$FFFF820e.W,(A6)+
	RTS

restore_old_video:
	BSR	restore_old_colours
	MOVE.W	(A6)+,-(A7)
	MOVE.W	#$58,-(A7)
	TRAP	#$E
	ADDQ.L	#4,A7
	MOVE.B	(A6)+,$FFFF8007.W
	MOVE.B	(A6)+,$FFFF8201.W
	MOVE.B	(A6)+,$FFFF8203.W
	MOVE.B	(A6)+,$FFFF820D.W
	MOVE.W	(A6)+,$FFFF820A.W
	MOVE.W	(A6)+,$FFFF820E.W
	MOVE.W	(A6)+,$FFFF8210.W
	MOVE.W	(a6)+,$FFFF8264.W
	MOVE.W	(a6)+,$FFFF820e.W
	RTS

save_old_mfp:
	MOVE.B	$FFFFFA07.W,(A6)+
	MOVE.B	$FFFFFA09.W,(A6)+
	MOVE.B	$FFFFFA13.W,(A6)+
	MOVE.B	$FFFFFA15.W,(A6)+
	MOVE.B	$FFFFFA17.W,(A6)+
	MOVE.B	$FFFFFA19.W,(A6)+
	MOVE.B	$FFFFFA1B.W,(A6)+
	MOVE.B	$FFFFFA1F.W,(A6)+
	MOVE.B	$FFFFFA21.W,(A6)+
	RTS

restore_old_mfp
	MOVE.B	(A6)+,$FFFFFA07.W
	MOVE.B	(A6)+,$FFFFFA09.W
	MOVE.B	(A6)+,$FFFFFA13.W
	MOVE.B	(A6)+,$FFFFFA15.W
	MOVE.B	(A6)+,$FFFFFA17.W
	MOVE.B	(A6)+,$FFFFFA19.W
	MOVE.B	(A6)+,$FFFFFA1B.W
	MOVE.B	(A6)+,$FFFFFA1F.W
	MOVE.B	(A6)+,$FFFFFA21.W
	RTS

save_old_vectors:
	MOVEA.W	#8,A0
	MOVE.W	#$7D,D0
.L000B:	MOVE.L	(A0)+,(A6)+
	DBF	D0,.L000B
	RTS

restore_old_vectors:
	MOVEA.W	#8,A0
	MOVE.W	#$7D,D0
.L000D:	MOVE.L	(A6)+,(A0)+
	DBF	D0,.L000D
	RTS

save_old_colours:
	MOVEQ	#$F,D0
	LEA	$FFFF8240.W,A0
.L000F:	MOVE.W	(A0)+,(A6)+
	DBF	D0,.L000F
	MOVE.W	#$FF,D0
	LEA	$FFFF9800.W,A0
.L0010:	MOVE.L	(A0)+,(A6)+
	DBF	D0,.L0010
	RTS

restore_old_colours:
	MOVEQ	#$F,D0
	LEA	$FFFF8240.W,A0
.L0012:	MOVE.W	(A6)+,(A0)+
	DBF	D0,.L0012
	MOVE.W	#$FF,D0
	LEA	$FFFF9800.W,A0
.L0013:	MOVE.L	(A6)+,(A0)+
	DBF	D0,.L0013
	RTS


save_loading_vectors:
	lea	old_loading_vectors(pc),a6
	move.l	$70.w,(a6)+
	move.l	$114.w,(a6)+		;timer C
	move.l	$110.w,(a6)+		;timer D
	move.b	$fffffa07.w,(a6)+
	move.b	$fffffa09.w,(a6)+
	move.b	$fffffa13.w,(a6)+
	move.b	$fffffa15.w,(a6)+
	rts

disable_loading_vectors:
	bsr	init_my_interrupts
	rts

restore_loading_vectors:
	lea	old_loading_vectors(pc),a6
	move.l	(a6)+,$70.w		;not system vbl!
	move.l	(a6)+,$114.w		;timer C
	move.l	(a6)+,$110.w		;timer D

; Allow Timer A if already set!
	move.b	$fffffa07.w,d0
	and.b	#%00100000,d0
	or.b	(a6)+,d0
	move.b	d0,$fffffa07.w
	move.b	(a6)+,$fffffa09.w

	move.b	$fffffa13.w,d0
	and.b	#%00100000,d0
	or.b	(a6)+,d0
	move.b	d0,$fffffa13.w
	move.b	(a6)+,$fffffa15.w
	rts
