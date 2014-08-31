

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "ind.h"
#include "window.h"
#include "module.h"


#define  FALSE            0
#define  TRUE             1
#define  CNTRL_Q          0x1011
#define  FOREVER          for (;;)
#define  VA_START         0x4711 


int   get_version (char vers[]),  init_modules (void);
int   check_modules (void);
void  terminate_modules (void),  call_module (int this_one);
void  insert_modules (int draw_flag);

void  init_configs (void),  fill_in_config_box (void);
int   cdecl conf_click (int object),  cdecl conf_typed (int scancode);

void  set_api_struct (void);

void  terminate (void),  get_path (void),  do_some_work (void);
void  do_slider (int position, int offset);
int   cdecl main_click (int object),  cdecl message_handler (int message[]);
int   cdecl key_typed (int scancode);


extern int   click_box[], mdle_box[], num_modules, conf_shown, edit[];
extern char  version[], *strings;

int   gl_apid, sender, disp_offset = 0, main_is_open = FALSE, exit_inetd = FALSE;
char  ism_path[256], inetd_path[256];



void  main()

{
   int   message[8], flag;
   char  string[6];

   gl_apid = appl_init();

   if (! _app) {
        menu_register (gl_apid, "  Super Server");
        evnt_timer (1000, 0);
      }

   if (! rsrc_load ("IND.RSC")) {
        form_alert (1, "[1][ |   Cannot find IND.RSC !   ][ Cancel ]");
        terminate();   return;
      }

   get_path();

   if (initialise_windows (4, ICONIFY) == 0) {
        leave_windows();   rsrc_free();   terminate();
        return;
      }

   if (get_version (string) > 0) {
        form_alert (1, 
                "[1][ |   STiK is not loaded,    | |      or corrupted !][ Cancel ]");
        leave_windows();   rsrc_free();   terminate();
        return;
      }
   change_freestring (START, ST_VERS,  -1, string, 5);
   change_freestring (START, SS_VERS,  -1, version, 5);

   set_api_struct();

   if (init_modules() == 0) {
        leave_windows();   rsrc_free();   terminate();
        return;
      }
   set_callbacks (CB_EVENT, (FUNC) check_modules, (FUNC) 0L);

   init_configs();

   graf_mouse (ARROW, NULL);

   if (_app) {
        do_some_work();
        while (! exit_inetd) {
             evnt_mesag (message);
             message_handler (message);
             while ((flag = operate_events()) >= 0);
             if (flag == -4)
                  exit_inetd = TRUE;
           }
      }
     else {
        FOREVER {
             evnt_mesag (message);
             message_handler (message);
           }
      }

   if (strings)   Mfree (strings);

   terminate_modules();

   leave_windows();

   rsrc_free();

   appl_exit();
 }


void  terminate()

{
   int   message[8];
   char  problem[] = "[1][ |  Problem occured during   | |    initialisation !][ Hmm ]";

   if (_app) {
        appl_exit();   return;
      }
     else {
        FOREVER {
             evnt_mesag (message);
             if (message[0] == AC_OPEN)   form_alert (1, problem);
           }
      }
 }


void  get_path()

{
   int   handle;
   long  len;
   char  *ptr, file[] = "\\IND.INF", path[] = "\\ISM";

   inetd_path[0] = 'A' + Dgetdrv();
   inetd_path[1] = ':';
   Dgetpath (&inetd_path[2], 0);

   strcpy (ism_path, inetd_path);

   strcat (ism_path, file);
   handle = (int) Fopen (ism_path, 0);

   if (handle < 0) {
        strcpy (&ism_path[2], file);
        handle = (int) Fopen (ism_path, 0);

        if (handle < 0) {
             strcpy (ism_path, path);
             return;
           }
      }

   len = Fread (handle, 250L, ism_path);
   Fclose (handle);

   if (len > 0) {
        if ((ptr = strchr (ism_path, '\r')) != NULL)   *ptr = '\0';
        if ((ptr = strchr (ism_path, '\n')) != NULL)   *ptr = '\0';
        ism_path[len] = '\0';
      }
     else
        strcpy (&ism_path[2], path);
 }


