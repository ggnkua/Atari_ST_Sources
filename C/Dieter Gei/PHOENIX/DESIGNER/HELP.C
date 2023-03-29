/*****************************************************************************
 *
 * Module : HELP.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 29.03.94
 *
 *
 * Description: This module implements the help engine.
 *
 * History:
 * 29.03.94: Function v_text called with no last parameter
 * 16.11.93: Using new file selector
 * 16.10.93: Include file appl.h included
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 03.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 22.08.93: Hypertext is dark green
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "appl.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "help.h"

/****** DEFINES **************************************************************/

#define KIND    (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS   (WI_CURSKEYS)
#define XFAC    gl_wbox                 /* X-Faktor */
#define YFAC    gl_hbox                 /* Y-Faktor */
#define XUNITS  4                       /* X-Einheiten fr Scrolling */
#define YUNITS  1                       /* Y-Einheiten fr Scrolling */
#define XOFFSET (1 * gl_wbox)           /* X-Offset Work/Scrollbereich */
#define YOFFSET (gl_hbox / 2)           /* Y-Offset Work/Scrollbereich */
#define INITX   ( 2 * gl_wbox)          /* X-Anfangsposition */
#define INITY   ( 6 * gl_hbox)          /* Y-Anfangsposition */
#define INITW   (38 * gl_wbox)          /* Anfangsbreite in Pixel */
#define INITH   (16 * gl_hbox)          /* Anfangsh”he in Pixel */
#define MILLI   0                       /* Millisekunden fr Zeitablauf */

#define CACHE_SIZE      4L              /* cache size for opening HELP database */
#define NUM_CURSORS     2               /* number of cursors for opening HELP database */
#define MAX_STACK       40              /* maximum number of help records on stack */

#define EFFECT_CHAR     '@'             /* char for using effects */
#define O_B_HEADLINE    'U'             /* out format begin headline */
#define O_E_HEADLINE    'V'             /* out format end headline */

#define HELP_NAME       "HELP"          /* name of helptable */
#define TBL_HELP       20               /* number of helptable */

/****** TYPES ****************************************************************/

typedef struct
{
  LONG address;
  BYTE index [82];
  BYTE text [8192];
} HELPTABLE;

typedef struct
{
  LONG address;
  LONG x;
  LONG y;
} STACK;

/****** VARIABLES ************************************************************/

LOCAL BASE      *helpdb;                /* help database */
LOCAL FILENAME  helpname;               /* name of help database */
LOCAL FULLNAME  helppath;               /* path of help database */
LOCAL STRING    helpcontents;           /* contents of database */
LOCAL HELPTABLE *helpbuf;               /* buffer for help text */
LOCAL CURSOR    *helpcursor;            /* cursor for moving in index */
LOCAL BOOLEAN   autowrap;               /* use automatic wrapping */
LOCAL WORD      stackp;                 /* stack pointer */
LOCAL STACK     stack [MAX_STACK];      /* stack for help records */

/****** FUNCTIONS ************************************************************/

LOCAL WINDOWP crt_help    _((OBJECT *obj, OBJECT *menu, WORD icon));
LOCAL BOOLEAN info_help   _((WINDOWP window, WORD icon));
LOCAL BOOLEAN help_help   _((WINDOWP window, WORD icon));

LOCAL VOID    fetch_data  _((WINDOWP window, BYTE *helpmsg, LONG address));
LOCAL VOID    calc_slider _((WINDOWP window, WORD width));
LOCAL VOID    blink_word  _((WINDOWP window, RECT *r));
LOCAL BYTE    *get_line   _((BYTE *p, BYTE *s, WORD w, WORD *eff, WORD *num_eff));
LOCAL WORD    code2effect _((WORD code, WORD effect));
LOCAL VOID    push        _((LONG address, LONG x, LONG y));
LOCAL VOID    pull        _((LONG *address, LONG *x, LONG *y));

