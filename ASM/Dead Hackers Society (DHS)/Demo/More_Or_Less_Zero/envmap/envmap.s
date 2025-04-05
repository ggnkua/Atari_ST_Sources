; envmap.s
;
; Envmap in overscan effect

		section	text

envmap_init:	rts

envmap_runtime_init:		;250 vbl!
		subq.w	#1,.once
		bne.w	.done

		;jsr	black_pal
		;jsr	clear_screens
		;jsr	syncfix				;fix eventual bitplane corruption
		;jsr	black_pal

		ifne	init_green
		move.w	#$0020,$ffff8240.w
		endc

		jsr	envmap_make_inv_tab
		jsr	init_c2p
		
		lea.l	envmap_lz77,a0
		lea.l	envmap_texture,a1
		jsr	lz77

		jsr	envmap_copy_tex_nibble
		jsr	clear_16k

		move.l	#env_filler_144x100_256col,env_fillrout		;select envmap polygon filler
		move.l	#25*96/2+22,env_center				;center of output buffer 26
		move.l	#envmap_texture+64*128+64,env_textureadr	;texture
		move.l	#envmap_texture+128*128+64*128+64,env_textureadr2	;texture shifted
		move.l	#1350,project_const				;350 min


;------------- copy overscan code
		lea.l	generic_code,a0

		move.l	#envmap_code1_end,d0		;main timer_a overscan lines
		sub.l	#envmap_code1_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.w	#50-1,d7
.code1a:	move.l	d0,d6
		lea.l	envmap_code1_start,a1
.code1b:	move.w	(a1)+,(a0)+
		dbra	d6,.code1b
		dbra	d7,.code1a

		move.l	#envmap_code2_end,d0		;jmp back to timer_a (rts not possible due to a7 use)
		sub.l	#envmap_code2_start,d0
		lsr.l	#1,d0
		subq.l	#1,d0
		move.l	d0,d6
		lea.l	envmap_code2_start,a1
.code2b:	move.w	(a1)+,(a0)+
		dbra	d6,.code2b
		

;-------------- end of overscan code -----------

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1


envmap_vbl_out:
		subq.w	#1,.wait
		bne.s	.no
		move.w	#3,.wait
		movem.l	envmap_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	envmap_mainpal,a0
		lea.l	envmap_blackpal,a1
		jsr	component_fade
.no:		addq.l	#8,project_const

		cmp.l	#16*59,.pos
		bgt.w	.nope

		move.l	.pos,d0
		lea.l	envmap_bgcols,a0
		add.l	d0,a0
		lea.l	envmap_bgcols2+3840,a1
		add.l	d0,a1
		movem.l	.empty,d0-d3
		
		movem.l	d0-d3,(a0)
		movem.l	d0-d3,960(a0)
		movem.l	d0-d3,960*2(a0)
		movem.l	d0-d3,960*3(a0)
		movem.l	d0-d3,(a1)
		movem.l	d0-d3,960(a1)
		movem.l	d0-d3,960*2(a1)
		movem.l	d0-d3,960*3(a1)

		subq.w	#1,.wait2
		bne.s	.nope
		move.w	#2,.wait2

		add.l	#16,.pos

.nope:
		bra.w	envmap_vbl
.pos:		dc.l	0
.wait:		dc.w	3
.wait2:		dc.w	2
.empty:		dcb.w	8,$0000


envmap_vbl_in:
		subq.w	#1,.wait
		bne.s	.no
		move.w	#5,.wait
		movem.l	envmap_mainpal,d0-d7
		movem.l	d0-d7,$ffff8240.w
		lea.l	envmap_mainpal,a0
		lea.l	envmap_pal,a1
		jsr	component_fade
.no:		cmp.l	#350,project_const
		ble.s	.done
		subq.l	#8,project_const
