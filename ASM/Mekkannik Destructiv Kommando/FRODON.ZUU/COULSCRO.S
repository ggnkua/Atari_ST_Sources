p_tbase	clr.l -(a7)
	move.w #$20,-(a7)
	trap #01
	addq.l #6,a7
	
	lea mus,a0
	lea finmus,a1
	lea $71154,a2
kiki	move.l (a0)+,(a2)+
	cmp.l a0,a1
	bge kiki

	lea data,a0
	lea finzizi,a1
	lea $74396,a2
koko	move.l (a0)+,(a2)+
	cmp.l a0,a1
	bge koko

	jsr image

	move.l screen,a0
	move.l screen2,a1
	move.w #8000,d0
contclear
	move.l (a0)+,(a1)+
	dbf d0,contclear
	
	dc.w $a00a

	move.b #$12,$fffc02
	
	clr coul
	lea palette,a0
	move.l a0,ptr
	move #$7,$ff8244
	move #$7,$ff8246
          move #$444,$ff8254
	bsr font_1
	bsr font
	bsr font2

	
	move #$2700,sr

	lea $ff8800,a0
	move.b #0,(a0)
	move.b (a0),port0
	move.b #1,(a0)
	move.b (a0),port1
	move.b #2,(a0)
	move.b (a0),port2
	move.b #3,(a0)
	move.b (a0),port3
	move.b #4,(a0)
	move.b (a0),port4
	move.b #5,(a0)
	move.b (a0),port5
	move.b #6,(a0)
	move.b (a0),port6
	move.b #7,(a0)
	move.b (a0),port7
	move.b #8,(a0)
	move.b (a0),port8
	move.b #9,(a0)
	move.b (a0),port9
	move.b #10,(a0)
	move.b (a0),port10
	move.b #11,(a0)
	move.b (a0),port11
	move.b #12,(a0)
	move.b (a0),port12
	move.b #13,(a0)
	move.b (a0),port13
	move.b #14,(a0)
	move.b (a0),port14
	move.b #15,(a0)
	move.b (a0),port15

	move.b $fffa07,iera
	move.b $fffa09,ierb
	clr.b $fffa07
	and.b #%01000000,$fffa09
	move.l $70,ancvbl
	move #$2300,sr
	move.w #20,d0
	lea scroll_tout,a0
	move.l a0,$70

	bclr #4,$fffa09
	bclr #5,$fffa09
	bclr #0,$fffa13
	bclr #0,$fffa0f
	bclr #0,$fffa0b
	bclr #0,$fffa07	

	lea palette,a5

	pea rout(pc)
	move.w #2,-(a7)
	move.w #8,-(a7)
	move.w #1,-(a7)
	move.w #$1f,-(a7)
	trap #14
	lea 12(a7),a7

	bset #0,$fffa13
	bset #0,$fffa07



	jsr $713a2

	lea $747ce,a0
	jsr $713c8
	
	move.w #1,-(a7)
	trap #01
	addq.l #2,a7
          
	move.w #8,-(a7)
	move.w #$1a,-(a7)
	trap #14
	addq.l #4,a7

	move #$2700,sr
	lea $ff8800,a0
	lea $ff8802,a1
	move.b #0,(a0)
	move.b port0,(a1)
	move.b #1,(a0)
	move.b port1,(a1)
	move.b #2,(a0)
	move.b port2,(a1)
	move.b #3,(a0)
	move.b port3,(a1)
	move.b #4,(a0)
	move.b port4,(a1)
	move.b #5,(a0)
	move.b port5,(a1)
	move.b #6,(a0)
	move.b port6,(a1)
	move.b #7,(a0)
	move.b port7,(a1)
	move.b #8,(a0)
	move.b port8,(a1)
	move.b #9,(a0)
	move.b port9,(a1)
	move.b #10,(a0)
	move.b port10,(a1)
	move.b #11,(a0)
	move.b port11,(a1)
	move.b #12,(a0)
	move.b port12,(a1)
	move.b #13,(a0)
	move.b port13,(a1)
	move.b #14,(a0)
	move.b port14,(a1)
	move.b #15,(a0)
	move.b port15,(a1)
	move.b iera,$fffa07
	move.b ierb,$fffa09
	bset #4,$fffa09
	bset #5,$fffa09
	move.l ancvbl,$70
	
	move #$2300,sr

	dc.w $a009

	move.b #8,$fffc02
          move.w #3,-(a7)
          trap   #14
          addq.l #2,a7
	move   #-1,-(a7)
          move.l d0,-(a7)
          move.l d0,-(a7)
          move   #5,-(a7)
          trap   #14
          adda.l #12,a7
          move.w #$20,-(a7)
          trap   #01
          addq.l #6,a7
          move.w #0,-(a7)	
	trap #01
	rts

