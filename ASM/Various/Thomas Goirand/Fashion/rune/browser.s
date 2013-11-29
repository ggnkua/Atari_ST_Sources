******************************************
*** Routines generales du file browser ***
******************************************
* XDEF
		XDEF		brows_new
* XREF de zlib
		XREF		dta_buf
* XREF de rune
		XREF		wd_create_brows
		XREF		FILEBROWS_adr
		XREF		display_sec,last_fb_state,last_fb_tri
		include		gemdos.i
		include		util.i
		include		memory.s
		include		macro.i
		include		zlib.i
		include		structs.s
		include		rune.s

SIZE_TEXT	equ	16	; intervale entre 2 textes
H_TEXT		equ	10

*** Donne la taille du plus long des nom d'une structure fb ***
Fbrows_max_nom	macro	; structure_fb
		move.l	\1,-(sp)
		bsr	brows_max_nom
		addq.l	#4,sp
		endm

*** Donne la taille du texte totale pour un repertoire donne en fonctione de fb_state et de la taille des noms ***
Fbrows_max_txt	macro	; structure_fb
		move.l	\1,-(sp)
		bsr	brows_max_txt
		addq.l	#4,sp
		endm

*** Procedure fabriquant le texte d'un objet a afficher en mode texte ***
Fbrows_fbo_txt	macro	; file_name_max_size,fb_state,fbo_struct,dest_string
		move.w	\1,-(sp)
		move.w	\2,-(sp)
		move.l	\3,-(sp)
		move.l	\4,-(sp)
		bsr	brows_fbo_txt
		lea	12(sp),sp
		endm

*** Donne le nombre d'entree d'un repertoire ***
Fbrows_file_nbr	macro	; chemin_n_mask
		move.l	\1,-(sp)
		bsr	brows_file_nbr
		addq.l	#4,sp
		endm

*** Tri les pointeurs sur structures fbo de la structure fb par ordre de nom ***
Fbrows_tri_nom	macro	; structure_fb
		move.l	\1,-(sp)
		bsr	brows_tri_nom
		addq.l	#4,sp
		endm

*** Fabrique une liste de fbo en remplissant les pointeurs de la structure fb ***
Fbrows_make_fbo	macro	; fb_structure
		move.l	\1,-(sp)
		bsr	brows_make_fbo
		addq.l	#4,sp
		endm

Fbrows_make_bound	macro	; structure_fb
		move.l	\1,-(sp)
		jsr	brows_make_bound
		addq.l	#4,sp
		endm

***********************************************
***********************************************
***********************************************
*** Ouverture d'une fenetre du file browser ***
***********************************************
* Fabrique une nouvelle fenetre en remplissant
* une structure fb, en fabriquant les fbo qui
* vont avec, et en fabriquant un nouveau
* formulaire G_BOUNDED
***********************************************
***********************************************
***********************************************
brows_new
		movem.l		d1-a6,-(sp)
		move.l		60(sp),a5

* Determination de la taille de la structure fb pour le Malloc *
		Fbrows_file_nbr	a5
		move.l		d0,d7

		move.l		d0,d6
		lsl.l		#2,d6
		add.l		#fb_fbo,d6	; de la place pour le debut de la structure

* Malloc une structure "fb" que l'on rempli par la suite
		Malloc		d6
		tst.l		d0
		bmi		error
		move.l		d0,a6		; pointeur vers structure fb
		move.l		d7,fb_nbr(a6)

*** Remplissage d'une structure FB ***
		move.w		last_fb_state,fb_state(a6)
		move.w		last_fb_tri,fb_tri(a6)
		lea		fb_path(a6),a0
		string_copy	a5,a0

		cmp.b		#"U",(a0)
		beq		unified_drive
		cmp.b		#"u",(a0)
		beq		unified_drive
		cmp.b		#"/",(a0)
		beq		unified_drive

		Fbrows_make_fbo		a6

		Fbrows_make_bound	a6

* Initialisation en vu de la creation du formulaire G_BOUNDED



* Creation de la fenetre
		wd_create	a6,#wd_create_brows,#-1,#0,#0,#0
		moveq.l		#0,d0
		movem.l		(sp)+,d1-a6
		rts
error
		moveq.l		#-1,d0
		movem.l		(sp)+,d1-a6
		rts
