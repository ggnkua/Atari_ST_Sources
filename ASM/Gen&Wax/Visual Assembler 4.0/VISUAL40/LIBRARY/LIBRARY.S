; Les fonctions en tˆte sont incluses tout le temps ...

		*--------------------------*

GWVA_COUNT_BYTES_0:			; a0=ptr string
	clr.b d1
GWVA_COUNT_BYTES:			; a0=ptr string d1=end of string char
	clr.l d0
.redo:	cmp.b 0(a0,d0.l),d1
	beq.s .fin
	addq.l #1,d0
	bra.s .redo
.fin:	rts

		*--------------------------*

GWVA_APP_OBJ_STORE_CURRENT_PATH:		; a0=ptr => U:\PATH\

	save.l a0
	DGETDRV d0
	load.l a0
	add.b #'A',d0
	move.b d0,(a0)+
	move.b #':',(a0)+

	clr.b (a0)
	save.l a0
	DGETPATH #0,(a0)
	load.l a0

.find_end:	tst.b (a0)+
	bne.s .find_end
	move.w #'\'*256,-1(a0)
	rts

GWVA_APP_OBJ_SET_PATH:		; a0=ptr => U:\PATH\

	clr d0
	move.b (a0),d0
	sub.b #'A',d0
	save.l a0
	DSETDRV d0
	load.l a0

	DSETPATH 2(a0)

	rts

		*--------------------------*

GWVA_APP_OBJ_SEARCH_SYSTEM_COOKIES:

	move.l $4f2.w,a0		; Adresse de la ROM
	move.w 2(a0),GWVA_APP_OBJ_COOKIE_TOS_VERSION

	move.l #'FSEL',GWVA_APP_OBJ_SEARCH_IN_OUT
	bsr.s GWVA_APP_OBJ_SEARCH_ONE_COOKIE
	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,a0
	cmp.l #0,a0
	beq.s .no_fsel
	move.l (a0),a1
	cmp.l #'SLCT',(a1)
	bne.s .no_trix
	move.l a1,GWVA_APP_OBJ_COOKIE_SELECTRIX_PTR
	lea 4+2+2+2+2+4+2+4(a1),a1
	move.l a1,GWVA_APP_OBJ_COOKIE_SELECTRIX_COMM_WORD
	lea 2+2+4(a1),a1
	move.l a1,GWVA_APP_OBJ_COOKIE_SELECTRIX_OUT_COUNT
	lea 2(a1),a1
	move.l a1,GWVA_APP_OBJ_COOKIE_SELECTRIX_OUT_PTR
.no_fsel:
.no_trix:

	move.l #"_FPU",GWVA_APP_OBJ_SEARCH_IN_OUT
	bsr.s GWVA_APP_OBJ_SEARCH_ONE_COOKIE
	tst.l GWVA_APP_OBJ_SEARCH_IN_OUT
	beq.s .no_copro
	move.w ([GWVA_APP_OBJ_SEARCH_IN_OUT]),GWVA_APP_OBJ_COOKIE_COPRO
.no_copro:

	move.l #"MiNT",GWVA_APP_OBJ_SEARCH_IN_OUT
	bsr.s GWVA_APP_OBJ_SEARCH_ONE_COOKIE
	tst.l GWVA_APP_OBJ_SEARCH_IN_OUT
	beq.s .no_mint
	move.w (2,[GWVA_APP_OBJ_SEARCH_IN_OUT]),GWVA_APP_OBJ_COOKIE_MINT
.no_mint:

	rts

GWVA_APP_OBJ_SEARCH_ONE_COOKIE:	; In : GWVA_APP_OBJ_SEARCH_IN_OUT, Out : GWVA_APP_OBJ_SEARCH_IN_OUT = ptr sur le mot long aprŠs la chaine donn‚e comme recherche ou 0.l si pas trouv‚
	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,d0
	clr.l GWVA_APP_OBJ_SEARCH_IN_OUT

	move.l $5a0.w,a0
	cmp.l #0,a0
	beq.s .no_cookie

.next:	tst.l (a0)
	beq.s .end_list

	cmp.l (a0),d0
	beq.s .found

	lea 8(a0),a0
	bra.s .next

.found:	lea 4(a0),a0
	move.l a0,GWVA_APP_OBJ_SEARCH_IN_OUT
.end_list:
.no_cookie:
	rts

*--------------------------------------------------------------------------*

	ifd LIB_XBRA

