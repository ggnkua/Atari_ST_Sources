; Falcon vector base cack...
; September 1993 by SJT

start:
	clr.l -(a7)
	move.w #$20,-(a7)
	trap #1
	move.l d0,save_stack
	addq.l #6,a7		;use existing stacks

	jsr savevectors
	bra program_start

*****************************************
*	vector-saving routines:	*
*****************************************
savevectors:
	move.w #-1,-(a7)
	move.w #$58,-(a7)
	trap #14
	addq.l #4,a7
	move.w d0,resolution

	move.w #2,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,screen_base

	move.w #3,-(a7)
	trap #14
	addq.l #2,a7
	move.l d0,screen_base_2

	lea save_vectors(pc),a0
	lea $8.w,a1
	moveq #($140-8)/4-1,d0
.copy1	move.l (a1)+,(a0)+
	dbf d0,.copy1
 
	lea $fffffa01.w,a1
	moveq #21,d0
.copy2	move.b (a1),(a0)+
	addq.l #2,a1
	dbf d0,.copy2

;set  error vectors:
	lea $8.w,a0
	lea restore_vectors(pc),a1
	moveq #9,d0
.copy3	move.l a1,(a0)+
	dbf d0,.copy3

	bclr #3,$fffffa17.w
	rts

; Crash handler:
****************
quit:
restore_vectors:
	movem.l d0-a7,save_registers

	move.w #$2700,sr
	lea save_vectors(pc),a0
	lea $8.w,a1
	moveq #($140-8)/4-1,d0
.copy1	move.l (a0)+,(a1)+
	dbf d0,.copy1

	lea $fffffa01.w,a1
	moveq #21,d0
.copy2	move.b (a0)+,(a1)
	addq.l #2,a1
	dbf d0,.copy2
; keyboard:
	move.b #$c8,$fffffa23.w

; Keyboard:
	lea mouse_on(pc),a0
	bsr send_ikbd
; Flush:
.flush	move.b $fffffc02.w,d0
	btst #0,$fffffc00.w
	bne.s .flush		;still an error
	move.w #$2300,sr

	move.w #37,-(a7)
	trap #14
	addq.l #2,a7		;wait vbl

	move.w #-1,-(a7)
	move.l screen_base(pc),-(a7)
	move.l screen_base_2(pc),-(a7)
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	move.w resolution(pc),-(a7)
	move.w #$58,-(a7)
	trap #14
	addq.l #4,a7

	movem.l save_registers(pc),d0-a7
	move.l $10.w,-(a7)
	rts

screen_base:
	ds.l 1
screen_base_2:
	ds.l 1
resolution:
	ds.w 1
save_stack:
	ds.l 1

*****************************************
*	Keyboard handler:		*
*****************************************

keyboard:
	move.w #$2300,sr
	move.w d6,-(a7)
	move.l a6,-(a7)
.read_data
	move.w status(pc),d6
	move.w .jumplist(pc,d6.w),d6
	jmp .jumplist(pc,d6.w)

.jumplist	dc.w .keypress-.jumplist	0 - keypress
	dc.w .mouse1-.jumplist	$f8 2
	dc.w .mouse1-.jumplist	$f9 4
	dc.w .mouse1-.jumplist	$fa 6
	dc.w .mouse1-.jumplist	$fb 8
	dc.w .keypress-.jumplist	$fc 10 - keypress
	dc.w .mouse2-.jumplist	$fd 12
	dc.w .joy1-.jumplist	$fe 14 - get j1 data
	dc.w .joy2-.jumplist	$ff 16 - get j2 data

*routines:
.keypress
	sub.w d6,d6		cant use MOVEQ!
	move.b $fffffc02.w,d6
	move.b d6,keypress

	cmp.w #$39,d6		;pressing UNDO?
	beq restore_vectors		;end
	cmp.w #$f8,d6		;special cases....
	bge.s .special		;yup

	lea keyboard_matrix,a6
	bclr #7,d6		;ignore bit 7
	bne.s .keyup

	st.b (a6,d6.w)
	bra.s .end
.keyup	clr.b (a6,d6.w)
				;falls through
* Done the routine...
.end
	btst #4,$fffffa01.w
	beq.s .read_data		;there's another interrupt...
	move.l (a7)+,a6
	move.w (a7)+,d6
	rte

**** Handle joysticks:
.special:	sub.w #$f7,d6		; 1 or 2
	add.w d6,d6		; 2 or 4...
	move.w d6,status
	bra.s .end

.joy1	move.b $fffffc02.w,joy1
	clr.w status
	bra.s .end
.joy2	move.b $fffffc02.w,joy2
	clr.w status
	bra.s .end

.mouse1	move.b $fffffc02.w,d6
	ext.w d6
	add.w d6,mouse_x
	move.w status(pc),d6	2-8
	lsr.w #1,d6		1-4
	subq.w #1,d6		0-3
	move.b d6,mouse_button
	move.w #12,status
	bra.s .end

