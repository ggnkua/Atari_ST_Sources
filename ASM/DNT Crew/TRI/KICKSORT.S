;Info structures: No.w|Valeur.w ca fait un mot long … traiter.
;A0=adresse tableau; D0=taille tableau
;
QuickSort_PSeuil
	movem.l	d0-5/a0-3,-(sp)	;on lance la r‚currence
	move.l	d0,d1		;du quicksort
	moveq	#0,d0		;en pr‚cisant les deux bornes
	subq.l	#1,d1		;du 1er tableau
	add.l	d1,d1
	add.l	d1,d1
	movea.l	a0,a1
	adda.l	d1,a1
	bsr.s	Sort_PSeuil	;
	movem.l	(sp)+,d0-5/a0-3	;
	rts

;; Insertion partielle ;;
;A0=a=d‚but partie … trier; A1=b=fin partie … trier
;C'est un bˆte tri par insertion, mais il ne traite qu'un intervalle
;pr‚cis du tableau.
Insertion_Partielle
	move.l	a0,a2		;i=a
	lea	4(a2),a3		;j+1    (travail de IP_next)
	cmpa.l	a3,a1		;j+1=m ?
	blt.s	IP_end		;non,tableau unitaire !
IP_bcl0	move.l	(a3)+,d4		;tab[(j++)+1]
IP_bcl1	move.l	(a2),d5		;Tab[i]
	cmp.w	d5,d4		;b<=Tab[i] ?
	bgt.s	IP_next		;non,fin de remont‚e
	move.l	d4,(a2)+		;si, continue d'ins‚rer
	move.l	d5,(a2)		;
	subq.l	#8,a2		;i=i-1 :un de plus !
	cmpa.l	a2,a0		;i=<d-1 ?
	ble.s	IP_bcl1		;non, insertion continue
IP_next	lea	-4(a3),a2		;i=(j+1)-1=j
	cmpa.l	a2,a1		;j<m ?
	bgt.s	IP_bcl0		;oui, continuer classement
IP_end	rts

;A0=Left ;A1=Right
;Il n'y a pas de sauvegardes de registres dans le corps de la routine,
;car lors des 2 appels de r‚currence … la fin, seul le premier impose
;de sauver certains registres.Le dernier est tout … fait … la fin,
;donc il n'y a rien derriŠre !.
QSPS_Seuil	equ	7		;Seuil optimum
Sort_PSeuil
	move.l	a1,d2		;regarde si le seuil de rapidit‚
	sub.l	a0,d2		;est atteint.
	cmpi.l	#QSPS_Seuil*4,d2	;Alors ?
	ble.s	Insertion_Partielle	;oui,phase d'insertion normale

	moveq	#-16,d4		;
	and.l	d4,d2		;Un quart de la taille du
	lsr.l	#2,d2		;tableau.
	lea	2(a0),a3		;On se place sur les valeurs.
	move.w	(a3),a0		;Ce sont des valeurs 16 bits
	REPT	3		;sign‚es, mais le total peut
	adda.l	d2,a3		;d‚passer 16 bits -> on se sert
	adda.w	(a3),a0		;d'un registre d'adresse car le
	ENDR			;680x0 effectue alors les add
	move.l	a0,d4		;sur 32 bits !...
	asr.l	#2,d4		;...et ca donne un pivot m‚dian

	movea.l	a0,a2		;Pointeur Tab+i
	movea.l	a1,a3		;Tab+j

SoPS_bcl0	cmp.w	2(a2),d4		;x>Tab[i] ?
	ble.s	SoPS_bcl1		;non,arrˆte d‚placement gauche
.sps0_in	addq.l	#4,a2		;si, d‚place la gauche:i=i+1
	cmp.w	2(a2),d4		;
	ble.s	SoPS_bcl1		;
	addq.l	#4,a2		;quadrupl‚s pour gagner du
	cmp.w	2(a2),d4		;temps.
	ble.s	SoPS_bcl1		;
	addq.l	#4,a2		;
	cmp.w	2(a2),d4		;
	ble.s	SoPS_bcl1		;
	addq.l	#4,a2		;
	cmp.w	2(a2),d4		;
	bgt.s	.sps0_in		;

SoPS_bcl1	cmp.w	2(a3),d4		;x<Tab[j] ?
	bge.s	SoPS_tst2		;non,arrˆte d‚placement droite	
.sps1_in	subq.l	#4,a3		;si, d‚place la droite:j=j-1
	cmp.w	2(a3),d4		;
	bge.s	SoPS_tst2		;
	subq.l	#4,a3		;
	cmp.w	2(a3),d4		;
	bge.s	SoPS_tst2		;
	subq.l	#4,a3		;
	cmp.w	2(a3),d4		;
	bge.s	SoPS_tst2		;
	subq.l	#4,a3		;
	cmp.w	2(a3),d4		;
	blt.s	.sps1_in		;
	
SoPS_tst2	cmpa.l	a3,a2		;au bout du compte, i<=j ?
	bgt.s	SoPS_tst3		;non,‡a marche
	move.l	(a2),d5		:si,il faut faire l'‚change
	move.l	(a3),(a2)+		;Tab[i]<=>Tab[j] et i=i+1
	move.l	d5,(a3)		;
	subq.l	#4,a3		;j=j-1
	bra.s	SoPS_bcl0		;

SoPS_tst3				;A0..A3=l,r,i,j en adresses
	movem.l	a1-a2,-(sp)	;protŠge les deux indices
				;i et r pendant la r‚currence
	move.l	a3,a1		;Sort_PSeuil(l,j)
	cmpa.l	a0,a1		;l<j ?
	ble.s	*+6		;non,cassos
	bsr.w	Sort_PSeuil	;
	movea.l	(sp)+,a1		;reprend les registres en les
	movea.l	(sp)+,a0		;redistribuant tout de suite
	cmpa.l	a0,a1		;i<r ?
	ble.s	*+6		;non,cassos
	bsr.w	Sort_PSeuil	;Sort_PSeuil(i,r)
SoPS_end	rts
