
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : Serielle Schnittstellen                      */
/*                                                                   */
/*                                                                   */
/*      Version 1.1                       vom 31. Januar 1997        */
/*                                                                   */
/*      Modul zum Datentransfer                                      */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "serial.h"
#include "ppp_fcs.h"


int          execute (int cdecl status());
int   cdecl  send (void cdecl out(), uint8 **walk, int16 *rem, int cdecl stat());
int   cdecl  receive (long cdecl in(), uint8 **walk, int16 *rem, int cdecl stat(), uint16 mark);

int          vjhc_compress (IP_DGRAM *datagram, VJHC *vjhc);
int          vjhc_uncompress (uint8 *buff, int16 len, int16 type, VJHC *vjhc, IP_DGRAM **dgram);

void         ppp_control (SERIAL_PORT *port, uint16 protocol, uint8 *data, int16 len);

void  cdecl  my_send (PORT *port);
int16        fetch_datagram (SERIAL_PORT *port);
void         ppp_do_cp (SERIAL_PORT *port);
int16        wrap_ip (SERIAL_PORT *port);
int16        slip_out (uint8 *dest, uint8 *source, int16 length);
int16        ppp_out (uint8 *dest, uint16 *fcs, uint32 accm, uint8 *source, uint16 length);
void  cdecl  my_receive (PORT *port);
void         process_datagram (SERIAL_PORT *port);
void         make_IP_dgram (uint8 *buffer, int16 buff_len, IP_DGRAM **dgram);
int16        slip_unwrap (SERIAL_PORT *port, int16 *type);
int16        ppp_unwrap (SERIAL_PORT *port, uint16 *prtcl, uint8 **data);


extern  DRIVER  my_driver;

uint8  ppp_header[4]  = {  PPP_ADDR, PPP_CNTRL, 0, 0  };



void  cdecl  my_send (port)

PORT  *port;

{
   int   cdecl  (* co_stat) (int);
   void  cdecl  (* con_out) (int, int);
   SERIAL_PORT  *serial;
   uint8        *walk;
   int16        remain;

   if (port->driver != & my_driver || ! port->active)
        return;

   serial = (SERIAL_PORT *) port;
   walk   = serial->send_buffer + serial->send_index;
   remain = serial->send_length - serial->send_index;

   if (execute (co_stat = serial->handler->Bcostat) != 0) {
        con_out = serial->handler->Bconout;
        do {
             if (remain == 0) {
                  if (! fetch_datagram (serial))
                       return;
                  walk = serial->send_buffer;   serial->send_index = 0;
                  remain = serial->send_length;
                }
          } while (send (con_out, & walk, & remain, co_stat) != 0);
      }

   serial->send_index = serial->send_length - remain;
 }


int16  fetch_datagram (port)

SERIAL_PORT  *port;

{
   port->send_length = port->send_index = 0;

   if ((port->generic.flags & FLG_PRTCL) && port->ppp.cp_send_len)
        ppp_do_cp (port);
     else {
        if (! wrap_ip (port))   return (FALSE);
      }

   port->generic.stat_sd_data += port->send_length;

   return (TRUE);
 }


void  ppp_do_cp (port)

SERIAL_PORT  *port;

{
   uint8   *work, chksum[2], *data;
   uint16  fcs, count, packet;

   work = port->send_buffer;

   for (count = 0; count < port->ppp.cp_send_len; count += packet + 2) {
        *work++ = PPP_FLAG;
        data = port->ppp.cp_send_data + count;
        packet = (data[4] << 8) | data[5];
        ppp_header[2] = data[0];   ppp_header[3] = data[1];
        fcs = 0xffffu;
        work += ppp_out (work, & fcs, 0xffffffffuL, ppp_header, 4);
        work += ppp_out (work, & fcs, 0xffffffffuL, & data[2], packet);
        fcs  ^= 0xffffu;
        chksum[0] = (uint8)  (fcs & 0x00ff);
        chksum[1] = (uint8) ((fcs >> 8) & 0x00ff);
        work += ppp_out (work, & fcs, 0xffffffffuL, chksum, 2);
      }

   *work++ = PPP_FLAG;
   port->send_length = work - port->send_buffer;
   KRfree (port->ppp.cp_send_data);   port->ppp.cp_send_len = 0;
 }


