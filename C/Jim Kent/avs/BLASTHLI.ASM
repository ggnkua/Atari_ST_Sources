

; :ts=8
	dseg
	public _cscreen
	public _lmasks
	public _rmasks

_lmasks: dc.w	$ffff,$7fff,$3fff,$1fff
	dc.w 	$fff,$7ff,$3ff,$1ff
	dc.w	$ff,$7f,$3f,$1f
	dc.w	$f,$7,$3,$1

_rmasks: dc.w	$8000,$c000,$e000,$f000
	dc.w	$f800,$fc00,$fe00,$ff00
	dc.w	$ff80,$ffc0,$ffe0,$fff0
	dc.w	$fff8,$fffc,$fffe,$ffff

	cseg



	public _blast_block
	;	blast_block(x1, y1, x2, y2, color)
	;	draws a filled block from upper left corner x1 y1
	;	to lower right corner x2 y2.
first_param  set 11*4
x1  set first_param
y1  set first_param+2
x2	 set first_param+4
y2	 set first_param+6
color	 set first_param+8
_blast_block
	movem.l	a2/a3/a4/a5/a6/d3/d4/d5/d6/d7,-(sp)


		;a4 points to the hline associated with this color
	move.l	#hline_table,a4	
	move.w	color(sp),d0
	add.w	d0,d0
	add.w	d0,d0	;turn it into longword index
	move.l	0(a4,d0),a4		; a4-> color based hline routine


		;d7 = lines = y2-y1+1
	move.w	y1(sp),d6
	move.w	y2(sp),d7
	sub.w	d6,d7
	add.w	#1,d7

		;set a1 = screen address of first hline
	move.l	_cscreen,a1
	move.w	d6,d0
	mulu	#160,d0
	adda.l	d0,a1


		;a2 and a3 go to the mask tables
	move.l	#_lmasks,a2
	move.l	#_rmasks,a3

		;get line endpoints
	move.w	x1(sp),d6
	move.w	x2(sp),d3

		;a1 = line_addr + ((x1>>2)&$fffc)
	move.w	d6,d0
	asr.w	#2,d0
	and.w	#$fffc,d0
	adda.w	d0,a1
	
		;d5 = count = (x2>>4) - (x1>>4) - 1
	move.w	d3,d5
	asr.w	#4,d5
	move.w	d6,d1
	asr.w	#4,d1
	sub.w	d1,d5
	sub.w	#1,d5

		;mask out where in word endpoints are
	and.w	#$f,d6
	and.w	#$f,d3
		;word addressing of mask tables
	asl	#1,d6
	asl	#1,d3

	;bra  zblast_block

	bra zbblp

bblp	
	move.l	a1,a0
	move.w	d6,d2
	move.w	d5,d0
	jsr	(a4)
	adda.w	#160,a1
zbblp	dbra	d7,bblp

zblast_block
	movem.l (sp)+,a2/a3/a4/a5/a6/d3/d4/d5/d6/d7
	rts





hline0:	
		;if it's all in one word and the masks together and set it!
	bpl	hwords0
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords0:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	bra	hloopz0

hloop0:
	clr.l	(a0)+
hloopz0: dbf	d0,hloop0

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hline1: 
		;if it's all in one word and the masks together and set it!
	bpl	hwords1
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	rts

hwords1:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+

	move.l	#$ffff0000,d1
	bra	hloopz1
hloop1:
	move.l	d1,(a0)+
hloopz1: dbf	d0,hloop1

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	rts

hline2: 
		;if it's all in one word and the masks together and set it!
	bpl	hwords2
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	rts

hwords2:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	add	#4,a0

	move.l	#$0000ffff,d1
	bra	hloopz2
hloop2:
	move.l	d1,(a0)+
hloopz2: dbf	d0,hloop2
	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	rts


hline3:
		;if it's all in one word and the masks together and set it!
	bpl	hwords3
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	rts

hwords3:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+

	move.l	#$ffffffff,d1
	bra	hloopz3
hloop3:
	move.l	d1,(a0)+
hloopz3: dbf	d0,hloop3

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	rts


hline_table:
	dc.l hline0,hline1,hline2,hline3

