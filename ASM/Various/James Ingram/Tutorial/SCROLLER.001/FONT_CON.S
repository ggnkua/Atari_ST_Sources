* FONT converter
* put font from PI1 format
* into a format that can be read quicker by
* the scroller...

	opt	o+,ow-
	opt	x+

	move.l	#stack,a7

	lea	pic+34(pc),a0
	move.l	#new_font,a1

* do 6 lines
	moveq	#6-1,d0

line_loop:
* do 10 chars per line
	moveq	#10-1,d1
	pea	(a0)

char_loop:

	move.l	a0,a2

	moveq	#32-1,d6
byte1:
	movep.l	(a2),d7
	move.l	d7,(a1)+
	add.l	#160,a2
	dbra	d6,byte1
	

	lea	1(a0),a2
	moveq	#32-1,d6
byte2:
	movep.l	(a2),d7
	move.l	d7,(a1)+
	add.l	#160,a2
	dbra	d6,byte2

	lea	8(a0),a2
	moveq	#32-1,d6
byte3:
	movep.l	(a2),d7
	move.l	d7,(a1)+
	add.l	#160,a2
	dbra	d6,byte3

	lea	9(a0),a2
	moveq	#32-1,d6
byte4:
	movep.l	(a2),d7
	move.l	d7,(a1)+
	add.l	#160,a2
	dbra	d6,byte4


* got an entire char!
	add.l	#16,a0		; go to next char address
	
	dbra	d1,char_loop

	move.l	(a7)+,a0
	add.l	#160*32,a0
	dbra	d0,line_loop

	move.l	a1,end_addr


	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,-(a7)

	bsr	initialise

	movem.l	pic+2,d0-7
	movem.l	d0-7,$ffff8240.w

* now show font on screen, to check it's been done OK
	move.l	#new_font,a0
	move.l	logbase,a1

	moveq	#6-1,d0		; 6 lines
line_loop2:

	moveq	#10-1,d1	; 10 chars per line

	pea	(a1)		; keep screen address

char_loop2:

	move.l	a1,a2

	moveq	#32-1,d6
.byte1:
	move.l	(a0)+,d7
	movep.l	d7,(a2)
	add.l	#160,a2
	dbra	d6,.byte1


	lea	1(a1),a2

	moveq	#32-1,d6
.byte2:
	move.l	(a0)+,d7
	movep.l	d7,(a2)
	add.l	#160,a2
	dbra	d6,.byte2


	lea	8(a1),a2

	moveq	#32-1,d6
.byte3:
	move.l	(a0)+,d7
	movep.l	d7,(a2)
	add.l	#160,a2
	dbra	d6,.byte3


	lea	9(a1),a2

	moveq	#32-1,d6
.byte4:
	move.l	(a0)+,d7
	movep.l	d7,(a2)
	add.l	#160,a2
	dbra	d6,.byte4

	add.l	#16,a1		; next char along
	dbra	d1,char_loop2

	move.l	(a7)+,a1
	add.l	#160*32,a1
	dbra	d0,line_loop2
	

	bsr	inp
	
	bsr	restore

	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	sav(pc),a0
	bsr	print_mes

wait_val:
	bsr	inp

	or.b	#$20,d0
	cmp.b	#"y",d0
	beq	save_it
	
	cmp.b	#"n",d0
	bne.s	wait_val

	clr.w	-(a7)
	trap	#1

save_it:
* save the font data!!!

	lea	font(pc),a0
	move.l	#new_font,a1
	move.l	end_addr,d0
	sub.l	a1,d0
	bsr	save_file

	lea	palname(pc),a0
	move.l	#pic+2,a1
	moveq	#32,d0
	bsr	save_file
	
	clr.w	-(a7)
	trap	#1

	include	save.s


font:
	dc.b	"font.dat",0
palname:
	dc.b	"font_pal.dat",0

sav:
	dc.b	27,"ESave font (Y/N)",10,13,0
	even


	include	\includes\init.s


print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

inp:	
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts



pic:
	incbin	\includes\font.pi1


	section	bss

end_addr	ds.l	1
new_font	ds.b	32000


	ds.b	5000
stack:


