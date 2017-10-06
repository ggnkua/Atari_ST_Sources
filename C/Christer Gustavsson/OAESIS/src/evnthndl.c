/****************************************************************************

 Module
  evnthndl.c
  
 Description
  Event processing routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
  jps (Jan Paul Schmidt <Jan.P.Schmidt@mni.fh-giessen.de>)

 Revision history
 
  960101 cg
   Added standard header.
   Mouse_gain_mctrl() and Mouse_release_mctrl() added.

  960129 cg
   Changed name form mouse.c to evnthndl.c.
   Public routines changed prefix from Mouse_ to Evhd_.
   
  960507 jps
   mouse arrow changement while window movement, sizing and sliding
   realtime slider.

  960623 cg
   Fixed mover grabbing bug; if the mouse was moved during click on
   window mover the window was topped / bottomed instead of dragged.
   
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <basepage.h>
#include <errno.h>
#include <fcntl.h>
#include <ioctl.h>
#include <mintbind.h>
#include <osbind.h>
#include <signal.h>
#include <stdio.h>
#include <unistd.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "evnthndl.h"
#include "gemdefs.h"
#include "global.h"
#include "graf.h"
#include "mintdefs.h"
#include "mesagdef.h"
#include "misc.h"
#include "mousedev.h"
#include "objc.h"
#include "resource.h"
#include "rdwrs.h"
#include "rsrc.h"
#include "types.h"
#include "vdi.h"
#include "wind.h"

#include <sysvars.h>

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define EVHD_APID     (-2)
#define EVHD_WAITTIME 200

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static struct {
	WORD       evid;
	WORD       mouseid;
	REVENTLIST *eventlist;

	WORD       lastervalid;
	EVNTREC    last_evntrec;
	WORD       mousefd;
	ULONG      lasttime;
}evntglbl = {
	-1,
	-1,
	0L,
	0,
	{-1,-1},
	-1,
	0UL
};

static struct {
	RECT   area;
	OBJECT *tree;
	WORD   dropwin;
}menu = {
	{0, 0, 0, 0}
};

static CSEMA mctrl = {
	-1L,
	-1,
	-1,
	0,
	-1
};

static WORD mouse_x;
static WORD mouse_y;
static WORD mouse_button;

static WORD iconify_x = 0;

static LONG mouse_sem;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/


static WORD time_message(EVNTREC *er) {
	ULONG	newtime;
	
  newtime = globals.time;

	if(newtime != evntglbl.lasttime) {
		er->ap_event = APPEVNT_TIMER;
		er->ap_value = newtime - evntglbl.lasttime;
					
		evntglbl.lasttime = newtime;
		
		return 1;
	};
	
	return 0;
}

static LONG	get_evntpacket(EVNTREC *er,WORD maxwait) {
	LONG kb_shift;

	LONG stdinrfds,mrfds;
	LONG rhndl;
  

  if(evntglbl.lastervalid) {
		*er = evntglbl.last_evntrec;
		evntglbl.lastervalid = 0;
		return 1;
	};
	
	stdinrfds = 1L << (LONG)STDIN_FILENO;
	mrfds = 1L << (LONG)evntglbl.mousefd;
	rhndl = stdinrfds | mrfds;

	if(Fselect(maxwait,&rhndl,NULL,0L) == 0) {
		return 0;
	};
	
	if(rhndl & stdinrfds) {
		ULONG c = Fgetchar(STDIN_FILENO,0);
		
		kb_shift = Kbshift(-1);
		
		evntglbl.last_evntrec.ap_event = APPEVNT_KEYBOARD;
		evntglbl.last_evntrec.ap_value = ((c & 0xff) << 16) +
			((c & 0x00ff0000L) << 8) + kb_shift;
	}
	
	if(rhndl & mrfds)  {
 		Fread(evntglbl.mousefd, sizeof(EVNTREC), 
 		       &evntglbl.last_evntrec);
 	};
	
	if(time_message(er)) {
		evntglbl.lastervalid = 1;
	}
	else {
		*er = evntglbl.last_evntrec;
	};	
	
	return 1;
}

static void	update_local_mousevalues(EVNTREC *er) {
  switch((WORD)er->ap_event) {
  case	APPEVNT_BUTTON	:
    mouse_button = ((WORD *)&er->ap_value)[1];
    break;	
    
  case	APPEVNT_MOUSE	:
    mouse_x = ((WORD *)&er->ap_value)[1];
    mouse_y = ((WORD *)&er->ap_value)[0];
    break;
  };
}

static void globalize_mousevalues(void) {
	globals.mouse_x = mouse_x;
	globals.mouse_y = mouse_y;
	globals.mouse_button = mouse_button;
}

static void localize_mousevalues(void) {
	mouse_x = globals.mouse_x;
	mouse_y = globals.mouse_y;
	mouse_button = globals.mouse_button;
}

static void handle_arrow_click(WORD win_id,WORD elem,WORD msg) {
	COMMSG    mesag;
	EVNTREC   er;
	WINSTRUCT *win;
	WORD      owner;
	
	Evhd_gain_mctrl(EVHD_APID,FALSE);

	mesag.type = WM_ARROWED;
	mesag.sid = 0;
	mesag.length = 0;
	mesag.msg0 = win_id;
	mesag.msg1 = msg;

	Rdwrs_operation(WSTARTWRITE);

	win = Wind_find_description(win_id);

	if(elem) {
		win->tree[elem].ob_state |= SELECTED;
		Wind_draw_elements(evntglbl.evid,win,&globals.screen,elem);
	};

	owner = win->owner;

	Rdwrs_operation(WENDWRITE);

	do {
	  if(get_evntpacket(&er,globals.arrowrepeat) == 0) {
			Appl_do_write(owner,16,&mesag);
	  };
	  
	  update_local_mousevalues(&er);
	}while(!((er.ap_event == APPEVNT_BUTTON) &&
		 !(er.ap_value & LEFT_BUTTON)));

	if(elem) {
		Rdwrs_operation(WSTARTWRITE);

		win = Wind_find_description(win_id);

		win->tree[elem].ob_state &= ~SELECTED;

		Wind_draw_elements(evntglbl.evid,win,&globals.screen,elem);

		Rdwrs_operation(WENDWRITE);
	};

	Appl_do_write(owner,16,&mesag);

	Evhd_release_mctrl();
}

static void handle_mover_click(WORD win_id) {
	WORD      timeleft = 100;
  WORD      last_x = mouse_x;
  WORD      last_y = mouse_y;
	WINSTRUCT *win;
	EVNTREC   er;
	COMMSG    mesag;
  
	Rdwrs_operation(WSTARTWRITE);
 
  win = Wind_find_description(win_id);
  
  win->tree[WMOVER].ob_state |= SELECTED;
  
  Wind_draw_elements(evntglbl.evid,win,&globals.screen,WMOVER);
  
  Rdwrs_operation(WENDWRITE);
  
  while(1) {
    if(get_evntpacket(&er,timeleft) == 0) {
    	timeleft = 0;
    	break;
    };
    
    if(er.ap_event == APPEVNT_TIMER) {
    	timeleft -= (WORD)er.ap_value;
    };
    
    if(timeleft < 0) {
    	timeleft = 0;
      break;
    };
    
    update_local_mousevalues(&er);
    
    if((er.ap_event == APPEVNT_BUTTON) &&
    		!(LEFT_BUTTON & er.ap_value)) {
    		break;
    };
  };
  
  if(timeleft) {
    static COMMSG	m;

		Rdwrs_operation(WSTARTREAD);
		
	  win = Wind_find_description(win_id);
  
    if(win->status & WIN_TOPPED) {
      m.type = WM_BOTTOM;
    }
    else {
      m.type = WM_TOPPED;
    };
    
    m.sid = 0;
    m.length = 0;
    m.msg0 = win_id;
    
    Appl_do_write(win->owner,16,&m);

		Rdwrs_operation(WENDREAD);
  }
  else {
  	Graf_do_mouse(evntglbl.evid,FLAT_HAND,NULL);
  	
    if(globals.realmove) {
    	Rdwrs_operation(WSTARTREAD);
    	
      win = Wind_find_description(win_id);

      mesag.type = WM_MOVED;
      mesag.sid = 0;
      mesag.length = 0;
      mesag.msg0 = win_id;
      mesag.msg1 = win->totsize.x;
      mesag.msg2 = win->totsize.y;
      mesag.msg3 = win->totsize.width;
      mesag.msg4 = win->totsize.height;

			Rdwrs_operation(WENDREAD);
      
      do {
        WORD	waittime = EVHD_WAITTIME;
        
        if((last_x != mouse_x) || (last_y != mouse_y)) {
        	WORD tmpy;
        
          mesag.msg1 += mouse_x - last_x;
          mesag.msg2 += mouse_y - last_y;
          
          last_x = mouse_x;
          last_y = mouse_y;
          
          tmpy = mesag.msg2;

          if(mesag.msg2 < (globals.clheight + 3)) {
          	mesag.msg2 = globals.clheight + 3;
          }
          
          Appl_do_write(win->owner,16,&mesag);
          
          mesag.msg2 = tmpy;
        };
        
        while(1) {
          if(get_evntpacket(&er,(WORD)waittime) == 0) {
           	er.ap_event = -1;
            break;
          };
          
          if(er.ap_event == APPEVNT_TIMER) {
            if((waittime -= (WORD)er.ap_value) <= 0) {
              break;
            };
          }
          else {
            update_local_mousevalues(&er);
          };
          
          if((er.ap_event == APPEVNT_BUTTON) &&
             !(er.ap_value & LEFT_BUTTON)) {
            break;
          };
        };
      }while(!((er.ap_event == APPEVNT_BUTTON) &&
               !(er.ap_value & LEFT_BUTTON)));
    }
    else {
    	RECT bound;
			RECT winsize;
			WORD owner;
    	
    	bound.y = globals.clheight + 3;
    	bound.height = 30000;
    	bound.x = -15000;
    	bound.width = 30000;
    	
			Wind_beg_update();

			Rdwrs_operation(WSTARTREAD);

      win = Wind_find_description(win_id);

			winsize = win->totsize;
			owner = win->owner;

			Rdwrs_operation(WENDREAD);

			globals.mouse_button = mouse_button;

			Graf_do_dragbox(evntglbl.evid,evntglbl.mousefd,
					winsize.width,winsize.height,
					winsize.x,winsize.y,
					&bound,
					&mesag.msg1,&mesag.msg2);
				          
		  Vdi_vq_mouse(globals.vid,&mouse_button,&mouse_x,&mouse_y);

      mesag.type = WM_MOVED;
      mesag.sid = 0;
      mesag.length = 0;
      mesag.msg0 = win_id;

      if(mesag.msg2 < (globals.clheight + 3)) {
       	mesag.msg2 = globals.clheight + 3;
      }

      mesag.msg3 = winsize.width;
      mesag.msg4 = winsize.height;
      
      Appl_do_write(owner,MSG_LENGTH,&mesag);
			
      Wind_end_update();
    };
    
   	Graf_do_mouse(evntglbl.evid,M_RESTORE,NULL);
  };
	
	Rdwrs_operation(WSTARTREAD);
  
  win = Wind_find_description(win_id);
  
  win->tree[WMOVER].ob_state &= ~SELECTED;
  Wind_draw_elements(evntglbl.evid,win,&globals.screen,WMOVER);
  
	Rdwrs_operation(WENDREAD);
	
	globalize_mousevalues();
}

static void handle_slider_click(WORD win_id, WORD elem) {
    WORD      last_x = mouse_x,
              last_y = mouse_y,
              new_x = last_x,
              new_y = last_y,
              waittime = EVHD_WAITTIME,
              bg = (elem == WVSLIDER)? WVSB : WHSB,
              dx,
              dy;

    WINSTRUCT *win;
    EVNTREC   er;
    COMMSG    mesag;
    WORD      xyarray[10];
    RECT      elemrect,bgrect;

    WORD *p_mousexy    = (elem == WHSLIDER)? &mouse_x        : &mouse_y,
         *p_lastxy     = (elem == WHSLIDER)? &last_x         : &last_y,
         *p_newxy      = (elem == WHSLIDER)? &new_x          : &new_y,
         *p_dxy        = (elem == WHSLIDER)? &dx             : &dy,
         *p_elemrectwh = (elem == WHSLIDER)? &elemrect.width : &elemrect.height,
         *p_bgrectxy   = (elem == WHSLIDER)? &bgrect.x       : &bgrect.y,
         *p_bgrectwh   = (elem == WHSLIDER)? &bgrect.width   : &bgrect.height;

    Graf_do_mouse(evntglbl.evid,FLAT_HAND, NULL);

    Rdwrs_operation(WSTARTWRITE);

    win = Wind_find_description(win_id);

    win->tree[elem].ob_state |= SELECTED;
    Wind_draw_elements(evntglbl.evid,win,&globals.screen,elem);

    Objc_do_offset(win->tree,elem,(WORD *)&elemrect);
    elemrect.width = win->tree[elem].ob_width;
    elemrect.height = win->tree[elem].ob_height;

    dx = last_x - elemrect.x;
    dy = last_y - elemrect.y;

    Objc_do_offset(win->tree,bg,(WORD *)&bgrect);
    bgrect.width = win->tree[bg].ob_width;
    bgrect.height = win->tree[bg].ob_height;

    Rdwrs_operation(WENDWRITE);

    if(globals.realslide) {
        while(1) {
            get_evntpacket(&er,0);
            update_local_mousevalues(&er);

            if((er.ap_event == APPEVNT_BUTTON) &&
              !(er.ap_value & LEFT_BUTTON)) {
                break;
            }

            if((*p_mousexy - *p_dxy + *p_elemrectwh) > (*p_bgrectxy + *p_bgrectwh)) {
                *p_newxy = *p_bgrectxy + *p_bgrectwh - *p_elemrectwh + *p_dxy;
            }
            else {
                if((*p_mousexy - *p_dxy) < *p_bgrectxy) {
                    *p_newxy = *p_bgrectxy + *p_dxy;
                }
                else {
                    *p_newxy = *p_mousexy;
                }
            }

            if(*p_newxy != *p_lastxy) {
                 mesag.type = (elem == WHSLIDER)? WM_HSLID : WM_VSLID;	      
                 mesag.sid = 0;
                 mesag.length = 0;
                 mesag.msg0 = win_id;
                 mesag.msg1 = (*p_bgrectwh == *p_elemrectwh)? 0 : (WORD)((((LONG)*p_newxy - (LONG)*p_dxy -
                                                                    (LONG)*p_bgrectxy) * (LONG)1000L) / 
                                                                    ((LONG)*p_bgrectwh - (LONG)*p_elemrectwh));
                 Appl_do_write(win->owner,16,&mesag);

                 while(1) {
                     if(get_evntpacket(&er, waittime) == 0) {
                         er.ap_event = -1;
                         break;
                     }

                     if(er.ap_event == APPEVNT_TIMER) {
                         if((waittime -= (WORD)er.ap_value) <= 0) {
                             break;
                         }
                     }
                     else {
                         update_local_mousevalues(&er);
                     }

                     if((er.ap_event == APPEVNT_BUTTON) &&
                       !(er.ap_value & LEFT_BUTTON)) {
                         break;
                     }

                *p_lastxy = *p_newxy;
                }
            }
        }
    }
    else {
        Wind_beg_update();
        Rdwrs_operation(WSTARTREAD);

        win = Wind_find_description(win_id);

        Vdi_vsl_type(evntglbl.evid,3);
        Vdi_vswr_mode(evntglbl.evid,MD_XOR);

        xyarray[0] = elemrect.x;
        xyarray[1] = elemrect.y;
        xyarray[2] = elemrect.x
          + elemrect.width - 1;
        xyarray[3] = xyarray[1];
        xyarray[4] = xyarray[2];
        xyarray[5] = elemrect.y
          + elemrect.height - 1;
        xyarray[6] = xyarray[0];
        xyarray[7] = xyarray[5];
        xyarray[8] = xyarray[0];
        xyarray[9] = xyarray[1];

        Vdi_v_hide_c(evntglbl.evid);
        Vdi_v_pline(evntglbl.evid,5,xyarray);
        Vdi_v_show_c(evntglbl.evid,1);

        while(1) {
            get_evntpacket(&er,0);
            update_local_mousevalues(&er);

            if((er.ap_event == APPEVNT_BUTTON) &&
              !(er.ap_value & LEFT_BUTTON)) {
                break;
            }

            if((*p_mousexy - *p_dxy + *p_elemrectwh) > (*p_bgrectxy + *p_bgrectwh)) {
                *p_newxy = *p_bgrectxy + *p_bgrectwh - *p_elemrectwh + *p_dxy;
            }
            else {
                if((*p_mousexy - *p_dxy) < *p_bgrectxy) {
                    *p_newxy = *p_bgrectxy + *p_dxy;
                }
                else {
                    *p_newxy = *p_mousexy;
                }
            }

            if(*p_newxy != *p_lastxy) {
                Vdi_v_hide_c(evntglbl.evid);
                Vdi_v_pline(evntglbl.evid,5,xyarray);
                Vdi_v_show_c(evntglbl.evid,1);
      
                xyarray[0] += new_x - last_x;
                xyarray[1] += new_y - last_y;
                xyarray[2] += new_x - last_x;
                xyarray[3] = xyarray[1];
                xyarray[4] = xyarray[2];
                xyarray[5] += new_y - last_y;
                xyarray[6] = xyarray[0];
                xyarray[7] = xyarray[5];
                xyarray[8] = xyarray[0];
                xyarray[9] = xyarray[1];

                Vdi_v_hide_c(evntglbl.evid);
                Vdi_v_pline(evntglbl.evid,5,xyarray);
                Vdi_v_show_c(evntglbl.evid,1);

                *p_lastxy = *p_newxy;
            }
        }

        Vdi_v_hide_c(evntglbl.evid);
        Vdi_v_pline(evntglbl.evid,5,xyarray);
        Vdi_v_show_c(evntglbl.evid,1);

        mesag.type = (elem == WHSLIDER)? WM_HSLID : WM_VSLID;      
        mesag.sid = 0;
        mesag.length = 0;
        mesag.msg0 = win_id;
        mesag.msg1 = (*p_bgrectwh == *p_elemrectwh)? 0 : (WORD)((((LONG)*p_newxy - (LONG)*p_dxy -
                                                           (LONG)*p_bgrectxy) * (LONG)1000L) / 
                                                           ((LONG)*p_bgrectwh - (LONG)*p_elemrectwh));
        Appl_do_write(win->owner,16,&mesag);

        Rdwrs_operation(WENDREAD);
        Wind_end_update();
    }

    Rdwrs_operation(WSTARTREAD);
    win = Wind_find_description(win_id);
    win->tree[elem].ob_state &= ~SELECTED;
    Wind_draw_elements(evntglbl.evid,win,&globals.screen,elem);
    Rdwrs_operation(WENDREAD);

    Graf_do_mouse(evntglbl.evid,M_RESTORE, NULL);  
}


static void	handle_button(WORD newbutton) {
  EVNTREC	er;
  WORD	changed = newbutton ^ globals.mouse_button;
  
  localize_mousevalues();
  
  mouse_button = newbutton;
  
  if(mctrl.apid >= 0) {
    EVNTREC	e;
	  	      
    e.ap_event = APPEVNT_BUTTON;
    e.ap_value = mouse_button | (1L << 16);
    Appl_put_event((WORD)mctrl.apid,&e);
  }
  else {
	  if((mouse_button & LEFT_BUTTON & changed)) {
	    WORD      win_id;
    
	    WINSTRUCT	*win;
    
			Rdwrs_operation(WSTARTREAD);
	    
	    win = Wind_on_coord(mouse_x,mouse_y);
			win_id = win->id;
    
    	if(win->status & WIN_DESKTOP) {
      	EVNTREC	e;

      	e.ap_event = APPEVNT_BUTTON;
      	e.ap_value = mouse_button | (1L << 16);
      	Appl_put_event(DESK_OWNER,&e);

				Rdwrs_operation(WENDREAD);
    	}
    	else if((win->status & WIN_DIALOG)
      	|| (win->status & WIN_MENU) ||
       	(((win->status & WIN_UNTOPPABLE) && !(win->status & WIN_ICONIFIED))
				&& (mouse_x >= win->worksize.x)
				&& (mouse_x < win->worksize.x + win->worksize.width)
				&& (mouse_y >= win->worksize.y)
				&& (mouse_y < win->worksize.y + win->worksize.height))) {
      	EVNTREC	e;
      
      	e.ap_event = APPEVNT_BUTTON;
      	e.ap_value = mouse_button | (1L << 16);
      	Appl_put_event(win->owner,&e);

				Rdwrs_operation(WENDREAD);
    	}
    	else {	
      	WORD	obj = Objc_do_find(win->tree,0,9,mouse_x,mouse_y,0);
      	WORD	owner = win->owner;
				COMMSG	mesag;				
      
				Rdwrs_operation(WENDREAD);
      	
      	switch(obj) {		
	      case	WCLOSER	:
					Rdwrs_operation(WSTARTREAD);
		
					win = Wind_find_description(win_id);
					win->tree[WCLOSER].ob_state |= SELECTED;
					Wind_draw_elements(evntglbl.evid,win,&globals.screen,WCLOSER);

					Rdwrs_operation(WENDREAD);
		
					do {
					  get_evntpacket(&er,0);
					  update_local_mousevalues(&er);
					}while(!((er.ap_event == APPEVNT_BUTTON) &&
						 !(er.ap_value & LEFT_BUTTON)));
		
					Rdwrs_operation(WSTARTREAD);
		
					win = Wind_find_description(win_id);
		
					win->tree[WCLOSER].ob_state &= ~SELECTED;
		
					Wind_draw_elements(evntglbl.evid,win,&globals.screen,WCLOSER);
		
					Rdwrs_operation(WENDREAD);
		
					mesag.type = WM_CLOSED;
					mesag.sid = 0;
					mesag.length = 0;
					mesag.msg0 = win_id;
					Appl_do_write(owner,16,&mesag);
		
					break;
		
	      case WSMALLER:
	      	{
	      		WORD skeys;
	      		
						Rdwrs_operation(WSTARTREAD);
			
						win = Wind_find_description(win_id);
						win->tree[WSMALLER].ob_state |= SELECTED;
						Wind_draw_elements(evntglbl.evid,win,&globals.screen,WSMALLER);
	
						Rdwrs_operation(WENDREAD);
			
						do {
						  get_evntpacket(&er,0);
						  update_local_mousevalues(&er);
						}while(!((er.ap_event == APPEVNT_BUTTON) &&
							 !(er.ap_value & LEFT_BUTTON)));
			
						Rdwrs_operation(WSTARTREAD);
			
						win = Wind_find_description(win_id);
			
						win->tree[WSMALLER].ob_state &= ~SELECTED;
			
						Wind_draw_elements(evntglbl.evid,win,&globals.screen,WSMALLER);
			
						Rdwrs_operation(WENDREAD);
	
						Vdi_vq_key_s(evntglbl.evid,&skeys);
						
						if(skeys & K_CTRL) {
							mesag.type = WM_ALLICONIFY;
						}
						else {
							mesag.type = WM_ICONIFY;
						};
						
						mesag.sid = 0;
						mesag.length = 0;
						mesag.msg0 = win_id;
						mesag.msg3 = globals.icon_width;
						mesag.msg4 = globals.icon_height;
						mesag.msg1 = iconify_x;
						mesag.msg2 = globals.screen.height - mesag.msg4;
						
						iconify_x += mesag.msg3;
						if(iconify_x + mesag.msg3 > globals.screen.width) {
							iconify_x = 0;
						};
						
						Appl_do_write(owner,16,&mesag);
					};
					break;
		
	      case WFULLER:
					Rdwrs_operation(WSTARTREAD);
		
					win = Wind_find_description(win_id);
		
					win->tree[WFULLER].ob_state |= SELECTED;
		
					Wind_draw_elements(evntglbl.evid,win,&globals.screen,WFULLER);
		
					Rdwrs_operation(WENDREAD);
		
					do {
					  get_evntpacket(&er,0);
					  update_local_mousevalues(&er);
					}while(!((er.ap_event == APPEVNT_BUTTON) &&
						 !(er.ap_value & LEFT_BUTTON)));
		
					Rdwrs_operation(WSTARTREAD);
		
					win = Wind_find_description(win_id);
		
					win->tree[WFULLER].ob_state &= ~SELECTED;
		
					Wind_draw_elements(evntglbl.evid,win,&globals.screen,WFULLER);

					Rdwrs_operation(WENDREAD);

					mesag.type = WM_FULLED;
					mesag.sid = 0;
					mesag.length = 0;
					mesag.msg0 = win_id;
					Appl_do_write(owner,16,&mesag);
		
					break;
		
	      case	WSIZER	:
					Rdwrs_operation(WSTARTWRITE);

					win = Wind_find_description(win_id);
		
					win->tree[WSIZER].ob_state |= SELECTED;
		
					Wind_draw_elements(evntglbl.evid,win,&globals.screen,WSIZER);
		
					if(globals.realsize) {
						WORD	last_x;
						WORD	last_y;
					  WORD	offsx = mouse_x - win->totsize.x - win->totsize.width;
					  WORD	offsy = mouse_y - win->totsize.y - win->totsize.height;
		  
					  mesag.type = WM_SIZED;
					  mesag.sid = 0;
					  mesag.length = 0;
					  mesag.msg0 = win_id;
					  mesag.msg1 = win->totsize.x;
					  mesag.msg2 = win->totsize.y;

						Rdwrs_operation(WENDWRITE);

						last_x = mouse_x;
						last_y = mouse_y;
		  
				    do {
	    			  LONG	waittime = 200;
	      
				      if((last_x != mouse_x) || (last_y != mouse_y)) {
				        mesag.msg3 = mouse_x - win->totsize.x - offsx;
								mesag.msg4 = mouse_y - win->totsize.y - offsy;
	        
				        last_x = mouse_x;
				        last_y = mouse_y;
	        
				        Appl_do_write(win->owner,16,&mesag);
				      };
	      
				      while(1) {
				        if(get_evntpacket(&er,(WORD)waittime) == 0) {
				        	er.ap_event = -1;
				          break;
				        };
	        
				        if(er.ap_event == APPEVNT_TIMER) {
				          if((waittime -= er.ap_value) <= 0) {
				            break;
				          };
				        }
				        else {
				          update_local_mousevalues(&er);
				        };
	        
				        if((er.ap_event == APPEVNT_BUTTON) &&
				           !(er.ap_value & LEFT_BUTTON)) {
				          break;
				        };
				      };
				    }while(!((er.ap_event == APPEVNT_BUTTON) &&
				             !(er.ap_value & LEFT_BUTTON)));
				 	}
					else {
						globals.mouse_button = mouse_button;

						Graf_do_rubberbox(evntglbl.evid,evntglbl.mousefd,
								win->totsize.x,win->totsize.y,100,100,
								&mesag.msg3,&mesag.msg4);
							          
					  Vdi_vq_mouse(globals.vid,&mouse_button,&mouse_x,&mouse_y);

	          mesag.type = WM_SIZED;
	          mesag.sid = 0;
	          mesag.length = 0;
	          mesag.msg0 = win_id;
	          mesag.msg1 = win->totsize.x;
	          mesag.msg2 = win->totsize.y;
	          mouse_x = mesag.msg3 + win->totsize.x - 1;
	          mouse_y = mesag.msg4 + win->totsize.y - 1;

						Rdwrs_operation(WENDWRITE);

	          Appl_do_write(owner,16,&mesag);
	        };

					Wind_beg_update();
					
					Rdwrs_operation(WSTARTREAD);
	        
	        win = Wind_find_description(win_id);
	        
	        win->tree[WSIZER].ob_state &= ~SELECTED;
	        Wind_draw_elements(evntglbl.evid,win,&globals.screen,WSIZER);

					Rdwrs_operation(WENDREAD);
					
					Wind_end_update();
	        break;

				case WAPP:	        
	      case WMOVER:
	      	handle_mover_click(win_id);
	        break;
	        
	      case WLEFT:
					handle_arrow_click(win_id,WLEFT,WA_LFLINE);
					break;
		
	      case WRIGHT:
					handle_arrow_click(win_id,WRIGHT,WA_RTLINE);
					break;
		
	      case WUP:
					handle_arrow_click(win_id,WUP,WA_UPLINE);
					break;
		
	      case WDOWN:
					handle_arrow_click(win_id,WDOWN,WA_DNLINE);
					break;
		
	      case WHSB:
	      	{
	      		WORD      xy[2];
	      		WINSTRUCT *win;
	      		
						Rdwrs_operation(WSTARTREAD);
						
						win = Wind_find_description(win_id);
						
						if(win) {
			      	Objc_do_offset(win->tree,WHSLIDER,xy);
			      };
		      	
						Rdwrs_operation(WENDREAD);
	
						if(mouse_x > xy[0]) {
							handle_arrow_click(win_id,0,WA_RTPAGE);
						}
						else {
							handle_arrow_click(win_id,0,WA_LFPAGE);
						};
					};
					break;
		
	      case WVSB:
	      	{
	      		WORD      xy[2];
	      		WINSTRUCT *win;
	      		
						Rdwrs_operation(WSTARTREAD);
						
						win = Wind_find_description(win_id);
						
						if(win) {
			      	Objc_do_offset(win->tree,WVSLIDER,xy);
			      };
		      	
						Rdwrs_operation(WENDREAD);
	
						if(mouse_y > xy[1]) {
							handle_arrow_click(win_id,0,WA_DNPAGE);
						}
						else {
							handle_arrow_click(win_id,0,WA_UPPAGE);
						};
					};
					break;
		
	      case WHSLIDER:
	      	handle_slider_click(win_id,WHSLIDER);
	        break;
	        
	      case WVSLIDER:
	      	handle_slider_click(win_id,WVSLIDER);
	        break;
	        
	      default:
	        if(win_id > 0) {
	          COMMSG	m;
	          
	          WINSTRUCT	*win;
	          
						Rdwrs_operation(WSTARTREAD);
	          
	          win = Wind_find_description(win_id);
	          	          
	          if(win) {
	          	if((win->status & WIN_ICONIFIED) &&
	          		(Evnt_waitclicks(evntglbl.mousefd,LEFT_BUTTON,LEFT_BUTTON,1,LEFT_BUTTON) >= 1)) {
		            m.type = WM_UNICONIFY;
		            m.sid = 0;
		            m.length = 0;
		            m.msg0 = win_id;
		            *(RECT *)&m.msg1 = win->origsize;
	
		            Appl_do_write(win->owner,16,&m);

							  Vdi_vq_mouse(globals.vid,&mouse_button,&mouse_x,&mouse_y);
	          	}
	          	else if(win != globals.win_vis->win) {
							  Vdi_vq_mouse(globals.vid,&mouse_button,&mouse_x,&mouse_y);

								if(mouse_button & LEFT_BUTTON) {
					        do {
			  		        get_evntpacket(&er,0);
			      		    update_local_mousevalues(&er);
					        }while(!((er.ap_event == APPEVNT_BUTTON) &&
		    	             !(er.ap_value & LEFT_BUTTON)));
		    	      };
		        
		            m.type = WM_TOPPED;
		            m.sid = 0;
		            m.length = 0;
		            m.msg0 = win_id;
	
		            Appl_do_write(win->owner,16,&m);
		          }
		          else {
				      	er.ap_event = APPEVNT_BUTTON;
				      	er.ap_value = (LONG)mouse_button | (1L << 16);
			  	    	Appl_put_event(win->owner,&er);
							};
						};
						
						Rdwrs_operation(WENDREAD);
	        };
	      };
	    };
	  }
	  else {
	    WINSTRUCT	*win;
	    
			Rdwrs_operation(WSTARTREAD);
	    
	    win = Wind_on_coord(mouse_x,mouse_y);
 
	    if(win->status & WIN_DESKTOP) {
	      EVNTREC	e;
	      
	      e.ap_event = APPEVNT_BUTTON;
	      e.ap_value = mouse_button | (1L << 16);
	      Appl_put_event(DESK_OWNER,&e);
	    }
	    else if(Misc_inside(&win->worksize,mouse_x,mouse_y)) {
	      EVNTREC	e;
	      
	      e.ap_event = APPEVNT_BUTTON;
	      e.ap_value = mouse_button | (1L << 16);
	      Appl_put_event(win->owner,&e);
	    };

	    Rdwrs_operation(WENDREAD);
	  };
	};

  globalize_mousevalues();
}

static void check_rectevents(WORD x,WORD y) {
  REVENTLIST	**rl;
  
  struct {
    EVNTREC       head;
    EVNTREC_MOUSE tail;
  }m;
  
  if(!evntglbl.eventlist) { /* This speeds things up when there is nothing in */
    return;                 /* the list */
  };
    
  Psemaphore(2,mouse_sem,-1);
  
  rl = &evntglbl.eventlist;
  
  while(*rl) {
  	if((mctrl.apid == -1) || (mctrl.apid == (*rl)->event.apid)) {
			WORD    sendflag = 0;
			AP_INFO *ai;

	    if((*rl)->event.flag1 != -1) {
	    	WORD insideflag = Misc_inside(&(*rl)->event.r1,x,y);
	    	
	    	if((insideflag && ((*rl)->event.flag1 == MO_ENTER)) ||
	    		((!insideflag) && ((*rl)->event.flag1 == MO_LEAVE))) {	
					m.head.ap_event = MO_RECT1;
					m.head.ap_value = (*rl)->event.apid;
					m.tail.mx = x;
					m.tail.my = y;
					m.tail.buttons = globals.mouse_button;
					/*m.tail.kstate = TODO <--*/
	
					sendflag = 1;	
		    };
		  }
	    else if((*rl)->event.flag2 != -1) {
	    	WORD insideflag = Misc_inside(&(*rl)->event.r2,x,y);
	    	
	    	if((insideflag && ((*rl)->event.flag2 == MO_ENTER)) ||
	    		((!insideflag) && ((*rl)->event.flag2 == MO_LEAVE))) {
					m.head.ap_event = MO_RECT2;
					m.head.ap_value = (*rl)->event.apid;
					m.tail.mx = x;
					m.tail.my = y;
					m.tail.buttons = globals.mouse_button;
					/*m.tail.kstate = TODO <--*/
	
					sendflag = 1;
		    };
		  };

			if(sendflag) {
				REVENTLIST *tmp = *rl;

				Rdwrs_operation(ASTARTREAD);
				
				ai = Appl_internal_info(tmp->event.apid);
	
				if(ai) {
	  			LONG pnr = Fopen(ai->eventname,O_WRONLY);
	
	  			Fwrite((WORD)pnr,sizeof(EVNTREC) + sizeof(EVNTREC_MOUSE),&m);
	  			Fclose((WORD)pnr);
				}
				else {
	  			DB_printf("%s: Line %d: "
		  			"Couldn't find application description!\r\n",
		  			__FILE__,__LINE__);
				};
				
				Rdwrs_operation(AENDREAD);
	
				/* Make sure that we only send one message =>
	   			remove the entry*/
	
				*rl = (*rl)->next;
				Mfree(tmp);
			};
				    
	    if(!(*rl))
	      break;
	  };	    
    rl = &(*rl)->next;
  };
  
  Psemaphore(3,mouse_sem,-1);
}

