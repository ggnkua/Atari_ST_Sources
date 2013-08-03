***********************************************************************
***********										***********
***********										***********
***********	    Initialisations Video Falcon030		***********
***********										***********
***********										***********
***********		  Par Simplet / FATAL DESIGN			***********
***********										***********
***********************************************************************

		Section	TEXT

Save_Video
		lea.l	Old_Video,a0			; Espace de sauvegarde

		move.b	$ffff8201.w,(a0)+		; Vid‚o (poids fort)
		move.b	$ffff8203.w,(a0)+		; Vid‚o (poids moyen)
		move.b	$ffff820d.w,(a0)+		; Vid‚o (poids faible)
		move.b	$ffff820a.w,(a0)+		; Synchronisation vid‚o
		move.w	$ffff820e.w,(a0)+		; Offset pour prochaine ligne
		move.w	$ffff8210.w,(a0)+		; Largeur d'une ligne en mots
		move.b	$ffff8260.w,(a0)+		; R‚solution ST
		move.b	$ffff8265.w,(a0)+		; D‚calage Pixel
		move.w	$ffff8266.w,(a0)+		; R‚solution Falcon
		move.w	$ffff8282.w,(a0)+		; HHT-Synchro
		move.w	$ffff8284.w,(a0)+		; Fin Bordure Droite
		move.w	$ffff8286.w,(a0)+		; D‚but Bordure Gauche
		move.w	$ffff8288.w,(a0)+		; D‚but Ligne
		move.w	$ffff828a.w,(a0)+		; Fin Ligne
		move.w	$ffff828c.w,(a0)+		; HSS-Synchro
		move.w	$ffff828e.w,(a0)+		; HFS ???
		move.w	$ffff8290.w,(a0)+		; HEE ???
		move.w	$ffff82a2.w,(a0)+		; VFT-Synchro
		move.w	$ffff82a4.w,(a0)+		; Fin Bordure Basse
		move.w	$ffff82a6.w,(a0)+		; D‚but Bordure Haute
		move.w	$ffff82a8.w,(a0)+		; D‚but Image
		move.w	$ffff82aa.w,(a0)+		; Fin Image
		move.w	$ffff82ac.w,(a0)+		; VSS-Synchro
		move.w	$ffff82c0.w,(a0)+		; Reconnaissance ST/Falcon
		move.w	$ffff82c2.w,(a0)+		; Informations r‚solution

		lea.l	$ffff8240.w,a1			; Palette ST
		moveq.l	#16/2-1,d0			; 8 longs...
Save_ST_Palette
		move.l	(a1)+,(a0)+			; Sauve 2 couleurs
		dbra		d0,Save_ST_Palette		; Boucle les 16 mots !

		lea.l	$ffff9800.w,a1			; Palette Falcon
		move.w	#256-1,d0				; 256 longs...
Save_Falcon_Palette
		move.l	(a1)+,(a0)+			; Sauve 1 couleur
		dbra		d0,Save_Falcon_Palette	; Boucle les 256 longs !
		rts

* Attend en a0 le tableau des infos Video
* en a1, tableau des adresses ecran
* en a2, buffer pour les ecrans
* et en d0, le nombre d'‚crans … r‚server -1

Init_Video
		move.l	(a0)+,d2				; Taille d'un ‚cran
		tst.w	d0
		bmi.s	No_Reserv_Screen
		move.l	a1,a3

Init_Screen_Adr
		move.l	a2,d7				; Adresse ‚cran
		addi.l	#256,d7				; + 256
		clr.b	d7					; Multiple de 256
		move.l	d7,(a1)+				; Adresse sauv‚e !
		adda.l	d2,a2				; Prochain ‚cran
		dbra		d0,Init_Screen_Adr		; Boucle tous les ‚crans

		move.l	(a3),d0				; Nouvelle
		lsr.w	#8,d0				; Adresse
		move.l	d0,$ffff8200.w			; Ecran

No_Reserv_Screen
		move.b	#2,$ffff820a.w			; Horloge Interne
		clr.b	$ffff8265.w			; D‚calage Pixel Nul

		move.w	(a0)+,$ffff820e.w		; Offset pour prochaine ligne nul
		move.w	(a0)+,$ffff8210.w		; Largeur d'une ligne en mots

		move.w	(a0)+,d0				; R‚solution ST
		move.w	(a0)+,d1				; R‚solution Falcon

		move.w	d1,$ffff8266.w			; Fixe R‚solution Falcon

		tst.w	(a0)+				; R‚solution Falcon ?
		beq.s	No_ST_Rez				; Si oui, saut !

		move.b	d0,$ffff8260.w			; Fixe R‚solution ST
		move.w	-8(a0),$ffff8210.w		; Largeur d'une ligne en mots

