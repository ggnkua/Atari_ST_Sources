
	xdef initialize_graphics
	xdef release_graphics
	xdef compile_sprite
	xdef compile_characters
	xdef prepare_sprite_infos
	xdef graphics_engine

	xdef display_screen_address
	xdef work_screen_address
	xdef display_window_address
	xdef text_bitmaps
	xdef text_matrix

SCREEN_BUFFER_SIZE=(16+512+256+16)*256*2*2
SCREEN_DISPLAY_OFFSET=16*2+16*256*2*2
TOTAL_NUMBER_OF_SPRITES=1885
TOTAL_NUMBER_OF_CHARACTERS=128 ; 4096 / (4 * 8) = 128
SPRITE_THROTTLE_DISPLAY_LINES=170 ; 240*3/4 = 180

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

initialize_graphics:
	; Prepare to send all sprite masks to the DSP.

	btst	#1,$ffffa202.w
	beq		*-6

	move.l	#TOTAL_NUMBER_OF_SPRITES,$ffffa204.w

	; Physbase.

	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp

	move.l	d0,physbase

	; Allocate screen buffers (16 bytes boundary, ST-RAM only).

	move	#0,-(sp)
	move.l	#SCREEN_BUFFER_SIZE*2+16,-(sp)
	move	#68,-(sp)
	trap	#1
	addq.l	#8,sp

	move.l	d0,allocated_screen_address

	add.l	#15,d0
	and.l	#$fffffff0,d0

	cmp.l	#-1,machine_supervidel
	beq		.no_supervidel

	add.l	#$a0000000,d0

.no_supervidel:
	move.l	d0,display_screen_address
	add.l	#SCREEN_BUFFER_SIZE,d0
	move.l	d0,work_screen_address

	add.l	#SCREEN_DISPLAY_OFFSET,d0
	move.l	d0,display_window_address

	; Load background graphics.

	clr		-(sp)
	pea		background_image_filename
	move	#61,-(sp)
	trap	#1
	addq.l	#8,sp

	move	d0,d7

	pea		background_image
	move.l	#256*2*512,-(sp)
	move	d7,-(sp)
	move	#63,-(sp)
	trap	#1
	lea		12(sp),sp

	move	d7,-(sp)
	move	#62,-(sp)
	trap	#1
	addq.l	#4,sp

	; Load background graphics (wrapped part).
	
	clr		-(sp)
	pea		background_image_filename
	move	#61,-(sp)
	trap	#1
	addq.l	#8,sp

	move	d0,d7

	pea		background_image+256*2*512
	move.l	#256*2*256,-(sp)
	move	d7,-(sp)
	move	#63,-(sp)
	trap	#1
	lea		12(sp),sp

	move	d7,-(sp)
	move	#62,-(sp)
	trap	#1
	addq.l	#4,sp

	; Copy background graphics.

	lea		background_image,a0
	move.l	display_screen_address,a1
	add.l	#SCREEN_DISPLAY_OFFSET,a1
	move.l	work_screen_address,a2
	add.l	#SCREEN_DISPLAY_OFFSET,a2

	move	#512+256-1,d7

