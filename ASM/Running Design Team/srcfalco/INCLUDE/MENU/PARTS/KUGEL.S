********* Kugel Animatiion *********

kugel_move:

* movement ?

		tst.b	keytable+$48
		beq.s	no_up_kugel

		tst.w	kugel_pos
		beq.s	no_down_kugel

		bsr	restore_kugel
		subq.w	#1,kugel_pos

no_up_kugel	tst.b	keytable+$50
		beq.s	no_down_kugel

		cmp.w	#3,kugel_pos
		beq.s	no_down_kugel

		bsr	restore_kugel
		addq.w	#1,kugel_pos

no_down_kugel	rts

restore_kugel
		move.l	screen_1,a0
		move.l	screen_2,a1
		adda.l	#kuglx*2+kugly*640,a0
		adda.l	#kuglx*2+kugly*640,a1
		
		move.w	kugel_pos,d0
		move.l	kugel_offsets(pc,d0.w*4),d0
		adda.l	d0,a0
		adda.l	d0,a1		

		lea	kugel_back,a2
		
		moveq	#16-1,d0
res_kugel
		rept	10
		move.l	(a2)+,d1
		move.l	d1,(a0)+
		move.l	d1,(a1)+
		endr

		lea	640-20*2(a0),a0
		lea	640-20*2(a1),a1

		dbra	d0,res_kugel
		rts

* Movement offsets

kugel_offsets
		dc.l	0
		dc.l	640*26
		dc.l	640*26*2-640
		dc.l	640*26*3-640

kugel:
* a0 = screen address 

* Animation
		
		adda.l	#kuglx*2+kugly*640,a0

		move.w	kugel_pos,d0
		adda.l	kugel_offsets(pc,d0.w*4),a0
		
		lea	kugl_anim+128,a1
		
		move.w	kugel_phase,d0
		
		neg.w	kugel_index
		tst.w	kugel_index
		bpl.s	phase_ok
		addq.w	#1,d0
		cmp.w	#16,d0
		blt.s	phase_ok
		moveq	#0,d0
phase_ok	move.w	d0,kugel_phase

		lsl.w	#3,d0	* mulu 20*2
		move.w	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0

		adda.w	d0,a1

* Drawing

		moveq	#16-1,d0
copy_kugel
		moveq	#20-1,d1
copy_pixel
		tst.w	(a1)+
		beq.s	xyz_no
		move.w	-2(a1),(a0)
xyz_no		addq.w	#2,a0
		dbra	d1,copy_pixel
	
		lea	640-20*2(a1),a1
		lea	640-20*2(a0),a0

		dbra	d0,copy_kugel
		rts

save_kugel
		adda.l	#kuglx*2+kugly*640,a0		
		lea	kugel_back,a1
		
		moveq	#16-1,d0
sav_kugel
		rept	10
		move.l	(a0)+,(a1)+
		endr

		lea	640-20*2(a0),a0

		dbra	d0,sav_kugel
		rts


