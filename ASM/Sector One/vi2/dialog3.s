* Installation d'une boŒte de dialogue de remplacement
* pour la s‚lection de r‚solutions dans le bureau
* Par Zerkman / Trisomic Development

** Version 1.01 :
; - PremiŠre version exploit‚e. Restent quelques bugs au sujet des redraws du fond de la
;   boŒte de dialogue.
; - Pas de possibilit‚ de s‚lection des seuils de scroll, du mode 'update INF'...
; - Affichages trŠs simplifi‚s. (genre pas de fr‚quences, pas de ceci, pas de cela...)
; - On ne pr‚s‚lectionne pas le mode dans lequel on se trouve.

** Version 1.02 :
; - Gestion correcte au passage d'un mode ‚tendu vers un mode "normal"
; - Gestion du nouveau format de cookie.
; - Rajout du caractŠre 'i' pour les modes entrelac‚s.
; - On active le mode "double ligne" du xbios si lignes >= 400

** Version 1.03 :
; - Gestion du tout nouveau VI 2.04 (fr‚quences Videl)
; - Relookage du panneau de s‚lection
; - Gestion de l'ascenseur am‚lior‚e
; - Affichage des fr‚quences d'affichage des modes
; - Correction d'un bug dans la gestion des erreurs
; - Correction d'un bug dans le passage en mode "Normal"
;   qui plantait sous TOS 4.04


NOMBRE_LIGNES	equ	13	; Nombre de lignes dans le s‚lecteur
ADR_TAB_ARBRE	equ	$a0f8	; Adresse du tableau d'arbres d'objets du bureau
ADR_RESO	equ	$a4ea	; Adresse o— l'on doit stocker la nouvelle r‚solution
ADR_XBIOS_RES	equ	$184c	; Adresse du mode Xbios actuel
MASQUE_DEFAUT	equ	$19f	;|(1<<VI_BIT)	; Masque de comparaison par d‚faut
DAT_VERSION	equ	$103	; Num‚ro de version du fichier DAT.
;DX3				; On utilise la carte DX-3
;VIRE_UPDATE			; Vire les wind_update
AUTO				; Assemblage dans le dossier AUTO.
id		equ	'vcnf'

	IFD	DX3
cook_id	equ	'VIDX'		;id de VI 2 pour DX3
	ELSE
cook_id	equ	'VI-2'		;id de VI 2 normal
	ENDC


	IFND	AUTO
	IFND	DX3
	output	d:\vi2_cnf.prg
	ELSE
	output	d:\vi2_dxcn.prg
	ENDC
	opt	o+,ow-,x+
	ELSE
	IFND	DX3
	output	c:\auto\vi2_cnf.prg
	ELSE
	output	c:\auto\vi2_dxcn.prg
	ENDC
	opt	o+,ow-,x-
	ENDC
	opt	brw,bdw

; Format du cookie :
ck_ver		rs.w	1	; Num‚ro de version du prog
ck_size		rs.w	1	; Taille de la structure du cookie
ck_state	rs.w	1	; tat actuel du programme
ck_flags	rs.w	1	; Flags de config du mode
ck_vmmask	rs.w	1	; Masque … appliquer pour comparer les modes vid‚o
ck_vmode	rs.w	1	; Mode Xbios correspondant au mode ‚tendu
ck_vwidth	rs.w	1	; largeur virtuelle en pixels
ck_vheight	rs.w	1	; hauteur virtuelle en lignes
ck_xthres	rs.w	1	; seuil horizontal de scroll en pixels
ck_ythres	rs.w	1	; seuil vertical de scroll en lignes

; A partir de l…, structure d'un mode sous ED_MODE
ck_mod_flags	rs.w	1	; Les flags du mode (bits 0-3:VCO, 4-6:Couleurs, 7-8:Fr‚quence)
ck_mod_npix	rs.w	1	; Suivent les mˆmes valeurs que dans ed_mode
ck_mod_xres	rs.w	1
ck_mod_xoff	rs.w	1
ck_mod_nlin	rs.w	1
ck_mod_yres	rs.w	1
ck_mod_yoff	rs.w	1
ck_mod_nom	rs.b	36

TAILLE_CK	rs.w	1
TAILLE_CK_MOD	equ	TAILLE_CK-ck_mod_flags

; D‚finition d'un mode vid‚o tel qu'il est en m‚moire pour le s‚lecteur
	RSRESET
mod_flags	rs.w	1
mod_npix	rs.w	1
mod_xres	rs.w	1
mod_xoff	rs.w	1
mod_nlin	rs.w	1
mod_yres	rs.w	1
mod_yoff	rs.w	1
mod_nom		rs.b	36
TAILLE_mod	rs.w	1

debut
	include	gem_equ.s
	include	gemmacro.i
	include	tos_030.s
	IFD	DX3
	include	vis_dx3.i
	ELSE
	include	vis.i
	ENDC

	section	text

	bra	depart

	dc.b	"XBRA"
	dc.l	id
anc_xbios
	dc.l	0
notre_xbios
	lea	8(sp),a0	; Pointeur de pile+6 dans a0
	btst.b	#5,(sp)		; Mode superviseur ?
	bne.s	.supfnd
	move.l	usp,a0		; User => usp dans a0
.supfnd
	cmp	#89,(a0)	; On cherche le type d'‚cran ?
	beq.s	xbios89
le_xbios
	jmp	([anc_xbios.w,pc])
xbios89
	move.l	ADR_TAB_ARBRE,a0
	move.l	$17*4(a0),a0	; Adresse de l'arbre d'objets du formulaire de config
	cmp.l	a0,a5		; On cherche si c'est le bureau qui appelle le xbios
	bne	le_xbios	; Sinon, circulez, y'a rien a voir

	bsr.s	recherche_cookie
	tst.l	d0		; VI 2 est pr‚sent ?
	beq	le_xbios	; Non, alors on ne fait rien
	move.l	d0,adresse_cookie
	move.l	#appel_formulaire,2(sp)
	rte

xb89shift
	clr	ck_vmode(a0)	; Pour dire que le mode n'est de toutes fa‡ons pas ‚tendu
	bra	le_xbios	; Par contre ‡a peut poser problŠme si le gars clique sur Annuler

recherche_cookie
	move.l	a2,-(sp)
	move.l	$5a0.w,a2	; Pointeur sur le cookie jar

cherche_cookie
	move.l	(a2)+,d0
	beq.s	rc_rts		; Cookie pas trouv‚ alors on ne fait rien
	cmp.l	#cook_id,d0
	beq.s	cookie_trouve
	addq.l	#4,a2		; On saute l'info du cookie qui ne nous int‚resse pas
	bra	cherche_cookie
cookie_trouve
	move.l	(a2),d0		; Adresse de la structure d'info de VI 2
rc_rts	move.l	(sp)+,a2
	rts

adresse_cookie	dc.l	0

