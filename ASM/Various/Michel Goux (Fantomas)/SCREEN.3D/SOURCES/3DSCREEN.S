; +-------------------------------------------------+
; |                                                 |
; | 'PIXEL SHOW' (c) 1992 FANTOMAS of BLACK RAINBOW | 
; |     -Sinus & Cosinus pr‚multipli‚s par 256-     |
; |                                                 |
; +-------------------------------------------------+

           opt 	o+

; -----------
;
; Superviseur
;
; -----------

           clr.l 	-(sp)
           move.w 	#$20,-(sp)
           trap 	#1
           addq.l 	#6,sp
           move.l 	d0,save_ssp

; -------
;
; Clavier
;
; -------

           move.b 	$484.w,save_key      ; Save key.
           clr.b 	$484.w                ; key OFF

; ------
;
; Souris
;
; ------
 
           dc.w 	$a00a                            ; Mouse OFF
           move.b 	#$12,$fffffc02.w

; ----------------
; Sauve la palette
; ----------------

           lea 	$ff8240,a0
           lea 	save_pal,a1
           movem.l 	(a0),d0-d7                    ; Save colors
           movem.l 	d0-d7,(a1)                 
            
; ----------------
;
; Sauve resolution
;
; ----------------

           move.w 	#4,-(sp)
           trap 	#14
           addq.l 	#2,sp
           move.w 	d0,save_rez                    ; Save rez.

; ------------
;
; Ancien ecran
;
; ------------

           move.w 	#2,-(sp)
           trap 	#14
           addq.l 	#2,sp
           move.l 	d0,save_scr                    ; Save scr.

; ---------------
;
; Nouveaux ecrans
;
; ---------------

           move.l 	#$70000,screen1                ; New scr_1
           move.l 	#$77d00,screen2                ; New scr_2

           clr.w 	-(sp)
           move.l 	#-1,-(sp)
           move.l 	#-1,-(sp)
           move.w 	#5,-(sp)
           trap 	#14
           add.l 	#12,sp

; ------------
; Tout en noir
; ------------
	
	lea 	$ffff8240.w,a0
	moveq	#7,d0
next	clr.w	(a0)+
	dbra 	d0,next

; ----------------
; Basse resolution
; ----------------

           clr.w 	-(sp)
           move.l 	#-1,-(sp)
           move.l 	#-1,-(sp)
           move.w 	#5,-(sp)
           trap 	#14

; ---------------
; Affiche le LOGO
; ---------------

           lea 		fond,a0    
	   lea 		34(a0),a0
;          move.l 	screen1,a1
;	   bsr		depack

   	   move.l	screen1,a1
           move.l 	screen2,a2
           move.w 	#7999,d0
boucle1    move.l 	(a0),(a1)+
	   move.l	(a0)+,(a2)+
           dbra 	d0,boucle1

; ----------------
; Nouvelle palette
; ----------------

	lea 	new_pal,a0
	lea	$ffff8240.w,a1
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,(a1)

; -------
; Musique
; -------

          moveq #1,d0
          bsr music1
           
; -----------
; Init Divers
; -----------

           move.w #12,incx
           move.w #159,centrx
           move.w #99,centry
           move.l #obj_lst,adr_lst
           move.l #cercle,adr_obj

           move.w #40*160,decal
           move.l #txt,ptr

           move.l #eff_1,efface1
           move.l #eff_2,efface2
           move.l efface1,a0
           move.l efface2,a1
           move.l screen1,a2
           move.w #359,d0
blouk      move.l a2,(a0)+
           move.l a2,(a1)+
           dbra d0,blouk

; ----------------
;
; Timers & synchro
;
; ----------------

           move.b $fffa07,save_iera
           move.b $fffa09,save_ierb
           move.b $fffa13,save_imra
           move.b $fffa11,save_isrb
           move.b $fffa17,save_vect
           move.l $70.w,save_vbl
           move.l $120.w,save_hbl
           move.l $118.w,save_118
           and.b #0,$fffa07
           and.b #$40,$fffa09
           bclr.b #3,$fffa17
           or.b #1,$fffa07
           or.b #1,$fffa13
           move.l #vbl,$70.w           
           move.l #newkey,$118.w

; ************************************************************** 
;
;                 Teste si fin premiere partie
;
; **************************************************************

loop0      cmpi.b #$39,$ffffc02
           bne.s loop0
loop1      cmpi.b #$39+$80,$ffffc02
           bne.s loop1

; --------------------------------------------------------------
;
;               Initialisations seconde partie
;
; --------------------------------------------------------------

           clr.b 	$fffffa1b.w           ; Stoppe Timer B
				
           move.l 	save_vbl,$70.w        ; Restore VBL

           move.b 	#8,$ffff8800.w        ; Sound OFF
           move.b 	#0,$ffff8802.w
           move.b 	#9,$ffff8800.w
           move.b 	#0,$ffff8802.w
           move.b 	#$a,$ffff8800.w
           move.b 	#0,$ffff8802.w

           move.l 	screen1,a0            ; Efface les ecrans
           move.l 	screen2,a1
           move.w 	#7999,d0
eff_scr    clr.l 	(a0)+
           clr.l 	(a1)+
           dbra 	d0,eff_scr

           moveq 	#1,d0                 ; Init music 2
	   jsr 		music2

	   move.w 	#4,cmpt_vbl
           move.w 	#-100,centrx          ; Init divers
           move.w 	#99,centry
           clr.w 	anim
           move.w	#42,adr_obj
           move.l 	#rebond,adr_y
           move.l 	#txt2-1,ptr
           move.w 	#$707,$ffff8244.w
           move.w 	#$707,$ffff8246.w
           move.l 	#vbl2,$70.w          ; Lance partie 2

; ************************************************************** 
;
;                 Teste si fin seconde partie
;
; **************************************************************

loop2      cmpi.b 	#$39,$fffffc02.w
           bne.s 	loop2
loop3      cmpi.b 	#$39+$80,$fffffc02.w
           bne.s 	loop3

; **************************************************************
;
;                       FIN DU PROGRAMME
;
; **************************************************************

; ------
;
; Timers
;
; ------

           move.b 	save_iera,$fffffa07.w
           move.b 	save_ierb,$fffffa09.w
           move.b 	save_imra,$fffffa13.w
           move.b 	save_isrb,$fffffa11.w
           move.b 	save_vect,$fffffa17.w
           move.l 	save_vbl,$70.w
           move.l 	save_hbl,$120.w
           move.l 	save_118,$118.w
           
; -----------
;
; Chip sonore
;
; -----------
				
           move.b 	#8,$ffff8800.w        ; Sound OFF
           move.b 	#0,$ffff8802.w
           move.b 	#9,$ffff8800.w
           move.b 	#0,$ffff8802.w
           move.b 	#$a,$ffff8800.w
           move.b 	#0,$ffff8802.w

; --------------------
;
; Resolution et ecrans
;
; --------------------
        
           move.w 	save_rez,-(sp)
           move.l 	save_scr,-(sp)
           move.l 	save_scr,-(sp)
           move.w 	#5,-(sp)
           trap 	#14
           add.l 	#12,sp           

; -------
;
; Palette
;
; -------
          				
           lea 		save_pal,a0           ; Restore pal.
           move.l 	#$ff8240,a1
           movem.l 	(a0)+,d0-d7
           movem.l 	d0-d7,(a1)

; ------
;
; Souris
;
; ------
 				
           move.b 	#$8,$fffffc02.w       ; Mouse ON
           dc.w 	$a009

; -------
;
; Clavier
;
; -------
  
           move.b 	save_key,$484.w        ; Key ON

; -----------
;
; Utilisateur
;
; -----------

           move.l 	save_ssp,-(sp)
           move.w 	#$20,-(sp)
           trap 	#1
           addq.l	#6,sp

; -------------
;
; Retour au DOS
;
; -------------
				
           clr.w 	-(sp)                 ; PTERM
           trap 	#1


; **************************************************************
;
;                      PROGRAMME PRINCIPAL
;
; **************************************************************

vbl        bsr 		permute
 
           lea 		new_pal,a0
           movem.l 	(a0)+,d0-d7
           movem.l 	d0-d7,$ffff8240.w

           clr.b 	$fffffa1b.w
           move.b 	#2,$fffffa21.w

           lea 		rasters,a3
           move.w 	#18,conte
           move.l 	#hbl1,$120.w
           move.b 	#8,$fffffa1b.w

; --------------------------------------------------------------
;
;                MUSIQUE & LEDS DES LECTEURS 
;
; --------------------------------------------------------------

           move.l 	a3,-(sp)
           bsr 		music1+8
           move.l 	(sp)+,a3

           move.l 	screen1,a1
           lea 		$ffff8800.w,a0
           moveq 	#0,d0
           moveq 	#0,d1
           move.w 	#30,d2
           move.w 	d2,d3
	   move.w	d2,d4

           move.b 	#8,(a0)
           move.b 	(a0),d0
           cmp.w 	#16,d0
           blt.s 	voiea
           move.w 	#15,d0

voiea      add.w 	d0,d0
           sub.w 	d0,d4
           lea 		vu_meter,a2
           add.w 	d4,a2
i          set 		0
           rept 	15    
           move.w 	(a2),i+320+2(a1)
           move.w 	(a2)+,i+320+154(a1)
i          set 		i+320
           endr

           move.l	screen1,a1
           move.b 	#9,(a0)
           move.b 	(a0),d0
           cmp.w 	#16,d0
           blt.s 	voieb
           move.w 	#15,d0

voieb      add.w 	d0,d0
           sub.w 	d0,d2
           lea 		vu_meter,a2
           add.w 	d2,a2
i          set 		0
           rept 	15    
           move.w 	(a2),i+320+10(a1)
           move.w 	(a2)+,i+320+146(a1)
i          set 		i+320
           endr

           move.l 	screen1,a1
           move.b 	#10,(a0)
           move.b 	(a0),d1
           cmp.w 	#15,d1
           blt.s 	voiec
           move.w 	#15,d1

voiec      add.w 	d1,d1
           sub.w 	d1,d3
           lea 		vu_meter,a2
           add.w 	d3,a2
i          set 		0
           rept 	15
           move.w 	(a2),i+320+18(a1)
           move.w 	(a2)+,i+320+138(a1)
i          set 		i+320
           endr

; --------------------------------------------------------------
;
;                        SCROLLTEXT 8x8
;
; --------------------------------------------------------------

           move.w 	bit,d0
           cmp.w 	#8,d0
           bne.s 	plusloin3
           clr.w 	bit
           move.l 	ptr,a1
           move.b 	(a1),d0
           cmp.b 	#255,d0
           bne.s 	lsuite
           move.l 	#txt,ptr
           move.l 	ptr,a1
           move.b 	(a1),d0
