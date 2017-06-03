	output d:\assemble\visual40\start\start.acx

OPT_FULL_PATHNAMES	; pour avoir le chemin complet du ressource pendant le d‚bug

	lea objet_application,a1

	include start.def
	include visual40.s
	include start.hs
	include start.obj

	comment HEAD=7
	section TEXT

*--------------------------------------------------------------------------*
	; Ceci est le programme de r‚f‚rence pour le Visual Assembleur 4.0
	; Il utilise presque toutes les fonctionnalit‚s de base (pas les librairies)
	; C'est celui que les concepteurs du V.A testent en premier quand ils
	; intŠgrent une nouvelle fonctionalit‚.

my_inits:
	lea objet_fenetre5,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND

	move #CAUTION,d0
	move #3,d1
	bsr RSC_ALERT_BOX

	rts

		*--------------------------*

app_term:
menu_quit:
	bra VISUAL40_END

		*--------------------------*

information:move.w #FORM_GENERAL,d0
	bsr GWVA_PRG_MODAL_FORM
	rts

		*--------------------------*

acc_open:	lea texte,a0		; 35 chars max.
	lea mask,a1			; 18 caracteres max
	lea 0,a2			; pas de s‚lection par d‚faut
	bsr FILE_SELECTOR
	tst d0
	ble.s .annule		; annule ou erreur ?

	move #ALERT1,d0		; exemple d'alerte dans le ressource
	move #2,d1
	bsr RSC_ALERT_BOX

.annule:	rts

		*--------------------------*

acc_close:	rts

		*--------------------------*

other_message:
	rts

		*--------------------------*

menu_wind1:
	; Attention cette fenˆtre a TOPABLE_STATE = 1
	; elle est donc untopable : jamais en premier plan !
	; quand on l'ouvre : elle se met derriŠre (untop) toute seule!

	lea objet_fenetre1,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

	; REMARQUE GENERALE : optimisation, on peut remplacer 
	; un BSR label suivi d'un RTS par un BRA
	; c'est moins lisible ... a vous de voir

menu_wind2:
	; Attention : cette fenˆtre est d‚clar‚e CUSTOM
	; mais on ne gŠre aucun des messages de redraw
	; contrairement … le fenˆtre 1 !
	; r‚sultat : le contenu est erratique
	; int‚ressant malgr‚ tout pour voir comment fat le GEM !

	lea objet_fenetre2,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

menu_wind3:	lea objet_fenetre3,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

menu_wind4:
	; Attention cette fenˆtre a TOPABLE_STATE = -1
	; elle est donc un-untopable : jamais au second plan !
	; quand on ouvre une autre fenˆtre, elle se re-top toute seule

	lea objet_fenetre4,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

menu_wind5:	lea objet_fenetre5,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

menu_wind6:	lea objet_fenetre6,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	; si elle existe d‚j… elle ne sera pas cr‚ee

	lea objet_fenetre6,a0
	lea montexte,a1
	bsr GWVA_WTEXT_OBJ_PRG_WRITE_IN_WINDOW
	; met le texte dans la fenˆtre et l'affiche
	rts

 DATA
montexte:	dc.b "C'est nous les plus meilleurs du monde enti‚ !",0
	even
 TEXT
		*--------------------------*

menu_wind7:	lea objet_fenetre7,a0
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	tst d7
	bpl.s .no

	lea image1,a0
	move #RAM_TT_ST,d0		; TT de pr‚f‚rence sinon ST
	bsr LOAD_FILE_IN_MEM
	tst.l d0
	ble.s .no

	; Image 16 couleurs
	; on charge un fichier avec l'image au format ‚cran en premier
	; taille : 640*480 * 4 bits
	; puis la palette : 16 couleurs = 16*32 bits

	move.l a0,a2		; adresse de chargement
	lea objet_fenetre7,a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move #640,GWVA_WBITM_OBJ_IMG_WIDTH(a1)
	move #480,GWVA_WBITM_OBJ_IMG_HEIGHT(a1)
	move #640,GWVA_WIND_OBJ_FIRST_W(a0)
	move #480,GWVA_WIND_OBJ_FIRST_H(a0)	: mise … jour des champs en direct
	move.l a2,GWVA_WBITM_OBJ_DATA_PTR(a1)
	add.l #640*480/2,a2		; taille de l'image en octets
	move.l a2,GWVA_WBITM_OBJ_PAL_PTR(a1)
	move #4,GWVA_WBITM_OBJ_NBR_BITPLANES(a1)

	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	lea objet_fenetre7,a0
	tst d7
	bmi event_window_bitmap_closed

.no:	rts

		*--------------------------*

