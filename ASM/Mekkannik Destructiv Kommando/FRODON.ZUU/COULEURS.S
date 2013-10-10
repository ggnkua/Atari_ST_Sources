          move.w #$20,-(a7)
          trap   #1
          addq.l #6,a7
          pea rout(pc)
	move.w #2,-(a7)
	move.w #8,-(a7)
	move.w #1,-(a7)
	move.w #$1f,-(a7)
	trap #14
	lea 12(a7),a7

	bset #0,$fffa13
	bset #0,$fffa07
	
	move.w #1,-(a7)
	trap #01
	addq.l #2,a7

	move.w #8,-(a7)
	move.w #$1a,-(a7)
	trap #14
	addq.l #4,a7

	clr.l $4d2
	move #$2700,sr
	move.b iera,$fffa07
	move.b ierb,$fffa09
	bset #4,$fffa09
	bset #5,$fffa09
	move.l ancvbl,$70
	
	move #$2300,sr

	dc.w $a009

	move.b #8,$fffc02

	move.w #$777,$ff8240
	clr.l -(a7)
	trap #01
	rts


rout 	movem.l a5,-(a7)
	move.l ptr,a5
	move (a5)+,$ff8240
	move 202(a5),$ff8242
	move.l a5,ptr
	movem.l (a7)+,a5
	bclr #0,$fffa0f
	rte
couleur	
	lea palette,a0
	move.l a0,a1
	add.l #18,a1
	move #8,d0
scoul	rept 10
	move (a1)+,(a0)+
	endr
	dbf d0,scoul
	move.l a0,a1
	addq.l #2,a1
	rept 8
	move (a1)+,(a0)+
	endr
	lea pal,a1
	cmp.l #38,coul
	blt scou
	clr.l coul
scou	add.l coul,a1
	move (a1),(a0)
	addq.l #2,coul
	lea rouleau,a0
	move (a0),-(a7)
	move.l a0,a1
	addq #2,a1
	move #98,d0
sroul	move (a1)+,(a0)+
	dbf d0,sroul
	move (a7)+,(a0)
	rts
          bsr couleur
pal		dc.w 1,2,3,4,5,6,7
		dc.w 6,5,4,3,2,1,0,0,0,0,0,0,0
		dc.w 17,18,19,20,21,22,23,22,21,20,19,18,17
		dc.w 0,0,0,0,0
		rept 4
		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		endr
palette		rept 101
		dc.w 0
		endr
rouleau		rept 2
*		dc.w $427,$527,$627,$727
		dc.w $726,$725,$724,$723,$722
		dc.w $732,$742,$752,$762,$772
		dc.w $772,$762,$752,$742,$732
		dc.w $722,$723,$724,$725,$726
		dc.w $727,$627,$527,$427,$427
		dc.w $427,$527,$627,$727
		dc.w $726,$725,$724,$723,$722
		dc.w $732,$742,$752,$762,$772
		dc.w $772,$762,$752,$742,$732
		dc.w $722,$723,$724,$725,$726
		dc.w $727
*,$627,$527,$427,$427
		endr
iera	ds.b 1
ierb	ds.b 1



ancvbl	ds.l 1






coul	ds.l 1
ptr	ds.l 1
cmpt_coul	ds.w 1
