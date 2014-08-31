
/*********************************************************************/
/*                                                                   */
/*     STinG : Ping Network Tool                                     */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                        from 16. Januar 1997      */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "transprt.h"
#include "ping.h"


#define  ICMP_ECHO_REPLY      0
#define  ICMP_ECHO            8


void          gem_program (void);
long          get_sting_cookie (void);
void          do_some_work (void);
void          fetch_parameters (void);
void          send_echo (void);
int16  cdecl  receive_echo (IP_DGRAM *datagram);
long          fetch_clock (void);


typedef int  BOOLEAN;

DRV_LIST  *sting_drivers;
TPL       *tpl;
uint16    sent, received, min, ave, max, num_packets;
uint32    host;
char      alert[200];
char  not_there[] = "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STinG structures corrupted !   ][ Oooops ]";
char  found_it[]  = "[3][ |  Driver \'%s\',|  by %s, found,   |  version %s.][ Okay ]";
char  no_module[] = "[1][ |  STinG Transport Driver not found !   ][ Grmbl ]";
char  takes[]     = "[3][ |  This will take a little more   | |    than %d seconds.][ Okay ]";
char  first[]     = "[3][  Ping Actions :| |    %u packets sent, %u received;   |    %ld %% lost.][ Okay ]";
char  second[]    = "[3][  Ping Time Statistics :   | |    Minimum %5ld ms|    Average %5ld ms|    Maximum %5ld ms][ Okay ]";



void  main()

{
   appl_init();

   if (rsrc_load ("PING.RSC") == 0)
        form_alert (1, "[1][ No RSC File !  ][ Hmpf ]");
     else
        gem_program();

   appl_exit();
 }


void  gem_program()

{
   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L) {
        form_alert (1, not_there);
        return;
      }
   if (strcmp (sting_drivers->magic, MAGIC) != 0) {
        form_alert (1, corrupted);
        return;
      }

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);

   if (tpl != (TPL *) NULL) {
        sprintf (alert, found_it, tpl->module, tpl->author, tpl->version);
        form_alert (1, alert);
        do_some_work();
      }
     else
        form_alert (1, no_module);
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


void  do_some_work()

{
   int  count;

   fetch_parameters();

   if (host == 0 || num_packets == 0)
        return;

   sprintf (alert, takes, (num_packets + 1) / 10);
   form_alert (1, alert);

   sent = received = 0;
   min = 50000u;   ave = max = 0;

   if (! ICMP_handler (receive_echo, HNDLR_SET))
        return;

   for (count = 0; count < num_packets; count++) {
        send_echo();
        evnt_timer (100, 0);
      }

   for (count = 0; count < 50 && received != sent; count++)
        evnt_timer (200, 0);

   ICMP_handler (receive_echo, HNDLR_REMOVE);

   sprintf (alert, first, sent, received, (sent - received) * 100L / sent);
   form_alert (1, alert);

   if (received) {
        sprintf (alert, second, min * 5L, ave * 5L / received, max * 5L);
        form_alert (1, alert);
      }
 }


void  fetch_parameters()

{
   OBJECT  *tree;
   char    *txt;
   int     x, y, w, h, c_x, c_y;

   graf_mouse (ARROW, NULL);

   rsrc_gaddr (R_TREE, PING, &tree);

   wind_update (BEG_UPDATE);

   form_center (tree, &x, &y, &w, &h);
   c_x = x + w / 2;   c_y = y + h / 2;
   form_dial (FMD_START, c_x, c_y, 0, 0, x, y, w, h);
   form_dial (FMD_GROW,  c_x, c_y, 0, 0, x, y, w, h);

   strcpy (tree[HOST].ob_spec.tedinfo->te_ptext, "127  0  0  1");
   strcpy (tree[NUM ].ob_spec.tedinfo->te_ptext, "50");

   objc_draw (tree, ROOT, MAX_DEPTH, x, y, w, h);
   form_do (tree, HOST);

   form_dial (FMD_SHRINK, c_x, c_y, 0, 0, x, y, w, h);
   form_dial (FMD_FINISH, c_x, c_y, 0, 0, x, y, w, h);

   wind_update (END_UPDATE);

   num_packets = atoi (tree[NUM].ob_spec.tedinfo->te_ptext);
   txt = tree[HOST].ob_spec.tedinfo->te_ptext;
   txt[12] = '\0';   h = atoi (&txt[9]);
   txt[ 9] = '\0';   w = atoi (&txt[6]);
   txt[ 6] = '\0';   y = atoi (&txt[3]);
   txt[ 3] = '\0';   x = atoi (&txt[0]);
   host = ((uint32) x << 24) | ((uint32) y << 16) | ((uint32) w << 8) | (uint32) h;
 }


void  send_echo()

{
           uint16  buffer[16];
   static  uint16  sequence = 0;

   buffer[0] = 0xaffeu;   buffer[1] = sequence++;
   * (long *) &buffer[2] = Supexec (fetch_clock);

   buffer[4] = 0xa5a5u;   buffer[5] = 0x5a5au;
   buffer[6] = 0x0f0fu;   buffer[7] = 0xf0f0u;

   ICMP_send (host, ICMP_ECHO, 0, buffer, 32);

   sent++;
 }


int16  cdecl  receive_echo (datagram)

IP_DGRAM  *datagram;

{
   uint16  *data, delay;

   data = datagram->pkt_data;

   if (data[0] != (ICMP_ECHO_REPLY << 8) || data[2] != 0xaffeu)
        return (FALSE);

   received++;
   delay = (uint16) (fetch_clock() - * (long *) &data[4]);

   if (min > delay)   min = delay;
   if (max < delay)   max = delay;
   ave += delay;

   ICMP_discard (datagram);

   return (TRUE);
 }


long  fetch_clock()

{
   return (* (long *) 0x4baL);
 }