LOCAL VOID    update_menu _((WINDOWP window));
LOCAL VOID    handle_menu _((WINDOWP window, WORD title, WORD item));
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

GLOBAL BOOLEAN init_help (help_name, help_path, help_contents)
BYTE *help_name, *help_path, *help_contents;

{
  autowrap = FALSE;

  strcpy (helpcontents, help_contents);
  if (help_name != NULL) open_dbhelp (help_name, help_path);

  return (TRUE);
} /* init_help */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_help ()

{
  close_dbhelp ();

  return (TRUE);
} /* term_help */

/*****************************************************************************/
/* ™ffnen der Hilfe-Datenbank                                                */
/*****************************************************************************/

GLOBAL BOOLEAN open_dbhelp (help_name, help_path)
BYTE *help_name, *help_path;

{
  LONGSTR    s;
  FULLNAME   basename, basepath;
  TABLE_INFO table_info;
  WINDOWP    window;
  BOOLEAN    mode;

  if (help_path == NULL) help_path = app_path;
  strcpy (basename, help_name);
  strcpy (basepath, help_path);

  window = search_window (CLASS_HELP, SRCH_ANY, NIL);
  if (window != NULL) window->flags |= WI_LOCKED;

  mode = set_alert (TRUE);      /* alert boxes as dialog boxes */
  busy_mouse ();
  close_dbhelp ();              /* only one database at a given time */

  helpdb = db_open (basename, basepath, BASE_MULTASK | BASE_RDONLY, CACHE_SIZE, NUM_CURSORS, "", "");
  if (helpdb == NULL) helpdb = db_open (basename, act_path, BASE_MULTASK | BASE_RDONLY, CACHE_SIZE, NUM_CURSORS, "", "");

  if (helpdb != NULL)
  {
    db_tableinfo (helpdb, TBL_HELP, &table_info);

    if (strcmp (table_info.name, HELP_NAME) != 0)
    {
      close_dbhelp ();
      sprintf (s, alerts [ERR_NOHELPBASE], basename);
      open_alert (s);
    } /* if */
    else
    {
      helpbuf = mem_alloc (table_info.size);

      if (helpbuf == NULL)
      {
        sprintf (s, alerts [ERR_NOHELPMEM], basename);
        open_alert (s);
        db_close (helpdb);
        helpdb       = NULL;
        helpname [0] = EOS;
        helppath [0] = EOS;
      } /* if */
      else
      {
        strcpy (helpname, basename);
        strcpy (helppath, basepath);
        helpcursor = db_newcursor (helpdb);
        db_initcursor (helpdb, TBL_HELP, 1, ASCENDING, helpcursor);
      } /* else */
    } /* else */
  } /* if */
  else
    if (db_status (helpdb) != SUCCESS)
    {
      sprintf (s, alerts [ERR_NOHELPOPEN], basename);
      open_alert (s);
    } /* if, else */

  stackp = 0;

  set_meminfo ();
  arrow_mouse ();
  set_alert (mode);

  if (window != NULL) window->flags &= ~ WI_LOCKED;

  return (helpdb != NULL);
} /* open_dbhelp */

/*****************************************************************************/
/* Schliežen der Hilfe-Datenbank                                             */
/*****************************************************************************/

GLOBAL BOOLEAN close_dbhelp (VOID)

{
  BOOLEAN ok;

  ok = TRUE;

  if (helpbuf != NULL) mem_free (helpbuf);

  if (helpdb != NULL)
  {
    busy_mouse ();
    if (helpcursor != NULL) db_freecursor (helpdb, helpcursor);
    ok = db_close (helpdb);
    arrow_mouse ();
  } /* if */

  helpdb       = NULL;
  helpbuf      = NULL;
  helpname [0] = EOS;
  helppath [0] = EOS;

  set_meminfo ();

  return (ok);
} /* close_dbhelp */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_help (help_name, help_path, help_msg)
BYTE *help_name, *help_path, *help_msg;

