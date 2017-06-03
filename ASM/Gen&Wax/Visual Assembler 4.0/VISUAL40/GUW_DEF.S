*----------------  Structure of the Main Application Object  --------------*
	rsreset

GWVA_APP_OBJ_FLAGS:		rs.b 1
	; bit 0 : (0) le ressource doit ˆtre charg‚, (1) il est en m‚moire
	; bit 1 : (0) un seul ressource (1) liste de ressorces en fonction de la resolution
	; bit 2 : (0) pas de background (1) image de fond si APP
	; bit 3 : (0) background normal (1) centrage auto de l'objet 1
GWVA_APP_OBJ_STATUS:		rs.b 1
	; bit 0 : (0) application non iconifi‚e (1) iconifi‚e

GWVA_APP_OBJ_TSR_SIZE:		rs.l 1	; longueur … sauvegarder (page de base y compris) pour les TSR, 0.l si pas TSR
GWVA_APP_OBJ_REG_NAME:		rs.l 1	; ptr sur le nom pour le MENU_REGISTER (REG_NEWNAME) (8 caracteres)
GWVA_APP_OBJ_ACC_NAME:		rs.l 1	; ptr sur le nom pour le MENU_REGISTER
GWVA_APP_OBJ_RSC_INFO:		rs.l 1	; ptr soit sur le path-name soit sur l'adresse du ressource,
				; ou bien sur un liste de ptr pour chaque nbre de coul. : 2, 4, 16, 256, pas de palette (5*1.L)
				; 0.l si pas de ressource
GWVA_APP_OBJ_BACKGROUND_OBJ:	rs.w 1	; index du tree-objet … mettre en fond si APP (la taille du pŠre sera ajust‚e … la taille du bureau)
GWVA_APP_OBJ_MAIN_MENU_PTR:	rs.l 1	; 0.l si pas de menu ou 1 pointeur sur une structure menu (GWVA_MENU_STRUCT)
GWVA_APP_OBJ_ALL_ICON_PTR:	rs.l 1	; ptr sur une structure de fenˆtre

GWVA_APP_OBJ_M1FLAG:		rs.w 1	; entr‚e de zone (0) sortie (1)
GWVA_APP_OBJ_M1X:		rs.w 1	; position et taille de la zone (<> 0 pour ˆtre actif)
GWVA_APP_OBJ_M1Y:		rs.w 1
GWVA_APP_OBJ_M1W:		rs.w 1
GWVA_APP_OBJ_M1H:		rs.w 1
GWVA_APP_OBJ_M2FLAG:		rs.w 1	; entr‚e de zone (0) sortie (1)
GWVA_APP_OBJ_M2X:		rs.w 1	; position et taille de la zone
GWVA_APP_OBJ_M2Y:		rs.w 1
GWVA_APP_OBJ_M2W:		rs.w 1
GWVA_APP_OBJ_M2H:		rs.w 1
GWVA_APP_OBJ_COUNT:		rs.l 1	; valeur du timer (<> 0 pour ˆtre actif)

GWVA_APP_OBJ_CUSTOM_INITS:	rs.l 1	; initialisation perso avant la boucle GEM d'attente

 ; A suivre tous les ‚vŠnements que peut recevoir l'objet 'application'
GWVA_APP_OBJ_AC_OPEN:		rs.l 1
GWVA_APP_OBJ_AC_CLOSE:		rs.l 1
GWVA_APP_OBJ_AP_TERM:		rs.l 1
GWVA_APP_OBJ_AP_TFAIL:		rs.l 1
GWVA_APP_OBJ_SHUT_COMPLETED:	rs.l 1
GWVA_APP_OBJ_RESCH_COMPLETED:	rs.l 1
GWVA_APP_OBJ_AP_DRAG_DROP:	rs.l 1
GWVA_APP_OBJ_SH_WDRAW:		rs.l 1
GWVA_APP_OBJ_CH_EXIT:		rs.l 1
GWVA_APP_OBJ_ALL_OTHER:		rs.l 1

