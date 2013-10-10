#include "global.h"
#include "aktion.h"
#include "av.h"
#include "clipbrd.h"
#include "dd.h"
#include "edit.h"
#include "file.h"
#include "find.h"
#include "icon.h"
#include "menu.h"
#include "makro.h"
#include "olga.h"
#include "options.h"
#include "projekt.h"
#include "rsc.h"
#include "se.h"
#include "set.h"
#include "string.h"
#include "text.h"
#include "window.h"
#include "event.h"

bool	abort_prog = FALSE;		/* Falls TRUE -> sofort Ende */

/****** DEFINES **************************************************************/

#ifndef WM_SHADED
#define WM_SHADED			0x5758
#define WM_UNSHADED		0x5759
#endif

#ifndef WM_M_BDROPPED
#define WM_M_BDROPPED	100
#endif

#ifndef DHST_ACK 
#define DHST_ACK			0xDADE
#endif

#ifndef FONT_CHANGED
#define FONT_CHANGED 	0x7A18
#endif

#define MAX_EVENT 		20

/****** TYPES ****************************************************************/

typedef struct
{
	int	which;
	int	msg[8];
	int	m_x;
	int	m_y;
	int	bstate;
	int	kstate;
	int	kreturn;
	int	breturn;
} EVENT;

/****** VARIABLES ************************************************************/

static EVENT	msg_queue[MAX_EVENT];
static int		msg_head = 0,
					msg_tail = 0;
static int		old_mx = 0,
					old_my = 0; 	/* Immer die letzte Mausposition */
static bool		menu_ctrl;

/****** FUNCTIONS ************************************************************/

static void handle_keybd	(int kstate, int kreturn);
static void handle_button	(int m_x, int m_y, int bstate, int kstate, int breturn);

/*****************************************************************************/

static bool is_event(void)
{
	return (msg_head != msg_tail);
}

static bool full_event(void)
{
	int next;

	next = msg_head+1;
	if (next == MAX_EVENT)
		next = 0;
	return(next == msg_tail);
}

static void add_event(EVENT *event)
{
	int next;

	if (event->which == MU_KEYBD && is_event())		/* Tastatur-Repeat? */
	{
		EVENT	*ptr = &msg_queue[msg_tail];

		if (ptr->which == MU_KEYBD && ptr->kreturn == event->kreturn &&
		    ptr->kstate == event->kstate)
			return;
	}

	next = msg_head + 1;
	if (next == MAX_EVENT)
		next = 0;
	if (next == msg_tail)
	{
		inote(1, 0, FATALERR, 10);
		return;
	}
	msg_queue[msg_head] = *event;
	msg_head = next;
}

static bool get_event(EVENT *event)
{
	if (msg_head != msg_tail)
	{
		*event = msg_queue[msg_tail];
		msg_tail++;
		if (msg_tail == MAX_EVENT) 
			msg_tail = 0;
		return TRUE;
	}
	return FALSE;
}

static bool idle(void)
{
	EVENT ev;
	int	events;

	if (full_event())
		return FALSE;

	events = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;
	if (mouse_sleeps())
		events |= MU_M1;
	ev.which = evnt_multi(events,	0x102, 3, 0,
									1, old_mx, old_my, 1, 1,
									0, 0, 0, 0, 0,
									ev.msg, 0L,
									&ev.m_x, &ev.m_y, &ev.bstate, &ev.kstate,
									&ev.kreturn, &ev.breturn);
	old_mx = ev.m_x;
	old_my = ev.m_y;

	if (ev.which != MU_TIMER)
	{
		ev.which &= (~MU_TIMER);
		if (ev.which == MU_M1)
			wake_mouse();
		else
			add_event(&ev);
		return TRUE;
	}
	return FALSE;
}

