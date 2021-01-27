/********************************************************************
 * All smaller form function extensions                             *
 ********************************************************************/

#include <stdio.h>
#include "gemf.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

void frm_desktop(long options, OBJECT *ptree)
{
	OBJECT  *pobj2;
	int fill;
	int color;
	long ob_spec;

	wind_update(BEG_UPDATE);
	if ((options & FRM_DTREMOVE) || ptree == NULL)
		wind_set(0, WF_NEWDESK, NULL, 0, 0);
	else if (options & FRM_CENTER)
	{
		rc_copy(&gl_rwdesk, &ptree->ob_x); /* copy desk xywh to tree	*/
		if (!(ptree->ob_flags & LASTOB))   /* if there's another object */
		{
			pobj2 = ptree + 1;				/* center it on the screen   */
			pobj2->ob_x = (ptree->ob_width  - pobj2->ob_width)  / 2;
			pobj2->ob_y = (ptree->ob_height - pobj2->ob_height) / 2;
		}
	}
	apl_vshared();								/* fill in gl_vwout[]  */
	if (gl_vwout[13] == 2)						/* monochrome monitor? */
	{
		ob_spec= ptree->ob_spec.index;			/* if so, and the	  */
		fill  = (ob_spec & 0x00000070L) >> 4;	/* desktop is a solid  */
		color = (ob_spec & 0x0000000FL);		/* color, change it to */

		if (fill == 7 && color > 0)				/* halftone gray.	  */
			ptree->ob_spec.index = (ob_spec & 0xFFFFFF00L) | 0x00000041L;
	}
	wind_set(0, WF_NEWDESK, ptree, 0, 0);

	wind_update(END_UPDATE);
	frmx_dial(FMD_FINISH, NULL, &gl_rwdesk);	/* paint the new desktop */
}

/**************************************************************************
 * FRMVFMT.C - Allocate a 2k buffer, format text into it with vsprintf().
 *************************************************************************/

static char errmsg[] = "\n"
                       "<Internal error: Can't get buffer to format message>"
                       "\n"
                       ;

static char nullmsg[] = "\n"
                        "<Internal error: NULL format pointer>\n"
                        "\n"
                        ;

void _FrmVFree(char *buffer)
{
	if (buffer != NULL && buffer != errmsg && buffer != nullmsg)
		apl_free(buffer);
}

char *_FrmVFormat(char *fmt, va_list args, int *plen)
{
    char *buffer;
    int len;

    if (NULL == fmt)
    {
        buffer = nullmsg;
        len    = -1;
    }
    else if (NULL == (buffer = apl_malloc(2048L)))
    {
        buffer = errmsg;
        len    = -1;
    }
    else
        len = vsprintf(buffer, fmt, args);

    if (plen != NULL)
        *plen = len;

    return buffer;
}

/**************************************************************************
 * FRMVPRTF.C - frm_vprintf() function.
 *************************************************************************/

char *_Frmaddmsg = NULL; 	/* hook for frm_error() to add a message */

int frm_vprintf(long options, char *buttons, char *fmt, va_list args)
{
	int 	status;
	int 	position;
	char	*msgbuf;

	msgbuf = _FrmVFormat(fmt, args, &position);

	if (_Frmaddmsg != NULL && position != -1)
	{
		strcpy(&msgbuf[position], _Frmaddmsg);
		_Frmaddmsg = NULL;
	}

	status = frm_nldialog(options, buttons, msgbuf);

	_FrmVFree(msgbuf);

	return status;
}

/**************************************************************************
 * FRMQCHOI.C - frm_qchoice() function.
 *************************************************************************/

int frm_qchoice(char *buttons, char *fmt, ...)
{
	va_list args;
	int rv;

	va_start(args, fmt);
	rv = frm_vprintf(FRM_NORMAL, buttons, fmt, args);
	va_end(args);

	return rv;
}

/**************************************************************************
 * FRMQERR.C - The frm_qerror() routine.
 *************************************************************************/

int frm_qerror(int err, char *fmt, ...)
{
	va_list args;

	va_start(args, fmt);
	frm_verror(err, NULL, fmt, args);
	va_end(args);

	return err;
}

