/*************************/
/* BOOTCONF              */
/* zur Konfiguration des */
/* Non Volatile Memory   */
/* von Falcon030 und TT  */
/* (c)1993 MAXON-Coputer */
/* Autor: Uwe Seimet     */
/*************************/

#define NUM_OBS 60

#define EXTERN extern

#include "bootconf.rsh"
#include <tos.h>
#include <vdi.h>
#include <stdio.h>

#define _MCH 0x5f4d4348l

/* Flags fÅr Falcon-Videomodi */

#define VERTFLAG 0x100
#define STMODES  0x80
#define OVERSCAN 0x40
#define PAL      0x20
#define VGA      0x10
#define TV       0x0

#define COL80    0x08
#define COL40    0x04

#define BPS16    4
#define BPS8     3
#define BPS4     2
#define BPS2     1
#define BPS1     0

/* LÑndercodes */

#define USA 0
#define FRG 1
#define FRA 2
#define UK  3
#define SPA 4
#define ITA 5
#define SWF 7
#define SWG 8

#define TRUE 1
#define FALSE 0

typedef enum _bool boolean;

#define NVMaccess(op,start,count,buffer) xbios(46,op,start,count,buffer)

int contrl[11],
    intin[80],
    intout[45],
    ptsin[32],
    ptsout[32];

int work_in[12],
    work_out[57];

int g_handle;

int gl_hchar,
    gl_wchar;

struct {
  int bootpref;
  char reserved1[4];
  char language;
  char keyboard;
  char datetime;
  char seperator;
  char reserved2[5];
  char vmode;
} nvm;

/* FÅr Umrechnung von LÑndercode in Sprache */

char code_to_lang[] =
  { LANG_GB, LANG_D, LANG_F,
    LANG_GB, LANG_ESP, LANG_I,
    LANG_GB, LANG_F, LANG_D,
    LANG_GB, LANG_GB, LANG_GB,
    LANG_GB, LANG_GB, LANG_GB };

char lang_to_code [] =
  { USA, FRG, FRA, SPA, ITA };

/* FÅr Umrechnung von LÑndercode in Tastaturlayout */

char code_to_key[] =
  { KEY_GB, KEY_D, KEY_F,
    KEY_GB, KEY_ESP, KEY_I,
    KEY_GB, KEY_CHF, KEY_CHD,
    KEY_GB, KEY_GB, KEY_GB,
    KEY_GB, KEY_GB, KEY_GB };

char key_to_code[] =
  { UK, FRG, FRA, SPA, ITA, USA, SWF, SWG };

/* Funktions-Prototypen */

boolean open_vwork(void);
boolean get_nvm(void);
void set_nvm(void);
boolean do_dialog(void);
boolean tst_mch(void);
void rsrc_init(void);

int main()
{
  if ((appl_init())!=-1) {
    if (open_vwork()) {
      if (tst_mch()) {
        if (get_nvm()) {
          rsrc_init();
          if (do_dialog()) set_nvm();
          v_clsvwk(g_handle);
        }
      }
    }
  }
  appl_exit();
  return(0);
}

/* Workstation îffnen */

boolean open_vwork()
{
  int gl_wbox,gl_hbox;

  register int i;

  for(i=1; i<10; work_in[i++]=0);
  work_in[10]=2;
  g_handle=graf_handle(&gl_wchar,&gl_hchar,
                       &gl_wbox,&gl_hbox);
  work_in[0]=g_handle;
  v_opnvwk(work_in,&g_handle,work_out);
  if (!g_handle) return(FALSE);
  return(TRUE);
}

/* Dialog fÅhren */

boolean do_dialog()
{
  int fo_cx,fo_cy,fo_cw,fo_ch;
  int exit;

  form_center(rs_trindex[DIALOG], &fo_cx, &fo_cy,
              &fo_cw, &fo_ch);
  form_dial(FMD_START, fo_cx, fo_cy, fo_cw, fo_ch,
            fo_cx, fo_cy, fo_cw, fo_ch);
  objc_draw(rs_trindex[DIALOG], 0, 2, fo_cx, fo_cy,
            fo_cw, fo_ch);
  graf_mouse(ARROW, NULL);
  exit=form_do(rs_trindex[DIALOG], 0);
  form_dial(FMD_FINISH, fo_cx, fo_cy, fo_cw, fo_ch,
            fo_cx, fo_cy, fo_cw, fo_ch);
  return(exit!=ABORT);
}

/* NVM auslesen */

