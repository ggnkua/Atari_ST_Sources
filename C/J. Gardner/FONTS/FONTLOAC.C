
/*
 * ST/FONT!  Ver. 100285 PB
 *				  120285 JAG
 * file:  B:FONTLOAD.C
 * (c) 1985 Antic Publishing
 *
 * The purpose of this program is to access character fonts from an
 * 8-bit Atari and display them from within the 520ST.
 *
 */

#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"

extern	int gl_apid;

int		gl_hchar, gl_wchar, gl_wbox, gl_hbox,
		menu_id, phys_handle, handle, file_handle, wi_handle, top_window,
		xdesk, ydesk, hdesk, wdesk, xold, yold, hold, wold,
		xwork, ywork, hwork, wwork,
		msgbuff[8], keycode, ret,
		i, j, k, l, done, button,
		contrl[12], intin[128], ptsin[128], intout[128], ptsout[128],
		work_in[11], work_out[57];

char	file_buffer[32768], path[] = "a:*.FNT\0", file_name[] = "NEW     .FNT\0",
		alert0[] = "[3][ Place Fonts in Drive A: ][ Read Disk ]",
		alert1[] = "[3][ ST/FONT! v.120285 | Font Load Complete | | System Configured ][ Exit ]";

long	max_len = 32768,
		char8x8 = 0x00018006,
		char8x16 = 0x00018a62,
		number, source_char;


/*--------------------------------------------------------------------------*/
main()
{
	appl_init();
	phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	menu_id = menu_register(gl_apid,"  ST Font Loader ");
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);

	wi_handle = (-1);

	fontable();
}

/*--------------------------------------------------------------------------*/
open_vwork()
{
int		i;

	for(i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	handle = phys_handle;
	v_opnvwk(work_in, &handle, work_out);
}

/*--------------------------------------------------------------------------*/
set_clip(x, y, w, h)
int		x, y, w, h;

{
int		clip[4];

	clip[0] = x;
	clip[1] = y;
	clip[2] = x + w;
	clip[3] = y + h;
	vs_clip(handle, 1, clip);
}

/*--------------------------------------------------------------------------*/
open_window()
{
	wi_handle = wind_create(NAME, (xdesk + wdesk) / 4, (ydesk + hdesk) / 4,
								   wdesk / 2, hdesk / 2);
	wind_set(wi_handle, WF_NAME, " ST/FONT! ", 0, 0);
	graf_growbox(10, 10, 10, 10, (xdesk + wdesk) / 4, (ydesk + hdesk) / 4,
								  wdesk / 2, hdesk / 2);
	wind_open(wi_handle, (xdesk + wdesk) / 4, (ydesk + hdesk) /4,
						  wdesk /2, hdesk /2);
	wind_get(wi_handle, WF_WORKXYWH, &xwork, &ywork, &wwork, &hwork);
}

/*--------------------------------------------------------------------------*/
do_redraw(xc, yc, wc, hc)
int		xc, yc, wc, hc;

{
GRECT	t1, t2;

	wind_update(TRUE);
	t2.g_x = xc;
	t2.g_y = yc;
	t2.g_w = wc;
	t2.g_h = hc;
	wind_get(wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);

	while(t1.g_w && t1.g_h)
	{
		if(rc_intersect(&t2, &t1))
		{
			set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
			do_font();
		}
		wind_get(wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
	}
	wind_update(FALSE);
}

/*--------------------------------------------------------------------------*/
fontable()
{
int		event;

	while(TRUE)
	{
		event = evnt_multi(MU_MESAG,
						   1, 1, ret,
						   0, 0, 0, 0, 0,
						   0, 0, 0, 0, 0,
						   msgbuff, 0, 0, &ret, &ret, &ret, &ret, &ret, &ret);

		wind_update(TRUE);

		if(event & MU_MESAG)
		{
			switch(msgbuff[0])
			{
				case WM_REDRAW:
					if(msgbuff[3] == wi_handle)
						do_redraw(msgbuff[4], msgbuff[5],
								  msgbuff[6], msgbuff[7]);
				break;

				case AC_OPEN:
					if(msgbuff[4] == menu_id)
					{
						if(wi_handle == (-1))
						{
							open_vwork();
							open_window();
						}
						else
							wind_set(wi_handle, WF_TOP, 0, 0, 0, 0);
					}
				break;

				case AC_CLOSE:
					if(msgbuff[3] == menu_id && wi_handle != (-1))
					{
						v_clsvwk(handle);
						wi_handle = (-1);
					}
				break;

			} /* end switch */
			wind_update(FALSE);

		} /* end if */
	} /* end while */
}

/*--------------------------------------------------------------------------*/
do_font()
{
	clear_window();

	form_alert(1, alert0);
	fsel_input(path, file_name, &button);

	if(button != 0)
	{
		graf_mouse(M_OFF, 0x0L);
		clear_window();

		file_handle = Fopen(file_name, 0);

		if(file_handle > (-1))
		{
			done = Fread(file_handle, max_len, file_buffer);
			bios(38, configure());
		}

		Fclose(file_handle);
		graf_mouse(M_ON, 0x0L);
	}

	clear_window();
	form_alert(1, alert1);

	wind_close(wi_handle);
	graf_shrinkbox(10, 10, 10, 10, (xdesk + wdesk) / 4, (ydesk + hdesk) / 4,
				   wdesk / 2, hdesk / 2);
	wind_delete(wi_handle);

	msgbuff[0] = AC_CLOSE;
	msgbuff[3] = menu_id;
	wi_handle = (-1);
}

/*--------------------------------------------------------------------------*/
clear_window()
{
int		temp[4];

	vsf_interior(handle, 2);
	vsf_style(handle, 8);
	vsf_color(handle, 0);
	temp[0] = xdesk;
	temp[1] = ydesk;
	temp[2] = xdesk + wdesk;
	temp[3] = ydesk + hdesk;
	v_bar(handle, temp);
}

/*--------------------------------------------------------------------------*/
configure()
{
char	*point1, *point2;

	for(i = 0; i < 128; i++)
	{
		l = i;
		if(i < 32)
			l = l + 64;
		if(i > 31 && i < 96)
			l = l - 32;
		for(j = 0; j < 16; j++)
		{
			source_char = (l * 8) + (j / 2);

			point1 = (char8x8 + (j * 128)) + i;
			point2 = (char8x16 + (j * 256)) + i;
			*(point1) = file_buffer[source_char];
			*(point2) = file_buffer[source_char];
		}
	}
}