/*************************************************************************
 * FRMQMENU.C - The frm_qmenu() routine.
 *************************************************************************/

int frm_qmenu(char *title,char *strings)
{
  return frm_nlmenu(FRM_NORMAL, title, strings);
}

/**************************************************************************
 * FRMQTEXT.C - frm_qtext() function.
 *************************************************************************/

void frm_qtext(char *fmt, ...)
{
	va_list args;

	va_start(args, fmt);
	frm_vprintf(FRM_NORMAL, NULL, fmt, args);
	va_end(args);
}

/*****************************************************************************
 * EXTERROR.C - Extended error message handling.
 ****************************************************************************/

#include "exterror.h"

#define MAX_EXT_TABLES  8

static _Err_tab *extmsg_tables[MAX_EXT_TABLES] = {NULL};
static char nullstr[] = "";

/*----------------------------------------------------------------------------
 * exterrset - Install or remove an application-specific error msg table.
 *--------------------------------------------------------------------------*/

int exterrset(_Err_tab *ptab, int install)
{
	int 	 tabidx;
	_Err_tab **pptab = extmsg_tables;

	for (tabidx = 0; tabidx < MAX_EXT_TABLES; ++tabidx, ++pptab)
	{
		if (install)
		{
			if (*pptab == NULL)
			{
				*pptab = ptab;
				return E_OK;
			}
		} else
		{
			*pptab = NULL;
			return E_OK;
		}
	}

	return ERROR;
}

/*----------------------------------------------------------------------------
 * exterror - like strerror(), but looks for application-specific msg first.
 *--------------------------------------------------------------------------*/

char *exterror(int err)
{
	int 	 tabidx;
	_Err_tab *ptab;
	char	 *themsg;

	for (tabidx = 0; tabidx < MAX_EXT_TABLES; ++tabidx)
		for (ptab = extmsg_tables[tabidx]; ptab && ptab->code; ++ptab)
			if (ptab->code == err)
			{
				themsg = ptab->msg;
				goto RETURN_IT;
			}

	if (err == 0)
		themsg = nullstr;
	else
		themsg = strerror(err);

RETURN_IT:

	if (themsg == NULL)
		themsg = nullstr;

	return themsg;
}

/**************************************************************************
 * FRMERROR.C - The frm_error() and frm_qerror() routines.
 *************************************************************************/

int frm_error(int err, char *buttons, char *fmt, ...)
{
	int rv;
	va_list args;

	va_start(args, fmt);
	rv = frm_verror(err, buttons, fmt, args);
	va_end(args);

	return rv;
}

/**************************************************************************
 * FRMVERRO.C - The frm_verror() routine.
 *************************************************************************/

extern char *_Frmaddmsg;

int frm_verror(int err, char *buttons, char *fmt, va_list args)
{
	char *msg;

	if (err)
	{
		if (NULL == (msg = exterror(err)))
			msg = "<no message>";

		_Frmaddmsg = msg;
	}

	return frm_vprintf(FRM_NORMAL, buttons, fmt, args);
}

/**************************************************************************
 * FRMPRTF.C - frm_printf() function.
 *************************************************************************/

int frm_printf(long options, char *buttons, char *fmt, ...)
{
	va_list args;
	int rv;

	va_start(args, fmt);
	rv = frm_vprintf(options, buttons, fmt, args);
	va_end(args);

	return rv;
}

/**************************************************************************
 * FRMNLDSU.C - Some service routines used by frm_nl and frm_ds functions.
 *************************************************************************/

#define JUSTIFY_LEFT   0
#define JUSTIFY_CENTER 2

static TEDINFO local_tedinfos[] =
{
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1}
};

typedef struct ___size_sanity_check___
{
    char x[FRM_DSMAXSTRINGS == (sizeof(local_tedinfos)/sizeof(TEDINFO))];
} ___size_sanity_check___;

/*-------------------------------------------------------------------------
 * set width of an object and all its children.
 *-----------------------------------------------------------------------*/

void _FrmTrWidths(OBJECT *ptree, int parent, int width)
{
	int curobj;

	ptree[parent].ob_width = width;
	curobj = ptree[parent].ob_head;

	while (curobj != parent && curobj >= ROOT)
	{
		ptree[curobj].ob_width = width;
		curobj = ptree[curobj].ob_next;
	}
}

