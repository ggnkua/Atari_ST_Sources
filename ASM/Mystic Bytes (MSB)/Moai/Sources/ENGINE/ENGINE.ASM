; **** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! ******
; * a space for visible faces expects max half of all faces to be visible! *
; ***** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! *****

; BUG v QDSP: ak za include ide riadok s odsadenim, nezoberie mi to prve EQU!!
;             equ mozu byt len 16 bit hodnoty! (equ $ffffff = $ffff)

COMPATIBLE	EQU	0

		INCLUDE	macros.asm

; ====================================
; === current limits of DSP engine ===
; ====================================

		IFNE	COMPATIBLE
MAX_POINTS	EQU	600
MAX_TRIANGLES	EQU	800
		ELSE
MAX_POINTS	EQU	750
MAX_TRIANGLES	EQU	1150
		ENDC

MAX_OBJECTS	EQU	32

; ============================
; === flags used in engine ===
; ============================

; y:<flags is trashed in:
; - kill_faces
; - render_scene (at the beginning)

FLG_WRAPTEX	EQU	4					; 1: wrap texture (64/128)
FLG_WIREFRAME	EQU	6					; 1: draw polygon as wireframe
FLG_FLAT	EQU	7					; 1: polygon is flat shaded
FLG_GOURAUD	EQU	8					; 1: polygon/line is Gouraud-shaded
FLG_ENVMAP	EQU	9					; 1: polygonis env mapped
FLG_TEXMAP	EQU	10					; 1: polygon is texture mapped
FLG_DSPTEX	EQU	11					; 1: texture lies in DSP memory

FLG_LEFT	EQU	12					; 1: interpolate left side
FLG_RIGHT	EQU	13					; 1: interpolate right side
FLG_SWAP	EQU	14					; 1: swap u1-u2/v1-v2,used by clipping

FLG_CLIP_LEFT	EQU	16					; 1: clip face against the left border
FLG_CLIP_RIGHT	EQU	17					; 1: clip face against the right border
FLG_CLIP_TOP	EQU	18					; 1: clip face against the top border
FLG_CLIP_BOTTOM	EQU	19					; 1: clip face against the bottom border

FLG_SPHERICAL	EQU	15					; set in x:<materials

; ======================
; === min/max values ===
; ======================

MIN_Z		EQU	1
MAX_Z		EQU	1024

; =================
; === constants ===
; =================

X_RES		EQU	300

PAINT_DSPTEX	EQU	34					; command for dsp texture paint
PAINT_GOURAUD	EQU	35					; command for gouraud paint
PAINT_FLAT	EQU	36					; command for flat poly paint
PAINT_SPRITE	EQU	37					; command for sprite paint
PAINT_LINE	EQU	38					; command for line paint

; ===========================================
; === shifting/masking stuff for textures ===
; ===========================================

TEXTINT		EQU	7
TEXTFRAC	EQU	16-TEXTINT
U_SHIFT		EQU	24-TEXTFRAC-1
V_SHIFT		EQU	24-(TEXTFRAC-TEXTINT)-1
V_MASK		EQU	($10000-1<<TEXTFRAC)>>(TEXTFRAC-TEXTINT)

SHADEINT	EQU	6
SHADEFRAC	EQU	14	;8

	ORG	P:$0000
	jmp	>init_engine

	ORG	P:$0024
	jsr	>receive_1_x_table				; $24
	ds	2						; $26
	ds	2						; $28
; use space reserved for host commands
hc_jumptable:
	dc	receive_object
	dc	receive_texture
	dc	start_engine
	dc	init_player

; =================
; === SMC stuff ===
; =================

jump_skip_flat:
	jmp	<interpolate_x					; smc_skip, smc_branch_shade
jump_skip_gouraud:
	jmp	<interpolate_s					; smc_skip
jump_skip_texture:
	jmp	<interpolate_uv					; smc_skip
jump_gouraud:
	jmp	<gouraud_shader					; smc_branch_shade
jump_texmap:
	move	l:<u_lr,y					; smc_branch_shade
jump_alphatex:
	jmp	<alpha_mapper					; smc_branch_shade
jump_alphatex_dsp:
	jmp	<alpha_dsp_mapper				; smc_branch_shade

dsp_tex1:
	move	a1,n0						; smc_texmap1
cpu_tex1:
	lsl	a						; smc_texmap1
dsp_tex2:
	movep	y:(r0+n0),x:<<$ffeb				; smc_texmap2
cpu_tex2:
	movep	a1,x:<<$ffeb					; smc_texmap2

	ORG	P:$0040

; =============================
; === Rotation & projection ===
; =============================

vertex_projection:
; x:(r0) - vertices to rotate (x, y, z) [in]
; x:(r1) - translation vector (x, y, z) [in]
; y:(r3) - projected z                  [out]
; y:(r5) - projected x                  [out]
; y:(r6) - projected y                  [out]
;
	move	#mul_1_x,r2					; X
	move	#rot_matrix,r4					; Y
	move	#<9-1,m4					; 3x3 matrix
	move	#-2,n0						; we can't use (Rn)-Nn
	move	#<2,n1
	move	#$008000,x1
	move			x:(r0)+,x0	y:(r4)+,y0

	do	n6,endloop
	move			x:(r1)+,a
	mac	+x0,y0,a	x:(r0)+,x0	y:(r4)+,y0
	mac	+x0,y0,a	x:(r0)+n0,x0	y:(r4)+,y0
	macr	+x0,y0,a	x:(r0)+,x0	y:(r4)+,y0

	move			x:(r1)+,b	a,y1
	mac	+x0,y0,b	x:(r0)+,x0	y:(r4)+,y0
	mac	+x0,y0,b	x:(r0)+n0,x0	y:(r4)+,y0
	macr	+x0,y0,b	x:(r0)+,x0	y:(r4)+,y0
smc1:	tst	b		x:(r1)-n1,a			; smc area here!

	mac	+x0,y0,a	x:(r0)+,x0	y:(r4)+,y0
	mac	+x0,y0,a	x:(r0)+,x0	y:(r4)+,y0
	macr	+x0,y0,a

	move	a,y0
	mpyr	y0,x1,a		b,x0				; (z+dist)*256 >> 8 // x0: y
	move	a,n2
	move					a,y:(r3)+	; z+dist
	move			x:(r2+n2),y0			; y0: 1/(z+dist)

	mpyr	+y1,y0,a			y:<center_x,y1	; 256*x/(z+dist)
	mpyr	+x0,y0,b			y:<center_y,x0	; 256*y/(z+dist)
	add	y1,a				y:(r4)+,y0
	add	x0,b		x:(r0)+,x0	a,y:(r5)+
	move					b,y:(r6)+
endloop:
	rts

normal_rotation:
; normal rotation and u,v calculation from nx,ny:
; u = (nx+1) << scale = nx<<scale + 1<<scale : <0,2) => scale has to be 1 degree lower than result
; v = (ny+1) << scale = ny<<scale + 1<<scale : <0,2)
; we save it in nz:u:v format (nz->for future use)

; x:(r0) - normals to rotate in 0.15 fixed point [in]
; y:(r5) - rotated normals in 0:8:8 format       [out]

	move	#<rot_matrix,r4					; Y
	movec	#<6-1,m4
	move	#1<<15,y1
	move	#$00ff00,x1
	move			x:(r0)+,x0	y:(r4)+,y0

	do	n6,_endloop
	mpy	x0,y0,a		x:(r0)+,x0	y:(r4)+,y0
	mac	x0,y0,a		x:(r0)+n0,x0	y:(r4)+,y0
	macr	x0,y0,a		x:(r0)+,x0	y:(r4)+,y0
	add	y1,a		y1,b

	mac	x0,y0,b		x:(r0)+,x0	y:(r4)+,y0
	mac	x0,y0,b		x:(r0)+,x0	y:(r4)+,y0
	macr	x0,y0,b

	and	x1,b		#1<<(16-1),x0			; b: $00:vv:$00
	and	x1,a		b,y0				; a: $00:uu:$00
	mac	x0,y0,a		x:(r0)+,x0	y:(r4)+,y0

	move					a1,y:(r5)+	; a1: $00:uu:vv
_endloop:
	rts

; =====================================
; === Z-Clipping & Backface Culling ===
; =====================================

; depack face buffer to temp buffer
; x:(r5) - packed face   [in]
; x:(r6) - depacked face [out]

depack_face:
	move			x:(r5)+,y0			; y0: vertices:flags
	tfr	y0,b		#1<<(24-12-1),x1
	mpy	y0,x1,a		#<1,n5
	move	a1,a						; acc: $00:vertices:$000
	lsr	a		a,x0		#$000fff,y1	; x0: vertices
	and	y1,b		x0,y0				; b1: flags
	move					b,y:<flags	; set flags

	jclr	#FLG_TEXMAP,y:<flags,_not_uv
	add	y0,a		#<3,n5				; n5: for skipping u, v
_not_uv:
	tst	a		y0,x:(r6)+			; save number of vertices
	jeq	<_end_copyloop

	do	a,_end_copyloop
	move			x:(r5)+,y0
	mpy	y0,x1,a		y0,b
	and	y1,b		a1,x:(r6)+
	move			b1,x:(r6)+
_end_copyloop:

	jclr	#0,x0,<_done					; even?
	move			x:(r5)+,y0
	move			y0,x:(r6)+

_done:	rts

