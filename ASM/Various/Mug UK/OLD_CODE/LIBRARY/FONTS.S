;
; Alter Fonts (should be called to install/remove new fonts)
;
userfont	macro
	move.l	#a1_font,a1_ptr ;mono font (8*16)
	move.l	#a2_font,a2_ptr ;colour font (8*8)
	endm

sysfont	macro
	move.l	#0,a1_ptr
	move.l	#0,a2_ptr
	endm
;
; FONTKIT Fonts (A1*.FON/A2*.FON/A3*.FON for Mono/Colour/Icon formats)
;  
; a1_font, must hold the (8*16) font of 4114 bytes
; a2_font, must hold the (8*8)  font of 2066 bytes
;
; Use:
;	font 16 - to switch to 8*16 size
;	font 8  - to switch to 8*8 size

font	macro	\1		;only one parameter is used
	move.w	#\1,d6
	dc.w	$a000		;initialize A-line
	move.l	a0,a_line_start
	move.l	(a1)+,fontaddress_6	;get ROM addresses
	move.l	(a1)+,fontaddress_8
	move.l	(a1),fontaddress_16

	cmp.w	#8,d6	; did we use 'font 8' ??
	beq	fnt8\@

fnt16\@	move.l	a1_ptr,a1	; we must of used 'font 16' then !!
	jsr	fnt_16
	bra	done\@

fnt8\@	move.l	a2_ptr,a1	
	jsr	fnt_8
	bra	done\@

done\@	nop	
	endm

; Access to font routines by Camy Maertens of Budgie U.K
; ------------------------------------------------------
;
; after a DC.W $A000 call, A0 returns a pointer to A-line variables
; which I stored in 'a_line_start', while A1 returns the address of
; of the 3 system fonts.  
;
; This routine expects the new font data in A1, otherwise a zero (L)
; must be passed in A1 to use system font.
;
; In this routine:- A0 points to font header (not A-line)
; 		A4 will point to A-line
;

fnt_8	move.l	fontaddress_8,a0	$fc96ca/fd2ca6 tos8/9
	bra	fnta

fnt_16	move.l	fontaddress_16,a0	$fc9cce/fd3702 tos8/9

fnta	move.l	a_line_start,a4	$293a /2994?
	suba.l	#6,a4		deduct 6 bytes (why?)
	move.w	$52(a0),d0	height of character (82 dec in the header)
	move.w	d0,-$28(a4)	merken?
	move.w	$8(a4),d1		bytes per screen line
	mulu	d0,d1		times height of character
	move.w	d1,-$22(a4)	yields bytes per line
	moveq	#0,d1		
	move.w	$2(a4),d1		raster lines on screen
	divu	d0,d1		divide by font height
	subq.w	#1,d1		minus
	move.w	d1,-$24(a4)	yields max cursor line
	moveq	#0,d1
	move.w	-6(a4),d1		screen width in bits
	divu	$34(a0),d1	divide by max char width
	subq.w	#1,d1		minus 1
	move.w	d1,-$26(a4)	yields max cursor column
	move.w	$50(a0),-8(a4)	width of form
	move.w	$24(a0),-$a(a4)	smallest ascii code in font
	move.w	$26(a0),-$c(a4)	largest
	cmp.l	#0,a1		if zero, use standard data
	beq	fnt1a		
	move.l	a1,-$10(a4)	else use mine
	bra	fnt2a
fnt1a	move.l	$4c(a0),-$10(a4)	standard data
fnt2a	move.l	$48(a0),-$4(a4)	pointer to offset table
	rts

a_line_start  	dc.l 0
fontaddress_6	dc.l 0
fontaddress_8	dc.l 0
fontaddress_16	dc.l 0
