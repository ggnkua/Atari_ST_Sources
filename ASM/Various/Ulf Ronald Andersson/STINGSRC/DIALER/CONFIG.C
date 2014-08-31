
/*********************************************************************/
/*                                                                   */
/*     STinG : Modem Dialer, Configuration module                    */
/*                                                                   */
/*                                                                   */
/*      Version 1.1                        from 16. Januar 1997      */
/*                                                                   */
/*      Module for Configuration of the Dialer and STinG             */
/*                                                                   */
/*********************************************************************/


#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <device.h>

#include "dial.h"
#include "window.h"


#define  FALSE              0
#define  TRUE               1

#define  S_NONE             0

#define  MAX_SCRIPT_SIZE   32
#define  TEDTEXT(a)        (tree[(a)].ob_spec.tedinfo->te_ptext)

#define  SELECT(a)         (tree[(a)].ob_state |= SELECTED)
#define  DESELECT(a)       (tree[(a)].ob_state &= ~SELECTED)
#define  ENABLE(a)         (tree[(a)].ob_state &= ~DISABLED)
#define  DISABLE(a)        (tree[(a)].ob_state |= DISABLED)


void    set_configuration (void);
int     get_port (void);
int     read_fee (char *buffer);

int     init_config_stuff (void),  conf_click (int object);
void    fill_in_config_box (void),  read_out_config_box (void);
void    reset_config (void),  parse_tree (OBJECT *tree, int obj, int mode);
int     choose_dial_script (void),  load_dial_script (char file[]);
char    get_char (int handle, int *eof);
int     compare (char buff[], int *flag, char fix[]);
void    load_config_part (int handle, int *eof);
int     load_script_part (int handle, int *eof);
long    load_ip_addr (unsigned char ip[], char buffer[]);
void    ted_ip_addr (unsigned char ip[], char *buffer);
int     read_boolean (char buffer[]);
void    read_cost (char buffer[], long *ISP_unit, long *ISP_cost);
int     read_environment (char buffer[]);
void    save_dial_script (void);
void    save_config_part (int handle),  save_script_part (int handle);
void    write_text_line (int handle, char desc[], char text[]);
void    write_number_line (int handle, char desc[], int number);
void    set_tedinfo_text (int tree, int obj, char text[]);
void    get_tedinfo_text (int tree, int obj, char text[]);
void    set_tedinfo_number (int tree, int obj, int number);
void    get_tedinfo_number (int tree, int obj, int *number);
void    get_fee_file (void);


extern GEMPARBLK      _GemParBlk;

extern int            tcpip_version, dial_state, digits, masque_there;
extern char           config_path[], *ports[], unit[];
extern unsigned char  ip_address[4], ip_dns[4][4];

int   conf_shown = 0, port_lock = FALSE, alert_mode, has_LAN;
int   conf_box[] = { CM_BOX,  CD_BOX,  CP_BOX, CA_BOX,  CT_BOX, CN_BOX, CG_BOX };
int   edit[]     = { CM_INIT, CD_TOUT, CP_IP,  CA_USER, CT_NUM, CN_ED1, 0 };
int   environ[]  = { CN_ED1, CN_ED2, CN_ED3, CN_ED4, CN_ED5, CN_ED6, CN_ED7 };
char  alert_form[] = "[1][ |  Wrong format in script variable  |     "
                     "\'%s\'|  Line ignored !][ Oops ]";
char  ip_format[] = "%-3d%-3d%-3d%-d", ip_out[] = "%d.%d.%d.%d", script_path[256];

char  modem_init[17] = "ATZ", modem_dial[9] = "ATDT", modem_hangup[9] = "+++,ATH";
int   connect_timeout = 60, redial_delay = 20;
int   o_conn[3] = { CM_CON1,CM_CON2,CM_CON3 }, o_abrt[3] = { CM_ABO1,CM_ABO2,CM_ABO3 };
int   o_redl[3] = { CM_RED1,CM_RED2,CM_RED3 };
char  s_conn[3][13] = { "CONNECT", "", "" }, s_abrt[3][13] = { "NO DIALTONE", "", "" };
char  s_redl[3][13] = { "BUSY", "NO CARRIER", "" };

int   script_which = 0, script_length = 0, script_timeout = 30;
char  script[MAX_SCRIPT_SIZE + 1][4][32];

int   port_flags = 0, port_mtu = 252, protocol = 0, papp_flag = FALSE;
char  pap_id[32], pap_passwd[32];

char  username[17] = "", fullname[33] = "", fqdn[43] = "";
int   act_dns = 0, dns_num = 0;

int   act_phone = 0, phone_num = 0;
char  phone[8][17] = { "","","","","","","","" }, fee_file[13] = "";
long  ISP_u_time, ISP_u_sent, ISP_u_recvd, ISP_c_time, ISP_c_sent, ISP_c_recvd;

char  **environ_base, *environ_used;
int   environ_number, environ_offset;

int   num_ports, act_port = 0, def_route = TRUE, masquerade = FALSE;
int   run_tools = FALSE, compuserve = FALSE, resident = FALSE, debugging = FALSE;



int  init_config_stuff()

{
   OBJECT  *tree, *popup;
   int     count, net;

   strcpy (script_path, config_path);
   if (strrchr (script_path, '\\') == NULL)   strcat (script_path, "\\");

   if ((environ_base = (char **) Malloc (2048L)) == NULL)
        return (FALSE);

   rsrc_gaddr (R_TREE, CONF, &tree);

   parse_tree (tree, ROOT, -1);

   tree[CD_BOX].ob_x = tree[CM_BOX].ob_x,  tree[CD_BOX].ob_y = tree[CM_BOX].ob_y;
   tree[CD_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CD_BOX, 0);

   tree[CP_BOX].ob_x = tree[CM_BOX].ob_x,  tree[CP_BOX].ob_y = tree[CM_BOX].ob_y;
   tree[CP_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CP_BOX, 0);

   tree[CA_BOX].ob_x = tree[CM_BOX].ob_x,  tree[CA_BOX].ob_y = tree[CM_BOX].ob_y;
   tree[CA_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CA_BOX, 0);

   tree[CT_BOX].ob_x = tree[CM_BOX].ob_x,  tree[CT_BOX].ob_y = tree[CM_BOX].ob_y;
   tree[CT_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CT_BOX, 0);

   tree[CN_BOX].ob_x = tree[CM_BOX].ob_x,  tree[CN_BOX].ob_y = tree[CM_BOX].ob_y;
   tree[CN_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CN_BOX, 0);

   tree[CG_BOX].ob_x = tree[CM_BOX].ob_x,  tree[CG_BOX].ob_y = tree[CM_BOX].ob_y;
   tree[CG_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CG_BOX, 0);

   rsrc_gaddr (R_TREE, PU_C_TYP, &popup);
   strcpy (tree[CC_M_NAM].ob_spec.free_string, popup[1].ob_spec.free_string + 2);

   for (count = 0; count < 4; count++)
        for (net = 0; net < 4; net++)   ip_dns[count][net] = '\0';

   if (_GemParBlk.global[1] == 1) {
        DISABLE (CG_RESI);    DISABLE (CG_RTXT);
      }

   if (masque_there == FALSE) {
        DISABLE (CG_MASQU);    DISABLE (CG_MTXT);
      }

   return (TRUE);
 }


