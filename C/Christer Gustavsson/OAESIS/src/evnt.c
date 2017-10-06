/****************************************************************************

 Module
  evnt.c
  
 Description
  Event handling routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  960127 cg
   Standard header added.

  960322 cg
	 Fixed "0x100" mode of evnt_multi().
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <assert.h>
#include <basepage.h>
#include <fcntl.h>
#include <mintbind.h>
#include <osbind.h>
#include <signal.h>
#include <stdio.h>
#include <support.h>
#include <unistd.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "evnthndl.h"
#include "gemdefs.h"
#include "global.h"
#include "lxgemdos.h"
#include "mintdefs.h"
#include "mesagdef.h"
#include "objc.h"
#include "resource.h"
#include "types.h"
#include "wind.h"

#include <sysvars.h>

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static WORD	clicktime = 200;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

static LONG waitforinput(LONG timeout,LONG *rhnd) {
	LONG l = timeout >> 15;
	LONG t = timeout & 0x7fffL;
	LONG fs;
	LONG rlhnd;
	
	while(l) {
		rlhnd = *rhnd;
	
		fs = Fselect(0x7fff,&rlhnd,NULL,0L);
		
		if(fs) {
			*rhnd = rlhnd;
			return fs;
		};
		
		l--;
	};
	
	rlhnd = *rhnd;
	
	fs = Fselect((WORD)t,&rlhnd,NULL,0L);
	*rhnd = rlhnd;
	return fs;
}

LONG eventselect(WORD events,LONG time,LONG *fhl) {
	if(events & MU_TIMER) {
		if(time <= 0) {
			return Fselect(1,fhl,0L,0L);
		}
		else {	
			return waitforinput(time,fhl);
		};
	}
	else {
		return Fselect(0,fhl,0L,0L);
	};			
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Evnt_waitclicks                                                          *
 *  Wait for mouse button clicks.                                           *
 ****************************************************************************/
WORD             /* Number of clicks that were counted.                     */
Evnt_waitclicks( /*                                                         */
WORD eventpipe,  /* Event message pipe.                                     */
WORD bstate,     /* Button state to wait for.                               */
WORD bmask,      /* Button mask.                                            */
WORD clicks,     /* Maximum number of clicks.                               */
WORD laststate)  /* Previous mouse button state.                            */
/****************************************************************************/
{
	WORD    clickcount = 0;
	EVNTREC er;
	WORD    extrawait = 1;
	
	while(clicks) {
		LONG fhl = (1L << eventpipe);
		
		if((extrawait = Fselect(clicktime,&fhl,0L,0L)) > 0) {
			Fread(eventpipe,sizeof(EVNTREC),&er);
			
			if(er.ap_event == APPEVNT_BUTTON) {
				if(((er.ap_value ^ laststate) & bmask) &&
						((bmask & er.ap_value) == bstate)) {
					clicks--;
					clickcount++;
				};
				
				laststate = (WORD)er.ap_value;
			};
		}
		else {
			break;
		};
	};
	
	if((clicks == 0) || extrawait) {
		(void)Fselect(clicktime,0L,0L,0L);
	};
	
	return clickcount;
}


/*0x0014 evnt_keybd*/

void	Evnt_keybd(AES_PB *apb) {
	EVNTREC	e;

	while(TRUE) {
		Fread(apb->global->int_info->eventpipe,sizeof(EVNTREC),&e);
	
		if(e.ap_event == APPEVNT_KEYBOARD) {
			apb->int_out[0] = (WORD)(e.ap_value >> 16);
			break;
		};
	};
}

/*0x0015 evnt_button*/

/****************************************************************************
 * Evnt_do_button                                                           *
 *  Implementation of evnt_button.                                          *
 ****************************************************************************/
WORD            /* Number of mouse clicks.                                  */
Evnt_do_button( /*                                                          */
WORD apid,      /* Application id.                                          */
WORD eventpipe, /* Event message pipe.                                      */
WORD clicks,    /* Mouse clicks to wait for.                                */
WORD mask,      /* Mouse buttons to wait for.                               */
WORD state,     /* Button state to wait for.                                */
WORD *mx,       /* X position of mouse pointer.                             */
WORD *my,       /* Y position of mouse pointer.                             */
WORD *button,   /* Mouse button state.                                      */
WORD *kstate)   /* Shift key state.                                         */
/****************************************************************************/
{
	EVENTIN	ei;

	EVENTOUT	eo;

	COMMSG	buf;

	ei.events = MU_BUTTON;
	ei.bclicks = clicks;
	ei.bmask   = mask;
	ei.bstate  = state;

	Evnt_do_multi(apid,eventpipe,-1,&ei,&buf,&eo,0);
	
	*mx = eo.mx;
	*my = eo.my;
	*button = eo.mb;
	*kstate = eo.ks;
	
	return eo.mc;
}

void	Evnt_button(AES_PB *apb) {
	apb->int_out[0] = Evnt_do_button(apb->global->apid,
			apb->global->int_info->eventpipe,
			apb->int_in[0],apb->int_in[1],apb->int_in[2]
			,&apb->int_out[1],&apb->int_out[2],&apb->int_out[3]
			,&apb->int_out[4]);
}