.mouse2	move.b $fffffc02.w,d6
	ext.w d6
	add.w d6,mouse_y
	clr.w status
	bra.s .end

*****************************
send_ikbd:
	move.w #$fc00,a1

.loop	btst #1,(a1)		;ready to send?
	beq.s .loop
	move.b (a0)+,2(a1)		;plonk it in
	cmp.b #-5,(a0)		;end?
	bne.s .loop
	rts

*****************************
mouse_on	dc.b $1a,$8,-5
joy_on	dc.b $14,$8,-5
	even

*********************
vbl:
	addq.w #1,vbl_timer
	cmp.b #$39,$fffffc02.w	;check for user quit
	beq restore_vectors
	movem.l d0-a6,-(A7)
	move.l my_vbl(pc),a0
	jsr (a0)
	movem.l (a7)+,d0-a6
	rte

wait_vbl:
	clr.w vbl_timer
.wv	tst.w vbl_timer
	beq.s .wv
	rts

*******************************
*	Data Section:	*
*******************************
* Mouse information:
mouse_button	dc.b 0
		even
mouse_x		dc.w 0
mouse_y		dc.w 0
save_a0		ds.l 1
status		ds.w 1
keypress		ds.w 1
keyboard_matrix	ds.b 128
joy1		ds.w 1
joy2		ds.w 1
kb_data		ds.w 1
vbl_timer		ds.w 1
logic		ds.l 1
physic		ds.l 1
my_vbl		dc.l rts

save_vectors	ds.l 350/4		?
save_registers	ds.l 16

program_start:

; Set original vectors:
	move.w my_resolution(pc),-(a7)
	MOVE.W #-1,-(A7)
	PEA $300000
	PEA $300000
	MOVE.W #5,-(A7)
	TRAP #14
	LEA 12(A7),A7
	move.w #$58,-(a7)
	trap #14
	addq.l #4,a7
	PEA CLEAR(PC)
	MOVE.W #9,-(A7)
	TRAP #1
	ADDQ.L #6,A7

	move.w #$2700,sr
	lea joy_on(pc),a0
	bsr send_ikbd


	move.l #vbl,$70.w
	move.l #keyboard,$118.w
	move.l #$ff00ff04,$fffffa06.w
	move.l #$ff00ff04,$fffffa12.w
	bclr #3,$fffffa17.w 
	move.w #$2300,sr
	bra begin

; Present setup:

; Vbl - to change vbl, set my_vbl
; ------ routines MUST be terminated by RTS! (no need to save regs)

; MFP - only keyboard routine installed. Joystick/kb activated.

my_resolution dc.w $18+3

; Bits 0-1 no.of planes
;       2  true colour mode
;	3  80 column mode
;	5  50Hz
;       6  overscan
;       8  interlace

begin:

; Load palette
	lea $ffff9800.w,a0
	lea palette+40(pc),a1
	move.w #255,d0
.copy1:
	move.w (a1)+,d1
	lsr.w #2,d1
	LSL.W #8,D1
	move.w (a1)+,d2
	lsr.w #2,d2
	move.b d2,d1
	swap d1
	move.w (a1)+,d1
	lsr.w #2,d1
	move.l d1,(a0)+
	dbf d0,.copy1

	move.l $44e.w,a1	
	move.l #(640*480)/4,d0
	moveq #0,d1
.wipe	move.l d1,(a1)+
	subq.l #1,d0
	bne.s .wipe

	lea img_picture(pc),a0
	move.l $44e.w,a1
	bsr img_depack


wait	;cmp.b #$39,$fffffc02.w
;	bne wait

	bsr wait_vbl
	bsr wait_vbl

	lea $ffff9800
.w,a0
	move.l (a0),d1
	move.w #254,d0
.colour_cycle:
	move.l 4(a0),(a0)+
	dbf d0,.colour_cycle
	move.l d1,(a0)+

	cmp.b #$39,$fffffc02.w
	bne wait
	bra quit
	illegal
rts	rts
;-------------- IMG-Depack -------------------------
; Equates:

check_ximg equ 1	;check for ximg colour palette
img_max_height	equ 480
	rsreset
img_version		rs.w 1
img_header_length	rs.w 1
img_bitplanes		rs.w 1
img_pattern_length	rs.w 1
			rs.w 2
img_picture_width	rs.w 1
img_picture_height	rs.w 1

img_my_buffer		ds.b 640
img_picture_chunks	ds.w 1
img_bytes_per_line	dc.w 640
img_chunk_offset	dc.w 16
img_bytes_width		ds.w 1
img_depack:

	ifne check_ximg
	cmp.l #"XIMG",16(a0)
	bne.s img_not_ximg
	lea 22(a0),a2
	lea $ffff9800.w,a3
	move.w #255,d0