/*-------------------------------------------------------------------------
 * attach string pointers from array to tedinfo pointers,
 * attach tedinfos to tree objects.
 * if the objects pointed to by pobj are not G_xTEXT objects, it
 * attaches the strings directly to the objects and doesn't touch
 * the tedinfo array at all.
 *-----------------------------------------------------------------------*/

int _FrmDS2Obj(char **ppstr, OBJECT *pobj, TEDINFO *pted, int *pwidth, int maxobj)
{
	char *pstr;
	int len;
	int counter;
	int linecount = 0;
	int width     = *pwidth;
	int sumwidth  = FALSE;
	int center_it;

	if (width == -1)
		sumwidth = TRUE, width    = 0;

	if (pted == NULL)
		pted = local_tedinfos;

	for (counter = 0; counter < maxobj; ++counter)
	{
		pstr = *ppstr;
		if (pstr == NULL)
			pobj->ob_flags |= HIDETREE;
		else
		{
			pobj->ob_flags &= ~HIDETREE;
			if (*pstr == 0x7F)
				center_it = TRUE, ++pstr;
			else
				center_it = FALSE;

			len  = strlen(pstr);
			if (sumwidth)
				width += len;
			else if (width < len)
				width = len;

			switch (pobj->ob_type & 0x00FF)
			{
			  case G_TEXT:
			  case G_BOXTEXT:
			  case G_FTEXT:
			  case G_FBOXTEXT:
				pobj->ob_spec.index   = (long)pted;
				pted->te_ptext  = pstr;
				pted->te_txtlen = len;
				pted->te_just   = (center_it) ? JUSTIFY_CENTER : JUSTIFY_LEFT;
				break;
			  default:
				pobj->ob_spec.index   = (long)pstr;
				break;
			}
			++ppstr;
			++linecount;
		}
		++pobj;
		++pted;
	}

	*pwidth = width;
	return linecount;
}

/*-------------------------------------------------------------------------
 * Go put \n chars back in all the places where we changed them to \0.
 *-----------------------------------------------------------------------*/

void _FrmNLPatch(char **patch_array)
{
	char *thepatch;

	while (NULL != (thepatch = *patch_array))
		*thepatch = '\n', ++patch_array;
}

/*-------------------------------------------------------------------------
 * Divide \n-delimited string into set of \0-terminated strings.
 *-----------------------------------------------------------------------*/

void _FrmNL2DS(char *strings, char **pointer_array, char **patch_array, int maxstrings)
{
	int counter;
	char c;

	for (counter = 0; *strings && counter < maxstrings; ++counter)
	{
		*pointer_array = strings;
		for (;;)
		{
			c = *strings;
			if (c == '\0' || c == '\n')
				break;

			++strings;
		}

		if (c == '\n')
		{
			if (patch_array)
				*patch_array++ = strings;

			*strings++ = '\0';
		}
		if (**pointer_array == '\0')
			*pointer_array = " ";

		++pointer_array;
	}

	*pointer_array = NULL;

	if (patch_array)
	{
		*patch_array   = NULL;
	}
}

/**************************************************************************
 * FRMNLDIA.C - frm_nldialog(): Newline-delimted dialog.
 *				This is a lot like frm_dsdialog() -- it dynamically
 *				constructs a dialog box around some boilerplate text you
 *				specify, and conducts the user interaction.  For this
 *				function, the text is all one huge string, with lines
 *				delimited by NL chars.
 *************************************************************************/

int frm_nldialog(long options, char *buttons, char *strings)
{
	int status;
	char *strptrs[FRM_DSMAXSTRINGS+1];
	char *strpatches[FRM_DSMAXSTRINGS+1];
	char *btnptrs[FRM_DSMAXBUTTONS+1];
	char *btnpatches[FRM_DSMAXBUTTONS+1];

	if (buttons == NULL || *buttons == '\0')
		buttons = " Continue ";

	if (strings == NULL || *strings == '\0')
		strings = "<no message>";

	_FrmNL2DS(buttons, btnptrs, btnpatches, FRM_DSMAXBUTTONS);
	_FrmNL2DS(strings, strptrs, strpatches, FRM_DSMAXSTRINGS);

	status = frm_dsdialog(options, btnptrs, strptrs);

	_FrmNLPatch(strpatches);
	_FrmNLPatch(btnpatches);

	return status;
}

