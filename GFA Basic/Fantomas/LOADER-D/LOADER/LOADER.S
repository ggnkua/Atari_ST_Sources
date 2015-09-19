;
; ***************************************************************
;
; LOADER DE FICHIER POUR UNE DEMO
; (C) FANTOMAS 06/92
; ***************************************************************
;

	opt O+

;
; ---------------------------------------------------------------
; Passage en mode SUPERVISEUR
; ---------------------------------------------------------------
;

	clr.l 	-(sp)
	move.w 	#32,-(sp)
	trap	#1
	addq.l 	#2,sp
	move.l 	d0,super

;
; ---------------------------------------------------------------
; Bloque la souris
; ---------------------------------------------------------------
;

           dc.w 	$a00a		; Souris cach‚e ...
           move.b 	#$12,$fffffc02.w	; ... et d‚sactiv‚e


;
; ---------------------------------------------------------------
; Bloque le clavier
; ---------------------------------------------------------------
;

	move.b 	$484.w,key		; Sauve clavier
	clr.b 	$484.w		; Clavier OFF

;
; ---------------------------------------------------------------
; Initialise le RESET
; ---------------------------------------------------------------
;

  	move.l 	#$31415926,$426.w	; Magic Number
           move.l 	#reset,$42a.w

;
;
;

	move.l	#ecr_lst,ecr_ptr	; Init chargement

;
; ***************************************************************
; 
; CHARGEMENT ET LANCEMENT DE L'INTRO
;
; ***************************************************************
;

	jsr 	init		; Init Loader
	move.l	#ecr_0,pathfile	; Nom & chemin intro
	jsr	load		; Charge intro
	addq.l	#8,ecr_ptr      	; Init suite
	move.l	#lance,a0		; Adresse du HEADER
	jsr	decod		; Decodage
	move.l	#lance,a0		; Adresse du HEADER
	jsr	reloc		; Relocation
	jmp 	fin		; Lance l'intro

;
; ***************************************************************
; 
; CHARGEMENT DES DIFFERENTS ECRANS
;
; ***************************************************************
;

debut	jsr	init		; Init Loader
	move.l	4(a6),pathfile	; Nom du fichier
           jsr 	load		; Charge fichier
	move.l 	#lance,a0		; Adresse HEADER
	jsr	decod		; Decodage
	move.l	#lance,a0		; Adresse HEADER
           jsr 	reloc		; Relocation
	move.l 	#messag+330,message	; PRESS SPACE 

wait_1	cmp.b 	#$39,$fffffc02.w	; Appui sur SPACE
	bne.s 	wait_1		; Non
wait_2     cmp.b 	#$39+$80,$fffffc02.w	; Relachement
	bne.s 	wait_2		; Non

	addq.l	#8,ecr_ptr		; Prochain fichier

;
; ***************************************************************
;
; STOPPE LE LOADER
;
; ***************************************************************
;

fin	clr.b	$fffffa1b.w	; Stoppe TIMER B
	move.l	save_vbl,$70.w	; Restore VBL

;
; ***************************************************************
;
; RESTORE LES INTERRUPTIONS
;
; ***************************************************************
;

	move.l	save_hbl,$120.w	; Restore HBL
	move.l	save_118,$118.w	; Restore clavier

           move.b 	save_iera,$fffffa07.w ; Restore IERA
           move.b 	save_ierb,$fffffa09.w ; Restore IERB
           move.b 	save_imra,$fffffa13.w	; Restore IMRA
           move.b 	savea11,$fffffa11.w	
           move.b 	save_vect,$fffffa17.w


;
; ***************************************************************
;
; STOPPE LA MUSIC
;
; ***************************************************************
;

           move.b 	#$8,$ffff8800.w	; Voie A
	clr.b 	$ffff8802.w	; OFF
           move.b 	#$9,$ffff8800.w	; Voie B
	clr.b 	$ffff8802.w	; OFF
           move.b 	#$a,$ffff8800.w	; Voie C
	clr.b	$ffff8802.w	; OFF
           
;
; ***************************************************************
;
; LANCEMENT DU FICHIER
;
; ***************************************************************
;

	move.l 	#debut,-(sp)	; Empile adr. LOADER
	move.l 	#lance+$1c,a0	; Lance le fichier
	jmp 	(a0)

;
; ***************************************************************
; *                                                             *
; * ANIMATION PENDANT LE CHARGEMENT (LOADER)                    *
; *                                                             *
; ***************************************************************
;

loader:

;
; ***************************************************************
; Sauve les registres
; ***************************************************************
;

          movem.l	d0-d7/a0-a6,-(sp)

