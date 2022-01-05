	TEXT
	output	d:\centinel\both\f_sel.o.o

	include	both\GEM.EQU
	include	d:\centinel\both\define.s
	include	both\LOCALMAC.S

	xref	buf_dta,BASE_PAGE,SAVE_OLD_PROS
	


	xref	WORK_BUF,ASCII_BUF
	xref	dsp_name

FILE_SELECT::
	lea	BIDON,a0
	lea	TYPE,a1
	lea	dsp_name,a2
	
	bsr	FILE_SELECTOR
	rts
BIDON	dc.b	'choisissez un fichier',0

TYPE	dc.b	'*.*',0
;------------------------------------------------------------------------------
; simulation d'un file_select
;------------------------------------------------------------------------------
FILE_SELECTOR::
;IN:	a0:	info line
;	a1:	mask de fichier
;	a2:	ptr destination

	movem.l	d0-a6,-(sp)

	movem.l	a0-a2,-(sp)




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
	xref	PETIT_MESSAGE,MES_SPACE
	move.l	#MES_VEC_CHG,MESSAGE_ADR
	jsr	PETIT_MESSAGE
	jsr	get_key
	move.l	#MES_SPACE,MESSAGE_ADR
	cmp.w	#$15,d0
	beq.s	.norm
	cmp.w	#$18,d0
	beq	.norm
	
	
	
	
	
	movem.l	(sp)+,a0-a2
	
	movem.l	(sp)+,d0-a6		; si non on quitte
	moveq	#-1,d0
	rts
.norm

	;CENT_PROS



	movem.l	(sp)+,a0-a2

	
	move.l	a0,PTR_TITRE
	move.l	a1,PTR_NAME
	move.l	a2,PTR_DEST

	xref	WINDOW_LIST,ACTIVE_WINDOW,ZOOM_WINDOW,QUIT_ZOOM,BUFFER_WINDOW

	move.l	ZOOM_WINDOW,d1
	beq.s	GO_DIRECTORY
	bsr.l	QUIT_ZOOM	
GO_DIRECTORY
	move.l	ACTIVE_WINDOW,SAVE_ACTIVE
	*------------------*
	* recherche une fenetre libre
	*------------------*
	lea	WINDOW_LIST,a0
	move	#32-1,d0
.SCAN	tst.l	(a0)+
	dbeq	d0,.SCAN
	move	CURRENT_ACTIVE,d0
	bmi	FIN
	subq	#4,a0
	
	move.l	a0,d0
	sub.l	#WINDOW_LIST,d0
	asr.l	#2,d0		;no du slot

	mulu	#Size_win,d0
	lea	(BUFFER_WINDOW,d0.l),a1
	move.l	a1,(a0)
	move.l	a1,ACTIVE_WINDOW
	move	#T_INFO,type(a1)
	

	*------------------*
	* on la fulle
	*------------------*
	xref	ZOOM
	bsr.l	ZOOM
	
	*------------------*
	* on lit le repertoire
	*------------------*
NEWDIR::
	bsr	READ_DIR
	

	*------------------*
	* resize la fenetre
	*------------------*

	move.l	ACTIVE_WINDOW,a0

	xref	RESO_Y
	move	RESO_Y,d0
	move	d0,d1
	subq	#1,d1
	move	d1,Hauteur(a0)

	subq	#1+2+1+1,d0		;1 titre +2 vides + 1 path + 1 vide
	move	d0,NB_LIGNE
					;d0= hauteur pour les entr‚es
	
	moveq	#0,d1
	move	WORK_BUF+256,d1		;nb entr‚es

	divu	d0,d1
	addq	#1,d1			;nb colonnes
	move	d1,NB_COL		;pour afficher toutes les entr‚es
	
	move	d1,d2	
	mulu	#1+12+1+8+4,d1		;" 12345678.123 88888888    "
	addq	#2,d1
	cmp	#40,d1
	bge.S	.OK100
	move	#40,d1			;pas de largeur < 40
.OK100	move	d1,Largeur(a0)
		
	cmp	#1,d2
	bne.S	.NOHAUT
	*------------------*
	* s'il n'y a que 1 col
	* ajuste la hauteur
	*------------------*
	move	WORK_BUF+256,d1		;nb entr‚es
	addq	#1+2+1+1+2,d1		;cf ci-dessus
	cmp	RESO_Y,d1
	blt.s	.OK101
	move	RESO_Y,d1
	subq	#1,d1
