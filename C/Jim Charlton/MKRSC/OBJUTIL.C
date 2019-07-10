#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "mkrsc.h"
#include "globals.h"



draw_inwind(thewin,blank)
	windowptr thewin;
	int	blank;
{
	int	cx, cy, cw, ch;
	OBJECT *inwind;

	inwind = thewin->inwindow->objt;

	cx = thewin->work.g_x;
	cy = thewin->work.g_y;
	cw = thewin->work.g_w;
	ch = thewin->work.g_h;
	
	if(blank)
		whiterect(thefrontwin);

	if(thefrontwin->inwindow->kind[0] == TMENU)
	{
		objc_draw(inwind,1,2,cx,cy,cw,ch);
		if(thefrontwin->inwindow->mbox > 0) 	
			objc_draw(inwind,thefrontwin->inwindow->mbox,10,cx,cy,cw,ch);
	}
	else

	objc_draw(inwind, 0, 10, cx, cy, cw, ch);
}

   /* draw dialog boxes   */
int do_dialog(dialog,start_obj)   /* with form_do   */
	OBJECT	*dialog;
	int		start_obj;
{
    int cx, cy, cw, ch;  /* dialog box dimensions  */
	int button;

	form_center(dialog, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(dialog, 0, 10, cx, cy, cw, ch);
	button = form_do(dialog, start_obj);
	form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
	return(button);
}

/* draw object .. no form_do  only to draw icon palettes	*/

int draw_obj(obj)
OBJECT *obj;
{
	int	cx, cy, cw, ch;

	cx = obj->ob_x;
	cy = obj->ob_y;
	cw = obj->ob_width;
	ch = obj->ob_height;

	objc_draw(obj, 1, 10, cx, cy, cw, ch);
}