;
; ***************************************************************
; Initialise les rasters
; ***************************************************************
;

	clr.w 	$ffff8240.w
	move.l	#rasters,rast_ptr
	move.b	#10,cmptr
	move.l	#hbl,$120.w
	move.b 	#1,$fffffa21.w
	move.b 	#8,$fffffa1b.w

;
; ***************************************************************
; Joue la music 
; ***************************************************************
;

	jsr 	music+8

;
; ---------------------------------------------------------------
; Affiche les messages 'LOADING' et 'PRESS SPACE'
; ---------------------------------------------------------------
;

	move.l message,a0
	move.l screen1,a1
i	set 0
	rept 15
	move.w (a0)+,200+i+4(a1)
	move.w (a0)+,200+i+12(a1)
	move.w (a0)+,200+i+20(a1)
	move.w (a0)+,200+i+28(a1)
	move.w (a0)+,200+i+36(a1)
	move.w (a0)+,200+i+44(a1)
	move.w (a0)+,200+i+52(a1)
	move.w (a0)+,200+i+60(a1)
	move.w (a0)+,200+i+68(a1)
	move.w (a0)+,200+i+76(a1)
	move.w (a0)+,200+i+84(a1)
i	set i+160
	endr

;
; ---------------------------------------------------------------
; Grossissement sphere
; ---------------------------------------------------------------
;

	addq.w 	#1,dummy
	cmp.w 	#3,dummy
	bne.s	dep_1	

	clr.w 	dummy
	move.l 	sph_ptr,a0
	addq.l 	#4,a0
	cmp.l 	#effac_1,a0
	bne.s	pas
	lea 	sph_lst,a0
pas	move.l 	a0,sph_ptr
	move.l 	(a0),spheres

;
; ---------------------------------------------------------------
; Deplacement sphere
; ---------------------------------------------------------------
;

dep_1	move.l 	dep_ptr,a0
	addq.l 	#4,a0
	cmp.l 	#sph_lst,a0
	bne.s	non
	lea 	dep_lst,a0
non	move.l 	a0,dep_ptr
	move.w 	(a0),centr_x
	move.w     2(a0),centr_y

;
; ---------------------------------------------------------------
; Efface les points
; ---------------------------------------------------------------
;

clear      move.l 	efface1,a0
           rept 30
           movem.l 	(a0)+,a1-a6
           clr.w	(a1)
           clr.w 	(a2)
           clr.w 	(a3)
           clr.w 	(a4)
           clr.w 	(a5)
           clr.w 	(a6)
           endr
 
;
; ---------------------------------------------------------------
; Test de l'angle y
; ---------------------------------------------------------------
;

           move.w 	angle_y,d7
           addq.w 	#6,d7

tst1       cmp.w 	#718,d7
           blt.s 	int
           sub.w 	#718,d7

;
; ---------------------------------------------------------------
; Initialisation calculs
; ---------------------------------------------------------------
;

int       	move.w 	d7,angle_y		; Sauvegarde angle

           lea 	cosin,a0		; Table des cosinus
           lea 	cosin+720,a1	; Table des sinus
           move.w 	(a0,d7.w),d6	; Cos(angle_y) dans d6
           move.w 	(a1,d7.w),d7	; Sin(angle_y) dans d7

	move.l	screen1,a0		; Adresse de l'ecran
	lea 	pos_x,a2		; Table des abscisses
	lea	pos_y,a3		; Table des ordon‚es
           move.l 	spheres,a4		; Adresse de la sphere
           move.l 	efface1,a6		; Buffer d'‚ffacement
           move.w 	#29,d5		; (29+1)*6 =180 points


calc	move.b 	(a4)+,d0		; x
           move.b 	(a4)+,d1		; y
           move.b 	(a4)+,d2		; z
	ext.w 	d0		; Extension sur 1 mot
	ext.w 	d1		; Extension sur 1 mot
	ext.w	d2		; Extension sur 1 mot

; ---------------------------------------------------------------
;
; CALCUL DE LA ROTATION SUIVANT Y
;
;  x = x * cos(ay) + z * sin(ay)
;  z = z * cos(ay) - x * sin(ay) 
; ---------------------------------------------------------------

	move.w 	d0,d3	; Copie de x
	move.w 	d2,d4	; Copie de z
           muls 	d6,d0	; x * cos(ay)
           muls 	d7,d4	; z * sin(ay)
           add.w 	d4,d0	; x * cos(ay) + z * sin(ay)
           asr.w 	#8,d0      ; mise a jour de x -> d0

	muls	d6,d2	; z * cos(ay)
	muls	d7,d3	; x * sin(ay)
	sub.w 	d3,d2	; z * cos(ay) - x * sin(ay)
	asr.w 	#8,d2	; mise a jour de z -> d2


