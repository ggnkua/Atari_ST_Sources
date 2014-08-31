
/*********************************************************************/
/*                                                                   */
/*     Konfiguration der Seriellen Schnittstellen                    */
/*                                                                   */
/*                                                                   */
/*      CPX-Version 0.90                   vom 17. August 1997       */
/*                                                                   */
/*      zu kompilieren mit Pure C ohne String - Merging !!!          */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>

#include "serial.h"


#define  NUM_ENTRIES  16


typedef  struct {
      char    name[13], *gemdos;
      int     bios_no, flags;
      int     bits, parity, stops, flow, dtr, send, recve;
      long    speed;
      MAPTAB  port_driver;
 } SER_PORT;

typedef  unsigned char  uint8;
typedef  unsigned int   uint16;
typedef  unsigned long  uint32;


/*
 *  Saved port variables. Must be first variables !!!
 */
SER_PORT  array[NUM_ENTRIES] = { "", NULL };
int       num_ports = 0, which = 0;


#pragma  warn  -rpt
#include "serial.rsh"
#pragma  warn  .rpt

#include <xctrl.h>


#define  FALSE       0
#define  TRUE        1

#define  NIL         ((void *) -1L)
#define  MESSAGE     -1
#define  CROS_CHK    (CROSSED | CHECKED)

#define  F_SERLAN     0x01
#define  F_RSVF       0x02
#define  F_STANDARD   0x04
#define  F_USELAN     0x08
#define  F_DTR        0x100
#define  F_IN_USE     0x800

#define  TF_STOPBITS    0x0003
#define  TF_1STOP       0x0001
#define  TF_15STOP      0x0002
#define  TF_2STOP       0x0003
#define  TF_CHARBITS    0x000c
#define  TF_8BIT        0x0000
#define  TF_7BIT        0x0004
#define  TF_6BIT        0x0008
#define  TF_5BIT        0x000c
#define  TF_FLOW        0x3000
#define  TF_TANDEM      0x1000
#define  TF_RTSCTS      0x2000
#define  TF_PARITY      0xc000
#define  TF_EVEN        0x4000
#define  TF_ODD         0x8000

#define  TIOCM_DTR      0x0002
#define  TIOCM_RTS      0x0004
#define  TIOCM_CTS      0x0008


long        cdecl  do_Rsconf (MAPTAB *ent, int spd, int flw, int u, int r, int t, int s);
void               flush (MAPTAB *entry);

CPX_INFO *  cdecl  cpx_init (CPX_PARAMS *para_ptr);
int         cdecl  cpx_call (GRECT *window);
int         cdecl  my_button_handler (PARMBLK *parameter);
void               parse_tree (OBJECT *tree, int obj, int mode);
long               do_flush (void);
long               do_break (void);
void               get_rsc_data (void);
void               set_rsc_data (void);
void               set_popup_string (char *original, int index, int flag, int enable);
long               get_port_data ();
long               set_port_data (void);
void               set_default_data (void);
void               set_port (SER_PORT *port, SER_PORT *back, int alert);
void               read_cookies (void);
void               RSVF_init (void);
void               xscript (char gemdos[], char generic[], int bios, int flag, int force);
void               xerase (char gemdos[]);
void               TOS_init (void);
void               do_entry (char gemdos[], char generic[], int bios, int flag);
void               bconmap_init (void);
int         cdecl  my_Bconstat (int dummy);
long        cdecl  my_Bconin (int dummy);
long        cdecl  my_Rsconf (int speed, int flow, int ucr, int rsr, int tsr, int scr);
void               do_port_popup (void);


CPX_PARAMS  *parameters;
OBJECT      *box;
USERBLK     my_user_block = {  my_button_handler,  0  };
CPX_INFO    fkts = {
               cpx_call, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL  };
SER_PORT    backup[NUM_ENTRIES];
int  cdecl  (* popup) (char *ent[], int no, int which, int font, GRECT *butt, GRECT *wind);
int         errno, vdi_handle, mode_flag, last_bios, glbl_par, alerts;
int         mode_box[] = {  PROT_BOX,  DRVR_BOX  };
int         act_speed, num_speed;
long        rsvf, mint, machine;
long        baudrate[] = {  19200, 9600, 4800, 3600, 2400, 2000, 1800, 1200, 600, 300,
                            200, 150, 134, 110, 75, 50  };
char        alert[100], dat_str[20], **ptrs, *wrk;
char        *port[NUM_ENTRIES], portbuf[384], *speed[32], speedbuf[320], ex_bios[168];
char        *mode[]   = {  "  Parameter ", "  Driver    "  };
char        *bits[]   = {  "    8   ", "    7   ", "    6   ", "    5   "  };
char        *parity[] = {  "  None  ", "  Even  ", "  Odd   "  };
char        *stops[]  = {  "    2   ", "    1.5 ", "    1   "  };
char        *flow[]   = {  "  None     ", "  Xon/Xoff ", "  RTS/CTS  ", "  Both     "  };



CPX_INFO *  cdecl  cpx_init (para)

CPX_PARAMS  *para;