{
  BOOLEAN ok, different;
  WINDOWP window;
  WORD    diff, w, h;

  ok        = TRUE;
  different = (strcmp (help_name, helpname) != 0) || (strcmp (help_path, helppath) != 0);

  if (different) ok = open_dbhelp (help_name, help_path);

  if (ok)
  {
    if ((window = search_window (CLASS_HELP, SRCH_OPENED, NIL)) != NULL)
    {
      if (different)
      {
        strcpy (window->name, FREETXT (FHELPNAM));
        if (helpname [0] != EOS) sprintf (window->name + strlen (window->name), "- %s ", helpname);
        wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
      } /* if */
      else
        push (helpbuf->address, window->doc.x, window->doc.y);

      fetch_data (window, help_msg, 0L);
      top_window (window);
      set_redraw (window, &window->scroll);
    } /* if */
    else
    {
      if ((window = search_window (CLASS_HELP, SRCH_CLOSED, NIL)) == NULL)
        window = crt_help (NULL, helpmenu, NIL);

      ok = window != NULL;

      if (ok)
      {
        stackp = 0;
        fetch_data (window, help_msg, 0L);

        w    = desk.w / window->xfac - 8;
        diff = min (window->doc.w + 2, w) - window->scroll.w / window->xfac;
        if (diff > 0)
        {
          diff             *= window->xfac;
          window->scroll.x -= diff;
          window->scroll.w += diff;
          window->work.x   -= diff;
          window->work.w   += diff;
        } /* if */

        h    = desk.h / window->yfac - 5;
        diff = min (window->doc.h, h) - window->scroll.h / window->yfac;
        if (diff > 0)
        {
          diff             *= window->yfac;
          window->scroll.y -= diff;
          window->scroll.h += diff;
          window->work.y   -= diff;
          window->work.h   += diff;
        } /* if */

        ok = open_window (window);

        if (! ok) hndl_alert (ERR_NOOPEN);
      } /* if */
    } /* else */
  } /* if */

  return (ok);
} /* open_help */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

LOCAL WINDOWP crt_help (obj, menu, icon)
OBJECT *obj, *menu;
WORD   icon;

{
  WINDOWP window;
  WORD    menu_height;

  window = create_window (KIND, CLASS_HELP);

  if (window != NULL)
  {
    menu_height = (menu != NULL) ? gl_hattr : 0;

    wind_calc (WC_WORK, KIND, desk.x + desk.w - INITW, desk.y + desk.h - INITH, INITW, INITH,
               &window->scroll.x, &window->scroll.y, &window->scroll.w, &window->scroll.h);

    window->scroll.x &= 0xFFF8;
    window->scroll.y += odd (window->scroll.y + menu_height);
    window->scroll.w  = window->scroll.w / XFAC * XFAC;
    window->scroll.h  = window->scroll.h / YFAC * YFAC;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = 0;
    window->doc.h     = 0;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->work.x    = window->scroll.x - XOFFSET;
    window->work.y    = window->scroll.y - YOFFSET - menu_height;
    window->work.w    = window->scroll.w + XOFFSET;
    window->work.h    = window->scroll.h + YOFFSET + menu_height;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = 0;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = handle_menu;
    window->updt_menu = update_menu;
    window->test      = NULL;
    window->open      = wi_open;
    window->close     = wi_close;
    window->delete    = NULL;
    window->draw      = wi_draw;
    window->arrow     = wi_arrow;
    window->snap      = wi_snap;
    window->objop     = NULL;
    window->drag      = NULL;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->top       = NULL;
    window->untop     = NULL;
    window->edit      = NULL;
    window->showinfo  = info_help;
    window->showhelp  = help_help;

    strcpy (window->name, FREETXT (FHELPNAM));
    if (helpname [0] != EOS) sprintf (window->name + strlen (window->name), "- %s ", helpname);
  } /* if */

  return (window);                      /* Fenster zurckgeben */
} /* crt_help */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

