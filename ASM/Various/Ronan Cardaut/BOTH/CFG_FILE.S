t;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	SECTION	TEXT
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------




;------------------------------------------------------------------------------
	output	d:\centinel\both\cfg_file.o

	include	both\GEM.EQU
	include	d:\centinel\both\define.s
	include	both\LOCALMAC.S

;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;SAVE_INIT_PATH
; le INIT_PATH est le repertoire courant
;------------------------------------------------------------------------------
SAVE_INIT_PATH::
	movem.l	d0-a6,-(sp)

	lea	INIT_PATH,a6
	GEM	Dgetdrv

	move.b	d0,d1
	add.b	#'A',d1
	move.b	d1,(a6)+
	move.b	#':',(a6)+

	clr	-(sp)
	move.l	a6,-(sp)
	GEM	Dgetpath
	
	movem.l	(sp)+,d0-a6
	rts
;------------------------------------------------------------------------------
		



;------------------------------------------------------------------------------
;SAVE_CENTINEL_PATH
; il faut trouver le CENTINEL_PATH dans la chaine d'environnement
; attention, par convention on a pas de "\" … la fin du chemin
;------------------------------------------------------------------------------
;*IN
;	ptr chaine d'environnement
;*OUT
;	CENTINEL_PATH est rempli
;------------------------------------------------------------------------------
SAVE_CENTINEL_PATH::
	movem.l	d0-a6,-(sp)

	lea	CENTINEL_PATH,a1
	clr.b	(a1)
.NEW_STRING
	tst.b	(a0)
	beq	.CURRENT_PATH
.STRING	
	tst.b	(a0)
	beq	.NEXT_STRING
	cmp.l	#'CENT',(a0)
	beq	.FFOUND
.CHAR	addq	#1,a0
	bra.s	.STRING
.NEXT_STRING
	addq	#1,a0
	bra.S	.NEW_STRING

	;------------------
	; on recopie la chaine trouv‚e
	;------------------
.FFOUND
	cmp.l	#'INEL',4(a0)
	bne	.CHAR
	cmp.l	#'_PAT',8(a0)
	bne	.CHAR
	cmp	#'H=',12(a0)
	bne	.CHAR
	add	#14,a0

.COP0	move.b	(a0)+,(a1)+
	bne.s	.COP0			
	cmp.b	#'\',-2(a1)
	bne.s	.FIN
	clr.b	-2(a1)
.FIN
	movem.l	(sp)+,d0-a6
	rts


.CURRENT_PATH
	;------------------
	; on prend le r‚pertoire courant comme CENTINEL_PATH 
	;------------------
	move.l	a1,a6

	GEM	Dgetdrv

	move.b	d0,d1
	add.b	#'A',d1
	move.b	d1,(a6)+
	move.b	#':',(a6)+

	clr	-(sp)
	move.l	a6,-(sp)
	GEM	Dgetpath

	bra	.FIN
;------------------------------------------------------------------------------



*------------------------------------------------------------------------------
*BOOT_PREFS
* lecture  du centinel .inf au lancement
*CENTINEL r‚sident:	ds le CENTINEL_PATH
*			ds le INIT_PATH
*			par d‚faut						
*
*
*CENTINEL normal	ds le INIT_PATH
*			ds le CENTINEL_PATH
*			par d‚faut						
*------------------------------------------------------------------------------
BOOT_PREFS::
	xref	flag_res				
	tst.b	flag_res				
	bne	CENT_RESIDENT
	
*----------------------------*
* CENTINEL NORMAL
*----------------------------*


	*----------------------------*
	* d'abord dans le chemin courant
	*----------------------------*
	lea	INIT_PATH,a0
	lea	CFG_FILE,a1
	move	#255-1,d0
.COP0	move.b	(a0)+,(a1)+
	dbeq	d0,.COP0
	move.b	#'\',-1(a1)
	lea	INF_NAME,a0
	move	#255-1,d0	
.COP1	move.b	(a0)+,(a1)+
	dbeq	d0,.COP1

	lea	CFG_FILE,a0
	bsr	READ_PREFS
	tst.l	d0
	beq	FIN
		
	*----------------------------*
	* sinon ds le CENTINEL_PATH
	*----------------------------*

	lea	CENTINEL_PATH,a0
	lea	CFG_FILE,a1
	move	#255-1,d0	
.COP2	move.b	(a0)+,(a1)+
	dbeq	d0,.COP2
	move.b	#'\',-1(a1)
	lea	INF_NAME,a0
	move	#255-1,d0	
.COP3	move.b	(a0)+,(a1)+
	dbeq	d0,.COP3

	lea	CFG_FILE,a0
	bsr	READ_PREFS
	tst.l	d0
	beq	FIN



DEFAULT
	*----------------------------*
	* sinon la config par d‚faut
	*----------------------------*

	lea	DEFAULT_FILE,a0
	move.l	#END_DEFAULT_FILE,d0
	sub.l	a0,d0
		
	bsr	INF_LOADED
	
	tst.l	d0
	beq.s	FIN

	*----------------------------*
	* la config par d‚faut est invalide
	* changez les programmeurs !!
	*----------------------------*
	illegal		
	
FIN
	rts


*----------------------------*
* CENTINEL RESIDENT
*----------------------------*
CENT_RESIDENT

	*----------------------------*
	* d'abord dans le CENTINEL_PATH
	*----------------------------*
	lea	CENTINEL_PATH,a0
	lea	CFG_FILE,a1
	move	#255-1,d0	
.COP0	move.b	(a0)+,(a1)+
	dbeq	d0,.COP0
	move.b	#'\',-1(a1)
	lea	INF_NAME,a0
	move	#255-1,d0	
.COP1	move.b	(a0)+,(a1)+
	dbeq	d0,.COP1

	lea	CFG_FILE,a0
	bsr	READ_PREFS
	tst.l	d0
	beq	FIN
		
	*----------------------------*
	* sinon ds le INIT_PATH
	*----------------------------*

	lea	INIT_PATH,a0
	lea	CFG_FILE,a1
	move	#255-1,d0	
.COP2	move.b	(a0)+,(a1)+
	dbeq	d0,.COP2
	move.b	#'\',-1(a1)
	lea	INF_NAME,a0
	move	#255-1,d0	
.COP3	move.b	(a0)+,(a1)+
	dbeq	d0,.COP3

	lea	CFG_FILE,a0
	bsr	READ_PREFS
	tst.l	d0
	beq	FIN

	*----------------------------*
	* sinon PAR DFAULT
	*----------------------------*
	BRA	DEFAULT	
	


*------------------------------------------------------------------------------
* LOAD PREFS: chargement d'un fichier de prefs … partir du menu
*------------------------------------------------------------------------------
LOAD_PREFS::
	movem.l	d0-a6,-(sp)
	
	
	xref	dsp_name
	
	lea	LD_PREFS,a0
	lea	MASK,a1
	lea	dsp_name,a2
	
	xref	FILE_SELECTOR	
	bsr.l	FILE_SELECTOR	
	
	
	tst	d0
	bne	.FIN
	lea	dsp_name,a0
	bsr	READ_PREFS



	xref	VIDEO_SYSTEME
	
	move.l	VIDEO_SYSTEME,d0
	cmp.l	#"_DOL",d0
	bne.S	.TOS		;pas dispo pour le TOS
	
	xref	DOLMEN_CH_REZ	
	bsr	DOLMEN_CH_REZ	
	bra.S	.FIN

