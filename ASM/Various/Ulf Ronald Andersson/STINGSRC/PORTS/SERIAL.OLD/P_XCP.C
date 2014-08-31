
/*********************************************************************/
/*                                                                   */
/*     Low Level Port : Serielle Schnittstellen                      */
/*                                                                   */
/*                                                                   */
/*      Version 0.1                         vom 16. Juli 1997        */
/*                                                                   */
/*      Modul fuer PPP Control Protocol Handler                      */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <stdio.h>
#include <string.h>

#include "transprt.h"
#include "port.h"

#include "serial.h"


void          set_dtr (void *hsm_code, int new_dtr);
int           inq_cd (void *hsm_code);

void          init_vjhc (VJHC *vjhc, int16 num_states);

uint16        fetch_16bit (uint8 *dest, uint8 *source);
uint32        fetch_32bit (uint8 *dest, uint8 *source);
uint32        choose_a_magic (uint32 avoid);
int16         add_ps_dns (char *buffer, uint32 dns_ip);
int16         pap_check_auth (SERIAL_PORT *port, uint8 *secret);
void          ppp_log_it (SERIAL_PORT *port, MACHINE *mach, char *act, char *which, int id);

void          user_event (SERIAL_PORT *port, int event, MACHINE *machine);

void          ppp_dummy (SERIAL_PORT *port, int16 flag);

void          lcp_up_down (SERIAL_PORT *port, int16 flag);
void          lcp_do_lower (SERIAL_PORT *port, int16 flag);
int32  cdecl  lcp_super_lower (void *port);
void          lcp_create (SERIAL_PORT *port);
int16         lcp_nego (SERIAL_PORT *port, uint8 *own, uint8 *source, uint8 *modified);
int16         lcp_imple (SERIAL_PORT *port, uint8 *option);
int16         lcp_options (SERIAL_PORT *port, uint8 *source, uint8 *modified);
void          lcp_accept (SERIAL_PORT *port, uint8 *option);

void          ipcp_up_down (SERIAL_PORT *port, int16 flag);
void          ipcp_create (SERIAL_PORT *port);
int16         ipcp_nego (SERIAL_PORT *port, uint8 *own, uint8 *source, uint8 *modified);
int16         ipcp_imple (SERIAL_PORT *port, uint8 *option);
int16         ipcp_options (SERIAL_PORT *port, uint8 *source, uint8 *modified);
void          ipcp_accept (SERIAL_PORT *port, uint8 *option);

void          pap_up_down (SERIAL_PORT *port, int16 flag);
void          pap_create (SERIAL_PORT *port);
int16         pap_nego (SERIAL_PORT *port, uint8 *own, uint8 *source, uint8 *modified);
int16         pap_imple (SERIAL_PORT *port, uint8 *option);
int16         pap_options (SERIAL_PORT *port, uint8 *source, uint8 *modified);
void          pap_accept (SERIAL_PORT *port, uint8 *option);


char  buffer[256];


#pragma warn -par



void  ppp_dummy (port, flag)

SERIAL_PORT  *port;
int16        flag;

{
   /*  Just don't do anything !  */
 }


void  lcp_up_down (port, flag)

SERIAL_PORT  *port;
int16        flag;

{
   char  string[12] = "";

   if (flag == PPP_UP) {
        if (port->generic.mtu > port->ppp.mtu2) {
             port->generic.mtu = port->ppp.mtu2;
           }
        if (port->ppp.lcp.flags & 0x8000u)
             strcat (string, "PAP & ");
        strcat (string, "IPCP.");
        ppp_log_it (port, & port->ppp.lcp, "Link established, starting", string, -1);
        if (port->ppp.lcp.flags & 0x8000u)
             user_event (port, PPP_LAYUP, & port->ppp.pap);
          else
             user_event (port, PPP_LAYUP, & port->ppp.ipcp);
      }
     else {
        port->ppp.lcp.conf_len = -1;
        ppp_log_it (port, & port->ppp.lcp, "Link is going down.", "", -1);
        user_event (port, PPP_LAYDOWN, & port->ppp.pap);
        user_event (port, PPP_LAYDOWN, & port->ppp.ipcp);
      }
 }


