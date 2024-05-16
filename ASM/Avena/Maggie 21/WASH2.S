







						avena_5_9_96:










;---------------------------------------------------------------
;
; "Washing Machine" effect, 5th September 1996 onwards
;
; Effect very similar to the tunnel effect. Here we make the
;    effect out of several (concentric?) rings.
;
;---------------------------------------------------------------
;
;	initial coding ideas
;
;---------------------------------------------------------------
;
; Water-type effects can be easily be added by altering the ring
;    list! (Now done)

; The effect routine will look like this:
;

;    rept 4
;	add.w	(a0)+,a1	16	;d0 mult of 4, relative!
;	move.w	(a0)+,d1	8	;d1 mult of 2?

; FOLLOWING LINE SCAN BE SELF-WRITTEN AS X(A1) TO REMOVE ABOVE
;   ADD.W STATEMENT FOR 68000
;	MOVE.L	X1(A1),A2
;	move.l	(a1),a2		12	;ring list
; ALSO THIS LINE CAN BE SELF WRITTEN??
;	move.b	(a2,d1.w),d2    20	....[or d3,d4,d5]
;	MOVE.W	X2(A2),D2
;					;Colour stored as mult of 2
;
;	move.l 	d2,a3		4	;c2p lookup on 256byte boundary
;	or.w	(a3),d6		12
;    endr
;	movep.w	d6,x(...)	24
;	movep.w	d6,160+x(...)	24
;
;				
;
; This routine is however horrendously slow on an ST...
;  ... approx 4.2 frames for 160x100
;  ....       2.6   "     "  100x100	similar to Platsch?
;
; Perhaps a 4 plane version would be a good idea too?
;
; Routine could well be improved by converting whole set of
;    lists 4 times rather than using a c2p lookup table?
;    This would involve huge amounts of memory though
;    and means you can't scroll patterns through the picture
;
; Further cunning optimisation:
;    Since the ring_number value in the table is rotationally
;    symmetrical, it needs only be fetched once. Also, the
;    ring_angle will automatically be (max_ring_angle/2)
;    greater at the opposite point...
;    Also note: this optimisation *will* also be possible
;    on the ST, as long as the self-writing routine is
;    amended to take this into account. It could well mean
;    1meg-only status, though

; Storing 4 copies of the picture will again save processor time

;    Another Cunning Trick: if max_ring_angle is exactly 256,
;      automatic looping could be done by placing each piece of ring data
;      on a 256-byte boundary... this doesn't help with self-written
;      routines though
;
;---------------------------------------------------------------
;
;	initial "design" ideas
;
;---------------------------------------------------------------
;	1. do a kind of bad tunnel effect with no distortion
;	2. do a platsch-effect on the bunny
;	3. do a face bender....
;	4. ....that dies out to show uncle sam
;	5. do ripples and bending on the bunny	
;	6. do several mad ripple+bends on patterns in different
;		colours. pulses to the music?
;
; for each effect we need:
;  - the graphics info (picture or pattern?)
;	LONG - gfx type (0 = picture, 1 = pattern)
;       LONG - pointer to gfx
;  - the bending data
;	LONG - multiply amount
;	LONG - swirl speed
;	LONG - swirl offset???
;  - the ripple data
;	LONG - multiply amount
;	LONG - speed through buffer (not offset - stored in circular buffer)
;	LONG - ripple speed
	
			section	text



max_ring_number		equ	60
max_ring_angle		equ	256
; This means ring_buffer size of 60 * 256 * 2 bytes = 30 Kbytes

ring_dummy_value	equ	-1

wash_x			equ	100
wash_y			equ	100
overflow_size		equ	40

falcon			equ	1

standalone		equ	0		;falcon debugging
testing_falcon		equ	0
testing_screen		equ	0
testing_selfwrite	equ	1

		opt	p=68000

	ifeq standalone				;called from INTRO.S

