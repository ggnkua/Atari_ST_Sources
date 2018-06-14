; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;          - Foxenstein -
;    a NoCrew production MCMXCV
;
;    (c) Copyright NoCrew 1995
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; DSP 56001 module.

CAMERA_W	equ	0.02	; camera width
CAMERA_H	equ	0.01	; camera height
CAMERA_D	equ	0.02	; camera distance

MAX_WALLS	equ	300
	include	"equates.asm"
	include	"dsp_io.equ"

WS_SIZE	equ	11
W_SIZE	equ	7

	org	Y:8192
sin	ds	1024

	org	X:$0
o_a	dc	0	; observer angle
o_x	dc	0.020	; observer x coordinate
o_y	dc	0.010	; observer y coordinate
o_z	dc	-0.020	; observer z coordiante

screen_w	dc	320
screen_h	dc	200
real_screen_w	dc	320
real_screen_h	dc	200
screen_cw	ds	1	; calculated screen constants
screen_ch	ds	1	; calculated screen constants

key	ds	1

tmp_wall
tmp_x0	ds	1
tmp_z0	ds	1
tmp_x1	ds	1
tmp_z1	ds	1
tmp_y0u	ds	1
tmp_y0l	ds	1
tmp_y1u	ds	1
tmp_y1l	ds	1
tmp_y0	ds	1
tmp_y1	ds	1
tmp_toffs	ds	1	; texture offset

alpha_0	ds	1
alpha_1	ds	1
omega	ds	1
omega_0	ds	1
omega_1	ds	1
delta_omega	ds	1

blocking	ds	1

wall	ds	1
wall_z	ds	1
delta_x	ds	1
delta_y	ds	1
delta_ry	ds	1
delta_z	ds	1

draw_z	ds	1
draw_y0	ds	1
draw_y1	ds	1
draw_wall	ds	1
draw_screen	ds	1
draw_texture	ds	1
draw_toffs	ds	1	; texture offset
draw_height	ds	1
draw_yinc	ds	1

N_KEYS	equ	8
key_convert	dc	$4b	; arrow left
	dc	$4d	; arrow right
	dc	$48	; arrow up
	dc	$50	; arrow down
	dc	$4e	; numeric '+'
	dc	$4a	; numeric '-'
	dc	$52	; insert
	dc	$47	; clr/home
keys	ds	1

n_map	dc	113
n_walls	ds	1