GWVA_APP_OBJ_EVNT_KEYBD:	rs.l 1
GWVA_APP_OBJ_EVNT_BUTTON:	rs.l 1
GWVA_APP_OBJ_EVNT_MOUSE1:	rs.l 1
GWVA_APP_OBJ_EVNT_MOUSE2:	rs.l 1
GWVA_APP_OBJ_EVNT_TIMER:	rs.l 1

*-------------------  Structure of The Menu Objects  ----------------------*
	rsreset

GWVA_MENU_STRUCT_INDEX:		rs.w 1	; Index du tree du menu dans le ressource
GWVA_MENU_STRUCT_PTR:		rs.l 1	; pointeur sur le tree du menu dans le ressource
GWVA_MENU_STRUCT_SCROLL_INDEX:	rs.w 1	; num‚ro du top menu le plus … gauche (-1 pour tout)
GWVA_MENU_STRUCT_LIST_ATTACH_PTR:	rs.l 1	; 0.l si aucun sous menu ou 1 ptr sur un tableau de pointeurs sur des structures GWVA_SUB_MENU termin‚ par 0.l
GWVA_MENU_STRUCT_START_LIST:	rs.w 0
	; 1.w : num‚ro du menu
	; 1.w ; le shortcut ‚ventuel (0 si pas)
	;  1.b pour le masque de bits des touches sp‚ciales
	;  bit 0=Rshift, bit 1=Lshift, bit 2=Ctrl, bit 3=Alt
	;  1.b pour le scan-code US !!! sera converti en langue locale
	; 1.l : poiteur sur la routine associ‚e
	; -1.w … la fin
	; retour :	d0=Top menu s‚lectionn‚
	;	d1=Menu-item Idx
	;	d2=Menu Idx
	;	a0=Tree ad.

	; CTRL : dc.w MNU_DESK_INFO,$00*256+'i'-'a'+1; Ctrl - a
	; ALT  : dc.w MNU_FILE_WIND,$08*256+'a'	; Alt - a
	; Prendre son copain dium
	; regarder l'ikbd.w donn‚ pour cette combinaison sans shift
	; si l'octet bas est non nul : valeur ASCII : on se fout des touches sp‚
	; s'il est nul, c'est un scancode alors, en plus des touches sp‚ :
	; 1) si la touche correspond … quelquechose d'ASCII, le mettre
	; 2) sinon, (par ex. F1) mettre le scancode +$80
	; dŠs que l'on a pas $80+..., le masque de touches sp‚ est indiff‚rent
	; Pas de shortcut utilisant Alt et une touche strictement … droite de 8

	rsreset
GWVA_SUB_MENU_TREE_OBJ_ATTACHED:	rs.w 1	; Menu Tree contenant le menu auquel on veut attacher un sous menu
GWVA_SUB_MENU_OBJ_IDX_ATTACHED:	rs.w 1	; Index du menu auquel on va attacher un sous menu
GWVA_SUB_MENU_TREE:		rs.w 1	; Index du tree qui contient le dessin du sous menu
GWVA_SUB_MENU_INDEX:		rs.w 1	; Index du dessin pŠre dans le ressource
GWVA_SUB_MENU_WHICH_ALIGN:	rs.w 1	; Quel fils du pŠre ci-dessus doit ˆtre align‚ avec le menu de d‚part
GWVA_SUB_MENU_SCROLL:		rs.w 1	; Scrollable ? (0) non (1) oui
GWVA_SUB_MENU_STRUCT_START_LIST:	rs.w 0
	; 1.w : num‚ro du menu
	; 1.w ; le shortcut ‚ventuel (0 si pas)
	;  1.b pour le masque de bits des touches sp‚ciales
	;  bit 0=Rshift, bit 1=Lshift, bit 2=Ctrl, bit 3=Alt
	;  1.b pour le scan-code US !!! sera converti en langue locale
	; 1.l : poiteur sur la routine associ‚e
	; -1.w … la fin
	; retour :	d0=Top menu s‚lectionn‚
	;	d1=Menu-item Idx
	;	d2=Menu Idx
	;	a0=Tree ad.


