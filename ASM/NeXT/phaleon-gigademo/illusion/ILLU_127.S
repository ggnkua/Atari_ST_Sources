;
;			 ®Rotator STE¯
;		      ®Beat This Bit Dist¯
;			  ®Illusion¯
;		       Multipart Screen
;
;			  STE only !!!
;
;		  ½ / Dbug II from NEXT
;
;
; Note: Cette version fonctionne sur Mega STE
;
finale	   equ 0	  Flag selon que l'on est sous Devpac ou Non (0 par d‚faut)
fast	   equ 1	  Mettre … 1 pour acc‚lerer l'assemblage, et … 0 pour r‚duire la place occup‚e. (Finale)
largeur_ligne=4168	  Largeur du buffer pour le text-megadist

 opt o+,w-




;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;% Macro qui fait une attente soit avec une succession de NOPs %
;% (FAST=1), soit en optimisant avec des instructions neutres  %
;% prenant plus de temps machine avec la mˆme taille	       %
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
;% gain de place, utilisation:				      %
;% <attend NombreDeNops,RegistreDeDonn‚eUtilis‚>	      %
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
 lea sbgt(pc),a0	    Indispensable de reloger l'‚cran si il est
 lea $5000+25000+320000,a1  trop bas en RAM, a cause de la table de
 lea $5000+320000+28,a2     volume et des routines de calcul du soundtrack.
.loiu
 move.l -(a2),-(a1)
 cmp.l a0,a2
 bgt.s .loiu
 jmp $5000+25000
sbgt
 org $b1a8	       ***$5000+25000
 move #$2700,sr
 clr.b $fffffa07.w
 clr.b $fffffa09.w
 bsr programme_principal
 move #$2700,sr
 dc.b "NEXTBACK"
 endc



programme_principal
 move #$2700,sr 	Ignorer toutes les interruptions.

efface_bss
 lea debut_bss,a0	On commence par effacer la BSS par s‚curit‚
 lea fin_bss,a1 	au cas o— un ‚ventuel d‚compacteur aurait laiss‚
 moveq #0,d0		des salet‚es.
.boucle_efface
 move.l d0,(a0)+
 cmpa.l a1,a0
 blt.s .boucle_efface

 move.l usp,a0		       Les deux piles doivent etre sauv‚es en cas
 move.l a0,sauve_usp	       d'utilisation plus ou moins r‚glementaire.
 move.l sp,sauve_ssp
 lea ma_pile,sp 		 Je prends ma propre pile
 move.b $fffffa13.w,sauve_imra	 Puis on sauve tous les vecteurs
 move.b $fffffa15.w,sauve_imrb	 qui vont etre effac‚s.
 move.b $ffff820a.w,sauve_freq
 move.b $ffff8260.w,sauve_rez
 move.b $ffff8265.w,sauve_pixl
 movem.l $ffff8240.w,d0-d7	 On sauve la palette courante puis on la
 movem.l d0-d7,sauve_palette	 met en noir pour cacher les salet‚es.
 movem.l palette_noire,d0-d7
 movem.l d0-d7,$ffff8240.w
 sf $fffffa13.w 		 Plus d'interruptions MFP autoris‚es.
 sf $fffffa15.w

 lea $8.w,a0		    Adresse de base des vecteurs (Erreur de Bus)
 lea liste_vecteurs,a1
 moveq #10-1,d0 	    On d‚tourne toutes les erreur possibles...
b_sauve_exceptions
 move.l (a1)+,d1	    Adresse de la nouvelle routine

 move.l (a0)+,-4(a1)	    Sauve l'ancienne
 move.l d1,-4(a0)	    Installe la mienne
 dbra d0,b_sauve_exceptions

 lea $80.w,a0		  Adresse du premier TRAP (#0), sauv‚s car utilis‚s
 lea liste_traps,a1	  comme temporisations ‚conomiques en place.
 moveq #16-1,d0
sauve_traps
 move.l (a1)+,d1	  Adresse de la nouvelle routine
 move.l (a0)+,-4(a1)	  Sauve l'ancienne
 move.l d1,-4(a0)	  Installe la mienne
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
 bsr sauvegarde_systeme   On sauve le bas de la RAM avant d'y ‚crire.
 bsr init		  Puis initialise le Player de soundtrack
 bsr g‚nere_fullscreen	  G‚n‚ration du code principal
 bsr initialise_fading	  R‚initialise les rasters Rouge/Vert d'effacement.
 sf fading_flag 	  - Pas de fading … faire
 clr fading_pos 	  - Position 0 (Sombre)
 lea palette_noire,a0	  Calcul d'un d‚grad‚
 lea palette_8x8_brun,a1
 trap #15
 move #100,dur‚e_stretch  Nombre de VBLs … attendre avant de continuer.
 move #$2300,sr 	  La VBL est r‚autoris‚e (La seule restante)
;
; On positionne l'‚cran … la bonne adresse
;
 stop #$2300		  Attend une VBL
 lea $ffff8201.w,a0	  Pointeur sur base de l'‚cran (STF/E)
 move.l #ligne_vide,d0	  Base du buffer de RAM Vid‚o
 move.b d0,d1
 lsr.l #8,d0
 movep.w (a0),d2	       Sauve l'ancienne valeur
 move d2,sauve_ecran_1
 movep.w d0,(a0)	       Ecrit la notre
 move.b 12(a0),sauve_vbaselo   Poids faible base Vid‚o (STE seulement)
 move.b d1,12(a0)		($ffff820d.w)
 bsr screen_choc	       Permet de r‚tablir l'‚cran si d‚callage

 bsr lance_message		      Affiche le texte d'intro + boules
 move.l #stretch_go,bloc_stretch      Pr‚calcule "GO!"
 bsr precalcule_stretch
 bsr attend_fin_message 	      On attend la fin du texte.

 stop #$2300			      Logo illusion
 move.l #routine_vbl_musique,$70.w    VBL qui se contente de rejouer la musique
 bsr efface_ecran
 move.b #1,fading_flag		      On pr‚pare le fondu (par pixelisation)
 clr fading_pos
 stop #$2300
 move.l #routine_vbl_logo,$70.w       Vbl destin‚e … afficher le logo pixelis‚
 move #250,d6			      durant 5 secondes
 bsr temporisation
 st fading_flag 		      On fait le fading inverse
 bsr wait_fin_fade		      Jusqu'a la fin

 bsr lance_stretch		      Affiche "GO!"

 bsr lance_message		      "Paralax dist 2"
 bsr attend_fin_message

 stop #$2300			     Partie Mega-Scroll
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter	     Le blitter est initialis‚ pour les changements de palette
 bsr prepare_scrolling		     Pr‚-‚criture du texte
 bsr modifie_ajouts_ligne_scroll     Param‚trage de la routine principale
 bsr prepare_palette_motif	     Pr‚paration du fonds color‚
 bsr disting_multiple		     Mode distortion toutes les lignes
 clr offset_ecran
 move.l #dist_texte,lateral_adr
 move.l #dist_texte,lateral_ptr
 move.l #morceau_vbl_scrolltext,__morceau_vbl+2
 stop #$2300
 move.l #routine_lance_vbl,$70.w

 move #32000,d6 		     Temporisation
 trap #14

 stop #$2300
 move.l #routine_vbl_musique,$70.w
;
 bsr lance_message		      "Impression‚s ?"
 move.l #stretch_no,bloc_stretch      Affiche "NO!"
 bsr precalcule_stretch
 bsr attend_fin_message
 bsr lance_stretch

 bsr efface_tout_buffer
 bsr lance_message		      "ok... et un image dist‚e ???"
 bsr depacke_image
 bsr attend_fin_message
;
; Puis l'image
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 move.l #dist_image,lateral_adr
 move.l #dist_image,lateral_ptr
 move.l #morceau_vbl_distort,__morceau_vbl+2
 move.l #border_normal,__auto_border
 move.l #ecrans,__adresse_‚cran
 bsr affiche_image
 lea palette_noire,a0
 lea palette_image,a1
 trap #15
 bsr prepare_palette_globale
 move.l #208,d0
 bsr modifie_ajouts_ligne
 bsr disting_multiple
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*12,d6
 trap #14
;
 stop #$2300
 move.l #routine_vbl_musique,$70.w

 bsr lance_message		      "KID... PLASMA ???"
 move.l #stretch_yes,bloc_stretch     Affiche "YES!"
 bsr precalcule_stretch

 bsr attend_fin_message
 bsr lance_stretch

 bsr lance_message		      "OK, PLASMA !!!"
 bsr prepare_table_plasma
 bsr attend_fin_message

;
; Puis le plasma 1
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_plasma,__morceau_vbl+2
 bsr affiche_plasma
 moveq #0,d0
 bsr modifie_ajouts_ligne
 bsr disting_multiple
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*5,d6
 trap #14
;
; Suivi du plasma 2
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_raster_vertical,__morceau_vbl+2
 bsr affiche_plasma
 moveq #0,d0
 bsr modifie_ajouts_ligne
 bsr disting_multiple
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*5,d6
 trap #14
;
 bsr lance_message		    "Vertical rasters..."
 bsr attend_fin_message
;
; Puis le raster vertical fixe
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 bsr efface_tout_buffer
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_raster_vertical,__morceau_vbl+2
 bsr calcule_raster_vertical_1
 lea palette_noire,a0
 lea palette_raster,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_raster_vertical
 moveq #0,d0
 bsr modifie_ajouts_ligne
 bsr prepare_table_rasters_1
 bsr disting_multiple
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*5,d6
 trap #14
;
 bsr lance_message		    "Vertical rasters..."
 bsr attend_fin_message
;
; Puis le raster vertical lat‚ral
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr efface_tout_buffer
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_raster_vertical,__morceau_vbl+2
 bsr calcule_raster_vertical_1
 lea palette_noire,a0
 lea palette_raster,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_raster_vertical
 bsr prepare_table_rasters_2
 bsr disting_multiple
 moveq #0,d0
 bsr modifie_ajouts_ligne
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*5,d6
 trap #14
;
 bsr lance_message		    "Vertical rasters..."
 bsr attend_fin_message
;
; On affiche les cr‚dits
;
 stop #$2300			      Texte 1
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 bsr efface_tout_buffer
 bsr initialise_full_blitter
 move.l #416,d0
 bsr modifie_ajouts_ligne
 lea palette_noire,a0
 lea palette_next,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_logo_next
 bsr disting_simple
 clr offset_ecran
 move.l #dist_zero,lateral_adr
 move.l #dist_zero,lateral_ptr
 move.l #texte_ecran_1,adresse_texte
 move.w #10,d_texte
 clr x_texte
 clr.l y_texte
 move.l #ecrans,__adresse_‚cran
 move.l #morceau_vbl_texte,__morceau_vbl+2
 move.l #border_lettre,__auto_border
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #32000,d6
 trap #14

 stop #$2300			      Texte 2
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr efface_tout_buffer
 bsr initialise_full_blitter
 move.l #416,d0
 bsr modifie_ajouts_ligne
 lea palette_noire,a0
 lea palette_next,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_logo_next
 bsr disting_simple
 clr offset_ecran
 move.l #dist_zero,lateral_adr
 move.l #dist_zero,lateral_ptr
 move.l #texte_ecran_2,adresse_texte
 move.l #border_lettre,__auto_border
 move.w #10,d_texte
 clr x_texte
 clr.l y_texte
 move.l #ecrans,__adresse_‚cran
 move.l #morceau_vbl_texte,__morceau_vbl+2
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #32000,d6
 trap #14
;
 bsr lance_message		    "Et maintenant, ca pivote"
 bsr attend_fin_message
;
; Puis le raster vertical pivotant
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 bsr efface_tout_buffer
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_raster_vertical,__morceau_vbl+2
 move.l #border_normal,__auto_border
 bsr calcule_raster_vertical_1
 lea palette_noire,a0
 lea palette_raster,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_raster_vertical
 bsr prepare_table_rasters_3
 bsr disting_multiple
 moveq #0,d0
 bsr modifie_ajouts_ligne
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*7,d6
 trap #14
;
 bsr lance_message		    "Vertical rasters..."
 bsr attend_fin_message
;
; Puis le raster vertical pivotant avec couleurs
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 bsr efface_tout_buffer
 bsr initialise_full_blitter
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_raster_vertical,__morceau_vbl+2
 bsr calcule_raster_vertical_1
 lea palette_noire,a0
 lea palette_raster,a1
 trap #15
 bsr prepare_palette_raster
 bsr affiche_raster_vertical
 bsr prepare_table_rasters_3
 bsr disting_multiple
 moveq #0,d0
 bsr modifie_ajouts_ligne
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*7,d6
 trap #14
;
 bsr lance_message		    "Vertical rasters..."
 bsr attend_fin_message
;
; Puis le NOT-HAM-ROTATING raster
;
 stop #$2300
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr efface_tout_buffer
 move.l #buffer_calcul,lateral_adr
 move.l #buffer_calcul,lateral_ptr
 move.l #vas_vien,vas_vien_ptr
 move.l #morceau_vbl_raster_vertical,__morceau_vbl+2
 bsr calcule_raster_vertical_1
 bsr cr‚e_palette_plasma    ***!!! Plein de couleurs
 bsr affiche_raster_vertical
 moveq #0,d0
 bsr modifie_ajouts_ligne
 bsr prepare_table_rasters_1
 bsr disting_multiple
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*6,d6
 trap #14
;
 bsr lance_message		    "Et maintenant, comment ca marche"
 bsr attend_fin_message
;
; Le texte sur les specification techniques
;
 stop #$2300			      Texte 3
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr efface_tout_buffer
 bsr initialise_full_blitter
 move.l #416,d0
 bsr modifie_ajouts_ligne
 lea palette_noire,a0
 lea palette_next,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_logo_next
 bsr disting_simple
 clr offset_ecran
 move.l #dist_zero,lateral_adr
 move.l #dist_zero,lateral_ptr
 move.l #texte_ecran_3,adresse_texte
 move.w #10,d_texte
 clr x_texte
 clr.l y_texte
 move.l #ecrans,__adresse_‚cran
 move.l #morceau_vbl_texte,__morceau_vbl+2
 move.l #border_lettre,__auto_border
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #32000,d6
 trap #14
;
 bsr lance_message		    "Et maintenant, moving back"
 bsr attend_fin_message
;
; Et un super moving background avec un logo NEXT
;
 stop #$2300			      moving back
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr initialise_full_blitter
 bsr prepare_moving
 bsr modifie_ajouts_ligne_moving
 lea palette_noire,a0
 lea palette_moving,a1
 trap #15
 bsr prepare_palette_globale
 move.l #dist_image,lateral_adr
 move.l #dist_image,lateral_ptr
 move.l #morceau_vbl_moving,__morceau_vbl+2
 move.l #border_normal,__auto_border
 bsr disting_simple
 bsr calcule_rebond_vertical
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #50*6,d6
 trap #14
;
 bsr lance_message		    "Et maintenant, greetings !"
 bsr attend_fin_message
;
; Les greetings
;
 stop #$2300			      Texte 4
 clr fading_pos
 move.l #routine_vbl_musique,$70.w
 bsr efface_tout_buffer
 bsr initialise_full_blitter
 move.l #416,d0
 bsr modifie_ajouts_ligne
 lea palette_noire,a0
 lea palette_next,a1
 trap #15
 bsr prepare_palette_globale
 bsr affiche_logo_next
 bsr disting_simple
 clr offset_ecran
 move.l #dist_zero,lateral_adr
 move.l #dist_zero,lateral_ptr
 move.l #texte_ecran_4,adresse_texte
 move.w #10,d_texte
 clr x_texte
 clr.l y_texte
 move.l #ecrans,__adresse_‚cran
 move.l #morceau_vbl_texte,__morceau_vbl+2
 move.l #border_lettre,__auto_border
 stop #$2300
 move.l #routine_lance_vbl,$70.w
 move #32000,d6
 trap #14
;
 bsr lance_message		    "Do you like ???"
 move #300,dur‚e_stretch
 move.l #stretch_end,bloc_stretch   Affiche "THE END!"
 bsr precalcule_stretch
 bsr attend_fin_message
 bsr lance_stretch
;
 bsr lance_message		    "Do you like ???"
 move.l #stretch_next,bloc_stretch  Affiche "Copyright"
 bsr precalcule_stretch
 bsr attend_fin_message
 bsr lance_stretch

fin_demo

 stop #$2300
 move.l #routine_vbl_musique,$70.w
 bsr screen_choc



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%					 %
;% Maintenant, c'est fini et on restaure %
;% tout ce que l'on avait alt‚r‚.        %
;%					 %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 move #$2700,sr
recupere_plantage
 bsr restaure_systeme	On restaure le bas de la RAM
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
 bsr restaure_microwire
 move #$2300,sr
 rts

flag_exit dc.w 0

boucle_attente
 sf flag_exit
.wait_loop
 subq.w #1,d6		       Attente pr‚vue
 beq.s .fin_attente
 tst.b flag_exit
 bne .fin_attente
 stop #$2300
 stop #$2300
 stop #$2300
 move.b $fffffc02.w,d0	       Une touche … ‚t‚ press‚e ???
 cmp.b #$44,d0			-F10-	  -> Quitte l'‚cran
 beq.s .fin_ecran
 cmp.b #$39,d0		       -ESPACE-   -> Phase suivante
 bne.s .wait_loop
 move.b #$80+8,$fffffc02.w     -> Evite les rebonds claviers
.fin_attente
 rts
.fin_ecran
 pea fin_demo		       Permet de revenir … la fin de l'‚cran
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
*				       *
* Ici se trouve la programme principal *
*				       *
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
 move.w #$2700,sr	  Deux erreurs … suivre... non mais !
.loop
 move.w d0,$ffff8240.w	  Zoli non ???
 move.w #0,$ffff8240.w
 cmp.b #$3b,$fffffc02.w
 bne.s .loop
 pea recupere_plantage	  Ca vas t'y marcher ???
 move.w #$2700,-(sp)	  J'espŠre !!!...
 rte			  On vas voir...
;
; C'est la s‚quence … faire pour r‚cuperer la main aprŠs ILLEGAL
;
 addq.l #2,2(sp)  *| 24/6
 rte		  *| 20/5 => Total hors tempo=78-> 80/20 nops

liste_vecteurs
 dc.l routine_bus	Vert
 dc.l routine_adresse	Bleu
 dc.l routine_illegal	Rouge
 dc.l routine_div	Jaune
 dc.l routine_chk	Ciel
 dc.l routine_trapv	Blanc
 dc.l routine_viole	Violet
 dc.l routine_trace	Gris
 dc.l routine_line_a	Orange
 dc.l routine_line_f	Vert pale

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%				      %
;% L'appel … la routine de TRAP et le %
;% retour prends 14 nops	      %
;%				      %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

routine_trap_4	 *| 91 nops
 dcb 31,$4e71
routine_trap_2	 *| 60 nops
 dcb 11,$4e71
routine_trap_0	 *| 49 nops
 dcb  2,$4e71
routine_trap_1	 *| 47 nops
 dcb 29,$4e71
routine_trap_3	 *| 18 nops
 dcb  4,$4e71
 rte		 *| 20/5 => Total hors tempos=58-> 56/14 nops

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

position_stretch dc.w 0
sens_stretch	 dc.w 0

routine_vbl_stretch
 movem.l d0-a6,-(sp)

;
; On affiche le ciel ‚toil‚
;
 lea ligne_vide,a2
 lea etoiles,a3
 moveq #(20*2)-1,d7
etoile_suivante
 move.l a2,a4
 add.l (a3)+,a4

 moveq #0,d0
 move (a3),d0	; X pos dans d0
 sub.w 2(a3),d0
 tst.w d0
 bpl.s pas_raz_etoile
 move #319,d0
 clr (a4)
pas_raz_etoile
 move d0,(a3)
 lea 4(a3),a3
 move d0,d1
 and.w #%1111,d1
 move #15,d2
 sub.w d1,d2
 lsr.w #4,d0
 lsl.w #3,d0

 clr 8(a4,d0.w)
 move (a4,d0.w),d1
 clr d1
 bset d2,d1
 move d1,(a4,d0.w)
 dbra d7,etoile_suivante

 moveq #0,d0
 move position_stretch,d0
 move.l d0,d1
 mulu #8000,d1
 lea ecrans+32000,a0
 add.l d1,a0

 tst.w sens_stretch
 bpl.s .avant
.arriere
 subq.w #1,d0
 bne.s .fin
 move #1,sens_stretch
 bra.s .fin

.avant
 addq.w #1,d0
 cmp.w #14-1,d0
 bne.s .fin
 move #-1,sens_stretch
.fin
 move d0,position_stretch

 lea ligne_vide+6,a1
 move #200-1,d1
.recop_stretch
var set 0
 rept 40/2
 move (a0)+,var(a1)
var set var+8
 endr
 lea 160(a1),a1
 dbra d1,.recop_stretch

 bsr rejoue_zik
 bsr execute_fading

 movem.l (sp)+,d0-a6
 rte

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

 movem.l (a4)+,d2-d6/a0/a5/a6	; 12+8*8=76 / 19

 movem.l d6/a0/a5/a6,4*4(a3)   ;  12+8*4=44/11
 move.b d1,(a1)
 pause 2
 move.b d0,(a1)
 movem.l d2-d5,(a3)	       ; 8+8*4=40/10
 movem.l (a4)+,d2-d6/a0/a5/a6	  ; 12+8*8=76 ==> 116 / 29
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
 movem.l d2-d5,(a3)	       ; 8+8*4=40/10
 movem.l (a4)+,d2-d6/a0/a5/a6	  ; 12+8*8=76 ==> 116 / 29
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

 bsr rejoue_zik

 movem.l (sp)+,d0-a6
 rte

routine_vbl_musique
 movem.l d0-a6,-(sp)
 attend 128*150,d0
 bsr rejoue_zik
 bsr execute_fading
 movem.l (sp)+,d0-a6
 rte

;
; On oublie pas le soundtrack !
;
rejoue_zik
 bsr prepare_registres

premiere_passe
 move #adr_replay,._automodif_1+2
 move #64-1,d2
.rejoue_couple_suivant
._automodif_1
 jsr (adr_replay).w
 add.w #longueur_bloc,._automodif_1+2  88
 dbra d2,.rejoue_couple_suivant        3

seconde_passe
 move #adr_replay,._automodif_2+2
 move #64-1,d2
.rejoue2_couple_suivant
._automodif_2
 jsr (adr_replay).w
 add.w #longueur_bloc,._automodif_2+2
 dbra d2,.rejoue2_couple_suivant
 exg d5,a5
 bsr routine_calcul
 rts

routine_lance_vbl
 move.l #routine_vbl,$70.w
 rte

routine_vbl
 move #$2700,sr
 movem.l d0-a6,-(sp)   ; 8+15*8=128/32

**************
*	     *
**************
__auto_border equ *+2
 jmp border_normal	 3 nops pour l'aller, faire JMP retour border...

border_normal
 attend 4126-8-373,d0
 jmp retour_border

retour_border

 move.l position_rouge,a0   5 Gestion des filets de couleur
 move.l position_vert,a1    5 servant au fading...
 lea liste_couleurs_1,a2    3
 lea liste_couleurs_2,a3    3
 moveq #5-1,d0		    1 => 17
.recop_palette
 move (a2)+,d2		  2
 move (a3)+,d3		  2 => 4
 rept 16
 move d2,(a0)+		  2
 move d3,(a1)+		  2 => 4*16=64
 endr
 dbra d0,.recop_palette     5*(4+64+3)+1 => 356+17 => 373

 move.l adresse_palette,$ffff8a24.w   --> 8

 jsr prepare_registres

**************
*	     *
**************

 lea $ffff8260.w,a1    ; 8 resolution
 lea $ffff820a.w,a5    ; 8 frequence
 move.l lateral_ptr,a6 ; 20
__adresse_‚cran equ *+2
 move.l #ecrans,d7     ; 12/3
* addi.l #$80000000,d7	;  8/2

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
 sub.b d4,d0	 ; 4
 beq.s .attend_syncro
 sub.b d0,d2
 lsl.b d2,d0

*
* ®aze¯ pour rechercher le d‚but de la VBL (apres synchro...)
*
 trap #2

 jsr buffer_g‚n‚ration	   20/5

 opt o+

 exg d5,a5  *
 bsr routine_calcul

__morceau_vbl
 jmp morceau_vbl_distort  ; 12/3



*
*
*  Ici, le morceau de code pour le distort !
*
*
morceau_vbl_distort
 bsr calcule_distort_lat‚ral
 bsr fading_fullscreen
 movem.l (sp)+,d0-a6
 rte

calcule_distort_lat‚ral
 move.l lateral_ptr,a1
 cmp.w #-1,274*2(a1) ; tst.w 274*2(a1)
 bne.s .pas_raz
 move.l lateral_adr,lateral_ptr
 rts
.pas_raz
 addq.w #2,a1
 move.l a1,lateral_ptr
 rts

*
*
*  Ici, le morceau de code pour le scroll text
*
*
morceau_vbl_scrolltext
 bsr calcule_distort_texte
 bsr fading_fullscreen
 movem.l (sp)+,d0-a6
 rte

calcule_distort_texte
 move.l pos_rockfont,a0
 move.l (a0)+,d7
 bpl.s .pas_raz_tbl
 lea table_rockfont,a0
 move.l (a0)+,d7
.pas_raz_tbl
 move.l a0,pos_rockfont

 move.l lateral_ptr,a1
 cmp.w #-1,274*2(a1)
 bne.s .pas_raz
 move.l lateral_adr,lateral_ptr
 moveq #0,d0
 move.b (a1),d0
 add.w d0,offset_ecran
 cmp.w #fin_scrolling,offset_ecran
 blt.s .pas_fin_scroll
 st flag_exit
.pas_fin_scroll
 lea ecrans,a0
 add.w offset_ecran,a0
 add.l d7,a0
 move.l a0,__adresse_‚cran
 rts

.pas_raz
 addq.w #4,a1
 move.l a1,lateral_ptr
 lea ecrans,a0
 add.w offset_ecran,a0
 add.l d7,a0
 move.l a0,__adresse_‚cran
 rts

pos_rockfont dc.l table_rockfont
offset_ecran dc.w 0



*
*  Ici, le morceau de code pour le plasma
*
morceau_vbl_plasma
 bsr calcule_raster_vertical_1
 bsr fading_fullscreen
 movem.l (sp)+,d0-a6
 rte

*
*
*  Ici, le morceau de code pour le raster vertical...
*  Le moins que l'on puisse dire, c'est que le temps machine ne
*  manque pas trop...
*
morceau_vbl_raster_vertical
 bsr calcule_raster_vertical_1
 bsr calcule_raster_parallaxe
 bsr fading_fullscreen
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

*
*
*  Ici, le morceau de code pour le moving Background
*
*
morceau_vbl_moving
 bsr calcule_distort_lat‚ral
 bsr calcule_rebond_vertical
 bsr fading_fullscreen
 movem.l (sp)+,d0-a6
 rte

calcule_rebond_vertical
 move.l pos_backgrnd,a0
 move (a0)+,d0
 bpl.s .pas_raz_tbl
 lea table_backgrnd,a0
 move (a0)+,d0
.pas_raz_tbl
 move.l a0,pos_backgrnd
 lea ecrans,a0
 add.w d0,a0
 move.l a0,__adresse_‚cran
 rts

pos_backgrnd dc.l table_backgrnd

***

*
*
*  Ici, le morceau de code pour le texte qui s'affiche betement
*
*
morceau_vbl_texte
 bsr affiche_lettre
 bsr fading_fullscreen
 movem.l (sp)+,d0-a6
 rte

affiche_lettre
 subq #1,d_texte
 bne .fin_texte
 move #1,d_texte
 move.l adresse_texte,a0
 moveq #0,d0
 move.b (a0)+,d0
 tst.b d0
 bgt.s .pas_raz_texte
 beq.s .saut_de_ligne
 st flag_exit
 bra .fin_texte
.saut_de_ligne
 add.l #416*14,y_texte
 clr x_texte
 move #10,d_texte
 move.l a0,adresse_texte
 bra .fin_texte
.pas_raz_texte
 move.l a0,adresse_texte

 lea convert_8x8_brun,a0
 move.b (a0,d0.w),d0
 mulu #28,d0
 lea fonte_8x8_brun,a0
 lea (a0,d0.w),a4
 move.l a4,adr_lettre

 lea ecrans,a0
 move x_texte,d0
 lsr d0
 lsl #3,d0
 add d0,a0	      Multiple en largeur pour l'affichage
 move x_texte,d0
 and #1,d0
 add d0,a0
 add.l y_texte,a0
 move.l a0,adr_ecran
 addq.w #1,x_texte
.fin_texte
 rts

 opt o-

border_lettre
 move.l adr_lettre,a4
 move.l adr_ecran,a0
var set 0
 rept 14
 move.b (a4)+,d0	2
 move.b (a4)+,d1	2
 move.b d1,d2		1
 or.b d0,d2		1
 not.b d2		1
 and.b d2,var+0(a0)	4
 and.b d2,var+2(a0)	4
 and.b d2,var+4(a0)	4
 and.b d2,var+6(a0)	4
 or.b d0,var+0(a0)	4
 or.b d1,var+2(a0)	4 => 31x14=350 // 10+350=360
var set var+416
 endr
 attend 4126-8-373-(10+31*14),d0
 jmp retour_border

 opt o+

adresse_texte dc.l 0
y_texte       dc.l 0
x_texte       dc.w 0
d_texte       dc.w 0
dist_zero     dc.w 0
adr_lettre    dc.l ecrans
adr_ecran     dc.l ecrans

affiche_logo_next
 lea motif_next,a0
 lea ecrans+40+416*52,a1
 move #143-1,d0
.recop_y
 move #112/4-1,d1
.recop_x
 move.l (a0)+,(a1)+
 dbra d1,.recop_x
 lea 416-112(a1),a1
 dbra d0,.recop_y

 move.l #ecrans,adr_lettre
 move.l #ecrans,adr_ecran
 rts

texte_ecran_1
 dc.b 0
 dc.b "        - Credits for this screen go to - ",0
 dc.b 0
 dc.b " - Killer D from Full Metal Computer Connexion.   ",0
 dc.b "   She made the picture called ""Golden Girl"" that",0
 dc.b "   appears in the fullscreen picture distorter.",0
 dc.b 0
 dc.b " - MIT made the original module player, and ",0
 dc.b "   created the new file format we're now using...",0
 dc.b 0
 dc.b " - CHROMIX is a big lazy guy, and he drew only the",0
 dc.b "  ""Rockfont"" used in the mega-dist-scroller part",0
 dc.b "   of this pretty nice demo-screen. But he composed",0
 dc.b "   the Great module you can now hear if you put the",0
 dc.b "   volume to a decent value...",0
 dc.b 0
 dc.b "                And now, let's continue with the...",0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,-1
 even

texte_ecran_2
 dc.b 0
 dc.b 0
 dc.b "             - Dbug's ego trip part -             ",0
 dc.b 0
 dc.b "  Last but not least, a special screen for me coz ",0
 dc.b "  I was lacking of room in the previous one...  ",0
 dc.b " ",0
 dc.b "  I did the rest: ",0
 dc.b "  - This font and the 3 color ball, the palettes,",0
 dc.b "  the graphics of plasma and rasters, and that's ",0
 dc.b "  enough for the artistic touches... ",0
 dc.b "  - Almost all the code of this screen, including ",0
 dc.b "  the STE fulltrack replay rout, and the specific ",0
 dc.b "  research made for using the Shifter improvements",0
 dc.b "  in a fullscreen, and at last for all the blitter",0
 dc.b "  routines.",0
 dc.b "  - I did the scenario too... ",0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,-1
 even

texte_ecran_3
 dc.b 0
 dc.b 0
 dc.b "             - Why I like the STE ! -             ",0
 dc.b 0
 dc.b "  - The new color palette is a real improvement:",0
 dc.b "  the graphics and rasters are better than before.",0
 dc.b "  - The built-in hardscroll is really impressive,",0
 dc.b "  but using it in fullscreen is a little more",0
 dc.b "  difficult -the shifter bugs in some cases !-",0
 dc.b "  - The DMA sound is great and our last replay",0
 dc.b "  rout is really fast - with volume control -.",0
 dc.b "  - The BLITTER isn't as fast as we can hope,",0
 dc.b "  but it works synchronous, and is always a little",0
 dc.b "  faster than the equivalent 68000 code without",0
 dc.b "  the room taken in memory by it ! It's possible to",0
 dc.b "  do a blitter access in a synchronous routine as",0
 dc.b "  well as in a fullscreen, and it needs no",0
 dc.b "  registers ! -very useful, isn't it ???-",0
 dc.b "                    That's why I like the STE...",0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,-1
 even

texte_ecran_4
 dc.b 0
 dc.b 0
 dc.b "           - The greetings; they go to: -         ",0
 dc.b 0
 dc.b "ACF -Jacky-, DELTA FORCE -New Mode,Ray-, TEX -Udo,",0
 dc.b "Mad Max-, TLB -Sammy Joe-, St Cnx -Krazy et Alien-",0
 dc.b "Legacy -Vulcan et Fabrice-, Mystic -Ltk-, Dnt Crew",0
 dc.b "Zarathoustra, Lonewolf, Albedo, Hemoroids, Fraggles",0
 dc.b "Night Force, Foxx, TSB, Firehawks, NSM, FM, Reps ",0
 dc.b "TCB, Aggression, The vision, TCR, TNC, Megabusters",0
 dc.b "Newline, Dma, Ulm, Chaos, CAT, A. Grotzinger,  ",0
 dc.b "Dragons, Scoopex, RSI, Quartex, Budbrain, Phenomena",0
 dc.b "Alcatraz, Dual Crew, Rebels, Silents, Sanity, SYNC",0
 dc.b "Omega, Oxygene, Naos, and all I've forgotten.  ",0
 dc.b " Personal greetings to M.Samoyeau -A teacher-, ",0
 dc.b "Etienne -sans ton immense patience...-.  ",0
 dc.b "     No fucks this time: why speak about lamers ? ",0
 dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,-1
 even

***

;
; Rasters verticaux fixes.
;
prepare_table_rasters_1
 lea buffer_calcul,a1
 move #$2800,d2
 move #274-1,d0     Les X
.image_suivante
 move #274-1,d1     Les Y
.ligne_suivante
 move d2,(a1)+	    (40.b)(00.b) Offset+Pixel
 dbra d1,.ligne_suivante
 dbra d0,.image_suivante
 rts
;
; Rasters qui bougent de gauche … droite
;
prepare_table_rasters_2
 lea buffer_calcul,a1
 moveq #0,d0	      Table des X
.image_suivante
 move d0,d2	    Charge X1
 and.b #$ff-15,d2
 lsl.w #7,d2
 move.b d0,d2
 and.b #15,d2	      -> Poids faible, pixel
 move #274-1,d1
.ligne_suivante
 move d2,(a1)+	    (40.b)(00.b) Offset+Pixel
 dbra d1,.ligne_suivante
 addq.w #1,d0
 cmp.w #274,d0
 blt .image_suivante
 rts
;
; Rasters qui pivotent
;
prepare_table_rasters_3
 moveq #$ff-15,d2
 moveq #15,d3
 lea table_precalc,a0
 lea buffer_calcul,a1
 moveq #0,d0	      Table des X
.image_suivante
 move.l (a0)+,d7      Charge l'incr‚ment
 move.l d0,d6	      Charge X1
 swap d6	       et on le renverse
 move #274-1,d1
.ligne_suivante
 swap d6	      Plus pratique pour les calculs...
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

;
; 1Šre tentative de pr‚calcul pour le plasma
;
prepare_table_plasma
 lea table_sinus+90*2,a0
 lea fin_buffer_calcul,a1
 moveq #14,d3	      Angle pour les d‚callages
 moveq #0,d0	      Table des X
 move.w #360*2,d2
 move.l #137,d4
.image_suivante
 swap d7
 move d0,d7
 add.w d7,d7
 swap d7
 move d0,d7	    Charge X1
 add.w #90,d7
 add.w d7,d7

 move #274-1,d1
.ligne_suivante
*
;
; Ici, on s'occupe du calcul de l'ondulation centrale.
;
 swap d7
 move (a0,d7),d5
 muls #50,d5
 asr.l d3,d5	     -> D5 offset sur le centre
 add.w #2,d7
 cmp.w d2,d7
 blt.s .not_yet_1
 sub.w d2,d7
.not_yet_1
 swap d7
*
;
; L…, on s'occupe du calcul de l'ondulation m‚diane (Rayon)
;
 move (a0,d7),d6    Valeur sinus dans d6
 muls #24,d6	      Multiplie par le rayon
 asr.l d3,d6	      On divise par 16384
 add.l d4,d6	      Ajoute le centre (137)
 add.l d5,d6
 add.w #12,d7
 cmp.w d2,d7
 blt.s .not_yet
 sub.w d2,d7
.not_yet
*
 move d6,d5
 and.w #15,d5
 move.b d5,-(a1)
 and.b #$ff-15,d6
 lsr d6
 move.b d6,-(a1)	  On sauve l'offset en X
 dbra d1,.ligne_suivante
 addq.w #1,d0
 cmp.w #214,d0
 blt.s .image_suivante
.attend_fin_message
 tst.b flag_fin_message
 bne.s .attend_fin_message
 cmp.w #274,d0
 blt.s .image_suivante
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
**************************************	 G‚n‚ration de code
**********************************
******************************

g‚nere_fullscreen
 lea buffer_g‚n‚ration,a1

.cr‚ation_entete
 lea modŠle_d‚but,a0			 On lance le bord gauche
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
 lea modŠle_fin,a0		 On termine le full proprement.
 move #(t_modŠle_fin/2)-1,d1
 bsr recopie_modŠle

 move #$4e75,(a1)+	       On n'oublie pas le RTS … la fin !
 bsr remplace_dbug
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
*
*     border haut:    3805 nops -> 29 lignes
*
*	    d‚but: 6 nops  x1	-> 6
* palette tracker: 68 nops x113 -> 7684
*      border bas: 118	   x1	-> 118
* tracker palette: 68 nops x14	-> 952
*	   finale: 104	   x1	-> 104 -> 8864 = 69 lignes
*

modŠle_d‚but
 pause 6
 move #1,$ffff8a38.w		-> 4
 moveq #0,d4	   ;  4/1
 dc.w "MP"         ;  8/2
 add.l d7,d4	   ;  8/2
 addi.l #"DBUG",d7 ; 16/4
 movep.l d4,-7(a5) ; 24/6
 dc.b "~NeXT~"       ; 12/4
 move.b d3,(a1)
 move.b d0,(a1)
t_modŠle_d‚but equ *-modŠle_d‚but

	    *<<< ligne modŠle pour le Full-Palette >>>*
	  *<<< ligne modŠle pour le Full-Soundtrack >>>*

modŠle_palette_tracker
 move.b #mlinebusy,$ffff8a3c.w	  -> 38 nops
 move #1,$ffff8a38.w		  -> 4
 trap #0			  -> 49 nops
 move.b d0,(a5)
 moveq #0,d4	       4/1
 move.b d3,(a5)
 pause 4
 dc.w "MP"       8/2
 add.l d7,d4	       8/2
 addi.l #"DBUG",d7    16/4
 move.b d3,(a1)
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1)
 move.b d0,(a1)
.modŠle_replay
 pause 9
 jsr ("").w              D‚but de la s‚quence de 91 nops (!!!! pas 88...)
 move.b d0,(a5) 	   D‚clanchement border gauche
 moveq #0,d4	       4/1
 move.b d3,(a5)
 pause 4
 dc.w "MP"       8/2
 add.l d7,d4	       8/2
 addi.l #"DBUG",d7    16/4
 move.b d3,(a1) 	   Stabilisation border droit
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1) 	   Border gauche
 move.b d0,(a1)
t_modŠle_palette_tracker equ *-modŠle_palette_tracker

	  *<<< Triple ligne modŠle pour le Full-Bord Bas >>>*
	       *<<< \+ palette \+ replay \+ palette>>>*

modŠle_border_bas
 move.b #mlinebusy,$ffff8a3c.w	  -> 38 nops
 move #1,$ffff8a38.w		  -> 4
 trap #0			  -> 49 nops
 move.b d0,(a5)
 moveq #0,d4	       4/1
 move.b d3,(a5)
 pause 4
 dc.w "MP"       8/2
 add.l d7,d4	       8/2
 addi.l #"DBUG",d7    16/4
 move.b d3,(a1)
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1)
 move.b d0,(a1)
 pause 9		(2Šme ligne: Track)
 jsr ("").w          D‚but de la s‚quence de 91 nops (!!!! pas 88...)
 move.b d0,(a5)
 moveq #0,d4	      4/1
 move.b d3,(a5)
 dc.w "MP"      8/2
 add.l d7,d4	      8/2
 addi.l #"DBUG",d7   16/4
 nop
 move.b d0,(a5)
 nop
 move.b d3,(a1)
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1) 	Attention, aprŠs ce passage, on n'a pas 91 nops de
 move.b d0,(a1)        libres, mais seulement 89, donc 2 nops sautent, ils
 move.b d3,(a5)        sont pris sur le changement de palette.
 move.b #mlinebusy,$ffff8a3c.w	  -> 38 nops
 move #1,$ffff8a38.w		  -> 4
 trap #1
 move.b d0,(a5) 	   D‚clanchement border gauche
 moveq #0,d4	       4/1
 move.b d3,(a5)
 pause 4
 dc.w "MP"       8/2
 add.l d7,d4	       8/2
 addi.l #"DBUG",d7    16/4
 move.b d3,(a1) 	   Stabilisation border droit
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1) 	   Border gauche
 move.b d0,(a1)
t_modŠle_border_bas equ *-modŠle_border_bas

	  *<<< ligne modŠle pour le Full-Soundtrack >>>*
	    *<<< ligne modŠle pour le Full-Palette >>>*

modŠle_tracker_palette
 pause 9
 jsr ("").w              D‚but de la s‚quence de 91 nops (!!!! pas 88...)
 move.b d0,(a5) 	   D‚clanchement border gauche
 moveq #0,d4	       4/1
 move.b d3,(a5)
 pause 4
 dc.w "MP"       8/2
 add.l d7,d4	       8/2
 addi.l #"DBUG",d7    16/4
 move.b d3,(a1) 	   Stabilisation border droit
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1) 	   Border gauche
 move.b d0,(a1)
.modŠle_palette
 move.b #mlinebusy,$ffff8a3c.w	  -> 38 nops
 move #1,$ffff8a38.w		  -> 4
 trap #0			  -> 49 nops
 move.b d0,(a5)
 moveq #0,d4	       4/1
 move.b d3,(a5)
 pause 4
 dc.w "MP"       8/2
 add.l d7,d4	       8/2
 addi.l #"DBUG",d7    16/4
 move.b d3,(a1)
 nop
 move.b d0,(a1)
 movep.l d4,-7(a5)    24/6
 dc.b "~NeXT~"  12/3
 move.b d3,(a1)
 move.b d0,(a1)
t_modŠle_tracker_palette equ *-modŠle_tracker_palette

modŠle_fin
 trap #4
 move.b d0,(a5) 	   Border droit
 nop
 move.b d3,(a5)
 pause 12
 move.b d3,(a1) 	   Stabilisation Border droit
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


*********************************************************
*
* Ici, on peut trouver toutes les routines d'affichage
* des motifs, textes, ou images...
*
*********************************************************

affiche_raster_vertical
 movem.l motif_raster+34,d2-d7
 lea ecrans,a1
 movem.l d2-d7,152-96(a1)
 movem.l d2-d7,152-48(a1)
 movem.l d2-d7,152(a1)
 movem.l d2-d7,152+48(a1)
 movem.l d2-d7,152+96(a1)
 rts

affiche_plasma
 lea ecrans,a1
 move.l a1,a2
 lea motif_plasma+34,a0
 move #(104/4)-1,d1
.recopie_image_x
 move.l (a0),104(a1)
 move.l (a0),208(a1)
 move.l (a0),312(a1)
 move.l (a0)+,(a1)+
 dbra d1,.recopie_image_x
 bsr cr‚e_palette_plasma
 rts

cr‚e_palette_plasma
 lea palettes_plasma,a0       On g‚nere le plasma … partir de 16 palettes
 lea buffer_palettes,a6       standard... Waouhhh... !!!
 move.l a6,adresse_palette    Et en plus, ‡a marche...
 moveq #8-1,d7	       ** 16
.prepare_palette
 movem.l (a0)+,d0-d6/a1
 movem.l d0-d6/a1,(a6)
 movem.l (a0),d0-d6/a1
 movem.l d0-d6/a1,480(a6)
 movem.l d0-a6,-(sp)
 bsr execute_degrad‚
 movem.l (sp)+,d0-a6
 lea 512(a6),a6
 dbra d7,.prepare_palette
 rts

palettes_plasma
 ds.w 16
 dc.w $E78,$678,$678,$D78,$D70,$570,$570,$D70 Vert clair
 dc.w $D78,$678,$678,$E71,$771,$771,$771,$E71
 dc.w $979,$A7A,$373,$474,$C7B,$573,$572,$D79 Vert fonc‚
 dc.w $671,$D71,$C71,$471,$371,$A71,$971,$171
 dc.w $7DD,$7DD,$766,$7EE,$7EE,$777,$E77,$67E Rose
 dc.w $D7E,$C7E,$5EE,$DE6,$D66,$6DD,$EDD,$755
 dc.w $704,$70B,$703,$71B,$79B,$7A4,$734,$7A5 Orang‚
 dc.w $79D,$716,$716,$78E,$70E,$706,$70D,$70C
 dc.w $EA0,$EB0,$EC0,$750,$760,$E58,$D49,$532 Rouges
 dc.w $42A,$C92,$599,$D18,$680,$600,$610,$E90
 dc.w $C37,$547,$557,$D67,$677,$5DE,$B46,$A36 Bleu
 dc.w $19D,$005,$88D,$98D,$216,$A9E,$B9E,$427
 dc.w $EEE,$666,$DDD,$555,$44C,$BB4,$33B,$AA3 Gris
 dc.w $33B,$BB4,$444,$44C,$CC5,$55D,$DDD,$666
 ds.w 16
 even

depacke_image
 lea motif_image,a0
 lea fin_motif_image,a2
 lea ecrans+64000,a1
.recopie_image
 move (a0)+,(a1)+
 cmpa.l a2,a0
 blt.s .recopie_image
 lea ecrans+64000,a0
 bsr depack
 rts

affiche_image
 lea ecrans+64000,a0
 lea ecrans,a1
 move #64000/4-1,d0
.recopie_image
 move.l (a0)+,(a1)+
 dbra d0,.recopie_image
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
hop	  =$3a
valeur_hop=3

*
* $ffff8A3B  (----xxxx).b
*
* OP, op‚ration logique entre la source et la destination
*  0-15 -> Voir BIT-BLT
op	 =$3b
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
skew	 =$3d
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
 move #30,y_count(a5)	       Nombre de lignes de hauteur

 move #2,src_xinc(a5)		 Nombre de mots pour aller au suivant.
 move #2,src_yinc(a5)		 Nombre d'octets … sauter aprŠs chaque ligne

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
 move #2,src_xinc(a5)	    Nombre de mots pour aller au suivant.
 move #2,src_yinc(a5)	    Nombre d'octets … sauter aprŠs chaque ligne
 move #2,dst_xinc(a5)
 move #-30,dst_yinc(a5)       Si ca marche...
 move.l #$ff8240,dst_addr(a5)  Adresse de la palette...
 move.b #0,skew(a5)
 move.b #2,hop(a5)
 move.b #3,op(a5)
 move #16,x_count(a5)	    Nombre de mots de largeur, du bloc … transf‚rer
 rts


remplace_dbug
 lea buffer_g‚n‚ration,a0
 lea fin_buffer_g‚n‚ration,a1
 lea memo_remplacement,a3
 lea (adr_replay).w,a4		Adresse de base du replay
 lea memo_distorting,a5
 move.l #"DBUG",d0
 move #"",d1
 move.l #longueur_bloc,d2	Taille d'un bloc de replay
 move #"MP",d3
 move.l #"~NeX",d4
.cherche_suivant
 cmp.l (a0),d0
 bne.s .pas_remplace_dbug
 move.l a0,(a3)+
 addq.w #2,a0
.pas_remplace_dbug

 cmp.w (a0),d1
 bne.s .pas_remplace_atari
 move a4,(a0)
 add.w d2,a4
 cmpa.l #adr_replay+longueur_bloc*64,a4
 blt.s .pas_remplace_atari
 lea (adr_replay).w,a4		Adresse de base du replay
.pas_remplace_atari

 cmp.w (a0),d3
 bne.s .pas_replace_mp
 move.l a0,(a5)+
 move #$181e,(a0)	      move.b (a6)+,d4
.pas_replace_mp

 cmp.l (a0),d4
 bne.s .pas_replace_NeXT
 move.l a0,(a5)+
 move.l #$1b5e005b,(a0)+	move.b (a6)+,91(a5)
 move #$4e71,(a0)	      nop
.pas_replace_NeXT

 addq.w #2,a0
 cmpa.l a1,a0
 blt.s .cherche_suivant
 move.l #-1,(a3)+
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

efface_buffer
 lea ligne_vide+32000,a0
 moveq #0,d1
 move #(160+416+150152-32000)/8-1,d0
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

compteur_image	dc.w 0
ecran_courant	dc.l 0
taille_courante dc.w 1
bloc_stretch	dc.l 0
cx_stretch	dc.w 0
cy_stretch	dc.w 0
dur‚e_stretch	dc.w 0

lance_stretch
 bsr efface_ecran
 move #0,position_stretch
 move #1,sens_stretch
 lea palette_noire,a0
 lea palette_etoiles,a1
 trap #15
 stop #$2300
 move.l #routine_vbl_stretch,$70.w
 bsr lance_fade_on
 move dur‚e_stretch,d6
 bsr temporisation
 bsr lance_fade_off
 rts

precalcule_stretch
 move.l #ligne_vide+32000,ecran_courant
 move #14,compteur_image
 move #16,taille_courante
 lea table_motifs(pc),a4
 lea fin_trace_blocs(pc),a3
ecran_suivant
 move.l #320,d0
 move.l d0,d1
 lsl #4,d1
 divu taille_courante,d1
 sub.w d1,d0
 lsr.w d0
 move d0,cx_stretch
 move.l #200,d0
 move.l d0,d1
 lsl #4,d1
 divu taille_courante,d1
 sub.w d1,d0
 lsr.w d0
 move d0,cy_stretch
 bsr calcule_image_strech
 add.l #8000,ecran_courant
 add.w #4,taille_courante
 subq.w #1,compteur_image
 bne ecran_suivant
 rts

calcule_image_strech
 move.l bloc_stretch,a6
 moveq #0,d6
ligne_suivante
 move.b (a6)+,d2	On r‚cupŠre les 8 1ers bits.
 move.b (a6)+,d1	On r‚cupŠre les 8 bits suivants.
 cmp.b #-1,d2
 bne.s .pas_fin_image
 cmp.b #-1,d1
 bne.s .pas_fin_image
 rts			Image termin‚e, on quitte !

.pas_fin_image
 moveq #0,d0
 rept 8
 roxr.b d2
 roxl.w d0
 endr
 roxr.b d1
 roxl.w d0	    Coordonn‚e X de d‚part
*
 moveq #0,d7
 rept 7
 roxr.b d1
 roxl.w d7
 endr
 move.b (a6)+,d2     On r‚cupŠre les 8 derniers bits.
 rept 2
 roxr.b d2
 roxl.w d7	     Coordon‚e X d'arriv‚e
 endr

 moveq #0,d4
 rept 6
 roxr.b d2
 roxl.w d4		  Offset en Y
 endr
 add.w d4,d6
 move d6,d4

 lsl #4,d4
 divu taille_courante,d4
 add.w cy_stretch,d4
 lea table_40(pc),a0
 add.w d4,d4
 move.l ecran_courant,a1
 add.w 0(a0,d4.w),a1	  On met … jour les Y

 lsl #4,d0		    Pr‚cision 16
 divu taille_courante,d0      X1 divis‚ par le zoom arriŠre
 add.w cx_stretch,d0
 move d0,d1
 lsr.w #4,d0
 and.w #$f,d1
 add.w d1,d1
 move 0(a4,d1.w),d4  ; d4=motif 1

 moveq #-1,d2

 lsl #4,d7
 divu taille_courante,d7      X2 divis‚ par le zoom arriŠre.
 add.w cx_stretch,d7
 move d7,d1
 lsr.w #4,d7

 and.w #$f,d1
 add.w d1,d1
 move 32(a4,d1.w),d5 ; d5=motif 2

 sub.w d0,d7	  ; -> Nombre de blocs
 beq un_seul_bloc

 add.w d0,d0
 lea (a1,d0.w),a0  ; -> a0=adresse premier bloc sur l'‚cran dest

 or.w d4,(a0)+	   1er bloc

**
 add.w d7,d7
 neg.w d7
 jmp 2(a3,d7.w)
yurk
 rept 20
 move d2,(a0)+	; 8   d16(an) -> 12
 endr
fin_trace_blocs
**
 or.w d5,(a0)
end
*********************
 bra ligne_suivante

un_seul_bloc
 add.w d0,d0
 and.w d5,d4	  ; d4 -> motif … afficher
 or.w d4,(a1,d0.w)
 bra ligne_suivante

remplissage_2

table_motifs
 dc.w %1111111111111111
 dc.w %0111111111111111
 dc.w %0011111111111111
 dc.w %0001111111111111
 dc.w %0000111111111111
 dc.w %0000011111111111
 dc.w %0000001111111111
 dc.w %0000000111111111
 dc.w %0000000011111111
 dc.w %0000000001111111
 dc.w %0000000000111111
 dc.w %0000000000011111
 dc.w %0000000000001111
 dc.w %0000000000000111
 dc.w %0000000000000011
 dc.w %0000000000000001

 dc.w %1000000000000000
 dc.w %1100000000000000
 dc.w %1110000000000000
 dc.w %1111000000000000
 dc.w %1111100000000000
 dc.w %1111110000000000
 dc.w %1111111000000000
 dc.w %1111111100000000
 dc.w %1111111110000000
 dc.w %1111111111000000
 dc.w %1111111111100000
 dc.w %1111111111110000
 dc.w %1111111111111000
 dc.w %1111111111111100
 dc.w %1111111111111110
 dc.w %1111111111111111

table_40
var set 0
 rept 200
 dc.w var
var set var+40
 endr

send_kbd
 lea $fffffc00.w,a0
.vide?
 btst.b #0,(a0)
 beq.s .vide
 move.b 2(a0),d1
 bra.s .vide?
.vide
 stop #$2300
.wait
 btst.b #1,(a0)
 beq.s .wait
 move #537,d1
.wait_2
 nop
 dbra d1,.wait_2
 move.b d0,2(a0)
 stop #$2300
 rts

modifie_ajouts_ligne
 lea memo_remplacement,a0
.adresse_suivante
 move.l (a0)+,a1
 cmp.l #-1,a1
 beq .fin
 move.l d0,(a1)
 bra.s .adresse_suivante
.fin
 rts

modifie_ajouts_ligne_scroll
 lea memo_remplacement,a0
 moveq #1,d0
.adresse_suivante
 move.l (a0)+,a1
 cmp.l #-1,a1
 beq .fin
 move.l #largeur_ligne,(a1)
 addq.w #1,d0
 cmp.w #19,d0
 bne.s .adresse_suivante
 move.l #-largeur_ligne*17,(a1)
 moveq #1,d0
 bra .adresse_suivante
.fin
 rts

modifie_ajouts_ligne_moving
 lea memo_remplacement,a0
 moveq #1,d0
.adresse_suivante
 move.l (a0)+,a1
 cmp.l #-1,a1
 beq .fin
 move.l #264,(a1)
 addq.w #1,d0
 cmp.w #46,d0
 bne.s .adresse_suivante
 move.l #-264*44,(a1)
 moveq #1,d0
 bra .adresse_suivante
.fin
 rts

disting_multiple
 lea memo_distorting,a0
 move #258-1,d0
.remplace_suivant
 move.l (a0)+,a1
 move #$181e,(a1)	     -> move.b (a6)+,d4
 move.l (a0)+,a1
 move.l #$1b5e005b,(a1)+     -> move.b (a6)+,91(a5)
 move #$4e71,(a1)
 dbra d0,.remplace_suivant
 rts

disting_simple
 lea memo_distorting,a0
 move #258-1,d0
.remplace_suivant
 move.l (a0)+,a1
 move #$1816,(a1)	     -> move.b (a6),d4
 move.l (a0)+,a1
 move.l #$1b6e0001,(a1)+     -> move.b 1(a6),91(a5)
 move #$005b,(a1)	     ->      (suite)
 dbra d0,.remplace_suivant
 rts

;
; 500 lettres au maximum, donc une ligne fait 8000 octets
;
prepare_scrolling
 lea fonte_conv,a0
 lea fonte_32,a1
 lea ecrans,a2
 lea scrolling_intro,a3
 moveq #0,d5
 move.l #largeur_ligne,d7
.charge_lettre_suivante
 moveq #0,d1
 move.b (a3)+,d1
 bmi .fin_scrolling
 move.b (a0,d1.w),d1
 lsl.l #8,d1
 lea (a1,d1.w),a4
 move.l a2,a5
 move.l a2,a6
 add.l #largeur_ligne*18,a6
 moveq #16-1,d6
.recop
 movem.l (a4)+,d0-d3
 movem.l d0-d3,(a5)
 add.l d7,a5
 movem.l d0-d3,(a6)
 add.l d7,a6
 dbra d6,.recop
 movem.l fonte_32+256*32,d0-d3
 movem.l d0-d1,(a5)
 movem.l d0-d1,(a6)
 movem.l d0-d1,8(a5)
 movem.l d0-d1,8(a6)
 add.l d7,a5
 add.l d7,a6
 movem.l d0-d1,(a5)
 movem.l d0-d1,(a6)
 movem.l d0-d1,8(a5)
 movem.l d0-d1,8(a6)
 lea 16(a2),a2
 bra .charge_lettre_suivante
.fin_scrolling
 rts

prepare_moving
 lea motif_backgrnd,a0
 lea ecrans,a1
 lea 11880(a1),a2
 moveq #45-1,d1
.ligne_suivante
 move #88/4-1,d0
.mot_suivant
 move.l (a0),176(a1)
 move.l (a0),88(a1)
 move.l (a0),(a1)+
 move.l (a0),176(a2)
 move.l (a0),88(a2)
 move.l (a0)+,(a2)+
 dbra d0,.mot_suivant
 lea 176(a1),a1
 lea 176(a2),a2
 dbra d1,.ligne_suivante
 rts

prepare_palette_motif
 lea buffer_palettes,a1
 move.l a1,adresse_palette
 lea palette_motif_texte,a2
 moveq #9,d5
 move #2-1,d6
.recop_bloc
 lea motif_distort,a0
 move #64-1,d7
.recop_palette
 movem.l (a2),d0-d3
 movem.l d0-d3,18(a1)
 subq.w #1,d5
 bne.s .pas_nouvelle
 moveq #9,d5
 lea 14(a2),a2
.pas_nouvelle
 movem.l (a0)+,d0-d3
 movem.l d0-d3,2(a1)
 lea 32(a1),a1
 dbra d7,.recop_palette
 dbra d6,.recop_bloc
 rts

palette_motif_texte
 dc $9AA,$ABB,$B44,$C55,$D66,$EEE,$FFF
 dc $1AA,$2BB,$344,$455,$566,$6EE,$7FF
 dc $8AA,$9BB,$A44,$B55,$C66,$DEE,$EFF
 dc $8A2,$9B3,$A4B,$B5C,$C6D,$DE6,$EF7
 dc $822,$933,$ABB,$BCC,$CDD,$D66,$E77
 dc $892,$9A3,$A3B,$B4C,$C5D,$DD6,$EE7
 dc $812,$923,$AAB,$BBC,$CCD,$D56,$E67
 dc $882,$993,$A2B,$B3C,$C4D,$DC6,$ED7
 dc $189,$29A,$323,$434,$545,$6CD,$7DE
 dc $989,$A9A,$B23,$C34,$D45,$ECD,$FDE
 dc $919,$A2A,$BA3,$CB4,$DC5,$E5D,$F6E
 dc $999,$AAA,$B33,$C44,$D55,$EDD,$FEE
 dc $992,$AA3,$B3B,$C4C,$D5D,$ED6,$FE7
 dc $199,$2AA,$333,$444,$555,$6DD,$7EE
 dc $891,$9A2,$A3A,$B4B,$C5C,$DD5,$EE6
 dc $098,$1A9,$232,$343,$454,$5DC,$6ED
 dc $010,$121,$239,$ABA,$BCB,$CD4,$56C




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
 lea palette_fondue,a6	       Cette routine cr‚e un d‚grad‚ … partir de
 movem.l (a0),d0-d7	       deux palettes pass‚es en A0 et A1
 movem.l d0-d7,(a6)	       en couleur STE qui conviennent...
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

prepare_palette_raster
 lea palette_noire,a0
 lea palette_raster,a1
 trap #15
 bsr prepare_palette_globale

 lea palette_raster,a0
 lea raster_bleu,a1
 trap #15

rst_bleu_1
 lea palette_fondue,a0
 lea buffer_palettes+32*16,a1
 moveq #16-1,d0
.recop_palette
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette

rst_bleu
 lea raster_bleu,a0
 moveq #16-1,d0
.recop_palette
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette

 moveq #16-1,d0
.recop_palette_2
 lea -32(a0),a0
 movem.l (a0),d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette_2

rst_vert
 lea raster_vert,a0
 moveq #16-1,d0
.recop_palette
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette

 moveq #16-1,d0
.recop_palette_2
 lea -32(a0),a0
 movem.l (a0),d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette_2

 pea (a1)
 lea raster_vert,a0
 lea palette_raster,a1
 trap #15
 move.l (sp)+,a1

rst_vert_2
 lea palette_fondue,a0
 moveq #16-1,d0
.recop_palette
 movem.l (a0)+,d1-d7/a2
 movem.l d1-d7/a2,(a1)
 lea 32(a1),a1
 dbra d0,.recop_palette

 rts

raster_bleu incbin bleu.pal
raster_vert incbin vert.pal

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
 lea offsets,a2 	  Buffers pour les offsets
 lea table_to_stf,a3	  Table de conversion
 lea x_source,a4	  Palette source d‚compos‚e en (R.l)+(V.l)+(B.l)
 moveq #16-1,d7
offset_couleur_suivante
 move (a0)+,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5	   Bleu de d‚part
 swap d5
 move.l d5,(a4)+
 move (a1)+,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6	   Bleu d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6		   Offset bleu
 move.l d6,(a2)+

 lsr #4,d0
 move d0,d2
 and.w #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5	   Vert de d‚part
 swap d5
 move.l d5,(a4)+
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6	   Vert d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6		   Offset vert
 move.l d6,(a2)+

 lsr #4,d0
 move d0,d2
 and #%1111,d2
 moveq #0,d5
 move.b (a3,d2.w),d5	   Rouge de d‚part
 swap d5
 move.l d5,(a4)+
 lsr #4,d1
 move d1,d2
 and #%1111,d2
 moveq #0,d6
 move.b (a3,d2.w),d6	   Rouge d'arriv‚e
 swap d6
 sub.l d5,d6
 asr.l #4,d6		   Offset rouge
 move.l d6,(a2)+

 dbra d7,offset_couleur_suivante

;#######################
; Puis le fading lui meme
;#######################

calcule_fading_palette
 lea x_source,a0
 move.l a6,a1	      Palette source
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

lance_message
 stop #$2300
 move.l #routine_vbl_musique,$70.w
 bsr efface_tout_buffer
 lea palette_noire,a0
 lea palette_8x8_brun,a1
 trap #15
 move.b #1,flag_fin_message
 stop #$2300
 move.l #routine_vbl_message,$70.w
 rts

attend_fin_message
 tst.b flag_fin_message
 bne.s attend_fin_message
 rts

; Flag fin message:
; 0 -> arret‚
; 1 -> ‚crit le message
; 2 -> fondu on
; 3 -> attente
; 4 -> fondu off
dur‚e_temporisation  dc.b 0
flag_fin_message     dc.b 0

 even

routine_vbl_message
 movem.l d0-a6,-(sp)

 bsr execute_fading

 cmp.b #1,flag_fin_message
 bgt .gestion_message

 lea convert_8x8_brun,a0
 lea fonte_8x8_brun,a1
 lea ecrans+160*93,a2
 move.l adresse_message,a3
 moveq #0,d6
 move.b (a3)+,dur‚e_temporisation	       Temporisation
 move.l #$00070001,d7
.charge_lettre_suivante
 moveq #0,d1
 move.b (a3)+,d1
 beq .fin_affichage
 move.b (a0,d1.w),d1
 mulu #28,d1
 lea (a1,d1.w),a4
var set 0
 rept 14
 move.b (a4)+,var+0(a2)
 move.b (a4)+,var+2(a2)
var set var+160
 endr
 add.w d7,a2
 swap d7
 bra .charge_lettre_suivante
.fin_affichage
 move.b #2,flag_fin_message
 move.l a3,adresse_message
 move.b #1,fading_flag
 cmp.b #-1,(a3)
 bne.s .message_pas_fini
 move.l #routine_vbl_musique,$70.w
 addq.l #1,adresse_message
 sf flag_fin_message
 sf fading_flag
.message_pas_fini

.fin_gestion_message

;
; On affiche le sprite (24x16)
;
; .l masque
; .w p1
; .w p2
; .l masque
; .w p1
; .w p2
 bsr aff_sprite
 bsr rejoue_zik

 movem.l (sp)+,d0-a6
 rte

.gestion_message
 cmp.b #3,flag_fin_message
 beq.s .temporisation
 bmi.s .fade_on
.fade_off
 tst.b fading_flag
 bne .fin_gestion_message
 move.b #1,flag_fin_message
 bra .fin_gestion_message

.fade_on
 tst.b fading_flag
 bne .fin_gestion_message
 move.b #3,flag_fin_message
 bra .fin_gestion_message

.temporisation
 subq.b #1,dur‚e_temporisation
 bne .fin_gestion_message
 move.b #4,flag_fin_message
 move.b #-1,fading_flag
 bra .fin_gestion_message

temporisation
 stop #$2300
 dbra d6,temporisation
 rts

lance_fade_on
 move.b #1,fading_flag
 bsr wait_fin_fade
 rts

lance_fade_off
 move.b #-1,fading_flag
 bsr wait_fin_fade
 stop #$2300
 move.l #routine_vbl_musique,$70.w
 rts

wait_fin_fade
 tst.b fading_flag
 bne.s wait_fin_fade
 rts


aff_sprite
 lea informations_sprites(pc),a6      On commence par effacer l'ancienne
 moveq #0,d0
 moveq #nb_sprites-1,d7
.efface_sprites
 move.l (a6)+,a0
var set 0
 rept 16
 move.l d0,var(a0)
 move.l d0,var+8(a0)
var set var+160
 endr
 dbra d7,.efface_sprites


 lea ecrans+160*100+84,a2  Adresse de base pour l'affichage
 lea sprite_boule,a3	   Adresse de base du buffer de sprites
 lea table_160,a4
 lea table_sinus+90*2,a5   On pointe sur les COSINUS (Plus pratique)
 lea informations_sprites(pc),a6
 move.l angle_a,d4	   Angle a+c
 move.l angle_b,d5	   Angle b+d
 moveq #14,d6		   D‚callages pour les angles
 moveq #nb_sprites-1,d7
affiche_sprite
 move.l a2,a0
 move.l a3,a1

 move (a5,d4.w),d2	 d2=COS(c)
 sub #12,d4
 swap d4
 move (a5,d4.w),d3	 d3=COS(a)
 sub #12,d4
 swap d4
 move #143,d0		   Rayon en X
 muls d2,d0		   Multiplie par le rayon
 asr.l d6,d0		   On divise par 16384
 muls d3,d0		   Multiplie par le rayon
 asr.l d6,d0		   On divise par 16384

 move (a5,d5.w),d2	 d2=COS(c)
 sub #12,d5
 swap d5
 move (a5,d5.w),d3	 d3=COS(a)
 sub #12,d5
 swap d5
 moveq #70,d1		   Rayon en Y
 muls d2,d1		   Multiplie par le rayon
 asr.l d6,d1		   On divise par 16384
 muls d3,d1		   Multiplie par le rayon
 asr.l d6,d1		   On divise par 16384

 add d1,d1
 move (a4,d1.w),d1	   On multiplie par 160
 move d0,d2
 asr d2 		   Multiple de 8
 and #$ffff-7,d2
 add d2,d1		   d1 -> adresse ‚cran
 add d1,a0
 move.l a0,(a6)+	   On sauve la nouvelle position … l'‚cran.

 and #15,d0
 lsl #8,d0    d0 -> multiple sprite
 add d0,a1

var set 0
 rept 16
 move.l var(a0),d0	   Enfin, l'affichage … proprement parler
 move.l var+8(a0),d1
 and.l (a1)+,d0
 or.l (a1)+,d0
 and.l (a1)+,d1
 or.l (a1)+,d1
 move.l d0,var(a0)
 move.l d1,var+8(a0)
var set var+160
 endr
 dbra d7,affiche_sprite

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
 rts

nb_sprites=15

angle_a dc.w 0
angle_c dc.w 0
angle_b dc.w 0
angle_d dc.w 0

informations_sprites
 rept nb_sprites
 dc.l ecrans
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

********************* Depacker Atomic **********************

DEC_MARGE:	equ	$10	;min=0 , max=126 (pair!)
taille	dc.l 0
depack
	movem.l d0-a6,-(a7)
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
	movem.l (a7)+,d0-a6
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

 include module_s.s

 SECTION DATA

fonte_8x8_brun	  incbin 8x8_brun.fnt
convert_8x8_brun  incbin 8x8_brun.cvt
fonte_32	  incbin  32x16.fnt
fonte_conv	  incbin  convert.tbl

motif_presente	  incbin illusion.cut
motif_image	  incbin    image.pak
fin_motif_image
motif_plasma	  incbin   plasma.dat
motif_raster	  incbin   raster.dat
motif_backgrnd	  incbin backgrnd.gfx
motif_distort	  incbin rockfont.mtf

dist_image	  incbin    image.tbl
dist_texte	  incbin    texte.tbl
 dc.w -1

table_precalc	  incbin psdodeci.tbl
		  incbin    sinus.tbl
table_sinus	  incbin    sinus.tbl
		  incbin    sinus.tbl
		  incbin    sinus.tbl
table_backgrnd	  incbin backgrnd.tbl
table_rockfont	  incbin rockfont.tbl

vas_vien	  incbin vas_vien.tbl

palette_image	  incbin    image.pal
palette_raster	  incbin   raster.pal
palette_presente  incbin illusion.pal
palette_etoiles   incbin  etoiles.pal
palette_8x8_brun  incbin 8x8_brun.pal
palette_font	  incbin rockfont.pal
palette_moving	  incbin backgrnd.pal
palette_next	  incbin     next.pal

stretch_go	  incbin       go.pkl
stretch_no	  incbin       no.pkl
stretch_yes	  incbin      yes.pkl
stretch_end	  incbin  the_end.pkl
stretch_next	  incbin copyrigh.pkl

sprite_boule	  incbin     ball.spr
tramage 	  incbin  tramage.ani

motif_bares	  incbin    bares.ani
motif_next	  incbin     next.dat

modfile 	  incbin	illusion.low
fmode even

table_transpose   incbin tb25118d.tbl

tfreq_ste
var set 0
 rept 37
 dc.l table_transpose+var
var set var+502
 endr
ftfreq

;
; 1/2 +0
; 3/4 +2
; 5/6 +4
etoiles
 dc.l 160*20
 dc.w 78,1
 dc.l 160*30+2
 dc.w 10,4
 dc.l 160*40+2
 dc.w 210,3
 dc.l 160*50
 dc.w 310,2
 dc.l 160*60+4
 dc.w 31,5
 dc.l 160*70+2
 dc.w 225,4
 dc.l 160*80
 dc.w 128,2
 dc.l 160*90
 dc.w 170,1
 dc.l 160*100+2
 dc.w 315,3
 dc.l 160*110
 dc.w 30,2
 dc.l 160*120+2
 dc.w 60,3
 dc.l 160*130+4
 dc.w 10,5
 dc.l 160*140+2
 dc.w 210,3
 dc.l 160*150
 dc.w 66,1
 dc.l 160*160
 dc.w 310,2
 dc.l 160*170+2
 dc.w 50,4
 dc.l 160*180+2
 dc.w 55,3
 dc.l 160*190
 dc.w 10,2
 dc.l 160*200+2
 dc.w 70,4
 dc.l 160*25
 dc.w 310,1

 dc.l 160*20
 dc.w 78,1
 dc.l 160*30+2
 dc.w 10,4
 dc.l 160*40+2
 dc.w 210,3
 dc.l 160*50
 dc.w 310,2
 dc.l 160*60+4
 dc.w 31,5
 dc.l 160*70+2
 dc.w 225,4
 dc.l 160*80
 dc.w 128,2
 dc.l 160*90
 dc.w 170,1
 dc.l 160*100+2
 dc.w 315,3
 dc.l 160*110
 dc.w 30,2
 dc.l 160*120+2
 dc.w 60,3
 dc.l 160*130+4
 dc.w 10,5
 dc.l 160*140+2
 dc.w 210,3
 dc.l 160*150
 dc.w 66,1
 dc.l 160*160
 dc.w 310,2
 dc.l 160*170+2
 dc.w 50,4
 dc.l 160*180+2
 dc.w 55,3
 dc.l 160*190
 dc.w 10,2
 dc.l 160*200+2
 dc.w 70,4
 dc.l 160*25
 dc.w 310,1

scrolling_intro
 dc.b "                 "
 dc.b "waouhhhh !!!...     the ste is really a great machine for "
 dc.b "doing these fucking mega multi bouncing scrollers !!!    "
 dc.b "let s wrap now, because this text only is a little part "
 dc.b "of the whole demo screen..."
fin_scrolling=(*-scrolling_intro)*16
 dc.b "                     "
 dc.b -1
 even

adresse_palette  dc.l buffer_palettes
adresse_message  dc.l liste_messages

liste_messages
 dc.b 71,"   At the beginning was the STF...      ",0  Pr‚sentation
 dc.b 71,"     ... and then came the STE.         ",0
 dc.b 71,"       Someone said about it :          ",0
 dc.b 71,"     ""too little, too late"".          ",0
 dc.b 71,"  But nobody really tried to use it...  ",0
 dc.b 71,"       ...at its maximum potential.     ",0
 dc.b 71,"   So, this screen can be seen as...    ",0
 dc.b 71,"    ...my personal encouragements...    ",0
 dc.b 71,"     ...to atari corp for still...      ",0
 dc.b 71,"     ...making fabulous computers.      ",0
 dc.b 71,"            One last word...            ",0
 dc.b 71,"     this screen doesn't exist,...      ",0
 dc.b 71,"         it is just an...               ",0
 dc.b 0,0,-1						ILLUSION LOGO
 dc.b 85,"        Ok, let's go now, with...       ",0
 dc.b 85,"  Parallax Distorter 2, the come-back   ",0
 dc.b 85,"               Ready ???                ",0
 dc.b 0,0,-1						GO!
 dc.b 85,"      I just have a question :          ",0
 dc.b 85,"     Have you been impressed ???        ",0
 dc.b 85,"              What ???                  ",0
 dc.b 0,0,-1						NO!
 dc.b 85,"  Ok,ok... That's only a distorter...   ",0
 dc.b 85," without any parallax. But there is...  ",0
 dc.b 85,"  a real 12.5 Khz stereo soundtracked   ",0
 dc.b 85,"   music, with full volume control.     ",0
 dc.b 85," Perhaps do you prefer a real time...   ",0
 dc.b 85,"fullscreen distorting picture in four...",0
 dc.b 85,"           bitplanes ???                ",0
 dc.b 0,0,-1						Image distort
 dc.b 85,"   This superb picture - I think -...   ",0
 dc.b 85,"        was drawn by Killer D...        ",0
 dc.b 85," the only coding'n gfx girl on Atari... ",0
 dc.b 85,"             in France !                ",0
 dc.b 85,"  Hey, what about a cheaty plasma ???   ",0
 dc.b 0,0,-1						YES!
 dc.b 90,"I thank you very much, coz it was a very",0
 dc.b 90,"hard work to do these fuckin' colors... ",0
 dc.b 90,"  This time, it's a fullscreen plasma.  ",0
 dc.b 90,"  And it uses a very special method...  ",0
 dc.b 90,"    ...called the 1 pixel plasma !!!    ",0
 dc.b 90,"        - Who says Amiga ???? -         ",0
 dc.b 0,0,-1						Plasma 1+2
 dc.b 85,"  It was really a cheating plasma !!!   ",0
 dc.b 85,"    and only STE made it possible...    ",0
 dc.b 85,"         But I still have many          ",0
 dc.b 85," free processor time in -all- the parts ",0
 dc.b 85,"          of this demo !!!              ",0
 dc.b 85,"      And now, vertical rasters !       ",0
 dc.b 85,"    Always in fullscreen. - normal -    ",0
 dc.b 0,0,-1						Rasters 1
 dc.b 85,"     Ok, Ok ! Let's swing them on !     ",0
 dc.b 0,0,-1						Rasters 2
 dc.b 85,"       Oh, I forget the credits...      ",0
 dc.b 85,"        I must repair this now !        ",0
 dc.b 85,"     Who did what in this screen ???    ",0
 dc.b 0,0,-1						Credits
 dc.b 85,"Bah, my previous effect wasn't original.",0
 dc.b 85,"  So, I must improve it a little bit.   ",0
 dc.b 0,0,-1						Rasters ki tournent
 dc.b 85,"           Oh ! Ah ! Hum !...           ",0
 dc.b 85,"      ... Where is the trick ???        ",0
 dc.b 85,"As I've still more processor time left, ",0
 dc.b 85,"        I can add many colors :         ",0
 dc.b 0,0,-1						Rasters color‚s
 dc.b 85,"   That's the end of the rastermania !  ",0
 dc.b 85,"  The incredible, amazing, fabulous...  ",0
 dc.b 85,"    megagreat, -...-, and so on...      ",0
 dc.b 85,"   not-ham-rotating-crossed-rasters     ",0
 dc.b 0,0,-1						NOT-HAM-...
 dc.b 85,"If you're not too bored with this screen",0
 dc.b 85,"I now explain you what is special in... ",0
 dc.b 0,0,-1						STE...
 dc.b 85,"   I'm now totally bored with rasters.  ",0
 dc.b 85,"     I prefer a moving background !     ",0
 dc.b 0,0,-1						Moving Back
 dc.b 85," Are you waiting for the greetings ???  ",0
 dc.b 85,"          Here they are...!!!           ",0
 dc.b 0,0,-1						Greetings
 dc.b 85," We really hope you liked this little...",0
 dc.b 85,"    demonstration. But never forget:    ",0
 dc.b 85,"      'Always break the limits...'      ",0
 dc.b 85,"         and long live atari.           ",0
 dc.b 85," Maybe the Falcon 030 will be a success.",0
 dc.b 85,"            See you soon.               ",0
 dc.b 0,0,-1						The End
 dc.b 200,"           - ½ 1992 NEXT -              ",0
 dc.b 200,"-All rights reserved for all countries.-",0
 dc.b 150,"                                        ",0
 dc.b 200,"         The Show is now over           ",0
 dc.b 0,0,-1						½ 1992 NeXT
 even



 even

 SECTION BSS
mit
debut_bss

 ds.w 1 		 !!! Encore un ... de Bug … la con... Sale betes !
sauve_palette	 ds.w 16

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
ligne_vide	  ds.b 160	   Encore une grosse ruse pour pas etre
ecrans		  ds.l 416/4	   gŠn‚ par la ligne de synchronisation !!! (Note en passant: Ca merde totalement !) (Re-note: En fait, si ‡a marche !!!)
buffer_calcul	  ds.l 150152/4    On est pas … 150 Ko prŠs !!!
fin_buffer_calcul
memo_remplacement ds.l 274	   Stockage des ®Dbug¯...
memo_distorting   ds.l 258*2	   Stockage des (a6)+... ®MP¯ & ®NeXT¯
buffer_g‚n‚ration ds.b t_g‚n‚ration Ici, on cr‚‚ du code (Surdimensionn‚ !)
fin_buffer_g‚n‚ration

		  ds.l 320/4
buffer_palettes   ds.l 4128/4	   La palette d'une image est l… !
		  ds.l 320/4

lateral_adr	 ds.l 1
lateral_ptr	 ds.l 1
vas_vien_ptr	 ds.l 1

compteur_couleur ds.w 1       de fading et autres changements de
compteur_phase	 ds.w 1       couleur.
x_source	 ds.l 16*3
offsets 	 ds.l 16*3
palette_fondue	 ds.l 512/4
;
; Ici, toutes les variables pour le soundtrack
;
info_voie_1 ds.b lenght_pack
 even
info_voie_2 ds.b lenght_pack
 even
info_voie_3 ds.b lenght_pack
 even
info_voie_4 ds.b lenght_pack
 even

offset_sur_position_pattern ds.w 1
offset_ds_pattern	    ds.w 1
compteur_vbl		    ds.w 1

adr_buffer_debut_sample ds.l 31
buffer_fin_sample	ds.l 31

mt_register		  ds.l 1
position_pattern_courante ds.l 1
mt_debpat		  ds.l 1
mt_adrsave		  ds.l 1

vitesse 	      ds.w 1
adr_positions_pattern ds.l 1
adr_positions_pattern_courante ds.l 1
adr_contenu_pattern ds.l 1
buffer1 	    ds.l 1
buffer2 	    ds.l 1
adr_car 	    ds.l 1
adr_ecr 	    ds.l 1
sample_nul	    ds.w fin_ech
registre	    ds.l 9
nb_in		    ds.w 1
nb_pat		    ds.w 1
nb_pos		    ds.w 1
pos_restart	    ds.w 1
info_instruments    ds.l 1
sym		    ds.w 1

fuck		    ds.l 1    juste un tempo

buffer
 ds.w (nb_oct_ste+1)*2
fin
;
;
;

sauve_ssp     ds.l 1
sauve_usp     ds.l 1
sauve_70      ds.l 1
sauve_systeme ds.b 256*65
 even
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





