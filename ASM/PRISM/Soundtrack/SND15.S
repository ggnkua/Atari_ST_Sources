

adr_vol:	equ	$2000
adr_sound:	equ	$1000

frq_data:	equ	39	39
tailbuf:	equ	384*2


ecart	equ	500		600 pour crupto



	opt	o+

vsync:	macro
	move.l	$466.w,d0
.\@l1:
	cmp.l	$466.w,d0
	beq.s	.\@l1
	endm

	move.w	sr,d0
	btst	#13,d0
	bne.s	yeah

	clr.	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

yeah:
	move.l	$44e.w,oldecr

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,log
	add.l	#32000,d0
	move.l	d0,phy

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w

	lea	save8,a0
	lea	fin,a1
	move.l	$8.w,(a0)+
	move.l	a1,$8.w
	move.l	$c.w,(a0)+
	move.l	a1,$c.w
	move.l	$14.w,(a0)+
	move.l	a1,$14.w


	bsr	copie_frq
	bsr	init

	vsync
	move.b	#0,$ffff8260.w
	vsync

	move.w	#$2700,sr
	bsr	copie_volume
	bsr	init_mfp


	lea	$ffff8800.w,a1

	move.l	#hbl,$68.w

	move.l	#vbl,$70.w

*	move.l	#vbl2,$70.w

	move.w	#$2300,sr

	move.b	#%00100000,$fffffa07.w
	move.b	#%00100000,$fffffa13.w
	vsync
main:

*	bsr	vbl

	cmp.b	#$39,$fffffc02.w
	bne.s	main

fin:
	move.w	#$2700,sr
	bsr	copie_volume
	bsr	fin_mfp
	move.w	#$2300,sr

	lea	save8,a0
	move.l	(a0)+,$8.w
	move.l	(a0)+,$c.w
	move.l	(a0)+,$14.w

error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:


	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w

	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	vsync


	clr.w	-(sp)
	trap	#1

copie_frq:
	lea	frq,a0
	lea	frq2,a1
	move.w	#857-1,d0
.loop1:
	move.l	(a0)+,d1
	move.w	#315-1,d2
	moveq	#0,d3
.loop2:
	add.l	d1,d3
	dbf	d2,.loop2
	move.l	d3,(a1)+
	dbf	d0,.loop1
	rts

trans_volume:
	lea	volume,a0		bricolage volume
	move.w	#(16384/2)-1,d0	passage en .w + $1000
.loop22:
	moveq	#0,d1
	move.b	(a0),d1
	add.w	#$1000/32,d1
	lsl.w	#3,d1
	move.w	d1,(a0)+
	dbf	d0,.loop22

	rts

copie_volume:

	lea	volume,a0
	lea	adr_vol,a1
	move.w	#16384-1,d0
.loop1:
	move.b	(a0),d1
	move.b	(a1),(a0)+
	move.b	d1,(a1)+
	dbf	d0,.loop1

	lea	sound,a0
	lea	adr_sound.w,a1
	move.w	#2048-1,d0
.loop2:
	move.b	(a0),d1
	move.b	(a1),(a0)+
	move.b	d1,(a1)+
	dbf	d0,.loop2
	rts


init_mfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move.w	#16,d0
	
savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40

	bclr	#3,$fffffa17.w
	
	clr.b	$fffffa19.w 	    Arret Timer A (Reg control)
	clr.b	$fffffa1b.w 	    Arret Timer B (Reg control)

	move.b	#frq_data,$fffffa1f.w
	move.b	#1,$fffffa19.w
	move.l	#soundchip,$134.w

	move.b	#%00000000,$fffffa07.w
	move.b	#%00000000,$fffffa13.w
	
	move.b	#%00000000,$fffffa09.w
	move.b	#%00000000,$fffffa15.w

	rte
	
fin_mfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
	
restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w

	rte
	
hbl:
	rte

vbl2:	rte



vbl:
toto:	move.w	#$245,$ffff8240.w
	bsr	play
	addq.l	#1,$466.w

	move.w	#$0,$ffff8240.w

*	rts

	rte
	
init:
	movem.l	d0-a6,-(sp)
	lea	module,a0
	lea	offset(pc),a1
	move.w	#$1d8,pos(a1)
	move.w	#$258,patt(a1)
	move.w	#$f,nbr(a1)

