/*************************************************************************
 * FORMWIND - A simple program to demonstrate handling of dialogs residing
 *            in windows. Written by Nils Ekholm. These sources are
 *            Public Domain.
 *************************************************************************/


#include <osbind.h>
#include <gemfast.h>
#include "formwind.h"

#ifndef NULL
   #define NULL 0L
#endif

#ifndef TRUE
   #define TRUE      1
   #define FALSE  0
#endif

#define WI_KIND      (MOVER|NAME)
#define NO_WINDOW -1
#define AP_MESAG  50 /* application generated message */

/*-------------------------------------------------------------------------
 * Global vars
 *-----------------------------------------------------------------------*/

int   wi_handle;                 /* Window handle */
char  wi_title[] = " FormWind "; /* Window title */
GRECT form_rect;                 /* Rectangle for object tree */

/*-------------------------------------------------------------------------
 * RSC-related data...
 *-----------------------------------------------------------------------*/

#define RSRCNAME "formwind.rsc"

OBJECT  *menu_tree;
OBJECT  *form_tree;

/*-------------------------------------------------------------------------
 * Program messages
 *-----------------------------------------------------------------------*/

static char rsc_load_error[] =
   " FormWind: Fatal!\n"
   "\n"
   "\x7F" "Can't load resource file.\n"
   ;


/*-------------------------------------------------------------------------
 * prg_exit - Free GEM resources and terminate program.
 *-----------------------------------------------------------------------*/

void prg_exit()
{
    rsrc_free();
    appl_exit();
    Pterm(0);
}

/*-------------------------------------------------------------------------
 * prg_init - Init GEM resources.
 *-----------------------------------------------------------------------*/

void prg_init()
{
    appl_init();
    
    graf_mouse(ARROW, NULL);

    if (!rsrc_load(RSRCNAME)) {
      frm_qchoice(" Exit ", rsc_load_error);
        prg_exit();
    }
    
       /* get tree-addresses*/
    rsc_gtrees(MAIN, &menu_tree,
               FORM, &form_tree,
               -1);
               
       /* transform buttons to Windows3-style */
    rsc_cubuttons(form_tree);

         /* get rectangle sizes for our (dialog-)object trees */
    form_center(form_tree, &form_rect.g_x, &form_rect.g_y, 
                              &form_rect.g_w, &form_rect.g_h);

    wi_handle = NO_WINDOW;
}

/*-------------------------------------------------------------------------
 * open_window - Create and open specified window and set its title or
 *               bring it to top if it's already open.
 *-----------------------------------------------------------------------*/
open_window()
{
        GRECT windrect;
        
        if (wi_handle == NO_WINDOW) {
        
                wind_calc(WC_BORDER, WI_KIND, form_rect, 
                           &windrect.g_x, &windrect.g_y,
                           &windrect.g_w, &windrect.g_h);
                           
                wi_handle = wind_create(WI_KIND, windrect);
                
                wind_set(wi_handle, WF_NAME, wi_title, 0L);
                
                wind_open(wi_handle, windrect);
        } 
        else {
                wind_set(wi_handle, WF_TOP, 0L, 0L);
        }
}


/*-------------------------------------------------------------------------
 * close_window - Close and delete specified window(if it's open).
 *-----------------------------------------------------------------------*/

close_window()
{
        if (wi_handle != NO_WINDOW) 
        {       
                wind_close(wi_handle);
                wind_delete(wi_handle);
                wi_handle = NO_WINDOW;
        }
}

/*-------------------------------------------------------------------------
 * draw_window - Draw object tree in window.
 *-----------------------------------------------------------------------*/

draw_window(cliprect)
GRECT cliprect;
{     
        objc_draw(form_tree, R_TREE, MAX_DEPTH, cliprect);
}

/*-------------------------------------------------------------------------
 * do_redraw - Process redraw list.
 *-----------------------------------------------------------------------*/

