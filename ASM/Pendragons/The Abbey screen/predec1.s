	lea megadeth,a1
	
	move.l ecran,a0
	lea 160*8(a0),a0
	move.l a0,a2
	
	move.w #((6240/4)/2)-1,d0
	move.w d0,d1
		
copy1	move.l (a1)+,(a0)+
	move.w (a1)+,(a0)+
	addq.w #2,a0
	dbf d0,copy1

	move.l a2,a0
	lea menu,a1
	
	moveq #15,d2
		
loop_pred move.l a2,a0
	
	move.w d1,d0
		
predec1	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbf d0,predec1
	
	move.l a2,a0
	bsr.s roxr
	
	dbf d2,loop_pred
	
	lea vague,a0
	lea t_vague,a1

precalc	cmp.l #f_vague,a0
	bge.s fincalc

	move.l (a0),d0
	move.l d0,d2

	lsr.l #4,d2
	lsl.l #3,d2

	move.l d2,(a0)+
	lsl.l #2,d0

	move.l (a1,d0.w),d1
	move.l d1,(a0)+

	bra.s precalc

fincalc	moveq #38,d0

	lea vague,a0
	lea f_vague,a1

loopcalc	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbf d0,loopcalc
	
	rts
	
roxr	moveq #38,d0
decal
n	set 0
	rept 18
	roxr n(a0)
n	set n+8
	endr
	
n	set 2
	rept 18
	roxr n(a0)
n	set n+8
	endr
	
n	set 4
	rept 18
	roxr n(a0)
n	set n+8
	endr
	
	lea 160(a0),a0
	
	dbf d0,decal
	rts
	
	