charge_fichier
	clr	-(sp)		; Ouverture en lecture
	pea	nom_fichier_dat(pc)
	Gemdos	Fopen
	move	d0,d7		; Handle du fichier
	bmi	cf_pas_trouve

	pea	tampon_header(pc)
	pea	28.w
	move	d7,-(sp)
	Gemdos	Fread

	lea	tampon_header(pc),a0
	cmp.l	#"DATF",(a0)+
	bne	cf_erreur_format
	cmp.l	#"ILE"<<8,(a0)+
	bne	cf_erreur_format

	move	(a0)+,d0	; Num‚ro de version du fichier
	cmp	#DAT_VERSION,d0
	bne	cf_erreur_format

	lea	freqs_ms(pc),a1
	movem.w	(a0)+,d1-d2
	mulu	#100,d1		; Conversion des fr‚quences en Hz
	mulu	#100,d2		;
	movem.w	d1-d2,(a1)	; Installe les fr‚quences multisync au bon format
	move.l	(a0)+,4(a1)	; les fr‚quences verticales multisync
	move	(a0)+,d1	; les flags
	move	type_moniteur(pc),d0	; 0 mono, 1 RGB, 2 VGA
	cmp	#2,d0		; VGA ?
	bne.s	.pas_vga
	btst	#0,d1		; Multisync ? (et VGA, donc)
	bne.s	.mult
.pas_vga
	lea	freqs(pc),a1
	lsl	#3,d0		; *8 car c'est des ensembles de 4 mots de 2 octets
	add	d0,a1
.mult	move.l	a1,adr_freqs	; adresse des fr‚quences

	move	(a0)+,d6	; Nombre de modes … charger
	move	d6,d5
	mulu	#TAILLE_mod,d5	; Taille … r‚server

	IFND	DX3
	lea	table_freq(pc),a1
	moveq	#2,d0
bcl_videl_freq
	moveq	#0,d1
	move	(a0)+,d1	; Fr‚quence interne no.1
	mulu.l	#100000,d1	; Conversion en Hz.
	move.l	d1,(a1)+
	dbra	d0,bcl_videl_freq
	ENDC

	move.l	d5,-(sp)
	Gemdos	Malloc		; On r‚serve notre bloc
	move.l	d0,adr_bloc

	move.l	d0,-(sp)
	move.l	d5,-(sp)
	move	d7,-(sp)
	Gemdos	Fread

	move	d7,-(sp)
	Gemdos	Fclose

; Ici on trie les modes valables et les pas valables (en fct des fr‚quences)
	move	d6,d5		; Nombre de modes
	subq	#1,d5		; Pour le dbra
	move.l	adr_bloc(pc),a2	; Bloc source
	move.l	a2,a1		; Bloc destination
	IFD	DX3
	moveq	#1,d4		; Fr‚quence videl interdite en VGA (32 MHz)
	move	type_moniteur(pc),d0
	cmp	#2,d0		; On est en vga ?
	beq.s	trie_mode
	moveq	#3,d4		; Fr‚quence videl interdite en RGB (50 MHz)
	ENDC
trie_mode
	move	mod_flags(a2),d0
	move	d0,d1		; Les flags du mode vid‚o
	lsr	#7,d1
	and	#3,d1		; Valeur repr‚sentant la fr‚quence Videl
	IFD	DX3
	cmp	d4,d1		; C'est la valeur interdite ?
	beq	vire_mode	; Alors on va pas plus loin
	ENDC
	move.l	(table_freq,pc,d1.w*4),d1	; Fr‚quence Videl en Hz

	lsr	#2,d0
	and	#3,d0		; Mode horizontal
	moveq	#2,d2
	sub	d0,d2		; 2 - hmode
	move	mod_npix(a2),d0
	lsl	d2,d0		; npix << (2-hmode)

	divu	d0,d1		; Fr‚quence horizontale du mode
	moveq	#0,d0
	move	d1,d0

	moveq	#0,d1
	move.l	adr_freqs(pc),a3 ; Fr‚quences mini et maxi
	move	(a3)+,d1	; hmin
	cmp.l	d1,d0
	bmi	vire_mode	; hfreq < hmin
	move	(a3)+,d1	; hmax
	cmp.l	d1,d0
	bgt	vire_mode	; hfreq > hmax
	move.l	d0,d2
	lsl.l	#2,d2
	add.l	d0,d2
	add.l	d2,d2		; hfreq * 10
	divu	mod_nlin(a2),d2	; fr‚quence verticale * 10

	move	(a3)+,d1	; vmin * 10
	cmp	d1,d2
	bmi	vire_mode
	move	(a3)+,d1	; vmax * 10
	cmp	d1,d2
	bgt	vire_mode

; Ici, donc, le mode est OK, il a pass‚ tous les tests.
	move	d0,d3		; Hfreq
	moveq	#7-1,d1
	move.l	a2,a3
	move.l	a1,a0
copie_mode
	move	(a3)+,(a0)+
	dbra	d1,copie_mode

	moveq	#8,d1
	move	mod_xres(a2),d0
	bsr	itoa
	sub	d0,d1
	move.b	#"x",(a0)+
	move	mod_yres(a2),d0
	bsr	itoa
	sub	d0,d1
	move	mod_flags(a2),d0
	btst	#1,d0			; Mode entrelac‚ ?
	beq.s	pas_i
	move.b	#'i',(a0)+
	subq	#1,d1
pas_i
	tst	d1
	bmi.s	pas_esp
espaces_bcl
	move.b	#' ',(a0)+
	dbra	d1,espaces_bcl

pas_esp
	lsr	#4,d0
	and	#7,d0			; Mode de couleur
	move.l	(liste_couleurs.w,pc,d0.w*4),a3
	moveq	#4,d1
.bcl
	subq	#1,d1
	move.b	(a3)+,(a0)+
	bne.s	.bcl
	move.b	#'c',-1(a0)
	tst	d1
	bmi.s	zobi_lamouche
paf_lechien
	move.b	#' ',(a0)+
	dbra	d1,paf_lechien
zobi_lamouche
	move	d3,d0		; Fr‚quence horizontale
	bsr	itoa
	move.b	#'/',(a0)+
	move	d2,d1		; Fr‚quence verticale * 10
	divu	#10,d1
	move	d1,d0
	bsr	itoa
	move.b	#'.',(a0)+
	swap	d1
	move	d1,d0
	bsr	itoa

	lea	freq_txt(pc),a3
.bcl	move.b	(a3)+,(a0)+
	bne.s	.bcl

	add	#TAILLE_mod,a1
	bra.s	mode_suivant
vire_mode
	subq	#1,d6		; nombre de modes - 1
mode_suivant
	add	#TAILLE_mod,a2
	dbra	d5,trie_mode

	move	d6,nombre_modes

	moveq	#1,d0
	rts

table_freq
	dc.l	25000000,32000000,40000000,50000000

cf_pas_trouve
	form_alert #1,#pas_trouve_alert
	bra.s	cf_erreur
cf_erreur_format
	form_alert #1,#erreur_format_alert
cf_erreur
	moveq	#0,d0
	rts

; Ici on est au mˆme niveau que la routine du bureau
appel_formulaire
	movem.l	(sp)+,d4-d7/a5
	unlk	a6

	bsr	gestion_formulaire
	rts

; Variables locales:
	RSRESET
gf_x	rs.w	1
gf_y	rs.w	1
gf_w	rs.w	1
gf_h	rs.w	1
gf_xa	rs.w	1
gf_ya	rs.w	1
taille	rs.w	1

; Gestion d'un formulaire. Se termine dŠs qu'un objet EXIT est s‚lectionn‚.
; ParamŠtres:
; a0 : adresse du formulaire
; Retour:
; d0.w : no de l'objet cliqu‚.
gestion_boite
	movem.l	d5-d6/a5,-(sp)
	sub	#taille,sp

	move.l	a0,a5
	bsr	affiche_boite

