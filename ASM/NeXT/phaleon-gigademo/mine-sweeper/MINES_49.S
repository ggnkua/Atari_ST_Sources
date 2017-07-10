 opt o+,d+,w+,ow-
;*********************************************************************
;  ****************** ROUTINES ECRITES PAR XAV *********************
;    *************************************************************
;      ******************* (Partiellement!) ********************
;
;		     #############  Mine Sweeper  #############
;
;					VERSION 1.1 du 14/06/92
;
; changement du remplissage
; version avec bord bas (dbug) et horloge
; sauvegarde et chargement de parties
; routine souris par dbug
; emulation souris avec touches curseur
; autorepeat pour touches curseur
; soundtrak et routines disques fdc par mit
;
* finale (1) pour phaleon (lancement jeu,gestion lecteurs)
finale=0
* cheat (1) pour gagner au premier drapeau
cheat=0
* acces disque en direct (1)
* chargement/sauvegarde (1)
read_score =0
write_score=0
* choix du soundtrak : auto (0), stf (1), ste (2) *
ste_auto = 0
* marquage 118: reception clavier (1)
def_debug = 0
* inactive souris pour faciliter Adebog (0).
def_souris = 1
* touche Esc active (1)
def_esc	= 1
* sauvegarde de la grille UNDO (1)
def_sauve_undo = 0
* Sortie avec appui 2 boutons (1)
def_deux_boutons_esc = 0
* position des includes
def_disque_dur = 1

ecart_scroll=2


nbr_ligne EQU 25
nbr_col   EQU 40
ligne_sup EQU 31	; valeur max = 25 -> ppcm = 32
col_sup   EQU 63	; valeur max = 40 -> ppcm = 64