*--------------------------------------------------------------------------------------------------------------------------*
unified_drive
		Dgetdrv
		Dsetdrv		d0
		move.l		d0,d7
		moveq.l		#-1,d4

		moveq.l		#2,d6	; numero de l'objet suivant
		moveq.l		#2,d5	; increment en Y pour les coordonnes des objets

*********************************** Boucle de creation d'un lecteur U
lp_get_drives	addq.l		#1,d4
		cmp.l		#32,d4
		beq		end_get_drives
		btst		d4,d7			; drive present ???
		beq		lp_get_drives

* Remplissage d'un objet G_TEXT (ajoute a la fin de l'arbre)
		move.w		d6,ob_next(a5)
		move.l		#-1,ob_head(a5)	; ob_head & tail en meme temps
		move.w		#G_TEXT,ob_type(a5)
		move.w		#$1,ob_flags(a5)
		move.w		#$0,ob_states(a5)
		Malloc		#te_struc_size
		move.l		d0,ob_spec(a5)
		move.l		d0,a4		; adresse de la tedinfo (routine suivante)
		move.w		#0,ob_x(a5)	; a 0 pixels du bord, on peut modifier ca avec le G_BOUNDING (ds le rsc)
		move.w		d5,ob_y(a5)
		add.w		#SIZE_TEXT,d5
		move.w		#48*16,ob_w(a5)	; 48 caractere de 16 pixels
		move.w		#H_TEXT,ob_h(a5)

* Remplissage de la tedinfo du nouvel objet G_TEXT (au nom et a la forme de la fonte en question)
		move.w		#48,te_txtlen(a4)
* Style du texte, a changer plus tard (parametrage dans le bureau)
		move.w		#3,te_font(a4)		; bitmap grande fontes
		move.w		#0,te_fontid(a4)
		move.w		#0,te_fontsize(a4)
		move.w		#$100,te_color(a4)	; texte en noire
		clr.w		te_just(a4)		; alignement gauche
		clr.w		te_thickness(a4)	; pas de cadre

* Mise a jour du texte de l'objet (nom, taille, date, heure et attribut du fichier)
;		Malloc		#MAX_BROWSTEXT
		bmi		error
		move.l		d0,te_ptext(a4)
		move.l		d0,a3
;		clr_zone	d0,#MAX_BROWSTEXT

		move.b		#" ",(a3)+

************* Nom du lecteur
		move.b		d4,d0
		add.b		#"A",d0
		move.b		d0,(a3)+
		move.b		#0,(a3)+

* Bouclage
		lea		24(a5),a5
		addq.l		#1,d6

		bra		lp_get_drives
***************************************************************** Fin de la boucle
end_get_drives
* Mise a jour du ob_next du dernier objet et du ob_tail du premier objet
		move.l		fb_ptr(a6),a0
		subq.l		#1,d6
		move.w		d6,ob_tail(a0)
		lea		-24(a5),a5
		clr.w		ob_next(a5)

* Creation de la fenetre
		wd_create	a6,#wd_create_brows,#-1,#0,#0,#0

		moveq.l		#0,d0
		movem.l		(sp)+,d1-a6
		rts

		bss
bak_form_adr	ds.l	1
path_nofile	ds.b	PATH_SIZE	; le chemin sans aucun nom de fichier
path_star	ds.b	PATH_SIZE	; le chemin complete de *.*
		even
		text
*--------------------------------------------------------------------------------------------------------------------------*
*************************************************************************
*** Procedure fabriquant le texte d'un objet a afficher en mode texte ***
*************************************************************************
brows_fbo_txt
	movem.l	d1-a6,-(sp)
	move.w	60+10(sp),d6	; taille du plus grand nom (dans le cas du support des nom longs, zero si GEMDOS)
	move.w	60+8(sp),d7	; state de la structure fb
	move.l	60+4(sp),a5	; structure fbo
	move.l	60+0(sp),a6	; texte destination

************************** Symbole a cote du Nom *******************
	cmp.w	#FBOT_FILE,fbo_type(a5)
	beq	.file
	cmp.w	#FBOT_FOLD,fbo_type(a5)
	beq	.folder
	cmp.w	#FBOT_PRG,fbo_type(a5)
	beq	.prg
	cmp.w	#FBOT_LINK,fbo_type(a5)
	beq	.link