lsuite     addq.l 	#1,ptr
           asl.l 	#3,d0
           lea 	font,a1
           add.l 	d0,a1
           lea 	buffer,a2

; -------------------
;
; Caractere -> Buffer
;
; -------------------

i          set 	0
           rept 	7
           move.b 	(a1)+,i(a2)
i          set 	i+2
           endr

plusloin3  addq.w 	#1,bit

; ------------------------------
;
; Buffer + petit scroll a gauche
;
; ------------------------------

           lea 	trav+80,a1
           lea 	buffer,a2
i          set 	0
           rept	 7
           roxl 	(a2)+
           roxl 	i+38(a1)
           roxl 	i+36(a1)
           roxl 	i+34(a1)
           roxl 	i+32(a1)
           roxl 	i+30(a1)
           roxl 	i+28(a1)
           roxl 	i+26(a1)
           roxl 	i+24(a1)
           roxl 	i+22(a1)
           roxl 	i+20(a1)
           roxl 	i+18(a1)
           roxl 	i+16(a1)
           roxl 	i+14(a1)
           roxl 	i+12(a1)
           roxl 	i+10(a1)
           roxl 	i+8(a1)
           roxl 	i+6(a1)
           roxl 	i+4(a1)
           roxl 	i+2(a1)
           roxl 	i(a1)
i          set 	i+40
           endr

; ----------------
;
; Travail -> Ecran
;
; ----------------

bas        tst.w 	sens
           bne.s 	haut
           add.w 	#160,decal
           cmp.w 	#150*160,decal      
           bne.s 	aff_scr
           move.w 	#1,sens
           bra.s 	aff_scr

haut       sub.w 	#160,decal
           cmp.w 	#40*160,decal
           bne.s 	aff_scr
           clr.w 	sens
           
aff_scr    move.l 	screen1,a1
           add.w 	decal,a1
           lea 	trav,a2
i          set 	0
           rept 	11
           move.w 	(a2)+,i+2(a1)
           move.w 	(a2)+,i+10(a1)
           move.w 	(a2)+,i+18(a1)
           move.w 	(a2)+,i+26(a1)
           move.w 	(a2)+,i+34(a1)
           move.w 	(a2)+,i+42(a1)
           move.w 	(a2)+,i+50(a1)
           move.w 	(a2)+,i+58(a1)
           move.w 	(a2)+,i+66(a1)
           move.w 	(a2)+,i+74(a1)
           move.w 	(a2)+,i+82(a1)
           move.w 	(a2)+,i+90(a1)
           move.w 	(a2)+,i+98(a1)
           move.w 	(a2)+,i+106(a1)
           move.w 	(a2)+,i+114(a1)
           move.w 	(a2)+,i+122(a1)
           move.w 	(a2)+,i+130(a1)
           move.w 	(a2)+,i+138(a1)
           move.w 	(a2)+,i+146(a1)
           move.w 	(a2)+,i+154(a1)
i          set 	i+160
           endr

; ------------------------
;
; Variables scrolltext 8x8
;
; ------------------------

          section bss

ptr       	ds.l 	1
decal     	ds.w 	1
sens      	ds.w 	1
bit       	ds.w 	1
buffer    	ds.w 	8

          section data

trav    dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      	dc.w 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

txt       	dc.b 	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,255
          	even
font      	incbin 	"FONT_8X8.DAT"

          	section text

; --------------------------------------------------------------
;
;                       ANIMATION OBJETS
;
; --------------------------------------------------------------

; -----------------
; Efface les points
; -----------------

           move.l 	efface1,a0
           rept 	119
           move.l 	(a0)+,a1
           clr.w 	(a1)
           endr
 
; ------------------
; D‚placement objets
; ------------------

obj_gau    tst.w 	senx 
           bne.s 	obj_dro
           subq.w 	#1,centrx
           cmp.w 	#80,centrx
           bne.s 	obj_hau
           move.w 	#1,senx

obj_dro    addq.w 	#1,centrx
           cmp.w 	#238,centrx
           bne.s 	obj_hau
           clr.w 	senx
           
obj_hau    tst.w 	seny
           bne.s 	obj_bas
           subq.w 	#1,centry
           cmp.w 	#89,centry
           bne.s 	animat0
           move.w 	#1,seny

obj_bas    addq.w 	#1,centry
           cmp.w 	#109,centry
           bne.s 	animat0
           clr.w 	seny

; ---------------------------
;
; Rotation en X et apparition
;
; ---------------------------

animat0    tst.w 	anim
           bne.s 	animat1
           addq.w 	#1,time
           cmp.w 	#6,time
           bne 	pas_fini
           clr.w 	time
           add.w 	#$111,fond+4
           sub.w 	#$110,palet2
           addq.w 	#1,incc
           cmp.w 	#7,incc
           bne 	pas_fini
           move.w 	#1,anim

; -------------
;
; Rotation en X
;
; -------------

animat1    cmp.w 	#1,anim
           bne.s 	animat2
           addq.w 	#1,time
           cmp.w 	#20,time
           bne 	pas_fini
           clr.w 	time
           move.w	#2,anim
           clr.w 	incx
           move.w 	#6,incy

; -------------
;
; Rotation en Y
;
; -------------

animat2    cmp.w 	#2,anim
           bne.s 	animat3
           addq.w 	#1,time
           cmp.w 	#600,time
           bne 	pas_fini
           clr.w 	time
           move.w 	#3,anim
           clr.w 	incy
           move.w 	#6,incz

; ------------- 
;
; Rotation en Z
;
; -------------

animat3    cmp.w 	#3,anim
           bne.s 	animat4
           addq.w 	#1,time
           cmp.w 	#600,time
           bne 	pas_fini
           clr.w 	time
           move.w 	#4,anim
           move.w 	#8,incx
           move.w 	#12,incy

; -------------------
;
; Rotation en X, Y, Z
;
; -------------------

animat4    cmp.w 	#4,anim
           bne.s 	animat5
           addq.w 	#1,time
           cmp.w 	#300,time
           bne 	pas_fini
           clr.w 	time
           move.w 	#5,anim

; ---------------------------------
;
; Rotation en X, Y, Z & disparition
;
; ---------------------------------

animat5    addq.w 	#1,time
           cmp.w 	#6,time
           bne.s 	pas_fini
           clr.w 	time
           sub.w 	#$111,fond+4
           add.w 	#$110,palet2
           subq.w 	#1,incc
           tst.w 	incc
           bne.s 	pas_fini

; ------------------
;
; Changement d'objet
;
; ------------------
 
           move.l 	adr_lst,a1
           addq.l 	#4,a1
           cmp.l 	#cercle,a1
           bne.s 	next_obj
           move.l 	#obj_lst,a1
next_obj   move.l 	a1,adr_lst
           move.l 	(a1),adr_obj
           clr.l 	angle_x
           clr.w 	angle_z
           clr.w 	anim
           move.w 	#1,time
           move.w 	#12,incx
           clr.l 	incy

; --------------------------------------------------------------
;
;                      CALCUL OBJETS 3D
;
; --------------------------------------------------------------

pas_fini   move.w 	incx,d1
           move.w 	incy,d2
           move.w 	incz,d3
           add.w 	d1,angle_x
           add.w 	d2,angle_y
           add.w 	d3,angle_z

; -------------------
;
; Test angles X, Y, Z
;
; -------------------

           cmp.w 	#718,angle_x
           blt.s 	test1
           sub.w 	#718,angle_x
test1      cmp.w 	#718,angle_y
           blt.s 	test2
           sub.w 	#718,angle_y     
test2      cmp.w 	#718,angle_z
           blt.s 	fin_test
           sub.w 	#718,angle_z

; -------------------------------------------------------------------
;
;
;              CALCUL ET AFFICHAGE DES DIFFERENTS OBJETS
;
;
; -------------------------------------------------------------------

fin_test   lea 	cosin,a0              ; a0 = table des cosinus
           lea 	cosin+720,a1          ; a1 = table des sinus
           move.l 	adr_obj,a4            ; a4 = Objet a afficher
           move.l 	efface1,a6            ; a6 = Adresses a effacer
				
           move.w 	(a4)+,d5              ; (Nbre de points/2)-1 dans d5

calcul     move.w 	(a4)+,d0              ; x dans d0
           move.w 	(a4)+,d1              ; y dans d1
           move.w 	(a4)+,d2              ; z dans d2

; -------------------------------
;
; CALCUL DE LA ROTATION SUIVANT X
;
;  y = y * cos(ax) - z * sin(ax)
;  z = y * sin(ax) + z * cos(ax)
;
; -------------------------------

           move.w 	angle_x,d7            ; ax dans d7
           move.w 	(a0,d7.w),d6          ; Cos(ax) dans d7
           move.w 	(a1,d7.w),d7          ; Sin(ax) dans d7
           move.w 	d1,d3                 ; Sauve y dans d3
           move.w 	d2,d4                 ; Sauve z dans d4
           muls 	d6,d1                 ; y * cos(ax)
           muls 	d7,d4                 ; z * sin(ax)
           sub.w 	d4,d1                 ; y * cos(ax) - z * sin(ax)
           asr.w 	#8,d1                 ; /256 = y
           muls 	d7,d3                 ; y * sin(ax)
           muls 	d6,d2                 ; z * cos(ax)
           add.w 	d3,d2                 ; y * sin(ax) + z * cos(ax)
           asr.w 	#8,d2                 ; /256 = 7
				
; -------------------------------
;
; CALCUL DE LA ROTATION SUIVANT Y
;
;  x = x * cos(ay) + z * sin(ay)
;
; -------------------------------

           move.w 	angle_y,d7            ; ay dans d7
           move.w 	(a0,d7.w),d6          ; Cos(ay) dans d6
           move.w 	(a1,d7.w),d7          ; Sin(ay) dans d7
           muls 	d6,d0                 ; x * cos(ay)
           muls 	d7,d2                 ; z * sin(ay)
           sub.w 	d2,d0                 ; x * cos(ay) - z * sin(ay)
           asr.w 	#8,d0                 ; /256 = x
				
; -------------------------------
;
; CALCUL DE LA ROTATION SUIVANT Z
;
;  x = x * cos(az) - y * sin(az)
;  y = x * sin(az) + y * cos(az)
;
; -------------------------------

           move.w 	angle_z,d7            ; az dans d7
           move.w 	(a0,d7.w),d6          ; Cos(az) dans d6
           move.w 	(a1,d7.w),d7          ; sin(az) dans d7
           move.w 	d0,d3                 ; Sauve x dans d3
           move.w 	d1,d4                 ; Sauve y dans d4
           muls 	d6,d0                 ; x * cos(az)
           muls 	d7,d4                 ; y * sin(az)
           sub.w 	d4,d0                 ; x * cos(az) - y * sin(az)
           asr.w 	#8,d0                 ; /256 = x
           muls 	d7,d3                 ; x * sin(az) 
           muls 	d6,d1                 ; y * cos(az)
           add.w 	d3,d1                 ; x * sin(az) + y * cos(az)
           asr.w 	#8,d1                 ; /256 = y
				
