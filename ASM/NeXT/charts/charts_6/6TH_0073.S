n_musique=5
duree_attente=15
y_pos=77
tempo=20
nbr_lettres=23
pause_restart=150
;
;
;                        The Sixth Charts
;
;                       ½  Dbug II from NEXT
;
;
;
 
pause macro
 dcb.w \1,$4e71
 endm

 opt o+,w-

offset_ecran = 0 
nop      = $4e71
y_scroll = 230
n        = 22

 jmp efface_bss
retourne_la_ou_il_le_faut_sale_con

 pea programme_principal
 move.w #$26,-(sp)
 trap #14
 addq #6,sp

 clr.w -(sp)
 trap #1



 
programme_principal
 move.l sp,sauve_sp
 lea ma_pile,sp

 
 moveq #n_musique,d0
 jsr musique

 move.l #ecrans,d0
 and.l #$ffffff00,d0
 add.l #256,d0
 move.l d0,ecran
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep.w (a0),d1
 move.w d1,sauve_ecran 
 movep.w d0,(a0)
 
 jsr prepare_ecran

 move.w #$2700,sr
 movem.l $ffff8240.w,d0-d7
 movem.l d0-d7,sauve_palette
 move.b $fffffa13.w,sauve_imra
 move.b $fffffa15.w,sauve_imrb
 move.b $ffff8260.w,sauve_rez
 clr.b $fffffa13.w
 clr.b $fffffa15.w
 clr.b $ffff8260.w
 move.b #2,$ffff820a.w
 move.l $70.w,sauve_70
 move.l #routine_vbl_bidon,$70.w
 jsr screen_choc
 move.w #$2300,sr

*
 jsr precalcule_fonte
 bra saute_intro
*
 jsr petit_fondu_au_noir
 jsr affiche_logo
 jsr apparition_logo
 jsr precalcule_fonte
 lea message_1,a0
 jsr affiche_message
 stop #$2300
 stop #$2300
 stop #$2300
 move.w #duree_attente,compteur_boucle
boucle_attente
 lea message_2,a0
 jsr affiche_message
 lea message_2,a0
 jsr efface_message
 subq.w #1,compteur_boucle
 beq.s fin_attente
 cmpi.b #$39+$80,$fffffc02.w
 bne.s boucle_attente
fin_attente
 lea message_1,a0
 jsr efface_message
 jsr disparition_logo

saute_intro
 jsr prepare_ecran
 movem.l palette_noire,d0-d7
 movem.l d0-d7,$ffff8240.w 

 jsr affiche_logo_charts
 jsr affiche_damier
 jsr affiche_image
; lea choix_charts+19+88,a0
; jsr affiche_lettre_charts
; jsr affiche_classement
 move.l #texte,scroll_ptr
 move.w #1,scroll_cpt
 move.l #texte_2,scroll_ptr_2
 move.w #15,scroll_cpt_2
 move.l #texte_3,scroll_ptr_3
 move.w #1,scroll_cpt_3
 move.l #zoom_list,zoom_ptr     
 move.l #choix_charts,charts_pos_1
 move.l #choix_charts,charts_pos_2
 move.w #nbr_lettres,fin_affichage
 move.w #0,joueur
 move.w #0,partie
 lea mess_joueur_joue,a0
 jsr affiche_informations
    
 stop #$2300
 move.l #routine_vbl,$70.w
   
attend_espace
 stop #$2300
 cmp.b #$39,$fffffc02.w
 bne.s attend_espace
  
 move.w #$2700,sr 
 move.l sauve_70,$70.w
 move.b sauve_imra,$fffffa13.w
 move.b sauve_imrb,$fffffa15.w
 move.b sauve_rez,$ffff8260.w
 movem.l sauve_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.w #$2300,sr
 lea $ffff8800.w,a0
 move.l #$07ff0800,d0
 movep.l d0,(a0)
 move.l #$09000a00,d0
 movep.l d0,(a0)
 lea $ffff8201.w,a0
 move.w sauve_ecran,d0 
 movep.w d0,(a0)
 jsr screen_choc
 move.l sauve_sp,sp
 rts 

****************************************
*                                      *
* Ici se trouve la programme principal *
*                                      *
****************************************

 opt o-

routine_vbl_bidon
 movem.l d0-a6,-(sp)
 jsr musique+8
 movem.l (sp)+,d0-a6
 rte
 
routine_vbl
 move.w #$2700,sr
 move.l a7,sauve_a7    ; 20

*
 move.l zoom_ptr,a0   ; 20
 move.w (a0)+,d7      ; 8
 bge .pas_raz_zoom    ; 12
 lea zoom_list,a0     ; 12
 move.w (a0)+,d7      ; 8
 move.l charts_pos_1,charts_pos_2  ; 36
 bra .raz_zoom        ; 12
.pas_raz_zoom
 pause 17
.raz_zoom
 move.l a0,zoom_ptr   ; 20
