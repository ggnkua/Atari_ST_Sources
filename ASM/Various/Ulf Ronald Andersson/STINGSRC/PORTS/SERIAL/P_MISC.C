
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : Serielle Schnittstellen                      */
/*                                                                   */
/*                                                                   */
/*      Version 0.1                         vom 16. Juli 1997        */
/*                                                                   */
/*      Modul zum PPP Control Protocol Handling                      */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "serial.h"


void         set_dtr (void *hsm_code, int new_dtr);
int          inq_cd (void *hsm_code);
long         choose_magic (void);

void         user_event (SERIAL_PORT *port, int event, MACHINE *machine);
void         timer_event (SERIAL_PORT *port, MACHINE *machine);
void         network_event (SERIAL_PORT *port, MACHINE *machine);

void         ppp_dummy (SERIAL_PORT *port, int16 flag);

void         lcp_up_down (SERIAL_PORT *port, int16 flag);
void         lcp_do_lower (SERIAL_PORT *port, int16 flag);
void         lcp_create (SERIAL_PORT *port);
int16        lcp_nego (SERIAL_PORT *port, uint8 *own, uint8 *source, uint8 *modified);
int16        lcp_imple (SERIAL_PORT *port, uint8 *option);
int16        lcp_options (SERIAL_PORT *port, uint8 *source, uint8 *modified);
void         lcp_accept (SERIAL_PORT *port, uint8 *option);

void         ipcp_up_down (SERIAL_PORT *port, int16 flag);
void         ipcp_create (SERIAL_PORT *port);
int16        ipcp_nego (SERIAL_PORT *port, uint8 *own, uint8 *source, uint8 *modified);
int16        ipcp_imple (SERIAL_PORT *port, uint8 *option);
int16        ipcp_options (SERIAL_PORT *port, uint8 *source, uint8 *modified);
void         ipcp_accept (SERIAL_PORT *port, uint8 *option);

void         pap_up_down (SERIAL_PORT *port, int16 flag);
void         pap_create (SERIAL_PORT *port);
int16        pap_nego (SERIAL_PORT *port, uint8 *own, uint8 *source, uint8 *modified);
int16        pap_imple (SERIAL_PORT *port, uint8 *option);
int16        pap_options (SERIAL_PORT *port, uint8 *source, uint8 *modified);
void         pap_accept (SERIAL_PORT *port, uint8 *option);

void         init_ppp (SERIAL_PORT *port);
int          send_cp (SERIAL_PORT *port, uint16 protocol, uint8 code, uint8 ident, 
                          uint16 length, uint8 *options);
void  cdecl  ppp_timer (void);
int16        open_ppp (SERIAL_PORT *port);
void         close_ppp (SERIAL_PORT *port);
void         open_ipcp (SERIAL_PORT *port);
void         close_ipcp (SERIAL_PORT *port);
void         ppp_control (SERIAL_PORT *port, uint16 protocol, uint8 *data, int16 len);
void         link_maintain (SERIAL_PORT *port);
uint16       fetch_16bit (uint8 *dest, uint8 *source);
uint32       fetch_32bit (uint8 *dest, uint8 *source);
uint32       choose_a_magic (uint32 avoid);
int16        add_ps_dns (char *buffer, uint32 dns_ip);
uint8        fetch_byte (char **buffer);
void         paste_byte (char **buffer, uint8 byte, int16 komma);
int16        pap_check_auth (SERIAL_PORT *port, uint8 *secret);
void         ppp_log_text (SERIAL_PORT *port, char *text);
void         ppp_log_it (SERIAL_PORT *port, MACHINE *mach, char *act, char *which, int id);
void         ppp_log_options (SERIAL_PORT *port, uint8 *data, int16 len, uint8 offs, uint8 xtra);
void         number_to_string (uint32 number, char *string, int16 digits);


extern SERIAL_PORT  *my_ports;
extern int          space;

MACHINE  lcp  = { "LCP",  0, PPP_LCP,   0, 0, FALSE, 0,  0, 0, 0, 0, 11, 8, -1,
                     1, 0, NULL, NULL, lcp_up_down,  lcp_do_lower, 
                     lcp_create,  lcp_nego,  lcp_imple,  lcp_options,  lcp_accept   };
MACHINE  ipcp = { "IPCP", 0, PPP_IPCP,  0, 0, FALSE, 0,  0, 0, 0, 0, 7,  4, -1,
                     1, 0, NULL, NULL, ipcp_up_down, ppp_dummy, 
                     ipcp_create, ipcp_nego, ipcp_imple, ipcp_options, ipcp_accept  };
MACHINE  pap  = { "PAP",  0, PPP_PAP,   0, 0, FALSE, 0,  0, 0, 0, 0, 3,  3, -1,
                     0, 1, NULL, NULL, pap_up_down,  ppp_dummy, 
                     pap_create,  pap_nego,  pap_imple,  pap_options,  pap_accept   };
