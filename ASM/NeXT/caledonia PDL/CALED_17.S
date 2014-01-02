nbrs=9                       here is the number of sprites to display
duree_tempo=50*5             reasonable time for a good reading
;
;
;     Intro COULEUR/MONOCHROME pour le catalogue de CALEDONIA PDL
;
;                  ½ 1992 Dbug II from NEXT
;
;
  
pause macro
 dcb.w \1,$4e71
 endm

 opt o+,w+

 pea programme_principal
 move #$26,-(sp)
 trap #14
 addq #6,sp
 clr -(sp)
 trap #1
 
programme_principal
 move.w #$2700,sr
 bra efface_bss
fin_efface_bss
 move.l sp,sauve_sp
 lea ma_pile,sp
 
 move.b $ffff8260.w,d0
 and.b #2,d0
 beq.s .pas_mono
 st mono_col
.pas_mono

 move.l #ecrans+256,d0
 sf d0
 move.l d0,image_1
 add.l #32000,d0
 move.l d0,image_2
 add.l #32000,d0
 move.l d0,ecran_1
 add.l #32000,d0
 move.l d0,ecran_2
 move.l d0,d1
 lsr.l #8,d0
 lea $ffff8201.w,a0
 movep.w 0(a0),d1
 move d1,sauve_ecran
 movep.w d0,0(a0)

 add #16000,d1
 lea informations_sprites,a0
 moveq #9*2-1,d0
.init_sauvegarde 
 move.l d1,(a0)+ 
 dbra d0,.init_sauvegarde 

 bsr prepare_image
 bsr predecalle_sprites

 tst.b mono_col
 bne.s .pas_sauve_couleur
   movem.l $ffff8240.w,d0-d7
   movem.l d0-d7,sauve_palette
   move.b $ffff8260.w,sauve_rez
   clr.b $ffff8260.w
   move.b #2,$ffff820a.w
   movem.l sprite_c,d0-d7
   movem.l d0-d7,$ffff8240.w
   bra.s .pas_init_mono
.pas_sauve_couleur 
   move.w #0,$ffff8240.w
.pas_init_mono
  
 move.b $fffffa07.w,sauve_iera
 move.b $fffffa09.w,sauve_ierb
 move.b $fffffa13.w,sauve_imra
 move.b $fffffa15.w,sauve_imrb
 move.b $fffffa17.w,sauve_vr
 move.b $fffffa1d.w,sauve_tcdcr
 move.b $fffffa25.w,sauve_tddr

 move.b #02,$fffffa07.w
 move.b #16,$fffffa09.w
 move.b #02,$fffffa13.w
 move.b #16,$fffffa15.w
 bclr #3,$fffffa17.w	
 move.b #07,$fffffa1d.w	
 move.b #246,$fffffa25.w

   
 move.l $70.w,sauve_70
 move.l $110.w,sauve_50hz
 move.l #routine_50hz,$110.w
 move.l #routine_vbl,$70.w

 sf vsync
 move #-1,ligne_lettre
 move ligne_lettre,d0
 st flag_vbl
 move.w #$2300,sr

 moveq #0,d0
 bsr musique


 
boucle_attente
;
; Prend la lettre suivante
;
 tst tempo
 beq.s .pas_tempo
 subq #1,tempo
 bra fin_gestion_texte
 
.pas_tempo
 tst ligne_lettre
 bpl nettoie_‚cran

 tst.b flag_vbl
 bne.s .lettres_passe_1
 tst.b mono_col
 bne.s .mono_texte
 bsr affiche_lettre_couleur
 bra fin_gestion_texte
.mono_texte
 bsr affiche_lettre_monochrome
 bra fin_gestion_texte

.lettres_passe_1

 move.l message_ptr,a0
.prend_lettre
 move.b (a0)+,d0
 bne.s .pas_fin_ligne 
 clr x_lettre             Fin de ligne, on passe ligne suivante
 add #160*17,y_lettre     -> Vaguement equivalent … 80*34
 move.l a0,message_ptr
 bra fin_gestion_texte