do_redraw(updtrect)
GRECT updtrect;         /* the full area that needs updating */
{
        GRECT listrect; /* one of our visible areas */

        wind_get(wi_handle, WF_FIRSTXYWH,
                  &listrect.g_x, &listrect.g_y, 
                  &listrect.g_w, &listrect.g_h);
                  
        while ( listrect.g_w && listrect.g_h ) {
                if ( rc_intersect(&updtrect, &listrect) ) {
                        draw_window(listrect);
                }
                wind_get(wi_handle, WF_NEXTXYWH, 
                          &listrect.g_x, &listrect.g_y,
                          &listrect.g_w, &listrect.g_h);
        }
}

/*-------------------------------------------------------------------------
 * do_msg - Handle messages sent by both GEM and FormWind.
 *-----------------------------------------------------------------------*/

do_msg(msgbuf)
int      msgbuf[];
{

        wind_update(BEG_UPDATE);

        switch (msgbuf[0]) {


                case WM_REDRAW:
                        if (msgbuf[3] == wi_handle)
                                do_redraw(msgbuf[4], msgbuf[5],
                                          msgbuf[6], msgbuf[7]);
                        break;

                case WM_NEWTOP:
                case WM_TOPPED:
                        if (msgbuf[3] == wi_handle) 
                                wind_set(wi_handle, WF_TOP, 0L, 0L);
                        break;


                case WM_MOVED:
                        if(msgbuf[3] == wi_handle) {
                                wind_set(wi_handle, WF_CURRXYWH, 
                                          msgbuf[4], msgbuf[5],
                                          msgbuf[6], msgbuf[7]);
                                wind_get(wi_handle, WF_WORKXYWH,
                                          &form_rect.g_x, &form_rect.g_y, 
                                          &form_rect.g_w, &form_rect.g_h);
                                form_tree->ob_x = form_rect.g_x;
                                form_tree->ob_y = form_rect.g_y;
                        break;
            
                case AP_MESAG:
                     if(msgbuf[3] == OK)
                        close_window(wi_handle);
                     break;
                     
                        }
                        break;

                } /* END switch (msgbuf[0]) */
                
                wind_update(END_UPDATE);
}

/*-------------------------------------------------------------------------
 * toggle_state - Toggle OB_STATE of spec. object(with optional redraw).
 *-----------------------------------------------------------------------*/

void toggle_state(tree, object, state, redraw)
OBJECT *tree;
int object;
int state;
int redraw;
{
   if(state & tree[object].ob_state)
      obj_stchange(tree, object, ~state, redraw);
   else
      obj_stchange(tree, object, state, redraw);
}

/*-------------------------------------------------------------------------
 * send_msg - Used by do_click.
 *-----------------------------------------------------------------------*/

void send_msg(sel_object)
int sel_object;
{
   short msg[8];
   
   msg[0] = AP_MESAG;
   msg[1] = gl_apid;
   msg[2] = 0;
   msg[3] = sel_object;
   msg[4] = 0; /* dummy messages */
   msg[5] = 0;
   msg[6] = 0;
   msg[7] = 0;
      
      
   appl_write(gl_apid, 16, msg);
}  

/*-------------------------------------------------------------------------
 * watch_box - used by do_click
 *-----------------------------------------------------------------------*/

watch_box(object)
int object;
{
   int cur_object = NO_OBJECT;
   int x, y, buttons, dummy;
   int flag1=TRUE;   /*flags used to avoid blinky redraws */
   int flag2=FALSE;
   
   do {
      graf_mkstate(&x, &y, &buttons, &dummy);
      cur_object = objc_find(form_tree, ROOT, MAX_DEPTH, x, y);

      if(cur_object != object)
         {
          if(flag1)
            {
             toggle_state(form_tree, object, SELECTED, TRUE);
             flag1 = FALSE;
             flag2 = TRUE;
             }
         }
      else
         {
          if(flag2)
            {
             toggle_state(form_tree, object, SELECTED, TRUE);
             flag1 = TRUE;
             flag2 = FALSE;
            }
         }
      } while(buttons);
}

/*-------------------------------------------------------------------------
 * wait_btn - used by select_radio(waits until button is released)
 *-----------------------------------------------------------------------*/