kill_faces:
	move	#<0,r0						; vis_counter
	move	#proj_point_x,r1				; Y
	move	#proj_point_y,r2				; Y
	move	#proj_point_z,r3				; Y
	move	#visible_faces,r4				; X
	move	#face_buffer,r5					; X
	move	r5,n4						; save (will be modified)
	move					r5,y:<backup_rn+1

	do	x:<faces,_endloop
	move	n4,r5						; facebuffer (X)
	move					y:<backup_rn+1,n5
	move	#<temp_face,r6					; X
	lua	(r5)-n5,n4					; n4: offset
	move					n4,y:<backup_rn

	jsr	<depack_face

	move	r5,n4
	move	#<temp_face,r5					; X
	move	#mul_1_x,r6					; X

	move			x:(r5)+,n6			; n6: vertices per face
	move	r5,n0						; save for future use

; check z coordinate against the boundaries (to avoid an overflow in mul table)
	move	#MIN_Z,x0
	move	#MAX_Z,x1
	clr	b		#<1,y0				; b: 0 (ok)

	do	n6,_checkz_endloop
	move			x:(r5)+n5,n3
	nop
	move					y:(r3+n3),a
	cmp	x0,a
	tlt	y0,b						; set false if z<min
	cmp	x1,a
	tge	y0,b						; set false if z>=max
_checkz_endloop:
	tst	b		n0,r5
	jne	<_invisible					; skip if false

	move	#2,x0
	move	n6,a
	cmp	x0,a
	jle	<_check_screen					; if sprite/line, skip

	move			x:(r5)+n5,n1			; vertex 1
	move	n1,n2
	move					y:(r1+n1),a	; a: X1
	move					y:(r2+n2),b	; b: Y1

	move			x:(r5)+n5,n1			; vertex 2
	move	n1,n2
	move					y:(r1+n1),y1	; y1: X2
	sub	y1,a				y:(r2+n2),y0	; x1-x2 // y0: Y2
	sub	y0,b		a,x0				; y1-y2

	move			x:(r5)+n5,n1			; vertex 3
	move	n1,n2
	move					y:(r1+n1),a	; a: X3
	sub	y1,a		b,x1		y:(r2+n2),b	; x3-x2 // b: Y3
	sub	y0,b		a,y0				; y3-y2
	mpy	-y0,x1,a	b,y1				; -(x3-x2)(y1-y2)
	mac	+x0,y1,a	n0,r5				; +(x1-x2)(y3-y2)
	jge	<_invisible					; if >=0

; check screen coordinates if the face doesn't lie out of screen
_check_screen:
	move					y:<clip_left,y0
	move					y:<clip_right,y1
	move					y:<clip_top,x0
	move	#<$0f,x1					; AND flags ($0f0000)
	move					x1,y:<flags

	do	n6,_check_loop
	move			x:(r5)+n5,n1
	clr	b		n1,n2

_check_left:
	move					y:(r1+n1),a	; a: x[i]
	cmp	y0,a		#<%00000001,x1
	jge	<_check_right
	or	x1,b

_check_right:
	cmp	y1,a		#<%00000010,x1
	jlt	<_check_up
	or	x1,b

_check_up:
	move					y:(r2+n2),a	; a: y[i]
	cmp	x0,a		#<%00000100,x1
	jge	<_check_down
	or	x1,b

_check_down:
	move					y:<clip_bottom,x1
	cmp	x1,a		#<%00001000,x1
	jlt	<_check_done
	or	x1,b

_check_done:
	move			b,x1		y:flags,a
	and	x1,a				y:<backup_rn,x1	; x1: %0000000000aaaaaaaaaaaaaa (10.14)
	move					a,y:<flags
_check_loop:

	tst	a		n0,r5
	jne	<_invisible

	move	#1<<(10-1),x0
	mpy	x1,x0,b						; b0: %aaaaaaaaaaaaaa0000000000 (14.10)

	clr	a		x:(r5)+n5,n3			; n3: first vertex
	move	(r0)+						; update counter
	move					y:(r3+n3),x0	; z1

	do	n6,_sumz_endloop
	move			x:(r5)+n5,n3			; vertex number
	add	x0,a
	move					y:(r3+n3),x0
_sumz_endloop:

	move			x:(r6+n6),x0	a,y0
	mpyr	y0,x0,a		b0,x0				; a: sum(z)/n (10 bits MAX)
	or	x0,a						; a: %aaaaaaaaaaaaaazzzzzzzzzz
	move			a1,x:(r4)+			; save face.z in 14.10 format

_invisible:
	nop
_endloop:
	move	r0,a
	whost	a						; send #faces & continue
	tst	a		a,x:<vis_faces
	rts

; =========================
; === 2-base radix sort ===
; =========================

sort_faces:
	move	#one_array,n0					; dst sorted faces (X)
	move	#zero_array,n4					; Y
	move	n0,y0
	move	n4,y1

	do	#10,_end_outloop				; 10 bits precision
	move	n0,r0
	move	n4,r4
	move	r0,r1

	do	x:<vis_faces,_end_inloop
	move			x:(r1)+,a			; address.z
	lsr	a						; lsb -> c
	jcc	<_zero						; jcc: back->front

_one:	move			a1,x:(r0)+
	jmp	<_skip

_zero:	move					a1,y:(r4)+	; save to zero array

_skip:	nop
_end_inloop:

	move	(r1)-

	move	r4,a						; update address
	sub	y1,a				y:-(r4),b	; same as original? // prepare 1st value
	jeq	<_no_copy
	move	(r4)-						; point to next (backward) element

	;rep	a
	do	a,_shit
	move			b,x:(r1)-	y:(r4)-,b
_shit:

_no_copy:
	nop
_end_outloop:
	rts

; ===========================
; === Edges Interpolation ===
; ===========================

interpolate_edges:
	do	x1,scan_endloop

	move	l:<x_r,b
	rnd	b		x:<x_l,y1			; round(x_r) // int(x_l)

	sub	y1,b				y:<pix_offset,a
	whost	b						; dx
	jgt	<dx_ok

	sub	y1,a		#X_RES,y1			; x_l since nothing is drawn
	add	y1,a
	move					a,y:<pix_offset

smc_skip:
	jmp	<interpolate_uv

dx_ok:	lsl	a		b,n3				; pix_offset << 1 // n3: dx
	whost	a

	add	y1,b		#X_RES,a			; b1: x_l + dx = x_r
	sub	b,a		x:(r3+n3),x1			; a1: X_RES - x_r // x1: 1/dx
	move					a,y:<pix_offset

smc_branch_shade:
; superfast texture mapper
; constants in following comments are for 6.8 accuracy

	move	l:<u_lr,y					; y1: u_l y0: u_r

	mpy	+y0,x1,a	y1,r5				; a1: +u_r/dx // r5: u [6.8]
	macr	-y1,x1,a	l:<v_lr,y			; a1: -u_l/dx // y1: v_l y0: v_r

	mpy	+y0,x1,a	a,n5				; a1: +v_r/dx // n5: dudx [6.8]
	macr	-y1,x1,a	x:<v_shift,x1			; a1: -v_l/dx

; mpyr -> mpy for 6.6.2
	mpyr	y1,x1,b		a,y1				; b : v    [6.6.2] // y1: dvdx [6.8]
	mpyr	y1,x1,a		#<v_mask,r4			; a : dvdx [6.6.2] // X

	;move	a1,x1						; x : dvdx [6.6.2]
	;move	a0,x0						;
	move	a,x1
	move			x:<u_shift,y0

	do	n3,end_texloop
	add	x1,b		x:(r4),a	b,y1
	and	y1,a		r5,y1
	mac	y1,y0,a		(r5)+n5
smc_texmap1:
	lsl	a						; hicolor word -> *2
	wait_write
smc_texmap2:
	movep	a1,x:<<$ffeb
end_texloop:
	jmp	<interpolate_uv

gouraud_shader:
; slow gouraud shader, cpu implemetation is faster, but more inaccurate

	move	l:<s_lr,y					; y1: s_l y0: s_r

	mpy	+y0,x1,a	y1,b				; a1: +s_r/dx // b1: s [6.14]
	macr	-y1,x1,a	#$003f00,x0			; a1: -s_l/dx

	move	#1<<(24-14+8-1),y0
	move	a,x1						; x1: dsdx [6.14]

	do	n3,_endloop
	add	x1,b				b,y1		; s += dsdx // y1: %0000SSSSSSssssssssssssss
	mpy	y1,y0,a						; a1: %0000000000SSSSSSssssssss
	and	x0,a				y:<curr_mat,y1	; a1: %0000000000SSSSSS00000000
	or	y1,a						; a1: %0000000000SSSSSSCCCCCCCC
	whost	a
_endloop:
	jmp	<interpolate_s

