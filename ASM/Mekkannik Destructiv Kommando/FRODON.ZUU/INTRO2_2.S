		listchar	$0f,$1b,$43,11
		ttl	The short intro v1.1
		plen	60

		section text
		
debut		
		movea.l	a7,a5
		movea.l	$04(a5),a5
		move.l	$0c(a5),d0
		add.l	$14(a5),d0
		add.l	$1c(a5),d0
		addi.l	#$200,d0
		move.l	d0,-(a7)
		move.l	a5,-(a7)
	 	clr.w	-(a7)
	 	move.w	#$04a,-(a7)	
	 	trap	#$01
	 	adda.l	#$0c,a7
		
		
		dc.w	$a00a       
		pea	chaine
		clr.w	-(a7)
		move.w	#25,-(a7)
		trap	#14
		addq.l	#8,a7
		
		pea efface
		move.w	#$09,-(a7)
		trap	#$01
		addq.l	#6,a7
		
		move.l	#$800,d0
		bsr	malloc
		move.l	d0,zone
		move.l	d0,a0
		addi.l	#50,d0
		move.l	d0,depart
		move.w	#$800,d7

rempli		move.w	#$000,(a0)+
		dbf	d7,rempli
		move.l    #texte,-(a7)
                    move.w    #9,-(a7)
                    trap      #1
                    addq.l    #6,a7
		move.l	depart,a0
		lea	barre,a1
		move.l	a0,12(a1)
		adda.l	#22,a0
		move.l	a0,6(a1)
		adda.l	#22,a0
		move.l	a0,(a1)
		
		moveq	#1,d1
		move.w	d1,4(a1)
		move.w	d1,10(a1)
		move.w	d1,16(a1)
		
		pea	routine
		move.w	#$26,-(a7)
		trap	#$0e
		addq.l	#6,a7
		
		move.l	zone,d0
		bsr	m_free
		
		pea	chaine2
		clr.w	-(a7)
		move.w	#25,-(a7)
		trap	#14
		addq.l	#8,a7
		
		
		
		clr.l	-(a7)
		trap	#$01
		
routine		move.b	#$10,$ff820a	;mode synchro (50 Hz)

		lea	$fffa00,a0
		move.b	$07(a0),-(a7)
		move.b	$13(a0),-(a7)
		move.b	$1b(a0),-(a7)
		move.b	$21(a0),-(a7)
		move.l	$0120,-(a7)
		clr.b	$01b(a0)
		bset	#$0,$07(a0)
		bset	#$0,$13(a0)
		bclr	#5,$fffa09
		bclr	#4,$fffa09
		move.l	#timer_b,$0120
		
		lea	midi_or+2,a0
		move.l	$118,(a0)
		lea	midi,a0
		move.l	a0,$118
		
		
		lea	vbl_orig+2,a0
		move.l	$70,(a0)
		lea	vbl,a0
		move.l	a0,$70
		
		move.w	#$025,-(a7)	;vsync
		trap	#$0e
		addq.l	#2,a7
		
		move.w	#$07,-(a7)
		trap	#$01		;attente touche
		addq.l	#2,a7
                    move.w    #$777,$ff8240
		
orig_value	move.w	#$2700,sr
		lea	$0fffa00,a0
		move.b	(a7)+,$07(a0)
		move.b	(a7)+,$13(a0)
		move.b	(a7)+,$1b(a0)
		move.b	(a7)+,$21(a0)
		move.l	(a7)+,$0120
		bset	#5,$fffa09
		bset	#5,$fffa09
		move.l	midi_or+2,$118
		move.l  vbl_orig+2,$70
		rts
		
		even
midi		move.w	#$2500,sr
midi_or		jmp	$0	
		
timer_b		move.w	offset,$ff8240
		addq.l	#2,timer_b+2
		bclr	#$0,$fffa0f
		rte	
		even
		
offset	 	dc.l	0

vbl		even
		clr.b	$fffa1b
		movem.l	a0-a6/d0-d7,-(a7)
		lea	barre,a0
		move.l	(a0),a1
		move.l	6(a0),a2
		move.l	12(a0),a3
                    move.l    18(a0),a4
		move.w	4(a0),d1
		move.w	10(a0),d2
		move.w	16(a0),d3
		move.w    22(a0),d4
couleur1	tst.w	d1
		beq	suite1_h
bas1		move.w	#$000,(a1)
		addq.l	#6,a1
		move.l	depart,a6
		adda.l	#170,a6
		cmpa.l	a6,a1
		bmi.s	ok1
perm1		;move.l	a3,a4
		;move.l	a1,a3
		;move.l	a4,a1
		;move.w	d3,d1
		moveq	#0,d1
		bra.s	ok1
suite1_h	move.w	#$000,22(a1)
		subq.l	#4,a1
		move.l	depart,a6
		cmpa.l	a6,a1
		bpl.s	ok1
perm11		moveq	#1,d1
ok1		;on passe a la couleur 2

couleur2	tst.w	d2
		beq	suite2_h
