	move.l ecran,a6
	lea 181*160(a6),a6
	
	move.l s_car_b1,a4
	move.l s_car_b2,a5
	move.l a4,s_car_b2
	move.l a5,s_car_b1
	
n	set 0
n1	set 0

	rept 10
	
	movem.l n+8(a6),d0-d7/a0-a4
	movem.l d0-d7/a0-a4,n(a6)
	movem.l n+60(a6),d0-d7/a0-a4
	movem.l d0-d7/a0-a4,n+52(a6)
	movem.l n+112(a6),d0-d7/a0-a3
	movem.l d0-d7/a0-a3,n+104(a6)
	
	move.l n1(a5),n+152(a6)
	move.l n1+4(a5),n+156(a6)
	move.l n1+8(a5),n1(a5)
	move.l n1+12(a5),n1+4(a5)

n	set n+160
n1	set n1+16
	endr

	rept 128*9
	nop 
	endr
	
	rept 19
	
	movem.l n+8(a6),d0-d7/a0-a4
	movem.l d0-d7/a0-a4,n(a6)
	movem.l n+60(a6),d0-d7/a0-a4
	movem.l d0-d7/a0-a4,n+52(a6)
	movem.l n+112(a6),d0-d7/a0-a3
	movem.l d0-d7/a0-a3,n+104(a6)
	
	move.l n1(a5),n+152(a6)
	move.l n1+4(a5),n+156(a6)
	move.l n1+8(a5),n1(a5)
	move.l n1+12(a5),n1+4(a5)

n	set n+160
n1	set n1+16
	endr
	
	subq.b #1,fin_car1
	beq.s new_car1
	
loop_h	subq.b #1,fin_car
	beq new_car
	
	rts
	
new_car1	moveq #0,d0
	move.b #4,fin_car1
	
	move.l pos_txt1,a0
	move.b -1(a0),d1
	move.b (a0)+,d0
	move.l a0,pos_txt1
	
	cmp.b #-1,d0
	beq deb_car1

	move.l s_car_b1,a1
	
	lea tab_car,a0
	lsl.w #2,d0
	lsl.w #2,d1
	move.l (a0,d1.w),a2
	move.l (a0,d0.w),a0
	
n	set 0
n1	set 0
	rept 29
	
	move.b n1+6(a0),n+9(a1)
	move.b n1+1(a0),n+8(a1)
	move.b n1(a0),n+1(a1)
	move.b n1+7(a2),n(a1)
	
	move.b n1+8(a0),n+11(a1)
	move.b n1+3(a0),n+10(a1)
	move.b n1+2(a0),n+3(a1)
	move.b n1+9(a2),n+2(a1)

	move.b n1+10(a0),n+13(a1)
	move.b n1+5(a0),n+12(a1)
	move.b n1+4(a0),n+5(a1)
	move.b n1+11(a2),n+4(a1)

n	set n+16
n1	set n1+120
	endr

	bra loop_h
	
new_car	moveq #0,d0
	move.b #4,fin_car
	
	move.l pos_txt,a0
	move.b (a0)+,d0
	move.l a0,pos_txt
	
	cmp.b #-1,d0
	beq deb_car

	move.l s_car_b1,a1

	lea tab_car,a0
	lsl.w #2,d0
	move.l (a0,d0.w),a0

n	set 0

	rept 29

	move.l n(a0),(a1)+
	move.w n+4(a0),(a1)+
	addq.l #2,a1
	move.l n+6(a0),(a1)+
	move.w n+10(a0),(a1)+
	addq.l #2,a1 		
n	set n+120
	endr
	
	rts
	
deb_car	move.l #text1,pos_txt
	bra new_car
	
deb_car1	move.l #text1,pos_txt1
	bra new_car1