script_wash_start:
		move.l	(a6)+,wash_gfx_type	;gfx type
		move.l	(a6)+,wash_gfx_pointer	;
		pea	(a6)

		clr.l	pattern_ring_offset
		bsr	Init_Wash

		move.l	(a7)+,a6
		rts


script_wash_do:
		move.l	(a6)+,wash_palette	;colour data

		move.l	(a6)+,d0
		move.w	d0,wash_sine_position

		move.l	(a6)+,wash_swirl_amount
		move.l	(a6)+,wash_swirl_speed
		move.l	(a6)+,wash_swirl_offset

		move.l	(a6)+,wash_ripple_amount ;
		move.l	(a6)+,wash_ripple_speed  ;
		move.l	(a6)+,wash_ripple_offset ;

		move.l	(a6)+,tunnel_music_end		;

		pea	(a6)

		bsr	do_wash_script

		move.l	(a7)+,a6
		rts

	else					;standalone version
		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7

	    ifne testing_screen
		move.l	$44e.w,old_44e

		move.l	#test+256,d0
		sub.b	d0,d0
		move.l	d0,logic
	ifeq	falcon
		add.l	#32000,d0
	else
		add.l	#320*100*2,d0
	endc
		move.l	d0,physic

		ifne testing_falcon
		move.w	#$24,-(a7)		;"true"colour
		move.w	#3,-(a7)
		else
		move.w	#0,-(a7)		;4 bitplane ST mode
		endc
		move.l	d0,-(a7)
		move.l	d0,-(a7)
		move.w	#5,-(a7)
		trap	#14
		ifne testing_falcon
		lea.l	14(a7),a7
		else
		lea	12(a7),a7
		endc

		;moveq	#$0009,d0
		;movec	d0,cacr
		;moveq	#0,d0
		;movec	d0,caar

		ifne testing_falcon
		ori.w	#1,$ffff82c2.w
		endc
	    endc

		move.l	$70.w,-(a7)
		move.l	#sod,$70.w

		movem.l	st_palette,d0-d7
		movem.l	d0-d7,$ffff8240.w
		
	    ifne testing_screen
		bsr	Init_Wash
wait:
		bsr	Do_Wash
		bsr	screen_swap
		cmp.b	#$39,$fffffc02.w
		bne	wait

		move.l	(a7)+,$70.w

		move.w	#2,-(a7)
		move.l	old_44e,-(a7)
		move.l	old_44e,-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea.l	12(a7),a7
		illegal
	    endc

screen_swap:
		move.l	logic,d0
		move.l	physic,logic
		move.l	d0,physic
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		rts
	endc


;---------------------------------------------------------------
	ifeq	standalone

do_wash_script:
		bsr	clear_screens

		move.l	wash_palette,a0
		moveq	#1,d0
		bsr	install_fade
		bsr	start_fade

.loop:
		bsr	Do_Wash
		bsr	swap_screens
		move.l	music_timer,d0
		cmp.l	tunnel_music_end,d0		;find what's needed
		blt.s	.loop				;not there yet

		lea	black_palette,a0
		moveq	#1,d0
		bsr	install_fade
		bsr	start_fade
.loop2:
		bsr	Do_Wash
		bsr	swap_screens
		tst.w	fade_done_flag
		beq.s	.loop2

		rts
	endc


;---------------------------------------------------------------
		section	text
;---------------------------------------------------------------
Init_Wash:
	ifeq	standalone
		bsr	convert_gfx
	endc

		bsr	build_rings

		bsr	use_wash_table
		bsr	init_ring_table_list

		bsr	create_c2p_table		;not on Falcon version
		rts




;---------------------------------------------------------------
	ifeq standalone
convert_gfx:
		move.l	wash_gfx_pointer,a0
		lea	160(a0),a1
		lea	wash_gfx,a2
		move.w	#wash_y-1,d0