uint8    identifier = 0;
char     not_open[] = "Packet dropped (LCP not open).";



void  init_ppp (port)

SERIAL_PORT  *port;

{
   port->ppp.lcp  = lcp;
   port->ppp.ipcp = ipcp;
   port->ppp.pap  = pap;

   port->ppp.message = NULL;
   port->ppp.cp_send_data = NULL;
   port->ppp.cp_send_len = 0;

   port->ppp.lcp.state = PPP_INITIAL;
 }


int  send_cp (port, protocol, code, ident, length, options)

SERIAL_PORT  *port;
uint16       protocol, length;
uint8        code, ident, *options;

{
   uint8   *data, *work;
   uint16  len;

   if (length + 4 > port->ppp.peer_mru)
        length = port->ppp.peer_mru - 4;

   len = length + 6;

   if ((data = KRmalloc (port->ppp.cp_send_len + len)) == NULL)
        return(-1);

   if (port->ppp.cp_send_len != 0) {
        memcpy (data, port->ppp.cp_send_data, port->ppp.cp_send_len);
        KRfree (port->ppp.cp_send_data);
      }
   port->ppp.cp_send_data = data;   port->ppp.cp_send_len += len;

   work = data + port->ppp.cp_send_len - len;
   len -= 2;

   *work++ = protocol >> 8;   *work++ = protocol & 0xff;
   *work++ = code;            *work++ = ident;
   *work++ = len >> 8;        *work++ = len & 0xff;
   memcpy (work, options, length);

   return(0);
 }


void  cdecl  ppp_timer()

{
   SERIAL_PORT  *port;
   int          count;

   for (count = 0; count < space; count++) {
        port = & my_ports[count];
        if (port->generic.active && (port->generic.flags & FLG_PRTCL) != 0) {
             if (port->ppp.lcp.timer_run) {
                  if (TIMER_elapsed (port->ppp.lcp.timer_start) > port->ppp.lcp.timer_elapsed)
                       timer_event (port, & port->ppp.lcp);
                }
             if (port->ppp.ipcp.timer_run) {
                  if (TIMER_elapsed (port->ppp.ipcp.timer_start) > port->ppp.ipcp.timer_elapsed)
                       timer_event (port, & port->ppp.ipcp);
                }
             if (port->ppp.pap.timer_run) {
                  if (TIMER_elapsed (port->ppp.pap.timer_start) > port->ppp.pap.timer_elapsed)
                       timer_event (port, & port->ppp.pap);
                }
             link_maintain (port);
           }
      }
 }


int16  open_ppp (port)

SERIAL_PORT  *port;

{
   port->generic.flags &= 0x000fffffL;

   port->ppp.peer_mru = 1500;
   port->ppp.recve_accm = port->ppp.send_accm = 0xffffffffuL;
   port->ppp.local_magic = port->ppp.remote_magic = 0x0uL;
   port->ppp.mtu2 = port->generic.max_mtu;

   if (port->ppp.lcp.conf == NULL) {
        if ((port->ppp.lcp.conf = KRmalloc (64L)) == NULL)
             return (FALSE);
      }
   if (port->ppp.ipcp.conf == NULL) {
        if ((port->ppp.ipcp.conf = KRmalloc (64L)) == NULL) {
             KRfree (port->ppp.lcp.conf);
             return (FALSE);
           }
      }
   if (port->ppp.pap.conf == NULL) {
        if ((port->ppp.pap.conf = KRmalloc (64L)) == NULL) {
             KRfree (port->ppp.lcp.conf);
             KRfree (port->ppp.ipcp.conf);
             return (FALSE);
           }
      }

   port->ppp.lcp.conf_len = port->ppp.pap.conf_len = port->ppp.ipcp.conf_len = -1;
   port->ppp.pap.state = port->ppp.ipcp.state = PPP_INITIAL;

   user_event (port, PPP_OPEN, & port->ppp.lcp);
   user_event (port, PPP_OPEN, & port->ppp.ipcp);
   user_event (port, PPP_OPEN, & port->ppp.pap);

   return (TRUE);
 }


void  close_ppp (port)

SERIAL_PORT  *port;

{
   int32  timer;

   port->generic.flags &= ~FLG_DONE;
   timer = TIMER_now();

   user_event (port, PPP_CLOSE, & port->ppp.lcp);

   while (TIMER_elapsed (timer) < 15000L && (port->generic.flags & FLG_DONE) == 0);

   port->ppp.pap_id[0] = port->ppp.pap_passwd[0] = '\0';

   port->ppp.lcp.state  = PPP_INITIAL;   port->ppp.lcp.flags  = 0;   KRfree (port->ppp.lcp.conf);
   port->ppp.ipcp.state = PPP_INITIAL;   port->ppp.ipcp.flags = 0;   KRfree (port->ppp.ipcp.conf);
   port->ppp.pap.state  = PPP_INITIAL;   port->ppp.pap.flags  = 0;   KRfree (port->ppp.pap.conf);
 }