.done:


		cmp.l	#16*59,.pos
		bgt.w	.nope

		move.l	.pos,d0
		lea.l	envmap_bgcols,a0
		add.l	d0,a0
		lea.l	envmap_bgcols2+3840,a1
		add.l	d0,a1
		lea.l	envmap_bgcols_data,a2
		add.l	d0,a2
		lea.l	envmap_bgcols2_data,a3
		add.l	d0,a3
		
		movem.l	(a2),d0-d3
		movem.l	d0-d3,(a0)
		movem.l	(a2),d0-d3
		movem.l	d0-d3,960(a0)
		movem.l	(a2),d0-d3
		movem.l	d0-d3,960*2(a0)
		movem.l	(a2),d0-d3
		movem.l	d0-d3,960*3(a0)

		movem.l	(a3),d0-d3
		movem.l	d0-d3,(a1)
		movem.l	(a3),d0-d3
		movem.l	d0-d3,960(a1)
		movem.l	(a3),d0-d3
		movem.l	d0-d3,960*2(a1)
		movem.l	(a3),d0-d3
		movem.l	d0-d3,960*3(a1)

		subq.w	#1,.wait2
		bne.s	.nope
		move.w	#2,.wait2

		add.l	#16,.pos

.nope:
		bra.s	envmap_vbl
.wait:		dc.w	5
.wait2:		dc.w	2
.pos:		dc.l	0

envmap_vbl:
		lea.l	$ffff8203.w,a0
		move.l	empty_adr,d0
		movep.l	d0,(a0)

		add.l	#48,envmap_zoomsin			;3d zoom in/out
		and.l	#$1fff,envmap_zoomsin


		add.w	#12,env_anx			;3d angles
		add.w	#16,env_any
		add.w	#8,env_anz
		and.w	#$0fff,env_anx
		and.w	#$0fff,env_any
		and.w	#$0fff,env_anz


		move.l	envmap_rastscr_adr1,d0		;swap raster buffers
		move.l	envmap_rastscr_adr2,envmap_rastscr_adr1
		move.l	d0,envmap_rastscr_adr2


		lea.l	envmap_bgcols,a0		;background rasters layer 1
		cmp.l	#16*59,.bgofs
		blt.s	.add
		clr.l	.bgofs
		bra.s	.done
.add:		add.l	#16,.bgofs
.done:		add.l	.bgofs,a0
		move.l	a0,envmap_bgcols_adr

		lea.l	envmap_bgcols2+3840,a2		;background rasters layer 2
		add.l	.bg2pos,a2
		move.l	a2,envmap_bgcols_adr2
		add.l	#32,.bg2pos
		cmp.l	#16*59,.bg2pos
		blt.s	.noclrbg2
		clr.l	.bg2pos
.noclrbg2:


		cmp.l	#320-70+100,.pos			;raster stripes above and under fx
		blt.s	.noreset
		clr.l	.pos
.noreset:	lea.l	env_rastcols,a0
		add.l	.pos,a0
		move.l	a0,env_uprastadr
		cmp.l	#320-70+100,.pos2
		blt.s	.noreset2
		clr.l	.pos2
.noreset2:	lea.l	env_rastcols,a0
		add.l	.pos2,a0
		move.l	a0,env_dnrastadr
		addq.l	#2,.pos
		addq.l	#2,.pos2



		rts
.bgofs:		dc.l	0
.pos:		dc.l	0
.pos2:		dc.l	96
.bg2pos:	dc.l	0

envmap_main:	
  		move.w	#alien_numcoord,env_numvertex		;number of vertexes in object
		move.w	#alien_numface,env_numface		;number of faces in object
		move.l	#alien_coords,env_coordsadr		;address of vertexes
		move.l	#alien_ecoords,env_ecoordsadr		;address of env vertexes
		move.l	#alien_faces,env_facesadr		;address of facelist

		move.l	envmap_chunkyadr1,env_destadr
		
		jsr	env_mul_rotate				;rotate
		jsr	env_backfaces				;backside clip
		jsr	counting_sort
		jsr	env_get_faces
		jsr	env_c2p

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2
		
		move.l	envmap_chunkyadr1,d0
		move.l	envmap_chunkyadr2,envmap_chunkyadr1
		move.l	d0,envmap_chunkyadr2

		rts
		