void  lcp_do_lower (port, flag)

SERIAL_PORT  *port;
int16        flag;

{
   if (flag == PPP_UP)
        port->generic.flags |= FLG_UP_DOWN;
     else
        port->generic.flags &= ~FLG_UP_DOWN;

   protect_exec ((void *) port, lcp_super_lower);
 }


int32  cdecl  lcp_super_lower (raw)

void  *raw;

{
   SERIAL_PORT  *port = (SERIAL_PORT *) raw;

   if (port->generic.flags & FLG_UP_DOWN) {
        if ((port->iocntl) ? ((inq_cd (port->iocntl)) ? TRUE : FALSE) : TRUE)
             port->ppp.lcp.event = PPP_LAYUP;
          else
             port->generic.flags |= FLG_DCD_UP;
      }
     else {
        if (port->iocntl) {
             port->generic.flags |= FLG_DTR_DOWN;   set_dtr (port->iocntl, FALSE);
           }
          else {
             port->generic.flags |= FLG_DONE;
           }
        port->ppp.lcp.event = PPP_LAYDOWN;
        port->generic.flags &= ~FLG_DCD_DOWN;
      }

   return (0L);
 }


void  lcp_create (port)

SERIAL_PORT  *port;

{
   uint8   *walk = port->ppp.lcp.conf;
   uint32  aux = 0L;

   *walk++ = OPT_MRU;
   *walk++ = 4;
   fetch_16bit (walk, (uint8 *) & port->generic.mtu);   walk += 2;

   if (port->generic.flags & FLG_REQU_AUTH) {
        *walk++ = OPT_AUTH;
        *walk++ = 4;
        * (uint16 *) walk = PPP_PAP;   walk += 2;
      }

   *walk++ = OPT_ACCM;
   *walk++ = 6;
   aux = 0L;
   fetch_32bit (walk, (uint8 *) & aux);   walk += 4;

   *walk++ = OPT_MAGIC;
   *walk++ = 6;
   aux = choose_a_magic (port->ppp.remote_magic);
   fetch_32bit (walk, (uint8 *) & aux);   walk += 4;
   port->ppp.offered = aux;

   *walk++ = OPT_PRTCL_COMP;
   *walk++ = 2;

   *walk++ = OPT_A_C_COMP;
   *walk++ = 2;

   port->ppp.lcp.conf_len = (int16) (walk - port->ppp.lcp.conf);

   port->generic.flags |= FLG_DCD_DOWN;
 }


int16  lcp_nego (port, own, source, mod)

SERIAL_PORT  *port;
uint8        *own, *source, *mod;

{
   uint32  aux = 0L;

   switch (*source) {
      case OPT_MRU :
        * (int16 *) mod = 4;
        mod[2] = OPT_MRU;
        mod[3] = 4;
        if (fetch_16bit (NULL, & source[2]) < 128)
             * (uint16 *) & mod[4] = (port->generic.max_mtu < 572) ? port->generic.max_mtu : 572;
          else
             * (uint16 *) & mod[4] = fetch_16bit (NULL, & source[2]);
        break;
      case OPT_ACCM :
        * (int16 *) mod = 6;
        memcpy (& mod[2], source, 6);
        break;
      case OPT_MAGIC :
        * (int16 *) mod = 6;
        aux = choose_a_magic (fetch_32bit (NULL, & source[2]));
        fetch_32bit (& source[2], (uint8 *) & aux);
        port->ppp.offered = aux;
        memcpy (& mod[2], source, 6);
        break;
      }

   return (FALSE);
 }


int16  lcp_imple (port, option)

SERIAL_PORT  *port;
uint8        *option;

