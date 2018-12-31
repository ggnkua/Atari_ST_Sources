/***************************************************************************
 * This program is Copyright (C) 1991-1996 by C.H.Lindsey, University of   *
 * Manchester.  (X)JOVETOOL is provided to you without charge, and with no *
 * warranty.  You may give away copies of (X)JOVETOOL, including sources,  *
 * provided that this notice is included in all the files, except insofar  *
 * as a more specific copyright notices attaches to the file (x)jovetool.c *
 ***************************************************************************/

/* proto: macro to allow us to prototype any function declaration
 * without upsetting old compilers.
 */

#ifdef	__STDC__
# define	REALSTDC	1
#else
#define	const	/*const*/
#endif

#ifdef	REALSTDC
# define    USE_PROTOTYPES  1
#endif

#ifdef	USE_PROTOTYPES
# define proto(x)        x
# ifdef	NO_PTRPROTO
   /* on these systems, a prototype cannot be used for a pointer to function */
#  define ptrproto(x)		()
# else
#  define ptrproto(x)		x
# endif
#else
# define proto(x)		()
# define ptrproto(x)		()
#endif

#define private static

extern	Tty	ttysw;

extern	Menu	main_menu;

#ifndef	SUNVIEW
extern	Xv_Font font;	/* ??? not in sunview */
#endif

extern void	menu_init proto((void));