;
;	REM: l'original fait 30x16 avec 99 bombes en mode 'expert'
;		(configurable jusqu'… 30x24 et 678 bombes)
;

;**********************************************************************
;**************** MACRO DIVERSES **************************************
;**********************************************************************

pause macro
 dcb.w \1,$4e71
 endm

hidem macro
 sf flag_souris
 jsr restaure_fonds_souris
 endm
 
showm macro
 tst.b flag_souris
 bne.s .deja_visible
 jsr memorise_fonds_souris
 st flag_souris
.deja_visible
 endm

v_sync macro
 move.b #0,v_sync_ind
.wait_vbl\@
 cmp.b #\1,v_sync_ind
 bne .wait_vbl\@
 endm
  
attend_plus_boutons macro
.scrute_souris
 moveq #0,d0
 move.b mousek,d0
 ifne def_deux_boutons_esc  **
 cmpi.b #3,d0
 beq fin_rapide
 endc **
 tst.b d0
 bne .scrute_souris
 endm

attend_plus_boutons_2 macro
.scrute_souris
 moveq #0,d0
 move.b mousek,d0
 tst.w d0
 bne .scrute_souris
 endm

wait_key macro
 sf touche
.\@
 tst.b touche
 beq.s .\@
 endm
;*************************************************************************
;**************** CORPS DU PROGRAMME *************************************
;*************************************************************************

 SECTION TEXT
 
 ifeq finale  **

 pea partie_principale
 move.w #$26,-(sp)		;supexec
 trap #14
 addq.w #6,sp
 clr.w -(sp)			;term
 trap #1

 elseif       **

bgt
drive_use = ($600+12+640+4) *2
 org $5000
 jsr partie_principale
 dc.l "NEXT","BACK"

 endc         **



partie_principale:

 move.w #$2700,sr

 lea sequence_absolu,a0			on connecte la souris en ABSOLU
 jsr envoie_clavier
 ifne def_souris **
 lea sequence_place_souris,a0	on positionne la souris
 jsr envoie_clavier
 endc **


 jmp efface_bss
fin_efface_bss 

 ifeq finale  **
 move #1<<1,n_drive
 elseif       **
 move drive_use,d0
 add d0,d0
 move d0,n_drive 
 endc         **

* init valeurs scroll
 clr scrollapp
 move #16+ecart_scroll,offset_scroll
 move.l #scrollb,adr_scroll

 move.l a7,sauve_ssp              piles <- (avec un s)
 move usp,a0
 move.l a0,sauve_usp
 lea pile,a7

 movem.l $ffff8240.w,d0-d7        palette
 movem.l d0-d7,sauve_palette
 move.b $ffff8260.w,sauve_8260    r‚solution
 move.b #0,$ffff8260.w
 move.b $ffff820a.w,sauve_820a    fr‚quence
 move.b #2,$ffff820a.w
 move.l #buffer_ecran+256,d0          positionne ‚crans
 sf d0					;set if condition (false donc met $00 dans d0.b)
 move.l d0,debut_ecran
 move.l d0,sauvegarde    Pour la souris, affichage initial
**
 move.l d0,d1
 add.l #198*160,d1
 lsr.l #8,d1
 move.l d1,debut_ecran_2    On ne cherche pas … comprendre... Ok ???      Adresse de base pour la synchronisation du border bas.
**
 move.l d0,d1
 add.l #32000,d1
 move.l d1,debut_bordure
 move.l d0,d1
 add.l #32000+160*12+8*1,d1
 move.l d1,debut_score
 move.l d0,d1
 add.l #32000+160*12+8*4,d1
 move.l d1,debut_face
 move.l d0,d1
 add.l #32000+160*12+8*7,d1
 move.l d1,debut_heure
 move.l d0,d1
 add.l #32000+160*10+8*12,d1
 move.l d1,debut_icone
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep.w 0(a0),d1		;charge adresse debut ecran
 move.w d1,sauve_8201
 movep.w d0,0(a0) 

 jsr predecalle_souris
 move sr,-(sp)
 move #$2700,sr
 jsr lance_border_bas
 jsr init
 move (sp)+,sr

;
; A partir de maintenant, sont actifs:
;   $70.w -> La VBL
;  $118.w -> L'interruption qui gere la souris et le clavier
;  $120.w -> La HBL pour le border bas
;
 ifne def_souris **
; move.w #160,place_x 			;place_x et place_y n'ont pas bouge
; move.w #100,place_y			;donc inutile de les re‚crire
 lea sequence_place_souris,a0	;on positionne la souris
 jsr envoie_clavier
 elseif **
 move #159,place_x
 move #219,place_y
 endc **

;             ***** INIT DES VARIABLES PROGRAMME *****
;             ****************************************
;

; ***** D'ABORD CHOIX DU NIVEAU *****
; ***********************************
; Il faut d'abord afficher la presente
; et choisir un niveau (niveau_defaut positionn‚ dans introduction)

 jsr introduction

 ifne def_souris **
 lea sequence_absolu1,a0			on connecte la souris en ABSOLU
 jsr envoie_clavier
 endc **
 

; ***** LET'S THE GAME BEGIN *****
; ***********************************
debut_partie:
 st go_horloge
 v_sync 10
 hidem
 jsr init_data

;	AFFICHE LA GRILLE DE DEPART (40x25)
;
 jsr aff_grille
 jsr aff_tableau
 jsr aff_score
 jsr aff_sourire
 jsr aff_seconde
 jsr aff_minute
 jsr aff_menu
 showm

; move #5,compteur
; move #$2300,sr

; jsr reset_shifter

 jsr sauve_partie		;pour initialiser le UNDO

 move.b #1,go_horloge
 move.b #0,touche


;             **** BOUCLE PRINCIPALE DU PROGRAMME ****
;             ****************************************
;
;	on scrute en permanence touche pour le clavier
;						 et mousek pour la souris.
;
scrute_action_joueur:
 showm
boucle_scrute_action_joueur:
 tst.b mousek
 bne bouton_souris_press‚ 
 tst.b touche
 beq boucle_scrute_action_joueur


; LE CLAVIER
;***********

 jsr test_touche
 tst.b emul_bouton		;le joueur utilise le clavier comme souris
 bne bouton_souris
 jsr actions_jeux
 jsr actions_icones	;obeit aux actions choisie dans test_touche
 tst.b on_a_touche		;esc = fin de jeu
 bne fin_rapide

 move.b niveau,d1			;1,2,3 redepart avec nouveau niveau
 cmp.b niveau_defaut,d1		;sauf si changement de niveau suite … load
 bne debut_partie

 move.b #0,touche
 bra scrute_action_joueur


; Les boutons de la souris ont ‚t‚ utilis‚s
;******************************************

bouton_souris_press‚:

 moveq #0,d0
 move.b mousek,d0

bouton_souris:

 hidem
 moveq #0,d3
 moveq #0,d4
 ifne def_souris **
 move.w mousex,d3
 move.w mousey,d4
 elseif **
 move.w place_x,d3
 move.w place_y,d4
 endc **


; Les deux boutons : on sort
 ifne def_deux_boutons_esc **
 cmpi #3,d0
 beq fin_rapide
 endc **

; respectons les limites de la decence (au pixel prŠs s'il vous plait).
 cmpi #319,d3
 bgt scrute_action_joueur
 cmpi #199,d4
 bls traite_grille

; allons voir quelle icone … ‚t‚ utilis‚e
 jsr test_menu
 jsr actions_jeux
 jsr actions_icones

 
 move.b niveau,d1			; si niveau_defaut a changer
 cmp.b niveau_defaut,d1		;alors on recommence la partie
 bne debut_partie

 tst.b on_a_touche
 bne fin_rapide
 cmp.b #6,d0			;auto_repeat si icone = change page
 beq scrute_action_joueur
 attend_plus_boutons	;pas auto_repeat
 bra scrute_action_joueur

;la souris etait sur la grille
;*****************************
traite_grille:

 lsr #3,d3
 lsr #3,d4			; adapte x et y … r‚solution de la grille

; sauvegarde la grille pour la fonction UNDO
 jsr sauve_partie


traite_bouton_gauche:		;** BOUTON GAUCHE **
 cmpi #1,d0
 bne traite_bouton_droit

; hidem				;hide mouse
 jsr aff_surprise

 lea grille_cache,a0
 lea grille_bomb,a1
 move.l d4,d0
 mulu #40,d0
 add.w d3,d0
 tst.b (a0,d0.w)
 beq traite_second_gauche	;grille_cache deja … 0 ?
 							;alors c'est un cas de recidive !

 cmpi.b #$c,(a0,d0.w)		; y a t il un drapeau ?
 beq traite_second_gauche	; oui: decouvre cases adjacentes



							;** BOUTON GAUCHE SEUL **

 tst.b (a1,d0.w)
 bne suite_bouton_gauche

							;grille_bombe … 0 (rien dessous) alors
							;	marque que maintenant on peut exploser
							;	puis remplissage				
 move.b #0,premier_appui

 movem.w d3-d4,-(sp)		;rappel: a7-a0 puis d7-d0 sur la pile
 jsr remplissage			; d3 = x et d4 = y
 add #4,sp
 jsr verif_remplissage
 jsr aff_apres_remplis
 bra fin_bouton_gauche


suite_bouton_gauche:			; Il y a quelque chose en dessous
 cmpi.b #9,(a1,d0.w)
 bne regarde_dessous
							;C'est une bombe
 cmpi.b #2,niveau			;Si le niveau est fort
 beq regarde_dessous		;on saute
 tst.b premier_appui
 bne fin_bouton_gauche		;ici on ne saute pas
							;car c'est le premier mouvement

regarde_dessous:			;attention, ca peut sauter !!!
							; sauf si premier mouvement et bon niveau
 tst.b niveau
 beq .pas_de_marque
 move.b #0,premier_appui
.pas_de_marque

 jsr calcul_adr_graph			; cas normal: decouvre la case
 jsr maj_grille

fin_bouton_gauche:
 attend_plus_boutons
 tst.b on_a_touche
 bne fin_normale
 jsr aff_sourire
 bra scrute_action_joueur


traite_second_gauche:	;** BOUTON GAUCHE POUR LA SECONDE FOIS **
;
; degage les 8 cases adjacentes (avec appel de remplissage dans maj2)
;
;		d3 & d4 contiennent (x,y)

 tst d4
 beq ligne_milieu

 subq #1,d4
 
case_haut_gauche:
 tst d3
 beq case_haut
 subq #1,d3
 jsr calcul_adr_graph
 jsr maj2_grille
 addq #1,d3
case_haut:
 jsr calcul_adr_graph
 jsr maj2_grille
case_haut_droit:
 cmpi #(nbr_col-1),d3
 beq fin_ligne_haut
 addq #1,d3
 jsr calcul_adr_graph
 jsr maj2_grille
 subq #1,d3
fin_ligne_haut:
 addq #1,d4
 
ligne_milieu:
case_gauche:
 tst d3
 beq case_droit
 subq #1,d3
 jsr calcul_adr_graph
 jsr maj2_grille
 addq #1,d3
case_droit:
 cmpi #nbr_col-1,d3
 beq ligne_bas
 addq #1,d3
 jsr calcul_adr_graph
 jsr maj2_grille
 subq #1,d3
 
 
ligne_bas:
 cmpi #(nbr_ligne-1),d4
 beq fin_bouton_gauche
 addq #1,d4
case_bas_gauche:
 tst d3
 beq case_bas
 subq #1,d3
 jsr calcul_adr_graph
 jsr maj2_grille
 addq #1,d3
case_bas:
 jsr calcul_adr_graph
 jsr maj2_grille
case_bas_droit:
 cmpi #nbr_col-1,d3
 beq fin_ligne_bas
 addq #1,d3
 jsr calcul_adr_graph
 jsr maj2_grille
 subq #1,d3
fin_ligne_bas:
 subq #1,d4

 bra fin_bouton_gauche

traite_bouton_droit:				;** BOUTON DROIT SEUL **
 cmpi #2,d0
 bne fin_rapide

; hidem		;hide mouse
 clr.l d0

 move.l d4,d2
 mulu #40,d2
 add.w d3,d2
 lea grille_cache,a0
 move.b (a0,d2),d0
 tst.b d0
 beq fin_bouton_droit		;deja decouvert? => on ne fait rien.
 
 addq.b #1,d0
 cmpi.b #$c,d0
 bne .pas_drapeau
 addq #1,nb_drapeau_mis
.pas_drapeau
 cmpi.b #$d,d0
 bne .pas_ancien_drapeau
 subi #1,nb_drapeau_mis
.pas_ancien_drapeau
 cmpi.b #$F,d0
 bne .pas_cycle
 move.b #$b,d0
.pas_cycle:

 move.b d0,(a0,d2)
 
 jsr calcul_adr_graph	;utilise d3+d4, rend a0 et d1
 jsr aff_case			;utilise a0+d0, modifie a0+a1+d0

 jsr aff_score			;re-affiche decompte des drapeaux
						;puis verifie si termin‚:  

 move nbr_bomb,d0
 cmp nb_drapeau_mis,d0
 bne fin_bouton_droit
 bsr compte_bombs

 move nbr_bomb,d0
 cmp nb_bomb_sous_drapeau,d0	;toute les bombes sont marqu‚es ?
 beq fin_normale_gagne					;(et seulement elles car en plus
										;(  nb_drapeau_mis = nbr_bomb )

*** cheat mode pour tester
 ifeq cheat **
 bra fin_normale_gagne
 endc **

fin_bouton_droit:
 attend_plus_boutons
 bra scrute_action_joueur

;       ***** FIN DU PROGRAMME *****
;		****************************
;
; Deux possibilit‚es:
;	le joueur s'est ‚clat‚e la tete (il est mort)
;	le joueur a gagn‚
; Seule difference : le smiley souris ou fait la gueule
; 
fin_normale_gagne
 sf go_horloge
 st gagne
 bra.s fin_normale1
fin_normale:
 sf gagne
fin_normale1:
 showm			;show mouse
 
 cmp.b #$ff,on_a_touche
 bne .pas_mort
 jsr aff_gasp
.pas_mort
 move.b #$ff,on_a_touche		;utilise par aff_grille

 bsr compte_bombs

 move #((nbr_ligne*nbr_col)-1),d0
 lea grille_cache,a4
efface_cache:
 clr.b (a4)+
 dbra d0,efface_cache

 hidem
 jsr aff_grille
 jsr aff_score
 clr.b go_horloge
 v_sync 60
***** * * * * * * * * * * * * * * *****
 tst.b gagne
 beq .perdu

 ifne read_score **
 v_sync 1
 move.l #rte,$120.w
 bsr verifie_disk4
* d3 nb secteur
* d4 nb piste to begin
* d5 nb secteurs to begin
 bsr eor_score
 lea easyscr,a0
 moveq #1,d3
 moveq #1,d4
 moveq #1,d5
 jsr disk_read
 bsr eor_score
 move.l #routine_hbl,$120.w
 v_sync 1
 endc **

* on voit si on a un des meilleurs scores
 moveq #0,d0
 move.b niveau,d0
 mulu #5*22,d0
 lea easyscr,a3
 add d0,a3
 lea 22*5(a3),a5
 moveq #5-1,d7
 move nb_min_horl,d0
 move nb_sec_horl,d1

.meilu
 move (a3),d2
 move 2(a3),d3
 cmp d2,d0
 bgt.s .uoi
 blt.s .pas_sec
 cmp d3,d1
 bgt.s .uoi
.pas_sec
*** demande le nom du joueur ici !!!
 bsr demande_nom
 move.l a3,a4
 tst d7
 beq.s .suoi
 subq #1,d7
.duoi
 moveq #21,d6
.doui1
 move.b -23(a5),-(a5)
 dbra d6,.doui1
 dbra d7,.duoi
.suoi
 move d0,(a4)+
 move d1,(a4)+
 lea name,a0
 moveq #17,d6
.cn
 move.b (a0)+,(a4)+
 dbra d6,.cn

 bra.s .fuoi
.uoi
 lea 22(a3),a3
 dbra d7,.meilu 
.fuoi
*
 bsr efface_screen
 lea message_gagne,a0
 moveq #0,d7
 bsr print
 bsr aff_info_fin

 ifne write_score **
 v_sync 1
 move.l #rte,$120.w
 bsr verifie_disk4
* d3 nb secteur
* d4 nb piste to begin
* d5 nb secteurs to begin
 bsr eor_score
 lea easyscr,a0
 moveq #1,d3
 moveq #1,d4
 moveq #1,d5
 jsr disk_write
 bsr eor_score
 move.l #routine_hbl,$120.w
 v_sync 1
 endc **
 bra .suite_gp



.perdu
 ifne read_score **
 v_sync 1
 move.l #rte,$120.w
 bsr verifie_disk4
* d3 nb secteur
* d4 nb piste to begin
* d5 nb secteurs to begin
 bsr eor_score
 lea easyscr,a0
 moveq #1,d3
 moveq #1,d4
 moveq #1,d5
 jsr disk_read
 bsr eor_score
 move.l #routine_hbl,$120.w
 v_sync 1
 endc **

 bsr efface_screen
 lea message_perdu,a0
 moveq #0,d7
 bsr print
 bsr aff_info_fin
.suite_gp
; MENU DE FIN
;************

 move.b #3,num_menu
 jsr aff_menu
 
 showm

scrute_fin:
 clr.b touche
 clr.b mousek
.attend_touche:
 tst.b mousek
 bne menu_fin
 tst.b touche
 beq.s .attend_touche

 jsr test_touche		;action clavier
 tst.b emul_bouton
 bne bouton_fin
 bra icone_fin

menu_fin:
 moveq #0,d0
 move.b mousek,d0
bouton_fin
 moveq #0,d3
 moveq #0,d4
 ifne def_souris **
 move.w mousex,d3
 move.w mousey,d4
 elseif **
 move.w place_x,d3
 move.w place_y,d4
 endc **

 cmpi #319,d3		;est-on … la hauteur des icones ?
 bgt scrute_fin
 cmpi #199,d4
 bls scrute_fin
 jsr test_menu

icone_fin:
 cmp.b #1,d0		;1 = load
 beq load_apres_fin
 cmp.b #4,d0		;4 = drapeau (arret)
 beq fin_rapide
 cmp.b #7,d0		;7 = croix rouge redepart complet meme niveau
 beq debut_partie
 jsr actions_icones ;5,6,9,10,11
 cmp.b #9,d0		; 9 niveau easy
 beq debut_partie
 cmp.b #10,d0		; 10 niveau cool
 beq debut_partie
 cmp.b #11,d0		; 11 niveau hard
 beq debut_partie
 bra scrute_fin

load_apres_fin:		;ici reste "load" => on recommence la partie
 move.b #0,num_menu
 v_sync 1
 hidem
 v_sync 1
 jsr remet_disk
 jsr aff_menu
 jsr aff_sourire
 showm
 v_sync 1
 jmp scrute_action_joueur

;*****************************************
; ARRET D'URGENCE : LE JOUEUR EN A MARRE
;
fin_rapide:

 move.w #$2700,sr
 hidem

 jsr arrete_border_bas

 lea sequence_retour_bureau,a0		;remet la souris en relatif
 jsr envoie_clavier

 jsr fin

 movem.l sauve_palette,d0-d7		;restaure palette initiale
 movem.l d0-d7,$ffff8240.w
 move.b sauve_8260,$ffff8260.w
 move.b sauve_820a,$ffff820a.w
 lea $ffff8201.w,a0
 move.w sauve_8201,d0
 movep.w d0,0(a0)
 move.l sauve_ssp,a7
 move.l sauve_usp,a0
 move a0,usp
 move.w #$2300,sr 
 rts
;*************************************************************************
;****************************** FIN PROGRAMME ****************************
;*************************************************************************
compte_bombs
 move nbr_bomb,d0
 move #(nbr_col*nbr_ligne),d1
 clr nb_bomb_sous_drapeau
 lea grille_cache,a0
 lea grille_bomb,a1
.compte_bomb
 subq #1,d1
 cmpi.b #9,(a1,d1.w)
 bne .compte_bomb
 subq #1,d0
 cmpi.b #$c,(a0,d1)
 bne .suite
 addq #1,nb_bomb_sous_drapeau
.suite
 tst d0
 bne .compte_bomb
 rts

verifie_disk4
 jsr sauve_ecran
* d3 nb secteur to read
* d4 nb piste to begin
* d5 nb secteur to begin
 lea secteur,a0
 moveq #1,d3
 moveq #0,d4
 moveq #1,d5
 jsr disk_read
 cmp.l #"Phal",secteur+2
 beq.s .suity
.insert
 bsr efface_screen
 lea insert4,a0
 moveq #0,d7
 bsr print
 wait_key
 bra.s verifie_disk4
.suity
 cmp #"_4",secteur+6
 bne.s .insert
 jsr remet_ecran
 rts
eor_score
 lea easyscr,a0
 moveq #$1c,d0
 move #512-1,d7
.eor
 eor.b d0,(a0)+
 addq #1,d0
 dbra d7,.eor
 rts
secteur ds.w 256
insert4
 dc.b 1,1,1,1,1,1,1,1,1,"   Please insert PHALEON disk 4",0
 even
;*************************************************************************
;********************** INIT_DATA ****************************************
;*************************************************************************
init_data:
;*********
; valeurs utilise dans les grilles (index des graphiques):
; 0 - 8 : indique les bombes … proximit‚
; 9		: c'est une bombe
; $A	: et on a marche dessus !!
; $B	: juste le cache			|
; $C	: un drapeau				|
; $D	: une croix					|
; $E	: un point d'interrogation. | (grille de cache)
; $F	: caractere remplissage auto

 clr.b on_a_touche
 move.b #1,premier_appui
 clr nb_drapeau_mis

 clr nb_sec_horl
 clr nb_min_horl
 
 clr.b num_menu

;			** gestion du niveau choisi **
 move.b niveau_defaut,niveau

 cmp.b #2,niveau
 bne .niveau_1
 move #160,nbr_bomb
 bra .fin_niveau

.niveau_1
 cmp.b #1,niveau
 bne .niveau_0
 move #130,nbr_bomb
 bra .fin_niveau

.niveau_0
 move #100,nbr_bomb
.fin_niveau

;			** mise … zero des grilles de fond et de cache **
 move #((nbr_ligne*nbr_col)-1),d0
 lea grille_bomb,a3
init_bomb:
 clr.b (a3)+
 dbra d0,init_bomb
 clr.b (a3)
 
 move #((nbr_ligne*nbr_col)-1),d0
 lea grille_cache,a4
.init_cache:
 move.b #$b,(a4)+
 dbra d0,.init_cache
 clr.b (a4)

;             ** pose les bombes dans grille_bomb **
 lea grille_bomb,a3
 moveq #0,d3
 moveq #0,d4
 move nbr_bomb,d5
 sub #1,d5

pose_bombs:			; *** debut boucle 
 move #17,-(sp)
 trap #14
 addq.l #2,sp       ; random
 andi.l #col_sup,d0
 move.b d0,d3
 cmpi.b #(nbr_col-1),d3
 bgt pose_bombs

tire_no_ligne
 move #17,-(sp)
 trap #14
 addq.l #2,sp       ; random
 andi.l #ligne_sup,d0
 move.b d0,d4
 cmpi.b #(nbr_ligne-1),d4
 bgt tire_no_ligne

					; ** traite ligne courante
 move d4,d0
 mulu #nbr_col,d0
 add.w d3,d0
 cmpi.b #9,(a3,d0)	;deja une bombe … cette endroit ??
 beq pose_bombs
 move.b #9,(a3,d0)
 
 tst d3
 beq ver_lc_droit
 cmpi.b #9,-1(a3,d0)
 beq ver_lc_droit
 addq.b #1,-1(a3,d0)

ver_lc_droit:
 cmpi #(nbr_col-1),d3
 beq verif_avant
 cmpi.b #9,1(a3,d0)
 beq verif_avant
 addq.b #1,1(a3,d0)

verif_avant:			; ** traite ligne precedente
 subi #nbr_col,d0

 tst d4
 beq verif_apres
 cmpi.b #9,(a3,d0)
 beq ver_av_gauche
 addq.b #1,(a3,d0)

ver_av_gauche: 
 tst d3
 beq ver_av_droit
 cmpi.b #9,-1(a3,d0)
 beq ver_av_droit
 addq.b #1,-1(a3,d0)

ver_av_droit:
 cmpi #(nbr_col-1),d3
 beq verif_apres
 cmpi.b #9,1(a3,d0)
 beq verif_apres
 addq.b #1,1(a3,d0)

 
verif_apres:			; ** traite ligne suivante
 addi #(nbr_col*2),d0

 cmpi #(nbr_ligne-1),d4
 beq fin_verif
 cmpi.b #9,(a3,d0)
 beq ver_ap_gauche
 addq.b #1,(a3,d0)
 
ver_ap_gauche:
 tst d3
 beq ver_ap_droit
 cmpi.b #9,-1(a3,d0)
 beq ver_ap_droit
 addq.b #1,-1(a3,d0)

ver_ap_droit:
 cmpi #(nbr_col-1),d3
 beq fin_verif
 cmpi.b #9,1(a3,d0)
 beq fin_verif
 addq.b #1,1(a3,d0)

fin_verif:
 dbra d5,pose_bombs		; *** fin boucle pose bombs !
 
 
 move.l #999,d0		;init de la couleur du border bas
 move.l debut_bordure,a0
.init_bas:
 clr.l (a0)+
 clr.l (a0)+
 dbra d0,.init_bas
 
 rts

;*************************************************************************
;********************** PROCEDURES A PART *********************************
;*************************************************************************
remplissage:
;***********
; entr‚es par la pile: X =4(sp) et Y =6(sp)
;
; En 6 phases:
;	1) la ligne courante
;	2) les lignes superieures
;	3) les lignes inferieures
;	4) verification ligne courante    ) avec appel
;	5) verification lignes sup‚rieure )	recursif
;	6) verification lignes inf‚rieure ) de "remplissage"

 lea grille_cache,a0
 lea grille_bomb,a1

 clr.l d2
 move 6(sp),d2		; calcule d2 = y*nb_col + x
 mulu #nbr_col,d2
 add 4(sp),d2

 cmpi.b #$F,(a0,d2.w)	;deja marque "!" ?
 beq fin_remplissage