image	movem.l img+2,d0-d7	charge la palette
	movem.l d0-d7,$ff8240
	lea	img+34,a4	image compress‚e
	move.l	screen2,a0	plan couleur 0
	move.l  a0,a1 plan couleur 1
	add.l #8000,a1
	move.l	a0,a2	plan couleur 2
	add.l #16000,a2
	move.l	a0,a3	plan couleur 3
	add.l #24000,a3
	move	#199,d0 	200 lignes a d‚compress‚e
.tes	move.l	a0,a5
	bsr.s	dec		pour 4 plans couleur
	move.l	a5,a0
	move.l	a1,a5
	bsr.s	dec
	move.l	a5,a1
	move.l	a2,a5
	bsr.s	dec
	move.l	a5,a2
	move.l	a3,a5
	bsr.s	dec
	move.l	a5,a3
	dbra	d0,.tes

.affi	move.l	screen,a4
	move.l  screen2,a0	pour entrelacer 4 plans
	move.l	a0,a1
	add.l #8000,a1
	move.l	a0,a2
	add.l #16000,a2
	move.l	a0,a3
	add.l #24000,a3
	move	#3999,d0	chaque plan fait 8000 octets
.af1	move	(a0)+,(a4)+
	move	(a1)+,(a4)+
	move	(a2)+,(a4)+
	move	(a3)+,(a4)+
	dbra	d0,.af1

fi	rts


dec	move.b	#0,d1
.dec10	cmpi.b	#40,d1
	beq.s	fi
	move.b	(a4)+,d2
	cmpi.b	#0,d2
	blt.s	.cas
	addq.b	#1,d2
.dec20	move.b	(a4)+,(a5)+
	addq.b	#1,d1
	subq.b	#1,d2
	cmpi.b	#0,d2
	bgt.s	.dec20
	bra.s	.dec10
.cas	neg.b	d2
	addq.b	#1,d2
	move.b	(a4)+,d3
.cas1	move.b	d3,(a5)+
	addq.b	#1,d1
	subq.b	#1,d2
	cmpi.b	#0,d2
	bgt.s	.cas1
	bra.s	.dec10
relog	lea	buffer,a0
	move.l	2(a0),d0
	add.l	6(a0),d0
	lea	memo(pc),a1
	move.l	d0,(a1)
	tst	$1a(a0)
	bne.s	.stop
	move.l	a0,a1
	add.l	#$1c,a1
	move.l	a1,a2
	add.l	2(a0),a2
	add.l	6(a0),a2
	add.l	14(a0),a2
	clr.l	d1
	lea	p_tbase(pc),a0
	move.l	a0,d2
	move.l	(a2)+,d0
.bcle1	add.l	d2,0(a1,d0.l)
.bcle2	move.b	(a2)+,d1
	tst.b	d1
	beq.s	.stop
	add.l	d1,d0
	cmp.b	#1,d1
	bne	.bcle1
	addi.l	#$fd,d0
	bra.s	.bcle2
.stop	rts


rout 	movem.l a5,-(a7)
	move.l ptr,a5
	move (a5)+,$ff8240
	move 202(a5),$ff8244
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


scroll_tout
	movem.l d0-d7/a0-a6,-(a7)
	lea palette,a5
	move.l a5,ptr
	addq #1,cmpt_coul
	cmp #1,cmpt_coul
	ble sd
	clr cmpt_coul
          bsr   couleur	
