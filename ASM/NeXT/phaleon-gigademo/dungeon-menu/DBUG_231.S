* carte 64*80....
bgt
finale=0
ste=1
 ifne finale
 org $5000
xp = $600 * 4
yp = ($600+4) * 4
di = ($600+4+4) * 4
map_connue = ($600+12) * 640
flag_ste = ($600+12+640+6) *2
flag_zik = ($600+12+640+8) *2
 endc

nombre_vbl=3
n_musique=1
tempo_message=50
vitesse_monstre=10

valeur_sol      = 0
valeur_mur      = 1
valeur_fontaine = 2
valeur_faux_mur = 3
valeur_force    = 4
valeur_gauche   = 5
valeur_droite   = 6
valeur_demitour = 7

valeur_plaque   = 4
valeur_porte    = 5
valeur_monstre  = 8

 opt o+,w-
 
*************************
*                       *
* Definition des macros *
*                       *
*************************

pause macro
 dcb.w \1,$4e71
 endm
  
teste_clavier macro
 move.b clavier,d0
 sf clavier

 cmp.b #$52,d0
 beq g_tourne_gauche
 cmp.b #$48,d0
 beq g_avance
 cmp.b #$47,d0
 beq g_tourne_droite
 cmp.b #$4b,d0
 beq g_gauche
 cmp.b #$50,d0
 beq g_recule
 cmp.b #$4d,d0
 beq g_droite
 ifeq finale
   cmp.b #$39,d0
   beq sort_boucle
 endc
 cmp.b #$72,d0
 beq entrer_porte
 cmp.b #$62,d0
 beq afficher_carte
 cmp.b #$61,d0
 bne.s .pas_zik
 not.b flag_zik
.pas_zik 
 cmp.b #$3b,d0
 bne.s .pas_f1
 move.l #status,adresse_messages
 move.b #12,n_message
 move.b #tempo_message,duree_message
 sf type_clavier
.pas_f1
 cmp.b #$3c,d0
 bne.s .pas_f2
 move.l #status,adresse_messages
 move.b #13,n_message
 move.b #tempo_message,duree_message
 move.b #1,type_clavier
.pas_f2
 cmp.b #$3d,d0
 bne.s .pas_f3
 move.l #status,adresse_messages
 move.b #14,n_message
 move.b #tempo_message,duree_message
 move.b #2,type_clavier
.pas_f3
sort_boucle_test 
 endm

vsync macro
 moveq #1,d0
 lea synchro_flag,a0
.attend_synchro
 cmp.b (a0),d0
 bne.s .attend_synchro
 sf (a0)
 endm

***********************
*                     *
* Programme principal *
*                     *
***********************
;
;
;                   THE DUNGEON MAIN MENU
;
;              First version in 1989... (Brand new !)
;                  Copyright 1990 T.T.Z.P. Inc.
;                       and 1991 NEXT
;   
;                      Coded by Dbug II
;            Graphix by Pulsar, Dbug II and Chromix.
;
;
 
 ifeq finale
   pea debut_programme
   move.w #$26,-(sp)
   trap #14
   addq.l #6,sp
   clr.w -(sp)
   trap #1
 endc
 
debut_programme
 move.w #$2700,sr
 jmp efface_bss
fin_efface_bss 
 move.l sp,sauve_ssp
 lea ma_pile,sp
 move usp,a0
 move.l a0,sauve_usp
 move.w #$2300,sr
 jsr sauve_interruptions
 jsr make_screens
 ifeq finale
   jsr screen_choc
 endc
 move.l #status,adresse_messages
 move.b #tempo_message,duree_message
 sf n_message
* move.w #15,x_monstre   * Dans le couloir de d‚part
* move.w #41,y_monstre
* move.w #03,d_monstre
; move.w #44,x_monstre   * Dans la salle aux faux murs
; move.w #51,y_monstre
; move.w #01,d_monstre
* move.w #25,x_monstre   * Dans le p‚rimetre Delta Force
* move.w #21,y_monstre
* move.w #01,d_monstre
; move.w #17,x_monstre   * Dans la salle HMD
; move.w #25,y_monstre
; move.w #01,d_monstre
* move.w #10,x_monstre   * Dans la zone Chaotike
* move.w #3,y_monstre
* move.w #03,d_monstre
 move.w #21,x_monstre   * Dans le p‚rimetre de d‚part
 move.w #51,y_monstre
 move.w #01,d_monstre
 move.b #vitesse_monstre,v_monstre
 ifeq finale
   move.l #2,di
   move.l #3,xp
   move.l #41,yp
   ifeq ste
     sf flag_zik
     sf flag_ste
   elseif
     st flag_zik
     st flag_ste
   endc
 endc
 jsr affiche_dongeon
 stop #$2300
 move.l #palette_dongeon,palette_affichee
 move.b #1,fading_flag
 sf fading_pos
 bsr reverse_cotes
 bsr reverse_sol
 move.l #palette_dongeon,palette_affichee
 move.b #-1,fading_flag
 jsr init_musique
 jsr conversion_du_texte
 tst.b flag_ste
 beq.s .attend_fin_fading
 jsr convertion_samples
.attend_fin_fading
 jsr convertion_water
 tst.b fading_flag
 bne.s .attend_fin_fading
 sf flag_swapping
 jsr lance_interruptions

loop

*************************
*                       *
* On affiche le plafond * 7520
*                       * 
*************************

 lea plafond,a0
 move.l xp,d0
 add.l yp,d0
 btst #0,d0
 bne normal 
 lea r_plafond,a0
normal

 move.l buf1,a1
var set 0

 rept 144
 movem.l (a0)+,d0-d7/a2-a6
 movem.l d0-d7/a2-a6,var(a1)
var set var+52
 endr
 movem.l (a0)+,d0-d7
 movem.l d0-d7,var(a1)
var set var+32

****************************************
*                                      *
* On efface entre le plafond et le sol * 8480
*                                      *
****************************************

 moveq #0,d0
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l d0,a2
 move.l d0,a3
 move.l d0,a4
 move.l d0,a5
 move.l d0,a6
;
; 12 registres x4 -> 48 octets
;
; Effacer en 20 fois 424 octets
;
 lea var(a1),a1
 moveq #19,d7
.efface_entre
var set 0
 rept 8
 movem.l d0-d6/a2-a6,var(a1)
var set var+48
 endr
 movem.l d0-d6/a2-a4,var(a1)
 lea 424(a1),a1
 dbra d7,.efface_entre

*********************
*                   *
* On affiche le sol * 16000
*                   *
*********************
 
affiche_sol
;
; 16000 octets … afficher en 20 fois soit 20x800
; 48 octets par movem
;
 moveq #19,d7
.recopie_sol 
var set 0
 rept 16
 movem.l (a0)+,d0-d6/a2-a6
 movem.l d0-d6/a2-a6,var(a1)
var set var+48
 endr
 movem.l (a0)+,d0-d6/a2
 movem.l d0-d6/a2,var(a1)
 lea 800(a1),a1
 dbra d7,.recopie_sol

**********************************************
*                                            *
* Ici, on fait les calculs de positionnement *
*             et de clipping                 *
*                                            *          
**********************************************

pas_fonds

***********************
*                     *
* gestion de la carte *
*                     *
***********************
 
;
; On d‚termine la position du beholder sur la carte (adresse)
;
ecrit_beholder_carte
 lea carte,a0
 move.l a0,a6
 move.w y_monstre,d0
 lsl #6,d0
 add.w d0,a6
 move.w x_monstre,d0
 add.w d0,a6           * ADRESSE DU MONSTRE SUR LA CARTE
   
charge_carte
 lea v_charge,a0
 move.l di,d0 
 lsl #2,d0
 move.l 0(a0,d0),a1
 lea carte,a0
 move.l yp,d0
 move.l xp,d1
 jmp (a1)

charge_1 
 lea c_1,a2
 subq.b #3,d0
 subq.b #1,d1
 bra fin_charge

charge_3
 lea c_3,a2
 subq.b #1,d0    ; pour arriere
 subq.b #1,d1
 bra fin_charge

charge_0
 lea c_0,a2
 subq.b #1,d0
 subq.b #3,d1
 bra fin_charge

charge_2 
 lea c_2,a2
 subq.b #1,d0
 subq.b #1,d1

fin_charge
 lsl.w #6,d0
 add.l d0,a0
 add.l d1,a0
 lea bloc_map,a1
 lea bloc_map_objets,a3

 move.l buf1,a4       *********!!!!
 lea 32000+80(a4),a4 
 move.l #0,(a4)
 move.l #0,4(a4)

 moveq #15-1,d0
.charge_suivant 
 moveq #0,d3
 move.w (a2)+,d1
 lea 0(a0,d1.w),a4
 move.b (a4),d2
 cmpa.l a6,a4
 bne.s .pas_de_monstre
 moveq #valeur_monstre,d3
.pas_de_monstre  
 move.b d2,(a1)+
 move.b d3,(a3)+
 dbra d0,.charge_suivant
;
; On stocke les 9 cases autour dans la nouvelle map
;
 lea map_connue,a0
 move.l yp,d0
 subq #1,d0
 lsl #3,d0
 add.l d0,a0

 move.l xp,d1
 subq #1,d1
 move.l d1,d0
 lsr.l #3,d0
 add.l d0,a0

 move.l a0,a1
 move.l a0,a2
 and #%111,d1
 moveq #7,d0
 sub d1,d0
 move d0,d1
 subq #1,d1
* tst d1
 bge.s .okay_bit1
 addq #1,a1
 move.l a1,a2
 moveq #7,d1
 moveq #6,d2
 bra.s .okay_f_bit
.okay_bit1

 move d1,d2
 subq #1,d2
 tst d2
 bge.s .okay_f_bit
 addq #1,a2
 moveq #7,d2
.okay_f_bit
 
var set 0
 rept 3
 bset.b d0,var(a0)
 bset.b d1,var(a1)
 bset.b d2,var(a2)
var set var+8
 endr
  
****************************
*
* charge la carte des murs *
*
****************************

charge_mur_et_cote
 lea bloc_map,a0      ; remplissage table des murs
 lea mur_map,a1
 move.l (a0)+,(a1)+   ; 9 octets transf‚r‚s
 move.l (a0)+,(a1)+
 move.b (a0)+,(a1)+

 lea bloc_map,a0     ; remplissage table des cotes
 lea cote_map,a1
var set 0
 rept 8
 move.b var+0(a0),(a1)+ 
 move.b var+2(a0),(a1)+
var set var+3
 endr
;
; On recherche des t‚l‚porteurs dans la table des cot‚s...
; Si oui on vire...
;
 lea cote_map,a0
 moveq #7,d0
cherche_pentacle_suivant
 cmp.b #64,(a0)+
 blt.s .pas_encore
 sf -1(a0) 
.pas_encore 
 dbra d0,cherche_pentacle_suivant 
;
; On recherche la pr‚sence de champs de force... Si oui, on efface !
;  
 lea mur_map,a0
 moveq #17,d0
