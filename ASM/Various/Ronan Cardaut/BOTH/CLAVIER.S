	output	d:\centinel\both\clavier.o
	incdir	d:\centinel\dsp
	
	
	include	d:\centinel\both\define.s
	
get_key::
*******************************************
** routine qui renvoie dans d0 la touche **
** on attend la touche avant de sortir   **
**  - si crtl  bit 8 de d0 mis           **
**  - si alt   bit 9 de d0 mis           **
**  - si shift bit a de d0 mis           **
*******************************************
	
	xref	clavier_pourri
	
	tst.w	clavier_pourri		; encore une fois on va regarder si on doit utiliser ou non
	beq	.ouf			; la routine systeme
	
	
	
	movem.l	d1-d2/a0-a2,-(sp)
	

	move	#2,-(sp)
	move	#2,-(sp)
	trap	#13
	addq.l	#4,sp


	swap	d0

	move.l	d0,-(sp)
	


	move	#-1,-(sp)
	move	#11,-(sp)
	trap	#13
	addq.l	#4,sp

	move.l	d0,d1
	
	move.l	(sp)+,d0
	
	
	
	
	btst	#0,d1
	beq.s	.p_sh
	bset	#$a,d0
.p_sh
	btst	#1,d1
	beq.s	.p_sh1
	bset	#$a,d0
.p_sh1

	btst	#2,d1
	beq.s	.p_ctrl
	bset	#$8,d0
.p_ctrl
	
	btst	#3,d1
	beq.s	.p_alt
	bset	#$9,d0
.p_alt
	btst	#4,d1
	beq.s	.p_cap
	bset	#$a,d0
.p_cap
	
	
	movem.l	(sp)+,d1-d2/a0-a2
	
	
	rts



.ouf
	
	move	d1,-(sp)
	move	d2,-(sp)
	clr.w	d1
	

	
.debut
	
	xref	replay_macro,record_macro
	tst.w	replay_macro		; on teste si on doit rejouer la macro
	beq.s	.normal
	
	illegal
	
	move.l	buffer_cou_t,a0
	
	
	
	move.l	(a0)+,d0
	beq.s	.retour_n
	move.l	a0,d1

		
	;move.l	#20,d6
.lmp	;move.l	#-1,d7
	;dbra	d7,*
	;dbra	d6,.lmp
	
	
	
	
	cmp.l	#fin_buf_t,d1
	bge	.retour_n	
	
	move.l	a0,buffer_cou_t
	
	move	(sp)+,d2
	move	(sp)+,d1
	
	
	
	rts
	
	
.retour_n
	
	
	clr.w	replay_macro
	move.l	#0,etat_touche
	
	
	
.normal
	
	
	
		
	move.l	etat_touche,d0
	and.l	#$0000ff00,d0
	
.m	
	
	;lea	buf(pc),a0
	;bsr	inquire_keys
	;move	d0,nb_car
	
	
	
	*------------------*
	* ‚mulation de l'exeption DSP
	*------------------*
	
	ifne	(DSP=DSP56001)
	btst	#3,$ffffa202.w
	beq	.NODSP	
	TRAP	#4
	endc
	
	
	ifne	(DSP=DSP56301)
	btst	#6,HSTR+3
	beq	.NODSP	
	TRAP	#4
	endif
	

	move.l	etat_touche,d0
	move.b	#$43,d0		;touche pour REFRESH
	bra	.OVER
	
	
.NODSP

	move.b	$fffffc00.w,d1
	btst	#7,d1
	;beq.s	.m
	;beq.s	.car_ok		; enleve la tempo
	beq	.tempo		; tempo
	
	btst	#0,d1		; traitement des erreurs
	bne.s	.car_ok
	and.b	#%01110000,d1
	bne.s	.err
	nop
.err
	move.b	$fffffc02.w,d1

	
	
	bra.s	.m

	*--- on a recu un carctŠre ---*
	
