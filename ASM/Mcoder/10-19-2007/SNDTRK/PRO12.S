;
; compli.mod (FE73 !!!)
; sonic.mod (<$FF1)
; consumma ($FF1)
;
; ‚crire programme qui fasse le directory des modules
;  (nom fichier,nom module,taille module,type module=nb ins,nb octets en trop ou pas assez)
;
; THUNDER.MOD -> ‚cart max = 17897 !!!!
; SONIC.MOD -> ‚cart=719
;
; structure d'un module
;
;	0-19=nom du module
;
;	ensuite pour chaque instrument :
;	0-21=nom de l'instrument
;	22.W=size
;	24.W=volume
;	26.W=loops
;	28.W=loopl
;
;	31*30+20=950=$3B6
;
;   15   31
;  $1D6	$3B6 (950) .B num‚ro du dernier pattern
;  $1D7	$3B7 (951) .B inutilis‚ ????
;  $1D8	$3B8 (952) 128 patterns
;   ..	$438 (1080) 'M.K.' ou 'FLT4' ou autre si module 15 instruments
;  $258	$43C (1084) stockage des patterns
;		    1024 octets par pattern = 256 octets par voie
;
; les modules qui plantent dŠs le d‚but ont besoin de 4 octets de plus
;  … la fin ????
;
; HARD20.MOD contient le nom le plus long
; UNIQUE.MOD peut ˆtre play‚ … 6 Khz !!!
; HARD6.MOD aussi
;
; am‚liorations :
;	- rajouter chrono
;	- afficher la fr‚quence la plus basse et la plus ‚lev‚e
;	- afficher nb instruments stock‚s+utilis‚s
;	- rajouter des fr‚quences cf COMPLI.MOD
;	- rajouter test longueur 0 quand on playe un module
;	   pour ‚viter plantage lamentable !!!
;	- ‚crire exploreur de patterns afin de d‚terminer les instruments
;	   utilis‚s et ceux inutilis‚s !!! (permet de r‚duire la taille
;	   des modules et les erreurs … l'int‚rieur)
;	- mettre les registres en equr
;	- mettre autres tables de volumes
;	- am‚liorer sortie sonore
;	- param‚trer timer
;	- calculer valeurs timers
;	- stocker plusieurs tables de sons
;	- compter les cycles de chaque routine d'output
;	- faire l'ajustement automatique de tout :
;		fr‚quence->timer->fr‚quences
;	- tout mettre en EQUR dans le replay (lib‚rer D6/D7/A6)
;	- calculer remplissage minimum (‚cart) pour chaque fr‚quence
;	- calculer d‚bordement maximal sur chaque instrument
;	- afficher toutes les informations
;	- g‚n‚rer les boucles
;	- introduire un contr“le strict des modules
;
;	bug GENPC : DBLO
;
;	Replay Protracker 1.1B
;	version ST : 1.7
;	26/04/1992-22/07/1992
;	Amiga optimisation by Mcoder
;	St optimisation by Terence.
;	gestion des samples avec bouclage au bon octet !
;	fr‚quences impl‚ment‚es : 25, 22, 19, 16 ,12 ,9.5, 6.4 khz
;
; version 1.8 : Mcoder 26/03/93
;	  - les volumes sont calcul‚s et non plus stock‚s !!!
;	  - les fr‚quences sont calcul‚es et non plus stock‚es !!!!
; version 1.7 : Mcoder 09/02/93
;		correction bouclage des instruments !!!!
;		correction samples ind‚finis
;		le problŠme ‚tait que le bouclage ‚tait une petite portion
;		 du sample
;		joue les modules 15 et 31 instruments !!!
;	liste des problŠmes existants :
;	  - les modules dont les samples sont … cheval sur 2 samples
;	     sont g‚r‚s de la maniŠre la plus nulle qui soit (on n‚glige
;	     la deuxiŠme partie du sample)
;	  - quelques modules d‚connent encore... (au niveau des effets)
;	  - plus les quelques am‚liorations ci-dessus
; version 1.6 : Mcoder 25/12/92
;		d‚buggage inits (plantait souvent)
;		am‚lioration calcul incr‚ments
;		d‚buggage longueur instruments (nombreux problŠmes)
;		(32Šme instrument,digits>32K,etc...)
;		assigneur de m‚moire pour directement jouer des .MOD
;
; version 1.5 :	am‚lioration du son (bons octets choisis)
;		arrondi fr‚quence a chaque boucle juste
;		table St Replay possible (moins de volume)
;		table sortie YM sur 10 bits
;		19 khz + taille de la boucle
;		deux tables de volume possibles
;		incr‚ments en fin de boucle variables
;
; la BSS n'‚tait pas effac‚e -> plantage !!!
;
;	qualite		nb words jou‚s par VBL (MAX)
;	25		518 dans ADM.MOD
;	22		440
;	19		385
;	16		316
;	12		257
;	9               193
;	6		129
;
; paramŠtres globaux
;
CPU	macro
	cmp.b	#$8F,$fffffc02.w
	bne.s	.\@
	move	#\1,$ffff8240.w
.\@
	endm

	org	$8000

nb_freq=$ff1+1		;nb total fr‚quences utilis‚es
;nb_freq=957		;nb total fr‚quences utilis‚es

equalizer=0		;0=‚qualiseurs
info=0			;0=informations
ecart=800		;pour bouclage digit
float=6			;zone flottante pour digit (words recopi‚s
			; pour ‚viter plantage)
inter=0			;0=interrupt on
qualite=25		;25,22,19,16,12,9,6 else bug !
;
; paramŠtres soundtracker
;
dst=0			;0=table son DST sinon ST replay
nb_bit=10		;‚chantillons 8 bits/10 bits
volume_table=0		;0=table volume GRIFF / table volume normale
	ifeq	volume_table
nonsigne=0
	elseif
nonsigne=1
	endc
taille_volume=65*256
	ifeq	nb_bit-8
taille_sound=256*8
	endc
	ifeq	nb_bit-10
taille_sound=1024*8
	endc

	ifeq	qualite-25		;25600
tailbuf=64*8
frq_data=24
frq_div=4
taille_boucle=64
nbboucles=8
	endc
	ifeq	qualite-22
tailbuf=63*7
frq_data=28
frq_div=4
taille_boucle=63
nbboucles=7
	endc
	ifeq	qualite-19
tailbuf=64*6
frq_data=32
frq_div=4
taille_boucle=64
nbboucles=6
	endc
	ifeq	qualite-16
tailbuf=63*5
frq_data=39
frq_div=4
taille_boucle=63
nbboucles=5
	endc
	ifeq	qualite-12
tailbuf=64*4
frq_data=48
frq_div=4
taille_boucle=64
nbboucles=4
	endc
	ifeq	qualite-9
tailbuf=64*3
frq_data=64
frq_div=4
taille_boucle=64
nbboucles=3
	endc
	ifeq	qualite-6		;6400
tailbuf=64*2
frq_data=96
frq_div=4
taille_boucle=64
nbboucles=2
	endc

	offset	$1000		;obligatoirement multiple de 8
debut_offset:
adr_sound:ds.b	taille_sound
pt_inc:	ds.l	1
compteur:ds.w	1
period0:ds.w	1
period1:ds.w	1
period2:ds.w	1
period3:ds.w	1
fin_offset:
	section	text

	opt	o+

vsync:	macro
	move	sync,d0
.\@:	cmp	sync,d0
	beq.s	.\@
	endm

	move	sr,d0
	and	#$2000,d0
	bne.s	yeah
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
yeah:
	move	#$2700,sr

	lea	pile,sp		;MCODER
	bsr	debug
	move.l	$ffff8200.w,sav8200
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	moveq	#18-1,d0
.savemfp:move.b	(a0),(a1)+
	addq.l	#2,a0
	dbra	d0,.savemfp

	move.l	$70.w,oldvbl
	move.l	$134.w,old134

	move.b	#$40,$fffffa17.w

	clr.b	$fffffa19.w		;Arret Timer A (Reg control)
	clr.b	$fffffa1b.w		;Arret Timer B (Reg control)

	clr.b	$fffffa09.w
	clr.b	$fffffa15.w

	move.l	#shitvbl,$70.w
	move	#$2300,sr
	vsync
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
	move	#$2700,sr

	move.l	#ecrans+255,d0
	clr.b	d0
	move.l	d0,ecran
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	move.l	#shitvbl,$70.w
	move.b	#%00100000,$fffffa07.w
	move.b	#%00100000,$fffffa13.w
	move.l	ecran,a0
	move	#32000/4-1,d0
	moveq	#0,d1
.cls	move.l	d1,(a0)+
	dbra	d0,.cls
	sub.l	ecran,a0
	cmp.l	#32000,a0
	beq.s	.good
	illegal
.good

	lea	debut_offset.w,a0
	lea	push_offset,a1
	move	#fin_offset-debut_offset-1,d0
.push	move.b	(a0)+,(a1)+
	dbra	d0,.push

;	lea	bss,a0
;	lea	fin_bss,a1
;	moveq	#0,d0
;.clrbss
;	move.l	d0,(a0)+
;	cmp.l	a1,a0
;	blo.s	.clrbss
;
;
; calcul des valeurs de fr‚quence
;
	ifeq	info
	move.l	#2457600,d0
	move	#frq_div*frq_data,d1
	bsr	longdiv
	lea	dispfreq2,a0
	bsr	decimal
	endc

	move	#frq_div*frq_data,d0
	move	#$9250,d1	;*$174DE.9250
	mulu	d0,d1
	clr	d1
	swap	d1
	move	#$74de,d2
	mulu	d0,d2
	add.l	d2,d1
	swap	d0
	clr	d0
	add.l	d0,d1
	move.l	d1,d7
	lea	frq1,a0
	moveq	#1,d6
	clr.l	(a0)+		;premiŠre fr‚quence=0
.genfreq
	move.l	d7,d0
	move.l	d6,d1
	bsr	longdiv
	move.l	d0,(a0)+
	addq	#1,d6
	cmp	#nb_freq,d6
	blo.s	.genfreq

	cmp.l	#fin_frq,a0
	beq.s	.same
	illegal
.same
;
; g‚n‚ration de la table de volumes
; passage table volume avec ajout table sound en adr_sound
;
	moveq	#65-1,d4
	moveq	#0,d6
	move.l	#adr_vol+255,d0
	clr.b	d0
	move.l	d0,a0
.gen1	moveq	#0,d2
	moveq	#-128,d3
.gen2	move	d2,d0
	ext	d0
	muls	d6,d0
	lsr	#8,d0
	add.b	d3,d0
	ifeq	nb_bit-8
;transformation de la table de volume
;en donnees 6 bits
	lsr.b	#2,d0
	endc
	asl	#3,d0
	add	#adr_sound/4,d0
	move	d0,(a0)+     ;diff‚rence par rapport au fichier PT_VOLTA.DAT <8
	addq.b	#2,d2
	bne.s	.gen2
	addq	#4,d6
	dbra	d4,.gen1

	ifeq	nb_bit-8
	lea	sound(pc),a0
	move	#256-1,d0
.loop9	move.b	5(a0),d1
	move.b	d1,6(a0)
	move.b	d1,7(a0)
	move.b	4(a0),5(a0)
	addq	#8,a0
	dbra	d0,.loop9
	endc

	ifeq	nb_bit-10
	lea	sound(pc),a0
	move	#1024-1,d0
.loop9:
	move.b	6(a0),7(a0)
	move.b	4(a0),5(a0)
	addq	#8,a0
	dbra	d0,.loop9
	endc

	lea	sound(pc),a0
	lea	adr_sound.w,a1
	move	#taille_sound-1,d0
.loop2:	move.b	(a0)+,(a1)+
	dbf	d0,.loop2

	CPU	$007
	bsr	mt_init			;init soundtracker
	CPU	$070

; procedure d'inits du soundtracker

;copie_frq:
	lea	frq1,a0
	lea	frq_inc,a1
	lea	frq2,a2
	move	#nb_freq-1,d2
.loopl3:
	move.l	(a0)+,d5

	moveq	#taille_boucle,d6
	mulu	d5,d6
	swap	d5
	mulu	#taille_boucle,d5
	swap	d5
	add.l	d6,d5

	moveq	#0,d6
	moveq	#nbboucles-1,d0
	moveq	#0,d4		;precedent
.loopl1:
;	moveq	#taille_boucle-1,d1
;.loopl2:
;	add.l	d5,d6
;	dbf	d1,.loopl2

	add.l	d5,d6
	swap	d6
	sub	d6,d4		;actuel-precedent
	neg	d4
	move	d4,(a1)+
	bpl.s	.nobug
	illegal
.nobug
	move	d6,d4		;reactualise precedent
	swap	d6
	dbf	d0,.loopl1
	swap	d6
	move	d6,(a2)+
	dbf	d2,.loopl3

	cmp.l	#fin_frq,a0
	beq.s	.ok
	illegal
.ok
	cmp.l	#fin_frq_inc,a1
	beq.s	.ok2
	illegal
.ok2

	lea	digit1,a0
	lea	digit2,a1
	move	#tailbuf+float-1,d0
.fill	move	#adr_sound,(a0)+
	move	#adr_sound,(a1)+
	dbra	d0,.fill
	move	#100-1,d0
.fill2
	move	#-1,(a0)+
	move	#-1,(a1)+
	dbra	d0,.fill2

	lea	no_ins,a1		;INIT CORRECTE SINON
	lea	chip1(pc),a0		;SINON CERTAINS MODULES
	moveq	#4-1,d0			;DEMARRENT MAL ...
;
; on peut optimiser ici mais ce sera moins clair (trop de bugs...)
;
.loop7:
	move.l	a1,chip_s_adr(a0)	;sample adr
	clr.l	chip_s_length(a0)	;length en .L
	clr	chip_periode(a0)	;periode
	clr	chip_volume(a0)		;volume
	move.l	a1,chip_loop_start(a0)	;loop start
	clr.l	chip_loop_length(a0)	;loop length
	move.l	a1,chip_start(a0)	;chip_start
	move.l	a1,chip_end(a0)		;chip_end
	ifeq	equalizer
	clr	chip_equal(a0)
	endc
	lea	long_chip(a0),a0
	dbra	d0,.loop7

	lea	digit1,a1
	move.l	a1,usp

;yamaha reset
	lea	$ffff8800.w,a0
	move.l	#$00000000,(a0)
	move.l	#$01010000,(a0)
	move.l	#$02020000,(a0)
	move.l	#$03030000,(a0)
	move.l	#$04040000,(a0)
	move.l	#$05050000,(a0)
	move.l	#$06060000,(a0)
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

	bsr	mt_music
	bsr	precalc_digit

	move.l	#vbl,$70.w
	move.l	#soundchip,$134.w
	clr.b	$fffffa19.w
	move.b	#frq_data,$fffffa1f.w
	ifeq	frq_div-4
	move.b	#1,$fffffa19.w
	else
	fail
	endc

	move	#$2300,sr

	move	#$777,$ffff8242.w
main:
	vsync
	ifne	inter
	CPU	$500
	bsr	precalc_digit
	CPU	$005
	bsr	mt_music
	endc
	clr	$ffff8240.w
	tst.b	bouclage_musique
	beq.s	.nobcl
	move	#$007,$ffff8240.w
.nobcl:
	ifeq	info

	lea	module,a0
	add	offset1,a0
	moveq	#0,d0
	move.b	(a0),d0
	cmp	last3,d0
	beq.s	.same3
	move	d0,last3
	lea	pattern4,a0
	bsr	decimal
	lea	pattern3,a0
	move.l	ecran,a4
	bsr	print
.same3
	moveq	#0,d0
	move.b	mt_songpos,d0
	cmp	last1,d0
	beq.s	.same1
	move	d0,last1
	lea	pattern2,a0
	bsr	decimal
	lea	pattern1,a0
	move.l	ecran,a4
	lea	160*8(a4),a4
	bsr	print
.same1
	move.l	nbwords,d0
	lsr.l	#1,d0
	cmp.l	last2,d0
	beq.s	.same2
	move.l	d0,last2
	lea	words1,a0
	bsr	decimal
	lea	words,a0
	move.l	ecran,a4
	lea	160*16(a4),a4
	bsr	print
.same2
	move.l	bclmin,d0
	cmp.l	last4,d0
	beq.s	.same4
	move.l	d0,last4
	lea	ecart2,a0
	bsr	decimal
	lea	ecart1,a0
	move.l	ecran,a4
	lea	160*24(a4),a4
	bsr	print
.same4
	tst	last6
	beq.s	.freq
	clr	last6
	lea	dispfreq1,a0
	move.l	ecran,a4
	lea	160*32(a4),a4
	bsr	print
.freq
	tst	last5
	beq.s	.name
	clr	last5
	lea	title,a0
	move.l	ecran,a4
	lea	160*40(a4),a4
	bsr	print
	lea	module,a0
	clr.b	20(a0)			;19 ou 20 lettres … afficher ???
	bsr	print
.name
	endc

	ifeq	equalizer
	move.l	ecran,a0
	lea	136*160+48(a0),a0
	lea	chip1+chip_equal,a4
	bsr	affiche_equal
	move.l	ecran,a0
	lea	136*160+16+48(a0),a0
	lea	chip2+chip_equal,a4
	bsr	affiche_equal
	move.l	ecran,a0
	lea	136*160+32+48(a0),a0
	lea	chip3+chip_equal,a4
	bsr	affiche_equal
	move.l	ecran,a0
	lea	136*160+48+48(a0),a0
	lea	chip4+chip_equal,a4
	bsr	affiche_equal

	endc

	cmp.b	#$39,$fffffc02.w
	bne	main

	move	#$2700,sr

	lea	$ffff8800.w,a0
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

	lea	push_offset,a0
	lea	debut_offset.w,a1
	move	#fin_offset-debut_offset-1,d0
.push	move.b	(a0)+,(a1)+
	dbra	d0,.push

	ifne	info
	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w
	move.l	sav8200,$ffff8200.w
	endc

	clr.b	$fffffa19.w
	clr.b	$fffffa1b.w
	clr.b	$fffffa1f.w

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	moveq	#18-1,d0
.restmfp:move.b	(a0)+,(a1)
	addq.l	#2,a1
	dbra	d0,.restmfp

	clr.b	$fffffa1d.w
	move.b	#$c0,$fffffa23.w
	move.b	#$50,$fffffa1d.w

	move.l	oldvbl,$70.w
	move.l	old134,$134.w

.error_clavier:
	moveq.l	#$FFFFFFA1,d0
	and.b	$fffffc00.w,d0
	beq.s	.noerror
	tst.b	$fffffc02.w
	bra.s	.error_clavier
.noerror:
	jmp	$140.w
	move	#$2300,sr
	illegal				;sortie ignoble
bclmin:	dc.l	0
;
; d0/d1
;
longdiv:
	move.l	d0,d2
	clr	d0
	swap	d0
	divu	d1,d0
	bvs.s	.overflow
	move.l	d0,d3
	move	d2,d3
	divu	d1,d3
	bvs.s	.overflow
	swap	d0
	move	d3,d0
	rts
.overflow:
	illegal

	ifeq	equalizer
affiche_equal:
	move	(a4),d0
	beq.s	.nodec
	subq	#1,d0
	move	d0,(a4)
.nodec
	moveq	#0,d4
	add	d0,d0
	add	d0,d0

	move	#eff_equal-here2-64*4,d5
	add	d0,d5
	jmp	here1(pc,d5.w)
here1:
x	set	63*160
	rept	64
	move	d4,x(a0)
x	set	x-160
	endr
	nop
disp_equal:
	moveq	#-1,d4
	lea	64*160(a0),a0
	move	#disp_equal-here1,d5
	sub	d0,d5
	jmp	here2(pc,d5.w)
here2:
x	set	-64*160
	rept	64
	move	d4,x(a0)
x	set	x+160
	endr
eff_equal:
	rts

equal1:	dc.w	0
equal2:	dc.w	0
equal3:	dc.w	0
equal4:	dc.w	0
	endc

	ifeq	info
bouclage_musique:dc.b	0
	even
last3:	dc.w	-1
last1:	dc.w	-1
last2:	dc.l	-1
last4:	dc.l	-1
last5:	dc.w	-1
last6:	dc.w	-1
decimal:
	divu	#10000,d0
	add	#'0',d0
	move.b	d0,(a0)
	clr	d0
	swap	d0
	divu	#1000,d0
	add	#'0',d0
	move.b	d0,1(a0)
	clr	d0
	swap	d0
	divu	#100,d0
	add	#'0',d0
	move.b	d0,2(a0)
	clr	d0
	swap	d0
	divu	#10,d0
	add.l	#$00300030,d0
	move.b	d0,3(a0)
	swap	d0
	move.b	d0,4(a0)
	rts
;
; entr‚e :
;	a0
; used :
;	d0/a0/a4/a5
;
print:
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	.pafini
	rts
.pafini
	sub.b	#' ',d0
	asl	#3,d0
	lea	fonte,a5
	add	d0,a5
x	set	0
	rept	8
	move.b	(a5)+,x(a4)
x	set	x+160
	endr
	addq	#1,a4
	move	a4,d0
	lsr	#1,d0
	bcs.s	print
	addq	#6,a4
	bra.s	print

dispfreq1:dc.b	'FREQUENCE : '
dispfreq2:dc.b	'00000Hz',0
pattern3:dc.b	'NB PATTERNS : '
pattern4:dc.b	'00000',0
pattern1:dc.b	'PATTERN : '
pattern2:dc.b	'00000',0
words:	dc.b	'NB WORDS PLAYES : '
words1:	dc.b	'00000',0
ecart1:	dc.b	'ECART MAX : '
ecart2:	dc.b	'00000',0
title:	dc.b	'TITLE : ',0
	even

	endc
;
; replay Protracker 1.1b
;
;chipx:	variables correspondant aux registres des custom chips AMIGA
	rsreset
chip_s_adr	rs.l	1	;=0		;.l
chip_s_length	rs.l	1	;=4		;.L (MCODER)
chip_periode	rs.w	1	;=8		;.w
chip_volume	rs.w	1	;=10		;.w
chip_loop_start	rs.l	1	;=12	;.l
chip_loop_length:rs.l	1	;=16	;.L (MCODER)
chip_start:	rs.l	1	;MCODER
chip_end:	rs.l	1	;MCODER
	ifeq	equalizer
chip_equal:	rs.w	1
	endc
long_chip:	rs.b	0

;voicex:
	rsreset
n_note	rs.w	1	;.w
n_cmd	rs.b	1	;.w
n_cmdlo	rs.b	1	;.b
n_start	rs.l	1	;.l	start adress of sample
n_length:rs.w	1	;.w	length of sample
n_loopstart:rs.l 1	;.l	repeat start
n_replen:rs.w	1	;.w	repeat length
n_period:rs.w	1	;.w	periode of sample
n_finetune:rs.b	1	;.b
n_volume:rs.b	1	;.b	volume of sample
n_toneportdirec:rs.b 1	;.b
n_toneportspeed:rs.b 1	;.b
n_wantedperiod:rs.w 1	;.w
n_vibratocmd:rs.b 1	;.b
n_vibratopos:rs.b 1	;.b
n_tremolocmd:rs.b 1	;.b
n_tremolopos:rs.b 1	;.b
n_wavecontrol:rs.b 1	;.b
n_glissfunk:rs.b 1	;.b
n_sampleoffset:rs.b 1	;.b
n_pattpos:rs.b	1	;.b
n_loopcount:rs.b 1	;.b
n_funkoffset:rs.b 1	;.b
n_wavestart:rs.l 1	;.l
n_reallength:rs.w 1	;.w
n_long:	rs.b	0

nb_ins:	ds.w	1
offset1:ds.w	1
offset2:ds.w	1
mt_init:
;
; remplissage pour les derniers instruments
;
	lea	mt_samplestarts(pc),a1
	moveq	#32-1,d0
.set0
	move.l	#$480000,(a1)+		;plantage si lecture
	dbra	d0,.set0

	lea	module,a0
	move	#31,nb_ins
	move	#$3B6,offset1
	move	#$43C,offset2

	cmp.l	#'FLT4',$438(a0)
	beq.s	.okmk
	cmp.l	#'M.K.',$438(a0)
	beq.s	.okmk
	move	#15,nb_ins
	move	#$1D6,offset1
	move	#$258,offset2
.okmk
       	move.l	a0,mt_songdataptr
	lea	$3b8-$3b6(a0),a1
	add	offset1,a1
	moveq	#128-1,d0
	moveq	#0,d2
.mtloop:move.b	(a1)+,d1
	cmp.b	d2,d1
	bls.s	.ok1
	move.b	d1,d2
.ok1	dbra	d0,.mtloop
	addq	#1,d2

	lea	mt_samplestarts(pc),a1
	moveq	#10,d0
	asl.l	d0,d2
	add.l	a0,d2
	move.l	d2,a2			;jc
	add	offset2,a2
	move.l	a2,savea2

	lea	20+22(a0),a0
;
; 0(a0)=nb mots instrument
; 4(a0)=loop start
; 6(a0)=loop length
;
	move.l	a2,memfree1		;ptr d‚but
	move.l	a2,memfree2		;ptr fin
	move.l	#instr,memfree3		;ptr libre

	move	nb_ins,d0
	subq	#1,d0
.mtloop3:
	cmp.l	#fin_module,a2
	bls.s	.okl
	illegal				;module trop petit ???
.okl
	cmp	#1,(a0)
	bhi.s	.more
	move.l	#$480000,(a1)+
	bra	.no_reverse
.more
	tst	4(a0)
	beq.s	.allright
	cmp	#1,6(a0)
	bls.s	.allright
	move	4(a0),d1
	cmp	(a0),d1
	bls.s	.noovflow
	illegal				;erreur irr‚cup‚rable :
					; d‚but repeat en dehors du sample
.noovflow
	add	6(a0),d1
	bcs.s	.carry
	cmp	(a0),d1
	bls.s	.allright
.carry
;
; MCODER
;
; tentative de r‚cup‚ration de l'erreur
;
;  la boucle de repeat d‚passe de l'instrument,
;   il suffit de l'ajuster
;
;	illegal
	move	(a0),d1
	sub	4(a0),d1
	move	d1,6(a0)
.allright
	moveq	#0,d1
	move	(a0),d1
	add.l	d1,d1
	bne.s	.not0
	illegal
.not0
	move.l	a0,savea0
	add.l	d1,memfree2

	moveq	#0,d4			;MC
	tst	4(a0)
	beq.s	.noc
	cmp	#1,6(a0)		;MC
	bls.s	.noc			;MC
	move	6(a0),d4		;MC
	add.l	d4,d4			;MC
.noc					;MC

	moveq	#0,d7
	move.l	memfree1,a3
	move.l	memfree2,d2
	sub.l	a3,d2
	sub.l	d4,d2			;MC
	sub.l	#ecart,d2
	cmp.l	d1,d2
	bge.s	.ok
	move.l	memfree3,a3
	moveq	#1,d7
.ok
	move.l	a3,(a1)+
	clr.l	(a2)		;efface les 4 premiers octets

;met les samples au format non sign‚

	move.l	a3,a4
.copie	moveq	#-2,d2
	and.b	(a2)+,d2
	ifne	nonsigne
	eor.b	#$80,d2
	endc
	move.b	d2,(a3)+
	subq.l	#1,d1
	bne.s	.copie

	tst	d7
	bne.s	.lower
	cmp.l	memfree2,a3
	blo.s	.lower
	illegal
.lower

	tst	4(a0)
	beq.s	.recopie_vide
	cmp	#1,6(a0)
	bls.s	.recopie_vide

	moveq	#0,d1
	move	4(a0),d1
	add	6(a0),d1
	cmp	(a0),d1
	bls.s	.okj
	illegal     		;repeat>longueur instrument
.okj

	moveq	#0,d1
	move	4(a0),d1
	add.l	d1,d1
	add.l	d1,a4
	moveq	#0,d1
	move	6(a0),d1	;MC
	add.l	d1,d1		;MC
	add.l	#ecart,d1	;MC

	ifeq	1
.ins	move.l	a4,a5		;MC
	move	6(a0),d3	;MC
	subq	#1,d3		;MC
.ins1	move.b	(a5)+,(a3)+	;MC
	move.b	(a5)+,(a3)+	;MC
	subq.l	#2,d1		;MC
	bls.s	.reverse	;MC
	dbra	d3,.ins1	;MC
	bra.s	.ins		;MC
	endc

	move.l	d1,d4
	moveq	#0,d2
	move	6(a0),d2
	add.l	d2,d2
	divu	d2,d1
	subq	#1,d1
	blo.s	.ins2
.ins1:
	move.l	a4,a5
	move	6(a0),d3
	subq	#1,d3
.ins11:	move.b	(a5)+,(a3)+
	move.b	(a5)+,(a3)+
	subq.l	#2,d4
	dbra	d3,.ins11
	dbra	d1,.ins1
.ins2:	swap	d1
	subq	#1,d1
	blo.s	.ins3
	move.l	a4,a5
.ins22:	move.b	(a5)+,(a3)+
	subq.l	#1,d4
	dbra	d1,.ins22
.ins3:
	tst.l	d4
	beq.s	.noin2
	illegal
.noin2
	bra.s	.reverse

.recopie_vide:
	move	#ecart-1,d1
	ifeq	nonsigne
	moveq.l	#0,d2
	else
	moveq.l	#$FFFFFF80,d2
	endc
.loop5	move.b	d2,(a3)+
	dbra	d1,.loop5
.reverse:
;	move.l	a2,memfree2

	tst	d7
	bne.s	.rev1
	cmp.l	memfree2,a3
	bhi.s	.bug
	move.l	a3,memfree1
	bra.s	.no_reverse
.bug	illegal
.rev1
	move.l	a3,memfree3
.no_reverse:
	lea	30(a0),a0
	dbra	d0,.mtloop3
	cmp.l	#fin_module,a2
	bls.s	.oki
	illegal			;module trop petit ??? bouff‚ ???
.oki
	addq	#7,$ffff8240.w

	lea	no_ins,a0
	move	#ecart-1,d1
	ifeq	nonsigne
	moveq.l	#0,d2
	else
	moveq.l	#$FFFFFF80,d2
	endc
.fill0	move.b	d2,(a0)+
	dbra	d1,.fill0
;
; manquait
;
	lea	digit1,a0
	lea	digit2,a1
	move	#tailbuf+float-1,d0
.setdig	clr	(a0)+
	clr	(a1)+
	dbra	d0,.setdig
	moveq	#100-1,d0
.set3	move	#-1,(a0)+
	move	#-1,(a1)+
	dbra	d0,.set3

	move.l	savea2,a0
	move.l	memfree1,a1
.test	btst	#0,(a0)+
	bne.s	.bug2
	cmp.l	a1,a0
	blo.s	.test
	bra.s	.ok2
.bug2
	illegal
.ok2

	move.b	#6,mt_speed
	clr.b	mt_counter
	clr.b	mt_songpos
	clr	mt_patternpos	;position dans pattern
;
; bugs du player originel :
;
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	clr.b	mt_pbreakflag
	clr.b	mt_lowmask

	clr.b	mt_pattdeltime
	clr.b	mt_pattdeltime2

	rts
savea0:	ds.l	1
nbwords:dc.l	0		;nb words play‚s MAX
savea2:	ds.l	1
memfree1:ds.l	1
memfree2:ds.l	1
memfree3:ds.l	1

mt_music:
	move.l	pt_digit1(pc),a5
	move.l	pt_digit2(pc),pt_digit1
	move.l	a5,pt_digit2

	move.l	usp,a0		;nombre d'octets jou‚s
	move.l	a5,usp
	move.l	a0,d0
	sub.l	pt_digit1(pc),d0
;	blt.s	.bugos
	cmp.l	nbwords,d0
	blo.s	.low
	move.l	d0,nbwords
;.bugos	addq	#7,$ffff8240.w
.low
	subq.b	#1,mt_counter
	bgt.s	mt_nonewnote
	move.b	mt_speed(pc),mt_counter
	tst.b	mt_pattdeltime2
	beq.s	mt_getnewnote
	bsr	mt_nonewallchannels
	bra	mt_dskip

mt_nonewnote:
	bsr	mt_nonewallchannels
	bra	mt_nonewposyet


mt_getnewnote:

	move.l	mt_songdataptr(pc),a0

	lea	12(a0),a3
	lea	$3B8-$3B6(a0),a4	;pattpo
	add	offset1,a4

	add	offset2,a0		;patterndata

	moveq	#0,d0
	moveq	#0,d1
	move.b	mt_songpos(pc),d0
	move.b	(a4,d0.w),d1
	moveq	#10,d5
	asl.l	d5,d1
	add	mt_patternpos(pc),d1
;	clr	mt_dmacontemp

	lea	chip1(pc),a5
	lea	voice1(pc),a6
	bsr.s	mt_playvoice	;voix 1
	bsr.s	mt_playvoice2
	bsr.s	mt_playvoice2
	pea	mt_setdma(pc)
mt_playvoice2:
	lea	long_chip(a5),a5
	lea	n_long(a6),a6

mt_playvoice:
	tst.l	(a6)
	bne.s	.mt_plvskip
	move	n_period(a6),chip_periode(a5)

.mt_plvskip:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	n_cmd(a6),d2
	lsr.b	#4,d2
	and.b	#$f,d2

	moveq	#-$10,d0
	and.b	(a6),d0
	or.b	d0,d2
	beq	mt_setregs

	lea	mt_samplestarts(pc),a4
	move	d2,d4

	subq	#1,d2
	add	d2,d2
	add	d2,d2

	add	d4,d4	;*30
	move	d4,d5
	asl	#4,d4
	sub	d5,d4

	move.l	(a4,d2.w),n_start(a6)
	move	(a3,d4.w),n_length(a6)
	move	(a3,d4.w),n_reallength(a6)
	move.b	2(a3,d4.w),n_finetune(a6)
	move.b	3(a3,d4.w),n_volume(a6)

	move	4(a3,d4.w),d2		;get repeat start
	beq.s	mt_noloop

	move	6(a3,d4.w),n_replen(a6)	;save replen
	cmp	#1,n_replen(a6)
	bhi.s	.ok
	illegal
.ok

	move.l	n_start(a6),d3		;get sample start

	add.l	d2,d2
	add.l	d2,d3			;add repeat start

;	move.l	d3,n_loopstart(a6)
;	move.l	d3,n_wavestart(a6)

	move.l	n_start(a6),d3
	moveq	#0,d2
	move	n_length(a6),d2
	add.l	d2,d2
	add.l	d2,d3
	move.l	d3,n_loopstart(a6)
	move.l	d3,n_wavestart(a6)


	moveq	#0,d0
	move.b	n_volume(a6),d0
	move	d0,chip_volume(a5)	;set volume
	bra.s	mt_setregs

mt_noloop:
	move.l	#no_ins,d2
	move.l	d2,n_loopstart(a6)
	move.l	d2,n_wavestart(a6)
	moveq	#0,d0
	move	d0,n_replen(a6)		;save replen
	move.b	n_volume(a6),d0
	move	d0,chip_volume(a5)	;set volume
mt_setregs:
	move	(a6),d0
	and	#$0fff,d0
	beq	mt_checkmoreefx		;if no note

	move	2(a6),d0
	and	#$0ff0,d0
	cmp	#$0e50,d0
	beq.s	mt_dosetfinetune

	moveq	#$f,d0
	and.b	2(a6),d0

	subq.b	#3,d0			;toneportamento
	beq.s	mt_chktoneporta

	subq.b	#2,d0
	beq.s	mt_chktoneporta

	subq.b	#4,d0			;sample offset
	bne.s	mt_setperiod

	bsr	mt_checkmoreefx
	bra.s	mt_setperiod

mt_dosetfinetune
	bsr	mt_setfinetune
	bra.s	mt_setperiod

mt_chktoneporta
	bsr	mt_settoneporta
	bra	mt_checkmoreefx

mt_setperiod
;	move.l	a4,-(sp)
	move	(a6),d0
	and	#$0fff,d0
	lea	mt_periodtable(pc),a4
	moveq	#36,d6
.mt_ftuloop
	cmp	(a4)+,d0
	dbcc	d6,.mt_ftuloop

	moveq	#0,d0
	move.b	n_finetune(a6),d0

	asl	#3,d0	;*36*2
	add	d0,a4
	asl	#3,d0
	add	d0,a4

	move	-(a4),n_period(a6)
;	move.l	(sp)+,a4
;	lea	-1.w,a4

	move	2(a6),d0
	and	#$0ff0,d0
	cmp	#$0ed0,d0		;notedelay
	beq	mt_checkmoreefx

	btst	#2,n_wavecontrol(a6)
	bne.s	.mt_vibnoc
	clr.b	n_vibratopos(a6)
.mt_vibnoc
	btst	#6,n_wavecontrol(a6)
	bne.s	.mt_trenoc
	clr.b	n_tremolopos(a6)
.mt_trenoc
	ifeq	equalizer
	move	#64,chip_equal(a5)
	endc
	move.l	n_start(a6),chip_s_adr(a5)	;set start
	move.l	n_start(a6),chip_start(a5)	;set start
	moveq	#0,d0
	move	n_length(a6),d0
	cmp	#1,d0
	bhi.s	.zeroins
	move.l	#no_ins,chip_s_adr(a5)
	move.l	#no_ins,chip_start(a5)
	moveq	#0,d0
.zeroins
	add.l	d0,d0
	move.l	d0,chip_s_length(a5)		;set length
	add.l	chip_s_adr(a5),d0	;JC
	move.l	d0,chip_end(a5)		;JC

	move	n_period(a6),chip_periode(a5)	;set period
;	move	n_dmabit(a6),d0
;	or	d0,mt_dmacontemp
	bra	mt_checkmoreefx

mt_setdma:

	lea	chip1(pc),a5
	lea	voice1(pc),a6

	move.l	n_loopstart(a6),chip_loop_start(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
;	cmp	#1,d0
;	bhi.s	.ok1			;MCODER
;	moveq	#0,d0
;.ok1:
	add.l	d0,d0
	move.l	d0,chip_loop_length(a5)
	lea	chip2(pc),a5		;next chip
	lea	n_long(a6),a6

	move.l	n_loopstart(a6),chip_loop_start(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
;	cmp	#1,d0
;	bhi.s	.ok2			;MCODER
;	moveq	#0,d0
;.ok2:
	add.l	d0,d0
	move.l	d0,chip_loop_length(a5)
	lea	chip3(pc),a5		;next chip
	lea	n_long(a6),a6

	move.l	n_loopstart(a6),chip_loop_start(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
;	cmp	#1,d0
;	bhi.s	.ok3			;MCODER
;	moveq	#0,d0
;.ok3:
	add.l	d0,d0
	move.l	d0,chip_loop_length(a5)
	lea	chip4(pc),a5		;next chip
	lea	n_long(a6),a6

	move.l	n_loopstart(a6),chip_loop_start(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
;	cmp	#1,d0
;	bhi.s	.ok4			;MCODER
;	moveq	#0,d0
;.ok4:
	add.l	d0,d0
	move.l	d0,chip_loop_length(a5)

mt_dskip:
	add	#16,mt_patternpos
	move.b	mt_pattdeltime(pc),d0
	beq.s	.mt_dskc

	move.b	d0,mt_pattdeltime2
	clr.b	mt_pattdeltime

.mt_dskc:
	tst.b	mt_pattdeltime2
	beq.s	.mt_dska

	subq.b	#1,mt_pattdeltime2
	beq.s	.mt_dska

	sub	#16,mt_patternpos

.mt_dska:
	tst.b	mt_pbreakflag
	beq.s	mt_nnpysk
	clr.b	mt_pbreakflag

	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	clr.b	mt_pbreakpos
	asl	#4,d0
	move	d0,mt_patternpos
mt_nnpysk
	cmp	#1024,mt_patternpos
	blo.s	mt_nonewposyet
mt_nextposition
	moveq	#0,d0
	move.b	mt_pbreakpos(pc),d0
	asl	#4,d0
	move	d0,mt_patternpos
	clr.b	mt_pbreakpos
	clr.b	mt_posjumpflag
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos(pc),d1
	move.l	mt_songdataptr(pc),a0

	move	offset1,d0
	cmp.b	(a0,d0.w),d1
	blo.s	mt_nonewposyet
	clr.b	mt_songpos
	st	bouclage_musique
mt_nonewposyet
	tst.b	mt_posjumpflag
	bne.s	mt_nextposition
	rts

;
; partie jouant les effets
;

mt_nonewallchannels:

	lea	chip1(pc),a5
	lea	voice1(pc),a6
	bsr.s	mt_checkefx

	lea	chip2(pc),a5
	lea	n_long(a6),a6
	bsr.s	mt_checkefx

	lea	chip3(pc),a5
	lea	n_long(a6),a6
	bsr.s	mt_checkefx

	lea	chip4(pc),a5
	lea	n_long(a6),a6

mt_checkefx:
	bsr	mt_updatefunk

	move	n_cmd(a6),d0
	and	#$fff,d0
	beq.s	mt_pernop

	moveq	#$f,d0
	and.b	n_cmd(a6),d0
	beq.s	mt_arpeggio

	move	d0,d5
	add	d5,d5
	add	d5,d5
	jmp	mt_obra1(pc,d5.w)

mt_obra1:
	bra.w	mt_arpeggio		;0 ok
	bra.w	mt_portaup		;1 ok
	bra.w	mt_portadown		;2 ok
	bra.w	mt_toneportamento	;3 ok
	bra.w	mt_vibrato		;4
	bra.w	mt_toneplusvoaslide	;5
	bra.w	mt_vibratoplusvoaslide	;6
	bra.w	setback7		;7
	bra.w	setback			;8
	bra.w	setback			;9
	bra.w	setback10		;a
	bra.w	setback			;b
	bra.w	setback			;c
	bra.w	setback			;d
	bra.w	mt_e_commands		;e
	;bra.w	setback			;f

setback:
mt_pernop
mt_arpeggio2:
	move	n_period(a6),chip_periode(a5)
	rts

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter(pc),d0
	divs	#3,d0
	swap	d0
	add	d0,d0
	jmp	.arpeg(pc,d0.w)
.arpeg:	bra.s	mt_arpeggio2
	bra.s	mt_arpeggio0
mt_arpeggio1:
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	bra.s	mt_arpeggio3
mt_arpeggio0:
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
mt_arpeggio3:
	add	d0,d0
	moveq	#0,d1
	move.b	n_finetune(a6),d1

	asl	#3,d1	;*36*2
	move	d1,d5
	asl	#3,d1
	add	d5,d1

	lea	mt_periodtable(pc),a0
	add	d1,a0
	move	n_period(a6),d1
	moveq	#36,d6
.mt_arploop:
	cmp	(a0)+,d1		;jc
;	bhs.s	mt_arpeggio4x
;	dbra	d6,.mt_arploop
	dbcc	d6,.mt_arploop
	bhs.s	mt_arpeggio4x

	rts

mt_arpeggio4x:
	move	-2(a0,d0.w),chip_periode(a5)	;jc
	rts

mt_fineportaup:
	tst.b	mt_counter
	bne.s	retup
	move.b	#$0f,mt_lowmask
mt_portaup
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	st	mt_lowmask
	sub	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$0fff,d0
	cmp	#113,d0
	bpl.s	.mt_portauskip
	and	#$f000,n_period(a6)
	or	#113,n_period(a6)
.mt_portauskip:
	move	n_period(a6),d0
	and	#$0fff,d0
	move	d0,chip_periode(a5)
retup	rts

mt_fineportadown:
	tst.b	mt_counter
	bne.s	retdwn
	move.b	#$0f,mt_lowmask
mt_portadown:
	clr	d0
	move.b	n_cmdlo(a6),d0
	and.b	mt_lowmask(pc),d0
	st	mt_lowmask
	add	d0,n_period(a6)
	move	n_period(a6),d0
	and	#$0fff,d0
	cmp	#856,d0
	bmi.s	.mt_portadskip
	and	#$f000,n_period(a6)
	or	#856,n_period(a6)
.mt_portadskip:
	move	n_period(a6),d0
	and	#$0fff,d0
	move	d0,chip_periode(a5)
retdwn	rts

mt_settoneporta:
	pea	(a0)
	move	(a6),d2
	and	#$0fff,d2
	moveq	#0,d0
	move.b	n_finetune(a6),d0

	add	d0,d0	;*2		;*37*2
	move	d0,d5
	add	d0,d0	;*4
	add	d0,d0	;*8
	move	d0,d6
	asl	#3,d0	;*64
	add	d6,d0
	add	d5,d0

	lea	mt_periodtable(pc),a0
	add	d0,a0
	moveq	#0,d0
mt_stploop
	cmp	(a0,d0.w),d2
	bhs.s	mt_stpfound
	addq	#2,d0
	cmp	#37*2,d0
	blo.s	mt_stploop
	moveq	#35*2,d0
mt_stpfound
	moveq	#8,d2
	and.b	n_finetune(a6),d2
	beq.s	mt_stpgoss

	tst	d0
	beq.s	mt_stpgoss
	subq	#2,d0
mt_stpgoss:

	move	(a0,d0.w),d2
	move.l	(a7)+,a0

	move	d2,n_wantedperiod(a6)
	move	n_period(a6),d0
	clr.b	n_toneportdirec(a6)

	cmp	d0,d2
	beq.s	mt_cleartoneporta
	bge.s	.ret
	move.b	#1,n_toneportdirec(a6)
.ret	rts

mt_cleartoneporta
	clr	n_wantedperiod(a6)
mt_return2
	rts

mt_toneportamento
	move.b	n_cmdlo(a6),d0
	beq.s	mt_toneportnochange

	move.b	d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_toneportnochange
	tst	n_wantedperiod(a6)
	beq.s	mt_return2

	moveq	#0,d0
	move.b	n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_toneportaup
mt_toneportadown
	add	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	bgt.s	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)
	bra.s	mt_toneportasetper

mt_toneportaup
	sub	d0,n_period(a6)
	move	n_wantedperiod(a6),d0
	cmp	n_period(a6),d0
	blt.s	mt_toneportasetper
	move	n_wantedperiod(a6),n_period(a6)
	clr	n_wantedperiod(a6)

mt_toneportasetper
	move	n_period(a6),d2
	moveq	#$f,d0
	and.b	n_glissfunk(a6),d0
	beq.s	mt_glissskip

	moveq	#0,d0
	move.b	n_finetune(a6),d0

	asl	#3,d0	;*36*2
	move	d0,d5
	asl	#3,d0
	add	d5,d0

	lea	mt_periodtable(pc),a0
	add	d0,a0
	moveq	#0,d0
mt_glissloop
	cmp	(a0,d0.w),d2
	bhs.s	mt_glissfound
	addq	#2,d0
	cmp	#36*2,d0
	blo.s	mt_glissloop
	moveq	#35*2,d0
mt_glissfound
	move	(a0,d0.w),d2
mt_glissskip
	move	d2,chip_periode(a5)	;set period
	rts

mt_vibrato
	move.b	n_cmdlo(a6),d0
	beq.s	mt_vibrato2

	move.b	n_vibratocmd(a6),d2

	and.b	#$0f,d0
	beq.s	mt_vibskip

	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip
	moveq	#-$10,d0
	and.b	n_cmdlo(a6),d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2
	move.b	d2,n_vibratocmd(a6)
mt_vibrato2
	moveq	#$7f,d0
	and.b	n_vibratopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0

	moveq	#3,d2
	and.b	n_wavecontrol(a6),d2
	beq.s	.mt_vib_sine
	asl.b	#3,d0

	subq.b	#1,d2
	beq.s	.mt_vib_rampdown
	moveq	#-1,d2
	bra.s	.mt_vib_set
.mt_vib_rampdown:
	tst.b	n_vibratopos(a6)
	bpl.s	.mt_vib_rampdown2
	moveq	#-1,d2
	sub.b	d0,d2
	bra.s	.mt_vib_set
.mt_vib_rampdown2
	move.b	d0,d2
	bra.s	.mt_vib_set
.mt_vib_sine
	move.b	0(a4,d0.w),d2
.mt_vib_set
	moveq	#$f,d0
	and.b	n_vibratocmd(a6),d0
	mulu	d2,d0
	lsr	#7,d0
	tst.b	n_vibratopos(a6)
	bpl.s	.pos
	neg	d0
.pos	add	n_period(a6),d0
	move	d0,chip_periode(a5)
	moveq	#$FFFFFFF0,d0
	and.b	n_vibratocmd(a6),d0
	lsr.b	#2,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_toneplusvoaslide
	bsr	mt_toneportnochange
	bra	mt_volumeslide

mt_vibratoplusvoaslide
	bsr.s	mt_vibrato2
	bra	mt_volumeslide

setback7:
	move	n_period(a6),chip_periode(a5)
mt_tremolo
	move.b	n_cmdlo(a6),d0
	beq.s	mt_tremolo2
	move.b	n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip
	moveq	#-$10,d0
	and.b	n_cmdlo(a6),d0
	beq.s	mt_treskip2

	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2
	move.b	d2,n_tremolocmd(a6)
mt_tremolo2
	moveq	#$7f,d0
	and.b	n_tremolopos(a6),d0
	lea	mt_vibratotable(pc),a4
	lsr	#2,d0

	moveq	#$30,d2
	and.b	n_wavecontrol(a6),d2
	lsr.b	#4,d2
	beq.s	mt_tre_sine

	asl.b	#3,d0

	subq.b	#1,d2
	beq.s	mt_tre_rampdown

	moveq	#-1,d2
	bra.s	mt_tre_set

mt_tre_rampdown
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	moveq	#-1,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2
	move.b	d0,d2
	bra.s	mt_tre_set
mt_tre_sine
	move.b	0(a4,d0.w),d2
mt_tre_set
	moveq	#$f,d0
	and.b	n_tremolocmd(a6),d0

	mulu	d0,d2
	lsr	#6,d2
	moveq	#0,d0
	move.b	n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_tremoloneg
	add	d2,d0
	bra.s	mt_tremolo3
mt_tremoloneg
	sub	d2,d0
mt_tremolo3
	bpl.s	mt_tremoloskip
	clr	d0
mt_tremoloskip
	cmp	#$40,d0
	bls.s	mt_tremolook
	moveq	#$40,d0
mt_tremolook
	move	d0,chip_volume(a5)

	move.b	n_tremolocmd(a6),d0
	lsr	#2,d0
	and	#$003c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_sampleoffset
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b	d0,n_sampleoffset(a6)
mt_sononew
	move.b	n_sampleoffset(a6),d0
	asl	#7,d0
	cmp	n_length(a6),d0
	bge.s	mt_sofskip
	sub	d0,n_length(a6)
	add	d0,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip
	move	#$0001,n_length(a6)
	rts

setback10:
	move	n_period(a6),chip_periode(a5)
mt_volumeslide
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	beq.s	mt_voaslidedown
mt_voaslideup
	add.b	d0,n_volume(a6)
	cmp.b	#$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b	#$40,n_volume(a6)
mt_vsuskip
	move.b	n_volume(a6),d0
	move	d0,chip_volume(a5)
	rts

mt_voaslidedown
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
mt_voaslidedown2
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip
	move.b	n_volume(a6),d0
	move	d0,chip_volume(a5)
	rts

mt_positionjump
	move.b	n_cmdlo(a6),d0
	subq.b	#1,d0
	move.b	d0,mt_songpos
	st	bouclage_musique
mt_pj2	clr.b	mt_pbreakpos
	st	mt_posjumpflag
	rts

mt_volumechange
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_volumeok
	moveq	#$40,d0
mt_volumeok
	move.b	d0,n_volume(a6)
	move	d0,chip_volume(a5)
	rts

mt_patternbreak
	moveq	#0,d0
	move.b	n_cmdlo(a6),d0
	moveq	#$f,d2
	and.b	d0,d2

	lsr.b	#4,d0

	add	d0,d0	;*10
	move	d0,d5
	asl	#3,d0
	add	d5,d0

	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b	d0,mt_pbreakpos
	st	mt_posjumpflag
	rts

mt_setspeed
	move.b	3(a6),d0
	beq.s	.ret
	move.b	d0,mt_counter
	move.b	d0,mt_speed
.ret	rts

mt_checkmoreefx
	bsr	mt_updatefunk
	moveq	#$f,d0
	and.b	2(a6),d0

	add	d0,d0			;*****
	add	d0,d0			;jc
	jmp	mt_action1(pc,d0.w)
mt_action1:
	bra.w	mt_pernop		;0
	bra.w	mt_pernop		;1
	bra.w	mt_pernop		;2
	bra.w	mt_pernop		;3
	bra.w	mt_pernop		;4
	bra.w	mt_pernop		;5
	bra.w	mt_pernop		;6
	bra.w	mt_pernop		;7
	bra.w	mt_pernop		;8
	bra.w	mt_sampleoffset		;9
	bra.w	mt_pernop		;a
	bra.w	mt_positionjump		;b
	bra.w	mt_volumechange		;c
	bra.w	mt_patternbreak		;d
	bra.w	mt_e_commands		;e
	bra.w	mt_setspeed		;f
					;**************
mt_e_commands
	move	#$f0,d0
	and.b	n_cmdlo(a6),d0
	lsr.b	#4,d0
	add	d0,d0			;***********
	add	d0,d0			;jcm
	jmp	mt_action2(pc,d0.w)
mt_action2:
	bra.w	mt_filteronoff		;0
	bra.w	mt_fineportaup		;1
	bra.w	mt_fineportadown	;2
	bra.w	mt_setglisscontrol	;3
	bra.w	mt_setvibratocontrol	;4
	bra.w	mt_setfinetune		;5
	bra.w	mt_jumploop		;6
	bra.w	mt_settremolocontrol	;7
	rts				;8
	nop
	bra.w	mt_retrignote		;9
	bra.w	mt_volumefineup		;a
	bra.w	mt_volumefinedown	;b
	bra.w	mt_notecut		;c
	bra.w	mt_notedelay		;d
	bra.w	mt_patterndelay		;e
	bra.w	mt_funkit		;f

mt_setglisscontrol
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	and.b	#$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
mt_filteronoff:				;no filter on st !
	rts

mt_setvibratocontrol
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	and.b	#$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_setfinetune
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	move.b	d0,n_finetune(a6)
	rts

mt_jumploop
	tst.b	mt_counter
	bne.s	.ret
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	beq.s	.mt_setloop

	tst.b	n_loopcount(a6)
	beq.s	.mt_jumpcnt
	subq.b	#1,n_loopcount(a6)
	beq.s	.ret
.mt_jmploop
	move.b	n_pattpos(a6),mt_pbreakpos
	st	mt_pbreakflag
.ret	rts

.mt_jumpcnt
	move.b	d0,n_loopcount(a6)
	bra.s	.mt_jmploop

.mt_setloop
	move	mt_patternpos(pc),d0
	lsr	#4,d0
	move.b	d0,n_pattpos(a6)
	rts

mt_settremolocontrol
	move.b	n_cmdlo(a6),d0			;jcm
	asl.b	#4,d0
	and.b	#$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_retrignote
	move.l	d1,-(sp)
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	beq.s	.mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
	bne.s	.mt_rtnskp
	move	(a6),d1
	and	#$0fff,d1
	bne.s	.mt_rtnend
	moveq	#0,d1
	move.b	mt_counter(pc),d1
.mt_rtnskp
	divu	d0,d1
	swap	d1
	tst	d1
	bne.s	.mt_rtnend
.mt_doretrig
	ifeq	equalizer
	move	#64,chip_equal(a5)
	endc
	move.l	n_loopstart(a6),chip_s_adr(a5)
	move.l	n_loopstart(a6),chip_start(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
	cmp	#1,d0
	bhi.s	.zeroins
	move.l	#no_ins,chip_s_adr(a5)
	move.l	#no_ins,chip_start(a5)
	moveq	#0,d0
.zeroins
	add.l	d0,d0
	move.l	d0,chip_s_length(a5)
	add.l	chip_s_adr(a5),d0	;JC
	move.l	d0,chip_end(a5)		;JC
.mt_rtnend
	move.l	(sp)+,d1
	rts

mt_volumefineup
	tst.b	mt_counter
	bne.s	.ret
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	bra	mt_voaslideup
.ret	rts

mt_volumefinedown
	tst.b	mt_counter
	bne.s	.ret
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	bra	mt_voaslidedown2
.ret	rts

mt_notecut
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	cmp.b	mt_counter(pc),d0
	bne.s	.ret
	clr.b	n_volume(a6)
	clr	chip_volume(a5)
.ret	rts

mt_notedelay
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	cmp.b	mt_counter(pc),d0
	bne.s	.ret
	move	(a6),d0
	beq.s	.ret

	ifeq	equalizer
	move	#64,chip_equal(a5)
	endc
	move.l	n_loopstart(a6),chip_s_adr(a5)
	move.l	n_loopstart(a6),chip_start(a5)
	moveq	#0,d0
	move	n_replen(a6),d0
	cmp	#1,d0
	bhi.s	.zeroins
	moveq	#0,d0
	move.l	#no_ins,chip_s_adr(a5)
	move.l	#no_ins,chip_start(a5)
.zeroins
	add.l	d0,d0
	move.l	d0,chip_s_length(a5)
	add.l	chip_s_adr(a5),d0	;JC
	move.l	d0,chip_end(a5)		;JC
.ret	rts

mt_patterndelay
	tst.b	mt_counter
	bne.s	.ret
	moveq	#$f,d0
	and.b	n_cmdlo(a6),d0
	tst.b	mt_pattdeltime2
	bne.s	.ret
	addq.b	#1,d0
	move.b	d0,mt_pattdeltime
.ret	rts

mt_funkit
	tst.b	mt_counter
	bne.s	.ret
	move.b	n_cmdlo(a6),d0		;jc
	asl.b	#4,d0
	and.b	#$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	bne.s	mt_updatefunk
.ret	rts

mt_updatefunk:
	moveq	#0,d0
	move.b	n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	.mt_funkend
	move.b	mt_funktable(pc,d0.w),d0
	add.b	d0,n_funkoffset(a6)
;	tst.b	n_funkoffset(a6)	;jc
	bge.s	.mt_funkend
	clr.b	n_funkoffset(a6)

	move.l	d1,-(sp)		;jc
	pea	(a0)			;jc
	move.l	n_loopstart(a6),d0
	moveq	#0,d1
	move	n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	move.l	n_wavestart(a6),a0
	addq.l	#1,a0
	cmp.l	d0,a0
	blo.s	.mt_funkok
	move.l	n_loopstart(a6),a0
.mt_funkok
	move.l	a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b	d0,(a0)
	move.l	(sp)+,a0		;jc
	move.l	(sp)+,d1		;jc
.mt_funkend
	rts

precalc_digit:

generev:macro
	move	\2+chip_periode(pc),d6
	cmp	#nb_freq,d6
	blo.s	.lower\@
;	illegal
	tst	d6
	bmi.s	.correct\@
	illegal
.correct\@
	moveq	#0,d6
.lower\@
	add	d6,d6
	move	d6,d5  		;p‚riode
	add	d5,d5		;fois 4
	lea	frq1,a4
	move.l	(a4,d5.w),d4	;frq
	lea	frq2,a4
	move	(a4,d6.w),\3	;periode * 315

	mulu	#nbboucles,d6	;sorry for this multiplication
				;but it's needed for various frequency
				;implementation

; 5 increments de fin de rept
	lea	frq_inc,a4
	lea	increments_boucle+\4(pc),a5
	add.l	d6,a4		;.L bug corrig‚ !!!!
	cmp.l	#fin_frq_inc,a4
	blo.s	.low\@
	illegal
.low\@
n	set	8
	move	(a4)+,(a5)
	rept	nbboucles-1
	move	(a4)+,n(a5)
n	set	n+8
	endr

	lea	\1,a0
	move.l	#$8000,d3	;1/2
;	move.l	#0,d3
	add	d4,d3
	swap	d3
	swap	d4
n	set	0
	rept	taille_boucle-1
	addx.l	d4,d3
	move	d3,n(a0)
n	set	n+34
	endr
	endm

	generev	auto+2(pc),chip1,period0.w,0
	generev	auto+2+8(pc),chip2,period1.w,2
	generev	auto+2+16(pc),chip3,period2.w,4
	generev	auto+2+24(pc),chip4,period3.w,6

	move	sr,d0
	move	#$2700,sr
	lea	$ffff8800.w,a3
	move.l	usp,a2
	move.l	a3,usp
	move.l	#soundchip3,$134.w
	move	d0,sr

;	a0=buffer digit
;	a1=adr volume
;	a2=PLAYER

;	a3=adr ins v1
;	a4=adr ins v2
;	a5=adr ins v3
;	a6=adr ins v4

;	d0=accumulateur
;	d1=>PLAYER
;	d2=>PLAYER
;	d3=volume v1
;	d4=volume v2
;	d5=volume v3
;	d6=volume v4
;	d7=

;fill_digit:
	move.l	#module,$280.w		;pour d‚buggage !!!!
	move.l	#fin_module,$284.w
	move.l	#no_ins,$288.w
	move.l	memfree1,$28c.w

	move.l	#increments_boucle,pt_inc.w

	move.l	pt_digit1(pc),a0

	move.l	#adr_vol+255,d0
	clr.b	d0
	move.l	d0,a1

	move.l	chip1(pc),a3
	move.l	chip2(pc),a4
	move.l	chip3(pc),a5
	move.l	chip4(pc),a6

	moveq	#0,d0

	moveq	#0,d3
	move	chip1+chip_volume(pc),d3
	asl	#8,d3
	add.l	a1,d3

	moveq	#0,d4
	move	chip2+chip_volume(pc),d4
	asl	#8,d4
	add.l	a1,d4

	moveq	#0,d5
	move	chip3+chip_volume(pc),d5
	asl	#8,d5
	add.l	a1,d5

	moveq	#0,d6
	move	chip4+chip_volume(pc),d6
	asl	#8,d6
	add.l	a1,d6

	move	#nbboucles,compteur.w
loop_c1:

	move.b	(a3),d3			;2	8
	move.l	d3,a1			;2	4
	move	(a1),d0			;2	8

	move.b	(a4),d4			;2	8
	move.l	d4,a1			;2	4
	add	(a1),d0			;2	8

	move.b	(a5),d5			;2	8
	move.l	d5,a1			;2	4
	add	(a1),d0			;2	8

	move.b	(a6),d6			;2	8
	move.l	d6,a1			;2	4
	add	(a1),d0			;2	8

	move	d0,(a0)+		;2=26	12=92

auto:
	rept	taille_boucle-1		;octets	cycles

	move.b	1(a3),d3		;4	12
	move.l	d3,a1			;2	4
	move	(a1),d0			;2	8

	move.b	1(a4),d4		;4	12
	move.l	d4,a1			;2	4
	add	(a1),d0			;2	8

	move.b	1(a5),d5		;4	12
	move.l	d5,a1			;2	4
	add	(a1),d0			;2	8

	move.b	1(a6),d6		;4	12
	move.l	d6,a1			;2	4
	add	(a1),d0			;2	8

	move	d0,(a0)+		;2=34	12=108
	endr

	move.l	pt_inc.w,a1		;16
	add	(a1)+,a3		;12
	add	(a1)+,a4		;12
	add	(a1)+,a5		;12
	add	(a1)+,a6		;12
	move.l	a1,pt_inc.w		;16

	subq	#1,compteur.w
	bgt	loop_c1

	rept	float
	move	d0,(a0)+		;2=40	12=108
	endr

; d4,d5,d6

bouclage:macro
	move.l	chip_s_adr(a3),a0
	add.l	d4,a0			;avancee de l'adr du sample

	cmp.l	chip_start(a3),a0
	bhs.s	.na\@
	illegal
.na\@
	move.l	chip_s_length(a3),d0	;length
	sub.l	d4,d0			;new length
	ble.s	.aa\@

	cmp.l	#no_ins,a0
	beq.s	.\@pas_loop1
	cmp.l	chip_end(a3),a0		;MCODER
	blo.s	.\@pas_loop1
	illegal
.aa\@
	cmp.l	chip_end(a3),a0		;MCODER
	bhs.s	.nb\@
	illegal
.nb\@
	move.l	d0,d5			;d‚passement
	neg.l	d5			;dans le buffer de bouclage

	cmp.l	bclmin,d5
	bls.s	.sam\@
	move.l	d5,bclmin
.sam\@

	move.l	chip_loop_start(a3),a0	;MCODER
	move.l	a0,chip_start(a3)
	add.l	chip_loop_length(a3),a0	;MCODER
	move.l	a0,chip_end(a3)		;MCODER

	move.l	chip_loop_start(a3),a0
	add.l	d5,a0			;restart + depassement
	move.l	chip_loop_length(a3),d4
	bne.s	.\@m2
	lea	no_ins,a0
	moveq	#0,d0

	move.l	a0,chip_start(a3)
	move.l	a0,chip_end(a3)		;MCODER
	bra.s	.\@okv1
.\@m1:
 	sub.l	d4,a0
.\@m2:
 	add.l	d4,d0			;compensation du depassement n fois
 	blt.s	.\@m1
.\@okv1:
.\@pas_loop1:
	move.l	d0,chip_s_length(a3)
	move.l	a0,chip_s_adr(a3)

	cmp.l	chip_start(a3),a0
	bhs.s	.nc\@
	illegal
.nc\@
	cmp.l	chip_end(a3),a0
	bls.s	.nd\@
	illegal
.nd\@
	endm

	lea	chip1(pc),a3
	moveq	#0,d4
	move	period0.w,d4
	bouclage
	lea	chip2(pc),a3
	moveq	#0,d4
	move	period1.w,d4
	bouclage
	lea	chip3(pc),a3
	moveq	#0,d4
	move	period2.w,d4
	bouclage
	lea	chip4(pc),a3
	moveq	#0,d4
	move	period3.w,d4
	bouclage

	move	sr,d0
	move	#$2700,sr
	move.l	a2,usp
	cmp.l	#digit1,a2
	blo.s	.err
	lea	$ffff8800.w,a1
	move.l	#soundchip,$134.w
	move	d0,sr
	rts
.err	illegal

;	a0=buffer digit
;	a1=adr volume
;	a2=PLAYER
;	a3=adr ins v1
;	a4=save buffer digit
;	a5=incr virgule
;	a6=

;	d0=accumulateur
;	d1=>PLAYER
;	d2=>PLAYER
;	d3=volume
;	d4=pos entier
;	d5=pos virgule
;	d6=incr entier
;	d7=PLAYER


;gestion yamaha 2149
;
; d1/a1/a2/d7/usp
;
soundchip:
	move.l	usp,a2		;4
	move	(a2)+,d7	;8
	move.l	a2,usp		;4
	move	d7,a2		;4
	move.l	(a2)+,d7	;12
	move.l	(a2),(a1)	;20
	movep.l	d7,(a1)		;24=100
	rte

soundchip_intro:
	move.l	a2,-(sp)
	move.l	usp,a2		;4
	move	(a2)+,d7	;8
	move.l	a2,usp		;4
	move	d7,a2		;4
	move.l	(a2)+,d7	;12
	move.l	(a2),(a1)	;20
	movep.l	d7,(a1)		;24=100
	move.l	(sp)+,a2
	rte

soundchip5:
	movem.l	d7/a1-a2,-(sp)
	move.l	usp,a2		;4
	move	(a2)+,d7	;8
	move.l	a2,usp		;4
	move	d7,a2		;4
	move.l	(a2)+,d7	;12
	lea	$ffff8800.w,a1
	move.l	(a2),(a1)	;20
	movep.l	d7,(a1)		;24=100
	movem.l	(sp)+,d7/a1-a2
	rte

soundchip3:
	move.l	a1,d2		;4
	move	(a2)+,a1	;8
;	move	d1,a1		;4
	move.l	(a1)+,d1	;12
	move.l	(a1),d7		;12
	move.l	usp,a1		;4
	move.l	d7,(a1)		;1+4=16
	movep.l	d1,(a1)		;24+4=28	108
	move.l	d2,a1		;4
	rte

sound:
	ifeq	nb_bit-10
	incbin	d:/rip/sndtrk/quarfast.tab
	endc
	ifeq	nb_bit-8
	ifne	dst
	include	d:/rip/sndtrk/streplay.s
	elseif
	incbin	d:/rip/sndtrk/table1.dst
	endc
	endc
	even


vbl:
	ifeq	inter
	movem.l	d0/d4/d5/a0/a4/a5,-(sp)
	CPU	$500
	bsr	precalc_digit
	CPU	$005
	bsr	mt_music
;	move	#0,$ffff8240.w
	movem.l	(sp)+,d0/d4/d5/a0/a4/a5
	endc
shitvbl:
	addq	#1,sync
	rte

	section	data
;
; variables sound tracker
;
mt_funktable:
	dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_vibratotable
	dc.b	000,024,049,074,097,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,097,074,049,024
	even
mt_periodtable
; tuning 0, normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114
;
voice1:	ds.b	n_long
voice2:	ds.b	n_long
voice3:	ds.b	n_long
voice4:	ds.b	n_long

mt_samplestarts:ds.l	32

mt_songdataptr	dc.l	-1	;0

mt_patternpos	dc.w	-1	;0 OK
;mt_dmacontemp	dc.w	-1	;0 ???? … quoi ‡a sert ??? inutilis‚ !!!
mt_speed	dc.b	-1	;6 OK
mt_counter	dc.b	-1	;0 OK
mt_songpos	dc.b	-1	;0 OK
mt_pbreakpos	dc.b	-1	;0 OK
mt_posjumpflag	dc.b	-1	;0 OK
mt_pbreakflag	dc.b	-1	;0 OK
mt_lowmask	dc.b	-1	;0 OK
mt_pattdeltime	dc.b	-1	;0
mt_pattdeltime2	dc.b	-1	;0
		even

chip1:	ds.b	long_chip
chip2:	ds.b	long_chip
chip3:	ds.b	long_chip
chip4:	ds.b	long_chip

pt_digit1:	dc.l	digit2
pt_digit2:	dc.l	digit1

increments_boucle:ds.w	nbboucles*4	;5 increments et 4 voies

debug:	incbin	d:/lib68000/debugger.bin

	ifeq	info
fonte:	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666
	dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800
	dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818
	dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000
	dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000
	dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800
	dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818
	dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00
	dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C
	dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00
	dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818
	dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000
	dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E
	dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00
	dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C
	dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00
	dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606
	dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00
	dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666
	dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600
	dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818
	dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800
	dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C
	dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00
	dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36
	dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800
	dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60
	dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00
	dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C
	dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C
	dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F
	dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00
	dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66
	dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00
	dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B
	dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78
	dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818
	dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800
	endc

module:
;	incbin	e:/modules/rebels1.mod		;testeur player
;	incbin	e:/modules/delta.mod
	incbin	f:/modules2/xenomix.mod
;
; le DC.L suivant est obligatoire parce qu'il existe certains modules
;  qui ont perdu 4 octets … la fin !!!
;  maintenant c'est corrig‚ par la moulinette DIRMOD !!!
;
;	even				;even inutile grƒce … DIRMOD
;	dc.l	0

fin_module:
	section	bss
	even

frq1:	ds.l	nb_freq
fin_frq:
frq2:	ds.w	nb_freq
frq_inc:ds.w	nb_freq*nbboucles	;16 khz
fin_frq_inc:
adr_vol:ds.b	taille_volume+255
	even
ecran:	ds.l	1
sync:	ds.w	1
savcol:	ds.w	16
oldmfp	ds.b	18
oldvbl:	ds.l	1
old134:	ds.l	1
sav8200:ds.l	1

	ds.l	100
pile:
push_offset:ds.b fin_offset-debut_offset
ecrans:	ds.b	32000+255
	even
digit1:	ds.w	tailbuf+float+100
digit2:	ds.w	tailbuf+float+100
no_ins:	ds.b	ecart
instr:
	end
