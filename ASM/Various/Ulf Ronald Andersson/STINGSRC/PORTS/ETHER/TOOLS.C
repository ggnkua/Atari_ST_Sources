
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : EtherNet Network Interface                   */
/*                                                                   */
/*                                                                   */
/*      Version 0.1                        vom 26. Januar 1998       */
/*                                                                   */
/*      Modul fuer Verschiedenes                                     */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "ether.h"


#define  ARP_NUM     32


int16  xmit_dgram (IP_DGRAM *dgram, BAB *txbab);
int16  send_dgram (IP_DGRAM *dgram, uint8 ether[6], BAB *txbab);
int16  launch_arp (uint32 ip_address, BAB *txbab);
int16  fetch_dgram (IP_DGRAM **dgram);
void   recve_dgram (BAB *rxbab);
void   retrieve_dgram (uint8 *buffer, int16 length);
void   process_arp (uint8 *buffer);
void   deplete_queue (IP_DGRAM **queue);
void   arp_init (void);
int16  arp_cache (uint32 ip_addr, ARP_ENTRY **entry);
void   arp_enter (uint32 ip_addr, uint8 ether[6]);


extern  PORT   my_port;
extern  BAB    *this_xmit;
extern  uint8  address[6];

ARP_ENTRY  arp_entries[ARP_NUM], *cache;



int16  xmit_dgram (dgram, txbab)

IP_DGRAM  *dgram;
BAB       *txbab;

{
   ETH_HDR    *ethptr;
   ARP_ENTRY  *entry;
   ARP        *arp;
   int16      length;
   uint8      *work;
   uint32     network, ip_address;

   network = my_port.ip_addr & my_port.sub_mask;

   if ((dgram->hdr.ip_dest & my_port.sub_mask) == network)
        ip_address = dgram->hdr.ip_dest;
     else {
        if ((dgram->ip_gateway & my_port.sub_mask) != network) {
             my_port.stat_dropped++;
             IP_discard (dgram, TRUE);
             return (FALSE);
           }
          else
             ip_address = dgram->ip_gateway;
      }

   if (arp_cache (ip_address, & entry))
        length = send_dgram (dgram, entry->ether, txbab);
     else
        length = launch_arp (ip_address, txbab);

   length = (length > 60) ? length : 60;
   txbab->buffer.xmit_buff->bcount = - length;
   txbab->buffer.xmit_buff->status |= DS_OWN;

   IP_discard (dgram, TRUE);
   my_port.stat_sd_data += length;

   return (TRUE);
 }


int16  send_dgram (dgram, ether, txbab)

IP_DGRAM  *dgram;
uint8     ether[6];
BAB       *txbab;

{
   ETH_HDR  *ethptr;
   uint8    *work;
   int16    length;

   ethptr = txbab->data;
   memcpy (& ethptr->destination[0], ether, 6);
   memcpy (& ethptr->source[0], address, 6);
   ethptr->type = TYPE_IP;

   work = & ethptr->data[0];
   memcpy (work, & dgram->hdr, sizeof (IP_HDR));        work += sizeof (IP_HDR);
   memcpy (work, dgram->options,  dgram->opt_length);   work += dgram->opt_length;
   memcpy (work, dgram->pkt_data, dgram->pkt_length);   work += dgram->pkt_length;

   return ((int16) (work - (uint8 *) ethptr));
 }


int16  launch_arp (ip_address, txbab)

uint32  ip_address;
BAB     *txbab;

{
   ETH_HDR  *ethptr;
   ARP      *arp;
   uint8    *work;
   int16    length;

   ethptr = txbab->data;
   memset (& ethptr->destination[0], 0xff, 6);
   memcpy (& ethptr->source[0], address, 6);
   ethptr->type = TYPE_ARP;

   arp = (ARP *) & ethptr->data[0];
   arp->hardware_space = ARP_HARD_ETHER;   arp->hardware_len = 6;
   arp->protocol_space = TYPE_IP;          arp->protocol_len = 4;
   arp->op_code = 1;
   memcpy (& arp->src_ether[0], address, 6);
   arp->src_ip = my_port.ip_addr;          arp->dest_ip = ip_address;

   return (sizeof (ETH_HDR) + sizeof(ARP));
 }


int16  fetch_dgram (dgram)

IP_DGRAM  **dgram;

{
   do {
        if ((*dgram = my_port.send) == NULL)
             return (FALSE);
        my_port.send = (*dgram)->next;
     } while (check_dgram_ttl (*dgram) != E_NORMAL);

   return (TRUE);
 }


void  recve_dgram (rxbab)

BAB  *rxbab;

{
   ETH_HDR  *ethptr;
   int16    length;

   length = rxbab->buffer.recve_buff->mcount;
   ethptr = rxbab->data;

   if ((rxbab->buffer.recve_buff->status & (DS_ERR | DS_STP | DS_ENP)) == (DS_STP | DS_ENP)) {
        switch (ethptr->type) {
           case TYPE_IP :
             retrieve_dgram (& ethptr->data[0], length);
             break;
           case TYPE_ARP :
             process_arp (& ethptr->data[0]);
             break;
           }
        my_port.stat_rcv_data += length;
      }
     else
        my_port.stat_dropped++;

   rxbab->buffer.recve_buff->status |= DS_OWN;
 }


