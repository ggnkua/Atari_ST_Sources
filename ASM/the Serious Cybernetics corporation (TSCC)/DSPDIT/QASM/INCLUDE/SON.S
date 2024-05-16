;	MACROs pour la gestion du son du Falcon 030
;	ecris par G.Audoly
;	je ne prends aucunement la responsabilite de degats pouvant etres
;	causes par ces MACROs


locksnd:	MACRO
	move.w	#$80,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM

unlocksnd: MACRO
	move.w	#$81,-(sp)
	trap	#14
	addq.w	#2,sp
	ENDM
	
soundcmd:	MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$82,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM

setbuffer: MACRO
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$83,-(sp)
	trap	#14
	add.w	#12,sp
	ENDM

setbuffer2: MACRO
	pea.l	\3
	pea.l	\2
	move.w	\1,-(sp)
	move.w	#$83,-(sp)
	trap	#14
	add.w	#12,sp
	ENDM
	
setmode:	MACRO
	move.w	\1,-(sp)
	move.w	#$84,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM

settracks: MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$85,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM

setmontracks: MACRO
	move.w	\1,-(sp)
	move.w	#$86,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM

setinterrupt: MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$87,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM

buffoper:	MACRO
	move.w	\1,-(sp)
	move.w	#$88,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM

dsptristate: MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$89,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM

gpio:	MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$8a,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM
	
	
devconnect: MACRO
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#$8b,-(sp)
	trap	#14
	add.w	#12,sp
	ENDM

sndstatus: MACRO
	move.w	\1,-(sp)
	move.w	#$8c,-(sp)
	trap	#14
	addq.w	#4,sp
	ENDM

buffptr:	MACRO
	move.l	\1,-(sp)
	move.w	#$8d,-(sp)
	trap	#14
	addq.w	#6,sp
	ENDM
	
	