; 
; ---------------------------------------------------------------
; Centrage dans l'ecran
; ---------------------------------------------------------------
; 

           add.w 	centr_x,d0
           add.w 	centr_y,d1

; 
; ---------------------------------------------------------------
; Affiche le point
; ---------------------------------------------------------------
; 

           lea 	(a0),a5
           add.w 	d1,d1
           adda.w 	(a3,d1.w),a5
           add.w 	d0,d0
           add.w 	d0,d0
           adda.w 	(a2,d0.w),a5
           move.w 	2(a2,d0.w),d1
	tst.w	d2
	bge.s	ok_1
	addq.l	#2,a5
ok_1       move.l 	a5,(a6)+
           or.w 	d1,(a5)

; ---------------------------------------------------------------
; Meme chose qu'au dessus (2)
; ---------------------------------------------------------------

	move.b 	(a4)+,d0
           move.b 	(a4)+,d1
           move.b 	(a4)+,d2
	ext.w 	d0
	ext.w 	d1
	ext.w	d2	

	move.w 	d0,d3	; Copie de x
	move.w 	d2,d4	; Copie de z
           muls 	d6,d0	; x * cos(ay)
           muls 	d7,d4	; z * sin(ay)
           add.w 	d4,d0	; x * cos(ay) + z * sin(ay)
           asr.w 	#8,d0      ; mise a jour de x -> d0

	muls	d6,d2	; z * cos(ay)
	muls	d7,d3	; x * sin(ay)
	sub.w 	d3,d2	; z * cos(ay) - x * sin(ay)
	asr.w 	#8,d2	; mise a jour de z -> d2
           
           add.w 	centr_x,d0
           add.w 	centr_y,d1

           lea 	(a0),a5
	add.w 	d1,d1
           adda.w 	(a3,d1.w),a5
           add.w 	d0,d0
           add.w 	d0,d0
           adda.w 	(a2,d0.w),a5
           move.w 	2(a2,d0.w),d1
	tst.w	d2
	bge.s	ok_2
	addq.l	#2,a5
ok_2       move.l 	a5,(a6)+
           or.w 	d1,(a5)

;
; ---------------------------------------------------------------
; Heu... toujour pareil !
; ---------------------------------------------------------------
;

	move.b 	(a4)+,d0
           move.b 	(a4)+,d1
           move.b 	(a4)+,d2
	ext.w 	d0
	ext.w 	d1
	ext.w	d2	


	move.w 	d0,d3	; Copie de x
	move.w 	d2,d4	; Copie de z
           muls 	d6,d0	; x * cos(ay)
           muls 	d7,d4	; z * sin(ay)
           add.w 	d4,d0	; x * cos(ay) + z * sin(ay)
           asr.w 	#8,d0      ; mise a jour de x -> d0

	muls	d6,d2	; z * cos(ay)
	muls	d7,d3	; x * sin(ay)
	sub.w 	d3,d2	; z * cos(ay) - x * sin(ay)
	asr.w 	#8,d2	; mise a jour de z -> d2
           add.w 	centr_x,d0
           add.w 	centr_y,d1

           lea 	(a0),a5
           add.w 	d1,d1
           adda.w 	(a3,d1.w),a5
           add.w 	d0,d0
           add.w 	d0,d0
           adda.w 	(a2,d0.w),a5
           move.w 	2(a2,d0.w),d1
	tst.w	d2
	bge.s	ok_3
	addq.l	#2,a5
ok_3       move.l 	a5,(a6)+
           or.w 	d1,(a5)

;
; ---------------------------------------------------------------
; Oui, c'est encore la meme chose ...
; ---------------------------------------------------------------
;

	move.b 	(a4)+,d0
           move.b 	(a4)+,d1
           move.b 	(a4)+,d2
	ext.w 	d0
	ext.w 	d1
	ext.w	d2	


	move.w 	d0,d3	; Copie de x
	move.w 	d2,d4	; Copie de z
           muls 	d6,d0	; x * cos(ay)
           muls 	d7,d4	; z * sin(ay)
           add.w 	d4,d0	; x * cos(ay) + z * sin(ay)
           asr.w 	#8,d0      ; mise a jour de x -> d0

	muls	d6,d2	; z * cos(ay)
	muls	d7,d3	; x * sin(ay)
	sub.w 	d3,d2	; z * cos(ay) - x * sin(ay)
	asr.w 	#8,d2	; mise a jour de z -> d2
           add.w 	centr_x,d0
           add.w 	centr_y,d1

           lea 	(a0),a5
           add.w 	d1,d1
           adda.w 	(a3,d1.w),a5
           add.w 	d0,d0
           add.w 	d0,d0
           adda.w 	(a2,d0.w),a5
           move.w 	2(a2,d0.w),d1
	tst.w	d2
	bge.s	ok_4
	addq.l 	#2,a5
