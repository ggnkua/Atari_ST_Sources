/**********************************
 *                                *
 *    FLDLIB v0.93 SOURCE CODE    *
 *     (C) M. J. Maisey 1994      *
 *  View with a tab setting of 2  *
 *                                *
 **********************************/


#include <aes.h>
#include <stdlib.h>
#include <string.h>
#include "icon.c"


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


/* Global variables - internally used */

FLD*		fld_first = NULL;
OBJECT*	fld_tempform;
int			fld_tempstart,
				fld_tempdepth;
int			fld_progability;
char		fld_iconinitialised = 0;


/* Function prototypes - externally available functions */

short	fld_open(OBJECT *form, short centred, char *title, short type);
void	fld_draw(short fldhandle, int startobj, int depth);
short fld_key(short kc, short *type, short *fldhandle);
short	fld_mouse(short x, short y, short numclicks, short *type, short *fldhandle);
int		fld_mesag(short *msgbuf);
void	fld_exit(void);
void	fld_close(short fldhandle);
int		fld_getwin(short fldhandle);
FLD*	fld_getfld(short fldhandle);
OBJECT*fld_getform(short fldhandle);
FLD*	fld_findtype(short type);
FLD*	fld_findform(OBJECT *form);
short fld_do(OBJECT *tree, char *title);
short fld_domulti(short *type, short *fldhandle);
void	fld_ability(int bitmask);


/* Function prototypes - internal use */

FLD*	fld_add(short *fldhandle);
void	fld_remove(short fldhandle);
FLD*	fld_findwin(int windowhandle);
int		fld_drawform(int handle, GRECT *area);
int		fld_drawicon(int handle, GRECT *area);


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


/* fld_add(): Add new fly_dialog to list              */
/*            Returns: pointer to new fly_dialog      */
/*            New handle -> fldhandle                 */
/*                      INTERNAL                      */

FLD *fld_add(short *fldhandle)  {
	FLD *temp = fld_first;

	if (fld_first == NULL)  {
		temp = fld_first = (FLD *) malloc(sizeof(FLD));
		*fldhandle = 1;
	} else {
		for (;temp->next != NULL; temp = temp->next);
		*fldhandle = temp->fldhandle + 1;
		temp->next = (FLD *) malloc(sizeof(FLD));
		temp = temp->next;
	}

	temp->windowhandle = 0;
	temp->fldhandle = *fldhandle;
	temp->type = 0;
	temp->title = NULL;
	temp->iconified = 0;
	temp->form = NULL;
	temp->xredraw = NULL;
	temp->next = NULL;

	return temp;
}


/* fld_remove(): Remove fly_dialog from list          */
/*               fldhandle -> handle to be removed    */
/*                      INTERNAL                      */

void fld_remove(short fldhandle)  {
	FLD *old = NULL, *temp = fld_first;

	for (; temp != NULL;)  {
		if (temp->fldhandle == fldhandle) break;
		old = temp;
		temp = temp->next;
	}

	if (temp != NULL)  {
		if (old == NULL)  {
			fld_first = temp->next;
			free((void *) temp->title);
			free((void *) temp);
		} else {
			old->next = temp->next;
			free((void *) temp->title);
			free((void *) temp);
		}
	}
}


/* fld_findwin(): Find fly_dialog for window          */
/*            Returns: pointer to fly_dialog if found */
/*                     NULL if not found              */
/*            windowhandle -> handle of window(!)     */
/*                      INTERNAL                      */

FLD *fld_findwin(int windowhandle)  {
	FLD *temp = fld_first;

	for (; temp != NULL; temp = temp->next)
		if (temp->windowhandle == windowhandle) break;

	return temp;
}


/* fld_open(): Open new flying dialog                 */
/*            Returns: handle of new fly_dialog       */
/*                     -1 if problem                  */
/*            form -> pointer to object tree          */
/*            centred -> centreing of pointer         */
/*            title -> window title                   */
/*            type -> type of fly_dialog              */
/*                      EXTERNAL                      */

