gere_boum	lea tmp_boum,a6
	moveq #3,d7
	moveq #0,d0
gere_boums3	move.l a6,a0
	bsr.s gere_boums0
	lea 14*4(a6),a6
	dbra d7,gere_boums3
	cmp.w #4,d0		les 4 bombes sont finies ?
	bne.s gere_boums2	non -> fin
	tst.w nb_blk		tout les blk eclates ?
	bne.s gere_boums2	non -> fin
	lea players,a6
	moveq #3,d0
gere_boums4	tst.b dead(a6)	les persos sont ils
	bgt.s gere_boums2	entrain de crever ?
	lea lg_play(a6),a6
	dbra d0,gere_boums4
	move.b #1,flag_exit	non alors tableau suivant.
gere_boums2	rts	
gere_boums0	tst.w (a0)		tempo explos.
	beq.s gere_boums1	=0 alors stop explos.
	subq.w #1,(a0)	sinon decremente tempo.
	rts
gere_boums1	clr.w 2(a0)		plus d'explosions.
	addq.w #1,d0		compteur explo off
	rts
