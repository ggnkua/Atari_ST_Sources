
/*********************************************************************/
/*                                                                   */
/*     STinG : Modem Dialer, Main module                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                        from 16. Januar 1997      */
/*                                                                   */
/*      Module for Startup, Menues, and Remote Control               */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <device.h>

#include "dial.h"
#include "window.h"
#include "remctrl.h"
#include "transprt.h"


#define  FALSE            0
#define  TRUE             1
#define  CNTRL_Q          0x1011
#define  FOREVER          for (;;)
#define  VA_START         0x4711 
#define  S_NONE           0


int    get_version (char vers[]);
void   query_active (int alert_flag);
int    init_misc (void);
int    en_dis_able (int dtr_flag, int alert_flag);
void   set_configuration (void);
void   set_statistics (void);
void   show_statistics (void);

int    init_config_stuff (void);
void   fill_in_config_box (void);
void   reset_config (void);
int    conf_click (int object);
int    load_dial_script (char file[]);

void   spawn_dialer (void);
void   spawn_batch (int what);
int    hangup (void);

void   set_memory (void);
void   show_memory (void);
int    mem_click (int object);
int    mem_key_typed (int scancode);
int    stat_click (int object);
int    stat_key_typed (int scancode);
void   set_routing (void);
int    routing_click (int object);
int    init_resolve (void);
int    resolve_click (int object);
int    spawn_ping (int object);
int    spawn_traceroute (int object);

void   terminate (void);
void   get_path (void);
long   get_boot_drv (void);
void   open_main (void);
void   operate_main (void);
int    main_click (int object);
int    set_mode (int mode, int alert_flag);
void   spawn_tools (int which);
int    key_typed (int scancode);
int    message_handler (int message[]);
int    timer_handler (void);
void   finish_dial (int return_code);


extern int       edit[], conf_shown, max_num_dials, resident;
extern char      version[], *batch;
extern DEV_LIST  *devices;

void           (* dial_timer) (void), (* mem_timer) (void), (* stat_timer) (void);
void           (* ping_timer) (void), (* trace_timer) (void);
int            gl_apid, out_msg[8], mode, handle, sender, counter, dialer_delay;
int            dial_state, off_hook, connected;
int            main_is_open = FALSE, exit_dialer = FALSE;
char           config_path[256];
char           hangup_alert[] = "[2][ |  Really hangup Modem ?   ][ Yes | No ]";
char           no_udp_alert[] = "[1][ |  Opening UDP port failed.   | |"
                                "  No Remote Control !][ Hmm ]";
char           no_batch_alert[] = "[1][ |  Can't run login tools,| |"
                                "  \'LOGIN_BATCH\' not defined.   ][ Hmm ]";
unsigned char  ip_address[4] = { 127, 0, 0, 1 }, ip_dns[4][4];



void  main()

