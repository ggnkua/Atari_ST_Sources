; 2 Pixel sine scroller written by McGeezer
; email graeme.cowie@ntlworld.com or
; PM me at www.atari-forum.com
;
screen:	equ	$180000
logscreen:	equ	$170000
buf1:	equ	$100000
buf2:	equ	$110000

start:	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap 	#1	; supervisor
	addq.l	#6,-(a7)
		
	lea	screen,a2
	move.w	#0,-(a7)
	move.l	a2,-(a7)
	move.l	a2,-(a7)
	move.w	#5,-(a7)
	trap	#14	; low res
	add.l	#12,a7

	bsr	set_pal	; set colour pallete
	bsr	clrscr	; clear screen areas

	bsr	bp1font	; turn font to be 1 plane
	bsr	pre_font	; replicate font at different positions
	bsr	pre_font3	; turn font so it can be movem'd

	bsr	pre_sine	; turn sine table into lines
	
	move.w	sr,status
	move.w	#$2700,sr

	move.b	$fffffa07,iea
	clr.b	$fffffa07	
	move.b	$fffffa09,ieb
	clr.b	$fffffa09
	
vbl:	;move.w	#$777,$ffff8240

	move.w	#37,-(a7)
	trap	#14	; wait vbl
	addq.l	#2,a7

	lea	scr_bufs,a0	; swap vid mem
	move.l	(a0),d0
	move.l	4(a0),d1
	move.l	d0,scr_ptr
	move.l	d1,(a0)
	move.l	d0,4(a0)
	
	lsr.l	#8,d0
	move.b	d0,$ffff8203
	lsr.l	#8,d0
	move.b	d0,$ffff8201

; do routines
;	move.w	#$700,$ffff8240
	bsr	sine_remove
;	move.w	#$070,$ffff8240
	bsr	scroll
;	move.w	#$777,$ffff8240
	
	cmp.b	#28,$fffc02	; hit return
	bne	vbl
	move.w	status,sr
	
	move.b	iea,$fffffa07	; restore control
	move.b	ieb,$fffffa09

;	move.w	#$777,$ffff8240	
	
	lea	oldpal,a0		; colours
	lea	$ffff8240,a1
	
	moveq	#15,d0
.loop2:	move.w	(a0)+,(a1)+
	dbf	d0,.loop2
	
	lea	screen,a2		; restore res
	move.w	#1,-(a7)
	move.l	a2,-(a7)
	move.l	a2,-(a7)
	move.w	#5,-(a7)
	trap	#14
	add.l	#12,a7
	
	clr.w	-(a7)		
	trap	#1		; exit
	
; Set screen pallette
set_pal:	lea	pal,a0
	lea	$ffff8240,a1
	lea	oldpal,a2
	
	moveq	#15,d0
.loop:	move.w	(a1),(a2)+
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts

; Routine to remove the sine scroller 	
sine_remove:	
	lea	sine_clear(pc),a0	; get saved sine addresses
	moveq	#0,d0
	moveq	#19,d7		; need to clear 20 chunks
	moveq	#0,d2		; used for chunk
	move.l	scr_ptr,d3		; get pointer to screen
	