void wait_btn()
{
   int dummy, buttons;
   
   do
      graf_mkstate(&dummy, &dummy, &buttons, &dummy);
   while(buttons);
}

/*-------------------------------------------------------------------------
 * select_radio - used by do_click.
 *-----------------------------------------------------------------------*/

select_radio(sel_object)
int sel_object;
{
      int parent;
      int    child;
      OBJECT *pobj;
      GRECT cliprect;
   
      parent = obj_parent(form_tree, sel_object);

      if(sel_object != obj_rbfind(form_tree, parent, SELECTED))
        /* avoid blinky redraws if user selects the selected radiobutton*/
      {
         obj_rbselect(form_tree, sel_object, SELECTED);
         cliprect = form_rect;

         child = form_tree[parent].ob_head;
         while ( (child != parent) && (child >= ROOT) ) 
            {
               pobj = &form_tree[child];
               objc_draw(form_tree, child, MAX_DEPTH, cliprect);
               child = pobj->ob_next;
            }
      }
      wait_btn();
}
   
/*-------------------------------------------------------------------------
 * do_click - evaluate mouse clicks.
 *-----------------------------------------------------------------------*/

do_click(x,y)
int x;
int y;
{

        int sel_object;
      
         
        wind_update(BEG_UPDATE);
        
        sel_object = objc_find(form_tree, ROOT, MAX_DEPTH, x, y);

        if (sel_object != NO_OBJECT) 
        {
            if(SELECTABLE & form_tree[sel_object].ob_flags)
               {
                if(!(DISABLED & form_tree[sel_object].ob_state))
                  {
                   if(RBUTTON & form_tree[sel_object].ob_flags)
                     {
                        select_radio(sel_object);
                     }
                   else
                     {
                      toggle_state(form_tree, sel_object, SELECTED, TRUE);
                      watch_box(sel_object);
                      if(SELECTED & form_tree[sel_object].ob_state)
                        if(EXIT & form_tree[sel_object].ob_flags)
                          {
                           send_msg(sel_object);
                              /* deselect exit-button */
                           toggle_state(form_tree, sel_object, SELECTED, FALSE);
                          }                      
                     }
                   } 
                }
        }  
             
        wind_update(END_UPDATE);
}


/*-------------------------------------------------------------------------
 * main - Main program loop
 *-----------------------------------------------------------------------*/

main()
{
        int dmy;
        int event;
        int msgbuf[8];
        int exit_req = FALSE;
        int mouse_x;
        int mouse_y;
        
        prg_init();
        
        menu_bar(menu_tree, TRUE);

        do {
                event = evnt_multi(
                         MU_MESAG | MU_BUTTON,
                         1,1,1,               /* mbclicks, mbmask, mbstate*/
                         0,0,0,0,0,           /* Mouse event rectangle 1  */
                         0,0,0,0,0,           /* Mouse event rectangle 2  */
                         msgbuf,              /* Message buffer           */
                         0,0,                 /* timer event, time = 0,0  */
                         &mouse_x, &mouse_y,  /* Mouse x & y at event     */
                         &dmy,                /* Mouse button at event    */
                         &dmy,                /* Keystate at event        */           
                         &dmy,                /* Keypress at event        */
                         &dmy);               /* Mouse click count        */

                if((event & MU_MESAG) && msgbuf[0] == MN_SELECTED)
                  {
                     switch(msgbuf[4])
                        {
                           
                           case MNFORM:
                              open_window();
                              break;
                              
                           case MNQUIT:
                              exit_req = TRUE;
                              break;
                        }
                     menu_tnormal(menu_tree, msgbuf[3], TRUE);
                  }
                  
                
               if(wi_handle != NO_WINDOW)
                  {
                  if (event & MU_MESAG)
                        do_msg(msgbuf);
                
                  if (event & MU_BUTTON) 
                        do_click(mouse_x, mouse_y);
                  }
                
        
        } while(!exit_req); /* END do-while */
        
        close_window();
        prg_exit();
}
