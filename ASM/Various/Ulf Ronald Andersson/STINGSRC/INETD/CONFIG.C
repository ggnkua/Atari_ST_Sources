

#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ind.h"
#include "window.h"
#include "module.h"

#define  FALSE             0
#define  TRUE              1
#define  CNTRL_Q           0x1011

#define  TEDTEXT(a)        (tree[(a)].ob_spec.tedinfo->te_ptext)

#define  SELECT(a)         (tree[(a)].ob_state |= SELECTED)
#define  DESELECT(a)       (tree[(a)].ob_state &= ~SELECTED)
#define  ENABLE(a)         (tree[(a)].ob_state &= ~DISABLED)
#define  DISABLE(a)        (tree[(a)].ob_state |= DISABLED)


typedef  struct standard_service {
           int   port, protocol;
           char  *short_desc, *long_desc;
    } SERVICES;

typedef  struct setup {
           int   port, server;
           struct {
               unsigned  reserved  :  13;
               unsigned  tcp       :  1;
               unsigned  open      :  1;
               unsigned  multiple  :  1;
           } flags;
    } MOD_SETUP;


void  init_configs (void),  read_services (void);
void  parse_tree (OBJECT *tree, int object, int mode);
void  fill_in_config_box (void),  read_out_config_box (void);
void  set_standard_info (void);
void  set_tedinfo_text (int tree, int obj, char text[]);
void  get_tedinfo_text (int tree, int obj, char text[]);
void  set_tedinfo_number (int tree, int obj, int number);
void  get_tedinfo_number (int tree, int obj, int *number);
int   cdecl conf_click (int object),  cdecl conf_typed (int scancode);


extern ISM_INTERN  *ism_data;
extern int         num_modules;
extern char        inetd_path[];

SERVICES  standard[100];
int       num_services, tcp_entry[25], udp_entry[25];
char      *strings;

int   conf_shown = 0;
int   conf_box[] = {  CI_BOX,  CE_BOX, CM_BOX  };
int   edit[]     = { CIC_LEN, CE_PORT, CM_RATE };

int        chargen_len = 80, chargen_random = TRUE;

MOD_SETUP  setup[100];
int        num_setup_entries = 1, which_setup = 0;

int        poll_rate = 10;



void  init_configs()

