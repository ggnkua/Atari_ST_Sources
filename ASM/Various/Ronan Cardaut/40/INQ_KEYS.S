*----------------------------------------------------------------------------*
* partie pour le test:
		opt	x+

		pea	kbd
		move	#$26,-(sp)
		trap	#14
		addq.l	#6,sp
		
		clr	-(sp)
		trap	#1

		* appel la routine aprŠs 5s
		* et attends juste aprŠs
kbd
		move.l	$4ba.w,d0
		add.l	#5*200,d0
pause
		cmp.l	$4ba.w,d0
		bgt	pause

		lea	buf(pc),a0
		bsr	inquire_keys
		move	d0,nb_car
		
		illegal
		rts

nb_car		dc.w	0
buf		dcb.b	16

*----------------------------------------------------------------------------*
		
		*-------------*
		* Retourne l'‚tat du clavier:
		* si pas de clavier=> buffer vide
		* si clavier mais pas de touche=> num‚ro de version du clavier
		* la suite suit cette rŠgle:
		* car 1: premier code scan de la liste+bit 7 … 1
		* car 2: version du clavier ($f0(stf),$f1 (mstf), $fx...)
		* car 3: premier code scan utile … prendre en compte
		* car 4 … 8: les codes suivant (0 indique la find de la liste)
		* au total on peut avoir Control,Shift gauche,alternate,
		* shift droit, capslock et une touche quelconque.
		* l'ordre correspond … l'ordre d'appui.
		*
		* NOTE: il faut que le compteur du timerc tourne, car c'est
		* la base de temps pour le reset.
		*
		* Cette routine peut prendre jusqu'… un peu plus de 500ms pour
		* s'ex‚cuter.
		*
		* Le sr est restaur‚ … la fin mais en interne, on passe en I7!
		
		*-------------*
		* A0: pointeur sur un buffer d'au moins 9 octets
		* => A0: le buffer est mis … jour (0.b marque la fin)
		cnop	0,16
inquire_keys
		movem.l	d1-2/a0-1,-(sp)
		
		move	sr,-(sp)
		move	#$2700,sr
		
	* reset le clavier
		lea	.init_ikbd(pc),a1
		move	(a1)+,d0
.wait_env
		btst.b	#1,$fffffc00.w
		beq.s	.wait_env
		
		move.b	(a1)+,$fffffc02.w
		dbra	d0,.wait_env

	* r‚cup‚ration des codes scan+ time out de  500ms		
		moveq	#0,d0		;nb cars re‡us
		move.l	#500*192/20,d1	;500 ms (192 ticks pour le
					;compteur du timerc
					;qui donne 20ms)
.time_out
		btst	#0,$fffffc00.w
		beq.s	.dec_time
		
		move.b	$ffffffc02.w,d2
		move.b	d2,(a0)+
		addq	#1,d0
.dec_time
		move.b	$fffffa23.w,d2

.wait		cmp.b	$fffffa23.w,d2
		beq	.wait
		
		subq.l	#1,d1
		bne	.time_out
	* fini
.end_wait
		move	(sp)+,sr
		movem.l	(sp)+,d1-2/a0-1
		rts

		* init le clavier
.init_ikbd	dc.w	2-1	;nb de car-1
		dc.b	$80,$01	;Reset

*----------------------------------------------------------------------------*
