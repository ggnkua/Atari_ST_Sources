;	opt	o+,Ow2-,p+
;	output	replay.prg
;touches=$430
;
; NOISE avec ou sans calcul
; HARD  avec ou sans calcul
;
; INF_SOUND :
;	bits
;	 0->1=init volume,0=play volume
;	 1->1=init fr‚quence,0=play freq
;	 2->0=ne pas jouer de son
;
	bra.w	init_music
	bra.w	replay_music
flgmus:	dc.b	0		;0=musique,<>0=pas de musique
flgeff:	dc.b	0		;0=effets sonores,<>0=pas d'effets
msndf:	dc.b	0		;0=init son,<>0=pas init
sndeff:	dc.b	0		;0=pas de bruit,<>0=num‚ro bruitage

psgreg:
psgreg0	dc.l	$00000000
psgreg1	dc.l	$01010000
psgreg2	dc.l	$02020000
psgreg3	dc.l	$03030000
psgreg4	dc.l	$04040000
psgreg5	dc.l	$05050000
psgreg6	dc.l	$06060000
psgreg7	dc.l	$0707ffff
psgreg8	dc.l	$08080000
psgreg9	dc.l	$09090000
psgrega	dc.l	$0a0a0000
psgregb	dc.l	$0b0b0000
psgregc	dc.l	$0c0c0000
psgregd	dc.l	$0d0d0000

mod_addr:	dc.l	0	;addr. init. module

speed: 		dc.b	3
cpt_patt: 	dc.b	0
positions: 	dc.b	0
flagd:		dc.b	0
etat:		dc.b	0
blocage:	dc.b	-1
	even
tb_sound:
;	ds.l 33*2
	ds.l	(12+3)*2
fin_tbsound:

tb_add_patt:			;128 patterns
;	ds.l 64
	ds.l	30+22+5+63
fin_patt:

;===========================================
;==	SOUNDTRACKS  REPLAY  ROUTINE	  ==
;==					  ==
;==     by PE LORIAUX          ©1990      ==
;==					  ==
;==   time: less than 15 raster lines     ==
;===========================================

	rsreset
sample		rs.l	1	; dc.l 0
frequence	rs.w	1 	; dc.w 0
volume		rs.w	1 	; dc.w 0
patt		rs.l	1	; dc.l 0
timing		rs.w	1	; dc.w 0
effet1		rs.b	1 	; dc.b 0
		rs.b	1
c_instr		rs.b	1 	; dc.b 0
c_note		rs.b	1 	; dc.b 0
sound		rs.l	2	; dc.l 0,0

inf_sound	rs.b	2	; dc.b 0,0
pt_vol		rs.b	1	; dc.b 0
pt_freq		rs.b	1	; dc.b 0

cpt_vol		rs.b	1 	; dc.b 0
cumul_vol	rs.b	1 	; dc.b 0
vari_vol	rs.b	1 	; dc.b 0
cpt_freq	rs.b	1 	; dc.b 0
off_vol		rs.w	1	; dc.w 0
cumul_freq	rs.w	1  	; dc.w 0	;ok
off_freq	rs.w	1	; dc.w 0	;ok
vari_freq	rs.l	1 	; dc.l 0
bender		rs.w	1
freque		rs.w	1 	; dc.b 0

st0		rs.l	1	;dc.l 0
cptins		rs.b	1
typesnd		rs.b	1
flagenv		rs.b	1
cur_vol		rs.b	1
decalage	rs.b	1
calcul		rs.b	1
vol		rs.b	1
longvoice	equ	(__RS+1)&-2

voice0:		ds.b longvoice
voice1:		ds.b longvoice
voice2:		ds.b longvoice
voice4:		ds.b longvoice
end_voices:

;************************

init_music:
	lea	sm(pc),a2
	st	blocage-sm(a2)

	lea	voice0(pc),a4
	moveq	#(end_voices-voice0)/2-1,d0
.clrall
	clr	(a4)+
	dbra	d0,.clrall

	clr.b	flagd-sm(a2)
	clr.b	psgregd+2-sm(a2)

	move.l	a0,a4

	lea voice0(pc),a0
	move.b #%11,inf_sound(a0)
	move.b #1,timing(a0)
	lea voice1(pc),a0
	move.b #%11,inf_sound(a0)
	move.b #1,timing(a0)
	lea voice2(pc),a0
	move.b #%11,inf_sound(a0)
	move.b #1,timing(a0)

	move.l	a4,mod_addr-sm(a2)
	move.w	12(a4),d0
	addq.w	#1,d0
	move.w	d0,nbpatt+2-sm(a2)	;nb de positions

	st	positions-sm(a2)		;music commence position 0
	move.b	#1,speed-sm(a2)
	move.b	#32,cpt_patt-sm(a2)
;----------
	move.w	14(a4),d0	;nb de patterns
	lea	80(a4),a0
	move.w	12(a4),d1
	addq.w	#1,d1
	mulu 	#14,d1
	subq	#4,d1
	add.w	d1,a0		;pointe patterns

	lea	tb_add_patt(pc),a1		;pat addr.
	move.l	#"patt",d2	;entete