; ---------------------
;
; Centrage dans l'ecran
;
; ---------------------

           add.w 	centrx,d0             ; x = x + centrx
           add.w 	centry,d1             ; y = y + centry
				
; ----------------
;
; Affiche le point
;
; ----------------

           move.l 	screen1,a5            ; Adresse ecran dans a5
           lea 	pos_y,a2              ; a2 = table des positions en y
           add.w 	d1,d1                 ; y * 2
           adda.w 	(a2,d1.w),a5          ; Position verticale du point
           lea 	pos_x,a2              ; a2 = table des positions en x
           add.w 	d0,d0                 ; x * 2
           add.w 	d0,d0                 ; x * 2
           adda.w 	(a2,d0.w),a5          ; a5 = adresse d'affichage du point
           move.l 	a5,(a6)+              ; Sauve a5 pour l'effacage
           move.w 	2(a2,d0.w),d1         ; Motif du point dans d1  
           or.w 	d1,(a5)               ; On l'affiche
				
; --------------------------------------------------------------
;
; On repete une fois, ce qui permet d'eviter (Nbr points/2) DBRA
;
; --------------------------------------------------------------

           move.w 	(a4)+,d0              ; x dans d0
           move.w 	(a4)+,d1              ; y dans d1
           move.w 	(a4)+,d2              ; z dans d2

; -------------------------------
;
; CALCUL DE LA ROTATION SUIVANT X
;
;  y = y * cos(ax) - z * sin(ax)
;  z = y * sin(ax) + z * cos(ax)
;
; -------------------------------

           move.w angle_x,d7           ; ax dans d7
           move.w (a0,d7.w),d6         ; Cos(ax) dans d7
           move.w (a1,d7.w),d7         ; Sin(ax) dans d7
           move.w d1,d3                ; Sauve y dans d3
           move.w d2,d4                ; Sauve z dans d4
           muls d6,d1                  ; y * cos(ax)
           muls d7,d4                  ; z * sin(ax)
           sub.w d4,d1                 ; y * cos(ax) - z * sin(ax)
           asr.w #8,d1                 ; /256 = y
           muls d7,d3                  ; y * sin(ax)
           muls d6,d2                  ; z * cos(ax)
           add.w d3,d2                 ; y * sin(ax) + z * cos(ax)
           asr.w #8,d2                 ; /256 = 7

; -------------------------------
;
; CALCUL DE LA ROTATION SUIVANT Y
;
;  x = x * cos(ay) + z * sin(ay)
;
; -------------------------------

           move.w angle_y,d7           ; ay dans d7
           move.w (a0,d7.w),d6         ; Cos(ay) dans d6
           move.w (a1,d7.w),d7         ; Sin(ay) dans d7
           muls d6,d0                  ; x * cos(ay)
           muls d7,d2                  ; z * sin(ay)
           sub.w d2,d0                 ; x * cos(ay) - z * sin(ay)
           asr.w #8,d0                 ; /256 = x

; -------------------------------
;
; CALCUL DE LA ROTATION SUIVANT Z
;
;  x = x * cos(az) - y * sin(az)
;  y = x * sin(az) + y * cos(az)
;
; -------------------------------

           move.w angle_z,d7           ; az dans d7
           move.w (a0,d7.w),d6         ; Cos(az) dans d6
           move.w (a1,d7.w),d7         ; sin(az) dans d7
           move.w d0,d3                ; Sauve x dans d3
           move.w d1,d4                ; Sauve y dans d4
           muls d6,d0                  ; x * cos(az)
           muls d7,d4                  ; y * sin(az)
           sub.w d4,d0                 ; x * cos(az) - y * sin(az)
           asr.w #8,d0                 ; /256 = x
           muls d7,d3                  ; x * sin(az) 
           muls d6,d1                  ; y * cos(az)
           add.w d3,d1                 ; x * sin(az) + y * cos(az)
           asr.w #8,d1                 ; /256 = y

; ---------------------
;
; Centrage dans l'ecran
;
; ---------------------

           add.w centrx,d0             ; x = x + centrx
           add.w centry,d1             ; y = y + centry

; ----------------
;
; Affiche le point
;
; ----------------

           move.l screen1,a5           ; Adresse ecran dans a5
           lea pos_y,a2                ; a2 = table des positions en y
           add.w d1,d1                 ; y * 2
           adda.w (a2,d1.w),a5         ; Position verticale du point
           lea pos_x,a2                ; a2 = table des positions en x
           add.w d0,d0                 ; x * 2
           add.w d0,d0                 ; x * 2
           adda.w (a2,d0.w),a5         ; a5 = adresse d'affichage du point
           move.l a5,(a6)+             ; Sauve a5 pour l'effacage
           move.w 2(a2,d0.w),d1        ; Motif du point dans d1  
           or.w d1,(a5)                ; On l'affiche

           dbra d5,calcul              ; Point suivant ...

           rte

; ***************************************************************
;
;
;
;
;
; ***************************************************************

vbl2       bsr permute
           jsr music2+8

           section data
music2     incbin "zik\cool.thk"
           section text
  
; ***************************************************************
; Affichage du texte
; ***************************************************************

           subq.w 	#1,cmpt_vbl
           bne 		curseur
           move.w 	#4,cmpt_vbl

           moveq 	#0,d0

; ---< Pointeur texte >---

           addq.l 	#1,ptr               ; + 1
           move.l 	ptr,a0               ; Sauve a0

; ---< Teste si caractere ou code >---

           move.b 	(a0),d0              ; Code ou caract dans d0

; ---------------------------------------------------------------
; Retour en debut de texte 
; ---------------------------------------------------------------

           cmp.b 	#$fd,d0
           bne.s 	deb_lig
           move.l 	#txt2-1,ptr
           move.w	#42,adr_obj
           bra 		curseur

; ---------------------------------------------------------------
; Retour en debut de ligne
; ---------------------------------------------------------------
   
deb_lig    cmp.b 	#$ff,d0               ; Debut de ligne ?
           bne.s 	pas_deb

           move.l 	screen1,a2     
           move.l 	screen2,a3     
           add.w 	adr_obj,a2
           add.w 	adr_obj,a3

i          set 	0
           rept 	7
           clr.b 	i(a2)
           clr.b 	i(a3)
i          set 	i+160
           endr
	
           add.w 	#80+8*160,adr_obj
           clr.w 	anim
           bra	 	curseur

pas_deb	   cmp.b	#$fe,d0
	   bne.s 	caract
           move.l 	screen1,a2     
           move.l 	screen2,a3     
           add.w 	adr_obj,a2
           add.w 	adr_obj,a3

i          set 	0
           rept 	7
           clr.b 	i(a2)
           clr.b 	i(a3)
i          set 	i+160
           endr

	   move.w	#42,adr_obj
	   clr.w	anim
	   bra.s 	curseur
           			
; ---------------------------------------------------------------
; Adresse du caractere a afficher
; ---------------------------------------------------------------

caract     asl.w 	#3,d0                 ; valeur * 8
           lea 		font,a0               ; Adresse de la fonte
           add.w 	d0,a0                 ; a0= adr caractere

; ---------------------------------------------------------------
; Caractere -> Ecran
; ---------------------------------------------------------------

           move.l 	screen1,a2	           
           move.l 	screen2,a3     
           add.w 	adr_obj,a2
           add.w 	adr_obj,a3

i          set 	0
           rept 	7
           move.b 	(a0),i(a2)
           move.b 	(a0)+,i(a3)
i          set 	i+160
           endr
           
; ---------------------------------------------------------------
; Adresse ecran du prochain caractere a afficher
; ---------------------------------------------------------------

           tst.w 	anim
           bne.s 	loc1
           move.b 	#1,anim
           addq.w 	#1,adr_obj           
           bra.s 	curseur
loc1       clr.w 	anim
           addq.w 	#7,adr_obj
    
; ---------------------------------------------------------------
; Gestion du curseur
; ---------------------------------------------------------------

curseur	   lea		font+37*8,a0
	   move.l 	screen1,a2     
           move.l 	screen2,a3     
           add.w 	adr_obj,a2
           add.w 	adr_obj,a3

i          set 	0
           rept 	7
           move.b 	(a0),i(a2)
i          set 	i+160
           endr

; -----------------
; Donnees pour txt2
; -----------------


           section data

cmpt_vbl   dc.w 2

; ------------------------------
; $fd = fin du texte
; $fe = retour en debut de ligne
; ------------------------------ 

;          ---< Page 1 >---

txt2       dc.b 34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,02,17,04,03,08,19,18,29,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,34,34,34,34,34,34,34,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,40,42,14,14,14,44,02,14,03,04,44,01,24,29,44,44,44,$ff
           dc.b 44,44,44,44,34,44,05,00,13,19,14,12,00,18,44,34,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 06,17,00,15,07,08,23,44,03,04,18,08,06,13,04,03,44,01,24,29,$ff
           dc.b 44,44,44,44,34,44,05,00,13,19,14,12,00,18,44,34,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,12,20,18,00,23,44,02,14,12,15,14,18,04,03,44,01,24,29,44,$ff
           dc.b 44,44,44,44,44,34,44,12,27,44,12,00,23,44,34,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 18,02,17,14,11,19,23,19,44,22,17,08,19,19,04,13,44,01,24,29,$ff
           dc.b 44,44,44,34,44,17,27,44,14,02,19,14,01,04,17,44,34,44,44,44,$ff
           dc.b 44,44,44,44,34,44,05,00,13,19,14,12,00,18,44,34,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 05,08,11,04,44,22,00,18,44,15,00,02,10,04,03,44,22,08,19,07,$ff
           dc.b 44,44,44,44,34,44,15,00,02,10,44,08,02,04,44,34,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,$fe

;          ---< Page 2 >---

           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,19,07,04,44,14,01,09,04,02,19,44,01,04,07,08,13,03,$ff
           dc.b 19,07,08,18,44,19,04,23,19,44,02,14,13,18,08,18,19,44,14,05,$ff
           dc.b 37,40,14,44,15,14,08,13,19,18,44,02,00,11,02,20,11,04,03,44,$ff
           dc.b 08,13,44,17,04,00,11,44,19,08,12,04,27,27,27,27,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,44,$ff
           dc.b 44,44,44,11,04,19,33,18,44,22,17,00,15,27,27,27,27,44,44,44,$ff
           dc.b $fd
           even
           
           section text

; ------------------
; D‚placement objets
; ------------------

obj_g      tst.w senx 
           bne.s obj_d
           subq.w #1,centrx
           cmp.w #80,centrx
           bgt.s obj_h
           move.w #1,senx