remplissage_recursif:

						;*** REMPLIS LIGNE COURANTE ***
 move 6(sp),-(sp)		; c'est y
 move 6(sp),-(sp)		; c'est x (la pile a bouge)
 jsr remplissage_ligne

 addq.l #4,sp


 move 6(sp),-(sp)	;c'est y => 2(sp)
 move 6(sp),-(sp)	;c'est x => (sp)

remplis_haut:				;*** REMPLIS LIGNES SUPERIEURES ***
 tst 2(sp)
 beq fin_remplis_haut
 subq #1,2(sp)
 subi #nbr_col,d2
; cmpi.b #$F,(a0,d2.w)	;grille_cache deja marque ?
; beq fin_remplis_haut
 tst.b (a1,d2.w)		;grille_bombe(d2) = vide ?
 bne fin_remplis_haut
 jsr remplissage_ligne
 bra remplis_haut
fin_remplis_haut:

 addq.l #4,sp
 move 6(sp),-(sp)
 move 6(sp),-(sp)

 clr.l d2
 move 2(sp),d2		; recalcule d2 = y*nbr_col + x
 mulu #nbr_col,d2
 add (sp),d2
 
remplis_bas:
 cmpi #(nbr_ligne-1),2(sp)
 beq fin_remplis_bas
 addq #1,2(sp)
 addi #nbr_col,d2
; cmpi.b #$F,(a0,d2.w)	;grille_cache deja marque ?
; beq fin_remplis_bas
 tst.b (a1,d2.w)		;grille_bomb(d2) = vide ?
 bne fin_remplis_bas
 jsr remplissage_ligne
 bra remplis_bas
fin_remplis_bas:

 addq.l #4,sp

fin_remplissage:
 rts

verif_remplissage:
;******************
;
; Verification de la grille pour les branches oubli‚es
;
; attention: dans le cas d'un appel r‚cursif de remplissage,
; cet algorithme va v‚rifier une 2nde fois une partie des lignes
; d‚couverte par le premier appel.
;
.commence_verif
 move.b #0,relance_remplissage
 move #nbr_ligne-1,d1
 move #(nbr_col*nbr_ligne)-1,d2
.ligne:
 move #nbr_col-1,d0
.colonne:
 cmp.b #$F,(a0,d2.w)	;grille_cache marqu‚e ?
 bne .case_suivante
 tst.b (a1,d2.w)
 bne .case_pleine
 jsr verif_case_vide	;grille_bomb vide !
 bra .case_suivante
.case_pleine
 cmp.b #2,niveau		;grille_bomb non vide !
 beq .case_suivante		;(pas de verification si niveau fort)
 jsr verif_case_pleine
.case_suivante:
 tst.b relance_remplissage
 bne .recursion
 sub #1,d2
 dbra d0,.colonne
 dbra d1,.ligne

 rts

.recursion:
 tst.b (a1,d5.w)			;verifie grille_bomb pour la case en faute
 bne .recursion_case_pleine
 movem.w d3-d4,-(sp)
 jsr remplissage
 add #4,sp
 bra .commence_verif
.recursion_case_pleine
 movem.w d0-d1,-(sp)
 jsr remplissage_recursif
 add #4,sp
 bra .commence_verif


remplissage_ligne:
;****************
; Entree attendu:
;	a0	grille_cache
;	a1	grille_bomb
;   dans la pile: 4(sp)=x et 6(sp)=y (non modifi‚)
;	d2	(x + y*nbr_col) => UTILISE EN SORTIE (donc non modifie)
; on marque d'abord le point d'appel
; puis on marque la partie droite et la gauche
; on s'arrete quand on a marque une case non vide

 moveq #0,d1
 move 4(sp),d1	;prend X

 move.l d2,d0
 
 jsr marque_case	;c'est la case de depart du remplissage
 tst.b (a1,d0.w)
 bne fin_remplis_ligne
 
montre_droite:
 cmpi #(nbr_col-1),d1
 beq fin_montre_droite
 addq #1,d0					;d0=coord. dans le tableau
 addq #1,d1					;d1=coord. dans la ligne
 jsr marque_case
 tst.b (a1,d0.w)		;grille_bomb(d0) = 0 ?
 beq montre_droite

fin_montre_droite:

 move 4(sp),d1
 move d2,d0

montre_gauche:
 tst d1
 beq fin_montre_gauche
 subq #1,d0
 subq #1,d1
 jsr marque_case
 tst.b (a1,d0.w)		;grille_bomb(d0) = 0 ?
 beq montre_gauche

fin_montre_gauche:
fin_remplis_ligne:
 rts


marque_case:
;***********
; marque une case lors d'un remplissage (par !)
; verifie la presence des drapeaux.
; d0 est la coordonnee dans le tableau (deroule lignes par lignes)

 cmpi.b #$C,(a0,d0.w)	;grille_cache = drapeau ?
 bne .pas_drapeau
 subq #1,nb_drapeau_mis
.pas_drapeau
 move.b #$F,(a0,d0.w)

 cmp #nbr_col,d0
 bmi .pas_sup
 cmp.b #$C,-nbr_col(a0,d0.W)
 bne .pas_drapeau_sup
 subq #1,nb_drapeau_mis
.pas_drapeau_sup
 move.b #$F,-nbr_col(a0,d0.w)

.pas_sup

 cmp #(nbr_col*(nbr_ligne-1))-1,d0
 bhi .pas_sub
 cmp.b #$C,nbr_col(a0,d0.W)
 bne .pas_drapeau_sub
 subq #1,nb_drapeau_mis
.pas_drapeau_sub
 move.b #$F,nbr_col(a0,d0.w)

.pas_sub

 rts


verif_case_pleine:
;*****************
; la case … verifier n'est pas vide dans grille_bomb.
; donc seules les cases adjacentes vides peuvent etre utilis‚es.
; en fait, il faut case vide ET cache pas decouvert ET cache pas marque.
; on marque alors qu'il faut faire un appel recursif … remplissage.
; entrees non modifiables:
; d0 = x
; d1 = y
; d2 = y*nbr_col + x
; a0 = grille_cache
; a1 = grille_bomb

 move d0,d3
 move d1,d4
 move d2,d5

.colonne_milieux: 
.case_haut:
 tst d4
 beq .case_bas
 sub #1,d4
 sub #(nbr_col),d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_haut
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_haut
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_haut
 add #1,d4
 add #(nbr_col),d5
.case_bas:
 cmpi #(nbr_ligne-1),d4
 beq .fin_colonne_milieux
 add #1,d4
 add #(nbr_col),d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_bas
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_bas
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_bas

.fin_colonne_milieux:
.colonne_gauche:

 move d0,d3			;rappel : d3 = x case test‚e
 move d1,d4					  d4 = y case test‚e
 move d2,d5					  d5 = position case test‚e

 tst d3						;est-on sur la colonne 0 ?
 beq .fin_colonne_gauche	; oui => pas de colonne … gauche

 sub #1,d3
 sub #1,d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_gauche
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_gauche
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_gauche

.case_haut_gauche:
 tst d4
 beq .case_bas_gauche
 sub #1,d4
 sub #(nbr_col),d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_haut_gauche
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_haut_gauche
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_haut_gauche
 add #1,d4
 add #(nbr_col),d5

.case_bas_gauche:
 cmpi #(nbr_ligne-1),d4
 beq .fin_colonne_gauche
 add #1,d4
 add #(nbr_col),d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_bas_gauche
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_bas_gauche
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_bas_gauche

.fin_colonne_gauche:

.colonne_droite:

 move d0,d3			;rappel : d3 = x case test‚e
 move d1,d4					  d4 = y case test‚e
 move d2,d5					  d5 = position case test‚e

 cmp #(nbr_col-1),d3		;est-on sur la derniŠre colonne ?
 beq .fin_colonne_droite	; oui => pas de colonne … droite

 add #1,d3
 add #1,d5

 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_droite
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_droite
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_droite

.case_haut_droite:
 tst d4
 beq .case_bas_droite
 sub #1,d4
 sub #(nbr_col),d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_haut_droite
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_haut_droite
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_haut_droite
 add #1,d4
 add #(nbr_col),d5

.case_bas_droite:
 cmpi #(nbr_ligne-1),d4
 beq .fin_colonne_droite
 add #1,d4
 add #(nbr_col),d5
 tst.b (a1,d5.w)		;grille_bomb vide
 bne .pas_case_bas_droite
 cmp.b #$F,(a0,d5.w)	;grille_cache marqu‚ "!"
 beq .pas_case_bas_droite
 tst.b (a0,d5.w)	 	;grille_cache decouvert
 bne .appel_recursif
.pas_case_bas_droite

.fin_colonne_droite:

 rts

.appel_recursif:
 move.b #$ff,relance_remplissage
 rts


verif_case_vide:
;*****************
; la case … verifier est vide dans grille_bomb.
; donc les 8 cases adjacentes doivent etre marqu‚es.
; sinon on marque qu'il faut faire un appel recursif … remplissage.
; entrees non modifiables:
; d0 = x
; d1 = y
; d2 = y*nbr_col + x
; a0 = grille_cache
; a1 = grille_bomb

 move d0,d3
 move d1,d4
 move d2,d5

.colonne_milieux: 
.case_haut:
 tst d4
 beq .case_bas
 sub #1,d4
 sub #(nbr_col),d5
 cmp.b #$F,(a0,d5.w)
 bne .appel_recursif
 add #1,d4
 add #(nbr_col),d5
.case_bas:
 cmpi #(nbr_ligne-1),d4
 beq .fin_colonne_milieux
 add #1,d4
 add #(nbr_col),d5
 cmp.b #$F,(a0,d5.w)
 bne .appel_recursif

.fin_colonne_milieux:
.colonne_gauche:

 move d0,d3			;rappel : d3 = x case test‚e
 move d1,d4					  d4 = y case test‚e
 move d2,d5					  d5 = position case test‚e

 tst d3						;est-on sur la colonne 0 ?
 beq .fin_colonne_gauche	; oui => pas de colonne … gauche

 sub #1,d3
 sub #1,d5

 cmp.b #$F,(a0,d5.w)	;la case de gauche est-elle marqu‚e "!" ?
 bne .appel_recursif
 tst.b (a1,d5.w)
 beq .fin_colonne_gauche	;case de gauche marque mais vide ?
 							;la verification se feras la fois suivante
 							;pour la colonne de gauche

.case_haut_gauche:
 tst d4
 beq .case_bas_gauche
 sub #1,d4
 sub #(nbr_col),d5
 cmp.b #$F,(a0,d5.w)
 bne .appel_recursif
 add #1,d4
 add #(nbr_col),d5
