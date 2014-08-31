
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                      from 23. November 1996      */
/*                                                                   */
/*      Module for IP Programming Interface, and Router              */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "globdefs.h"


void *     cdecl  KRmalloc (int32 size);
void       cdecl  KRfree (void *mem_block);

uint16            check_sum (IP_HDR *header, void *options, int16 length);
uint16            lock_exec (uint16 status);

int16      cdecl  ICMP_process (IP_DGRAM *datagram);

void              init_ip (void);
PORT *            route_it (uint32 ip_destination, uint32 *gateway);
int16      cdecl  get_route_entry (int16 no, uint32 *tmplt, uint32 *mask, PORT **port, uint32 *gway);
int16      cdecl  set_route_entry (int16 no, uint32 tmplt, uint32 mask, PORT *port, uint32 gway);
int16      cdecl  routing_table (void);
int16             fetch_line (char **location, ROUTE_ENTRY *route);
int16             get_ip_addr (char *field, uint32 *ip_addr);
int16      cdecl  IP_send (uint32, uint32, uint8, uint16, uint8, uint8, uint16, void *, uint16, void *, uint16);
IP_DGRAM * cdecl  IP_fetch (int16 protocol);
int16      cdecl  IP_handler (int16 protocol, int16 cdecl (* handler) (IP_DGRAM *), int16 flag);
void       cdecl  IP_discard (IP_DGRAM *datagram, int16 all_flag);


extern CONFIG    conf;
extern PORT      my_port;
extern IP_PRTCL  ip[];
extern uint32    sting_clock;
extern void      *icmp;
extern char      sting_path[];

ROUTE_ENTRY  route_tab[32];
int          route_number = 0;



void  init_ip()

{
   int  count;

   for (count = 0; count < 256; count++) {
        ip[count].active = FALSE;
        ip[count].defrag = NULL;  ip[count].queue = NULL;  ip[count].process = NULL;
      }

   ip[ICMP].active = TRUE;
   ip[ICMP].process = ICMP_process;   conf.icmp = NULL;
 }


PORT  * route_it (ip_destination, gateway)

uint32  ip_destination, *gateway;

{
   PORT         *walk;
   ROUTE_ENTRY  *route;
   uint16       status, count;

   if (ip_destination == 0 || ip_destination == 0xffffffffUL)
        return (& my_port);

   if ((ip_destination & 0xff000000UL) == 0x7f000000UL)
        return (& my_port);

   for (walk = conf.ports; walk != NULL; walk = walk->next)
        if (walk->active) {
             if (ip_destination == walk->ip_addr)
                  return (& my_port);
           }

   if (route_number == 0)   return (NO_NETWORK);

   status = lock_exec (0);

   for (count = 0, route = &route_tab[0]; count < route_number; count++, route++)
        if ((ip_destination & route->netmask) == route->template) {
             if (gateway)
                  *gateway = route->ip_gateway;
             lock_exec (status);
             return ((route->port->active) ? route->port : HOST_UNREACH);
           }

   lock_exec (status);

   return (NET_UNREACH);
 }


int16  cdecl  get_route_entry (no, tmplt, mask, port, gway)

int16   no;
uint32  *tmplt, *mask, *gway;
PORT    **port;

{
   uint16  status;

   status = lock_exec (0);

   if (no < 0 || route_number <= no)
        no = -1;
     else {
        *tmplt = route_tab[no].template;   *port = route_tab[no].port;
        *mask  = route_tab[no].netmask;    *gway = route_tab[no].ip_gateway;
        no = route_number;
      }

   lock_exec (status);

   return (no);
 }


int16  cdecl  set_route_entry (no, tmplt, mask, port, gway)

int16   no;
uint32  tmplt, mask, gway;
PORT    *port;

{
   uint16  status;

   status = lock_exec (0);

   if (no < -1 || route_number <= no)
        no = -1;
     else {
        if (no == -1 && route_number < 32)
             no = route_number++;
        if (no != -1) {
             route_tab[no].template = tmplt;   route_tab[no].port       = port;
             route_tab[no].netmask  = mask;    route_tab[no].ip_gateway = gway;
           }
      }

   lock_exec (status);

   return (no);
 }