menu_wind9:	lea objet_fenetre8,a0
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	tst d7
	bpl.s .no

	lea image2,a0
	move #RAM_TT_ST,d0		; TT de pr‚f‚rence sinon ST
	bsr LOAD_FILE_IN_MEM
	tst.l d0
	ble.s .no

	; Image TRUE-COLOR (65536 couleurs)
	; on charge un fichier avec l'image au format ‚cran en premier
	; taille : 320*240 * 16 bits
	; pas de palette !

	move.l a0,a2
	lea objet_fenetre8,a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move #320,GWVA_WBITM_OBJ_IMG_WIDTH(a1)
	move #240,GWVA_WBITM_OBJ_IMG_HEIGHT(a1)
	move.l a2,GWVA_WBITM_OBJ_DATA_PTR(a1)
	move #16,GWVA_WBITM_OBJ_NBR_BITPLANES(a1)
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	lea objet_fenetre8,a0
	tst d7
	bmi.s event_window_bitmap_closed

.no:	rts

		*--------------------------*

menu_wind8:	lea objet_fenetre9,a0
	bsr GWVA_WIND_OBJ_PRG_TEST_IF_WIND_CREATED
	tst d7
	bpl.s .no

	lea image3,a0
	move #RAM_TT_ST,d0		; TT de pr‚f‚rence sinon ST
	bsr LOAD_FILE_IN_MEM
	tst.l d0
	ble.s .no

	; Image 256 couleurs
	; on charge un fichier avec l'image au format ‚cran en premier
	; taille : 320*240 * 8 bits
	; puis la palette : 256 couleurs = 256*32 bits

	move.l a0,a2
	lea objet_fenetre9,a0
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	move #320,GWVA_WBITM_OBJ_IMG_WIDTH(a1)
	move #240,GWVA_WBITM_OBJ_IMG_HEIGHT(a1)
	move.l a2,GWVA_WBITM_OBJ_DATA_PTR(a1)
	add.l #320*240,a2
	move.l a2,GWVA_WBITM_OBJ_PAL_PTR(a1)
	move #8,GWVA_WBITM_OBJ_NBR_BITPLANES(a1)
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	lea objet_fenetre9,a0
	tst d7
	bmi.s event_window_bitmap_closed

.no:	rts

		*--------------------------*

event_window_bitmap_closed:
	; Il n'y a qu'un seul malloc pour l'image et la palette
	; donc on ne fait qu'une lib‚ration

	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	move.l GWVA_WIND_OBJ_SPEC_PTR(a0),a1
	MFREE GWVA_WBITM_OBJ_DATA_PTR(a1)
	rts

