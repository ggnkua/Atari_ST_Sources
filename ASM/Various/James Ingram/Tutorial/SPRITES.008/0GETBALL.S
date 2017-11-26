* Sprite converter
* adapted to get BALL sprite and mask out!
* by James Ingram, May 1994

	opt	x+,o+,ow-

spr_h	equ	31
spr_w	equ	32
offset	equ	144

words	equ	spr_w/16*4	; width / pixels in a word * WORDs per plane


	include	includes\macros.s

	super_on

	bsr	initialise

* now put my palette in
	pea	pic+2
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7


* and display the picture on screen
	move.l	logbase,a0
	lea	pic+34,a1
	move.w	#32000/4-1,d0
d:
	move.l	(a1)+,(a0)+
	dbra	d0,d


* now do the actual converting bit...
	move.l	logbase,a0	; addr of sprite
	add.l	#offset,a0
	move.l	#sprite,a1	; addr to put it at
	
	move.w	#spr_h-1,d0	; counter for lines
line:
	move.l	a0,a2
	move.w	#words-1,d1
do_words:
	move.w	(a2),(a1)+
	not.w	(a2)+
	dbra	d1,do_words	; copy whole line
	
	lea	160(a0),a0	; goto next line on screen
	dbra	d0,line

* now get the MASK out!
* 1 plane only!
	move.l	#mask,a1
	move.w	#spr_h-1,d0
m_line:
	move.l	a0,a2
	move.w	#(words/4)-1,d1
m_words:
	move.w	(a2),d7
	not.w	d7
	move.w	d7,(a1)+
	not.l	(a2)+
	not.l	(a2)+

	dbra	d1,m_words

	lea	160(a0),a0
	dbra	d0,m_line


	bsr	inp


	bsr	restore
	
	lea	mes(pc),a0
	bsr	print_mes
	bsr	get_yn		; get either "y" or "n"
	
	cmp.b	#"n",d0
	beq	no_save

* save this stuff!!!
	lea	spr_nam(pc),a0
	move.l	#sprite,a1
	move.l	#sprite_len,d0
	bsr	save_file

	lea	mask_nam(pc),a0
	move.l	#mask,a1
	move.l	#mask_len,d0
	bsr	save_file



no_save:
	super_off

	clr.w	-(a7)
	trap	#1


spr_nam:
	dc.b	"ball.dat",0

mask_nam:
	dc.b	"ball_mask.dat",0


mes:
	dc.b	27,"ESave sprite and palette (Y/N)?",10,13,0
	even

	include	\includes\misc.s
	include	\includes\init.s
	include	\includes\save.s

pic:
	incbin	\includes\sprite.pi1

	section	bss

sprite:
	ds.w	spr_h*words
sprite_len	equ	*-sprite


mask:
	ds.w	spr_h*words/4
mask_len	equ	*-mask