bcspat:
	cmp.l	(a0)+,d2
	bne.s	bcspat
	move.l	a0,(a1)+
	dbra	d0,bcspat

	lea	fin_patt(pc),a3
	cmp.l	a3,a1
	bhi.s	bug
;------------

	lea	tb_sound+8(pc),a1
	move.l	#"inst",d2	;entete volu
	move.l	#"insf",d1	;entete freq

	move.w	16(a4),d0	;nb de sound
	subq.w	#1,d0
bcsds:
	cmp.l	(a0)+,d2
	bne.s	bcsds
	move.l	a0,(a1)+
schvol:
	cmp.l	(a0)+,d1
	bne.s	schvol
	move.l	a0,(a1)+
	dbra	d0,bcsds

	lea	fin_tbsound(pc),a0
	cmp.l	a0,a1
	bhi.s	bug

	lea	voice4(pc),a6		;init bruitages
	move.b	#64,effet1(a6)
	clr	bender(a6)

	clr.b	blocage-sm(a2)
ftbs:
	rts
bug:	dc.l	$4a780001

;**********************************
;**********************************

replay_music:
	ifeq	1
;
; motor off
;
	tst.b	floplock.w
	bne.s	.nostop
	move	$ffff8604.w,d0
	tst.b	d0
	bmi.s	.nostop
	move.l	#$0e0e0707,$ffff8800.w
	st	floplock.w
.nostop:

	lea	sm(pc),a2
	tst.b	touches+$43.w
	beq.s	.notf9
	clr.b	touches+$43.w
	not.b	flgeff-sm(a2)
.notf9
	tst.b	touches+$44.w
	beq.s	.notf10
	clr.b	touches+$44.w
	not.b	flgmus-sm(a2)
.notf10
	endc

	move.b	blocage(pc),d0
	bne.s	ftbs
	movem.l	psgreg(pc),d0-d7/a0/a1/a3/a4/a5
	movem.l	d0-d7/a0/a1/a3/a4/a5,$ffff8800.w
	move.l	psgregd(pc),d0
	bclr	#7,flagd-sm(a2)
	beq.s	.no
	move.l	d0,$ffff8800.w
.no

	cmp.b	#32,cpt_patt-sm(a2)
	bne	temps

	addq.b	#1,positions-sm(a2)	;pattern suivant

nbpatt:	cmp.b	#4,positions-sm(a2)	;nb de positions
	bne.S	init_pattern
	SF	positions-sm(a2)	;reboot music

;=================================
;==   initialisation patterns	==
;=================================
init_pattern:
	sf	cpt_patt-sm(a2)
	moveq	#0,d0
	move.b	positions(pc),d0
	add.w	d0,d0
	move.w	d0,d1		;*14
	lsl.w	#3,d0
	sub.w	d1,d0

	move.l	mod_addr(pc),a5
	lea	80(a5),a5	;pointe pos

	add.w	d0,a5
	lea	tb_add_patt(pc),a4	;tb add patt works

	lea	voice0(pc),a6	;init patt voie 0
	moveq	#0,d1
	move.b	(a5)+,d1	;n° pattern
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a4,d1.w),patt(a6)	;add premiere ligne
;	subq.l	#4,patt(a6)
	move.b	(a5)+,c_instr(a6)	;correction instrument
	move.b	(a5)+,c_note(a6)		;correction note
	move.b	#1,timing(a6)

	lea	voice1(pc),a6			;voie 1
	moveq	#0,d1
	move.b	(a5)+,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a4,d1.w),patt(a6)
;	subq.l	#4,patt(a6)
	move.b	(a5)+,c_instr(a6)
	move.b 	(a5)+,c_note(a6)
	move.b 	#1,timing(a6)

	lea	voice2(pc),a6		;voie 2
	moveq	#0,d1
	move.b	(a5)+,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	0(a4,d1.w),patt(a6)
;	subq.l	#4,patt(a6)
	move.b	(a5)+,c_instr(a6)
	move.b	(a5)+,c_note(a6)
	move.b	#1,timing(a6)

	addq	#3,a5

	move.b	(a5),d1		;a5=a5+12
	beq.s	pascv
	move.b	d1,tempo+3-sm(a2)		;vitesse
pascv:

;-----------------

temps:
	lea	tb_notes-24(pc),a1	;pointe table notes
	subq.b	#1,speed-sm(a2)		;tempo voie0
	bne.s	speed1

	addq.b #1,cpt_patt-sm(a2);cpt longueur de pattern
tempo:	move.b #2,speed-sm(a2)	;1 pas fini

	lea	voice0(pc),a6
	subq.b	#1,timing(a6)
	bne.s	fpv1
;	moveq	#1,d1
	JSR	(A2)
	addq.l	#4,patt(a6)	;ligne suivante

fpv1:	lea	voice1(pc),a6
	subq.b	#1,timing(a6)
	bne.s	fpv2
;	moveq	#2,d1
	JSR	(A2)
	addq.l	#4,patt(a6)

fpv2:	lea	voice2(pc),a6
	subq.b	#1,timing(a6)
	bne.s	fpv3
;	moveq	#4,d1
	JSR	(A2)
	addq.l	#4,patt(a6)

fpv3:

speed1:
;	move.w #$8000,d5
	clr	d5

	lea	voice0(pc),a6
	move.b	inf_sound(a6),d7
	btst	#2,d7
	beq.S	pfx1
	addq.b	#1,d5
	bsr	play_sound
	move.b	d7,inf_sound(a6)

pfx1:	lea	voice1(pc),a6
	move.b	inf_sound(a6),d7
	btst	#2,d7
	beq.S	pfx2
	addq.b	#2,d5
	bsr	play_sound
	move.b	d7,inf_sound(a6)

pfx2:	lea	voice2(pc),a6
	move.b	inf_sound(a6),d7
	btst	#2,d7
	beq.S	pfx3
	addq.b	#4,d5
	bsr	play_sound
	move.b	d7,inf_sound(a6)

pfx3:
	tst.b	flgeff-sm(a2)
	bne.s	.neff0
	clr	d0
	move.b	sndeff-sm(a2),d0
	beq.s	.neff1

;	move	#$700,$ffff8240.w
	lea	voice4(pc),a6

	tst.b	msndf-sm(a2)
	bne.s	.npfx5
	st	msndf-sm(a2)

;--------			;init effet
	add	d0,d0
	move	d0,d1
	add	d0,d0
	add	d1,d0		;*6
	lea	tbeff(pc),a0
	add	d0,a0		;add para snd
	move	(a0)+,d0		;off note
	move.b	d0,freque(a6)
	lea	tbeff(pc),a1
	add	(a0)+,a1
	move.l	a1,sound(a6)
	lea	tbeff(pc),a1
	add	(a0)+,a1
	move.l	a1,sound+4(a6)
	move.l	#$07000000,inf_sound(a6)	;pour debut de table

.npfx5:
	move.b	inf_sound(a6),d7
	btst	#2,d7
	bne.S	.pfx5
	clr.b	sndeff-sm(a2)
	bra.s	.neff1

.pfx5:	lea	tb_notes(pc),a1
	bsr	play_sound
	move.b	d7,inf_sound(a6)
	or	#$0004,d5
	bra.s	.neff1
.neff0:
	clr.b	sndeff-sm(a2)
.neff1
;
; d5=‚tat des voix
;
	move.b	d5,etat-sm(a2)

	tst.b	flgmus-sm(a2)
	bne.s	.nomus

	moveq.l	#$c0,d6
	moveq	#0,d7		;voix 1
	lea	voice0(pc),a6
	bsr.s	playdma
;	clr.b	psgreg8+2

	moveq	#1,d7		;voix 2
	lea	voice1(pc),a6
	bsr.s	playdma
;	clr.b	psgreg9+2

	lea	voice2(pc),a6
	tst.b	flgeff-sm(a2)
	bne.s	.noeff
	tst.b	sndeff-sm(a2)
	beq.s	.noeff
	lea	voice4(pc),a6
.noeff
	moveq	#2,d7		;voix 3
	bsr.s	playdma
;	clr.b	psgrega+2
	bra.s	.okmus

.nomus:
	clr.b	psgreg8+2-sm(a2)	;oblig‚ !!!!
	clr.b	psgreg9+2-sm(a2)
	clr.b	psgrega+2-sm(a2)

	moveq.l	#$ff,d6

	tst.b	flgeff-sm(a2)
	bne.s	.okmus
	tst.b	sndeff-sm(a2)
	beq.s	.okmus
	lea	voice4(pc),a6
	moveq.l	#$c0+%11011,d6
	moveq	#2,d7		;voix 3
	bsr.s	playdma

.okmus
	move.b	d6,psgreg7+2-sm(a2)
	rts
playdma:
;	btst	#2,inf_sound(a6)
	btst	d7,etat-sm(a2)
	beq	novoice

	tst.b	cptins(a6)
	beq.s	.refresh
	subq.b	#1,cptins(a6)	;d‚compteur
	bra	norefresh
.refresh:
	clr.b	flagenv(a6)
	clr.b	calcul(a6)

	move.l	st0(a6),a0
.bcl
	clr	d0
	move.b	(a0),d0
	add	d0,d0
	add	d0,d0
	jmp	.codes(pc,d0.w)
.codes
	bra.w	.fini		;$00=fin
	bra.w	.length		;$01=longueur du son
	bra.w	.loop		;$02=bouclage
	bra.w	.sound		;$03=son
	bra.w	.noise		;$04=bruit
	bra.w	.sndnois	;$05=son et bruit ensemble
	bra.w	.nothing	;$06=ni son ni bruit
	bra.w	.hard		;$07=enveloppe hard
	bra.w	.noisec		;$08=bruit calcul‚
	bra.w	.sndnoisc	;$09=son et bruit calcul‚s
	bra.w	.hardc		;$0a=enveloppe hard calcul‚e
	bra.w	.volume		;$0b=volume de la voix
.hardc
	addq	#1,a0
	move.b	(a0)+,d0
	move.b	(a0)+,decalage(a6)
;	or.b	#$80,calcul(a6)
	tas	calcul(a6)
	move.b	#$10,flagenv(a6)	;enveloppe hard

	cmp.b	psgregd+2-sm(a2),d0
	beq.s	.goodd
	move.b	d0,psgregd+2-sm(a2)
	st	flagd-sm(a2)
