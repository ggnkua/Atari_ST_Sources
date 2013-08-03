;	STrEet fighter II
;	V 0.93	21 juillet 1994
;	Code by Patrice Mandin / DATA

;	V 0.6  version standard
;	v 0.7  programme externe pour les personnages
;	v 0.8  test collision : pas de cache de donn‚es
;	v 0.81 detection falcon : ok pour le cache
;	v 0.82 impacts
;	v 0.83 limites de l'ecran
;	v 0.84 defense / attaque
;	v 0.85 modif gestion collision
;	v 0.9  barres d'energie
;	v 0.91 visualisation impacts
;	v 0.92 bruitages
;	v 0.93 scrolling differentiel dans le sol
		
	output	e:\patrice\sf2_ste.tos

true	equ	-1
false	equ	0

pausecontrol	equ	false
timecontrol	equ	false
debugmode	equ	false
twoplayers	equ	false
scroldif	equ	true

screenwidth	equ	640
base_sautopp_y	equ	100
base_y	equ	187	 ; bas du sprite
new_nrj	equ	103

base_p1_x	equ	screenwidth/2-22 ; centre du sprite
base_dnew1	equ	-1

base_p2_x	equ	screenwidth/2+22 ; centre du sprite
base_dnew2	equ	0
	
	include	gemdos.s
	include	xbios.s
	
	TEXT

	SETBLOCK	#pile

	move.l	#screenwidth*200/2,memoryused
	MALLOC	#screenwidth*200/2
	move.l	d0,ecran1
	beq	error1
	add.l	#screenwidth*200/2,memoryused
	MALLOC	#screenwidth*200/2
	move.l	d0,ecran2
	beq	error2

; -------------	Relogement des routines joueur 1

	lea	player1,a0
	move.l	2(a0),d0
	add.l	6(a0),d0
	move.l	d0,d1
	add.l	14(a0),d0
	
	lea	28(a0),a0
	lea	(a0,d0.l),a1
	
	lea	28+player1,a2	; adr relogement
	add.l	(a1)+,a0
	move.l	a2,d1
	add.l	d1,(a0)
	moveq	#0,d0

go_reloge	move.b	(a1)+,d0
	tst.b	d0
	beq.s	go_finreloge
	cmp.b	#1,d0
	beq.s	go_incadr
	add	d0,a0
	move.l	a2,d1
	add.l	d1,(a0)
	bra.s	go_reloge
go_incadr	lea	254(a0),a0
	bra.s	go_reloge

go_finreloge	lea	player1,a0
	move.l	28(a0),vbl_joueur1
	move.l	32(a0),seq_joueur1
	move.l	36(a0),adr_sprites1
	
; -------------	Initialisation buffers

	move.l	adr_sprites1,a0
	moveq	#0,d2	; taille a reserver

go_init	move.l	(a0)+,d0
	beq.s	go_stopcalc
	move.l	d0,a1
	moveq	#0,d0
	move	(a1),d0
	move	d0,d1
	and	#15,d1
	beq.s	go_mult16
	add	#16,d0
	and	#-16,d0
go_mult16	
	lsr	#1,d0
	mulu	2(a1),d0
	add.l	d0,d2
	bra.s	go_init

go_stopcalc	add.l	d2,memoryused
	MALLOC	d2
	move.l	d0,symetrie2	; idem pour joueur 2
	move.l	d0,symetrie1
	beq	error3
	move.l	d0,a0
	move.l	d2,d0
	lsr	#1,d0
clear_symbuf	clr	(a0)+
	subq.l	#1,d0
	bne.s	clear_symbuf

	lsr.l	#2,d2
	add.l	d2,memoryused
	MALLOC	d2
	move.l	d0,mask2	; idem pour joueur 2
	move.l	d0,mask1
	beq	error4
	move.l	d0,a0
	lsr	#1,d2
clear_mskbuf	clr	(a0)+
	subq.l	#1,d2
	bne.s	clear_mskbuf

	IFEQ	debugmode
	move.l	memoryused,d0
	lea	chars,a0
	lea	memused,a1
	moveq	#5,d3
	moveq	#12,d2
boucle_mem1	move.l	d0,d1
	rol.l	d2,d1
	and	#15,d1
	move.b	(a0,d1),(a1)+
	addq	#4,d2
	dbra	d3,boucle_mem1

	MALLOC	#-1
	lea	chars,a0
	lea	memfree,a1
	moveq	#5,d3
	moveq	#12,d2
boucle_mem2	move.l	d0,d1
	rol.l	d2,d1
	and	#15,d1
	move.b	(a0,d1.w),(a1)+
	addq	#4,d2
	dbra	d3,boucle_mem2
	CCONWS	#usermessage
	CCONIN

; ------------- Ecran

	SUPEXEC	#falcon_test
	
	tst	falcon
	beq.s	ste

	VSETMODE	#-1
	move	d0,d7
	move	d0,-(sp)
	move	#3,-(sp)
	SETINTERRUPT	#INT_TIMERA,#INT_PLAY
	SOUNDCMD	#SETPRESCALE,#CCLK_12K
	DEVCONNECT	#DMAPLAY,#DAC,#CLK_25M,#CLK_COMPAT,#NO_SHAKE
	bra.s	start_demo

ste	clr	-(sp)
	GETREZ
	move	d0,-(sp)

start_demo	LOGBASE
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move	#5,-(sp)
	and	#VGA+PAL,d7
	or	#STMODES+BPS4,d7
	btst	#4,d7
	beq.s	notvga
	or	#VERTFLAG,d7
notvga	VSETMODE	d7
	;SETSCREEN	#-1,#-1,#0
	ENDC
	
	SUPEXEC	#go
	
	IFEQ	debugmode
	trap	#14
	lea	14(sp),sp
	ENDC
	
	MFREE	mask1
error4	MFREE	symetrie1
error3	MFREE	ecran2
error2	MFREE	ecran1
error1	PTERM0

	IFEQ	debugmode
usermessage	dc.b	27,"H","<< STrEet fighter II >>",13,10
	dc.b	"----- V. 0.93 Demo -----",13,10
	dc.b	"21 juillet 1994",13,10,13,10
	dc.b	"Cod‚ par Patrice Mandin",13,10,13,10,13,10,13,10
	dc.b	"Utiliser joysticks et clavier : ",13,10
	dc.b	"            P1        |       P2",13,10
	dc.b	"      Bas  Moyen Fort | Bas  Moyen Fort",13,10
	dc.b	"Poing  7     8     9  |  A     Z     E",13,10
	dc.b	"Pied   4     5     6  |  Q     S     D",13,10,13,10
	
	dc.b	"RAM utilis‚e : "
memused	ds.b	6
	dc.b	13,10
	dc.b	"RAM libre    : "
memfree	ds.b	6
	dc.w	0

chars	dc.l	"0123","4567","89AB","CDEF"
	ENDC

; -------------	Test falcon

falcon_test	clr	falcon
	move.l	$5a0.w,d0
	beq.s	f30_end
	move.l	d0,a0
f30_search	cmp.l	#'_MCH',(a0)
	bne.s	f30_not_found
	cmp	#3,4(a0)
	bne.s	f30_not_found
	move	#-1,falcon
f30_not_found	addq	#8,a0
	tst.l	(a0)
	bne.s	f30_search
f30_end	rts

; -------------	Initialisations sprites et masques

;	taille x.W,y.W
;	adr.L du masque
;	adr.L du symetrique
;	adr.L du masque
;	taille x.W,y.W
;	donn‚es du sprite

; -----	Sym‚trie