;
; La partie 1 prends 128 cycles soit 32 nops
;
 lea prestr,a3             ; 12
 adda.w d7,a3              ; 8
 move.l charts_pos_2,a0    ; 20
 move.l ecran,a2           ; 20
 lea 160+230*9+32(a2),a2   ; 8
 moveq #18,d1              ; 4
;
; La partie 2 prends 72 cycles soit 18 nops 
;
.lettre_suivante
 moveq #0,d0        ; 4
 move.b (a0)+,d0    ; 8
 lsl.w #5,d0        ; 6+5x2=16
 move.l a3,a1       ; 4
 adda.w d0,a1       ; 8 => 40/10
var set 0
 rept 16
 move.w (a1)+,var(a2)  ; 16x16=256/64
var set var+230 
 endr     
 lea 8(a2),a2       ; 8
 dbra d1,.lettre_suivante  ; 3/4
;
; La partie 3 prends:
; 19x(40+256+8+12)+16=6020 cycles soit 1505
;
; Total=32+18+1505=1555 nops
*

 lea $ffff8260.w,a0    ; 8 resolution 
 lea $ffff820a.w,a1    ; 8 frequence
 lea $ffff8240.w,a2    ; 8 palette
 
* Scrolltext 8x8 en haut de l'‚cran numero 1
horizontal_scroll_1
 move.l ecran,a3  ; 20
 lea 160(a3),a3   ; 8
 moveq #7,d0      ; 4
.ligne 
var set 208
 rept 27
 roxl.w var(a3)
var set var-8 
 endr
 lea 230(a3),a3
 dbra d0,.ligne  => (20+8+4)+(8x27x(8+8))+(7x12)+16+(8x8)=3652/913 nops
*

* Scrolltext 8x8 en haut de l'‚cran numero 2
horizontal_scroll_2
 move.l ecran,a3  ; 20
 lea 160+230*y_pos(a3),a3   ; 8
 moveq #7,d0      ; 4
.ligne 
var set 208
 rept 27
 roxl.w var(a3)
var set var-8 
 endr
 lea 230(a3),a3
 dbra d0,.ligne  => (20+8+4)+(8x27x(8+8))+(7x12)+16+(8x8)=3652/913 nops
*

nn=20
* Scrolltext 16x16 … droite de l'‚cran
 move.l ecran,a3
 lea 160+230*(8+130)+192(a3),a3
var set -230*(30+nn)
 rept 131+nn
 move.w var+230(a3),var(a3)
var set var+230 
 endr   ==> (20+8)+(131x20)=2648/662 nops
*

 pause 4283-(913)-(913)-(662)-(nn*5)-(1555)      ; -> 4283
; 19x(4+8+16+4+8+256+8)=19x(304+3)+4+72=5852 ==> 1463 nops

 lea $ffff8260.w,a0    ; 8 resolution 
 lea $ffff820a.w,a1    ; 8 frequence
 lea $ffff8240.w,a2    ; 8 palette
 moveq #0,d0
 move.b d0,(a1)
 pause 18
 moveq #2,d1
 move.b d1,(a1)
 
 lea $ffff8209.w,a3    ; 8 syncro
 moveq #16,d2
attend_syncro
 move.b (a3),d3   ; syncro
 beq.s attend_syncro
 sub.b d3,d2
 lsl.b d2,d3

 pause 86-3
 lea rasters,a3   ; 12


 move.w #87,d2 ; 8
.boucle_1
 move.l (a3)+,(a2)  ; 20
 pause 8-5
 move.b  d1,(a0)   ; haute 2
 nop
 nop
 move.b  d0,(a0)   ; basse 0
 pause 56
 move.w (a3)+,2(a2)  ; 16
 pause 29
 move.b  d0,(a1)   ; 60 hz
 nop
 move.b  d1,(a1)   ; 50 hz
 pause 12
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 dbra d2,.boucle_1
 pause 3
 
 move.w #122,d2 ; 8
.boucle_2
 dcb.w 2,nop
 move.b  d1,(a0)   ; haute 2
 nop
 nop
 move.b  d0,(a0)   ; basse 0
 pause 16
 movem.l pions,d3-d7/a3-a5  ; 20+64
 movem.l d3-d7/a3-a5,(a2)   ; 8+64  => 156/39 nops
 pause 89-39-31-16
 movem.l image,d3-d7/a3-a5  ; 20+64
 movem.l d3-d6,(a2)         ; 8+32  => 124/31 nops

 move.b  d0,(a1)   ; 60 hz
 nop
 move.b  d1,(a1)   ; 50 hz
 move.l d7,16(a2)   ; 16/4
 move.l a3,20(a2)   ; 16/4
 move.l a4,24(a2)   ; 16/4
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 move.l a5,28(a2)  ; 16/4
 dcb.w 2,nop
 dbra d2,.boucle_2
; jmp yurk
 