No_ST_Rez	btst.b	#7,$ffff8006.w			; Ecran VGA ?
		beq.s	No_VGA				; Si non, saut...

		adda.w	#16*2,a0

No_VGA	move.w	(a0)+,$ffff8282.w		; HHT-Synchro
		move.w	(a0)+,$ffff8284.w		; Fin Bordure Droite
		move.w	(a0)+,$ffff8286.w		; D‚but Bordure Gauche
		move.w	(a0)+,$ffff8288.w		; D‚but Ligne
		move.w	(a0)+,$ffff828a.w		; Fin Ligne
		move.w	(a0)+,$ffff828c.w		; HSS-Synchro
		move.w	(a0)+,$ffff828e.w		; HFS ???
		move.w	(a0)+,$ffff8290.w		; HEE ???
		move.w	(a0)+,$ffff82a2.w		; VFT-Synchro
		move.w	(a0)+,$ffff82a4.w		; Fin Bordure Basse
		move.w	(a0)+,$ffff82a6.w		; D‚but Bordure Haute
		move.w	(a0)+,$ffff82a8.w		; D‚but Image
		move.w	(a0)+,$ffff82aa.w		; Fin Image
		move.w	(a0)+,$ffff82ac.w		; VSS-Synchro
		move.w	(a0)+,$ffff82c0.w		; Reconnaissance ST/Falcon
		move.w	(a0),$ffff82c2.w		; Informations r‚solution
		rts


Init_Falcon_Palette
		moveq.l	#0,d0				; d0 nul
		lea.l	$ffff9800.w,a0			; Palette Falcon
		move.w	#256-1,d1				; 256 longs
Init_FalconPalette
		move.l	d0,(a0)+				; 1 couleur noire
		dbra		d1,Init_FalconPalette	; Boucle les 256 longs !
		rts	


Init_ST_Palette
		moveq.l	#0,d0				; d0 nul
		lea.l	$ffff8240.w,a0			; Palette ST
		moveq.l	#16/2-1,d1			; 8 longs
Init_STPalette
		move.l	d0,(a0)+				; 2 couleurs noires
		dbra		d1,Init_STPalette		; Boucle les 16 mots !
		rts


Restore_Video
		lea.l	Old_Video,a0			; Espace de sauvegarde

		move.b	(a0)+,$ffff8201.w		; Vid‚o (poids fort)
		move.b	(a0)+,$ffff8203.w		; Vid‚o (poids moyen)
		move.b	(a0)+,$ffff820d.w		; Vid‚o (poids faible)
		move.b	(a0)+,$ffff820a.w		; Synchronisation vid‚o
		move.w	(a0)+,$ffff820e.w		; Offset pour prochaine ligne
		move.w	(a0)+,$ffff8210.w		; Largeur d'une ligne en mots
		move.b	(a0)+,d0				; R‚solution ST
		move.b	(a0)+,$ffff8265.w		; D‚calage Pixel
		move.w	(a0)+,d1				; R‚solution Falcon

		move.w	d1,$ffff8266.w			; Fixe R‚solution Falcon

		btst.b	#0,28(a0)				; R‚solution Falcon ?
		bne.s	No_STRez				; Si oui, saut !

		move.b	d0,$ffff8260.w			; Fixe R‚solution ST
		move.w	-6(a0),$ffff8210.w		; Largeur d'une ligne en mots

No_STRez	move.w	(a0)+,$ffff8282.w		; HHT-Synchro
		move.w	(a0)+,$ffff8284.w		; Fin Bordure Droite
		move.w	(a0)+,$ffff8286.w		; D‚but Bordure Gauche
		move.w	(a0)+,$ffff8288.w		; D‚but Ligne
		move.w	(a0)+,$ffff828a.w		; Fin Ligne
		move.w	(a0)+,$ffff828c.w		; HSS-Synchro
		move.w	(a0)+,$ffff828e.w		; HFS ???
		move.w	(a0)+,$ffff8290.w		; HEE ???
		move.w	(a0)+,$ffff82a2.w		; VFT-Synchro
		move.w	(a0)+,$ffff82a4.w		; Fin Bordure Basse
		move.w	(a0)+,$ffff82a6.w		; D‚but Bordure Haute
		move.w	(a0)+,$ffff82a8.w		; D‚but Image
		move.w	(a0)+,$ffff82aa.w		; Fin Image
		move.w	(a0)+,$ffff82ac.w		; VSS-Synchro
		move.w	(a0)+,$ffff82c0.w		; Reconnaissance ST/Falcon
		move.w	(a0)+,$ffff82c2.w		; Informations r‚solution


		lea.l	$ffff8240.w,a1			; Palette ST
		moveq.l	#16/2-1,d0			; 8 longs...
