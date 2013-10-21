; ********************************************************************
; * Source assembleur 680X0 de gestion des joysticks normaux sur     *
; * le port etendu (STE/FALCON)  (Tabulation 12)                     *
; * Ce programme n'est qu'un exemple et une maniere de faire...      *
; * La sous-routine   de gestion doit etre optimisable selon les cas.*
; * Elle renvoit les memes valeurs que les joysticks normaux.        *
; * Son utilisation est simple appuyez sur 0 1 2 ou 3                *
; * pour tester les joysticks 0 1 2 ou 3 et espace pour quitter....  *
; *------------------------------------------------------------------*
; * Fabrice Vend‚/E-mail: fvende@srvetud.univ-lr.fr                  *
; ********************************************************************

; passage en super U m‚thode boeuf
   move.l   #0,-(sp)
   move.w   #32,-(sp)
   trap	#1
   addq.l   #6,sp

   moveq.l  #0,d0


   moveq.l  #0,d5
boucle_test:
   move.l   d5,d0    	; numero du joy dans d0 (0 1 2 et 3)

   bsr	joystick    ; d0 (numero joy) en parametre et en retour d3 (position) et d1 (bouton feu)

affichage_texte:
   lea	numero,a0
   add.b	d5,(a0)
   move.b   d3,d0    	; position dans d0
            	; Attention on obtient ":" pour le position 10
   lea	position,a0
   add.b	d0,(a0)
   lea	fire,a0
   add.b	d1,(a0)


; affichage  texte
   move.l   #texte,-(sp)
   move.w   #9,-(sp)
   trap  	#1
   addq.l   #6,sp

; reaffichage normal
   lea  	numero,a0
   move.b   #48,(a0)
   lea   	position,a0
   move.b   #48,(a0)
   lea   	fire,a0
   move.b   #48,(a0)

            ; =>return d3
; test l'appuie sur une touche
test_clavier:
   move.b   $fffc02,d0
   cmp.b 	#109,d0     ; appuie sur 1 ?
   bne.s 	test_2
   moveq.l  #1,d5
   bra.s 	test_stop
test_2:
   cmp.b 	#110,d0     ; appuie sur 2 ?
   bne.s 	test_3
   moveq.l  #2,d5
   bra.s 	test_stop
test_3:
   cmp.b 	#111,d0     ; appuie sur 3 ?
   bne.s 	test_0
   moveq.l  #3,d5
   bra.s 	test_stop
test_0:
   cmp.b 	#112,d0     ; appuie sur 0 ?
   bne.s 	test_stop
   moveq.l  #0,d5

test_stop:
   cmp.b 	#57,d0
   bne.s 	boucle_test

; fin on quitte
   move.w   #0,-(sp)
   trap  	#1







; ********************
; * S.P. GESTION JOY *
; ********************

joystick:
; les registres de donnees d0 … d4 et d'adresse a0 sont utilise ici

   moveq.l	#0,d3    ; 0 dans d3
   move.b   d0,d1    ; sauve num‚ro du joy de d0
   lsl.b 	#2,d0    ; multiplie par 4 le numero du joy
   move.b   d0,d4

   move.w   $ff9202,d2	; on recupere le mot pour tester position


droite_2:
   btst.l   d4,d2	; on test le bit 0 du joy d0
   bne.s 	gauche_2	; et s'il est <> 0 test suivant
   addq.l   #8,d3

gauche_2:
   move.b   d4,d0
   addq.l   #1,d0	; on test le bit 1 du joy d0
   btst.l   d0,d2
   bne.s 	bas_2	; et s'il est <> 0 test suivant
   addq.l   #4,d3
bas_2:
   move.b   d4,d0
   addq.l   #2,d0	; on test le bit 2 du joy d0
   btst.l   d0,d2
   bne.s 	haut_2	; et s'il est <> 0 test suivant
   addq.l   #2,d3
haut_2:
   move.b   d4,d0
   addq.l   #3,d0	; on test le bit 3 du joy d0
   btst.l   d0,d2
   bne.s 	test_tir    ; et s'il est <> 0 test suivant
   addq.l   #1,d3

test_tir:
;
   move.b   d1,d0	; recupere numero joy
   move.b   $ff9201,d2	; octet de l'appuie sur le bouton
   moveq 	#0,d1
   cmp.b 	#0,d0
   beq.s 	test_joy_0_3	; cas des joy 0 ou 3
   cmp.b 	#3,d0
   beq.s 	test_joy_0_3
; cas des joy 1 ou 2
test_joy_1_2:
   addq.l   #1,d0
   eor.b 	#1,d0    ; pour le joy 1 on test le bit 2
   subq.b   #1,d0
   btst.l   d0,d2    ; et pour le joy 2 on test le bit 1
   bne.s 	fin_test
   moveq.b  #1,d1
   bra.s 	fin_test
test_joy_0_3:
   btst.l   d0,d2    ; on test le bit 0 ou 3
   bne.s 	fin_test
   moveq.b  #1,d1    ; tir dans d1


fin_test:
   rts







   SECTION DATA
texte 	dc.b  27,"Y",32,32,"Joystick :"
numero   	dc.b  48,13,10
   	dc.b  "Position :"
position 	dc.b  48,13,10
   	dc.b  " Fire :"
fire  	dc.b  48,"   (0=> pas d'appuie, 1=> appuie)",10,13
   	dc.b  "<Espace pour quitter>",10,13,0
