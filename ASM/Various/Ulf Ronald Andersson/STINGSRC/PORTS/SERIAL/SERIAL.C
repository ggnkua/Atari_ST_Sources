
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : Serielle Schnittstellen                      */
/*                                                                   */
/*                                                                   */
/*      Version 1.2                       vom 13. Januar 1997        */
/*                                                                   */
/*      Modul zur Installation und Aktivierung der Ports             */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "serial.h"


#define  M_YEAR    18
#define  M_MONTH   6
#define  M_DAY     18


void  cdecl   my_send (PORT *port);
void  cdecl   my_receive (PORT *port);

int           execute (int cdecl code());

void          init_vjhc (VJHC *vjhc, int16 num_states);

void          init_ppp (SERIAL_PORT *port);
void  cdecl   ppp_timer (void);
int16         open_ppp (SERIAL_PORT *port);
void          close_ppp (SERIAL_PORT *port);
void          open_ipcp (SERIAL_PORT *port);
void          close_ipcp (SERIAL_PORT *port);

int           get_cookie (long which, long *value);
long          read_cookie (void);
int           install (void);
long          find_drive_u (void);
void          add_standard_ports (void);
void          add_rsvf_ports (void);
int           find_rsvf_name (int bios, SERIAL_PORT *port, int lan);
void          init_port (int index, char *name, int bios, char *gemdos, MAPTAB *handler);
int16  cdecl  my_set_state (PORT *port, int16 state);
long          do_Fopen (void);
long          do_Fclose (void);
long          flush (void);
void          deplete_queue (IP_DGRAM **queue);
int16  cdecl  my_cntrl (PORT *port, uint32 argument, int16 code);


extern BASPAG  *_BasPag;

DRV_LIST     *sting_drivers;
TPL          *tpl;
STX          *stx;
PORT         init_dummy = {  "", L_SER_PTP, FALSE, 0L, 0xffffffffUL, 0xffffffffUL,
                             4096, 4096, 0L, NULL, 0L, NULL, 0, NULL, NULL  };
SERIAL_PORT  *my_ports = NULL;
RSVF_DEV     *rsvf_head;
DRIVER       my_driver = {  my_set_state, my_cntrl, my_send, my_receive, "Serial", "01.15",
                            (M_YEAR << 9) | (M_MONTH << 5) | M_DAY, "Peter Rottengatter",
                            NULL, NULL   };
MAPTAB       *do_flush;
int          space, ck_flag, scc, has_drv_u;
long         cookie, handle;
char         device[20] = "U:\\DEV\\";
char         fault[] = "SERIAL.STX : STinG extension module. Only to be started by STinG !\r\n";



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
          else {
             if (my_ports)   Mfree (my_ports);
           }
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


int  install()

{
   PORT    *ports;
   DRIVER  *driver;
   int     count;

   if (Bconmap (0) != 0)   return (FALSE);

   add_standard_ports();
   add_rsvf_ports();

   if (my_ports == NULL)   return (FALSE);

   if (! TIMER_call (ppp_timer, HNDLR_SET))
        return (FALSE);

   has_drv_u = (int) Supexec (find_drive_u);

   query_chains ((void **) & ports, (void **) & driver, NULL);

   my_driver.basepage = _BasPag;

   while (ports->next)
        ports = ports->next;

   for (count = 0; count < space; count++) {
        if (count)
             my_ports[count - 1].generic.next = & my_ports[count].generic;
        my_ports[count].generic.next   = NULL;
        my_ports[count].generic.driver = & my_driver;
      }
   ports->next = & my_ports[0].generic;

   while (driver->next)
        driver = driver->next;

   driver->next = & my_driver;

   return (TRUE);
 }


long  find_drive_u()

{
   return ((* (long *) 0x4c2L & 0x00100000L) ? 1L : 0L);
 }


void  add_standard_ports()

