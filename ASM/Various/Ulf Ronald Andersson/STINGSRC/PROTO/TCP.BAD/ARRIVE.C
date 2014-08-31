
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : TCP                                    */
/*                                                                   */
/*                                                                   */
/*      Version 1.2                          from 28. May 1997       */
/*                                                                   */
/*      Modul fÅr Segment Handler                                    */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "layer.h"

#include "tcp.h"


uint16        check_sum (uint32 src_ip, uint32 dest_ip, TCP_HDR *packet, uint16 length);

void          send_sync (CONNEC *connec);
void          process_sync (CONNEC *connec, IP_DGRAM *dgram);
void          process_options (CONNEC *connec, IP_DGRAM *dgram);
void          send_reset (IP_DGRAM *dgram);
int16         sequ_within (uint32 actual, uint32 low, uint32 high);
void          close_self (CONNEC *connec, int16 reason);

void          update_wind (CONNEC *connec, TCP_HDR *tcph);
int16         trim_segm (CONNEC *connec, IP_DGRAM *dgram, RESEQU **block, int16 flag);
void          add_resequ (CONNEC *connec, RESEQU *block);
void          do_output (CONNEC *connec);

int16  cdecl  TCP_handler (IP_DGRAM *dgram);
void          do_arrive (CONNEC *conn, IP_DGRAM *dgram);


extern TCP_CONF  my_conf;
extern CONNEC    *root_list;



int16  cdecl  TCP_handler (datagram)

IP_DGRAM  *datagram;

{
   CONNEC    *connect, *option;
   TCP_HDR   *hdr;
   IP_DGRAM  *walk;
   uint16    len, count, max_mss;

   hdr = (TCP_HDR *) datagram->pkt_data;
   len = datagram->pkt_length;

   if (len < sizeof (TCP_HDR)) {
        my_conf.generic.stat_dropped++;
        return (TRUE);
      }

   if (check_sum (datagram->hdr.ip_src, datagram->hdr.ip_dest, hdr, len) != 0) {
        my_conf.generic.stat_dropped++;
        return (TRUE);
      }

   for (connect = root_list, option = NULL; connect; connect = connect->next) {
        if (hdr->dest_port != connect->local_port)
             continue;
        if (connect->remote_port)
             if (hdr->src_port != connect->remote_port)
                  continue;
        if (connect->local_IP_address)
             if (datagram->hdr.ip_dest != connect->local_IP_address)
                  continue;
        if (connect->remote_IP_address)
             if (datagram->hdr.ip_src != connect->remote_IP_address)
                  continue;
        if (connect->local_IP_address && connect->remote_IP_address && connect->remote_port)
             break;
        option = connect;
      }

   if (connect == NULL && option != NULL) {
        if (option->state == TLISTEN) {
             if (hdr->sync) {
                  connect = option;
                  connect->local_IP_address  = datagram->hdr.ip_dest;
                  connect->remote_IP_address = datagram->hdr.ip_src;
                  connect->remote_port       = hdr->src_port;
                  if (connect->info) {
                       connect->info->address.lhost = connect->local_IP_address;
                       connect->info->address.rhost = connect->remote_IP_address;
                       connect->info->address.rport = connect->remote_port;
                       connect->info->status = 0;
                     }
                  PRTCL_get_parameters (datagram->hdr.ip_src, NULL, & connect->ttl, & connect->mtu);
                  max_mss = connect->mtu - sizeof (IP_HDR) - sizeof (TCP_HDR);
                  connect->mss = (connect->mss < max_mss) ? connect->mss : max_mss;
                }
           }
      }

   if (connect == NULL) {
        send_reset (datagram);
        my_conf.generic.stat_dropped++;
        return (TRUE);
      }
   if (connect->state == TCLOSED) {
        send_reset (datagram);
        my_conf.generic.stat_dropped++;
        return (TRUE);
      }

   if ((walk = (IP_DGRAM *) KRmalloc (sizeof (IP_DGRAM))) == NULL) {
        my_conf.generic.stat_dropped++;
        return (TRUE);
      }
   memcpy (walk, datagram, sizeof (IP_DGRAM));

   datagram->options = datagram->pkt_data = NULL;
   datagram = walk;

   datagram->next = NULL;

   if (connect->pending) {
        for (walk = connect->pending; walk->next; walk = walk->next);
        walk->next = datagram;
      }
     else
        connect->pending = datagram;

   return (TRUE);
 }


