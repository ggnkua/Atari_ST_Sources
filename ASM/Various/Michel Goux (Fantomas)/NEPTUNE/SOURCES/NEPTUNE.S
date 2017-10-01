; *------------------------------------------------------*
;                 **** [ N E P T U N E ] ****
;                   ½ GOUX Michel -Fantomas- 
;              e-mail  : michel.goux@wanadoo.fr
;     site web: http://www.perso.wanadoo.fr/michel.goux/
; *------------------------------------------------------*
;
; -> Utiliser les fleches pour modifier la courbe.
; -> F1 … F10 pour des courbes pr‚d‚finies.

; **************
;
; INITIALISATION
;
; **************

           opt o+

; --- Mode superviseur ---

           clr.l 	-(sp)
           move.w 	#$20,-(sp)
           trap 	#1
           addq.l 	#6,sp
           move.l 	d0,oldssp

; --- Sauve et supprime clavier ---

           move.b 	$484,key
           clr.b 	$484

; --- Supprime souris ---
 
           pea 		stop_mouse
           move.w 	#0,-(sp)
           move.w 	#$19,-(sp)
           trap 	#14
           addq.l 	#8,sp

; --- Sauve palette couleurs ---

           move.l 	#$ffff8240,a0
           lea 		oldpal,a1
           movem.l 	(a0)+,d0-d7
           movem.l 	d0-d7,(a1)

; --- Installe nouvelle palette ---

          pea 		fond+2
          move.w 	#6,-(sp)
          trap 		#14
          addq.l 	#6,sp
            
; --- Sauve resolution ---

	   move.w 	#4,-(sp)
           trap 	#14
           addq.l 	#4,sp 
           move.w 	d0,oldrez

; --- Sauve adresse ecran ---

           move.w 	#2,-(sp)
           trap 	#14
           addq.l 	#2,sp
           move.l 	d0,oldscreen

; --- Cree deux ecrans --- 

           move.l 	#$70000,screen1
           move.l 	#$77d00,screen2

; --- Change resolution et ecrans ---

           clr.w 	-(sp)
           move.l 	screen1,-(sp)
           move.l 	screen2,-(sp)
           move.w 	#5,-(sp)
           trap 	#14
           add.l 	#14,sp

; --- Affiche le fond ---

           move.l 	screen1,a0
           move.l 	screen2,a1
           lea 		fond+34,a2
           move.w 	#7999,d0
boucle2    move.l 	(a2),(a0)+
           move.l 	(a2)+,(a1)+
           dbra 	d0,boucle2

; --- Init musique ---

          moveq 	#1,d0
          bsr 		music
           
; ************************
;
; INITIALISATIONS DIVERSES
;
; ************************

; --- Init effacement ---

           move.l 	#efftab1,efface1
           move.l 	#efftab2,efface2                       

           move.l 	screen1,a0        
           move.l 	efface1,a1
           move.l 	efface2,a2
           move.w 	#15,d0

one_more   move.l 	a0,(a1)+
           move.l 	a0,(a2)+

           rept 	15
           move.l 	(a0),(a1)+
           move.l 	(a0),(a2)+
           move.l 	4(a0),(a1)+
           move.l 4(a0),(a2)+
           move.l 8(a0),(a1)+
           move.l 8(a0),(a2)+
           move.l 12(a0),(a1)+
           move.l 12(a0),(a2)+
           endr
            
           dbf d0,one_more
  
; ---

           move.w #1456,incr

           move.l screen1,a0
           bsr params

; --- Init synchro ---

           move.l $70,save_vbl
           move.l #vbl,$70           

; ***************** 
;
; BOUCLE PRINCIPALE
;
; *****************

; -----------------------------
; Teste les touches de fonction
; -----------------------------

loop       cmp.b #$39,$ffffc02
           bne.s loop

; ****************
;
; FIN DU PROGRAMME
;
; ****************


; --- Restore timers ---

           move.l save_vbl,$70
           
; --- Chip sonore ---

           move.b #8,$ff8800
           move.b #0,$ff8802
           move.b #9,$ff8800
           move.b #0,$ff8802
           move.b #$a,$ff8800
           move.b #0,$ff8802

; --- Ancienne resolution et ecrans ---
        
           move.w oldrez,-(sp)
           move.l oldscreen,-(sp)
           move.l oldscreen,-(sp)
           move.w #5,-(sp)
           trap #14
           add.l #12,sp

; --- Ancienne palette ---
          
           lea oldpal,a0
           move.l #$ffff8240,a1
           movem.l (a0)+,d0-d7
           movem.l d0-d7,(a1)