{
   switch (*option) {
      case OPT_MRU :
        port->generic.mtu = fetch_16bit (NULL, & option[2]);
        break;
      case OPT_ACCM :
        port->ppp.recve_accm = fetch_32bit (NULL, & option[2]);
        break;
      case OPT_MAGIC :
        port->ppp.local_magic = fetch_32bit (NULL, & option[2]);
        break;
      }

   return (FALSE);
 }


int16  lcp_options (port, source, mod)

SERIAL_PORT  *port;
uint8        *source, *mod;

{
   int16  value;

   switch (*source) {
      case OPT_MRU :
        if (fetch_16bit (NULL, & source[2]) < 128) {
             * (int16 *) mod = 4;
             mod[2] = OPT_MRU;   mod[3] = 4;
             * (uint16 *) & mod[4] = (port->generic.max_mtu < 572) ? port->generic.max_mtu : 572;
             value = PPP_CONF_NAK;
           }
          else
             value = PPP_CONF_ACK;
        break;
      case OPT_ACCM :
        value = PPP_CONF_ACK;
        break;
      case OPT_AUTH :
        if (fetch_16bit (NULL, & source[2]) != PPP_PAP) {
             * (int16 *) mod = 4;
             mod[2] = OPT_AUTH;   mod[3] = 4;   * (uint16 *) & mod[4] = PPP_PAP;
             value = PPP_CONF_NAK;
           }
          else
             value = (port->generic.flags & FLG_ALLOW_PAP) ? PPP_CONF_ACK : PPP_CONF_NAK;
        break;
      case OPT_QUALITY :
        value = PPP_CONF_REJCT;
        break;
      case OPT_MAGIC :
        if (fetch_32bit (NULL, & source[2]) == port->ppp.offered) {
             * (int16 *) mod = 6;
             mod[2] = OPT_MAGIC;   mod[3] = 6;
             * (uint32 *) & mod[4] = choose_a_magic (port->ppp.offered);
             value = PPP_CONF_NAK;
           }
          else
             value = PPP_CONF_ACK;
        break;
      case OPT_PRTCL_COMP :
      case OPT_A_C_COMP :
        value = PPP_CONF_ACK;
        break;
      default :
        value = PPP_CONF_REJCT;
      }

   return (value);
 }


void  lcp_accept (port, option)

SERIAL_PORT  *port;
uint8        *option;

{
   switch (*option) {
      case OPT_MRU :
        port->ppp.mtu2 = fetch_16bit (NULL, & option[2]);
        break;
      case OPT_ACCM :
        port->ppp.send_accm = fetch_32bit (NULL, & option[2]);
        break;
      case OPT_AUTH :
        port->ppp.lcp.flags |= 0xc000u;
        if (fetch_16bit (NULL, & option[2]) == PPP_PAP)
             port->ppp.lcp.flags &= ~0x4000u;
        break;
      case OPT_MAGIC :
        port->ppp.remote_magic = fetch_32bit (NULL, & option[2]);
        break;
      case OPT_PRTCL_COMP :
        port->generic.flags |= FLG_PRTCL_COMP;
        break;
      case OPT_A_C_COMP :
        port->generic.flags |= FLG_A_C_COMP;
        break;
      }
 }


void  ipcp_up_down (port, flag)

SERIAL_PORT  *port;
int16        flag;

