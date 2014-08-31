
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                      from 23. November 1996      */
/*                                                                   */
/*      Module for InterNet Control Message Protocol                 */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "globdefs.h"


#define  M_YEAR    16
#define  M_MONTH   11
#define  M_DAY     23


void *  cdecl  KRmalloc (int32 size);
void    cdecl  KRfree (void *mem_block);

uint16         check_sum (IP_HDR *header, void *options, int16 length);
uint16         lock_exec (uint16 status);

int16   cdecl  IP_send (uint32, uint32, uint8, uint16, uint8, uint8, uint16, void *, uint16, void *, uint16);
void    cdecl  IP_discard (IP_DGRAM *datagram, int16 all_flag);

int16          ICMP_reply (uint8 type, uint8 code, IP_DGRAM *dgram, uint32 supplement);
int16   cdecl  ICMP_process (IP_DGRAM *dgram);
int16   cdecl  ICMP_send (uint32 dest, uint8 type, uint8 code, void *data, uint16 length);
int16   cdecl  ICMP_handler (int16 cdecl handler (IP_DGRAM *), int16 flag);
void    cdecl  ICMP_discard (IP_DGRAM *dgram);
uint16         layer_checksum (uint8 *packet, int16 length);


extern PORT    my_port;
extern CONFIG  conf;
extern uint32  sting_clock;

LAYER       icmp_desc = {  "ICMP", "01.00", 0L, (M_YEAR << 9) | (M_MONTH << 5) | M_DAY,
                           "Peter Rottengatter", 0, NULL, NULL  };
uint16      icmp_id = 0;



int16  ICMP_reply (type, code, dgram, supple)

IP_DGRAM  *dgram;
uint32    supple;
uint8     type, code;

{
   IP_DGRAM  *walk, **previous;
   int32     time_stamp;
   uint32    ip;
   uint16    length, status;
   uint8     *packet;

   ip = dgram->hdr.ip_src;

   if (ip == 0L || (ip >> 24) == 0xe0 || dgram->hdr.frag_ofst) {
        IP_discard (dgram, TRUE);
        return (FALSE);
      }

   switch (type) {
      case ICMP_ECHO_REPLY :
        code = 0;
        break;
      case ICMP_DEST_UNREACH :
      case ICMP_SRC_QUENCH :
      case ICMP_REDIRECT :
      case ICMP_TIME_EXCEED :
      case ICMP_PARAMETER :
        length = 8 + dgram->hdr.hd_len * 4 + 8;
        if ((packet = KRmalloc (length)) == NULL) {
             icmp_desc.stat_dropped++;
             IP_discard (dgram, TRUE);
             return (FALSE);
           }
        memcpy (packet + 8, &dgram->hdr, 20);
        memcpy (packet + 28, dgram->options, dgram->opt_length);
        if (dgram->pkt_data)
             memcpy (packet + 28 + dgram->opt_length, dgram->pkt_data, 8);
        *((uint32 *) packet + 1) = supple;
        if (dgram->pkt_data)
             KRfree (dgram->pkt_data);
        dgram->pkt_data   = packet;
        dgram->pkt_length = length;
        break;
      case ICMP_STAMP_REPLY :
        code = 0;
        if ((time_stamp = sting_clock + ((int32) icmp_desc.flags >> 16) * 60000L) < 0)
             time_stamp += MAX_CLOCK;
        if (time_stamp >= MAX_CLOCK)   time_stamp -= MAX_CLOCK;
        *((uint32 *) dgram->pkt_data + 3) = time_stamp;
        *((uint32 *) dgram->pkt_data + 4) = time_stamp;
        dgram->pkt_length = 20;
        break;
      case ICMP_MASK_REPLY :
        code = 0;
        *((uint32 *) dgram->pkt_data + 2) = dgram->recvd->sub_mask;
        dgram->pkt_length = 12;
        break;
      default :
        icmp_desc.stat_dropped++;   IP_discard (dgram, TRUE);
        return (FALSE);
      }

   *  (uint8 *) dgram->pkt_data      = type;
   * ((uint8 *) dgram->pkt_data + 1) = code;

   *((uint16 *) dgram->pkt_data + 1) = 0;
   *((uint16 *) dgram->pkt_data + 1) = layer_checksum (dgram->pkt_data, dgram->pkt_length);

   dgram->hdr.length    = dgram->hdr.hd_len * 4 + dgram->pkt_length;
   dgram->hdr.ident     = icmp_id++;
   dgram->hdr.dont_frg  = TRUE;
   dgram->hdr.more_frg  = FALSE;
   dgram->hdr.frag_ofst = 0;
   dgram->hdr.ttl       = conf.ttl + 1;
   dgram->hdr.protocol  = ICMP;
   dgram->hdr.ip_src    = dgram->recvd->ip_addr;
   dgram->hdr.ip_dest   = ip;

   dgram->hdr.hdr_chksum = 0;
   dgram->hdr.hdr_chksum = check_sum (& dgram->hdr, dgram->options, dgram->opt_length);

   dgram->timeout = sting_clock + dgram->hdr.ttl * 1000L - 1;
   dgram->next = NULL;

   if (dgram->timeout >= MAX_CLOCK)   dgram->timeout -= MAX_CLOCK;

   status = lock_exec (0);

   for (walk = *(previous = &my_port.receive); walk; walk = *(previous = &walk->next));
   *previous = dgram;

   lock_exec (status);

   return (TRUE);
 }


