
/*********************************************************************/
/*                                                                   */
/*     STinG : Modem Dialer, Network tools                           */
/*                                                                   */
/*                                                                   */
/*      Version 1.0                        from 16. Januar 1997      */
/*                                                                   */
/*      Module for Ping and Traceroute                               */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <string.h>
#include <device.h>

#include "dial.h"
#include "window.h"

#include "transprt.h"
#include "port.h"


#define  FALSE                0
#define  TRUE                 1
#define  CNTRL_C         0x2e03
#define  CNTRL_Q         0x1011

#define  ICMP_ECHO_REPLY      0
#define  ICMP_ECHO            8

#define  ICMP_DEST_UNREACH    3
#define  ICMP_DU_PRTCL        2
#define  ICMP_DU_PORT         3
#define  ICMP_TTL_EXCEED     11

#define  UDP_PORT         65530u

#define  MIN(a,b)         (((a) < (b)) ? (a) : (b))
#define  MAX(a,b)         (((a) > (b)) ? (a) : (b))


typedef struct ps_hdr {
     uint32   src_ip;
     uint32   dest_ip;
     uint8    zero;
     uint8    protocol;
     uint16   udp_len;
 } PS_HDR;

typedef struct udp_pckt {
     uint16   src_port;
     uint16   dest_port;
     uint16   length;
     uint16   chk_sum;
     uint16   ident;
 } UDP_PCKT;

typedef struct pudp_hdr {
     PS_HDR    ps_hdr;
     UDP_PCKT  udp_packet;
 } PUDP;

typedef  struct text {
     struct text  *next;
     uint32       num_ip;
     char         *text_ip, *text_dn;
 } STRING;


void    show_statistics (void);

uint32  load_ip_addr (unsigned char ip[], char buffer[]);

void          set_memory (void);
void          show_memory (void);
void          set_ram_string (long value, int index, int redraw);
int           mem_click (int object);
int           mem_key_typed (int scancode);
long          get_blocks (void);
void          set_stat_string (long value, int index, int redraw);
int           stat_click (int object);
int           stat_key_typed (int scancode);
void          set_routing (void);
int           routing_click (int object);
void          show_routing (int redraw_flag);
void          put_ip_addr (char *string, uint32 ip_address);
int           init_resolve (void);
int           resolve_click (int object);
int           my_resolve (char *domain, char **real, uint32 *ip, int16 len);
int           spawn_ping (int object);
void          do_ping (void);
long          fetch_clock (void);
int16  cdecl  ping_echo (IP_DGRAM *datagram);
int           ping_click (int object);
int           ping_key_typed (int scan);
int           spawn_traceroute (int object);
void          do_traceroute (void);
void          send_packet (void);
int16  cdecl  trace_echo (IP_DGRAM *datagram);
void          trace_proceed (void);
int           complete_list (void);
void          erase_list (void);
int           trace_click (int object);
int           trace_key_typed (int scan);


struct mem {
    long  sting_ttl, sting_lblk, st_ttl, st_lblk, alt_ttl, alt_lblk;
 } blocks;

extern void  (* mem_timer) (void), (* stat_timer) (void);
extern void  (* ping_timer) (void), (* trace_timer) (void);

PUDP    packet;
STRING  *router = NULL;
int16   stat_port, stat_layer, route_num, route_index;
int16   rslv_height = 0, rslv_m_pos, rslv_frame, rslv_min;
int16   do_send, num_sent, num_recvd, sent, act_ttl, old_num, timeout, shown;
uint32  ping_host, trace_host;
long    my_times[3], ping_times[3], max, ave, min, intrpt[3], mine[3];
char    ip_space[] = "%d.%d.%d.%d        ", dash[] = "  -- ";

int     net_lst[]   = { OU_NET1, OU_NET2, OU_NET3, OU_NET4, OU_NET5, OU_NET6, OU_NET7, 
                        OU_NET8, OU_NET9, OU_NET10 };
int     mask_lst[]  = { OU_MSK1, OU_MSK2, OU_MSK3, OU_MSK4, OU_MSK5, OU_MSK6, OU_MSK7, 
                        OU_MSK8, OU_MSK9, OU_MSK10 };
int     port_lst[]  = { OU_PRT1, OU_PRT2, OU_PRT3, OU_PRT4, OU_PRT5, OU_PRT6, OU_PRT7, 
                        OU_PRT8, OU_PRT9, OU_PRT10 };
int     gate_lst[]  = { OU_GTW1, OU_GTW2, OU_GTW3, OU_GTW4, OU_GTW5, OU_GTW6, OU_GTW7, 
                        OU_GTW8, OU_GTW9, OU_GTW10 };

int     trtab_hop[] = { OT_HOP1, OT_HOP2, OT_HOP3, OT_HOP4, OT_HOP5, OT_HOP6, OT_HOP7, 
                        OT_HOP8, OT_HOP9, OT_HOP10 };
