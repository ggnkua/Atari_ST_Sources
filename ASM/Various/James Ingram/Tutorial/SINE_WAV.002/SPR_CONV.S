* Sprite converter
* by James Ingram, March 1994

	opt	x+,o+,ow-

spr_h	equ	75
spr_w	equ	160

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

	lea	pal_nam(pc),a0
	move.l	#pic+2,a1
	moveq	#32,d0
	bsr	save_file


no_save:
	super_off

	clr.w	-(a7)
	trap	#1


spr_nam:
	dc.b	"sprite.dat",0
pal_nam:
	dc.b	"spr_pal.dat",0

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



