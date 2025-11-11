/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly! Library ----------- (c) 1991-92 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

/*
   gcc adaptions by Markus M. Nick (Markus_Nick@mz.maus.de), 23.03.92
   - all adaptions are marked with '!gcc!'.
   - gcc users please use <aes.h>, <vdi.h> and <tos.h> 
     distributed with Ruby.
   - note that `do_key(short key, short kbshift)' requires shorts 
     (only important in 32 bit int mode when sizeof(short)!=sizeof(int))
*/

#ifndef __LTMFLIB__
#define __LTMFLIB__

#include <aes.h>

/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly! Structure -------------------------------------------- */
/* ------------------------------------------------------------------------- */

#if defined(__GNUC__) && !defined(__MSHORT__)	/* !gcc! */
#define unsigned	unsigned short
#define	int 		short
#endif

typedef struct
{
	unsigned /*int !gcc!*/ version;	/* BSD format		*/
	struct
	{
		unsigned light	: 1;	/* light version (read)	*/
		unsigned niceln	: 1;	/* niceline		*/
		unsigned jumpin	: 1;	/* jumpin' dials	*/
		unsigned flyswi	: 1;	/* conf. flymode switch	*/
		unsigned vscr	: 1;	/* virtual scr. support	*/
		unsigned center : 1;	/* center mode		*/
		unsigned keys	: 1;	/* key handling		*/
		unsigned edit	: 1;	/* extended editor	*/
		unsigned redraw	: 1;	/* send redraw message	*/
		unsigned flytyp	: 1;	/* solid/hollow fly	*/
		unsigned fly	: 1;	/* flying on/off	*/
		unsigned alert	: 1;	/* alerts/errors on/off	*/
		unsigned mouse	: 1;	/* use virtual memory	*/
		unsigned f_grow	: 1;	/* grow/shrink boxes	*/
		unsigned g_grow : 1;	/* dials to mouse	*/
		unsigned bypass : 1;	/* ON/OFF highest prio	*/
	} config;
	int	conf2;			/* reserved 		*/
	int	reserved;		/* reserved 		*/
	void	cdecl	(*di_fly)(OBJECT *tree);	/* fly routine		*/
	void	cdecl	(*obj_clsize)(OBJECT *tree, int obj, int *x, int *y, int *w, int *h);
	int	cdecl	(*do_key)(int key, int kshift);	/* User Keys	*/
	int	cdecl	(*init_keys)(OBJECT *tree);
	int	cdecl	(*lookup_key)(int key, int kshift);
	int	cdecl	(*di_moveto)(OBJECT *tree, int mx, int my);
	int	cdecl	(*di_center)(OBJECT *tree);
	int	ucol;	/* underscore color	*/
	int	aicol;	/* alert icon color	*/
	int	aframe;	/* alert frame size	*/
	int	ccol;	/* character color	*/
	int	flydelay;	/* delay before flying (form_do()-only)	*/
	int	cdecl	(*hist_insert)(char *string);
	char	cdecl	(*ins_spcchar)(void);
} LTMFLY;

#if defined(__GNUC__) && !defined(__MSHORT__)	/* !gcc! */
#undef unsigned
#undef int
#endif

/* ------------------------------------------------------------------------- */

extern	LTMFLY	*letemfly;

/* ------------------------------------------------------------------------- */
/* ----- Prototypes -------------------------------------------------------- */
/* ------------------------------------------------------------------------- */

long *get_cookie(long cookie);
int ltmf_check(unsigned int version);
int di_fly(OBJECT *tree);
int obj_clsize(OBJECT *tree, int obj, int *x, int *y, int *w, int *h);
int init_keys(OBJECT *tree);
int lookup_key(int key, int kbshift);
int set_do_key(int cdecl (*key_handler)());
int di_moveto(OBJECT *tree, int x, int y);
int di_center(OBJECT *tree);
int ins_spcchar(void);
int hist_insert(char *string);
int init_flyobj(OBJECT *tree);

#define	_get_cookie		get_cookie

/* some useful defines ... */

#define fly_check(tree)		di_moveto(tree, -1, 0)
#define redraw_check(tree)	di_moveto(tree, -2, 0)

#endif

/* ------------------------------------------------------------------------- */
