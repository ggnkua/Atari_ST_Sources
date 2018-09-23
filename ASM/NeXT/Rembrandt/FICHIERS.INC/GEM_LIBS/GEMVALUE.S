; D‚finitions RS pour les objets GEM
;

 rsreset
menu_tree	rs.l 1	L'adresse de l'arbre du menu
menu_menu	rs.w 1	Le num‚ro de l'objet parent
menu_item	rs.w 1	Le num‚ro de l'objet dans le menu
menu_scroll	rs.w 1	0-> Pas de scroll, sinon repr‚sente l'objet d'o— le scroll commence
menu_keystate	rs.w 1	L'‚tat des touches CTRL/ALT/SHIFT lors de l'appui sur le bouton
menu_taille	rs.b 0	(***) Fin de d‚finition

 rsreset
values_display	rs.l 1	Delai avant affichage du sous-menu
values_drag	rs.l 1	Delai avant la disparition du sous-menu
values_delay	rs.l 1	Delai entre chaque scroll
values_speed	rs.l 1	Delai pour le scroll continu
values_height	rs.w 1	La hauteur du menu
values_taille	rs.b 0	(***) Fin de d‚finition

 rsreset
ob_next		rs.w 1	Pointeur sur objet suivant
ob_head		rs.w 1	Pointeur sur premier enfant
ob_tail		rs.w 1	Pointeur sur dernier enfant
ob_type		rs.w 1	Type d'objets
ob_flags	rs.w 1	Flags objets
ob_state	rs.w 1	Etat de l'objet
ob_spec		rs.l 1	[variable selon ob_type]
ob_x		rs.w 1  coordonn‚e x relative de l'objet 
ob_y		rs.w 1  coordonn‚e x relative de l'objet 
ob_l		rs.w 1  largeur de l'objet 
ob_h		rs.w 1  hauteur de l'objet 

flag_selectable	equ 0
flag_default	equ 1
flag_exit	equ 2
flag_editable	equ 3
flag_rbutton	equ 4
flag_lastob	equ 5
flag_touchexit	equ 6
flag_hidetree	equ 7
flag_indirect	equ 8
flag_relief	equ 9

state_selected	equ 0
state_crossed	equ 1
state_checked	equ 2
state_disabled	equ 3
state_oulined	equ 4
state_shadowed	equ 5


***** Pareil pour les fenetres:

win_name	equ 1
win_closer	equ 2
win_fuller	equ 4
win_mover	equ 8
win_info	equ 16
win_sizer	equ 32
win_up		equ 64
win_down	equ 128
win_vslide	equ 256
win_left	equ 512
win_right	equ 1024
win_hslide	equ 2048

***** Les messages possibles:

msg_menu	equ 10		Choix d'un menu d‚roulant

msg_redraw	equ 20
msg_topped	equ 21
msg_closed	equ 22
msg_fulled	equ 23
msg_arrowed	equ 24
msg_hslid	equ 25
msg_vslid	equ 26
msg_sized	equ 27
msg_moved	equ 28
msg_newtop	equ 29

msg_open_acc	equ 30
msg_close_acc	equ 31

**** Les types d'objets:
*
* Correspondant aux notations GEM:
*
g_box		equ 20	Boite rectangulaire
g_texte		equ 21	Texte complet (Taille et Style changeables)
g_boxtext	equ 22	Boite avec du texte
g_image		equ 23	Dessin bitmap
g_prodef	equ 24	Objet d‚finit par le programmeur (USER_DEF)
g_ibox		equ 25	Rectangle invisible
g_button	equ 26	Texte graphique centr‚ dans un rectangle
g_boxchar	equ 27	Rectangle avec une seule lettre centr‚e
g_string	equ 28	Texte simple (Pas d'attributs complexes)
g_ftext		equ 29	Texte graphique format‚
g_fboxtext	equ 30	Boite rectangulaire avec du texte format‚
g_icon		equ 31	Ic“ne
g_title		equ 32	Texte graphique pour le titre d'un menu d‚roulant.

*
* Correspondant aux notations NeXT:
*
_creu		equ -1
_plat		equ 0
_bomb‚		equ 0		(??? pourquoi pas 1 ???)

bord_fin	equ 0
bord_moyen	equ 1
bord_gros	equ 2

neutre		equ 0
color‚		equ -1

no_scan		equ 0
no_ascii	equ 0

no_prog		equ 0

GRIS50		equ 16<<11+32<<5+16
GRIS40		equ 14<<11+28<<5+14
VERT50		equ 31<<5
ROUGE100	equ 31<<11
VERT100		equ 63<<5
BLEU100		equ 31

def_‚paisseur	set bord_fin
def_hauteur	set _bomb‚ 

_box macro
; ifne narg,7
;   fail 'Parametrage foireux dans _BOX !!!'
; endc
 dc.w g_box		Type de l'objet
 dc.w \1,\2,\3,\4	X,Y,L,H
 dc.w def_‚paisseur	‚paisseur
 dc.w def_hauteur	0-> Bosse \ 1-> Creu
 dc.w \5		Couleur centre (RVB)
 dc.w \6		0-> GRIS \ 1-> D'aprŠs RGB.
 dc.l \7		Adresse de la routine de gestion (sinon 0)
 dc.l 0
 endm

_boxtext macro
; ifne narg,8
;   fail 'Parametrage foireux dans _BOXTEXT !!!'
; endc
 dc.w g_boxtext		Type de l'objet
 dc.w \1,\2,\3,\4	X,Y,L,H
 dc.w def_‚paisseur	‚paisseur
 dc.w def_hauteur	0-> Bosse \ 1-> Creu
 dc.w \5		Couleur centre (RVB)
 dc.w \6		0-> GRIS \ 1-> D'aprŠs RGB.
 dc.l \7		Adresse de la routine de gestion (sinon 0)
 dc.l \8		Adresse du texte (sinon 0)
 endm

raccourcis macro
 dc.b \1
 dc.b \2
 dc.l \3
 endm
 