void  fill_in_config_box()

{
   OBJECT  *tree;
   char    temp[42], *ptr, *frmt = "%ld.%03ld";
   int     count;

   rsrc_gaddr (R_TREE, CONF, &tree);

   if (strlen (script_path) > 40) {
        strncpy (temp, script_path, 20);   temp[20] = '\0';
        if (strchr (temp, '\\'))
             strcpy (strchr (temp, '\\') + 1, "...");
          else
             strcpy (temp, "...");
        ptr = script_path + strlen(script_path) - 40 + strlen(temp);
        if (strchr (ptr, '\\'))   ptr = strchr (ptr, '\\');
        strcat (temp, ptr);
        set_tedinfo_text (CONF, CC_SCRPT, temp);
      }
     else
        set_tedinfo_text (CONF, CC_SCRPT, script_path);

   for (count = 0; count < 3; count++) {
        set_tedinfo_text (CONF, o_conn[count], s_conn[count]);
        set_tedinfo_text (CONF, o_redl[count], s_redl[count]);
        set_tedinfo_text (CONF, o_abrt[count], s_abrt[count]);
      }
   set_tedinfo_text (CONF, CM_INIT, modem_init);
   set_tedinfo_text (CONF, CM_DIAL, modem_dial);
   set_tedinfo_text (CONF, CM_HANG, modem_hangup);
   set_tedinfo_number (CONF, CM_CTOUT, connect_timeout);
   set_tedinfo_number (CONF, CM_RDLAY, redial_delay);

   script_which = 0;
   if (script_length < 2)
        DISABLE (CD_PREV),  DISABLE (CD_NEXT);
   if (script_length == 0)
        DISABLE (CD_DEL);
   if (script_length == MAX_SCRIPT_SIZE)
        DISABLE (CD_INS);
   set_tedinfo_number (CONF, CD_TOUT, script_timeout);
   set_tedinfo_text (CONF, CD_STEP, "  1 ");
   set_tedinfo_text (CONF, CD_TIME, script[0][0]);
   set_tedinfo_text (CONF, CD_REPT, script[0][1]);
   set_tedinfo_text (CONF, CD_FIND, script[0][2]);
   set_tedinfo_text (CONF, CD_RESP, script[0][3]);

   sprintf (temp, ip_format, (int) ip_address[0], (int) ip_address[1],
              (int) ip_address[2], (int) ip_address[3]);
   set_tedinfo_text (CONF, CP_IP, (strcmp (temp, "0  0  0  0") == 0) ? "" : temp);
   set_tedinfo_number (CONF, CP_MTU, port_mtu);
   set_tedinfo_text (CONF, CP_PID,   pap_id);
   set_tedinfo_text (CONF, CP_PPASS, pap_passwd);
   if (protocol != 0) {
        tree[CP_PID].ob_flags   |= EDITABLE;     ENABLE (CP_PID);
        tree[CP_PPASS].ob_flags |= EDITABLE;     ENABLE (CP_PPTXT);
        ENABLE (CP_FPPW);    ENABLE (CP_PPPW);   ENABLE (CP_TPPW);
        ENABLE (CA_GETNS);   ENABLE (CA_NSTXT);
      }
     else {
        tree[CP_PID].ob_flags   &= ~EDITABLE;      DISABLE (CP_PID);
        tree[CP_PPASS].ob_flags &= ~EDITABLE;      DISABLE (CP_PPTXT);
        DISABLE (CP_FPPW);    DISABLE (CP_PPPW);   DISABLE (CP_TPPW);
        DISABLE (CA_GETNS);   DISABLE (CA_NSTXT);
      }
   DESELECT (CP_SLIP);   DESELECT (CP_PPP);
   (protocol  == 0)  ? SELECT (CP_SLIP) : SELECT (CP_PPP);
   DESELECT (CP_FPPW);   DESELECT (CP_PPPW);
   (papp_flag == 0)  ? SELECT (CP_FPPW) : SELECT (CP_PPPW);
   (port_flags & 2) ? SELECT (CP_VJHC) : DESELECT (CP_VJHC);
   (port_flags & 4) ? SELECT (CP_LAN)  : DESELECT (CP_LAN);
   if (strcmp (ports[act_port], "Ser.2/LAN") == 0 && has_LAN) {
        ENABLE (CP_LAN);   ENABLE (CP_LTXT);
      }
     else {
        DISABLE (CP_LAN);   DISABLE (CP_LTXT);   DESELECT (CP_LAN);
      }

   set_tedinfo_text (CONF, CA_USER, username);
   set_tedinfo_text (CONF, CA_FULL, fullname);
   set_tedinfo_text (CONF, CA_FQDN, fqdn);
   (dns_num != 4) ? ENABLE (CA_ADD) : DISABLE (CA_ADD);
   if (dns_num) {
        sprintf (temp, ip_format, (int) ip_dns[act_dns][0], (int) ip_dns[act_dns][1],
                   (int) ip_dns[act_dns][2], (int) ip_dns[act_dns][3]);
      }
   set_tedinfo_text (CONF, CA_DNS, (dns_num) ? temp : "");
   (port_flags & 8) ? SELECT (CA_GETNS) : DESELECT (CA_GETNS);

   (phone_num != 8) ? ENABLE (CT_ADD) : DISABLE (CT_ADD);
   set_tedinfo_text (CONF, CT_NUM, (phone_num) ? phone[act_phone] : "");
   set_tedinfo_text (CONF, CT_FEE, fee_file);
   if ((ptr = (char *) Malloc (10250L)) != NULL) {
        if (read_fee (ptr) != 0) {
             strcpy (unit, "$");   digits = 2;
           }
        Mfree (ptr);
      }
     else {
        strcpy (unit, "$");   digits = 2;
      }
   sprintf (TEDTEXT (CI_TU), "%ld", ISP_u_time);
   sprintf (TEDTEXT (CI_SU), "%ld", ISP_u_sent);
   sprintf (TEDTEXT (CI_RU), "%ld", ISP_u_recvd);
   strncpy (& temp[10], unit, 4);   temp[14] = '\0';
   sprintf (temp, "%4s", & temp[10]);
   strncpy (tree[CI_TC].ob_spec.tedinfo->te_ptmplt, temp, 4);
   strncpy (tree[CI_SC].ob_spec.tedinfo->te_ptmplt, temp, 4);
   strncpy (tree[CI_RC].ob_spec.tedinfo->te_ptmplt, temp, 4);
   sprintf (temp, frmt,  ISP_c_time / 1000,  ISP_c_time % 1000);
   *(strchr (temp, '.') + digits + 1) = '\0';   set_tedinfo_text (CONF, CI_TC, temp);
   sprintf (temp, frmt,  ISP_c_sent / 1000,  ISP_c_sent % 1000);
   *(strchr (temp, '.') + digits + 1) = '\0';   set_tedinfo_text (CONF, CI_SC, temp);
   sprintf (temp, frmt, ISP_c_recvd / 1000, ISP_c_recvd % 1000);
   *(strchr (temp, '.') + digits + 1) = '\0';   set_tedinfo_text (CONF, CI_RC, temp);

   environ_offset = 0;
   set_tedinfo_text (CONF, CN_OFF, "  0 ");
   for (count = 0; count < 7; count++) {
        set_tedinfo_text (CONF, environ[count], (count < environ_number) ? environ_base[count] : "");
      }

   strncpy (tree[CG_PORT].ob_spec.free_string, ports[act_port], 10);
   (def_route)  ? SELECT (CG_DEFRT) : DESELECT (CG_DEFRT);
   (masquerade) ? SELECT (CG_MASQU) : DESELECT (CG_MASQU);
   (run_tools)  ? SELECT (CG_LOGIN) : DESELECT (CG_LOGIN);
   (compuserve) ? SELECT (CG_CIX)   : DESELECT (CG_CIX);
   (resident)   ? SELECT (CG_RESI)  : DESELECT (CG_RESI);
   (debugging)  ? SELECT (CG_DEBUG) : DESELECT (CG_DEBUG);
 }