*-------------------  Structure of the Window Objects  --------------------*
	rsreset

GWVA_WIND_OBJ_FLAGS:		rs.w 1	; same as GEM bits
	; 0 : name
	; 1 : close
	; 2 : full
	; 3 : move
	; 4 : info
	; 5 : size
	; 6 : up arrow	 7 : down arrow	 8 : v slide
	; 9 : left arrow	10 : right arrow	11 : h slide
	;14 : smaller

GWVA_WIND_OBJ_STATUS:		rs.w 1
	; 0 : GWVA_WIN_BIT_FULL    : 1=fulled
	; 1 : GWVA_WIN_BIT_OPEN    : 0=closed, 1=opened
	; 2 : GWVA_WIN_BIT_CURS    : 1=curseur du champ ‚ditable affich‚
	; 3 : GWVA_WIN_BIT_ICON    : 1=iconified
	; 4 : GWVA_WIN_NAMIFIED    : 1=window reduced to a title (and info)
	; 5 : Reserved, must be 0
	; 6 : Reserved, must be 0
	; 7 : Reserved, must be 0
	; 8-15 : Free for user

GWVA_WIND_OBJ_PROPERTIES:	rs.w 1
	; 0 : GWVA_WIN_BIT_ATOOLBAR: 1=window has got a toolbar attached
	; 1 : GWVA_WIN_BIT_AMENU   : 1=window has got a menu atached
	; 2 : GWVA_WIN_BIT_CTRLC   : 1=supports CTRL+C
	; 3 : GWVA_WIN_BIT_CTRLV   : 1=supports CTRL+V
	; 4 : GWVA_WIN_BIT_CTRLX   : 1=supports CTRL+X
	; 5 : Reserved, must be 0
	; 6 : Reserved, must be 0
	; 7 : Reserved, must be 0
	; 8 : GWVA_WIN_BIT_COPYXY   : 1=automatically copy window current_x,y to first_x,y when closed
	; 9 : GWVA_WIN_BIT_AUTODEL  : 1=automatically delete window when closed
	;10 : GWVA_WIN_BIT_FREEPTR1 : 1=automatically MFREE USER_PTR1 if window deleted
	;11 : GWVA_WIN_BIT_FREEPTR2 : 1=automatically MFREE USER_PTR2 if window deleted
	;12 : GWVA_WIN_BIT_FREEDATA : 1=automatically MFREE DATA_PTR  if bitmap window deleted
	;13 : GWVA_WIN_BIT_FREEPAL  : 1=automatically MFREE PAL_PTR   if bitmap window deleted
	;14 : GWVA_WIN_BIT_FREEFORM : 1=automatically MFREE CLONE_FORM_SAVE if form window deleted
	;15 : Reserved, must be 0

GWVA_WIND_OBJ_TOPABLE_STATE:	rs.w 1	; increment to make it untop, decrement to restore original state
				; decrement to make it ununtop, increment to restore original state (0 at startup)
GWVA_WIND_OBJ_NAME:		rs.l 1	; ptr sur nom
GWVA_WIND_OBJ_INFO:		rs.l 1	; ptr sur l'info
GWVA_WIND_OBJ_ICON_WIND_PTR:	rs.l 1	; ptr sur une structure fenˆtre

GWVA_WIND_OBJ_TOOLBAR_SPEC_PTR:	rs.l 1	; ptr sur l'objet toolbar : mˆme structure qu'un formulaire
GWVA_WIND_OBJ_TOOLBAR_HEIGHT:	rs.w 1	; hauteur de la toolbar 0.w si aucune
GWVA_WIND_OBJ_MENU_SPEC_PTR:	rs.l 1	; ptr sur l'objet menu (GWVA_MENU_STRUCT)
GWVA_WIND_OBJ_MENU_HEIGHT:	rs.w 1	; hauteur du menu 0.w si aucun
GWVA_WIND_OBJ_KEY_TABLE:	rs.l 1	; ptr sur une table de touches & routines associ‚es 0.l si aucune
	; 1 word type de raccourci (0 normal, 1=ctrl+C, 2=ctrl+V, 3=ctrl+X)
	; 1 word shortcut
	; 1 long pointeur sur la routine
	; fin par -1.w

