/*
* VIDBIND.H	Low level Falcon video function bindings.
*
*		R.J. Ridder			7/ 4/93
*
*/

#define	VERTFLAG	0x100
#define	STMODES		0x80
#define OVERSCAN	0x40
#define PAL			0x20
#define VGA			0x10
#define TV			0x0

#define	COL80		0x08
#define	COL40		0x0
#define	NUMCOLS		7

#define	BPS16		4
#define	BPS8		3
#define BPS4		2
#define BPS2		1
#define BPS1		0

extern	long	xbios();

#define Setscreen(a,b,c,d)	(int) xbios( 5,(long)(a),(long)(b),\
										   (int)(c),(int)(d))
#define Vsetmode(m)			(int) xbios(88,(int)(m))
#define mon_type()			(int) xbios(89)
#define VgetSize(m)			(long)xbios(91,(int)(m))
#define VsetSync(a)			(void)xbios(90,(int)(a))
#define VsetRGB(a,b,c)		(void)xbios(93,(int)(a),(int)(b),(long*)(c))
#define VgetRGB(a,b,c)		(void)xbios(94,(int)(a),(int)(b),(long*)(c))
#define VsetMask(a,b)		(void)xbios(150,(long)(a),(long)(b),(int)(c))

/* EOF */