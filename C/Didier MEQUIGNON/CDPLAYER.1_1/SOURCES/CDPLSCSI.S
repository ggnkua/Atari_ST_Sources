
; CDPLAYER.CPX partie driver SCSI

	.export  Scsi_read,Scsi_write

flock			equ $43e
_hz_200			equ $4ba
_cookie 		equ $5a0
TIME_OUT_CMDE	equ 200;	1S
TIME_OUT_4S		equ 800
TIME_OUT_10S	equ 2000

Scsi_read:
;canal dans D0, nbre octets DMA dans D1
;nbre octets de commande dans D2
;A0: buffer DMA, A1: buffer octets de commande
;au retour code erreur dans D0

	movem.l D1-A6,-(SP)
	st.b flock
	move D0,-(SP)
	move.l #"_MCH",D0
	bsr get_cookie
	bmi sr11
	swap D0
	cmp #2,D0;TT
	beq sr7;SCSI NCR 5380 ZILOG
	cmp #3,D0;FALCON
	beq sr10
sr11:
	move.l A0,-(SP);ST
	move.b 3(SP),$ffff860d;base DMA poids faible
	move.b 2(SP),$ffff860b; -    -   -    moyen
	move.b 1(SP),$ffff8609; -    -   -    fort
	addq #4,SP
	move #$190,$ffff8606
	bsr tempo_fixe_mfp
	move #$90,$ffff8606;lecture DMA ACSI
	bsr tempo_fixe_mfp
	move.l D1,D0;nbre octets DMA
	and #$1ff,D1
	lsr.l #8,D0
	lsr.l #1,D0;/512
	tst D1
	beq sr12
	addq #1,D0
sr12:
	move D0,$ffff8604;nbre de secteurs * 512 octets DMA
	bsr tempo_fixe_mfp
	move (SP)+,D0;canal ACSI ST
	move #$88,$ffff8606;acc‚s au HDC, A1=0:octet de commande
	bsr params_hdc_acsi
	bmi sr4;time-out
	bsr wait_cmde_hdc_acsi;attente fin de commande
	bmi sr4;time-out
	bsr vide_cache
	move #$8a,$ffff8606
	moveq #0,d0
	move $ffff8604,D0;status HDC
	and #$ff,D0;code erreur
	bra sr4
sr10:
	move (SP)+,D0;canal SCSI FALCON
	bsr params_hdc_scsi_falcon
	bmi sr8;time-out
	move #$89,$ffff8606
	move #0,$ffff8604
	move #$8b,$ffff8606
	move #1,$ffff8604
	move #$8f,$ffff8606
	move $ffff8604,D0
	move #$8a,$ffff8606
	move #2,$ffff8604
	move.l A0,-(SP)
	move.b 3(SP),$ffff860d;base DMA poids faible
	move.b 2(SP),$ffff860b; -    -   -    moyen
	move.b 1(SP),$ffff8609; -    -   -    fort
	addq #4,SP
	move #$190,$ffff8606
	bsr tempo_fixe_mfp
	move #$90,$ffff8606;lecture DMA SCSI
	bsr tempo_fixe_mfp
	move.l D1,D0;nbre octets DMA
	and #$1ff,D1
	lsr.l #8,D0
	lsr.l #1,D0;/512
	tst D1
	beq sr3
	addq #1,D0
sr3:
	move D0,$ffff8604;nbre de secteurs * 512 octets DMA
sr1:
	btst #3,$ffff860F
	bne sr1
	move #$8f,$ffff8606
	move #0,$ffff8604
	move #0,$ffff8606;transfert lecture
	bsr wait_cmde_hdc_scsi_falcon
	bmi sr8;time-out
	and #$f,D1
	beq sr2;octets DMA multiple de 16
	move #$20,$ffff8606
sr2:
	bsr vide_cache
	bsr etat_hdc_scsi_falcon
	and.l #$ff,D0;code erreur
sr8:
	move #$8f,$ffff8606
	move $ffff8604,D1
sr4:
	move #$180,$ffff8606
	bsr tempo_fixe_mfp
	move #$80,$ffff8606;registre de commande FDC
	bra sr5
