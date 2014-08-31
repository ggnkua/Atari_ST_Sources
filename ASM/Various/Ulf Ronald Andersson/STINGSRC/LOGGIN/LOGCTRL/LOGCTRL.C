
/*********************************************************************/
/*                                                                   */
/*     LogSTinG : Control Program                                    */
/*                                                                   */
/*      Version 1.2                         from 17. March 1997      */
/*                                                                   */
/*********************************************************************/


#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>

#include "ctrl.h"

#include "transprt.h"


#define  FALSE       0
#define  TRUE        1

#define  CLI_NUM     37
#define  MOD_NUM     20

#define  CROS_CHK    (CROSSED | CHECKED)
#define  SWAP(a,b)   (zwsp = (a), (a) = (b), (b) = zwsp)


typedef struct logstruc {
     char  *version;
     int   cli_num, mod_num;
     char  *generic;
     char  *client_itf, *module_itf;
     char  *path;
 } LOG_IT;


void        gem_prgm (void);
int         init_data (void);
void        do_settings (void);
void        modify_fname (void);
void        create_path (void);
void        do_dialog (int api);
int         get_cookie (long which, long *value);
long        read_cookie (void);
int  cdecl  my_button_handler (PARMBLK *parameter);


extern GEMPARBLK  _GemParBlk;

DRV_LIST  *sting_drivers;
LOG_IT    *log_this;
USERBLK   my_user_block = {  my_button_handler,  0  };
MFDB      screen = { NULL, 0, 0, 0, 0, 1, 0, 0, 0 };
MFDB      box    = { NULL, 0, 0, 0, 0, 1, 0, 0, 0 };
int       vdi_handle, ck_flag, planes;
long      cookie;

int   cli_array[] = { C_KMALL,  C_KFREE,  C_KGETFR, C_KREALL, C_ERRTXT, C_GTVSTR, C_CARDET, 
                      C_TOPEN,  C_TCLOSE, C_TSEND,  C_TSTATE, C_TACK,   C_UOPEN,  C_UCLOSE, 
                      C_USEND,  C_CKICK,  C_CBCNT,  C_CGCHAR, C_CGNDB,  C_CGBLK,  C_HSKEEP, 
                      C_RSLV,   C_SERDIS, C_SEREN,  C_SETFLG, C_CLRFLG, C_CGINFO, C_ONPRT, 
                      C_OFFPRT, C_STVSTR, C_QUPRT,  C_CGS,    C_ISEND,  C_IHNDLR, C_IDSCRD,
                      C_TINFO,  C_CTLPRT
            };
int   mod_array[] = { M_SETTTL, M_CHKTTL, M_LDROUT, M_SETSYS, M_QUCHNS, M_IPSEND, M_IPFTCH, 
                      M_IPHAND, M_IPDISC, M_PANNOU, M_PGTPAR, M_PREQU,  M_PRELEA, M_PLOOK,
                      M_TCALL,  M_TNOW,   M_TELAPS, M_EXEC,   M_GTROUT, M_STROUT
            };
int   cli_num = CLI_NUM, mod_num = MOD_NUM;
char  cli_set[CLI_NUM], mod_set[MOD_NUM], path[256];



void  main()

{
   OBJECT  *tree;
   int     tree_cnt, count;

   appl_init();

   graf_mouse (ARROW, NULL);

   if (rsrc_load ("CTRL.RSC") == 0) {
        form_alert (1, "[1][ |  Couldn't locate CTRL.RSC !  ][ Ooops ]");
        appl_exit();
        return;
      }

   for (tree_cnt = 0; tree_cnt < 3; tree_cnt++) {
        rsrc_gaddr (R_TREE, tree_cnt, & tree);
        do {
             if (tree->ob_type & 0x7f00)
                  if ((tree->ob_state & CROS_CHK) == CROS_CHK) {
                       tree->ob_type = G_USERDEF;
                       tree->ob_spec.userblk = &my_user_block;
                       tree->ob_state &= ~ CROS_CHK;
                     }
          } while ((tree++->ob_flags & LASTOB) == 0);
      }

   if (init_data() == 0) {
        rsrc_free();
        appl_exit();
        return;
      }

   wind_update (BEG_UPDATE);

   gem_prgm();

   wind_update (END_UPDATE);

   rsrc_free();
   appl_exit();
 }