envmap_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w

		movem.l d0-a6,-(sp)

		dcb.w	69-2,$4e71

		moveq.l	#0,d7				;1
		moveq.l	#2,d6				;1


		lea.l	$ffff8209.w,a0
		moveq.l	#127,d1

.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-7-7-23-5,$4e71	
		move.l	screen_adr,d0	;5
		lea.l	$ffff8203.w,a0	;2

		;move.l	envmap_bgcols_adr,a1	;5
		move.l	envmap_rastscr_adr1,a1	;5

		lea.l	$ffff8240+16.w,a2	;2

		movem.l	(a1),d1-d4		;11
		lea.l	16(a1),a1		;2
		movem.l	d1-d4,(a2)		;10

		move.l	envmap_chunkyadr2,a6	;5


		; rasterline
		lea.l	$ffff8240.w,a3		;2
		move.l	env_uprastadr,a4	;5
		dcb.w	8,$4e71
		rept	35
		move.w	(a4)+,(a3)		;3*35 = 105
		endr
		move.w	#0,(a3)			;3
		dcb.w	5,$4e71
		
		dcb.w	128-20-3,$4e71

		move.l	a7,envmap_savea7	;5
		move.l	envmap_bgcols_adr2,a7	;5
		move.l	envmap_rastscr_adr2,a5	;5
		move.l	envmap_bgcols_adr,a4	;5

		jmp	generic_code		;3
envmap_endoverscan:

		move.l	empty_adr,d0		;5
		movep.l	d0,(a0)			;6
		dcb.w	128-11-3,$4e71		;-3 = jmp

		lea.l	$ffff8240.w,a3		;2
		move.l	env_dnrastadr,a4	;5
		dcb.w	8,$4e71
		rept	35
		move.w	(a4)+,(a3)		;3*35 = 105
		endr
		move.w	#0,(a3)			;2
		dcb.w	5,$4e71

		move.l	envmap_savea7,a7
		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

envmap_code1_start:
		;-------------------------------
		;rept	50	
		movep.l	d0,(a0)			;6	screenptr
		move.b	d6,$ffff8260.w		;3	left border
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-60-11,$4e71		;90	
		movem.l	envmap_bg,d1-d5/a3	;17	clear chunky
		movem.l	d1-d5/a3,(a6)		;14
		move.w	envmap_bg+24,24(a6)	;6
		movem.l	d1-d5/a3,26(a6)		;15
		move.w	envmap_bg+24,50(a6)	;6
		lea.l	52(a6),a6		;2
		movem.l	(a1),d1-d4		;11	get colours
		move.b	d7,$ffff820a.w		;3	right border
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-2-10,$4e71		;20	
		lea.l	16(a1),a1		;2	next line of colours
		movem.l	d1-d4,(a2)		;10	set colours
		;-------------------------------
		movep.l	d0,(a0)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-60-11,$4e71		;70
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		movem.l	(a1),d1-d4 ;11
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-2-10,$4e71		;70
		lea.l	16(a1),a1		;2
		movem.l	d1-d4,(a2)		;10
		;-------------------------------
		movep.l	d0,(a0)
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		dcb.w	90-60-11-4,$4e71	;70
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		move.l	(a4)+,d1		;3
		add.l	(a7)+,d1		;4
		move.l	d1,(a5)+		;3
		movem.l	(a1),d1-d4 ;11
		ifne	hatari
		add.l	#230,d0			;4
		endc
		ifeq	hatari
		add.l	#224,d0
		endc
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		dcb.w	20-2-10,$4e71		;70
		lea.l	16(a1),a1		;2
		movem.l	d1-d4,(a2)		;10
		;-------------------------------
		;endr
envmap_code1_end:
envmap_code2_start:	jmp	envmap_endoverscan
envmap_code2_end:


envmap_make_inv_tab:
		lea	env_inv_table,a0
		move.w	#-1,d7
.inv:		move.w	d7,d0
		not.w	d0		;     0 -> 65536
		sub.w	#32768,d0	;-32768 -> 32767
		move.l	#$10000,d1
		divs	d0,d1
		move.w	d1,(a0)+
		dbra	d7,.inv
		rts