; --- Retablit la souris ---
 
           pea go_mouse(pc)
           move.w #0,-(sp)
           move.w #$19,-(sp)
           trap #14
           addq.l #8,sp

; --- Retablit le clavier ---

           move.b key,$484

; --- Retour en mode USER ---

           move.l oldssp,-(sp)
           move.w #$20,-(sp)
           trap #1
           addq.l #6,sp

; --- Retour au DOS ---

           clr.w -(sp)
           trap #1

; *********
;
; PROGRAMME
;
; *********

vbl:

           move.l a3,-(sp)
           bsr music+34
           move.l (sp)+,a3

; ------------
; Test touches
; ------------

           moveq #0,d0
           lea $ffffc02,a0
           move.b (a0),d0
           
; --- Touches de fonction ---

           cmp.b #$3b,d0
           blt pas_tou
           cmp.b #$44,d0
           ble function

; --- Teste si fleche droite ---

           cmp.b #$4d,d0
           bne.s pas_droi
           move.b d0,kay
           add.w #24,incr
           cmp.w #1576,incr
           bne.s pas_droi
           move.w #1456,incr

; --- Teste si fleche gauche ---

pas_droi   cmp.b #$4b,d0
           bne.s pas_gauc
           move.b d0,kay
           sub.w #24,incr
           cmp.w #1432,incr
           bne.s pas_gauc
           move.w #1552,incr

; --------------------
; Teste si fleche haut
; --------------------

pas_gauc  cmp.b #$48,d0
          bne pas_haut

; --- xd ---

          cmp.w #1456,incr
          bne.s pas_1
          addq.w #1,xd
          cmp.w #11,xd
          bne.s mic_1
          clr.w xd
mic_1     bra restore

; --- yd ---

pas_1     cmp.w #1480,incr
          bne.s pas_2
          addq.w #1,yd
          cmp.w #11,yd
          bne.s mic_2
          clr.w yd
mic_2     bra.s restore

; --- xv ---

pas_2     cmp.w #1504,incr
          bne.s pas_3
          addq.w #1,xv
          cmp.w #256,xv
          bne.s mic_3
          clr.w xv
mic_3     bra.s restore

; --- yv ---

pas_3     cmp.w #1528,incr
          bne.s pas_4
          addq.w #1,yv
          cmp.w #256,yv
          bne.s mic_4
          clr.w yv
mic_4     bra.s restore

; --- gd ---

pas_4     addq.w #1,gd
          cmp.w #256,gd
          bne.s restore
          clr.w gd

restore   bsr params

; --------------------
; Teste si fleche bas
; --------------------

pas_haut  cmp.b #$50,d0
          bne pas_tou

; --- xd ---

          cmp.w #1456,incr
          bne.s pas_5
          subq.w #1,xd
          cmp.w #0,xd
          bge.s mic_5
          move.w #10,xd
mic_5     bra restaure

; --- yd ---

pas_5     cmp.w #1480,incr
          bne.s pas_6
          subq.w #1,yd
          cmp.w #0,yd
          bge.s mic_6
          move.w #10,yd
mic_6     bra.s restaure

; --- xv ---

pas_6     cmp.w #1504,incr
          bne.s pas_7
          subq.w #1,xv
          cmp.w #0,xv
          bge.s mic_7
          move.w #255,xv
mic_7     bra.s restaure

; --- yv ---

pas_7     cmp.w #1528,incr
          bne.s pas_8
          subq.w #1,yv
          cmp.w #0,yv
          bge.s mic_8
          move.w #255,yv
mic_8     bra.s restaure

; --- gd ---

pas_8     subq.w #1,gd
          cmp.w #0,gd
          bge.s restaure
          move.w #255,gd

restaure  bsr params
          bra pas_tou

; ----------------------------
; Courbes predefinies (F1-F10)
; ----------------------------

function   lea courbes,a0 
           lea xd,a1
           moveq #0,d1
          
           sub.b #$3b,d0
           move.b d0,d1
           asl.w #2,d1
           add.w d1,d0
           add.w d0,d0
           add.w d0,a0

           move.l (a0)+,(a1)+
           move.l (a0)+,(a1)+
           move.w (a0),(a1)
           bsr params

; --------------
; Buffer-> Ecran
; --------------

