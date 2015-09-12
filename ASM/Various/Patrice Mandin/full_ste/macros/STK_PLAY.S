;	Soundtrack playroutine by DATA

	TEXT

SOUNDTRACK_INIT	macro	adresse_module,ste_freq

	move.l	\1,a0
	moveq	#15,d0
	cmp.l	#"M.K.",$438(a0)
	beq.s	sndtrk_11
	cmp.l	#"FLT4",$438(a0)
	bne.s	sndtrk2
sndtrk_11	moveq	#31,d0

sndtrk2	move.l	d0,d1
	mulu	#30,d1
	lea	22(a0,d1.w),a1
	move.l	a1,partition
	lea	128(a1),a1
	cmp	#31,d0
	bne.s	sndtrk_21
	addq	#4,a1
sndtrk_21	move.l	a1,adr_pat
	
	moveq	#0,d1	; pat max	
	move.l	partition,a1
	moveq	#0,d3
	move.b	-2(a1),d3
	subq	#1,d3
	
sndtrk3	move.b	(a1)+,d2
	cmp.b	d2,d1
	bcc.s	sndtrk4
	move.b	d2,d1
sndtrk4	dbra	d3,sndtrk3
 
	addq	#1,d1
	moveq	#10,d2
	lsl.l	d2,d1
	move.l	adr_pat,a1
	add.l	d1,a1
	move.l	d0,d1
	subq	#1,d1

;	Init donn‚es samples

	lea	16+samples,a2
	lea	42(a0),a0
sndtrk5	move.l	a1,(a2)	; adresse sample

	move	(a0),d4	; longueur sample
	add	d4,d4
	move	d4,4(a2)

	move	6(a0),d4	; longueur repeat
	cmp	#1,d4
	bne.s	sndtrk6
	moveq	#0,d4
sndtrk6	add	d4,d4
	move	d4,12(a2)
	
	move.l	(a2),d4	; adresse repeat
	moveq	#0,d5
	move	4(a2),d5
	add.l	d5,d4
	move	4(a0),d5
	sub.l	d5,d4
	move	12(a2),d5
	sub.l	d5,d4
	move.l	d4,8(a2)

	move	2(a0),6(a2)	; volume sample

	moveq	#0,d4
	move	4(a2),d4
	add.l	d4,a1
	lea	16(a2),a2
	lea	30(a0),a0
	dbra	d1,sndtrk5

;	Inverse les samples

	subq	#1,d0
	lea	16+samples,a2
sndtrk7	move.l	(a2),a0
	moveq	#0,d4
	move	4(a2),d4
	beq.s	sndtrk9
	lea	(a0,d4.l),a1
	lsr	#1,d4
sndtrk8	move.b	(a0),d1
	move.b	-1(a1),(a0)+
	move.b	d1,-(a1)
	dbra	d4,sndtrk8
sndtrk9	lea	16(a2),a2
	dbra	d0,sndtrk7

;	Init valeurs

	move.l	#$063fff01,vitesse

	lea	joue,a0
	lea	samples+16,a1
	moveq	#3,d0
sndtrk11	move.l	(a1),$00(a0)
	move	4(a1),$04(a0)
	clr	$06(a0)
	move.l	a1,$08(a0)
	move.l	#$0200ffff,$0c(a0)
	move.l	#$02000000,$10(a0)
	clr.l	$14(a0)
	clr.l	$18(a0)
;	move.l	a1,$18(a0)
	lea	32(a0),a0
	dbra	d0,sndtrk11

	clr	flagbuf

;	Init replay du son

	lea	bufferf0,a0
	move	#499,d0
sndtrk1	clr.l	(a0)+
	dbra	d0,sndtrk1	

	lea	$ffff8900.w,a0

	move.l	#bufferf0,d0
	move.b	d0,$07(a0)
	ror	#8,d0
	move.l	d0,$02(a0)
	ror	#8,d0

	add	#4,d0

	move.b	d0,$13(a0)
	ror	#8,d0
	move.l	d0,$0e(a0)
	ror	#8,d0

	clr.b	$01(a0)
	move.b	\2,$21(a0)

	ENDM
	
