;
;                        ®Rotator STE¯
;                     ®Beat This Bit Dist¯
;                         ®Illusion¯
;                      Multipart Screen
;
;                         STE only !!!
;
;                 ½ / Dbug II from NEXT
;
;
; Note: Cette version fonctionne sur Mega STE
;
finale     equ 0          Flag selon que l'on est sous Devpac ou Non (0 par d‚faut)
fast       equ 1          Mettre … 1 pour acc‚lerer l'assemblage, et … 0 pour r‚duire la place occup‚e. (Finale)
largeur_ligne=4168        Largeur du buffer pour le text-megadist

 opt o+,w-




;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;% Macro qui fait une attente soit avec une succession de NOPs %
;% (FAST=1), soit en optimisant avec des instructions neutres  %
;% prenant plus de temps machine avec la mˆme taille           %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 ifne fast
pause macro
 dcb.w \1,$4e71
 endm
 elseif
pause macro
t6 set (\1)/6
t5 set (\1-t6*6)/5
t4 set (\1-t6*6-t5*5)/4
t3 set (\1-t6*6-t5*5-t4*4)/3
t2 set (\1-t6*6-t5*5-t4*4-t3*3)/2
t1 set (\1-t6*6-t5*5-t4*4-t3*3-t2*2)
 dcb.w t6,$e188
 dcb.w t5,$ed88
 dcb.w t4,$e988  ; 
 dcb.w t3,$1090  ; move.b (a0),(a0)
 dcb.w t2,$8080  ; move.b d0,d0
 dcb.w t1,$4e71  ; nop
 endm
 endc




;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;% Macro qui fait une attente avec un Dbra, d'o— un important %
;% gain de place, utilisation:                                %
;% <attend NombreDeNops,RegistreDeDonn‚eUtilis‚>              %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

attend macro
t set \1
t set t-6
b set t/3
n set t-(b*3)
 move #b,\2
 dbra \2,*
 dcb.w n,$4e71
 endm




 ifeq finale
 move.l #programme_principal,-(sp)
 move #$26,-(sp)
 trap #14
 addq #6,sp
 clr -(sp)
 trap #1
 elseif
bgt
 lea sbgt(pc),a0            Indispensable de reloger l'‚cran si il est
 lea $5000+25000+320000,a1  trop bas en RAM, a cause de la table de
 lea $5000+320000+28,a2     volume et des routines de calcul du soundtrack.
.loiu
 move.l -(a2),-(a1)
 cmp.l a0,a2
 bgt.s .loiu
 jmp $5000+25000
sbgt 
 org $b1a8             ***$5000+25000
 move #$2700,sr
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 bsr programme_principal
 move #$2700,sr
 dc.b "NEXTBACK"
 endc


 
programme_principal
 move #$2700,sr         Ignorer toutes les interruptions.

efface_bss
 lea debut_bss,a0       On commence par effacer la BSS par s‚curit‚
 lea fin_bss,a1         au cas o— un ‚ventuel d‚compacteur aurait laiss‚
 moveq #0,d0            des salet‚es.
.boucle_efface 
 move.l d0,(a0)+
 cmpa.l a1,a0 
 blt.s .boucle_efface 

 move.l usp,a0                 Les deux piles doivent etre sauv‚es en cas
 move.l a0,sauve_usp           d'utilisation plus ou moins r‚glementaire.
 move.l sp,sauve_ssp
 lea ma_pile,sp                  Je prends ma propre pile
 move.b $fffffa13.w,sauve_imra   Puis on sauve tous les vecteurs
 move.b $fffffa15.w,sauve_imrb   qui vont etre effac‚s.
 move.b $ffff820a.w,sauve_freq
 move.b $ffff8260.w,sauve_rez
 move.b $ffff8265.w,sauve_pixl
 movem.l $ffff8240.w,d0-d7       On sauve la palette courante puis on la
 movem.l d0-d7,sauve_palette     met en noir pour cacher les salet‚es.
 movem.l palette_noire,d0-d7     
 movem.l d0-d7,$ffff8240.w
 sf $fffffa13.w                  Plus d'interruptions MFP autoris‚es.
 sf $fffffa15.w

 lea $8.w,a0                Adresse de base des vecteurs (Erreur de Bus)
 lea liste_vecteurs,a1
 moveq #10-1,d0             On d‚tourne toutes les erreur possibles...
b_sauve_exceptions
 move.l (a1)+,d1            Adresse de la nouvelle routine

 move.l (a0)+,-4(a1)        Sauve l'ancienne
 move.l d1,-4(a0)           Installe la mienne 
 dbra d0,b_sauve_exceptions
 
 lea $80.w,a0             Adresse du premier TRAP (#0), sauv‚s car utilis‚s
 lea liste_traps,a1       comme temporisations ‚conomiques en place.
 moveq #16-1,d0
sauve_traps 
 move.l (a1)+,d1          Adresse de la nouvelle routine
 move.l (a0)+,-4(a1)      Sauve l'ancienne
 move.l d1,-4(a0)         Installe la mienne 
 dbra d0,sauve_traps 

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%								   %
;% Description des nouvelles fonctions TRAP:			   %
;%								   %
;% TRAP #0 -> 49 nops						   %
;% TRAP #1 -> 47 nops						   %
;% TRAP #2 -> 60 nops						   %
;% TRAP #3 -> 18 nops						   %
;% TRAP #4 -> 91 nops						   %
;% TRAP #5							   %
;% TRAP #6							   %
;% TRAP #7							   %
;% TRAP #8							   %
;% TRAP #9							   %
;% TRAP #10							   %
;% TRAP #11							   %
;% TRAP #12							   %
;% TRAP #13							   %
;% TRAP #14 -> Temporisation Dbra d6				   %
;% TRAP #15 -> Calcule un d‚grad‚ STE (de A0 vers A1 en 16 phases) %
;%								   %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 move.l $70.w,sauve_70
 move.l #routine_vbl_musique,$70.w
 bsr g‚nere_fullscreen    G‚n‚ration du code principal
 bsr initialise_fading    R‚initialise les rasters Rouge/Vert d'effacement.
 sf fading_flag           - Pas de fading … faire
 clr fading_pos           - Position 0 (Sombre)
 move #$2300,sr           La VBL est r‚autoris‚e (La seule restante)
;
; On positionne l'‚cran … la bonne adresse
;
 stop #$2300              Attend une VBL
 lea $ffff8201.w,a0       Pointeur sur base de l'‚cran (STF/E)
 move.l #ligne_vide,d0    Base du buffer de RAM Vid‚o
 move.b d0,d1
 lsr.l #8,d0
 movep.w (a0),d2               Sauve l'ancienne valeur
 move d2,sauve_ecran_1
 movep.w d0,(a0)               Ecrit la notre
 move.b 12(a0),sauve_vbaselo   Poids faible base Vid‚o (STE seulement)
 move.b d1,12(a0)               ($ffff820d.w)
 bsr screen_choc               Permet de r‚tablir l'‚cran si d‚callage

 moveq #1,d0
 jsr musique

 stop #$2300                          Logo illusion
 move.l #routine_vbl_musique,$70.w    VBL qui se contente de rejouer la musique
 bsr efface_ecran
 move.b #1,fading_flag                On pr‚pare le fondu (par pixelisation)
 clr fading_pos
 stop #$2300
 move.l #routine_vbl_logo,$70.w       Vbl destin‚e … afficher le logo pixelis‚
 move #250,d6                         durant 5 secondes
 bsr temporisation
 st fading_flag                       On fait le fading inverse
 bsr wait_fin_fade		      Jusqu'a la fin
  
;
; Puis le raster vertical pivotant
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 bsr efface_tout_buffer
 move.l #vas_vien,vas_vien_ptr
 bsr calcule_raster_vertical_1
 lea palette_noire,a0
 lea palette_raster,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_raster_vertical
 bsr prepare_table_rasters_3
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*7,d6
 trap #14

fin_demo
 moveq #0,d0
 jsr musique
  
 stop #$2300
 move.l #routine_vbl_musique,$70.w
 bsr screen_choc

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                       %
;% Maintenant, c'est fini et on restaure %
;% tout ce que l'on avait alt‚r‚.        %
;%                                       %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 move #$2700,sr 
recupere_plantage
 move.l sauve_70,$70.w

 lea $8.w,a0
 lea liste_vecteurs,a1
 moveq #10-1,d0
restaure_illegal 
 move.l (a1)+,(a0)+
 dbra d0,restaure_illegal
 
 lea $80.w,a0
 lea liste_traps,a1
 moveq #16-1,d0
restaure_traps 
 move.l (a1)+,(a0)+
 dbra d0,restaure_traps 

 move.b sauve_imra,$fffffa13.w
 move.b sauve_imrb,$fffffa15.w
 move.b sauve_freq,$ffff820a.w
 move.b sauve_rez,$ffff8260.w
 move.b sauve_pixl,$ffff8265.w
 move.b sauve_ecran_1,$ffff8201.w
 move.b sauve_ecran_2,$ffff8203.w
 move.b sauve_vbaselo,$ffff820d.w
 clr.b $ffff820d.w
 lea $ffff8201.w,a0
 movep d2,(a0)
 movem.l sauve_palette,d0-d7
 movem.l d0-d7,$ffff8240.w
 move.l sauve_ssp,sp
 move.l sauve_usp,a0
 move.l a0,usp
 move #$2300,sr
 rts 

flag_exit dc.w 0

boucle_attente
 sf flag_exit
.wait_loop 
 subq.w #1,d6                  Attente pr‚vue
 beq.s .fin_attente
 tst.b flag_exit
 bne .fin_attente
 stop #$2300
 stop #$2300
 stop #$2300
 move.b $fffffc02.w,d0         Une touche … ‚t‚ press‚e ???
 cmp.b #$44,d0                  -F10-     -> Quitte l'‚cran
 beq.s .fin_ecran
 cmp.b #$39,d0                 -ESPACE-   -> Phase suivante
 bne.s .wait_loop
 move.b #$80+8,$fffffc02.w     -> Evite les rebonds claviers
.fin_attente
 rts
.fin_ecran
 pea fin_demo                  Permet de revenir … la fin de l'‚cran
 rts

routine_trap_14
 bsr boucle_attente
 st fading_flag
 bsr wait_fin_fade
 rte
  
attend_fin_fading
 stop #$2300
 tst.b fading_flag
 bne.s attend_fin_fading
 rts
 
****************************************
*                                      *
* Ici se trouve la programme principal *
*                                      *
****************************************

routine_bus
 move.w #$070,d0
 bra.s execute_d‚tournement

routine_adresse
 move.w #$007,d0
 bra.s execute_d‚tournement
  
routine_illegal
 move.w #$700,d0
 bra.s execute_d‚tournement
  
routine_div
 move.w #$770,d0
 bra.s execute_d‚tournement
  
routine_chk
 move.w #$077,d0
 bra.s execute_d‚tournement
  
routine_trapv
 move.w #$777,d0
 bra.s execute_d‚tournement
  
routine_viole
 move.w #$707,d0
 bra.s execute_d‚tournement
  
routine_trace
 move.w #$333,d0
 bra.s execute_d‚tournement
  
routine_line_a
 move.w #$740,d0
 bra.s execute_d‚tournement
  
routine_line_f
 move.w #$474,d0
 bra.s execute_d‚tournement
  
execute_d‚tournement
 move.w #$2700,sr         Deux erreurs … suivre... non mais !
.loop
 move.w d0,$ffff8240.w    Zoli non ???
 move.w #0,$ffff8240.w
 cmp.b #$3b,$fffffc02.w
 bne.s .loop
 pea recupere_plantage    Ca vas t'y marcher ???
 move.w #$2700,-(sp)      J'espŠre !!!...
 rte                      On vas voir...
;
; C'est la s‚quence … faire pour r‚cuperer la main aprŠs ILLEGAL
;
 addq.l #2,2(sp)  *| 24/6
 rte              *| 20/5 => Total hors tempo=78-> 80/20 nops

liste_vecteurs
 dc.l routine_bus       Vert
 dc.l routine_adresse   Bleu
 dc.l routine_illegal   Rouge
 dc.l routine_div       Jaune
 dc.l routine_chk       Ciel
 dc.l routine_trapv     Blanc
 dc.l routine_viole     Violet
 dc.l routine_trace     Gris
 dc.l routine_line_a    Orange
 dc.l routine_line_f    Vert pale

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%				      %
;% L'appel … la routine de TRAP et le %
;% retour prends 14 nops              %
;%				      %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

routine_trap_4   *| 91 nops
 dcb 31,$4e71
routine_trap_2   *| 60 nops
 dcb 11,$4e71 
routine_trap_0   *| 49 nops
 dcb  2,$4e71
routine_trap_1   *| 47 nops
 dcb 29,$4e71
routine_trap_3   *| 18 nops
 dcb  4,$4e71
 rte             *| 20/5 => Total hors tempos=58-> 56/14 nops

routine_trap_5
routine_trap_6
routine_trap_7
routine_trap_8
routine_trap_9
routine_trap_10
routine_trap_11
routine_trap_12
routine_trap_13
 rte
 
liste_traps
 dc.l routine_trap_0
 dc.l routine_trap_1
 dc.l routine_trap_2
 dc.l routine_trap_3
 dc.l routine_trap_4
 dc.l routine_trap_5
 dc.l routine_trap_6
 dc.l routine_trap_7
 dc.l routine_trap_8
 dc.l routine_trap_9
 dc.l routine_trap_10
 dc.l routine_trap_11
 dc.l routine_trap_12
 dc.l routine_trap_13
 dc.l routine_trap_14
 dc.l routine_trap_15
  
screen_choc
 stop #$2300
 sf $ffff8260.w
 sf $ffff820a.w
 stop #$2300
 stop #$2300
 move.b #2,$ffff820a.w
 stop #$2300
 stop #$2300
 stop #$2300
 sf $ffff820a.w
 stop #$2300
 stop #$2300
 stop #$2300
 move.b #2,$ffff820a.w
 rts

 opt o-
 
routine_vbl_logo
 movem.l d0-a6,-(sp)
  
 lea $ffff8260.w,a1
 lea $ffff820a.w,a2
 lea $ffff8240.w,a3
 lea palette_presente,a4

 movem.l ligne_vide,d0-d7
 movem.l d0-d7,(a3)
 
 moveq #0,d0
 moveq #2,d1
    
 move.b $ffff820d.w,d4
 moveq #16,d2
attend_syncro
 move.b $ffff8209.w,d3
 sub.b d4,d3
 beq.s attend_syncro
 sub.b d3,d2
 lsl.b d2,d3

 attend 128*35+22,d7
 jsr affiche_logo

 movem.l (a4)+,d2-d6/a0/a5/a6   ; 12+8*8=76 / 19

 movem.l d6/a0/a5/a6,4*4(a3)   ;  12+8*4=44/11
 move.b d1,(a1)
 pause 2
 move.b d0,(a1)
 movem.l d2-d5,(a3)            ; 8+8*4=40/10
 movem.l (a4)+,d2-d6/a0/a5/a6     ; 12+8*8=76 ==> 116 / 29
 trap #2
 move.b d0,(a2)
 move.b d1,(a2)
 pause 11
 moveq #29-1,d7
.boucle_fullscreen 
 nop
 move.b d1,(a1)
 nop 
 move.b d0,(a1)
 movem.l d6/a0/a5/a6,4*4(a3)   ;  12+8*4=44/11
 move.b d1,(a1)
 pause 2
 move.b d0,(a1)
 movem.l d2-d5,(a3)            ; 8+8*4=40/10
 movem.l (a4)+,d2-d6/a0/a5/a6     ; 12+8*8=76 ==> 116 / 29
 trap #2
 move.b d0,(a2)
 move.b d1,(a2)
 pause 9
 dbra d7,.boucle_fullscreen
 move.b d1,(a1)
 nop 
 move.b d0,(a1)
  
 movem.l ligne_vide,d0-d7
 movem.l d0-d7,(a3)

 tst.b fading_flag
 beq.s .fin_fading
 bmi.s .fade_out
.fade_in
 move fading_pos,d0
 addq.w #1,d0
 move d0,fading_pos
 cmp.w #149,d0
 bne.s .fin_fading
 sf fading_flag
 bra.s .fin_fading
.fade_out
 subq.w #1,fading_pos
 bne.s .fin_fading
 sf fading_flag
.fin_fading 
   
 movem.l (sp)+,d0-a6
 rte
 
routine_vbl_musique
 movem.l d0-a6,-(sp)
 bsr execute_fading
 movem.l (sp)+,d0-a6
 rte

routine_lance_vbl
 move.l #routine_vbl,$70.w
 rte
 
routine_vbl
 move #$2700,sr
 movem.l d0-a6,-(sp)   ; 8+15*8=128/32

************** 
*            *
**************

border_normal
 attend 3865,d0

 move.l position_rouge,a0   5 Gestion des filets de couleur
 move.l position_vert,a1    5 servant au fading...
 lea liste_couleurs_1,a2    3
 lea liste_couleurs_2,a3    3
 moveq #5-1,d0              1 => 17
.recop_palette 
 move (a2)+,d2            2
 move (a3)+,d3            2 => 4
 rept 16
 move d2,(a0)+            2
 move d3,(a1)+            2 => 4*16=64
 endr
 dbra d0,.recop_palette     5*(4+64+3)+1 => 356+17 => 373

 move.l adresse_palette,$ffff8a24.w   --> 8

**************
*            *
**************

 lea $ffff8260.w,a1    ; 8 resolution 
 lea $ffff820a.w,a5    ; 8 frequence
 move.l lateral_ptr,a6 ; 20
__adresse_‚cran equ *+2
 move.l #ecrans,d7     ; 12/3
* addi.l #$80000000,d7  ;  8/2
  
 move.b $ffff820d.w,d4

 sf d0
 move.b d0,(a5)
 trap #3
 moveq #2,d3
 move.b d3,(a5)
 
 lea $ffff8209.w,a0    ; 8 syncro
 moveq #16,d2
.attend_syncro
 move.b (a0),d0   ; syncro
 sub.b d4,d0     ; 4
 beq.s .attend_syncro
 sub.b d0,d2
 lsl.b d2,d0

*
* ®aze¯ pour rechercher le d‚but de la VBL (apres synchro...)
*
 trap #2

 jsr buffer_g‚n‚ration     20/5

 opt o+
  
 bsr calcule_raster_vertical_1
 bsr calcule_raster_parallaxe
 bsr fading_fullscreen
 jsr musique+8
 movem.l (sp)+,d0-a6
 rte

calcule_raster_vertical_1
 move.l vas_vien_ptr,a0
 moveq #0,d0
 move (a0)+,d0
 bpl.s .pas_raz_table
 lea vas_vien,a0
 move (a0)+,d0
.pas_raz_table
 move.l a0,vas_vien_ptr
 mulu #548,d0
 move.l lateral_adr,a0
 add.l d0,a0
 move.l a0,lateral_ptr
 rts
 
calcule_raster_parallaxe
 lea motif_bares,a0
 move.w motif_bares_ptr,d0
 bne.s .not_yet
 move.w #320*20,motif_bares_ptr
.not_yet
 sub.w #320,motif_bares_ptr 
 add.w d0,a0
 move.l a0,__adresse_‚cran
 rts

motif_bares_ptr dc.w 0

 
***

;
; Rasters qui pivotent
;
prepare_table_rasters_3
 moveq #$ff-15,d2
 moveq #15,d3
 lea table_precalc,a0
 lea buffer_calcul,a1
 moveq #0,d0          Table des X
.image_suivante
 move.l (a0)+,d7      Charge l'incr‚ment
 move.l d0,d6         Charge X1
 swap d6               et on le renverse
 move #274-1,d1
.ligne_suivante
 swap d6              Plus pratique pour les calculs...
 move d6,d5
 and.b d2,d5
 lsr d5
 move.b d5,(a1)+      On sauve l'offset en X
 move d6,d5
 and.w d3,d5
 move.b d5,(a1)+
 swap d6
 add.l d7,d6
 dbra d1,.ligne_suivante
 addq.w #1,d0
 cmp.w #274,d0
 blt .image_suivante
 rts

 
**********************************************************
*
* Ici, la routine commune … toutes les VBL's, qui FADE les couleurs
*
*********************************************************
*
execute_fading
 tst.b fading_flag
 beq.s .fin_fading
 move fading_pos,d0
 lsl.w #5,d0 
 lea palette_fondue,a0
 movem.l 0(a0,d0.w),d0-d7
 movem.l d0-d7,$ffff8240.w
 tst.b fading_flag
 beq.s .fin_fading
 bmi.s .fade_out
.fade_in
 move fading_pos,d0
 addq.w #1,d0
 move d0,fading_pos
 cmp.w #15,d0
 bne.s .fin_fading
 sf fading_flag
 bra.s .fin_fading
.fade_out
 subq.w #1,fading_pos
 bne.s .fin_fading
 sf fading_flag
.fin_fading 
*************** ici en attendant !
 move.l #ligne_vide,d0
 move.b d0,d1
 lsr.l #8,d0
 move.b d0,$ffff8203.w 
 lsr.w #8,d0
 move.b d0,$ffff8201.w 
 move.b d1,$ffff820d.w 
 rts

;
;  Routine qui affiche 2 rouleaux de couleur qui scrollent vers le centre
; de l'‚cran: rouge en haut, vert en bas.
;
position_rouge dc.l 0
position_vert  dc.l 0

fading_fullscreen
 tst.b fading_flag
 beq .fin_fading
 move.l position_rouge,a0
 move.l position_vert,a1
 lea 32*5(a0),a2
 cmpa.l a1,a2
 blt.s .continue_fading
 sf fading_flag
 bsr initialise_fading
 bra .fin_fading

.continue_fading
 lea 32(a0),a0
 move.l a0,position_rouge
 lea -32(a1),a1
 move.l a1,position_vert
.fin_fading
 move.l #ligne_vide,d0
 move.b d0,d1
 lsr.l #8,d0
 move.b d0,$ffff8203.w 
 lsr.w #8,d0
 move.b d0,$ffff8201.w 
 move.b d1,$ffff820d.w 
 rts

liste_couleurs_1
 dc.w $000,$200,$500,$700,$500
liste_couleurs_2
 dc.w $050,$070,$050,$020,$000
  
******************************
**********************************
**************************************   G‚n‚ration de code
**********************************
******************************

g‚nere_fullscreen
 lea buffer_g‚n‚ration,a1

.cr‚ation_entete
 lea modŠle_d‚but,a0                     On lance le bord gauche
 move #(t_modŠle_d‚but/2)-1,d1
 bsr recopie_modŠle
 
 moveq #113-1,d0
.cr‚ation_1Šre_partie
 lea modŠle_palette_tracker,a0
 move #(t_modŠle_palette_tracker/2)-1,d1
 bsr recopie_modŠle
 dbra d0,.cr‚ation_1Šre_partie
  
.cr‚ation_centre
 lea modŠle_border_bas,a0
 move #(t_modŠle_border_bas/2)-1,d1
 bsr recopie_modŠle

 moveq #14-1,d0
.cr‚ation_2Šme_partie
 lea modŠle_palette_tracker,a0
 move #(t_modŠle_tracker_palette/2)-1,d1
 bsr recopie_modŠle
 dbra d0,.cr‚ation_2Šme_partie

.cr‚ation_fin
 lea modŠle_fin,a0               On termine le full proprement.
 move #(t_modŠle_fin/2)-1,d1
 bsr recopie_modŠle

 move #$4e75,(a1)+             On n'oublie pas le RTS … la fin !
 rts

recopie_modŠle 
 move (a0)+,(a1)+
 dbra d1,recopie_modŠle
 rts

commentaires macro
(( Liste des registres utilis‚s ))

a1 -> R‚solution  (8260.w)
a5 -> Fr‚quence   (820a.w)
a6 -> Table de distort 
d7 -> Pointe sur la ligne courante de l'‚cran

 Chaque bloc commence/fini … la limite du 1er passage qui d‚clanche le
border gauche. Le bloc de Border Bas prends 2 lignes.
  
 endm
 opt o-

modŠle_d‚but
 pause 6
 move #1,$ffff8a38.w            -> 4
 moveq #0,d4       ;  4/1
 move.b (a6)+,d4         ;  8/2
 add.l d7,d4       ;  8/2
 pause 4
 movep.l d4,-7(a5) ; 24/6
 move.b (a6)+,91(a5)       ; 12/4
 nop
 move.b d3,(a1)
 move.b d0,(a1)
t_modŠle_d‚but equ *-modŠle_d‚but

            *<<< ligne modŠle pour le Full-Palette >>>*
          *<<< ligne modŠle pour le Full-Soundtrack >>>*

modŠle_palette_tracker
 move.b #mlinebusy,$ffff8a3c.w    -> 38 nops
 move #1,$ffff8a38.w              -> 4
 trap #0                          -> 49 nops
 move.b d0,(a5)
 moveq #0,d4           4/1
 move.b d3,(a5)
 pause 8
 move.b (a6)+,d4       8/2
 add.l d7,d4           8/2
 move.b d3,(a1)
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)
 move.b d0,(a1)
.modŠle_replay
 trap #4
 move.b d0,(a5)            D‚clanchement border gauche
 moveq #0,d4           4/1
 move.b d3,(a5)
 pause 8
 move.b (a6)+,d4       8/2
 add.l d7,d4           8/2
 move.b d3,(a1)            Stabilisation border droit
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)            Border gauche
 move.b d0,(a1)
t_modŠle_palette_tracker equ *-modŠle_palette_tracker
 
          *<<< Triple ligne modŠle pour le Full-Bord Bas >>>*
               *<<< \+ palette \+ replay \+ palette>>>*

modŠle_border_bas
 move.b #mlinebusy,$ffff8a3c.w    -> 38 nops
 move #1,$ffff8a38.w              -> 4
 trap #0                          -> 49 nops
 move.b d0,(a5)
 moveq #0,d4           4/1
 move.b d3,(a5)
 pause 8
 move.b (a6)+,d4       8/2
 add.l d7,d4           8/2
 move.b d3,(a1)
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)
 move.b d0,(a1)
 trap #4
 move.b d0,(a5)
 moveq #0,d4          4/1
 move.b d3,(a5)
 move.b (a6)+,d4      8/2
 add.l d7,d4          8/2
 pause 5
 move.b d0,(a5)
 nop
 move.b d3,(a1)
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)         Attention, aprŠs ce passage, on n'a pas 91 nops de
 move.b d0,(a1)        libres, mais seulement 89, donc 2 nops sautent, ils
 move.b d3,(a5)        sont pris sur le changement de palette.
 move.b #mlinebusy,$ffff8a3c.w    -> 38 nops
 move #1,$ffff8a38.w              -> 4
 trap #1
 move.b d0,(a5)            D‚clanchement border gauche
 moveq #0,d4           4/1
 move.b d3,(a5)
 pause 8
 move.b (a6)+,d4       8/2
 add.l d7,d4           8/2
 move.b d3,(a1)            Stabilisation border droit
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)            Border gauche
 move.b d0,(a1)
t_modŠle_border_bas equ *-modŠle_border_bas

          *<<< ligne modŠle pour le Full-Soundtrack >>>*
            *<<< ligne modŠle pour le Full-Palette >>>*

modŠle_tracker_palette
 trap #4
 move.b d0,(a5)            D‚clanchement border gauche
 moveq #0,d4           4/1
 move.b d3,(a5)
 pause 8
 move.b (a6)+,d4       8/2
 add.l d7,d4           8/2
 move.b d3,(a1)            Stabilisation border droit
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)            Border gauche
 move.b d0,(a1)
.modŠle_palette
 move.b #mlinebusy,$ffff8a3c.w    -> 38 nops
 move #1,$ffff8a38.w              -> 4
 trap #0                          -> 49 nops
 move.b d0,(a5)
 moveq #0,d4           4/1
 move.b d3,(a5)
 pause 8
 move.b (a6)+,d4       8/2
 add.l d7,d4           8/2
 move.b d3,(a1)
 nop 
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 move.b (a6)+,91(a5)  12/3
 nop
 move.b d3,(a1)
 move.b d0,(a1)
t_modŠle_tracker_palette equ *-modŠle_tracker_palette

modŠle_fin
 trap #4
 move.b d0,(a5)            Border droit
 nop
 move.b d3,(a5)
 pause 12
 move.b d3,(a1)            Stabilisation Border droit
 moveq #0,d0
 move.b d0,(a1)
 lea $ffff8240.w,a1
 rept 8
 move.l d0,(a1)+
 endr
 sf 91(a5)
t_modŠle_fin equ *-modŠle_fin

t_g‚n‚ration=t_modŠle_d‚but+t_modŠle_palette_tracker*113+t_modŠle_border_bas+t_modŠle_tracker_palette*14+t_modŠle_fin+2

 opt o+,w-
  
******************************
**********************************
**************************************
**********************************
******************************


affiche_raster_vertical
 movem.l motif_raster+34,d2-d7
 lea ecrans,a1
 movem.l d2-d7,152-96(a1)
 movem.l d2-d7,152-48(a1)
 movem.l d2-d7,152(a1)
 movem.l d2-d7,152+48(a1)
 movem.l d2-d7,152+96(a1)
 rts

*
* $ffff8a00 16x().w
*
* HALFTONE, 16 mots d‚finissant un masque pour l'affichage
*
halftone=$00

*
* $ffff8a20 ().w
*
* SRC_XINC, Nombre d'octets qui s‚parent les adresses de 2 mots … copier
* cons‚cutifs, d'une meme ligne graphique
src_xinc=$20

*
* $ffff8a22 ().w
*
* SRC_YINC, Nombre d'octets qui s‚parent 2 lignes graphiques du bloc …
* copier
src_yinc=$22

src_addr=$24
endmask1=$28
endmask2=$2a
endmask3=$2c
dst_xinc=$2e
dst_yinc=$30
dst_addr=$32
x_count =$36
y_count =$38


*
* $ffff8A3A  (------xx).b
*
* HOP, r‚glage du mode demi_teinte
*  0 -> Uniquement bits 1
*  1 -> MASQUE
*  2 -> SOURCE uniquement
*  3 -> SOURCE and MASQUE
hop       =$3a
valeur_hop=3

*
* $ffff8A3B  (----xxxx).b
*
* OP, op‚ration logique entre la source et la destination
*  0-15 -> Voir BIT-BLT
op       =$3b
valeur_op=3

*
* $ffff8A3C (xxx-xxxx).b
*
*  bits 0-3 -> LINE_NUM (D‚finit le 1er registre de demi-teinte utilis‚)
*  bit 5    -> SMUDGE, active ou d‚sactive LINE_NUM (si non, utilise SRC_YINC comme base...)
*  bit 6    -> HOG, (1) 100% pour le blitter, sinon 50/50
*  bit 7    -> BUSY, mettre … 1 pour lancer, … z‚ro quand fini.
line_num =$3c
flinebusy=7
mlinebusy=128+64

*
* $ffff8a3d (xx--xxx).b
* 
*  bits 0-3, SKEW, d‚calage en bits, mod 16 du bloc cible vis … vis du bloc source.
*  bit 6   , NFSR, (1) lire un mot en plus en d‚but de ligne (No Final Source Read)
*  bit 7   , FXSR, (1) lire un mot de plus en fin de ligne (Force eXtra Source Read)
skew     =$3d
mskewfxsr=0   $80
mskewnfsr=0   $40

affiche_logo
 movem.l d0-a6,-(sp)
 jsr initialise_blitter_logo
 lea $ffff8a00.w,a5

 lea tramage,a0        150 phases de 32 octets
 move fading_pos,d0
 lsl #5,d0
 add.w d0,a0
 movem.l (a0),d0-d7    En une seule passe, le buffer de motifs est recopi‚.
 movem.l d0-d7,(a5)

 move.b #mlinebusy,line_num(a5)
 movem.l (sp)+,d0-a6
 rts

initialise_blitter_logo
 lea $ffff8a00.w,a5
 move #$ffff,endmask1(a5)
 move #$ffff,endmask2(a5)
 move #$ffff,endmask3(a5)

 move #208/2,x_count(a5)       Nombre de mots de largeur, du bloc … transf‚rer
 move #30,y_count(a5)          Nombre de lignes de hauteur
 
 move #2,src_xinc(a5)            Nombre de mots pour aller au suivant.
 move #2,src_yinc(a5)            Nombre d'octets … sauter aprŠs chaque ligne
 
 move #2,dst_xinc(a5)
 move #24,dst_yinc(a5)

 move.l #motif_presente,src_addr(a5)
 move.l #ecrans+160*85,dst_addr(a5)

 move.b #0,skew(a5)         
 
 move.b #valeur_hop,hop(a5)  **
 
 move.b #valeur_op,op(a5)   **
 rts

initialise_full_blitter 
 lea $ffff8a00.w,a5
 move #$ffff,endmask1(a5)
 move #$ffff,endmask2(a5)
 move #$ffff,endmask3(a5)
 move #2,src_xinc(a5)       Nombre de mots pour aller au suivant.
 move #2,src_yinc(a5)       Nombre d'octets … sauter aprŠs chaque ligne
 move #2,dst_xinc(a5)
 move #-30,dst_yinc(a5)       Si ca marche...
 move.l #$ff8240,dst_addr(a5)  Adresse de la palette...
 move.b #0,skew(a5)         
 move.b #2,hop(a5)
 move.b #3,op(a5)
 move #16,x_count(a5)       Nombre de mots de largeur, du bloc … transf‚rer
 rts

efface_tout_buffer 
 lea ligne_vide,a0
 moveq #0,d1
 move #(160+416+150152)/8-1,d0
.efface 
 move.l d1,(a0)+
 move.l d1,(a0)+
 dbra d0,.efface
 rts

efface_ecran
 lea ligne_vide,a0
 moveq #0,d1
 move #32000/8-1,d0
.efface 
 move.l d1,(a0)+
 move.l d1,(a0)+
 dbra d0,.efface
 rts

initialise_fading
 move.l adresse_palette,a0
 move.l a0,position_rouge
 sub.l #32*5,position_rouge
 move.l a0,position_vert
 add.l #32*130,position_vert
 sf fading_flag
 rts

;%%%%%%%%%%%%%
; Le passage de parametres … lieu par A0 -> Palette source
;%%%%%%%%%%%%%
routine_trap_15
calcule_d‚grad‚
 lea palette_fondue,a6         Cette routine cr‚e un d‚grad‚ … partir de
 movem.l (a0),d0-d7            deux palettes pass‚es en A0 et A1
 movem.l d0-d7,(a6)            en couleur STE qui conviennent...
 movem.l (a1),d0-d7
 movem.l d0-d7,480(a6)
 bsr execute_degrad‚
 rte
 
prepare_palette_globale
 lea palette_fondue,a0
 lea buffer_palettes,a1
 move.l a1,adresse_palette
 moveq #16-1,d0
.recop_palette
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette  

 move #129-32-1,d0
.recop_palette_2
 movem.l -32(a0),d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette_2

 moveq #16-1,d0
.recop_palette_3
 lea -32(a0),a0
 movem.l (a0),d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette_3
 rts

;#######################
; On est pri‚ de passer l'adresse de la palette en a6 !!! Merci...
;#######################
execute_degrad‚
;#######################
; D'abord, on calcule les offsets en pseudo d‚cimales
;#######################

calcule_offsets_fading
 move.l a6,a0
 lea 480(a6),a1
 lea offsets,a2           Buffers pour les offsets
 lea table_to_stf,a3      Table de conversion
 lea x_source,a4          Palette source d‚compos‚e en (R.l)+(V.l)+(B.l)
 moveq #16-1,d7
offset_couleur_suivante
 move (a0)+,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5       Bleu de d‚part
 swap d5
 move.l d5,(a4)+
 move (a1)+,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6       Bleu d'arriv‚e
 swap d6   
 sub.l d5,d6
 asr.l #4,d6               Offset bleu
 move.l d6,(a2)+
 
 lsr #4,d0
 move d0,d2
 and.w #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5       Vert de d‚part
 swap d5
 move.l d5,(a4)+
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6       Vert d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6               Offset vert
 move.l d6,(a2)+

 lsr #4,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5       Rouge de d‚part
 swap d5
 move.l d5,(a4)+
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6       Rouge d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6               Offset rouge
 move.l d6,(a2)+
    
 dbra d7,offset_couleur_suivante 

;#######################
; Puis le fading lui meme
;#######################

calcule_fading_palette
 lea x_source,a0
 move.l a6,a1         Palette source
 lea offsets,a2
 lea table_to_ste,a3
 move #16,compteur_couleur
couleur_suivante
 move.l a1,a4
 addq.w #2,a1
 move.l (a2)+,d0      Incr‚ment Bleu
 move.l (a2)+,d1      Incr‚ment Vert
 move.l (a2)+,d2      Incr‚ment Rouge
 move.l (a0)+,d3      Courant Bleu
 move.l (a0)+,d4      Courant Vert
 move.l (a0)+,d5      Courant Rouge
 move #16,compteur_phase
degr‚_suivant
 moveq #0,d7
 swap d5
 move.b (a3,d5.w),d6   Rouge converti en STE
 move.b d6,d7
 lsl #4,d7
 swap d5

 swap d4
 move.b (a3,d4.w),d6   Vert converti en STE
 or.b d6,d7
 lsl #4,d7
 swap d4

 swap d3
 move.b (a3,d3.w),d6   Bleu converti en STE
 or.b d6,d7
 swap d3
 move.w d7,(a4)       On sauve dans le buffer
 lea 32(a4),a4

 add.l d0,d3
 add.l d1,d4
 add.l d2,d5
    
 subq.w #1,compteur_phase
 bne degr‚_suivant
 subq.w #1,compteur_couleur
 bne couleur_suivante
 rts
   
table_to_stf
 dc.b 0
 dc.b 2
 dc.b 4
 dc.b 6
 dc.b 8
 dc.b 10
 dc.b 12
 dc.b 14
 dc.b 1
 dc.b 3
 dc.b 5
 dc.b 7
 dc.b 9
 dc.b 11
 dc.b 13
 dc.b 15


table_to_ste
 dc.b 0
 dc.b 8
 dc.b 1
 dc.b 9
 dc.b 2
 dc.b 10
 dc.b 3
 dc.b 11
 dc.b 4
 dc.b 12
 dc.b 5
 dc.b 13
 dc.b 6
 dc.b 14
 dc.b 7
 dc.b 15

 even

temporisation
 stop #$2300
 dbra d6,temporisation
 rts

wait_fin_fade
 tst.b fading_flag
 bne.s wait_fin_fade
 rts
 
 SECTION DATA
    
motif_presente    incbin d:\illusion.cut
motif_raster      incbin   d:\raster.dat

table_precalc     incbin d:\psdodeci.tbl
 
vas_vien          incbin d:\vas_vien.tbl

palette_raster    incbin   d:\raster.pal
palette_presente  incbin d:\illusion.pal

tramage           incbin  d:\tramage.ani

motif_bares       incbin    d:\bares.ani

musique           incbin d:\loader.mus
 
 even
 
adresse_palette  dc.l buffer_palettes
lateral_adr      dc.l buffer_calcul
lateral_ptr      dc.l buffer_calcul

 even

 SECTION BSS
mit 
debut_bss

 ds.w 1                  !!! Encore un ... de Bug … la con... Sale betes !
sauve_palette    ds.w 16

;
; J'explique:
; - Lorsqu'une image est affich‚e, pas besoin des 150 Ko de buffer.
; - Lorsque c'est le plasma ou le raster, 416 octets de ram Vid‚o suffisent.
; --> Donc, on fait un buffer commun !!!
;  56992 octets de RAM Video (274x208)
;  150152 octets pour le buffer de pr‚calcul.
;
; - Lorsque c'est le m‚gadistort texte:
; - 1 lettre = 16 octets x 16 lignes = 256 octets
; -  
;
palette_noire
ligne_vide        ds.b 160         Encore une grosse ruse pour pas etre 
ecrans            ds.l 416/4       gŠn‚ par la ligne de synchronisation !!! (Note en passant: Ca merde totalement !) (Re-note: En fait, si ‡a marche !!!)
buffer_calcul     ds.l 150152/4    On est pas … 150 Ko prŠs !!!
fin_buffer_calcul
buffer_g‚n‚ration ds.b t_g‚n‚ration Ici, on cr‚‚ du code (Surdimensionn‚ !)
fin_buffer_g‚n‚ration

                  ds.l 320/4
buffer_palettes   ds.l 4128/4      La palette d'une image est l… !
                  ds.l 320/4

vas_vien_ptr     ds.l 1

compteur_couleur ds.w 1       de fading et autres changements de
compteur_phase   ds.w 1       couleur.
x_source         ds.l 16*3
offsets          ds.l 16*3
palette_fondue   ds.l 512/4

;
;
;

sauve_ssp     ds.l 1
sauve_usp     ds.l 1
sauve_70      ds.l 1
              ds.l 400
ma_pile       ds.l 1

sauve_ecran_1 ds.b 1
sauve_ecran_2 ds.b 1

fading_pos    ds.w 1
fading_flag   ds.b 1
flag_quitte   ds.b 1

sauve_imra    ds.b 1
sauve_imrb    ds.b 1
sauve_freq    ds.b 1
sauve_rez     ds.b 1
sauve_pixl    ds.b 1
sauve_vbaselo ds.b 1

 even
 
fin_bss       ds.l 1

 end





