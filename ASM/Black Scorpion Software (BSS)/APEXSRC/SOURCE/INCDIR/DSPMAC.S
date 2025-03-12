
dspwrite	macro
.ww\@		btst		#1,$FFFFA202.w
		beq.s		.ww\@
		move.w	\1,$FFFFA206.w
		endm

dspread	macro
.wr\@		btst		#0,$FFFFA202.w
		beq.s		.wr\@
		move.w	$FFFFA206.w,\1
		endm

dspwritel	macro
.ww\@		btst		#1,$FFFFA202.w
		beq.s		.ww\@
		move.l	\1,$FFFFA204.w
		endm

dspreadl	macro
.wr\@		btst		#0,$FFFFA202.w
		beq.s		.wr\@
		move.l	$FFFFA204.w,\1
		endm