sr7:
	move (SP)+,D0;canal SCSI TT
	bsr params_hdc_scsi_tt;NCR 5380 ZILOG
	bmi sr5;time-out
	move.b #0,$ffff8783
	move.b #1,$ffff8787
	move.b $ffff878f,d0
	move.b #2,$ffff8785
	move.b #0,$ffff878f
	move.b #0,$ffff8714
	move.b #2,$ffff8714
	bsr wait_cmde_hdc_scsi_tt
	bne sr5;erreur
	bsr etat_hdc_scsi_tt
	bne sr5
	bsr vide_cache
	lea $ffff8701,A0
	movep.l 0(A0),D0;adresse compteur DMA
	move.l D0,D1
	and #3,D0
	and #$fffc,D1
	move.l D1,A0
	move.l $ffff8710,D1;buffer DMA 4 octets
	subq #1,D0
	bmi sr6
sr9:
		rol.l #8,D1;r‚cupŠre les derniers octets
 		move.b D1,(A0)+
	dbra D0,sr9
sr6:
	moveq #0,D0
sr5:
	clr flock
	movem.l (SP)+,D1-A6
	rts

Scsi_write:
;canal dans D0, nbre octets DMA dans D1
;nbre octets de commande dans D2
;A0: buffer DMA, A1: buffer octets de commande
;au retour code erreur dans D0

	movem.l D1-A6,-(SP)
	st.b flock
	move D0,-(SP)
	move.l #"_MCH",D0
	bsr get_cookie
	bmi sw9
	swap D0
	cmp #2,D0;TT
	beq sw7;SCSI NCR 5380 ZILOG
	cmp #3,D0;FALCON
	beq sw8
	
sw9:
	move.l A0,-(SP);ST
	move.b 3(SP),$ffff860d;base DMA poids faible
	move.b 2(SP),$ffff860b; -    -   -    moyen
	move.b 1(SP),$ffff8609; -    -   -    fort
	addq #4,SP
	move #$90,$ffff8606
	bsr tempo_fixe_mfp
	move #$190,$ffff8606;‚criture DMA ACSI
	bsr tempo_fixe_mfp
	move.l D1,D0;nbre octets DMA
	and #$1ff,D1
	lsr.l #8,D0
	lsr.l #1,D0;/512
	tst D1
	beq sw11
	addq #1,D0
sw11:
	move D0,$ffff8604;nbre de secteurs * 512 octets DMA
	bsr tempo_fixe_mfp
	move (SP)+,D0;canal ACSI ST
	move #$188,$ffff8606;acc‚s au HDC, A1=0:octet de commande
	bsr params_hdc_acsi
	bmi sw4;time-out
	bsr wait_cmde_hdc_acsi;attente fin de commande
	bmi sw4;time-out
	bsr vide_cache
	move #$18a,$ffff8606
	moveq #0,d0
	move $ffff8604,D0;status HDC
	and #$ff,D0;code erreur
	bra sw4
sw8:
	move (SP)+,D0;canal SCSI FALCON
	bsr params_hdc_scsi_falcon
	bmi sw6;time-out
	move #$8b,$ffff8606
	move #0,$ffff8604
	move #$8f,$ffff8606
	move $ffff8604,d0
	cmp.l #512,D1;nbre octets DMA
	bcs sw10
	move #$8a,$ffff8606
	move #2,$ffff8604
	move.l A0,-(SP)
	move.b 3(SP),$ffff860d;base DMA poids faible
	move.B 2(SP),$ffff860b; -    -   -    moyen
	move.B 1(SP),$ffff8609; -    -   -    fort
	addq #4,SP
	move #$90,$ffff8606
	bsr tempo_fixe_mfp
	move #$190,$ffff8606;‚criture DMA SCSI
	bsr tempo_fixe_mfp
	move.l D1,D0;nbre octets DMA
	and #$1ff,D1
	lsr.l #8,D0
	lsr.l #1,D0;/512
	tst D1
	beq sw3
	addq #1,D0
sw3:
	move D0,$ffff8604;nbre de secteurs * 512 octets DMA
sw1:
	btst #3,$ffff860f
	bne sw1
	move #$18d,$ffff8606
	move #0,$ffff8604
	move #$100,$ffff8606;transfert ‚criture
	bsr wait_cmde_hdc_scsi_falcon
	bmi sw6;time-out
	bra sw2
