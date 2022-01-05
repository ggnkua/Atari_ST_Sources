* attention:
* j'ai enlev‚ le menu RAM libre car ca fait un gros appel systeme … chaque coup !



	output	d:\centinel\both\menu.o
	incdir	d:\centinel\both

	include	d:\centinel\both\define.s
	include	d:\centinel\both\localmac.s


DRAW_MENU::
	xref	RESO_X,COL_MENU,COL_NOR,LINE,AFF_XY,AFF8_XY


	lea	MENU_BAR,a0
	move	(a0)+,d0		;type
	
	move	(a0)+,d7
	subq	#1,d7			; nb titres
	
	move	RESO_X,d6	
	subq	#1,d6
	bmi	.FIN
	move	COL_MENU,d0
	lea	LINE,a6
	clr.l	(a6)+
	move	CURRENT_MENU,d2
	addq	#1,d2
	tst	ACTIF_MENU
	bne.s	.LOOP
	move	#$7fff,d2	;nb infini

	*-----------------*
	* boucle de recopie 
	* des titres
	*-----------------*

.LOOP	move	COL_MENU,d0
	subq	#1,d2
	bne.s	.NOACT
	move	COL_NOR,d0

.NOACT	move.l	(a0)+,a1
	clr	6(a1)		;y menu=0
	move	RESO_X,d1
	subq	#1,d1
	sub	d6,d1
	move	d1,4(a1)	
	move.l	8(a1),a1	;titre du menu
.COP	move.b	(a1)+,d0
	beq.S	.OK0
	move	d0,(a6)+
	dbra	d6,.COP
	bra.s	.TERM
.OK0	dbra	d7,.LOOP
.FIL	move	#' ',(a6)+
	dbra	d6,.FIL		
.TERM	
	xref	RESIDENT
	tst	RESIDENT
	beq.S	.NORES
.RES
	move	COL_MENU,d0
	move.b	#'R',d0
	move	d0,-2(a6)
.NORES	
	move	#$8000,(a6)+

	bsr	AFF_XY
.FIN	
	rts
	
*------------------------------------------------------------------------------	
* GESTION COMPLETE de la barre de menu
*------------------------------------------------------------------------------	
GERE_MENU::
	bsr	INIT_CTRLA
	bsr	INIT_IO_SIZE

	xref	get_key
	st	ACTIF_MENU
.LOOP	
	*---------------*
	* AFFICHE LA BARRE DE MENU
	*---------------*
	bsr	DRAW_MENU
	
	bsr	get_key
	
	cmp.b	#$01,d0		;esc
	beq	.FIN
	cmp.b	#$44,d0		;F10
	beq	.FIN
	cmp.b	#$4d,d0
	beq.s	.droite	
	cmp.b	#$4b,d0
	beq.s	.gauche	
	cmp.b	#$1c,d0
	beq.s	.select_menu
	cmp.b	#$50,d0
	beq.s	.select_menu
	bra.S	.LOOP
	
	*-------------*				

.droite
	lea	MENU_BAR,a0
	move	CURRENT_MENU,d0
	addq	#1,d0
	divu	2(a0),d0	;current/nb entree
	swap	d0
	move	d0,CURRENT_MENU
	bra	.LOOP
	
	*-------------*				

.gauche
	lea	MENU_BAR,a0
	move	CURRENT_MENU,d0
	subq	#1,d0
	divu	2(a0),d0	;current/nb entree
	swap	d0
	move	d0,CURRENT_MENU
	bra	.LOOP
	
	*-------------*				

.select_menu
	lea	MENU_BAR,a0
	move	CURRENT_MENU,d0	
	move.l	(4,a0,d0.w*4),a0
	bsr	GERE_DEROULANT
	bra	.LOOP

	*-------------*				
.FIN
	clr	ACTIF_MENU
	xref	set_all_flags	
	jsr	set_all_flags	
	rts
*------------------------------------------------------------------------------
*	GERE DEROULANT
* routine de gestion complete du menu deroulant
*------------------------------------------------------------------------------
*IN
* a0		ptr menu
*------------------------------------------------------------------------------
GERE_DEROULANT
	local_raz
	local.w	current
	local_reserve				
	
	move	#-1,current(a6)