sd	move.l screen,d0
	swap d0
	move.b d0,$ff8201
	move.l screen,a0
	move.l screen2,screen
	move.l a0,screen2

	jsr $7122a

	cmp #-2,choix
	bne s0
	bra s3

s0	cmp #-5,choix
	bne s1
	bsr scroll
	bra finchoix
	
s1	cmp #-4,choix
	bne s2
	bsr scroll_4
	bra finchoix

s2	cmp #-3,choix
	bne s3
	bsr scroll_2
	bra finchoix

s3	bsr scroll_0
finchoix

	movem.l (a7)+,d0-d7/a0-a6 
	rte


font_1	lea buf,a1
	lea buf_0,a3
	lea tampon,a2
	lea tampon2,a0
	move #0,d2
koko_1	bsr cont_rempli
	addq #1,d2
	cmp #47,d2
	ble koko_1
	rts

font	lea buf_2,a1
	lea buf,a3
	lea tampon,a2
	lea tampon2,a0
	move #0,d2
koko4	bsr cont_rempli2
	addq #1,d2
	cmp #47,d2
	ble koko4
	rts

font2	lea buf_3,a1
	lea buf_2,a3
	lea tampon,a0
	lea tampon2,a2
	move #0,d2
koko5	bsr cont_rempli3
	addq #1,d2
	cmp #47,d2
	ble koko5
	rts

cont_rempli
	rept 16
	move (a3),(a2)
	move (a3),(a0)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+

	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+
	addq #2,a3
	endr
	rts

cont_rempli2
	move #16*2-1,d6

jiji	move (a3),(a2)
	move (a3),(a0)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+

	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+
	addq #2,a3
	dbf d6,jiji
	rts

cont_rempli3
	move #16*4-1,d6

jiji2	move (a3),(a2)
	move (a3),(a0)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+

	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+
	addq #2,a3
	dbf d6,jiji2
	rts

remplibuf2
	lea phrase,a6
	move nbr,d3
	mulu #2,d3
	add.l d3,a6
	move.w (a6),d3
	cmp #0,d3
	bge gigi
	cmp #-1,d3
	beq r.0
	move d3,choix
	bra gi
r.0	clr nbr
	clr d3
gigi	mulu #64*4,d3
	lea buf_3,a0
	add.l d3,a0
	lea buf2,a1
	rept 64
	move.l (a0)+,(a1)+
	endr
gi	addq #1,nbr
	rts

scroll
	bsr scroll4
	rts

copy2	move.l screen2,a0
	move #64,d0
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
deb4	cmp.w #36*4,cmpt_buf
	ble suite4
fin_mot	clr.w cmpt_buf
	bsr remplibuf2	
	
suite4	move.w #15,d0
	move.l screen,a0
	add.l #3*160,a0
	move.l screen2,a4
	add.l #3*160,a4
	lea buf2,a1
cont_scroll4
	move.l a0,a3
	addq.l #8,a3
	rept 19
	move (a3),d6
	swap d6
	move (a0),d6
	rol.l #8,d6
	move d6,(a4)
	addq.l #8,a0
	addq.l #8,a3
	addq.l #8,a4
	endr

	move (a1)+,d6
	swap d6
	move (a0),d6
	rol.l #8,d6
	move d6,(a4)

	move (a1),d6
	swap d6
	move -(a1),d6
	rol.l #8,d6
	move d6,(a1)+
	rept 5	
	addq #2,a1

	move (a1),d6
	swap d6
	move -(a1),d6
	rol.l #8,d6
	move d6,(a1)+
	endr

	move (a1),d6
	swap d6
	move 2(a1),d6
	asl.l #8,d6
	move d6,2(a1)
	swap d6
	move d6,(a1)

	move.l a4,a2
	sub.l #152,a4
	addq.l #8,a2
	rept 19*11+10
	move (a4),(a2)
	addq #8,a4
	addq #8,a2
	endr
	move (a4),(a2)
	add.l #168,a4
	add.l #11*160+8,a0
	addq.l #4,a1
	dbf d0,cont_scroll4 
	addq.w #8,cmpt_buf
	dbf d1,deb4
	rts

***********mul *4***********

