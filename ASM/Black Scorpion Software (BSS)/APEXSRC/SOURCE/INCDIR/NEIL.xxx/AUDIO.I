 
;--------------------------------------------------------------------
; AUDIO CODEC REGISTERS
;--------------------------------------------------------------------

S_DMA_INTCTRL	=	$FFFF8900
S_NOINT		=	%0000
S_PLAY7		=	%0001
S_REC7		=	%0010
S_PLAYREC7	=	%0011
S_PLAYA		=	%0100
S_RECA		=	%1000
S_PLAYRECA	=	%1100

S_DMA_CTRL	=	$FFFF8901
S_PLAYON	=	1
S_PLAYREP	=	1<<1
S_RECON		=	1<<4
S_RECREP	=	1<<5
S_RECACCESS	=	1<<7

S_FSTART_HI	=	$FFFF8903
S_FSTART_MED	=	$FFFF8905
S_FSTART_LO	=	$FFFF8907
S_FCOUNT_HI	=	$FFFF8909
S_FCOUNT_MED	=	$FFFF890B
S_FCOUNT_LO	=	$FFFF890D
S_FEND_HI	=	$FFFF890F
S_FEND_MED	=	$FFFF8911
S_FEND_LO	=	$FFFF8913

S_TRK_PLAYCTRL	=	$FFFF8920
S_PLAY_1TRK	=	0
S_PLAY_2TRK	=	1
S_PLAY_3TRK	=	2
S_PLAY_4TRK	=	3
S_CONNECT_TRK1	=	0<<4
S_CONNECT_TRK2	=	1<<4
S_CONNECT_TRK3	=	2<<4
S_CONNECT_TRK4	=	3<<4

S_TRK_RECCTRL	=	$FFFF8936
S_REC_1TRK	=	0
S_REC_2TRK	=	1
S_REC_3TRK	=	2
S_REC_4TRK	=	3

S_MODE_CTRL	=	$FFFF8921
S_16BIT		=	1<<6
S_MONO		=	1<<7
S_NUTE		=	0
S_STE12		=	1
S_STE25		=	2
S_STE50		=	3

S_SRCDEVICE	=	$FFFF8930
S_DESTDEVICE	=	$FFFF8932

S_PRESCALE_EXT	=	$FFFF8934

S_PRESCALE_INT	=	$FFFF8935
S_CLKSTE	=	0
S_CLK50		=	1
S_CLK33		=	2
S_CLK25		=	3
S_CLK20		=	4
S_CLK16		=	5
S_CLK14		=	7
S_CLK10		=	9
S_CLK8		=	11

S_HARDADDER	=	$FFFF8937
S_ADD_ADC	=	1
S_ADD_MATRIX	=	2

S_ADC_INPUT	=	$FFFF8938
S_PSGLEFT	=	1
S_PSGRIGHT	=	2

S_GAIN		=	$FFFF8939
S_ATTEN		=	$FFFF893A

S_CODECSTAT	=	$FFFF893C
S_LOVERFLOW	=	1<<9
S_ROVERFLOW	=	1<<8

;--------------------------------------------------------------------
; AUDIO XBIOS MACROS CALLS
;--------------------------------------------------------------------

S_LOCKSND	macro
		move.w	#128,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

S_UNLOCKSND	macro
		move.w	#129,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

S_SOUNDCMD	macro	(mode,data)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#130,-(sp)
		trap	#14
		lea	8(sp),sp
		endm

S_SETBUFFER	macro	(reg,beginadd,endadd)
		move.l	\3,-(sp)
		move.l	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#131,-(sp)
		trap	#14
		lea	12(sp),sp
		endm

S_SETMODE	macro	(mode)
		move.w	\1,-(sp)
		move.w	#132,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

S_SETTRACKS	macro	(playtracks,rectracks)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#133,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

S_SETMONTRACKS	macro	(montrack)
		move.w	\1,-(sp)
		move.w	#134,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

S_SETINTERRUPT	macro	(inter,cause)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#135,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

S_BUFFOPER	macro	(mode)
		move.w	\1,-(sp)
		move.w	#136,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

S_DSPTRISTATE	macro	(dspxmit,dsprec)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#137,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

S_GPIO		macro	(mode,data)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#138,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

S_DEVCONNECT	macro	(src,dst,srcclk,prescale,protocol)
		move.w	\5,-(sp)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#139,-(sp)
		trap	#14
		lea	12(sp),sp
		endm

S_SNDSTATUS	macro	(reset)
		move.w	\1,-(sp)
		move.w	#140,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

S_BUFFPTR	macro	(ptr)
		move.l	\1,-(sp)
		move.w	#141,-(sp)
		trap	#14
		addq.w	#6,sp
		endm

