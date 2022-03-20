
locksnd		macro	
		move.w	#128,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

unlocksnd	macro	
		move.w	#129,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

soundcmd	macro	mode,data
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#130,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

setbuffer	macro	reg,begaddr,endaddr
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#131,-(sp)
		trap	#14
		lea	12(sp),sp
		endm

setmode		macro	mode
		move.w	\1,-(sp)
		move.w	#132,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

settracks	macro	playtracks,rectracks
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#133,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

setmontracks	macro	montrack
		move.w	\1,-(sp)
		move.w	#134,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

setinterupt	macro	src_inter,cause
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#135,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

buffoper	macro	mode
		move.w	\1,-(sp)
		move.w	#136,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

dsptristate	macro	dspxmit,dsprec
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#137,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

gpio		macro	mode,data
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#138,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

devconnect	macro	src,dst,srcclk,prescale,protocol
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#139,-(sp)
		trap	#14
		lea	12(sp),sp
		endm

sndstatus	macro	reset
		move.w	\1,-(sp)
		move.w	#140,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

buffptr		macro	pointer
		move.l	\1,-(sp)
		move.w	#141,-(sp)
		trap	#14
		addq.w	#6,sp
		endm