.LOOP
	move	current(a6),d0

	bsr	DRAW_DEROULANT

	bsr	get_key
	
	cmp.b	#$01,d0		;esc
	beq	.FIN
	cmp.b	#$48,d0
	beq.s	.haut
	cmp.b	#$50,d0
	beq.s	.bas
	cmp.b	#$1c,d0
	beq.s	.select
	cmp.b	#$4d,d0
	beq.s	.droite	
	cmp.b	#$4b,d0
	beq	.gauche	

	bra	.LOOP
.FIN	
	xref	CLS_SCREEN,AFFICHE,set_all_flags
	bsr	set_all_flags
	bsr	CLS_SCREEN
	bsr	AFFICHE
	local_free
	rts

.haut	move	current(a6),d0
	subq	#1,d0
	divu	2(a0),d0
	swap	d0
	move	d0,current(a6)
	bra	.LOOP

.bas	move	current(a6),d0
	addq	#1,d0
	divu	2(a0),d0
	swap	d0
	move	d0,current(a6)
	bra	.LOOP
.select
	move	current(a6),d0
	bmi.S	.FIN
	jsr	([16,a0,d0.w*8])	
	
	*---------------------*
	* on force … quitter le menu
	*---------------------*
	bsr	set_all_flags
	local_free
	addq	#4,sp
	clr	ACTIF_MENU
	rts
				
	;bra	.FIN
.droite
	lea	MENU_BAR,a0
	move	CURRENT_MENU,d0
	addq	#1,d0
	divu	2(a0),d0	;current/nb entree
	swap	d0
	move	d0,CURRENT_MENU
	move	#0,current(a6)

	movem.l	d0-a6,-(sp)
	bsr	set_all_flags
	bsr	CLS_SCREEN
	bsr	AFFICHE

	movem.l	(sp)+,d0-a6
	move.l	(4,a0,d0.w*4),a0
	bra	.LOOP

.gauche
	lea	MENU_BAR,a0
	move	CURRENT_MENU,d0
	subq	#1,d0
	divu	2(a0),d0	;current/nb entree
	swap	d0
	move	d0,CURRENT_MENU
	move	#0,current(a6)

	movem.l	d0-a6,-(sp)
	bsr	set_all_flags
	bsr	CLS_SCREEN
	bsr	AFFICHE

	movem.l	(sp)+,d0-a6
	move.l	(4,a0,d0.w*4),a0
	bra	.LOOP
	
	
*------------------------------------------------------------------------------
*	DRAW_DEROULANT
* routine d'affichage d'un menu deroulant
*------------------------------------------------------------------------------
*IN
* a0		ptr menu
* d0		current
*------------------------------------------------------------------------------
DRAW_DEROULANT

	move	d0,d4
	move	2(a0),d7	;nb entrees
	subq	#1,d7
	bmi	.FIN
	move.l	4(a0),d6	;x:y
	move	#1,d6		;y=1
	lea	12(a0),a1	;premiere entree 
	addq	#1,d4
.LOOP_ENTREE	
	lea	LINE,a5
	move.l	(a1),a2
	addq	#8,a1		;entree suivante
	move.l	d6,(a5)+
	move	RESO_X,d5
	subq	#1,d5
	move.b	COL_MENU,(a5)+
	move.b	#'³',(a5)+
	
	*---------------*
	* entree active ?
	* -> change de couleur
	*---------------*
	move	COL_MENU,d0
	subq	#1,d4
	bne.s	.OK0
	move	COL_NOR,d0	
.OK0		

.COP	move.b	(a2)+,d0
	beq.s	.FF
	move	d0,(a5)+
	dbra	d5,.COP
	bra.s	.TERM
.FF	move.b	COL_MENU,(a5)+
	move.b	#'³',(a5)+
.TERM	move	#$8000,(a5)+

	*---------------*
	* AFFICHE LA LIGNE
	*---------------*
	bsr	AFF_XY
	
	addq	#1,d6		;ligne suivante
	dbra	d7,.LOOP_ENTREE
	
	subq	#8,a1
	move.l	(a1),a2		;derniere entree
	lea	LINE,a5
	move.l	d6,(a5)+
	move	COL_MENU,d0

	move.b	#'À',d0
	move	d0,(a5)+
	tst.b	(a2)+
	beq.s	.COURT
	move.b	#'Ä',d0

.ADD	move	d0,(a5)+
	tst.b	(a2)+
	bne.s	.ADD	
	
	move.b	#'Ù',d0
	move	d0,(a5)+
	move	#$8000,(a5)
	