gb_attente_clic
	form_do	a5,#0
	move	d0,d5
	smi	d6			; Si double clic (bit 15=1)
	bclr	#15,d5			; On ne tient pas compte des double clics
	objc_offset a5,#0
	move	int_out+2(pc),gf_xa(sp)
	move	int_out+4(pc),gf_ya(sp)

	move	d5,d0
	add	d0,d0
	add	d5,d0
	move	ob_flags(a5,d0.w*8),d0
	and	#EXIT,d0
	beq	gb_attente_clic

gb_fin
	objc_change a5,d5,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#NORMAL,#0

	bsr	efface_boite

	move	d5,d0
	add	#taille,sp
	movem.l	(sp)+,d5-d6/a5
	rts

; Affiche une boŒte de dialogue.
; a5 = adresse arbre.
; sp+4 = adresse d'une structure gf_xywh
affiche_boite
	form_center a5
	move	int_out+2(pc),gf_x+4(sp)
	move	int_out+4(pc),gf_y+4(sp)
	move	int_out+6(pc),gf_w+4(sp)
	move	int_out+8(pc),gf_h+4(sp)

	moveq	#FMD_START,d0
	form_dial d0,d0,d0,d0,d0,gf_x+4(sp),gf_y+4(sp),gf_w+4(sp),gf_h+4(sp)

	IFND	VIRE_UPDATE
	wind_update #BEG_UPDATE
	ENDC

	objc_draw a5,#0,#15,gf_x+4(sp),gf_y+4(sp),gf_w+4(sp),gf_h+4(sp)
	rts

; Efface une boŒte de dialogue.
; a5 = adresse arbre.
; sp+4 = adresse d'une structure gf_xywh
efface_boite
	IFND	VIRE_UPDATE
	wind_update #END_UPDATE
	ENDC
	moveq	#0,d0
	form_dial #FMD_FINISH,d0,d0,d0,d0,gf_x+4(sp),gf_y+4(sp),gf_w+4(sp),gf_h+4(sp)
	rts

; Routine principale de gestion du formulaire de s‚lection du mode vid‚o.
gestion_formulaire
	movem.l	d1-d7/a1-a6,-(sp)
	sub	#taille,sp
	bsr	rsc_reloc

	lea	rsc(pc),a5
	add	rsh_trindex(a5),a5	; Adresse des arbres d'objets
	move.l	select*4(a5),a5		; Adresse de l'arbre de config
	add	#5,vsp_button*ob_size+ob_y(a5)
	sub	#10,vsp_button*ob_size+ob_h(a5)
	tst	stfalc_valid(pc)
	beq.s	.resident
	move	#DISABLED,falcon_but*ob_size+ob_state(a5)
	move	#DISABLED,st_but*ob_size+ob_state(a5)
.resident

	move.l	adresse_cookie(pc),a0
	btst	#0,ck_flags+1(a0)	; Test si ‚cran virtuel
	beq.s	.pasv
	move	#SELECTED,virt_but*ob_size+ob_state(a5)
.pasv

	move	#-1,-(sp)
	Xbios	Vsetmode
	move	d0,mode_xbios		; Mode vid‚o courant
	Xbios	mon_type
	cmp	#3,d0
	bne.s	.suite
	moveq	#1,d0
.suite	move	d0,type_moniteur

	bsr	charge_fichier
	tst	d0
	beq	gf_fin

	clr	ypos
	move	#-1,mode_actuel		; aucun mode par d‚faut
	bsr	maj_ascenseur
	bsr	maj_select

	move	mode_xbios(pc),d6
	move	d6,d0

; Mise … jour des paramŠtres de la boŒte de s‚lection des modes Falcon.
	lea	rsc(pc),a0
	add	rsh_trindex(a0),a0	; Adresse des arbres d'objets
	move.l	falcon*4(a0),a0		; Adresse de l'arbre de config
	move	d6,d0			; Mode vid‚o courant
	move	d0,d1
	and	#7,d1			; r‚cupŠre ce qui correspond au nb de couleurs
	add	#coul2_but,d1		; + no d'objet correspondant au bouton 2 couleurs
	move	d1,d2
	add	d1,d1
	add	d2,d1			; nb*3
	move	#SELECTED,ob_state(a0,d1.w*8)	; nb*24
	moveq	#col40_but*3,d1
	lsr	#4,d0			; Test du bit 80 colonnes
	bcc.s	.40col
	add.w	#3,d1			; Objet d'… c“t‚
.40col	move	#SELECTED,ob_state(a0,d1.w*8)
	moveq	#over_but*3,d1
	lsr	#3,d0			; Test du bit Overscan
	bcs.s	.ov
	add.w	#3,d1
.ov	move	#SELECTED,ob_state(a0,d1.w*8)
	moveq	#entr_but*3,d1
	lsr	#2,d0			; Test du bit entrelac‚
	bcs.s	.entr
	add.w	#3,d1
.entr	move	#SELECTED,ob_state(a0,d1.w*8)

	move	type_moniteur(pc),d0
	bne.s	.pas_mono
	move	#DISABLED,falcon_but*ob_size+ob_state(a5)
	move	#DISABLED,st_but*ob_size+ob_state(a5)
.pas_mono
	lea	mode_rgb_txt(pc),a1
	cmp	#1,d0			; Test RGB
	beq.s	.rgb
	lea	mode_vga_txt(pc),a1
	move	#DISABLED,over_but*ob_size+ob_state(a0)
.rgb

.commun
	move.l	a1,vmode_str*ob_size+ob_spec(a0)

	bsr	gestion_virtuel
	bsr	affiche_boite

attente_clic
	moveq	#-1,d0
	tst	virt_but*ob_size+ob_state(a5)
	beq.s	.fd
	moveq	#0,d0
.fd	form_do	a5,#-1
	move	d0,d5
	smi	d6			; Si double clic (bit 15=1)
	bclr	#15,d5			; On ne tient pas compte des double clics
	objc_offset a5,#0
	move	int_out+2(pc),gf_xa(sp)
	move	int_out+4(pc),gf_ya(sp)

test0
;	cmp	#coul_but,d5
;	bne	test1
;test1

	cmp	#ligne0,d5
	bmi	test2
	cmp	#ligne0+NOMBRE_LIGNES,d5
	bpl	test2

; Clic sur une entr‚e
	move	d5,d4
	sub	#ligne0,d4
	add	ypos(pc),d4	; Num‚ro du mode s‚lectionn‚

	cmp	nombre_modes(pc),d4
	bpl	attente_relachement_souris	; Si on clique sur une ligne vide

	move	mode_actuel(pc),d0
	bmi.s	.suite
	move	ypos(pc),d1
	cmp	d1,d0
	bmi.s	.suite		; Si l'ancien mode est pas visible (au dessus)
	add.w	#NOMBRE_LIGNES,d1
	cmp	d1,d0
	bpl.s	.suite
	sub	ypos(pc),d0
	add	#ligne0,d0

	objc_change a5,d0,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#NORMAL,#1
.suite
	objc_change a5,d5,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#SELECTED,#1
	move	d4,mode_actuel

	bsr	gestion_virtuel
	moveq	#ok_but,d5
	tst.b	d6
	bne	sortie

	moveq	#x_ftx,d0
	bsr	affiche_obj
	moveq	#y_ftx,d0
	bsr	affiche_obj

	bra	attente_relachement_souris

test2
	cmp	#up_arrow,d5
	bne	test3

