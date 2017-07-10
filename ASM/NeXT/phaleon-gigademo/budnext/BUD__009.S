 opt o+,d+,w+,ow-
;*********************************************************************
;  ****************** ROUTINES ECRITES PAR XAV *********************
;    *************************************************************
;
;		     #############  BUD NEXT  #############
;
;					VERSION 0.5 du 14/5/92
;
;def_ram_disque
def_vbl


*	Salut.
*	Voila le prg en l'‚tat
*
*	Il travaille d‚ja sur deux ecrans mais d'une facon speciale:
*	l'ecran precedent n'est pas effac‚, on le recupere et on y superpose
*	le nouveau sprite.
*	Donc si on veut arreter l'anim, il faut afficher deux fois de suite le
*	dernier sprite.
*	Par contre, c'est utile pour la fum‚e du fusil qui continue … bouger
*	alors que seul le coq en train de se desintegrer est encore modifi‚e.
*	
*	Le coq est une exception: affich‚ en transparent, il oblige … effacer
*	l'ancien sprite. j'ai memoris‚ le fond du coq et le restitue … chaques
*	fois. Ca marche bien car le fond ne bouge pas encore. le coq ne sera
*	plus l… lorsque la lune tombera.
*	
*	L'enchainement des animation est r‚gl‚ par la chaine de datas qui 
*	commence sur debut_attente_anim. il y a deja des repŠres.
*
*   les d‚lais sont des nombres de vbl sur des words (0-21 minutes)
*	
*	le chat et la fum‚e ont leur propre datas qui se termine par zero.
*	leur chaine d'attente peut s'allonger sans problŠme pour varier les
*	effets et ne pas paraitre trop repetitif.
*	Attention, chat et fum‚es sont ‚crit sur l'ecran physique. je pense
*	que l'on peut laisser comme ca car l'ecriture est rapide et sa dur‚e
*	est fixe: le soundtrack ne devrait pas etre gen‚.
*	
*	il reste l'animation de la lune et du soleil: j'ai deja un masque
*	dans arr_mask.pi1.
*
*	il suffit de copier le masque du sprite lune dans un buffer,
*	de coller dessus le morceau correspondant d'anti-masque (pris dans
*	arr_mask.pi1), de faire la meme chose pour le sprite lune
*	et ensuite de coller le masque masqu‚,puis le sprite masqu‚ sur l'ecran
*
*	ps: il y a parfois un decalage de plan au d‚part.
*	   pour l'instant, le clavier n'est pas vraiment test‚
*
*	Mit : fout pas trop le bordel, j'aimerais pouvoir dire que
*	c'est mon code majoritaire dans cet ‚cran.
*	
*	Avec de la chance,… samedi.

;**********************************************************************
;**************** Position des Sprites ********************************
;**********************************************************************

nb_eyes    EQU 7 		*nb de sprites yeux
nb_smokes  EQU 6 		*nb de sprites fum‚es maison

pos_smokes EQU 22*160+13*8	*position des sprites smokes … l'‚cran
pos_eyes   EQU 49*160+5*8	*position des yeux du chat
pos_volets EQU 132*160+7*8	*position du volets
pos_coqs   EQU 49*160+16*8  *position coq (complet ou tete)
pos_tetes  EQU 41*160+16*8
pos_chute  EQU 56*160+16*8	*chute du coq

pos_debut_texte EQU 50*160+1*8  *debut du texte

colonne_lune    EQU 15*8
colonne_soleil  EQU 3*8
pos_1_lune 		EQU 15*160+colonne_lune    *position haute de la lune
pos_haut_soleil EQU 15*160+colonne_soleil  *position haute du soleil

;**********************************************************************
;**************** MACRO DIVERSES **************************************
;**********************************************************************
 ifd def_vbl

v_sync macro
 move #0,v_sync_count
.wait_vbl\@
 cmp #\1,v_sync_count
 bne .wait_vbl\@
 endm

v_sync_d0 macro
 add v_sync_count,d0
 move d0,v_sync_wait
 add #1,d0
.wait_vbl\@
 cmp v_sync_count,d0
 bne .wait_vbl\@
 endm

 endc

attend_space macro
 move.l #$fffffc02,a0
wait_touch\@
 cmp.b #$39,(a0)
 bne wait_touch\@
 endm

prepare_change_ecran macro
 move.l debut_ecran_actif,a0
 move.l debut_ecran_travail,debut_ecran_actif
 move.l a0,debut_ecran_travail
 endm

