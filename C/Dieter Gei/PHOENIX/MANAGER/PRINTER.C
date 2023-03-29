/*****************************************************************************
 *
 * Module : PRINTER.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 28.04.94
 *
 *
 * Description: This module implements the printer dialog box.
 *
 * History:
 * 28.04.94: No longer sending off-codes in code_to_prn
 * 04.04.94: Using new syntax for inf files
 * 16.11.93: Using new file selector
 * 01.11.93: Tabstops used in listbox
 * 09.09.93: New 3d listbox added
 * 22.08.93: Radio buttons are zero-based saved
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"

#if MSDOS
#include <bios.h>
#endif

#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "process.h"
#include "resource.h"

#include "export.h"
#include "printer.h"

/****** DEFINES **************************************************************/

#if FLEXOS
#define A_WRITE         0x0004  /* Write - CREATE,INSTALL,OPEN               */
#define A_SHARE         0x0010  /* Shared - CREATE,INSTALL,OPEN              */
#define A_SHFP          0x0040  /* Share FP with Family (0=unique) - OPEN,   */
                                /*      CREATE                               */
#define A_TEMP          0x0100  /* Delete on Last Close - CREATE, VCCREATE   */
                                /* READ, WRITE, SEEK, LOCK - see A_OFFMSK    */

#define PRBUFFER        1       /* FlexOS buffering for slow network */
#endif

#ifndef PRBUFFER
#define PRBUFFER        0       /* no buffering for other machines */
#endif

#if PRBUFFER
#define PRBUFLEN        0x2000
#endif

#define SPOOLNAME       "SPOOL.TMP"

#define MAX_SPOOLFILES  20      /* max files to spool */
#define QINF_SIZE       40      /* size of one string of queue info */

#define MAX_VALUES      2048    /* maximum number of bytes for translation table */
#define NUM_ASCII       256     /* number of ascii codes */

#define DRV_CTRL        'S'     /* control sequences */
#define DRV_PROP        'P'     /* proportional values */
#define DRV_ASCII       'A'     /* ascii translation */
#define DRV_EXT         'X'     /* extended definitions */

/****** TYPES ****************************************************************/

typedef BYTE PORT [5];          /* port name */

typedef struct
{
  FULLNAME filename;            /* filename of file to spool */
  WORD     port;                /* port number to spool */
  BOOLEAN  binary;              /* file is binary or text */
  BOOLEAN  tmp;                 /* file is temporary only */
  LONG     events_ps;           /* events per second */
  LONG     bytes_pe;            /* bytes per event */
} SPOOL_INF;

typedef BYTE QINF [QINF_SIZE];  /* queue info line */

typedef struct
{
  BYTE *ctrl_tbl [MAX_CTRL];    /* table of control sequences */
  BYTE *ascii_tbl [NUM_ASCII];  /* table of ascii translations */
} PRNDRV;

/****** VARIABLES ************************************************************/

#if FLEXOS
EXTERN UWORD    _mw_open_and_mask;
EXTERN UWORD    _mw_open_or_mask;
#endif

#if PRBUFFER
LOCAL UBYTE     pr_buffer [PRBUFLEN];
LOCAL WORD      pr_index;
#endif

LOCAL FILE      *prnfile;
LOCAL SPOOL_INF *spool_inf [MAX_SPOOLFILES];
LOCAL WORD      spool_head;
LOCAL WORD      spool_tail;
LOCAL WORD      spool_num;
LOCAL QINF      queue_inf [MAX_SPOOLFILES];

LOCAL PRNDRV    drv_tbl;
LOCAL BYTE      drv_val [MAX_VALUES];
LOCAL FILENAME  drv_iname;

#if GEMDOS
LOCAL PORT port_name [5] = {"PRN:", "AUX:", "", "", ""};
#endif

#if MSDOS
LOCAL PORT port_name [5] = {"PRN", "LPT2", "LPT3", "AUX", "COM2"};
#endif

#if FLEXOS
LOCAL PORT port_name [5] = {"PRN:", "SER:", "", "", ""};
#endif

LOCAL BYTE *szPrinterConfig = "PrinterConfig";
LOCAL WORD tabs [] = {1 * 8, 10 * 8, 15 * 8, 21 * 8, 28 * 8};
LOCAL WORD tabstyles [] = {LBT_LEFT, LBT_LEFT, LBT_LEFT, LBT_LEFT, LBT_LEFT};

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    set_boxes     _((VOID));
LOCAL VOID    set_box       _((WORD ctrl, WORD obj));
LOCAL VOID    start_spooler _((VOID));
LOCAL BOOLEAN work_spooler  _((PROC_INF *proc_inf));
LOCAL BOOLEAN stop_spooler  _((PROC_INF *proc_inf));

LOCAL BOOLEAN flush_printer _((VOID));
LOCAL BOOLEAN ctrl_to_prn   _((WORD ctrl_on, WORD ctrl_off, BOOLEAN on, FILE *file, BOOLEAN to_printer));
LOCAL BOOLEAN ascii_to_prn  _((WORD c, FILE *file, BOOLEAN to_printer));
LOCAL BOOLEAN ch_to_prn     _((WORD c, FILE *file, BOOLEAN to_printer));
LOCAL BOOLEAN send_raw      _((BYTE *s, FILE *file, BOOLEAN to_printer));
LOCAL BOOLEAN send_ucsd     _((BYTE *s, FILE *file, BOOLEAN to_printer));
LOCAL WORD    get_value     _((BYTE *s, BYTE *u));

LOCAL VOID    set_queue     _((VOID));
LOCAL VOID    update_queue  _((VOID));
LOCAL BOOLEAN queue_info    _((WINDOWP window, WORD icon));
LOCAL VOID    queue_box     _((WINDOWP window, BOOLEAN grow));
LOCAL VOID    queue_open    _((WINDOWP window));
LOCAL VOID    queue_close   _((WINDOWP window));
LOCAL VOID    queue_click   _((WINDOWP window, MKINFO *mk));

LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow));
LOCAL VOID    wi_open       _((WINDOWP window));
LOCAL VOID    wi_close      _((WINDOWP window));
LOCAL VOID    wi_click      _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN wi_key        _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_printer ()

{
  WORD     i;
  ICONBLK  *dialicon, *deskicon;
  BYTE     *p;
  FULLNAME filename;

  mem_set (&prncfg, 0, sizeof (PRNCFG));
  mem_set (&drv_tbl, 0, sizeof (PRNDRV));
  strcpy (filename, scrapdir);
  strcat (filename, SPOOLNAME);
  set_ptext (cfgprn, PCONTROL, "");
  set_ptext (cfgprn, PFILENAM, filename);

  for (i = PPORT1; i <= PPORT5; i++)
  {
    strcpy (get_str (cfgprn, i), port_name [i - PPORT1]);

    if (port_name [i - PPORT1] [0] == EOS)
    {
      do_flags (cfgprn, i, HIDETREE);
      cfgprn [PPORTS].ob_height -= gl_hbox;
    } /* if */
    else
      undo_flags (cfgprn, i, HIDETREE);
  } /* for */

  get_prncfg (&prncfg);

  if (is_state (cfgprn, PFILE, SELECTED))
    do_state (cfgprn, PSPOOL, DISABLED);

  p = get_str (cfgprn, PFILENAM);

  if (*p == EOS)
    do_state (cfgprn, PFILE, DISABLED);

  dialicon = (ICONBLK *)get_ob_spec (cfgprn, PPRINTER);
  deskicon = (ICONBLK *)get_ob_spec (desktop, IPRINTER);
  strcpy (drv_iname, deskicon->ib_ptext);
  dialicon->ib_ptext = deskicon->ib_ptext = drv_iname;

  prnfile    = NULL;
  spool_head = spool_tail = spool_num = 0;

  return (TRUE);
} /* init_printer */

/*****************************************************************************/

GLOBAL BOOLEAN term_printer ()

{
  return (TRUE);
} /* term_printer */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_printer (icon)
WORD icon;

{
  BOOLEAN ok;
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, CFGPRN);

  if (window == NULL)
  {
    form_center (cfgprn, &ret, &ret, &ret, &ret);
    window = crt_dialog (cfgprn, NULL, CFGPRN, FREETXT (FPRINTER), WI_MODELESS);

    if (window != NULL)
    {
      window->open     = wi_open;
      window->close    = wi_close;
      window->click    = wi_click;
      window->key      = wi_key;
      window->showinfo = info_printer;
    } /* if */
  } /* if */

  ok = window != NULL;

  if (ok)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (cfgprn, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_prncfg (&prncfg);
      set_boxes ();
    } /* if */

    ok = open_dialog (CFGPRN);
  } /* if */

  return (ok);
} /* open_printer */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_printer (window, icon)
WINDOWP window;
WORD    icon;

{
  open_queue (NIL);

  return (TRUE);
} /* info_printer */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_printer (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HPRINTER));
} /* help_printer */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_queue (icon)
WORD icon;

{
  BOOLEAN ok;
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, QUEUE);

  if (window == NULL)
  {
    form_center (queue, &ret, &ret, &ret, &ret);
    window = crt_dialog (queue, NULL, QUEUE, FREETXT (FQUEUE), WI_MODELESS);

    if (window != NULL)
    {
      window->open     = queue_open;
      window->close    = queue_close;
      window->click    = queue_click;
      window->showinfo = queue_info;
    } /* if */
  } /* if */

  ok = window != NULL;

  if (ok)
  {
    if (window->opened == 0) set_queue ();
    ok = open_dialog (QUEUE);
  } /* if */

  return (ok);
} /* open_queue */

/*****************************************************************************/
/* Drucker-Testroutinen                                                      */
/*****************************************************************************/

GLOBAL BOOLEAN prn_ready (port)
WORD port;

{
  BOOLEAN ready;

  ready = TRUE;

#if GEMDOS
  switch (port)
  {
    case 0 : ready = Cprnos () != 0; break;
    case 1 : ready = Cauxos () != 0; break;
  } /* switch */
#endif /* GEMDOS */

#if MSDOS
#if TURBO_C
  switch (port)
  {
    case 0 :
    case 1 : ready = biosprint (2, 0, port) == 0x90; break;
    case 2 :
    case 3 : break;
  } /* switch */
#endif /* TURBO_C */

#if MS_C
  switch (port)
  {
    case 0 :
    case 1 : ready = _bios_printer (_PRINTER_STATUS, port, 0) == 0x90; break;
    case 2 :
    case 3 : break;
  } /* switch */
#endif /* MS_C */
#endif /* MSDOS */

  return (ready);
} /* prn_ready */

/*****************************************************************************/

GLOBAL BOOLEAN prn_check (port)
WORD port;

{
  while (! prn_ready (port))
    if (hndl_alert (ERR_PRINTER) == 2) return (FALSE);

  return (TRUE);
} /* prn_check */

/*****************************************************************************/

GLOBAL BOOLEAN prn_occupied ()

{
  return (prnfile != NULL);
} /* prn_occupied */

/*****************************************************************************/

GLOBAL BOOLEAN str_to_prn (s, file, to_printer)
BYTE    *s;
FILE    *file;
BOOLEAN to_printer;

{
  REG WORD    c, len;
  REG BOOLEAN ok;

  ok = TRUE;

  while (*s && ok)
  {
    c  = *s++;
    c &= 0x00FF;

    if (c == 0x00FF)            /* control codes following */
    {
      for (len = *s++ - 1; len > 0; len--)
      {
        c   = *s++;
        c  &= 0x00FF;
        ok  = ch_to_prn (c - 1, file, to_printer);
      } /* for */
    } /* if */
    else
      ok = ascii_to_prn (c, file, to_printer);
  } /* while */

  return (ok);
} /* str_to_prn */

/*****************************************************************************/

GLOBAL BOOLEAN code_to_prn (prncfg, file, to_printer, start)
PRNCFG  *prncfg;
FILE    *file;
BOOLEAN to_printer, start;