alpha_mapper:
; superfast alphatexture mapper
; constants in following comments are for 64 shades and 7.8 textures

	move	l:<u_lr,y					; y1: u_l y0: u_r

	mpy	+y0,x1,a	y1,r5				; a1: +u_r/dx // r5: u [7.8]
	macr	-y1,x1,a	l:<v_lr,y			; a1: -u_l/dx // y1: v_l y0: v_r

	mpy	+y0,x1,b	y1,r0				; b1: +v_r/dx // r0: v [7.8]
	macr	-y1,x1,b	l:<s_lr,y			; b1: -v_l/dx // y1: s_l y0: s_r

	mpy	+y0,x1,b	b,n0				; b1: +s_r/dx // n0: dvdx [7.8]
	macr	-y1,x1,b	a,n5				; b1: -s_l/dx // n5: dudx [7.8]

	tfr	y1,b		b,x1				; b1: s [6.14] // x1: dsdx [6.14]
	
	move	#<s_mask,r4					; X
	move			x:<v_shift,y0
	move			x:<u_shift,x0

	do	n3,_endloop
	add	x1,b		x:(r4),a	b,y1		; b1: s += dsdx // a1: mask // y1: s [6.14]
	and	y1,a		r0,y1				; a1: %0000SSSSSS00000000000000 // y1: v [7.8]
	mac	y1,y0,a		x:<v_mask,y1			; a1: %0000SSSSSSVVVVVVVvvvvvvv
	and	y1,a		r5,y1				; a1: %0000SSSSSSVVVVVVV0000000 // y1: u [7.8]
	mac	y1,x0,a		(r0)+n0				; a1: %0000SSSSSSVVVVVVVUUUUUUU // v += dvdx
	move	(r5)+n5						; u += dudx
	whost	a1
_endloop:
	jmp	<interpolate_s
	
alpha_dsp_mapper:
; not-so-fast-but-more-accurate dsp alphatexture mapper
; constants in following comments are for 64 shades and 6.8 textures

	move	l:<u_lr,y					; y1: u_l y0: u_r
	
	mpy	+y0,x1,a	y1,r5				; a1: +u_r/dx // r5: u [6.8]
	macr	-y1,x1,a	l:<s_lr,y			; a1: -u_l/dx // y1: s_l y0: s_r
	
	mpy	+y0,x1,a	a,n5				; a1: +s_r/dx // n5: dudx [6.8]
	macr	-y1,x1,a	y1,b0				; a1: -s_l/dx // b0: s [6.14]
	
	move	l:<v_lr,y					; y1: v_l y0: v_r
	
	mpy	+y0,x1,a	a,x0				; b1: +v_r/dx // x0: dsdx [6.14]
	macr	-y1,x1,a	x:<v_shift,y0			; b1: -v_l/dx
	
	mpyr	y1,y0,a		a,y1				; a1: v [6.6] // y1: dvdx [6.6]
	mpyr	y1,y0,a		a,b1				; a1: dvdx [6.6] // b1: v [6.6]
	
	move	a,x1						; x1: dvdx [6.6]
	move	#<v_mask,r4					; X
	move			x:<u_shift,y0
	move	x,l:<dvdx_dsdx

	do	n3,_endloop
	add	x,b		x:(r4),a	b,y1		; y1: %000000000000VVVVVVvvvvvv
	and	y1,a		r5,y1				; a1: %000000000000VVVVVV000000
	mac	y1,y0,a		b0,y1				; a1: %000000000000VVVVVVUUUUUU // y1: %0000SSSSSSssssssssssssss
	move	l:<s_mask_shift,x
	mpy	y1,x0,a		a,n0				; a1: %0000000000SSSSSSssssssss // n0: %0000VVVVVVUUUUUU
	and	x1,a		(r5)+n5				; a1: %0000000000SSSSSS00000000
	move					y:(r0+n0),y1
	or	y1,a		l:<dvdx_dsdx,x			; a1: %0000000000SSSSSSTTTTTTTT
	whost	a1
_endloop:
	
interpolate_s:
	move	l:<s_lr,a10
	move	l:<ds_dy_lr,x
	add	x,a
	move	a10,l:<s_lr

interpolate_uv:
	move	l:<u_lr,a10
	move	l:<du_dy_lr,x
	add	x,a		l:<v_lr,b10

	move	l:<dv_dy_lr,x
	add	x,b		a10,l:<u_lr
	move	b10,l:<v_lr

interpolate_x:
	move	l:<x_l,a					; a1:a0 = int:frac
	move	l:<dx_dy_l,x
	add	x,a				y:<pix_offset,y1
	add	y1,a		a,l:<x_l

	move	l:<x_r,b
	move	l:<dx_dy_r,x
	add	x,b				a1,y:<pix_offset
	move	b,l:<x_r

	move	(r6)-						; dy--
scan_endloop:
	rts

; ========================
; === Polygon sections ===
; ========================

right_section:
; Searches for the right section
; output: dy, dx/dy, [ds/dy], [du/dy], [dv/dy]
	move			x:(r1)+n1,x0			; x0: y[i]
	move			x:(r1),b			; b1: y[i+1]
	sub	x0,b						; dy_r
	jeq	<right_section

	move	(r1)+						; x:(r1) = x[i+1]

	move	b,n3						; n3: dy
	move			x:(r1)-n1,a			; a1: x[i+1] // x:(r1) = x[i]
	move			x:(r1)+,y1			; x1: x[i]
	sub	y1,a				b,y:<dy_r

	move			x:(r3+n3),x0	a,y1		; x0: 1/dy // y1: dy
	mpy	y1,x0,a		x:(r1+n1),x1			; x1: s[i+1] or u[i+1]
	move	a,l:<dx_dy_r

	jset	#FLG_FLAT,y:<flags,_end

_gouraud:
	jclr	#FLG_GOURAUD,y:<flags,_texmap

	mpy	+x1,x0,a	x:(r1)+,x1			; a1: +s[i+1]/dy // x1: s[i]
	macr	-x1,x0,a	x:(r1+n1),x1			; a1: -s[i]/dy   // x1: u[i+1]
	move					a,y:<ds_dy_r

	jclr	#FLG_TEXMAP,y:<flags,_end

_texmap:
	mpy	+x1,x0,a	x:(r1)+,x1			; a1: +u[i+1]/dy // x1: u[i]
	macr	-x1,x0,a	x:(r1+n1),x1			; a1: -u[i]/dy   // x1: v[i+1]
	mpy	+x1,x0,b	x:(r1)+,x1			; b1: +v[i+1]/dy // x1: v[i]
	macr	-x1,x0,b			a,y:<du_dy_r	; b1: -v[i]/dy
	move					b,y:<dv_dy_r

_end:	rts

left_section:
; Searches for the left section
; output: dy, dx/dy, [ds/dy], [du/dy], [dv/dy]
	move			x:(r2)-n2,x0			; x0: y[i]
	move			x:(r2),b			; b1: y[i+1]
	sub	x0,b						; dy_l
	jeq	<left_section

	move	(r2)+						; x:(r2) = x[i+1]

	move	b,n3						; n3: dy
	move			x:(r2+n2),y1			; x1: x[i]
	move			x:(r2)+,a			; a1: x[i+1]
	sub	y1,a		b,x:<dy_l

	move			x:(r3+n3),x0	a,y1		; x0: 1/dy // y1: dy
	mpy	y1,x0,a		x:(r2+n2),x1			; x1: s[i] or u[i]
	move	a,l:<dx_dy_l

	jset	#FLG_FLAT,y:<flags,_end

_gouraud:
	jclr	#FLG_GOURAUD,y:<flags,_texmap

	mpy	-x1,x0,a	x:(r2)+,x1			; a1: -s[i]/dy   // x1: s[i+1]
	macr	+x1,x0,a	x:(r2+n2),x1			; a1: +s[i+1]/dy // x1: u[i]
	move			a,x:<ds_dy_l

	jclr	#FLG_TEXMAP,y:<flags,_end

_texmap:
	mpy	-x1,x0,a	x:(r2)+,x1			; a1: -u[i]/dy   // x1: u[i+1]
	macr	+x1,x0,a	x:(r2+n2),x1			; a1: +u[i+1]/dy // x1: v[i]
	mpy	-x1,x0,b	x:(r2)+,x1			; b1: -v[i]/dy   // x1: v[i+1]
	macr	+x1,x0,b	a,x:<du_dy_l			; b1: +v[i+1]/dy
	move			b,x:<dv_dy_l

_end:	move	(r2)-n2
	rts

; =======================
; === Polygon painter ===
; =======================

; n0: number of vertices (min 3)
; n1: number of elements for one vertex (flat:2, gouraud:3, texture:4, alpha:5)
; m1: wrapper for n1
; r1: polygon_buffer
; r3: 1/x table

draw_polygon:
	move					y:<clip_top,a
	move					y:<clip_bottom,b

	do	n0,_endloop
	move			x:(r1),y0			; y[i]
	cmp	y0,b						; min_y > y[i] ?
	tgt	y0,b		r1,r2				; yes, set new min
	cmp	y0,a		(r1)+n1				; max_y < y[i] ? // i++
	tlt	y0,a						; yes, set new max
_endloop:
; a: bottom y
; b: top y
; r2: address of top y

	sub	b,a						; max_y - min_y
	whost	a						; global dy
	jle	<end_jump

	whost	b						; send top y
	move	a,n4

	jclr	#FLG_FLAT,y:<flags,_not_material
	whost	y:curr_mat
_not_material:

	movec	m1,m2						; ringbuffer for left side
	move	n1,n2						; offset for left side
	move	r2,r1						; right=left=top

; locked: - r0 (x:sort_faces)
;         - r1 (x:right side pointer)
;         - r2 (x:left side pointer)
;         - r3 (x:1/x table)
;         - r6: global dy counter
;         - n1, n2
;         - m1, m2

	jsr	<right_section
	jsr	<left_section

	lua	(r1)-n1,r5					; r1 is NEXT point already
	lua	(r2)+n2,r6					; r2 is NEXT point already
	move	(r5)+						; skip y
	move	(r6)+						; skip y

	move			x:(r5)+,a
	move	a,l:<x_r

	move			x:(r6)+,a
	move	a,l:<x_l
	move					a,y:<pix_offset

	jset	#FLG_FLAT,y:<flags,_skip
	jclr	#FLG_GOURAUD,y:<flags,_texture

	move			x:(r5)+,a			; s_r
	move			x:(r6)+,b			; s_l
	move	ba,l:<s_lr
	jclr	#FLG_TEXMAP,y:<flags,_skip