;<<< Ces valeurs ne sont pas modifi‚s par le VISUAL
GWVA_WIND_OBJ_FIRST_X:		rs.w 1	; externe (-1 pour centrer)
GWVA_WIND_OBJ_FIRST_Y:		rs.w 1	; 
GWVA_WIND_OBJ_FIRST_W:		rs.w 1	; (interne) en unit‚ de la fenˆtre
GWVA_WIND_OBJ_FIRST_H:		rs.w 1	; carac ou pixels (TAILLE MINIMALE 64 PIXELS*?)
;>>>
GWVA_WIND_OBJ_INTERNAL_MAX_W:	rs.w 1	; (interne) en pixels si bitmap fix‚ par taille de l'image
GWVA_WIND_OBJ_INTERNAL_MAX_H:	rs.w 1	; si wind_text, fix‚ par nb col,ligne : sera recalcul‚ en pixel
	; n'est pas compt‚e la hauteur de la toolbar
	; si l'unit‚ est le caractŠre, ils seront calcul‚s … l'init
	; tous seront de toute fa‡on v‚rifi‚s … l'init

GWVA_WIND_OBJ_GEM_HANDLE:	rs.w 1
	; handle gem, mettre -1 au d‚but
	; s'il y a -1 ici c'est que la fenˆtre n'existe pas !

GWVA_WIND_OBJ_EXTERNAL_X:	rs.w 1	; tout ceci est calcul‚ par
GWVA_WIND_OBJ_EXTERNAL_Y:	rs.w 1	; le visual et ne doit pas
GWVA_WIND_OBJ_EXTERNAL_W:	rs.w 1	; ˆtre chang‚
GWVA_WIND_OBJ_EXTERNAL_H:	rs.w 1	; hauteur toolbar compt‚e
GWVA_WIND_OBJ_INTERNAL_X:	rs.w 1
GWVA_WIND_OBJ_INTERNAL_Y:	rs.w 1	; r‚el … l'‚cran, d‚cal‚ vers le bas si toolbar
GWVA_WIND_OBJ_INTERNAL_W:	rs.w 1
GWVA_WIND_OBJ_INTERNAL_H:	rs.w 1
GWVA_WIND_OBJ_EXTERNAL_MAX_W:	rs.w 1	; (externe) lors d'un wind top ou resize
GWVA_WIND_OBJ_EXTERNAL_MAX_H:	rs.w 1	; en pixels

GWVA_WIND_OBJ_SLIDER_V_POS:	rs.w 1	; position de 1 … 1000
GWVA_WIND_OBJ_SLIDER_V_SIZE:	rs.w 1	; taille de 1 … 1000 (-1 : taille minimale)
GWVA_WIND_OBJ_SLIDER_H_POS:	rs.w 1
GWVA_WIND_OBJ_SLIDER_H_SIZE:	rs.w 1

GWVA_WIND_OBJ_TYPE:		rs.w 1
	; 1 : GWVA_WIND_CUSTOM : Window custom sans rien … l'int‚rieur, juste les bords
	; 2 : GWVA_WIND_TEXT   : Window TEXT
	; 3 : GWVA_WIND_FORM   : Window contenant un formulaire
	; 4 : GWVA_WIND_BITMAP : Window contenant du bitmap
	; Window contenant une toolbox, faites un formulaire

GWVA_WIND_OBJ_SPEC_PTR:		rs.l 1	; pointeur sur une structure sp‚cifique en fonction du type

