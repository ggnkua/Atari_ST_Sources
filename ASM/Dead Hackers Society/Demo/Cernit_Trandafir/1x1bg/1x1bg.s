; Altparty 2009 STe demo
; Texturemapper on top of 1x1 background
;
; 1x1bg.s

XSCR	= 160
YSCR	= 100

		section	text

;-------------- INIT
bg1x1_init:	rts

;-------------- RUNTIME INIT
bg1x1_runtime_init_pic:
		subq.w	#1,.once
		bne.w	.done

		jsr	black_pal
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		ifne	init_finish
		move.w	#$0700,$ffff8240.w
		endc

		;depack background
		lea.l	bg1x1_pic_ice,a0
		lea.l	bg1x1_pic,a1
		jsr	ice

		;clear screens
		move.l	bg1x1_scr1,a0
		move.l	bg1x1_scr2,a1
		moveq.l	#0,d0
		move.w	#32000/4-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a1)+
		dbra	d7,.clr
		
		move.l	bg1x1_scr2,d0
		move.l	d0,d1					;set screen
		lsr.w	#8,d0					;
		move.l	d0,$ffff8200.w				;
		move.b	d1,$ffff820d.w				;
		
.done:		rts
.once:		dc.w	1


bg1x1_runtime_init:
		subq.w	#1,.once
		bne.w	.done


		;depack texture
		lea.l	bg1x1_txt_ice,a0
		lea.l	generic_256k,a1
		jsr	ice
		
		;convert texture nibble -> byte
		lea.l	generic_256k,a0
		lea.l	bg1x1_textures,a1
		move.w	#128*128/2-1,d7
.shift2:	move.b	(a0)+,d0
		move.b	d0,d1
		lsr.b	#4,d0
		lsl.b	#4,d1
		lsr.b	#4,d1
		move.b	d0,(a1)+
		move.b	d1,(a1)+
		dbra	d7,.shift2
		
		jsr	bg1x1_copy_tex_nibble_128

		move.l	#bg1x1_filler_160x100_256col,bg1x1_fillrout
		move.l	#(XSCR*YSCR/2+XSCR/2)/2+12,bg1x1_center				
;		move.l	#bg1x1_textures+64*128+64,bg1x1_textureadr
;		move.l	#bg1x1_textures+64*128+64+128*128,bg1x1_textureadr2

		;FIXME: adjust texture offset here (linewidth=256)
		move.l	#bg1x1_textures+256*50,bg1x1_textureadr
		move.l	#bg1x1_textures+256*50+128,bg1x1_textureadr2

		move.l	#500,bg1x1_project_const

		jsr	bg1x1_make_inv_tab
		jsr	init_c2p

		; create mask c2p table
		lea.l	c2ptable,a0
		lea.l	c2pmask,a1
		move.w	#65536-1,d7
.mask:		move.l	(a0)+,d0
		move.l	d0,d1
		lsr.l	#8,d0
		or.b	d0,d1
		lsr.l	#8,d0
		or.b	d0,d1
		lsr.w	#8,d0
		or.b	d0,d1
		not.b	d1
		move.b	d1,(a1)+
		move.b	d1,(a1)+
		move.b	d1,(a1)+
		move.b	d1,(a1)+
		dbra	d7,.mask

		ifne	init_finish
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1


bg1x1_runtime_init_scramble:
		subq.w	#1,.once
		bne.s	.no

		;scramble background to fit c2p order
		lea.l	.tmp,a0
		lea.l	bg1x1_pic+34,a1
		move.w	#320*200/2/8-1,d7
.scramble:
		movem.l	(a1),d0-d1
		movem.l	d0-d1,(a0)
		
		move.b	(a0),(a1)+
		move.b	2(a0),(a1)+
		move.b	4(a0),(a1)+
		move.b	6(a0),(a1)+

		move.b	1(a0),(a1)+
		move.b	3(a0),(a1)+
		move.b	5(a0),(a1)+
		move.b	7(a0),(a1)+
		dbra	d7,.scramble
.no:		rts
.once:		dc.w	1
.tmp:		ds.l	2


;-------------- VBL
bg1x1_vbl:
		lea.l	$ffff8203.w,a0
		move.l	bg1x1_scr2,d0
		movep.l	d0,0(a0)
		
		addq.l	#1,timer_t

		add.w	#6,bg1x1_anx			;3d angles
		add.w	#10,bg1x1_any
		add.w	#8,bg1x1_anz
		and.w	#$0fff,bg1x1_anx
		and.w	#$0fff,bg1x1_any
		and.w	#$0fff,bg1x1_anz

		rts

bg1x1_scroll_in:
		bsr.s	bg1x1_vbl
		tst.w	bg1x1_ypos
		ble.s	.done
		subq.w	#1,bg1x1_ypos
.done:		rts

bg1x1_scroll_out:
		bsr.s	bg1x1_vbl
		cmp.w	#-100,bg1x1_ypos
		ble.s	.done
		subq.w	#1,bg1x1_ypos
.done:		rts

