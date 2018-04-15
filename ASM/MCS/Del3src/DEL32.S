	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	MOVE.L #0,$4D2
	MOVE.L #0,$4D6
	move.w	#0,$FF8900
	MOVE.W	#$486,$FFFF8922
	move.w #0,-(a7)
	move.l #$78000,-(a7)
	move.l #$78000,-(a7)
	move.w #5,-(a7)
	trap #14
	add.l #12,a7

	lea palimg,a0
	lea $ff8240,a1
	rept 8
	move.l (a0)+,(a1)+
	endr
	pea txt
	move.w #9,-(a7)
	trap #1
	add.l #6,a7
	JSR	INIT_MUZEXX
	JSR	PLAY_MUZEXX
TST2	cmp.b #1,$fffc02
	BNE	TST2
	pea txt2
	move.w #9,-(a7)
	trap #1
	add.l #6,a7
tst	cmp.b #1,$fffc02
	bne tst

	move.l #0,d2
	move.l #76,d3
	bsr calc

	bsr inter
	move.l #prog,$70
key:
	cmp.b #$39,$fffc02
	bne key

	move.b #0,$ff8265
	move.b #0,$ff820f
	move.l s70,$70
	move.l s120,$120
	move.b sa21,$fffa21
	move.b sa1b,$fffa1b
	move.b sa07,$fffa07
	move.b sa13,$fffa13
	move.b sa09,$fffa09
	MOVE.L	#0,$4D2
	move.w	#0,$FF8900
	JMP	$8C
inter
	move.l $120,s120
	move.l $70,s70
	move.l $70,j+2
	move.b $fffa21,sa21
	move.b $fffa1b,sa1b
	move.b $fffa07,sa07 
 	move.b $fffa13,sa13
	move.b $fffa09,sa09
 	and.b #$ef,$fffa13
 	and.b #$ef,$fffa0f
 	and.b #$ef,$fffa0b
 	clr.b $fffa07
 	clr.b $fffa1b
	clr.b $fffa09
 	or.b #1,$fffa07
 	or.b #1,$fffa13
	rts
s120	dc.l 0
s70	dc.l 0
sa21	dc.l 0
sa1b	dc.l 0
sa07	dc.l 0
sa13	dc.l 0
sa09	dc.l 0

prog	
	move.b #1,$fffa21
	move.b #8,$fffa1b
	move.l #0,pospal
	move.l #0,$ff8240+26
	movem.l a0-a6/d0-d3,-(a7)
	move.l palhbl,a4
	cmp.l #palhbl1,a4
	bne pal2
	move.l #palhbl2,palhbl
	move.l #t,$120.w
	bra pal1
pal2	move.l #palhbl1,palhbl
	move.l #i,$120.w
pal1	lea tab1,a4
	add.l pos1,a4
	cmp.b #-1,(a4)
	bne ct1
	lea tab1,a4
	move.l #0,pos1
ct1	move.b (a4)+,$ff8265
	move.b (a4)+,$ff820f
	move.b (a4)+,$ff8209
	move.b (a4)+,$ff8207
	move.b (a4)+,$ff8205
	add.l #5,pos1
	lea tab2,a4
	add.l pos2,a4
	cmp.b #-1,(a4)
	bne ct2
	lea tab2,a4
	move.l #0,pos2
ct2	move.b (a4)+,it2a+3
	move.b (a4)+,it2b+3
	move.b (a4)+,it2c+3
	move.b (a4)+,it2d+3
	move.b (a4)+,it2e+3
	add.l #5,pos2
	lea tab3,a4
	add.l pos3,a4 
	cmp.b #-1,(a4)
	bne ct3
	lea tab3,a4
	move.l #0,pos3
ct3	move.b (a4)+,it3a+3
	move.b (a4)+,it3b+3
	move.b (a4)+,it3c+3
	move.b (a4)+,it3d+3
	move.b (a4)+,it3e+3
	add.l #5,pos3
	lea tab4,a4
	add.l pos4,a4
	cmp.b #-1,(a4)
	bne ct4
	lea tab4,a4
	move.l #0,pos4
ct4	move.b (a4)+,it4a+3
	move.b (a4)+,it4b+3
	move.b (a4)+,it4c+3
	move.b (a4)+,it4d+3
	move.b (a4)+,it4e+3
	add.l #5,pos4
	lea tab5,a4
	add.l pos5,a4
	cmp.b #-1,(a4)
	bne ct5
	lea tab5,a4
	move.l #0,pos5
ct5	move.b (a4)+,it5a+3
	move.b (a4)+,it5b+3
	move.b (a4)+,it5c+3
	move.b (a4)+,it5d+3
	move.b (a4)+,it5e+3
	add.l #5,pos5
	lea tab6,a4
	add.l pos6,a4
	cmp.b #-1,(a4)
	bne ct6
	lea tab6,a4
	move.l #0,pos6
ct6	move.b (a4)+,it6a+3
	move.b (a4)+,it6b+3
	move.b (a4)+,it6c+3
	move.b (a4)+,it6d+3
	move.b (a4)+,it6e+3
	add.l #5,pos6
	CMP.B #70,WAIT
	BEQ  SOUND
	ADD.B #1,WAIT
	BSR affesca
	BRA NOSOUNDYET
SOUND	MOVE.L #VBL,$4D2.W
	MOVE.L	#$4E714E71,SOUND
	MOVE.L	#$4E714E71,SOUND+4
	lea esca,a0
	add.l	esca1,a0
	cmp.l	#-1,(a0)
	bne escsuit
	move.l #-4,esca1
	lea esca,a0
escsuit
	add.l #4,esca1
	move.l (a0),a0
	lea 	ecran,a1
	add.l	#172*320+92-32,a1
	lea 	ecran,a2
	add.l	#172*320+92+160-32,a2