recherche_force
 cmp.b #valeur_force,(a0)
 bne.s .suivant_1
 sf (a0)
.suivant_1
 cmp.b #valeur_gauche,(a0)
 blt.s .suivant_2
 cmp.b #64,(a0)
 bge.s .suivant_2
 sf (a0)
.suivant_2
 addq.w #1,a0
 dbra d0,recherche_force
;
; On affiche les pentacles sur le sol
;
affiche_pentacles_sol
 lea mur_map,a0
 lea pentacle_rout,a1
 moveq #9-1,d0
pentacle_suivant
 move.l (a1)+,a2
 cmp.b #64,(a0)+
 blt.s .suite
 sf -1(a0) 
 jsr (a2)
.suite 
 dbra d0,pentacle_suivant

**********************************
*                                *
*     Routine de clipping        *
* Effacement des murs invisibles *
*                                *
**********************************

clipping
 lea cote_map,a0
 lea mur_map,a1
 moveq #0,d0
 bsr clip_fonds
 bsr clip_milieu
 bsr clip_devant
 bsr clip_cotes

 bsr determine_palette

********************************
*                              *
* Routines 3D (c) 1989 Dbug II *
*                              *
********************************
 
affiche_3d_murs_cotes
 lea ordre,a0
 lea mur_map,a1          ; !!!! ne pas toucher d0
 lea v_ordre,a2          ; !!!! eviter d1/d2
 lea bloc_map_objets,a3
   
 moveq #5,d0
case_suivante

 moveq #0,d1
 move.w (a0)+,d2         ; d2 -> no de la case
 move.b 0(a3,d2),d1   *** Je yen a test‚ monstre !
 beq .ya_pas_monstre 
 movem.l d0-a6,-(sp)
 jsr affiche_monstre
 movem.l (sp)+,d0-a6
.ya_pas_monstre
 move.b 0(a1,d2),d1      ; d1 -> type de la case
 tst.b d1  
 beq.s saute_case
 bpl.s .pas_une_porte
 cmpi.b #192,d1
 bgt.s .une_porte
 move.b #valeur_plaque,d1
 bra.s .pas_une_porte
.une_porte
 move.b #valeur_porte,d1
.pas_une_porte 

 lsl.l #2,d2
 move.l 0(a2,d2),a6      ; a6 -> v_??? 

 move.l d1,d2
 subq.w #1,d2
 lsl.l #2,d2
 move.l 0(a6,d2),adresse_mur   ; a6 -> adresse du mur … afficher

 move.l (a0),a6
 movem.l d0-d7/a0-a6,-(sp)
 jsr (a6)
 movem.l (sp)+,d0-d7/a0-a6
 
saute_case
 addq.l #4,a0
 dbra d0,case_suivante
 
********************
***               **
**  affiche cotes  *
***               **
********************

affiche_3d_cotes
 lea cote_map,a1         ; !!!! ne pas toucher d0
 lea ordre_cotes,a0
 moveq #7,d0
cote_nxt 
 moveq #0,d1
 move.b (a1)+,d1    ; d1 type de la case
 move.l (a0)+,a2    ; routine o— il faut aller
 move.l (a0)+,a3    ; position du mur...
 tst.b d1
 beq.s pas_cote
 bpl.s .pas_une_porte
 cmpi.b #192,d1
 bgt.s .une_porte
 move.b #valeur_plaque,d1
 bra.s .pas_une_porte
.une_porte
 move.b #valeur_porte,d1
.pas_une_porte 

 move.l d1,d2
 subq.w #1,d2
 lsl.l #2,d2
 move.l 0(a3,d2),adresse_mur   *a3

 cmp.b #valeur_mur,d1
 bne.s .pas_mur
 move.l xp,d2
 add.l yp,d2
 and.l #1,d2
 mulu #8808,d2
 add.l d2,adresse_mur
.pas_mur 

 movem.l d0-d7/a0-a6,-(sp)
 jsr (a2) 
 movem.l (sp)+,d0-d7/a0-a6
 
pas_cote 
 dbra d0,cote_nxt

*****************************
***                        **
**  affiche murs du centre  *
***                        **
*****************************

affiche_3d_murs_centre
 lea ordre+36,a0
 lea mur_map,a1          ; !!!! ne pas toucher d0
 lea v_ordre,a2          ; !!!! eviter d1/d2
 lea bloc_map_objets,a3
   
 moveq #2,d0
case_suivante_centre
 moveq #0,d1
 move.w (a0)+,d2         ; d2 -> no de la case
 move.b 0(a3,d2),d1   *** Je yen a test‚ monstre !
 beq .ya_pas_monstre 
 movem.l d0-a6,-(sp)
 jsr affiche_monstre
 movem.l (sp)+,d0-a6
.ya_pas_monstre
 move.b 0(a1,d2),d1      ; d1 -> type de la case
 tst.b d1  
 beq.s saute_case_centre
 bpl.s .pas_une_porte
 cmpi.b #192,d1
 bgt.s .une_porte
 move.b #valeur_plaque,d1
 bra.s .pas_une_porte
.une_porte
 move.b #valeur_porte,d1
.pas_une_porte 

 lsl.l #2,d2
 move.l 0(a2,d2),a6      ; a6 -> v_???
 move.l d1,d2
 subq #1,d2
 lsl.l #2,d2
 move.l 0(a6,d2),adresse_mur *a6      ; a6 -> adresse du mur … afficher

 move.l (a0),a6
 movem.l d0-d7/a0-a6,-(sp)
 jsr (a6)
 movem.l (sp)+,d0-d7/a0-a6
 
saute_case_centre
 addq.l #4,a0
 dbra d0,case_suivante_centre
;
; On teste si on est devant une porte... Si oui on met un panneau...
;
 moveq #0,d0
 move.b bloc_map+7,d0
 cmp.b #valeur_fontaine,d0
 bne.s .pas_fontaine
 jsr rejoue_sample_water	
 bra.s .continue
.pas_fontaine
 clr loop_stf?
 tst.b flag_ste
 bne.s .ste_boucle_fontaine
 bra.s .continue
.ste_boucle_fontaine

 cmp.b #3,$ffff8901.w
 bne.s .continue
 sf $ffff8901.w
.continue

 tst.b d0
 bpl affiche_boussole
 neg.b d0 
 ext.w d0
 cmp.w #65,d0
 bge affiche_texte_plaque
 lea names,a0
 subq.w #1,d0
 move.l #carte+5120+12*6*64,adresse_messages
 move.b #tempo_message,duree_message
 move.b d0,n_message
 mulu #32*7,d0
 add.w d0,a0
 move.l buf1,a1
var set 160*48+80-16 
 rept 7
 movem.l (a0)+,d0-d7
 movem.l d0-d7,var(a1)
var set var+160 
 endr
 bra affiche_boussole
;
; Mais si on est devant une plaque, si oui on met du texte !
;
affiche_texte_plaque
 lea carte+5120,a0
 sub.w #65,d0
 mulu #12*6,d0
 add.w d0,a0
 move.l buf1,a1
 lea 160*42+8*4(a1),a1
 moveq #5,d0
.ligne_suivante
 moveq #11,d1
.caractere_suivant
 moveq #0,d2 
 move.b (a0)+,d2  
 lsl.l #7,d2
 lea fonte_plak,a2
 add.w d2,a2
var set 0
 rept 16
 move.l (a2)+,var(a1)
 move.l (a2)+,4+var(a1)
var set var+160
 endr
 addq.w #8,a1
 dbra d1,.caractere_suivant
 lea 160*17-8*12(a1),a1
 dbra d0,.ligne_suivante
;
; On affiche la boussole
;
affiche_boussole
 lea boussole+32,a0
 move.l di,d0
 add.w #2,d0
 and.w #%11,d0
 mulu #16*27,d0
 add.l d0,a0
 move.l buf1,a1
 add.l #32160+160*5,a1
var set 0
 rept 27
 movem.l (a0)+,d0-d3
 movem.l d0-d3,var(a1)
var set var+160
 endr
 
 subq.b #1,duree_message
 bne.s .pas_message_vide
 move.b #1,duree_message
 move.b #5,n_message
 move.l #status,adresse_messages
.pas_message_vide
 bsr affiche_message
;
; Si on est sur la meme case que le monstre...
;
 tst.b bloc_map_objets+10
 beq .ya_pas_monstre
 moveq #10,d2
 movem.l d0-a6,-(sp)
 jsr affiche_monstre
 movem.l (sp)+,d0-a6
.ya_pas_monstre
;
; N'oublions pas de gerer le mouvement du monstre
;
 subq.b #1,v_monstre
 bne.s .d‚place_pas_monstre
 jsr d‚place_monstre
 move.b #vitesse_monstre,v_monstre
.d‚place_pas_monstre

***************************
*                         *
*    Fin de l'affichage   *
*   On scrute le clavier  *
* Et on attend la synchro *
*                         *
***************************

vas_clavier 
 teste_clavier
fin_clavier 
 vsync
 bra loop

***************************
*                         *
*     Fin du programme    *
* Restitution du contexte *
*   Et retour au bureau   *
*                         *
***************************

sort_boucle
 move.b #-1,fading_flag
.attend_fin_fading
 tst.b fading_flag
 bne .attend_fin_fading
 
;
; Le num‚ro de la porte est en BSS dans "porte_choisie"
; le num‚ro va de 0 … 63
;
 
 bsr arrete_musique
 bsr restaure_interruptions
 move #$2700,sr
 move.l sauve_ssp,sp
 move.l sauve_usp,a0
 move a0,usp
 ifne finale
   move porte_choisie,d0
   jmp $1002
 elseif
   move #$2300,sr
   rts
 endc
 
affiche_message
 move.l buf1,a1
 lea 32160(a1),a1
 moveq #0,d0
 move.b n_message,d0
 move.l adresse_messages,a0
 mulu #18*2,d0
 add.w d0,a0 
 moveq #1,d0
.ligne_suivante
 moveq #17,d1
.caractere_suivant
 moveq #0,d2 
 move.b (a0)+,d2  
 lsl.l #7,d2
 lea fonte_or,a2
 add.w d2,a2
var set 16
 rept 16
 move.l (a2)+,var(a1)
 move.l (a2)+,4+var(a1)
var set var+160
 endr
 addq.w #8,a1
 dbra d1,.caractere_suivant
 lea 160*17-8*18(a1),a1
 dbra d0,.ligne_suivante
 rts

**********************************
*                                *
*     Routine principale de      *
* gestion de l'affichage de la   *
*            carte...            *
*                                *
**********************************

afficher_carte
 move.b #-1,fading_flag
.attend_fin_fading
 tst.b fading_flag
 bne .attend_fin_fading
affiche_la_carte_sur_l_ecran
 move.b #1,flag_swapping
 bsr afficher_carte_ecran
 move.l #status,adresse_messages
 move.b #6,n_message
 bsr affiche_message
 move.b #tempo_message,duree_message
 move.l #palette_old_map,palette_affichee
 move.l #palette_old_map,palette_suivante
 move.b #1,fading_flag
 sf fading_pos

 sf clavier