remplibuf2_4
	lea phrase,a6
	move nbr,d3
	mulu #2,d3
	add.l d3,a6
	move.w (a6),d3
	cmp #0,d3
	bge gigi4
	cmp #-1,d3
	beq r.1
	move d3,choix
	bra gi1
r.1	clr nbr
	clr d3
		
gigi4	mulu #64*2,d3
	lea buf_2,a0
	add.l d3,a0
	lea buf2,a1
	rept 32
	move.l (a0)+,(a1)+
	endr
gi1	addq #1,nbr
	rts

scroll_4
	bsr scroll4_4
	move.l screen2,a1
	add.l #160*68,a1
	bsr.s copy2_4
	move.l screen2,a1
	add.l #160*135,a1
	bsr.s copy2_4
	rts

copy2_4	move.l screen2,a0
	add.l #160*2,a0
	move #64,d0
hihi_4	rept 19
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	endr
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	dbf d0,hihi_4		
	rts

scroll4_4
	moveq.w #0,d1
deb4_4	cmp.w #36*2,cmpt_buf
	ble suite4_4
	clr.w cmpt_buf
	bsr remplibuf2_4	
	
suite4_4
	move.w #15,d0
	move.l screen,a0
	add.l #160*2,a0
	move.l screen2,a4
	add.l #160*2,a4
	lea buf2,a1
cont_scroll4_4
	move.l a0,a3
	addq.l #8,a3
	rept 19
	move (a3),d6
	swap d6
	move (a0),d6
	rol.l #4,d6
	move d6,(a4)
	addq.l #8,a0
	addq.l #8,a3
	addq.l #8,a4
	endr

	move (a1)+,d6
	swap d6
	move (a0),d6
	rol.l #4,d6
	move d6,(a4)

	move (a1),d6
	swap d6
	move -(a1),d6
	rol.l #4,d6
	move d6,(a1)+
	
	addq #2,a1

	move (a1),d6
	swap d6
	move -(a1),d6
	rol.l #4,d6
	move d6,(a1)+
	
	move (a1),d6
	swap d6
	move 2(a1),d6
	asl.l #4,d6
	move d6,2(a1)
	swap d6
	move d6,(a1)

	move.l a4,a2
	sub.l #152,a4
	addq.l #8,a2
	rept 19*3+2
	move (a4),(a2)
	addq #8,a4
	addq #8,a2
	endr
	move (a4),(a2)
	add.l #168,a4
	add.l #160*3+8,a0
	addq.l #4,a1
	dbf d0,cont_scroll4_4 
	addq.w #4,cmpt_buf
	dbf d1,deb4_4
	rts

*****************mul *2*********

cont_rempli_2
	move d2,d3
	mulu #8,d3
	add.l d3,a0
	rept 16
	move (a0),(a2)

	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+

	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)
	roxl (a0)
	roxl (a1)
	roxl (a2)
	roxl (a1)+
	add.l #160,a0
	endr
	rts


remplibuf2_2
	lea phrase,a6
	move nbr,d3
	mulu #2,d3
	add.l d3,a6
	move.w (a6),d3
	cmp #0,d3
	bge gigi2
	cmp #-1,d3
	beq r.2
	move d3,choix
	bra gi2
r.2	clr nbr
	clr d3
	
gigi2	mulu #64,d3
	lea buf,a0
	add.l d3,a0
	lea buf2,a1
	rept 16
	move.l (a0)+,(a1)+
	endr
gi2	addq #1,nbr
	rts

scroll_2
	bsr scroll4_2
	move.l screen2,a1
	add.l #160*167,a1
	bsr.s copy2_2
	rts

copy2_2
	move.l screen2,a0
	add.l #2*160,a0
	move #32,d0
hihi_2	rept 19
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	endr
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	dbf d0,hihi_2		
	rts

scroll4_2
	moveq.w #0,d1
deb4_2	cmp.w #36,cmpt_buf
	ble suite4_2
	clr.w cmpt_buf
	bsr remplibuf2_2	
	
suite4_2
	move.w #15,d0
	move.l screen,a0
	add.l #2*160,a0
	move.l screen2,a4
	add.l #2*160,a4
	lea buf2,a1
