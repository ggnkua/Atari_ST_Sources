
/*********************************************************************/
/*                                                                   */
/*     LogSTinG : Administrative Stuff                               */
/*                                                                   */
/*      Version 1.2                         from 17. March 1997      */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#include "transprt.h"
#include "port.h"


#define  UINT8      0
#define  INT8       1
#define  UINT16     2
#define  INT16      3
#define  UINT32     4
#define  INT32      5
#define  STRING     6
#define  IP_ADDR    7

#define  CLI_NUM    37
#define  MOD_NUM    20


typedef struct logstruc {
     char  *version;
     int   cli_num, mod_num;
     char  *generic;
     char  *client_itf, *module_itf;
     char  *path;
 } LOGSTRUC;


DRV_HDR *  cdecl  my_get_dftab (char *drv_name);
void *     cdecl  my_KRmalloc (int32 length);
void       cdecl  my_KRfree (void *mem_block);
int32      cdecl  my_KRgetfree (int16 flag);
void *     cdecl  my_KRrealloc (void *mem_block, int32 length);
int16      cdecl  my_TCP_open (uint32 rem_host, uint16 rem_port, uint16 tos, uint16 size);
int16      cdecl  my_TCP_close (int16 connec, int16 mode, int16 *result);
int16      cdecl  my_TCP_send (int16 connec, void *buffer, int16 length);
int16      cdecl  my_TCP_wait_state (int16 connec, int16 state, int16 timeout);
int16      cdecl  my_TCP_ack_wait (int16 connec, int16 timeout);
int16      cdecl  my_TCP_info (int16 connec, TCPIB *tcpib);
int16      cdecl  my_UDP_open (uint32 rem_host, uint16 rem_port);
int16      cdecl  my_UDP_close (int16 connec);
int16      cdecl  my_UDP_send (int16 connec, void *buffer, int16 length);
int16      cdecl  my_ICMP_send (uint32 rem_host, uint8 type, uint8 code, void *data, uint16 length);
int16      cdecl  my_ICMP_handler (int16 cdecl (* handler) (IP_DGRAM *), int16 code);
void       cdecl  my_ICMP_discard (IP_DGRAM *dgram);
int16      cdecl  my_CNkick (int16 connec);
int16      cdecl  my_CNbyte_count (int16 connec);
int16      cdecl  my_CNget_char (int16 connec);
NDB *      cdecl  my_CNget_NDB (int16 connec);
int16      cdecl  my_CNget_block (int16 connec, void *block, int16 length);
int16      cdecl  my_CNgets (int16 connec, char *buffer, int16 length, char delim);
CIB *      cdecl  my_CNget_info (int16 connec);
int16      cdecl  my_resolve (char *domain, char **real, uint32 *ip_list, int16 ip_num);
int16      cdecl  my_setvstr (char name[], char value[]);
char *     cdecl  my_getvstr (char name[]);
int16      cdecl  my_on_port (char *port);
void       cdecl  my_off_port (char *port);
int16      cdecl  my_query_port (char *port);
int16      cdecl  my_cntrl_port (char *port, uint32 argument, int16 code);
void       cdecl  my_ser_disable (void);
void       cdecl  my_ser_enable (void);
int16      cdecl  my_set_flag (int16 flag);
void       cdecl  my_clear_flag (int16 flag);
char *     cdecl  my_get_err_text (int16 error);
int16      cdecl  my_carrier_detect (void);
void       cdecl  my_housekeep (void);

int16      cdecl  my_IP_send (uint32 src, uint32 dest, uint8 tos, uint16 frg, uint8 ttl, uint8 prtcl,
                              uint16 id, void *data, uint16 dlen, void *opt, uint16 olen);
IP_DGRAM * cdecl  my_IP_fetch (int16 protocol);
int16      cdecl  my_IP_handler (int16 protocol, int16 cdecl (* handler) (IP_DGRAM *), int16 code);
void       cdecl  my_IP_discard (IP_DGRAM *dgram, int16 flag);
int16      cdecl  my_PRTCL_announce (int16 protocol);
int16      cdecl  my_PRTCL_get_parameters (uint32 rem, uint32 *lcl, int16 *ttl, uint16 *mtu);
int16      cdecl  my_PRTCL_request (void *anonymous, void *functions);
void       cdecl  my_PRTCL_release (int16 handle);
void *     cdecl  my_PRTCL_lookup (int16 handle, void *anonymous);
int16      cdecl  my_TIMER_call (void cdecl (* handler) (void), int16 code);
int32      cdecl  my_TIMER_now (void);
int32      cdecl  my_TIMER_elapsed (int32 moment);
void       cdecl  my_set_dgram_ttl (IP_DGRAM *dgram);
int16      cdecl  my_check_dgram_ttl (IP_DGRAM *dgram);
int32      cdecl  my_set_sysvars (int16 active, int16 fraction);
void       cdecl  my_query_chains (void **port, void **driver, void **layer);
int32      cdecl  my_protect_exec (void *parameter, int32 cdecl (* code) (void *));
int16      cdecl  my_load_routing_table (void);
int16      cdecl  my_get_route_entry (int16 no, uint32 *tmplt, uint32 *mask, PORT **port, uint32 *gway);
int16      cdecl  my_set_route_entry (int16 no, uint32 tmplt, uint32 mask, PORT *port, uint32 gway);