sw10:
		bsr wait_hdc_scsi_falcon_2
		bmi sw6;time-out
		move #$8d,$ffff8606
		move $ffff8604,D0
		btst #3,D0
		beq sw2
		moveq #0,D0
		move.b (A0)+,D0;octets DMA
		move #$88,$ffff8606
		move D0,$ffff8604
		bsr strobe_scsi_falcon
	bra sw10	
sw2:
	bsr etat_hdc_scsi_falcon
	and.l #$ff,D0;code erreur
sw6:
	move #$8f,$ffff8606
	move $ffff8604,D1
sw4:
	move #$180,$ffff8606
	bsr tempo_fixe_mfp
	move #$80,$ffff8606;registre de commande FDC
	bra sw5
sw7:
	move (SP)+,D0;canal SCSI TT
	bsr params_hdc_scsi_tt;NCR 5380 ZILOG
	bmi sw5;time-out
	move.b #0,$ffff8787
	move.b $ffff878f,D0
	move.b #2,$ffff8785
	move.b #0,$ffff878b
	move.b #1,$ffff8714
	move.b #3,$ffff8714
	bsr wait_cmde_hdc_scsi_tt
	bne sw5;erreur
	bsr etat_hdc_scsi_tt
sw5:
	clr flock
	movem.l (sp)+,D1-A6
	rts   

vide_cache:

	move.l D0,-(SP)
	move.l #"_CPU",D0
	jsr get_cookie
	bmi vc1
	cmp.l #20,D0
	bcs vc1
	move SR,-(SP)
	or #$700,SR;masque IRQ
	dc.l $4e7a0002;MOVEC CACR,D0
	or #$808,D0;CD cache de donn‚es & instructions vid‚s
	dc.l $4e7b0002;MOVEC D0,CACR
	move (SP)+,SR
vc1:
	move.l (SP)+,D0
	rts

etat_hdc_scsi_falcon:

	move.l D1,-(SP)
	move #$8b,$ffff8606
	move #3,$ffff8604
	move #$8f,$ffff8606
	move $ffff8604,D0
	move #$8C,$ffff8606
	move.l _hz_200,D1
ef5:
		move $ffff8604,D0;‚tat DMA
		btst #5,D0
		bne ef2
		move.l _hz_200,D0
		sub.l d1,D0
		cmp.l #TIME_OUT_CMDE,D0
	blt ef5
	bra ef6
ef2:
	move #$88,$ffff8606
	move $ffff8604,D0
	and.l #$ff,D0
	move.l D0,-(SP)
	bsr strobe_scsi_falcon
	move #$8c,$ffff8606
	move.l _hz_200,d1
ef3:
		move $ffff8604,D0;‚tat DMA
		btst #5,D0
		bne ef4
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l #TIME_OUT_CMDE,D0;time-out 500 mS
	blt ef3
	addq #4,SP
ef6:
	moveq #-1,D0
	bra ef1
ef4:
	move #$88,$ffff8606
	move $ffff8604,D0
	bsr strobe_scsi_falcon
	move.l (SP)+,D0
ef1:
	move.l (SP)+,D1
	tst.l D0
	rts

etat_hdc_scsi_tt:

	move.l D1,-(SP)
	move.b #3,$ffff8787
	move.b $ffff878f,D0
	move.l _hz_200,D1
et5:
		btst #5,$ffff8789
		bne et2
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l #TIME_OUT_CMDE,D0
	blt et5
	bra et6
et2:
	moveq #0,D0
	move.b $ffff8781,D0;‚tat
	move.l D0,-(SP)
	bsr strobe_scsi_tt
	bmi et7
	move.l _hz_200,D1
et3:
		btst #5,$ffff8789
		bne et4
		move.l _hz_200,d0
		sub.l D1,D0
		cmp.l #TIME_OUT_CMDE,D0
	blt et3
et7:
	addq #4,SP
et6:
	moveq #-1,D0;time-out
	bra et1
et4:
	move.b $ffff8781,D0
	bsr strobe_scsi_tt
	bmi et7
	move.l (SP)+,D0