void  do_arrive (conn, datagram)

CONNEC    *conn;
IP_DGRAM  *datagram;

{
   TCP_HDR  *hdr;
   RESEQU   *net_data, temp;
   NDB      *ndb, *work;
   int16  	stored, trim;
   uint16   len;

   hdr = (TCP_HDR *) datagram->pkt_data;
   len = datagram->pkt_length;

   switch (conn->state) {
      case TCLOSED :
        send_reset (datagram);
        conn->net_error = E_UA;
        my_conf.generic.stat_dropped++;
        return;
      case TLISTEN :
        if (hdr->reset) {
             return;
           }
        if (hdr->ack) {
             send_reset (datagram);
             my_conf.generic.stat_dropped++;
             return;
           }
        if (hdr->sync) {
             process_sync (conn, datagram);
             send_sync (conn);
             my_conf.con_in++;
             conn->state = TSYN_RECV;
             if (len - hdr->offset * 4 > 0 || hdr->fin)
                  break;
             do_output (conn);
           }
          else
             my_conf.generic.stat_dropped++;
        return;
      case TSYN_SENT :
        if (hdr->ack) {
             if (! sequ_within (hdr->acknowledge, conn->send.ini_sequ + 1, conn->send.next)) {
                  send_reset (datagram);
                  conn->net_error = E_UA;   my_conf.generic.stat_dropped++;
                  return;
                }
           }
        if (hdr->reset) {
             if (hdr->ack) {
                  close_self (conn, E_RRESET);   conn->net_error = E_REFUSE;
                }
             return;
           }
        if (hdr->ack && PREC (datagram->hdr.tos) != PREC (conn->tos)) {
             send_reset (datagram);
             conn->net_error = E_UA;   my_conf.generic.stat_dropped++;
             return;
           }
        if (hdr->sync) {
             process_sync (conn, datagram);
             if (hdr->ack) {
                  update_wind (conn, hdr);
                  conn->state = TESTABLISH;
                }
               else {
                  conn->state = TSYN_RECV;
                }
             if (len - hdr->offset * 4 > 0 || hdr->fin)
                  break;
             do_output (conn);
           }
        return;
      }

   if (! hdr->sync)
        process_options (conn, datagram);

   if (! trim_segm (conn, datagram, & net_data, TRUE)) {
        if (! hdr->reset) {
             conn->flags |= FORCE;
             do_output (conn);
           }
        KRfree (net_data);
        return;
      }
   datagram->pkt_data = NULL;

   if (hdr->sequence != conn->recve.next && (net_data->data_len != 0 || hdr->sync || hdr->fin)) {
        add_resequ (conn, net_data);
        return;
      }

   for (;;) {
        hdr = net_data->hdr;
        len = (uint16) (net_data->data + net_data->data_len - (uint8 *) net_data->hdr);
        stored = FALSE;

        if (hdr->reset) {
             if (conn->state == TSYN_RECV)
                  conn->state = TLISTEN;
               else {
                  close_self (conn, E_RRESET);   conn->net_error = E_RRESET;
                }
             KRfree (net_data->hdr);   KRfree (net_data);
             return;
           }

        if (PREC (net_data->tos) != PREC (conn->tos) || hdr->sync) {
             datagram->pkt_data   = hdr;
             datagram->pkt_length = len;
             KRfree (net_data);
             send_reset (datagram);
             conn->net_error = E_UA;   my_conf.generic.stat_dropped++;
             return;
           }

        if (! hdr->ack) {
             KRfree (net_data->hdr);
             KRfree (net_data);
             my_conf.generic.stat_dropped++;
             return;
           }

        switch (conn->state) {
           case TSYN_RECV :
             if (sequ_within (hdr->acknowledge, conn->send.unack + 1, conn->send.next)) {
                  update_wind (conn, hdr);
                  conn->state = TESTABLISH;
                }
               else {
                  datagram->pkt_data   = hdr;
                  datagram->pkt_length = len;
                  KRfree (net_data);
                  send_reset (datagram);
                  conn->net_error = E_UA;   my_conf.generic.stat_dropped++;
                  return;
                }
             break;
           case TESTABLISH :
           case TCLOSE_WAIT :
           case TFIN_WAIT2 :
             update_wind (conn, hdr);
             break;
           case TFIN_WAIT1 :
             update_wind (conn, hdr);
             if (conn->send.count == 0)
                  conn->state = TFIN_WAIT2;
             break;
           case TCLOSING :
             update_wind (conn, hdr);
             if (conn->send.count == 0) {
                  conn->state = TTIME_WAIT;
                  conn->rtrn.mode = TRUE;
                  conn->rtrn.start = TIMER_now();
                  conn->rtrn.timeout = 2 * my_conf.max_slt;
                }
             break;
           case TLAST_ACK :
             update_wind (conn, hdr);
             if (conn->send.count == 0) {
                  close_self (conn, E_NORMAL);
                  KRfree (net_data->hdr);   KRfree (net_data);
                  return;
                }
           case TTIME_WAIT :
             conn->flags |= FORCE;
             conn->rtrn.mode = TRUE;
             conn->rtrn.start = TIMER_now();
             conn->rtrn.timeout = 2 * my_conf.max_slt;
           }

        if (net_data->data_len != 0) {
             switch (conn->state) {
                case TSYN_RECV :
                case TESTABLISH :
                case TFIN_WAIT1 :
                case TFIN_WAIT2 :
                  temp = *net_data;
                  ndb = (NDB *) net_data;
                  ndb->ptr   = (char *) temp.hdr;
                  ndb->ndata = temp.data;
                  ndb->len   = temp.data_len;
                  ndb->next  = NULL;
                  if (conn->recve.queue) {
                       for (work = conn->recve.queue; work->next; work = work->next);
                       work->next = ndb;
                     }
                    else {
                       conn->recve.queue = ndb;
                     }
                  conn->recve.count  += ndb->len;   conn->recve.next += ndb->len;
                  conn->recve.window -= ndb->len;   conn->flags |= FORCE;
                  stored = TRUE;
                }
           }

        if (hdr->fin) {
             conn->flags |= FORCE;
             switch (conn->state) {
                case TSYN_RECV :
                case TESTABLISH :
                  conn->recve.next++;
                  conn->state = TCLOSE_WAIT;
                  break;
                case TFIN_WAIT1 :
                  if (conn->send.count != 0) {
                       conn->recve.next++;
                       conn->state = TCLOSING;
                       break;
                     }
                case TFIN_WAIT2 :
                  conn->recve.next++;
                  conn->state = TTIME_WAIT;
                  conn->rtrn.mode = TRUE;
                  conn->rtrn.start = TIMER_now();
                  conn->rtrn.timeout = 2 * my_conf.max_slt;
                  break;
                case TCLOSE_WAIT :
                case TCLOSING :
                case TLAST_ACK :
                  break;
                case TTIME_WAIT :
                  conn->rtrn.mode = TRUE;
                  conn->rtrn.start = TIMER_now();
                  conn->rtrn.timeout = 2 * my_conf.max_slt;
                  break;
                }
           }

        if (! stored) {
             KRfree (net_data->hdr);   KRfree (net_data);
           }

        for (trim = FALSE; conn->recve.reseq != NULL;) {
             if ((int32) conn->recve.next - (int32) conn->recve.reseq->hdr->sequence < 0)
                  break;
             net_data = conn->recve.reseq;   conn->recve.reseq = net_data->next;
             if (trim_segm (conn, NULL, & net_data, FALSE)) {
                  trim = TRUE;
                  break;
                }
             KRfree (net_data->hdr);   KRfree (net_data);
           }
        if (! trim)   break;
      }

   do_output (conn);

   return;
 }