GWVA_APP_OBJ_SEARCH_ONE_XBRA:	; In : GWVA_APP_OBJ_SEARCH_IN_OUT : vecteur
			; In2: GWVA_APP_OBJ_SEARCH_IN_OUT+4 : texte xbra
			; Out: GWVA_APP_OBJ_SEARCH_IN_OUT = ptr sur le mot long aprŠs la chaine donn‚e comme recherche ou 0.l si pas trouv‚


	move.l ([GWVA_APP_OBJ_SEARCH_IN_OUT]),a0
	move.l GWVA_APP_OBJ_SEARCH_IN_OUT+4,d0

	clr.l GWVA_APP_OBJ_SEARCH_IN_OUT

.search:	cmp.l #'XBRA',-12(a0)
	bne.s .fin_liste

	cmp.l -8(a0),d0
	beq.s .found

	move.l -4(a0),a0
	cmp.l #0,a0
	beq.s .fin_liste
	bra.s .search

.found:	move.l a0,GWVA_APP_OBJ_SEARCH_IN_OUT
.fin_liste:	rts

GWVA_APP_OBJ_INSTALL_ONE_XBRA:	; In : GWVA_APP_OBJ_SEARCH_IN_OUT : vecteur
			; In2: GWVA_APP_OBJ_SEARCH_IN_OUT+4 : ptr nouvelle routine avec avant : XBRA, "TEXT", 0.l
			; Out: GWVA_APP_OBJ_SEARCH_IN_OUT = 0.l si install correcte

	; Ne teste pas s'il existe d‚j…, … vous de le faire
	; en vous servant de GWVA_APP_OBJ_SEARCH_ONE_XBRA

	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,a0
	move.l GWVA_APP_OBJ_SEARCH_IN_OUT+4,a1

	move.l #-1,GWVA_APP_OBJ_SEARCH_IN_OUT

	cmp.l #'XBRA',-12(a1)
	bne.s .cannot_install
	tst.l -4(a1)
	bne.s .cannot_install

	move.l (a0),-4(a1)
	move.l a1,(a0)
	clr.l GWVA_APP_OBJ_SEARCH_IN_OUT

.cannot_install:
	rts

GWVA_APP_OBJ_REMOVE_ONE_XBRA:	; In : GWVA_APP_OBJ_SEARCH_IN_OUT : vecteur
			; In2: GWVA_APP_OBJ_SEARCH_IN_OUT+4 : texte cookie
			; Out: GWVA_APP_OBJ_SEARCH_IN_OUT = -1 si pas trouv‚, 0 si removed

	move.l GWVA_APP_OBJ_SEARCH_IN_OUT,a0
	move.l GWVA_APP_OBJ_SEARCH_IN_OUT+4,d0

	move.l #-1,GWVA_APP_OBJ_SEARCH_IN_OUT

.search:	move.l (a0),a1	; a0=ptr sur struct XBRA
	cmp.l #0,a1
	beq.s .fin_liste
	cmp.l #'XBRA',-12(a1)
	bne.s .fin_liste

	cmp.l -8(a1),d0
	beq.s .found

	lea -4(a1),a0
	bra.s .search

.found:	move.l -4(a1),(a0)
	clr.l -4(a1)
	clr.l GWVA_APP_OBJ_SEARCH_IN_OUT
.fin_liste:	rts

	endc

*--------------------------------------------------------------------------*

	ifd MDL_MENU

GWVA_SHOW_MENU:	; Passe dans a0.l l'adresse de l'objet MENU … afficher
	save.l a0
	wind_update #BEG_UPDATE
	load.l a0
	menu_bar a0,#1
	wind_update #END_UPDATE
	rts

GWVA_HIDE_MENU:	; Passe dans a0.l l'adresse de l'objet MENU … effacer
	save.l a0
	wind_update #BEG_UPDATE
	load.l a0
	menu_bar a0,#0
	wind_update #END_UPDATE
	rts

GWVA_CHECK_MENU: 	; Passe dans a0.l l'adresse de l'objet MENU
	menu_icheck a0,d0,d1	; d0 : num‚ro du menu, d1 : 0=effacer,1=afficher
	rts

GWVA_GREY_MENU: 	; Passe dans a0.l l'adresse de l'objet MENU
	menu_ienable a0,d0,d1	; d0 : num‚ro du menu, d1 : 0=disable,1=enable
	rts

	endc

*--------------------------------------------------------------------------*

	ifd MDL_WIND_FORM

