;---------------------------------------------------------------------
;	Plugin-based multipalette picture viewer.
;	by Zerkman / Sector One
;	mode 2: 320x199, blitter based, displays 56 colors per scanline
;		with uniform repartition of color change positions.
;---------------------------------------------------------------------

; Copyright (c) 2012-2013 Francois Galea <fgalea at free.fr>
; This program is free software. It comes without any warranty, to
; the extent permitted by applicable law. You can redistribute it
; and/or modify it under the terms of the Do What The Fuck You Want
; To Public License, Version 2, as published by Sam Hocevar. See
; the COPYING file or http://www.wtfpl.net/ for more details.

; MPP file format:
; 3 bytes : "MPP"
; 1 byte  : mode (0-3)
; 1 byte  : flags (bit 0: STE palette,  bit 1: extra palette bit, bit 2: double image)

; plugin structure entry offsets
plug_width			equ	0
plug_height			equ	2
plug_colors_per_scanline	equ	4
plug_stored_colors_per_scanline	equ	6
plug_line_size			equ	8
plug_timera_data		equ	10
plug_flags			equ	12
plug_pal_adr			equ	14
plug_init			equ	18
plug_palette_unpack		equ	22
plug_timera			equ	26

dta_reserved			equ	0
dta_attrib			equ	21
dta_time			equ	22
dta_date			equ	24
dta_length			equ	26
dta_fname			equ	30

fa_rdonly			equ	$01
fa_hidden			equ	$02
fa_system			equ	$04
fa_volume			equ	$08
fa_dir				equ	$10
fa_archive			equ	$20

flag_steonly			equ	$1

	text

	bsr	get_machine_type
	move	d0,mch		; 0:ST, 1:STe, 2:MSTe, -1:unsupported
	bmi	unsup_machine_error

	move	#47,-(sp)	; Fgetdta
	trap	#1
	addq.l	#2,sp
	move.l	d0,a6		; dta

	move.l	a6,a0
	moveq	#0,d0
	move.b	(a0)+,d0	; command line length
	beq.s	scandir		; if empty command line, scan the current dir

	clr.b	(a0,d0.w)	; zero byte at end of command line
	bsr	mpploadnview
	bra	bye

scandir:
	move	#fa_rdonly|fa_archive,-(sp)
	pea	fspec(pc)
	move	#78,-(sp)	; Fsfirst
	trap	#1
	addq.l	#8,sp

fileloop:
	tst	d0
	bne	bye

	lea	dta_fname(a6),a0
	move.l	a6,-(sp)
	bsr	mpploadnview
	move.l	(sp)+,a6

	move	#79,-(sp)	; Fsnext
	trap	#1
	addq.l	#2,sp
	bra	fileloop

bye:
	clr	-(sp)
	trap	#1

fspec:	dc.b	"*.MPP",0
	even

; Reads a MPP file and display it
; a0: (i) file name
mpploadnview:
	move.l	a0,a5		; remember the file name
	clr	-(sp)		; read mode
	move.l	a0,-(sp)
	move	#61,-(sp)	; Fopen
	trap	#1
	addq.l	#8,sp

	move	d0,d6		; file handle
	bmi	read_file_error

	lea	img,a3
	move.l	a3,-(sp)
	pea	12.w		; read 12-byte header
	move	d6,-(sp)	; file handle
	move	#63,-(sp)	; Fread
	trap	#1
	lea	12(sp),sp

	move.l	8(a3),d0	; extra header info, to be skipped
	beq.s	noseek

	move	#1,-(sp)	; seek from current position
	move	d6,-(sp)	; file handle
	move.l	d0,-(sp)	; seek value
	move	#66,-(sp)	; Fseek
	trap	#1
	lea	10(sp),sp
noseek:

	moveq	#0,d0
	move.b	3(a3),d0	; mode
	add	d0,d0
	lea	plugins(pc),a6
	add	(a6,d0.w),a6	; plugin header address
	move.l	a6,plug

	move	plug_flags(a6),d0
	and	#flag_steonly,d0
	beq.s	mlvf0
	tst	mch		; test if STe only and machine == ST
	bne.s	mlvf0
	bsr	cant_view_ste_warn
	move	d6,-(sp)
	move	#62,-(sp)	; Fclose
	trap	#1
	addq.l	#4,sp
	rts
mlvf0:

	move.b	4(a3),d0	; flags
	moveq	#9,d2		; bit size
	btst	#0,d0		; STE palette ?
	beq.s	noste
	addq	#3,d2
noste:	btst	#1,d0		; extra palette bit ?
	beq.s	noxtra
	addq	#3,d2