fin_si_space macro
 move.l #$fffffc02,a0
 cmp.b #$39,(a0)
 beq fin
 endm
 

;*************************************************************************
;**************** CORPS DU PROGRAMME *************************************
;*************************************************************************

 SECTION TEXT
 move #0,-(sp)
 pea -1
 pea -1
 move #5,-(sp)
 trap #14
 lea 12(sp),sp
 
 pea partie_principale
 move.w #$26,-(sp)		;supexec
 trap #14
 addq.w #6,sp
 clr.w -(sp)			;term
 trap #1




PARTIE_PRINCIPALE:

 jmp efface_bss
fin_efface_bss 

;--------------------
;  Installe la pile
;--------------------
 move.l a7,sauve_ssp              piles <- (avec un s)
 move usp,a0
 move.l a0,sauve_usp
 lea pile,a7

;---------------------------------------------------
;  Sauvegarde de contexte graphique et debut ecran
;---------------------------------------------------
 move.w #$2700,sr

 movem.l $ffff8240.w,d0-d7        palette
 movem.l d0-d7,sauve_palette
 move.b $ffff8260.w,sauve_8260    r‚solution
 stop #$2300
 move.b #0,$ffff8260.w
 move.b $ffff820a.w,sauve_820a    fr‚quence
 move.b #2,$ffff820a.w
 move.l #buffer_ecran+256,d0          positionne ‚crans
 sf d0					;set if condition (false donc met $00 dans d0.b)
 move.l d0,debut_ecran_actif
 add.l #32000,d0
 move.l d0,debut_ecran_travail

 lea $ffff8201.w,a0
 movep.w 0(a0),d1		;charge adresse debut ecran
 move.w d1,sauve_8201

;------------------------
; remplis premier ecran
;------------------------
 move.l #pi1_maison,a0
 jsr aff_pi1
 
 prepare_change_ecran

 move.l #pi1_maison,a0
 jsr aff_pi1
 
;------------------------
; Init de smoke et eyes
;------------------------
 move #0,rang_smokes
 move debut_attente_smokes,attente_smokes
 move.l #debut_attente_smokes,adr_attente_smokes
 move #0,rang_eyes
 move debut_attente_eyes,attente_eyes
 move.l #debut_attente_eyes,adr_attente_eyes

;------------------------
; Init des anims
;------------------------
 move #pos_1_lune,pos_lune
 jsr aff_lune
 move #0,rang_volets
 jsr aff_volets
 jsr sauve_fond_coq
 move #0,rang_coqs
 jsr aff_coqs

 prepare_change_ecran
 
 jsr aff_lune
 jsr aff_volets
 jsr aff_coqs

 move debut_attente_anims,attente_anims
 move.l #debut_attente_anims,adr_attente_anims
 
;----------------
; Demarre la VBL
;----------------
 st go_anims

 move.l $70.w,sauve_70
 move.l #routine_vbl,$70.w
 move #$2300,sr

 move.l #palette_nuit,adr_palette_active
 bsr fondu_1


;***************
; ET HERE WE GO
;***************
 move #0,v_sync_count

; et le coq chantat pour la derniŠre fois
;----------------------------------------
 move #8,d6
boucle_chant_coq

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 add.w #(32/2)*32,rang_coqs		*sprite 32*32
 cmp.w #(32/2)*32*3,rang_coqs
 bne .pas_raz
 move #(32/2)*32,rang_coqs
.pas_raz
 jsr aff_coqs
 jsr donne_attente_suivante
 dbra d6,boucle_chant_coq

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 move #0,rang_coqs
 jsr aff_coqs
 jsr donne_attente_suivante

 move attente_anims,d0		* deux fois pour traiter les 2 ecrans
 prepare_change_ecran
 v_sync_d0
 jsr aff_coqs
 jsr donne_attente_suivante

; Les volets s'ouvrent et feu
;---------------------------- 
 move #23,d6
boucle_ouvre_volets

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr aff_volets
 add.w #(48/2)*32,rang_volets	*sprite 48*32
 jsr donne_attente_suivante
 dbra d6,boucle_ouvre_volets


; et vlan dans la sale bete
;--------------------------
 move #0,rang_coqs
 move #4,d6
boucle_boum_coq

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr aff_tetes
 add.w #(32/2)*16,rang_coqs		*sprite 32*16
 jsr aff_volets
 add.w #(48/2)*32,rang_volets	*sprite 48*32
 jsr donne_attente_suivante
 dbra d6,boucle_boum_coq

