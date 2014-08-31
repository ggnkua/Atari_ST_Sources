
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                      from 23. November 1996      */
/*                                                                   */
/*      Module for IP Fragmentation ad Reassembly                    */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "globdefs.h"


void *  cdecl  KRmalloc (int32 size);
void    cdecl  KRfree (void *mem_block);
void *  cdecl  KRrealloc (void *mem_block, int32 new_size);

uint16         check_sum (IP_HDR *header, void *options, int16 length);

int16          check_sequence (uint32 first, uint32 second, int32 *diff);

void    cdecl  IP_discard (IP_DGRAM *datagram, int16 all_flag);

int16          fragment (IP_DGRAM **datagram, uint16 mtu);
int16          reassembly (IP_DGRAM **datagram, int16 protocol);


extern CONFIG    conf;
extern IP_PRTCL  ip[];
extern uint32    sting_clock;



int16  fragment (datagram, mtu)

IP_DGRAM  **datagram;
uint16    mtu;

{
   IP_DGRAM  *head, *last, **last_ptr;
   uint8     *orig, *remain;
   int16     count, remain_len, len, first_flg = TRUE, frg_ofst, frg_datalen, rest;

   if ((remain = KRmalloc (60)) == NULL)
        return (FALSE);

   remain_len = count = 0;
   orig = (uint8 *) (*datagram)->options;

   while (count < (*datagram)->opt_length && orig[count] != 0)
        if ((orig[count] & 0x1f) >= 2) {
             len = orig[count+1];
             if (orig[count] & 0x80) {
                  memcpy (&remain[remain_len], &orig[count], len);
                  remain_len += len;
                }
             count += len;
           }
          else
             count++;

   while (remain_len % 4 != 0)
        remain[++remain_len] = 0;

   last_ptr = &head;   head = NULL;   frg_ofst = 0;

   do {
        if ((last = KRmalloc (sizeof (IP_DGRAM))) == NULL) {
             KRfree (remain);
             while (head) {
                  last = head->next;   IP_discard (head, TRUE);   head = last;
                }
             return (FALSE);
           }
        last->options = last->pkt_data = NULL;
        memcpy (&last->hdr, &(*datagram)->hdr, sizeof (IP_HDR));

        if (first_flg) {
             orig = (*datagram)->options;   count = (*datagram)->opt_length;
             first_flg = FALSE;
           }
          else {
             orig = remain;   count = remain_len;
           }
        if ((last->options = KRmalloc (last->opt_length = count)) == NULL) {
             KRfree (remain);   IP_discard (last, TRUE);
             while (head) {
                  last = head->next;   IP_discard (head, TRUE);   head = last;
                }
             return (FALSE);
           }
        memcpy (last->options, orig, count);

        frg_datalen = ((mtu - sizeof (IP_HDR) - count) / 8) * 8;
        rest = (*datagram)->pkt_length - frg_ofst;
        if (frg_datalen > rest)   frg_datalen = rest;

        if ((last->pkt_data = KRmalloc (last->pkt_length = frg_datalen)) == NULL) {
             KRfree (remain);   IP_discard (last, TRUE);
             while (head) {
                  last = head->next;   IP_discard (head, TRUE);   head = last;
                }
             return (FALSE);
           }
        memcpy (last->pkt_data, ((uint8 *) (*datagram)->pkt_data) + frg_ofst, frg_datalen);

        last->hdr.hd_len    = (sizeof (IP_HDR) + last->opt_length) / 4;
        last->hdr.length    = last->hdr.hd_len * 4 + frg_datalen;
        last->hdr.frag_ofst = frg_ofst / 8;
        if (rest > frg_datalen)   last->hdr.more_frg = TRUE;
        last->hdr.hdr_chksum = 0;
        last->hdr.hdr_chksum = check_sum (& last->hdr, last->options, last->opt_length);

        *last_ptr = last;   last->next = NULL;  last_ptr = &last->next;
        frg_ofst += frg_datalen;
     } while (rest > frg_datalen);

   KRfree (remain);
   IP_discard (*datagram, TRUE);   *datagram = head;

   return (TRUE);
 }


int16  reassembly (datagram, protocol)

IP_DGRAM  **datagram;
int16     protocol;

