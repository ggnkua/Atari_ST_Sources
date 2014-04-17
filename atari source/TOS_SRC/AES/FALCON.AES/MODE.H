
/*
 * mode.h
 * ======================================================================
 * Falcon/030 setmode call and defines.
 * 
 * 920608 towns	created.
 *
 */

/* NOTE: These XBIOS numbers are subject to CHANGE. In fact, I know 
 *       they will CHANGE. DO NOT RELY ON THEM.
 */

#define setmode(a)	(int)xbios(88,a)
#define mon_type(a)	(int)xbios(89)
#define ext_sync(a)	(void)xbios(90,a)

#define VERTFLAG	0x100
#define STMODES		0x80
#define OVERSCAN	0x40
#define PAL		0x20
#define	VGA		0x10
#define TV		0

#define	COL80		0x8
#define	COL40		0
#define NUMCOLS		7	/* This is the bit mask for bit/plane numbers */

#define BPS16		4
#define BPS8		3
#define BPS4		2
#define BPS2		1
#define BPS1		0






