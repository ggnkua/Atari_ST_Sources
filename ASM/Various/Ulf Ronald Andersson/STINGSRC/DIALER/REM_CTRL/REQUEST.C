
/*********************************************************************/
/*                                                                   */
/*     This program requests remote control dialing from a Dialer    */
/*      server. It serves as sample code for programmers.            */
/*                                                                   */
/*     (c) Peter Rottengatter              from 16. Januar 1997      */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#include "transprt.h"
#include "remctrl.h"


#define  DIAL_SCRIPT        "DIAL.SCR"
#define  DIAL_MAX_NUMBER    5
#define  TIMEOUT            60


void  gem_program (void),  do_some_work (void);
long  get_sting_cookie (void);


typedef int  BOOLEAN;

DRV_LIST   *sting_drivers;
TPL        *tpl;
char       alert[200];
int        gl_apid;
int        errors[] = {  9, 
                         IP_USER_ABORT, IP_IN_PROGRESS, IP_IS_CONNECTED,
                         IP_SCR_NOT_FOUND, IP_MAX_EXCEEDED, IP_FATAL_PROBLEM,
                         IP_OPEN_FAILED, IP_PORT_LOCKED
                      };

char  not_there[] = "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STinG structures corrupted !   ][ Oooops ]";
char  found_it[]  = "[3][ |  Driver \'%s\',|  by %s, found,   |  version %s.][ Okay ]";
char  no_module[] = "[1][ |  STinG Transport Driver not found !   ][ Grmbl ]";
char  no_dialer[] = "[1][ |  STinG variable DIALER not set !   ][ Grrr ]";
char  not_start[] = "[1][ |  Dialer is not running !   ][ Forgot ]";
char  begin_it[]  = "[3][ |  Dialer found. Sending dial request.   ][ Good ]";
char  waiting[]   = "[3][ |  Waiting %d seconds for a response.   ][ Do it ]";
char  dial_error_text[][70] = { "",
                    "[1][ |  Dial error :| |    User aborted dialing !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Dialing already in progress !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Already connected !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Script not found !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Redials exceed max number !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Modem reports fatal problem !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Can't pass port to STinG !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Can't open serial port !   ][ Uhmmm ]"
               };
char  success[]   = "[3][ |  Dialing done. Connection established.   ][ Well done ]";
char  other_err[] = "[1][ |  Dialer reports an error.   | |    Code unknown !][ Hey ]";
char  timer_qu[]  = "[2][ |  Wait timeout expired.| |    Give it some more time ?   ][ Yes | Abort ]";
char  no_rslv[]   = "[1][ |  Attempt to resolve hostname   | |    failed !][ Piss off ]";
char  bad_ip[]    = "[1][ |  Wrong format in IP address !  ][ F... ]";
char  no_udp[]    = "[1][ |  Couldn't open UDP connection !  ][ Hmm ]";



void  main()

{
   gl_apid = appl_init();

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
   NDB      *ndb;
   uint32   rhost;
   time_t   timeout;
   int      count, handle, message[12], abort;
   char     *walk, dialer_name[64];

   strncpy (dialer_name, getvstr ("DIALER"), 64);

   if (strcmp (dialer_name, "0") == 0) {
        form_alert (1, no_dialer);
        return;
      }

   if (atoi (dialer_name) == 0) {
        if (resolve (dialer_name, NULL, &rhost, 1) <= 0) {
             form_alert (1, no_rslv);
             return;
           }
      }
     else {
        for (count = 0, walk = dialer_name; count < 4; count++) {
             rhost = (rhost << 8) | atoi (walk);
             if (count < 3) {
                  if ((walk = strchr (walk, '.') + 1) == (void *) 1L) {
                       form_alert (1, bad_ip);
                       return;
                     }
                }
               else {
                  if (strchr (walk, '.') != NULL) {
                       form_alert (1, bad_ip);
                       return;
                     }
                }
           }
      }

   if ((handle = UDP_open (rhost, IP_DIALER_PORT)) < 0) {
        form_alert (1, no_udp);
        return;
      }

   form_alert (1, begin_it);

   message[0] = IP_DIAL_REQUEST;
   message[1] = DIAL_MAX_NUMBER;
   strncpy ((char *) & message[2], DIAL_SCRIPT, 18);
   message[11] = 0;

   UDP_send (handle, (char *) message, 24);

   sprintf (alert, waiting, (int) TIMEOUT);
   form_alert (1, alert);

   timeout = time (NULL) + TIMEOUT;

/**/
/*   Note that in case of IP_DIAL_ERROR : IP_OPEN_FAILED  a connection has been
/*      established. If IP_DIAL_HANGUP is not used, your telephone bill will
/*      start to grow ! ;-)
/**/

   for (abort = 0; abort == 0;) {
        evnt_timer (200, 0);
        if ((ndb = CNget_NDB (handle)) != NULL) {
             switch (* (int16 *) ndb->ndata) {
                case IP_DIAL_DONE :
                  form_alert (1, success);
                  abort = 1;
                  break;
                case IP_DIAL_ERROR :
                  for (count = 1; count < errors[0]; count++)
                       if (errors[count] == * (int16 *) (ndb->ndata + 2))
                            break;
                  form_alert (1, (count == errors[0]) ? other_err : dial_error_text[count]);
                  abort = 1;
                  break;
                }
           }
        if (time (NULL) > timeout) {
             if (form_alert (1, timer_qu) == 2)
                  abort = 1;
               else
                  timeout = time (NULL) + TIMEOUT;
           }
      }

   UDP_close (handle);
 }
