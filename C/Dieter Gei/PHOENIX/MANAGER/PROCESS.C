/*****************************************************************************
 *
 * Module : PROCESS.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 23.02.97
 *
 *
 * Description: This module implements the process window.
 *
 * History:
 * 23.03.97: An uninteruptable process cannot be interrupted by pressing the esc key
 * 02.01.97: Element filestr is being drawn
 * 25.05.95: Slider is drawn more beautifully
 * 28.07.94: Printer port calculation corrected
 * 09.10.93: Mouse is hidden despite error in vdi driver in wi_timer
 * 04.10.93: Records per event is multiplied by 10 if exclusive
 * 03.10.93: Background of dialog box is set according to sys_colors
 * 17.09.93: Y value of PRSLIDER modified in init_process to prevent being overriden by PRUPPER
 * 15.09.93: Border of dialog boxes modified according to dlg_colors when opened
 * 29.08.93: INITX and INITY changed
 * 22.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "event.h"
#include "printer.h"
#include "resource.h"

#include "export.h"
#include "process.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|MOVER)
#define FLAGS  (WI_NONE)
#define XFAC   gl_wbox                  /* X-Faktor */
#define YFAC   2                        /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fr Scrolling */
#define INITX  (20 * gl_wbox)           /* X-Anfangsposition */
#define INITY  (desk.y + gl_hattr + 2 * gl_hbox + 15) /* Y-Anfangsposition */
#define INITW  (36 * gl_wbox)           /* Anfangsbreite in Pixel */
#define INITH  ( 8 * gl_hbox)           /* Anfangsh”he in Pixel */
#define MILLI  1000                     /* Millisekunden fr Zeitablauf */

#define MAX_PROCESSES  (ITRASH - IPROCESS) /* max number of processes */

#define START_WORK     "00:00:00"       /* start working time */

#define CHICAGO        250              /* font number of Chicago font */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    free_all    _((PROC_INF *proc_inf));
LOCAL VOID    draw_slider _((WINDOWP window, BOOLEAN draw_border));
LOCAL VOID    draw_text   _((WINDOWP window, WORD obj, BYTE *text, BOOL center, BOOL right, BOOL border));
LOCAL DOUBLE  calc_avg    _((PROC_INF *proc_inf, BYTE *run, BYTE *remain));
LOCAL VOID    set_timestr _((LONG secs, BYTE *s));

LOCAL VOID    update_menu _((WINDOWP window));
LOCAL VOID    handle_menu _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box         _((WINDOWP window, BOOLEAN grow));
LOCAL BOOLEAN wi_test     _((WINDOWP window, WORD action));
LOCAL VOID    wi_open     _((WINDOWP window));
LOCAL VOID    wi_close    _((WINDOWP window));
LOCAL VOID    wi_delete   _((WINDOWP window));
LOCAL VOID    wi_draw     _((WINDOWP window));
LOCAL VOID    wi_arrow    _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap     _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop    _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag     _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick  _((WINDOWP window));
LOCAL BOOLEAN wi_key      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer    _((WINDOWP window));
LOCAL VOID    wi_top      _((WINDOWP window));
LOCAL VOID    wi_untop    _((WINDOWP window));
LOCAL VOID    wi_edit     _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_process ()

{
  num_processes = 0;
  millisecs     = 0;
  events       &= ~ MU_TIMER;		/* no processes => no timer */

  procbox [PRSLIDER].ob_y      += 3;	/* because border is outlined */
  procbox [PRSLIDER].ob_y      += 2;
  procbox [PRSLIDER].ob_height -= 4;

  return (TRUE);
} /* init_process */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_process ()

{
  return (TRUE);
} /* term_process */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_process (obj, menu, icon, title, proc_inf, bytes, flags)
OBJECT      *obj, *menu;
WORD        icon;
BYTE        *title;
PROC_INF    *proc_inf;
LONG        bytes;
UWORD       flags;

