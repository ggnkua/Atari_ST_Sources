***************************************************************************
* Module pour les programmes multi-formulaires
***************************************************************************

;--------------------------------------------------------------------------
; GWVA_WFORM_OBJ_PRG_SAVE_FORM : Sauvegarde param‚trable d'un formulaire
;
; Entr‚e :	d0.w = num‚ro de l'arbre
;	d1.w = param‚trage de la sauvegarde
;		= bit 0 : sauve l'‚tat des objets et le caractŠre des BOXCHAR
;		= bit 1 : sauve les TEDINFO
;		= bit 2 : sauve les textes non ‚ditables sauf le caractŠre des icones
;		= bit 3 : sauve les textes editables (texte+mise en forme+champ de saisie)
;		= bit 4 : sauve les BITBLK
;		= bit 5 : sauve les ICONBLK
;		= bit 6 : sauve les CICONBLK
;		= bit 7 : sauve les APPLBLK
;	a0.l = 0 (MALLOC automatique) ou pointeur sur un pr‚c‚dent champ de sauvegarde
; Sortie :	a0.l = pointeur sur le champ de sauvegarde
;	d7.w = code d'erreur ou 0 si non

GWVA_WFORM_OBJ_PRG_SAVE_FORM:
	tst d1
	beq .pas_de_parametres

	save.w d0
	save.w d1
	save.l a0
	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr RETURN_TREE_OBJ_PTR
	load.l a0
	load.w d1
	load.w d2

	tst.w d0
	beq.s .pas_de_tree

	cmp.l #0,a0
	beq.s .faire_un_malloc

	cmp.w (a0),d1
	bne.s .pas_les_memes_parametres

	move.l 2(a0),d2		; taille malloc

	bra.s .deja_un_malloc

.faire_un_malloc:
	save.w d1

	move d1,d3			; parametre

	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0	; adresse de base de l'arbre
	move.l #.calcul_taille_objet,a1	; routine … executer … chaque objet
	move.l a0,a2		; adresse de l'objet courant
	clr.w d0			; num‚ro courant
	moveq #-1,d1		; num‚ro du p‚re du root
	clr.l d2			; taille en octet pris par l'arbre
	bsr GWVA_WFORM_OBJ_PRG_RECURS_TREE

	add.l #2+4,d2			; +1.w pour le param‚trage +1.l pour la taille
	save.l d2
	MXALLOC #RAM_TT_ST,d2
	load.l d2

	load.w d1

	tst.l d0
	ble.s .pas_de_memoire

	move.l d0,a0
.deja_un_malloc:

	save.l a0

	move.l a0,a3
	move.w d1,(a3)+		; paramŠtres
	move.l d2,(a3)+		; taille du malloc

	move.w d1,d3

	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0	; adresse de base de l'arbre
	move.l a0,a2		; adresse de l'objet courant
	move.l #.sauve_objet,a1		; routine … executer … chaque objet
	clr.w d0			; num‚ro courant
	moveq #-1,d1		; num‚ro du p‚re du root
	bsr GWVA_WFORM_OBJ_PRG_RECURS_TREE

	load.l a0

	clr.w d7
	rts

.pas_les_memes_parametres:
.pas_de_tree:
.pas_de_parametres:
	move.w #GWVA_ERROR_GENERIC,d7
	rts
.pas_de_memoire:
	move.w #GWVA_ERROR_MALLOC,d7
	rts

; Calcul la taille de l'objet
; d2.l taille totale
; d3.w paramŠtres
.calcul_taille_objet:
	btst #0,d3
	beq.s .pas_objet_de_base

	add.l #L_OBJECT,d2	; + moi
.pas_objet_de_base:

	btst #1,d3
	beq.s .pas_TEDINFO

	moveq #L_TEDINFO,d4
	cmp.w #G_TEXT,ob_type(a2)
	beq.s .taille_text
	cmp.w #G_BOXTEXT,ob_type(a2)
	beq.s .taille_text
	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .taille_text
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .pas_TEDINFO
.taille_text:
	add.l d4,d2