m	set 0
n	set 0
	rept $1b
	movem.l n(a0),a3-a6/d1-d2
	movem.l a3-a6/d1-d2,m(a1)
	movem.l a3-a6/d1-d2,m(a2)
m	set m+320
n	set n+$20
	endr
	lea tree,a0
	add.l	tr1,a0
	cmp.l #-1,(a0)
	bne treesuit
	move.l	#-4,tr1
	lea tree,a0
treesuit
	add.l #4,tr1
	move.l (a0),a0
	lea ecran,a1
	add.l	#75*320+116-32,a1
	lea ecran,a2
	add.l	#75*320+116+160-32,a2
m	set 0
n	set 0
	rept $f
	movem.l  n(a0),a3-a4
	movem.l  a3-a4,m(a1)
	movem.l  a3-a4,m(a2)
m	set m+320
n	set n+$10
	endr
	lea lapin,a0
	add.l	lap,a0
	cmp.l #-1,(a0)
	bne lapsuit
	move.l	#-4,lap
	lea lapin,a0
lapsuit
	add.l #4,lap
	move.l (a0),a0
	lea ecran,a1
	add.l	#94*320+84-32,a1	
	lea ecran,a2
	add.l	#94*320+84+160-32,a2
m	set 0
n	set 0
	rept $1a
	movem.l n(a0),a3-a6
	movem.l a3-a6,m(a1)
	movem.l a3-a6,m(a2)
m	set m+320
n	set n+$18
	endr
NOSOUNDYET
	movem.l (a7)+,a0-a6/d0-d3
	;MOVE.W		#0,$FF8240
j	jmp $12345678
	
affesca
	lea 	esc1,a0
	lea 	ecran,a1
	add.l	#172*320+92-32,a1
	lea 	ecran,a2
	add.l	#172*320+92+160-32,a2
	move.w #$1b,d0
essc	movem.l (a0),a3-a6/d1-d2
	movem.l a3-a6/d1-d2,(a1)
	movem.l a3-a6/d1-d2,(a2)
	lea	320(a1),a1
	lea	320(a2),a2
	lea	$20(a0),a0
	dbf	d0,essc
	rts

i	move.w #$f,$ff8240+26
	move.l #i1,$120.w
	bclr #0,$fffa0f
	rte
i1	move.w #$f,$ff8240+26
	move.l #i2,$120.w
	bclr #0,$fffa0f
	rte
i2	move.w #$f,$ff8240+26
	move.l #i3,$120.w
	bclr #0,$fffa0f
	rte
i3	move.w #$f,$ff8240+26
	move.l #i4,$120.w
	bclr #0,$fffa0f
	rte
i4	move.w #$f,$ff8240+26
	move.l #i5,$120.w
	bclr #0,$fffa0f
	rte
i5	move.w #$f,$ff8240+26
	move.l #i6,$120.w
	bclr #0,$fffa0f
	rte
i6	move.w #$f,$ff8240+26
	move.l #i7,$120.w
	bclr #0,$fffa0f
	rte
i7	move.w #$f,$ff8240+26
	move.l #i8,$120.w
	bclr #0,$fffa0f
	rte
i8	move.w #7,$ff8240+26
	move.l #i9,$120.w
	bclr #0,$fffa0f
	rte
i9	move.w #7,$ff8240+26
	move.l #i10,$120.w
	bclr #0,$fffa0f
	rte
i10	move.w #$e,$ff8240+26
	move.l #i11,$120.w
	bclr #0,$fffa0f
	rte
i11	move.w #$e,$ff8240+26
	move.l #i12,$120.w
	bclr #0,$fffa0f
	rte
i12	move.w #6,$ff8240+26
	move.l #i13,$120.w
	bclr #0,$fffa0f
	rte
i13	move.w #6,$ff8240+26
	move.l #i14,$120.w
	bclr #0,$fffa0f
	rte
i14	move.w #$d,$ff8240+26
	move.l #i15,$120.w
	bclr #0,$fffa0f
	rte
i15	move.w #$d,$ff8240+26
	move.l #i16,$120.w
	bclr #0,$fffa0f
	rte
i16	move.w #5,$ff8240+26
	move.l #i17,$120.w
	bclr #0,$fffa0f
	rte
i17	move.w #5,$ff8240+26
	move.l #i18,$120.w
	bclr #0,$fffa0f
	rte
i18	move.w #$c,$ff8240+26
	move.l #i19,$120.w
	bclr #0,$fffa0f
	rte
i19	move.w #$c,$ff8240+26
	move.l #i20,$120.w
	bclr #0,$fffa0f
	rte
i20	move.w #$c,$ff8240+26
	move.l #i21,$120.w
	bclr #0,$fffa0f
	rte
i21	move.w #4,$ff8240+26
	move.l #i22,$120.w
	bclr #0,$fffa0f
	rte
i22	move.w #4,$ff8240+26
	move.l #i23,$120.w
	bclr #0,$fffa0f
	rte
i23	move.w #$b,$ff8240+26
	move.l #i24,$120.w
	bclr #0,$fffa0f
	rte
i24	move.w #$b,$ff8240+26
	move.l #i25,$120.w
	bclr #0,$fffa0f
	rte
i25	move.w #3,$ff8240+26
	move.l #i26,$120.w
	bclr #0,$fffa0f
	rte
i26	move.w #3,$ff8240+26
	move.l #i27,$120.w
	bclr #0,$fffa0f
	rte
i27	move.w #$a,$ff8240+26
	move.l #i28,$120.w
	bclr #0,$fffa0f
	rte
i28	move.w #$a,$ff8240+26
	move.l #i29,$120.w
	bclr #0,$fffa0f
	rte