go	move.l	adr_sprites1,a0
	move.l	symetrie1,a2
go_symetrie	move.l	(a0)+,d0
	beq	go_stopsym
	move.l	d0,a1	; a1 donn‚es sprite
	move.l	a2,8(a1)	; a2 adr sym

	lea	20(a1),a3	; init
	move	(a1),d0
	move	d0,d1
	and	#15,d1
	beq.s	go_symbs
	add	#16,d0
	and	#-16,d0
go_symbs	move	d0,18(a1)
	moveq	#0,d7
	move	d0,d7
	sub	(a1),d7
	add.l	#$02038000,d7
	move	d0,d6
	lsr	#4,d6
	addq	#1,d6
	swap	d6
	move	2(a1),d6
	move	d7,d4
	and	#15,d4
	move	#$ffff,d5
	lsr	d4,d5
	moveq	#-8,d4
	swap	d4
	move	d0,d4
	move	d0,d3
	lsr	#1,d3
	lea	-8(a2,d3),a5
	
	moveq	#3,d0	; recopie invers‚e des mots
go_symblit	lea	$ffff8a20.w,a4
	move.l	#$80000,(a4)+
	move.l	a3,(a4)+
	move	d5,(a4)+
	move.l	#$ffff0000,(a4)+
	move.l	d4,(a4)+
	move.l	a5,(a4)+
	move.l	d6,(a4)+
	move.l	d7,(a4)
	BLTWAIT	2(a4)

	addq	#2,a3
	addq	#2,a5
	dbra	d0,go_symblit

	move	18(a1),d0	; symetrie des bits
	lsr	#2,d0
	mulu	2(a1),d0
	subq	#1,d0
	move.l	a2,a3
	
go_symbit	move	(a3),d1
	moveq	#7,d2
go_symbit1	addx	d1,d1
	roxr	#1,d3
	addx	d1,d1
	roxr	#1,d3
	dbra	d2,go_symbit1
	move	d3,(a3)+
	dbra	d0,go_symbit

	move	18(a1),d0	; suivant
	lsr	#1,d0
	mulu	2(a1),d0
	add	d0,a2
	bra	go_symetrie

; -----	Masque

go_stopsym	move.l	adr_sprites1,a0
	move.l	mask1,a2
go_masque	move.l	(a0)+,d0
	beq	go_stopmask

	move.l	d0,a1	; a1 donn‚es sprite
	move	(a1),d0
	move	d0,16(a1)
	move	18(a1),d1
	lsr	#4,d1
	addq	#1,d1
	move	d1,(a1)
	swap	d1
	move	2(a1),d1	; d1=(x+1)|y
	move.l	d1,d2

	move.l	a2,4(a1)	; adr masque
	lea	20(a1),a3	; adr sprite
	moveq	#3,d0
go_mskblit1	lea	$ffff8a20.w,a4
	move.l	#$00080000,(a4)+
	move.l	a3,(a4)+
	move.l	#$ffffffff,(a4)+
	clr	(a4)+
	move.l	#$00020000,(a4)+
	move.l	a2,(a4)+
	move.l	d1,(a4)+
	move.l	#$2078000,(a4)
	BLTWAIT	2(a4)

	addq	#2,a3
	dbra	d0,go_mskblit1 

	swap	d1
	subq	#1,d1
	add	d1,d1
	mulu	2(a1),d1
	add	d1,a2

	move.l	a2,12(a1)	; adr masque symetrique
	move.l	8(a1),a3	; adr sprite symetrique
	moveq	#3,d0
go_mskblit2	lea	$ffff8a20.w,a4
	move.l	#$00080000,(a4)+
	move.l	a3,(a4)+
	move.l	#$ffffffff,(a4)+
	clr	(a4)+
	move.l	#$00020000,(a4)+
	move.l	a2,(a4)+
	move.l	d2,(a4)+
	move.l	#$2078000,(a4)
	BLTWAIT	2(a4)

	addq	#2,a3
	dbra	d0,go_mskblit2
	add	d1,a2
	move	2(a1),18(a1)
	bra	go_masque

; -------------	Init ecrans

go_stopmask	lea	$ffff8a20.w,a0
	move.l	#$00020000,(a0)+
	move.l	#ecran_save,(a0)+
	move.l	#$ffffffff,(a0)+
	clr	(a0)+
	move.l	#$00020000,(a0)+
	move.l	ecran1,(a0)+
	move.l	#$00a100c8,(a0)+
	move.l	#$02038000,(a0)
	BLTWAIT	2(a0)

	lea	$ffff8a20.w,a0
	move.l	#$00020000,(a0)+
	move.l	#ecran_save,(a0)+
	move.l	#$ffffffff,(a0)+
	clr	(a0)+
	move.l	#$00020000,(a0)+
	move.l	ecran2,(a0)+
	move.l	#$00a100c8,(a0)+
	move.l	#$02038000,(a0)
	BLTWAIT	2(a0)

; -------------	Init barres d'energie

	lea	energie_save,a0
	lea	energie,a1
	moveq	#3,d0
bcl_initpower	
	lea	$ffff8a20.w,a3	; transfere les barres
	move.l	#$00080008,(a3)+
	move.l	a0,(a3)+
	move.l	#$ffffffff,(a3)+
	move	#$ffff,(a3)+
	move.l	#$00080008,(a3)+
	move.l	a1,(a3)+
	move.l	#$000e0010,(a3)+
	move.l	#$02038000,(a3)
	BLTWAIT	2(a3)

	lea	$ffff8a20.w,a3	; fait le masque
	move.l	#$00080008,(a3)+
	move.l	a0,(a3)+
	move.l	#$ffffffff,(a3)+
	move	#$ffff,(a3)+
	move.l	#$00020002,(a3)+
	move.l	#energie_mask,(a3)+
	move.l	#$000e0010,(a3)+
	move.l	#$02078000,(a3)
	BLTWAIT	2(a3)

	addq	#2,a0
	addq	#2,a1
	dbra	d0,bcl_initpower

; -------------	Init impact

	lea	imp0_save,a0
	lea	imp0_mask,a1
	bsr	init_impact

	lea	imp1_save,a0
	lea	imp1_mask,a1
	bsr	init_impact

	lea	imp2_save,a0
	lea	imp2_mask,a1
	bsr	init_impact
	bra	init_inters
	
init_impact	lea	$ffff8a28.w,a3
	move.l	#$ffffffff,(a3)+
	move	#$ffff,(a3)+
	move.l	#$00020002,(a3)+
	move.l	a1,(a3)+
	move.l	#$00020020,(a3)+
	move.l	#$00008000,(a3)
	BLTWAIT	2(a3)
	
	moveq	#3,d0
bcl_impact
	lea	$ffff8a20.w,a3	; fait le masque
	move.l	#$00080008,(a3)+
	move.l	a0,(a3)+
	move.l	#$ffffffff,(a3)+
	move	#$ffff,(a3)+
	move.l	#$00020002,(a3)+
	move.l	a1,(a3)+
	move.l	#$00020020,(a3)+
	move.l	#$02078000,(a3)
	BLTWAIT	2(a3)

	addq	#2,a0
	dbra	d0,bcl_impact

	rts
	
; -------------	Init interruptions

init_inters
	IFEQ	debugmode
	move	#$2700,sr
	lea	$fffffa00.w,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(sp)
	lea	$ffff8240.w,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(sp)
	move.l	$70.w,-(sp)
	move.l	$118.w,-(sp)
	move.l	$134.w,-(sp)

	move.b	#$14,$fffffc02.w ; joy mode
	;clr.l	$fffffa06.w	 ; no its
	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w
	move.l	#vbl,$70.w
	move.l	#ikbd,$118.w

	move.l	#timera,$134.w
	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	move.b	#8,$fffffa19.w
	move.b	#1,$fffffa1f.w

	lea	palette,a0
	lea	$ffff8260.w,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(a1)
	ENDC

	IFNE	pausecontrol
	clr	pause
	ENDC