;module du type 31 instruments ?

	cmp.l	#'M.K.',$438(a0)
	bne.s	no_new_modules
	move.w	#$3b8,pos(a1)
	move.w	#$43c,patt(a1)
	move.w	#$1f,nbr(a1)
no_new_modules

	lea	module,a0
	lea	offset(pc),a1
	add.w	pos(a1),a0
	moveq	#$7f,d0
	moveq	#0,d1
;nombre de patterns
.loop1	move.l	d1,d2
	subq.w	#1,d0
.loop2	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	.loop1
	dbf	d0,.loop2
	addq.b	#1,d2
	swap	d2
	lsr.l	#6,d2
	lea	module,a0
	add.l	a0,d2
	lea	$14(a0),a0
	lea	offset(pc),a1
	move.w	nbr(a1),d7
	add.w	patt(a1),d2
	move.l	d2,a2
	lea	samplestarts(pc),a1
	lea	(a1),a3
	moveq	#$1e,d6
.loop3	clr.l	(a3)+
	dbra	d6,.loop3
	subq.w	#1,d7
.loop4	clr.l	(a2)
;adresse de debut des samples
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	22(a0),d1	len
	lsl.l	#1,d1	fois deux
	cmp.w	#1,d1
	blt.s	.ok1
	add.l	#ecart,d1	plus ecart
.ok1:	move.l	a2,a5
	add.l	d1,a2
	move.l	a2,(a1)
	move.l	a2,a6
	move.w	22(a0),d6
	beq.s	.no_reverse
	cmp.w	#1,d6
	beq.s	.no_reverse
	add.l	#ecart/2,d6
	subq.w	#1,d6
;inverse les samples en memoire
.loop5	move.b	(a5),d2
	move.b	-1(a6),d3
;met les samples au format non signes
	eor.b	#$80,d2
	eor.b	#$80,d3
	move.b	d3,(a5)+
	move.b	d2,-(a6)
	dbra	d6,.loop5
.no_reverse
	cmp.w	#$0001,28(a0)
	bne.s	.loop6
	clr.w	28(a0)
.loop6	lea	$1e(a0),a0
	dbra	d7,.loop4
t3:
	lea	chip(pc),a0
	lea	no_ins+200(pc),a1
	moveq	#$7,d0
