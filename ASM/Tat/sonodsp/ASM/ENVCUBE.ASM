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
maximum_points		EQU	200
maximum_file_size	EQU	4000
maximum_polys		EQU	400
maximum_objects		EQU	3
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
envmap_handler		EQU	ON
shademap_handler	EQU	OFF
shademap2_handler	EQU	OFF

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
	looptest	HA1,handle_one_object
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
	move #object_distort_data,r0
	 wait_receive
	movep x:<<hrx,n6		;number of points to get
	clr a
	do n6,_sine_get
			 wait_receive
			movep x:<<hrx,x0
			move x0,y:(r0)+			;sine speed (only need one)

			 wait_receive
			movep x:<<hrx,x0		;ignore the other two...
			 wait_receive
			movep x:<<hrx,x0

			move a,y:(r0)+			;current sine position
_sine_get2:
		nop
_sine_get:
	jmp main_loop


; new animator acts by using the sine offset as a fraction
; along which the NORMAL VECTOR of the point is scaled. This
; is then added to the normal xyz point co-ord

animate_object:
; Install object address (object 1):
	move x:file_address,r0
	move #>C_Objects,n0
	nop
	move y:(r0+n0),a
	move a1,x:object_address

	ori #%000000100,omr				;switch on internal sine rom
	move #>$100,r1					;address of sine table
	move #>$ff,m1					;make it loop
	move #>$ff,y1					;???!
	  wait_receive
	movep x:<<hrx,y0
	move y0,y:anim_size

	move x:object_address,r0		;find the original point data
	move #>O_Point_Ptr,n0
	move #-1,m2
	move y:(r0+n0),r4				;r4 address of original points
	move #>O_Points,n0
	move #object_distort_data,r2	;sines/sine speeds (3 x points)
	move y:(r0+n0),n6				;n6 number of points 
	move #O_Gour_Ptr,n0
	nop
	move y:(r0+n0),r5				;r5 gouraud vectors 

	move #object_points,r0

; r0 output addr
; r1 sine table
; r2 obj distort data
; r4 original points
; r5 original normvector data (gouraud)
; r6
; y0 sine size

	do n6,_object_distort_loop
; First, move through the table.
; Then add the sized sine to the undistorted co-ord.
			move y:(r2)+,x0				;what to add
			move y:(r2),a				;current sine position
			add x0,a					;b1 = un-distorted position
			and y1,a
			move a1,n1
			move a1,y:(r2)+				;store sine again

			move y:(r1+n1),x0			;lookup sine value for [n1]
		  	mpy x0,y0,b					;size sine, accumulate..
			move b1,x0					;y1 is the new "size"

			do #3,_object_distort_loop_2
				move y:(r4)+,a			;original point
				move y:(r5)+,x1			;original vector
				macr x1,x0,a
				move a1,y:(r0)+
_object_distort_loop_2:
		nop								;aaaaaarrrggghh!
_object_distort_loop:

; Distortion now done:
	andi #%11111011,omr		;switch off sine rom
	move #-1,m1
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
object_distort_data		ds	2*maximum_points
object_points			ds	3*maximum_points	;must be y mem
anim_size				ds	1






