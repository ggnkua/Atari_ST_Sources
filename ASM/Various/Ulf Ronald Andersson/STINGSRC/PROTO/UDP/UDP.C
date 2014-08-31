
/*********************************************************************/
/*                                                                   */
/*     High Level Protokoll : UDP                                    */
/*                                                                   */
/*      Version 1.30                        from 26. June 1997       */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "layer.h"

#include "udp.h"


#define  M_YEAR     18
#define  M_MONTH    3
#define  M_DAY      6


#pragma warn -par


void          wait_flag (int16 *semaphore);
int16         req_flag (int16 *semaphore);
void          rel_flag (int16 *semaphore);
long          dis_intrpt (void);
long          en_intrpt (void);
UDP_HDR *     get_pending (UDP_HDR **pointer);
uint16        check_sum (uint32 src_ip, uint32 dest_ip, UDP_HDR *packet, uint16 length);

long          get_sting_cookie (void);
int16         install (void);
uint16        read_word (char *string);
int16         next_port (void);
int16  cdecl  my_UDP_open (uint32 rem_host, uint16 rem_port);
int16  cdecl  my_UDP_close (int16 connec);
int16  cdecl  my_UDP_send (int16 connec, void *buffer, int16 length);
int16  cdecl  my_CNkick (void *connec);
int16  cdecl  my_CNbyte_count (void *connec);
int16  cdecl  my_CNget_char (void *connec);
NDB *  cdecl  my_CNget_NDB (void *connec);
int16  cdecl  my_CNget_block (void *connec, void *buffer, int16 length);
CIB *  cdecl  my_CNgetinfo (void *connec);
int16  cdecl  my_CNgets (void *connec, char *buffer, int16 length, char delimiter);
int16  cdecl  UDP_handler (IP_DGRAM *dgram);
void   cdecl  timer_function (void);
int16         poll_receive (CONNEC *connec);
long          poll_doit (void);
void          timer_work (CONNEC *connec);
int16  cdecl  do_ICMP (IP_DGRAM *dgram);


DRV_LIST  *sting_drivers;
TPL       *tpl;
STX       *stx;
LAYER     my_conf  = {    "UDP", "01.42", 0x10400L, (M_YEAR << 9) | (M_MONTH << 5) | M_DAY, 
                          "Peter Rottengatter", 0, NULL, NULL  };
CN_FUNCS  cn_vectors = {  my_CNkick, my_CNbyte_count, my_CNget_char, my_CNget_NDB, 
                          my_CNget_block, my_CNgetinfo, my_CNgets   };
uint16    last_port, udp_id = 0;
int16     global_sema = 0;
CONNEC    *root_list = NULL, *global;
char      fault[] = "UDP.STX : STinG extension module. Only to be started by STinG !\r\n";



void  main (argc, argv)

int   argc;
char  *argv[];

{
   if (argc != 2) {
        Cconws (fault);   return;
      }
   if (strcmp (argv[1], "STinG_Load") != 0) {
        Cconws (fault);   return;
      }

   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L)   return;

   if (strcmp (sting_drivers->magic, MAGIC) != 0)
        return;

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl != (TPL *) NULL && stx != (STX *) NULL) {
        if (install())
             Ptermres (_PgmSize, 0);
      }
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


int16  install()

{
   LAYER  *layers;
   int16  count;
   char   *config;

   if (! ICMP_handler (do_ICMP, HNDLR_SET))
        return (FALSE);

   if (! IP_handler (P_UDP, UDP_handler, HNDLR_SET)) {
        ICMP_handler (do_ICMP, HNDLR_REMOVE);
        return (FALSE);
      }

   if (! TIMER_call (timer_function, HNDLR_SET)) {
        ICMP_handler (do_ICMP, HNDLR_REMOVE);
        IP_handler (P_UDP, UDP_handler, HNDLR_REMOVE);
        return (FALSE);
      }

   if (PRTCL_announce (P_UDP)) {
        ICMP_handler (do_ICMP, HNDLR_REMOVE);
        IP_handler (P_UDP, UDP_handler, HNDLR_REMOVE);
        TIMER_call (timer_function, HNDLR_REMOVE);
        return (FALSE);
      }

   my_conf.basepage = _BasPag;

   query_chains (NULL, NULL, (void **) & layers);

   while (layers->next)
        layers = layers->next;

   layers->next = & my_conf;

   tpl->UDP_open  = my_UDP_open;
   tpl->UDP_close = my_UDP_close;
   tpl->UDP_send  = my_UDP_send;

   config = getvstr ("UDP_PORT");
   if (config[1]) {
        my_conf.flags &= 0xffff0000ul;
        my_conf.flags |= read_word (config);
      }
   config = getvstr ("UDP_ICMP");
   my_conf.flags &= 0xfffefffful;
   my_conf.flags |= (config[0] != '0') ? 0x10000ul : 0ul;

   if ((last_port = my_conf.flags & 0xfffful) >= 30000)
        last_port = 29999;

   return (TRUE);
 }


