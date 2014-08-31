	output	.ro

	;due to bus error handling in [Alt_E] function and in the evaluator,
	;this RO allows you to 'POKE' in bus error vector, i.e. $8.

putberr:
	move.l	(a1),$8.w
	rts