void  gem_prgm()

{
   OBJECT  *tree;
   int     box_x, box_y, box_w, box_h, button, end = FALSE;
   int     work_in[11], work_out[57], count, dummy;

   for (count = 0; count < 10; count++)   work_in[count] = 1;
   work_in[10] = 2;
   vdi_handle = graf_handle (& dummy, & dummy, & dummy, & dummy);
   v_opnvwk (work_in, & vdi_handle, work_out);
   vq_extnd (vdi_handle, 1, work_out);
   planes = work_out[4];

   rsrc_gaddr (R_TREE, LOGCTRL, & tree);
   form_center (tree, & box_x, & box_y, & box_w, & box_h);
   form_dial (FMD_START, 0,0,0,0, box_x, box_y, box_w, box_h);
   objc_draw (tree, ROOT, MAX_DEPTH, box_x, box_y, box_w, box_h);

   do {
        button = form_do (tree, 0) & 0x7fffu;
        evnt_timer (60, 0);
        tree[button].ob_state &= ~SELECTED;
        objc_draw (tree, button, 1, box_x, box_y, box_w, box_h);

        switch (button) {
           case FILENAM :
             modify_fname();
             objc_draw (tree, ROOT, MAX_DEPTH, box_x, box_y, box_w, box_h);
             break;
           case CLIENT :
           case MODULE :
             form_dial (FMD_FINISH, 0,0,0,0, box_x, box_y, box_w, box_h);
             do_dialog ((button == CLIENT) ? CLI_API : MOD_API);
             form_dial (FMD_START, 0,0,0,0, box_x, box_y, box_w, box_h);
             objc_draw (tree, ROOT, MAX_DEPTH, box_x, box_y, box_w, box_h);
             break;
           case TERM :
             if (form_alert (1, "[2][ |  Remove LogSTinG and   |   leave LogCTRL ?][ Yes | No ]") == 1) {
                  if ((long) (*sting_drivers->get_dftab) ("LOGSTING : REMOVE") == 'OkOk')
                       end = TRUE;
                    else
                       form_alert (1, "[1][ |  Could not remove LogSTinG !  ][ Hmmm ]");
                }
             break;
           case FIX :
             if (form_alert (1, "[2][ |  Activate new settings ?   ][ Yes | No ]") == 1)
                  do_settings();
             break;
           case CANCEL :
             if (form_alert (1, "[2][ |  Leave LogCTRL ?   ][ Yes | No ]") == 1)
                  end = TRUE;
             break;
           }
     } while (! end);

   form_dial (FMD_FINISH, 0,0,0,0, box_x, box_y, box_w, box_h);
   v_clsvwk (vdi_handle);
 }


int  init_data()

