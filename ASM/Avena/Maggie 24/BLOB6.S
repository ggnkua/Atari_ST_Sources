; BLOB.S
;
; Blob effect for Maggie 24 intro
; Uses code as described in Maggie 24 programming article
;
;

			output	a:\blob.prg
			opt	p=68000

;--------------------------------------------------------------------

blob_table_x		equ	320
blob_table_y		equ	200
;max_r			equ	90

;--------------------------------------------------------------------

;--------------------------------------------------------------------
			section	bss

max_r			ds.l	1
max_r_squared		ds.l	1

blob_finish_time	ds.l	1
blob_fadeoff_palette	ds.l	1
blob_fadeon_palette	ds.l	1
blob_colour1		ds.l	1
blob_colour2		ds.l	1
blob_colour3		ds.l	1


blob1_pos		ds.l	1
blob2_pos		ds.l	1
blob3_pos		ds.l	1
blob_colour_address	ds.l	1

;--------------------------------------------------------------------

			section	data
blob_palette1:
			dc.w	$000,$100,$200,$300
			dc.w	$400,$500,$600,$f00
			dc.w	$f11,$f22,$f33,$f44
			dc.w	$f55,$f66,$f77,$fff
blob_palette2:
			dc.w	$000
			dc.w	$100
			dc.w	$200
			dc.w	$300
			dc.w	$400
			dc.w	$500
			dc.w	$600
			dc.w	$700
			dc.w	$720
			dc.w	$740
			dc.w	$760
			dc.w	$770
			dc.w	$772
			dc.w	$774
			dc.w	$776
			dc.w	$777
			dc.w	$777
blob_palette3
			dc.w	$000
			dc.w	$010
			dc.w	$010
			dc.w	$120
			dc.w	$220
			dc.w	$320
			dc.w	$420
			dc.w	$530
			dc.w	$630
			dc.w	$741
			dc.w	$752
			dc.w	$763
			dc.w	$774
			dc.w	$775
			dc.w	$776
			dc.w	$777

blob_palette4:
			dc.w	$000
			dc.w	$001
			dc.w	$001

			dc.w	$102
			dc.w	$202
			dc.w	$302

			dc.w	$402
			dc.w	$503
			dc.w	$603

			dc.w	$714
			dc.w	$725
			dc.w	$736

			dc.w	$747
			dc.w	$757
			dc.w	$767
			dc.w	$777

blob_palette5:
			dc.w	$000
			dc.w	$001
			dc.w	$002
			dc.w	$003
			dc.w	$004
			dc.w	$005
			dc.w	$006
			dc.w	$007
			dc.w	$006
			dc.w	$005
			dc.w	$004
			dc.w	$003
			dc.w	$002
			dc.w	$001
			dc.w	$000
			dc.w	$000

c2p_colour_list:
			dc.l	$00000000
			dc.l	$ff000000
			dc.l	$00ff0000
			dc.l	$ffff0000
			dc.l	$0000ff00
			dc.l	$ff00ff00
			dc.l	$00ffff00
			dc.l	$ffffff00
			dc.l	$000000ff
			dc.l	$ff0000ff
			dc.l	$00ff00ff
			dc.l	$ffff00ff
			dc.l	$0000ffff
			dc.l	$ff00ffff
			dc.l	$00ffffff
			dc.l	$ffffffff
 
sine1			dc.w	1,4
			dc.w		0,64
sine2			dc.w	2,4
			dc.w		0+(256/3),64+(256/3)
sine3			dc.w	3,4
			dc.w		0+(2*256/3),64+(2*256/3)


;--------------------------------------------------------------------

		section	text

;--------------------------------------------------------------------

script_calc_routine:
		move.l	(a6)+,d0
		move.l	(a6)+,d1
		move.l	(a6)+,d2

		pea	(a6)
		bsr	make_blobcode_routine
		move.l	(a7)+,a6
		rts