obj_d      addq.w #1,centrx
           cmp.w #220,centrx
           blt.s obj_h
           clr.w senx
           
obj_h      move.l adr_y,a0
           lea 2(a0),a0
           cmp.l #save_iera,a0
           bne.s shmol
           lea rebond,a0
shmol      move.l a0,adr_y
           move.w (a0),d0
           add.w d0,centry

; --------------------------------------------------------------
;
;                       ANIMATION OBJETS
;
; --------------------------------------------------------------

; -----------------
; Efface les points
; -----------------

toto       move.l efface1,a0
           rept 360
           move.l (a0)+,a1
           clr.w (a1)
           endr
 
; --------------------------------------------------------------
;
;                      CALCUL OBJETS 3D
;
; --------------------------------------------------------------

           addq.w 	#4,angle_y

tst1       cmp.w 	#718,angle_y
           blt.s 	tst2
           sub.w 	#718,angle_y

tst2       lea 		pos_y,a2
           lea 		pos_x,a3
           lea 		big_sphere,a4
           move.l 	efface1,a6
           moveq 	#8,d3
           move.w 	(a4)+,d5

; --- Sinus & Cosinus de angle_y ---

	   lea 		cosin,a0		; a0 = table des Cosinus
           lea 		cosin+720,a1		; a1 = table des Sinus
           move.w 	angle_y,d7        	; Angle dans d7
           move.w 	(a0,d7.w),d6      	; Cos(angle) dans d6
           move.w 	(a1,d7.w),d7      	; Sin(angle) dans d7

; --- Adresse de l'ecran logique ---

	move.l	screen1,a0		; a0 = ecran logique

; ***************************************************************
;
; CALCUL DE LA ROTATION DES 360 POINTS SUIVANT L'AXE DES Y
;
; ***************************************************************

calc:

; ***************************************************************
; Point no 1: transfert de x, y, z dans d0 - d1 - d2 
; ***************************************************************

	   move.w 	(a4)+,d0		; x dans d0
           move.w 	(a4)+,d1		; y dans d1
           move.w 	(a4)+,d2		; z dans d2

; ---------------------------------------------------------------
; Calcul de la rotation suivant y : x=x*cos(ay)+z*sin(ay)
; ---------------------------------------------------------------

           muls 	d6,d0		; x*cos(ay)
           muls 	d7,d2		; z*sin(ay)
           sub.w 	d2,d0		; x*cos(ay)+z*sin(ay)
           asr.w 	d3,d0		; /256

; ---------------------------------------------------------------
; Centrage dans l'ecran 
; ---------------------------------------------------------------

           add.w 	centrx,d0		; x=x+centrx
           blt.s 	no2		; si x<0 va en no2
           add.w 	centry,d1		; y=y+centry

; ---------------------------------------------------------------
; Affiche le point 
; ---------------------------------------------------------------

           move.l 	a0,a5		; Adresse ecran -> a5
           add.w 	d1,d1		; y*2
           adda.w 	(a2,d1.w),a5	; a5=a5+y*160
           add.w 	d0,d0		; x*2
           add.w 	d0,d0		; x*2
           adda.w 	(a3,d0.w),a5	; a5=a5+x
           move.w 	2(a3,d0.w),d1	; d1=motif du point
           move.l 	a5,(a6)+		; Sauve a5
           or.w 	d1,(a5)		; Affiche le point

; ---- La meme routine en 68030 ----

;	move.l	a0,a5
;	adda.w	(a2,d1.w*2),a5
;	adda.w	(a3,d0.w*4),a5
;	move.w	2(a3,d0.w*4),d1
;	move.l	a5,(a6)+
;	or.w	d1,a5	

; ***************************************************************
; Point no 2: transfert de x, y, z dans d0 - d1 - d2 
; ***************************************************************

no2	   move.w 	(a4)+,d0		; x dans d0
           move.w 	(a4)+,d1		; y dans d1
           move.w 	(a4)+,d2		; z dans d2

; ---------------------------------------------------------------
; Calcul de la rotation suivant y : x=x*cos(ay)+z*sin(ay)
; ---------------------------------------------------------------

           muls 	d6,d0		; x*cos(ay)
           muls 	d7,d2		; z*sin(ay)
           sub.w 	d2,d0		; x*cos(ay)+z*sin(ay)
           asr.w 	d3,d0		; /256

; ---------------------------------------------------------------
; Centrage dans l'ecran 
; ---------------------------------------------------------------

           add.w 	centrx,d0		; x=x+centrx
           blt.s 	no3		; si x<0 va en no2
           add.w 	centry,d1		; y=y+centry

; ---------------------------------------------------------------
; Affiche le point 
; ---------------------------------------------------------------

           move.l 	a0,a5		; Adresse ecran -> a5
           add.w 	d1,d1		; y*2
           adda.w 	(a2,d1.w),a5	; a5=a5+y*160
           add.w 	d0,d0		; x*2
           add.w 	d0,d0		; x*2
           adda.w 	(a3,d0.w),a5	; a5=a5+x
           move.w 	2(a3,d0.w),d1	; d1=motif du point
           move.l 	a5,(a6)+	; Sauve a5
           or.w 	d1,(a5)		; Affiche le point

; ***************************************************************
; Point no 3: transfert de x, y, z dans d0 - d1 - d2 
; ***************************************************************

no3	   move.w 	(a4)+,d0		; x dans d0
           move.w 	(a4)+,d1		; y dans d1
           move.w 	(a4)+,d2		; z dans d2

; ---------------------------------------------------------------
; Calcul de la rotation suivant y : x=x*cos(ay)+z*sin(ay)
; ---------------------------------------------------------------

           muls 	d6,d0		; x*cos(ay)
           muls 	d7,d2		; z*sin(ay)
           sub.w 	d2,d0		; x*cos(ay)+z*sin(ay)
           asr.w 	d3,d0		; /256

; ---------------------------------------------------------------
; Centrage dans l'ecran 
; ---------------------------------------------------------------

           add.w 	centrx,d0		; x=x+centrx
           blt.s 	no4		; si x<0 va en no2
           add.w 	centry,d1		; y=y+centry

; ---------------------------------------------------------------
; Affiche le point 
; ---------------------------------------------------------------

           move.l 	a0,a5		; Adresse ecran -> a5
           add.w 	d1,d1		; y*2
           adda.w 	(a2,d1.w),a5	; a5=a5+y*160
           add.w 	d0,d0		; x*2
           add.w 	d0,d0		; x*2
           adda.w 	(a3,d0.w),a5	; a5=a5+x
           move.w 	2(a3,d0.w),d1	; d1=motif du point
           move.l 	a5,(a6)+		; Sauve a5
           or.w 	d1,(a5)		; Affiche le point

; ***************************************************************
; Point no 4: transfert de x, y, z dans d0 - d1 - d2 
; ***************************************************************

no4	   move.w 	(a4)+,d0		; x dans d0
           move.w 	(a4)+,d1		; y dans d1
           move.w 	(a4)+,d2		; z dans d2

; ---------------------------------------------------------------
; Calcul de la rotation suivant y : x=x*cos(ay)+z*sin(ay)
; ---------------------------------------------------------------

           muls 	d6,d0		; x*cos(ay)
           muls 	d7,d2		; z*sin(ay)
           sub.w 	d2,d0		; x*cos(ay)+z*sin(ay)
           asr.w 	d3,d0		; /256

; ---------------------------------------------------------------
; Centrage dans l'ecran 
; ---------------------------------------------------------------

           add.w 	centrx,d0		; x=x+centrx
           blt.s 	no5		; si x<0 va en no2
           add.w 	centry,d1		; y=y+centry

; ---------------------------------------------------------------
; Affiche le point 
; ---------------------------------------------------------------

           move.l 	a0,a5		; Adresse ecran -> a5
           add.w 	d1,d1		; y*2
           adda.w 	(a2,d1.w),a5	; a5=a5+y*160
           add.w 	d0,d0		; x*2
           add.w 	d0,d0		; x*2
           adda.w 	(a3,d0.w),a5	; a5=a5+x
           move.w 	2(a3,d0.w),d1	; d1=motif du point
           move.l 	a5,(a6)+		; Sauve a5
           or.w 	d1,(a5)		; Affiche le point

; ***************************************************************
; Point no 5: transfert de x, y, z dans d0 - d1 - d2 
; ***************************************************************

no5	   move.w 	(a4)+,d0		; x dans d0
           move.w 	(a4)+,d1		; y dans d1
           move.w 	(a4)+,d2		; z dans d2

; ---------------------------------------------------------------
; Calcul de la rotation suivant y : x=x*cos(ay)+z*sin(ay)
; ---------------------------------------------------------------

           muls 	d6,d0		; x*cos(ay)
           muls 	d7,d2		; z*sin(ay)
           sub.w 	d2,d0		; x*cos(ay)+z*sin(ay)
           asr.w 	d3,d0		; /256

; ---------------------------------------------------------------
; Centrage dans l'ecran 
; ---------------------------------------------------------------

           add.w 	centrx,d0		; x=x+centrx
           blt.s 	no6		; si x<0 va en no2
           add.w 	centry,d1		; y=y+centry

; ---------------------------------------------------------------
; Affiche le point 
; ---------------------------------------------------------------

           move.l 	a0,a5		; Adresse ecran -> a5
           add.w 	d1,d1		; y*2
           adda.w 	(a2,d1.w),a5	; a5=a5+y*160
           add.w 	d0,d0		; x*2
           add.w 	d0,d0		; x*2
           adda.w 	(a3,d0.w),a5	; a5=a5+x
           move.w 	2(a3,d0.w),d1	; d1=motif du point
           move.l 	a5,(a6)+		; Sauve a5
           or.w 	d1,(a5)		; Affiche le point
         
no6        dbra d5,calc

           rte

; --------------------------------------------------------------
;
;                        RASTERS (TIMER B)
;
; --------------------------------------------------------------

hbl1       subq.w #1,conte
;           tst.w conte
           beq.s fin_hbl
           move.w (a3)+,$ffff8244.w
           rte

fin_hbl    clr.b $ffffa1b
           move.l #hbl2,$120.w
           move.b #8,$ffffa1b
           rte

hbl2       move.l (a3)+,$ff8248
           move.l (a3)+,$ff824c
           clr.b $ffffa1b
           move.b #120,$ffffa21
           move.l #hbl3,$120.w
           move.b #8,$ffffa1b
           rte    

hbl3       move.l (a3)+,$ff8248
           move.l (a3)+,$ff824c
           clr.b $ffffa1b
           rte       
       
; -------
; Clavier
; -------

newkey     move.w #$2500,sr
           bclr #6,$ffffa11
           rte

; ***************************************************************
;
;         PERMUTE BUFFERS EFFACEMENT ET LES DEUX ECRANS
;
; ***************************************************************