{
   OBJECT  *tree;
   long    value;

   if (! get_cookie ('STiK', (long *) & sting_drivers)) {
        form_alert (1, "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]");
        return (0);
      }
   if (sting_drivers == 0L) {
        form_alert (1, "[1][ |  STinG is not loaded or enabled !   ][ Hmmm ]");
        return (0);
      }

   if (strcmp (sting_drivers->magic, MAGIC) != 0) {
        form_alert (1, "[1][ |  STinG structures corrupted !   ][ Fuck ]");
        return (0);
      }

   log_this = (LOG_IT *) (*sting_drivers->get_dftab) ("LOGSTING : QUERY");

   if (log_this == NULL) {
        form_alert (1, "[1][ |  LogSTinG is not installed !   ][ Ooops ]");
        return (0);
      }

   rsrc_gaddr (R_TREE, LOGCTRL, & tree);
   strncpy (& tree[VERSION].ob_spec.free_string[1], log_this->version, 3);

   tree[ACTIVE  ].ob_state = (log_this->generic[0]) ? SELECTED : NORMAL;
   tree[PARAS   ].ob_state = (log_this->generic[1]) ? SELECTED : NORMAL;
   tree[POINTER ].ob_state = (log_this->generic[2]) ? SELECTED : NORMAL;
   tree[BUFFER  ].ob_state = (log_this->generic[3]) ? SELECTED : NORMAL;
   tree[INTERNAL].ob_state = (log_this->generic[4]) ? SELECTED : NORMAL;
   tree[CACHE   ].ob_state = (log_this->generic[5]) ? SELECTED : NORMAL;
   tree[FILE    ].ob_state = (log_this->generic[6]) ? NORMAL : SELECTED;
   tree[PIPE    ].ob_state = (log_this->generic[6]) ? SELECTED : NORMAL;

   strcpy (path, log_this->path);
   create_path();

   if (cli_num > log_this->cli_num)   cli_num = log_this->cli_num;
   if (mod_num > log_this->mod_num)   mod_num = log_this->mod_num;

   memcpy (cli_set, log_this->client_itf, cli_num);
   memcpy (mod_set, log_this->module_itf, mod_num);

   if (get_cookie ('MagX', & value)) {
        if ((value = * (long *) (value + 8) + 12 * sizeof (long)) > 100) {
             if (* (int *) value >= 0x300)
                  return (1);
           }
      }

   if (get_cookie ('MiNT', & value)) {
        if (value >= 0x100)
             return (1);
      }

   tree[PIPE].ob_state &= ~SELECTED;
   tree[PIPE].ob_state |= DISABLED;
   tree[PIPENAM].ob_state |= DISABLED;
   tree[FILE].ob_state |= SELECTED;

   return (1);
 }


void  do_settings()

{
   OBJECT  *tree;

   rsrc_gaddr (R_TREE, LOGCTRL, & tree);

   log_this->generic[0] = (tree[ACTIVE  ].ob_state & SELECTED) ? TRUE : FALSE;
   log_this->generic[1] = (tree[PARAS   ].ob_state & SELECTED) ? TRUE : FALSE;
   log_this->generic[2] = (tree[POINTER ].ob_state & SELECTED) ? TRUE : FALSE;
   log_this->generic[3] = (tree[BUFFER  ].ob_state & SELECTED) ? TRUE : FALSE;
   log_this->generic[4] = (tree[INTERNAL].ob_state & SELECTED) ? TRUE : FALSE;
   log_this->generic[5] = (tree[CACHE   ].ob_state & SELECTED) ? TRUE : FALSE;
   log_this->generic[6] = (tree[PIPE    ].ob_state & SELECTED) ? TRUE : FALSE;

   strcpy (log_this->path, path);

   memcpy (log_this->client_itf, cli_set, cli_num);
   memcpy (log_this->module_itf, mod_set, mod_num);
 }


void  modify_fname()

{
   int   button;
   char  f_path[200], f_file[32], ext[] = "\\*.*";

   strncpy (f_path, path, 200);
   f_path[196] = '\0';

   if (strrchr (f_path, '\\')) {
        strcpy (strrchr (f_path, '\\'), ext);
        strncpy (f_file, strrchr (path, '\\') + 1, 32);
        f_file[31] = '\0';
      }
     else {
        strcat (strrchr (path, '\\'), ext);
        f_file[0] = '\0';
      }

   if (_GemParBlk.global[0] >= 0x0140)
        fsel_exinput (f_path, f_file, & button, "Choose Log File");
     else
        fsel_input (f_path, f_file, &button);

   if (button == 0)   return;

   strncpy (path, f_path, 250);

   if (strrchr (path, '\\'))
        strncpy (strrchr (path, '\\') + 1, f_file, 32);
     else
        strcat (strrchr (path, '\\'), f_file);

   create_path();
 }


void  create_path()

{
   OBJECT  *tree;
   char    *edit, *work;
   int     remain;

   rsrc_gaddr (R_TREE, LOGCTRL, & tree);

   if (strlen (path) <= 30) {
        strcpy (tree[FILENAM].ob_spec.tedinfo->te_ptext, path);
      }
     else {
        edit = tree[FILENAM].ob_spec.tedinfo->te_ptext;
        remain = 27;
        if (path[1] == ':' && path[2] == '\\') {
             remain -= 3;
             *edit++ = path[0];   *edit++ = path[1];   *edit++ = path[2];
           }
        strcpy (edit, "...");   edit += 3;
        work = & path[strlen(path) - remain];
        if (strchr (work, '\\'))
             strcpy (edit, strchr (work, '\\'));
          else
             strcpy (edit, work);
      }
 }