uar_bcl
	tst	ypos(pc)
	ble.s	uar_fin
	objc_change a5,d5,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#SELECTED,#1
	subq	#1,ypos
	bsr	maj_ascenseur
	bsr	maj_select
	bsr	affiche_fen_asc
	graf_mkstate
	tst	int_out+6(pc)	; ‚tat du bouton de la souris
	bne.s	uar_bcl

uar_fin
	objc_change a5,d5,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#NORMAL,#1
attente_relachement_souris
	graf_mkstate
	tst	int_out+6(pc)	; ‚tat du bouton de la souris
	bne	attente_relachement_souris

	bra	attente_clic

test3
	cmp	#down_arrow,d5
	bne.s	test4

	move	nombre_modes(pc),d4
	sub	#NOMBRE_LIGNES,d4
dar_bcl
	cmp	ypos(pc),d4
	ble	uar_fin
	objc_change a5,d5,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#SELECTED,#1
	addq	#1,ypos
	bsr	maj_ascenseur
	bsr	maj_select
	bsr	affiche_fen_asc
	graf_mkstate
	tst	int_out+6(pc)	; ‚tat du bouton de la souris
	bne	dar_bcl
	bra	uar_fin

test4
	cmp	#slide_button,d5
	bne	test41
	cmp	#NOMBRE_LIGNES,nombre_modes
	ble	attente_relachement_souris

	graf_mkstate
	move	int_out+4(pc),d4	; Position y de la souris

	objc_change a5,#slide_button,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#SELECTED,#1
	graf_mouse #FLAT_HAND

	sub	slide_button*24+ob_y(a5),d4
	subq	#1,d4			; ydep

	move	nombre_modes(pc),d3
	sub	#NOMBRE_LIGNES,d3

	move	vsp_button*24+ob_h(a5),d5
	sub	slide_button*24+ob_h(a5),d5	; dy

slide_bcl
	graf_mkstate
	moveq	#0,d0
	move	int_out+4(pc),d0	; position y de la souris
	move	int_out+6(pc),d6	; ‚tat du bouton de la souris
	sub	d4,d0			; position de la barre correspondant
	muls	d3,d0
	divs	d5,d0
	tst	d0

	bpl.s	slide_s0
	moveq	#0,d0
slide_s0
	cmp	d3,d0
	bmi.s	slide_im
	move	d3,d0
slide_im

	cmp	ypos(pc),d0
	beq.s	slide_raf

	move	d0,ypos
	bsr	maj_ascenseur
	bsr	maj_select
	bsr	affiche_fen_asc
slide_raf
	tst	d6
	bne	slide_bcl
	graf_mouse #ARROW
	objc_change a5,#slide_button,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#NORMAL,#1

	bra	attente_clic

test41
	cmp	#vsp_button,d5
	bne.s	test5

	graf_mkstate
	move	int_out+4(pc),d4	; Position y de la souris
	objc_offset a5,#slide_button
	move	int_out+4(pc),d3	; Position y du slider

	move	ypos(pc),d5
	cmp	d3,d4			; Comparaison de coordonn‚es.
	bhi.s	vsp_descente
	sub	#NOMBRE_LIGNES,d5	; On remonte, donc ypos diminue
	bpl.s	vsp_ok			; Si la position est n‚gative
	moveq	#0,d5			; On la force … 0
	bra.s	vsp_ok
vsp_descente
	move	nombre_modes(pc),d4
	sub	#NOMBRE_LIGNES,d4	; position y … ne pas d‚passer
	add	#NOMBRE_LIGNES,d5	; On descend, donc ypos augmente
	cmp	d4,d5
	ble.s	vsp_ok
	move	d4,d5			; Valeur maxi
vsp_ok
	move	d5,ypos

	bsr	maj_ascenseur
	bsr	maj_select
	bsr	affiche_fen_asc
;	graf_mkstate
;	tst	int_out+6(pc)	; ‚tat du bouton de la souris
;	bne	dar_bcl
	bra	attente_clic



test5
	cmp	#sauve_but,d5
	bne	test6
	tst	mode_actuel(pc)
	bmi	fin_gestion_sauvegarde

	graf_mouse #BUSYBEE

	lea	tampon_cookie(pc),a0
	move.l	a0,a1
	move	#TAILLE_CK/2-1,d0
efface_tampon
	clr	(a0)+
	dbra	d0,efface_tampon
	move	#MASQUE_DEFAUT,ck_vmmask(a1)

ouverture_inf
	move	#2,-(sp)		;lecture & ‚criture
	pea	nom_fichier_inf(pc)	;Nom du fichier
	Gemdos	Fopen
	move	d0,d7
	bpl.s	ouverture_inf_ok
	cmp	#-33,d0			; Fichier non trouv‚ ?
	bne	erreur_fichier_inf

; On cr‚e un fichier puisqu'il n'y en a pas...
	clr.w	-(sp)
	pea	nom_fichier_inf(pc)
	Gemdos	Fcreate
	move	d0,d7
	bmi	erreur_fichier_inf

	pea	header_type(pc)	; adresse buffer
	pea	10.w		; Taille … ‚crire
	move	d7,-(sp)
	Gemdos	Fwrite

	moveq	#3-1,d6
ecrit_cookie_vierge
	pea	tampon_cookie+6(pc)
	pea	TAILLE_CK-6.w
	move	d7,-(sp)
	Gemdos	Fwrite
	dbra	d6,ecrit_cookie_vierge

	move	d7,-(sp)
	Gemdos	Fclose
	bra.s	ouverture_inf		; Hop c'est cr‚‚, ‡a devrait marcher maintenant

ouverture_inf_ok
	pea	tampon_header(pc)
	pea	8.w			; taille header-2 (flags)
	move	d7,-(sp)
	Gemdos	Fread

	lea	tampon_header(pc),a0
	cmp.l	#"VI2.",(a0)+
	bne.s	erreur_header_inf
	cmp.l	#"INF"<<8,(a0)+
	bne.s	erreur_header_inf	; En cas de mauvais format de header...

	pea	flags_actuel(pc)	; adresse des flags par d‚faut
	pea	2.w
	move	d7,-(sp)
	Gemdos	Fwrite

	move	type_moniteur(pc),d0
	mulu	#TAILLE_CK-6,d0		; D‚calage pour sauver le cookie
	add	#10,d0			; + taille header
	clr	-(sp)			;… partir du d‚but du fichier
	move	d7,-(sp)		;handle
	move.l	d0,-(sp)		;offset
	Gemdos	Fseek

	lea	tampon_cookie(pc),a2
	bsr	creation_cookie

	pea	6(a2)			; Hop, on sauve le cookie fraŒchement g‚n‚r‚
	pea	TAILLE_CK-6.w
	move	d7,-(sp)
	Gemdos	Fwrite

erreur_header_inf
	move	d7,-(sp)
	Gemdos	Fclose			; Fermeture du fichier

erreur_fichier_inf
	graf_mouse #ARROW
fin_gestion_sauvegarde
	objc_change a5,d5,gf_xa(sp),gf_ya(sp),gf_w(sp),gf_h(sp),#NORMAL,#1
	bra	attente_clic

test6
	cmp	#falcon_but,d5
	bne	test7

	bsr	efface_boite

	lea	rsc(pc),a4
	add	rsh_trindex(a4),a4	; Adresse des arbres d'objets
	move.l	falcon*4(a4),a4		; Adresse de l'arbre de config

	move.l	a4,a0
	bsr	gestion_boite
	cmp	#fok_but,d0
	bne.s	test6_1			; Si on a pas cliqu‚ sur OK, retour … la bcl principale

