
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : TCP                                    */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                     from 19. February 1997       */
/*                                                                   */
/*      Modul fÅr Input / Output Funktionen                          */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "layer.h"

#include "tcp.h"


void    wait_flag (int16 *semaphore);
int16   req_flag (int16 *semaphore);
void    rel_flag (int16 *semaphore);
uint16  check_sum (uint32 src_ip, uint32 dest_ip, TCP_HDR *packet, uint16 length);

int16   sequ_within (uint32 actual, uint32 low, uint32 high);

void    update_wind (CONNEC *connec, TCP_HDR *tcph);
uint16  pull_up (NDB **queue, char *buffer, uint16 length);
int16   trim_segm (CONNEC *connec, IP_DGRAM *dgram, RESEQU **block, int16 flag);
void    add_resequ (CONNEC *connec, RESEQU *block);
void    do_output (CONNEC *connec);
uint8   *prep_segment (CONNEC *connec, TCP_HDR *hdr, uint16 *length, uint16 offset, uint16 size);


extern TCP_CONF  my_conf;

uint16  tcp_id = 0;



void  update_wind (connec, tcph)

CONNEC    *connec;
TCP_HDR   *tcph;

{
   uint32  rtrip, acked;

   if ((int32) tcph->acknowledge - (int32) connec->send.next > 0) {
        connec->flags |= FORCE;
        return;
      }

   if ((int32) tcph->sequence - (int32) connec->send.lwup_seq > 0 || (
                   (tcph->sequence == connec->send.lwup_seq) && 
           ((int32) tcph->acknowledge - (int32) connec->send.lwup_ack >= 0))) {
        if (connec->send.window == 0 && tcph->window != 0)
             connec->send.ptr = connec->send.unack;
        connec->send.window   = tcph->window;
        connec->send.lwup_seq = tcph->sequence;
        connec->send.lwup_ack = tcph->acknowledge;
      }

   if ((int32) tcph->acknowledge - (int32) connec->send.unack <= 0)
        return;

   if (connec->rtrp.mode && (int32) tcph->acknowledge - (int32) connec->rtrp.sequ >= 0) {
        connec->rtrp.mode = FALSE;
        if ((connec->flags & RETRAN) == 0) {
             rtrip = TIMER_elapsed (connec->rtrp.start);
             if (rtrip > connec->rtrp.smooth)
                  connec->rtrp.smooth = ( 7 * connec->rtrp.smooth + rtrip) /  8;
               else
                  connec->rtrp.smooth = (15 * connec->rtrp.smooth + rtrip) / 16;
             connec->rtrn.start   = TIMER_now();
             connec->rtrn.timeout = 2L * ((connec->rtrp.smooth > 1) ? connec->rtrp.smooth : 1);
             connec->rtrn.backoff = 0;
           }
      }

   acked = (int32) tcph->acknowledge - (int32) connec->send.unack;

   if (connec->state == TSYN_SENT || connec->state == TSYN_RECV) {
        acked--;
        connec->send.count--;
      }

   pull_up (& connec->send.queue, NULL, acked);

   connec->send.count -= acked;
   connec->send.total -= (tcph->fin) ? (acked - 1) : acked;
   connec->send.unack  = tcph->acknowledge;

   if (connec->send.unack != connec->send.next) {
        connec->rtrn.mode    = TRUE;
        connec->rtrn.start   = TIMER_now();
        connec->rtrn.timeout = 2L * ((connec->rtrp.smooth > 1) ? connec->rtrp.smooth : 1);
        connec->rtrn.backoff = 0;
      }
     else
        connec->rtrn.mode = FALSE;

   if ((int32) connec->send.ptr - (int32) connec->send.unack < 0)
        connec->send.ptr = connec->send.unack;

   connec->flags &= ~RETRAN;
 }


uint16  pull_up (queue, buffer, length)

NDB     **queue;
char    *buffer;
uint16  length;