long    get_sting_cookie (void);
void    install (void);
long    deinstall (void);
char *  get_error (int16 error);
void    write_log_text (char *text);
void    write_function (char *name);
void    write_parameter (char *name, int type, void *value, char *supple);
void    write_buffer (char *buffer, int length);


extern  BASPAG  *_BasPag;

DRV_LIST  *sting_drivers;
TPL       *sting_tpl, *tpl, my_tpl;
STX       *sting_stx, *stx, my_stx;
DRV_HDR   *cdecl  (*old_get_dftab) (char *drv_name);
LOGSTRUC  log_this;
int       offset = -1, cache_len;
char      generic[7], cli_flags[CLI_NUM], mod_flags[MOD_NUM], path[256];
char      version[] = "1.6", *cache;

char  type_txt[][9] = { "(uint8)", "(int8)", "(uint16)", "(int16)", "(uint32)",
                        "(int32)", "(string)", "(IP)"   };
char  *code_txt[]   = { "HNDLR_SET", "HNDLR_FORCE", "HNDLR_REMOVE", "HNDLR_QUERY"  };

char  errors[][16]  = { "E_NORMAL", "E_OBUFFULL", "E_NODATA", "E_EOF", "E_RRESET", 
             "E_UA", "E_NOMEM", "E_REFUSE", "E_BADSYN", "E_BADHANDLE", "E_LISTEN", 
             "E_NOCCB", "E_NOCONNECTION", "E_CONNECTFAIL", "E_BADCLOSE", 
             "E_USERTIMEOUT", "E_CNTIMEOUT", "E_CANTRESOLVE", "E_BADDNAME", 
             "E_LOSTCARRIER", "E_NOHOSTNAME", "E_DNSWORKLIMIT", "E_NONAMESERVER", 
             "E_DNSBADFORMAT", "E_UNREACHABLE", "E_DNSNOADDR", "E_NOROUTINE", 
             "E_LOCKED", "E_FRAGMENT", "E_TTLEXCEED"   };

char  not_there[] = "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]";
char  corrupted[] = "[1][ |  STinG structures corrupted !   ][ Fuck ]";
char  found_it[]  = "[3][ |  Driver \'%s\',|  by %s, found,   |  version %s.][ Okay ]";
char  no_module[] = "[1][ |  STinG Transport Driver not found !   ][ Grmbl ]";
char  no_memory[] = "[1][ |  Can\'t allocate buffer memory !   ][ Shit ]";
char  itsthere[]  = "[1][ |  LogSTinG already installed !   ][ Ooops ]";
char  installed[] = "[3][ |  LogSTinG debugging tool    | |    installed ...][ Okay ]";



void  main()

{
   char  alert[256];

   appl_init();

   sting_drivers = (DRV_LIST *) Supexec (get_sting_cookie);

   if (sting_drivers == 0L) {
        form_alert (1, not_there);
        return;
      }
   if (strcmp (sting_drivers->magic, MAGIC) != 0) {
        form_alert (1, corrupted);
        return;
      }

   if ((*sting_drivers->get_dftab) ("LOGSTING : QUERY") != NULL) {
        form_alert (1, itsthere);
        return;
      }

   sting_tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   sting_stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (sting_tpl == (TPL *) NULL || sting_stx == (STX *) NULL)
        form_alert (1, no_module);
     else {
        if ((cache = (char *) Malloc (8192L)) == NULL)
             form_alert (1, no_memory);
          else {
             sprintf (alert, found_it, sting_tpl->module, sting_tpl->author, sting_tpl->version);
             form_alert (1, alert);
             install();
             form_alert (1, installed);
             appl_exit();
             Ptermres (_PgmSize, 0);
           }
      }

   appl_exit();
 }


long  get_sting_cookie()

{
   long  *work;

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == 'STiK')
             return (*++work);

   return (0L);
 }


void  install()