{
   BCONMAP  *map_ptr;
   int      count;
   long     machine;

   map_ptr = (BCONMAP *) Bconmap (-2);

   if (! get_cookie ('_MCH', & machine))
        machine = 0;

   switch (machine >> 16) {
      case 0 :
        space = 1;   break;
      case 1 :
        space = ((machine & 0xffffL) == 16) ? 3 : 1;   break;
      case 2 :
        space = 4;   break;
      case 3 :
        space = 3;   break;
      default :
        space = 1;
      }

   if ((my_ports = (SERIAL_PORT *) Malloc (space * sizeof (SERIAL_PORT))) == NULL)
        return;

   switch (machine >> 16) {
      case 0 :
        init_port (0, "Modem 1",   6, "MODEM1",  map_ptr->maptab);
        break;
      case 1 :
        if ((machine & 0xffffL) == 16) {
             init_port (1, "Modem 2",   7, "MODEM2",  map_ptr->maptab + 1);
             init_port (2, "Ser.2/LAN", 8, "SERIAL2", map_ptr->maptab + 2);
           }
        init_port (0, "Modem 1",   6, "MODEM1",  map_ptr->maptab);
        break;
      case 2 :
        init_port (0, "Modem 1",   6, "MODEM1",  map_ptr->maptab + 0);
        init_port (1, "Modem 2",   7, "MODEM2",  map_ptr->maptab + 1);
        init_port (2, "Serial 1",  8, "SERIAL1", map_ptr->maptab + 2);
        init_port (3, "Ser.2/LAN", 9, "SERIAL2", map_ptr->maptab + 3);
        break;
      case 3 :
        init_port (0, "Modem 1",   6, "MODEM1",  map_ptr->maptab + 0);
        init_port (1, "Modem 2",   7, "MODEM2",  map_ptr->maptab + 1);
        init_port (2, "LAN",       8, "LAN",     map_ptr->maptab + 2);
        break;
      default :
        init_port (0, "Modem 1",   6, "MODEM1",  map_ptr->maptab);
      }
 }


void  add_rsvf_ports()

{
   SERIAL_PORT  *temp;
   BCONMAP      *map_ptr;
   MAPTAB       *act_map;
   int          rest, bios, count;

   map_ptr = (BCONMAP *) Bconmap (-2);

   if (! get_cookie ('RSVF', (long *) & rsvf_head))
        rsvf_head = NULL;

   if ((rest = map_ptr->maptabsize - space) == 0 || rsvf_head == NULL)
        return;

   if ((temp = (SERIAL_PORT *) Malloc ((space + rest) * sizeof (SERIAL_PORT))) == NULL)
        return;

   memcpy (temp, my_ports, space * sizeof (SERIAL_PORT));

   Mfree (my_ports);
   my_ports = temp;

   for (bios = 0; bios < space; bios++)
        find_rsvf_name (my_ports[bios].bios_addr, & my_ports[bios], TRUE);

   for (act_map = map_ptr->maptab + space, bios = 6 + space; rest > 0; rest--, bios++) {
        init_port (space, "", bios, "", act_map++);
        if (find_rsvf_name (bios, & my_ports[space], FALSE))   space++;
      }
 }


int  find_rsvf_name (bios, port, lan)

int          bios, lan;
SERIAL_PORT  *port;

{
   RSVF_DEV  *walk;

   walk = rsvf_head;

   while (walk->miscell) {
        if ((walk->flags & RSVF_DEVICE) == 0) {
             walk = walk->miscell;
             continue;
           }
        if (walk->bios != 3 && walk->bios == bios && (lan || strcmp (walk->miscell, "LAN"))) {
             port->gemdos = walk->miscell;
             if (strcmp (walk->miscell, "MIDI") == 0)
                  port->generic.name = "Midi";
               else
                  port->generic.name = (*port->generic.name) ? port->generic.name : walk->miscell;
             if (walk->flags & RSVF_MXDDEV)
                  port->iocntl = (*((void ***) walk->miscell - 1))[7];
             return (TRUE);
           }
        walk++;
      }

   return (FALSE);
 }


void  init_port (index, name, bios, gemdos, handler)

char    *name, *gemdos;
int     index, bios;
MAPTAB  *handler;

{
   my_ports[index].generic       = init_dummy;
   my_ports[index].generic.name  = name;
   my_ports[index].bios_addr     = bios;
   my_ports[index].gemdos        = gemdos;
   my_ports[index].handler       = handler;
   my_ports[index].vjhc          = NULL;
   my_ports[index].send_buffer   = NULL;
   my_ports[index].recve_buffer  = NULL;

   my_ports[index].iocntl        = NULL;
   my_ports[index].ppp.pap_id[0] = my_ports[index].ppp.pap_passwd[0] = '\0';

   init_ppp (& my_ports[index]);
 }