.TOS
	xref	TOS_VIDEO
	bsr	TOS_VIDEO
	
	
.FIN	movem.l	(sp)+,d0-a6
	rts


*------------------------------------------------------------------------------
* place le flag_res selon qu'on est lanc‚ du TSR manager ou non
* attention flag_res vaut 0 si on est ds le dossier auto...
* STEPHANE, tu marches en logique invers‚e ou quoi?
*------------------------------------------------------------------------------
CHECK_AUTO::
	*-----------------------*
	* le nom de notre programme
	* est il "RENTINEL" ?
	*-----------------------*
	move.l	([$4f2],$28),a0
	move.l	(a0),a0
	move.l	$24(a0),a0
	move.l	$20(a0),a0
	
	cmp.b	#'R',30(a0)
	seq	flag_res
	rts
		
			




	ifne	0
	xref	flag_res

	*-----------------------*
	* on cherche si le debugueur
	* est lanc‚ depuis le dossier auto
	* cad si le cookye "_TSR" est pr‚sent
	*-----------------------*
	sf	flag_res

	move.l	#'_TSR',d0
	move.l	$5a0.w,a0
	tst.l	a0
	beq	.FIN		;pas de cooky jar
.youpz
	move.l	(a0),d1
	beq	.FIN		;vid‚ le cooky jar !
	cmp.l	d1,d0
	beq.s	.FOUND		;trouv‚ !!
	lea	8(a0),a0
	bra.s	.youpz
.FOUND	tst.l	4(a0)		;dossier auto?
	beq.s	.FIN		;non
	st	flag_res
.FIN	
	rts
	endc

*------------------------------------------------------------------------------


*------------------------------------------------------------------------------
* READ_PREFS
* chargement du .inf
*------------------------------------------------------------------------------
*in:
*	a0	ptr nom de fichier
*out:
*	d0.l	0	ok la cfg est charg‚e
*		-1	file not found
*		-2	wrong file format
*------------------------------------------------------------------------------
READ_PREFS::

	*-------------------*
	* charge le .INF
	*-------------------*
	
	bsr	LOAD_INF
	tst.l	d0
	bpl	INF_LOADED
.ERREUR0		;file not found => on quitte		
	moveq	#-1,d0
	rts
	

INF_LOADED	
	move.l	a0,-(sp)	;sauve ptr file	


	*-------------------*
	* on commence par clearer
	* les slots
	* et la fenetre active
	*-------------------*

	lea	WINDOW_LIST,a1
	move	#31,d7
.CLR	clr.l	(a1)+
	dbra	d7,.CLR
	clr.l	ACTIVE_WINDOW



	*-------------------*
	* scanne et d‚cortique le .INF
	*-------------------*
	bsr	PARSE_FILE	
	tst	d0		;bien charg‚ ?
	bmi	.WRONG_FORMAT

	GEM	Mfree		

.SUITE	
	*-------------------*
	* Si on n'a pas de fenetre active
	* on met la premiere dispo
	*-------------------*
	xref	WINDOW_LIST,ACTIVE_WINDOW
	tst.l	ACTIVE_WINDOW
	bne.s	.NO_INF1
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP	tst.l	(a0)+
	dbne	d7,.LOOP
	tst	d7
	bpl	.OK0
	illegal				; on a aucune fenetre d'ouverte ! c'est interdit !!
.OK0
	move.l	-(a0),ACTIVE_WINDOW
.NO_INF1

	
	*-------------------*
	* On tronque les fenetres
	* mais on passe temporairement des 
	* coordonn‚es pixel en coordonn‚es char
	*-------------------*
	move	RESO_X,d0
	lsr	#3,d0
	move	d0,RESO_X

	move	RESO_Y,d0
	ifeq	(size_font=8)
	lsr	#4,d0
	else
	lsr	#3,d0
	endc
	move	d0,RESO_Y

	xref	TRONQUE_FENETRES
	bsr	TRONQUE_FENETRES

	move	RESO_X,d0
	lsl	#3,d0
	move	d0,RESO_X

	move	RESO_Y,d0
	ifeq	(size_font=8)
	lsl	#4,d0
	else
	lsl	#3,d0
	endc
	move	d0,RESO_Y

	moveq	#0,d0		;ok tout a march‚
	rts


	*-------------------*


.WRONG_FORMAT			;le .inf ‚tait invalide !!

	GEM	Mfree		;MFREE(buffer_file)

	moveq	#-1,d0
	rts

	ifne	0		

	move.l	#MES_DEFAULT_CFG,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key



	bra	.PAR_DEFAUT	

.OK12
	GEM	Mfree		;MFREE(buffer_file)

	bra.s	.SUITE
		
.PAR_DEFAUT
	*-------------------*
	* on a pas trouv‚ le .INF
	* on met une config par d‚faut
	*-------------------*
	lea	DEFAULT_FILE,a0
	move.l	#END_DEFAULT_FILE,d0
	sub.l	a0,d0
		
	bsr	PARSE_FILE

	tst	d0		;bien charg‚ ?
	beq	.SUITE
	
		
.BOUM	
	illegal

.SUITE	
	*-------------------*
	* Si on n'a pas de fenetre active
	* on met la premiere dispo
	*-------------------*
	xref	WINDOW_LIST,ACTIVE_WINDOW
	tst.l	ACTIVE_WINDOW
	bne.s	.NO_INF1
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP	tst.l	(a0)+
	bne.s	.OK0
	dbra	d7,.LOOP
	bra	.PAR_DEFAUT
	illegal			;on a pris la config par d‚faut, mais ya tjrs pas de fenetre !!!
.OK0
	move.l	-(a0),ACTIVE_WINDOW
.NO_INF1
	
	
	*-------------------*
	* On tronque les fenetres
	* mais on passe temporairement des 
	* coordonn‚es pixel en coordonn‚es char
	*-------------------*
	move	RESO_X,d0
	lsr	#3,d0
	move	d0,RESO_X

	move	RESO_Y,d0
	ifeq	(size_font=8)
	lsr	#4,d0
	else
	lsr	#3,d0
	endc
	move	d0,RESO_Y

	xref	TRONQUE_FENETRES
	bsr	TRONQUE_FENETRES

	move	RESO_X,d0
	lsl	#3,d0
	move	d0,RESO_X

	move	RESO_Y,d0
	ifeq	(size_font=8)
	lsl	#4,d0
	else
	lsl	#3,d0
	endc
	move	d0,RESO_Y

	rts
			
	endc


*------------------------------------------------------------------------------
* PARSER de CENTINEL.INF
*------------------------------------------------------------------------------
*IN:
*	a0:	ptr sur le fichier
*	d0	taille du fichier
*------------------------------------------------------------------------------
PARSE_FILE

	lea	(a0,d0.l),a6		;fin fichier

	lea	CONFIG,a1
	bsr	STRCMP
	tst	d0
	beq	NEXTLINE
	
	moveq	#-1,d0
	bra	FIN_PARSE	

