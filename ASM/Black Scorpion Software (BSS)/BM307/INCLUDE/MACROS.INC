*=======================================================*
*	Macros: updated 12/06/97			*
*=======================================================*

*-------------------------------------------------------*
*	CPU stack management				*
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

*-------------------------------------------------------*
*	Section alignment				*
*-------------------------------------------------------*

align	macro
	ifd		use_alignment
.o\@	=		*
	ds.b		(alignment-((.o\@)&(alignment-1)))&(alignment-1)
	elseif
	even
	endc
	endm

txtlong	macro
	align
	text
	align
	endm

bsslong	macro
	align
	bss
	align
	endm

datlong	macro
	align
	data
	align
	endm

*-------------------------------------------------------*
*	String macros					*
*-------------------------------------------------------*

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

;	move.l		(a0),d0

	lsr.w		#8,d0
	move.l		d0,$ffff8200.w
	move.b		#0,$ffff820d.w
	endm

*-------------------------------------------------------*
*	Memory management				*
*-------------------------------------------------------*

Mxalloc	macro
	move.w		\2,-(sp)
	move.l		\1,-(sp)
	move.w		#68,-(sp)
	trap		#1
	addq.l		#8,sp
	endm

Mfree	macro
	move.l		\1,-(sp)
	move.w		#73,-(sp)
	trap		#1
	addq.l		#6,sp
	endm

*-------------------------------------------------------*
*	Processor data operations			*
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

cpstruct		macro
.ls\@	set		(\1)/4
.ws\@	set		((\1)-(.ls\@*4))/2
.bs\@	set		(\1)-(.ls\@*4)-(.ws\@*2)
	ifne		.ls\@
	ifgt		.ls\@-1
	moveq		#.ls\@-1,\2
.cpl\@:	move.l		(\3)+,(\4)+
	dbra		\2,.cpl\@
	elseif
	move.l		(\3)+,(\4)+
	endc
	endc	
	ifne		.ws\@
	move.w		(\3)+,(\4)+
	endc
	ifne		.bs\@
	move.b		(\3)+,(\4)+
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
	movem.l		d0/a0,-(sp)
	move.l		\1,-(sp)
	move.w		#9,-(sp)
	trap		#1
	addq.l		#6,sp
	movem.l		(sp)+,d0/a0
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