boolean get_nvm()
{
  char *te_ptext;
  int index;

  NVMaccess(0, 0, (int)(sizeof(nvm)), &nvm);

/* Videomodus auswerten */

  index = (nvm.vmode & 0x07) + COLOURS;
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  if (nvm.vmode & COL80) index = COLS80;
  else index = COLS40;
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  if (nvm.vmode & PAL) index = PALMODE;
  else index = NTSCMODE;
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  if (nvm.vmode & VGA) index = VGAMODE;
  else index = TVMODE;
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  if (nvm.vmode & VERTFLAG)
    rs_trindex[DIALOG][INTRLACE].ob_state |= SELECTED;  

  if (nvm.vmode & OVERSCAN)
    rs_trindex[DIALOG][OVRSCAN].ob_state |= SELECTED; 

  if (nvm.vmode & STMODES)
    rs_trindex[DIALOG][STMODE].ob_state |= SELECTED;  

/* Sprache auswerten */

  index = code_to_lang[nvm.language];
  rs_trindex[DIALOG][index].ob_state |= SELECTED; 

/* Tastatur auswerten */

  index = code_to_key[nvm.keyboard];
  rs_trindex[DIALOG][index].ob_state |= SELECTED; 

/* Uhrzeitformat auswerten */

  index = ((nvm.datetime>>4) & 0x01) + HOURS12;
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

/* Datumsformat auswerten */

  index = (nvm.datetime & 0x03) + DATE;
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  te_ptext = rs_trindex[DIALOG][SEPERATOR].ob_spec.tedinfo->te_ptext;
  te_ptext[0] = nvm.seperator;

/* BootprÑferenz auswerten */

  switch(nvm.bootpref) {
    case 0x80:  index = TOS;
                break;
    case 0x40:  index = UNIX;
                break;
    default:    index = NOPREF;
  }
  rs_trindex[DIALOG][index].ob_state |= SELECTED;

  return(TRUE);
}

/* NVM neu initialisieren */

void set_nvm()
{
  char *te_ptext;
  int index;

  index = COLOURS;
  while (!(rs_trindex[DIALOG][index].ob_state & SELECTED))
    index++;
  nvm.vmode = index-COLOURS;

  if (rs_trindex[DIALOG][PALMODE].ob_state & SELECTED)
    nvm.vmode |= PAL;

  if (rs_trindex[DIALOG][VGAMODE].ob_state & SELECTED)
    nvm.vmode |= VGA;

  if (rs_trindex[DIALOG][COLS80].ob_state & SELECTED)
    nvm.vmode |= COL80;

  if (rs_trindex[DIALOG][INTRLACE].ob_state & SELECTED)
    nvm.vmode |= VERTFLAG;

  if (rs_trindex[DIALOG][OVRSCAN].ob_state & SELECTED)
    nvm.vmode |= OVERSCAN;

  if (rs_trindex[DIALOG][STMODE].ob_state & SELECTED)
    nvm.vmode |= STMODES;

  index = LANG_GB;
  while (!(rs_trindex[DIALOG][index].ob_state & SELECTED)) index++;
  nvm.language = lang_to_code[index-LANG_GB];

  index = KEY_GB;
  while (!(rs_trindex[DIALOG][index].ob_state & SELECTED)) index++;
  nvm.keyboard = key_to_code[index-KEY_GB];

  te_ptext = rs_trindex[DIALOG][SEPERATOR].ob_spec.tedinfo->te_ptext;
  nvm.seperator = te_ptext[0];

  nvm.bootpref = 0x0;
  if (rs_trindex[DIALOG][TOS].ob_state & SELECTED)
    nvm.bootpref = 0x80;
  if (rs_trindex[DIALOG][UNIX].ob_state & SELECTED)
    nvm.bootpref = 0x40;

  NVMaccess(1, 0, (int)(sizeof(nvm)), &nvm);
}

/* Rechnertyp testen */

boolean tst_mch()
{
  long oldstack;
  long *cookiejar;

  oldstack = Super(0l);
  cookiejar = *((long **)(0x5a0l));
  Super((void *)(oldstack));

  if (!cookiejar) {
    form_alert(1,
      "[3][BOOTCONF lÑuft nur|auf TT und Falcon!][Abbruch]");
    return(FALSE);
  }

  do
  {
    if (cookiejar[0] == _MCH)
      if (cookiejar[1] >= 0x20000l) return(TRUE);
    cookiejar = &(cookiejar[2]);
  } while (cookiejar[-2]);

  return(FALSE);
}

/* Objektkoordinaten umrechnen */

void rsrc_init()
{
  register int i;

  for(i=0; i<NUM_OBS; i++) rsrc_obfix(rs_trindex
      [DIALOG],i);
}