/*0x0016 evnt_mouse*/
void	Evnt_mouse(AES_PB *apb) {
	DB_printf("evnt_mouse not implemented yet");
	
	apb->int_out[0] = 1;
}

/*0x0017 evnt_mesag*/

void	Evnt_mesag(AES_PB *apb) {
	COMMSG    e;
	WORD      i;
	WINSTRUCT *win;

	Fread(apb->global->int_info->msgpipe,MSG_LENGTH,&e);

	for(i = 0; i < 8; i++) {
		((WORD *)apb->addr_in[0])[i] = ((WORD *)&e)[i];
	};
	
	if((e.type == WM_REDRAW) && (e.sid == -1)) {		
		Rdwrs_operation(WSTARTREAD);

		win = Wind_find_description(((WORD *)apb->addr_in[0])[3]);
	
		((WORD *)apb->addr_in)[4] += win->totsize.x;
		((WORD *)apb->addr_in)[5] += win->totsize.y;

		Rdwrs_operation(WENDREAD);
	};			

	apb->int_out[0] = 1;
}

/*0x0018 evnt_timer*/

void	Evnt_timer(AES_PB *apb) {
	LONG	time = apb->int_in[1];
	
	time <<= 16;
	time += apb->int_in[0];
	time <<= 10;	/*approx * 1000 :-)*/

	usleep(time);
}


/*0x0019 evnt_multi*/

/****************************************************************************
 * Evnt_do_multi                                                            *
 *  Implementation of evnt_multi.                                           *
 ****************************************************************************/
void                 /*                                                     */
Evnt_do_multi(       /*                                                     */
WORD     apid,       /* Application id.                                     */
WORD     eventpipe,  /* Event message pipe.                                 */
WORD     msgpipe,    /* AES message pipe.                                   */
EVENTIN  *ei,        /* Input parameters.                                   */
COMMSG   *buf,       /* Message buffer.                                     */
EVENTOUT *eo,        /* Output parameters.                                  */
WORD     level)      /* Number of times the function has been called by     */
                     /* itself.                                             */
/****************************************************************************/
{
	ULONG	starttime = globals.time;

	WORD	lastbutton = globals.mouse_button;
	
	LONG	fhevent,fhmsg;

	if(ei->events & MU_MESAG) {
		fhmsg = (1L << msgpipe);
	}
	else {
		fhmsg = 0L;
	};

	if(ei->events & (MU_M1 | MU_M2 | MU_BUTTON | MU_KEYBD)) {
		fhevent = (1L << eventpipe);
	}
	else {
		fhevent = 0L;
	};

	if(ei->events & (MU_M1 | MU_M2)) {
		RECTEVENT	re;
		
		re.apid = apid;
		
		if(ei->events & MU_M1) {
			re.flag1 = ei->m1flag;
			re.r1 = ei->m1r;
		}
		else {
			re.flag1 = -1;
		};
		
		if(ei->events & MU_M2) {
			re.flag2 = ei->m2flag;
			re.r2 = ei->m2r;
		}
		else {
			re.flag2 = -1;
		};

		Evhd_make_rectevent(&re);
	};

	if((level == 0) && (ei->events & MU_BUTTON) && (0x0100 & ei->bclicks) &&
		(ei->bmask & lastbutton) && (apid == Evhd_click_owner())) {
		eo->mx = globals.mouse_x;
		eo->my = globals.mouse_y;
		eo->ks = (WORD)(Kbshift(-1) & 0x1f);
		eo->mb = globals.mouse_button;

		if((ei->bclicks & 0xff) <= 0) {
			eo->mc = 0;
		}
		else {
			eo->mc = 1 + Evnt_waitclicks(eventpipe,ei->bmask & lastbutton,
							ei->bmask & lastbutton,
							ei->bclicks & 0xff,lastbutton);
		};

		eo->events = MU_BUTTON;

	}	
	else if((level == 0) && (ei->events & MU_BUTTON) &&
		((!fhmsg) || (fhmsg && (Finstat(msgpipe) == 0))) &&
		(ei->bstate == (ei->bmask & lastbutton)) &&
		((ei->bmask & lastbutton) || (ei->bclicks <= 1)) &&
		(apid == Evhd_click_owner())) {

		eo->mx = globals.mouse_x;
		eo->my = globals.mouse_y;
		eo->ks = (WORD)(Kbshift(-1) & 0x1f);
		eo->mb = globals.mouse_button;

		if(ei->bclicks <= 0) {
			eo->mc = 0;
		}
		else {
			eo->mc = 1 + Evnt_waitclicks(eventpipe,ei->bstate,ei->bmask,
													ei->bclicks,lastbutton);
		};

		eo->events = MU_BUTTON;
		
	}
	else {	
		while(1) {
			LONG fhl = (fhevent | fhmsg);
			LONG time = (((LONG)ei->hicount) << 16) + (LONG)ei->locount
							 - (LONG)(globals.time - starttime);

			if(eventselect(ei->events,time,&fhl) == 0) {
				eo->events = MU_TIMER;
				
				eo->mx = globals.mouse_x;
				eo->my = globals.mouse_y;
				eo->ks = (WORD)(Kbshift(-1) & 0x1f);
				eo->mb = globals.mouse_button;

				break;
			};
		
			if(fhl & fhevent) {	
				EVNTREC	e;
				
				Fread(eventpipe,sizeof(EVNTREC),&e);

				if(e.ap_event == MO_RECT1) {
					EVNTREC_MOUSE	e2;
						
					Fread(eventpipe,sizeof(EVNTREC_MOUSE),&e2);

					if(ei->events & MU_M1) {						
						eo->events = MU_M1;

						eo->mx = e2.mx;
						eo->my = e2.my;
						eo->mb = e2.buttons;
						eo->ks = e2.kstate;
						break;
					};
				}
				else if(e.ap_event == MO_RECT2) {
					EVNTREC_MOUSE	e2;
						
					Fread(eventpipe,sizeof(EVNTREC_MOUSE),&e2);
					
					if(ei->events & MU_M2) {	
						eo->events = MU_M2;

						eo->mx = e2.mx;
						eo->my = e2.my;
						eo->mb = e2.buttons;
						eo->ks = e2.kstate;
						break;
					};
				}
				else if((e.ap_event == APPEVNT_KEYBOARD) &&
						(e.ap_value & 0xffff0000L) &&
						(ei->events & MU_KEYBD)) {
					eo->events = MU_KEYBD;
					eo->kc = (WORD)(e.ap_value >> 16);
					eo->ks = (WORD)(e.ap_value);
						
					eo->mx = globals.mouse_x;
					eo->my = globals.mouse_y;
					eo->mb = globals.mouse_button;

					break;
				}
				else if((e.ap_event == APPEVNT_BUTTON) &&
								(ei->events & MU_BUTTON)) {
					if((0x0100 & ei->bclicks) && (ei->bmask & e.ap_value)) {
						lastbutton = (WORD)e.ap_value;

						eo->mx = globals.mouse_x;
						eo->my = globals.mouse_y;
						eo->ks = (WORD)(Kbshift(-1) & 0x1f);
						eo->mb = globals.mouse_button;

						if((ei->bclicks & 0xff) >= 1) {
							eo->mc = 1 + Evnt_waitclicks(eventpipe,ei->bmask & lastbutton,
												ei->bmask & lastbutton,
												(ei->bclicks & 0xff) - 1,lastbutton);
						}
						else {
							eo->mc = 1;
						};
						
						eo->events = MU_BUTTON;

						break;
					}
					else if((e.ap_value & ei->bmask) == ei->bstate) {
						lastbutton = (WORD)e.ap_value;
	
						eo->mx = globals.mouse_x;
						eo->my = globals.mouse_y;
						eo->ks = (WORD)(Kbshift(-1) & 0x1f);
						eo->mb = globals.mouse_button;

						if(ei->bclicks >= 1) {
							eo->mc = 1 + Evnt_waitclicks(eventpipe,ei->bstate,ei->bmask,
																	ei->bclicks - 1,lastbutton);
						}
						else {
							eo->mc = 1;
						};

						eo->events = MU_BUTTON;
						
						break;
					};
					
					lastbutton = (WORD)e.ap_value;
				};
			}
			else if(fhl & fhmsg) {
				Fread(msgpipe,sizeof(COMMSG),buf);
	
				eo->events = MU_MESAG;
		
				if((buf->type == WM_REDRAW) && (buf->sid == -1)) {	
					WINSTRUCT	*win;
				
					Rdwrs_operation(WSTARTREAD);
			
					win = Wind_find_description(((WORD *)buf)[3]);
				
					buf->msg1 += win->totsize.x;
					buf->msg2 += win->totsize.y;
	
					Rdwrs_operation(WENDREAD);
				};	
				
				eo->mx = globals.mouse_x;
				eo->my = globals.mouse_y;
				eo->ks = (WORD)(Kbshift(-1) & 0x1f);
				eo->mb = globals.mouse_button;

				break;
			};
		};
	};
	
	if(ei->events & (MU_M1 | MU_M2)) {
		Evhd_kill_rectevent(apid);
	};
}

void Evnt_multi(AES_PB *apb) {
	if(!apb->global->int_info) {
		apb->global->apid = Appl_do_find((BYTE *)(0xffff0000L | Pgetpid()));
		
		if(apb->global->apid == -1) {
			apb->int_out[0] = 0;
			return;
		};
		
		if(!(apb->global->int_info = Appl_internal_info(apb->global->apid))) {
			apb->int_out[0] = 0;
			return;
		};
	};

	Evnt_do_multi(apb->global->apid,
			apb->global->int_info->eventpipe,
			apb->global->int_info->msgpipe,
			(EVENTIN *)apb->int_in,(COMMSG *)apb->addr_in[0],
			(EVENTOUT *)apb->int_out,0);	
}

/*0x001a evnt_dclick*/

void	Evnt_dclick(AES_PB *apb) {
	if(apb->int_in[1] == EDC_SET) {
		clicktime = 320 - 60 * apb->int_in[0];
	};
	
	apb->int_out[0] = (320 - clicktime) / 60;
}
