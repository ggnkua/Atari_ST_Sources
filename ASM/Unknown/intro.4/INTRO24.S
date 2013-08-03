c_particle1_width			EQU 16
c_particle2_width			EQU 12
c_particle3_width			EQU 8
c_particle4_width			EQU 4

c_particle1_height		EQU 12
c_particle2_height		EQU 9
c_particle3_height		EQU 6
c_particle4_height		EQU 3

c_particle1_array_size	EQU 16
c_particle2_array_size	EQU	32
c_particle3_array_size	EQU	48
c_particle4_array_size	EQU	64

c_screen_size			EQU	245*160
c_return_code_bytes		EQU	6

c_particle_spawn_freq	EQU	2
c_random_xtable_size	EQU	512

break	MACRO
;	move.b	#0,$ffc123
	ENDM
	
	move.l  4(sp),a5                ; address to basepage
	move.l  $0c(a5),d0              ; length of text segment
	add.l   $14(a5),d0              ; length of data segment
	add.l   $1c(a5),d0              ; length of bss segment
	add.l   #$1000,d0               ; length of stackpointer
	add.l   #$100,d0                ; length of basepage
	move.l  a5,d1                   ; address to basepage
	add.l   d0,d1                   ; end of program
	and.l   #-2,d1                  ; make address even
	move.l  d1,sp                   ; new stackspace

	move.l  d0,-(sp)                ; mshrink()
	move.l  a5,-(sp)                ;
	move.w  d0,-(sp)                ;
	move.w  #$4a,-(sp)              ;
	trap    #1                  	;
	lea 	12(sp),sp               ;

	jsr		initialize
;	jsr		init_music

	movem.l	black_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	jsr		low_resolution

	move.l	#c_screen_size,-(sp)
	move.l	#screen_buffer,-(sp)
	jsr	create_double_buffer
	lea	8(sp),sp

	move.l	logical_screen,-(sp)
	move.l	#c_screen_size,-(sp)
	move.l	#0,-(sp)
	jsr	memset
	lea	12(sp),sp

	move.l	physical_screen,-(sp)
	move.l	#c_screen_size,-(sp)
	move.l	#0,-(sp)
	jsr	memset
	lea	12(sp),sp

	move.l	#particle1,-(sp)
	move.l	#c_particle1_height,-(sp)
	jsr		preshift_particle
	lea		8(sp),sp

	move.l	#particle2,-(sp)
	move.l	#c_particle2_height,-(sp)
	jsr		preshift_particle
	lea		8(sp),sp

	move.l	#particle3,-(sp)
	move.l	#c_particle3_height,-(sp)
	jsr		preshift_particle
	lea		8(sp),sp

	move.l	#particle4,-(sp)
	move.l	#c_particle4_height,-(sp)
	jsr		preshift_particle
	lea		8(sp),sp

	jsr		copy_particle1_data
	jsr		copy_particle2_data
	jsr		copy_particle3_data
	jsr		copy_particle4_data

	jsr		init_particle_stacks
	jsr		init_particle_xy_positions
	jsr		init_particle_screen_positions

	move.l	#200,d0
pre_run_loop
	move.l	d0,-(sp)
	jsr		run_particle_system
	move.l	(sp)+,d0
	dbra	d0,pre_run_loop

	; init screen position array pointers
	move.l	#particle1_screen_pos_array,particle1_screen_physical
	move.l	#particle1_screen_pos_array+c_particle1_array_size*4,particle1_screen_logical
	move.l	#particle2_screen_pos_array,particle2_screen_physical
	move.l	#particle2_screen_pos_array+c_particle2_array_size*4,particle2_screen_logical
	move.l	#particle3_screen_pos_array,particle3_screen_physical
	move.l	#particle3_screen_pos_array+c_particle3_array_size*4,particle3_screen_logical
	move.l	#particle4_screen_pos_array,particle4_screen_physical
	move.l	#particle4_screen_pos_array+c_particle4_array_size*4,particle4_screen_logical

	move.l	#vbl,$70.w	; install vbl handler
	ori.b	#1,$fffffa07.w	; enable timer b
	ori.b	#1,$fffffa13.w

	stop	#$2300
	clr.w	vbl_counter

; --------

main
	REPT	4500
;	nop
	ENDR

;	move.w	#$777,$ffff8240.w
	jsr		run_particle_system
;	move.w	#$0,$ffff8240.w
	
	move.l	#xpos_array,a5
	move.l	logical_screen,a6
	
;	move.w	#$700,$ffff8240.w
	jsr		clear_particle1_array
;	move.w	#$400,$ffff8240.w
	jsr		clear_particle2_array
;	move.w	#$200,$ffff8240.w
	jsr		clear_particle3_array
;	move.w	#$100,$ffff8240.w
	jsr		clear_particle4_array
;	move.w	#$070,$ffff8240.w	
	jsr		draw_particle1_array
;	move.w	#$040,$ffff8240.w	
	jsr		draw_particle2_array
;	move.w	#$020,$ffff8240.w	
	jsr		draw_particle3_array
;	move.w	#$010,$ffff8240.w
	jsr		draw_particle4_array
;	move.w	#$000,$ffff8240.w

	jsr		swap_particle_buffers

	jsr		swap_buffers
	move.l	physical_screen,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

.wait_for_vbl
	tst.w	vbl_counter
	beq.s	.wait_for_vbl
	clr.w	vbl_counter

	addq	#1,frame

	cmp.b	#$b9,$fffffc02.w	; wait for spacebar
	bne		main

exit
;	jsr		music+4
	jmp 	deinitialize

init_music
	moveq	#1,d0
;	jsr		music

	rts

; --------

