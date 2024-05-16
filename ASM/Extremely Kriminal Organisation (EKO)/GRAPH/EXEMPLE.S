;voila un (tres) court programme d'exemple
	
	
	
	lea	x,a0
	lea	sommet,a1
;on charge dans les registres
	move.w	(a1)+,d0	; x1
	move.w	(a1)+,d1	; y1
	move.w	(a1)+,d2	; x2
	move.w	(a1)+,d3	; y2
;calcul de la pente(m)
	sub.w	d1,d3	;delta y
	sub.w	d0,d2	;delta x
	
	lsl.l	#7,d2
	divs	d3,d2
	ext.l	d2
	lsl.l	#8,d2
	lsl.l	#1,d2
;un lsl.l #9,d2 est impossible...
	move.l	#$8000,d7

calcul:	swap	d7
	move.w	d7,(a0)+
	swap	d7
	add.l	d2,d7
	dbra	d3,calcul		
; quelques precisions:
; dans d2 on a:
; 16 bits de poids fort 16 bits de poids faible
; partie entiere*65536  | partie flottante*65536
; d0 contient $8000,soit 0.5*65536...
; cela permet de partir avec un registre
; egale a 0.5,comme on se sert que de la valeur entiere
; on a int(X+0.5)=round(x) (round=arrondit)

; Puisque cette partie n'est,il faut bien l'avouer,
; pas tres difficile (mais en cas de probleme regarder
; le comportement de la routine instruction par instruction)
; voila quelques optimisations envisagable:
; -on peut se passer des swaps grace a un format pour d2 et d7
;    different.Indice:carry,addx.
; -on peut aussi se passer du dbra,en sautant dans un rept..endr
; Voila,les deux sont cumulables!

; et n'oubliez pas que je ne donne que les algorithmes...
; dans cette serie tout serat optimisable...c'est a mon avis
; la meilleure facon de comprendre une routine !
; a bientot...Createur/EkO. 
fin:
	clr.w	-(a7)
	trap	#1


	data
sommet	dc.w	0,0,$f,10


	bss
x	ds.w	200