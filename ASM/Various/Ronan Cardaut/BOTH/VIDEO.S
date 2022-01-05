	TEXT

	output	d:\centinel\both\video.o
	include	d:\centinel\both\define.s
	include	d:\centinel\both\localmac.s
	include	d:\centinel\both\GEM.EQU
	include	d:\centinel\both\XBIOS.EQU
	include	d:\centinel\both\DOLMEN.RS
	include	d:\centinel\both\VIDEO.RS

	incdir	d:\centinel\both\

S3VIDEO	equ	0

*------------------------------------------------------------------------------
* INITIALISATIONS VIDEO
* 1.	init du menu (Dolmen uniquement pour l'instant)
* 2.	Sauvegarde de la video
* 3.	Init table Y
*------------------------------------------------------------------------------
INIT_VIDEO::

	*-------------------*
	* Cherche le systeme video
	*-------------------*
	bsr	TEST_VIDEO_SYSTEME
	move.l	d0,VIDEO_SYSTEME

	cmp.l	#"_S3V",d0
	beq	.S3				


	*-------------------*
	* Sauve la video du bureau
	*-------------------*
	lea	OLD_VIDEO,a0
	bsr	SAVE_VIDEO

	*-------------------*
	* Sauve le mode en cours (idem)
	*-------------------*
	lea	VIDEO_COU,a0
	bsr	SAVE_VIDEO


	move.l	VIDEO_SYSTEME,d0
	cmp.l	#"_TOS",d0
	beq.s	.TOS		

	cmp.l	#"_DOL",d0
	bne.s	.TOS		

	bsr	INIT_VIDEO_MENU
	bsr 	DOLMEN_CH_REZ

	lea	VIDEO_COU,a0
	bsr	SET_VIDEO		;remet la video du bureau
	
	xref	etat_trace
	clr	etat_trace
	
	bra.s	.SUITE

.TOS	bsr	TOS_VIDEO
	bra.s	.SUITE
	
.S3
	bsr	S3_VIDEO
			

	
.SUITE	



	*-------------------*
	* inits des tables ecran
	*-------------------*

	jsr	INIT_TABY

	bsr	TRONQUE_FENETRES
	
	
	xref	CENTINEL_INFO
	move.l	LOG,CENTINEL_INFO+8	
	rts
		




*------------------------------------------------------------------------------
* changement de resol qui gere tous les problemes !!!!!
* Et qui utilise DOLMEN !
*------------------------------------------------------------------------------
DOLMEN_CH_REZ::
	local_raz
	local.w	_rez0,V_length/2
	local_reserve
	
	*-------------------*
	* efface les coches de tout les menus
	*-------------------*
	move.l	menu_video+12,a0
	move	#8-1,d7
.CLR	move.b	#' ',(a0)
	add	#13,a0
	dbra	d7,.CLR

	*-------------------*
	* recherche la r‚sol la + proche
	* ‚gale ou imm‚diatement inf‚rieure
	* … celle demand‚e
	*-------------------*
	
	lea	TAB_VIDEO_MODE,a3
	moveq	#8-1,d7
	moveq	#0,d3
	moveq	#0,d0		;handle
	move	RESO_X,d1
	move	RESO_Y,d2
.SCAN	
	tst.l	(a3)
	beq.s	.NEXT
	cmp	(a3),d1
	blt	.NEXT
	cmp	2(a3),d2
	blt	.NEXT
	move	(a3),d4
	mulu	2(a3),d4
	cmp.l	d3,d4
	ble.s	.NEXT
	move.l	a3,d0		;nvx mode
	move.l	d4,d3		;nvlle surface
.NEXT	add.w	#280*4,a3
	dbra	d7,.SCAN
	;tst	d0		;"en th‚orie" ca se peut pas !!
	;beq	.FIN		;PAS DE RESOL DISPO !!! => GAUFFRE ( au
	
	*-------------------*
	* passe le mode
	*-------------------*
	move.l	d0,a3
	lea	4(a3),a0
	bsr	SET_VIDEO
	
	move.l	a3,d0
	sub.l	#TAB_VIDEO_MODE,d0
	divu	#280*4,d0
	mulu	#13,d0
	
	move.l	menu_video+12,a0
	add.l	d0,a0
	move.b	#'¯',(a0)
	
	*-------------------*
	* recupere les parametres de l'ecran
	*-------------------*
	
	move	(a3)+,d0	;largeur en pixels
	asr	d0
	move	d0,LSCR
	lsr	#2,d0
	move	d0,RESO_X

	moveq	#0,d0
	move	(a3)+,d0	;Hauteur en pixel
	divu	#size_font,d0
	move	d0,RESO_Y

	
	bsr	SET_PALETTE


	xref	CLS_SCREEN
	bsr	CLS_SCREEN

	*-------------------*
	* installe le LOG
	*-------------------*
	move.b	LOG+1,$ffff8201.w
	move.b	LOG+2,$ffff8203.w
	move.b	LOG+3,$ffff820d.w

	*-------------------*
	* Sauve le mode DE CENTINEL
	*-------------------*
	lea	CENTINEL_VIDEO,a0
	bsr	SAVE_VIDEO

	local_free

	rts
	
;---------------------------------------------------------
S3_VIDEO	
	move.l	#$d2000000,LOG				
	move	#1024*2,LSCR

	move	#1024/8,RESO_X
	move	#768/16,RESO_Y

	*-------------------*
	* pas de menu video !
	* et c'est bien fait !
	*-------------------*
	xref	menu_video
	clr	menu_video+2

	xref	etat_trace
	clr	etat_trace
	
	xref	CONVERT_PAL
	bsr	CONVERT_PAL

	rts
;---------------------------------------------------------
	


;---------------------------------------------------------
TOS_VIDEO::

	move.l	LOG,d0
	beq.s	.OK0
	move.l	d0,-(sp)		;libere l'‚cran
	GEM	Mfree			;s'il y en a deja un...
.OK0
	
	
	move	#-1,-(sp)
	move	#88,-(sp)
	trap	#14
	addq	#4,sp
	move	d0,-(sp)		;sauve l'ancien mode

	and	#$fff0,d0
	or.w	#%1010,d0		;640*480*16c VGA
	
	move	#%00011010,d0		
	
	move	d0,-(sp)	

	move	d0,-(sp)
	move	#3,-(sp)
	move.l	#0,-(sp)
	move.l	#0,-(sp)
	move	#5,-(sp)
	trap	#14			;nouveau mode
	add	#14,sp

	
	move	#$5b,-(sp)
	trap	#14			;VGET SIZE
	addq	#4,sp

	move.l	d0,SIZE_SCREEN

	
	; ST-RAM
	
	RON_XALLOC2 #0,d0
	
	move.l	d0,LOG
	


	move.b	LOG+1,$ffff8201.w
	move.b	LOG+2,$ffff8203.w
	move.b	LOG+3,$ffff820d.w	;passe l'‚cran


	bsr	SET_PALETTE

	*-------------------*
	* Sauve le mode DE CENTINEL
	*-------------------*
	lea	CENTINEL_VIDEO,a0
	bsr	SAVE_VIDEO


	*-------------------*
	* recupere les parametres de 
	*l'ecran de facon pas 'propre'
	*-------------------*

	dc.w	$a000
	move	-12(a0),d0	;largeur screen en octet
	asr	d0
	move	d0,LSCR
	lsr	#2,d0
	move	d0,RESO_X

	moveq	#0,d0
	move	-4(a0),d0
	divu	#size_font,d0
	move	d0,RESO_Y

	move	#3,-(sp)	;l'ancien mode
	move.l	#0,-(sp)
	move.l	#0,-(sp)
	move	#5,-(sp)
	trap	#14
	add	#14,sp

	
	*-------------------*
	* pas de menu video !
	* et c'est bien fait !
	*-------------------*
	xref	menu_video
	clr	menu_video+2

	xref	etat_trace
	clr	etat_trace

	rts
;---------------------------------------------------------
	

*------------------------------------------------------------------------------
* DETECTION du sous-systeme VIDEO
*------------------------------------------------------------------------------
*OUT:
*	d0=	"_VID" dolmen Videl
*		"_S3V" dolmen S3Virge
*		"_TOS" TOS..
*------------------------------------------------------------------------------
TEST_VIDEO_SYSTEME
	move.l	d1,-(sp)
	*-------------------*
	* recherche le cooky _VID 
	* de la video DOLMEN
	* rechercher aussi _S3V pour la S3
	*-------------------*
	move.l	#'_TOS',d1
	
	move.l	$5a0.w,a0
	tst.l	a0
	beq	.FIN		;pas de cooky jar
.youpz
	move.l	(a0),d0
	beq	.FIN		;vid‚ le cooky jar !

	ifne	S3VIDEO
	cmp.l	#'_S3V',d0
	bne.s	.OK01
	move.l	d0,d1
	bra.S	.FIN
	endc

.OK01	cmp.l	#'_VID',d0
	bne.s	.OK0
	move.l	d0,d1	

.OK0	lea	8(a0),a0
	bra.s	.youpz
.FIN	move.l	d1,d0
	move.l	(sp)+,d1
	rts
*------------------------------------------------------------------------------
		
		
*------------------------------------------------------------------------------
* INIT VIDEO MENU
* r‚cupere les modes videos dispos et les ajoute au menu video
* on revient ds la r‚sol de d‚part … la fin
*------------------------------------------------------------------------------
INIT_VIDEO_MENU
	local_raz
	local.w	_rez,V_length/2
	local.w	_rez1,V_length/2
	local_reserve


	*------------------*
	* sauve pour r‚initialiser
	* la VDI en quittant Centinel
	*------------------*
	pea	OLD_MODE
	XBIOS	Vread
	*------------------*

	moveq	#0,d6				;surface de l'‚cran

	xref	menu_video
	clr	menu_video+2
	lea	menu_video+12,a1		;ptr 1ere entr‚e
	move.l	(a1),a2				;ptr texte
	lea	TAB_VIDEO_MODE,a3
	lea	_rez(a6),a5
	lea	_rez1(a6),a4
	

	moveq	#-1,d2
	move.l	d2,V_hdl(a4)
	move.l	d2,V_physx(a4)
	move.l	d2,V_logx(a4)
		
	move	#4,V_plan(a4)			;tout est indiff‚rent sauf les 4 plans

	movem.l	d1-d2/a1-a2,-(sp)
	move.l	a5,-(sp)
	move.l	a4,-(sp)
	XBIOS	Vfirst
	movem.l	(sp)+,d1-d2/a1-a2
	
	tst.l	d0
	bmi	.OK0

	moveq	#8-1,d7				;max 8 modes	
	bra.s	.TEST
.LOOP	
	move	V_hdl(a5),V_hdl(a4)		;transfert du handle
	movem.l	d1-d2/a1-a2,-(sp)
	move.l	a5,-(sp)
	move.l	a4,-(sp)
	XBIOS	Vnext
	movem.l	(sp)+,d1-d2/a1-a2
	tst.l	d0
	bmi.s	.OK0


.TEST	
	cmp	#640,4(a5)
	blt.s	.LOOP				;trop petit
	cmp	#480,6(a5)
	blt.s	.LOOP				;trop petit

	*---------------------*
	* Le MODE convient
	* on le passe
	*---------------------*
	clr.l	V_logx(a5)
	movem.l	d1-d2/a1-a2,-(sp)
	pea	(a5)
	pea	(a5)
	move	#0,-(sp)			;ne pas r‚initialiser la VDI
	XBIOS	Vwrite
	movem.l	(sp)+,d1-d2/a1-a2

	*---------------------*

	addq	#1,menu_video+2			;+1 mode
	move.l	V_physx(a5),(a3)			;L+H
	move	(a3),d0
	mulu	2(a3),d0
	cmp.l	d6,d0
	ble.s	.INF
	move.l	d0,d6
.INF	
	
	lea	4(a3),a0
	bsr	SAVE_VIDEO
	add.w	#280*4,a3

	move.l	a2,(a1)+			;ptr nom
	move.l	#video_rout,(a1)+		;routine chg mode

	move.b	#' ',(a2)+
	move	4(a5),d0
	bsr	.WRITE_NUM			;reso X
	move	#' x',(a2)+			
	move.b	#' ',(a2)+
	move	6(a5),d0
	bsr.s	.WRITE_NUM			;reso Y
	clr.b	(a2)+

.NEXT
	dbra	d7,.LOOP
	bra.s	.FIN
.OK0	clr.l	(a3)
	add.w	#280*4,a3
	dbra	d7,.OK0

.FIN
	movem.l	d1-d2/a1-a2,-(sp)
	pea	OLD_MODE
	pea	OLD_MODE
	move	#0,-(sp)			;ne pas r‚initialiser la VDI
	XBIOS	Vwrite
	movem.l	(sp)+,d1-d2/a1-a2


	*---------------------*
	* Malloc du plus grand ‚cran dispo
	*---------------------*
	
	lsr.l	d6				;taille ‚cran=surface/2
	move.l	d6,SIZE_SCREEN	

	RON_XALLOC2 #0,d6
	move.l	d0,LOG


	local_free	
	rts
	
.WRITE_NUM
	ext.l	d0
	divu	#1000,d0
	tst	d0
	bne.s	.OK1
	move.b	#' '-'0',d0
.OK1	add.b	#'0',d0
	move.b	d0,(a2)+			;milliers
	clr	d0
	swap	d0
	
	divu	#100,d0
	add.b	#'0',d0
	move.b	d0,(a2)+			;centaines
	clr	d0
	swap	d0

	divu	#10,d0
	add.b	#'0',d0
	move.b	d0,(a2)+			;dizaines
	swap	d0
	add.b	#'0',d0
	move.b	d0,(a2)+			;unit‚
	rts
			



*------------------------------------------------------------------------------
* installation de la palette du debugeur
*------------------------------------------------------------------------------
SET_PALETTE	
	movem.l	d0-a6,-(sp)

	lea	PALETTE,a0
	lea	$ffff9800.w,a1
	move	#16-1,d0
.C	move.l	(a0)+,(a1)+
	dbra	d0,.C

	movem.l	(sp)+,d0-a6

	rts
*------------------------------------------------------------------------------


*------------------------------------------------------------------------------
* sauve les parametres de VIDEL
*------------------------------------------------------------------------------
SAVE_VIDEO::
*IN	
*	a0:	ptr sauvegarde
	
	cmp.l	#"_S3V",VIDEO_SYSTEME
	bne.S	.OK0
	rts
.OK0


	movem.l	d7/a0/a1,-(sp)
;****** REGISTRES VIDEO FALCON

	move	$ffff8006.w,(a0)+	;mon type
	move	#$8282,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move	#$82a2,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.w	(a1)+,(a0)+

	addq.w	#1,a0		
	move.b	$ffff820a.w,(a0)+

	move	$ffff820e.w,(a0)+
	move	$ffff8210.w,(a0)+	
	move	$ffff82c0.w,(a0)+	
	
	addq.w	#1,a0		
	move.b	$ffff8265.w,(a0)+
	
	move	$ffff8266.w,(a0)+	
	move	$ffff82c2.w,(a0)+	
;****** ADRESSES ECRAN
	addq	#1,a0
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
;****** PALETTE ******************
	lea	$ffff9800.w,a1
	move.w	#256-1,d7
.C	move.l	(a1)+,(a0)+
	dbra	d7,.C
	movem.l	(sp)+,d7/a0/a1
	rts

*------------------------------------------------------------------------------
* SET_VIDEO::
*  restaure les parametres de VIDEL
*------------------------------------------------------------------------------
*IN	
*	a0:	ptr video … passer
*------------------------------------------------------------------------------
SET_VIDEO::

	cmp.l	#"_S3V",VIDEO_SYSTEME
	beq.s	S3_SET_VIDEO

	movem.l	d7/a0/a1,-(sp)


	* Vsync avant de commencer (marche en I7!)
	move	_VFC.w,d7
.sync
	cmp	_VFC.w,d7
	bhs	.sync



;****** REGISTRES VIDEO FALCON
	move	(a0)+,$ffff8006.w	;mon type
	movea	#$8282,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	movea	#$82a2,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	(a0)+,(a1)+

	addq	#1,a0
	move.b	(a0)+,$ffff820a.w

	move	(a0)+,$ffff820e.w
	move	(a0)+,$ffff8210.w	
	move	(a0)+,$ffff82c0.w	

	addq	#1,a0
	move.b	(a0)+,$ffff8265.w
	
	move	(a0)+,$ffff8266.w	
	move	(a0)+,$ffff82c2.w	
;****** ADRESSES ECRAN
	addq	#1,a0
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820d.w
;****** PALETTE ******************
	lea	$ffff9800+256*4.w,a1
	add	#256*4,a0
	move.w	#256-1,d7
.C	move.l	-(a0),-(a1)
	dbra	d7,.C
	movem.l	(sp)+,d7/a0/a1
	rts
*------------------------------------------------------------------------------
	
*------------------------------------------------------------------------------
* installe l'‚cran sur 
*------------------------------------------------------------------------------
S3_SET_VIDEO
	rts
	cmp.l	#CENTINEL_VIDEO,a0

*------------------------------------------------------------------------------
	

*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
INIT_TABY::
	lea	TAB_Y,a0
	move	#199,d7
	moveq	#0,d1
	moveq	#0,d0
	move	LSCR,d0
	ifeq	(size_font=8)
	lsl.l	#4,d0
	else
	lsl.l	#3,d0
	endc
	
.LOOP	move.l	d1,(a0)+
	add.l	d0,d1
	dbra	d7,.LOOP
	rts
*------------------------------------------------------------------------------
	


*------------------------------------------------------------------------------
* Changement de resolution par le menu
*------------------------------------------------------------------------------
*IN	d0: no de la resol
video_rout
	movem.l	d0-a6,-(sp)
	
	mulu	#280*4,d0
	move.l	(TAB_VIDEO_MODE.l,d0.l),RESO_X


	ifne	0
	*-------------------------*
	* MFREE de l'‚cran
	*-------------------------*
	move.l	LOG,-(sp)
	GEM	Mfree
	endc

	bsr	DOLMEN_CH_REZ
	
	jsr	INIT_TABY

	bsr	TRONQUE_FENETRES
	
	
	


	xref	set_all_flags		
	jsr	set_all_flags		
					
	
	movem.l	(sp)+,d0-a6
	rts
	


*------------------------------------------------------------------------------
* Parcours la liste des fenetres et ‚limine les fenetres qui
* d‚bordent de l'‚cran...
* remet … jour ACTIVE_WINDOW
*------------------------------------------------------------------------------
TRONQUE_FENETRES::	
	xref	ACTIVE_WINDOW,BUFFER_WINDOW
	*-------------------------*
	* Verification des fenetres
	* IN/OUT
	*-------------------------*
	xref	WINDOW_LIST
	lea	WINDOW_LIST,a0
	move	RESO_X,d0
	move	RESO_Y,d1
	subq	#1,d1			;1 ligne r‚serv‚e en bas de l'‚cran
	move.l	ACTIVE_WINDOW,d4
	moveq	#0,d5			;flag de recherche de active window
	move	#32-1,d7
.LOOP
	move.l	(a0)+,d2
	beq.S	.NEXT
	move.l	d2,a1
	move	W_X1(a1),d2
	addq	#2,d2
	cmp	d0,d2
	bge.s	.CLR
	subq	#2,d2
	move	W_Y1(a1),d3
	addq	#2,d3
	cmp	d1,d3
	bge.s	.CLR
	subq	#2,d3
	add	Largeur(a1),d2
	subq	#1,d2
	cmp	d0,d2
	blt.s	.NOSMALLERX		;bgt car ya pas le subq #1 sur la largeur
	move	d0,d2
	sub	W_X1(a1),d2
	move	d2,Largeur(a1)
.NOSMALLERX	
	add	Hauteur(a1),d3
	subq	#1,d3			;!!
	cmp	d1,d3
	blt.s	.NOSMALLERY
	move	d1,d3
	sub	W_Y1(a1),d3
	;subq	#1,d3
	move	d3,Hauteur(a1)
.NOSMALLERY
	bra.S	.NEXT	
	
.CLR	cmp.l	-4(a0),d4
	bne.s	.OK_CLR
	move	d7,d5
.OK_CLR	clr.l	-4(a0)
.NEXT	dbra	d7,.LOOP
	
	tst.l	d5			;doit on rechercher un nvx active_window ?
	beq	.RIEN
	lea	WINDOW_LIST,a0
	move	#32-1,d7
.LOOP1	move.l	(a0)+,d0
	bne.s	.OK
	dbra	d7,.LOOP1

	move	#32-1,d0
	sub	d5,d0
	move	d0,d5
	mulu	#Size_win,d0
	add.l	#BUFFER_WINDOW,d0
	move.l	d0,(WINDOW_LIST,d5.w*4)
	move.l	d0,a0			;force une fenetre ds l'ecran
	move.l	#1,W_X1(a0)
	move.l	#$f000f,Largeur(a0)
					
.OK	move.l	d0,ACTIVE_WINDOW
.RIEN	
	rts
	
*------------------------------------------------------------------------------
	DATA
*------------------------------------------------------------------------------
PALETTE::		incbin	default.PAL
	
TAB_Y::
A	set	0
	rept	200	;200 lignes max...
	dc.l	A
A	set	A+640*8/2
	endr

TAB_X::
A	set	0
	rept	320/2	;pour 320 car max
	dc.w	A,A+1
A	set	A+8
	endr



*------------------------------------------------------------------------------
	BSS
*------------------------------------------------------------------------------




*------------------------------------------------------------------------------
* Les sauvegarde du videl
*------------------------------------------------------------------------------
OLD_VIDEO::		ds.l	280		;a l'arriv‚e
VIDEO_COU::		ds.l	280		;pour tracer
CENTINEL_VIDEO::	ds.l	280		;le mode de Centinel
OLD_MODE::		ds.l	V_length	;pour Vread/Vcreate
*------------------------------------------------------------------------------



*------------------------------------------------------------------------------
* Variables de l'ecran
*------------------------------------------------------------------------------
;DOLMEN_VIDEO::	ds	1
RESO_X::	ds	1
RESO_Y::	ds	1
LSCR::		ds	1
TAB_VIDEO_MODE	ds.l	280*8			;max 8 modes

LOG::		ds.l	1
SIZE_SCREEN::	ds.l	1			;taille du Malloc
*------------------------------------------------------------------------------
VIDEO_SYSTEME::	ds.l	1			;"_TOS" "_VID" ou "_S3V"
*------------------------------------------------------------------------------