.pas_TEDINFO:

	btst #2,d3
	beq.s .pas_texte_normal

	cmp.w #G_TEXT,ob_type(a2)
	beq.s .taille_texte_normal_tedinfo
	cmp.w #G_BOXTEXT,ob_type(a2)
	bne.s .pas_texte_normal_text
.taille_texte_normal_tedinfo:
	move.w ([a2,ob_spec],te_txtlen),d4
	ext.l d4
	add.l d4,d2
.pas_texte_normal_text:

	cmp.w #G_BUTTON,ob_type(a2)
	beq.s .taille_texte_normal_string
	cmp.w #G_TITLE,ob_type(a2)
	beq.s .taille_texte_normal_string
	cmp.w #G_STRING,ob_type(a2)
	bne.s .pas_taille_texte_normal_string
.taille_texte_normal_string:
	move.l ob_spec(a2),a0
	save.l d3
	bsr GWVA_COUNT_BYTES_0
	add.l #1,d0
	load.l d3
	add.l d0,d2
.pas_taille_texte_normal_string:

	cmp.w #G_BOXCHAR,ob_type(a2)
	bne.s .pas_texte_normal_boxchar
	add.l #1,d2
.pas_texte_normal_boxchar:
.pas_texte_normal:

	btst #3,d3
	beq.s .pas_texte_editable

	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .taille_texte_editable_tedinfo
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .pas_texte_editable_text
.taille_texte_editable_tedinfo:
	move.w ([a2,ob_spec],te_txtlen),d4
	ext.l d4
	add.l d4,d2
	move.w ([a2,ob_spec],te_tmplen),d4
	ext.l d4
	add.l d4,d2
	add.l d4,d2
.pas_texte_editable_text:
.pas_texte_editable:

	btst #4,d3
	beq.s .pas_BITBLK

	moveq #L_BITBLK,d4
	cmp.w #G_IMAGE,ob_type(a2)
	bne.s .pas_image
	add.l d4,d2
.pas_image:
.pas_BITBLK:

	btst #5,d3
	beq.s .pas_ICONBLK

	moveq #L_ICONBLK,d4
	cmp.w #G_ICON,ob_type(a2)
	bne.s .pas_icon
	add.l d4,d2
.pas_icon:
.pas_ICONBLK:

	btst #6,d3
	beq.s .pas_CICONBLK

	moveq #L_CICONBLK,d4
	cmp.w #G_CICON,ob_type(a2)
	bne.s .pas_cicon
	add.l d4,d2
.pas_cicon:
.pas_CICONBLK:

	btst #7,d3
	beq.s .pas_APPLBLK

	moveq #L_APPLBLK,d4
	cmp.w #G_PROGDEF,ob_type(a2)
	bne.s .pas_progdef
	add.l d4,d2
.pas_progdef:
.pas_APPLBLK:

	rts

; Sauvegarde d'un objet : parametre dans d0.w
.sauve_objet:
	btst #0,d3
	beq.s .pas_sauve_objet_de_base

	move.l a2,a4
	move.w #L_OBJECT/2-1,d4
.recop_obj:	move.w (a4)+,(a3)+
	dbf d4,.recop_obj

.pas_sauve_objet_de_base:

	btst #1,d3
	beq.s .pas_sauve_TEDINFO

	cmp.w #G_TEXT,ob_type(a2)
	beq.s .sauve_TEDINFO
	cmp.w #G_BOXTEXT,ob_type(a2)
	beq.s .sauve_TEDINFO
	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .sauve_TEDINFO
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .pas_sauve_TEDINFO
.sauve_TEDINFO:
	move.l ob_spec(a2),a4
	move.w #L_TEDINFO/2-1,d4
.recop_tedinfo:
	move.w (a4)+,(a3)+
	dbf d4,.recop_tedinfo