.copy1:
	move.w (a2)+,d1
	lsr.w #2,d1
	LSL.W #8,D1
	move.w (a2)+,d2
	lsr.w #2,d2
	move.b d2,d1
	swap d1
	move.w (a2)+,d1
	lsr.w #2,d1
	move.l d1,(a3)+
	dbf d0,.copy1
img_not_ximg:
	endc

	move.l a0,a2
	add.w img_header_length(a0),a2	;header length in WORDS
	add.w img_header_length(a0),a2	;a2=start of pic data
; Palette - XIMG?

	move.w img_picture_width(a0),d0
	addq.w #7,d0
	lsr.w #3,d0
	move.w d0,img_bytes_width

	move.w img_picture_width(a0),d0
	add.w #15,d0
	lsr.w #4,d0			;number of "chunks" to do
	move.w d0,img_picture_chunks

	move.w img_picture_height(a0),d0
	cmp.w #img_max_height,d0
	ble.s .ok
	move.w #img_max_height,d0
.ok:	subq.w #1,d0

img_do_scanline:
	move.w img_bitplanes(a0),d1
	subq.w #1,d1
img_bitplane_loop:
	bsr img_do_bitplane
	addq.l #2,a1			;next bitplane
	dbf d1,img_bitplane_loop


	add.w img_bytes_per_line(pc),a1
	sub.w img_bitplanes(a0),a1
	sub.w img_bitplanes(a0),a1
	dbf d0,img_do_scanline
; Finished!!!
	rts

img_do_bitplane:
	lea img_my_buffer(pc),a3
	move.l a3,a4
	add.w img_bytes_width(pc),a4	;where we need to get to

img_read_data:
	moveq #0,d2
	move.b (a2)+,d2
	beq img_choice
	cmp.b #$80,d2
	beq img_uncompressed
	bra img_solid_mode

img_choice:
; Pattern-run or scanline-run mode?
	moveq #0,d3
	move.b (a2)+,d3			;d3=patt_repeat
	beq img_scanline_run		;oh cack. difficult bit.
	subq.w #1,d3
img_copy_pattern:
	move.w img_pattern_length(a0),d4
	subq.w #1,d4
	move.l a2,a5
; OK read pattern and copy:
.img_pattern_copy:
	move.b (a5)+,(a3)+		;into buffer
	dbf d4,.img_pattern_copy
	dbf d3,img_copy_pattern
	add.w img_pattern_length(a0),a2 ;adjust
	cmp.l a4,a3			;finished?
	blt.s img_read_data
	bra img_copy_scanline


img_uncompressed:
	move.b (a2)+,d2
	subq.w #1,d2
.copy_uncompressed:
	move.b (a2)+,(a3)+
	dbf d2,.copy_uncompressed
	cmp.l a4,a3
	blt img_read_data
	bra img_copy_scanline

img_solid_mode:
	clr.b d3
	bclr #7,d2		;only want 0-127, set flags
	sne d3
	subq.w #1,d2
.copy_solid:
	move.b d3,(a3)+
	dbf d2,.copy_solid
	cmp.l a4,a3
	blt img_read_data
	;bra img_copy_scanline

img_copy_scanline:
	lea img_my_buffer(pc),a3
	move.w img_picture_chunks(pc),d4
	subq.w #1,d4
	pea (a1)
.img_copy_2:
	move.w (a3)+,(a1)
	add.w img_chunk_offset(pc),a1
	dbf d4,.img_copy_2
	move.l (a7)+,a1
	rts

; Special case - need to copy same scanline instructions many times

img_scanline_run:
	addq.l #4,a7			;hoargh, ignore ret addr
	cmp.b #$ff,(a2)+
	bne img_read_data		;something wrong
	moveq #0,d3
	move.b (a2)+,d3			;number of lines to copy
	subq.w #1,d3			;needed before, since d0 already dec'd
	sub.w d3,d0			;adjust lines to do!
	pea (a2)
.scanline_scanline
	move.l (a7),a2			;restore data pos
	move.w img_bitplanes(a0),d1
	subq.w #1,d1

.img_bitplane_loop:
	move.w d3,-(a7)
	bsr img_do_bitplane
	move.w (a7)+,d3
	addq.l #2,a1			;next bitplane
	dbf d1,.img_bitplane_loop
	add.w img_bytes_per_line(pc),a1
	sub.w img_bitplanes(a0),a1
	sub.w img_bitplanes(a0),a1
	dbf d3,.scanline_scanline

	addq.l #4,a7			;ignore old a2
	DBF D0,img_do_scanline		;...and back again
	RTS

CLEAR:	DC.B 27,"E",0
	EVEN

PALETTE:
	INCBIN d:\FRACPLAY\TTLOW\BLENDED.PAL

img_picture:
	incbin d:\fracplay\spiral2.img