void  do_some_work()

{
   int  event = 0;

   main_is_open = TRUE;

   open_rsc_window (START, 0, " STiK  Super Server ", " Main ", -1);
   set_callbacks (START, main_click, key_typed);
   set_callbacks (CB_MESSAGE, (FUNC) message_handler, (FUNC) 0L);

   while (event >= 0)
        if ((event = operate_events()) == -4)
             exit_inetd = TRUE;

   main_is_open = FALSE;
 }


int cdecl  main_click (object)

int  object;

{
   OBJECT  *tree;
   int     pos_x, pos_y, key_state, mouse_state, offset, count;

   rsrc_gaddr (R_TREE, START, &tree);
   graf_mkstate (&pos_x, &pos_y, &mouse_state, &key_state);

   if ((object & 0x7fff) != ST_S_BTN)
        evnt_timer (60, 0);
   change_flags (START, object & 0x7fff, 0, 0, SELECTED);

   switch (object & 0x7fff) {
      case ST_CONF :
        open_rsc_window (CONF, edit[conf_shown], " STiK INetD : Configuration ", " Config ", START);
        fill_in_config_box();
        set_callbacks (CONF, conf_click, conf_typed);
        break;
      case AUTHORS :
        open_rsc_window (CREDITS, 0, " STiK INetD : Credits ", " Credits ", START);
        set_callbacks (CREDITS, (FUNC) NULL, key_typed);
        break;
      case ST_MCK1 :
      case ST_MCK2 :
      case ST_MCK3 :
      case ST_MCK4 :
        for (count = 0; count < 4; count++)
             if (click_box[count] == (object & 0x7fff))
                  break;
        change_flags (START, mdle_box[count], 0, 0, 0);
        call_module (disp_offset + count);
        break;
      case ST_S_UP :
        do_slider (-1, -1);   break;
      case ST_S_DWN :
        do_slider (-1,  1);   break;
      case ST_S_BTN :
        graf_mkstate (&pos_x, &pos_y, &mouse_state, &key_state);
        if (num_modules > 4) {
             offset = 500 / (num_modules - 4);
             if (mouse_state & 0x01) {
                  count = offset + graf_slidebox (tree, ST_S_GND, ST_S_BTN, TRUE);
                  do_slider ((num_modules - 4) * count / 1000, 0);
                }
           }
        break;
      case ST_S_GND :
        offset = pos_y;
        objc_offset (tree, ST_S_BTN, &pos_x, &pos_y);
        do_slider (-1, (offset < pos_y) ? -4 :
                      ((offset > pos_y + tree[ST_S_BTN].ob_height) ? 4 : 0));
        break;
      case CLOSER_CLICKED :
        if ((key_state & 0x04) != 0) {
             close_rsc_window (CREDITS, -1);
             close_rsc_window (CONF, -1);
             exit_inetd = TRUE;
             return (1);
           }
      }

   return (0);
 }


void  do_slider (position, offset)

int  position, offset;

{
   OBJECT  *tree;
   int     difference;

   rsrc_gaddr (R_TREE, START, &tree);

   if (position < 0) {
        disp_offset += offset;
        if (disp_offset < 0)                 disp_offset = 0;
        if (disp_offset > num_modules - 4)   disp_offset = num_modules - 4;
      }
     else
        disp_offset = position;

   difference = tree[ST_S_GND].ob_height - tree[ST_S_BTN].ob_height;
   tree[ST_S_BTN].ob_y = difference * disp_offset / (num_modules - 4);
   insert_modules (TRUE);
   change_flags (START, ST_SLIDE, FALSE, 0, 0);
 }


int cdecl  message_handler (message)

int  message[8];

{
   sender = message[1];

   switch (message[0]) {
      case AC_OPEN :
      case VA_START :
        if (! main_is_open)   do_some_work();
          else
             top_rsc_window (START);
        break;
      case AC_CLOSE :
      case AP_TERM :
      case AP_RESCHG :
        exit_inetd = TRUE;
        break;
      }

   return (0);
 }


int cdecl  key_typed (scan)

int  scan;

{
   return ((scan == CNTRL_Q) ? -1 : 1);
 }
