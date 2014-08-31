
/*********************************************************************/
/*                                                                   */
/*     STinG : Save-IP Network Tool                                  */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                       from 18. October 1997      */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"


long  get_sting_cookie (void);
void  do_some_work (void);


DRV_LIST    *sting_drivers;
STX         *stx;

char  *path, port_name[32] = "";

char  arguments[] = "[1][ |  Two arguments : File and port   ][ Ok ]";
char  not_there[] = "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STinG structures corrupted !   ][ Oooops ]";
char  no_open[]   = "[1][ |  Can't create file \'IP.INF\' !   ][ Shit ]";



void main (argc, argv)

int   argc;
char  *argv[];

{
   int  count;

   appl_init();

   if (argc < 3) {
        form_alert (1, arguments);
        return;
      }

   path = argv[1];

   for (count = 2; count < argc; count++) {
        strcat (port_name, argv[count]);
        if (count < argc - 1)   strcat (port_name, " ");
      }

   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L) {
        form_alert (1, not_there);
        return;
      }
   if (strcmp (sting_drivers->magic, MAGIC) != 0) {
        form_alert (1, corrupted);
        return;
      }

   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (stx != (STX *) NULL)   do_some_work();

   appl_exit();
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
   PORT    *chain;
   uint32  ip;
   int16   file;
   void    *dummy;
   char    *name, ip_addr[20];

   if (path[1] == ':') {
        Dsetdrv (path[0] - 'A');   path = & path[2];
      }

   name = path;

   if (strrchr (path, '\\') == NULL)
        Dsetpath ("\\");
     else {
        * ((name = strrchr (path, '\\') + 1) - 1) = '\0';
        Dsetpath (path);
      }

   if ((file = (int16) Fcreate (name, 0)) < 0) {
        form_alert (1, no_open);
        return;
      }

   query_chains ((void **) & chain, & dummy, & dummy);

   while (chain != NULL) {
        if (strcmp (chain->name, port_name) == 0) {
             ip = chain->ip_addr;
             sprintf (ip_addr, "%ld.%ld.%ld.%ld\r\n", (ip >> 24) & 0xff, (ip >> 16) & 0xff, (ip >> 8) & 0xff, ip & 0xff);
             Fwrite (file, strlen (ip_addr), ip_addr);
           }
        chain = chain->next;
      }

   Fclose (file);
 }