ok_4       move.l 	a5,(a6)+
           or.w 	d1,(a5)

;
; ------------------------
; C'est la derniere fois !
; ------------------------
;

	move.b 	(a4)+,d0
           move.b 	(a4)+,d1
           move.b 	(a4)+,d2
	ext.w 	d0
	ext.w 	d1
	ext.w	d2	

	move.w 	d0,d3	; Copie de x
	move.w 	d2,d4	; Copie de z
           muls 	d6,d0	; x * cos(ay)
           muls 	d7,d4	; z * sin(ay)
           add.w 	d4,d0	; x * cos(ay) + z * sin(ay)
           asr.w 	#8,d0      ; mise a jour de x -> d0

	muls	d6,d2	; z * cos(ay)
	muls	d7,d3	; x * sin(ay)
	sub.w 	d3,d2	; z * cos(ay) - x * sin(ay)
	asr.w 	#8,d2	; mise a jour de z -> d2
           add.w 	centr_x,d0
           add.w 	centr_y,d1

           lea 	(a0),a5
           add.w 	d1,d1
           adda.w 	(a3,d1.w),a5
           add.w 	d0,d0
           add.w 	d0,d0
           adda.w 	(a2,d0.w),a5
           move.w 	2(a2,d0.w),d1
	tst.w	d2
	bge.s	ok_5
	addq.l 	#2,a5
ok_5       move.l 	a5,(a6)+
           or.w 	d1,(a5)

;
; --------------------------------------------------------------- 
; Enfin de compte, j'en rajoute un ...
; ---------------------------------------------------------------
;

	move.b 	(a4)+,d0
           move.b 	(a4)+,d1
           move.b 	(a4)+,d2
	ext.w 	d0
	ext.w 	d1
	ext.w	d2	

	move.w 	d0,d3	; Copie de x
	move.w 	d2,d4	; Copie de z
           muls 	d6,d0	; x * cos(ay)
           muls 	d7,d4	; z * sin(ay)
           add.w 	d4,d0	; x * cos(ay) + z * sin(ay)
           asr.w 	#8,d0      ; mise a jour de x -> d0

	muls	d6,d2	; z * cos(ay)
	muls	d7,d3	; x * sin(ay)
	sub.w 	d3,d2	; z * cos(ay) - x * sin(ay)
	asr.w 	#8,d2	; mise a jour de z -> d2
           add.w 	centr_x,d0
           add.w 	centr_y,d1

           lea 	(a0),a5
           add.w 	d1,d1
           adda.w 	(a3,d1.w),a5
           add.w 	d0,d0
           add.w 	d0,d0
           adda.w 	(a2,d0.w),a5
           move.w 	2(a2,d0.w),d1
	tst.w	d2
	bge.s	ok_6
	addq.l 	#2,a5
ok_6       move.l 	a5,(a6)+
           or.w 	d1,(a5)
         
           dbra 	d5,calc

;
; ***************************************************************
; *                                                             *
; * SCROLLTEXT 8X8                                              *
; *                                                             *
; ***************************************************************
;

; +---------------+
; | Test pointeur |
; +---------------+

           move.w 	bit,d0
           cmp.w 	#8,d0
           bne.s 	pas_car
           clr.w 	bit

; +-----------------+
; | Nouvelle lettre |
; +-----------------+

           move.l 	ptr,a1
           move.b 	(a1),d0
           cmp.b 	#255,d0
           bne.s 	lsuite
	move.l 	ecr_ptr,a0
           move.l 	(a0),ptr
           move.l 	ptr,a1
           move.b 	(a1),d0
lsuite     addq.l 	#1,ptr

; +-----------------------+
; | Calcul adresse lettre |
; +-----------------------+

           asl.w 	#3,d0
           lea 	font,a1
           add.w 	d0,a1

; +---------------------+
; | Caractere -> Buffer |
; +---------------------+

           lea 	buffer,a2
i          set 	0
           rept 	7
           move.b 	(a1)+,i(a2)
i          set 	i+2
           endr

pas_car    addq.w 	#1,bit

; +--------------------------------+
; | Buffer + petit scroll a gauche |
; +--------------------------------+

           lea 	trav,a1
           lea 	buffer,a2
i          set 	0
           rept 	7
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

; +------------------+
; | Travail -> Ecran |
; +------------------+

           move.l 	screen1,a1
           lea 	trav,a2
i          set 	4+190*160
           rept 7
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