vbl
	movem.l	d0-a6,-(sp)

	movem.l	pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.b	$fffffa1b.w		; disable timer B
	move.b 	#1,$fffffa21.w	; occur on the first line
	move.b	#8,$fffffa1b.w	; enable timer B
	move.l	#timer_b,$120.w	; timer B routine

	move.w	#0,timer_b_counter

;	clr.b	$fffffa1b.w		; disable timer B
;	move.b 	#199,$fffffa21.w	; occur on the last line
;	move.b	#8,$fffffa1b.w		; enable timer B
;	move.l	#lower,$120.w		; timer B routine

;	jsr		music+8

;	lea		logo_palettes,a0
;	add.l	logo_fade_adder,a0
;	movem.l	(a0),d0-d7
;	movem.l	d0-d7,$ffff8240.w

	add.w	#1,vbl_counter

	movem.l	(sp)+,d0-a6
	rte

timer_b
	movem.l	d0-d1/a0,-(sp)

	lea		bg_rasters,a0
	move.w	timer_b_counter,d0
	move.w	(a0,d0.w),$ffff8240.w
	addq	#2,d0
	move.w	d0,timer_b_counter

 	bclr	#0,$fffffa0f.w		; clear interrupt

	movem.l	(sp)+,d0-d1/a0
	rte

lower
	movem.l	d0/a1,-(sp)
	move	#$2700,sr			; time critical
	move.w	#$fa21,a1
	move.b	(a1),d0
.1	cmp.b	(a1),d0        		; wait last scanline
	beq		.1
	clr.b	$ffff820a.w    		; 60 Hz
	moveq	#3,d0
.2	nop                 		; wait a while
	dbf d0,.2
	move.b	#2,$ffff820a.w  	; 50 Hz
	movem.l	(sp)+,d0/a1
 	bclr	#0,$fffffa0f.w		; clear interrupt
	clr.b	$fffffa1b.w			; disable timer B

	rte

; --------

preshift_particle
	move.l	8(sp),a0	; base address
	move.l	8(sp),a1	; shift address
	
	move.l	4(sp),d0	; number of scanlines

	move.l	d0,d1		; offset shift address
	mulu.w	#8,d1
	add.l	d1,a1

	move.l	d0,d1
	mulu.w	#15,d1
	subq.l	#1,d1
.loop
	move.w	(a0),d3
	move.w	4(a0),d4
	roxr.w	d3
	roxr.w	d4
	move.w	d3,(a1)
	move.w	d4,4(a1)

	move.w	2(a0),d3
	move.w	6(a0),d4
	roxr.w	d3
	roxr.w	d4
	move.w	d3,2(a1)
	move.w	d4,6(a1)

	add.l	#8,a0
	add.l	#8,a1

	dbra	d1,.loop

	rts

; --------

copy_particle_data
	move.l	20(sp),a0	; source
	move.l	16(sp),a1	; destination
	move.l	12(sp),d0	; source delta
	move.l	8(sp),d1	; destination delta
	move.l	4(sp),d2	; count

	subq.l	#1,d2
.loop
	move.l	(a0),(a1)
	add.l	d0,a0
	add.l	d1,a1
	dbra	d2,.loop

	rts

; --------

particle1w	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*3+0(a0)
	ori.l	#0,160*4+0(a0)
	ori.l	#0,160*5+0(a0)
	ori.l	#0,160*6+0(a0)
	ori.l	#0,160*7+0(a0)
	ori.l	#0,160*8+0(a0)
	ori.l	#0,160*9+0(a0)
	ori.l	#0,160*10+0(a0)
	ori.l	#0,160*11+0(a0)
	jmp		draw_particle1_array_return
	ENDM

