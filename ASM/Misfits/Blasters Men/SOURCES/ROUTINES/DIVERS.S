wait_vbl	clr.b pt_vbl
wait_vbls1	tst.b pt_vbl
	beq.s wait_vbls1
	rts

swap_screen	movem.l screen1,d0-d7
	exg.l d0,d1		swap screen
	exg.l d2,d3		swap back perso
	exg.l d4,d5		swap back bomb
	exg.l d6,d7		swap back explosion
swap_scrns1	movem.l d0-d7,screen1
	jsr wait_vbl
	move.l d1,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w
	move.b d1,$ffff820d.w
	rts

vbl2	jsr musik+4
vbl	st.b pt_vbl
	rte

copy_scrn2	move.l screen1,a1
	move.l screen2,a0
	bra.s copy_s2
copy_scrn	move.l screen1,a0
	move.l screen2,a1
copy_s2	move.w #32000/4-1,d0
copy_s1	move.l (a0)+,(a1)+
	dbra d0,copy_s1
	rts

load_map	lea nom_map,a5
	lea levels,a6
	move.l #48802,d6
	jsr load
	tst.w d0
	bmi.s no_map
	lea nom_atb,a5
	lea attrib,a6
	move.l #24000,d6
	jsr load
	tst.w d0
	bmi.s no_atb
	moveq #0,d0
	tst.w d0
	rts

no_map	lea tno_map,a0
	bra.s error
no_atb	lea tno_atb,a0
error	print (a0)
	getkey
	moveq #-1,d0
	tst.w d0
	rts