int     trtab_ip[]  = { OT_IP1, OT_IP2, OT_IP3, OT_IP4, OT_IP5, OT_IP6, OT_IP7, 
                        OT_IP8, OT_IP9, OT_IP10 };
int     trtab_dn[]  = { OT_DN1, OT_DN2, OT_DN3, OT_DN4, OT_DN5, OT_DN6, OT_DN7, 
                        OT_DN8, OT_DN9, OT_DN10 };

int     ip_fld[] = { R_IP1, R_IP2, R_IP3, R_IP4, R_IP5, R_IP6, R_IP7, R_IP8  };

char    icmp_problem[]  = "[1][ |  Problem using ICMP !   ][ Cancel ]";
char    route_problem[] = "[1][ |  No Route to this host !   ][ Cancel ]";
char    mem_problem[]   = "[1][ |  Out of internal memory !   ][ Cancel ]";
char    send_problem[]  = "[1][ |  Problem sending packet !   ][ Cancel ]";



void  set_memory()

{
   OBJECT  *tree;
   int     offset;

   rsrc_gaddr (R_TREE, O_MEM, &tree);

   if (! Supexec (get_blocks))
        if ((tree[OM_ARAM].ob_flags & HIDETREE) == 0) {
             tree[OM_ARAM].ob_flags |= HIDETREE;
             offset = tree[OM_STRAM].ob_y - tree[OM_STING].ob_y;
             tree[OM_BOX].ob_height -= offset;   tree[0].ob_height -= offset;
           }

   set_ram_string (blocks.sting_ttl,  SKR_TTL,  FALSE);
   set_ram_string (blocks.sting_lblk, SKR_LBLK, FALSE);
   set_ram_string (blocks.st_ttl,     STR_TTL,  FALSE);
   set_ram_string (blocks.st_lblk,    STR_LBLK, FALSE);
   set_ram_string (blocks.alt_ttl,    ALR_TTL,  FALSE);
   set_ram_string (blocks.alt_lblk,   ALR_LBLK, FALSE);
 }


void  show_memory()

{
   Supexec (get_blocks);

   set_ram_string (blocks.sting_ttl,  SKR_TTL,  TRUE);
   set_ram_string (blocks.sting_lblk, SKR_LBLK, TRUE);
   set_ram_string (blocks.st_ttl,     STR_TTL,  TRUE);
   set_ram_string (blocks.st_lblk,    STR_LBLK, TRUE);
   set_ram_string (blocks.alt_ttl,    ALR_TTL,  TRUE);
   set_ram_string (blocks.alt_lblk,   ALR_LBLK, TRUE);
 }


void  set_ram_string (value, index, redraw_flag)

long  value;
int   index, redraw_flag;

{
   char  number[12];

   sprintf (number, "%8ld", value);
   change_tedinfo (O_MEM, index, (redraw_flag) ? index : -1, TE_PTEXT, number, 8);
 }


int  mem_click (object)

int  object;

{
   if ((object & 0x7fff) == CLOSER_CLICKED)
        mem_timer = NULL;

   return (0);
 }


int  mem_key_typed (scan)

int  scan;

{
   if (scan == CNTRL_Q)   mem_timer = NULL;

   return ((scan == CNTRL_Q) ? -1 : 1);
 }


long  get_blocks()

{
   long  *array, length;
   int   count;

   blocks.sting_ttl  = KRgetfree (FALSE);
   blocks.sting_lblk = KRgetfree (TRUE);

   if (Sversion() >= 0x1900) {
        array = (long *) Mxalloc (
                   blocks.st_ttl = blocks.st_lblk = (long) Mxalloc(-1L, 0), 0);
        if (array != NULL) {
             for (count = 0; (length = (long) Mxalloc (-1L, 0)) > 10; count++) {
                  blocks.st_ttl += length;
                  array[count] = (long) Mxalloc (length, 0);
                }
             for (--count; count >= 0; --count)
                  Mfree ((void *) array[count]);
             Mfree (array);
           }
        array = (long *) Mxalloc (
                   blocks.alt_ttl = blocks.alt_lblk = (long) Mxalloc(-1L, 1), 1);
        if (array != NULL) {
             for (count = 0; (length = (long) Mxalloc (-1L, 1)) > 10; count++) {
                  blocks.alt_ttl += length;
                  array[count] = (long) Mxalloc (length, 1);
                }
             for (--count; count >= 0; --count)
                  Mfree ((void *) array[count]);
             Mfree (array);
           }
      }
     else {
        array = (long *) Malloc (blocks.st_ttl = blocks.st_lblk = (long) Malloc(-1L));
        if (array != NULL) {
             for (count = 0; (length = (long) Malloc (-1L)) > 10; count++) {
                  blocks.st_ttl += length;
                  array[count] = (long) Malloc (length);
                }
             for (--count; count >= 0; --count)
                  Mfree ((void *) array[count]);
             Mfree (array);
           }
      }

   return (Sversion() >= 0x1900);
 }


