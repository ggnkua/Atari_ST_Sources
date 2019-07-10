/*
 *	t100.h - stuff for term emulator
 */


#ifndef lint
static char *rcsid_t100_h = "$Id: t100.h,v 1.0 1991/09/12 20:29:08 rosenkra Exp $";
#endif

/*
 * $Log: t100.h,v $
 * Revision 1.0  1991/09/12  20:29:08  rosenkra
 * Initial revision
 *
 */


/*
 *	devices we use
 */
#define AUX		1
#define CON		2

#define KEYMASK		(0x7FL)
#define ALTMASK		(0x80L)

/*
 *	functions
 */
long		getcookie (char *);
void		config (void);
void		long_break (void);
void		help (void);
void		handle_key (long);
void		blurb (void);
void		rs232init (void);
short		rs232cd (void);
void		dobreak (void);
void		bye (int);
#ifdef EMUL_VT100
void		vt100 (void);
void		vt100_reset (void);
# ifdef USE_FONTS
 int		load_msp_font (int, short *);
 void		fnt_roman (void);
 void		fnt_bold (void);
 void		fnt_uline (void);
 void		fnt_reverse (void);
 void		fnt_normal (void);
# endif /*USE_FONTS*/
#endif /*EMUL_VT100*/