pas_tou    move.l screen1,a1
           lea (a1),a2
           move.w eff_inc1,d0
           add.w d0,a2
           clr.l 4(a2)
           move.w incr,d0
           move.w incr,eff_inc1
           add.w d0,a1
           move.w #%1111111111111111,4(a1)
       
           lea buf_num,a1
           move.l screen1,a2          ; Et le buffer ...
i          set 0
           rept 6
           move.w (a1)+,i+22(a2)
           move.w (a1)+,i+182(a2)
           move.w (a1)+,i+342(a2)
           move.w (a1)+,i+502(a2)
           move.w (a1)+,i+662(a2)
           move.w (a1)+,i+822(a2)
           move.w (a1)+,i+982(a2)
           move.w (a1)+,i+1142(a2)
i          set i+24
           endr

; -------------
; Efface balles
; -------------

           move.l efface1,a0

i          set 3660
           rept 16
           lea i(a0),a1

           move.l (a1)+,a2             ; Adresse ecran

           move.l (a1)+,(a2)           ; Ligne 1
           move.l (a1)+,4(a2)
           move.l (a1)+,8(a2)
           move.l (a1)+,12(a2)

           move.l (a1)+,160(a2)        ; Ligne 2
           move.l (a1)+,164(a2)
           move.l (a1)+,168(a2)
           move.l (a1)+,172(a2)

           move.l (a1)+,320(a2)        ; Ligne 3
           move.l (a1)+,324(a2)
           move.l (a1)+,328(a2)
           move.l (a1)+,332(a2)

           move.l (a1)+,480(a2)        ; Ligne 4
           move.l (a1)+,484(a2)
           move.l (a1)+,488(a2)
           move.l (a1)+,492(a2)

           move.l (a1)+,640(a2)        ; Ligne 5
           move.l (a1)+,644(a2)
           move.l (a1)+,648(a2)
           move.l (a1)+,652(a2)

           move.l (a1)+,800(a2)        ; Ligne 6
           move.l (a1)+,804(a2)
           move.l (a1)+,808(a2)
           move.l (a1)+,812(a2)

           move.l (a1)+,960(a2)        ; Ligne 7
           move.l (a1)+,964(a2)
           move.l (a1)+,968(a2)
           move.l (a1)+,972(a2)

           move.l (a1)+,1120(a2)        ; Ligne 8
           move.l (a1)+,1124(a2)
           move.l (a1)+,1128(a2)
           move.l (a1)+,1132(a2)

           move.l (a1)+,1280(a2)        ; Ligne 9
           move.l (a1)+,1284(a2)
           move.l (a1)+,1288(a2)
           move.l (a1)+,1292(a2)

           move.l (a1)+,1440(a2)        ; Ligne 10
           move.l (a1)+,1444(a2)
           move.l (a1)+,1448(a2)
           move.l (a1)+,1452(a2)

           move.l (a1)+,1600(a2)        ; Ligne 11
           move.l (a1)+,1604(a2)
           move.l (a1)+,1608(a2)
           move.l (a1)+,1612(a2)

           move.l (a1)+,1760(a2)        ; Ligne 12
           move.l (a1)+,1764(a2)
           move.l (a1)+,1768(a2)
           move.l (a1)+,1772(a2)

           move.l (a1)+,1920(a2)        ; Ligne 13
           move.l (a1)+,1924(a2)
           move.l (a1)+,1928(a2)
           move.l (a1)+,1932(a2)

           move.l (a1)+,2080(a2)        ; Ligne 14
           move.l (a1)+,2084(a2)
           move.l (a1)+,2088(a2)
           move.l (a1)+,2092(a2)

           move.l (a1)+,2240(a2)        ; Ligne 15
           move.l (a1)+,2244(a2)
           move.l (a1)+,2248(a2)
           move.l (a1)+,2252(a2)

i          set i-244
           endr           