.loop:	move.l	d3,d1
	add.w	(a0)+,d1		; add sine offset
	add.w	d2,d1		; add chunk offset
	move.l	d1,a1

				; clear the plane
				; for as many lines
				; as we need.
	move.w	d0,-160*1(a1)
	move.w	d0,-160*2(a1)
	move.w	d0,-160*3(a1)
	move.w	d0,-160*4(a1)
	move.w	d0,-160*5(a1)
	move.w	d0,-160*6(a1)
	move.w	d0,-160*7(a1)
	move.w	d0,-160*8(a1)
	move.w	d0,-160*9(a1)
	move.w	d0,-160*10(a1)
	move.w	d0,-160*11(a1)
	move.w	d0,-160*12(a1)
	move.w	d0,-160*13(a1)
	move.w	d0,-160*14(a1)
	move.w	d0,-160*15(a1)
	move.w	d0,-160*16(a1)
	move.w	d0,-160*17(a1)
	move.w	d0,-160*18(a1)
	move.w	d0,-160*19(a1)
	move.w	d0,-160*20(a1)
	move.w	d0,-160*21(a1)
	move.w	d0,-160*22(a1)
	move.w	d0,-160*23(a1)
	move.w	d0,-160*24(a1)
	move.w	d0,-160*25(a1)
	move.w	d0,-160*26(a1)
	move.w	d0,-160*27(a1)
	move.w	d0,-160*28(a1)
	move.w	d0,-160*29(a1)
	move.w	d0,-160*30(a1)
	move.w	d0,-160*31(a1)

	move.w	d0,(a1)

	move.w	d0,160*1(a1)
	move.w	d0,160*2(a1)
	move.w	d0,160*3(a1)
	move.w	d0,160*4(a1)
	move.w	d0,160*5(a1)
	move.w	d0,160*6(a1)
	move.w	d0,160*7(a1)
	move.w	d0,160*8(a1)
	move.w	d0,160*9(a1)
	move.w	d0,160*10(a1)
	move.w	d0,160*11(a1)
	move.w	d0,160*12(a1)
	move.w	d0,160*13(a1)
	move.w	d0,160*14(a1)
	move.w	d0,160*15(a1)
	move.w	d0,160*16(a1)
	move.w	d0,160*17(a1)
	move.w	d0,160*18(a1)
	move.w	d0,160*19(a1)
	move.w	d0,160*20(a1)
	move.w	d0,160*21(a1)
	move.w	d0,160*22(a1)
	move.w	d0,160*23(a1)
	move.w	d0,160*24(a1)
	move.w	d0,160*25(a1)
	move.w	d0,160*26(a1)
	move.w	d0,160*27(a1)
	move.w	d0,160*28(a1)
	move.w	d0,160*29(a1)
	move.w	d0,160*30(a1)
	move.w	d0,160*31(a1)
	move.w	d0,160*32(a1)
	move.w	d0,160*33(a1)
	move.w	d0,160*34(a1)
	move.w	d0,160*27(a1)
	move.w	d0,160*27(a1)
	move.w	d0,160*28(a1)
	move.w	d0,160*29(a1)
	move.w	d0,160*30(a1)
	move.w	d0,160*31(a1)
	move.w	d0,160*32(a1)
	move.w	d0,160*33(a1)
	move.w	d0,160*34(a1)
	move.w	d0,160*35(a1)
	move.w	d0,160*36(a1)
	move.w	d0,160*37(a1)
	move.w	d0,160*38(a1)
	move.w	d0,160*39(a1)
	move.w	d0,160*40(a1)
	move.w	d0,160*41(a1)
	move.w	d0,160*42(a1)
	move.w	d0,160*43(a1)
	move.w	d0,160*44(a1)
	addq.w	#8,d2		; goto next chunk
	dbf	d7,.loop
	rts

; Scroller routine	
scroll:	lea	text_ptr(pc),a1
	lea	scr_ptr,a6
	moveq	#19,d7	; 20 chars across
	
scroll_loop:
	move.l	(a1),a3	; pointer in text is a2
	move.l	sine_ptr,a4	; load sine table
	cmp.l	#sine,a4
	bge.s	.scroll_1
	move.l	#sine_end,a4
	move.l	a4,sine_ptr

.scroll_1:	lea	sine_mask(pc),a5
	subq.l	#2,sine_ptr		; sine speed (mult 2)
	
	lea	sine_clear(pc),a2
	moveq	#0,d5	; sign offset 
	
.loop2:	moveq	#0,d0
	moveq	#0,d1
	move.b	(a3)+,d0	; d0 has first char 
	move.b	(a3),d1	; d1 has next char
	tst.b	d1
	bne.s	.loop3
	move.l	#text,a3	;reset scroll line to start
	move.l	a3,text_ptr
	move.b	(a3)+,d0
	move.b	(a3),d1

.loop3:	sub.b	#32,d0
	lsl.w	#2,d0
	
	move.w	font_off,d2	; font offset ptr
	lsl.w	#3,d2	; multiply by 8
	lea	font_char_ptr(pc),a0
	add.w	d2,a0	; select text block
	
	move.l	(a0)+,a6	; a6 now has ptr to mask
	move.l	(a6),d3	; d2 now has font offset mask
	move.l	(a0),a0
	
	add.w	d0,a0
	move.l	d3,d0
	move.l	(a0),a0	; a0 now has pointer to char

