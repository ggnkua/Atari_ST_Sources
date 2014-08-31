

#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <string.h>
#include <stdio.h>


#define  FALSE            0
#define  TRUE             1
#define  MAX_WIN          32
#define  CLOSER_CLICKED   0x7654

#define  BEGIN            1
#define  END              2

#define  CB_TIMER         -1L
#define  CB_MESSAGE       -2L
#define  CB_MENU          -3L
#define  CB_EVENT         -4L

#define  TE_PTEXT         0
#define  TE_PTMPLT        1
#define  TE_PVALID        2

#define  FOREVER          for (;;)
#define  MIN(a,b)         (((a) < (b)) ? (a) : (b))
#define  MAX(a,b)         (((a) > (b)) ? (a) : (b))
#define  SWAP(a,b)        (zwsp = (a), (a) = (b), (b) = zwsp)

#define  _HZ_200          ((long *) 0x4baL)


typedef struct {
     int     window_handle, tree_index, kind, icnfy_flg;
     int     x_pos, y_pos, width, height;
     OBJECT  *tree;
     char    *full_name, *short_name;
     int     next, edit, ed_char;
     int     cdecl (* object_click) (int object),  cdecl (* key_typed) (int scan);
  } WIN_DESC;


int   initialise_windows (int no, int tree);
int   leave_windows (void);
int   open_rsc_window (int tree, int edit, char name[], char shorter[], int parent);
int   close_rsc_window (int tree, int handle);
void  set_callbacks (int tree, int cdecl click (int obj), int cdecl key (int typed));
int   operate_events (void);
long  read_timer (void);
int   finish (int index, int reason);
int   do_message_event (int msg[]);
void  interupt_editing (int tree, int what, int new_edit);
void  change_rsc_size (int tree, int new_width, int new_height, int parent);
void  change_freestring (int tree, int object, int parent, char text[], int no);
void  change_tedinfo (int tree, int object, int parent, int which, char text[], int no);
void  change_flags (int tree, int object, int chg_flag, int flags, int state);
void  set_slider (int index);
void  do_redraw (int handle, GRECT *rec, int sub_object);
int   rc_intersect (GRECT *src, GRECT *dest);
int   top_rsc_window (int tree);
int   search_tree (int tree);
int   search_window (int handle);
void  pop_up (int tree, int *object, int dialog, int string, int length);
int cdecl  my_button_handler (PARMBLK *parameter);


extern int  gl_apid;

USERBLK   my_user_block = {  my_button_handler,  0  };

WIN_DESC  win_array[MAX_WIN];
OBJECT    *icnfy_tree;
GRECT     desk;
MFDB      screen = { NULL, 0,0,0,0,1,0,0,0 };
MFDB      popup  = { NULL, 0,0,0,0,1,0,0,0 };
long      delay, more_time;
int       cdecl (* timer_thread)(void),  cdecl (* message_thread)(int message[]);
int       cdecl (* menu_thread)(int title, int entry),  cdecl (* event_thread)(void);
int       window_count = 0, vdi_handle, planes;
int       window_kind = NAME | CLOSER | MOVER | BACKDROP;
int       extra_x_kind = SIZER | LFARROW | RTARROW | HSLIDE;
int       extra_y_kind = SIZER | UPARROW | DNARROW | VSLIDE;



int  initialise_windows (num_trees, icnfy_index)

int  num_trees, icnfy_index;

{
   OBJECT  *tree;
   int     count, work_in[11], work_out[57];

   for (count = 0; count < 10; count++)   work_in[count] = 1;
   work_in[10] = 2;

   vdi_handle = graf_handle (&count, &count, &count, &count);
   v_opnvwk (work_in, &vdi_handle, work_out);

   if (vdi_handle == 0) {
        form_alert (1, "[1][ |  Problems opening a virtual  | |  VDI workstation !][ Hm ]");
        return (0);
      }

   vq_extnd (vdi_handle, 1, work_out);
   planes = work_out[4];

   for (count = 0; count < num_trees; count++) {
        rsrc_gaddr (R_TREE, count, &tree);
        while (TRUE) {
             if ((tree->ob_type & 0x7f00) && (tree->ob_state & (CROSSED | CHECKED))) {
                  tree->ob_state &= ~ (CROSSED | CHECKED);
                  tree->ob_type = G_USERDEF;
                  tree->ob_spec.userblk = &my_user_block;
                }
             if (tree->ob_flags & LASTOB)   break;
             tree++;
           }
      }

   for (count = 0; count < MAX_WIN; count++)
        win_array[count].tree_index = win_array[count].window_handle = -1;

   wind_get (0, WF_WORKXYWH, &desk.g_x, &desk.g_y, &desk.g_w, &desk.g_h);

   more_time = delay = -1L;
   timer_thread   = (int cdecl (*) ())         NULL;
   message_thread = (int cdecl (*) (int []))   NULL;
   menu_thread    = (int cdecl (*) (int, int)) NULL;
   event_thread   = (int cdecl (*) ())         NULL;

   if (icnfy_index != -1) {
        rsrc_gaddr (R_TREE, icnfy_index, &icnfy_tree);  window_kind |= ICONFIER;
      }
     else
        icnfy_tree = (OBJECT *) NULL;

   return (1);
 }