/**************************************************************************
 * FRMNLMEN.C - frm_nlmenu(): Newline-delimited menu.
 *************************************************************************/

int frm_nlmenu(long options, char *title, char *strings)
{
	int status;
	char *strptrs[FRM_DSMAXSTRINGS+1];
	char *strpatches[FRM_DSMAXSTRINGS+1];

	if (strings == NULL || *strings == '\0')
		strings = "<error: no items>";

	_FrmNL2DS(strings, strptrs, strpatches, FRM_DSMAXSTRINGS);

	status = frm_dsmenu(options, title, strptrs);

	_FrmNLPatch(strpatches);

	return status;
}

/*************************************************************************
 * FRMDSMEN.C - The frm_dsmenu() routine.
 *************************************************************************/

static TEDINFO title_tedinfo =
{
  NULL, NULL, NULL, 3, 6, 2, 0x11F0, 0, -1,   1,   1
};

static OBJECT menutree[] = {
 { -1,  1,  2, G_BOX,      NONE,       NORMAL,   (long)(0x00FF1100L),       0x0000, 0x0000, 0x0001, 0x0016},
 {  2, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   (long)(&title_tedinfo),    0x0000, 0x0000, 0x0001, 0x0101},
 {  0,  3, 22, G_IBOX,     NONE,       NORMAL,   (long)(0x00001100L),       0x0001, 0x0002, 0x0001, 0x0014},
 {  4, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0000, 0x0001, 0x0001},
 {  5, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0001, 0x0001, 0x0001},
 {  6, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0002, 0x0001, 0x0001},
 {  7, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0003, 0x0001, 0x0001},
 {  8, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0004, 0x0001, 0x0001},
 {  9, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0005, 0x0001, 0x0001},
 { 10, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0006, 0x0001, 0x0001},
 { 11, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0007, 0x0001, 0x0001},
 { 12, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0008, 0x0001, 0x0001},
 { 13, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0009, 0x0001, 0x0001},
 { 14, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000A, 0x0001, 0x0001},
 { 15, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000B, 0x0001, 0x0001},
 { 16, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000C, 0x0001, 0x0001},
 { 17, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000D, 0x0001, 0x0001},
 { 18, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000E, 0x0001, 0x0001},
 { 19, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000F, 0x0001, 0x0001},
 { 20, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0010, 0x0001, 0x0001},
 { 21, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0011, 0x0001, 0x0001},
 { 22, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0012, 0x0001, 0x0001},
 {  2, -1, -1, G_BOXTEXT,  0x0021,     NORMAL,   (long)(0L),                0x0000, 0x0013, 0x0001, 0x0001}
};

#define TITLE_BOX           1
#define TEXT_BOX            2
#define FIRST_TEXT_LINE     3
#define LAST_TEXT_LINE     22

int frm_dsmenu(long options, char *title, char **strings)
{
	int maxwidth;
	int numlines;
	int selection;
	int hhalf = gl_hchar / 2;
	OBJECT *ptree = menutree;
	static int initdone = FALSE;

	if (!(options & FRM_NODEFAULTS))
		options |= (_FrmDefaults & FRM_DOPTIONBITS) | FRM_DEFAULT_DYNOPT;

	options |= FRM_MANDATORY_DYNOPT;

	if (!initdone)
	{
		initdone = TRUE;
		rsc_treefix(ptree);
	}

	if (title != NULL)
	{
		ptree->ob_flags 		  = NORMAL;
		ptree[TITLE_BOX].ob_flags = FRM_MOVER|TOUCHEXIT;
		ptree[TEXT_BOX].ob_y	  = ptree[TITLE_BOX].ob_height + hhalf;
		title_tedinfo.te_ptext    = title;
		maxwidth				  = strlen(title);
	}
	else
	{
		ptree->ob_flags 		  = FRM_MOVER|TOUCHEXIT;
		ptree[TITLE_BOX].ob_flags = HIDETREE;
		ptree[TEXT_BOX].ob_y	  = hhalf;
		maxwidth				  = 1;
	}

	ptree->ob_state = (options & FRM_DSHADOWED) ? SHADOWED : NORMAL;

	numlines = _FrmDS2Obj(strings, &ptree[FIRST_TEXT_LINE], NULL,
							&maxwidth, FRM_DSMAXSTRINGS);

	_FrmTrWidths(ptree, ROOT,     (maxwidth+2)*gl_wchar);
	_FrmTrWidths(ptree, TEXT_BOX, maxwidth*gl_wchar);

	ptree[TEXT_BOX].ob_height = numlines * gl_hchar;
	ptree->ob_height = ptree[TEXT_BOX].ob_height + ptree[TEXT_BOX].ob_y + hhalf;

	selection = frm_menu(options, ptree, SELECTED);

	if (selection > NO_OBJECT)
	{
		ptree[selection].ob_state &= ~SELECTED;
		selection -= FIRST_TEXT_LINE-1; /* adjust to 1-based index. 		*/
		if (selection == numlines)  	/* last selection is returned as	*/
			selection = 0;  			/* zero; it s/b Cancel, Exit, etc.  */
	}

	return selection;
}