GWVA_WIND_OBJ_USER_PTR1:	rs.l 1	; pointeurs user defined
GWVA_WIND_OBJ_USER_PTR2:	rs.l 1

GWVA_WIND_OBJ_START_EVNT_LIST:	rs.w 1
	; liste : 1 word puis le ptr sur la routine correspondante
	; WM_BEFORE+WM_? est appel‚ avant l'action et WM_AFTER+WM_? aprŠs
	; ex.:	dc.w WM_BEFORE+WM_CLOSED (pas de WM_TOOLBAR)
	;	dc.l window_closed
	;	dc.w -1

	*-----------------------------------------------------*

	rsreset		; structure de l'objet fenˆtre bitmap

GWVA_WBITM_OBJ_IMG_WIDTH:	rs.w 1	; largeur de l'image
GWVA_WBITM_OBJ_IMG_HEIGHT:	rs.w 1	; hauteur de l'image
GWVA_WBITM_OBJ_DATA_PTR:	rs.l 1	; pointeur sur le buffer
GWVA_WBITM_OBJ_PAL_PTR:		rs.l 1	; ptr sur la palette (4/16/256)
GWVA_WBITM_OBJ_NBR_BITPLANES:	rs.w 1	; nb de plans (1,2,4,8,16)
GWVA_WBITM_OBJ_AFF_DX:		rs.w 1	; (X,Y) / buffer du pixel dans le coin
GWVA_WBITM_OBJ_AFF_DY:		rs.w 1	; sup‚rieur gauche

	*-----------------------------------------------------*

	rsreset		; structure de l'objet fenˆtre texte

GWVA_WTEXT_OBJ_NB_COLONNES:	rs.w 1	; largeur : les deux doivent ˆtre (TAILLE MINIMALE 64 PIXELS*?)
GWVA_WTEXT_OBJ_NB_LIGNES:	rs.w 1	; hauteur : fix‚s par l'utilisateur et fixent w,h maximal interne
GWVA_WTEXT_OBJ_FNT_SIZE:	rs.w 1	; taille de la font en pixels
GWVA_WTEXT_OBJ_CELL_WIDTH:	rs.w 1
GWVA_WTEXT_OBJ_CELL_HEIGHT:	rs.w 1
GWVA_WTEXT_OBJ_MALOC:		rs.l 1	; 0 si rien (pas de LF ni RC stock‚s)
GWVA_WTEXT_OBJ_CUR_BUF_COL:	rs.w 1
GWVA_WTEXT_OBJ_CUR_BUF_LIGN:	rs.w 1
GWVA_WTEXT_OBJ_CUR_AFF_COL:	rs.w 1
GWVA_WTEXT_OBJ_CUR_AFF_LIGN:	rs.w 1
GWVA_WTEXT_OBJ_BUF_COLONNE:	rs.w 1
GWVA_WTEXT_OBJ_BUF_LIGNE:	rs.w 1
GWVA_WTEXT_OBJ_AFF_COLONNE:	rs.w 1
GWVA_WTEXT_OBJ_AFF_LIGNE:	rs.w 1

	*-----------------------------------------------------*

	rsreset		; structure de l'objet fenˆtre formulaire

