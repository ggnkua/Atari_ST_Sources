/**************************************************************************
 *                                                                        *
 *                             FLDLIB DEMO 3                              *
 *           Demonstrates multiple form and window management             *
 *                                                                        *
 **************************************************************************/

#include <stdlib.h>
#include <aes.h>
#include "fldlib.h"
#include "demo.h"

OBJECT *form1, *form2;
short form1handle, form2handle;
int windowhandle;
short vdihandle, work_out[57], work_in[] = {1,1,1,1,1,1,1,1,1,1,2};

void object_handle(short, short);
int  main(void);


void gem_init(void)  {
	short dummy;
	
	vdihandle = graf_handle(&dummy, &dummy, &dummy, &dummy);
	v_opnvwk(work_in, &vdihandle, work_out);
	
	windowhandle = wind_create(NAME|CLOSE|MOVE|SIZE|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE, 100, 100, 100, 100);
	wind_title(windowhandle, "Another GEM window");
	wind_set(windowhandle, WF_HSLIDE, 1);
	wind_set(windowhandle, WF_HSLSIZE, 1000);
	wind_set(windowhandle, WF_VSLIDE, 1);
	wind_set(windowhandle, WF_VSLSIZE, 1000);
	wind_open(windowhandle, 100, 100, 200, 150);
}


void finish(void)  {
	fld_exit();
	
	wind_close(windowhandle);
	wind_delete(windowhandle);
	
	v_clsvwk(vdihandle);
	
	rsrc_free();
	
	appl_exit();
	exit(0);
}


void object_handle(short object, short type)  {
	switch(type)  {
	case FORM1:

		switch (object)  {
		case FM1_EXIT1:
			form_alert(1, "[1][ Exit 1 | selected ][ OK ]");
			finish();
			break;
		case FM1_EXIT2:
			form_alert(1, "[1][ Exit 2 | selected ][ OK ]");
			finish();
			break;
		case FM_DL2:
			form2handle = fld_open(form2, FLDC_MOUSE, "FLDLIB Demo", FORM2);
			form1[FM_DL2].ob_state &= ~SELECTED;
			fld_draw(form1handle, FM_DL2, 0);
			break;
		}

		break;
	case FORM2:

		switch (object)  {
		case FM2_OK:
			fld_close(form2handle);
			form2[FM2_OK].ob_state &= ~SELECTED;
			break;
		}

		break;
	}
}


int redraw_window(int windowhandle, GRECT *rect)  {
	short pxyarray[4];
	
	pxyarray[0] = rect->g_x;
	pxyarray[1] = rect->g_y;
	pxyarray[2] = rect->g_x + rect->g_w - 1;
	pxyarray[3] = rect->g_y + rect->g_h - 1;
	
	vsf_style(vdihandle, 8);
	vsf_interior(vdihandle, 2);
	vsf_color(vdihandle, WHITE);
	vr_recfl(vdihandle, pxyarray);
	
	return 1;
}


void do_mesag(short *msgbuf)  {
	switch (msgbuf[0])  {
	case WM_REDRAW:
		if (msgbuf[3] == windowhandle)
			wind_redraw(windowhandle, (GRECT *) (msgbuf + 4), redraw_window);
		break;
	case WM_TOPPED:
		if (msgbuf[3] == windowhandle)
			wind_set(windowhandle, WF_TOP);
		break;
	case WM_CLOSED:
		if (msgbuf[3] == windowhandle)
			finish();
		break;
	case WM_SIZED: case WM_MOVED:
		if (msgbuf[3] == windowhandle)
			wind_set(windowhandle, WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
		break;
	}
}


int main(void)  {
	short ret, type, handle, msgbuf[8], mx, my, mb, mk, kc, numclicks, evnts;

	appl_init();

	if (!rsrc_load("DEMO.RSC"))  {
		form_alert(1,"[3][ Could not find | DEMO.RSC ][ Exit ]");
		appl_exit();
		return 0;
	}

	rsrc_gaddr(R_TREE, FORM1, &form1);
	rsrc_gaddr(R_TREE, FORM2, &form2);

	form1handle = fld_open(form1, FLDC_SCREEN, "FLDLIB Demo", FORM1);
	
	gem_init();

	graf_mouse(ARROW, NULL);

	while (1)  {
		evnts = evnt_multi(MU_KEYBD|MU_BUTTON|MU_MESAG, 2, 1, 1,  /* Flags + clicks */
		                   0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  /* Rects to watch (none) */
		                   msgbuf, 0, 0, &mx, &my, &mb, &mk, /* Msg buffer + mouse click */
		                   &kc, &numclicks);

		if (evnts & MU_KEYBD)
			if ((ret = fld_key(kc, &type, &handle)) != -1)  {
				object_handle(ret, type);
			}
		if (evnts & MU_BUTTON)
			if ((ret = fld_mouse(mx, my, numclicks, &type, &handle)) != -1)  {
				object_handle(ret, type);
			}
		if (evnts & MU_MESAG)  {
			do_mesag(msgbuf);
			fld_mesag(msgbuf);
		}
	}


	return 0;
}