LOCAL BOOLEAN info_help (window, icon)
WINDOWP window;
WORD    icon;

{
  WORD    ret;
  BOOLEAN ok;

  window = search_window (CLASS_DIALOG, SRCH_ANY, HABOUT);

  if (window == NULL)
  {
    form_center (habout, &ret, &ret, &ret, &ret);
    window = crt_dialog (habout, NULL, HABOUT, FREETXT (FHABOUT), WI_MODELESS);
  } /* if */

  if (window != NULL)
    if (open_dialog (HABOUT))
      window->flags &= ~ WI_LOCKED;
    else
    {
      delete_window (window);
      habout->ob_spec = 0x00021100L;
      hndl_dial (habout, 0, FALSE, TRUE, NULL, &ok);
      habout->ob_spec = 0x00001100L;
    } /* else, if */

  return (TRUE);
} /* info_help */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

LOCAL BOOLEAN help_help (window, icon)
WINDOWP window;
WORD    icon;

{
  return ((helpdb == NULL) ? FALSE : open_help (helpname, helppath, (BYTE *)helpinx [HHELP].ob_spec));
} /* help_help */

/*****************************************************************************/

LOCAL VOID fetch_data (window, helpmsg, address)
WINDOWP window;
BYTE    *helpmsg;
LONG    address;

{
  STRING  index;
  LONGSTR s;

  busy_mouse ();

  window->doc.x = window->doc.y = 0;

  if (address == 0)
  {
    strcpy (helpbuf->index, helpmsg);

    if (! db_search (helpdb, TBL_HELP, 1, ASCENDING, helpcursor, helpbuf, 0L))
    {
      strncpy (index, helpmsg, 27);
      index [27] = EOS;
      sprintf (s, alertmsg [NOHLPINX], index);
      beep ();
      form_alert (1, s);
    } /* if */
  } /* if */

  if (! db_read (helpdb, TBL_HELP, helpbuf, helpcursor, address, FALSE))
  {
    db_fillnull (helpdb, TBL_HELP, helpbuf);
    helpbuf->address = 0;
  } /* if */

  calc_slider (window, window->scroll.w);
  set_sliders (window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);
  arrow_mouse ();
} /* fetch_data */

/*****************************************************************************/

LOCAL VOID calc_slider (window, width)
WINDOWP window;
WORD    width;

{
  WORD    w, len, cols, lines, eff, num_eff;
  BYTE    *p;
  LONGSTR s;

  eff  = TXT_NORMAL;
  w    = width / window->xfac;
  cols = lines = 0;
  p    = helpbuf->text;

  while ((p = get_line (p, s, w, &eff, &num_eff)) != NULL)
  {
    len  = strlen (s) - num_eff * 2;
    cols = max (cols, len);
    lines++;
  } /* while */

  window->doc.w = cols;
  window->doc.h = lines;
} /* calc_slider */

/*****************************************************************************/

LOCAL VOID blink_word (window, r)
WINDOWP window;
RECT    *r;

{
  WORD i;
  WORD xy [4];
  RECT rect, r1;

  rect = *r;

  if (rc_intersect (&window->scroll, &rect))
  {
    hide_mouse ();
    vswr_mode (vdi_handle, MD_XOR);
    vsf_interior (vdi_handle, FIS_SOLID);
    vsf_color (vdi_handle, BLACK);

    for (i = 0; i < 2 * blinkrate; i++)
    {
      wind_get (window->handle, WF_FIRSTXYWH, &r1.x, &r1.y, &r1.w, &r1.h);

      while ((r1.w != 0) && (r1.h != 0))
      {
        if (rc_intersect (&rect, &r1))
        {
          set_clip (TRUE, &r1);
          rect2array (&r1, xy);
          vr_recfl (vdi_handle, xy);
        } /* if */

        wind_get (window->handle, WF_NEXTXYWH, &r1.x, &r1.y, &r1.w, &r1.h);
      } /* while */

#if GEM & XGEM
      evnt_timer (10, 0);
#else
      evnt_timer (50, 0);
#endif
    } /* for */

    show_mouse ();
  } /* if */
} /* blink_word */

