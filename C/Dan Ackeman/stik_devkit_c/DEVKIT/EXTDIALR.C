

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "transprt.h"


#define  DIALER             'IP'
#define  IP_DIAL_REQUEST    (DIALER + 0)
#define  IP_DIAL_HANGUP     (DIALER + 1)
#define  IP_DIAL_DONE       (DIALER + 2)
#define  IP_DIAL_ERROR      (DIALER + 3)

#define  DIAL_SCRIPT        "dial.scr"
#define  DIAL_MAX_NUMBER    10
#define  TIMEOUT            10


void  gem_program (void),  do_some_work (void);
long  get_stik_cookie (void);

DRV_LIST   *stik_drivers;
TPL        *tpl;
char       alert[200];
int        gl_apid;

char  not_there[] = "[1][ |  STiK is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STiK structures corrupted !   ][ Oooops ]";
char  found_it[]  = "[3][ |  Driver \'%s\',|  by %s, found,   |  version %s.][ Okay ]";
char  no_module[] = "[1][ |  STiK Transport Driver not found !   ][ Grmbl ]";
char  no_dialer[] = "[1][ |  STiK variable DIALER not set !   ][ Grrr ]";
char  not_start[] = "[1][ |  Dialer is not running !   ][ Forgot ]";
char  begin_it[]  = "[3][ |  Dialer found. Sending dial request.   ][ Good ]";
char  waiting[]   = "[3][ |  Waiting %d seconds for a response.   ][ Do it ]";
char  dial_error_text[][70] = { "",
                    "[1][ |  Dial error :| |    Script not found !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Redials exceed max number !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Modem reports fatal problem !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    User aborted dialing !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Dialing already in progress !   ][ Uhmmm ]",
                    "[1][ |  Dial error :| |    Already connected !   ][ Uhmmm ]"
               };
char  success[]   = "[3][ |  Dialing done. Connection established.   ][ Well done ]";
char  other_err[] = "[1][ |  Dialer reports an error.   | |  Code unknown !][ Hey ]";
char  timer_qu[]  = "[2][ |  Wait timeout expired.| |    Give it some more time ?   ][ Yes | Abort ]";
char  abort_qu[]  = "[2][ |  Wanna abort waiting for response ?   ][ Yes | Continue ]";



void  main()

{
   gl_apid = appl_init();

   gem_program();

   appl_exit();
 }


void  gem_program()

{
   stik_drivers = (DRV_LIST *) Supexec (get_stik_cookie);

   if (stik_drivers == 0L) {
        form_alert (1, not_there);
        return;
      }
   if (strcmp (stik_drivers->magic, MAGIC) != 0) {
        form_alert (1, corrupted);
        return;
      }

   tpl = (TPL *) (*stik_drivers->get_dftab) (TRANSPORT_DRIVER);

   if (tpl != (TPL *) NULL) {
        sprintf (alert, found_it, tpl->module, tpl->author, tpl->version);
        form_alert (1, alert);
        do_some_work();
      }
     else
        form_alert (1, no_module);
 }


long  get_stik_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


void  do_some_work()

{
   int   count, dialer_apid, message[8], abort, event, dummy;
   long  timeout;
   char  dialer_name[9], dial_script_name[] = DIAL_SCRIPT;

   strncpy (dialer_name, getvstr ("DIALER"), 9);
   dialer_name[8] = '\0';

   if (strcmp (dialer_name, "0") == 0) {
        form_alert (1, no_dialer);
        return;
      }

   for (count = (int) strlen (dialer_name); count < 8; count++)
        dialer_name[count] = ' ';

   for (count = 0; count < 8; count++)
        dialer_name[count] = toupper (dialer_name[count]);

   dialer_apid = appl_find (dialer_name);

   if (dialer_apid < 0) {
        form_alert (1, not_start);
        return;
      }

   form_alert (1, begin_it);

   message[0] = IP_DIAL_REQUEST;
   message[1] = gl_apid;
   message[2] = 0;
   *(char **) &message[3] = dial_script_name;
   message[5] = DIAL_MAX_NUMBER;
   for (count = 6; count < 8; count++)   message[count] = 0;

   appl_write (dialer_apid, 16, message);

   timeout = TIMEOUT * 1000L;

   sprintf (alert, waiting, (int) (timeout / 1000));
   form_alert (1, alert);

   for (abort = 0; abort == 0;) {
        event = evnt_multi (MU_MESAG | MU_TIMER | MU_BUTTON, 1,3,3, 0,0,0,0,0,
                       0,0,0,0,0, message, (unsigned int) (timeout & 0xffff), 
                       (unsigned int) (timeout >> 16), &dummy, &dummy, &dummy,
                       &dummy, &dummy, &dummy);

        if (event & MU_MESAG)
             switch (message[0]) {
                case IP_DIAL_DONE :
                  form_alert (1, success);
                  abort = 1;
                  break;
                case IP_DIAL_ERROR :
                  if (message[3] < 1 || 6 < message[3])
                       form_alert (1, other_err);
                    else
                       form_alert (1, dial_error_text[message[3]]);
                  abort = 1;
                  break;
                }
        if (event & MU_TIMER)
             if (form_alert (1, timer_qu) == 2)   abort = 1;

        if (event & MU_BUTTON)
             if (form_alert (1, abort_qu) == 1)   abort = 1;
      }
 }