.goodd
	bra.s	.bcl
.hard
	addq	#1,a0
	move.b	(a0)+,d0
	move.b	(a0)+,psgregb+2-sm(a2)
	clr.b	psgregc+2-sm(a2)
	move.b	#$10,flagenv(a6)	;enveloppe hard

	cmp.b	psgregd+2-sm(a2),d0
	beq.s	.goodd2
	move.b	d0,psgregd+2-sm(a2)
	st	flagd-sm(a2)
.goodd2
	bra.s	.bcl

.volume	addq	#1,a0
	move.b	(a0)+,vol(a6)
	bra	.bcl
.sound	move.b	#type0,typesnd(a6)
	addq	#1,a0
	bra	.bcl
.noise	move.b	#type1,typesnd(a6)
	addq	#1,a0
	move.b	(a0)+,psgreg6+2-sm(a2)
	bra	.bcl
.noisec	move.b	#type1,typesnd(a6)
	addq	#1,a0
	move.b	(a0)+,decalage(a6)
	bset	#6,calcul(a6)
	bra	.bcl
.sndnois
	move.b	#type2,typesnd(a6)
	addq	#1,a0
	move.b	(a0)+,psgreg6+2-sm(a2)
	bra	.bcl
.sndnoisc
	move.b	#type2,typesnd(a6)
	addq	#1,a0
	move.b	(a0)+,decalage(a6)
	bset	#6,calcul(a6)
	bra	.bcl
.nothing
	addq	#1,a0
	move.b	#type3,typesnd(a6)
	bra	.bcl
.loop
	addq	#1,a0
	clr	d0
	move.b	(a0),d0		;bouclage
	move.l	sample(a6),a0
	add	d0,a0
	bra	.bcl
.length
	addq	#1,a0
	move.b	(a0)+,cptins(a6)	;longueur
.fini	move.l	a0,st0(a6)	;fin du bruit (bouclage de 0)
;
; jouer le son
;
norefresh:
	tst.b	calcul(a6)
	bpl.s	.nohardc
	clr	d0
	move.b	freque(a6),d0
	add.b	decalage(a6),d0
	lea	filter-24(pc),a3
	move	(a3,d0.w),d0

;	move	frequence(a6),d0
;	addq	#6,d0
;	lsr	#6,d0
	move.b	d0,psgregb+2-sm(a2)
;	lsr	#8,d0
;	move.b	d0,psgregc+2-sm(a2)
	move.w	d0,psgregc+2-sm(a2)
.nohardc

	btst	#6,calcul(a6)
	beq.s	.nosndc
	move	frequence(a6),d0
	add	#1<<6-1,d0
	lsr	#7,d0
	not.b	d0
;	addq	#4,d0
;	sub.b	#$10,d0
	sub.b	decalage(a6),d0
	and	#$1f,d0
	move.b	d0,psgreg6+2-sm(a2)
.nosndc

	asl	#3,d7

	lea	psgreg0(pc),a0

	move.b	frequence+1(a6),2(a0,d7.w)
	move.b	frequence(a6),2+4(a0,d7.w)
	lsr	#1,d7
	clr	d0
	move.b	cur_vol(a6),d0
;	sub	general_volume(pc),d0
;	bpl.s	.posit
;	clr	d0
;.posit

	move.b	conv(pc,d0.w),d0
	beq.s	.env
	or.b	flagenv(a6),d0		;$10=enveloppe hard
	cmp.b	#$10,d0
	bhs.s	.env
	sub.b	vol(a6),d0
	bpl.s	.env
	clr	d0
.env
	lea	psgreg8(pc),a0
	move.b	d0,2(a0,d7.w)

	lsr	#2,d7
	clr	d0
	move.b	typesnd(a6),d0
	jmp	hardos(pc,d0.w)
novoice:
	lea	psgreg8(pc),a0
	add	d7,d7
	add	d7,d7
	clr.b	2(a0,d7.w)
	lsr	#2,d7
hardos:
type3=0
	bset	d7,d6
type0=2
	addq	#3,d7
type1=4
	bset	d7,d6
type2=6
	rts
conv:
	dc.b	0,2,4,5,6,6,7,7,8,8,9,9,9,9,10,10,10,10
	dc.b	11,11,11,11,11,11,12,12,12,12,12,12,12,13,13,13,13,13
	dc.b	13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,15
	dc.b	15,15,15,15,15,15,15,15,15,15,15
	even
;=================================
;==   initialisation  notes	==
;=================================

sm:
init_note:
	clr.w	d0
	move.l	patt(a6),a0		;add de ligne dans pattern actuel
	move.b	(a0)+,d0		;lire note
	beq.s	effets			;effet ?

	add.b	c_note(a6),d0

	move.b	d0,freque(a6)
	move.b	(a0),d0			;lire instrument
	add.b	c_instr(a6),d0
	lsl.b	#3,d0			;*8
	lea	tb_sound(PC),a5
	ADD.W	D0,A5
	move.l (a5)+,sound(a6)
	move.l (A5),sound+4(a6)
	move.l #$07000000,inf_sound(a6)	;pour debut de table