/*****************************************************************************/

LOCAL BYTE *get_line (p, s, w, eff, num_eff)
BYTE *p, *s;
WORD w;
WORD *eff, *num_eff;

{
  REG WORD i, c;

  i = 0;
  if (num_eff != NULL) *num_eff = 0;

  if ((p == NULL) || (*p == EOS))
    p = NULL;
  else
  {
    while ((*p != EOS) && (*p != '\n') && (! autowrap || (i < w)))
    {
      c = *p++;

      if (c != '\r')
      {
        if (c == EFFECT_CHAR)
        {
          if (num_eff != NULL) (*num_eff)++;
          if (eff != NULL) *eff = code2effect (*p, *eff);
          w += 2;                       /* width can now be larger */
        } /* if */

        if (c == '\t')
        {
          while ((i < LONGSTRLEN) && (i % 8 != 7)) s [i++] = SP;
          c = SP;
        } /* if */

        s [i++] = c;
      } /* if */
    } /* while */

    if (*p == '\n') p++;                /* move behind '\n' */
  } /* else */

  s [i] = EOS;

  return (p);
} /* get_line */

/*****************************************************************************/

LOCAL WORD code2effect (code, effect)
WORD code, effect;

{
  switch (code)
  {
    case O_B_BOLDFACE   : effect |=   TXT_THICKENED;  break;
    case O_E_BOLDFACE   : effect &= ~ TXT_THICKENED;  break;
    case O_B_ITALICS    : effect |=   TXT_SKEWED;     break;
    case O_E_ITALICS    : effect &= ~ TXT_SKEWED;     break;
    case O_B_UNDERSCORE : effect |=   TXT_UNDERLINED; break;
    case O_E_UNDERSCORE : effect &= ~ TXT_UNDERLINED; break;
    case O_B_EXPANDED   : effect |=   TXT_OUTLINED;   break;
    case O_E_EXPANDED   : effect &= ~ TXT_OUTLINED;   break;
    case O_B_LIGHT      : effect |=   TXT_LIGHT;      break;
    case O_E_LIGHT      : effect &= ~ TXT_LIGHT;      break;
    case O_B_HEADLINE   : effect |=   TXT_SHADOWED;   break;
    case O_E_HEADLINE   : effect &= ~ TXT_SHADOWED;   break;
  } /* switch */

  return (effect);
} /* code2effect */

/*****************************************************************************/

LOCAL VOID push (address, x, y)
LONG address, x, y;

{
  if (helpbuf->address != 0)
    if (stackp < MAX_STACK)
    {
      stack [stackp].address = address;
      stack [stackp].x       = x;
      stack [stackp++].y     = y;
    } /* if, if */
} /* push */

/*****************************************************************************/

LOCAL VOID pull (address, x, y)
LONG *address, *x, *y;

{
  *address = stack [--stackp].address;
  *x       = stack [stackp].x;
  *y       = stack [stackp].y;
} /* pull */

/*****************************************************************************/

LOCAL VOID update_menu (window)
WINDOWP window;

