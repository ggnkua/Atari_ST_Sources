init_var	move.w #-1,level
	move.l #back_p1,ad_bpers1
	move.l #back_p2,ad_bpers2
	move.l #back_b1,ad_bbomb1
	move.l #back_b2,ad_bbomb2
	move.l #back_e1,ad_bboum1
	move.l #back_e2,ad_bboum2
	lea players,a0
	lea type_joy,a1
	lea c_type,a2
	moveq #0,d1
	moveq #3,d0
init_vars1	move.w #nb_vies,vie(a0)
	clr.w score(a0)
	clr.b dead(a0)
	move.b (a2)+,d1
	cmp.b #5,d1
	bne.s init_vars2
	move.b #-1,dead(a0)
	clr.w vie(a0)
init_vars2	add.w d1,d1
	add.w d1,d1
	move.l (a1,d1.w),ad_rout(a0)
	lea lg_play(a0),a0
	dbra d0,init_vars1
	rts

init_var2	clr.l tmp_boum
	clr.l tmp_boum+(14*4)
	lea players,a0
	lea back_b1,a2
	lea back_b2,a3
	moveq #3,d0
init_var2s1	move.w #-1,crd_bx(a0)
	lea lg_play(a0),a0
	move.l #-1,(a2)+
	move.l #-1,(a3)+
	dbra d0,init_var2s1
	clr.w back_e1
	clr.w back_e2
	sf.b flag_exit
	rts

type_joy	dc.l pt_joy0
	dc.l pt_joy1
	dc.l pt_joy2
	dc.l pt_joy3
	dc.l pt_joy4
	dc.l pt_null

init_map	lea levels+10,a0
	move.w level,d0
	move.w d0,d1
	mulu #488,d0		taille d'une map
	add.l d0,a0
	move.l a0,ad_map
	lea attrib,a0
	mulu #240,d1		taille attributs
	add.l d1,a0
	move.l a0,ad_atb
	rts

clr_bss	lea debut_bss,a0
clr_bss_s1	clr.l (a0)+
	cmp.l #end_bss,a0
	blt.s clr_bss_s1
	rts