int  leave_windows()

{
   int  count;

   for (count = 0; count < MAX_WIN; count++)
        if (win_array[count].tree_index >= 0) {
             wind_close (win_array[count].window_handle);
             wind_delete (win_array[count].window_handle);
           }

   if (vdi_handle)   v_clsvwk (vdi_handle);

   return (1);
 }


int  open_rsc_window (rsc_tree, edit, name, shorter, parent)

int   rsc_tree, edit, parent;
char  name[], shorter[];

{
   WIN_DESC  *window;
   OBJECT    *tree;
   int       count, index, center_x, center_y, kind;
   int       pos_x, pos_y, pos_w, pos_h, all_x, all_y, all_w, all_h;

   if ((index = search_tree (rsc_tree)) >= 0) {
        wind_set (win_array[index].window_handle, WF_TOP, 0, 0, 0, 0);
        return (index);
      }

   if (parent == -1)
        center_x = desk.g_x + desk.g_w / 2,  center_y = desk.g_y + desk.g_h / 2;
     else {
        if ((parent = search_tree (parent)) < 0)
             center_x = desk.g_x + desk.g_w / 2,  center_y = desk.g_y + desk.g_h / 2;
          else {
             wind_get (win_array[parent].window_handle, WF_CURRXYWH,
                             &all_x, &all_y, &all_w, &all_h);
             center_x = all_x + all_w / 2;   center_y = all_y + all_h / 2;
           }
      }

   for (index = 0; index < MAX_WIN; index++)
        if (win_array[index].tree_index == -1)   break;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   form_center (tree, &pos_x, &pos_y, &pos_w, &pos_h);

   for (count = 0, kind = window_kind; count < 2; count++) {
        wind_calc (WC_BORDER, kind,
                   pos_x+1, pos_y+1, pos_w-2, pos_h-2, &all_x, &all_y, &all_w, &all_h);
        if (all_w > desk.g_w)   all_w = desk.g_w,  kind |= extra_x_kind;
        if (all_h > desk.g_h)   all_h = desk.g_h,  kind |= extra_y_kind;
      }

   all_x = center_x - all_w / 2;   all_x = (all_x > desk.g_x) ? all_x : desk.g_x;
   all_y = center_y - all_h / 2;   all_y = (all_y > desk.g_y) ? all_y : desk.g_y;

   if (all_x + all_w > desk.g_x + desk.g_w)   all_x = desk.g_x + desk.g_w - all_w;
   if (all_y + all_h > desk.g_y + desk.g_h)   all_y = desk.g_y + desk.g_h - all_h;

   if (index < MAX_WIN) {
        window = &win_array[index];
        window->window_handle = wind_create (window->kind = kind, 0, 0, all_w, all_h);
        if (window->window_handle < 0)   index = MAX_WIN;
      }
   if (index == MAX_WIN) {
        form_alert (1, "[1][ |   Cannot open a window !   ][ Cancel ]");
        return (-1);
      }

   wind_set (window->window_handle, WF_NAME, name, 0, 0);
   wind_open (window->window_handle, all_x, all_y, all_w, all_h);

   window->x_pos = window->y_pos = 0;
   window->width = pos_w - 2;   window->height = pos_h - 2;
   set_slider (index);

   window->tree_index = rsc_tree;   window->tree = tree;
   window->edit = 0;
   window->next = (tree[edit].ob_flags & EDITABLE) ? edit : 0;
   window->object_click = window->key_typed = NULL;

   window->icnfy_flg = FALSE;
   window->full_name = name;   window->short_name = shorter;
   window_count++;

   return (index);
 }


int  close_rsc_window (rsc_tree, window_handle)

int  rsc_tree, window_handle;