loop_carte
*
 moveq #1,d7
 jsr affiche_monstre_carte
 jsr d‚place_monstre
 moveq #15,d7
 jsr affiche_monstre_carte
*
 vsync
 move.b clavier,d0
 beq.s loop_carte
 cmp.b #$72,d0
 bne fin_loop_carte
 bsr entre_message_clavier 
fin_loop_carte  	
 
 move.b #-1,fading_flag
.attend_fin_fading
 tst.b fading_flag
 bne .attend_fin_fading

 move.l #status,adresse_messages
 move.b #5,n_message
 move.b #tempo_message,duree_message
 bsr affiche_message
 sf flag_swapping
 
 vsync
 move.l #palette_standard,palette_affichee
 move.l #palette_standard,palette_suivante
 move.b #1,fading_flag
 sf fading_pos
 sf clavier
 bra loop

;
; Cette routine saisie une phrase au clavier.
;
entre_message_clavier
 sf clavier
efface_ancien_message
 lea status+559,a5
 move.l a5,a3
 lea 16(a5),a6
 moveq #16-1,d0
.boucle_efface
 move.b #32,(a3)+
 dbra d0,.boucle_efface

 move.l a5,a3
 lea table_scan,a4
 moveq #0,d0
 move.b type_clavier,d0
 lsl.w #6,d0
 adda.w d0,a4 
.boucle_attente
 move.l #status,adresse_messages
 move.b #15,n_message
 bsr affiche_message
.attend_touche
 moveq #0,d0
 move.b clavier,d0
 beq.s .attend_touche
 bmi.s .attend_touche
 sf clavier
 cmp.b #$72,d0         Enter (Validation)
 beq valide_message
 cmp.b #$1c,d0         Return (Validation)
 beq valide_message
 cmp.b #$0e,d0         Backspace (Effacement)
 bne.s .pas_effacement_lettre
 cmpa.l a5,a3
 beq .boucle_attente
 move.b #32,-(a3)
 movem.l d0-a6,-(sp)
 jsr rejoue_sample_plop
 movem.l (sp)+,d0-a6
 bra .boucle_attente
.pas_effacement_lettre
 cmp.b #$39,d0
 bgt .boucle_attente
 cmpa.l a6,a3
 beq .boucle_attente
 move.b 0(a4,d0.w),d1
 bmi .boucle_attente
 move.b d1,(a3)+
 movem.l d0-a6,-(sp)
 jsr rejoue_sample_plop
 movem.l (sp)+,d0-a6
 bra .boucle_attente

valide_message
;
; Comparaison du message entr‚ avec la table des passwords
;
 lea password,a0
 lea status+559,a5
 moveq #0,d1              Num‚ro du message
.compare_suivant
 tst.w (a0)
 bmi message_echec
 move.l a0,a1
 move.l a5,a2
 moveq #16,d0
.compare_lettre_suivante
 cmp.b (a1)+,(a2)+ 
 bne .fin_lettre
 subq.b #1,d0
 bne .compare_lettre_suivante
 bra message_r‚ussite
.fin_lettre
 bra .compare_suivant

message_echec
 move.l #status,adresse_messages
 move.b #16,n_message
 bsr affiche_message

 moveq #25,d1
.attente
 vsync
 dbra d1,.attente
 rts

message_r‚ussite
 move.l #status,adresse_messages
 move.b #17,n_message
 bsr affiche_message

 moveq #25,d1
.attente
 vsync
 dbra d1,.attente
 rts
 
**********************************
*                                *
*     Routines de clipping       *
* Effacement des murs invisibles *
*                                *
**********************************

clip_fonds
 tst.b 1(a1)
 bne.s pas_mur_2
 rts
pas_mur_2
 move.b d0,0(a0)        Un mur du centre recouvre les deux cot‚s
 move.b d0,1(a0)        des murs adjacents.
 rts
 
clip_milieu
 tst.b 3(a1)
 beq.s milieu_4
 move.b d0,0(a1)     Le mur de gauche recouvre celui de derriere
milieu_4
 tst.b 4(a1)
 beq.s droite_5
 move.b d0,1(a1)     Le mur central recouvre celui derriere lui
 move.b d0,0(a0)     ainsi que les cot‚s des murs sur 2 rang‚es.
 move.b d0,1(a0)
 move.b d0,2(a0)
 move.b d0,3(a0)
droite_5 
 tst.b 5(a1)
 beq.s pas_droite_5
 move.b d0,2(a1)     Le mur de droite recouvre celui de derriere
pas_droite_5
 rts
 
clip_devant
 tst.b 6(a1)
 beq.s milieu_7
 move.b d0,3(a1)
milieu_7 
 tst.b 7(a1)
 beq.s droite_8
 move.b d0,1(a1)
 move.b d0,4(a1)
 move.b d0,0(a0)
 move.b d0,1(a0)
 move.b d0,2(a0)
 move.b d0,3(a0)
 move.b d0,4(a0)
 move.b d0,5(a0)
droite_8
 tst.b 8(a1)
 beq.s pas_droite_8
 move.b d0,5(a1)
pas_droite_8
 rts  
 
clip_cotes
 tst.b 6(a0)
 beq.s droite_8_bis
 move.b d0,6(a1)
droite_8_bis
 tst.b 7(a0)
 beq.s pas_droite_8_bis
 move.b d0,8(a1)
pas_droite_8_bis
 rts
   
**************
************** gestion du deplacement
**************

gere_case_pivot
 cmp.b #valeur_gauche,d0
 beq g_tourne_gauche
 cmp.b #valeur_droite,d0
 beq g_tourne_droite
 cmp.b #valeur_demitour,d0
 beq g_demitour
 bra fin_clavier

g_demitour
 addq.l #2,di
 and.l #3,di
 bra fin_clavier
  
g_tourne_gauche
 subq.l #1,di
 and.l #3,di
 bra fin_clavier

g_avance
 move.b bloc_map+7,d0
 lea v_avance,a0
 bra teste_deplacement
  
g_tourne_droite
 addq.l #1,di
 and.l #3,di
 bra fin_clavier
 
g_gauche
 move.b bloc_map+9,d0
 lea v_gauche,a0
 bra teste_deplacement
 
g_recule
 move.b bloc_map+13,d0
 lea v_recule,a0
 bra teste_deplacement
 
g_droite
 move.b bloc_map+11,d0
 lea v_droite,a0

teste_deplacement 
 cmp.b #64,d0
 bge ouille
 cmp.b #valeur_gauche,d0
 bge .ca_passe
 cmp.b #valeur_faux_mur,d0
 beq .ca_passe
 tst.b d0
 bne ouille
.ca_passe 
 move.l di,d1
 lsl #3,d1
 add.w d1,a0
 move.l (a0)+,d1
 add.l d1,xp
 move.l (a0),d1
 add.l d1,yp
 bra gere_case_pivot

ouille
 cmp.b #64,d0
 bge teleporte_joueur
 jsr rejoue_sample_ouch
;
; On fait un fading "au rouge"...
;
 move.b #1,flag_swapping
 cmp.l #palette_standard,palette_suivante
 bne.s .pas_standard
 move.l #palette_rstandard,palette_suivante
 bra.s .continue
.pas_standard
 move.l #palette_rfontaine,palette_suivante
.continue
 move.b #-1,fading_flag
 move.l #status,adresse_messages
 move.b #tempo_message,duree_message
 move.b #1,n_message
.attend
 tst.b fading_flag
 bne.s .attend 
 move.b #1,fading_flag
.attend2
 tst.b fading_flag
 bne.s .attend2
 sf flag_swapping
 vsync
 bra fin_clavier

teleporte_joueur
 jsr rejoue_sample_zap
 move.b #-1,fading_flag
;
; Recherche le t‚l‚porteur de destination
; 
 bchg.l #0,d0
 lea carte,a0
 move.w #5120-1,d1
.cherche_case_suivante
 cmp.b (a0)+,d0
 beq.s .case_trouvee
 dbra d1,.cherche_case_suivante
.case_trouvee
 sub.l #carte+1,a0
 move.l a0,d0
 lsr.l #6,d0
 move.l d0,yp
 lsl.l #6,d0
 sub.l d0,a0
 move.l a0,xp
.attend_fin_fading
 tst.b fading_flag
 bne.s .attend_fin_fading
;
; On relance...
;
 move.l #status,adresse_messages
 move.b #tempo_message,duree_message
 move.b #11,n_message
 move.b #1,fading_flag
 bra fin_clavier
 
entrer_porte
 move.l #status,adresse_messages
 move.b #tempo_message,duree_message
 move.b bloc_map+7,d0
 bpl.s .pas_une_porte
 neg.b d0 
 ext.w d0
 cmp.w #65,d0
 bge .lire_plaque
;
; C'est bon, on rentre
; 
 subq.w #1,d0
 move.w d0,porte_choisie 
 jsr rejoue_sample_door
 bra sort_boucle
.pas_une_porte
 move.b bloc_map+7,d0
 tst.b d0
 beq.s .rien_devant
 cmp.b #valeur_fontaine,d0
 beq.s .drink_water
 cmp.b #valeur_faux_mur,d0
 beq.s .faux_mur
 cmp.b #valeur_force,d0
 beq.s .the_force
 cmp.b #64,d0
 bge.s .magic_pentacle
;
; You can't enter here !
;
 move.b #4,n_message
 bra fin_clavier
;
; Try to read it !
;
.lire_plaque
 move.b #3,n_message
 bra fin_clavier
;
; This is water...
;   
.drink_water
 move.b #2,n_message
 bra fin_clavier
;
; Do you really look a door ?
;
.rien_devant
 move.b #7,n_message
 bra fin_clavier
;
; Something special ???
;
.faux_mur
 move.b #8,n_message
 bra fin_clavier
;
; A strange force...
;
.the_force
 move.b #9,n_message
 bra fin_clavier
;
; This is a magical pentacle
;
.magic_pentacle
 move.b #10,n_message
 bra fin_clavier
 
***********************
*                     *
* Procedures diverses *
*                     *
***********************

reverse_sol
 lea plafond,a0
 lea r_plafond,a1

 move.l a1,a6           ; recopie bloc avant inversion
 move.l a0,a5
 move.w #147-1,d7
renverse_sol_1
 moveq #0,d0
 move.l #160-8,d1  ; 112
 moveq #20-1,d6
renverse_sol_2 
 move.l 0(a5,d0),0(a6,d1)
 move.l 4(a5,d0),4(a6,d1)
 addq.l #8,d0
 subq.l #8,d1
 dbra d6,renverse_sol_2
 lea 160(a5),a5
 lea 160(a6),a6
 dbra d7,renverse_sol_1

 lea r_plafond,a6           ; inversion du bloc
 move.w #11760-1,d6
rev_sol_1
 move.w (a6),d2
 moveq #15,d5
