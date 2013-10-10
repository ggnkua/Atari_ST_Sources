aff_bando	lea players,a6
	lea tbando+2,a5
	moveq #0,d0
	moveq #3,d7
aff_bandos1	move.w vie(a6),d0
	cmp.w #9,d0
	ble.s aff_bandos2
	move.w #9,d0
aff_bandos2	add.b #"0",d0
	move.b d0,(a5)
	addq.w #2,a5
	move.w score(a6),d0
	move.l a5,a0
	jsr dec_asc
	addq.w #8,a5
	lea lg_play(a6),a6
	dbra d7,aff_bandos1
	lea tbando,a0
	moveq #8,d0
	move.w #192,d1
	jmp aff_texte

