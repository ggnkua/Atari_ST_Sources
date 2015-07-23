; Many people made own Gemdos Xbios & Bios Library
; Why not make another one . . . . Empty Head :)


;v 0.03


;~~~~~~~~~~~~ Gemdoses in Alphabetical order ~~~~~~~~~~~~~~

Exit	macro
	clr.w -(a7)
	trap #1
	endm	

;for immediate acces
Malloc 	macro \1	;allocate memory (All GEMDOS v)
	move.l #\1,-(a7)
	move.w #72,-(a7)
	trap #1
	addq.l #6,a7
	endm

;for data registers
Malloc2 	macro \1	;allocate memory (All GEMDOS v)
	move.l \1,-(a7)
	move.w #72,-(a7)
	trap #1
	addq.l #6,a7
	endm




Mfree	macro \1	;free allocate memory (All GEMDOS v)
	move.l \1,-(a7)
	move.w #73,-(a7)
	trap #1
	addq.l #6,a7
	endm

Wait_Key	macro
	movem.l a0-a1/d0-d1,-(a7)
	move.w #7,-(a7)
	trap #1
	addq.l #2,a7
	movem.l (a7)+,a0-a1/d0-d1
	endm

MX_STRAM	equ 0 ;allocate only ST-RAM
MX_TTRAM	equ 1 ;allocate only TT-RAM
MX_PREFSTRAM equ 2 ;allocate either, preffering ST-RAM
MX_PREFTTRAM equ 3 ;allocate either, preffering TT-RAM


;for immediate acces
Mxalloc	macro \1,\2
MXALLOC\2:	cmp.w #$1900,SVERSION
	blo.s .MALLOC\2
	move.w #\1,-(a7)
	move.l #\2,-(a7)
	move.w #$44,-(a7)
	trap #1
	addq.l #8,a7
	bra.s .ALLMALLOC\2
.MALLOC\2:	Malloc \2
.ALLMALLOC\2:
	endm

;for data registers
Mxalloc2	macro \1,\2,\3
MXALLOC\3:	cmp.w #$1900,SVERSION
	blo.s .MALLOC\3
	move.w #\1,-(a7)
	move.l \2,-(a7)
	move.w #$44,-(a7)
	trap #1
	addq.l #8,a7
	bra.s .ALLMALLOC\3
.MALLOC\3:	Malloc2 \2
.ALLMALLOC\3:
	endm

	
Supervisor	macro
	clr.l -(a7)
	move.w #32,-(a7)
	trap #1
	addq.l #6,a7
	move.l d0,STACK_BACK

	section bss
STACK_BACK:	ds.l 1 ;backup because Supervisor
	section text
	endm

Sversion    macro
	move.w #48,-(a7) ;take GEMDOS v
	trap #1
	addq.l #2,a7
	move.w d0,SVERSION
	section bss
SVERSION:	ds.w 1
	section text
 	endm

	
Unsupervisor	macro
	move.l STACK_BACK,-(a7)
	move.w #32,-(a7)
	trap #1
	addq.l #6,a7
	endm

;~~~~~~~~~~~~ Xbioses in Alpabetical order ~~~~~~~~~~~~~~~~

Logbase	macro	;get a Logbase VDI adress
	move.w #3,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,LOGBASE
	endm

Physbase	macro	;get a Physical adress of Shifter
	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,PHYSBASE
	endm	

Random	macro	;randomize 24-bit number
	move.w #$11,-(a7)
	trap #14
	addq.l #2,a7
	endm

Random_other macro \1   ;randomize number in area 0-\1 (maximally 65535)
	Random
	swap d0 ;convert to word
	clr.w d0
	swap d0
	divu #\1,d0
	swap d0 ;rest is important for us
	endm

;	Fwrite ADRESS,#BYTES
Fwritedata	macro location,length ;write data into file
	pea	\1
	move.l	\2,-(a7)
	move.w	FILE_HANDLE,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	endm

Fcreate	macro path
	move.w	#$0,-(sp)		;create file
	pea	\1		
	move.w	#$3C,-(sp)
	trap	#1
	lea	8(a7),a7
	move.w	d0,FILE_HANDLE
	endm