rev_sol_2
 roxl.w #1,d2
 roxr.w #1,d1
 dbra d5,rev_sol_2
 move.w d1,(a6)+
 dbra d6,rev_sol_1
 rts
 
reverse_cotes
 move.l #200,hauteur_mur
 lea side1,a0
 lea r_side1+8808,a1
 bsr inverse_cotes_1
 lea side1+8808,a0
 lea r_side1,a1
 bsr inverse_cotes_1
 lea cfontaine1,a0
 lea r_cfontaine1,a1
 bsr inverse_cotes_1
 lea cporte1,a0
 lea r_cporte1,a1
 bsr inverse_cotes_1
 lea cplaque1,a0
 lea r_cplaque1,a1
 bsr inverse_cotes_1

 move.l #175,hauteur_mur
 lea side2,a0
 lea r_side2+8808,a1
 bsr inverse_cotes_2
 lea side2+8808,a0
 lea r_side2,a1
 bsr inverse_cotes_2
 lea cfontaine2,a0
 lea r_cfontaine2,a1
 bsr inverse_cotes_2
 lea cporte2,a0
 lea r_cporte2,a1
 bsr inverse_cotes_2
 lea cplaque2,a0
 lea r_cplaque2,a1
 bsr inverse_cotes_2

 move.l #100,hauteur_mur
 lea side3,a0
 lea r_side3+8808,a1
 bsr inverse_cotes_0
 lea side3+8808,a0
 lea r_side3,a1
 bsr inverse_cotes_0
 lea cfontaine3,a0
 lea r_cfontaine3,a1
 bsr inverse_cotes_0
 lea cporte3,a0
 lea r_cporte3,a1
 bsr inverse_cotes_0
 lea cplaque3,a0
 lea r_cplaque3,a1
 bsr inverse_cotes_0

 move.l #76,hauteur_mur
 lea side4,a0
 lea r_side4+8808,a1
 bsr inverse_cotes_0
 lea side4+8808,a0
 lea r_side4,a1
 bsr inverse_cotes_0
 lea cfontaine4,a0
 lea r_cfontaine4,a1
 bsr inverse_cotes_0
 lea cporte4,a0
 lea r_cporte4,a1
 bsr inverse_cotes_0
 lea cplaque4,a0
 lea r_cplaque4,a1
 bsr inverse_cotes_0
 rts

inverse_cotes_0
 move.l hauteur_mur,d2
 addq.l #1,d2
 lsl.l #3,d2
 move.l d2,taille_reverse
 move.l a1,a6               ; r_side
 move.l a0,a5               ; side  
 move.l hauteur_mur,d7
 subq.l #1,d7
rev_cote
 moveq #3,d6
rev_cote_1 
 move.w (a5)+,d2
 moveq #15,d5
rev_cote_2
 roxl.w #1,d2
 roxr.w #1,d1
 dbra d5,rev_cote_2
 move.w d1,(a6)+
 dbra d6,rev_cote_1
 dbra d7,rev_cote
 rts 

inverse_cotes_1
 move.l hauteur_mur,d2
 addq.l #1,d2
 lsl.l #4,d2
 move.l d2,taille_reverse
 move.l a1,a6           ; recopie bloc avant inversion
 move.l a0,a5
 move.l hauteur_mur,d7
 subq.l #1,d7
ev_mur_1
 move.l (a5),8(a6)
 move.l 4(a5),12(a6)
 move.l 8(a5),(a6)
 move.l 12(a5),4(a6)
 lea 16(a5),a5
 lea 16(a6),a6
 dbra d7,ev_mur_1
 move.l a1,a6           ; inversion du bloc
 move.l taille_reverse,d6
 lsr.l #1,d6
i_bloc_1
 move.w (a6),d2
 moveq #15,d5
i_bloc_2
 roxl.w #1,d2
 roxr.w #1,d1
 dbra d5,i_bloc_2
 move.w d1,(a6)+
 dbra d6,i_bloc_1 
 rts

inverse_cotes_2
 move.l hauteur_mur,d2
 addq.l #1,d2
 mulu #24,d2
 move.l d2,taille_reverse
 move.l a1,a6           ; recopie bloc avant inversion
 move.l a0,a5
 move.l hauteur_mur,d7
 subq.l #1,d7
ev_mur_2
 move.l (a5),16(a6)
 move.l 4(a5),20(a6)
 move.l 8(a5),8(a6)
 move.l 12(a5),12(a6)
 move.l 16(a5),(a6)
 move.l 20(a5),4(a6)
 add.l #24,a5
 add.l #24,a6
 dbra d7,ev_mur_2

 move.l a1,a6           ; inversion du bloc
 move.l taille_reverse,d6
 lsr.l #1,d6
i_bloc_12
 move.w (a6),d2
 moveq #15,d5
i_bloc_22
 roxl.w #1,d2
 roxr.w #1,d1
 dbra d5,i_bloc_22
 move.w d1,(a6)+
 dbra d6,i_bloc_12
 rts
 
*********************************
*                               *
* routines d'affichage des murs *
*                               *
*********************************

a_0
 move.l buf1,a6
 move.l adresse_mur,a5
var1 set 16
var2 set 160*38
 rept 77
 movem.l var1(a5),d0-d7/a0-a3
 movem.l d0-d7/a0-a3,var2(a6)
var1 set var1+64
var2 set var2+160 
 endr
 rts

s_0
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*38+40+8
 rept 75
 move.l (a5)+,var(a6)
 move.l (a5)+,var+4(a6)
var set var+160 
 endr
 rts
 
a_1
 move.l buf1,a6
 move.l adresse_mur,a5
var1 set 40
var2 set 160*31
 rept 100
 movem.l var1(a5),d0-d7/a0-a1
 movem.l d0-d7/a0-a1,var2(a6)
var1 set var1+80
var2 set var2+160
 endr
 rts

s_1
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*31+32+8
 rept 100
 move.l (a5)+,var(a6)
 move.l (a5)+,var+4(a6)
var set var+160 
 endr
 rts

a_2
 move.l buf1,a6
 move.l adresse_mur,a5
var1 set 112
var2 set 160*11
 rept 175
 movem.l var1(a5),d0-d3
 movem.l d0-d3,var2(a6)
var1 set var1+112+16
var2 set var2+112+32+16
 endr
 rts

s_2
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*11+16
 rept 88
 movem.l (a5)+,d0-d7/a0-a3
 movem.l d0-d5,var(a6)
var set var+160
 movem.l d6-d7/a0-a3,var(a6)
var set var+160 
 endr
 rts

s_3
 move.l buf1,a6
 move.l adresse_mur,a5
var set 0
 rept 200
 movem.l (a5)+,d0-d3
 movem.l d0-d3,var(a6)
var set var+160 
 endr
 rts

; Affichage de la rang‚e du centre
 
a_4
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*38+48
 rept 77
 movem.l (a5)+,d0-d7/a0-a4
 movem.l d0-d7/a0-a4,var(a6)
 movem.l (a5)+,d0-d2
 movem.l d0-d2,var+52(a6)
var set var+160 
 endr
 rts

a_5
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*31+40
 rept 100
 movem.l (a5)+,d0-d7/a0-a4
 movem.l d0-d7/a0-a4,var(a6)
 movem.l (a5)+,d0-d6
 movem.l d0-d6,var+52(a6)
var set var+160
 endr
 rts

a_6
 move.l buf1,a6
 lea 160*11+16(a6),a6
 move.l adresse_mur,a5
var set 0
 rept 175
 movem.l (a5)+,d0-d7/a0-a4
 movem.l d0-d7/a0-a4,var(a6)
 movem.l (a5)+,d0-d7/a0-a4
 movem.l d0-d7/a0-a4,var+52(a6)
 movem.l (a5)+,d0-d5
 movem.l d0-d5,var+104(a6)
var set var+160
 endr 
 rts

a_7
 rts
  
a_8                                  ; petit mur du fonds … droite
 move.l buf1,a6
 move.l adresse_mur,a5
var1 set 0
var2 set 160*38+80+32
 rept 77
 movem.l var1(a5),d0-d7/a0-a3
 movem.l d0-d7/a0-a3,var2(a6)
var1 set var1+64
var2 set var2+160 
 endr
 rts

s_8
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*38+72+8*5-8
 rept 75
 move.l (a5)+,var(a6)
 move.l (a5)+,var+4(a6)
var set var+160 
 endr
 rts
 
a_9
 move.l buf1,a6
 move.l adresse_mur,a5
var1 set 0
var2 set 160*31+120
 rept 100
 movem.l var1(a5),d0-d7/a0-a1
 movem.l d0-d7/a0-a1,var2(a6)
var1 set var1+80
var2 set var2+160
 endr
 rts

s_9
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*31+80+8*5-8
 rept 100
 move.l (a5)+,var(a6)
 move.l (a5)+,var+4(a6)
var set var+160 
 endr
 rts
 
a_10
 move.l buf1,a6
 move.l adresse_mur,a5
var1 set 0
var2 set 160*11+144
 rept 175
 movem.l var1(a5),d0-d3
 movem.l d0-d3,var2(a6)
var1 set var1+112+16
var2 set var2+112+32+16
 endr
 rts

s_10
 move.l buf1,a6
 move.l adresse_mur,a5
var set 160*11+88+8*5-8
 rept 88
 movem.l (a5)+,d0-d7/a0-a3
 movem.l d0-d5,var(a6)
var set var+160
 movem.l d6-d7/a0-a3,var(a6)
var set var+160 
 endr
 rts
 
s_11
 move.l buf1,a6
 move.l adresse_mur,a5
var set 104+8*5
 rept 200
 movem.l (a5)+,d0-d3
 movem.l d0-d3,var(a6)
var set var+160 
 endr
 rts

***************
;
; Les routines d'affichage pour le pentacle...
;
p_0
 movem.l d0/a0-a1,-(sp)
 lea pentacle3,a0
 move.l buf1,a1
 lea 160*105(a1),a1
 moveq #7,d0
.recop_pentacle_1
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)  
 movem.l (a0)+,d1-d4
 movem.l d1-d4,32(a1)  
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_1
 movem.l d0/a0-a1,-(sp)
 lea pentacle3,a0
 move.l buf1,a1
 lea 160*105+56(a1),a1
 moveq #7,d0
.recop_pentacle_1
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)  
 movem.l (a0)+,d1-d4
 movem.l d1-d4,32(a1)  
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_2
 movem.l d0/a0-a1,-(sp)
 lea pentacle3,a0
 move.l buf1,a1
 lea 160*105+112(a1),a1
 moveq #7,d0
.recop_pentacle_1
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)  
 movem.l (a0)+,d1-d4
 movem.l d1-d4,32(a1)  
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_3
 movem.l d0/a0-a1,-(sp)
 lea pentacle2+24,a0
 move.l buf1,a1
 lea 160*114(a1),a1
 moveq #14,d0
.recop_pentacle_1
 movem.l (a0),d1-d7/a2-a4
 movem.l d1-d7/a2-a4,(a1)  
 lea 64(a0),a0
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_4
 movem.l d0/a0-a1,-(sp)
 lea pentacle2,a0
 move.l buf1,a1
 lea 160*114+48(a1),a1
 moveq #14,d0