{
  BOOLEAN ok;
  STRING  s;

  ok = TRUE;

  if (start)
  {
#if 0
    ok = ok && ctrl_to_prn (PRINTER_ON,   FAILURE,       TRUE,                       file, to_printer);
    ok = ok && ctrl_to_prn (PICA_ON,      FAILURE,       prncfg->face == PPICA,      file, to_printer);
    ok = ok && ctrl_to_prn (ELITE_ON,     FAILURE,       prncfg->face == PELITE,     file, to_printer);
    ok = ok && ctrl_to_prn (CONDENSED_ON, CONDENSED_OFF, prncfg->condensed,          file, to_printer);
    ok = ok && ctrl_to_prn (SUPER_ON,     SUPER_OFF,     prncfg->micro,              file, to_printer);
    ok = ok && ctrl_to_prn (EXPANDED_ON,  EXPANDED_OFF,  prncfg->expanded,           file, to_printer);
    ok = ok && ctrl_to_prn (ITALIC_ON,    ITALIC_OFF,    prncfg->italic,             file, to_printer);
    ok = ok && ctrl_to_prn (BOLD_ON,      BOLD_OFF,      prncfg->emphasized,         file, to_printer);
    ok = ok && ctrl_to_prn (NLQ_ON,       NLQ_OFF,       prncfg->nlq,                file, to_printer);
    ok = ok && ctrl_to_prn (LINE6_ON,     FAILURE,       prncfg->lspace == PLSPACE6, file, to_printer);
    ok = ok && ctrl_to_prn (LINE8_ON,     FAILURE,       prncfg->lspace == PLSPACE8, file, to_printer);
#else
    ok = ok && ctrl_to_prn (PRINTER_ON,   FAILURE,       TRUE,                       file, to_printer);
    ok = ok && ctrl_to_prn (PICA_ON,      FAILURE,       prncfg->face == PPICA,      file, to_printer);
    ok = ok && ctrl_to_prn (ELITE_ON,     FAILURE,       prncfg->face == PELITE,     file, to_printer);
    ok = ok && ctrl_to_prn (CONDENSED_ON, FAILURE,       prncfg->condensed,          file, to_printer);
    ok = ok && ctrl_to_prn (SUPER_ON,     FAILURE,       prncfg->micro,              file, to_printer);
    ok = ok && ctrl_to_prn (EXPANDED_ON,  FAILURE,       prncfg->expanded,           file, to_printer);
    ok = ok && ctrl_to_prn (ITALIC_ON,    FAILURE,       prncfg->italic,             file, to_printer);
    ok = ok && ctrl_to_prn (BOLD_ON,      FAILURE,       prncfg->emphasized,         file, to_printer);
    ok = ok && ctrl_to_prn (NLQ_ON,       FAILURE,       prncfg->nlq,                file, to_printer);
    ok = ok && ctrl_to_prn (LINE6_ON,     FAILURE,       prncfg->lspace == PLSPACE6, file, to_printer);
    ok = ok && ctrl_to_prn (LINE8_ON,     FAILURE,       prncfg->lspace == PLSPACE8, file, to_printer);
#endif

    str2ucsd (prncfg->control, s);
    ok = ok && send_ucsd (s, file, to_printer);
  } /* if */
  else
    ok = ok && ctrl_to_prn (FAILURE, PRINTER_OFF, FALSE, file, to_printer);

  return (ok);
} /* code_to_prn */

/*****************************************************************************/

GLOBAL FILE *fopen_prn (filename)
BYTE *filename;

{
#if FLEXOS
  UWORD old_and, old_or;
#endif

#if FLEXOS
  old_and = _mw_open_and_mask;
  old_or  = _mw_open_or_mask;
 
  _mw_open_and_mask = 0;
  _mw_open_or_mask  = A_WRITE | A_SHARE | A_SHFP | A_TEMP;

  prnfile = fopen (filename, RDWR_APPEND_BIN);

  _mw_open_and_mask = old_and;
  _mw_open_or_mask  = old_or;
#else
#if GEMDOS
  prnfile = (strcmp (filename, "PRN:") == 0) ? stdprn : stdaux;
#else
  prnfile = fopen (filename, WRITE_BIN);
#endif
#endif

  setbuf (prnfile, NULL);       /* smooth printing */

#if PRBUFFER
  pr_index = 0;
#endif

  return (prnfile);
} /* fopen_prn */

/*****************************************************************************/

GLOBAL VOID fclose_prn ()

{
  flush_printer ();

#if GEMDOS
  /* don't close stdprn or stdaux */
#else
  if (prnfile != NULL) fclose (prnfile);
#endif

  prnfile = NULL;
} /* fclose_prn */

/*****************************************************************************/

GLOBAL VOID spool_file (filename, port, binary, tmp, events_ps, bytes_pe)
BYTE    *filename;
WORD    port;
BOOLEAN binary, tmp;
LONG    events_ps, bytes_pe;

{
  SPOOL_INF *spoolp;

  if (spool_num == MAX_SPOOLFILES)
    hndl_alert (ERR_QUEUEFULL);
  else
  {
    spoolp = mem_alloc ((LONG)sizeof (SPOOL_INF));

    if (spoolp == NULL)
      hndl_alert (ERR_NOMEMORY);
    else
    {
      if (! file_exist (filename))
        file_error (ERR_FILEOPEN, filename);
      else
      {
        spool_inf [spool_head] = spoolp;
        spool_head             = (spool_head + 1) % MAX_SPOOLFILES;
        spool_num++;

        strcpy (spoolp->filename, filename);
        spoolp->port      = port;
        spoolp->binary    = binary;
        spoolp->tmp       = tmp;
        spoolp->events_ps = events_ps;
        spoolp->bytes_pe  = bytes_pe;

        update_queue ();
        set_meminfo ();
        if (! prn_occupied ()) start_spooler ();
      } /* else */
    } /* else */
  } /* else */
} /* spool_file */

/*****************************************************************************/

GLOBAL VOID print_buffer (buffer, size)
BYTE *buffer;
LONG size;