et1:
	move.l (SP)+,D1
	tst.l d0
	rts

arret_hdc_scsi_falcon:

af1:
	btst #3,$ffff860f;DMA SCSI sur FALCON
	bne af1
	move #$190,$ffff8606
	bsr tempo_fixe_mfp
	move #$90,$ffff8606;lecture DMA
	bsr tempo_fixe_mfp
	move #$89,$ffff8606
	move #$80,$ffff8604
	move.l #TIME_OUT_CMDE,D0
	bsr tempo_hz_200
	move #$89,$ffff8606
	move #0,$ffff8604
	move.l #200,D0;1 S
	bsr tempo_hz_200
	rts

arret_hdc_scsi_tt:

	move.b #$80,$ffff8783;NCR 5380 ZILOG gestion SCSI
	move.l #TIME_OUT_CMDE,D0
	bsr tempo_hz_200
	move.b #0,$ffff8783
	move.l #200,D0;1 S
	bsr tempo_hz_200
	rts

params_hdc_acsi:;canal dans D0, nbre octets de commande dans D2
;A1: buffer octets de commande
;au retour si D0 < 0 => time-out

	movem.l D1/D2/A1,-(SP)
	cmp.b #$1f,(A1)
	bhi.s pa3;commande audio => n'envoi pas le canal ?
	asl #5,D0
	or.b D0,(A1)
pa3:
	move $ffff8606,D1
	and #$100,D1;conserve flag lecture/‚criture
	move.b #$8a,D1
	subq #2,D2;compteur octets de commande
	bmi pa1
pa2:	
		bsr wait_hdc_acsi
		bmi pa1
		moveq #0,D0
		move.b (A1)+,D0;octets de commande
		swap D0
		move D1,D0
		move.l D0,$ffff8604
	dbra D2,pa2	
pa1:
	move D1,$ffff8606
	moveq #0,D0
	clr.b D1
	move D1,D0
	move.l D0,$ffff8604;transfert
	moveq #0,D0
	movem.l (SP)+,D1/D2/A1
	rts

params_hdc_scsi_falcon:;canal dans D0, nbre octets de commande dans D2
;A1: buffer octets de commande
;au retour si D0 < 0 => time-out

	movem.l D1-D3/A1,-(SP)
	move #$8c,$ffff8606
	move.l _hz_200,D1
pf1:
		move $ffff8604,D3;‚tat DMA
		btst #6,D3
		beq pf2
		move.l _hz_200,D3
		sub.l D1,D3
		cmp.l #TIME_OUT_CMDE,D3
	blt pf1
	bra pf7
pf2:
	move #$8b,$ffff8606
	move #0,$ffff8604
	move #$8c,$ffff8606
	move #0,$ffff8604
	move #$89,$ffff8606
	move #$c,$ffff8604
	moveq #0,D1
	and #7,D0;canal SCSI
	bset D0,D1
	move #$88,$ffff8606
	move D1,$ffff8604
	move #$89,$ffff8606
	move #5,$ffff8604
	move #$8a,$ffff8606
	move $ffff8604,D0
	and.b #$fe,D0
	move D0,$ffff8604
	move #$89,$ffff8606
	move $ffff8604,D0
	and #$f7,D0
	move D0,$ffff8604
	bsr tempo_fixe_mfp
	move #$8c,$ffff8606
	move.l _hz_200,D1
pf6:
		move $ffff8604,D0;‚tat DMA
		btst #6,D0
		bne pf3
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l #TIME_OUT_CMDE,D0
	blt pf6
pf7:
	move #$89,$ffff8606
	move #0,$ffff8604
	moveq #-1,D0;time-out
 	bra pf5
pf3:
	move #$89,$ffff8606
	move #0,$ffff8604
	move #$8b,$ffff8606
	move #2,$ffff8604
	move #$89,$ffff8606
	move #1,$ffff8604
	subq #1,D2;compteur octets de commande
	bmi pf8
pf4:
		bsr wait_hdc_scsi_falcon
		bmi pf5;time-out
		moveq #0,D0
		move.b (A1)+,D0;octets de commande
		move #$88,$ffff8606
		move D0,$ffff8604
		bsr strobe_scsi_falcon
	dbra D2,pf4