GWVA_WFORM_OBJ_FORM_IDX:	rs.w 1	; num‚ro du tree du formulaire
GWVA_WFORM_OBJ_FORM_PTR:	rs.l 1	; adresse du formulaire calcul‚e par le visual
GWVA_WFORM_OBJ_CLICK_ROUTINE:	rs.l 1	; routine pour tout click dans le formulaire ou 0.l
GWVA_WFORM_OBJ_FOCUSED_TXT:	rs.w 1	; focused text at startup
GWVA_WFORM_OBJ_CURSOR_POS:	rs.w 1	; position du curseur ?
GWVA_WFORM_OBJ_L_SCULPT:	rs.w 1	; largeur additionnelle … gauche
GWVA_WFORM_OBJ_T_SCULPT:	rs.w 1	; " en haut
GWVA_WFORM_OBJ_R_SCULPT:	rs.w 1	; " … droite
GWVA_WFORM_OBJ_B_SCULPT:	rs.w 1	; " en bas
GWVA_WFORM_OBJ_W_SCULPT:	rs.w 1	; largeur en tenant compte du 'relief'
GWVA_WFORM_OBJ_H_SCULPT:	rs.w 1	; hauteur "
GWVA_WFORM_OBJ_IS_CLONE_FORM:	rs.w 1	; champs de bit disant ce qu'il faut sauver si ce formulaire est un clone ou 0.w si form unique
GWVA_WFORM_OBJ_CLONE_FORM_SAVE:	rs.l 1	; pointeur sur une sauvegarde du contenu du formulaire
GWVA_WFORM_OBJ_CLONE_MAIN_PTR:	rs.l 1	; pointeur sur un mot long pointant en permanence sur la structure de la fenˆtre clone active
GWVA_WFORM_OBJ_START_OBJ_LIST:	rs.w 1
	; liste des objets du formulaire.
	; le num‚ro de l'objet, son shortcut (0 si non), son type, puis
	; un pointeur sur sa structure
	; fin par -1.w

	; Types
	; 1 : GWVA_FORM_WIND_OBJECT_TEXT         : champs de texte (‚ditable ou pas)
	; 2 : GWVA_FORM_WIND_OBJECT_BUTON        : bouton
	; 3 : GWVA_FORM_WIND_OBJECT_MENU_POPUP   : menu popup
	; 4 : GWVA_FORM_WIND_OBJECT_RADIO_BUTON  : radio bouton
	;*5 : GWVA_FORM_WIND_OBJECT_ROLL_POPUP   : roll over popup object (direct ptr sur struct du popup associ‚)
	;*6 : GWVA_FORM_WIND_OBJECT_ROLL_RADIO_B : roll over radio-button object (direct ptr sur struct du radio associ‚)
	;*7 : GWVA_FORM_WIND_OBJECT_PROGRESS_BAR : percent-progress graphic object
	; 8 : GWVA_FORM_WIND_OBJECT_SLIDER	     : Objet slider

	;*  = pas d'‚vŠnements

	; un bouton exit ou touchexit sera redessin‚ d‚selectionn‚
	; s'il est enfonc‚

	rsreset		; structure de l'objet texte
GWVA_FORM_TXT_OBJ_START_EVNT_LIST:	rs.w 1
	; les listes d'‚vŠnements sont : 
	; l'‚vŠnement.w puis le pointeur sur la routine.
	; -1 … la fin

	rsreset		; structure de l'objet bouton
GWVA_FORM_BTON_OBJ_STATE:	rs.w 1
GWVA_FORM_BTON_OBJ_START_EVNT_LIST:	rs.w 1
	; les listes d'‚vŠnements sont : 
	; l'‚vŠnement.w puis le pointeur sur la routine.
	; -1 … la fin
	; retour :	a0=ptr fenˆtre
	;	a1=ptr formulaire
	;	a2=ptr structure ‚vŠnement (ptr sur obj dans la liste des objets)
	;	a3=ptr obj bouton
	;	d0=No objet du formulaire click‚ qui a entrain‚ l'activation du popup
	;	d1=‚tat du bouton (bit 0 : selected?)

	rsreset		; structure de l'objet popup
GWVA_FORM_POP_OBJ_TREE_FORM:	rs.w 1	; num‚ro de l'arbre (formulaire contenant le popup)
GWVA_FORM_POP_OBJ_FORM_IDX:	rs.w 1	; num‚ro de l'objet qui sera le popup
GWVA_FORM_POP_OBJ_SELECTION:	rs.w 1	; num‚ro de l'objet s‚lectionn‚ (… initialiser par le user)
GWVA_FORM_POP_OBJ_CHANGE_ROUTINE:	rs.l 1	; ptr sur la routine CHANGED (0 si aucune)
	; retour :	a0=ptr fenˆtre
	;	a1=ptr formulaire
	;	a2=ptr structure ‚vŠnement (ptr sur obj dans la liste des objets)
	;	a3=ptr obj popup
	;	d0=No objet du formulaire click‚ qui a entrain‚ l'activation du popup
	;	d1=nouvelle s‚lection
	;	d2=ancienne s‚lection

	rsreset		; structure de l'objet radio-bouton