.pas_fin_ligne
 cmp.b #-1,d0
 bne.s .pas_fin_message 
 cmp.b #-1,(a0)
 bne.s .pas_fin_messages

 lea message,a0
.pas_fin_messages 

 clr x_lettre            Fin de texte, on remonte
 clr y_lettre
 clr ligne_lettre
 move #duree_tempo,tempo
 move.l a0,message_ptr
 bra fin_gestion_texte

.pas_fin_message
 move.l a0,message_ptr
;
; Recherche la lettre qui correspond
; 
 moveq #0,d2
 cmp.b #" ",d0              Pourquoi donc afficher les espaces ?
 beq.s space_final_frontier
 lea convert,a0
.cherche_suivante
 move.b (a0)+,d1
 beq fin_gestion_texte   Fin de la table, on affiche pas ! 
 move.b (a0)+,d2
 cmp.b d1,d0
 bne.s .cherche_suivante
    
 move x_lettre,d0
 move y_lettre,d1
 lsl #7,d2               taille d'une lettre

 tst.b mono_col
 bne.s mono_texte

 lea fonte_c,a0            Adresse de la fonte couleur
 add d2,a0                 adresse de la lettre
 movem.l a0/d0-d1,memo_lettre
 bsr affiche_lettre_couleur
 bra.s space_final_frontier 

mono_texte
 lea fonte_m,a0
 lsl d2
 add d2,a0
 movem.l a0/d0-d1,memo_lettre
 bsr affiche_lettre_monochrome
 
space_final_frontier
 moveq #8,d0
 tst.b mono_col
 beq.s .pas_cool
 moveq #4,d0
.pas_cool
 add d0,x_lettre
 bra fin_gestion_texte

nettoie_‚cran
 move ligne_lettre,d0
 mulu #160,d0
 move.l image_1,a0
 add d0,a0
 lea 32000(a0),a1
 move.l ecran_1,a2
 add d0,a2
 movem.l (a0)+,d0-d7/a4-a6  -> 44 octets
 movem.l d0-d7/a4-a6,(a1)
 movem.l d0-d7/a4-a6,(a2)
 movem.l (a0)+,d0-d7/a4-a6  -> 44 octets
 movem.l d0-d7/a4-a6,44(a1)
 movem.l d0-d7/a4-a6,44(a2)
 movem.l (a0)+,d0-d7/a4-a6  -> 44 octets
 movem.l d0-d7/a4-a6,88(a1)
 movem.l d0-d7/a4-a6,88(a2)
 movem.l (a0)+,d0-d6        -> 28 octets
 movem.l d0-d6,132(a1)
 movem.l d0-d6,132(a2)
 not.b flag_vbl
 tst.b flag_vbl
 beq.s fuck_erik  
 move ligne_lettre,d0
 addq #1,d0
 cmp #200,d0
 blt.s .pas_fini 
 move #-1,d0
 st flag_vbl
.pas_fini
 move d0,ligne_lettre
fuck_erik

fin_gestion_texte
;
; Efface l'ancien sprite
;
 tst.b mono_col
 beq.s .sprites_couleur
.sprites_mono
 bsr sprites_mono
 bra.s .fin_sprites
.sprites_couleur 
 bsr sprites_colo
.fin_sprites

 
;
; Nouvelle coordonn‚es
;
 cmp.b #$2a,$fffffc02.w
 beq.s enddd
 subq #2,angle_a
 bpl.s .pas_reset_a
 add #720,angle_a
.pas_reset_a

 subq #8,angle_b
 bpl.s .pas_reset_b
 add #720,angle_b
.pas_reset_b

 subq #4,angle_c
 bpl.s .pas_reset_c
 add #720,angle_c
.pas_reset_c

 subq #6,angle_d
 bpl.s .pas_reset_d
 add #720,angle_d
.pas_reset_d
enddd
;
; ‚change les ‚crans
;
 movem.l ecran_1,d0-d1
 exg d0,d1
 movem.l d0-d1,ecran_1
 lsr.l #8,d1
 lea $ffff8201.w,a0
 movep.w d1,(a0)

 sf vsync
attend_vbl
 tst.b vsync
 beq.s attend_vbl
 
 cmpi.b #$39,$fffffc02.w
 bne boucle_attente



 move.w #$2700,sr 
 bsr musique+8
 move.l sauve_70,$70.w
 move.b sauve_iera,$fffffa07.w
 move.b sauve_ierb,$fffffa09.w
 move.b sauve_imra,$fffffa13.w
 move.b sauve_imrb,$fffffa15.w
 move.b sauve_vr,$fffffa17.w
 move.b sauve_tcdcr,$fffffa1d.w
 move.b sauve_tddr,$fffffa25.w
 move.l sauve_50hz,$110.w
 lea $ffff8201.w,a0
 move sauve_ecran,d0
 movep.w d0,0(a0)

 move.l	#$08000000,$ffff8800.w
 move.l #$09000000,$ffff8800.w
 move.l #$0a000000,$ffff8800.w

 tst.b mono_col
 bne.s .pas_restaure_couleur
   move.b sauve_rez,$ffff8260.w
   movem.l sauve_palette,d0-d7
   movem.l d0-d7,$ffff8240.w
.pas_restaure_couleur

 move.l sauve_sp,sp
 move.w #$2300,sr
 rts 










affiche_lettre_couleur
 not.b flag_vbl
 movem.l memo_lettre,a0/d0-d1
 move.l image_2,a1
 move.l ecran_1,a2
 add d0,a1
 add d0,a2
 add d1,a1
 add d1,a2
var set 0
 rept 16
 move.l (a0)+,d0
 move.l (a0)+,d1

 move d0,d4  
 swap d0
 or d0,d4  

 or d1,d4  
 swap d0
 or d1,d4  

 not d4
 move d4,d5
 swap d4
 move d5,d4

 move.l var(a1),d2
 move.l var+4(a1),d3
 and.l d4,d2
 and.l d4,d3
 or.l d0,d2
 or.l d1,d3

 move.l d2,var(a1) 
 move.l d3,var+4(a1) 

 move.l d2,var(a2) 
 move.l d3,var+4(a2) 
var set var+160
 endr
 rts






affiche_lettre_monochrome
 not.b flag_vbl
 movem.l memo_lettre,a0/d0-d1
 move.l image_2,a1
 move.l ecran_1,a2
 add d0,a1
 add d0,a2
 add d1,a1
 add d1,a2
var set 0
 rept 32
 move.l var(a1),d2
 and.l (a0)+,d2
 or.l (a0)+,d2

 move.l d2,var(a1) 
 move.l d2,var(a2) 
var set var+80
 endr
 rts






sprites_colo
 move.l #32000,d6
 move.l ecran_2,d0
 cmp.l ecran_1,d0
 bgt.s .normal
 lsl.l d6
.normal
 
 lea informations_sprites(pc),a6   On commence par effacer l'ancienne
 moveq #nbrs-1,d7                  9 sprites
.efface_sprites 
 move.l (a6),a1                    Adresse sur l'‚cran
 addq #8,a6
 move.l a1,a0
 sub.l d6,a0                    
var set 0
 rept 30
 movem.l var(a0),d0-d5
 movem.l d0-d5,var(a1)             Et zou...
var set var+160
 endr
 dbra d7,.efface_sprites
;
; Affiche le sprite … l'‚cran
;
 move.l ecran_1,a2         Adresse de base pour l'affichage
 lea 160*85+72(a2),a2      (centre de l'‚cran)
 lea table_lettres_c,a3      Adresse de base du buffer de sprites
 lea table_160,a4
 lea table_sinus+90*2,a5   On pointe sur les COSINUS (Plus pratique)
 lea informations_sprites(pc),a6
 move.l angle_a,d4         Angle a+c
 move.l angle_b,d5         Angle b+d
 moveq #14,d6              D‚callages pour les angles
 moveq #nbrs-1,d7          9 sprites
affiche_sprite
 move.l a2,a0
 move.l (a3)+,a1

 move (a5,d4.w),d2       d2=COS(c)
 sub #18,d4
 swap d4
 move (a5,d4.w),d3       d3=COS(a)
 sub #18,d4
 swap d4
 move #143,d0              Rayon en X
 muls d2,d0                Multiplie par le rayon
 asr.l d6,d0               On divise par 16384
 muls d3,d0                Multiplie par le rayon
 asr.l d6,d0               On divise par 16384

 move (a5,d5.w),d2       d2=COS(c)
 sub #18,d5
 swap d5
 move (a5,d5.w),d3       d3=COS(a)
 sub #18,d5
 swap d5
 moveq #70,d1              Rayon en Y
 muls d2,d1                Multiplie par le rayon
 asr.l d6,d1               On divise par 16384
 muls d3,d1                Multiplie par le rayon
 asr.l d6,d1               On divise par 16384
 
 add d1,d1
 move (a4,d1.w),d1         On multiplie par 160
 move d0,d2
 asr d2                    Multiple de 8
 and #$ffff-7,d2         
 add d2,d1                 d1 -> adresse ‚cran
 add d1,a0
 move.l 4(a6),(a6)+
 move.l a0,(a6)+           On sauve la nouvelle position … l'‚cran.

 movem.l d4-d5,-(sp)

 and #15,d0
 mulu #1080,d0
 add d0,a1

 rept 30
 movem.l (a0),d0-d5
 and.l (a1),d0
 and.l (a1)+,d1
 and.l (a1),d2
 and.l (a1)+,d3
 and.l (a1),d4
 and.l (a1)+,d5
 or.l (a1)+,d0
 or.l (a1)+,d1
 or.l (a1)+,d2
 or.l (a1)+,d3
 or.l (a1)+,d4
 or.l (a1)+,d5
 movem.l d0-d5,(a0)
 lea 160(a0),a0
 endr


 movem.l (sp)+,d4-d5
 dbra d7,affiche_sprite
 rts

angle_a dc.w 0
angle_c dc.w 0
angle_b dc.w 0
angle_d dc.w 0

informations_sprites
 rept 9
 dc.l 0,0
 endr
  
var set -160*100
 rept 100
 dc.w var
var set var+160 
 endr
table_160
 rept 100
 dc.w var
var set var+160 
 endr








sprites_mono
 move.l #32000,d6
 move.l ecran_2,d0
 cmp.l ecran_1,d0
 bgt.s .normal
 move.l #64000,d6
.normal
 
 lea informations_sprites(pc),a6   On commence par effacer l'ancienne
 moveq #nbrs-1,d7                     9 sprites
.efface_sprites 
 move.l (a6),a1                    Adresse sur l'‚cran
 addq #8,a6
 move.l a1,a0
 sub.l d6,a0                    
var set 0
 rept 60
 move.l var(a0),var(a1)
 move.l var+4(a0),var+4(a1)
 move.w var+8(a0),var+8(a1)
var set var+80
 endr
 dbra d7,.efface_sprites
;
; Affiche le sprite … l'‚cran
;
 move.l ecran_1,a2         Adresse de base pour l'affichage
 lea 80*(200-30)+36(a2),a2      (centre de l'‚cran)
 lea table_lettres_m,a3      Adresse de base du buffer de sprites
 lea table_80,a4
 lea table_sinus+90*2,a5   On pointe sur les COSINUS (Plus pratique)
 lea informations_sprites(pc),a6
 move.l angle_a,d4         Angle a+c
 move.l angle_b,d5         Angle b+d
 moveq #14,d6              D‚callages pour les angles
 moveq #nbrs-1,d7             9 sprites
affiche_sprite2
 move.l a2,a0
 move.l (a3)+,a1

 move (a5,d4.w),d2       d2=COS(c)
 sub #18,d4
 swap d4
 move (a5,d4.w),d3       d3=COS(a)
 sub #18,d4
 swap d4
 move #280,d0              Rayon en X
 muls d2,d0                Multiplie par le rayon
 asr.l d6,d0               On divise par 16384
 muls d3,d0                Multiplie par le rayon
 asr.l d6,d0               On divise par 16384

 move (a5,d5.w),d2       d2=COS(c)
 sub #18,d5
 swap d5
 move (a5,d5.w),d3       d3=COS(a)
 sub #18,d5
 swap d5
 move #150,d1             Rayon en Y
 muls d2,d1                Multiplie par le rayon
 asr.l d6,d1               On divise par 16384
 muls d3,d1                Multiplie par le rayon
 asr.l d6,d1               On divise par 16384
 
 add d1,d1
 move (a4,d1.w),d1         On multiplie par 80
 move d0,d2
 asr #3,d2
 and #$fffe,d2         
 add d2,d1                 d1 -> adresse ‚cran
 add d1,a0
 move.l 4(a6),(a6)+
 move.l a0,(a6)+           On sauve la nouvelle position … l'‚cran.

 move.l d4,-(sp)

 moveq #15,d1
 sub d0,d1
 and #15,d1
 mulu #1200,d1
 add d1,a1

 rept 60
 movem.l (a1)+,d0-d4
 and.l d0,(a0)								
 or.l d1,(a0)+
 and.l d2,(a0)
 or.l d3,(a0)+
 and.w d4,(a0)
 swap d4
 or.w d4,(a0)+
 lea 70(a0),a0
 endr

 move.l (sp)+,d4
 dbra d7,affiche_sprite2
 rts

var set -80*200
 rept 200
 dc.w var
var set var+80 
 endr
table_80
 rept 200
 dc.w var
var set var+80 
 endr

routine_vbl
 st vsync
 rte

routine_50hz
 movem.l d0-a6,-(sp)
 bsr musique+4
 movem.l (sp)+,d0-a6
 rte
 
prepare_image
 tst.b mono_col
 bne.s prepare_image_mono
 lea livre_c,a0
 move.l ecran_1,a1
 lea 160*47+24(a1),a1
 move.l #-64000,d7
 move.l #-32000,d6
 moveq #105-1,d0
.recopie_ligne
 moveq #112/4-1,d1
.recopie_mot
 move.l (a0),(a1,d7.l)    Image 1
 move.l (a0),(a1,d6.l)    Image 2
 move.l (a0),32000(a1)    Ecran 2 
 move.l (a0)+,(a1)+       Ecran 1
 dbra d1,.recopie_mot 
 lea 48(a1),a1
 dbra d0,.recopie_ligne
 rts

prepare_image_mono
 lea livre_m,a0
 move.l ecran_1,a1
 lea 80*94+12(a1),a1
 move.l #-64000,d7
 move.l #-32000,d6
 move #209-1,d0
.recopie_ligne
 moveq #56/4-1,d1
.recopie_mot
 move.l (a0),(a1,d7.l)    Image 1
 move.l (a0),(a1,d6.l)    Image 2
 move.l (a0),32000(a1)    Ecran 2 
 move.l (a0)+,(a1)+       Ecran 1
 dbra d1,.recopie_mot 
 lea 24(a1),a1
 dbra d0,.recopie_ligne
 rts
 
predecalle_sprites
 tst.b mono_col
 bne predecalle_sprites_mono
 lea sprite,a6
 lea sprite_c+32,a5
 moveq #8-1,d5
lettre_suivante

 move.l a6,a1 
 moveq #16-1,d7
.logo_suivant
 move.l a5,a0
 moveq #30-1,d6
.ligne_suivante 
 lea 12(a1),a1
 moveq #3,d4
.mot_suivant 
 move.l (a0)+,(a1)+
 dbra d4,.mot_suivant
 clr.l (a1)+
 clr.l (a1)+
 dbra d6,.ligne_suivante
 dbra d7,.logo_suivant
 
decallage_du_vaisseau 
 move.l a6,a0
 add.l #17280,a0
 moveq #16-1,d7
.bloc_suivant
 move.l d7,d3
 moveq #16,d0
 sub.l d3,d0
 move #(720+360)/2-1,d1 ; 5808
.predecalle_bloc
 move -(a0),d6
 move -8(a0),d2
 lsr d3,d6        ; decalle de D3 rotations
 lsl d0,d2
 add d2,d6
 move d6,(a0)
 dbra d1,.predecalle_bloc
 dbra d7,.bloc_suivant
   
masquage_du_vaisseau
 move.l a6,a0
 move.l a0,a1
 moveq #16-1,d7
.sprite_suivant
 moveq #30-1,d6
.bloc_suivant 
 lea 12(a0),a0
 moveq #2,d4
.largeur 
 move (a0)+,d0
 or (a0)+,d0
 or (a0)+,d0
 or (a0)+,d0
 not d0
 move d0,d1
 swap d0
 move d1,d0
 move.l d0,(a1)+
 dbra d4,.largeur
 lea 24(a1),a1
 dbra d6,.bloc_suivant
 dbra d7,.sprite_suivant
 lea 480(a5),a5             On passe … la lettre suivante
 add.l #17280,a6

 dbra d5,lettre_suivante 
 rts


predecalle_sprites_mono
 lea sprite_m,a5         D'abord recopier le sprite en position 0
 lea sprite,a6

 moveq #8-1,d2           8 lettres … d‚caller 
.lettre_suivante
 move.l a6,a0
 
 move #300-1,d0
.recopie_premier
 move.l (a5)+,(a6)+
 dbra d0,.recopie_premier

 moveq #15-1,d1       Le premier n'a pas besoin de l'etre
.decallage_suivant
 moveq #60-1,d0
.ligne_suivante 
 move.l a6,a1
 move.l (a0)+,(a1)+  Recopie la ligne initiale
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 move.l (a0)+,(a1)+
 moveq #0,d7
 addx d7,d7
 roxl 16(a6)  Graph
 roxl 14(a6)
 roxl 12(a6)
 roxl 6(a6)
 roxl 4(a6)
 moveq #-1,d7
 addx d7,d7
 roxl 18(a6)  Maske
 roxl 10(a6)
 roxl 8(a6)
 roxl 2(a6)
 roxl (a6)
 lea 20(a6),a6 
 dbra d0,.ligne_suivante
 dbra d1,.decallage_suivant
 dbra d2,.lettre_suivante
 rts


 
 
 
efface_bss 
 lea debut_bss,a0
 lea fin_bss,a1
 moveq #0,d0
efface_suivant
 move.l d0,(a0)+
 cmp.l a1,a0
 bmi.s efface_suivant
 bra fin_efface_bss

 SECTION DATA

table_sinus    incbin sinus.tbl
musique        incbin lap2.snd
 even
 
sprite_c       incbin sprite_c.dat
livre_c        incbin livre_c.dat
fonte_c        incbin fonte_c.dat

sprite_m       incbin sprite_m.dat
livre_m        incbin livre_m.dat
fonte_m        incbin fonte_m.dat

table_lettres_c
 dc.l sprite+17280*1    A
 dc.l sprite+17280*7    I
 dc.l sprite+17280*6    N
 dc.l sprite+17280*5    O
 dc.l sprite+17280*4    D
 dc.l sprite+17280*3    E
 dc.l sprite+17280*2    L
 dc.l sprite+17280*1    A
 dc.l sprite+17280*0    C

table_lettres_m
 dc.l sprite+19200*1    A
 dc.l sprite+19200*7    I
 dc.l sprite+19200*6    N
 dc.l sprite+19200*5    O
 dc.l sprite+19200*4    D
 dc.l sprite+19200*3    E
 dc.l sprite+19200*2    L
 dc.l sprite+19200*1    A
 dc.l sprite+19200*0    C

convert
 dc.b "A",0,"a",0
 dc.b "B",1,"b",1
 dc.b "C",2,"c",2
 dc.b "D",3,"d",3
 dc.b "E",4,"e",4
 dc.b "F",5,"f",5
 dc.b "G",6,"g",6
 dc.b "H",7,"h",7
 dc.b "I",8,"i",8
 dc.b "J",9,"j",9
 dc.b "K",10,"k",10
 dc.b "L",11,"l",11
 dc.b "M",12,"m",12
 dc.b "N",13,"n",13
 dc.b "O",14,"o",14
 dc.b "P",15,"p",15
 dc.b "Q",16,"q",16
 dc.b "R",17,"r",17
 dc.b "S",18,"s",18
 dc.b "T",19,"t",19
 dc.b "U",20,"u",20
 dc.b "V",21,"v",21
 dc.b "W",22,"w",22
 dc.b "X",23,"x",23
 dc.b "Y",24,"y",24
 dc.b "Z",25,"z",25
 dc.b "!",26
 dc.b ":",27
 dc.b ".",28
 dc.b ";",29
 dc.b "?",30
 dc.b "0",14
 dc.b "1",8
 dc.b "2",25
 dc.b "3",31
 dc.b "4",32
 dc.b "5",18
 dc.b "6",33
 dc.b "7",34
 dc.b "8",1
 dc.b "9",35
 dc.b "-",36
 dc.b "'",37
 dc.l 0
 
message
 dc.b 0
 dc.b " welcome to the last",0
 dc.b "   update of this",0
 dc.b "    catalogue !",0
 dc.b 0
 dc.b "all the crew of the ",0
 dc.b "caledonia pdl wishes",0
 dc.b " you will enjoy our",0
 dc.b "     selection.",0
 dc.b -1

 dc.b 0
 dc.b "the file viewer had",0
 dc.b "been improved and it",0
 dc.b "allows you to use a ",0
 dc.b "monochrom monitor.",0
 dc.b 0
 dc.b "for having all the",0
 dc.b "information on its",0
 dc.b "use, just press the",0
 dc.b "HELP key, and read.",0
 dc.b -1

 dc.b "the credits:",0
 dc.b 0
 dc.b "  -Dbug from next-",0
 dc.b "for coding the intro",0
 dc.b "you are now looking",0
 dc.b "at !",0
 dc.b 0
 dc.b "  -MIT from next-",0
 dc.b "for coding the text-",0
 dc.b "viewer.",0
 dc.b -1

 dc.b 0,0
 dc.b "the musics are from",0
 dc.b "various authors:",0
 dc.b 0
 dc.b "    LAP -next-",0
 dc.b "   MAD MAX -tex-",0
 dc.b "   count 0 -e.i.-",0
 dc.b -1
 
 dc.b 0
 dc.b "we hope this intro",0
 dc.b "would perfectly run",0
 dc.b "on any machines, and",0
 dc.b "those including the",0
 dc.b "-TT-  -mega STE- and",0
 dc.b "the last one:       ",0
 dc.b 0
 dc.b "     --FALCON--",0
 dc.b -1
 
 dc.b "for the best public",0
 dc.b "domain on atari, one",0
 dc.b "adress:",0
 dc.b "--------------------",0
 dc.b "CALEDONIA PDL",0
 dc.b "250 oldtown road",0
 dc.b "HILTON",0
 dc.b "INVERNESS IV2 4PT",0
 dc.b "illverness-scotland",0
 dc.b "(0463) 225736",0
 dc.b "--------------------",0
 dc.b -1
 dc.b -1

 even

message_ptr   dc.l message
  
 SECTION BSS

debut_bss

palette_noire ds.w 16
sauve_palette ds.w 16

ecrans        ds.l 128256/4

*sprite        ds.l ((16*(24+12)*30))*8/4
sprite        ds.l 153600/4
 
memo_lettre   ds.l 3

image_1       ds.l 1 
image_2       ds.l 1 
ecran_1       ds.l 1
ecran_2       ds.l 1

x_lettre      ds.w 1
y_lettre      ds.w 1
ligne_lettre  ds.w 1
tempo         ds.w 1

sauve_ecran   ds.w 1

sauve_70      ds.l 1
sauve_120     ds.l 1
sauve_50hz    ds.l 1

              ds.l 80
ma_pile       ds.l 1
sauve_sp      ds.l 1

sauve_rez     ds.b 1
sauve_iera    ds.b 1
sauve_ierb    ds.b 1
sauve_imra    ds.b 1
sauve_imrb    ds.b 1
sauve_vr      ds.b 1
sauve_tcdcr   ds.b 1
sauve_tddr    ds.b 1

vsync         ds.b 1

flag_vbl      ds.b 1

mono_col      ds.b 1

fin_bss       ds.b 4
 
 end