{
   int   alert;
   char  string[6];

   gl_apid = appl_init();

   if (! _app) {
        menu_register (gl_apid, "  STinG Dialer");
        evnt_timer (1000, 0);
      }

   get_path();
   dial_state = S_NONE;   off_hook = connected = FALSE;
   strcat (config_path, "DIAL.RSC");

   if (! rsrc_load (config_path)) {
        form_alert (1, "[1][ |   Cannot find DIAL.RSC !   ][ Abort ]");
        terminate();   return;
      }
   config_path[strlen(config_path) - 8] = '\0';

   if (initialise_windows (19, ICONIFY) == 0) {
        leave_windows();   rsrc_free();   terminate();
        return;
      }

   if ((alert = get_version (string)) > 0) {
        form_alert (1, (alert == 1) ?
                "[1][ |   Don't use this Dialer    | |     with STiK !][ Abort ]" :
                "[1][ |   STinG is not loaded,    | |     or corrupted !][ Okay ]");
        leave_windows();   rsrc_free();   terminate();
        return;
      }

   if ((devices = InitDevices (NULL, NULL)) == NULL) {
        leave_windows();   rsrc_free();   terminate();
        return;
      }

   if (! init_misc()) {
        form_alert (1, "[1][ |   Serial driver not    | |     installed !][ Abort ]");
        TermDevices();   leave_windows();   rsrc_free();   terminate();
        return;
      }

   change_freestring (START, ST_VERS,  -1, string, 5);
   change_freestring (START, DL_VERS,  -1, version, 5);
   change_freestring (START, MOD_STAT, -1, " Offline", 9);
   set_mode (FALSE, TRUE);

   if (! init_config_stuff()) {
        TermDevices();   leave_windows();   rsrc_free();   terminate();
        return;
      }
   load_dial_script ("DIAL.SCR");   fill_in_config_box();   set_configuration();
   dial_timer = mem_timer = stat_timer = ping_timer = trace_timer = NULL;

   if ((handle = UDP_open (0, IP_DIALER_PORT)) < 0) {
        handle = -1;
        form_alert (1, no_udp_alert);
      }
   set_callbacks (CB_TIMER,   (FUNC)   timer_handler, (FUNC) 200L);
   set_callbacks (CB_MESSAGE, (FUNC) message_handler, (FUNC)   0L);

   graf_mouse (ARROW, NULL);

   if (_app) {
        open_main();
        operate_main();
        while (resident && ! exit_dialer) {
             operate_main();
           }
      }
     else {
        FOREVER {
             operate_main();
           }
      }

   if (handle != -1)
        UDP_close (handle);

   TermDevices();

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
   char  *ptr, file[128] = "\\DIAL.INF", path[] = "\\STING\\";

   config_path[0] = 'A' + Dgetdrv();
   config_path[1] = ':';
   Dgetpath (& config_path[2], 0);
   strcat (config_path, file);
   handle = (int) Fopen (config_path, 0);

   if (handle < 0) {
        strcpy (& config_path[2], file);
        handle = (int) Fopen (config_path, 0);

        if (handle < 0) {
             config_path[0] = (char) Supexec (get_boot_drv);
             handle = (int) Fopen (config_path, 0);

             if (handle < 0) {
                  if (! shel_find (& file[1])) {
                       strcpy (config_path, path);
                       return;
                     }
                  if ((handle = (int) Fopen (& file[1], 0)) < 0) {
                       strcpy (config_path, path);
                       return;
                     }
                }
           }
      }

   len = Fread (handle, 250L, config_path);
   Fclose (handle);

   if (len > 0) {
        config_path[len] = '\0';
        if ((ptr = strchr (config_path, '\r')) != NULL)   *ptr = '\0';
        if ((ptr = strchr (config_path, '\n')) != NULL)   *ptr = '\0';
      }
     else
        strcpy (config_path, path);
 }


long  get_boot_drv()

{
   unsigned  int  *_bootdev = (void *) 0x446L;

   return ((long) ('A' + *_bootdev));
 }


void  open_main()

{
   main_is_open = TRUE;

   open_rsc_window (START, 0, " STinG Dialer : Main ", " Main ", -1);
   set_callbacks (START, main_click, key_typed);
 }


void  operate_main()

{
   int  event;

   do {
        if ((event = operate_events()) == -4)
             exit_dialer = TRUE;
     } while (event >= 0);
 }


int  main_click (object)

int  object;

