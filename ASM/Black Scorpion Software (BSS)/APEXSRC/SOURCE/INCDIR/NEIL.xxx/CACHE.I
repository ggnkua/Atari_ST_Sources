
;--------------------------------------------------------------------
; CACHE CONTROL EQUATES + MACRO
;--------------------------------------------------------------------

C_IENAB		=		1<<0
C_IFREZ		=		1<<1
C_ICLRE		=		1<<2
C_ICLR		=		1<<3
C_IBRST		=		1<<4

C_DENAB		=		1<<8
C_DFREZ		=		1<<9
C_DCLRE		=		1<<10
C_DCLR		=		1<<11
C_DBRST		=		1<<12

C_WA		=		1<<13

C_RESET		=		12561|C_ICLR|C_DCLR

CACHE		macro
		move.w	d0,-(sp)
		move.w	#\1,d0
		movec	d0,CACR
		move.w	(sp)+,d0
		endm
