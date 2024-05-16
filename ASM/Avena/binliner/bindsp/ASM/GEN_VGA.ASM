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
maximum_file_size	EQU	4000
maximum_polys		EQU	400
maximum_objects		EQU	3
maximum_colours		EQU	1

x_min			EQU	-160
x_max			EQU	+160
y_min			EQU	-100
y_max			EQU	+100
cpersp			EQU	25			;$3fff = wacky fx

flat_handler		EQU	ON
gouraud_handler		EQU	OFF
texmap_handler		EQU	ON
phong_handler		EQU	OFF
envmap_handler		EQU	OFF
shademap_handler	EQU	OFF
shademap2_handler	EQU	OFF

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
	IF		gouraud_handler||flat_handler
	looptest	COL,receive_colours
	ENDIF

	looptest	OBJ,receive_object
	looptest	LIG,receive_light
	looptest	MAT,receive_rotation
	looptest	VIE,receive_viewpoint

	looptest	CAL,calc_object
	looptest	HAN,handle_file
	looptest	HA1,handle_one_object
	looptest	TEX,receive_texmap
	looptest	CLI,receive_clipping

	looptest	RTS,exit
	jmp		main_loop

exit	rts



;-------------------------------------------------------

; Insert user defined routines here:

;-------------------------------------------------------

	include	'f:\dsp_new\asm\3dsys\core2.asm'

rotate_routine		EQU	rotate_points