int16  cdecl  routing_table()

{
   ROUTE_ENTRY  *work;
   int16        handle, length, status, flag;
   char         rt_path[255], *route_ptr, *walk;

   strcpy (rt_path, sting_path);
   strcat (rt_path, "ROUTE.TAB");

   if ((handle = (int16) Fopen (rt_path, FO_READ)) < 0)
        return (E_NODATA);

   length = (int16) Fseek (0, handle, 2);
   Fseek (0, handle, 0);

   if ((route_ptr = (char *) KRmalloc (length + 3)) == NULL) {
        Fclose (handle);
        return (E_NOMEM);
      }
   status = (uint16) Fread (handle, length, route_ptr);
   Fclose (handle);

   if (status != length) {
        Mfree (route_ptr);   return (E_NODATA);
      }
   strcpy (&route_ptr[length++], "\r\n");

   walk = route_ptr;
   work = & route_tab[length = 0];

   status = lock_exec (0);

   do {
        if ((flag = fetch_line (& walk, work)) == 1) {
             work++;
             length++;
           }
     } while (flag >= 0 && length < 32);

   lock_exec (status);

   KRfree (route_ptr);
   route_number = work - & route_tab[0];

   return (E_NORMAL);
 }


int16  fetch_line (location, route)

char         **location;
ROUTE_ENTRY  *route;

{
   PORT    *walk;
   int16   count;
   char    buffer[100], *net, *mask, *port, *gate;

   for (count = 0; ;) {
        if ((buffer[count] = *(*location)++) == '\0')
             return (-1);
        if (buffer[count] == '\r' || buffer[count] == '\n') {
             buffer[count] = '\0';
             if (**location == '\n' || **location == '\r')
                  ++*location;
             break;
           }
        if (count++ > 98)   count = 98; 
      }

   if (buffer[0] < '0' || '9' < buffer[0])
        return (0);

   net = &buffer[0];
   if ((mask = strchr (net,  '\t')) == NULL)
        return (0);
   *mask = '\0';
   while (*++mask == '\t');
   if ((port = strchr (mask, '\t')) == NULL)
        return (0);
   *port = '\0';
   while (*++port == '\t');
   if ((gate = strchr (port, '\t')) == NULL)
        return (0);
   *gate = '\0';
   while (*++gate == '\t');

   if (get_ip_addr (net, & route->template) == 0)
        return (0);

   if (get_ip_addr (mask, & route->netmask) == 0)
        return (0);

   for (walk = conf.ports; walk != NULL; walk = walk->next)
        if (strcmp (walk->name, port) == 0) {
             route->port = walk;
             break;
           }
   if (walk == NULL)   return (0);

   if (get_ip_addr (gate, & route->ip_gateway) == 0)
        return (0);

   route->template &= route->netmask;

   return (1);
 }


int16  get_ip_addr (field, ip_addr)

char    *field;
uint32  *ip_addr;

{
   uint32  ip_1, ip_2, ip_3, ip_4;
   char    *work = field;

   ip_1 = atoi (work);
   if ((work = strchr (work, '.')) == NULL)
        return (0);
   ip_2 = atoi (++work);
   if ((work = strchr (work, '.')) == NULL)
        return (0);
   ip_3 = atoi (++work);
   if ((work = strchr (work, '.')) == NULL)
        return (0);
   ip_4 = atoi (++work);

   *ip_addr = (ip_1 << 24) | (ip_2 << 16) | (ip_3 << 8) | ip_4;
   return (1);
 }


int16  cdecl  IP_send (source, dest, tos, fragm_flg, ttl, protocol, ident, 
                       data, data_len, options, opt_len)

uint32  source, dest;
uint8   tos, ttl, protocol;
uint16  fragm_flg, ident, data_len, opt_len;
void    *data, *options;