cont_scroll4_2
	move.l a0,a3
	addq.l #8,a3
	rept 19
	move (a3),d6
	swap d6
	move (a0),d6
	rol.l #4,d6
	move d6,(a4)
	addq.l #8,a0
	addq.l #8,a3
	addq.l #8,a4
	endr

	move (a1),d6
	swap d6
	move (a0),d6
	rol.l #4,d6
	move d6,(a4)
	
	move (a1),d6
	swap d6
	move 2(a1),d6
	asl.l #4,d6
	move d6,2(a1)
	swap d6
	move d6,(a1)

	move.l a4,a2
	sub.l #152,a4
	addq.l #8,a2
	rept 19
	move (a4),(a2)
	addq #8,a4
	addq #8,a2
	endr
	move (a4),(a2)
	add.l #168,a4
	add.l #168,a0
	addq.l #4,a1
	dbf d0,cont_scroll4_2 
	addq.w #4,cmpt_buf
	dbf d1,deb4_2
	rts

*************mul * 0**********************


remplibuf2_0
	lea phrase,a6
	move nbr,d3
	mulu #2,d3
	add.l d3,a6
	move.w (a6),d3
	cmp #0,d3
	bge gigi0
	cmp #-1,d3
	beq r.3
	move d3,choix
	bra gi3
r.3	clr nbr
	clr d3

gigi0	mulu #32,d3
	lea buf_0,a0
	add.l d3,a0
	lea buf2,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
gi3	addq #1,nbr
	rts

scroll_0
	bsr scroll4_0
	move.l screen2,a1
	add.l #160*182,a1
	bsr.s copy2_0
	rts

copy2_0	move.l screen2,a0
	add.l #160*2,a0
	move #15,d0
hihi_0	rept 19
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	endr
	move (a0),(a1)
	addq #8,a0
	addq #8,a1
	dbf d0,hihi_0		
	rts

scroll4_0
	moveq.w #0,d1
deb4_0	cmp.w #18,cmpt_buf
	ble suite4_0
	clr.w cmpt_buf
	bsr remplibuf2_0	
	
suite4_0
	move.w #15,d0
	move.l screen,a0
	move.l screen2,a4
	add.l #160*2,a0
	add.l #160*2,a4
	lea buf2,a1
cont_scroll4_0
	move.l a0,a3
	addq.l #8,a3
	rept 19
	move (a3),d6
	swap d6
	move (a0),d6
	rol.l #4,d6
	move d6,(a4)
	addq.l #8,a0
	addq.l #8,a3
	addq.l #8,a4
	endr

	move (a0),d6
	swap d6
	move (a1),d6
	asl.l #4,d6
	move d6,(a1)
	swap d6
	move d6,(a4)
	add.l #8,a0
	add.l #8,a4
	addq.l #2,a1
	dbf d0,cont_scroll4_0
	addq.w #4,cmpt_buf
	dbf d1,deb4_0
	rts

	section data
buf_lettre
buf_0 incbin '\frodon.zuu\font.dat'
		rept 33
		dc.w 0
		endr
cmpt_buf	dc.w 0
cmpt_buf2	dc.w 0
nbr		dc.w 0
screen2		dc.l $e8000
screen		dc.l $d8000
pal
                    dc.w 0,0,0,0,0,0,0,0
palette		rept 101
		dc.w 0
		endr
rouleau		rept 4
		dc.w $222,$222,$222,$222,$222
		dc.w $222,$222,$222,$222,$222
		dc.w $222,$222,$222,$555,$555
		dc.w $555,$555,$555,$555,$555
		dc.w $555,$555,$555,$555,$555
		*dc.w $443,$552,$661,$770,$760
		*dc.w $750,$740,$730,$720,$710
		*dc.w $700,$711,$722,$733,$744

		*dc.w $755,$766,$777,$767,$757
		*dc.w $747,$737,$727,$717,$707
                    endr

