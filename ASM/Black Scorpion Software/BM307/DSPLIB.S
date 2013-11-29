*=======================================================*
*	DSP library: updated 12/06/97			*
*=======================================================*

*-------------------------------------------------------*
*	DSP host equates				*
*-------------------------------------------------------*

DSPHostStat		=	$FFFFA202
DSPHost32		=	$FFFFA204
DSPHost24		=	$FFFFA205
DSPHost16		=	$FFFFA206
DSPHost8		=	$FFFFA207

*-------------------------------------------------------*
*	DSP function numbers				*
*-------------------------------------------------------*

GETWORDSIZE		=	7
EXECPROG		=	13

*-------------------------------------------------------*
*	DSP communications				*
*-------------------------------------------------------*

dspexec	macro
	moveq		#1,d1
	move.l		#(\1_e-\1)/3,d0
	lea		\1,a0
	jsr		DspExecProg
	endm

dspwaitwrite		macro
	ifge		(compat_level-\0)
	ifeq		NARG
.ww\@:	btst		#1,$FFFFA202.w
	beq.s		.ww\@
	elseif	
.ww\@:	btst		#1,\1
	beq.s		.ww\@
	endc
	endc
	endm

dspwaitread		macro
	ifge		(compat_level-\0)
	ifeq		NARG
.wr\@:	btst		#0,$FFFFA202.w
	beq.s		.wr\@
	elseif	
.ww\@:	btst		#0,\1
	beq.s		.ww\@
	endc
	endc
	endm

dspwrite		macro
	ifeq		'\0'-'r'
	move.l		\1,d0
	dspwaitwrite.0	\2
	move.w		d0,$FFFFA206.w
	swap		d0
	dspwaitwrite.0	\2
	move.w		d0,$FFFFA206.w
	elseif
	dspwaitwrite.0
	ifeq		'\0'-'w'
	move.w		\1,$FFFFA206.w
	elseif
	ifeq		'\0'-'l'
	move.l		\1,$FFFFA204.w
	elseif
	ifeq		'\0'-'b'
	move.b		\1,$FFFFA207.w
	endc
	endc
	endc
	endc
	endm

dspread			macro
	ifeq		'\0'-'r'
	elseif
	dspwaitread.0
	ifeq		'\0'-'w'
	move.w		$FFFFA206.w,\1
	elseif
	ifeq		'\0'-'l'
	move.l		$FFFFA204.w,\1
	elseif
	ifeq		'\0'-'b'
	move.b		$FFFFA207.w,\1
	endc
	endc
	endc
	endc
	endm

dspcall	macro
	moveq		\1,d0
	add.l		drvr_start,d0
	move.w		d0,-(sp)
	trap		#14
	endm

*-------------------------------------------------------*
IsDspDrv:
*-------------------------------------------------------*
	move.l		#500,drvr_start		;rev 1-2
	bsr		DspGetWordSize
	cmp.w		#500+GETWORDSIZE,d0
	bne.s		.ok
	move.l		#96,drvr_start		;rev 3-4
	bsr		DspGetWordSize
	cmp.w		#96+GETWORDSIZE,d0
	bne.s		.ok
.no:	moveq		#0,d0
.ok:	rts

*-------------------------------------------------------*
DspGetWordSize:
*-------------------------------------------------------*
	move.l		a2,-(sp)
	dspcall		#GETWORDSIZE
	addq.w		#2,sp
	move.l		(sp)+,a2
	rts

*-------------------------------------------------------*
DspExecProg:
*-------------------------------------------------------*
	move.l		a2,-(sp)
	move.w		d1,-(sp)
	move.l		d0,-(sp)
	move.l		a0,-(sp)
	dspcall		#EXECPROG
	lea		12(sp),sp
	move.l		(sp)+,a2
	rts

*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

drvr_start:		ds.l	1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