{
   int16  min;
   char   *dns;

   if (flag == PPP_UP) {
        if (port->ppp.vjhc_max1 != -1 && port->ppp.vjhc_max2 != -1) {
             min = port->ppp.vjhc_max1;
             min = (min < port->ppp.vjhc_max2) ? min : port->ppp.vjhc_max2;
             if (min < 4) {
                  port->generic.flags &= ~ FLG_VJHC;
                }
               else
                  port->generic.flags |= FLG_VJHC;   init_vjhc (port->vjhc, min);
           }
        if (port->generic.flags & FLG_DNS) {
             if (port->ppp.p_dns || port->ppp.s_dns) {
                  buffer[0] = '\0';
                  dns = getvstr ("NAMESERVER");
                  if (dns[1])
                       strcpy (buffer, dns);
                  min = FALSE;
                  if (port->ppp.p_dns)
                       min |= add_ps_dns (buffer, port->ppp.p_dns);
                  if (port->ppp.s_dns)
                       min |= add_ps_dns (buffer, port->ppp.s_dns);
                  if (min)   setvstr ("NAMESERVER", buffer);
                }
           }
        port->generic.flags |= FLG_SUCCESS;
        ppp_log_it (port, & port->ppp.ipcp, "IP connection open.", "", -1);
      }
     else
        port->ppp.ipcp.conf_len = -1;

   port->generic.flags |= FLG_DONE;
 }


void  ipcp_create (port)

SERIAL_PORT  *port;

{
   uint8  *walk = port->ppp.ipcp.conf;

   if ((port->generic.flags & FLG_VJHC) != 0) {
        *walk++ = OPT_VJHC;
        *walk++ = 6;
        *walk++ = PPP_VJHC_C >> 8;
        *walk++ = PPP_VJHC_C & 0xff;
        *walk++ = MAX_STATES - 1;
        *walk++ = 0;
      }

   *walk++ = OPT_IP_ADDR;
   *walk++ = 6;
   fetch_32bit (walk, (uint8 *) & port->generic.ip_addr);
   walk += 4;

   if ((port->generic.flags & FLG_DNS) != 0) {
        *walk++ = OPT_PDNS_ADDR;
        *walk++ = 6;
        *walk++ = 0;   *walk++ = 0;   *walk++ = 0;   *walk++ = 0;
        port->ppp.p_dns = 0L;
      }

   if ((port->generic.flags & FLG_DNS) != 0) {
        *walk++ = OPT_SDNS_ADDR;
        *walk++ = 6;
        *walk++ = 0;   *walk++ = 0;   *walk++ = 0;   *walk++ = 0;
        port->ppp.s_dns = 0L;
      }

   port->ppp.vjhc_max1 = port->ppp.vjhc_max2 = -1;

   port->ppp.ipcp.conf_len = (int16) (walk - port->ppp.ipcp.conf);
 }


int16  ipcp_nego (port, own, source, mod)

SERIAL_PORT  *port;
uint8        *own, *source, *mod;

{
   switch (*source) {
      case OPT_VJHC :
        if ((port->generic.flags & FLG_VJHC) == 0) {
             * (int16 *) mod = 0;
             break;
           }
        * (int16 *) mod = 6;

        if (fetch_16bit (NULL, & source[2]) == PPP_VJHC_C) {
             if (3 < source[4] && source [4] < MAX_STATES  && source[5] == '\0') {
                  memcpy (& mod[2], source, 6);
                  break;
                }
           }
        mod[2] = OPT_VJHC;
        mod[3] = 6;
        * (uint16 *) mod[4] = PPP_VJHC_C;
        if (3 < source[4] && source [4] < MAX_STATES)
             mod[6] =  source[4];
          else
             mod[6] = (source[4] < 4) ? 4 : MAX_STATES - 1;
        mod[7] = 0;
        break;
      case OPT_IP_ADDR :
      case OPT_PDNS_ADDR :
      case OPT_SDNS_ADDR :
        * (int16 *) mod = 6;
        memcpy (& mod[2], source, 6);
        break;
      default :
        * (int16 *) mod = 0;
      }

   return (FALSE);
 }


int16  ipcp_imple (port, option)

SERIAL_PORT  *port;
uint8        *option;

{
   switch (*option) {
      case OPT_VJHC :
        port->ppp.vjhc_max2 = option[4];
        break;
      case OPT_IP_ADDR :
        port->generic.ip_addr = fetch_32bit (NULL, & option[2]);
        break;
      case OPT_PDNS_ADDR :
        port->ppp.p_dns = fetch_32bit (NULL, & option[2]);
        break;
      case OPT_SDNS_ADDR :
        port->ppp.s_dns = fetch_32bit (NULL, & option[2]);
        break;
      }

   return (FALSE);
 }