{
   IP_DGRAM  *dgram, *walk, **previous;
   PORT      *port;
   uint16    status, my_ttl;
   uint8     *new_options;

   if (source == 0L) {
        if ((long) (port = route_it (dest, NULL)) <= 0)
             return (E_UNREACHABLE);
        source = port->ip_addr;
        if (source == LOOPBACK)   dest = source;
      }

   if ((dgram = KRmalloc (sizeof (IP_DGRAM))) == NULL)
        return (E_NOMEM);

   my_ttl = (uint16) ttl + 1;

   dgram->hdr.version    = 4;
   dgram->hdr.hd_len     = 5 + (opt_len + 3) / 4;
   dgram->hdr.tos        = tos;
   dgram->hdr.length     = dgram->hdr.hd_len * 4 + data_len;
   dgram->hdr.ident      = ident;
   dgram->hdr.reserved   = 0;
   dgram->hdr.dont_frg   = fragm_flg;
   dgram->hdr.more_frg   = FALSE;
   dgram->hdr.frag_ofst  = 0;
   dgram->hdr.ttl        = my_ttl;
   dgram->hdr.protocol   = protocol;
   dgram->hdr.ip_src     = source;
   dgram->hdr.ip_dest    = dest;

   if (options && opt_len) {
        if ((new_options = KRmalloc (opt_len + 3)) == NULL) {
             KRfree (dgram);
             return (E_NOMEM);
           }
        memcpy (new_options, options, opt_len);
        KRfree (options);
        *(new_options + opt_len    ) = '\0';
        *(new_options + opt_len + 1) = '\0';
        *(new_options + opt_len + 2) = '\0';
        opt_len = ((opt_len + 3) / 4) * 4;
      }
     else {
        if (options)   KRfree (options);
        new_options = NULL;
        opt_len = 0;
      }

   dgram->options     = new_options;
   dgram->opt_length  = opt_len;
   dgram->pkt_data    = data;
   dgram->pkt_length  = data_len;

   dgram->timeout = sting_clock + my_ttl * 1000L - 1;
   dgram->next    = NULL;

   if (dgram->timeout >= MAX_CLOCK)   dgram->timeout -= MAX_CLOCK;

   dgram->hdr.hdr_chksum = 0;
   dgram->hdr.hdr_chksum = check_sum (& dgram->hdr, dgram->options, dgram->opt_length);

   status = lock_exec (0);

   for (walk = *(previous = &my_port.receive); walk; walk = *(previous = &walk->next));
   *previous = dgram;

   lock_exec (status);

   return (E_NORMAL);
 }


IP_DGRAM *  cdecl  IP_fetch (protocol)

int16  protocol;

{
   IP_DGRAM  *datagram, *walk, **previous;
   uint16    status;

   if (protocol < 1 || 255 < protocol)
        return (NULL);

   status = lock_exec (0);

   if ((walk = ip[protocol].queue) == NULL)
        datagram = NULL;
     else {
        for (previous = &ip[protocol].queue; walk->next; walk = *(previous = &walk->next));
        datagram = walk;
        *previous = NULL;
      }

   lock_exec (status);

   return (datagram);
 }


int16  cdecl  IP_handler (protocol, handler, flag)

int16  protocol,  cdecl (* handler) (IP_DGRAM *), flag;

{
   int16  ret_flag = FALSE;

   if (protocol <= 1 || 255 < protocol)
        return (FALSE);

   switch (flag) {
      case HNDLR_SET :
        if (ip[protocol].process == NULL) {
             ret_flag = TRUE;
             ip[protocol].process = handler;
           }
        return (ret_flag);
      case HNDLR_FORCE :
        ip[protocol].process = handler;
        return (TRUE);
      case HNDLR_REMOVE :
        if (ip[protocol].process == handler) {
             ret_flag = TRUE;
             ip[protocol].process = NULL;
           }
        return (ret_flag);
      case HNDLR_QUERY :
        return ((ip[protocol].process) ? TRUE : FALSE);
      }

   return (FALSE);
 }


void  cdecl  IP_discard (datagram, all_flag)

IP_DGRAM  *datagram;
int16     all_flag;

{
   if (datagram->options)   KRfree (datagram->options);
   if (datagram->pkt_data && all_flag)   KRfree (datagram->pkt_data);
   KRfree (datagram);
 }
