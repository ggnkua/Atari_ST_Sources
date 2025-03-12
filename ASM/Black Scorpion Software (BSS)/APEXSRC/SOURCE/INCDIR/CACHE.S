
ienab_bit	=		0
ifrz_bit	=		1
iclre_bit	=		2
iclr_bit	=		3
ibrst_bit	=		4

denab_bit	=		8
dfrz_bit	=		9
dclre_bit	=		10
dclr_bit	=		11
dbrst_bit	=		12
wa_bit	=		13

ienab		=		1<<ienab_bit
ifrz		=		1<<ifrz_bit
iclre		=		1<<iclre_bit
iclr		=		1<<iclr_bit
ibrst		=		1<<ibrst_bit

denab		=		1<<denab_bit
dfrz		=		1<<dfrz_bit
dclre		=		1<<dclre_bit
dclr		=		1<<dclr_bit
dbrst		=		1<<dbrst_bit
wa		=		1<<wa_bit

reset		=		iclr|dclr|ibrst|dbrst|ienab|denab|wa

cache		macro
		move.w	d0,-(sp)
		move.w	#\1,d0
		movec		d0,CACR
		move.w	(sp)+,d0
		endm

cacheoff	macro
		move.w	#ienab|dclr,\1
		movec		\1,cacr
		endm

cacheon	macro
		move.w	#ienab|denab|wa,\1
		movec		\1,cacr
		endm