script_calc_blob:
		move.l	(a6)+,max_r
		move.l	(a6)+,d0
		move.l	(a6)+,d0

		pea	(a6)

		move.l	max_r,d0
		mulu.w	d0,d0
		move.l	d0,max_r_squared

		bsr	calc_blob_table

		move.l	(a7)+,a6
		rts

script_display_blob:
		move.l	(a6)+,blob_finish_time

		move.l	(a6)+,blob_fadeon_palette
		move.l	(a6)+,blob_fadeoff_palette

		move.l	(a6)+,blob_colour1
		move.l	(a6)+,blob_colour2
		move.l	(a6)+,blob_colour3

		lea	sine1,a0
		moveq	#12-1,d0
.loop:		move.l	(a6)+,d1
		move.w	d1,(a0)+
		dbf	d0,.loop

		pea	(a6)

		bsr	do_blob_script

		move.l	(a7)+,a6
		rts




do_blob_script:
		bsr	calc_c2p_table

		move.l	blob_fadeon_palette,a0
		moveq	#1,d0
		bsr	install_fade
		bsr	start_fade

		bsr	draw_blob_loop

		move.l	blob_fadeoff_palette,a0
		moveq.l	#1,d0
		bsr	install_fade
		bsr	start_fade
		add.l	#32,blob_finish_time

		bsr	draw_blob_loop
		rts

draw_blob_loop:
		bsr	update_blobs
		bsr	draw_blob_st
		bsr	swap_screens
		move.l	music_timer,d0
		cmp.l	blob_finish_time,d0
		blt.s	draw_blob_loop
		rts



;--------------------------------------------------------------------
calc_blob_table:
		lea	blob_table+(blob_table_x*2)*(blob_table_y/2)+blob_table_x/2*2,a0
		move.l	a0,a1

		move.w	#0,d7
		move.w	#0,d5
.loop1:
		move.l	a0,a2
		move.l	a0,a3
		move.l	a1,a4
		move.l	a1,a5
		move.w	#0,d6
.loop2:
		move.w	d6,d0
		move.w	d7,d1
		bsr	calc_blob_element
		move.w	d2,-(a2)
		move.w	d2,(a3)+
		move.w	d2,-(a4)
		move.w	d2,(a5)+
		addq.w	#1,d6
		cmp.w	#blob_table_x/2,d6
		bne.s	.loop2

		lea	blob_table_x*2(a0),a0
		lea	-blob_table_x*2(a1),a1

		addq.w	#1,d7
		cmp.w	#blob_table_y/2,d7
		bne.s	.loop1
		rts

;    !------------------------------------------------------------
;    ! x and y are the co-ordinate values given as input
;    LET distance_squared = x*x + y*y
;    IF distance_squared > max_r*max_r THEN
;      LET density = 0               !Outside max_r, density=0
;    ELSE
;      LET fraction_squared = 256*distance_squared/max_r/max_r)
;      LET density = (256-fraction_squared)^4
;                                    !calculate density function
;    ENDIF
;    !------------------------------------------------------------

calc_blob_element:
		movem.w	d3-d7,-(a7)
		muls.w	d0,d0
		muls.w	d1,d1
		add.l	d1,d0		;d0 = distance_squared
		cmp.l	max_r_squared,d0
		blt.s	.do_inside

		move.w	#0,d2
		bra.s	.done
.do_inside:
		asl.l	#7,d0		;128*
		divs.w	max_r_squared+2,d0
		ext.l	d0
		move.l	#128,d2
		sub.l	d0,d2
		muls	d2,d2
		muls	d2,d2
		swap	d2

; The result is a 12-bit number
; We convert it to 7 bits:
		asr.w	#5-2,d2

; Now multiply by 16
.done
		asl.w	#4,d2
		movem.w	(a7)+,d3-d7
		rts