_texture:
	move			x:(r5)+,a			; u_r
	move			x:(r6)+,b			; u_l
	move	ba,l:<u_lr

	move			x:(r5),a			; v_r
	move			x:(r6),b			; v_l
	move	ba,l:<v_lr

_skip:	move	n4,r6						; r6: global dy

loop_sections:
	move	l:<dy_lr,ab
	cmp	b,a		a,x1				; x1: current dy
	jlt	<_left
	jgt	<_right

_both:	bset	#FLG_LEFT,y:<flags
	bset	#FLG_RIGHT,y:<flags
	jmp	<_skip

_left:	sub	a,b
	move					b,y:<dy_r
	bset	#FLG_LEFT,y:<flags
	bclr	#FLG_RIGHT,y:<flags
	jmp	<_skip

_right:	sub	b,a		b,x1
	move			a,x:<dy_l
	bclr	#FLG_LEFT,y:<flags
	bset	#FLG_RIGHT,y:<flags
_skip:
	jsr	<interpolate_edges

	move	r6,a
	tst	a
	jeq	<end_jump

	jsset	#FLG_RIGHT,y:<flags,right_section
	jsset	#FLG_LEFT,y:<flags,left_section
	jmp	<loop_sections

; ====================
; === Line painter ===
; ====================

draw_line:
	do	#4,_endloop					; y1,x1,y2,x2
	whost	x:(r1)+
_endloop:
	whost	y:curr_mat					; material
	jmp	<end_jump

; ======================
; === Sprite painter ===
; ======================

draw_sprite:
	whost	x:(r1)+						; y1
	whost	x:(r1)+						; x1
	jmp	<end_jump

; ===========================
; === Main Rendering Loop ===
; ===========================

render_scene:
	move	#sorted_faces,r0				; X

	do	x:<vis_faces,end_mainloop

	move	#face_buffer,r5
	move			x:(r0)+,n5			; actual face offset
	move	#<temp_face,r6					; X
	move	(r5)+n5						; r5: face address
	move					r0,y:<backup_rn	; save pointer

	jsr	<depack_face

	move	#<polygon_data,r1				; X
	move	#proj_point_x,r2				; Y
	move	#proj_point_y,r3				; Y
	move	#vertex_uv,r4					; X
	move	#<temp_face,r6					; X

	move					y:<clip_left,y0
	move					y:<clip_right,y1
	move					y:<clip_bottom,x0

	move			x:(r6)+,n0			; n0: number of vertices

	move	#<$80,n5					; n5: 1<<(8-1) = $80
	move	#$ff00,n6

	move	#2,x1
	move	n0,a
	cmp	x1,a
	jgt	<_polygon
	move					y:<clip_right_line,y1
	move					y:<clip_bottom_line,x0

_polygon:

; --- test for clipping & save to temp buffer---
	do	n0,_check_loop

	move			x:(r6)+,n3
	clr	b		n3,n2

_check_up:
	move					y:(r3+n3),a	; a: y[i]
	move			a,x:(r1)+			; y[i]->buffer
	move					y:<clip_top,x1
	cmp	x1,a		#<%00000100,x1
	jge	<_check_down
	or	x1,b

_check_down:
	cmp	x0,a		#<%00001000,x1
	jle	<_check_left
	or	x1,b

_check_left:
	move					y:(r2+n2),a	; a: x[i]
	move			a,x:(r1)+			; x[i]->buffer
	cmp	y0,a		#<%00000001,x1
	jge	<_check_right
	or	x1,b

_check_right:
	cmp	y1,a		#<%00000010,x1
	jle	<_check_done
	or	x1,b

_check_done:
	move			b,x1		y:flags,a
	or	x1,a		n2,n4
	move					a,y:<flags

	; try spherical mapping
	move			x:(r4+n4),x1			; x1: $00:u:v (spherical texture coords)
	jset	#FLG_SPHERICAL,x:<materials,_depack_uv

	; try gouraud shading
	move	#proj_point_z,r4				; Y
	jset	#FLG_GOURAUD,y:<flags,_gouraud

	; try material mapping
	jset	#FLG_TEXMAP,y:<flags,_mapped

	; try env mapping
	move	#rot_pnt_norm_xyz,r4				; Y
	jclr	#FLG_ENVMAP,y:<flags,_skip			; if has no u,v & gouraud -> skip
_envmap:
	move					y:(r4+n4),x1	; x1: $00:u:v (from env mapping)
_depack_uv:
	tfr	x1,a		n5,y0				; a1: $00:u:v
	mpy	x1,y0,b		n6,y0				; b0: u:v:$00
	and	y0,a		b0,b				; a1: u:$00
	and	y0,b		a1,x:(r1)+			; b1: v:$00
	move			b1,x:(r1)+
	jmp	<_skip
_gouraud:
; current shade = max_shade + z * (min_shade-max_shade)/(max_z-min_z)
	move					y:(r4+n4),x1	; x1: current z
	move			x:<shading_ratio,y0
	mpy	x1,y0,a
	asr	a		x:<shading_adder,y0
	move	a0,a
	add	y0,a		#<$00,y0
	tlt	y0,a
	move			a1,x:(r1)+			; s[i] << 8 -> buffer
	jclr	#FLG_TEXMAP,y:<flags,_skip
_mapped:
	move	n5,x1
	move			x:(r6)+,y0
	mpy	y0,x1,a		x:(r6)+,y0
	mpy	y0,x1,b
	jclr	#FLG_WRAPTEX,y:<flags,_no_wrap
	move			x:texture_repeat,y0
	rep	y0
	asl	a
	rep	y0
	asl	b
_no_wrap:
	move			a0,x:(r1)+			; u[i]<<8 -> buffer
	move			b0,x:(r1)+			; v[i]<<8 -> buffer
_skip:
	move					y:<clip_left,y0
_check_loop:
; --- end of test routine ---

	move	#<polygon_data,r1				; X
	move	#<clipped_polygon_data,r2			; X
	move	#mul_1_x,r3					; X
	move	#<0,r4						; vertex counter

	move	#$00000f,x1
	move					y:<flags,b
	and	x1,b						; b1: current material/texture
	move					b,y:<curr_mat

	move	n0,x0						; x0: vertices
	move	#<2,n1						; default is 2 elements (y,x)
	move	n1,a

_sprite:
	cmp	x0,a
	jle	<_line						; >=2 vertices
	;movec	#<2-1,m1
	whost	#PAINT_SPRITE
	jmp	<draw_sprite

_line:
	cmp	x0,a
	jlt	<_polygon_flat					; >2 vertices
	movec	#<4-1,m1
	tst	a						; nonzero

	jsset	#FLG_CLIP_LEFT,y:<flags,line_clip_left
	jeq	<skip_primitive
	jsset	#FLG_CLIP_RIGHT,y:<flags,line_clip_right
	jeq	<skip_primitive
	jsset	#FLG_CLIP_TOP,y:<flags,line_clip_top
	jeq	<skip_primitive
	jsset	#FLG_CLIP_BOTTOM,y:<flags,line_clip_bottom
	jeq	<skip_primitive

	whost	#PAINT_LINE
	jmp	<draw_line

_polygon_flat:
; flat shaded
	jclr	#FLG_FLAT,y:<flags,_polygon_gouraud
	move	#PAINT_FLAT,a

	movem	p:<jump_skip_flat,x1				; x1: jmp <interpolate_x
	movem	x1,p:smc_skip
	movem	x1,p:smc_branch_shade

	jmp	<_calc_wrapper

_polygon_gouraud:
; gouraud shaded
	jclr	#FLG_GOURAUD,y:<flags,_polygon_texture
	jset	#FLG_TEXMAP,y:<flags,_polygon_alpha
	move	#<3,n1						; y,x,c
	move	#PAINT_GOURAUD,a

	movem	p:<jump_skip_gouraud,x1				; x1: jmp <interpolate_s
	movem	x1,p:smc_skip
	movem	p:<jump_gouraud,x1				; x1: jmp <gouraud_shader
	movem	x1,p:smc_branch_shade

	jmp	<_calc_wrapper

_polygon_alpha:
; gouraud + texture mapped (alpha textures)
	jset	#FLG_DSPTEX,y:<flags,_polygon_dsp_alpha
	move	#16,x1
	move					y:<curr_mat,a
	add	x1,a		#<5,n1				; texture + 16 = alphatexture // y,x,c,u,v

	move	#$0fc000,x1					;    0000SSSSSSssssssssssssss
	move			x1,x:<s_mask			; -> 0000SSSSSS00000000000000
	move	#$0fff80,x1					;    0000SSSSSSVVVVVVVvvvvvvv
	move			x1,x:<v_mask			; -> 0000SSSSSSVVVVVVV0000000
	move	#1<<V_SHIFT,x1
	move			x1,x:<v_shift
	move	#1<<U_SHIFT,x1
	move			x1,X:<u_shift

	movem	p:<jump_skip_gouraud,x1				; x1: jmp <interpolate_s
	movem	x1,p:smc_skip
	movem	p:<jump_alphatex,x1				; x1: jmp <alpha_mapper
	movem	x1,p:smc_branch_shade

	jmp	<_calc_wrapper
	