LOOP_SECTION
	move.b	(a0),d0
	cmp.b	#'#',d0
	beq.s	NEXTLINE
	cmp.b	#$d,d0
	beq.s	NEXTLINE

	*-------------------*
	* Ici on a ni un commentaire
	* ni un CR/LF
	* donc peut etre un d‚but de section
	*-------------------*
	
	cmp.l	#'SECT',(a0)
	bne.s	NEXTLINE
	cmp	#'IO',4(a0)
	bne.s	NEXTLINE
	cmp.b	#'N',6(a0)
	bne.s	NEXTLINE
	addq	#8,a0

	lea	SCREEN,a1
	bsr	STRCMP
	tst	d0
	beq	LOAD_SCREEN

	lea	COLOR,a1
	bsr	STRCMP
	tst	d0
	beq	LOAD_COLOR

	lea	WINDOW,a1
	bsr	STRCMP
	tst	d0
	beq	LOAD_WINDOW

	lea	S040,a1
	bsr	STRCMP
	tst	d0
	beq	LOAD_40
	
	
NEXTLINE
	cmp	#$0d0a,(a0)
	beq.s	.F0
	addq	#1,a0
	cmp.l	a6,a0
	blt	NEXTLINE
.F0	addq	#2,a0
	cmp.l	a6,a0
	blt	LOOP_SECTION
	moveq	#0,d0
FIN_PARSE	
	rts
		
		
	*-------------------*
	* traite la section 40
	*-------------------*
LOAD_40
	
	lea	ENDSEC,a1
	bsr	STRCMP
	tst	d0
	beq	NEXTLINE
	
	lea	DETOURNE,a1
	bsr	STRCMP
	tst	d0
	beq.s	.DETOURNE

	lea	VECTEUR,a1
	bsr	STRCMP
	tst	d0
	beq.s	.VECTEUR

	lea	VIEW_CTRL_A,a1
	bsr	STRCMP
	tst	d0
	beq.s	.VIEW

	lea	IPL_INTERNE,a1
	bsr	STRCMP
	tst	d0
	beq.s	.IPL

	bsr	NEW_LINE	
		
	bra	LOAD_SCREEN
	
.DETOURNE
	bsr	READ_NUM
	move.b	#1,(table_autori-2,d0.w)

	bra	LOAD_40

.VECTEUR
	bsr	READ_NUM
	move	d0,EXEP_ARRET

	bra	LOAD_40

.VIEW
	bsr	READ_NUM
	xref	voir_ctrl_a
	move	d0,voir_ctrl_a

	bra	LOAD_40

.IPL
	bsr	READ_NUM
	xref	IPL_INT
	move	d0,IPL_INT

	bra	LOAD_40
	
	
		
		
LOAD_WINDOW
	*-------------------*
	* traite une section WINDOW
	*-------------------*

	xref	WINDOW_LIST,BUFFER_WINDOW,BUFFER_EXPR

	lea	NB,a1
	bsr	STRCMP
	tst	d0
	bne	NEXTLINE		;indispensable
	
	bsr	READ_NUM
	cmp	#31,d0
	bgt	NEXTLINE

	*-------------------*
	* recupere l'adresse de la fenetre
	* et la place ds windows list
	*-------------------*
	move	d0,d1
	mulu	#Size_win,d1
	lea	(BUFFER_WINDOW.l,d1.w),a3
	move.l	a3,(WINDOW_LIST,d0.w*4)
	move	d0,d1
	lsl	#8,d1			;d1*256
	lea	(BUFFER_EXPR,d1.w),a4	
	;move.l	a4,ptr_expr(a3)		;ptr expression

	move	#4,Tab_Value(a3)	;force l'init

LOOP_WIN
	
	lea	ENDSEC,a1
	bsr	STRCMP
	tst	d0
	beq	NEXTLINE

	lea	TYPE,a1
	bsr	STRCMP
	tst	d0
	beq	.TYPE		

	lea	SIZE,a1
	bsr	STRCMP
	tst	d0
	beq	.SIZE		
	
	lea	MEM,a1
	bsr	STRCMP
	tst	d0
	beq	.MEM

	lea	ADR,a1
	bsr	STRCMP
	tst	d0
	beq	.ADR

	lea	LOCK,a1
	bsr	STRCMP
	tst	d0
	beq	.LOCK

	lea	SCROLL,a1
	bsr	STRCMP
	tst	d0
	beq	.SCROLL

	lea	ACTIVE,a1
	bsr	STRCMP
	tst	d0
	beq	.ACTIVE
	

	lea	TAB_ID,a1
	bsr	STRCMP
	tst	d0
	beq	.TAB
	
	
	bsr	NEW_LINE	
	bra	LOOP_WIN
	

.TYPE
	*-------------------*
	* Lit le type de fenetre
	*-------------------*
	bsr	READ_NUM
	move	d0,type(a3)	;type
	bra	LOOP_WIN
	

.SIZE
	*-------------------*
	* la taille de la fenetre
	*-------------------*
	bsr	READ_NUM
	move	d0,W_X1(a3)	;X
	bsr	READ_NUM
	move	d0,W_Y1(a3)	;X
	bsr	READ_NUM
	move	d0,Largeur(a3)	;L
	bsr	READ_NUM
	move	d0,Hauteur(a3)	;H
	bra	LOOP_WIN
	
	
.MEM	
	*-------------------*
	* MEM TYPE
	*-------------------*
	bsr	READ_NUM
	move	d0,mem_type(a3)	;mem type
	bra	LOOP_WIN

.ADR	
	*-------------------*
	* adresse fenetre
	*-------------------*
	bsr	READ_NUM
	move.l	d0,adr_debut(a3)	;adr debut	
	clr.l	adr_fin(a3)		;adr fin
	bra	LOOP_WIN
	
.LOCK
	*-------------------*
	* pas d'expression sauv‚e pour l'instant
	*-------------------*
	;addq	#1,a0
	clr.l	ptr_expr(a3)	;expression
	cmp	#'""',(a0)
	beq.s	.SUITE
	move.l	a4,ptr_expr(a3)
.OK0	cmp.b	#'"',(a0)+
	bne.s	.OK0

.COP	move.b	(a0)+,d0
	cmp.b	#'"',d0
	beq.s	.ER_EXPR	;poas d'expr
	move.b	d0,(a4)+
	bra.s	.COP
.ER_EXPR	
	clr.b	(a4)+
.SUITE	
	bra	LOOP_WIN


.SCROLL	
	*-------------------*
	* decalage dans la fenetre
	*-------------------*
	clr.l	start_col(a3)	;init au cas ou le fichier de prefs n'est pas … jour
	
	bsr	READ_NUM
	move	d0,start_col(a3)	
	bsr	READ_NUM
	move	d0,start_ligne(a3)	
	
	*-------------------*
	* DIVERS
	*-------------------*
	clr	nb_colonnes(a3)	;nb colonnes
	move	#1,flag_aff(a3)	;flag aff
	clr.l	max_ligne(a3);flag scroll down
	move	#4,Tab_Value(a3)
	
	bra	LOOP_WIN

