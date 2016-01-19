;
; Invert (EOR) sample files
; -------------------------
;
; Converts 2 Bit System Replay samples into STE format
;

	opt	d+,x+

	bra.s	start	

sample_start	ds.l	1
sample_end	ds.l	1
sample_length	ds.l	1

start	move.l	#sample_start,D0
	add.l	sample_length,D0
	move.l	D0,sample_end

	move.l	#sample_start,A0

convert	move.b	(A0),D0
	sub.b	#$80,D0
	move.b	D0,(A0)+
	cmp.l	sample_end,A0
	bne.s	convert
	rts