static void	getmenuxpos(WORD *x,WORD *width) {
	OBJECT	*t;
	
	WORD start;
	
	*width = 0;

	Rdwrs_operation(ASTARTREAD);
	
	t = Appl_get_menu(TOP_MENU_OWNER);
	
	if(t) {
		start = t[t[0].ob_head].ob_head;
	
		*x = t[0].ob_x + t[t[0].ob_head].ob_x + t[start].ob_x;
		*width = t[t[start].ob_tail].ob_x + t[t[start].ob_tail].ob_width;
	}
	else {
		DB_printf("%s: Line %d: getmenuxpos:\r\n"
									"Couldn't find top menu.\r\n",__FILE__,__LINE__);
	};
	
	Rdwrs_quick(AENDREAD);
}

static WORD	get_matching_menu(OBJECT *t,WORD n) {
	WORD parent,start,i = 0;
	
	/*first we need to know which in order our title is*/
	
	parent = t[t[0].ob_head].ob_head;
	start = t[parent].ob_head;
	
	while(start != n) {
		/* we have failed to find the object! */
		
		if(start == parent)
			return -1;

		start = t[start].ob_next;
		i++;
	};
	
	/* now we shall find the i:th menubox! */
	
	parent = t[t[0].ob_head].ob_next;
	
	start = t[parent].ob_head;
	
	while(i) {
		start = t[start].ob_next;

		if(start == parent)
			return -1;
			
		i--;
	};
	
	return start;
}