i29	move.w #2,$ff8240+26
	move.l #i30,$120.w
	bclr #0,$fffa0f
	rte
i30	move.w #2,$ff8240+26
	move.l #i31,$120.w
	bclr #0,$fffa0f
	rte
i31	move.w #9,$ff8240+26
	move.l #i32,$120.w
	bclr #0,$fffa0f
	rte
i32	move.w #9,$ff8240+26
	move.l #i33,$120.w
	bclr #0,$fffa0f
	rte
i33	move.w #1,$ff8240+26
	move.l #i34,$120.w
	bclr #0,$fffa0f
	rte
i34	move.w #1,$ff8240+26
	move.l #i35,$120.w
	bclr #0,$fffa0f
	rte
i35	move.w #7,$ff8240+26
	move.l #i36,$120.w
	bclr #0,$fffa0f
	rte
i36	move.w #7,$ff8240+26
	move.l #i37,$120.w
	bclr #0,$fffa0f
	rte
i37	move.l #$03250620,$ff8240+26
	move.b #31,$fffa21
	move.l #it1,$120.w
	bclr #0,$fffa0f
	rte
t	move.w #$f,$ff8240+26
	move.l #t2,$120.w
	bclr #0,$fffa0f
	rte
t2	move.w #$f,$ff8240+26
	move.l #t3,$120.w
	bclr #0,$fffa0f
	rte
t3	move.w #$f,$ff8240+26
	move.l #t4,$120.w
	bclr #0,$fffa0f
	rte
t4	move.w #$f,$ff8240+26
	move.l #t5,$120.w
	bclr #0,$fffa0f
	rte
t5	move.w #$f,$ff8240+26
	move.l #t6,$120.w
	bclr #0,$fffa0f
	rte
t6	move.w #$f,$ff8240+26
	move.l #t7,$120.w
	bclr #0,$fffa0f
	rte
t7	move.w #$f,$ff8240+26
	move.l #t8,$120.w
	bclr #0,$fffa0f
	rte
t8	move.w #7,$ff8240+26
	move.l #t9,$120.w
	bclr #0,$fffa0f
	rte
t9	move.w #7,$ff8240+26
	move.l #t10,$120.w
	bclr #0,$fffa0f
	rte
t10	move.w #$e,$ff8240+26
	move.l #t11,$120.w
	bclr #0,$fffa0f
	rte
t11	move.w #$e,$ff8240+26
	move.l #t12,$120.w
	bclr #0,$fffa0f
	rte
t12	move.w #6,$ff8240+26
	move.l #t13,$120.w
	bclr #0,$fffa0f
	rte
t13	move.w #6,$ff8240+26
	move.l #t14,$120.w
	bclr #0,$fffa0f
	rte
t14	move.w #$d,$ff8240+26
	move.l #t15,$120.w
	bclr #0,$fffa0f
	rte
t15	move.w #$d,$ff8240+26
	move.l #t16,$120.w
	bclr #0,$fffa0f
	rte
t16	move.w #5,$ff8240+26
	move.l #t17,$120.w
	bclr #0,$fffa0f
	rte
t17	move.w #5,$ff8240+26
	move.l #t18,$120.w
	bclr #0,$fffa0f
	rte
t18	move.w #$c,$ff8240+26
	move.l #t19,$120.w
	bclr #0,$fffa0f
	rte
t19	move.w #$c,$ff8240+26
	move.l #t20,$120.w
	bclr #0,$fffa0f
	rte
t20	move.w #$c,$ff8240+26
	move.l #t21,$120.w
	bclr #0,$fffa0f
	rte
t21	move.w #4,$ff8240+26
	move.l #t22,$120.w
	bclr #0,$fffa0f
	rte
t22	move.w #4,$ff8240+26
	move.l #t23,$120.w
	bclr #0,$fffa0f
	rte
t23	move.w #$b,$ff8240+26
	move.l #t24,$120.w
	bclr #0,$fffa0f
	rte
t24	move.w #$b,$ff8240+26
	move.l #t25,$120.w
	bclr #0,$fffa0f
	rte
t25	move.w #3,$ff8240+26
	move.l #t26,$120.w
	bclr #0,$fffa0f
	rte
t26	move.w #3,$ff8240+26
	move.l #t27,$120.w
	bclr #0,$fffa0f
	rte
t27	move.w #$a,$ff8240+26
	move.l #t28,$120.w
	bclr #0,$fffa0f
	rte
t28	move.w #$a,$ff8240+26
	move.l #t29,$120.w
	bclr #0,$fffa0f
	rte
t29	move.w #2,$ff8240+26
	move.l #t30,$120.w
	bclr #0,$fffa0f
	rte
t30	move.w #2,$ff8240+26
	move.l #t31,$120.w
	bclr #0,$fffa0f
	rte
t31	move.w #9,$ff8240+26
	move.l #t32,$120.w
	bclr #0,$fffa0f
	rte
t32	move.w #9,$ff8240+26
	move.l #t33,$120.w
	bclr #0,$fffa0f
	rte
t33	move.w #1,$ff8240+26
	move.l #t34,$120.w
	bclr #0,$fffa0f
	rte
t34	move.w #1,$ff8240+26
	move.l #t35,$120.w
	bclr #0,$fffa0f
	rte
t35	move.w #7,$ff8240+26
	move.l #t36,$120.w
	bclr #0,$fffa0f
	rte
t36	move.w #7,$ff8240+26
	move.l #t37,$120.w
	bclr #0,$fffa0f
	rte
t37	move.w #0,$ff8240+26
	move.l #t38,$120.w
	bclr #0,$fffa0f
	rte
t38	move.l #$03250620,$ff8240+26
	move.b #31,$fffa21
	move.l #it1,$120.w
	bclr #0,$fffa0f
	rte

