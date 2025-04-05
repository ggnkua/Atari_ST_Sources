*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*							*
*		     Petite gestion de cookies			*
*							*
*	Ces routines sont du bidouillage, je vous conseille d'en	*
*	utiliser d'autres pour vos propres applications!		*
*							*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
* Version     : 15/12/1995, v0.742				*
* Tab setting : 11						*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderight L. de Soras 1994-95*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Installation d'un cookie sur la jar			*
*	Si celui-ci est d‚j… pr‚sent, on le signale.		*
*	Si la jar est trop petite, on en cr‚e une autre, avec l'adresse	*
*	fournie comme 3Šme paramŠtre. Attention, cette zone doit d‚j…	*
*	ˆtre r‚serv‚e! Si elle est utilis‚e, elle devra ˆtre r‚sidente	*
*	… la sortie du programme, sinon elle devra ˆtre lib‚r‚e (enfin	*
*	si vous voulez...). Pr‚voir assez large!			*
*	Les paramŠtres sont des *modes d'adressages* (pensez aux #	*
*	devant les nombres).					*
*	Renvoie (mot long):					*
*	    0 s'il n'y a eu aucun problŠme,			*
*	    -1 si le cookie ‚tait d‚j… l…,			*
*	    Un nombre positif indiquant la taille maxi de la nouvelle	*
*		jar, en OCTETS, si on a ‚t‚ oblig‚ d'en cr‚er une.	*
*	Marche en -*- SUPERVISEUR -*-				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

newcookie:	Macro			; 3 paramŠtres : Id, valeur, nouvelle adresse
	movem.l	d1-a6,-(sp)
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	bsr	rout_newcookie
	lea	12(sp),sp
	movem.l	(sp)+,d1-a6
	EndM



*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Lecture d'un cookie					*
*	Les paramŠtres sont des *modes d'adressages* (pensez aux #	*
*	devant les nombres).					*
*	Renvoie l'adresse de ce cookie s'il est trouv‚, sinon 0.	*
*	Marche en -*- SUPERVISEUR -*-				*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

readcookie:	Macro		; 1 paramŠtre : Id
	movem.l	d1-a6,-(sp)
	move.l	\1,d0
	bsr	rout_readcookie
	movem.l	(sp)+,d1-a6
	EndM





*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*	Routines des cookies. Ne pas oublier de d‚plier cette macro	*
*	… la fin de votre programme si vous utilisez les fonctions 	*
*	cookie pr‚c‚dentes!					*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

cookie_routines:	Macro

;--- Routine d'ajout d'un cookie ---------------------------------------------
rout_newcookie:
	move.l	$5a0.w,a0		; a0 = adresse de la Cookie Jar
	move.l	4(sp),d1		; d1 = Id du nouveau cookie
	move.l	8(sp),d4		; d4 = valeur du nouveau cookie
	move.l	12(sp),a1		; a1 = adresse d'une ‚ventuelle nouvelle jar
	moveq	#0,d0		; d0 = compteur de cookies
.readloop:
	move.l	(a0,d0.w*8),d2	; d2 = id du cookie qu'on scanne
	move.l	4(a0,d0.w*8),d3	; d3 = sa valeur
	cmp.l	d2,d1		; On est d‚j… dans la jar ?
	beq.s	.present		; Oui, on s'en va
	addq.l	#1,d0
	tst.l	d2		; C'est le dernier ?
	bne.s	.readloop		; Non, on continue … chercher

	cmp.l	d0,d3		; Il y a assez de place ?
	ble.s	.pasdeplace	; Non, il faut cr‚er une autre Jar

	move.l	-8(a0,d0.w*8),(a0,d0.w*8)	; On translate le dernier cookie
	move.l	-4(a0,d0.w*8),4(a0,d0.w*8)
	move.l	d1,-8(a0,d0.w*8)	; Et on met le notre …
	move.l	d4,-4(a0,d0.w*8)	; l'avant-derniŠre position

	moveq	#0,d0		; Pas d'erreur
	rts

.present:
	moveq	#-1,d0		; d‚j… pr‚sent, retourne -1
	rts

.pasdeplace:			; Pas de place, il faut copier toute la
				; jar dans un endroit plus grand, d‚j…
				; r‚serv‚, dont on a fourni l'adresse.
				; Ne pas oublier de *ne pas* r‚alouer cet
				; endroit en cas d'utilisation. (pas propre!)
	move.l	d0,d5
	subq.l	#1,d5		; *** Ca bugge si la jar ne contient que le
.copyloop:				; cookie de fin, mais c'est normalement impossible.
	move.l	(a0)+,(a1)+	; Copie l'ancienne jar sauf le cookie de fin
	move.l	(a0)+,(a1)+
	dbra	d5,.copyloop
	move.l	d1,(a1)+		; Copie le nouveau cookie … la suite
	move.l	d4,(a1)+
	clr.l	(a1)+		; Et fabrique le cookie de fin
	add.l	#8,d0		; place pour 8 autres cookies
	lsl.l	#3,d0		; conversion en octets
	move.l	d0,(a1)+		; Stoque, et retourne la taille de cette nouvelle jar
	rts



;--- Routine de recherche d'un cookie ----------------------------------------
rout_readcookie:
	move.l	$5a0.w,a0
.loop:	move.l	(a0),d1
	beq.s	.notfound
	cmp.l	d1,d0
	beq.s	.found
	addq.l	#8,a0
	bra.s	.loop

.found:
	move.l	a0,d0
	rts

.notfound:
	moveq	#0,d0
	rts



	EndM		; Fin des routines de cookie