{
  menu_enable (helpmenu, MHINFO, helpdb != NULL);
  menu_enable (helpmenu, MHELPINF, helpdb != NULL);

  menu_enable (helpmenu, MHCLOSED, helpdb != NULL);
#if 0
  menu_enable (helpmenu, MHPRINT,  (helpdb != NULL) && (window->doc.h > 0));
#endif

  menu_enable (helpmenu, MHEDIT, helpdb != NULL);
  menu_enable (helpmenu, MHUNDO,   (helpdb != NULL) && (stackp > 0));
  menu_enable (helpmenu, MHNEXT,   (helpdb != NULL) && ! db_islast (helpdb, helpcursor));
  menu_enable (helpmenu, MHPREV,   (helpdb != NULL) && ! db_isfirst (helpdb, helpcursor));

  menu_enable (helpmenu, MHHELP, helpdb != NULL);
  menu_enable (helpmenu, MHUSEHLP, helpdb != NULL);
  menu_enable (helpmenu, MHCONTEN, helpdb != NULL);
} /* update_menu */

/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  LONG     address, x, y;
  FULLNAME filename, basename, basepath;
  EXT      ext;

  if (window != NULL)
    menu_normal (window, title, FALSE);         /* Titel invers darstellen */

  switch (title)
  {
    case MHINFO   : switch (item)
                    {
                      case MHELPINF : info_help (window, NIL); break;
                    } /* switch */
                    break;
    case MHFILE   : switch (item)
                    {
                      case MHOPENDB : filename [0] = EOS;

                                      if (get_open_filename (FOPENDB, NULL, 0L, FFILTER_IND, NULL, NULL, FINDSUFF, filename, NULL))
                                      {
                                        file_split (filename, NULL, basepath, basename, ext);

                                        if (! open_help (basename, basepath, helpcontents))
                                        {
                                          update_menu (window);
                                          draw_mbar (window);
                                          mem_set (&window->doc, 0, sizeof (LRECT));
                                          set_redraw (window, &window->scroll);
                                        } /* if */
                                      } /* if */
                                      break;
                      case MHCLOSED : close_dbhelp ();
                                      menu_normal (window, title, TRUE);
                                      close_window (window);
                                      window = NULL;    /* don't update menu */
                                      break;
#if 0
                      case MHPRINT  : break;
#endif
                    } /* switch */
                    break;
    case MHEDIT   : switch (item)
                    {
                      case MHUNDO : pull (&address, &x, &y);
                                    fetch_data (window, NULL, address);
                                    window->doc.x = x;
                                    window->doc.y = y;
                                    db_search (helpdb, TBL_HELP, 1, ASCENDING, helpcursor, helpbuf, address);
                                    set_sliders (window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);
                                    set_redraw (window, &window->scroll);
                                    break;
                      case MHNEXT :
                      case MHPREV : push (helpbuf->address, window->doc.x, window->doc.y);
                                    if (db_movecursor (helpdb, helpcursor, (item == MHNEXT) ? (LONG)ASCENDING : (LONG)DESCENDING))
                                      if ((address = db_readcursor (helpdb, helpcursor, NULL)) != 0)
                                      {
                                        fetch_data (window, NULL, address);
                                        set_redraw (window, &window->scroll);
                                      } /* if, if */
                                    break;
                    } /* switch */
                    break;
    case MHHELP   : switch (item)
                    {
                      case MHUSEHLP : help_help (window, NIL);
                                      break;
                      case MHCONTEN : open_help (helpname, helppath, helpcontents);
                                      break;
                    } /* switch */
                    break;
  } /* switch */

  if (window != NULL)
    menu_normal (window, title, TRUE);          /* Titel wieder normal darstellen */
} /* handle_menu */