* Ici, on fout le bord bas une 1ere fois

 nop
 move.b  d1,(a0)   ; haute 2
 nop
 nop
 move.b  d0,(a0)   ; basse 0
 pause 89
 move.b d0,(a1)   ; 60 Hz
 nop
 move.b d1,(a1)   ; 50 Hz
 dcb.w 9,nop
 move.b d0,(a1)   ; 60 Hz
 nop
 move.b d1,(a0)   ; haute
 nop 
 move.b d0,(a0)   ; basse

 dcb.w 11,nop
 move.b d1,(a0)   ; haute
 move.b d1,(a1)   ; 50 Hz
 move.b d0,(a0)   ; basse
 pause 89
 move.b d0,(a1)   ; 60 Hz
 move.b d1,(a1)   ; 50 Hz
 dcb.w 13,nop
 move.b d1,(a0)   ; haute
 nop 
 move.b d0,(a0)   ; basse

 dcb.w 4,nop
 move.w #13,d2
.boucle_3 
 dcb.w 5,nop
 move.b  d1,(a0)   ; haute 2
 nop
 nop
 move.b  d0,(a0)   ; basse 0
 pause 89
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 dcb.w 13,nop
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 dcb.w 3,nop
 dbra d2,.boucle_3
 
* Ici, on fout le bord bas une seconde fois

 dcb.w 4,nop
 move.b  d1,(a0)   ; haute 2
 nop
 nop
 move.b  d0,(a0)   ; basse 0
 pause 89
 move.b d0,(a1)   ; 60 Hz
 nop
 move.b d1,(a1)   ; 50 Hz
 dcb.w 9,nop
 move.b d0,(a1)   ; 60 Hz
 nop
 move.b d1,(a0)   ; haute
 nop 
 move.b d0,(a0)   ; basse
 
 dcb.w 11,nop
 move.b d1,(a0)   ; haute
 move.b d1,(a1)   ; 50 Hz
 move.b d0,(a0)   ; basse
 pause 89
 move.b d0,(a1)   ; 60 Hz
 move.b d1,(a1)   ; 50 Hz
 dcb.w 13,nop
 move.b d1,(a0)   ; haute
 nop 
 move.b d0,(a0)   ; basse
;
; 229 lignes+11 = 240 lignes d'Overscan
;
 dcb.w 4,nop
 move.w #10,d2
.boucle_4
 dcb.w 5,nop
 move.b  d1,(a0)   ; haute 2
 nop
 nop
 move.b  d0,(a0)   ; basse 0
 pause 89
 move.b  d0,(a1)   ; 60 hz
 move.b  d1,(a1)   ; 50 hz
 dcb.w 13,nop
 move.b  d1,(a0)   ; haute
 nop 
 move.b  d0,(a0)   ; basse
 dcb.w 3,nop
 dbra d2,.boucle_4
yurk

 opt o+,w-

;
; On change la palette pour le logo "THE CHARTS"
;
 movem.l charts,d0-d7
 movem.l d0-d7,$ffff8240.w

;
; On scrolle le texte du haut numero 1
; 
rentre_lettre_1
 subq.w #1,scroll_cpt
 bne .pas_fini
 move.w #8,scroll_cpt
 moveq #0,d0
 move.l scroll_ptr,a0
 move.b (a0)+,d0
 bne .pas_raz_scroll
 lea texte,a0
 move.b (a0)+,d0
.pas_raz_scroll  
 move.l a0,scroll_ptr
 lsl.w #3,d0
 lea fonte_8,a0
 add.w d0,a0
 move.l ecran,a1
 lea 160+208(a1),a1
var set 0
 rept 8
 move.b (a0)+,var(a1)
var set var+230 
 endr
.pas_fini

;
; On scrolle le texte du haut numero 2
; 
rentre_lettre_2
 subq.w #1,scroll_cpt_3
 bne .pas_fini
 move.w #8,scroll_cpt_3
 moveq #0,d0
 move.l scroll_ptr_3,a0
 move.b (a0)+,d0
 bne .pas_raz_scroll
 lea texte_3,a0
 move.b (a0)+,d0
.pas_raz_scroll  
 move.l a0,scroll_ptr_3
 lsl.w #3,d0
 lea fonte_8,a0
 add.w d0,a0
 move.l ecran,a1
 lea 160+208+230*y_pos(a1),a1
var set 0
 rept 8
 move.b (a0)+,var(a1)
var set var+230 
 endr
.pas_fini

;
; On scrolle le texte du cot‚
; 
rentre_lettre_vertical
 addq.w #1,scroll_cpt_2
 cmp.w #16,scroll_cpt_2
 bne .pas_fini
 move.w #0,scroll_cpt_2
 moveq #0,d0
 move.l scroll_ptr_2,a0
 move.b (a0)+,d0
 bne .pas_raz_scroll
 lea texte_2,a0
 move.b (a0)+,d0
.pas_raz_scroll  
 sub.b #64,d0
 move.w d0,lettre_2
 move.l a0,scroll_ptr_2
.pas_fini  
 move.w lettre_2,d0
 lsl.w #5,d0
 lea fonte_16,a0
 add.w d0,a0
 move.w scroll_cpt_2,d0
 add.w d0,a0
 add.w d0,a0
 move.l ecran,a1
 add.l #160+192+230*239,a1
 move.w (a0),(a1)