void  read_out_config_box()

{
   OBJECT  *tree;
   char    temp[32], *frmt = "%s, %s";
   int     count;

   rsrc_gaddr (R_TREE, CONF, &tree);

   for (count = 0; count < 3; count++) {
        get_tedinfo_text (CONF, o_conn[count], s_conn[count]);
        get_tedinfo_text (CONF, o_redl[count], s_redl[count]);
        get_tedinfo_text (CONF, o_abrt[count], s_abrt[count]);
      }
   get_tedinfo_text (CONF, CM_INIT, modem_init);
   get_tedinfo_text (CONF, CM_DIAL, modem_dial);
   get_tedinfo_text (CONF, CM_HANG, modem_hangup);
   get_tedinfo_number (CONF, CM_CTOUT, &connect_timeout);
   get_tedinfo_number (CONF, CM_RDLAY, &redial_delay);

   get_tedinfo_number (CONF, CD_TOUT, &script_timeout);
   get_tedinfo_text (CONF, CD_TIME, script[script_which][0]);
   get_tedinfo_text (CONF, CD_REPT, script[script_which][1]);
   get_tedinfo_text (CONF, CD_FIND, script[script_which][2]);
   get_tedinfo_text (CONF, CD_RESP, script[script_which][3]);

   get_tedinfo_text (CONF, CP_IP, temp);   ted_ip_addr (ip_address, temp);
   get_tedinfo_number (CONF, CP_MTU, & port_mtu);
   get_tedinfo_text (CONF, CP_PID,   pap_id);
   get_tedinfo_text (CONF, CP_PPASS, pap_passwd);
   protocol    = (tree[CP_SLIP].ob_state & SELECTED) ? 0 : 1;
   papp_flag   = (tree[CP_FPPW].ob_state & SELECTED) ? 0 : 1;
   port_flags  = protocol;
   port_flags |= (tree[CP_VJHC].ob_state & SELECTED) ? 2 : 0;
   port_flags |= (tree[CP_LAN ].ob_state & SELECTED) ? 4 : 0;

   get_tedinfo_text (CONF, CA_USER, username);
   get_tedinfo_text (CONF, CA_FULL, fullname);
   get_tedinfo_text (CONF, CA_FQDN, fqdn);
   get_tedinfo_text (CONF, CA_DNS, temp);   ted_ip_addr (ip_dns[act_dns], temp);
   for (count = 0; count < dns_num; count++)
        if (ip_dns[count][0] == 0) {
             --dns_num;
             ip_dns[count][0] = ip_dns[dns_num][0];   ip_dns[count][1] = ip_dns[dns_num][1];
             ip_dns[count][2] = ip_dns[dns_num][2];   ip_dns[count][3] = ip_dns[dns_num][3];
           }
   port_flags |= (tree[CA_GETNS].ob_state & SELECTED) ? 8 : 0;

   get_tedinfo_text (CONF, CT_NUM, phone[act_phone]);
   for (count = 0; count < phone_num; count++)
        if (phone[count][0] == '\0')
             strcpy (phone[count], phone[--phone_num]);
   get_tedinfo_text (CONF, CT_FEE, fee_file);
   sprintf (temp, frmt, TEDTEXT (CI_TU), TEDTEXT (CI_TC));
   read_cost (temp, &ISP_u_time,  &ISP_c_time);
   sprintf (temp, frmt, TEDTEXT (CI_SU), TEDTEXT (CI_SC));
   read_cost (temp, &ISP_u_sent,  &ISP_c_sent);
   sprintf (temp, frmt, TEDTEXT (CI_RU), TEDTEXT (CI_RC));
   read_cost (temp, &ISP_u_recvd, &ISP_c_recvd);

   def_route  = (tree[CG_DEFRT].ob_state & SELECTED) ? TRUE : FALSE;
   masquerade = (tree[CG_MASQU].ob_state & SELECTED) ? TRUE : FALSE;
   run_tools  = (tree[CG_LOGIN].ob_state & SELECTED) ? TRUE : FALSE;
   compuserve = (tree[CG_CIX  ].ob_state & SELECTED) ? TRUE : FALSE;
   resident   = (tree[CG_RESI ].ob_state & SELECTED) ? TRUE : FALSE;
   debugging  = (tree[CG_DEBUG].ob_state & SELECTED) ? TRUE : FALSE;
 }


void  reset_config()

{
   interupt_editing (CONF, BEGIN, -1);
   fill_in_config_box();
   change_flags (CONF, CON_BOX, 0, 0, 0);
   interupt_editing (CONF, END, edit[conf_shown]);
 }


int  conf_click (object)

int  object;