.loop1		move.w	#wash_x-1,d1
.loop2:		move.b	(a0)+,d2
		move.b	(a1)+,d3
		move.b	d2,d4
		and.w	#$f,d4
		move.b	d2,d5
		and.w	#$f,d5
		add.w	d4,d5
		lsr.b	#4,d2
		lsr.b	#4,d3
		and.w	#$f,d2
		and.w	#$f,d3
		add.w	d2,d5
		add.w	d3,d5
		asr.w	#2,d5
		move.b	d5,(a2)+
		dbf	d1,.loop2

		lea	320-(wash_x)(a0),a0
		lea	320-(wash_x)(a1),a1
		dbf	d0,.loop1
		rts
	endc


;---------------------------------------------------------------
;	build_rings(void)
;
; First we build up several ring_tables of size (ring_length)
;    by analysing the picture and the ring shape - similar to
;    the tunnel table.
;
;---------------------------------------------------------------
build_rings:
		tst.l	wash_gfx_type
		bne	build_pattern_rings

; Initially we fill the ring_tables with a dummy value:
		bsr	fill_buffer
	

; Finally each ring_table must be *doubled* to allow wrap-around
;   get each value of wash_table (ring number,angle) and insert
;   the pic data at ring_buffer[ring_number,ring_angle]:
		bsr	insert_in_rings

; Afterwards, any values of 'dummy' will be written over by the
;   last non-dummy value to be found. Loop round twice (forwards)
;   to be sure?

; Finally each ring_buffer must be *doubled* to allow wrap-around
;   of rotation:
		bsr	remove_dummies
		rts


fill_buffer:
		lea	ring_buffer,a0
		move.w	#(max_ring_number*max_ring_angle*2)-1,d0
.filldummy:	move.b	#ring_dummy_value,(a0)+
		dbf	d0,.filldummy
		rts

insert_in_rings:
		lea	wash_table,a0		;source offsets
		lea	wash_gfx,a2		;source picture
		lea	ring_buffer,a1		;destination

		move.w	#(wash_x*wash_y)-1,d0
.convert:	moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d1		;ring_number 0-95
		move.b	(a0)+,d2		;ring_angle 0-255
		mulu.w	#max_ring_angle*2,d1
		add.l	d2,d1
		move.b	(a2)+,d3
	ifeq testing_falcon				;ie. bitplane modes...
		lsl.b	#2,d3
	endc
		move.b	d3,(a1,d1.l)
		dbf	d0,.convert
		rts

remove_dummies:
		lea	ring_buffer,a0
		move.w	#max_ring_number-1,d0
.fill_1:
		move.b	#-1,d2			;set first data
		move.l	a0,a1			;save positions
		move.w	#max_ring_angle-1,d1
		bsr	fill_loop
		move.l	a0,a1			;save positions
		move.w	#max_ring_angle-1,d1	;do it again
		bsr	fill_loop
; Now double the buffer:
		bsr	double_loop
		lea	max_ring_angle*2(a0),a0
		dbf	d0,.fill_1
		rts

fill_loop:
		move.b	(a1)+,d3
		cmp.b	#ring_dummy_value,d3
		bne.s	.get_new			;position filled?

		cmp.b	#-1,d2				;none yet found?
		beq.s	.ignore
		move.b	d2,-1(a1)
.ignore:	dbf	d1,fill_loop
		rts
.get_new:
		move.b	d3,d2				;data is new d2
		dbf	d1,fill_loop
		rts

double_loop:
		lea	max_ring_angle(a0),a1
		move.l	a0,a2
		move.w	#max_ring_angle-1,d1
.copy		move.b	(a2)+,(a1)+
		dbf	d1,.copy
		rts


;---------------------------------------------------------------
build_pattern_rings:
		clr.l	pattern_ring_offset

		moveq	#max_ring_number-1,d0
.buildloop:
		move.l	d0,-(a7)
		bsr	build_pattern_ring
		move.l	(a7)+,d0
		dbf	d0,.buildloop
		rts