/**************************************************************************
 * FRMMENU.C - The frm_menu() and frm_mdo() functions.
 *************************************************************************/

#define BLITOPTIONS (FRM_USEBLIT|FRM_MOVEABLE)

#define MU_M1_ENTRY 0
#define MU_M1_EXIT  1

static void wait_buttonup(void)
{
    int dmy;
    evnt_button(1,1,0,&dmy,&dmy,&dmy,&dmy);
}

int frm_mdo(FormControl *ctl)
{
	int mx;
	int my;
	int mb;
	int dmy;
	int exit_condition;
	int mouse_object;
	int watch_object;
	int selected_object;
/*	int oldmouse;
*/	int ob_flags;
	int ob_state;
	GRECT leaverect;
	XMULTI xm;
	OBJECT *ptree = ctl->ptree;

	wind_update(BEG_MCTRL);
/*	oldmouse = graf_mouse(GRF_MSINQUIRE, NULL);
*/
	if (ctl->options & FRM_MEXITPARENT)
		obj_clcalc(ptree, ctl->parentobj, &leaverect, NULL);
	else if (ctl->options & FRM_MEXITVICINITY)
	{
		obj_clcalc(ptree, ctl->parentobj, &leaverect, NULL);
		rc_gadjust(&leaverect, 4*gl_wchar, 2*gl_hchar);
		rc_intersect(&gl_rwdesk,  &leaverect);
	}
	else
		rc_copy(&gl_rwdesk, &leaverect);

	watch_object	= ctl->parentobj;
	selected_object = NO_OBJECT;

	xm.mflags   = MU_M1 | MU_BUTTON;
	xm.mbclicks = 1;
	xm.mbmask   = 1;
	xm.mbstate  = 1;
	xm.mm1flags = MU_M1_ENTRY;

	if (ctl->defaultobj != NO_OBJECT)
		xm.mflags |= MU_KEYBD;

	do
	{
		exit_condition = FALSE;
		obj_clcalc(ptree, watch_object, &xm.mm1rect, NULL);

		evnx_multi(&xm);
		graf_mkstate(&mx, &my, &mb, &dmy);

		if ((xm.mwhich & MU_M1) && (selected_object != NO_OBJECT))
		{
			obj_stchange(ptree, selected_object, ~ctl->select_state,
				OBJ_CLIPDRAW, ctl->pboundrect);
			selected_object = NO_OBJECT;
		}

		mouse_object = objc_find(ptree, ctl->parentobj, MAX_DEPTH, mx, my);
		watch_object = ctl->parentobj;
		xm.mm1flags  = MU_M1_ENTRY;

		if (mouse_object == NO_OBJECT)
		{
			if (!rc_ptinrect(&leaverect, mx, my))
				exit_condition = TRUE;
		}
		else
		{
			ob_flags = ptree[mouse_object].ob_flags;
			ob_state = ptree[mouse_object].ob_state;
			if ( (ob_flags & (SELECTABLE|EXIT|TOUCHEXIT|DEFAULT)) &&
				!(ob_state & DISABLED))
			{
				selected_object = mouse_object;
				if (!(ob_flags & (EXIT|DEFAULT|TOUCHEXIT)))
				{
					watch_object = mouse_object;
					xm.mm1flags = MU_M1_EXIT;
					obj_stchange(ptree, mouse_object, ctl->select_state,
						OBJ_CLIPDRAW, ctl->pboundrect);
				}
			}
		}

		if (xm.mwhich & MU_BUTTON)
		{
			exit_condition = TRUE;
			if (selected_object != NO_OBJECT && (ob_flags & (EXIT|DEFAULT)))
			{
				if (!graf_watchbox(ptree, selected_object, ctl->select_state, ob_state))
				{
					exit_condition = FALSE;
					selected_object = NO_OBJECT;
				}
			}
		}

		if (xm.mwhich & MU_KEYBD && (xm.mkreturn & 0x00FF) == '\r')
		{
			selected_object = ctl->defaultobj;
			exit_condition  = TRUE;
			obj_stchange(ptree, selected_object, ctl->select_state,
				OBJ_CLIPDRAW, ctl->pboundrect);
		}

		if ((ctl->options & FRM_DMUSTSELECT) && selected_object == NO_OBJECT)
			exit_condition = FALSE;

	} while (!exit_condition);

	wind_update(END_MCTRL);

	return selected_object;
}