; do next char
	sub.b	#32,d1
	lsl.w	#2,d1
	
	lea	font_char_ptr(pc),a1
	add.w	d2,a1
	
	move.l	(a1)+,a6
	move.l	(a6),d4
	move.l	(a1),a1
	add.w	d1,a1
	move.l	(a1),a1	; a1 now has pointer to next char
	move.l	d4,d1

	not.l	d1	; invert mask to paste second char

; a0=address pointer to first char
; d0=mask for character
; a1=address pointer to second char
; a2=saved sine addresses for clear later
; d1=address mask for second char
; a6=pointer to address of screen
; a4=sine table pointer
; a5=sine mask
	move.l	d7,-(a7)		; save the colum

	move.l	scr_ptr,d4		; screen pointer
	
	moveq	#0,d7
	move.w	(a4),d7
	move.w	d7,(a2)+	; Save screen address
		
	rept	16		; 16 pixel mask
	move.l	(a5)+,d6		; sine mask in d6

	move.l	d4,d7		; get screen pointer
	add.w	d5,d7		; add chunk offset
	add.w	(a4)+,d7		; add sine offset
	move.l	d7,a6		; set screen address
		
	move.l	(a0)+,d2		; load in 2 words from first
	move.l	(a1)+,d3		; load in 2 words from second
	and.l	d0,d2		; clear off right of first
	and.l	d1,d3		; clear off left of second
	or.l	d3,d2		; merge together
	and.l	d6,d2		; now apply sine mask 
	or.w	d2,1*160(a6)	; copy 2 lines to screen
	swap	d2
	or.w	d2,(a6)

	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,3*160(a6)	
	swap	d2
	or.w	d2,2*160(a6)

	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,5*160(a6)	
	swap	d2
	or.w	d2,4*160(a6)
	
	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,7*160(a6)	
	swap	d2
	or.w	d2,6*160(a6)

	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,9*160(a6)	
	swap	d2
	or.w	d2,8*160(a6)

	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,11*160(a6)	
	swap	d2
	or.w	d2,10*160(a6)

	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,13*160(a6)	
	swap	d2
	or.w	d2,12*160(a6)
	
	move.l	(a0)+,d2		
	move.l	(a1)+,d3		
	and.l	d0,d2
	and.l	d1,d3
	or.l	d3,d2
	and.l	d6,d2		 
	or.w	d2,15*160(a6)	
	swap	d2
	or.w	d2,14*160(a6)
	
	sub.l	#32,a0
	sub.l	#32,a1
	
	endr

	addq.w	#8,d5		; next chunk for sine

	move.l	(a7)+,d7		restore d7
	dbf	d7,.loop2
	clr.w	sine_off
	
	lea	font_off,a0
	addq.w	#1,(a0)
	cmp.w	#7,(a0)
	bne.s	.scroll_end
	clr.w	(a0)
	addq.l	#1,text_ptr		;scroll to next char

.scroll_end:	rts

; Clear screen areas
clrscr:	lea	screen,a0
	lea	logscreen,a1
	move.l	#$8000,d0
	lsr.l	#2,d0
.loop1:	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d0,.loop1
	rts
	
; Make the included 16*16 font into 1 bitplane	
bp1font:	lea	font,a0
	lea	fontend,a1
	lea	buf1,a2
	
	add.l	#34,a0
	
	moveq	#0,d1
.loop:	move.w	(a0),d0	; 1st plane
	or.w	2(a0),d0	; or pixels of 2nd plane to 1st
	or.w	4(a0),d0	; or pixels of 3rd plane to 1st
	or.w	6(a0),d0	; or pixels of 4th plane to 1st
	move.w	d0,(a2)
	move.w	d1,2(a2)
	move.w	d1,4(a2)
	move.w	d1,6(a2)
	
	addq.l	#8,a0
	addq.l	#8,a2
	cmp.l	a1,a0
	blt.s	.loop
	rts



; pre-calculate
; make font blocks by rotating them by 2 pixels
pre_font:	move.l	#160*50,d0 	; to next font block
	move.l	d0,d1
	moveq	#0,d2
	lsr.l	#1,d0	; divide by 4
	move.l	d0,d6

	moveq	#6,d7	; 7 blocks for speed 2
	lea	font_ptr(pc),a2	; pointer to fonts

	lea	buf1,a0
	move.l	a0,a1
	add.l	d1,a1

	move.w	#-1,d5	; the and mask
		