.pas_sauve_TEDINFO:

	btst #2,d3
	beq.s .pas_sauve_texte_normal

	cmp.w #G_TEXT,ob_type(a2)
	beq.s .sauve_texte_normal_tedinfo
	cmp.w #G_BOXTEXT,ob_type(a2)
	bne.s .pas_sauve_texte_normal_tedinfo
.sauve_texte_normal_tedinfo:
	move.l ob_spec(a2),a4
	move.w te_txtlen(a4),d4
	move.l te_ptext(a4),a4
	sub.w #1,d4
	bmi.s .pas_sauve_texte_normal_tedinfo
.recop_texte_normal_tedinfo:
	move.b (a4)+,(a3)+
	dbf d4,.recop_texte_normal_tedinfo
.pas_sauve_texte_normal_tedinfo

	cmp.w #G_BUTTON,ob_type(a2)
	beq.s .sauve_texte_normal_string
	cmp.w #G_TITLE,ob_type(a2)
	beq.s .sauve_texte_normal_string
	cmp.w #G_STRING,ob_type(a2)
	bne.s .pas_sauve_texte_normal_string
.sauve_texte_normal_string:
	move.l ob_spec(a2),a4
	COPY_STRING_0 a4,a3
.pas_sauve_texte_normal_string:

	cmp.w #G_BOXCHAR,ob_type(a2)
	bne.s .pas_sauve_texte_normal_boxchar
	move.b ob_spec(a2),(a3)+
.pas_sauve_texte_normal_boxchar:
.pas_sauve_texte_normal:

	btst #3,d3
	beq.s .pas_sauve_texte_editable

	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .sauve_texte_editable_tedinfo
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .pas_sauve_texte_editable
.sauve_texte_editable_tedinfo:
	move.l ob_spec(a2),a4
	move.w te_txtlen(a4),d4
	move.l te_ptext(a4),a4
	sub.w #1,d4
	bmi.s .pas_sauve_texte_editable_tedinfo_txt
.recop_texte_editable_tedinfo_txt:
	move.b (a4)+,(a3)+
	dbf d4,.recop_texte_editable_tedinfo_txt
.pas_sauve_texte_editable_tedinfo_txt:
	move.l ob_spec(a2),a4
	move.w te_tmplen(a4),d4
	move.l te_pvalid(a4),a5
	move.l te_ptmplt(a4),a4
	sub.w #1,d4
	bmi.s .pas_sauve_texte_editable_tedinfo_tmplt_valid
.recop_texte_editable_tedinfo_tmplt_valid:
	move.b (a4)+,(a3)+
	move.b (a5)+,(a3)+
	dbf d4,.recop_texte_editable_tedinfo_tmplt_valid
.pas_sauve_texte_editable_tedinfo_tmplt_valid
.pas_sauve_texte_editable:

	btst #4,d3
	beq.s .pas_sauve_bitblk

	cmp.w #G_IMAGE,ob_type(a2)
	bne.s .pas_sauve_bitblk
	move.l ob_spec(a2),a4
	move.w #L_BITBLK/2-1,d4
.recop_bitblk:
	move.w (a4)+,(a3)+
	dbf d4,.recop_bitblk
.pas_sauve_bitblk:

	btst #5,d3
	beq.s .pas_sauve_iconblk

	cmp.w #G_ICON,ob_type(a2)
	bne.s .pas_sauve_iconblk
	moveq #L_ICONBLK/2-1,d4
.recop_iconblk:
	move.w (a4)+,(a3)+
	dbf d4,.recop_iconblk
.pas_sauve_iconblk:

	btst #6,d3
	beq.s .pas_sauve_ciconblk

	cmp.w #G_CICON,ob_type(a2)
	bne.s .pas_sauve_ciconblk
	moveq #L_CICONBLK/2-1,d4
.recop_ciconblk:
	move.w (a4)+,(a3)+
	dbf d4,.recop_ciconblk