void  set_stat_string (value, index, redraw_flag)

long  value;
int   index, redraw_flag;

{
   char  number[12];

   sprintf (number, "%8ld", value);
   change_tedinfo (O_STAT, index, (redraw_flag) ? index : -1, TE_PTEXT, number, 8);
 }


int  stat_click (object)

int  object;

{
   int  last_shown;

   switch (object & 0x7fff) {
      case  OS_PORT :
        last_shown = stat_port++;
        pop_up (PU_S_PRT, & stat_port, O_STAT, OS_PORT, 10);
        if (last_shown != --stat_port)
             show_statistics();
        break;
      case  OS_LAYER :
        last_shown = stat_layer++;
        pop_up (PU_S_LAY, & stat_layer, O_STAT, OS_LAYER, 10);
        if (last_shown != --stat_layer)
             show_statistics();
        break;
      case  CLOSER_CLICKED :
        stat_timer = NULL;
        break;
      }

   return (0);
 }


int  stat_key_typed (scan)

int  scan;

{
   if (scan == CNTRL_Q)   stat_timer = NULL;

   return ((scan == CNTRL_Q) ? -1 : 1);
 }


void  set_routing()

{
   OBJECT  *tree;
   PORT    *port_dummy;
   uint32  dummy;

   rsrc_gaddr (R_TREE, O_ROUTE, &tree);

   if ((route_num = get_route_entry (0, & dummy, & dummy, & port_dummy, & dummy)) < 0)
        route_num = 0;

   if (route_num <= 10)
        tree[OU_SLDBX].ob_flags |= HIDETREE;
     else
        tree[OU_SLDBX].ob_flags &= ~ HIDETREE;

   if (route_num)
        tree[OU_SLDR].ob_height = tree[OU_PRNT].ob_height * 10 / route_num;

   route_index = 0;
   tree[OU_SLDR].ob_y = 0;

   show_routing (FALSE);
 }


int  routing_click (object)

int  object;

{
   OBJECT  *tree;
   int     m_x, m_y, m_stat, keybd, s_x, s_y, offset;

   rsrc_gaddr (R_TREE, O_ROUTE, & tree);

   switch (object & 0x7fff) {
      case OU_UP :
        if (route_index > 0) {
             --route_index;   show_routing (TRUE);
           }
        change_flags (O_ROUTE, OU_UP, FALSE, 0, SELECTED);
        break;
      case OU_DOWN :
        if (route_index < route_num - 10) {
             route_index++;   show_routing (TRUE);
           }
        change_flags (O_ROUTE, OU_DOWN, FALSE, 0, SELECTED);
        break;
      case OU_PRNT :
        graf_mkstate (& m_x, & m_y, & m_stat, & keybd);
        if (objc_find (tree, OU_SLDBX, 3, m_x, m_y) == OU_PRNT) {
             objc_offset (tree, OU_SLDR, & s_x, & s_y);
             route_index += (m_y > s_y) ? 10 : -10;
             route_index = MAX (route_index, 0);
             route_index = MIN (route_index, route_num - 10);
             show_routing (TRUE);
           }
        break;
      case OU_SLDR :
        graf_mkstate (& m_x, & m_y, & m_stat, & keybd);
        if (route_num > 10) {
             offset = 500 / (route_num - 10);
             if (m_stat & 0x01) {
                  route_index = offset + graf_slidebox (tree, OU_PRNT, OU_SLDR, 1);
                  route_index = (route_num - 10) * route_index / 1000;
                }
             show_routing (TRUE);
           }
        break;
      }

   return (0);
 }


void  show_routing (redraw_flag)

int  redraw_flag;

{
   OBJECT  *tree;
   PORT    *port;
   uint32  net, mask, gate;
   int     count;

   rsrc_gaddr (R_TREE, O_ROUTE, &tree);

   for (count = 0; count < 10; count++) {
        if (get_route_entry (route_index + count, & net, & mask, & port, & gate) < 0) {
             *tree[ net_lst[count]].ob_spec.free_string = '\0';
             *tree[mask_lst[count]].ob_spec.free_string = '\0';
             *tree[port_lst[count]].ob_spec.free_string = '\0';
             *tree[gate_lst[count]].ob_spec.free_string = '\0';
           }
          else {
             if (net != 0L || mask != 0L) {
                  put_ip_addr (tree[ net_lst[count]].ob_spec.free_string,  net);
                  put_ip_addr (tree[mask_lst[count]].ob_spec.free_string, mask);
                }
               else {
                  strcpy (tree[net_lst[count]].ob_spec.free_string, "Default Route");
                  *tree[mask_lst[count]].ob_spec.free_string = '\0';
                }
             if (port->type > L_PAR_PTP)
                  put_ip_addr (tree[gate_lst[count]].ob_spec.free_string, gate);
               else
                  strcpy (tree[gate_lst[count]].ob_spec.free_string, dash);
             strncpy (tree[port_lst[count]].ob_spec.free_string, port->name, 12);
           }
      }

   tree[OU_SLDR].ob_y = (route_num <= 10) ? 0 : route_index *
                  (tree[OU_PRNT].ob_height - tree[OU_SLDR].ob_height) / (route_num - 10);

   if (redraw_flag) {
        change_flags (O_ROUTE, OU_BIGBX, 0, 0, 0);   change_flags (O_ROUTE, OU_PRNT, 0, 0, 0);
      }
 }