effets:
	move.b 2(a0),timing(a6)	;---- new duree

	MOVEQ	#-32,D0
	AND.b (a0)+,d0		;n° effet
	bne.s eff_gliss1
	move.b #64,effet1(a6)	;par default
	clr.w bender(a6)
	rts
eff_gliss1:
	cmp.b #$60,d0
	bne.s eff_gliss2
	moveq #0,d0
	move.b (a0),d0
	neg.w d0
	move.w d0,bender(a6)
	move.b #64,effet1(a6)
	rts
eff_gliss2:
	cmp.b #$40,d0
	bne.s eff_vol
	clr d0
	move.b (a0),d0
	move.w d0,bender(a6)
	move.b #64,effet1(a6)
	rts
eff_vol:
	move.b (a0),effet1(a6)
	clr.w bender(a6)
	rts


;***********************************************
;***	           			     ***
;***	      P L A Y     S O U N D	     ***
;***            			     ***
;***********************************************

play_sound:			;a6=add voice(0-1-2-3)
	clr.w	d6
	move.b	pt_vol(a6),d6

;=========================
;=   gestion du volume   =
;=========================
gest_volume:

bcvo:	move.l	sound(a6),a0
	add.w	d6,a0
	move.b	(a0)+,d1
	cmp.b	#$a0,d1
	beq.s	vol_a0
	cmp.b	#$c0,d1
	beq.s	putv
no_c0:	cmp.b	#$b0,d1
	beq.s	exec_b0

	clr.w	volume(a6)	;volume=0  fin de sequence
	bclr	#2,d7		;son (off)
	bra	plays1

exec_b0:move.b (a0),d6
	bra.s bcvo

putv:	clr.w d1		;c0
	move.b (a0)+,d1
	bpl.s	.notres
	not.b	d1
	lea	ptr_res(pc),a0
	bra.s	.addv
;
; … d‚gager
;
.notres:
	lea	tb_sample(pc),a0
.addv
	add.w	d1,d1
	add	(a0,d1.w),a0
	move.l	a0,sample(a6)		;PC
	move.l	a0,st0(a6)		;ptr d‚but sample

	clr.b	cptins(a6)		;compteur … 0

	addq.b	#4,d6
	bset	#0,d7		;init
	bra.s bcvo
vol_a0:
	bclr #0,d7		;init ?
	beq.S vol2_a0
	move.b (a0)+,d1		;oui ! vol depart
	move.b (a0)+,d2		;vol arrive
	move.b (a0),cpt_vol(a6)	;dure
	addq.b #1,cpt_vol(a6)
	move.b d1,volume+1(a6)
	SF	cumul_vol(a6)	;clr cumul
	move.b #1,off_vol(a6)
	sub.b d1,d2
	bhs.s vol_monte
	neg.b d2
	ST	off_vol(a6)
vol_monte:
	move.b d2,vari_vol(a6)	;d2=variation volume
	bra.s plays1
end2_vol:
	addq.b #4,d6
	bset #0,d7		;init
	bra gest_volume
vol2_a0:
	subq.b #1,cpt_vol(a6)
	beq.s end2_vol
	move.b 2(a0),d4		;dure
	move.b cumul_vol(a6),d1
	add.b vari_vol(a6),d1
	sub.b d4,d1
	bmi.s end_vol
	clr.w d2		;offset
	move.b off_vol(a6),d3	;+1 -1
inc_off:
	add.b d3,d2
	sub.b d4,d1
	bpl.s inc_off
	add.b d2,volume+1(a6)
end_vol:
	add.b d4,d1
	move.b d1,cumul_vol(a6)

plays1:	move.b d6,pt_vol(a6)
	move.b pt_freq(a6),d6

;============================
;=  gestion de la frequence =
;============================
gest_frequence:

bcfq:	move.l sound+4(a6),a0
	add.w d6,a0
	move.b (a0)+,d1
	cmp.b #$a0,d1
	beq.s freq_a0
	cmp.b #$d0,d1
	beq.s freq_d0
	cmp.b #$b0,d1
	bne plays2	;mauvaise valeur ou fin de seq
	move.b (a0),d6	;restore pointeur sur boucle
	bra.s bcfq

;---********

freq_d0:
	bclr #1,d7		;init ?
	bne.s fre_d0
	subq.b #1,cpt_freq(a6)
	bne plays2
	bset #1,d7		;poursuit la sequence
	addq.b #4,d6
	bra.s gest_frequence
fre_d0:			;init
	clr d1
	move.b (a0),d1			;correction
	move.b 2(a0),cpt_freq(a6)	;dure
	add.b freque(a6),d1
	move (a1,d1.w),frequence(a6)	;new value
	bra.s plays2

;---*********

freq_a0:	;--- VARIATIONS
	bclr #1,d7		;init ?
	beq.s fre2_a0

	clr d0
	move.b (a0)+,d1		;depart
	move.b (a0)+,d2		;arrive
	move.b (a0),cpt_freq(a6);dure

	move.b freque(a6),d0
	move.w 0(a1,d0.w),d0
	ext d1
	ext d2
	add.w d0,d1		;freq depart
	add.w d0,d2		;freq arrive

	move.w d1,frequence(a6)
	move.w d1,cumul_freq(a6)
	clr.w off_freq(a6)

	sub.w d1,d2		;variation
	clr d1
	move.b cpt_freq(a6),d1	;duree

	ext.l d2
	asl.l #8,d2		;*256
	divs d1,d2
	bvs.s divsd2
	ext.l d2
	asl.l #8,d2		;*256
				;d2.H=partie entiere
				;d2.W=partie fractionnaire
	move.l d2,vari_freq(a6)	;d2=variation freq
	bra.s plays2