build_pattern_ring:
		bsr	update_pattern_offset

		move.l	pattern_ring_offset,d0
		mulu.w	#max_ring_angle*2,d0
		add.l	#ring_buffer,d0

		move.l	d0,a0
		lea	max_ring_angle(a0),a1

		lea	wash_data_1,a2			;gfx 1
		lea	wash_data_1,a3			;gfx 1
		move.w	pattern_1_offset,d0
		mulu.w	#256,d0
		move.w	pattern_2_offset,d1
		mulu.w	#256,d1
		add.l	d0,a2
		add.l	d1,a3

		move.l	#$3c3c3c3c,d1
		rept	max_ring_angle/4		;longs
		 move.l	(a2)+,d0
		 add.l	(a3)+,d0
		 lsr.l	d0
		 and.l	d1,d0		 
		 move.l	d0,(a0)+
		 move.l	d0,(a1)+
		endr

		move.l	pattern_ring_offset,d0
		subq.l	#1,d0
		bpl.s	.ok
		add.l	#max_ring_number,d0
.ok		move.l	d0,pattern_ring_offset

		rts

update_pattern_offset:
		add.l	#$018000,pattern_1_offset
		and.l	#$3fffff,pattern_1_offset
		add.l	#-$02c000,pattern_2_offset
		and.l	#$3fffff,pattern_2_offset
		rts



;---------------------------------------------------------------
;	use_wash_table
;
; converts from original format of 2 bytes to two words,
; - first word relative from last (initially rel from 0)
;       and a multiple of 4
; - second word multiple of 1 (pixels here stored as bytes!)
;
; - selftwriting version doesn't use relative values...
;
;---------------------------------------------------------------
use_wash_table:

	ifeq	testing_selfwrite
; Relative version:
		lea	wash_table,a0
		lea	wash_table_2,a1
		move.w	#(wash_x*wash_y)-1,d0
		moveq	#0,d3			;last ring_number*4
.cw:
		moveq	#0,d1
		moveq	#0,d2
		move.b	(a0)+,d1		;ring_number
		move.b	(a0)+,d2		;ring_angle
		asl.l	#2,d1
		sub.l	d1,d3			;last-new
		neg.l	d3			;new-last
		move.w	d3,(a1)+		;new ring_number_relative
		move.w	d2,(a1)+		;new ring_angle
		move.l	d1,d3			;new --> old

		dbf	d0,.cw

	else
; Self-writing version:
		lea	wash_table,a0
		lea	wash_instruction_buffer,a1
		moveq	#0,d2			;screen offset
		move.w	#(wash_y)-1,d0		;counter 1
.sw_loop_1:
		move.w	#(wash_x/8)-1,d1	;ie 12 = 96 pixels
.sw_loop_2:
		bsr	makechunk
		addq.w	#1,d2
		bsr	makechunk
		addq.w	#7,d2
		dbf	d1,.sw_loop_2
		bsr	makechunk		;do last 4 pixels
		add.w	#320-((wash_x/8)*8),d2
		dbf	d0,.sw_loop_1

		move.w	#$4e75,(a1)+			;'rts'
		rts

makechunk:
		lea	wash_loop_start,a2
		move.l	a1,a3				;save current dest
		move.w	#(wash_loop_length)-1,d3
.makecopy:	move.b	(a2)+,(a3)+
		dbf	d3,.makecopy

		bsr	.get_wash_table_data
		move.w	d3,wash_off1-wash_loop_start(a1)
		move.w	d4,wash_off2-wash_loop_start(a1)
		bsr	.get_wash_table_data
		move.w	d3,wash_off3-wash_loop_start(a1)
		move.w	d4,wash_off4-wash_loop_start(a1)
		bsr	.get_wash_table_data
		move.w	d3,wash_off5-wash_loop_start(a1)
		move.w	d4,wash_off6-wash_loop_start(a1)
		bsr	.get_wash_table_data
		move.w	d3,wash_off7-wash_loop_start(a1)
		move.w	d4,wash_off8-wash_loop_start(a1)
		move.w	d2,wash_off9-wash_loop_start(a1)  ;screenoffset
		lea	wash_loop_length(a1),a1
		rts