.recop_pentacle_1
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)  
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,32(a1)  
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_5
 movem.l d0/a0-a1,-(sp)
 lea pentacle2,a0
 move.l buf1,a1
 lea 160*114+120(a1),a1
 moveq #14,d0
.recop_pentacle_1
 movem.l (a0),d1-d7/a2-a4
 movem.l d1-d7/a2-a4,(a1)  
 lea 64(a0),a0
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_6
 movem.l d0/a0-a1,-(sp)
 lea pentacle1+80-16,a0
 move.l buf1,a1
 lea 160*133(a1),a1
 moveq #45,d0
.recop_pentacle_1
 movem.l (a0),d1-d4
 movem.l d1-d4,(a1)
 lea 80(a0),a0
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

p_7
 movem.l d0/a0-a1,-(sp)
 lea pentacle1,a0
 move.l buf1,a1
 lea 160*133+40(a1),a1
 moveq #45,d0
.recop_pentacle_1
 movem.l (a0)+,d1-d7/a2-a6
 movem.l d1-d7/a2-a6,(a1)  
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,48(a1)  
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts
 
p_8
 movem.l d0/a0-a1,-(sp)
 lea pentacle1,a0
 move.l buf1,a1
 lea 160*133+144(a1),a1
 moveq #45,d0
.recop_pentacle_1
 movem.l (a0),d1-d4
 movem.l d1-d4,(a1)
 lea 80(a0),a0
 lea 160(a1),a1
 dbra d0,.recop_pentacle_1
 movem.l (sp)+,d0/a0-a1
 rts

***************
***************
***************
 
make_screens
 move.l #ecrans,d0
 sf d0
 add.l #256,d0
 move.l d0,buf1 
 add.l #37888,d0
 move.l d0,buf2

 move.l buf1,d0
 asr.l #8,d0
 lea $ffff8201.w,a0
 movep.w d0,0(a0)
 rts
 
envoie_clavier  
 btst.b #1,$fffffc00.w
 beq.s envoie_clavier
 move.b d0,$fffffc02.w
 rts
 
sauve_interruptions
 move.w #$2700,sr
 moveq #$12,d0
 bsr envoie_clavier
 moveq #$15,d0
 bsr envoie_clavier
 moveq #$13,d0
 bsr envoie_clavier
 move.l $70.w,sauve_vbl
 move.l $110.w,sauve_110
 move.l $118.w,sauve_118
 move.l $120.w,sauve_hbl
 move.b $ffff8201.w,sauve_ecran_1
 move.b $ffff8203.w,sauve_ecran_2 
 move.b $ffff820a.w,sauve_frequence
 move.b $ffff8260.w,sauve_resolution
 sf $ffff8260.w
 move.b $fffffa07.w,sov_1
 sf $fffffa07.w 
 move.b $fffffa09.w,sov_2
 sf $fffffa09.w 
 move.b $fffffa13.w,sov_3
 move.b $fffffa15.w,sov_4
 move.b $fffffa1b.w,sov_5
 sf $fffffa1b.w 
 move.b $fffffa1d.w,sov_6
 sf $fffffa1d.w
 move.b $fffffa21.w,sov_7
 move.b $fffffa25.w,sov_8
 move.l #vbl_choc,$70.w
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,sauve_palette
 movem.l efface,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.l #efface,palette_affichee
 move.l #efface,palette_suivante
 sf fading_flag
 sf fading_pos
 move.w #$2300,sr
 rts
 
 ifeq finale
screen_choc 
 move.w #$2700,sr
 move.l #vbl_choc,$70.w
 move.w #$2300,sr
 stop #$2300
 move.b #2,$ffff820a.w
 stop #$2300
 stop #$2300
 sf $ffff820a.w
 stop #$2300
 stop #$2300
 move.b #2,$ffff820a.w
 rts
 endc

lance_interruptions  
 move.w #$2700,sr 
 move.l #routine_vbl,$70.w
 move.l #routine_timer_d,$110.w
 move.l #routine_118,$118.w
 move.l #routine_hbl,$120.w
 sf synchro_flag 
 move.b #%00000001,$fffffa07.w
 move.b #%01000000,$fffffa09.w
 move.b #%00000001,$fffffa13.w
 move.b #%01000000,$fffffa15.w
 moveq #$11,d0
 bsr envoie_clavier
 move.l #palette_standard,palette_affichee
 move.l #palette_standard,palette_suivante
 move.b #1,fading_flag
 sf fading_pos
 move.w #$2300,sr
 rts

restaure_interruptions
 move.w #$2700,sr
 move.b sauve_resolution,$ffff8260.w
 move.b sauve_ecran_1,$ffff8201.w
 move.b sauve_ecran_2,$ffff8203.w
 move.b sauve_frequence,$ffff820a.w
 move.b sov_1,$fffffa07.w
 move.b sov_2,$fffffa09.w
 move.b sov_3,$fffffa13.w
 move.b sov_4,$fffffa15.w
 move.b sov_5,$fffffa1b.w
 move.b sov_6,$fffffa1d.w
 move.b sov_7,$fffffa21.w
 move.b sov_8,$fffffa25.w
 move.l sauve_vbl,$70.w
 move.l sauve_110,$110.w
 move.l sauve_118,$118.w
 move.l sauve_hbl,$120.w
 movem.l sauve_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 moveq #$08,d0
 bsr envoie_clavier
 move.w #$2300,sr
 rts

vbl_choc
 movem.l d0-d7/a0-a6,-(sp)
 move.l palette_affichee,a0
 bsr execute_fading
 bsr suite_fading 
 movem.l (sp)+,d0-d7/a0-a6
 rte
  
routine_vbl
 move.w #$2700,sr
 movem.l d0-d7/a0-a6,-(sp)

 move.l palette_affichee,a0
 bsr execute_fading
 

****** on gere tt de suite les boucles de la digit
 tst.b flag_ste
 bne.s .pas_gere_sample_stf

 tst.b flag_zik
 bne.s .pas_gere_sample_stf

 move.l usp,a2
 move.l fin_sample,a3
 cmp.l a3,a2
 blt.s .pas_gere_sample_stf
 tst loop_stf?
 beq.s .pas_loop_stf
 sub.l #(fin_samples-128)-snd_water,a2
* lea snd_water,a2
 move.l a2,usp
 bra.s .pas_gere_sample_stf
.pas_loop_stf
 sf $fffffa1d.w

.pas_gere_sample_stf
 move.l #routine_hbl,$120.w
 move.b #198,$fffffa21.w
 move.b #8,$fffffa1b.w

 move.w #$2300,sr
 tst.b flag_zik
 beq.s .pas_zik
 jsr music+8
 tst.b flag_ste
 bne.s .pas_zikk
 sf $fffffa1d.w
 bra.s .pas_zikk
.pas_zik
 bsr arrete_musique
.pas_zikk
  
********** On quitte

fin_vbl    
 addq.w #1,compteur_rnd
 movem.l (sp)+,d0-d7/a0-a6
 rte
 
 opt o- 
 
routine_hbl 
 move.w #$2700,sr
 movem.l d0-a6,-(sp)
 
sync
 move.b $ffff8209.w,d0
 cmp.b #100,d0
 blt.s sync
 moveq #16,d1
 sub.b d0,d1 
 lsl.w d1,d0

 pause 60

*************** d‚clanchement du border bas

 sf $ffff820a.w
 pause 20
 move.b #2,$ffff820a.w
 
 opt o+

 lea palette_boussole,a0
 bsr execute_fading
 bsr suite_fading 

********* on swappe les ecrans

 tst.b flag_swapping
 beq.s .normal_swapping

.normal_swapping
 addq.b #1,compteur_vbl
 cmp.b #nombre_vbl,compteur_vbl
 bne pas_de_swapping
 sf compteur_vbl
 move.b #1,synchro_flag
 move.l buf1,d0
 tst.b flag_swapping
 bne.s .pas_swapping
 move.l buf2,buf1
 move.l d0,buf2
.pas_swapping
 asr.l #8,d0
 lea $ffff8201.w,a0
 movep.w d0,0(a0)
 move.l palette_suivante,palette_affichee
pas_de_swapping

************* fin de la routine
 
fin
 movem.l (sp)+,d0-a6
 sf $fffffa1b.w
 move.l #routine_hbl_2,$120.w
 move.b #33,$fffffa21.w
 move.b #8,$fffffa1b.w
 bclr #0,$fffffa0f.w
 rte

routine_hbl_2
 movem.l d0-d7,-(sp)
 movem.l efface,d0-d7
 movem.l d0-d7,$ffff8240.w
 movem.l (sp)+,d0-d7
 sf $fffffa1b.w
 bclr #0,$fffffa0f.w
 rte
 
execute_fading
 moveq #0,d0
 move.b fading_pos,d0
 lsl.w #5,d0 
 movem.l 0(a0,d0.w),d1-d7/a1
 movem.l d1-d7/a1,$ffff8240.w
 rts

suite_fading 
 tst.b fading_flag
 beq.s .fin_fading
 bmi.s .fade_out
.fade_in
 move.b fading_pos,d0
 addq.b #1,d0
 move.b d0,fading_pos
 cmp.b #15,d0
 bne.s .fin_fading
 sf fading_flag
 bra.s .fin_fading
.fade_out
 move.b fading_pos,d0
 subq.b #1,d0
 move.b d0,fading_pos
 bne.s .fin_fading
 sf fading_flag
.fin_fading 
 rts
 
routine_118
 move.l d0,-(sp)
 move.l d1,-(sp)
debut
 move.b $fffffc00.w,d0
 btst #7,d0
 beq.s fin_2  ; -> si le bit 7 est nul,alors pas d'interrupt clavier.
 
 btst #0,d0
 beq.s fin_1  ; -> si le bit 0 est nul,alors pas d'octet en attente.
 
 move.b $fffffc02.w,d1
 move.b d1,clavier
fin_1
 and.b #$20,d0
 beq.s fin_2
 move.b $fffffc02.w,d0
fin_2
 btst #4,$fffffa01.w
 beq.s debut
 bclr #6,$fffffa11.w
 move.l (sp)+,d1
 move.l (sp)+,d0
 rte

init_musique
 moveq #n_musique,d0
 jsr music
 rts

arrete_musique
 move.l #$8080000,$ffff8820.w
 move.l #$9090000,$ffff8820.w
 move.l #$a0a0000,$ffff8820.w
 move.l #$707ffff,$ffff8820.w
 rts

conversion_du_texte
 lea convert,a0
 lea carte+5120,a1
 moveq #0,d1
 move.w #64*(12*6+18*2)-1,d0
.next_one
 move.b (a1),d1
 move.b 0(a0,d1.w),(a1)+
 dbra d0,.next_one
 rts

determine_palette 
 lea palette_standard,a1
 lea mur_map,a0
 moveq #8,d0