uint16  read_word (string)

char  *string;

{
   uint16  result = 0;

   while (*string == ' ')
        string++;

   while ('0' <= *string && *string <= '9')
        result = result * 10 + (*string++ - '0');

   return (result);
 }


int16  next_port()

{
   CONNEC  *connect;

   Supexec (dis_intrpt);

   for (;;) {
        last_port++;

        if (last_port > 32765 || last_port < (my_conf.flags & 0xfffful))
             last_port = my_conf.flags & 0xfffful;

        for (connect = root_list; connect; connect = connect->next)
             if (connect->local_port == last_port)
                  break;
        if (connect)   continue;

        Supexec (en_intrpt);
        return (last_port);
      }
 }


int16  cdecl  my_UDP_open (rem_host, rem_port)

uint32  rem_host;
uint16  rem_port;

{
   CAB     *cab;
   CONNEC  *connect;
   uint32  lcl_host = 0L, aux_ip;
   uint16  lport, rport;
   int16   ttl, handle;

   if (rem_host == 0L && rem_port == UDP_EXTEND)
        rem_port = next_port();

   if (rem_port != UDP_EXTEND) {
        lport = (rem_host) ? next_port() : rem_port;
        rport = (rem_host) ?  rem_port   : 0;
      }
     else {
        cab = (CAB *) rem_host;
        rem_host = cab->rhost;   rport =  cab->rport;
        lcl_host = cab->lhost;   lport = (cab->lport) ? cab->lport : next_port();
      }

   if (rem_host != 0) {
        if (PRTCL_get_parameters (rem_host, & aux_ip, & ttl, NULL) != E_NORMAL)
             return (E_UNREACHABLE);
        lcl_host = (lcl_host) ? lcl_host : aux_ip;
      }

   if ((connect = (CONNEC *) KRmalloc (sizeof (CONNEC))) == NULL)
        return (E_NOMEM);

   if ((handle = PRTCL_request (connect, & cn_vectors)) == -1) {
        KRfree (connect);
        return (E_NOMEM);
      }

   connect->remote_IP_address = rem_host;
   connect->remote_port       = rport;
   connect->local_IP_address  = lcl_host;
   connect->local_port        = lport;
   connect->ttl               = ttl;
   connect->total_data        = 0L;
   connect->info              = NULL;
   connect->receive_queue     = NULL;
   connect->pending           = NULL;
   connect->net_error         = 0;
   connect->semaphore         = 0;

   Supexec (dis_intrpt);
   connect->next = root_list;
   root_list     = connect;
   Supexec (en_intrpt);

   return (handle);
 }


int16  cdecl  my_UDP_close (connec)

int16  connec;

{
   UDP_HDR  *walk, *qu_prev;
   CONNEC   *connect, *work, **previous;

   if ((connect = PRTCL_lookup (connec, & cn_vectors)) == NULL)
        return (E_BADHANDLE);

   Supexec (dis_intrpt);

   for (work = * (previous = & root_list); work; work = * (previous = & work->next)) {
        if (work == connect)
             break;
      }

   if (work)
        *previous = work->next;

   Supexec (en_intrpt);

   if (connect->info != NULL)
        KRfree (connect->info);

   for (walk = connect->receive_queue; walk; walk = qu_prev) {
        qu_prev = walk->chain.next;
        KRfree (walk);
      }

   for (walk = connect->pending; walk; walk = qu_prev) {
        qu_prev = walk->chain.next;
        KRfree (walk);
      }

   KRfree (connect);
   PRTCL_release (connec);

   return (E_NORMAL);
 }


int16  cdecl  my_UDP_send (connec, buffer, length)

int16  connec, length;
void   *buffer;