permute    move.l efface1,d0
           move.l efface2,efface1
           move.l d0,efface2

           move.l screen1,d0
           move.l screen2,screen1
           move.l d0,screen2

           move.b screen1+1,$ffff8201.w
           move.b screen1+2,$ffff8203.w
  
           rts
        
; --------------------------------------------------------------
;
;                      VARIABLES & DONNEES
;
; --------------------------------------------------------------

rasters dc.w $070,$170,$270,$370,$470,$570,$670,$770
        dc.w $760,$750,$740,$730,$720,$710,$700,$600
        dc.w $007

palet2  dc.w $770    ; Logo 'FANTOMAS / RED OCTOBER'
        dc.w $777    ; Logo + objet
        dc.w $007    ; Logo + scroll
        dc.w $007

palet3  dc.w $766    ; Remet les couleurs pour 'RAINBOW'
        dc.w $766
        dc.w $755
        dc.w $755

; ****************************************************************
;
;                        TABLE DES OBJETS
;
; ****************************************************************

obj_lst    dc.l cercle,sphere3,chaise,red,sphere2,cube,plaque
           dc.l lunettes,sphere,fantomas

; ****************************************************************
;
; PARTIE I: DONNEES OBJETS 3D ( 10 OBJETS )
;
; ****************************************************************

; ---< [01] Cercle / 90 points>---

cercle     dc.w 44
           dc.w 0,60,0
           dc.w 4,59,0
           dc.w 8,59,0
           dc.w 12,58,0
           dc.w 16,57,0
           dc.w 20,56,0
           dc.w 24,54,0
           dc.w 28,52,0
           dc.w 31,50,0
           dc.w 35,48,0
           dc.w 38,45,0
           dc.w 41,43,0
           dc.w 44,40,0
           dc.w 47,36,0
           dc.w 49,33,0
           dc.w 51,30,0
           dc.w 53,26,0
           dc.w 55,22,0
           dc.w 57,18,0
           dc.w 58,14,0
           dc.w 59,10,0
           dc.w 59,6,0
           dc.w 59,2,0
           dc.w 59,-2,0
           dc.w 59,-6,0
           dc.w 59,-10,0
           dc.w 58,-14,0
           dc.w 57,-18,0
           dc.w 55,-22,0
           dc.w 53,-26,0
           dc.w 51,-30,0
           dc.w 49,-33,0
           dc.w 47,-36,0
           dc.w 44,-40,0
           dc.w 41,-43,0
           dc.w 38,-45,0
           dc.w 35,-48,0
           dc.w 31,-50,0
           dc.w 28,-52,0
           dc.w 24,-54,0
           dc.w 20,-56,0
           dc.w 16,-57,0
           dc.w 12,-58,0
           dc.w 8,-59,0
           dc.w 4,-59,0
           dc.w 0,-60,0
           dc.w -4,-59,0
           dc.w -8,-59,0
           dc.w -12,-58,0
           dc.w -16,-57,0
           dc.w -20,-56,0
           dc.w -24,-54,0
           dc.w -28,-52,0
           dc.w -31,-50,0
           dc.w -35,-48,0
           dc.w -38,-45,0
           dc.w -41,-43,0
           dc.w -44,-40,0
           dc.w -47,-36,0
           dc.w -49,-33,0
           dc.w -51,-30,0
           dc.w -53,-26,0
           dc.w -55,-22,0
           dc.w -57,-18,0
           dc.w -58,-14,0
           dc.w -59,-10,0
           dc.w -59,-6,0
           dc.w -59,-2,0
           dc.w -59,2,0
           dc.w -59,6,0
           dc.w -59,10,0
           dc.w -58,14,0
           dc.w -57,18,0
           dc.w -55,22,0
           dc.w -53,26,0
           dc.w -51,30,0
           dc.w -49,33,0
           dc.w -47,36,0
           dc.w -44,40,0
           dc.w -41,43,0
           dc.w -38,45,0
           dc.w -35,48,0
           dc.w -31,50,0
           dc.w -28,52,0
           dc.w -24,54,0
           dc.w -20,56,0
           dc.w -16,57,0
           dc.w -12,58,0
           dc.w -8,59,0
           dc.w -4,59,0

; ---< [02] Cube / 116 points>---

cube       dc.w 57
           dc.w -50,-50,-50
           dc.w -40,-50,-50
           dc.w -30,-50,-50
           dc.w -20,-50,-50
           dc.w -10,-50,-50
           dc.w 0,-50,-50
           dc.w 10,-50,-50
           dc.w 20,-50,-50
           dc.w 30,-50,-50
           dc.w 40,-50,-50
           dc.w 50,-50,-50
           dc.w -50,-40,-50
           dc.w 50,-40,-50
           dc.w -50,-30,-50
           dc.w 50,-30,-50
           dc.w -50,-20,-50
           dc.w 50,-20,-50
           dc.w -50,-10,-50
           dc.w 50,-10,-50
           dc.w -50,0,-50
           dc.w 50,0,-50
           dc.w -50,10,-50
           dc.w 50,10,-50
           dc.w -50,20,-50
           dc.w 50,20,-50
           dc.w -50,30,-50
           dc.w 50,30,-50
           dc.w -50,40,-50
           dc.w 50,40,-50
           dc.w -50,50,-50
           dc.w -40,50,-50
           dc.w -30,50,-50
           dc.w -20,50,-50
           dc.w -10,50,-50
           dc.w 0,50,-50
           dc.w 10,50,-50
           dc.w 20,50,-50
           dc.w 30,50,-50
           dc.w 40,50,-50
           dc.w 50,50,-50
           dc.w -50,-50,50
           dc.w -40,-50,50
           dc.w -30,-50,50
           dc.w -20,-50,50
           dc.w -10,-50,50
           dc.w 0,-50,50
           dc.w 10,-50,50
           dc.w 20,-50,50
           dc.w 30,-50,50
           dc.w 40,-50,50
           dc.w 50,-50,50
           dc.w -50,-40,50
           dc.w 50,-40,50
           dc.w -50,-30,50
           dc.w 50,-30,50
           dc.w -50,-20,50
           dc.w 50,-20,50
           dc.w -50,-10,50
           dc.w 50,-10,50
           dc.w -50,0,50
           dc.w 50,0,50
           dc.w -50,10,50
           dc.w 50,10,50
           dc.w -50,20,50
           dc.w 50,20,50
           dc.w -50,30,50
           dc.w 50,30,50
           dc.w -50,40,50
           dc.w 50,40,50
           dc.w -50,50,50
           dc.w -40,50,50
           dc.w -30,50,50
           dc.w -20,50,50
           dc.w -10,50,50
           dc.w 0,50,50
           dc.w 10,50,50
           dc.w 20,50,50
           dc.w 30,50,50
           dc.w 40,50,50
           dc.w 50,50,50
           dc.w -50,-50,-40
           dc.w -50,-50,-30         
           dc.w -50,-50,-20
           dc.w -50,-50,-10 
           dc.w -50,-50,0
           dc.w -50,-50,10 
           dc.w -50,-50,20
           dc.w -50,-50,30 
           dc.w -50,-50,40
           dc.w 50,-50,-40
           dc.w 50,-50,-30         
           dc.w 50,-50,-20
           dc.w 50,-50,-10 
           dc.w 50,-50,0
           dc.w 50,-50,10 
           dc.w 50,-50,20
           dc.w 50,-50,30 
           dc.w 50,-50,40
           dc.w -50,50,-40
           dc.w -50,50,-30         
           dc.w -50,50,-20
           dc.w -50,50,-10 
           dc.w -50,50,0
           dc.w -50,50,10 
           dc.w -50,50,20
           dc.w -50,50,30 
           dc.w -50,50,40
           dc.w 50,50,-40
           dc.w 50,50,-30         
           dc.w 50,50,-20
           dc.w 50,50,-10 
           dc.w 50,50,0
           dc.w 50,50,10 
           dc.w 50,50,20
           dc.w 50,50,30 
           dc.w 50,50,40

; ---< [03] Plaque / 100 points >---

plaque     dc.w 49
           dc.w -45,-45,0,-35,-45,0,-25,-45,0,-15,-45,0,-5,-45,0,5,-45,0
           dc.w 15,-45,0,25,-45,0,35,-45,0,45,-45,0,-45,-35,0,-35,-35,0
           dc.w -25,-35,0
           dc.w -15,-35,0
           dc.w -5,-35,0
           dc.w 5,-35,0
           dc.w 15,-35,0
           dc.w 25,-35,0
           dc.w 35,-35,0
           dc.w 45,-35,0
           dc.w -45,-25,0
           dc.w -35,-25,0
           dc.w -25,-25,0
           dc.w -15,-25,0
           dc.w -5,-25,0
           dc.w 5,-25,0
           dc.w 15,-25,0
           dc.w 25,-25,0
           dc.w 35,-25,0
           dc.w 45,-25,0
           dc.w -45,-15,0
           dc.w -35,-15,0
           dc.w -25,-15,0
           dc.w -15,-15,0
           dc.w -5,-15,0
           dc.w 5,-15,0
           dc.w 15,-15,0
           dc.w 25,-15,0
           dc.w 35,-15,0
           dc.w 45,-15,0
           dc.w -45,-5,0
           dc.w -35,-5,0
           dc.w -25,-5,0
           dc.w -15,-5,0
           dc.w -5,-5,0
           dc.w 5,-5,0
           dc.w 15,-5,0
           dc.w 25,-5,0
           dc.w 35,-5,0
           dc.w 45,-5,0
           dc.w -45,5,0
           dc.w -35,5,0
           dc.w -25,5,0
           dc.w -15,5,0
           dc.w -5,5,0
           dc.w 5,5,0
           dc.w 15,5,0
           dc.w 25,5,0
           dc.w 35,5,0
           dc.w 45,5,0
           dc.w -45,15,0
           dc.w -35,15,0
           dc.w -25,15,0
           dc.w -15,15,0
           dc.w -5,15,0
           dc.w 5,15,0
           dc.w 15,15,0
           dc.w 25,15,0
           dc.w 35,15,0
           dc.w 45,15,0
           dc.w -45,25,0
           dc.w -35,25,0
           dc.w -25,25,0
           dc.w -15,25,0
           dc.w -5,25,0
           dc.w 5,25,0
           dc.w 15,25,0
           dc.w 25,25,0
           dc.w 35,25,0
           dc.w 45,25,0
           dc.w -45,35,0
           dc.w -35,35,0
           dc.w -25,35,0
           dc.w -15,35,0
           dc.w -5,35,0
           dc.w 5,35,0
           dc.w 15,35,0
           dc.w 25,35,0
           dc.w 35,35,0
           dc.w 45,35,0
           dc.w -45,45,0
           dc.w -35,45,0
           dc.w -25,45,0
           dc.w -15,45,0
           dc.w -5,45,0
           dc.w 5,45,0
           dc.w 15,45,0
           dc.w 25,45,0
           dc.w 35,45,0
           dc.w 45,45,0

