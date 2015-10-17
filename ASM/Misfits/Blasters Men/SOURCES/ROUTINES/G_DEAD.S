gere_dead	lea players,a6
	moveq #3,d7
	moveq #0,d0
	moveq #0,d1
gere_deads1	tst.b dead(a6)	spr rip ?
	ble.s gere_deads2	non -> suivant
	subq.b #1,dead(a6)	tempo rip
	bne.s gere_deads2	pas finie -> perso suivant.
	tst.w vie(a6)		plus de vie ?
	bne.s gere_deads2
	subq.b #1,dead(a6)	alors player off
gere_deads2	or.w vie(a6),d0
	tst.b dead(a6)
	bpl.s gere_deads3
	addq.w #1,d1
gere_deads3	lea lg_play(a6),a6
	dbra d7,gere_deads1
	tst.w d0		les players sont off ?
	bne.s gere_deads4	non -> continu jeu
	cmp.w #4,d1		anims tombes finies ?
	bne.s gere_deads4
	st.b flag_exit	alors fin du jeu.
gere_deads4	rts

