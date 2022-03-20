/**************************************************************************/
/* Demo-Programm zur 1ST-BASE Messagepipeline von DaCapo                  */
/* (C) Francisco Mendez/SHIFT Computer und Werbung GmbH, 25-04-93         */
/* Letzte énderung: 15-09-93                                              */
/**************************************************************************/

/********** INCLUDE *******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <portab.h>
#include <vdi.h>
#include <aes.h>

#include <nkcc.h>
#include <mglobal.h>
#include <mydial.h>

#include "1b_pipe.h"
#ifdef RSC_CREATE
#include "1b_pipe.rh"
#include "1b_pipe.rsh"
#endif

/********** DEFINE ********************************************************/

#define NIL        -1

#define PB_INIT    0x1b00    /* Programm -> 1ST_BASE: Systemadressen */
#define BP_INIT    0x1b80    /* 1ST_BASE -> Programm: RÅckgabemessagenummer */
#define PB_SFIRST  0x1b09    /* Search First */
#define BP_SFIRST  0x1b89
#define PB_SNEXT   0x1b0a    /* Search next */
#define BP_SNEXT   0x1b8a

#define MAX_FIELDS 4         /* Textobjekte in "Feldbezeichner" */
#define MAX_ADR    6         /* Textobjekte in "Adressen" */
#define MAX_ALERT  3         /* Anzahl Fehlermeldungen */
enum {
  AL_NODACAPO,
  AL_NORECORD,
  AL_NOVERSION,
};

/********** TYPEDEF *******************************************************/

#ifndef __PORTAB__
typedef enum {
  FALSE,
  TRUE,
} BOOLEAN;
#endif

enum {
  SEL_MARKED,                /* aktuelle Liste, markierte */
  SEL_NMARKED,               /* aktuelle Liste, nicht markierte */
  SEL_LIST,                  /* aktuelle Liste, alle */
  SEL_ALL,                   /* Gesamtliste */
};

typedef struct {
  long msk_len;
  long msk_addr;
} BASE_INFO;

/********** Globale Variablen *********************************************/

int work_in  [12];
int work_out [57];

int handle;
int phys_handle;

int gl_hchar;
int gl_wchar;
int gl_hbox;
int gl_wbox;

int  gl_apid;
int  acc_id;               /* Kennung von DACAPO */
int  menu_id;
int  msg [8];              /* Nachrichtenpuffer */
int  mode;                 /* Art der Suche */
char *alerts [MAX_ALERT];  /* Alertboxen */

OBJECT *maindial;
OBJECT *adrdial;
OBJECT *fieldial;
OBJECT *versdial;

/********** Funktionsprototypen *******************************************/

BOOLEAN open_vwork  (void);
void    close_vwork (void);

int     find_state  (OBJECT *tree, int obj, unsigned int state);
int     is_state    (OBJECT *tree, int obj, unsigned int state);
int     is_flags    (OBJECT *tree, int obj, unsigned int flags);
void    draw_object (OBJECT *tree, int object);

void    hndl_alert  (int mesag_num);
int     mydial_do   (DIALINFO *di);
void    myhndl_dial (OBJECT *tree);

BOOLEAN init_rsrc   (void);
void    search      (void);
void    get_fields  (void);
void    get_version (void);
void    MainDial    (void);

void    gem_prg     (void);

/**************************************************************************/

BOOLEAN open_vwork (void)