/*****************************************************************************/
/* ™ffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  draw_growbox (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieže Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  LONG    i;
  WORD    x, y, w, h, lines, ret;
  WORD    eff, num_eff;
  WORD    j, xoffset, maxlen, pos, xpos;
  BYTE    *p, *q;
  RECT    new;
  LONGSTR s, line;

  clr_top (window);
  clr_left (window);
  clr_scroll (window);
  if (helpbuf == NULL) return;

  text_default (vdi_handle);
  vst_height (vdi_handle, gl_hchar, &ret, &ret, &ret, &ret);

  x = window->scroll.x;
  y = window->scroll.y;
  w = window->scroll.w / window->xfac;
  h = window->scroll.h;

  if (window->scroll.x + window->scroll.w == clip.x + clip.w)
  {
    new    = clip;
    new.w += window->xfac;
    set_clip (TRUE, &new);              /* for faster text blitting */
  } /* if */

  p   = helpbuf->text;
  eff = TXT_NORMAL;

  for (lines = 0; lines < window->doc.y; lines++) p = get_line (p, s, w, &eff, NULL);

  for (i = window->doc.y; (i < window->doc.h) && (y - window->scroll.y < h); i++, y += window->yfac)
  {
    p = get_line (p, s, w, NULL, &num_eff);

    if (num_eff == 0)                   /* fast special case */
    {
      vst_effects (vdi_handle, eff);
      s [window->doc.x + w] = EOS;

      if (y + window->yfac > clip.y)
        if (strlen (s) > window->doc.x)
          v_text (vdi_handle, x, y, s + window->doc.x);
    } /* if */
    else
    {
      q       = s;
      xoffset = 0;

      while (*q != EOS)
      {
        j = 0;
        while ((*q != EOS) && (*q != EFFECT_CHAR)) line [j++] = *q++;
        line [j] = EOS;

        if (j != 0)
        {
          if ((eff & (TXT_THICKENED | TXT_UNDERLINED)) == (TXT_THICKENED | TXT_UNDERLINED))
          {
            vst_color (vdi_handle, DGREEN);
            if (colors > 8) eff &= ~ TXT_THICKENED;     /* green instead of thickened */
          } /* if */
          else
            if (eff & TXT_SHADOWED)
            {
#if GEMDOS
              vst_color (vdi_handle, BLUE);
#else
              vst_color (vdi_handle, DBLUE);
#endif
              eff &= ~ TXT_SHADOWED;                    /* blue instead of shadowed */
            } /* if */

          vst_effects (vdi_handle, eff);

          maxlen = window->doc.x + w - xoffset;
          maxlen = max (0, maxlen);
          line [maxlen] = EOS;

          if (y + window->yfac > clip.y)
            if (xoffset + strlen (line) > window->doc.x)
            {
              pos  = window->doc.x - xoffset;
              pos  = max (0, pos);
              xpos = xoffset - window->doc.x;
              xpos = max (0, xpos);
              v_text (vdi_handle, x + xpos * window->xfac, y, line + pos);
            } /* if, if */

          xoffset += j;
        } /* if */

        if (*q == EFFECT_CHAR)                  /* handle effects */
        {
          q++;
          eff = code2effect (*q++, eff);
        } /* if */

        vst_color (vdi_handle, BLACK);          /* restore color */
      } /* while */
    } /* else */
  } /* for */
} /* wi_draw */

/*****************************************************************************/
/* Reagiere auf Pfeile                                                       */
/*****************************************************************************/

LOCAL VOID wi_arrow (window, dir, oldpos, newpos)
WINDOWP window;
WORD    dir;
LONG    oldpos, newpos;

{
  LONG delta;

  delta = newpos - oldpos;

  if (dir & HORIZONTAL)         /* Horizontale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling n”tig */
    {
      window->doc.x = newpos;                   /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);  /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                          /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling n”tig */
    {
      window->doc.y = newpos;                   /* Neue Position */

      set_sliders (window, VERTICAL, SLPOS);    /* Schieber setzen */
      scroll_window (window, VERTICAL, delta * window->yfac);
    } /* if */
  } /* else */
} /* wi_arrow */

/*****************************************************************************/
/* Einrasten des Fensters                                                    */
/*****************************************************************************/

LOCAL VOID wi_snap (window, new, mode)
WINDOWP window;
RECT    *new;
WORD    mode;