; ------------- Routine de soundtrack

SOUNDTRACK_PLAY	MACRO

; a0-5:d0-6	Permuter buffer de travail

	move.l	#bufferf0,d7
	not	flagbuf
	beq.s	dt_buf
	move.l	#bufferf1,d7
dt_buf	move.l	d7,adr_buf

	lea	$ffff8900.w,a6
	move.b	d7,$07(a6)
	ror	#8,d7
	move.l	d7,$02(a6)
	ror	#8,d7

	add	\3,d7
	add	\3,d7

	move.b	d7,$13(a6)
	ror	#8,d7
	move.l	d7,$0e(a6)
	;ror	#8,d7

; a0-5:d0-6	Vide le buffer

	move.l	adr_buf,a6
	move	\3,d7
	subq	#1,d7
dt_clearbuf	clr	(a6)+
	dbra	d7,dt_clearbuf

; a0-4:d0-6 	Nouvelle ligne … jouer
	
dt_sautsf	lea	vbls,a6
	subq.b	#1,(a6)
	bne	dt_nonewline
	move.b	vitesse,(a6)

	lea	ligne,a6
	addq.b	#1,(a6)
	and.b	#63,(a6)
	bne.s	dt_nonewpat
	lea	pattern,a5
	addq.b	#1,(a5)
	move.l	partition,a6
	move.b	(a5),d7
	cmp.b	-2(a6),d7
	bcs.s	dt_nonewpat
	clr.b	(a5)
	cmp.b	-1(a6),d7
	bcs.s	dt_nonewpat
	move.b	-1(a6),(a5)

; a0-4:d0-5	Calcul ligne/pattern … jouer

dt_nonewpat	moveq	#0,d7
	move.l	adr_pat,a6
	move.b	ligne,d7
	lsl	#4,d7
	add	d7,a6
	moveq	#0,d7
	move.b	pattern,d7
	move.l	partition,a5
	move.b	(a5,d7.w),d7
	moveq	#10,d6
	lsl.l	d6,d7
	add.l	d7,a6
	move.l	a6,adresse
		
; a0-3:d0-3	Calcul instruments … jouer

	moveq	#3,d7
	lea	joue+3*32,a5
dt_nextvoice1	move.l	adresse,a6
	move.l	d7,d6
	lsl	#2,d6
	add	d6,a6	; a6 adresse infos voie

	move.b	2(a6),d5
	lsr.b	#4,d5
	and	#15,d5
	move.b	(a6),d4
	and	#$10,d4
	add	d4,d5	; d5 nouvel instrument
	beq.s	dt_nonewspl

	clr	$0e(a5)
	and	#255,d5
	lsl	#4,d5
	lea	samples,a4
	add	d5,a4
	cmp.l	$08(a5),a4
	beq.s	dt_nonewspl1

	move.l	a4,$08(a5)
	move.l	(a4),$00(a5)
	move.l	4(a4),$04(a5)

dt_nonewspl1	move.b	$07(a5),$06(a5)

dt_nonewspl	move	(a6),d6
	and	#$0fff,d6	; d6 nouvelle periode
	beq.s	dt_nonewper

	move.b	2(a6),d5
	and	#15,d5
	cmp.b	#3,d5	; commande 3 ?
	bne.s	dt_nosetprt

	move.b	#1,$17(a5)
	move	$0c(a5),d5
	sub	d6,d5
	bne.s	dt_setprt0
	clr.l	$14(a5)
	bra.s	dt_nonewper
	
dt_setprt0	bmi.s	dt_setprt1
	move.b	#-1,$17(a5)
dt_setprt1	move	d6,$14(a5)
	move.b	3(a6),$16(a5)
	bra.s	dt_nonewper

dt_nosetprt	move	d6,$0c(a5)
	move	d6,$10(a5)
	move.l	$08(a5),a4
	move.l	(a4),$00(a5)
	move.l	4(a4),$04(a5)
	move.b	$07(a5),$06(a5)
	clr	$0e(a5)
	
; a0-3:d0-5	Commandes B,C,D,F