.pas_sauve_ciconblk:

	btst #7,d3
	beq.s .pas_sauve_applblk

	cmp.w #G_PROGDEF,ob_type(a2)
	bne.s .pas_sauve_applblk
	moveq #L_APPLBLK/2-1,d4
.recop_applblk:
	move.w (a4)+,(a3)+
	dbf d4,.recop_applblk
.pas_sauve_applblk:

	rts

;--------------------------------------------------------------------------
; GWVA_WFORM_OBJ_PRG_RESTORE_FORM : Restauration d'un formulaire pr‚c‚dement sauvegard‚
;
; Entr‚e :	d0.w = num‚ro de l'arbre
;	d1.w = param‚trage (voir sauvegarde)
;	a0.l = pointeur sur le champ de sauvegarde
; Sortie :	d7.w = code d'erreur ou 0 si non

GWVA_WFORM_OBJ_PRG_RESTORE_FORM:
	tst.w d1
	beq.s .pas_de_restoration

	save.l a0/d1
	lea GWVA_APP_OBJ_TMP_ADD_TREE,a0
	bsr RETURN_TREE_OBJ_PTR
	load.l a0/d1

	tst.w d0
	beq .pas_de_tree

	move.w (a0),d0		; paramŠtres de sauvegarde
	or.w d1,d0
	cmp.w (a0),d0
	bne.s .restoration_impossible

	move.l a0,a3
	move.w d1,d3		; d3 paramŠtres de restoration
	move.w (a3)+,d2		; d2 paramŠtres de sauvegarde
	lea 4(a3),a3

	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0	; adresse de base de l'arbre
	move.l #.restore_objet,a1	; routine … executer … chaque objet
	move.l a0,a2
	clr.w d0			; num‚ro courant
	moveq #-1,d1		; num‚ro du p‚re du root
	bsr GWVA_WFORM_OBJ_PRG_RECURS_TREE

	clr.w d7
	rts

.restoration_impossible:
.pas_de_tree:
.pas_de_restoration:
	move.w #GWVA_ERROR_GENERIC,d7
	rts

; Restoration d'un objet : paramŠtre de restoration dans d3.w,paramŠtre de sauvegarde dans d2.w , buffer dans a3.l
.restore_objet:
	btst #0,d2		; l'objet de base a-t-il ‚t‚ sauv‚ ?
	beq.s .pas_sauve_objet_de_base

	btst #0,d3		; l'objet de base doit-il ˆtre restor‚
	beq.s .pas_restore_objet_de_base

	move.l a2,a4
	move.l a3,a0
	move.w #L_OBJECT/2-1,d4
.recop_obj:	move.w (a0)+,(a4)+
	dbf d4,.recop_obj
.pas_restore_objet_de_base:
	lea L_OBJECT(a3),a3
.pas_sauve_objet_de_base:

	btst #1,d2		; la structure TEDINFO a-t-elle ‚t‚ sauv‚e
	beq.s .pas_sauve_TEDINFO

	btst #1,d3		; doit-elle ˆtre restor‚e
	beq.s .pas_restore_TEDINFO

	cmp.w #G_TEXT,ob_type(a2)
	beq.s .restore_TEDINFO
	cmp.w #G_BOXTEXT,ob_type(a2)
	beq.s .restore_TEDINFO
	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .restore_TEDINFO
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .pas_restore_TEDINFO
.restore_TEDINFO:
	move.l ob_spec(a2),a4
	move.w #L_TEDINFO/2-1,d4
.recop_tedinfo:
	move.w (a3)+,(a4)+
	dbf d4,.recop_tedinfo
	bra.s .pas_sauve_TEDINFO
;#
.pas_restore_TEDINFO:
	cmp.w #G_TEXT,ob_type(a2)
	beq.s .prestore_TEDINFO
	cmp.w #G_BOXTEXT,ob_type(a2)
	beq.s .prestore_TEDINFO
	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .prestore_TEDINFO
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .ppas_restore_TEDINFO
.prestore_TEDINFO:
	lea L_TEDINFO(a3),a3