; ------------- Init ecrans

	move	#160,ecrx
	clr	ecran_flag
	move.l	ecran1,ecr_travail
	move.l	ecran2,ecr_affiche
	clr	imp_vbls
	clr	imp_aff_x
	clr	imp_aff_y

; ------------- Init son

	clr	snd_flag

	move.l	#snd_buf0,d0

	lea	$ffff8900.w,a0
	move.b	d0,$07(a0)
	ror	#8,d0
	move.l	d0,$02(a0)
	ror	#8,d0

	add.l	#4,d0

	move.b	d0,$13(a0)
	ror	#8,d0
	move.l	d0,$0e(a0)

	move.b	#1,$21(a0)

	lea	$ffff8a28.w,a0
	move.l	#$ffffffff,(a0)+
	move	#$ffff,(a0)+
	move.l	#$00020002,(a0)+
	move.l	#snd_buf0,(a0)+
	move.l	#250*65536+1,(a0)+
	move.l	#$00008000,(a0)
	BLTWAIT	2(a0)

	lea	$ffff8a28.w,a0
	move.l	#$ffffffff,(a0)+
	move	#$ffff,(a0)+
	move.l	#$00020002,(a0)+
	move.l	#snd_buf1,(a0)+
	move.l	#250*65536+1,(a0)+
	move.l	#$00008000,(a0)
	BLTWAIT	2(a0)

; ------------- Init joueur 1

	clr	bord1
	clr	collision1
	clr	seq_vbl1
	clr	seq_cpt1
	clr	touche1
	move.l	vbl_joueur1,seq_cur1
	move.l	seq_joueur1,seq_spr1
	move	#base_p1_x,x_new1
	move	#base_y,y_new1
	move	#base_dnew1,d_new1
	move	#(base_p1_x+base_p2_x)/2-screenwidth/4,minecrx1
	move	#(base_p1_x+base_p2_x)/2+screenwidth/4,maxecrx1
	move	#new_nrj,energie1
	move	#103,old_nrj1
	clr	touche1
	clr	last_bt1
	clr	attack1
	clr	defense1

	move.l	seq_spr1,a0
	move.l	(a0),a0
	move	x_new1,x_sav11
	move	y_new1,y_sav11
	move.l	16(a0),t_sav11
	move	x_new1,x_sav12
	move	y_new1,y_sav12
	move.l	16(a0),t_sav12
	clr.l	snd_adr1
	move.l	#-1,snd_res1

; ------------- init joueur 2

	clr	bord2
	clr	collision2
	clr	seq_vbl2
	clr	seq_cpt2
	clr	touche2
	
	move.l	vbl_joueur1,seq_cur2
	move.l	seq_joueur1,seq_spr2
	move	#base_p2_x,x_new2
	move	#base_y,y_new2
	move	#base_dnew2,d_new2
	move	minecrx1,minecrx2
	move	maxecrx1,maxecrx2
	move	#new_nrj,energie2
	move	#103,old_nrj2
	clr	touche2
	clr	attack2
	clr	defense2
	clr	last_bt2

	move.l	seq_spr2,a0
	move.l	(a0),a0
	move	x_new2,x_sav21
	move	y_new2,y_sav21
	move.l	16(a0),t_sav21
	move	x_new2,x_sav22
	move	y_new2,y_sav22
	move.l	16(a0),t_sav22
	clr.l	snd_adr2
	move.l	#-1,snd_res2

; -------------	Boucle principale

	move.b	#3,$ffff8901.w
	stop	#$2300

init_boucle
	IFEQ	debugmode
	tst	vbl_sync
	beq.s	init_boucle
	clr	$ffff8240.w
	ENDC
	
	lea	save11,a6
	lea	save21,a5
	tst	ecran_flag
	beq.s	nodemo
	lea	save12,a6
	lea	save22,a5
nodemo	move.l	a6,quoi1
	move.l	a5,quoi2

; -------------	Restaure fond

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$420,$ffff8240.w
	ENDC
	ENDC

	bsr	restaure_nrj
	bsr	restaure_impact

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$642,$ffff8240.w
	ENDC
	ENDC

	lea	x_new1,a5	; sprite 1
	move.l	quoi1,a6
	bsr	restaure_fond

	lea	x_new2,a5	; sprite 2
	move.l	quoi2,a6
	bsr	restaure_fond

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$531,$ffff8240.w
	ENDC
	ENDC

	IFNE	scroldif
	bsr	scroll_dif
	ENDC

; -------------	Nouveau sprite a afficher

	move.l	seq_spr1,a1
	lea	x_new1,a5
	move.l	quoi1,a6
	bsr	new_sprite

	move.l	seq_spr2,a1
	lea	x_new2,a5
	move.l	quoi2,a6
	bsr	new_sprite

; -------------	Affiche masque + sprite

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$246,$ffff8240.w
	ENDC
	ENDC

	move.l	seq_spr1,a1	; joueur 2 attaque
	move.b	4(a1),d0
	and	#$7f,d0
	bne.s	pl1_attack
	
	lea	cx1,a2
	lea	x_new1,a5
	move.l	quoi1,a6
	bsr	affiche_spr
	lea	cx2,a2
	lea	x_new2,a5
	move.l	seq_spr2,a1
	move.l	quoi2,a6
	bsr	affiche_spr
	bra.s	pl2_attack

pl1_attack	lea	cx2,a2
	lea	x_new2,a5
	move.l	seq_spr2,a1	; joueur 1 attaque
	move.l	quoi2,a6
	bsr	affiche_spr
	lea	cx1,a2
	lea	x_new1,a5
	move.l	seq_spr1,a1
	move.l	quoi1,a6
	bsr	affiche_spr
pl2_attack

; ------------- Test de collision

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$462,$ffff8240.w
	ENDC
	ENDC

	bsr	collision_test

	tst	falcon
	beq.s	col_ste
	movec	cacr,d0
	move	d0,-(sp)
	bclr	#8,d0
	movec	d0,cacr
col_ste
	move	colflag,collision1
	move	colflag,collision2
	
;	IFNE	timecontrol
;	move	#$050,$ffff8240.w
;	tst	colflag
;	beq.s	no_coll_2_spr
;	move	#$f00,$ffff8240.w
;no_coll_2_spr
;	ENDC
	
	tst	falcon
	beq.s	col_ste1
	move	(sp)+,d0
	movec	d0,cacr
col_ste1
	
; -------------	Affiche l'impact si a lieu

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$426,$ffff8240.w
	ENDC
	ENDC

	bsr	affiche_impact

; -------------	Affiche la barre d'energie

	IFEQ	debugmode
	IFNE	timecontrol
	move	#$204,$ffff8240.w
	ENDC
	ENDC

	moveq	#0,d1

	move	x_new1,d0
	bpl.s	hsc_xn1mi
	moveq	#0,d0
hsc_xn1mi	cmp	#screenwidth,d0
	bmi.s	hsc_xn1ma
	move	#screenwidth,d0
hsc_xn1ma	move	x_new2,d1
	bpl.s	hsc_xn2mi
	moveq	#0,d1
hsc_xn2mi	cmp	#screenwidth,d1
	bmi.s	hsc_xn2ma
	move	#screenwidth,d1
