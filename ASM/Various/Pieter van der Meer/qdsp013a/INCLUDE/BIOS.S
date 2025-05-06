;	MACROs pour appels BIOS
;	ecris par G.Audoly
;	je ne prends aucunement la responsabilite de degats pouvant etres
;	causes par ces MACROs

Bconstat:	MACRO
	move.w	\1,-(sp)
	move.w	#1,-(sp)
	trap	#13
	addq.w	#4,sp
	ENDM
	
Bconin:	MACRO
	move.w	\1,-(sp)
	move.w	#2,-(sp)
	trap	#13
	addq.w	#4,sp
	ENDM

Bconout:	MACRO
	move.w	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#3,-(sp)
	trap	#13
	addq.w	#6,sp
	ENDM

Getbpb:	MACRO		#dev.W
	move.w	\1,-(sp)
	move.w	#7,-(sp)
	trap	#13
	addq.l	#6,sp
	ENDM		bpb.L	

Rwabs:	MACRO		#rwflag.W, #buffer.L, #nombre.W, #debut.W, #dev.W
	move.w	\5,-(sp)
	move.w	\4,-(sp)
	move.w	\3,-(sp)
	move.l	\2,-(sp)
	move.w	\1,-(sp)
	move.w	#4,-(sp)
	trap	#13
	lea.l	14(sp),sp
	ENDM