bool check_for_abbruch(void)
{
	EVENT ev;
	int	events;

	if (full_event())
		events = MU_KEYBD | MU_TIMER;
	else
	{
		events = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;
		if (mouse_sleeps())
			events |= MU_M1;
	}
	ev.which = evnt_multi(events,	0x102, 3, 0,
									1, old_mx, old_my, 1, 1,
									0, 0, 0, 0, 0,
									ev.msg, 0L,
									&ev.m_x, &ev.m_y, &ev.bstate, &ev.kstate,
									&ev.kreturn, &ev.breturn);
	old_mx = ev.m_x;
	old_my = ev.m_y;

	if (ev.which != MU_TIMER)
	{
		ev.which &= (~MU_TIMER);
		if (ev.which == MU_M1)
		{
			wake_mouse();
			return FALSE;
		}
		if (ev.which & MU_KEYBD)					/* andere Tasten schlucken */
			return (ev.kreturn == 0x011B);
		add_event(&ev);
	}
	return FALSE;
}

static void next_action(EVENT *ev)
{
	int	events;

again:
	if (get_event(ev))									/* Event aus der Schlange */
	{
		old_mx = ev->m_x;
		old_my = ev->m_y;
		if (makro_play)
		{
			if (ev->which != MU_KEYBD)
			{
				end_play();
				return;
			}
			else if (ev->kreturn == 0x011B)
			{
				end_play();
				goto again;
			}
		}
		else
			return;
	}
	if (from_makro(&ev->kstate, &ev->kreturn))	/* Event vom Makro */
	{
		ev->which = MU_KEYBD;
		return;
	}
																/* auf Event warten */
	events = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;

	if (mouse_sleeps())
		events |= MU_M1;

	if (winlist_top() == NULL)
		events &= (~MU_TIMER);

	ev->which = evnt_multi(events,	0x102, 3, 0,
									1, old_mx, old_my, 1, 1,
									0, 0, 0, 0, 0,
									ev->msg, TIMER_INTERVALL,
									&ev->m_x, &ev->m_y, &ev->bstate, &ev->kstate,
									&ev->kreturn, &ev->breturn);
	old_mx = ev->m_x;
	old_my = ev->m_y;
}

/*****************************************************************************/
/* Ereignis-Verarbeitung																										 */
/*****************************************************************************/

static void handle_keybd(int kstate, int kreturn)
{
	WINDOWP window;

	/* fÅr PC-Tastaturen wird Shift-Ctrl-8/9 nach KP-(/) gemappt */
	if (emu_klammer && kstate == 6)
	{
		if (kreturn == 0x908)		/* S-C-( */
		{
			kreturn = 0x6308;
			kstate = 4;
		}
		if (kreturn == 0xA09)		/* S-C-) */
		{
			kreturn = 0x6409;
			kstate = 4;
		}
	}

#if 0
	if (debug_level)
	{
		TEXTP	t_ptr;
		
		window = winlist_top();
		if (window != NULL)
			t_ptr = get_text(window->handle);
		
		if (kstate == 4 && kreturn == 0x3B00)				/* ^F1 */
		{
			debug("Debug-Special: Ctrl-F1\n");

			return;
		}
	}
#endif

	to_makro(kstate, kreturn);
	if (!makro_play)
		sleep_mouse();

	window = winlist_top();
	if (window == NULL)
		key_global(kstate, kreturn);
	else
	{
		if (!key_window(window, kstate, kreturn))
			key_global(kstate, kreturn);
	}
}

/*****************************************************************************/
static void handle_button(int m_x, int m_y, int bstate, int kstate, int breturn)
{
	int		wh;
	WINDOWP	window;

	if (!all_iconified)
	{
		wake_mouse();
		wh = wind_find(m_x, m_y);
		window = get_window(wh);
		if (window != NULL)
			click_window(window, m_x, m_y, bstate, kstate, breturn);
	}
}

