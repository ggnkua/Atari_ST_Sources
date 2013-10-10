	move.l t_vag,a0
	
	move.l ecran,a1
	lea 160*8(a1),a1
	lea 0.w,a4
	
n	set 8

	rept 39
	move.l (a0)+,a2
	add.l a1,a2
	move.l (a0)+,a3
	add.l a4,a3
	
	movem.l (a3)+,d0-d7/a5-a6
	movem.l d0-d7/a5-a6,n(a2)
	movem.l (a3)+,d0-d7/a5-a6
	movem.l d0-d7/a5-a6,n+40(a2)
	movem.l (a3)+,d0-d7/a5-a6
	movem.l d0-d7/a5-a6,n+80(a2)
	movem.l (a3)+,d0-d4
	movem.l d0-d4,n+120(a2)

	lea 160(a4),a4
	
n	set n+160
	endr
	
	move.l t_vag,a0
	addq.l #8,a0
	
	cmp.l #f_vague,a0
	ble.s cont_vag
	
	lea vague,a0

cont_vag	move.l a0,t_vag
	
	rts	
	