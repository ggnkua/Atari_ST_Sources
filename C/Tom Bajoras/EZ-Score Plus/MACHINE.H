/************************************************************************/
/*	MACHINE.H Compatibility file for 8086 to 68000 porting.		*/
/*		Copyright 1985 Atari Corp.				*/
/*									*/
/*	WARNING: This file is not supported!				*/
/*		 We reccomend that you use a native 68000 enviroment.	*/
/************************************************************************/

#define	PCDOS	0	/* IBM PC DOS 		*/
#define	CPM	1	/* CP/M version 2.2	*/
#define	DRDOS	0	/* GEM DOS 		*/

#define HILO 1		/* how bytes are stored, 0 for i8086, 1 for 68k */

#define I8086	0	/* Intel 8086/8088	*/
#define	MC68K	1	/* Motorola 68000	*/

#define ALCYON	1	/* Alcyon C Compiler	*/

#define LINKED	1	/* if desktop linked with gem	*/

#define UNLINKED	0	/* if desktop not linked with gem	*/
#define CARTRIDGE	1	/* if rom cartridge exists		*/


#define ATARI	1		/* for ATARI ST series			*/

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
						/* in LARGE.A86		*/
						/* return length of 	*/
						/*   string pointed at	*/
						/*   by long pointer	*/
EXTERN WORD	LSTRLEN();


						/* copy n words from	*/
						/*   src long ptr to	*/
						/*   dst long ptr i.e.,	*/
						/*   LWCOPY(dlp, slp, n)*/
EXTERN WORD	LWCOPY();
						/* copy n words from	*/
						/*   src long ptr to	*/
						/*   dst long ptr i.e.,	*/
						/*   LBCOPY(dlp, slp, n)*/
EXTERN BYTE	LBCOPY();

EXTERN WORD	LBWMOV();

EXTERN WORD	LSTCPY();

						/* return low word of	*/
						/*   a long value	*/
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


/************************************************************************/

#if I8086


						/* return long address	*/
						/*   of short ptr	*/
EXTERN LONG	ADDR();

						/* return long address	*/
						/*   of the data seg	*/
EXTERN LONG	LLDS();

						/* return long address	*/
						/*   of the code seg	*/
EXTERN LONG	LLCS();
						/* return a single byte	*/
						/*   pointed at by long	*/
						/*   ptr		*/
EXTERN BYTE	LBGET();
						/* set a single byte	*/
						/*   pointed at by long	*/
						/*   ptr, LBSET(lp, bt)	*/
EXTERN BYTE	LBSET();
						/* return a single word	*/
						/*   pointed at by long	*/
						/*   ptr		*/
EXTERN WORD	LWGET();
						/* set a single word	*/
						/*   pointed at by long	*/
						/*   ptr, LWSET(lp, bt)	*/
EXTERN WORD	LWSET();
						/* return a single long	*/
						/*   pointed at by long	*/
						/*   ptr		*/
EXTERN LONG	LLGET();
						/* set a single long	*/
						/*   pointed at by long	*/
						/*   ptr, LLSET(lp, bt)	*/
EXTERN LONG	LLSET();
						/* return 0th byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE0(x) (*x)
						/* return 1st byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE1(x) (*(x+1))
						/* return 2nd byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE2(x) (*(x+2))
						/* return 3rd byte of	*/
						/*   a long value given	*/
						/*   a short pointer to	*/
						/*   the long value	*/
#define LBYTE3(x) (*(x+3))

#endif


/************************************************************************/

#if MC68K

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