noxtra:	move	d2,d4		; number of bits
	move	d4,nbits-img(a3)
	mulu	plug_stored_colors_per_scanline(a6),d4
	mulu	plug_height(a6),d4
	moveq	#15,d0
	add.l	d0,d4
	lsr.l	#3,d4
	and	#-2,d4		; packed palette size
	move	d4,ppalsz-img(a3)

	lea	8(a3),a5	; unpacked palette address
	move.l	a5,palp0-img(a3)
	move.l	a5,palp1-img(a3)
	bsr	rdimg
	move.l	a0,picp0-img(a3)
	move.l	a0,picp1-img(a3)

	btst	#2,img+4
	beq.s	nord2n

; Read second image
	move.l	a5,palp1-img(a3)
	bsr	rdimg
	move.l	a0,picp1-img(a3)

nord2n:
	move	d6,-(sp)
	move	#62,-(sp)	; Fclose
	trap	#1
	addq.l	#4,sp

	tst	mch		; test if machine == ST
	bne.s	mlvnst
	btst	#2,img+4	; double image ?
	bne	noxtr2
	cmp	#9,d2		; 12-bit mode on ST ?
	beq	noxtr2

; Handle 12-bit (STe) mode on the ST.
	move.l	palp0-img(a3),a0
	move	plug_colors_per_scanline(a6),d3
	subq	#1,d3

	move.l	a5,a1
	move.l	a1,palp1-img(a3); destination palette

	move	plug_height(a6),d1
	subq	#1,d1		; height counter
seblln:	move	d3,d2		; line color counter
sebl0:	move	(a0),d0
	move	d0,(a1)

	lsl.w	#4,d0
	moveq	#3-1,d5		; bit counter
sebl1:	rol.w	#4,d0
	moveq	#$f,d6
	and	d0,d6		; isolate component
	eor	d6,d0		; clear component
	or.b	etoe1(pc,d6),d0	; component + 1
	dbra	d5,sebl1


	btst	#0,d1		; even or odd line ?
	beq.s	sebl3
	move	d0,(a0)
	bra.s	sebl4

sebl3:	move	d0,(a1)
sebl4:	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d2,sebl0
	dbra	d1,seblln

	bra.s	noxtr2


mlvnst:	btst	#1,4(a3)	; extra bit ?
	beq.s	noxtr2

; Handle extra bit palette
	move.l	palp0-img(a3),a0
	move	plug_colors_per_scanline(a6),d3
	subq	#1,d3

	move.l	a5,a1
	move.l	a1,palp1-img(a3); destination palette

	move	plug_height(a6),d1
	subq	#1,d1		; height counter
exblln:	move	d3,d2		; line color counter
exbl0:	move	(a0),d0
	move	d0,(a1)
	move	d0,d4
	rol	#4,d4
	and	#7,d4		; isolate the 3 extra bits
	moveq	#3-1,d5		; bit counter
exbl1:	lsr	#1,d4		; test bit
	bcc.s	exbl2
	moveq	#$f,d6
	and	d0,d6		; isolate last component
	and	#$fff0,d0
	or.b	etoe1(pc,d6),d0	; component + 1
exbl2:	ror	#4,d0		; switch to next component
	dbra	d5,exbl1
	ror	#4,d0
	btst	#0,d1		; even or odd line ?
	beq.s	exbl3
	move	d0,(a0)
	bra.s	exbl4

; table to add 1 to STE color components
etoe1:	dc.b	8, 9, 10, 11, 12, 13, 14, 15, 1, 2, 3, 4, 5, 6, 7, 15

exbl3:	move	d0,(a1)
exbl4:	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d2,exbl0
	dbra	d1,exblln

noxtr2:


; Timer A data
	lea	tad+2(pc),a0
	move	plug_timera_data(a6),(a0)

; Run main loop
	pea	mainsup(pc)
	move	#38,-(sp)	; Supexec
	trap	#14
	addq.l	#6,sp

	rts


; Read palette and image from file
; a6: (io) Image plugin address
; a5: (io) Pointer to block of free memory, for palette and image allocation
; a3: (io) Image header address
; d4: (io) Packed palette size
; d6: (io) File handle
; a0: (o)  address of allocated picture
rdimg:
	move	plug_height(a6),d5
	mulu	plug_colors_per_scanline(a6),d5
	move	d5,d1
	add	d1,d1
	sub	d4,d1		; additional bytes in unpacked palette
	add	#128,d1
	lea     (a5,d1.w),a4    ; packed palette address

	move.l	a4,-(sp)	; palette address
	move.l	d4,-(sp)	; packed palette size
	move	d6,-(sp)	; file handle
	move	#63,-(sp)	; Fread
	trap	#1
	lea	12(sp),sp

