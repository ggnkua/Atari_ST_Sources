
		section	text


spr3d_init_megaobj:
		subq.w	#1,.once
		bne.s	.no

		move.w	#2,spr3d_anipos
		clr.w	spr3d_aniposclr

		move.w	#280,spr3d_xpos
		clr.w	spr3d_ypos
		clr.l	spr3d_xpos_clr
		clr.l	spr3d_ypos_clr

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		lea.l	spr3d_mega_obj,a0
		moveq.l	#16,d0
		moveq.l	#16,d1
		moveq.l	#32,d2
		bsr.w	spr3d_makeanim

		move.w	#2,spr3d_numplanes
		clr.w	spr3d_dostars
		
		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.no:		rts
.once:		dc.w	1


spr3d_vbl_megaobj_fadeout1:
		bsr.s	spr3d_vbl_megaobj
		
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		
		movem.l	spr3d_pal_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	spr3d_pal_black,a0
		lea.l	spr3d_pal_2pl2,a1
		jsr	component_fade
.no:		rts
.wait:		dc.w	3

spr3d_vbl_megaobj_fadeout2:
		bsr.s	spr3d_vbl_megaobj
		
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		
		movem.l	spr3d_pal_black,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea.l	spr3d_pal_black,a0
		lea.l	spr3d_pal_black2,a1
		jsr	component_fade
.no:		rts
.wait:		dc.w	3


spr3d_vbl_megaobj:
		bsr.w	spr3d_vbl
		
		subq.w	#1,.wait
		bgt.s	.doit
		move.w	#2,.wait

		clr.w	spr3d_do_main
		bra.s	.no
		
.doit:		move.w	#1,spr3d_do_main

		move.w	spr3d_xpos,spr3d_xpos_clr
		subq.w	#1,spr3d_xpos		

.no:		rts
.wait:		dc.w	2

		section	data

; Object format
;
; dc.w numvert
; rept numvert
; dc.w x,y,z,s
; endr
; s=size, 0 (16x16 3.6% cpu), 1 (32x32 8.4% cpu), 2 (48x48 16.7% cpu), 3 (64x64 25% cpu)

spr3d_mega_s:	equ	12
spr3d_mega_obj:

		dc.w	34

		;center part with 48x48 sprites
		dc.w	spr3d_mega_s*-64,spr3d_mega_s*-144,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*32,spr3d_mega_s*-144,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*128,spr3d_mega_s*-64,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*128,spr3d_mega_s*32,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*32,spr3d_mega_s*128,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*-64,spr3d_mega_s*128,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*-160,spr3d_mega_s*32,spr3d_mega_s*0,3
		dc.w	spr3d_mega_s*-160,spr3d_mega_s*-64,spr3d_mega_s*0,3
		
		;midplane with 32x32 upper
		dc.w	spr3d_mega_s*-80,spr3d_mega_s*-80,spr3d_mega_s*60,1
		dc.w	spr3d_mega_s*64,spr3d_mega_s*-80,spr3d_mega_s*60,1
		dc.w	spr3d_mega_s*64,spr3d_mega_s*64,spr3d_mega_s*60,1
		dc.w	spr3d_mega_s*-80,spr3d_mega_s*64,spr3d_mega_s*60,1

		;midplane with 32x32 lower
		dc.w	spr3d_mega_s*-80,spr3d_mega_s*-80,spr3d_mega_s*-60,1
		dc.w	spr3d_mega_s*64,spr3d_mega_s*-80,spr3d_mega_s*-60,1
		dc.w	spr3d_mega_s*64,spr3d_mega_s*64,spr3d_mega_s*-60,1
		dc.w	spr3d_mega_s*-80,spr3d_mega_s*64,spr3d_mega_s*-60,1
		
		dc.w	spr3d_mega_s*-32,spr3d_mega_s*-32,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*0,spr3d_mega_s*-32,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*32,spr3d_mega_s*-32,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*-32,spr3d_mega_s*0,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*0,spr3d_mega_s*0,spr3d_mega_s*120,0
		dc.w	spr3d_mega_s*32,spr3d_mega_s*0,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*-32,spr3d_mega_s*32,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*0,spr3d_mega_s*32,spr3d_mega_s*100,0
		dc.w	spr3d_mega_s*32,spr3d_mega_s*32,spr3d_mega_s*100,0

		dc.w	spr3d_mega_s*-32,spr3d_mega_s*-32,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*0,spr3d_mega_s*-32,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*32,spr3d_mega_s*-32,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*-32,spr3d_mega_s*0,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*0,spr3d_mega_s*0,spr3d_mega_s*-120,0
		dc.w	spr3d_mega_s*32,spr3d_mega_s*0,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*-32,spr3d_mega_s*32,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*0,spr3d_mega_s*32,spr3d_mega_s*-100,0
		dc.w	spr3d_mega_s*32,spr3d_mega_s*32,spr3d_mega_s*-100,0



		section	text
		