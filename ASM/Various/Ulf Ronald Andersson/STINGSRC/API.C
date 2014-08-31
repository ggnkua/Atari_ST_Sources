
/*********************************************************************/
/*                                                                   */
/*     STinG : API and IP kernel package                             */
/*                                                                   */
/*                                                                   */
/*      Version 1.1                         from 8. Januar 1997      */
/*                                                                   */
/*      Module for Application Programming Interface, Dummy calls    */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "globdefs.h"


#define  NUM_LAYER   2


typedef  struct drv_header {
           char     *module, *author, *version;
     } DRV_HDR;

typedef  struct driver {
           char     magic[10];
           DRV_HDR  * cdecl (*get_drvfunc) (char *);
           int16      cdecl (*ETM_exec) (char *);
           CONFIG   *cfg;
           BASPAG   *basepage;
           DRV_HDR  *layer[NUM_LAYER];
     } GENERIC;

typedef  struct client_layer {
    char *     module;      /* Specific string that can be searched for     */
    char *     author;      /* Any string                                   */
    char *     version;     /* Format `00.00' Version:Revision              */
    void *     cdecl  (* KRmalloc) (int32);
    void       cdecl  (* KRfree) (void *);
    int32      cdecl  (* KRgetfree) (int16);
    void *     cdecl  (* KRrealloc) (void *, int32);
    char *     cdecl  (* get_err_text) (int16);
    char *     cdecl  (* getvstr) (char *);
    int16      cdecl  (* carrier_detect) (void);
    int16      cdecl  (* TCP_open) (uint32, uint16, uint16, uint16);
    int16      cdecl  (* TCP_close) (int16, int16, int16 *);
    int16      cdecl  (* TCP_send) (int16, void *, int16);
    int16      cdecl  (* TCP_wait_state) (int16, int16, int16);
    int16      cdecl  (* TCP_ack_wait) (int16, int16);
    int16      cdecl  (* UDP_open) (uint32, uint16);
    int16      cdecl  (* UDP_close) (int16);
    int16      cdecl  (* UDP_send) (int16, void *, int16);
    int16      cdecl  (* CNkick) (int16);
    int16      cdecl  (* CNbyte_count) (int16);
    int16      cdecl  (* CNget_char) (int16);
    NDB *      cdecl  (* CNget_NDB) (int16);
    int16      cdecl  (* CNget_block) (int16, void *, int16);
    void       cdecl  (* housekeep) (void);
    int16      cdecl  (* resolve) (char *, char **, uint32 *, int16);
    void       cdecl  (* ser_disable) (void);
    void       cdecl  (* ser_enable) (void);
    int16      cdecl  (* set_flag) (int16);
    void       cdecl  (* clear_flag) (int16);
    CIB *      cdecl  (* CNgetinfo) (int16);
    int16      cdecl  (* on_port) (char *);
    void       cdecl  (* off_port) (char *);
    int16      cdecl  (* setvstr) (char *, char *);
    int16      cdecl  (* query_port) (char *);
    int16      cdecl  (* CNgets) (int16, char *, int16, char);
    int16      cdecl  (* ICMP_send) (uint32, uint8, uint8, void *, uint16);
    int16      cdecl  (* ICMP_handler) (int16 cdecl (*) (IP_DGRAM *), int16);
    void       cdecl  (* ICMP_discard) (IP_DGRAM *);
    int16      cdecl  (* TCP_info) (int16, void *);
    int16      cdecl  (* cntrl_port) (char *, uint32, int16);
 } CLIENT_API;