int16  wrap_ip (port)

SERIAL_PORT  *port;

{
   IP_DGRAM  *dgram;
   VJHC      *comp;
   int16     compressed, type, offs, hdr, len, posi;
   uint32    accm;
   uint16    fcs = 0xffffu;
   uint8     *work, chksum[2];

   port->send_length = 0;

   do {
        if ((dgram = port->generic.send) == NULL)
             return (FALSE);
        port->generic.send = dgram->next;
     } while (check_dgram_ttl (dgram) != E_NORMAL);

   compressed = ((port->generic.flags & FLG_VJHC) != 0) ? TRUE : FALSE;
   work = port->send_buffer;

   comp = port->vjhc;

   if ((port->generic.flags & FLG_PRTCL) == 0) {
        *work++ = SLIP_END;
        if (compressed) {
             switch (type = vjhc_compress (dgram, comp)) {
                case VJHC_TYPE_IP :
                case VJHC_TYPE_UNCOMPR_TCP :
                  *((uint8 *) & dgram->hdr) |= type;
                  work += slip_out (work, (uint8 *) & dgram->hdr, 20);
                  work += slip_out (work, dgram->options, dgram->opt_length);
                  work += slip_out (work, dgram->pkt_data, dgram->pkt_length);
                  break;
                case VJHC_TYPE_COMPR_TCP :
                  comp->header[comp->begin] |= VJHC_TYPE_COMPR_TCP;
                  work += slip_out (work, comp->header + comp->begin, comp->length);
                  offs = ((TCP_HDR *) dgram->pkt_data)->offset << 2;
                  work += slip_out (work, (uint8*)dgram->pkt_data+offs, dgram->pkt_length-offs);
                  break;
                }
           }
          else {
             work += slip_out (work, (uint8 *) & dgram->hdr, 20);
             work += slip_out (work, dgram->options, dgram->opt_length);
             work += slip_out (work, dgram->pkt_data, dgram->pkt_length);
           }
        *work++ = SLIP_END;
      }
     else {
        hdr = ppp_header[2] = 0;
        len = posi = 4;
        if ((port->generic.flags & FLG_PRTCL_COMP) != 0) {
             len -= 1;   posi -= 1;
           }
        if ((port->generic.flags & FLG_A_C_COMP) != 0) {
             len -= 2;   hdr += 2;
           }
        *work++ = PPP_FLAG;
        accm    = port->ppp.send_accm;
        if (compressed) {
             switch (type = vjhc_compress (dgram, comp)) {
                case VJHC_TYPE_IP :
                case VJHC_TYPE_UNCOMPR_TCP :
                  ppp_header[posi - 1] = (type == VJHC_TYPE_IP) ? PPP_IP : PPP_VJHC_UNC;
                  work += ppp_out (work, & fcs, accm, & ppp_header[hdr], len);
                  work += ppp_out (work, & fcs, accm, (uint8 *) & dgram->hdr, 20);
                  work += ppp_out (work, & fcs, accm, dgram->options, dgram->opt_length);
                  work += ppp_out (work, & fcs, accm, dgram->pkt_data, dgram->pkt_length);
                  break;
                case VJHC_TYPE_COMPR_TCP :
                  ppp_header[posi - 1] = PPP_VJHC_C;
                  work += ppp_out (work, & fcs, accm, & ppp_header[hdr], len);
                  work += ppp_out (work, & fcs, accm, comp->header + comp->begin, comp->length);
                  offs = ((TCP_HDR *) dgram->pkt_data)->offset << 2;
                  work += ppp_out (work, & fcs, accm, (uint8*) dgram->pkt_data + offs,
                                   dgram->pkt_length - offs);
                  break;
                }
           }
          else {
             ppp_header[posi - 1] = PPP_IP;
             work += ppp_out (work, & fcs, accm, & ppp_header[hdr], len);
             work += ppp_out (work, & fcs, accm, (uint8 *) & dgram->hdr, 20);
             work += ppp_out (work, & fcs, accm, dgram->options, dgram->opt_length);
             work += ppp_out (work, & fcs, accm, dgram->pkt_data, dgram->pkt_length);
           }
        fcs ^= 0xffffu;
        chksum[0] = (uint8)  (fcs & 0x00ff);
        chksum[1] = (uint8) ((fcs >> 8) & 0x00ff);
        work += ppp_out (work, & fcs, accm, chksum, 2);
        *work++ = PPP_FLAG;
      }

   IP_discard (dgram, TRUE);
   port->send_length = work - port->send_buffer;

   return (TRUE);
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


int16  ppp_out (destination, fcs, send_accm, source, length)

uint8   *destination, *source;
uint16  *fcs, length;
uint32  send_accm;

{
   int16  count = 0;
   uint8  byte;

   while (length--) {
        *fcs = (*fcs >> 8) ^ fcs_tab[(*fcs ^ (byte = *source++)) & 0xff];

        if (byte < 32) {
             if (((1L << byte) & send_accm) == 0)
                  *destination++ = byte;
               else
                  *destination++ = PPP_ESC,  *destination++ = byte ^ 0x20,  count++;
             count++;
           }
          else {
             switch (byte) {
                case PPP_FLAG :
                  *destination++ = PPP_ESC;   *destination++ = PPP_FLAG ^ 0x20;
                  count += 2;   break;
                case PPP_ESC :
                  *destination++ = PPP_ESC;   *destination++ = PPP_ESC ^ 0x20;
                  count += 2;   break;
                default :
                  *destination++ = byte;   count++;
                }
           }
      }

   return (count);
 }


void  cdecl  my_receive (port)

PORT  *port;

{
   int   cdecl  (* con_stat) (int);
   long  cdecl  (* con_in) (int);
   SERIAL_PORT  *serial;
   uint8        *walk, mark;
   int16        remain, status;

   if (port->driver != & my_driver || ! port->active)
        return;

   serial = (SERIAL_PORT *) port;
   walk   = serial->recve_buffer + serial->recve_index;
   remain = serial->recve_buffer + 8190 - walk;
   mark   = ((serial->generic.flags & FLG_PRTCL) == 0) ? SLIP_END : PPP_FLAG;

   if (execute (con_stat = serial->handler->Bconstat) != 0) {
        con_in = serial->handler->Bconin;
        do {
             status = receive (con_in, & walk, & remain, con_stat, (uint16) mark);
             if (remain == 0) {
                  serial->generic.stat_dropped++;
                  walk = serial->recve_buffer;   serial->recve_index = 0;   remain = 8190;
                }
             if (walk[-1] == mark) {
                  if (--walk != serial->recve_buffer) {
                       serial->recve_length = walk - serial->recve_buffer;
                       process_datagram (serial);
                       walk = serial->recve_buffer;   serial->recve_index = 0;   remain = 8190;
                     }
                }
          } while (status != 0);
      }

   serial->recve_index = (int) (walk - serial->recve_buffer);
 }


void  process_datagram (port)

SERIAL_PORT  *port;

{
   IP_DGRAM  *dgram, *walk, **previous;
   uint8     *data;
   int16     len, compression, type;
   uint16    protocol;

   compression = (port->generic.flags & FLG_VJHC) ? TRUE : FALSE;
   port->generic.stat_rcv_data += port->recve_length;

   if (port->generic.flags & FLG_PRTCL) {
        len = ppp_unwrap (port, & protocol, & data);
        if (len > 0) {
             switch (protocol) {
                case PPP_IP :
                  compression = FALSE;   break;
                case PPP_VJHC_UNC :
                  compression = TRUE;   type = VJHC_TYPE_UNCOMPR_TCP;   break;
                case PPP_VJHC_C :
                  compression = TRUE;   type = VJHC_TYPE_COMPR_TCP;     break;
                default :
                  ppp_control (port, protocol, data, len);   return;
                }
           }
          else {
             compression = TRUE;   type = VJHC_TYPE_ERROR;
           }
      }
     else {
        len = slip_unwrap (port, & type);
        data = port->recve_buffer;
      }

   if ((port->generic.flags & FLG_PRTCL) != 0 && port->ppp.ipcp.state != PPP_OPENED) {
        port->generic.stat_dropped++;
        return;
      }

   if (! compression)
        make_IP_dgram (data, len, & dgram);
     else
        vjhc_uncompress (data, len, type, port->vjhc, & dgram);

   if (dgram == NULL) {
        port->generic.stat_dropped++;
        return;
      }

   dgram->recvd = & port->generic;
   dgram->next = NULL;
   set_dgram_ttl (dgram);

   previous = & port->generic.receive;

   for (walk = *previous; walk; walk = *(previous = &walk->next));
   *previous = dgram;
 }


void  make_IP_dgram (buffer, buff_len, dgram)

uint8     *buffer;
int16     buff_len;
IP_DGRAM  **dgram;

{
   IP_DGRAM  *temp;

   *dgram = NULL;

   if (buff_len < sizeof (IP_HDR))
        return;

   if ((temp = KRmalloc (sizeof (IP_DGRAM))) == NULL)
        return;

   memcpy (& temp->hdr, buffer, sizeof (IP_HDR));
   buffer += sizeof (IP_HDR);

   if (temp->hdr.length > buff_len || temp->hdr.hd_len < 5 || (temp->hdr.hd_len << 2) > buff_len) {
        KRfree (temp);
        return;
      }

   temp->options  = KRmalloc (temp->opt_length = (temp->hdr.hd_len << 2) - sizeof (IP_HDR));
   temp->pkt_data = KRmalloc (temp->pkt_length = temp->hdr.length - (temp->hdr.hd_len << 2));

   if (temp->options == NULL || temp->pkt_data == NULL ) {
        IP_discard (temp, TRUE);
        return;
      }

   memcpy (temp->options, buffer, temp->opt_length);
   memcpy (temp->pkt_data, buffer + temp->opt_length, temp->pkt_length);

   *dgram = temp;
 }


int16  slip_unwrap (port, type)

SERIAL_PORT  *port;
int16        *type;

{
   uint8  *p_read, *p_write, *p_last, first;
   int16  error = FALSE;

   p_last = (p_read = p_write = port->recve_buffer) + port->recve_length;

   if (*p_read == SLIP_END)
        p_read++;

   while (p_read < p_last) {
        if (*p_read == SLIP_ESC)
             switch (*++p_read) {
                case SLIP_DATEND :   *p_read = SLIP_END;   break;
                case SLIP_DATESC :   *p_read = SLIP_ESC;   break;
                default :            error = TRUE;
                }
        *p_write++ = *p_read++;
      }

   if (*p_read != SLIP_END)   error = TRUE;

   first = * port->recve_buffer;

   if (! error) {
        if (first & 0x80u)
             *type = VJHC_TYPE_COMPR_TCP;
          else {
             if (first >= 0x70u) {
                  *type = VJHC_TYPE_UNCOMPR_TCP;   *port->recve_buffer &= ~0x30u;
                }
               else
                  *type = VJHC_TYPE_IP;
           }
      }
     else
        *type = VJHC_TYPE_ERROR;

   return ((int16) (p_write - port->recve_buffer));
 }


int16  ppp_unwrap (port, protocol, data)

SERIAL_PORT  *port;
uint16       *protocol;
uint8        **data;

{
   uint8   *p_read, *p_write, *p_last;
   uint16  fcs = 0xffffu;

   p_last = (p_read = p_write = port->recve_buffer) + port->recve_length;

   if (*p_read == PPP_FLAG)
        p_read++;

   while (p_read < p_last) {
        if (*p_read < 32)
             if (((1L << *p_read) & port->ppp.recve_accm) != 0) {
                  p_read++;
                  continue;
                }
        if (*p_read == PPP_ESC) {
             if (*++p_read == PPP_FLAG)   return (0);
             *p_read ^= 0x20;
           }
        fcs = (fcs >> 8) ^ fcs_tab[(fcs ^ *p_read) & 0xff];
        *p_write++ = *p_read++;
      }

   if (fcs != 0xf0b8 || p_write - port->recve_buffer < 6)
        return (0);

   p_read = port->recve_buffer;
   p_write -= 3;

   if (p_read[0] == PPP_ADDR && p_read[1] == PPP_CNTRL)
        p_read += 2;

   if ((*p_read & 0x01) == 0)
        *protocol = (*p_read << 8) | *(p_read + 1);
     else
        *protocol =  *p_read;

   *data = p_read + ((*p_read & 0x01) ? 1 : 2);

   if ((*protocol & 0x01) == 0)
        return (0);

   return ((int16) (p_write - p_read));
 }