.cherche_suivant
 cmp.b #valeur_fontaine,(a0)+
 bne.s .pas_encore
 lea palette_fontaine,a1
.pas_encore 
 dbra d0,.cherche_suivant 
 move.l a1,palette_suivante  
 rts

affiche_dongeon
 lea dongeon,a0
 move.l buf1,a1
 lea 160*50(a1),a1
 move.w #16000/4-1,d0
.ligne_suivante 
 move.l (a0)+,(a1)+
 dbra d0,.ligne_suivante
 rts

afficher_carte_ecran
;
; On recopie la carte pack‚e sur buf2
;
 lea old_map,a0
 lea fin_old_map,a1
 move.l buf2,a2
.recopie
 move.l (a0)+,(a2)+
 cmpa.l a1,a0
 ble.s .recopie 
;
; On d‚packe la carte
; 
 move.l buf2,a0
 jsr depack
;
; On efface le fonds
;
 move.l buf1,a0
 moveq #0,d1
 move.w #32000/4,d0
.effacer_l_ecran
 move.l d1,(a0)+
 dbra d0,.effacer_l_ecran
;
; On affiche le fonds de la carte
; 
 move.l buf2,a0
 move.l buf1,a1
 lea 24+7*160(a1),a1
 move.w #185,d0
.recopie_ligne_y
 moveq #27,d1
.recopie_ligne_x
 move.l (a0)+,(a1)+
 dbra d1,.recopie_ligne_x
 lea 48(a1),a1
 dbra d0,.recopie_ligne_y
;
; C'est ici que l'on se marre, car il faut afficher
; point par point la carte !
;
 lea map_connue,a0
 lea carte,a6 
 move.l buf1,a1
 lea 32+18*160(a1),a1
 moveq #79,d7
.affiche_ligne
 moveq #7,d4
 move.l a1,a2  
offset_position=3
 moveq #offset_position,d6
.affiche_colonne
 move.b (a6)+,d3
* btst.b d4,(a0)
* beq .fin_affiche_point
 tst.b d3
 beq .fin_affiche_point
 cmp.b #valeur_force,d3
 bge .fin_affiche_point
;
; On calcule l'emplacement
; 
.affiche_un_point_1
 move.l a2,a3
 move.w d6,d0
 add.w d0,d0
 move.w d0,d1
 and.w #%111111110000,d0
 lsr.w #1,d0
 add.w d0,a3
 moveq #15,d0 
 and.w #%1111,d1
 sub.w d1,d0
 lea (a3),a4
 bsr valide_point
 lea 160(a3),a4
 bsr valide_point
;
; On calcule l'emplacement
; 
.affiche_un_point_2
 move.l a2,a3
 move.w d6,d0
 add.w d0,d0
 addq.w #1,d0
 move.w d0,d1
 and.w #%111111110000,d0
 lsr.w #1,d0
 add.w d0,a3
 moveq #15,d0 
 and.w #%1111,d1
 sub.w d1,d0
 lea (a3),a4
 bsr valide_point
 lea 160(a3),a4
 bsr valide_point
.fin_affiche_point

 subq #1,d4
 tst d4
 bge.s .chou_octet
 moveq #7,d4
 addq #1,a0
.chou_octet

 addq.w #1,d6
 cmp.w #64+offset_position,d6
 blt .affiche_colonne
 lea 320(a1),a1
 dbra d7,.affiche_ligne
;
; Puis, on affiche l'endroit o— l'on est...
;
 move.l buf1,a0
 lea 32+18*160(a0),a0
 move.l yp,d0
 mulu #320,d0
 add.w d0,a0
 move.l xp,d6
 addq.w #3,d6
;
 move.l a0,a3
 move.w d6,d0
 add.w d0,d0
 move.w d0,d1
 and.w #%111111110000,d0
 lsr.w #1,d0
 add.w d0,a3
 moveq #15,d0 
 and.w #%1111,d1
 sub.w d1,d0
 lea (a3),a4
 moveq #15,d2
 bsr affiche_le_point
 lea 160(a3),a4
 moveq #15,d2
 bsr affiche_le_point
;
; On calcule l'emplacement
; 
 move.l a0,a3
 move.w d6,d0
 add.w d0,d0
 addq.w #1,d0
 move.w d0,d1
 and.w #%111111110000,d0
 lsr.w #1,d0
 add.w d0,a3
 moveq #15,d0 
 and.w #%1111,d1
 sub.w d1,d0
 lea (a3),a4
 moveq #15,d2
 bsr affiche_le_point
 lea 160(a3),a4
 moveq #15,d2
 bsr affiche_le_point
 rts

valide_point
 moveq #12,d2
 cmp.b #valeur_mur,d3
 beq.s .mur
 cmp.b #valeur_fontaine,d3
 beq.s .fontaine
 bpl.s affiche_le_point
 move.b d3,d1
 neg.b d1
 cmp.b #65,d1
 bge.s .mur
.porte_vue
 moveq #1,d2
 bra affiche_le_point
.fontaine
 moveq #2,d2
 bra affiche_le_point
.mur
 moveq #12,d2
 bra affiche_le_point
.porte_a_voir
 moveq #15,d2
 bra affiche_le_point

affiche_le_point  
 move.w (a4),d1
 roxr d2
 bcs.s .set_bit_1
 bclr.l d0,d1
 bra.s .fin_bit_1
.set_bit_1
 bset.l d0,d1
.fin_bit_1
 move.w d1,(a4)

 move.w 2(a4),d1
 roxr d2
 bcs.s .set_bit_2
 bclr.l d0,d1
 bra.s .fin_bit_2
.set_bit_2
 bset.l d0,d1
.fin_bit_2
 move.w d1,2(a4)

 move.w 4(a4),d1
 roxr d2
 bcs.s .set_bit_3
 bclr.l d0,d1
 bra.s .fin_bit_3
.set_bit_3
 bset.l d0,d1
.fin_bit_3
 move.w d1,4(a4)

 move.w 6(a4),d1
 roxr d2
 bcs.s .set_bit_4
 bclr.l d0,d1
 bra.s .fin_bit_4
.set_bit_4
 bset.l d0,d1
.fin_bit_4
 move.w d1,6(a4)
 rts

*** D‚bogage only
affiche_monstre_carte
;
; Puis, on affiche le monstre
;
 move.l buf1,a0
 lea 32+18*160(a0),a0
 move.w y_monstre,d0
 mulu #320,d0
 add.w d0,a0
 move.w x_monstre,d6
 addq.w #3,d6
;
 move.l a0,a3
 move.w d6,d0
 add.w d0,d0
 move.w d0,d1
 and.w #%111111110000,d0
 lsr.w #1,d0
 add.w d0,a3
 moveq #15,d0 
 and.w #%1111,d1
 sub.w d1,d0
 lea (a3),a4
 move.l d7,d2
 bsr affiche_le_point
 lea 160(a3),a4
 move.l d7,d2
 bsr affiche_le_point
;
; On calcule l'emplacement
; 
 move.l a0,a3
 move.w d6,d0
 add.w d0,d0
 addq.w #1,d0
 move.w d0,d1
 and.w #%111111110000,d0
 lsr.w #1,d0
 add.w d0,a3
 moveq #15,d0 
 and.w #%1111,d1
 sub.w d1,d0
 lea (a3),a4
 move.l d7,d2
 bsr affiche_le_point
 lea 160(a3),a4
 move.l d7,d2
 bsr affiche_le_point
 rts
*****************
 
***
DEC_MARGE:	equ	$10	;min=0 , max=126 (pair!)
taille  dc.l 0
depack:
	movem.l	d0-a6,-(a7)
	cmp.l	#"ATOM",(a0)+
	bne	no_crunched
	move.l	(a0)+,d0
 	move.l d0,taille
	move.l	d0,-(a7)
	lea	DEC_MARGE(a0,d0.l),a5
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus:
	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch:
	moveq	#6,d6
take_lenght:
	add.b	d7,d7
	beq.s	.empty1
.cont_copy:
	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:
	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:
	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:
	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:
	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:
	moveq	#1,d6
	bsr.s	get_bit2
tablus2:
	move.b	0(a4,d5.w),-(a5)	
	bra.s	make_jnk
get_bit2:
	clr	d5
.get_bits:
	add.b	d7,d7
	beq.s	.empty
.cont:
	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	
	lea	decrun_table(pc),a4
cont:
	moveq	#2,d6
	bsr.s	get_bit2
contus:
	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:
	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same: move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk:
	moveq	#11,d6
	moveq	#11,d5
take_jnk
	add.b	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod
	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1
	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1
	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk
	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word
	cmp.l	a6,a0
.decrunch
	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	move.l	(a7)+,d0
	bsr	copy_decrun
no_crunched
	movem.l	(a7)+,d0-a6
 	rts
empty
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table
	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2
	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table
	dc.b	$60,$20,$10,$8
copy_decrun
	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun
	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts

efface_bss
 lea debut_bss,a0
 lea fin_bss,a1
 moveq #0,d0
.boucle_efface
 move.l d0,(a0)+
 cmp.l a1,a0
 blt.s .boucle_efface 
 jmp fin_efface_bss


****************************
*
* Bruitages STE
*
****************************

convertion_samples    ; (Fuck FFT)
 move.b #%10000000,$ffff8921.w
;
; Reglage Interface Microwire
;
; Master  = 1216+(<=40)
; V Gauche= 1344+(<=20)
; V Droit = 1280+(<=20)
; Aigue   = 1152+(<=12)
; Grave   = 1088+(<=12)
; Mixage  = 1024+(<=3)
 move.w #$7ff,$ffff8924.w
 move.w #1256,d0  ; Master
 bsr.s teste_masque
 move.w #1364,d0  ; V Gauche 
 bsr.s teste_masque
 move.w #1300,d0  ; V Droit
 bsr.s teste_masque
 move.w #1152,d0  ; Aigues
 bsr.s teste_masque
 move.w #1088,d0  ; Basses
 bsr.s teste_masque
 move.w #1025,d0  ; Mixage
 bsr.s teste_masque
*
 lea debut_samples,a0
 lea fin_samples,a1
 move.w #$80,d0
.sample_suivant
 sub.b d0,(a0)+
 cmpa.l a1,a0
 bmi .sample_suivant   
 rts

teste_masque 
 cmp.w #$7ff,$ffff8924.w
 bne.s teste_masque
 move.w d0,$ffff8922.w
 rts


rejoue_sample_plop
 tst.b flag_ste
 beq.s .not_cut
 clr.b $ffff8901.w
.not_cut
 lea snd_plop,a2
 lea fin_plop-1,a3
 moveq #1,d6
 bra.s rejoue_sample 

rejoue_sample_ouch
 tst.b flag_ste
 beq.s .not_cut
 clr.b $ffff8901.w
.not_cut
 lea snd_ouch,a2
 lea fin_ouch-1,a3
 moveq #1,d6
 bra.s rejoue_sample 

rejoue_sample_zap
 tst.b flag_ste
 beq.s .not_cut
 clr.b $ffff8901.w
