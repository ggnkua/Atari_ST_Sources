*=======================================================*
*	Macros: [update 11/02/96]			*
*=======================================================*

alignment		=	2

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

align	macro
.o\@	=		*
	ds.b		(alignment-((.o\@)&(alignment-1)))&(alignment-1)
	endm

txtlong	macro
	text
	align		text_start
	endm

bsslong	macro
	bss
	align		bss_start
	endm

datlong	macro
	data
	align		data_start
	endm

fixcase	macro
	cmp.b		#'A',\1
	blo.s		.no\@
	cmp.b		#'Z',\1
	bhi.s		.no\@
	and.w		#$FF,\1
	add.w		#'a'-'A',\1
.no\@:	
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

*-------------------------------------------------------*
*	Display management 				*
*-------------------------------------------------------*

vsync	macro
.wv\@:	tst.w		timer
	bne.s		.wv\@
	move.w		#vbilock,timer
	endm

doublebuffer		macro
	lea		screen_ptrs,a0
	move.l		(a0),d0
	move.l		4(a0),(a0)
	move.l		8(a0),4(a0)
	move.l		d0,8(a0)
	lsr.w		#8,d0
	move.l		d0,$ffff8200.w
	move.b		#0,$ffff820d.w
	endm

*-------------------------------------------------------*
*	Memory management				*
*-------------------------------------------------------*

Malloc	macro

	move.l		\1,d0
	bsr		allocate_chunk
	tst.l		d0

;	move.l		\1,d0
;	addq.l		#4-1,d0
;	and.l		#-4,d0
;	move.l		d0,-(sp)
;	move.w		#$48,-(sp)
;	trap		#1
;	addq.l		#6,sp
;	tst.l		d0
;	beq.s		.err\@
;	addq.l		#4-1,d0
;	and.l		#-4,d0
;.err\@:

	endm

Mxalloc	macro
	move.l		\1,d0
	addq.l		#4-1,d0
	and.l		#-4,d0
	move.w		#\2,-(sp)
	move.l		d0,-(sp)
	move.w		#68,-(sp)
	trap		#1
	addq.l		#8,sp
	tst.l		d0
	beq.s		.err\@
	addq.l		#4-1,d0
	and.l		#-4,d0
.err\@:
	endm


Mfree	macro		address

	move.l		\1,d0
	bsr		deallocate_chunk

;	move.l		\1,-(sp)
;	move.w		#73,-(sp)
;	trap		#1
;	addq.l		#6,sp

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