hsc_xn2ma
	add	d1,d0
	lsr	#1,d0
	sub	#screenwidth/4,d0
	bpl.s	vbl_nonegos
	moveq	#0,d0
vbl_nonegos	cmp	#screenwidth/2,d0
	bmi.s	vbl_noposos
	move	#screenwidth/2,d0
vbl_noposos	
	move	d0,minecrx1
	move	d0,minecrx2
	add	#screenwidth/2,d0
	move	d0,maxecrx1
	move	d0,maxecrx2
	sub	#screenwidth/2,d0

	move	d0,ecrx
	bsr	affiche_nrj

; -------------	Hardscroll

	IFEQ	debugmode
	IFNE	timecontrol
	clr	$ffff8240.w
	ENDC
	ENDC

	move	#screenwidth/8,linewid

	moveq	#0,d1
	move	ecrx,d0
	move	d0,d1
	and	#-16,d1
	lsr	#1,d1
	add.l	ecr_travail,d1
	and	#15,d0
	beq.s	vbl_nohsc0
	sub	#4,linewid
vbl_nohsc0	move	d0,hscroll
	ror	#8,d1
	move.l	d1,$ffff8200.w
	ror	#8,d1
	move.b	d1,$ffff820d.w

; -------------	C'est parti pour un autre tour

	move.l	ecran1,ecr_travail
	move.l	ecran2,ecr_affiche
	not	ecran_flag
	beq.s	init_nochgecr
	move.l	ecran2,ecr_travail
	move.l	ecran1,ecr_affiche
init_nochgecr
	clr	vbl_sync

	tst.b	$39+clavier
	beq	init_boucle
	
; -------------	Restaurations

	move	#$2700,sr
	move.b	#8,$fffffc02.w
	clr.b	$ffff8901.w
	clr	$ffff820e.w
	clr	$ffff8264.w

	move.l	(sp)+,$134.w
	move.l	(sp)+,$118.w
	move.l	(sp)+,$70.w
	lea	$ffff8260.w,a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(a0)
	lea	$fffffa20.w,a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(a0)
	move	#$2300,sr

init_videkbd	btst.b	#0,$fffffc00.w
	beq.s	init_fin
	move.b	$fffffc02.w,d0
	bra.s	init_videkbd
init_fin	rts	
	
; ------------------------------
;	Restaure fond
; ------------------------------

restaure_fond	lea	ecran_save,a0
	move.l	ecr_travail,a1

	moveq	#0,d0	; d0 adresse ecran
	move	y_sav11-save11(a6),d0
	sub	2+t_sav11-save11(a6),d0
	bpl.s	restaure_miny
	moveq	#0,d0
restaure_miny	mulu	#screenwidth/2,d0 ; offset y
	add.l	d0,a0
	add.l	d0,a1

	moveq	#0,d0
	move	x_sav11-save11(a6),d0
	move	minecrx1-x_new1(a5),d1
	cmp	d1,d0
	bpl.s	restaure_minx
	move	d1,d0
restaure_minx	move	maxecrx1-x_new1(a5),d1
	sub	t_sav11-save11(a6),d1
	cmp	d1,d0
	bmi.s	restaure_maxx
	move	d1,d0
restaure_maxx	and	#-16,d0
	lsr	#1,d0	; offset x
	add.l	d0,a0
	add.l	d0,a1

	move.l	#$20002+screenwidth/2,d0
	move	t_sav11-save11(a6),d1
	add	#32,d1
	and	#-16,d1
	lsr	#1,d1
	sub	d1,d0

	move.l	t_sav11-save11(a6),d1
	swap	d1
	and	#-16,d1
	lsr	#2,d1
	addq	#8,d1
	swap	d1

	lea	$ffff8a20.w,a2
	move.l	d0,(a2)+
	move.l	a0,(a2)+
	move.l	#$ffffffff,(a2)+
	move	#$ffff,(a2)+
	move.l	d0,(a2)+
	move.l	a1,(a2)+
	move.l	d1,(a2)+
	move.l	#$02038000,(a2)
	BLTWAIT	2(a2)
	rts
	
; ------------------------------
; 	Nouveau sprite
; ------------------------------

new_sprite	move.l	(a1),a0
	move.l	16(a0),t_sav11-save11(a6)
	move	d_new1-x_new1(a5),d_sav11-save11(a6)
	move	16(a0),d1
	lsr	#1,d1
	move	x_new1-x_new1(a5),d0
	sub	d1,d0
	move.b	6(a1),d1
	ext	d1
	tst	d_new1-x_new1(a5)
	beq.s	xnewtoleft
	add	d1,d0
	bra.s	xnewtoboth
xnewtoleft	sub	d1,d0
xnewtoboth	move	d0,x_sav11-save11(a6)
	move	y_new1-x_new1(a5),d0
	move.b	7(a1),d1
	ext	d1
	add	d1,d0
	move	d0,y_sav11-save11(a6)
	rts

; ------------------------------
;	Affiche mask & sprite	
; ------------------------------

affiche_spr	move.l	ecr_travail,a0	; Adresse ecran affichage

	btst.b	#7,4(a1)	; Symetrie du sprite ?
	sne	d1
	ext	d1
	move	d_sav11-save11(a6),d0
	eor	d0,d1

	move.l	(a1),a1	; Adresse donn‚es du sprite

	lea	20(a1),a4	; Adresse du sprite
	move.l	4(a1),a3	; et de son masque
	tst	d1
	beq.s	mskspr_nosym
	move.l	8(a1),a4	; Symetriques
	move.l	12(a1),a3
mskspr_nosym	
	move.l	a3,cadr1-cx1(a2) ;  collision
	move	t_sav11-save11(a6),clx1-cx1(a2)
	move	2+t_sav11-save11(a6),cly1-cx1(a2)

	moveq	#0,d0
	move.l	(a1),d6
	move	y_sav11-save11(a6),d0
	ble	fin_affiche
	sub	2+t_sav11-save11(a6),d0
	move	d0,cy1-cx1(a2) ; collision
	move	d0,d2
	tst	d0
	bpl.s	deb_affiche

	add	d0,d6	
	swap	d6
	move	d6,d2
	swap	d6
	subq	#1,d2
	lsl	#3,d2
	move	d0,d3
	neg	d3
	mulu	d3,d2
	add	d2,a4
	lsr	#2,d2
	add	d2,a3
	moveq	#0,d0
deb_affiche	
	mulu	#screenwidth/2,d0
	add.l	d0,a0
	clr	bord1-x_new1(a5)
	move	x_sav11-save11(a6),d0
	move	minecrx1-x_new1(a5),d1
	cmp	d1,d0
	bpl.s	print_minx
	move	#-1,bord1-x_new1(a5)
	move	d1,d0
print_minx	move	maxecrx1-x_new1(a5),d1
	sub	t_sav11-save11(a6),d1
	cmp	d1,d0
	bmi.s	print_maxx
	move	#-1,bord1-x_new1(a5)
	move	d1,d0
print_maxx	
	move	d0,cx1-cx1(a2)	; collision
	move	d0,d3
	and	#-16,d0
	lsr	#1,d0
	add	d0,a0

	moveq	#0,d1
	moveq	#0,d2
	move	(a1),d2
	subq	#1,d2
	lsl	#3,d2
	move.l	#$80000+screenwidth/2,d1
	sub	d2,d1

	move	d3,d2
	and	#15,d2
	moveq	#-1,d3
	lsr	d2,d3
	move	d3,d4
	not	d4
	move.l	d2,d5
	swap	d3
	add.l	#$02048000,d2
	add.l	#$02078000,d5
	
;	Masque

	moveq	#3,d0
