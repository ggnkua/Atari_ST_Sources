
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : LocalTalk Bus Schnittstelle                  */
/*                                                                   */
/*      Version 0.1                      vom 18. Dezember 1996       */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"


#define  M_YEAR    18
#define  M_MONTH   6
#define  M_DAY     18


int            get_cookie (long which, long *value);
long           read_cookie (void);
int16          install (void);
void    cdecl  my_send (PORT *port);
void    cdecl  my_receive (PORT *port);
int16   cdecl  my_set_state (PORT *port, int16 state);
int16   cdecl  my_cntrl (PORT *port, uint32 argument, int16 code);


DRV_LIST  *sting_drivers;
TPL       *tpl;
STX       *stx;
PORT      my_port   = {  "LocalTalk", L_SER_BUS, FALSE, 0L, 0xffffffffUL, 0xffffffffUL,
                         4096, 4096, 0L, NULL, 0L, NULL, 0, NULL, NULL  };
DRIVER    my_driver = {  my_set_state, my_cntrl, my_send, my_receive, "LocalTalk", "00.01",
                         (M_YEAR << 9) | (M_MONTH << 5) | M_DAY, "Unknown Programmer",
                         NULL, NULL   };
int       ck_flag;
long      cookie;
char      fault[] = "LCLTLK.STX : STinG extension module. Only to be started by STinG !\r\n";



void  main (argc, argv)

int   argc;
char  *argv[];

{
   if (argc != 2) {
        Cconws (fault);   return;
      }
   if (strcmp (argv[1], "STinG_Load") != 0) {
        Cconws (fault);   return;
      }

   if (! get_cookie ('STiK', (long *) & sting_drivers))
        return;

   if (sting_drivers == NULL)   return;

   if (strcmp (sting_drivers->magic, MAGIC) != 0)
        return;

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        if (install())
             Ptermres (_PgmSize, 0);
      }
 }


int  get_cookie (which, value)

long  which, *value;

{
   cookie = which;
   *value = Supexec (read_cookie);

   return (ck_flag);
 }


long  read_cookie()

{
   long  *work;

   ck_flag = FALSE;

   if (* (long **) 0x5a0L == NULL)
        return (0L);

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == cookie) {
             ck_flag = TRUE;   return (*++work);
           }

   return (-1L);
 }


int16  install()

{
   PORT    *ports;
   DRIVER  *driver;
   long    machine;

   if (! get_cookie ('_MCH', & machine))
        return (FALSE);

   if ((machine >> 16) < 1 || 3 < (machine >> 16))
        return (FALSE);

   if ((machine >> 16) == 1 && (machine & 0xffffL) != 16)
        return (FALSE);

   query_chains ((void **) & ports, (void **) & driver, NULL);

   (my_port.driver = & my_driver)->basepage = _BasPag;

   while (ports->next)
        ports = ports->next;

   ports->next = & my_port;

   while (driver->next)
        driver = driver->next;

   driver->next = & my_driver;

   return (TRUE);
 }


void  cdecl  my_send (port)

PORT  *port;

{
   if (port != & my_port)   return;
 }


void  cdecl  my_receive (port)

PORT  *port;

{
   if (port != & my_port)   return;
 }


int16  cdecl  my_set_state (port, state)

PORT   *port;
int16  state;

{
   if (port != & my_port)   return (FALSE);

   return (TRUE);
 }


int16  cdecl  my_cntrl (port, argument, code)

PORT    *port;
uint32  argument;
int16   code;

{
   return (E_FNAVAIL);
 }