int16  cdecl  my_set_state (port, state)

PORT   *port;
int16  state;

{
   SERIAL_PORT  *serial;

   if (port->driver != & my_driver)   return (FALSE);

   serial = (SERIAL_PORT *) port;
   port->flags &= ~ (FLG_DONE | FLG_SUCCESS);

   if (state) {
        if (serial->send_buffer == NULL)
             if ((serial->send_buffer = KRmalloc (8192L)) == NULL)
                  return (FALSE);
        if (serial->recve_buffer == NULL)
             if ((serial->recve_buffer = KRmalloc (8192L)) == NULL) {
                  KRfree (serial->send_buffer);
                  serial->send_buffer = NULL;
                  return (FALSE);
                }
        if (port->flags & FLG_VJHC) {
             if (serial->vjhc == NULL)
                  if ((serial->vjhc = KRmalloc (sizeof (VJHC))) == NULL) {
                       KRfree (serial->send_buffer);    serial->send_buffer = NULL;
                       KRfree (serial->recve_buffer);   serial->recve_buffer = NULL;
                       return (FALSE);
                     }
             init_vjhc (serial->vjhc, MAX_STATES);
           }
        if ((port->flags & FLG_PRTCL) != 0) {
             if (! open_ppp (serial)) {
                  KRfree (serial->vjhc);           serial->vjhc = NULL;
                  KRfree (serial->send_buffer);    serial->send_buffer = NULL;
                  KRfree (serial->recve_buffer);   serial->recve_buffer = NULL;
                  return (FALSE);
                }
           }
          else {
             port->flags |= FLG_DONE | FLG_SUCCESS;
           }
        if (strcmp (port->name, "Ser.2/LAN") == 0) {
             if (has_drv_u)
                  serial->gemdos = (port->flags & FLG_LANBIT) ? "LAN" : "SERIAL2";
               else {
                  scc = Giaccess (0, 14);
                  (port->flags & FLG_LANBIT) ? Offgibit (0x7f) : Ongibit (0x80);
                }
           }
        if (has_drv_u) {
             strcpy (& device[7], serial->gemdos);
             Supexec (do_Fopen);
             if (handle < 0)   return (FALSE);
             serial->handle = (int) handle;
           }
        serial->send_length  = serial->send_index  = 0;
        serial->recve_length = serial->recve_index = 0;
      }
     else {
        if ((port->flags & FLG_PRTCL) != 0)
             close_ppp (serial);
        if (! has_drv_u) {
             if (strcmp (port->name, "Ser.2/LAN") == 0)
                  (scc & 0x80) ? Ongibit (0x80) : Offgibit (0x7f);
           }
          else {
             handle = serial->handle;   Supexec (do_Fclose);
           }
        if (serial->send_buffer) {
             KRfree (serial->send_buffer);   serial->send_buffer = NULL;
           }
        if (serial->recve_buffer) {
             KRfree (serial->recve_buffer);  serial->recve_buffer = NULL;
           }
        if (serial->vjhc) {
             KRfree (serial->vjhc);   serial->vjhc = NULL;
           }
        deplete_queue (& port->send);
        deplete_queue (& port->receive);
      }

   do_flush = serial->handler;
   Supexec (flush);

   return (TRUE);
 }


long  do_Fopen()

{
   OSHEADER  *oshdr = * (OSHEADER **) 0x4f2L;
   BASPAG    **process, *old;

   if (oshdr->os_version >= 0x0102)
        process = oshdr->p_run;
     else
        process = (BASPAG **) (((oshdr->os_conf >> 1) == 4) ? 0x873cL : 0x602cL);

   old = *process;   *process = _BasPag;

   handle = Fopen (device, FO_RW | O_NDELAY);

   *process = old;

   return (0L);
 }


long  do_Fclose()

{
   OSHEADER  *oshdr = * (OSHEADER **) 0x4f2L;
   BASPAG    **process, *old;

   if (oshdr->os_version >= 0x0102)
        process = oshdr->p_run;
     else
        process = (BASPAG **) (((oshdr->os_conf >> 1) == 4) ? 0x873cL : 0x602cL);

   old = *process;   *process = _BasPag;

   Fclose ((int) handle);

   *process = old;

   return (0L);
 }