printmask_spr	lea	$ffff8a20.w,a2
	move.l	#$20000,(a2)+	; x,y src
	move.l	a3,(a2)+	; adr src
	move.l	d3,(a2)+	; msk left+mid
	move	d4,(a2)+	; msk right
	move.l	d1,(a2)+	; x,y dst
	move.l	a0,(a2)+	; adr dst
	move.l	d6,(a2)+	; size
	move.l	d2,(a2)	; run blt
	BLTWAIT	2(a2)
	
;	Sprite

	lea	$ffff8a20.w,a2
	move.l	#$80000,(a2)+
	move.l	a4,(a2)+
	move.l	d3,(a2)+
	move	d4,(a2)+
	move.l	d1,(a2)+
	move.l	a0,(a2)+
	move.l	d6,(a2)+
	move.l	d5,(a2)
	BLTWAIT	2(a2)

	addq	#2,a0
	addq	#2,a4
	dbra	d0,printmask_spr

fin_affiche	rts	

; ----------------------------------------------
;	Test de collision
; ----------------------------------------------
; pour les deux sprites : 	cadr(n) : adr du masque
;		cx(n)   : posx du sprite
;		cy(n)   : posy du sprite
;		clx(n)  : largeur du sprite
;		cly(n)  : hauteur du sprite

collision_test	clr	colflag

; -- Collision verticale ?

	move	cy1,d0
	cmp	cy2,d0
	bhi.s	no_colver1
	add	cly1,d0
	cmp	cy2,d0
	bls.s	no_colver1
	clr	csy2
	move	cy2,d0
	sub	cy1,d0
	move	d0,csy1
	move	cly1,d1
	sub	d0,d1
	bra.s	col_ver

no_colver1	move	cy2,d0
	cmp	cy1,d0
	bhi	no_collision
	add	cly2,d0
	cmp	cy1,d0
	bls	no_collision
	clr	csy1
	move	cy1,d0
	sub	cy2,d0
	move	d0,csy2
	move	cly2,d1
	sub	d0,d1

col_ver	cmp	cly1,d1
	ble.s	colver_ty1
	move	cly1,d1
colver_ty1	cmp	cly2,d1
	ble.s	colver_ty2
	move	cly2,d1
colver_ty2	move	d1,cty

; -- Collision horizontale ?

	move	cx1,d0
	cmp	cx2,d0
	bhi.s	no_colhor1
	add	clx1,d0
	cmp	cx2,d0
	bls.s	no_colhor1
	clr	csx2
	move	cx2,d0
	sub	cx1,d0
	move	d0,csx1
	move	clx1,d1
	sub	d0,d1
	bra.s	col_hor

no_colhor1	move	cx2,d0
	cmp	cx1,d0
	bhi	no_collision
	add	clx2,d0
	cmp	cx1,d0
	bls	no_collision
	clr	csx1
	move	cx1,d0
	sub	cx2,d0
	move	d0,csx2
	move	clx2,d1
	sub	d0,d1

col_hor	cmp	clx1,d1
	ble.s	colhor_tx1
	move	clx1,d1
colhor_tx1	cmp	clx2,d1
	ble.s	colhor_tx2
	move	clx2,d1
colhor_tx2	move	d1,ctx

;	d2 = midmask , rightmask
;	d3 = largeur du bloc intersection en mots

	moveq	#-1,d2
	move	ctx,d3
	move	d3,d0
	neg	d0
	and	#15,d0
	beq.s	col_initcopy
	add	#16,d3
	and	#-16,d3

col_initcopy	lsl	d0,d2
	lsr	#4,d3

; -------------	Copie sprite 1 dans buffer

	lea	cx1,a0
	move.l	#$02038000,d0	; dest = source
	bsr	col_blitter
	
; -------------	And sprite 2 dans buffer

	lea	cx2,a0
	move.l	#$02018000,d0	; dest = source and dest
	bsr	col_blitter

; -------------	Or buffer dans flag

	moveq.l	#-1,d1
	move	ctx,d4
	neg	d4
	and	#15,d4
	lsl	d4,d1
	moveq.l	#-1,d2

	move	d3,d0
	cmp	#1,d0
	bne.s	col_1wrdwide
	move	d1,d2
col_1wrdwide	swap	d0
	move	cty,d0

	lea	$ffff8a20.w,a0
	move.l	#$00020002,(a0)+
	move.l	#collision,(a0)+
	move	d2,(a0)+
	move.l	d1,(a0)+
	clr.l	(a0)+
	move.l	#colflag,(a0)+
	move.l	d0,(a0)+
	move.l	#$02078000,(a0)
	BLTWAIT	2(a0)

no_collision	rts

; ------------------------------
;	Blitter ops.
; ------------------------------

col_blitter	moveq	#2,d5
	swap	d5
	move	clx1-cx1(a0),d5
	move	d5,d1
	and	#15,d1
	beq.s	col_nomind5
	add	#16,d5
	and	#-16,d5
col_nomind5	lsr	#3,d5
	move	d5,d4	; d4 taille 1 ligne source
	sub	d3,d5
	sub	d3,d5	; d5 sxyinc

	move.l	cadr1-cx1(a0),a1
	mulu	csy1-cx1(a0),d4
	add	d4,a1
	move	csx1-cx1(a0),d1
	and	#-16,d1
	lsr	#3,d1
	add	d1,a1	; a1 adresse source
	
	lea	collision-2,a2	; a2 adresse destination
	moveq	#0,d4	; d4 leftmask
	move	d3,d6	; d6 taille x et y
	addq	#1,d6
	move.l	#$00020000,d7	; d7 dxyinc

	move	csx1-cx1(a0),d1
	neg	d1
	and	#15,d1
	tst	d1
	bne.s	col_bltna15
	addq	#2,a2
	addq	#2,d5
	moveq	#-1,d4
	addq	#2,d7
	subq	#1,d6
	cmp	#1,d6
	bne.s	col_bltna15
	move	d2,d4

col_bltna15	swap	d6
	move	cty,d6
	or	d1,d0	; d0 blitter ops
	
	lea	$ffff8a20.w,a3
	move.l	d5,(a3)+
	move.l	a1,(a3)+
	move	d4,(a3)+
	move.l	d2,(a3)+
	move.l	d7,(a3)+
	move.l	a2,(a3)+
	move.l	d6,(a3)+
	move.l	d0,(a3)
	BLTWAIT	2(a3)
	
	rts

; ---------------------------------------------------------
;	Barres d'energie
; ---------------------------------------------------------

restaure_nrj	lea	ecran_save+4*320+24,a0
	move.l	ecr_travail,a2
	lea	4*320+24(a2),a2
	
	move	ecrx,d0
	sub	#16,d0
	bpl.s	rest_nrj_ok1
	moveq	#0,d0
rest_nrj_ok1	and	#-16,d0
	lsr	#1,d0
	add	d0,a0
	add	d0,a2

	lea	$ffff8a20.w,a1
	move.l	#$00020002+320-272/2,(a1)+
	move.l	a0,(a1)+
	move.l	#$ffffffff,(a1)+
	move	#$ffff,(a1)+
	move.l	#$00020002+320-272/2,(a1)+
	move.l	a2,(a1)+
	move.l	#$00440010,(a1)+
	move.l	#$02038000,(a1)
	BLTWAIT	2(a1)
	rts

; -------------	Affiche les barres

affiche_nrj	

; ------------- Joueur 1