.case_bas_gauche:
 cmpi #(nbr_ligne-1),d4
 beq .fin_colonne_gauche
 add #1,d4
 add #(nbr_col),d5
 cmp.b #$F,(a0,d5.w)
 bne .appel_recursif

.fin_colonne_gauche:

.colonne_droite:

 move d0,d3			;rappel : d3 = x case test‚e
 move d1,d4					  d4 = y case test‚e
 move d2,d5					  d5 = position case test‚e

 cmp #(nbr_col-1),d3		;est-on sur la derniŠre colonne ?
 beq .fin_colonne_droite	; oui => pas de colonne … droite

 add #1,d3
 add #1,d5

 cmp.b #$F,(a0,d5.w)	;la case de droite est-elle marqu‚e "!" ?
 bne .appel_recursif
 tst.b (a1,d5.w)
 beq .fin_colonne_droite	;case de droite marque mais vide ?
 							;la verification a deja ‚t‚ faite
 							;pour la colonne de droite

.case_haut_droite:
 tst d4
 beq .case_bas_droite
 sub #1,d4
 sub #(nbr_col),d5
 cmp.b #$F,(a0,d5.w)
 bne .appel_recursif
 add #1,d4
 add #(nbr_col),d5
.case_bas_droite:
 cmpi #(nbr_ligne-1),d4
 beq .fin_colonne_droite
 add #1,d4
 add #(nbr_col),d5
 cmp.b #$F,(a0,d5.w)
 bne .appel_recursif

.fin_colonne_droite:
 rts

.appel_recursif:
 move.b #$ff,relance_remplissage
 rts

aff_apres_remplis:
;*****************
;
; re affichage de la grille
;

 jsr aff_grille
 
 move #((nbr_ligne*nbr_col)-1),d0
 lea grille_cache,a0
demarque:
 cmpi.b #$F,(a0,d0.w)
 bne .pas_demarque
 clr.b (a0,d0.w)
.pas_demarque
 dbra d0,demarque

 jsr aff_grille
 jsr aff_score

 rts

*** routine de print ( ainsi soit il !)
gagne ds.w 1
print  *adr ds a0
 lea pfont,a2
 move.l debut_ecran,a1
 moveq #0,d1
.print
 moveq #0,d0
 move.b (a0)+,d0
 beq .fin
* effets sympas ...
 cmp.b #1,d0
 bne.s .pas_saut
 moveq #0,d1
 lea 160*10(a1),a1
 bra .print
.pas_saut
***
 lea (a2,d0.w),a5
 lea (a1,d1.w),a4
 add d7,a4
x set 0
x1 set 0
 rept 8
 move.b x(a5),x1(a4)
 move.b x(a5),x1+4(a4)
x set x+256
x1 set x1+160
 endr
 btst #0,d1
 beq.s .suite
 addq #6,d1
.suite
 addq #1,d1
 bra .print
.fin
 rts

;*************************************************************************
;***************** POUR AFFICHAGE SCORE EN BORD BAS **********************
;*************************************************************************
aff_score:
;*********
; pas d'entr‚es
; modifie d0-d2 a0-a2
 move nb_drapeau_mis,d1
 clr.l d0
 move nbr_bomb,d0
 sub d1,d0
 move.l debut_score,a0
 jsr aff_3_chiffre
 rts

aff_minute
;*********
 move nb_min_horl,d0
 move.l debut_heure,a0
 jsr aff_2_chiffre
 rts

aff_seconde
;**********
 move nb_sec_horl,d0
 move.l debut_heure,a0
 lea 16(a0),a0
 jsr aff_2_chiffre
 rts

aff_sourire
;**********
 move #$a,d0
 move.l debut_face,a0
 jsr aff_decal_char
 move #$b,d0
 move.l debut_face,a0
 addq.l #8,a0
 jsr aff_decal_char
 rts

aff_surprise
;***********
 move #$c,d0
 move.l debut_face,a0
 jsr aff_decal_char
 move #$d,d0
 move.l debut_face,a0
 addq.l #8,a0
 jsr aff_decal_char
 rts

aff_gasp
;*******
 move #$e,d0
 move.l debut_face,a0
 jsr aff_decal_char
 move #$f,d0
 move.l debut_face,a0
 addq.l #8,a0
 jsr aff_decal_char
 rts

aff_3_chiffre
;************
; provoque l'affichage sur 3 caractŠres
; utilise en entr‚e:
; a0: adresse sur ecran 1er caractere
; d0.w: nombre (0-999)
; si d0 n‚gatif shifte d'un plan pour changer de couleur

 move.l a0,a1
 move #18,d2	; 19 lignes … effacer     znort
.masque
 clr.l (a1)		; efface 4 plans pour 3 caract‚res
 clr.l 4(a1)
 clr.l 8(a1)
 clr.l 12(a1)
 clr.l 16(a1)
 clr.l 20(a1)
 add.l #160,a1
 dbra d2,.masque

 tst d0
 bgt .change_plan
* addq.l #2,a0
 neg d0
.change_plan

 clr.l d1
 and.l #$ffff,d0
 divu #100,d0
 move d0,d1				;quotient dans d1.w
 swap d0				;reste dans d0.w
 jsr aff_1_char
 addq.l #8,a0

 and.l #$ffff,d0
 divu #10,d0
 move d0,d1
 swap d0
 jsr aff_1_char
 addq.l #8,a0

 and.l #$ffff,d0
 move d0,d1
 jsr aff_1_char
 addq.l #8,a0

 rts

aff_2_chiffre
;************
; provoque l'affichage sur 2 caractŠres
; utilise en entr‚e:
; a0: adresse sur ecran 1er caractere (non modifie)
; d0.w: nombre (0-999)
; si d0 n‚gatif shifte d'un plan pour changer de couleur

* move.l a0,a1
* moveq #18,d2	; 19 lignes … effacer
*.masque
* clr.l (a1)		; efface 4 plans pour 2 caract‚res
* clr.l 4(a1)
* clr.l 8(a1)
* clr.l 12(a1)
* add.l #160,a1
* dbra d2,.masque

 clr.l d1
 and.l #$ffff,d0
 divu #10,d0
 move d0,d1				;quotient dans d1.w
 swap d0				;reste dans d0.w
 jsr aff_1_char
 addq.l #8,a0

 and.l #$ffff,d0
 move d0,d1
 jsr aff_1_char
 addq.l #8,a0

 rts

aff_1_char
;************
; affiche un caractŠre de 16x19 en 4 plans
; (chiffre 0-9 ou visage dans mines_2.dat)
;
; utilise en entree:
; a0 adresse d'affichage (au plan prŠs pour la couleur)
; d1 chiffre ou « visage … afficher (0-15)
;    0-9 chiffre
;	 a+b sourire
;	 c+d surprise
;	 e+f gasp !

 move.l a0,a2

 lea adr_graph_2,a1
 mulu #19*8,d1
 add.l d1,a1
 
 moveq #18,d2
.bouc_chif:
 move.l (a1)+,(a2)
 move.l (a1)+,4(a2)
 add.l #160,a2
 dbra d2,.bouc_chif
 rts

aff_icone:
;*********
; affiche un caractŠre de 24 lignes x 22 en 4 plans
; utilis‚ pour l'affichage d'une icone
; utilise a0 a1 d0 d1
;
; utilise en entree:
; a0 adresse d'affichage
; d0 num‚ro de l'icone
; 	0 rien
;	1 load
;	2 save
;	3 boulier
;	4 drapeau
;	5 help
;	6 change page
;	7 croix rouge
;	8 disk

 lea adr_icone,a1
 mulu #22*16,d0
 add.l d0,a1
 
 moveq #21,d1
.bouc_chif:
 move.l (a1)+,(a0)
 move.l (a1)+,4(a0)
 move.b (a1),8(a0)
 move.b 2(a1),10(a0)
 move.b 4(a1),12(a0)
 move.b 6(a1),14(a0)
 addq.l #8,a1
 add.l #160,a0
 dbra d1,.bouc_chif
 rts

aff_decal_char:
;*************
;	… cause de la position du cadre sur le tableau,
;	l'affichage du smiley (2*16 bits) se fait d‚cal‚ de 8 bits
;	Cette proc‚dure assure l'affichage de 16 bits (*4plans)
;	Mais … cheval entre deux paquets de 16 bits.
 lea adr_graph_2,a1
 mulu #19*8,d0
 add.l d0,a1

 move #18,d0
.trace_ligne
 move.b 0(a1),1(a0)
 move.b 2(a1),3(a0)
 move.b 4(a1),5(a0)
 move.b 6(a1),7(a0)
 move.b 1(a1),8(a0)
 move.b 3(a1),10(a0)
 move.b 5(a1),12(a0)
 move.b 7(a1),14(a0)
 addq.l #8,a1
 add.l #160,a0
 dbra d0,.trace_ligne
 rts

;*************************************************************************
;***************** SOUS PROGRAMMES COMMUNS *******************************
;*************************************************************************


aff_pi1
;**********
;affiche une image pi1 sur l'ecran principal
;adresse de depart dans a0.
;
 v_sync 1

 lea 2(a0),a0
 lea $ffff8240.w,a1
 rept 8
 move.l (a0)+,(a1)+
 endr

 move.l debut_ecran,a1
 move.w #(160*200)/4-1,d0
.recop
 move.l (a0)+,(a1)+
 dbra d0,.recop
 rts


aff_tableau
;**********
;affiche le tableau de bord en bas de l'ecran
;
 lea tableau+32,a0
 move.l debut_bordure,a1
 lea 160(a1),a1
 move.w #(160*40)/4-1,d0
.recop
 move.l (a0)+,(a1)+
 dbra d0,.recop
 rts


aff_menu:
;********
;affiche les quatres icones de menu

 clr.l d0
 clr.l d2
 move.b num_menu,d2
 lsl #2,d2

 lea menu_0,a2

 move.b 0(a2,d2),d0
 move.l debut_icone,a0
 jsr aff_icone

 clr d0
 move.b 1(a2,d2),d0
 move.l debut_icone,a0
 add.l #16,a0
 jsr aff_icone

 clr d0
 move.b 2(a2,d2),d0
 move.l debut_icone,a0
 add.l #32,a0
 jsr aff_icone

 clr d0
 move.b 3(a2,d2),d0
 move.l debut_icone,a0
 add.l #48,a0
 jsr aff_icone

 rts
 
aff_grille:
;**********
;				affiche l'‚cran de jeu.
;				on utilise en entr‚e a2 (adresse buffer ‚cran)
;									 a3 adresse grille fond
;								  et a4 adresse grille cache

 movem.l a3-a4/d3,-(sp)

 move.l debut_ecran,a2
 lea grille_bomb,a3
 lea grille_cache,a4

 subq.l #7,a2
 move.l #1,d3
  
 move.l #nbr_ligne-1,d1
aff_gr_ligne:				; *** debut 1ere boucle (colonne)

  move.l #nbr_col-1,d2
aff_gr_col:					; ** debut 2nd boucle (ligne)

   clr.l d0
   move.b (a4)+,d0		;Cache
   bne affiche_case
   move.b (a3),d0		;si cache = 0 => affiche grille fond
affiche_case:
   addq.l #1,a3

   addq.l #1,a2		;1er ou 2nd octet des 16 bits (suivant swap d2)
   swap d3
   tst.w d3
   bne .mot_suivant
   addq.l #6,a2		;une fois sur deux (groupe de 16 bits suivant)

.mot_suivant
   move.l a2,a0
   jsr aff_case

   tst.b on_a_touche	; tempo si fin
   beq .pas_tempo
   move #$ff,d0
.boucle_att
    ori.l #$0,d0
    dbra d0,.boucle_att
.pas_tempo

  dbra d2,aff_gr_col		; ** fin 2nd boucle affichage

  add.l #160*7,a2
 dbra d1,aff_gr_ligne		; *** fin 1ere boucle

 movem.l (sp)+,a3-a4/d3
 rts


aff_case:
;********
;			affiche une case sur l'‚cran.
;			d0 contient le num‚ro du graphe (0-$E)
;			a0 contient l'adresse du 1er octet o— on affiche
;	REM: pour calculer a0, utiliser calcul_adr_graph.
;
; Calcule l'adresse du sprite
 lea adr_graph,a1
 lsl.w #5,d0
 adda.l d0,a1
 
var set 0
 rept 8
 move.b (a1)+,var+0(a0)
 move.b (a1)+,var+2(a0)
 move.b (a1)+,var+4(a0)
 move.b (a1)+,var+6(a0)
var set var+160
 endr 
 rts

;*************************************************************************
;***************** SAUVEGARDE/RESTITUTION ECRAN COMPLET ******************
;*************************************************************************
aff_help:
;********
; affiche 2 PI1 pour expliquer comment jouer
; puis restaure l'ecran initial

 move.b #0,go_horloge
 hidem
 v_sync 1

 jsr sauve_ecran
 v_sync 1
 tst.b scrollapp
 beq.s .rien__
 sf scrollapp
 st scrollapp+1
