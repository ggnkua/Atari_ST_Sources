;
; ***************************************************************
;
;                  INTRO FOR -CONAN- OF -FUZION-
;                     (C) -FANTOMAS- 10/1992
;
; ***************************************************************
;
; Changements par rapport au circle-scroll de la FONT COMPIL 2:
; - Rajout de 1 caractŠre (17 caractŠres en tout)
; - Apparition et disparition progressive des caractŠres
; - Tous les caracteres sont masqu‚s (on peut afficher nimporte
;   quel dessin PI1 en dessous)
; - 1 wave supplementaire pour le d‚placement 

; Le code n'est pas forcement ce qui se fait de mieux, mais ca
; fonctionne !
; Le listing est partiellement comment‚, sorry !
;
;
;                            -FANTOMAS-
;

           opt o+

; 
; ***************************************************************
; Initialisations
; ***************************************************************
; 

; -----------
; Superviseur
; -----------

           clr.l 	-(sp)
           move.w 	#$20,-(sp)           ; GEMDOS(32) SUPER
           trap 	#1
           addq.l 	#6,sp
           move.l 	d0,oldssp

; -------
; Clavier
; -------

           move.b 	$484.w,key
           clr.b 	$484.w

; ----------
; Souris OFF
; ----------
 
           dc.w 	$a00a
           move.b 	#$12,$fffffc02.w

; -------------
; Sauve palette
; -------------

           move.l 	#$ffff8240,a0
           lea 	oldpal,a1
           movem.l 	(a0)+,d0-d7
           movem.l 	d0-d7,(a1)

; ----------------
; Nouvelle palette
; ----------------

           pea 	picture+2
           move.w 	#6,-(sp)             ; XBIOS(6) SETPALETTE
           trap 	#14
           addq.l 	#6,sp
            
; ----------------
; Sauve resolution
; ----------------

           move.w 	#4,-(sp)             ; XBIOS(4) GETREZ
           trap 	#14
           addq.l 	#2,sp 
           move.w 	d0,oldrez

; -------------------
; Sauve adresse ecran
; -------------------

           move.w 	#2,-(sp)             ; XBIOS(2) PHYBASE
           trap 	#14
           addq.l 	#2,sp
           move.l 	d0,oldscreen

; ---------------
; Nouveaux ecrans
; ---------------

           move.l 	#$60000,screen1      ; Ecran 1
           move.l 	#$67d00,screen2      ; Ecran 2

; -----------------
; Change resolution
; -----------------

           clr.w 	-(sp)                ; Basse resolution
           move.l	#-1,-(sp)            ; Logic
           move.l 	#-1,-(sp)            ; Physic
           move.w 	#5,-(sp)             ; XBIOS(5) SETSCREEN
           trap 	#14
           add.l 	#12,sp

; -----------------
; Affiche image PI1
; -----------------

	lea	picture+34,a2
           move.l 	screen1,a0
           move.l 	screen2,a1
           move.l 	#7999,d0     
red_oct    move.l	(a2),(a0)+
           move.l	(a2)+,(a1)+
           dbra 	d0,red_oct

; -------
; Musique
; -------

          moveq 	#1,d0
          bsr 	music
           
;
; ***************************************************************
; Initialisations diverses
; ***************************************************************
;

; ----------------------------
; Pointeurs deplacement cercle
; ----------------------------

           move.l 	#script-12,script_ptr
           move.l 	#wave_0,wave_ptr 
           move.l 	#wave_0,wave_deb
           move.l 	#wave_0+4,wave_end
           move.l 	#400,anim

; -------------------------------------------------------
; Buffers de restauration du fond (244 octets par sprite)
; -------------------------------------------------------

           move.l 	#eff_tab1,eff_1
           move.l 	#eff_tab2,eff_2
           move.l 	screen1,a0
           move.l 	eff_1,a1
           move.l 	eff_2,a2
           move.w 	#16,d0
eff_init   move.l 	a0,(a1)+
           move.l 	a0,(a2)+