GWVA_FIND_FATHER_OBJECT:	; a0:pointeur objet root d'un form  d0:num‚ro du fils dont on cherche le pŠre
			; sortie : d0=pŠre d7<0 si pas de pŠre et a0.l pointeur sur cet objet
	tst d0
	beq.s .root

	move d0,d1
	mulu #L_OBJECT,d1
	lea 0(a0,d1.l),a1
	move d0,d1		; d0=courant d1=pr‚c‚dent

.boucle:	move ob_next(a1),d0
	move d0,d2
	mulu #L_OBJECT,d2
	lea 0(a0,d2.l),a1	; a1 : adresse de l'objet courant
	cmp ob_tail(a1),d1	; est-ce que ob_tail obj suivant = nous ?
	beq.s .found_father
	move d0,d1		; nouveau pr‚c‚dent = courant pour la suite
	bra.s .boucle
.found_father:
	move.l a1,a0
	clr d7
	rts

.root:	moveq #GWVA_ERROR_GENERIC,d7
	rts

GWVA_ENABLE_DISABLE_OBJECT:	; d0.w : num‚ro du formulaire, d1.w : num‚ro de l'objet, d2=nouvel ‚tat (1=disable)

	save.w d2
	bsr RETURN_OBJ_IN_FORM_OBJ_PTR
	load.w d2

	bclr #3,ob_state+1(a1)
	tst d2
	beq.s .cleared
	bset #3,ob_state+1(a1)
.cleared:	rts

GWVA_SHOW_HIDE_TREE:	; d0.w : num‚ro du formulaire, d1.w : num‚ro de l'objet, d2=nouvel ‚tat (1 = hide)

	save.w d2
	bsr RETURN_OBJ_IN_FORM_OBJ_PTR
	load.w d2

	bclr #7,ob_flags+1(a1)
	tst d2
	beq.s .cleared
	bset #7,ob_flags+1(a1)
.cleared:	rts

	endc

*--------------------------------------------------------------------------*
; d0 : num‚ro de l'alert box dans le ressource
; d1 : numero du bouton par d‚faut gauche(1)->milieu(2)->droite(3)
; retourne dans d0 le num‚ro du bouton

	ifd MDL_GEM
RSC_ALERT_BOX:	; d0=num‚ro dans le ressource, d1=bouton d‚faut (1->3) sortie : d0=bouton
	save.w d1
	rsrc_gaddr #5,d0	; R_STRING : Free String Data
	move.l addr_out,a0
	load.w d0

	bsr.s ALERT_BOX
	rts
		*------------------------*
; a0 : chaine d'alerte
; d0 : numero du bouton par d‚faut gauche(1)->milieu(2)->droite(3)
; retourne dans d0 le num‚ro du bouton

ALERT_BOX:	; a0=ptr chaine, d0=bouton d‚faut(1->3) sortie : d0=bouton
	form_alert d0,a0
	move.w int_out,d0
	rts
		*------------------------*
RETURN_TREE_OBJ_PTR:		; a0=adresse de stockage de l'adresse de base du
	save.l a0		; formulaire dont le num‚ro est dans D0
	rsrc_gaddr #0,d0
	load.l a0
	move.l addr_out,(a0)
	rts
		*------------------------*
	ifd LIB_FORMULARY

GWVA_PRG_MODAL_FORM:	; entr‚e : d0.w = num‚ro formulaire / sortie : d0.w = objet EXIT ou TOUCHEXIT

	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr.s RETURN_TREE_OBJ_PTR

	ifd MDL_WIND_BITMAP

	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi.s .the_top_windows_is_not_mine

	bsr GWVA_WBITM_OBJ_PRG_RESET_DESK_PALETTE
.the_top_windows_is_not_mine:

	endc

	wind_update #BEG_UPDATE

	form_center GWVA_APP_OBJ_TMP_ADD_TREE

	movem.w int_out+1*2,d1-d4

	save.w d1-d4
	graf_mouse #M_OFF
	movem.w (sp),d1-d4
	form_dial #0,#0,#0,#0,#0,d1,d2,d3,d4
	movem.w (sp),d1-d4
	form_dial #1,#0,#0,#10,#10,d1,d2,d3,d4
	movem.w (sp),d1-d4
	objc_draw GWVA_APP_OBJ_TMP_ADD_TREE,#0,#12,d1,d2,d3,d4
	graf_mouse #M_ON

	form_do GWVA_APP_OBJ_TMP_ADD_TREE,#0
	load.w d1-d4
	save.w d0-d4
	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0
	move d0,d1
	mulu #L_OBJECT,d1
	bclr #0,ob_state+1(a0,d1.l)	; de-selected

	graf_mouse #M_OFF
	movem.w (sp),d0-d4
	form_dial #2,#0,#0,#10,#10,d1,d2,d3,d4
	movem.w (sp),d0-d4
	form_dial #3,#0,#0,#0,#0,d1,d2,d3,d4
	graf_mouse #M_ON

	wind_update #END_UPDATE

	ifd MDL_WIND_BITMAP
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE
	endc

	load.w d0-d4
	rts

 	endc
		*------------------------*