; ---< [04] lunettes / 102 points >---

lunettes   dc.w 50
           dc.w -50,-10,50,-45,-15,50,-40,-15,50,-35,-15,50,-30,-15,50
           dc.w -25,-15,50,-20,-15,50,-15,-15,50,-10,-10,50,-5,-15,50
           dc.w 0,-15,50,5,-15,50,10,-10,50,15,-15,50,20,-15,50,25,-15,50
           dc.w 30,-15,50,35,-15,50,40,-15,50,45,-15,50,50,-10,50,-50,-5,50
           dc.w -10,-5,50,10,-5,50,50,-5,50,-50,0,50,-10,0,50,10,0,50,50,0,50
           dc.w -50,5,50,-10,5,50,10,5,50,50,5,50,-50,10,50,-10,10,50
           dc.w 10,10,50,50,10,50,-45,15,50,-40,15,50,-35,15,50,-30,15,50
           dc.w -25,15,50,-20,15,50,-15,15,50,15,15,50,20,15,50,25,15,50
           dc.w 30,15,50,35,15,50,40,15,50,45,15,50,50,-10,45,50,-10,40
           dc.w 50,-10,35,50,-10,30,50,-10,25,50,-10,20,50,-10,15,50,-10,10
           dc.w 50,-10,5,50,-10,0,50,-10,-5,50,-10,-10,50,-10,-15,50,-10,-20
           dc.w 50,-10,-25,50,-10,-30,50,-10,-35,50,-10,-40,50,-10,-45
           dc.w 50,-5,-50,50,0,-50,50,5,-50,50,10,-50,50,15,-45,50,15,-40
           dc.w -50,-10,45,-50,-10,40
           dc.w -50,-10,35,-50,-10,30,-50,-10,25,-50,-10,20,-50,-10,15,-50,-10,10
           dc.w -50,-10,5,-50,-10,0,-50,-10,-5,-50,-10,-10,-50,-10,-15,-50,-10,-20
           dc.w -50,-10,-25,-50,-10,-30,-50,-10,-35,-50,-10,-40,-50,-10,-45
           dc.w -50,-5,-50,-50,0,-50,-50,5,-50,-50,10,-50,-50,15,-45,-50,15,-40          
           dc.w -50,15,-40

; ---< [05] fantomas / 112 points >---

fantomas   dc.w 55
           dc.w -78,-8,0,-74,-8,0,-70,-8,0,-66,-8,0,-62,-8,0,-78,-4,0
           dc.w -78,0,0,-74,0,0,-70,0,0,-78,4,0,-78,8,0,-58,-8,0,-54,-8,0
           dc.w -50,-8,0,-46,-8,0,-42,-8,0,-58,-4,0,-42,-4,0,-58,0,0,-54,0,0
           dc.w -50,0,0,-46,0,0,-42,0,0,-58,4,0,-42,4,0,-58,8,0,-42,8,0
           dc.w -38,-8,0,-22,-8,0,-38,-4,0,-34,-4,0,-22,-4,0,-38,0,0
           dc.w -30,0,0,-22,0,0,-38,4,0,-26,4,0,-22,4,0,-38,8,0,-22,8,0
           dc.w -18,-8,0,-14,-8,0,-10,-8,0,-6,-8,0,-2,-8,0,-10,-4,0
           dc.w -10,0,0,-10,4,0,-10,8,0,2,-8,0,2,-4,0,2,0,0,2,4,0,2,8,0
           dc.w 6,-8,0,6,8,0,10,-8,0,10,8,0,14,-8,0,14,8,0,18,-8,0,18,-4,0
           dc.w 18,0,0,18,4,0,18,8,0,22,-8,0,22,-4,0,22,0,0,22,4,0,22,8,0
           dc.w 26,-4,0,30,0,0,34,-4,0,38,-8,0,38,-4,0,38,0,0,38,4,0,38,8,0
           dc.w 42,-8,0,42,-4,0,42,0,0,42,4,0,42,8,0,46,-8,0,46,0,0
           dc.w 50,-8,0,50,0,0,54,-8,0,54,0,0,58,-8,0,58,-4,0,58,0,0
           dc.w 58,4,0,58,8,0,62,-8,0,62,-4,0,62,0,0,62,8,0,66,-8,0,66,0,0
           dc.w 66,8,0,70,-8,0,70,0,0,70,8,0,74,-8,0,74,0,0,74,8,0
           dc.w 78,-8,0,78,0,0,78,4,0,78,8,0,78,8,0

; ---< [06] Chaise / 98 points >---

chaise     dc.w 48
           dc.w -20,-20,-20,-15,-20,-20,-10,-20,-20,-5,-20,-20,0,-20,-20
           dc.w 5,-20,-20,10,-20,-20,15,-20,-20,20,-20,-20
           dc.w -20,-20,20,-15,-20,20,-10,-20,20,-5,-20,20,0,-20,20
           dc.w 5,-20,20,10,-20,20,15,-20,20,20,-20,20       
           dc.w -20,-20,-15,-20,-20,-10,-20,-20,-5,-20,-20,0,-20,-20,5
           dc.w -20,-20,10,-20,-20,15
           dc.w 20,-20,-15,20,-20,-10,20,-20,-5,20,-20,0,20,-20,5
           dc.w 20,-20,10,20,-20,15
           dc.w 20,-15,20,20,-10,20,20,-5,20,20,0,20,20,5,20,20,10,20
           dc.w 20,15,20,20,20,20
           dc.w -20,-15,20,-20,-10,20,-20,-5,20,-20,0,20,-20,5,20,-20,10,20
           dc.w -20,15,20,-20,20,20  
           dc.w -20,-15,-20,-20,-10,-20,-20,-5,-20,-20,0,-20,-20,5,-20,-20,10,-20
           dc.w -20,15,-20,-20,20,-20
           dc.w 20,-15,-20,20,-10,-20,20,-5,-20,20,0,-20,20,5,-20,20,10,-20
           dc.w 20,15,-20,20,20,-20
           dc.w -20,-25,-20,-20,-30,-20,-20,-35,-20,-20,-40,-20,-20,-45,-20
           dc.w -20,-50,-20,-20,-55,-20,-20,-60,-20,-20,-65,-20,-20,-70,-20
           dc.w 20,-25,-20,20,-30,-20,20,-35,-20,20,-40,-20,20,-45,-20
           dc.w 20,-50,-20,20,-55,-20,20,-60,-20,20,-65,-20,20,-70,-20
           dc.w -15,-70,-20,-10,-70,-20,-5,-70,-20,0,-70,-20,5,-70,-20
           dc.w 10,-70,-20,15,-70,-20
           dc.w -15,-55,-20,-10,-55,-20,-5,-55,-20,0,-55,-20,5,-55,-20
           dc.w 10,-55,-20,15,-55,-20

; ---< [07] Sphere / 108 points >---

sphere     dc.w 53
           dc.w 60,0,0
           dc.w 59,10,0
           dc.w 56,20,0
           dc.w 51,30,0
           dc.w 45,38,0
           dc.w 38,45,0
           dc.w 30,51,0
           dc.w 20,56,0
           dc.w 10,59,0
           dc.w 0,60,0
           dc.w -10,59,0
           dc.w -20,56,0
           dc.w -30,51,0
           dc.w -38,45,0
           dc.w -45,38,0
           dc.w -51,30,0
           dc.w -56,20,0
           dc.w -59,10,0
           dc.w -60,0,0
           dc.w -59,-10,0
           dc.w -56,-20,0
           dc.w -51,-30,0
           dc.w -45,-38,0
           dc.w -38,-45,0
           dc.w -30,-51,0
           dc.w -20,-56,0
           dc.w -10,-59,0
           dc.w 0,-60,0
           dc.w 10,-59,0
           dc.w 20,-56,0
           dc.w 30,-51,0
           dc.w 38,-45,0
           dc.w 45,-38,0
           dc.w 51,-30,0
           dc.w 56,-20,0
           dc.w 59,-10,0
           dc.w 30,0,-51
           dc.w 29,10,-51
           dc.w 28,20,-48
           dc.w 25,30,-44
           dc.w 22,38,-38
           dc.w 19,45,-32
           dc.w 15,51,-25
           dc.w 10,56,-17
           dc.w 5,59,-8
           dc.w 0,60,0
           dc.w -5,59,8
           dc.w -10,56,17
           dc.w -15,51,25
           dc.w -19,45,32
           dc.w -22,38,38
           dc.w -25,30,44
           dc.w -28,20,48
           dc.w -29,10,51
           dc.w -30,0,51
           dc.w -29,-10,51
           dc.w -28,-20,48
           dc.w -25,-30,44
           dc.w -22,-38,38
           dc.w -19,-45,32
           dc.w -15,-51,25
           dc.w -10,-56,17
           dc.w -5,-59,8
           dc.w 0,-60,0
           dc.w 5,-59,-8
           dc.w 10,-56,-17
           dc.w 15,-51,-25
           dc.w 19,-45,-32
           dc.w 22,-38,-38
           dc.w 25,-30,-44
           dc.w 28,-20,-48
           dc.w 29,-10,-51
           dc.w -30,0,-51
           dc.w -29,10,-51
           dc.w -28,20,-48
           dc.w -25,30,-44
           dc.w -22,38,-38
           dc.w -19,45,-32
           dc.w -15,51,-25
           dc.w -10,56,-17
           dc.w -5,59,-8
           dc.w 0,60,0
           dc.w 5,59,8
           dc.w 10,56,17
           dc.w 15,51,25
           dc.w 19,45,32
           dc.w 22,38,38
           dc.w 25,30,44
           dc.w 28,20,48
           dc.w 29,10,51
           dc.w 30,0,51
           dc.w 29,-10,51
           dc.w 28,-20,48
           dc.w 25,-30,44
           dc.w 22,-38,38
           dc.w 19,-45,32
           dc.w 15,-51,25
           dc.w 10,-56,17
           dc.w 5,-59,8
           dc.w 0,-60,0
           dc.w -5,-59,-8
           dc.w -10,-56,-17
           dc.w -15,-51,-25
           dc.w -19,-45,-32
           dc.w -22,-38,-38
           dc.w -25,-30,-44
           dc.w -28,-20,-48
           dc.w -29,-10,-51
 
; ---< [08] Sphere no 2 / 90 points >---