; Recherche du mode de couleur ou on est.
	lea	coul2_but*ob_size+ob_state(a4),a0
	moveq	#0,d0
.bcl	tst	(a0)
	bne.s	.ok
	add	#24,a0
	addq	#1,d0
	bra	.bcl
.ok
	btst	#0,col40_but*ob_size+ob_state+1(a4)
	bne.s	.col40
	bset	#3,d0
.col40
	btst	#0,entr_but*ob_size+ob_state+1(a4)
	beq.s	.pas_entr
	bset	#8,d0
.pas_entr
	btst	#0,over_but*ob_size+ob_state+1(a4)
	beq.s	.pas_over
	bset	#6,d0
.pas_over
	cmp	#2,type_moniteur
	bne.s	.pas_vga
	bset	#4,d0
.pas_vga
	move.l	adresse_cookie(pc),a0
	clr	ck_vmode(a0)
	move	d0,ADR_RESO
	and.w	#$0060,ADR_XBIOS_RES	; mode nul -> force changement
	bra	sortie_modif

test6_1
	move	d5,d0
	add	d0,d0
	add	d5,d0
	move	#NORMAL,ob_state(a5,d0.w*8)

	bsr	affiche_boite
	bra	attente_clic


test7
	cmp	#st_but,d5
	bne.s	test8

	bsr	efface_boite

	lea	rsc(pc),a4
	add	rsh_trindex(a4),a4	; Adresse des arbres d'objets
	move.l	st*4(a4),a4		; Adresse de l'arbre de config

	move.l	a4,a0
	bsr	gestion_boite
	cmp	#sok_but,d0
	bne	test6_1			; Si on a pas cliqu‚ sur OK, retour … la bcl principale

; Recherche du mode st s‚lectionn‚.
	lea	basse_but*ob_size+ob_state(a4),a0
	moveq	#2,d0
.bcl	tst	(a0)
	bne.s	.ok
	add	#24,a0
	dbra	d0,.bcl
	bra.s	test6_1			; Si on n'a rien activ‚
.ok
	cmp	#2,d0			; c'est la basse r‚so?
	beq.s	.basse
	bset	#3,d0			; Sinon on passe en 80 colonnes.
.basse
	bset	#7,d0			; On active le mode ST, le reste est g‚r‚ par le TOS.
	move.l	adresse_cookie(pc),a0
	clr	ck_vmode(a0)
	move	d0,ADR_RESO
	bra.s	sortie_modif		; Et hop, c'est fini, y'a plus qu'a provoquer 
					; le changement de r‚so.
test8
	cmp	#virt_but,d5
	bne.s	test9

test8_1
	bsr	gestion_virtuel
	moveq	#x_ftx,d0
	bsr	affiche_obj
	moveq	#y_ftx,d0
	bsr	affiche_obj

	bra	attente_clic

test9
	cmp	#ok_but,d5
	beq.s	sortie
	cmp	#annul_but,d5
	beq.s	sortie
	bra	attente_clic

sortie
	bsr	efface_boite

	cmp	#ok_but,d5
	bne.s	pas_modif

	move	mode_actuel(pc),d0	; Si on n'a rien s‚lectionn‚
	bmi.s	pas_modif

	tst	stfalc_valid(pc)
	beq.s	.resident
	mulu	#TAILLE_mod,d0
	move.l	adr_bloc(pc),a1
	add.l	d0,a1			; Adresse du mode vid‚o actuel.
	add	#mod_nom,a1
	lea	bloc_chaine(pc),a0
.bcl1	move.b	(a1)+,(a0)+
	bne.s	.bcl1
.resident

	bsr.s	gestion_virtuel

	move.l	adresse_cookie(pc),a2	; adresse du bloc de donn‚es fourni dans le cookie
	bsr	creation_cookie
	move	ck_vmode(a2),ADR_RESO

sortie_modif
	move.l	adr_bloc(pc),d0
	beq.s	.pas_bloc
	move.l	d0,-(sp)
	Gemdos	Mfree
.pas_bloc
	moveq	#1,d0
	bra.s	ok_modif

pas_modif
	move.l	adr_bloc(pc),d0
	beq.s	.pas_bloc
	move.l	d0,-(sp)
	Gemdos	Mfree
.pas_bloc
	moveq	#0,d0
ok_modif
	clr.l	adr_bloc
gf_fin
	add	#taille,sp
	movem.l	(sp)+,d1-d7/a1-a6
	rts

; modifie les valeurs des 2 champs ‚ditable de l'‚cran virtuel, en fonction de
; s'il est actif ou pas. C'est pas grave, je me comprends.
; Copie dans vwidth et vheight les largeurs et hauteur virtuelles corrig‚es si
; l'‚cran virtuel est actif, sinon la r‚so s‚lectionn‚e.
; a5 = arbre d'objets principal.
gestion_virtuel
	lea	vwidth(pc),a2		; Adresse des largeur et hauteur virtuelles
	move	mode_actuel(pc),d2	; si un mode est s‚lectionn‚
	bmi	gvir_pas_select
	mulu	#TAILLE_mod,d2
	move.l	adr_bloc(pc),a1
	add.l	d2,a1			; Adresse du mode vid‚o actuel.
	tst	virt_but*ob_size+ob_state(a5)	; si l'‚cran virtuel est d‚sactiv‚
	beq.s	gvir_desactive

	move	#NORMAL,x_ftx*ob_size+ob_state(a5)
	move	#NORMAL,y_ftx*ob_size+ob_state(a5)
	move	#EDITABLE|1<<10,x_ftx*ob_size+ob_flags(a5)
	move	#EDITABLE|1<<10,y_ftx*ob_size+ob_flags(a5)

	move.l	x_ftx*ob_size+ob_spec(a5),a0	; a0 pointe sur la tedinfo.
	move.l	te_ptext(a0),a0			; a0 = texte
	bsr	atoi
	cmp	mod_xres(a1),d0
	bpl.s	gvir_xsup		; des fois qu'on ait rentr‚ une r‚so virtuelle
					; inf‚rieure … la r‚so r‚elle.
	move	mod_xres(a1),d0		; Dans ce cas, on corrige l'erreur.
gvir_xsup
	moveq	#-16,d1			; Masque de largeur.
	move	mod_flags(a1),d2
	lsr	#4,d2
	and	#7,d2			; log2 ( Nombre de bits / pixel )
	bne.s	gvir_xmok		; si on est pas en 2 couleurs, ok.
	add	d1,d1			; du coup on masque sur 32 pixels et pas sur 16.
gvir_xmok
	and	d1,d0
	move	d0,(a2)			; On sauve la largeur.

	move.l	y_ftx*ob_size+ob_spec(a5),a0	; a0 pointe sur la tedinfo.
	move.l	te_ptext(a0),a0			; a0 = texte
	bsr	atoi
	move	mod_yres(a1),d2		; R‚so r‚elle verticale.
	cmp	d2,d0
	bpl.s	gvir_ysup		; des fois qu'on ait rentr‚ une r‚so virtuelle
					; inf‚rieure … la r‚so r‚elle.
	move	d2,d0			; Dans ce cas, on corrige l'erreur.