{
  RECT r, diff;
  WORD wbox, hbox;
  LONG max_xdoc, max_ydoc;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) / wbox * wbox;        /* Differenz berechnen */
  diff.y = (new->y - r.y) & 0xFFFE;
  diff.w = (new->w - r.w) / wbox * wbox;
  diff.h = (new->h - r.h) / hbox * hbox;

  if (wbox == 8) new->x = r.x + diff.x;         /* Schnelle Position */
  new->y = r.y + diff.y;                        /* Y immer gerade */
  new->w = r.w + diff.w;                        /* Arbeitsbereich einrasten */
  new->h = r.h + diff.h;

  if (mode & SIZED)
  {
    r.w      = (window->scroll.w + diff.w) / wbox; /* Neuer Scrollbereich */
    max_xdoc = window->doc.w - r.w;
    r.h      = (window->scroll.h + diff.h) / hbox;
    max_ydoc = window->doc.h - r.h;

    if (max_xdoc < 0) max_xdoc = 0;
    if (max_ydoc < 0) max_ydoc = 0;

    if (window->doc.x > max_xdoc)               /* Jenseits rechter Bereich */
    {
      set_redraw (window, &window->work);       /* Wegen smart redraw */
      window->doc.x = max_xdoc;
    } /* if */

    if (window->doc.y > max_ydoc)               /* Jenseits unterer Bereich */
    {
      set_redraw (window, &window->work);       /* Wegen smart redraw */
      window->doc.y = max_ydoc;
    } /* if */

    if (autowrap)
    {
      calc_slider (window, r.w * wbox);
      set_redraw (window, &window->scroll);
    } /* if */
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE    *p, *q;
  BOOLEAN ready;
  LONG    i;
  WORD    y, w, h, xoffset;
  WORD    j, eff, num_eff, lines;
  LONGSTR s, line;
  RECT    r;

  if ((helpdb != NULL) && inside (mk->mox, mk->moy, &window->scroll))
  {
    y   = window->scroll.y;
    w   = window->scroll.w / window->xfac;
    h   = window->scroll.h;
    p   = helpbuf->text;
    eff = TXT_NORMAL;

    for (lines = 0; lines < window->doc.y; lines++) p = get_line (p, s, w, &eff, NULL);

    for (ready = FALSE, i = window->doc.y; ! ready && (i < window->doc.h) && (y - window->scroll.y < h); i++, y += window->yfac)
    {
      p = get_line (p, s, w, NULL, &num_eff);

      if (num_eff != 0)
      {
        q       = s;
        xoffset = 0;

        while (*q != EOS)
        {
          j = 0;
          while ((*q != EOS) && (*q != EFFECT_CHAR)) line [j++] = *q++;
          line [j] = EOS;

          if (j != 0)
          {
            if ((eff & (TXT_THICKENED | TXT_UNDERLINED)) == (TXT_THICKENED | TXT_UNDERLINED))
            {
              r.x = window->scroll.x + (xoffset - window->doc.x) * window->xfac;
              r.y = y;
              r.w = strlen (line) * gl_wbox;
              r.h = gl_hbox;

              if (inside (mk->mox, mk->moy, &r))
              {
                blink_word (window, &r);
                ready = TRUE;
                push (helpbuf->address, window->doc.x, window->doc.y);
                fetch_data (window, line, 0L);
                set_redraw (window, &window->scroll);
              } /* if */
            } /* if */

            xoffset += j;
          } /* if */

          if (*q == EFFECT_CHAR)                /* handle effects */
          {
            q++;
            eff = code2effect (*q++, eff);
          } /* if */
        } /* while */
      } /* if */
    } /* for */
  } /* if */
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
} /* wi_unclick */

/*****************************************************************************/
/* Taste fr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if ((mk->scan_code == UNDO) || (mk->ascii_code == ESC)) /* UNDO means Control-Z */
  {
    mk->ascii_code = SUB;
    mk->ctrl       = TRUE;
  } /* if */

  if (menu_key (window, mk)) return (TRUE);

  return (FALSE);
} /* wi_key */