n_blitter	ds	1
blitter	ds	960
map	;	   x0,   z0,    x1,   z1, color
	dc	0.000,0.000,0.000,0.040,0.020,0.00,0	; 1 1st wall
	dc	0.000,0.040,0.000,0.080,0.020,0.00,0	; 2 section
	dc	0.000,0.080,0.000,0.120,0.020,0.00,0	; 3
	dc	0.000,0.120,-0.020,0.160,0.020,0.00,0	; 4
	dc	-0.020,0.160,-0.020,0.200,0.020,0.00,0	; 5
	dc	-0.020,0.200,0.000,0.240,0.020,0.00,0	; 6
	dc	0.000,0.240,0.000,0.280,0.020,0.00,0	; 7
	dc	0.000,0.280,0.000,0.320,0.020,0.00,0	; 8
	dc	0.000,0.320,0.000,0.360,0.020,0.00,0	; 9
	dc	0.000,0.360,0.000,0.400,0.020,0.00,0	; 10
	;
	dc	0.040,0.000,0.040,0.040,0.020,0.00,0	;   2nd wall
	dc	0.040,0.080,0.040,0.120,0.020,0.00,0	;   section
	dc	0.040,0.120,0.040,0.160,0.020,0.00,0	; 
	dc	0.040,0.200,0.040,0.240,0.020,0.00,0	; 
	dc	0.040,0.240,0.040,0.280,0.020,0.00,0	; 
	dc	0.040,0.280,0.040,0.320,0.020,0.00,0	; 
	;
	dc	0.080,0.120,0.080,0.160,0.020,0.00,0	; 
	dc	0.080,0.160,0.080,0.200,0.020,0.00,0	; 
	dc	0.080,0.200,0.080,0.240,0.020,0.00,0	; 
	dc	0.080,0.240,0.080,0.280,0.020,0.00,0	; 
	dc	0.080,0.320,0.080,0.360,0.020,0.00,0	; 
	;
	dc	0.120,0.160,0.120,0.200,0.020,0.00,0	; 
	dc	0.120,0.280,0.120,0.320,0.020,0.00,0	; 
	;
	dc	0.160,0.000,0.160,0.040,0.020,0.00,0	; 
	dc	0.160,0.040,0.160,0.080,0.020,0.00,0	; 
	;
	dc	0.200,0.080,0.200,0.120,0.020,0.00,0	; 
	dc	0.200,0.120,0.200,0.160,0.020,0.00,0	; 
	dc	0.200,0.160,0.200,0.200,0.020,0.00,0	; 
	dc	0.200,0.200,0.200,0.240,0.020,0.00,0	; 
	;
	dc	0.240,0.040,0.240,0.080,0.020,0.00,0	; 
	dc	0.240,0.160,0.240,0.200,0.020,0.00,0	; 
	;
	dc	0.280,0.120,0.280,0.160,0.020,0.00,0	; 
	dc	0.280,0.160,0.280,0.200,0.020,0.00,0	; 
	dc	0.280,0.200,0.280,0.240,0.020,0.00,0	; 
	dc	0.280,0.240,0.280,0.280,0.020,0.00,0	; 
	;
	dc	0.320,0.120,0.320,0.160,0.020,0.00,0	; 
	dc	0.320,0.200,0.320,0.240,0.020,0.00,0	; 
	dc	0.320,0.240,0.320,0.280,0.020,0.00,0	; 
	dc	0.320,0.280,0.320,0.320,0.020,0.00,0	; 
	;
	dc	0.360,0.040,0.360,0.080,0.020,0.00,0	; 
	dc	0.360,0.080,0.360,0.120,0.020,0.00,0	; 
	dc	0.360,0.160,0.360,0.200,0.020,0.00,0	; 
	dc	0.360,0.360,0.360,0.400,0.020,0.00,0	; 
	;
	dc	0.400,0.000,0.400,0.040,0.020,0.00,0	; 
	dc	0.400,0.040,0.400,0.080,0.020,0.00,0	; 
	dc	0.400,0.080,0.400,0.120,0.020,0.00,0	; 
	dc	0.400,0.120,0.400,0.160,0.020,0.00,0	; 
	dc	0.400,0.160,0.400,0.200,0.020,0.00,0	; 
	dc	0.400,0.200,0.400,0.240,0.020,0.00,0	; 
	dc	0.400,0.240,0.400,0.280,0.020,0.00,0	; 
	dc	0.400,0.280,0.400,0.320,0.020,0.00,0	; 
	dc	0.400,0.320,0.400,0.360,0.020,0.00,0	; 
	dc	0.400,0.360,0.400,0.400,0.020,0.00,0	; 
	;
	dc	0.040,0.000,0.080,0.000,0.020,0.00,0	; 1st vertical
	dc	0.080,0.000,0.120,0.000,0.020,0.00,0	; section
	dc	0.120,0.000,0.160,0.000,0.020,0.00,0
	dc	0.160,0.000,0.200,0.000,0.020,0.00,0
	dc	0.200,0.000,0.240,0.000,0.020,0.00,0
	dc	0.240,0.000,0.280,0.000,0.020,0.00,0
	dc	0.280,0.000,0.320,0.000,0.020,0.00,0
	dc	0.320,0.000,0.360,0.000,0.020,0.00,0
	dc	0.360,0.000,0.400,0.000,0.020,0.00,0
	;
	dc	0.040,0.040,0.080,0.040,0.020,0.00,1	; 
	dc	0.120,0.040,0.080,0.040,0.020,0.00,1	; 
	dc	0.200,0.040,0.240,0.040,0.020,0.00,0	; 
	dc	0.240,0.040,0.280,0.040,0.020,0.00,0	; 
	dc	0.280,0.040,0.320,0.040,0.020,0.00,0	; 
	dc	0.320,0.040,0.360,0.040,0.020,0.00,0	; 
	;
	dc	0.040,0.080,0.080,0.080,0.020,0.00,0	; 
	dc	0.080,0.080,0.120,0.080,0.020,0.00,0	; 
	dc	0.120,0.080,0.160,0.080,0.020,0.00,0	; 
	dc	0.160,0.080,0.200,0.080,0.020,0.00,0	; 
	;
	dc	0.080,0.120,0.120,0.120,0.020,0.00,0	; 
	dc	0.120,0.120,0.160,0.120,0.020,0.00,0	; 
	dc	0.240,0.120,0.280,0.120,0.020,0.00,0	; 
	dc	0.280,0.120,0.320,0.120,0.020,0.00,0	; 
	dc	0.320,0.120,0.360,0.120,0.020,0.00,0	; 
	;
	dc	0.120,0.200,0.160,0.200,0.020,0.00,0	; 
	dc	0.200,0.200,0.240,0.200,0.020,0.00,0	; 
	dc	0.320,0.200,0.360,0.200,0.020,0.00,0	; 
	;
	dc	0.080,0.240,0.120,0.240,0.020,0.00,0	; 
	dc	0.160,0.240,0.200,0.240,0.020,0.00,0	; 
	dc	0.200,0.240,0.240,0.240,0.020,0.00,0	; 
	dc	0.320,0.240,0.360,0.240,0.020,0.00,0	; 
	dc	0.360,0.240,0.400,0.240,0.020,0.00,0	; 
	;
	dc	0.080,0.280,0.120,0.280,0.020,0.00,0	; 
	dc	0.120,0.280,0.160,0.280,0.020,0.00,0	; 
	dc	0.160,0.280,0.200,0.280,0.020,0.00,0	; 
	dc	0.200,0.280,0.240,0.280,0.020,0.00,0	; 
	dc	0.240,0.280,0.280,0.280,0.020,0.00,0	; 
	;
	dc	0.040,0.320,0.080,0.320,0.020,0.00,0	; 
	dc	0.080,0.320,0.120,0.320,0.020,0.00,0	; 
	dc	0.120,0.320,0.160,0.320,0.020,0.00,0	; 
	dc	0.160,0.320,0.200,0.320,0.020,0.00,0	; 
	dc	0.240,0.320,0.280,0.320,0.020,0.00,0	; 
	dc	0.280,0.320,0.320,0.320,0.020,0.00,0	; 
	;
	dc	0.000,0.360,0.040,0.360,0.020,0.00,0	; 
	dc	0.080,0.360,0.120,0.360,0.020,0.00,0	; 
	dc	0.120,0.360,0.160,0.360,0.020,0.00,0	; 
	dc	0.160,0.360,0.200,0.360,0.020,0.00,0	; 
	dc	0.200,0.360,0.240,0.360,0.020,0.00,0	; 
	dc	0.240,0.360,0.280,0.360,0.020,0.00,0	; 
	dc	0.280,0.360,0.320,0.360,0.020,0.00,0	; 
	dc	0.320,0.360,0.360,0.360,0.020,0.00,0	; 
	;
	dc	0.000,0.400,0.040,0.400,0.020,0.00,0	; 
	dc	0.040,0.400,0.080,0.400,0.020,0.00,0	; 
	dc	0.080,0.400,0.120,0.400,0.020,0.00,0	; 
	dc	0.120,0.400,0.160,0.400,0.020,0.00,0	; 
	dc	0.160,0.400,0.200,0.400,0.020,0.00,0	; 
	dc	0.200,0.400,0.240,0.400,0.020,0.00,0	; 
	dc	0.240,0.400,0.280,0.400,0.020,0.00,0	; 
	dc	0.280,0.400,0.320,0.400,0.020,0.00,0	; 
	dc	0.320,0.400,0.360,0.400,0.020,0.00,0	; 
	;
