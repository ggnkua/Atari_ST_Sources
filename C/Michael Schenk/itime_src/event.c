/*------------------------------------------------------------------------*/
/* Ereignisbearbeitung																										*/

#include <cflib.h>
#include <stdlib.h>
#include <string.h>

#include "event.h"
#include "internet.h"
#include "main.h"

/*------------------------------------------------------------------------*/
/* EXTERNE VARIABLE																												*/

int intervall;

/*------------------------------------------------------------------------*/
/* EXTPORTIERTE VARIABLE																									*/

/*------------------------------------------------------------------------*/
/* DEFINES																																*/

#define TIMER_INTERVALL	1000L							/* Pollzeit fr Timerevent 			*/

/*------------------------------------------------------------------------*/
/* TYPES																																	*/

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

/*------------------------------------------------------------------------*/
/* FUNKTIONS																															*/

static void action(EVENT *ev);

/*------------------------------------------------------------------------*/
/* LOCALE VARIABLES																												*/

static int old_mx = 0,
					 old_my = 0; 									 /* Immer die letzte Mausposition */
static int done = 0;

/*------------------------------------------------------------------------*/
/* Hauptschleife																													*/

void main_loop(void)
{
	EVENT	ev;
	
	set_mdial_wincb(handle_msg);
	do
	{
		action (&ev);
		if ( ev.which == MU_TIMER )
			online_time();
		if (ev.which & MU_KEYBD)							/* Taste 												*/
		{
			if(!key_wdial(ev.kreturn,ev.kstate))
				;
		}
		if (ev.which & MU_BUTTON)							/* Mausknopf 										*/
		{
			if(!click_wdial(ev.breturn,ev.m_x,ev.m_y,ev.kstate,ev.bstate))
				;
		}
		if (ev.which & MU_MESAG)							/* Meldung 											*/
			handle_msg(ev.msg);
		if (abort_prog)
		{
			int	msg[] = {0,0,0,0,0,0,0,0};

			msg[0] = AP_TERM;
			msg[1] = gl_apid;
			appl_write(gl_apid, 16, msg);
		}
	} while (! done);
}

/*------------------------------------------------------------------------*/
/* Bearbeiten der eingegangenen Message																		*/

void handle_msg(int *msg)
{
	if(message_wdial(msg))									/* unmodale Fensterdialoge			*/
		return;

	switch (msg[0])													/* Art der Nachricht 						*/
	{
		case AP_TERM:
			done=1;
		break;
	}
}

/*------------------------------------------------------------------------*/

void action(EVENT *ev)
{
	int	events;
																/* auf Event warten */
	events = MU_KEYBD | MU_BUTTON | MU_MESAG | MU_TIMER;

	ev->which = evnt_multi(events,	0x102, 3, 0,
									1, old_mx, old_my, 1, 1,
									0, 0, 0, 0, 0,
									ev->msg, intervall,
									&ev->m_x, &ev->m_y, &ev->bstate, &ev->kstate,
									&ev->kreturn, &ev->breturn);

	old_mx = ev->m_x;
	old_my = ev->m_y;
}
