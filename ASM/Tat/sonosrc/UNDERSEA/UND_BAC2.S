;[	]
;[	]SeaScape background module
;[	]
;[	]Done by simply picking left and right edge background colours
;[	]and interpolating between them.
;[	]
;[	]Could use the moving lines method outlined earlier?
;[	]

;---------------------------------------------------------------
max_rays_colours	equ	56
max_rays_width		equ	192

max_bubbles		equ	100
;---------------------------------------------------------------


; Data requirements

; EDGE COLOUR DETERMINATION
;
; FOR each side:
; - No_rays_Colours
; - Edge colour buffer (0-100)

;   FOR each rays_colour:
;   - colour index
;   - direction of colour change (if any)
;   - position index
;   - direction of position movement (if any)
;   - duration before "death" (-1 if everlasting)


; BUBBLE DETERMINATION
; FOR each BUBBLE:
;   - x position
;   - y position
;   - y speed (upwards)
;   - x oscillation speed
;   - x oscillation magnitude
;   - duration before "death"

;---------------------------------------------------------------
			rsreset
routine_address		rs.l	1
routine_data		rs.b	1

routine_data_define	macro
			rsset	routine_data
			endm

;---------------------------------------------------------------
			routine_data_define
rays_colour_index	rs.w	1
rays_colour_dir		rs.w	1
rays_position		rs.w	1
rays_position_dir	rs.w	1
rays_duration		rs.w	1

rays_data_size		rs.b	1

;---------------------------------------------------------------
			routine_data_define
; FOR each BUBBLE:
;   - x position
;   - y position
;   - y speed (upwards)
;   - x oscillation speed
;   - x oscillation magnitude
;   - duration before "death"
bubble_x		rs.w	1
bubble_y		rs.w	1
bubble_y_speed		rs.w	1
bubble_x_speed		rs.w	1
bubble_x_mag		rs.w	1
bubble_duration		rs.w	1
bubble_data_size	rs.b	1


;---------------------------------------------------------------
			section	bss
;---------------------------------------------------------------
no_of_rays_colours	ds.w	1
number_of_scanlines	ds.w	1

rays_data		ds.w	rays_data_size*max_rays_colours
bubble_data		ds.w	bubble_data_size*max_bubbles

rays_colour_buffer_1	ds.w	max_rays_width
rays_colour_buffer_2	ds.w	max_rays_width
			even

;---------------------------------------------------------------
			section	data
;---------------------------------------------------------------
rays_colour_table:
; Position 0
o			set	$0004

			dcb.w	64,o
rays_off = (*-rays_colour_table)/2
			dcb.w	64,o
rays_norm = (*-rays_colour_table)/2+2*14
			rept	27
			 dc.w	o,o
o			 set	o+$0001
			endr
			dcb.w	32,o
			rept	32
			 dc.w	o,o+$20
o			 set	o+$0840
			endr
			dcb.w	32,-1
rays_top = (*-rays_colour_table)/2+6
			dcb.w	64,-1

movement_table:
			dc.w	-2,-3,-2,-1
			dc.w	+1,+2,+3,+2

colourindex_table:
			dc.w	-8,-7,-6,-5,-4,-3,-2,-1
			dc.w	+1,+2,+3,+4,+5,+6,+7,+8

;---------------------------------------------------------------
			section	text
;---------------------------------------------------------------
;						get_random
get_random:	movem.w	random_seed,d0/d1/d2
		add.w	d1,d0
		add.w	#1,d0
		mulu.w	#259,d0
		mulu.w	#59,d1
		add.w	#17,d1
		mulu.w	#9,d2
		add.w	#7,d2
		movem.w	d0/d1/d2,random_seed
		rts

random_seed:	dc.w	0,0,0


;---------------------------------------------------------------


init_rays:
		lea	rays_data,a0
		move.w	#max_rays_colours-1,d0
.do_routine:	move.l	(a0),a1
		move.w	d0,-(a7)
		jsr	init_one_colour
		lea	rays_data_size(a0),a0
		move.w	(a7)+,d0
		dbf	d0,.do_routine
		rts


;						execute_rays:
execute_rays:	lea	rays_data,a0
		move.w	#max_rays_colours-1,d0
.do_routine:	move.l	(a0),a1
		move.w	d0,-(a7)
		jsr	routine_one_colour
		lea	rays_data_size(a0),a0
		move.w	(a7)+,d0
		dbf	d0,.do_routine
		rts


do_rays:
		move.w	d0,-(a7)
		lea	rays_colour_buffer_1,a0
		move.w	#(max_rays_width/4)-1,d0
		moveq	#0,d1
.empty:		move.l	d1,(a0)+
		move.l	d1,(a0)+
		dbf	d0,.empty

		bsr	execute_rays

		lea	rays_colour_buffer_1,a0
		lea	rays_colour_buffer_2,a2
		move.w	#(max_rays_width)-1-1,d0
		move.w	(a7)+,d1
		move.w	d1,(a0)+
		lea	rays_colour_Table,a3
		move.w	(a3,d1.w*2),(a2)+

.fill:		add.w	(a0),d1
		move.w	d1,(a0)+
		move.w	d1,d2
;		bpl.s	.ok1
;		moveq	#0,d2
;.ok1:		cmp.w	#127,d2
;		blt.s	.ok2
;		move.w	#127,d2
;.ok2:
		move.w	(a3,d2.w*2),(a2)+
		dbf	d0,.fill
		rts