; **************************************************************
;
;         -> CALCUL DES COORDONNEES DE CHAQUE BALLE <-
;
; **************************************************************
;
; xb=150+72*cos((dd*xd)+(xv*no))+72*cos(((dd*4)+(gd*no))/2
; yb=90+42*sin((dd*yd)+(yv*no))+42*sin((dd*8)+(gd*no))/2
;

           lea decal,a2                ; a2=table des decalages
           lea cos_tab,a4              ; a4=table des cosinus
           lea cos_tab+720,a5          ; a5=table des sinus
           move.l efface1,a6           ; a6=table des effacements
           moveq #15,d0                ; d0=no=16 balles
           move.w dd,d1                ; d1=dd

; --------------------------------------------------------------
;
;                      -> CALCUL DE XB <-
;
; --------------------------------------------------------------
          
sprite     move.w xd,d2
           move.w xv,d3 

; -------------------------------
; Calcul de angle=(dd*xd)+(no*xv)
; -------------------------------

           mulu d1,d2                  ; d2=(dd*xd)
           mulu d0,d3                  ; d3=(no*xv)
           add.w d2,d3                 ; d3=(dd*xd)+(no*xv)

tst_1      cmp.w #360,d3               ; d3<359 ?
           blt.s non_1                 ; oui, on continue
           sub.w #359,d3               ; d3=d3-359
           bra.s tst_1

non_1      add.w d3,d3                 ; angle*2
           move.w 0(a4,d3.w),d3        ; cos(angle)*128 dans d3

; ----------------------------------
; Calcul de angle=((dd*4)+(gd*no))/2
; ----------------------------------

           move.w d1,d2                ; d2=dd
           move.w gd,d4                ; d4=gd

           asl.w #2,d2                 ; d2=(dd*4)
           move.w d2,d5                ; sauve (dd*4)
           mulu d0,d4                  ; d4=(gd*no)        
           add.w d4,d5                 ; d5=(dd*4)+(gd*no)
           asr.w #1,d5                 ; d5=((dd*4)+(gd*no))/2

tst_2      cmp.w #360,d5
           blt.s non_2
           sub.w #359,d5
           bra.s tst_2

non_2      add.w d5,d5                 ; angle*2
           move.w 0(a4,d5.w),d5        ; d5=cos((dd*4)+(gd*no))/2
          
           add.w d3,d5                 ; d5=abscisse balle

; --------------------------------------------------------------
; 
;                     -> CALCUL DE YB <-
;
; --------------------------------------------------------------

           move.w yd,d6
           move.w yv,d3 
          
           mulu d1,d6                   ; d6=(dd*yd)
           mulu d0,d3                   ; d3=(no*yv)
           add.w d6,d3                  ; d3=(dd*yd)+(no*yv)                  

tst_3      cmp.w #360,d3
           blt.s non_3
           sub.w #360,d3
           bra.s tst_3

non_3      add.w d3,d3
           move.w 0(a5,d3.w),d3
 
           add.w d2,d2
           add.w d2,d4
           asr.w #1,d4       

tst_4      cmp.w #360,d4
           blt.s non_4
           sub.w #359,d4
           bra.s tst_4

non_4      add.w d4,d4
           move.w 0(a5,d4.w),d4

           add.w d3,d4

; -------------
; Coory_b * 160
; -------------

grandy     lea y_tab,a0
           add.w d4,d4
           move.w 0(a0,d4.w),d4

; **************************************************************
;
;               -> AFFICHAGE DES BALLES <-
;
; **************************************************************

           move.l screen1,a1

           move.w d5,d3
           and.w #15,d3                 ; d3=decalage modulo 15
           lsl.w #2,d3                  ; d3 * 4
           move.l 0(a2,d3.w),a0         ; valeur decalage dans d3        
           lsr.w #1,d5                  ; x=x/2
           andi #$f8,d5                 ; and -8
           add.w d5,d4                  ; x+y*160

           add.w d4,a1

; ---< Sauvegarde du fond >---
;
; 244 octets par balle:
;   4 octets : Adresse de la balle a l'ecran
; 240 octets : Sauvegarde du fond
;

           move.l a1,(a6)+   
i          set 0
           rept 15 
           move.l i(a1),(a6)+
           move.l i+4(a1),(a6)+
           move.l i+8(a1),(a6)+
           move.l i+12(a1),(a6)+
i          set i+160
           endr
           
; ---< Affiche la balle >---

i          set 0
           rept 5

           moveq #0,d7
           move.w (a0)+,d2
           move.w (a0)+,d3
           or.w d2,d7
           or.w d3,d7
           not.w d7
           and.w d7,i(a1)
           or.w d2,i(a1)
           and.w d7,i+2(a1)
           or.w d3,i+2(a1)
           and.w d7,i+4(a1)
           and.w d7,i+6(a1)
           
           move.w (a0)+,d4
           move.w (a0)+,d5
           moveq #0,d7
           or.w d4,d7
           or.w d5,d7
           not.w d7
           and.w d7,i+8(a1)
           or.w d4,i+8(a1)
           and.w d7,i+10(a1)
           or.w d5,i+10(a1)
           and.w d7,i+12(a1)
           and.w d7,i+14(a1) 

; --- 2 ---

           moveq #0,d7
           move.w (a0)+,d2
           move.w (a0)+,d3
           move.w (a0)+,d4
           move.w (a0)+,d5
           or.l d2,d7
           or.l d3,d7
           not.w d7
           and.w d7,i+160(a1)
           or.w d2,i+160(a1)
           and.w d7,i+162(a1)
           or.w d3,i+162(a1)
           and.w d7,i+164(a1)
           and.w d7,i+166(a1)


           moveq #0,d7
           or.w d4,d7
           or.w d5,d7
           not.w d7
           and.w d7,i+168(a1)
           or.w d4,i+168(a1)
           and.w d7,i+170(a1)
           or.w d5,i+170(a1)
           and.w d7,i+172(a1)
           and.w d7,i+174(a1)            

; --- 3 ---

           moveq #0,d7
           move.w (a0)+,d2
           move.w (a0)+,d3
           move.w (a0)+,d4
           move.w (a0)+,d5
           or.w d2,d7
           or.w d3,d7
           not.w d7
           and.w d7,i+320(a1)
           or.w d2,i+320(a1)
           and.w d7,i+322(a1)
           or.w d3,i+322(a1)
           and.w d7,i+324(a1)
           and.w d7,i+326(a1)


           moveq #0,d7
           or.w d4,d7
           or.w d5,d7
           not.w d7
           and.w d7,i+328(a1)
           or.w d4,i+328(a1)
           and.w d7,i+330(a1)
           or.w d5,i+330(a1)
           and.w d7,i+332(a1)
           and.w d7,i+334(a1) 

i          set i+480
           endr

           dbra d0,sprite

;
;
;

           addq.w #2,dd
           cmp.w #360,dd
           blt.s flop
           clr.w dd

flop       addq.w #1,faux
           cmp.w #255,faux
           bne.s lets_go
           clr.w faux

lets_go    lea numbers,a0
           lea buf_num+80,a1
           move.w faux,d1 
           asl.w #4,d1
           add.w d1,a0
           movem.l (a0)+,d1-d4
           movem.l d1-d4,(a1)

; -----------
; SWAP ECRANS
; -----------

perm       move.l efface1,d0
           move.l efface2,efface1
           move.l d0,efface2

           move.w eff_inc1,d0
           move.w eff_inc2,eff_inc1
           move.w d0,eff_inc1

           move.l screen1,d0
           move.l screen2,screen1
           move.l d0,screen2

           lsr.l #8,d0
           move.w #$8200,a0
           movep.w d0,1(a0)
           rte


; ***************
;
; SOUS PROGRAMMES
;
; ***************

; ---------------------------
; Affiche tous les parametres
; ---------------------------

params     lea numbers,a0
           lea buf_num,a1

           move.w xd,d1
           asl.w #4,d1
           move.w 0(a0,d1.w),(a1)+
           move.w 2(a0,d1.w),(a1)+
           move.w 4(a0,d1.w),(a1)+
           move.w 6(a0,d1.w),(a1)+
           move.w 8(a0,d1.w),(a1)+
           move.w 10(a0,d1.w),(a1)+
           move.w 12(a0,d1.w),(a1)+
           move.w 14(a0,d1.w),(a1)+

           move.w yd,d1
           asl.w #4,d1
           move.w 0(a0,d1.w),(a1)+
           move.w 2(a0,d1.w),(a1)+
           move.w 4(a0,d1.w),(a1)+
           move.w 6(a0,d1.w),(a1)+
           move.w 8(a0,d1.w),(a1)+
           move.w 10(a0,d1.w),(a1)+
           move.w 12(a0,d1.w),(a1)+
           move.w 14(a0,d1.w),(a1)+

           move.w xv,d1
           asl.w #4,d1
           move.w 0(a0,d1.w),(a1)+
           move.w 2(a0,d1.w),(a1)+
           move.w 4(a0,d1.w),(a1)+
           move.w 6(a0,d1.w),(a1)+
           move.w 8(a0,d1.w),(a1)+
           move.w 10(a0,d1.w),(a1)+
           move.w 12(a0,d1.w),(a1)+
           move.w 14(a0,d1.w),(a1)+

           move.w yv,d1
           asl.w #4,d1
           move.w 0(a0,d1.w),(a1)+
           move.w 2(a0,d1.w),(a1)+
           move.w 4(a0,d1.w),(a1)+
           move.w 6(a0,d1.w),(a1)+
           move.w 8(a0,d1.w),(a1)+
           move.w 10(a0,d1.w),(a1)+
           move.w 12(a0,d1.w),(a1)+
           move.w 14(a0,d1.w),(a1)+

           move.w gd,d1
           asl.w #4,d1
           move.w 0(a0,d1.w),(a1)+
           move.w 2(a0,d1.w),(a1)+
           move.w 4(a0,d1.w),(a1)+
           move.w 6(a0,d1.w),(a1)+
           move.w 8(a0,d1.w),(a1)+
           move.w 10(a0,d1.w),(a1)+
           move.w 12(a0,d1.w),(a1)+
           move.w 14(a0,d1.w),(a1)+

           rts

; ********************
;
; DONNEES ET VARIABLES
;
; ********************

; --- 0 ---
ball       dc.l $7C007C0,$0
           dc.l $1E01FF0,$0
           dc.l $1CE823F0,$0
           dc.l $3EF841F4,$0
           dc.l $3EF441F8,$0
           dc.l $BEF4C1FA,$0
           dc.l $9CF4E3FA,$0
           dc.l $C1F4FFFA,$0
           dc.l $FFF4FFFA,$0
           dc.l $FFECFFF2,$0
           dc.l $7FCC7FF0,$0
           dc.l $4F187FE4,$0
           dc.l $10782F80,$0
           dc.l $FE01010,$0
           dc.l $7C0,$0
; --- 1 ---
           dc.l $3E003E0,$0
           dc.l $F00FF8,$0
           dc.l $E7411F8,$0
           dc.l $1F7C20FA,$0
           dc.l $1F7A20FC,$0
           dc.l $5F7A60FD,$0
           dc.l $4E7A71FD,$0
           dc.l $60FA7FFD,$0
           dc.l $7FFA7FFD,$0
           dc.l $7FF67FF9,$0
           dc.l $3FE63FF8,$0
           dc.l $278C3FF2,$0
           dc.l $83C17C0,$0
           dc.l $7F00808,$0
           dc.l $3E0,$0
; --- 2 ---
           dc.l $1F001F0,$0
           dc.l $7807FC,$0
           dc.l $73A08FC,$0
           dc.l $FBE107D,$0
           dc.l $FBD107E,$0
           dc.l $2FBD307E,$8000
           dc.l $273D38FE,$8000
           dc.l $307D3FFE,$8000
           dc.l $3FFD3FFE,$8000
           dc.l $3FFB3FFC,$8000
           dc.l $1FF31FFC,$0
           dc.l $13C61FF9,$0
           dc.l $41E0BE0,$0
           dc.l $3F80404,$0
           dc.l $1F0,$0
; --- 3 ---
           dc.l $F800F8,$0
           dc.l $3C03FE,$0
           dc.l $39D047E,$0
           dc.l $7DF083E,$8000
           dc.l $7DE083F,$80000000
           dc.l $17DE183F,$80004000
           dc.l $139E1C7F,$80004000
           dc.l $183E1FFF,$80004000
           dc.l $1FFE1FFF,$80004000
           dc.l $1FFD1FFE,$80004000
           dc.l $FF90FFE,$80000000
           dc.l $9E30FFC,$8000
           dc.l $20F05F0,$0
           dc.l $1FC0202,$0
           dc.l $F8,$0
; --- 4 ---
           dc.l $7C007C,$0
           dc.l $1E01FF,$0
           dc.l $1CE023F,$80000000
           dc.l $3EF041F,$80004000
           dc.l $3EF041F,$40008000
           dc.l $BEF0C1F,$4000A000
           dc.l $9CF0E3F,$4000A000
           dc.l $C1F0FFF,$4000A000
           dc.l $FFF0FFF,$4000A000
           dc.l $FFE0FFF,$C0002000
           dc.l $7FC07FF,$C0000000
           dc.l $4F107FE,$80004000
           dc.l $10702F8,$80000000
           dc.l $FE0101,$0
           dc.l $7C,$0
; --- 5 ---
           dc.l $3E003E,$0
           dc.l $F00FF,$8000
           dc.l $E7011F,$40008000
           dc.l $1F7020F,$C000A000
           dc.l $1F7020F,$A000C000
           dc.l $5F7060F,$A000D000
           dc.l $4E7071F,$A000D000
           dc.l $60F07FF,$A000D000
           dc.l $7FF07FF,$A000D000
           dc.l $7FF07FF,$60009000
           dc.l $3FE03FF,$60008000
           dc.l $27803FF,$C0002000
           dc.l $83017C,$C0000000
           dc.l $7F0080,$8000
           dc.l $3E,$0
; --- 6 ---
           dc.l $1F001F,$0
           dc.l $7007F,$8000C000
           dc.l $73008F,$A000C000
           dc.l $FB0107,$E000D000
           dc.l $FB0107,$D000E000
           dc.l $2FB0307,$D000E800
           dc.l $273038F,$D000E800
           dc.l $30703FF,$D000E800
           dc.l $3FF03FF,$D000E800
           dc.l $3FF03FF,$B000C800
           dc.l $1FF01FF,$3000C000
           dc.l $13C01FF,$60009000
           dc.l $4100BE,$E0000000
           dc.l $3F0040,$80004000
           dc.l $1F,$0
; --- 7 ---
           dc.l $F000F,$80008000
           dc.l $3003F,$C000E000
           dc.l $390047,$D000E000
           dc.l $7D0083,$F000E800
           dc.l $7D0083,$E800F000
           dc.l $17D0183,$E800F400
           dc.l $13901C7,$E800F400
           dc.l $18301FF,$E800F400
           dc.l $1FF01FF,$E800F400
           dc.l $1FF01FF,$D800E400
           dc.l $FF00FF,$9800E000
           dc.l $9E00FF,$3000C800
           dc.l $20005F,$F0000000
           dc.l $1F0020,$C0002000
           dc.l $F,$8000
; --- 8 ---
           dc.l $70007,$C000C000
           dc.l $1001F,$E000F000
           dc.l $1C0023,$E800F000
           dc.l $3E0041,$F800F400
           dc.l $3E0041,$F400F800
           dc.l $BE00C1,$F400FA00
           dc.l $9C00E3,$F400FA00
           dc.l $C100FF,$F400FA00
           dc.l $FF00FF,$F400FA00
           dc.l $FF00FF,$EC00F200
           dc.l $7F007F,$CC00F000
           dc.l $4F007F,$1800E400
           dc.l $10002F,$78008000
           dc.l $F0010,$E0001000
           dc.l $7,$C000
; --- 9 ---
           dc.l $30003,$E000E000
           dc.l $F,$F000F800
           dc.l $E0011,$7400F800
           dc.l $1F0020,$7C00FA00
           dc.l $1F0020,$7A00FC00
           dc.l $5F0060,$7A00FD00
           dc.l $4E0071,$7A00FD00
           dc.l $60007F,$FA00FD00
           dc.l $7F007F,$FA00FD00
           dc.l $7F007F,$F600F900
           dc.l $3F003F,$E600F800
           dc.l $27003F,$8C00F200
           dc.l $80017,$3C00C000
           dc.l $70008,$F0000800
           dc.l $3,$E000
; --- 10 ---
           dc.l $10001,$F000F000
           dc.l $7,$7800FC00
           dc.l $70008,$3A00FC00
           dc.l $F0010,$BE007D00
           dc.l $F0010,$BD007E00
           dc.l $2F0030,$BD007E80
           dc.l $270038,$3D00FE80
           dc.l $30003F,$7D00FE80
           dc.l $3F003F,$FD00FE80
           dc.l $3F003F,$FB00FC80
           dc.l $1F001F,$F300FC00
           dc.l $13001F,$C600F900
           dc.l $4000B,$1E00E000
           dc.l $30004,$F8000400
           dc.l $1,$F000
; --- 11 ---
           dc.l $0,$F800F800
           dc.l $3,$3C00FE00
           dc.l $30004,$9D007E00
           dc.l $70008,$DF003E80
           dc.l $70008,$DE803F00
           dc.l $170018,$DE803F40
           dc.l $13001C,$9E807F40
           dc.l $18001F,$3E80FF40
           dc.l $1F001F,$FE80FF40
           dc.l $1F001F,$FD80FE40
           dc.l $F000F,$F980FE00
           dc.l $9000F,$E300FC80
           dc.l $20005,$F00F000
           dc.l $10002,$FC000200
           dc.l $0,$F800
; --- 12 ---
           dc.l $0,$7C007C00
           dc.l $1,$1E00FF00
           dc.l $10002,$CE803F00
           dc.l $30004,$EF801F40
           dc.l $30004,$EF401F80
           dc.l $B000C,$EF401FA0
           dc.l $9000E,$CF403FA0
           dc.l $C000F,$1F40FFA0
           dc.l $F000F,$FF40FFA0
           dc.l $F000F,$FEC0FF20
           dc.l $70007,$FCC0FF00
           dc.l $40007,$F180FE40
           dc.l $10002,$780F800
           dc.l $1,$FE000100
           dc.l $0,$7C00
; --- 13 ---
           dc.l $0,$3E003E00
           dc.l $0,$F00FF80
           dc.l $1,$E7401F80
           dc.l $10002,$F7C00FA0
           dc.l $10002,$F7A00FC0
           dc.l $50006,$F7A00FD0
           dc.l $40007,$E7A01FD0
           dc.l $60007,$FA0FFD0
           dc.l $70007,$FFA0FFD0
           dc.l $70007,$FF60FF90
           dc.l $30003,$FE60FF80
           dc.l $20003,$78C0FF20
           dc.l $1,$83C07C00
           dc.l $0,$7F008080
           dc.l $0,$3E00
; --- 14 ---
           dc.l $0,$1F001F00
           dc.l $0,$7807FC0
           dc.l $0,$73A08FC0
           dc.l $1,$FBE007D0
           dc.l $1,$FBD007E0
           dc.l $20003,$FBD007E8
           dc.l $20003,$73D08FE8
           dc.l $30003,$7D0FFE8
           dc.l $30003,$FFD0FFE8
           dc.l $30003,$FFB0FFC8
           dc.l $10001,$FF30FFC0
           dc.l $10001,$3C60FF90
           dc.l $0,$41E0BE00
           dc.l $0,$3F804040
           dc.l $0,$1F00
; --- 15 ---
           dc.l $0,$F800F80
           dc.l $0,$3C03FE0
           dc.l $0,$39D047E0
           dc.l $0,$7DF083E8
           dc.l $0,$7DE883F0
           dc.l $10001,$7DE883F4
           dc.l $10001,$39E8C7F4
           dc.l $10001,$83E8FFF4
           dc.l $10001,$FFE8FFF4
           dc.l $10001,$FFD8FFE4
           dc.l $0,$FF98FFE0
           dc.l $0,$9E30FFC8
           dc.l $0,$20F05F00
           dc.l $0,$1FC02020
           dc.l $0,$F80

new_pal    dc.w $000,$707,$606,$505,$777,$707,$606,$505
           dc.w $777,$667,$557,$447,$777,$777,$474,$777

stop_mouse dc.b $12
go_mouse   dc.b $8

efface1    ds.l 1
efface2    ds.l 1
efftab1    ds.w 3904
efftab2    ds.w 3904

incr       ds.w 1
eff_inc1   ds.w 1
eff_inc2   ds.w 1 

xd         dc.w 3
yd         dc.w 1
xv         dc.w 1
yv         dc.w $b4
gd         dc.w $12
gv         dc.w 8
dd         dc.w 0
vi         dc.w 2

; ------------------------------------------------------
;
;             COURBES PREDEFINIES F1-F10
;
; ------------------------------------------------------

courbes    dc.w $0A,$0A,$FF,$FF,$FF
           dc.w $05,$04,$12,$10,$16
           dc.w $03,$01,$01,$03,$AE
           dc.w $03,$02,$AE,$08,$02
           dc.w $01,$00,$AB,$A6,$00
           dc.w $00,$03,$AB,$A6,$00
           dc.w $00,$02,$18,$00,$2D
           dc.w $01,$00,$00,$A8,$16
           dc.w $00,$02,$B4,$00,$14
           dc.w $01,$02,$00,$00,$2D

; ------------------------------------------------------
;
;                  TABLE DES DECALAGES
;
; ------------------------------------------------------

decal      dc.l ball,ball+120,ball+240,ball+360,ball+480,ball+600
           dc.l ball+720,ball+840,ball+960,ball+1080,ball+1200
           dc.l ball+1320,ball+1440,ball+1560,ball+1680,ball+1800

; --------------------
;
; Tables des ordonn‚es
;
; --------------------

y_tab:

i          set 0
           rept 200
           dc.w i
i          set i+160
           endr

; ---------
;
; Variables
;
; ---------

adr_big    ds.l 1
save_vbl   ds.l 1
save_hbl   ds.l 1
buf_num    ds.w 6*8
oldrez     ds.w 1
faux       ds.w 1
oldscreen  ds.l 1
oldpal     ds.w 16
conte      ds.w 1
screen1    ds.l 1
screen2    ds.l 1
oldssp     ds.l 1
           ds.l 128
pile       ds.l 1
key        ds.b 1

kay        ds.b 1
cmptr      ds.b 1
save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
savea11    ds.b 1
old118     ds.b 1
           even

cos_tab    incbin "COSIN.TAB"
numbers    incbin "NUMBERS.DAT"
music      incbin "NTM.SND"
fond       incbin "NEPTUNE.PI1"