.ACTIVE
	move.l	a3,ACTIVE_WINDOW
	bra	LOOP_WIN
	


.TAB
	*-------------------*
	* TAB VALUE
	*-------------------*
	bsr	READ_NUM
	move	d0,Tab_Value(a3)	
	bra	LOOP_WIN



			
	*-------------------*
	* traite la section COLOR
	*-------------------*
LOAD_COLOR
	xref	COL_40,COL_DSP,COL_QUICC,COL_LAB,COL_ADR,COL_FCT,COL_BKPT,COL_CHG,COL_REG,COL_MENU,COL_PC,COL_ERR_L
	
	lea	ENDSEC,a1
	bsr	STRCMP
	tst	d0
	beq	NEXTLINE
	
	lea	mcol_40,a1
	bsr	STRCMP
	tst	d0
	bne	.OK0
	lea	COL_40,a2
	bra	.READ

.OK0	lea	mcol_dsp,a1
	bsr	STRCMP
	tst	d0
	bne	.OK1
	lea	COL_DSP,a2
	bra	.READ

.OK1	lea	mcol_q,a1
	bsr	STRCMP
	tst	d0
	bne	.OK2
	lea	COL_QUICC,a2
	bra	.READ


.OK2	lea	mcol_lab,a1
	bsr	STRCMP
	tst	d0
	bne	.OK4
	lea	COL_LAB,a2
	bra	.READ

.OK4	lea	mcol_add,a1
	bsr	STRCMP
	tst	d0
	bne	.OK5
	lea	COL_ADR,a2
	bra	.READ

.OK5	lea	mcol_fct,a1
	bsr	STRCMP
	tst	d0
	bne	.OK6
	lea	COL_FCT,a2
	bra	.READ

.OK6	lea	mcol_bkp,a1
	bsr	STRCMP
	tst	d0
	bne	.OK7
	lea	COL_BKPT,a2
	bra	.READ

.OK7	lea	mcol_chg,a1
	bsr	STRCMP
	tst	d0
	bne	.OK8
	lea	COL_CHG,a2
	bra	.READ

.OK8	lea	mcol_reg,a1
	bsr	STRCMP
	tst	d0
	bne	.OK9
	lea	COL_REG,a2
	bra	.READ

.OK9	lea	mcol_menu,a1
	bsr	STRCMP
	tst	d0
	bne	.OKA
	lea	COL_MENU,a2
	bra	.READ

.OKA	lea	mcol_pc,a1
	bsr	STRCMP
	tst	d0
	bne	.OKB
	lea	COL_PC,a2
	bra	.READ

.OKB	lea	mcol_errl,a1
	bsr	STRCMP
	tst	d0
	bne	.OKC
	lea	COL_ERR_L,a2
	bra	.READ
.OKC	
.READ	

	*----------------*
	* il y a un nom en clair ?
	* 1. en francais
	* 2. en anglais
	*----------------*
	moveq	#0,d2
	moveq	#16-1,d7
	lea	ptr_color_fr,a3
.LOOP	move.l	(a3)+,a1
	bsr	STRCMP
	tst	d0
	beq	.WRI
	addq	#1,d2
	dbra	d7,.LOOP	

	moveq	#0,d2
	moveq	#16-1,d7
	lea	ptr_color_eng,a3
.LOOP1	move.l	(a3)+,a1
	bsr	STRCMP
	tst	d0
	beq	.WRI
	addq	#1,d2
	dbra	d7,.LOOP1

	bsr	READ_NUM
	move	d0,d2
.WRI	
	lsl	#8,d2
	move	d2,(a2)
	
		
	;bsr	NEW_LINE	

	bra	LOAD_COLOR

	*-------------------*
	* traite la section SCREEN
	*-------------------*
LOAD_SCREEN
	
	lea	ENDSEC,a1
	bsr	STRCMP
	tst	d0
	beq	NEXTLINE
	
	lea	RESOL,a1
	bsr	STRCMP
	tst	d0
	beq.s	.RESOL

	bsr	NEW_LINE	
		
	bra	LOAD_SCREEN
	
.RESOL	
	xref	RESO_X,RESO_Y
	bsr	READ_NUM
	move	d0,RESO_X
	bsr	READ_NUM
	move	d0,RESO_Y
	bra	LOAD_SCREEN



	*-------------------*
	* comparaison de 2 chaines
	* tab, cr, lf et _ sont saut‚s
	* si diff‚rent, a0 n'est pas modifi‚
	* CASE INSENSITIVE
	*-------------------*
STRCMP
	move.l	d1,-(sp)
	move.l	a0,-(sp)

.LOAD1	move.b	(a1)+,d1
	beq.s	.VERIF_SOURCE
	cmp.b	#'a',d1
	blt.s	.INF1
	cmp.b	#'z',d1
	bgt.s	.INF1	
	add.b	#'A'-'a',d1	;conversion en MAJ
.INF1	
	cmp.b	#' ',d1
	beq.s	.LOAD1
	cmp.b	#'	',d1
	beq.s	.LOAD1
	cmp.b	#$d,d1
	beq.s	.LOAD1
	cmp.b	#$a,d1
	beq.s	.LOAD1


.LOAD0	move.b	(a0)+,d0
	;beq.S	.EGAL
	cmp.b	#'a',d0
	blt.s	.INF0
	cmp.b	#'z',d0
	bgt.s	.INF0	
	add.b	#'A'-'a',d0	;conversion en MAJ
.INF0
	cmp.b	#' ',d0
	beq.s	.LOAD0
	cmp.b	#'	',d0
	beq.s	.LOAD0
	cmp.b	#$d,d0
	beq.s	.LOAD0
	cmp.b	#$a,d0
	beq.s	.LOAD0


	cmp.b	d0,d1
	bne.s	.DIFFERENT
	bra.s	.LOAD1
.VERIF_SOURCE
	*--------------------*	
	* la chaine est termin‚e
	* on v‚rifie que la source est 
	* termin‚e aussi
	*--------------------*	
	move.b	(a0)+,d0
	cmp.b	#'	',d0
	beq.S	.EGAL	
	cmp.b	#' ',d0
	beq.S	.EGAL	
	cmp.b	#$d,d0
	beq.S	.EGAL	
	cmp.b	#$a,d0
	beq.S	.EGAL	
.DIFFERENT
	moveq	#1,d0
	move.l	(sp)+,a0
	move.l	(sp)+,d1
	rts
.EGAL	moveq	#0,d0
	move.l	(sp)+,d1
	move.l	(sp)+,d1
	rts
			
	
	*-------------------*
	* routine rapide pour aller
	* … la prochaine ligne...
	*-------------------*
NEW_LINE
	cmp	#$0d0a,(a0)
	beq.S	.FIN
	addq	#1,a0
	bra.S	NEW_LINE
.FIN	rts
	


	
	
	ifne	0
ENTRY	MACRO
	dc	.next\@-*-2
	dc	.end\@-*-2
	dc.b	\1
.end\@
	even
	dc.l	\2