void  put_ip_addr (text, ip_addr)

char    *text;
uint32  ip_addr;

{
   long  ip_a, ip_b, ip_c, ip_d;

   ip_a = (ip_addr >> 24) & 0xff;   ip_c = (ip_addr >> 8) & 0xff;
   ip_b = (ip_addr >> 16) & 0xff;   ip_d =  ip_addr       & 0xff;

   sprintf (text, "%ld.%ld.%ld.%ld", ip_a, ip_b, ip_c, ip_d);
 }


int  init_resolve()

{
   OBJECT  *tree;

   rsrc_gaddr (R_TREE, O_RSLV, &tree);

   if (rslv_height == 0) {
        rslv_height = tree[0].ob_height;   rslv_m_pos = tree[RM_BOX].ob_y;
        rslv_frame = tree[RIP_FRM].ob_height;
        rslv_min = tree[RM_BOX].ob_y + tree[DO_RSLV].ob_y + tree[DO_RSLV].ob_height * 3/2;
      }

   tree[ RA_BOX].ob_flags |= HIDETREE;
   tree[RIP_BOX].ob_flags |= HIDETREE;   tree[RM_BOX].ob_y = tree[RA_BOX].ob_y;

   tree[0].ob_height = rslv_min;
   tree[R_HOST].ob_spec.tedinfo->te_ptext[0] = '@';

   return(0);
 }


int  resolve_click (object)

int  object;

{
   OBJECT  *tree;
   int16   result, count, height, min_height;
   uint32  ip_array[8], tmp;
   char    domain[64], temp[25], *real_domain, *wrk, *error;

   if ((object & 0x7fff) != DO_RSLV)   return(0);

   rsrc_gaddr (R_TREE, O_RSLV, &tree);
   tree[DO_RSLV].ob_state &= ~SELECTED;

   strncpy (domain, tree[R_HOST].ob_spec.tedinfo->te_ptext, 48);

   result = my_resolve (domain, &real_domain, ip_array, 8);

   if (result >= 0) {
        strncpy (tree[R_ALIAS].ob_spec.tedinfo->te_ptext, real_domain, 48);
        wrk = tree[R_ALIAS].ob_spec.tedinfo->te_ptext;
        for (wrk = &wrk[count = (int) strlen (real_domain)]; count < 48; count++)
             *wrk++ = ' ';

        for (count = 0; count < 8; count++)
             if (count < result) {
                  tmp = ip_array[count];
                  sprintf (temp, ip_space, (int) (tmp >> 24), (int) ((tmp >> 16) & 0xff),
                           (int) ((tmp >> 8) & 0xff), (int) (tmp & 0xff));
                  strncpy (tree[ip_fld[count]].ob_spec.tedinfo->te_ptext, temp, 15);
                  tree[ip_fld[count]].ob_flags &= ~HIDETREE;
                }
               else
                  tree[ip_fld[count]].ob_flags |= HIDETREE;

        tree[ RA_BOX].ob_flags &= ~HIDETREE;
        tree[RIP_BOX].ob_flags &= ~HIDETREE;   tree[RM_BOX].ob_y = rslv_m_pos;
        tree[RIP_FRM].ob_height = rslv_frame - 
                        (8 - result) * (tree[R_IP2].ob_y - tree[R_IP1].ob_y);
        height = rslv_height - (rslv_frame - tree[RIP_FRM].ob_height);
        min_height = rslv_min + rslv_m_pos - tree[RA_BOX].ob_y;

        if (strcmp (domain, real_domain) == 0) {
             tree[RM_BOX].ob_y = tree[RA_BOX].ob_y;   tree[RA_BOX].ob_flags |= HIDETREE;
             height -= rslv_m_pos - tree[RM_BOX].ob_y;   min_height = rslv_min;
           }
        KRfree (real_domain);
      }
     else {
        switch (result) {
           case E_CANTRESOLVE :
             error = "[1][ |  Can't resolve the hostname ...  ][ Hmmm ]";
             break;
           case E_NOHOSTNAME :
             error = "[1][ |  Hostname does not exist ...  ][ Hmmm ]";
             break;
           }
        form_alert (1, error);

        count = tree[R_HOST].ob_spec.tedinfo->te_ptext[0];
        init_resolve();
        tree[R_HOST].ob_spec.tedinfo->te_ptext[0] = count;
        height = min_height = rslv_min;
      }
   change_rsc_size (O_RSLV, -1, MAX (height, min_height), OR_BOX);

   return (0);
 }


