	clr.l -(a7)
	move.w #$20,-(a7)
	trap #01
	addq.l #6,a7

	move.l #$f8000,a0
	move.w #8000,d0
contclear
	clr.l (a0)+
	dbf d0,contclear
	
	dc.w $a00a

	move.b #$12,$fffc02
	
	move.w #-1,-(a7)
	move.l #$f8000,-(a7)
	move.l #$f8000,-(a7)
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	pea buf_lettre+2
	move.w #6,-(a7)
*	trap #14
	addq.w #6,a7

	jsr rempli_buf
	bsr remplibuf2
	move #$2700,sr
	move.l $70,ancvbl
	move #$2300,sr
	move.w #20,d0
	lea scroll,a0
	move.l a0,$70
clav	
*	bsr scroll
*	cmp.b #$39,$fffc02
*	bne clav
	
	move.w #1,-(a7)
	trap #01
	addq.l #2,a7
	clr.l $4d2
	move #$2700,sr
	move.l ancvbl,$70
	move #$2300,sr

	dc.w $a009

	move.b #8,$fffc02

	move.w #$777,$ff8240
	clr.l -(a7)
	trap #01
	rts

rempli_buf
	
	lea buf_lettre+34,a0
	lea buf,a1
	lea tampon,a2
	move #0,d2
koko	bsr cont_rempli
	lea buf_lettre+34,a0
	addq #1,d2
	cmp #18,d2
	ble koko

	lea buf_lettre+34+16*160,a0
	lea tampon,a2
	move #0,d2
koko2	bsr cont_rempli
	lea buf_lettre+34+16*160,a0
	addq #1,d2
	cmp #18,d2
	ble koko2

	lea buf_lettre+34+32*160,a0
	lea tampon,a2
	move #0,d2
koko3	bsr cont_rempli
	lea buf_lettre+34+32*160,a0
	addq #1,d2
	cmp #9,d2
	ble koko3
	rts

cont_rempli
	move d2,d3
	mulu #8,d3
	add.l d3,a0
	rept 16
	move (a0),(a1)+
	add.l #160,a0
	endr
	rts


remplibuf2
	
	move nbr,d3
	mulu #32,d3
	lea buf,a0
	add.l d3,a0
	lea buf2,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	addq #1,nbr
	cmp #48,nbr
	bne gigi
	clr nbr
gigi	rts

scroll
	movem.l d0-d7/a0-a6,-(a7)
	move sr,-(a7)
	move #$2700,sr
*	clr $ff8240
	bsr scroll4
	move.l #$f8002+160*16,a1
	bsr.s copy2
	move.l #$f8002+160*33,a1
	bsr.s copy2
	move.l #$f8004+160*50,a1
	bsr.s copy2
	move.l #$f8004+160*67,a1
	bsr.s copy2
	move.l #$f8006+160*82,a1
	bsr.s copy2
	move.l #$f8006+160*99,a1
	bsr.s copy2
	move.l #$f8000+160*116,a1
	bsr.s copy2
	move.l #$f8000+160*133,a1
	bsr.s copy2
	move.l #$f8002+160*150,a1
	bsr.s copy2
	move.l #$f8002+160*167,a1
	bsr.s copy2
	move.l #$f8002+160*184,a1
	bsr.s copy2
	move (a7)+,sr
	
	
	movem.l (a7)+,d0-d7/a0-a6
	move #$777,$ff8240
	rte

copy2	move.l #$f8000,a0
	move #15,d0
hihi	rept 19
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	endr
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	dbf d0,hihi		
	rts

scroll4
	moveq.w #0,d1
deb4	cmp.w #18,cmpt_buf
	ble suite4
fin_mot	clr.w cmpt_buf
	bsr remplibuf2	
	
suite4	move.w #15,d0
	move.l #$f8000,a0
	lea buf2,a1
cont_scroll4
	move.l a0,a3
	addq.l #8,a3
	rept 19
	move (a3),d6
	swap d6
	move (a0),d6
	rol.l #4,d6
	move d6,(a0)
	addq.l #8,a0
	addq.l #8,a3
	endr

	move (a0),d6
	swap d6
	move (a1),d6
	asl.l #4,d6
	move d6,(a1)
	swap d6
	move d6,(a0)
	add.l #8,a0
	addq.l #2,a1
	dbf d0,cont_scroll4 
	addq.w #4,cmpt_buf
	dbf d1,deb4
	rts

	section data
buf_lettre incbin 'domi.pi1'
cmpt_buf	dc.w 0
cmpt_buf2	dc.w 0
nbr		dc.w 0
	section bss
	even
buf ds.l 800
ancvbl	ds.l 1
buf2 ds.l 100
tampon ds.w 1