{
   int  pre_index = -1, index = -1;

   if (rsc_tree >= 0)
        pre_index = search_tree (rsc_tree);
   if (window_handle >= 0)
        index = search_window (window_handle);

   if (pre_index == -1) {
        if (index == -1)   return (-1);
      }
     else {
        if (index == -1)   index = pre_index;
          else
             if (index != pre_index)   return (-1);
      }

   wind_close (win_array[index].window_handle);
   wind_delete (win_array[index].window_handle);

   win_array[index].tree_index = -1;
   --window_count;

   return (0);
 }


void  set_callbacks (rsc_tree, object_click, key_typed)

int  rsc_tree;
int  cdecl (* object_click) (int object),  cdecl (* key_typed) (int scan);

{
   int  index;

   if (rsc_tree >= 0) {
        if ((index = search_tree (rsc_tree)) >= 0) {
             if ((long) object_click != -1L)
                  win_array[index].object_click = object_click;
             if ((long) key_typed    != -1L)
                  win_array[index].key_typed    = key_typed;
           }
      }
     else {
        switch (rsc_tree) {
           case CB_TIMER :
             timer_thread   = (int cdecl (*) ()) object_click;
             more_time = delay = (long) key_typed;
             break;
           case CB_MESSAGE :
             message_thread = (int cdecl (*) (int [])) object_click;
             break;
           case CB_MENU :
             menu_thread    = (int cdecl (*) (int, int)) object_click;
             break;
           case CB_EVENT :
             event_thread   = (int cdecl (*) ()) object_click;
             break;
           }
      }
 }


int  operate_events()

{
   WIN_DESC      *win;
   int           index, dummy, kind = MU_KEYBD | MU_BUTTON | MU_MESAG;
   int           event, message[8], m_x, m_y, butt, kbd, scan, num, tmp, flag;
   unsigned int  low, high;
   long          before;

   more_time = delay;

   FOREVER {
        if (window_count == 0)   return (-3);

        win = &win_array[MAX_WIN-1];
        do {
             if (win->tree_index >= 0)
                  if (win->next != 0 && win->next != win->edit) {
                       win->edit = win->next;
                       win->next = 0;
                       objc_edit (win->tree, win->edit, 0, &win->ed_char, ED_INIT);
                     }
           } while (--win >= &win_array[0]);

        if (delay >= 0) {
             low    = (unsigned int) (more_time & 0xffffL);
             high   = (unsigned int) (more_time >> 16);
             before = Supexec (read_timer);
             event  = kind | MU_TIMER;
           }
          else
             event  = kind;

        event = evnt_multi (event, 2,1,1, 0,0,0,0,0, 0,0,0,0,0, message, low, high,
                        &m_x, &m_y, &butt, &kbd, &scan, &num);

        if (delay >= 0)
             more_time -= Supexec (read_timer) - before;

        if (event_thread != NULL) {
             if (event_thread())   return (0);
           }

        wind_get (0, WF_TOP, &index, &dummy, &dummy, &dummy);
        if ((index = search_window (index)) >= 0)   win = &win_array[index];

        if (event & MU_KEYBD) {
             if (form_keybd (win->tree, win->edit, win->next, scan, &win->next, &scan) == 0) {
                  if (win->object_click != NULL) {
                       if (win->object_click (win->next))
                            if (finish (index, 0))   return (-1);
                     }
                    else {
                       win->next = 0;   return (1);
                     }
                  win->next = 0;
                }
             if (scan != 0) {
                  if (win->key_typed != NULL) {
                       tmp = win->key_typed (scan);
                       if (tmp > 0)
                            objc_edit (win->tree, win->edit, scan, &win->ed_char, ED_CHAR);
                       if (tmp < 0)
                            if (finish (index, 0))   return (-1);
                     }
                    else
                       objc_edit (win->tree, win->edit, scan, &win->ed_char, ED_CHAR);
                }
           }

        if (event & MU_MESAG) {
             if (message[0] == MN_SELECTED) {
                  if (menu_thread != NULL)
                       if (menu_thread (message[3], message[4]))   return (0);
                }
               else {
                  if ((flag = do_message_event (message)) < 0)
                       if (flag == -2) {
                            if ((index = search_window (message[3])) >= 0)
                                 if (finish (index, CLOSER_CLICKED))
                                      return (-1);
                          }
                         else {
                            for (index = 0; index < MAX_WIN; index++)
                                 finish (index, CLOSER_CLICKED);
                            return ((flag == -1) ? -4 : -2);
                          }
                }
           }

        if (event & MU_BUTTON) {
             if ((index = search_window (wind_find (m_x, m_y))) >= 0)
                  if (win_array[index].tree_index >= 0) {
                       win = &win_array[index];
                       if (! win->icnfy_flg) {
                            win->next = objc_find (win->tree, ROOT, MAX_DEPTH, m_x, m_y);
                            if (form_button (win->tree, win->next, num, &win->next) == 0) {
                                 if (win->object_click != NULL) {
                                      if (win->object_click (win->next))
                                           if (finish (index, 0))   return (-1);
                                    }
                                 win->next = 0;
                                 if (win->object_click == NULL)   return (1);
                               }
                          }
                     }
           }

        if (event & MU_TIMER && more_time <= 0) {
             more_time = delay;
             if (timer_thread != NULL) {
                  if (timer_thread())   return (0);
                }
               else   return (0);
           }

        win = &win_array[MAX_WIN-1];
        do {
             if (win->tree_index >= 0) {
                  if (win->next != 0 && win->next != win->edit)
                       objc_edit (win->tree, win->edit, 0, &win->ed_char, ED_END);
                }
           } while (--win >= &win_array[0]);
      }
 }