{
   int  count;

   path[0] = 'A' + Dgetdrv();
   path[1] = ':';
   Dgetpath (& path[2], 0);
   strcat (path, "\\STING.LOG");

   cache_len = 0;

   tpl = & my_tpl;
   memcpy (tpl, sting_tpl, sizeof (TPL));

   sting_tpl->KRmalloc       = my_KRmalloc;
   sting_tpl->KRfree         = my_KRfree;
   sting_tpl->KRgetfree      = my_KRgetfree;
   sting_tpl->KRrealloc      = my_KRrealloc;
   sting_tpl->TCP_open       = my_TCP_open;
   sting_tpl->TCP_close      = my_TCP_close;
   sting_tpl->TCP_send       = my_TCP_send;
   sting_tpl->TCP_wait_state = my_TCP_wait_state;
   sting_tpl->TCP_ack_wait   = my_TCP_ack_wait;
   sting_tpl->TCP_info       = my_TCP_info;
   sting_tpl->UDP_open       = my_UDP_open;
   sting_tpl->UDP_close      = my_UDP_close;
   sting_tpl->UDP_send       = my_UDP_send;
   sting_tpl->ICMP_send      = my_ICMP_send;
   sting_tpl->ICMP_handler   = my_ICMP_handler;
   sting_tpl->ICMP_discard   = my_ICMP_discard;
   sting_tpl->CNkick         = my_CNkick;
   sting_tpl->CNbyte_count   = my_CNbyte_count;
   sting_tpl->CNget_char     = my_CNget_char;
   sting_tpl->CNget_NDB      = my_CNget_NDB;
   sting_tpl->CNget_block    = my_CNget_block;
   sting_tpl->CNgets         = my_CNgets;
   sting_tpl->CNgetinfo      = my_CNget_info;
   sting_tpl->resolve        = my_resolve;
   sting_tpl->setvstr        = my_setvstr;
   sting_tpl->getvstr        = my_getvstr;
   sting_tpl->on_port        = my_on_port;
   sting_tpl->off_port       = my_off_port;
   sting_tpl->query_port     = my_query_port;
   sting_tpl->cntrl_port     = my_cntrl_port;
   sting_tpl->ser_disable    = my_ser_disable;
   sting_tpl->ser_enable     = my_ser_enable;
   sting_tpl->set_flag       = my_set_flag;
   sting_tpl->clear_flag     = my_clear_flag;
   sting_tpl->get_err_text   = my_get_err_text;
   sting_tpl->carrier_detect = my_carrier_detect;
   sting_tpl->housekeep      = my_housekeep;

   for (count = 0; count < (log_this.cli_num = CLI_NUM); count++)
        cli_flags[count] = 1;
   log_this.client_itf = cli_flags;

   stx = & my_stx;
   memcpy (stx, sting_stx, sizeof (STX));

   sting_stx->IP_send              = my_IP_send;
   sting_stx->IP_fetch             = my_IP_fetch;
   sting_stx->IP_handler           = my_IP_handler;
   sting_stx->IP_discard           = my_IP_discard;
   sting_stx->PRTCL_announce       = my_PRTCL_announce;
   sting_stx->PRTCL_get_parameters = my_PRTCL_get_parameters;
   sting_stx->PRTCL_request        = my_PRTCL_request;
   sting_stx->PRTCL_release        = my_PRTCL_release;
   sting_stx->PRTCL_lookup         = my_PRTCL_lookup;
   sting_stx->TIMER_call           = my_TIMER_call;
   sting_stx->TIMER_now            = my_TIMER_now;
   sting_stx->TIMER_elapsed        = my_TIMER_elapsed;
   sting_stx->set_dgram_ttl        = my_set_dgram_ttl;
   sting_stx->check_dgram_ttl      = my_check_dgram_ttl;
   sting_stx->set_sysvars          = my_set_sysvars;
   sting_stx->query_chains         = my_query_chains;
   sting_stx->protect_exec         = my_protect_exec;
   sting_stx->load_routing_table   = my_load_routing_table;
   sting_stx->get_route_entry      = my_get_route_entry;
   sting_stx->set_route_entry      = my_set_route_entry;

   for (count = 0; count < (log_this.mod_num = MOD_NUM); count++)
        mod_flags[count] = 0;
   log_this.module_itf = mod_flags;

   generic[0] = 0;   generic[1] = 1;
   generic[2] = 0;   generic[3] = 0;   generic[4] = 0;
   generic[5] = 0;   generic[6] = 0;

   log_this.generic = generic;
   log_this.path    = path;
   log_this.version = version;

   old_get_dftab = sting_drivers->get_dftab;
   sting_drivers->get_dftab = my_get_dftab;
 }


long  deinstall()

{
   int   handle;
   char  *real_path;

   real_path = (generic[6]) ? "U:\\PIPE\\DEBUG" : path;

   if (cache_len > 0) {
        if ((handle = Fopen (real_path, FO_RW)) < 0)
             handle = Fcreate (real_path, 0);
        if (handle >= 0) {
             Fseek (0, handle, 2);
             Fwrite (handle, cache_len, cache);
             Fclose (handle);
           }
      }

   sting_drivers->get_dftab = old_get_dftab;

   memcpy (sting_tpl, tpl, sizeof (TPL));
   memcpy (sting_stx, stx, sizeof (STX));

   Mfree (cache);

   Mfree (_BasPag->p_env);
   Mfree (_BasPag);

   return (0L);
 }


