/*	MACHINE.H		09/29/84 - 10/09/84	Lee Lorenzen	
 *	for 68k			10/10/84 - 04/22/85	Lowell Webster	
 *	Update			05/07/85		Derek Mui	
 *	Add more define		07/12/85		Derek Mui	
 *	add MULRES		3/25/86			Derek Mui
 *	add SWISSGER & SWISSFRA defines 8/3/87		Slavik Lozben
 *	add MEXICO defines      9/28/87 		Slavik Lozben
 *	Clean up		11/23/87		Derek Mui
 * 	Added 132 column switch	12/18/87		D.Mui		
 *	add FINLAND		1/8/88			D.Mui	
 */

#ifndef _MACHINE_H_
#define _MACHINE_H_

/*#define DEBUGMSGS	/* define this for debugging */

#ifdef DEBUGMSGS
#define	Debug0(a)	Debug(0,a)
#define Ndebug0(a)	Ndebug(0,a)
#define	Debug1(a)	Debug(1,a)
#define Ndebug1(a)	Ndebug(1,a)
#define	Debug2(a)	Debug(2,a)
#define Ndebug2(a)	Ndebug(2,a)
#define	Debug3(a)	Debug(3,a)
#define Ndebug3(a)	Ndebug(3,a)
#define	Debug4(a)	Debug(4,a)
#define Ndebug4(a)	Ndebug(4,a)
#define	Debug5(a)	Debug(5,a)
#define Ndebug5(a)	Ndebug(5,a)
#define	Debug6(a)	Debug(6,a)
#define Ndebug6(a)	Ndebug(6,a)
#define	Debug7(a)	Debug(7,a)
#define Ndebug7(a)	Ndebug(7,a)
#else
#define	Debug0(a)
#define Ndebug0(a)
#define	Debug1(a)
#define Ndebug1(a)
#define	Debug2(a)
#define Ndebug2(a)
#define	Debug3(a)
#define Ndebug3(a)
#define	Debug4(a)
#define Ndebug4(a)
#define	Debug5(a)
#define Ndebug5(a)
#define	Debug6(a)
#define Ndebug6(a)
#define	Debug7(a)
#define Ndebug7(a)
#endif

#define HIGHWORD	0xFFFF0000L
#define LOWWORD		0x0000FFFFL		
#define ST		0x00000L	/* ST Machine		*/
#define	STE		0x10000L	/* STE			*/
#define	TT		0x20000L	/* TT 			*/
#define FALCON		0x30000L	/* FALCON video mode	*/
#define BELL 		0x07		/* bell			*/
#define ATARI		1		/* for ATARI ST series	*/
#define CARTRIDGE	1		/* if rom cartridge exists */
#define	GEMDOS		1		/* GEM DOS 		*/
#define	MC68K		1		/* Motorola 68000	*/
#define HILO		1		/* how bytes are stored,*/
					/* 0 for i8086, 1 for 68k */


					/* coerce short ptr to	*/
					/*   low word  of long	*/
#define LW(x) ( (LONG)((UWORD)(x)) )

					/* coerce short ptr to	*/
					/*   high word  of long	*/
#define HW(x) ((LONG)((UWORD)(x)) << 16)

					/* in OPTIMIZE.C	*/
EXTERN BYTE	*strcpy();
EXTERN BYTE	*strcat();
EXTERN BYTE	*strscn();

#define LLOWD(x) ((UWORD)(x))
						/* return high word of	*/
						/*   a long value	*/
#define LHIWD(x) ((UWORD)(x >> 16))
						/* return high byte of	*/
						/* a word value		*/
						/* added 12/03/84	*/
#define LLOBT(x) ((BYTE)(x))
						/* return 0th byte of   */
						/* a long value given	*/
						/* a short pointer to	*/
						/* the long value 	*/
						/* added 12/03/84	*/
#define LHIBT(x) ((BYTE)(x >> 8))


						/* return a long address*/
						/*   of a short pointer */
#define ADDR /**/
						/* return long address	*/
						/*   of the data seg	*/
#define LLDS() (LONG)0

						/* return long address	*/
						/*   of the code seg	*/
#define LLCS() (LONG)0

						/* return a single byte	*/
						/*   pointed at by long	*/
						/*   ptr		*/
#define LBGET(x) ( (UBYTE) *((BYTE * )(x)) )
						/* set a single byte	*/
						/*   pointed at by long	*/
						/*   ptr, LBSET(lp, bt)	*/
#define LBSET(x, y)  ( *((BYTE *)(x)) = y)
						/* return a single word	*/
						/*   pointed at by long	*/
						/*   ptr		*/
#define LWGET(x) ( (WORD) *((WORD *)(x)) )
						/* set a single word	*/
						/*   pointed at by long	*/
						/*   ptr, LWSET(lp, bt)	*/
#define LWSET(x, y)  ( *((WORD *)(x)) = y)

						/* return a single long	*/
						/*   pointed at by long	*/
						/*   ptr		*/
#define LLGET(x) ( *((LONG *)(x)))
						/* set a single long	*/
						/*   pointed at by long	*/
						/*   ptr, LLSET(lp, bt)	*/
#define LLSET(x, y) ( *((LONG *)(x)) = y)

						/* return 0th byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE0(x) ( *((x)+3) )
						/* return 1st byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE1(x) ( *((x)+2) )
						/* return 2nd byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE2(x) ( *((x)+1) )
						/* return 3rd byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE3(x) (*(x))

#endif