; Entr‚e :	d0.w : num‚ro de l'objet tree
; Sortie :	d0.w : bord gauche
; 	d1.w : bord haut
; 	d2.w : bord droit
; 	d3.w : bord bas
;	a0.l : ptr sur l'objet
RETURN_FORM_OBJ_SCULPTURE:
	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr RETURN_TREE_OBJ_PTR
	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0
	movem.w ob_x(a0),d0-d3
	movem.w d0-d3,-(sp)
	form_center GWVA_APP_OBJ_TMP_ADD_TREE

	movem.w int_out+2,d4-d7

	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0
	movem.w ob_x(a0),d0-d3
	
	sub.w d4,d0		; bord gauche
	sub.w d2,d6
	sub.w d0,d6		; bord droit

	sub.w d5,d1		; bord haut
	sub.w d3,d7
	sub.w d1,d7		; bord bas

	move.w d6,d2
	move.w d7,d3

	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0
	movem.w (sp)+,d4-d7
	movem.w d4-d7,ob_x(a0)

	rts
		*------------------------*
; Entr‚e :	d0.w : num‚ro du formulaire
;	d1.w : num‚ro de l'objet
; Sortie :	a1.l : pointeur sur l'objet

RETURN_OBJ_IN_FORM_OBJ_PTR:
	save.w d1
	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr RETURN_TREE_OBJ_PTR
	move.l (a0),a1
	load.w d0
	mulu #L_OBJECT,d0
	add.l d0,a1
	rts
		*------------------------*
; Entr‚e :	d0.w : num‚ro du formulaire
;	d1.w : num‚ro de l'objet avec ted info : G_TEXT ou G_BOXTEXT ou G_FTEXT ou G_FBOXTEXT
;		ou sans : G_STRING ... etc ...
; Sortie :	a1.l : pointeur sur le champs TEXT qqsoit l'obj
RETURN_TEXT_OBJ_IN_FORM_OBJ_PTR:	; d0=idx form, d1=idx obj txt => a1=ptr

	bsr.s RETURN_OBJ_IN_FORM_OBJ_PTR

	move ob_type(a1),d0
	and.w #$ff,d0
	cmp.w #G_TEXT,d0
	beq.s .theres_ted_info
	cmp.w #G_BOXTEXT,d0
	beq.s .theres_ted_info
	cmp.w #G_FTEXT,d0
	beq.s .theres_ted_info
	cmp.w #G_FBOXTEXT,d0
	beq.s .theres_ted_info

	move.l ob_spec(a1),a1
	rts

.theres_ted_info:
	move.l ob_spec(a1),a1
	move.l te_ptext(a1),a1	; A1 = pointeur du texte voulu
	rts

	endc		; ifd MDL_GEM

*--------------------------------------------------------------------------*
*-------------          Librairies ind‚pendantes          -----------------*
*--------------------------------------------------------------------------*

	ifd LIB_HEXA

AFFICH_HEXA:	; 'affichage hexa d'1 registre : d0=donn‚e d1=nb bits
	sub #4,d1
	move.l d0,d2	; d1=nb bits
	lsr.l d1,d2		; d0=donn‚e
	and.w #$f,d2
	cmp #$a,d2
	bge.s .lettr
	add.b #'0',d2
	bra.s .fin_lettr
.lettr:	add.b #'A'-$a,d2
.fin_lettr:	save.l d0-d2/a0
	move.w d2,-(sp)
	appel dos,2,4
	load.l d0-d2/a0
	tst d1
	bgt.s AFFICH_HEXA
	rts

STOCK_HEXA:	; sous routine transformation hexa-ASCII d'1 registre
	; d0=donn‚e d1=nb bits a1=destination sortie -1(a1)=0
	sub #4,d1
	move.l d0,d2
	lsr.l d1,d2
	and.w #$f,d2
	cmp #$a,d2
	bge.s .lettr
	add.b #'0',d2
	bra.s .fin_lettr
.lettr:	add.b #'A'-$a,d2
.fin_lettr:	move.b d2,(a1)+
	tst d1
	bgt.s STOCK_HEXA
	clr.b (a1)+
	rts