pf8:
	moveq #0,D0
pf5:
	movem.l (SP)+,D1-D3/A1
	rts

params_hdc_scsi_tt:;canal dans D0, nbre octets DMA dans D1
;nbre octets de commande dans D2
;A0: buffer DMA, A1: buffer octets de commande
;au retour si D0 < 0 => time-out

	movem.l D1-D4/A0-A2,-(SP)
	move.l _hz_200,D4
pt1:
		btst #6,$ffff8789;NCR 5380 ZILOG
		beq pt2
		move.l _hz_200,D3
		sub.l D4,D3
		cmp.l #TIME_OUT_CMDE,D3
	blt pt1
	bra pt7
pt2:
	move.b #0,$ffff8787
	move.b #0,$ffff8789
	move.b #$c,$ffff8783
	moveq #0,D3
	and #7,D0;canal SCSI
	bset D0,D3
	move.b D3,$ffff8781
	move.b #$d,$Ffff8783
	and.b #$fe,$ffff8785
	and.b #$f7,$ffff8783
	bsr tempo_fixe_mfp
	move.l _hz_200,D4
pt6:
		btst #6,$ffff8789;NCR 5380 ZILOG
		bne pt3
		move.l _hz_200,D3
		sub.l D4,D3
		cmp.l #TIME_OUT_CMDE,D3
	blt pt6
pt7:
	move.b #0,$ffff8783
	moveq #-1,D0;time-out
	bra pt5
pt3:
	move.b #0,$ffff8783
	lea $ffff8701,A2
	move.l A0,D0;adresse
	movep.L D0,0(A2);adresse DMA
	lea $ffff8709,A2
	movep.l D1,0(A2);nbre d'octets compteur DMA
	move.b #2,$ffff8787
	move.b #1,$ffff8783
	moveq #-1,D0
	subq #1,D2;compteur octets de commande
	bmi pt5
pt4:
		bsr wait_hdc_scsi_tt
		bmi pt5;time-out
		move.b (A1)+,$ffff8781;octets de commande
		bsr strobe_scsi_tt
	dbmi d2,pt4
pt5:
	tst.l d0
	movem.l (SP)+,D1-D4/A0-A2
	rts

strobe_scsi_falcon:

	move D0,-(SP)
	move #$89,$ffff8606
	move $ffff8604,D0
	or.b #$11,D0
	move D0,$ffff8604
	and.b #$ef,D0
	move d0,$ffff8604
	move (SP)+,D0
	rts

strobe_scsi_tt:;au retour si D0 < 0 => time-out

	move.l D1,-(SP)
	or.b #$11,$ffff8783
	move.l _hz_200,D1
st1:
		btst #5,$ffff8789;NCR 5380 ZILOG
		beq st2
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l #TIME_OUT_CMDE,D0
	blt st1
	moveq #-1,D0;time-out
	bra st3
st2:
	moveq #0,D0
st3:
	and.b #$ef,$ffff8783
	move.l (SP)+,D1
	tst.l D0
	rts

tempo_fixe_mfp:

	tst.b $fffffa01;tempo fixe par accŠs sur GPIP MFP 68901
	tst.b $fffffa01
	tst.b $fffffa01
	tst.b $fffffa01
	rts

tempo_hz_200:;dans D0.L

	movem.l D1/D2,-(SP)
	move.l _hz_200,D1
th1:	move.l _hz_200,D2;incr‚ment‚ toutes les 5 mS
		sub.l D1,D2
		cmp.l D0,D2
	blt th1
	movem.l (SP)+,D1/D2
	rts

wait_hdc_acsi:;au retour si D0 < 0 => time-out

	move.l #TIME_OUT_CMDE,D0
	bsr attente_hdc
	rts

wait_hdc_scsi_falcon_2:;au retour si D0 < 0 => time-out

	movem.l D1/D2,-(SP)
	move.l #TIME_OUT_4S,D2
	bra suite_wait_hdc_scsi_falcon

wait_hdc_scsi_falcon:;au retour si D0 < 0 => time-out

	movem.l D1/D2,-(SP)
	move.l #TIME_OUT_CMDE,D2
suite_wait_hdc_scsi_falcon:
	move #$8c,$ffff8606
	move.l _hz_200,D1