{
   int  count;

   parameters = para;
   read_cookies();

   if (parameters->booting)   set_default_data();
     else {
        if (! parameters->rsc_init) {
             (*parameters->do_resource)(NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                         rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                         rs_bitblk, rs_frstr, rs_frimg, rs_trindex, rs_imdope);
             box = rs_object;

             for (count = 0; count < NUM_OBS; count++) {
                  if (box[count].ob_type & 0x7f00)
                       if ((box[count].ob_state & CROS_CHK) == CROS_CHK) {
                            box[count].ob_type = G_USERDEF;
                            box[count].ob_spec.userblk = &my_user_block;
                            box[count].ob_state &= ~ (CROSSED | CHECKED);
                          }
                }
             parse_tree (box, ROOT, -1);

             if (rsvf)
                  RSVF_init();
               else
                  TOS_init();

             do_port_popup();   Supexec (get_port_data);
             memcpy (backup, array, NUM_ENTRIES * sizeof (SER_PORT));

             if (which >= num_ports)   which = 0;
             set_popup_string (port[which], PORT, FALSE, TRUE);
             set_popup_string (mode[mode_flag = 0], MODE, FALSE, TRUE);

             if ((array[which].flags & F_IN_USE) != 0) {
                  parse_tree (box, PROT_BOX, 0);
                  box[PROT_BOX].ob_flags |= HIDETREE;
                }
               else
                  box[FAILED].ob_flags |= HIDETREE;

             parse_tree (box, DRVR_BOX, 0);
             box[DRVR_BOX].ob_flags |= HIDETREE;
             set_rsc_data();
           }
          else
             return (NULL);
      }

   return (&fkts);
 }


int  cdecl  cpx_call (wind)

GRECT  *wind;

