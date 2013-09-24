
		section	text

spr3d_init_str1:
		subq.w	#1,.once
		bne.s	.no

		move.w	#2,spr3d_anipos
		clr.w	spr3d_aniposclr

		move.w	#280,spr3d_xpos
		clr.w	spr3d_ypos
		clr.l	spr3d_xpos_clr
		clr.l	spr3d_ypos_clr

		lea.l	spr3d_str1_obj,a0
		moveq.l	#16,d0
		moveq.l	#16,d1
		moveq.l	#32,d2
		bsr.w	spr3d_makeanim

		move.w	#4,spr3d_numplanes
		move.w	#1,spr3d_dostars

		ifne	init_finish
		move.w	#$0077,$ffff8240.w
		endc

.no:		rts
.once:		dc.w	1

spr3d_vbl_str1:	
		bsr.w	spr3d_vbl

		movem.l	spr3d_4pl_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	spr3d_xpos,spr3d_xpos_clr
		subq.w	#1,spr3d_xpos		

		move.w	#1,spr3d_do_main

		rts


		section	data


; Object format
;
; dc.w numvert
; rept numvert
; dc.w x,y,z,s
; endr
; s=size, 0 (16x16 3.6% cpu), 1 (32x32 8.4% cpu), 2 (48x48 16.7% cpu), 3 (64x64 25% cpu)

spr3d_str1_obj:
q:		set	8

		dc.w	14


		dc.w	100*q,100*q,100*q,1
		dc.w	-100*q,100*q,100*q,1
		dc.w	-100*q,-100*q,100*q,1
		dc.w	100*q,-100*q,100*q,1

		dc.w	100*q,100*q,-100*q,1
		dc.w	-100*q,100*q,-100*q,1
		dc.w	-100*q,-100*q,-100*q,1
		dc.w	100*q,-100*q,-100*q,1

		dc.w	50*q,50*q,0*q,0
		dc.w	-50*q,50*q,0*q,0
		dc.w	-50*q,-50*q,0*q,0
		dc.w	50*q,-50*q,0*q,0

		dc.w	0*q,0*q,50*q,0
		dc.w	0*q,0*q,-50*q,0


		section	text
		