;---------------------------------------------------------------
display_rays:
		move.l	logic,a0
		lea	4*(max_rays_width/2)(a0),a0

		move.w	#lines-1,d0
		lea	rays_colour_buffer_2+2*(max_rays_width/2),a1
		move.l	#192,d4

.lineloop:
		move.l	#192*$10000,d2
		divu.l	d4,d2
		swap	d2

		move.l	a0,a2
		move.l	a0,a3
		move.w	#96-1,d1
		moveq	#0,d3
		moveq	#0,d5
		move.w	(a1),d6
		move.w	d6,d7
		swap	d6

		move	#0,ccr
.pixloop:
		move.w	(a1,d5.w*2),d6
		swap	d6			;-ve
		move.l	d6,-(a3)
		swap	d7
		move.w	(a1,d3.w*2),d7
		move.l	d7,(a2)+		;+ve
		addx.l	d2,d3
		subx.l	d2,d5
		dbf	d1,.pixloop

		lea	BytesPerLine(a0),a0
		addq.l	#1,d4
		dbf	d0,.lineloop
		rts

;---------------------------------------------------------------
;						routine_one_colour:
routine_one_colour:
		subq.w	#1,rays_duration(a0)
		bpl	.no_new_colour

		bsr	get_new_colour

.no_new_colour:
		movem.w	rays_position(a0),d0/d1
		add.w	d1,d0
		cmp.w	#0+10,d0
		bgt.s	.notleft
		neg.w	d1
		add.w	d1,d0
.notleft:
		cmp.w	#max_rays_width-10,d0
		blt.s	.notright
		neg.w	d1
		add.w	d1,d0
.notright:
		movem.w	d0/d1,rays_position(a0)

		lea	rays_colour_buffer_1,a1
		move.w	rays_colour_index(a0),d0
		move.w	rays_position(a0),d1
		add.w	d0,(a1,d1.w*2)
		rts

get_new_colour:
		bsr	get_random
		and.w	#%111,d0
		add.w	#3,d0
		move.w	d0,rays_duration(a0)

		bsr	get_random
		and.w	#%111,d0
		move.w	(movement_table.l,d0.w*2),d0
		move.w	d0,rays_position_dir(a0)
		rts

init_one_colour:
		bsr	get_random
		and.w	#%1111,d0
		move.w	(colourindex_table.l,d0.w*2),d0
		move.w	d0,rays_colour_index(a0)

		move.w	#max_rays_width/2,rays_position(a0)

		bsr	get_new_colour

		rts


















;---------------------------------------------------------------








;			bubbles








;---------------------------------------------------------------
init_bubbles:
		lea	bubble_data,a0
		move.w	#max_bubbles-1,d0
.do_routine:	move.l	(a0),a1
		move.w	d0,-(a7)
		jsr	init_one_bubble
		lea	bubble_data_size(a0),a0
		move.w	(a7)+,d0
		dbf	d0,.do_routine
		rts


;---------------------------------------------------------------
;						execute_bubbles:
execute_bubbles:
		lea	bubble_data,a0
		move.w	#max_bubbles-1,d0
.do_routine:	move.l	(a0),a1
		move.w	d0,-(a7)
		jsr	routine_one_bubble
		lea	bubble_data_size(a0),a0
		move.w	(a7)+,d0
		dbf	d0,.do_routine
		rts


do_bubbles:
		move.l	d0,d7
		move.l	scanline_pointer,d0
		sub.l	#scanlines,d0
		asr.l	#2,d0
		move.w	d0,number_of_scanlines
		bsr	execute_bubbles
		rts

;---------------------------------------------------------------
;						routine_one_colour:
routine_one_bubble:
		subq.w	#1,bubble_duration(a0)
		bpl	.no_new_bubble

		tst.w	number_of_scanlines
		beq.s	.no_new_bubble

		bsr	get_new_bubble

; Set proper x and y coords here:
		bsr	get_random
		and.l	#$ffff,d0
		divu.w	number_of_scanlines,d0
		swap	d0
		move.l	(scanlines.l,d0.w*4),d0

; Calculate the x and y coords:
		sub.l	logic,d0
		divu	#BytesPerLine,d0
		move.w	d0,bubble_y(a0)		;lines down
		swap	d0
		asr.w	d0			;halve (2bytes/pixel)
		move.w	d0,bubble_x(a0)		;remainder = x pos
		bsr	get_random

.no_new_bubble:
		movem.w	bubble_x(a0),d0/d1
		add.w	bubble_y_speed(a0),d1
		movem.w	d0/d1,bubble_x(a0)

		tst.w	d1
		ble	.dontdraw

		muls.w	#BytesPerLine,d1
		add.l	logic,d1
		move.l	d1,a1
		add.l	d7,(a1,d0.w*2)
.dontdraw
		rts


get_new_bubble:
		bsr	get_random
		and.w	#%111,d0
		add.w	#5,d0
		move.w	d0,bubble_duration(a0)

		bsr	get_random
		and.w	#%11,d0
		addq.w	#1,d0
		neg.w	d0
		move.w	d0,bubble_y_speed(a0)

		bsr	get_random
		and.w	#%111111,d0
		move.w	d0,bubble_x_speed(a0)

		bsr	get_random
		and.w	#%111111,d0
		move.w	d0,bubble_x_mag(a0)
		rts

init_one_bubble:
		bsr	get_new_bubble
		move.w	#-1,bubble_x(a0)
		move.w	#Lines-1,bubble_y(a0)
		rts



;---------------------------------------------------------------
			section	text
;---------------------------------------------------------------
