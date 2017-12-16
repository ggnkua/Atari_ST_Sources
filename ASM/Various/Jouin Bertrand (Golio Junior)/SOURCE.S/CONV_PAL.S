* routine d'extraction d'une palette d'un fichier GIF
* et conversion en "palette" true color
* Par Golio Junior pour Falk'mag 5

	section TEXT
				* pr‚paratif … la conversion
	lea	image_gif+13,a0	* a0 pointe sur la palette source
	lea	palette,a1		* a1 pointe sur la palette destination
	move.w	#256-1,d0		* nombre de couleur

				* d‚but de la conversion
conversion_b1
	move.b	(a0)+,d1		* composante rouge
	swap	d1
	lsr.l	#8,d1		* qui se retrouve dans les
				* 8 bits de poids forts
	andi.w	#%1111100000000000,d1	* ‚limination des bits inutiles
	
	move.b	(a0)+,d2		* composante verte
	lsl.w	#3,d2
	andi.w	#%0000011111100000,d2
	or.w	d2,d1
	
	move.b	(a0)+,d2		* composante bleu
	lsr.w	#3,d2
	andi.w	#%0000000000011111,d2
	or.w	d2,d1
	
	move.w	d1,(a1)+		* sauvegarde du r‚sultat
	
	dbra	d0,conversion_b1

	move.w #00,-(sp)		* fichier en Lecture/Ecriture
	pea fichier_nom
	move.w #$3C,-(sp)		* fonction F_create
	trap #1			* appel Gemdos
	addq.l #8,sp
	tst.l d0
	bmi erreur
				* on r‚cupŠre le handle du fichier cr‚‚
	move.w d0,fichier_handle

				* ecriture
	pea palette		* adresse du bloc a sauvegarder
	move.l #2*512,-(sp)		* 2*512 octets … ‚crire
	move.w fichier_handle,-(sp)
	move.w #$40,-(sp)		* fonction F_write
	trap #1			* appel Gemdos
	lea 12(sp),sp
	tst.l d0
	bmi erreur
	
				* fermeture
	move.w fichier_handle,-(sp)
	move.w #$3E,-(sp)		* fonction F_close
	trap #1			* appel Gemdos
	addq.l #4,sp
erreur				* fin du programme
	move.w #0,-(sp)		* fonction P_term0
	trap #1			* appel du Gemdos

		
	section DATA
image_gif	incbin	"palette.gif"
fichier_nom
	dc.b "fract_tc.pal"
	dc.b 00

	section BSS
	even
fichier_handle
	ds.w	1
palette	ds.w	256