{
   int  shown;

   evnt_timer (60, 0);
   change_flags (START, object & 0x7fff, 0, 0, SELECTED);

   switch (object & 0x7fff) {
      case ST_CNCT :
        if (dial_state != S_NONE || connected) {
             if (off_hook) {
                  if (form_alert (2, hangup_alert) == 1) {
                       hangup();
                       dial_state = S_NONE;
                     }
                }
               else
                  top_rsc_window (DIALER);
           }
          else {
             sender = -1;   max_num_dials = 12345;
             spawn_dialer();
             counter = dialer_delay;
           }
        break;
      case ST_ABLE :
        set_mode (-1, TRUE);
        break;
      case ST_STUFF :
        shown = -1;
        if (pop_up (PU_S_TL, & shown, START, TL_TTL, 0) != 0)
             spawn_tools (shown);
        break;
      case ST_CONF :
        open_rsc_window (CONF, edit[conf_shown], " STinG Dialer : Configuration ", " Config ", START);
        fill_in_config_box();
        set_callbacks (CONF, conf_click, key_typed);
        break;
      case AUTHORS :
        open_rsc_window (CREDITS, 0, " STinG : Credits ", " Credits ", START);
        set_callbacks (CREDITS, (FUNC) NULL, key_typed);
        break;
      case ST_EXIT :
        close_rsc_window (CREDITS, -1);
        close_rsc_window (DIALER, -1);
        close_rsc_window (CONF, -1);
        close_rsc_window (O_MEM, -1);
        close_rsc_window (O_STAT, -1);
        close_rsc_window (O_ROUTE, -1);
        close_rsc_window (O_RSLV, -1);
        close_rsc_window (O_PING, -1);
        close_rsc_window (OP_DOIT, -1);
        close_rsc_window (O_TRACE, -1);
        close_rsc_window (OT_DOIT, -1);
        exit_dialer = TRUE;
        return (1);
      case CLOSER_CLICKED :
        main_is_open = FALSE;
        break;
      }

   return (0);
 }


int  set_mode (new_mode, alert)

int  new_mode, alert;

{
   OBJECT  *tree;

   rsrc_gaddr (R_TREE, START, &tree);

   if (new_mode < 0)
        new_mode = (tree[ST_ABLE].ob_spec.free_string[0] == 'E');

   if (  new_mode && tree[ST_ABLE].ob_spec.free_string[0] == 'D')
        return (TRUE);
   if (! new_mode && tree[ST_ABLE].ob_spec.free_string[0] == 'E')
        return (TRUE);

   if (! en_dis_able (new_mode, alert))
        return (FALSE);

   strcpy (tree[ST_ABLE].ob_spec.free_string, (new_mode) ? "Disable" : "Enable");

   if (new_mode) {
        query_active (alert);
        tree[ST_CNCT].ob_state  &= ~DISABLED;
        change_flags (CONF, CC_SET,  TRUE,  0, DISABLED);
        change_flags (CONF, CC_SAVE, TRUE,  0, DISABLED);
      }
     else {
        tree[ST_CNCT].ob_state  |=  DISABLED;
        change_flags (CONF, CC_SET,  FALSE, 0, DISABLED);
        change_flags (CONF, CC_SAVE, FALSE, 0, DISABLED);
      }

   tree[ST_ABLE].ob_state &= ~SELECTED;

   evnt_timer (60, 0);
   change_flags (START, ST_BOX, 1, 0, 0);

   return (TRUE);
 }


void  spawn_tools (which)

int  which;

{
   switch (which) {
      case 1 :           /* Show Memory   */
        set_memory();
        open_rsc_window (O_MEM, 0, " STinG : Show Memory ", " Memory ", START);
        set_callbacks (O_MEM, mem_click, mem_key_typed);
        mem_timer = (void (*) (void)) show_memory;
        break;
      case 2 :           /* Statistics    */
        set_statistics();
        open_rsc_window (O_STAT, 0, " STinG : Statistics ", " Statistics ", START);
        set_callbacks (O_STAT, stat_click, stat_key_typed);
        stat_timer = (void (*) (void)) show_statistics;
        break;
      case 3 :           /* Routing Table */
        set_routing();
        open_rsc_window (O_ROUTE, 0, " STinG : Routing Table ", " Routing ", START);
        set_callbacks (O_ROUTE, routing_click, key_typed);
        break;
      case 4 :           /* Launch Batch  */
        if (*(batch = getvstr ("LOGIN_BATCH")) == '0')
             form_alert (1, no_batch_alert);
          else
             spawn_batch (-1);
        break;
      case 5 :           /* Resolve       */
        init_resolve();
        open_rsc_window (O_RSLV, R_HOST, " STinG : Resolve ", " Resolve ", START);
        set_callbacks (O_RSLV, resolve_click, key_typed);
        break;
      case 6 :           /* Ping Host     */
        open_rsc_window (O_PING, OP_HOST, " STinG : Ping ", " Ping ", START);
        set_callbacks (O_PING, spawn_ping, key_typed);
        change_tedinfo (O_PING, OP_HOST, -1, TE_PTEXT, "", 48);
        break;
      case 7 :           /* Trace Route   */
        open_rsc_window (O_TRACE, OT_HOST, " STinG : Trace Route ", " TraceRoute ", START);
        set_callbacks (O_TRACE, spawn_traceroute, key_typed);
        change_tedinfo (O_TRACE, OT_HOST, -1, TE_PTEXT, "", 48);
        break;
      }
 }