i	set 	0
	rept 	15
	move.l	i(a0),(a1)+
	move.l	4+i(a0),(a1)+	
	move.l	8+i(a0),(a1)+
	move.l	12+i(a0),(a1)+	
	move.l	i(a0),(a2)+
	move.l	4+i(a0),(a2)+	
	move.l	8+i(a0),(a2)+
	move.l	12+i(a0),(a2)+	
i	set 	i+160
	endr
           dbra 	d0,eff_init
     
; ----------------------
; Texte du circle scroll
; ----------------------

           move.l 	#txt,txt_ptr
           move.l 	#coor,coor_ptr

; ------------
; Timers & VBL
; ------------

           move.b 	$fffffa07.w,save_iera	
           move.b 	$fffffa09.w,save_ierb
           move.b 	$fffffa13.w,save_imra
           move.b 	$fffffa11.w,savea11
           move.b 	$fffffa17.w,save_vect
           move.l 	$70.w,save_vbl
           move.l 	$120.w,save_hbl
           move.l 	$118.w,save_118

           move.l 	#vbl,$70.w                      

;
; ***************************************************************
; Boucle principale !!! 
; ***************************************************************
;

loop       cmp.b 	#$39,$fffffc02.w         ; Appui sur [SPACE] ?
           bne.s 	loop	              ; Non, on continue ...
			
; 
; ***************************************************************
; Fin du programme
; ***************************************************************
; 


; --------------
; Restore timers
; --------------

           clr.b $ffffa1b
           move.b save_iera,$ffffa07
           move.b save_ierb,$ffffa09
           move.b save_imra,$ffffa13
           move.b savea11,$fffa11
           move.b save_vect,$ffffa17
           move.l save_vbl,$70.w
           move.l save_hbl,$120.w
           move.l save_118,$118.w
           
; -----------
; Chip sonore
; -----------

           move.b #8,$ffff8800.w           ; On coupe les 3 canaux
           move.b #0,$ffff8802.w
           move.b #9,$ffff8800.w
           move.b #0,$ffff8802.w
           move.b #$a,$ffff8800.w
           move.b #0,$ffff8802.w

; -----------------------------
; Ancienne resolution et ecrans
; -----------------------------
        
           move.w 	oldrez,-(sp)          
           move.l 	oldscreen,-(sp)
           move.l 	oldscreen,-(sp)
           move.w 	#5,-(sp)
           trap 	#14
           add.l 	#12,sp

; ----------------
; Ancienne palette
; ----------------
          
           lea 	oldpal,a0
           move.l 	#$ffff8240,a1
           movem.l 	(a0)+,d0-d7
           movem.l 	d0-d7,(a1)

; ---------
; Souris ON
; ---------
 
           move.b 	#8,$fffffc02.w
           dc.w 	$a009

; -------------------
; Retablit le clavier
; -------------------

           move.b 	key,$484.w

; -------------------
; Retour en mode USER
; -------------------

           move.l 	oldssp,-(sp)
           move.w 	#$20,-(sp)
           trap 	#1
           addq.l 	#6,sp

; -------------
; Retour au DOS
; -------------

           clr.w 	-(sp)                 ; GEMDOS(0) PTERM
           trap 	#1

; 
; ***************************************************************
; Ici commence le programme ...
; ***************************************************************
; 
 
vbl:

; --------------------------------------------
; Temps machine utilis‚ (en appuyant sur TAB):
; --------------------------------------------
 
;	cmp.b 	#$0f,$fffffc02.w
;	bne.s 	pas_time
;	move.w 	#$777,$ffff8240.w

; ----------
; Joue music
; ----------

; Pour une zic MAD_MAX  : bsr music+8
; Pour une zic COUNT_0  : bsr music+6
; Pour une zic BG_ALEC  : bsr music+4
   
pas_time	bsr 	music+6

; ----------------
; Restaure le fond
; ----------------
;
; On restaure dans le sens inverse de celui de la sauvegarde ...

           move.l 	eff_1,a0
