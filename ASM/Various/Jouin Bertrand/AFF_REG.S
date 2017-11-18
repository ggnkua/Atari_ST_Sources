* Affichage de contenu du registre D0 en hexad‚cimal
* et en binaire
* Par Golio Junior

	section Text
	move.l #$12345678,d0
			* affichage du contenu du registre
	bsr affd0_hex
	bsr affd0_bin
	
			* attente d'une touche
	move.w #7,-(sp)	* fonction C_rawcin
	trap #1		* appel du Gemdos
	addq.l #2,sp
	
			* fin du programme
	move.w #0,-(sp)	* fonction P_term0
	trap #1		* appel du Gemdos
	
			* inutile de corriger la pile
			* le programme n'est plus ex‚cut‚
affd0_hex
	movem.l d0-d2/a0-a2,-(sp)
	lea aff_hex_f-2,a0	* a0 pointe sur l'octet 13

	move.w #8-1,d1
affd0_hex_b1
	move.b d0,d2
	andi.b #$0F,d2
	cmpi.b #$A,d2
	bpl affd0_hex_sup
	add.b #'0',d2
	bra affd0_hex_suite
affd0_hex_sup
	add.b #'A'-$A,d2
affd0_hex_suite
	move.b d2,-(a0)
	lsr.l #4,d0
	dbra d1,affd0_hex_b1

	pea aff_hex
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel du Gemdos	
	addq.l #6,sp
	
	movem.l (sp)+,d0-d2/a0-a2
	rts
	
affd0_bin
	movem.l d0-d2/a0-a2,-(sp)
	
	lea aff_bin+6,a0
	move.w #32-1,d1
affd0_bin_b1
	lsl.l #1,d0
	bcs affd0_bin_1
	move.b #'0',(a0)+
	bra affd0_bin_fin
affd0_bin_1
	move.b #'1',(a0)+
affd0_bin_fin
	dbra d1,affd0_bin_b1
	
	pea aff_bin
	move.w #9,-(sp)	* fonction C_conws
	trap #1		* appel du Gemdos	
	addq.l #6,sp

	movem.l (sp)+,d0-d2/a0-a2
	rts
	
	section Data
aff_hex	dc.b "D0 : $00000000",13,10
aff_hex_f	dc.b 00

aff_bin	dc.b "D0 : %00000000000000000000000000000000",13,10
	dc.b 00