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

INVERSE_MOT2	MACRO	adresse,registre
	move	(\1)+,\2
	ror	#8,\2
	ENDM

INVERSE_LONG2	MACRO	adresse,registre
	move.l	(\1)+,\2
	ror	#8,\2
	swap	\2
	ror	#8,\2
	ENDM

	BSS
	
intel	ds.l	1