{
   OBJECT  *tree;
   char    temp[16];
   int     count, index, last_shown;
   char    alert[] = "[3][ |  Not possible while  | |  port enabled !][ Hmmm ]";

   object &= 0x7fff;

   evnt_timer (60, 0);

   if (object != CP_SLIP && object != CP_PPP && object != CP_FPPW && object != CP_PPPW)
        change_flags (CONF, object, 0, 0, SELECTED);

   rsrc_gaddr (R_TREE, CONF, &tree);

   switch (object) {
      case CC_SCRPT :
        if (choose_dial_script() > 0)
             reset_config();
        break;
      case CC_SAVE :
      case CC_SET :
        if (port_lock)
             form_alert (1, alert);
          else {
             read_out_config_box();
             set_configuration();
             if (object == CC_SAVE)   save_dial_script();
           }
        break;
      case CC_M_NAM :
        last_shown = conf_shown++;
        pop_up (PU_C_TYP, &conf_shown, CONF, CC_M_NAM, 16);
        if (last_shown != --conf_shown) {
             interupt_editing (CONF, BEGIN, -1);
             parse_tree (tree, conf_box[last_shown], 0);
             tree[conf_box[last_shown]].ob_flags |= HIDETREE;
             parse_tree (tree, conf_box[conf_shown], 1);
             if (tree[CP_SLIP].ob_state & SELECTED) {
                  tree[CP_PID].ob_flags   &= ~EDITABLE;
                  tree[CP_PPASS].ob_flags &= ~EDITABLE;
                }
             change_flags (CONF, conf_box[conf_shown], 0, HIDETREE, 0);
             interupt_editing (CONF, END, edit[conf_shown]);
           }
        break;
      case CD_PREV :
      case CD_NEXT :
        if (script_length > 0) {
             interupt_editing (CONF, BEGIN, -1);
             get_tedinfo_text (CONF, CD_TIME, script[script_which][0]);
             get_tedinfo_text (CONF, CD_REPT, script[script_which][1]);
             get_tedinfo_text (CONF, CD_FIND, script[script_which][2]);
             get_tedinfo_text (CONF, CD_RESP, script[script_which][3]);
             if (object == CD_PREV) {
                  if (--script_which < 0)   script_which = script_length - 1;
                }
               else {
                  if (++script_which >= script_length)   script_which = 0;
                }
             sprintf (temp, " %2d ", script_which + 1);
             set_tedinfo_text (CONF, CD_STEP, temp);
             set_tedinfo_text (CONF, CD_TIME, script[script_which][0]);
             set_tedinfo_text (CONF, CD_REPT, script[script_which][1]);
             set_tedinfo_text (CONF, CD_FIND, script[script_which][2]);
             set_tedinfo_text (CONF, CD_RESP, script[script_which][3]);
             change_flags (CONF, CD_IBOX, 0, 0, 0);
             interupt_editing (CONF, END, CD_TIME);
           }
        break;
      case CD_INS :
        if (script_length < MAX_SCRIPT_SIZE) {
             interupt_editing (CONF, BEGIN, -1);
             get_tedinfo_text (CONF, CD_TIME, script[script_which][0]);
             get_tedinfo_text (CONF, CD_REPT, script[script_which][1]);
             get_tedinfo_text (CONF, CD_FIND, script[script_which][2]);
             get_tedinfo_text (CONF, CD_RESP, script[script_which][3]);
             script_length++;
             for (count = script_length; count > script_which; --count)
                  for (index = 0; index < 4; index++)
                       strcpy (script[count][index], script[count - 1][index]);
             script[script_which][0][0] = script[script_which][1][0] = 
                     script[script_which][2][0] = script[script_which][3][0] = '\0';
             if (script_length == MAX_SCRIPT_SIZE)
                  DISABLE (CD_INS);
             if (script_length >= 2) {
                  ENABLE (CD_PREV);   ENABLE (CD_NEXT);
                }
             set_tedinfo_text (CONF, CD_TIME, "");
             set_tedinfo_text (CONF, CD_REPT, "");
             set_tedinfo_text (CONF, CD_FIND, "");
             set_tedinfo_text (CONF, CD_RESP, "");
             ENABLE (CD_DEL);
             change_flags (CONF, CD_IBOX, 0, 0, 0);
             interupt_editing (CONF, END, CD_TIME);
           }
        break;
      case CD_DEL :
        if (script_length > 0) {
             interupt_editing (CONF, BEGIN, -1);
             for (count = script_which; count < script_length; count++)
                  for (index = 0; index < 4; index++)
                       strcpy (script[count][index], script[count + 1][index]);
             if (script_which == --script_length) {
                  script_which = script_length - 1;
                  if (script_length == 0) {
                       script_which = 0;   DISABLE (CD_DEL);
                     }
                  sprintf (temp, " %2d ", script_which + 1);
                  set_tedinfo_text (CONF, CD_STEP, temp);
                }
             if (script_length < 2) {
                  DISABLE (CD_PREV);   DISABLE (CD_NEXT);
                }
             set_tedinfo_text (CONF, CD_TIME, script[script_which][0]);
             set_tedinfo_text (CONF, CD_REPT, script[script_which][1]);
             set_tedinfo_text (CONF, CD_FIND, script[script_which][2]);
             set_tedinfo_text (CONF, CD_RESP, script[script_which][3]);
             ENABLE (CD_INS);
             change_flags (CONF, CD_IBOX, 0, 0, 0);
             interupt_editing (CONF, END, CD_TIME);
           }
        break;
      case CP_SLIP :
        interupt_editing (CONF, BEGIN, -1);
        tree[CP_PID].ob_flags   &= ~EDITABLE;
        tree[CP_PPASS].ob_flags &= ~EDITABLE;
        change_flags (CONF, CP_PID,   1, 0, DISABLED);
        change_flags (CONF, CP_PPTXT, 1, 0, DISABLED);
        change_flags (CONF, CP_FPPW,  1, 0, DISABLED);
        change_flags (CONF, CP_PPPW,  1, 0, DISABLED);
        change_flags (CONF, CP_TPPW,  1, 0, DISABLED);
        DISABLE (CA_GETNS);   DISABLE (CA_NSTXT);
        interupt_editing (CONF, END, CP_IP);
        break;
      case CP_PPP :
        tree[CP_PID].ob_flags   |= EDITABLE;
        tree[CP_PPASS].ob_flags |= EDITABLE;
        change_flags (CONF, CP_PID,   0, 0, DISABLED);
        change_flags (CONF, CP_PPTXT, 0, 0, DISABLED);
        change_flags (CONF, CP_FPPW,  0, 0, DISABLED);
        change_flags (CONF, CP_PPPW,  0, 0, DISABLED);
        change_flags (CONF, CP_TPPW,  0, 0, DISABLED);
        ENABLE (CA_GETNS);   ENABLE (CA_NSTXT);
        break;
      case CA_PREV :
      case CA_NEXT :
        if (dns_num == 0)   break;
        interupt_editing (CONF, BEGIN, -1);
        get_tedinfo_text (CONF, CA_DNS, temp);
        ted_ip_addr (ip_dns[act_dns], temp);
        if (object == CA_PREV) {
             if (--act_dns < 0)   act_dns = dns_num - 1;
           }
          else {
             if (++act_dns >= dns_num)   act_dns = 0;
           }
        sprintf (temp, ip_format, (int) ip_dns[act_dns][0], (int) ip_dns[act_dns][1],
              (int) ip_dns[act_dns][2], (int) ip_dns[act_dns][3]);
        set_tedinfo_text (CONF, CA_DNS, temp);
        change_flags (CONF, CA_DNS, 0, 0, 0);
        interupt_editing (CONF, END, CA_DNS);
        break;
      case CA_ADD :
        interupt_editing (CONF, BEGIN, -1);
        get_tedinfo_text (CONF, CA_DNS, temp);
        ted_ip_addr (ip_dns[act_dns], temp);
        for (count = 0; count < dns_num; count++)
             if (ip_dns[count][0] == 0)
                  break;
        if (count < 4) {
             act_dns = (count == dns_num) ? dns_num++ : count;
             ip_dns[act_dns][0] = ip_dns[act_dns][1] = ip_dns[act_dns][2] =
                                  ip_dns[act_dns][3] = 0;
             set_tedinfo_text (CONF, CA_DNS, "");
             change_flags (CONF, CA_DNS, 0, 0, 0);
           }
        interupt_editing (CONF, END, CA_DNS);
        break;
      case CT_PREV :
      case CT_NEXT :
        if (phone_num == 0)   break;
        interupt_editing (CONF, BEGIN, -1);
        get_tedinfo_text (CONF, CT_NUM, phone[act_phone]);
        if (object == CT_PREV) {
             if (--act_phone < 0)   act_phone = phone_num - 1;
           }
          else {
             if (++act_phone >= phone_num)   act_phone = 0;
           }
        set_tedinfo_text (CONF, CT_NUM, phone[act_phone]);
        change_flags (CONF, CT_NUM, 0, 0, 0);
        interupt_editing (CONF, END, CT_NUM);
        break;
      case CT_ADD :
        interupt_editing (CONF, BEGIN, -1);
        get_tedinfo_text (CONF, CT_NUM, phone[act_phone]);
        for (count = 0; count < phone_num; count++)
             if (phone[count][0] == '\0')
                  break;
        if (count < 8) {
             act_phone = (count == phone_num) ? phone_num++ : count;
             phone[act_phone][0] = '\0';
             set_tedinfo_text (CONF, CT_NUM, phone[act_phone]);
             change_flags (CONF, CT_NUM, 0, 0, 0);
           }
          else
             change_flags (CONF, CT_ADD, 1, 0, DISABLED);
        interupt_editing (CONF, END, CT_NUM);
        break;
      case CT_FEE :
        get_fee_file();
        set_tedinfo_text (CONF, CT_FEE, fee_file);
        change_flags (CONF, CT_FEE, 0, 0, 0);
        break;
      case CN_PREV :
      case CN_NEXT :
      case CN_ADD :
      case CN_UP :
      case CN_DOWN :
      case CN_SLDR :
      case CN_BACK :
        break;
      case CG_PORT :
        if (dial_state != S_NONE)
             form_alert (1, alert);
          else {
             last_shown = act_port + 1;
             pop_up (PU_C_PRT, & act_port, CONF, CG_PORT, 10);
             if (last_shown != act_port) {
                  if (strcmp (ports[--act_port], "Ser.2/LAN") == 0 && has_LAN) {
                       ENABLE (CP_LAN);   ENABLE (CP_LTXT);
                     }
                    else {
                       DISABLE (CP_LAN);   DISABLE (CP_LTXT);   DESELECT (CP_LAN);
                     }
                  strncpy (tree[CG_PORT].ob_spec.free_string, ports[act_port], 10);
                  get_port();
                  reset_config();
                }
               else
                  --act_port;
           }
        break;
      }

   return (0);
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


int  choose_dial_script()

{
   int   button, handle, eof = 1, ret_code = 1;
   long  error;
   char  path[200], file[32], buffer[256], ext[] = "\\*.SCR";
   char  problem[] = "[1][ |   Cannot find/read file !   ][ Cancel ]";

   strncpy (path, script_path, 200);
   path[196] = '\0';

   if (strrchr (path, '\\')) {
        strcpy (strrchr (path, '\\'), ext);
        strncpy (file, strrchr (script_path, '\\') + 1, 32);
        file[31] = '\0';
      }
     else {
        strcat (path, ext);
        file[0] = '\0';
      }

   if (_GemParBlk.global[0] >= 0x0140)
        fsel_exinput (path, file, &button, "Load Dial Script");
     else
        fsel_input (path, file, &button);

   if (button == 0)   return (0);

   strcpy (buffer, path);
   if (strrchr (buffer, '\\'))
        strcpy (strrchr (buffer, '\\') + 1, file);
     else {
        form_alert (1, problem);   return (0);
      }

   if ((error = Fopen (buffer, FO_READ)) < 0) {
        form_alert (1, problem);
        return (0);
      }
   handle = (int) error;
   strcpy (script_path, buffer);

   script_length = 0;   alert_mode = TRUE;

   load_config_part (handle, &eof);
   ret_code = (eof) ? -1 : load_script_part (handle, &eof);

   Fclose (handle);

   return (ret_code);
 }


int  load_dial_script (filename)

char  filename[];

{
   int   handle, eof = 1, ret_code = 1;
   long  error;
   char  buffer[256];

   strcpy (buffer, script_path);
   if (strrchr (buffer, '\\'))
        strcpy (strrchr (buffer, '\\') + 1, filename);
     else
        return (-1);

   if ((error = Fopen (buffer, FO_READ)) < 0)
        return (-1);
   handle = (int) error;
   strcpy (script_path, buffer);

   script_length = 0;   alert_mode = FALSE;

   load_config_part (handle, &eof);
   ret_code = (eof) ? -1 : load_script_part (handle, &eof);

   Fclose (handle);

   return (ret_code);
 }


void  load_config_part (handle, eof)

int  handle, *eof;

{
   int   i_conn = 0, i_redl = 0, i_abrt = 0, count, flag;
   char  buffer[256], *work, port_txt[10];

   dns_num = act_dns = phone_num = act_phone = 0;

   ISP_u_time = ISP_u_sent = ISP_u_recvd = 1L;
   ISP_c_time = ISP_c_sent = ISP_c_recvd = 0L;

   port_flags = 0;

   modem_init[0] = modem_dial[0] = modem_hangup[0] = '\0';
   username[0] = fullname[0] = fqdn[0] = '\0';

   environ_used = (char *) environ_base + 2048;
   environ_number = 0;


   do {
        work = &buffer[0] - 1;
        do {
             *++work = get_char (handle, eof);
          } while (*work != '\r' && *work != '\n' && ! *eof);
        *work = '\0';

        if (buffer[0] == '#' || buffer[0] < ' ') {
             if (! *eof)   continue;
               else   break;
           }
        flag = FALSE;

        if (compare (buffer, & flag, "INIT"))           strncpy (modem_init, buffer, 16);
        if (compare (buffer, & flag, "PREFIX"))         strncpy (modem_dial, buffer, 8);
        if (compare (buffer, & flag, "HANGUP"))         strncpy (modem_hangup, buffer, 8);
        if (compare (buffer, & flag, "CONNECT_WAIT"))   connect_timeout = atoi (buffer);
        if (compare (buffer, & flag, "REDIAL_DELAY"))   redial_delay    = atoi (buffer);

        if (compare (buffer, & flag, "SUCCESS")) {
             if (i_conn < 3)   strncpy (s_conn[i_conn++], buffer, 12);
           }
        if (compare (buffer, & flag, "FAILURE")) {
             if (i_redl < 3)   strncpy (s_redl[i_redl++], buffer, 12);
           }
        if (compare (buffer, & flag, "ABORT")) {
             if (i_abrt < 3)   strncpy (s_abrt[i_abrt++], buffer, 12);
           }

        if (compare (buffer, & flag, "CLIENT_IP"))      load_ip_addr (ip_address, buffer);
        if (compare (buffer, & flag, "MTU"))            port_mtu = atoi (buffer);
        if (compare (buffer, & flag, "PAP_ID"))         strncpy (pap_id, buffer, 30);
        if (compare (buffer, & flag, "PAP_PASSWORD"))   strncpy (pap_passwd, buffer, 30);
        if (compare (buffer, & flag, "PAP_PROMPT"))     papp_flag = read_boolean (buffer);
        if (compare (buffer, & flag, "PROTOCOL"))       protocol  = atoi (buffer);
        if (compare (buffer, & flag, "VJHC"))           port_flags |= (read_boolean (buffer)) ? 2 : 0;
        if (compare (buffer, & flag, "LAN_PORT"))       port_flags |= (read_boolean (buffer)) ? 4 : 0;

        if (compare (buffer, & flag, "USERNAME"))       strncpy (username, buffer, 16);
        if (compare (buffer, & flag, "FULLNAME"))       strncpy (fullname, buffer, 32);
        if (compare (buffer, & flag, "HOSTNAME"))       strncpy (fqdn, buffer, 42);

        if (compare (buffer, & flag, "NAMESERVER"))
             if (dns_num < 4)   load_ip_addr (ip_dns[dns_num++], buffer);
        if (compare (buffer, & flag, "FETCH_DNS"))      port_flags |= (read_boolean (buffer)) ? 8 : 0;

        if (compare (buffer, & flag, "PHONE_NUMBER"))
             if (phone_num < 8)   strncpy (phone[phone_num++], buffer, 16);

        if (compare (buffer, & flag, "FEE_FILE"))       strncpy (fee_file, buffer, 12);
        if (compare (buffer, & flag, "ISP_TIME"))       read_cost (buffer, &ISP_u_time,  &ISP_c_time);
        if (compare (buffer, & flag, "ISP_SENT"))       read_cost (buffer, &ISP_u_sent,  &ISP_c_sent);
        if (compare (buffer, & flag, "ISP_RECVD"))      read_cost (buffer, &ISP_u_recvd, &ISP_c_recvd);

        if (compare (buffer, & flag, "SERIALPORT"))     strncpy (port_txt, buffer, 10);
        if (compare (buffer, & flag, "DEF_ROUTE"))      def_route  = read_boolean (buffer);
        if (compare (buffer, & flag, "MASQUERADE"))     masquerade = read_boolean (buffer);
        if (compare (buffer, & flag, "EXEC_BATCH"))     run_tools  = read_boolean (buffer);
        if (compare (buffer, & flag, "CIX_LOGIN"))      compuserve = read_boolean (buffer);
        if (compare (buffer, & flag, "RESIDENT"))       resident   = read_boolean (buffer);
        if (compare (buffer, & flag, "DEBUGGING"))      debugging  = read_boolean (buffer);

        if (compare (buffer, & flag, "FIND_TIMEOUT"))   script_timeout = atoi (buffer);

        if (compare (buffer, & flag, "DIAL_SCRIPT"))
             break;
        if (flag == FALSE)   read_environment (buffer);
     } while (! *eof);

   protocol = (protocol < 2) ? protocol : 0;
   port_flags |= protocol;

   while (i_conn < 3)   s_conn[i_conn++][0] = '\0';
   while (i_redl < 3)   s_redl[i_redl++][0] = '\0';
   while (i_abrt < 3)   s_abrt[i_abrt++][0] = '\0';

   for (count = 0; count < num_ports; count++)
        if (strcmp (ports[count], port_txt) == 0)
             break;
   act_port = (count == num_ports) ? 0 : count;

   if (resident && _GemParBlk.global[1] == 1)
        resident = FALSE;

   if (masque_there == FALSE)   masquerade = FALSE;
 }


int  load_script_part (handle, eof)

int  handle, *eof;

{
   int   index, check, flag;
   char  alert[] =
         "[1][ |  Dial script : Wrong sequence   | |  of WAIT/REPT/FIND/RESP !][ Oops ]";
   char  buffer[256], *work, *scr_ptr, *script_buffer;

   if ((script_buffer = (char *) Malloc (5120L)) == NULL) {
        form_alert (1, "[1][ |  Cannot allocate enough   | |     memory !][ Hmmm ]");
        return (-1);
      }

   if (! *eof) {
        scr_ptr = script_buffer;
        do {
             work = &buffer[0] - 1;
             do {
                  *++work = get_char (handle, eof);
               } while (*work != '\r' && *work != '\n' && ! *eof);
             *work = '\0';

             if (buffer[0] == '#' || buffer[0] < ' ') {
                  if (! *eof)   continue;
                    else   break;
                }

             *scr_ptr = '\0';
             if (compare (buffer, & flag, "WAIT"))   *scr_ptr = 'W';
             if (compare (buffer, & flag, "REPT"))   *scr_ptr = 'P';
             if (compare (buffer, & flag, "FIND"))   *scr_ptr = 'F';
             if (compare (buffer, & flag, "RESP"))   *scr_ptr = 'R';
             if (*scr_ptr) {
                  strcpy (++scr_ptr, buffer);
                  while (*scr_ptr++);
                }
          } while (! *eof && scr_ptr - script_buffer < 5000);

        *scr_ptr = '\0';
     }

   work = script_buffer;

   for (index = 0; index < MAX_SCRIPT_SIZE && *work; index++) {
        check = 0;
        do {
             if (*work == 'W') {
                  if (check & 1) {
                       if (alert_mode)   form_alert (1, alert);
                       Mfree (script_buffer);
                       return (-1);
                     }
                  check |= 1;   strcpy (script[index][0], work + 1);
                }
             if (*work == 'P') {
                  if (check & 2) {
                       if (alert_mode)   form_alert (1, alert);
                       Mfree (script_buffer);
                       return (-1);
                     }
                  check |= 2;   strcpy (script[index][1], work + 1);
                }
             if (*work == 'F') {
                  if (check & 4) {
                       if (alert_mode)   form_alert (1, alert);
                       Mfree (script_buffer);
                       return (-1);
                     }
                  check |= 4;   strcpy (script[index][2], work + 1);
                }
             if (*work == 'R') {
                  if (check & 8) {
                       if (alert_mode)   form_alert (1, alert);
                       Mfree (script_buffer);
                       return (-1);
                     }
                  check |= 8;   strcpy (script[index][3], work + 1);
                }
             while (*work++);
          } while (check != 15);
      }

   Mfree (script_buffer);

   if (*work != 0 && alert_mode) {
        form_alert (1, "[1][ |  Too many script quadrupels !  ][ Oops ]");
        return (-2);
      }

   script[index][0][0] = script[index][1][0] = script[index][2][0] = 
                         script[index][3][0] = '\0';
   script_length = index;

   return (1);
 }


char  get_char (handle, eof)

int  handle, *eof;

{
   static char  buffer[256];
   static int   level, eof_level;

   if (*eof > 0) {
        *eof = 0;  level = eof_level = 256;
      }

   if (level == eof_level) {
        if (eof_level < 256) {
             --*eof;   return ('\n');
           }
        eof_level = (int) Fread (handle, 256L, buffer);
        if (eof_level <= 0) {
             --*eof;   return ('\n');
           }
        level = 0;
      }

   return (buffer[level++]);
 }


int  compare (buffer, flag, fix_strg)

char  buffer[], fix_strg[];
int   *flag;

{
   char  *b_ptr, *f_ptr, compare_char, alert[100];

   b_ptr = & buffer[0];   f_ptr = & fix_strg[0];

   do {
        compare_char = *b_ptr++;
        if ('a' <= compare_char && compare_char <= 'z')
             compare_char += 'A' - 'a';
        if (compare_char != *f_ptr++)   return (0);
     } while (*f_ptr);

   while (*b_ptr == ' ')   b_ptr++;

   if (*b_ptr) {
        if (*b_ptr == '=') {
             b_ptr++;
             while (*b_ptr == ' ')   b_ptr++;
           }
          else {
             sprintf (alert, alert_form, fix_strg);
             if (alert_mode)
                  form_alert (1, alert);
             return (0);
           }
      }
   strcpy (buffer, b_ptr);

   *flag = TRUE;

   return (1);
 }


long  load_ip_addr (ip, buffer)

unsigned char  ip[];
char           buffer[];

{
   long  ip_1, ip_2, ip_3, ip_4;
   char  *work = buffer;

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

   if (ip_1 >= 0 && ip_1 < 256 && ip_2 >= 0 && ip_2 < 256 && ip_3 >= 0 && ip_3 < 256 &&
                 ip_4 >= 0 && ip_4 < 256) {
        ip[0] = (unsigned char) ip_1;   ip[1] = (unsigned char) ip_2;
        ip[2] = (unsigned char) ip_3;   ip[3] = (unsigned char) ip_4;
      }
     else
        return (0);

   return ((ip_1 << 24) | (ip_2 << 16) | (ip_3 << 8) | ip_4);
 }


void  ted_ip_addr (ip, buffer)

unsigned char  ip[];
char           *buffer;

{
   char  byte[4], temp[15];

   strcpy  (temp, "0  0  0  0  ");
   strncpy (temp, buffer, strlen (buffer));
   buffer = temp;

   byte[3] = '\0';

   byte[0] = *buffer++;   byte[1] = *buffer++;   byte[2] = *buffer++;
   ip[0] = atoi (byte);
   byte[0] = *buffer++;   byte[1] = *buffer++;   byte[2] = *buffer++;
   ip[1] = atoi (byte);
   byte[0] = *buffer++;   byte[1] = *buffer++;   byte[2] = *buffer++;
   ip[2] = atoi (byte);
   byte[0] = *buffer++;   byte[1] = *buffer++;   byte[2] = *buffer++;
   ip[3] = atoi (byte);
 }


int  read_boolean (buffer)

char  buffer[];

{
   if (strcmp (buffer, "TRUE") == 0)
        return (TRUE);

   if (strcmp (buffer, "FALSE") == 0)
        return (FALSE);

   return ((atoi (buffer)) ? TRUE : FALSE);
 }


void  read_cost (buffer, ISP_unit, ISP_cost)

char  buffer[];
long  *ISP_unit, *ISP_cost;

{
   char  *work, *dot;

   *ISP_unit = atol (buffer);

   for (work = buffer; *work; work++)
        if (*work < '0' || *work > '9')   break;

   switch (*work) {
      case 's' :                     break;
      case 'm' :   *ISP_unit *= 60L;   break;
      case 'h' :   *ISP_unit *= 3600L;   break;
      case 'K' :   *ISP_unit *= 1024L;     break;
      case 'M' :   *ISP_unit *= 1048576L;    break;
      default :    --work;
      }
   work++;

   while (*work == ' ' || *work == '\t')
        work++;

   if (*work++ != ',')   return;

   while (*work == ' ' || *work == '\t')
        work++;

   digits = 0;

   if ((dot = strchr (work, '.')) != NULL) {
        dot++;
        while ('0' <= *dot && *dot <= '9') {
             digits++;
             *(dot - 1) = *dot;
             dot++;
           }
        *(dot - 1) = '\0';
      }

   *ISP_cost = atol (work) *
          ((digits == 0) ? 1000 : ((digits == 1) ? 100 : ((digits == 2) ? 10 : 1)));
 }


int  read_environment (buffer)

char  buffer[];

{
   char  name[32], value[64], *work, **array = environ_base;
   int   length, count;

   if (strchr (buffer, '=') == NULL)
        return (FALSE);

   for (work = & buffer[0]; *work == ' '; work++);
   strncpy (name, work, 32);   name[31] = '\0';

   if (strchr (name, '=') == NULL)
        return (FALSE);
   for (work = strchr (name, '=') - 1; *work == ' '; --work);
   work[1] = '\0';
   length = (int) strlen (name);

   for (work = strchr (buffer, '=') + 1; *work == ' '; work++);
   strncpy (value, work, 64);   value[63] = '\0';

   for (work = & value[strlen (value) - 1]; *work == ' '; --work);
   work[1] = '\0';

   for (count = 0; count < length; count++) {
        if ('a' <= name[count] && name[count] <= 'z')
             name[count] += 'A' - 'a';
        if (name[count] != '_' && 'Z' < name[count])
             return (FALSE);
        if (name[count] < '0' || ('9' < name[count] && name[count] < 'A'))
             return (FALSE);
      }

   for (count = 0; count < environ_number; count++) {
        if (strncmp (array[count], name, length) == 0 && array[count][length] == '=')
             return (FALSE);
      }

   if ((char *) & array[environ_number + 1] >= environ_used - (length + strlen (value) + 2))
        return (FALSE);

   work = environ_used - (length + strlen (value) + 2);
   strcpy (work, name);   strcat (work, "=");   strcat (work, value);
   array[environ_number++] = environ_used = work;

   return (TRUE);
 }


void  save_dial_script()

{
   int   button, handle;
   long  error;
   char  path[200], file[32], buffer[256], ext[] = "\\*.SCR";
   char  problem[] = "[1][ |   Cannot write file !   ][ Cancel ]";

   strncpy (path, script_path, 200);
   path[196] = '\0';

   if (strrchr (path, '\\'))
        strcpy (strrchr (path, '\\'), ext);
     else
        strcat (strrchr (path, '\\'), ext);
   file[0] = '\0';

   if (_GemParBlk.global[0] >= 0x0140)
        fsel_exinput (path, file, &button, "Save Dial Script");
     else
        fsel_input (path, file, &button);

   if (button == 0)   return;

   strcpy (buffer, path);
   if (strrchr (buffer, '\\'))
        strcpy (strrchr (buffer, '\\') + 1, file);
     else {
        form_alert (1, problem);   return;
      }

   if ((error = Fcreate (buffer, 0)) < 0) {
        form_alert (1, problem);
        return;
      }
   handle = (int) error;

   save_config_part (handle);
   save_script_part (handle);

   Fclose (handle);
 }


void  save_config_part (handle)

int  handle;

{
   int   count;
   char  text[33], *cost = "%ld, %ld.%03ld", *true = "TRUE", *false = "FALSE";

   Fwrite (handle, 33L, "#\r\n#\r\n#   General Parameters\r\n#\r\n");
   write_text_line (handle, "SERIALPORT", ports[act_port]);
   write_text_line (handle, "DEF_ROUTE",  (def_route)  ? true : false);
   write_text_line (handle, "MASQUERADE", (masquerade) ? true : false);
   write_text_line (handle, "EXEC_BATCH", (run_tools)  ? true : false);
   write_text_line (handle, "CIX_LOGIN",  (compuserve) ? true : false);
   write_text_line (handle, "RESIDENT",   (resident)   ? true : false);
   write_text_line (handle, "DEBUGGING",  (debugging)  ? true : false);
   Fwrite (handle, 3L, "#\r\n");

   Fwrite (handle, 27L, "#\r\n#   Port Parameters\r\n#\r\n");
   sprintf (text, ip_out, (int) ip_address[0], (int) ip_address[1],
              (int) ip_address[2], (int) ip_address[3]);
   write_text_line (handle, "CLIENT_IP",    text);
   write_number_line (handle, "MTU",        port_mtu);
   write_text_line (handle, "PAP_ID",       pap_id);
   write_text_line (handle, "PAP_PASSWORD", pap_passwd);
   write_text_line (handle, "PAP_PROMPT",  (papp_flag) ? true : false);

   write_number_line (handle, "PROTOCOL",   protocol);
   write_text_line (handle, "VJHC",        (port_flags & 2) ? true : false);
   write_text_line (handle, "LAN_PORT",    (port_flags & 4) ? true : false);
   Fwrite (handle, 3L, "#\r\n");

   Fwrite (handle, 22L, "#\r\n#   Addressing\r\n#\r\n");
   write_text_line (handle, "USERNAME",     username);
   write_text_line (handle, "FULLNAME",     fullname);
   write_text_line (handle, "HOSTNAME",     fqdn);
   for (count = 0; count < dns_num; count++) {
        if (ip_dns[count][0] != 0) {
             sprintf (text, ip_out, (int) ip_dns[count][0], (int) ip_dns[count][1],
                        (int) ip_dns[count][2], (int) ip_dns[count][3]);
             write_text_line (handle, "NAMESERVER", text);
           }
      }
   write_text_line (handle, "FETCH_DNS",   (port_flags & 8) ? true : false);
   Fwrite (handle, 3L, "#\r\n");

   Fwrite (handle, 27L, "#\r\n#   Modem Specifics\r\n#\r\n");
   write_text_line (handle, "INIT",   modem_init);
   write_text_line (handle, "PREFIX", modem_dial);
   write_text_line (handle, "HANGUP", modem_hangup);
   write_number_line (handle, "CONNECT_WAIT", connect_timeout);
   write_number_line (handle, "REDIAL_DELAY", redial_delay);
   for (count = 0; count < 3; count++)
        if (s_conn[count][0])
             write_text_line (handle, "SUCCESS",  s_conn[count]);
   for (count = 0; count < 3; count++)
        if (s_redl[count][0])
             write_text_line (handle, "FAILURE",  s_redl[count]);
   for (count = 0; count < 3; count++)
        if (s_abrt[count][0])
             write_text_line (handle, "ABORT",    s_abrt[count]);
   Fwrite (handle, 3L, "#\r\n");

   Fwrite (handle, 21L, "#\r\n#   Telephone\r\n#\r\n");
   for (count = 0; count < phone_num; count++)
        if (phone[count][0])
             write_text_line (handle, "PHONE_NUMBER", phone[count]);
   write_text_line (handle, "FEE_FILE", fee_file);
   sprintf (text, cost,  ISP_u_time,  ISP_c_time / 1000,  ISP_c_time % 1000);
   *(strchr (text, '.') + digits + 1) = '\0';
   write_text_line (handle, "ISP_TIME", text);
   sprintf (text, cost,  ISP_u_sent,  ISP_c_sent / 1000,  ISP_c_sent % 1000);
   *(strchr (text, '.') + digits + 1) = '\0';
   write_text_line (handle, "ISP_SENT", text);
   sprintf (text, cost, ISP_u_recvd, ISP_c_recvd / 1000, ISP_c_recvd % 1000);
   *(strchr (text, '.') + digits + 1) = '\0';
   write_text_line (handle, "ISP_RECVD", text);
   Fwrite (handle, 3L, "#\r\n");

   Fwrite (handle, 31L, "#\r\n#   Network Environment\r\n#\r\n");
   for (count = 0; count < environ_number; count++) {
        text[32] = '\0';
        strncpy (text, environ_base[count], 32);
        if (strchr (text, '='))
             * strchr (text, '=') = '\0';
        write_text_line (handle, text, strchr (environ_base[count], '=') + 1);
      }
   Fwrite (handle, 3L, "#\r\n");

   Fwrite (handle, 23L, "#\r\n#   Dial Script\r\n#\r\n");
   write_number_line (handle, "FIND_TIMEOUT", script_timeout);
   Fwrite (handle, 3L, "#\r\n");
 }


void  save_script_part (handle)

int  handle;

{
   int  count;

   Fwrite (handle, 16L, "DIAL_SCRIPT\r\n#\r\n");

   for (count = 0; count < script_length; count++) {
        write_text_line (handle, "WAIT", script[count][0]);
        write_text_line (handle, "REPT", script[count][1]);
        write_text_line (handle, "FIND", script[count][2]);
        write_text_line (handle, "RESP", script[count][3]);
        Fwrite (handle, 3L, "#\r\n");
      }
 }


void  write_text_line (handle, desc, text)

int   handle;
char  desc[], text[];

{
   char  buffer[128];

   sprintf (buffer, "%-15s = %s\r\n", desc, text);
   Fwrite (handle, strlen (buffer), buffer);
 }


void  write_number_line (handle, desc, number)

int   handle, number;
char  desc[];

{
   char  buffer[128];

   sprintf (buffer, "%-15s = %d\r\n", desc, number);
   Fwrite (handle, strlen (buffer), buffer);
 }


void  set_tedinfo_text (rsc_tree, object, text)

int   rsc_tree, object;
char  text[];

{
   change_tedinfo (rsc_tree, object, -1, TE_PTEXT, text, -1);
 }


void  get_tedinfo_text (rsc_tree, object, text)

int   rsc_tree, object;
char  text[];

{
   OBJECT   *tree;
   TEDINFO  *ted;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   ted = tree[object].ob_spec.tedinfo;
   strncpy (text, ted->te_ptext, ted->te_txtlen - 1);
 }


void  set_tedinfo_number (rsc_tree, object, number)

int   rsc_tree, object, number;

{
   char     temp[32];

   sprintf (temp, "%-d", number);
   change_tedinfo (rsc_tree, object, -1, TE_PTEXT, temp, -1);
 }


void  get_tedinfo_number (rsc_tree, object, number)

int   rsc_tree, object, *number;

{
   OBJECT   *tree;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   *number = atoi (TEDTEXT (object));
 }


void  get_fee_file()

{
   int   button;
   char  path[200], check[200], file[32], ext[] = "\\*.FEE";
   char  path_prob[] = "[1][ |  Fee File can only be found in"
                        "  | |  script directory !][ Proceed | Cancel ]";
   char  len_prob[]  = "[1][ |  Fee File name length must not"
                        "  | |  exceed 12 characters !][ Cancel ]";

   strncpy (path, script_path, 200);
   if (strrchr (path, '\\'))   strcpy (strrchr (path, '\\'), ext);
     else   strcat (strrchr (path, '\\'), ext);
   strcpy (file, fee_file);

   fsel_exinput (path, file, &button, "Search Fee File");

   if (button == 0)   return;

   strncpy (check, script_path, 200);
   if (strrchr (check, '\\'))   *strrchr (check, '\\') = '\0';
   if (strrchr ( path, '\\'))   *strrchr ( path, '\\') = '\0';

   if (strcmp (path, check)) {
        if (form_alert (1, path_prob) == 2)   return;
      }
   if (strlen (file) > 12) {
        form_alert (1, len_prob);   return;
      }

   strncpy (fee_file, file, 12);
 }
