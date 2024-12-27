; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.

	
Ste_Test	LEA	$FFFF8205.W,A5
;;;;;;;;;;		MOVEQ	#-1,D1
		MOVE.B	(A5),D0	;get original value
		MOVE.B	#-1,(A5)	;poke new value
		CMP.B	(A5),d0		;get value again, is it same?
** changed by MSD of POV 'cos of STe detection bug
		bne	.notSTE	;yes same so not ste
**
		MOVE.B	D0,(a5)	;yes so poke original value back
.ste_found	move.w	#-1,ste_flg

.notSTE
	rts
ste_flg		DC.W 0