sphere2    dc.w 44
           dc.w 45,18,-3
           dc.w 48,-6,-6
           dc.w 10,-48,-2
           dc.w 13,-47,-3
           dc.w 21,-44,-7
           dc.w 14,47,-6
           dc.w 40,18,-21
           dc.w 41,-8,-25
           dc.w 33,25,-24
           dc.w 34,20,-28
           dc.w 10,-47,-10
           dc.w 28,26,-31
           dc.w 5,-49,-7
           dc.w 16,39,-24
           dc.w 19,-31,-32
           dc.w 20,18,-41
           dc.w 2,49,-7
           dc.w 7,-42,-23
           dc.w 7,39,-29
           dc.w 3,-45,-20
           dc.w 2,42,-24
           dc.w 0,43,-23
           dc.w -1,-9,-48
           dc.w -4,-15,-46
           dc.w -7,-27,-40
           dc.w -2,48,-9
           dc.w -5,-46,-16
           dc.w -18,1,-45
           dc.w -17,27,-36
           dc.w -3,49,-5
           dc.w -27,1,-40
           dc.w -19,-37,-25
           dc.w -17,-42,-19
           dc.w -12,46,-11
           dc.w -35,-17,-29
           dc.w -23,40,-17
           dc.w -28,36,-18
           dc.w -34,30,-18
           dc.w -6,-49,-2
           dc.w -19,-45,-7
           dc.w -42,-21,-12
           dc.w -44,-20,-9
           dc.w -31,-38,-4
           dc.w -8,49,0
           dc.w -46,18,0
           dc.w -16,-46,1
           dc.w -46,16,6
           dc.w -46,-11,9
           dc.w -20,44,5
           dc.w -19,44,7
           dc.w -33,32,15
           dc.w -28,38,15
           dc.w -36,25,22
           dc.w -9,48,7
           dc.w -16,44,14
           dc.w -35,-6,34
           dc.w -30,-20,33
           dc.w -25,-27,32
           dc.w -8,-47,12
           dc.w -7,-47,12
           dc.w -18,-26,37
           dc.w -18,-2,45
           dc.w -3,-48,9
           dc.w -11,-5,47
           dc.w -7,23,43
           dc.w -1,-48,11
           dc.w -1,-1,48
           dc.w 1,37,31
           dc.w 1,-48,9
           dc.w 5,-38,31
           dc.w 3,47,15
           dc.w 15,-9,46
           dc.w 14,29,37
           dc.w 19,-21,40
           dc.w 12,-43,20
           dc.w 9,46,14
           dc.w 20,-36,26
           dc.w 30,18,34
           dc.w 35,-7,34
           dc.w 13,-46,10
           dc.w 32,29,23
           dc.w 31,-32,19
           dc.w 0,-49,0
           dc.w 3,-49,1
           dc.w 40,25,14
           dc.w 30,37,8
           dc.w 38,30,8
           dc.w 7,49,1
           dc.w 24,42,1
           dc.w 47,-15,0

; ---< [09] Sphere no 3 / 90 points >---

sphere3    dc.w 44
           dc.w 12,48,0
           dc.w 2,49,0
           dc.w 43,-22,-9
           dc.w 5,49,-1
           dc.w 31,35,-11
           dc.w 9,48,-4
           dc.w 7,-49,-4
           dc.w 11,48,-6
           dc.w 27,36,-19
           dc.w 13,46,-10
           dc.w 7,-48,-7
           dc.w 13,45,-14
           dc.w 22,-34,-28
           dc.w 12,44,-19
           dc.w 21,25,-36
           dc.w 11,42,-23
           dc.w 0,49,0
           dc.w 8,40,-27
           dc.w 0,49,0
           dc.w 5,38,-31
           dc.w 1,48,-12
           dc.w 1,35,-33
           dc.w 0,49,-5
           dc.w -3,33,-36
           dc.w -6,-30,-38
           dc.w -9,30,-37
           dc.w -2,49,-6
           dc.w -15,27,-38
           dc.w -9,44,-19
           dc.w -21,25,-37
           dc.w -24,23,-36
           dc.w -27,21,-34
           dc.w -21,38,-23
           dc.w -33,18,-31
           dc.w -36,-11,-30
           dc.w -38,15,-27
           dc.w -41,6,-25
           dc.w -42,12,-22
           dc.w -40,23,-17
           dc.w -46,8,-16
           dc.w -18,-46,-5
           dc.w -47,5,-10
           dc.w -43,22,-6
           dc.w -48,1,-3
           dc.w -17,46,0
           dc.w -48,-1,3
           dc.w -47,-12,6
           dc.w -47,-5,10
           dc.w -41,-24,11
           dc.w -46,-8,16
           dc.w -21,43,9
           dc.w -42,-12,22
           dc.w -31,32,19
           dc.w -38,-15,27
           dc.w -9,48,7
           dc.w -33,-18,31
           dc.w -32,-10,35
           dc.w -27,-21,34
           dc.w -9,-46,14
           dc.w -21,-25,37
           dc.w -14,-37,28
           dc.w -15,-27,38
           dc.w -15,5,46
           dc.w -9,-30,37
           dc.w -7,-17,45
           dc.w -3,-33,36
           dc.w -1,-1,48
           dc.w 1,-35,33
           dc.w 5,-8,48
           dc.w 5,-38,31
           dc.w 11,11,46
           dc.w 8,-40,27
           dc.w 0,49,1
           dc.w 11,-42,23
           dc.w 10,44,18
           dc.w 12,-44,19
           dc.w 9,-47,12
           dc.w 13,-45,14
           dc.w 34,-12,33
           dc.w 13,-46,10
           dc.w 38,-14,27
           dc.w 11,-48,6
           dc.w 3,-49,1
           dc.w 9,-48,4
           dc.w 37,-29,13
           dc.w 5,-49,1
           dc.w 47,-3,10
           dc.w 2,-49,0
           dc.w 24,43,1
           dc.w 0,-50,0

; ---< [10] Red october / 102 points >---

red	dc.w 	50
	dc.w 	-8,-20,0,-4,-20,0,0,-20,0,4,-20,0,-8,-16,0,8,-16,0
	dc.w 	-8,-12,0,-4,-12,0,0,-12,0,4,-12,0,-8,-8,0,4,-8,0
	dc.w 	-8,-4,0,8,-4,0
	dc.w 	-64,4,0,-60,4,0,-56,4,0,-68,8,0,-52,8,0,-68,12,0
	dc.w 	-52,12,0,-68,16,0,-52,16,0,-64,20,0,-60,20,0
	dc.w 	-56,20,0
	dc.w 	-44,4,0,-40,4,0,-36,4,0,-32,4,0,-48,8,0,-48,12,0
	dc.w 	-48,16,0,-44,20,0,-40,20,0,-36,20,0,-32,20,0
	dc.w 	-28,4,0,-24,4,0,-20,4,0,-16,4,0,-12,4,0,-20,8,0
	dc.w 	-20,12,0,-20,16,0,-20,20,0
	dc.w 	-4,4,0,0,4,0,4,4,0,-8,8,0,8,8,0,-8,12,0,8,12,0
	dc.w 	-8,16,0,8,16,0,-4,20,0,0,20,0,4,20,0
	dc.w 	12,4,0,16,4,0,20,4,0,12,8,0,24,8,0,12,12,0,16,12,0
	dc.w 	20,12,0,24,12,0,12,16,0,28,16,0,12,20,0,16,20,0
	dc.w 	20,20,0,24,20,0
	dc.w 	32,4,0,36,4,0,40,4,0,44,4,0,48,4,0,32,8,0,32,12,0
	dc.w 	36,12,0,40,12,0,32,16,0,32,20,0,36,20,0,40,20,0
	dc.w 	44,20,0,48,20,0
	dc.w 	52,4,0,56,4,0,60,4,0,64,4,0,52,8,0,68,8,0,52,12,0
	dc.w 	56,12,0,60,12,0,64,12,0,52,16,0,64,16,0,56,20,0
	dc.w 	68,20,0

; ***************************************************************
;
; PARTIE II: DONNEES POUR LA BIG SPHERE (360 POINTS)
;
; ***************************************************************