it	move.w #0,$ff8240+26
	move.l a0,-(a7)
	move.l palhbl,a0
	add.l pospal,a0
	cmp.w #-1,(a0)
	beq finit1
	move.w (a0),it+2
	add.l #2,pospal
	move.l (a7)+,a0
	bclr #0,$fffa0f
	rte
finit1
	move.l #it1,$120.w
	move.b #30,$fffa21
	move.l (a7)+,a0
	bclr #0,$fffa0f
	rte

it1	add.b #1,wait
	cmp.b #2,wait
	bne it1b
	move.b #29,$fffa21
it1b	cmp.b #3,wait
	bne it1a
	move.b #0,wait
	move.b #5,$fffa21
	move.l #it2a,$120
it1a 	bclr #0,$fffa0f
	rte
	
it2a	move.b #0,$ff8265
it2b	move.b #0,$ff820f
it2c	move.b #0,$ff8209
it2d	move.b #0,$ff8207
it2e	move.b #0,$ff8205
	move.b #8,$fffa21
	move.l #it3a,$120
 	bclr #0,$fffa0f
	rte
it3a	move.b #0,$ff8265
it3b	move.b #0,$ff820f
it3c	move.b #0,$ff8209
it3d	move.b #0,$ff8207
it3e	move.b #0,$ff8205
	move.b #12,$fffa21
	move.l #it4a,$120
 	bclr #0,$fffa0f
	rte
it4a	move.b #0,$ff8265
it4b	move.b #0,$ff820f
it4c	move.b #0,$ff8209
it4d	move.b #0,$ff8207
it4e	move.b #0,$ff8205
	move.b #18,$fffa21
	move.l #it5a,$120
 	bclr #0,$fffa0f
	rte
it5a	move.b #0,$ff8265
it5b	move.b #0,$ff820f
it5c	move.b #0,$ff8209
it5d	move.b #0,$ff8207
it5e	move.b #0,$ff8205
	move.b #21,$fffa21
	move.l #it6a,$120.w
 	bclr #0,$fffa0f
	rte
it6a	move.b #0,$ff8265
it6b	move.b #0,$ff820f
it6c	move.b #0,$ff8209
it6d	move.b #0,$ff8207
it6e	move.b #0,$ff8205
	;move.b #30,$fffa21
	;move.l #it7a,$120.w
	clr.b  $fffa21
	clr.b  $fffa1b
 	bclr #0,$fffa0f
	rte

it7a	
	clr.b  $fffa21
	clr.b  $fffa1b
 	bclr #0,$fffa0f
	rte
	
calc
	lea tab1,a1
	move.w #319,d4
calc1
	move.b #76,d3
	add.b #1,d1
	cmp.b #16,d1
	bne cnt1
	move.b #0,d1
	add.l #8,d2
	move.b #80,d3
	cmp.b #160,d2
	bne cnt1
	move.l #0,d2
cnt1:
	move.b d1,(a1)+
	move.b d3,(a1)+
	lea ecran2,a0
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calc1
	lea tab2,a1
	move.w #159,d4
calc2
	move.b #76,d3
	add.b #2,d1
	cmp.b #16,d1
	bne cnt2
	move.b #0,d1
	add.l #8,d2
	move.b #80,d3
	cmp.b #160,d2
	bne cnt2
	move.l #0,d2
cnt2:
	move.b d1,(a1)+
	move.b d3,(a1)+
	lea ecran2+129*320,a0
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calc2

	lea tab3,a1
	move.w #319,d4
	move.b #0,d1
calc3	move.b #76,d3
	add.b #3,d1
	cmp.b #16,d1
	blt cnt3
	sub.b #16,d1
	cmp.b #0,d1
	bne cal3
	move.b #80,d3
cal3	add.l #8,d2
	cmp.b #160,d2
	bne cnt3
	move.l #0,d2
cnt3:
	move.b d1,(a1)+
	move.b d3,(a1)+
	lea ecran2+134*320,a0
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calc3

	lea tab4,a1
	move.w #79,d4
	move.b #0,d1
calc4	move.b #76,d3
	add.b #4,d1
	cmp.b #16,d1
	blt cnt4
	sub.b #16,d1
	cmp.b #0,d1
	bne cal4
	move.b #80,d3
cal4	add.l #8,d2
	cmp.b #160,d2
	bne cnt4
	move.l #0,d2
cnt4:
	move.b d1,(a1)+
	move.b d3,(a1)+
	lea ecran2+142*320,a0
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calc4

	lea tab5,a1
	move.w #63,d4
	move.b #0,d1
calc5	move.b #76,d3
	add.b #5,d1
	cmp.b #16,d1
	blt cnt5
	sub.b #16,d1
	cmp.b #0,d1
	bne cal5
	move.b #80,d3
cal5	add.l #8,d2
	cmp.b #160,d2
	bne cnt5
	move.l #0,d2
cnt5:
	move.b d1,(a1)+
	move.b d3,(a1)+
	lea ecran2+154*320,a0
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calc5

	lea tab6,a1
	move.w #159,d4
	move.b #0,d1
calc6	move.b #76,d3
	add.b #6,d1
	cmp.b #16,d1

	blt cnt6
	sub.b #16,d1
	cmp.b #0,d1
	bne cal6
	move.b #80,d3
cal6	add.l #8,d2
	cmp.b #160,d2
	bne cnt6
	move.l #0,d2
cnt6:
	move.b d1,(a1)+
	move.b d3,(a1)+
	lea ecran2+172*320,a0		;172
	add.l	d2,a0
	move.l a0,d0
	move.b d0,(a1)+
	lsr.w #8,d0
	move.b d0,(a1)+
	swap d0
	move.b d0,(a1)+
	dbf d4,calc6
	rts