.get_wash_table_data:
		moveq	#0,d3
		moveq	#0,d4
		move.b	(a0)+,d3		;ring_number
		move.b	(a0)+,d4		;ring_angle
		asl.w	#2,d3
	endc
		rts


;---------------------------------------------------------------
create_c2p_table:
		move.l	#c2p_buffer+256,d0
		sub.b	d0,d0			;256 byte boundary
		move.l	d0,c2p_buffer_address

; Now we need 4 sets of the same data, each shifted by 2 bits
		move.l	d0,a0			;a0 dest1
		lea	256(a0),a1		;a1 dest2
		lea	256(a1),a2		;a2 dest3
		lea	256(a2),a3		;a3 dest4
		lea	c2p_colour_list,a4	;a4 source
		moveq	#16-1,d0
.c2p_loop:
		move.l	(a4)+,d1
		and.l	#$c0c0c0c0,d1
		move.l	d1,(a0)+
		lsr.l	#2,d1
		move.l	d1,(a1)+
		lsr.l	#2,d1
		move.l	d1,(a2)+
		lsr.l	#2,d1
		move.l	d1,(a3)+
		dbf	d0,.c2p_loop
		rts


;---------------------------------------------------------------
init_ring_table_list:
		lea	ring_table_list,a0
		lea	ring_buffer,a1
		move.w	#max_ring_number-1,d0
.fill:		move.l	a1,(a0)+		;save address
		add.l	#max_ring_angle*2,a1
		dbf	d0,.fill
		rts



;---------------------------------------------------------------





















;---------------------------------------------------------------
;
;



Do_Wash:
		bsr	update_table_list
		bsr	show_wash
		bsr	double_wash

		tst.l	wash_gfx_type
		beq.s	.no_patt
		bsr	build_pattern_ring
.no_patt
		rts


update_table_list:
		movem.w	wash_sine_position,d0/d1
		add.l	wash_swirl_speed,d0
		and.w	#(256*2)-2,d0
		add.l	wash_ripple_speed,d1
		and.w	#(256*2)-2,d1
		movem.w	d0/d1,wash_sine_position

		lea	ring_buffer,a0
		lea	ring_table_list,a1
		lea	sine_table,a2
		lea	ring_fix_list,a3

		moveq	#0,d4			;ring number

		move.l	wash_swirl_amount,d5
		move.l	wash_ripple_amount,d6
		move.l	wash_swirl_offset,a4
		move.l	wash_ripple_offset,a5

		move.w	#(max_ring_number)-1,d7

.update_loop:
						;rotation
		move.w	(a2,d0.w),d2		;sine value
		muls.w	d5,d2
		swap	d2
		and.w	#255,d2
		ext.l	d2
						;ripple effect
		move.w	(a2,d1.w),d3		;sine value
		muls.w	d6,d3
		swap	d3

		add.w	d4,d3
		add.w	d3,d3
		move.w	(a3,d3.w),d3		;lookup in table 0 to (max-1)

		add.w	pattern_ring_offset+2,d3
		cmp.w	#max_ring_number,d3
		blt.s	.ok2
		sub.w	#max_ring_number,d3
.ok2:
		muls.w	#max_ring_angle*2,d3
		add.l	d3,d2
		add.l	a0,d2

		move.l	d2,(a1)+

		addq.w	#1,d4			;normal offset

		add.w	a4,d0
		and.w	#(256*2)-2,d0
		add.w	a5,d1
		and.w	#(256*2)-2,d1
		dbf	d7,.update_loop
		rts

show_wash:
;---------------------------------------------------------------
	ifne testing_falcon
		move.l	logic,a3		;screen address!
		moveq	#0,d2
		lea	wash_table_2,a0
		lea	ring_table_list,a1
		lea	testing_colour_table,a4

		move.w	#(wash_y)-1,d7
.test_loop_1:
		move.w	#(wash_x)-1,d6