aff_nrj_p1	move	energie1,d0
	cmp	old_nrj1,d0
	beq	aff_nrj_p2
	move	d0,old_nrj1
	
	lea	energie+4*224*4/8,a1
	moveq	#103,d1
	sub	d0,d1

	moveq	#-1,d2
	move	#$8000,d3
	move	d1,d5
	and	#15,d5
	asr	d5,d3
	cmp	#15,d1
	bpl.s	aff_nrj_min1
	move	d3,d2
	swap	d2
aff_nrj_min1
	and	#$fff0,d1
	lsr	#4,d1
	addq	#1,d1

	move.l	#$00080008+224*4/8,d4
	move	d1,d5
	lsl	#3,d5
	sub	d5,d4
	
	moveq	#8,d0
	swap	d0
	move	d1,d0
	swap	d0
	move.l	d0,d1
	
	moveq	#10,d7
	moveq	#3,d0
aff_blt_p1	
	moveq	#1,d6
	ror.l	#1,d6
	lsr	#1,d7
	bcc.s	aff_nrj_pln01
	move	#$000f,d6
aff_nrj_pln01	swap	d6
	
	lea	$ffff8a28.w,a2
	move.l	d2,(a2)+
	move	d3,(a2)+
	move.l	d4,(a2)+
	move.l	a1,(a2)+
	move.l	d1,(a2)+
	move.l	d6,(a2)	
	BLTWAIT	2(a2)

	addq	#2,a1
	dbra	d0,aff_blt_p1

; ------------- Joueur 2

aff_nrj_p2	move	energie2,d0
	cmp	old_nrj2,d0
	beq	aff_barres
	move	d0,old_nrj2
	
	lea	energie+4*224*4/8,a1
	move	d0,d1
	add	#120,d1
	and	#$fff0,d1
	lsr	#1,d1
	add	d1,a1

	move	d0,d1
	add	#120,d1
	moveq	#-1,d2
	moveq	#-1,d3
	and	#15,d1
	lsr	d1,d2

	moveq	#103,d1
	sub	d0,d1
	move	d1,d0
	lsr	#4,d1
	addq	#1,d1

	move.l	#$00080008+224*4/8,d4
	move	d1,d5
	lsl	#3,d5
	sub	d5,d4
	
	moveq	#8,d0
	swap	d0
	move	d1,d0
	swap	d0
	move.l	d0,d1
	
	moveq	#10,d7
	moveq	#3,d0
aff_blt_p2	
	moveq	#1,d6
	ror.l	#1,d6
	lsr	#1,d7
	bcc.s	aff_nrj_pln02
	move	#$000f,d6
aff_nrj_pln02	swap	d6
	
	lea	$ffff8a28.w,a2
	move	d2,(a2)+
	move.l	d3,(a2)+
	move.l	d4,(a2)+
	move.l	a1,(a2)+
	move.l	d1,(a2)+
	move.l	d6,(a2)	
	BLTWAIT	2(a2)

	addq	#2,a1
	dbra	d0,aff_blt_p2
	
; ------------- Zou

aff_barres	move.l	ecr_travail,a0
	lea	4*320+24(a0),a0
	move	ecrx,d0
	and	#-16,d0
	lsr	#1,d0
	add	d0,a0

	move	ecrx,d1
	moveq	#-1,d2
	and	#15,d1
	lsr.l	d1,d2
	move.l	d2,d3
	swap	d3
	not	d3

	move.l	#$02048000,d4
	move.l	#$02078000,d5
	add	d1,d4
	add	d1,d5

	lea	energie,a1
	moveq	#3,d0
aff_nrj
	lea	$ffff8a20.w,a2
	move.l	#$00020000,(a2)+
	move.l	#energie_mask,(a2)+
	move.l	d2,(a2)+
	move	d3,(a2)+
	move.l	#$00080000+(640-224)/2,(a2)+
	move.l	a0,(a2)+
	move.l	#$000f0010,(a2)+
	move.l	d4,(a2)
	BLTWAIT	2(a2)

	lea	$ffff8a20.w,a2
	move.l	#$00080000,(a2)+
	move.l	a1,(a2)+
	move.l	d2,(a2)+
	move	d3,(a2)+
	move.l	#$00080000+(640-224)/2,(a2)+
	move.l	a0,(a2)+
	move.l	#$000f0010,(a2)+
	move.l	d5,(a2)
	BLTWAIT	2(a2)

	addq	#2,a1
	addq	#2,a0
	dbra	d0,aff_nrj
	rts

; ---------------------------------------------------------
;	Impact
; ---------------------------------------------------------

restaure_impact	move.l	ecr_travail,a0
	lea	ecran_save,a1
	
	move	imp_aff_y,d0
	mulu	#320,d0
	moveq	#0,d1
	move	imp_aff_x,d1
	and	#-16,d1
	lsr	#1,d1
	add.l	d1,d0

	add.l	d0,a0
	add.l	d0,a1
	
	lea	$ffff8a20.w,a2
	move.l	#$00020002+320-48/2,(a2)+
	move.l	a1,(a2)+
	move.l	#$ffffffff,(a2)+
	move	#$ffff,(a2)+
	move.l	#$00020002+320-48/2,(a2)+
	move.l	a0,(a2)+
	move.l	#$000c0020,(a2)+
	move.l	#$02038000,(a2)
	BLTWAIT	2(a2)
	
	rts

; ------------- Affiche impact

affiche_impact	tst	imp_aff
	beq	no_aff_impact

	move.l	imp_spr_aff,a0	
	move.l	ecr_travail,a1

	move	imp_aff_y,d0
	mulu	#320,d0
	add.l	d0,a1

	move	imp_aff_x,d0
	move	d0,d1
	and	#-16,d0
	lsr	#1,d0
	add	d0,a1
		
	and	#15,d1
	moveq	#-1,d4
	lsr	d1,d4
	move	d4,d5
	not	d5
	swap	d4

	move.l	#$02048000,d6
	move.l	#$02078000,d7
	add	d1,d6
	add	d1,d7

	moveq	#3,d0
bcl_aff_imp
	lea	$ffff8a20.w,a3	; masque
	move.l	#$00020000,(a3)+
	move.l	imp_msk_aff,(a3)+
	move.l	d4,(a3)+
	move	d5,(a3)+
	move.l	#$00080008+320-24,(a3)+
	move.l	a1,(a3)+
	move.l	#$00030020,(a3)+
	move.l	d6,(a3)
	BLTWAIT	2(a3)

	lea	$ffff8a20.w,a3	; sprite
	move.l	#$00080000,(a3)+
	move.l	a0,(a3)+
	move.l	d4,(a3)+
	move	d5,(a3)+
	move.l	#$00080008+320-24,(a3)+
	move.l	a1,(a3)+
	move.l	#$00030020,(a3)+
	move.l	d7,(a3)
	BLTWAIT	2(a3)

	addq	#2,a0
	addq	#2,a1
	dbra	d0,bcl_aff_imp

no_aff_impact	rts

; ---------------------------------------------------------
;	Le scroll dif du sol
; ---------------------------------------------------------

scroll_dif	
	IFNE	debugmode
	illegal
	ENDC

	lea	ecran_save+164*320-8,a0
	move.l	ecr_travail,a1
	add.l	#164*320-8,a1

	move.l	#$02038000,d6
	moveq	#1,d7
	
	moveq	#35,d0
scdf_ligne	
	move	ecrx,d2
	sub	#160,d2

	move	d7,d1
	add	#63,d1
	muls	d2,d1
	asr.l	#6,d1
	add	#160,d1
	
	move	d1,d2
	and	#-16,d2
	asr	#1,d2
	lea	(a0,d2.w),a3
	
	move	ecrx,d2
	and	#-16,d2
	lsr	#1,d2
	lea	(a1,d2.w),a4

	move	ecrx,d2
	and	#15,d2
	move	d1,d3
	and	#15,d3
	sub	d3,d2
	bpl.s	scdf_notneg
	addq	#8,a3
