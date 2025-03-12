
;--------------------------------------------------------------------
; GENERALLY USEFUL MACROS
;--------------------------------------------------------------------

GENERAL

HIDEMOUSE	macro	
		dc.w	$A00A
		endm

SHOWMOUSE	macro
		dc.w	$A009
		endm

ENVIRONMENT	macro	
		move.l	sp,a5
		move.l	4(a5),a5	get next TPA (end of this TPA)

		move.l	a5,a4
		add.w	#128,a4		pointer to command string
		move.l	44(a5),a3	pointer to environment string

		move.l	12(a5),d0	TEXT size
		add.l	20(a5),d0	DATA size
		add.l	28(a5),d0	BSS size
		add.l	#256,d0		extra for stack
		endm

push		macro	(pushvar)
		move.\0	\1,-(sp)
		endm
	
pop		macro	(popvar)
		move.\0	(sp)+,\1
		endm

pushall		macro
		movem.l	d0-d7/a0-a6,-(sp)
		endm
	
popall		macro
		movem.l	(sp)+,d0-d7/a0-a6
		endm
