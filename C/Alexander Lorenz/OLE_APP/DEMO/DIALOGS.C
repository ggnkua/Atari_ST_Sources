#include <aes.h>
#include <string.h>

#include "portab.h"
#include "oep_demo.h"


VOID about(VOID)
{
	/*
	*	About-Dialogbox aufbauen und abhandeln
	*/
	
	WORD nr, x, y, w, h;
	OBJECT *dialog;
	
	rsrc_gaddr(R_TREE, ABOUT, &dialog);
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	form_center(dialog, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
	form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);
	objc_draw(dialog, 0, 7, x, y, w, h);
	nr = form_do(dialog, 0);
	form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h);
	form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	
	if (nr == ABOUT_OK)
		dialog[ABOUT_OK].ob_state &= ~SELECTED;
}


WORD change(VOID)
{
	/*
	*	About-Dialogbox aufbauen und abhandeln
	*/
	
	WORD nr, x, y, w, h, ret;
	OBJECT *dialog, *data;
	
	rsrc_gaddr(R_TREE, CHANGE, &dialog);
	rsrc_gaddr(R_TREE, DATA, &data);
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	form_center(dialog, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
	form_dial(FMD_GROW, 0, 0, 0, 0, x, y, w, h);
	objc_draw(dialog, 0, 7, x, y, w, h);
	nr = form_do(dialog, CHANGE_DT);
	form_dial(FMD_SHRINK, 0, 0, 0, 0, x, y, w, h);
	form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
	
	if (nr == CHANGE_OK)
	{
		dialog[nr].ob_state &= ~SELECTED;
		strcpy(data[DATA_DT].ob_spec.tedinfo->te_ptext, dialog[CHANGE_DT].ob_spec.tedinfo->te_ptext);
		ret = 1;
	}
	else
	{
		dialog[CHANGE_CANCEL].ob_state &= ~SELECTED;
		ret = 0;
	}

	return(ret);
}