.rien__
 move.b num_menu,sauv_menu
 move.b #5,num_menu
 jsr aff_menu
 lea help_scr_1,a0
 jsr aff_pi1
 move.b #$62,touche_attendu
 move.b #0,touche_recu
.plus_mouse_0
 tst.b mousek
 bne .plus_mouse_0
.attente_1
 tst.b touche_recu
 bne .fin_attente_1
 tst.b mousek
 bne .plus_mouse_1
 bra .attente_1
.plus_mouse_1
 tst.b mousek
 bne .plus_mouse_1
.fin_attente_1

 v_sync 1
 lea help_scr_2,a0
 jsr aff_pi1
 move.b #$62,touche_attendu
 move.b #0,touche_recu
.attente_2
 tst.b touche_recu
 bne .fin_attente_2
 tst.b mousek
 bne .plus_mouse_2
 bra .attente_2
.plus_mouse_2
 tst.b mousek
 bne .plus_mouse_2
.fin_attente_2


 move.b #1,go_horloge
 tst.b scrollapp+1
 beq.s .pas_intro
 move.b #0,go_horloge
 st scrollapp
 sf scrollapp+1
.pas_intro
 jsr remet_ecran
 move.b sauv_menu,num_menu
 jsr aff_menu
 v_sync 1
 showm
 v_sync 20
 rts

sauve_ecran:
;**********
 move.l debut_ecran,a0
 lea sauv_ecran,a1
 move #7999,d0
.transfert_ecran
 move.l (a0)+,(a1)+
 dbra d0,.transfert_ecran
 rts

remet_ecran:
;***********
 move.l debut_ecran,a0
 lea sauv_ecran,a1
 move #7999,d0
.transfert_ecran
 move.l (a1)+,(a0)+
 dbra d0,.transfert_ecran
 rts


;*************************************************************************
;************************* AFFICHAGE D'UNE CASE **************************
;*************************************************************************

calcul_adr_graph:
;****************
;			utilise d3,d4 = (x,y) en entr‚e
;			rend a0: adresse … l'‚cran
;			  et d1: abscisse lin‚aire
;			MODIFIE D1
 move.l debut_ecran,a0
 lsl #2,d3
 adda d3,a0
 lsr #2,d3
 move d3,d1
 and #1,d1
 beq .pas_octet_haut
 suba #3,a0
.pas_octet_haut
 move d4,d1
 mulu #(160*8),d1
 adda.l d1,a0		;adresse o— copier le graph
 
 move.l d4,d1
 mulu #40,d1
 add.l d3,d1		;abscisse lin‚aire
 rts

maj_grille:
;**********
;			met … jour les grilles et affiche le truc
;			a0 contient l'adresse … l'‚cran
;			d1 contient x + (y*nbr_col).
 lea grille_bomb,a1
 lea grille_cache,a2

 move.b #0,(a2,d1.w)	;enleve cache

 cmpi.b #9,(a1,d1.w)	;est-ce une bombe ?
 bne .pas_touche
 move.b #$ff,on_a_touche
 move.b #$a,(a1,d1.w)
.pas_touche

 clr.l d0
 move.b (a1,d1.w),d0
 jsr aff_case

 move #$ffff,d0
.tempo
 and.l #$FFFF,d0
 dbra d0,.tempo

 rts

maj2_grille:
;***********
;
;			idem maj_grille (utilise pour second appui sur gauche)
;			seule difference sur traitement des drapeaux (graph $c)
; ATTENTION a l'appel a0 contient l'adresse a l'ecran
 lea grille_bomb,a1
 lea grille_cache,a2

 cmpi.b #$c,(a2,d1.w)
 beq .fin_maj2			;drapeau ? => on ne fait rien
 
 tst.b (a2,d1.w)
 beq .pas_remplis_2
 tst.b (a1,d1.w)
 bne .pas_remplis_1

 movem.l a0-a2,-(sp)
 move.w d1,-(sp)
 movem.w d3/d4,-(sp)

 jsr remplissage
 jsr verif_remplissage
 jsr aff_apres_remplis

 movem.w (sp)+,d3/d4
 move.w (sp)+,d1
 movem.l (sp)+,a0-a2

.pas_remplis_1
 move.b #0,(a2,d1.w)	;enleve cache
.pas_remplis_2
 
 cmpi.b #9,(a1,d1.w)	;bombe ?
 bne .pas_touche
 move.b #$ff,on_a_touche
 move.b #$a,(a1,d1.w)
.pas_touche
 move.b (a1,d1.w),d0
 and.l #$ff,d0
 jsr aff_case
 
.fin_maj2
 rts

;*************************************************************************
;***************** VBL/HBL POUR BORDURE BAS ******************************
;*************************************************************************
lance_border_bas
;***************
 move.b $fffffa07.w,sauve_fa07
 move.b $fffffa09.w,sauve_fa09
 move.b $fffffa13.w,sauve_fa13
 move.b $fffffa15.w,sauve_fa15
 move.b $fffffa17.w,sauve_fa17
 move.b $fffffa1b.w,sauve_fa1b
 move.b $fffffa21.w,sauve_fa21
 move.l $70.w,sauve_70
 move.l $118.w,sauve_118
 move.l $120.w,sauve_120
 move.l $134.w,sauve_134
 move.l #routine_vbl,$70.w
 move.l #routine_118,$118.w
 move.l #routine_hbl,$120.w
 clr.b $fffffa1b.w
 move.b #%00000001,$fffffa07.w
 move.b #%01000000,$fffffa09.w
 move.b #%00000001,$fffffa13.w
 move.b #%01000000,$fffffa15.w
 bclr.b #3,$fffffa17.w
 rts
rte rte
arrete_border_bas
;****************
 move.l sauve_70,$70.w
 move.l sauve_118,$118.w
 move.l sauve_120,$120.w
 move.l sauve_134,$134.w
 move.b sauve_fa07,$fffffa07.w
 move.b sauve_fa09,$fffffa09.w
 move.b sauve_fa13,$fffffa13.w
 move.b sauve_fa15,$fffffa15.w
 move.b sauve_fa17,$fffffa17.w
 move.b sauve_fa1b,$fffffa1b.w
 move.b sauve_fa21,$fffffa21.w
 rts

routine_vbl
;**********
 movem.l d0-a6,-(sp)
 clr.b $fffffa1b.w
 move.b #194,$fffffa21.w
 move.b #8,$fffffa1b.w
;
; indique qu'une vbl est pass‚e
;
 add.b #1,v_sync_ind
;
; Ici, on demande au clavier de nous balancer les coordon‚es de la souris
; Avec la commande $0D ®Demande de position absolue¯
;
 ifne def_souris **
 tst.b flag_clavier
 beq .no_key
 lea $fffffc00.w,a0
.attend
 btst.b #1,(a0)
 beq.s .attend
 pause 128
 move.b #$0D,2(a0)  
.no_key
 endc **
;
; On change la palette
;

 tst.b scrollapp
 bne.s .scroll
 lea adr_pal,a0
 lea $ffff8240.w,a1
 rept 8
 move.l (a0)+,(a1)+
 endr
 bra .pas_scroll
.scroll
 lea lonewolf+2,a0
 lea $ffff8240.w,a1
 rept 8
 move.l (a0)+,(a1)+
 endr

 move.l debut_ecran,a1
 lea bufferscroll,a0
*
 bsr aff_scr1
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr1
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr1
 lea 160(a1),a1
 addq #2,a0
*
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
*
 bsr aff_scr1
 lea -40(a0),a0
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr1
 lea -40(a0),a0
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr1
 lea -40(a0),a0
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
*
 bsr aff_scr3
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr3
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr3
 lea 160(a1),a1
 addq #2,a0
*
 bsr aff_scr3
 lea -40(a0),a0
 bsr aff_scr1
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr3
 lea -40(a0),a0
 bsr aff_scr1
 lea 160(a1),a1
 addq #2,a0
*
 bsr aff_scr3
 lea -40(a0),a0
 bsr aff_scr2
 lea 160(a1),a1
 addq #2,a0
 bsr aff_scr3
 lea -40(a0),a0
 bsr aff_scr2

 cmp #2,offset_scroll
 bne.s .pas_efface
 lea bufferscroll+20*2,a0
 moveq #0,d0
x set 0
 rept 16
 move d0,x(a0)
x set x+42
 endr
.pas_efface


* scroll
 lea bufferscroll,a0
x set 21*16*2-8*4
 rept 21
 movem.l x(a0),d0-d7
 addx.l d7,d7
 addx.l d6,d6
 addx.l d5,d5
 addx.l d4,d4
 addx.l d3,d3
 addx.l d2,d2
 addx.l d1,d1
 addx.l d0,d0
 movem.l d0-d7,x(a0)
x set x-8*4
 endr

 subq #1,offset_scroll
 bne.s .pasreaffiche
 move #16+ecart_scroll,offset_scroll
 lea bufferscroll+20*2,a0
 lea font,a1
 move.l adr_scroll,a2
 moveq #0,d0
 move.b (a2)+,d0
 bne.s .okay
 lea scrollb,a2
 move.b (a2)+,d0
.okay
 move.l a2,adr_scroll
 subq #1,d0
 lsl #5,d0
 add d0,a1
x set 0
 rept 16
 move (a1)+,x(a0)
x set x+42
 endr
.pasreaffiche
.pas_scroll

;
; On restaure le fonds sous le curseur
;
 tst.b flag_souris
 beq.s restaure_pas_souris
 jsr restaure_fonds_souris
restaure_pas_souris
;
; Ici incrementation de l'heure
;
 tst.b go_horloge
 beq .pas_aff_horloge

 addq.b #1,nb_cycle_horl
 cmp.b #49,nb_cycle_horl
 ble .pas_aff_horloge
 clr.b nb_cycle_horl		; 1 seconde entiere
 addq #1,nb_sec_horl
 cmp #59,nb_sec_horl
 ble .pas_minute
 clr nb_sec_horl			; 1 minute entiere
 addq #1,nb_min_horl
 cmp #59,nb_min_horl
 ble .pas_heure
 clr nb_min_horl		; 1 heure entiere
.pas_heure:
 jsr aff_minute
.pas_minute:
 jsr aff_seconde
.pas_aff_horloge:
;
; On affiche le curseur !
;
 tst.b flag_souris
 beq.s affiche_pas_souris
 jsr affiche_curseur_souris
affiche_pas_souris
;
; On quitte notre VBL
;
 jsr routine_calcul

;
; Ici on met la musique ‚ventuellement
;

* eor #$fff,$ffff8240.w
* eor #$fff,$ffff8240.w
 movem.l (sp)+,d0-a6
 rte

aff_scr1
x set 2
 rept 20
 move (a0)+,x(a1)
x set x+8
 endr
 rts
aff_scr2
x set 4
 rept 20
 move (a0)+,x(a1)
x set x+8
 endr
 rts
aff_scr3
x set 6
 rept 20
 move (a0)+,x(a1)
x set x+8
 endr
 rts

routine_hbl
;**********
 move.w #$2700,sr
 tst.b ste?
 bne.s .pas_sterts0
 jsr Routine_timer_a_rts
.pas_sterts0
 movem.l d0/d1/a0/a1,-(sp)
;
; On attend de d‚passer la 198Šme ligne de l'‚cran
;
 move.l debut_ecran_2,a0
 lea $ffff8205.w,a1
 tst.b ste?
 bne.s .pas_sterts1
 jsr Routine_timer_a_rts
.pas_sterts1
sync_1
 movep.w (a1),d0
 cmp.w a0,d0
 blt.s sync_1
;
; 
;
 addq.w #4,a1
 moveq #0,d0
sync_2 
 move.b (a1),d0
 bpl.s sync_2   

sync_3
 move.b (a1),d0
 cmp.b #32,d0
 blt.s sync_3   
 moveq #32,d1
 sub.w d0,d1
 lsl.w d1,d0 
 
;
; D‚clenchement du border bas
;
 pause 80+45
 pause 4
 move.b #0,$ffff820a.w
 pause 20
 move.b #2,$ffff820a.w
 tst.b ste?
 bne.s .pas_sterts2
 jsr Routine_timer_a_rts
.pas_sterts2
;
; On change la palette
;
 lea tableau,a0
 lea $ffff8240.w,a1
 rept 8
 move.l (a0)+,(a1)+
 endr
;
; Et r‚actualisation des boutons !
;
 move.b boutons,d0
 move.b mousek,d1
bouton_droit
 btst #1,d1
 beq .relach‚
.press‚
 btst #1,d0
 beq .fin_test
 bclr #1,d1
 bra .fin_test 
.relach‚
 btst #0,d0
 beq .fin_test
 bset #1,d1
.fin_test
bouton_gauche
 btst #0,d1
 beq .relach‚
.press‚
 btst #3,d0
 beq .fin_test
 bclr #0,d1
 bra .fin_test 