typedef  struct stx_layer {
    char *     module;      /* Specific string that can be searched for     */
    char *     author;      /* Any string                                   */
    char *     version;     /* Format `00.00' Version:Revision              */
    void       cdecl  (* set_dgram_ttl) (IP_DGRAM *);
    int16      cdecl  (* check_dgram_ttl) (IP_DGRAM *);
    int16      cdecl  (* routing_table) (void);
    int32      cdecl  (* set_sysvars) (int16, int16);
    void       cdecl  (* query_chains) (PORT **, DRIVER **, LAYER **);
    int16      cdecl  (* IP_send) (uint32, uint32, uint8, uint16, uint8, uint8, uint16,
                                   void *, uint16, void *, uint16);
    IP_DGRAM * cdecl  (* IP_fetch) (int16);
    int16      cdecl  (* IP_handler) (int16, int16 cdecl (*) (IP_DGRAM *), int16);
    void       cdecl  (* IP_discard) (IP_DGRAM *, int16);
    int16      cdecl  (* PRTCL_announce) (int16);
    int16      cdecl  (* PRTCL_get_parameters) (uint32, uint32 *, int16 *, uint16 *);
    int16      cdecl  (* PRTCL_request) (void *, CN_FUNCS *);
    void       cdecl  (* PRTCL_release) (int16);
    void *     cdecl  (* PRTCL_lookup) (int16, CN_FUNCS *);
    int16      cdecl  (* TIMER_call) (void cdecl (*) (void), int16);
    int32      cdecl  (* TIMER_now) (void);
    int32      cdecl  (* TIMER_elapsed) (int32);
    int32      cdecl  (* protect_exec) (void *, int32 cdecl (*) (void *));
    int16      cdecl  (* get_route_entry) (int16, uint32 *, uint32 *, PORT **, uint32 *);
    int16      cdecl  (* set_route_entry) (int16, uint32, uint32, PORT *, uint32);
 } STX_API;


int16      cdecl  setvstr (char name[], char value[]);
char *     cdecl  getvstr (char name[]);

int32      cdecl  set_sysvars (int16 new_act, int16 new_frac);
void       cdecl  query_chains (PORT **port, DRIVER **drv, LAYER **layer);
char *     cdecl  get_error_text (int16 error_code);
void *     cdecl  KRmalloc (int32 size);
void       cdecl  KRfree (void *mem_block);
int32      cdecl  KRgetfree (int16 block_flag);
void *     cdecl  KRrealloc (void *mem_block, int32 new_size);

int16      cdecl  set_flag (int16 flag);
void       cdecl  clear_flag (int16 flag);
int32      cdecl  protect_exec (void *parameter, int32 cdecl (* code) (void *));

int16      cdecl  on_port (char *port);
void       cdecl  off_port (char *port);
int16      cdecl  query_port (char *port);
int16      cdecl  cntrl_port (char *port, uint32 argument, int16 code);

void       cdecl  set_dgram_ttl (IP_DGRAM *datagram);
int16      cdecl  check_dgram_ttl (IP_DGRAM *datagram);

int16      cdecl  get_route_entry (int16 no, uint32 *tmplt, uint32 *mask, PORT **port, uint32 *gway);
int16      cdecl  set_route_entry (int16 no, uint32 tmplt, uint32 mask, PORT *port, uint32 gway);
int16      cdecl  routing_table (void);
int16      cdecl  IP_send (uint32, uint32, uint8, uint16, uint8, uint8, uint16, void *, 
                           uint16, void *, uint16);
IP_DGRAM * cdecl  IP_fetch (int16 prtcl);
int16      cdecl  IP_handler (int16 prtcl, int16 cdecl (* hndlr) (IP_DGRAM *), int16 flag);
void       cdecl  IP_discard (IP_DGRAM *datagram, int16 all_flag);

int16      cdecl  ICMP_send (uint32 dest, uint8 type, uint8 code, void *data, uint16 len);
int16      cdecl  ICMP_handler (int16 cdecl (* hndlr) (IP_DGRAM *), int16 flag);
void       cdecl  ICMP_discard (IP_DGRAM *datagram);

int16             handle_lookup (int16 connec, void **anonymous, CN_FUNCS **entry);
int16      cdecl  PRTCL_announce (int16 protocol);
int16      cdecl  PRTCL_get_parameters (uint32 rem_host, uint32 *src_ip, int16 *ttl, uint16 *mtu);
int16      cdecl  PRTCL_request (void *anonymous, CN_FUNCS *cn_functions);
void       cdecl  PRTCL_release (int16 handle);
void *     cdecl  PRTCL_lookup (int16 handle, CN_FUNCS *cn_functions);
int16      cdecl  TIMER_call (void cdecl (* hndlr) (void), int16 flag);
int32      cdecl  TIMER_now (void);
int32      cdecl  TIMER_elapsed (int32 then);