envmap_copy_tex_nibble:
		lea.l	envmap_texture,a0
		move.l	a0,a1
		add.l	#128*128,a1
		moveq.l	#0,d0
		move.w	#128*128-1,d7
.sh:		move.b	(a0)+,d0
		lsl.b	#4,d0
		move.b	d0,(a1)+
		dbra	d7,.sh
		rts


		include	'envmap/envmultb.s'
		include	'envmap/matrix.s'
		include	'envmap/rot_mul.s'
		include	'envmap/c2p.s'
env_obj:       	include	'envmap/lessenv7.i' 



		section	data

envmap_mainpal:		dcb.w	16,$0000
envmap_blackpal:	dcb.w	16,$0000

envmap_pal:		dc.w	$0000,$0002,$0024,$0146,$0367,$0477,$0577,$0677
			dc.w	$0110,$0210,$0320,$0430,$0540,$0650,$0760,$0770


envmap_lz77:		incbin	'envmap/env.z77'
			even
				
envmap_chunkyadr1:	dc.l	envmap_chunky+32768+1024		;1024=overflow buffer
envmap_chunkyadr2:	dc.l	envmap_chunky+32768+1024+9600+1024

envmap_bg:		dc.w	$8ecb
			dc.l	$a9abcded,$cba9abcd,$edcba9ab,$cdedcba9,$abcdedcb
			dc.w	$a9ab
			dc.w	$cdef

envmap_bgcols_adr:	dc.l	envmap_bgcols
envmap_bgcols_data:	incbin	'envmap/bg.12b'
			;ds.w	8*60*3
envmap_bgcols_adr2:	dc.l	envmap_bgcols2+960*4
envmap_bgcols2_data:	
			dcb.w	8,$0000
			dcb.w	8,$0888
			dcb.w	8,$0111
			dcb.w	8,$0999
			dcb.w	8,$0222
			dcb.w	8,$0aaa
			dcb.w	8,$0333
			dcb.w	8,$0bbb
			dcb.w	8,$0bbb
			dcb.w	8,$0333
			dcb.w	8,$0aaa
			dcb.w	8,$0222
			dcb.w	8,$0999
			dcb.w	8,$0111
			dcb.w	8,$0888
			dcb.w	8,$0000
			dcb.w	44*8,$0000
		
env_uprastadr:		dc.l	env_rastcols
env_dnrastadr:		dc.l	env_rastcols
env_rastcols:
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

			dc.w	$0000,$0008,$0001,$0009,$0002,$000a,$0003,$000b
			dc.w	$0004,$000c,$0005,$000d,$0006,$000e,$0007,$000f
			dc.w	$008f,$001f,$009f,$002f,$00af,$003f,$00bf,$004f
			dc.w	$00cf,$005f,$00cf,$006f,$00ef,$007f,$00ff,$08ff
			dc.w	$01ff,$09ff,$02ff,$0aff,$03ff,$0bff,$04ff,$0cff
			dc.w	$05ff,$0dff,$06ff,$0eff,$07ff,$0fff,$07ff,$0eff
			dc.w	$06ff,$0dff,$05ff,$0cff,$04ff,$0bff,$03ff,$0aff
			dc.w	$02ff,$09ff,$01ff,$08ff,$00ff,$007f,$00ef,$006f
			dc.w	$00df,$005f,$00cf,$004f,$00bf,$003f,$00af,$002f
			dc.w	$009f,$001f,$008f,$000f,$0007,$000e,$0006,$000d
			dc.w	$0005,$000c,$0004,$000b,$0003,$000a,$0002,$0009
			dc.w	$0001,$0008,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
			dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

 
envmap_rastscr_adr1:	dc.l	envmap_rastscr1 
envmap_rastscr_adr2:	dc.l	envmap_rastscr2
envmap_zoomsin:		dc.l	0

		section	bss

envmap_savea7:		ds.l	1
envmap_rastscr1:	ds.w	8*150
envmap_rastscr2:	ds.w	8*150

		section	text


	