whf1:
		move $ffff8604,D0
		btst #5,D0
		bne whf2
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l D2,D0
	blt whf1
	moveq #-1,D0;time-out
	bra whf3
whf2:
	moveq #0,D0
whf3:
	movem.l (SP)+,D1/D2
	rts

wait_hdc_scsi_tt:;au retour si D0 < 0 => time-out

	move.l D1,-(SP)
	move.l _hz_200,D1
wht1:
		btst #5,$ffff8789;NCR 5380 ZILOG
		bne wht2
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l #TIME_OUT_CMDE,D0
	blt wht1
	moveq #-1,D0;time-out
	bra wht3
wht2:
	moveq #0,D0
wht3:
	move.l (SP)+,D1
	tst.l D0
	rts

wait_cmde_hdc_acsi:;au retour si D0 < 0 => time-out

	move.l #TIME_OUT_4S,D0
	bsr attente_hdc
	rts

wait_cmde_hdc_scsi_falcon:;au retour si D0 < 0 => time-out

	move.l #TIME_OUT_4S,D0
	cmp #6,D2;nbre d'octets de commande
	beq wcf3
	move.l #TIME_OUT_10S,D0
wcf3:
	bsr attente_hdc
	bpl wcf2
	bsr arret_hdc_scsi_falcon
	moveq #-1,D0
	bra wcf1
wcf2:
	move #$8f,$ffff8606
	move $ffff8604,D0
	move #$8a,$ffff8606
	move #0,$ffff8604
	move #$89,$ffff8606
	move #0,$ffff8604
	moveq #0,D0
wcf1:
	rts

wait_cmde_hdc_scsi_tt:;au retour si D0 < 0 => time-out sinon erreur

	movem.l D1/D3,-(SP)
	move.l #TIME_OUT_4S,D3
	cmp #6,D2;nbre d'octets de commande
	beq wct6
	move.l #TIME_OUT_10S,D3
wct6:
	move.l _hz_200,D1
wct2:
		btst #7,$fffffa81;GPIP 2Šme MFP 68901 attente fin de commande
		bne wct1
		move.l _hz_200,D0
		sub.l D1,D0
		cmp.l D3,D0;time-out
		bge wct3
		btst #5,$fffffa81;GPIP 2Šme MFP 68901
		bne wct4
		move $ffff8714,D0
		and.l #$80,D0
		beq.S wct2
		move.l D0,-(SP)
		bsr arret_hdc_scsi_tt
		move.l (SP)+,D0
		bra wct5
wct4:	move.l _hz_200,D0
		sub.l D1,D0
		cmp.l D3,D0;time-out
	blt wct2
wct3:
	bsr arret_hdc_scsi_tt
	moveq #-1,D0;time-out
	bra wct5
wct1:
	move.b $ffff878f,D1
	move #0,$ffff8714
	move.b #0,$ffff8785
	move.b #0,$ffff8783
	moveq #0,D0
wct5:
	movem.l (SP)+,D1/D3
	tst.l D0
	rts

attente_hdc:;time-out dans D0.L
;au retour si D0 < 0 => time-out

	movem.l D1/D2,-(SP)
	move.l _hz_200,D1
ah1:
		btst #5,$fffffa01;GPIP MFP 68901 attente fin de commande
		beq ah2
		move.l _hz_200,D2
		sub.l D1,D2
		cmp.l D0,D2
	blt ah1
	moveq #-1,D0;time-out
	bra ah3
ah2:
	moveq #0,D0
ah3:
	movem.l (SP)+,D1/D2
	rts

get_cookie:;au retour si < 0 pas de cookie
;retourne contenu dans D0

	movem.l D5-A0,-(SP)
	move.l D0,D6
	moveq #-1,D5
	moveq #0,D7
	move.l _cookie,D0
	beq gc1
	move.l D0,A0
gc2:
		tst.l (A0)
		beq gc1
		cmp.l (A0),D6
		bne gc3
		move.l 4(A0),D7
		moveq #0,D5
		bra gc1
gc3:
	addq #8,A0
 	bra gc2
gc1:
	move.l D7,D0
	tst d5
	movem.l (SP)+,D5-A0
	rts

	end