gvir_ysup
	moveq	#-8,d1			; Masque de hauteur.
	cmp	#400,d2			; On est en caractŠres de 8 ou 16 lignes ?
	bmi.s	gvir_ymok
	add	d1,d1			; On masque sur 16 lignes et pas sur 8.
gvir_ymok
	and	d1,d0
	move	d0,2(a2)		; On sauve la hauteur.

	bra.s	gvir_aff_rezo

gvir_desactive
	move	mod_xres(a1),(a2)	; largeur
	move	mod_yres(a1),2(a2)	; Adresse de la hauteur
	bra.s	gvir_desactive_ftx

gvir_pas_select
	move.l	adresse_cookie(pc),a1
	move.l	ck_vwidth(a1),(a2)

gvir_desactive_ftx
	move	#DISABLED,x_ftx*ob_size+ob_state(a5)
	move	#DISABLED,y_ftx*ob_size+ob_state(a5)
	move	#1<<10,x_ftx*ob_size+ob_flags(a5)
	move	#1<<10,y_ftx*ob_size+ob_flags(a5)

gvir_aff_rezo
	move.l	x_ftx*ob_size+ob_spec(a5),a0	; a0 pointe sur la tedinfo.
	move.l	te_ptext(a0),a0			; a0 = texte
	moveq	#0,d0
	move	(a2)+,d0			; d0 = largeur virtuelle.
	bsr	itoa
	clr.b	(a0)
	move.l	y_ftx*ob_size+ob_spec(a5),a0	; a1 pointe sur la tedinfo.
	move.l	te_ptext(a0),a0			; a0 = texte
	move	(a2),d0				; d0 = hauteur virtuelle.
	bsr	itoa
	clr.b	(a0)

	rts


; Cr‚e un cookie prˆt … servir
; a2 = adresse de destination du cookie
creation_cookie
	move	mode_actuel(pc),d0	; Num‚ro du mode actuellement s‚lectionn‚
	mulu	#TAILLE_mod,d0
	move.l	adr_bloc(pc),a0
	add.l	d0,a0			; Adresse du mode vid‚o s‚lectionn‚

	move	mod_flags(a0),d0	; Les flags divers du mode vid‚o
	moveq	#0,d2
	cmp	#400,mod_yres(a0)	; La r‚solution ‚cran verticale
	bpl.s	.pas_double_ligne
	bset	#8,d2			; Bit Double ligne
.pas_double_ligne
	move	type_moniteur(pc),d1	; Type de moniteur (0:mono,1:rgb,2:vga)
	cmp	#1,d1			; Mode RGB ?
	bne.s	gestion_mono_vga
gestion_rgb
	bchg	#8,d2			; bit d'entrelacement
	move	d0,d1
	and	#$C,d1			; Test si moyenne ou haute r‚solution horizontale
	beq.s	.pas80
	bset	#3,d2			; On passe en 80 colonnes
.pas80
	bra.s	gestion_commune
gestion_mono_vga
	bset	#4,d2			; On active le bit VGA
	btst	#3,d0			; Test si haute r‚solution horizontale
	beq.s	.pas80
	bset	#3,d2			; Mode 80 colonnes
.pas80
gestion_commune
	lsr	#4,d0
	and	#7,d0			; On isole les couleurs
	or	d2,d0
	move	d0,ck_vmode(a2)

	move	flags_actuel(pc),d2
	move	mod_xres(a0),d0
	move	vwidth(pc),d1
	move	d1,ck_vwidth(a2)
	cmp	d0,d1
	beq.s	.pasx
	bset	#0,d2			; active l'‚cran virtuel
.pasx
	move	mod_yres(a0),d0
	move	vheight(pc),d1
	move	d1,ck_vheight(a2)
	cmp	d0,d1
	beq.s	.pasy
	bset	#0,d2			; active l'‚cran virtuel
.pasy
	move	d2,ck_flags(a2)
	move	#MASQUE_DEFAUT,ck_vmmask(a2)
	move.l	xthres_actuel(pc),ck_xthres(a2)	; Copie seuils x et y en mˆme temps

	lea	ck_mod_flags(a2),a3
	moveq	#TAILLE_CK_MOD/2-1,d0
copie_regs
	move	(a0)+,(a3)+
	dbra	d0,copie_regs		; D‚j… on copie tous les registres horiz et vert.

	rts


affiche_fen_asc
	objc_draw a5,#scmode_window,#15,gf_xa+4(sp),gf_ya+4(sp),gf_w+4(sp),gf_h+4(sp)
	objc_draw a5,#vsp_button,#15,gf_xa+4(sp),gf_ya+4(sp),gf_w+4(sp),gf_h+4(sp)
	rts

; Affiche un objet.
; a5 = adresse arbre.
; sp+4 = adresse d'une structure gf_xywh
; d0 = num‚ro d'objet
affiche_obj
	objc_draw a5,d0,#15,gf_xa+4(sp),gf_ya+4(sp),gf_w+4(sp),gf_h+4(sp)
	rts

; Mise … jour du contenu du s‚lecteur
maj_select
	movem.l	d2-d4/a2,-(sp)
	lea	rsc(pc),a1
	add	rsh_trindex(a1),a1
	move.l	select*4(a1),a1		; Adresse de l'arbre
	lea	ligne0*24(a1),a0	; adresse de l'objet STRING
	move.l	adr_bloc(pc),a2
	add	#14,a2			; adresse de la 1ere chaŒne

	move	ypos(pc),d0
	move	d0,d1
	mulu	#TAILLE_mod,d1
	add	d1,a2			; Adresse de la 1ere chaŒne … afficher

	moveq	#NOMBRE_LIGNES-1,d3
	move	mode_actuel(pc),d4
	move	nombre_modes(pc),d1
	move	d0,d2
	add	#NOMBRE_LIGNES,d2
	cmp	d2,d1
	bmi.s	majs_affstr
	move	d2,d1			; on s'arrˆte … min(nombre_modes, NOMBRE_LIGNES+ypos)
majs_affstr
	cmp	d1,d0
	bpl.s	majs_fini
	move.l	a2,ob_spec(a0)
	cmp	d4,d0
	bne.s	majs_pas_actuel
	or	#SELECTED,ob_state(a0)
	bra.s	majs_actuel
majs_pas_actuel
	and	#~SELECTED,ob_state(a0)
majs_actuel
	add	#TAILLE_mod,a2
	add	#24,a0
	addq	#1,d0
	subq	#1,d3
	bra.s	majs_affstr
majs_fini
; Si on a pas tout affich‚ jusqu'en bas ( d3 ò 0 )
	tst	d3
	bmi.s	majs_rts	
.bcl
	move.l	#zero,ob_spec(a0)
	and	#~SELECTED,ob_state(a0)
	add	#24,a0
	dbra	d3,.bcl
majs_rts
	movem.l	(sp)+,d2-d4/a2
	rts

; Mise … jour des positions de l'ascenseur
maj_ascenseur
	lea	rsc(pc),a1
	add	rsh_trindex(a1),a1
	move.l	select*4(a1),a1		; Adresse de l'arbre

	move	vsp_button*24+ob_h(a1),d0	; Hauteur du slider
	move	nombre_modes(pc),d1
	cmp	#NOMBRE_LIGNES,d1
	bpl.s	.ok
	move	#NOMBRE_LIGNES,d1
