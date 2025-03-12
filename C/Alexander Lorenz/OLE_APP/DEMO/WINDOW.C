#include <aes.h>

#include "demo.h"
#include "oep.h"
#include "dd.h"
#include "oep_demo.h"


extern OBJECT *menue;


WORD win_open(BYTE *title, DATAINFO *datainfo)
{
	/*
	*	Fenster ”ffnen
	*/
	
	WORD handle, dummy, attr;
	WORD x, y, w, h;
	OBJECT *data;
	
	wind_get(DESK, WF_WORKXYWH, &x, &y, &dummy, &dummy);

	rsrc_gaddr(R_TREE, DATA, &data);
	w = data[DATA_BOX].ob_width;
	h = data[DATA_BOX].ob_height;
	
	attr = NAME|MOVER|CLOSER;
	
	wind_calc(WC_BORDER, attr, x, y, w, h, &dummy, &dummy, &w, &h);
	
	handle = wind_create(attr, x, y, w, h);
	if (handle > 0)
	{
		wind_update(BEG_UPDATE);
		wind_set(handle, WF_NAME, title);
		wind_open(handle, x, y, w, h);
		
		menu_ienable(menue, M_CLOSE, 1);
		menu_ienable(menue, M_UPDATE, 1);
		wind_update(END_UPDATE);
		
		if (datainfo > NULL)
		{
			datainfo->id = 0L;
			datainfo->date = 0;
			datainfo->time = 0;
			datainfo->systime = 0L;
			datainfo->cid = 0L;

			init_datainfo(datainfo);
		}
	}

	return(handle);
}


VOID win_close(WORD handle, DATAINFO *datainfo)
{
	/*
	*	Fenster schliežen
	*/
	
	if (handle > 0)
	{
		wind_update(BEG_UPDATE);
		wind_close(handle);
		wind_delete(handle);

		if (menue > 0L)
		{
			menu_ienable(menue, M_CLOSE, 0);
			menu_ienable(menue, M_UPDATE, 0);
		}
		wind_update(END_UPDATE);

		if (datainfo > NULL)
		{
			unlink_doc(datainfo);
		}
	}
}


VOID win_redraw(WORD handle, WORD x, WORD y, WORD w, WORD h)
{
	/*
	*	Fenster(bereich) neu zeichnen
	*/
	
	WORD p1, p2, p3, p4;
	OBJECT *data;
	
	if (handle > 0)
	{
		rsrc_gaddr(R_TREE, DATA, &data);

		wind_get(handle, WF_WORKXYWH, &p1, &p2, &p3, &p4);
		data[DATA_BOX].ob_x = p1;
		data[DATA_BOX].ob_y = p2;
		
		objc_draw(data, 0, 7, x, y, w, h);
	}
}


VOID win_draw(WORD handle)
{
	/*
	*	Komplettes Fenster neu zeichnen
	*/
	
	WORD x, y, w, h;
	
	if (handle > 0)
	{
		wind_update(BEG_UPDATE);
		wind_get(handle, WF_WORKXYWH, &x, &y, &w, &h);
		wind_update(END_UPDATE);
		
		redraw(handle, x, y, w, h);
	}
}


VOID win_top(WORD handle)
{
	/*
	*	Fenster toppen
	*/
	
	if (handle > 0)
		wind_set(handle, WF_TOP, 0, 0, 0, 0);
}


VOID win_bottom(WORD handle)
{
	/*
	*	Fenster bottomen
	*/
	
	if (handle > 0)
		wind_set(handle, WF_BOTTOM, 0, 0, 0, 0);
}


VOID win_move(WORD handle, WORD x, WORD y, WORD w, WORD h)
{
	/*
	*	Fenster verschieben
	*/
	
	if (handle > 0)
		wind_set(handle, WF_CURRXYWH, x, y, w, h);
}