{
   UDP_HDR  *packet;
   CONNEC   *conn;
   int16    error, udp_length, value;

   if ((conn = PRTCL_lookup (connec, & cn_vectors)) == NULL)
        return (E_BADHANDLE);

   if (conn->remote_IP_address == 0L)
        return (E_LISTEN);

   error = conn->net_error;

   if (error < 0) {
        conn->net_error = 0;   return (error);
      }

   udp_length = sizeof (UDP_HDR) + length;

   if ((packet = (UDP_HDR *) KRmalloc (udp_length)) == NULL)
        return (E_NOMEM);

   packet->udp.source_port = conn->local_port;
   packet->udp.dest_port   = conn->remote_port;
   packet->udp.length      = udp_length;
   packet->udp.checksum    = 0;

   memcpy (packet + 1, buffer, length);

   packet->udp.checksum = check_sum (conn->local_IP_address, 
                                     conn->remote_IP_address, packet, packet->udp.length);

   value = IP_send (conn->local_IP_address, conn->remote_IP_address, 0, FALSE, conn->ttl,
                    P_UDP, udp_id++, packet, udp_length, NULL, 0);

   if (value != E_NORMAL)   KRfree (packet);

   return (value);
 }


int16  cdecl  my_CNkick (connec)

void  *connec;

{
   int16  error;

   if ((error = poll_receive (connec)) < 0)
        return (error);

   return (E_NORMAL);
 }


int16  cdecl  my_CNbyte_count (connec)

void  *connec;

{
   int16  error;

   if ((error = poll_receive (connec)) < 0)
        return (error);

   return ((int16) ((CONNEC *) connec)->total_data);
 }


int16  cdecl  my_CNget_char (connec)

void  *connec;

{
   UDP_HDR  *walk;
   int16    error, chr;

   if ((error = poll_receive (connec)) < 0)
        return (error);

   wait_flag (& ((CONNEC *) connec)->semaphore);

   for (;;) {
        if ((walk = ((CONNEC *) connec)->receive_queue) == NULL)
             break;

        if (walk->chain.index < walk->chain.length) {
             ((CONNEC *) connec)->total_data--;
             chr = * ((uint8 *) (walk + 1) + walk->chain.index++);
             rel_flag (& ((CONNEC *) connec)->semaphore);
             return (chr);
           }
        ((CONNEC *) connec)->receive_queue = walk->chain.next;
        KRfree (walk);
      }

   rel_flag (& ((CONNEC *) connec)->semaphore);

   return (E_NODATA);
 }


NDB *  cdecl  my_CNget_NDB (connec)

void  *connec;

{
   UDP_HDR  *walk;
   NDB      *data_blk;

   if (poll_receive (connec) < 0)
        return (NULL);

   wait_flag (& ((CONNEC *) connec)->semaphore);

   for (;;) {
        if ((walk = ((CONNEC *) connec)->receive_queue) == NULL)
             break;

        if (walk->chain.index < walk->chain.length) {
             if ((data_blk = KRmalloc (sizeof (NDB))) == NULL)
                  break;
             data_blk->ptr   = (uint8 *)  walk;
             data_blk->ndata = (uint8 *) (walk + 1) + walk->chain.index;
             data_blk->len   = walk->chain.length - walk->chain.index;
             data_blk->next  = NULL;
             ((CONNEC *) connec)->receive_queue = walk->chain.next;
             ((CONNEC *) connec)->total_data   -= data_blk->len;
             rel_flag (& ((CONNEC *) connec)->semaphore);
             return (data_blk);
           }

        ((CONNEC *) connec)->receive_queue = walk->chain.next;
        KRfree (walk);
      }

   rel_flag (& ((CONNEC *) connec)->semaphore);

   return (NULL);
 }


int16  cdecl  my_CNget_block (connec, buffer, length)

void   *connec;
void   *buffer;
int16  length;

