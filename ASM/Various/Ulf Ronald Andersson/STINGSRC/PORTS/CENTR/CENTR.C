
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : Centronics Schnittstelle                     */
/*                                                                   */
/*      Version 0.2                        vom 28. Januar 1997       */
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

#define  SLIP_END       '\300'
#define  SLIP_ESC       '\333'
#define  SLIP_DATEND    '\334'
#define  SLIP_DATESC    '\335'

#define  SEMA_RECVE     0


void           send_dgram (void);
void           recve_dgram (void);

long           get_sting_cookie (void);
int16          install (void);
int16   cdecl  my_set_state (PORT *port, int16 state);
int16   cdecl  my_cntrl (PORT *port, uint32 argument, int16 code);
void    cdecl  my_send (PORT *port);
int16          slip_out (uint8 *dest, uint8 *source, int16 length);
void    cdecl  my_receive (PORT *port);
void           process_datagram (void);


DRV_LIST  *sting_drivers;
TPL       *tpl;
STX       *stx;
IP_DGRAM  *pending[8];
int16     sending, send_pend, receiving, recve_pend;
int16     send_length, recve_length;
uint8     *send_buffer, *recve_buffer;
uint16    timeout, rcv_max_length;
PORT      my_port   = {  "Centronics", L_PAR_PTP, FALSE, 0L, 0xffffffffUL, 0xffffffffUL,
                         8192, 8192, 0L, NULL, 0L, NULL, 0, NULL, NULL  };
DRIVER    my_driver = {  my_set_state, my_cntrl, my_send, my_receive, "Centronics", "00.02",
                         (M_YEAR << 9) | (M_MONTH << 5) | M_DAY, "Peter Rottengatter",
                         NULL, NULL   };
char      fault[] = "CENTR.STX : STinG extension module. Only to be started by STinG !\r\n";



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

   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L)   return;

   if (strcmp (sting_drivers->magic, MAGIC) != 0)
        return;

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        if (install())
             Ptermres (_PgmSize, 0);
      }
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


int16  install()

{
   PORT    *ports;
   DRIVER  *driver;

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


int16  cdecl  my_set_state (port, state)

PORT   *port;
int16  state;

{
   if (port != & my_port)   return (FALSE);

   if (state) {
        sending    = 0;
        send_pend  = FALSE;
        receiving  = FALSE;
        recve_pend = 0;
      }
     else {
      }

   return (TRUE);
 }


int16  cdecl  my_cntrl (port, argument, code)

PORT    *port;
uint32  argument;
int16   code;

{
   return (E_FNAVAIL);
 }


void  cdecl  my_send (port)

PORT  *port;

{
   IP_DGRAM  *dgram;
   int16     count;
   uint8     *work, *src;

   if (port->driver != & my_driver || ! port->active)
        return;

   if (sending) {
        if (--sending == 0)   recve_dgram();
        return;
      }

   if (send_pend) {
        if (! receiving)   send_dgram();
        return;
      }

   send_length = 0;

   do {
        if ((dgram = my_port.send) == NULL)
             return;
        my_port.send = dgram->next;
     } while (check_dgram_ttl (dgram) != E_NORMAL);

   work = send_buffer;

   work += slip_out (work, (uint8 *) & dgram->hdr, 20);
   work += slip_out (work, dgram->options, dgram->opt_length);
   work += slip_out (work, dgram->pkt_data, dgram->pkt_length);
   *work++ = SLIP_END;

   IP_discard (dgram, TRUE);

   my_port.stat_sd_data += (send_length = work - send_buffer);

   if (receiving)
        send_pend = TRUE;
     else
        send_dgram();
 }


int16  slip_out (destination, source, length)

uint8  *destination, *source;
int16  length;

{
   int  count = 0;

   while (length--) {
        switch (*source) {
           case SLIP_END :
             *destination++ = SLIP_ESC;   *destination++ = SLIP_DATEND;
             count += 2;   break;
           case SLIP_ESC :
             *destination++ = SLIP_ESC;   *destination++ = SLIP_DATESC;
             count += 2;   break;
           default :
             *destination++ = *source;   count++;
           }
        source++;
      }

   return (count);
 }


void  cdecl  my_receive (port)

PORT  *port;

{
   IP_DGRAM  *array[8], *walk, **previous;
   int16     num_entry, count;

   if (port->driver != & my_driver || ! port->active)
        return;

   if (recve_pend == 0)   return;

   if (set_flag (SEMA_RECVE))
        return;
   memcpy (array, pending, (num_entry = recve_pend) * sizeof (IP_DGRAM *));
   recve_pend = 0;
   clear_flag (SEMA_RECVE);

   for (count = 0; count < num_entry - 1; count++)
        array[count]->next = array[count+1];
   array[count]->next = NULL;

   for (walk = *(previous = & my_port.receive); walk; walk = *(previous = &walk->next));
   *previous = array[0];
 }


void  process_datagram()

{
   IP_DGRAM  *dgram, *walk, **previous;
   uint16    len;
   uint8     *p_read, *p_write, *p_last;

   p_write = recve_buffer;

   for (p_last = (p_read = p_write) + recve_length; p_read < p_last; ) {
        if (*p_read == SLIP_ESC)
             switch (*++p_read) {
                case SLIP_DATEND :   *p_read = SLIP_END;   break;
                case SLIP_DATESC :   *p_read = SLIP_ESC;   break;
                }
        *p_write++ = *p_read++;
      }
   my_port.stat_rcv_data += recve_length;

   if ((len = p_write - recve_buffer) < sizeof (IP_HDR)) {
        my_port.stat_dropped++;
        return;
      }
   if ((dgram = KRmalloc (sizeof (IP_DGRAM))) == NULL) {
        my_port.stat_dropped++;
        return;
      }
   memcpy (& dgram->hdr, recve_buffer, sizeof (IP_HDR));

   if (dgram->hdr.length != len || dgram->hdr.hd_len < 5 || dgram->hdr.hd_len * 4 > len) {
        KRfree (dgram);
        my_port.stat_dropped++;
        return;
      }
   dgram->options  = KRmalloc (dgram->opt_length = dgram->hdr.hd_len * 4 - sizeof (IP_HDR));
   dgram->pkt_data = KRmalloc (dgram->pkt_length = len - dgram->hdr.hd_len * 4);

   if (dgram->options == NULL || dgram->pkt_data == NULL ) {
        IP_discard (dgram, TRUE);
        my_port.stat_dropped++;
        return;
      }
   memcpy (dgram->options, recve_buffer + sizeof (IP_HDR), dgram->opt_length);
   memcpy (dgram->pkt_data, recve_buffer + dgram->hdr.hd_len * 4, dgram->pkt_length);

   dgram->recvd = & my_port;
   set_dgram_ttl (dgram);

   if (! set_flag (SEMA_RECVE)) {
        if (recve_pend < 8) {
             pending[recve_pend++] = dgram;
           }
          else {
             IP_discard (dgram, TRUE);   my_port.stat_dropped++;
           }
        clear_flag (SEMA_RECVE);
      }
     else {
        IP_discard (dgram, TRUE);   my_port.stat_dropped++;
      }
 }