bg1x1_fade_out:
		bsr.w	bg1x1_vbl

		movem.l	bg1x1_pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	bg1x1_pic+2,a0
		lea.l	bg1x1_black,a1
		jsr	component_fade
		rts

bg1x1_flash:
		bsr.w	bg1x1_vbl

		movem.l	bg1x1_flashpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
		lea.l	bg1x1_flashpal,a0
		lea.l	bg1x1_pic+2,a1
		jsr	fade
		rts


bg1x1_copypic_vbl:
		subq.w	#1,.wait
		bne.s	.nocol
		move.w	#4,.wait
		
		movem.l bg1x1_blackstart,d0-d7
		movem.l d0-d7,$ffff8240.w
		
		lea.l	bg1x1_blackstart,a0
		lea.l	bg1x1_pic+2,a1
		jsr	component_fade
.nocol:
		subq.w	#1,.draw
		bpl.s	.done
		
		cmp.w	#160*199,.ofs
		bge.s	.done
		move.l	bg1x1_scr1,a0
		move.l	bg1x1_scr2,a1
		lea.l	bg1x1_pic+34,a2
		add.w	.ofs,a0
		add.w	.ofs,a1
		add.w	.ofs,a2
		move.w	#160/4-1,d7
.copy:		move.l	(a2)+,d0
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		dbra	d7,.copy
		add.w	#160,.ofs
.done:		rts
.ofs:		dc.w	0
.wait:		dc.w	4
.draw:		dc.w	100

;-------------- MAIN
bg1x1_main:	
  		move.w	#alien_numcoord,bg1x1_numvertex		;number of vertexes in object
		move.w	#alien_numface,bg1x1_numface		;number of faces in object
		move.l	#alien_coords,bg1x1_coordsadr		;address of vertexes
		move.l	#alien_ecoords,bg1x1_ecoordsadr		;address of env vertexes
		move.l	#alien_faces,bg1x1_facesadr		;address of facelist
		move.l	bg1x1_chunkyadr1,bg1x1_destadr
		
		jsr	bg1x1_chunkyclear
		jsr	bg1x1_mul_rotate			;rotate
		bsr.w	bg1x1_obj_ymove
		jsr	bg1x1_backfaces				;backside clip
		jsr	bg1x1_counting_sort
		jsr	bg1x1_get_faces

		;do 1x1 c2p area
		moveq.l	#4,d0
		bsr.w	bg1x1_c2p
		moveq.l	#13,d0
		bsr.w	bg1x1_c2p
		moveq.l	#14,d0
		bsr.w	bg1x1_c2p
		moveq.l	#23,d0
		bsr.w	bg1x1_c2p
		moveq.l	#24,d0
		bsr.w	bg1x1_c2p
		moveq.l	#25,d0
		bsr.w	bg1x1_c2p
		moveq.l	#33,d0
		bsr.w	bg1x1_c2p
		moveq.l	#34,d0
		bsr.w	bg1x1_c2p
		moveq.l	#35,d0
		bsr.w	bg1x1_c2p
		moveq.l	#36,d0
		bsr.w	bg1x1_c2p
		moveq.l	#46,d0
		bsr.w	bg1x1_c2p
		moveq.l	#47,d0
		bsr.w	bg1x1_c2p

		;do standard c2p area
		moveq.l	#5,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#6,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#7,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#8,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#15,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#16,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#17,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#18,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#19,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#26,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#27,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#28,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#29,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#37,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#38,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#39,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#44,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#45,d0
		bsr.w	bg1x1_c2p_standard
		moveq.l	#48,d0
		bsr.w	bg1x1_c2p_standard

		move.l	bg1x1_scr1,d0
		move.l	bg1x1_scr2,bg1x1_scr1
		move.l	d0,bg1x1_scr2

		rts

bg1x1_obj_ymove:
		lea.l	bg1x1_rotcoords+2,a0
		move.w	bg1x1_numvertex,d7
		subq.w	#1,d7
		move.w	bg1x1_ypos,d0
.move:		add.w	d0,(a0)
		addq.l	#8,a0
		dbra	d7,.move
		rts
		
bg1x1_chunkyclear: 
		lea.l	bg1x1_chunky+160*100/2,a6
		movem.l	.zero,d0-a5
		rept	142
		movem.l	d0-a5,-(a6)		;56
		endr
		movem.l	d0-a3,-(a6)		;48
		rts
.zero:		dcb.l	15,$0

bg1x1_c2p:
;input
;d0.w = square to c2p, value 0-49 (10*5 squares)

		lea.l	.gfxofs,a1
		lea.l	.chunkyofs,a2
		lsl.w	#2,d0
		move.l	(a1,d0.w),d1
		move.l	(a2,d0.w),d2

		move.l	bg1x1_scr1,a0
		add.l	d1,a0
		move.l	bg1x1_chunkyadr1,a1
		add.l	d2,a1
		lea.l	c2ptable,a2
		lea.l	bg1x1_pic+34,a3
		add.l	d1,a3
		lea.l	c2pmask,a4
		
		move.w	#20-1,d7