void  open_ipcp (port)

SERIAL_PORT  *port;

{
   user_event (port, PPP_OPEN, & port->ppp.ipcp);
 }


void  close_ipcp (port)

SERIAL_PORT  *port;

{
   user_event (port, PPP_CLOSE, & port->ppp.ipcp);
 }


void  ppp_control (port, protocol, data, length)

SERIAL_PORT  *port;
uint16       protocol;
uint8        *data;
int16        length;

{
   uint8  *block;
   char   string[8];

   port->ppp.data   = data;
   port->ppp.length = length;

   switch (protocol) {
      case PPP_LCP :
        network_event (port, & port->ppp.lcp);
        break;
      case PPP_IPCP :
        if (port->ppp.lcp.state != PPP_OPENED) {
             port->generic.stat_dropped++;
             ppp_log_it (port, & port->ppp.ipcp, not_open, "", -1);
           }
          else
             network_event (port, & port->ppp.ipcp);
        break;
      case PPP_PAP :
        if (port->ppp.lcp.state != PPP_OPENED) {
             port->generic.stat_dropped++;
             ppp_log_it (port, & port->ppp.lcp, not_open, "", -1);
           }
          else
             network_event (port, & port->ppp.pap);
        break;
      default :
        if (port->ppp.lcp.state == PPP_OPENED) {
             if (data - port->recve_buffer >= 2) {
                  data[-2] = protocol >> 8;   data[-1] = protocol & 0xff; 
                  send_cp (port, PPP_LCP, PPP_PRTCL_REJCT, identifier++, length + 2, data - 2);
                }
               else {
                  if ((block = KRmalloc (length + 2)) != NULL) {
                       * (uint16 *) block = protocol;
                       memcpy (block + 2, data, length);
                       send_cp (port, PPP_LCP, PPP_PRTCL_REJCT, identifier++, length + 2, block);
                       KRfree (block);
                     }
                }
             number_to_string (protocol, string, 4);
             string[5] = '\0';
             ppp_log_it (port, & port->ppp.lcp, "Unknown protocol rejected :", string, -1);
           }
          else {
             port->generic.stat_dropped++;
             ppp_log_it (port, & port->ppp.lcp, not_open, "", -1);
           }
      }
 }


void  link_maintain (port)

SERIAL_PORT  *port;

{
   uint32  *flags;

   if (port->iocntl == NULL)
        return;

   flags = & port->generic.flags;

   if (*flags & FLG_DTR_DOWN) {
        if ((*flags & FLG_DTR_UP) == 0)
             *flags |= FLG_DTR_UP;
          else {
             *flags |= FLG_DONE;   *flags &= ~(FLG_DTR_DOWN | FLG_DTR_UP);
             set_dtr (port->iocntl, TRUE);
           }
      }

   if (inq_cd (port->iocntl)) {
        if (*flags & FLG_DCD_UP)
             user_event (port, PPP_LAYUP, & port->ppp.lcp);
      }
     else {
        if (*flags & FLG_DCD_DOWN) {
             *flags |= FLG_DTR_DOWN;   *flags &= ~FLG_DCD_DOWN;
             set_dtr (port->iocntl, FALSE);
             user_event (port, PPP_LAYDOWN, & port->ppp.lcp);
           }
      }
 }


uint16  fetch_16bit (dest, src)

uint8  *dest, *src;

{
   uint16  accu = 0L;
   uint8   byte;

   accu = byte = *src++;
   if (dest)   *dest++ = byte;

   accu = (accu << 8) | (byte = *src++);
   if (dest)   *dest++ = byte;

   return (accu);
 }


uint32  fetch_32bit (dest, src)

uint8  *dest, *src;

{
   uint32  accu = 0L;
   uint8   byte, count;

   for (count = 0; count < 4; count++) {
        byte = *src++;
        if (dest)   *dest++ = byte;
        accu = (accu << 8) | byte;
      }

   return (accu);
 }


uint32  choose_a_magic (avoid)

uint32  avoid;

{
   uint32  magic;

   do {
        magic = (uint32) TIMER_now() ^ Supexec (choose_magic);
     } while (magic == 0uL || magic == avoid);

   return (magic);
 }


int16  add_ps_dns (buffer, dns)

char    *buffer;
uint32  dns;