static int find_default_exit(OBJECT *ptree)
{
	int    counter = 0;

	for (;;)
	{
		if (ptree->ob_flags & DEFAULT)
			return counter;

		if (ptree->ob_flags & LASTOB)
			return NO_OBJECT;

		++ptree;
		++counter;
	}
}

int frm_menu(long options, OBJECT *ptree, int select_state)
{
	FormControl 	ctl;
	int 			selobj;
	long			actions;

	if (0 == (actions = options & FRM_ACTIONBITS))
		options  |= (actions = FRM_DCOMPLETE);

	if (actions == FRM_DCOMPLETE)
	{
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
	}
	else
		if (options & BLITOPTIONS)
			options &= ~BLITOPTIONS;

	wait_buttonup();

	_FrmSetup(&ctl, options, ptree, NULL);
	ctl.select_state = select_state;
	ctl.form_do 	 = frm_mdo;
	ctl.defaultobj   = find_default_exit(ptree);

	if (actions & FRM_DSTART)
		frm_start(&ctl);

	if (actions & FRM_DDRAW)
		frm_draw(&ctl, ROOT);

	if (actions & FRM_DDO)
		selobj = frm_do(&ctl, 0);

	if (actions & FRM_DFINISH)
		frm_finish(&ctl);

	frm_cleanup(&ctl);

	if (!(ptree[selobj].ob_flags & TOUCHEXIT))
		wait_buttonup();


	if (actions == FRM_DCOMPLETE)
	{
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
	}

	return selobj;
}

/**************************************************************************
 * FRMENABL.C - Set the blit function vector.
 *************************************************************************/

extern BLITFU *_FrBltVector;

void frm_enableblit(void)
{
	_FrBltVector = grf_blit;
}

/**************************************************************************
 * FRMCONFI.C - The frm_confine() function.
 *************************************************************************/

void frm_confine(OBJECT *ptree, GRECT *boundrect)
{
	GRECT  *prect = (GRECT *)&ptree->ob_x;

	if (ptree->ob_state & (OUTLINED|SHADOWED))
		rc_gadjust(prect, 4, 4);

	rc_confine(boundrect, prect);

	if (ptree->ob_state & (OUTLINED|SHADOWED))
		rc_gadjust(prect, -4, -4);
}

/**************************************************************************
 *
 *************************************************************************/

#define MOVER_CANT_BE (SELECTABLE|DEFAULT|EXIT|EDITABLE|RBUTTON|HIDETREE)
#define MOVER_MUST_BE (FRM_MOVER|TOUCHEXIT)

int frm_mkmoveable(OBJECT *ptree, int object)
{
	int oldflags;

	ptree   		= &ptree[object];
	oldflags		= ptree->ob_flags;
	ptree->ob_flags = (oldflags & ~MOVER_CANT_BE) | MOVER_MUST_BE;
	return oldflags;
}