long  read_timer()

{
   return (*_HZ_200 * 5);
 }


int  finish (index, reason)

int  index, reason;

{
   WIN_DESC  *window;

   window = &win_array[index];

   if (window->edit != 0)
        objc_edit (window->tree, window->edit, 0, &window->ed_char, ED_END);

   if (window->object_click != NULL)   window->object_click (reason);

   wind_close (win_array[index].window_handle);
   wind_delete (win_array[index].window_handle);

   win_array[index].tree_index = -1;

   return ((--window_count > 0) ? 0 : 1);
 }


int  do_message_event (mesag)

int  mesag[];

{
   WIN_DESC  *window;
   GRECT     act;
   int       index;

   switch (mesag[0]) {
      case AC_CLOSE :
      case AP_TERM :
      case AP_RESCHG :
        if (message_thread != NULL)   message_thread (mesag);
        return (-1);
      }

   if ((index = search_window (mesag[3])) >= 0) {
        window = &win_array[index];
        wind_get (mesag[3], WF_WORKXYWH, &act.g_x, &act.g_y, &act.g_w, &act.g_h);

        switch (mesag[0]) {
           case WM_REDRAW :
             act.g_x = mesag[4];  act.g_y = mesag[5];  act.g_w = mesag[6];  act.g_h = mesag[7];
             do_redraw (mesag[3], &act, ROOT);
             break;
           case WM_TOPPED :
             wind_set (mesag[3], WF_TOP, 0, 0, 0, 0);
             break;
           case WM_BOTTOMED :
             wind_set (mesag[3], WF_BOTTOM, 0, 0, 0, 0);
             break;
           case WM_MOVED :
             wind_set (mesag[3], WF_CURRXYWH, mesag[4], mesag[5], mesag[6], mesag[7]);
             wind_get (mesag[3], WF_WORKXYWH, &act.g_x, &act.g_y, &act.g_w, &act.g_h);
             window->tree->ob_x = act.g_x - 1;   window->tree->ob_y = act.g_y - 1;
             break;
           case WM_SIZED :
             mesag[6] = MAX (mesag[6], 120);   mesag[7] = MAX (mesag[7], 80);
             wind_calc (WC_WORK, window->kind, mesag[4], mesag[5],
                             mesag[6], mesag[7], &act.g_x, &act.g_y, &act.g_w, &act.g_h);
             act.g_w = (window->kind & HSLIDE) ? MIN(act.g_w,window->width)  :  window->width;
             act.g_h = (window->kind & VSLIDE) ? MIN(act.g_h,window->height) : window->height;
             wind_calc (WC_BORDER, window->kind, act.g_x, act.g_y,
                             act.g_w, act.g_h, &mesag[4], &mesag[5], &mesag[6], &mesag[7]);
             wind_set (mesag[3], WF_CURRXYWH, mesag[4], mesag[5], mesag[6], mesag[7]);
             set_slider (index);
             break;
           case WM_ARROWED :
             switch (mesag[4]) {
                case WA_UPPAGE :   window->y_pos -= act.g_h;        break;
                case WA_DNPAGE :   window->y_pos += act.g_h;        break;
                case WA_UPLINE :   window->y_pos -= act.g_h / 10;   break;
                case WA_DNLINE :   window->y_pos += act.g_h / 10;   break;
                case WA_LFPAGE :   window->x_pos -= act.g_w;        break;
                case WA_RTPAGE :   window->x_pos += act.g_w;        break;
                case WA_LFLINE :   window->x_pos -= act.g_w / 10;   break;
                case WA_RTLINE :   window->x_pos += act.g_w / 10;   break;
                }
             window->x_pos = MAX (0, MIN (window->x_pos, window->width  - act.g_w));
             window->y_pos = MAX (0, MIN (window->y_pos, window->height - act.g_h));
             wind_set (mesag[3], WF_HSLIDE,
                        (int) (window->x_pos * 1000L / (window->width  - act.g_w)), 0, 0, 0);
             wind_set (mesag[3], WF_VSLIDE,
                        (int) (window->y_pos * 1000L / (window->height - act.g_h)), 0, 0, 0);
             do_redraw (mesag[3], &desk, ROOT);
             break;
           case WM_HSLID :
             wind_set (mesag[3], WF_HSLIDE, mesag[4], 0, 0, 0);
             window->x_pos = (int) (((long) mesag[4] * (window->width - act.g_w)) / 1000);
             do_redraw (mesag[3], &desk, ROOT);
             break;
           case WM_VSLID :
             wind_set (mesag[3], WF_VSLIDE, mesag[4], 0, 0, 0);
             window->y_pos = (int) (((long) mesag[4] * (window->height - act.g_h)) / 1000);
             do_redraw (mesag[3], &desk, ROOT);
             break;
           case WM_ICONIFY :
             window->icnfy_flg = TRUE;
             wind_set (mesag[3], WF_ICONIFY, mesag[4], mesag[5], mesag[6], mesag[7]);
             wind_set (mesag[3], WF_NAME, window->short_name, 0, 0);
             break;
           case WM_UNICONIFY :
             window->icnfy_flg = FALSE;
             wind_set (mesag[3], WF_UNICONIFY, mesag[4], mesag[5], mesag[6], mesag[7]);
             wind_set (mesag[3], WF_NAME, window->full_name, 0, 0);
             break;
           case WM_CLOSED :
             return (-2);
           default :
             if (message_thread != NULL) {
                  if (message_thread (mesag) < 0)   return (-3);
                }
           }

        return (0);
      }

   if (message_thread != NULL) {
        if (message_thread (mesag) < 0)   return (-3);
      }

   return (0);
 }


