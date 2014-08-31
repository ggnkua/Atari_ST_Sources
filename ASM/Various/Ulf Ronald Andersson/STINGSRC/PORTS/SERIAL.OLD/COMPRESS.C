
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : Serielle Schnittstellen                      */
/*                                                                   */
/*                                                                   */
/*      Version 0.5                          vom 10. Mai 1997        */
/*                                                                   */
/*      Modul zur Van Jacobson Header Compression                    */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "serial.h"


void  make_IP_dgram (uint8 *buffer, int16 buff_len, IP_DGRAM **dgram);

void  init_vjhc (VJHC *vjhc, int16 num_states);
int   vjhc_compress (IP_DGRAM *datagram, VJHC *vjhc);
int   send_uncomp (IP_DGRAM *dgram, VJHC *vjhc, CSTATE *state);
int   vjhc_uncompress (uint8 *buff, int16 len, int16 type, VJHC *vjhc, IP_DGRAM **dgram);



void  init_vjhc (vjhc, num_states)

VJHC   *vjhc;
int16  num_states;

{
   int  count;

   memset (vjhc, 0, sizeof (VJHC));
   vjhc->max_states = num_states;

   for (count = 1; count < num_states; count++) {
        vjhc->send_state[count].connec_id = count;
        vjhc->send_state[count].next      = & vjhc->send_state[count - 1];
      }
   vjhc->send_state[0].next = & vjhc->send_state[num_states - 1];

   vjhc->last_recvd = vjhc->last_send = 255;
   vjhc->last_cstate = & vjhc->send_state[0];
 }


int  vjhc_compress (dgram, vjhc)

IP_DGRAM  *dgram;
VJHC      *vjhc;

{
   CSTATE   *state, *walk;
   IP_HDR   *ip;
   TCP_HDR  *tcp;
   uint32   diff_, diffA;
   int16    found, *old, *new;
   uint8    *work;

   if (dgram->hdr.protocol != P_TCP)
        return (VJHC_TYPE_IP);

   if (dgram->hdr.more_frg || dgram->hdr.frag_ofst || dgram->hdr.length < 40)
        return (VJHC_TYPE_IP);

   ip = & dgram->hdr;
   tcp = (TCP_HDR *) dgram->pkt_data;

   if (tcp->fin || tcp->sync || tcp->reset || ! tcp->ack)
        return (VJHC_TYPE_IP);

   state = vjhc->last_cstate->next;

   if (ip->ip_src != state->cs_ip.ip_src || ip->ip_dest != state->cs_ip.ip_dest ||
                * (uint32 *) tcp != * (uint32 *) & state->cs_tcp) {
        found = FALSE;
        do {
             walk  = state;
             state = state->next;
             if (ip->ip_src == state->cs_ip.ip_src && ip->ip_dest == state->cs_ip.ip_dest &&
                          * (uint32 *) tcp != * (uint32 *) & state->cs_tcp) {
                  found = TRUE;
                  break;
                }
          } while (state != vjhc->last_cstate);

        if (! found) {
             vjhc->last_cstate = walk;
             return (send_uncomp (dgram, vjhc, state));
           }
        if (state == vjhc->last_cstate) 
             vjhc->last_cstate = walk;
          else {
             walk->next = state->next;   state->next = vjhc->last_cstate->next;
             vjhc->last_cstate->next = state;
           }
      }

   old = (int16 *) ip;   new = (int16 *) & state->cs_ip;

   if (old[0] != new[0] || old[3] != new[3] || old[4] != new[4])
        return (send_uncomp (dgram, vjhc, state));

   if (tcp->offset != state->cs_tcp.offset)
        return (send_uncomp (dgram, vjhc, state));

   if (dgram->opt_length) {
        if (memcmp (dgram->options, state->cs_ip_opt, dgram->opt_length))
             return (send_uncomp (dgram, vjhc, state));
      }
   if (tcp->offset > 5) {
        if (memcmp (tcp + 1, state->cs_tcp_opt, (tcp->offset - 5) << 2))
             return (send_uncomp (dgram, vjhc, state));
      }

   work = & vjhc->header[4];
   vjhc->header[0] = 0;
   vjhc->header[1] = state->connec_id;

   if (tcp->urgent) {
        if (tcp->urg_ptr >= 256 || tcp->urg_ptr == 0) {
             *work++ = 0;
             *work++ = tcp->urg_ptr >> 8;   *work++ = tcp->urg_ptr;
           }
          else {
             *work++ = tcp->urg_ptr;
           }
        vjhc->header[0] |= NEW_U;
      }
     else {
        if (tcp->urg_ptr != state->cs_tcp.urg_ptr)
             return (send_uncomp (dgram, vjhc, state));
      }

   if ((diff_ = tcp->window - state->cs_tcp.window) != 0) {
        if (diff_ >= 256) {
             *work++ = 0;   *work++ = diff_ >> 8;   *work++ = diff_;
           }
          else {
             *work++ = diff_;
           }
        vjhc->header[0] |= NEW_W;
      }

   if ((diffA = tcp->acknowledge - state->cs_tcp.acknowledge) != 0) {
        if (diffA > 0xffffUL)
             return (send_uncomp (dgram, vjhc, state));
        if (diffA >= 256) {
             *work++ = 0;   *work++ = diffA >> 8;   *work++ = diffA;
           }
          else {
             *work++ = diffA;
           }
        vjhc->header[0] |= NEW_A;
      }

   if ((diff_ = tcp->sequence - state->cs_tcp.sequence) != 0) {
        if (diff_ > 0xffffUL)
             return (send_uncomp (dgram, vjhc, state));
        if (diff_ >= 256) {
             *work++ = 0;   *work++ = diff_ >> 8;   *work++ = diff_;
           }
          else {
             *work++ = diff_;
           }
        vjhc->header[0] |= NEW_S;
      }

   found = state->cs_ip.length - ((state->cs_ip.hd_len + state->cs_tcp.offset) << 2);

   switch (vjhc->header[0]) {
      case 0 :
        if (ip->length != state->cs_ip.length && found == 0)
             break;
      case SPECIAL_I :
      case SPECIAL_D :
        return (send_uncomp (dgram, vjhc, state));
      case NEW_S | NEW_A :
        if (diff_ == diffA && diff_ == found) {
             vjhc->header[0] = SPECIAL_I;   work = & vjhc->header[4];
           }
        break;
      case NEW_S :
        if (diff_ == found) {
             vjhc->header[0] = SPECIAL_D;   work = & vjhc->header[4];
           }
        break;
      }

   if ((diff_ = ip->ident - state->cs_ip.ident) != 1) {
        if (diff_ >= 256 || diff_ == 0) {
             *work++ = 0;
             *work++ = diff_ >> 8;   *work++ = diff_;
           }
          else {
             *work++ = diff_;
           }
        vjhc->header[0] |= NEW_I;
      }

   vjhc->length = (int) (work - & vjhc->header[0]);

   if (tcp->push)
        vjhc->header[0] |= TCP_PUSH;

   * (uint16 *) & vjhc->header[2] = tcp->chksum;

   memcpy (& state->cs_ip, & dgram->hdr, sizeof (IP_HDR));
   memcpy (& state->cs_tcp, tcp, tcp->offset << 2);

   if (dgram->options)
        memcpy (state->cs_ip_opt, dgram->options, dgram->opt_length);

   if (vjhc->last_send != state->connec_id) {
        vjhc->header[0] |= NEW_C;
        vjhc->header[1] = vjhc->last_send = state->connec_id;
        vjhc->begin = 0;
      }
     else {
        vjhc->header[1] = vjhc->header[0];
        vjhc->begin = 1;   vjhc->length--;
      }

   return (VJHC_TYPE_COMPR_TCP);
 }