short	fld_open(OBJECT *form, short centred, char *title, short type)  {
	short fldhandle, x, y, w, h, dummy, wx, wy, ww, wh, max, tempobj, dy, parts;
	FLD *temp = fld_first;

	for (; temp != NULL; temp = temp->next)  {
		if (temp->form == form)  {
			wind_set(temp->windowhandle, WF_TOP);
			return temp->fldhandle;
		}
	}

	switch (centred)  {
	case FLDC_NONE:
		objc_offset(form, 0, &x, &y);
		w = form->ob_width;
		h = form->ob_height;
		break;
	case FLDC_SCREEN:
		form_center(form, &x, &y, &w, &h);
		break;
	case FLDC_MOUSE:
		w = form->ob_width;
		h = form->ob_height;
		graf_mkstate(&x, &y, &dummy, &dummy);
		x -= w / 2;
		y -= h / 2;
		form->ob_x = x;
		form->ob_y = y;
		if (x < 0) x = 0;
		if (y < 0) y = 0;
		break;
	}
	
	if (fld_progability & FLDA_CLOSE)
		parts = NAME|MOVE|CLOSE;
	else
		parts = NAME|MOVE;
	
	if (fld_progability & FLDA_ICON)
		parts |= SMALLER;

	temp = fld_add(&fldhandle);
	temp->form = form;
	wind_calc(WC_BORDER, parts, x, y, w, h, &wx, &wy, &ww, &wh);
	wx++;wy++;ww-=2;wh-=2;
	
	wind_get(DESK, WF_PREVXYWH, &dummy, &dy, &dummy, &dummy);
	if (wy < dy)  {
		temp->form->ob_y = dy + y - wy;
		wy = dy;
	}
	
	temp->windowhandle = wind_create(parts, wx, wy, ww, wh);
	temp->title = (char *) malloc(strlen(title)+2);
	temp->type = type;
	strcpy(temp->title, title);
	wind_title(temp->windowhandle, temp->title);
	wind_open(temp->windowhandle, wx, wy, ww, wh);

	/* Initialise edit */
	max = temp->form->ob_tail;
	for (tempobj = 0; tempobj <= max; tempobj++)
		if (temp->form[tempobj].ob_flags & EDITABLE)  break;

	if (tempobj <= max)  {				/* Check editable object found */
		temp->focus = tempobj;
		objc_edit(temp->form, temp->focus, 0, &temp->index, ED_INIT);
	} else
		temp->focus = -1;

	return fldhandle;
}


/* fld_getfld(): Find fly_dialog given a handle       */
/*            Returns: pointer to fly_dialog if found */
/*                     NULL if not found              */
/*                      EXTERNAL                      */

FLD *fld_getfld(short fldhandle)  {
	FLD *temp = fld_first;

	for (; temp != NULL; temp = temp->next)
		if (temp->fldhandle == fldhandle) break;

	if (temp != NULL)
		return temp;

	return NULL;
}


/* fld_drawform: called only via wind_redraw()        */
/*                      INTERNAL                      */

int fld_drawform(int handle, GRECT *area)  {
	objc_draw(fld_tempform, fld_tempstart, fld_tempdepth, area->g_x, area->g_y, area->g_w, area->g_h);

	return 1;
}


/* fld_drawicon: called only via wind_redraw()        */
/*                      INTERNAL                      */

int fld_drawicon(int handle, GRECT *area)  {
	short x, y, w, h;
	
	wind_get(handle, WF_WORKXYWH, &x, &y, &w, &h);
	FLD_ICONFORM->ob_x = x;
	FLD_ICONFORM->ob_y = y;
	FLD_ICONFORM->ob_width = w;
	FLD_ICONFORM->ob_height = h;
	
	FLD_ICONFORM[1].ob_x = w / 2 - FLD_ICONFORM[1].ob_width / 2;
	FLD_ICONFORM[1].ob_y = h / 2 - FLD_ICONFORM[1].ob_height / 2;
	
	objc_draw(FLD_ICONFORM, 0, 7, area->g_x, area->g_y, area->g_w, area->g_h);

	return 1;
}


/* fld_draw(): Find fly_dialog given a handle         */
/*             fldhandle -> fly_dialog handle         */
/*             startobj -> start object for draw      */
/*             depth -> maximum depth to draw to      */
/*                      EXTERNAL                      */