scdf_notneg	and	#15,d2
	move.b	d2,d6

	moveq	#3,d2
scdf_plan	lea	$ffff8a20.w,a2
	move.l	#$00080008,(a2)+
	move.l	a3,(a2)+
	move.l	#$ffffffff,(a2)+
	move	#$ffff,(a2)+
	move.l	#$00080008,(a2)+
	move.l	a4,(a2)+
	move.l	#$00160001,(a2)+
	move.l	d6,(a2)
	BLTWAIT	2(a2)

	addq	#2,a3
	addq	#2,a4
	dbra	d2,scdf_plan

	lea	320(a0),a0
	lea	320(a1),a1
	addq	#1,d7
	dbra	d0,scdf_ligne
	rts

; ---------------------------------------------------------
;	IT vbl
; ---------------------------------------------------------

	dc.b	"DATA rules"

vbl	clr	$ffff8240.w

;	move	$ffff8a3c.w,-(sp)
;	clr	$ffff8a3c.w
	
	move	#-1,vbl_sync
	move	hscroll,$ffff8264.w
	move	linewid,$ffff820e.w
	movem.l	d0-d7/a0-a6,-(sp)

; -------------	Test pause

	IFNE	pausecontrol
	tst.b	$3b+clavier
	beq.s	pausef2
	move	#-1,pause2

pausef2	tst.b	$3c+clavier
	beq.s	pausef3
	clr	pause
	clr	pause1
	clr	pause2
pausef3	tst.b	$3d+clavier
	beq.s	pausef4
	move	#1,pause
	move	#1,pause1
pausef4	tst.b	$3e+clavier
	beq.s	pausef5
	move	#2,pause
	move	#2,pause1
pausef5	tst.b	$3f+clavier
	beq.s	pausef10
	move	#3,pause
	move	#3,pause1
pausef10	tst.b	$44+clavier
	beq.s	nopause
	cmp	#-1,pause2
	beq.s	ralenti
		
nopause	cmp	#-1,pause2
	beq	finvbl
ralenti	subq.w	#1,pause1
	bcc	finvbl
	move	pause,pause1
	ENDC
	
; -------------	Gere joueurs

joueur1	move.l	seq_cur1,a0	; quelle sequence
	lea	buttons1,a4	; quels boutons 
	lea	joystick1,a5	; quel joystick
	lea	x_new1,a6	; quels buffers
	lea	x_new2,a3	; pour acceder infos j2
	jsr	(a0)

joueur2	move.l	seq_cur2,a0
	lea	buttons2,a4
	lea	joystick0,a5
	lea	x_new2,a6
	lea	x_new1,a3
	IFEQ	twoplayers
	clr.b	joystick0
	ENDC
	jsr	(a0)
	
; ------------- Gestion de l'impact

	clr	imp_aff

	tst	imp_vbls
	bpl	gere_imp
	tst	touche1
	bne.s	init_imp
	tst	touche2
	beq	finvbl
init_imp	
	move	#23,imp_vbls
	move	cy1,d0
	add	csy1,d0
	move	cty,d1
	lsr	#1,d1
	add	d1,d0
	sub	#16,d0
	move	d0,imp_aff_y
	move	cx1,d0
	add	csx1,d0
	move	ctx,d1
	lsr	#1,d1
	add	d1,d0
	sub	#16,d0
	move	d0,imp_aff_x
gere_imp	
	move	#-1,imp_aff
	lea	imp2_save,a0
	lea	imp2_mask,a1
	move	imp_vbls,d0
	lsr	#3,d0
	beq.s	no_imp_spr
	lea	imp1_save,a0
	lea	imp1_mask,a1
	subq.w	#1,d0
	beq.s	no_imp_spr
	lea	imp0_save,a0
	lea	imp0_mask,a1
	clr	touche1
	clr	touche2
no_imp_spr
	move.l	a0,imp_spr_aff
	move.l	a1,imp_msk_aff
	
	subq.w	#1,imp_vbls

; ------------- Fin vbl

finvbl	movem.l	(sp)+,d0-d7/a0-a6
;	move	(sp)+,$ffff8a3c.w
	rte

; ----------------------------------
;	IT kbd
; ----------------------------------

ikbd	
;	move	$ffff8a3c.w,-(sp)
;	clr	$ffff8a3c.w
	
	movem.l	d0-d1/a0,-(sp)
	lea	clavier,a0
	move.b	$fffffc02.w,d0
	move	d0,d1
	and	#$7f,d1
	tas	d0
	spl	(a0,d1.w)
	
	cmp.b	#$fe,d0
	bne.s	joy1?
	move.l	#joy0,$118.w
	bra.s	ikbd_end
joy1?	cmp.b	#$ff,d0
	bne.s	ikbd_end
	move.l	#joy1,$118.w

ikbd_end	movem.l	(sp)+,d0-d1/a0
	bclr	#6,$fffffa11.w
;	move	(sp)+,$ffff8a3c.w
	rte

joy0	
;	move	$ffff8a3c.w,-(sp)
;	clr	$ffff8a3c.w

	move.b	$fffffc02.w,joystick0
	move.l	#ikbd,$118.w
	
	bclr	#6,$fffffa11.w
;	move	(sp)+,$ffff8a3c.w
	rte

joy1	
;	move	$ffff8a3c.w,-(sp)
;	clr	$ffff8a3c.w
	
	move.b	$fffffc02.w,joystick1
	move.l	#ikbd,$118.w
	
	bclr	#6,$fffffa11.w
;	move	(sp)+,$ffff8a3c.w
	rte

; ----------------------------------
;	IT timer A : le son
; ----------------------------------

timera	movem.l	d0-d7/a0-a6,-(sp)
	IFNE	timecontrol
	not	$ffff8240.w
	ENDC
	
	move.l	#snd_buf0,d0
	not	snd_flag
	beq.s	notsndbuf0
	move.l	#snd_buf1,d0
notsndbuf0
	move.l	d0,a1

	lea	$ffff8900.w,a0
	move.b	d0,$07(a0)
	ror	#8,d0
	move.l	d0,$02(a0)
	ror	#8,d0

	add.l	#250*2,d0

	move.b	d0,$13(a0)
	ror	#8,d0
	move.l	d0,$0e(a0)

; ------------- Reset buffer

	move.l	a1,a0
	move	#124,d0
	moveq	#0,d1
snd_clr	move.l	d1,(a0)+
	dbra	d0,snd_clr

; ------------- Calcul voie gauche : p1

	move.l	snd_res1,d1
	bmi.s	calc_snd2
	move.l	a1,a0
	move	x_new2,d0
	cmp	x_new1,d0
	bpl.s	snd_p1ip2
	addq	#1,a0
snd_p1ip2	move.l	snd_adr1,a2	

	moveq	#0,d2
	move.l	#249,d0
	cmp.l	#250,d1
	bpl.s	ok_minsnd1
	move.l	d1,d0
	moveq.l	#-1,d2
ok_minsnd1
copy_snd1	move.b	(a2)+,(a0)
	addq	#2,a0
	dbra	d0,copy_snd1

	move.l	a2,snd_adr1
	move.l	#-1,snd_res1
	tst.l	d2
	bne.s	calc_snd2
	sub.l	#250,d1
	bpl.s	ok_sndnotfin1
	move.l	#-1,d1
ok_sndnotfin1	move.l	d1,snd_res1	

