#include "global.h"
#include "aktion.h"
#include "rsc.h"

extern handle_msg(int *msg);	/* -> event.c */

int	akt_handle;

static long		max_value;
static int		interupt;
static OBJECT	*aktion = NULL;

static void redraw(int start, int depth, int x, int y, int w, int h)
{
	GRECT		r, r1;
	
	r.g_x = x; r.g_y = y; r.g_w = w; r.g_h = h;
	wind_update(BEG_UPDATE);
	hide_mouse_if_needed(&r);
	wind_get_grect(akt_handle, WF_FIRSTXYWH, &r1);
	while (r1.g_w != 0 && r1.g_h != 0)
	{
		if (rc_intersect(&r, &r1))
			objc_draw(aktion, start, depth, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
		wind_get_grect(akt_handle, WF_NEXTXYWH, &r1);
	}
	show_mouse();
	wind_update(END_UPDATE);
}

static void move(int x, int y)
{
	GRECT	r;

	wind_get_grect(akt_handle, WF_CURRXYWH, &r);
	r.g_x = x;
	r.g_y = y;
	wind_set_grect(akt_handle, WF_CURRXYWH, &r);
	wind_get_grect(akt_handle, WF_WORKXYWH, &r);
	aktion[0].ob_x = r.g_x;
	aktion[0].ob_y = r.g_y;
}



void start_aktion(char *str, bool inter, long max)
{
	int	d;
	GRECT	r1, r2;

	if (aktion == NULL)
	{
		rsrc_gaddr(R_TREE, AKTION,	&aktion);
		fix_dial(aktion);
	}
		
	max_value = max(max, 1);
	set_string(aktion, ATEXT, str);
	aktion[ABOX2].ob_width = 1;
	set_flag(aktion, AESC, HIDETREE, !inter);
	interupt = inter;

	/* Zentrieren, nur beim ersten Mal */
	if (aktion[0].ob_x == 0 && aktion[0].ob_y == 0)
		form_center(aktion, &d, &d, &d, &d);	
	
	r1.g_x = aktion[0].ob_x;
	r1.g_y = aktion[0].ob_y;
	r1.g_w = aktion[0].ob_width;
	r1.g_h = aktion[0].ob_height;
	wind_calc_grect(WC_BORDER, (NAME|MOVER|BACKDROP), &r1, &r2);
	akt_handle = wind_create_grect((NAME|MOVER|BACKDROP), &r1);
	if (akt_handle > 0)
	{
		/* Men abschalten */
		disable_menu();
		wind_set_str(akt_handle, WF_NAME, " qed ");
		wind_open_grect(akt_handle, &r2);
	}
}

bool do_aktion(char *str, long value)
{
	int	msg[8], kreturn, d, event;
	long 	max_len, help;
	GRECT	r;
	bool	ret = TRUE;
	
	/* zun„chst Box updaten */
	if (str[0] != EOS)
	{
		set_string(aktion, ATEXT, str);
		get_objframe(aktion, ATEXT, &r);
		redraw(ROOT, MAX_DEPTH, r.g_x, r.g_y, r.g_w, r.g_h);
	}
	
	max_len = aktion[ABOX1].ob_width;
	help = max((max_len * value) / max_value,1);
	help = min(max_len, help);
	if (aktion[ABOX2].ob_width != help)
	{
		aktion[ABOX2].ob_width = (int) help;
		get_objframe(aktion, ABOX2, &r);
		redraw(ABOX2, 0, r.g_x, r.g_y, r.g_w, r.g_h);
	}

	/* nachschauen, ob es irgendwelche GEM-Events gibt */
	do
	{
		event = evnt_multi(MU_MESAG|MU_KEYBD|MU_TIMER, 1, 1, 1, 
								0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
								msg, 1, &d, &d, &d, &d, &kreturn, &d);
		if (event & MU_MESAG)
		{
			switch (msg[0])
			{
				case WM_REDRAW :
					if (msg[3] == akt_handle)
						redraw(ROOT, MAX_DEPTH, msg[4], msg[5], msg[6], msg[7]);
					else
						handle_msg(msg);
					break;
					
				case WM_MOVED :
					if (msg[3] == akt_handle)
						move(msg[4], msg[5]);
					else
						handle_msg(msg);
					break;
	
				case WM_TOPPED :
				case WM_NEWTOP :
				case WM_ONTOP :		
					wind_set(akt_handle, WF_TOP, 0, 0, 0, 0);
					break;
	
				case WM_SIZED:
				case WM_BOTTOMED:
					/* ignore */
					break;
	
				case AP_TERM :
					ret = FALSE;
					break;
			}
		}
		if (event & MU_KEYBD)
		{
			if (interupt && kreturn == 0x011B)		/* ESC */
				ret = FALSE;
		}
	}
	while (event & MU_MESAG);	/* alle Messages auswerten */
	return ret;
}

void end_aktion (void)
{
	if (akt_handle > 0)
	{
		int	msg[8], d, event = 0;

		wind_close(akt_handle);
		wind_delete(akt_handle);
		akt_handle = -1;

		/*
		 * Alle auflaufenden Redraw-Messages abarbeiten, damit
		 * alle Fenster sauber sind, wenn der Dialog beendet ist.
		*/
		while (event != MU_TIMER)
		{
			event = evnt_multi(MU_MESAG|MU_TIMER, 1, 1, 1, 
									0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
									msg, 1, &d, &d, &d, &d, &d, &d);
			if ((event & MU_MESAG) && (msg[0] == WM_REDRAW))
				handle_msg(msg);
		}

		/* Men wieder an */
		enable_menu();
	}
}

void redraw_aktion(void)
{
	if (akt_handle > 0)
	{
		GRECT	r;
		
		get_objframe(aktion, 0, &r);
		redraw(ROOT, MAX_DEPTH, r.g_x, r.g_y, r.g_w, r.g_h);
	}
}