{
  WINDOWP  window;
  WORD     num;
  LONG     impexpmem, pagemem, prnmem, calcmem;
  PROC_INF *procp;
  BYTE     *memory;
  VTABLE   *vtablep;
  VINDEX   *vindexp;
  STRING   s;
  CALCCODE *calccode;

  if (num_processes == MAX_PROCESSES)
  {
    hndl_alert (ERR_NOPROCESSES);
    free_all (proc_inf);
    set_meminfo ();
    return (NULL);
  } /* if */

  if ((proc_inf->db == NULL) || (rtable (proc_inf->table) < NUM_SYSTABLES))
    calcmem = 0;
  else
  {
    calccode = &proc_inf->db->t_info [tableinx (proc_inf->db, rtable (proc_inf->table))].calccode;
    calcmem  = calccode->size + sizeof (LONG);
  } /* else */

  if (odd (bytes)) bytes++;     /* no odd adresses on 68000 machines */
  if (odd (calcmem)) calcmem++; /* no odd adresses on 68000 machines */

  impexpmem = (proc_inf->impexpcfg == NULL) ? 0 : sizeof (IMPEXPCFG);
  pagemem   = (proc_inf->page_format == NULL) ? 0 : sizeof (PAGE_FORMAT);
  prnmem    = (proc_inf->prncfg == NULL) ? 0 : sizeof (PRNCFG);
  memory    = mem_alloc ((LONG)(sizeof (PROC_INF) + impexpmem + pagemem + prnmem + calcmem + bytes));

  if (memory == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    free_all (proc_inf);
    set_meminfo ();
    return (NULL);
  } /* if */

  procp   = (PROC_INF *)memory;
  memory += sizeof (PROC_INF);
  *procp  = *proc_inf;

  if (VTBL (procp->table))      /* increment virtual table, original could be destroyed */
  {
    vtablep = VTABLEP (procp->table);
    vtablep->used++;
  } /* if */

  if (VINX (procp->inx))        /* increment virtual index, original could be destroyed */
  {
    vindexp = VINDEXP (procp->inx);
    vindexp->used++;
  } /* if */

  if (impexpmem != 0)
  {
    mem_move (memory, procp->impexpcfg, sizeof (IMPEXPCFG));
    procp->impexpcfg  = (IMPEXPCFG *)memory;            /* use import/export configuration */
    memory           += sizeof (IMPEXPCFG);
  } /* if */

  if (pagemem != 0)
  {
    mem_move (memory, procp->page_format, sizeof (PAGE_FORMAT));
    procp->page_format  = (PAGE_FORMAT *)memory;        /* use page format */
    memory             += sizeof (PAGE_FORMAT);
  } /* if */

  if (prnmem != 0)                                      /* use printer configuration */
  {
    mem_move (memory, procp->prncfg, sizeof (PRNCFG));
    procp->prncfg  = (PRNCFG *)memory;
    memory        += sizeof (PRNCFG);
  } /* if */

  if (calcmem != 0)                                     /* use calculation code */
  {
    mem_lmove (memory, calccode, calcmem);
    procp->calccode  = (CALCCODE *)memory;
    memory          += calcmem;
  } /* if */

  procp->actrec         = 0;
  procp->saved_recs_pe  = procp->recs_pe;
  procp->memory         = memory;
  procp->slider         = 0;
  procp->start          = clock ();
  procp->sum_work       = 0;
  procp->sec_work       = 0;
  procp->pausing        = FALSE;
  procp->blocked        = FALSE;
  procp->aborted        = FALSE;
  procp->exclusive      = FALSE;
  procp->use_calc       = use_calc;
  procp->uninteruptable = FALSE;

  if (procp->db == NULL)
  {
    procp->dbstr [0]  = EOS;
    procp->inxstr [0] = EOS;
  } /* if */
  else
  {
    dbtbl_name (procp->db, procp->table, s);
    strcpy (procp->dbstr, s + 1);                               /* 1 blank */

    sort_name (procp->db, procp->table, procp->inx, procp->dir, s);
    strcpy (procp->inxstr, s + 1);                              /* 1 blank */
  } /* else */

  strcpy (procp->workstr, START_WORK);
  strcpy (procp->reststr, procp->workstr);

  flags  = FLAGS | flags;
  obj    = procbox;                             /* always use this box */
  num    = num_windows (CLASS_PROCESS, SRCH_ANY, NULL);
  window = crt_dialog (obj, NULL, icon, title, flags);

  if (window != NULL)
  {
    window->class     = CLASS_PROCESS;  /* want to have a dialog window with my class */
    window->flags     = flags;
    window->kind      = KIND;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = 0;
    window->doc.h     = 0;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->scroll.x  = INITX + num * gl_wbox;
    window->scroll.y  = INITY + num * gl_hbox;
    window->scroll.w  = obj->ob_width;
    window->scroll.h  = obj->ob_height;
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = (procp->events_ps > 1000L) ? 1 : (1000L / procp->events_ps);
    window->special   = (LONG)procp;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = NULL;
    window->updt_menu = NULL;
    window->test      = wi_test;
    window->open      = wi_open;
    window->close     = wi_close;
    window->delete    = wi_delete;
    window->draw      = wi_draw;
    window->arrow     = NULL;
    window->snap      = NULL;
    window->objop     = NULL;
    window->drag      = NULL;
    window->click     = wi_click;
    window->unclick   = NULL;
    window->key       = wi_key;
    window->timer     = wi_timer;
    window->top       = wi_top;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = info_process;
    window->showhelp  = help_process;

    num_processes++;
    set_meminfo ();
    set_timer ();
  } /* if */

  return (window);                      /* Fenster zurckgeben */
} /* crt_process */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_process (icon)
WORD icon;