_polygon_dsp_alpha:
; gouraud + texture mapped (alpha textures) for dsp
	move					y:<curr_mat,x1
	jsr	<get_texture
	move					y:<curr_tex,r0	; Y

	;move	#$003f00,x1
	move	#$007e00,x1
	move			x1,x:<s_mask
	;move	#1<<(24-14+8-1),x1
	move	#1<<(24-14+8-1+1),x1
	move					x1,y:<s_shift
	move	#$000fc0,x1					; 6.10 accuracy
	move			x1,x:<v_mask
	move	#<$08,x1					; $080000 = 1<<(20-1)
	move			x1,x:<v_shift
	move	#1<<(14-1),x1
	move			x1,x:<u_shift

	movem	p:<jump_skip_gouraud,x1				; x1: jmp <interpolate_s
	movem	x1,p:smc_skip
	movem	p:<jump_alphatex_dsp,x1				; x1: jmp <alpha_dsp_mapper
	movem	x1,p:smc_branch_shade

	move	#32,x1
	move					y:<curr_mat,a
	add	x1,a		#<5,n1				; texture + 32 = dsp alphatexture // y,x,c,u,v
	
	jmp	<_calc_wrapper

_polygon_texture:
; texture mapped (from envmap or material)
	jset	#FLG_DSPTEX,y:<flags,_polygon_dsp_texture
	move					y:<curr_mat,a
	move	#<4,n1						; y,x,u,v

	move	#V_MASK,x1
	move			x1,x:<v_mask
	move	#1<<V_SHIFT,x1
	move			x1,x:<v_shift
	move	#1<<U_SHIFT,x1
	move			x1,x:<u_shift

	movem	p:<jump_skip_texture,x1				; x1: jmp <interpolate_uv
	movem	x1,p:smc_skip
	movem	p:<jump_texmap,x1				; x1: move l:<v_lr,ab
	movem	x1,p:smc_branch_shade
	movem	p:<cpu_tex1,x1					; lsl a
	movem	x1,p:smc_texmap1
	movem	p:<cpu_tex2,x1					; movep a1,x:<<$ffeb
	movem	x1,p:smc_texmap2
	
	jmp	<_calc_wrapper
	
_polygon_dsp_texture:
; texture mapped (from envmap or material) for dsp
	move					y:<curr_mat,x1
	jsr	<get_texture
	move					y:<curr_tex,r0	; Y

	move	#$000fc0,x1					; 6.10 accuracy
	move			x1,x:<v_mask
	move	#<$08,x1					; $080000 = 1<<(20-1)
	move			x1,x:<v_shift
	move	#1<<(14-1),x1
	move			x1,x:<u_shift

	movem	p:<jump_skip_texture,x1				; x1: jmp <interpolate_uv
	movem	x1,p:smc_skip
	movem	p:<jump_texmap,x1				; x1: move l:<v_lr,ab
	movem	x1,p:smc_branch_shade
	movem	p:<dsp_tex1,x1					; move a1,n0
	movem	x1,p:smc_texmap1
	movem	p:<dsp_tex2,x1					; movep y:(r0+n0),x:<<$ffeb
	movem	x1,p:smc_texmap2

	move	#<4,n1						; y,x,u,v
	move	#PAINT_DSPTEX,a

_calc_wrapper:
	move	n1,x1						; x1: elements
	mpy	x0,x1,b		a,x:paint_command
	asr	b		#1,x0
	move	b0,b
	sub	x0,b						; never will be zero
	movec	b,m1						; m1: vertices * elements - 1

	jsset	#FLG_CLIP_LEFT,y:<flags,polygon_clip_left
	jeq	<skip_primitive					; Z flag MUST NOT be set by default!!!
	jsset	#FLG_CLIP_RIGHT,y:<flags,polygon_clip_right
	jeq	<skip_primitive
	jsset	#FLG_CLIP_TOP,y:<flags,polygon_clip_top
	jeq	<skip_primitive
	jsset	#FLG_CLIP_BOTTOM,y:<flags,polygon_clip_bottom
	jeq	<skip_primitive

	whost	x:paint_command

	jmp	<draw_polygon

end_jump:
	move					y:<backup_rn,r0
	movec	m0,m1
	movec	m0,m2
end_mainloop:
	rts

skip_primitive:
; send -1 to cpu, skip to the next primitive

	whost	#-1
	jmp	<end_jump


; ==========================
; === Main Rotation Loop ===
; ==========================

rotate_mesh:
; This is what is everything about - object rotations and translations.
; new [x y z] = (([x y z]*OR+OC)-CC)*CR+FD = [x y z]*OR*CR + (OC-CC)*CR+FD

; do some backups since matrix generator destroyes everything ;-)
	move	#<backup_rn,r0					; Y
	move	#mesh_buffer,r1
	move					r1,y:(r0)+
	move	#<0,r1						; mesh counter
	move					r1,y:(r0)+
	move	#proj_point_z,r1
	move					r1,y:(r0)+
	move	#points_xyz,r1
	move					r1,y:(r0)+
	move	#proj_point_x,r1
	move					r1,y:(r0)+
	move	#proj_point_y,r1
	move					r1,y:(r0)+
	move	#point_norm_xyz,r1
	move					r1,y:(r0)+
	move	#rot_pnt_norm_xyz,r1
	move					r1,y:(r0)+

	do	x:<objects,mesh_endloop

	move	#<object_matrix,n6				; Y
	jsr	<generate_matrix

	move	#<backup_rn,r6					; Y

; OR*CR
	move	#<object_matrix,r0				; Y
	move	#<camera_matrix,r1				; Y
	move	#<rot_matrix,r2					; Y
	jsr	<mul_matrix_matrix

; (OC-CC)*CR+FD (object vector)

	move					y:(r6),r5	; mesh_buffer (Y)
	move	#<2,n5
	move	#<focus_vector,r0				; X
	move	#<object_vector,r1				; X
	move	#<camera_pos,r2					; X
	move	#<camera_matrix,r4				; Y

; TODO: optimize
	move					y:(r5)+n5,n6	; points per mesh (skip faces per mesh)
	move			x:(r2)+,x0	y:(r5)+,a	; x0: cam_x // a: obj_center_x
	sub	x0,a		x:(r2)+,x1	y:(r5)+,b	; x1: cam_y // b: obj_center_y
	sub	x1,b		a,x0		y:(r5)+,a	; x0: cx - cam_x // a: obj_center_z
	move			x:(r2),x1			; x1: cam_z
	sub	x1,a		b,x1				; x1: cy - cam_y
	move			a,y0				; y0: cz - cam_z
	move					r5,y:(r6)+

	move	(r6)+						; skip counter
	jsr	<mul_vector_matrix_translate

; rotate&translate&project the object according to its center and camera position

	move	#<object_vector,r1				; (OC-CC)*CR+FD (X)
	move					y:(r6)+,r3	; proj_point_z (Y)
	move					y:(r6)+,r0	; points_xyz (X)
	move					y:(r6)+,r5	; proj_point_x (Y)
	move					y:(r6),r6	; proj_point_y (Y)

	jsr	<vertex_projection

	movec	m0,m4
	move	#<backup_rn+2,r1				; skip unimportant stuff
	move	(r0)-
	move	(r4)-
	move					r3,y:(r1)+
	move					r0,y:(r1)+
	move					r5,y:(r1)+
	move					r6,y:(r1)+
	move					y:(r1)+,r0	; point_norm_xyz (X)
	move					y:(r1)-,r5	; rotated - // - (Y)

	jsr	<normal_rotation

	move	(r0)-
	movec	m0,m4						; back to linear
	move					r0,y:(r1)+
	move					r5,y:(r1)
mesh_endloop:
	rts

; ========================
; === Polygon clipping ===
; ========================

polygon_clip_left:
	move	#<clip_left,r5
	do	n0,_endloop

	move	(r1)+						; skip y
	move			x:(r1+n1),b			; x[i+1]
	move			x:(r1)-,a	y:(r5),y1	; x[i]
	cmp	y1,a
	jlt	<_first_out
	cmp	y1,b
	jlt	<_second_out

; both points are inside -> write only 2nd point
	move	(r1)+n1
	jsr	<copy_point
	jmp	<_end_jump

; first point is invisible -> write both points
_first_out:
	cmp	y1,b
	jlt	<_outside					; 2nd point is invisible,too

	jsr	<x_intersect
	jsr	<copy_point
	jmp	<_end_jump

; second point is invisible (but first one is visible) -> write only 2nd point
_second_out:
	jsr	<x_intersect
	jmp	<_end_jump

; whole 'line' is invisible -> just skip
_outside:
	move	(r1)+n1						; next point
_end_jump:
	nop
_endloop:
	jmp	<update_buffer

polygon_clip_right:
	move	#<clip_right,r5					; Y
	do	n0,_endloop

	move	(r1)+						; skip y
	move			x:(r1+n1),b			; x[i+1]
	move			x:(r1)-,a	y:(r5),y1	; x[i]
	cmp	y1,a
	jgt	<_first_out
	cmp	y1,b
	jgt	<_second_out

; both points are inside -> write only 2nd point
	move	(r1)+n1
	jsr	<copy_point
	jmp	<_end_jump

; first point is invisible -> write both points
_first_out:
	cmp	y1,b
	jgt	<_outside					; 2nd point is invisible,too

	jsr	<x_intersect
	jsr	<copy_point
	jmp	<_end_jump

; second point is invisible (but first one is visible) -> write only 2nd point
_second_out:
	jsr	<x_intersect
	jmp	<_end_jump