; fin de vlan dans la sale bete
;------------------------------
 move #3,d6
boucle_plus_coq

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr aff_tetes
 add.w #(32/2)*16,rang_coqs		*sprite 32*16
 jsr donne_attente_suivante
 dbra d6,boucle_plus_coq


; chute de la sale bete
;-----------------------
 move #0,rang_coqs
 move #8,d6
boucle_chute_coq

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr aff_chute
 add.w #(32*25/2),rang_coqs		*sprite 32*25
 jsr donne_attente_suivante
 dbra d6,boucle_chute_coq

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr remet_fond_coq
* jsr remet_fond_tete
 jsr donne_attente_suivante

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr remet_fond_coq
* jsr remet_fond_tete
 jsr donne_attente_suivante


; Les volets se ferment
;----------------------- 
 move #(24*32)*22,rang_volets
 move #21,d6
boucle_ferme_volets

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 sub.w #24*32,rang_volets
 jsr aff_volets
 jsr donne_attente_suivante
 dbra d6,boucle_ferme_volets

 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0
 jsr aff_volets
 jsr donne_attente_suivante

; La lune tombe
;--------------
 move.l #debut_position_lune,adr_position_lune
 
boucle_chute_lune
 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0

 move.l adr_position_lune,a6
 move (a6)+,d0
 move.l a6,adr_position_lune
 move #pos_1_lune,pos_lune
 add d0,pos_lune
 jsr aff_lune
 jsr donne_attente_suivante
 move.l adr_position_lune,a6
 cmp #$8000,(a6)
 bne boucle_chute_lune

; Le jour se leve
;----------------
 
 move.l #palette_journuit,adr_palette_active
 bsr fondu_1

; Le soleil monte
;----------------
 move.l #debut_position_soleil,adr_position_soleil
 
boucle_leve_soleil
 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0

 move.l adr_position_soleil,a6
 move (a6)+,d0
 move.l a6,adr_position_soleil
 move #pos_haut_soleil,pos_soleil
 add d0,pos_soleil
 jsr aff_soleil
 jsr donne_attente_suivante
 move.l adr_position_soleil,a6
 cmp #$8000,(a6)
 bne boucle_leve_soleil
 
 move attente_anims,d0
 prepare_change_ecran
 v_sync_d0

 move.l #palette_jour+15*32,adr_palette_active
 bsr fondu_0


;-----------------------
; Et on affiche le texte
;-----------------------
 sf go_anims
 move #0,pos_lettre

 move.l #palette_tableau,adr_palette_active
boucle_aff_texte
 jsr aff_texte
 jsr fondu_1
 move #150,d0
 v_sync_d0
 jsr fondu_0
 move pos_lettre,d0
 move.l #debut_texte,a0
 tst.b (a0,d0.w)
 bne boucle_aff_texte


;------------
; C'est Fini
;------------

; attente finale
; --------------
* move attente_anims,d0
* prepare_change_ecran
* v_sync_d0

fin
* attend_space

 move.w #$2700,sr

 ifd def_vbl
 move.l sauve_70,$70.w
 endc

 movem.l sauve_palette,d0-d7		;restaure palette initiale
 movem.l d0-d7,$ffff8240.w
 stop #$2300
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
;*************************************************************************
;*************************** EFFACE LA BSS *******************************
;*************************************************************************

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

;*************************************************************************
;************************* VBL/HBL ***************************************
;*************************************************************************

ROUTINE_VBL
;**********
 movem.l d0-a6,-(sp)

;-------------------------------
; indique qu'une vbl est pass‚e
;-------------------------------
 add #1,v_sync_count

 move.l adr_palette_active,a0
 movem.l (a0)+,d0-d7
 movem.l d0-d7,$ffff8240.w

 tst.b go_anims
 beq no_anims

;------------------------------------
; swappe l'ecran et la palette
;------------------------------------
 move v_sync_count,d0
 cmp v_sync_wait,d0
 bne .swappe_pas
 move.l debut_ecran_actif,d0
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep.w d0,0(a0) 

.swappe_pas
;-----------------------
; affichage de la fumee
;-----------------------
 jsr aff_smoke
 
;---------------------------
; affichage des yeux du chat
;---------------------------
 jsr aff_eyes


no_anims
;--------------------------------------
; Ici on met la musique ‚ventuellement
;--------------------------------------
* jsr music+8

