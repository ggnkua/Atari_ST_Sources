; dsp subrouts & macros

sendLongToDsp:	MACRO
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	move.l	\1,$ffffa204.w
	ENDM

receiveLongFromDsp:	MACRO
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	move.l	$ffffa204.w,\1
	ENDM

sendWordToDsp:	MACRO
	btst.b	#1,$ffffa202.w
	beq.s	*-6
	move.w	\1,$ffffa206.w
	ENDM

receiveWordFromDsp:	MACRO
	btst.b	#0,$ffffa202.w
	beq.s	*-6
	move.w	$ffffa206.w,\1
	ENDM