INIT_MUZEXX
	LEA		SEQ(PC),A0
	LEA		PAT(PC),A1
	LEA		NBR_INS(PC),A2
	LEA		MUZEXX,A3
	MOVE	#$1D8,(A0)
	MOVE	#$258,(A1)
	MOVE	#15,(A2)
	CMP.L	#'M.K.',$438(A3)
	BNE		REAL_DOCs_MODULE
	MOVE	#$3B8,(A0)
	MOVE	#$43C,(A1)
	MOVE	#31,(A2)
REAL_DOCs_MODULE

	LEA		MUZEXX,A0
	ADD		SEQ(PC),A0
	MOVE.L	#$80,D0
	MOVEQ	#0,D1
INIT_MUZEXX1
	MOVE.L	D1,D2
	SUBQ	#1,D0
INIT_MUZEXX2
	MOVE.B	(A0)+,D1
	CMP.B	D2,D1
	BGT.S	INIT_MUZEXX1
	DBF		D0,INIT_MUZEXX2
	ADDQ.B	#1,D2
	SWAP	D2
	LSR.L	#6,D2
	LEA		MUZEXX,A0
	ADD		PAT,A0
	ADD.L	D2,A0
	LEA		20+MUZEXX,A1
	LEA		16+INS(PC),A2
	MOVE	NBR_INS(PC),D0
	SUBQ	#1,D0
INIT_MUZEXX3
	MOVE.L	A0,4(A2)
	MOVEQ	#0,D1
	MOVE	22(A1),D1
	LSL.L	#1,D1
	MOVE.L	D1,(A2)
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE	24(A1),D1
	BEQ		INIT_MUZEXX4
	SUBQ	#1,D1
INIT_MUZEXX4
	MOVE	D1,12(A2)
	MOVEQ	#0,D1
	MOVE	28(A1),D1
	LSL.L	#1,D1
	CMP.L	#2,D1
	BNE		INIT_MUZEXX5
	MOVEQ	#0,D1
INIT_MUZEXX5
	SWAP	D1
	MOVE.L	D1,8(A2)
	LEA		30(A1),A1
	LEA		16(A2),A2
	DBRA	D0,INIT_MUZEXX3


	MOVE.W	#2,$FF8920   

	LEA		MUSIQUE_END,A0	
	MOVE.L		A0,D0
	MOVE.W		D0,$FF8912
	ROR.L		#8,D0
	MOVE.W		D0,$FF8910
	ROR.L		#8,D0
	MOVE.W		D0,$FF890E

	LEA		MU,A0
	MOVE.L		A0,D0
	MOVE.W		D0,$FF8906
	ROR.L		#8,D0
	MOVE.W		D0,$FF8904
	ROR.L		#8,D0
	MOVE.W		D0,$FF8902
	MOVE.L		#$33fc0003,rt
	MOVE.L		#$00ff8900,rt+4
	
	RTS


PLAY_MUZEXX
ON	
	MOVE	#6,SPD+2
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX,A0
	ADD		SEQ(PC),A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF(PC),A0
	LEA		OFF(PC),A1
	LEA		OFF(PC),A2
	LEA		OFF(PC),A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	MOVE.W	#10080,D0
	LEA	MU,A0
CLRR	MOVE.W #0,(A0)+
	DBF D0,CLRR
	RTS




MUSC		DC.L	MU,MU+1008,MU+2016,MU+3024,MU+4032,MU+5040,MU+6048
		DC.L	MU+7056,MU+8064,MU+9072,MU+10080,MU+11088,MU+12096
		DC.L	MU+13104,MU+14112,MU+15120,MU+16128,MU+17136,MU+18144
		DC.L	MU+19152

AMIGA	
	MOVE.B		MUSI,D7
	ADDQ.B		#4,D7
	CMP.B		#80,D7
	BNE.S		AM3
	MOVEQ.B	#0,D7
AM3
	MOVE.B		D7,MUSI
	MOVE.L		MUSC(PC,D7.W),A4
AMM
	MOVEQ		#0,D7
	MOVE.W		#504,D6
AM2
	SWAP		D0						
	SWAP		D1					
	SWAP		D2					
	SWAP		D3					
V0	SUB.L		#0,D0					
	BMI.S		L0					
V1	SUB.L		#0,D1					
	BMI.S		L1					
V2	SUB.L		#0,D2					
	BMI.S		L2					
V3	SUB.L		#0,D3					
	BMI.S		L3					
OUT	SWAP		D0					
	SWAP		D1					
	SWAP		D2					
	SWAP		D3					
	MOVE.B		0(A0,D0),D4				
	MOVE.B		0(A1,D1),D5				
	ADD.B		0(A2,D2),D4				
	ADD.B		0(A3,D3),D5					
	;SUB.B		#$80,D4
	;SUB.B		#$80,D5
	MOVE.B		D4,(A4)+			
	MOVE.B		D5,(A4)+
	DBF D6,AM2						
rt	MOVE.W 	#3,$FF8900
	MOVE.W		#$4E75,rt
	RTS
	
L0	MOVE.L		#0,D0
F0	MOVE.L		#0,V0+2
	BRA		V1
L1	MOVE.L		#0,D1
F1	MOVE.L		#0,V1+2
	BRA		V2
L2	MOVE.L		#0,D2
F2	MOVE.L		#0,V2+2
	BRA		V3
L3	MOVE.L		#0,D3
F3	MOVE.L		#0,V3+2
	BRA		OUT

VBL	MOVEM.L	D0-D7/A0-A6,-(A7)
	MOVEM.L	REGIS,D0-D6/A0-A6
	;MOVE.W		#$700,$FF8240
	JSR		AMIGA
	MOVE.L	#300,D6