; Unpack palette
	movem.l	d5-d6/a5,-(sp)
	moveq	#0,d7		; bit buffer
	moveq	#0,d6		; bit counter
	move	nbits-img(a3),d5; number of bits per color
	move.l	a5,a0		; destination buffer
	lea	get_color(pc),a5; color
	jsr	plug_palette_unpack(a6)
	movem.l	(sp)+,d5-d6/a5


	move.l	a5,a0		; palette
	move	d5,d3		; total number of unpacked palette entries

	btst	#0,4(a3)	; ste palette ?
	bne.s	nostp

; Convert 9-bit palette entries to ST format
	subq	#1,d3		; palette entry counter
stplp:	move	(a0),d0
	move	d0,d1
	lsl	#2,d1
	and	#$700,d1	; red component
	move	d0,d2
	lsl	#1,d2
	and	#$070,d2	; green component
	or	d2,d1
	and	#$007,d0	; blue component
	or	d0,d1
	move	d1,(a0)+
	dbra	d3,stplp
nostp:

	add.l	d5,d5
	move.l	d5,d0		; unpacked palette size
	add.l	a5,d0		; address after palette
	cmp.b	#$a0,d0
	bmi.s	mpnm
	add.l	#$100,d0
mpnm:	move.b	#$a0,d0	; aligned picture address
	move.l	d0,a5

	move.l	a5,-(sp)
	move	plug_height(a6),d3
	mulu	plug_width(a6),d3
	lsr.l	#1,d3
	move.l	d3,-(sp)
	move	d6,-(sp)	; file handle
	move	#63,-(sp)	; Fread
	trap	#1
	addq.l	#8,sp

	move.l	(sp)+,a0	; image address

	move	plug_height(a6),d5
	mulu	plug_line_size(a6),d5
	add.l	d5,a5
	cmp.l	d5,d3
	beq.s	rdinft

	move.l	a0,a1
	add.l	d3,a1		; source address
	move.l	a5,a2		; destination address

	move	plug_line_size(a6),d5
	move	plug_width(a6),d3
	lsr	#1,d3		; source width in bytes
	sub	d3,d5		; line offset
	lsr	#1,d3
	subq	#1,d3
	move	plug_height(a6),d1
	subq	#2,d1
rdifl1:	sub	d5,a2
	move	d3,d0
rdifl0:	move	-(a1),-(a2)
	dbra	d0,rdifl0
	dbra	d1,rdifl1

rdinft:
	rts

; Generic function to get a color from a stream with variable number of bits.
; d5: number of bits to read
; d6: available bits in buffer
; d7: bit buffer
; a4: stream pointer
; d0: (o) read value
get_color:
	sub	d5,d6		; enough bits in bit buffer ?
	bpl.s	gcl_getbits

	swap	d7
	move	(a4)+,d7
	add	#16,d6

gcl_getbits:
	move.l	d7,d0
	lsr.l	d6,d0
	rts

unsup_machine_error:
	lea	unsup_error_txt(pc),a0
	bsr.s	_cconws
	bra.s	end

cant_view_ste_warn:
	lea	cant_view_ste_txt1(pc),a0
	bsr.s	_cconws
	move.l	a5,a0
	bsr.s	_cconws
	lea	cant_view_ste_txt2(pc),a0
	bsr.s	_cconws
	bra.s	presskey

read_file_error:
	lea	open_error_txt1(pc),a0
	bsr.s	_cconws
	move.l	a5,a0
	bsr.s	_cconws
	lea	open_error_txt2(pc),a0
	bsr.s	_cconws

end:
	bsr.s	presskey
	clr	-(sp)
	trap	#1

presskey:
	lea	presskey_txt(pc),a0
	bsr.s	_cconws

	move.w	#7,-(sp)	; Crawcin
	trap	#1
	addq.l	#2,sp
	rts

_cconws:
	move.l	a0,-(sp)
	move	#9,-(sp)	; Cconws
	trap	#1
	addq.l	#6,sp
	rts


; Main routine, supervisor mode
mainsup:
	move.l	$462.w,d0	; _vbclock
vs:	cmp.l	$462.w,d0
	beq.s	vs

	move	#$2700,sr

; Setup VBL, timers & co.
	lea	-128(sp),sp
	move.l	sp,a0
	move.l	usp,a1
	move.l	a1,(a0)+
	cmp	#2,mch		; MSte ?
	bne.s	msnm
	move	$ffff8e20.w,(a0)+
	clr.b	$ffff8e21.w
msnm:	move.l	$ffff8200.w,(a0)+
	move.b	$ffff820a.w,(a0)+
	move.b	$ffff8260.w,(a0)+
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	movem.l $ffff8240.w,d1-d7/a1
	movem.l d1-d7/a1,(a0)

	move.l	sp,vecptr