pre_font2:	move.l	a0,(a2)+

pre_font1:	move.w	(a0)+,d1
	rol.w	#2,d1
	move.w	d1,(a1)+
	dbf	d0,pre_font1

	subq.l	#2,a0
	subq.l	#2,a1
	move.l	d6,d0
	
	dbf	d7,pre_font2

	move.l	#-1,(a2)

	rts
	
; re-adjust font into words
pre_font3:	lea	buf2,a0
	lea	font_ptr(pc),a1
	lea	font_set(pc),a3
	
pre_font8:	cmp.l	#-1,(a1)
	beq	pre_font9
		
	move.l	(a1)+,a2
	move.l	#160*16,d1		; bytes to next row
	moveq	#2,d7		;3 rows

pre_font5:
	moveq	#19,d6	;20 colums

pre_font4:	
	move.l	a0,(a3)+
	move.w	(a2),d2
	swap	d2
	move.w	160(a2),d2
	
	move.w	160*2(a2),d3
	swap	d3
	move.w	160*3(a2),d3
	
	move.w	160*4(a2),d4
	swap	d4
	move.w	160*5(a2),d4

	move.w	160*6(a2),d5
	swap	d5
	move.w	160*7(a2),d5
	
	movem.l	d2-d5,(a0)
	add.l	#16,a0
	
	move.w	160*8(a2),d2
	swap	d2
	move.w	160*9(a2),d2
	
	move.w	160*10(a2),d3
	swap	d3
	move.w	160*11(a2),d3
	
	move.w	160*12(a2),d4
	swap	d4
	move.w	160*13(a2),d4

	move.w	160*14(a2),d5
	swap	d5
	move.w	160*15(a2),d5
	
	movem.l	d2-d5,(a0)

	add.l	#16,a0
	
	addq.l	#8,a2		; next char
	dbf	d6,pre_font4
	
	sub.l	#160,a2
	add.l	d1,a2
	
	dbf	d7,pre_font5
	bra	pre_font8
	
pre_font9:	rts

; Turn sine lines into screen addressable area
pre_sine:	lea	sine,a0
pre_sine1:	moveq	#0,d0
	cmp.w	#-1,(a0)
	beq	pre_sine2
	
	move.w	(a0),d0
	mulu	#160,d0
	move.w	d0,(a0)+
	bra.s	pre_sine1
pre_sine2:	rts

sine_ptr:	dc.l	sine_end
sine:	rept	5
	dc.w	124,124,121,121,118,118,115,115,112,112,109,109
	dc.w	106,106,103,103,99,99,96,96,93,93,90,90,87,87,84,84,81,81
	dc.w	79,79,76,76,73,73,70,70,67,67,64,64,62,62,59,59,56,56
	dc.w	54,54,51,51,49,49,46,46,44,44,42,42,39,39 
        	dc.w	37,37,35,35,33,33,31,31,29,29,27,27,25,25,23,23,21,21
        	dc.w	19,19,18,18,16,16,15,15,13,13,12,12,10,10 
        	dc.w	9,9,8,8,7,7,6,6,5,5,4,4,3,3,3,3,2,2,1,1,1,1
        	dc.w	0,0,0,0,0,0,0,0,0,0,0
        	dc.w	0,0,0,0,0,0,0,0,0,0,0
        	dc.w	1,1,1,1,2,2,3,3,3,3,4,4,5,5,6,6,7,7,8,8  
        	dc.w	9,9,10,10,12,12,13,13,15,15,16,16,18,18,19,19,21,21,23,23
        	dc.w	25,25,27,27,29,29,31,31,33,33,35,35 
	dc.w	37,37,39,39,42,42,44,44,46,46,49,49,51,51,54,54
	dc.w	56,56,59,59,62,62,64,64,67,67,70,70,73,73,76,76 
	dc.w	79,79,81,81,84,84,87,87,90,90,93,93,96,96,99,99
	dc.w	103,103,106,106,109,109,112,112,115,115,118,118,121,121	
	endr
	
