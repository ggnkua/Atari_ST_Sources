;
; General morphing section.
;
;
;
;
;

morph_init:
	move #morph_points_1,r0
	jsr fetch_points
	move #morph_normals_1,r0
	jsr fetch_points

	move #morph_points_2,r0
	move #morph_points_1,r1
	jsr fetch_points2
	move #morph_normals_2,r0
	move #morph_normals_1,r1
	jsr fetch_points2
	jmp main_loop

fetch_points:
	 wait_receive
	movep x:<<hrx,x0

	do x0,_get
	do #3,_get2
		 wait_receive
		movep x:<<hrx,a
		asr a
		move a,y:(r0)+
_get2:	nop
_get:
	rts

; this time we want the OFFSET!

fetch_points2:
	 wait_receive
	movep x:<<hrx,x0

	do x0,_get
	do #3,_get2
		move y:(r1)+,x0					; get original value
		 wait_receive
		movep x:<<hrx,a
		asr a
		sub x0,a
		move a1,y:(r0)+
_get2:	nop
_get:
	rts

;
; morpher:
;
; multiply the offset (r1)+ by the morph_points, then add (r0)+
;
;
;


morph_object:
; Install object address (object 1):
	move x:file_address,r0
	move #>C_Objects,n0
	nop
	move y:(r0+n0),a
	move a1,x:object_address

	  wait_transmit
	move #'OK!',x0
	movep x0,x:<<hrx				;y0 = multiplier
	  wait_receive
	movep x:<<hrx,y0				;y0 = multiplier

	move x:object_address,r0		;find the original point data
	move #>O_Point_Ptr,n0
	move #morph_points_2,r1
	move y:(r0+n0),r4				;r4 address of output
	move #>O_Points,n0
	nop
	move y:(r0+n0),x1
	move #morph_points_1,r0
	jsr morph_it

	move x:object_address,r0		;find the original point data
	move #>O_Gour_Ptr,n0
	move #morph_normals_2,r1
	move y:(r0+n0),r4				;r4 address of output
	move #>O_Points,n0
	nop
	move y:(r0+n0),x1
	move #morph_normals_1,r0
	jsr morph_it
	jmp main_loop

morph_it:
	do x1,_object_morph_loop
		move y:(r1)+,x0
		move y:(r0)+,a
		macr x0,y0,a
		asl a
		move a1,y:(r4)+
		move y:(r1)+,x0
		move y:(r0)+,a
		macr x0,y0,a
		asl a
		move a1,y:(r4)+
		move y:(r1)+,x0
		move y:(r0)+,a
		macr x0,y0,a
		asl a
		move a1,y:(r4)+
_object_morph_loop_2:
		nop								;aaaaaarrrggghh!
_object_morph_loop:
	rts

	include	'f:\dsp_new\asm\3dsys\core2.asm'


;
;
;
;	References to previous INCLUDEs here:
;
;
;

rotate_routine		EQU	rotate_points

						org	y:
morph_points_1			ds	3*maximum_points
morph_points_2			ds	3*maximum_points
morph_normals_1			ds	3*maximum_points
morph_normals_2			ds	3*maximum_points