HEXA2VALUE:	; a0=chaine, d0.b=fin de chaine, d1.l=sortie, d7.w : erreur (-1) -1(a0)=d0 si d7=0
	clr.l d1
	moveq #1,d3		; signe
	cmp.b #'-',(a0)
	bne.s .pas_moins
	neg d3
	lea 1(a0),a0
.pas_moins:	cmp.b #'+',(a0)
	bne.s .pas_plus
	lea 1(a0),a0
.pas_plus:
.redo:	clr.l d2
	move.b (a0)+,d2
	cmp.b d2,d0
	beq.s .fin
	sub.b #'0',d2
	bmi.s .erreur
	cmp.b #9,d2
	ble.s .number
	sub.b #'A'-'0'-$a,d2
	bmi.s .erreur
	cmp.b #$f,d2
	bgt.s .erreur
.letter:
.number:	mulu.l #$10,d1		; 68030 only
	add.l d2,d1
	bra.s .redo
.fin:	tst d3
	bge.s .resultat_positif
	neg.l d1
.resultat_positif:
	clr d7
	rts
.erreur:	move.w #GWVA_ERROR_GENERIC,d7
	rts

	endc

*--------------------------------------------------------------------------*

	ifd LIB_DECI

STOCK_DECI:	; d0=valeur, a1 : destination o— stocker le chiffre en d‚cimal sign‚, sortie -1(a1)=0
	move.l #10000000*10,d2	; sur 8 d‚cimales max

	tst.l d0
	bge.s .positif
	move.b #'-',(a1)+
	neg.l d0
.positif:

.until_frac0_1:
	divul #10,d3:d2	; reste:fraction
	tst.l d2
	beq.s .que_zeros

	divul d2,d1:d0	; reste:fraction
	tst.b d0
	bne.s .diff_0
	move.l d1,d0
	bra.s .until_frac0_1
.que_zeros:	move.w #'0'*256,(a1)+
	rts

.until_frac0_2:
	divul #10,d3:d2	; reste:fraction
	tst.l d2
	beq.s .fin_digit

	divul d2,d1:d0	; reste:fraction
.diff_0:	add.b #'0',d0
	move.b d0,(a1)+
	move.l d1,d0	; on redivise le reste
	bra.s .until_frac0_2
.fin_digit:	clr.b (a1)+
	rts

DECI2VALUE:		; a0=chaine, d0.b=fin de chaine, d1.l=sortie, d7 = erreur, -1(a0)=d0 si d7=0
	clr.l d1
	moveq #1,d3		; signe
	cmp.b #'-',(a0)
	bne.s .pas_moins
	neg d3
	lea 1(a0),a0
.pas_moins:	cmp.b #'+',(a0)
	bne.s .pas_plus
	lea 1(a0),a0
.pas_plus:

.redo:	clr.l d2
	move.b (a0)+,d2
	cmp.b d2,d0
	beq.s .fin
	sub.b #'0',d2
	bmi.s .erreur
	cmp.b #9,d2
	bgt.s .erreur
	mulu.l #10,d1		; 68030 only
	add.l d2,d1
	bra.s .redo
.fin:	tst d3
	bge.s .resultat_positif
	neg.l d1
.resultat_positif:
	clr.w d7
	rts
.erreur:	move #GWVA_ERROR_GENERIC,d7
	rts

	endc

*--------------------------------------------------------------------------*

	ifd LIB_FILESELECTOR
	ifd MDL_GEM

;	lea texte,a0		; 35 chars max.
;	lea mask,a1			; 18 caracteres max
;	lea oldpathname,a2		; A:\TEMP\ ou #0.l
;	bsr FILE_SELECTOR
;	tst d0
;	beq.s annule
;	bmi.s erreur_gemdos
; 	-> a0 : nom du fichier
;	-> a1 : drive:path\ du fichier
;	-> a2 : drive:path\filename.ext

FILE_SELECTOR:	; In : a0=txt, a1=mask, a2=old pathname, Out:d0, a0=name ,a1=path, a2=pathname

	ifd MDL_WIND_BITMAP
	save.l a0-a2
	bsr GWVA_WIND_OBJ_PRG_RETURN_TOP_WINDOW
	tst d7
	bmi.s .the_top_windows_is_not_mine

	bsr GWVA_WBITM_OBJ_PRG_RESET_DESK_PALETTE