{
   IP_DGRAM  *dgram;
   DEFRAG    *walk, *previous = NULL;
   uint32    src;
   uint16    ident, needed, count, bit;
   uint8     *byte, *n_data, *n_bit;

   src = (*datagram)->hdr.ip_src;   ident = (*datagram)->hdr.ident;

   for (walk = ip[protocol].defrag; walk; walk = walk->next) {
        if (walk->dgram->hdr.ip_src == src && walk->dgram->hdr.ident == ident)
             break;
        previous = walk;
      }

   if (walk == NULL) {
        if ((walk = KRmalloc (sizeof (DEFRAG))) == NULL)
             return (FALSE);
        if ((walk->dgram = KRmalloc (sizeof (IP_DGRAM))) == NULL) {
             KRfree (walk);
             return (FALSE);
           }
        walk->blk_bits = walk->dgram->pkt_data = NULL;
        walk->act_space = 0;
        if ((walk->dgram->options  = KRmalloc (60)) == NULL) {
             KRfree (walk->dgram);
             KRfree (walk);
             return (FALSE);
           }
        if (previous)   previous->next = walk;
          else   ip[protocol].defrag = walk;
        walk->ttl_data = 0;
        if ((walk->dgram->timeout = sting_clock + conf.frag_ttl * 1000) >= MAX_CLOCK)
             walk->dgram->timeout -= MAX_CLOCK;
        walk->next = NULL;
      }

   needed = (*datagram)->hdr.frag_ofst * 8 + (*datagram)->pkt_length;

   if (walk->act_space < needed) {
        needed += 1024;
        n_data = KRrealloc (walk->dgram->pkt_data, needed);
        n_bit  = KRrealloc (walk->blk_bits, (needed + 63) / 64);
        if (n_data == NULL || n_bit == NULL) {
             KRfree ((n_data != NULL) ? n_data : walk->dgram->pkt_data);
             KRfree ((n_bit  != NULL) ? n_bit  : walk->blk_bits);
             KRfree (walk->dgram->options);   KRfree (walk->dgram);
             KRfree (walk);
             return (FALSE);
           }
        walk->dgram->pkt_data = n_data;   walk->blk_bits = n_bit;
        walk->act_space = needed;
      }

   walk->dgram->recvd = (*datagram)->recvd;

   memcpy ((uint8 *) walk->dgram->pkt_data + (*datagram)->hdr.frag_ofst * 8,
           (*datagram)->pkt_data, (*datagram)->pkt_length);

   for (count = 0; count <= (*datagram)->pkt_length / 8; count++) {
        bit = (*datagram)->hdr.frag_ofst + count;
        byte = (uint8 *) walk->blk_bits + bit / 8;   *byte |= (1 << (bit % 8));
      }

   if ((*datagram)->hdr.frag_ofst == 0) {
        memcpy (&walk->dgram->hdr, &(*datagram)->hdr, sizeof (IP_HDR));
        walk->dgram->opt_length = (*datagram)->opt_length;
        memcpy (walk->dgram->options, (*datagram)->options, (*datagram)->opt_length);
      }

   if (! (*datagram)->hdr.more_frg)
        walk->ttl_data = (*datagram)->hdr.frag_ofst * 8 + (*datagram)->pkt_length;

   if (check_sequence (walk->dgram->timeout, (*datagram)->timeout, NULL))
        walk->dgram->timeout = (*datagram)->timeout;

   IP_discard (*datagram, TRUE);
   *datagram = NULL;

   if (walk->ttl_data) {
        needed = walk->ttl_data - (walk->ttl_data / 64) * 64;
        needed = (needed + 7) / 8;
        for (count = 0; count < walk->ttl_data / 64; count++)
             if (*((uint8 *) walk->blk_bits + count) != 0xff)
                  return (TRUE);
        if (needed)
             if (*((uint8 *) walk->blk_bits + count) != (1 << needed) - 1)
                  return (TRUE);

        dgram = walk->dgram;
        dgram->hdr.length   = dgram->hdr.hd_len * 4 + walk->ttl_data;
        dgram->hdr.more_frg = FALSE;
        dgram->pkt_length   = walk->ttl_data;
        dgram->hdr.hdr_chksum = 0;
        dgram->hdr.hdr_chksum = check_sum (& dgram->hdr, dgram->options, dgram->opt_length);

        IP_discard (*datagram, TRUE);
        *datagram = dgram;   KRfree (walk->blk_bits);

        if (previous)   previous->next = walk->next;
          else   ip[protocol].defrag = walk->next;
        KRfree (walk);

        return (TRUE);
      }

   return (TRUE);
 }
