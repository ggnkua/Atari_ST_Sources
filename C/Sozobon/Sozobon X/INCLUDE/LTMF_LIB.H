/* --------------------------------------------------------------------- */
/* ----- Let 'em Fly! Library ----------- (c) 1991-92 by Oliver Scheel - */
/* --------------------------------------------------------------------- */
	/* changed for __SOZOBONX__ 0x223  -jerry: 1994/12/01 	*/

#if (SOZOBON  && __SOZOBONX__ < 0x223)
#error "works only with hcc v2.00x23 :: bitfields"
#else
#define STDARGS
#define VOID		void

#endif

#ifndef __LTMFLIB__
#define __LTMFLIB__



/* --------------------------------------------------------------------- */
/* ----- Let 'em Fly! Structure ---------------------------------------- */
/* --------------------------------------------------------------------- */

typedef struct
{
	UWORD	version;	/* BCD format		*/
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
	WORD	conf2;			/* reserved 		*/
	WORD	reserved;		/* reserved 		*/
	VOID	STDARGS	(*di_fly)(OBJECT *tree);
	VOID	STDARGS	(*obj_clsize)(OBJECT *tree, WORD obj, WORD *x, WORD *y, WORD *w, WORD *h);
	WORD	STDARGS	(*do_key)(WORD key, WORD kshift);
	WORD	STDARGS	(*init_keys)(OBJECT *tree);
	WORD	STDARGS	(*lookup_key)(WORD key, WORD kshift);
	WORD	STDARGS	(*di_moveto)(OBJECT *tree, WORD mx, WORD my);
	WORD	STDARGS	(*di_center)(OBJECT *tree);
	WORD	ucol;	/* underscore color	*/
	WORD	aicol;	/* alert icon color	*/
	WORD	aframe;	/* alert frame size	*/
	WORD	flydelay;	/* delay before flying (form_do()-only)	*/
	WORD	STDARGS	(*hist_insert)(CHAR *string);
	CHAR	STDARGS	(*ins_spcchar)(VOID);
	VOID	STDARGS	(*init_niceline)(OBJECT *tree);
} LTMFLY;

/* --------------------------------------------------------------------- */

extern	LTMFLY	*letemfly;

/* --------------------------------------------------------------------- */
/* ----- Prototypes ---------------------------------------------------- */
/* --------------------------------------------------------------------- */

WORD ltmf_check(UWORD version);
WORD di_fly(OBJECT *tree);
WORD obj_clsize(OBJECT *tree, WORD obj, WORD *x, WORD *y, WORD *w, WORD *h);
WORD init_keys(OBJECT *tree);
WORD lookup_key(WORD key, WORD kbshift);
WORD set_do_key(WORD STDARGS (*key_handler)());
WORD di_moveto(OBJECT *tree, WORD x, WORD y);
WORD di_center(OBJECT *tree);
CHAR ins_spcchar(VOID);
WORD hist_insert(CHAR *string);
WORD init_niceline(OBJECT *tree);
WORD init_flyobj(OBJECT *tree);


/* some useful defines ... */

#define fly_check(tree)		di_moveto(tree, -1, 0)
#define redraw_check(tree)	di_moveto(tree, -2, 0)

#endif

/* ----------------------------------------------------------------------*/
