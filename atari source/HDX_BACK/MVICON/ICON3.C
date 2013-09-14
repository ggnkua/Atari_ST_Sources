#include "obdefs.h" 
#include "gemdefs.h"
#include "osbind.h"

/* AES (windows and messages) related variables */
int gl_hchar;
int gl_wchar;
int gl_wbox;
int gl_hbox;
int phys_handle;
int handle;
int wi_handle;
int formw, formh, sx, sy, lx, ly;
int xdesk, ydesk, hdesk, wdesk;
int xwork, ywork, hwork, wwork;

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];

int work_in[11];
int work_out[57];

main()
{
	int gr_mkmx, gr_mkmy;
	int gr_mkmstate, gr_mkkstate;
	int tmpx, tmpy;
	int tmpx1, tmpy1;
	int tmpx2, tmpy2;
	int index, rgb_in[3];
	int draw;

	appl_init();
	phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	open_vwork();
	wi_handle = wind_create(0x0040&0x0080, xdesk, ydesk, wdesk, hdesk);
	graf_mouse(3, 0x0L);
	graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
	vswr_mode(handle, 3);
	v_enter_cur(handle);
	v_exit_cur(handle);
	graf_mouse(M_OFF, 0x0L);
	drawicon(gr_mkmx,gr_mkmy);
	graf_mouse(M_ON, 0x0L);
	while(!(0x0002&gr_mkmstate))	{
		graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
		tmpx1 = gr_mkmx;
		tmpy1 = gr_mkmy;
		graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
		if (((tmpx1 != gr_mkmx) || (tmpy1 != gr_mkmy)) &&
				(0x0001&gr_mkmstate))	{
			v_enter_cur(handle);
			v_exit_cur(handle);
			graf_mouse(M_OFF, 0x0L);
			drawicon(gr_mkmx,gr_mkmy);
			graf_mouse(M_ON, 0x0L);
		}
	}
	wind_delete(wi_handle);
	v_clsvwk(handle);
	appl_exit();
}

open_vwork()
{
	int i;

	for (i=0; i < 10;)
		work_in[i++] = 1;
	work_in[10] = 2;
	handle = phys_handle;
	v_opnvwk(work_in, &handle, work_out);
}


abs(x, y)
int x,y;
{
	if (x > y)	{
		return(x - y);
	} else {
		return(y - x);
	}
}