.COURT	
	bsr	AFF_XY
.FIN
	rts
		
	
	
	
*------------------------------------------------------------------------------
* INIT_CTRLA
* 	met la petite coche ds le Menu si voir en ctrl A est actif
*------------------------------------------------------------------------------
INIT_CTRLA
	move.b	#' ',ctrla
	xref	voir_ctrl_a
	tst	voir_ctrl_a
	beq.S	.FIN
	move.b	#'¯',ctrla
.FIN	rts
		
*------------------------------------------------------------------------------
* INIT_IO_SIZE
*	met la petite coche en face de l'entr‚e qui convient
*------------------------------------------------------------------------------
INIT_IO_SIZE
	xref	IO_SIZE
	move.b	#' ',io32		
	move.b	#' ',io16		
	move.b	#' ',io8
	move	IO_SIZE,d0
	beq	.IO8
	cmp	#1,d0
	beq	.IO16
	cmp	#1,d0
	beq	.IO32
.IO32	move.b	#'¯',io32
	bra.S	.FIN
.IO16	move.b	#'¯',io16
	bra.S	.FIN
.IO8	move.b	#'¯',io8
	
.FIN
	rts
	
*------------------------------------------------------------------------------


*------------------------------------------------------------------------------
* les routines des menus...
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* about_rout
* on zoom la premiere fenetre dispo
*------------------------------------------------------------------------------
about_rout
	xref	ZOOM_WINDOW,QUIT_ZOOM,ZOOM
	xref	WINDOW_LIST,BUFFER_WINDOW
	xref	GEN_DIVERS
	xref	TITRE,CORP,BOTTOM,CLOSE_WIN


	movem.l	d0-a6,-(sp)

	move.l	ZOOM_WINDOW,d0
	beq.s	GO_DIRECTORY
	bsr	QUIT_ZOOM	
GO_DIRECTORY
	xref	ACTIVE_WINDOW,SAVE_ACTIVE
	move.l	ACTIVE_WINDOW,SAVE_ACTIVE

	*------------------*
	* recherche une fenetre libre
	*------------------*
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.SCAN	tst.l	(a0)+
	bne.s	.SCAN
	subq	#4,a0
	
	move.l	a0,d0
	sub.l	#WINDOW_LIST,d0
	asr.l	#2,d0		;no du slot

	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a1
	move.l	a1,(a0)
	move.l	a1,ACTIVE_WINDOW
	move	#T_INFO,type(a1)
	move.l	#ABOUT_MES,adr_debut(a1)
	
	bsr	ZOOM
	

	move.l	ACTIVE_WINDOW,a0				
	
	bsr.l	GEN_DIVERS

	bsr	CLS_SCREEN

	move.l	ACTIVE_WINDOW,a0				
	
	bsr	TITRE		
	bsr	CORP
	bsr	BOTTOM

	xref	get_key
.WAIT	
	bsr	get_key
	cmp.b	#1,d0
	bne.s	.WAIT

	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre
	bsr	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW

	movem.l	(sp)+,d0-a6
	
	rts	

null_rout
	rts
	

help_rout
	xref	ZOOM_WINDOW,QUIT_ZOOM,ZOOM
	xref	WINDOW_LIST,BUFFER_WINDOW
	xref	GEN_DIVERS
	xref	TITRE,CORP,BOTTOM,CLOSE_WIN


	movem.l	d0-a6,-(sp)

	move.l	ZOOM_WINDOW,d0
	beq.s	GO_DIRECTORY1
	bsr	QUIT_ZOOM	
GO_DIRECTORY1
	xref	ACTIVE_WINDOW,SAVE_ACTIVE
	move.l	ACTIVE_WINDOW,SAVE_ACTIVE

	*------------------*
	* recherche une fenetre libre
	*------------------*
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.SCAN	tst.l	(a0)+
	bne.s	.SCAN
	subq	#4,a0
	
	move.l	a0,d0
	sub.l	#WINDOW_LIST,d0
	asr.l	#2,d0		;no du slot

	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a1
	move.l	a1,(a0)
	move.l	a1,ACTIVE_WINDOW
	move	#T_INFO,type(a1)
	move.l	#HELP_MES,adr_debut(a1)
	
	bsr	ZOOM
	

	move.l	ACTIVE_WINDOW,a0				
	
	
	bsr.l	GEN_DIVERS

	move	#100,max_ligne(a0)
	move	#80+14,max_col(a0)



	bsr	CLS_SCREEN

	move.l	ACTIVE_WINDOW,a0				
	
	bsr	TITRE		
	bsr	CORP
	bsr	BOTTOM

	xref	get_key