long  flush()

{
   while (execute (do_flush->Bconstat) != 0)
        execute ((int cdecl (*) ()) do_flush->Bconin);

   return (0L);
 }


void  deplete_queue (queue)

IP_DGRAM  **queue;

{
   IP_DGRAM  *walk, *next;

   for (walk = *queue; walk; walk = next) {
        next = walk->next;
        IP_discard (walk, TRUE);
      }

   *queue = NULL;
 }


int16  cdecl  my_cntrl (port, argument, code)

PORT    *port;
uint32  argument;
int16   code;

{
   SERIAL_PORT  *serial;
   int16        status, result = E_FNAVAIL;

   serial = (SERIAL_PORT *) port;
   status = ((port->flags & FLG_PRTCL) && port->active) ? TRUE : FALSE;

   switch (code) {
      case CTL_SERIAL_SET_PRTCL :
        if ((argument & FLG_LANBIT) && strcmp (port->name, "Ser.2/LAN"))
             return (E_PARAMETER);
        if (argument & ~(FLG_PRTCL | FLG_VJHC | FLG_LANBIT | FLG_DNS))
             return (E_PARAMETER);
        port->flags = port->flags & ~(FLG_PRTCL | FLG_VJHC | FLG_LANBIT | FLG_DNS) | argument;
        result = E_NORMAL;
        break;
      case CTL_SERIAL_GET_PRTCL :
        * (uint16 *) argument = (uint16) port->flags & (FLG_PRTCL | FLG_VJHC | FLG_LANBIT | FLG_DNS);
        result = E_NORMAL;
        break;
      case CTL_SERIAL_SET_LOGGING :
        if (* (long *) argument) {
             serial->log_buffer = * (char **) argument;
             serial->log_len = (uint16) ((uint32 *) argument)[1];
             serial->log_ptr = 0;
             port->flags |= FLG_LOGGING;
           }
          else {
             * (uint32 *) argument = serial->log_ptr;
             port->flags &= ~ FLG_LOGGING;
           }
        result = E_NORMAL;
        break;
      case CTL_SERIAL_SET_AUTH :
        if (argument) {
             serial->ppp.pap_ack = ((char **) argument)[0];
             serial->ppp.pap_nak = ((char **) argument)[1];
             serial->ppp.pap_auth = & ((char **) argument)[2];
             port->flags |= FLG_REQU_AUTH;
           }
          else {
             serial->ppp.pap_ack = serial->ppp.pap_nak = NULL;
             serial->ppp.pap_auth = NULL;
             port->flags &= ~ FLG_REQU_AUTH;
           }
        result = E_NORMAL;
        break;
      case CTL_SERIAL_SET_PAP :
        if (((char **) argument)[0] == NULL || ((char **) argument)[1] == NULL)
             port->flags &= ~ FLG_ALLOW_PAP;
          else {
             if (strlen (((char **) argument)[0]) > 127 || strlen (((char **) argument)[1]) > 127)
                  return (E_BIGBUF);
             strcpy (& serial->ppp.pap_id[0],     ((char **) argument)[0]);
             strcpy (& serial->ppp.pap_passwd[0], ((char **) argument)[1]);
             port->flags |= FLG_ALLOW_PAP;
           }
        result = E_NORMAL;
        break;
      case CTL_SERIAL_INQ_STATE :
        if (*((int16 *) argument) == 0) {
             if ((port->flags & FLG_DONE) != 0)
                  *((int16 *) argument) = (port->flags & FLG_SUCCESS) ? 1 : -1;
               else
                  *((int16 *) argument) = 0;
           }
          else
             /* return PPP status */;
        result = E_NORMAL;
        break;
      case CTL_GENERIC_SET_MTU :
        if (argument < 68 || argument > port->max_mtu)
             return (E_PARAMETER);
        if (status) {
             close_ppp (serial);   port->mtu = (int16) argument;   open_ppp (serial);
           }
          else
             port->mtu = (int16) argument;
        result = E_NORMAL;
        break;
      case CTL_GENERIC_SET_IP :
        if (status) {
             close_ipcp (serial);   port->ip_addr = argument;   open_ipcp (serial);
           }
          else
             port->ip_addr = argument;
        result = E_NORMAL;
        break;
      }

   return (result);
 }