void fld_draw(short fldhandle, int startobj, int depth)  {
	FLD *temp;
	GRECT rect;

	temp = fld_getfld(fldhandle);
	if (temp == NULL) return;

	fld_tempform = temp->form;
	fld_tempstart = startobj;
	fld_tempdepth = depth;

	wind_get(DESK, WF_PREVXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	if (temp->focus != -1) objc_edit(temp->form, temp->focus, 0, &temp->index, ED_END);
	wind_redraw(temp->windowhandle, &rect, fld_drawform);
	if (temp->xredraw != NULL)
		wind_redraw(temp->windowhandle, &rect, temp->xredraw);
	if (temp->focus != -1) objc_edit(temp->form, temp->focus, 0, &temp->index, ED_INIT);
}


/* fld_key(): Deal with keypress                      */
/*   Returns: -1 (FLDR_NONE) if no object selected    */
/*            OR selected object                      */
/*            kc -> keypress from evnt_multi()        */
/*            relevent fly_dialog type -> type        */
/*            relevent fly_dialog handle -> fldhandle */
/*                      EXTERNAL                      */

short fld_key(short kc, short *type, short *fldhandle)  {
	FLD *temp;
	short windowhandle, nextob;

	wind_get(0, WF_TOP, &windowhandle, NULL, NULL, NULL);
	temp = fld_findwin(windowhandle);
	if (temp == NULL) return FLDR_NONE;

	*fldhandle = temp->fldhandle;
	*type = temp->type;


	if (temp->iconified == 0)  {
			/* Process kc for special chars */
		if (form_keybd(temp->form, temp->focus, 0, kc, &nextob, &kc) == 0)
				/* Return default object if <return> pressed */
			return nextob;

			/* Process valid keypress */
		if (kc)  {
			objc_edit(temp->form, temp->focus, kc, &temp->index, ED_CHAR);
		}

			/* Check for new focus object */
		if ((nextob != 0) && (nextob != temp->focus) && (temp->focus != -1))  {
			objc_edit(temp->form, temp->focus, 0, &temp->index, ED_END);
			temp->focus = nextob;
			objc_edit(temp->form, temp->focus, 0, &temp->index, ED_INIT);
		}
	}

	return FLDR_NONE;
}


/* fld_mouse(): Deal with mouse click                   */
/*     Returns: -1 (FLDR_NONE) if no object selected    */
/*              OR selected object                      */
/*              x,y -> mouse pos. from evnt_multi()     */
/*              numclicks -> number of clicks from      */
/*                           evnt_multi                 */
/*              relevent fly_dialog type -> type        */
/*              relevent fly_dialog handle -> fldhandle */
/*                      EXTERNAL                        */

short fld_mouse(short x, short y, short numclicks, short *type, short *fldhandle)  {
	FLD *temp;
	int obj;
	short windowhandle, nextob;

	wind_get(0, WF_TOP, &windowhandle, NULL, NULL, NULL);
	temp = fld_findwin(windowhandle);
	if (temp == NULL) return FLDR_NONE;

	*fldhandle = temp->fldhandle;
	*type = temp->type;

	if (temp->iconified == 0)  {
		if ( (obj = objc_find(temp->form, 0, 7, x, y)) == -1)
			return FLDR_NONE;

		if (form_button(temp->form, obj, numclicks, &nextob) == 0)
			return obj;

			/* Check for new focus object */
		if ((nextob != 0) && (nextob != temp->focus) && (temp->focus != -1))  {
			objc_edit(temp->form, temp->focus, 0, &temp->index, ED_END);
			temp->focus = nextob;
			objc_edit(temp->form, temp->focus, 0, &temp->index, ED_INIT);
		}
	}

	return FLDR_NONE;
}


/* fld_event(): Handle GEM event                         */
/*     Returns: -1 (FLDR_NONE) if dialogs still open     */
/*           OR fldhandle of closed dialog               */
/*              msgbuf -> message buffer from evnt_multi */
/*                        EXTERNAL                       */

int fld_mesag(short *msgbuf)  {
	FLD *temp;
	short x, y, w, h;

	if (fld_first == NULL) return FLDR_NONE;

	switch (msgbuf[0])  {
	case WM_REDRAW:
		if ( (temp = fld_findwin(msgbuf[3])) == NULL)  return FLDR_NONE;
		if (temp->iconified)
			wind_redraw(temp->windowhandle, (GRECT *) (msgbuf + 4), fld_drawicon);
		else  {
			fld_tempform = temp->form;
			fld_tempstart = 0;
			fld_tempdepth = 7;
			if (temp->focus != -1)  objc_edit(temp->form, temp->focus, 0, &temp->index, ED_END);
				wind_redraw(temp->windowhandle, (GRECT *) (msgbuf + 4), fld_drawform);
			if (temp->xredraw != NULL)
				wind_redraw(temp->windowhandle, (GRECT *) (msgbuf + 4), temp->xredraw);
			if (temp->focus != -1)  objc_edit(temp->form, temp->focus, 0, &temp->index, ED_INIT);
		}
		break;
	case WM_MOVED:
		if ( (temp = fld_findwin(msgbuf[3])) == NULL)  return FLDR_NONE;
		if (temp->iconified == 0)
			if (temp->focus != -1)  objc_edit(temp->form, temp->focus, 0, &temp->index, ED_END);
		wind_get(temp->windowhandle, WF_CURRXYWH, &x, &y, &w, &h);
		wind_set(temp->windowhandle, WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
		if (temp->iconified == 0)  {
			temp->form->ob_x += msgbuf[4] - x;
			temp->form->ob_y += msgbuf[5] - y;
			if (temp->focus != -1)  objc_edit(temp->form, temp->focus, 0, &temp->index, ED_INIT);
		}
		break;
	case WM_TOPPED:
		if ( (temp = fld_findwin(msgbuf[3])) == NULL)  return FLDR_NONE;
		wind_set(temp->windowhandle, WF_TOP);
		break;
	case WM_CLOSED:
		if ( (temp = fld_findwin(msgbuf[3])) == NULL)  return FLDR_NONE;
		return temp->fldhandle;
		break;
	case WM_ICONIFY:
		if ( (temp = fld_findwin(msgbuf[3])) == NULL)  return FLDR_NONE;
		wind_set(temp->windowhandle, WF_ICONIFY, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
		temp->iconified = 1;
		if (fld_iconinitialised == 0)  {
			fld_iconinitialised = 1;
			rsrc_init();
		}
		break;
	case WM_UNICONIFY:
		if ( (temp = fld_findwin(msgbuf[3])) == NULL)  return FLDR_NONE;
		wind_set(temp->windowhandle, WF_UNICONIFY, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
		temp->iconified = 0;
		break;
	}
	
	return FLDR_NONE;
}


/* fld_exit(): Clean up on program exit                  */
/*                        EXTERNAL                       */

void fld_exit(void)  {
	while (fld_first != NULL)  {
		wind_close(fld_first->windowhandle);
		wind_delete(fld_first->windowhandle);
		fld_remove(fld_first->fldhandle);
	}
}


/* fld_close(): Close fly_dialog                         */
/*              fldhandle -> fly_dialog handle           */
/*                        EXTERNAL                       */

void fld_close(short fldhandle)  {
	FLD *temp;

	if ( (temp = fld_getfld(fldhandle)) == NULL)
		return;

	wind_close(temp->windowhandle);
	wind_delete(temp->windowhandle);
	fld_remove(fldhandle);
}


/* fld_getwin(): Get windowhandle for given fldhandle    */
/*      Returns: -1 if fly_dialog not found              */
/*               OR window handle                        */
/*               fldhandle -> fly_dialog handle          */
/*                        EXTERNAL                       */

int fld_getwin(short fldhandle)  {
	FLD *temp;

	if ( (temp = fld_getfld(fldhandle)) == NULL)
		return -1;

	return temp->windowhandle;
}


/* fld_getform(): Get object tree for given fldhandle    */
/*       Returns: NULL if fly_dialog not found           */
/*                OR pointer to tree                     */
/*                fldhandle -> fly_dialog handle         */
/*                        EXTERNAL                       */

OBJECT *fld_getform(short fldhandle)  {
	FLD *temp;

	if ( (temp = fld_getfld(fldhandle)) == NULL)
		return NULL;

	return temp->form;
}


/* fld_findtype(): Get fly_dialog for given type         */
/*        Returns: NULL if type not found                */
/*                 OR pointer to fly_dialog              */
/*                 type -> fly_dialog type               */
/*                        EXTERNAL                       */


FLD *fld_findtype(short type)  {
	FLD *temp = fld_first;

	for (; temp != NULL; temp = temp->next)
		if (temp->type == type) break;

	return temp;
}


/* fld_findform(): Get fly_dialog for given form         */
/*        Returns: NULL if form not found                */
/*                 OR pointer to fly_dialog              */
/*                 form -> address of object tree        */
/*                        EXTERNAL                       */


FLD *fld_findform(OBJECT *form)  {
	FLD *temp = fld_first;

	for (; temp != NULL; temp = temp->next)
		if (temp->form == form) break;

	return temp;
}


/* fld_ability(): Set ability of program to handle new   */
/*                FLDLIB features                        */
/*                bitmask -> bitmask of features handled */
/*                       EXTERNAL                        */

void fld_ability(int bitmask)  {
	fld_progability = bitmask;
}


/* fld_do(): Manage single flying dialog                 */
/*  Returns: index of object clicked on                  */
/*           -1 if there are already flying dialogs open */
/*           -1 (FLDR_NONE) if the dialog is closed      */
/*              without an object being clicked          */
/*              (when fld_ability(FLDA_CLOSE); called)   */
/*           tree -> object tree to manage               */
/*           title -> title of window                    */
/*                        EXTERNAL                       */

short fld_do(OBJECT *tree, char *title)  {
	short msgbuf[8], mx, my, mb, mk, kc, numclicks, evnts, ret, fldhandle, type;

	if (fld_first != NULL) return -1;

	fld_open(tree, FLDC_SCREEN, title, 0);

	while (1)  {
		evnts = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,  /* Flags + clicks */
		                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  /* Rects to watch (none) */
		                   msgbuf, 0, 0, &mx, &my, &mb, &mk, /* Msg buffer + mouse click */
		                   &kc, &numclicks);

		if (evnts & MU_KEYBD)
			if ((ret = fld_key(kc, &type, &fldhandle)) != FLDR_NONE)  {
				fld_close(fldhandle);
				return ret;
			}
		if (evnts & MU_BUTTON)
			if ((ret = fld_mouse(mx, my, numclicks, &type, &fldhandle)) != FLDR_NONE)  {
				fld_close(fldhandle);
				return ret;
			}
		if (evnts & MU_MESAG)
			if ((ret = fld_mesag(msgbuf)) != FLDR_NONE)  {
				fld_close(ret);
				return FLDR_NONE;
			}
	}

	return 0;
}


/* fld_domulti(): Manage multiple flying dialogs                */
/*       Returns: index of object clicked on                    */
/*             OR the negative fldhandle of a closed dialog     */
/*                type of fly_dialog with selected obj -> type  */
/*                fly_dialog handle -> fldhandle                */
/*                             EXTERNAL                         */

short fld_domulti(short *type, short *fldhandle)  {
	short msgbuf[8], mx, my, mb, mk, kc, numclicks, evnts, ret;

	while (1)  {
		evnts = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,  /* Flags + clicks */
		                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  /* Rects to watch (none) */
		                   msgbuf, 0, 0, &mx, &my, &mb, &mk, /* Msg buffer + mouse click */
		                   &kc, &numclicks);

		if (evnts & MU_KEYBD)
			if ((ret = fld_key(kc, type, fldhandle)) != FLDR_NONE)  {
				return ret;
			}
		if (evnts & MU_BUTTON)
			if ((ret = fld_mouse(mx, my, numclicks, type, fldhandle)) != FLDR_NONE)  {
				return ret;
			}
		if (evnts & MU_MESAG)
			if ((ret = fld_mesag(msgbuf)) != FLDR_NONE)  {
				return -ret;
			}
	}

	return 0;
}