.test_loop_2:
		 add.w	(a0)+,a1	16	;d0 mult of 4, relative!
		 move.w	(a0)+,d1	8	;d1 mult of 2?
		 move.l	(a1),a2		12	;ring list
		 move.b	(a2,d1.w),d2	20	....[or d3,d4,d5]
		 move.l	(a4,d2.l*4),(a3)+
		dbf	d6,.test_loop_2

		lea	(640-(wash_x*4))(a3),a3
		dbf	d7,.test_loop_1
		rts
	else

;---------------------------------------------------------------
; ST bitplane versions:
;	First the one using tables (a fair bit slower)
;
	   ifeq testing_selfwrite

		move.l	logic,a3		;screen address!
		moveq	#0,d2
		lea	wash_table_2,a0
		lea	ring_table_list,a1

		move.l	c2p_buffer_address,d2
		move.l	d2,d3
		add.l	#$100,d3
		move.l	d3,d4
		add.l	#$100,d4
		move.l	d4,d5
		add.l	#$100,d5

		move.w	#(wash_y)-1,d7

.test_loop_1:
washchunk	macro
		 add.w	(a0)+,a1	16	;d0 mult of 4, relative!
		 move.w	(a0)+,d1	8	;d1 mult of 2?
		 move.l	(a1),a2		12	;ring list
		 move.b	(a2,d1.w),d2	20	....[or d3,d4,d5]
		 move.l	d2,a4
		 move.l	(a4),d0

		 add.w	(a0)+,a1	16	;d0 mult of 4, relative!
		 move.w	(a0)+,d1	8	;d1 mult of 2?
		 move.l	(a1),a2		12	;ring list
		 move.b	(a2,d1.w),d3	20	....[or d3,d4,d5]
		 move.l	d3,a4
		 or.l	(a4),d0

		 add.w	(a0)+,a1	16	;d0 mult of 4, relative!
		 move.w	(a0)+,d1	8	;d1 mult of 2?
		 move.l	(a1),a2		12	;ring list
		 move.b	(a2,d1.w),d4	20	....[or d3,d4,d5]
		 move.l	d4,a4
		 or.l	(a4),d0

		 add.w	(a0)+,a1	16	;d0 mult of 4, relative!
		 move.w	(a0)+,d1	8	;d1 mult of 2?
		 move.l	(a1),a2		12	;ring list
		 move.b	(a2,d1.w),d5	20	....[or d3,d4,d5]
		 move.l	d5,a4
		 or.l	(a4),d0
	endm

o		set	0
		rept	wash_x/8
		washchunk
		movep.l	d0,o(a3)
		washchunk
		movep.l	d0,o+1(a3)
o		set	o+8
		endr

		washchunk		; do the last 4 bits
		movep.l	d0,o(a3)

		lea	320(a3),a3

		dbf	d7,.test_loop_1
		rts
	    else
; Self-written version:
		move.l	logic,a3		;screen address!
		lea	(160-12*8)/2(a3),a3
		moveq	#0,d2
		lea	ring_table_list,a1
		move.l	c2p_buffer_address,d2
		move.l	d2,d3
		add.l	#$100,d3
		move.l	d3,d4
		add.l	#$100,d4
		move.l	d4,d5
		add.l	#$100,d5
		jsr	wash_instruction_buffer
		rts
	    endc
	endc

;---------------------------------------------------------------

double_wash:
	ifeq testing_falcon
		move.l	logic,a6		;screen address!
		lea	(160-12*8)/2(a6),a6
		rept	wash_y
		movem.l	(a6)+,d0-a5
		movem.l	d0-a5,160-(14*4)(a6)
		movem.l	(a6)+,d0-a3
		movem.l	d0-a3,160-(12*4)(a6)
		lea	320-4*(14+12)(a6),a6
		endr
	endc
		rts

sod	rte


;----------------------------------------------------------------
;	Self-written routine template
;	7_9_96
;

	ifne	testing_selfwrite
wash_loop_start:

wash_off1	= *+2
		 move.l	2(a1),a2	;16
wash_off2	= *+2
		 move.b	2(a2),d2	;12
		 move.l	d2,a4		;4
		 move.l	(a4),d0		;8