.the_top_windows_is_not_mine:
	load.l a0-a2
	endc

	cmp.l #0,a2
	bne.s .old_path_given

	save.l a0-a1

	DGETDRV
	add.b #'A',d0
	lea GWVA_FSEL_DISK_PATH,a2
	move.b d0,(a2)+
	move.b #':',(a2)+	; A: ou B: ...
	save.l a2
	DGETPATH #0,(a2)
	load.l a2
.trouv_0:	tst.b (a2)+
	bne.s .trouv_0	; on rajoute \ … la fin
	move.w #'\'*256,-1(a2)

	load.l a0/a1

	COPY_STRING_0 a1,a2
	bra.s .call_fsel

.old_path_given:
	lea GWVA_FSEL_DISK_PATH,a3
	COPY_STRING_0 a2,a3
.find_a:	cmp.b #'\',-(a3)
	bne.s .find_a
	lea 1(a3),a3
	save.l a3
	lea GWVA_FSEL_FILE_SELECTOR_PTR_NAME,a4
	COPY_STRING_0 a3,a4
	load.l a3
	COPY_STRING_0 a1,a3

.call_fsel:	fsel_exinput #GWVA_FSEL_DISK_PATH,#GWVA_FSEL_FILE_SELECTOR_PTR_NAME,a0

	tst d0
	beq .problem
	move.w int_out+2,d0	; 'ANNULE','CONFIRME'

	lea GWVA_FSEL_DISK_PATH,a0
.pas0:	tst.b (a0)+
	bne.s .pas0
.pas_trouv_d:
	cmpi.b #'\',-(a0)
	beq.s .found_slash
	cmpi.b #':',(a0)
	bne.s .pas_trouv_d
	addq.l #1,a0
	move.b #'\',(a0)		; root
.found_slash:clr.b 1(a0)		; chemin fini par \0

	lea GWVA_FSEL_DISK_PATH,a0
	cmpi.b #':',1(a0)
	bne.s .pas_driv
	clr d1
	move.b (a0),d1
	subi.b #'A',d1
	save.l d0/a0
	DSETDRV d1
	load.l d0/a0
	addq.l #2,a0

.pas_driv:	save.w d0
	DSETPATH (a0)
	move d0,d1
	load.w d0
	tst d1
	bne.s .problem

	lea GWVA_FSEL_FILE_SELECTOR_PTR_NAME,a0
	save.w d0

	lea GWVA_FSEL_DISK_PATH,a1
	lea GWVA_FSEL_FILE_PATHNAME,a2
	clr.b d0
	COPY_STRING a1,a2
	lea -1(a2),a2
	COPY_STRING a0,a2

	load.w d0

	lea GWVA_FSEL_FILE_SELECTOR_PTR_NAME,a0
	lea GWVA_FSEL_DISK_PATH,a1
	lea GWVA_FSEL_FILE_PATHNAME,a2

	bra.s .fin_fsel

.problem:	move d1,d0

.fin_fsel:
	ifd MDL_WIND_BITMAP
	save.l d0/a0-a2
	bsr GWVA_WBITM_OBJ_PRG_SET_RIGHT_PALETTE
	load.l d0/a0-a2
	endc

	rts

 BSS
GWVA_FSEL_DISK_PATH:		ds.b GWVA_MAX_PATH_LENGTH
GWVA_FSEL_FILE_PATHNAME:	ds.b GWVA_MAX_PATH_LENGTH
GWVA_FSEL_FILE_SELECTOR_PTR_NAME:	ds.b 8+1+3+1	; fileselect filename.
 even
 TEXT
 	endc
	endc	; ifd ...

*--------------------------------------------------------------------------*

	ifd LIB_PALETTE

SAVE_PALETTES:
	VSYNC
	lea palette256,a0
	lea old_palette256,a1
	move #256-1,d0
.cop_p:	move.l (a0)+,(a1)+
	dbf d0,.cop_p
	lea palette,a0
	lea old_palette16,a1
	move #16-1,d0
.cop_p1:	move.w (a0)+,(a1)+
	dbf d0,.cop_p1
	rts
 BSS
old_palette256:	ds.l 256
old_palette16:	ds.w 16
 TEXT

RESTORE_PALETTES:
	VSYNC
	lea old_palette256,a0
	lea palette256,a1
	move #256-1,d0
.res_p:	move.l (a0)+,(a1)+
	dbf d0,.res_p
	lea old_palette16,a0
	lea palette,a1
	move #16-1,d0
.res_p1:	move.w (a0)+,(a1)+
	dbf d0,.res_p1
	rts

	endc

