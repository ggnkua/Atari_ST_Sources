; _________                     ______________________________________________________
;(   _____ \          ___  ___ (______________________________________________   _____)
; \ (     \ \______  (   )(   )______   ______      __   __    __  ____      /  /
;  \ \    / (  ____) / _ \/ _ (  ___ \ (   __ \    /__\ (  )  (  )(  _ \    /  /
;   ) \__/ / ) )__  / / \  / \/ (___) ) ) (__) )  /(__)\/  \  / / / / \ \  /  /
;  / __   / (  ___)/ /   \/  / ____  ( / __   /  / ____ \/\ \/ / / /  / / /  /
; / /  \  \  ) )__/_/_      / (____)  ) /  \ (  / /   /\ \ \  / / /__/ / /  /
;(__)   \  \(_________)    (_________/ /   (__)(__)  / (__)(__)(_______)/  /
;        \  \   / /              \ \(__)            / /                /  /
;        (___) (__)              (__)              (__)               /  /
;                                                                    (___)
;
;                               V 3.07 á Fr
;                               
;                  ½ -  Dbug II from NEXT
;
; DerniŠre modification le 27 juillet 1994
;

debug		equ 1
cpu_time	equ 0	C'est pour avoir les changements de couleur.
_main_part	equ 1	C'est pour que les modules plantent isol‚ment. (!)
num‚ro_version	equ $0306
sauvegarde	equ 1
taille_chemin	equ 100	Taille des chemins … m‚moriser pour l'accŠs.
maximum_image	equ 10	Nombre maximum d'images que l'on peut avoir.
nvdi_stop	equ 1	Pour le test, doit on refuser NVDI ??? (1=refuser)

 opt o+,w-
 
 bra gemdos_init
  
 dc.b "################"
 dc.b "~~~ REMBRANDT ~~"
 dc.b "Ver num 3.06á Fr"
 dc.b "  ½ 1990-1994   "
 dc.b "     Dbug II    "
 dc.b "        &       "
 dc.b "       MIT      "
 dc.b "    from NeXT   "
 dc.b "################"
 dc.b " <100% of 68030>"
 dc.b " Motorola Inside"
 dc.b "is the best way "
 dc.b "for having fun !"
 dc.b "################"
 dc.b "CONTACT ME: (Bug report or useful suggestions) at the "
 dc.b "following adress: "
 dc.b "- POINTIER Mickael - 6, rue George Sand "
 dc.b "- 49100 ANGERS - FRANCE -"
 dc.b "You can phone at a decent hour at the following number :"
 dc.b " [France prefix+] 81.88.23.22 "
 dc.b "Please, don't forget international reply coupon if you "
 dc.b "expect any answer from myself ! Cause I'm a student and "
 dc.b "I don't really like to buy stamps... Hope you'll understand. "
 dc.b "Ok, Girls'n Boys that's all for now. "
 dc.b "################"
 even
 include FICHIERS.INC\GEM_LIBS\GEMMACRO.S
 include FICHIERS.INC\GEM_LIBS\AESLIB.S
 include FICHIERS.INC\GEM_LIBS\VDILIB.S
 include FICHIERS.INC\GEM_LIBS\GEMVALUE.S
 include FICHIERS.INC\GEM_LIBS\POINTEURS.S
 include FICHIERS.INC\SYSTEME\MACROS.S

  
 TEXT
 
gemdos_init
 lea d‚but_bss,a0	Au cas o— il y aurait des vilains packeurs
 lea fin_bss,a1		ou que la m‚moire soit crade... On ne sait jamais !
.efface_bss
 clr.l (a0)+
 cmpa.l a1,a0
 blt.s .efface_bss
 
 move.l 4(sp),a5	LibŠre la m‚moire g‚n‚reusement allou‚e
 move.l a5,adresse_basepage
 lea nouvelle_pile,sp	par le GEMDOS
 move.l 12(a5),d0	TEXT
 add.l 20(a5),d0	+DATA
 add.l 28(a5),d0	+BSS
 add.l #256,d0		+PAGE DE BASE	> TAILLE TOTALE NECESSAIRE
 move.l d0,-(sp)
 move.l a5,-(sp)
 clr -(sp)
 move #$4a,-(sp)
 trap #1
 lea 12(sp),sp
  
 clr global		On efface GLOBAL[0].
 appl_init		Appelle GEM pour lui demander un identificateur
 tst global		Si GLOBAL[0] est nul, c'est que y'a pas d'AES !
 bne.s aes_install‚

 move.l message_aes_absent,-(sp)	Un petit message pour dire ce que je pense du fait
 move #9,-(sp)		de m'avoir mis dans le dossier AUTO !!!
 trap #1
 addq #6,sp
 
 move #7,-(sp)		Une attente de touche sympathique.
 trap #1
 addq #2,sp
 
 clr -(sp)		Et bye bye les amis...
 trap #1
 
aes_install‚ 
 cmp #-1,global+2	GLOBAL[1] indique par -1 que multitos est l….
 seq flag_multitos	On le m‚morise pour plus tard.
 
 cmp #-1,d0
 bne.s pas_trop_de_programmes

 move.l message_trop_programmes,-(sp)	L'AES … renvoy‚ -1, donc c'est qu'il
 move #9,-(sp)		y a trop d'applications en cours...
 trap #1
 addq #6,sp
 
 move #7,-(sp)		Une attente de touche sympathique.
 trap #1
 addq #2,sp
 
 clr -(sp)		Et bye bye les amis...
 trap #1
 
pas_trop_de_programmes
 move d0,ap_id    	et sauvegarde le num‚ro d'identification
 
 graf_handle
 move d0,current_handle

 lea intin,a0
 moveq #10-1,d0
.remplissage
 move #1,(a0)+
 dbra d0,.remplissage
 move #2,(a0)+			Utilisation du mode RasterCoordinate

 v_opnvwk
 move intout+13*2,d0		Combien de couleurs disponibles ???
 cmp #16,d0			Moins de 16 ???
 slt flag_transformation	Alors, il faut changer la ressource !
 
 wind_get #0,#4			Sauvegarde les coordonn‚es de l'‚cran systŠme
 move int_out+2,x_‚cran		C'est utile pour redemander un retra‡age total
 move int_out+4,y_‚cran 	de la zone de travail lorsque l'on revient sous
 move int_out+6,l_‚cran 	GEM.
 move int_out+8,h_‚cran

 graf_mouse #2		Une abeille pendant qu'on travaille !!!
 v_show_c #0
   
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%%                                                %%
;%%  Relocation du fichier Ressource REMBRAND.RSC  %%
;%%                                                %%
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 bsr charge_ressource			Relocation
 bsr initialise_ressource		Calcule les pointeurs d'arbres
 bsr transforme_formulaire		Recoloriage
****	Pour d‚bogage seulement !!!
**** bra quitte_programme	
****

 clr langue				Force le mode ANGLAIS...

 bsr teste_machine			Si on revient avec une valeur
 bne quitte_programme			n‚gative, on quitte.

 bsr r‚serve_m‚moire_globale		R‚servation m‚moire globale
 beq.s .r‚servation_effectu‚e
 boite_alerte #1,#alert_m‚moire_insuffisante
 bra quitte_programme
.r‚servation_effectu‚e

 bsr.l sauve_dta_systŠme
 
 ifeq debug
   bsr.l m‚morise_chemin_rembrandt
 endc
 bsr charge_param‚trage_image
  
 bsr.l charge_drivers_rim
 move nombre_drivers_internes,d0
 add nombre_drivers_rim,d0
 move d0,nombre_drivers			Nombre total de drivers

 bsr initialise_matrice			Pour les outils

 bsr teste_moniteur

 bsr pr‚pare_buffer_image

get_table
 pea -1.w				M‚morise l'adresse de r‚f‚rence
 pea -1.w				des tables clavier, pour la
 pea -1.w				routine de gestion EVNT_KEYBOARD.
 move #16,-(sp)
 trap #14
 lea 14(sp),sp
 move.l d0,a0
 movem.l (a0)+,d0-d2
 movem.l d0-d2,tables_clavier

 bsr prepare_‚cran

 sf flag_chang‚e		Aucune modification de faite
 st flag_scrolling		Scrolling autoris‚
 
 move.l #buffer_zoomer+4,d0
 and.b #252,d0
 move.l d0,adresse_zoomer
 
 move #5<<11+5<<5+5,couleur_grille
 move #63488,couleur		En th‚orie, c'est un beau rouge !
 move #50,r_cercle		Rayon des cercles par d‚faut
 move #50,r_a‚rosol 		Rayon de l'a‚rosol par d‚faut

 clr vitesse_souris

 st flag_calcule_zoomer
 move #100,position_hbl
    
 graf_mouse #0		Le boulot est termin‚, on peut commencer
 v_show_c #0		les choses s‚rieuses !!!


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                              %
;% Initialisation, et cr‚ation d'un menu hi‚rarchique.		%
;%                                                              %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 lea menu_menudef,a0			Adresse de la structure MENU
 move.l ptr_hierarchique,menu_tree(a0)	Attache au menu principal !
 move #objet_back_langue,menu_menu(a0)	Objet parent=1
 move #1,menu_item(a0)			Menu de d‚part=1
 move #0,menu_scroll(a0)		Pas de scrolling
 menu_attach #1,ptr_menu_accessoires,#objet_menu_langage,#menu_menudef

 menu_istart #1,ptr_hierarchique,#0,#1

****

 lea menu_menudef,a0			Adresse de la structure MENU
 move.l ptr_hierarchique,menu_tree(a0)	Attache au menu principal !
 move #objet_back_chemins,menu_menu(a0)	Objet parent=1
 move #1,menu_item(a0)			Menu de d‚part=1
 move #0,menu_scroll(a0)		Pas de scrolling
 menu_attach #1,ptr_menu_accessoires,#objet_menu_chemins,#menu_menudef

 menu_istart #1,ptr_hierarchique,#0,#1


 lea menu_values,a0		Adresse de la structure MN_SET
 move.l #50,values_display(a0)	D‚lai avant que le sous-menu soit affich‚
 clr.l values_drag(a0)		D‚lai avant disparition du sous-menu
 move.l #100,values_delay(a0)	D‚lai avant que le scroll commence (1ø clic sur une flŠche) */
 clr.l values_speed(a0)		D‚lai entre chaque scroll
 move #5,values_height(a0)	Hauteur du sous-menu en nbre d'options
 menu_settings #1,#menu_values

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                              %
;% Initialisation, cr‚ation, affichage de la fenetre et du menu %
;% d‚roulant.                                                   %
;%                                                              %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*
* Le but, ouvrir une fenetre !
* NB: intin/intout/ptsin... -> VDI
*     int_in/int_out...     -> AES... Pas confondre !
*
type_fenetre=win_name+win_closer+win_mover+win_info
 form_center ptr_page_principale			Calcule la fenetre selon la
 move.l ptr_page_principale,a0				taille de notre formulaire !
 wind_calc #0,#type_fenetre,ob_x(a0),ob_y(a0),ob_l(a0),ob_h(a0)
 move.l int_out+2,x_fen					M‚morise la taille de la fenetre.
 move.l int_out+6,l_fen
 
 movem x_fen,d0-d3					Reprend les tailles de la fenetre
 wind_create #type_fenetre,x_fen,y_fen,l_fen,h_fen	Cr‚ation de la fenetre
 move d0,handle_fen					M‚morise le handle de la fenetre

 move.l	#titre_fenetre,int_in+4				Adresse de la chaine de caractŠres.
 wind_set handle_fen,#2					Modifie le titre

 move.l	#infos_fenetre,int_in+4				Adresse de la chaine de caractŠres.
 wind_set handle_fen,#3					Modifie le titre

 bsr compose_infos_fenetre				Inscrit les infos concernant l'image

 wind_open handle_fen,x_fen,y_fen,l_fen,h_fen		Ouvre la fenetre sur l'‚cran !

 menu_bar ptr_menu_accessoires,#1			Affiche la barre de menu

;@@
;@@ L…, c'est LA BOUCLE PRINCIPALE de Rembrandt. C'est un gros appel
;@@ EVNT_MULTI qui gŠre les messages, le clavier, la souris. Donc, on
;@@ attend. C'est 100% compatible MultiTos !
;@@

attend_‚venement
 sf flag_quitter_programme
 evnt_multi #%010011,#2,#1,#1,,,,,,,,,,,#buffer_message
 move int_out,d0

 btst #0,d0
 beq.s .pas_‚venement_clavier 
 movem.l d0-a6,-(sp)
 bsr ‚venement_clavier
 movem.l (sp)+,d0-a6
.pas_‚venement_clavier 

 btst #1,d0
 beq.s .pas_‚venement_souris
 movem.l d0-a6,-(sp)
 bsr ‚venement_souris
 movem.l (sp)+,d0-a6
.pas_‚venement_souris

 btst #4,d0
 beq.s .pas_‚venement_message
 movem.l d0-a6,-(sp)
 bsr ‚venement_message
 movem.l (sp)+,d0-a6
.pas_‚venement_message

 tst.b flag_traduction
 beq.s .pas_traduction
 bsr traduit_ressources
.pas_traduction

 tst.b flag_quitter_programme
 beq attend_‚venement


fin_du_programme
 tst.b flag_sauv‚e			Si l'image n'a pas ‚t‚ modifi‚e
 bne.s quitte_normal			(flag=-1), pas de message

quitte_sauve
 boite_alerte #3,#alert_fin_programme_sauve
 cmp #2,int_out				[Annuler]
 beq attend_‚venement
 cmp #1,int_out
 beq.s termin‚
.sauve_image
 bsr.l sauve_image			Si on ne sauve pas finalement,
 tst.b flag_sauv‚e			on repose la question !
 bne.s termin‚
 bra.s quitte_sauve
 
quitte_normal
 boite_alerte #1,#alert_fin_programme
 cmp #2,int_out				[Annuler]
 beq attend_‚venement

termin‚
 wind_close handle_fen			On ferme les fenetres...
 wind_delete handle_fen			Et on les d‚truit !
 menu_bar ptr_menu_accessoires,#0	Efface la barre de menu
 lea adresse_drivers_rim,a0		et on libŠre la m‚moire r‚serv‚e pour les RIM.
 bsr.l libŠre_bloc
 bsr.l restore_dta_systŠme
quitte_programme
 graf_mouse #0
 rsrc_free
 v_clsvwk
 appl_exit
 clr -(a7)
 move #$4c,-(a7)
 trap #1



‚venement_clavier
 move int_out+8,d7		Touches sp‚ciales
 move int_out+10,d6		SCAN+ASCII
 lsr #8,d6
 move d6,code_scan		Un scan code VALIDE
 move.l table_normale,a0	+Une table des touches
 move.b (a0,d6.w),d0		=Un code ASCII correct ! C'est simple non ?
 move d0,code_ascii

 bsr force_majuscule
  
 lea on_gosub_event_list,a0	Liste de correspondance events...
.cherche_suivant
 move.l on_gosub_routine(a0),a1
 cmp.l #0,a1
 beq.s .recherche_termin‚e	Si routine=0 -> Fin de la liste.
 move on_gosub_special(a0),d1	Masque de la touche special (Alternate...)
 move on_gosub_touche(a0),d2	Code ASCII de la touche ('E','A',...)
 move on_gosub_scan(a0),d3	Code SCAN de la touche
 lea on_gosub_longueur(a0),a0
 eor d7,d1			Compare le masque
 bne.s .cherche_suivant 
 tst d3
 beq.s .teste_ascii
 cmp d6,d3
 beq.s .touche_ok
 bne.s .cherche_suivant
.teste_ascii 
 tst d2
 beq.s .cherche_suivant
 cmp d0,d2			Compare le code ASCII
 bne .cherche_suivant  
.touche_ok
 jsr (a1)
.recherche_termin‚e
 rts

 rsreset
on_gosub_routine	rs.l 1	Adresse de la routine … ex‚cuter.
on_gosub_special	rs.w 1	Code des touches sp‚ciales (1=SHIFT D,2=SHIFT G,4=CONTROL,8=ALTERNATE)
on_gosub_scan		rs.w 1	Code SCAN de la touche
on_gosub_touche		rs.w 1	Code ASCII de la touche 
on_gosub_bouton		rs.w 1	Num‚ro du bouton correspondant dans la ressource
on_gosub_menu		rs.w 1	Num‚ro du menu correspondant
on_gosub_arbre		rs.l 1	Adresse de l'arbre correspondant
on_gosub_longueur	rs.w 1

	DATA
 
on_gosub_event_list
 dc.l choix_informations
 dc.w 0,0,''			[Escape]
 dc.w -1			Pas de bouton "A PROPOS DE"
 dc.w objet_menu_a_propos_de
 dc.l ptr_menu_accessoires
 
 dc.l choix_aide
 dc.w 0,$62,0			[Help]
 dc.w -1			Pas de bouton "A PROPOS DE"
 dc.w objet_menu_a_propos_de
 dc.l ptr_menu_accessoires

 dc.l choix_quitter
 dc.w 8,0,'Q'			[Alt]+[Q]
 dc.w -1			Pas de bouton "QUITTER"
 dc.w objet_menu_quitter
 dc.l ptr_menu_accessoires

 dc.l charge_image_automatique
 dc.w 8,0,'C'			[Alt]+[C]
 dc.w objet_charger_fichier
 dc.w objet_menu_charger
 dc.l ptr_menu_accessoires


 dc.l charge_image_s‚lection
 dc.w 1+8,0,'C'			[Shift D]+[Alt]+[C]
 dc.w objet_charger_par_type
 dc.w objet_menu_charger_com
 dc.l ptr_menu_accessoires

 dc.l charge_image_s‚lection
 dc.w 2+8,0,'C'			[Shift G]+[Alt]+[C]
 dc.w objet_charger_par_type
 dc.w objet_menu_charger_com
 dc.l ptr_menu_accessoires

 dc.l charge_image_s‚lection
 dc.w 1+2+8,0,'C'		[Shift G]+[Shift D]+[Alt]+[C]
 dc.w objet_charger_par_type
 dc.w objet_menu_charger_com
 dc.l ptr_menu_accessoires

 dc.l sauve_image_directe
 dc.w 1+8,0,'S'			[Shift D]+[Alt]+[S]
 dc.w -1			Pas d'objet pour sauver directement
 dc.w objet_menu_sauver
 dc.l ptr_menu_accessoires

 dc.l sauve_image_directe
 dc.w 2+8,0,'S'			[Shift G]+[Alt]+[S]
 dc.w -1			Pas d'objet pour sauver directement
 dc.w objet_menu_sauver
 dc.l ptr_menu_accessoires

 dc.l sauve_image_directe
 dc.w 1+2+8,0,'S'		[Shift G]+[Shift D]+[Alt]+[S]
 dc.w -1			Pas d'objet pour sauver directement
 dc.w objet_menu_sauver
 dc.l ptr_menu_accessoires

 dc.l sauve_image
 dc.w 8,0,'S'			[Alt]+[S]
 dc.w objet_sauver_fichier
 dc.w objet_menu_sauver_sous
 dc.l ptr_menu_accessoires

**** Menu ®r‚glage¯

;
; Le choix de la langue...
;
 dc.l choix_langue_fran‡ais
 dc.w 0,0,0
 dc.w -1
 dc.w objet_menu_francais
 dc.l ptr_hierarchique

 dc.l choix_langue_anglais
 dc.w 0,0,0
 dc.w -1
 dc.w objet_menu_anglais
 dc.l ptr_hierarchique

 dc.l choix_langue_allemand
 dc.w 0,0,0
 dc.w -1
 dc.w objet_menu_allemand
 dc.l ptr_hierarchique

 dc.l choix_langue_espagnol
 dc.w 0,0,0
 dc.w -1
 dc.w objet_menu_espagnol
 dc.l ptr_hierarchique

 dc.l choix_langue_italien
 dc.w 0,0,0
 dc.w -1
 dc.w objet_menu_italien
 dc.l ptr_hierarchique

;
; Le choix du chemin...
;
 dc.l choix_chemin_rim
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_rim
 dc.l ptr_hierarchique

 dc.l choix_chemin_wim
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_wim
 dc.l ptr_hierarchique

 dc.l choix_chemin_ifx
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_ifx
 dc.l ptr_hierarchique

 dc.l choix_chemin_gvl
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_gvl
 dc.l ptr_hierarchique

 dc.l choix_chemin_gvs
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_gvs
 dc.l ptr_hierarchique

 dc.l choix_chemin_efms
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_efms
 dc.l ptr_hierarchique

 dc.l choix_chemin_clip
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_clip
 dc.l ptr_hierarchique

 dc.l choix_chemin_work
 dc.w 0,0,0
 dc.w -1
 dc.w objet_chemin_work
 dc.l ptr_hierarchique


;
;
;
 dc.l choix_parametre_preferences
 dc.w 4,0,'P'			[G]‚n‚ral
 dc.w -1
 dc.w objet_menu_preferences
 dc.l ptr_menu_accessoires

 dc.l affiche_m‚moire
 dc.w 4,0,'M'			[M]‚moire
 dc.w -1
 dc.w objet_menu_memoire
 dc.l ptr_menu_accessoires

 dc.l affiche_drivers
 dc.w 4,0,'D'			[D]rivers
 dc.w -1
 dc.w objet_menu_drivers
 dc.l ptr_menu_accessoires

 dc.l sauve_param‚trage_image
 dc.w 0,0,0			Pas de touche pour sauver
 dc.w -1			Pas de bouton "SAUVER PREFS"
 dc.w objet_menu_sauve_prefs
 dc.l ptr_menu_accessoires


*** Ressource principale

 dc.l module_hors_gem
 dc.w 0,0,13			[Return]
 dc.w objet_dessiner
 dc.w -1			Pas de menu "DESSINER'
 dc.l -1

 dc.l module_hors_gem
 dc.w 0,0,32			[ESPACE]
 dc.w objet_dessiner
 dc.w -1
 dc.l -1


 dc.l choix_parametre_image
 dc.w 0,0,'R'			[R]
 dc.w objet_reglage_image
 dc.w -1
 dc.l -1

 dc.l choix_informations_image
 dc.w 0,0,'I'			[I]
 dc.w objet_infos_image
 dc.w -1
 dc.l -1
 
 dc.l choix_efface_image
 dc.w 4,0,'E'			[Control]+E
 dc.w objet_effacer_image
 dc.w -1
 dc.l -1	
 
 dc.l 0
  
	TEXT

***[PIPE]***
*
* a0->Pointe sur le message buffer.
*
* Si l'on re‡oit un message diff‚rent de celui-la, on signale une erreur.
*
* 1	+0	$1234	-> Demande d'infos
* 2	+2		-> Ap Id
* 3	+4	0	-> 16 octets
* 4/5	+6	'NeXT'
* 6/7	+10	'Pipe'
*
pipe_demande_infos
 lea buffer_message,a0
 move 2(a0),id_acc		M‚morise l'APP_ID de l'accessoire
 addq #6,a0			Longueur du message (on s'en tape !)

* MOVEM.L D0-A6,-(SP)
* PEA (A0)
* MOVE #9,-(SP)
* TRAP #1
* ADDQ #6,SP
* MOVEM.L (SP)+,D0-A6

 cmp.l #'NeXT',(a0)+
 bne .message_foireux
 cmp.l #'Pipe',(a0)+
 bne .message_foireux

 form_alert #1,#alert_message_ok
 lea message_pipe,a0
 move #$1234,(a0)		Num‚ro de message
 move ap_id,2(a0)		Identificateur de Rembrandt
 move #0,4(a0)			Longueur du message
 move.l #'NeXT',6(a0)		Identificateur PIPE
 move.l #liste_routines,10(a0)	Adresse de la liste de routines Rembrandt
 appl_write id_acc,#16,a0
 rts

.message_foireux
 form_alert #1,#alert_message_foireux
 rts
 
message_pipe	ds.b 16
id_acc		ds.w 1

liste_routines
 dc.l combien_m‚moire
 dc.l r‚serve_bloc
 dc.l libŠre_bloc
 
alert_message_foireux
 dc.b "[1][R‚ception d'un message|de type inconnu.][ECHEC]",0

alert_message_ok
 dc.b "[1][R‚ception d'un message|compris.][Yeah !!!]",0
 
 even

 
 
‚venement_message
 lea buffer_message,a0
 move (a0),d0			Type du message

 cmp #$1234,d0
 beq pipe_demande_infos
 
 
 cmp #msg_menu,d0
 beq teste_menu			Choix d'un menu

 move 6(a0),d1			V‚rifie si le message concerne notre
 cmp handle_fen,d1		fenetre
 bne.s .fin_message
 cmp #msg_redraw,d0
 beq redessine_fenetre		Pour redessiner la fenetre
 cmp #msg_topped,d0
 beq s‚lectionne_fenetre	Pour repasser en premier plan
 cmp #msg_closed,d0
 beq choix_quitter		Case de fermeture
 cmp #msg_moved,d0
 beq bouge_fenetre		D‚placement de la fenetre
.fin_message
 rts



s‚lectionne_fenetre
 wind_set handle_fen,#10
 rts



choix_quitter
 st flag_quitter_programme
 rts




redessine_fenetre
 movem 8(a0),d0-d3
 movem d0-d3,x_clip

 wind_get handle_fen,#4			Dimensions int‚rieures de la fenetre
 move.l ptr_page_principale,a0
 move int_out+2,ob_x(a0)
 move int_out+4,ob_y(a0)

 wind_update #1			Bloque les REDRAW gem...

 wind_get handle_fen,#11	1er rectangle

rectangle_suivant
 movem int_out+2,d0-d3		Coordonn‚es XYLH du rectangle
 tst d2
 bne .valeur_non_nulle
 tst d3
 beq fin_rectangle

.valeur_non_nulle

rc_intersect
 move d0,d4		d4=x1+l1
 add d2,d4
 move x_clip,d5		d5=x2+l2
 add l_clip,d5
 cmp d4,d5		d4=Xmax
 bgt.s .pas_min_l
 exg d4,d5
.pas_min_l 

 move d1,d5		d5=y1+h1
 add d3,d5
 move y_clip,d6		d6=y2+h2
 add h_clip,d6
 cmp d5,d6		d5=Ymax
 bgt.s .pas_min_h
 exg d5,d6
.pas_min_h

 cmp x_clip,d0
 bge.s .pas_max_x
 move x_clip,d0		D0=Xmin
.pas_max_x

 cmp y_clip,d1
 bge.s .pas_max_y
 move y_clip,d1		D1=Ymin
.pas_max_y
  
 cmp d0,d4		Xmin,Xmax
 ble .pas_visible
 cmp d1,d5		Ymin,Ymax
 ble .pas_visible
  
 move d4,d2
 sub d0,d2
 move d5,d3
 sub d1,d3

 objc_draw ptr_page_principale,#0,#2,d0,d1,d2,d3
.pas_visible
 wind_get handle_fen,#12	Rectangle suivant...
 bra rectangle_suivant

fin_rectangle
 wind_update #0
 rts


bouge_fenetre
 move 8(a0),int_in+4		Nouveau X
 move 10(a0),int_in+6		Nouveau Y
 move 12(a0),int_in+8		Largeur identique
 move 14(a0),int_in+10		Hauteur identique
 wind_set handle_fen,#5		Change la position de la fenetre
 rts


arbre_menu	ds.l 1 

teste_menu
 move 6(a0),titre_menu
 move 8(a0),objet_exit
 move.l 10(a0),arbre_menu
 
 lea on_gosub_event_list-on_gosub_longueur,a0	Liste de correspondance events...
 move objet_exit,d0
 move.l arbre_menu,d1
.cherche_suivant
 lea on_gosub_longueur(a0),a0
 move.l on_gosub_routine(a0),a1
 cmp.l #0,a1
 beq .d‚selectionne_menu	Si routine=0 -> Fin de la liste.
 cmp.l ([on_gosub_arbre,a0]),d1	Adresse de l'arbre de menu...
 bne.s .cherche_suivant
 cmp on_gosub_menu(a0),d0	Num‚ro du menu
 bne.s .cherche_suivant 
 jsr (a1)
.d‚selectionne_menu
 menu_tnormal ptr_menu_accessoires,titre_menu,#1	D‚selectionne le menu
 rts








‚venement_souris
 move.l int_out+2,mousexy		M‚morise les coordonn‚es !
 move int_out+6,d0			L'‚tat des boutons
 cmp #2,d0
 bne.s .pas_bouton_droit
 relache
 bsr module_hors_gem
 rts
 
.pas_bouton_droit
 cmp #1,d0
 bne.s .pas_bouton_gauche
 bsr ‚venement_bouton
.pas_bouton_gauche  
 rts


‚venement_bouton
 wind_find mousex,mousey
 move int_out,d0
 cmp handle_fen,d0
 bne .fin_formulaire

.gŠre_formulaire 
 wind_get handle_fen,#4			Dimensions int‚rieures de la fenetre

 move.l ptr_page_principale,a0
 move.l int_out+2,ob_x(a0)		Positionne X & Y formulaire

 objc_find a0,#0,#2,mousex,mousey
 move int_out,objet_exit

 lea on_gosub_event_list,a0	Liste de correspondance events...
 move objet_exit,d0
.cherche_suivant
 move.l on_gosub_routine(a0),a1
 cmp.l #0,a1
 beq .fin_formulaire		Si routine=0 -> Fin de la liste.
 cmp on_gosub_bouton(a0),d0	Num‚ro du bouton correspondant
 lea on_gosub_longueur(a0),a0
 bne.s .cherche_suivant 
 pea (a1)
 objc_change ptr_page_principale,objet_exit,x_‚cran,y_‚cran,l_‚cran,h_‚cran,#1,#1	S‚lectionne l'objet
 move.l (sp)+,a1
 move objet_exit,-(sp)
 jsr (a1)
 move (sp)+,objet_exit
 objc_change ptr_page_principale,objet_exit,x_‚cran,y_‚cran,l_‚cran,h_‚cran,#0,#1	D‚selectionne l'objet
.fin_formulaire
 rts




*******************
******************** Module HORS GEM.
*******************
******************** Ce module utilise une commutation de r‚solution,
******************* et n'est donc pas compatible avec les drivers d'‚cran,
******************** MultiTos en mode prot‚g‚, et NVDI.
*******************
******************** Il faut donc tester tout cela !
*******************

module_hors_gem
 move #104,-(sp)		Dsp_Lock()
 trap #14
 addq #2,sp
 tst d0				Si 0, c'est que le DSP est disponible
 beq.s .dsp_ok
 cmp #-1,d0			Si -1, il est d‚ja occup‚
 beq.s .dsp_occup‚		Sinon, on suppose qu'il y a un problŠme !!!
 boite_alerte #1,#alert_dsp_absent
 rts
.dsp_occup‚
 boite_alerte #1,#alert_dsp_occup‚
 rts
 
.dsp_ok 
 tst type_moniteur
 bne.s .pas_monochrome
 boite_alerte #1,#alert_moniteur_monochrome
 rts
 
.pas_monochrome
 tst.b flag_multitos
 beq.s .pas_sous_multitos
 boite_alerte #1,#alert_multitos_pr‚sent
 rts
 
.pas_sous_multitos
 tst.b flag_affichage_normal
 beq.s .pas_nvdi
 move.l ptr_pas_nvdi,adresse_formulaire
 bsr affiche_formulaire
 bsr gere_formulaire
 bsr ferme_formulaire 
 rts

.pas_nvdi
 tst.b flag_image_valide	Est-ce qu'on a une image en m‚moire ?
 bne .image_ok
 boite_alerte #1,#alert_image_invalide
 rts
   
.image_ok
 lea ‚cran,a0			R‚servation m‚moire pour l'‚cran
 move.l taille_‚cran,d0
 bsr r‚serve_bloc
 beq.s .‚crans_ok		Ok, pas de problŠme m‚moire !
 boite_alerte #1,#alert_dessiner_impossible
 rts
 
.‚crans_ok
 menu_bar ptr_menu_accessoires,#0	Efface la barre de menu
 form_dial #0,#0,#0,#0,#0,x_‚cran,y_‚cran,l_‚cran,h_‚cran
 v_hide_c
 bsr colorie_curseur
 bsr passe_sous_tos

 sf flag_chang‚e
 move #$2100,sr

boucle_hors_gem
 bsr affiche_le_zoomer
* lea ‚tat_touches,a0
* tst.b (a0,$1d)
 tst.b ‚tat_touches+29
 beq.s .pas_control
 bsr r‚glage_hbl
.pas_control

 getmouse
 cmp #1,mousek
 bne.s .pas_bouton_gauche
 bsr bouton_gauche
.pas_bouton_gauche 

 cmp #2,mousek
 bne.s .pas_bouton_droit
 bsr bouton_droit
.pas_bouton_droit

 tst.b flag_touche_press‚e
 beq boucle_hors_gem
 
 getkey
 bsr force_majuscule
 cmp.b #$72,d0			ENTER ???
 beq fin_boucle_hors_gem
 cmp.b #$1c,d0			RETURN ???
 beq fin_boucle_hors_gem
 
 move code_scan,d0
 move code_ascii,d1

 lea liste_touches,a0
.cherche_suivant
 move (a0)+,d2		Scan.b + Acii.b
 beq .fin_recherche_touche
 move.l (a0)+,a1

 tst.b d2
 beq .teste_scan_code
 
.teste_ascii
 cmp.b d1,d2
 beq .ex‚cute_routine
 bne .cherche_suivant
 
.teste_scan_code
 rol #8,d2
 cmp.b d0,d2
 bne .cherche_suivant
 
.ex‚cute_routine
 jsr (a1)
 bra boucle_hors_gem

.fin_recherche_touche
 bsr v‚rifie_touche_outils
 bra boucle_hors_gem

fin_boucle_hors_gem 
 relache
 bsr recopie_‚cran
 relache
 bsr passe_sous_gem
 move #105,-(sp)		Dsp_Unlock()	On libŠre le DSP
 trap #14
 addq #2,sp
 v_show_c #0
 bsr retrace_ressource
 bsr compose_infos_fenetre	Inscrit les infos concernant l'image
 rts
 
retrace_ressource
 wind_update #1
 form_dial #3,#0,#0,#0,#0,x_‚cran,y_‚cran,l_‚cran,h_‚cran
 move #0,intin+4
 move #0,intin+6
 move #0,intin+8
 move #0,intin+10
 wind_set #0,#14
 wind_update #0
 menu_bar ptr_menu_accessoires,#1	Affiche la barre de menu
 rts


	DATA
*
* dc.b scan_code,code_ascii
* dc.l adresse_routine
*
liste_touches
 dc.b 0,'#'			#
 dc.l s‚lecteur_informations
 dc.b 0,'('			(
 dc.l commute_largeur_‚cran
 dc.b 0,')'			)
 dc.l commute_hauteur_‚cran
 dc.b 0,'/'			/
 dc.l commute_overscan_‚cran
 dc.b $0f,0			TAB
 dc.l d‚brayage_scrolling
 dc.b $62,0			HELP
 dc.l affiche_infos
 dc.b $52,0			INSERT
 dc.l change_vitesse_souris
 dc.b $47,0			CLR HOME
 dc.l change_vitesse_souris
 dc.b 0,' '			ESPACE
 dc.l s‚lecteur_de_couleur
 dc.b $61,0			UNDO
 dc.l routine_undo
 dc.b $1,0			ESCAPE
 dc.l routine_bloc
 dc.b $4b,0			
 dc.l effet_pivote_90_gauche
 dc.b $4d,0			
 dc.l effet_pivote_90_droite
 dc.b $48,0			
 dc.l effet_retourne_horizontal
 dc.b $50,0			
 dc.l effet_retourne_vertical
 dc.b $6d,0			1
 dc.l effet_assombrir
 dc.b $6e,0			2
 dc.l effet_‚claircir
 dc.b $6f,0			3
 dc.l effet_n‚gativer
 dc.b $6a,0			4
 dc.l effet_rendre_flou_horizontal
 dc.b $6b,0			5
 dc.l effet_rendre_flou_global
 dc.b $6c,0			6
 dc.l effet_transforme_gris
 dc.b $3b,0			F1
 dc.l module_loupe
 dc.b $3c,0			F2
 dc.l module_loupe
 dc.b $3d,0			F3
 dc.l module_loupe
 dc.b $3e,0			F4
 dc.l module_loupe
 dc.b $3f,0			F5
 dc.l module_loupe
 dc.b $40,0			F6
 dc.l module_loupe
 dc.b $41,0			F7
 dc.l module_loupe
 dc.b $42,0			F8
 dc.l module_loupe
 dc.b $43,0			F9
 dc.l module_loupe
 dc.b $44,0			F10
 dc.l module_loupe
 dc.l effet_transforme_gris
 dc.b 0,'*'			*
 dc.l modifie_segmentation_zoomer 
 dc.b 0,'-'			-
 dc.l diminue_zoom_zoomer
 dc.b 0,'+'			+
 dc.l augmente_zoom_zoomer
* dc.b $02,$0b			1-0
* dc.l change_couleur_clavier      
 dc.w 0
 dc.l 0


	TEXT
	 
change_couleur_clavier
 movem.l d0-a6,-(sp)
 getshift

 moveq #3,d1
 btst #3,d0		Alternate
 bne .ok_touche

 moveq #2,d1
 btst #1,d0		Shift Gauche
 bne .ok_touche

 moveq #1,d1
 btst #2,d0		Control
 bne .ok_touche

 moveq #0,d1		Aucune touche...
.ok_touche
 
 lsl #2,d1		x4
 moveq #0,d0
 move code_scan,d0
 subq #2,d0
 lsl #4,d0			Multiplie par 16 pour avoir la bonne...
 add d1,d0			+ d‚callage SHIFT...
* lea table_couleurs,a0
* move ([a0,d0.w]),couleur
 movem.l (sp)+,d0-a6
 rts
 
  
choix_efface_image
 tst.b flag_sauv‚e			Si l'image n'a pas ‚t‚ modifi‚e
 bne .efface_image			(flag=-1), pas de message
 boite_alerte #1,#alert_efface_image
 cmp #2,int_out
 beq .fin_efface_image
.efface_image
 st flag_sauv‚e				Ok, l'image est 'vierge'...
 bsr efface_image
.fin_efface_image
 rts
 
choix_informations
 move.l ptr_infos,adresse_formulaire
 clr premier_objet
 bsr affiche_formulaire
 bsr gere_formulaire
 bsr ferme_formulaire
 cmp #objet_plus_infos,objet_exit
 beq .choix_plus_informations 
 rts
.choix_plus_informations 
 move.l ptr_shareware_info,adresse_formulaire
 clr premier_objet
 bsr affiche_formulaire
 bsr gere_formulaire
 bsr ferme_formulaire
 rts

choix_aide
 boite_alerte #1,#alert_aide_demand‚e
 rts
 
;#
;# Lors du chargement d'un image, il est n‚c‚ssaire de:
;# - Initialiser les variables LARGEUR_IMAGE, HAUTEUR_IMAGE, TAILLE_IMAGE.
;# - Changer dans la ressource, les tailles affich‚es de l'image.
;#
pr‚pare_buffer_image
 movem.l d0-a6,-(sp)
 move largeur_image,d0		Maintenant, on recalcule la taille du
 mulu hauteur_image,d0		nouveau buffer pour stocker l'image.
 move.l d0,taille_image
 lea fichier,a0
 bsr r‚serve_bloc
 seq flag_image_valide 

 bsr valide_param‚trages

 st flag_sauv‚e			Ok, l'image est 'vierge'...
 movem.l (sp)+,d0-a6
 cmp.b #-1,flag_image_valide
 rts


 
 include FICHIERS.INC\SYSTEME\_FORMULA.S	Le gestionnaire de formulaires ®Hors Gem¯
 include FICHIERS.INC\SYSTEME\MEMOIRE.S		Le gestionnaire de blocs m‚moire
 include FICHIERS.INC\SYSTEME\VIDEO.S		Le gestionnaire ‚cran
 include FICHIERS.INC\SYSTEME\CLAVIER.S
 include FICHIERS.INC\SYSTEME\CURSEUR.S		L'affichage du curseur
 include FICHIERS.INC\SYSTEME\INTERRUP.S	VBL, HBL & Cie...

 include FICHIERS.INC\GEM_LIBS\RSC_INIT.S	Initialisation de la ressource
 include FICHIERS.INC\GEM_LIBS\DIALOGUE.S	Le gestionnaire de formulaires GEM

 include FICHIERS.INC\TEXTES\CHAINES.S	Les manipulation de chaines texte

 include FICHIERS.INC\PARAMS\CONFIG.S	D‚termination du type de machine
 include FICHIERS.INC\PARAMS\PARAMS.S	Gestion du fichier de param‚trage

 include FICHIERS.INC\DIALOGUE\REGLAGE.S	Ressource de r‚glage de l'image
 include FICHIERS.INC\DIALOGUE\PREFERE.S	Ressource pour le choix des pr‚f‚rences
 include FICHIERS.INC\DIALOGUE\LANGAGE.S	Ressource pour le choix du langage courant
 include FICHIERS.INC\DIALOGUE\INFOS.S		Ressource pour les infos concernant l'image
 include FICHIERS.INC\DIALOGUE\MEMOIRE.S	Ressource pour la m‚moire occup‚e par les buffers
 include FICHIERS.INC\DIALOGUE\CHEMINS.S	Ressource pour le choix des chemins d'accŠs
 include FICHIERS.INC\DIALOGUE\_PALETTE.S	Boite de s‚lection de couleur
 include FICHIERS.INC\DIALOGUE\_OUTILS.S	Boite de s‚lection d'outil
 include FICHIERS.INC\DIALOGUE\_EFFETS.S	Boite de s‚lection des effets
 include FICHIERS.INC\DIALOGUE\_PASFINI.S	Boite d'alerte !
 include FICHIERS.INC\DIALOGUE\_INFOS.S		La ligne d'info en bordure bas...

  

 
	TEXT





 



************************
*
*
*
************************

bouton_gauche
 bsr recopie_‚cran
 move type_info_outil,type_info_zoomer
 bsr cache_curseur
 opt o-
 jsr ([adresse_routine_dessin])
 opt o+
 bsr montre_curseur
 clr type_info_zoomer

 tst.b flag_chang‚e		Si l'image n'a pas ‚t‚ modifi‚e, il n'est
 beq.s .sauvegarde_inutile	pas n‚c‚ssaire d'avertir l'utilisateur que
 sf flag_sauv‚e			son image risque d'etre perdue s'il efface.
.sauvegarde_inutile
 rts

;@
;@ Le bouton droit:
;@ - Si le click bouton droit est prolong‚, on passe en mode de capture de
;@   couleur.
;@ - Si le click bouton droit est bref, cela fait apparaitre le menu de
;@   s‚lection des outils. Yeahhh... C'est l'id‚e g‚niale.
;@
bouton_droit
 moveq #10,d0			10 Vbl... Est'ce suffisant ???
.attend_bouton
 bsr vsync
 bsr.l affiche_le_zoomer
 getmouse			Lecture de la souris
 tst mousek
 beq .validation_outils
 dbra d0,.attend_bouton

.capture_couleur
 bsr vsync
 bsr.l affiche_le_zoomer
 move.l ‚cran,a0
 move mousex,d0
 lea (a0,d0*2),a0
 move mousey,d0
 mulu largeur_‚cran,d0
 move (a0,d0.l),couleur
;
 move couleur,d‚f_infos_couleur_1_rvb
 move #16<<11+31<<5+16,d‚f_infos_couleur_2_rvb
 move #16<<11+31<<5+16,d‚f_infos_couleur_3_rvb
 bsr r‚affiche_cases_couleur
;
 bsr colorie_curseur
 getmouse
 cmp #2,mousek
 beq .capture_couleur
 cmp #3,mousek
 beq .mode_d‚grad‚
 rts

.mode_d‚grad‚
 move couleur,sauve_couleur

.capture_d‚grad‚
 bsr vsync
 bsr.l affiche_le_zoomer
 move.l ‚cran,a0
 move mousex,d0
 lea (a0,d0*2),a0
 move mousey,d0
 mulu largeur_‚cran,d0
 move (a0,d0.l),d3
;
 move d3,d‚f_infos_couleur_2_rvb
;
 move sauve_couleur,d0	Ancienne couleur de r‚f‚rence...
 move d0,d2
 and #%11111,d2		D2=bleu
 move d0,d1
 lsr #5,d1
 and #%111111,d1	D1=vert
 rol #5,d0
 and #%11111,d0		D0=rouge

 move d3,d5		La nouvelle teinte … m‚langer...
 and #%11111,d5		D2=bleu
 move d3,d4
 lsr #5,d4
 and #%111111,d4	D1=vert
 rol #5,d3
 and #%11111,d3		D0=rouge

 add d3,d0
 lsr d0
 add d4,d1
 lsr d1
 add d5,d2
 lsr d2
 
 ror #5,d0
 lsl #5,d1
 or d1,d0
 or d2,d0
   
 move d0,couleur
;
 move d0,d‚f_infos_couleur_3_rvb
 bsr r‚affiche_cases_couleur
;
 bsr colorie_curseur
 getmouse
 cmp #3,mousek
 beq .capture_d‚grad‚
 cmp #2,mousek
 beq .capture_couleur

 move couleur,d‚f_infos_couleur_1_rvb
 move #16<<11+31<<5+16,d‚f_infos_couleur_2_rvb
 move #16<<11+31<<5+16,d‚f_infos_couleur_3_rvb
 bsr r‚affiche_cases_couleur

 relache			Attend que l'on ai relach‚ le bouton.
 rts
  
.validation_outils 
 bsr module_choisie_outils 
 rts

sauve_couleur	ds.w 1


;
; On attend un mouvement de la souris, mais on
; affiche aussi le ZOOMER entre temps...
;
attend_mouvement
 move.l d7,-(sp)
 move.l d0,-(sp)
 move.l xy1,d7
.attend_mouvement
 bsr affiche_le_zoomer
 getshift
 tst d0
 bne .fin_attente
 getmouse
* force_int‚rieur
 tst mousek
 bne .fin_attente 
 cmp.l mousexy,d7
 beq .attend_mouvement
.fin_attente
 move.l (sp)+,d0
 move.l (sp)+,d7
 rts



affiche_image
 move.l fichier,a0
 move.l ‚cran,a1

 move hauteur_image,d1
 subq #1,d1

 move largeur_image,d2
 lsr d2
 subq #1,d2
 
.recopie_image_y
 move.l a0,a2
 move.l a1,a3
 add largeur_image,a0
 add largeur_‚cran,a1
 move d2,d0
.recopie_image_x
 move (a2)+,(a3)+
 dbra d0,.recopie_image_x
 dbra d1,.recopie_image_y
 rts
 
recopie_‚cran
 tst.b flag_chang‚e		Si l'image n'a pas ‚t‚ modifi‚e, pas … recopier !
 bne.s .continue_recopie
 rts 
.continue_recopie 
 move.l ‚cran,a0
 move.l fichier,a1
 
 move hauteur_image,d1
 subq #1,d1

 move largeur_image,d2
 lsr d2
 subq #1,d2
 
.recopie_image_y
 move.l a0,a2
 move.l a1,a3
 add largeur_‚cran,a0
 add largeur_image,a1
 move d2,d0
.recopie_image_x
 move (a2)+,(a3)+
 dbra d0,.recopie_image_x
 dbra d1,.recopie_image_y
 rts
 


routine_undo
 tst.b flag_chang‚e
 bne.s .continue_undo
 rts

********************* Intervertir l'‚cran avec l'image en m‚moire...
 
.continue_undo
 bsr cache_zoomer_s‚lecteur
 bsr vsync

 move.l ‚cran,a0
 move.l fichier,a1
  
 move hauteur_image,d1
 subq #1,d1

 move largeur_image,d2
 lsr d2
 subq #1,d2
 
.recopie_image_y
 move.l a0,a2
 move.l a1,a3
 move d2,d0
.recopie_image_x
 move (a3),d7
 move (a2),(a3)+
 move d7,(a2)+
 dbra d0,.recopie_image_x
 add largeur_‚cran,a0
 add largeur_image,a1
 dbra d1,.recopie_image_y
 
 bsr montre_zoomer_s‚lecteur
 rts



attend_touche
 bsr vide_clavier
 clr code_scan
 tst.b flag_touche_press‚e
 bne.s fin_attente
 getmouse
 tst mousek
 bne.s fin_attente
 bra.s attend_touche
fin_attente
 rts

force_majuscule
 move d0,-(sp)
 move code_ascii,d0
 cmp2.b limites_alphabet,d0
 bcs.s .pas_minuscule
 sub #32,code_ascii
.pas_minuscule
 move (sp)+,d0
 rts

 DATA
 
limites_alphabet	dc.b 'az'

 TEXT
   
vsync
 tst.b flag_sous_tos
 beq.s .vsync_gem
.vsync_tos
 sf flag_vsync
.wait_synchro
 tst.b flag_vsync
 beq.s .wait_synchro 
 rts
 
.vsync_gem 
 movem.l d0-a6,-(sp)
 move #37,-(sp)
 trap #14
 addq #2,sp
 movem.l (sp)+,d0-a6
 rts

tempo
 bsr vsync
 dbra d0,tempo
 rts

prepare_‚cran
 move #2,-(sp)
 trap #14
 addq #2,sp
 move.l d0,sauve_physique

 move #3,-(sp)
 trap #14
 addq #2,sp
 move.l d0,sauve_logique

 move #4,-(sp)
 trap #14
 addq #2,sp
 move d0,sauve_st_rez

 move #-1,-(sp)
 move #88,-(sp)
 trap #14
 addq #4,sp
 move d0,sauve_falcon_rez
 btst #7,d0
 bne.s .mode_video_falcon
 move #3,sauve_st_rez		M‚thode douteuse, mais bon !!!
.mode_video_falcon
 rts
 
efface_image
 lea fichier,a0
 bsr efface_bloc
 rts

superviseur
 clr.l -(sp)
 move #$20,-(sp)
 trap #1
 addq #6,sp
 move.l d0,sauve_pile
 move.b $484.w,sauve_484
 clr.b $484.w
 movec cacr,d0
 move d0,sauve_cacr
 move.l $ffff9800.w,sauve_9800
 move $ffff820e.w,sauve_linewidth
 rts

utilisateur
 move.l sauve_9800,$ffff9800.w
 move.b sauve_484,$484.w
 move sauve_cacr,d0
 movec d0,cacr
 move sauve_linewidth,$ffff820e.w
 move.l sauve_pile,-(sp)
 move #$20,-(sp)
 trap #1
 addq #6,sp
 rts

passe_sous_tos
 bsr vsync
 bsr superviseur
 bsr commute_r‚solution
 sf flag_souris_libre
 bsr installe_souris_absolu
 bsr vsync
 bsr fuck_hbl
 bsr cache_curseur		D‚sactive la gestion en VBL du curseur
 bsr installe_interruptions
 bsr vsync
 bsr teste_hbl_hard
 bsr vsync
 bsr vsync
 bsr vsync
 clr.l $ffff9800.w		Met le cadre en noir
 bsr affiche_image		Affiche l'image … l'‚cran
 bsr initialise_zoomer
 bsr montre_curseur		R‚active la gestion VBL du curseur
 sf flag_affiche_zoomer		D‚sactive la loupe temps r‚el...
 rts

passe_sous_gem
 bsr cache_curseur		D‚sactive la gestion en VBL du curseur

 sf flag_affiche_zoomer
 bsr restaure_interruptions

 bsr vsync
 bsr vsync
 bsr vsync
  
 bsr utilisateur

 bsr installe_souris_relative

 move sauve_falcon_rez,-(sp)
 move sauve_st_rez,-(sp)
 move.l sauve_physique,-(sp)
 move.l sauve_logique,-(sp)
 move #5,-(sp)
 trap #14
 lea 14(sp),sp

 bsr vsync
 bsr vsync
 bsr vsync
 lea ‚cran,a0			LibŠre la m‚moire prise pour l'‚cran
 bsr libŠre_bloc
 rts


  
installe_interruptions
 bsr vsync
 move sr,-(sp)
 move #$2700,sr
 move.l $68.w,sauve_68
 move.l $70.w,sauve_70

 lea routines_patch‚es,a0	On m‚morise les vecteurs MFP, pour y intercaller
 lea sauve_mfp_rout,a1		une routine destin‚e … r‚abaisser leur niveau
 lea $100.w,a2			d'IPL.
 moveq #16-1,d7
.patche_mfp_rout
 move.l (a2),(a1)+		M‚morise l'ancien vecteur MFP
 move.l a0,(a2)+		Met notre routine a la place
 lea taille_patche(a0),a0	Saute … la routine suivante 
 dbra d7,.patche_mfp_rout

 move.l #routine_vbl,$70.w
 move.l #routine_hbl_hard,$68.w
 move.l #routine_clavier,$118.w
 move.l #routine_hbl_1,$120.w
 move.b $fffffa07.w,sauve_iera
 move.b $fffffa09.w,sauve_ierb
 move.b $fffffa13.w,sauve_imra
 move.b $fffffa15.w,sauve_imrb
 move.b $fffffa17.w,sauve_vr
 move.b $fffffa1b.w,sauve_tbcr
 move.b $fffffa21.w,sauve_tbdr
 bset #0,$fffffa07.w
 bset #0,$fffffa13.w
 st flag_sous_tos
 move (sp)+,sr
 bsr vsync
 rts




restaure_interruptions
 bsr vsync
 move sr,-(sp)
 move #$2700,sr
 move.l sauve_70,$70.w
 move.l sauve_68,$68.w

 lea sauve_mfp_rout,a0		Restaure toutes les interruptions du MFP de
 lea $100.w,a1			maniere … ce qu'elles travaillent a leur niveau
 moveq #16-1,d7			IPL originel.
.restaure_mfp_rout
 move.l (a0)+,(a1)+
 dbra d7,.restaure_mfp_rout

 move.b sauve_iera,$fffffa07.w
 move.b sauve_ierb,$fffffa09.w
 move.b sauve_imra,$fffffa13.w
 move.b sauve_imrb,$fffffa15.w
 move.b sauve_vr,$fffffa17.w
 move.b sauve_tbcr,$fffffa1b.w
 move.b sauve_tbdr,$fffffa21.w
 sf flag_sous_tos
 move (sp)+,sr
 bsr vsync
 rts


vide_clavier      
 rts
* movem.l d0-a6,-(sp)
*boucle_vide_clavier
* move #2,-(sp)
* move #1,-(sp)
* trap #13
* addq #4,sp
* tst d0
* beq.s fin_vidage_clavier
* move #2,-(sp)
* move #2,-(sp)
* trap #13
* addq #4,sp
* bra.s boucle_vide_clavier
*fin_vidage_clavier
* movem.l (sp)+,d0-a6
 rts

 include FICHIERS.INC\GRAPHICS\ZOOMER.S		Le zoomer temps r‚el
 include FICHIERS.INC\GRAPHICS\LOUPE.S		La loupe Degas/CrackArt
 include FICHIERS.INC\GRAPHICS\EFFETS.S		Les effets applicables sur l'image
 include FICHIERS.INC\GRAPHICS\LIGNE.S		Les primitives graphique pour les lignes
 include FICHIERS.INC\GRAPHICS\POLYFILL.S	Gestion de la table MiniMax & Cie.

 include FICHIERS.INC\OUTILS\CRAYON.S 
 include FICHIERS.INC\OUTILS\REGLE.S
 include FICHIERS.INC\OUTILS\EQUERRE.S
 include FICHIERS.INC\OUTILS\ROTATION.S
 include FICHIERS.INC\OUTILS\GOMME.S
 include FICHIERS.INC\OUTILS\PEINTURE.S
 include FICHIERS.INC\OUTILS\EFFETS.S
 include FICHIERS.INC\OUTILS\COMPAS.S
 include FICHIERS.INC\OUTILS\AEROSOL.S
 include FICHIERS.INC\OUTILS\BLOCS.S

 include FICHIERS.INC\DISQUE\__DRIVER.S		Les op‚rations disque
    
 section DATA

adresse_curseur			dc.l curseur_crayon_dessin

curseur_sablier			incbin fichiers.inc\curseurs\sablier.tru

curseur_crayon_dessin		incbin fichiers.inc\curseurs\crayon.tru
curseur_peinture_remplissage	incbin fichiers.inc\curseurs\filler.tru
curseur_rŠgle_ligne
curseur_rŠgle_kligne
curseur_rŠgle_rayon		incbin fichiers.inc\curseurs\line.tru
curseur_equerre_cadre		incbin fichiers.inc\curseurs\frame.tru
curseur_equerre_boite		incbin fichiers.inc\curseurs\box.tru

curseur_compas_cercle		incbin fichiers.inc\curseurs\cercle.tru
curseur_compas_disque		incbin fichiers.inc\curseurs\disque.tru

curseur_a‚rosol_spray_1
curseur_a‚rosol_spray_2		incbin fichiers.inc\curseurs\aerosol.tru

curseur_gomme_fine
curseur_gomme_moyenne
curseur_rotation_90gauche
curseur_rotation_90droite
curseur_rotation_vflip
curseur_rotation_hflip
curseur_effet_gris
curseur_effet_assombrir
curseur_effet_‚claicir
curseur_effet_n‚gatif
curseur_effet_hflou
curseur_effet_gflou
curseur_flŠche			incbin fichiers.inc\curseurs\palette.tru

curseur_tire_horizontal		incbin fichiers.inc\curseurs\h_resize.tru
curseur_tire_vertical		incbin fichiers.inc\curseurs\v_resize.tru

curseur_d‚coupe_bloc		incbin fichiers.inc\curseurs\cut_box.tru
curseur_d‚place_bloc		incbin fichiers.inc\curseurs\deplacer.tru
curseur_d‚signe_bloc		incbin fichiers.inc\curseurs\designer.tru

 even

 include FICHIERS.INC\TEXTES\TXT_DIVR.S
 include FICHIERS.INC\TEXTES\TXT_DISK.S
 include FICHIERS.INC\TEXTES\TXT_RSRC.S

 even
d‚but_bss
 section BSS

menu_menudef		ds.b menu_taille	Utilis‚ par MENU_ATTACH (structure MENU)
menu_menudata		ds.b menu_taille	Utilis‚ par MENU_ATTACH (structure MENU)
menu_values		ds.b values_taille	Utilis‚ par MENU_SET (structure MN_SET)

buffer_vide		ds.l 16	De quoi effacer 16 registres (toujours … 0)...

‚cran			ds.l 1	Descripteurs de blocs. Voir le module
fichier			ds.l 1		
			
; R‚servation m‚moire:
; Il faut pour travailler:
; - Un buffer pour stocker le fichier
; - Un ‚cran de travail
; - Un tampon pour le zoomer et la d‚coupe de bloc

l_largeur_image		ds.w 1
largeur_image		ds.w 1  Ce sont les dimensions r‚elles de
l_hauteur_image		ds.w 1
hauteur_image		ds.w 1	l'image charg‚e.
taille_image		ds.l 1	Largeur x Hauteur

anciennes_dimensions	ds.l 1	C'est en fait: [LARGEUR.w][HAUTEUR.w]

l_largeur_‚cran		ds.w 1
largeur_‚cran		ds.w 1	Ce sont les dimensions de l'‚cran virtuel qui
l_hauteur_‚cran		ds.w 1
hauteur_‚cran		ds.w 1	apparait sur les moniteur (+ les parties cach‚es)
taille_‚cran		ds.l 1	Largeur x Hauteur

largeur_maximum		ds.w 1	C'est les limite d'affichage pour le
hauteur_maximum		ds.w 1	d‚placement de mes ressource.

src_couleur		ds.w 1
src_composantes
src_rouge		ds.w 1
src_vert		ds.w 1
src_bleu		ds.w 1

dst_couleur		ds.w 1
dst_composantes
dst_rouge		ds.w 1
dst_vert		ds.w 1
dst_bleu		ds.w 1

adresse_barre		ds.l 1

inc_rouge		ds.l 1
inc_vert		ds.l 1
inc_bleu		ds.l 1

tables_clavier
table_capslock		ds.l 1
table_shift		ds.l 1
table_normale		ds.l 1

touches_mortes		ds.w 1

sauve_pile		ds.l 1
sauve_vbl 		ds.l 1
sauve_hbl 		ds.l 1
sauve_logique		ds.l 1
sauve_physique		ds.l 1
sauve_st_rez		ds.w 1 
sauve_falcon_rez	ds.w 1
masque      		ds.l 1
s_a7        		ds.l 1
sauve_68		ds.l 1
sauve_70    		ds.l 1
sauve_mfp_rout		ds.l 16		Pour toutes les routines du MFP.
sauve_iera		ds.w 1
sauve_ierb		ds.w 1
sauve_imra		ds.w 1
sauve_imrb		ds.w 1
sauve_vr		ds.w 1
sauve_tbcr		ds.w 1
sauve_tbdr		ds.w 1

sauve_484		ds.w 1
sauve_cacr		ds.w 1

offset_zoom_160		ds.l 1
offset_zoom_1  	 	ds.l 1

mousexy
mousex      		ds.w 1
mousey      		ds.w 1
mousek      		ds.w 1

vbl_mousexy
vbl_mousex		ds.w 1
vbl_mousey		ds.w 1
vbl_mousek		ds.w 1

compteur_vbl		ds.l 1

code_touche 
code_scan   		ds.w 1 
code_ascii  		ds.w 1
encre       		ds.w 1
fonds       		ds.w 1
dessin_mode 		ds.w 1
zoom        		ds.w 1
handle      		ds.w 1
modif_palette		ds.w 1
couleur			ds.w 1	Couleur utilis‚e pour l'affichage...

 even

ap_id			ds.w 1
x_‚cran			ds.w 1	Coordonn‚es de l'‚cran systŠme
y_‚cran			ds.w 1
l_‚cran			ds.w 1
h_‚cran			ds.w 1

x_fen			ds.w 1
y_fen			ds.w 1
l_fen			ds.w 1
h_fen			ds.w 1

x_clip			ds.w 1
y_clip			ds.w 1
l_clip			ds.w 1
h_clip			ds.w 1

handle_fen		ds.w 1

buffer_message		ds.b 16

x_form			ds.w 1  Coordonn‚es d'un formulaire, aprŠs
y_form			ds.w 1  centrage
l_form			ds.w 1
h_form			ds.w 1

objet_exit		ds.w 1	Num‚ro de l'objet qui a provoqu‚ la sortie.
titre_menu		ds.w 1	Num‚ro du titre du menu choisi.
adresse_formulaire	ds.l 1
premier_objet		ds.w 1

flag_sauv‚e		ds.w 1	0-> Image non sauv‚e
flag_chang‚e		ds.w 1	0-> Image non modifi‚e
flag_transformation	ds.w 1	0-> On … 16 couleurs disponibles

flag_affiche_zoomer	ds.w 1	0-> Zoomer effac‚ /1-> Zoomer affich‚
flag_calcule_zoomer	ds.w 1	0-> Zoomer inactif /1-> Zoomer actif
flag_remettre_zoomer	ds.w 1	0-> Choix d'un formulaire avec le zoomer

flag_sous_tos		ds.w 1	0-> Sous GEM / 1-> Sous TOS
flag_vsync		ds.w 1	Permet la synchronisation VBL qui met … 1

flag_shrink_box		ds.w 1	0-> Pas Shrink Box / 1-> Avec Shrink Box
flag_format_pic		ds.w 1  0-> Selon extension / 1-> Avec formulaire
flag_fileselect		ds.w 1	0-> Fileselect systŠme / 1-> Le mien...
flag_utiliser_rim	ds.w 1	0-> Formats internes / 1-> RIM Parx
flag_compacter_image	ds.w 1	0-> On ne compacte pas / 1-> on essaie...
flag_sauver_palette	ds.w 1	0-> On ne sauve pas la palette.
flag_recopier_palette	ds.w 1	0-> On conserve la palette courante...

flag_multitos		ds.w 1  0-> Monotache / 1-> Multitache
flag_cookie_jar		ds.w 1	0-> Pas de cookie jar / 1-> Ok !

flag_image_valide	ds.w 1	0-> Image est incorrecte / 1-> Ok !

flag_sens_tra‡age_x	ds.w 1	Flag (byte)

flag_quitter_programme	ds.w 1	0-> On reste / 1-> On quitte !

flag_affichage_normal	ds.w 1	0-> Pas de driver sp‚cial / 1-> Aille !

flag_souris_libre	ds.w 1	0-> Pas le droit de lire la souris !

flag_r‚solution_loupe	ds.w 1	1-> On a d‚ja calcul‚ la r‚solution loupe !

flag_d‚place_s‚lecteur	ds.w 1	1-> On peut d‚placer les s‚lecteurs... (dans l'‚cran)

flag_s‚lecteur_loupe	ds.w 1	1-> On peut d‚placer les s‚lecteurs... (dans la loupe)

flag_double_click	ds.w 1	1-> On a eu un double click en s‚lection

flag_quitte_loupe	ds.w 1	Indique aprŠs l'appuie sur une touche si on doit quitter le mode loupe.

flag_curseur		ds.w 1	Indique si le curseur est visible ou pas...

flag_traduction		ds.w 1	Indique si on … chang‚ de langage -> Il faut re-traduire...

position_hbl		ds.w 1

langue			ds.w 1  0:Fran‡ais/1:Anglais/2:Allemand/3:Espagnol/4:Italien

infos_fenetre		ds.b 150	Une chaine vide pour ‚crire la ligne d'info de la fenetre !

			ds.l 500
nouvelle_pile		ds.l 1

adresse_basepage	ds.l 1

matrice_outils		ds.b matrice_largeur*matrice_hauteur*matrice_taille

fin_bss			ds.l 1

 end