.copy_loop1:
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,(a1)
	movem.l	d0-d6/a3-a6,(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4(a1)
	movem.l	d0-d6/a3-a6,11*4(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*2(a1)
	movem.l	d0-d6/a3-a6,11*4*2(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*3(a1)
	movem.l	d0-d6/a3-a6,11*4*3(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*4(a1)
	movem.l	d0-d6/a3-a6,11*4*4(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*5(a1)
	movem.l	d0-d6/a3-a6,11*4*5(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*6(a1)
	movem.l	d0-d6/a3-a6,11*4*6(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*7(a1)
	movem.l	d0-d6/a3-a6,11*4*7(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*8(a1)
	movem.l	d0-d6/a3-a6,11*4*8(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*9(a1)
	movem.l	d0-d6/a3-a6,11*4*9(a2)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*10(a1)
	movem.l	d0-d6/a3-a6,11*4*10(a2)
	movem.l	(a0)+,d0-d6
	movem.l	d0-d6,11*4*11(a1)
	movem.l	d0-d6,11*4*11(a2)

	add.l	#256*2*2,a1
	add.l	#256*2*2,a2

	dbf		d7,.copy_loop1

	move.l	display_screen_address,a0
	add.l	#SCREEN_DISPLAY_OFFSET,a0
	lea		background_image+SCREEN_DISPLAY_OFFSET,a1

	move	#512+256-1,d7

.copy_loop2:
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*2(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*3(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*4(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*5(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*6(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*7(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*8(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*9(a1)
	movem.l	(a0)+,d0-d6/a3-a6
	movem.l	d0-d6/a3-a6,11*4*10(a1)
	movem.l	(a0)+,d0-d6
	movem.l	d0-d6,11*4*11(a1)

	add.l	#256*2,a0
	add.l	#256*2*2,a1

	dbf		d7,.copy_loop2

	; Build color translation table.

	lea		color_translation_table,a0
	clr.l	d0

.color_translation_loop:
	bfextu	d0{16+5:5},d1
	bfextu	d0{16+0:5},d2
	bfextu	d0{16+10:5},d3

	clr		d4

	bfins	d1,d4{16+0:5}
	bfins	d2,d4{16+5:5}
	bfins	d3,d4{16+11:5}

	move	d4,(a0)+

	addq	#1,d0
	bne		.color_translation_loop

	rts

; ------------------------------------------------------------------------------

release_graphics:
	; Free allocated graphics buffer.

	move.l	allocated_screen_address,-(sp)
	move	#73,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

; ------------------------------------------------------------------------------
;
; a0.l = compiled sprites struct address.
;

; d0   #1
; d1   #2
; d2   #3
; d3   #4
; d4   #5
; d5   #6
; d6   #7
; d7   #8 
; a0   #9
; a1   #10
; a2   #11
; a3   #12
; a4   #13
; a5   palette_address / #14
; a6   screen_address
; sp   stack_pointer
; (sp) #15

convert_sprite_to_drawing_code:
	movem.l	d0-a6,-(sp)

	lea		sprite_matrix,a1
	move.l	free_compiled_objects_address,a2
	move.l	a2,(a0)
	lea		sprite_color_to_register_table,a0

	; Colors.

	lea		sprite_colors_count+2,a3 ; Start at index #1.
	clr		d0 ; Color index.
	clr		d1 ; Color register bitmap (for "movem.l", bit 0 = d0, ...).
	clr		d2 ; Gap offset.

	cmp		#15,sprite_color_count
	bne		.skip_color_fix1

	move	#$2f2d,(a2)+ ; "move.l x(a5),-(sp)".
	move	#15*4,(a2)+ ; "x".

.skip_color_fix1:
	move	#16-1-1,d7

.colors_loop:
	tst		(a3)+
	beq		.process_gap

	tst		d2
	beq		.count_colors

	cmp		#8,d2
	ble		.quick_add1

	move	#$4bed,(a2)+ ; "lea x(a5),a5".
	move	d2,(a2)+ ; "x".

	bra		.count_colors

.quick_add1:
	and		#$7,d2
	lsl		#8,d2
	add		d2,d2
	add		#$508d,d2 ; "addq.l #x,a5".
	move	d2,(a2)+

.count_colors:
	clr		d2

	move	2(a0,d0.w*2),d3
	cmp		#15,d3
	beq		.skip_color_fix2

	bset	d3,d1

.skip_color_fix2:
	bra		.next_color

.process_gap:
	tst		d1
	beq		.count_gaps

	move	#$4cdd,(a2)+ ; "movem.l (a5)+,rx-ry".
	move	d1,(a2)+ ; "rx-ry".

.count_gaps:
	clr		d1

	addq	#4,d2

.next_color:
	addq	#1,d0

	dbf		d7,.colors_loop

	tst		d1
	beq		.no_final_colors

	move	#$4cdd,(a2)+ ; "movem.l (a5)+,rx-ry".
	move	d1,(a2)+ ; "rx-ry".

.no_final_colors:
	; Pixels.

	clr		d0 ; Gap offset.
	clr		d1

	move	#16-1,d7

.lines_loop2:
	move	#16-1,d6

.pixels_loop:
	move.b	(a1)+,d1
	bne		.process_pixel

	addq	#2,d0

	bra		.next_pixel

.process_pixel:
	tst		d0
	beq		.draw_pixel

	cmp		#8,d0
	ble		.quick_add2

	move	#$4dee,(a2)+ ; "lea x(a6),a6".
	move	d0,(a2)+ ; "x".

	bra		.draw_pixel

.quick_add2:
	and		#$7,d0
	lsl		#8,d0
	add		d0,d0
	add		#$508e,d0 ; "addq.l #x,a6".
	move	d0,(a2)+

.draw_pixel:
	clr		d0

	move	(a0,d1.w*2),d2 ; "x".
	cmp		#15,d2
	bne		.skip_color_fix3

	move	#$3cd7,d2 ; "move.w (sp),(a6)+".
	cmp		-2(a2),d2 ; Is the last opcode also "move.w (sp),(a6)+"?
	bne		.set_draw_color_command

	move	#$2cd7,d2 ; "move.l (sp),(a6)+".
	subq.l	#2,a2

	bra		.set_draw_color_command

.skip_color_fix3:
	add		#$3cc0,d2 ; "move.w rx,(a6)+".

	cmp		-2(a2),d2 ; Is the last opcode also "move.w rx,(a6)+"?
	bne		.set_draw_color_command

	sub		#$1000,d2 ; Convert the current opcode to "move.l rx,(a6)+".
	subq.l	#2,a2

.set_draw_color_command:
	move	d2,(a2)+

.next_pixel:
	dbf		d6,.pixels_loop

	add		#(256*2-16)*2,d0

	dbf		d7,.lines_loop2

	cmp		#15,sprite_color_count
	bne		.skip_color_fix4

	move	#$588f,(a2)+ ; "addq.l #4,sp".

.skip_color_fix4:
	move	#$4e75,(a2)+ ; "rts".

	move.l	a2,free_compiled_objects_address

	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------
;
; a0.l = compiled sprites struct address.

convert_sprite_to_restore_data:
	movem.l	d0-a6,-(sp)

	move.l	free_compiled_objects_address,a2
	move.l	a2,(a0)
	
	lea		sprite_matrix,a1
	
	clr		d0 ; Pixel offset.
	clr		d1 ; Jump offset.
	
	move	#16-1,d7

.lines_loop:
	move	#16-1,d6
	
.pixels_loop:
	tst.b	(a1)+
	beq		.no_pixel
	
	tst		d1
	bne		.skip_pixel_offset
	
	move	d0,(a2)+
	clr		d0

.skip_pixel_offset:
	subq	#2,d1

	bra		.next_pixel
	
.no_pixel:
	tst		d1
	beq		.skip_jump_offset
	
	move	d1,(a2)+
	clr		d1

.skip_jump_offset:
	addq	#2,d0

.next_pixel:
	dbf		d6,.pixels_loop
	
	tst		d1
	beq		.skip_jump_offset2
	
	move	d1,(a2)+
	clr		d1

.skip_jump_offset2:
	add		#(512-16)*2,d0

	dbf		d7,.lines_loop

	move	#-1,(a2)+
	
	move.l	a2,free_compiled_objects_address
	
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

build_and_send_sprite_mask_to_dsp:
	movem.l	d0-a6,-(sp)

	lea		sprite_matrix,a0
	lea		sprite_mask_bitmap,a1

	move	#16-1,d7

.loop:
	clr		d0

	move	#16-1,d6

.loop2:
	tst.b	(a0)+
	beq		.no_pixel

	bset	d6,d0

.no_pixel:
	dbf		d6,.loop2

	move	d0,(a1)+

	dbf		d7,.loop

	; Send packed mask to DSP.

	lea		$ffffa204.w,a0
	lea		sprite_mask_bitmap,a1

	rept 5

	move.l	(a1)+,d0
	move	d0,d1
	lsr.l	#8,d0
	move.l	d0,(a0)
	swap	d1
	move	(a1)+,d1
	move.l	d1,(a0)

	endr

	move	(a1)+,d0
	lsl.l	#8,d0
	move.l	d0,(a0)

	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------
;
; d0.l = original sprite data address.
;

compile_sprite:
	movem.l	d0-a6,-(sp)

	; Create sprite matrix and count colors.

	move.l	(sp),a0
	lea		sprite_matrix,a1
	lea		sprite_colors_count+16*2,a2
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)

	move	#16-1,d7

.lines_loop1:
	move.l	(a0)+,d1
	bfextu	d1{0:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{4:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{8:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{12:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{16:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{20:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{24:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{28:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+

	move.l	16*4-4(a0),d1
	bfextu	d1{0:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{4:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{8:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{12:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{16:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{20:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{24:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+
	bfextu	d1{28:4},d2
	addq	#1,(a2,d2.w*2)
	move.b	d2,(a1)+

	dbf		d7,.lines_loop1

	; Send sprite mask to DSP.

	jsr		build_and_send_sprite_mask_to_dsp

	; Palette color counting.

	lea		sprite_colors_count+2,a0
	lea		sprite_color_to_register_table+2,a1
	clr		d0

	move	#16-1-1,d7

.count_loop:
	tst		(a0)+
	beq		.color_not_used

	move	d0,(a1)
	addq	#1,d0

.color_not_used:
	addq.l	#2,a1

	dbf		d7,.count_loop

	move	d0,sprite_color_count

	; Create normal sprite.

	move.l	(sp),a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	; Create horizontally flipped sprite.

	lea		sprite_matrix,a0

	move	#16-1,d7

.flip_loop1:
	lea		16(a0),a1

	rept 8

	move.b	(a0),d0
	move.b	-(a1),(a0)+
	move.b	d0,(a1)

	endr

	addq.l	#8,a0

	dbf		d7,.flip_loop1

	move.l	(sp),a0
	addq.l	#4,a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	; Create horizontally and vertically flipped sprite.

	lea		sprite_matrix,a0
	lea		15*16(a0),a1

	move	#8-1,d7

.flip_loop2:
	rept 4

	move.l	(a0),d0
	move.l	(a1),(a0)+
	move.l	d0,(a1)+

	endr

	sub.l	#16*2,a1

	dbf		d7,.flip_loop2

	move.l	(sp),a0
	add.l	#12,a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	; Create vertically flipped sprite.

	lea		sprite_matrix,a0

	move	#16-1,d7

.flip_loop3:
	lea		16(a0),a1

	rept 8

	move.b	(a0),d0
	move.b	-(a1),(a0)+
	move.b	d0,(a1)

	endr

	addq.l	#8,a0

	dbf		d7,.flip_loop3

	move.l	(sp),a0
	addq.l	#8,a0
	jsr		convert_sprite_to_drawing_code
	add.l	#16,a0
	jsr		convert_sprite_to_restore_data

	addq.l	#8,a0
	move	sprite_count,(a0)
	addq	#1,sprite_count

	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

compile_characters:
	movem.l	d0-a6,-(sp)

	; Reorder character graphics.
	
	move.l	TEXT_GRAPHICS_ADDRESS,a0
	
	clr		d0
	
.reorder_loop:
	lea		text_reorder_buffer,a1

	move	d0,d1
	lsl		#5,d1
	lea		(a0,d1.w),a2

	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	add.l	#16,a2
	
	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	sub.l	#16-1,a2
	
	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	add.l	#16,a2
	
	move.b	32*0+0(a2),(a1)+
	move.b	32*1+0(a2),(a1)+
	move.b	32*2+0(a2),(a1)+
	move.b	32*3+0(a2),(a1)+

	move.b	32*0+2(a2),(a1)+
	move.b	32*1+2(a2),(a1)+
	move.b	32*2+2(a2),(a1)+
	move.b	32*3+2(a2),(a1)+

	move.b	32*0+4(a2),(a1)+
	move.b	32*1+4(a2),(a1)+
	move.b	32*2+4(a2),(a1)+
	move.b	32*3+4(a2),(a1)+
	
	move.b	32*0+6(a2),(a1)+
	move.b	32*1+6(a2),(a1)+
	move.b	32*2+6(a2),(a1)+
	move.b	32*3+6(a2),(a1)+
	
	move.b	32*0+8(a2),(a1)+
	move.b	32*1+8(a2),(a1)+
	move.b	32*2+8(a2),(a1)+
	move.b	32*3+8(a2),(a1)+

	move.b	32*0+10(a2),(a1)+
	move.b	32*1+10(a2),(a1)+
	move.b	32*2+10(a2),(a1)+
	move.b	32*3+10(a2),(a1)+

	move.b	32*0+12(a2),(a1)+
	move.b	32*1+12(a2),(a1)+
	move.b	32*2+12(a2),(a1)+
	move.b	32*3+12(a2),(a1)+
	
	move.b	32*0+14(a2),(a1)+
	move.b	32*1+14(a2),(a1)+
	move.b	32*2+14(a2),(a1)+
	move.b	32*3+14(a2),(a1)+

	lea		text_reorder_buffer,a1
	sub.l	#16+1,a2

	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	
	addq	#4,d0
	cmp		#TOTAL_NUMBER_OF_CHARACTERS,d0
	bne		.reorder_loop
	
	; Compile characters.

	move.l	TEXT_GRAPHICS_ADDRESS,-(sp)
	
	move	#TOTAL_NUMBER_OF_CHARACTERS-1,d7
	
.characters_loop:

	; Clear sprite matrix.

	lea		sprite_matrix+16*16,a1

	moveq	#16-1,d6

.clear_loop:
	clr.l	-(a1)
	clr.l	-(a1)
	clr.l	-(a1)
	clr.l	-(a1)

	dbf		d6,.clear_loop

	; Clear color count table.

	lea		sprite_colors_count+16*2,a2
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)

	move.l	(sp),a0

	; Decode character graphics.

	moveq	#8-1,d6

.lines_loop:
	move.b	(a0)+,d3
	move.b	(a0)+,d2
	move.b	(a0)+,d1
	move.b	(a0)+,d0

	move	#8-1,d5

.pixels_loop:
	clr		d4

	add.b	d0,d0
	addx	d4,d4
	add.b	d1,d1
	addx	d4,d4
	add.b	d2,d2
	addx	d4,d4
	add.b	d3,d3
	addx	d4,d4

	addq	#1,(a2,d4.w*2)
	move.b	d4,(a1)+

	dbf		d5,.pixels_loop

	addq.l	#8,a1

	dbf		d6,.lines_loop

	; Palette color counting.

	lea		sprite_colors_count+2,a0
	lea		sprite_color_to_register_table+2,a1
	clr		d0

	moveq	#16-1-1,d6

.count_loop:
	tst		(a0)+
	beq		.color_not_used

	move	d0,(a1)
	addq	#1,d0

.color_not_used:
	addq.l	#2,a1

	dbf		d6,.count_loop

	move	d0,sprite_color_count

	; Create normal sprite.

	move.l	(sp),a0
	jsr		convert_sprite_to_drawing_code
	addq.l	#4,a0
	jsr		convert_sprite_to_restore_data

	add.l	#4*8,(sp)
	
	dbf		d7,.characters_loop
	
	addq.l	#4,sp
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

prepare_sprite_infos:
	movem.l	d0-a6,-(sp)

	; Sort sprites.

	lea		SPRITE_DATA_TABLE,a0
	move.l	CURRENT_SPRITE_DATA_ENTRY,d7
	sub.l	a0,d7
	beq		.skip_all

	move.l	d7,(sp) ; Return number of prepared sprites.

	move.l	work_sprite_infos_address,a3

	lsr		#3,d7
	move	d7,(a3)+
	beq		.skip_all

	subq	#1,d7

	lea		sort_buffers,a1
	lea		sort_counts+32*2,a2

	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	clr.l	-(a2)
	
	addq.l	#6,a0
	
	clr		d0
	
.sort_loop:
	moveq	#$1f,d1
	and		(a0),d1
	
	move	(a2,d1.w*2),d2
	addq	#1,(a2,d1.w*2)
	swap	d1
	lsr.l	#7,d1
	add		d2,d1
	move	d0,(a1,d1.w*2)

	addq	#1,d0
	addq.l	#8,a0
	
	dbf		d7,.sort_loop

	; Reorder sprite data.

	lea		SPRITE_DATA_TABLE,a0
	
	move	#32-1,d7
	
.reorder_loop:
	move	(a2)+,d6
	beq		.skip_reorder
	
	lea     (a1,d6.w*2),a4
	subq	#1,d6
	
.reorder_loop2:
	move	-(a4),d0
	move.l	(a0,d0.w*8),(a3)+
	move.l	4(a0,d0.w*8),(a3)+

	dbf		d6,.reorder_loop2
	
.skip_reorder:
	lea		512*2(a1),a1

	dbf		d7,.reorder_loop
	
.skip_all:
	move.l	work_sprite_infos_address,d0
	move.l	display_sprite_infos_address,work_sprite_infos_address
	move.l	d0,display_sprite_infos_address
	
	movem.l	(sp)+,d0-a6

	move.l	#SPRITE_DATA_TABLE,CURRENT_SPRITE_DATA_ENTRY

	clr.l	d0

	rts
	
; ------------------------------------------------------------------------------

process_sprite_infos:
;	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES-60,$fffffa21.w
;	bcc		.start_processing
	
;	move.l	#process_sprite_infos,next_graphics_routine
	
;	rts

;.start_processing:
	movem.l	d0-a6,-(sp)

	move.l	display_sprite_infos_address,a0

	clr.l	d7
	move	(a0)+,d7
	bne		.start

	movem.l	(sp)+,d0-a6

	rts

.start:
	move.l	SPRITE_DATA_ADDRESS,a1

	move.l	work_screen_address,a2
	move	work_background_position,d0
	swap	d0
	clr		d0
	lsr.l	#6,d0
	add.l	d0,a2

	lea		translated_palettes,a3
	move.l	work_sprite_infos_address_new,a4
	lea		$ffffa204+2.w,a6

	btst	#3,$ffffa202.w
	beq		*-6

	bset	#3,$ffffa200.w

	move.l	d7,$ffffa204.w ; Send number of sprite infos to be sent to the DSP.

	subq	#1,d7

.loop:
	movem	(a0)+,d0-d3

	move	d1,d5

	lea		(a2,d0.w*2),a5
	swap	d1
	clr		d1
	lsr.l	#6,d1
	add.l	d1,a5
	move.l	a5,(a4)+ ; Screen address.

	move	d3,d1
	lsr		#4,d1
	and		#$f0,d1
	lea		4(a3,d1.w*4),a5
	move.l	a5,(a4)+ ; Palette address.

	ext.l	d2
	lsl.l	#2+3+2,d2
	lea		(a1,d2.l),a5 ; Sprite data.

	move	d3,d1
	and		#$c000,d1
	or		32(a5),d1
	move	d1,(a6) ; Flip info + sprite ID -> DSP.
	move	d0,(a6) ; X position -> DSP.
	move	d5,(a6) ; Y position -> DSP.

	rol		#2,d3
	and		#$3,d3
	lea		(a5,d3.w*4),a5
	move.l	(a5),(a4)+ ; Sprite draw address.
	move.l	16(a5),(a4)+ ; Sprite restore address.

	dbf		d7,.loop

	clr.l	(a4) ; End marker.

	movem.l	(sp)+,d0-a6

	bra		update_background

; ------------------------------------------------------------------------------

update_background:
	movem.l	d0-d1,-(sp)

	move	#512-1,d0
	move	BACKGROUND_SCROLL_COUNTER,d1
	and		#$1ff,d1
	sub		d1,d0
	clr		d0 ; Fixme!
	move	d0,work_background_position

	movem.l	(sp)+,d0-d1

	bra		translate_palettes

; ------------------------------------------------------------------------------

translate_palettes:
;	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES-60,$fffffa21.w
;	bcc		.start_translating
	
;	move.l	#translate_palettes,next_graphics_routine
	
;	rts

;.start_translating:
	movem.l	d0-a6,-(sp)

	lea		L_00E82000+$200,a0
	lea		color_translation_table,a1
	lea		translated_palettes,a2

	clr.l	d0

	move	#16*16/16-1,d7

.loop:
	rept 16

	move	(a0)+,d0
	move	(a1,d0.l*2),d1
	move	d1,(a2)+
	move	d1,(a2)+

	endr

	dbf		d7,.loop

	movem.l	(sp)+,d0-a6

	bra		clear_text

; ------------------------------------------------------------------------------

clear_text:
	movem.l	d0-a6,-(sp)

	move.l	work_text_infos_address,a3
	
	bra		.start

.loop:
	move.l	d0,a2
	move.l	(a3)+,a1
	addq.l	#4,a3
	move.l	(a3)+,a0
	
	bra		.jump
	
.sprite_loop:
	add		d0,a1
	add		d0,a2
	
	move	(a0)+,d0
	jmp		.jump(pc,d0.w)

	rept 16

	move	(a1)+,(a2)+
	
	endr

.jump:
	move	(a0)+,d0
	bpl		.sprite_loop
	
.start:
	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES,$fffffa21.w
	bcc		.start2
	
	move.l	a3,next_text_infos_address
	move.l	#.resume,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.resume:
	movem.l	d0-a6,-(sp)

	move.l	next_text_infos_address,a3
	
.start2:
	move.l	(a3)+,d0
	bne		.loop

	move.l	work_text_infos_address,a0	
	clr.l	(a0)

	movem.l	(sp)+,d0-a6

	bra		draw_sprites
	
; ------------------------------------------------------------------------------

draw_sprites:
	movem.l	d0-a6,-(sp)

	move.l	next_sprite_infos_address,a0

	bra		.start

.loop:
	move.l	d0,a6
	move.l	(a0)+,a5
	move.l	(a0)+,a1

	pea		4(a0)

	jsr		(a1)

	move.l	(sp)+,a0

	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES,$fffffa21.w
	bcc		.start
	
	move.l	a0,next_sprite_infos_address
	move.l	#draw_sprites,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.start:
	move.l	(a0)+,d0
	bne		.loop

;	move.l	work_sprite_infos_address_old,d0 ; Fixme!
;	move.l	work_sprite_infos_address_new,work_sprite_infos_address_old
;	move.l	d0,work_sprite_infos_address_new

	movem.l	(sp)+,d0-a6

	move.l	#sprite_infos3,next_sprite_infos_address

	bra		clear_sprites_dsp

; ------------------------------------------------------------------------------

clear_sprites_dsp:
	movem.l	d0-a6,-(sp)

	move.l	work_sprite_infos_address_new,a0	
	tst.l	(a0)
	beq		.skip

.wait_for_dsp_loop:
	btst	#3,$ffffa202.w
	beq		.start

	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES,$fffffa21.w
	bcc		.wait_for_dsp_loop
	
	move.l	#clear_sprites_dsp,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.start:
	bclr	#3,$ffffa200.w
	
	lea		$ffffa204.w,a0
	lea		$ffffa204+2.w,a1
	lea		background_image+16*256*2*2,a2
	move.l	work_screen_address,a3
	add.l	#16*256*2*2,a3

	move.l	(a0),d0 ; RLE count.

	move	#255,d2
	sub.b	$fffffa21.w,d2
	move	d0,d1
	lsr		#4,d1
	add		d1,d2
	cmp		#SPRITE_THROTTLE_DISPLAY_LINES,d2
	bcs		.rle_loop
	
	move.l	#.clear_sprites_dsp2,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.clear_sprites_dsp2:
	movem.l	d0-a6,-(sp)

	lea		$ffffa204.w,a0
	lea		$ffffa204+2.w,a1
	lea		background_image+16*256*2*2,a2
	move.l	work_screen_address,a3
	add.l	#16*256*2*2,a3

	bra		.rle_loop

	rept 16+256+16

	move	(a2)+,(a3)+

	endr

.rle_loop:
	move.l	(a0),d0
	add.l	d0,a2
	add.l	d0,a3

	move	(a1),d1

	jmp		.rle_loop(pc,d1.w)

.skip:
	move.l	work_sprite_infos_address_new,a0	
	clr.l	(a0)
	
	movem.l	(sp)+,d0-a6

	bra		prepare_text

; ------------------------------------------------------------------------------

prepare_text:
	movem.l	d0-a6,-(sp)

	move.l	#text_bitmaps,a0
	lea		text_matrix,a1
	move.l	TEXT_GRAPHICS_ADDRESS,a2
	move.l	work_text_infos_address,a3
	lea		background_image+SCREEN_DISPLAY_OFFSET,a4
	move.l	work_screen_address,a5
	add.l	#SCREEN_DISPLAY_OFFSET,a5

	move	#32-1,d7

.lines_loop:
	move.l	(a0),d0
	beq		.skip_line	

	move	#32-1,d6

.characters_loop:
	add.l	d0,d0
	bcc		.skip_character

	move.l	a5,(a3)+
	move.l	a4,(a3)+

	clr		d1
	move.b	(a1),d1
	lsl		#5,d1
	move.l	(a2,d1.w),(a3)+
	move.l	4(a2,d1.w),(a3)+
	
.skip_character:
	addq.l	#1,a1
	add.l	#8*2,a4
	add.l	#8*2,a5

	dbf		d6,.characters_loop

	add.l	#256*2*2*8-256*2,a4
	add.l	#256*2*2*8-256*2,a5

	bra		.next_line

.skip_line:
	add.l	#32,a1
	add.l	#256*2*2*8,a4
	add.l	#256*2*2*8,a5

.next_line:
	move.l	32*4(a0),(a0)+

	dbf		d7,.lines_loop

	clr.l	(a3) ; End marker.

	movem.l	(sp)+,d0-a6
	
	bra		draw_text
	
; ------------------------------------------------------------------------------

draw_text:
	movem.l	d0-a6,-(sp)

	move.l	work_text_infos_address,a0
	lea		translated_palettes+4,a5

.loop:
	move.l	(a0),d0
	beq		.end

	movem.l	a0/a5,-(sp)

	move.l	d0,a6
	move.l	8(a0),a0
	jsr		(a0)

	movem.l	(sp)+,a0/a5

	add.l	#4*4,a0

	cmp.b	#255-SPRITE_THROTTLE_DISPLAY_LINES,$fffffa21.w
	bcc		.loop
	
	move.l	a0,next_text_infos_address

	move.l	#.resume,next_graphics_routine
	
	movem.l	(sp)+,d0-a6
	
	rts

.resume:
	movem.l	d0-a6,-(sp)

	move.l	next_text_infos_address,a0
	lea		translated_palettes+4,a5

	bra		.loop

.end:
	movem.l	(sp)+,d0-a6
	
	bra		flip_screen
	
; ------------------------------------------------------------------------------

flip_screen:
	movem.l	d0-d1,-(sp)

	move.l	work_screen_address,d0
	move.l	display_screen_address,work_screen_address
	move.l	d0,display_screen_address

	move	work_background_position,d0
	move	display_background_position,work_background_position
	move	d0,display_background_position

	move.l	work_text_infos_address,d0
	move.l	display_text_infos_address,work_text_infos_address
	move.l	d0,display_text_infos_address

;	move.l	work_sprite_infos_address_old,d0 ; Fixme!
;	move.l	display_sprite_infos_address_old,work_sprite_infos_address_old
;	move.l	d0,display_sprite_infos_address_old

;	move.l	work_sprite_infos_address_new,d0 ; Fixme!
;	move.l	display_sprite_infos_address_new,work_sprite_infos_address_new
;	move.l	d0,display_sprite_infos_address_new

	move	display_background_position,d0

	ifd __HATARI__

	move.l	work_screen_address,d1

	else

	move.l	display_screen_address,d1

	endif

	add.l	#SCREEN_DISPLAY_OFFSET,d1
	swap	d0
	clr		d0
	lsr.l	#6,d0
	add.l	d0,d1
	move.l	d1,display_window_address

	movem.l	(sp)+,d0-d1

	move.l	#process_sprite_infos,next_graphics_routine
	
	rts

; ------------------------------------------------------------------------------

clear_sprites:
	movem.l	d0-a6,-(sp)

	move.l	work_sprite_infos_address_old,a3
	lea		background_image,a4
	move.l	work_screen_address,d1
	
	bra		.start

.loop:
	addq.l	#8,a3
	move.l	(a3)+,a0
	
	move.l	d0,a2
	sub.l	d1,d0
	lea		(a4,d0.l),a1

	bra		.jump
	
.sprite_loop:
	add		d0,a1
	add		d0,a2
	
	move	(a0)+,d0
	jmp		.jump(pc,d0.w)

	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+
	move	(a1)+,(a2)+

.jump:
	move	(a0)+,d0
	bpl		.sprite_loop
	
.start:
	move.l	(a3)+,d0
	bne		.loop

	move.l	work_sprite_infos_address_old,a0	
	clr.l	(a0)
	
	movem.l	(sp)+,d0-a6

	rts

; ------------------------------------------------------------------------------

graphics_engine:
	move.l	next_graphics_routine,-(sp)
	rts

; ------------------------------------------------------------------------------

draw_text_slow:
	movem.l	d0-a6,-(sp)

	lea		text_bitmaps,a0
	lea		L_00E00000,a1
	move.l	work_screen_address,a2
	add.l	#SCREEN_DISPLAY_OFFSET,a2
	lea		translated_palettes,a3

	move	#32-1,d7

.text_lines_loop:
	move.l	(a0),d0
	beq		.skip_text_line	

	move	#32-1,d6

.characters_loop:
	add.l	d0,d0
	bcc		.skip_character

	move	#8-1,d5

.lines_loop:
	move.l	a1,a4
	move.b	(a4),d1
	swap	d1

	add.l	#$20000,a4
	move.b	(a4),d1
	swap	d1

	add.l	#$20000,a4
	move.b	(a4),d2
	swap	d2

	add.l	#$20000,a4
	move.b	(a4),d2
	swap	d2

	move.l	a2,a4

	move	#8-1,d4

.pixels_loop:
	clr		d3

	swap	d2
	add.b	d2,d2
	addx	d3,d3
	swap	d2
	add.b	d2,d2
	addx	d3,d3
	swap	d1
	add.b	d1,d1
	addx	d3,d3
	swap	d1
	add.b	d1,d1
	addx	d3,d3
	beq		.skip_pixel

	move	(a3,d3.w*4),(a4)

.skip_pixel:
	addq.l	#2,a4

	dbf		d4,.pixels_loop

	add.l	#128,a1
	add.l	#256*2*2,a2

	dbf		d5,.lines_loop

	sub.l	#128*8,a1
	sub.l	#256*2*2*8,a2

.skip_character:
	addq.l	#1,a1
	add.l	#8*2,a2

	dbf		d6,.characters_loop

	add.l	#128*8-32,a1
	add.l	#256*2*2*8-256*2,a2

	bra		.next_text_line

.skip_text_line:
	add.l	#128*8,a1
	add.l	#256*2*2*8,a2

.next_text_line:
	move.l	32*4(a0),(a0)+

	dbf		d7,.text_lines_loop	

	movem.l	(sp)+,d0-a6

	rts
	
; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

background_image_filename:
	dc.b	'ETC_DAT\BACKGND.DAT',0

	even

next_graphics_routine:
	dc.l	process_sprite_infos
	
display_sprite_infos_address_new:
	dc.l	sprite_infos1

display_sprite_infos_address_old:
	dc.l	sprite_infos2

work_sprite_infos_address_new:
	dc.l	sprite_infos3

work_sprite_infos_address_old:
	dc.l	sprite_infos4

free_compiled_objects_address:
	dc.l	compiled_objects

next_sprite_infos_address:
	dc.l	sprite_infos3

display_sprite_infos_address:
	dc.l	emulated_sprite_infos1

work_sprite_infos_address:
	dc.l	emulated_sprite_infos2

next_text_infos_address:
	dc.l	text_infos1

work_text_infos_address:
	dc.l	text_infos1
	
display_text_infos_address:
	dc.l	text_infos2
	
; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

physbase:
	ds.l	1

allocated_screen_address:
	ds.l	1

display_screen_address:
	ds.l	1

work_screen_address:
	ds.l	1

display_window_address:
	ds.l	1

display_background_position:
	ds		1

work_background_position:
	ds		1

sprite_infos1: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

sprite_infos2: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

sprite_infos3: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

sprite_infos4: ; screen_address, palette_address, sprite_draw_address, sprite_clear_address.
	ds.l	512*4+1

emulated_sprite_infos1:
	ds		1+512*4

emulated_sprite_infos2:
	ds		1+512*4

text_bitmaps:
	ds.l	2*32 ; Text clear bitmap infos followed by text draw bitmap infos.

text_matrix:
	ds.b	32*32

text_infos1:
	ds.l	32*32*4+1 ; screen_adress, background_address, text_draw_address, text_clear_address

text_infos2:
	ds.l	32*32*4+1 ; screen_adress, background_address, text_draw_address, text_clear_address

text_reorder_buffer:
	ds.b	32*4

background_image:
	ds.b	SCREEN_BUFFER_SIZE

color_translation_table:
	ds		$10000

translated_palettes:
	ds.l	16*16

compiled_objects:
	ds.b	$300000

sprite_color_count:
	ds		1

sprite_colors_count:
	ds		16

sprite_color_to_register_table:
	ds		16

sprite_matrix:
	ds.b	16*16

sprite_mask_bitmap:
	ds		16

sprite_count:
	ds		1

sort_buffers:
	ds		32*512
	
sort_counts:
	ds		32

sorted_sprite_data:
	ds		512*8

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------