dt_nonewper	moveq	#0,d6
	move.l	adresse,a6
	move	d7,d6
	lsl	#2,d6
	lea	3(a6,d6.w),a6
	move.b	-1(a6),d6
	and	#15,d6
	cmp	#$b,d6
	bmi.s	dt_nofx1
	lsl	#2,d6
	lea	dt_effets,a4
	move.l	(a4,d6.w),a4
	jsr	0(a4)

dt_nofx1	lea	-32(a5),a5
	dbra	d7,dt_nextvoice1
	bra	voie1

; a0-3:d0-2	Commandes 0,1,2,3,4,5,6,A

dt_nonewline	moveq	#3,d7
	lea	joue+3*32,a5
dt_nextvoice2	move.l	adresse,a6
	move	d7,d6
	lsl	#2,d6
	lea	3(a6,d6.w),a6
	move.b	-1(a6),d6
	and	#15,d6
	cmp	#$b,d6
	bpl.s	dt_nofx2
	lsl	#2,d6
	lea	dt_effets,a4
	move.l	(a4,d6.w),a4
	jsr	0(a4)

dt_nofx2	lea	-32(a5),a5
	dbra	d7,dt_nextvoice2
	bra	voie1

;	Effets

dt_effets	dc.l	dt_arpeggio
	dc.l	dt_portup
	dc.l	dt_portdown
	dc.l	dt_porttone

	dc.l	dt_vibrato
	dc.l	dt_portvolume
	dc.l	dt_vibvolume
	dc.l	dt_rts

	dc.l	dt_rts
	dc.l	dt_rts
	dc.l	dt_volumeslide
	dc.l	dt_patternjump

	dc.l	dt_setvolume
	dc.l	dt_patternbreak
	dc.l	dt_rts
	dc.l	dt_setspeed

;	0 Arpeggio

dt_arpeggio	move.b	(a6),d6
	beq	dt_arpeggio7
	
	move.b	vbls,d5
	lea	arpeggio,a6
	move.b	(a6,d5),d5
	beq.s	dt_arpeggio5

	cmp.b	#2,d5
	beq.s	dt_arpeggio2

dt_arpeggio1	moveq	#0,d5
	move.b	d6,d5
	lsr.b	#4,d5
	bra.s	dt_arpeggio3

dt_arpeggio2	moveq	#0,d5
	move.b	d6,d5
	and	#15,d5

dt_arpeggio3	add	d5,d5
	move	$10(a5),d6
	lea	periods,a6
	moveq	#$24,d4
dt_arpeggio4	move	(a6,d5),d3
	cmp	(a6),d6
	bge.s	dt_arpeggio6
	addq	#2,a6
	dbra	d4,dt_arpeggio4
dt_arpeggio5	move	$10(a5),$0c(a5)	
	rts

dt_arpeggio6	move	d3,$0c(a5)	
dt_arpeggio7	rts

;	1 Portamento up

dt_portup	moveq	#0,d5
	move.b	(a6),d5
	move	$0c(a5),d6
	sub	d5,d6
	cmp	#$71,d6
	bpl.s	dt_portup1
	moveq	#$71,d6
dt_portup1	move	d6,$0c(a5)
	move	d6,$10(a5)
	rts

;	2 Portamento down

dt_portdown	moveq	#0,d5
	move.b	(a6),d5
	move	$0c(a5),d6
	add	d5,d6
	cmp	#$358,d6
	bmi.s	dt_portdown1
	move	#$358,d6
dt_portdown1	move	d6,$0c(a5)
	move	d6,$10(a5)
	rts

;	3 Tone portamento

dt_porttone	move	$0c(a5),d6
	moveq	#0,d5
	move.b	$16(a5),d5
	tst.b	$17(a5)
	beq	dt_prt5
	bmi.s	dt_prt4

	add	d5,d6
	cmp	$14(a5),d6
	bmi.s	dt_prt3
dt_prt2	move	$14(a5),d6
	clr.l	$14(a5)
dt_prt3	move	d6,$0c(a5)
	move	d6,$10(a5)
dt_prt5	rts
	
dt_prt4	sub	d5,d6
	cmp	$14(a5),d6
	bpl.s	dt_prt3
	bra.s	dt_prt2