wash_off3	= *+2
		 move.l	2(a1),a2	;16
wash_off4	= *+2
		 move.b	2(a2),d3	;12
		 move.l	d3,a4		;4
		 or.l	(a4),d0		;12
wash_off5	= *+2
		 move.l	2(a1),a2	;16
wash_off6	= *+2
		 move.b	2(a2),d4	;12
		 move.l	d4,a4		;4
		 or.l	(a4),d0		;12
wash_off7	= *+2
		 move.l	2(a1),a2	;16
wash_off8	= *+2
		 move.b	2(a2),d5	;12
		 move.l	d5,a4		;4
		 or.l	(a4),d0		;12
wash_off9	= *+2
		 movep.l d0,2(a3)	;24
wash_loop_end:

wash_loop_length =	(wash_loop_end-wash_loop_start)
	endc

;----------------------------------------------------------------


;----------------------------------------------------------------
			section	data
;----------------------------------------------------------------

; ring number (byte), angle (byte)
wash_table		incbin	D:\Source2\M21.St\Data\Wash.dat
			even

		ifne standalone
wash_gfx		incbin	D:\Source2\m21.st\Data\Wash.Gfx
			even
		endc


		ifne standalone
sine_table:		incbin	f:\data\smallsin.dat
			even

st_palette:
			dc.w	$000,$888
			dc.w	$111,$999
			dc.w	$222,$aaa
			dc.w	$333,$bbb
			dc.w	$444,$ccc
			dc.w	$555,$ddd
			dc.w	$666,$eee
			dc.w	$777,$fff
		endc


		ifne testing_falcon
testing_colour_table:
o			set	0
			rept	16
			 dc.w	o,o		; testing colour table
o			 set	o+$841*2	; (two word values)
			endr
		endc


			dcb.w	overflow_size,0		;underflow
ring_fix_list:
o			set	0
			rept	max_ring_number-1
			 dc.w	o
o			 set	o+1		;(max_ring_angle*2)
			endr
			dcb.w	overflow_size,o		;overflow

wash_data_1		incbin	Data\Tun1.Dat
wash_data_2		incbin	Data\Tun2.Dat
			even

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
;----------------------------------------------------------------
			section	bss
;----------------------------------------------------------------
		ifne standalone
physic			ds.l	1
logic			ds.l	1
		endc

wash_gfx_type		ds.l	1			;gfx type
wash_gfx_pointer	ds.l	1			;
wash_palette		ds.l	1			;
wash_swirl_amount	ds.l	1			;
wash_swirl_speed	ds.l	1			;
wash_swirl_offset	ds.l	1			;
wash_ripple_amount	ds.l	1			;
wash_ripple_speed 	ds.l	1			;
wash_ripple_offset	ds.l	1			;

pattern_1_offset	ds.l	1
pattern_2_offset	ds.l	1
pattern_ring_offset	ds.l	1

c2p_buffer_address	ds.l	1
wash_sine_position	ds.w	1
			ds.w	1

old_44e			ds.l	1

ring_table_list		ds.l	max_ring_number

c2p_buffer		ds.b	256+(4*256)

	ifeq	testing_selfwrite
wash_table_2
		ds.w	wash_x*wash_y*2
	endc


;ring_buffer		ds.b	max_ring_number*max_ring_angle*2

; All these share the same bss space:
	ifne	testing_selfwrite

textbuffer1	equ	*
textbuffer2	equ	*+bufferheight*40*1
textbuffer3	equ	*+bufferheight*40*2
textbuffer4	equ	*+bufferheight*40*3

wash_instruction_buffer:
tunnel_instruction_buffer:
			;ds.b	max_tunnel_chunk_width*max_tunnel_height*2*(tunnel_loop_size)+10
			ds.b	(wash_loop_length)*(wash_x/4)*(wash_y)
	endc

	ifne	testing_screen
test			ds.b	256+(320*200*2)
	endc

	ifeq standalone
wash_gfx		ds.b	100*100
			even
	endc