*
 tst.w fin_affichage
 beq .pas_affichage
 subq.w #1,fin_affichage
 jsr affiche_lettre_charts
.pas_affichage 
*
  
fin_vbl    
 move.l sauve_a7,a7

 move.w #$700,$ffff8240.w
 move.w #$070,$ffff8240.w
 jsr musique+8
 move.w #$000,$ffff8240.w
 
 move.b $fffffc02.w,d0
 cmp.b #$62,d0
 beq __help

;
; Gestion du morpion
;
 move.w #$770,$ffff8240.w
gere_deplacement_morpion
 tst.w partie
 bne partie_finie
 tst.w joueur
 bne .pas_joueur
 cmp.b #$67,d0
 bmi .pas_pave
 cmp.b #$70,d0
 bpl .pas_pave
 jsr valide_pion
.pas_pave
 bra fin_deplacement_morpion
.pas_joueur
 tst.w wait_ordi
 beq pas_pause
 subq.w #1,wait_ordi
 bra fin_deplacement_morpion
pas_pause
 jsr ordinateur_joue
 lea mess_joueur_joue,a0
 jsr affiche_informations
fin_deplacement_morpion
 jsr teste_joueur_gagne
 tst.w partie
 bne partie_finie
 jsr teste_ordi_gagne
 tst.w partie
 bne partie_finie
 jsr teste_damier
partie_finie
 tst.w pause_partie_finie
 beq fin_gere_partie_finie
 subq.w #1,pause_partie_finie
 bne fin_gere_partie_finie
 jsr reaffiche_damier
 lea mess_ordi_joue,a0
 tst.w joueur
 bne .pas_ordi
 lea mess_joueur_joue,a0
.pas_ordi
 jsr affiche_informations
 move.w #0,partie
fin_gere_partie_finie

 move.w #$007,$ffff8240.w

 tst.w wait
 beq pas_wait
 subq.w #1,wait
 bne fin_wait
pas_wait
 cmp.b #$4a,d0
 bne pas_moins
 cmp.l #choix_charts,charts_pos_1
 beq pas_moins
 sub.l #88,charts_pos_1
 move.w #nbr_lettres,fin_affichage
 move.w #tempo,wait
pas_moins
 cmp.b #$4e,d0
 bne pas_plus
 cmp.l #fin_choix_charts-88,charts_pos_1
 bge pas_plus
 add.l #88,charts_pos_1
 move.w #nbr_lettres,fin_affichage
 move.w #tempo,wait  
pas_plus
fin_wait
 move.w #$000,$ffff8240.w
 rte

__help
 move.b #2,$ffff820a.w
 move.b #0,$ffff8260.w
 move.l #__help_vbl,$70.w
 rte

__help_vbl 
 jsr musique+8
 cmp.b #$61,$fffffc02.w
 beq __undo
 rte
  
__undo
 move.l #routine_vbl,$70.w
 rte

*****************************

prepare_ecran 
 move.l ecran,a0
 moveq #0,d1
 move.w #64000/16-1,d0
clear
 move.l d1,(a0)+
 move.l d1,(a0)+
 move.l d1,(a0)+
 move.l d1,(a0)+
 dbra d0,clear 
 rts

petit_fondu_au_noir
 lea palette_fondu,a0
 moveq #15,d0
.couleur_suivante
 stop #$2300
 stop #$2300
 stop #$2300
 lea $ffff8240.w,a1
 moveq #15,d1
.next
 move.w (a0),(a1)+
 dbra d1,.next
 add #2,a0
 dbra d0,.couleur_suivante
 rts

petit_fondu_au_blanc
 lea palette_fondu+15*2,a0
 moveq #15,d0
.couleur_suivante
 stop #$2300
 stop #$2300
 stop #$2300
 lea $ffff8240.w,a1
 moveq #15,d1
.next
 move.w (a0),(a1)+
 dbra d1,.next
 sub #2,a0
 dbra d0,.couleur_suivante
 rts

affiche_image
 lea image+32,a0
 move.l ecran,a1
 lea 160+230*76(a1),a1
 move.w #162,d0
.ligne_suivante
 rept 80/4
 move.l (a0)+,(a1)+
 endr
 lea 230-80(a1),a1
 dbra d0,.ligne_suivante 
 rts

***********************************************************
*
* Ici, se trouve tout ce qui concerne la gestion du morpion
*
***********************************************************

teste_ordi_gagne
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 lea plateau,a0
 lea table_recherche,a1
.teste_case_suivante
 move.b (a1)+,d1
 move.b (a1)+,d2
 move.b (a1)+,d3
 tst.b d1
 bmi .pas_gagne
 cmp.b #1,(a0,d1.w)
 bne .teste_case_suivante
 cmp.b #1,(a0,d2.w)
 bne .teste_case_suivante
 cmp.b #1,(a0,d3.w)
 bne .teste_case_suivante
 move.w #1,partie
 lea mess_ordi_gagne,a0
 jsr affiche_informations
 move.w #pause_restart,pause_partie_finie
