save_all	moveq #$13,d0
	jsr write_ikbd
	move.w #$2700,sr
	savepal old_pal
	loadpal null
	getrez2 old_rez
	getphys2 old_phys
	move.l $70.w,old_vbl
	move.l $118.w,old_118
	tst.b _falcon_030
	beq.s save_alls1
	getmode old_mode
	savefpal old_fpal
save_alls1	move.w #$2300,sr
	rts

init_all	setscreen #0,#-1,#-1
	move.l #vbl,$70.w
	move.l #v118,$118.w
	move.l #ecran,d0
	clr.b d0
	move.l d0,screen1
	add.l #32000,d0
	move.l d0,screen2
	jsr wait_vbl
	setscreen2 #0,screen1
	moveq #$11,d0
	jsr write_ikbd
	moveq #$14,d0
	jsr write_ikbd
	jsr flush_kbd
	moveq #1,d0
	jmp musik

restore_all	loadpal null
	moveq #0,d0
	jsr musik
	moveq #$13,d0
	jsr write_ikbd
	jsr wait_vbl
	move.w #$2700,sr
	setscreen2 old_rez,old_phys
	move.l old_vbl,$70.w
	move.l old_118,$118.w
	loadpal old_pal
	tst.b _falcon_030
	beq.s restore_alls1
	setmode2 old_mode,old_phys,old_phys
	loadfpal old_fpal
restore_alls1	moveq #$13,d0
	jsr write_ikbd
	moveq #8,d0
	jsr write_ikbd
	jmp flush_kbd

write_ikbd	btst #1,$fffffc00.w
	beq.s write_ikbd
	move.b d0,$fffffc02.w
	rts

flush_kbd	btst #0,$fffffc00.w
	beq.s flush_kbds1
	move.b $fffffc02.w,d1
	bra.s flush_kbd
flush_kbds1	rts

