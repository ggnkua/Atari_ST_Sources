
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : DNS Resolver                           */
/*                                                                   */
/*                                                                   */
/*      Version 0.5                        from 24. March 1997       */
/*                                                                   */
/*      Modul fÅr AusfÅhrung eines Nameserver-Query                  */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "resolve.h"


void    _appl_yield (void);

int16   do_query (char item[], uint32 dns, int16 type, DNS_HDR **hdr, uint8 **data,
                               uint8 **qs, uint8 **as, uint8 **ns, uint8 **ais);
long    sys_timer (void);
int16   check_reply (uint8 *data, int16 rep, DNS_HDR *hdr,
                               uint8 **qs, uint8 **as, uint8 **ns, uint8 **ais);
int16   track_section (uint8 *data, int16 size, uint8 *section, int16 num, int16 a_flg);
int16   track_domain (uint8 *data, int16 size, uint8 *label, char domain[]);


uint16  identifier = 0;



int16  do_query (item, dns, type, hdr, data, qs, as, ns, ais)

char     item[];
uint32   dns;
int16    type;
DNS_HDR  **hdr;
uint8    **data, **qs, **as, **ns, **ais;

{
   DNS_HDR  *send;
   uint8    *query, num;
   int16    length, handle, reply, len;
   int32    timeout;
   char     *walk, *ptr;

   *hdr  = NULL;
   *data = *qs = *as = *ns = *ais = NULL;

   if ((send = (DNS_HDR *) (query = KRmalloc (272L))) == NULL)
        return (-1);

   send->ident    = identifier++;
   send->qr_flg   = 0;   send->op_code  = 0;
   send->aa_flg   = 0;   send->tc_flg   = 0;
   send->rd_flg   = 1;   send->ra_flg   = 0;
   send->zero     = 0;   send->reply    = 0;

   send->QD_count = 1;   send->AN_count = 0;
   send->NS_count = 0;   send->AR_count = 0;

   query = (uint8 *) (send + 1);
   walk = item;

   while ((ptr = strchr (walk, '.')) != NULL) {
        num = (uint8) (ptr - walk);
        *query++ = num;   strncpy (query, walk, num);   query += num;
        walk += num + 1;
      }

   do {
        num = (uint8) strlen (walk);
        *query++ = num;   strcpy (query, walk);   query += num;
        walk += num;
     } while (num != 0);

   *((uint16 *) query)++ = type;   *((uint16 *) query)++ = 1;

   length = (int16) (query - (uint8 *) send);

   if ((*hdr = (DNS_HDR *) KRmalloc (sizeof (DNS_HDR))) == NULL) {
        KRfree (send);
        return (-1);
      }

   if ((handle = UDP_open (dns, 53)) < 0) {
        KRfree (send);
        return (-2);
      }
   UDP_send (handle, send, length);

   timeout = Supexec (sys_timer);

   while (CNbyte_count (handle) < sizeof (DNS_HDR)) {
        _appl_yield();
        if ((int32) Supexec (sys_timer) - timeout > 3000L) {
             KRfree (send);
             UDP_close (handle);
             return (-3);
           }
      }

   if (CNget_block (handle, *hdr, sizeof (DNS_HDR)) != sizeof (DNS_HDR)) {
        KRfree (send);
        UDP_close (handle);
        return (-2);
      }

   reply = CNbyte_count (handle);

   if ((*data = (uint8 *) KRmalloc (reply)) == NULL) {
        KRfree (send);
        UDP_close (handle);
        return (-1);
      }

   if (CNget_block (handle, *data, reply) != reply) {
        KRfree (send);
        UDP_close (handle);
        return (-2);
      }
   UDP_close (handle);

   if (check_reply (*data, reply, *hdr, qs, as, ns, ais) == 0) {
        KRfree (send);
        return (0);
      }

   KRfree (*data);   *data = NULL;

   if ((handle = TCP_open (dns, 53, 0, 1000)) < 0) {
        KRfree (send);
        return (-2);
      }

   TCP_send (handle, & length, 2);
   TCP_send (handle, send, length);
   KRfree (send);

   timeout = Supexec (sys_timer);

   while (CNbyte_count (handle) < sizeof (DNS_HDR)) {
        _appl_yield();
        if ((int32) Supexec (sys_timer) - timeout > 3000L) {
             TCP_close (handle, 0);
             return (-3);
           }
      }

   if (CNget_block (handle, *hdr, sizeof (DNS_HDR)) != sizeof (DNS_HDR)) {
        TCP_close (handle, 0);
        return (-2);
      }

   if ((ptr = *data = (uint8 *) KRmalloc ((long) (length = 10000))) == NULL) {
        TCP_close (handle, 0);
        return (-1);
      }

   while ((len = CNbyte_count (handle)) >= EOF) {
        if (len > length) {
             TCP_close (handle, 0);
             return (-4);
           }
        if (CNget_block (handle, ptr, len) != len) {
             TCP_close (handle, 0);
             return (-2);
           }
        length -= len;
        ptr += len;
        if ((int32) Supexec (sys_timer) - timeout > 3000L) {
             TCP_close (handle, 0);
             return (-3);
           }
        _appl_yield();
      }
   TCP_close (handle, 0);

   ptr = *data;
   reply = 10000 - length;

   if ((*data = (uint8 *) KRmalloc (reply)) == NULL)
        *data = ptr;
     else {
        memcpy (*data, ptr, reply);
        KRfree (ptr);
      }

   if (check_reply (*data, reply, *hdr, qs, as, ns, ais) == 0)
        return (0);

   return (-5);
 }