; Init viewer
	jsr	plug_init(a6)

	clr.b	$fffffa07.w
	clr.b	$fffffa09.w

	move.b	#2,$ffff820a.w

	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w

	clr.b	$fffffa19.w
	lea	timer_a(pc),a0
	move.l	a0,$134.w
	lea	vbl(pc),a0
	move.l	a0,$70.w
	lea	hbl(pc),a0
	move.l	a0,$68.w

	bsr.s	next_pic

	move	#$2300,sr
; main loop
mainlp:	bra.s	mainlp

next_pic:
	lea	z,a0
	not	flick
	beq.s	nextp0
	move.l	picp0-z(a0),d0
	move.l	palp0-z(a0),d1
	bra.s	nextp1
nextp0:	move.l	picp1-z(a0),d0
	move.l	palp1-z(a0),d1
nextp1:	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.l	plug-z(a0),a0
	move.l	d1,plug_pal_adr(a0)
	rts

exit:
	move	#$2700,sr
	clr.b	$fffffa19.w

	move.l	vecptr,sp

	move.l	sp,a0
	move.l	(a0)+,a1
	move.l	a1,usp
	cmp	#2,mch		; MSte ?
	bne.s	enm
	move	(a0)+,$ffff8e20.w
enm:	move.l	(a0)+,$ffff8200.w
	move.b	(a0)+,$ffff820a.w
	move.b	(a0)+,$ffff8260.w
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$134.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	movem.l (a0)+,d1-d7/a1
	movem.l d1-d7/a1,$ffff8240.w

	move	#$2300,sr

	lea	128(sp),sp
	rts

vbl:	clr.b	$fffffa19.w
tad:	move.b	#100,$fffffa1f.w
	move.b	#$4,$fffffa19.w

	cmp.b	#$39,$fffffc02.w
	beq.s	exit

	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824c.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825c.w

hbl:	rte

timer_a:
	clr.b	$fffffa19.w
	bclr.b	#5,$fffffa0f.w
	movem.l	d0-a6,-(sp)
	move.l	plug,a0
	jsr	plug_timera(a0)
	bsr	next_pic

	movem.l	(sp)+,d0-a6
	rte

; Retrieve the machine type.
; d0: (o) 0:ST, 1:STe, 2:MSTe, -1:unsupported (Falcon/TT/...)
get_machine_type:
	move.l	#'_MCH',d6
	pea	get_cookie(pc)
	move	#38,-(sp)	; Supexec
	trap	#14
	addq.l	#6,sp

	cmp.l	#-1,d0		; no cookie jar or no cookie found
	beq.s	gmtst

	swap	d0
	tst	d0		; ST ?
	beq.s	gmtst
	cmp	#2,d0		; machine type
	bpl.s	gmtuns		; TT and Falcon are unsupported
	btst	#20,d0		; MSte ?
	beq.s	gmtste
	moveq	#2,d0		; MSTe
	rts
gmtste:	moveq	#1,d0		; STe
	rts
gmtst:	moveq	#0,d0		; ST
	rts
gmtuns:	moveq	#-1,d0		; unsupported
	rts

get_cookie:
	move.l	$5a0.w,d0	; _p_cookies
	beq.s	gcknf
	move.l	d0,a0
gcknx:	move.l	(a0)+,d0	; cookie name
	beq.s	gcknf
	cmp.l	d6,d0
	beq.s	gckf
	addq.l	#4,a0
	bra.s	gcknx
gckf:	move.l	(a0)+,d0	; cookie value
	rts
gcknf:	moveq	#-1,d0
	rts


open_error_txt1:
	dc.b	"Could not find file '",0
open_error_txt2:
	dc.b	"'.",$d,$a,0
cant_view_ste_txt1:
	dc.b	"The file '",0
cant_view_ste_txt2:
	dc.b	"' cannot be viewed (STe only).",$d,$a,0
error_txt:
	dc.b	"File error.",$d,$a,0
unsup_error_txt:
	dc.b	"This program only works on ST, STe and Mega STe.",$d,$a,0
presskey_txt:
	dc.b	"Press any key.",$d,$a,0
	even

plugins:
	dc.w	mode0-plugins, mode1-plugins, mode2-plugins, mode3-plugins

mode0:	include	"mode0.s"
mode1:	include	"mode1.s"
mode2:	include	"mode2.s"
mode3:	include	"mode3.s"

	bss
z:
mch:	ds.w	1
vecptr:	ds.l	1
plug:	ds.l	1
ppalsz:	ds.w	1
flick:	ds.w	1
nbits:	ds.w	1
picp0:	ds.l	1
picp1:	ds.l	1
palp0:	ds.l	1
palp1:	ds.l	1
img:	ds.b	200000