.loop7	move.l	a1,(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,.loop7
	lea	voices(pc),a0
	moveq	#$1c-1,d0
.loop11	clr.l	(a0)+
	dbra	d0,.loop11
;initialise quelques datas...
	lea	offset(pc),a0
	move.b	#$6,speed
*	move.b	#5,songpos(a0)
	clr.b	songpos(a0)
	

	clr.b	counter(a0)
	clr.w	pattpos(a0)
	lea	digit_swap(pc),a0
	lea	(digit+tailbuf)(pc),a1
	move.l	a1,(a0)
	
	lea	digit(pc),a1
	move.l	a1,4(a0)
	move.l	a1,usp
	move.w	#tailbuf-1,d0
.loop8	move.w	#$1000,(a1)+
	dbra	d0,.loop8


	lea	sound(pc),a0
	move.w	#255,d0
.loop9	move.b	5(a0),6(a0)
	move.b	5(a0),7(a0)
	move.b	4(a0),5(a0)
	lea	8(a0),a0
	dbra	d0,.loop9

	lea	volume(pc),a0
	move.w	#$3fff,d0
.loop10	move.b	(a0),d1
;transformation de la table de volume
;en donnees 6 bits
	lsr.b	#2,d1
	move.b	d1,(a0)+
	dbra	d0,.loop10

;	passage table volume avec ajout table sound en $1000

	bsr	trans_volume

;yamaha reset
	move.l	#$00000000,$ffff8800.w
	move.l	#$01010000,$ffff8800.w
	move.l	#$02020000,$ffff8800.w
	move.l	#$03030000,$ffff8800.w
	move.l	#$04040000,$ffff8800.w
	move.l	#$05050000,$ffff8800.w
	move.l	#$06060000,$ffff8800.w
	move.l	#$0707ffff,$ffff8800.w
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w

	movem.l	(sp)+,d0-a6
	rts

;zone de sauvegarde du contexte du st





play:
	move.w	#$2700,sr
;permutation des deux buffers
;de digit  de travail
	lea	digit_swap(pc),a6
	move.l	4(a6),a5
	move.l	(a6),4(a6)
	move.l	(a6),d0

	move.l	usp,a0		nombre d'octets jou‚s
	sub.l	d0,a0
	move.l	a0,$41a.w

	move.l	a5,(a6)
	move.l	a5,usp
	move.w	#$2300,sr
;lit la partition et produit
;les effets sonores
	bsr.s	player
;calcule la digit a jouer
;a la prochaine vbl
	bsr	precalc_digit
	rts

player:
	lea	offset(pc),a4
	move.b	counter(a4),d0
	subq.b	#1,d0
	bgt.s	nonew
;effets sonore ou nouvelle
;lecture de la partition ?
	move.b	speed,d0

	move.b	d0,counter(a4)
	bra.s	read_pattern

;produit les effets sonores
;sur les 4 voies
;commandes:0,1,2,3,4,a
nonew:
	move.b	d0,counter(a4)
	lea	chip1(pc),a5
	lea	voice1(pc),a6
	bsr	check_command
	lea	chip2(pc),a5
	lea	voice2(pc),a6
	bsr	check_command
	lea	chip3(pc),a5
	lea	voice3(pc),a6
	bsr	check_command
	lea	chip4(pc),a5
	lea	voice4(pc),a6
	bsr	check_command
	bra	end_of_player

;lit la partition pour les 4 voies

*	utilise :	A0,A3,A4,A5,A6
*		D0,D1,D2,D3,D4

read_pattern:

	lea	module,a0
	lea	$c(a0),a3
	move.l	a0,a5
	add.w	pos(a4),a5
	add.w	patt(a4),a0

	moveq	#0,d0
	moveq	#0,d1
	move.b	songpos(a4),d0
	move.b	(a5,d0.w),d1
	swap	d1
	lsr.l	#$6,d1
	add.w	pattpos(a4),d1

	move.l	a4,-(sp)
	lea	samplestarts(pc),a4
	lea	chip1(pc),a5
	lea	voice1(pc),a6
	bsr.s	playvoice
	lea	chip2(pc),a5
	lea	voice2(pc),a6
	bsr.s	playvoice
	lea	chip3(pc),a5
	lea	voice3(pc),a6
	bsr.s	playvoice
	lea	chip4(pc),a5
	lea	voice4(pc),a6
	bsr.s	playvoice
	move.l	(sp)+,a4
	bra	set_repeat

;routine qui traite une voie

playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0	numero ins
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	set_regs
	moveq	#0,d3
	move.l	d2,d4
	subq.l	#$1,d2
	add.w	d2,d2
	add.w	d2,d2
	mulu	#$1e,d4
	move.l	(a4,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	bra.s	no_loop

	move.l	$4(a4,d2.l),$4(a6)
	add.w	$6(a3,d4.l),d3
	move.w	d3,$8(a6)
	add.w	d3,d3
	sub.l	d3,$4(a6)
	move.l	$4(a6),$a(a6)
	moveq	#0,d3
	move.w	$6(a3,d4.l),d3
	move.w	d3,$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	set_regs
no_loop:
	move.l	$4(a6),$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
set_regs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	check_command_2
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$3,d0
	bne.s	setperiod
	bsr	set_portamento_tone
	bra	check_command_2
setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	moveq	#0,d0
	move.w	$8(a6),d0
	add.w	d0,d0
	move.l	d0,$4(a5)
	move.w	$10(a6),$a(a5)
	bra	check_command_2


;active les repeat des 4 voies
set_repeat:
	moveq	#0,d0
	lea	chip1(pc),a5
	lea	voice1(pc),a6
	move.l	$a(a6),$c(a5)
	move.w	$e(a6),d0
	add.w	d0,d0
	move.l	d0,$10(a5)
	lea	chip2(pc),a5
	lea	voice2(pc),a6
	move.l	$a(a6),$c(a5)
	move.w	$e(a6),d0
	add.w	d0,d0
	move.l	d0,$10(a5)
	lea	chip3(pc),a5
	lea	voice3(pc),a6
	move.l	$a(a6),$c(a5)
	move.w	$e(a6),d0
	add.w	d0,d0
	move.l	d0,$10(a5)
	lea	chip4(pc),a5
	lea	voice4(pc),a6
	move.l	$a(a6),$c(a5)
	move.w	$e(a6),d0
	add.w	d0,d0
	move.l	d0,$10(a5)

	add.w	#$10,pattpos(a4)
;nouveau pattern?
	cmp.w	#$400,pattpos(a4)
	bne.s	end_of_player
next_patt
	clr.w	pattpos(a4)
	clr.b	break
	addq.b	#1,songpos(a4)
	and.b	#$7f,songpos(a4)
	move.b	songpos(a4),d1
	lea	module,a0
	add.w	pos(a4),a0
	cmp.b	-2(a0),d1
	bne.s	end_of_player
	clr.b	songpos(a4)
	move.w	#$754,toto+2
end_of_player
	tst.b	break
	bne.s	next_patt
	rts


;effets sonores qui se produisent
;lorsqu'il ne faut pas lire la partition

*	utilise A3,A4,A5,A6
*	        D0,D1,D2,D3

check_command:

	move.w	$2(a6),d0
	and.w	#$fff,d0
;pas de commande
	beq.s	no_command
	move.b	$2(a6),d0
	and.b	#$f,d0
	beq.s	arpeggio
	cmp.b	#$1,d0
	beq	portamento_up
	cmp.b	#$2,d0
	beq	portamento_down
	cmp.b	#$3,d0
	beq	portamento_tone
	cmp.b	#$4,d0
	beq	vibrato
	move.w	$10(a6),$a(a5)
	cmp.b	#$a,d0
	beq	volume_slide
no_command
	rts

;commande 0: arpeggio
arpeggio
	moveq	#0,d0
	move.b	counter(a4),d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	arpeggio2
	cmp.w	#$2,d0
	beq.s	arpeggio1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#$4,d0
	bra.s	arpeggio3
arpeggio1
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	arpeggio3
arpeggio2
	move.w	$10(a6),d2
	bra.s	arpeggio4
arpeggio3
	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	periods(pc),a0
	moveq	#$24,d3
arpeggio_loop
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arpeggio4
	addq.l	#2,a0
	dbra	d3,arpeggio_loop
	rts
arpeggio4
	move.w	d2,$a(a5)
	rts

;commande 1: portamento up

portamento_up:
	move.w	#$72,$ffff8240.w
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	cmp.w	#$71,d0
	bpl.s	portup
	move.w	#$71,$10(a6)
portup:
	move.w	$10(a6),$a(a5)
	rts

;commande 2: portamento down
portamento_down:
*	move.w	#$72,$ffff8240.w
	moveq	#0,d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	cmp.w	#$358,d0
	bmi.s	portdwn
	move.w	#$358,$10(a6)
portdwn	move.w	$10(a6),$a(a5)
	rts

;met en place le portamento tone
set_portamento_tone
*	move.w	#$72,$ffff8240.w
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	clr_portamento_tone
	bge.s	ok_rts
	move.b	#$1,$16(a6)
	rts
clr_portamento_tone
	clr.w	$18(a6)
ok_rts
	rts

;commande 3: portamento tone
portamento_tone
*	move.w	#$72,$ffff8240.w
	move.b	$3(a6),d0
	beq.s	my_slide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
my_slide
	tst.w	$18(a6)
	beq.s	ok_rts
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	my_sub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	my_ok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
my_ok	move.w	$10(a6),$a(a5)
	rts
my_sub
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	my_ok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$a(a5)
	rts

;commande 4: vibrato
vibrato
	move.b	$3(a6),d0
	beq.s	vib
	move.b	d0,$1a(a6)

vib	move.b	$1b(a6),d0
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	lea	sinus(pc),a3
	move.b	(a3,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	vib_min
	add.w	d2,d0
	bra.s	vib2
vib_min	sub.w	d2,d0
vib2	move.w	d0,$a(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

;commande $a: volume slide
volume_slide
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	volume_down
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	volup_ok
	move.w	#$40,$12(a6)
volup_ok
	move.w	$12(a6),$8(a5)
	rts

volume_down
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	voldwn_ok
	clr.w	$12(a6)
voldwn_ok
	move.w	$12(a6),$8(a5)
	rts

;commandes qui peuvent etre effectuees
;lors de la lecture de la partition

*	utilise : A4,A5,A6
*	          D0

check_command_2
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$b,d0
	beq.s	position_jump
	cmp.b	#$c,d0
	beq.s	set_volume
	cmp.b	#$d,d0
	beq.s	pattern_break
	cmp.b	#$e,d0
	beq.s	set_filter
	cmp.b	#$f,d0
	beq.s	set_speed
;pas de commande
	rts

;commande $b: postion jump
position_jump
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,songpos(a4)
	not.b	break
	rts

;commande $c: set volume
set_volume
	cmp.b	#$40,$3(a6)
	ble.s	volume_ok
	move.b	#$40,$3(a6)
volume_ok
	move.b	$3(a6),$9(a5)
	rts

;commande $d: pattern break
pattern_break
	not.b	break
	rts

;commande $e: filter
;il n'est pas implemente ici
set_filter
	rts

;commande $f: set speed
set_speed
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	no_change_speed
	clr.b	counter(a4)
	move.b	d0,speed
no_change_speed
	rts


;precalcule la digit qui sera jouee
;lors de la prochaine vbl

precalc_digit:
	move.w	#$70,$ffff8240.w

	bsr	generev1
	bsr	generev2
	bsr	generev3
	bsr	generev4

	move.w	#$2700,sr
	move.l	#soundchip2,$134.w
	move.w	#$2300,sr
	move.w	#$707,$ffff8240.w

	bsr.s	fill_digit

	move.w	#$2700,sr
	lea	$ffff8800.w,a1
	move.l	#soundchip,$134.w
	move.w	#$2300,sr

	rts

;	a0=buffer digit
;	a1=adr volume
;	a2=adr table inc

;	a3=adr ins v1
;	a4=adr ins v2
;	a5=adr ins v3
;	a6=adr ins v4

;	d0=accumulateur
;	d1=>PLAYER
;	d2=LIBRE !
;	d3=volume v1
;	d4=volume v2
;	d5=volume v3
;	d6=volume v4
;	d7=boucle

fill_digit:

	move.w	#1,$210.w
	lea	digit_swap(pc),a0
	move.l	4(a0),a0
	lea	adr_vol,a1

	move.l	chip1,a3
	lea	ecart(a3),a3
	adda.w	chip1+6,a3
	move.l	chip2,a4
	lea	ecart(a4),a4
	adda.w	chip2+6,a4
	move.l	chip3,a5
	lea	ecart(a5),a5
	adda.w	chip3+6,a5
	move.l	chip4,a6
	lea	ecart(a6),a6
	adda.w	chip4+6,a6

	moveq	#0,d0

	moveq	#0,d3
	move.w	chip1+8,d3
	beq.s	.volume_nul1
	subq.w	#1,d3
	lsl.w	#8,d3
.volume_nul1:
	add.l	a1,d3

	moveq	#0,d4
	move.w	chip2+8,d4
	beq.s	.volume_nul2
	subq.w	#1,d4
	lsl.w	#8,d4
.volume_nul2:
	add.l	a1,d4


	moveq	#0,d5
	move.w	chip3+8,d5
	beq.s	.volume_nul3
	subq.w	#1,d5
	lsl.w	#8,d5
.volume_nul3:
	add.l	a1,d5

	moveq	#0,d6
	move.w	chip4+8,d6
	beq.s	.volume_nul4
	subq.w	#1,d6
	lsl.w	#8,d6
.volume_nul4:
	add.l	a1,d6
	
	move.w	#5-1,d7		5*63=315
loop_c1:

	move.b	(a3),d3			8
	move.l	d3,a1			4
	move.w	(a1),d0			8

	move.b	(a4),d4			8
	move.l	d4,a1			4
	add.w	(a1),d0			8

	move.b	(a5),d5			8
	move.l	d5,a1			4
	add.w	(a1),d0			8

	move.b	(a6),d6			8
	move.l	d6,a1			4
	add.w	(a1),d0			8

	move.w	d0,(a0)+		2 = 40	12 = 92

auto:
	rept	62		octets	cycles


	move.b	1(a3),d3		4	12
	move.l	d3,a1		2	4
	move.w	(a1),d0		2	8

	move.b	1(a4),d4		4	12
	move.l	d4,a1		2	4
	add.w	(a1),d0		2	8

	move.b	1(a5),d5		4	12
	move.l	d5,a1		2	4
	add.w	(a1),d0		2	8

	move.b	1(a6),d6		4	12
	move.l	d6,a1		2	4
	add.w	(a1),d0		2	8
	
	move.w	d0,(a0)+		2 = 40	12 = 108
	endr


inc1:	lea	1(a3),a3
inc2:	lea	1(a4),a4
inc3:	lea	1(a5),a5
inc4:	lea	1(a6),a6


	dbf	d7,loop_c1			932 cycles

	move.w	d0,(a0)+		2 = 40	12 = 108
	move.w	d0,(a0)+		2 = 40	12 = 108


	move.w	chip1+6,d0
	sub.w	$270.w,d0
	bge.s	.okv1
	move.w	chip1+18,d0
	move.l	chip1+12,chip1
.okv1:
	move.w	d0,chip1+6

	move.w	chip2+6,d0
	sub.w	$274.w,d0
	bge.s	.okv2
	move.w	chip2+18,d0
	move.l	chip2+12,chip2
.okv2:
	move.w	d0,chip2+6

	move.w	chip3+6,d0
	sub.w	$278.w,d0
	bge.s	.okv3
	move.w	chip3+18,d0
	move.l	chip3+12,chip3
.okv3:
	move.w	d0,chip3+6

	move.w	chip4+6,d0
	sub.w	$27c.w,d0
	bge.s	.okv4
	move.w	chip4+18,d0
	move.l	chip4+12,chip4
.okv4:
	move.w	d0,chip4+6

	rts

generev1:
	lea	chip1,a6
	lea	auto+2(pc),a0
	moveq	#0,d6
	move.w	10(a6),d6		;periode

	add.w	d6,d6
	add.w	d6,d6
	lea	frq(pc),a4
	move.l	(a4,d6.w),d2	;periode.l
	lea	frq2(pc),a4
	move.l	(a4,d6.w),$270.w	;periode.l

	move.w	d2,d4	virgule
	moveq	#0,d5	virgule

	swap	d2
	moveq	#0,d3

st	set	0
	rept	62
	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,st(a0)
st	set	st+34
	endr
	
	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,inc1+2
	
	rts

generev2:
	lea	chip2,a6
	lea	auto+8+2(pc),a0

	moveq	#0,d6
	move.w	10(a6),d6		;periode

	add.w	d6,d6
	add.w	d6,d6
	lea	frq(pc),a4
	move.l	(a4,d6.w),d2	;periode.l
	lea	frq2(pc),a4
	move.l	(a4,d6.w),$274.w	;periode.l

	move.w	d2,d4	virgule
	moveq	#0,d5	virgule

	swap	d2
	moveq	#0,d3

st	set	0
	rept	62
	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,st(a0)
st	set	st+34
	endr

	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,inc2+2

	rts

generev3:
	lea	chip3,a6
	lea	auto+16+2(pc),a0

	moveq	#0,d6
	move.w	10(a6),d6		;periode

	add.w	d6,d6
	add.w	d6,d6
	lea	frq(pc),a4
	move.l	(a4,d6.w),d2	;periode.l
	lea	frq2(pc),a4
	move.l	(a4,d6.w),$278.w	;periode.l

	move.w	d2,d4	virgule
	moveq	#0,d5	virgule

	swap	d2
	moveq	#0,d3

st	set	0
	rept	62
	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,st(a0)
st	set	st+34
	endr

	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,inc3+2

	rts

generev4:
	lea	chip4,a6
	lea	auto+24+2(pc),a0

	moveq	#0,d6
	move.w	10(a6),d6		;periode

	add.w	d6,d6
	add.w	d6,d6
	lea	frq(pc),a4
	move.l	(a4,d6.w),d2	;periode.l
	lea	frq2(pc),a4
	move.l	(a4,d6.w),$27c.w	;periode.l

	move.w	d2,d4	virgule
	moveq	#0,d5	virgule

	swap	d2
	moveq	#0,d3

st	set	0
	rept	62
	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,st(a0)
st	set	st+34
	endr

	sub.w	d4,d5
	subx.w	d2,d3
	move.w	d3,inc4+2

	rts




;gestion yamaha 2149

soundchip:
	move.l	usp,a2		4
	move.w	(a2)+,d7		8
	move.l	a2,usp		4
	movea.w	d7,a2		4
	move.l	(a2)+,d7		12
	move.l	(a2),(a1)		20
	movep.l	d7,(a1)		24 = 100
	rte

soundchip2:
	movem.l	a1-a2,-(sp)

	move.l	usp,a2		4
	move.w	(a2)+,d1		8
	move.l	a2,usp		4

	movea.w	d1,a2
	move.l	(a2)+,d1		28

	lea	$ffff8800.w,a1	8

	move.l	(a2),(a1)
	movep.l	d1,(a1)

	movem.l	(sp)+,a1-a2	12 = 136
	rte

soundchip3:
	move.l	a2,-(sp)		12
	move.l	a1,d2		4
	move.l	usp,a2		4
	move.w	(a2)+,d1		8
	move.l	a2,usp		4
	movea.w	d1,a2
	move.l	(a2)+,d1		12
	lea	$ffff8800.w,a1	8
	move.l	(a2),(a1)		20
	movep.l	d1,(a1)		24
	move.l	(sp)+,a2		12
	move.l	d2,a1		4 = 136
	rte

sound:
	incbin	"table1.dst"
	even

	section	data

log:	dc.l	$f8000
phy:	dc.l	$f8000

;table pour le vibrato
sinus
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18
;table pour l'arpeggio
periods
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

speed:	dc.b	6
break:	dc.b	0
	even

offset:	dcb.w	$6,0
songpos:	equ	$1
pattpos:	equ	$2
counter:	equ	$4
pos:	equ	$6
patt:	equ	$8
nbr:	equ	$a
samplestarts:	dcb.l	$20,0
voices:	dcb.l	$1c,0
voice1:	equ	voices
voice2:	equ	voices+$1c
voice3:	equ	voices+$38
voice4:	equ	voices+$54
chip:	dcb.l	$18
chip1:	equ	chip
chip2:	equ	chip+$18
chip3:	equ	chip+$30
chip4:	equ	chip+$48
*	dcb.b	ecart,$0

no_ins:	dcb.b	ecart+500,$80

digit:	dcb.w	(tailbuf+8)/2,adr_sound
digit2:	dcb.w	(tailbuf+8)/2,adr_sound
digit_swap:	dcb.l	2,0

frq:	dc.l	0
	incbin	16khz.frq		16
end_frq:

frq2:
	ds.l	857

volume:
	incbin	volume.bin	;table cr‚‚e par volume.gfa
	even
module:
	incbin	"swing.mo3"
	even

	section	bss




oldecr:	ds.l	1
savcol:	ds.w	16

oldmfp	ds.b	24
oldvec	ds.l	24
olda7:	ds.l	1

save8:	ds.l	3

ecrans:	ds.b	256
	ds.b	64000
	end

;	voicex
;voice+$0:  1 longmot: derniere ligne lue dans la partition
;voice+$4:  1 longmot: adresse de l'instrument utilise
;voice+$8:  1 mot:     longueur de l'instrument en mot
;voice+$a:  1 longmot: adresse de la partie du sample a repeat 
;voice+$e:  1 mot:     longueur du repeat en mot
;voice+$10: 1 mot:     periode(=note)
;voice+$12: 1 mot:     volume
;voice+$14: 1 mot:     inutilise
;voice+$16: 1 octet:   concerne la commande 3
;voice+$17: 1 octet:   concerne la commande 3
;voice+$18: 1 mot:     periode(=note) d'arrivee pour la commande 3
;voice+$1a: 1 octet:   concerne la commande 4
;voice+$1b: 1 octet:   concerne la commande 4
;
;	chipx
;chip+$0:   1 longmot: adresse de l'instrument
;chip+$4:   1 longmot: longueur restante exprimee en octet
;chip+$8:   1 mot:     volume actuel
;chip+$a:   1 mot:     periode(=note)
;chip+$c:   1 longmot: adresse de la partie a repeat
;chip+$10:  1 longmot: longueur de la boucle exprimee en octet
;
;
;nous utilisons une table de volume au format suivant:
;seuls les 6 bits de poids faible sont utilises dans chaque octet.
;cela a pour consequence d'avoir une tres bonne qualite sonore.
;