phrase
	dc.w -3,24,4,4,0,14,20,20,26,19,7,0,19,48
          dc.w 22,14,17,10,18,48,32,32,32,48,48
          dc.w 8,19,48,22,0,18,48,7,0,17,3,48,1,20,19,48,8,48
          dc.w 7,0,21,4,48,18,20,2,2,4,4,3,48,8,13,48,12,0,10,8
          dc.w 13,6,48,19,7,8,18,48,18,2,17,14,11,11,48,32,32,48,8
          dc.w 19,29,18,48,0,48,11,14,21,4,11,24,48,14,13,4,26
          dc.w 8,18,13,29,19,48,8,19,48,47,47,48,19,7,4,13,26,22,7
          dc.w 0,19,29,18,48,13,4,22,48,3,14,2,48,47,48,48,48,9,20,18
          dc.w 19,48,19,7,8,18,48,6,0,12,4,48,22,7,8,2,7,48,22,0,18
          dc.w 48,2,17,0,2,10,4,3,48,1,24,48,19,7,4,48,1,17,0,8,13,26,14,13,4
          dc.w 48,14,5,48,19,18,19,27,48,19,7,4,48,14,19,7,4,17,18,48,0,17,4
          dc.w 48,28,48,5,8,5,8,17,4,26,6,11,14,14,18,7,26,8,14,13,8,23,26
          dc.w 19,14,12,48,18,19,0,17,26,17,8,2,20,18,48,0,13,3,48,10,8,5,8
          dc.w 17,4,27,48,13,14,22,26,9,20,18,19,48,18,14,12,4,48,5,0,18,19
          dc.w 48,6,17,4,4,19,8,13,6,18,48,33,5,0,18,19,26,1,4,2,0,20,18,4
          dc.w 48,19,7,4,48,1,27,0,27,2,27,48,14,5,48,5,17,4,13,2,7,48,8,18
          dc.w 48,8,13,48,19,22,14,48,7,14,20,17,18,27,27,27,34,27,48,19,7,4,24
          dc.w 48,0,17,4,48,18,4,13,3,48,19,14,28,48,19,7,4,48,17,4,15,11,8
          dc.w 2,0,13,19,18,33,3,14,12,26,5,20,17,24,26,18,13,0,10,4,48,0,13,3,48
          dc.w 4,11,22,14,14,3,48,32,32,34,26,1,20,1,26,12,0,13,3,17,0,23,26,19,7,4,48,2,27,18,27,19,27,33,7,4,11,11,14,48
          dc.w 18,19,4,15,7,32,32,34,26,19,7,4,48,18,15,24,9,0,2,10,2,8,4,26
          dc.w 0,11,11,48,14,20,17,18,48,5,17,8,4,13,3,18,48,0,13,3,48,19,14
          dc.w 48,24,14,20,27,27,27,27,27,48,48,48,1,24,4,48,1,24,4,48,0,13,3
          dc.w 48,18,4,4,48,24,14,20,48,18,14,14,13,27,27,27,27,48,48,48,48,48,48,48,48,48,48,48,48,48,48
          dc.w 48,48,48,48,48,48,48,48,48,-3,48,-1


	even
img	incbin '\frodon.zuu\harrier.pc1',0
	even
mus	incbin '\frodon.zuu\elim.mus'
finmus
	even
data	incbin '\frodon.zuu\elim4.dat'
finzizi

port0	dc.b 0
port1	dc.b 0
port2	dc.b 0
port3	dc.b 0
port4	dc.b 0
port5	dc.b 0
port6	dc.b 0
port7	dc.b 0
port8	dc.b 0
port9	dc.b 0
port10	dc.b 0
port11	dc.b 0
port12	dc.b 0
port13	dc.b 0
port14	dc.b 0
port15	dc.b 0

	section bss
	even
buffer	ds.l 100
memo	ds.l 10
iera	ds.b 1
ierb	ds.b 1
buf 	ds.l 800
buf_2	ds.l 800*4
buf_3	ds.l 800*8
ancvbl	ds.l 1
buf2 ds.l 100
tampon2	ds.w 1
tampon  ds.w 1
choix	ds.w 1

space   ds.w 200
coul	ds.l 1
ptr	ds.l 1
phys      ds.l 1
cmpt_coul	ds.w 1