long  sys_timer()

{
   return (* (long *) 0x4baL);
 }


int16  check_reply (data, reply, hdr, qs, as, ns, ais)

DNS_HDR  *hdr;
uint8    *data;
int16    reply;
uint8    **qs, **as, **ns, **ais;

{
   int16  len;

   if (hdr->tc_flg)   return (-1);

   *qs = data;

   if ((len = track_section (data, reply, *qs,  hdr->QD_count, 0)) < 0)
        return (-1);
   *as = *qs + len;
   if (*as > data + reply)
        return (-1);

   if ((len = track_section (data, reply, *as,  hdr->AN_count, 1)) < 0)
        return (-1);
   *ns = *as + len;
   if (*ns > data + reply)
        return (-1);

   if ((len = track_section (data, reply, *ns,  hdr->NS_count, 1)) < 0)
        return (-1);
   *ais = *ns + len;
   if (*ais > data + reply)
        return (-1);

   if ((len = track_section (data, reply, *ais, hdr->AR_count, 1)) < 0)
        return (-1);
   if (*ais + len > data + reply)
        return (-1);

   return (0);
 }


int16  track_section (data, size, section, num_entry, a_flg)

uint8  *data, *section;
int16  size, num_entry, a_flg;

{
   int16  count, len;

   for (count = 0; num_entry > 0; --num_entry) {
        if (a_flg) {
             if ((len = track_domain (data, size, section, NULL)) < 0)
                  return (-1);
             len += 8;
             if (section + len >= data + size)
                  return (-1);
             len += * (int16 *) (section + len);
           }
          else {
             if ((len = track_domain (data, size, section, NULL)) < 0)
                  return (-1);
             len += 4;
           }
        if (section + len > data + size)
             return (-1);
        count += len;
        section += len;
      }

   return (count);
 }


int16  track_domain (data, size, label, domain)

uint8  *data, *label;
int16  size;
char   domain[];

{
   int16  count, len, cnt_flg = TRUE;
   char   *ptr = domain;

   if (label + 1 >= data + size)
        return (-1);

   for (count = 0; *label != '\0'; count += len) {
        if (*label > 63) {
             len = 2;
             cnt_flg = FALSE;
             label  = data + ((uint16) (*label & 0x3f) << 8) + *(label + 1);
             label -= sizeof (DNS_HDR);
             continue;
           }
        if (ptr) {
             strncpy (ptr, label + 1, *label);   ptr += *label;   *ptr++ = '.';
           }
        len = (cnt_flg) ? *label + 1 : 0;
        label += *label + 1;
        if (label + 1 >= data + size)   return (-1);
      }

   if (ptr > domain)
        *(ptr - 1) = '\0';
        
   return (count + ((cnt_flg) ? 1 : 0));
 }
