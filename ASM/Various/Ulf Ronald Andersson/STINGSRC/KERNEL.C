
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                      from 23. November 1996      */
/*                                                                   */
/*      Module for IP Kernel calls, except Router                    */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>

#include "globdefs.h"


void   cdecl  KRfree (void *mem_block);

uint16        check_sum (IP_HDR *header, void *options, int16 length);
uint16        lock_exec (uint16 status);

int16         fragment (IP_DGRAM **datagram, uint16 mtu);
int16         reassembly (IP_DGRAM **datagram, int16 protocol);

PORT *        route_it (uint32 ip_destination, uint32 *gateway);
void   cdecl  IP_discard (IP_DGRAM *datagram, int16 all_flag);

int16         ICMP_reply (uint8 type, uint8 code, IP_DGRAM *dgram, uint32 supple);

void   cdecl  my_send (PORT *port);
void   cdecl  my_receive (PORT *port);
void          poll_ports (void);
IP_DGRAM *    fetch_dgram (PORT *port);
void          clean_up (void);
void   cdecl  set_dgram_ttl (IP_DGRAM *dgram);
int16  cdecl  check_dgram_ttl (IP_DGRAM *dgram);
int16         process_dgram (IP_DGRAM *dgram);
int16         receive_dgram (IP_DGRAM *dgram, int16 re_process);
int16         check_sequence (uint32 first, uint32 second, int32 *diff);


extern CONFIG  conf;
extern PORT    my_port;
extern int32   sting_clock;

IP_PRTCL  ip[256];



void  cdecl  my_send (port)

PORT  *port;

{
   IP_DGRAM  *walk, **previous, *next;
   uint16    length;

   for (walk = *(previous = & port->send); walk; walk = next) {
        next = *previous = walk->next;
        length = walk->hdr.length;
        if (receive_dgram (walk, FALSE) == E_LOCKED) {
             *previous = walk;
             previous = & walk->next;
           }
          else
             port->stat_rcv_data += length;
      }
 }


void  cdecl  my_receive (port)

PORT  *port;

{
   IP_DGRAM  *walk;

   for (walk = port->receive; walk; walk = walk->next)
        port->stat_sd_data += walk->hdr.length;
 }


void  poll_ports()

{
   FUNC_LIST  *timer;
   PORT       *walk;
   IP_DGRAM   *received;

   for (walk = conf.ports; walk; walk = walk->next)
        walk->driver->receive (walk);

   for (walk = conf.ports; walk; walk = walk->next)
        while ((received = fetch_dgram (walk)) != NULL) {
             conf.stat_all++;
             received->recvd = walk;
             process_dgram (received);
           }

   for (walk = conf.ports; walk; walk = walk->next)
        walk->driver->send (walk);

   for (timer = conf.interupt; timer; timer = timer->next)
        timer->handler (NULL);
 }


IP_DGRAM  * fetch_dgram (port)

PORT  *port;

{
   IP_DGRAM  *fetched;
   uint16    status;

   status = lock_exec (0);

   fetched = port->receive;

   if (fetched)
        port->receive = fetched->next;

   lock_exec (status);

   return (fetched);
 }


void  clean_up()

{
   IP_DGRAM  *ip_walk, **ip_previous;
   DEFRAG    *df_walk, **df_previous;
   uint16    count, status;

   for (count = 1; count < 256; count++) {
        if (ip[count].queue) {
             status = lock_exec (0);
             ip_walk = *(ip_previous = & ip[count].queue);
             while (ip_walk) {
                  if (check_sequence (ip_walk->timeout, sting_clock, NULL)) {
                       conf.stat_ttl_excd++;
                       *ip_previous = ip_walk->next;
                       if (ip_walk->hdr.protocol != ICMP)
                            ICMP_reply (ICMP_TIME_EXCEED, 0, ip_walk, 0);
                         else
                            IP_discard (ip_walk, TRUE);
                       ip_walk = *ip_previous;
                     }
                    else
                       ip_walk = * (ip_previous = & ip_walk->next);
                }
             lock_exec (status);
           }
        if (ip[count].defrag) {
             status = lock_exec (0);
             df_walk = *(df_previous = & ip[count].defrag);
             while (df_walk) {
                  if (check_sequence (df_walk->dgram->timeout, sting_clock, NULL)) {
                       conf.stat_ttl_excd++;
                       *df_previous = df_walk->next;
                       IP_discard (df_walk->dgram, TRUE);
                       KRfree (df_walk->blk_bits);
                       KRfree (df_walk);
                       df_walk = *df_previous;
                     }
                    else
                       df_walk = * (df_previous = & df_walk->next);
                }
             lock_exec (status);
           }
      }
 }


void  cdecl  set_dgram_ttl (dgram)