{
  register int i;

  if ((gl_apid = appl_init()) != NIL) 
  {
    for (i = 1; i < 10; work_in [i++] = 1);

    work_in [10] = 2;
    phys_handle  = graf_handle (&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    work_in [0]  = handle = phys_handle;

    v_opnvwk (work_in, &handle, work_out);

    return (TRUE);
  } /* if */
    else
      return (FALSE);
} /* open_vwork */

/**************************************************************************/
/* Objekt-Routinen                                                        */
/**************************************************************************/

int find_state (OBJECT *tree, int obj, unsigned int state)

{
  do
  {
    if (is_state (tree, obj, state)) return (obj);
  } while (! is_flags (tree, obj++, LASTOB));

  return (NIL);
} /* find_state */

/**************************************************************************/

BOOLEAN is_state (OBJECT *tree, int obj, unsigned int state)

{
  return ((tree [obj].ob_state & state) != 0);
} /* is_state */

/**************************************************************************/

BOOLEAN is_flags (OBJECT *tree, int obj, unsigned int flags)

{
  return ((tree [obj].ob_flags & flags) != 0);
} /* is_flags */

/**************************************************************************/

void draw_object (OBJECT *tree, int object)

{
   RECT r;
 
   wind_update (BEG_UPDATE);
   objc_rect  (tree, object, &r, FALSE);
   objc_draw  (tree, object, MAX_DEPTH, r.x, r.y, r.w, r.h);                       
   wind_update (END_UPDATE);
} /* draw_object */

/**************************************************************************/
/* MyDial-Schnittstelle                                                   */
/**************************************************************************/

void hndl_alert (int mesag_num)

{
  wind_update (BEG_UPDATE);
  do_alert (1, alerts [mesag_num]);
  wind_update (END_UPDATE);
} /* hndl_alert */

/**************************************************************************/

int mydial_do (DIALINFO *di)

{
  int ret;

  wind_update (BEG_UPDATE);
  wind_update (BEG_MCTRL);
  ret = dial_do (di, 0);
  wind_update (END_MCTRL);
  wind_update (END_UPDATE);
  
  return (ret);
} /* mydial_do */

/**************************************************************************/

void myhndl_dial (OBJECT *tree)

{
  BOOLEAN ok;

  wind_update (BEG_UPDATE);
  wind_update (BEG_MCTRL);
  HndlDial (tree, 0, TRUE, NULL, &ok);
  wind_update (END_MCTRL);
  wind_update (END_UPDATE);
} /* myhndl_dial */

/**************************************************************************/
/* Resource initialisieren                                                */
/**************************************************************************/

void close_vwork (void) 

{
   v_clsvwk (handle);

#ifndef RSC_CREATE
   rsrc_free ();
#endif
   appl_exit ();
} /* close_vwork */

/**************************************************************************/

BOOLEAN init_rsrc (void)

{
  register int i;
  
#ifdef RSC_CREATE

  for (i = 0; i < NUM_OBS; i++)
    rsrc_obfix (rs_object, i);
  
  for (i = 0; i < MAX_ALERT; i++)
    alerts [i] = rs_frstr [i];
  
  maindial = rs_trindex [MAIN];
  adrdial  = rs_trindex [RECORDS];
  fieldial = rs_trindex [FIELDS];
  versdial = rs_trindex [VERSION];

#else
  int mesag_buf [8];

  if (! rsrc_load ("1B_PIPE.RSC"))
  {
    form_alert (1, "[3][Kann meine Resource-|datei nicht finden!][Exit]");
    if (_app)
      return (FALSE);
    else
      while (TRUE) evnt_mesag (mesag_buf);
  } /* if */

  rsrc_gaddr (R_TREE, MAIN,     &maindial);
  rsrc_gaddr (R_TREE, RECORDS,  &adrdial);
  rsrc_gaddr (R_TREE, FIELDS,   &fieldial);
  rsrc_gaddr (R_TREE, VERSION,  &versdial);

  for (i = 0; i < MAX_ALERT; i++)
    rsrc_gaddr (R_STRING, i, &alerts [i]);

#endif

  if (dial_init (malloc, free, NULL, NULL, NULL, TRUE))
  {
    nkc_init (BE_OFF, handle);      
    nkc_set (0);                       

    dial_fix (maindial, TRUE); 
    dial_fix (adrdial,  TRUE); 
    dial_fix (fieldial, TRUE);
    dial_fix (versdial, TRUE);
  } /* if */
  else
    return (FALSE);

  return (TRUE);
} /* init_rsrc */

/**************************************************************************/
/* 1ST_ADDR-INIT: Versions-Nr. ermitteln (Zeichenkette)                   */
/**************************************************************************/

void get_version (void)

{
  long version;           /* Zeiger auf "1ST-BASE  V1.00-D" + 10 */

  memset (msg, 0, sizeof (msg));
  msg [0] = 0x1A00;
  msg [1] = acc_id;
  msg [2] = gl_apid;
  appl_write (acc_id, 16, msg);
  do
  {
    evnt_mesag (msg);
  } while (msg [0] != 0x1A80);

  version = *(long *)&msg [4];
  set_ptext (versdial, VVERSION, (char *)version - 10);
  myhndl_dial (versdial);
} /* get_version */

/**************************************************************************/
/* 1ST_BASE-INIT: Feldbezeichner ermitteln                                */
/**************************************************************************/

void get_fields (void)

{
  BASE_INFO *info;                   /* RÅckgabe von PB_INIT */
  int       num;
  char      nums [8];

  memset (msg, 0, sizeof (msg));
  msg [0] = PB_INIT;
  msg [1] = acc_id;
  msg [2] = gl_apid;
  msg [3] = 1;
  appl_write (acc_id, 16, msg);
  do
  {
    evnt_mesag (msg);
  } while (msg [0] != BP_INIT);

  if (msg [3] > NIL)
  {
    int  i;
    char *s, len;

    info = (BASE_INFO *)(*(long *)&msg [4]);
    s   = (char *)info->msk_addr;    /* Zeiger auf Texte */
    num = info->msk_len;             /* Anzahl an Feldern */

    sprintf (nums, "%4d", num);
    set_ptext (fieldial, FNUM, nums);
    for (i = 0; i < num && i < MAX_FIELDS; i++)
    {
      len = *s++;                    /* LÑngenbyte */
      set_ptext (fieldial, FFIELD0 + i, s);
      s += len + 1;                  /* nÑchstes LÑngenbyte */
    } /* for */
    myhndl_dial (fieldial);
  } /* if */
  else
    hndl_alert (AL_NOVERSION);
} /* get_fields */

/**************************************************************************/
/* DatensÑtze suchen                                                      */
/**************************************************************************/

void search (void)

{
  register int i;
  int  delm, subst;
  int  ret;
  long record;                   /* Zeiger auf NULL-terminierten Datensatz */
  char s [MAX_ADR][40];
  char *p, *tmp;

  DIALINFO di;

  for (i = 0; i < MAX_ADR; i++) *s [i] = EOS;

  delm  = ',';                   /* normale Feldtrennung */
  delm  <<= 8;                   /* High Byte */
  subst = ';';                   /* Ersatz fÅr delm bei Export */
  subst &= 0x00FF;               /* Low Byte */

  memset (msg, 0, sizeof (msg));
  msg [0] = PB_SFIRST;           /* Messagenummer */
  msg [1] = acc_id;              /* Da Capo-Id */
  msg [2] = gl_apid;             /* eigene Id */
  msg [3] = 1;                   /* Tabelle: 0=Clipboard, 1=erste Datei... */
  msg [4] = mode;                /* Art der Suche */
  msg [5] = delm | subst;
  appl_write (acc_id, 16, msg);  /* ersten Datensatz suchen */
  do
  {
    evnt_mesag (msg);
  } while (msg [0] != BP_SFIRST);
    
  dial_center (adrdial);
  open_dial   (adrdial, TRUE, NULL, &di);
 
  do
  {
    if (msg [3] > NIL)
    {
      record = *(long *)&msg [4];
      p = (char *)record;
      if (p != NULL)
        for (i = 0; i < MAX_ADR; i++)
        {
          memset  (s [i], EOS, 40);
          strncpy (s [i], p, 40);
          p = strchr (p, ',');
          p++;
          tmp = strchr (s [i], ',');
          if (tmp)
            *tmp = EOS;
        } /* for */
    } /* if */
    else
      hndl_alert (AL_NORECORD);

    for (i = 0; i < MAX_ADR; i++)
      set_ptext (adrdial, AFIELD0 + i, s [i]);

    dial_draw (&di);
    ret = mydial_do (&di);
    if (ret == ANEXT)            /* nÑchsten Datensatz suchen */
    {
      memset (msg, 0, sizeof (msg));
      msg [0] = PB_SNEXT;
      msg [1] = acc_id;
      msg [2] = gl_apid;
      msg [3] = 0;
      msg [4] = mode;
      msg [5] = delm | subst;
      appl_write (acc_id, 16, msg);
      do
      {
        evnt_mesag (msg);
      } while (msg [0] != BP_SNEXT);
    } /* if */
    undo_state  (adrdial, ret, SELECTED);
    draw_object (adrdial, ret & ~0x8000);
  } while (ret != ACANCEL);

  close_dial (TRUE, NULL, &di);
} /* search */

/**************************************************************************/

void MainDial (void)

{
  int      ret, obj;
  DIALINFO di;

  acc_id = appl_find ("DACAPO  ");
  if (acc_id < 0)
  {
#if TRUE      /* aber hallo! nur, weil Single-TOS keine ID liefern will */
    if (! _app)
      acc_id = 0;
    else
#endif
    {
      hndl_alert (AL_NODACAPO);
      return;
    } /* else */
  } /* if */

  dial_center (maindial);
  open_dial (maindial, TRUE, NULL, &di);
  dial_draw (&di);
  
  do
  {
    ret = mydial_do (&di);
    obj = find_state (maindial, SELMARKED, SELECTED);
    mode = SEL_MARKED + obj - SELMARKED;

    switch (ret)
    {
      case MVERSION : get_version ();  break;
      case MFIELDS  : get_fields  ();  break;
      case MSEARCH  : search      ();  break;
    } /* switch */

    undo_state  (maindial, ret, SELECTED);
    draw_object (maindial, ret & ~0x8000);
  } while (ret != MEND);
      
  close_dial (TRUE, NULL, &di);
} /* maindial */

/**************************************************************************/

void gem_prg (void)

{
  int mesag_buf [8];                        /* GEM-Nachrichtenpuffer */

  if (init_rsrc ())
  {
    if (_app)
      MainDial ();
    else
    {
      menu_id = menu_register (gl_apid, "  Da Capo - 1st Base");
      if (menu_id < 0)
        while (TRUE) evnt_timer (0, 1);     /* Lasse andere Prozesse ran */

      while (TRUE)
      {
        evnt_mesag (mesag_buf);             /* auf Nachricht warten */
        switch (mesag_buf [0])
        {
          case AC_OPEN  : if (mesag_buf [4] == menu_id)
                            MainDial ();
                          break;
          case AC_CLOSE : break;
        } /* switch */
      } /* while */
    } /* else */
    
    nkc_exit  ();       /* Tastaturroutinen */
    dial_exit ();       /* MyDials */
  } /* if */
} /* gem_prg */

/**************************************************************************/

void main (void) 

{
  if (open_vwork () == TRUE) 
  {
    gem_prg ();

    close_vwork ();
    exit (0);
  } /* if */
  else
  {
    fprintf (stderr, "Fehler bei der Programminitialisierung!");
    exit (NIL);
  } /* else */
} /* main */