{
   GRECT     rect;
   SER_PORT  *act;
   int       button, count, delay, choice, event, dummy, abort_flg = FALSE;
   int       msg_buff[8], work_in[11], work_out[57];
   char      error[64];

   graf_mouse (ARROW, NULL);

   for (count = 0; count < 10; count++)   work_in[count] = 1;
   work_in[10] = 2;

   vdi_handle = parameters->vdi_handle;
   v_opnvwk (work_in, &vdi_handle, work_out);

   box[ROOT].ob_x = wind->g_x;   box[ROOT].ob_y = wind->g_y;
   objc_draw (box, ROOT, MAX_DEPTH, wind->g_x, wind->g_y, wind->g_w, wind->g_h);

   popup = parameters->do_pulldown;   act = & array[which];

   alerts = TRUE;

   do {
        button = (act->flags & F_RSVF) || (mint && (act->flags & F_STANDARD));
        button = ((act->flags & F_IN_USE) == 0) ? ((mode_flag && button) ? SEND_BUF : 0) : 0;
        button = (*parameters->do_form) (box, button, msg_buff);   
        if (button > 0) {
             objc_offset (box, button &= 0x7fff, &rect.g_x, &rect.g_y);
             rect.g_w = box[button].ob_width;   rect.g_h = box[button].ob_height;
           }
        switch (button) {
           case SAVE :
             choice = FALSE;
             for (count = 0; count < num_ports; count++)
                  if ((array[count].flags & F_IN_USE) != 0)   choice = TRUE;
             choice = form_alert (1, (choice) ?
                          "[2][  Some ports are in use,|  their settings would be  |"
                          "  lost ! Save anyway ?][Save| Cancel ]" :
                          "[2][ |  Save port settings ?][Save| Cancel ]");
             if (choice == 1) {
                  if ((act->flags & F_IN_USE) == 0)
                       get_rsc_data();
                  Supexec (set_port_data);
                  count = NUM_ENTRIES * sizeof (SER_PORT) + 2 * sizeof (int);
                  (*parameters->write_config) (array, count);
                }
             break;
           case SET :
             if ((act->flags & F_IN_USE) == 0)
                  get_rsc_data();
             Supexec (set_port_data);
           case CANCEL :
             abort_flg = TRUE;
             break;
           case MESSAGE :
             if (msg_buff[0] == WM_CLOSED) {
                  if ((act->flags & F_IN_USE) == 0)
                       get_rsc_data();
                  Supexec (set_port_data);
                  abort_flg = TRUE;
                }
             if (msg_buff[0] == AC_CLOSE)   abort_flg = TRUE;
             break;
           case PORT :
             choice = (* popup) (port, num_ports, which, IBM, & rect, wind);
             if (choice >= 0 && choice != which) {
                  if ((act->flags & F_IN_USE) == 0)
                       get_rsc_data();
                  set_popup_string (port[which = choice], PORT, TRUE, TRUE);
                  set_rsc_data();
                  act = & array[which];
                  if ((act->flags & F_IN_USE) == 0) {
                       box[mode_box[mode_flag]].ob_flags &= ~HIDETREE;
                       count = (act->flags & F_RSVF) || (mint && (act->flags & F_STANDARD));
                       parse_tree (box, choice = mode_box[mode_flag], count);
                       box[FAILED].ob_flags |= HIDETREE;
                     }
                    else {
                       box[mode_box[mode_flag]].ob_flags |= HIDETREE;
                       parse_tree (box, mode_box[mode_flag], 0);
                       box[choice = FAILED].ob_flags &= ~HIDETREE;
                     }
                  objc_draw (box, choice, MAX_DEPTH, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
                }
             break;
           case MODE :
             choice = (* popup) (mode, 2, mode_flag, IBM, & rect, wind);
             if (choice >= 0 && choice != mode_flag) {
                  if ((act->flags & F_IN_USE) == 0) {
                       box[mode_box[mode_flag]].ob_flags |= HIDETREE;
                       parse_tree (box, mode_box[mode_flag], 0);
                     }
                  set_popup_string (mode[mode_flag = choice], MODE, TRUE, TRUE);
                  if ((act->flags & F_IN_USE) == 0) {
                       box[choice = mode_box[mode_flag]].ob_flags &= ~HIDETREE;
                       count = (act->flags & F_RSVF) || (mint && (act->flags & F_STANDARD));
                       parse_tree (box, choice, count);
                       objc_draw (box, choice, MAX_DEPTH, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
                     }
                }
             break;
           case BAUDRATE :
             choice = (* popup) (speed, num_speed, act_speed, IBM, & rect, wind);
             if (choice >= 0) {
                  set_popup_string (speed[act_speed = choice], BAUDRATE, TRUE, TRUE);
                  act->speed = atol (speed[act_speed]);
                }
             break;
           case BITS :
             choice = (* popup) (bits, 4, act->bits >> 2, IBM, & rect, wind);
             if (choice >= 0)
                  set_popup_string (bits[choice], BITS, TRUE, TRUE),  act->bits = choice << 2;
             break;
           case PARITY :
             count = (act->parity & TF_EVEN) ? 1 : ((act->parity & TF_ODD) ? 2 : 0);
             choice = (* popup) (parity, 3, count, IBM, & rect, wind);
             if (choice >= 0) {
                  set_popup_string (parity[choice], PARITY, TRUE, TRUE);
                  act->parity = (choice) ? ((choice == 1) ? TF_EVEN : TF_ODD) : 0x0000;
                }
             break;
           case STOPS :
             choice = (* popup) (stops, 3, 3 - act->stops, IBM, & rect, wind);
             if (choice >= 0)
                  set_popup_string (stops[choice], STOPS, TRUE, TRUE),  act->stops =  3 - choice;
             break;
           case FLOW :
             choice = (* popup) (flow, 4, act->flow >> 12, IBM, & rect, wind);
             if (choice >= 0)
                  set_popup_string (flow[choice], FLOW, TRUE, TRUE),  act->flow = choice << 12;
             break;
           case FLUSH :
             event = evnt_multi (MU_BUTTON | MU_M1, 1,1,0, 1,rect.g_x,rect.g_y,rect.g_w,rect.g_h,
                            0,0,0,0,0, NULL,0,0, &dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
             if ((event & MU_M1) == 0) {
                  if (form_alert (1, "[2][ |  Flush Buffers ?   ][Flush| Cancel ]") == 1)
                       Supexec (do_flush);
                }
             break;
           case BREAK :
             glbl_par = TRUE;    Supexec (do_break);
             evnt_multi (MU_BUTTON | MU_M1, 1,1,0, 1,rect.g_x,rect.g_y,rect.g_w,rect.g_h, 0,0,0,0,0,
                            NULL,0,0, &dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
             glbl_par = FALSE;   Supexec (do_break);
             break;
           }
        if (button > 0) {
             box[button].ob_state &= ~ SELECTED;
             objc_draw (box, button, 3, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
           }
     } while (! abort_flg);

   v_clsvwk (vdi_handle);

   return (FALSE);
 }


int  cdecl  my_button_handler (parameter)

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


void  parse_tree (tree, object, mode)

OBJECT  *tree;
int     object, mode;

{
   int  work;

   if (mode == -1) {
        if (tree[object].ob_flags & EDITABLE)
             tree[object].ob_type |= 0x100;
      }
     else {
        if (tree[object].ob_type & 0x100) {
             if (mode == 1)
                  tree[object].ob_flags |= EDITABLE;
               else
                  tree[object].ob_flags &= ~EDITABLE;
           }
      }

   if ((work = tree[object].ob_head) == -1)
        return;

   do {
        parse_tree (tree, work, mode);
        work = tree[work].ob_next;
     } while (work != object);
 }


long  do_flush()

{
   SER_PORT  *port;
   int       handle;
   char      file[32];
   long      value;

   port = & array[which];
   strcpy (file, "U:\\DEV\\");   strcat (file, port->gemdos);

   if ((handle = (int) Fopen (file, 0x40 | FO_RW)) >= 0) {
        value = 3;
        Fcntl (handle, (port->flags & F_RSVF) ? value : (long) & value, TIOCFLUSH);
        Fclose (handle);
      }
     else {
        if (port->port_driver.Bconstat)
             flush (& port->port_driver);
      }

   return (0);
 }


long  do_break()

{
   SER_PORT  *port;
   int       handle, ok_flag = FALSE;
   char      file[32];
   long      value;

   port = & array[which];
   strcpy (file, "U:\\DEV\\");   strcat (file, port->gemdos);

   if ((port->flags & F_RSVF) == 0 && (mint == 0 || (port->flags & F_STANDARD) == 0))
        handle = -1;
     else
        handle = (int) Fopen (file, 0x40 | FO_RW);

   if (handle >= 0) {
        if (Fcntl (handle, 0L, (glbl_par) ? TIOCSBRK : TIOCCBRK) == 0)
             ok_flag = TRUE;
        Fclose (handle);
      }

   if (ok_flag == FALSE) {
        if (port->port_driver.iorec) {
             value = do_Rsconf (& port->port_driver, -1, -1, -1, -1, -1, -1);
             if (glbl_par)
                  value = ((value >> 8) & 0xff) | 8L;
               else
                  value = ((value >> 8) & 0xff) & ~8L;
             do_Rsconf (& port->port_driver, -1, -1, -1, -1, value, -1);
           }
      }

   return (0);
 }


void  get_rsc_data()

{
   SER_PORT  *port = & array[which];

   port->send  = atoi (box[SEND_BUF].ob_spec.tedinfo->te_ptext);
   port->recve = atoi (box[RCVE_BUF].ob_spec.tedinfo->te_ptext);

   if (port->flags & F_SERLAN) {
        if (box[USE_LAN].ob_state & SELECTED)
             port->flags |= F_USELAN;
          else
             port->flags &= ~F_USELAN;
      }

   port->dtr = (box[DTR].ob_state & SELECTED) ? TIOCM_DTR : 0;
 }


void  set_rsc_data()

{
   SER_PORT  *port;
   int       handle, index;
   char      file[32];
   long      spd, last;

   if (((port = & array[which])->flags & F_IN_USE) != 0)
        return;
   strcpy (file, "U:\\DEV\\");   strcat (file, port->gemdos);

   if ((port->flags & F_RSVF) == 0)
        box[RSVF].ob_flags |=  HIDETREE;
     else
        box[RSVF].ob_flags &= ~HIDETREE;

   set_popup_string (flow[port->flow >> 12], FLOW, FALSE, (port->flow != -1));

   set_popup_string (stops[3 - port->stops], STOPS, FALSE, (port->stops != -1));

   index = (port->parity & TF_EVEN) ? 1 : ((port->parity & TF_ODD) ? 2 : 0);
   set_popup_string (parity[index], PARITY, FALSE, (port->parity != -1));

   set_popup_string (bits[port->bits >> 2], BITS, FALSE, (port->bits != -1));

   sprintf (box[SEND_BUF].ob_spec.tedinfo->te_ptext, "%d", port->send);
   sprintf (box[RCVE_BUF].ob_spec.tedinfo->te_ptext, "%d", port->recve);

   if ((port->flags & F_SERLAN) == 0)
        box[LAN_BOX].ob_flags |= HIDETREE;
     else {
        box[LAN_BOX].ob_flags &= ~HIDETREE;
        box[USE_LAN].ob_state &= ~SELECTED;
        box[USE_LAN].ob_state |= (port->flags & F_USELAN) ? SELECTED : NORMAL;
      }

   if ((port->flags & F_DTR) != 0) {
        if (port->dtr)
             box[DTR].ob_state = SELECTED;
          else
             box[DTR].ob_state = NORMAL;
      }
     else
        box[DTR].ob_state = DISABLED;

   if ((port->flags & F_RSVF) == 0 && (mint == 0 || (port->flags & F_STANDARD) == 0))
        handle = -1;
     else
        handle = (int) Fopen (file, 0x40 | FO_RW);

   box[FLUSH].ob_state = (handle < 0 && port->port_driver.iorec == NULL) ? DISABLED : NORMAL;

   index = 0;
   spd = 100000000L;

   if (port->speed != -1) {
        if (handle >= 0) {
             do {
                  last = --spd;
                  if (Fcntl (handle, (long) & spd, TIOCIBAUD) == EINVFN)
                       break;
                  speed[index] = & speedbuf[10 * index];
                  sprintf (speed[index++], "  %6ld ", spd);
               } while (last >= spd);
           }

        if (index == 0) {
             while (index < 16) {
                  sprintf (speed[index] = & speedbuf[10 * index], "  %6ld ", baudrate[index]);
                  index++;
                }
             index++;
           }
        num_speed = index - 1;

        for (index = 0; index < num_speed; index++)
             if (atol (speed[index]) < port->speed)   break;
        if (index > 0)   --index;
      }

   act_speed = index;
   sprintf (file, "%ld", port->speed);
   set_popup_string (file, BAUDRATE, FALSE, (port->speed != -1));

   if (handle >= 0)   Fclose (handle);
 }


void  set_popup_string (original, index, draw_flag, enable)

char  *original;
int   index, draw_flag, enable;

{
   char  temp[32], *walk;
   int   bt_x, bt_y;

   if (enable) {
        strncpy (temp, original, 31);
        temp[31] = '\0';
        for (walk = & temp[0]; *walk == ' ';)
             walk++;
        original = walk;
        for (walk = original + strlen (original) - 1; *walk == ' ' && walk >= original;)
             walk--;
        *++walk = '\0';
        box[index].ob_state &= ~ DISABLED;
      }
     else {
        original = "Unknown";
        box[index].ob_state |= DISABLED;
      }
   strcpy (box[index].ob_spec.free_string, original);

   if (draw_flag) {
        objc_offset (box, index, & bt_x, & bt_y);
        objc_draw (box, index, 1, bt_x, bt_y, box[index].ob_width, box[index].ob_height);
      }
 }


long  get_port_data()

{
   SER_PORT  *port;
   int       act_no, index, handle, ok_flag, flags, rate;
   long      spd, mapping[6];
   char      file[32];

   strcpy (file, "U:\\DEV\\");

   if (Bconmap (0) != 0L)
        act_no = -1;
     else {
        act_no = Bconmap (-1);   which = 10000;
      }

   for (index = 0, port = & array[0]; index < num_ports; index++, port++) {
        strcpy (& file[7], port->gemdos);
        if ((port->flags & F_RSVF) == 0 && (mint == 0 || (port->flags & F_STANDARD) == 0))
             handle = -1;
          else {
             if ((handle = (int) Fopen (file, 0x40 | FO_RW)) < 0) {
                  port->flags |= F_IN_USE;
                  continue;
                }
               else
                  port->flags &= ~F_IN_USE;
           }
        spd = -1;
        if (handle >= 0)
             Fcntl (handle, (long) & spd, TIOCIBAUD);
        if (spd == -1) {
             if (port->port_driver.iorec) {
                  rate = (int) do_Rsconf (& port->port_driver, -2, -1, -1, -1, -1, -1);
                  if (0 <= rate && rate <= 15)   spd = baudrate[rate];
                }
           }
        port->speed = spd;

        ok_flag = FALSE;

        if (handle >= 0) {
             if (Fcntl (handle, (long) & flags, TIOCGFLAGS) == 0) {
                  ok_flag = TRUE;
                  port->flow  = flags & TF_FLOW;       port->parity = flags & TF_PARITY;
                  port->stops = flags & TF_STOPBITS;   port->bits   = flags & TF_CHARBITS;
                }
           }
        if (! ok_flag) {
             if (port->port_driver.iorec) {
                  flags = do_Rsconf (& port->port_driver, -1, -1, -1, -1, -1, -1) >> 24;
                  port->parity = (flags & 4) ? ((flags & 2) ? TF_EVEN : TF_ODD) : 0x0000;
                  port->stops = (flags >> 3) & TF_STOPBITS;   port->bits = (flags >> 3) & TF_CHARBITS;
                }
               else
                  port->parity = port->stops = port->bits = -1;
             port->flow = -1;
           }

        ok_flag = FALSE;

        if (handle >= 0) {
             if (Fcntl (handle, (long) mapping, TIOCCTLMAP) == 0) {
                  ok_flag = TRUE;
                  port->flags |= (mapping[0] & TIOCM_DTR) ? F_DTR : 0;
                }
           }
        if (! ok_flag) {
             switch (machine >> 16) {
                case 0 :
                  if (port->bios_no == 6)   port->flags |= F_DTR;
                  break;
                case 1 :
                  if (port->bios_no == 6)   port->flags |= F_DTR;
                  if ((machine & 0xffffL) == 16) {
                       if (port->bios_no == 7 || port->bios_no == 8)   port->flags |= F_DTR;
                     }
                  break;
                case 2 :
                  if (port->bios_no == 6 || port->bios_no == 7 || port->bios_no == 9)
                       port->flags |= F_DTR;
                  break;
                case 3 :
                  if (port->bios_no == 7 || port->bios_no == 8)   port->flags |= F_DTR;
                  break;
                }
           }

        ok_flag = FALSE;

        if (port->flags & F_DTR) {
             spd = TIOCM_DTR;
             if (handle >= 0) {
                  if (Fcntl (handle, (long) & spd, TIOCCTLGET) == 0) {
                       ok_flag = TRUE;
                       spd &= TIOCM_DTR;
                     }
                }
             if (ok_flag == FALSE) {
                  /* Grab DTR via HW access */
                  ok_flag = TRUE;
                }
             port->dtr = spd;
           }

        ok_flag = FALSE;
        mapping[0] = mapping[1] = mapping[2] = mapping[3] = -1L;

        if (handle >= 0) {
             if (Fcntl (handle, (long) mapping, TIOCBUFFER) == 0)
                  ok_flag = TRUE;
           }
        if (ok_flag == FALSE) {
             if (port->port_driver.iorec) {
                  mapping[0] = (port->port_driver.iorec    )->ibufsiz;
                  mapping[3] = (port->port_driver.iorec + 1)->ibufsiz;
                }
           }
        port->recve = mapping[0];
        port->send  = mapping[3];

        if (port->bios_no == act_no)
             which = index;

        if (handle >= 0)   Fclose (handle);
      }

   if (Bconmap (0) == 0L) {
        if (which >= num_ports)   which = 0;
      }

   return (0);
 }


long  set_port_data()

{
   SER_PORT  *port, *back, serlan, *old;
   int       index, handle;
   char      file[32];

   old = NULL;

   for (index = 0, port = array, back = backup; index < num_ports; index++, port++, back++) {
        if (port->flags & F_SERLAN) {
             old = back;
             memcpy (& serlan, port, sizeof (SER_PORT));
           }
        set_port (port, back, alerts);
      }

   if (old) {
        if (strcmp (serlan.gemdos, "LAN") == 0)
             serlan.gemdos = "SERIAL2";
          else
             serlan.gemdos = "LAN";
        set_port (& serlan, back, FALSE);

        strcpy (file, "U:\\DEV\\");
        strcpy (& file[7], (serlan.flags & F_USELAN) ? "LAN" : "SERIAL2");

        if ((serlan.flags & F_RSVF) == 0 && mint == 0)
             handle = -1;
          else
             handle = (int) Fopen (file, 0x40 | FO_RW);

        if (handle < 0)
             (serlan.flags & F_USELAN) ? Offgibit (0x7f) : Ongibit (0x80);
          else
             Fclose (handle);
      }

   if (Bconmap (0) == 0L)
        Bconmap (array[which].bios_no);

   return (0);
 }
 

void  set_default_data()

{
   SER_PORT  *port, *back, bald;
   int       saved, index, count;
   char      *name;

   memcpy (backup, array, NUM_ENTRIES * sizeof (SER_PORT));
   saved = num_ports;

   if (rsvf)
        RSVF_init();
     else
        TOS_init();

   Supexec (get_port_data);

   for (index = 0, port = & array[0]; index < num_ports; index++, port++) {
        name = port->name;
        for (count = 0, back = & backup[0]; count < saved; count++, back++) {
             if (strcmp (name, back->name) == 0) {
                  port->bits   = back->bits;
                  port->parity = back->parity;
                  port->stops  = back->stops;
                  port->flow   = back->flow;
                  port->dtr    = back->dtr;
                  port->send   = back->send;
                  port->recve  = back->recve;
                  port->speed  = back->speed;
                  port->flags  = (port->flags & ~F_USELAN) | (back->flags & F_USELAN);
                  count = saved;
                }
           }
      }

   bald.speed = bald.bits = bald.parity = bald.stops = bald.flow = -1;
   bald.dtr = bald.send = bald.recve = -1;

   for (index = 0, back = & backup[0]; index < num_ports; index++, back++)
        memcpy (back, & bald, sizeof (SER_PORT));

   alerts = FALSE;

   Supexec (set_port_data);
 }


void  set_port (port, back, alert)

SER_PORT  *port, *back;
int       alert;

{
   int       handle, count, flags, flow, ucr, ok_flag;
   long      longs[4];
   char      file[32], error[128];
   char      tmplt[] = "[1][ |  Cannot set %s for  | |  port \"%s\" !][ Hmm ]";

   strcpy (file, "U:\\DEV\\");
   strcpy (& file[7], port->gemdos);

   if ((port->flags & F_IN_USE) != 0)
        return;

   if ((port->flags & F_RSVF) == 0 && (mint == 0 || (port->flags & F_STANDARD) == 0))
        handle = -1;
     else {
        if ((handle = (int) Fopen (file, 0x40 | FO_RW)) < 0) {
             sprintf (error, "[1][ |  Cannot open port  | |  \"%s\" !][ Hmm ]", port->name);
             if (alert)
                  form_alert (1, error);
             return;
           }
      }

   if (port->speed != back->speed) {
        ok_flag = FALSE;
        if (handle != -1) {
             longs[0] = longs[1] = port->speed;
             if (Fcntl (handle, (long) & longs[0], TIOCIBAUD) == 0 &&
                 Fcntl (handle, (long) & longs[1], TIOCOBAUD) == 0)
                  ok_flag = TRUE;
           }
        if (! ok_flag) {
             if (port->port_driver.iorec) {
                  for (count = 0; count < 16; count++)
                       if (baudrate[count] < port->speed)   break;
                  if (count > 0)   --count;
                  do_Rsconf (& port->port_driver, count, -1, -1, -1, -1, -1);
                  ok_flag = TRUE;
                }
           }
        if (! ok_flag) {
             sprintf (error, tmplt, "baudrate", port->name);
             if (alert)
                  form_alert (1, error);
           }
      }

   if (handle != -1)
        Fcntl (handle, (long) & flags, TIOCGFLAGS);
   if (port->port_driver.iorec) {
        flow = -1;
        ucr = do_Rsconf (& port->port_driver, -1, -1, -1, -1, -1, -1) >> 24;
      }

   if (port->bits != back->bits) {
        flags = flags & ~TF_CHARBITS | port->bits;
        ucr = ucr & 0x9f | (port->bits << 3);
      }
   if (port->parity != back->parity) {
        flags = flags & ~TF_PARITY | port->parity;
        ucr = ucr & 0xfb | ((port->parity) ? 4 : 0);
        ucr = ucr & 0xfd | ((port->parity & TF_EVEN) ? 2 : 0);
      }
   if (port->stops != back->stops) {
        flags = flags & ~TF_STOPBITS | port->stops;
        ucr = ucr & 0xe7 | (port->stops << 3);
      }
   if (port->flow != back->flow) {
        flags = flags & ~TF_FLOW | port->flow;
        flow = port->flow >> 12;
      }

   if (handle != -1) {
        if (Fcntl (handle, (long) & flags, TIOCSFLAGS) < 0) {
             sprintf (error, "[1][  Can\'t set protocol due to|  illegal combination of|  Bits/Parity"
                             "/Stopbits/FlowCTRL   |  for \"%s\" !][ Hmm ]", port->name);
             if (alert)
                  form_alert (1, error);
           }
      }
     else {
        if (port->port_driver.iorec)
             do_Rsconf (& port->port_driver, -1, flow, ucr, -1, -1, -1);
      }

   if (port->flags & F_DTR && port->dtr != back->dtr) {
        ok_flag = FALSE;
        if (handle != -1) {
             longs[0] = TIOCM_DTR;
             longs[1] = port->dtr;
             if (Fcntl (handle, (long) longs, TIOCCTLSET) == 0)
                  ok_flag = TRUE;
           }
        if (! ok_flag) {
             /* Set DTR via HW access */
             ok_flag = TRUE;
           }
        if (! ok_flag) {
             sprintf (error, tmplt, "DTR", port->name);
             if (alert)
                  form_alert (1, error);
           }
      }

   ok_flag = 0;

   if (port->recve == back->recve)
        ok_flag |= 1;
     else {
        if (handle != -1) {
             longs[1] = longs[2] = longs[3] = -1L;
             longs[0] = port->recve;
             if (Fcntl (handle, (long) longs, TIOCBUFFER) == 0)
                  if (longs[0] != -1L)
                       ok_flag |= 1;
           }
      }

   if (port->send == back->send)
        ok_flag |= 2;
     else {
        if (handle != -1) {
             longs[0] = longs[1] = longs[2] = -1L;
             longs[3] = port->send;
             if (Fcntl (handle, (long) longs, TIOCBUFFER) == 0)
                  if (longs[3] != -1L)
                       ok_flag |= 2;
           }
      }

   if (ok_flag != 3) {
        sprintf (error, tmplt, "buffers", port->name);
        if (alert)
             form_alert (1, error);
      }

   if (handle >= 0)   Fclose (handle);
 }


void  read_cookies()

{
   if ((*parameters->find_cookie) ('_MCH', (long *) & machine) == 0)
        machine = 0;
   if ((*parameters->find_cookie) ('RSVF', (long *) & rsvf) == 0)
        rsvf = 0L;
   if ((*parameters->find_cookie) ('MiNT', (long *) & mint) == 0)
        mint = 0L;
 }


void  RSVF_init()

{
   uint8  *walk, ***work;
   int    index;

   for (walk = (uint8 *) rsvf, index = 0; * (long *) walk != 0L && index < NUM_ENTRIES;)
        if ((walk[4] & 0x80) != 0) {
             port[index++] = walk;
             walk += 8;
           }
          else
             walk = * (char **) walk;

   port[index] = NULL;
   num_ports = -1;

   switch (machine >> 16) {
      case 0 :
        xscript ("MODEM1", "Modem 1", last_bios = 6, FALSE, TRUE);
        break;
      case 1 :
        xscript ("MODEM1", "Modem 1", last_bios = 6, FALSE, TRUE);
        if ((machine & 0xffffL) == 16) {
             xscript ("MODEM2",  "Modem 2",               7, FALSE, TRUE);
             xscript ("SERIAL2", "Ser.2/LAN", last_bios = 8, TRUE,  TRUE);
             xerase ("LAN");
           }
        break;
      case 2 :
        xscript ("MODEM1",  "Modem 1",               6, FALSE, TRUE);
        xscript ("MODEM2",  "Modem 2",               7, FALSE, TRUE);
        xscript ("SERIAL1", "Serial 1",              8, FALSE, TRUE);
        xscript ("SERIAL2", "Ser.2/LAN", last_bios = 9, TRUE,  TRUE);
        xerase ("LAN");
        break;
      case 3 :
        xscript ("MODEM1", "Modem 1",         6, FALSE, FALSE);
        xscript ("MODEM2", "Modem 2",         7, FALSE, TRUE);
        xscript ("LAN",    "LAN", last_bios = 8, FALSE, TRUE);
        xerase ("SERIAL2");
        break;
      default :
        xscript ("MODEM1", "Modem 1", last_bios = 6, FALSE, TRUE);
      }
   xscript ("MIDI", "Midi", 0, FALSE, FALSE);

   for (work = (char ***) port; *work; work++)
        if (*work != NIL) {
             strcpy (array[++num_ports].name, **work);
             array[num_ports].gemdos = **work;
             array[num_ports].bios_no =  *((uint8 *) *work + 6);
             array[num_ports].flags   = (*((uint8 *) *work + 4) & 0xf0) | F_RSVF;
             array[num_ports].port_driver.iorec = NULL;
             array[num_ports].port_driver.Bconstat = NULL;
           }

   num_ports++;
   bconmap_init();
 }


void  xscript (gemdos, generic, bios, flag, force)

char  gemdos[], generic[];
int   bios, flag, force;

{
   char  ***walk;

   for (walk = (char ***) port; *walk; walk++) {
        if (*walk != NIL) {
             if (strcmp (**walk, gemdos) == 0) {
                  num_ports++;
                  strcpy (array[num_ports].name, generic);
                  array[num_ports].gemdos = **walk;
                  array[num_ports].bios_no =  *((uint8 *) *walk + 6);
                  array[num_ports].flags   = (*((uint8 *) *walk + 4) & 0xf0) | F_RSVF | F_STANDARD;
                  if (flag)
                       array[num_ports].flags |= F_SERLAN;
                  array[num_ports].port_driver.iorec = NULL;
                  array[num_ports].port_driver.Bconstat = NULL;
                  *walk = (void *) -1L;
                  return;
                }
           }
      }

   if (force) {
        strcpy (array[++num_ports].name, generic);
        array[num_ports].gemdos = gemdos;
        array[num_ports].bios_no = bios;
        array[num_ports].flags   = ((flag) ? F_SERLAN : 0x00) | F_STANDARD;
        array[num_ports].port_driver.iorec = NULL;
      }
 }


void  xerase (gemdos)

char  gemdos[];

{
   char  ***walk;

   for (walk = (char ***) port; *walk; walk++) {
        if (*walk != NIL)
             if (strcmp (**walk, gemdos) == 0)
                  *walk = (void *) -1L;
      }
 }


void  TOS_init()

{
   num_ports = 0;

   switch (machine >> 16) {
      case 0 :
        do_entry ("MODEM1", "Modem 1", last_bios = 6, FALSE);
        break;
      case 1 :
        do_entry ("MODEM1", "Modem 1", last_bios = 6, FALSE);
        if ((machine & 0xffffL) == 16) {
             do_entry ("MODEM2",  "Modem 2",               7, FALSE);
             do_entry ("SERIAL2", "Ser.2/LAN", last_bios = 8, TRUE);
           }
        break;
      case 2 :
        do_entry ("MODEM1",  "Modem 1",               6, FALSE);
        do_entry ("MODEM2",  "Modem 2",               7, FALSE);
        do_entry ("SERIAL1", "Serial 1",              8, FALSE);
        do_entry ("SERIAL2", "Ser.2/LAN", last_bios = 9, TRUE);
        break;
      case 3 :
        do_entry ("MODEM1", "Modem 1",         6, FALSE);
        do_entry ("MODEM2", "Modem 2",         7, FALSE);
        do_entry ("LAN",    "LAN", last_bios = 8, FALSE);
        break;
      default :
        do_entry ("MODEM1", "Modem 1", last_bios = 6, FALSE);
      }

   bconmap_init();
 }


void  do_entry (gemdos, generic, bios, flag)

char  gemdos[], generic[];
int   bios, flag;

{
   strcpy (array[num_ports].name, generic);
   array[num_ports].gemdos = gemdos;
   array[num_ports].bios_no = bios;
   array[num_ports].flags   = ((flag) ? F_SERLAN : 0x00) | F_STANDARD;
   array[num_ports].port_driver.iorec = NULL;
   array[num_ports].port_driver.Bconstat = NULL;

   num_ports++;
 }


void  bconmap_init()

{
   BCONMAP  *bcon;
   MAPTAB   *map_walk;
   int      count, bios, flag, port;
   char     *gemdos, name[8];

   if (Bconmap (0) != 0L) {
        for (port = 0; port < num_ports; port++) {
             if (array[port].bios_no == 6) {
                  array[port].port_driver.Rsconf = my_Rsconf;
                  array[port].port_driver.iorec = Iorec(0);
                  array[port].port_driver.Bconstat = my_Bconstat;
                  array[port].port_driver.Bconin = my_Bconin;
                }
           }
        return;
      }

   map_walk = (bcon = (BCONMAP *) Bconmap (-2))->maptab;
   bios = 6;
   gemdos = & ex_bios[0];

   for (count = bcon->maptabsize; count > 0; --count) {
        flag = FALSE;
        for (port = 0; port < num_ports; port++) {
             if (array[port].bios_no == bios) {
                  flag = TRUE;
                  memcpy (& array[port].port_driver, map_walk, sizeof (MAPTAB));
                }
           }
        if (bios > last_bios && flag == FALSE) {
             array[num_ports].bios_no = bios;
             array[num_ports].flags   = 0;
             sprintf (array[num_ports].name, "Bios %d", bios);
             sprintf (array[num_ports].gemdos = gemdos, "BIOS%d", bios);
             gemdos += strlen (gemdos) + 1;
             memcpy (& array[num_ports++].port_driver, map_walk, sizeof (MAPTAB));
           }
        map_walk++;   bios++;
      }
 }


#pragma warn -par


int  cdecl  my_Bconstat (dummy)

int  dummy;

{
   return (Bconstat (1));
 }


long  cdecl  my_Bconin (dummy)

int  dummy;

{
   return (Bconin (1));
 }


long  cdecl  my_Rsconf (speed, flowctrl, ucr, rsr, tsr, scr)

int  speed, flowctrl, ucr, rsr, tsr, scr;

{
   return (Rsconf (speed, flowctrl, ucr, rsr, tsr, scr));
 }


void  do_port_popup()

{
   int  index, length = 0, len;

   for (index = 0; index < num_ports; index++) {
        if (length < (len = strlen (array[index].name)))
             length = len;
      }

   for (index = 0; index < num_ports; index++) {
        port[index] = & portbuf[16 * index];
        strcpy (port[index], "  ");
        strcat (port[index], array[index].name);
        strcat (port[index], "              ");
        port[index][length + 3] = '\0';
      }
 }