;
; ***************************************************************
; Permutation ecrans & buffers effacement
; ***************************************************************
;

           move.l 	efface1,d0
           move.l 	efface2,efface1
           move.l 	d0,efface2

           move.l 	screen1,d0
           move.l 	screen2,screen1
           move.l 	d0,screen2

           lsr.l 	#8,d0
           move.w 	#$8200,a0
           movep.w 	d0,1(a0)

;
; ***************************************************************
; Restore les registres
; ***************************************************************
;

	movem.l	(sp)+,d0-d7/a0-a6

;
; ***************************************************************
; Fin du LOADER
; ***************************************************************
;

	rte

;
; ***************************************************************
; *                                                             *  
; * ROUTINE DECLENCHEE PAR APPUI SUR RESET                      *
; *                                                             *
; ***************************************************************
;
				
reset	move.b 	#2,$ffff820a.w	; Passage en 50Hz
	jsr	init		; Init Loader
  	move.l 	#ecr_2,pathfile	; Nom & chemin 
	jsr 	load		; Charge fichier
	move.l 	#lance,a0		; Relocation fichier
	jsr 	reloc

	clr.b	$fffffa1b.w
	move.l	save_vbl,$70.w
	move.l	save_hbl,$120.w
	move.l	save_118,$118.w
           move.b 	save_iera,$fffffa07.w
           move.b 	save_ierb,$fffffa09.w
           move.b 	save_imra,$fffffa13.w
           move.b 	savea11,$fffffa11.w
           move.b 	save_vect,$fffffa17.w

; -----------------
; Stoppe la musique
; -----------------

           move.b 	#$8,$ffff8800.w
	clr.b 	$ffff8802.w
           move.b 	#$9,$ffff8800.w
	clr.b 	$ffff8802.w
           move.b 	#$a,$ffff8800.w
	clr.b	$ffff8802.w

; -----------------------
; Lance le fichier charg‚
; -----------------------

	move.l 	#debut,-(sp)
	move.l 	#lance+$1c,a0
	jmp 	(a0)

;
; ***************************************************************
; 
; ROUTINE D'AFFICHAGE DES RASTERS
;
; ***************************************************************
;

hbl        move.l	a3,-(sp)
	movea.l	rast_ptr,a3
	move.w 	(a3),$ffff8248.w
	addq.l	#2,rast_ptr
	subq.b	#1,cmptr
	beq.s 	fin_hbl
	move.l	(sp)+,a3
           rte

fin_hbl	clr.b	$fffffa1b.w
	move.b 	#100,$fffffa21.w
	move.l	#hbl2,$120.w
	move.b     #8,$fffffa1b.w
	move.l	(sp)+,a3
	rte

hbl2       clr.b 	$fffffa1b.w
	move.b 	#1,$fffffa21.w
	move.b     #70,cmptr
	move.l	#hbl3,$120.w
	move.b	#8,$fffffa1b.w
	rte

hbl3       move.l	a3,-(sp)
	movea.l	rast_ptr,a3
	move.w 	(a3),$ffff8240.w
	addq.l	#2,rast_ptr
	subq.b	#1,cmptr
	beq.s 	fin_hbl3
	move.l	(sp)+,a3
           rte

fin_hbl3   clr.b	$fffffa1b.w
	move.l	(sp)+,a3
	rte
     
newkey     move.w 	#$2500,sr
           bclr 	#6,$fffffa11.w
           rte

; ***************************************************************
;
; INITIALISATION DU LOADER
;
; ***************************************************************
;

init:

; +------------------+
; | Initialise music |
; +------------------+
	
       	moveq 	#1,d0
           jsr	music

; +--------------------------+
; | Adresses des deux ecrans |
; +--------------------------+

	move.l 	#$60000,screen1	; 1er ecran
	move.l 	#$67d00,screen2 	; 2me ecran
	
; +------------------+
; | Basse r‚solution |
; +------------------+

           clr.b 	$ffff8260.w	; Basse r‚solution
	
; +---------------------+
; | Efface les 2 ecrans |
; +---------------------+

	move.l	screen1,a0		
	move.l 	screen2,a1
	move.w 	#7999,d0
eff_ecr	clr.l 	(a0)+
	clr.l	(a1)+
	dbf	d0,eff_ecr

; +----------------------------+
; | Init effacement des points |
; +----------------------------+

;	move.l 	#effac_1,efface1
;	move.l 	#effac_2,efface2

	move.l	screen1,a0
	move.l	efface1,a1
	move.l	efface2,a2
	move.w	#179,d0
init_eff	move.l	a0,(a1)+
	move.l	a0,(a2)+
	dbf	d0,init_eff

; +-------------+
; | Init sphere |
; +-------------+

	move.l 	#sphere0,spheres
	move.w 	#159,centr_x
	move.w 	#99,centr_y

