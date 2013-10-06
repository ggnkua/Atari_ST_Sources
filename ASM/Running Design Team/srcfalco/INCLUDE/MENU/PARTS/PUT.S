********* Put Infos **********

edge_move_texture:
* a6 = offset table

* movement ?

		tst.b	keytable+$48
		beq.s	no_up_kugelxx

		clr.b	keytable+$48

		tst.w	kugel_pos
		beq	no_down_kugelxx
	
		move.l	#$ffffffff,d0
		move.l	screen_2,a0
		bsr	paint_edge
		move.l	#$ffffffff,d0
		move.l	screen_1,a0
		bsr	paint_edge
		
		subq.w	#1,kugel_pos

		lea	name_control_array,a0
		move.w	kugel_pos,d0
		mulu	#10,d0
		adda.w	d0,a0

		move.w	#1,(a0)
		clr.b	2(a0)
		rts

no_up_kugelxx	tst.b	keytable+$50
		beq.s	no_down_kugelxx

		clr.b	keytable+$50

		cmp.w	#3,kugel_pos
		beq.s	no_down_kugelxx

		move.l	#$ffffffff,d0
		move.l	screen_2,a0
		bsr	paint_edge
		move.l	#$ffffffff,d0
		move.l	screen_1,a0
		bsr	paint_edge
		
		addq.w	#1,kugel_pos

		lea	name_control_array,a0
		move.w	kugel_pos,d0
		mulu	#10,d0
		adda.w	d0,a0

		move.w	#1,(a0)
		clr.b	2(a0)

no_down_kugelxx
		rts


edge_move:
* a6 = offset table

* movement ?

		tst.b	keytable+$48
		beq.s	no_up_kugelx

		clr.b	keytable+$48

		tst.w	kugel_pos
		beq.s	no_down_kugelx
	
		move.l	#$ffffffff,d0
		move.l	screen_2,a0
		bsr	paint_edge
		move.l	#$ffffffff,d0
		move.l	screen_1,a0
		bsr	paint_edge
		
		subq.w	#1,kugel_pos
		rts

no_up_kugelx	tst.b	keytable+$50
		beq.s	no_down_kugelx

		clr.b	keytable+$50

		cmp.w	#3,kugel_pos
		beq.s	no_down_kugelx

		move.l	#$ffffffff,d0
		move.l	screen_2,a0
		bsr	paint_edge
		move.l	#$ffffffff,d0
		move.l	screen_1,a0
		bsr	paint_edge
		
		addq.w	#1,kugel_pos

no_down_kugelx	rts

paint_edge
* a6 = offset table
* a0 = screen
* d0 = color

	lea	5*640+20*2(a0),a0
	adda.l	(a6),a0

	move.w	kugel_pos,d1
	adda.l	4(a6,d1.w*4),a0
	mulu	#640*47,d1
	adda.l	d1,a0

	rept	21
	move.l	d0,640*41(a0)
	move.l	d0,(a0)+
	endr

	lea	640-84(a0),a0
	
	rept	40
	move.w	d0,(a0)
	move.w	d0,41*2(a0)
	lea	640(a0),a0	
	endr

	rts



put_infos
* a0 = infos

	lea	fade_buffer_2+128,a1	
	adda.l	#12*640+200*2,a1

	lea	txt+128,a2	

	moveq	#3,d0
dops
	move.l	a1,a3
	move.l	a2,a4

	move.w	(a0),d1
	move.b	3(a0,d1.w),d1
	mulu	#20*128,d1
	adda.l	d1,a4

	moveq	#19,d1
sops
	rept	25
	move.l	(a4)+,(a3)+
	endr
	
	lea	28(a4),a4

	lea	640-100(a3),a3
	dbra	d1,sops

	lea	6(a0),a0

	lea	48*640(a1),a1
	
	dbra	d0,dops
	rts	

put_infos2
* a0 = infos

	move.l	screen_2,a1	
	adda.l	#12*640+200*2,a1
	move.l	screen_1,a5	
	adda.l	#12*640+200*2,a5

	lea	txt+128,a2	

	moveq	#3,d0
dops2
	move.l	a5,a6
	move.l	a1,a3
	move.l	a2,a4

	move.w	(a0),d1
	move.b	3(a0,d1.w),d1
	mulu	#20*128,d1
	adda.l	d1,a4

	moveq	#19,d1
sops2
	rept	25
	move.l	(a4)+,d2
	move.l	d2,(a3)+
	move.l	d2,(a6)+
	endr
	
	lea	28(a4),a4

	lea	640-100(a3),a3
	lea	640-100(a6),a6
	dbra	d1,sops2

	lea	6(a0),a0

	lea	48*640(a1),a1
	lea	48*640(a5),a5
	
	dbra	d0,dops2
	rts	