int  send_uncomp (dgram, vjhc, state)

IP_DGRAM  *dgram;
VJHC      *vjhc;
CSTATE    *state;

{
   memcpy (& state->cs_ip, & dgram->hdr, sizeof (IP_HDR));
   memcpy (& state->cs_tcp, dgram->pkt_data, ((TCP_HDR *) dgram->pkt_data)->offset << 2);

   if (dgram->options)
        memcpy (state->cs_ip_opt, dgram->options, dgram->opt_length);

   dgram->hdr.protocol = state->connec_id;
   vjhc->last_send = state->connec_id;

   return (VJHC_TYPE_UNCOMPR_TCP);
 }


int  vjhc_uncompress (buffer, buff_len, type, vjhc, dgram)

uint8     *buffer;
int16     buff_len, type;
VJHC      *vjhc;
IP_DGRAM  **dgram;

{
   IP_HDR    *ip;
   TCP_HDR   *tcp;
   CSTATE    *state;
   IP_DGRAM  *temp;
   uint8     *work, changes, *fin;
   uint16    data, *walk, limit;
   uint32    chksum;

   *dgram = NULL;

   if (vjhc == NULL)   return (-1);

   switch (type) {
      case VJHC_TYPE_UNCOMPR_TCP :
        ip = (IP_HDR *) buffer;
        if (ip->protocol >= vjhc->max_states) {
             vjhc->flags |= VJHC_TOSS;
             return (-1);
           }
        state = & vjhc->rec_state[vjhc->last_recvd = ip->protocol];
        vjhc->flags &= ~ VJHC_TOSS;
        ip->protocol = P_TCP;
        memcpy (& state->cs_ip,     ip,      sizeof (IP_HDR));
        memcpy (& state->cs_ip_opt, ip + 1, (state->cs_ip.hd_len << 2) - sizeof (IP_HDR));
        tcp = (TCP_HDR *) (buffer + (state->cs_ip.hd_len << 2));
        memcpy (& state->cs_tcp,     tcp,      sizeof (TCP_HDR));
        memcpy (& state->cs_tcp_opt, tcp + 1, (state->cs_tcp.offset << 2) - sizeof (TCP_HDR));
        state->cs_ip.hdr_chksum = 0;
      case VJHC_TYPE_IP :
        make_IP_dgram (buffer, buff_len, dgram);
        return (0);
      case VJHC_TYPE_COMPR_TCP :
        break;
      case VJHC_TYPE_ERROR :
      default :
        vjhc->flags |= VJHC_TOSS;
        return (-1);
      }

   work = buffer;
   changes = *work++;

   if (changes & NEW_C) {
        if (*work >= vjhc->max_states) {
             vjhc->flags |= VJHC_TOSS;
             return (-1);
           }
        vjhc->flags &= ~ VJHC_TOSS;
        vjhc->last_recvd = *work++;
      }
     else {
        if (vjhc->flags & VJHC_TOSS)
             return (-1);
      }

   state = & vjhc->rec_state[vjhc->last_recvd];
   ip  = & state->cs_ip;
   tcp = & state->cs_tcp;

   tcp->chksum = ((uint16) work[0] << 8) | work[1];
   work += 2;
   tcp->push = (changes & TCP_PUSH) ? 1 : 0;

   switch (changes & SPECIAL_MASK) {
      case SPECIAL_I :
        data = ip->length - (ip->hd_len << 2) - (tcp->offset << 2);
        tcp->sequence += data;
        tcp->acknowledge += data;
        break;
      case SPECIAL_D :
        tcp->sequence += ip->length - (ip->hd_len << 2) - (tcp->offset << 2);
        break;
      default :
        if (changes & NEW_U) {
             if (*work == 0) {
                  tcp->urg_ptr = ((uint16) work[1] << 8) | work[2];
                  work += 3;
                }
               else
                  tcp->urg_ptr = *work++;
           }
        if (changes & NEW_W) {
             if (*work == 0) {
                  tcp->window += ((uint16) work[1] << 8) | work[2];
                  work += 3;
                }
               else
                  tcp->window += *work++;
           }
        if (changes & NEW_A) {
             if (*work == 0) {
                  tcp->acknowledge += ((uint32) work[1] << 8) | work[2];
                  work += 3;
                }
               else
                  tcp->acknowledge += *work++;
           }
        if (changes & NEW_S) {
             if (*work == 0) {
                  tcp->sequence += ((uint32) work[1] << 8) | work[2];
                  work += 3;
                }
               else
                  tcp->sequence += *work++;
           }
        tcp->urgent = (changes & NEW_U) ? 1 : 0;
        break;
      }

   if (changes & NEW_I) {
        if (*work == 0) {
             ip->ident += ((uint16) work[1] << 8) | work[2];
             work += 3;
           }
          else
             ip->ident += *work++;
      }
     else
        ip->ident++;

   buff_len -= work - buffer;

   if (buff_len < 0) {
        vjhc->flags |= VJHC_TOSS;
        return (-1);
      }

   ip->length = (ip->hd_len << 2) + (tcp->offset << 2) + buff_len;

   if ((temp = KRmalloc (sizeof (IP_DGRAM))) == NULL) {
        vjhc->flags |= VJHC_TOSS;
        return (-1);
      }
   memcpy (& temp->hdr, ip, sizeof (IP_HDR));

   temp->options  = KRmalloc (temp->opt_length = (temp->hdr.hd_len << 2) - sizeof (IP_HDR));
   temp->pkt_data = KRmalloc (temp->pkt_length = temp->hdr.length - (temp->hdr.hd_len << 2));

   if (temp->options == NULL || temp->pkt_data == NULL ) {
        IP_discard (temp, TRUE);
        vjhc->flags |= VJHC_TOSS;
        return (-1);
      }
   memcpy (temp->options, & state->cs_ip_opt[0], temp->opt_length);

   fin = (uint8 *) temp->pkt_data;
   memcpy (fin, tcp, (tcp->offset << 2));
   memcpy (fin + (tcp->offset << 2), work, temp->pkt_length - (tcp->offset << 2));

   chksum = 0;
   limit  = temp->opt_length / 2;

   for (walk = (uint16 *) & temp->hdr, data = 0; data < 10; walk++, data++)
        chksum += *walk;

   for (walk = (uint16 *) temp->options, data = 0; data < limit; walk++, data++)
        chksum += *walk;

   temp->hdr.hdr_chksum = ~ (uint16) ((chksum & 0xffffL) + ((chksum >> 16) & 0xffffL));

   *dgram = temp;

   return (0);
 }