int16  ipcp_options (port, source, mod)

SERIAL_PORT  *port;
uint8        *source, *mod;

{
   int16  value;

   switch (*source) {
      case OPT_VJHC :
        if ((port->generic.flags & FLG_VJHC) == 0) {
             value = PPP_CONF_REJCT;
             break;
           }
        if (fetch_16bit (NULL, & source[2]) == PPP_VJHC_C) {
             if (3 < source[4] && source [4] < MAX_STATES && source[5] == '\0') {
                  value = PPP_CONF_ACK;
                  break;
                }
           }
        * (int16 *) mod = 6;
        mod[2] = OPT_VJHC;
        mod[3] = 6;
        * (uint16 *) & mod[4] = PPP_VJHC_C;
        mod[6] = MAX_STATES - 1;
        mod[7] = 0;
        value = PPP_CONF_NAK;
        break;
      case OPT_IP_ADDR :
        value = PPP_CONF_ACK;
        break;
      default :
        value = PPP_CONF_REJCT;
      }

   return (value);
 }


void  ipcp_accept (port, option)

SERIAL_PORT  *port;
uint8        *option;

{
   switch (*option) {
      case OPT_VJHC :
        port->ppp.vjhc_max1 = option[4];
        break;
      case OPT_IP_ADDR :
        break;
      }
 }


void  pap_up_down (port, flag)

SERIAL_PORT  *port;
int16        flag;

{
   if (flag == PPP_UP) {
        ppp_log_it (port, & port->ppp.pap, "Authentication acknowledged.", "", -1);
        user_event (port, PPP_LAYUP, & port->ppp.ipcp);
      }
     else
        port->ppp.pap.conf_len = -1;
 }


void  pap_create (port)

SERIAL_PORT  *port;

{
   uint8  *walk = port->ppp.pap.conf;
   int    len;
   char   *id, *pass;

   port->ppp.pap.conf_len = -1;

   id   = & port->ppp.pap_id[0];
   pass = & port->ppp.pap_passwd[0];

   len = (int) strlen (id);
   *walk++ = (uint8) ((len < 30) ? len : 30);
   strncpy (walk, id, 30);
   walk += walk[-1];

   len = (int) strlen (pass);
   *walk++ = (uint8) ((len < 30) ? len : 30);
   strncpy (walk, pass, 30);
   walk += walk[-1];

   port->ppp.pap.conf_len = (int16) (walk - port->ppp.pap.conf);
 }


int16  pap_nego (port, own, source, mod)

SERIAL_PORT  *port;
uint8        *own, *source, *mod;

{
   if (port->ppp.message) {
        memcpy (port->ppp.message, & source[1], source[0]);
        port->ppp.message[source[0]] = '\0';
      }
   user_event (port, PPP_CLOSE, & port->ppp.lcp);

   return (TRUE);
 }


int16  pap_imple (port, option)

SERIAL_PORT  *port;
uint8        *option;

{
   if (port->ppp.message) {
        memcpy (port->ppp.message, & option[1], option[0]);
        port->ppp.message[option[0]] = '\0';
      }

   if (port->ppp.pap.state == PPP_REQ_SENT)   port->ppp.pap.state = PPP_ACK_SENT;

   return (TRUE);
 }


int16  pap_options (port, source, mod)

SERIAL_PORT  *port;
uint8        *source, *mod;

{
   int16  result;

   if (pap_check_auth (port, ""))
        result = TRUE;
     else {
        user_event (port, PPP_CLOSE, & port->ppp.lcp);
        result = FALSE;
      }

   return (result);
 }


void  pap_accept (port, option)

SERIAL_PORT  *port;
uint8        *option;

{
 }
