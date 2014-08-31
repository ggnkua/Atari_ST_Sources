
/*********************************************************************/
/*                                                                   */
/*     Konfiguration der STinG High Level Protokolle                 */
/*                                                                   */
/*                                                                   */
/*      CPX-Version 0.8                     vom 23. M„rz 1997        */
/*                                                                   */
/*      zu kompilieren mit Pure C ohne String - Merging !!!          */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>

#include "sting.h"

#include "transprt.h"
#include "layer.h"

#include <xctrl.h>


/*
 *  Setup variables. Must be first variables !!!
 */
typedef  struct conf {
    int16   i_addrmask, i_advert, i_gmt_lag, t_do_icmp, u_do_icmp, dns_save;
    uint16  t_mss, t_beg_port, t_rcv_win, t_def_rtt, t_def_ttl, u_beg_port, dns_size;
    char    dns_ip[5][13], domain[64];
    int16   flag;
 } CONF;

CONF  config = {  0, 0, 0, 1, 1, 1, 
                  2000, 1024, 5000, 50, 64, 1024, 128, 
                  "", "", "", "", "", "", 
                  0   };


#pragma  warn  -rpt
#include "sting.rsh"
#pragma  warn  .rpt


#define  MESSAGE      -1
#define  CROS_CHK     (CROSSED | CHECKED)

#define  ICMP         0
#define  TCP          1
#define  UDP          2
#define  RESOLVE      3
#define  MAX_PRTCL    4


typedef  struct tcp_desc  {
     LAYER     generic;            /* Standard layer structure              */
     uint16    mss;                /* Maximum segment size                  */
     uint16    rcv_window;         /* TCP receive window                    */
     uint16    def_rtt;            /* Initial Round Trip Time in ms         */
     int16     def_ttl;            /* Default value for IP TTL              */
     int16     max_slt;            /* Estimated maximum segment lifetime    */
     uint16    con_out;            /* Outgoing connection attempts          */
     uint16    con_in;             /* Incoming connection attempts          */
     uint16    resets;             /* Counting sent resets                  */
 } TCP_CONF;


CPX_INFO *  cdecl  cpx_init (CPX_PARAMS *para_ptr);
int         cdecl  cpx_call (GRECT *window);
int         cdecl  my_button_handler (PARMBLK *parameter);
void               parse_tree (OBJECT *tree, int obj, int mode);
void               set_rsc_data (void);
void               get_rsc_data (void);
void               set_sting_data (void);
void               get_sting_data (void);
void               get_IP_address (char *str, char *dest);


extern  GEMPARBLK  _GemParBlk;

DRV_LIST    *sting_drivers;
TPL         *tpl;
STX         *stx;
LAYER       *layers[MAX_PRTCL];
CPX_PARAMS  *params;
OBJECT      *box;
USERBLK     my_user_block = {  my_button_handler,  0  };
CPX_INFO    fkts = {
               cpx_call, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL };
int         prtcl_box[] = {  ICMP_BOX, TCP_BOX, UDP_BOX, DNS_BOX  };
int         edit[] = {  I_RA_ED, MSS, U_PORT, DNS_IP  };
char        prtcl_name[][10] = {  "ICMP", "TCP", "UDP", "Resolver"  };
char        *pup[MAX_PRTCL], popup[MAX_PRTCL][15], alert[80];
int         errno, vdi_handle, num_prtcl, which[MAX_PRTCL], box_prtcl, dns;



CPX_INFO *  cdecl  cpx_init (para)

CPX_PARAMS  *para;

