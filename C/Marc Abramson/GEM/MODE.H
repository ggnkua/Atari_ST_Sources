/*
 * mode.h
 * ======================================================================
 * Falcon/030 setmode call and defines.
 * (C) Atari 1992
 *
 * legerement modifie par Marc Abramson pour etre conforme
 * et compatible avec les definitions du Pure C1.1
 */

	#define VSetscreen(a,b,c) (int)xbios(5,a,b,3,c)

	#define Vsetmode(a)  (int)xbios(88,a)
	#define mon_type() (int)xbios(89)
	#define VsetSync(a) (void)xbios(90,a)


	#define BPS16             4
	#define BPS8              3
	#define BPS4              2
	#define BPS2              1
	#define BPS1              0

	#define NUMCOLS           7
	#define VERTFLAG          0x0100
	#define STMODES           0x0080
	#define OVERSCAN          0x0040
	#define PAL               0x0020
	#define VGA_FALCON        0x0010
	#define TV                0x0000

	#define COL80       0x8
	#define COL40       0
	#define NUMCOLS     7   /* This is the bit mask for bit/plane numbers */