; +--------------+
; | Init palette |
; +--------------+

	lea 	palette,a0
	lea 	$ffff8240.w,a1
	movem.l 	(a0)+,d0-d7
	movem.l	d0-d7,(a1)

; +----------------+
; | Init animation |
; +----------------+

	move.l 	#sph_lst,sph_ptr
	move.l 	#dep_lst,dep_ptr

; +--------------------------+
; | Efface buffer de travail |
; +--------------------------+
 
	lea 	trav,a0
	move.w 	#69,d0
eff_trav   clr.l 	(a0)+
	dbf 	d0,eff_trav
	
; +--------------------------+
; | Efface buffer caracteres |
; +--------------------------+

	lea 	buffer,a0
	moveq.w 	#6,d0
eff_buff	clr.w	(a0)+
	dbf	d0,eff_buff

; +-----------------+
; | Pointeur a zero |
; +-----------------+

	clr.w	bit

; +------------------+
; | Adresse du texte |
; +------------------+

	move.l	ecr_ptr,a6
	move.l	(a6),ptr

; ***************************************************************
; Init messages 'LOADING' et 'PRESS SPACE'
; ***************************************************************

	move.l 	#messag,message

; ***************************************************************
; Init interruptions 
; ***************************************************************

; +---------------+
; | Sauve valeurs |
; +---------------+

           move.b 	$fffffa07.w,save_iera
           move.b 	$fffffa09.w,save_ierb
           move.b 	$fffffa13.w,save_imra
           move.b 	$fffffa11.w,savea11
           move.b 	$fffffa17.w,save_vect
	move.l	$70.w,save_vbl
           move.l 	$120.w,save_hbl
           move.l 	$118.w,save_118

; +-------------------+
; | Nouvelles valeurs |
; +-------------------+

           and.b 	#0,$fffffa07.w
           and.b 	#$40,$fffffa09.w
           bclr 	#3,$fffffa17.w	; Automatic end of interrupt
           or.b 	#1,$fffffa07.w
           or.b 	#1,$fffffa13.w
	clr.b	$fffffa1b.w	; Stoppe TIMER B
           move.l 	#newkey,$118.w 	; Nouvelle interrup. clavier

;
; ***************************************************************
; Installe le LOADER sous VBL
; ***************************************************************
;

	move.l 	#loader,$70.w

	rts

;
; ***************************************************************
; *                                                             *
; * ROUTINE DE CHARGEMENT D'UN FICHIER                          *
; *                                                             *
; ***************************************************************
;

load:

; +------------------+
; | Ouvre le fichier |
; +------------------+

	clr.w 	-(sp)
	move.l 	pathfile,-(sp)
	move.w 	#$3d,-(sp)
	trap 	#1
	addq.l 	#8,sp
	move.w 	d0,n_log1

; +-------------------+
; | Charge le fichier |
; +-------------------+

	move.l 	#lance,-(sp)
	move.l 	#200000,-(sp)
	move.w 	n_log1,-(sp)
	move.w 	#$3f,-(sp)
	trap 	#1
	lea 	12(sp),sp
	move.l	d0,length

; +--------------------+
; | Referme le fichier |
; +--------------------+
	
	move.w 	n_log1,-(sp)
	move.w 	#$3e,-(sp)
	trap 	#1
	addq.w 	#4,sp

           rts

;
; ***************************************************************
; *                                                             *
; * ROUTINE DE RELOCATION (MERCI A TBC ...)                     *
; *                                                             *
; ***************************************************************
;

reloc      move.l 	2(a0),d0		; Longueur du PRG
	add.l	6(a0),d0		; 
	add.l 	14(a0),d0 		;
	lea	$1c(a0),a0		; Adresse de debut
	movea.l	a0,a1
	movea.l	a0,a2
	move.l	a0,d1
	adda.l	d0,a1
	move.l	(a1)+,d0
	adda.l	d0,a2
	add.l	d1,(a2)
	moveq      #0,d0
reloc2	move.b	(a1),d0
	clr.b	(a1)+
	tst.b	d0
	beq.s	f_reloc
	cmp.b 	#1,d0
	beq.s	reloc3
	adda.l	d0,a2
	add.l	d1,(a2)
	bra.s	reloc2
reloc3	lea 	$fe(a2),a2
	bra.s	reloc2
f_reloc	rts

;
; ***************************************************************
; *                                                             *
; * ROUTINE DE DECODAGE DU FICHIER                              *
; *                                                             *
; ***************************************************************
;

decod	move.b	#%00100111,d1	; Cl‚ dans d1.b
	move.l	length,d0		; Taille dans d0
