
BLIT		equ	$FFFF8A00
halftone	equ	BLIT+00	;16*16 pattern mask
src_xinc	equ	BLIT+32	;increment of next source word (-128 -> +127)
src_yinc	equ	BLIT+34	;increment of next source line (-128 -> +127)
src_addr	equ	BLIT+36	;source data address
endmask1	equ	BLIT+40	;mask for first word in line (or only word)
endmask2	equ	BLIT+42	;mask for middle words in line
endmask3	equ	BLIT+44	;mask for last word in line
dst_xinc	equ	BLIT+46	;increment of next dest. word (-128 -> +127)
dst_yinc	equ	BLIT+48	;increment of next dest. line (-128 -> +127)
dst_addr	equ	BLIT+50	;destination screen address
x_size	equ	BLIT+54	;x-size	(number of words to go)
y_size	equ	BLIT+56	;y_size	(number of lines to go)
HOP		equ	BLIT+58	;halftone operation...
blit_op	equ	BLIT+59	;logic operations
blit_stat	equ	BLIT+60	;blitter chip status registers
skew		equ	BLIT+61	;offset bit shift (byte, 0 > +-15)