/*****************************************************************************/
static bool str_to_key(char *str, int *kstate, int *kreturn)
{
	char	c, sign, *s1, *s2;
	bool	erg = FALSE;

	if (str[0] == EOS)
		return FALSE;

	s1 = strrchr(str, '^');
	s2 = strrchr(str, '');
	if (s1 > s2)
		str = s1;
	else
		str = s2;

	if (str != NULL && strlen(str) >= 2) 	/* Sign und Buchstabe */
	{
		sign = *str++; 							/* "Vorzeichen" */
		c	  = *str;								/* Eigentliches Zeichen */
		switch (sign)
		{
			case '^':
				*kstate = K_CTRL;
				*kreturn = c;
				erg = TRUE;
				break;

			case '':
				*kstate = K_ALT;
				*kreturn = c;
				erg = TRUE;
				break;
		}
	}
	return erg;
}

void handle_msg(int *msg)
{
	WINDOWP	window;

	wake_mouse();
	window= get_window(msg[3]);			/* Zugehîriges Fenster */

	switch (msg[0])							/* Art der Nachricht */
	{
		case MN_SELECTED:
			if (makro_rec)						/* Makro wird Tastendruck vorgegaukelt */
			{
				int	kstate, kreturn;
				char	str[50];
				
				get_string(menu, msg[4], str);
				if (str_to_key(str, &kstate, &kreturn))
				{
					kstate |= (kstate & 3);
					to_makro(kstate, kreturn);
				}
			}
			handle_menu(msg[3], msg[4], menu_ctrl);
			menu_ctrl = FALSE;
			break;
		case WM_REDRAW  :
			if (msg[3] == akt_handle)
				redraw_aktion();
			else
				redraw_window (window, (GRECT*)(msg+4));
			break;
		case WM_CLOSED  :
			do_icon(window->handle, DO_DELETE);
			break;
		case WM_FULLED  :
			full_window (window);
			break;
		case WM_ARROWED :
			arrow_window (window, msg[4], 1);
			break;
		case WM_HSLID	 :
			h_slider (window, msg[4]);
			break;
		case WM_VSLID	 :
			v_slider (window, msg[4]);
			break;
		case WM_SIZED	 :
			size_window (window, (GRECT*)(msg+4), TRUE);
			break;
		case WM_MOVED	 :
			move_window (window, (GRECT*)(msg+4));
			break;
		case WM_NEWTOP	 : /* Fenster von qed ist irgendwie nach oben gekommen */
		case WM_ONTOP	 :
			ontop_window(window);
			break;
		case WM_TOPPED  :
			top_window (window);
			break;
		case WM_UNTOPPED: /* qed hat jetzt nicht mehr das Top-Fenster */
			untop_window (window);
			break;
		case WM_BOTTOMED: 	/* AES 4.00 MagiC 3 : Fenster nach hinten */
		case WM_M_BDROPPED :	/* Magic 2 */
			bottom_window (window, msg[0]);
			break;
		case WM_ICONIFY:
			iconify_window(window, (GRECT*)(msg+4));
			break;
		case WM_ALLICONIFY:
			all_iconify(window, (GRECT*)(msg+4));
			break;
		case WM_UNICONIFY:
			if (all_iconified)
				all_uniconify(NULL, (GRECT*)(msg+4));
			else
				uniconify_window(window, (GRECT*)(msg+4));
			break;
		case WM_SHADED :
		case WM_UNSHADED :
			shade_window(window, msg[0]);
			break;

		case AP_TERM:
			if (all_iconified)
				all_uniconify(NULL, NULL);
			quick_close = TRUE;
			if (prepare_quit())
				do_quit();
			break;
		case AP_DRAGDROP :
			if (all_iconified)
				Bconout(2, 7);
			else
				handle_dd(msg);
			break;

		case SC_CHANGED :
			/*
			 * Ignorieren, da wir vor dem Paste sowieso neu laden.
			*/
			break;

		case VA_START :
		case VA_PROTOSTATUS :
		case VA_DRAG_COMPLETE :
		case VA_DRAGACCWIND :
		case AV_SENDKEY :
			handle_av(msg);
			break;

		case SE_INIT:
		case SE_OK:
		case SE_ACK:
		case SE_OPEN:
		case SE_ERROR:
		case SE_ERRFILE:
		case SE_PROJECT:
		case SE_QUIT:
		case SE_TERMINATE:
		case SE_CLOSE :
		case SE_MENU :
			if (all_iconified)
				all_uniconify(NULL, NULL);
		   handle_se(msg);
		   break;

		case OLGA_INIT :
		case OLE_NEW :
		case OLGA_ACK :
		case OLE_EXIT :
			handle_olga(msg);
			break;

		case SH_WDRAW:				/* schickt Freedom stÑndig */
		case DHST_ACK:				/* SMU antwortet */
			/* ignore */
			break;

		case FONT_CHANGED :
			if (msg[4] != 0)
				font_id = msg[4];
			if (msg[5] != 0)
				font_pts = msg[5];
			font_change();	
			break;
			
		default:
			if (debug_level)
			{
				char	str[12];
				int	d, i, id;
	
				if ((appl_xgetinfo(4, &d, &d, &i, &d)) && (i == 1))	/* gibts appl_search? */
				{
					i = appl_search(0, str, &d, &id);
					while (i != 0)
					{
						if (id == msg[1])
							break;
						i = appl_search( 1, str, &d, &id);
					}
				}
				else
				{
					strcpy(str, "");
					id = msg[1];
				}
				debug("Unbekannte Msg %d (0x%X) von %s (%d)\n", msg[0], msg[0], str, id);
			}
			break;
	}
}