.OK101	move	d1,Hauteur(a0)
			
.NOHAUT		


	xref	CLS_SCREEN
	bsr	CLS_SCREEN


REDRAW

	bsr	GEN_FSEL
	
	*------------------*
	* redraw
	*------------------*
	;xref	CLS_SCREEN
	;bsr	CLS_SCREEN
	

	xref	TITRE,CORP,BOTTOM
	move.l	ACTIVE_WINDOW,a0				
	bsr	TITRE		
	bsr	CORP
	bsr	BOTTOM

	xref	get_key
.WAIT	
	bsr	get_key

	
	cmp.w	#$010e,d0	;ctrl back_space ?
	beq	BACK_ONE		

	cmp.b	#1,d0
	beq	ABORT		;esc ?
	
	cmp.b	#$50,d0
	beq	FLECHE_BAS

	cmp.b	#$48,d0
	beq	FLECHE_HAUT

	cmp.b	#$4B,d0
	beq	FLECHE_GAUCHE

	cmp.b	#$4D,d0
	beq	FLECHE_DROITE

	cmp.b	#$1c,d0
	beq	SELECT

	*------------------*
	* changement de lecteur
	*------------------*
	swap	d0
	and	#$ff-$20,d0	;force Maj
	cmp.b	#'A',d0
	blt	REDRAW		
	cmp.b	#'Z',d0
	bgt	REDRAW
	sub.b	#'A',d0
	move	d0,d1
	
	move	d0,-(sp)
	GEM	Dsetdrv
	
	btst	d1,d0
	beq	.WAIT
	
	
	
	bra	NEWDIR

BACK_ONE
	lea	ASCII_BUF,a2
	move.l	a2,a1
	move	#'..',(a1)+
	bra	FCOP1
	
	
SELECT	
	*------------------*
	* on … choisi une entr‚e...
	* on cherche son type
	*------------------*
	move	CURRENT_ACTIVE,d0
	lea	WORK_BUF+256+2,a0
	subq	#2,d0
	bmi.s	.FOUND
.LOOP	move.l	2(a0),a0
	dbra	d0,.LOOP
.FOUND	move	(a0),d0		;type ds d0
	beq	FICHIER		
	
	*------------------*
	* on a choisit un repertoire...

	*------------------*
	
	lea	6+2(a0),a0	;+2 pour sauter le sigle "repertoire"
	lea	ASCII_BUF,a1
	move.l	a1,a2
.COP1	move	(a0)+,d0
	beq.S	FCOP1
	cmp.b	#' ',d0
	beq.S	FCOP1
	move.b	d0,(a1)+
	bra.s	.COP1
FCOP1
	clr.b	(a1)+
	*------------------*
	* on rentre ds le 
	* nouveau repertoire
	*------------------*
	move.l	a2,-(sp)
	GEM	Dsetpath
	bra	NEWDIR			

			
FLECHE_GAUCHE
	move	CURRENT_ACTIVE,d0
	subq	#1,d0
	bne.s	.OK
	MOVEQ	#1,D0
.OK	move	D0,CURRENT_ACTIVE
	bra	REDRAW	
			
FLECHE_DROITE
	*------------------*
	* passe au fichier suivant ou
	* au premier si on reboucle
	*------------------*
	move	CURRENT_ACTIVE,d0
	addQ	#1,d0
	cmp	WORK_BUF+256,d0
	ble.s	.OK
	moveq	#1,d0
.OK	move	d0,CURRENT_ACTIVE
	bra	REDRAW	
		

FLECHE_BAS
	*------------------*
	* passe au fichier de la ligne suivante ou
	* au premier si on reboucle
	*------------------*
	move	CURRENT_ACTIVE,d0
	add	NB_COL,d0
	cmp	WORK_BUF+256,d0
	ble.s	.OK
	moveq	#1,d0
.OK	move	d0,CURRENT_ACTIVE
	bra	REDRAW	


FLECHE_HAUT
	*------------------*
	* passe au fichier de la ligne pr‚c‚dente ou
	* au dernier si on reboucle
	*------------------*
	move	CURRENT_ACTIVE,d0
	sub	NB_COL,d0	
	cmp	#1,d0
	bge.s	.OK
	move	WORK_BUF+256,d0