walls	ds	9*MAX_WALLS

	org	P:$40
start	jmp	_nixen
	jsr	<make_walls
	jsr	<send_walls
_hang	jmp	_hang
_nixen	move	#-1,m0	; Set all modifier 
	move	#-1,m1	; to Linear (Modulo 65536)
	move	#-1,m2
	move	#-1,m3
	move	#-1,m4
	move	#-1,m5
	move	#-1,m6
	move	#-1,m7

	andi	#$fb,omr
	movep	x:<<M_HRX,x0	; Clear host port
	movep	#%0000000000000000,x:<<M_PCD
	movep	#%0000000101100000,x:<<M_PCDDR
	movep	#%0100000000000000,x:<<M_CRA
	movep	#%0001011000010000,x:<<M_CRB
	movep	#%0000000101000000,x:<<M_PCC

	move	#>CPU_SYNC,x0
	jsr	<send_host

	move	#sin,r0
	do	#1024,_sin
	jsr	<recv_host
	move	x0,Y:(r0)+
_sin	nop

	move	#blitter,r0
	jsr	<recv_host
	move	x0,X:<n_blitter
	do	x0,_blitter
	jsr	<recv_host
	move	x0,A
	rep	#8
	lsl	A
	move	A,X:(r0)+
_blitter	nop

	clr	A
	move	A,X:<keys
	jsr	recv_host
	move	x0,X:<screen_w
	jsr	recv_host
	move	x0,X:<screen_h
	jsr	recv_host
	move	x0,X:<real_screen_w
	jsr	recv_host
	move	x0,X:<real_screen_h
	jsr	calc_screen