char *  get_error (error)

int16  error;

{
   error *= -1;

   if (error <= 0 || E_LASTERROR < error)
        return ("");

   return (errors[error]);
 }


void  write_log_text (text)

char  *text;

{
   int   limit, handle;
   char  *real_path, *offset_text = "||||||||||||||||||||||||";

   if (generic[0] == 0 || (generic[4] == 0 && offset > 0))
        return;

   real_path = (generic[6]) ? "U:\\PIPE\\DEBUG" : path;
   limit     = (generic[5]) ? 8191 - (strlen (text) + offset + 2) : 0;

   if (cache_len > limit) {
        if ((handle = Fopen (real_path, FO_RW)) < 0)
             if ((handle = Fcreate (real_path, 0)) < 0)
                  return;
        Fseek (0, handle, 2);
        Fwrite (handle, cache_len, cache);   cache_len = 0;
        Fclose (handle);
      }

   if (generic[5]) {
        memcpy (cache + cache_len, offset_text, offset);
        cache_len += offset;
        memcpy (cache + cache_len, text, limit = strlen (text));
        cache_len += limit;
        memcpy (cache + cache_len, "\r\n", 2L);
        cache_len += 2;
      }
     else {
        if ((handle = Fopen (real_path, FO_RW)) < 0)
             if ((handle = Fcreate (real_path, 0)) < 0)
                  return;
        Fseek (0, handle, 2);
        if (offset > 0)
             Fwrite (handle, offset, offset_text);
        Fwrite (handle, strlen (text), text);
        Fwrite (handle, 2L, "\r\n");
        Fclose (handle);
      }
 }


void  write_function (name)

char  *name;

{
   char  line[100];

   write_log_text ("\r\n");

   sprintf (line, "Call to \'%s\' ($%lx).", name, TIMER_now());
   write_log_text (line);
 }


void  write_parameter (name, type, value, supple)

char  *name, *supple;
int   type;
void  *value;

{
   uint32  number;
   int16   ip_1, ip_2, ip_3, ip_4;
   char    val_str[32], supp[32], line[100];

   switch (type) {
      case UINT8 :
        number = * ((uint8 *) value);
        sprintf (val_str, "%u ($%x)", (uint16) number, (uint16) number);
        break;
      case INT8 :
        sprintf (val_str, "%d", (int16) * ((int8 *) value));
        break;
      case UINT16 :
        number = * ((uint16 *) value);
        sprintf (val_str, "%u ($%x)", (uint16) number, (uint16) number);
        break;
      case INT16 :
        sprintf (val_str, "%d",  * ((int16 *) value));
        break;
      case UINT32 :
        number = * ((uint32 *) value);
        sprintf (val_str, "%lu ($%lx)", number, number);
        break;
      case INT32 :
        sprintf (val_str, "%ld", * ((int32 *) value));
        break;
      case STRING :
        strncpy (val_str, (char *) value, 31);
        val_str[31] = '\0';
        break;
      case IP_ADDR :
        number = * ((uint32 *) value);
        ip_1 = (number >> 24) & 0xff;   ip_3 = (number >> 8) & 0xff;
        ip_2 = (number >> 16) & 0xff;   ip_4 =  number       & 0xff;
        sprintf (val_str, "%d.%d.%d.%d", ip_1, ip_2, ip_3, ip_4);
        break;
      }

   if (*supple) {
        supp[0] = '(';   strcpy (& supp[1], supple);   strcat (supp, ")");
      }
     else   supp[0] = '\0';

   sprintf (line, "   %-16s %10s  :  %s  %s", name, type_txt[type], val_str, supp);

   write_log_text (line);
 }


void  write_buffer (buffer, length)

char  *buffer;
int   length;

{
   int   index, num, count, byte;
   char  hex_line[50], hex[5], ascii[20], line[100];

   if (buffer == NULL)   return;

   for (index = 0; index < length; index += 16) {
        num = length - index;
        if (num > 16)   num = 16;
        hex_line[0] = '\0';
        for (count = 0; count < num; count++) {
             byte = (int) *((unsigned char *) buffer + index + count);
             sprintf (hex, " %02x", byte);
             strcat (hex_line, hex);
             if (byte < 32 || 127 < byte)   byte = '.';
             ascii[count] = byte;
           }
        ascii[count] = '\0';
        sprintf (line, "     $%04x : %-48s \'%s", index, hex_line, ascii);
        write_log_text (line);
      }
 }