int  my_resolve (domain, real_domain, ip_array, arr_len)

char    *domain, **real_domain;
uint32  *ip_array;
int16   arr_len;

{
   int   result;
   char  *error, string[64];

   if ((result = resolve (domain, real_domain, ip_array, arr_len)) >= 0)
        return (result);

   if (result == E_CANTRESOLVE || result == E_NOHOSTNAME)
        return (result);

   switch (result) {
      case E_NOMEM :
        error = "[1][ |  Resolve failed due to lack  | |    of memory ...][ Hmmm ]";
        break;
      case E_BADDNAME :
        error = "[1][ |  Bad format in domain name ...  ][ Hmmm ]";
        break;
      case E_DNSWORKLIMIT :
        error = "[1][ |  Resolver work limit reached ...  ][ Hmmm ]";
        break;
      case E_NONAMESERVER :
        error = "[1][ |  No nameservers could be found  | |    for query ...  ][ Hmmm ]";
        break;
      case E_DNSBADFORMAT :
        error = "[1][ |  Bad format of DNS query ...  ][ Hmmm ]";
        break;
      case E_DNSNOADDR :
        error = "[1][ |  No address records exist  | |    for host ...][ Hmmm ]";
        break;
      case -13579 :
        error = "[1][ |  This is not a valid host\'s  | |    domain name ...][ Hmmm ]";
        break;
      default :
        sprintf (string, "[1][ |  STinG returned error  | |    code %d ...][ Hmmm ]", result);
        error = string;
      }

   form_alert (1, error);

   return (result);
 }


int  spawn_ping (object)

int  object;

{
   OBJECT  *tree;
   char    *name, *error, dest[25];
   uint8   ip[4];
   int16   result;

   if ((object & 0x7fff) != OP_OK)
        return (1);

   rsrc_gaddr (R_TREE, O_PING, & tree);

   tree[OP_OK].ob_state &= ~SELECTED;
   name = tree[OP_HOST].ob_spec.tedinfo->te_ptext;

   ping_host = load_ip_addr (ip, name);

   if (ping_host == 0) {
        if ((result = my_resolve (name, NULL, & ping_host, 1)) <= 0) {
             switch (result) {
                case E_CANTRESOLVE :
                  error = "[1][ |  Can't resolve the hostname ...  ][ Hmmm ]";
                  break;
                case E_NOHOSTNAME :
                  error = "[1][ |  Hostname does not exist ...  ][ Hmmm ]";
                  break;
                }
             form_alert (1, error);
             return (1);
           }
      }
     else
        evnt_timer (60, 0);

   if (! ICMP_handler (ping_echo, HNDLR_SET)) {
        form_alert (1, icmp_problem);
        return (1);
      }

   open_rsc_window (OP_DOIT, 0, " STinG : Ping ", " Ping ", O_PING);
   set_callbacks (OP_DOIT, ping_click, ping_key_typed);
   ping_timer = do_ping;

   rsrc_gaddr (R_TREE, OP_DOIT, & tree);

   sprintf (dest, "%ld.%ld.%ld.%ld        ", (ping_host >> 24) & 0xff, (ping_host >> 16) & 0xff,
                  (ping_host >> 8) & 0xff, ping_host & 0xff);
   strncpy (tree[OP_IP].ob_spec.tedinfo->te_ptext, dest, 15);

   sprintf (dest, "%d     ", num_sent = num_recvd = 0);
   strncpy (tree[OP_SENT ].ob_spec.tedinfo->te_ptext, dest, 5);
   strncpy (tree[OP_RECVD].ob_spec.tedinfo->te_ptext, dest, 5);

   strcpy (tree[OP_RTT1].ob_spec.tedinfo->te_ptext, dash);
   strcpy (tree[OP_RTT2].ob_spec.tedinfo->te_ptext, dash);
   strcpy (tree[OP_RTT3].ob_spec.tedinfo->te_ptext, dash);
   strcpy (tree[OP_MINI].ob_spec.tedinfo->te_ptext, dash);
   strcpy (tree[OP_AVE ].ob_spec.tedinfo->te_ptext, dash);
   strcpy (tree[OP_MAXI].ob_spec.tedinfo->te_ptext, dash);

   min = 50000u;   ave = max = 0;
   intrpt[0] = intrpt[1] = intrpt[2] = -1;
   do_send = TRUE;

   return (1);
 }


void  do_ping()