dec_1	eor.b	d1,(a0)+ 		; D‚codage ...
	subq.l	#1,d0
	bne.s	dec_1		; ... jusqu'a la fin
 	rts

;
; ***************************************************************
; *                                                             *
; * DONNEES ET VARIABLES                                        *
; *                                                             *
; ***************************************************************
;

;
; ***************************************************************
; Donnees generales
; ***************************************************************
;

rast_ptr   ds.l 1
super	ds.l 1
save_vbl   ds.l 1
save_hbl   ds.l 1
save_118   ds.l 1

cmptr      ds.w 1

key	ds.b 1
save_iera  ds.b 1
save_ierb  ds.b 1
save_imra  ds.b 1
save_imrb  ds.b 1
savea11    ds.b 1
save_vect  ds.b 1
	even

;
; ***************************************************************
; Donnees pour le chargement des fichiers
; ***************************************************************
;

ecr_lst	dc.l	txt_0,ecr_0
	dc.l 	txt_1,ecr_1
           dc.l 	txt_2,ecr_2
           dc.l 	txt_3,ecr_3
           dc.l 	txt_4,ecr_4
	dc.l 	txt_5,ecr_5

pathfile   ds.l 	1
length	ds.l 	1
ecr_ptr    ds.l 	1
message	ds.l 	1
n_log1	ds.w 	1
	even

; +---------------------+
; | Palette de couleurs |
; +---------------------+

palette	dc.w 	$000,$777,$444,$000,$777,$444,$000,$000
	dc.w 	$707,$000,$000,$000,$000,$000,$000,$000

; +----------------------------+
; | Nom des fichiers a charger |
; +----------------------------+

ecr_0      dc.b 	"F.DAT",0	; Intro
ecr_1      dc.b 	"B.DAT",0	; Font compil #1
ecr_2      dc.b 	"C.DAT",0	; Bigscroll
ecr_3      dc.b 	"A.DAT",0	; Font compil #2
ecr_4      dc.b 	"D.DAT",0  ; Neptune
ecr_5	dc.b	"E.DAT",0	; Pixel Show

; +---------------------------------------+
; | Textes affiches pendant le chargement |
; +---------------------------------------+

txt_0      incbin     "TEXTE_0.DAT" ; Loading INTRO
	dc.b	255
txt_1      incbin	"TEXTE_1.DAT" ; Loading FONT COMPIL #1
	dc.b	255
txt_2      incbin	"TEXTE_2.DAT" ; Loading BIGSCROLL
	dc.b	255
txt_3      incbin	"TEXTE_3.DAT" ; Loading FONT COMPIL #2
	dc.b	255
txt_4	incbin	"TEXTE_4.DAT" ; Loading NEPTUNE
	dc.b	255
txt_5	dc.b	255
	even

; +------------------------------------+ 
; | Messages 'LOADING' et 'PRESS SPACE |
; +------------------------------------+

messag     incbin 	"MESSAG.DAT"

;
; ***************************************************************
; Donnees pour le scrolltext 8x8
; ***************************************************************
;

ptr       ds.l 1

bit       ds.w 1
buffer    ds.w 7
trav      ds.w 20*7

font      incbin "FONT.DAT"

;
; ***************************************************************
; Donnees pour l'animation de la sphere
; ***************************************************************
;

;
; +---------------------------------+
; | Table des deplacements en x & y |
; +---------------------------------+
;