void  retrieve_dgram (buffer, length)

uint8  *buffer;
int16  length;

{
   IP_DGRAM  *dgram, *walk, **previous;

   if ((dgram = KRmalloc (sizeof (IP_DGRAM))) == NULL) {
        my_port.stat_dropped++;
        return;
      }

   memcpy (& dgram->hdr, buffer, sizeof (IP_HDR));
   buffer += sizeof (IP_HDR);

   if (dgram->hdr.length > length || dgram->hdr.hd_len < 5 || (dgram->hdr.hd_len << 2) > length) {
        KRfree (dgram);
        my_port.stat_dropped++;
        return;
      }

   dgram->options  = KRmalloc (dgram->opt_length = (dgram->hdr.hd_len << 2) - sizeof (IP_HDR));
   dgram->pkt_data = KRmalloc (dgram->pkt_length = dgram->hdr.length - (dgram->hdr.hd_len << 2));

   if (dgram->options == NULL || dgram->pkt_data == NULL ) {
        IP_discard (dgram, TRUE);
        my_port.stat_dropped++;
        return;
      }

   memcpy (dgram->options, buffer, dgram->opt_length);
   memcpy (dgram->pkt_data, buffer + dgram->opt_length, dgram->pkt_length);

   dgram->recvd = & my_port;
   dgram->next = NULL;
   set_dgram_ttl (dgram);

   for (walk = *(previous = & my_port.receive); walk; walk = *(previous = & walk->next));
   *previous = dgram;
 }


void  process_arp (buffer)

uint8  *buffer;

{
   ARP        *arp;
   ARP_ENTRY  *entry;
   ETH_HDR    *ethptr;
   int16      update = FALSE, length;

   arp = (ARP *) buffer;

   if (arp->hardware_space != ARP_HARD_ETHER || arp->hardware_len != 6)
        return;
   if (arp->protocol_space != TYPE_IP || arp->protocol_len != 4)
        return;

   if (arp_cache (arp->src_ip, & entry)) {
        update = TRUE;
        memcpy (& entry->ether[0], & arp->src_ether[0], 6);
      }

   if (arp->dest_ip != my_port.ip_addr)
        return;

   if (update == FALSE)
        arp_enter (arp->src_ip, arp->src_ether);

   if (arp->op_code == 2)
        return;

   if (this_xmit->buffer.xmit_buff->status & DS_OWN)
        return;

   arp->dest_ip = arp->src_ip;
   memcpy (& arp->dest_ether[0], & arp->src_ether[0], 6);
   arp->src_ip = my_port.ip_addr;
   memcpy (& arp->src_ether[0], address, 6);
   arp->op_code = 2;

   ethptr = this_xmit->data;
   memcpy (& ethptr->destination[0], & arp->dest_ether[0], 6);
   memcpy (& ethptr->source[0], & arp->src_ether[0], 6);
   ethptr->type = TYPE_ARP;
   memcpy (& ethptr->data[0], arp, sizeof(ARP));

   length = sizeof (ETH_HDR) + sizeof(ARP);
   length = (length > 60) ? length : 60;
   this_xmit->buffer.xmit_buff->bcount = - length;
   this_xmit->buffer.xmit_buff->status |= DS_OWN;

   this_xmit = this_xmit->next_bab;
   my_port.stat_sd_data += length;
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


void  arp_init()

{
   int16  count;

   for (count = 0; count < ARP_NUM; count++) {
        arp_entries[count].valid = FALSE;
        arp_entries[count].next  = & arp_entries[count + 1];
      }
   arp_entries[ARP_NUM - 1].next = NULL;

   cache = & arp_entries[0];
 }


int16  arp_cache (ip_addr, entry)

uint32     ip_addr;
ARP_ENTRY  **entry;

{
   ARP_ENTRY  *walk, **previous;

   for (walk = *(previous = & cache); walk; walk = *(previous = & walk->next)) {
        if (walk->valid) {
             if (walk->ip_addr == ip_addr)   break;
           }
      }

   if (! walk)   return (FALSE);

   *previous = walk->next;
   walk->next = cache;   cache = walk;

   *entry = walk;

   return (TRUE);
 }


void  arp_enter (ip_addr, ether_addr)

uint32  ip_addr;
uint8   ether_addr[6];

{
   ARP_ENTRY  *walk, **previous;

   for (walk = *(previous = & cache); walk->next; walk = *(previous = & walk->next));

   *previous = NULL;
   walk->valid = TRUE;
   walk->ip_addr = ip_addr;
   memcpy (& walk->ether[0], & ether_addr[0], 6);

   walk->next = cache;   cache = walk;
 }