{
  BOOLEAN ok;
  WINDOWP window;

  window = search_window (CLASS_PROCESS, SRCH_CLOSED, icon);
  ok     = window != NULL;

  if (ok)
  {
    window->object->ob_spec = (dlg_colors < 16) ? 0x00001100L : 0x00001170L | sys_colors [COLOR_DIALOG];
    ok                      = open_window (window);

    if (ok)
    {
      (*window->top) (window);

      window->flags &= ~ WI_RESIDENT;   /* open window will be destroyed on close */
      window->icon   = NIL;
    } /* else */
  } /* if */

  return (ok);
} /* open_process */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_process (window, icon)
WINDOWP window;
WORD    icon;

{
  LONGSTR  s;
  PROC_INF *procp;
  DOUBLE   average;
  STRING   run, remain;

  if (icon != NIL)
    window = search_window (CLASS_PROCESS, SRCH_ANY, icon);

  if (window != NULL)
  {
    procp   = (PROC_INF *)window->special;
    average = calc_avg (procp, run, remain);
    sprintf (s, alerts [ERR_INFOPROCESS], window->name + 1, procp->filename, run, remain, average);
    open_alert (s);

    procp->start    = clock ();
    procp->sec_work = procp->sum_work;
  } /* if */

  return (window != NULL);
} /* info_process */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_process (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HPROCESS));
} /* help_process */

/*****************************************************************************/

GLOBAL VOID start_process (window, minimize, background)
WINDOWP window;
BOOLEAN minimize, background;

{
  PROC_INF *procp;

  procp = (PROC_INF *)window->special;

  if ((window->flags & WI_MODAL) || ! background) procp->exclusive = TRUE;
  if (procp->exclusive) minimize = FALSE;

  if (! minimize && background)
    if (! open_window (window))
    {
      hndl_alert (ERR_NOOPEN);
      return;
    } /* if, if */

  if (procp->exclusive && ! procp->pausing) busy_mouse ();
  if (minimize) miconify (window);

  if (background)
  {
    if (window->flags & WI_MODAL) hndl_modal (TRUE);
  } /* if */
  else
    wi_timer (window);
} /* start_process */

/*****************************************************************************/

GLOBAL BOOLEAN proc_used (db)
DB *db;