.next\@
	ENDM


LIST_CMD
	dc	14
	ENTRY	'WIN_ACT',L_ACTIF	
	ENTRY	'SCREEN',L_RESO
	ENTRY	'WINDOW',L_WIN
	*-------------------*
	* Les commandes de couleurs
	*-------------------*
	ENTRY	'COL_40',L_C40
	ENTRY	'COL_DSP',L_CDSP
	ENTRY	'COL_QUICC',L_CQUICC
	ENTRY	'COL_LABEL',L_CLAB
	ENTRY	'COL_ADDRESS',L_CADR
	ENTRY	'COL_FCT',L_CFCT
	ENTRY	'COL_BKPT',L_CBKP
	ENTRY	'COL_CHG',L_CCHG
	ENTRY	'COL_REG',L_CREG
	ENTRY	'COL_MENU',L_CMENU
	ENTRY	'COL_PC',L_CPC
	ENTRY	'COL_ERR_L',L_CERR

	endc
	
*------------------------------------------------------------------------------	
* Lecture d'un nombre dans le fichier
* il doit etre preced‚ de \ ou $ pour son type
*------------------------------------------------------------------------------	
READ_NUM
	move.b	(a0)+,d0
	cmp.b	#'\',d0
	beq.S	READ_DEC
	cmp.b	#'$',d0
	beq.S	READ_HEX
	cmp.b	#$d,d0
	beq.s	.FIN
	bra.s	READ_NUM
.FIN	rts

READ_DEC
	moveq	#0,d0	
	moveq	#0,d1
	
.LOOP	move.b	(a0)+,d1
	cmp.b	#'0',d1
	blt.s	.FIN
	cmp.b	#'9',d1
	bgt.s	.FIN
	mulu.l	#10,d0
	sub.b	#'0',d1
	and	#$f,d1
	add.l	d1,d0
	bra.s	.LOOP
	
.FIN	
	rts

READ_HEX
	moveq	#0,d0	
	
.LOOP	move.b	(a0)+,d1
	cmp.b	#'0',d1
	blt.s	.FIN
	cmp.b	#'9',d1
	ble.s	.OKDEC
	and	#$df,d1
	cmp.b	#'A',d1
	blt	.FIN
	cmp.b	#'F',d1
	bgt	.FIN
	sub	#'A'-10,d1
	bra.s	.OK0
.OKDEC
	sub.b	#'0',d1
.OK0	lsl.l	#4,d0
	add	d1,d0
	bra.s	.LOOP
	
.FIN	
	rts

*------------------------------------------------------------------------------
* Lit la fenetre active
*------------------------------------------------------------------------------
L_ACTIF
	bsr	READ_NUM
	move.l	(WINDOW_LIST,d0.w*4),d0
	beq.S	.FIN
	move.l	d0,ACTIVE_WINDOW
.FIN	rts

*------------------------------------------------------------------------------
* Lit les parametres de la fenetre
*------------------------------------------------------------------------------
L_WIN	
	xref	WINDOW_LIST,BUFFER_WINDOW,BUFFER_EXPR

	*-------------------*
	* Lit le no de fenetre
	*-------------------*
	bsr	READ_NUM
	cmp	#31,d0
	bgt	.FIN	
	


	*-------------------*
	* recupere l'adresse de la fenetre
	* et la place ds windows list
	*-------------------*
	move	d0,d1
	mulu	#Size_win,d1
	lea	(BUFFER_WINDOW.l,d1.w),a3
	move.l	a3,(WINDOW_LIST,d0.w*4)
	move	d0,d1
	lsl	#8,d1			;d1*256
	lea	(BUFFER_EXPR,d1.w),a4	
	move.l	a4,ptr_expr(a3)		;ptr expression
			
	*-------------------*
	* Lit le type de fenetre
	*-------------------*
	bsr	READ_NUM
	move	d0,type(a3)	;type

	*-------------------*
	* la taille de la fenetre
	*-------------------*
	bsr	READ_NUM
	move	d0,W_X1(a3)	;X
	bsr	READ_NUM
	move	d0,W_Y1(a3)	;X
	bsr	READ_NUM
	move	d0,Largeur(a3)	;L
	bsr	READ_NUM
	move	d0,Hauteur(a3)	;H
	
	
	
	*-------------------*
	* MEM TYPE
	*-------------------*
	bsr	READ_NUM
	
	move	d0,mem_type(a3)	;mem type

	*-------------------*
	* adresse fenetre
	*-------------------*
	
	bsr	READ_NUM
	move.l	d0,adr_debut(a3)	;adr debut	
	clr.l	adr_fin(a3)		;adr fin
	

	*-------------------*
	* pas d'expression sauv‚e pour l'instant
	*-------------------*
.L0	cmp.l	#'EXPR',(a2)
	beq.s	.OK0
	addq	#1,a2
	bra.s	.L0
.OK0	cmp.b	#'"',(a2)+
	bne.s	.OK0
	cmp.b	#'"',(a2)
	beq.s	.ER_EXPR	;poas d'expr
.COP	move.b	(a2)+,d0
	cmp.b	#'"',d0
	beq.S	.L1
	move.b	d0,(a4)+
	bra.s	.COP
.L1	clr.b	(a4)+
	bra	.SUITE
.ER_EXPR	
	clr.l	ptr_expr(a3)	;expression
	
.SUITE
	*-------------------*
	* decalage dans la fenetre
	*-------------------*
	clr.l	start_col(a3)	;init au cas ou le fichier de prefs n'est pas … jour
	
	bsr	READ_NUM
	move	d0,start_col(a3)	
	bsr	READ_NUM
	move	d0,start_ligne(a3)	
	
	*-------------------*
	* DIVERS
	*-------------------*
	clr	nb_colonnes(a3)	;nb colonnes
	move	#1,flag_aff(a3)	;flag aff
	clr.l	max_ligne(a3);flag scroll down
	move	#4,Tab_Value(a3)

.FIN
	rts
	


*------------------------------------------------------------------------------
* Charge le CENTINEL.INF
*------------------------------------------------------------------------------
*in:
*	a0:	ptr nom fichier
*out:	
*	d0	la taille du fichier ou erreur
*	a0	le pointeur sur le fichier ( handle du Malloc )
*------------------------------------------------------------------------------
LOAD_INF
	*-------------------*
	* FOPEN
	*-------------------*

	move	#0,-(sp)
	move.l	a0,-(sp)
	GEM	Fopen
	move.l	d0,d7
	bmi	.ERREUR
	*-------------------*
	* Calcul de la taille
	* du fichier....
	* par 2 FSEEK
	*-------------------*

	move	#2,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)	
	GEM	Fseek		;va … la fin

	move.l	d0,d6
		
	
	move	#0,-(sp)
	move	d7,-(sp)
	clr.l	-(sp)
	GEM	Fseek		;retourne au debut
	

	*-------------------*
	* MALLOC...
	*-------------------*
	move.l	d6,-(sp)
	
	RON_ALLOC
	
	;GEM	Malloc		;Malloc(size)
	tst.l	d0
	beq	.ERREUR	
	move.l	d0,a6
	

	*-------------------*
	* Lecture du fichier
	*-------------------*
	
	move.l	d0,-(sp)
	move.l	d6,-(sp)	
	move	d7,-(sp)
	GEM	Fread		;FREAD(size)
	
	
		
	move	d7,-(sp)
	GEM	Fclose
	move.l	a6,a0
	move.l	d6,d0
	rts
						
