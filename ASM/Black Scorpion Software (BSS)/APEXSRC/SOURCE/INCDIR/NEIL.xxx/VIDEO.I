
;--------------------------------------------------------------------
; VIDEO HARDWARE REGISTERS
;--------------------------------------------------------------------

V_MONTYPE	= $FFFF8006
V_MON_MONO	= 0<<6
V_MON_COLOUR	= 1<<6
V_MON_VGA	= 2<<6
V_MON_TV	= 3<<6

V_BASEPTR	= $FFFF8200
V_BASE_HI	= V_BASEPTR+1
V_BASE_MED	= V_BASEPTR+3
V_BASE_LO	= V_BASEPTR+$D

V_COUNTER_HI	= $FFFF8205
V_COUNTER_MED	= $FFFF8207
V_COUNTER_LO	= $FFFF8209

V_SYNCMODE	= $FFFF820A
V_LINESKIP	= $FFFF820E
V_LINEWID	= $FFFF8210

V_STPALETTE	= $FFFF8240

V_STSHIFT	= $FFFF8260

V_FINESCROLL	= $FFFF8264

V_SHIFT		= $FFFF8266
V_TC		= 1<<10
V_2COL		= 1<<8
V_256COL	= 1<<4
V_EXT_VSYNC	= 1<<5
V_EXT_HSYNC	= 1<<6

V_HFREQ_CNTR	= $FFFF8280
V_HFREQ_TIMER	= $FFFF8282
V_HBORD_BEGIN	= $FFFF8284
V_HBORD_END	= $FFFF8286
V_HDISP_BEGIN	= $FFFF8288
V_HDISP_END	= $FFFF828A
V_H_SS		= $FFFF828C
V_H_FS		= $FFFF828E
V_H_HH		= $FFFF8290

V_VFREQ_CNTR	= $FFFF82A0
V_VFREQ_TIMER	= $FFFF82A2
V_VBORD_BEGIN	= $FFFF82A4
V_VBORD_END	= $FFFF82A6
V_VDISP_BEGIN	= $FFFF82A8
V_VDISP_END	= $FFFF82AA
V_V_SS		= $FFFF82AC

V_SCALE		= $FFFF82C2
V_SQUASH	= 1<<0
V_LACE		= 1<<1
V_HIRES		= 1<<2

V_PALETTE	= $FFFF9800

;--------------------------------------------------------------------
; Modecode equates
;--------------------------------------------------------------------

BPL1		=	0
BPL2		=	1
BPL4		=	2
BPL8		=	3
TRUE		=	4
HIRES		=	1<<3
VGA		=	1<<4
PAL		=	1<<5
OS		=	1<<6
ST		=	1<<7
LACE		=	1<<8

;--------------------------------------------------------------------
; VIDEO TRAPS
;--------------------------------------------------------------------

V_PHYSBASE	macro
		move.w	#2,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

V_LOGBASE	macro
		move.w	#3,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

V_SETSCREEN	macro	(logic.l,physic.l,res.w,mode.w)
		move.w	\4,-(sp)
		move.w	\3,-(sp)
		move.l	\2,-(sp)
		move.l	\1,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	14(sp),sp
		endm

V_SETMODE	macro	(modecode.w)
		move.w	\1,-(sp)
		move.w	#88,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

V_MONTYPE	macro
		move.w	#89,-(sp)
		trap	#14
		addq.w	#2,sp
		endm

V_GETSIZE	macro	(mode.w)
		move.w	\1,-(sp)
		move.w	#91,-(sp)
		trap	#14
		addq.w	#4,sp
		endm

V_SETRGB	macro	(index.w,count.w,address.l)
		move.l	\3,-(sp)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#93,-(sp)
		trap	#14
		lea	10(sp),sp
		endm

V_GETRGB	macro	(index.w,count.w,address.l)
		move.l	\3,-(sp)
		move.w	\2,-(sp)
		move.w	\1,-(sp)
		move.w	#94,-(sp)
		trap	#14
		lea	10(sp),sp
		endm