void  do_dialog (api)

int  api;

{
   OBJECT  *tree;
   int     box_x, box_y, box_w, box_h, button, zwsp, xy[8];
   int     b_all, b_none, b_ok, b_canc, count, number, *array;
   char    *dest;

   if (api == CLI_API) {
        b_all = C_ALL;  b_none = C_NONE;  b_ok = C_OK;  b_canc = C_CANCEL;
        number = cli_num;   array = cli_array;   dest = cli_set;
      }
     else {
        b_all = M_ALL;  b_none = M_NONE;  b_ok = M_OK;  b_canc = M_CANCEL;
        number = mod_num;   array = mod_array;   dest = mod_set;
      }

   rsrc_gaddr (R_TREE, api, & tree);
   form_center (tree, & box_x, & box_y, & box_w, & box_h);

   for (count = 0; count < number; count++)
        tree[array[count]].ob_state = (dest[count]) ? SELECTED : NORMAL;

   box.fd_w = box_w;   box.fd_h = box_h;
   box.fd_nplanes = planes;   box.fd_wdwidth = (box_w + 15) / 16;
   box.fd_addr = Malloc (planes * (box_h * (box_w + 15L) / 8));

   xy[0] = box_x;   xy[2] = box_x + box_w - 1;
   xy[1] = box_y;   xy[3] = box_y + box_h - 1;
   xy[4] = xy[5] = 0;   xy[6] = box_w - 1;   xy[7] = box_h - 1;

   if (box.fd_addr) {
        graf_mouse (M_OFF, NULL);
        vro_cpyfm (vdi_handle, S_ONLY, xy, & screen, & box);
        graf_mouse (M_ON, NULL);
      }
     else
        form_dial (FMD_START, 0,0,0,0, box_x, box_y, box_w, box_h);

   objc_draw (tree, ROOT, MAX_DEPTH, box_x, box_y, box_w, box_h);

   for (;;) {
        button = form_do (tree, 0) & 0x7fffu;
        evnt_timer (60, 0);
        tree[button].ob_state &= ~SELECTED;
        objc_draw (tree, button, 1, box_x, box_y, box_w, box_h);

        if (button == b_all || button == b_none) {
             for (count = 0; count < number; count++) {
                  tree[array[count]].ob_state = (button == b_all) ? SELECTED : NORMAL;
                  objc_draw (tree, array[count], 1, box_x, box_y, box_w, box_h);
                }
           }

        if (button == b_ok) {
             for (count = 0; count < number; count++)
                  dest[count] = (tree[array[count]].ob_state & SELECTED) ? TRUE : FALSE;
             break;
           }

        if (button == b_canc)
             break;
      }

   SWAP (xy[0], xy[4]);   SWAP (xy[1], xy[5]);
   SWAP (xy[2], xy[6]);   SWAP (xy[3], xy[7]);

   if (box.fd_addr) {
        graf_mouse (M_OFF, NULL);
        vro_cpyfm (vdi_handle, S_ONLY, xy, & box, & screen);
        graf_mouse (M_ON, NULL);   Mfree (box.fd_addr);
      }
     else
        form_dial (FMD_FINISH, 0,0,0,0, box_x, box_y, box_w, box_h);
 }


int  get_cookie (which, value)

long  which, *value;

{
   cookie = which;
   *value = Supexec (read_cookie);

   return (ck_flag);
 }


long  read_cookie()

{
   long  *work;

   ck_flag = FALSE;

   if (* (long **) 0x5a0L == NULL)
        return (0L);

   for (work = * (long **) 0x5a0L; *work != 0L; work += 2)
        if (*work == cookie) {
             ck_flag = TRUE;   return (*++work);
           }

   return (-1L);
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
