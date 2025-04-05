
		section	text

spr3d_init_cubs:
		subq.w	#1,.once
		bne.s	.no

		move.w	#2,spr3d_anipos
		clr.w	spr3d_aniposclr

		clr.w	spr3d_xpos
		move.w	#-130,spr3d_ypos
		clr.l	spr3d_xpos_clr
		clr.l	spr3d_ypos_clr

		lea.l	spr3d_cubs_obj,a0
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

spr3d_vbl_cubs:	
		bsr.w	spr3d_vbl

		movem.l	spr3d_4pl_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	spr3d_ypos,spr3d_ypos_clr

		subq.w	#1,.wait
		bne.s	.no
		move.w	#2,.wait
		
		addq.w	#1,spr3d_ypos

.no:		move.w	#1,spr3d_do_main
		rts
.wait:		dc.w	2


		section	data

		
; Object format
;
; dc.w numvert
; rept numvert
; dc.w x,y,z,s
; endr
; s=size, 0 (16x16 3.6% cpu), 1 (32x32 8.4% cpu), 2 (48x48 16.7% cpu), 3 (64x64 25% cpu)

spr3d_cubs_obj:
q:		set	2

		dc.w	24

		dc.w	-100*q,-100*q,100*q,0
		dc.w	-100*q,100*q,100*q,0
		dc.w	100*q,100*q,100*q,0
		dc.w	100*q,-100*q,100*q,0
		dc.w	-100*q,-100*q,-100*q,0
		dc.w	-100*q,100*q,-100*q,0
		dc.w	100*q,100*q,-100*q,0
		dc.w	100*q,-100*q,-100*q,0


		dc.w	-100*q,-100*q,500*q,0
		dc.w	-100*q,100*q,500*q,0
		dc.w	100*q,100*q,500*q,0
		dc.w	100*q,-100*q,500*q,0
		dc.w	-100*q,-100*q,700*q,0
		dc.w	-100*q,100*q,700*q,0
		dc.w	100*q,100*q,700*q,0
		dc.w	100*q,-100*q,700*q,0

		dc.w	-100*q,-100*q,-500*q,0
		dc.w	-100*q,100*q,-500*q,0
		dc.w	100*q,100*q,-500*q,0
		dc.w	100*q,-100*q,-500*q,0
		dc.w	-100*q,-100*q,-700*q,0
		dc.w	-100*q,100*q,-700*q,0
		dc.w	100*q,100*q,-700*q,0
		dc.w	100*q,-100*q,-700*q,0
		


		ifne	0
		dc.w	-100*q,100*q,100*q,0
		dc.w	100*q,100*q,100*q,0
		dc.w	100*q,-100*q,100*q,0
		dc.w	-100*q,-100*q,100*q,0
		dc.w	-100*q,100*q,-100*q,0
		dc.w	100*q,100*q,-100*q,0
		dc.w	100*q,-100*q,-100*q,0
		dc.w	-100*q,-100*q,-100*q,0

		dc.w	-100*q,100*q,300*q,0
		dc.w	100*q,100*q,300*q,0
		dc.w	100*q,-100*q,300*q,0
		dc.w	-100*q,-100*q,300*q,0
		dc.w	-100*q,100*q,500*q,0
		dc.w	100*q,100*q,500*q,0
		dc.w	100*q,-100*q,500*q,0
		dc.w	-100*q,-100*q,500*q,0

		dc.w	-100*q,100*q,-300*q,0
		dc.w	100*q,100*q,-300*q,0
		dc.w	100*q,-100*q,-300*q,0
		dc.w	-100*q,-100*q,-300*q,0
		dc.w	-100*q,100*q,-500*q,0
		dc.w	100*q,100*q,-500*q,0
		dc.w	100*q,-100*q,-500*q,0
		dc.w	-100*q,-100*q,-500*q,0

		dc.w	-100*q,100*q,700*q,0
		dc.w	100*q,100*q,700*q,0
		dc.w	100*q,-100*q,700*q,0
		dc.w	-100*q,-100*q,700*q,0
		dc.w	-100*q,100*q,900*q,0
		dc.w	100*q,100*q,900*q,0
		dc.w	100*q,-100*q,900*q,0
		dc.w	-100*q,-100*q,900*q,0

		dc.w	-100*q,100*q,-700*q,0
		dc.w	100*q,100*q,-700*q,0
		dc.w	100*q,-100*q,-700*q,0
		dc.w	-100*q,-100*q,-700*q,0
		dc.w	-100*q,100*q,-900*q,0
		dc.w	100*q,100*q,-900*q,0
		dc.w	100*q,-100*q,-900*q,0
		dc.w	-100*q,-100*q,-900*q,0

		endc

		section	text
		