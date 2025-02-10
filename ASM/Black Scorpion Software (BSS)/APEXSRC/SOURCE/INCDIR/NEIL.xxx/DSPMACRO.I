
dspwrite	macro
		ifeq "\0"-"b"
		move.b	\1,$FFFFA207.w
		endc
		ifeq "\0"-"l"
		move.l	\1,$FFFFA204.w
		else
		move.w	\1,$FFFFA206.w
		endc
		endm

dspread		macro
		ifeq "\0"-"b"
		move.b	$FFFFA207.w,\1
		endc
		ifeq "\0"-"l"
		move.l	$FFFFA204.w,\1
		else
		move.w	$FFFFA206.w,\1
		endc
		endm

dsptx		macro
.ww\@		btst		#1,$FFFFA202.w
		beq.s		.ww\@
		endm

dsprx		macro
.wr\@		btst		#0,$FFFFA202.w
		beq.s		.wr\@
		endm

dspwritewait	macro
		dsptx
		dspwrite	\1
		endm

dspreadwait	macro
		dsprx
		dspread		\1
		endm