.ERREUR	
	moveq	#-1,d0
	rts
*------------------------------------------------------------------------------



	
		
*------------------------------------------------------------------------------
* SAUVEGARDE DES PREFERENCES
*------------------------------------------------------------------------------
* g‚n‚ration du fichier ASCII *.inf
*------------------------------------------------------------------------------
WRITE_PREFS::
	movem.l	d0-a6,-(sp)
	
	
	
	xref	BASE_VECT_DISK,REF_DISK
	move.l	BASE_VECT_DISK,a0
	lea	REF_DISK,a1
	rept	4
	cmpm.l	(a0)+,(a1)+
	bne.s	.changed
	endr
	bra.s	.norm
.changed
	xref	MES_VEC_CHG,MESSAGE_ADR		; on verifie les vecteurs disk
	xref	PETIT_MESSAGE,MES_SPACE,get_key
	move.l	#MES_VEC_CHG,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key
	move.l	#MES_SPACE,MESSAGE_ADR
	cmp.w	#$15,d0
	beq.s	.norm
	cmp.w	#$18,d0
	beq	.norm
	movem.l	(sp)+,d0-a6		; si non on quitte
	rts
.norm
		
	clr	-(sp)
	pea	CFG_FILE	;ON SAUVE LA OU ON A CHARG
	GEM	Fcreate
	move.l	d0,d7		;handle

		
	xref	MES_PREF_WRIT,MESSAGE_ADR
	move.l	#MES_PREF_WRIT,MESSAGE_ADR


	*-----------------*
	* le marker  "fichier de config"
	*-----------------*
	lea	CONFIG,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR
	lea	CRLF,a0
	bsr	WRITE_STR


	*-----------------*
	* ce qui concerne l'‚cran...
	*-----------------*

	bsr	WRITE_SCREEN_SECTION
		
	*-----------------*
	* COLOR....le big morceau
	*-----------------*

	bsr	WRITE_COLOR_SECTION


	*-----------------*
	* les fenetres....
	* le very very big morceau
	*-----------------*
	
	bsr	WRITE_ALL_WINDOWS
	

	*-----------------*
	* les prefs trace 40 & co
	*-----------------*
	bsr	WRITE_40_SECTION
	

	lea	CRLF,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR


	move	d7,-(sp)
	GEM	Fclose
	
	xref	tempo
	sf	tempo
		
	movem.l	(sp)+,d0-a6
	
	rts
	
	
;------------------------------------------------------------------------------
; tout ce qui concerne le trace & co pour le 40
;------------------------------------------------------------------------------
WRITE_40_SECTION
;*IN
;	d0:	handle

	movem.l	d0/d1/d7/a0/a3,-(sp)
	move.l	d0,d7


	*--------------*
	* SECTION 68040
	*--------------*
	
	lea	SECTION,a0
	bsr	WRITE_STR

	lea	S040,a0
	bsr	WRITE_STR
	
	lea	CRLF,a0
	bsr	WRITE_STR
	
	*---------------*
	*‚crit toutes les exeptions … d‚tourner
	*---------------*
	xref	table_autori
	lea	table_autori,a3
	moveq	#2,d1		;ya pas 0 et 1
	move	#64-2-1,d7
.LOOPAUTORI
	tst.b	(a3)+
	beq.S	.NXT
	lea	DETOURNE,a0
	bsr	WRITE_STR
		
	bsr	WRITE_DEC	
	
	lea	CRLF,a0
	bsr	WRITE_STR
	
	
.NXT	addq	#1,d1			
	dbra	d7,.LOOPAUTORI
	

	*--------------*
	* ecrit le vecteur d'arret
	*--------------*


	lea	VECTEUR,a0
	bsr	WRITE_STR

	xref	EXEP_ARRET
	move	EXEP_ARRET,d1
	bsr	WRITE_HEX		
	
	lea	CRLF,a0
	bsr	WRITE_STR
	

	*--------------*
	* voir en ctrl A ?
	*--------------*

	lea	VIEW_CTRL_A,a0
	bsr	WRITE_STR
	
	xref	voir_ctrl_a
	move	voir_ctrl_a,d1
	bsr	WRITE_DEC

	lea	CRLF,a0
	bsr	WRITE_STR
		

	*--------------*
	* IPL interne
	*--------------*

	lea	IPL_INTERNE,a0
	bsr	WRITE_STR
	
	xref	IPL_INT
	move	IPL_INT,d1
	bsr	WRITE_DEC

	lea	CRLF,a0
	bsr	WRITE_STR
		

	
	*--------------*
	* ENDSEC
	*--------------*
	
	lea	ENDSEC,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR
	lea	CRLF,a0
	bsr	WRITE_STR

	movem.l	(sp)+,d0/d1/d7/a0/a3
	
	rts
;------------------------------------------------------------------------------
	

;------------------------------------------------------------------------------
; ‚crit autant de section window que de fenetres
;------------------------------------------------------------------------------
WRITE_ALL_WINDOWS
;*IN
;	d0:	handle

	movem.l	d0/d1/d6/d7/a0/a1,-(sp)
	move.l	d0,d7
	
	
	lea	WINDOW_LIST,a1
	move	#31,d6
.LOOP	
	move.l	(a1)+,d0	
	beq	.NEXT
	move.l	d0,a0
	move.l	d7,d0
	move	#31,d1
	sub	d6,d1
		
	bsr	WRITE_WINDOW_SECTION
	
.NEXT
	dbra	d6,.LOOP	

	movem.l	(sp)+,d0/d1/d6/d7/a0/a1
	rts
		
	
;------------------------------------------------------------------------------	
; ‚crit une section window complete
;------------------------------------------------------------------------------	
WRITE_WINDOW_SECTION
;*IN
;	a0:	ptr fenetre
;	d0:	handle
;	d1:	no de fenetre


	movem.l	d0-a6,-(sp)

	move.l	a0,a1

	*--------------*
	* SECTION WINDOW
	*--------------*
	
	lea	SECTION,a0
	bsr	WRITE_STR

	lea	WINDOW,a0
	bsr	WRITE_STR
	
	lea	CRLF,a0
	bsr	WRITE_STR


	*--------------*
	* NB
	*--------------*
	lea	NB,a0
	bsr	WRITE_STR

	bsr	WRITE_DEC	
	
	lea	CRLF,a0
	bsr	WRITE_STR


	*--------------*
	* ACTIVE ?
	*--------------*
	cmp.l	ACTIVE_WINDOW,a1
	bne.s	.NO
	lea	ACTIVE,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR
	