i	set	16*244

           rept 	17
           move.l 	i(a0),a1			; Adresse			

           move.l	i+4(a0),(a1)                  	; 1re ligne
           move.l 	i+8(a0),4(a1)
           move.l 	i+12(a0),8(a1)
           move.l 	i+16(a0),12(a1)

           move.l 	i+20(a0),160(a1)              	; 2me
           move.l 	i+24(a0),164(a1)
           move.l 	i+28(a0),168(a1)               
           move.l 	i+32(a0),172(a1)

           move.l 	i+36(a0),320(a1)              	; 3me
           move.l 	i+40(a0),324(a1)
           move.l 	i+44(a0),328(a1)               
           move.l 	i+48(a0),332(a1)

           move.l 	i+52(a0),480(a1)              	; 4me
           move.l 	i+56(a0),484(a1)
           move.l 	i+60(a0),488(a1)             
           move.l 	i+64(a0),492(a1)

           move.l 	i+68(a0),640(a1)              	; 5me
           move.l 	i+72(a0),644(a1)
           move.l 	i+76(a0),648(a1)             
           move.l 	i+80(a0),652(a1)

           move.l 	i+84(a0),800(a1)              	; 6me
           move.l 	i+88(a0),804(a1)
           move.l 	i+92(a0),808(a1)     
           move.l 	i+96(a0),812(a1)

           move.l 	i+100(a0),960(a1)              	; 7me
           move.l 	i+104(a0),964(a1)
           move.l 	i+108(a0),968(a1)            
           move.l 	i+112(a0),972(a1)

           move.l 	i+116(a0),1120(a1)              	; 8me
           move.l 	i+120(a0),1124(a1)
           move.l 	i+124(a0),1128(a1)
           move.l 	i+128(a0),1132(a1)

           move.l	i+132(a0),1280(a1)              	; 9me
           move.l 	i+136(a0),1284(a1)
           move.l 	i+140(a0),1288(a1)
           move.l 	i+144(a0),1292(a1)

           move.l 	i+148(a0),1440(a1)              	; 10me
           move.l 	i+152(a0),1444(a1)
           move.l 	i+156(a0),1448(a1)               
           move.l 	i+160(a0),1452(a1)

           move.l 	i+164(a0),1600(a1)              	; 11me
           move.l 	i+168(a0),1604(a1)
           move.l 	i+172(a0),1608(a1)               
           move.l 	i+176(a0),1612(a1)

           move.l 	i+180(a0),1760(a1)              	; 12me
           move.l 	i+184(a0),1764(a1)
           move.l 	i+188(a0),1768(a1)             
           move.l 	i+192(a0),1772(a1)

           move.l 	i+196(a0),1920(a1)              	; 13me
           move.l 	i+200(a0),1924(a1)
           move.l 	i+204(a0),1928(a1)             
           move.l 	i+208(a0),1932(a1)

           move.l 	i+212(a0),2080(a1)              	; 14me
           move.l 	i+216(a0),2084(a1)
           move.l 	i+220(a0),2088(a1)     
           move.l 	i+224(a0),2092(a1)

           move.l 	i+228(a0),2240(a1)              	; 15me
           move.l 	i+232(a0),2244(a1)
           move.l 	i+236(a0),2248(a1)            
           move.l 	i+240(a0),2252(a1)

i	set	i-244
           endr

; -------------------------
; Affiche les 17 caracteres
; -------------------------

           move.l 	coor_ptr,a0	; Coordonnees du cercle
           move.l 	txt_ptr,a1		; Pointeur sur le texte
	move.l	eff_1,a3		; Buffer d'effacement
	lea	y_tab,a4		; Coordonnees y * 160
	lea 	cache,a5		; Donnees pour disparition

