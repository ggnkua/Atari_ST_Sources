

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


	public init_hli
	; init_hli = set up registers with color info so can call hli
	;     below with less set up than _hline.  Also sets up mask pointers
	; d0 = color

init_hli
		;a4 points to the hline associated with this color
	move.l	#hline_table,a4	
	asl.w	#2,d0			;pointer addressing ... *4
	move.l	0(a4,d0.w),a4		; a4-> color based hline routine
		;a2 and a3 go to the mask tables
	move.l	#_lmasks,a2
	move.l	#_rmasks,a3
	move.l	_cscreen,a1
	rts


	public hli
	; hli(y, x1, x2)
	; hli - draw a horizontal line while trashing registers:
	;	d0,d1,d2,d3	a0,a2,a3,a4
hli
first_param  set 4
y  set first_param
x1 set first_param+2
x2 set first_param+4

	; get y address of hline in a0
	move.l	a1,a0
	move.w	y(sp),d0
	lsl.w	#5,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d0,d0
	add.w	d1,d0
	adda.w	d0,a0


	; add in x component of address to get left end in a0
	move.w	x1(sp),d2 ;peel off copy of x1 for future use
	move.w	d2,d0
	asr.w	#1,d0	; x2 pixels/bytes
	and.w	#$fff8,d0	; mask to word boundary
	adda.w	d0,a0

	move.w	x2(sp),d3 ; peel off copy of x2 for future use

		;d0 = count = (x2>>4) - (x1>>4) - 1
	move.w	d3,d0
	asr.w	#4,d0
	move.w	d2,d1
	asr.w	#4,d1
	sub.w	d1,d0


		;mask out where in word endpoints are
	and.w	#$f,d2
	and.w	#$f,d3


		;word addressing of mask tables
	asl	#1,d2
	asl	#1,d3

	sub.w	#1,d0
	jmp	(a4)



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
	asl.w	#2,d0			;pointer addressing ... *4
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

		;a1 = line_addr + ((x1>>1)&$fff8)
	move.w	d6,d0
	asr.w	#1,d0
	and.w	#$fff8,d0
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




	public _blast_hlines

first_param  set 7*4
thread1  set first_param
thread2  set first_param+4
highy	 set first_param+8
count	 set first_param+10
color	 set first_param+12

_blast_hlines:
	movem.l	a2/a3/a4/a5/a6/d4,-(sp)

		;set a1 = screen address of first hline
	move.l	_cscreen,a1
	move.w	highy(sp),d0
	mulu	#160,d0
	adda	d0,a1

		;a2 and a3 go to the mask tables
	move.l	#_lmasks,a2
	move.l	#_rmasks,a3

		;a4 points to the hline associated with this color
	move.l	#hline_table,a4	
	move.w	color(sp),d0
	asl.w	#2,d0			;pointer addressing ... *4
	move.l	0(a4,d0),a4		; a4-> color based hline routine

	move.l	thread1(sp),a5	;overwriting static data pointer but it's ok
	move.l	thread2(sp),a6
	move.w	count(sp),d4
	adda	d4,a6	;	thread2 is backwards so skip to end of it
	adda	d4,a6
	bra	zblast_loop
blast_loop:	move.w	(a5)+,d2
	move.w	-(a6),d3
	cmp.w	d2,d3
	bgt	blast_noswap
	exg	d2,d3

blast_noswap:
		;a1 = line_addr + ((x1>>1)&$fff8)
	move.l	a1,a0
	move.w	d2,d0
	asr.w	#1,d0
	and.w	#$fff8,d0
	adda	d0,a0
	
		;d0 = count = (x2>>4) - (x1>>4)
	move.w	d3,d0
	asr.w	#4,d0
	move.w	d2,d1
	asr.w	#4,d1
	sub.w	d1,d0

		;mask out where in word endpoints are
	and.w	#$f,d2
	and.w	#$f,d3
		;word addressing of mask tables
	asl	#1,d2
	asl	#1,d3

	subq.w	#1,d0	;test for within one word (zero count)
	jsr	(a4)	;and jump to color specific routine

	adda	#160,a1
zblast_loop:	dbf	d4,blast_loop	
	movem.l (sp)+,a2/a3/a4/a5/a6/d4
	rts


hline0:	
		;if it's all in one word and the masks together and set it!
	bpl	hwords0
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords0:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	bra	hloopz0

hloop0:
	clr.l	(a0)+
	clr.l	(a0)+
hloopz0: dbf	d0,hloop0

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
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
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords1:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+

	move.l	#$ffff0000,d1
	bra	hloopz1
hloop1:
	move.l	d1,(a0)+
	clr.l	(a0)+
hloopz1: dbf	d0,hloop1

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
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
	and.w	d1,4(a0)
	and.w	d1,6(a0)
	rts

hwords2:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#4,a0
	and.w	d1,(a0)+
	and.w	d1,(a0)+

	move.l	#$0000ffff,d1
	bra	hloopz2
hloop2:
	move.l	d1,(a0)+
	clr.l	(a0)+
hloopz2: dbf	d0,hloop2
	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#4,a0
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts


hline3:
		;if it's all in one word and the masks together and set it!
	bpl	hwords3
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts

hwords3:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+

	move.l	#$ffffffff,d1
	bra	hloopz3
