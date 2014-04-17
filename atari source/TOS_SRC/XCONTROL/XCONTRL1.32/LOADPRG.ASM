; WARNING- THIS CODE IS INCORRECT AND TRASHES BSS IF THE FIXUP
; INFORMATION IS TOO LARGE.
; THE CODE IS CORRECTED IN 'LOADCPX.C'
;
; loadprg.s	Load and fixup a object file	5/21/87	RMS
;		Modified for CPX loader		1/29/90 CJG 
;		Added Fseek to get past header  2/21/90 CJG
;
; Assemble with Mad Mac 
; Form:   mac loadprg.asm
; Note:   CPX HEADER FILE size is 512 bytes - $200
;

.include	atari
.include	bios

CPXSIZE		=	$200		; CPX HEADER SIZE

; header structure
magic		=	0
tsize		=	magic+2
dsize		=	tsize+4
bsize		=	dsize+4
ssize		=	bsize+4
xxx1		=	ssize+4
xxx2		=	xxx1+4
xxx3		=	xxx2+4
headsize	= 	xxx3+2

;	base page structure
tbase		=	0
tlen		=	tbase+4
dbase		=	tlen+4
dlen		=	dbase+4
bbase		=	dlen+4
blen		=	bbase+4
bpsize		=	blen+4		; size of basepage structure


		.globl	loadprg		; routine to load and relocate prg

;
; loadprg()	Given a pointer to a ascii file name load the prg.
;		Assume we are at the directory to fine the file to load.
;		Return driver load address for sucess or 0 for
;		failure.
;		a0 pointer to program file name

loadprg:
;	move.l	4(sp),a0	 pointer to prg file name
	movem.l a1-a5/d1-d5,-(sp)

	Fopen	a0,#RDONLY	; open file name
	tst.w	d0
	bmi	exit		; If no handle exit on a error note

	move.w	d0,fd		; save file descriptor

	
	Fseek	#CPXSIZE,fd,#0	; Seek past the cpx header
	tst.w	d0
	bmi	exit		; error of some kind occurred

	move.w  fd, d0		; restore file handle

	sub.l	#headsize,sp	; get room on stack for header
	move.l	sp,headaddr
	bsr	loadit		; returns driver addr or 0 on error
	add.l	#headsize,sp	; cleanup buffers

	move.l	d0,d3		; save return
	Fclose	fd		; pop and close file handle
	move.l	d3,d0		; restore return
	movem.l (sp)+,a1-a5/d1-d5
	rts

;
; loadit	Given a handle (.w) in d0 load the puppy in
;		and relocate it. Return 0 if error or load addr
loadit:
	Fread	d0,#headsize,headaddr	; read in file header

	cmpi.l	#headsize,d0		; If(not all header read) exit
	bne	exit

	move.l	headaddr,a0		; If(file not executable) exit
	cmp.w	#$601a,magic(a0)
	bne	exit

	bsr	getsize			; returns d0 = size of driver
	tst.l	d0
	beq	exit

	Malloc	d0
	move.l	d0,prgbpage		; If(no memory for prg) exit
	beq	exit

	bsr	setbp			; set up the prg basepage

	bsr	getprg			; get prg's text segment
	bmi	.merrexit

	bsr	prgfix
	bmi	.merrexit		; Error has occured

	bsr	clrbss			; clr the calling routines bss

	move.l	prgbpage,d0		; return drivers load addr
	rts	

.merrexit:
	Mfree prgbpage			; error occured free up malloced
	; FALL THROUGH
exit:
	clr.l	d0			; return (-) on error
	movem.l (sp)+,a1-a5/d1-d5
	rts

;
; errexit	Common error exit routine
;
errexit:
	move.l	#-1,d0
	movem.l (sp)+,a1-a5/d1-d5
	rts

;
; clrbss	Rotuine to zero the prg's bss
;
clrbss:
	move.l	prgbpage,a0	; prg's basepage
	move.l	bbase(a0),a1	; prg's bss
	move.l	blen(a0),d0	; it's length
	bra	.clr
.cnxt:
	move.b	#0,(a1)+
.clr:
	dbra	d0,.cnxt
	rts

;
; prgfix	Routine to relocate the prg in memory.
;
prgfix:
	move.l	prgbpage,a0		; a0 -> prg base page
	move.l	tbase(a0),a3		; a3 -> to text code
	move.l	bbase(a0),a4		; a4 -> to bss "scratch" area

	move.l	a3,d3			; d3 = text code addr

	move.l	(a4)+,a0		; first fixup offset
	beq	.exit			; If(0) no fixups

	add.l	a0,a3			; a3 -> first fixup
	add.l	d3,(a3)			; relocate it 
	clr.w	d0
.nxt:
	move.b	(a4)+,d0		; get fixup
	beq	.exit			; No more we are done

	cmp.b	#1,d0
	bne.s	.1
	add.w	#$00fe,a3		; bump fixup pointer
	bra.s	.nxt
.1:
	add.l	d0,a3			; last fixup
	add.l	d3,(a3)			; relocate it
	bra	.nxt
.exit:
	rts

;
; getprg	Routine to read the prg (skipping symbols) into ram.
;
getprg:
	move.l	prgbpage,a3		; a3 -> prg base page
	move.l	tbase(a0),a4		; a4 -> start of text segment

	move.l	headaddr,a5		; a0 -> prg header
	move.l	tsize(a5),d3
	add.l	dsize(a5),d3		; d3 = size of prg

	Fread	fd,d3,a4		; read in text and data segments
	cmp.l	d0,d3
	bne	errexit			; Exit on error

	move.l	ssize(a5),d0
	Fseek	d0,fd,#1		; seek past symbol table

	move.l	bbase(a3),a0		; a0 -> prg's bss

	Fread	fd,#$7fffffff,a0	; get rest of fixup info
	tst.w	d0
	beq	errexit			; error reading fixup info

	rts

;
; setbp		routine to set up the prg's base page
;		Input	d0 = prgbpage address
setbp:
	move.l	d0,a0			; a0 -> prg base page
	move.l	headaddr,a2		; a2 -> prg header

	add.l	#$1C,d0			; d0 -> prg's text segment
					; was #$100
	move.l	d0,tbase(a0)
	move.l	tsize(a2),tlen(a0)

	add.l	tlen(a0),d0		; d0 -> prg's data segment
	move.l	d0,dbase(a0)
	move.l	dsize(a2),dlen(a0)

	add.l	dlen(a0),d0		; d0 -> prg's bss
	move.l	d0,bbase(a0)
	move.l	bsize(a2),blen(a0)

	rts

;
; getsize	return the size of the prg in d0
;		Input	a0 -> file header
getsize:
	move.l	#$1C,d0			; d0 = basepage size
					; used to be #$100
	add.l	tsize(a0),d0		; + text
	add.l	dsize(a0),d0		; + data
	add.l	bsize(a0),d0		; + bss
	rts


	.bss
headaddr:	.ds.l	1	; address of our header buffer
prgbpage:	.ds.l	1	; address of the prg base page
fd:		.ds.w	1	; file descriptor
	.end
