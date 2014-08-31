
/*********************************************************************/
/*                                                                   */
/*     This program pretents being a Dialer server, so that it       */
/*      can be connected to by a dial client. It's there to show     */
/*      how the remote control dialing facility works.               */
/*                                                                   */
/*     (c) Peter Rottengatter              from 16. Januar 1997      */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <time.h>
#include <string.h>

#include "transprt.h"
#include "remctrl.h"


#define  TIMEOUT   60


void  gem_program (void),  do_some_work (void);
long  get_sting_cookie (void);

DRV_LIST   *sting_drivers;
TPL        *tpl;
char       alert[200];
int        gl_apid;

char  not_there[] = "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STinG structures corrupted !   ][ Oooops ]";
char  found_it[]  = "[3][ |  Driver \'%s\',|  by %s, found,   |  version %s.][ Okay ]";
char  no_module[] = "[1][ |  STinG Transport Driver not found !   ][ Grmbl ]";
char  query[]     = "[3][ |  Dialing request using script file   |    \'%s\',|    up to %d tries !   ][ Done | Error ]";
char  number[]    = "[2][ |  Parameter is %d. Wanna change it ?   ][ < | Okay | > ]";
char  hangup[]    = "[3][ |  Hang up request received !   ][ Okay ]";
char  proceed[]   = "[2][ |  Proceed faking a dialer ?   ][ Proceed | Abort ]";
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
   NDB     *ndb;
   time_t  timeout;
   int     handle, message[2], response, ready;

   if ((handle = UDP_open (0, IP_DIALER_PORT)) < 0) {
        form_alert (1, no_udp);
        return;
      }

   for (;;) {

        timeout = time (NULL) + TIMEOUT;

        do {
             evnt_timer (200, 0);

             if ((ndb = CNget_NDB (handle)) != NULL) {
                  switch (* (int16 *) ndb->ndata) {
                     case IP_DIAL_REQUEST :
                       sprintf (alert, query, ndb->ndata + 4, * (int16 *) (ndb->ndata + 2));
                       if (form_alert (1, alert) == 1)
                            message[0] = IP_DIAL_DONE,  message[1] = 0;
                         else {
                            message[0] = IP_DIAL_ERROR;
                            response = 0;
                            do {
                                 sprintf (alert, number, response);
                                 ready = 0;
                                 switch (form_alert (1, alert)) {
                                    case 1 :   response --;   break;
                                    case 2 :   ready = 1;     break;
                                    case 3 :   response ++;   break;
                                    }
                              } while (! ready);
                            message[1] = response;
                          }
                       break;
                     case IP_DIAL_HANGUP :
                       form_alert (1, hangup);
                       message[0] = IP_DIAL_DONE;
                       message[1] = 0;
                       break;
                     }
                  KRfree (ndb->ptr);
                  KRfree (ndb);
                  UDP_send (handle, (char *) message, 4);
                  UDP_close (handle);

                  if ((handle = UDP_open (0, IP_DIALER_PORT)) < 0) {
                       form_alert (1, no_udp);
                       return;
                     }
                }
          } while (time (NULL) < timeout);

        if (form_alert (1, proceed) != 1)   break;
      }

   UDP_close (handle);
 }