{
   OBJECT  *tree, *popup;
   int     count, walk;

   rsrc_gaddr (R_TREE, CONF, &tree);

   parse_tree (tree, ROOT, -1);

   tree[CE_BOX].ob_x = tree[CI_BOX].ob_x,  tree[CE_BOX].ob_y = tree[CI_BOX].ob_y;
   tree[CE_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CE_BOX, 0);

   tree[CM_BOX].ob_x = tree[CI_BOX].ob_x,  tree[CM_BOX].ob_y = tree[CI_BOX].ob_y;
   tree[CM_BOX].ob_flags |= HIDETREE;   parse_tree (tree, CM_BOX, 0);

   rsrc_gaddr (R_TREE, PU_C_TYP, &popup);
   strcpy (tree[CC_M_NAM].ob_spec.free_string, popup[1].ob_spec.free_string + 2);

   rsrc_gaddr (R_TREE, PU_C_TCP, &popup);
   for (count = 0, walk = 3; count < num_modules && walk < 25; count++) {
        if (ism_data[count].protocol & ISM_TCP) {
             tcp_entry[walk] = count;
             strncpy (popup[walk++].ob_spec.free_string + 2, ism_data[count].ism_name, 16);
           }
      }
   popup->ob_height = (walk - 1) * popup[1].ob_height;
   while (walk < 25)
        popup[walk++].ob_flags |= HIDETREE;

   rsrc_gaddr (R_TREE, PU_C_UDP, &popup);
   for (count = 0, walk = 3; count < num_modules && walk < 25; count++) {
        if (ism_data[count].protocol & ISM_UDP) {
             udp_entry[walk] = count;
             strncpy (popup[walk++].ob_spec.free_string + 2, ism_data[count].ism_name, 16);
           }
      }
   popup->ob_height = (walk - 1) * popup[1].ob_height;
   while (walk < 25)
        popup[walk++].ob_flags |= HIDETREE;

   setup[0].flags.tcp      = TRUE;    setup[0].port   = 7;
   setup[0].flags.open     = FALSE;   setup[0].server = 1;
   setup[0].flags.multiple = FALSE;

   read_services();
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


void  read_services()

{
   int   handle, v_len;
   long  length;
   char  *work, *w_pos, *shrt_v, *lng_v;

   num_services = 0;
   strings = NULL;

   work = &inetd_path[strlen (inetd_path)];
   strcpy (work, "\\IND.SRV");

   if ((handle = (int) Fopen (inetd_path, 0)) < 0) {
        *work = '\0';
        return;
      }
   *work = '\0';

   length = Fseek (0, handle, 2);
   Fseek (0, handle, 0);

   if ((strings = (char *) Malloc (length)) == NULL) {
        Fclose (handle);
        return;
      }

   Fread (handle, length, strings);
   Fclose (handle);

   w_pos = work = strings;

   do {
        if (('a' <= *work && *work <= 'z') || ('A' <= *work && *work <= 'Z')) {
             shrt_v = work;
             while (' ' < *work && *work < 0x7f)
                  work++;
             *work++ = '\0';
             while (*work == ' ')
                  work++;
             standard[num_services].port = atoi (work);
             while (*work != '/' && (long) (work - strings) < length)
                  work++;
             ++work;
             if (*work == 't' || *work == 'T')
                  standard[num_services].protocol = ISM_TCP;
               else {
                  if (*work == 'u' || *work == 'U')
                       standard[num_services].protocol = ISM_UDP;
                    else
                       return;
                }
             while (*work != '#' && (long) (work - strings) < length)
                  work++;
             work++;
             while (*work == ' ')
                  work++;
             lng_v = work;
             while (' ' <= *work && *work < 0x7f)
                  work++;
             *work = '\0';
             memcpy (w_pos, shrt_v, v_len = (int) strlen (shrt_v) + 1);
             standard[num_services].short_desc = w_pos;
             w_pos += v_len;
             memcpy (w_pos, lng_v, v_len = (int) strlen (lng_v) + 1);
             standard[num_services].long_desc = w_pos;
             w_pos += v_len;
             if (++num_services == 100)
                  return;
           }
        while (*work != '\r' && *work != '\n' && (long) (work - strings) < length)
             work++;
        while (*work == '\r' || *work == '\n')
             work++;
     } while ((long) (work - strings) < length);

   if (num_services == 0 || w_pos == strings) {
        Mfree (strings);
        strings = NULL;
      }
     else
        Mshrink (0, strings, (long) (w_pos - strings));
 }


void  fill_in_config_box()

{
   OBJECT  *tree, *popup;
   char    temp[12];

   rsrc_gaddr (R_TREE, CONF, &tree);

   set_tedinfo_number (CONF, CIC_LEN, chargen_len);
   DESELECT (CIC_ALPH);   DESELECT (CIC_RNDM);
   SELECT ((chargen_random) ? CIC_RNDM : CIC_ALPH);

   if (num_setup_entries == 1)   DISABLE (CE_DEL);
     else   ENABLE (CE_DEL);
   if (num_setup_entries == 99)   DISABLE (CE_INS);
     else   ENABLE (CE_INS);
   sprintf (temp, "%2d", which_setup);
   strncpy (&tree[CE_NO].ob_spec.free_string[7], temp, 2);
   set_tedinfo_number (CONF, CE_PORT, setup[which_setup].port);
   DESELECT (CE_TCP);   DESELECT (CE_UDP);
   SELECT ((setup[which_setup].flags.tcp) ? CE_TCP : CE_UDP);
   set_standard_info();
   rsrc_gaddr (R_TREE, (setup[which_setup].flags.tcp) ? PU_C_TCP : PU_C_UDP, &popup);
   strcpy (tree[CE_SERV].ob_spec.free_string,
                         popup[setup[which_setup].server].ob_spec.free_string + 2);
   if (setup[which_setup].flags.open)   SELECT (CE_OPEN);
     else   DESELECT (CE_OPEN);
   if (setup[which_setup].flags.multiple)   SELECT (CE_MULTI);
     else   DESELECT (CE_MULTI);

   set_tedinfo_number (CONF, CM_RATE, poll_rate);
 }


void  read_out_config_box()

{
 }


void  set_standard_info()

{
   OBJECT  *tree;
   int     count, port, protocol;
   char    space_str[] = "                                        ";

   rsrc_gaddr (R_TREE, CONF, &tree);

   port     = atoi (TEDTEXT(CE_PORT));
   protocol = (tree[CE_TCP].ob_state & SELECTED) ? ISM_TCP : ISM_UDP;

   strncpy (tree[CE_SS_A].ob_spec.free_string, space_str, 12);
   strncpy (tree[CE_SS_B].ob_spec.free_string, space_str, 36);

   for (count = 0; count < num_services; count++)
        if (standard[count].port == port && standard[count].protocol == protocol) {
             strncpy (tree[CE_SS_A].ob_spec.free_string, standard[count].short_desc, 12);
             strncpy (tree[CE_SS_B].ob_spec.free_string, standard[count].long_desc, 36);
           }
 }


void  set_tedinfo_text (rsc_tree, object, text)

int   rsc_tree, object;
char  text[];

{
   OBJECT   *tree;
   TEDINFO  *ted;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   ted = tree[object].ob_spec.tedinfo;
   strncpy (ted->te_ptext, text, ted->te_txtlen - 1);
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
   OBJECT   *tree;
   TEDINFO  *ted;
   char     temp[32];

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   ted = tree[object].ob_spec.tedinfo;
   sprintf (temp, "%-d", number);
   strncpy (ted->te_ptext, temp, ted->te_txtlen - 1);
 }


void  get_tedinfo_number (rsc_tree, object, number)

int   rsc_tree, object, *number;

{
   OBJECT   *tree;

   rsrc_gaddr (R_TREE, rsc_tree, &tree);
   *number = atoi (TEDTEXT (object));
 }


int cdecl  conf_click (object)

int  object;

{
   OBJECT  *tree;
   int     last_shown;

   object &= 0x7fff;

   evnt_timer (60, 0);
   change_flags (CONF, object, 0, 0, SELECTED);

   rsrc_gaddr (R_TREE, CONF, &tree);

   switch (object) {
      case CC_SAVE :
        break;
      case CC_SET :
        break;
      case CC_M_NAM :
        last_shown = conf_shown++;
        pop_up (PU_C_TYP, &conf_shown, CONF, CC_M_NAM, 16);
        if (last_shown != --conf_shown) {
             interupt_editing (CONF, BEGIN, -1);
             parse_tree (tree, conf_box[last_shown], 0);
             tree[conf_box[last_shown]].ob_flags |= HIDETREE;
             parse_tree (tree, conf_box[conf_shown], 1);
             change_flags (CONF, conf_box[conf_shown], 0, HIDETREE, 0);
             interupt_editing (CONF, END, edit[conf_shown]);
           }
        break;
      case CE_UP :
      case CE_DWN :
        break;
      case CE_INS :
        break;
      case CE_DEL :
        break;
      case CE_SERV :
/*        pop_up (PU_C_TCP, &act_port, CONF, CS_PORT, 10);*/
        break;
      }

   return (0);
 }


int cdecl  conf_typed (scan)

int  scan;

{
   return ((scan == CNTRL_Q) ? -1 : 1);
 }