.car_ok
	move.b	$fffffc02.w,d0
.OVER					; on arrive ici si on veut forcer REFRESH
	cmp.b	#$61,d0			; on fait un reset des touches du clavier
	bne.s	.p_reset		; c'est la touche undo
	move.w	#0,d0
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_reset
	cmp.b	#$1d,d0			; test de crtl
	bne.s	.p_ctrl_pressed  
	bset	#8,d0			;on met le bit 8 de d0 a 1	
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_ctrl_pressed
	cmp.b	#$80+$1d,d0
	bne.s	.p_ctrl_unpressed
	bclr	#8,d0
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_ctrl_unpressed
	cmp.b	#$38,d0			; test de alt
	bne.s	.p_alt_pressed
	bset	#9,d0			;on met le bit 9 de d0 a 1	
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_alt_pressed
	cmp.b	#$80+$38,d0
	bne.s	.p_alt_unpressed
	bclr	#9,d0
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_alt_unpressed
	cmp.b	#$2a,d0			; test de shift gauche
	bne.s	.p_shtg_pressed
	bset	#$a,d0			;on met le bit 10 de d0 a 1	
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_shtg_pressed
	cmp.b	#$80+$2a,d0
	bne.s	.p_shtg_unpressed
	bclr	#$a,d0
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_shtg_unpressed
	cmp.b	#$36,d0			; test de shift droit
	bne.s	.p_shtd_pressed
	bset	#$a,d0			;on met le bit 10 de d0 a 1	
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_shtd_pressed
	cmp.b	#$80+$36,d0
	bne.s	.p_shtd_unpressed
	bclr	#$a,d0
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
.p_shtd_unpressed
	bra	.su	


	*--- gestion de la r‚p‚tition ---*

	
.tempo
	tst.w	tempo1		; la repetition rapide
	beq.s	.p_rep
	move.w	#65535,d1
.p1	dbra	d1,.p1
	move.l	etat_touche,d0
	bra	.FIN
.p_rep
	
	tst.w	tempo		; amorcage de la repetition
	beq.s	.p_temp
	move.w	#65535,d1
.p	dbra	d1,.p
	;move.l	etat_touche,d0
	addq.l	#1,COMPT_REPEAT
	cmp.l	#50,COMPT_REPEAT
	bne.s	.p_temp
	clr.l	COMPT_REPEAT
	st	tempo1
	sf	tempo
	bra	.m
.p_temp
	bra	.m




	
.su
	btst	#7,d0			; 0 touche appuyee
	beq.s	.suiv			; 1 toouche relachee
	move.l	#0,COMPT_REPEAT
	sf	tempo1
	sf	tempo
	bra	.m
	
.suiv
	st	tempo

	
	*-----*
	
	

	
	
	


;j'ajoute le code ascii ds le LSB du MSW
	clr	d1
	move.b	d0,d1
	btst	#$a,d0
	bne.S	.shift
	btst	#9,d0
	bne.S	.alt
	move.b	(CARACTERES_NORMAUX.l,d1),d1
	bra.S	.SUITE
.alt	move.b	(CARACTERES_ALT.l,d1),d1
	bra.S	.SUITE
.shift	btst	#9,d0
	bne.s	.shftalt	
	move.b	(CARACTERES_SHIFT.l,d1),d1
	bra.S	.SUITE
.shftalt 
	move.b	(CARACTERES_SHIFT_ALT.l,d1),d1


.SUITE	swap	d0
	move.b	d1,d0
	swap	d0
.FIN	
	
	
	
	
	move.l	d0,etat_touche

	
	
	
	
	;tst.w	replay_macro
	;bne.s	.pas_r
	
	tst.w	record_macro		; on ne record pas si on le demande
	beq.s	.pas_r
	
	
	pea	(a0)
	move.l	buffer_cou_t,a0
	move.l	d0,(a0)+
	
	move.l	a0,d1
	cmp.l	#fin_buf_t,d1		; si debordement alors on stoppe l'enregistrement
	blt	.p_p
	move.l	#t_buf,a0
	clr.w	record_macro
