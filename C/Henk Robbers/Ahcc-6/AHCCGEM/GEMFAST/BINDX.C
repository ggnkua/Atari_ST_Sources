/***************************************************************
 * BINDX.C various variations on bindings                      *
 ***************************************************************/

#include "gemf.h"

#ifndef NULL
  #define NULL 0L
#endif

/**************************************************************************
 * EVNXMULT.C -  Extended event_multi() routine...
 *************************************************************************/

int evnx_multi(XMULTI *xm)
{
	return xm->mwhich = evnt_multi(
		xm->mflags,
		xm->mbclicks,
		xm->mbmask,
		xm->mbstate,
		xm->mm1flags,
		xm->mm1rect.g_x,
		xm->mm1rect.g_y,
		xm->mm1rect.g_w,
		xm->mm1rect.g_h,
		xm->mm2flags,
		xm->mm2rect.g_x,
		xm->mm2rect.g_y,
		xm->mm2rect.g_w,
		xm->mm2rect.g_h,
		xm->msgbuf,
		xm->mtlocount,
		xm->mthicount,
		&xm->mmox,
		&xm->mmoy,
		&xm->mmobutton,
		&xm->mmokstate,
		&xm->mkreturn,
		&xm->mbreturn);
}

/**************************************************************************
 * FRMXCENT.C -  Extended form_center() function.
 *************************************************************************/

int frmx_center(OBJECT *ptree, GRECT *prect)
{
  return form_center(ptree,&prect->g_x,&prect->g_y,&prect->g_w,&prect->g_h);
}
/**************************************************************************
 * FRMXDIAL.C -  Extended form_dial() function.
 *************************************************************************/

int frmx_dial(int flag, GRECT *plittle, GRECT *pbig)
{
	static GRECT dmyrect = {0,0,0,0};

	if (plittle == NULL)
		plittle = &dmyrect;

	return form_dial
		(flag,
			plittle->g_x,
			plittle->g_y,
			plittle->g_w,
			plittle->g_h,
			pbig->g_x,
			pbig->g_y,
			pbig->g_w,
			pbig->g_h
		);
}

/**************************************************************************
 * GRFXDRAG.C - Extended graf_dragbox() function.
 *************************************************************************/

int grfx_dragbox(GRECT *startrect, GRECT *boundrect, GRECT *endrect)
{
	if (boundrect == NULL)
		boundrect = &gl_rwdesk;

	endrect->g_w = startrect->g_w;
	endrect->g_h = startrect->g_h;

	return graf_dragbox(startrect->g_w, startrect->g_h,
						startrect->g_x, startrect->g_y,
						boundrect->g_x, boundrect->g_y,
						boundrect->g_w, boundrect->g_h,
						&endrect->g_x,  &endrect->g_y);

}

/**************************************************************************
 * WINXCALC.C - Extended wind_calc() function.
 *************************************************************************/

int winx_calc(int type, int kind, GRECT inrect, GRECT *poutrect)
{
	return wind_calc(type, kind,
		inrect.g_x,
		inrect.g_y,
		inrect.g_w,
		inrect.g_h,
		&poutrect->g_x,
		&poutrect->g_y,
		&poutrect->g_w,
		&poutrect->g_h);
}

/**************************************************************************
 * WINXGET.C - Extended wind_get() function.
 *************************************************************************/

int winx_get(
    int whandle,
    int wfield,
    GRECT *prect)
{
	return wind_get(whandle, wfield,
					&prect->g_x, &prect->g_y,
					&prect->g_w, &prect->g_h);
}

/**************************************************************************
 * WNDTOP.C - The wnd_top() function.
 *            This critter is somewhere between a utility and a binding.
 *************************************************************************/

int wnd_top(void)
{
	int topwindow;
	int dmy;

	wind_get(0, WF_TOP, &topwindow, &dmy, &dmy, &dmy);

	return topwindow;
}

/**************************************************************************
 * WNDUPDAT.C - Implement nested wind_update() logic.
 *************************************************************************/

#undef wind_update    /* undo GEMFAST.H remapping, we need The Real Thing */

static int  windowcount;
static int  mousecount;

int wnd_update(int flag)
{
	int *counter;

	counter = (flag & 0x0002) ? &mousecount : &windowcount;

	if (flag & 0x0001)  					/* BEG_UPDATE or BEG_MCTRL, count */
	{
		if (++(*counter) == 1)  			/* it. if we went from 0 to 1, we */
			return wind_update(flag);   	/* need to aquire the semaphore.  */
	}
	else									/* END_UPDATE or END_MCTRL    */
		if (*counter > 0)   				/* if we're currently holding */
			if (--(*counter) == 0)  		/* semaphore, decr count, if  */
				return wind_update(flag);   /* it goes to 0, release it.  */
	return 1;
}

/**************************************************************************
 * MNUBAR.C - The mnu_bar(), mnu_enable(), and mnu_disable() functions.
 *************************************************************************/

#undef menu_bar

static void *lastmenu;
static int  hidecount;

int mnu_bar(void *menutree, int flag, long reserved)
{
	lastmenu  = (flag) ? menutree : NULL;
	hidecount = 0;
	return menu_bar(menutree, flag);
}

void mnu_disable(void)
{
	if (lastmenu != NULL)
		if (++hidecount == 1)
			menu_bar(lastmenu, 0);
}

void mnu_enable(void)
{
	if (lastmenu != NULL)
		if (--hidecount <= 0)
			hidecount = 0, menu_bar(lastmenu, 1);
}