void  interupt_editing (rsc_tree, mode, new_edit)

int  rsc_tree, mode, new_edit;

{
   WIN_DESC  *window;
   int       index;

   if ((index = search_tree (rsc_tree)) < 0)
        return;

   window = &win_array[index];

   if (new_edit >= 0 && mode != BEGIN)   window->edit = new_edit;

   if (window->edit != 0) {
        objc_edit (window->tree, window->edit, 0, &window->ed_char,
                    (mode == BEGIN) ? ED_END : ED_INIT);
      }
   if (mode == BEGIN)   window->edit = 0;
 }


void  change_rsc_size (rsc_tree, new_width, new_height, parent)

int  rsc_tree, new_width, new_height, parent;

{
   WIN_DESC  *window;
   OBJECT    *tree;
   int       pos_x, pos_y, pos_w, pos_h, all_x, all_y, all_w, all_h;
   int       index, tmp_x, tmp_y;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);

   if (new_width  > 0)   tree->ob_width  = new_width;
   if (new_height > 0)   tree->ob_height = new_height;

   if ((index = search_tree (rsc_tree)) < 0)
        return;
   window = &win_array[index];

   tmp_x = tree->ob_x;   tmp_y = tree->ob_y;
   form_center (tree, &pos_x, &pos_y, &pos_w, &pos_h);
   tree->ob_x = tmp_x;   tree->ob_y = tmp_y;
   window->width = pos_w - 2;   window->height = pos_h - 2;

   wind_calc (WC_BORDER, window->kind,
              pos_x+1, pos_y+1, pos_w-2, pos_h-2, &all_x, &all_y, &all_w, &all_h);
   wind_get (window->window_handle, WF_CURRXYWH, &pos_x, &pos_y, &pos_w, &pos_h);

   if (new_width  > 0) {
        if ((window->kind & HSLIDE) == 0 || pos_w > all_w)
             pos_w = all_w;
      }
   if (new_height > 0) {
        if ((window->kind & VSLIDE) == 0 || pos_h > all_h)
             pos_h = all_h;
      }
   wind_set (window->window_handle, WF_CURRXYWH, pos_x, pos_y, pos_w, pos_h);
   set_slider (index);

   if (! window->icnfy_flg)
        if (parent >= 0)
             do_redraw (window->window_handle, &desk, parent);
 }


void  change_freestring (rsc_tree, object, parent, text, number)

int   rsc_tree, object, parent, number;
char  text[];

{
   OBJECT  *tree;
   int     index;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   strncpy (tree[object].ob_spec.free_string, text, number);

   if ((index = search_tree (rsc_tree)) < 0)
        return;

   if (! win_array[index].icnfy_flg)
        if (parent >= 0)
             do_redraw (win_array[index].window_handle, &desk, parent);
 }


