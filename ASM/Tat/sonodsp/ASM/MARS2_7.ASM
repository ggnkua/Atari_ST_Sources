; MARS2.ASM
; Routines for 'Useless'
; Tabs at 4

; Mar '96-


; Unforseen problems emerge quite quickly...

; 28/3/96 - Most problems fixed, only y_offset to add now
; 28/3/96 - fixing bug with heights of 1
;         - overall size
; 14/11/96 - nearly re-written to allow rotation round x-axis


screen_width		=	192
screen_height		=	200/2
screen_top		=	-50
screen_bottom		=	+50

pixels_per_line		=	318
z_levels			=	32

depth_cue_max		=	$3fff*4
depth_cue_mul		=	-depth_cue_max/(16*$200)


; Equates:
	include	'f:\dsp_new\asm\base.asm'

; Setup:
	org p:$210
	;movep #>0,x:<<BCR
	;movep #>1,x:<<PBC
	;andi #$fc,MR

;-------------------------------------------------------
	;jsr get_one_over
main_loop
		clr a
		wait_receive
		movep x:<<hrx,a1	;Receive control word
		looptest	RTS,exit

		looptest	ZTA,receive_z_table
		looptest	ONE,receive_one_over_table
		looptest	CAL,calc_planet
		looptest	SIN,receive_sine
		looptest	SI2,receive_sine_2
		looptest	MOV,receive_movement
	jmp main_loop

exit	rts
;-------------------------------------------------------


;-------------------------------------------------------
calc_planet:
	jsr	init_tables
	jsr	do_calc
	jmp	main_loop

init_tables:
	move #last_height_table,r0
	move #last_colour_table,r1
	move #max_height_table,r2
	move #>screen_bottom,x0
	move #>depth_cue_max/2/2,x1
	;move #>$7FFFFF,x0
	do	#screen_width,_fill
		move x0,x:(r0)+
		move x1,x:(r1)+
		move x0,x:(r2)+
_fill:
	rts

do_calc:
	move y:row_count,n6
	move #z_table,r0
	move #$0fff,m2
	move #$0fff,m3

	do	n6,do_z_line
		jsr	fetch_r0_stuff
		jsr	precalc_z_fractions

; We can calculate the zh height and colour multipliers here!

		move #max_height_table,r1
		move #last_colour_table,r4
		move #0,r5							;'across' counter

		do #screen_width,do_column

; Calc xh_height component
			move y:xcurrent,x0
			move #frac3a,r6
			jsr calculate_fraction
			move a1,y:xh_height

; Calc overall colour:
; Move this to after height calc?
			move y:xcurrent,x0
			move #frac4a,r6
			jsr calculate_fraction
			move y:zh_colour,x0
			add x0,a
; The max value for this is -$200000 to $1fffff (+/- 0.25)
; We must correct it to the region 0 to $3fffff
			move #>$200000,x0
			add x0,a
			move a1,x0

			;move #>$3fff,y0
			move y:colour_mul,y0			;*2 for integer maths
			mpy x0,y0,a						;make it positive
			move a1,y:this_colour

; Now calculate the new height:
			move y:xh_height,a				;(xh+zh)
			move y:zh_height,x0
			add x0,a
			move a1,x1						;Mult wave by overall size

			move y:y_scale_rotated,y0		;whole
			move y:rowcentre_y_screen,a
			mac x1,y0,a						;was MAC
			move #>0,a0
			move #>screen_bottom,x0
; a is now the new height
; limit the value:
			cmp x0,a		#>screen_top,x1	;limit height to screenbottom
			tge x0,a
			cmp x1,a
			tle x1,a

; Compare with last height
			move x:(r1),x0					;fetch lowest val so far
			cmp x0,a		a1,y:new_height
			jge	no_draw_line				;if last>this, draw it!
											; else if gtr/same, skip

			move a,x:(r1)					;save new min-val
			sub x0,a
			neg a
			move a1,y:height_offset

; b1 now the distance between.
;---------------------------------------------------------------------
; Send the screen offset:
			move y:new_height,x1
			move #>pixels_per_line/2,x0
			move r5,b0
			mac x1,x0,b		;r5,x0
			move b0,b
			 wait_transmit
			movep b1,x:<<htx

; Send the height:
			 wait_transmit
			movep a1,x:<<htx

; Calculate the colour difference
			move y:this_colour,x0			;x0 new value

	; Send initial value
			 wait_transmit
			movep x0,x:<<htx				;start colour -128 to 127!

	; Do the one-over trick
			move x:(r4),b					;b old value
			move x0,x:(r4)					;save last colour
			sub x0,b						;(b - a)
	; Send fraction
			move #one_over_table,r6
			move y:height_offset,n6
			move b1,x0						;(b - a) *  1
			move y:(r6+n6),x1				;          --
			mpy x0,x1,a						;          dy
			 wait_transmit
			movep a1,x:<<htx
			jmp	skip_no_draw_line

; Colour handling
no_draw_line:
			move y:this_colour,x0			;x0 new value
			move x0,x:(r4)					;save colour

skip_no_draw_line:
			move (r1)+
			move (r4)+						;next colour
			move (r5)+						;move across
			move y:this_colour,x0

	; Move along in z-values
			move y:xcurrent,a
			move y:xstep,x1
			add x1,a
			move a1,y:xcurrent
do_column:
			nop
do_z_line:
	jsr send_delta_values
	rts




fetch_r0_stuff:
		move x:(r0)+,x0					;rowcentre_z
		move x0,y:rowcentre_z

		move x:(r0)+,x0
		move x0,y:y_scale_rotated

		move x:(r0)+,x0
		move x0,y:rowcentre_y_screen

		move x:(r0)+,x0
		move x0,y:xcurrent

		move x:(r0)+,x0
		move x0,y:xstep

		clr a
		move x:(r0)+,x0
		move #>depth_cue_mul,y0
		move #>depth_cue_max,a0
		mac x0,y0,a
		move a0,y:colour_mul
		rts


send_delta_values
; Send a negative value here?
	move #>"END",x0
	 wait_transmit
	movep x0,x:<<htx

	move #-1,m2
	move #-1,m3

	move #>max_height_table,r0
	do #screen_width,_send2
		wait_transmit
		move x:(r0)+,x0
		movep x0,x:<<htx
_send2
	rts


precalc_z_fractions:
	move y:rowcentre_z,x0
	move #frac1a,r6
	jsr calculate_fraction
	move a1,y:zh_height

	move y:rowcentre_z,x0
	move #frac2a,r6
	jsr calculate_fraction
	move a1,y:zh_colour
	rts




; x0 - x/z value to find for
; value is sin(z*frac1a)*sin(z*frac1b)*sin(z*frac1c)

; Therefore min/max outcome is -/+ 0.5*0.5*0.5 = 1/8

calculate_fraction:
	move #>$0fff,y0
	move y:(r6)+,x1						;               fetch frac-a
	mpy x0,x1,a		y:(r6)+,x1			;calc z*frac-a, fetch frac-b
	mpy x0,x1,b		y:(r6)+,x1			;calc z*frac-b
	move y:(r6)+,r2
	and y0,a
	and y0,b		a1,n2				;conv frac-a
	mpy x0,x1,a		b1,n3				;calc z*frac-c
	move y:(r6)+,r3
	and y0,a		x:(r2+n2),x0
	move x:(r3+n3),x1
	move y:(r6)+,r3
	mpy	x0,x1,b		a1,n3
	move b1,x0
	move x:(r3+n3),x1
	mpy x0,x1,a
	rts

;-------------------------------------------------------
receive_sine_2:
	move #sine_table_2,r0
	jmp recsine

receive_sine:
	move #sine_table,r0
recsine:
	move #>$1000,n0
	do	n0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	jmp	main_loop

;-------------------------------------------------------
receive_z_table:
	move #>-1,x1
	move #z_table,r0
	move #0,r6						;counter
_z_table_loop:
	wait_receive
	movep x:<<hrx,a
	cmp x1,a						;-1?
	jeq _z_table_done

	move (r6)+						;increase count
	move a1,x:(r0)+

	move #6-1,n0					;increased 24/12/96
	do	n0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,x:(r0)+
_get:
	jmp _z_table_loop
_z_table_done:
	move r6,y:row_count
	jmp	main_loop

;-------------------------------------------------------
receive_one_over_table:
	move #one_over_table,r0
	move #200,n0
	do	n0,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+
_get:
	jmp	main_loop

;-------------------------------------------------------
receive_movement:
	move #mov1,r0
	jsr _get3
	move #mov2,r0
	jsr _get3
	move #mov3,r0
	jsr _get3
	move #mov4,r0
	jsr _get3

;	move #x_offset,r0
;	do	#5,_get_4
;		wait_receive
;		movep x:<<hrx,x0
;		move x0,y:(r0)+
;_get_4
	jmp	main_loop

_get3
	do	#3,_get
		wait_receive
		movep x:<<hrx,x0
		move x0,y:(r0)+
_get:
	rts











;-------------------X MEMORY-----------------------------
					org	x:$1000-8*z_levels
z_table				ds	8*z_levels		;xxxx  bsp-words

					org	x:$1000
sine_table			ds	$1000
sine_table_2		ds	$1000


; Above list contains:

;   rowcentre_z							integer
; 	y_scale_rotated						integer
;	rowcentre_y_screen					integer
; 	Xstep 								INTEGER
; 	xcurrent = (-96) * Xstep			INTEGER
;	rowcentre_z_shading					integer


;-------------------Y MEMORY-----------------------------

					org	y:$1
y_scale_rotated		ds	1
save_xstep			ds	1
xcurrent			ds	1
xstep				ds	1
rowcentre_z			ds	1
rowcentre_y_screen	ds	1

zh_height			ds	1
zh_colour			ds	1
xh_height			ds	1
this_colour			ds	1
new_height			ds	1
height_offset		ds	1
colour_mul			ds	1
row_count			ds	1

frac1a				dc	+0.2318					;z height
frac1b				dc	+0.7921
frac1c				dc	-0.5838
mov1				dc	$2000,$1f00,$1000

frac2a				dc	-0.46982				;z colour
frac2b				dc	+0.37924
frac2c				dc	+0.4913
mov2				dc	$1f00,$2000,$1000

frac3a				dc	-0.01978				;x height
frac3b				dc	-0.024211
frac3c				dc	+0.013918
mov3				dc	$1000,$1000,$2800

frac4a				dc	-0.01422				;x colour
frac4b				dc	+0.029232
frac4c				dc	+0.019323
mov4				dc	$1000,$2f00,$1000


;--------------------------------------------------------
					org	y:$800
last_height_table	ds	screen_width
last_colour_table	ds	screen_width
max_height_table	ds	screen_width
one_over_table		ds	200