divsd2:
	asr.l #8,d2
	divs d1,d2
	swap d2
	clr d2
	move.l d2,vari_freq(a6)
	bra.s plays2
;--------------
fin2_a0:
	bset #1,d7		;poursuit la sequence
	addq.b #4,d6
	bra gest_frequence
fre2_a0:
	subq.b #1,cpt_freq(a6)
	beq.s fin2_a0

	move.l vari_freq(a6),d1
	add.l d1,cumul_freq(a6)
	move.w cumul_freq(a6),frequence(a6)

;---*******

plays2:	move.b d6,pt_freq(a6)
	move.w bender(a6),d1
	add.w d1,frequence(a6)

;---***************
	move.w volume(a6),d6

	add.b effet1(a6),d6
	sub.b #64,d6
	bpl.s v_pos		;test securite
	clr.w d6
v_pos:
;	sub	#10,d6		;volume moins fort
;	bhs.s	.okvol
;	clr	d6
;.okvol
	move.b	d6,cur_vol(a6)	;init volume pour replay ST
	rts

;=========================================
;== 	   BUFFERS  &  DATAS		==
;=========================================

filter
	DC.W	$FD,$EF,$E1
	DC.W	$D5,$C9,$BD,$B3
	DC.W	$A9,$9F,$96,$8E
	DC.W	$86,$7E,$77,$72
	DC.W	$6B,$64,$5F,$59
	DC.W	$54,$4F,$4B,$47
	DC.W	$43,$3F,$3C,$39
	DC.W	$36,$32,$2F,$2C
	DC.W	$2A,$28,$25,$24
	DC.W	$22,$20,$1E,$1C
	DC.W	$1B,$19,$18,$16
	DC.W	$15,$14,$13,$12
	DC.W	$11,$10,$F,$E
	DC.W	$D,$C,$C,$B
	DC.W	$A,$A,9,9
	rept	24
	DC.W	8
	endr

tb_notes:	;6 octaves
	DC.W	$FD1,$EEE,$E17,$D4D
	DC.W	$C8E,$BD9,$B2F,$A8E
	DC.W	$9F7,$967,$8E0,$861
	DC.W	$7E8,$777,$70B,$6A6
	DC.W	$647,$5EC,$597,$547
	DC.W	$4FB,$4B3,$470,$430
	DC.W	$3F4,$3BB,$385,$353
	DC.W	$323,$2F6,$2CB,$2A3
	DC.W	$27D,$259,$238,$218
	DC.W	$1FA,$1DD,$1C2,$1A9
	DC.W	$191,$17B,$165,$151
	DC.W	$13E,$12C,$11C,$10C
	DC.W	$FD,$EE,$E1,$D4
	DC.W	$C8,$BD,$B2,$A8
	DC.W	$9F,$96,$8E,$86
	DC.W	$7E,$77,$70,$6A
	DC.W	$64,$5E,$59,$54
	DC.W	$4F,$4B,$47,$43
	DC.W	$3F,$3B,$38,$35
	DC.W	$32,$2F,$2C,$2A
	DC.W	$27,$25,$23,$21
	DC.W	$1F,$1D,$1C,$1A
	DC.W	$19,$17,$16,$15
	DC.W	$13,$12,$11,$10
	DC.W	$F

;
; liste des bruitages
;
	ifeq	1
tbeff:	dc.w 0		;off_note
	dc.w vv0-tbeff,ff0-tbeff	;add_vol, add_freq
	dc.w 96+30	;son 1
	dc.w vv0-tbeff,ff0-tbeff
	dc.w 96+30	;son 2
	dc.w vv1-tbeff,ff1-tbeff
	dc.w 96-12	;son 3
	dc.w vv2-tbeff,ff2-tbeff

	dc.w 96+38	;son 4
	dc.w vv3-tbeff,ff3-tbeff

	dc.w 48		;son 5	(flamme)
	dc.w vv4-tbeff,ff4-tbeff
	dc.w 138	;son 6
	dc.w vv5-tbeff,ff5-tbeff
	dc.w 120	;son 7
	dc.w vv6-tbeff,ff6-tbeff
	dc.w 96+24	;son 8   (objet detruit)
	dc.w vv7-tbeff,ff7-tbeff

;-----------
vv0:	dc.b $c0,-1,00,04		;$0A
	dc.b $a0,50,0,14
	dc.b $e0,00

ff0:	dc.b $a0,0,50,2
	dc.b $a0,50,-100,6
	dc.b $d0,0,0,1
	dc.b $d0,18,0,1
	dc.b $b0,8
;-----------
vv1:	dc.b $c0,-3,0,0			;$0C
	dc.b $a0,50,10,10
	dc.b $e0,0