WAA	DBF	D6,WAA
	;MOVE.W		#7,$FF8240
	SUBQ.B	#1,SPEED
	BEQ.S	PLAY
	;MOVE.W		#5,$FF8240
	JSR		EFFECT
END_VBL
	;MOVE.W		#$077,$FF8240
	MOVEM.L	D0-D6/A0-A6,REGIS
	MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS

PLAY
NO_KEYBOARD1
	MOVEM.L	D0-D1/A0-A5,-(SP)
SPD	MOVE.B	#6,SPEED
	SUBQ.B	#1,POS
	BNE		NO_NEW_PATTERN
	MOVE.B	#64,POS
	ADDQ.L	#1,MUS+2
	SUBQ.B	#1,TRK
	BMI		RESTART
	MOVEQ	#0,D0
MUS	MOVE.B	$0,D0
	SWAP	D0
	LSR.L	#6,D0
	LEA		MUZEXX,A0
	ADD		PAT(PC),A0
	ADD.L	D0,A0
	MOVE.L	A0,ADD_IN_PAT
NO_NEW_PATTERN
	MOVE.L	ADD_IN_PAT(PC),A0
	LEA		FRQ(PC),A1
	LEA		INS(PC),A2
	LEA		COMMAND,A3
	LEA		VOICE0(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE1(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE2(PC),A4
	BSR		LOAD_VOICE
	LEA		VOICE3(PC),A4
	BSR		LOAD_VOICE
	MOVE.L	A0,ADD_IN_PAT
	MOVEM.L	(SP)+,D0-D1/A0-A5
* ADDRESS ALL 4 VOICES
	MOVEM.L	D4/A5,-(SP)
	LEA		VOICE0(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT0
	MOVE.L	(A5),D0
	MOVE.L	4(A5),A0
	MOVE.L	8(A5),D4
	MOVE.L	D4,L0+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V0+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F0+2
CONT0
	CLR.B	20(A5)
	LEA		VOICE1(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT1
	MOVE.L	(A5),D1
	MOVE.L	4(A5),A1
	MOVE.L	8(A5),D4
	MOVE.L	D4,L1+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V1+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F1+2
CONT1
	CLR.B	20(A5)
	LEA		VOICE2(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT2
	MOVE.L	(A5),D2
	MOVE.L	4(A5),A2
	MOVE.L	8(A5),D4
	MOVE.L	D4,L2+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V2+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F2+2
CONT2
	CLR.B	20(A5)
	LEA		VOICE3(PC),A5
	TST.B	20(A5)
	BEQ.S	CONT3
	MOVE.L	(A5),D3
	MOVE.L	4(A5),A3
	MOVE.L	8(A5),D4
	MOVE.L	D4,L3+2
	MOVE.L	12(A5),D4
	MOVE.L	D4,V3+2
	MOVE.L	16(A5),D4
	MOVE.L	D4,F3+2
CONT3
	CLR.B	20(A5)
	MOVEM.L	(SP)+,D4/A5

	BRA		END_VBL

LOAD_VOICE
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE	D0,30(A4)
	MOVE	(A0)+,D0
	BEQ.S	COMMAND?
	BTST	#12,D0
	BEQ.S	CONT_FRQ
	AND		#$FFF,D0
	MOVE	#$100,D1
CONT_FRQ
	MOVE.B	#1,20(A4)
	MOVE	D0,24(A4)
	ADD		D0,D0
	ADD		D0,D0
	MOVE.L	(A1,D0.W),D0
	MOVE.L	D0,12(A4)
	TST.L	16(A4)
	BEQ.S	CONT_LOAD_FRQ
	MOVE.L	D0,16(A4)
CONT_LOAD_FRQ
	OR.B	(A0),D1
	AND		#$FF0,D1
	BEQ.S	COMMAND?
	MOVE.L	12(A4),16(A4)
	MOVE.L	0(A2,D1.W),(A4)
	MOVE.L	4(A2,D1.W),4(A4)
	MOVE.L	8(A2,D1.W),8(A4)
	BNE.S	REPEAT
	CLR.L	16(A4)
REPEAT
COMMAND?
	MOVE	(A0)+,D0
	MOVE.B	D0,D1
	AND		#$F00,D0
	LSR		#6,D0
	MOVE.L	(A3,D0.W),A5
	JMP		(A5)

NO_COMMAND
	RTS

ARPEGGIO
	TST.B	D1
	BEQ.S	NO_ARPEGGIO
	MOVE.B	#0,22(A4)
	MOVE.B	D1,23(A4)
	MOVE.B	#1,21(A4)		*ARPEGGIO COUNTER
	MOVE	#1,30(A4)
NO_ARPEGGIO
	RTS

PORTAMENTO_UP
	MOVE.B	#1,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

PORTAMENTO_DOWN
	MOVE.B	#2,22(A4)
	MOVE.B	D1,23(A4)
	MOVE	#1,30(A4)
	RTS

POSITION_JUMP
	LEA		MUZEXX,A5
	ADD		SEQ(PC),A5
	LEA		-1(A5),A5
	MOVE.B	#1,POS
	MOVE.L	A5,D0
	ADD.L	D1,D0
	MOVE.L	D0,MUS+2
	MOVE.B	-1(A5),D0
	SUB		D1,D0
	MOVE.B	D0,TRK
	RTS

SET_VOLUME
	TST.B	D1
	BNE.S	NO_CHANGE			*NO REAL TIME VOLUME VARIATION
	CLR.L	12(A4)				*IN THIS VERSION! MAYBE
	MOVE.B	#1,20(A4)			*SOME OTHER DAY...
NO_CHANGE
	RTS

PATTERN_BREAK
	MOVE.B	#1,POS
	RTS

SET_FILTER
	RTS

SET_SPEED
	MOVE.B	D1,SPD+3
	MOVE.B	D1,SPEED
	RTS

COMMAND		DC.L	ARPEGGIO,PORTAMENTO_UP,PORTAMENTO_DOWN,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,NO_COMMAND
			DC.L	NO_COMMAND,NO_COMMAND,NO_COMMAND,POSITION_JUMP
			DC.L	SET_VOLUME,PATTERN_BREAK,SET_FILTER,SET_SPEED

EFFECT
	MOVEM.L	D4-D6/A4-A6,-(SP)
	LEA		FRQ(PC),A5
	LEA		VOICE0(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT1
	BSR		DO_EFFECT
	MOVE.L	26(A6),V0+2
	TST.L	F0+2
	BEQ.S	CONT_EFFECT1
	MOVE.L	26(A6),F0+2
CONT_EFFECT1
	LEA		VOICE1(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT2
	BSR		DO_EFFECT
	MOVE.L	26(A6),V1+2
	TST.L	F1+2
	BEQ.S	CONT_EFFECT2
	MOVE.L	26(A6),F1+2
CONT_EFFECT2
	LEA		VOICE2(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT3
	BSR		DO_EFFECT
	MOVE.L	26(A6),V2+2
	TST.L	F2+2
	BEQ.S	CONT_EFFECT3
	MOVE.L	26(A6),F2+2
CONT_EFFECT3
	LEA		VOICE3(PC),A6
	TST		30(A6)
	BEQ.S	CONT_EFFECT4
	BSR		DO_EFFECT
	MOVE.L	26(A6),V3+2
	TST.L	F3+2
	BEQ.S	CONT_EFFECT4
	MOVE.L	26(A6),F3+2
CONT_EFFECT4
	MOVEM.L	(SP)+,D4-D6/A4-A6
	RTS

DO_EFFECT
	MOVE.B	22(A6),D4
	BEQ.S	ARPEGGIO_ROUT
	CMP.B	#1,D4
	BEQ.S	PORTUP
	CMP.B	#2,D4
	BEQ.S	PORTDOWN
	RTS

PORTUP
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	SUB		D4,D5
	CMP		#$71,D5
	BPL.S	OK_PORTUP
	MOVEQ	#$71,D5
OK_PORTUP
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

PORTDOWN
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	MOVE	24(A6),D5
	ADD		D4,D5
	CMP		#$358,D5
	BMI.S	OK_PORTDOWN
	MOVE	#$358,D5
OK_PORTDOWN
	MOVE	D5,24(A6)
	ADD		D5,D5
	ADD		D5,D5
	MOVE.L	(A5,D5),26(A6)
	RTS

ARPEGGIO_ROUT
	MOVE.B	21(A6),D4
	CMP.B	#1,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#2,D4
	BEQ.S	ARP_ROUT2
	CMP.B	#3,D4
	BEQ.S	ARP_ROUT3
	CMP.B	#4,D4
	BEQ.S	ARP_ROUT1
	CMP.B	#5,D4
	BEQ.S	ARP_ROUT2
	RTS

ARP_ROUT1
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	LSR.B	#4,D4
	BRA.S	ARP_ROUT
ARP_ROUT2
	MOVEQ	#0,D4
	MOVE.B	23(A6),D4
	AND.B	#$0F,D4
	BRA.S	ARP_ROUT
ARP_ROUT3
	MOVE	24(A6),D6
	BRA.S	END_ARP_ROUT2
ARP_ROUT
	ADD		D4,D4
	MOVE	24(A6),D5
	LEA		ARPEGGIO_DATA(PC),A4
ARP_LOOP
	CMP		(A4),D5
	BEQ.S	END_ARP_ROUT1
	LEA		2(A4),A4
	BRA.S	ARP_LOOP
END_ARP_ROUT1
	MOVE	(A4,D4),D6
END_ARP_ROUT2
	ADD		D6,D6
	ADD		D6,D6
	MOVE.L	(A5,D6),26(A6)
	ADDQ.B	#1,21(A6)
	RTS

RESTART
	MOVEM.L	(SP)+,D0-D1/A0-A5
	MOVE	#6,SPD+2 
	MOVE.B	#6,SPEED
	MOVE.B	#1,POS
	LEA		MUZEXX,A0
	ADD		SEQ,A0
	LEA		-2(A0),A0
	MOVE.B	(A0)+,TRK
	MOVE.L	A0,MUS+2
	LEA		OFF,A0
	LEA		OFF,A1
	LEA		OFF,A2
	LEA		OFF,A3
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVEQ	#0,D3
	CLR.L	V0+2
	CLR.L	V1+2
	CLR.L	V2+2
	CLR.L	V3+2
	CLR.L	F0+2
	CLR.L	F1+2
	CLR.L	F2+2
	CLR.L	F3+2
	BRA		PLAY

END_OF_MUZEXX
	RTS




FILENAME	DC.B	40,0
			DS.B	40
OFF			DC.L	0
SPEED		DC.B	0
POS			DC.B	0
TRK			DC.B	0
SEQ			DS.W	1
PAT			DS.W	1
NBR_INS		DS.W	1
FRQ			incbin 25_khz.frq
ARPEGGIO_DATA		DC.W	$0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
			DC.W	$023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
			DC.W	$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0
			DC.W	$00E2,$00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097
			DC.W	$008F,$0087,$007F,$0078,$0071,$0000,$0000,$0000

SVBL		DS.L	0
TIMERA		DS.L	1
SAVE_STACK	DS.L	1
			DS.L	128
STACK
SWITCH		DS.W	1
KEY_PRESS	DS.W	1
VOICE0		DS.L	8
VOICE1		DS.L	8
VOICE2		DS.L	8
VOICE3		DS.L	8
ADD_IN_PAT	DS.L	1
REGIS		DS.L	14
MU			DS.W 		10080
MUSIQUE_END		DS.L		10
MUSI			DS.L		0
INS			DS.L	32*4


pos1:	dc.l 0
pos2:	dc.l 0
pos3:	dc.l 0
pos4:	dc.l 0
pos5:	dc.l 0
pos6:	dc.l 0
wait	dc.b 0
z
	dc.b 1
	even
palimg dc.w $0000,$0020,$0030,$0040,$0060,$0310,$0420,$0530
       dc.w $0542,$0654,$0200,$0010,$0666,$0325,$0620,$0444


palhbl1
	dc.w $f,$f,$f,$f,$f,$f,$f,$f,7,7,$e,$e,6,6,$d,$d,5,5,$c,$c
	dc.w 4,4,$b,$b,3,3,$a,$a,2,2,9,9,1,1,8,8,0,0,-1
palhbl2
	dc.w $f,$f,$f,$f,$f,$f,$f,7,7,$e,$e,6,6,$d,$d,5,5,$c,$c,4,4
	dc.w $b,$b,3,3,$a,$a,2,2,9,9,1,1,8,8,0,0,0,-1
palhbl dc.l palhbl1
pospal dc.l 0
color  dc.w 0
ecran  dc.l 0
ecran2
	incbin img2.ste
tab1
	dcb.b 5*320
	dc.b -1	
	even
tab2	dcb.b 5*160
	dc.b -1
	even
tab3	dcb.b 5*320
	dc.b -1
	even
tab4	dcb.b 5*80
	dc.b -1
	even
tab5	dcb.b 5*64
	dc.b -1
tab6	dcb.b 5*160
	dc.b -1
	even
esca	rept 90
	dc.l esc1,esc1
	endr
	dc.l esc2,esc2,esc2,esc3,esc3,esc3,esc4,esc4,esc4
	rept 60
	dc.l esc5,esc5
	endr
	dc.l esc4,esc4,esc4,esc3,esc3,esc3,esc2,esc2,esc2
	rept 50
	dc.l esc1,esc1
	endr
	dc.l esc2,esc2,esc2,esc3,esc3,esc3,esc4,esc4,esc4
	rept 40
	dc.l esc5,esc5
	endr
	dc.l esc4,esc4,esc4,esc3,esc3,esc3,esc2,esc2,esc2,-1
esca1	dc.l 0

esc1	incbin esc1
esc2	incbin esc2
esc3	incbin esc3
esc4	incbin esc4
esc5	incbin esc5
tree	rept	110
	dc.l   tre1,tre1
	endr
	dc.l	tre1,tre1,tre1,tre2,tre2,tre2,tre3,tre3,tre3,tre4,tre4,tre4
	rept	40
	dc.l	tre5,tre5
	endr
	dc.l	tre5,tre5,tre5,tre5,tre5,tre5,tre5,tre4,tre4,tre4
	dc.l	tre3,tre3,tre3,tre2,tre2,tre2,tre1,tre1,tre1,tre1,tre1,-1
tr1	dc.l 0
tre1	incbin	tree1
tre2	incbin	tree2
tre3	incbin	tree3
tre4	incbin	tree4
tre5	incbin	tree5
lapin	rept	100
	dc.l	lap1,lap1
	endr
	dc.l	lap1,lap1,lap1,lap2,lap2,lap2,lap3,lap3,lap3,lap4,lap4,lap4
	rept   50
	dc.l	lap5,lap5
	endr
	dc.l	lap5,lap5,lap5,lap5,lap5,lap5,lap5,lap4,lap4,lap4
	dc.l	lap3,lap3,lap3,lap2,lap2,lap2,lap1,lap1,lap1,lap1,lap1,-1
lap	dc.l 0
lap1	incbin	lap1
lap2	incbin	lap2
lap3	incbin	lap3
lap4	incbin	lap4
lap5	incbin	lap5
WAIT	DC.W 0
	EVEN
txt	      ****************************************
	dc.b $1b,'E  Hello',$a,$d,$a,$d
	dc.b ' Here is my first demo on the STE',$d,$a,$d,$a
	dc.b '             FIND THE BEAST',$d,$a,$d,$a
	dc.b '    using 6 differential scrolls ,',$d,$a 
	dc.b '        and a soundtracker',$d,$a
	dc.b 'at 25 KHZ in stereo , 4 channels',$d,$a,$d,$a
	dc.b 'At the top there is 32 shades of blue',$d,$a
	dc.b 'making a 32768 colors palette',$d,$a
	dc.b '(try to imagine a ray tracing with)',$d,$a
	dc.b 'And 3 animations on the screen.',$d,$a
	dc.b 'Search them.',$d,$a
	dc.b 'I have enough time to put more anims,',$d,$a
	dc.b "but my graphist doesn't have it.",$d,$a,$d,$a
	dc.b 'Oops excuse me I am    Axel F.',$d,$a
	dc.b '4/5/90             (MCS/French Alliance)',$d,$a,$d,$a     
	dc.b '		  Crunch the ESC key',0
	even
txt2   dc.b $1b,'E'
	dc.b 'I could have put a scrolltext on the',$d,$a
	dc.b 'screen, but it would have broken the',$d,$a
	dc.b 'beauty of the picture, and noone would',$d,$a
	dc.b 'have read it entirely . So, here it is.',$d,$a,$d,$a,$d,$a
	dc.b 'Graph and anims  by  ALF',$d,$a
	dc.b 'Musixx by   ????',$d,$a
	dc.b 'Code by me',$d,$a
	dc.b '			Bite the ESC Key',$d,$a,$d,$a
	dc.b 'PS : I really hate scrolltext',0
	even  
MUZEXX incbin del32.mus
	end


	