{
   UDP_HDR  *walk;
   int16    error, count = 0, xfer;

   if ((error = poll_receive (connec)) < 0)
        return (error);

   if (length == 0)   return (0);

   if (length > ((CONNEC *) connec)->total_data)
        return (E_NODATA);

   wait_flag (& ((CONNEC *) connec)->semaphore);

   do {
        if ((walk = ((CONNEC *) connec)->receive_queue) == NULL) {
             rel_flag (& ((CONNEC *) connec)->semaphore);
             return (E_NODATA);
           }
        xfer = walk->chain.length - walk->chain.index;
        xfer = (length < xfer) ? length : xfer;
        memcpy (buffer, (uint8 *) (walk + 1) + walk->chain.index, xfer);
        buffer = (uint8 *) buffer + xfer;
        count += xfer;   length -= xfer;   walk->chain.index += xfer;

        if (walk->chain.index >= walk->chain.length) {
             ((CONNEC *) connec)->receive_queue = walk->chain.next;
             KRfree (walk);
           }
     } while (length > 0);

   ((CONNEC *) connec)->total_data -= count;

   rel_flag (& ((CONNEC *) connec)->semaphore);

   return (count);
 }


CIB *  cdecl  my_CNgetinfo (connec)

void  *connec;

{
   CIB  *cib;

   if (((CONNEC *) connec)->info == NULL) {
        if ((((CONNEC *) connec)->info = (CIB *) KRmalloc (sizeof (CIB))) == NULL)
             return (NULL);
        ((CONNEC *) connec)->info->status = 0;
      }

   cib = ((CONNEC *) connec)->info;

   cib->protocol = P_UDP;
   cib->address.lport = ((CONNEC *) connec)->local_port;
   cib->address.rport = ((CONNEC *) connec)->remote_port;
   cib->address.rhost = ((CONNEC *) connec)->remote_IP_address;
   cib->address.lhost = ((CONNEC *) connec)->local_IP_address;

   return (cib);
 }


int16  cdecl  my_CNgets (connec, buffer, length, delimiter)

void   *connec;
int16  length;
char   *buffer, delimiter;

{
   UDP_HDR  *walk, *free, *next;
   int16    error, cnt, amount = 0;
   uint8    *search;

   if ((error = poll_receive (connec)) < 0)
        return (error);

   if (((CONNEC *) connec)->total_data == 0)
        return (E_NODATA);

   if (length <= 1)
        return (E_BIGBUF);

   wait_flag (& ((CONNEC *) connec)->semaphore);

   for (walk = ((CONNEC *) connec)->receive_queue; walk != NULL; walk = walk->chain.next) {
        search = (uint8 *) (walk + 1) + walk->chain.index;

        for (cnt = 0; cnt < walk->chain.length - walk->chain.index && length > 1; cnt++, --length) {
             if (*search == delimiter)
                  break;
             *buffer++ = *search++;
           }
        amount += cnt;   *buffer = '\0';

        if (*search == delimiter || length == 1)
             break;
      }

   if (*search != delimiter) {
        rel_flag (& ((CONNEC *) connec)->semaphore);
        return ((length == 1) ? E_BIGBUF : E_NODATA);
      }

   for (free = ((CONNEC *) connec)->receive_queue; free != walk; free = next) {
        next = free->chain.next;
        KRfree (free);
      }
   ((CONNEC *) connec)->receive_queue = walk;

   walk->chain.index += cnt + 1;
   ((CONNEC *) connec)->total_data -= amount + 1;

   rel_flag (& ((CONNEC *) connec)->semaphore);

   return (amount);
 }


int16  cdecl  UDP_handler (dgram)

IP_DGRAM  *dgram;

