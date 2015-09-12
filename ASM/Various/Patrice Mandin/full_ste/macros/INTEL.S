	TEXT

INVERSE_LONG	MACRO	adress_register,adress_register
	lea	intel+4,\2
	move.b	(\1)+,-(\2)
	move.b	(\1)+,-(\2)
	move.b	(\1)+,-(\2)
	move.b	(\1)+,-(\2)
	ENDM

INVERSE_MOT	MACRO	adress_register,adress_register
	lea	intel+2,\2
	move.b	(\1)+,-(\2)
	move.b	(\1)+,-(\2)
	ENDM

	BSS
	
intel	ds.l	1