.p_p
	
	move.l	a0,buffer_cou_t
	move.l	(sp)+,a0


.pas_r

	
	
	;cmp.l	#$41,d0		; on teste si on a fait f7
	;bne.s	.p_rej
	
	
	
	;move.l	buffer_cou_t,a0
	;clr.l	(a0)
	
	;move.l	#t_buf,buffer_cou_t
	
	;move.l	buffer_cou_t,a0
	;move.l	(a0),d0
	
	
	;st	replay_macro
	;bra	.debut
	
	
	
;.p_rej
	
	
	
	move	(sp)+,d2
	move	(sp)+,d1
	
	

	rts
	
	
.FIN1
	move	(sp)+,d2
	move	(sp)+,d1
	
	
	
	
	rts
	
	
etat_touche::
	dc.l	0		; etat des touche speciales


	include	both\TAB_CAR.S


	xref	MESSAGE_ADR

GET_CHAINE::
*******************************************************
** Routine qui va demander un chaine a l'utilisateur **
**  - a0 adresse du message a afficher               **
**  - a2 retour de la chaine a exploiter             **
**  - d0=-1 ok      d0=0 annule                      **
*******************************************************
	xref	PETIT_MESSAGE

	movem.l	d1-a1/a3-a6,-(sp)


	move.l	#MES_SPACE,MESSAGE_ADR
	bsr	PETIT_MESSAGE


	move.w	lignes_count,d0
	move.w	d0,lignes_count1


	

	move.l	a0,a2
	move.l	a0,a6


	clr.w	direction
.debut_saisie
	
	
	bsr	eff_buf
	
	moveq	#1,d2
	lea	buffer_eval,a1

	move.w	#0,POS_CUR
	
	
.copi	move.b	(a0)+,(a1)+
	addq.w	#1,POS_CUR
	tst.b	(a0)
	bne.s	.copi
	
	move.l	a1,DEB_CHAINE
	move.w	POS_CUR,POS_MIN
	move.l	a1,a6
	move.b	#' ',(a1)
	
	
.recoit	move.l	#buffer_eval_cur,MESSAGE_ADR
	bsr	met_le_curseur
	move.l	a1,-(sp)
	bsr	PETIT_MESSAGE
	move.l	(sp)+,a1
	bsr	get_key
	cmp.b	#$1c,d0
	beq	.sort			; gros return
	cmp.b	#$72,d0
	beq	.sort			; petit return
	cmp.b	#1,d0
	beq	.sort_esc		; c'est le esc
	cmp.b	#$3a,d0			
	beq.s	.recoit			; c'est le caps lock
	cmp.b	#$62,d0
	beq.s	.recoit			; help
	cmp.b	#$61,d0
	beq.s	.recoit			; undo
	cmp.b	#$52,d0
	beq.s	.recoit			; insert
	cmp.b	#$0f,d0
	beq.s	.recoit			; tab
	
	
	
	cmp.b	#$48,d0			; fleche du haut : la ligne d'avant
	bne	.p_back_t
	move.w	lignes_count1,d0		; si ligne a 0 on n'en a pas dans le buffer
	cmp.w	#0,d0
	beq.s	.recoit
	
	move.l	a2,a0
	bsr	eff_buf
	moveq	#1,d2


	cmp.w	#1,direction
	bne.w	.p_e
	subq.w	#1,lignes_count1
	move.w	#2,direction	

.p_e

	lea	buffer_eval,a1
	move.w	#255,d0
