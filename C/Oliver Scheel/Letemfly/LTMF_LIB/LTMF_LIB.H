/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly! Library -------------- (c) 1991 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

#ifndef __LTMFLIB__
#define __LTMFLIB__

#include <aes.h>

/* ------------------------------------------------------------------------- */
/* ----- Let 'em Fly! Structure -------------------------------------------- */
/* ------------------------------------------------------------------------- */

typedef struct
{
	unsigned int	version;
	struct
	{
		unsigned light	: 1;	/* light version (read)	*/
		unsigned	: 2;	/* reserved		*/
		unsigned flyswi	: 1;	/* conf. flymode switch	*/
		unsigned vscr	: 1;	/* virtual scr. support	*/
		unsigned center : 1;	/* center mode		*/
		unsigned keys	: 1;	/* key handling		*/
		unsigned edit	: 1;	/* extended editor	*/
		unsigned redraw	: 1;	/* send redraw message	*/
		unsigned flytyp	: 1;	/* solid/hollow fly	*/
		unsigned fly	: 1;	/* flying on/off	*/
		unsigned alert	: 1;	/* Alerts/Errors on/off	*/
		unsigned v_mem	: 1;	/* use virtual memory	*/
		unsigned f_grow	: 1;	/* grow/shrink boxes	*/
		unsigned g_grow : 1;
		unsigned bypass : 1;	/* ON/OFF highest prio	*/
	} config;
	char	*vpath;			/* path for v-mem	*/
	void	cdecl	(*di_fly)(OBJECT *tree);	/* fly routine		*/
	void	cdecl	(*obj_clsize)(OBJECT *tree, int obj, int *x, int *y, int *w, int *h);
	int	cdecl	(*do_key)(int key, int kshift);	/* User Keys	*/
	int	cdecl	(*init_keys)(OBJECT *tree);
	int	cdecl	(*lookup_key)(int key, int kshift);
	long	res1;	/* reserved		*/
	long	res2;	/* reserved		*/
	int	ucol;	/* underscore color	*/
	int	aicol;	/* alert icon color	*/
	int	aframe;	/* alert frame size	*/
} LTMFLY;

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

#define	_get_cookie	get_cookie

#endif

/* ------------------------------------------------------------------------- */
