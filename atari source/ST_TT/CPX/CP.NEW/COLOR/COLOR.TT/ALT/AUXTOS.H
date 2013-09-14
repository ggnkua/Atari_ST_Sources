/*
 * Auxtos.h - defines for new TOS calls
 */
 
#define	EsetShift(a)			(int)	xbios(80, a)
#define	EgetShift()				(int)	xbios(81)
#define	EsetBank(a)				(int)	xbios(82, a)
#define	EsetColor(a, b)			(int)	xbios(83, a, b)
#define	EsetPalette(a, b, c)	(void)	xbios(84, a, b, c)
#define	EgetPalette(a, b, c)	(void)	xbios(85, a, b, c)
#define	EsetGray(a)				(int)	xbios(86, a)
#define	EsetSmear(a)			(int)	xbios(87, a)