.po	clr.b	(a1)+
	dbra	d0,.po
	lea	buffer_eval,a1
	
	lea	buffer_lignes,a3
	clr.l	d0
	move.w	lignes_max,d0
	mulu	#256,d0
	add.l	d0,a3
	clr.l	d0
	move.w	lignes_count1,d0
	mulu	#256,d0
	sub.l	d0,a3
	
	
	cmp.w	#1,direction
	beq.s	.k11
	subq.w	#1,lignes_count1
	move.w	#2,direction	
.k11
	
	move.w	#0,POS_CUR
.copy	move.b	(a0)+,(a1)+
	addq.w	#1,POS_CUR
	tst.b	(a0)
	bne.s	.copy
	move.l	a1,DEB_CHAINE
	move.l	a1,a6
.copy1	move.b	(a3)+,(a1)+
	addq.w	#1,POS_CUR
	addq.w	#1,d2
	tst.b	(a3)
	bne.s	.copy1
	
	
	
	
	move.w	#2,direction
	
	;move.w	POS_CUR,POS_MIN
	move.b	#' ',(a1)
	bra	.recoit
	
	
	
.p_back_t
	
	
	cmp.b	#$50,d0			; fleche du haut : la ligne d'avant
	bne	.p_ff_t
	move.w	lignes_count1,d0
	cmp.w	lignes_count,d0
	bge	.recoit
	;move.w	lignes_count,d0
	;cmp.w	#1,d0
	;ble	.recoit
	
	
	move.l	a2,a0
	bsr	eff_buf
	cmp.w	#2,direction
	bne.s	.k114
	addq.w	#1,lignes_count1
.k114
	addq.w	#1,lignes_count1
	moveq	#1,d2
	
	;move.w	lignes_count1,d0
	;cmp.w	lignes_count,d0
	;ble.s	.ko
	;move.w	lignes_count,lignes_count1
;.ko


	lea	buffer_eval,a1
	move.w	#255,d0
.po1	clr.b	(a1)+
	dbra	d0,.po1
	
	lea	buffer_eval,a1
	
	
	
	lea	buffer_lignes,a3
	clr.l	d0
	move.w	lignes_max,d0
	mulu	#256,d0
	add.l	d0,a3
	clr.l	d0
	move.w	lignes_count1,d0
	mulu	#256,d0
	sub.l	d0,a3
	
	
	
	
	move.w	#0,POS_CUR
.copy0	move.b	(a0)+,(a1)+
	addq.w	#1,POS_CUR
	tst.b	(a0)
	bne.s	.copy0
	move.l	a1,DEB_CHAINE
	move.l	a1,a6
.copy01	move.b	(a3)+,(a1)+
	addq.w	#1,POS_CUR
	addq.w	#1,d2
	tst.b	(a3)
	bne.s	.copy01
	
	
	move.w	#1,direction	
	
	
	;move.w	POS_CUR,POS_MIN
	;move.b	#' ',(a1)
	bra	.recoit
	
	
	
.p_ff_t
	
	
	
	cmp.b	#$47,d0
	bne.s	.p_eff_tout0		; clr home on eff tout
	move.l	a2,a0
	bra	.debut_saisie
.p_eff_tout0
	


	cmp.w	#$10e,d0		; crtl bck on eff tout
	bne.s	.p_eff_tout
	move.l	a2,a0
	bra	.debut_saisie
.p_eff_tout
	
	
	
	cmp.b	#$53,d0			
	bne.s	.p_del
	lea	buffer_eval,a0
	add.w	POS_CUR,a0
	tst.b	1(a0)
	beq	.recoit
.yu1	move.b	1(a0),(a0)
	tst.b	1(a0)
	beq.s	.f1
	addq.l	#1,a0
	bra.s	.yu1
.f1
	subq.w	#1,d2
	bra	.recoit
.p_del

	
	
	
	
	
	cmp.b	#$e,d0			; on a la bck spc
	bne.s	.p_bck
	subq.w	#1,POS_CUR
	move.w	POS_MIN,d0
	cmp.w	POS_CUR,d0
	ble.s	.zer
	addq.w	#1,POS_CUR
	bra	.recoit
	