{
           OBJECT  *tree;
           char    value[10];
           uint16  buffer[16];
   static  uint16  sequence = 0;

   buffer[0] = 0xaffeu;   buffer[1] = sequence++;
   * (long *) &buffer[2] = Supexec (fetch_clock);

   buffer[4] = 0xa5a5u;   buffer[5] = 0x5a5au;
   buffer[6] = 0x0f0fu;   buffer[7] = 0xf0f0u;

   if (do_send) {
        ICMP_send (ping_host, ICMP_ECHO, 0, buffer, 32);
        num_sent++;
      }

   rsrc_gaddr (R_TREE, OP_DOIT, & tree);

   sprintf (value, "%d     ", num_sent);
   change_tedinfo (OP_DOIT, OP_SENT,  OP_SENT,  TE_PTEXT, value, 5);
   sprintf (value, "%d     ", num_recvd);
   change_tedinfo (OP_DOIT, OP_RECVD, OP_RECVD, TE_PTEXT, value, 5);

   if (num_recvd == 0)   return;

   mine[0] = intrpt[0];   mine[1] = intrpt[1];   mine[2] = intrpt[2];
   sprintf (value, "%5ld", mine[0] * 5L);
   change_tedinfo (OP_DOIT, OP_RTT1, OP_RTT1, TE_PTEXT, (mine[0] > 0) ? value : dash, 5);
   sprintf (value, "%5ld", mine[1] * 5L);
   change_tedinfo (OP_DOIT, OP_RTT2, OP_RTT2, TE_PTEXT, (mine[0] > 0) ? value : dash, 5);
   sprintf (value, "%5ld", mine[2] * 5L);
   change_tedinfo (OP_DOIT, OP_RTT3, OP_RTT3, TE_PTEXT, (mine[0] > 0) ? value : dash, 5);

   sprintf (value, "%5ld", min * 5L);
   change_tedinfo (OP_DOIT, OP_MINI, OP_MINI, TE_PTEXT, value, 5);
   sprintf (value, "%5ld", ave * 5L / num_recvd);
   change_tedinfo (OP_DOIT, OP_AVE,  OP_AVE,  TE_PTEXT, value, 5);
   sprintf (value, "%5ld", max * 5L);
   change_tedinfo (OP_DOIT, OP_MAXI, OP_MAXI, TE_PTEXT, value, 5);
 }


long  fetch_clock()

{
   return (* (long *) 0x4baL);
 }


int16  cdecl  ping_echo (datagram)

IP_DGRAM  *datagram;

{
   uint16  *data, delay;

   data = datagram->pkt_data;

   if (data[0] != (ICMP_ECHO_REPLY << 8) || data[2] != 0xaffeu)
        return (FALSE);

   num_recvd++;
   delay = (uint16) (fetch_clock() - * (long *) &data[4]);

   intrpt[0] = intrpt[1];   intrpt[1] = intrpt[2];   intrpt[2] = delay;   

   if (min > delay)   min = delay;
   if (max < delay)   max = delay;
   ave += delay;

   ICMP_discard (datagram);

   return (TRUE);
 }


int  ping_click (object)

int  object;

{
   if ((object & 0x7fff) == OP_STOP) {
        do_send = FALSE;
        evnt_timer (60, 0);
        change_flags (OP_DOIT, OP_STOP, FALSE, 0, SELECTED);
      }

   if ((object & 0x7fff) == CLOSER_CLICKED) {
        ping_timer = NULL;
        ICMP_handler (ping_echo, HNDLR_REMOVE);
      }
   return (0);
 }


int  ping_key_typed (scan)

int  scan;

{
   if (scan == CNTRL_C)
        do_send = FALSE;

   if (scan == CNTRL_Q) {
        ping_timer = NULL;
        ICMP_handler (ping_echo, HNDLR_REMOVE);
      }
   return ((scan == CNTRL_Q) ? -1 : 1);
 }


int  spawn_traceroute (object)

int  object;