void  change_tedinfo (rsc_tree, object, parent, which, text, number)

int   rsc_tree, object, parent, number;
char  text[];

{
   OBJECT   *tree;
   TEDINFO  *ted;
   int      index;
   char     *text_ptr;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   ted = tree[object].ob_spec.tedinfo;

   switch (which) {
      case TE_PTEXT  :  text_ptr = ted->te_ptext;    break;
      case TE_PTMPLT :  text_ptr = ted->te_ptmplt;   break;
      case TE_PVALID :  text_ptr = ted->te_pvalid;   break;
      }
   strncpy (text_ptr, text, number);

   if ((index = search_tree (rsc_tree)) < 0)
        return;

   if (! win_array[index].icnfy_flg)
        if (parent >= 0)
             do_redraw (win_array[index].window_handle, &desk, parent);
 }


void  change_flags (rsc_tree, object, chg_flag, flags, state)

int  rsc_tree, object, chg_flag, flags, state;

{
   OBJECT  *obj_ptr;
   int     index;

   if (object == 0 || object == CLOSER_CLICKED)
        return;

   rsrc_gaddr (R_TREE, rsc_tree, &obj_ptr);
   obj_ptr = &obj_ptr[object];

   if (chg_flag)
        obj_ptr->ob_flags |=  flags,  obj_ptr->ob_state |=  state;
     else
        obj_ptr->ob_flags &= ~flags,  obj_ptr->ob_state &= ~state;

   if ((index = search_tree (rsc_tree)) < 0)
        return;

   if (! win_array[index].icnfy_flg)
        do_redraw (win_array[index].window_handle, &desk, object);
 }


void set_slider (index)

int  index;

{
   WIN_DESC  *window;
   int       wa_x, wa_y, wa_w, wa_h, size, pos, msg[8];

   window = &win_array[index];
   wind_get (window->window_handle, WF_WORKXYWH, &wa_x, &wa_y, &wa_w, &wa_h);

   msg[0] = WM_REDRAW;   msg[1] = gl_apid;   msg[3] = window->window_handle;
   msg[2] = 0;   msg[4] = wa_x;   msg[5] = wa_y;   msg[6] = wa_w;   msg[7] = wa_h;

   if (window->kind & HSLIDE) {
        size = (int) (wa_w * 1000L / window->width);
        wind_set (window->window_handle, WF_HSLSIZE, size, 0, 0, 0);
        pos = (int) (window->x_pos * 1000L / (window->width - wa_w));
        if (pos > 1000) {
             window->x_pos = window->width - wa_w;   pos = 1000;
             appl_write (gl_apid, 16, msg);
           }
        wind_set (window->window_handle, WF_HSLIDE, pos, 0, 0, 0);
      }

   if (window->kind & VSLIDE) {
        size = (int) (wa_h * 1000L / window->height);
        wind_set (window->window_handle, WF_VSLSIZE, size, 0, 0, 0);
        pos = (int) (window->y_pos * 1000L / (window->height - wa_h));
        if (pos > 1000) {
             window->y_pos = window->height - wa_h;   pos = 1000;
             appl_write (gl_apid, 16, msg);
           }
        wind_set (window->window_handle, WF_VSLIDE, pos, 0, 0, 0);
      }
 }


void  do_redraw (handle, rect, sub)

GRECT  *rect;
int    handle, sub;

{
   WIN_DESC  *window;
   OBJECT    *tree;
   GRECT     act;
   int       index, pos_x, pos_y, pos_w, pos_h;

   if ((index = search_window (handle)) < 0)
        return;

   window = &win_array[index];

   tree = (window->icnfy_flg) ? icnfy_tree : window->tree;

   wind_get (handle, WF_WORKXYWH, &pos_x, &pos_y, &pos_w, &pos_h);
   tree->ob_x = pos_x - 1 - window->x_pos;
   tree->ob_y = pos_y - 1 - window->y_pos;

   if (window->icnfy_flg) {
        tree->ob_width = pos_w + 2;   tree->ob_height = pos_h + 2;
        tree[1].ob_x = pos_x + pos_w / 2 - tree[1].ob_width  / 2 - tree->ob_x;
        tree[1].ob_y = pos_y + pos_h / 2 - tree[1].ob_height / 2 - tree->ob_y;
      }

   wind_update (BEG_UPDATE);

   if (window->edit && (! window->icnfy_flg))
        objc_edit (window->tree, window->edit, 0, &window->ed_char, ED_END);

   rc_intersect (&desk, rect);
   wind_get (handle, WF_FIRSTXYWH, &pos_x, &pos_y, &pos_w, &pos_h);
   do {
        act.g_x = pos_x;   act.g_y = pos_y;   act.g_w = pos_w;   act.g_h = pos_h;
        if (rc_intersect (rect, &act))
             objc_draw (tree, sub, MAX_DEPTH, act.g_x, act.g_y, act.g_w, act.g_h);
        wind_get (handle, WF_NEXTXYWH, &pos_x, &pos_y, &pos_w, &pos_h);
     } while (pos_w != 0 || pos_h != 0);

   if (window->edit && (! window->icnfy_flg))
        objc_edit (window->tree, window->edit, 0, &window->ed_char, ED_INIT);

   wind_update (END_UPDATE);
 }