;-----------------------------
; Calcul pour prochain smokes
;-----------------------------
 sub #1,attente_smokes
 bne .pas_changes_smokes

 move.l adr_attente_smokes,a0
 add.l #2,a0
 tst (a0)
 bne .pas_raz_smokes
 move.l #debut_attente_smokes,a0
.pas_raz_smokes
 move (a0),attente_smokes
 move.l a0,adr_attente_smokes

 add.w #8*48,rang_smokes
 cmp.w #8*48*(nb_smokes),rang_smokes
 bne .pas_changes_smokes
 move #0,rang_smokes
.pas_changes_smokes

;---------------------------
; Calcul pour prochain eyes
;---------------------------
 sub #1,attente_eyes
 bne .pas_change_eyes

 move.l adr_attente_eyes,a0
 add.l #2,a0
 tst (a0)
 bne .pas_raz_eyes
 move.l #debut_attente_eyes,a0
.pas_raz_eyes
 move (a0),attente_eyes
 move.l a0,adr_attente_eyes

 add.w #8*8,rang_eyes
 cmp.w #8*8*(nb_eyes),rang_eyes
 bne .pas_change_eyes
 move #0,rang_eyes
.pas_change_eyes

;---------------------
; On quitte notre VBL
;---------------------
 movem.l (sp)+,d0-a6

 rte


;*************************************************************************
;***************** SOUS PROGRAMME SYNCHRONISATION ************************
;*************************************************************************

donne_attente_suivante
;*********************
 move.l adr_attente_anims,a0
 add.l #2,a0
* tst (a0)								*
* bne .pas_raz_anims					*
* move.l #debut_attente_anims,a0		*bouclage inutile
*.pas_raz_anims							*
 move (a0),attente_anims
 move.l a0,adr_attente_anims
 rts

;*************************************************************************
;*********************** CHANGEMENT DE PALETTE ***************************
;*************************************************************************
fondu_1
 moveq #15-1,d7
.lop
 moveq #2,d0
 v_sync_d0
 add.l #32,adr_palette_active
 dbra d7,.lop
 rts

fondu_0
 moveq #15-1,d7
.lop
 moveq #2,d0
 v_sync_d0
 sub.l #32,adr_palette_active
 dbra d7,.lop
 rts
CHANGE_PALETTE
;*************
 move.l adr_palette_active,a0
 move.l adr_palette_arrivee,a1
 
 move #15,d4
.change_palette

 move.b (a1)+,d0
 cmp.b (a0)+,d0
 beq .fin1
 bmi .sub1
 add.b #1,-1(a0)
 bra.s .fin1
.sub1
 sub.b #1,-1(a0)
.fin1

 move.b (a0),d0
 move.b (a1),d1
 move.l d0,d2
 move.l d1,d3

 lsr.b #4,d0
 lsr.b #4,d1
 cmp.b d0,d1
 beq .fin2
 bmi .sub2
 add.b #1,d0
 bra.s .fin2
.sub2
 sub.b #1,d1
.fin2

 and #$f,d2
 and #$f,d3
 cmp.b d2,d3
 beq .fin3
 bmi .sub3
 add.b #1,d2
 bra.s .fin3
.sub3
 sub.b #1,d3
.fin3
 lsl.b #4,d0
 lsl.b #4,d1
 or.b d2,d0
 or.b d3,d1
 move.b d0,(a0)+
 move.b d1,(a1)+

 dbra d4,.change_palette

;*************************************************************************
;************************ AFFICHAGE DU TEXTE *****************************
;*************************************************************************
AFF_TEXTE
;********
 lea pi1_tableau,a0
 jsr aff_pi1

 move #0,numero_ligne

boucle_text
 move.l debut_ecran_actif,a0
 lea pos_debut_texte(a0),a0
 move numero_ligne,d0
 mulu #(20*160),d0
 adda.w d0,a0

boucle_text1
 lea debut_texte,a1
 add pos_lettre,a1
 addq #1,pos_lettre
 
 cmp.b #$11,(a1)
 beq fin_aff_texte
 cmp.b #$13,(a1)
 bne aff_1_lettre
 addq #1,numero_ligne
 bra boucle_text

fin_aff_texte
 rts


fnt dc.b " ABCDEFGHIJKLMNOPQRSTUVWXYZ.,!?()",0
 even
AFF_1_LETTRE
 moveq #0,d0
 move.b (a1),d0
 cmp.b #"a",d0
 blt.s .autre
 cmp.b #"z",d0
 bge.s .autre
 add #"A"-"a",d0