.pas_gagne
 rts
 
teste_joueur_gagne
 moveq #0,d1
 moveq #0,d2
 moveq #0,d3
 lea plateau,a0
 lea table_recherche,a1
.teste_case_suivante
 move.b (a1)+,d1
 move.b (a1)+,d2
 move.b (a1)+,d3
 tst.b d1
 bmi .pas_gagne
 cmp.b #2,(a0,d1.w)
 bne .teste_case_suivante
 cmp.b #2,(a0,d2.w)
 bne .teste_case_suivante
 cmp.b #2,(a0,d3.w)
 bne .teste_case_suivante
 move.w #2,partie
 lea mess_joueur_gagne,a0
 jsr affiche_informations
 move.w #pause_restart,pause_partie_finie
.pas_gagne
 rts
 
teste_damier
 lea plateau,a0
.analyse_case_suivante
 tst.b (a0)+
 beq .trouve_case
 bmi damier_plein
 bra .analyse_case_suivante
.trouve_case
 rts

damier_plein
 move.w #3,partie
 lea mess_personne_gagne,a0
 jsr affiche_informations
 move.w #pause_restart,pause_partie_finie
 rts

teste_case
 move.b d5,(a0,d1.w)
 moveq #0,d2
 moveq #0,d3
 moveq #0,d4
 moveq #0,d6
 lea table_recherche,a1
.teste_case_suivante
 move.b (a1)+,d2
 move.b (a1)+,d3
 move.b (a1)+,d4
 tst.b d2
 bmi .pas_gagne
 cmp.b (a0,d2.w),d5
 bne .teste_case_suivante
 cmp.b (a0,d3.w),d5
 bne .teste_case_suivante
 cmp.b (a0,d4.w),d5
 bne .teste_case_suivante
 moveq #1,d6
.pas_gagne
 move.b #0,(a0,d1.w)
 rts
  
ordinateur_joue
;
; Phase de r‚flexion num‚ro un
;
phase_1
 lea plateau,a0
 moveq #0,d1
.analyse_case_suivante
 tst.b (a0,d1.w)
 bmi phase_2
 bne .saute_case
 moveq #1,d5
 jsr teste_case
 tst d6
 bne valide_case 
 moveq #2,d5
 jsr teste_case
 tst d6
 bne valide_case 
.saute_case
 addq.l #1,d1 
 bra .analyse_case_suivante
;
; Phase de r‚flexion num‚ro deux
;
phase_2
 lea plateau,a0
 moveq #0,d1
.analyse_case_suivante
 tst.b (a0,d1.w)
 beq valide_case
 bmi damier_plein
 addq.l #1,d1 
 bra .analyse_case_suivante
valide_case
 move.b #1,(a0,d1.w)
 add d1,d1
 lea pos_pion,a0
 add d1,a0
 move.l ecran,a1
 add.l #160+230*114+104,a1
 add.w (a0),a1
 lea pions+32+512*1,a0
var set 0
 rept 32
 movem.l (a0)+,d2-d5
 movem.l d2-d5,var(a1)
var set var+230 
 endr
 not.w joueur
 rts

valide_pion 
 moveq #0,d1
 move.b d0,d1
 sub #$67,d1
 lea plateau,a1
 tst.b (a1,d1.w)
 bne case_non_vide
 move.b #2,(a1,d1.w)
 add d1,d1
 lea pos_pion,a0
 add d1,a0
 move.l ecran,a1
 add.l #160+230*114+104,a1
 add.w (a0),a1
 lea pions+32+512*2,a0
var set 0
 rept 32
 movem.l (a0)+,d2-d5
 movem.l d2-d5,var(a1)
var set var+230 
 endr
 not.w joueur
 lea mess_ordi_joue,a0
 jsr affiche_informations
 move.w #20,wait_ordi
case_non_vide
 rts

affiche_informations
 move.l ecran,a1
 add.l #160+230*96+104-8-8-8,a1
 moveq #7,d1
.ligne_suivante 
var set 0
 rept 14
 move.w (a0)+,var(a1)
var set var+8
 endr
 lea 230(a1),a1
 dbra d1,.ligne_suivante
 rts
  
affiche_damier
 move.l ecran,a1
 add.l #160+230*114+104,a1
 lea pions+32,a0
var set 0
 rept 32
 movem.l (a0)+,d2-d5
 movem.l d2-d5,var+00+0*230*32(a1)
 movem.l d2-d5,var+16+0*230*32(a1)
 movem.l d2-d5,var+32+0*230*32(a1)
 movem.l d2-d5,var+00+1*230*32(a1)
 movem.l d2-d5,var+16+1*230*32(a1)
 movem.l d2-d5,var+32+1*230*32(a1)
 movem.l d2-d5,var+00+2*230*32(a1)
 movem.l d2-d5,var+16+2*230*32(a1)
 movem.l d2-d5,var+32+2*230*32(a1)
var set var+230 
 endr
 rts