.NO	
	*--------------*
	* TYPE
	*--------------*
	lea	TYPE,a0
	bsr	WRITE_STR
	
	moveq	#0,d1
	move	type(a1),d1
	bsr	WRITE_DEC	

	lea	CRLF,a0
	bsr	WRITE_STR

	*--------------*
	* SIZE
	*--------------*
	lea	SIZE,a0
	bsr	WRITE_STR
	
	moveq	#0,d1
	move	W_X1(a1),d1
	bsr	WRITE_DEC	

	moveq	#0,d1
	move	W_Y1(a1),d1
	bsr	WRITE_DEC	

	moveq	#0,d1
	move	Largeur(a1),d1
	bsr	WRITE_DEC	

	moveq	#0,d1
	move	Hauteur(a1),d1
	bsr	WRITE_DEC	

	lea	CRLF,a0
	bsr	WRITE_STR

	*--------------*
	* SCROLL
	*--------------*
	lea	SCROLL,a0
	bsr	WRITE_STR
	
	moveq	#0,d1
	move	start_col(a1),d1
	bsr	WRITE_DEC	


	moveq	#0,d1
	move	start_ligne(a1),d1
	bsr	WRITE_DEC	

	lea	CRLF,a0
	bsr	WRITE_STR


	*--------------*
	* MEM TYPE
	*--------------*
	lea	MEM,a0
	bsr	WRITE_STR
	
	moveq	#0,d1
	move	mem_type(a1),d1
	bsr	WRITE_DEC	

	lea	CRLF,a0
	bsr	WRITE_STR

	*--------------*
	* ADRESSE DEBUT 
	*--------------*
	lea	ADR,a0
	bsr	WRITE_STR
	
	move.l	adr_debut(a1),d1
	bsr	WRITE_HEX

	lea	CRLF,a0
	bsr	WRITE_STR

	
	*-----------------*
	*LOCK EXPRESSION
	*-----------------*
	lea	LOCK,a0
	bsr	WRITE_STR
	lea	GUIL0,a0
	bsr	WRITE_STR

	move.l	ptr_expr(a1),d1
	beq.s	.nul
	move.l	d1,a0	
	bsr	WRITE_STR

.nul	lea	GUIL1,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR

	*--------------*
	* TAB_VALUE
	*--------------*
	lea	TAB_ID,a0
	bsr	WRITE_STR
	
	moveq	#0,d1
	move	Tab_Value(a1),d1
	bsr	WRITE_DEC

	lea	CRLF,a0
	bsr	WRITE_STR
	

	*--------------*
	* ENDSEC
	*--------------*
	
	lea	ENDSEC,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR
	lea	CRLF,a0
	bsr	WRITE_STR
	
	movem.l	(sp)+,d0-a6
		
	rts
;------------------------------------------------------------------------------


;------------------------------------------------------------------------------
; sauve toutes les couleurs ds leur section
; en clair
;------------------------------------------------------------------------------
WRITE_COLOR_SECTION
;*IN
;	d0:	handle

	movem.l	d0/d1/d7/a0,-(sp)

	*--------------*
	* SECTION COLOR
	*--------------*

	lea	SECTION,a0
	bsr	WRITE_STR

	lea	COLOR,a0
	bsr	WRITE_STR
	
	lea	CRLF,a0
	bsr	WRITE_STR

	*--------------*
	*--------------*

	lea	mcol_40,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_40,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR


	lea	mcol_dsp,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_DSP,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR


	lea	mcol_lab,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_LAB,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR

	lea	mcol_add,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_ADR,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR


	lea	mcol_fct,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_FCT,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR

	lea	mcol_bkp,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_BKPT,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR


	lea	mcol_chg,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_CHG,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR


	lea	mcol_reg,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_REG,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR


	lea	mcol_menu,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_MENU,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR

	lea	mcol_pc,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_PC,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR

	lea	mcol_errl,a0
	bsr	WRITE_STR
	moveq	#0,d1
	move.b	COL_ERR_L,d1
	bsr	WRITE_COLOR
	lea	CRLF,a0
	bsr	WRITE_STR
	

	*--------------*
	* ENDSEC
	*--------------*
	
	lea	ENDSEC,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR
	lea	CRLF,a0
	bsr	WRITE_STR
	
	movem.l	(sp)+,d0/d1/d7/a0
	rts

WRITE_COLOR
;*IN
;	d1:	no couleur
	ifne	(LANGUAGE=FRANCAIS)
	move.l	(ptr_color_fr,d1.w*4),a0
	endc	
	ifne	(LANGUAGE=ANGLAIS)
	move.l	(ptr_color_eng,d1.w*4),a0
	endc	
	
	bsr	WRITE_STR
	
	rts
	

WRITE_SCREEN_SECTION
;*IN
;	d0:	handle

	movem.l	d0/d1/d7/a0,-(sp)
	move.l	d0,d7

	*--------------*
	* SECTION SCREEN
	*--------------*
	
	lea	SECTION,a0
	bsr	WRITE_STR

	lea	SCREEN,a0
	bsr	WRITE_STR
	
	lea	CRLF,a0
	bsr	WRITE_STR
	
	*---------------*
	*RESOL	\640	\480
	*---------------*
	
	lea	RESOL,a0
	bsr	WRITE_STR
	
	move	RESO_X,d1
	lsl	#3,d1		;reso=nbcar*8
	bsr	WRITE_DEC	;$largeur

	move	RESO_Y,d1
	mulu	#size_font,d1	;reso=nb_char * hauteur de fonte
	bsr	WRITE_DEC	;$hauteur

	lea	CRLF,a0
	bsr	WRITE_STR

	
	*--------------*
	* ENDSEC
	*--------------*
	
	lea	ENDSEC,a0
	bsr	WRITE_STR

	lea	CRLF,a0
	bsr	WRITE_STR
	lea	CRLF,a0
	bsr	WRITE_STR

	movem.l	(sp)+,d0/d1/d7/a0
	
	rts
		
	
		


		

;------------------------------------------------------------------------------
; ‚crit la chaine point‚e par a0
; dans le fichier dont le handle est donn‚
;------------------------------------------------------------------------------
;*IN
;	a0:	ptr chaine
;	d0:	handle

WRITE_STR
	movem.l	d0/d1/a1,-(sp)
	move.l	a0,a1
.LL	tst.b	(a1)+
	bne.s	.LL
	move.l	a1,d1
	sub.l	a0,d1
	beq.S	.FIN	
	subq	#1,d1
	
	pea	(a0)
	move.l	d1,-(sp)
	move	d0,-(sp)
	GEM	Fwrite
.FIN	
	movem.l	(sp)+,d0/d1/a1
	rts

;------------------------------------------------------------------------------
; convertit d0 en hexa
; et l'ecrit sur disque
;------------------------------------------------------------------------------
;*IN
;	d0:	handle
;	d1:	nombre

WRITE_HEX
	movem.l	d0/d1/d2/d7/a0/a6,-(sp)
	local_raz
	local.w	buf,8
	local_reserve

	move	d0,d7	
	move.l	d1,d0
	lea	buf(a6),a0
	move.b	#'$',(a0)+
	addq	#8,a0
	move.b	#$20,(a0)	
	move	#8-1,d2
.LOOP	move.b	d0,d1
	and	#$f,d1
	lsr.l	#4,d0
	add.b	#'0',d1
	cmp.b	#'9',d1
	ble.s	.OK
	add.b	#'A'-'0'-10,d1