; 
; --- Routine d'affichage du caractere no: 0 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	640(a0),d0            ; x dans d0
           move.w 	642(a0),d1            ; y dans d1
           bsr 	test
           move.w 	d0,d7                 ; x dans d7
           and.l 	#15,d7                ; Decalage mod 15
           lsr.w 	#1,d0                 ; x / 2
           andi.w 	#$f8,d0               ; AND - 8
           add.w 	d0,d1                 ; x + y * 160
           add.l 	d1,a6                 ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere 

           lea 	font,a2
           move.b 	(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affichage du caractere no 0

i          set 	0
           rept 	15
           moveq 	#0,d0
	moveq 	#0,d6
           move.w 	(a2)+,d0		; Sprite dans d0...
	jsr 	car_0
	move.w 	d0,d6		; ... et dans d6
           ror.l 	d7,d0		; Rotation Sprite
	ror.l 	d7,d6		; Rotation masque
	not.l 	d6		; Masque dans d6
	and.w 	d6,i(a6)		; Masque AND fond (plan 1)
           or.w 	d0,i(a6)		; Sprite OR fond
	and.w 	d6,i+2(a6)		; Masque AND fond (plan 2)
	and.w 	d6,i+4(a6)		; Idem plan 3
	and.w 	d6,i+6(a6)		; Idem plan 4
           swap 	d0
	swap 	d6
	and.w 	d6,i+8(a6)      
           or.w 	d0,i+8(a6)
	and.w 	d6,i+10(a6)  	
	and.w 	d6,i+12(a6)     
	and.w 	d6,i+14(a6)     
i          set	i+160
           endr

; 
; --- Routine d'affichage du caractere no: 1 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	600(a0),d0          	; x dans d0
           move.w 	602(a0),d1          	; y dans d1
           bsr 	test
           move.w 	d0,d7               	; x dans d7
           and.l 	#15,d7              	; Decalage mod 15
           lsr.w 	#1,d0               	; x / 2
           andi.w 	#$f8,d0             	; AND - 8
           add.w 	d0,d1               	; x + y * 160
           add.l 	d1,a6               	; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond
	
; ---< Calcul adresse caractere >---

           lea 	font,a2
           move.b 	1(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 1 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	560(a0),d0          ; x dans d0
           move.w 	562(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond
	
; ---< Calcul adresse caractere >---

           lea 	font,a2
           move.b 	2(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 2 ---
;

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	520(a0),d0          ; x dans d0
           move.w 	522(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	3(a1),d2
           asl.w	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 3 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	480(a0),d0          ; x dans d0
           move.w 	482(a0),d1          ; y dans d1
           bsr 	test 
           move.w 	d0,d7               ; x dans d7
           and.l	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	4(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 4 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	440(a0),d0          ; x dans d0
           move.w 	442(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	5(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

;
; --- Routine d'affichage du caractere no: 5 ---
;

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage 

           move.w 	400(a0),d0          ; x dans d0
           move.w 	402(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	6(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 6 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	360(a0),d0          ; x dans d0
           move.w 	362(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	7(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 7 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	320(a0),d0          ; x dans d0
           move.w 	322(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	8(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 8 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	280(a0),d0          ; x dans d0
           move.w 	282(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	9(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

;
; --- Routine d'affichage du caractere no: 9 ---
;

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	240(a0),d0          ; x dans d0
           move.w 	242(a0),d1          ; y dans d1
           bsr test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	10(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

; 
; --- Routine d'affichage du caractere no: 10 ---
; 

           move.l 	screen1,a6

           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	200(a0),d0          ; x dans d0
           move.w 	202(a0),d1          ; y dans d1
           bsr 	test
           move.w 	d0,d7               ; x dans d7
           and.l 	#15,d7              ; Decalage mod 15
           lsr.w 	#1,d0               ; x / 2
           andi.w 	#$f8,d0             ; AND - 8
           add.w 	d0,d1               ; x + y * 160
           add.l 	d1,a6               ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	11(a1),d2
           asl.w 	#5,d2
           add.l 	d2,a2

; -> Affiche le caractere

	jsr	aff_car

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
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea font,a2
           move.b 12(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

	jsr	aff_car

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
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea font,a2
           move.b 13(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

	jsr	aff_car

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
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea font,a2
           move.b 14(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

	jsr	aff_car

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
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea font,a2
           move.b 15(a1),d2
           asl.w #5,d2
           add.l d2,a2

; -> Affiche le caractere

	jsr	aff_car

; ---------------------------------------
; Routine d'affichage du caractere no: 16
; ---------------------------------------

           move.l 	screen1,a6
				
           moveq 	#0,d0
           moveq 	#0,d1
           moveq 	#0,d2
           moveq 	#0,d7
         
; -> Calcul adresse d'affichage

           move.w 	(a0),d0            ; x dans d0
           move.w 	2(a0),d1           ; y dans d1
           bsr 	test
           move.w 	d0,d7              ; x dans d7
           and.l 	#15,d7             ; Decalage mod 15
           lsr.w 	#1,d0              ; x / 2
           andi.w 	#$f8,d0            ; AND - 8
           add.w 	d0,d1              ; x + y * 160
           add.l 	d1,a6              ; adresse d'affichage
				
; -> Sauvegarde du fond

	jsr	save_fond

; -> Calcul adresse caractere

           lea 	font,a2
           move.b 	16(a1),d2
           asl.w 	#5,d2			 						
           add.l 	d2,a2

; -> Affichage du caractere no 16

i          set 0
           rept 15
           moveq #0,d0
	moveq #0,d6
           move.w (a2)+,d0	; Sprite dans d0...
	jsr car_1		; Cache
	move.w d0,d6	; ... et dans d6
           ror.l d7,d0	; Rotation Sprite
	ror.l d7,d6	; Rotation masque
	not.l d6		; Masque dans d6
	and.w d6,i(a6)	; Masque AND fond (plan 1)
           or.w d0,i(a6)	; Sprite OR fond
	and.w d6,i+2(a6)	; Masque AND fond (plan 2)
	and.w d6,i+4(a6)	; Idem plan 3
	and.w d6,i+6(a6)	; Idem plan 4
           swap d0
	swap d6
	and.w d6,i+8(a6)      
           or.w d0,i+8(a6)
	and.w d6,i+10(a6)  	
	and.w d6,i+12(a6)     
	and.w d6,i+14(a6)     
i          set i+160
           endr

;
; --------------------------
; Deplacement des caracteres
; --------------------------
;

           addq.l 	#4,coor_ptr
           cmp.l 	#coor+40,coor_ptr
           bne.s 	circle
           move.l 	#coor,coor_ptr
           addq.l 	#1,txt_ptr
           cmp.l 	#fin_txt,txt_ptr
           bne.s 	circle
           move.l 	#txt,txt_ptr

; ---------------------
; Deplacement du cercle
; ---------------------

circle     move.l 	wave_ptr,a0
           addq.l 	#4,a0                  ; Adresse coordonnees+4
           cmp.l 	wave_end,a0            ; Fini
           bne.s 	move_it                ; Non ...

; ----------------
; Test du compteur
; ----------------

           move.l 	anim,d0
           subq.l 	#1,d0
           bne.s 	couac

; --------------
; Nouvelle vague
; --------------

           move.l 	script_ptr,a1
           add.l 	#12,a1
           cmp.l 	#wave_0,a1
           bne.s 	new_wave
           move.l 	#script,a1
new_wave   move.l 	a1,script_ptr
           move.l 	(a1),d0
           move.l 	4(a1),wave_deb
           move.l 	8(a1),wave_end
 
couac      move.l 	d0,anim
           move.l 	wave_deb,a0           ; Et si, retour au depart       

move_it    move.l 	a0,wave_ptr


; ---------------------------------------------------
; Pointeur pour apparition/disparition d'un caractere
; ---------------------------------------------------

	addq.w 	#1,cach_ptr
	cmp.w 	#10,cach_ptr
	bne.s 	permute
	clr.w	cach_ptr
;
; ***************************************************************
; Swapping des ecrans logic/physic et des buffers d'effacement
; ***************************************************************
;

permute    move.l 	eff_1,d0
           move.l 	eff_2,eff_1
           move.l 	d0,eff_2

           move.l 	screen1,d0
           move.l 	screen2,screen1
           move.l 	d0,screen2

           lsr.l 	#8,d0
           move.w 	#$8200,a0
           movep.w 	d0,1(a0)

	clr.w 	$ffff8240.w
           rte                         ; Fin programme principal

; ***************************************************************
; Routine pour la disparition d'un caractere
; ***************************************************************

car_0:

	move.w	cach_ptr,d5
           asl.w	#1,d5
	move.w 	0(a5,d5.w),d5
	and.w	d5,d0
	rts

; ***************************************************************
; Routine l'apparition d'un caractere
; ***************************************************************

car_1:

	move.w	cach_ptr,d5
           asl.w	#1,d5
	move.w 	20(a5,d5.w),d5
	and.w	d5,d0
	rts

; ***************************************************************
; Routine d'affichage d'un caractere
; ***************************************************************

aff_car:

i          set 0
           rept 15
           moveq #0,d0
	moveq #0,d6
           move.w (a2)+,d0	; Sprite dans d0...
	move.w d0,d6	; ... et dans d6
           ror.l d7,d0	; Rotation Sprite
	ror.l d7,d6	; Rotation masque
	not.l d6		; Masque dans d6
	and.w d6,i(a6)	; Masque AND fond (plan 1)
           or.w d0,i(a6)	; Sprite OR fond
	and.w d6,i+2(a6)	; Masque AND fond (plan 2)
	and.w d6,i+4(a6)	; Idem plan 3
	and.w d6,i+6(a6)	; Idem plan 4
           swap d0
	swap d6
	and.w d6,i+8(a6)      
           or.w d0,i+8(a6)
	and.w d6,i+10(a6)  	
	and.w d6,i+12(a6)     
	and.w d6,i+14(a6)     
i          set i+160
           endr
	rts

; ***************************************************************
; Routine de sauvegarde du fond
; ***************************************************************
;
; Adresse :   4 octets
; Donnees : 240 octets (8 plans * 2 octets * 15 lignes)

save_fond:

	move.l 	a6,(a3)+		; Adresse caractere
i	set	0
	rept 	15
	move.l 	i(a6),(a3)+	
	move.l 	4+i(a6),(a3)+
	move.l 	8+i(a6),(a3)+	
	move.l 	12+i(a6),(a3)+
i	set	i+160
	endr
	rts

;
; ***************************************************************
; Routine de tests pour l'ecrasement du cercle
; ***************************************************************
;

test:

	move.l 	wave_ptr,a2

; ------------------
; Test gauche/droite
; ------------------

           add.w 	(a2),d0	; x = x + offset
           tst.w 	d0	; x > 0 ?	
           bgt.s 	ok_gauche	; Pas de depassement a gauche
           moveq 	#0,d0	; Oui, x = 0
ok_gauche  cmp.w 	#304,d0	; x < 304 ?
           blt.s 	ok_droite	; Pas de depassement a droite
           move.w 	#304,d0	; Oui, x = 304

; -------------
; Test haut/bas
; -------------

ok_droite  add.w 	2(a2),d1
	tst.w	d1
	bgt.s	ok_haut
	moveq 	#0,d1
ok_haut	cmp.w	#184,d1
	blt.s	ok_bas
	move.w	#184,d1
ok_bas	add.w 	d1,d1
	move.w	0(a4,d1.w),d1
           rts

; ***************************************************************
; Donnees & variables pour le deplacement des caracteres
; ***************************************************************

font       incbin 	"A:\CDOC.SRC\DATA\FONTCAR1.DAT"
coor       incbin 	"A:\CDOC.SRC\DATA\CIRCLE.DAT"
           
;
; Surtout ne pas enlever les 44 !!! Sinon je ne reponds de rien !
; 

txt        dc.b 	44,44,44,44,44,44,44,44,44
	dc.b	44,44,44,44,44,44,44,44,44
           incbin 	"A:\CDOC.SRC\DATA\TEXTE.DAT"
fin_txt    dc.b 	44,44,44,44,44,44,44,44,44
	dc.b	44,44,44,44,44,44,44,44,44
           even

eff_1      ds.l 	1
eff_2      ds.l 	1
txt_ptr    ds.l 	1
coor_ptr   ds.l 	1
eff_tab1   ds.b 	244*17
eff_tab2   ds.b 	244*17

;
; ***************************************************************
; Donnees & variables pour le deplacement du cercle
; ***************************************************************
;


; ---------------------------------------------------------------
;               - SCRIPT DE DEPLACEMENT DU CERCLE -
;
; dc.l nbr_fois,wave_n,fin_wave
;
;          nbr_fois: Nbre de fois que le cercle fera le deplacement
;          wave_n  : Type de deplacement (0 < n < 4)          
;          fin_wave: Adresse de fin du deplacement wave_n
; 
; wave_0 : Le cercle ne bouge pas ...!
; wave_1 : Le cercle de deplace a gauche & droite 
; wave_2 : Le cercle rebondit
; wave_3 : Le cercle rebondit et se deplace a gauche & a droite
; wave_4 : Le cercle tourne en spirale et revient a sa place
;
; --------------------------------------------------------------- 
 
script     dc.l 	0002,wave_2,wave_2+0136
           dc.l 	0001,wave_4,wave_4+0728
           dc.l 	0001,wave_3,wave_3+0544
           dc.l 	0001,wave_1,wave_1+3600
           dc.l 	0200,wave_0,wave_0+0004
           dc.l 	0002,wave_4,wave_4+0728
           dc.l 	0002,wave_3,wave_3+0544
           dc.l 	0004,wave_2,wave_2+0136
           dc.l 	0001,wave_1,wave_1+3600
           dc.l 	0004,wave_4,wave_4+0728
           dc.l 	0200,wave_0,wave_0+0004
           dc.l 	0004,wave_4,wave_4+0728
          
; -------------------------
; Fichiers des deplacements
; -------------------------

wave_0     dc.w 	0,0         	        ; Fin: wave_0 + 0004
wave_1     incbin 	"A:\CDOC.SRC\DATA\WAVE_1.DAT" ; Fin: wave_1 + 3600
wave_2     incbin 	"A:\CDOC.SRC\DATA\WAVE_2.DAT" ; Fin: wave_2 + 0136
wave_3     incbin 	"A:\CDOC.SRC\DATA\WAVE_3.DAT" ; Fin: wave_3 + 0544
wave_4	incbin 	"A:\CDOC.SRC\DATA\WAVE_4.DAT" ; Fin: wave_4 + 0728

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

; ----------------------------- 
; Variables pour le deplacement
; -----------------------------

script_ptr ds.l 	1            ; Adresse en cours (script)
wave_ptr   ds.l 	1            ; Adresse en cours (coordonnees)
wave_deb   ds.l 	1            ; Adresse debut wave
wave_end   ds.l 	1            ; Adresse fin wave
anim       ds.l 	1            ; Nombre de fois

;
; ***************************************************************
; Donnees & variables pour l'ensemble du programme
; ***************************************************************
;      

cache      dc.w 	%1111111111111111	; Disparition
	dc.w	%1111111111111111
	dc.w	%1111111111111100
	dc.w	%1111111111110000
	dc.w	%1111111111000000
	dc.w	%1111111100000000
	dc.w	%1111110000000000
	dc.w	%1111000000000000
	dc.w	%1100000000000000
	dc.w	%0000000000000000

           dc.w       %0000000000000000	; Apparition
           dc.w       %0000000000000011
           dc.w       %0000000000001111
           dc.w       %0000000000111111
           dc.w       %0000000011111111
           dc.w       %0000001111111111
           dc.w       %0000111111111111
           dc.w       %0011111111111111
           dc.w       %1111111111111111
           dc.w       %1111111111111111

cach_ptr   ds.l 	1
save_hbl   ds.l 	1
save_118   ds.l 	1
save_vbl   ds.l 	1
oldscreen  ds.l 	1
screen1    ds.l 	1
screen2    ds.l 	1
oldssp     ds.l 	1

oldrez     ds.w 	1
oldpal     ds.w 	16

save_vect  ds.b 	1
save_iera  ds.b 	1
save_ierb  ds.b 	1
save_imra  ds.b 	1
savea11    ds.b 	1
key        ds.b 	1
           even

; ---------------------------------------------------
; Charge les fichiers (dessins, fontes, musiques ...)
; ---------------------------------------------------

music      incbin 	"A:\CDOC.SRC\MUSIC\DECMENU.SND"

; Ici tu mets le nom de ton dessin .PI1

picture    incbin 	"A:\CDOC.SRC\PICTURE\EXEMPLE.PI1"
