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
	char								iconified;
	OBJECT							*form;
	int 								(*xredraw)(int, GRECT*);
	struct fly_dialog 	*next;
} FLD;


/* Function prototypes */

short	fld_open(OBJECT *form, short centred, char *title, short type);
void	fld_draw(short fldhandle, int startobj, int depth);
short	fld_key(short kc, short *type, short *fldhandle);
short	fld_mouse(short x, short y, short numclicks, short *type, short *fldhandle);
int		fld_mesag(short *msgbuf);
void	fld_exit(void);
void	fld_close(short fldhandle);
int		fld_getwin(short fldhandle);
FLD*	fld_getfld(short fldhandle);
OBJECT*fld_getform(short fldhandle);
FLD*	fld_findtype(short type);
FLD*	fld_findform(OBJECT *form);
short	fld_do(OBJECT *tree, char *title);
short	fld_domulti(short *type, short *fldhandle);
void	fld_ability(int bitmask);


/* Form positions on opening */

#define FLDC_NONE		0		/* No centreing */
#define FLDC_SCREEN	1		/* Centre on screen */
#define FLDC_MOUSE	2		/* Centre on mouse pointer */


/* Ability codes */

#define FLDA_NONE   0x0000   /* No special program abilities */
#define FLDA_CLOSE  0x0001   /* Close dialog handling */
#define FLDA_ICON   0x0002   /* Iconify handling */


/* fld_mouse/fld_key/fld_mesag return values */

#define FLDR_NONE   -1       /* No action required */



/* Variables */

extern OBJECT *fld_tempform;
extern int     fld_tempstart,
               fld_tempdepth;

#endif