{
  FULLNAME filename;
  FHANDLE  f;

  busy_mouse ();
  strcpy (filename, (prncfg.port == PFILE) ? prncfg.filename : temp_name (NULL));

  f = file_create (filename);

  if (f < 0)
    file_error (ERR_FILECREATE, filename);
  else
  {
    if (file_write (f, size, buffer) != size) file_error (ERR_FILEWRITE, filename);
    file_close (f);

    if (prncfg.port != PFILE)
      spool_file (filename, prncfg.port - PPORT1, FALSE, TRUE, prncfg.events_ps, prncfg.bytes_pe);
  } /* else */

  arrow_mouse ();
} /* print_buffer */

/*****************************************************************************/

GLOBAL VOID check_spool ()

{
  if (! prn_occupied ())
    if (spool_num > 0) start_spooler ();
} /* check_spool */

/*****************************************************************************/

GLOBAL VOID get_ctrlcode (ctrl_code, code)
WORD ctrl_code;
BYTE *code;

{
  WORD i;

  code [0] = EOS;
  
  if (drv_tbl.ctrl_tbl [ctrl_code] != NULL)
  {
    for (i = 0; i <= LEN (drv_tbl.ctrl_tbl [ctrl_code]); i++)
      code [i + 1] = drv_tbl.ctrl_tbl [ctrl_code] [i] + 1;

    code [0]     = 0xFF;
    code [i + 1] = EOS;
  } /* if */
} /* get_ctrlcode */

/*****************************************************************************/

GLOBAL VOID get_prncfg (prncfg)
PRNCFG *prncfg;

{
  STRING s;

  get_ptext (cfgprn, PCONTROL, prncfg->control);
  get_ptext (cfgprn, PFILENAM, prncfg->filename);
  str_upper (prncfg->filename);

  prncfg->face       = get_rbutton (cfgprn, PPICA);
  prncfg->condensed  = get_checkbox (cfgprn, PCONDENS);
  prncfg->micro      = get_checkbox (cfgprn, PMICRO);
  prncfg->expanded   = get_checkbox (cfgprn, PEXPANDE);
  prncfg->italic     = get_checkbox (cfgprn, PITALIC);
  prncfg->emphasized = get_checkbox (cfgprn, PEMPHASI);
  prncfg->nlq        = get_checkbox (cfgprn, PNLQ);
  prncfg->spool      = get_checkbox (cfgprn, PSPOOL);
  prncfg->port       = get_rbutton (cfgprn, PFILE);
  prncfg->lspace     = get_rbutton (cfgprn, PLSPACE6);

  get_ptext (cfgprn, PEVENTS, s);
  prncfg->events_ps = atol (s);

  get_ptext (cfgprn, PBYTES, s);
  prncfg->bytes_pe = atol (s);
} /* get_prncfg */

/*****************************************************************************/

GLOBAL VOID set_prncfg (prncfg)
PRNCFG *prncfg;

{
  STRING s;

  str_upper (prncfg->filename);
  set_ptext (cfgprn, PCONTROL, prncfg->control);
  set_ptext (cfgprn, PFILENAM, prncfg->filename);

  set_rbutton (cfgprn, prncfg->face, PPICA, PELITE);
  set_checkbox (cfgprn, PCONDENS, prncfg->condensed);
  set_checkbox (cfgprn, PMICRO,   prncfg->micro);
  set_checkbox (cfgprn, PEXPANDE, prncfg->expanded);
  set_checkbox (cfgprn, PITALIC,  prncfg->italic);
  set_checkbox (cfgprn, PEMPHASI, prncfg->emphasized);
  set_checkbox (cfgprn, PNLQ,     prncfg->nlq);
  set_checkbox (cfgprn, PSPOOL,   prncfg->spool);
  set_rbutton (cfgprn, prncfg->port, PFILE, PPORT5);
  set_rbutton (cfgprn, prncfg->lspace, PLSPACE6, PLSPACE8);

  sprintf (s, "%ld", prncfg->events_ps);
  set_ptext (cfgprn, PEVENTS, s);
  sprintf (s, "%ld", prncfg->bytes_pe);
  set_ptext (cfgprn, PBYTES, s);

  if (is_state (cfgprn, PFILE, SELECTED) == ! is_state (cfgprn, PSPOOL, DISABLED))
    flip_state (cfgprn, PSPOOL, DISABLED);

  if ((prncfg->filename [0] == EOS) == ! is_state (cfgprn, PFILE, DISABLED))
    flip_state (cfgprn, PFILE, DISABLED);

  undo_state (cfgprn, POK, DISABLED);
  undo_state (cfgprn, PSAVE, DISABLED);
} /* set_prncfg */

/*****************************************************************************/

GLOBAL VOID get_prname (prncfg, prname)
PRNCFG *prncfg;
BYTE   *prname;

{
  if (prncfg->port == PFILE)
    strcpy (prname, prncfg->filename);
  else
    if (prncfg->spool)
      strcpy (prname, temp_name (NULL));
    else
      strcpy (prname, port_name [prncfg->port - PPORT1]);
} /* get_prname */

/*****************************************************************************/

GLOBAL BOOLEAN load_prncfg (loadinf, loadname, cfg, updt_dialog)
BYTE    *loadinf, *loadname;
PRNCFG  *cfg;
BOOLEAN updt_dialog;