bas2		move.w	#$000,(a2)
		addq.l	#2,a2	
		move.l	depart,a6
		adda.l	#100,a6
		cmpa.l	a6,a2
		bmi.s	ok2
		moveq	#0,d2
		bra.s	ok2
suite2_h	move.w	#$000,22(a2)
		subq.l	#2,a2
		move.l	depart,a6
		cmpa.l	a6,a2
		bpl.s	ok2
		moveq	#1,d2
ok2		;on passe a la couleur 3

couleur3	tst.w	d3
		beq	suite3_h
bas3		move.w	#$000,(a3)
		addq.l	#2,a3
		move.l	depart,a6
		adda.l	#124,a6
		cmpa.l	a6,a3
		bmi.s	ok3
		moveq	#0,d3
		bra.s	ok3
suite3_h	move.w	#$000,22(a3)
		subq.l	#2,a3
		move.l	depart,a6
		cmpa.l	a6,a3
		bpl.s	ok3
		moveq	#1,d3

ok3		;on affiche les couleurs
couleur4	tst.w	d4
		beq	suite4_h
bas4		move.w	#$000,(a4)
		addq.l	#2,a4
		move.l	depart,a6
		adda.l	#144,a6
		cmpa.l	a6,a4
		bmi.s	ok3
		moveq	#0,d4
		bra.s	ok4
suite4_h	move.w	#$000,22(a4)
		subq.l	#2,a4
		move.l	depart,a6
		cmpa.l	a6,a4
		bpl.s	ok4
perm44		moveq	#1,d4
ok4                 ;on affiche les couleurs
		
                    move.w    #$0,(a1)
                    move.w    #$0,2(a1)		
		move.w	#$000,4(a1)
		move.w	#$200,6(a1)
		move.w	#$300,8(a1)
		move.w	#$400,10(a1)
		move.w	#$500,12(a1)
		move.w	#$707,14(a1)
		move.w	#$505,16(a1)
		move.w	#$404,18(a1)
		move.w	#$303,20(a1)
		move.w	#$202,22(a1)
		move.w	#$101,24(a1)
                    move.w    #$0,26(a1)
                    move.w    #$0,28(a1)


		move.w	#$222,(a2)
		move.w	#$333,2(a2)
		move.w	#$444,4(a2)
		move.w	#$555,6(a2)
		move.w	#$666,8(a2)
		move.w	#$77,10(a2)
		move.w	#$66,12(a2)
		move.w	#$55,14(a2)
		move.w	#$44,16(a2)
		move.w	#$33,18(a2)
		move.w	#$22,20(a2)
		
		move.w	#$20,(a3)
		move.w	#$30,2(a3)
		move.w	#$40,4(a3)
		move.w	#$50,6(a3)
		move.w	#$60,8(a3)
		move.w	#$770,10(a3)
		move.w	#$660,12(a3)
		move.w	#$550,14(a3)
		move.w	#$440,16(a3)
		move.w	#$330,18(a3)
		move.w	#$220,20(a3)

		move.w	#$20,(a3)
		move.w	#$30,2(a3)
		move.w	#$40,4(a3)
		move.w	#$50,6(a3)
		move.w	#$60,8(a3)
		move.w	#$770,10(a3)
		move.w	#$660,12(a3)
		move.w	#$550,14(a3)
		move.w	#$440,16(a3)
		move.w	#$330,18(a3)
		move.w	#$220,20(a3)

		lea	barre,a0
		move.l	a1,(a0)
		move.l	a2,6(a0)
		move.l	a3,12(a0)
                    move.l    a4,18(a0)
		move.w	d1,4(a0)
		move.w	d2,10(a0)
		move.w	d3,16(a0)
		move.w    d4,22(a0)							
		
		
		
		
		
		move.w	#$000,$ff8240
		move.b	#$02,$fffa21
		move.b	#$08,$fffa1b
		move.l	depart,timer_b+2
		movem.l	(a7)+,a0-a6/d0-d7
vbl_orig	jmp	$0	


;**************************
;****** D.A.T.A ***********
;**************************
		even
texte               dc.b      13,10,13,10,13,10,13,10,13,10,13,10,"           TST proudly present:",13,10
                    dc.b      13,10,13,10,13,10,13,10,13,10,"           This news stuff !!!",13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,13,10,0
zone		dc.l	0
depart		dc.l	0		
physique	dc.l	0
buffer		dc.l	0
barre		dc.l	0	;couleur 1
		dc.w	0
		dc.l	0	;couleur 2
		dc.w	0
		dc.l	0	;couleur 3
		dc.w	0
		dc.l      0
                    dc.w      0

		even
chaine		dc.b	18
		even
chaine2		dc.b	8		
		even
efface		dc.b	$1b,$45,0
		even		

malloc		move.l  d0,-(a7)
                move.w  #$048,-(a7)
                trap    #$01
                addq.l  #6,a7
                rts
                                        ;par le systeme
m_free		move.l	d0,-(a7)
		move.w	#$49,-(a7)
		trap	#$01
		addq.l	#6,a7
		rts