Restore_ST_Palette
		move.l	(a0)+,(a1)+			; Restaure 2 couleurs
		dbra		d0,Restore_ST_Palette	; Boucle les 16 mots !

		lea.l	$ffff9800.w,a1			; Palette Falcon
		move.w	#256-1,d0				; 256 longs...
Restore_Falcon_Palette
		move.l	(a0)+,(a1)+			; Restaure 1 couleur
		dbra		d0,Restore_Falcon_Palette	; Boucle les 256 longs !

Wait_No_Key
		move.b	$fffffc02.w,d0			; Code clavier
		btst.b	#0,$fffffc00.w			; Buffer vide ?
		bne.s	Wait_No_Key			; Sinon,on continue...

		move.w	#$2300,sr
		rts

***********************************************************************
***********				Section DATA				***********
***********************************************************************

		Section	DATA

Videl_320_100_True
		dc.l		320*100*16/8+256				* G‚n‚ral
		dc.w		0,320,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,46,143,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0001					* Double Ligne

Videl_320_200_4
		dc.l		320*200*2/8+256				* G‚n‚ral
		dc.w		0,40,1,$0
		dc.w		-1							* Flag Ordre

		dc.w		62,48,8,569,18,52,0,0			* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		23,18,1,522,9,17,0,0			* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_200_16
		dc.l		320*200*4/8+256				* G‚n‚ral
		dc.w		0,80,0,$0
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,12,109,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		198,141,21,650,107,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_200_256
		dc.l		320*200+256					* G‚n‚ral
		dc.w		0,160,0,$10
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,28,125,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		198,141,21,666,123,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_200_True
		dc.l		320*200*16/8+256				* G‚n‚ral
		dc.w		0,320,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,46,143,216,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0000

		dc.w		198,150,15,682,139,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_4
		dc.l		320*400*2/8+256				* G‚n‚ral
		dc.w		0,40,1,$0
		dc.w		-1							* Flag Ordre

		dc.w		62,48,8,569,18,52,0,0			* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		23,18,1,522,9,17,0,0			* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_16
		dc.l		320*400*4/8+256				* G‚n‚ral
		dc.w		0,80,0,$0
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,12,109,216,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		198,141,21,650,107,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_256
		dc.l		320*400+256					* G‚n‚ral
		dc.w		0,160,0,$10
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,28,125,216,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		198,141,21,666,123,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_320_400_True
		dc.l		320*200*16/8+256				* G‚n‚ral
		dc.w		0,320,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,46,143,216,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0010

		dc.w		198,150,15,682,139,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%0101

Videl_640_200_2
		dc.l		640*200/8+256					* G‚n‚ral
		dc.w		0,40,0,$400
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,1007,160,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		198,141,21,627,80,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_200_4
		dc.l		640*200*2/8+256				* G‚n‚ral
		dc.w		0,80,1,$0
		dc.w		-1							* Flag Ordre

		dc.w		62,48,8,2,32,52,0,0				* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		23,18,1,526,13,17,0,0			* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_200_16
		dc.l		640*200*4/8+256				* G‚n‚ral
		dc.w		0,160,0,$0
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,77,254,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		198,141,21,675,124,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_200_256
		dc.l		640*200+256					* G‚n‚ral
		dc.w		0,320,0,$10
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,93,270,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

		dc.w		198,141,21,683,132,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_200_True
		dc.l		640*200*16/8+256				* G‚n‚ral
		dc.w		0,640,0,$100
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,113,290,434,0,0		* RVB
		dc.w		625,613,47,127,527,619
		dc.w		$181,%0100

Videl_640_400_2
		dc.l		640*400/8+256					* G‚n‚ral
		dc.w		0,40,0,$400
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,1007,160,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		198,141,21,627,80,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_4
		dc.l		640*400*2/8+256				* G‚n‚ral
		dc.w		0,80,1,$0
		dc.w		-1							* Flag Ordre

		dc.w		62,48,8,2,32,52,0,0				* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		23,18,1,526,13,17,0,0			* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_16
		dc.l		640*400*4/8+256				* G‚n‚ral
		dc.w		0,160,0,$0
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,77,254,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		198,141,21,675,124,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_256
		dc.l		640*400+256					* G‚n‚ral
		dc.w		0,320,0,$10
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,93,270,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

		dc.w		198,141,21,683,132,150,0,0		* VGA 47 Hz
 		dc.w		1337,1300,100,315,1115,1333
		dc.w		$186,%1001

Videl_640_400_True
		dc.l		640*400*16/8+256				* G‚n‚ral
		dc.w		0,640,0,$100
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,113,290,434,0,0		* RVB
		dc.w		624,613,47,126,526,619
		dc.w		$181,%0110