.autre
 lea fnt,a2
.boucle_recherhe
 move.b (a2)+,d1
 bne.s .suite
 moveq #0,d0
 bra.s .suite1
.suite
 cmp.b d1,d0
 bne.s .boucle_recherhe
 sub.l #fnt+1,a2
 move a2,d0
.suite1
 lea rockfont,a1
 lsl #8,d0
 add d0,a1
 move.l a0,a2
 move #15,d0
.aff_lettre
 move.l (a1)+,(a2)+
 move.l (a1)+,(a2)+
 move.l (a1)+,(a2)+
 move.l (a1)+,(a2)+
 adda.l #(160-(32/2)),a2
 dbra d0,.aff_lettre
 lea 16(a0),a0
 bra boucle_text1

;*************************************************************************
;***************** SOUS PROGRAMMES D'AFFICHAGE ***************************
;*************************************************************************
AFF_PI1
;**********
;affiche une image pi1 sur l'ecran principal
;adresse de depart dans a0.
;


* addq.w #2,a0
* movem.l (a0)+,d0-d7
* movem.l d0-d7,$ffff8240.w

 lea 34(a0),a0

 move.l debut_ecran_actif,a1
 move.w #(160*200)/4-1,d0
.recop
 move.l (a0)+,(a1)+
 dbra d0,.recop
 rts

AFF_SMOKE
;*******
; smokes      = label des sprites
; rang_smoke  = decalage pour le sprite utile
; pos_smoke   = position sur l'ecran
 move.l #smokes,a0
 adda.w rang_smokes,a0
 moveq #0,d0
 move.b $ffff8201.w,d0
 swap d0
 move.b $ffff8203.w,d0
 lsl #8,d0
 move.l d0,a1
 adda.w #pos_smokes,a1
 
 move #47,d0
.boucle_smoke
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 adda.w #160-8,a1
 dbra d0,.boucle_smoke

 rts

AFF_EYES
;*******
 move.l #cat_eyes,a0
 adda.w rang_eyes,a0
 moveq #0,d0
 move.b $ffff8201.w,d0
 swap d0
 move.b $ffff8203.w,d0
 lsl #8,d0
 move.l d0,a1
 adda.w #pos_eyes,a1
 move.l #masque_fond,a2
 adda.w #pos_eyes,a2
 
 move #7,d0
.boucle_eyes
 move.l (a2)+,d2
 and.l d2,(a1)
 move.l (a0)+,d1
 or.l d1,(a1)+
 move.l (a2)+,d2
 and.l d2,(a1)
 move.l (a0)+,d1
 or.l d1,(a1)+
 adda.w #160-8,a1
 adda.w #160-8,a2
 dbra d0,.boucle_eyes

 rts

AFF_VOLETS
;*********
 move.l #volets,a0
 adda.w rang_volets,a0
 move.l debut_ecran_travail,a1
 adda.w #pos_volets,a1
 
 move #31,d0
.boucle_volets
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 adda.w #160-(3*8),a1
 dbra d0,.boucle_volets

 rts

AFF_COQS
;*******

 jsr remet_fond_coq

 move.l #les_coqs,a0
 adda.w rang_coqs,a0
 move.l #msk_coqs,a2
 adda.w rang_coqs,a2
 move.l debut_ecran_travail,a1
 adda.w #pos_coqs,a1
 
 move #31,d0
.boucle_coqs

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 adda.w #160-(2*8),a1
 dbra d0,.boucle_coqs

 rts

AFF_TETES
;********

 jsr remet_fond_tete

 move.l #tetes_coq,a0
 adda.w rang_coqs,a0
 move.l #msk_tetes,a2
 adda.w rang_coqs,a2
 move.l debut_ecran_travail,a1
 adda.w #pos_tetes,a1
 
 move #15,d0
.boucle_tetes

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 move.l (a1),d1
 and.l (a2)+,d1
 or.l  (a0)+,d1
 move.l d1,(a1)+

 adda.w #160-(2*8),a1
 dbra d0,.boucle_tetes

 rts

AFF_CHUTE
;********

 jsr remet_fond_coq

 move.l #chute_coqs,a0
 adda.w rang_coqs,a0
 move.l #msk_chute,a2
 adda.w rang_coqs,a2
 move.l debut_ecran_travail,a1
 adda.w #pos_chute,a1
 move.l #masque_fond,a3
 adda.w #pos_chute,a3
 
 move #24,d0