{
   UDP_HDR  *hdr, *walk, **previous;
   CONNEC   *connect, *option;
   uint16   size;
   uint8    *icmp, *work;

   hdr = (UDP_HDR *) dgram->pkt_data;

   if (hdr->udp.checksum != 0) {
        if (check_sum (dgram->hdr.ip_src, dgram->hdr.ip_dest, hdr, hdr->udp.length) != 0xffff) {
             my_conf.stat_dropped++;
             return (TRUE);
           }
      }

   for (connect = root_list, option = NULL; connect; connect = connect->next) {
        if (hdr->udp.dest_port != connect->local_port)
             continue;
        if (connect->remote_port)
             if (hdr->udp.source_port != connect->remote_port)
                  continue;
        if (connect->local_IP_address)
             if (dgram->hdr.ip_dest != connect->local_IP_address)
                  continue;
        if (connect->remote_IP_address)
             if (dgram->hdr.ip_src  != connect->remote_IP_address)
                  continue;
        if (connect->local_IP_address && connect->remote_IP_address && connect->remote_port)
             break;
        option = connect;
      }

   if (connect == NULL && option != NULL) {
        connect = option;
        connect->local_IP_address  = dgram->hdr.ip_dest;
        connect->remote_IP_address = dgram->hdr.ip_src;
        connect->remote_port       = hdr->udp.source_port;
        if (connect->info) {
             connect->info->address.lhost  = connect->local_IP_address;
             connect->info->address.rhost  = connect->remote_IP_address;
             connect->info->address.rport  = connect->remote_port;
             connect->info->status = 0;
           }
        PRTCL_get_parameters (dgram->hdr.ip_src, NULL, & connect->ttl, NULL);
      }

   if (connect == NULL) {
        my_conf.stat_dropped++;
        if ((work = icmp = KRmalloc (size = dgram->hdr.hd_len * 4 + 12)) == NULL)
             return (TRUE);
        * (uint32 *) work = 0L;
        work += 4;
        memcpy (work, & dgram->hdr, sizeof (IP_HDR));
        work += sizeof (IP_HDR);
        memcpy (work, dgram->options, dgram->opt_length);
        work += dgram->opt_length;
        memcpy (work, dgram->pkt_data, 8);
        ICMP_send (dgram->hdr.ip_src, 3, 3, icmp, size);
        KRfree (icmp);
        return (TRUE);
      }

   dgram->pkt_data = NULL;

   hdr->chain.length -= sizeof (UDP_HDR);
   hdr->chain.index = 0;   hdr->chain.next = NULL;

   previous = & connect->pending;
   for (walk = *previous; walk; walk = * (previous = & walk->chain.next));
   *previous = hdr;

   return (TRUE);
 }


void  cdecl  timer_function()

{
   CONNEC  *connect;

   for (connect = root_list; connect; connect = connect->next)
        timer_work (connect);
 }


int16  poll_receive (connec)

CONNEC  *connec;

{
   int16  error;

   error = connec->net_error;

   if (error < 0) {
        connec->net_error = 0;   return (error);
      }

   if (TIMER_elapsed (connec->last_work) < 1200)
        return(0);

   wait_flag (& global_sema);   global = connec;
   Supexec (poll_doit);

   return(0);
 }


long  poll_doit()

{
   CONNEC  *connec;

   connec = global;   rel_flag (& global_sema);
   timer_work (connec);

   return (0L);
 }


void  timer_work (connec)

CONNEC  *connec;

{
   UDP_HDR  *queue, *walk, **previous;
   uint32   pending;

   if (req_flag (& connec->semaphore) != 0)
        return;

   if (connec->pending) {
        queue = get_pending (& connec->pending);
        pending = 0;
        for (walk = queue; walk; walk = walk->chain.next)
             pending += walk->chain.length;
        previous = & connec->receive_queue;
        for (walk = *previous; walk; walk = * (previous = & walk->chain.next));
        *previous = queue;
        connec->total_data += pending;
      }

   connec->last_work = TIMER_now();
   rel_flag (& connec->semaphore);
 }


int16  cdecl  do_ICMP (dgram)

IP_DGRAM  *dgram;

{
   IP_HDR   *ip;
   UDP_HDR  *udp;
   CONNEC   *connect;
   uint8    type, code;

   if ((my_conf.flags & 0x10000ul) == 0)
        return (FALSE);

   type = *  (uint8 *) dgram->pkt_data;
   code = * ((uint8 *) dgram->pkt_data + 1);

   if (type != 3 && type != 4 && type != 11)
        return (FALSE);

   ip = (IP_HDR *) ((uint8 *) dgram->pkt_data + 8);

   if (ip->protocol != P_UDP)
        return (FALSE);

   udp = (UDP_HDR *) ((uint8 *) ip + ip->hd_len * 4);

   for (connect = root_list; connect; connect = connect->next) {
        if (udp->udp.source_port != connect->local_port)
             continue;
        if (udp->udp.dest_port   != connect->remote_port)
             continue;
        if (ip->ip_src  != connect->local_IP_address)
             continue;
        if (ip->ip_dest != connect->remote_IP_address)
             continue;
        break;
      }

   if (connect) {
        if (connect->info)
             connect->info->status = (uint16) type << 8 | code;

        switch (type) {
           case  3 :   connect->net_error = E_UNREACHABLE;   break;
           case  4 :   connect->net_error = E_CNTIMEOUT;     break;
           case 11 :   connect->net_error = E_TTLEXCEED;     break;
           }
      }

   ICMP_discard (dgram);
   return (TRUE);
 }
