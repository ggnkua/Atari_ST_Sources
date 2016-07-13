*-------------------------------------------------------------------------*
		SECTION DATA
*-------------------------------------------------------------------------*

		*---------------*
		* tags
		*---------------*
p_tags:
		dc.l	APP_CLOSE		; 0
		
		dc.l	APP_CLOSE		; 1
		
		dc.l	0		; 2 frame directory
		dc.l	0		; 3 frame fichiers
		
		dc.l	0	; 4
		dc.l	0	; 5
		
		dc.l	0	;test_resize	; test resizing
		
		dc.l	set_path		; 7= action des objets directory
		dc.l	"$$$$"		; 8= tag de la chaine path courant
		dc.l	set_drive		; 9= reglage du lecteur courant ??
		
		dc.l	fermer_info_1	; 10
		dc.l	rien	; 11
		dc.l	fermer_info_2	; 12
		
		dc.l	"$$$$"		; 13
		dc.l	"$$$$"		; 14
		
		dc.l	info_down		; 15
		dc.l	info_up		; 16
		
		dc.l	fermer_info_4	; 17
		
		dc.l	SelectFile	; 18
		dc.l	0		; 19
		
		dc.l	0	; 20 jointure type a
		dc.l	0	; 21 jointure type b
		dc.l	0	; 22 jointure type c
		dc.l	0	; 23 petite icone dossier
		dc.l	0	; 24
		dc.l	0	; 25
		dc.l	0	; 26
		dc.l	0	; 27
		dc.l	0	; 28
		dc.l	0	; 29
		
		dc.l	pix_avant		; 30
		dc.l	pix_arriere	; 31
		dc.l	0		; 32
		
		dc.l	move_pix		; 33
		dc.l	resize_pix	; 34
		
		dc.l	0		; 35
		dc.l	0		; 36
		
		dc.l	"$$$$"		; 37
		
		dc.l	fsel_slide	; 38
		
		dc.l	"$$$$"
		
		dc.l	0	; 40
		
		dc.l	0	; 41
		dc.l	rien		; 42
		
		dc.l	0		; 43
		
		dc.l	rien		; 44	; player de .WAV
		dc.l	rien		; 45	; executer application externe
		
		dc.l	rien		; 46	; RETOUR
		dc.l	rien		; 47	; AVANCE
		dc.l	rien		; 48	; edito
		dc.l	rien		; 49	; ours
		dc.l	rien		; 50	; sommaire
		dc.l	rien		; 51	; imprimer
		
		dc.l	APP_CLOSE		; 52
		
		dc.l	"%%%%"

*-------------------------------------------------------------------------*
		