main	move	#>CPU_SYNC,x0
	jsr	<send_host

	jsr	<command
	jsr	<get_key
	jsr	<make_walls
	jsr	<send_walls
	jmp	<main

send_walls	move	#0,r3	; x counter
	move	#WS_SIZE,n0

	clr	A
	move	A,X:<blocking
	do	X:<screen_w,_next_x
	move	X:<n_walls,A
	tst	A	; jump if there's no walls
	jeq	<_next_wall
	move	#walls,r0
	clr	A
	move	A,X:<blocking
	do	X:<n_walls,_next_wall
	move	r0,r1
	nop
	move	X:(r1)+,A	; read delta x
	tst	A
	jeq	<_not_active
	move	r3,x0
	move	X:(r1)+,B	; read current x
	cmp	x0,B
	jne	<_not_active

	move	r0,r2
	move	#>1,x0
	sub	x0,A
	move	A,X:(r2)+	; write delta x
	add	x0,B
	move	B,X:(r2)+	; write x

	move	X:(r1)+,A	; read omega
	move	A,X:<omega
	move	X:(r1)+,x0	; read delta omega
	add	x0,A
	move	A,X:(r2)+	; write omega

	move	X:(r1)+,x0	; read wall #
	move	x0,X:<wall

	move	X:<omega,y0
	move	X:(r1)+,A	; y0
	move	X:(r1)+,x0	; delta y0
	macr	x0,y0,A	; new y0
	move	X:(r1)+,B	; y1
	move	X:(r1)+,x0	; delta y1
	macr	x0,y0,B	; new y1

	move	A,y0
	move	B,y1
	move	X:<screen_h,A
	asr	A
	move	A,B
	sub	y0,A
	sub	y1,B

	sub	A,B B,X:<tmp_y1
	move	B,x1
	move	x1,X:<delta_ry

	move	#0,x0
	move	x0,X:<tmp_toffs
	move	X:<screen_h,x0
	tst	A X:<tmp_y1,B
	jpl	_ok1
	move	A,y0
	abs	A
	move	A,X:<tmp_toffs
	move	x1,A
	add	y0,A
	move	A,x1
	clr	A
_ok1	cmp	x0,A
	jlt	_ok2
	sub	x0,A
	move	A,y0
	move	x1,A
	sub	y0,A
	move	A,x1
	move	x0,A
_ok2	tst	B
	jpl	_ok3
	move	B,y0
	move	x1,B
	add	y0,B
	clr	B B,x1
_ok3	cmp	x0,B
	jlt	_ok4
	sub	x0,B
	move	B,y0
	move	x1,B
	sub	y0,B
	move	B,x1
	move	x0,B
_ok4
	move	A1,X:<tmp_y0
	move	B1,X:<tmp_y1
	move	x1,X:<delta_y
	move	x1,B
	tst	B
	jeq	<_not_active
	jmi	<_not_active	;; !!!REALLY NOT NECCESSARY!!!

	move	X:<omega,y0
	move	X:(r1)+,A	; z0
	move	X:(r1)+,x0	; delta z0
	macr	x0,y0,A	; new z0
	move	X:<blocking,B
	tst	B
	jeq	<_ok
	move	X:<draw_z,x0
	cmp	x0,A
	jge	<_not_active
