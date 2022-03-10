#include <aes.h>

#ifndef FLYDIAL
#define FLYDIAL

/* FLD structure - used internally by FLYDIAL */
/* Can be accessed externally by fld_getfld() */

typedef struct fly_dialog  {
	int 								windowhandle;
	short								fldhandle,
			 								type,
			 								focus,
			 								index;
	char 								*title;
	OBJECT							*form;
	int 								(*xredraw)(int, GRECT*);
	struct fly_dialog 	*next;
} FLD;


/* Function prototypes */

short	fld_open(OBJECT *form, short centred, char *title, short type);
void	fld_draw(short fldhandle, int startobj, int depth);
short	fld_key(short kc, short *type, short *fldhandle);
short	fld_mouse(short x, short y, short numclicks, short *type, short *fldhandle);
void	fld_mesag(short *msgbuf);
void	fld_exit(void);
void	fld_close(short fldhandle);
int		fld_getwin(short fldhandle);
FLD*	fld_getfld(short fldhandle);
OBJECT*fld_getform(short fldhandle);
short	fld_do(OBJECT *tree, char *title);
short	fld_domulti(short *type, short *fldhandle);


/* Form positions on opening */

#define FLDC_NONE		0		/* No centreing */
#define FLDC_SCREEN	1		/* Centre on screen */
#define FLDC_MOUSE	2		/* Centre on mouse pointer */


/* Variables */

extern OBJECT *fld_tempform;
extern int     fld_tempstart,
               fld_tempdepth;

#endif