.relach‚
 btst #2,d0
 beq .fin_test
 bset #0,d1
.fin_test
yurk
 move.b d1,mousek
;
; Ainsi que MouseX et MouseY
;
 move x_mouse,mousex
 tst.b scrollapp
 beq.s .oky
 cmp #40,y_mouse
 bge.s .oky
 add #201,y_mouse
.oky
 move.w y_mouse,mousey

 movem.l (sp)+,d0/d1/a0/a1
 clr.b $fffffa1b.w
 rte

routine_118
;**********
; Gestion Clavier_souris
; deux cas:
; 1) on est en train de recevoir les coordonnees souris
; c'est une suite de cinq caract‚res avec 7F aux debut.
; 2) on recois un caractere touche enfonces (01-72) ou relach‚e (x+80)
; un test de touche_attendu permet de marquer touche_recu
;
 ifne def_debug **
 move.w $ffff8240.w,-(sp)
 move.w #$070,$ffff8240.w
 endc **

 btst #0,$fffffc00.w		;tampon plein ?
 beq fin_118_vide
 
 movem.l d0-d1/a0,-(sp)

 move.b $fffffc02.w,d0		;donn‚e recue.

 cmpi.w #5,compteur			;coordonn‚es en cours de transmission.
 beq .pas_souris_actuellement
 addq.w #1,compteur
 move.w compteur,d1
 lea touche(pc),a0
 move.b d0,0(a0,d1.w)
 bra fin_118_plein

.pas_souris_actuellement
 cmp.b #$f7,d0				;en-tete coordonn‚es souris
 bne .pas_entete
 clr.w compteur
 bra fin_118_plein

.pas_entete
 move.b d0,touche
 cmp.b touche_attendu,d0
 bne .pas_encore
 move.b $FF,touche_recu
.pas_encore

fin_118_plein
 movem.l (sp)+,d0-d1/a0
fin_118_vide
 ifne def_debug **
 move.w (sp)+,$ffff8240.w
 endc **
 rte

touche_attendu dc.b 0
touche_recu    dc.b 0
touche      dc.b 0
boutons     dc.b 0
x_mouse     dc.w 0
y_mouse     dc.w 0
compteur    dc.w 0
flag_souris dc.b 0
mousek      dc.b 0
mousex      dc.w 0
mousey      dc.w 0

;*************************************************************************
;************************ ACTION SUR LE CLAVIER **************************
;*************************************************************************
test_touche:
;***********
; donne le num‚ro de l'icone ‚quivalente dans d0
; ou alors met 0 dans d0 et action imm‚diate.
 move.b touche,d0
 move.b #0,touche
 move.b #0,emul_bouton
 
 cmp.b #$01,d0			; Esc -> On quitte (icone 4) !!!
 bne pas_esc
 ifeq def_esc **
 moveq #0,d0
 elseif **
 moveq #4,d0
 endc **
 bra fin_tst_touche
pas_esc:

 cmp.b #$02,d0         ; "1" -> Changement de niveau
 bne.s pas_un
 moveq #9,d0
 bra fin_tst_touche
pas_un:

 cmp.b #$03,d0         ; "2" -> Changement de niveau
 bne.s pas_deux
 moveq #$A,d0
 bra fin_tst_touche
pas_deux:

 cmp.b #$04,d0         ; "3" -> Changement de niveau
 bne.s pas_trois
 moveq #$B,d0
 bra fin_tst_touche
pas_trois:

 cmp.b #$1f,d0         ; "S" -> Sauve la partie sur disk
 bne.s pas_sauve_disc
 moveq #2,d0
 bra fin_tst_touche
pas_sauve_disc:

 cmp.b #$26,d0         ; "L" -> Charge la partie du disk
 bne.s pas_lect_disc
 moveq #1,d0
 bra fin_tst_touche
pas_lect_disc:

 cmp.b #$61,d0		   ; UNDO -> Annule le coup pr‚c‚dent
 bne pas_undo
 moveq #7,d0
 bra fin_tst_touche
pas_undo:

 cmp.b #$62,d0		   ; HELP -> Affiche un ecran d'aide
 bne pas_help
 moveq #5,d0
 bra fin_tst_touche
pas_help:

 cmp.b #$3b,d0			; F1 pour centrer la souris
 bne pas_f1
 tst.b scrollapp
 bne .centre_debut
 move.w #159,place_x
 move.w #99,place_y
 bra .fin_centre
.centre_debut
 move.w #159,place_x
 move.w #219,place_y
.fin_centre
 ifne def_souris **
 lea sequence_place_souris,a0
 jsr envoie_clavier
 endc **
 moveq #0,d0
 bra fin_tst_touche
pas_f1:

 cmp.b #$48,d0			;  => deplace curseur
 bne pas_fleche_haut
 move.b #$C8,touche_attendu
 move.b #0,touche_recu
fleche_haut:
 ifne def_souris **
 move.w mousex,place_x 
 move.w mousey,place_y
 endc **
 cmp.w #8,place_y
 bmi .bord_haut
 sub.w #8,place_y
.bord_haut

 tst.b scrollapp
 beq.s .oky
 cmp #201,place_y
 bgt.s .oky
 move #201,place_y
.oky

 jsr arrondi_coordonnees
 ifne def_souris **
 lea sequence_place_souris,a0
 jsr envoie_clavier
 endc **
 v_sync 5
 tst.b touche_recu
 beq fleche_haut
 moveq #0,d0
 bra fin_tst_touche
pas_fleche_haut:

 cmp.b #$50,d0			;  => deplace curseur
 bne pas_fleche_bas
 move.b #$D0,touche_attendu
 move.b #0,touche_recu
fleche_bas:
 ifne def_souris **
 move.w mousex,place_x 
 move.w mousey,place_y
 endc **
 cmp.w #231,place_y		;(240 lignes => 239-8)
 bhi .bord_bas
 add.w #8,place_y
.bord_bas

 tst.b scrollapp
 beq.s .oky
 cmp #201,place_y
 bgt.s .oky
 move #201,place_y
.oky

 jsr arrondi_coordonnees
 ifne def_souris **
 lea sequence_place_souris,a0
 jsr envoie_clavier
 endc **
 v_sync 5
 tst.b touche_recu
 beq fleche_bas
 moveq #0,d0
 bra fin_tst_touche
pas_fleche_bas:

 cmp.b #$4B,d0			;  => deplace curseur
 bne pas_fleche_gauche
 move.b #$CB,touche_attendu
 move.b #0,touche_recu
fleche_gauche:
 ifne def_souris **
 move.w mousex,place_x 
 move.w mousey,place_y
 endc **
 cmp.w #8,place_x
 bmi .bord_gauche
 sub.w #8,place_x
.bord_gauche
 jsr arrondi_coordonnees
 ifne def_souris **
 lea sequence_place_souris,a0
 jsr envoie_clavier
 endc **
 v_sync 5
 tst.b touche_recu
 beq fleche_gauche
 moveq #0,d0
 bra fin_tst_touche
pas_fleche_gauche:

 cmp.b #$4D,d0			;  => deplace curseur
 bne pas_fleche_droite
 move.b #$CD,touche_attendu
 move.b #0,touche_recu
fleche_droite:
 ifne def_souris **
 move.w mousex,place_x 
 move.w mousey,place_y
 endc **
 cmp.w #311,place_x
 bhi .bord_droit
 add.w #8,place_x
.bord_droit:
 jsr arrondi_coordonnees
 ifne def_souris **
 lea sequence_place_souris,a0
 jsr envoie_clavier
 endc **
 v_sync 5
 tst.b touche_recu
 beq fleche_droite
 moveq #0,d0
 bra fin_tst_touche
pas_fleche_droite:

 cmp.b #$52,d0			; Insert => bouton gauche
 bne pas_insert
 move.l #1,d0 
 move.b #$FF,emul_bouton
 bra fin_tst_touche
pas_insert:

 cmp.b #$47,d0			; Clr home => bouton droit
 bne pas_clr_home
 move.l #2,d0 
 move.b #$FF,emul_bouton
 bra fin_tst_touche
pas_clr_home:

fin_tst_touche:
 rts

arrondi_coordonnees
;*****************
; pour le deplacement de la souris au clavier.
 and.w #$fff8,place_x
 add.w #4,place_x
 and.w #$fff8,place_y
 add.w #4,place_y
 rts
 
;*************************************************************************
;************************ ACTION SUR LES ICONES **************************
;*************************************************************************
test_menu:
;*********
; donne dans d0 le num‚ro de l'icone choisi (0 si rien)
;
 clr.l d0			;retour = 0 (icone vide) par defaut
 clr.l d2

 cmpi #231,d4
 bgt fin_tst_menu
 cmpi #209,d4
 bls fin_tst_menu
 cmpi #191,d3
 bls fin_tst_menu
 cmpi #310,d3
 bgt fin_tst_menu

						;ACTION SUR LE MENU
 cmpi #214,d3		;fin 1er bouton
 bmi traite_menu
 cmpi #223,d3		;debut 2i‚me bouton
 bmi fin_tst_menu
 addq.l #1,d2
 cmpi #246,d3		;fin 2i‚me bouton
 bmi traite_menu 
 cmpi #255,d3		;debut 3i‚me bouton
 bmi fin_tst_menu
 addq.l #1,d2
 cmpi #278,d3		;fin 3i‚me bouton
 bmi traite_menu 
 cmpi #288,d3
 bmi fin_tst_menu
 addq.l #1,d2
 
 
traite_menu:
 lea menu_0,a0
 add.l d2,a0
 move.b num_menu,d2
 add.l d2,d2
 add.l d2,d2
 add.l d2,a0
 move.b (a0),d0		;recupere num‚ro icone

fin_tst_menu:
 rts