.boucle_coqs

 rept 4
 move.l (a3)+,d1
 not.l d1
 or.l (a2)+,d1
 and.l d1,(a1)

 move.l (a0)+,d2
 not.l d1
 and.l d1,d2
 or.l d2,(a1)+
 endr

 adda.w #160-(2*8),a1
 adda.w #160-(2*8),a3
 dbra d0,.boucle_coqs

 rts

;*************************************************************************
;************* COQS EN TRANSPARENT SUR LE CIEL ET LA LUNE ****************
;*************************************************************************
SAUVE_FOND_COQ
;**************
 move.l #fond_tete,a1
 move.l debut_ecran_travail,a0
 adda.w #pos_tetes,a0
 
 move #39,d0
.boucle_coqs

 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 adda.w #160-(2*8),a0
 dbra d0,.boucle_coqs

 rts

REMET_FOND_COQ
;**************
 move.l #fond_coq,a0
 move.l debut_ecran_travail,a1
 adda.w #pos_coqs,a1
 
 move #31,d0
.boucle_coqs

 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 adda.w #160-(2*8),a1
 dbra d0,.boucle_coqs

 rts

REMET_FOND_TETE
;**************
 move.l #fond_tete,a0
 move.l debut_ecran_travail,a1
 adda.w #pos_tetes,a1
 
 move #15,d0
.boucle_coqs

 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 adda.w #160-(2*8),a1
 dbra d0,.boucle_coqs

 rts

;*************************************************************************
;********************** MOUVEMENT LUNE/SOLEIL ****************************
;*************************************************************************
AFF_LUNE
;*********
						; retaure l'ancien fond d'ecran
						;-------------------------------
 move.l #maison,a0
 move.l debut_ecran_travail,a1
 adda #colonne_lune,a0
 adda #colonne_lune,a1
 jsr remet_fond_lune
						; copie masque dans buffer temporaire
						;------------------------------------
 move.l #msk_lune,a0
 move.l #copie_msk,a1
 jsr move_sprite

						; transforme masque
						;------------------
 move.l #masque_fond,a0
 adda.w pos_lune,a0
 move.l #copie_msk,a1
 jsr and_ecran_sprite

 move.l #copie_msk,a0
 jsr neg_sprite

						; applique masque sur ecran travail
						;----------------------------------
 move.l #copie_msk,a0
 move.l debut_ecran_travail,a1
 adda.w pos_lune,a1
 jsr and_sprite_ecran


						; copie sprite dans buffer temporaire
						;------------------------------------
 move.l #la_lune,a0
 move.l #copie_lune,a1
 jsr move_sprite

						; transforme sprite
						;------------------
 move.l #masque_fond,a0
 adda.w pos_lune,a0
 move.l #copie_lune,a1
 jsr and_ecran_sprite

						; applique sprite sur ecran travail
						;----------------------------------
 move.l #copie_lune,a0
 move.l debut_ecran_travail,a1
 adda.w pos_lune,a1
 jsr or_sprite_ecran

 rts

AFF_SOLEIL
;*********
						; retaure l'ancien fond d'ecran
						;-------------------------------
 move.l #maison,a0
 move.l debut_ecran_travail,a1
 adda #colonne_soleil,a0
 adda #colonne_soleil,a1
 jsr remet_fond_lune
						; copie masque dans buffer temporaire
						;------------------------------------
 move.l #msk_soleil,a0
 move.l #copie_msk,a1
 jsr move_sprite

						; transforme masque
						;------------------
 move.l #masque_fond,a0
 adda.w pos_soleil,a0
 move.l #copie_msk,a1
 jsr and_ecran_sprite

 move.l #copie_msk,a0
 jsr neg_sprite

						; applique masque sur ecran travail
						;----------------------------------
 move.l #copie_msk,a0
 move.l debut_ecran_travail,a1
 adda.w pos_soleil,a1
 jsr and_sprite_ecran


						; copie sprite dans buffer temporaire
						;------------------------------------
 move.l #le_soleil,a0
 move.l #copie_lune,a1
 jsr move_sprite

						; transforme sprite
						;------------------
 move.l #masque_fond,a0
 adda.w pos_soleil,a0
 move.l #copie_lune,a1
 jsr and_ecran_sprite

						; applique sprite sur ecran travail
						;----------------------------------
 move.l #copie_lune,a0
 move.l debut_ecran_travail,a1
 adda.w pos_soleil,a1
 jsr or_sprite_ecran

 rts