ff1:	dc.b $d0,-8,0,1
	dc.b $a0,-100,50,6
	dc.b $d0,0,0,1
	dc.b $d0,-18,0,1
	dc.b $b0,8
;-----------
vv2:	dc.b $c0,-3,0,10		;$28
	dc.b $a0,40,0,2
	dc.b $a0,60,20,6
	dc.b $c0,-1,00,4		;$1A
	dc.b $a0,30,0,10
	dc.b $e0,00

ff2:	dc.b $a0,100,-100,4
	dc.b $d0,-12,0,1
	dc.b $d0,8,0,1
	dc.b $d0,-4,0,1
	dc.b $d0,16,0,1
	dc.b $a0,127,-100,6
	dc.b $a0,-100,0,2
	dc.b $b0,24
;-----------
vv3:	dc.b $c0,-1,00,$f		;$1A
	dc.b $a0,60,05,5
	dc.b $a0,45,02,5
	dc.b $a0,30,00,8
	dc.b $a0,10,00,8
	dc.b $e0,00

ff3:	dc.b $d0,0,0,6
	dc.b $a0,0,4,2
	dc.b $d0,0,0,4
	dc.b $b0,4
;-----------

vv4:	dc.b $c0,-2,00,$8		;$0A
	dc.b $a0,64,30,10
	dc.b $a0,40,20,10
	dc.b $a0,50,30,10
	dc.b $a0,40,20,10
	dc.b $a0,30,10,10
	dc.b $a0,25,0,10
	dc.b $e0,04

ff4:	dc.b $a0,0,50,2
	dc.b $a0,50,-100,6
	dc.b $d0,0,0,1
	dc.b $d0,18,0,1
	dc.b $d0,0,0,1
	dc.b $d0,18,0,1
	dc.b $b0,0

;-----------

vv5:	dc.b $c0,-1,00,$f		;$1C
	dc.b $a0,35,20,4
	dc.b $a0,30,10,4
	dc.b $a0,10,00,8
	dc.b $e0,00

ff5:	dc.b $d0,-24,0,1
	dc.b $d0,0,0,1
	dc.b $e0,0
;-----------
vv6:	dc.b $c0,-1,00,$f		;$1C
	dc.b $a0,40,20,8
	dc.b $a0,20,00,20
	dc.b $e0,00

ff6:	dc.b $d0,8,0,3
	dc.b $d0,-10,0,3
	dc.b $d0,0,0,3
	dc.b $d0,10,0,1
	dc.b $e0,0
;----------
vv7:	dc.b $c0,-1,00,$f		;$1C
	dc.b $a0,40,20,8
	dc.b $e0,00

ff7:	dc.b $d0,8,0,3
	dc.b $e0,0
	even
	endc

tbeff:	dc.w 0		;off_note
	dc.w vv0-tbeff,ff0-tbeff	;add_vol, add_freq
	dc.w 96+26	;son 1
	dc.w vv0-tbeff,ff0-tbeff
	dc.w 96+30	;son 2
	dc.w vv1-tbeff,ff1-tbeff
	dc.w 96+22	;son 3
	dc.w vv2-tbeff,ff2-tbeff
	dc.w 96+8	;son 4
	dc.w vv3-tbeff,ff3-tbeff
	dc.w 48		;son 5	(flamme)
	dc.w vv4-tbeff,ff4-tbeff
	dc.w 138	;son 6
	dc.w vv5-tbeff,ff5-tbeff
	dc.w 120	;son 7
	dc.w vv6-tbeff,ff6-tbeff
	dc.w 96+24	;son 8 (objet detruit)
	dc.w vv7-tbeff,ff7-tbeff
	dc.w 92+2	;son 9
	dc.w vv8-tbeff,ff8-tbeff
	dc.w 96-8	;son 10
	dc.w vv9-tbeff,ff9-tbeff

	dc.w 96+24	;son 11 (toki meurt)
	dc.w vv10-tbeff,ff10-tbeff

	dc.w 96-24	;son 12
	dc.w vv11-tbeff,ff11-tbeff

	dc.w 140	;son 13
	dc.w vv12-tbeff,ff12-tbeff

;-
vv0:	dc.b $c0,-1,00,04		;$1a
	dc.b $a0,40,0,16
	dc.b $e0,00

ff0:	dc.b $a0,127,0,16
	dc.b $e0,00
;-
vv1:	dc.b $c0,-3,00,00		;$1f
	dc.b $a0,35,00,8
	dc.b $e0,00

ff1:	dc.b $d0,-8,0,1
	dc.b $a0,-10,127,10
	dc.b $e0,00
;-
vv2:	dc.b $c0,-3,01,$f		;$1a
	dc.b $a0,30,0,10
	dc.b $e0,00

ff2:	dc.b $a0,100,-50,2
	dc.b $a0,-50,120,8
	dc.b $e0,00
;-
vv3:	dc.b $c0,-1,00,$f		;$1a
	dc.b $a0,40,05,3
	dc.b $a0,35,02,5
	dc.b $a0,20,00,8
	dc.b $a0,10,00,6
	dc.b $e0,00

ff3:	dc.b $a0,-127,50,4
	dc.b $a0,0,127,3
	dc.b $a0,127,0,3
	dc.b $b0,4