actions_jeux:
;**************
;entr‚e: d0 (num‚ro de l'icone)
;	1 load
;	2 save
;	7 croix rouge	(undo)


icon_1:
 cmp.b #1,d0
 bne icon_2
 jsr remet_disk
 move.b #1,d0
 bra fin_actions_jeux

icon_2:
 cmp.b #2,d0
 bne icon_7
 jsr sauve_disk
 move.b #2,d0
 bra fin_actions_jeux

icon_7:
 cmp.b #7,d0			; Undo => reaffiche grille precedente
 bne fin_actions_jeux
 hidem
 jsr remet_partie
 jsr aff_grille
 jsr aff_score
 moveq #7,d0

fin_actions_jeux:
 rts

actions_icones:
;*************
;entr‚e: d0 (num‚ro de l'icone)
; 	0 vide
;	3 boulier
;	4 drapeau		(sortir programme)
;	5 help
;	6 change page
;	8 "disc"
;	9 "easy"
;   10 "Cool"
;	11 "hard"


 cmp.b #0,d0			;rien => on sort
 beq fin_actions_icones
 cmp.b #3,d0			;boulier => rien
 beq fin_actions_icones
 cmp.b #8,d0			;disk => c'est pour faire beau
 beq fin_actions_icones


icon_4:
 cmp.b #4,d0			;drapeau blanc => marque fin de jeux
 bne icon_5
 move.b #$ff,on_a_touche
 bra fin_actions_icones

icon_5:					;ecran d'aide => sauve ecran + affiche 2 pi1
 cmp.b #5,d0
 bne icon_6
 jsr aff_help
 moveq #5,d0
 bra fin_actions_icones

icon_6:					;page => menu suivant
 cmp.b #6,d0
 bne icon_9
 add.b #1,num_menu
 cmp.b #3,num_menu
 bne .pas_raz
 clr.b num_menu
.pas_raz
 cmp.b #5,num_menu
 bne .pas_boucle
 move.b #3,num_menu
.pas_boucle
 jsr aff_menu
 v_sync 10
 moveq #6,d0
 bra fin_actions_icones

icon_9:
icon_10:
icon_11:				; niveau => change niveau_defaut
 cmp.b #9,d0
 bmi fin_actions_icones
 cmp.b #11,d0
 bhi fin_actions_icones

 move.b d0,niveau_defaut
 sub.b #9,niveau_defaut

fin_actions_icones:
 rts

;*************************************************************************
;************************ INTRODUCTION ***********************************
;*************************************************************************

introduction
;***********
 st scrollapp
; niveau par defaut:
; 0 -> 100 bombes et pas d'explosion tant que pas trouv‚ de case vide
; 1 -> 130 bombes et pas d'explosion si bombe la 1ere fois
; 2 -> 160 bombes
; en sortie d0=niveau
;

 move.b #1,niveau_defaut
 sf on_a_touche

;		** init de l'affichage (grille,score,horloge,menu) **

 clr nb_sec_horl
 clr nb_min_horl
 clr.w nbr_bomb
 clr.w nb_drapeau_mis
 move.b #6,num_menu
 move.b #0,go_horloge

 jsr aff_tableau
 jsr aff_score
 jsr aff_sourire
 jsr aff_seconde
 jsr aff_minute
 jsr aff_menu
 hidem
 move #5,compteur
 move #$2300,sr
 v_sync 1
 lea lonewolf,a0
 jsr aff_pi1

 v_sync 1
 showm

; ***** DEMANDE NIVEAU DU JEUX *****
scrute_niveau:

 clr.b touche
 clr.b mousek
.attend_touche:
 tst.b mousek
 bne menu_niveau
 tst.b touche
 beq.s .attend_touche

;*** par les touches "1" "2" "3" ou Esc ***
 jsr test_touche
 tst.b emul_bouton
 bne  bouton_niveau
 bra actions_debut

;*** par la souris ***
menu_niveau:
 moveq #0,d0
 move.b mousek,d0
bouton_niveau:
 moveq #0,d3
 moveq #0,d4
 ifne def_souris **
 move.w mousex,d3
 move.w mousey,d4
 elseif **
 move.w place_x,d3
 move.w place_y,d4
 endc **

 cmpi #319,d3		;est-on … la hauteur des icones ?
 bgt scrute_niveau
 cmpi #199,d4
 bls scrute_niveau

 attend_plus_boutons_2

 jsr test_menu

actions_debut:

 jsr actions_icones
 
 ifne def_esc **
 cmp.b #$ff,on_a_touche	; si esc => on sort
 beq fin_scrute_niveau
 endc **

 cmp.b #9,d0		;9 = niveau 0
 bmi scrute_niveau
 cmp.b #11,d0		;11= niveau 2
 bhi scrute_niveau

fin_scrute_niveau:
 sf on_a_touche
 tst.b scrollapp
 beq .tyu
 bsr efface_screen
 sf scrollapp
 move.l debut_ecran,a0
 move #(160*16)/4-1,d7
.eff
 clr.l (a0)+
 dbra d7,.eff
.tyu
 rts
efface_screen
 move.l debut_ecran,a0
 lea 200*160(a0),a1
 moveq #100-1,d7
 moveq #0,d5
.loopi
 v_sync 1
 moveq #10-1,d6
.loopi0
 move.l d5,(a0)+
 move.l d5,(a0)+
 move.l d5,(a0)+
 move.l d5,(a0)+
 move.l d5,-(a1)
 move.l d5,-(a1)
 move.l d5,-(a1)
 move.l d5,-(a1)
 dbra d6,.loopi0
 dbra d7,.loopi
 rts

;*************************************************************************
;**************************** UNDO ***************************************
;*************************************************************************
remet_partie:
;*************
 move #((((nbr_col*nbr_ligne)/4)+1)*2)-1,d1
 lea copie_2_grille,a1
 lea grille_bomb,a0
_remet_grilles:
 move.l (a1)+,(a0)+
 dbra d1,_remet_grilles
 move copie_nb_drapeau,nb_drapeau_mis

 move.b #0,on_a_touche		;utile si on etait en fin de partie
 rts

sauve_partie
;***********
 move #((((nbr_col*nbr_ligne)/4)+1)*2)-1,d1
 lea copie_2_grille,a0
 lea grille_bomb,a1
sauve_grilles:
 move.l (a1)+,(a0)+
 dbra d1,sauve_grilles
 move nb_drapeau_mis,copie_nb_drapeau
 rts


;*************************************************************************
;********************** OPERATIONS DISQUE ********************************
;*************************************************************************

sauve_disk:
;***********

 tst.b on_a_touche		;pas de sauvegarde si on est mort
 bne .loupe
 v_sync 1
 move.l #rte,$120.w
 bsr verifie_disk4
* d3 nb secteur
* d4 nb piste to begin
* d5 nb secteurs to begin
 lea grille_bomb,a0
 moveq #4,d3
 moveq #1,d4
 moveq #2,d5
 jsr disk_write
 move.l #routine_hbl,$120.w
 v_sync 1
.loupe
 jsr aff_minute
 jsr aff_seconde
 st go_horloge
 showm
 rts

remet_disk:
;***********
 hidem
 v_sync 1
 move.l #rte,$120.w
 bsr verifie_disk4
* d3 nb secteur
* d4 nb piste to begin
* d5 nb secteurs to begin
 lea grille_bomb,a0
 moveq #4,d3
 moveq #1,d4
 moveq #2,d5
 jsr disk_read
 move.l #routine_hbl,$120.w
 v_sync 1
 jsr sauve_partie
 jsr aff_score
 jsr aff_grille
 move.b #0,on_a_touche		;utile si on etait en fin de partie
 move.b niveau,niveau_defaut
 showm
 st go_horloge
 jsr aff_minute
 jsr aff_seconde
 rts

aff_info_fin
* illegal
** niveau.b        0,1,2
** nb_min_horl.w
** nb_sec_horl.w
** nbr_bomb.w
** nb_drapeau_mis.w
* nb_bomb_sous_drapeau.w

* affiche le niveau du joueur
 bsr clrline
 lea niveaumess,a0
 lea line,a1
 bsr recopy
 lea easy,a0
 tst.b niveau
 beq.s .hehc
 lea cool,a0
 cmp.b #1,niveau
 beq.s .hehc
 lea hard,a0
.hehc
 bsr recopy
 lea line,a0
 move #10*160*10,d7
 bsr print

* temps mis pour jouer
 bsr clrline
 lea tempp,a0
 lea line,a1
 bsr recopy
 move nb_min_horl,d0
 move.l a1,a0
 bsr change_asc
 lea tmin,a0
 bsr recopy
 move nb_sec_horl,d0
 move.l a1,a0
 bsr change_asc
 lea tsec,a0
 bsr recopy 
 lea line,a0
 move #11*160*10,d7
 bsr print

* nbr de bombs k'il y avait a decouvrir
 bsr clrline
 lea bombh,a0
 lea line,a1
 bsr recopy
 move nbr_bomb,d0
 move.l a1,a0
 bsr change_asc
 lea line,a0
 move #12*160*10,d7
 bsr print

* nbr de flag mit
 bsr clrline
 lea flagh0,a0
 lea line,a1
 bsr recopy
 move nb_drapeau_mis,d0
 move.l a1,a0
 bsr change_asc
 lea flagh1,a0
 bsr recopy
 lea line,a0
 move #13*160*10,d7
 bsr print

* nbr de bombes decouvertes
 bsr clrline
 lea disc0,a0
 lea line,a1
 bsr recopy
 move nb_bomb_sous_drapeau,d0
 move.l a1,a0
 bsr change_asc
 lea disc1,a0
 bsr recopy
 lea line,a0
 move #14*160*10,d7
 bsr print

 lea press,a0
 move #16*160*10,d7
 bsr print

 wait_key
*** affichage des meilleurs scrores selon le niveau de difficulte choisi.
 bsr efface_screen
 lea easy_scores,a0
 moveq #0,d7
 bsr print
 lea easyscr,a3
 move #10*160,d6
 move.b #"1",d5
 bsr aff_scores
 move #2*10*160,d6
 move.b #"2",d5
 bsr aff_scores
 move #3*10*160,d6
 move.b #"3",d5
 bsr aff_scores
 move #4*10*160,d6
 move.b #"4",d5
 bsr aff_scores
 move #5*10*160,d6
 move.b #"5",d5
 bsr aff_scores
*
 lea cool_scores,a0
 move #7*10*160,d7
 bsr print
 move #8*10*160,d6
 move.b #"1",d5
 bsr aff_scores
 move #9*10*160,d6
 move.b #"2",d5
 bsr aff_scores
 move #10*10*160,d6
 move.b #"3",d5
 bsr aff_scores
 move #11*10*160,d6
 move.b #"4",d5
 bsr aff_scores
 move #12*10*160,d6
 move.b #"5",d5
 bsr aff_scores

*
 lea hard_scores,a0
 move #14*10*160,d7
 bsr print
 move #15*10*160,d6
 move.b #"1",d5
 bsr aff_scores
 move #16*10*160,d6
 move.b #"2",d5
 bsr aff_scores
 move #17*10*160,d6
 move.b #"3",d5
 bsr aff_scores
 move #18*10*160,d6
 move.b #"4",d5
 bsr aff_scores
 move #19*10*160,d6
 move.b #"5",d5
 bsr aff_scores
 rts
easy_scores dc.b "     ~Best scores in easy mode~",0
cool_scores dc.b "     ~Best scores in cool mode~",0
hard_scores dc.b "     ~Best scores in hard mode~",0
press       dc.b "       Press a key to continue          ",0
disc0 dc.b " And you discovered ",0
disc1 dc.b " mines.",0
bombh dc.b " The number of mines was : ",0
flagh0 dc.b " You put ",0
flagh1 dc.b " flags.",0
tempp dc.b " You played for ",0
tmin dc.b " min. & ",0
tsec dc.b " sec.",0
niveaumess dc.b " Your level was : ",0
easy dc.b "Easy",0
cool dc.b "Cool",0
hard dc.b "Hard",0
 even
line ds.w 21
name dc.b " YOYO je gagne !! "
demn
 dc.b 1,1,1,1
 dc.b "",1
 dc.b "                                    ",1
 dc.b "    You've made a Hi score!!!       ",1
 dc.b "                                    ",1
 dc.b "   So please enter your name :      ",1
 dc.b "                                    ",1
 dc.b "      >                  <          ",1
 dc.b "                                    ",1
 dc.b "",1
 dc.b 0

suitedemn
 dc.b "      >                  <",0
conv_carmaj
 dc.b 0,0,"1234567890",0,0,0,0,"AZERTYUIOP",0,"$",0,0,"QSDFGHJKLM%"
 dc.b "-",0,0,"WXCVBN?./+",0,0,0," ",0,0,0,0,0,0,0,0,0,0,0
 dc.b 0,0,0,0,0,"-",0,0,0,"+",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"()/*7894561230.",1,0,0,0,0,0,0,0
 even
demande_nom
 movem.l d0-a6,-(sp)
 lea suitedemn+9,a1
 lea name,a2
 moveq #17,d7
.efr
 move.b #" ",(a1)+
 move.b #" ",(a2)+
 dbra d7,.efr
*
 bsr efface_screen
 lea demn,a0
 moveq #0,d7
 bsr print
 lea conv_carmaj,a0
 lea suitedemn+9,a1
 lea name,a2
 moveq #17,d7
 moveq #0,d6
.dem
 sf touche
 wait_key 
 moveq #0,d0
 move.b touche,d0
 btst #7,d0
 bne.s .dem

 cmp.b #$e,d0
 bne.s .pas_backspace
 tst d6
 beq.s .dem
 subq #1,d6
 addq #1,d7
 move.b #" ",-(a1)
 move.b #" ",-(a2)
 movem.l d0-a6,-(sp)
 lea suitedemn,a0
 move #10*160*10,d7
 bsr print
 movem.l (sp)+,d0-a6
 bra.s .dem
.pas_backspace
 cmp.b #$1c,d0
 beq.s .finen
 cmp.b #$72,d0
 beq.s .finen
 move.b (a0,d0.w),d0
 tst.b d0
 beq.s .dem
 move.b d0,(a1)+
 move.b d0,(a2)+
 addq #1,d6
 movem.l d0-a6,-(sp)
 lea suitedemn,a0
 move #10*160*10,d7
 bsr print
 movem.l (sp)+,d0-a6
 dbra d7,.dem
.finen
 sf touche
 v_sync 3
 sf touche
 v_sync 10
 sf touche
 v_sync 10
 sf touche
*
 movem.l (sp)+,d0-a6
 rts
easyscr
 dc 10,10
 dc.b "LONE WOLF         "
 dc 15,10
 dc.b "MIT               "
 dc 20,20
 dc.b "DBUG              "
 dc 25,30
 dc.b "FFT               "
 dc 30,42
 dc.b "CHROMIX           "
*
 dc 10,10
 dc.b "LONE WOLF         "
 dc 15,10
 dc.b "MIT               "
 dc 20,20
 dc.b "DBUG              "
 dc 25,30
 dc.b "FFT               "
 dc 30,42
 dc.b "CHROMIX           "
*
 dc 10,10
 dc.b "LONE WOLF         "
 dc 15,10
 dc.b "MIT               "
 dc 20,20
 dc.b "DBUG              "
 dc 25,30
 dc.b "FFT               "
 dc 30,42
 dc.b "CHROMIX           "
 ds.w 256


aff_scores
 bsr clrline
 move.b d5,line+4
 move.b #"_",line+5
 lea line+8,a0
 move (a3)+,d0
 bsr change_asc
 addq #1,d2
 add d2,a2
 move.b #"m",(a2)+
 addq #1,a2
 move.l a2,a0
 move (a3)+,d0
 bsr change_asc
 addq #1,d2
 add d2,a2
 move.b #"s",(a2)+
 addq #2,a2
 move.l a2,a1
 move.l a3,a0
 bsr reopcy1
 lea line,a0
 move d6,d7
 bsr print
 lea 18(a3),a3
 rts
reopcy1
 moveq #17,d7
.loop
 move.b (a0)+,(a1)+
 dbra d7,.loop
 rts
recopy
 move.b (a0)+,d0
 beq.s .suite
 move.b d0,(a1)+
 bra.s recopy
.suite
 rts
clrline
 lea line(pc),a0
 moveq #39,d7
.cl
 move.b #" ",(a0)+
 dbra d7,.cl
 move.b #1,(a0)+
 clr.b (a0)+
 rts
change_asc
* d0.w
* a0
 move.l a0,a2
 moveq #-1,d1
.loop
 and.l #$ffff,d0
 divu #10,d0
 swap d0
 move.b .tab(pc,d0.w),(a0)+
 swap d0
 addq #1,d1
 tst d0
 bne.s .loop
 addq #1,a1
 move d1,d2
 lsr d1
.loop1
 move.b (a2),d0
 move.b -(a0),(a2)+
 move.b d0,(a0)
 dbra d1,.loop1
 add d2,a1
 rts
.tab dc.b "0123456789"

; ********* OPERATION CLAVIER **********
; **************************************

envoie_clavier
;*************
 sf flag_clavier	; marque "on cause au clavier" pour la vbl
 move.b (a0)+,d1
 cmp.b #-1,d1
 beq.s .fin_envoie
 lea $fffffc00.w,a1
.attend
 move.b (a1),d2
 btst #1,d2
 beq.s .attend
 move.w #$3b6,d2
.temporisation
 bsr comme_le_systeme
 dbra d2,.temporisation
 move.b d1,2(a1)
 bra.s envoie_clavier
.fin_envoie
 st flag_clavier
 rts
comme_le_systeme 	; temporisation par execution de bsr
 rts

; ********* OPERATION SOURIS ***********
; **************************************


restaure_fonds_souris
;********************
 movem.l d0-a6,-(sp)
 lea sauvegarde,a0
 move.l (a0)+,a1
 moveq #15,d7
.reaff
 movem.l (a0)+,d0-d3
 movem.l d0-d3,(a1)
 lea 160(a1),a1
 dbra d7,.reaff 
 movem.l (sp)+,d0-a6
 rts

memorise_fonds_souris
;*******************
 movem.l d0-a6,-(sp)
 move.l debut_ecran,a1
 lea sauvegarde,a2
 moveq #0,d0
 move.w mousey,d0
 mulu #160,d0
 add.l d0,a1
 moveq #0,d0
 move.w mousex,d0
 lsr.l #4,d0
 lsl.l #3,d0
 add.l d0,a1
 move.l a1,(a2)+
 moveq #15,d7
.memorise_ligne_suivante
 movem.l (a1),d0-d3
 lea 160(a1),a1
 movem.l d0-d3,(a2)
 lea 16(a2),a2
 dbra d7,.memorise_ligne_suivante
 movem.l (sp)+,d0-a6
 rts
 
affiche_curseur_souris
;*********************
 lea sprite,a0
 move.l debut_ecran,a1
 lea sauvegarde,a2
 moveq #0,d0
 ifne def_souris **
 move mousey,d0
 elseif **
 move place_y,d0
 endc **
 mulu #160,d0
 add.l d0,a1
 moveq #0,d0
 ifne def_souris **
 move mousex,d0
 elseif **
 move place_x,d0
 endc **
 move d0,d6
 move.l d0,d1
 and.w #15,d0
 mulu #(256+128),d0
 add.l d0,a0
 lsr.l #4,d1
 lsl.l #3,d1
 add.l d1,a1
 move.l a1,(a2)+
 moveq #15,d7
 cmp #304,d6
 bge.s .affiche_ligne_suivante_premier_multiple
.affiche_ligne_suivante 
 movem.l (a1),d0-d3
 movem.l d0-d3,(a2)
 and.l (a0),d0
 and.l (a0)+,d1
 and.l (a0),d2
 and.l (a0)+,d3
 or.l (a0)+,d0
 or.l (a0)+,d1
 or.l (a0)+,d2
 or.l (a0)+,d3
 movem.l d0-d3,(a1)
 lea 160(a1),a1
 lea 16(a2),a2
 dbra d7,.affiche_ligne_suivante 
 rts

.affiche_ligne_suivante_premier_multiple
 movem.l (a1),d0-d3
 movem.l d0-d3,(a2)
 and.l (a0),d0
 and.l (a0)+,d1
 addq #4,a0
 or.l (a0)+,d0
 or.l (a0)+,d1
 addq #8,a0
 move.l d0,(a1)
 move.l d1,4(a1)
 lea 160(a1),a1
 lea 16(a2),a2
 dbra d7,.affiche_ligne_suivante_premier_multiple
 rts


predecalle_souris
;****************
 lea sprite,a1
 moveq #16-1,d7
.sprite_suivant
 lea mouse,a0
 moveq #16-1,d6
.ligne_suivante 
 lea 8(a1),a1
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 clr.l (a1)+
 clr.l (a1)+
 dbra d6,.ligne_suivante
 dbra d7,.sprite_suivant
 
decallage_du_sprite
;******************
 moveq #15,d5
 lea fin_sprite-2,a0
.bloc_suivant
 move.l d5,d3
 moveq #16,d0
 sub.l d3,d0
 move.w #(256+128)/2-1,d1 ; 5808
.predecalle_bloc
 move.w (a0),d4
 move.w -8(a0),d2
 lsr.w d3,d4        ; decalle de D3 rotations
 lsl.w d0,d2
 add.w d2,d4
 move.w d4,(a0)
 subq.l #2,a0
 dbra d1,.predecalle_bloc
 dbra d5,.bloc_suivant
   
masquage_du_sprite
;*****************
 lea sprite,a0
 lea sprite,a1
 moveq #16-1,d7
.sprite_suivant
 moveq #16-1,d6
.bloc_suivant 
 lea 8(a0),a0
 moveq #1,d5
.largeur 
 move.w (a0)+,d0
 or.w (a0)+,d0
 or.w (a0)+,d0
 or.w (a0)+,d0
 not.w d0
 move.w d0,d1
 swap d0
 move.w d1,d0
 move.l d0,(a1)+
 dbra d5,.largeur
 lea 16(a1),a1
 dbra d6,.bloc_suivant
 dbra d7,.sprite_suivant
 rts
 
efface_bss
;*********
 lea debut_bss,a0
 lea fin_bss,a1
 moveq #0,d0
.efface
 move.l d0,(a0)+  
 cmpa.l a1,a0
 bmi.s .efface
 jmp fin_efface_bss

reset_shifter
;*************
 stop #$2300
 move.b #0,$ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 move.b #0,$ffff820a.w
 stop #$2300
 move.b #2,$ffff820a.w
 rts 
;*************************************************************************
;********************** SECTION DATA *************************************
;*************************************************************************

 include strkmit6.s
 include fdcw.s
 include fdcr.s


   SECTION DATA

;nom_fichier dc.b 'a:\jeu_mine.sav',0

 EVEN

 ifne def_disque_dur **
adr_icone   incbin icones.dat
adr_pal     incbin mines_1.dat
adr_graph_2 incbin mines_2m.dat 
mouse       incbin mouse.dat
tableau     incbin tableau.dat
lonewolf	incbin lonewol4.pi1
help_scr_1	incbin help_1.pi1
help_scr_2	incbin help_2.pi1
 elseif **
adr_icone   incbin icones.dat
adr_pal     incbin mines_1.dat
adr_graph_2 incbin mines_2m.dat 
mouse       incbin mouse.dat
tableau     incbin tableau.dat
'help_scr_1
'help_scr_2
lonewolf	incbin lonewol4.pi1
help_scr_1	incbin help_1.pi1
help_scr_2	incbin help_2.pi1
 endc **

adr_graph EQU adr_pal+32

 even 
 dc.b 0
sequence_absolu
 dc.b $09
 dc.w 316    *Xmax (theorique 319)
 dc.w 35    *Ymax ( "  "  "  244) => attention … la taille du buffer ecran
 dc.b -1
 even
 dc.b 0
sequence_absolu1
 dc.b $09
 dc.w 316    *Xmax (theorique 319)
 dc.w 236    *Ymax ( "  "  "  244) => attention … la taille du buffer ecran
 dc.b -1
 even
sequence_retour_bureau
 dc.b $08,-1

sequence_place_souris
        dc.w $0e00
place_x dc.w 160		;1ere position de la souris
place_y dc.w 15
        dc.b -1
         
menu_0 dc.b 5,7,4,6		;jeux
menu_1 dc.b 8,1,2,6
menu_2 dc.b 9,10,11,6

menu_3 dc.b 1,7,4,6		;fin partie
menu_4 dc.b 9,10,11,6

menu_5 dc.b 0,0,0,0		;ecran d'aide
menu_6 dc.b 9,10,11,5	;choix niveau

 even
pfont incbin tosfnt.dat
font
 ds.w 16
 incbin font.dat
scrollb
 incbin scroll.dat
 even
message_gagne
 dc.b 1,1
 dc.b "",1
 dc.b "                                    ",1
 dc.b "      Great !!  You won !!!         ",1
 dc.b "                                    ",1
 dc.b "",1
 dc.b 0
message_perdu
 dc.b 1,1
 dc.b "",1
 dc.b "                                    ",1
 dc.b "     Sorry , but you lose ....      ",1
 dc.b "                                    ",1
 dc.b "",1
 dc.b 0
 even
;*************************************************************************
;*********************** SECTION BSS *************************************
;*************************************************************************

   SECTION BSS
mit
debut_bss

sauve_palette ds.w 16
debut_icone   ds.l 1
debut_ecran   ds.l 1
debut_ecran_2 ds.l 1
debut_bordure ds.l 1
debut_score   ds.l 1
debut_face    ds.l 1
debut_heure   ds.l 1

buffer_ecran ds.l    10300		;zone d'affichage (avec bord bas)
								;  256                  placement ecran stf
								;+ (200x160)            ecran
								;+ (45x160)             bordure basse
								;+ ((236+16)-245)x160   depassement souris
								; = 40576 soit 10144 longs
sprite     ds.l ((256+128)*16)/4
fin_sprite

sauvegarde ds.l (1+256)/4

           ds.l 150		;reserve pour la pile
pile       ds.l 1
sauve_120  ds.l 1
sauve_134  ds.l 1
sauve_118  ds.l 1
sauve_70   ds.l 1
sauve_ssp  ds.l 1
sauve_usp  ds.l 1

sauv_ecran ds.l 8000	;apres le help,on retaure l'ecran d'origine

* grille de position des bombes et des chiffres
* plus grille des caches (drapeaux etc)
* plus  le compteur des drapeaux pos‚s.
*		le nombre de bombes
*		le niveau choisi
*		l'indicateur 1er essai
*
grille_bomb     ds.l ((nbr_col*nbr_ligne)/4)+1
grille_cache    ds.l ((nbr_col*nbr_ligne)/4)+1
nb_drapeau_mis  ds.w 1
nbr_bomb ds.w 1
niveau ds.b 1
premier_appui ds.b 1
.rien ds.w 1

* les compteurs de l'horloge.
*
nb_min_horl		ds.w 1
nb_sec_horl	   	ds.w 1
nb_cycle_horl	ds.b 1
.rien ds.b 1

yo
 ds.b  4*512-(yo-grille_bomb)

* espace de sauvegarde des grilles de bonbes et de cache
* plus le nb_drapeau. (pour UNDO)
*
copie_2_grille	ds.l ((((nbr_col*nbr_ligne)/4)+1)*2)
copie_nb_drapeau ds.w 1
.rien ds.w 1

* pour la sauvegarde sur disquette
handle ds.w 1
* pour voir si le joueur a gagne (avec nb_drapeau_mis)
nb_bomb_sous_drapeau ds.w 1
* pour memoriser l'explosion
on_a_touche ds.b 1
* pour savoir dans quel menu on est.
num_menu ds.b 1
* memoriser dans quel menu on est.
sauv_menu ds.b 1
* pour connaitre le niveau de depart.
niveau_defaut ds.b 1
* pour le v_sync
v_sync_ind ds.b 1
* pour arreter l'horloge
go_horloge ds.b 1
* pour dire … la vbl de ne pas interroger le clavier quand on lui cause
flag_clavier ds.b 1
* pour indiquer si il faut relancer le remplissage en recursif
relance_remplissage ds.b 1
* pour indiquer que le joueur a utilis‚ insert ou clr-home
emul_bouton ds.b 1
 even
* bss pour la gestion du scroll text .. mit !!
scrollapp ds.w 1
bufferscroll ds.w 21*16
offset_scroll ds.w 1
adr_scroll ds.l 1

n_drive ds.w 1

sauve_fa07 ds.b 1
sauve_fa09 ds.b 1
sauve_fa13 ds.b 1
sauve_fa15 ds.b 1
sauve_fa17 ds.b 1
sauve_fa1b ds.b 1
sauve_fa21 ds.b 1
sauve_820a ds.b 1
sauve_8260 ds.b 1
sauve_8203 ds.b 1
sauve_8201 ds.w 1

fin_bss    ds.l 2

 end