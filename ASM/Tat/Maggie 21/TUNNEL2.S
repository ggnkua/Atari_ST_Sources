;
;
;
;	tunnel / c2p_converter notes
;
;	timings assume 2x2 conversions
;
;	based on 160x100 screen = 16000 pixels
;
;
;	version 1
;		move.l	x-$8000(a0),d0	;16
;		or.l	x-$4000(a0),d0	;20
;		or.l	x+$0000(a0),d0	;20
;		or.l	x+$4000(a0),d0	;20
;		or.l	x-$8000(a1),d0	;16
;		or.l	x-$4000(a1),d0	;20
;		or.l	x+00000(a1),d0	;20
;		or.l	x+$4000(a1),d0	;20

;		move.l	d0,x(a4)	;16
;		move.l	d0,x+160(a4)	;16	total 60+48=208 for 8 pixels
;						or 26*16000 cycles

;	version 2
;		move.w	x-$4000(a0),d0	;12
;		or.w	x-$2000(a0),d0	;16
;		or.w	x+$0000(a0),d0	;16
;		or.w	x+$2000(a0),d0	;16
;		movep.w	d0,x(a1)	;24
;		movep.w	d0,x+160(a1)	;24	total 60+48=108 for 4 pixels
;						or 27*16000 cycles

; So version 1 is quicker, uses 2 more address registers though...
;                          ...and twice as much in the gfx buffers...

;	How the textures are stored.
;	original texture is 32*32....
;
;	we make 4 copies of 64*64 (for movement)
;	size of each will be 64*64*2 bytes (each pixel data is a WORD)
;			(or 8K)
;	a0 - is non-shifted
;	a1 - same data, shifted by 2 to right
;	etc...

;------------------------------------------------------

;	Storage of original texture?
;
;


; Let's have a 320 x 160 tunnel.
		section	text

max_tunnel_chunk_width	equ	20
max_tunnel_height	equ	100		;double lined!

tunnel_chunk_width	dc.w	20
tunnel_height		dc.w	100		;double lined!


script_tunnel_start:
		move.l	(a6)+,tunnel_music_end
		movem.l	(a6)+,d0/d1
		move.w	d0,tunnel_chunk_width
		move.w	d1,tunnel_height
		move.l	(a6)+,tunnel_map_offset
		move.l	(a6)+,a0			;which palette!
		move.l	(a6)+,tunnel_gfx_pointer
		pea	(a6)
		moveq	#1,d0
		bsr	install_fade

		bsr	clear_screens
		bsr	tunnel_initialise
		bsr	draw_tunnel
		bsr	swap_screens
		bsr	start_fade
.loop:
		bsr	tunnel_frame
		move.l	music_timer,d0
		cmp.l	tunnel_music_end,d0		;find what's needed
		blt.s	.loop				;not there yet

		lea	black_palette,a0
		moveq	#2,d0
		bsr	install_fade
		bsr	start_fade
.loop2:	
		clr.l	vbl_timer
		bsr	tunnel_frame
		tst.w	fade_done_flag
		beq.s	.loop2
		move.l	(a7)+,a6
		rts

tunnel_frame:
		bsr	draw_tunnel
		bsr	wait_vbl_tunnel2
		bsr	swap_screens
		rts

wait_vbl_tunnel:
		tst.l	vbl_timer
		beq	wait_vbl_tunnel
		rts

wait_vbl_tunnel2:
		tst.l	vbl_timer
		beq	wait_vbl_tunnel2	;not quicker than 1 frame
		rts

;tunnel_draw:
;		bsr	tunnel_initialise
;
;		lea	tunnel_gfx_buffer+(2*64*64)*2,a0
;		move.l	$44e.w,a1
;		jsr	tunnel_instruction_buffer
;		illegal
;		rts


draw_tunnel

		move.l	tunnel_offset,d0
		add.l	#(64*2)*2,d0
		and.l	#%0111110111110,d0
		move.l	d0,tunnel_offset

		lea	tunnel_gfx_buffer+(2*64*64)*2,a0
		add.l	d0,a0

		move.w	tunnel_sine,d1			;add x-offset
		add.w	#2,d1
		and.w	#256*2-2,d1
		move.w	d1,tunnel_sine

		lea	sine_table,a1			;look up in table
		move.w	(a1,d1.w),d1
		mulu.w	#64*2,d1
		swap	d1
		add.w	#32,d1
		and.w	#%11111,d1
		add.w	d1,d1				;2 bytes each
		ext.l	d1
		add.l	d1,a0

		move.l	logic,a1
		;lea	160*(200-160)/2(a1),a1
		jsr	tunnel_instruction_buffer
		rts


tunnel_initialise:
		bsr	tunnel_make_instructions
		move.l	tunnel_gfx_pointer,a0
		bsr	tunnel_make_gfx_buffers
		rts

tunnel_make_instructions:
		lea	tunnel_instruction_buffer,a0
		lea	tunnel_offset_data,a1
		add.l	tunnel_map_offset,a1

		moveq	#0,d7				;x offset
		move.w	tunnel_height,d0
		subq.w	#1,d0
.loop1:	
		move.w	tunnel_chunk_width,d1
		add.w	d1,d1
		subq.w	#1,d1

		moveq	#1,d5				;what to add to d7!

.loop2:		lea	tunnel_loop_start,a2
		move.l	a0,a3				;save position

		moveq	#(tunnel_loop_size)/2-1,d2
