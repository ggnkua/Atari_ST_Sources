	move.l #$f0451,d0
	bsr aff_d0

     	clr.w -(sp)
     	trap #1

* affichage hexad‚cimal de d0
aff_d0	* un mot long en hexa
	* est represent‚ par 8
	* caractŠres, donc en
	* affichant caractere par
	* caractere, on fait 8
	* fois la meme chose
	moveq.l #8-1,d1
aff_d0_bouc
	* recup‚ration du quartet de poid
	* fort dans le quartet de poid
	* faible
	rol.l #4,d0
	* copie et extention de bit
	move.b d0,d2
	andi.w #$000f,d2
	* comparaison avec 10
	* pour savoir si le caractere est 
	* un chiffre ou une lettre
	cmpi.b #10,d2
	bmi aff_d0_chiffre
	add.b #'A'-10,d2
	bra aff_d0_suite
aff_d0_chiffre
	add.b #'0',d2
aff_d0_suite
	* sauvegarde sur la pile
	* de d0
	move.l d0,-(sp)
	* affichage de d2
	move.w d2,-(sp)
	move.w #2,-(sp)
	trap #1
	addq.l #4,sp
	move.l (sp)+,d0
	dbra d1,aff_d0_bouc
	rts