{
   NDB     *temp;
   uint16  avail, accu = 0;

   while (length > 0 && *queue != NULL) {
        avail = ((*queue)->len < length) ? (*queue)->len : length;
        if (buffer) {
             memcpy (buffer, (*queue)->ndata, avail);
             buffer += avail;
           }
        (*queue)->len -= avail;   (*queue)->ndata += avail;
        if ((*queue)->len == 0) {
             KRfree ((*queue)->ptr);
             temp = *queue;   *queue = (*queue)->next;   KRfree (temp);
           }
        accu += avail;   length -= avail;
      }

   return (accu);
 }


int16  trim_segm (connec, dgram, block, make_resequ)

CONNEC    *connec;
IP_DGRAM  *dgram;
RESEQU    **block;
int16     make_resequ;

{
   TCP_HDR  *hdr;
   uint32   wind_beg, wind_end;
   int32    dupes, excess;
   int16    accept, dat_len, seq_len;
   uint8    *data;

   if (make_resequ) {
        if ((*block = KRmalloc (sizeof (RESEQU))) == NULL)
             return (FALSE);
        (*block)->tos       = dgram->hdr.tos;
        (*block)->hdr = hdr = (TCP_HDR *) dgram->pkt_data;
        (*block)->data      = (uint8 *) dgram->pkt_data + hdr->offset * 4;
        (*block)->data_len  = dgram->pkt_length - hdr->offset * 4;
      }

   hdr     = (*block)->hdr;
   data    = (*block)->data;
   dat_len = (*block)->data_len;

   accept  = FALSE;
   seq_len = dat_len;

   if (hdr->sync)   seq_len++;
   if (hdr->fin)    seq_len++;

   wind_beg = connec->recve.next;
   wind_end = wind_beg + connec->recve.window - 1;

   if (connec->recve.window == 0) {
        if (hdr->sequence == connec->recve.next && seq_len == 0)
             return (TRUE);
      }
     else {
        if (sequ_within (hdr->sequence, wind_beg, wind_end))
             accept = TRUE;
        if (seq_len != 0) {
             if (sequ_within (hdr->sequence + seq_len - 1, wind_beg, wind_end))
                  accept = TRUE;
             if (sequ_within (wind_beg, hdr->sequence, hdr->sequence + seq_len - 1))
                  accept = TRUE;
           } 
      }

   if (! accept)
        return (FALSE);

   if ((dupes = connec->recve.next - hdr->sequence) > 0) {
        if (hdr->sync) {
             dupes--;
             hdr->sync = FALSE;   hdr->sequence++;
           }
        data += dupes;   dat_len -= dupes;
        hdr->sequence += dupes;
      }

   excess = (hdr->sequence + dat_len) - (connec->recve.next + connec->recve.window);

   if (excess > 0) {
        dat_len -= excess;   hdr->fin = FALSE;
      }

   (*block)->data = data;
   (*block)->data_len = dat_len;

   return (TRUE);
 }


void  add_resequ (connec, block)

CONNEC  *connec;
RESEQU  *block;

{
   RESEQU  *work;

   if (connec->recve.reseq != NULL) {
        if ((int32) block->hdr->sequence - (int32) connec->recve.reseq->hdr->sequence >= 0) {
             for (work = connec->recve.reseq; work->next; work = work->next) {
                  if ((int32) block->hdr->sequence - (int32) work->next->hdr->sequence < 0)
                       break;
                }
             block->next = work->next;   work->next = block;
             return;
           }
      }

   block->next = connec->recve.reseq;   connec->recve.reseq = block;
 }


void  do_output (connec)

CONNEC  *connec;