reaffiche_damier
 lea plateau,a0
 clr.l (a0)+
 clr.l (a0)+
 clr.b (a0)+
 move.l ecran,a1
 add.l #160+230*(114+4)+104,a1
 lea pions+32+16*4,a0
var set 0
 rept 32-7
 movem.l (a0)+,d2-d5
 movem.l d2-d5,var+00+0*230*32(a1)
 movem.l d2-d5,var+16+0*230*32(a1)
 movem.l d2-d5,var+32+0*230*32(a1)
 movem.l d2-d5,var+00+1*230*32(a1)
 movem.l d2-d5,var+16+1*230*32(a1)
 movem.l d2-d5,var+32+1*230*32(a1)
 movem.l d2-d5,var+00+2*230*32(a1)
 movem.l d2-d5,var+16+2*230*32(a1)
 movem.l d2-d5,var+32+2*230*32(a1)
var set var+230 
 endr
 rts

****************************
*
* Reste...
*
****************************
  
affiche_logo_charts
 lea charts+32,a0
 move.l ecran,a1
 add.l #160+230*240+16,a1
 move.w #28,d0
.ligne_suivante 
var set 0
 rept 136/8
 move.l (a0)+,var(a1)
 move.l (a0)+,var+4(a1)
var set var+8 
 endr
 lea 160(a1),a1
 dbra d0,.ligne_suivante
 rts

affiche_logo
 lea logo+32,a0
 move.l ecran,a1
 lea 32+160*70(a1),a1
 move.w #90,d0
.ligne_suivante 
var set 0
 rept 12
 move.l (a0)+,var(a1)
 move.l (a0)+,var+4(a1)
var set var+8 
 endr
 lea 160(a1),a1
 dbra d0,.ligne_suivante
 rts

apparition_logo
 lea logo_pal,a0
 moveq #15,d0
.couleur_suivante
 stop #$2300
 stop #$2300
 stop #$2300
 lea $ffff8240.w,a1
 moveq #7,d1
.next
 move.l (a0)+,(a1)+
 dbra d1,.next
 dbra d0,.couleur_suivante
 rts

disparition_logo
 lea logo_pal+32*15,a0
 moveq #15,d0
.couleur_suivante
 stop #$2300
 stop #$2300
 stop #$2300
 lea $ffff8240.w,a1
 moveq #7,d1
.next
 move.l (a0)+,(a1)+
 dbra d1,.next
 lea -64(a0),a0
 dbra d0,.couleur_suivante
 rts

affiche_lettre_charts
 move.w fin_affichage,d0
 move.l charts_pos_1,a0
 lea 19(a0),a0
 add.w d0,a0
 move.l ecran,a2
 lea 160+230*(8+18)+8+8(a2),a2
 lsl.w #3,d0
 add.w d0,a2
 moveq #2,d7
.lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0
 lsl.w #5,d0
 lea prestr+1600*19,a1
 add.w d0,a1
var set 0
 rept 16
 move.w (a1)+,var(a2)
var set var+230 
 endr     
 lea 230*17(a2),a2
 lea 22(a0),a0
 dbra d7,.lettre_suivante
 rts

affiche_classement
 move #160+230*(8+18)+8+8,d6
 moveq #2,d5
.ligne_suivante
 move.l ecran,a2
 add.l d6,a2
 moveq #22,d7
.lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0
 lsl.w #5,d0
 lea prestr+1600*19,a1
 add.w d0,a1
var set 0
 rept 16
 move.w (a1)+,var(a2)
 move.w #0,var+2(a2)
 move.l #0,var+4(a2)
var set var+230 
 endr     
 lea 8(a2),a2
 dbra d7,.lettre_suivante
 add.l #230*17,d6
 dbra d5,.ligne_suivante
 rts

affiche_message
 move.l (a0)+,d6
 move.l a0,a4
 moveq #19,d7
.taille_suivante
 move.l a4,a0
 move.l ecran,a2
 add.l d6,a2
.lettre_suivante
 moveq #0,d0
 move.b (a0)+,d0
 beq .fin_message
 sub.b #64,d0
 lsl.w #5,d0
 moveq #19,d1
 sub.w d7,d1
 mulu #1600,d1
 lea prestr,a1
 add.w d1,a1
 add.w d0,a1
var set 0
 rept 16
 move.w (a1)+,var(a2)
 move.w #0,var+2(a2)
 move.l #0,var+4(a2)
var set var+160 
 endr     
 lea 8(a2),a2
 bra .lettre_suivante
.fin_message 
 stop #$2300
 dbra d7,.taille_suivante
 rts

efface_message
 move.l (a0)+,d6
 move.l a0,a4
 moveq #19,d7
.taille_suivante
 move.l a4,a0
 move.l ecran,a2
 add.l d6,a2
.lettre_suivante
 moveq #0,d0
 moveq #0,d1
 move.b (a0)+,d2
 beq .fin_message
 tst.w d7
 beq.s .efface_lettre
 move.b d2,d0
 sub.b #64,d0
 lsl.w #5,d0
 move.w d7,d1
 mulu #1600,d1