;	4 Vibrato

dt_vibrato	move.b	(a6),d6
	beq.s	dt_vibrato1
	move.b	d6,$12(a5)

dt_vibrato1	move.b	$13(a5),d6
	lsr	#2,d6
	and	#31,d6
	moveq	#0,d5
	lea	sinus,a6
	move.b	(a6,d6),d5
	move.b	$12(a5),d6
	and	#15,d6
	mulu	d6,d5
	lsr	#7,d5
	move	$10(a5),d6
	tst.b	$13(a5)
	bmi.s	dt_vibrato2
	add	d5,d6
	bra.s	dt_vibrato3

dt_vibrato2	sub	d5,d6

dt_vibrato3	move	d6,$0c(a5)
	move.b	$12(a5),d6
	lsr	#2,d6
	and	#$3c,d6
	add.b	d6,$13(a5)
	rts

;	5 Portamento tone + volume slide

dt_portvolume	move	$0c(a5),d6
	moveq	#0,d5
	move.b	$16(a5),d5
	tst.b	$17(a5)
	beq	dt_volumeslide
	bmi.s	dt_prtvol4

	add	d5,d6
	cmp	$14(a5),d6
	bmi.s	dt_prtvol3
dt_prtvol2	move	$14(a5),d6
	clr.l	$14(a5)
dt_prtvol3	move	d6,$0c(a5)
	move	d6,$10(a5)
	bra	dt_volumeslide
	
dt_prtvol4	sub	d5,d6
	cmp	$14(a5),d6
	bpl.s	dt_prtvol3
	bra.s	dt_prtvol2

;	6 vibrato + volume slide

dt_vibvolume	move.b	$13(a5),d6
	lea	sinus,a4
	lsr	#2,d6
	and	#$1f,d6
	moveq	#0,d5
	move.b	(a4,d6),d5
	move.b	$12(a5),d6
	and	#15,d6
	mulu	d6,d5
	lsr	#7,d5
	move	$10(a5),d6
	tst.b	$13(a5)
	bmi.s	dt_vibvol1
	add	d5,d6
	bra.s	dt_vibvol2

dt_vibvol1	sub	d5,d6

dt_vibvol2	move	d6,$0c(a5)
	move.b	$12(a5),d6
	lsr	#2,d6
	and	#$3c,d6
	add.b	d6,$13(a5)
	
	bra.s	dt_volumeslide
	
;	7 Tremolo

	nop

;	8 Phasor effect

;	9 Play end part of a sample

;	A Volume slide

dt_volumeslide	move.b	$06(a5),d6
	move.b	(a6),d5
	lsr.b	#4,d5
	beq.s	dt_volumeslide2

	add.b	d5,d6
	cmp.b	#$40,d6
	bmi.s	dt_volumeslide3
	moveq	#$40,d6
	bra.s	dt_volumeslide3
	
dt_volumeslide2	move.b	(a6),d5
	and	#15,d5
	sub.b	d5,d6
	bpl.s	dt_volumeslide3
	moveq	#0,d6

dt_volumeslide3	move.b	d6,$06(a5)
	rts

;	B Pattern jump
;	D Pattern break

dt_patternjump	move.b	(a6),pattern
	subq.b	#1,pattern
dt_patternbreak	move.b	#$3f,ligne
dt_rts	rts
	
;	C Set volume

dt_setvolume	move.b	(a6),d6
	cmp.b	#$40,d6
	bmi.s	dt_setvolume1
	moveq	#$40,d6
dt_setvolume1	move.b	d6,$06(a5)
	rts
		
;	F Set speed

dt_setspeed	move.b	(a6),d6
	and	#$1f,d6
	move.b	d6,vitesse
	move.b	d6,vbls
	rts

; a0-1:d0-1 	Calcul voie 1 d

voie1	;clr.b	joue+0*32+6
	;clr.b	joue+1*32+6
	;clr.b	joue+2*32+6
	;clr.b	joue+3*32+6

	move.l	adr_buf,a6
	lea	joue+1*32,a5

	move	$0c(a5),d7	; periode
	move.l	#$23bf8f,d6
	divu	d7,d6
	ext.l	d6
	move	\1,d7