IP_DGRAM  *dgram;

{
   if ((dgram->timeout = sting_clock + dgram->hdr.ttl * 1000L) >= MAX_CLOCK)
        dgram->timeout -= MAX_CLOCK;
 }


int16  cdecl  check_dgram_ttl (dgram)

IP_DGRAM  *dgram;

{
   int32  remain_ttl;

   check_sequence (sting_clock, dgram->timeout, & remain_ttl);

   remain_ttl = (remain_ttl - 1) / 1000;

   if (dgram->hdr.ttl != remain_ttl) {
        dgram->hdr.ttl = (uint8) remain_ttl;
        dgram->hdr.hdr_chksum = 0;
        dgram->hdr.hdr_chksum = check_sum (& dgram->hdr, dgram->options, dgram->opt_length);
      }

   if (remain_ttl <= 0) {
        conf.stat_ttl_excd++;
        if (dgram->hdr.protocol != ICMP)
             ICMP_reply (ICMP_TIME_EXCEED, 0, dgram, 0);
          else
             IP_discard (dgram, TRUE);
        return (E_TTLEXCEED);
      }

   return (E_NORMAL);
 }


int16  process_dgram (dgram)

IP_DGRAM  *dgram;

{
   PORT      *port;
   IP_DGRAM  *walk, **previous;

   if (check_sum (& dgram->hdr, dgram->options, dgram->opt_length) != 0) {
        conf.stat_chksum++;
        IP_discard (dgram, TRUE);
        return (E_UA);
      }

   dgram->hdr.ttl--;
   dgram->hdr.hdr_chksum += 0x100 + ((dgram->hdr.hdr_chksum >= 0xfeff) ? 1 : 0);

   port = route_it (dgram->hdr.ip_dest, & dgram->ip_gateway);

   if ((long) port <= 0) {
        conf.stat_unreach++;
        if (dgram->hdr.protocol != ICMP)
             ICMP_reply (ICMP_DEST_UNREACH, - (long) port, dgram, 0);
          else
             IP_discard (dgram, TRUE);
        return (E_UNREACHABLE);
      }

   if (dgram->hdr.length > port->mtu) {
        if (dgram->hdr.dont_frg) {
             conf.stat_unreach++;
             if (dgram->hdr.protocol != ICMP)
                  ICMP_reply (ICMP_DEST_UNREACH, 4, dgram, 0);
               else
                  IP_discard (dgram, TRUE);
             return (E_FRAGMENT);
           }
        if (! fragment (& dgram, port->mtu)) {
             conf.stat_lo_mem++;
             if (dgram->hdr.protocol != ICMP)
                  ICMP_reply (ICMP_SRC_QUENCH, 0, dgram, 0);
               else
                  IP_discard (dgram, TRUE);
             return (E_NOMEM);
           }
      }
     else
        dgram->next = NULL;

   for (walk = *(previous = & port->send); walk; walk = *(previous = & walk->next));
   *previous = dgram;

   return (E_NORMAL);
 }


int16  receive_dgram (dgram, re_process)

IP_DGRAM  *dgram;
int16     re_process;

{
   uint16  protocol, status;

   protocol = dgram->hdr.protocol;

   if (! ip[protocol].active) {
        conf.stat_unreach++;
        ICMP_reply (ICMP_DEST_UNREACH, 2, dgram, 0);
        return (E_UNREACHABLE);
      }

   if (dgram->hdr.frag_ofst != 0 || dgram->hdr.more_frg) {
        if (! reassembly (& dgram, protocol)) {
             conf.stat_lo_mem++;
             if (dgram->hdr.protocol != ICMP)
                  ICMP_reply (ICMP_SRC_QUENCH, 0, dgram, 0);
               else
                  IP_discard (dgram, TRUE);
             return (E_NOMEM);
           }
        re_process = FALSE;
        if (dgram == NULL)   return (E_NORMAL);
      }

   if (! re_process)
        if (ip[protocol].process)
             if (ip[protocol].process (dgram)) {
                  if (protocol != ICMP)
                       IP_discard (dgram, TRUE);
                  return (E_NORMAL);
                }

   status = lock_exec (0);

   dgram->next = ip[protocol].queue;
   ip[protocol].queue = dgram;

   lock_exec (status);

   return (E_NORMAL);
 }


int16  check_sequence (first, second, diff)

uint32  first, second;
int32   *diff;

{
   int32  remain;

   remain = (int32) second - (int32) first;

   if (remain < - MAX_CLOCK / 2)   remain += MAX_CLOCK;
   if (remain >   MAX_CLOCK / 2)   remain -= MAX_CLOCK;

   if (diff)   *diff = remain;

   return ((remain > 0) ? TRUE : FALSE);
 }
