PHYSX		=	320		; Physical resolution
PHYSY		=	480

TTXRES		=	PHYSX
TTYRES		=	PHYSY
FXRES		=	PHYSX
FYRES		=	PHYSY

COLORDEPTH	=	8

NULL		=	0
NIL		=	0
TRUE		=	-1
FALSE		=	0

TT030		=	0
F030		=	1

KEY_QUIT	=	$39		; Esc = Quit

XRES		=	256		; Resolution of the mandelbrot window
YRES		=	XRES*3/2	;>256

; Fractal constants

FRACBITS	=	11		; Fixedpoint accuracy
XMIN		=	(-225<<FRACBITS)/100	; Initial area
XMAX		=	(80<<FRACBITS)/100
YMIN		=	(-115<<FRACBITS)/100
YMAX		=	(115<<FRACBITS)/100
MAXRAD		=	2<<FRACBITS	; Radial limit
MAXITER		=	48-1		; Number of iterations

XCLIPLEFT	=	(-250<<FRACBITS)/100	; Maximum bounding box
XCLIPRIGHT	=	(100<<FRACBITS)/100
YCLIPTOP	=	(-150<<FRACBITS)/100
YCLIPBOT	=	(150<<FRACBITS)/100
