PHYSX		=	320		; Maximum physical resolution
PHYSY		=	480

XRES		=	320             ; Virtual screen resolution
YRES		=	192


TTXRES		=	PHYSX
TTYRES		=	PHYSY
FXRES		=	XRES
FYRES		=	YRES

	ifeq	MODE-RGB_24BPP		; Colordepth in bits
COLORDEPTH	=	24		; Let's pretend we have a 24bpp RGB mode
	else				; on the falcon
COLORDEPTH	=	8
	endc

NULL		=	0
NIL		=	0
TRUE		=	-1
FALSE		=	0

TT030		=	0
F030		=	1

KEY_QUIT	=	$39		; Esc = Quit
