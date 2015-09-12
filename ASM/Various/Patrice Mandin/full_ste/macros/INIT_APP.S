;	Initialisation d'une application

;	ARGC  (mot)	nb de params dans la ligne de commande
;	ARGV (long)	paramätres de la ligne de commande
;	ENV  (long)	variables d'environnement
;	PILE (long)	taille de la pile

	TEXT

START_APP	MACRO	argc,argv,env,pile

	move.l	a0,d0	; a0<>0 si accessoire = adr basepage
	bne.s	_accessoire
	move.l	4(sp),d0	; basepage est en 4(sp)
	clr	_acc_flag	; flag app/acc
	bra.s	_application
_accessoire	move	#-1,_acc_flag
_application
	move.l	d0,a0	; a0 est la basepage
	move.l	a0,a6	; sauve adresse basepage

	move.l	12(a0),d0	;   taille zone TEXT
	add.l	20(a0),d0	; + taille zone DATA
	add.l	28(a0),d0	; + taille zone BSS
	add.l	\4,d0	; + taille de la pile
	add.l	#256,d0	; + taille de la basepage
			; = Taille du programme
	move.l	d0,d1
	add.l	a0,d1
	and	#-4,d1
	move.l	d1,sp	; Init nouvelle pile

	tst	_acc_flag	; accessoire : pas env et arguments
	bne	_pas_init_app

	MSHRINK	a0,d0	; libäre mÇmoire non utile

	; -------------	Lecture de l'environnement
	
	lea	0,a4	; adresse params si ARGV
	pea	0	; derniäre variable d'environnement
	moveq	#0,d0	; nb de variables

	move.l	$2c(a6),a5	; adresse environnement
	tst.b	(a5)
	beq.s	_fin_env
_lire_env
	tst.b	(a5)	; si pas octet nul
	beq.s	_fin_lire_env
	pea	(a5)	;   mettre l'adresse dans la pile
	addq	#1,d0
_bcl_lire_env	
	tst.b	(a5)+	;   si octet nul on arrete
	beq.s	_lire_env
	
	cmp.b	#'A',-1(a5)	; teste si "ARGV="
	bne.s	_bcl_lire_env	; si oui c'est la derniere variable
	cmp.b	#'R',0(a5)	; d'environnement
	bne.s	_bcl_lire_env	; tout le reste est la ligne de commande
	cmp.b	#'G',1(a5)
	bne.s	_bcl_lire_env
	cmp.b	#'V',2(a5)
	bne.s	_bcl_lire_env
	cmp.b	#'=',3(a5)
	bne.s	_bcl_lire_env
	cmp.b	#127,128(a6)	; si longueur cmd line<>127, pas ARGV
	bne.s	_bcl_lire_env

	clr.l	(sp)+	; supprime ARGV de la pile
	subq	#1,d0	; idem dans le nb de variables
	lea	4(a5),a5

_env_argv	tst.b	(a5)+	; passe la valeur de ARGV
	bne.s	_env_argv

	move.l	a5,a4
_fin_lire_env
	; Remet les variables dans l'ordre
	
	move.l	sp,a3
	moveq	#0,d2
	move.l	d0,d2
	add.l	d2,d2
	add.l	d2,d2
	lsr	#1,d0
	beq.s	_fin_env
	subq	#1,d0
	lea	(sp,d2.l),a2
_permute_env	move.l	(a3),d2
	move.l	-4(a2),(a3)+
	move.l	d2,-(a2)
	dbra	d0,_permute_env
_fin_env
	move.l	sp,\3	; renvoie l'adresse des variables

	; ------------- Lecture de la ligne de commande

	move.l	a4,a0
	move.l	a4,d0
	beq.s	_arg_init

	pea	0	; dernier parametre
	moveq	#0,d0
	tst.b	(a5)
	beq.s	_fin_args
_lire_argv
	tst.b	(a5)
	beq.s	_fin_lire_arg
	pea	(a5)
	addq	#1,d0
_lire_argv1
	tst.b	(a5)+
	bne.s	_lire_argv1
	bra.s	_lire_argv