MOVE_SPRITE
;********** 
x set 0
 rept 49
 movem.l (a0)+,d1-d7/a3
 movem.l d1-d7/a3,x(a1)
x set x+32
 endr
 rts

NEG_SPRITE
;********** 
 moveq #49-1,d0
.boucle_lune
 rept 8
 not.l (a0)+
 endr
 dbra d0,.boucle_lune
 rts

AND_ECRAN_SPRITE
;*************** 
 move.l #49,a2
.boucle_lune
 movem.l (a0)+,d0-d7
 and.l d0,(a1)+
 and.l d1,(a1)+
 and.l d2,(a1)+
 and.l d3,(a1)+
 and.l d4,(a1)+
 and.l d5,(a1)+
 and.l d6,(a1)+
 and.l d7,(a1)+
 adda.w #160-(4*8),a0
 subq.l #1,a2
 move a2,d0
 bne.s .boucle_lune
 rts

AND_SPRITE_ECRAN
;*************** 
 move.l #49,a2
.boucle_lune
 movem.l (a0)+,d0-d7
 and.l d0,(a1)+
 and.l d1,(a1)+
 and.l d2,(a1)+
 and.l d3,(a1)+
 and.l d4,(a1)+
 and.l d5,(a1)+
 and.l d6,(a1)+
 and.l d7,(a1)+
 adda.w #160-(4*8),a1
 subq.l #1,a2
 move a2,d0
 bne.s .boucle_lune
 rts

OR_SPRITE_ECRAN
;************** 
 move.l #49,a2
.boucle_lune
 movem.l (a0)+,d0-d7
 or.l d0,(a1)+
 or.l d1,(a1)+
 or.l d2,(a1)+
 or.l d3,(a1)+
 or.l d4,(a1)+
 or.l d5,(a1)+
 or.l d6,(a1)+
 or.l d7,(a1)+
 adda.w #160-(4*8),a1
 subq.l #1,a2
 move a2,d0
 bne.s .boucle_lune
 rts


REMET_FOND_LUNE
;**************
 lea 14*160(a1),a1
 lea 14*160(a0),a0
 moveq #80,d7
.boucle_fond_lune
 movem.l (a0)+,d0-d6/a3
 movem.l d0-d6/a3,(a1)
 lea 160-4*8(a0),a0
 lea 160(a1),a1
 dbra d7,.boucle_fond_lune
 rts

;*************************************************************************
;********************** SECTION DATA *************************************
;*************************************************************************

   SECTION DATA

 EVEN

debut_texte dc.b "STARRING",$13
			dc.b "PAGE",$11
			dc.b "ET VOILA",$13
			dc.b " BYE",$11
			dc.b 0





debut_attente_smokes dc.w 10,11,8,10,7,12,9,0
debut_attente_eyes   dc.w 350,10,10,10,10,10,5
					 dc.w 150,10,10,10,10,10,5,0

debut_attente_anims
* chant du coq (10 affichages)
					 dc.w 10,10,10,10,10,10,10,10,10,10
* arret chant
					 dc.w 10,10 
* sequence ouvre volets(29 sprites)
                     dc.w 50,10,10,10,10,10,10,10,10,10
					 dc.w 10,10,10,10,10,10,10,10,10
					 dc.w 10				*armement 1
					 dc.w 10				*armement 2
					 dc.w 10,10				*leve fusil
					 dc.w 10				*debut coup de feu

* fin coup de feu + mort du coq
					 dc.w 10,5,5,5,5

* mort du coq
					 dc.w 10,10,10,10

* chute du cadavre
					 dc.w 10,10,10,10,10,10,10,10,10
					 dc.w 10,10
					 
* sequence ferme volets (22 sprites)
debut_attente_volets dc.w 20,10				*baisse fusil
					 dc.w 5,5
					 dc.w 10,10,10,10,10,10,10,10,10
					 dc.w 10,10,10,10,10,10,10,10,10
					 dc.w 10

* chute de la lune (attente)
 dcb 5,6
 dcb 5,5
 dcb 5,4
 dcb 10,2
 dcb 4,1
* lever du jour (change palette)
					 dc.w 10,10,10,10,10,10,10,10
* arrivee soleil (attente)
					 dc.w 10,10,10,10,10,10,10,5,5,5,5,5,5,5
* affichage de texte
					 dc.w 10,10,10,10

* attente finale
					 dc.w 10,0