{
   int16   komma_flag = FALSE;
   uint32  inter;

   while (*buffer) {
        komma_flag = TRUE;
        inter =                fetch_byte (& buffer);
        inter = (inter << 8) | fetch_byte (& buffer);
        inter = (inter << 8) | fetch_byte (& buffer);
        inter = (inter << 8) | fetch_byte (& buffer);
        if (inter == dns)
             return (FALSE);
        while (*buffer == ' ')   buffer++;
      }

   if (komma_flag) {
        strcpy (buffer, ", ");   buffer += 2;
      }

   paste_byte (& buffer,  dns >> 24,         TRUE);
   paste_byte (& buffer, (dns >> 16) & 0xff, TRUE);
   paste_byte (& buffer, (dns >> 8)  & 0xff, TRUE);
   paste_byte (& buffer,  dns        & 0xff, FALSE);
   buffer[0] = '\0';

   return (TRUE);
 }


uint8  fetch_byte (buffer)

char  **buffer;

{
   uint8  byte = 0;

   while ('0' <= **buffer && **buffer <= '9')
        byte = 10 * byte + (*(*buffer)++ - '0');

   if (**buffer == '.' || **buffer == ',')
        (*buffer)++;

   return (byte);
 }


void  paste_byte (buffer, byte, komma)

char   **buffer;
uint8  byte;
int16  komma;

{
   char  number[10], *walk;

   *(walk = & number[9]) = '\0';

   do {
        *--walk = '0' + (byte % 10);
        byte /= 10;
     } while (byte != 0);

   while (*walk)   *(*buffer)++ = *walk++;

   if (komma)   *(*buffer)++ = '.';
 }


int16  pap_check_auth (port, secret)

SERIAL_PORT  *port;
uint8        *secret;

{
   int16  length, count;
   uint8  **secret_list;

   if ((port->generic.flags & FLG_REQU_AUTH) == 0 || port->ppp.pap_auth == NULL)
        return (FALSE);

   secret_list = port->ppp.pap_auth;
   length = (int16) (strlen (secret) + strlen (& secret[strlen (secret) + 1]) + 2);

   for (count = 8192; count > 0 && *secret_list != NULL; --count, secret_list++)
        if (memcmp (*secret_list, secret, length) == 0)
             return (TRUE);

   return (FALSE);
 }


void  ppp_log_text (port, string)

SERIAL_PORT  *port;
char         *string;

{
   uint16  length;

   if ((port->generic.flags & FLG_LOGGING) == 0)
        return;

   length = (uint16) strlen (string);

   if (port->log_ptr + length > port->log_len)
        memcpy (port->log_buffer, "...\r\n", port->log_ptr = 5);

   memcpy (port->log_buffer + port->log_ptr, string, length);
   port->log_ptr += length;
 }


void  ppp_log_it (port, machine, action, which, ident)

SERIAL_PORT  *port;
MACHINE      *machine;
char         *action, *which;
int          ident;

{
   char  line[50], *id;

   id = " (Id $..)";
   number_to_string ((uint32) ident, & id[5], 2);

   strcpy (line, machine->name);
   strcat (line, " -> ");
   strcat (line, action);   strcat (line, " ");   strcat (line, which);
   if (ident >= 0)   strcat (line, id);
   strcat (line, "\r\n");

   ppp_log_text (port, line);
 }


void  ppp_log_options (port, data, length, offset, xtra)

SERIAL_PORT  *port;
uint8        *data, offset, xtra;
int16        length;

{
   uint16  index, number, count, nibble;
   char    line[64], *walk;

   line[0] = line[1] = line[2] = ' ';
   index = 3;

   for (walk = data; walk < data + length;) {
        line[index++] = '[';
        if ((number = walk[offset] + xtra) == 0)
             break;
        for (count = 0; count < number; count++) {
             nibble = *walk >> 4;
             line[index++] = (nibble < 10) ? '0' + nibble : 'a' + nibble - 10;
             nibble = *walk++ & 0x0f;
             line[index++] = (nibble < 10) ? '0' + nibble : 'a' + nibble - 10;
             if (count == number - 1) {
                  line[index++] = ']';
                  line[index++] = (walk == data + length) ? '.' : ',';
                  line[index++] = ' ';
                }
             if (index > 52) {
                  line[index++] = '\r';   line[index++] = '\n';   line[index++] = '\0';
                  ppp_log_text (port, line);
                  index = 3;
                }
             if (count < number - 1)   line[index++] = ' ';
           }
      }

   if (index > 3) {
        line[index++] = '\r';   line[index++] = '\n';   line[index++] = '\0';
        ppp_log_text (port, line);
      }
 }


void  number_to_string (number, string, digits)

uint32  number;
char    *string;
int16   digits;

{
   uint8  nibbles[8];
   int16  count;

   for (count = 0; count < digits; count++)
        nibbles[count] = (number >> (count * 4)) & 0x0f;

   *string++ = '$';

   for (count = digits - 1; count >= 0; --count)
        *string++ = (nibbles[count] < 10) ? '0' + nibbles[count] : 'a' + nibbles[count] - 10;
 }