{
   OBJECT  *tree;
   char    *name, *error;
   uint8   ip[4];
   int16   result, count;
   uint16  *walk;
   uint32  chksum = 0;

   if ((object & 0x7fff) != OT_OK)
        return (1);

   rsrc_gaddr (R_TREE, O_TRACE, & tree);

   tree[OT_OK].ob_state &= ~SELECTED;
   name = tree[OT_HOST].ob_spec.tedinfo->te_ptext;

   trace_host = load_ip_addr (ip, name);

   if (trace_host == 0) {
        if ((result = my_resolve (name, NULL, & trace_host, 1)) <= 0) {
             switch (result) {
                case E_CANTRESOLVE :
                  error = "[1][ |  Can't resolve the hostname ...  ][ Hmmm ]";
                  break;
                case E_NOHOSTNAME :
                  error = "[1][ |  Hostname does not exist ...  ][ Hmmm ]";
                  break;
                }
             form_alert (1, error);
             return (1);
           }
      }
     else
        evnt_timer (60, 0);

   if (PRTCL_get_parameters (trace_host, & packet.ps_hdr.src_ip, NULL, NULL) != E_NORMAL) {
        form_alert (1, route_problem);
        return (1);
      }

   if (! ICMP_handler (trace_echo, HNDLR_SET)) {
        form_alert (1, icmp_problem);
        return (1);
      }

   open_rsc_window (OT_DOIT, 0, " STinG : Trace Route ", " TraceRoute ", O_TRACE);
   set_callbacks (OT_DOIT, trace_click, trace_key_typed);
   trace_timer = do_traceroute;

   rsrc_gaddr (R_TREE, OT_DOIT, & tree);

   for (count = 0; count < 10; count++) {
        *tree[trtab_hop[count]].ob_spec.free_string = '\0';
        tree[trtab_ip [count]].ob_spec.free_string = "";
        tree[trtab_dn [count]].ob_spec.free_string = "";
      }
   tree[OT_SLDBX].ob_flags |= HIDETREE;
   memset (tree[OT_DEST].ob_spec.tedinfo->te_ptext, ' ', 48);
   strncpy (tree[OT_DEST].ob_spec.tedinfo->te_ptext, name, strlen (name));
   strcpy (tree[OT_STATE].ob_spec.tedinfo->te_ptext, "Tracing. ");

   packet.ps_hdr.dest_ip       = trace_host;
   packet.ps_hdr.zero          = 0;
   packet.ps_hdr.protocol      = P_UDP;
   packet.ps_hdr.udp_len       = (int16) sizeof (UDP_PCKT);
   packet.udp_packet.src_port  = 0;
   packet.udp_packet.dest_port = UDP_PORT;
   packet.udp_packet.length    = (int16) sizeof (UDP_PCKT);
   packet.udp_packet.chk_sum   = 0;
   packet.udp_packet.ident     = 0xaffaU;

   for (walk = (uint16 *) & packet, count = 0; count < sizeof (PUDP) / 2; walk++, count++)
        chksum += *walk;

   packet.udp_packet.chk_sum = ~ (uint16) ((chksum & 0xffffL) + ((chksum >> 16) & 0xffffL));

   act_ttl = old_num = 1;   sent = FALSE;   shown = 0;
   erase_list();

   return (1);
 }


void  do_traceroute()

{
   if (! sent)   send_packet();
     else {
        if (--timeout == 0)   send_packet();
      }

   complete_list();
 }


void  send_packet()

{
   UDP_PCKT  *dgram;
   int16     what;

   if ((dgram = KRmalloc (sizeof (UDP_PCKT))) == NULL) {
        form_alert (1, mem_problem);
        ICMP_handler (trace_echo, HNDLR_REMOVE);
        trace_timer = NULL;
        return;
      }
   memcpy (dgram, & packet.udp_packet, sizeof (UDP_PCKT));

   what = IP_send (packet.ps_hdr.src_ip, packet.ps_hdr.dest_ip, 0, TRUE, act_ttl, P_UDP,
            32768u + act_ttl, dgram, (int16) sizeof (UDP_PCKT), NULL, 0);

   if (what == E_NOMEM || what == E_UNREACHABLE) {
        form_alert (1, "[1][ |   Problem sending packet !   ][ Tja ]");
        KRfree (dgram);
        ICMP_handler (trace_echo, HNDLR_REMOVE);
        trace_timer = NULL;
        return;
      }

   sent = TRUE;
   timeout = 50;
 }


int16  cdecl  trace_echo (datagram)

IP_DGRAM  *datagram;

{
   UDP_PCKT  *packet;
   STRING    *entry, *walk, **previous;
   uint8     *icmp;

   icmp = datagram->pkt_data;

   if (*icmp != ICMP_TTL_EXCEED && *icmp != ICMP_DEST_UNREACH)
        return (FALSE);

   if (((IP_HDR *) & icmp[8])->protocol != P_UDP)
        return (FALSE);

   packet = (UDP_PCKT *) (& icmp[8] + ((IP_HDR *) & icmp[8])->hd_len * 4);

   if (packet->src_port != 0 || packet->dest_port != UDP_PORT)
        return (FALSE);

   if ((entry = KRmalloc (sizeof (STRING))) == NULL)
        return (FALSE);

   sent = FALSE;

   entry->text_ip = entry->text_dn = NULL;
   entry->next = NULL;
   entry->num_ip = datagram->hdr.ip_src;

   for (walk = *(previous = & router); walk; walk = *(previous = &walk->next));
   *previous = entry;

   if (++act_ttl == 99 || icmp[0] == ICMP_DEST_UNREACH)
        trace_timer = trace_proceed;

   ICMP_discard (datagram);

   return (TRUE);
 }


void  trace_proceed()

{
   change_tedinfo (OT_DOIT, OT_STATE, OT_STATE, TE_PTEXT, "Finished.", 9);

   complete_list();

   trace_timer = NULL;
 }


int  complete_list()