.ppas_restore_TEDINFO:

.pas_sauve_TEDINFO:

	btst #2,d2		; les textes normaux ont-ils ‚t‚ sauv‚s
	beq .pas_sauve_texte_normal

	btst #2,d3		; doivent-ils ˆtre restor‚s
	beq.s .pas_restore_texte_normal

	cmp.w #G_TEXT,ob_type(a2)
	beq.s .restore_texte_normal_tedinfo
	cmp.w #G_BOXTEXT,ob_type(a2)
	bne.s .pas_restore_texte_normal_tedinfo
.restore_texte_normal_tedinfo:
	move.l ob_spec(a2),a4
	move.w te_txtlen(a4),d4
	move.l te_ptext(a4),a4
	sub.w #1,d4
	bmi.s .pas_restore_texte_normal_tedinfo
.recop_texte_normal_tedinfo:
	move.b (a3)+,(a4)+
	dbf d4,.recop_texte_normal_tedinfo
.pas_restore_texte_normal_tedinfo

	cmp.w #G_BUTTON,ob_type(a2)
	beq.s .restore_texte_normal_string
	cmp.w #G_TITLE,ob_type(a2)
	beq.s .restore_texte_normal_string
	cmp.w #G_STRING,ob_type(a2)
	bne.s .pas_restore_texte_normal_string
.restore_texte_normal_string:
	move.l ob_spec(a2),a4
	COPY_STRING_0 a3,a4
.pas_restore_texte_normal_string:

	cmp.w #G_BOXCHAR,ob_type(a2)
	bne.s .pas_restore_texte_normal_boxchar
	move.b (a3)+,ob_spec(a2)
.pas_restore_texte_normal_boxchar:
	bra.s .pas_sauve_texte_normal
;#
.pas_restore_texte_normal:
	cmp.w #G_TEXT,ob_type(a2)
	beq.s .prestore_texte_normal_tedinfo
	cmp.w #G_BOXTEXT,ob_type(a2)
	bne.s .ppas_restore_texte_normal_tedinfo
.prestore_texte_normal_tedinfo:
	move.l ob_spec(a2),a4
	move.w te_txtlen(a4),d4
	ext.l d4
	add.l d4,a3 
.ppas_restore_texte_normal_tedinfo

	cmp.w #G_BUTTON,ob_type(a2)
	beq.s .prestore_texte_normal_string
	cmp.w #G_TITLE,ob_type(a2)
	beq.s .prestore_texte_normal_string
	cmp.w #G_STRING,ob_type(a2)
	bne.s .ppas_restore_texte_normal_string
.prestore_texte_normal_string:
	move.l a3,a0
	save.w d3
	bsr GWVA_COUNT_BYTES_0
	add.l #1,d0
	load.w d3
	add.l d0,a3
.ppas_restore_texte_normal_string:

	cmp.w #G_BOXCHAR,ob_type(a2)
	bne.s .ppas_restore_texte_normal_boxchar
	add.l #1,a3
.ppas_restore_texte_normal_boxchar:

.pas_sauve_texte_normal:

	btst #3,d2		; les textes ‚ditables ont-ils ‚t‚ sauv‚s
	beq.s .pas_sauve_texte_editable

	btst #3,d3		; doivent-ils ˆtre restor‚s
	beq.s .pas_restore_texte_editable

	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .restore_texte_editable_tedinfo
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .pas_restore_texte_editable
.restore_texte_editable_tedinfo:
	move.l ob_spec(a2),a4
	move.w te_txtlen(a4),d4
	move.l te_ptext(a4),a4
	sub.w #1,d4
	bmi.s .pas_restore_texte_editable_tedinfo_txt
.recop_texte_editable_tedinfo_txt:
	move.b (a3)+,(a4)+
	dbf d4,.recop_texte_editable_tedinfo_txt