static WORD	handle_drop_down(WORD menubox,WORD title) {
	WORD     entry;
	WORD     deskbox = menu.tree[menu.tree[0].ob_tail].ob_head;

	OBJECT   *nmenu;
	
	if((deskbox == menubox) && (mouse_y >= globals.pmenutad[0].ob_y)) {
		nmenu = globals.pmenutad;
		entry = Objc_do_find(nmenu,0,9,mouse_x,mouse_y,0);
	}
	else {
		nmenu = menu.tree;
		entry = Objc_do_find(nmenu, menubox, 9, mouse_x, mouse_y,0);
	};

	if(entry >= 0) {
		RECT entryarea;

		Objc_area_needed(nmenu,entry,&entryarea);

		if(!(nmenu[entry].ob_state & DISABLED) && (entry != 0)) {
			/* select the entry and update it */

			nmenu[entry].ob_state |= SELECTED;

			Objc_do_draw(evntglbl.evid,nmenu,0,9,&entryarea);
		};

		while(TRUE) {
			EVNTREC er;
			
	    get_evntpacket(&er,0);
	
	    switch((WORD)er.ap_event) {		
	    case APPEVNT_KEYBOARD :
	    case APPEVNT_TIMER :
	      break;	
	      
	    case APPEVNT_MOUSE	:
	      mouse_y = (WORD)(er.ap_value >> 16);
	      mouse_x = (WORD)er.ap_value;

	    	if(!Misc_inside(&entryarea,mouse_x,mouse_y)) {
					if(!(nmenu[entry].ob_state & DISABLED)) {
						nmenu[entry].ob_state &= ~SELECTED;
			
						Objc_do_draw(evntglbl.evid,nmenu,0,9,&entryarea);
					};
					
					return 0;
				};
 	    	break;
	    
	    case APPEVNT_BUTTON	:
	    	{
	    		WORD changebut = (WORD)(mouse_button ^ er.ap_value);

			    mouse_button = (WORD)er.ap_value;

		    	if(changebut & LEFT_BUTTON & (!mouse_button)) {
						nmenu[entry].ob_state &= ~SELECTED;
		
						if(nmenu == globals.pmenutad) {
							AP_LIST *mr;
							WORD    walk = entry - PMENU_FIRST;
						
							Rdwrs_operation(ASTARTREAD);
							
							mr = globals.applmenu;
						
							while(walk && mr) {
								mr = mr->mn_next;
								walk--;
							};
							
							if(walk) {
								walk--;
								mr = globals.accmenu;

								while(walk && mr) {
									mr = mr->mn_next;
									walk--;
								};
							};
							
						
							if(mr) {
								COMMSG m;
								m.sid = 0;
								m.length = 0;

								if(mr->ai->type & APP_APPLICATION) {
									m.msg0 = mr->ai->id;
									m.type = MH_TOP;
		
									Rdwrs_operation(AENDREAD);
								
									Appl_do_write(0, 16, &m);
								}
								else { /* Accessory */
									m.msg0 = mr->ai->id;
									m.msg1 = mr->ai->id;
									m.type = AC_OPEN;
									
									Rdwrs_operation(AENDREAD);
									
									Appl_do_write(m.msg0, 16, &m);
								};
							}
							else {
								Rdwrs_operation(AENDREAD);
								
								DB_printf("%s: Line %d: handle_drop_down:\r\n"
									"Couldn't find application to top!\r\n",__FILE__,__LINE__);
							};
						}
						else {
							MENUMSG m;
		
							m.type = MN_SELECTED;
							m.sid = 0;
							m.length = 0;
							m.title = title;
							m.item = entry;
							m.tree = nmenu;
							m.parent = menubox;
		
							Appl_do_write(TOP_MENU_OWNER, 16, &m);
						};
						
						return 1;
					};
				};
	    	break;
	    	
	    default:
	    	DB_printf("%s: Line %d: handle_menu:\r\n"
	    									"Unknown message.\r\n",__FILE__,__LINE__);
			};
		};	
	};
	
	return 0;
}

static WORD	handle_selected_title(void) {
	EVNTREC er;
  WORD    box;
  WORD    title;
 	WORD    deskbox;
  	
  title = Objc_do_find(menu.tree, 0, 9, mouse_x, mouse_y, 0);
  box = get_matching_menu(menu.tree, title);
  
  deskbox = menu.tree[menu.tree[0].ob_tail].ob_head;
	  
  if(box >= 0) {
		RECT area;
		RECT titlearea;
	    
    /* select the title and update it */
	    
    menu.tree[title].ob_state |= SELECTED;

    Objc_area_needed(menu.tree,title,&titlearea);
		Objc_do_draw(evntglbl.evid,menu.tree,0,9,&titlearea);

		Objc_area_needed(menu.tree,box,&area);

		if(box == deskbox) {
			WORD i;
			
	    Objc_do_offset(menu.tree,box,&globals.pmenutad[0].ob_x);
    
	    globals.pmenutad[0].ob_y += (menu.tree[menu.tree[box].ob_head].ob_height << 1);
			globals.pmenutad[0].ob_width = menu.tree[box].ob_width;

			for(i = PMENU_FIRST; i <= PMENU_LAST; i++) {
				globals.pmenutad[i].ob_width = globals.pmenutad[0].ob_width;
			}
		
			area.height = globals.pmenutad[0].ob_height + (globals.pmenutad[1].ob_height << 1) + 2;
		};

		Rdwrs_operation(WSTARTWRITE);
		menu.dropwin = Wind_do_create(0,0,&area,WIN_MENU);
    Wind_do_open(evntglbl.evid,menu.dropwin,&area);
		Rdwrs_operation(WENDWRITE);

		menu.tree[box].ob_flags &= ~HIDETREE;

		if(box == deskbox) {
			RECT clip = area;
			
			clip.height = globals.pmenutad[0].ob_y - area.y;
			Objc_do_draw(evntglbl.evid,menu.tree,box,9,&clip);
			
			clip.y = globals.pmenutad[0].ob_y;
			clip.height = globals.pmenutad[0].ob_height + 1;
			Objc_do_draw(evntglbl.evid,globals.pmenutad,0,9,&clip);
		}
		else {
			Objc_do_draw(evntglbl.evid,menu.tree,box,9,&area);
		};

    /* Start to wait for messages and rect 1 */
    while(TRUE) {
	    get_evntpacket(&er,0);
	
	    switch((WORD)er.ap_event) {		
	    case APPEVNT_BUTTON	:
	    case APPEVNT_KEYBOARD :
	    case APPEVNT_TIMER :
	      break;	
	      
	    case APPEVNT_MOUSE	:
	      mouse_x = (WORD)er.ap_value;
	      mouse_y = (WORD)(er.ap_value >> 16);

				if(!Misc_inside(&titlearea,mouse_x,mouse_y)) {
	      	WORD closebox = 0;
	      	
	      	if((deskbox == box) && (mouse_y >= globals.pmenutad[0].ob_y)) {
	      		if(!Misc_inside((RECT *)&globals.pmenutad[0].ob_x,mouse_x,mouse_y) ||
	      			(Objc_do_find(globals.pmenutad,0,9,mouse_x,mouse_y,0) < 0) ||
	      			handle_drop_down(box,title)) {
	      			closebox = 1;
	      		};
	      	}
	      	else if((Objc_do_find(menu.tree, box, 9, mouse_x, mouse_y,0)
					    < 0) || handle_drop_down(box,title)) {
						closebox = 1;
					};
									    
					if(closebox) {
					  menu.tree[title].ob_state &= ~SELECTED;
						Objc_do_draw(evntglbl.evid,menu.tree,0,9,&titlearea);
					  
					  Rdwrs_operation(WSTARTWRITE);
					  Wind_do_close(evntglbl.evid,menu.dropwin);
					  Wind_do_delete(evntglbl.evid,menu.dropwin);
					  Rdwrs_operation(WENDWRITE);
					  
						menu.tree[box].ob_flags |= HIDETREE;
					  
					  return 0;
					};
				};
	      break;
	    
	    default:
	    	DB_printf("%s: Line %d: handle_menu:\r\n"
	    									"Unknown message.\r\n",__FILE__,__LINE__);
	    };
    };	
  };
  
  return 0;
}

static void handle_menu(void) {
	EVNTREC er;
	
	localize_mousevalues();
	
	Rdwrs_operation(MSTARTREAD);

  menu.tree = Appl_get_menu(TOP_MENU_OWNER);

  getmenuxpos(&menu.area.x,&menu.area.width);

  while(TRUE) {
    get_evntpacket(&er,0);

    switch((WORD)er.ap_event) {		
    case APPEVNT_BUTTON	:
    case APPEVNT_KEYBOARD :
    case APPEVNT_TIMER :
      break;	
      
    case APPEVNT_MOUSE	:
      mouse_x = ((WORD *)&er.ap_value)[1];
      mouse_y = ((WORD *)&er.ap_value)[0];

			if(Misc_inside(&menu.area,mouse_x,mouse_y)) {
				handle_selected_title();
			};
			
			if(mouse_y > menu.area.height) {
				Rdwrs_operation(MENDREAD);
			
			  globalize_mousevalues();
			
				return;
			};
      break;
    
    default:
    	DB_printf("%s: Line %d: handle_menu:\r\n"
    									"Unknown message.\r\n",__FILE__,__LINE__);
    };
  };
}

static WORD evnt_handler(LONG arg) {
  WORD	  work_in[] = {1,7,1,1,1,1,1,1,1,1,2};
  WORD	  work_out[57];
  EVNTREC	er;

	NOT_USED(arg);

	menu.area.height = globals.clheight + 3;

  evntglbl.mousefd = (WORD)Fopen(globals.mousename,0);
  
  if(evntglbl.mousefd < 0) {
  	DB_printf("Couldn't open mouse pipe! Error %d",evntglbl.mousefd);
  };
  
  evntglbl.lasttime = globals.time;

  /* open up a vdi workstation to use in the process */
  
  evntglbl.evid = globals.vid;
  Vdi_v_opnvwk(work_in,&evntglbl.evid,work_out);
  
  while(1) {
    get_evntpacket(&er,0);

    switch((WORD)er.ap_event) {
    case APPEVNT_TIMER:
    	break;
    			
    case APPEVNT_BUTTON	:
      handle_button((WORD)er.ap_value);
      break;	
      
    case APPEVNT_MOUSE	:
      globals.mouse_x = (WORD)(er.ap_value & 0xffff);
      globals.mouse_y = (WORD)(er.ap_value >> 16);

			if(mctrl.apid >= 0) {
	      check_rectevents(globals.mouse_x,globals.mouse_y);

				if(mctrl.mode) {
		    	Appl_put_event((WORD)mctrl.apid,&er);
		    };
  		}
			else {
				if(globals.mouse_y < menu.area.height) {
					handle_menu();
				}
				else {
		      check_rectevents(globals.mouse_x,globals.mouse_y);
		    };
	    };
      break;
      
    case APPEVNT_KEYBOARD :
    	if((((er.ap_value & 0x00ff0000L) >> 16) == 0x09) &&
    		(er.ap_value & K_CTRL) && (er.ap_value & K_ALT)) {
    		AP_LIST *al;
    		WORD    newtop = -1;
    		
    		Rdwrs_operation(ASTARTREAD);
    		
    		al = globals.ap_pri;
    		
    		if(al) {
    			while(al->next) {
    				al = al->next;
    				
    				newtop = al->ai->id;
    			};
    		};
    		
    		Rdwrs_operation(AENDREAD);
    		
    		if(newtop != -1) {
    			COMMSG m;
    			
					m.msg0 = newtop;
					m.type = MH_TOP;
								
					Appl_do_write(0, 16, &m);
    		}
    	}
    	else {
	      Appl_put_event(TOP_APPL,&er);
	    };
      break;
      
    default:
    	DB_printf("%s: Line %d:\r\nUnknown mouse event %ld!",
    		__FILE__,__LINE__,er.ap_event);
    };
  };
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Evhd_init_module                                                         *
 *  Initiate event processing module.                                       *
 ****************************************************************************/
void                   /*                                                   */
Evhd_init_module(void) /*                                                   */
/****************************************************************************/
{	
  /* Initialize internal mouse variables */
  
  Vdi_vq_mouse(globals.vid,&globals.mouse_button,&globals.mouse_x,&globals.mouse_y);
  
  /* Create and get the mouse event semaphore */
  
  mouse_sem = Rdwrs_create_sem();

	mctrl.id = Rdwrs_create_sem();
	
  evntglbl.mouseid = (WORD)newfork(evnt_handler,0,"EvntHndl");
}

/****************************************************************************
 * Evhd_exit_module                                                         *
 *  Shutdown event processing module.                                       *
 ****************************************************************************/
void                   /*                                                   */
Evhd_exit_module(void) /*                                                   */
/****************************************************************************/
{
	Rdwrs_operation(MSTARTWRITE);

  (void)Pkill(evntglbl.mouseid,SIGKILL);

	Rdwrs_operation(MENDWRITE);

	Rdwrs_destroy_sem(mouse_sem);
	Rdwrs_destroy_sem(mctrl.id);
}

/****************************************************************************
 * Evhd_make_rectevent                                                      *
 *  Start reporting of mouse events.                                        *
 ****************************************************************************/
void                   /*                                                   */
Evhd_make_rectevent(   /*                                                   */
RECTEVENT *re)         /* Description of events that should be reported.    */
/****************************************************************************/
{
  REVENTLIST *rl = (REVENTLIST *)Mxalloc(sizeof(REVENTLIST),GLOBALMEM);
  
  Psemaphore(2,mouse_sem,-1);
  
  rl->event = *re;
  rl->next = evntglbl.eventlist;
  evntglbl.eventlist = rl;
  
  Psemaphore(3,mouse_sem,-1);
  
  check_rectevents(globals.mouse_x,globals.mouse_y);
}

/****************************************************************************
 * Evhd_kill_rectevent                                                      *
 *  End reporting of mouse events.                                          *
 ****************************************************************************/
void                   /*                                                   */
Evhd_kill_rectevent(   /*                                                   */
WORD apid)             /* Application id to end reporting to.               */
/****************************************************************************/
{
  REVENTLIST	**rl;
  
  Psemaphore(2,mouse_sem,-1);
  
  rl = &evntglbl.eventlist;
  
  while(*rl) {
    if((*rl)->event.apid == apid) {
      REVENTLIST	*tmp = *rl;
      
      *rl = tmp->next;
      
      Mfree(tmp);
      break;
    };
    
    rl = &(*rl)->next;
  };
  
  Psemaphore(3,mouse_sem,-1);
}

/****************************************************************************
 * Evhd_gain_mctrl                                                          *
 *  Gain exclusive right to mouse events.                                   *
 ****************************************************************************/
WORD              /*                                                        */
Evhd_gain_mctrl(  /*                                                        */
WORD apid,        /* Application to gain exclusive right.                   */
WORD send_coord)  /* 1 => movement packets will be sent, 0 => no movement.  */
/****************************************************************************/
{
	WORD r;

	if((mctrl.count > 0) && (mctrl.pid != Pgetpid())) {
		return 0;
	};
	
	r = Rdwrs_get_sem(&mctrl);

	if(r) {
		mctrl.apid = apid;
		mctrl.mode = send_coord;
	};

	return r;
}

/****************************************************************************
 * Evhd_release_mctrl                                                       *
 *  Release right to mouse events.                                          *
 ****************************************************************************/
WORD                      /*                                                */
Evhd_release_mctrl(void)  /*                                                */
/****************************************************************************/
{
	mctrl.apid = -1;
	
	return Rdwrs_rel_sem(&mctrl);
}

/****************************************************************************
 * Evhd_click_owner                                                         *
 *  Find out which application that "owns" mouse clicks.                    *
 ****************************************************************************/
WORD                    /*                                                  */
Evhd_click_owner(void)  /*                                                  */
/****************************************************************************/
{
	WINSTRUCT *win;
	WORD      ret = 0;
	
	if(mctrl.count > 0) {
		ret = mctrl.apid;
	}
	else {
		Rdwrs_operation(WSTARTREAD);
		win = Wind_on_coord(globals.mouse_x,globals.mouse_y);
	
		if(win) {
			if(win->status & WIN_DESKTOP) {
				AP_INFO *ai;
				
				Rdwrs_operation(ASTARTREAD);
				
				ai = Appl_internal_info(DESK_OWNER);
				
				if(ai) {
					ret = ai->id;
				};
					
				Rdwrs_operation(AENDREAD);
			}
			else {
				ret = win->owner;
			};
		};

		Rdwrs_operation(WENDREAD);
	};
	
	return ret;
}
