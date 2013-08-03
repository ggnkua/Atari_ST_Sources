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
maximum_points		EQU	187+2
maximum_file_size	EQU	3800
maximum_polys		EQU	185+2
maximum_objects		EQU	2
maximum_colours		EQU	1

x_min				EQU	-192
x_max				EQU	+191
y_min				EQU	-100/2
y_max				EQU	+100/2
cpersp				EQU	25			;$3fff = wacky fx

flat_handler		EQU	OFF
gouraud_handler		EQU	OFF
texmap_handler		EQU	OFF
phong_handler		EQU	OFF
envmap_handler		EQU	OFF
shademap_handler	EQU	ON
shademap2_handler	EQU	ON

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

	looptest	A_I,bee_init
	looptest	A_O,bee_object

	looptest	RTS,exit
	jmp		main_loop

exit	rts

;
;
;
; First get the "original" object points
;
;
;

bee_init:
	move #bee_points_1,r0
	jsr _fetch_points
	move #bee_normals_1,r0
	jsr _fetch_points
	jmp main_loop

_fetch_points:
	 wait_receive
	movep x:<<hrx,x0

	do x0,_get
		do #3,_get2
			 wait_receive
			movep x:<<hrx,x0
			move x0,y:(r0)+
_get2:	nop
_get:
	rts


;
; beeer:
;
; multiply the offset (r1)+ by the bee_points, then add (r0)+
;
;
;


bee_object:
; Install object address (object 1):
	 wait_receive
	movep x:<<hrx,x0
	move x0,y:bee_frame
	jmp main_loop

bee_rotate_points:
	move y:bee_frame,a1
	jclr #1,a1,_b2
	move #bee_points_1,r4
	jmp object_rotate_points_patch
_b2:
	move x:object_address,r0
	move #>O_Point_Ptr,n0
	nop
	move y:(r0+n0),r4
	jmp object_rotate_points_patch

normals_patch:
	move y:bee_frame,a1
	jclr #1,a1,_b2
	move #bee_normals_1,r6
	rts
_b2:
	move x:object_address,r0
	move #>O_Gour_Ptr,n0
	nop
	move y:(r0+n0),r6
	rts


	include	'f:\dsp_new\asm\3dsys\core2.asm'

rotate_routine		EQU	bee_rotate_points

				org	y:
bee_frame		dc	0
bee_points_1	ds	3*maximum_points	;must be y mem
bee_normals_1	ds	3*maximum_points	;must be y mem