long              init_cookie (void);
DRV_HDR *  cdecl  get_drv_func (char *drv_name);
int16      cdecl  ETM_exec (char *module);
int16      cdecl  TCP_open (uint32 rem_host, uint16 rem_port, uint16 tos, uint16 size);
int16      cdecl  TCP_close (int16 connec, int16 mode, int16 *result);
int16      cdecl  TCP_send (int16 connec, void *buffer, int16 length);
int16      cdecl  TCP_wait_state (int16 connec, int16 state, int16 timeout);
int16      cdecl  TCP_ack_wait (int16 connec, int16 timeout);
int16      cdecl  TCP_info (int16 connec, void *tcp_info);
int16      cdecl  UDP_open (uint32 rem_host, uint16 rem_port);
int16      cdecl  UDP_close (int16 connec);
int16      cdecl  UDP_send (int16 connec, void *buffer, int16 length);
int16      cdecl  CNkick (int16 connec);
int16      cdecl  CNbyte_count (int16 connec);
int16      cdecl  CNget_char (int16 connec);
NDB *      cdecl  CNget_NDB (int16 connec);
int16      cdecl  CNget_block (int16 connec, void *buffer, int16 length);
CIB *      cdecl  CNgetinfo (int16 connec);
int16      cdecl  CNgets (int16 connec, char *buffer, int16 length, char delimiter);
int16      cdecl  resolve (char *domain, char **real, uint32 *ip_list, int16 ip_num);
void       cdecl  serial_dummy (void);
int16      cdecl  carrier_detect (void);
void       cdecl  house_keep (void);


CONFIG      conf;
CLIENT_API  tpl  = { "TRANSPORT_TCPIP", "Peter Rottengatter", TCP_DRIVER_VERSION, 
                      KRmalloc, KRfree, KRgetfree, KRrealloc, 
                      get_error_text, getvstr, carrier_detect, 
                      TCP_open, TCP_close, TCP_send, TCP_wait_state, TCP_ack_wait, 
                      UDP_open, UDP_close, UDP_send, 
                      CNkick, CNbyte_count, CNget_char, CNget_NDB, CNget_block, 
                      house_keep, resolve, serial_dummy, serial_dummy, 
                      set_flag, clear_flag, CNgetinfo, 
                      on_port, off_port, setvstr, query_port, CNgets, 
                      ICMP_send, ICMP_handler, ICMP_discard, TCP_info, cntrl_port
               };
STX_API     stxl = { "MODULE_LAYER", "Peter Rottengatter", STX_LAYER_VERSION, 
                      set_dgram_ttl, check_dgram_ttl, routing_table, set_sysvars, query_chains, 
                      IP_send, IP_fetch, IP_handler, IP_discard, 
                      PRTCL_announce, PRTCL_get_parameters, PRTCL_request, PRTCL_release, 
                      PRTCL_lookup, TIMER_call, TIMER_now, TIMER_elapsed,
                      protect_exec, get_route_entry, set_route_entry
               };
GENERIC     cookie = { "STiKmagic", get_drv_func, ETM_exec,
                       & conf, NULL, (DRV_HDR *) & tpl, (DRV_HDR *) & stxl  };
long        my_jar[8] = {  0L, 4L  };



long  init_cookie()

{
   int   cnt_cookie;
   long  *work, *jar, *new;

   conf.new_cookie = FALSE;

   if ((work = * (long **) 0x5a0L) == NULL) {
        conf.new_cookie = TRUE;
        * (long **) 0x5a0L = & my_jar[0];
      }

   for (work = * (long **) 0x5a0L, cnt_cookie = 0; *work != 0L; work += 2, cnt_cookie++)
        if (*work == 'STiK')
             return (-1L);

   if (work[1] - 1 <= cnt_cookie) {
        if ((jar = (long *) Malloc ((cnt_cookie + 8) * 2 * sizeof (long))) == NULL)
             return (-1L);
        for (work = * (long **) 0x5a0L, new = jar; *work != 0L; work += 2, new += 2)
             new[0] = work[0],  new[1] = work[1];
        new[0] = 0L;
        new[1] = cnt_cookie + 8;
        work = new;
        * (long **) 0x5a0L = jar;
        conf.new_cookie = TRUE;
      }

   work[2] = work[0];   work[0] = 'STiK';
   work[3] = work[1];   work[1] = (long) &cookie;

   cookie.basepage = _BasPag;

   return (0L);
 }