.efface_lettre
 lea prestr,a1
 add.w d1,a1
 add.w d0,a1
var set 0
 rept 16
 move.w (a1)+,var(a2)
 move.w #0,var+2(a2)
 move.l #0,var+4(a2)
var set var+160 
 endr     
 lea 8(a2),a2
 bra .lettre_suivante
.fin_message 
 stop #$2300
 dbra d7,.taille_suivante
 rts

precalcule_fonte
 lea stretch,a4
 moveq #19,d7
.fonte_suivante
 lea fonte_16,a0
 lea prestr,a1
 moveq #0,d6 
 move.w d7,d6
 mulu #1600,d6
 add.w d6,a1
 move.w #49,d6
.lettre_suivante
 move.l a4,a2
 move.w #15,d5
.ligne_suivante
 move.l a4,a3
 moveq #0,d0
 move.b (a2)+,d0
 add.b d0,d0
;
; D0 -> ligne … prendre
;
 move.w (a0)+,d1
;
; D1 -> les 16 pixels … stretcher
;   
 moveq #0,d2
 moveq #15,d4
.pixel_suivant
 moveq #15,d3
 sub.b (a3)+,d3 
 btst d4,d1
 beq.s .pixel_vide
 bset d3,d2
.pixel_vide
 dbra d4,.pixel_suivant
 move.w d2,0(a1,d0.w)
 dbra d5,.ligne_suivante  
 lea 32(a1),a1
 dbra d6,.lettre_suivante
 lea 16(a4),a4
 dbra d7,.fonte_suivante
 rts
 
efface_bss 
 lea debut_bss,a0
 lea fin_bss,a1
 moveq #0,d0
efface_suivant
 move.l d0,(a0)+
 cmp.l a1,a0
 bmi efface_suivant
 jmp retourne_la_ou_il_le_faut_sale_con

screen_choc 
 stop #$2300
 stop #$2300
 stop #$2300
 stop #$2300
 move.b #2,$ffff820a.w
 stop #$2300
 stop #$2300
 stop #$2300
 stop #$2300
 move.b #0,$ffff820a.w
 stop #$2300
 stop #$2300
 stop #$2300
 stop #$2300
 move.b #2,$ffff820a.w
 stop #$2300
 rts

 SECTION DATA

logo     incbin logo.dat
logo_pal incbin logo.pal
fin_logo_pal
charts   incbin charts.dat
pions    incbin pions.dat
messages incbin messages.txt
image    incbin bellamy.blk
fonte_16 incbin 16x16.fnt
fonte_8  incbin 8x8.fnt
stretch  incbin stretch.tbl
musique  incbin tlb.snd		*warp_gam.snd

 even

mess_ordi_joue      equ messages+224*0
mess_joueur_joue    equ messages+224*1
mess_ordi_gagne     equ messages+224*2
mess_joueur_gagne   equ messages+224*3
mess_personne_gagne equ messages+224*4
mess_recommence     equ messages+224*5

choix_charts
 incbin charts.txt
fin_choix_charts

 even
 
palette_fondu
 dc.w $fff,$777,$eee,$666,$ddd,$555,$ccc,$444
 dc.w $bbb,$333,$aaa,$222,$999,$111,$888,$000

 even

message_1
 dc.l 160*160+8*6
 dc.b "PRESENTS",0
 even
 
message_2
 dc.l 160*180+8*2
 dc.b "THE@SIXTH@CHARTS",0
 even

;classement_1
; dc.l 160+230*(8+18)+8+8
; dc.b "ABCDEFGHIJK@ABCDEFGHIJK",0
; dc.b "ABCDEFGHIJK@ABCDEFGHIJK",0
; dc.b "ABCDEFGHIJK@ABCDEFGHIJK",0
; even
  
texte
 dc.b "YYYaaaaooouuuhhhhh !!!!....... "
 dc.b "After a long time, here are the 6th Charts. "
 dc.b "Have a nice day, with these new stuff..."
 dc.b "And now, I restart...              "
 dc.b "      ½  Dbug II from NEXT                "
 dc.b 0

texte_2
 dc.b "HELLO@GUYS@@@HERE@IS@THE@SECOND@SCROLLING@OF@THIS@SCREEN@"
 dc.b "LET@S@WRAP@NOW"
 dc.b "@@@@@@@@@@@@@@@@@@@@"
 dc.b 0

texte_3
 dc.b "Arrrgggg !!!! Des bugs partout !!! "
 dc.b "A l'aide !!! "
 dc.b "Que faire ! Le morpion n'est pas meme entam‚ !... Yurk..."
 dc.b "      ½  Dbug II from NEXT                "
 dc.b 0

 even

zoom_list
var set 0
 rept 19
 dc.w var*1600
var set var+1
 endr
 rept 19
 dc.w var*1600
var set var-1
 endr
 dc.w -1
 
 even