*--------------------------------------------------------------------------*

	ifd LIB_GET_FLENGTH

GET_FILE_LENGTH:	; a0 = filename	retour d0.l (<0 si non trouv‚)
	save.l a0
	FGETDTA
	save.l d0
	FSETDTA GWVA_APP_OBJ_DTA
	load.l d0
	load.l a0
	save.l d0
	FSFIRST #$23,(a0)
	load.l a0
	save.w d0
	FSETDTA (a0)
	load.w d0
	ext.l d0
	bmi.s .erreur
	move.l GWVA_APP_OBJ_DTA+26,d0
.erreur:	rts

	endc

*--------------------------------------------------------------------------*

	ifd LIB_LOAD_FILE_IN_MEM

 ifnd LIB_GET_FLENGTH
  fail	; Vous avez besoin de la librairie LIB_GET_FLENGTH
  end
 endc


LOAD_FILE_IN_MEM:	; a0 : filename,d0=mxallox-mode	retour a0=ptr,d0=length (d0<=0 erreur)
	save.w d0
	save.l a0
	bsr.s GET_FILE_LENGTH
	load.l a0
	load.w d1
	tst.l d0
	ble.s .error_name_file
	save.l d0/a0
	MXALLOC d1,d0
	load.l d1/a0	; d1=longeur a0=ptr nom
	tst.l d0
	ble.s .error_allocation_mem
	save.l d0/d1	: d0=buffer d1=longeur
	FILE_OPEN read,(a0),d7
	load.l d0/d1
	tst d7
	bmi.s .error_open_file
	save.l d0/d1
	FREAD d0,d1,d7
	save.l d0
	FCLOSE d7
	load.l d2
	load.l d0/d1
	cmp.l d2,d1
	bne.s .error_read_file
	move.l d0,a0
	move.l d1,d0
.error_name_file:
	rts

.error_allocation_mem:
	move.l #GWVA_ERROR_MALLOC,d0
	rts
.error_open_file:
	MFREE d0
	move.w d7,d0
	ext.l d0
	rts
.error_read_file:
	MFREE d0
	move.l #GWVA_ERROR_READ,d0
	rts
	endc

*--------------------------------------------------------------------------*

	ifd LIB_RS232

RS232_SEND_STRING_WITH_TIMEOUT:	; a0=buffer,d0.l=length,d1.w=port,d2.l=timeout in 1/200 s

	tst.l d0
	ble .nothing_to_send

	clr.l GWVA_OLD_200HZ_COUNTER

	move d1,d3
	cmp.w #3,d1
	bne.s .paspatch
	moveq #4,d3
.paspatch:

.send_next_bytes:

	save.l d0-d3/a0
	move d3,-(sp)	; ikbd <-> midi
	appel bios,8,4
	tst d0
	bne.s .buffempty

	bsr GWVA_GET_200HZ_DELAY_SINCE_LAST_CALL
	move.l d0,d4
	load.l d0-d3/a0
	cmp.l d2,d4
	blt.s .send_next_bytes

	moveq #GWVA_ERROR_GENERIC,d7
	rts

.buffempty:	load.l d0-d3/a0

	move.b (a0)+,d4
	subq.l #1,d0
	bmi.s .fini

	save.l d0-d3/a0
	move.w d4,-(sp)
	move.w d1,-(sp)
	appel bios,3,6
	load.l d0-d3/a0

	bra.s .send_next_bytes

.nothing_to_send:
.fini:
	clr d7
	rts

RS232_SEND_STRING_WITHOUT_CONTROL:	; a0=buffer,d0.l=length,d1.w=port

	move.b (a0)+,d4
	subq.l #1,d0
	bmi.s .fini

	save.l d0-d1/a0
	move.w d4,-(sp)
	move.w d1,-(sp)
	appel bios,3,6
	load.l d0-d1/a0

	bra.s RS232_SEND_STRING_WITHOUT_CONTROL
.fini:
	rts

RS232_TEST_IF_CHAR_PRESENT:	; d0.w=port sortie d7=-1 : non
	move.w d0,-(sp)
	appel bios,1,4	; -1:1 char present
	moveq #-1,d7
	sub d0,d7
	rts

RS232_GET_AVAILABLE_CHARS:	; a0=buffer,d0.l=max store length,d1.w=port =>d0.l=nb captur‚s
	clr.l d2