GWVA_FORM_RADIO_OBJ_SELECTION:	rs.w 1	; num‚ro de l'objet s‚lectionn‚ (… initialiser par le user)
GWVA_FORM_RADIO_OBJ_CHANGE_ROUTINE:	rs.l 1	; ptr sur la routine CHANGED (0 si aucune)
	; retour :	a0=ptr fenˆtre
	;	a1=ptr formulaire
	;	a2=ptr structure ‚vŠnement (ptr sur obj dans la liste des objets)
	;	a3=ptr obj radio-bouton
	;	d0=nouvelle s‚lection
	;	d1=ancienne s‚lection

	rsreset		; structure de l'objet percent-progress
GWVA_FORM_PROGRESS_OBJ_PERCENT:	rs.w 1	; pourcentage 0 <= percent <= 100 sinon infini "oo"
GWVA_FORM_PROGRESS_OBJ_TEXT_IDX:	rs.w 1	; Index du texte ASCII ou 0 si pas
GWVA_FORM_PROGRESS_OBJ_GRAPHIC_FIDX:rs.w 1	; Index du graphique pŠre fixe contenant l'autre variable (0 si pas)
GWVA_FORM_PROGRESS_OBJ_GRAPHIC_SIDX:rs.w 1	; Index du graphique dont la taille va varier de 0 … celle du pŠre

	rsreset		; structure de l'objet slider
GWVA_FORM_SLIDER_OBJ_POS:	rs.l 1	; Position du coulisseau (en nombre d'‚l‚ment : 0 -> (LENGTH-SIZE)
GWVA_FORM_SLIDER_OBJ_SIZE:	rs.l 1	; Nombre d'‚l‚ments repr‚sentant le coulisseau (une page)
GWVA_FORM_SLIDER_OBJ_LENGTH:	rs.l 1	; Nombre d'‚l‚ments repr‚sentant la glissiŠre
GWVA_FORM_SLIDER_OBJ_ORIENT:	rs.w 1	; Direction du slider (0 horizontal, 1 vertical)
GWVA_FORM_SLIDER_OBJ_GRAPHIC_FIDX:	rs.w 1	; Index du graphique de la glissiŠre
GWVA_FORM_SLIDER_OBJ_GRAPHIC_SIDX:	rs.w 1	; Index du graphique du coulisseau en lui mˆme
GWVA_FORM_SLIDER_OBJ_GRAPHIC_P1_IDX:rs.w 1	; Index de l'objet provoquant l'addition d'1 ‚lement (0 si pas)
GWVA_FORM_SLIDER_OBJ_GRAPHIC_M1_IDX:rs.w 1	; Index de l'objet provoquant la soustraction d'1 ‚lement (0 si pas)
GWVA_FORM_SLIDER_OBJ_GRAPHIC_P1P_IDX:rs.w 1	; Index de l'objet provoquant l'addition d'1 page (0 si pas)
GWVA_FORM_SLIDER_OBJ_GRAPHIC_M1P_IDX:rs.w 1	; Index de l'objet provoquant la soustraction d'1 page (0 si pas)
GWVA_FORM_SLIDER_OBJ_CHANGE_ROUTINE:rs.l 1	; ptr sur la routine CHANGED (0 si pas)
	; retour :	a0=ptr fenˆtre
	;	a1=ptr formulaire
	;	a2=ptr structure ‚vŠnement (ptr sur obj dans la liste des objets)
	;	a3=ptr obj slider
	;	d0.l=nouvelle position du slider
	;	d1.l=d‚placement effectu‚ (sign‚)

*--------------------------------------------------------------------------*