rasters
 dc.w $222,$700,$700
 dc.w $444,$710,$710
 dc.w $666,$720,$720
 dc.w $777,$730,$730
 dc.w $666,$740,$740
 dc.w $555,$730,$730
 dc.w $444,$720,$720
 dc.w $222,$710,$710
 
 dc.w $000,$007,$007

 dc.w $000,$700,$700
 dc.w $000,$710,$710
 dc.w $000,$720,$720
 dc.w $000,$730,$730
 dc.w $000,$740,$740
 dc.w $000,$750,$750
 dc.w $000,$760,$760
 dc.w $000,$770,$770
 dc.w $000,$770,$770
 dc.w $000,$760,$760
 dc.w $000,$750,$750
 dc.w $000,$740,$740
 dc.w $000,$730,$730
 dc.w $000,$720,$720
 dc.w $000,$710,$710
 dc.w $000,$700,$700
 
 dc.w $000,$007,$007

 dc.w $000,$070,$707
 dc.w $000,$170,$717
 dc.w $000,$270,$727
 dc.w $000,$370,$737
 dc.w $000,$470,$747
 dc.w $000,$570,$757
 dc.w $000,$670,$767
 dc.w $000,$770,$777
 dc.w $000,$770,$777
 dc.w $000,$670,$767
 dc.w $000,$570,$757
 dc.w $000,$470,$747
 dc.w $000,$370,$737
 dc.w $000,$270,$727
 dc.w $000,$170,$717
 dc.w $000,$070,$707

 dc.w $000,$007,$007

 dc.w $000,$700,$077
 dc.w $000,$710,$067
 dc.w $000,$720,$057
 dc.w $000,$730,$047
 dc.w $000,$740,$037
 dc.w $000,$750,$027
 dc.w $000,$760,$017
 dc.w $000,$770,$007
 dc.w $000,$770,$007
 dc.w $000,$760,$017
 dc.w $000,$750,$027
 dc.w $000,$740,$037
 dc.w $000,$730,$047
 dc.w $000,$720,$057
 dc.w $000,$710,$067
 dc.w $000,$700,$077

 dc.w $000,$007,$007

 dc.w $000,$007,$000
 dc.w $000,$017,$111
 dc.w $000,$027,$222
 dc.w $000,$037,$333
 dc.w $000,$047,$444
 dc.w $000,$057,$555
 dc.w $000,$067,$666
 dc.w $000,$077,$777
 dc.w $000,$077,$777
 dc.w $000,$067,$666
 dc.w $000,$057,$555
 dc.w $000,$047,$444
 dc.w $000,$037,$333
 dc.w $000,$027,$222
 dc.w $000,$017,$111
 dc.w $000,$007,$000

 dc.w $000,$007,$007

 dc.w $222,$700,$700
 dc.w $444,$710,$710
 dc.w $666,$720,$720
 dc.w $777,$730,$730
 dc.w $666,$740,$740
 dc.w $555,$730,$730
 dc.w $444,$720,$720
 dc.w $222,$710,$710
 dc.w $111,$700,$700

 dcb.l 90,0
 
 even

; 012
; 345
; 678

table_recherche
 dc.b 0,1,2
 dc.b 3,4,5
 dc.b 6,7,8
 dc.b 0,3,6
 dc.b 1,4,7
 dc.b 2,5,8
 dc.b 0,4,8
 dc.b 2,4,6
 dc.b -1

table_preferences
 dc.b 4,0,2,8,6,1,5,7,3
 dc.b 4,8,6,0,2,1,5,7,3
 dc.b 4,6,0,2,8,1,5,7,3

 even
 
plateau
 dc.b 0,0,0
 dc.b 0,0,0
 dc.b 0,0,0
 dc.b -1
  
 even

pos_pion
var set 0
 rept 3
 dc.w var,16+var,32+var
var set var+230*32
 endr

 SECTION BSS

debut_bss

prestr         ds.l 32000/4   ; 20 fontes de 1600 octets (50 caracteres)

sauve_palette  ds.w 16
palette_noire  ds.w 16

ecrans         ds.l 64256/4

ecran          ds.l 1

compteur_boucle ds.w 1

*
scroll_ptr     ds.l 1
scroll_cpt     ds.w 1

scroll_ptr_2   ds.l 1
scroll_cpt_2   ds.w 1
lettre_2       ds.w 1

scroll_ptr_3   ds.l 1
scroll_cpt_3   ds.w 1

charts_pos_1   ds.l 1
charts_pos_2   ds.l 1

wait           ds.w 1

fin_affichage  ds.w 1

joueur         ds.w 1
partie         ds.w 1
wait_ordi      ds.w 1
pause_partie_finie ds.w 1
*

zoom_ptr       ds.l 1

sauve_ssp      ds.l 1
sauve_70       ds.l 1
sauve_sp       ds.l 1
sauve_a7       ds.l 1
sauve_ecran    ds.w 1

               ds.l 50
ma_pile        ds.l 1

sauve_rez      ds.b 1
sauve_imra     ds.b 1
sauve_imrb     ds.b 1

 even
 
fin_bss           ds.l 2
 
 end