.y:
q:		set	0
		rept	2
		moveq.l	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		move.l	(a2,d0.l),d1
		move.l	(a4,d0.l),d2
		move.l	160(a3),d4	;bg
		move.l	(a3)+,d3	;bg
		and.l	d2,d3
		or.l	d1,d3
		and.l	d2,d4
		or.l	d1,d4
		movep.l	d3,q(a0)
		movep.l	d4,q+160(a0)

		moveq.l	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		move.l	(a2,d0.l),d1
		move.l	(a4,d0.l),d2
		move.l	160(a3),d4	;bg
		move.l	(a3)+,d3	;bg
		and.l	d2,d3
		or.l	d1,d3
		and.l	d2,d4
		or.l	d1,d4
		movep.l	d3,q+1(a0)
		movep.l	d4,q+161(a0)
q:		set	q+8
		endr

		lea.l	320(a0),a0
		lea.l	80-8(a1),a1
		lea.l	160+160-16(a3),a3

		dbra	d7,.y
		rts
.gfxofs:
q:		set	0
		rept	5
w:		set	0
		rept	10
		dc.l	16*w+160*q
w:		set	w+1
		endr
q:		set	q+40
		endr
.chunkyofs:
q:		set	0
		rept	5
w:		set	0
		rept	10
		dc.l	8*w+80*q
w:		set	w+1
		endr
q:		set	q+20
		endr


bg1x1_c2p_standard:
;input
;d0.w = square to c2p, value 0-49 (10*5 squares)

		lea.l	.gfxofs,a1
		lea.l	.chunkyofs,a2
		lsl.w	#2,d0
		move.l	(a1,d0.w),d1
		move.l	(a2,d0.w),d2

		move.l	bg1x1_scr1,a0
		add.l	d1,a0
		move.l	bg1x1_chunkyadr1,a1
		add.l	d2,a1
		lea.l	c2ptable,a2
		
		move.w	#20-1,d7
.y:
q:		set	0
		rept	2
		moveq.l	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		move.l	(a2,d0.l),d0
		movep.l	d0,q(a0)
		movep.l	d0,q+160(a0)

		moveq.l	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		move.l	(a2,d0.l),d0
		movep.l	d0,q+1(a0)
		movep.l	d0,q+161(a0)

q:		set	q+8
		endr

		lea.l	320(a0),a0
		lea.l	80-8(a1),a1

		dbra	d7,.y
		rts
.gfxofs:
q:		set	0
		rept	5
w:		set	0
		rept	10
		dc.l	16*w+160*q
w:		set	w+1
		endr
q:		set	q+40
		endr
.chunkyofs:
q:		set	0
		rept	5
w:		set	0
		rept	10
		dc.l	8*w+80*q
w:		set	w+1
		endr
q:		set	q+20
		endr


bg1x1_make_inv_tab:
		lea.l	bg1x1_inv_table,a0
		move.w	#65536-1,d7
.inv:
		move.w	d7,d0
		not.w	d0		;     0 -> 65536
		sub.w	#32768,d0	;-32768 -> 32767
;		sub.w	#32768/2,d0	;-32768 -> 32767
;		neg.w	d0
		move.l	#$10000,d1
		divs	d0,d1
		move.w	d1,(a0)+
		dbra	d7,.inv
		rts

		;texture size = 128x128
bg1x1_copy_tex_nibble_128:
		lea	bg1x1_textures,a0
		lea	127*256(a0),a1	;last row
		lea	127*128(a0),a0	;last row
		move.w	#128-1,d6
.sepy:
		move.w	#128-1,d7
.sepx:
		move.b	(a0)+,d0
		move.b	d0,(a1)+
		lsl.b	#4,d0
		move.b	d0,127(a1)
		dbra	d7,.sepx
		lea	-128-128(a0),a0
		lea	-128-256(a1),a1
		dbra	d6,.sepy
		rts

		ifne	0
		;texture size = 256x256
bg1x1_copy_tex_nibble_256:
		lea	bg1x1_textures,a0
		lea	bg1x1_textures+256*256,a1
		moveq.l	#0,d0
		move.w	#256*256-1,d7
.sh:		move.b	(a0)+,d0
		lsl.b	#4,d0
		move.b	d0,(a1)+
		dbra	d7,.sh
		rts
		endc

		include	'1x1bg/visu.s'
		include	'1x1bg/trans.s'

bg1x1_obj:	include	'1x1bg/rose.inc' 
		even

;--- DATA -------------------------------------------------------------

			section	data

bg1x1_blackstart:	dcb.w	16,$0000
bg1x1_black:		dcb.w	16,$0000
bg1x1_flashpal:		dcb.w	16,$0fff

bg1x1_txt_ice:		incbin	'1x1bg/txt.ice' ;nibble/pixel ice packed
			even

bg1x1_chunky:		;ds.b	160*100/2	;nibble chunky buffer
bg1x1_pic_ice:		incbin	'1x1bg/pic.ice' ;lowres scrabled picture ice packed
			even
				
bg1x1_chunkyadr1:	dc.l	bg1x1_chunky

bg1x1_scr1:		dc.l	generic_code
bg1x1_scr2:		dc.l	generic_code+32000

bg1x1_ypos:		dc.w	100
timer_t:		dc.l	0


			section	text
