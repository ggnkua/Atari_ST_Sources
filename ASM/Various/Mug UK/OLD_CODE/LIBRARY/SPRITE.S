;---------------------------------------------------------------------
; Moving Sprite Bootsector - Written by Mike Mee (Colour version)
;
; Bootsector Installer Source Code by Merlin
; Coding by MUG U.K
;---------------------------------------------------------------------

* Ask which drive is to be protected

guard	pea	guardmess
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
		
* Wait for the 'a', 'b' and 'esc' keys.

_kloop	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	D0
	
	cmp.b	#1,D0	ESC key
	beq.s	_exit
	cmp.b	#$1e,D0	'a' key
	beq.s	guarda
	cmp.b	#$30,D0	'b' key
	bne.s	_kloop
	
guardb	move.w	#1,guarddrv+2
	bra.s	do_guard
	
guarda	clr.w	guarddrv+2

do_guard
	pea	guardclr		Display 'Writing'
	move.w	#$09,-(sp)
	trap	#1
	addq.l	#6,sp
		
* Read the current bootsector and insert the main data into ours

	bsr.s	read
		
	lea	bootbuffer,A0
	lea	mybuffer,A1
	moveq	#29,D0
cloop1	move.b	(A0)+,(A1)+
	dbf	D0,cloop1
	move.w	#$601C,mybuffer		Add BSR code
		
* Calculate new checksum

	lea	mybuffer,A0		My bootsector
	moveq	#0,D7			Clear checksum count
	move.w	#254,D5
calop	add.w	(A0)+,D7		Make checksum in D7
	dbf	D5,calop
	move.w	#$1234,D0
	sub.w	D7,D0
	move.w	D0,(A0)			write checksum makeup

	bsr.s	write
	bra	guard
	
_exit	clr.w	-(sp)
	trap	#1

*****************************************************************
* Subroutines to read and write the bootsector

read	moveq	#8,D0
	lea	bootbuffer,A0
	bra.s	perform
write	moveq	#9,D0
	lea	mybuffer,A0

perform	move.w	#1,-(sp)		Read 1 sector
	clr.w	-(sp)			Side 0
	clr.w	-(sp)			Track 0
	move.w	#1,-(sp)		Sector 1
guarddrv
	move.w	#0,-(sp)		Drive A
	clr.l	-(sp)			Filler
	move.l	A0,-(sp)		Address of buffer
	move.w	D0,-(sp)		Floprd/flopwr
	trap	#14
	lea	20(sp),sp
	rts
		
*****************************************************************
guardmess
	dc.b	27,69
	dc.b	"+----------------------------------------+",13,10
	dc.b	"| 'Moving Sprite' Bootsector by Mike Mee |",13,10
	dc.b	"|             (colour version)           |",13,10
	dc.b	"|                                        |",13,10
	dc.b	"|     Written in 68000 on 15/03/1991     |",13,10
	dc.b	"+----------------------------------------+",13,10,10,10

	dc.b	"Insert disk to be installed.",13,10,10

	dc.b	"Press 'A' to write to the disk in drive A",13,10
	dc.b	"      'B' to write to the disk in drive B",13,10
	dc.b	"     'ESC' to abort.",0

guardclr
	dc.b	13,10,10,10
	dc.b	"Installing ... Hang On !!",0
		
	even
	
* 512 byte buffer for bootsector read from disk
	
bootbuffer	ds.b	512

*****************************************************************
* Pre constructed boot sector minus statistics

bootst
mybuffer	ds.b	30

buffcode
screen1	equ	$70000
screen2	equ	$78000

set_pal	move.w	#$007,$ff8240	; blue background
	move.w	#$777,$ff8242	; white graphic

mainloop
;
; Flip Screens
;
flip	move.l	visscreen,d0
	move.l	currentscreen,visscreen
	move.l	d0,currentscreen

	move.w	#-1,-(sp)
	move.l	visscreen,-(sp)
	move.l	currentscreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	bsr	waitvbl		;wait for vertical blank
;
; Clear Screen
;
cls	move.l	currentscreen,a0	;erase screen data
	moveq	#0,d0
	move.w	#200-1,d7
sf	rept	40
	move.l	d0,(a0)+
	endr
	dbra	d7,sf

	bsr	sprite

readkey	move.w	#$00ff,-(sp)
	move.w	#$0006,-(sp)	;function 6-readkey
	trap	#1		;wait for a key
	addq.w	#4,sp		;return key in d0
	
	cmp.b	#" ",d0		;space pressed ?
	bne	mainloop		;no, loop

res_pal	move.w	#$777,$ff8240	; white background
	move.w	#$700,$ff8242	; red graphic


exit	rts

waitvbl	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp
	rts

;display sprite at d0,d1 (x,y)

sprite
	addq.w	#1,xpos
*	addq.w	#1,ypos
	and.w	#$007f,xpos
	and.w	#$007f,ypos

	move.w	xpos,d0
	move.w	ypos,d1
	mulu.w	#160,d1
	move.l	currentscreen,a1
	add.w	d1,a1
	move.w	d0,d6
	lsr.w	#1,d0
	and.w	#$fff8,d0
	add.w	d0,a1		; screen address
	and.w	#$000f,d6		; shifts ?? ($0f)
	moveq	#64-1,d7		; no. of lines in sprite (16)
	lea	spritedata(pc),a0

;a0=data  a1=screen  d6=shifts  d7=loop

drawit	moveq	#0,d0
	move.w	(a0)+,d0
	ror.l	d6,d0
	or.w	d0,(a1)
	swap	d0
	or.w	d0,32(a1)		;8
	lea	160(a1),a1
	dbra	d7,drawit
	rts

**************************************************************************

xpos	dc.w	0
ypos	dc.w	0

;graphics data

spritedata
	dc.w	%1111001110011111
	dc.w	%1111010101011111
	dc.w	%1111011011011111
	dc.w	%1111011111011111
	dc.w	%1111111111111111
	dc.w	%1111011111011111
	dc.w	%1111011111011111
	dc.w	%1111011111011111
	dc.w	%1111000000011111
	dc.w	%1111111111111111
	dc.w	%1111000000011111
	dc.w	%1111011111111111
	dc.w	%1111011100011111
	dc.w	%1111011111011111
	dc.w	%1111000000011111
	dc.w	%1111111111111111

;reserved space for variables

visscreen	
	dc.l	screen1

currentscreen
	dc.l	screen2

blanks	ds.l	30