;-
vv4:	dc.b $c0,-1,00,$8		;$2f
	dc.b $a0,64,64,20
	dc.b $e0,04

ff4:	dc.b $a0,20,0,20
	dc.b $a0,0,120,20
	dc.b $b0,0
;-
vv5:	dc.b $c0,-1,00,$f		;$1c
	dc.b $a0,35,20,4
	dc.b $a0,30,10,4
	dc.b $a0,10,00,8
	dc.b $e0,00

ff5:	dc.b $d0,-24,0,1
	dc.b $d0,0,0,1
	dc.b $e0,0
;-
vv6:	dc.b $c0,-1,00,$f		;$1c
	dc.b $a0,40,20,8
	dc.b $a0,20,00,20
	dc.b $e0,00

ff6:	dc.b $d0,8,0,3
	dc.b $d0,-10,0,3
	dc.b $d0,0,0,3
	dc.b $d0,10,0,1
	dc.b $e0,0
;-
vv7:	dc.b $c0,-1,00,$f		;$1c
	dc.b $a0,40,20,8
	dc.b $e0,00

ff7:	dc.b $d0,8,0,3
	dc.b $e0,0
;-
vv8:	dc.b $c0,-1,1,$f		;$1c
	dc.b $a0,30,50,3
	dc.b $a0,25,0,8
	dc.b $e0,00

ff8:	dc.b $a0,-120,0,4
	dc.b $d0,-24,0,2
	dc.b $d0,0,0,1
	dc.b $b0,4
;-
vv9:	dc.b $c0,-1,1,$f		;$1c
	dc.b $a0,40,60,3
	dc.b $a0,30,0,4
	dc.b $a0,50,0,4
	dc.b $a0,20,0,2
	dc.b $a0,30,0,4
	dc.b $a0,10,0,3
	dc.b $e0,00

ff9:	dc.b $d0,12,0,2
	dc.b $a0,127,-127,6
	dc.b $d0,-12,0,2
	dc.b $d0,24,0,1
	dc.b $b0,8
;*

vv10:	dc.b $c0,-1,00,$f		;$1c
	dc.b $a0,40,20,8
	dc.b $e0,00

ff10:	dc.b $d0,8,0,3
	dc.b $e0,0
;-

vv11:	dc.b $c0,-1,0,$f		;$1a
	dc.b $a0,40,20,4
	dc.b $a0,20,40,6
	dc.b $a0,30,10,20
	dc.b $a0,10,00,40
	dc.b $e0,00

ff11:	dc.b $d0,8,0,1
	dc.b $a0,127,-127,10
	dc.b $d0,8,0,2
	dc.b $d0,10,0,2
	dc.b $d0,12,0,2
	dc.b $d0,14,0,2
	dc.b $d0,18,0,2
	dc.b $d0,24,0,2
	dc.b $d0,32,0,2
	dc.b $d0,38,0,1
	dc.b $e0,0
;-

vv12:	dc.b $c0,-1,00,$f		;$1a
	dc.b $a0,40,20,4
	dc.b $a0,10,0,8
	dc.b $e0,00

ff12:	dc.b $d0,0,0,1
	dc.b $d0,2,0,1
	dc.b $e0,0
 even

FIN	MACRO
	DC.B	$00
	ENDM
LENGTH	MACRO
	DC.B	$01,\1
	ENDM
LOOP	MACRO
	DC.B	$02,\1
	ENDM
SON	MACRO
	DC.B	$03
	ENDM
BRUIT	MACRO
	DC.B	$04,\1
	ENDM
SONBRUIT:MACRO
	DC.B	$05,\1
	ENDM
RIEN	MACRO
	DC.B	$06
	ENDM
HARD	MACRO
	DC.B	$07,\1,\2
	ENDM
BRUITC	MACRO			;bruit calcul‚
	DC.B	$08,\1
	ENDM
SONBRUITC:MACRO			;bruit calcul‚
	DC.B	$09,\1
	ENDM
HARDC	MACRO			;enveloppe calcul‚e
	DC.B	$0a,\1,\2
	ENDM
VOLUME	macro			;volume … soustraire sur la voix
	dc.b	$0b,\1
	endm

ptr_res:dc.w	sound0-ptr_res	;son -1
	dc.w	sound1-ptr_res	;son -2
	dc.w	sound2-ptr_res	;son -3

sound0:
	VOLUME	0
	SON
	LENGTH	100
	FIN
sound1:
	VOLUME	0
	BRUITC	-4		;$18
	LENGTH	100
	FIN
sound2:
	VOLUME	0
;	SONBRUITC	-4	;$18-4
	BRUITC	-4		;$18-4
	LENGTH	0
	SON
	LENGTH	100
	FIN


synthe0:
	VOLUME	0
	SON
	FIN
cymbale:
	VOLUME	0
	BRUIT	0
	FIN
cymbale2:
	VOLUME	0
	SONBRUITC	$18-2+2
	FIN
	even

tb_sample:
x:
	rept	26
	dc.W	synthe0-x
	endr
	dc.W	synthe0-x
	dc.W	cymbale2-x	;elf6
	dc.W	cymbale-x	;elf2

fin_sample:
