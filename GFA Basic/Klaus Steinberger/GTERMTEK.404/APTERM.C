/*********************************************************************/
/* SAMPLE APPLICATION SKELETON                                       */
/*      started 5/28/85 R.Z.   Copyright ATARI Corp. 1985            */
/*********************************************************************/

/*********************************************************************/
/* INCLUDE FILES                                                     */
/*********************************************************************/

#include "ascii.h"
#include "tek.h"
#include "obdefs.h"
#include "define.h"
#include "gemdefs.h"
#include "osbind.h"
#include "portab.h"
#include "treeaddr.h"
#include "term.h"
#include "termdef.h"
#include "termmode.h"
#include "keytbl.h"

/*********************************************************************/
/* EXTERNALS                                                         */
/*********************************************************************/

extern int      gl_apid;
extern int      tek_state;

/*********************************************************************/
/* GLOBAL VARIABLES                                                  */
/*********************************************************************/

int     gl_hchar;
int     gl_wchar;
int     gl_wbox;
int     gl_hbox;        /* system sizes */
long    gl_menu;

int     phys_handle;    /* physical workstation handle */
int     handle;         /* virtual workstation handle */
int     wi_handle;      /* window handle */
int     top_window;     /* handle of topped window */

int     xwork,ywork,hwork,wwork;        /* desktop and work areas */

int     msgbuff[8];     /* event message buffer */
int  keystate;          /* keyboardstete return bei message handler */
int     keycode;        /* keycode returned by event-keyboard */
int     muflag;         /* flag fuer event_multi bedingungen */
int     mx,my;          /* mouse x and y pos. */
int     old_mx, old_my; /* old mouse positions */
int     m_out= FALSE;   /* whereis the mouse ? */
int     ev_mobutton;    /* mouse button returned */
int     butdown;        /* button state tested for, UP/DOWN */
int     ret;            /* dummy return variable */

int     hidden = FALSE; /* current state of cursor */

int     fulled;         /* current state of window */

int     contrl[12];
int     intin[128];
int     ptsin[128];
int     intout[128];
int     ptsout[128];    /* storage wasted for idiotic bindings */

int work_in[11];        /* Input to GSX parameter array */
int work_out[57];       /* Output from GSX parameter array */
int pxyarray[10];       /* input point array */

struct    t_mode my_setup;    /* storage for setup */

/****************************************************************/
/*              Accessory Init. Until First Event_Multi         */
/****************************************************************/
main()
{
     int  done;

     if ((done = gterm_ini()) != 0) {
          appl_exit(done);
     }
        hidden=FALSE;
        fulled=TRUE;
        butdown=TRUE;
        hide_mouse();
        ini_setup();
        tek_init();

        multi();
}

/****************************************************************/
/* dispatches all accessory tasks                               */
/****************************************************************/
multi()
{
int event;
WORD wdw_hndl;
WORD done;

      muflag = MU_BUTTON | MU_KEYBD | MU_TIMER | MU_M1 | MU_MESAG;
      done = FALSE;
      do {
        event = evnt_multi(muflag,
                        1,1,1,
                        m_out,xwork,ywork,wwork,hwork,
                        0,0,0,0,0,
                        msgbuff,0,0,&mx,&my,&ev_mobutton,&keystate,&keycode,&ret);

        wind_update(TRUE);
        wdw_hndl = msgbuff[3];

        if (event & MU_M1) {
               hndl_mouse();
          }

        if (event & MU_MESAG)
          switch (msgbuff[0]) {

          case MN_SELECTED:
               done = hndl_menu(wdw_hndl, msgbuff[4]);
               break;

          case WM_CLOSED:
               done = TRUE;
               break;
          
          case WM_REDRAW:
            do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
            break;

          case WM_NEWTOP:
          case WM_TOPPED:
            wind_set(wi_handle,WF_TOP,0,0,0,0);
            break;

          case WM_SIZED:
          case WM_MOVED:
            if(msgbuff[6]<MIN_WIDTH)msgbuff[6]=MIN_WIDTH;
            if(msgbuff[7]<MIN_HEIGHT)msgbuff[7]=MIN_HEIGHT;
            wind_set(wi_handle,WF_CURRXYWH,msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
            wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
            fulled=FALSE;
            break;

          case WM_FULLED:
            if(fulled){
                wind_get(wi_handle,WF_PREVXYWH,&xwork,&ywork,&wwork,&hwork);
                wind_set(wi_handle,WF_CURRXYWH,xwork,ywork,wwork,hwork);
                wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);}
            else{
                wind_get(wi_handle,WF_FULLXYWH,&xwork,&ywork,&wwork,&hwork);
                wind_set(wi_handle,WF_CURRXYWH,xwork,ywork,wwork,hwork);
                wind_get(wi_handle,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
            }
            fulled ^= TRUE;
            break;

          } /* switch (msgbuff[0]) */

        if (event & MU_BUTTON) {
               if (tek_state & TEK_GIN){
/*                    if (ev_mobutton & 0x1) {*/
                         Cauxout(' ');
/*                    } else if (ev_mobutton & 0x2) {
                         Cauxout('t');
                    }    */
                    tek_gin(mx,my);
               } else {
                    show_mouse();
               }
       }

          

          if(event & MU_KEYBD){
               keycode = keys(keycode, keystate);
               if (keycode & KEY_N) {
                    if (my_setup.general & M_ONLINE) {
                         Cauxout(keycode & 0xff);
                    }
                    if (!(my_setup.general & M_ONLINE) ||
                         (my_setup.comm & M_LECHO)) {
                         tek_scan(keycode & 0x7f);
                         tek_store(keycode & 0x7f);
                    }
                    if (tek_state & TEK_GIN) {
                         tek_gin(mx,my);
                    }
               } else {
                    keycode = tek_keys(keycode);
                    if (keycode != -1) {
                         if (my_setup.general & M_ONLINE) {
                              Cauxout(keycode & 0xff);
                         }
                         if (!(my_setup.general & M_ONLINE) ||
                              (my_setup.comm & M_LECHO)) {
                              tek_scan(keycode & 0x7f);
                              tek_store(keycode & 0x7f);
                         }
                         if (tek_state & TEK_GIN) {
                              tek_gin(mx,my);
                         }                         
                    }
               }
          }
     if (my_setup.general & M_ONLINE) { /* get characters from the host */
        while (Cauxis()) {              /* only in ONLINE Mode */
          keycode = Cauxin();
          keycode &= 0x7f;
          tek_scan(keycode);
          tek_store(keycode);
          if ((my_setup.general & M_CRLF) && (keycode == CR)) {
               tek_scan(LF);
               tek_store(LF);
          }
        }        
     } 
          if ((tek_state & TEK_GIN) && (my_setup.graphic & M_G_LHAIR)) {
               if (( mx != old_mx) || (my != old_my)) {
                    tek_cross(old_mx, old_my); /* clear the cross */
                    tek_cross(mx,my);
                    old_mx = mx;
                    old_my = my;
               }
          }
        wind_update(FALSE);

      }while(!done);     /* until done */

      wind_close(wi_handle);
      graf_shrinkbox(xwork+wwork/2,ywork+hwork/2,gl_wbox,gl_hbox,xwork,ywork,wwork,hwork);
      wind_delete(wi_handle);
      v_clsvwk(handle);
      appl_exit();

}


ini_setup()
{
     my_setup.general = M_ONLINE;
     my_setup.graphic = M_G_DEL|M_G_CR;
     my_setup.comm = M_CS9600|M_IXON;
     set_comm();
}

