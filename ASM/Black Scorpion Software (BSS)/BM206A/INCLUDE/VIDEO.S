*=======================================================*
*	Video definitions: latest update 21/11/95	*
*=======================================================*

*-------------------------------------------------------*
*	Modecode bits					*
*-------------------------------------------------------*

		rsreset
plane_bits	rs.b	2
true_bit	rs.b	1
hires_bit	rs.b	1
vga_bit		rs.b	1
pal_bit		rs.b	1
os_bit		rs.b	1
compat_bit	rs.b	1
lace_bit	rs.b	1

*-------------------------------------------------------*
*	Bitplane codes					*
*-------------------------------------------------------*

		rsreset
bpl1		rs.b	1
bpl2		rs.b	1
bpl4		rs.b	1
bpl8		rs.b	1

*-------------------------------------------------------*
*	Modecode elements				*
*-------------------------------------------------------*

true		=	1<<true_bit
hires		=	1<<hires_bit
vga		=	1<<vga_bit
pal		=	1<<pal_bit
os		=	1<<os_bit
compat		=	1<<compat_bit
lace		=	1<<lace_bit

*-------------------------------------------------------*
*	Various HW video registers			*
*-------------------------------------------------------*

BORDER_START	=	$FFFF82A4
BORDER_STOP	=	$FFFF82A6

SCAN_START	=	$FFFF82A8
SCAN_STOP	=	$FFFF82AA

*-------------------------------------------------------*