big_sphere dc.w 71
           dc.w 78,-12,-1
           dc.w 76,19,-2
           dc.w 74,-27,-3
           dc.w 54,-57,-3
           dc.w 60,51,-5
           dc.w 46,-64,-4
           dc.w 76,-17,-9
           dc.w 32,72,-4
           dc.w 62,-48,-9
           dc.w 74,-22,-13
           dc.w 11,-79,-2
           dc.w 77,-9,-16
           dc.w 76,-16,-17
           dc.w 8,-79,-2
           dc.w 27,74,-7
           dc.w 71,28,-20
           dc.w 55,-54,-16
           dc.w 69,-32,-22
           dc.w 69,-28,-24
           dc.w 37,69,-13
           dc.w 0,79,0
           dc.w 24,75,-9
           dc.w 72,-2,-30
           dc.w 71,16,-31
           dc.w 28,-73,-13
           dc.w 61,-41,-29
           dc.w 70,-5,-35
           dc.w 59,-43,-31
           dc.w 57,-44,-31
           dc.w 69,0,-40
           dc.w 51,52,-30
           dc.w 4,79,-2
           dc.w 41,62,-27
           dc.w 3,-79,-2
           dc.w 61,27,-43
           dc.w 18,-76,-13
           dc.w 56,35,-42
           dc.w 14,77,-11
           dc.w 52,41,-42
           dc.w 55,33,-46
           dc.w 55,-29,-48
           dc.w 55,27,-50
           dc.w 22,73,-21
           dc.w 56,-12,-54
           dc.w 50,-36,-50
           dc.w 38,56,-40
           dc.w 53,4,-57
           dc.w 52,4,-58
           dc.w 32,-63,-36
           dc.w 0,-79,0
           dc.w 16,-75,-20
           dc.w 41,41,-53
           dc.w 46,-13,-62
           dc.w 24,68,-33
           dc.w 43,-24,-62
           dc.w 43,-15,-64
           dc.w 43,-9,-66
           dc.w 41,15,-66
           dc.w 19,-70,-31
           dc.w 5,-79,-9
           dc.w 0,79,0
           dc.w 35,26,-66
           dc.w 34,17,-68
           dc.w 12,74,-26
           dc.w 24,53,-53
           dc.w 32,-5,-72
           dc.w 28,-32,-67
           dc.w 8,76,-21
           dc.w 24,-40,-64
           dc.w 2,79,-7
           dc.w 12,70,-34
           dc.w 15,62,-47
           dc.w 22,-22,-72
           dc.w 18,43,-64
           dc.w 20,12,-76
           dc.w 13,56,-54
           dc.w 1,-79,-7
           dc.w 12,50,-60
           dc.w 13,-31,-71
           dc.w 13,-8,-77
           dc.w 6,67,-41
           dc.w 9,-45,-64
           dc.w 2,-76,-21
           dc.w 7,-23,-75
           dc.w 4,57,-54
           dc.w 5,13,-77
           dc.w 2,55,-56
           dc.w 2,11,-78
           dc.w 0,-62,-49
           dc.w 0,52,-60
           dc.w -1,-11,-78
           dc.w -2,-51,-60
           dc.w -1,75,-26
           dc.w -4,35,-70
           dc.w -6,-29,-73
           dc.w 0,79,-3
           dc.w -9,16,-77
           dc.w -5,-71,-35
           dc.w -1,-79,-7
           dc.w -12,29,-72
           dc.w -1,79,-5
           dc.w -12,54,-56
           dc.w -11,-59,-51
           dc.w -9,-69,-38
           dc.w -8,-72,-31
           dc.w -14,61,-49
           dc.w -14,-62,-47
           dc.w -4,78,-15
           dc.w -1,79,-5
           dc.w -9,75,-25
           dc.w -14,69,-37
           dc.w -1,-79,-4
           dc.w -3,79,-7
           dc.w -32,5,-72
           dc.w -16,69,-34
           dc.w -32,-31,-65
           dc.w -32,-36,-63
           dc.w -32,40,-60
           dc.w -35,28,-64
           dc.w -29,-54,-50
           dc.w -1,-79,-1
           dc.w -33,-48,-53
           dc.w -8,78,-12
           dc.w -27,-62,-41
           dc.w -6,79,-9
           dc.w 0,80,0
           dc.w -46,17,-61
           dc.w -46,27,-59
           dc.w -35,-55,-44
           dc.w -23,71,-27
           dc.w -30,64,-35
           dc.w -52,-12,-58
           dc.w -42,48,-46
           dc.w -54,8,-56
           dc.w -35,-62,-35
           dc.w -27,-69,-26
           dc.w -57,11,-53
           dc.w -32,-66,-29
           dc.w -51,-41,-44
           dc.w -53,-37,-44
           dc.w -20,-75,-16
           dc.w -59,22,-46
           dc.w -28,71,-21
           dc.w -42,59,-31
           dc.w -41,-61,-29
           dc.w -65,9,-44
           dc.w -51,51,-33
           dc.w -31,-70,-19
           dc.w -65,22,-39
           dc.w -60,37,-35
           dc.w -35,-68,-19
           dc.w -69,-4,-37
           dc.w -62,37,-31
           dc.w -25,74,-12
           dc.w -71,-5,-33
           dc.w -34,69,-15
           dc.w -69,26,-29
           dc.w -72,-15,-29
           dc.w -32,-71,-12
           dc.w -20,-76,-7
           dc.w -74,-2,-25
           dc.w -8,-79,-2
           dc.w -63,44,-19
           dc.w -30,73,-8
           dc.w -71,29,-19
           dc.w -76,6,-19
           dc.w -54,-56,-12
           dc.w -65,42,-13
           dc.w -50,61,-9
           dc.w -70,-33,-12
           dc.w -66,43,-10
           dc.w -19,-77,-2
           dc.w -37,69,-4
           dc.w -78,9,-8
           dc.w -7,79,0
           dc.w -62,-49,-4
           dc.w -31,73,-1
           dc.w -23,76,0
           dc.w -18,77,0
           dc.w -75,27,0
           dc.w -47,63,0
           dc.w -25,75,0
           dc.w -69,37,3
           dc.w -74,27,5
           dc.w -39,-69,3
           dc.w -54,-57,5
           dc.w -59,-52,7
           dc.w -28,74,4
           dc.w -60,51,9
           dc.w -32,-72,5
           dc.w -65,42,12
           dc.w -50,60,10
           dc.w -69,35,15
           dc.w -39,68,9
           dc.w -75,13,20
           dc.w -71,28,20
           dc.w -49,60,15
           dc.w -44,64,14
           dc.w -31,72,10
           dc.w -29,-73,10
           dc.w -46,-62,17
           dc.w -30,72,12
           dc.w -69,-23,29
           dc.w -3,-79,1
           dc.w -1,-79,0
           dc.w -33,70,16
           dc.w -57,-47,29
           dc.w -38,-66,20
           dc.w -22,75,12
           dc.w -45,60,26
           dc.w -67,-9,40
           dc.w -24,74,15
           dc.w -45,-58,29
           dc.w -57,38,38
           dc.w -62,-24,43
           dc.w -62,19,45
           dc.w -42,59,31
           dc.w -48,-50,38
           dc.w -24,73,19
           dc.w -29,69,24
           dc.w -55,29,48
           dc.w -52,35,47
           dc.w -49,-42,45
           dc.w -3,-79,3
           dc.w -33,64,33
           dc.w -6,79,6
           dc.w -11,-77,12
           dc.w -42,48,46
           dc.w -24,-69,28
           dc.w -43,-43,51
           dc.w -42,41,52
           dc.w -48,-15,61
           dc.w -46,-17,61
           dc.w -44,-22,61
           dc.w -8,78,12
           dc.w -27,63,40
           dc.w -9,77,14
           dc.w 0,-79,0
           dc.w -40,8,67
           dc.w -12,-76,20
           dc.w -2,79,4
           dc.w -2,79,5
           dc.w -19,-67,38
           dc.w -29,-41,61
           dc.w -15,-71,32
           dc.w -10,-75,23
           dc.w -18,63,44
           dc.w -16,67,39
           dc.w -10,74,26
           dc.w -2,-79,5
           dc.w -10,-73,29
           dc.w 0,79,1
           dc.w -6,-76,21
           dc.w -6,76,22
           dc.w -11,66,42
           dc.w -12,-62,48
           dc.w -12,56,54
           dc.w -8,67,42
           dc.w -10,57,53
           dc.w -13,-23,74
           dc.w -9,54,57
           dc.w -2,77,16
           dc.w -8,-32,72
           dc.w -1,-78,14
           dc.w -4,-64,46
           dc.w -2,73,31
           dc.w 0,-78,14
           dc.w -1,63,47
           dc.w -1,-37,69
           dc.w 0,76,22
           dc.w 0,78,12
           dc.w 2,36,70
           dc.w 4,2,78
           dc.w 0,79,10
           dc.w 4,56,55
           dc.w 7,31,72
           dc.w 7,49,62
           dc.w 8,-49,62
           dc.w 10,-43,66
           dc.w 10,-50,61
           dc.w 6,-72,32
           dc.w 14,38,67
           dc.w 12,-58,52
           dc.w 17,-33,69
           dc.w 18,-36,68
           dc.w 15,-56,53
           dc.w 23,-12,75
           dc.w 16,57,52
           dc.w 0,79,1
           dc.w 26,-19,72
           dc.w 5,78,14
           dc.w 21,-55,52
           dc.w 29,-22,69
           dc.w 30,-28,67
           dc.w 26,48,57
           dc.w 4,79,9
           dc.w 35,-1,70
           dc.w 24,-60,45
           dc.w 14,74,25
           dc.w 24,-63,41
           dc.w 40,-8,67
           dc.w 19,71,30
           dc.w 40,-28,62
           dc.w 44,0,66
           dc.w 43,22,62
           dc.w 24,67,33
           dc.w 40,41,54
           dc.w 40,45,51
           dc.w 8,-78,10
           dc.w 23,-71,27
           dc.w 51,8,59
           dc.w 52,-13,57
           dc.w 49,-31,53
           dc.w 55,0,57
           dc.w 43,50,43
           dc.w 38,58,37
           dc.w 16,-76,15
           dc.w 57,-20,51
           dc.w 24,-73,20
           dc.w 9,-79,7
           dc.w 49,47,40
           dc.w 61,-13,48
           dc.w 42,59,31
           dc.w 10,-78,7
           dc.w 7,-79,5
           dc.w 55,-42,37
           dc.w 66,11,43
           dc.w 64,24,40
           dc.w 67,2,40
           dc.w 63,31,36
           dc.w 36,67,20
           dc.w 9,79,5
           dc.w 10,79,5
           dc.w 71,-1,34
           dc.w 54,-52,25
           dc.w 60,-44,26
           dc.w 0,-79,0
           dc.w 59,-47,23
           dc.w 55,-53,21
           dc.w 58,50,21
           dc.w 54,-54,18
           dc.w 75,4,24
           dc.w 15,-78,4
           dc.w 60,-49,17
           dc.w 72,27,19
           dc.w 0,-79,0
           dc.w 74,-22,17
           dc.w 54,56,11
           dc.w 76,-13,14
           dc.w 77,4,13
           dc.w 67,-41,10
           dc.w 78,5,10
           dc.w 48,63,5
           dc.w 43,-66,4
           dc.w 57,-54,5
           dc.w 27,74,1
           dc.w 77,-16,4
           dc.w 58,-53,2
           dc.w 46,64,0
           dc.w 4,79,0

; ----------------
; Nouvelle palette
; ----------------

new_pal	dc.w	$000,$777,$007,$007,$766,$766,$755,$755
  	dc.w	$457,$457,$236,$236,$347,$347,$744,$744

; ------------------------
; Table des positions en X
; ------------------------

pos_x:

i          set 0
           rept 20
           dc.w i,32768,i,16384,i,8192,i,4096,i,2048,i,1024,i,512,i,256,i,128,i,64,i,32,i,16,i,8,i,4,i,2,i,1
i          set i+8
           endr

; ------------------------
; Table des positions en Y
; ------------------------

pos_y:

i          set 0
           rept 200
           dc.w i
i          set i+160
           endr

; --------
; Vu-metre
; --------

vu_meter   dc.w 65532,65532,65532,65532,65532,65532,65532,65532
           dc.w 65532,65532,65532,65532,65532,65532,65532,65532
           dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; -------------------
; Rebond de la sphere
; -------------------

rebond     dc.w 3,3,2,3,1,2,0,0,0,-2,-1,-3,-2,-3,-3
           dc.w -3,-3,-2,-3,-1,-2,0,0,0,2,1,3,2,3,3


; ---------
; Variables
; ---------

save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
save_isrb  ds.b 1
save_vect  ds.b 1

screen1    ds.l 1
screen2    ds.l 1
efface1    ds.l 1
efface2    ds.l 1
adr_obj    ds.l 1
adr_lst    ds.l 1
adr_y      ds.l 1
adr_col    ds.l 1

eff_1      ds.l 360
eff_2      ds.l 360

centrx     ds.w 1
centry     ds.w 1
senx       ds.w 1
seny       ds.w 1

anim       ds.w 1
time       ds.w 1
incc       ds.w 1
incx       ds.w 1
incy       ds.w 1
incz       ds.w 1
angle_x    ds.w 1
angle_y    ds.w 1
angle_z    ds.w 1
conte      ds.w 1

save_scr        ds.l 1
save_vbl        ds.l 1
save_hbl        ds.l 1
save_118        ds.l 1
save_ssp        ds.l 1
save_pal        ds.w 16
save_rez        ds.w 1
save_key        ds.b 1

music1     incbin "ZIK\STEPHANI.THK"
cosin      incbin "COSIN.DAT"
fond       incbin "3D_LOGO.PI1"

