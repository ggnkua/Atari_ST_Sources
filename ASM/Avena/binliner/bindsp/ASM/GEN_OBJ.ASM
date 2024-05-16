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

					include	'd:\dsp\asm\base.asm'

; Equates:
maximum_points		EQU	450
maximum_file_size	EQU	4400
maximum_polys		EQU	520
maximum_objects		EQU	13
maximum_colours		EQU	1

x_min				EQU	-192
x_max				EQU	+190
y_min				EQU	-50
y_max				EQU	+50
cpersp				EQU	25			;$3fff = wacky fx

flat_handler		EQU	ON
envmap_handler		EQU	ON
texmap_handler		EQU	ON
shademap_handler	EQU	ON
doublescan_adjust	EQU	ON

; Setup:
	org p:$210
	;movep #>0,x:<<BCR
	;movep #>1,x:<<PBC
	;andi #$fc,MR
	jsr receive_one_over

; Comparisons:
	jmp		main_loop

exit	rts



;-------------------------------------------------------

; Insert user defined routines here:

;-------------------------------------------------------

	include	'd:\dsp\asm\3dsys\core2e.asm'

rotate_routine		EQU	rotate_points