Fclose	macro
	move.w FILE_HANDLE,-(a7) ;close file
	move.w #$3e,-(a7)
	trap #1
	addq.l #4,a7
	endm
		

;~~~~~~~~~~~~ Bioses in Alphabetical order ~~~~~~~~~~~~~~~~
Kbshift	macro
	move.w #-1,-(a7)
	move.w #11,-(a7)
	trap #13
	addq.l #4,a7
	endm

	rsreset
K_rshift	rs.b 1
K_lshift	rs.b 1
K_ctrl	rs.b 1
K_alt	rs.b 1
K_capslock	rs.b 1
K_clrhome	rs.b 1
K_Insert	rs.b 1

K_RSHIFT	equ 1<<K_rshift
K_LSHIFT	equ 1<<K_lshift
K_CTRL	equ 1<<K_ctrl
K_ALT	equ 1<<K_alt
K_CAPSLOCK	equ 1<<K_capslock
K_CLRHOME	equ 1<<K_clrhome
K_INSERT	equ 1<<K_Insert


;~~~~~~~~~~~~~~~~ My System operation ~~~~~~~~~~~~~~~~~~~~~
;--------------------------------------------------------------------------
; CookieJar Check to see if we have DMA sound.(i.e STE/TT)
; Return D1=0 if DMA sound is not available on this machine. (else d1=-1)
;--------------------------------------------------------------------------

SoundTest		macro 
		ifd STFLAG ;v pripade ST Flagu, nezapinej DMA zvuk
		bra .no_dmasnd
		endc

		move.l $5A0.W,d0		; get cookie jar ptr
		beq.s .no_dmasnd			;; nul ptr = no cookie jar
		move.l d0,a0			;; (no cookie jar= no dma snd)
.search_next	tst.l (a0)			
		beq.s .no_dmasnd
		cmp.l #'_SND',(a0)		; cookie found?
		beq.s .search_found
		addq.l #8,a0
		bra.s .search_next
.search_found	move.l 4(a0),d0			; get _SND const.
		btst #1,D0
		beq.s .no_dmasnd
		move.w #-1,STE_FLAG			; DMA SOUND FOUND!
		bra.s .cont
.no_dmasnd		move.w #0,STE_FLAG			; NO DMA SOUND!
.cont		rts

		dc.b 'TEST DMA OR YAMAHA'
		dc.b 'by Martin Grifith'
	     even

STE_FLAG: ds.w 1
		endm


ComputerTest	macro
		clr.w d0
		move.l $5A0.W,d1		; get cookie jar ptr
		beq.s .WE_GOTIT			; nul ptr = no cookie jar
		move.l d1,a0		; (no cookie jar= ST)
.search_next	tst.l (a0)			
		beq.s .WE_GOTIT
		cmp.l #'_MCH',(a0)		; cookie found?
		beq.s .search_found
		addq.l #8,a0
		bra.s .search_next
.search_found	move.l 4(a0),d0			; get _SND const.
		swap d0
		cmp.w #3,d0
		beq.s .ADD2
		cmp.w #2,d0
		beq.s .ADD2
		cmp.w #1,d0
		bne.s .WE_GOTIT ;zero is zero :)
		swap d0
		cmp.w #16,d0
		beq.s .ADD2
		cmp.w #0,d0 ;one is one STE :)
		add.w #1,d0 ;ST BOOK uaaaa??
		bra.s .WE_GOTIT
.ADD2:		add.w #2,d0		
.WE_GOTIT:		move.w d0,MACHINE
		rts

MACHINE:		ds.w 1	
		endm


Mxstram	macro	\1
	Sversion   ;allocate ST Ram by use Mxalloc, (GEMDOS<0.19 => Malloc)
	cmp.w #$1900,d0
	bhs .XALLOC
	Malloc \1
	bra.s .MADE
.XALLOC:	Mxalloc #MX_STRAM,\1
.MADE:	
	endm


	
	section text
	bra.s AFTERLOG
LOGBASE:	ds.l 1
PHYSBASE:	ds.l 1
FILE_HANDLE: ds.w 1
AFTERLOG:
	section text
