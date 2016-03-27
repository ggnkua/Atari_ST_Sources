; MACRO.S

printtext	macro
		pea	\1
		move.w	#9,-(a7)
		trap	#1
		addq.l	#6,a7
		endm

waitkey		macro
		move.w	#8,-(a7)
		trap	#1
		addq.l	#2,a7
		endm