event_window_bitmap_fulled:
	; sur cette fenˆtre on veut faire un traitement particulier :
	; un ALT+fenˆtre FULL donne une namification (action sp‚cifique V.A)
	; on demande donc … ˆtre averti des EVNT_WIND_FULL avant leur traitement
	; (pour l'annuler) et on teste ici l'‚tat des touches sp‚ciales qui sont
	; dans GWVA_APP_OBJ_EVNT_MULTI_KS

	move GWVA_APP_OBJ_EVNT_MULTI_KS,d0
	and.w #%1000,d0			; touche ALT enfon‡‚e ?
	beq.s .pas_alt

	bsr GWVA_WIND_OBJ_PRG_NAMIFY_UNAMIFY_ONE_WIND	; a0=ptr
	; c'est une fonction flip / flop

	moveq #-1,d7
	; bien sur il ne faut pas faire de FULL de la fenˆtre !
	rts

.pas_alt:	clr d7
	rts

		*--------------------------*

event_window1_closed:
	; Ceci est … but didactique
	; on aurait pu le faire automatiquement en changeant les
	; propri‚t‚s de la fenˆtre ... GWVA_WIN_BIT_AUTODEL

	lea objet_fenetre1,a0
	bsr GWVA_WIND_OBJ_PRG_DELETE_ONE_WIND
	rts

event_window1_redraw:
	; Cette fenˆtre ‚tant CUSTOM la prise en charge du redraw doit ˆtre
	; faite par le programmeur.
	; les coodonn‚es sont pass‚es dans GWVA_WIND_OBJ_REDRAW_CLIP & d0-d3.w

	vswr_mode #MD_REPLACE
	vsf_color #0		; blanc
	v_bar GWVA_WIND_OBJ_REDRAW_CLIP,GWVA_WIND_OBJ_REDRAW_CLIP+2,GWVA_WIND_OBJ_REDRAW_CLIP+4,GWVA_WIND_OBJ_REDRAW_CLIP+6
	; une fenˆtre blanche pour l'exemple ...

	rts

event_window1_moved:
	clr d7	; confirmer l'ordre de mouvement de l'utilisateur ? OUI !
	rts

wind1_tool_obj1_click:
	; Ceci est … but didactique

	; on est averti que l'utilisateur a cliqu‚ un bouton de la toolbar
	; on recoit dans d0 son num‚ro

	rts

fenetre1_control_c:
	; Ceci est … but didactique

	; si on est ici c'est que CTRL+C a ‚t‚ press‚ ... on peut d‚finir ainsi
	; une liste de raccourcis et y associer facilement une action sp‚ciale.

	rts

		*--------------------------*

event_window3_created:		; WM_BEFORE !
	clr d7		; mettre -1 pour empŠcher la cr‚ation
	rts

event_window3_opened:
	; On sauve l'aspect du formulaire pour le restaurer si l'utilisateur
	; fait cancel

	save.l a0
	move #FORMULAIRE3,d0
	move #%1111,d1		; sauver l'apparence & textes
	move.l #0,a0		; r‚server un malloc !
	bsr GWVA_WFORM_OBJ_PRG_SAVE_FORM
	move.l a0,a1
	load.l a0
	tst d7
	bmi.s .erreur	; annule l'ouverture si pas pu sauver
	move.l a1,GWVA_WIND_OBJ_USER_PTR1(a0)
	clr d7
.erreur:	rts

wind3_bton_cancel_click:
	; l'utilisateur a cliqu‚ sur Cancel on remet l'apparence pr‚c‚dente !

	save.l a0
	move.l GWVA_WIND_OBJ_USER_PTR1(a0),a0
	move #FORMULAIRE3,d0
	move #%1111,d1		; restaurer l'apparence & les textes
	bsr GWVA_WFORM_OBJ_PRG_RESTORE_FORM
	load.l a0

	move #0,d0			; premier objet 0 : le pŠre
	move #7,d1			; profondeur 7
	clr d2			; l'int‚rieur
	bra GWVA_FORM_WIND_OBJ_PRG_REDRAW_PART	; bsr+rts = bra

event_window3_closed:
	; on rend le malloc o— est la sauvegarde de l'apparence du formulaire

	save.l a0
	MFREE GWVA_WIND_OBJ_USER_PTR1(a0)
	load.l a0
	clr.l GWVA_WIND_OBJ_USER_PTR1(a0)
	clr d7			; confirmer la fermeture
	rts

event_window3_redraw:
	clr d7
	rts

wind3_bton_ok_click:
	; Sur un OK dans le fenˆtre 3 on ouvre la 1 qui est sp‚ciale ...

	; on ne teste pas si elle est d‚j… ouverte, dans ce cas on nous
	; renerra un message d'erreur et l'action sera annul‚e.

	lea objet_fenetre1,a0
	bsr GWVA_WIND_OBJ_PRG_CREATE_OPEN_ONE_WIND
	rts

popup1_changed:
	; Ceci est … but didactique

	; on est averti que l'utilisateur a chang‚ la s‚lection du popup1
	; dans le fenˆtre 3.
	; on recoit dans d1 ... la nouvelle s‚lection

	rts

radio_bton_click:
	; Ceci est … but didactique

	; on est averti que l'utilisateur a cliqu‚ un nouveau bouton
	; dans le fenˆtre 3.
	; on recoit dans d1 ... la nouvelle s‚lection

	rts

w3_option1_unselct:
	; Ceci est … but didactique

	; on est averti que l'utilisateur a cliqu‚ sur un bouton s‚lectionnable
	; mais non exit (donc pas d'‚vŠnement CLICK) et plus sp‚cialement que ce
	; bouton vient de remonter ! cool !

	rts

		*--------------------------*

event_window6_arrowed:
	; exemple de message pas trŠs int‚ressant mais bon ... c'est possible

	rts

		*--------------------------*

	section DATA

texte:	dc.b 'Genuwax for the best : ',0

	ifnd OPT_FULL_PATHNAMES
image1:	dc.b 'start16.raw',0
	else
image1:	dc.b 'd:\assemble\visual40\start\start16.raw',0
	endc

	ifnd OPT_FULL_PATHNAMES
image2:	dc.b 'start32k.raw',0
	else
image2:	dc.b 'd:\assemble\visual40\start\start32k.raw',0
	endc

	ifnd OPT_FULL_PATHNAMES
image3:	dc.b 'start256.raw',0
	else
image3:	dc.b 'd:\assemble\visual40\start\start256.raw',0
	endc

mask:	dc.b '*.S,*.BAK',0
 even

 END