.OK	move	d0,CURRENT_ACTIVE
	bra	REDRAW	

	*------------------*
	* on a choisi un fichier
	*------------------*

FICHIER
	*------------------*
	* place le path
	*------------------*
	lea	WORK_BUF,a2
	move.l	PTR_DEST,a1
.REC0	move.b	(a2)+,(a1)+
	bne.s	.REC0
	move.b	#'\',-1(a1)

	*------------------*
	* on recopie le nom de fichier … la suite
	*------------------*
	lea	6+2(a0),a0	;saute type+ptr
.COP10	move	(a0)+,d0
	beq.S	.FCOP10
	cmp.b	#' ',d0
	beq.S	.FCOP10
	move.b	d0,(a1)+
	bra.s	.COP10
.FCOP10
	clr.b	(a1)+
	
	moveq	#0,d0
			
	*------------------*
	* c'est fini...
	*------------------*
QUIT
	xref	ZOOM_WINDOW		
	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre

	xref	CLOSE_WIN
	bsr.l	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW
FIN	
	;REST_PROS
	movem.l	(sp)+,d0-a6
	moveq	#0,d0
	rts


ABORT
	xref	ZOOM_WINDOW		
	clr.l	ZOOM_WINDOW		;obligatoire pour fermer la fenetre

	xref	CLOSE_WIN
	bsr.l	CLOSE_WIN
	move.l	SAVE_ACTIVE,ACTIVE_WINDOW

	;REST_PROS
	movem.l	(sp)+,d0-a6
	moveq	#-1,d0
	rts
	
	
;------------------------------------------------------------------------------
; lit le repertoire courant 
; et repere les infos dont on a besoin
;------------------------------------------------------------------------------
READ_DIR


	;CENT_PROS
	
	move	#1,CURRENT_ACTIVE	;raz le curseur
	
	*-----------------*
	* je ne change pas la DTA
	* car c'est celle de STEPH en place...
	*-----------------*
	;xref	buf_dta
	;pea	buf_dta
	;GEM	Fsetdta	

	
	
	lea	WORK_BUF,a6
	
	*------------------*
	* on stocke le chemin courant
	* dans les 256 premiers octets
	*------------------*
	
	GEM	Dgetdrv
	move	d0,d1
	add.b	#'A',d0
	move.b	d0,(a6)+
	move.b	#':',(a6)+		;D:
		
	addq	#1,d1		;attention ca commence … 0
	move	d1,-(sp)
	pea	(a6)
	GEM	Dgetpath

			
	*------------------*
	* on stocke les entr‚es du directory
	*
	* nb.W
	*
	* type.W	}
	* next.l	}
	* name[?].B	} n fois
	*------------------*
	lea	WORK_BUF+256,a6
	move.l	a6,a5
	clr	(a6)+			
	
	*------------------*
	* en premier, je ne prend 
	* que les sous repertoires
	*------------------*
	move	#$10,-(sp)	;dir
	move.l	#ALL,-(sp)	
	GEM	Fsfirst
	tst.l	d0
	bmi	.FIN0
	bra.s	.FILE
.LOOP
	GEM	Fsnext	
	tst.l	d0
	bmi	.FIN0

.FILE
	xref	COL_NOR,COL_ADR,COL_REG,ATTRIBUTE
	move	COL_NOR,ATTRIBUTE

	*------------------*
	* dir ou fichier ?
	*------------------*

	move.b	buf_dta+21,d0
	cmp	#$10,d0
	bne.s	.LOOP

	addq	#1,(a5)		;une entr‚e en plus
	
	move.l	a6,a4
	addq	#6,a6

	move	#1,(a4)+	;type=1 ( repertoire )
	
	move	COL_ADR,ATTRIBUTE
	move	ATTRIBUTE,d1
	move.b	#'',d1
	move	d1,(a6)+
	

	*------------------*
	* copie le nom de fichier
	*------------------*
	lea	(12+2+8)*2(a6),a3

	lea	buf_dta+30,a0
	col_cpy	a0,a6

	
	*------------------*
	* fill avec des spc pour que 
	* ca soit joli
	*------------------*
