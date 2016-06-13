;	MACROs pour les appels XBIOS
;	ecris par G.Audoly
;	je ne prends aucunement la responsabilite de degats pouvant etres
;	causes par ces MACROs

Floprd:	MACRO		;#buffer.L,#dev.W,#sector.W,#track.W,#side.W,#count.W
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	clr.l	-(sp)
	move.l	\1,-(sp)
	move.w	#$8,-(sp)
	trap	#14
	lea.l	20(sp),sp
	ENDM

Rsconf:	MACRO		;#baud.W,#ctrl.W,#ucr.W,#rsr.W,#tsr.W,#scr.W
	move.w	\6,-(sp)
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.l	\1,-(sp)
	move.w	#$f,-(sp)
	trap	#14
	lea.l	18(sp),sp
	ENDM
	
Supexec:	MACRO		;#adresse.L
	move.l	\1,-(sp)
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM

Supexec2:	MACRO		;adresse.L
	pea.l	\1
	move.w	#$26,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM

Vsync:	MACRO
	move.w	#$25,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM


