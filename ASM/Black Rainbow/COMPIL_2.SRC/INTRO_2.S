;
; ***************************************************************
;
;      THE 'A-LOT-OF-RASTERS-AND-BOUNCING-CIRCLE-SCROLL INTRO'
;                     (C) -FANTOMAS- 07/1992
;
; ***************************************************************
;

           opt o+

; 
; ---------------------------------------------------------------
; Initialisations
; ---------------------------------------------------------------
; 

;
; --- Superviseur ---
;

           clr.l -(sp)
           move.w #$20,-(sp)           ; GEMDOS(32) SUPER
           trap #1
           addq.l #6,sp
           move.l d0,oldssp

;
; --- Clavier ---
;

           move.b $484.w,key
           clr.b $484.w

;
; --- Souris OFF ---
;
 
           dc.w $a00a
           move.b #$12,$fffffc02.w

;
; --- Sauve palette ---
;

           move.l #$ffff8240,a0
           lea oldpal,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

;
; --- Nouvelle palette ---
;

           pea plasma+2
           move.w #6,-(sp)             ; XBIOS(6) SETPALETTE
           trap #14
           addq.l #6,sp
            
;
; --- Sauve resolution ---
;

           move.w #4,-(sp)             ; XBIOS(4) GETREZ
           trap #14
           addq.l #2,sp 
           move.w d0,oldrez

;
; --- Sauve adresse ecran ---
;

           move.w #2,-(sp)             ; XBIOS(2) PHYBASE
           trap #14
           addq.l #2,sp
           move.l d0,oldscreen

;
; --- Nouveaux ecrans --- 
;

           move.l #$70000,screen1      ; #$60000 pour un 520
           move.l #$79600+1280,screen2 ; #$69600+1280 pour un 520

;
; --- Change resolution et ecrans ---
;

           clr.w -(sp)                 ; Basse resolution
           move.l screen1,-(sp)        ; Logic = ecran1
           move.l screen2,-(sp)        ; Physic = ecran2
           move.w #5,-(sp)             ; XBIOS(5) SETSCREEN
           trap #14
           add.l #12,sp

;
; --- Efface ecrans ---
;

           move.l screen1,a0
           move.l screen2,a1
           move.l #(248*40)-1,d0       ; 248 lignes 
red_oct    clr.l (a0)+
           clr.l (a1)+
           dbra d0,red_oct

;
; --- Fond de plan ---
;

           lea plasma+34,a2
           move.l screen1,a0
           move.l screen2,a1
           move.w #7999,d0
titi       move.l (a2),(a0)+
           move.l (a2)+,(a1)+
           dbra d0,titi

;
; --- Logo 'BLACK RAINBOW' ---
;

           lea logo,a0
           move.l screen1,a1
           move.l screen2,a2
           add.l #200*160,a1
           add.l #200*160,a2
           move.w #(34*40)-1,d0
encore     move.l (a0),(a1)+
           move.l (a0)+,(a2)+
           dbf d0,encore

;
; --- Musique ---
;

          moveq #1,d0
          bsr music
           
;
; ---------------------------------------------------------------
; Initialisations diverses
; ---------------------------------------------------------------
;

;
; --- Pointeur texte scroll vertical ---
;

           move.l #vtext,vtxt_ptr

;
; --- Pointeur texte bigscroll ---
;

           move.l #big_scr,adr_big


;
; --- Pointeurs deplacement cercle ---
;

           move.l #script-12,script_ptr
           move.l #wave_0,wave_ptr 
           move.l #wave_0,wave_deb
           move.l #wave_0+4,wave_end
           move.l #2600,anim

;
; --- Tables effacement des caracteres (sprites 16*15 1 plan) ---
;

           move.l #eff_tab1,eff_1
           move.l #eff_tab2,eff_2
           move.l screen1,a0
           move.l eff_1,a1
           move.l eff_2,a2
           move.w #15,d0
eff_init   move.l a0,(a1)+
           move.l a0,(a2)+
           dbra d0,eff_init
     
;
; --- Texte du circle scroll ---
;

           move.l #txt,txt_ptr
           move.l #coor,coor_ptr

;
; --- Rasters ---
;

           move.l #rasters2,tut_adr
           move.l #oh_baby,droopy
           move.l #the_mov,fantomas

;
; --- Timers & VBL ---
;

           move.b $fffa07,save_iera
           move.b $fffa09,save_ierb
           move.b $fffa13,save_imra
           move.b $fffa11,savea11
           move.b $fffa17,save_vect
           move.l $70.w,save_vbl
           move.l $120.w,save_hbl
           move.l $118.w,save_118

           and.b #0,$fffa07
           and.b #$40,$fffa09
           bclr #3,$fffa17             ; Automatic end of interrupt
           or.b #1,$fffa07
           or.b #1,$fffa13
           move.l #vbl,$70.w                      
           move.l #newkey,$118.w

;
; ---------------------------------------------------------------
; Boucle principale 
; ---------------------------------------------------------------
;

loop       cmp.b #$39,$ffffc02         ; Appui sur [SPACE] ?
           bne.s loop                  ; Non, on continue ...

; 
; ---------------------------------------------------------------
; Fin du programme
; ---------------------------------------------------------------
; 


;
; --- Restore timers ---
;

           clr.b $ffffa1b
           move.b save_iera,$ffffa07
           move.b save_ierb,$ffffa09
           move.b save_imra,$ffffa13
           move.b savea11,$fffa11
           move.b save_vect,$ffffa17
           move.l save_vbl,$70.w
           move.l save_hbl,$120.w
           move.l save_118,$118.w
           
;
; --- Chip sonore ---
;

           move.b #8,$ff8800           ; On coupe les 3 canaux
           move.b #0,$ff8802
           move.b #9,$ff8800
           move.b #0,$ff8802
           move.b #$a,$ff8800
           move.b #0,$ff8802

;
; --- Ancienne resolution et ecrans ---
;
        
           move.w oldrez,-(sp)          
           move.l oldscreen,-(sp)
           move.l oldscreen,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

;
; --- Ancienne palette ---
;
          
           lea oldpal,a0
           move.l #$ffff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

;
; --- Souris ON ---
;
 
           move.b #8,$fffffc02.w
           dc.w $a009

;
; --- Retablit le clavier ---
;

           move.b key,$484.w

;
; --- Retour en mode USER ---
;

           move.l oldssp,-(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp

;
; --- Retour au DOS ---
;

           clr.w -(sp)                 ; GEMDOS(0) PTERM
           trap #1


; 
; ---------------------------------------------------------------
; Ici commence le programme ...
; ---------------------------------------------------------------
; 

vbl        move.w #$777,$ff8254
           move.w #$605,$ff825a
           clr.w cmptr
           clr.b $ffffa1b
           move.b #1,$ffffa21
           move.b #8,$ffffa1b
        
; ----------------
; Restaure le fond
; ----------------

           lea the_fond,a0
           lea fond,a1
i          set 0
           rept 10
           movem.l (a0)+,d0-d7/a2/a6
           movem.l d0-d7/a2/a6,i(a1)
i          set i+40
           endr

; ---------------------------------------------------------------
; The barre
; ---------------------------------------------------------------

;
; --- Calcul adresse ---
;

           move.l fantomas,a0
           lea 4(a0),a0
           cmp.l #ah_yeah,a0
           bne.s pas_fant
           lea the_mov,a0
pas_fant   move.l a0,fantomas

;
; --- Affichage ---
;

           lea the_bar,a1
           movem.l (a1)+,d0-d7
i          set 0
           rept 8
           move.l i(a0),a2
           movem.l d0-d7,(a2)
i          set i+20
           endr

;
; ---------------------------------------------------------------
; Rasters 1
; ---------------------------------------------------------------
;

           move.l droopy,a0
           lea -2(a0),a0
           cmp.l #rasters,a0
           bne.s pas_droop
           lea oh_baby,a0
pas_droop  move.l a0,droopy


; ---------------------------------------------------------------
; Rasters 2
; ---------------------------------------------------------------

           move.l tut_adr,a0
           lea 2(a0),a0
           cmp.l #shabada,a0
           bne.s pas_tut
           lea rasters2,a0
pas_tut    move.l a0,tut_adr

; ----------------
; Adresses rasters
; ----------------

           move.l droopy,a3
           move.l tut_adr,a4
           lea fond,a5

; ------------
; Init rasters
; ------------

           clr.w conte
           move.l #hbl1,$120.w
           move.b #8,$ffffa1b
         
; 
; ---------------------------------------------------------------
; Musique & vumetres
; ---------------------------------------------------------------
; 

;
; --- Joue music ---
;

; On sauve les registres a3/a4/a5 sinon c'est le bordel avec les
; rasters (ils ne sont pas non plus utilises dans le reste de la  
; demo ...)
 
           movem.l a3-a5,-(sp)
           bsr music+6
           movem.l (sp)+,a3-a5

; 
; --- Vumetres ---
;

           lea $ff8800,a0

           move.l screen1,a1
           add.l #(230*160)+22,a1
           lea (a1),a2
                     
i          set 0
           rept 16
           clr.w i(a1)
i          set i-160
           endr
           
           moveq #0,d0                 ; Voie 1
           move.b #8,(a0)
           move.b (a0),d0
           cmp.b #16,d0
           blt.s ok1
           move.b #15,d0
ok1        move.w #%1110000000000000,(a1)
           move.w #%1110000000000000,128(a1)
           lea -160(a1),a1
           dbf d0,ok1

           move.l a2,a1                ; Voie 2
           moveq #0,d0
           move.b #9,(a0)
           move.b (a0),d0
           cmp.b #16,d0
           blt.s ok2
           move.b #15,d0
ok2        or.w #%0000001110000000,(a1)
           or.w #%0000001110000000,128(a1)
           lea -160(a1),a1
           dbf d0,ok2

           move.l a2,a1                ; Voie 3
           moveq #0,d0
           move.b #10,(a0)
           move.b (a0),d0
           cmp.b #16,d0
           blt.s ok3
           move.b #15,d0
ok3        or.w #%0000000000001110,(a1)
           or.w #%0000000000001110,128(a1)
           lea -160(a1),a1
           dbf d0,ok3

;
; ---------------------------------------------------------------
; Scrolltext circulaire
; ---------------------------------------------------------------
;

;
; ---------------------------------------------------------------
; Efface les 16 caracteres 
; ---------------------------------------------------------------
;

           move.l eff_1,a0

           rept 16
           move.l (a0)+,a1
           clr.w 4(a1)                 ; 1re ligne
           clr.w 12(a1)
           clr.w 164(a1)               ; 2me
           clr.w 172(a1)
           clr.w 324(a1)               ; 3me
           clr.w 332(a1)
           clr.w 484(a1)               ; 4me
           clr.w 492(a1)
           clr.w 644(a1)               ; 5me
           clr.w 652(a1)
           clr.w 804(a1)               ; 6me
           clr.w 812(a1)
           clr.w 964(a1)               ; 7me
           clr.w 972(a1)
           clr.w 1124(a1)              ; 8me
           clr.w 1132(a1)
           clr.w 1284(a1)              ; 9me
           clr.w 1292(a1)
           clr.w 1444(a1)              ; 10me
           clr.w 1452(a1)
           clr.w 1604(a1)              ; 11me
           clr.w 1612(a1)
           clr.w 1764(a1)              ; 12me
           clr.w 1772(a1)
           clr.w 1924(a1)              ; 13me
           clr.w 1932(a1)
           clr.w 2084(a1)              ; 14me
           clr.w 2092(a1)
           clr.w 2244(a1)              ; 15me
           clr.w 2252(a1)
           endr

; ---------------------------------------------------------------
; Affiche les 16 caracteres
; ---------------------------------------------------------------

           move.l coor_ptr,a0
           move.l txt_ptr,a1

; 
; --- Routine d'affichage du caractere no: 0 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 600(a0),d0         ; x dans d0
           move.w 602(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,(a2)

; -> Calcul adresse caractere 

           lea font,a2
           move.b (a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr


; 
; --- Routine d'affichage du caractere no: 1 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 560(a0),d0         ; x dans d0
           move.w 562(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,4(a2)

; ---< Calcul adresse caractere >---

           lea font,a2
           move.b 1(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 2 ---
;

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 520(a0),d0          ; x dans d0
           move.w 522(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,8(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 2(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere 

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 3 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 480(a0),d0          ; x dans d0
           move.w 482(a0),d1          ; y dans d1
           bsr test 
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,12(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 3(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 4 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 440(a0),d0          ; x dans d0
           move.w 442(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,16(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 4(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

;
; --- Routine d'affichage du caractere no: 5 ---
;

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage 

           move.w 400(a0),d0          ; x dans d0
           move.w 402(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,20(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 5(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 6 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 360(a0),d0          ; x dans d0
           move.w 362(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,24(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 6(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 7 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 320(a0),d0          ; x dans d0
           move.w 322(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,28(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 7(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 8 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 280(a0),d0          ; x dans d0
           move.w 282(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,32(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 8(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

;
; --- Routine d'affichage du caractere no: 9 ---
;

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 240(a0),d0          ; x dans d0
           move.w 242(a0),d1          ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,36(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 9(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 10 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 200(a0),d0         ; x dans d0
           move.w 202(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,40(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 10(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere 

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

;
; --- Routine d'affichage du caractere no: 11 ---
;

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 160(a0),d0         ; x dans d0
           move.w 162(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,44(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 11(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

;
; --- Routine d'affichage du caractere no: 12 ---
;

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 120(a0),d0         ; x dans d0
           move.w 122(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,48(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 12(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 13 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 80(a0),d0         ; x dans d0
           move.w 82(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,52(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 13(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

;
; --- Routine d'affichage du caractere no: 14 ---
;


           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w 40(a0),d0         ; x dans d0
           move.w 42(a0),d1         ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,56(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 14(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

; 
; --- Routine d'affichage du caractere no: 15 ---
; 

           move.l screen1,a6

           moveq #0,d0
           moveq #0,d1
           moveq #0,d2
           moveq #0,d7
         
; -> Calcul adresse d'affichage

           move.w (a0),d0            ; x dans d0
           move.w 2(a0),d1           ; y dans d1
           bsr test
           move.w d0,d7              ; x dans d7
           and.l #15,d7              ; Decalage mod 15
           lsr.w #1,d0               ; x / 2
           andi.w #$f8,d0            ; AND - 8
           add.w d0,d1               ; x + y * 160
           add.l d1,a6               ; adresse d'affichage
           move.l eff_1,a2
           move.l a6,60(a2)

; -> Calcul adresse caractere

           lea font,a2
           move.b 15(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

i          set 0
           rept 15
           moveq #0,d0
           move.w (a2)+,d0
           ror.l d7,d0
           or.w d0,i+4(a6)
           swap d0
           or.w d0,i+12(a6)
i          set i+160
           endr

;
; ---------------------------------------------------------------
; Deplacement des caracteres
; ---------------------------------------------------------------
;

           addq.l #4,coor_ptr
           cmp.l #coor+40,coor_ptr
           bne.s dep
           move.l #coor,coor_ptr
           addq.l #1,txt_ptr
           cmp.l #fin_txt,txt_ptr
           bne.s dep
           move.l #txt,txt_ptr
dep

; ---------------------------------------------------------------
; Donnees & variables pour le deplacement des caracteres
; ---------------------------------------------------------------

           section data

font       incbin "FONTCAR1.DAT"
coor       incbin "CIRCLE.DAT"
           
txt        dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
           incbin "texte.dat"
fin_txt    dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44
           even

           section bss

eff_1      ds.l 1
eff_2      ds.l 1
txt_ptr    ds.l 1
coor_ptr   ds.l 1
eff_tab1   ds.l 16
eff_tab2   ds.l 16

           section text

;
; ---------------------------------------------------------------
; Deplacement du cercle
; ---------------------------------------------------------------
;

circle     move.l wave_ptr,a0
           addq.l #4,a0                 ; Adresse coordonnees+4
           cmp.l wave_end,a0            ; Fini
           bne.s move_it                ; Non ...

;
; --- Test du compteur ---
;

           move.l anim,d0
           subq.l #1,d0
           bne.s couac

;
; --- Nouvelle vague ---
;

           move.l script_ptr,a1
           add.l #12,a1
           cmp.l #wave_0,a1
           bne.s new_wave
           move.l #script,a1
new_wave   move.l a1,script_ptr
           move.l (a1),d0
           move.l 4(a1),wave_deb
           move.l 8(a1),wave_end
 
couac      move.l d0,anim
           move.l wave_deb,a0           ; Et si, retour au depart       

move_it    move.l a0,wave_ptr

;
; ---------------------------------------------------------------
; Donnees & variables pour le deplacement du cercle
; ---------------------------------------------------------------
;

           section data

;
; --- 'Script' de deplacement du cercle ---
;

;          dc.l nbr_fois,wave_n,fin_wave
;
;          nbr_fois: Nbre de fois que le cercle fera le deplacement
;          wave_n  : Type de deplacement (0 < n < 3)          
;          fin_wave: Adresse de fin du deplacement wave_n
; 
; wave_0 : Le cercle ne bouge pas ...!
; wave_1 : Le cercle de deplace a gauche & droite 
; wave_2 : Le cercle rebondit
; wave_3 : Le cercle rebondit et se deplace a gauche & a droite
 
script     dc.l 0002,wave_2,wave_2+0136
           dc.l 0100,wave_0,wave_0+0004
           dc.l 0001,wave_3,wave_3+0544
           dc.l 0100,wave_0,wave_0+0004
           dc.l 0001,wave_1,wave_1+3600
           dc.l 0100,wave_0,wave_0+0004
           dc.l 0020,wave_2,wave_2+0136
           dc.l 0002,wave_3,wave_3+0544
           dc.l 0100,wave_0,wave_0+0004
           dc.l 0002,wave_1,wave_1+3600
           dc.l 0100,wave_0,wave_0+0004
           dc.l 0004,wave_3,wave_3+0544
           dc.l 0100,wave_0,wave_0+0004

;          
;
; --- Fichiers des deplacements ---
;
;

wave_0     dc.w 0,0                 ; Fin: wave_0 + 0004
wave_1     incbin "WAVE_1.DAT"      ; Fin: wave_1 + 3600
wave_2     incbin "WAVE_2.DAT"      ; Fin: wave_2 + 0136
wave_3     incbin "WAVE_3.DAT"      ; Fin: wave_3 + 0544

           section bss

;
; 
; --- Variables pour le deplacement ---
; 
;

script_ptr ds.l 1            ; Adresse en cours (script)
wave_ptr   ds.l 1            ; Adresse en cours (coordonnees)
wave_deb   ds.l 1            ; Adresse debut wave
wave_end   ds.l 1            ; Adresse fin wave
anim       ds.l 1            ; Nombre de fois

           section text
 
;
; ---------------------------------------------------------------
; 'Bigscroll' (lettres de 64*64 pixels)
; ---------------------------------------------------------------
;

;
; --- Test pointeurs ---
;

           move.l adr_big,a0
           cmp.l #fond,a0
           bne.s big
           move.l #big_scr,a0

;
; --- Scroll du texte (8 fois 8 lignes) ---
;

big        move.l a0,adr_big
           move.l screen1,a0
           move.l screen2,a1
           lea 70*160(a0),a0
           lea 70*160(a1),a1

           move.l adr_big,a2

i          set 6
scroll     rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 2 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 3 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 4 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 5 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 6 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 7 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2

; --- 8 ---

           rept 8
           move.w i+32(a0),i+24(a0)
           move.w i+40(a0),i+32(a0)
           move.w i+48(a0),i+40(a0)
           move.w i+56(a0),i+48(a0)
           move.w i+64(a0),i+56(a0)
           move.w i+72(a0),i+64(a0)
           move.w i+80(a0),i+72(a0)
           move.w i+88(a0),i+80(a0)
           move.w i+96(a0),i+88(a0)
           move.w i+104(a0),i+96(a0)
           move.w i+112(a0),i+104(a0)
           move.w i+120(a0),i+112(a0)
           move.w i+128(a0),i+120(a0)
           move.w i+136(a0),i+128(a0)
           move.b i+137(a1),i+136(a0)
           move.b (a2),i+137(a0)
i          set i+160
           endr
           addq #1,a2
           move.l a2,adr_big
           
           section bss

adr_big    ds.l 1

           section text

;
; --------------------------------------------------------------
; Scrolltexts verticaux (fonte 16x16 1 plan)
; --------------------------------------------------------------
;

           moveq #0,d0
           move.b vbit,d0
           cmp.b #16,d0
           bne.s plusloin2
           clr.b vbit
           move.l vtxt_ptr,a0
           move.b (a0),d0
           cmp.b #255,d0
           bne.s vsuite
           move.l #vtext,vtxt_ptr
           move.l vtxt_ptr,a0
           move.b (a0),d0
vsuite     addq.l #1,vtxt_ptr
           asl #5,d0
           lea fontv,a0
           add.l d0,a0
           lea vbuffer,a1

;
; --- Caractere -> Buffer ---
;

           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

plusloin2  add.b #1,vbit

;
; --- Physic -> Logic ---
;

           move.l screen2,a0
           move.l screen1,a1
n          set 480
           rept 194
           move.w 8+n(a0),8+n-160(a1)
           move.w 152+n(a0),152+n-160(a1)
n          set n+160
           endr

;
; --- Buffer -> Logic ---
;

           lea vbuffer,a0
           move.w (a0),8+196*160(a1)
           move.w (a0),152+196*160(a1)
           movem.l 2(a0),d0-d7
           movem.l d0-d7,(a0)

;
; ---------------------------------------------------------------
; Swapping des ecrans logic/physic et des buffers d'effacement
; ---------------------------------------------------------------
;

           move.l eff_1,d0
           move.l eff_2,eff_1
           move.l d0,eff_2

           move.l screen1,d0
           move.l screen2,screen1
           move.l d0,screen2

           lsr.l #8,d0
           move.w #$8200,a0
           movep.w d0,1(a0)

           rte                         ; Fin programme principal

;
; --------------------------------------------------------------
; Rasters & no down border (timer B)
; --------------------------------------------------------------
;

;
; --- Rasters ---
;

hbl1       addq.w #1,cmptr
           move.w (a3)+,$ffff8242.w
           move.w (a4)+,$ffff8244.w
           move.w (a5)+,$ffff8240.w
           cmp.w #198,cmptr
           bne.s fin_hbl
           move.w #$320,$ff8254
           move.w #$432,$ff825a
           clr.b $ffffa1b
           move.b #1,$ffffa21
           move.l #border,$120.w
           move.b #8,$ffffa1b
fin_hbl    rte

; 
; --- No down border ---
; 

border     clr.b $fffffa1b.w
	   movem.l d0/a0,-(sp)
	   movea.w #$fa21,a0
	   move.b #200,(a0)
	   move.b #8,$fffffa1b.w
	   move.b (a0),d0
wait2	   cmp.b (a0),d0
	   beq.s wait2
	   clr.b $ffff820a.w
	   rept 16
 	   nop
	   endr
	   move.b #2,$ffff820a.w
	   movem.l (sp)+,d0/a0
	   rte			
		
;
; --- Clavier ---
;

newkey     move.w #$2500,sr
           bclr #6,$ffffa11
           rte
;
; ---------------------------------------------------------------
; Tests pour le deplacement du cercle
; ---------------------------------------------------------------
;

test       move.l wave_ptr,a2

;
; --- Test gauche/droite ---
;

           add.w (a2),d0
           cmp.w #48,d0
           bgt.s ok_gauche
           move.w #48,d0
ok_gauche  cmp.w #273,d0
           blt.s ok_droite
           move.w #273,d0

;
; --- Test haut/bas ---
;

ok_droite  clr.l d3
           clr.l d4
           move.w d1,d3
           move.w 2(a2),d4
           add.w 2(a2),d1
           add.l d3,d4
           cmp.l #174*160,d4
           blt.s ok_bas
           move.w #174*160,d1
ok_bas     rts
           
;
; --------------------------------------------------------------
; Donnees & variables pour l'ensemble du programme
; --------------------------------------------------------------
;      

; --- Couleurs rasters 1 (couleur 1) ---

rasters    dc.w $771
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $570,$670,$770,$771,$772
oh_baby    dc.w $771
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $570,$670,$770,$771,$772

;
; --- Couleurs rasters 2 (couleur 2) ---
;

rasters2   dc.w $771
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $570,$670,$770,$771,$772
shabada    dc.w $771
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $770,$670,$570,$470,$370,$270,$170,$070
           dc.w $071,$072,$073,$074,$075,$076,$077,$067
           dc.w $057,$047,$037,$027,$017,$007,$107,$207
           dc.w $307,$407,$507,$607,$707,$706,$705,$704
           dc.w $703,$702,$701,$700,$710,$720,$730,$740
           dc.w $750,$760,$770,$670,$570,$470,$370,$270
           dc.w $170,$070,$071,$072,$073,$074,$075,$076
           dc.w $077,$067,$057,$047,$037,$027,$017,$007
           dc.w $107,$207,$307,$407,$507,$607,$707,$706
           dc.w $705,$704,$703,$702,$701,$700,$710,$720
           dc.w $730,$740,$750,$760,$770,$670,$570,$470
           dc.w $370,$270,$170,$070,$170,$270,$370,$470
           dc.w $570,$670,$770,$771,$772

; 
; --- Couleurs rasters du fond (couleur 0) ---
; 

the_fond   dc.w $777,$000,$000,$000,$000,$000,$000,$000,$000,$000
           dc.w $000,$000,$110,$220,$330,$440,$550,$660,$770,$770
           dc.w $660,$550,$440,$330,$220,$110,$000,$000,$010,$020
           dc.w $030,$040,$050,$060,$070,$070,$060,$050,$040,$030
           dc.w $010,$000,$000,$100,$200,$300,$400,$500,$600,$700
           dc.w $700,$600,$500,$400,$300,$200,$100,$000,$000,$011
           dc.w $022,$033,$044,$055,$066,$077,$077,$066,$055,$044
           dc.w $033,$022,$011,$000,$000,$101,$202,$303,$404,$505
           dc.w $505,$606,$707,$707,$606,$505,$404,$303,$202,$101
           dc.w $000,$000,$001,$002,$003,$004,$005,$006,$007,$007
           dc.w $006,$005,$004,$003,$002,$001,$000,$000,$101,$202      
           dc.w $303,$404,$505,$606,$707,$707,$606,$505,$404,$303
           dc.w $202,$101,$000,$000,$011,$022,$033,$044,$055,$066
           dc.w $077,$077,$066,$055,$044,$033,$022,$011,$000,$000
           dc.w $100,$200,$300,$400,$500,$600,$700,$700,$600,$500
           dc.w $400,$300,$200,$100,$000,$000,$010,$020,$030,$040
           dc.w $050,$060,$070,$070,$060,$050,$040,$030,$020,$010
           dc.w $000,$000,$110,$220,$330,$440,$550,$660,$770,$770
           dc.w $770,$660,$550,$440,$330,$220,$110,$000,$000,$000
           dc.w $000,$000,$000,$000,$000,$000,$777,$000,$000,$000

; 
; --- Barre de rasters grise (couleur 0) ---
; 

the_bar    dc.w $000,$111,$222,$333,$444,$555,$666,$777
           dc.w $777,$666,$555,$444,$333,$222,$111,$000           

; 
; --- Adresses de deplacement des barres --
; 

the_mov    dc.l fond+182
           dc.l fond+186
           dc.l fond+190
           dc.l fond+196
           dc.l fond+200
           dc.l fond+206
           dc.l fond+210
           dc.l fond+214
           dc.l fond+220
           dc.l fond+224
           dc.l fond+228
           dc.l fond+234
           dc.l fond+238
           dc.l fond+242
           dc.l fond+246
           dc.l fond+252
           dc.l fond+256
           dc.l fond+260
           dc.l fond+264
           dc.l fond+268
           dc.l fond+270
           dc.l fond+274
           dc.l fond+278
           dc.l fond+282
           dc.l fond+286
           dc.l fond+288
           dc.l fond+292
           dc.l fond+294
           dc.l fond+298
           dc.l fond+300
           dc.l fond+302
           dc.l fond+304
           dc.l fond+306
           dc.l fond+308
           dc.l fond+310
           dc.l fond+312
           dc.l fond+314
           dc.l fond+316
           dc.l fond+316
           dc.l fond+318
           dc.l fond+318
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+322
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+318
           dc.l fond+318
           dc.l fond+316
           dc.l fond+316
           dc.l fond+314
           dc.l fond+312
           dc.l fond+310
           dc.l fond+308
           dc.l fond+306
           dc.l fond+304
           dc.l fond+302
           dc.l fond+300
           dc.l fond+298
           dc.l fond+294
           dc.l fond+292
           dc.l fond+288
           dc.l fond+286
           dc.l fond+282
           dc.l fond+278
           dc.l fond+274
           dc.l fond+270
           dc.l fond+268
           dc.l fond+264
           dc.l fond+260
           dc.l fond+256
           dc.l fond+252
           dc.l fond+246
           dc.l fond+242
           dc.l fond+238
           dc.l fond+234
           dc.l fond+228
           dc.l fond+224
           dc.l fond+220
           dc.l fond+214
           dc.l fond+210
           dc.l fond+206
           dc.l fond+200
           dc.l fond+196
           dc.l fond+190
           dc.l fond+186
           dc.l fond+182
           dc.l fond+176
           dc.l fond+172
           dc.l fond+166
           dc.l fond+162
           dc.l fond+156
           dc.l fond+152
           dc.l fond+148
           dc.l fond+142
           dc.l fond+138
           dc.l fond+134
           dc.l fond+128
           dc.l fond+124
           dc.l fond+120
           dc.l fond+116
           dc.l fond+112
           dc.l fond+106
           dc.l fond+102
           dc.l fond+98
           dc.l fond+94
           dc.l fond+92
           dc.l fond+88
           dc.l fond+84
           dc.l fond+80
           dc.l fond+76
           dc.l fond+74
           dc.l fond+70
           dc.l fond+68
           dc.l fond+64
           dc.l fond+62
           dc.l fond+60
           dc.l fond+58
           dc.l fond+56
           dc.l fond+54
           dc.l fond+52
           dc.l fond+50
           dc.l fond+48
           dc.l fond+46
           dc.l fond+46
           dc.l fond+44
           dc.l fond+44
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+44
           dc.l fond+44
           dc.l fond+46
           dc.l fond+46
           dc.l fond+48
           dc.l fond+50
           dc.l fond+52
           dc.l fond+54
           dc.l fond+56
           dc.l fond+58
           dc.l fond+60
           dc.l fond+62
           dc.l fond+64
           dc.l fond+68
           dc.l fond+70
           dc.l fond+74
           dc.l fond+76
           dc.l fond+80
           dc.l fond+84
           dc.l fond+88
           dc.l fond+92
           dc.l fond+94
           dc.l fond+98
           dc.l fond+102
           dc.l fond+106
           dc.l fond+112
           dc.l fond+116
           dc.l fond+120
           dc.l fond+124
           dc.l fond+128
           dc.l fond+134
           dc.l fond+138
           dc.l fond+142
           dc.l fond+148
           dc.l fond+152
           dc.l fond+156
           dc.l fond+162
           dc.l fond+166
           dc.l fond+172
           dc.l fond+176

ah_yeah    dc.l fond+182
           dc.l fond+186
           dc.l fond+190
           dc.l fond+196
           dc.l fond+200
           dc.l fond+206
           dc.l fond+210
           dc.l fond+214
           dc.l fond+220
           dc.l fond+224
           dc.l fond+228
           dc.l fond+234
           dc.l fond+238
           dc.l fond+242
           dc.l fond+246
           dc.l fond+252
           dc.l fond+256
           dc.l fond+260
           dc.l fond+264
           dc.l fond+268
           dc.l fond+270
           dc.l fond+274
           dc.l fond+278
           dc.l fond+282
           dc.l fond+286
           dc.l fond+288
           dc.l fond+292
           dc.l fond+294
           dc.l fond+298
           dc.l fond+300
           dc.l fond+302
           dc.l fond+304
           dc.l fond+306
           dc.l fond+308
           dc.l fond+310
           dc.l fond+312
           dc.l fond+314
           dc.l fond+316
           dc.l fond+316
           dc.l fond+318
           dc.l fond+318
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+322
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+320
           dc.l fond+318
           dc.l fond+318
           dc.l fond+316
           dc.l fond+316
           dc.l fond+314
           dc.l fond+312
           dc.l fond+310
           dc.l fond+308
           dc.l fond+306
           dc.l fond+304
           dc.l fond+302
           dc.l fond+300
           dc.l fond+298
           dc.l fond+294
           dc.l fond+292
           dc.l fond+288
           dc.l fond+286
           dc.l fond+282
           dc.l fond+278
           dc.l fond+274
           dc.l fond+270
           dc.l fond+268
           dc.l fond+264
           dc.l fond+260
           dc.l fond+256
           dc.l fond+252
           dc.l fond+246
           dc.l fond+242
           dc.l fond+238
           dc.l fond+234
           dc.l fond+228
           dc.l fond+224
           dc.l fond+220
           dc.l fond+214
           dc.l fond+210
           dc.l fond+206
           dc.l fond+200
           dc.l fond+196
           dc.l fond+190
           dc.l fond+186
           dc.l fond+182
           dc.l fond+176
           dc.l fond+172
           dc.l fond+166
           dc.l fond+162
           dc.l fond+156
           dc.l fond+152
           dc.l fond+148
           dc.l fond+142
           dc.l fond+138
           dc.l fond+134
           dc.l fond+128
           dc.l fond+124
           dc.l fond+120
           dc.l fond+116
           dc.l fond+112
           dc.l fond+106
           dc.l fond+102
           dc.l fond+98
           dc.l fond+94
           dc.l fond+92
           dc.l fond+88
           dc.l fond+84
           dc.l fond+80
           dc.l fond+76
           dc.l fond+74
           dc.l fond+70
           dc.l fond+68
           dc.l fond+64
           dc.l fond+62
           dc.l fond+60
           dc.l fond+58
           dc.l fond+56
           dc.l fond+54
           dc.l fond+52
           dc.l fond+50
           dc.l fond+48
           dc.l fond+46
           dc.l fond+46
           dc.l fond+44
           dc.l fond+44
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+42
           dc.l fond+44
           dc.l fond+44
           dc.l fond+46
           dc.l fond+46
           dc.l fond+48
           dc.l fond+50
           dc.l fond+52
           dc.l fond+54
           dc.l fond+56
           dc.l fond+58
           dc.l fond+60
           dc.l fond+62
           dc.l fond+64
           dc.l fond+68
           dc.l fond+70
           dc.l fond+74
           dc.l fond+76
           dc.l fond+80
           dc.l fond+84
           dc.l fond+88
           dc.l fond+92
           dc.l fond+94
           dc.l fond+98
           dc.l fond+102
           dc.l fond+106
           dc.l fond+112
           dc.l fond+116
           dc.l fond+120
           dc.l fond+124
           dc.l fond+128
           dc.l fond+134
           dc.l fond+138
           dc.l fond+142
           dc.l fond+148
           dc.l fond+152
           dc.l fond+156
           dc.l fond+162
           dc.l fond+166
           dc.l fond+172
           dc.l fond+176

;
; --- Donnees & variables pour les scrolltexts verticaux ---
;

           section bss

vtxt_ptr   ds.l 1
vbuffer    ds.w 17
vbit       ds.b 1
           even
         
           section data

vtext     incbin "a:\compil_2\texte.dat"
          even

;
; --- Donnees pour le BIGSCROLL ---
;

; --- F ---

big_scr   dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
            
; --- O ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- N ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- T ---

          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; ---  ---

          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- C ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- O ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- M ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$ff,$ff,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- P ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$00
          dc.b $ff,$ff,$ff,$ff,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00


; --- I ---

          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$00


; --- L ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$ff

; ---  ---

          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- D ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$ff,$ff,$ff,$ff,$ff,$ff,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00


; --- I ---

          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$00


; --- S ---

          dc.b $ff,$ff,$ff,$ff,$00,$00,$00,$00
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$ff,$ff,$ff,$ff,$ff
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- C ---

          dc.b $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$ff
          dc.b $ff,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; ---  ---

          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- # ---

          dc.b $00,$00,$ff,$00,$00,$ff,$00,$00
          dc.b $00,$00,$ff,$00,$00,$ff,$00,$00
          dc.b $00,$ff,$ff,$ff,$ff,$ff,$ff,$00
          dc.b $00,$00,$ff,$00,$00,$ff,$00,$00
          dc.b $00,$ff,$ff,$ff,$ff,$ff,$ff,$00
          dc.b $00,$00,$ff,$00,$00,$ff,$00,$00
          dc.b $00,$00,$ff,$00,$00,$ff,$00,$00
          dc.b $00,$00,$00,$00,$00,$00,$00,$00

; --- 2 ---

           dc.b $ff,$00,$00,$ff,$ff,$ff,$ff,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$00,$00,$ff,$00,$00,$00,$ff
           dc.b $ff,$ff,$ff,$ff,$00,$00,$00,$ff
           dc.b $00,$00,$00,$00,$00,$00,$00,$00


; ---  ---

           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00

; ---  ---

           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00

; ---  ---

           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00

; ---  ---

           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00

; ---  ---

           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00
           dc.b $00,$00,$00,$00,$00,$00,$00,$00

fond       ds.w 200

save_hbl   ds.l 1
save_118   ds.l 1
save_vbl   ds.l 1
oldscreen  ds.l 1
screen1    ds.l 1
screen2    ds.l 1
oldssp     ds.l 1

fantomas   ds.l 1
droopy     ds.l 1
tut_adr    ds.l 1
conte      ds.w 1

oldrez     ds.w 1
oldpal     ds.w 16

save_vect  ds.b 1
save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
savea11    ds.b 1
key        ds.b 1
cmptr      ds.b 1
           even

;
; --- Charge les fichiers (dessins, fontes, musiques ...) ---
;

music      incbin "COUNT_00.DAT"
logo       incbin "RAST_LOG.DAT"
fontv      incbin "FONTCAR2.DAT"
plasma     incbin "PLASMA_2.PI1"

; *** STOP *** 2605 lignes, ca suffit !!!