hloop3:
	move.l	d1,(a0)+
	clr.l	(a0)+
hloopz3: dbf	d0,hloop3

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	rts


hline4:
		;if it's all in one word and the masks together and set it!
	bpl	hwords4
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	addq	#4,a0
	and.w	d1,(a0)
	rts

hwords4:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	addq	#2,a0
	and.w	d1,(a0)+

	move.l	#$ffff0000,d1
	bra	hloopz4
hloop4:
	clr.l	(a0)+
	move.l	d1,(a0)+
hloopz4: dbf	d0,hloop4

	move.w	0(a3,d3.w),d1
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	addq	#2,a0
	and.w	d1,(a0)+
	rts


hline5:
		;if it's all in one word and the masks together and set it!
	bpl	hwords5
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,2(a0)
	and.w	d1,6(a0)
	rts

hwords5:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,2(a0)
	and.w	d1,6(a0)
	addq	#8,a0

	move.l	#$ffff0000,d1
	bra	hloopz5
hloop5:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
hloopz5: dbf	d0,hloop5

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,2(a0)
	and.w	d1,6(a0)
	rts


hline6:
		;if it's all in one word and the masks together and set it!
	bpl	hwords6
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,6(a0)
	rts

hwords6:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,6(a0)
	addq	#8,a0

	move.l	#$0000ffff,d1
	move.l	#$ffff0000,d2
	bra	hloopz6
hloop6:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopz6: dbf	d0,hloop6

	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,6(a0)
	rts


hline7:
		;if it's all in one word and the masks together and set it!
	bpl	hwords7
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	rts

hwords7:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+

	move.l	#$ffffffff,d1
	move.l	#$ffff0000,d2
	bra	hloopz7
hloop7:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopz7: dbf	d0,hloop7

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	not.w	d1
	and.w	d1,(a0)+
	rts


hline8:	
		;if it's all in one word and the masks together and set it!
	bpl	hwords8
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)
	rts

hwords8:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+

	move.l	#$0000ffff,d1
	bra	hloopz8
hloop8:
	clr.l	(a0)+
	move.l	d1,(a0)+
hloopz8: dbf	d0,hloop8

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)
	rts

hline9: 
		;if it's all in one word and the masks together and set it!
	bpl	hwords9
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts

hwords9:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	addq	#4,a0

	move.l	#$ffff0000,d1
	move.l	#$0000ffff,d2
	bra	hloopz9
hloop9:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopz9: dbf	d0,hloop9

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,4(a0)
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)
	rts

hlinea: 
		;if it's all in one word and the masks together and set it!
	bpl	hwordsa
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	rts

hwordsa:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	addq	#8,a0

	move.l	#$0000ffff,d1
	bra	hloopza
hloopa:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
hloopza: dbf	d0,hloopa
	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	and.w	d1,4(a0)
	rts


hlineb:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsb
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	rts

hwordsb:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#4,a0

	move.l	#$ffffffff,d1
	move.l	#$0000ffff,d2
	bra	hloopzb
hloopb:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopzb: dbf	d0,hloopb

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,2(a0)
	not.w	d1
	and.w	d1,(a0)
	rts


hlinec:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsc
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts

hwordsc:
			;set first word
	move.w	0(a2,d2.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+

	move.l	#$ffffffff,d1
	bra	hloopzc
hloopc:
	clr.l	(a0)+
	move.l	d1,(a0)+
hloopzc: dbf	d0,hloopc

	move.w	0(a3,d3.w),d1
	not.w	d1
	and.w	d1,(a0)+
	and.w	d1,(a0)+
	not.w	d1
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts

hlined:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsd
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,2(a0)
	rts

hwordsd:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,2(a0)
	addq	#8,a0

	move.l	#$ffff0000,d1
	move.l	#$ffffffff,d2
	bra	hloopzd
hloopd:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopzd: dbf	d0,hloopd

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,2(a0)
	rts


hlinee:
		;if it's all in one word and the masks together and set it!
	bpl	hwordse
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	rts

hwordse:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	addq	#8,a0

	move.l	#$0000ffff,d1
	move.l	#$ffffffff,d2
	bra	hloopze
hloope:
	move.l	d1,(a0)+
	move.l	d2,(a0)+
hloopze: dbf	d0,hloope

	move.w	0(a3,d3.w),d1
	or.w	d1,2(a0)
	or.w	d1,4(a0)
	or.w	d1,6(a0)
	not.w	d1
	and.w	d1,(a0)
	rts


hlinef:
		;if it's all in one word and the masks together and set it!
	bpl	hwordsf
	move.w	0(a2,d2.w),d1
	and.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts

hwordsf:
			;set first word
	move.w	0(a2,d2.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+

	move.l	#$ffffffff,d1
	bra	hloopzf
hloopf:
	move.l	d1,(a0)+
	move.l	d1,(a0)+
hloopzf: dbf	d0,hloopf

	move.w	0(a3,d3.w),d1
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)+
	or.w	d1,(a0)
	rts



	dseg

hline_table:
	dc.l hline0,hline1,hline2,hline3
	dc.l hline4,hline5,hline6,hline7
	dc.l hline8,hline9,hlinea,hlineb
	dc.l hlinec,hlined,hlinee,hlinef