dep_lst    dc.w      159,99
           dc.w      162,101
           dc.w      165,103
           dc.w      169,104
           dc.w      172,106
           dc.w      175,107
           dc.w      179,108
           dc.w      182,108
           dc.w      185,108
           dc.w      188,108
           dc.w      191,107
           dc.w      194,106
           dc.w      197,104
           dc.w      199,103
           dc.w      202,101
           dc.w      204,99
           dc.w      207,96
           dc.w      209,94
           dc.w      211,93
           dc.w      213,91
           dc.w      215,90
           dc.w      216,89
           dc.w      218,89
           dc.w      219,89
           dc.w      220,89
           dc.w      221,90
           dc.w      222,91
           dc.w      223,93
           dc.w      223,94
           dc.w      223,96
           dc.w      224,99
           dc.w      223,101
           dc.w      223,103
           dc.w      223,104
           dc.w      222,106
           dc.w      221,107
           dc.w      220,108
           dc.w      219,108
           dc.w      218,108
           dc.w      216,108
           dc.w      215,107
           dc.w      213,106
           dc.w      211,104
           dc.w      209,103
           dc.w      207,101
           dc.w      204,99
           dc.w      202,96
           dc.w      199,94
           dc.w      197,93
           dc.w      194,91
           dc.w      191,90
           dc.w      188,89
           dc.w      185,89
           dc.w      182,89
           dc.w      179,89
           dc.w      175,90
           dc.w      172,91
           dc.w      169,93
           dc.w      165,94
           dc.w      162,96
           dc.w      159,99
           dc.w      155,101
           dc.w      152,103
           dc.w      148,104
           dc.w      145,106
           dc.w      142,107
           dc.w      138,108
           dc.w      135,108
           dc.w      132,108
           dc.w      129,108
           dc.w      126,107
           dc.w      123,106
           dc.w      120,104
           dc.w      118,103
           dc.w      115,101
           dc.w      113,99
           dc.w      110,96
           dc.w      108,94
           dc.w      106,93
           dc.w      104,91
           dc.w      102,90
           dc.w      101,89
           dc.w      99,89
           dc.w      98,89
           dc.w      97,89
           dc.w      96,90
           dc.w      95,91
           dc.w      94,93
           dc.w      94,94
           dc.w      94,96
           dc.w      94,99
           dc.w      94,101
           dc.w      94,103
           dc.w      94,104
           dc.w      95,106
           dc.w      96,107
           dc.w      97,108
           dc.w      98,108
           dc.w      99,108
           dc.w      101,108
           dc.w      102,107
           dc.w      104,106
           dc.w      106,104
           dc.w      108,103
           dc.w      110,101
           dc.w      113,99
           dc.w      115,96
           dc.w      118,94
           dc.w      120,93
           dc.w      123,91
           dc.w      126,90
           dc.w      129,89
           dc.w      132,89
           dc.w      135,89
           dc.w      138,89
           dc.w      142,90
           dc.w      145,91
           dc.w      148,93
           dc.w      152,94
           dc.w      155,96

;
; +-------------------------------+
; | Tables des tailles de spheres |
; +-------------------------------+
;

sph_lst    dc.l 	sphere0,sphere1,sphere2,sphere3,sphere4,sphere5
           dc.l 	sphere6,sphere7,sphere8,sphere9,sphere10,sphere11
           dc.l 	sphere12,sphere13,sphere14,sphere15,sphere16,sphere17
           dc.l 	sphere18,sphere19,sphere20,sphere19,sphere18,sphere17
           dc.l 	sphere16,sphere15,sphere14,sphere13,sphere12,sphere11
           dc.l 	sphere10,sphere9,sphere8,sphere7,sphere6,sphere5
           dc.l 	sphere4,sphere3,sphere2,sphere1

effac_1    ds.l 	180
effac_2    ds.l 	180
screen1    ds.l 	1
screen2    ds.l 	1
efface1    dc.l 	effac_1
efface2    dc.l 	effac_2
spheres    ds.l	1
sph_ptr    ds.l 	1
dep_ptr    ds.l 	1

dummy      ds.w 	1
centr_x    ds.w 	1
centr_y	ds.w 	1
angle_y    ds.w 	1

; +-------------------+
; | Table des rasters |
; +-------------------+

rasters	dc.w $500,$610,$700,$710,$720,$730,$740,$750,$760,$770

           dc.w $001,$000,$001,$000,$001,$001,$001,$001,$002,$001
           dc.w $002,$001,$002,$002,$002,$002,$003,$002,$003,$002
           dc.w $003,$003,$003,$003,$004,$003,$004,$003,$004,$004
           dc.w $004,$004,$005,$004,$005,$004,$005,$005,$005,$005
           dc.w $006,$005,$006,$005,$006,$006,$006,$006,$007,$006
           dc.w $007,$006,$007,$007,$007,$007,$017,$007,$017,$007
           dc.w $017,$017,$017,$017,$027,$017,$027,$017,$027,$027

; +--------------------------+
; | Table des positions en X |
; +--------------------------+

pos_x:

i          set 0
           rept 20
           dc.w i,32768,i,16384,i,8192,i,4096,i,2048,i,1024,i,512,i,256,i,128,i,64,i,32,i,16,i,8,i,4,i,2,i,1
i          set i+8
           endr

; +--------------------------+
; | Table des positions en Y |
; +--------------------------+

pos_y:

i          set 0
           rept 200
           dc.w i
i          set i+160
           endr

;
; +-----------------------------+
; | Donnees pour les 21 spheres |
; +-----------------------------+
;

	include	"SPHERES.S"

;
; +----------------------------------------+
; | Music et table des Cosinus/sinus * 256 |
; +----------------------------------------+
;

cosin	incbin "COSIN.DAT"
music	incbin "LIFBITCH.SND"
	even

;
; ***************************************************************
; *                                                             *
; * ADRESSE DE CHARGEMENT DES FICHIERS                          *
; *                                                             *
; ***************************************************************
;

lance:
