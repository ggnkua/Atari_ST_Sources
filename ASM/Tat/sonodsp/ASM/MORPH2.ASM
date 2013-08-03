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
maximum_points		EQU	224
maximum_file_size	EQU	3300
maximum_polys		EQU	385
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
	looptest	CLI,receive_clipping

	looptest	M_I,morph_init
	looptest	M_O,morph_object

	looptest	RTS,exit
	jmp		main_loop

exit	rts

	include		'f:\dsp_new\asm\3dsys\morphin2.asm'