multi1	add.l	d6,d6
	dbra	d7,multi1
	
	moveq	#0,d7	; volume
	move.b	$06(a5),d7
	lsl	#8,d7
	lea	volumes,a4
	add	d7,a4

	move	\2,d7
	move.l	d6,d2
	swap	d2
	move.l	$08(a5),a2
	move.l	$00(a5),a3	; adr dep courante
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move	$04(a5),d5	; position courante

	tst	$0e(a5)
	bne	jump150
	tst.b	$06(a5)
	beq	jump150

jump125	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	move	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump135
jump126	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	move	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump136
jump127	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	move	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump137
jump128	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	move	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump138
jump129	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	move	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump139

jump130	dbra	d7,jump125
	bra	jump150
	
jump135	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump126
	move	#-1,$0e(a5)
	bra.s	jump150

jump136	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump127
	move	#-1,$0e(a5)
	bra.s	jump150

jump137	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump128
	move	#-1,$0e(a5)
	bra.s	jump150

jump138	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump129
	move	#-1,$0e(a5)
	bra.s	jump150

jump139	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump130
	move	#-1,$0e(a5)
jump150	
	move.l	a3,$00(a5)
	move	d5,$04(a5)
	
; a0-1:d0-1	Calcul voie 2 d
	
voie2	move.l	adr_buf,a6
	lea	joue+2*32,a5

	move	$0c(a5),d7	; periode
	move.l	#$23bf8f,d6
	divu	d7,d6
	ext.l	d6
	move	\1,d7
multi2	add.l	d6,d6
	dbra	d7,multi2
	
	moveq	#0,d7	; volume
	move.b	$06(a5),d7
	lsl	#8,d7
	lea	volumes,a4
	add	d7,a4

	move	\2,d7
	move.l	d6,d2
	swap	d2
	move.l	$08(a5),a2
	move.l	$00(a5),a3	; adr dep courante
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move	$04(a5),d5	; position courante

	tst	$0e(a5)
	bne	jump240
	tst.b	$06(a5)
	beq	jump240

jump225	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump235
jump226	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump236
jump227	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump237
jump228	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump238
jump229	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add	d3,(a6)+
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump239

jump230	dbra	d7,jump225
	bra	jump240

jump235	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump226
	move	#-1,$0e(a5)
	bra.s	jump240

jump236	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump227
	move	#-1,$0e(a5)
	bra.s	jump240

jump237	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump228
	move	#-1,$0e(a5)
	bra.s	jump240

jump238	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump229
	move	#-1,$0e(a5)
	bra.s	jump240

jump239	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump230
	move	#-1,$0e(a5)

jump240	move.l	a3,$00(a5)
	move	d5,$04(a5)

; a0-1:d0-1	Calcul voie 0 g

voie0	move.l	adr_buf,a6
	lea	joue+0*32,a5

	move	$0c(a5),d7	; periode
	move.l	#$23bf8f,d6
	divu	d7,d6
	ext.l	d6
	move	\1,d7
multi0	add.l	d6,d6
	dbra	d7,multi0
	
	moveq	#0,d7	; volume
	move.b	$06(a5),d7
	lsl	#8,d7
	lea	volumes,a4
	add	d7,a4

	move	\2,d7
	move.l	d6,d2
	swap	d2
	move.l	$08(a5),a2
	move.l	$00(a5),a3	; adr dep courante
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move	$04(a5),d5	; position courante
		
	tst	$0e(a5)
	bne	jump040
	tst.b	$06(a5)
	beq	jump040