int16  cdecl  ICMP_process (dgram)

IP_DGRAM  *dgram;

{
   FUNC_LIST   *walk;
   uint16      checksum;

   checksum = * ((uint16 *) dgram->pkt_data + 1);

   if (checksum != layer_checksum (dgram->pkt_data, dgram->pkt_length)) {
        icmp_desc.stat_dropped++;
        IP_discard (dgram, TRUE);
        return (TRUE);
      }

   switch (* (uint8 *) dgram->pkt_data) {
      case ICMP_ECHO :
        ICMP_reply (ICMP_ECHO_REPLY,  0, dgram, 0L);
        break;
      case ICMP_STAMP_REQU :
        ICMP_reply (ICMP_STAMP_REPLY, 0, dgram, 0L);
        break;
      case ICMP_MASK_REQU :
        if ((icmp_desc.flags & 1) == 0)
             break;
        ICMP_reply (ICMP_MASK_REPLY,  0, dgram, 0L);
        break;
      default :
        for (walk = conf.icmp; walk; walk = walk->next) {
             if (walk->handler (dgram))
                  break;
           }
        if (walk == NULL) {
             icmp_desc.stat_dropped++;   IP_discard (dgram, TRUE);
           }
      }

   return (TRUE);
 }


int16  cdecl  ICMP_send (dest, type, code, data, dat_length)

uint32  dest;
uint16  dat_length;
uint8   type, code;
void    *data;

{
   uint16  length;
   uint8   *packet;

   if (dest == 0L || (dest >> 24) == 0xe0)
        return (E_BADDNAME);

   if ((packet = KRmalloc ((length = 4 + dat_length) + 1)) == NULL)
        return (E_NOMEM);

   memcpy (packet + 4, data, dat_length);
   packet[length] = '\0';
   * (uint8 *) packet = type;   * ((uint8 *) packet + 1) = code;

   *((uint16 *) packet + 1) = layer_checksum (packet, length);

   if (IP_send (0, dest, 0, 1, conf.ttl, ICMP, icmp_id++, packet, length, NULL, 0) != E_NORMAL) {
        KRfree (packet);
        return (E_NOMEM);
      }
   return (E_NORMAL);
 }


int16  cdecl  ICMP_handler (handler, flag)

int16  cdecl handler (IP_DGRAM *), flag;

{
   FUNC_LIST  *walk, *previous, *this, *prev_this;

   this = prev_this = previous = NULL;

   for (walk = conf.icmp; walk; walk = walk->next) {
        if (walk->handler == handler)
             this = walk,  prev_this = previous;
        previous = walk;
      }

   switch (flag) {
      case HNDLR_SET :
      case HNDLR_FORCE :
        if (this != NULL)   return (FALSE);
        if ((this = KRmalloc (sizeof (FUNC_LIST))) == NULL)
             return (FALSE);
        this->handler = handler;   this->next = conf.icmp;
        conf.icmp = this;
        return (TRUE);
      case HNDLR_REMOVE :
        if (this == NULL)   return (FALSE);
        if (prev_this)
             prev_this->next = this->next;
          else
             conf.icmp = this->next;
        KRfree (this);
        return (TRUE);
      case HNDLR_QUERY :
        return ((this) ? TRUE : FALSE);
      }

   return (FALSE);
 }


void  cdecl  ICMP_discard (dgram)

IP_DGRAM  *dgram;

{
   IP_discard (dgram, TRUE);
 }


uint16  layer_checksum (packet, length)

uint8  *packet;
int16  length;

{
   uint32  chksum;
   uint16  *walk, count;

   * ((uint16 *) packet + 1) = 0;

   chksum = 0;

   for (walk = (uint16 *) packet, count = 0; count < length / 2; walk++, count++)
        chksum += *walk;

   if (length & 1)
        chksum += (uint16) (* (uint8 *) walk) << 8;

   chksum = (chksum & 0xffffL) + ((chksum >> 16) & 0xffffL);

   return (~ (uint16) ((chksum & 0x10000L) ? chksum + 1 : chksum));
 }