{
   OBJECT  *tree;
   STRING  *walk;
   uint32  ip;
   int16   num_entry, chg_box, chg_sldr, count, idx, offs;

   rsrc_gaddr (R_TREE, OT_DOIT, & tree);

   num_entry = act_ttl - 1;
   chg_box = chg_sldr = FALSE;

   for (walk = router, count = 0; walk; walk = walk->next, count++) {
        if (walk->text_ip == NULL) {
             if ((walk->text_ip = KRmalloc (16)) != NULL) {
                  ip = walk->num_ip;
                  sprintf (walk->text_ip, "%ld.%ld.%ld.%ld", (ip >> 24) & 0xff, (ip >> 16) & 0xff,
                                           (ip >> 8) & 0xff, ip & 0xff);
                  if (shown <= count && count < shown + 10)
                       chg_box = TRUE;
                  resolve (walk->text_ip, & walk->text_dn, NULL, 0);
                }
           }
        if (shown <= count && count < shown + 10) {
             idx = count - shown;
             sprintf (tree[trtab_hop[idx]].ob_spec.free_string, "%2d", count + 1);
             tree[trtab_ip [idx]].ob_spec.free_string = (walk->text_ip) ? walk->text_ip : "";
             tree[trtab_dn [idx]].ob_spec.free_string = (walk->text_dn) ? walk->text_dn : "";
           }
        if (count == 10) {
             if (old_num != num_entry)   chg_sldr = TRUE;
             old_num = num_entry;
             offs = num_entry / 2;
             tree[OT_SLDR].ob_height = (int) ((tree[OT_PRNT].ob_height * 10L + offs) / num_entry);
             tree[OT_SLDR].ob_y = (int) ((tree[OT_PRNT].ob_height * (long)shown + offs) / num_entry);
             if ((tree[OT_SLDBX].ob_flags & HIDETREE) != 0) {
                  chg_sldr = FALSE;
                  tree[OT_SLDBX].ob_flags &= ~HIDETREE;
                  change_flags (OT_DOIT, OT_SLDBX, 0, 0, 0);
                }
           }
      }

   if (chg_box)
        change_flags (OT_DOIT, OT_BIGBX, 0, 0, 0);
   if (chg_sldr)
        change_flags (OT_DOIT, OT_PRNT, 0, 0, 0);

   return (chg_box);
 }


void  erase_list()

{
   STRING  *aux;

   while (router) {
        KRfree (router->text_ip);   KRfree (router->text_dn);
        aux = router->next;         KRfree (router);
        router = aux;
      }
 }


int  trace_click (object)

int  object;

{
   OBJECT  *tree;
   int     m_x, m_y, m_stat, keybd, s_x, s_y, offset;

   rsrc_gaddr (R_TREE, OT_DOIT, & tree);

   switch (object & 0x7fff) {
      case OT_UP :
        if (--shown < 0)   shown = 0;
          else {
             if (! complete_list())
                  change_flags (OT_DOIT, OT_BIGBX, 0, 0, 0);
             change_flags (OT_DOIT, OT_PRNT, 0, 0, 0);
           }
        change_flags (OT_DOIT, OT_UP, FALSE, 0, SELECTED);
        break;
      case OT_DOWN :
        if (++shown > act_ttl - 11)   shown = act_ttl - 11;
          else {
             if (! complete_list())
                  change_flags (OT_DOIT, OT_BIGBX, 0, 0, 0);
             change_flags (OT_DOIT, OT_PRNT, 0, 0, 0);
           }
        change_flags (OT_DOIT, OT_DOWN, FALSE, 0, SELECTED);
        break;
      case OT_PRNT :
        graf_mkstate (& m_x, & m_y, & m_stat, & keybd);
        if (objc_find (tree, OT_SLDBX, 3, m_x, m_y) == OT_PRNT) {
             objc_offset (tree, OT_SLDR, & s_x, & s_y);
             shown += (m_y > s_y) ? 10 : -10;
             shown = MAX (shown, 0);
             shown = MIN (shown, act_ttl - 11);
             if (! complete_list())
                  change_flags (OT_DOIT, OT_BIGBX, 0, 0, 0);
             change_flags (OT_DOIT, OT_PRNT, 0, 0, 0);
           }
        break;
      case OT_SLDR :
        graf_mkstate (& m_x, & m_y, & m_stat, & keybd);
        if (act_ttl > 11) {
             offset = 500 / (act_ttl - 11);
             if (m_stat & 0x01) {
                  shown = offset + graf_slidebox (tree, OT_PRNT, OT_SLDR, 1);
                  shown = (act_ttl - 11) * shown / 1000;
                }
           }
        if (! complete_list())
             change_flags (OT_DOIT, OT_BIGBX, 0, 0, 0);
        change_flags (OT_DOIT, OT_PRNT, 0, 0, 0);
        break;
      case CLOSER_CLICKED :
        erase_list();
        trace_timer = NULL;
        ICMP_handler (trace_echo, HNDLR_REMOVE);
        break;
      }

   return (0);
 }


int  trace_key_typed (scan)

int  scan;

{
   if (scan == CNTRL_Q) {
        erase_list();
        trace_timer = NULL;
        ICMP_handler (trace_echo, HNDLR_REMOVE);
      }
   return ((scan == CNTRL_Q) ? -1 : 1);
 }