{
  LONGSTR  s;
  BYTE     *pInf;
  FILE     *file;
  FULLNAME filename, name;
  WINDOWP  window;

  filename [0] = EOS;

  if (loadinf != NULL)
    pInf = loadinf;
  else
  {
    if ((loadname != NULL) && (*loadname != EOS))
      strcpy (filename, loadname);
    else
      if (! get_open_filename (FLOADPRN, NULL, 0L, FFILTER_PRN, NULL, cfg_path, FPRNSUFF, filename, NULL))
        return (FALSE);

    pInf = ReadInfFile (filename);

    if (pInf == NULL)
    {
      file_error (ERR_FILEOPEN, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

  if (FindSection (pInf, szPrinterConfig) != NULL)
  {
    GetProfileString (pInf, szPrinterConfig, "PrinterDriver", "", s);
    strcpy (name, drv_path);
    strcat (name, drv_name);

    if (strcmp (s, name) != 0)
      load_driver (s);

    GetProfileString (pInf, szPrinterConfig, "ControlCodes", cfg->control, cfg->control);
    GetProfileString (pInf, szPrinterConfig, "OutputFileName", cfg->filename, cfg->filename);
    cfg->face       = GetProfileWord (pInf, szPrinterConfig, "FontType", cfg->face) + PPICA;
    cfg->condensed  = GetProfileBool (pInf, szPrinterConfig, "Condensed", cfg->condensed);
    cfg->micro      = GetProfileBool (pInf, szPrinterConfig, "Micro", cfg->micro);
    cfg->expanded   = GetProfileBool (pInf, szPrinterConfig, "Expanded", cfg->expanded);
    cfg->italic     = GetProfileBool (pInf, szPrinterConfig, "Italic", cfg->italic);
    cfg->emphasized = GetProfileBool (pInf, szPrinterConfig, "Emphasized", cfg->emphasized);
    cfg->nlq        = GetProfileBool (pInf, szPrinterConfig, "NLQ", cfg->nlq);
    cfg->spool      = GetProfileBool (pInf, szPrinterConfig, "Spooler", cfg->spool);
    cfg->port       = GetProfileWord (pInf, szPrinterConfig, "Port", cfg->port) + PFILE;
    cfg->lspace     = GetProfileWord (pInf, szPrinterConfig, "LineSpacing", cfg->lspace) + PLSPACE6;
    cfg->events_ps  = GetProfileLong (pInf, szPrinterConfig, "EventsPerSecond", cfg->events_ps);
    cfg->bytes_pe   = GetProfileLong (pInf, szPrinterConfig, "BytesPerEvent", cfg->bytes_pe);
  } /* if */
  else						/* old inf file */
  {
    file = fopen (filename, READ_TXT);

    text_rdln (file, cfg->control, LONGSTRLEN);
    text_rdln (file, cfg->filename, LONGSTRLEN);
    text_rdln (file, s, LONGSTRLEN);
    sscanf (s, "%3d%2d%2d%2d%2d%2d%2d%2d%3d%3d %ld %ld\n",
               &cfg->face,
               &cfg->condensed,
               &cfg->micro,
               &cfg->expanded,
               &cfg->italic,
               &cfg->emphasized,
               &cfg->nlq,
               &cfg->spool,
               &cfg->port,
               &cfg->lspace,
               &cfg->events_ps,
               &cfg->bytes_pe);

    cfg->face   += PPICA;
    cfg->port   += PFILE;
    cfg->lspace += PLSPACE6;

    fclose (file);
    save_prncfg (NULL, filename, cfg);	/* save as new format */
  } /* else */

  if (updt_dialog)
  {
    set_prncfg (cfg);

    window = search_window (CLASS_DIALOG, SRCH_OPENED, CFGPRN);
    if (window != NULL) set_redraw (window, &window->scroll);
  } /* if */

  if (loadinf == NULL) mem_free (pInf);

  arrow_mouse ();
  return (TRUE);
} /* load_prncfg */

/*****************************************************************************/

GLOBAL BOOLEAN save_prncfg (savefile, savename, cfg)
FILE   *savefile;
BYTE   *savename;
PRNCFG *cfg;

{
  FILE     *file;
  FULLNAME filename;

  filename [0] = EOS;

  if (savefile != NULL)
    file = savefile;
  else
  {
    if ((savename != NULL) && (*savename != EOS))
      strcpy (filename, savename);
    else
      if (! get_save_filename (FSAVEPRN, NULL, 0L, FFILTER_PRN, NULL, cfg_path, FPRNSUFF, filename, NULL))
        return (FALSE);

    file = fopen (filename, WRITE_TXT);

    if (file == NULL)
    {
      file_error (ERR_FILECREATE, filename);
      return (FALSE);
    } /* if */
  } /* else */

  busy_mouse ();

  fprintf (file, "[%s]\n", szPrinterConfig);
  fprintf (file, "PrinterDriver=%s%s\n", drv_path, drv_name);
  fprintf (file, "ControlCodes=%s\n", cfg->control);
  fprintf (file, "OutputFileName=%s\n", cfg->filename);
  fprintf (file, "FontType=%d\n", cfg->face - PPICA);
  fprintf (file, "Condensed=%d\n", cfg->condensed);
  fprintf (file, "Micro=%d\n", cfg->micro);
  fprintf (file, "Expanded=%d\n", cfg->expanded);
  fprintf (file, "Italic=%d\n", cfg->italic);
  fprintf (file, "Emphasized=%d\n", cfg->emphasized);
  fprintf (file, "NLQ=%d\n", cfg->nlq);
  fprintf (file, "Spooler=%d\n", cfg->spool);
  fprintf (file, "Port=%d\n", cfg->port - PFILE);
  fprintf (file, "LineSpacing=%d\n", cfg->lspace - PLSPACE6);
  fprintf (file, "EventsPerSecond=%ld\n", cfg->events_ps);
  fprintf (file, "BytesPerEvent=%ld\n", cfg->bytes_pe);

  if (savefile == NULL) fclose (file);

  arrow_mouse ();
  return (TRUE);
} /* save_prncfg */

/*****************************************************************************/

GLOBAL BOOLEAN load_driver (filename)
BYTE *filename;

{
  BOOLEAN  ok;
  FILE     *file;
  WORD     line, val, size, i;
  LONG     memsize;
  BOOLEAN  more;
  LONGSTR  s, u;
  FULLNAME fullname;
  STRING   t;
  BYTE     *mem, *p;
  WINDOWP  window;

  if (prn_occupied () || (spool_num > 0))
  {
    hndl_alert (ERR_CHANGEDRV);
    return (FALSE);
  } /* if */

  if ((filename != NULL) && (*filename != EOS))
    strcpy (fullname, filename);
  else
  {
    strcpy (fullname, drv_path);
    strcat (fullname, drv_name);

    if (! get_open_filename (FLOADPRT, NULL, 0L, FFILTER_PRT, NULL, drv_path, FPRTSUFF, fullname, drv_name))
      return (FALSE);
  } /* else */

  if (*fullname == EOS) return (FALSE);

  file_split (fullname, NULL, drv_path, drv_name, NULL);

  busy_mouse ();

  file = fopen (fullname, READ_TXT);
  ok   = file != NULL;

  if (! ok)
  {
    drv_path [0] = EOS;
    drv_name [0] = EOS;
    file_error (ERR_FILEOPEN, fullname);
  } /* if */
  else
  {
    line    = 0;
    more    = TRUE;
    memsize = 0;

    while (more && text_rdln (file, s, LONGSTRLEN))
    {
      line++;

      if (*s != EOS)
      {
        val = 0;

        switch (s [0])
        {
          case DRV_CTRL  : val = get_value (s + 1, u);
                           if ((0 <= val) && (val < MAX_CTRL))
                             memsize += LEN (u) + 1;
                           break;
          case DRV_PROP  : break;
          case DRV_ASCII : val = get_value (s + 1, u);
                           if ((0 <= val) && (val < NUM_ASCII))
                             memsize += LEN (u) + 1;
                           break;
          case DRV_EXT   : break;
        } /* switch */

        if (val == FAILURE)
        {
          strncpy (t, s, 40);
          t [40] = EOS;
          sprintf (s, alerts [ERR_READDRV], fullname, line, t);
          ok = more = open_alert (s) == 1;
        } /* if */
      } /* if */
    } /* while */

    if (more)
      if (memsize > MAX_VALUES)
      {
        hndl_alert (ERR_NOMEMORY);
        ok = FALSE;
      } /* if */
      else
      {
        rewind (file);
        mem_set (&drv_tbl, 0, sizeof (PRNDRV));

        mem  = drv_val;
        more = TRUE;
        line = 0;

        while (more && text_rdln (file, s, LONGSTRLEN))
          if (*s != EOS)
          {
            if (line == 0)              /* get name of printer */
            {
              p = strchr (s, ':');

              if (p != NULL)
              {
                p++;
                while (*p == SP) p++;
                strncpy (drv_iname, p, 12);
                drv_iname [12] = EOS;
                for (i = strlen (drv_iname) - 1; (i >= 0) && (drv_iname [i] == SP); i--);
                drv_iname [i + 1] = EOS;
              } /* if */
            } /* if */

            line++;
            val = 0;

            switch (s [0])
            {
              case DRV_CTRL  : val = get_value (s + 1, u);
                               if ((0 <= val) && (val < MAX_CTRL))
                               {
                                 size = LEN (u) + 1;
                                 drv_tbl.ctrl_tbl [val] = mem;
                                 mem_move (mem, u, size);
                                 mem += size;
                               } /* if */
                               break;
              case DRV_PROP  : break;
              case DRV_ASCII : val = get_value (s + 1, u);
                               if ((0 <= val) && (val < NUM_ASCII))
                               {
                                 size = LEN (u) + 1;
                                 drv_tbl.ascii_tbl [val] = mem;
                                 mem_move (mem, u, size);
                                 mem += size;
                               } /* if */
                               break;
              case DRV_EXT   : break;
            } /* switch */
          } /* if, while */

        set_boxes ();
        draw_object (find_desk (), IPRINTER);
        window = search_window (CLASS_DIALOG, SRCH_OPENED, CFGPRN);
        if (window != NULL) set_redraw (window, &window->scroll);
      } /* else, if */

    set_meminfo ();
    fclose (file);
  } /* else */

  arrow_mouse ();
  return (ok);
} /* load_driver */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  switch (msg)
  {
    case LBN_GETITEM   : return ((LONG)&queue_inf [index]);
    case LBN_DRAWITEM  : break;
    case LBN_SELCHANGE : break;
    case LBN_DBLCLK    : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID set_boxes ()

{
  set_box (PICA_ON, PPICA);
  set_box (ELITE_ON, PELITE);
  set_box (CONDENSED_ON, PCONDENS);
  set_box (SUPER_ON, PMICRO);
  set_box (EXPANDED_ON, PEXPANDE);
  set_box (ITALIC_ON, PITALIC);
  set_box (BOLD_ON, PEMPHASI);
  set_box (NLQ_ON, PNLQ);
  set_box (LINE6_ON, PLSPACE6);
  set_box (LINE8_ON, PLSPACE8);
} /* set_boxes */

/*****************************************************************************/

LOCAL VOID set_box (ctrl, obj)
WORD ctrl, obj;

{
  if ((drv_tbl.ctrl_tbl [ctrl] == NULL) == ! is_state (cfgprn, obj, DISABLED))
    flip_state (cfgprn, obj, DISABLED);
} /* set_box */

/*****************************************************************************/

LOCAL VOID start_spooler ()

{
  SPOOL_INF *spoolp;
  PROC_INF  proc_inf, *procp;
  BYTE      *title;
  WINDOWP   window;
  FULLNAME  prname;

  spoolp = spool_inf [spool_tail];

  strcpy (proc_inf.filename, spoolp->filename);

  proc_inf.db          = NULL;
  proc_inf.table       = FAILURE;
  proc_inf.inx         = FAILURE;
  proc_inf.dir         = 0;
  proc_inf.cols        = 0;
  proc_inf.columns     = NULL;
  proc_inf.colwidth    = NULL;
  proc_inf.cursor      = NULL;
  proc_inf.format      = 1;
  proc_inf.maxrecs     = file_length (spoolp->filename);
  proc_inf.events_ps   = spoolp->events_ps;
  proc_inf.recs_pe     = spoolp->bytes_pe;
  proc_inf.impexpcfg   = NULL;
  proc_inf.page_format = NULL;
  proc_inf.prncfg      = NULL;
  proc_inf.to_printer  = TRUE;
  proc_inf.binary      = spoolp->binary;
  proc_inf.tmp         = spoolp->tmp;
  proc_inf.special     = 0;
  proc_inf.filelength  = proc_inf.maxrecs;
  proc_inf.workfunc    = work_spooler;
  proc_inf.stopfunc    = stop_spooler;

  if (proc_inf.filelength != 0)
    if (prn_check (spoolp->port))
    {
      proc_inf.file = fopen (proc_inf.filename, READ_BIN);

      if (proc_inf.file == NULL)
        file_error (ERR_FILEOPEN, proc_inf.filename);
      else
      {
        strcpy (prname, port_name [spoolp->port]);
        fopen_prn (prname);

        if (prnfile == NULL)
          file_error (ERR_FILECREATE, prname);
        else
        {
          if (! spoolp->binary) code_to_prn (&prncfg, prnfile, TRUE, TRUE);

          title  = FREETXT (FPSPOOL);
          window = crt_process (NULL, NULL, NIL, title, &proc_inf, 0L, WI_MODELESS);

          if (window != NULL)
          {
            procp = (PROC_INF *)window->special;
            strcpy (procp->dbstr, prname);
            miconify (window);
          } /* if */
        } /* if */
      } /* if */
    } /* if, if */

  mem_free (spoolp);
  spool_tail = (spool_tail + 1) % MAX_SPOOLFILES;
  spool_num--;
  set_meminfo ();
  update_queue ();
} /* start_spooler */

/*****************************************************************************/

LOCAL BOOLEAN work_spooler (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok;
  BYTE    c;
  BYTE    s [2];

  ok = fread (&c, 1, sizeof (BYTE), proc_inf->file) == sizeof (BYTE);

  if (ok)
    if (proc_inf->binary)
      ok = ch_to_prn (c, prnfile, TRUE);        /* don't use translate table */
    else
    {
      s [0] = c;
      s [1] = EOS;
      ok    = str_to_prn (s, prnfile, TRUE);    /* use translate table */
    } /* else, if */

  return (ok);
} /* work_spooler */

/*****************************************************************************/

LOCAL BOOLEAN stop_spooler (proc_inf)
PROC_INF *proc_inf;

{
  BOOLEAN ok;

  if (! proc_inf->binary && ! proc_inf->tmp && proc_inf->to_printer) /* ascii spooler */
    ok = code_to_prn (&prncfg, prnfile, TRUE, FALSE); /* send "stop string" */

  return (ok);
} /* stop_spooler */

/*****************************************************************************/

LOCAL BOOLEAN flush_printer ()

{
  BOOLEAN ok;

  ok = TRUE;

#if PRBUFFER
  if (prnfile != NULL) ok = fwrite (pr_buffer, 1, pr_index, prnfile) == pr_index;
  pr_index = 0;
#endif

  return (ok);
} /* flush_printer */

/*****************************************************************************/

LOCAL BOOLEAN ctrl_to_prn (ctrl_on, ctrl_off, on, file, to_printer)
WORD    ctrl_on, ctrl_off;
BOOLEAN on;
FILE    *file;
BOOLEAN to_printer;

{
  BOOLEAN ok;

  ok = TRUE;

  if (on)
  {
    if (ctrl_on != FAILURE)
      if (drv_tbl.ctrl_tbl [ctrl_on] != NULL)
        ok = send_ucsd (drv_tbl.ctrl_tbl [ctrl_on], file, to_printer);
  } /* if */
  else
  {
    if (ctrl_off != FAILURE)
      if (drv_tbl.ctrl_tbl [ctrl_off] != NULL)
        ok = send_ucsd (drv_tbl.ctrl_tbl [ctrl_off], file, to_printer);
  } /* else */

  return (ok);
} /* ctrl_to_prn */

/*****************************************************************************/

LOCAL BOOLEAN ascii_to_prn (c, file, to_printer)
WORD    c;
FILE    *file;
BOOLEAN to_printer;

{
  if (drv_tbl.ascii_tbl [c] == NULL)
    return (ch_to_prn (c, file, to_printer));
  else
    return (send_ucsd (drv_tbl.ascii_tbl [c], file, to_printer));
} /* ascii_to_prn */

/*****************************************************************************/

LOCAL BOOLEAN ch_to_prn (c, file, to_printer)
WORD    c;
FILE    *file;
BOOLEAN to_printer;

{
  BOOLEAN ok;
  BYTE    s [2];

#if PRBUFFER
  if (to_printer)
  {
    ok = TRUE;
    pr_buffer [pr_index++] = c;
    if (pr_index == PRBUFLEN) ok = flush_printer ();
  } /* if */
  else
  {
    s [0] = c;
    s [1] = EOS;
    ok    = fwrite (s, 1, 1, file) == 1;
  } /* else */
#else
  s [0] = c;
  s [1] = EOS;
  ok    = fwrite (s, 1, 1, file) == 1;
#endif

  return (ok);
} /* ch_to_prn */

/*****************************************************************************/

LOCAL BOOLEAN send_raw (s, file, to_printer)
BYTE    *s;
FILE    *file;
BOOLEAN to_printer;

{
  REG BOOLEAN ok;

  ok = TRUE;

  while (*s && ok) ok = ch_to_prn (*s++, file, to_printer);

  return (ok);
} /* send_raw */

/*****************************************************************************/

LOCAL BOOLEAN send_ucsd (s, file, to_printer)
BYTE    *s;
FILE    *file;
BOOLEAN to_printer;

{
  REG BOOLEAN ok;
  REG WORD    i, l;

  l = (UBYTE)s [0];

  for (i = 1, ok = TRUE; (i <= l) && ok; i++) ok = ch_to_prn (s [i], file, to_printer);

  return (ok);
} /* send_ucsd */

/*****************************************************************************/

LOCAL WORD get_value (s, u)
BYTE *s, *u;

{
  WORD    val;
  BYTE    *p, *r;
  LONGSTR t;
  BOOLEAN ok;

  strcpy (t, s);

  val = atoi (t);
  p   = strchr (t, ':');

  if (p == NULL)
    val = FAILURE;
  else
  {
    p++;                                        /* behind ':' */
    while ((*p == SP) && (*p != EOS)) p++;      /* eat spaces */
    r = strchr (p, ';');                        /* look for comments */
    if (r != NULL) *r = EOS;                    /* discard comments */

    ok = str2ucsd (p, u);

    if (! ok) val = FAILURE;
  } /* else */

  return (val);
} /* get_value */

/*****************************************************************************/

LOCAL VOID set_queue ()

{
  WORD      i, num;
  BYTE      *mem, *p;
  SPOOL_INF *spoolp;
  FILENAME  filename;
  EXT       ext;

  p = FREETXT (FQUEUEIN);

  for (num = spool_num, i = spool_tail, mem = queue_inf [0]; num > 0; num--, i = (i + 1) % MAX_SPOOLFILES)
  {
    spoolp = spool_inf [i];
    file_split (spoolp->filename, NULL, NULL, filename, ext);
    sprintf (mem, p, filename, ext, port_name [spoolp->port], FREETXT (spoolp->binary ? FBINARY : FASCII), FREETXT (spoolp->tmp ? FYES : FNO));
    mem += sizeof (QINF);
  } /* for */

  ListBoxSetCallback (queue, QLIST, callback);
  ListBoxSetStyle (queue, QLIST, LBS_VSCROLL | LBS_VREALTIME | LBS_MANDATORY, TRUE);
  ListBoxSetTabstops (queue, QLIST, sizeof (tabs) / sizeof (WORD), tabs, tabstyles);
  ListBoxSetCount (queue, QLIST, spool_num, NULL);
  ListBoxSetCurSel (queue, QLIST, FAILURE);
  ListBoxSetTopIndex (queue, QLIST, 0);
  ListBoxSetLeftOffset (queue, QLIST, 0);
} /* set_queue */

/*****************************************************************************/

LOCAL VOID update_queue ()

{
  if (search_window (CLASS_DIALOG, SRCH_OPENED, QUEUE) != NULL)
  {
    set_queue ();
    ListBoxRedraw (queue, QLIST);
  } /* if */
} /* update_queue */

/*****************************************************************************/

LOCAL VOID queue_box (window, grow)
WINDOWP window;
BOOLEAN grow;

{
  RECT l, b;

  xywh2rect (0, 0, 0, 0, &l);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* queue_box */

/*****************************************************************************/

LOCAL VOID queue_open (window)
WINDOWP window;

{
  box (window, TRUE);
  ListBoxSetWindowHandle (queue, QLIST, window->handle);
} /* queue_open */

/*****************************************************************************/

LOCAL VOID queue_close (window)
WINDOWP window;

{
  ListBoxSetWindowHandle (queue, QLIST, FAILURE);
  box (window, FALSE);
} /* queue_close */

/*****************************************************************************/

LOCAL VOID queue_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case QLIST : ListBoxClick (window->object, window->exit_obj, mk);
                 break;
    case QOK   : break;
    case QHELP : hndl_help (HQUEUE);
                 undo_state (window->object, window->exit_obj, SELECTED);
                 draw_object (window, window->exit_obj);
                 break;
  } /* switch */
} /* queue_click */

/*****************************************************************************/

LOCAL BOOLEAN queue_info (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR s;

  sprintf (s, alerts [ERR_INFOPRINTER], spool_num, MAX_SPOOLFILES);
  open_alert (s);

  return (TRUE);
} /* queue_info */

/*****************************************************************************/

LOCAL VOID box (window, grow)
WINDOWP window;
BOOLEAN grow;

{
  RECT l, b;

  get_dxywh (IPRINTER, &l);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  box (window, TRUE);
} /* wi_open */

/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  box (window, FALSE);
} /* wi_close */

/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE     *p1, *p2, *p3, *p4;
  FULLNAME fullname;
  STRING   s;
  PRNCFG   savecfg;

  switch (window->exit_obj)
  {
    case PPRINTER :
    case PDRIVER  : load_driver (NULL);

                    if (window->exit_obj == PDRIVER)
                    {
                      undo_state (window->object, window->exit_obj, SELECTED);
                      draw_object (window, window->exit_obj);
                    } /* if */
                    break;
    case PFILELAB : if (mk->breturn == 2)
                    {
                      get_ptext (window->object, PFILENAM, fullname);

                      if (get_save_filename (FPRNFILE, NULL, 0L, FFILTER_TMP, NULL, NULL, FAILURE, fullname, NULL))
                      {
                        set_ptext (window->object, PFILENAM, fullname);
                        draw_object (window, PFILENAM);
                      } /* if */
                    } /* if */
                    break;
    case POK      : get_prncfg (&prncfg);
                    break;
    case PCANCEL  : set_prncfg (&prncfg);
                    break;
    case PHELP    : help_printer (window, IPRINTER);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case PLOAD    : load_prncfg (NULL, NULL, &savecfg, TRUE);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case PSAVE    : get_prncfg (&savecfg);
                    save_prncfg (NULL, NULL, &savecfg);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  p1 = get_str (cfgprn, PFILENAM);
  p2 = get_str (cfgprn, PEVENTS);
  p3 = get_str (cfgprn, PBYTES);
  p4 = get_str (cfgprn, PCONTROL);

  if ((! str2ucsd (p4, s) || (*p1 == EOS) && is_state (cfgprn, PFILE, SELECTED) || (*p2 == EOS) || (*p3 == EOS)) == ! is_state (cfgprn, POK, DISABLED))
  {
    flip_state (cfgprn, POK, DISABLED);
    draw_object (window, POK);
    flip_state (cfgprn, PSAVE, DISABLED);
    draw_object (window, PSAVE);
  } /* if */

  if (is_state (cfgprn, PFILE, SELECTED) == ! is_state (cfgprn, PSPOOL, DISABLED))
  {
    flip_state (cfgprn, PSPOOL, DISABLED);
    draw_object (window, PSPOOL);
  } /* if */
} /* wi_click */

/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;

  switch (window->edit_obj)
  {
    case PFILENAM : p = get_str (cfgprn, PFILENAM);

                    if ((*p == EOS) == ! is_state (cfgprn, PFILE, DISABLED))
                    {
                      flip_state (cfgprn, PFILE, DISABLED);
                      draw_object (window, PFILE);
                    } /* if */
                    break;
  } /* switch */

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

