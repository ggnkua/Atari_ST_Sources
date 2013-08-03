;
;	GEN_OBJ.ASM world routines
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
maximum_points		EQU	400
maximum_file_size	EQU	4330
maximum_polys		EQU	400
maximum_objects		EQU	2
maximum_colours		EQU	1

x_min			EQU	-192
x_max			EQU	+191
y_min			EQU	-100/2
y_max			EQU	+100/2
cpersp			EQU	25			;$3fff = wacky fx

flat_handler		EQU	OFF
gouraud_handler		EQU	OFF
texmap_handler		EQU	OFF
phong_handler		EQU	OFF
envmap_handler		EQU	OFF
shademap_handler	EQU	ON

doublescan_adjust	EQU	ON

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

	looptest	A_I,animate_init
	looptest	A_O,animate_object

	looptest	RTS,exit
	jmp		main_loop

exit	rts



;-------------------------------------------------------

; Insert user defined routines here:

;-------------------------------------------------------

;
;	Room distorter / general object sine distorter
;	NOTE: idea could be dodgy because we rely on
;	object_address being already set up. ie. only
;	one object allowed!!
;

animate_init:
	 wait_receive
	movep x:<<hrx,n6		;number of points to get
	clr a
	do n6,_sine_get
		 wait_receive
		movep x:<<hrx,x0
		 wait_receive
		movep x:<<hrx,x0		;ignore the other two...
		 wait_receive
		movep x:<<hrx,x0
_sine_get2:
		nop
_sine_get:
	jmp main_loop


; new animator acts by using the sine offset as a fraction
; along which the NORMAL VECTOR of the point is scaled. This
; is then added to the normal xyz point co-ord

;
; tree animator
;

; this must fetch only a distort period. this is multiplied by
; the y-coordinate of the point, then cos(a) and sin(a) are looked
; up. the point's x and z coordinates are rotated to give the new
; point

; also "squish" distorter, shrink y position and shear x position
; using y

animate_object:
; Install object address (object 1):
	move x:file_address,r0
	move #>C_Objects,n0
	nop
	move y:(r0+n0),a
	move a1,x:object_address

	ori #%000000100,omr				;switch on internal sine rom

	move #>$100,r1					;address of sine table
	move #>$140,r2					;address of cos table
	move #>$ff,m1					;make it loop

; Get the sine period
	  wait_receive
	movep x:<<hrx,x0
	move x0,y:distort_period
	  wait_receive
	movep x:<<hrx,x0
	move x0,y:distort_period2

	move x:object_address,r0		;find the original point data
	move #>O_Point_Ptr,n0
	move #>$ff,m2					;make it loop, too

	move y:(r0+n0),r4				;r4 address of original points
	move #>O_Points,n0
	nop
	move y:(r0+n0),n6				;n6 number of points 
	move #object_points,r0

; r0 output addr
; r1 sine table
; r2 cos table
; r4 original points
; x0 sine period

	do n6,_object_distort_loop
; First get x, then multiply y by x0 (sine period)
		move y:(r4)+,y1					;y1 = x coord
		move y:(r4)+,x1					;x1 = y coord
		move y:distort_period,x0
		mpy x0,x1,a		y:(r4)+,x0		;a = sine*period

		move a1,n1						;x0 = z coord
		move a1,n2
; New x coord is:   x*sin(a) - z*cos(a)
		move y:(r1+n1),y0
		mpy y1,y0,a		y:(r2+n2),y0
		mac -x0,y0,a
		move a1,y:(r0)+

; New z coord is:   x*cos(a) + z*sin(a)
		mpy y0,y1,a		y:(r1+n1),y0
		mac y0,x0,a		x1,y:(r0)+
		move a1,y:(r0)+
_object_distort_loop:

	andi #%11111011,omr		;switch off sine rom
	move #-1,m1

; Now do the squish and shear:
	move #object_points,r0
	move y:distort_period2,y1
	;move #>$7fffff,y1
	do n6,_object_distort_loop_2
		move (r0)+					;x position
		move y:(r0),y0				;y position
		mpy y1,y0,a					;a - shrunken y as proportion
		move a1,y:(r0)+
		move (r0)+
_object_distort_loop_2:

; Distortion now done:
	jmp main_loop



object_rotate_points:
	move #object_points,r4
	jmp object_rotate_points_patch

	include	'f:\dsp_new\asm\3dsys\core2.asm'


;
;
;
;	References to previous INCLUDEs here:
;
;
;

rotate_routine		EQU	object_rotate_points

				org	y:
distort_period2			ds	1
distort_period			ds	1
object_points			ds	3*maximum_points	;must be y mem