.OK	move.b	d1,-(a0)
	dbra	d2,.LOOP
	
		
	pea	buf(a6)
	move.l	#10,-(sp)
	move	d7,-(sp)
	GEM	Fwrite
	local_free
	movem.l	(sp)+,d0/d1/d2/d7/a0/a6
	rts

;------------------------------------------------------------------------------
; convertit d0 en decimal
; et l'ecrit sur disque
;------------------------------------------------------------------------------
;*IN
;	d0:	handle
;	d1:	nombre
WRITE_DEC
	movem.l	d0-d4/d7/a0/a1/a6,-(sp)
	local_raz
	local.w	buf,4
	local_reserve

	move	d0,d7
	move.l	d1,d0
		
	lea	buf(a6),a0
	move.b	#'\',(a0)+
	move	#5-1,d2
	ext.l	d0
	moveq	#0,d3
	move.l	#10000,d4
.LOOP	
	divu	d4,d0
	bne.s	.OK		;on a zero ?
	tst	d2
	beq.s	.OK		;dernier char obligatoire
.IGNORE
	tst	d3
	beq.s	.OK0		;premier char … 0 => ignor‚
.OK	add.b	#'0',d0
	move.b	d0,(a0)+
	st	d3
.OK0	swap	d0
	ext.l	d0
	divu	#10,d4
	dbra	d2,.LOOP
	move.b	#$20,(a0)+
	
	lea	buf(a6),a1
	sub.l	a1,a0
		
	pea	buf(a6)
	move.l	a0,-(sp)
	move	d7,-(sp)
	GEM	Fwrite
	local_free
	movem.l	(sp)+,d0-d4/d7/a0/a1/a6
	rts
		
				
		
	DATA

	*---------------*
	* les commandes du fichier prefs
	*---------------*
	
CONFIG		dc.b	"**CENTINEL CFG FILE**",0
SECTION		dc.b	"SECTION ",0
ENDSEC		dc.b	"ENDSEC",0
SCREEN		dc.b	'SCREEN',0
S040		dc.b	'68040',0
RESOL		dc.b	"	RESOL	",0
WINDOW		dc.b	'WINDOW',0
COLOR		dc.b	'COLOR',0
NB		dc.b	'	NB	',0
TYPE		dc.b	'	TYPE	',0
SIZE		dc.b	'	SIZE	',0
SCROLL		dc.b	'	SCROLL	',0
MEM		dc.b	'	MEM	',0
ADR		dc.b	'	ADDRESS	',0
LOCK		dc.b	'	LOCK	',0
ACTIVE		dc.b	'	ACTIVE',0
DETOURNE	dc.b	'	DETOURNE	',0
VECTEUR		dc.b	'	VECTEUR	',0
VIEW_CTRL_A	dc.b	'	VOIR_CTRL_A	',0
IPL_INTERNE	dc.b	'	IPL	',0
CRLF		dc.b	$d,$a,0	
GUIL0		dc.b	'"',0
GUIL1		dc.b	'"',0
TAB		dc.b	'	',0
TAB_ID		dc.b	'	TAB	',0

mcol_40		dc.b	'	680x0	',0
mcol_dsp	dc.b	'	56x01	',0
mcol_q		dc.b	'	68360	',0
mcol_lab	dc.b	'	LABEL	',0
mcol_add	dc.b	'	ADDRESSE	',0
mcol_fct	dc.b	'	SYSTEME	',0
mcol_bkp	dc.b	'	BREAKPOINT	',0
mcol_chg	dc.b	'	CHANGE	',0
mcol_reg	dc.b	'	REGISTRE	',0
mcol_menu	dc.b	'	MENU	',0
mcol_pc		dc.b	'	PC	',0
mcol_errl	dc.b	'	LECTURE	',0
		even

;------------------------------------------------------------------------------
; pour lire les noms de couleur en clair
; et aussi pour les ecrire
; une table en francais et une en anglais
;------------------------------------------------------------------------------
ptr_color_fr		dc.l	.col_fond,.col_noir,.col_vert,.col_jaune,.col_bleu,.col_magenta,.col_cyan,.col_gris,.col_grisF,.col_rouge
			dc.l	.col_vertF,.col_jauneF,.col_bleuF,.col_magentaF,.col_cyanF,.col_blanc
.col_fond		dc.b	'fond',0
.col_noir		dc.b	'noir',0
.col_vert		dc.b	'vert',0
.col_jaune		dc.b	'jaune',0
.col_bleu		dc.b	'bleu',0
.col_magenta		dc.b	'magenta',0
.col_cyan		dc.b	'cyan',0
.col_gris		dc.b	'gris',0
.col_grisF		dc.b	'grisF',0
.col_rouge		dc.b	'rouge',0
.col_vertF		dc.b	'vertF',0
.col_jauneF		dc.b	'jauneF',0
.col_bleuF		dc.b	'bleuF',0
.col_magentaF		dc.b	'magentaF',0
.col_cyanF		dc.b	'cyanF',0
.col_blanc		dc.b	'blanc',0

ptr_color_eng		dc.l	.col_fond,.col_noir,.col_vert,.col_jaune,.col_bleu,.col_magenta,.col_cyan,.col_gris,.col_grisF,.col_rouge
			dc.l	.col_vertF,.col_jauneF,.col_bleuF,.col_magentaF,.col_cyanF,.col_blanc
.col_fond		dc.b	'back',0
.col_noir		dc.b	'black',0
.col_vert		dc.b	'green',0
.col_jaune		dc.b	'yellow',0
.col_bleu		dc.b	'blue',0
.col_magenta		dc.b	'magenta',0
.col_cyan		dc.b	'cyan',0
.col_gris		dc.b	'grey',0
.col_grisF		dc.b	'Dgrey',0
.col_rouge		dc.b	'red',0
.col_vertF		dc.b	'DgreenF',0
.col_jauneF		dc.b	'Dyellow',0
.col_bleuF		dc.b	'Dblue',0
.col_magentaF		dc.b	'Dmagenta',0
.col_cyanF		dc.b	'Dcyan',0
.col_blanc		dc.b	'white',0
;------------------------------------------------------------------------------



DEFAULT_FILE	incbin	both\DEFAULT.INF
END_DEFAULT_FILE
		even

		ifne	(LANGUAGE=FRANCAIS)
LD_PREFS	dc.b	'Choisissez un fichier .INF',0
MES_DEFAULT_CFG	dc.b	"Ce n'est pas un fichier de configuration de CENTinel, je charge la configuration par defaut",0
		endc
		ifne	(LANGUAGE=ANGLAIS)
LD_PREFS	dc.b	'Select a .INF file',0
MES_DEFAULT_CFG		dc.b	'This is not a Centinel configuration file, I am Loading the default file',0
		endc
MASK		dc.b	'*.*',0

	*---------------*


INF_NAME	dc.b	'CENTINEL.INF',0
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	SECTION	BSS
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
	
CENTINEL_PATH::	ds.b	256
INIT_PATH::	ds.b	256
CFG_FILE	ds.b	256

