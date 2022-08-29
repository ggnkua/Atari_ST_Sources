
;notes: see hatari source archive -> nf_asma.s

		comment HEAD=-1		;tell gbe to strip prg header
		opt	p=68000		;processor type
		opt	c+		;case matters
		opt	o+		;optimize all
		opt	chkpc		;force position independent
		output	nf_test.inl

		text

		;returns true or false
nf_test:	lea	sub(pc),a0
		move.l	a0,-(sp)
		move.w	#38,-(sp)	;supexec()
		trap	#14
		addq.l	#6,sp		;fix stack
		rts			;->d0.l

sub:
		moveq	#0,d0		;assume no natfeats available
		move.l	sp,a1
		move.l	$10.w,a0	;illegal vector

	;	move.l	#fail_nf,$10
		lea	fail_nf(pc),a2
		move.l	a2,$10.w

	;	pea	nf_version
		lea	nf_version(pc),a2
		move.l	a2,-(sp)

		subq.l	#4,sp
		;
		dc.w	$7300		;jump to natfeats_id
		tst.l	d0
		beq.s	fail_nf
		moveq	#-1,d0		;natfeats detected
fail_nf:
		move.l	a1,sp
		move.l	a0,$10.w	;illegal vector
		;
		rts			;->d0.l

nf_version:	dc.b	"NF_VERSION",0
		even

		end
