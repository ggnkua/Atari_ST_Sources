; ASCII Text Convert Routine by Seb/The REMOVERS
; for use with C, Pascal or Basic !!!
; INPUT :
;	adr_txt.L,size_txt.L,input.W,output.W
; OUTPUT :
;	0 if all is OK
;	-1 if error
; Source for ASSEMBLE ( from Brainstorm )
; Values of input ( input format ) and output ( output format )
;	INPUT :
;		0 <-> ATARI
;		1 <-> MAC
;		2 <-> Windows
;		3 <-> DOS
;		4 <-> Unix

* Warning : switch only one of this switches to assemble *
C:	equ	1
PASCAL:	equ	0
BASIC:	equ	0

	MC68000
	
	IFNE	C
		output	'asc_c.o'
	ENDC
	IFNE	PASCAL
		output	'asc_pas.o'
	ENDC
	IFNE	BASIC
		output	'asc_bas.bin'
	ENDC
	
	IFEQ	BASIC
		opt	l1
		export	convert
	ENDC

MAX_FORMAT:	equ	4
* D1-D7/A0-A6 are saved on the stack *
OFFSET:	equ	(7+7)*4
	
convert:
	movem.l	d1-d7/a0-a6,-(sp)
	IFEQ	PASCAL
		CARGS	adr_txt.l,size_txt.l,input.w,output.w
	ELSE
		PARGS	adr_txt.l,size_txt.l,input.w,output.w	
	ENDC
	move.l	OFFSET+adr_txt(sp),a0
	move.l	OFFSET+size_txt(sp),d0
	lea	(a0,d0.l),a1
	move.w	OFFSET+input(sp),d1
	blt.s	.error
	move.w	OFFSET+output(sp),d2
	blt.s	.error
	cmp.w	#MAX_FORMAT,d1
	bgt.s	.error
	cmp.w	#MAX_FORMAT,d2
	bgt.s	.error
	cmp.w	d1,d2
	beq.s	.end
	lea	index(pc),a2
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a2,d1.w),d1
	lea	(a2,d1.l),a2
	lsl.w	#7,d2
	lea	(a2,d2.w),a2
	clr.w	d0
.loop_convert:
	move.b	(a0)+,d0
	bclr.l	#7,d0
	beq.s	.no_change
	move.b	(a2,d0.w),-1(a0)
.no_change:
	cmp.l	a0,a1
	bgt.s	.loop_convert
.end:
	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	rts	
.error:
	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#-1,d0
	rts	
informations:
	dc.b	'ASCII Text Converter by Seb/The REMOVERS'	
	even
index:
	dc.l	ATARI-index,MAC-index,WINDOWS-index,DOS-index,UNIX-index
ATARI:
	incbin	'ID'
	incbin	'ATA_MAC'
	incbin	'ATA_WIN'
	incbin	'ATA_DOS'
	incbin	'ATA_UNX'
MAC:
	incbin	'MAC_ATA'
	incbin	'ID'
	incbin	'MAC_WIN'
	incbin	'MAC_DOS'
	incbin	'MAC_UNX'
WINDOWS:
	incbin	'WIN_ATA'
	incbin	'WIN_MAC'
	incbin	'ID'
	incbin	'WIN_DOS'
	incbin	'WIN_UNX'
DOS:
	incbin	'DOS_ATA'
	incbin	'DOS_MAC'
	incbin	'DOS_WIN'
	incbin	'ID'
	incbin	'DOS_UNX'
UNIX:
	incbin	'UNX_ATA'
	incbin	'UNX_MAC'
	incbin	'UNX_WIN'
	incbin	'UNX_DOS'
	incbin	'ID'
