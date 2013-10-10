	move.l ecran1,a1
	lea 186*160(a1),a1
	move.l ecran,a2
	lea 186*160(a2),a2
	lea mencarbuf,a3
	
n	set 0
	rept 20
	move.w n+6(a2),n+6(a1)
	move.w n+14(a2),n+14(a1)
	move.w n+22(a2),n+22(a1)
	move.w n+30(a2),n+30(a1)
	move.w n+38(a2),n+38(a1)
	move.w n+46(a2),n+46(a1)
	move.w n+54(a2),n+54(a1)
	move.w n+62(a2),n+62(a1)
	move.w n+70(a2),n+70(a1)
	move.w n+78(a2),n+78(a1)
	move.w n+86(a2),n+86(a1)
	move.w n+94(a2),n+94(a1)
	move.w n+102(a2),n+102(a1)
	move.w n+110(a2),n+110(a1)
	move.w n+118(a2),n+118(a1)
	move.w n+126(a2),n+126(a1)
	move.w n+134(a2),n+134(a1)
	move.w n+142(a2),n+142(a1)
	move.w n+150(a2),n+150(a1)
	move.w n+158(a2),n+158(a1)
	
	move.w (a3),d1
	roxl.w #1,d1
	move.w d1,(a3)+
	
	roxl.w n+158(a1)
	roxl.w n+150(a1)
	roxl.w n+142(a1)
	roxl.w n+134(a1)
	roxl.w n+126(a1)
	roxl.w n+118(a1)
	roxl.w n+110(a1)
	roxl.w n+102(a1)
	roxl.w n+94(a1)
	roxl.w n+86(a1)
	roxl.w n+78(a1)
	roxl.w n+70(a1)
	roxl.w n+62(a1)
	roxl.w n+54(a1)
	roxl.w n+46(a1)
	roxl.w n+38(a1)
	roxl.w n+30(a1)
	roxl.w n+22(a1)
	roxl.w n+14(a1)
	roxl.w n+6(a1)
	
n	set n+160
	endr	
	
	subq.b #1,fin_car_m
	beq.s mennewcar
	
	rts
	
mennewcar	moveq #0,d0
	move.b #16,fin_car_m
	
	move.l menpostxt,a0
	move.b (a0)+,d0
	move.l a0,menpostxt
	
	cmp.b #-1,d0
	beq.s mennewpos
	
	lea tabmencar,a0
	
	lsl.w #2,d0
	
	move.l (a0,d0.w),a0
	lea mencarbuf,a1
	
n	set 0
	rept 20
	move.w n(a0),(a1)+
n	set n+40
	endr
	rts
	
mennewpos	move.l #menu_txt1,menpostxt
	bra mennewcar