_ok	move	A,X:<draw_z
	move	#>$ffffff,x0
	move	x0,X:<blocking

	move	X:<tmp_toffs,y0
	move	y0,X:<draw_toffs

	move	X:<tmp_y0,y0
	move	y0,X:<draw_y0
	move	X:<tmp_y1,y1
	move	y1,X:<draw_y1

	move	X:<tmp_y0,y0
	move	X:<real_screen_w,A
	lsr	A
	move	A,x0
	mpy	x0,y0,A r3,x0
	move	A0,A
	add	x0,A
	rep	#8
	lsl	A
	move	A1,X:<draw_screen

	move	X:<wall,A
	rep	#8
	lsl	A
	move	A,X:<draw_wall

	move	#>80,x0
	move	X:<omega,y0
	mpyr	x0,y0,A X:<draw_toffs,y0
	mpy	x0,y0,B
	move	B0,B
	lsl	B
	add	B,A
	lsl	A	; 80*2
	rep	#8
	lsl	A
	move	A,X:<draw_texture

	move	X:<delta_y,A
	rep	#8
	lsl	A
	move	A,X:<draw_height

	move	X:<n_blitter,x0
	move	#blitter,r5
	move	X:<delta_ry,A
	cmp	x0,A
	jlt	_sure
	move	x0,A
_sure	move	A,n5
	nop
	move	X:(r5+n5),x0
	move	x0,X:<draw_yinc

_not_active	move	(r0)+n0
_next_wall	jsr	send_z_buffer
	move	(r3)+	; increase x
_next_x	nop

_no_walls	move	#$ffff00,x0
	jsr	send_DMA	; end of sync
	jsr	send_DMA	; end of sync
	jsr	send_DMA	; end of sync
	rts

command	jsr	recv_host

	move	#>DSP_SYNC,A
	cmp	x0,A
	jeq	_got_sync

	move	#>DSP_SCREEN,A
	cmp	x0,A
	jne	_no_screen
	jsr	recv_host
	move	x0,X:<screen_w
	jsr	recv_host
	move	x0,X:<screen_h
	jsr	recv_host
	move	x0,X:<real_screen_w
	jsr	recv_host
	move	x0,X:<real_screen_h
	jsr	calc_screen
_no_screen

	move	#>DSP_KEY,A
	cmp	x0,A #0,r1
	jne	_no_keys
	jsr	recv_host
	move	x0,A
	bclr	#7,A1
	move	#key_convert,r0
	do	#N_KEYS,_next_key
	move	X:(r0)+,y0
	cmp	y0,A
	jne	_nixen
	enddo
	move	#>$1,A
	move	r1,B
	tst	B
	jeq	_no_shift
	rep	r1	; use lc?
	lsl	A
_no_shift	clr	A A1,y0
	move	X:<keys,A1
	jset	#7,x0,_dec
_add	or	y0,A	; set key
	move	A1,X:<keys
	jmp	_next_key
_dec	clr	B
	move	y0,B1
	not	B
	move	B1,y0
	and	y0,A
	move	A1,X:<keys
_nixen	move	(r1)+
_next_key	nop

_no_keys	jmp	command
_got_sync	rts

calc_screen	move	#CAMERA_W,y0
	move	X:<screen_w,A
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,X:<screen_cw
	move	#CAMERA_H,y0
	move	X:<screen_h,A
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,X:<screen_ch
	rts

get_key	move	#0,x1	; delta o_x
	move	#0,y1	; delta o_y

	jclr	#0,X:<keys,_not_left	; arrow left
	move	#>$a000,A
	neg	A
	add	x1,A
	move	A,x1
_not_left	jclr	#1,X:<keys,_not_right	; arrow right
	move	#>$a000,A
	add	x1,A
	move	A,x1
_not_right	jclr	#2,X:<keys,_not_forward	; arrow up
	move	#>$a000,A
	add	y1,A
	move	A,y1
_not_forward	jclr	#3,X:<keys,_not_backward	; arrow down
	move	#>$a000,A
	neg	A
	add	y1,A
	move	A,y1
_not_backward

	move	#1024-1,m4
	move	#1024-1,m5
	move	#sin+256,r4	; r4 - cos
	move	#sin,r5	; r5 - sin
	move	X:<o_a,n4
	move	X:<o_a,n5
	move	Y:(r4+n4),x0	; cos
	move	Y:(r5+n5),y0	; sin
	move	X:<o_x,A
	move	X:<o_z,B
	mac	x0,x1,A
	macr	y0,x1,B
	mac	x0,y1,B
	macr	-y0,y1,A
	move	A,X:<o_x
	move	B,X:<o_z
	move	#-1,m4
	move	#-1,m5

	jclr	#4,X:<keys,_not_higher	; numeric '+'
	move	X:<o_y,y0
	move	#>$1000,A
	add	y0,A
	move	A,X:<o_y