jump025	move.b	(a3,d5.l),d3
	move.b	(a4,d3),(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump035
jump026	move.b	(a3,d5.l),d3
	move.b	(a4,d3),(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump036
jump027	move.b	(a3,d5.l),d3
	move.b	(a4,d3),(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump037
jump028	move.b	(a3,d5.l),d3
	move.b	(a4,d3),(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump038
jump029	move.b	(a3,d5.l),d3
	move.b	(a4,d3),(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump039

jump030	dbra	d7,jump025
	bra.s	jump040

jump035	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump026
	move	#-1,$0e(a5)
	bra.s	jump040

jump036	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump027
	move	#-1,$0e(a5)
	bra.s	jump040

jump037	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump028
	move	#-1,$0e(a5)
	bra.s	jump040

jump038	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump029
	move	#-1,$0e(a5)
	bra.s	jump040

jump039	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump030
	move	#-1,$0e(a5)

jump040	move.l	a3,$00(a5)
	move	d5,$04(a5)

; a0-1:d0-1	Calcul voie 3 g

voie3	move.l	adr_buf,a6
	lea	joue+3*32,a5

	move	$0c(a5),d7	; periode
	move.l	#$23bf8f,d6
	divu	d7,d6
	ext.l	d6
	move	\1,d7
multi3	add.l	d6,d6
	dbra	d7,multi3
	
	moveq	#0,d7	; volume
	move.b	$06(a5),d7
	lsl	#8,d7
	lea	volumes,a4
	add	d7,a4

	move	\2,d7
	move.l	d6,d2
	swap	d2
	move.l	$08(a5),a2
	move.l	$00(a5),a3	; adr dep courante
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	move	$04(a5),d5	; position courante

	tst	$0e(a5)
	bne	jump340		
	tst.b	$06(a5)
	beq	jump340

jump325	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add.b	d3,(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump335
jump326	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add.b	d3,(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump336
jump327	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add.b	d3,(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump337
jump328	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add.b	d3,(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump338
jump329	move.b	(a3,d5.l),d3
	move.b	(a4,d3),d3
	add.b	d3,(a6)
	addq	#2,a6
	sub	d6,d4
	subx	d2,d5
	bcs.s	jump339

jump330	dbra	d7,jump325
	bra	jump340

jump335	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump326
	move	#-1,$0e(a5)
	bra.s	jump340

jump336	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump327
	move	#-1,$0e(a5)
	bra.s	jump340

jump337	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump328
	move	#-1,$0e(a5)
	bra.s	jump340

jump338	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump329
	move	#-1,$0e(a5)
	bra.s	jump340

jump339	move.l	8(a2),a3
	move	12(a2),d5
	bne.s	jump330
	move	#-1,$0e(a5)
	
jump340	move.l	a3,$00(a5)
	move	d5,$04(a5)
	ENDM

	DATA

;joue	 4*32 octets
;	$00.L	adresse sample courant
;	$04.W	longueur sample	courant
;	$06.B	volume voie courante
;	$07.B	volume sample courant
;	$08.L	adresse donn‚es sample courant
;	$0C.W	p‚riode courante
;	$0E.W	repeat on/off

;	$10.W	p‚riode partition
;	$12.B	fx4 ctrl
;	$13.B	fx4 dt

;	$14.W	fx3 p‚riode
;	$16.B	fx3 dt
;	$17.B	fx3 ctrl

;samples	32*16 octets
;	$00.L	adresse sample
;	$04.W	longueur sample
;	$06.W	volume
;	$08.L	adresse repeat
;	$0C.W	longueur repeat

volumes	incbin	volume.bin

sinus	dc.b	$00,$18,$31,$4a,$61,$78,$8d,$a1
	dc.b	$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b	$ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5
	dc.b	$b4,$a1,$8d,$78,$61,$4a,$31,$18

arpeggio	dc.b	0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0
	dc.b	1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
	
periods	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280
	dc.w	$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w	$01ac,$0194,$017d,$0168,$0153,$0140
	dc.w	$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w	$00d6,$00ca,$00be,$00b4,$00aa,$00a0
	dc.w	$0097,$008f,$0087,$007f,$0078,$0071

	BSS

joue	ds.l	32
vitesse	ds.b	1
ligne	ds.b	1
pattern	ds.b	1
vbls	ds.b	1
adresse	ds.l	1
partition	ds.l	1
adr_pat	ds.l	1
samples	ds.b	16*32
flagbuf	ds.w	1
adr_buf	ds.l	1

bufferf0	ds.w	1000
bufferf1	ds.w	1000