; Modes Overscan seulement en RVB

Videl_384_128_True
		dc.l		384*128*16/8+256				* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0001					* Double Ligne

Videl_384_256_4
		dc.l		384*256*2/8+256				* G‚n‚ral
		dc.w		0,48,1,$0
		dc.w		-1							* Flag Ordre

		dc.w		62,48,8,562,27,52,0,0			* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

Videl_384_256_16
		dc.l		384*256*4/8+256				* G‚n‚ral
		dc.w		0,96,0,$0
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,748,141,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

Videl_384_256_256
		dc.l		384*256+256					* G‚n‚ral
		dc.w		0,192,0,$10
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,764,157,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

Videl_768_256_2
		dc.l		768*256/8+256					* G‚n‚ral
		dc.w		0,48,0,$400
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,943,224,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

Videl_768_256_4
		dc.l		768*256*2/8+256				* G‚n‚ral
		dc.w		0,96,1,$0
		dc.w		-1							* Flag Ordre

		dc.w		62,48,8,567,32,52,0,0			* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

Videl_768_256_16
		dc.l		768*256*4/8+256				* G‚n‚ral
		dc.w		0,192,0,$0
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,13,318,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

Videl_768_256_256
		dc.l		768*256+256					* G‚n‚ral
		dc.w		0,384,0,$10
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,29,334,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

Videl_768_240_True
		dc.l		768*240*16/8+256				* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		625,613,47,87,567,619
		dc.w		$181,%0100

Videl_768_256_True
		dc.l		768*256*16/8+256				* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0100

Videl_768_480_True
		dc.l		768*480*16/8+256				* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		624,613,47,86,566,619
		dc.w		$181,%0110

Videl_768_512_True
		dc.l		768*512*16/8+256				* G‚n‚ral
		dc.w		0,768,0,$100
		dc.w		0							* Flag Ordre

		dc.w		510,409,80,49,354,434,0,0		* RVB
		dc.w		624,613,47,70,582,619
		dc.w		$181,%0110

; Modes Overscan accessibles aussi en VGA

Videl_384_240_True
		dc.l		384*240*16/8+256				* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,87,567,619
		dc.w		$181,%0000

		dc.w		240,160,0,714,151,200,0,0		* VGA 52.11 Hz
 		dc.w		1207,1300,0,163,1123,1203
		dc.w		$186,%0101

Videl_384_256_True
		dc.l		384*256*16/8+256				* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,71,583,619
		dc.w		$181,%0000

		dc.w		240,160,0,714,151,200,0,0		* VGA 52.11 Hz
 		dc.w		1207,1300,0,131,1155,1203
		dc.w		$186,%0101

Videl_384_480_True
		dc.l		384*480*16/8+256				* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,86,566,619
		dc.w		$181,%0010

		dc.w		240,160,0,714,151,200,0,0		* VGA 50.2 Hz
 		dc.w		1257,1300,0,163,1123,1253
		dc.w		$186,%0100

Videl_384_512_True
		dc.l		384*512*16/8+256				* G‚n‚ral
		dc.w		0,384,0,$100
		dc.w		0							* Flag Ordre

		dc.w		254,203,39,14,175,216,0,0		* RVB
		dc.w		625,613,47,70,582,619
		dc.w		$181,%0010

		dc.w		240,160,0,714,151,200,0,0		* VGA 50.2 Hz
 		dc.w		1257,1300,0,131,1155,1253
		dc.w		$186,%0100

***********************************************************************
***********				Section BSS				***********
***********************************************************************

			Section	BSS

Old_Video		ds.b		3			; Adresse M‚moire Vid‚o
			ds.b		1			; Synchronisation vid‚o
			ds.w		1			; Offset pour prochaine ligne
			ds.w		1			; Largeur d'une ligne en mots
			ds.b		1			; R‚solution ST
			ds.b		1			; D‚calage Pixel
			ds.w		1			; R‚solution Falcon
			ds.w		1			; HHT-Synchro
			ds.w		1			; Fin Bordure Droite
			ds.w		1			; D‚but Bordure Gauche
			ds.w		1			; D‚but Ligne
			ds.w		1			; Fin Ligne
			ds.w		1			; HSS-Synchro
			ds.w		1			; HFS ???
			ds.w		1			; HEE ???
			ds.w		1			; VFT-Synchro
			ds.w		1			; Fin Bordure Basse
			ds.w		1			; D‚but Bordure Haute
			ds.w		1			; D‚but Image
			ds.w		1			; Fin Image
			ds.w		1			; VSS-Synchro
			ds.w		1			; Reconnaissance ST/Falcon
			ds.w		1			; Informations r‚solution

			ds.w		16			; Palette ST
			ds.l		256			; Palette Falcon
