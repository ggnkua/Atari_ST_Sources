* long division
* answer in second argument, remainder in first
Div_l	MACRO
	clr.l	-(sp)	;storage for counter
.dl_1	addq.l	#1,(sp)
	sub.l	\1,\2
	bge.s	.dl_1
	add.l	\1,\2	
	move.l	\2,\1	;remainder in first argument
	move.l	(sp)+,\2	;count in second argument
	subq.l	#1,\2	;correct count
	ENDM