_not_higher	jclr	#5,X:<keys,_not_lower	; numeric '-'
	move	X:<o_y,y0
	move	#>$1000,A
	neg	A
	add	y0,A
	move	A,X:<o_y
_not_lower

	jclr	#6,X:<keys,_not_rleft	; insert
	move	X:<o_a,A
	move	#>1024+8,x0
	add	x0,A #$3ff,x0
	and	x0,A
	move	A,X:<o_a
	jmp	_not
_not_rleft
	jclr	#7,X:<keys,_not_rright	; clr/home
	move	X:<o_a,A
	move	#>1024-8,x0
	add	x0,A #$3ff,x0
	and	x0,A
	move	A,X:<o_a
	jmp	_not
_not_rright
_not	rts

make_walls	clr	A
	move	A,X:<n_walls

	move	#map,r0	; r0 - map
	move	#W_SIZE,n0	; r1 - map copy
	move	#walls,r2	; r2 - walls
	move	#sin+256,r4	; r4 - cos
	move	#1024-1,m4
	move	#sin,r5	; r5 - sin
	move	#1024-1,m5

	move	X:<n_map,A
	tst	A	; jump if no walls are present
	jeq	_no_walls
	do	A,_loop1
	move	r0,r1
	move	(r0)+n0	; update to next wall

	move	X:<o_x,y0	; translate
	move	X:<o_z,y1	; map coordinates
	move	X:(r1)+,A		; x0
	sub	y0,A X:(r1)+,B	; z0
	sub	y1,B A,X:<tmp_x0
	move	B,X:<tmp_z0
	move	X:(r1)+,A		; x1
	sub	y0,A X:(r1)+,B	; z1
	sub	y1,B A,X:<tmp_x1
	move	B,X:<tmp_z1
	move	X:<o_y,y0
	move	X:(r1)+,A
	sub	y0,A X:(r1)+,B
	sub	y0,B A,X:<tmp_y0
	move	B,X:<tmp_y1

	move	X:<o_a,n4	; rotate coordinates
	move	X:<o_a,n5
	move	Y:(r4+n4),y0	; cos
	move	Y:(r5+n5),y1	; sin
;	move	#>$7fffff,y0	;;;
;	move	#>$000000,y1	;;;
	move	#tmp_wall,r3
	move	#CAMERA_D/2,B
	do	#2,_rotate	; two coordiantes/walls
	move	X:(r3)+,x0
	move	X:(r3)-,A
	add	B,A
	move	A,x1
	mpy	x0,y0,A
	macr	x1,y1,A
	move	A,X:(r3)+
	mpy	-x0,y1,A
	macr	x1,y0,A
	sub	B,A
	move	A,X:(r3)+
_rotate	nop

	clr	A #>$7fffff,B
	move	A,X:<omega_0		; 0
	move	B,X:<omega_1		; 1

	move	X:<tmp_z0,A
	tst	A
	jpl	_z0_ok
	move	X:<tmp_z1,A
	tst	A
	jmi	_next_wall
	move	X:<tmp_z0,A
	move	X:<tmp_z1,B
	sub	A,B
	abs	A
	abs	B
	move	B,y0
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,X:<omega_0
	clr	A #>$7fffff,B
	move	A,X:<tmp_z0
	move	B,X:<alpha_0

	move	X:<tmp_x1,A
	move	X:<tmp_x0,x0
	sub	x0,A X:<omega_0,y0
	move	x0,B
	move	A,x0
	macr	x0,y0,B
	move	B,X:<tmp_x0

	jmp	_go_on1
_z0_ok	move	X:<tmp_z0,B
	move	#CAMERA_D,A
	add	A,B
	move	B,y0
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,X:<alpha_0	; alpha 0
	move	X:<tmp_x0,x0
	move	X:<alpha_0,y0
	mpyr	x0,y0,A
	move	A,X:<tmp_x0