draw_blob_st:
		move.l	blob1_pos,a0
		move.l	blob2_pos,a1
		move.l	blob3_pos,a2
		move.l	blob_colour_address,a3
		move.l	blob_colour_address,d3
		move.l	logic,a4
		move.w	#320,d2
		jsr	blob_routine
		rts

;--------------------------------------------------------------
update_blobs:
		lea	sine1,a0
		bsr	.update_sines
		bsr	.calc_pos
		move.l	a0,blob1_pos
		lea	sine2,a0
		bsr	.update_sines
		bsr	.calc_pos
		move.l	a0,blob2_pos
		lea	sine3,a0
		bsr	.update_sines
		bsr	.calc_pos
		move.l	a0,blob3_pos
		rts

.calc_pos:
		add.w	d0,d0
		add.w	d1,d1
		lea	sine_table,a5
		move.w	(a5,d0.w),d0
		move.w	(a5,d1.w),d1
		muls.w	#160,d0
		swap	d0
		add.w	#160/2,d0
		muls.w	#100,d1
		swap	d1
		add.w	#100/2,d1
		muls.w	#320*2,d1
		muls.w	#2,d0
		add.l	d0,d1
		lea	blob_table,a1
		lea	(a1,d1.l),a0
		rts

.update_sines:
		movem.w	(a0)+,d2/d3

		move.w	(a0),d0
		add.w	d2,d0
		and.w	#$ff,d0
		move.w	d0,(a0)+

		move.w	(a0),d1
		add.w	d3,d1
		and.w	#$ff,d1
		move.w	d1,(a0)+
		rts


;--------------------------------------------------------------------
calc_c2p_table:

; The c2p table is made up as follows

;   BLOCK * D0		; black blocks
;   BLOCK * D1 * 16	; intermediate blocks
;   BLOCK * D2		; white blocks

; total D0 + D2 + D1*16 = 390*4

		lea	blob_colour_table,a0
		move.l	a0,d0
		;and.l	#$ffff0000,d0
		;move.l	d0,a0
		move.l	d0,blob_colour_address

		;move.w	#64*4,d0
		;move.w	#4*4,d1
		;move.w	#(390*4-16*4*4-64*4),d2

		move.l	blob_colour1,d0
		move.l	blob_colour2,d1
		move.l	blob_colour3,d2
		bsr	create_c2p_table
		rts


; FORMAT OF C2P BUFFER

; Blocks of 16 bytes
;  for each entry   + 0  leftmost 2 pixels
;                   + 4
;                   + 8  
;                   + 12 rightmost 2 pixels



create_c2p_table:
		subq.w	#1,d0
.c2p_loop_black:
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		dbf	d0,.c2p_loop_black

; Now do the colour range:
		subq.w	#1,d1

		lea	c2p_colour_list,a1
		move.w	#16-1,d4		;overall counter
.c2p_loop_middle:
		move.w	d1,d3
.c2p_loop_entry:
		move.l	(a1),d5			;d2 current colour
		and.l	#$c0c0c0c0,d5		;only want leftmost bits
		move.l	d5,(a0)+
		ror.l	#2,d5
		move.l	d5,(a0)+
		ror.l	#2,d5
		move.l	d5,(a0)+
		ror.l	#2,d5
		move.l	d5,(a0)+
		dbf	d3,.c2p_loop_entry
		addq.l	#4,a1
		dbf	d4,.c2p_loop_middle

		subq.w	#1,d2
		subq.l	#4,a1
.c2p_loop_white:
		move.l	(a1),d5
		and.l	#$c0c0c0c0,d5
		move.l	d5,(a0)+
		lsr.l	#2,d5
		move.l	d5,(a0)+
		lsr.l	#2,d5
		move.l	d5,(a0)+
		lsr.l	#2,d5
		move.l	d5,(a0)+
		dbf	d2,.c2p_loop_white
		rts


;--------------------------------------------------------------------
; d0/d1/d2 flags for add/sub etc
;