sine_end:
	rept	5
	dc.w	124,124,121,121,118,118,115,115,112,112,109,109
	dc.w	106,106,103,103,99,99,96,96,93,93,90,90,87,87,84,84,81,81
	dc.w	79,79,76,76,73,73,70,70,67,67,64,64,62,62,59,59,56,56
	dc.w	54,54,51,51,49,49,46,46,44,44,42,42,39,39 
        	dc.w	37,37,35,35,33,33,31,31,29,29,27,27,25,25,23,23,21,21
        	dc.w	19,19,18,18,16,16,15,15,13,13,12,12,10,10 
        	dc.w	9,9,8,8,7,7,6,6,5,5,4,4,3,3,3,3,2,2,1,1,1,1
        	dc.w	0,0,0,0,0,0,0,0,0,0,0
        	dc.w	0,0,0,0,0,0,0,0,0,0,0
        	dc.w	1,1,1,1,2,2,3,3,3,3,4,4,5,5,6,6,7,7,8,8  
        	dc.w	9,9,10,10,12,12,13,13,15,15,16,16,18,18,19,19,21,21,23,23
        	dc.w	25,25,27,27,29,29,31,31,33,33,35,35 
	dc.w	37,37,39,39,42,42,44,44,46,46,49,49,51,51,54,54
	dc.w	56,56,59,59,62,62,64,64,67,67,70,70,73,73,76,76 
	dc.w	79,79,81,81,84,84,87,87,90,90,93,93,96,96,99,99
	dc.w	103,103,106,106,109,109,112,112,115,115,118,118,121,121	
	endr
	dc.w	-1
	
sine_clear:	ds.l	(40*16)

;sine:	rept	500
;	dc.w	20
;	endr
;	dc.w	-1
	
sine_mask:	rept	20
	dc.w	%1000000000000000,%1000000000000000
	dc.w	%0100000000000000,%0100000000000000
	dc.w	%0010000000000000,%0010000000000000
	dc.w	%0001000000000000,%0001000000000000
	dc.w	%0000100000000000,%0000100000000000
	dc.w	%0000010000000000,%0000010000000000
	dc.w	%0000001000000000,%0000001000000000
	dc.w	%0000000100000000,%0000000100000000
	dc.w	%0000000010000000,%0000000010000000
	dc.w	%0000000001000000,%0000000001000000
	dc.w	%0000000000100000,%0000000000100000
	dc.w	%0000000000010000,%0000000000010000
	dc.w	%0000000000001000,%0000000000001000
	dc.w	%0000000000000100,%0000000000000100
	dc.w	%0000000000000010,%0000000000000010
	dc.w	%0000000000000001,%0000000000000001
	endr
	
	
sine_off:	dc.w	0	; this goes 0,8,16,24,32
	dc.l	0

scr_ptr	dc.l	screen
scr_bufs:	dc.l	screen,logscreen

font_off:	dc.w	0	; this goes 0,1,2,3,4,5,6,7

font_char_ptr:
	dc.l	font_mask,font_set
	dc.l	font_mask+4,font_set+1*(4*60)
	dc.l	font_mask+8,font_set+2*(4*60)
	dc.l	font_mask+12,font_set+3*(4*60)
	dc.l	font_mask+16,font_set+4*(4*60)
	dc.l	font_mask+20,font_set+5*(4*60)
	dc.l	font_mask+24,font_set+6*(4*60)
	dc.l	font_mask+28,font_set+7*(4*60)

font_mask:	dc.w	%1111111111111111,%1111111111111111
	dc.w	%1111111111111100,%1111111111111100
	dc.w	%1111111111110000,%1111111111110000
	dc.w	%1111111111000000,%1111111111000000
	dc.w	%1111111100000000,%1111111100000000
	dc.w	%1111110000000000,%1111110000000000
	dc.w	%1111000000000000,%1111000000000000
	dc.w	%1100000000000000,%1100000000000000
	dc.w	%0000000000000000,%0000000000000000
	
text_ptr:	dc.l	text
text:	dc.b	"                     THIS IS A 1 PIXEL SINE SCROLLER CODED BY MCGEEZER - PM ME AT WWW.ATARI-FORUM.COM....                   ",0
	even

;font_set holds addresses of every font char
;60 chars per font block (chars per block * rotates sets) 60*8 = 480
font_set:	ds.l	480
		
font_ptr:	ds.l	17
		;     bp1  bp2       bp3
pal:	dc.w	$000,$777,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000

iea:	dc.b	0
ieb:	dc.b	0

oldpal:	ds.w	16

status:	dc.w	0

font:	
	incbin	"c:\aura.pi1"
fontend:


