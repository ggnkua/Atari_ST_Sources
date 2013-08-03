;
;	UNDERSEA.ASM world routines
;
;	now in more sensible format to allow selected effects only
;	(saves memory)
;
;
;
;
;
;
;
	include	'f:\dsp_new\asm\base.asm'

; Equates:
maximum_points		EQU	170
maximum_file_size	EQU	1700
maximum_polys		EQU	170
maximum_objects		EQU	20
maximum_colours		EQU	4

x_min			EQU	-192
x_max			EQU	+191
y_min			EQU	-100/2
y_max			EQU	+100/2
cpersp			EQU	25	;$3fff = wacky fx


flat_handler		EQU	OFF
gouraud_handler		EQU	ON
texmap_handler		EQU	OFF
phong_handler		EQU	OFF
envmap_handler		EQU	OFF


doublescan_adjust	EQU	OFF

; Setup:
	org p:$210
	;movep #>0,x:<<BCR
	;movep #>1,x:<<PBC
	;andi #$fc,MR
	jsr receive_one_over

main_loop:
	clr a
	wait_receive
	movep x:<<hrx,a1	;Receive control word

; Comparisons:
	IF		gouraud_handler
	looptest	COL,receive_colours
	ENDIF

	looptest	OBJ,receive_object
	looptest	LIG,receive_light
	looptest	MAT,receive_rotation
	looptest	VIE,receive_viewpoint

	looptest	CAL,calc_object
	looptest	HAN,handle_file
	looptest	TEX,receive_texmap
	looptest	CLI,receive_clipping

	looptest	FCO,set_fish_colour
	looptest	FIS,distort_fish

	looptest	RTS,exit
	jmp		main_loop

exit	rts



;-------------------------------------------------------

; Insert user defined routines here:

;-------------------------------------------------------

;
;	Fish distorter
;	NOTE: idea could be dodgy because we rely on
;	object_address being already set up. ie. only
;	one object allowed!!
;
;	Object distorter can be easily changed to allow
;	more complex distortions
;
;

fish_distort_period = 0.3


distort_fish:
	ori #%000000100,omr		;switch on internal sine rom
	move #>$100,a			;address of sine table

	move #>$ff,m1			;make it loop
	  wait_receive
	movep x:<<hrx,x0		;receive offset
	add x0,a
	move a,r1

	  wait_receive
	movep x:<<hrx,x0
	move x0,y:fish_distort_size	;receive size


; Install object address (object 1):
	move x:file_address,r0
	move #>C_Objects,n0
	nop
	move y:(r0+n0),a
	move a1,x:object_address


	move x:object_address,r0
	move #>O_Point_Ptr,n0
	move #-1,m2
	move y:(r0+n0),r4		;r4 address of original points
	move #>O_Points,n0
	move #fish_distort_period,y0
	move y:(r0+n0),n6		;n6 number of points 
	move #fish_points,r0

; We now want to distort the z (depth) coordinate, depending
; on the value of x (horizontal)

	do n6,_fish_distort_loop

	  move y:(r4)+,y1			;y1 = x
	  move y1,y:(r0)+			;	*Store X (UNCHANGED)
	  move y:(r4)+,x1			;x0 = y

	  move y:(r4)+,x0			;x0 = z
	  move x0,b1				;b1 = z  y0 = f_d_p
	  mpy y1,y0,a	y:fish_distort_size,y1
						;a1 = (f_d_p)x
	  move a1,n1				;
	  move x1,y:(r0)+			;	*Store Y (UNCHANGED)
	  move y:(r1+n1),y0			;y0 = sin((f_d_p)x)
	  mac y1,y0,b	#fish_distort_period,y0	;b  = z + (f_d_s *
						;	    sin((f_d_p)x) )
	  move b1,y:(r0)+			;	*Store Z (CHANGED)
_fish_distort_loop:
	andi #%11111011,omr		;switch off sine rom
	move #-1,m1
	jmp main_loop



fish_rotate_points:
	move #fish_points,r4
	jmp fish_rotate_points_patch



set_fish_colour:
	wait_receive
	movep	x:<<hrx,x0
	move	#>128/2,y0
	move	#gouraud_colours,a0
	mac	x0,y0,a
	move	a0,x:gouraud_colour_address
	jmp	main_loop



	include	'f:\dsp_new\asm\3dsys\core2.asm'


;
;
;
;	References to previous INCLUDEs here:
;
;
;

rotate_routine		EQU	fish_rotate_points

			org	y:
fish_distort_size	ds	1
fish_points		ds	3*maximum_points	;must be y mem