; whole 'line' is invisible -> just skip
_outside:
	move	(r1)+n1						; next point
_end_jump:
	nop
_endloop:
	jmp	<update_buffer

polygon_clip_top:
	move	#<clip_top,r5					; Y
	do	n0,_endloop

	move			x:(r1+n1),b			; y[i+1]
	move			x:(r1),a	y:(r5),y1	; y[i]
	cmp	y1,a
	jlt	<_first_out
	cmp	y1,b
	jlt	<_second_out

; both points are inside -> write only 2nd point
	move	(r1)+n1
	jsr	<copy_point
	jmp	<_end_jump

; first point is invisible -> write both points
_first_out:
	cmp	y1,b
	jlt	<_outside					; 2nd point is invisible,too

	jsr	<y_intersect
	jsr	<copy_point
	jmp	<_end_jump

; second point is invisible (but first one is visible) -> write only 2nd point
_second_out:
	jsr	<y_intersect
	jmp	<_end_jump

; whole 'line' is invisible -> just skip
_outside:
	move	(r1)+n1
_end_jump:
	nop
_endloop:
	jmp	<update_buffer

polygon_clip_bottom:
	move	#<clip_bottom,r5				; Y
	do	n0,_endloop

	move			x:(r1+n1),b			; y[i+1]
	move			x:(r1),a	y:(r5),y1	; y[i]
	cmp	y1,a
	jgt	<_first_out
	cmp	y1,b
	jgt	<_second_out

; both points are inside -> write only 2nd point
	move	(r1)+n1
	jsr	<copy_point
	jmp	<_end_jump

; first point is invisible -> write both points
_first_out:
	cmp	y1,b
	jgt	<_outside					; 2nd point is invisible,too

	jsr	<y_intersect
	jsr	<copy_point
	jmp	<_end_jump

; second point is invisible (but first one is visible) -> write only 2nd point
_second_out:
	jsr	<y_intersect
	jmp	<_end_jump

; whole 'line' is invisible -> just skip
_outside:
	move	(r1)+n1
_end_jump:
	nop
_endloop:
	jmp	<update_buffer

; =====================
; === Line clipping ===
; =====================

line_clip_left:
	move	#<clip_left,r5

	move	(r1)+						; skip y
	move			x:(r1+n1),b			; x[i+1]
	move			x:(r1)-,a	y:(r5),y1	; x[i]
	cmp	y1,a
	jlt	<_first_out
	cmp	y1,b
	jlt	<_second_out

	jmp	<line_both_visible

_first_out:
	cmp	y1,b
	jlt	<update_buffer					; 2nd point is invisible,too

	jsr	<x_intersect
	jsr	<copy_point
	jmp	<update_buffer

_second_out:
	jsr	<copy_point
	jsr	<x_intersect
	jmp	<update_buffer

line_clip_right:
	move	#<clip_right_line,r5				; Y

	move	(r1)+						; skip y
	move			x:(r1+n1),b			; x[i+1]
	move			x:(r1)-,a	y:(r5),y1	; x[i]
	cmp	y1,a
	jgt	<_first_out
	cmp	y1,b
	jgt	<_second_out

	jmp	<line_both_visible

_first_out:
	cmp	y1,b
	jgt	<update_buffer					; 2nd point is invisible,too

	jsr	<x_intersect
	jsr	<copy_point
	jmp	<update_buffer

_second_out:
	jsr	<copy_point
	jsr	<x_intersect
	jmp	<update_buffer

line_clip_top:
	move	#<clip_top,r5					; Y

	move			x:(r1+n1),b			; y[i+1]
	move			x:(r1),a	y:(r5),y1	; y[i]
	cmp	y1,a
	jlt	<_first_out
	cmp	y1,b
	jlt	<_second_out

	jmp	<line_both_visible

_first_out:
	cmp	y1,b
	jlt	<update_buffer					; 2nd point is invisible,too

	jsr	<y_intersect
	jsr	<copy_point
	jmp	<update_buffer

_second_out:
	jsr	<copy_point
	jsr	<y_intersect
	jmp	<update_buffer

line_clip_bottom:
	move	#<clip_bottom_line,r5				; Y

	move			x:(r1+n1),b			; y[i+1]
	move			x:(r1),a	y:(r5),y1	; y[i]
	cmp	y1,a
	jgt	<_first_out
	cmp	y1,b
	jgt	<_second_out

	jmp	<line_both_visible

_first_out:
	cmp	y1,b						; 2nd point is invisible,too
	jgt	<update_buffer

	jsr	<y_intersect
	jsr	<copy_point
	jmp	<update_buffer

_second_out:
	jsr	<copy_point
	jsr	<y_intersect
	jmp	<update_buffer

x_intersect:

; new y = y1 + dy/dx * (x_clip-x1)

	sub	a,b		x:(r1+n1),a
	move			x:(r1)+,x0	b,y0		; x0: y1
	move	#1,b
	andi	#$fe,ccr
	rep	#24
	div	y0,b
	move	b0,x1						; x1: |1/dx|

	cmp	x0,a		x:(r1+n1),b
	jge	<_pos						; y2 >= y1
	tfr	x0,a		a,x0
	sub	x0,a		(r1)+
	bset	#FLG_SWAP,y:<flags
	jmp	<_neg

_pos:	sub	x0,a		x:(r1)+,b

_neg:	sub	y1,b		a,y0				; y0: dy
	abs	b
	move	b,y1						; y1: x_clip-x1

; x0: y1
; x1: |1/dx|
; y0: dy
; y1: |x_clip-x1|

	mpy	y0,y1,a
	asr	a
	move	a0,y0
	mpy	y0,x1,a
	add	x0,a
	move			a,x:(r2)+	y:(r5),b	; save new y
	move			b,x:(r2)+			; save new x
	jmp	<misc_intersect

y_intersect:

; new x = x1 + dx/dy * (y_clip-y1)

	sub	a,b		(r1)+
	move			x:(r1+n1),a	b,y0
	move	#1,b
	andi	#$fe,ccr
	rep	#24
	div	y0,b

	move	b0,x1						; x1: |1/dy|
	move			x:(r1)-,x0			; x0: x1

	cmp	x0,a		x:(r1+n1),b
	jge	<_pos						; x2 >= x1 ?
	tfr	x0,a		a,x0
	sub	x0,a		(r1)+
	bset	#FLG_SWAP,y:<flags
	jmp	<_neg

_pos:	sub	x0,a		x:(r1)+,b

_neg:	sub	y1,b		a,y0				; y0: dx
	abs	b		(r1)+
	move	b,y1						; y1: y_clip-y1

; x0: x1
; x1: |1/dy|
; y0: dx
; y1: |y_clip-y1|

	mpy	y0,y1,a
	asr	a
	move	a0,y0
	mpy	y0,x1,a				y:(r5),b
	add	x0,a		b,x:(r2)+			; save new y
	move			a,x:(r2)+			; save new x

; intersection for shade, u, v
misc_intersect:
	move	n1,a
	move	#2,x0
	sub	x0,a
	jeq	<_endloop

	do	a,_endloop
	move			x:(r1+n1),a			; t[i+1]
	move			x:(r1)+,b			; t[i]

	jclr	#FLG_SWAP,y:<flags,_ok
	tfr	b,a		a,b
_ok:
	sub	b,a
	rep	#8						; scale down (to avoid an overflow)
	asr	a
	move	a,x0
	mpy	y1,x0,a
	asr	a
	move	a0,x0
	mpy	x1,x0,a
	rep	#8
	asl	a
	add	b,a
	move			a,x:(r2)+
_endloop:

	bclr	#FLG_SWAP,y:<flags
	move	(r4)+
	rts

; point is visible, let's save it into buffer
copy_point:
	do	n1,_endloop
	move			x:(r1)+,x0
	move			x0,x:(r2)+
_endloop:
	move	(r1)-n1
	move	(r4)+
	rts

; both points of line are visible -> just copy
line_both_visible:
	jsr	<copy_point
	move	(r1)+n1
	jsr	<copy_point
	move	#<2,r4

; copies clipped data back to polygon buffer
update_buffer:
	move	#<polygon_data,r1
	move	#<clipped_polygon_data,r2
	move	r4,x0
	move	n1,x1
	mpy	x0,x1,a		r4,n0				; n0: number of vertices
	move	a0,a
	lsr	a		#<0,r4				; a: vertices * elements
	jeq	<_endloop					; no visible points !!!

	tfr	a,b		#1,x0
	sub	x0,b
	movec	b,m1

	do	a,_endloop
	move			x:(r2)+,x0
	move			x0,x:(r1)+
_endloop:
	move	#<polygon_data,r1
	tst	a		#<clipped_polygon_data,r2
	rts

; =====================
; === Algebra Stuff ===
; =====================

mul_matrix_matrix:
; input:  y:(r0) A
;         y:(r1) B
; output: y:(r2) A*B

	move	#<3,n0
	do	#3,_columns
	move					y:(r1)+,x0
	move					y:(r1)+,x1
	move					y:(r1)+,y0

	do	#3,_rows
	move					y:(r0)+n0,y1
	mpy	x0,y1,a				y:(r0)+n0,y1
	mac	x1,y1,a				y:(r0)-n0,y1
	macr	y0,y1,a		(r0)-n0
	move					a,y:(r2)+
	move	(r0)+
_rows:
	move	(r0)-n0
_columns:
	rts

mul_matrix_matrix_n:
; input:  x:(r3) matrix buffer
; output: y:(r0) A(1)*...*A(n)

	move	#<temp_matrix,r2
	move			x:(r3)+,r4				; n matrices
	move			x:(r3)+,r0
	move			x:(r3)+,r1
	move	(r4)-							; n-1 muls

	do	r4,_endloop
	jsr	<mul_matrix_matrix
	move	r2,r0
	move			x:(r3)+,r1
	move	#<temp_matrix,r2
_endloop:
	rts

mul_vector_matrix_translate:
; input:  x0:    v1.x
;         x1:    v1.y
;         y0:    v1.z
;         x:(r0) v2
;         y:(r4) A
; output: v2 + v1*A

	do	#3,_endloop
	move			x:(r0)+,a	y:(r4)+,y1
	mac	x0,y1,a				y:(r4)+,y1
	mac	x1,y1,a				y:(r4)+,y1
	macr	y0,y1,a
	move			a,x:(r1)+
_endloop:
	rts


transpose_matrix:
; input:  y:(r0) A
; output: y:(r1) A^T

	move	#<3,n1
	do	#3,_endloop
	move					y:(r0)+,x0
	move					x0,y:(r1)+n1
	move					y:(r0)+,x0
	move					x0,y:(r1)+n1
	move					y:(r0)+,x0
	move					x0,y:(r1)-n1
	move	(r1)-n1
	move	(r1)+
_endloop:
	rts

generate_matrix:
; 34 cycles matrix generator
; input: n6: dst matrix (Y)
;        r6: sin/cos buffer (Y)

	move			x:sincos_pointer,r6
	move	#cos_alpha,r0					; X
	move	#sin_alpha,r1					; X
	move	#cos_beta,r2					; X
	move	#sin_beta,r3					; X
	move	#<cos_gama,r4					; Y
	move	#<sin_gama,r5					; Y

	move					y:(r6)+,x0	; cos(alpha)
	move			x0,x:(r0)
	move					y:(r6)+,x0	; sin(alpha)
	move			x0,x:(r1)
	move					y:(r6)+,x0	; cos(beta)
	move			x0,x:(r2)
	move					y:(r6)+,x0	; sin(beta)
	move			x0,x:(r3)
	move					y:(r6)+,x0	; cos(gama)
	move					x0,y:(r4)
	move					y:(r6)+,x0	; sin(gama)
	move					x0,y:(r5)
	move			r6,x:sincos_pointer
	move	n6,r6

;    ( +cosBcosC +cosAsinC+sinAsinBcosC +sinAsinC-cosAsinBcosC )
;    ( -cosBsinC +cosAcosC-sinAsinBsinC +sinAcosC+cosAsinBsinC )
;    ( +sinB     -sinAcosB              +cosAcosB              )

	move			x:(r2),x0	y:(r4),y0
	; x0 = cosB; y0 = cosC
	mpyr	+x0,y0,a	x:(r3),b	y:(r5),y1	;  +cosBcosC
	; b = sinB; y1 = sinC
	mpyr	-x0,y1,a	b,x1		a,y:(r6)+	;  -cosBsinC
	; x1 = sinB
	move			x:(r1),x0	a,y:(r6)+	;  +sinB
	; x0 = sinA

	mpyr	+x0,x1,a	x:(r0),x0	b,y:(r6)+	;  +sinAsinB
	; x0 = cosA
	mpyr	+x0,y1,a	a,x1				;  +cosAsinC
	; x1 = +sinAsinB
	macr	+x1,y0,a					;  +sinAsinBcosC
	; ---
	mpy	+x0,y0,a	x:(r2),x0	a,y:(r6)+	;  +cosAcosC
	; x0 = cosB
	macr	-x1,y1,a	x:(r1),x1	b,y0		;  -sinAsinBsinC
	; x1 = sinA; y0 = sinB
	mpyr	-x1,x0,a	x:(r0),x0	a,y:(r6)+	;  -sinAcosB
	; x0 = cosA

	mpyr	+x0,y0,a			a,y:(r6)+	;  +cosAsinB
	; ---
	mpy	+x1,y1,a	a,x0		y:(r4),y0	;  +sinAsinC
	; x0 = +cosAsinB; y0 = cosC
	macr	-x0,y0,a					;  -cosAsinBcosC
	; ---
	mpy	+x0,y1,a	x:(r0),x0	a,y:(r6)+	;  +cosAsinBsinC
	; x0 = cosA
	macr	+x1,y0,a	x:(r2),x1			;  +sinAcosC
	; x1 = cosB
	mpyr	+x0,x1,a			a,y:(r6)+	;  +cosAcosB
	; ---
	move					a,y:(r6)+
	rts

patch_line_clip:
	move					y:<clip_right,r0
	move					y:<clip_bottom,r1
	move	(r0)-
	move	(r1)-
	move					r0,y:<clip_right_line
	move					r1,y:<clip_bottom_line
	rts

; ====================
; === Frame update ===
; ====================

update_scene:
; get values for the new frame

; half y-res?
	move	#$56c10b,x0					; tst b
	rhost	a
	tst	a		#$56c12a,y0			; 0: hires, 1: lowres // asr b
	teq	x0,a
	tne	y0,a
	movem	a1,p:smc1
	
	rhost	x:shading_adder					; max shading value << 14
	rhost	x:shading_ratio					; ds/dz << 14
	rhost	x:texture_repeat

	rhost	y:center_x					; screen center
	rhost	y:center_y					; screen center

	rhost	y:clip_left
	rhost	y:clip_right
	rhost	y:clip_top
	rhost	y:clip_bottom

	jsr	<patch_line_clip

	move	#1<<(8-1),y0					; y0: scale << 8

	rhost	x0
	mpy	x0,y0,a		#<focus_vector,r0		; X
	rhost	x0
	mpy	x0,y0,a		a0,x:(r0)+
	rhost	x0
	mpy	x0,y0,a		a0,x:(r0)+
	move			a0,x:(r0)+

	move			x:<objects,r0
	move	#<sin_cos,r1					; Y
	move			r1,x:sincos_pointer		; reset pointer
	move	(r0)+						; 1+objects

	do	r0,_endloop1
	do	#6,_endloop2					; 3*(cos,sin)
	rhost	y:(r1)+
_endloop2:
	nop
_endloop1:

	rhost	x0
	mpy	x0,y0,a		#<camera_pos,r0			; X
	rhost	x0
	mpy	x0,y0,a		a0,x:(r0)+
	rhost	x0
	mpy	x0,y0,a		a0,x:(r0)+
	move			a0,x:(r0)+

	move	#mesh_buffer+2,r0				; skip points,faces (Y)
	move	#<3,n0
	do	x:<objects,_endloop3
	rhost	x0
	mpy	x0,y0,a
	rhost	x0
	mpy	x0,y0,a				a0,y:(r0)+	; cx*256
	rhost	x0
	mpy	x0,y0,a				a0,y:(r0)+	; cy*256
	move					a0,y:(r0)+n0	; cz*256
_endloop3:

; now calculate new camera position
	move	#<camera_matrix,n6				; Y
	jsr	<generate_matrix

	ifne	0
; transforms camera coordinates (in camera space) to world coordinates (world space)
; camera is set as delta from origin of camera space (eye lies in origin of camera space)
; world space -> camera space: [O](c) = ( [O](w) - [C](w) ) * [CR]
; camera space -> world space: [O](w) =   [O](c) * [CR]^(-1) + [C](w)
; [O](w) = new camera position, [C](w) = old camera position

; invert camera matrix (inverse = transposition)
	move	#<camera_matrix,r0				; Y
	move	#<temp_matrix,r1				; Y
	jsr	<transpose_matrix

	move	#<camera_vector,r0				; camera coords in CS (X)
	move	#<camera_pos,r1					; camera coords in WS (X)
	move	#<temp_matrix,r4				; inverse camera matrix (Y)

	move			x:(r0)+,x0
	move			x:(r0)+,x1
	move			x:(r0),y0

	move	r1,r0						; src = dest
	jsr	<mul_vector_matrix_translate
	endc

	rts

; =============================
; === Receiving Subroutines ===
; =============================

receive_1_x_table:
	move	#mul_1_x+2,r0
	do	#1023,_endloop
	rhost	x:(r0)+
_endloop:
	rti

receive_object:

	move	#1<<(8-1),y0					; scale << 8

; 1. receive global information
	rhost	x:objects
	rhost	x:points
	rhost	x:faces
	rhost	x:materials

; 2. receive objects info & centers
	move	#mesh_buffer,r0

	do	x:<objects,_endloop1
	rhost	y:(r0)+						; points per object
	rhost	y:(r0)+						; faces per object

	rhost	x0
	mpy	x0,y0,a
	rhost	x0
	mpy	x0,y0,a				a0,y:(r0)+	; cx*256
	rhost	x0
	mpy	x0,y0,a				a0,y:(r0)+	; cy*256
	move					a0,y:(r0)+	; cz*256
_endloop1:

; 3. receive points
	move	#points_xyz,r0
	move	#1<<(8-1),y0					; scale << 8

	do	x:<points,_endloop2
	rhost	x0
	mpy	x0,y0,a
	rhost	x0
	mpy	x0,y0,a		a0,x:(r0)+			; x*256
	rhost	x0
	mpy	x0,y0,a		a0,x:(r0)+			; y*256
	move			a0,x:(r0)+			; z*256
_endloop2:

; 4. receive normals
	move	#point_norm_xyz,r0

	do	x:<points,_endloop3
	rhost	x:(r0)+
	rhost	x:(r0)+
	rhost	x:(r0)+
_endloop3:

; 5. receive spherical coordinates
	jclr	#FLG_SPHERICAL,x:<materials,_not_spherical

	move	#vertex_uv,r0
	move	#1<<(8-1),x1
	do	x:<points,_endloop6
	rhost	x0						; u
	mpy	x0,x1,a
	move	a0,a
	rhost	x0						; v
	or	x0,a						; u:v
	move			a1,x:(r0)+
_endloop6:
_not_spherical:

; 6. receive faces
	move	#face_buffer,r0					; X
	move	#1<<(12-1),x1

	do	x:<faces,_endloop4
	rhost	x0						; x0: vertices
	mpy	x0,x1,a		x0,y0				; a0: vertices:$000 // y0: vertices
	move	a0,a
	rhost	y1						; y1: flags
	or	y1,a		x0,b				; a1: vertices:flags // b1: vertices
	lsr	b		a,x:(r0)+

	jclr	#FLG_TEXMAP,a1,_not_uv
	add	y0,b
_not_uv:
	tst	b
	jeq	<_endloop5

; mapped coordinates:
; b = vertices*3 >> 1 = vertices*(2+1) >> 1 = vertices*2 >> 1 + vertices >> 1 =
;   = vertices + vertices >> 1

; default:
; b = vertices >> 1

	do	b,_endloop5
	rhost	y1
	mpy	y1,x1,a
	move	a0,a
	rhost	y1
	or	y1,a
	move			a,x:(r0)+
_endloop5:

	jclr	#0,x0,<_done					; if even points -> we're done
	rhost	x:(r0)+

_done:	nop
_endloop4:
	rts

receive_texture:
	rhost	x1						; number of texture
	jsr	<get_texture
	move					y:<curr_tex,r0
	do	y1,_endloop
	rhost	y:(r0)+
_endloop:
	rts

get_texture:
; input:  x1: number of texture
; output: y:<curr_tex
;         y1: texture size
	move	#64*64,y1
	mpy	x1,y1,a
	asr	a		#textures,b
	move	a0,a
	add	a,b
	move					b,y:<curr_tex
	rts

; ==========================
; === Rendering pipeline ===
; ==========================

start_engine:
	jsr	<update_scene
	jsr	<rotate_mesh

	jsr	<kill_faces					; returns visible faces
	jeq	<end_mainloop

	jsr	<sort_faces
	jmp	<render_scene

; ============================
; === CPU <-> DSP services ===
; ============================

init_engine:
	bset	#2,x:<<$ffe8					; host command enable
	movec	#<0,omr						; disable ROMs

	whost	#'OK!'						; confirm successfull launch

dsp_mainloop:
	rhost	a						; wait for command from host

	move	#'CSR',x0
	cmp	x0,a
	jseq	<call_subroutine

	move	#'RXM',x0
	cmp	x0,a
	jseq	<receive_x_memoryblock

	move	#'RYM',x0
	cmp	x0,a
	jseq	<receive_y_memoryblock

	move	#'RPM',x0
	cmp	x0,a
	jseq	<receive_p_memoryblock

	jmp	<dsp_mainloop

init_player:
	jmp	$7a1e						; ABSOLUTE JUMP!!

call_subroutine:
	move	#<hc_jumptable,r0
	rhost	n0						; number of subroutine
	nop
	movem	p:(r0+n0),r0					; address of subroutine
	nop
	jmp	(r0)

receive_x_memoryblock:
	rhost	r0     	  					; destination adress in x memory
	rhost	x0						; number of words to receive
	do	x0,_endloop
	rhost	x:(r0)+
_endloop:
	rts

receive_y_memoryblock:
	rhost	r0       					; destination adress in y memory
	rhost	x0						; number of words to receive
	do	x0,_endloop
	rhost	y:(r0)+
_endloop:
	rts

receive_p_memoryblock:
	rhost	r0       					; destination adress in p memory
	rhost	x0						; number of words to receive
	do	x0,_endloop
	rhost	p:(r0)+
_endloop:
	rts

end_p_memory:

; --------------------------------------------------------------
;		Internal L memory
; --------------------------------------------------------------

		ORG	L:$0009
x_l:		ds	1
x_r:		ds	1
dx_dy_l:	ds	1
dx_dy_r:	ds	1

s_lr:		ds	1
u_lr:		ds	1
v_lr:		ds	1
ds_dy_lr:	ds	1
du_dy_lr:	ds	1
dv_dy_lr:	ds	1

dy_lr:		ds	1

s_mask_shift:	ds	1
dvdx_dsdx:	ds	1

; --------------------------------------------------------------
;		Internal X memory
; --------------------------------------------------------------

		ORG	X:$0000

shading_ratio:	ds	1					; for gouraud shading
shading_adder:	ds	1

v_shift:	ds	1
v_mask:		ds	1

vis_faces:	ds	1
points:		ds	1
faces:		ds	1
objects:	ds	1
materials:	ds	1

x_il:		ds	1
x_ir:		ds	1
dx_dy_il:	ds	1
dx_dy_ir:	ds	1

s_l:		ds	1
u_l:		ds	1
v_l:		ds	1
ds_dy_l:	ds	1
du_dy_l:	ds	1
dv_dy_l:	ds	1

dy_l:		ds	1

s_mask:		ds	1
dvdx:		ds	1

u_shift:	ds	1

camera_pos:	ds	3					; camera position in world space
focus_vector:	ds	3					; distance
object_vector:	ds	3
camera_vector:	ds	3					; new camera pos in camera space

cos_alpha:	ds	1
sin_alpha:	ds	1

cos_beta:	ds	1
sin_beta:	ds	1
temp_face:	ds	1+8*3					; points, p1, u1, v1, p2, u2, ...

polygon_data:	ds	8*5					; 8 points*(y,x,c,u,v) (%000000)
clipped_polygon_data:
		ds	8*5					;  - // -
		
paint_command:	ds	1
sincos_pointer:	ds	1
texture_repeat:	ds	1

		IFLE	$0100-*
		FAIL	"Internal X memory overflow"
		ENDC

; --------------------------------------------------------------
;		Internal Y memory
; --------------------------------------------------------------

		ORG	Y:$0000

rot_matrix:	ds	9					; posledne 4 bity == %0000

x_fl:		ds	1
x_fr:		ds	1
dx_dy_fl:	ds	1
dx_dy_fr:	ds	1

s_r:		ds	1
u_r:		ds	1
v_r:		ds	1
ds_dy_r:	ds	1
du_dy_r:	ds	1
dv_dy_r:	ds	1

dy_r:		ds	1

s_shift:	ds	1
dsdx:		ds	1

flags:		ds	1

cos_gama:	ds	1
sin_gama:	ds	1

center_x:	ds	1
center_y:	ds	1

clip_left:	ds	1
clip_right:	ds	1
clip_top:	ds	1
clip_bottom:	ds	1

backup_rn:	ds	9

temp_matrix:
object_matrix:	ds	9
camera_matrix:	ds	9

pix_offset:	ds	1					; offset from current draw position

clip_right_line:
		ds	1
clip_bottom_line:
		ds	1
curr_mat:	ds	1					; current material (number of color)
curr_tex:	ds	1					; pointer at current texture

sin_cos:	ds	(MAX_OBJECTS+1)*6			; 3*sin,3*cos for objects+camera
mesh_buffer:	ds	MAX_OBJECTS*5				; points,faces,cx,cy,cz

		IFLE	$0200-*
		FAIL	"Internal/External Y memory overflow"
		ENDC

; --------------------------------------------------------------
;		External X memory
; --------------------------------------------------------------

		ORG	X:$0100					; we don't use a/mu-law table

points_xyz:	ds	MAX_POINTS*3
point_norm_xyz:	ds	MAX_POINTS*3

face_buffer:	ds	MAX_TRIANGLES*(1+1+9+1)/2		; vertices,flags,p1,u1,v1,p2,u2,v2,p3,u3,v3,free
vertex_uv:	equ	face_buffer+MAX_TRIANGLES*(1+1+3+1)/2	; if spherical, we don't need whole buffer

visible_faces:
sorted_faces:
one_array:	ds	MAX_TRIANGLES/2

		IFNE	COMPATIBLE
mul_1_x:	dc	0					; 1/0
		dc	$7fffff					; 1/1
		ds	1023
		ENDC

		IFLE	$3000-*
		FAIL	"External X memory #1 overflow"
		ENDC

; Earxov player lezi v p:$7000 ~ p:$7bb8 = x:$3000 ~ x:$3bb8

		IFEQ	COMPATIBLE
		ORG	X:$3bc0

mul_1_x:	dc	0					; 1/0
		dc	$7fffff					; 1/1
		ds	1023
		ENDC

		IFLE	$4000-*
		FAIL	"External X memory #2 overflow"
		ENDC

; --------------------------------------------------------------
;		External Y memory
; --------------------------------------------------------------

		ORG	Y:end_p_memory

proj_point_x:	ds	MAX_POINTS				; translated, rotated & projected
proj_point_y:	ds	MAX_POINTS				; points buffers
proj_point_z:	ds	MAX_POINTS				; z + dist

rot_pnt_norm_xyz:
		ds	MAX_POINTS				; nx:ny:nz

zero_array:	ds	MAX_TRIANGLES/2

textures:	ds	64*64*2

; still around 2K of free space left!

		IFLE	$3bf8-*
		FAIL	"External Y memory overflow"
		ENDC

; Earxov player lezi v y:$3bf8 ~ y:$3fff