.zer
	
	
	subq.w	#1,d2
	lea	buffer_eval,a0
	add.w	POS_CUR,a0
.yu	move.b	1(a0),(a0)
	tst.b	1(a0)
	beq.s	.f
	addq.l	#1,a0
	bra.s	.yu
.f	
	clr.w	(a0)
	bra	.recoit
.p_bck
	
	
	cmp.w	#$014b,d0			; a gauche vite
	bne.s	.p_gauche_rap
	move.w	POS_MIN,POS_CUR
	bra	.recoit
.p_gauche_rap

	


	cmp.b	#$4b,d0				; a gauche d'un cran
	bne.s	.p_gauche
	subq.w	#1,POS_CUR
	move.w	POS_MIN,d1
	cmp.w	POS_CUR,d1
	blt.s	.aze
	move.w	POS_MIN,POS_CUR
.aze
	
	bra	.recoit
.p_gauche

	
	
	cmp.w	#$14d,d0			; regarde si on fait crtl + doite
	bne.s	.p_droite_rap
.ajt	addq.w	#1,POS_CUR
	lea	buffer_eval,a0
	add.w	POS_CUR,a0
	tst.b	(a0)
	bne.s	.ajt
	subq.w	#1,POS_CUR
	bra	.recoit
.p_droite_rap

	
	cmp.b	#$4d,d0			; regarde si on va adroite
	bne.s	.p_droite
	addq.w	#1,POS_CUR
	lea	buffer_eval,a0
	add.w	POS_CUR,a0
	tst.b	(a0)
	bne.s	.oiu
	subq.w	#1,POS_CUR
.oiu
	bra	.recoit
.p_droite
	





	cmp.w	MAX_CAR,d2
	beq	.recoit

	addq.w	#1,d2
	
	btst	#9,d0
	bne.s	.alt?
	btst	#10,d0
	beq.s	.norm
	
	lea	CARACTERES_SHIFT,a0
	clr.l	d1
	move.b	d0,d1
	move.b	(a0,d1),d0
	addQ.l	#1,a1
	bsr	inser_t
	addq.w	#1,POS_CUR
	bra	.recoit
	
.alt?
	btst	#10,d0
	beq.s	.alt
	
	lea	CARACTERES_SHIFT_ALT,a0
	clr.l	d1
	move.b	d0,d1
	move.b	(a0,d1),d0
	addQ.l	#1,a1
	bsr	inser_t
	addq.w	#1,POS_CUR
	bra	.recoit

	
	
.norm
	lea	CARACTERES_NORMAUX,a0
	clr.l	d1
	move.b	d0,d1
	move.b	(a0,d1),d0
	addQ.l	#1,a1
	bsr	inser_t
	addq.w	#1,POS_CUR
	bra	.recoit
	
.alt
	lea	CARACTERES_ALT,a0
	clr.l	d1
	move.b	d0,d1
	move.b	(a0,d1),d0
	addQ.l	#1,a1
	bsr	inser_t
	addq.w	#1,POS_CUR
	bra	.recoit
	
	
.sort
	moveq	#-1,d0
	lea	buffer_eval,a0
	cmp.w	#1,d2
	beq.s	.sort_esc
	
	moveq	#0,d0

.op	tst.b	(a0)+
	beq	.op4
	addq.l	#1,d0
	bra.s	.op
.op4
	lea	buffer_eval,a1
	subq.l	#2,a0
	
	clr.b	(a0)		; efface l'espace du curseur
	
	bsr	put_ligne_buf

	moveq	#-1,d0


	move.l	a6,a2
	movem.l	(sp)+,d1-a1/a3-a6
	rts
	
.sort_esc
	moveq	#0,d0
	;clr.b	(a1)+
	
	
	movem.l	(sp)+,d1-a1/a3-a6
	
	rts