{
   LAYER  *my_layers, *walk;
   int    count, cnt, len, max_len = 0;

   params = para;

   if ((*params->find_cookie) ('STiK', (long *) &sting_drivers) == 0)
        return (NULL);

   if (sting_drivers == 0L)   return (NULL);

   if (strcmp (sting_drivers->magic, MAGIC) != 0)
        return (NULL);

   tpl = (TPL *) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER);
   stx = (STX *) (*sting_drivers->get_dftab) (MODULE_DRIVER);

   if (tpl == (TPL *) NULL || stx == (STX *) NULL)
        return (NULL);

   query_chains (NULL, NULL, (void **) & my_layers);

   for (count = 0; count < MAX_PRTCL; count++)
        layers[count] = NULL;

   for (walk = my_layers, num_prtcl = 0; walk != NULL; walk = walk->next) {
        for (count = 0; count < MAX_PRTCL; count++)
             if (strcmp (walk->name, prtcl_name[count]) == 0) {
                  layers[count] = walk;
                  which[num_prtcl] = count;
                  memset (popup[num_prtcl], ' ', 15);
                  strncpy (popup[num_prtcl++] + 2, walk->name, len = (int) strlen (walk->name));
                  if (max_len < len)   max_len = len;
                }
      }

   for (count = 0; count < num_prtcl; count++) {
        pup[count] = popup[count];   popup[count][max_len + 3] = '\0';
      }

   if (params->booting) {
        if (config.flag == 1 && * getvstr ("CONFSTING") == '0')
             set_sting_data();
      }
     else {
        if (! params->rsc_init) {
             (*params->do_resource)(NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                         rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                         rs_bitblk, rs_frstr, rs_frimg, rs_trindex, rs_imdope);
             box = rs_object;

             for (count = 0; count < NUM_OBS; count++) {
                  if (box[count].ob_type & 0x7f00)
                       if ((box[count].ob_state & CROS_CHK) == CROS_CHK) {
                            box[count].ob_type = G_USERDEF;
                            box[count].ob_spec.userblk = & my_user_block;
                            box[count].ob_state &= ~ CROS_CHK;
                          }
                }
             parse_tree (box, ROOT, -1);

             for (count = 1; count < MAX_PRTCL; count++) {
                  box[prtcl_box[count]].ob_flags |= HIDETREE;
                  parse_tree (box, which[count], 0);
                }
             get_sting_data();   dns = 0;   set_rsc_data();

             box_prtcl = which[0];
             strncpy (box[PROTOCOL].ob_spec.free_string, prtcl_name[box_prtcl], 10);
             strncpy (box[VERSION].ob_spec.free_string + 7, tpl->version, 5);
             parse_tree (box, prtcl_box[box_prtcl], 1);
             box[prtcl_box[box_prtcl]].ob_flags &= ~ HIDETREE;
             config.flag = 1;
           }
          else
             return (NULL);
      }

   return (&fkts);
 }


int  cdecl  cpx_call (wind)

GRECT  *wind;