_go_on1	move	X:<tmp_z1,A
	tst	A
	jpl	_z1_ok
	move	X:<tmp_z0,A
	tst	A
	jmi	_next_wall
	move	X:<tmp_z0,A
	move	X:<tmp_z1,B
	sub	A,B
	abs	A
	abs	B
	move	B,y0
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,X:<omega_1
	clr	A #>$7fffff,B
	move	A,X:<tmp_z1
	move	B,X:<alpha_1

	move	X:<tmp_x1,A
	move	X:<tmp_x0,x0
	sub	x0,A X:<omega_1,y0
	move	x0,B
	move	A,x0
	macr	x0,y0,B
	move	B,X:<tmp_x1

	jmp	_go_on2
_z1_ok	move	X:<tmp_z1,B
	move	#CAMERA_D,A
	add	A,B
	move	B,y0
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,X:<alpha_1	; alpha 1
	move	X:<tmp_x1,x0
	move	X:<alpha_1,y0
	mpyr	x0,y0,A
	move	A,X:<tmp_x1
_go_on2

	move	X:<screen_ch,x0
	move	X:<tmp_y0,y0	; scale y0 and y1
	mpyr	x0,y0,A
	move	A,X:<tmp_y0
	move	X:<tmp_y1,y1
	mpyr	x0,y1,A
	move	A,X:<tmp_y1

	move	X:<alpha_0,x0
	move	X:<tmp_y0,y0	; y0
	mpyr	x0,y0,A
	move	A,X:<tmp_y0u
	move	X:<tmp_y1,y1	; y1
	mpyr	x0,y1,A
	move	A,X:<tmp_y0l
	;
	move	X:<alpha_1,x0
	move	X:<tmp_y0,y0	; y0
	mpyr	x0,y0,A
	move	A,X:<tmp_y1u
	move	X:<tmp_y1,y1	; y1
	mpyr	x0,y1,A
	move	A,X:<tmp_y1l
	;
	move	X:<tmp_y1u,A
	move	X:<tmp_y0u,y0
	sub	y0,A
	move	A,X:<tmp_y1u	; delta y0
	move	X:<tmp_y1l,A
	move	X:<tmp_y0l,y1
	sub	y1,A
	move	A,X:<tmp_y1l	; delta y1

	move	X:(r1)+,x0	; get wall #
	move	x0,X:<wall

	move	X:<tmp_x0,x0
	move	X:<tmp_x1,x1
	move	X:<screen_w,A	; scale x0 and x1
	lsr	A
	move	X:<screen_cw,y0
	macr	x0,y0,A A,B
	macr	x1,y0,B A,x0
	move	B,x1
	move	x0,X:<tmp_x0
	move	x1,X:<tmp_x1

	move	X:<tmp_z0,x1
	move	x1,X:<wall_z
	move	X:<tmp_z1,B
	sub	x1,B	; delta z
	move	B,X:<delta_z

	clr	A #>$7fffff,B
	move	A,X:<omega_0		; 0
	move	B,X:<omega_1		; 1

	move	X:<tmp_x1,A
	move	X:<tmp_x0,x0
	sub	x0,A	; delta x
	move	A,X:<delta_x
	abs	A
	rep	#12
	lsl	A
	move	A,y0	; scaled delta x
	move	#>$001000,A
	and	#$fe,CCR
	rep	#24
	div	y0,A
	move	A0,A
	jclr	#23,X:<delta_x,_not_negative
	neg	A
	move	X:<tmp_x0,x0
	move	X:<tmp_x1,x1
	move	x0,X:<tmp_x1
	move	x1,X:<tmp_x0
	move	X:<omega_0,y0
	move	X:<omega_1,y1
	move	y0,X:<omega_1
	move	y1,X:<omega_0
	move	X:<delta_x,B
	abs	B
	move	B,X:<delta_x
_not_negative	move	A,X:<delta_omega

	move	X:<omega_0,A
	move	X:<delta_x,x0
	move	X:<tmp_x0,B
	add	x0,B
	jmi	_next_wall	; is outside the screen
	move	X:<tmp_x0,B
	tst	B
	jpl	_ok

	move	X:<tmp_x0,A
	abs	A X:<delta_omega,y0
	move	X:<delta_x,B
	sub	A,B A,x0
	move	B,X:<delta_x
	mpy	x0,y0,A
	asr	A X:<omega_0,x0
	clr	B A0,A
	add	x0,A B,X:<tmp_x0
_ok	move	A,X:<omega

	move	X:<delta_x,A	; copy all parameters
	tst	A	; to walls list
	jeq	_next_wall
	; Everything a ok
	move	A,X:(r2)+	; write delta x
	move	X:<tmp_x0,x0
	move	x0,X:(r2)+	; left x
	move	X:<omega,x0
	move	x0,X:(r2)+	; omega
	move	X:<delta_omega,x0
	move	x0,X:(r2)+	; delta omega
	move	X:<wall,x0
	move	x0,X:(r2)+	; wall #
	; Write y values
	move	X:<tmp_y0u,x0
	move	x0,X:(r2)+	; y0 upper
	move	X:<tmp_y1u,x0
	move	x0,X:(r2)+	; y0 delta upper
	move	X:<tmp_y0l,x0
	move	x0,X:(r2)+	; y0 lower
	move	X:<tmp_y1l,x0
	move	x0,X:(r2)+	; y0 delta lower
	; Write z values
	move	X:<tmp_z0,x0
	move	x0,X:(r2)+	; z
	move	X:<delta_z,x0
	move	x0,X:(r2)+	; delta z

	move	#>1,x0
	move	X:<n_walls,A
	add	x0,A
	move	A,X:<n_walls

_next_wall	nop
_loop1	nop
_no_walls	nop

	move	#-1,m4
	move	#-1,m5
	rts

send_z_buffer	move	X:<blocking,A
	tst	A
	jeq	<_nixen

	move	X:<draw_y0,A
	tst	A
	jeq	_no_upper
	move	r3,A
	jsr	sendA_DMA	; screen offset
	move	#0,x0
	jsr	send_DMA	; 
	move	#0,x0
	jsr	send_DMA	; texture offset
	move	X:<draw_y0,A
	jsr	sendA_DMA	; wall height
	move	#0,x0
	jsr	send_DMA	; y increment
	move	#>$00c000,x0
	jsr	send_DMA	; blitter initialization
_no_upper
	move	X:<draw_screen,x0
	jsr	send_DMA	; screen offset
	move	X:<draw_wall,x0
	jsr	send_DMA	; texture #
	move	X:<draw_texture,x0
	jsr	send_DMA	; texture offset
	move	X:<draw_height,x0
	jsr	send_DMA	; wall height
	move	X:<draw_yinc,x0
	jsr	send_DMA	; y increment
	move	#>$03c000,x0
	jsr	send_DMA	; blitter initialization

	move	X:<screen_h,A
	move	X:<draw_y1,y1
	sub	y1,A
	tst	A A,y0
	jeq	_no_lower
	move	X:<draw_y1,y1
	move	X:<real_screen_w,A
	lsr	A
	move	A,x0
	mpy	x0,y1,A r3,x0
	move	A0,A
	add	x0,A
	jsr	sendA_DMA	; screen offset
	move	#0,x0
	jsr	send_DMA	; 
	move	#0,x0
	jsr	send_DMA	; texture offset
	move	y0,A
	jsr	sendA_DMA	; wall height
	move	#0,x0
	jsr	send_DMA	; y increment
	move	#>$00c000,x0
	jsr	send_DMA	; blitter initialization
_no_lower
	jmp	_resume
_nixen	move	r3,A
	jsr	sendA_DMA	; screen offset
	move	#0,x0
	jsr	send_DMA	; 
	move	#0,A
	jsr	sendA_DMA	; texture offset
	move	X:<screen_h,A
	jsr	sendA_DMA	; wall height
	clr	A
	jsr	sendA_DMA	; y increment
	move	#>$00c000,x0
	jsr	send_DMA	; blitter initialization
_resume	rts

recv_host	jclr	#0,x:<<M_HSR,recv_host
	movep	x:<<M_HRX,x0
	rts
send_host	jclr	#1,x:<<M_HSR,send_host
	movep	x0,x:<<M_HTX
	rts
send_DMA	bset	#5,x:<<M_PCD	; start frame sync
	movep	x0,x:<<M_TX
_wait	jclr	#6,x:<<M_SR,_wait
	bclr	#5,x:<<M_PCD	; stop frame sync
	rts
sendA_DMA	rep	#8
	lsl	A
	bset	#5,x:<<M_PCD	; start frame sync
	movep	A1,x:<<M_TX
_wait	jclr	#6,x:<<M_SR,_wait
	bclr	#5,x:<<M_PCD	; stop frame sync
	rts

	end