put_ligne_buf
**************************
** met la ligne en pile **
**************************
	clr.l	d0
	move.w	lignes_max,d0
	clr.l	d1
	move.w	lignes_count,d1
	addq.w	#1,d1
	cmp.w	d1,d0
	bge	.norm
	; ** on decale tout dans la pile
	move.w	lignes_max,lignes_count
	lea	buffer_lignes,a0
	mulu	#256,d0		
	sub.l	#256,d0
	add.l	d0,a0			; on se place une ligne avant la fin
	move.w	lignes_max,d0
	subq.l	#1,d0			; on doit copier tout -1 ligne
	

.op	move.l	a0,a2


	

.iop	move.b	-256(a0),(a0)
	addq.l	#1,a0
	tst.b	-256(a0)
	bne.s	.iop
	
	move.l	a2,a0
	sub.l	#256,a0			; on se place sur la ligne d'avant
	dbra	d0,.op	
		



	move.l	a6,a2
	lea	buffer_lignes,a0
	
	move.l	#0,d0
	
.o1	move.b	(a2)+,(a0)+
	bne.s	.o1
	move.b	#'1',(a0)+
	clr.l	(a0)	
	
	
	
	
	
	
	move.w	lignes_max,d0
	;subq.w	#1,d0
	move.w	d0,lignes_count	
	
	
	rts
.norm	; ** on empile normalement
	move.w	d1,lignes_count
	move.l	a6,a2
	lea	buffer_lignes,a0
	mulu	#256,d0
	add.l	d0,a0
	mulu	#256,d1

	sub.l	d1,a0



.o	move.b	(a2)+,(a0)+
	bne.s	.o
	




	rts


eff_buf
	lea	buffer_eval,a1
	move.w	#254,d1
.eff	clr.b	(a1)+
	dbra	d1,.eff
	lea	buffer_eval_cur,a1
	move.w	#254,d1
.eff1	clr.b	(a1)+
	dbra	d1,.eff1
	rts


inser_t
**************************************
** on insert du text dans la chaine **
**************************************
	movem.l	a2/a3,-(sp)
	lea	buffer_eval,a2
	add.w	POS_CUR,a2
	move.l	a1,a3
.w	move.b	(a1),1(a1)
	cmp.l	a1,a2
	beq.s	.w1
	subq.l	#1,a1
	bra.s	.w
.w1
	move.b	d0,(a1)
	move.l	a3,a1
	
	
	

	movem.l	(sp)+,a2/a3


	rts


met_le_curseur
*****************************************
** on insere le curseur dans la chaine **
*****************************************
	movem.l	a0/d0-d1/a1,-(sp)
	
	xref	ATTRIBUTE,COL_ADR
	
	move.l	DEB_CHAINE,a1
	lea	buffer_eval,a0
	sub.l	a0,a1
	move.l	a1,d1
	
	move.w	COL_ADR,ATTRIBUTE
	lea	buffer_eval,a0
	lea	buffer_eval_cur,a1
	move.w	#16,(a1)+
	move.w	POS_CUR,d0
	
	tst.w	d0
	beq.s	.i1	
	subq.w	#1,d0
	clr.w	d1
.k	move.b	(a0)+,d1
	move.w	ATTRIBUTE,(a1)
	or.w	d1,(a1)+
	dbra	d0,.k
.i1
	bset	#6,ATTRIBUTE
	clr.w	d1
	move.b	(a0)+,d1
	move.w	ATTRIBUTE,(a1)
	or.w	d1,(a1)+
	bclr	#6,ATTRIBUTE
	clr.w	d1
.p	move.b	(a0)+,d1
	tst.b	d1
	beq.s	.i
	move.w	ATTRIBUTE,(a1)
	or.w	d1,(a1)+
	bra.s	.p
.i
	
	addq.w	#1,yop
	cmp.w	#8,yop
	bne	.l
	
	;illegal
.l
	
	
	