particle1l	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*0+8(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*1+8(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*2+8(a0)
	ori.l	#0,160*3+0(a0)
	ori.l	#0,160*3+8(a0)
	ori.l	#0,160*4+0(a0)
	ori.l	#0,160*4+8(a0)
	ori.l	#0,160*5+0(a0)
	ori.l	#0,160*5+8(a0)
	ori.l	#0,160*6+0(a0)
	ori.l	#0,160*6+8(a0)
	ori.l	#0,160*7+0(a0)
	ori.l	#0,160*7+8(a0)
	ori.l	#0,160*8+0(a0)
	ori.l	#0,160*8+8(a0)
	ori.l	#0,160*9+0(a0)
	ori.l	#0,160*9+8(a0)
	ori.l	#0,160*10+0(a0)
	ori.l	#0,160*10+8(a0)
	ori.l	#0,160*11+0(a0)
	ori.l	#0,160*11+8(a0)
	jmp		draw_particle1_array_return
	ENDM

particle2w	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*3+0(a0)
	ori.l	#0,160*4+0(a0)
	ori.l	#0,160*5+0(a0)
	ori.l	#0,160*6+0(a0)
	ori.l	#0,160*7+0(a0)
	ori.l	#0,160*8+0(a0)
	jmp		draw_particle2_array_return
	ENDM

particle2l	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*0+8(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*1+8(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*2+8(a0)
	ori.l	#0,160*3+0(a0)
	ori.l	#0,160*3+8(a0)
	ori.l	#0,160*4+0(a0)
	ori.l	#0,160*4+8(a0)
	ori.l	#0,160*5+0(a0)
	ori.l	#0,160*5+8(a0)
	ori.l	#0,160*6+0(a0)
	ori.l	#0,160*6+8(a0)
	ori.l	#0,160*7+0(a0)
	ori.l	#0,160*7+8(a0)
	ori.l	#0,160*8+0(a0)
	ori.l	#0,160*8+8(a0)
	jmp		draw_particle2_array_return
	ENDM

particle3w	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*3+0(a0)
	ori.l	#0,160*4+0(a0)
	ori.l	#0,160*5+0(a0)
	jmp		draw_particle3_array_return
	ENDM

particle3l	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*0+8(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*1+8(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*2+8(a0)
	ori.l	#0,160*3+0(a0)
	ori.l	#0,160*3+8(a0)
	ori.l	#0,160*4+0(a0)
	ori.l	#0,160*4+8(a0)
	ori.l	#0,160*5+0(a0)
	ori.l	#0,160*5+8(a0)
	jmp		draw_particle3_array_return
	ENDM

particle4w	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*2+0(a0)
	jmp		draw_particle4_array_return
	ENDM

particle4l	MACRO
	ori.l	#0,160*0+0(a0)
	ori.l	#0,160*0+8(a0)
	ori.l	#0,160*1+0(a0)
	ori.l	#0,160*1+8(a0)
	ori.l	#0,160*2+0(a0)
	ori.l	#0,160*2+8(a0)
	jmp		draw_particle4_array_return
	ENDM

draw_particle1_0
	particle1w
draw_particle1_1
	REPT	15
	particle1l
	ENDR

draw_particle1_0_left
	REPT	16
	particle1w
	ENDR

draw_particle1_0_right
	REPT	16
	particle1w
	ENDR

draw_particle2_0
	REPT	4
	particle2w
	ENDR
draw_particle2_4
	REPT	12
	particle2l
	ENDR

draw_particle2_0_left
	REPT	16
	particle2w
	ENDR

draw_particle2_0_right
	REPT	16
	particle2w
	ENDR

draw_particle3_0
	REPT	8
	particle3w
	ENDR
draw_particle3_8
	REPT	8
	particle3l
	ENDR

draw_particle3_0_left
	REPT	16
	particle3w
	ENDR

draw_particle3_0_right
	REPT	16
	particle3w
	ENDR

draw_particle4_0
	REPT	12
	particle4w
	ENDR
draw_particle4_12
	REPT	4
	particle4l
	ENDR

draw_particle4_0_left
	REPT	16
	particle4w
	ENDR
	
draw_particle4_0_right
	REPT	16
	particle4w
	ENDR

; --------

draw_particle1_array
	; screen pointer should be in a6	
	; x-position array should be in a5
 	moveq	#0,d2	
	move.l	d2,d3

	moveq	#c_particle1_array_size-1,d0	; array size
	move.l	#particle1_xy_pos_array,a2	; xy-position array
	move.l	particle1_screen_logical,a3	; screen position array
draw_particle1_array_loop
	move.l	a6,a0			; copy screen address to a0

	move.w	(a2)+,d1		; get x-position for sprite
	move.w	(a2)+,d2		; get y-position for sprite

	add.w	d1,d1			; make word aligned
	blt.s	draw_particle1_array_left	; check if x-position is negative

	cmp.w	#(319-16)*2,d1	; word aligned
	bgt.s	draw_particle1_array_right	; check if x-position is on the last word

	move.l	#particle1_ptr,a1

draw_particle1_array_blit
	add.w	(a5,d1.w),a0	; add x-position to screen address

draw_particle1_array_no_x_add_fetch
	add.w	d1,d1			; make dword aligned
	and.w	#$3c,d1			; mask x-position to 0-15, dword aligned

	add.l	d2,a0			; add y-position to screen address
	move.l	a0,(a3)+		; save screen position for clear rout

	move.l	(a1,d1.w),a4	; get the address of the sprite rout
	jmp		(a4)			; call sprite rout

draw_particle1_array_return
	dbra	d0,draw_particle1_array_loop

	rts

draw_particle1_array_left
	cmp.w	#-(c_particle1_width-1)*2,d1	; word aligned
	blt.s	draw_particle1_array_return	; x-position too small, skip draw

	add.w	#16*2,d1					; word aligned
	move.l	#particle1_ptr_left,a1
	bra.s	draw_particle1_array_no_x_add_fetch
	
draw_particle1_array_right
	cmp.w	#319*2,d1					; word aligned
	bgt.s	draw_particle1_array_return	; x-position too large, skip draw

	move.l	#particle1_ptr_right,a1
	bra.s	draw_particle1_array_blit
		
draw_particle2_array
	; screen pointer should be in a6	
	; x-position array should be in a5
 	moveq	#0,d2	
	move.l	d2,d3

	move.l	#c_particle2_array_size-1,d0	; array size
	move.l	#particle2_xy_pos_array,a2	; xy-position array
	move.l	particle2_screen_logical,a3	; screen position array
draw_particle2_array_loop
	move.l	a6,a0			; copy screen address to a0

	move.w	(a2)+,d1		; get x-position for sprite
	move.w	(a2)+,d2		; get y-position for sprite

	add.w	d1,d1			; make word aligned
	blt.s	draw_particle2_array_left	; check if x-position is negative

	cmp.w	#(319-16)*2,d1	; word aligned
	bgt.s	draw_particle2_array_right	; check if x-position is on the last word

	move.l	#particle2_ptr,a1

draw_particle2_array_blit
	add.w	(a5,d1.w),a0	; add x-position to screen address

draw_particle2_array_no_x_add_fetch
	add.w	d1,d1			; make dword aligned
	and.w	#$3c,d1			; mask x-position to 0-15, dword aligned

	add.l	d2,a0			; add y-position to screen address
	move.l	a0,(a3)+		; save screen position for clear rout

	move.l	(a1,d1.w),a4	; get the address of the sprite rout
	jmp		(a4)			; call sprite rout

draw_particle2_array_return
	dbra	d0,draw_particle2_array_loop

	rts

draw_particle2_array_left
	cmp.w	#-(c_particle2_width-1)*2,d1	; word aligned
	blt.s	draw_particle2_array_return	; x-position too small, skip draw

	add.w	#16*2,d1					; word aligned
	move.l	#particle2_ptr_left,a1
	bra.s	draw_particle2_array_no_x_add_fetch
	
draw_particle2_array_right
	cmp.w	#319*2,d1					; word aligned
	bgt.s	draw_particle2_array_return	; x-position too large, skip draw

	move.l	#particle2_ptr_right,a1
	bra.s	draw_particle2_array_blit

draw_particle3_array
	; screen pointer should be in a6	
	; x-position array should be in a5
 	moveq	#0,d2	
	move.l	d2,d3

	move.l	#c_particle3_array_size-1,d0	; array size
	move.l	#particle3_xy_pos_array,a2	; xy-position array
	move.l	particle3_screen_logical,a3	; screen position array
draw_particle3_array_loop
	move.l	a6,a0			; copy screen address to a0

	move.w	(a2)+,d1		; get x-position for sprite
	move.w	(a2)+,d2		; get y-position for sprite

	add.w	d1,d1			; make word aligned
	blt.s	draw_particle3_array_left	; check if x-position is negative

	cmp.w	#(319-16)*2,d1	; word aligned
	bgt.s	draw_particle3_array_right	; check if x-position is on the last word

	move.l	#particle3_ptr,a1

draw_particle3_array_blit
	add.w	(a5,d1.w),a0	; add x-position to screen address

draw_particle3_array_no_x_add_fetch
	add.w	d1,d1			; make dword aligned
	and.w	#$3c,d1			; mask x-position to 0-15, dword aligned

	add.l	d2,a0			; add y-position to screen address
	move.l	a0,(a3)+		; save screen position for clear rout

	move.l	(a1,d1.w),a4	; get the address of the sprite rout
	jmp		(a4)			; call sprite rout

draw_particle3_array_return
	dbra	d0,draw_particle3_array_loop

	rts

draw_particle3_array_left
	cmp.w	#-(c_particle3_width-1)*2,d1	; word aligned
	blt.s	draw_particle3_array_return	; x-position too small, skip draw

	add.w	#16*2,d1					; word aligned
	move.l	#particle3_ptr_left,a1
	bra.s	draw_particle3_array_no_x_add_fetch
	
draw_particle3_array_right
	cmp.w	#319*2,d1					; word aligned
	bgt.s	draw_particle3_array_return	; x-position too large, skip draw

	move.l	#particle3_ptr_right,a1
	bra.s	draw_particle3_array_blit

draw_particle4_array
	; screen pointer should be in a6	
	; x-position array should be in a5
 	moveq	#0,d2	
	move.l	d2,d3

	move.l	#c_particle4_array_size-1,d0	; array size
	move.l	#particle4_xy_pos_array,a2	; xy-position array
	move.l	particle4_screen_logical,a3	; screen position array
draw_particle4_array_loop
	move.l	a6,a0			; copy screen address to a0

	move.w	(a2)+,d1		; get x-position for sprite
	move.w	(a2)+,d2		; get y-position for sprite

	add.w	d1,d1			; make word aligned
	blt.s	draw_particle4_array_left	; check if x-position is negative

	cmp.w	#(319-16)*2,d1	; word aligned
	bgt.s	draw_particle4_array_right	; check if x-position is on the last word

	move.l	#particle4_ptr,a1

draw_particle4_array_blit
	add.w	(a5,d1.w),a0	; add x-position to screen address

draw_particle4_array_no_x_add_fetch
	add.w	d1,d1			; make dword aligned
	and.w	#$3c,d1			; mask x-position to 0-15, dword aligned

	add.l	d2,a0			; add y-position to screen address
	move.l	a0,(a3)+		; save screen position for clear rout

	move.l	(a1,d1.w),a4	; get the address of the sprite rout
	jmp		(a4)			; call sprite rout

draw_particle4_array_return
	dbra	d0,draw_particle4_array_loop

	rts

draw_particle4_array_left
	cmp.w	#-(c_particle4_width-1)*2,d1	; word aligned
	blt.s	draw_particle4_array_return	; x-position too small, skip draw

	add.w	#16*2,d1					; word aligned
	move.l	#particle4_ptr_left,a1
	bra.s	draw_particle4_array_no_x_add_fetch
	
draw_particle4_array_right
	cmp.w	#319*2,d1					; word aligned
	bgt.s	draw_particle4_array_return	; x-position too large, skip draw

	move.l	#particle4_ptr_right,a1
	bra.s	draw_particle4_array_blit

; --------

clear_particle1_array
	moveq	#c_particle1_array_size-1,d0
	moveq	#0,d1
	move.l	particle1_screen_logical,a0
.loop
	move.l	(a0)+,a1			; copy screen address

i	SET		0
	REPT	c_particle1_height
	move.l	d1,i(a1)
	move.l	d1,i+8(a1)
i	SET		i+160
	ENDR
	dbra	d0,.loop

	rts

clear_particle2_array
	moveq	#c_particle2_array_size-1,d0
	moveq	#0,d1
	move.l	particle2_screen_logical,a0
.loop
	move.l	(a0)+,a1			; copy screen address

i	SET		0
	REPT	c_particle2_height
	move.l	d1,i(a1)
	move.l	d1,i+8(a1)
i	SET		i+160
	ENDR
	dbra	d0,.loop

	rts

clear_particle3_array
	moveq	#c_particle3_array_size-1,d0
	moveq	#0,d1
	move.l	particle3_screen_logical,a0
.loop
	move.l	(a0)+,a1			; copy screen address

i	SET		0
	REPT	c_particle3_height
	move.l	d1,i(a1)
	move.l	d1,i+8(a1)
i	SET		i+160
	ENDR
	dbra	d0,.loop

	rts

clear_particle4_array
	moveq	#c_particle4_array_size-1,d0
	moveq	#0,d1
	move.l	particle4_screen_logical,a0
.loop
	move.l	(a0)+,a1			; copy screen address

i	SET		0
	REPT	c_particle4_height
	move.l	d1,i(a1)
	move.l	d1,i+8(a1)
i	SET		i+160
	ENDR
	dbra	d0,.loop

	rts

; --------

copy_particle1_data	
	; normal
	move.l	#particle1,-(sp)
	move.l	#draw_particle1_0+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle1_height,-(sp)
	jsr		copy_particle_data
	lea		20(sp),sp

	move.l	#particle1+2*2*2*c_particle1_height,-(sp)
	move.l	#draw_particle1_1+2,-(sp)
	move.l	#4,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle1_height*2,-(sp)
	jsr		copy_particle_data

	REPT	14
	add.l	#c_particle1_height*16+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle1_height,16(sp)
	jsr		copy_particle_data
	ENDR
	
	lea		20(sp),sp

	; left
	move.l	#particle1+4,-(sp)
	move.l	#draw_particle1_0_left+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle1_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle1_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle1_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	; right
	move.l	#particle1,-(sp)
	move.l	#draw_particle1_0_right+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle1_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle1_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle1_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	rts

copy_particle2_data
	; normal
	move.l	#particle2,-(sp)
	move.l	#draw_particle2_0+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle2_height,-(sp)
	jsr		copy_particle_data

	REPT	3
	add.l	#c_particle2_height*8+c_return_code_bytes,12(sp)	; 8 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle2_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	move.l	#particle2+2*2*2*c_particle2_height*4,-(sp)
	move.l	#draw_particle2_4+2,-(sp)
	move.l	#4,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle2_height*2,-(sp)
	jsr		copy_particle_data

	REPT	11
	add.l	#c_particle2_height*16+c_return_code_bytes,12(sp)	; 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle2_height,16(sp)
	jsr		copy_particle_data
	ENDR
	
	lea		20(sp),sp

	; left
	move.l	#particle2+4,-(sp)
	move.l	#draw_particle2_0_left+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle2_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle2_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle2_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	; right
	move.l	#particle2,-(sp)
	move.l	#draw_particle2_0_right+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle2_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle2_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle2_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	rts

copy_particle3_data
	; normal
	move.l	#particle3,-(sp)
	move.l	#draw_particle3_0+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle3_height,-(sp)
	jsr		copy_particle_data

	REPT	7
	add.l	#c_particle3_height*8+c_return_code_bytes,12(sp)	; 8 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle3_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	move.l	#particle3+2*2*2*c_particle3_height*8,-(sp)
	move.l	#draw_particle3_8+2,-(sp)
	move.l	#4,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle3_height*2,-(sp)
	jsr		copy_particle_data

	REPT	7
	add.l	#c_particle3_height*16+c_return_code_bytes,12(sp)	; 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle3_height,16(sp)
	jsr		copy_particle_data
	ENDR
	
	lea		20(sp),sp

	; left
	move.l	#particle3+4,-(sp)
	move.l	#draw_particle3_0_left+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle3_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle3_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle3_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	; right
	move.l	#particle3,-(sp)
	move.l	#draw_particle3_0_right+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle3_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle3_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle3_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	rts

copy_particle4_data
	; normal
	move.l	#particle4,-(sp)
	move.l	#draw_particle4_0+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle4_height,-(sp)
	jsr		copy_particle_data

	REPT	11
	add.l	#c_particle4_height*8+c_return_code_bytes,12(sp)	; 8 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle4_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	move.l	#particle4+2*2*2*c_particle4_height*12,-(sp)
	move.l	#draw_particle4_12+2,-(sp)
	move.l	#4,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle4_height*2,-(sp)
	jsr		copy_particle_data

	REPT	3
	add.l	#c_particle4_height*16+c_return_code_bytes,12(sp)	; 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle4_height,16(sp)
	jsr		copy_particle_data
	ENDR
	
	lea		20(sp),sp

	; left
	move.l	#particle4+4,-(sp)
	move.l	#draw_particle4_0_left+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle4_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle4_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle4_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	; right
	move.l	#particle4,-(sp)
	move.l	#draw_particle4_0_right+2,-(sp)
	move.l	#8,-(sp)
	move.l	#8,-(sp)
	move.l	#c_particle4_height,-(sp)
	jsr		copy_particle_data

	REPT	15
	add.l	#c_particle4_height*8+c_return_code_bytes,12(sp)	; 12 lines, 16 bytes each line, +2 bytes for rts 
	add.l	#2*2*2*c_particle4_height,16(sp)
	jsr		copy_particle_data
	ENDR

	lea		20(sp),sp

	rts

; --------

swap_particle_buffers
	move.l	particle1_screen_logical,d0
	move.l	particle1_screen_physical,particle1_screen_logical
	move.l  d0,particle1_screen_physical

	move.l	particle2_screen_logical,d0
	move.l	particle2_screen_physical,particle2_screen_logical
	move.l  d0,particle2_screen_physical

	move.l	particle3_screen_logical,d0
	move.l	particle3_screen_physical,particle3_screen_logical
	move.l  d0,particle3_screen_physical

	move.l	particle4_screen_logical,d0
	move.l	particle4_screen_physical,particle4_screen_logical
	move.l  d0,particle4_screen_physical

	rts

; --------

init_particle_stacks
	moveq	#c_particle1_array_size-1,d0
	move.l	#particle1_xy_pos_array,d1
	move.l	#particle1_stack,a1
.particle1_loop
	move.l	d1,(a1)+
	add.l	#4,d1
	dbra	d0,.particle1_loop	
		
	moveq	#c_particle2_array_size-1,d0
	move.l	#particle2_xy_pos_array,d1
	move.l	#particle2_stack,a1
.particle2_loop
	move.l	d1,(a1)+
	add.l	#4,d1
	dbra	d0,.particle2_loop	
		
	moveq	#c_particle3_array_size-1,d0
	move.l	#particle3_xy_pos_array,d1
	move.l	#particle3_stack,a1
.particle3_loop
	move.l	d1,(a1)+
	add.l	#4,d1
	dbra	d0,.particle3_loop	

	moveq	#c_particle4_array_size-1,d0
	move.l	#particle4_xy_pos_array,d1
	move.l	#particle4_stack,a1
.particle4_loop
	move.l	d1,(a1)+
	add.l	#4,d1
	dbra	d0,.particle4_loop	
		
	rts

init_particle_xy_positions
	moveq	#c_particle1_array_size-1,d0
	move.l	#particle1_xy_pos_array,a0
.particle1_loop
	move.w	#-16,(a0)+	; x-position outside screen
	move.w	#-160,(a0)+	; y-position outside screen
	dbra	d0,.particle1_loop

	moveq	#c_particle2_array_size-1,d0
	move.l	#particle2_xy_pos_array,a0
.particle2_loop
	move.w	#-16,(a0)+	; x-position outside screen
	move.w	#-160,(a0)+	; y-position outside screen
	dbra	d0,.particle2_loop

	moveq	#c_particle3_array_size-1,d0
	move.l	#particle3_xy_pos_array,a0
.particle3_loop
	move.w	#-16,(a0)+	; x-position outside screen
	move.w	#-160,(a0)+	; y-position outside screen
	dbra	d0,.particle3_loop

	moveq	#c_particle4_array_size-1,d0
	move.l	#particle4_xy_pos_array,a0
.particle4_loop
	move.w	#-16,(a0)+	; x-position outside screen
	move.w	#-160,(a0)+	; y-position outside screen
	dbra	d0,.particle4_loop

	rts
	
init_particle_screen_positions
	moveq	#c_particle1_array_size-1,d0
	move.l	#particle1_screen_pos_array,a0
.particle1_loop
	move.l	logical_screen,c_particle1_array_size*4(a0)
	move.l	physical_screen,(a0)+
	dbra	d0,.particle1_loop

	moveq	#c_particle2_array_size-1,d0
	move.l	#particle2_screen_pos_array,a0
.particle2_loop
	move.l	logical_screen,c_particle2_array_size*4(a0)
	move.l	physical_screen,(a0)+
	dbra	d0,.particle2_loop

	moveq	#c_particle3_array_size-1,d0
	move.l	#particle3_screen_pos_array,a0
.particle3_loop
	move.l	logical_screen,c_particle3_array_size*4(a0)
	move.l	physical_screen,(a0)+
	dbra	d0,.particle3_loop

	moveq	#c_particle4_array_size-1,d0
	move.l	#particle4_screen_pos_array,a0
.particle4_loop
	move.l	logical_screen,c_particle4_array_size*4(a0)
	move.l	physical_screen,(a0)+
	dbra	d0,.particle4_loop

	rts

; --------

run_particle_system
	jsr		move_particle1_particles
	jsr		move_particle2_particles
	jsr		move_particle3_particles
	jsr		move_particle4_particles

	subq	#1,particle_counter
	bgt		.exit

	move.w	#c_particle_spawn_freq,particle_counter

	lea		x_spawn_random_table,a0		; get new x-position
	move.w	spawn_random_counter,d0		;

	move.l	seed(pc),d1					; create random value
	add.l	d1,d1
	bcc.s	.done
	eori.b	#$af,d1
	
.done
	move.l	d1,seed

	and.w	#3,d1						; mask value
	beq.s	.first

	cmp.w	#1,d1
	beq.s	.second

	cmp.w	#2,d1
	beq.s	.third
	
	lea		particle4_stack_pos,a1
	lea		particle4_stack,a2
	bra.s	.continue

.third
	lea		particle3_stack_pos,a1
	lea		particle3_stack,a2
	bra.s	.continue
	
.second
	lea		particle2_stack_pos,a1
	lea		particle2_stack,a2
	bra.s	.continue

.first
	lea		particle1_stack_pos,a1
	lea		particle1_stack,a2

.continue
	move.w	(a1),d2
	cmp.w	#0,d2					; check if the stack has slots
	blt.w	.exit					; no slots left

	move.l	(a2,d2.w),a2			; address of particle in array

	subq	#4,d2					; remove slot from stack
	move.w	d2,(a1)					;

	move.w	(a0,d0.w),d1			; get new x-position

	move.w	d1,(a2)+				; set x-position for particle
;	move.w	#(216-c_particle1_height)*160,(a2)+	; set y-position
	move.w	#(200-c_particle1_height)*160,(a2)+	; set y-position
	
	addq	#2,d0					; advance random counter
	and.w	#(c_random_xtable_size-1)*2,d0
	move.w	d0,spawn_random_counter	;
	
.exit
	rts

move_particle1_particles
	moveq	#c_particle1_array_size-1,d0
	lea		particle1_xy_pos_array,a0
	lea		particle1_stack,a1
	lea		x_move_random_table,a2
	move.w	move_random_counter,d3
.loop
	move.w	2(a0),d2				; y-position

	cmp.w	#0,d2					; check if sprite is already outside
	blt.w	.next					;

	sub.w	#160*4,d2				; move vertical
	blt.w	.outside

	move.w	(a0),d1					; move horizontal
	add.w	(a2,d3.w),d1			;

	addq	#2,d3					; advance random counter
	and.w	#(c_random_xtable_size-1)*2,d3

	move.w	d1,(a0)					; save new x-position
	move.w	d2,2(a0)				; save new y-position

.next
	addq	#4,a0					; move to next particle
	dbra	d0,.loop

	move.w	d3,move_random_counter	; save random counter

	rts

.outside
	move.w	#-16,(a0)				; move particle outside the screen
	move.w	d2,2(a0)				;

	move.w	particle1_stack_pos,d1	; return particle to the stack
	addq	#4,d1					;
	move.l	a0,(a1,d1.w)			;
	move.w	d1,particle1_stack_pos	; add new stack slot
	
	bra.s	.next

move_particle2_particles
	moveq	#c_particle2_array_size-1,d0
	lea		particle2_xy_pos_array,a0
	lea		particle2_stack,a1
	lea		x_move_random_table,a2
	move.w	move_random_counter,d3
.loop
	move.w	2(a0),d2				; y-position

	cmp.w	#0,d2					; check if sprite is already outside
	blt.w	.next					;

	sub.w	#160*3,d2				; move vertical
	blt.w	.outside

	move.w	(a0),d1					; move horizontal
	add.w	(a2,d3.w),d1			;

	addq	#2,d3					; advance random counter
	and.w	#(c_random_xtable_size-1)*2,d3

	move.w	d1,(a0)					; save new x-position
	move.w	d2,2(a0)				; save new y-position

.next
	addq	#4,a0					; move to next particle
	dbra	d0,.loop

	move.w	d3,move_random_counter	; save random counter

	rts

.outside
	move.w	#-16,(a0)				; move particle outside the screen
	move.w	d2,2(a0)				;

	move.w	particle2_stack_pos,d1	; return particle to the stack
	addq	#4,d1					;
	move.l	a0,(a1,d1.w)			;
	move.w	d1,particle2_stack_pos	; add new stack slot
	
	bra.s	.next


move_particle3_particles
	moveq	#c_particle3_array_size-1,d0
	lea		particle3_xy_pos_array,a0
	lea		particle3_stack,a1
	lea		x_move_random_table,a2
	move.w	move_random_counter,d3
.loop
	move.w	2(a0),d2				; y-position

	cmp.w	#0,d2					; check if sprite is already outside
	blt.w	.next					;

	sub.w	#160*2,d2				; move vertical
	blt.w	.outside

	move.w	(a0),d1					; move horizontal
	add.w	(a2,d3.w),d1			;

	addq	#2,d3					; advance random counter
	and.w	#(c_random_xtable_size-1)*2,d3

	move.w	d1,(a0)					; save new x-position
	move.w	d2,2(a0)				; save new y-position

.next
	addq	#4,a0					; move to next particle
	dbra	d0,.loop

	move.w	d3,move_random_counter	; save random counter

	rts

.outside
	move.w	#-16,(a0)				; move particle outside the screen
	move.w	d2,2(a0)				;

	move.w	particle3_stack_pos,d1	; return particle to the stack
	addq	#4,d1					;
	move.l	a0,(a1,d1.w)			;
	move.w	d1,particle3_stack_pos	; add new stack slot
	
	bra.s	.next

move_particle4_particles
	moveq	#c_particle4_array_size-1,d0
	lea		particle4_xy_pos_array,a0
	lea		particle4_stack,a1
	lea		x_move_random_table,a2
	move.w	move_random_counter,d3
.loop
	move.w	2(a0),d2				; y-position

	cmp.w	#0,d2					; check if sprite is already outside
	blt.w	.next					;

	sub.w	#160,d2					; move vertical
	blt.w	.outside

	move.w	(a0),d1					; move horizontal
	add.w	(a2,d3.w),d1			;

	addq	#2,d3					; advance random counter
	and.w	#(c_random_xtable_size-1)*2,d3

	move.w	d1,(a0)					; save new x-position
	move.w	d2,2(a0)				; save new y-position

.next
	addq	#4,a0					; move to next particle
	dbra	d0,.loop

	move.w	d3,move_random_counter	; save random counter

	rts

.outside
	move.w	#-16,(a0)				; move particle outside the screen
	move.w	d2,2(a0)				;

	move.w	particle4_stack_pos,d1	; return particle to the stack
	addq	#4,d1					;
	move.l	a0,(a1,d1.w)			;
	move.w	d1,particle4_stack_pos	; add new stack slot
	
	bra.s	.next

; --------

;fix_bottom_palette
;	move.l	#bottom+(4*2),-(sp)
;	move.l	#bottom+((4+8)*2),-(sp)
;	move.l	#$777,-(sp)
;	move.l	#8,-(sp)
;	move.w	#4000,-(sp)
;	jsr		fade_palette
;	lea		18(sp),sp
;	rts

	INCLUDE	c:\sources\lib.s

; *** DATA ***

	DATA

	EVEN

seed	dc.l	$12345678

frame				dc.l	0
timer_b_counter		dc.w	0

particle_counter	dc.w	0
spawn_random_counter	dc.w	0
move_random_counter		dc.w	0

;logo_palettes	dcb.w	(c_logo_fade_frames*16)-4	; -4 words of obj data
;bottom_palettes	dcb.w	(c_bottom_fade_frames*16)-4	; -4 words of obj data

black_pal	dcb.w	$16,$000
pal			dc.w	$000,$aaa,$ccc,$fff,$700,$700,$700,$700
			dc.w	$700,$700,$700,$700,$700,$700,$700,$700

rast	MACRO
	dc.w	\1,\1,\1,\1,\1,\1,\2,\1
	ENDM
	
bg_rasters
	rast	$47f,$bef
	rast	$bef,$36f
	rast	$36f,$adf
	rast	$adf,$25f
	rast	$25f,$9cf
	rast	$9cf,$14f
	rast	$14f,$1bf
	rast	$8bf,$03f
	rast	$03f,$0af
	rast	$0af,$02f
	rast	$02f,$09f
	rast	$09f,$017
	rast	$017,$08e
	rast	$08e,$006
	rast	$006,$00d
	rast	$00d,$005
	rast	$005,$00c
	rast	$00c,$004
	rast	$004,$00b
	rast	$00b,$003
	rast	$003,$00a
	rast	$00a,$002
	rast	$002,$009
	rast	$009,$001
	rast	$001,$008
	rast	$008,$000
	rast	$000,$000

x_spawn_random_table	INCBIN	xspwnrnd.bin
x_move_random_table		INCBIN	xmovernd.bin

particle1	INCBIN	bubble1.bin
			dcb.w	2*2*c_particle1_height*15
particle2	INCBIN	bubble2.bin
			dcb.w	2*2*c_particle2_height*15
particle3	INCBIN	bubble3.bin
			dcb.w	2*2*c_particle3_height*15
particle4	INCBIN	bubble4.bin
			dcb.w	2*2*c_particle4_height*15

particle1_stack_pos	dc.w	(c_particle1_array_size-1)*4
particle2_stack_pos	dc.w	(c_particle2_array_size-1)*4
particle3_stack_pos	dc.w	(c_particle3_array_size-1)*4
particle4_stack_pos	dc.w	(c_particle4_array_size-1)*4

xpos_array
i	SET		0
	REPT	320
	dc.w	(i/16)*8
i	SET		i+1
	ENDR

	EVEN

particle1_ptr
	dc.l	draw_particle1_0
i	SET		0
	REPT 	15
	dc.l	draw_particle1_1+i
i	SET		i+(c_particle1_height*16+c_return_code_bytes)
	ENDR

particle1_ptr_left
i	SET		0
	REPT 	16
	dc.l	draw_particle1_0_left+i
i	SET		i+(c_particle1_height*8+c_return_code_bytes)
	ENDR

particle1_ptr_right
i	SET		0
	REPT 	16
	dc.l	draw_particle1_0_right+i
i	SET		i+(c_particle1_height*8+c_return_code_bytes)
	ENDR

particle2_ptr
i	SET		0
	REPT 	4
	dc.l	draw_particle2_0+i
i	SET		i+(c_particle2_height*8+c_return_code_bytes)
	ENDR
i	SET		0
	REPT 	12
	dc.l	draw_particle2_4+i
i	SET		i+(c_particle2_height*16+c_return_code_bytes)
	ENDR

particle2_ptr_left
i	SET		0
	REPT 	16
	dc.l	draw_particle2_0_left+i
i	SET		i+(c_particle2_height*8+c_return_code_bytes)
	ENDR

particle2_ptr_right
i	SET		0
	REPT 	16
	dc.l	draw_particle2_0_right+i
i	SET		i+(c_particle2_height*8+c_return_code_bytes)
	ENDR

particle3_ptr
i	SET		0
	REPT 	8
	dc.l	draw_particle3_0+i
i	SET		i+(c_particle3_height*8+c_return_code_bytes)
	ENDR
i	SET		0
	REPT 	8
	dc.l	draw_particle3_8+i
i	SET		i+(c_particle3_height*16+c_return_code_bytes)
	ENDR

particle3_ptr_left
i	SET		0
	REPT 	16
	dc.l	draw_particle3_0_left+i
i	SET		i+(c_particle3_height*8+c_return_code_bytes)
	ENDR

particle3_ptr_right
i	SET		0
	REPT 	16
	dc.l	draw_particle3_0_right+i
i	SET		i+(c_particle3_height*8+c_return_code_bytes)
	ENDR

particle4_ptr
i	SET		0
	REPT 	12
	dc.l	draw_particle4_0+i
i	SET		i+(c_particle4_height*8+c_return_code_bytes)
	ENDR
i	SET		0
	REPT 	4
	dc.l	draw_particle4_12+i
i	SET		i+(c_particle4_height*16+c_return_code_bytes)
	ENDR

particle4_ptr_left
i	SET		0
	REPT 	16
	dc.l	draw_particle4_0_left+i
i	SET		i+(c_particle4_height*8+c_return_code_bytes)
	ENDR

particle4_ptr_right
i	SET		0
	REPT 	16
	dc.l	draw_particle4_0_right+i
i	SET		i+(c_particle4_height*8+c_return_code_bytes)
	ENDR

;music	INCBIN	sv2011nt.snd
	EVEN

; *** BSS ***

	BSS

	EVEN
	
particle1_stack	ds.l	c_particle1_array_size
particle2_stack	ds.l	c_particle2_array_size
particle3_stack	ds.l	c_particle3_array_size
particle4_stack	ds.l	c_particle4_array_size

particle1_xy_pos_array	ds.w	c_particle1_array_size*2	; (x,y)
particle2_xy_pos_array	ds.w	c_particle2_array_size*2
particle3_xy_pos_array	ds.w	c_particle3_array_size*2
particle4_xy_pos_array	ds.w	c_particle4_array_size*2

particle1_screen_pos_array	ds.l	c_particle1_array_size*2	; 2 frames
particle2_screen_pos_array	ds.l	c_particle2_array_size*2
particle3_screen_pos_array	ds.l	c_particle3_array_size*2
particle4_screen_pos_array	ds.l	c_particle4_array_size*2

particle1_screen_physical	ds.l	1
particle1_screen_logical	ds.l	1
particle2_screen_physical	ds.l	1
particle2_screen_logical	ds.l	1
particle3_screen_physical	ds.l	1
particle3_screen_logical	ds.l	1
particle4_screen_physical	ds.l	1
particle4_screen_logical	ds.l	1

screen_buffer
	ds.w	256
	ds.b	c_screen_size
	ds.w	256
	ds.b	c_screen_size

	EVEN