; ------------- Calcul voie droite : p2

calc_snd2	move.l	snd_res2,d1
	bmi.s	calc_snd
	move.l	a1,a0
	move	x_new2,d0
	cmp	x_new1,d0
	bmi.s	snd_p1sp2
	addq	#1,a0
snd_p1sp2	move.l	snd_adr2,a2	

	moveq	#0,d2
	move.l	#249,d0
	cmp.l	#250,d1
	bpl.s	ok_minsnd2
	move.l	d1,d0
	moveq.l	#-1,d2
ok_minsnd2
copy_snd2	move.b	(a2)+,(a0)
	addq	#2,a0
	dbra	d0,copy_snd2

	move.l	a2,snd_adr2
	move.l	#-1,snd_res2
	tst.l	d2
	bne.s	calc_snd
	sub.l	#250,d1
	bpl.s	ok_sndnotfin2
	move.l	#-1,d1
ok_sndnotfin2	move.l	d1,snd_res2

; ------------- Fin du calcul du son

calc_snd
	IFNE	timecontrol
	not	$ffff8240.w
	ENDC
	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#5,$fffffa0f.w
	rte

; ----------------------------------
;	Buffers
; ----------------------------------

	DATA

player1	incbin	chunli.prg

ecran_save	incbin	stage1.bin	; ecran sauvegarde

energie_save	incbin	power.bin	; barres d'energie

imp0_save	incbin	imp0.bin	; etoiles impact
imp1_save	incbin	imp1.bin
imp2_save	incbin	imp2.bin

palette	dc.l	$00000888,$01110999,$02220aaa,$03330bbb
	dc.l	$04440ccc,$05550ddd,$06660eee,$07770fff

buttons1	dc.l	$67+clavier,$68+clavier,$69+clavier
	dc.l	$6a+clavier,$6b+clavier,$6c+clavier
buttons2	dc.l	$10+clavier,$11+clavier,$12+clavier
	dc.l	$1e+clavier,$1f+clavier,$20+clavier

	BSS

;	D‚cor

linewid	ds.w	1
hscroll	ds.w	1
vbl_sync	ds.w	1
ecran_flag	ds.w	1	; Ecran 1 ou 2 de travail ?
ecr_travail	ds.l	1
ecr_affiche	ds.l	1
ecran1	ds.l	1	; adr ecr 1
ecran2	ds.l	1	; adr ecr 2

ecrx	ds.w	1
energie	ds.b	224*16*4/8	; en cours
energie_mask	ds.b	224*16*1/8	; masque

imp_vbls	ds.w	1	; compteur impacts
imp_spr_aff	ds.l	1
imp_msk_aff	ds.l	1
imp_aff	ds.w	1
imp_aff_x	ds.w	1
imp_aff_y	ds.w	1
imp0_mask	ds.b	32*32*1/8
imp1_mask	ds.b	32*32*1/8
imp2_mask	ds.b	32*32*1/8

;	Joueur 1

adr_sprites1	ds.l	1
vbl_joueur1	ds.l	1
seq_joueur1	ds.l	1

x_new1	ds.w	1	; position courante
y_new1	ds.w	1
d_new1	ds.w	1	; dir courante
attack1	ds.w	1	; flag attaque
defense1	ds.w	1	; flag defense
saut1	ds.w	1	; sens du saut/flag
bord1	ds.w	1	; flag bord
bt_nmb1	ds.w	1	; divers

seq_cpt1	ds.w	1	; idem
seq_cur1	ds.l	1	; sequence courante
seq_vbl1	ds.w	1	; compteur ds sequence
seq_spr1	ds.l	1	; pointeur courant ds seq

seq_cur12	ds.l	1	; sequence courante
seq_vbl12	ds.w	1	; idem
seq_spr12	ds.l	1	; si interrupt

collision1	ds.w	1	; flag collision
minecrx1	ds.w	1	; minimum x
maxecrx1	ds.w	1	; maximum x
last_bt1	ds.w	1
energie1	ds.w	1	; energie restante
touche1	ds.w	1	; touche ?
snd_adr1	ds.l	1	; adr courante son
snd_res1	ds.l	1	; taille restante

old_nrj1	ds.w	1
symetrie1	ds.l	1	; adresse des symetries
mask1	ds.l	1	; adresse des masques
quoi1	ds.l	1	; quelles donnees

save11
x_sav11	ds.w	1	; ancienne position
y_sav11	ds.w	1
d_sav11	ds.w	1	; direction ancienne
t_sav11	ds.l	1	; taille ancienne
save12
x_sav12	ds.w	1	; ancienne position
y_sav12	ds.w	1
d_sav12	ds.w	1	; direction ancienne
t_sav12	ds.l	1	; taille ancienne

;	Joueur 2

adr_sprites2	ds.l	1
vbl_joueur2	ds.l	1
seq_joueur2	ds.l	1

x_new2	ds.w	1	; position courante
y_new2	ds.w	1
d_new2	ds.w	1	; dir courante
attack2	ds.w	1
defense2	ds.w	1
saut2	ds.w	1	; sens du saut/flag
bord2	ds.w	1	; flag bord
bt_nmb2	ds.w	1	; divers

seq_cpt2	ds.w	1	; idem
seq_cur2	ds.l	1	; sequence courante
seq_vbl2	ds.w	1	; compteur ds sequence
seq_spr2	ds.l	1	; pointeur courant ds seq

seq_cur22	ds.l	1	; sequence courante
seq_vbl22	ds.w	1	; idem
seq_spr22	ds.l	1	; si interrupt

collision2	ds.w	1	; flag collision
minecrx2	ds.w	1	; minimum x
maxecrx2	ds.w	1	; maximum x
last_bt2	ds.w	1
energie2	ds.w	1	; energie restante
touche2	ds.w	1	; touche ?
snd_adr2	ds.l	1	; adr courante son
snd_res2	ds.l	1	; taille restante

old_nrj2	ds.w	1
symetrie2	ds.l	1	; adresse des symetries
mask2	ds.l	1	; adresse des masques
quoi2	ds.l	1	; quelles donnees

save21
x_sav21	ds.w	1	; ancienne position
y_sav21	ds.w	1
d_sav21	ds.w	1	; direction ancienne
t_sav21	ds.l	1	; taille ancienne
save22
x_sav22	ds.w	1	; ancienne position
y_sav22	ds.w	1
d_sav22	ds.w	1	; direction ancienne
t_sav22	ds.l	1	; taille ancienne

;	Collision

cx1	ds.w	1
cy1	ds.w	1
clx1	ds.w	1
cly1	ds.w	1
csx1	ds.w	1
csy1	ds.w	1
cadr1	ds.l	1

cx2	ds.w	1
cy2	ds.w	1
clx2	ds.w	1
cly2	ds.w	1
csx2	ds.w	1
csy2	ds.w	1
cadr2	ds.l	1

ctx	ds.w	1
cty	ds.w	1

colblocs	ds.w	1
colflag	ds.w	1
collision	ds.b	4000

;	Pause

	IFNE	pausecontrol
pause	ds.w	1	
pause1	ds.w	1
pause2	ds.w	1
	ENDC

;	Son

snd_flag	ds.w	1	; quel buffer
snd_buffer	ds.l	1	; adr buffer a traiter
snd_buf0	ds.w	500	; 12.5Khz stereo
snd_buf1	ds.w	500

;	Clavier

joystick0	ds.b	1
joystick1	ds.b	1
clavier	ds.b	128

;	Divers

memoryused	ds.l	1
falcon	ds.w	1

;	Pile

	ds.l	1024
pile	ds.l	1