_arg_init
	lea	129(a6),a0
	moveq	#0,d1	; nb de caracteres ligne de commande
	move.b	128(a6),d1
	lea	_empty_name,a1

	pea	0	; dernier param
	pea	(a1)	; balance le prg : argv[0]
	moveq	#1,d0	; nb de params -> argc
	tst	d1
	beq.s	_fin_lire_arg
_bcl_lire_arg
	cmp.b	#' ',(a0)
	beq.s	_bcl_lire_arg1
	cmp.b	#'"',(a0)
	beq.s	_bcl_lire_arg1
	pea	(a0)
	addq	#1,d0
_bcl_lire_arg2	
	tst.b	(a0)
	beq.s	_fin_lire_arg
	cmp.b	#' ',(a0)
	beq.s	_bcl_lire_arg
	cmp.b	#'"',(a0)
	beq.s	_bcl_lire_arg
	addq	#1,a0
	bra.s	_bcl_lire_arg2
_bcl_lire_arg1
	clr.b	(a0)+
	bra.s	_bcl_lire_arg
_fin_lire_arg
	; Inverse les arguments

	move.l	sp,a3
	moveq	#0,d2
	move.l	d0,d2
	add.l	d2,d2
	add.l	d2,d2
	move	d0,d1
	lsr	#1,d1
	beq.s	_fin_args
	subq	#1,d1
	lea	(sp,d2.l),a2
_permute_arg	move.l	(a3),d2
	move.l	-4(a2),(a3)+
	move.l	d2,-(a2)
	dbra	d1,_permute_arg
_fin_args
	move	d0,\1
	move.l	sp,\2

	; -------------	Fin de l'initialisation
_pas_init_app
	ENDM
	
; -------------	Initialisation d'une application GEM
;	> application	sous programme correspondant Ö l'application
;	> rsc_name	nom du fichier ressource
;	> menu	nb de l'objet correspondant au menu
;	< adr_menu	adresse de base du menu de l'application
;	> app_title	nom de l'application (dans le menu)
;	> app_name	nom du programme (dans u:\proc)

START_GEM	MACRO	application,rsc_name,menu,adr_menu,app_title,app_name
	APPL_INIT
	move	_int_out,_ap_id
	cmp	#-1,_ap_id
	beq	_fin
	
	GRAF_MOUSE	#_ARROW

	cmp	#-1,_ap_count
	bne	_notMint
	IFEQ	NARG-5
	MENU_REGISTER	_ap_id,\4
	ENDC
	IFEQ	NARG-6
	MENU_REGISTER	#_REG_NEWNAME,\5
	ENDC
_notMint	
	IFNE	NARG-1
	RSRC_LOAD	\2
	tst	_int_out
	beq	_fin1

	RSRC_GADDR	#_R_TREE,\3,\4

	WIND_UPDATE	#_BEG_UPDATE
	MENU_BAR	\4,#_MENU_INSTALL
	WIND_UPDATE	#_END_UPDATE
	ENDC

	lea	_vdiparblk_in,a0
	moveq	#9,d0
_initvdiparblk	move	#1,(a0)+
	dbra	d0,_initvdiparblk
	move	#2,(a0)
	GETREZ
	addq	#2,d0
	move	d0,_vdiparblk_in
	GRAF_HANDLE	_char_width,_char_height,_box_width,_box_height
	move	_int_out,_vdi_handle
	V_OPNVWK	#_vdiparblk_in,_vdi_handle,#_vdiparblk_out

	jsr	\1

	V_CLSVWK	_vdi_handle
	MENU_BAR	\4,#_MENU_REMOVE
	RSRC_FREE
_fin1	APPL_EXIT
_fin	
	ENDM

	DATA
	
_empty_name	dc.b	32,0
	even

	BSS

;	Infos START_APP

_acc_flag	ds.w	1

;	Infos START_GEM

_vdi_handle	ds.w	1
_vdiparblk_in	ds.w	11
_vdiparblk_out	ds.w	57	
_char_width	ds.w	1
_char_height	ds.w	1
_box_width	ds.w	1
_box_height	ds.w	1