{
   TCP_HDR  hdr;
   int16    value;
   uint16   length, sent, usable_win, size, raw_size;
   uint8    *block;

   if (connec->state == TCLOSED || connec->state == TLISTEN)
        return;

   for (;;) {
        sent = connec->send.ptr - connec->send.unack;

        if ((connec->flags & RETRAN) != 0 && sent != 0)
             break;
        if (connec->state == TSYN_SENT && sent != 0)
             break;

        if (connec->send.window == 0) {
             if (sent != 0)
                  break;
             usable_win = 1;
           }
          else {
             usable_win = connec->send.window - sent;
             if (connec->state == TESTABLISH || connec->state == TCLOSE_WAIT) {
                  if (usable_win < connec->send.window / 4)
                       usable_win = 0;
                  if (sent != 0 && connec->send.count - sent < connec->mss)
                       usable_win = 0;
                }
           }

        size = connec->send.count - sent;
        size = (size < usable_win)  ? size : usable_win;
        size = (size < connec->mss) ? size : connec->mss;
        raw_size = size;

        if (size == 0 && (connec->flags & FORCE) == 0)
             break;
        connec->flags &= ~FORCE;

        hdr.urgent = hdr.push = hdr.reset = hdr.sync = hdr.fin = FALSE;
        hdr.ack = (connec->state == TSYN_SENT) ? FALSE : TRUE;

        if (connec->send.ptr == connec->send.ini_sequ) {
             if (connec->state == TSYN_SENT || connec->state == TSYN_RECV) { 
                  raw_size--;
                  hdr.sync = TRUE;
                }
           }

        hdr.sequence    = connec->send.ptr;
        hdr.acknowledge = connec->recve.next;

        if (connec->send.total - sent == raw_size - 1) {
             raw_size--;
             hdr.fin = TRUE;
           }

        if (raw_size != 0 && sent + size == connec->send.count)
             hdr.push = TRUE;

        connec->send.ptr += size;

        if ((int32) connec->send.ptr - (int32) connec->send.next > 0)
             connec->send.next = connec->send.ptr;

        if (size != 0) {
             if (! connec->rtrp.mode) {
                  connec->rtrp.start = TIMER_now();
                  connec->rtrp.mode  = TRUE;
                  connec->rtrp.sequ  = connec->send.ptr;
                }
             if (! connec->rtrn.mode)
                  connec->rtrn.mode  = TRUE;
           }
          else {
             if (sent == 0)
                  connec->rtrn.mode = FALSE;
           }

        if ((block = prep_segment (connec, & hdr, & length, sent, raw_size)) != NULL) {
             value = IP_send (connec->local_IP_address, connec->remote_IP_address, connec->tos, 
                         FALSE, connec->ttl, P_TCP, tcp_id++, block, length, NULL, 0);
             if (value != E_NORMAL)
                  KRfree (block);
             if (value == E_UNREACHABLE)
                  connec->net_error = E_UNREACHABLE;
           }
      }
 }


uint8  *prep_segment (connec, hdr, length, offset, size)

CONNEC   *connec;
TCP_HDR  *hdr;
uint16   *length, offset, size;

{
   NDB      *work;
   uint32   chksum;
   uint16   *walk, chunk;
   uint8    *mem, *ptr;

   *length = sizeof (TCP_HDR) + ((hdr->sync) ? 4 : 0) + size;

   if ((mem = KRmalloc (*length)) == NULL)
        return (NULL);

   hdr->src_port  = connec->local_port;
   hdr->dest_port = connec->remote_port;
   hdr->offset    = (hdr->sync) ? 6 : 5;
   hdr->resvd     = 0;
   hdr->window    = connec->recve.window;
   hdr->urg_ptr   = 0;

   if (hdr->sync) {
        walk = (uint16 *) (mem + sizeof (TCP_HDR));
        *walk++ = 0x0204;
        *walk++ = connec->mss;
      }
   memcpy (mem, hdr, sizeof (TCP_HDR));

   if (size > 0) {
        ptr = mem + sizeof (TCP_HDR) + ((hdr->sync) ? 4 : 0);

        for (work = connec->send.queue; work != NULL; work = work->next) {
             if (work->len > offset)
                  break;
             offset -= work->len;
           }

        for (; work != NULL && size > 0; work = work->next, offset = 0) {
             chunk = (work->len - offset < size) ? work->len - offset : size;
             size -= chunk;
             memcpy (ptr, work->ndata + offset, chunk);
             ptr += chunk;
           }
      }

   ((TCP_HDR *) mem)->chksum = 0;

   ((TCP_HDR *) mem)->chksum =
          check_sum (connec->local_IP_address, connec->remote_IP_address, (TCP_HDR *) mem, *length);

   connec->recve.lst_win = connec->recve.window;

   return (mem);
 }
