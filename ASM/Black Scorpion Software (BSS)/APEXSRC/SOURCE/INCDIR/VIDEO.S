
		rsreset
plane_bits	rs.b	2	; 0
true_bit	rs.b	1	; 2
hires_bit	rs.b	1	; 3
vga_bit		rs.b	1	; 4
pal_bit		rs.b	1	; 5
os_bit		rs.b	1	; 6
compat_bit	rs.b	1	; 7
lace_bit	rs.b	1	; 8

		rsreset
bpl1		rs.b	1
bpl2		rs.b	1
bpl4		rs.b	1
bpl8		rs.b	1

true		=	1<<true_bit
hires		=	1<<hires_bit
vga		=	1<<vga_bit
pal		=	1<<pal_bit
os		=	1<<os_bit
compat		=	1<<compat_bit
lace		=	1<<lace_bit

BORDER_START	=	$FFFF82A4
BORDER_STOP		=	$FFFF82A6

SCAN_START		=	$FFFF82A8
SCAN_STOP		=	$FFFF82AA