.not_cut
 lea snd_zap,a2
 lea fin_zap-1,a3
 moveq #1,d6
 bra.s rejoue_sample 
   
rejoue_sample_door
 tst.b flag_ste
 beq.s .not_cut
 clr.b $ffff8901.w
.not_cut
 lea snd_door,a2
 lea fin_door-1,a3
 moveq #1,d6
 bra.s rejoue_sample 
   
rejoue_sample_water
 lea snd_water,a2
 lea fin_water-1,a3
 moveq #3,d6
 tst loop_stf?
 beq.s rejoue_sample
 rts

rejoue_sample
 tst.b flag_ste
 beq.s rejoue_sample_stf
rejoue_sample_ste
 move.l a2,d7
 lea $ffff8903.w,a1
 move.b d7,4(a1)
 asr.w #8,d7 
 move.b d7,2(a1)
 swap d7
 move.b d7,(a1)
 lea $ffff890f.w,a1
 move.l a3,d7
 move.b d7,4(a1)
 asr.w #8,d7 
 move.b d7,2(a1)
 swap d7
 move.b d7,(a1)
 move.b d6,$ffff8901.w  
 rts

convertion_water
 lea snd_water,a0
 lea fin_water,a1
 moveq #127,d0
.recop
 move.b (a0)+,(a1)+
 dbra d0,.recop
 rts
 
rejoue_sample_stf
 tst.b flag_zik
 bne fin_rejoue_sample_stf
 sf $fffffa1d.w
 subq #1,d6
 move d6,loop_stf?
 move.l a2,debut_sample
 move.l a2,usp
 move.l a3,fin_sample
 lea $ffff8800.w,a0
 move.l #$00000000,(a0)
 move.l #$01010000,(a0)
 move.l #$02020000,(a0)
 move.l #$03030000,(a0)
 move.l #$04040000,(a0)
 move.l #$05050000,(a0)
 move.l #$06060000,(a0)
 move.l #$08080000,(a0)
 move.l #$09090000,(a0)
 move.l #$0a0a0000,(a0)
 move.l #$0707ffff,(a0)
 bset.b #4,$fffffa09.w
 bset.b #4,$fffffa15.w
 move.b #$40,$fffffa17.w
 move.b #100,$fffffa25.w
 move.b #$1,$fffffa1d.w
fin_rejoue_sample_stf
 rts
 
routine_timer_d
 move.l d0,-(sp)
 pea (a0)
 moveq #0,d0
 move.l usp,a0
 move.b (a0)+,d0
 move.l a0,usp
 lsl #3,d0
 lea $ffff8800.w,a0
 move.l digi_tab+4(pc,d0.w),(a0)
 move.l digi_tab(pc,d0.w),d0
 movep.l d0,(a0)
 move.l (sp)+,a0
 move.l (sp)+,d0
 rte
digi_tab incbin data\yamaha.tbl

********************************************
*                                          *
* Routine de gestion du m‚chant ®Beholder¯ *
*                                          *
********************************************

d‚place_monstre
 move.w d_monstre,d3
 move.w x_monstre,d4
 move.w y_monstre,d5
 move.l xp,d6
 move.l yp,d7
*
 lea carte,a0
 move.w d5,d0
 lsl #6,d0
 add.w d0,a0
 add.w d4,a0           * ADRESSE DU MONSTRE SUR LA CARTE
*
 cmp.w d6,d4                  * xp/xm
 bne.s pas_meme_verticale
meme_verticale
 cmp.w d7,d5                  * yp/ym
 beq fin_d‚placement_monstre  Meme case, alors on bouge pas !
 blt faut_descendre

faut_remonter 
 move.w d5,d2
 sub.w d7,d2
 move.l a0,a1
.teste_case_suivante
 move.b (a1),d0
 bsr teste_case_carte
 tst.b d0
 bne gere_d‚placement_normal
 lea -64(a1),a1
 subq.b #1,d2
 bne .teste_case_suivante
 moveq #0,d3
 bra execute_d‚placement

faut_descendre
 move.w d7,d2
 sub.w d5,d2
 move.l a0,a1
.teste_case_suivante
 move.b (a1),d0
 bsr teste_case_carte
 tst.b d0
 bne gere_d‚placement_normal
 lea 64(a1),a1
 subq.b #1,d2
 bne .teste_case_suivante
 moveq #2,d3
 bra execute_d‚placement

pas_meme_verticale
 cmp.w d7,d5                   * yp/ym
 bne.s pas_meme_horizontale
meme_horizontale
 cmp.w d6,d4                   * xp/xm
 beq fin_d‚placement_monstre   Meme case, alors on bouge pas !
 blt vas_…_droite

vas_…_gauche
 move.w d4,d2
 sub.w d6,d2
 move.l a0,a1
.teste_case_suivante
 move.b (a1),d0
 bsr teste_case_carte
 tst.b d0
 bne gere_d‚placement_normal
 subq.w #1,a1
 subq.b #1,d2
 bne .teste_case_suivante
 moveq #3,d3
 bra execute_d‚placement

vas_…_droite
 move.w d6,d2
 sub.w d4,d2
 move.l a0,a1
.teste_case_suivante
 move.b (a1),d0
 bsr teste_case_carte
 tst.b d0
 bne gere_d‚placement_normal
 addq.w #1,a1
 subq.b #1,d2
 bne .teste_case_suivante
 moveq #1,d3
 bra execute_d‚placement

pas_meme_horizontale
gere_d‚placement_normal
 move.w d3,d2
 lsl.w #3,d2
 lea teste_dessus,a2
 jmp 0(a2,d2.w)
teste_dessus
 move.b -64(a0),d0
 bra continue_test
teste_droite
 move.b  +1(a0),d0
 bra continue_test
teste_dessous
 move.b +64(a0),d0
 bra continue_test
teste_gauche
 move.b  -1(a0),d0

continue_test
 bsr teste_case_carte
 beq execute_d‚placement
;
; On change la direction, avec un pseudo hasard...
;
 move.b $ffff8209.w,d0          Un petit coup de compteur vid‚o
 ror.b d0                       - Pour r‚cuperer un bit de poids faible  
 add.w compteur_rnd,d3
 add.w d0,d3                    - On ajoute tout ca … l'ancienne valeur
 and.w #3,d3
 bra fin_d‚placement_monstre
 
execute_d‚placement
 move.w d3,d2
 lsl.w #4,d2
 lea vers_haut,a2
 jmp 0(a2,d2.w)
vers_haut
 move.l #$0000ffff,xo_monstre
 bra fin_gere_sens
 nop
vers_droite
 move.l #$00010000,xo_monstre
 bra fin_gere_sens
 nop
vers_bas
 move.l #$00000001,xo_monstre
 bra fin_gere_sens
 nop
vers_gauche
 move.l #$ffff0000,xo_monstre

fin_gere_sens
 add.w xo_monstre,d4          On modifie les coordon‚es X et Y
 add.w yo_monstre,d5
fin_d‚placement_monstre
 move.w d3,d_monstre
 move.w d4,x_monstre
 move.w d5,y_monstre
 rts

teste_case_carte
 tst.b d0
 beq renvoie_libre
 cmp.b #3,d0
 beq renvoie_libre
 cmp.b #5,d0
 blt renvoie_occup‚e
 cmp.b #64,d0
 bge renvoie_occup‚e
renvoie_libre
 moveq #00,d0
 rts
renvoie_occup‚e
 moveq #-1,d0
 rts
   
affiche_monstre
 move.l buf1,a1
 lea table_monstre_2,a2
 lsl.w #3,d2
 add.w d2,a2
 add.l (a2)+,a1     Offset sur l'‚cran
 move.l (a2),a2     Adresse du bloc d'infos (Table monstre)
 move.l (a2)+,a0          * Adresse du monstre
 move.l (a2)+,a3          * Position de la table de saut vertical

 move.w vol_ptr,d0        On gere le d‚placement sur la
 add.w d0,a3              table de saut
 add.w d0,a3
 addq.w #1,d0
 cmp.w #72,d0
 blt.s .pas_raz   
 moveq #0,d0
.pas_raz
 move.w d0,vol_ptr

 add.w (a3),a1
 move.l (a2)+,a3          * Hauteur
 tst.l (a2)               * Nombre de multiples
 bne boucle_affiche_monstre_32
 
boucle_affiche_monstre_64
 movem.l (a1),d0-d7
 and.l (a0),d0
 and.l (a0)+,d1
 and.l (a0),d2
 and.l (a0)+,d3
 and.l (a0),d4
 and.l (a0)+,d5
 and.l (a0),d6
 and.l (a0)+,d7
 or.l (a0)+,d0
 or.l (a0)+,d1
 or.l (a0)+,d2
 or.l (a0)+,d3
 or.l (a0)+,d4
 or.l (a0)+,d5
 or.l (a0)+,d6
 or.l (a0)+,d7
 movem.l d0-d7,(a1)
 lea 160(a1),a1
 subq.w #1,a3
 cmp.w #0,a3
 bne boucle_affiche_monstre_64
 rts

boucle_affiche_monstre_32
 movem.l (a1),d0-d3
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
 subq.w #1,a3
 cmp.w #0,a3
 bne boucle_affiche_monstre_32
 rts

 section DATA

**********************************************
*                                            *
* Cette table sert … d‚terminer l'adresse o— *
*   l'on va trouver les blocs … afficher...  *
*                                            *
* V_  pour les morceaux de face              *
*                                            *
**********************************************
  
v_ordre
 dc.l v_0
 dc.l v_1
 dc.l v_2
 dc.l v_3
 dc.l v_4
 dc.l v_5
 dc.l v_6
 dc.l v_7
 dc.l v_8
* dc.l v_9
* dc.l v_10
* dc.l v_11
 
v_0
 dc.l mur3
 dc.l fontaine3
 dc.l mur3
 dc.l plaque3
 dc.l porte3

v_3
 dc.l mur2
 dc.l archside   ;fontaine2
 dc.l mur2
 dc.l plaque2
 dc.l porte2

v_6
 dc.l mur1
 dc.l fontaine1
 dc.l mur1
 dc.l plaque1
 dc.l porte1

v_1
 dc.l mur3
 dc.l fontaine3
 dc.l mur3
 dc.l plaque3
 dc.l porte3

v_4
 dc.l mur2
 dc.l fontaine2
 dc.l mur2
 dc.l plaque2
 dc.l porte2

v_7
 dc.l mur1
 dc.l fontaine1
 dc.l mur1
 dc.l plaque1
 dc.l porte1

v_2
 dc.l mur3
 dc.l fontaine3
 dc.l mur3
 dc.l plaque3
 dc.l porte3

v_5
 dc.l mur2
 dc.l archside   ;fontaine2
 dc.l mur2
 dc.l plaque2
 dc.l porte2

v_8
 dc.l mur1
 dc.l fontaine1
 dc.l mur1
 dc.l plaque1
 dc.l porte1

 even

