;%%%%%%%%%%%%%%%%%%%%%%%%
;%
;%  Chargement d'images JPEG
;%
;%%%%%%%%%%%%%%%%%%%%%%%%

;******************************************************************
;****                                                          ****
;**** JPEG DECODER    ½ 01/1994 BRAINSTORM & SUNIX/THE EXTRACT ****
;****                                                          ****
;******************************************************************

;	On  appelle  tout  d'abord INDSP (chargement du d‚codeur en
;	m‚moire  DSP)  sans  paramŠtres.  On  appelle ensuite INBUF
;	avant  chaque  d‚codage  (clear  du  buffer d'‚change entre
;	l'application  et  le d‚codeur) en lui indiquant avec A0 l'
;	adresse  du  buffer  ($a34 octets). A0 devra pointer sur ce
;	buffer  avant  tout  appel  au d‚codeur (sauf pour INDSP et
;	EXDSP).  Puis  on  indique  l'adresse  de l'image (A0+04).L
;	ainsi  que  sa taille (A0+12).L et le format de destination
;	(A0+24).W  (2  pour  16 bits ou 3 pour 24 bits). On appelle
;	PASS1  et  en  retour,  on  a la taille de l'image d‚pack‚e
;	(A0+16).L  ainsi  que  sa r‚solution en x (A0+52).W et en y
;	(A0+54).W  (en pixels).  Il  ne reste plus qu'… indiquer l'
;	adresse  du  buffer  pour  d‚packer  l'image (A0+08).L et …
;	lancer  son d‚codage par un appel a PASS2. Il est conseill‚
;	d'appeller EXDSP en fin de programme (pour lib‚rer le DSP).
;
;						SUNIX/THE EXTRACT


 TEXT
 
teste_image_jpeg
charge_image_jpeg
 bsr indsp			Charge le d‚codeur dans la m‚moire du DSP

 lea buffer_jpeg,a0		Initialisation du buffer d'‚change entre le d‚codeur
 bsr inbuf			et ma routine.

 lea buffer_jpeg,a0		Indique au d‚codeur JPEG les informations de base
 move.l buffer_fichier,4(a0)	sur l'image
 move.l taille_fichier,12(a0)
 move #2,24(a0)			2=Chargement en 16 bits/3=24 bits
 bsr pass1
* tst d0
* bne .erreur_jpeg
 
 lea buffer_jpeg,a0
 move 52(a0),d0			Largeur de l'image
 add d0,d0
 move d0,largeur_image
 move 54(a0),hauteur_image  	Hauteur de l'image
 move.l 16(a0),d0		Taille de l'image d‚pack‚e AVEC LES MERDES EN PLUS !!!
 lea buffer_d‚packing,a0
 bsr.l r‚serve_bloc
 bmi .erreur_jpeg

 lea buffer_jpeg,a0
 move.l	buffer_d‚packing,8(a0)	Endroit o— il faut ‚crire l'image
 move #3,22(a0)
 move #2,24(a0)
 clr 26(a0)
 bsr pass2
 tst d0
 bmi .erreur_jpeg

 bsr.l pr‚pare_buffer_image
 bne .erreur_jpeg

 move largeur_image,d0
 lsr d0			Largeur en pixels
 addq #7,d0		+ 7
 lsr #3,d0		Divise par 8
 btst #0,d0		Impaire ???
 beq.s .paire_ok
 addq #1,d0		Non, alors rend le pair !
.paire_ok
 lsl #3,d0		Remultiplie par 8
 lsl d0			Pour avoir la largeur en mots... 
 
 move.l buffer_d‚packing,a0
 move.l fichier,a1

 move hauteur_image,d6
 subq #1,d6
.ligne_suivante
 move.l a0,a2
 add d0,a0
 move largeur_image,d7
 lsr d7
 subq #1,d7
.recopie_ligne
 move (a2)+,(a1)+
 dbra d7,.recopie_ligne
 dbra d6,.ligne_suivante
 
 bsr exdsp
 moveq #0,d0
 rts

.erreur_jpeg
 bsr exdsp
 bra erreur_m‚moire_chargement

; + 4.L		Adresse du fichier source
; + 8.L		Adresse du buffer de d‚packing
; + 12.L	Taille du fichier source
; + 24.W	Nombre d'octets par pixel (2 ou 3)
; + 26.W	[Fichier ???]
; + 52.W	Largeur
; + 54.W	Hauteur

exdsp
 move #$69,-(sp)	Xbios(105): Dsp_Unlock
 trap #$e
 addq #2,sp
 rts

inbuf
 move #2612,d0
 lsr #2,d0
 subq #1,d0
.efface_buffer
 clr.l (a0)+
 dbra d0,.efface_buffer
 rts

pass1
	movea.l	a0,a6
	move.l	#$10000,(a6)
	movea.l	buffer_fichier,a5		A5=D‚but du fichier JPEG
	lea	table_ffandco(pc),a0
	moveq	#-1,d2
	move	(a5)+,d0
	cmp.w	#$ffd8,d0
	bne	jpg_erreur_pass_1
	moveq	#0,d0
l025a	move.b	(a5)+,d0
	cmp.b	d2,d0
	bne.s	l025a
l025b	move.b	(a5)+,d0
	cmp.b	d2,d0
	beq.s	l025b
	move.w	d0,d1
	andi.w	#$f0,d0
	cmp.w	#$c0,d0
	bne.s	l025c
	eor.w	d0,d1
	tst.b	0(a0,d1.w)
	bne.s	l025d
l025c	adda.w	(a5),a5
	bra.s	l025a
l025d	addq.w	#3,a5
	move.w	(a5)+,54(a6)	Hauteur
	move.w	(a5)+,52(a6)	Largeur
	moveq	#0,d0
	move.b	(a5)+,d0
	move	d0,20(a6)
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d6
	moveq	#0,d7
	subq.w	#1,d0
l025e	addq.w	#1,a5
	move.b	(a5)+,d1
	move.b	d1,d2
	andi.w	#$f,d1
	eor.w	d1,d2
	lsr.w	#4,d2
	cmp.b	d2,d6
	bge.s	l025f
	move.b	d2,d6
l025f	cmp.b	d1,d7
	bge.s	l0260
	move.b	d1,d7
l0260	addq.w	#1,a5
	dbf	d0,l025e
	lsl.w	#3,d6
	lsl.w	#3,d7
	subq.w	#1,d6
	subq.w	#1,d7
	move.w	52(a6),d0
	move.w	54(a6),d1
	add.w	d6,d0
	add.w	d7,d1
	not.w	d6
	not.w	d7
	and.w	d6,d0
	and.w	d7,d1
	mulu	24(a6),d0	Nombre d'octets (2:16 bits,3:24 bits)
	lsr.w	#1,d0
	move.w	d0,56(a6)
	mulu	d1,d0
	add.l	d0,d0
	move.l	d0,16(a6)	Taille du fichier
	moveq	#0,d0
	rts
jpg_erreur_pass_1
	moveq	#1,d0
	rts

table_ffandco
	dc.b	$ff,$ff,$ff,$ff,$00,$ff,$ff,$ff
	dc.b	$ff,$ff,$ff,$ff,$00,$ff,$ff,$ff


pass2
	movea.l	a0,a6
	move.l	buffer_fichier,a5
	move.w	(a5)+,d0
	cmp.w	#$ffd8,d0
	bne.s	jpg_erreur_pass2
l0266	move.b	(a5)+,d0
	cmp.b	#$ff,d0
	bne.s	l0266
	tst.b	(a5)
	beq.s	l0266
	bsr.s	l026d
	beq.s	l0266
	cmp.w	#2,d0
	bne.s	l0267
	moveq	#0,d0
l0267	move.w	d0,-(sp)
	lea	1358(a6),a0
	bsr.s	jpg_libŠre_memoire
	lea	1366(a6),a0
	bsr.s	jpg_libŠre_memoire1
	lea	68(a6),a0
	bsr.s	jpg_libŠre_memoire1
	lea	72(a6),a0
	bsr.s	jpg_libŠre_memoire1
	lea	76(a6),a0
	bsr.s	jpg_libŠre_memoire1
	lea	80(a6),a0
	bsr.s	jpg_libŠre_memoire1
	tst.w	26(a6)
	move.w	(sp)+,d0
l0269	tst.w	d0
	rts
jpg_erreur_pass2
	moveq	#1,d0
	rts

jpg_libŠre_memoire
	movem.l	a0-a2/d1-d2,-(sp)
	bsr.l libŠre_bloc
	tst.l	d0
	movem.l	(sp)+,a0-a2/d1-d2
	clr.l (a0)
	rts

jpg_libŠre_memoire1
	movem.l	a0-a2/d1-d2,-(sp)
	bsr.l libŠre_bloc_jpg
	tst.l	d0
	movem.l	(sp)+,a0-a2/d1-d2
	clr.l (a0)
	rts

l026d	moveq	#0,d0
	move.b	(a5)+,d0
	eori.b	#$80,d0
	bmi	l026f
	jmp	([l026e.l,d0.w*4])
l026e
	rept 64
	dc.l	l026f
	endr

	dc.l	l0270
	dc.l	l0275
	dc.l	l0276
	dc.l	l0277
	dc.l	l02sp
	dc.l	l0278
	dc.l	l0279
	dc.l	l027a
	dc.l	l02a6
	dc.l	l027b
	dc.l	l027c
	dc.l	l027d
	dc.l	l02ad
	dc.l	l027e
	dc.l	l027f
	dc.l	l0280

	rept 8 
	dc.l	l0288
	endr

	dc.l	l026f
	dc.l	l026f
	dc.l	l02b0
	dc.l	l02b9
	dc.l	l02c1
	dc.l	l02c2
	dc.l	l02c3
	dc.l	l02c4
	
	rept 30
	dc.l	l02a6
	endr

	dc.l	l02a6
	dc.l	l026d
	
l0270	movem.l	a0-a1/d1-d5,-(sp)
	move.w	(a5)+,d5
	move.b	(a5)+,d0
	cmp.b	#8,d0
	bne.s	l0274
	move.w	(a5)+,d0
	move.w	d0,1284(a6)
	bne.s	l0271
	bsr	l02c1
	bne.s	l0273
l0271	move.w	(a5)+,d0
	beq.s	l0274
	move.w	d0,1282(a6)
	moveq	#0,d4
	move.b	(a5)+,d4
	beq.s	l0274
	move.w	d4,20(a6)
	lea	1370(a6),a0
	lea	2394(a6),a1
	not.l	(a1)
	not.l	4(a1)
	not.w	8(a1)
	moveq	#0,d2
	move.w	d4,d3
	mulu	#3,d3
	addq.w	#8,d3
	subq.w	#1,d4
	bmi.s	l0274
l0272	move.b	(a5)+,d2
	move.w	d2,(a1)+
	tas	0(a0,d2.w*4)
	bne.s	l0274
	move.b	(a5)+,d0
	move.b	d0,d1
	andi.b	#$f,d1
	eor.b	d1,d0
	lsr.b	#4,d0
	move.b	d0,1(a0,d2.w*4)
	move.b	d1,2(a0,d2.w*4)
	move.b	(a5)+,d1
	move.b	d1,3(a0,d2.w*4)
	dbf	d4,l0272
	cmp.w	d5,d3
	bne.s	l0274
	move.w	#1,2404(a6)
	moveq	#0,d0
l0273	movem.l	(sp)+,a0-a1/d1-d5
	rts
l0274	moveq	#$1d,d0
	movem.l	(sp)+,a0-a1/d1-d5
	rts

l026f	moveq	#2,d0
	rts
l0275	moveq	#3,d0
	rts
l0276	moveq	#4,d0
	rts
l0277	moveq	#5,d0
	rts
l0278	moveq	#6,d0
	rts
l0279	moveq	#7,d0
	rts
l027a	moveq	#8,d0
	rts
l027b	moveq	#10,d0
	rts
l027c	moveq	#11,d0
	rts
l027d	moveq	#12,d0
	rts
l027e	moveq	#13,d0
	rts
l027f	moveq	#14,d0
	rts
l0280	moveq	#15,d0
	rts
l0288	moveq	#16,d0
	rts

l02ad	moveq	#$12,d0
	rts

l02c1	moveq	#$14,d0
	rts

l02c2	moveq	#$15,d0
	rts

l02c3	moveq	#$16,d0
	rts

l02c4	moveq	#$17,d0
	rts

l032c	moveq	#$20,d0
	rts

l02a6	adda.w	(a5),a5
	moveq	#0,d0
	rts

l02sp	movem.l	a0-a3/d1-d3,-(sp)
	movea.l	a5,a3
	move.w	(a5)+,d0
	adda.w	d0,a3
l02a8	moveq	#0,d0
	move.b	(a5)+,d0
	move.b	d0,d1
	andi.w	#$f,d0
	cmp.w	#1,d0
	bhi.s	l02ab
	eor.w	d0,d1
	btst	#4,d1
	bne.s	l02aa
	st	100(a6,d0.w)
	movea.l	a5,a0
	bsr	l02e4
	bne.s	l02a9
	cmpa.l	a3,a5
	blt.s	l02a8
	bne.s	l02ab
	moveq	#0,d0
l02a9	movem.l	(sp)+,a0-a3/d1-d3
	rts
l02aa	st	102(a6,d0.w)
	movea.l	a5,a0
	bsr	l02f0
	bne.s	l02a9
	cmpa.l	a3,a5
	blt.s	l02a8
	bne.s	l02ab
	moveq	#0,d0
	movem.l	(sp)+,a0-a3/d1-d3
	rts
l02ab	moveq	#$11,d0
	movem.l	(sp)+,a0-a3/d1-d3
	rts


l02b0	movem.l	a0-a1/d1-d5,-(sp)
	cmpi.w	#1,2404(a6)
	bne	l02b8
	move.w	(a5)+,d5
	moveq	#0,d3
	moveq	#0,d4
	move.b	(a5)+,d3
	cmp.w	20(a6),d3
	bne	l02b8
	subq.w	#1,d3
	moveq	#0,d4
	lea	1370(a6),a0
	lea	1286(a6),a1
	move.w	d3,d1
	add.w	d1,d1
	addq.w	#8,d1
	cmp.w	d5,d1
	bne	l02b8
l02b1	moveq	#0,d0
	move.b	(a5)+,d0
	tst.b	0(a0,d0.w*4)
	beq	l02b8
	moveq	#0,d1
	moveq	#0,d2
	move.b	1(a0,d0.w*4),d1
	move.b	2(a0,d0.w*4),d2
	bsr	l0324
	bne	jpg_fin_passe_dsp
	mulu	d2,d1
	add.w	d1,d4
	subq.w	#1,d1
	move.w	d1,(a1)
	moveq	#0,d0
	move.b	(a5)+,d0
	move.w	d0,d1
	lsr.w	#4,d0
	andi.w	#$f,d1
	tst.b	100(a6,d0.w)
	beq	l02b8
	tst.b	102(a6,d1.w)
	beq	l02b8
	move.l	84(a6,d0.w*4),6(a1)
	move.l	92(a6,d1.w*4),2(a1)
	lea	10(a1),a1
	dbf	d3,l02b1
	move.w	#$ffff,(a1)
	move.w	d4,1348(a6)
	bsr	l0326
	bne	jpg_fin_passe_dsp
	move.w	(a5)+,d0
	cmp.w	#$3f,d0
	bne	l02b8
	move.b	(a5)+,d0
	bne	l02b8
	moveq	#0,d0
	move.w	1282(a6),d0
	move.w	1350(a6),d1
	lsl.w	#3,d1
	divu	d1,d0
	move.w	d0,d1
	swap	d0
	tst.w	d0
	beq.s	l02b2
	addq.w	#1,d1
l02b2	move.w	d1,28(a6)
	moveq	#0,d0
	move.w	1284(a6),d0
	move.w	1352(a6),d1
	lsl.w	#3,d1
	divu	d1,d0
	move.w	d0,d1
	swap	d0
	tst.w	d0
	beq.s	l02b3
	addq.w	#1,d1
l02b3	move.w	d1,30(a6)
	moveq	#0,d0
	move.w	1348(a6),d0
	lsl.l	#7,d0
	addq.l	#4,d0
	move.l	d0,d1
	lea	1358(a6),a0
	bsr	jpg_r‚serve_m‚moire1
	bne	jpg_fin_passe_dsp
	move.l	d1,1362(a6)
	
	move.l	1358(a6),a0
	move.w	1350(a6),d0
	mulu	1352(a6),d0
	mulu	28(a6),d0
	mulu	20(a6),d0
	lsl.l	#6,d0			x64
	lea	1366(a6),a0		Adresse buffer MCU ???
	bsr	jpg_r‚serve_m‚moire1
	bne.s	jpg_fin_passe_dsp

	move.l	1366(a6),a0		Adresse buffer MCU ???
	bsr	jpg_execute_dsp
	bne.s	jpg_fin_passe_dsp
	bsr	l02ce
	bsr	l02fc
	bsr	l0337
	bsr	l033d
	bsr	l0343
	bne.s	jpg_fin_passe_dsp
	move.w	30(a6),d1
	subq.w	#1,d1
l02b4	bsr	l02c6
	bne.s	jpg_fin_passe_dsp
	bsr	l02ff
	dbf	d1,l02b4
	move.w	172(a6),d0
	cmp.w	#$f,d0
	blt.s	l02b5
	move.b	-(a5),d0
	cmpi.b	#$ff,-1(a5)
	bne.s	l02b5
	subq.w	#1,a5
l02b5	cmp.w	#8,d0
	blt.s	l02b6
	move.b	-(a5),d0
	cmpi.b	#$ff,-1(a5)
	bne.s	l02b6
	subq.w	#1,a5
l02b6	moveq	#0,d0
jpg_fin_passe_dsp
	movem.l	(sp)+,a0-a1/d1-d5
	rts
l02b8	moveq	#$1e,d0
	movem.l	(sp)+,a0-a1/d1-d5
	rts

l02b9	movem.l	a0-a1/d1-d3,-(sp)
	moveq	#$41,d1
	move.w	(a5)+,d0
	subq.w	#2,d0
	sub.w	d1,d0
	beq.s	l02be
	sub.w	d1,d0
	beq.s	l02bd
	sub.w	d1,d0
	beq.s	l02bc
	sub.w	d1,d0
	beq.s	l02bb
l02ba	moveq	#$13,d0
	movem.l	(sp)+,a0/d1-d2
	rts

l02bb	moveq	#3,d3
	bra.s	l02bf
l02bc	moveq	#2,d3
	bra.s	l02bf
l02bd	moveq	#1,d3
	bra.s	l02bf
l02be	moveq	#0,d3
l02bf	lea	l036e(pc),a1
	moveq	#0,d0
	move.b	(a5)+,d0
	move.b	d0,d1
	andi.b	#$f,d0
	eor.b	d0,d1
	bne.s	l02ba
	lsl.w	#8,d0
	lea	190(a6),a0
	adda.w	d0,a0
	moveq	#0,d1
	moveq	#$3f,d2
l02c0	moveq	#0,d0
	move.b	(a5)+,d0
	lsl.w	#8,d0
	lsl.l	#4,d0
	move.l	(a1)+,d1
	move.l	d0,0(a0,d1.w*2)
	dbf	d2,l02c0
	dbf	d3,l02bf
	moveq	#0,d0
	movem.l	(sp)+,a0-a1/d1-d3
	rts

l02c6	movem.l	a0-a4/d1-d7,-(sp)
	movea.l	1358(a6),a3
	addq.w	#2,a3
	movea.l	1366(a6),a4
	move.w	1350(a6),d4
	mulu	1352(a6),d4
	lsl.w	#6,d4
	move.l	2406(a6),d5
	move.w	1348(a6),d6
	lsl.w	#6,d6
	addq.w	#1,d6
	move.w	28(a6),d7
	subq.w	#1,d7
	bsr	l02cf
	bne.s	l02c8
l02c7	clr.l	-(sp)
	clr.l	-(sp)
	move.l	d6,-(sp)
	move.l	a3,-(sp)
	move.w	#$7b,-(sp)	Xbios(123): Dsp_BlkWords
	trap	#$e
	lea	18(sp),sp
	bsr	l02cf
	bne.s	l02c8
	jsr	(d5.l)
	dbf	d7,l02c7
	moveq	#0,d0
l02c8	movem.l	(sp)+,a0-a4/d1-d7
	rts

jpg_dsp_blkbytes
	move.l	d4,-(sp)
	move.l	a4,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#$7c,-(sp)	Xbios(124): Dsp_BlkBytes
	trap	#$e
	lea	18(sp),sp
	adda.w	d4,a4
	rts

jpg_dsp_blkbytes2
	move.l	d4,-(sp)
	add.l	d4,(sp)
	move.l	a4,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#$7c,-(sp)	Xbios(124): Dsp_BlkBytes
	trap	#$e
	lea	18(sp),sp
	lea	0(a4,d4.w*2),a4
	rts

jpg_dsp_blkwords2
	move.l	d4,-(sp)
	move.l	a4,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#$7b,-(sp)	Xbios(123): Dsp_BlkWords
	trap	#$e
	lea	18(sp),sp
	lea	0(a4,d4.w*2),a4
	rts

jpg_dsp_blkbytes3
	move.l	d4,-(sp)
	add.l	d4,(sp)
	add.l	d4,(sp)
	move.l	a4,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#$7c,-(sp)	Xbios(124): Dsp_BlkBytes
	trap	#$e
	lea	18(sp),sp
	adda.w	d4,a4
	lea	0(a4,d4.w*2),a4
	rts

jpg_dsp_blkbytes4
	move.l	d4,-(sp)
	add.l	d4,(sp)
	add.l	d4,(sp)
	add.l	d4,(sp)
	move.l	a4,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.w	#$7c,-(sp)	Xbios(124): Dsp_BlkBytes
	trap	#$e
	lea	18(sp),sp
	lea	0(a4,d4.w*4),a4
	rts

l02ce	clr.w	([1358.w,a6],2.w)
	clr.w	172(a6)
	rts

l02cf	movem.l	a0-a4/d1-d7,-(sp)
	tst.w	d7
	beq	l02e2
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	suba.l	a1,a1
	movea.l	1358(a6),a0
	add.l	1362(a6),a0
	move.w	1348(a6),d7
	subq.w	#1,d7
l02d0	movem.l	a1/d0-d6,-(a0)
	movem.l	a1/d0-d6,-(a0)
	movem.l	a1/d0-d6,-(a0)
	movem.l	a1/d0-d6,-(a0)
	dbf	d7,l02d0
	move.w	172(a6),d2
	lea	l0370(pc),a4
	movea.l	a0,a3
	clr.l	-(sp)
	pea	1286(a6)
l02d1	movea.l	(sp),a2
	move.w	(a2)+,d7
	bmi	l02e1
	move.l	(a2)+,d6
l02d2	movea.l	([sp],6.w),a2
	lea	l036f(pc),a0
	tst.w	d2
	beq.s	l02d5
	subq.w	#1,d2
	move.w	d2,d1
	move.w	d2,d3
	subi.w	#$f,d1
	neg.w	d1
	moveq	#0,d0
	move.b	-(a5),d0
	bne.s	l02d3
	move.b	-1(a5),d0
	suba.w	0(a4,d0.w*2),a5
l02d3	move.b	-(a5),d0
	bne.s	l02d4
	move.b	-1(a5),d0
	suba.w	0(a4,d0.w*2),a5
l02d4	moveq	#0,d0
	moveq	#0,d2
	move.b	(a5)+,d0
	adda.w	0(a4,d0.w*2),a5
	move.b	(a5)+,d2
	adda.w	0(a4,d2.w*2),a5
	lsl.w	#8,d0
	move.b	d2,d0
	lsl.w	d1,d0
	move.w	d3,d2
	bra.s	l02d6
l02d5	moveq	#0,d2
	move.b	(a5)+,d0
	adda.w	0(a4,d0.w*2),a5
	move.b	(a5)+,d2
	adda.w	0(a4,d2.w*2),a5
	lsl.w	#8,d0
	move.b	d2,d0
	moveq	#$f,d2
l02d6	add.w	d0,d0
	subx.w	d1,d1
	move.w	0(a2,d1.w*2),d1
	adda.w	d1,a2
	dbpl	d2,l02d6
	bmi.s	l02d5
	moveq	#0,d1
	move.l	(a2),d3
	bmi	l02e3
	moveq	#0,d1
	move.w	d3,d4
	bmi.s	l02d9
	dbf	d2,l02d8
l02d7	moveq	#0,d2
	move.b	(a5)+,d0
	adda.w	0(a4,d0.w*2),a5
	move.b	(a5)+,d2
	adda.w	0(a4,d2.w*2),a5
	lsl.w	#8,d0
	move.b	d2,d0
	moveq	#$f,d2
l02d8	add.w	d0,d0
	addx.w	d1,d1
	subq.w	#1,d3
	dbmi	d2,l02d8
	bpl.s	l02d7
	btst	d4,d1
	seq	d3
	add.b	d3,d3
	addx.w	d4,d4
	add.w	-44(a4,d4.w*2),d1
l02d9	add.w	([4.w,sp],a6.l,$ae.w),d1
	move.w	d1,([4.w,sp],a6.l,$ae.w)
	move.w	d1,(a3)
	move.w	#$fc,d5
l02da	movea.l	d6,a2
	dbf	d2,l02dc
l02db	moveq	#0,d2
	move.b	(a5)+,d0
	adda.w	0(a4,d0.w*2),a5
	move.b	(a5)+,d2
	adda.w	0(a4,d2.w*2),a5
	lsl.w	#8,d0
	move.b	d2,d0
	moveq	#$f,d2
l02dc	add.w	d0,d0
	subx.w	d1,d1
	move.w	0(a2,d1.w*2),d1
	adda.w	d1,a2
	dbpl	d2,l02dc
	bmi.s	l02db
	move.l	(a2),d3
	beq.s	l02e0
	sub.w	d3,d5
	adda.w	d3,a0
	swap	d3
	subq.w	#1,d3
	bmi.s	l02df
	move.w	d3,d4
	moveq	#0,d1
	dbf	d2,l02de
l02dd	moveq	#0,d2
	move.b	(a5)+,d0
	adda.w	0(a4,d0.w*2),a5
	move.b	(a5)+,d2
	adda.w	0(a4,d2.w*2),a5
	lsl.w	#8,d0
	move.b	d2,d0
	moveq	#$f,d2
l02de	add.w	d0,d0
	addx.w	d1,d1
	subq.w	#1,d3
	dbmi	d2,l02de
	bpl.s	l02dd
	btst	d4,d1
	seq	d3
	add.b	d3,d3
	addx.w	d4,d4
	add.w	-44(a4,d4.w*2),d1
	move.w	d1,([a0],a3.l)
l02df	addq.w	#4,a0
	subq.w	#4,d5
	bne.s	l02da
l02e0	lea	128(a3),a3
	dbf	d7,l02d2
	moveq	#$a,d5
	add.l	d5,(sp)
	addq.l	#2,4(sp)
	bra	l02d1
l02e1	addq.w	#8,sp
	move.w	d2,d0
	move.w	d2,172(a6)
l02e2	moveq	#0,d0
	movem.l	(sp)+,a0-a4/d1-d7
	rts
l02e3	addq.w	#8,sp
	moveq	#$1f,d0
	movem.l	(sp)+,a0-a4/d1-d7
	rts
l02e4	movem.l	a0-a4/d1-d7,-(sp)
	move.w	d0,d7
	lea	104(a6),a1
	lea	16(a5),a2
	moveq	#$f,d0
l02e5	tst.b	-(a2)
	dbne	d0,l02e5
	move.w	d0,d6
	movea.l	a0,a2
	movea.l	a1,a3
	moveq	#0,d0
	moveq	#1,d1
	moveq	#0,d3
	moveq	#0,d4
	suba.l	a4,a4
	move.w	d6,d5
l02e6	move.w	d1,d2
	sub.w	d0,d2
	add.w	d2,d3
	move.w	d2,(a3)+
	add.w	d0,d0
	move.b	(a2)+,d4
	move.w	d4,(a3)+
	adda.w	d4,a4
	add.w	d4,d0
	add.w	d1,d1
	dbf	d5,l02e6
	ext.l	d5
	move.l	d5,(a3)
	lea	16(a5),a5
	move.l	a4,d4
	add.w	d3,d4
	addq.w	#1,d4
	lsl.w	#2,d4
	move.l	d4,d0
	lea	68(a6,d7.w*4),a0
	bsr	jpg_r‚serve_m‚moire1
	bne.s	l02ef

	move.l	68(a6,d7.w*4),a0
	lea	0(a0,d3.w*4),a2
	lea	0(a0,d3.w*4),a0
	move.l	a0,84(a6,d7.w*4)
	subq.l	#2,84(a6,d7.w*4)
l02e7	move.l	a2,d0
	sub.l	a0,d0
	addq.w	#2,d0
	move.w	(a1)+,d2
	bpl.s	l02e9
	subq.w	#4,d0
	moveq	#-1,d5
	move.l	d5,(a2)+
l02e8	tst.w	(a0)
	bpl.s	l02ee
	move.w	d0,(a0)+
	tst.w	(a0)
	bpl.s	l02ee
	move.w	d0,(a0)+
	subq.w	#4,d0
	bra.s	l02e8
l02e9	move.w	d2,d3
	lsl.w	#2,d3
	neg.w	d3
	move.w	(a1)+,d1
	beq.s	l02ed
l02ea	subq.w	#1,d1
	bmi.s	l02ed
	subq.w	#1,d2
	move.w	d0,-(a0)
	moveq	#0,d5
	move.b	(a5)+,d5
	subq.w	#1,d5
	move.l	d5,(a2)+
	addq.w	#4,d0
	subq.w	#1,d1
	bmi.s	l02ec
	move.w	d0,-(a0)
	moveq	#0,d5
	move.b	(a5)+,d5
	subq.w	#1,d5
	move.l	d5,(a2)+
	addq.w	#4,d3
	addq.w	#8,d0
	bra.s	l02ea
l02eb	move.w	d3,-(a0)
	subq.w	#4,d3
l02ec	move.w	d3,-(a0)
l02ed	dbf	d2,l02eb
	bra.s	l02e7
l02ee	moveq	#0,d0
l02ef	movem.l	(sp)+,a0-a4/d1-d7
	rts
l02f0	movem.l	a0-a4/d1-d7,-(sp)
	move.w	d0,d7
	lea	104(a6),a1
	lea	16(a5),a2
	moveq	#$f,d0
l02f1	tst.b	-(a2)
	dbne	d0,l02f1
	move.w	d0,d6
	movea.l	a0,a2
	movea.l	a1,a3
	moveq	#0,d0
	moveq	#1,d1
	moveq	#0,d3
	moveq	#0,d4
	suba.l	a4,a4
	move.w	d6,d5
l02f2	move.w	d1,d2
	sub.w	d0,d2
	add.w	d2,d3
	move.w	d2,(a3)+
	add.w	d0,d0
	move.b	(a2)+,d4
	move.w	d4,(a3)+
	adda.w	d4,a4
	add.w	d4,d0
	add.w	d1,d1
	dbf	d5,l02f2
	ext.l	d5
	move.l	d5,(a3)
	lea	16(a5),a5
	move.l	a4,d4
	add.w	d3,d4
	addq.w	#1,d4
	lsl.w	#2,d4
	move.l	d4,d0
	lea	76(a6,d7.w*4),a0
	bsr	jpg_r‚serve_m‚moire1
	bne	l02fb

	move.l	76(a6,d7.w*4),a0
	lea	0(a0,d3.w*4),a2
	lea	0(a0,d3.w*4),a0
	move.l	a0,92(a6,d7.w*4)
	subq.l	#2,92(a6,d7.w*4)
l02f3	move.l	a2,d0
	sub.l	a0,d0
	addq.w	#2,d0
	move.w	(a1)+,d2
	bpl.s	l02f5
	subq.w	#4,d0
	moveq	#-1,d5
	move.l	d5,(a2)+
l02f4	tst.w	(a0)
	bpl.s	l02fa
	move.w	d0,(a0)+
	tst.w	(a0)
	bpl.s	l02fa
	move.w	d0,(a0)+
	subq.w	#4,d0
	bra.s	l02f4
l02f5	move.w	d2,d3
	lsl.w	#2,d3
	neg.w	d3
	move.w	(a1)+,d1
	beq.s	l02f9
l02f6	subq.w	#1,d1
	bmi.s	l02f9
	subq.w	#1,d2
	move.w	d0,-(a0)
	moveq	#$f,d5
	and.b	(a5),d5
	swap	d5
	move.b	(a5)+,d5
	lsr.w	#4,d5
	lsl.w	#2,d5
	move.l	d5,(a2)+
	addq.w	#4,d0
	subq.w	#1,d1
	bmi.s	l02f8
	move.w	d0,-(a0)
	moveq	#$f,d5
	and.b	(a5),d5
	swap	d5
	move.b	(a5)+,d5
	lsr.w	#4,d5
	lsl.w	#2,d5
	move.l	d5,(a2)+
	addq.w	#4,d3
	addq.w	#8,d0
	bra.s	l02f6
l02f7	move.w	d3,-(a0)
	subq.w	#4,d3
l02f8	move.w	d3,-(a0)
l02f9	dbf	d2,l02f7
	bra.s	l02f3

l02fa	moveq	#0,d0
l02fb	movem.l	(sp)+,a0-a4/d1-d7
	rts

l02fc	movem.l	a0-a1/d1-d2,-(sp)
	lea	48(a6),a0
	move.l	buffer_d‚packing,(a0)		Adresse du buffer de d‚packing
	move.w	1282(a6),4(a0)
	move.w	1284(a6),6(a0)
	move.w	28(a6),d1
	mulu	24(a6),d1		Nombre d'octets par pixel (2 ou 3)
	mulu	1350(a6),d1
	lsl.l	#2,d1
	move.w	d1,8(a0)
	clr.w	10(a0)
	move.w	24(a6),d0		Nombre d'octets par pixel (2 ou 3)
	lsl.w	#3,d0
	move.w	d0,12(a0)
	move.w	1352(a6),d2
	movea.l	(l0372.l,d2.w*4),a0
	lea	2430(a6),a1
	lsl.w	#3,d2
	subq.w	#1,d2
l02fd	move.w	(a0)+,d0
	mulu	d1,d0
	add.l	d0,d0
	move.l	d0,(a1)+
	dbf	d2,l02fd
	move.w	24(a6),d0		Nombre d'octets par pixel (2 ou 3)
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	1352(a6),d0
	subq.w	#1,d0
	move.l	(l0371.l,d0.w*4),2426(a6)
	move.l	buffer_d‚packing,2414(a6)		Adresse o— l'on d‚packe
	move.w	1352(a6),d0
	mulu	1350(a6),d0
	mulu	28(a6),d0
	mulu	24(a6),d0		Nombre d'octets par pixel (2 ou 3)
	lsl.l	#6,d0
	move.l	d0,2418(a6)
	tst.w	26(a6)		BEQ.S plus loin...
	movem.l	(sp)+,a0-a1/d1-d2
	rts

l02ff	jmp	([2426.w,a6])
l0300	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#7,d6
	bra.s	l0304

l0301	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$f,d6
	bra.s	l0304

l0302	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$17,d6
	bra.s	l0304

l0303	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$1f,d6
l0304	movea.l	1366(a6),a0
	movea.l	2414(a6),a1
	lea	2430(a6),a4
	move.w	1350(a6),d3
	subq.w	#1,d3
	move.w	2412(a6),d4
	sub.w	d4,2410(a6)
	bpl.s	l0305
	move.w	2410(a6),d4
	add.w	2412(a6),d4
l0305	move.w	d4,2424(a6)
	move.w	28(a6),d7
	subq.w	#1,d7
l0306	move.w	d6,d5
	movea.l	a4,a3
l0307	move.l	(a3)+,d4
	lea	0(a1,d4.l),a2
	move.w	d3,d2
l0308	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbf	d2,l0308
	dbf	d5,l0307
	lea	16(a1),a1
	dbf	d7,l0306
	move.l	2418(a6),d4
	add.l	d4,2414(a6)
	movem.l	(sp)+,a0-a4/d2-d7
	rts

l0309	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#7,d6
	bra.s	l030d

l030a	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$f,d6
	bra.s	l030d

l030b	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$17,d6
	bra.s	l030d

l030c	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$1f,d6
l030d	movea.l	1366(a6),a0
	movea.l	2414(a6),a1
	lea	2430(a6),a4
	move.w	1350(a6),d3
	subq.w	#1,d3
	move.w	2412(a6),d4
	sub.w	d4,2410(a6)
	bpl.s	l030e
	move.w	2410(a6),d4
	add.w	2412(a6),d4
l030e	move.w	d4,2424(a6)
	move.w	28(a6),d7
	subq.w	#1,d7
l030f	move.w	d6,d5
	movea.l	a4,a3
l0310	move.l	(a3)+,d4
	lea	0(a1,d4.l),a2
	move.w	d3,d2
l0311	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbf	d2,l0311
	dbf	d5,l0310
	lea	32(a1),a1
	dbf	d7,l030f
	move.l	2418(a6),d4
	add.l	d4,2414(a6)
	movem.l	(sp)+,a0-a4/d2-d7
	rts

l0312	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#7,d6
	bra.s	l0316

l0313	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$f,d6
	bra.s	l0316

l0314	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$17,d6
	bra.s	l0316

l0315	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$1f,d6
l0316	movea.l	1366(a6),a0
	movea.l	2414(a6),a1
	lea	2430(a6),a4
	move.w	1350(a6),d3
	subq.w	#1,d3
	move.w	2412(a6),d4
	sub.w	d4,2410(a6)
	bpl.s	l0317
	move.w	2410(a6),d4
	add.w	2412(a6),d4
l0317	move.w	d4,2424(a6)
	move.w	28(a6),d7
	subq.w	#1,d7
l0318	move.w	d6,d5
	movea.l	a4,a3
l0319	move.l	(a3)+,d4
	lea	0(a1,d4.l),a2
	move.w	d3,d2
l031a	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbf	d2,l031a
	dbf	d5,l0319
	lea	48(a1),a1
	dbf	d7,l0318
	move.l	2418(a6),d4
	add.l	d4,2414(a6)
	movem.l	(sp)+,a0-a4/d2-d7
	rts

l031b	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#7,d6
	bra.s	l031f

l031c	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$f,d6
	bra.s	l031f

l031d	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$17,d6
	bra.s	l031f

l031e	movem.l	a0-a4/d2-d7,-(sp)
	moveq	#$1f,d6
l031f	movea.l	1366(a6),a0
	movea.l	2414(a6),a1
	lea	2430(a6),a4
	move.w	1350(a6),d3
	subq.w	#1,d3
	move.w	2412(a6),d4
	sub.w	d4,2410(a6)
	bpl.s	l0320
	move.w	2410(a6),d4
	add.w	2412(a6),d4
l0320	move.w	d4,2424(a6)
	move.w	28(a6),d7
	subq.w	#1,d7
l0321	move.w	d6,d5
	movea.l	a4,a3
l0322	move.l	(a3)+,d4
	lea	0(a1,d4.l),a2
	move.w	d3,d2
l0323	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbf	d2,l0323
	dbf	d5,l0322
	lea	64(a1),a1
	dbf	d7,l0321
	move.l	2418(a6),d4
	add.l	d4,2414(a6)
	movem.l	(sp)+,a0-a4/d2-d7
	rts

l0324	movem.l	a0/d1,-(sp)
	lea	1328(a6),a0
	move.w	1354(a6),d0
	clr.w	0(a0,d0.w)
	move.w	d1,0(a0,d0.w)
	move.w	d2,2(a0,d0.w)
	move.w	#$ffff,4(a0,d0.w)
	addq.w	#4,1354(a6)
	mulu	d2,d1
	add.w	d1,1356(a6)
	cmpi.w	#$a,1356(a6)
	bgt.s	l0325
	moveq	#0,d0
	movem.l	(sp)+,a0/d1
	rts

l0325	moveq	#$18,d0
	movem.l	(sp)+,a0/d1
	rts

l0326	movem.l	a0/d6-d7,-(sp)
	moveq	#0,d6
	moveq	#0,d7
	lea	1328(a6),a0
l0327	tst.w	(a0)
	bmi.s	l032a
	move.w	(a0),d0
	cmp.w	d0,d6
	bge.s	l0328
	move.w	d0,d6
l0328	move.w	2(a0),d0
	cmp.w	d0,d7
	bge.s	l0329
	move.w	d0,d7
l0329	addq.w	#4,a0
	bra.s	l0327
l032a	move.w	d6,1350(a6)
	move.w	d7,1352(a6)
	moveq	#0,d0
	movem.l	(sp)+,a0/d6-d7
	rts

jpg_execute_dsp
	move.w	22(a6),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	24(a6),d0		Nombre d'octets par pixel (2 ou 3)
	subq.w	#1,d0
	move.l	jpg_xbios_dsp(pc,d0.w*4),d0
	beq	l032c
	move.l	d0,2406(a6)
	moveq	#0,d0
	rts


jpg_xbios_dsp
	dc.l	jpg_dsp_blkbytes
	dcb.w	8,0
	dc.l	jpg_dsp_blkbytes2
	dcb.w	6,0
	dc.l	jpg_dsp_blkwords2
	dc.l	jpg_dsp_blkbytes3
	dcb.w	8,0
	dc.l	jpg_dsp_blkbytes4


indsp	movem.l	a0-a2/d1-d2,-(sp)
	bsr	jpg_dsp_lock
	bsr	jpg_dsp_getprogability
	subi.w	#$4a44,d0
	beq.s	l032f
	move.w	#$4a44,d0
	move.l	#$2ff,d1
	lea	codsp(pc),a0
	bsr	jpg_dsp_execprog
	bsr.s	l0330
l032f	tst.w	d0
	movem.l	(sp)+,a0-a2/d1-d2
	rts


l0330	movem.l	a0-a1/d0-d2,-(sp)
	lea	l0407,a0
	move.l	#$200,d0
	movea.l	a0,a1
	moveq	#0,d1
	moveq	#$7f,d2
l0331	move.l	d1,(a1)+
	dbf	d2,l0331
	lsr.w	#8,d2
l0332	move.l	d1,(a1)+
	addq.w	#1,d1
	dbf	d2,l0332
	subq.w	#1,d1
	moveq	#$7f,d2
l0333	move.l	d1,(a1)+
	dbf	d2,l0333
	bsr	jpg_dsp_blkunpacked
	movea.l	a0,a1
	move.w	#$1ff,d2
l0334	move.l	(a1),d1
	lsr.w	#3,d1
	ror.w	#5,d1
	move.l	d1,(a1)+
	dbf	d2,l0334
	bsr	jpg_dsp_blkunpacked
	movea.l	a0,a1
	move.w	#$1ff,d2
l0335	move.l	(a1),d1
	lsr.w	#5,d1
	move.l	d1,(a1)+
	dbf	d2,l0335
	bsr	jpg_dsp_blkunpacked
	movea.l	a0,a1
	move.w	#$1ff,d2
l0336	move.l	(a1),d1
	lsr.w	#6,d1
	move.l	d1,(a1)+
	dbf	d2,l0336
	bsr	jpg_dsp_blkunpacked
	movem.l	(sp)+,a0-a1/d0-d2
	rts
l0337	movem.l	a0-a3/d0-d3,-(sp)
	lea	186(a6),a0
	move.l	#1,(a0)
	moveq	#0,d0
	move.w	1348(a6),d0
	lsl.l	#5,d0
	move.l	d0,1028(a0)
	moveq	#0,d0
	move.w	20(a6),d0
	move.l	d0,1032(a0)
	moveq	#3,d3
	lea	1036(a0),a1
	lea	2394(a6),a2
	moveq	#0,d0
	move.w	1350(a6),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	1352(a6),d0
	subq.w	#1,d0
	movea.l	(l0379.l,d0.w*4),a3
l0338	move.w	(a2)+,d2
	bmi.s	l0339
	moveq	#0,d0
	moveq	#0,d1
	move.b	(1371.w,a6,d2.w*4),d0
	move.b	(1372.w,a6,d2.w*4),d1
	mulu	d0,d1
	move.l	d1,(a1)+
	move.b	(1373.w,a6,d2.w*4),d1
	move.l	(l0387.l,d1.w*4),(a1)+
	dbf	d3,l0338
	bra.s	l033a
l0339	not.l	(a1)+
	not.l	(a1)+
	dbf	d3,l0339
l033a	move.w	1350(a6),d0
	mulu	1352(a6),d0
	lsl.l	#5,d0
	move.l	d0,1068(a0)
	move.w	20(a6),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	22(a6),d0
	subq.w	#1,d0
	move.b	(l0378.l,d0.w),d1
	extb.l	d1
	move.l	d1,1072(a0)
	move.w	20(a6),d0
	subq.w	#1,d0
	lsl.w	#2,d0
	add.w	24(a6),d0		Nombre d'octets par pixel (2 ou 3)
	subq.w	#1,d0
	move.b	(l0377.l,d0.w),d1
	extb.l	d1
	move.l	d1,1076(a0)
	not.l	1080(a0)
	not.l	1084(a0)
	not.l	1088(a0)
	not.l	1092(a0)
	lea	1080(a0),a1
	lea	2394(a6),a2
	moveq	#3,d3
l033b	move.w	(a2)+,d2
	bmi.s	l033c
	moveq	#0,d0
	move.b	(1371.w,a6,d2.w*4),d0
	subq.w	#1,d0
	mulu	1352(a6),d0
	add.b	(1372.w,a6,d2.w*4),d0
	subq.w	#1,d0
	move.b	0(a3,d0.w),d0
	extb.l	d0
	move.l	d0,(a1)+
	dbf	d3,l033b
l033c	movem.l	(sp)+,a0-a3/d0-d3
	rts

l033d	movem.l	a0/d0,-(sp)
	lea	186(a6),a0
	move.l	#$448,d0
	lsr.l	#2,d0
	bsr.s	jpg_dsp_blkunpacked
	movem.l	(sp)+,a0/d0
	rts

jpg_dsp_blkunpacked
	movem.l	a0-a2/d0-d2,-(sp)
	clr.l	-(sp)
	clr.l	-(sp)
	move.l	d0,-(sp)
	move.l	a0,-(sp)
	move.w	#$62,-(sp)	Xbios(98): Dsp_BlkUnpacked
	trap	#$e
	lea	18(sp),sp
	movem.l	(sp)+,a0-a2/d0-d2
	rts

jpg_dsp_lock
	movem.l	a0-a2/d1-d2,-(sp)
	move.w	#$68,-(sp)	Xbios(104): Dsp_Lock
	trap	#$e
	addq.w	#2,sp
	andi.w	#$1b,d0
	movem.l	(sp)+,a0-a2/d1-d2
	rts

jpg_dsp_getprogability
	movem.l	a0-a2/d1-d2,-(sp)
	move.w	#$72,-(sp)	Xbios(114): Dsp_GetProgAbility
	trap	#$e
	addq.w	#2,sp
	movem.l	(sp)+,a0-a2/d1-d2
	rts

jpg_dsp_execprog
	movem.l	a0-a2/d1-d2,-(sp)
	move.w	d0,-(sp)
	move.l	d1,-(sp)
	move.l	a0,-(sp)
	move.w	#$6d,-(sp)	Xbios(109): Dsp_ExecProg
	trap	#$e
	lea	12(sp),sp
	movem.l	(sp)+,a0-a2/d1-d2
	rts


l0343
	move.w	54(a6),2410(a6)
	move.w	1352(a6),d0
	lsl.w	#3,d0
	move.w	d0,2412(a6)
	moveq	#0,d0
	tst.w	26(a6)
	rts


;
; Appel au d‚but
;
jpg_r‚serve_m‚moire1
	movem.l	d6-d7/a0,-(sp)
	
	move.l 48(a6),d7
	sub.l buffer_d‚packing,d7
	move.l 2414(a6),d6
	sub.l buffer_d‚packing,d6
	

	movem.l	a1-a2/d1-d2/d6-d7,-(sp)
	add.l	d0,2558(a6)
	jsr r‚serve_bloc_jpg
	tst.l	d0
	bmi.s	jpg_erreur_r‚servation_m‚moire
	moveq	#0,d0
	movem.l	(sp)+,a1-a2/d1-d2/d6-d7

	move.l	buffer_fichier,a0
	sub.l 	a0,a5
	move.l	a5,a0
	move.l	buffer_fichier,a5
	add.l	a0,a5

	add.l	buffer_d‚packing,d7
	add.l	buffer_d‚packing,d6
	move.l  d7,48(a6)
	move.l  d6,2414(a6)
	
	movem.l	(sp)+,d6-d7/a0
	rts

jpg_erreur_r‚servation_m‚moire
	moveq #$19,d0			Code 25
	movem.l	(sp)+,a1-a2/d1-d2
	rts

codsp	dc.l	$00000000,$00000000,$010C0040,$00000000
	dc.l	$00400002,$720003F8,$08F4A800,$000408F4
	dc.l	$BF000C00,$08F4A000,$000108F4,$BE000000
	dc.l	$0002B805,$F420FFFF,$FF05F421,$FFFFFF05
	dc.l	$F422FFFF,$FF05F423,$FFFFFF05,$F424FFFF
	dc.l	$FF05F425,$FFFFFF05,$F426FFFF,$FF05F427
	dc.l	$FFFFFF0A,$A9800000,$5E08442B,$0C005A60
	dc.l	$F4000020,$00060088,$0000640A,$A9800000
	dc.l	$620858EB,$44F40000,$10004470,$0000018E
	dc.l	$44F40000,$12004470,$00000190,$44F40000
	dc.l	$14004470,$00000192,$44F40000,$16004470
	dc.l	$00000194,$0AA98000,$00750AAB,$A0000298
	dc.l	$62F40000,$018064F4,$00001800,$065A0000
	dc.l	$00840AA9,$8000007F,$0864EB0A,$A9800000
	dc.l	$82085CAB,$64F40000,$1800051F,$A061F400
	dc.l	$00018D06,$5A000000,$AB065A00,$0000A863
	dc.l	$E200051F,$A360F400,$000000C0,$83000620
	dc.l	$80000098,$F0FCD050,$6000C083,$D8595800
	dc.l	$61700000,$01956270,$00000196,$64700000
	dc.l	$01970BF0,$800000B3,$0BF08000,$019961F0
	dc.l	$00000195,$62F00000,$019664F0,$00000197
	dc.l	$20590020,$5900205A,$000BF080,$00014905
	dc.l	$F425FFFF,$FF0BF080,$0002370C,$006560F4
	dc.l	$00000000,$38040064,$F4000000,$013C0400
	dc.l	$61F40000,$00023904,$0065F400,$0000033D
	dc.l	$040062F4,$00000020,$3E040063,$F4000000
	dc.l	$C00504A3,$67F40000,$00C80504,$a7060280
	dc.l	$00014706,$04800001,$3DF0E000,$F5E1D020
	dc.l	$00F35660,$C0F0E4E7,$5661D0F5,$E5002000
	dc.l	$F35664C0,$C09BE756,$65D0C5BF,$002000F3
	dc.l	$8E80E04E,$E0C78EA4,$014CE418,$09201656
	dc.l	$645147E1,$188F8516,$5E64714C,$E5185761
	dc.l	$16CB2541,$4EE0185F,$651682BF,$00C5BBD0
	dc.l	$2000F35E,$60E0C09B,$C75E65D0,$C5BF0020
	dc.l	$00F35E64,$E02256C7,$5E61004A,$C8002000
	dc.l	$18574E16,$21C4004A,$C9002000,$18574E16
	dc.l	$19A5005F,$E4002000,$18574E16,$188C005F
	dc.l	$CD002000,$18574E16,$564E0046,$4E00474E
	dc.l	$00444E00,$F0E000F5,$E1D02000,$F35660C0
	dc.l	$F0E4E756,$61D0F5E5,$002000F3,$5664C0C0
	dc.l	$9BE75665,$D0C5BF00,$2000F38E,$80E04EE0
	dc.l	$C78EA401,$4CE41809,$20165664,$5147E118
	dc.l	$8F85165E,$64714CE5,$18576116,$CB25414E
	dc.l	$E0185F65,$1682BF00,$C5BBD020,$00F35E60
	dc.l	$E0C09BC7,$5E65D0C5,$BF002000,$F35E64E0
	dc.l	$2256C75E,$61004AC8,$00200018,$5F4E1621
	dc.l	$C4004AC9,$00200018,$5F4E1619,$A5005FE4
	dc.l	$00200018,$5F4E1618,$8C005FCD,$00205A18
	dc.l	$5F4E165E,$4E004E4E,$004F4E00,$4C4E0060
	dc.l	$F4000000,$2064F400,$00002161,$F4000000
	dc.l	$2265F400,$00002362,$F4000000,$0000000C
	dc.l	$60F40000,$00D070F0,$0000018B,$00000060
	dc.l	$E8000000,$000AE080,$45F00000,$018A60F4
	dc.l	$00001000,$05F420FF,$FFFF64F4,$00001800
	dc.l	$47F40000,$020006C5,$00000160,$44E0004E
	dc.l	$D8C15E64,$B1565C00,$00000C45,$F0000001
	dc.l	$8A60F400,$00100064,$F4000018,$0061F400
	dc.l	$00180006,$C5000001,$715EE000,$BA190056
	dc.l	$590056D8,$00BA1900,$5E5C0000,$000C0C01
	dc.l	$5145F000,$00018A60,$F4000010,$0005F420
	dc.l	$FFFFFF61,$F4000012,$0062F400,$00140064
	dc.l	$F4000018,$0065F400,$00010005,$04A50008
	dc.l	$F806C500,$000196C0,$9D002000,$D8C0DD01
	dc.l	$C0BDD356,$6401C0DD,$D6C0BDD7,$5E5CDBF0
	dc.l	$B8005764,$D0F0A209,$F0A1DB5F,$5C09F0BA
	dc.l	$DEF0B9DF,$5764D35E,$5C0000F3,$B800000C
	dc.l	$60F40000,$000061F0,$00000195,$65F40000
	dc.l	$00D475D9,$0064E100,$65ED0060,$F4000000
	dc.l	$000BE580,$64510061,$70000001,$9500000C
	dc.l	$22950056,$D800061F,$A0BA9800,$5E5C005E
	dc.l	$D800061F,$A0FA1D00,$565D0000,$000C0000
	dc.l	$0C00000C,$00000C00,$000C0000,$0C00000C
	dc.l	$2292003A,$04002295,$003C0500,$3D050006
	dc.l	$08800001,$C356D800,$0603A0BA,$98005E4C
	dc.l	$00060880,$0001C95E,$D8000603,$A0FA1D00
	dc.l	$564D0004,$4A140000,$0C229200,$06208000
	dc.l	$01D14AD8,$00BA1A00,$BF1A0000,$000C2292
	dc.l	$003A0400,$2295003C,$0D003D0D,$00060880
	dc.l	$0001DD56,$D8000603,$A0BA9800,$5E4C0006
	dc.l	$08800001,$E35ED800,$0603A0FA,$1D00564D
	dc.l	$00044A14,$00000C00,$000C0000,$0C381000
	dc.l	$22950022,$92003C10,$003D1000,$3A100004
	dc.l	$48160604,$80000209,$4AD800BA,$1A00BF1A
	dc.l	$004AD800,$BA1A00BF,$1A004AD8,$00BA1A00
	dc.l	$BF1A004A,$D800BA1A,$00BF1A00,$4ADE00BA
	dc.l	$1A00BF1A,$004ADE00,$BA1A00BF,$1A004ADE
	dc.l	$00BA1A00,$BF1A004A,$DE00BA1A,$00BF1A00
	dc.l	$D08A0006,$04800002,$1822B000,$044D1456
	dc.l	$D800060F,$A0BA9800,$5E5C0022,$B000044D
	dc.l	$14F28D00,$060FA0FA,$1C00565C,$00204D00
	dc.l	$00000C00,$000C0000,$0C00000C,$00000C00
	dc.l	$000C0000,$0C00000C,$00000C00,$000C0000
	dc.l	$0C00000C,$00000C00,$000C0000,$0C00000C
	dc.l	$00000C00,$000C0000,$0C00000C,$00000C00
	dc.l	$000C0000,$0C00000C,$00000C00,$000C0000
	dc.l	$0C00000C,$00000C00,$000C60F4,$00000110
	dc.l	$70F00000,$018C0000,$0060E800,$0000000A
	dc.l	$E08060F4,$00001800,$05F420FF,$FFFF64F4
	dc.l	$00002100,$45F00000,$018A06C5,$00000250
	dc.l	$74E0000A,$A9810002,$4A08ECEB,$7CD8000A
	dc.l	$A9810002,$4E08ECEB,$00000C60,$F4000018
	dc.l	$0005F420,$FFFFFF64,$F4000023,$0065F400
	dc.l	$00250066,$F4000027,$0045F000,$00018A06
	dc.l	$C5000002,$7374E000,$7DD80076,$E0004CEC
	dc.l	$134CED42,$4CEE4220,$00420AA9,$81000267
	dc.l	$08CE2B7C,$D80075E0,$007ED800,$4CEC134C
	dc.l	$ED424CEE,$42200042,$0AA98100,$027108CE
	dc.l	$2B00000C,$60F40000,$180005F4,$20FFFFFF
	dc.l	$64F40000,$210045F0,$0000018A,$06C50000
	dc.l	$029674E0,$000AA981,$00028008,$ECEB7CD8
	dc.l	$000AA981,$00028408,$ECEB74E0,$000AA981
	dc.l	$00028808,$ECEB7CD8,$000AA981,$00028C08
	dc.l	$ECEB74E0,$000AA981,$00029008,$ECEB7CD8
	dc.l	$000AA981,$00029408,$ECEB0000,$0C60F400
	dc.l	$00004006,$80800002,$A10AA980,$00029C08
	dc.l	$60AB0AA9,$8000029F,$0858EB60,$F4000001
	dc.l	$80060D80,$0002A80A,$A9800002,$A60858AB
	dc.l	$60F40000,$018D0604,$800002B0,$0AA98000
	dc.l	$02AD0858,$AB205800,$0C006500,$00010000
	dc.l	$C0000005,$00000000,$00005A82,$7A0C7C5C
	dc.l	$238E7600,$00010000,$C8000005,$00000000
	dc.l	$00005A82,$7A3EC530,$3536CC00,$00020000
	dc.l	$C0000005,$3B20D818,$7DE30000,$00000000
	dc.l	$00000000,$00020000,$C8000005,$2D413D2D
	dc.l	$413D0000,$00000000,$00000000,$00010000
	dc.l	$D0000004,$00015100,$01620001,$73000174
	dc.l	$00000100,$00D40000,$2B0001A9,$0001B300
	dc.l	$01B40001,$B50001B6,$0001B700,$01B70001
	dc.l	$B80001B9,$0001CC00,$01D30001,$E60001E7
	dc.l	$0001E800,$021A0002,$1B00021C,$00021D00
	dc.l	$021E0002,$1F000220,$00022100,$02220002
	dc.l	$23000224,$00022500,$02260002,$27000228
	dc.l	$00022900,$022A0002,$2B00022C,$00022D00
	dc.l	$022E0002,$2F000230,$00023100,$02320002
	dc.l	$33000234,$00023500,$02360000,$01000100
	dc.l	$00000500,$02000002,$CE0000B0,$00016E00
	dc.l	$038B0000,$02000100,$00000500,$02000002
	dc.l	$CE0000B0,$00016E00,$038B0000,$01000110
	dc.l	$00000300,$023F0002,$52000275,$00000100
	dc.l	$01800000,$18000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$00000000,$00000000,$00000000,$00000000
	dc.l	$10000000,$00001200,$00000000,$14000000
	dc.l	$00001600,$00000000,$00000000,$00000000

l036e	dcb.w	2,0
l036f	dc.b	$00,$00,$00,$02,$00,$00,$00,$10
	dc.b	$00,$00,$00,$20,$00,$00,$00,$12
	dc.b	$00,$00,$00,$04,$00,$00,$00,$06
	dc.b	$00,$00,$00,$14,$00,$00,$00,$22
	dc.b	$00,$00,$00,$30,$00,$00,$00,$40
	dc.b	$00,$00,$00,$32,$00,$00,$00,$24
	dc.b	$00,$00,$00,$16,$00,$00,$00,$08
	dc.b	$00,$00,$00,$0a,$00,$00,$00,$18
	dc.b	$00,$00,$00,$26,$00,$00,$00,$34
	dc.b	$00,$00,$00,$42,$00,$00,$00,$50
	dc.b	$00,$00,$00,$60,$00,$00,$00,$52
	dc.b	$00,$00,$00,$44,$00,$00,$00,$36
	dc.b	$00,$00,$00,$28,$00,$00,$00,$1a
	dc.b	$00,$00,$00,$0c,$00,$00,$00,$0e
	dc.b	$00,$00,$00,$1c,$00,$00,$00,$2a
	dc.b	$00,$00,$00,$38,$00,$00,$00,$46
	dc.b	$00,$00,$00,$54,$00,$00,$00,$62
	dc.b	$00,$00,$00,$70,$00,$00,$00,$72
	dc.b	$00,$00,$00,$64,$00,$00,$00,$56
	dc.b	$00,$00,$00,$48,$00,$00,$00,$3a
	dc.b	$00,$00,$00,$2c,$00,$00,$00,$1e
	dc.b	$00,$00,$00,$2e,$00,$00,$00,$3c
	dc.b	$00,$00,$00,$4a,$00,$00,$00,$58
	dc.b	$00,$00,$00,$66,$00,$00,$00,$74
	dc.b	$00,$00,$00,$76,$00,$00,$00,$68
	dc.b	$00,$00,$00,$5a,$00,$00,$00,$4c
	dc.b	$00,$00,$00,$3e,$00,$00,$00,$4e
	dc.b	$00,$00,$00,$5c,$00,$00,$00,$6a
	dc.b	$00,$00,$00,$78,$00,$00,$00,$7a
	dc.b	$00,$00,$00,$6c,$00,$00,$00,$5e
	dc.b	$00,$00,$00,$6e,$00,$00,$00,$7c
	dc.b	$00,$00,$00,$7e,$00,$00,$ff,$ff
	dc.b	$00,$00,$ff,$fd,$00,$00,$ff,$f9
	dc.b	$00,$00,$ff,$f1,$00,$00,$ff,$e1
	dc.b	$00,$00,$ff,$c1,$00,$00,$ff,$81
	dc.b	$00,$00,$ff,$01,$00,$00,$fe,$01
	dc.b	$00,$00,$fc,$01,$00,$00,$f8,$01
l0370	dcb.w	255,0
	dc.b	$00,$01
l0371	dc.l	l0300
	dc.l	l0301
	dc.l	l0302
	dc.l	l0303
	dc.l	l0309
	dc.l	l030a
	dc.l	l030b
	dc.l	l030c
	dc.l	l0312
	dc.l	l0313
	dc.l	l0314
	dc.l	l0315
	dc.l	l031b
	dc.l	l031c
	dc.l	l031d
l0372	dc.l	l031e
	dc.l	l0373
	dc.l	l0374
	dc.l	l0375
	dc.l	l0376
l0373	dc.b	$00,$00,$00,$01,$00,$02,$00,$03
	dc.b	$00,$04,$00,$05,$00,$06,$00,$07
l0374	dc.b	$00,$00,$00,$08,$00,$01,$00,$09
	dc.b	$00,$02,$00,$0a,$00,$03,$00,$0b
	dc.b	$00,$04,$00,$0c,$00,$05,$00,$0d
	dc.b	$00,$06,$00,$0e,$00,$07,$00,$0f
l0375	dc.b	$00,$00,$00,$08,$00,$10,$00,$01
	dc.b	$00,$09,$00,$11,$00,$02,$00,$0a
	dc.b	$00,$12,$00,$03,$00,$0b,$00,$13
	dc.b	$00,$04,$00,$0c,$00,$14,$00,$05
	dc.b	$00,$0d,$00,$15,$00,$06,$00,$0e
	dc.b	$00,$16,$00,$07,$00,$0f,$00,$17
l0376	dc.b	$00,$00,$00,$08,$00,$10,$00,$18
	dc.b	$00,$01,$00,$09,$00,$11,$00,$19
	dc.b	$00,$02,$00,$0a,$00,$12,$00,$1a
	dc.b	$00,$03,$00,$0b,$00,$13,$00,$1b
	dc.b	$00,$04,$00,$0c,$00,$14,$00,$1c
	dc.b	$00,$05,$00,$0d,$00,$15,$00,$1d
	dc.b	$00,$06,$00,$0e,$00,$16,$00,$1e
	dc.b	$00,$07,$00,$0f,$00,$17,$00,$1f
l0377	dc.b	$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	dc.b	$00,$01,$02,$ff,$ff,$ff,$ff,$ff
l0378	dc.b	$00,$ff,$01,$ff,$ff,$ff,$ff,$ff
	dc.b	$02,$ff,$03,$ff,$ff,$ff,$ff,$ff
l0379	dc.l	l037a
	dc.l	l037b
	dc.l	l037c
	dc.l	l037d
	dc.l	l037e
	dc.l	l037f
	dc.l	l0380
	dc.l	l0381
	dc.l	l0382
	dc.l	l0383
	dc.l	l0384
	dcb.w	2,0
	dc.l	l0385
	dc.l	l0386
	dcb.w	4,0
l037a	dc.b	$00
l037b	dc.b	$02,$01
l037c	dc.b	$04,$ff,$03
l037d	dc.b	$07,$ff,$06,$05
l037e	dc.b	$09,$08
l037f	dc.b	$0d,$0c,$0b,$0a
l0380	dc.b	$11,$ff,$10,$0f,$ff,$0e
l0381	dc.b	$17,$ff,$16,$15,$14,$ff,$13,$12
l0382	dc.b	$19,$ff,$18
l0383	dc.b	$1d,$1c,$ff,$ff,$1b,$1a
l0384	dc.b	$21,$ff,$20,$ff,$ff,$ff,$1f,$ff,$1e
l0385	dc.b	$24,$ff,$23,$22
l0386	dc.b	$2a,$29,$ff,$ff,$28,$27,$26,$25
l0387	dc.b	$00,$00,$00,$40,$00,$00,$00,$60
	dc.b	$00,$00,$00,$80,$00,$00,$00,$a0
l0389	dc.b	$00,$00,$02,$00,$00,$00,$00,$00
	dcb.w	4,0
	dc.b	$00,$20

	BSS
	
buffer_jpeg	ds.b 2612
l0407		ds.b	2048