.WAIT	
	bsr	get_key
	cmp.b	#1,d0
	bne.s	.WAIT

	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre
	bsr	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW

	movem.l	(sp)+,d0-a6
	
	rts	




togle_ctrla
	bchg	#0,voir_ctrl_a+1
	rts
	
	xref	IO_SIZE
set_io32
	move	#2,IO_SIZE
	rts
set_io16
	move	#1,IO_SIZE
	rts
set_io8
	move	#0,IO_SIZE
	rts
	

		DATA

*------------------------------------------------------------------------------
* la barre de menu de CENTINEL
*------------------------------------------------------------------------------

MENU_BAR::	dc	0		;type= menu bar
		dc	4		;nb entree de menu deroulant
		dc.l	menu_info,menu_prefs,menu_video,menu_options


menu_info	*--------------------------------------------------------------
		dc	1		;type= menu deroulant
		dc	2		;nb d'entrees
		dc.l	0		;x:y
		dc.l	.titre
		dc.l	.about,about_rout
		dc.l	.help,help_rout
		ifne	(LANGUAGE=FRANCAIS)
.titre		dc.b	'CENTINEL  ',0	
.about		dc.b	' A propos de CENTinel',0	
.help		dc.b	' *---    Help    ---*',0	
		endc
		ifne	(LANGUAGE=ANGLAIS)
.titre		dc.b	'CENTINEL  ',0	
.about		dc.b	' About CENTinel',0	
.help		dc.b	' *--  Help  --*',0	
		endc		
		even



menu_prefs	*--------------------------------------------------------------	
		dc	1		;type= menu deroulant
		dc	2		;nb d'entrees
		dc.l	0		;x:y
		dc.l	.titre
		xref	LOAD_PREFS
		dc.l	.load,LOAD_PREFS
		xref	WRITE_PREFS
		dc.l	.save,WRITE_PREFS

		
		ifne	(LANGUAGE=FRANCAIS)
.titre		dc.b	'PREFERENCES  ',0	
.load		dc.b	' Charge un .INF ',0	
.save		dc.b	' Sauve un .INF  ',0	
		endc		

		ifne	(LANGUAGE=ANGLAIS)
.titre		dc.b	'PREFERENCES  ',0	
.load		dc.b	' Load .INF ',0	
.save		dc.b	' Save .INF ',0	
		endc		
		even
		


menu_video::	*--------------------------------------------------------------
		dc	1
		dc	0
		dc.l	0	
		dc.l	.titre
		dc.l	.mode0,0
		dcb.l	7*2,0

		ifne	(LANGUAGE=FRANCAIS)
.titre		dc.b	'MODE VIDEO  ',0
.mode0		dc.b	' 9999 x 9999',0
		dcb.b	8*13,0
		endc
		ifne	(LANGUAGE=ANGLAIS)
.titre		dc.b	'VIDEO MODE  ',0
.mode0		dc.b	' 9999 x 9999',0
		dcb.b	8*13,0
		endc
		even		



menu_options	*--------------------------------------------------------------
		dc	1		;type= menu deroulant
		dc	4		;nb d'entrees
		dc.l	0		;x:y
		dc.l	.titre
		dc.l	ctrla,togle_ctrla
		dc.l	io32,set_io32
		dc.l	io16,set_io16
		dc.l	io8,set_io8


		ifne	(LANGUAGE=FRANCAIS)
.titre		dc.b	'OPTIONS  ',0	
ctrla		dc.b	' Voir en R&B  ',0
io32		dc.b	' E/S 32 bits  ',0
io16		dc.b	' E/S 16 bits  ',0
io8		dc.b	' E/S 08 bits  ',0
		endc
		ifne	(LANGUAGE=ANGLAIS)
.titre		dc.b	'OPTIONS  ',0	
ctrla		dc.b	' See when R&B ',0
io32		dc.b	' I/O 32 bits  ',0
io16		dc.b	' I/I 16 bits  ',0
io8		dc.b	' I/I 08 bits  ',0
		endc
		even


CURRENT_MENU	dc	0
ACTIF_MENU	dc	0
ABOUT_MES	incbin	about.bin
HELP_MES	incbin	help.bin