make_blobcode_routine:

; First overwrite the routine to give the right bits:

		lea	blobcode1_start(pc),a0
		lea	blobcode1_middle(pc),a1

		move.w	blob1_yes(pc),d7
		tst.w	d0
		beq.s	.yes
		move.w	blob1_no(pc),d7
.yes:		move.w	d7,(a0)+
		move.w	d7,(a1)+


		move.w	blob2_yes(pc),d7
		tst.w	d1
		beq.s	.yes2
		move.w	blob2_no(pc),d7
.yes2:		move.w	d7,(a0)+
		move.w	d7,(a1)+

		move.w	blob3_yes(pc),d7
		tst.w	d2
		beq.s	.yes3
		move.w	blob3_no(pc),d7
.yes3:		move.w	d7,(a0)+
		move.w	d7,(a1)+





		lea	blob_routine,a0
		move.w	#100-1,d7		;d7 linecount
		moveq.l	#0,d6			;d6 screen offset
		move.l	#$00070001,d5		;d5 0/1 byte swap
.make_line:
		moveq	#40-1,d4		;d4 chunk count
.make_chunk:
		move.l	a0,a2
		bsr	copy_blobcode1_block
		move.w	d6,d3
		move.w	d3,blobcode1_off1(a2)
		add.w	#160,d3
		move.w	d3,blobcode1_off2(a2)
		add.w	d5,d6
		swap	d5
		dbf	d4,.make_chunk
		bsr	copy_blobcode2_block
		add.w	#160,d6
		dbf	d7,.make_line
		move.w	#$4e75,(a0)+		; "rts"
		rts

copy_blobcode1_block:
		lea	blobcode1_start(pc),a1
		move.w	#blobcode1_size/2-1,d0
.copy		move.w	(a1)+,(a0)+
		dbf	d0,.copy
		rts

copy_blobcode2_block:
		lea	blobcode2_start(pc),a1
		move.w	#blobcode2_size/2-1,d0
.copy		move.w	(a1)+,(a0)+
		dbf	d0,.copy
		rts

;--------------------------------------------------------------------
blob1_yes	move.l	(a0)+,d0		;all multiples of 16
blob1_no	move.l	(a0)+,d0		;all multiples of 16
blob2_yes	sub.l	(a1)+,d0		;all multiples of 16
blob2_no	add.l	(a1)+,d0		;all multiples of 16
blob3_yes	sub.l	(a2)+,d0		;all multiples of 16
blob3_no	add.l	(a2)+,d0		;all multiples of 16


blobcode1_start:
		move.l	(a0)+,d0		;all multiples of 16
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		move.l	4(a3,d0.w),d1
		swap	d0
		or.l	(a3,d0.w),d1
blobcode1_middle:
		move.l	(a0)+,d0
		add.l	(a1)+,d0
		add.l	(a2)+,d0
		or.l	12(a3,d0.w),d1
		swap	d0
		or.l	8(a3,d0.w),d1
blobcode1_1:	equ *+2
		movep.l	d1,0002(a4)
blobcode1_2:	equ *+2
		movep.l	d1,0004(a4)
blobcode1_end:

blobcode1_size	equ	blobcode1_end-blobcode1_start
blobcode1_off1	equ	blobcode1_1-blobcode1_start
blobcode1_off2	equ	blobcode1_2-blobcode1_start


;--------------------------------------------------------------------
blobcode2_start:
		add.w	d2,a0
		add.w	d2,a1
		add.w	d2,a2
blobcode2_end:
blobcode2_size	equ	blobcode2_end-blobcode2_start

;--------------------------------------------------------------------

			section	bss
blob_table:		ds.w	blob_table_x*blob_table_y
blob_routine:		ds.b	((blobcode1_size*2*20)+(blobcode2_size))*100+4
blob_colour_base:
blob_colour_table:	ds.l	4*390*4