* chute de la lune (position = nb attente -1)
debut_position_lune
					dc.w 1*160,2*160,3*160,5*160,8*160
x set 13*160
	rept 24
	dc x
x set x+3*160
	endr
 	dc.w $8000
debut_position_soleil
					dc.w 50*160,45*160,40*160,30*160,20*160
					dc.w 10*160,5*160,-1*160,0,1*160,0
					dc.w -1*160,0,0,$8000

 EVEN

 ifd def_ram_disque
volets      incbin d:\volets.dat
smokes      incbin d:\smoke.dat
tetes_coq   incbin d:\le_coq3.dat 
les_coqs    incbin d:\le_coq2.dat
chute_coqs  incbin d:\coq_fall.dat
la_lune     incbin d:\la_lune.dat
le_soleil   incbin d:\le_sun.dat
cat_eyes    incbin d:\cat_eyes.dat
pi1_maison	incbin d:\arr_plan.pi1
pi1_masque	incbin d:\arr_mask.pi1
pi1_tableau incbin d:\wings.pi1
rockfont    ds.w 128
	incbin d:\rockfont.dat
palette_tableau incbin d:\wings.pal
palette_jour incbin d:\jour.pal
palette_nuit incbin d:\nuit.pal
palette_journuit incbin d:\nuitjour.pal
 elseif
volets      incbin volets.dat
smokes      incbin smoke.dat
tetes_coq   incbin le_coq3.dat 
les_coqs    incbin le_coq2.dat
chute_coqs  incbin coq_fall.dat
la_lune     incbin la_lune.dat
le_soleil   incbin le_sun.dat
cat_eyes    incbin cat_eyes.dat
pi1_maison	incbin arr_plan.pi1
pi1_masque	incbin arr_mask.pi1
pi1_tableau incbin wings.pi1
rockfont    ds.w 128
	incbin rockfont.dat
palette_tableau incbin wings.pal
palette_jour incbin jour.pal
palette_nuit incbin nuit.pal
palette_journuit incbin nuitjour.pal
 endc

msk_tetes   EQU tetes_coq+(9*32*16/2) 
msk_coqs    EQU les_coqs+(32*32*3/2)
msk_chute   EQU chute_coqs+(32*25*9/2)
msk_lune    EQU la_lune+(64*49/2)
msk_soleil  EQU le_soleil+(64*49/2)

pal_maison  EQU pi1_maison+2
maison      EQU pi1_maison+34
masque_fond EQU pi1_masque+34
tableau     EQU pi1_tableau+34

;*************************************************************************
;*********************** SECTION BSS *************************************
;*************************************************************************

   SECTION BSS
debut_bss

adr_position_lune     ds.l 1
adr_position_soleil   ds.l 1

adr_attente_smokes  ds.l 1
adr_attente_eyes    ds.l 1
adr_attente_anims   ds.l 1
attente_smokes ds.w 1
attente_eyes   ds.w 1
attente_anims  ds.w 1
rang_smokes	ds.w 1		*position du sprites sur les 6 dans "smokes"
rang_eyes	ds.w 1		*idem pour les 6 yeux de chats
rang_volets ds.w 1		*idem pour les volets
rang_coqs   ds.w 1

pos_lune	ds.w 1
pos_soleil  ds.w 1

debut_ecran_actif   ds.l 1
debut_ecran_travail ds.l 1
buffer_ecran 	ds.l    (32000/4)+256		;zone d'affichage
				ds.l 	(32000/4)

fond_tete  ds.l (32*(16-8))/8	*buffers de sauvegarde du fonds du coq
fond_coq   ds.l (32*32)/8		*les sprites tete et coq se recoupent
								* 8 lignes sur 16 pour tete et 32 pour coq

copie_lune ds.l (64*49)/8	*buffer de travail pour la lune
copie_msk  ds.l (64*49)/8	*et son masque

adr_palette_active  ds.l 1
adr_palette_arrivee ds.l 1

go_anims ds.b 1

pos_lettre   ds.w 1
numero_ligne ds.w 1

           ds.l 150		;reserve pour la pile
pile       ds.l 1
sauve_70   ds.l 1
sauve_ssp  ds.l 1
sauve_usp  ds.l 1
sauve_palette ds.w 16
sauve_820a ds.b 1
sauve_8260 ds.b 1
sauve_8201 ds.w 1

v_sync_count ds.w 1			* pour le v_sync
v_sync_wait  ds.w 1


fin_bss ds.l 1
 end
