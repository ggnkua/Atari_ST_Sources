
		section	text

		
fullrot_ofsmap:
		lea.l	fullrot_chunky,a0
		lea.l	fullrot_ofstxt+256*256/2,a1
		add.l	fullrot_t,a1

		move.w	fullrot_chunky_xofs,d0
		move.w	fullrot_chunky_yofs,d1

		add.w	d0,a0
		add.w	d1,a0

		move.l	fullrot_ofsadr,a3
		lea.l	.ofspos,a2
		add.w	d0,d0
		add.w	(a2,d0.w),a3
		
		lsr.w	#1,d1
		add.w	d1,a3



q:		set	0
w:		set	0

		rept	17

		movem.l	w(a3),d0-d7

		move.b	(a1,d0.w),q+4(a0)
		swap	d0
		move.b	(a1,d0.w),q(a0)

		move.b	(a1,d1.w),q+12(a0)
		swap	d1
		move.b	(a1,d1.w),q+8(a0)

		move.b	(a1,d2.w),q+20(a0)
		swap	d2
		move.b	(a1,d2.w),q+16(a0)

		move.b	(a1,d3.w),q+28(a0)
		swap	d3
		move.b	(a1,d3.w),q+24(a0)

		move.b	(a1,d4.w),q+36(a0)
		swap	d4
		move.b	(a1,d4.w),q+32(a0)

		move.b	(a1,d5.w),q+44(a0)
		swap	d5
		move.b	(a1,d5.w),q+40(a0)

		move.b	(a1,d6.w),q+52(a0)
		swap	d6
		move.b	(a1,d6.w),q+48(a0)

		move.b	(a1,d7.w),q+60(a0)
		swap	d7
		move.b	(a1,d7.w),q+56(a0)

		movem.l	w+32(a3),d0-d4

		move.b	(a1,d0.w),q+68(a0)
		swap	d0
		move.b	(a1,d0.w),q+64(a0)

		move.b	(a1,d1.w),q+76(a0)
		swap	d1
		move.b	(a1,d1.w),q+72(a0)

		move.b	(a1,d2.w),q+84(a0)
		swap	d2
		move.b	(a1,d2.w),q+80(a0)

		move.b	(a1,d3.w),q+92(a0)
		swap	d3
		move.b	(a1,d3.w),q+88(a0)

		move.b	(a1,d4.w),q+100(a0)
		swap	d4
		move.b	(a1,d4.w),q+96(a0)
		
q:		set	q+104*4
w:		set	w+26*4*2
		endr
		
		rts
.ofspos:	dc.w	52*68*0,52*68*1,52*68*2,52*68*3

		section	data

fullrot_ofsadr:		dc.l	fullrot_ofslut_spiral

fullrot_ofslut_spiral:	incbin	'fullrot/spiral.ofs'
			even

fullrot_ofslut_wave:	incbin	'fullrot/wave.ofs'
			even

fullrot_ofslut_polar:	incbin	'fullrot/polar.ofs'
			even

fullrot_ofslut_tunnel:	incbin	'fullrot/tunnel.ofs'
			even

fullrot_ofstxt_lz77:	incbin	'fullrot/ofstxt.z77'
			even

		
		section	text