int  rc_intersect (rect_src, rect_dest)

GRECT  *rect_src, *rect_dest;

{
   int  cut_x, cut_y, cut_w, cut_h;

   cut_x = MAX (rect_src->g_x, rect_dest->g_x);
   cut_y = MAX (rect_src->g_y, rect_dest->g_y);
   cut_w = MIN (rect_src->g_x + rect_src->g_w, rect_dest->g_x + rect_dest->g_w);
   cut_h = MIN (rect_src->g_y + rect_src->g_h, rect_dest->g_y + rect_dest->g_h);
   rect_dest->g_x = cut_x;   rect_dest->g_w = cut_w - cut_x;
   rect_dest->g_y = cut_y;   rect_dest->g_h = cut_h - cut_y;

   return ((cut_w > cut_x) && (cut_h > cut_y));
 }


int  top_rsc_window (rsc_tree)

int  rsc_tree;

{
   int  index;

   index = search_tree (rsc_tree);

   if (index >= 0)
        wind_set (win_array[index].window_handle, WF_TOP, 0, 0, 0);

   return ((index >= 0) ? 0 : -1);
 }


int  search_tree (rsc_tree)

int  rsc_tree;

{
   int  count;

   for (count = 0; count < MAX_WIN; count++)
        if (win_array[count].tree_index == rsc_tree)   break;

   return ((count == MAX_WIN) ? -1 : count);
 }


int  search_window (window_handle)

int  window_handle;

{
   int  count;

   for (count = 0; count < MAX_WIN; count++)
        if (win_array[count].tree_index >= 0)
             if (win_array[count].window_handle == window_handle)   break;

   return ((count == MAX_WIN) ? -1 : count);
 }


void  pop_up (popup_ind, object, dial_ind, str_obj, length)

int   popup_ind, *object, dial_ind, str_obj, length;