.link	move.b	#"",(a6)+
	bra	ok_symbol
.folder	move.b	#"",(a6)+
	bra	ok_symbol
.prg	move.b	#"-",(a6)+
	bra	ok_symbol
.file	move.b	#" ",(a6)+
ok_symbol
************************** Nom du fichier *******************
		lea		fbo_file_name(a5),a2
		tst.w	d6
		bne	nom_long
	*----------------------------------*
		moveq.l		#8,d1
.cp_fname	move.b		(a2)+,d0
		beq		.end_without_extend
		cmp.b		#".",d0
		beq		.end_debut_fnam		; le nom
		subq.w		#1,d1
		move.b		d0,(a6)+
		bra		.cp_fname

.end_without_extend
		addq.w		#4,d1
.complete_we	move.b		#" ",(a6)+
		dbf		d1,.complete_we		; pas d'extention, on complete avec des espaces
		bra		.name_ok

.end_debut_fnam	tst		d1
		beq		.cp_extend
		subq.w		#1,d1

.complete_deb	move.b		#" ",(a6)+
		dbf		d1,.complete_deb	; on aligne l'extention

.cp_extend	move.b		#".",(a6)+		; on ajoute le "."

		moveq.l		#4,d1
.loop_extend	subq.w		#1,d1
		move.b		(a2)+,(a6)+
		bne		.loop_extend
		subq.l		#1,a6

.end_extention	move.b		#" ",(a6)+
		dbf		d1,.end_extention	; complete l'extention par des espaces

.name_ok
		bra		nom_ok
	*----------------------------------*
nom_long	move.b		(a2)+,(a6)+
		beq		.fin_nom
		dbf		d6,nom_long
		bra		nom_ok
.fin_nom	move.b		#" ",(a6)+
		dbf		d6,.fin_nom
nom_ok
		move.b		#" ",(a6)+
************************** Taille si programme ou fichier et si FB_SIZE = 1 *******************
	btst	#FB_SIZE,d7
	beq	taille_ok

	cmp.w	#FBOT_FOLD,fbo_type(a5)
	beq	.no_taille
	cmp.w	#FBOT_LINK,fbo_type(a5)
	beq	.no_taille


		long_2_filesize	fbo_size(a5),a6
.find_end_size	tst.b		(a6)+
		bne		.find_end_size
		subq.l		#1,a6
		move.b		#" ",(a6)+
		move.b		#" ",(a6)+
		bra		taille_ok

.no_taille	move.w		#9,d0
.lp_add_space	move.b		#" ",(a6)+
		dbf		d0,.lp_add_space
taille_ok
************************** Date si FB_DATE = 1 *******************
		btst		#FB_DATE,d7
		beq		no_date
		date_2_string	fbo_date(a5),a6
.find_end_date	tst.b		(a6)+
		bne		.find_end_date
		subq.l		#1,a6
		move.b		#" ",(a6)+
		move.b		#" ",(a6)+
no_date

************************** Heure si FB_TIME = 1 *******************
		btst		#FB_TIME,d7
		time_2_string	fbo_time(a5),a6,display_sec
.find_end_time	tst.b		(a6)+
		bne		.find_end_time
		subq.l		#1,a6
		move.b		#" ",(a6)+
		move.b		#" ",(a6)+
no_time

************************** Attributs FB_ATRB = 1 *******************
		btst		#FB_ATRB,d7
		beq		no_attributs
		dosattrb_2_string	fbo_attrb(a5),a6
.find_end_attrb	tst.b		(a6)+
		bne		.find_end_attrb
		subq.l		#1,a6