{
  WORD    num, i;
  WINDOWP windows [MAX_PROCESSES];

  num = num_windows (CLASS_PROCESS, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
    if (((PROC_INF *)windows [i]->special)->db == db) return (TRUE);

  return (FALSE);
} /* proc_used */

/*****************************************************************************/

GLOBAL BOOLEAN chk_filenames (filename)
BYTE *filename;

{
  WORD    num, i;
  WINDOWP windows [MAX_PROCESSES];

  num = num_windows (CLASS_PROCESS, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
    if (strcmp (((PROC_INF *)windows [i]->special)->filename, filename) == 0)
    {
      file_error (ERR_FILEUSED, filename);
      return (FALSE);
    } /* if */

  return (TRUE);
} /* chk_filenames */

/*****************************************************************************/

GLOBAL VOID set_timer ()

{
  WORD    num, i;
  LONG    milli;
  WINDOWP windows [MAX_PROCESSES];

  num = num_windows (CLASS_PROCESS, SRCH_ANY, windows);

  for (i = millisecs = 0; i < num; i++)
  {
    milli = windows [i]->milli;

    if (milli > 0)
      if (! ((PROC_INF *)windows [i]->special)->pausing)
        millisecs = (millisecs == 0) ? milli : min (millisecs, milli);
  } /* for */

  if (millisecs > 0)
    events |= MU_TIMER;
  else
    events &= ~ MU_TIMER;

  if (millisecs == 1) millisecs = 0;    /* well, that's faster */
} /* set_timer */

/*****************************************************************************/

LOCAL VOID free_all (proc_inf)
PROC_INF *proc_inf;

{
  if (proc_inf->cursor != NULL) db_freecursor (proc_inf->db->base, proc_inf->cursor);

  if (proc_inf->file != NULL)
    if (proc_inf->to_printer)
      fclose_prn ();
    else
      fclose (proc_inf->file);

  mem_free (proc_inf->columns);
} /* free_all */

/*****************************************************************************/

LOCAL VOID draw_slider (window, draw_border)
WINDOWP window;
BOOLEAN draw_border;

{
  RECT     r;
  PROC_INF *procp;
  WORD     xy [4];

  procp = (PROC_INF *)window->special;

  if (draw_border)
    if (dlg_colors >= 16)
    {
      objc_rect (window->object, PRSLIDER, &r, TRUE);
      draw_3d (vdi_handle, r.x + 1, r.y + 1, 1, r.w - 2, r.h - 2, BLACK, DWHITE, DBLACK, FALSE);
      draw_3d (vdi_handle, r.x, r.y, 1, r.w, r.h, DBLACK, WHITE, DWHITE, FALSE);
    } /* if, if */

  if (procp->slider > 0)
  {
    vsf_interior (vdi_handle, (colors > 2) ? FIS_SOLID : FIS_PATTERN);
    vsf_style (vdi_handle, 4);
    vsf_color (vdi_handle, (colors >= 8) ? BLUE : (colors > 2) ? GREEN : BLACK);
    vsf_perimeter (vdi_handle, TRUE);
    get_border (window, PRSLIDER, &r);

    r.w = procp->slider;

    if (dlg_colors > 2)
    {
      r.x++;
      r.y++;
      r.w -= 2;
      r.h -= 2;
    } /* if */

    rect2array (&r, xy);

    if (dlg_colors >= 16)
    {
      xy [0]++;
      xy [1]++;
      xy [2]--;
      xy [3]--;

      if (xy [0] <= xy [2])
      {
        vsf_color (vdi_handle, DWHITE);
        v_bar (vdi_handle, xy);
        draw_3d (vdi_handle, r.x + 1, r.y + 1, 1, r.w - 2, r.h - 2, WHITE, DBLACK, DWHITE, FALSE);
        draw_3d (vdi_handle, r.x, r.y, 1, r.w, r.h, BLACK, BLACK, BLACK, FALSE);
      } /* if */
    } /* if */
    else
    {
      xy [0]++;
      xy [1]++;
      xy [2]--;
      xy [3]--;

      if (xy [0] <= xy [2])
        v_bar (vdi_handle, xy);
    } /* else */
  } /* if */
} /* draw_slider */

/*****************************************************************************/

LOCAL VOID draw_text (WINDOWP window, WORD obj, BYTE *text, BOOL center, BOOL right, BOOL border)
{
  RECT r;
  WORD x, y, w, h;
  WORD minimum, maximum, width;
  WORD extent [8], distances [5], effects [3];

  get_border (window, obj, &r);
  vqt_extent (vdi_handle, text, extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

  w = extent [2] - extent [0] + effects [2];
  h = extent [5] - extent [3];
  x = r.x;
  y = r.y + (r.h - h) / 2;

  if (center)
    x += (r.w - w) / 2;
  else
    if (right)
      x += r.w - w;

  v_gtext (vdi_handle, x, y, text);

  if (dlg_colors >= 16)
  {
    draw_3d (vdi_handle, r.x - 1, r.y - 1, 1, r.w + 2, r.h + 2, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
    draw_3d (vdi_handle, r.x, r.y, 1, r.w, r.h, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
  } /* if */
} /* draw_text */

/*****************************************************************************/

LOCAL DOUBLE calc_avg (proc_inf, run, remain)
PROC_INF *proc_inf;
BYTE     *run, *remain;

{
  DOUBLE average;
  LONG   av;
  WORD   i;
  STRING s;

  average = (proc_inf->actrec == 0) ? 0.0 : (DOUBLE)proc_inf->sum_work / (DOUBLE)proc_inf->actrec;
  av      = (average * 1000000L) / CLK_TCK;

  sprintf (s, "%ld", av);
  for (i = 2; i < strlen (s); i++) s [i] = '0'; /* use only first two digits */
  av = atol (s);

  average  = av;
  average *= CLK_TCK;
  average /= 1000000L;

  set_timestr (proc_inf->sum_work, run);
  set_timestr ((LONG)(average * (proc_inf->maxrecs - proc_inf->actrec)), remain);

  return (average / CLK_TCK);
} /* calc_avg */

/*****************************************************************************/

LOCAL VOID set_timestr (secs, s)
LONG secs;
BYTE *s;

{
  WORD hour, minute, second;

  if (secs < 0) secs = 0;

  secs   /= CLK_TCK;
  second  = secs % 60;
  secs   /= 60;
  minute  = secs % 60;
  secs   /= 60;
  hour    = secs;

  if (hour > 99) hour = 99;
  sprintf (s, "%02d:%02d:%02d", hour, minute, second);
} /* set_timestr */

/*****************************************************************************/
/* Box zeichnen                                                              */
/*****************************************************************************/

LOCAL VOID box (window, grow)
WINDOWP window;
BOOLEAN grow;

{
  RECT l, b;

  get_dxywh (window->icon, &l);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/
/* Teste Fenster                                                             */
/*****************************************************************************/

LOCAL BOOLEAN wi_test (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN  ret;
  MKINFO   mk;
  PROC_INF *procp;

  ret = FALSE;

  switch (action & 0x00FF)
  {
    case DO_CLOSE  : ret = done || acc_close;
                     if (acc_close) miconify (window);
                     if (! ret)
                     {
                       ret = TRUE;
                       graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);

                       if (! (window->flags & WI_RESIDENT))
                         if ((mk.kstate & K_ALT) || (mk.mobutton & 2))
                           miconify (window);
                         else
                         {
                           procp          = (PROC_INF *)window->special;
                           ret            = hndl_alert (ERR_ABORTPROCESS) == 1;
                           procp->aborted = ret;
                         } /* else */
                     } /* if */
                     break;
    case DO_DELETE : ret = TRUE;
                     break;
  } /* switch */

  return (ret);
} /* wi_test */

/*****************************************************************************/
/* ™ffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  PROC_INF *procp;

  procp = (PROC_INF *)window->special;

  set_checkbox (window->object, PRPAUSE, procp->pausing);
  set_checkbox (window->object, PREXCLUS, procp->exclusive);

  wi_top (window); /* set object states before opening window */

  box (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieže Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  box (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* L”sche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID wi_delete (window)
WINDOWP window;

{
  PROC_INF *procp;
  WORD     num, i;
  BOOLEAN  ready;
  WINDOWP  win;
  WINDOWP  windows [MAX_PROCESSES];

  procp = (PROC_INF *)window->special;

  if (procp->stopfunc != NULL) (*procp->stopfunc) (procp);

  if (proc_beep)
    if (! procp->aborted) beep ();

  num_processes--;                      /* spooler finds a free process now */

  if (procp->file != NULL)              /* close file before spooling or removing */
  {
    if (procp->prncfg != NULL)          /* "printer stop" string */
      code_to_prn (procp->prncfg, procp->file, procp->to_printer, FALSE);

    if (procp->to_printer)
      fclose_prn ();
    else
      fclose (procp->file);

    procp->file = NULL;
  } /* if */

  if (procp->tmp) file_remove (procp->filename);

  if (procp->prncfg != NULL)
    if (procp->prncfg->spool)
      if (procp->aborted)               /* remove aborted spool file */
        file_remove (procp->filename);
      else
        spool_file (procp->filename, procp->prncfg->port - PPORT1, TRUE, TRUE, procp->prncfg->events_ps, procp->prncfg->bytes_pe);

  free_all (procp);
  if (VTBL (procp->table)) free_vtable (procp->table);
  if (VINX (procp->inx)) free_vindex (procp->inx);

  mem_free (procp);

  window->milli = 0;            /* don't use timer of window to delete */
  window->count = -1;           /* stop timer_window call */
  set_meminfo ();

  num = num_windows (CLASS_PROCESS, SRCH_ANY, windows);

  if (! prn_occupied ())
  {
    for (i = 0, ready = FALSE; (i < num) && ! ready; i++)
    {
      win   = windows [i];
      procp = (PROC_INF *)win->special;

      if (win != window)                /* don't use same window */
        if (procp->blocked)             /* unblock topmost window */
        {
          procp->pausing = FALSE;       /* calculate new timer */
          procp->blocked = FALSE;
          procp->file    = fopen_prn (procp->filename);

          if (procp->prncfg != NULL) code_to_prn (procp->prncfg, procp->file, procp->to_printer, TRUE);
          wi_top (win);
          if (win->opened > 0) set_redraw (win, &win->scroll);
          ready = TRUE;
        } /* if, if */
    } /* for */

    if (! ready) check_spool ();
  } /* if */

  set_timer ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  PROC_INF *procp;
  WORD     w, ret;
  STRING   s;
  UWORD    state;

  procp = (PROC_INF *)window->special;
  w     = procbox [PRFILE].ob_width / gl_wbox;

  set_checkbox (window->object, PRPAUSE, procp->pausing);
  objc_draw (window->object, PRPAUSE, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  state = window->object [PRPAUSE].ob_state;

  if (procp->blocked)
    do_state (window->object, PRPAUSE, DISABLED);
  else
    undo_state (window->object, PRPAUSE, DISABLED);

  objc_draw (window->object, PRPAUSE, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  window->object [PRPAUSE].ob_state = state;

  set_checkbox (window->object, PREXCLUS, procp->exclusive);
  objc_draw (window->object, PREXCLUS, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

  if (wi_modeless == WI_MODAL)                  /* only for MSDOS machines */
  {
    if (window->flags & WI_MODAL)
      do_state (window->object, PRICON, DISABLED);
    else
      undo_state (window->object, PRICON, DISABLED);

    objc_draw (window->object, PRICON, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  } /* if */

  strncpy (s, (procp->filename [0] == EOS) ? procp->filestr : procp->filename, w);
  s [w] = EOS;

  strcpy (get_str (window->object, PRFILE), s);
  undo_flags (window->object, PRFILE, HIDETREE);
  objc_draw (window->object, PRFILE, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  do_flags (window->object, PRFILE, HIDETREE);

  strcpy (get_str (window->object, PRDBNAME), procp->dbstr);
  undo_flags (window->object, PRDBNAME, HIDETREE);
  objc_draw (window->object, PRDBNAME, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  do_flags (window->object, PRDBNAME, HIDETREE);

  strncpy (s, procp->inxstr, w);
  s [w] = EOS;

  strcpy (get_str (window->object, PRINDEX), s);
  undo_flags (window->object, PRINDEX, HIDETREE);
  objc_draw (window->object, PRINDEX, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  do_flags (window->object, PRINDEX, HIDETREE);

  strcpy (get_str (window->object, PRRECLBL), FREETXT (FPRECORD + procp->format));
  undo_flags (window->object, PRRECLBL, HIDETREE);
  objc_draw (window->object, PRRECLBL, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  do_flags (window->object, PRRECLBL, HIDETREE);

  sprintf (s, "%ld", procp->maxrecs);
  strcpy (get_str (window->object, PRUPPER), s);
  undo_flags (window->object, PRUPPER, HIDETREE);
  objc_draw (window->object, PRUPPER, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
  do_flags (window->object, PRUPPER, HIDETREE);

  text_default (vdi_handle);
	
 	vst_font (vdi_handle, CHICAGO);

  vst_point (vdi_handle, gl_point, &ret, &ret, &ret, &ret);

  draw_text (window, PRRUNNIN, procp->workstr, TRUE, FALSE, TRUE);
  draw_text (window, PRREMAIN, procp->reststr, TRUE, FALSE, TRUE);
  sprintf (s, "%ld", procp->actrec);
  draw_text (window, PRRECORD, s, FALSE, TRUE, TRUE);
  draw_slider (window, TRUE);
} /* wi_draw */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  PROC_INF *procp;

  procp = (PROC_INF *)window->special;

  switch (window->exit_obj)
  {
    case PRPAUSE  : procp->pausing = get_checkbox (window->object, PRPAUSE);
                    if (! procp->pausing)
                    {
                      procp->start    = clock ();       /* start again */
                      procp->sec_work = procp->sum_work;
                    } /* if */
                    if (procp->exclusive && ! procp->pausing) busy_mouse ();
                    set_timer ();
                    break;
    case PREXCLUS : procp->exclusive = get_checkbox (window->object, PREXCLUS);
                    if (procp->exclusive && ! procp->pausing) busy_mouse ();
                    break;
    case PRICON   : miconify (window);
                    break;
    case PRHELP   : hndl_help (HPROCESS);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* wi_click */

/*****************************************************************************/
/* Taste fr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if ((mk->ascii_code == ESC) || (mk->scan_code == UNDO))
  {
    window->flags |= WI_DLCLOSE;
    return (TRUE);
  } /* if */

  return (FALSE);
} /* wi_key */

/*****************************************************************************/
/* Zeitablauf fr Fenster                                                    */
/*****************************************************************************/

LOCAL VOID wi_timer (window)
WINDOWP window;

{
  BOOLEAN  cont, in_window, mode;
  LONG     i, newval, maxrecs;
  WORD     oldwidth, newwidth, maxwidth, ret;
  PROC_INF *procp;
  RECT     r, r1;
  STRING   s;
  MKINFO   mk;
  WINDOWP  deskwin;

  procp = (PROC_INF *)window->special;

  if (procp->pausing) return;

  do
  {
    maxrecs = procp->maxrecs;
    cont    = maxrecs > 0;

    if (procp->exclusive)
      procp->recs_pe = 10 * procp->saved_recs_pe;
    else
      procp->recs_pe = procp->saved_recs_pe;

    for (i = 0; (i < procp->recs_pe) && cont; i++)
    {
      if (procp->workfunc != NULL) cont = (*procp->workfunc) (procp);

      if (cont)
      {
        if (procp->exclusive)
          if (procp->actrec % 10 == 0)
            if (! procp->uninteruptable && esc_pressed ())
            {
              mode = set_alert (TRUE);  /* no redraw events on exclusive processes */

              if (hndl_alert (ERR_ABORTPROCESS) == 1)
              {
                procp->aborted = TRUE;
                cont           = FALSE;
              } /* if */

              set_alert (mode);
            } /* if, if, if */

        procp->actrec++;
      } /* if */
    } /* for */

    newval          = procp->actrec;
    procp->sum_work = procp->sec_work + clock () - procp->start;

    calc_avg (procp, procp->workstr, procp->reststr);

    objc_rect (window->object, PRSLIDER, &r, TRUE); /* calculate slider */
    maxwidth = r.w;
    oldwidth = procp->slider;
    newwidth = (procp->maxrecs == 0) ? 0 : maxwidth * newval / procp->maxrecs;

    oldwidth = min (oldwidth, maxwidth);        /* don't get to large */
    newwidth = min (newwidth, maxwidth);

    procp->slider = newwidth;                   /* save slider for drawing */

    graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);

    if (window->opened > 0)
    {
      in_window = wind_find (mk.mox, mk.moy) == window->handle;

      if (in_window)
      {
        get_border (window, PRSLIDER, &r);
        r.x       -= 16;
        r.y       -= 16;
        r.w       += 32;
        r.h       += 32;
        in_window  = inside (mk.mox, mk.moy, &r);

        get_border (window, PRRUNNIN, &r);
        r.x       -= 16;
        r.y       -= 16;
        r.w       += 32;
        r.h       += 32;
        in_window |= inside (mk.mox, mk.moy, &r);

        get_border (window, PRREMAIN, &r);
        r.x       -= 16;
        r.y       -= 16;
        r.w       += 32;
        r.h       += 32;
        in_window |= inside (mk.mox, mk.moy, &r);

        get_border (window, PRRECORD, &r);
        r.x       -= 16;
        r.y       -= 16;
        r.w       += 32;
        r.h       += 32;
        in_window |= inside (mk.mox, mk.moy, &r);

        if (maxrecs != procp->maxrecs)          /* something has changed */
        {
          get_border (window, PRUPPER, &r);
          r.x       -= 16;
          r.y       -= 16;
          r.w       += 32;
          r.h       += 32;
          in_window |= inside (mk.mox, mk.moy, &r);
        } /* if */
      } /* if */

      if (is_top (window) && procp->exclusive && ! procp->uninteruptable)
        if ((mk.kstate & (K_RSHIFT | K_LSHIFT)) || (mk.mobutton & 3)) /* flip exclusive flag */
        {
          procp->exclusive ^= TRUE;
          set_checkbox (window->object, PREXCLUS, procp->exclusive);
          draw_object (window, PREXCLUS);

          if (procp->exclusive)                 /* I have a lot of work to do */
            busy_mouse ();
          else
            arrow_mouse ();
        } /* if, if */

      window->object->ob_x = window->scroll.x;  /* correct object tree */
      window->object->ob_y = window->scroll.y;

      wind_update (BEG_UPDATE);
      if (in_window) hide_mouse ();

      wind_get (window->handle, WF_FIRSTXYWH, &r1.x, &r1.y, &r1.w, &r1.h);

      while ((r1.w != 0) && (r1.h != 0))
      {
        text_default (vdi_handle);
        vst_font (vdi_handle, CHICAGO);
        vst_point (vdi_handle, gl_point, &ret, &ret, &ret, &ret);
        set_clip (TRUE, &r1);

        draw_text (window, PRRUNNIN, procp->workstr, TRUE, FALSE, TRUE);
        draw_text (window, PRREMAIN, procp->reststr, TRUE, FALSE, TRUE);
        sprintf (s, "%ld", procp->actrec);
        draw_text (window, PRRECORD, s, FALSE, TRUE, TRUE);

        if (maxrecs != procp->maxrecs)          /* something has changed */
        {
          sprintf (s, "%ld", procp->maxrecs);
          strcpy (get_str (window->object, PRUPPER), s);
          undo_flags (window->object, PRUPPER, HIDETREE);
          objc_draw (window->object, PRUPPER, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
          do_flags (window->object, PRUPPER, HIDETREE);
        } /* if */

        if (newwidth > oldwidth) draw_slider (window, FALSE);  /* flicker free output */

        wind_get (window->handle, WF_NEXTXYWH, &r1.x, &r1.y, &r1.w, &r1.h);
      } /* while */

      if (in_window) show_mouse ();
      wind_update (END_UPDATE);
    } /* if */
  } while (procp->exclusive && cont);

  if (! cont)
  {
    if (window->icon != NIL)
    {
      deskwin = find_desk ();
      get_border (find_desk (), window->icon, &r);
      do_flags (desktop, window->icon, HIDETREE);
      undo_state (desktop, window->icon, SELECTED);
      redraw_window (deskwin, &r);

      if (sel_window == deskwin)
      {
        setexcl (sel_objs, window->icon);       /* deleted icon is no longer in selected set */
        if (setcmp (sel_objs, NULL)) sel_window = NULL;
      } /* if */
    } /* if */

    if (procp->exclusive) arrow_mouse ();
    delete_window (window);
  } /* if */
} /* wi_timer */

/*****************************************************************************/
/* Fenster nach oben gebracht                                                */
/*****************************************************************************/

LOCAL VOID wi_top (window)
WINDOWP window;

{
  PROC_INF *procp;

  procp = (PROC_INF *)window->special;

  if (procp->blocked)
    do_state (window->object, PRPAUSE, DISABLED);
  else
    undo_state (window->object, PRPAUSE, DISABLED);

  if (window->flags & WI_MODAL)                  /* modal windows cannot be iconified */
    do_state (window->object, PRICON, DISABLED);
  else
    undo_state (window->object, PRICON, DISABLED);
} /* wi_top */

/*****************************************************************************/