.loop3:		move.w	(a2)+,(a0)+			;Copy instructions
		dbf	d2,.loop3			; to buffer

		move.w	(a1)+,d2			;fetch orig offset
		sub.w	#64*64*4,d2
		move.w	d2,tunnel_off3-tunnel_loop_start(a3)
		move.w	(a1)+,d2			;fetch orig offset
		sub.w	#64*64*2,d2
		move.w	d2,tunnel_off2-tunnel_loop_start(a3)
		move.w	(a1)+,d2			;fetch orig offset
		;add.w	#64*64*2,d2
		move.w	d2,tunnel_off1-tunnel_loop_start(a3)
		move.w	(a1)+,d2			;fetch orig offset
		add.w	#64*64*2,d2
		move.w	d2,tunnel_off4-tunnel_loop_start(a3)
							;screen offsets

		move.w	d7,tunnel_off5-tunnel_loop_start(a3)
		move.w	d7,d6
		add.w	#160,d6
		move.w	d6,tunnel_off6-tunnel_loop_start(a3)

		add.w	d5,d7				;next scrn chunk
		eor.w	#%110,d5			;1 or 7...
		dbf	d1,.loop2

		move.w	tunnel_chunk_width,d1
		asl.w	#3,d1				;multiply by 8
		neg.w	d1
		move.w	d1,d2
		add.w	#320,d1
		ext.l	d1
		add.l	d1,d7
		add.w	#200,d2
		add.w	d2,d2
		add.w	d2,a1
		;add.l	#320-(8*tunnel_chunk_width),d7	;next scan line
		;add.l	#2*(200-(8*tunnel_chunk_width)),a1
		dbf	d0,.loop1
		move.w	#$4e75,(a0)+			;'rts'
		rts



;------------------------------------------------------
tunnel_loop_start:
tunnel_off1	= *+2
		move.w	2(a0),d0	;16
tunnel_off2	= *+2
		or.w	2(a0),d0	;20
tunnel_off3	= *+2
		or.w	2(a0),d0	;20
tunnel_off4	= *+2
		or.w	2(a0),d0	;20
tunnel_off5	= *+2
		movep.w	d0,2(a1)	;16
tunnel_off6	= *+2
		movep.w	d0,2+160(a1)	;16	total 60+48=108 for 4 pixels
tunnel_loop_end:

tunnel_loop_size =	tunnel_loop_end-tunnel_loop_start

;------------------------------------------------------
tunnel_make_gfx_buffers:
		lea	tunnel_gfx_buffer,a1
		lea	64*64*2(a1),a2
		lea	64*64*2(a2),a3
		lea	64*64*2(a3),a4
		move.w	#32-1,d0
		moveq	#0,d1
.loop1:		moveq	#2-1,d2			;chunks
.loop2:		move.w	(a0)+,d3
		move.w	(a0)+,d4
		moveq	#16-1,d5		;pixels to do
.loop3:
		moveq	#0,d6
		moveq	#0,d7
		add.w	d3,d3
		scs	d6
		add.w	d4,d4
		scs	d7
		and.b	#%11000000,d6
		and.b	#%11000000,d7
		move.b	d6,(a1)+
		move.b	d7,(a1)+

		lsr.b	#2,d6
		lsr.b	#2,d7
		move.b	d6,(a2)+
		move.b	d7,(a2)+

		lsr.b	#2,d6
		lsr.b	#2,d7
		move.b	d6,(a3)+
		move.b	d7,(a3)+

		lsr.b	#2,d6
		lsr.b	#2,d7
		move.b	d6,(a4)+
		move.b	d7,(a4)+
		dbf	d5,.loop3

		moveq	#16-1,d5		;copy 32 pixels
.loop4:		move.l	-64(a1),(a1)+		;  or 64 bytes..
		move.l	-64(a2),(a2)+
		move.l	-64(a3),(a3)+
		move.l	-64(a4),(a4)+
		dbf	d5,.loop4
		dbf	d2,.loop2
		dbf	d0,.loop1

; Copy overspill:
		lea	tunnel_gfx_buffer+32*64*2,a1
		lea	64*64*2(a1),a2
		lea	64*64*2(a2),a3
		lea	64*64*2(a3),a4
		move.w	#32*64-1,d0		
.copy
		move.w	-32*64*2(a1),(a1)+
		move.w	-32*64*2(a2),(a2)+
		move.w	-32*64*2(a3),(a3)+
		move.w	-32*64*2(a4),(a4)+
		dbf	d0,.copy
		rts




;------------------------------------------------------
			section	data
;------------------------------------------------------
tunnel_offset_data:	incbin	data\tunnel.dat

tunnel_gfx_1:		incbin	data\tunnel.gfx
tunnel_gfx_2:		incbin	data\tunnel2.gfx
tunnel_gfx_3:		incbin	data\tunnel3.gfx
tunnel_gfx_4:		incbin	data\tunnel4.gfx

;------------------------------------------------------
			section	bss
;------------------------------------------------------
tunnel_offset:		ds.l	1
tunnel_sine:		ds.w	1
tunnel_music_end:	ds.l	1
tunnel_map_offset:	ds.l	1
tunnel_gfx_pointer:	ds.l	1


;tunnel_gfx_buffer:
;			ds.b	4*(64*64*2)		; = 32768 bytes

;tunnel_instruction_buffer:
;			ds.b	max_tunnel_chunk_width*max_tunnel_height*2*(tunnel_loop_size)+10


;------------------------------------------------------
			section	text
;------------------------------------------------------