.FILL	move	#' ',(a6)+
	cmp.l	a3,a6
	blt.s	.FILL

	clr	(a6)+

	*------------------*
	* pointeur sur le suivant
	*------------------*
	move.l	a6,(a4)
	bra	.LOOP
.FIN0	


FILEZ
	move	#$00,-(sp)	;dir
	move.l	PTR_NAME,-(sp)	
	GEM	Fsfirst
	tst.l	d0
	bmi	.FIN
	bra.s	.FILE
.LOOP
	GEM	Fsnext	
	tst.l	d0
	bmi	.FIN

.FILE
	xref	COL_NOR,COL_ADR,COL_REG,ATTRIBUTE
	move	COL_NOR,ATTRIBUTE

		
	*------------------*
	* dir ou fichier ?
	*------------------*

	move.b	buf_dta+21,d0
	cmp	#$10,d0
	beq.s	.LOOP

	addq	#1,(a5)		;une entr‚e en plus
	
	move.l	a6,a4
	addq	#6,a6


	clr	(a4)+		;type=0 ( fichier )

	move	ATTRIBUTE,d1
	move.b	#' ',d1	

	move	#' ',(a6)+
	

	*------------------*
	* copie le nom de fichier
	*------------------*
	lea	(12+2)*2(a6),a3

	lea	buf_dta+30,a0
	col_cpy	a0,a6

	
	*------------------*
	* fill avec des spc pour que 
	* ca soit joli
	*------------------*
.FILL	move	#' ',(a6)+
	cmp.l	a3,a6
	blt.s	.FILL


	*------------------*
	* ajoute la taille du fichier
	*------------------*
	move.l	buf_dta+26,d0	;taille

	move	COL_REG,ATTRIBUTE
	xref	AFF_DEC
	bsr.l	AFF_DEC

	clr	(a6)+

	*------------------*
	* pointeur sur le suivant
	*------------------*
	move.l	a6,(a4)
	bra	.LOOP
.FIN	

	;REST_PROS


	rts


	

;------------------------------------------------------------------------------
; genere le File selector … l'aide des infos indispensables
;------------------------------------------------------------------------------
GEN_FSEL::
	xref	ASCII_BUF,COL_FEN,ATTRIBUTE

	move	COL_NOR,COL_FEN
	move	COL_FEN,ATTRIBUTE
	
	*------------------*
	* la ligne d'info
	*------------------*
	move.l	PTR_TITRE,a0
	lea	ASCII_BUF,a6
	col_cpy	a0,a6
	
	move.l	#$d000d,(a6)+


	*------------------*
	* le repertoire courant
	*------------------*
	lea	WORK_BUF,a0
	col_cpy	a0,a6			
	move.l	#$d000d,(a6)+

	
	*------------------*
	* les fichiers
	*------------------*

	move	CURRENT_ACTIVE,d2
	lea	WORK_BUF+256,a0
	move.l	#WORK_BUF+256,a0
	move	(a0)+,d7	
	subq	#1,d7
	bmi.s	.FIN

.LOOP	
	move	NB_COL,d6
	subq	#1,d6
.ONE_COL
	*------------------*
	* la premiere colonne
	*------------------*
	
	moveq	#0,d1		
	subq	#1,d2
	bne.s	.NO_ACT
	move	#$4000,d1
.NO_ACT

	lea	6(a0),a1
.COP0	move	(a1)+,d0
	beq.S	.FIN_ENTRY
	or	d1,d0
	move	d0,(a6)+
	bra.s	.COP0	
.FIN_ENTRY
	rept	4
	move	#' ',(a6)+
	endr
	
	move.l	2(a0),a0
	
	subq	#1,d7
	bmi	.FIN	
	dbra	d6,.ONE_COL	
	move	#$d,-2(a6)

	bra	.LOOP
		
.FIN

				
	*------------------*
	* c'est fini
	*------------------*

	move	#$8000,(a6)+
	rts




	BSS
NB_COL		ds	1		;nb colonnes
NB_LIGNE	ds	1		;nb lignes
PTR_TITRE	ds.l	1
PTR_NAME	ds.l	1
PTR_DEST	ds.l	1
CURRENT_ACTIVE	ds.w	1
SAVE_ACTIVE::	ds.l	1

	DATA
ALL		dc.b	'*.*',0