.ok
	mulu	#NOMBRE_LIGNES,d0
	divu	d1,d0
	move	d0,slide_button*24+ob_h(a1)	; maj hauteur slider

	moveq	#0,d0
	move	vsp_button*24+ob_h(a1),d0
	sub	slide_button*24+ob_h(a1),d0
	beq.s	maja_pos0

	mulu	ypos(pc),d0
	move	nombre_modes(pc),d1
	sub	#NOMBRE_LIGNES,d1
	divu	d1,d0

maja_pos0
	move	d0,slide_button*24+ob_y(a1)

	rts

*********************************************
* Relocation d'un fichier ressource en incbin
*********************************************
rsc_reloc
	lea	rsc(pc),a6		; adresse du rsc
	move	rsh_nobs(a6),d7		; Nombre d'objets
	add	rsh_object(a6),a6	; Adresse des objets
	lea	copie_objets(pc),a5	; Adresse du buffer d'objets
	subq	#1,d7

copie_obj_bcl
	move.l	a5,a4
	REPT	6
	move.l	(a6)+,(a5)+
	ENDR
	rsrc_obfix a4,#0		; Changement de taille
	dbra	d7,copie_obj_bcl

	rts

*** Routine d'affichage d‚cimal ***
* a0=adresse variable
* d0=valeur … afficher
* Retour : 
* d0=Nombre de caractŠres ‚mis
itoa
	movem.l	d1-d2,-(sp)
	moveq	#0,d2
.bcl	divu	#10,d0
	swap	d0
	add	#'0',d0
	move	d0,-(sp)
	addq	#1,d2
	clr	d0
	swap	d0
	bne.s	.bcl
	move	d2,d1
	subq	#1,d1
.bcl2	move	(sp)+,d0
	move.b	d0,(a0)+
	dbra	d1,.bcl2
	move	d2,d0
	movem.l	(sp)+,d1-d2
	rts

; Conversion ASCII d‚cimal -> binaire
; a0 = adresse du texte
; retour d0 = valeur convertie
atoi
	move.l	d1,-(sp)
	moveq	#0,d0
	moveq	#0,d1
.bcl	tst.b	(a0)
	bne.s	.suite
	move.l	(sp)+,d1
	rts
.suite	mulu	#10,d0
	move.b	(a0)+,d1
	sub.b	#'0',d1
	add	d1,d0
	bra.s	.bcl

* Depart du programme
*********************
depart
	StartUp	$1000

	pea	recherche_cookie(pc)
	Xbios	Supexec
	move.l	d0,adresse_cookie	; Cookie existant ?

	tst.l	d7
	bne	gestion_acc

	clr	global		;on positionne global(0) … 0
	appl_init
	tst	global(pc)	;si global(0) est toujours … 0 aprŠs le appl_init()
	beq	boot_executed	;c'est que l'aes n'est pas install‚, donc on est en AUTO

*** Gestion d'un appel depuis le bureau ***

	tst.l	adresse_cookie(pc)
	bne.s	ok_cook
	form_alert #1,#cook_err_alert
	bra	ap_exit
ok_cook
	bsr	rsc_init
	st	stfalc_valid
	graf_mouse #ARROW
	bsr	gestion_formulaire
	tst	d0
	beq	ap_exit

	sub	#256,sp		; on se r‚serve une petite place m‚moire...
	move.l	sp,a0
	lea	fin_alert1(pc),a1
	bsr	copie_txt
	lea	bloc_chaine(pc),a1
	bsr	copie_txt
	lea	fin_alert2(pc),a1
	bsr.s	copie_txt
	move.l	adresse_cookie(pc),a2
	move.l	#320,d0
	move	ck_vmode(a2),d1	; mode s‚lectionn‚
	btst	#3,d1		; test du mode 80 colonnes
	beq.s	.x320
	add.l	d0,d0		; C'est 640 finalement
.x320	bsr	itoa
	move.b	#'x',(a0)+
	moveq	#100,d0
	add.l	d0,d0		; 200
	btst	#4,d1		; Test du mode VGA
	beq.s	.xrgb
	add	#40,d0		; 240
	bchg	#8,d1		; Inverse le flag vertical, pour compatibilit‚ RGB
.xrgb	btst	#8,d1
	beq.s	.x200
	add	d0,d0		; 400 ou 480
.x200	bsr	itoa
	move.w	#', ',(a0)+
	and	#7,d1
	moveq	#1,d0
	lsl	d1,d0
	move.l	d0,d1
	moveq	#1,d0
	lsl	d1,d0		; nombre de couleurs.
	bsr	itoa

	lea	fin_alert3(pc),a1
.copie3	move.b	(a1)+,(a0)+
	bne.s	.copie3

	form_alert #1,sp

	add	#256,sp
*** Sortie du programme ***
ap_exit
	appl_exit
	Gemdos	Pterm0

copie_txt
	move.b	(a1)+,(a0)+
	bne.s	copie_txt
	subq	#1,a0
	rts

gestion_acc
	appl_init
	menu_register d0,#acc_txt
	move	d0,me_id
	bsr	rsc_init
acc_bcl
	evnt_mesag #msg_buf
	move	msg_buf(pc),d0
	cmp	#AC_OPEN,d0
	bne	acc_bcl
	move	msg_buf+8(pc),d0
	cmp	me_id(pc),d0
	bne	acc_bcl

	form_alert #1,#acc_err_alert
	bra	acc_bcl

boot_executed
	pea	hello(pc)
	Gemdos	Cconws

	pea	install(pc)
	Xbios	Supexec

	tst	d0
	bne.s	quitte_resident
	Gemdos	Pterm0

quitte_resident
	bsr.s	rsc_init
	pea	the_end-debut+$100	; Bon ben c'est pas tout ca...
	Gemdos	Ptermres		; A la prochaine !

install
	move.l	$b8.w,a0		; Pointeur Xbios
cherche_id_bcl
	cmp.l	#'XBRA',-12(a0)		; C'est une routine XBRA ?
	bne.s	debut_installation	; Non, c'est que la routine n'est pas install‚e alors
	cmp.l	#id,-8(a0)		; C'est notre routine ?
	beq.s	cassos			; Oui, c'est qu'on est d‚j… install‚s
	move.l	-4(a0),a0		; Pointeur suivant dans la liste XBRA
	bra	cherche_id_bcl

debut_installation
	move	sr,-(sp)		; On se protŠge des interruptions et autres (?)
	move	#$2700,sr		; suspend toutes les interruptions
	move.l	$b8.w,anc_xbios		; On sauve l'ancienne adresse Xbios
	move.l	#notre_xbios,$b8.w	; On met la notre … la place
	moveq	#1,d0
	rtr				; Vala, c'‚tait pas long, on peut remettre les it's ...

cassos
	moveq	#0,d0
	rts

rsc_init
; Phase 1 : on reloge les diff‚rentes structures du systŠme
	lea	rsc(pc),a1		; adresse du rsc
; te_ptext
	move	rsh_tedinfo(a1),a0	; adresse des pointeurs des te_ptext
	move	rsh_nted(a1),d0		; nombre de te_ptext
	moveq	#28,d1			; ‚cart entre 2 TEDINFO
	bsr	rsrc_raddr
; te_ptmplt
	move	rsh_tedinfo(a1),a0
	addq	#4,a0
	move	rsh_nted(a1),d0
	moveq	#28,d1
	bsr	rsrc_raddr
; te_pvalid
	move	rsh_tedinfo(a1),a0
	addq	#8,a0
	move	rsh_nted(a1),d0
	moveq	#28,d1
	bsr	rsrc_raddr