.u
	move	#' ',(a1)+
	cmp.l	#fin_buf,a1
	blt.s	.u
	
	move	#$8000,(a1)
	
	
	movem.l	(sp)+,a0/a1/d0-d1
	rts


yop	dc.w	0

lignes_count	
	dc.w	0
lignes_count1	
	dc.w	0
lignes_max
	dc.w	20-1


MAX_CAR	dc.w	60
MES_SPACE	dc.b	'                                        ',0
	
	even
tempo::		dc.w	0		; flag pour la repetition (amorceage)
tempo1::	dc.w	0		; flag pour la vitesse de repetition
nb_car		dc.w	0
buf		ds.b	50


*----------------------------------------------------------------------------*
		
		*-------------*
		* Retourne l'‚tat du clavier:
		* si pas de clavier=> buffer vide
		* si clavier mais pas de touche=> num‚ro de version du clavier
		* la suite suit cette rŠgle:
		* car 1: premier code scan de la liste+bit 7 … 1
		* car 2: version du clavier ($f0(stf),$f1 (mstf), $fx...)
		* car 3: premier code scan utile … prendre en compte
		* car 4 … 8: les codes suivant (0 indique la find de la liste)
		* au total on peut avoir Control,Shift gauche,alternate,
		* shift droit, capslock et une touche quelconque.
		* l'ordre correspond … l'ordre d'appui.
		*
		* NOTE: il faut que le compteur du timerc tourne, car c'est
		* la base de temps pour le reset.
		*
		* Cette routine peut prendre jusqu'… un peu plus de 500ms pour
		* s'ex‚cuter.
		*
		* Le sr est restaur‚ … la fin mais en interne, on passe en I7!
		
		*-------------*
		* A0: pointeur sur un buffer d'au moins 9 octets
		* => A0: le buffer est mis … jour (0.b marque la fin)
		cnop	0,16
inquire_keys
		movem.l	d1-d2/a0-a1,-(sp)
		
		
	* reset le clavier
		lea	.init_ikbd(pc),a1
		move	(a1)+,d0
.wait_env
		btst.b	#1,$fffffc00.w
		beq.s	.wait_env
		
		move.b	(a1)+,$fffffc02.w
		dbra	d0,.wait_env

	* r‚cup‚ration des codes scan+ time out de  500ms		
		moveq	#0,d0		;nb cars re‡us
		move.l	#500*192/20,d1	;500 ms (192 ticks pour le
					;compteur du timerc
					;qui donne 20ms)
.time_out
		btst	#0,$fffffc00.w
		beq.s	.dec_time
		
		move.b	$fffffc02.w,d2
		move.b	d2,(a0)+
		addq	#1,d0
.dec_time
		move.b	$fffffa23.w,d2

.wait		cmp.b	$fffffa23.w,d2
		beq	.wait
		
		subq.l	#1,d1
		bne	.time_out
	* fini
.end_wait
		movem.l	(sp)+,d1-d2/a0-a1
		rts

		* init le clavier
.init_ikbd	dc.w	2-1	;nb de car-1
		dc.b	$80,$01	;Reset

*----------------------------------------------------------------------------*




	SECTION BSS
	
COMPT_REPEAT	ds.l	1

DEB_CHAINE	ds.l	1
POS_CUR	ds.w	1
POS_MIN	ds.w	1
******************************
** buffer pour l'evaluateur **
******************************

buffer_cou_t::	ds.l	1
direction	ds.w	1		; flag pour donner la direction du rappel des expressions
buffer_lignes	ds.b	256*21		; on reserve 10 lignes pour le rappel
buffer_eval	ds.b	256		; buffer pour la chaine de l'evaluateur
buffer_eval_cur	ds.b	256*2		; buffer pour la chaine de l'evaluateur
fin_buf
	ds.l	1

t_buf::		ds.l	100		; on autorise 100 operations
fin_buf_t		