no_attributs
		move.b		#0,(a6)+
	movem.l	(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
***************************************************************
*** Donne la taille du plus long des nom d'une structure fb ***
***************************************************************
* Retour : d0 = nombre max de caractere d'un fichier dans le dossier
* Si dommain = DOS, alors "8+1+3"=12 (nom+point+extention)
brows_max_nom	movem.l		d1/d7/a5-a6,-(sp)
		move.l		12+0(sp),a6	; structure fb

		btst		#FB_UNIX,fb_state+1(a6)
		beq		.nom_dos

* Nom UNIX : on calcule la taille maxi
		lea		fb_fbo(a6),a6
		move.l		fb_nbr(a6),d7
		moveq.l		#0,d0

.lp_max_nom	move.l		(a6)+,a5
		lea		fbo_file_name(a5),a5
		moveq.l		#-1,d1
.lp_search_size	addq.l		#1,d1
		tst.b		(a5)+
		bne		.lp_search_size

		cmp.l		d1,d0
		bge		.lp_max_nom
		move.l		d1,d0

		subq.l		#1,d7
		bne		.lp_max_nom
		bra		.end

.nom_dos	moveq.l		#8+1+3,d0

.end		movem.l		(sp)+,d1/d7/a5-a6
		rts
*--------------------------------------------------------------------------------------------------------------------------*
******************************************************************************************************************
*** Donne la taille du texte totale pour un repertoire donne en fonctione de fb_state et de la taille des noms ***
******************************************************************************************************************
* Retour dans d0
brows_max_txt	movem.l		d6/d7/a6,-(sp)
		move.l		16+0(sp),a6	; structure fb

		move.w		fb_state(a6),d6

		btst		#FB_ICON,d6
		bne		.bigicon

* La fenetre est afficher sous forme de mini icon et d'un texte
		*--- Nom ---*
		Fbrows_max_nom	a6			* *""		; 1 symbole
		move.l		d0,d7			*"FILENAME.TXT"	; 8+3+1 ou
		addq.l		#3,d7			;"file.txt"	; taille maxi (ds le cas UNIX)
							*"  "		; 2 espaces
		*--- Taille ---*
		btst		#FB_SIZE,d6		*"9 999 KB"	; 8 caractere...
		beq		.no_size		;"  "		; ...+2 espaces pour la taille
		add.l		#10,d7
.no_size
		*--- Date ---*
		btst		#FB_DATE,d6		*"15/02/99"	; idem pour la date
		beq		.no_date		*"  "
		add.l		#10,d6
.no_date	
		*--- Time ---*
		btst		#FB_TIME,d6		*"12h20"	; 5...
		beq		.no_time		*"m22"		; ...ou 8 pour l'heure...
		addq.l		#7,d7			*"  "		; ...+2 espace
		tst.w		display_sec
		beq		.no_time
		addq.l		#3,d7
.no_time
		*--- Attrb ---*
		btst		#FB_ATRB,d6
		bne		.no_attribs		*"rsah"		; 4...
		addq.l		#4,d7			;"drwx---rwx"	; ...ou 10 pour les attributs
		btst		#FB_UNIX,d6
		beq		.no_unix_attrb
		addq.l		#6,d7
.no_unix_attrb
.no_attribs
		*--- Fin de chaine ---*
		addq.l		#1,d7			*0		; +1

		move.l		d7,d0
		movem.l		(sp)+,d6/d7/a6
		rts


* La fenetre est afficher en icones
.bigicon	illegal

		movem.l		(sp)+,d6/d7/a6
		rts
*--------------------------------------------------------------------------------------------------------------------------*
************************************************
*** Donne le nombre d'entree d'un repertoire ***
************************************************
brows_file_nbr	movem.l		d1-d2/d7/a0-a2/a6,-(sp)
		move.l		32+0(sp),a6	; chemin+mask ou chercher
		moveq.l		#0,d7

		Fsfirst		#$37,a6
		tst.w		d0
		bmi		.error

.lp_names	addq.l		#1,d7
		Fsnext		#$37,a6
		tst.w		d0
		bge		.lp_names
		move.l		d7,d0
		movem.l		(sp)+,d1-d2/d7/a0-a2/a6
		rts

.error		moveq.l		#-1,d0
		movem.l		(sp)+,d1-d2/d7/a0-a2/a6
		rts
*--------------------------------------------------------------------------------------------------------------------------*
********************************************************************************
*** Tri les pointeurs sur structures fbo de la structure fb par ordre de nom ***
********************************************************************************
brows_tri_nom
	movem.l	d1-a6,-(sp)
	movem.l	60+0(sp),a6	; structure fb


	movem.l	(sp)+,d1-a6
	rts
*--------------------------------------------------------------------------------------------------------------------------*
*********************************************************************************
*** Fabrique une liste de fbo en remplissant les pointeurs de la structure fb ***
*********************************************************************************
brows_make_fbo
		movem.l		d1-a6,-(sp)
		move.l		60+0(sp),a6

		lea		fb_fbo(a6),a5
		lea		fb_path(a6),a4
		move.l		fb_nbr(a6),d7	; nombre de fichier dans le repertoire

		move.l		#sizeof_fbo,d6
		mulu.l		d7,d6
		Malloc		d6
		tst.l		d0
		beq		.error
		bmi		.error
		move.l		d0,a3

		Fsfirst		#$37,a4

.lp_make_fbo	move.l		a3,(a5)+
		lea		dta_buf,a0

************************** attributs du fichier
		moveq.l		#0,d5
		move.b		dta_attrb(a0),d5	
		move.w		d5,fbo_attrb(a3)

************************** Type du fichier
		btst		#GDF_DIR,d5
		beq		.not_folder
		move.w		#FBOT_FOLD,fbo_type(a3)
		bra		.type_ok

.not_folder	lea		dta_name(a0),a1
.lp_find_ext	tst.b		(a1)
		beq		.file
		cmp.b		#".",(a1)+
		bne		.lp_find_ext
		subq.l		#1,a1
		cmp.l		#".PRG",(a1)
		beq		.prog
		cmp.l		#".prg",(a1)
		beq		.prog
		cmp.l		#".PRX",(a1)
		beq		.prog
		cmp.l		#".prx",(a1)
		beq		.prog
		cmp.l		#".ACC",(a1)
		beq		.prog
		cmp.l		#".acc",(a1)
		beq		.prog
		cmp.l		#".ACX",(a1)
		beq		.prog
		cmp.l		#".acx",(a1)
		beq		.prog
		cmp.l		#".TTP",(a1)
		beq		.prog
		cmp.l		#".ttp",(a1)
		beq		.prog
		cmp.l		#".TOS",(a1)
		beq		.prog
		cmp.l		#".tos",(a1)
		beq		.prog
		cmp.l		#".APP",(a1)
		beq		.prog
		cmp.l		#".app",(a1)
		beq		.prog
		cmp.l		#".APX",(a1)
		beq		.prog
		cmp.l		#".apx",(a1)
		beq		.prog
		cmp.l		#".GTP",(a1)
		beq		.prog
		cmp.l		#".gtp",(a1)
		beq		.prog

		cmp.l		#".LNK",(a1)
		beq		.link
		cmp.l		#".lnk",(a1)
		beq		.link
.file
		move.w		#FBOT_FILE,fbo_type(a3)
		bra		.type_ok
.link		move.w		#FBOT_LINK,fbo_type(a3)
		bra		.type_ok
.prog		move.w		#FBOT_PRG,fbo_type(a3)

.type_ok
************************** Icone ***
		move.w		#0,fbo_fron_icon(a3)	; pour l'instant, tout a 0
************************** Taille, date et heure ***
		move.l		dta_lenght(a0),fbo_size(a3)
		move.l		dta_date(a0),fbo_date(a3)
		move.l		dta_time(a0),fbo_time(a3)
************************** Nom ***
		lea		dta_name(a0),a1
		lea		fbo_file_name(a3),a2
.lp_cp_name	move.b		(a1)+,(a2)+
		bne		.lp_cp_name

************************** Fin de boucle ***
		lea		sizeof_fbo(a3),a3

		Fsnext		#$37,a4
		tst.w		d0
		bge		.lp_make_fbo

		movem.l		(sp)+,d1-a6
		rts

.error		moveq.l		#-1,d0
		movem.l		(sp)+,d1-a6
		rts

*************************************************************************
*** Fabrique un formulaire G_BOUNDED a partir d'une structure FB trie ***
*************************************************************************
brows_make_bound
		movem.l		d1-a6,-(sp)
		move.l		60+0(sp),a6

		btst		#FB_ICON,fb_state+1(a6)
		beq		.texte_mode

*** Ici, affichage sous forme d'icone ***
		illegal

*** Ici, affchage sous forme de texte ***
.texte_mode
* Calcule de la taille de ce que prend les textes et malloc ds un buffer
		Fbrows_max_txt	a6			; la taille du champ texte
		move.l		d0,d4
		move.l		d0,d7
		add.l		#te_struc_size,d7	; plus une tedinfo
		move.l		fb_nbr(a6),d0
		addq.l		#4,d0
		mulu.l		d0,d7		; * le nombre de fichier
		Malloc		d7
		tst.l		d0
		beq		error
		bmi		error
		move.l		d0,fb_txt_ptr(a6)
		move.l		d0,a3

* Reservation de memoire pour le formulaire
		move.l		fb_nbr(a6),d7
		mulu.l		#24*3,d7		; 1 fichier = 3 objet GEM
		add.l		#24*2,d7		; 1 dossier = +2 objets (G_BOUNDING + G_PIX)
		Malloc		d7
		tst.l		d0
		bmi		error
		move.l		d0,fb_ptr(a6)
		move.l		d0,a5			; pointeur vers le formulaire

* Remplissage de la G_BOUNDED racine
		move.l		#$ffff0001,(a5)		; structures de base...
		move.w		#G_BOUNDED,ob_type(a5)	; ...reste le OB_TAIL a updater
		move.l		#0,ob_flags(a5)
		move.w		#0,ob_x(a5)
		move.w		#0,ob_y(a5)

		Malloc		#sizeof_gbd		; on malloc un ob_spec et on le rempli
		move.l		d0,ob_spec(a5)
		move.l		d0,a4
		move.l		FILEBROWS_adr,gbd_tree(a4)
		move.w		#BROWS_BOUND,gbd_index(a4)
		clr.w		gbd_flags(a4)

		lea		24(a5),a5
		moveq.l		#2,d6	; numero de l'objet suivant
		moveq.l		#2,d5	; increment en Y pour les coordonnes des objets
		lea		fb_fbo(a6),a4

		btst		#FB_UNIX,fb_state+1(a6)
		bne		.unix
		moveq.l		#0,d3
		bra		.dos
.unix
		Fbrows_max_nom	a6
		move.l		d0,d3
.dos
		move.l		fb_nbr(a6),d2
lp_get_dosnames
* Remplissage d'un objet G_TEXT (ajoute a la fin de l'arbre)
		move.w		d6,ob_next(a5)
		move.l		#-1,ob_head(a5)	; ob_head & tail en meme temps
		move.w		#G_TEXT,ob_type(a5)
		move.w		#$1,ob_flags(a5)
		move.w		#$0,ob_states(a5)
		move.w		#0,ob_x(a5)	; a 0 pixels du bord, on peut modifier ca avec le G_BOUNDING (ds le rsc)
		move.w		d5,ob_y(a5)
		add.w		#SIZE_TEXT,d5
		move.w		#48*16,ob_w(a5)	; 48 caractere de 16 pixels
		move.w		#SIZE_TEXT,ob_h(a5)
		move.l		a3,ob_spec(a5)