; ib_pmask
	move	rsh_iconblk(a1),a0
	move	rsh_nib(a1),d0
	moveq	#34,d1
	bsr.s	rsrc_raddr
; ib_pdata
	move	rsh_iconblk(a1),a0
	addq	#4,a0
	move	rsh_nib(a1),d0
	moveq	#34,d1
	bsr.s	rsrc_raddr
; ib_ptext
	move	rsh_iconblk(a1),a0
	addq	#8,a0
	move	rsh_nib(a1),d0
	moveq	#34,d1
	bsr.s	rsrc_raddr
; bi_pdata
	move	rsh_bitblk(a1),a0
	move	rsh_nbb(a1),d0
	moveq	#14,d1
	bsr.s	rsrc_raddr

; Phase 2 : on reloge les vecteurs d'ob_spec
	move.l	a1,a2
	add	rsh_object(a2),a2	; adresse des objets
	move	rsh_nobs(a1),d1		; nombre d'objets
	subq	#1,d1

reloge_ob_spec
	move	6(a2),d0		; ob_type
	cmp	#20,d0			; G_BOX ?
	beq.s	pas_reloc_ob_spec
	cmp	#25,d0			; G_IBOX ?
	beq.s	pas_reloc_ob_spec
	cmp	#27,d0			; G_BOXCHAR ?
	beq.s	pas_reloc_ob_spec
	move.l	12(a2),a0
	add.l	a1,a0			; mise … jour ob_spec
	move.l	a0,12(a2)
pas_reloc_ob_spec
	add	#24,a2
	dbra	d1,reloge_ob_spec

; Phase 3 : on reloge la table des pointeurs sur les arbres d'objets
	move.l	a1,a2
	add	rsh_trindex(a1),a2	; adresse des pointeurs
	lea	copie_objets(pc),a3	; adresse des objets (pas encore) recopi‚s
	sub.l	(a2),a3			; - premier pointeur = d‚calage … rajouter
	move	rsh_ntree(a1),d0
	subq	#1,d0
reloge_table_arbres
	move.l	(a2),a0
	add.l	a3,a0
	move.l	a0,(a2)+
	dbra	d0,reloge_table_arbres
	rts

* Reloge des pointeurs
; en entr‚e: 
; a0 = adresse du premier pointeur - adr rsc
; a1 = adresse du rsc
; d0.w = nombre de pointeurs
; d1.w = offset entre chaque pointeur
rsrc_raddr
	add.l	a1,a0		; adresse du pointeur
	subq	#1,d0
	bcs.s	.rts		; si c'‚tait … 0
.bcl
	move.l	(a0),a2
	add.l	a1,a2
	move.l	a2,(a0)
	add	d1,a0
	dbra	d0,.bcl
.rts	rts


	section	data

stfalc_valid	dc.w	0		; Si != 0, alors on d‚sactive les boutons ST et Falcon
adr_bloc	dc.l	0		; Kan adr_bloc == 0 c'est qu'il n'y a pas de bloc r‚serv‚

freqs		dc.w	31000, 33000, 500, 750		;/* Moniteur monochrome */
		dc.w	15000, 16000, 475, 610		;/* Moniteur RGB */
		dc.w	31000, 35000, 500, 750		;/* Moniteur (S)VGA */
freqs_ms	dc.w	22000, 40000, 450, 1500		;/* Moniteur Multisync */

liste_couleurs	dc.l	coul2,coul4,coul16,coul256,coul64k

header_type	dc.b	"VI2.INF",0	; cette ligne doit ˆtre suivie de flags_actuel
flags_actuel	dc.w	8		; *! Valeur par d‚faut, pas modifi‚e pour l'instant
xthres_actuel	dc.w	50		; *! Valeur par d‚faut, pas modifi‚e pour l'instant
ythres_actuel	dc.w	50		; *! Valeur par d‚faut, pas modifi‚e pour l'instant

tampon_cookie	dcb.b	TAILLE_CK,0

freq_txt	dc.b	" Hz",0
		IFD	DX3
nom_fichier_dat	dc.b	"C:\VI2_DX3.DAT",0
nom_fichier_inf	dc.b	"C:\VI2_DX3.INF",0
		ELSE
nom_fichier_dat	dc.b	"C:\VI2.DAT",0
nom_fichier_inf	dc.b	"C:\VI2.INF",0
		ENDC
zero		dc.b	0

mode_rgb_txt	dc.b	"Mode entrelac‚:",0
mode_vga_txt	dc.b	"Mode double ligne:",0

pas_trouve_alert
		IFD	DX3
		dc.b	"[1][Le Fichier C:\VI2_DX3.DAT|est introuvable !|L'accŠs aux modes vid‚o|est impossible !][ Argh ! ]",0
		ELSE
		dc.b	"[1][Le Fichier C:\VI2.DAT|est introuvable !|L'accŠs aux modes vid‚o|est impossible !][ Argh ! ]",0
		ENDC
erreur_format_alert
		IFD	DX3
		dc.b	"[1][Le format du fichier C:\VI2_DX3.DAT|n'est pas g‚r‚ par cette version|du s‚lecteur de modes vid‚o !|Utilisez l'‚diteur de modes|pour effectuer la conversion.][ Dacodac ]",0
		ELSE
		dc.b	"[1][Le format du fichier C:\VI2.DAT|n'est pas g‚r‚ par cette version|du s‚lecteur de modes vid‚o !|Utilisez l'‚diteur de modes|pour effectuer la conversion.][ Dacodac ]",0
		ENDC
cook_err_alert	dc.b	"[1][VI 2 n'est pas pr‚sent en m‚moire !][ Argh ! ]",0
acc_err_alert	dc.b	"[1][Videl Inside Selector ne fonctionne|pas en tant qu'accessoire !][ Argh ! ]",0
fin_alert1	dc.b	"[1][VI 2 a ‚t‚ configur‚ selon le mode|",0
fin_alert2	dc.b	".|Veuillez s‚lectionner le mode vid‚o|",0
fin_alert3	dc.b	" couleurs|… partir du bureau.][ Ok ]",0
hello		dc.b	13,10,27,"p- Videl Inside Selector v1.03 -",27,"q",13,10
		dc.b	"par Fran‡ois GALEA",13,10,0
acc_txt		dc.b	"  Configuration VI 2",0
coul2		dc.b	"2",0
coul4		dc.b	"4",0
coul16		dc.b	"16",0
coul256		dc.b	"256",0
coul64k		dc.b	"64k",0
	even
rsc
	IFD	DX3
	incbin	vis_dx3.rsc
	ELSE
	incbin	vis.rsc
	ENDC
fin_rsc
TAILLE_RSC	equ	fin_rsc-rsc

	include	aeslib.s

	even
	section	bss

mode_actuel	ds.w	1		; Mode actuellement s‚lectionn‚
ypos		ds.w	1		; Position de l'ascenseur
type_moniteur	ds.w	1
mode_xbios	ds.w	1
nombre_modes	ds.w	1
adr_freqs	ds.l	1
copie_objets	ds.b	TAILLE_RSC
	even
vwidth		ds.w	1	; Largeur virtuelle … prendre en compte
vheight		ds.w	1	; Hauteur virtuelle

tampon_header	ds.b	20

me_id		ds.w	1	; Id de l'entr‚e de l'accessoire
msg_buf		ds.w	8

bloc_chaine	ds.b	256

the_end

	end


