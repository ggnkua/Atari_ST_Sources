;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;  player v1.00 -RealSound-
;  CODED BY NEW-FACE/EXA	 
;
;   -op‚re en 255 voix (en th‚orie)
;   -Utilise les MODULES .RSP (Real Sound Player)	 
;   -Cette routine utilise le DSP en interruption ainsi elle ne 
;	bloque pas ce dernier et utilise trŠs peu de place memoire.
;   -le sequenceur utilise tous les effects du PROTRACKER (v 3.01).
; 	Cependant certains n'ont pas ‚t‚ test‚s...
;   ...	
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;	opt =nb_voix in var

pl_data			equ	1	;fichier player.lib en data ou source ?...	
	ifeq	pl_data
offset	equ	0
	else
offset	equ	$1c	;offset d'un prg.
	endc
preloc			equ	0+offset
pinit_module		equ	4+offset
pinit_first_time	equ	8+offset
pinit_int		equ	12+offset
pend_player		equ	16+offset
pload_dsp_prg		equ	20+offset
info_module		equ	24+offset	;pointeur sur la structure suivante {

;	playing	  	 rs.b	2	;octet poids fort utilis‚
;	inc_volume	 rs.b	2	;(0< v >=$100)	
;	volume_general	 rs.b	2	
;	mix_voice_table	 rs.b	32	;pour chaque octet correspond chaque voie
;					{bit 0 =0 mixage a gauche
;					       =1 mixage a droite 
;					 bit 1 =gestion interne
;					=-1 => pas de voies
;	pour chaque voie	rs.b	32
;				{ rs.b	2 =volume
;				{ rs.b	30 =gestion interne	
;}	


start_rsnd

	clr.l	-(sp)
	move	#32,-(sp)	;superviser
	trap	#1
	addq.l	#6,sp



	ifne	pl_data
	jsr	start_player+preloc	;reloge le player
	endc





	lea	module(pc),a0
	jsr	start_player+pinit_module	;initialise le module



						;dans a3 = fin du module (apres precalcule de celui ci)
	tst	d0				;-1 header non trouv‚	;-2 mauvaise version
	bmi	no_fine_rs_module




	jsr	start_player+pinit_first_time   ;initialise table pour la premiere fois (et derniere).
	jsr	start_player+pinit_int		;installe interruption.



	
	move.l	start_player+info_module,a1
	clr.w	4(a1)	;volume a 0
	move.w	#1,2(a1)	;on fait un pti fade volume en fixant l'increment
	sf	(a1)	;enable playing
	move.l	#$01000100,6(a1)	;regles les 8 voies
	move.l	#$01000100,10(a1)

;	programme d'exemple d'un transfert DSP tout bete ....


	lea	test_prg(pc),a0			;Adresse et taille de notre
	move.l	#size/3,d0			;programme exemple au !! DSP !!.
	jsr	start_player+pload_dsp_prg	;charge le prog DSP




;---------------------------------------------------------

kl
.loop	btst	#1,$ffffa202.w
	beq.s	.loop		;dsp pret?

revient
	move.l	#80*20,d0
	move.l	$44e,a0		;on balance a l'ecran
	move.l	d0,$fffffa204.w
	subq	#1,d0
lost
	move.l	$ffffa204.w,(a0)+		;transfert BOURRIN !!
	dbf	d0,lost				;tout est TRANSPARENT !!!
	cmp.b	#$39,$fffffc02.w
	bne.s	kl

;---------------------------------------------------------


	move.w	#-2,2(a1)	;on fait un pti fade volume en fixant l'increment
.no_nul_vol
	tst	4(a1)
	bne.s	.no_nul_vol




	st	(a1)	;disable playing


	
	jsr	start_player+pend_player	;coupe tout et remet le son.




no_fine_rs_module

	clr.l	-(sp)
	trap	#1


	ifne	pl_data
start_player	incbin 	player.prg
	else
		include player.lib
	endc	


	section	data

test_prg	incbin	essai.p56
size	equ	*-test_prg
	even
module		incbin	varanen.rsp