* Remplissage de la tedinfo du nouvel objet G_TEXT (au nom et a la forme de la fonte en question)
		move.w		d4,te_txtlen(a3)
* Style du texte, a changer plus tard (parametrage dans le bureau)
		move.w		#3,te_font(a3)		; bitmap grande fontes
		move.w		#0,te_fontid(a3)
		move.w		#0,te_fontsize(a3)
		move.w		#$100,te_color(a3)	; texte en noire
		clr.w		te_just(a3)		; alignement gauche
		clr.w		te_thickness(a3)	; pas de cadre
		add		#te_struc_size,a3

* Mise a jour du texte de l'objet (nom, taille, date, heure et attribut du fichier)
		move.l		a3,te_ptext-te_struc_size(a3)

		Fbrows_fbo_txt	d3,fb_state(a6),(a4)+,a3
.find_end	tst.b		(a3)+
		bne		.find_end

* Fin de la boucle
		addq.l		#1,d6
		lea		24(a5),a5
		subq.l		#1,d2
		bne		lp_get_dosnames

* Mise a jour du ob_next du dernier objet et du ob_tail du premier objet

		move.l		fb_ptr(a6),a0
		subq.l		#2,d6
		move.w		d6,ob_tail(a0)
		lea		-24(a5),a5
		clr.w		ob_next(a5)

		movem.l		(sp)+,d1-a6
		rts
****************************************************************
*** Detrui le formulaire G_BOUNDED et tout ce qu'il conteint ***
****************************************************************
brows_kill_bound

