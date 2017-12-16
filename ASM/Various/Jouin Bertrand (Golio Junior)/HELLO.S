* Mon premier programme d'entr‚e/sortie
* Par Golio Junior (1er Age)

	section Text
			* affichage du message
	pea message
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel du Gemdos	
	addq.l #6,sp
	
			* attente d'une touche
	move.w #7,-(sp)	* fonction C_rawcin
	trap #1		* appel du Gemdos
	addq.l #2,sp
	
			* fin du programme
	move.w #0,-(sp)	* fonction P_term0
	trap #1		* appel du Gemdos
	
			* inutile de corriger la pile
			* le programme n'est plus ex‚cut‚
	
	section Data
message	dc.b "hello world !!",13,10
	dc.b 00