ordre 
 dc.w 0
 dc.l a_0

 dc.w 3
 dc.l a_1

 dc.w 6
 dc.l a_2

 dc.w 2
 dc.l a_8

 dc.w 5
 dc.l a_9

 dc.w 8
 dc.l a_10

 dc.w 1
 dc.l a_4

 dc.w 4
 dc.l a_5

 dc.w 7
 dc.l a_6

 even

c_1
 dc.w 000,001,002
 dc.w 064,065,066
 dc.w 128,129,130
 dc.w 192,193,194
 dc.w 256,257,258
 
c_3
 dc.w 258,257,256
 dc.w 194,193,192
 dc.w 130,129,128
 dc.w 066,065,064
 dc.w 002,001,000
 
c_0
 dc.w 128,064,000
 dc.w 129,065,001
 dc.w 130,066,002
 dc.w 131,067,003
 dc.w 132,068,004
 
c_2
 dc.w 004,068,132  
 dc.w 003,067,131
 dc.w 002,066,130
 dc.w 001,065,129 
 dc.w 000,064,128

 even
     
v_avance
 dc.l -1,0
v_droite
 dc.l 0,-1
v_recule
 dc.l 1,0
v_gauche
 dc.l 0,1
 dc.l -1,0
 dc.l 0,-1
 dc.l 1,0
 
v_charge
 dc.l charge_0,charge_1,charge_2,charge_3 

;
; Ici se trouvent les fichiers … charger (LOAD)
;
palette_fontaine  incbin data\fontaine.pal
palette_rfontaine incbin data\r_fontai.pal
palette_standard  incbin data\standard.pal
palette_rstandard incbin data\r_standa.pal
palette_dongeon   incbin  data\dungeon.pal
palette_boussole  incbin data\boussole.pal
palette_old_map   incbin  data\old_map.pal

carte      incbin data\phaleonb.map
convert    incbin  data\convert.tbl
graphics   incbin data\mainmenu.dat
status     incbin data\messages.txt
password   incbin data\password.txt
old_map    incbin  data\old_map.gfk
fin_old_map
boussole   incbin data\boussole.gfx
fonte_or   incbin    data\fonte.gfx
fonte_plak incbin data\plakfont.gfx
names      incbin    data\names.gfx
monstre    incbin  data\monster.gfx
archside   incbin data\archside.gfx
survol     incbin data\beholder.trj
table_scan incbin   data\french.kbd
           incbin  data\british.kbd
           incbin   data\german.kbd
debut_samples
snd_ouch   incbin     data\ouch.spl
fin_ouch
 ds.b 128
snd_zap    incbin      data\zap.spl
fin_zap
 ds.b 128
snd_door   incbin     data\door.spl
fin_door
 ds.b 128
snd_water  incbin    data\water.spl
fin_water
 ds.b 128
snd_plop   incbin     data\plop.spl
fin_plop
 ds.b 128
fin_samples

music      incbin      data\arg.snd
   
 even

mur1        equ graphics
mur2        equ mur1+22400
mur3        equ mur2+8000
side1       equ mur3+4928
side2       equ side1+3200
side3       equ side2+4200
side4       equ side3+800
plafond     equ side4+608+(3200+4200+800+608)
sol         equ plafond+7520
pentacle1   equ sol+16000
pentacle2   equ pentacle1+3680
pentacle3   equ pentacle2+960
fontaine1   equ pentacle3+384
fontaine2   equ fontaine1+22400
fontaine3   equ fontaine2+8000
cfontaine1  equ fontaine3+4928
cfontaine2  equ cfontaine1+3200
cfontaine3  equ cfontaine2+4200
cfontaine4  equ cfontaine3+800
porte1      equ cfontaine4+608
porte2      equ porte1+22400
porte3      equ porte2+8000
cporte1     equ porte3+4928
cporte2     equ cporte1+3200
cporte3     equ cporte2+4200
cporte4     equ cporte3+800
plaque1     equ cporte4+608
plaque2     equ plaque1+22400
plaque3     equ plaque2+8000
cplaque1    equ plaque3+4928
cplaque2    equ cplaque1+3200
cplaque3    equ cplaque2+4200
cplaque4    equ cplaque3+800

__fin__     equ cplaque4+608

 even
 
ordre_cotes 
 dc.l s_0,adresse_gauche_4
 dc.l s_8,adresse_droite_4
 dc.l s_1,adresse_gauche_3
 dc.l s_9,adresse_droite_3
 dc.l s_2,adresse_gauche_2
 dc.l s_10,adresse_droite_2
 dc.l s_3,adresse_gauche_1
 dc.l s_11,adresse_droite_1

adresse_gauche_1
 dc.l side1
 dc.l cfontaine1
 dc.l side1
 dc.l cplaque1
 dc.l cporte1
adresse_gauche_2
 dc.l side2
 dc.l cfontaine2
 dc.l side2
 dc.l cplaque2
 dc.l cporte2
adresse_gauche_3
 dc.l side3
 dc.l cfontaine3
 dc.l side3
 dc.l cplaque3
 dc.l cporte3
adresse_gauche_4
 dc.l side4
 dc.l cfontaine4
 dc.l side4
 dc.l cplaque4
 dc.l cporte4

adresse_droite_1
 dc.l r_side1
 dc.l r_cfontaine1
 dc.l r_side1
 dc.l r_cplaque1
 dc.l r_cporte1
adresse_droite_2
 dc.l r_side2
 dc.l r_cfontaine2
 dc.l r_side2
 dc.l r_cplaque2
 dc.l r_cporte2
adresse_droite_3
 dc.l r_side3
 dc.l r_cfontaine3
 dc.l r_side3
 dc.l r_cplaque3
 dc.l r_cporte3
adresse_droite_4
 dc.l r_side4
 dc.l r_cfontaine4
 dc.l r_side4
 dc.l r_cplaque4
 dc.l r_cporte4
 
 even
  
bloc_map
 dc.b "..."
 dc.b "..."
 dc.b "..."
 dc.b ".X."
 dc.b "..."         

bloc_map_objets
 dc.b "..."
 dc.b "..."
 dc.b "..."
 dc.b ".X."
 dc.b "..."         

 even

pentacle_rout
 dc.l p_0
 dc.l p_1
 dc.l p_2
 dc.l p_3
 dc.l p_4
 dc.l p_5
 dc.l p_6
 dc.l p_7
 dc.l p_8

table_monstre
* dc.l monstre+6576,survol+144*4,08,1
 dc.l monstre+6192,survol+144*3,16,1
 dc.l monstre+5424,survol+144*2,32,1
 dc.l monstre+3072,survol+144*1,48,0
 dc.l monstre+0000,survol+144*0,64,0
***
 dc.l monstre+0000,survol+144*0,64,0
 dc.l monstre+0000,survol+144*0,64,0
 dc.l monstre+0000,survol+144*0,64,0
 dc.l monstre+0000,survol+144*0,64,0
 dc.l monstre+0000,survol+144*0,64,0
 dc.l monstre+0000,survol+144*0,64,0
 dc.l monstre+0000,survol+144*0,64,0

table_monstre_2
 dc.l -48,table_monstre
 dc.l 000,table_monstre
 dc.l +48,table_monstre

 dc.l -56,table_monstre+16
 dc.l 000,table_monstre+16
 dc.l +56,table_monstre+16

 dc.l -64,table_monstre+32
 dc.l 000,table_monstre+32
 dc.l +64,table_monstre+32

 dc.l 000,table_monstre+48  ** Non utilis‚...!
 dc.l 000,table_monstre+48
 dc.l 000,table_monstre+48  ** Non utilis‚...!
*********
 dc.l 000,table_monstre+48  ** Non utilis‚...!
 dc.l 000,table_monstre+48
 dc.l 000,table_monstre+48  ** Non utilis‚...!
 dc.l 000,table_monstre+48  ** Non utilis‚...!
 dc.l 000,table_monstre+48
 dc.l 000,table_monstre+48  ** Non utilis‚...!
*********
 
dongeon    incbin  data\dungeon.gfx    ; Ne pas d‚placer 
r_plafond equ dongeon        ;  7520 octets
r_sol     equ dongeon+7520   ; 16000 octets

 section BSS
mit
debut_bss
 ds.b 7520         Du rab pour le reverse du plafond
 
mur_map
 ds.b 9+1

cote_map
 ds.b 8
   
 even
  
adresse_mur    ds.l 1
hauteur_mur    ds.l 1

x_monstre      ds.w 1
y_monstre      ds.w 1
d_monstre      ds.w 1
v_monstre      ds.w 1
xo_monstre     ds.w 1
yo_monstre     ds.w 1

 ifeq finale
di             ds.l 1  ; sens du d‚placement
xp             ds.l 1  ; position X du joueur
yp             ds.l 1  ; position Y du joueur
flag_zik       ds.w 1
flag_ste       ds.w 1
map_connue     ds.b 640
 endc
key            ds.w 1

vol_ptr        ds.w 1

ecrans         ds.l 75776/4
  
buf1           ds.l 1
buf2           ds.l 1

compteur_rnd   ds.w 1

 even
 
r_side1         ds.b 3200
r_side2         ds.b 4200
r_side3         ds.b 800
r_side4         ds.b 608+(3200+4200+800+608)

r_cfontaine1    ds.b 3200
r_cfontaine2    ds.b 4200
r_cfontaine3    ds.b 800
r_cfontaine4    ds.b 608

r_cporte1       ds.b 3200
r_cporte2       ds.b 4200
r_cporte3       ds.b 800
r_cporte4       ds.b 608

r_cplaque1      ds.b 3200
r_cplaque2      ds.b 4200
r_cplaque3      ds.b 800
r_cplaque4      ds.b 608

 even

taille_reverse   ds.l 1
sauve_vbl        ds.l 1
sauve_hbl        ds.l 1
sauve_110        ds.l 1
sauve_118        ds.l 1

efface           ds.l 16
sauve_palette    ds.w 16
palette_affichee ds.l 1
palette_suivante ds.l 1

adresse_messages ds.l 1

porte_choisie    ds.w 1

loop_stf?        ds.w 1
debut_sample     ds.l 1
fin_sample       ds.l 1

                 ds.l 500
ma_pile          ds.l 1
sauve_ssp        ds.l 1
sauve_a7         ds.l 1
sauve_usp        ds.l 1

 even

sov_1            ds.b 1
sov_2            ds.b 1
sov_3            ds.b 1
sov_4            ds.b 1
sov_5            ds.b 1
sov_6            ds.b 1
sov_7            ds.b 1
sov_8            ds.b 1
sauve_frequence  ds.b 1
sauve_resolution ds.b 1
sauve_ecran_1    ds.b 1
sauve_ecran_2    ds.b 1
n_message        ds.b 1
clavier          ds.b 1
type_clavier     ds.b 1

synchro_flag     ds.b 1
compteur_vbl     ds.b 1

fading_flag      ds.b 1
fading_pos       ds.b 1
duree_message    ds.b 1
flag_swapping    ds.b 1

fin_bss          ds.b 4

 end

