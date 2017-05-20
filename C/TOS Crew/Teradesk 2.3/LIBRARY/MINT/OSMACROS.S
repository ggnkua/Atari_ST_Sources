GEMDOS		=	1
BIOS		=	13
XBIOS		=	14

REGSIZE		equ	4		; size of the space we need 
					; for scrap regs
.MACRO	SYS_	Os,Nr
	pea	(a2)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#2,sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_L	Os,Nr,L1
	pea	(a2)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#6,sp
	movea.l	(sp)+,a2
	.ENDM
	
.MACRO	SYS_W	Os,Nr,W1
	pea	(a2)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#4,sp
	movea.l	(sp)+,a2
	.ENDM
	
.MACRO	SYS_WW	Os,Nr,W1,W2
	pea	(a2)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#6,sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LW	Os,Nr,L1,W1
	pea	(a2)
	move.w	W1,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#8,sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WWW	Os,Nr,W1,W2,W3
	pea	(a2)
	move.w	W3,-(sp)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#8,sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WLW	Os,Nr,W1,L1,W2
	pea	(a2)
	move.w	W2,-(sp)
	move.l	L1,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	10(sp),sp
	movea.l	(sp)+,a2
	.ENDM
	
.MACRO	SYS_WL	Os,Nr,W1,L1
	pea	(a2)
	move.l	L1,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	addq.w	#8,sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WLL	Os,Nr,W1,L1,L2
	pea	(a2)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	12(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WWL	Os,Nr,W1,W2,L1
	pea	(a2)
	move.l	L1,-(sp)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	10(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LWW	Os,Nr,L1,W1,W2
	pea	(a2)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	10(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WWWL Os,Nr,W1,W2,W3,L1
	pea	(a2)
	move.l	L1,-(sp)
	move.w	W3,-(sp)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	12(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WWLL Os,Nr,W1,W2,L1,L2
	pea	(a2)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	14(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WLLL Os,Nr,W1,L1,L2,L3
	pea	(a2)
	move.l	L3,-(sp)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	16(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WLLLL Os,Nr,W1,L1,L2,L3,L4
	pea	(a2)
	move.l	L4,-(sp)
	move.l	L3,-(sp)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	20(sp),sp			; HR!!! 16 --> 20
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LL	Os,Nr,L1,L2
	pea	(a2)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	10(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LLW	Os,Nr,L1,L2,W1
	pea	(a2)
	move.w	W1,-(sp)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	12(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LLL	Os,Nr,L1,L2,L3
	pea	(a2)
	move.l	L3,-(sp)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	14(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LLWW	Os,Nr,L1,L2,W1,W2
	pea	(a2)
	move.w	W2,-(sp)
	move.w	W1,-(sp)
	move.l	L2,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	14(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_LWLW	Os,Nr,L1,W1,L2,W2
	pea	(a2)
	move.w	W2,-(sp)
	move.l	L2,-(sp)
	move.w	W1,-(sp)
	move.l	L1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	14(sp),sp
	movea.l	(sp)+,a2
	.ENDM

.MACRO	SYS_WLWWW	Os,Nr,W1,L1,W2,W3,W4
	pea	(a2)
	move.w	W4,-(sp)
	move.w	W3,-(sp)
	move.w	W2,-(sp)
	move.l	L1,-(sp)
	move.w	W1,-(sp)
	move.w	Nr,-(sp)
	trap	#Os
	lea	14(sp),sp
	movea.l	(sp)+,a2
	.ENDM
	

