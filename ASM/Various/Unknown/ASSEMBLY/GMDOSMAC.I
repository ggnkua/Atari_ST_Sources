Pterm	MACRO
	move.w	\1,-(sp)
	move.w	#76,-(sp)
	trap	#1
	ENDM

Mshrink	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	clr.w	-(sp)
	move.w	#74,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

Fopen	MACRO
	move.w	\1,-(sp)
	move.l	\2,-(sp)
	move.w	#61,-(sp)
	trap	#1
	addq.l	#8,sp
	ENDM

Fread	MACRO
	move.l	\1,-(sp)
	move.l	\2,-(sp)
	move.w	\3,-(sp)
	move.w	#63,-(sp)
	trap	#1
	lea	12(sp),sp
	ENDM

Fclose	MACRO
	move.w	\1,-(sp)
	move.w	#62,-(sp)
	trap	#1
	addq.l	#4,sp
	ENDM

Cconws	MACRO
	move.l	\1,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	ENDM	