/*****************************************************************************/
void main_loop(void)
{
	EVENT	ev;
	bool	menu_chg;
	long	as_timer = 0, t;
	
	/* Message-Handler fÅr Fenster-Dialoge und -Alerts */
	set_mdial_wincb(handle_msg);
	
	update_menu();
	menu_chg = FALSE;
	onblink_edit();
	do
	{
		quick_close = FALSE; 						/* Sichern der Texte ohne Nachfrage */
		next_action (&ev);
/*
		get_realtop();
*/
		if (ev.which == MU_TIMER) 					/* Zeit (nur wenn nichts anderes anliegt) */
		{
			timer_se();
			if (blinking_cursor)
				blink_edit();
			if (clip_on_disk)
				save_clip();

			if (as_text || as_prj)
			{
				/*
				 * Weil der do_all_icon() recht viel Rechenzeit verheizt, und
				 * AutoSave min. 1 min wartet, wird er nur jede Minute aufgerufen.
				*/
				t = Tgettime();
				if ((t - as_timer) >= 32)
				{
					do_all_icon(ALL_TYPES, DO_AUTOSAVE);
					as_timer = t;
				}
			}
		}
		if (ev.which & MU_KEYBD)					/* Taste */
		{
			offblink_edit();
			handle_keybd(ev.kstate, ev.kreturn);
			menu_chg = TRUE;
			onblink_edit();
			while (idle()) 							/*	Auch fÅr Makro-Play-Abbruch */
				;
		}
		if (ev.which & MU_BUTTON)					/* Mausknopf */
		{
			offblink_edit();
			handle_button(ev.m_x, ev.m_y, ev.bstate, ev.kstate, ev.breturn);
			menu_chg = TRUE;
			onblink_edit();
		}
		if (ev.which & MU_MESAG)					/* Meldung */
		{
			if (ev.msg[0] == MN_SELECTED)
				menu_ctrl = (ev.kstate & K_CTRL);
			offblink_edit();
			handle_msg(ev.msg);
			menu_chg = TRUE;
			onblink_edit();
		}
		if (ev.which & MU_M1)						/* Maus bewegt */
			wake_mouse();

		if (menu_chg && !is_event())				/* Wenn Zeit */
		{
			update_menu();								/* Eine Aktion kann MenÅs verÑndern */
			menu_chg = FALSE;
		}
		end_undo_seq();
		if (abort_prog)
		{
			int	msg[] = {0,0,0,0,0,0,0,0};

			msg[0] = AP_TERM;
			msg[1] = gl_apid;
			appl_write(gl_apid, 16, msg);
		}
	} while (! done);
}
