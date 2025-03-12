*=======================================================*
*	Macros:						*
*=======================================================*

*-------------------------------------------------------*
*	Stack management				*
*-------------------------------------------------------*

push	macro
	move.\0		\1,-(sp)
	endm

pop	macro
	move.\0		(sp)+,\1
	endm

pushall	macro
	movem.l		d0-a6,-(sp)
	endm

popall	macro
	movem.l		(sp)+,d0-a6
	endm

fixcase	macro
	cmp.b		#'a',\1
	blo.s		.ok\@
	cmp.b		#'z',\1
	bhi.s		.ok\@
	and.w		#$FF,\1
	sub.w		#'a'-'A',\1		
.ok\@:	
	endm	

sclock	macro
	move.l		clock200,.l_time(sp)
	move.l		\1,.l_delay(sp)
	move.l		\2,.l_repeat(sp)
	endm

clock	macro
	move.l		clock200,d0
	cmp.l		.l_time(sp),d0
	blo.\0		\1
	add.l		.l_delay(sp),d0
	move.l		d0,.l_time(sp)	
	move.l		.l_repeat(sp),.l_delay(sp)
	endm

sclick	macro
	move.l		\1,d0
	add.l		clock200,d0
	move.l		d0,.l_time(sp)
	endm

click	macro
	ifeq		NARG-1
	move.l		clock200,d0
	elseif
	move.l		\2,d0
	endc
	cmp.l		.l_time(sp),d0
	bhi.\0		\1
	endm

rgbw8	macro
	dc.w		(((\1)>>3)<<11)|(((\2)>>2)<<5)|((\3)>>3)
	endm	

rgbw6	macro
	dc.w		(((\1)>>1)<<11)|((\2)<<5)|((\3)>>1)
	endm	

alignment		=	4

align	macro
	ds.b		(alignment-((*)&(alignment-1)))&(alignment-1)
	endm

*-------------------------------------------------------*
*	DSP communications				*
*-------------------------------------------------------*

dspexec	macro
	moveq		#1,d1
	move.l		#(\1_e-\1)/3,d0
	lea		\1,a0
	jsr		DspExecProg
	endm

dspload	macro
	cmp.l		#\1,current_dsp
	beq.s		.n\@
	move.l		#\1,current_dsp
	st		dspgaurd_sem
	movem.l		d0-d2/a0-a2,-(sp)
	moveq		#1,d1
	move.l		#(\1_e-\1)/3,d0
	lea		\1,a0
	jsr		DspExecProg
;	jsr		DspSync
	movem.l		(sp)+,d0-d2/a0-a2
	sf		dspgaurd_sem
.n\@
	endm

dspwaitwrite		macro
	ifeq		NARG
.ww\@:	btst		#1,$FFFFA202.w
	beq.s		.ww\@
	elseif	
.ww\@:	btst		#1,\1
	beq.s		.ww\@
	endc
	endm

dspwaitread		macro
	ifeq		NARG
.wr\@:	btst		#0,$FFFFA202.w
	beq.s		.wr\@
	elseif	
.ww\@:	btst		#0,\1
	beq.s		.ww\@
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

*-------------------------------------------------------*
*	Memory management				*
*-------------------------------------------------------*

Malloc	macro
	move.l		\1,-(sp)
	move.w		#$48,-(sp)
	trap		#1
	addq.l		#6,sp
	tst.l		d0
	endm

Mxalloc	macro
	move.w		\2,-(sp)
	move.l		\1,-(sp)
	move.w		#68,-(sp)
	trap		#1
	addq.l		#8,sp
	tst.l		d0
	endm

Mfree	macro		address
	move.l		\1,-(sp)
	move.w		#73,-(sp)
	trap		#1
	addq.l		#6,sp
	endm

*-------------------------------------------------------*
*	Processor format operations			*
*-------------------------------------------------------*

imov	macro
	ifeq		'\0'-'l'
	move.l		\1,d0
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	move.l		d0,\2
	elseif
	ifeq		'\0'-'w'
	move.w		\1,d0
	ror.w		#8,d0
	move.w		d0,\2
	elseif
	move.b		\1,\2
	endc
	endc
	endm

*-------------------------------------------------------*
*	I/O macros					*
*-------------------------------------------------------*

Cconout	macro		char
	move.w		\1,-(sp)
	move.w		#2,-(sp)
	trap		#1
	addq.l		#4,sp
	endm

Crawcin	macro
	move.w		#7,-(sp)
	trap		#1
	addq.l		#2,sp
	endm
		
Cconws	macro		string
	move.l		\1,-(sp)
	move.w		#9,-(sp)
	trap		#1
	addq.l		#6,sp
	endm

Fopen	macro		fname,mode
	move.w		\2,-(sp)
	move.l		\1,-(sp)
	move.w		#61,-(sp)
	trap		#1
	addq.l		#8,sp
	tst.w		d0
	endm

Fclose	macro		handle
	move.w		\1,-(sp)
	move.w		#62,-(sp)
	trap		#1
	addq.l		#4,sp
	endm

Fread	macro		handle,count,buffer
	move.l		\3,-(sp)
	move.l		\2,-(sp)
	move.w		\1,-(sp)
	move.w		#63,-(sp)
	trap		#1
	lea		12(sp),sp
	endm

Fseek	macro		offset,handle,seekmode
	move.w		\3,-(sp)
	move.w		\2,-(sp)
	move.l		\1,-(sp)
	move.w		#66,-(sp)
	trap		#1
	lea		10(sp),sp
	endm

*-------------------------------------------------------*
