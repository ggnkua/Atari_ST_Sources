; *************************************************
; * Routine de remplacement de la commande LPRINT *
; *    ne marchant pas en GFA-Basic sur Falcon    *
; *************************************************
;
; By Dumbo - XXäme siäcle

; Appel :
; VOIC C:routine%(L:adresse_chaine%,L:longueur_chaine)
; 32 octets

	TEXT

	move.l	4(sp),a6		; Adresse de la chaine a imprimer
	move.l	8(sp),d7		; Longueur
	tst.l	d7
	beq.s	fin
	clr.l	-(sp)		; Imprimante
	move.w	#3,-(sp)		; Bconstat

loop:	move.b	(a6)+,5(sp)	; Va chercher le caractere
	trap	#13		; Bios
	subq.l	#1,d7
	bne.s	loop
	addq.l	#6,sp
fin:	rts