.pas_restore_texte_editable_tedinfo_txt:
	move.l ob_spec(a2),a4
	move.w te_tmplen(a4),d4
	move.l te_pvalid(a4),a5
	move.l te_ptmplt(a4),a4
	sub.w #1,d4
	bmi.s .pas_restore_texte_editable_tedinfo_tmplt_valid
.recop_texte_editable_tedinfo_tmplt_valid:
	move.b (a3)+,(a4)+
	move.b (a3)+,(a5)+
	dbf d4,.recop_texte_editable_tedinfo_tmplt_valid
.pas_restore_texte_editable_tedinfo_tmplt_valid
	bra.s .pas_sauve_texte_editable
;#
.pas_restore_texte_editable:
	cmp.w #G_FTEXT,ob_type(a2)
	beq.s .prestore_texte_editable_tedinfo
	cmp.w #G_FBOXTEXT,ob_type(a2)
	bne.s .ppas_restore_texte_editable
.prestore_texte_editable_tedinfo:
	move.l ob_spec(a2),a4
	move.w te_txtlen(a4),d4
	ext.l d4
	add.l d4,a3
	move.w te_tmplen(a4),d4
	ext.l d4
	add.l d4,a3
	add.l d4,a3
.ppas_restore_texte_editable:

.pas_sauve_texte_editable:

	btst #4,d2		; les structures BITBLK ont-elles ‚t‚ sauv‚es
	beq.s .pas_sauve_bitblk

	btst #4,d3		; doivent-elles ˆtre restor‚es
	beq.s .pas_restore_bitblk

	cmp.w #G_IMAGE,ob_type(a2)
	bne.s .pas_restore_bitblk
	move.l ob_spec(a2),a4
	move.w #L_BITBLK/2-1,d4
.recop_bitblk:
	move.w (a3)+,(a4)+
	dbf d4,.recop_bitblk
	bra.s .pas_sauve_bitblk
;#
.pas_restore_bitblk:
	cmp.w #G_IMAGE,ob_type(a2)
	bne.s .ppas_restore_bitblk
	lea L_BITBLK(a3),a3
.ppas_restore_bitblk:

.pas_sauve_bitblk:

	btst #5,d2		; les structures ICONBLK ont-elles ‚t‚ sauv‚es
	beq.s .pas_sauve_iconblk

	btst #5,d3		; doivent-elles ˆtre restor‚es
	beq.s .pas_restore_iconblk

	cmp.w #G_ICON,ob_type(a2)
	bne.s .pas_restore_iconblk
	moveq #L_ICONBLK/2-1,d4
.recop_iconblk:
	move.w (a3)+,(a4)+
	dbf d4,.recop_iconblk
	bra.s .pas_sauve_iconblk
;#
.pas_restore_iconblk:
	cmp.w #G_ICON,ob_type(a2)
	bne.s .ppas_restore_iconblk
	lea L_ICONBLK(a3),a3
.ppas_restore_iconblk:

.pas_sauve_iconblk:

	btst #6,d2		; les structures CICONBLK ont-elles ‚t‚ sauv‚es
	beq.s .pas_sauve_ciconblk

	btst #6,d3		; doivent-elles ˆtre restor‚es
	beq.s .pas_restore_ciconblk

	cmp.w #G_CICON,ob_type(a2)
	bne.s .pas_restore_ciconblk
	moveq #L_CICONBLK/2-1,d4
.recop_ciconblk:
	move.w (a3)+,(a4)+
	dbf d4,.recop_ciconblk
	bra.s .pas_sauve_ciconblk
;#
.pas_restore_ciconblk:
	cmp.w #G_CICON,ob_type(a2)
	bne.s .ppas_restore_ciconblk
	lea L_CICONBLK(a3),a3
.ppas_restore_ciconblk:

.pas_sauve_ciconblk:

	btst #7,d2		; les structures APPLBLK ont-elles ‚t‚ sauv‚es
	beq.s .pas_sauve_applblk

	btst #7,d3		; doivent-elles ˆtre restor‚es
	beq.s .pas_restore_applblk

	cmp.w #G_PROGDEF,ob_type(a2)
	bne.s .pas_restore_applblk
	moveq #L_APPLBLK/2-1,d4
.recop_applblk:
	move.w (a3)+,(a4)+
	dbf d4,.recop_applblk
	bra.s .pas_sauve_applblk
;#
.pas_restore_applblk:
	cmp.w #G_PROGDEF,ob_type(a2)
	bne.s .ppas_restore_applblk
	lea L_APPLBLK(a3),a3
.ppas_restore_applblk:

.pas_sauve_applblk:
	rts

;--------------------------------------------------------------------------
; GWVA_WFORM_OBJ_PRG_COPY_SAVED_FORM : Copie d'une sauvegarde de formulaire
;
; Entr‚e :	a0.l = pointeur sur le champ de sauvegarde source
;	a1.l = 0 (cr‚ation de la copie - malloc) ou adresse d'un buffer de destination
; Sortie :	a0.l = pointeur de la sauvegarde de destination
;	d7.w = code d'erreur ou 0 si non

GWVA_WFORM_OBJ_PRG_COPY_SAVED_FORM:
	cmp.l #0,a1
	bne.s .pas_de_malloc

	save.l a0
	MXALLOC #RAM_TT_ST,2(a0)
	load.l a0

	tst.l d0
	ble.s .pas_de_memoire

	move.l d0,a1
	move.w (a0),(a1)
	move.l 2(a0),2(a1)
.pas_de_malloc:

	save.l a1

	move.l 2(a0),d0
	move.l d0,d1
	asr.l #2,d1
.recop_long:
	beq.s .pas_de_mot_long
	move.l (a0)+,(a1)+
	sub.l #1,d1
	bra.s .recop_long
.pas_de_mot_long:
	move.l d0,d1
	and.l #3,d1
	asr.w #1,d1
	beq.s .pas_de_mot
	move.w (a0)+,(a1)+
.pas_de_mot:
	move.l d0,d1
	and.l #1,d1
	beq.s .pas_de_byte
	move.b (a0)+,(a1)+
.pas_de_byte:

	load.l a0

	clr.w d7
	rts
.pas_recopie_possible:
	move.w #GWVA_ERROR_GENERIC,d7
	rts

.pas_de_memoire:
	move.w #GWVA_ERROR_MALLOC,d7
	rts
;--------------------------------------------------------------------------
; Parcour r‚cursif d'un arbre d'objet
;	move.l GWVA_APP_OBJ_TMP_ADD_TREE,a0	; adresse de base de l'arbre
;	move.l #.calcul_taille_objet,a1	; routine … executer … chaque objet
;	move.l a0,a2		; adresse de l'objet courant
;	clr.w d0			; num‚ro courant
;	moveq #-1,d1		; num‚ro du p‚re du root
GWVA_WFORM_OBJ_PRG_RECURS_TREE:
	link a6,#-(2+4)
	move.w d1,(a7)	; stock num‚ro du pŠre
.same_level:
	move.l a2,2(a7)	; et mon adresse

	save.l a0-a2/a6/d0-d1
	jsr (a1)
	load.l a0-a2/a6/d0-d1

	move ob_head(a2),d1	; ai-je un fils ?
	bpl.s .child_exist

.continue_brother_father:
	move ob_next(a2),d1	; ai-je une famille autre que mon pŠre
	move.w d1,d0

	cmp.w (a7),d1
	beq.s .back_2_father

	mulu #L_OBJECT,d1
	lea (a0,d1.l),a2
	bra.s .same_level

.child_exist:
	save.w d2
	move.w d1,d2
	mulu #L_OBJECT,d1
	lea (a0,d1.l),a2
	move.w d0,d1	; l'ancien pŠre c'est moi
	move.w d2,d0
	load.w d2
	bsr GWVA_WFORM_OBJ_PRG_RECURS_TREE
	move.l 2(a7),a2	; mon adresse

	bra.s .continue_brother_father

.back_2_father:
	unlk a6
	rts