DRV_HDR *  cdecl  get_drv_func (drv_name)

char  *drv_name;

{
   int  count;

   for (count = 0; count < NUM_LAYER; count++)
        if (strcmp (cookie.layer[count]->module, drv_name) == 0)
             return (cookie.layer[count]);

   return ((DRV_HDR *) NULL);
 }


int16  cdecl  ETM_exec (module)

char  *module;

{
   return (0);
 }


int16  cdecl  TCP_open (rem_host, rem_port, tos, buff_size)

uint32  rem_host;
uint16  rem_port, tos;
uint16  buff_size;

{
   return (E_UNREACHABLE);
 }


int16  cdecl  TCP_close (connec, mode, result)

int16  connec, mode, *result;

{
   return (E_BADHANDLE);
 }


int16  cdecl  TCP_send (connec, buffer, length)

int16  connec, length;
void   *buffer;

{
   return (E_BADHANDLE);
 }


int16  cdecl  TCP_wait_state (connec, state, timeout)

int16  connec, state, timeout;

{
   return (E_BADHANDLE);
 }


int16  cdecl  TCP_ack_wait (connec, timeout)

int16  connec, timeout;

{
   return (E_BADHANDLE);
 }


int16  cdecl  TCP_info (connec, tcp_info)

int16  connec;
void   *tcp_info;

{
   return (E_BADHANDLE);
 }


int16  cdecl  UDP_open (rem_host, rem_port)

uint32  rem_host;
uint16  rem_port;

{
   return (E_UNREACHABLE);
 }


int16  cdecl  UDP_close (connec)

int16  connec;

{
   return (E_BADHANDLE);
 }


int16  cdecl  UDP_send (connec, buffer, length)

int16  connec, length;
void   *buffer;

{
   return (E_BADHANDLE);
 }


int16  cdecl  CNkick (connec)

int16  connec;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (E_BADHANDLE);

   return ((* entry->CNkick) (anonymous));
 }


int16  cdecl  CNbyte_count (connec)

int16  connec;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (E_BADHANDLE);

   return ((* entry->CNbyte_count) (anonymous));
 }


int16  cdecl  CNget_char (connec)

int16  connec;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (E_BADHANDLE);

   return ((* entry->CNget_char) (anonymous));
 }


NDB *  cdecl  CNget_NDB (connec)

int16  connec;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (NULL);

   return ((* entry->CNget_NDB) (anonymous));
 }


int16  cdecl  CNget_block (connec, buffer, length)

int16  connec, length;
void   *buffer;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (E_BADHANDLE);

   return ((* entry->CNget_block) (anonymous, buffer, length));
 }


CIB *  cdecl  CNgetinfo (connec)

int16  connec;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (NULL);

   return ((* entry->CNgetinfo) (anonymous));
 }


int16  cdecl  CNgets (connec, buffer, length, delimiter)

int16  connec, length;
char   *buffer, delimiter;

{
   void      *anonymous;
   CN_FUNCS  *entry;

   if (handle_lookup (connec, & anonymous, & entry) == 0)
        return (E_BADHANDLE);

   return ((* entry->CNgets) (anonymous, buffer, length, delimiter));
 }


int16  cdecl  resolve (domain, real_domain, ip_list, ip_num)

char    *domain, **real_domain;
uint32  *ip_list;
int16   ip_num;

{
   return (E_CANTRESOLVE);
 }


void  cdecl  serial_dummy()

{
   /* Do really nothing, as these functions are obsolete ! */
 }


int16  cdecl  carrier_detect()

{
   return (+1);
 }


void  cdecl  house_keep()

{
   /* Do really nothing, as this function is obsolete ! */
 }