{
   GRECT  rect;
   int    button, def_edit, count, old_prtcl, abort_flg = FALSE;
   int    msg_buff[8], work_in[11], work_out[57];

   graf_mouse (ARROW, NULL);

   for (count = 0; count < 10; count++)   work_in[count] = 1;
   work_in[10] = 2;

   vdi_handle = params->vdi_handle;
   v_opnvwk (work_in, &vdi_handle, work_out);

   box[ROOT].ob_x = wind->g_x;   box[ROOT].ob_y = wind->g_y;
   objc_draw (box, ROOT, MAX_DEPTH, wind->g_x, wind->g_y, wind->g_w, wind->g_h);

   def_edit = edit[box_prtcl];

   do {
        button = (*params->do_form) (box, def_edit, msg_buff);
        def_edit = 0;
        if (button > 0) {
             objc_offset (box, button &= 0x7fff, &rect.g_x, &rect.g_y);
             rect.g_w = box[button].ob_width;   rect.g_h = box[button].ob_height;
           }
        switch (button) {
           case SAVE :
             if ((*params->alert)(0)) {
                  get_rsc_data();
                  (*params->write_config) (& config, sizeof (CONF));
                  set_sting_data();
                  set_rsc_data();
                  objc_draw (box, WHOLE, MAX_DEPTH, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
                }
             break;
           case SET :
             get_rsc_data();   set_sting_data();
           case CANCEL :
             abort_flg = TRUE;
             break;
           case MESSAGE :
             if (msg_buff[0] == WM_CLOSED) {
                  get_rsc_data();   set_sting_data();
                  abort_flg = TRUE;
                }
             if (msg_buff[0] == AC_CLOSE)   abort_flg = TRUE;
             break;
           case PROTOCOL :
             old_prtcl = box_prtcl;
             for (count = 0; count < MAX_PRTCL; count++)
                  if (which[count] == box_prtcl)
                       break;
             count = (*params->do_pulldown) (pup, num_prtcl, count, IBM, & rect, wind);
             box_prtcl = (count < 0 || num_prtcl <= count) ? old_prtcl : which[count];
             if (old_prtcl != box_prtcl) {
                  strncpy (box[PROTOCOL].ob_spec.free_string, prtcl_name[box_prtcl], 10);
                  parse_tree (box, prtcl_box[old_prtcl], 0);
                  box[prtcl_box[old_prtcl]].ob_flags |= HIDETREE;
                  parse_tree (box, prtcl_box[box_prtcl], 1);
                  box[prtcl_box[box_prtcl]].ob_flags &= ~ HIDETREE;
                  objc_draw (box, WHOLE, MAX_DEPTH, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
                  def_edit = edit[box_prtcl];
                }
             break;
           case DNS_PREV :
             strncpy (config.dns_ip[dns], box[DNS_IP].ob_spec.tedinfo->te_ptext, 12);
             if (++dns == 5)   dns = 0;
             strncpy (box[DNS_IP].ob_spec.tedinfo->te_ptext, config.dns_ip[dns], 12);
             evnt_timer (60, 0);
             objc_draw (box, DNS_IP, 1, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
             break;
           case DNS_NEXT :
             strncpy (config.dns_ip[dns], box[DNS_IP].ob_spec.tedinfo->te_ptext, 12);
             if (--dns < 0)   dns = 4;
             strncpy (box[DNS_IP].ob_spec.tedinfo->te_ptext, config.dns_ip[dns], 12);
             evnt_timer (60, 0);
             objc_draw (box, DNS_IP, 1, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
             break;
           }
        if (button > 0) {
             box[button].ob_state &= ~SELECTED;
             objc_draw (box, button, 3, wind->g_x, wind->g_y, wind->g_w, wind->g_h);
           }
     } while (! abort_flg);

   v_clsvwk (vdi_handle);

   return (FALSE);
 }


int  cdecl  my_button_handler (parameter)

PARMBLK *parameter;

{
   int  clip[4], pxy[4], pos_x, pos_y, radius;

   clip[0] = parameter->pb_xc;   clip[2] = clip[0] + parameter->pb_wc - 1;
   clip[1] = parameter->pb_yc;   clip[3] = clip[1] + parameter->pb_hc - 1;
   vs_clip (vdi_handle, 1, clip);

   radius = (parameter->pb_w + parameter->pb_h) / 6;
   pos_x = parameter->pb_x + parameter->pb_w / 2;
   pos_y = parameter->pb_y + parameter->pb_h / 2;

   vsf_interior (vdi_handle, FIS_HOLLOW);

   if (parameter->pb_tree[parameter->pb_obj].ob_flags & RBUTTON) {
        v_circle (vdi_handle, pos_x, pos_y, radius);

        if (parameter->pb_currstate & SELECTED) {
             vsf_interior (vdi_handle, FIS_SOLID);
             v_circle (vdi_handle, pos_x, pos_y, radius / 2);
           }
      }
     else {
        pxy[0] = pos_x - radius;   pxy[2] = pos_x + radius;
        pxy[1] = pos_y - radius;   pxy[3] = pos_y + radius;
        v_bar (vdi_handle, pxy);

        if (parameter->pb_currstate & SELECTED) {
             pxy[0] += 2;   pxy[1] += 2;   pxy[2] -= 2;   pxy[3] -= 2;
             v_pline (vdi_handle, 2, pxy);
             radius = pxy[1];   pxy[1] = pxy[3];   pxy[3] = radius;
             v_pline (vdi_handle, 2, pxy);
           }
      }

   vs_clip (vdi_handle, 0, clip);

   return (parameter->pb_currstate & ~SELECTED);
 }


void  parse_tree (tree, object, mode)

OBJECT  *tree;
int     object, mode;

{
   int  work;

   if (mode == -1) {
        if (tree[object].ob_flags & EDITABLE)
             tree[object].ob_type |= 0x100;
      }
     else {
        if (tree[object].ob_type & 0x100) {
             if (mode == 1)
                  tree[object].ob_flags |= EDITABLE;
               else
                  tree[object].ob_flags &= ~EDITABLE;
           }
      }

   if ((work = tree[object].ob_head) == -1)
        return;

   do {
        parse_tree (tree, work, mode);
        work = tree[work].ob_next;
     } while (work != object);
 }


void  set_rsc_data()

{
   TEDINFO  *ted;
   int      count, cnt;
   char     *ptr;

   for (count = 0; count < MAX_PRTCL; count++)
        if (layers[count]) {
             switch (count) {
                case ICMP :
                  box[I_AMC].ob_state = (config.i_addrmask) ? SELECTED : NORMAL;
                  box[I_RA].ob_state  = (config.i_advert)   ? SELECTED : NORMAL;
                  sprintf (box[I_RA_ED].ob_spec.tedinfo->te_ptext, 
                                         (config.i_advert) ? "%-u" : "", config.i_advert);
                  sprintf (box[I_LAG].ob_spec.tedinfo->te_ptext, "%-d", config.i_gmt_lag);
                  break;
                case TCP :
                  sprintf (box[MSS     ].ob_spec.tedinfo->te_ptext, "%-u", config.t_mss);
                  sprintf (box[RCV_WIN ].ob_spec.tedinfo->te_ptext, "%-u", config.t_rcv_win);
                  sprintf (box[T_PORT  ].ob_spec.tedinfo->te_ptext, "%-u", config.t_beg_port);
                  sprintf (box[DEF_TTL ].ob_spec.tedinfo->te_ptext, "%-u", config.t_def_ttl);
                  sprintf (box[RTT_INIT].ob_spec.tedinfo->te_ptext, "%5u", config.t_def_rtt);
                  box[T_ICMP].ob_state = (config.t_do_icmp) ? SELECTED : NORMAL;
                  ptr = & box[RTT_INIT].ob_spec.tedinfo->te_ptext[1];
                  while (*ptr == ' ')   *ptr++ = '0';
                  break;
                case UDP :
                  sprintf (box[U_PORT].ob_spec.tedinfo->te_ptext, "%-u", config.u_beg_port);
                  box[U_ICMP].ob_state = (config.u_do_icmp) ? SELECTED : NORMAL;
                  break;
                case RESOLVE :
                  strncpy (box[DNS_IP].ob_spec.tedinfo->te_ptext, config.dns_ip[dns], 12);
                  ted = box[DNS_DOM].ob_spec.tedinfo;
                  strncpy (ted->te_ptext, config.domain, ted->te_txtlen - 1);
                  sprintf (box[DNS_CSZ].ob_spec.tedinfo->te_ptext, "%-u", config.dns_size);
                  box[DNS_CSV].ob_state = (config.dns_save) ? SELECTED : NORMAL;
                  break;
                }
           }
 }


void  get_rsc_data()

{
   TEDINFO  *ted;
   int      count, cnt;
   char     *ptr;

   for (count = 0; count < MAX_PRTCL; count++)
        if (layers[count]) {
             switch (count) {
                case ICMP :
                  config.i_addrmask = (box[I_AMC].ob_state & SELECTED) ? TRUE : FALSE;
                  config.i_advert   = (box[I_RA].ob_state & SELECTED) ?
                                           atoi (box[I_RA_ED].ob_spec.tedinfo->te_ptext) : 0;
                  config.i_gmt_lag  = atoi (box[I_LAG].ob_spec.tedinfo->te_ptext);
                  break;
                case TCP :
                  ptr = box[RTT_INIT].ob_spec.tedinfo->te_ptext;
                  while (strlen (ptr) < 5)   strcat (ptr, "0");
                  config.t_mss      = atoi (box[MSS     ].ob_spec.tedinfo->te_ptext);
                  config.t_rcv_win  = atoi (box[RCV_WIN ].ob_spec.tedinfo->te_ptext);
                  config.t_beg_port = atoi (box[T_PORT  ].ob_spec.tedinfo->te_ptext);
                  config.t_def_ttl  = atoi (box[DEF_TTL ].ob_spec.tedinfo->te_ptext);
                  config.t_def_rtt  = atoi (box[RTT_INIT].ob_spec.tedinfo->te_ptext);
                  config.t_do_icmp  = (box[T_ICMP].ob_state & SELECTED) ? TRUE : FALSE;
                  break;
                case UDP :
                  config.u_beg_port = atoi (box[U_PORT].ob_spec.tedinfo->te_ptext);
                  config.u_do_icmp  = (box[U_ICMP].ob_state & SELECTED) ? TRUE : FALSE;
                  break;
                case RESOLVE :
                  strncpy (config.dns_ip[dns], box[DNS_IP].ob_spec.tedinfo->te_ptext, 12);
                  ted = box[DNS_DOM].ob_spec.tedinfo;
                  if (strncmp (config.domain, ted->te_ptext, ted->te_txtlen - 1) != 0)
                       strcpy (config.domain, ted->te_ptext);
                  config.dns_size = atoi (box[DNS_CSZ].ob_spec.tedinfo->te_ptext);
                  config.dns_save = (box[DNS_CSV].ob_state & SELECTED) ? TRUE : FALSE;
                  break;
                }
           }
 }


void  set_sting_data()

{
   int   count, cnt, byte;
   char  temp[64], buff[4], *con, *ptr;

   for (count = 0; count < MAX_PRTCL; count++)
        if (layers[count]) {
             switch (count) {
                case ICMP :
                  layers[ICMP]->flags  =          config.i_addrmask;
                  layers[ICMP]->flags |= (uint32) config.i_advert  << 8;
                  layers[ICMP]->flags |=  (int32) config.i_gmt_lag << 16;
                  break;
                case TCP :
                  layers[TCP]->flags = config.t_beg_port | ((config.t_do_icmp) ? 0x10000L : 0L);
                  ((TCP_CONF *) layers[TCP])->mss        = config.t_mss;
                  ((TCP_CONF *) layers[TCP])->rcv_window = config.t_rcv_win;
                  ((TCP_CONF *) layers[TCP])->def_ttl    = config.t_def_ttl;
                  ((TCP_CONF *) layers[TCP])->def_rtt    = config.t_def_rtt;
                  ((TCP_CONF *) layers[TCP])->max_slt    = config.t_def_rtt * 4;
                  break;
                case UDP :
                  layers[UDP]->flags = config.u_beg_port | ((config.u_do_icmp) ? 0x10000L : 0L);
                  break;
                case RESOLVE :
                  for (cnt = 0, temp[0] = buff[3] = '\0'; cnt < 5; cnt++) {
                       if (config.dns_ip[cnt][0]) {
                            for (byte = 0; byte < 4; byte++) {
                                 con = buff;
                                 strncpy (con, & config.dns_ip[cnt][3 * byte], 3);
                                 while (*con == ' ')
                                      con++;
                                 if ((ptr = strchr (con, ' ')) != NULL)
                                      *ptr = '\0';
                                 strcat (temp, con);   strcat (temp, ".");
                               }
                            strcpy (& temp[strlen(temp) - 1], ", ");
                          }
                     }
                  if (temp[0])
                       *strrchr (temp, ',') = '\0';
                  setvstr ("NAMESERVER", temp);
                  setvstr ("DOMAIN", config.domain);
                  sprintf (temp, "%d", config.dns_size);   setvstr ("DNS_CACHE", temp);
                  setvstr ("DNS_SAVE", (config.dns_save != 0) ? "TRUE" : "FALSE");
                  break;
                }
           }
 }


void  get_sting_data()

{
   int   count, cnt;
   char  *dns_ptr;

   for (count = 0; count < MAX_PRTCL; count++)
        if (layers[count]) {
             switch (count) {
                case ICMP :
                  config.i_addrmask =  layers[ICMP]->flags & 0x0001ul;
                  config.i_advert   = (layers[ICMP]->flags & 0xff00ul) >> 8;
                  config.i_gmt_lag  = (int32) layers[ICMP]->flags >> 16;
                  break;
                case TCP :
                  config.t_beg_port =  layers[TCP]->flags & 0xfffful;
                  config.t_do_icmp  = (layers[TCP]->flags & 0x10000ul) ? 1 : 0;
                  config.t_mss      = ((TCP_CONF *) layers[TCP])->mss;
                  config.t_rcv_win  = ((TCP_CONF *) layers[TCP])->rcv_window;
                  config.t_def_ttl  = ((TCP_CONF *) layers[TCP])->def_ttl;
                  config.t_def_rtt  = ((TCP_CONF *) layers[TCP])->def_rtt;
                  break;
                case UDP :
                  config.u_beg_port =  layers[UDP]->flags & 0xfffful;
                  config.u_do_icmp  = (layers[UDP]->flags & 0x10000ul) ? 1 : 0;
                  break;
                case RESOLVE :
                  dns_ptr = getvstr ("NAMESERVER");
                  for (cnt = 0; cnt < 5; cnt++) {
                       get_IP_address (dns_ptr, config.dns_ip[cnt]);
                       if (strchr (dns_ptr, ','))
                            dns_ptr = strchr (dns_ptr, ',') + 1;
                         else
                            dns_ptr = "";
                     }
                  strncpy (config.domain, getvstr ("DOMAIN"), 63);
                  config.domain[63] = '\0';
                  config.dns_size = atoi (getvstr ("DNS_CACHE"));
                  if (config.dns_size < 32)   config.dns_size = 32;
                  dns_ptr = getvstr ("DNS_SAVE");
                  config.dns_save = (strcmp (dns_ptr, "1") && strcmp (dns_ptr, "TRUE")) ? 0 : 1;
                  break;
                }
           }
 }


void  get_IP_address (string, dest_str)

char    *string, *dest_str;

{
   int16   count, dots, array[5];
   char    chr;

   array[0] = atoi (string);

   for (count = dots = 0; dots < 4; count++) {
        chr = string[count];
        if (chr == ' ' || ('0' <= chr && chr <= '9') || chr == '.') {
             if (chr == '.')
                  array[++dots] = atoi (& string[count + 1]);
           }
          else
             break;
      }

   if (dots == 3)
        sprintf (dest_str, "%-3d%-3d%-3d%-d", array[0], array[1], array[2], array[3]);
     else
        *dest_str = '\0';
 }