{
   OBJECT  *pu, *dial, *wrk;
   GRECT   box;
   char    *chr;
   int     button, zwsp, p_x, p_y, t_x, t_y, xy[8], abort_flg = FALSE;
   int     event, state, butt, dummy, kret, bret;

   rsrc_gaddr (R_TREE, popup_ind, &pu);     objc_offset (pu, *object, &t_x, &t_y);
   rsrc_gaddr (R_TREE, dial_ind, &dial);    objc_offset (dial, str_obj, &p_x, &p_y);
   pu->ob_x += p_x - t_x;   pu->ob_y += p_y - t_y;

   pu->ob_x = MIN (desk.g_x + desk.g_w - pu->ob_width - 3,  pu->ob_x);
   pu->ob_x = MAX (desk.g_x + 3, pu->ob_x);
   pu->ob_y = MIN (desk.g_y + desk.g_h - pu->ob_height - 3, pu->ob_y);
   pu->ob_y = MAX (desk.g_y + 3, pu->ob_y);

   box.g_x = pu->ob_x - 1;   box.g_w = pu->ob_width  + 4;
   box.g_y = pu->ob_y - 1;   box.g_h = pu->ob_height + 4;

   for (wrk = pu; ! (wrk->ob_flags & LASTOB); (++wrk)->ob_state &= ~CHECKED);
   pu[button = *object].ob_state |= CHECKED | SELECTED;

   popup.fd_w = box.g_w;   popup.fd_h = box.g_h;
   popup.fd_nplanes = planes;   popup.fd_wdwidth = (box.g_w + 15) / 16;
   popup.fd_addr = Malloc (planes * (box.g_h * (box.g_w + 15L) / 8));

   xy[0] = box.g_x;   xy[2] = box.g_x + box.g_w - 1;
   xy[1] = box.g_y;   xy[3] = box.g_y + box.g_h - 1;
   xy[4] = xy[5] = 0;   xy[6] = box.g_w - 1;   xy[7] = box.g_h - 1;

   wind_update (BEG_UPDATE);   wind_update (BEG_MCTRL);

   if (popup.fd_addr) {
        graf_mouse (M_OFF, NULL);
        vro_cpyfm (vdi_handle, S_ONLY, xy, &screen, &popup);
        graf_mouse (M_ON, NULL);   graf_mouse (ARROW, NULL);
      }
     else
        form_dial (FMD_START, 0,0,0,0, box.g_x, box.g_y, box.g_w, box.g_h);

   graf_mkstate (&dummy, &dummy, &butt, &dummy);
   state = (butt & 1) ? 0 : 1;

   objc_draw (pu, ROOT, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h);

   do {
        objc_offset (pu, button, &p_x, &p_y);
        event = evnt_multi (MU_KEYBD | MU_BUTTON | MU_M1, 1, 1, state, (button > 0),
                    p_x, p_y, pu[button].ob_width, pu[button].ob_height,
                    0,0,0,0,0, NULL, 0,0, &t_x, &t_y, &butt, &dummy, &kret, &bret);

        if ((event & MU_KEYBD) || (event & MU_BUTTON))
             abort_flg = TRUE;
        pu[button].ob_state &= ~SELECTED;

        if (event & MU_KEYBD)   button = 0;
        if (event & MU_M1) {
             if (button)
                  objc_draw (pu, ROOT, 2, p_x, p_y, pu[button].ob_width, pu[button].ob_height);
             button = objc_find (pu, ROOT, MAX_DEPTH, t_x, t_y);
             if (button > 0) {
                  if ((pu[button].ob_state & DISABLED) == 0) {
                       pu[button].ob_state |= SELECTED;
                       objc_draw (pu, button, 1, box.g_x, box.g_y, box.g_w, box.g_h);
                     }
                    else   button = 0;
                }
               else   button = 0;
           }
     } while (! abort_flg);

   SWAP (xy[0], xy[4]);   SWAP (xy[1], xy[5]);
   SWAP (xy[2], xy[6]);   SWAP (xy[3], xy[7]);

   if (popup.fd_addr) {
        graf_mouse (M_OFF, NULL);
        vro_cpyfm (vdi_handle, S_ONLY, xy, &popup, &screen);
        graf_mouse (M_ON, NULL);   Mfree (popup.fd_addr);
      }
     else
        form_dial (FMD_FINISH, 0,0,0,0, box.g_x, box.g_y, box.g_w, box.g_h);

   wind_update (END_MCTRL);   wind_update (END_UPDATE);

   if (button) {
        for (chr = pu[button].ob_spec.free_string; *chr == ' '; chr++);
        change_freestring (dial_ind, str_obj, str_obj, chr, length);
        *object = button;
      }
 }


int cdecl  my_button_handler (parameter)

PARMBLK *parameter;

{
   int  clip[4], pxy[4], pos_x, pos_y, radius;

   clip[0] = parameter->pb_xc;   clip[2] = clip[0] + parameter->pb_wc - 1;
   clip[1] = parameter->pb_yc;   clip[3] = clip[1] + parameter->pb_hc - 1;
   vs_clip (vdi_handle, 1, clip);

   radius = (parameter->pb_w + parameter->pb_h) / 6;
   pos_x = parameter->pb_x + parameter->pb_w / 2;
   pos_y = parameter->pb_y + parameter->pb_h / 2;

   vsf_interior (vdi_handle, FIS_HOLLOW);

   if (parameter->pb_tree[parameter->pb_obj].ob_flags & RBUTTON) {
        v_circle (vdi_handle, pos_x, pos_y, radius);

        if (parameter->pb_currstate & SELECTED) {
             vsf_interior (vdi_handle, FIS_SOLID);
             v_circle (vdi_handle, pos_x, pos_y, radius / 2);
           }
      }
     else {
        pxy[0] = pos_x - radius;   pxy[2] = pos_x + radius;
        pxy[1] = pos_y - radius;   pxy[3] = pos_y + radius;
        v_bar (vdi_handle, pxy);

        if (parameter->pb_currstate & SELECTED) {
             pxy[0] += 2;   pxy[1] += 2;   pxy[2] -= 2;   pxy[3] -= 2;
             v_pline (vdi_handle, 2, pxy);
             radius = pxy[1];   pxy[1] = pxy[3];   pxy[3] = radius;
             v_pline (vdi_handle, 2, pxy);
           }
      }

   vs_clip (vdi_handle, 0, clip);

   return (parameter->pb_currstate & ~SELECTED);
 }