int  key_typed (scan)

int  scan;

{
   return ((scan == CNTRL_Q) ? -1 : 1);
 }


int  message_handler (message)

int  message[8];

{
   switch (message[0]) {
      case AC_OPEN :
      case VA_START :
        if (! main_is_open)   open_main();
          else
             top_rsc_window (START);
        break;
      case AC_CLOSE :
      case AP_TERM :
      case AP_RESCHG :
        close_rsc_window (CREDITS, -1);
        close_rsc_window (DIALER, -1);
        close_rsc_window (CONF, -1);
        close_rsc_window (O_MEM, -1);
        close_rsc_window (O_STAT, -1);
        close_rsc_window (O_RSLV, -1);
        close_rsc_window (O_PING, -1);
        close_rsc_window (OP_DOIT, -1);
        close_rsc_window (O_TRACE, -1);
        close_rsc_window (OT_DOIT, -1);
        exit_dialer = TRUE;
        return(-1);
      }

   return (0);
 }


int  timer_handler()

{
   NDB  *ndb;
   int  message[2], flag = TRUE;

   if (--counter <= 0) {
        if (dial_timer)   dial_timer();
        counter = dialer_delay;
      }

   if (  mem_timer)     mem_timer();
   if ( stat_timer)    stat_timer();
   if ( ping_timer)    ping_timer();
   if (trace_timer)   trace_timer();

   if (handle == -1)   return (0);

   if ((ndb = CNget_NDB (handle)) == NULL)
        return (0);

   message[0] = IP_DIAL_ERROR;

   switch (* (int16 *) ndb->ndata) {
      case IP_DIAL_REQUEST :
        if (dial_state != S_NONE || connected) {
             message[1] = (dial_state != S_NONE) ? IP_IN_PROGRESS : IP_IS_CONNECTED;
             break;
           }
        if (load_dial_script (ndb->ndata + 4) < 0) {
             message[1] = IP_SCR_NOT_FOUND;
             break;
           }
        reset_config();
        if (! set_mode (TRUE, FALSE))  {
             message[1] = IP_PORT_LOCKED;
             break;
           }
        max_num_dials = * (int16 *) (ndb->ndata + 2);
        spawn_dialer();
        counter = dialer_delay;
        sender = 1;
        flag = FALSE;
        break;
      case IP_DIAL_HANGUP :
        if (dial_state != S_NONE) {
             message[1] = IP_IN_PROGRESS;
             break;
           }
        if (! hangup()) {
             message[1] = IP_OPEN_FAILED;
             break;
           }
        set_mode (FALSE, FALSE);
        message[0] = IP_DIAL_DONE;
        message[1] = 0;
        break;
      }
   KRfree (ndb->ptr);
   KRfree (ndb);

   if (flag) {
        UDP_send (handle, (char *) message, 4);
        UDP_close (handle);

        if ((handle = UDP_open (0, IP_DIALER_PORT)) < 0) {
             handle = -1;
             form_alert (1, no_udp_alert);
           }
      }

   return (0);
 }


void  finish_dial (ret_code)

int  ret_code;

{
   int  message[2];

   if (sender < 0)   return;

   message[0] = (ret_code < 0) ? IP_DIAL_DONE : IP_DIAL_ERROR;
   message[1] = (ret_code < 0) ? 0 : ret_code;

   UDP_send (handle, (char *) message, 4);
   UDP_close (handle);

   if ((handle = UDP_open (0, IP_DIALER_PORT)) < 0) {
        handle = -1;
        form_alert (1, no_udp_alert);
      }
 }