.get_all:	subq.l #1,d0
	bmi.s .fin_capture2

	save.l d0-d2/a0
	move d1,-(sp)
	appel bios,1,4		; bconstat
	tst d0
	beq.s .fin_capture1

	move 4+2(sp),-(sp)		; ruse : ptr d0 d1 d2 a0
	appel bios,2,4		; bconin
	move d0,d3
	load.l d0-d2/a0

	move.b d3,(a0)+
	addq.l #1,d2
	bra.s .get_all

.fin_capture1:
	load.l d0-d2/a0
.fin_capture2:
	move.l d2,d0
	rts
	endc

*--------------------------------------------------------------------------*

	ifd LIB_TIME_DATE

 ifnd LIB_DECI
  fail	; Vous avez besoin de la librairie LIB_DECI
  end
 endc

GWVA_GET_FORMATED_DATE:		; a1=ptr destination : "29/06/1995"

	save.l a1
	appel dos,42,2
	load.l a1
	move.l a1,a0

	save.l d0/a0
	and.l #%11111,d0		; date
	bsr STOCK_DECI
	load.l d0/a0
	lea -1(a1),a1
	add #1,a0
	cmp.l a0,a1
	bne.s .2digits
	move.b -1(a0),(a0)
	move.b #'0',-1(a0)
	lea 1(a1),a1
.2digits:	move.b #'/',(a1)+
	lea 2(a0),a0
	save.l d0/a0
	and.l #%111100000,d0		; month
	lsr.l #5,d0
	bsr STOCK_DECI
	load.l d0/a0
	lea -1(a1),a1
	add #1,a0
	cmp.l a0,a1
	bne.s .2digits2
	move.b -1(a0),(a0)
	move.b #'0',-1(a0)
	lea 1(a1),a1
.2digits2:	move.b #'/',(a1)+
	lea 2(a0),a0
	and.l #%1111111000000000,d0	; year
	lsr.l #8,d0
	lsr.l #1,d0
	add.l #1980,d0
	bsr STOCK_DECI
	rts

GWVA_GET_FORMATED_TIME:		; a1=ptr destination : "19:20:00"
	save.l a1
	appel dos,44,2
	load.l a1
	move.l a1,a0

	save.l d0/a0
	and.l #%1111100000000000,d0	; hour
	lsr.l #8,d0
	lsr.l #3,d0
	bsr STOCK_DECI
	load.l d0/a0
	lea -1(a1),a1
	add #1,a0
	cmp.l a0,a1
	bne.s .2digits
	move.b -1(a0),(a0)
	move.b #'0',-1(a0)
	lea 1(a1),a1
.2digits:	move.b #':',(a1)+
	lea 2(a0),a0

	save.l d0/a0
	and.l #%11111100000,d0		; minutes
	lsr.l #5,d0
	bsr STOCK_DECI
	load.l d0/a0
	lea -1(a1),a1
	add #1,a0
	cmp.l a0,a1
	bne.s .2digits2
	move.b -1(a0),(a0)
	move.b #'0',-1(a0)
	lea 1(a1),a1
.2digits2:	move.b #':',(a1)+
	lea 2(a0),a0

	save.l d0/a0
	and.l #%11111,d0		; secondes
	lsl.l #1,d0
	bsr STOCK_DECI
	load.l d0/a0
	lea -1(a1),a1
	add #1,a0
	cmp.l a0,a1
	bne.s .2digits3
	move.b -1(a0),(a0)
	move.b #'0',-1(a0)
	lea 1(a1),a1
.2digits3:	lea 1(a1),a1		; pour pointer aprŠs le 0
	rts

	endc

*--------------------------------------------------------------------------*

	ifd LIB_200HZ

GWVA_GET_200HZ_COUNTER:		; … executer en superviseur (SUPEXEC)
	move.l cpt_200,GWVA_CUR_200HZ_COUNTER
	rts

GWVA_GET_200HZ_DELAY_SINCE_LAST_CALL:	; faire clr.l GWVA_OLD_200HZ_COUNTER avant 1er appel => retour d0.l
	SUPEXEC GWVA_GET_200HZ_COUNTER
	tst.l GWVA_OLD_200HZ_COUNTER
	bne.s .compare
	move.l GWVA_CUR_200HZ_COUNTER,GWVA_OLD_200HZ_COUNTER
	clr.l d0
	rts

.compare:	move.l GWVA_OLD_200HZ_COUNTER,d0
	sub.l GWVA_CUR_200HZ_COUNTER,d0
	rts

 BSS
GWVA_OLD_200HZ_COUNTER:		ds.l 1
GWVA_CUR_200HZ_COUNTER:		ds.l 1
 TEXT
	endc

*--------------------------------------------------------------------------*
