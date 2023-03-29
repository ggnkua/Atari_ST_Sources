/*****************************************************************************
 *
 * Module : BASE.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 14.12.94
 *
 *
 * Description: This module implements the base window.
 *
 * History:
 * 14.12.94: Value of newtable [NTSB] fixed in init_base
 * 29.09.94: Show also relation type (1:1, 1:n) in draw_rels
 * 15.09.94: Arrows in draw_rels are painted independently of the rule
 * 18.11.93: GetFontDialog used instead of mselfont
 * 25.10.93: Test on BASE_RDONLY in test_base added
 * 14.09.93: datacache & treecache used
 * 09.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 08.09.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "clipbrd.h"
#include "commdlg.h"
#include "desktop.h"
#include "dialog.h"
#include "mfile.h"
/*#include "mselfont.h"*/
#include "mselsize.h"
#include "mselect.h"
#include "mask.h"

#include "baccess.h"
#include "bcif.h"
#include "bclick.h"
#include "bdbinfo.h"
#include "bdelrule.h"
#include "bformat.h"
#include "bicons.h"
#include "bload.h"
#include "bnfield.h"
#include "bnkey.h"
#include "bntable.h"
#include "bparams.h"
#include "btblinfo.h"
#include "btxt.h"

#include "export.h"
#include "base.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_MOUSE|WI_CURSKEYS)
#define XFAC   gl_wbox                  /* X-Faktor */
#define YFAC   gl_hbox                  /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fÅr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fÅr Scrolling */
#define INITX  (1 * gl_wbox)            /* X-Anfangsposition */
#define INITY  (3 * gl_hbox)            /* Y-Anfangsposition */
#define INITW  (desk.w - 4 * gl_wbox)   /* Anfangsbreite in Pixel */
#define INITH  (desk.h - 8 * gl_hbox)   /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define KEY_ATTRIBUTE TXT_THICKENED     /* use thick fonts for marking key fields */
#define NEW_SIZE      16                /* data & tree size for new dbs */
#define REL_1         '1'               /* relation type 1:1 */
#define REL_N         'n'               /* relation type 1:n */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD iconwidth;	/* width of iconbar */
LOCAL WORD iconheight;	/* height of iconbar */
LOCAL WORD menu_height;	/* height of menu */

/****** FUNCTIONS ************************************************************/

#if GEMDOS
EXTERN VOID vdi _((VOID));
#endif

LOCAL WORD    get_wbox      _((WORD out_handle, WORD c));
LOCAL VOID    set_factor    _((WINDOWP window));
LOCAL VOID    draw_base     _((WINDOWP window, WORD out_handle, WORD wbox, WORD hbox));
LOCAL VOID    draw_rels     _((WINDOWP window, WORD out_handle, WORD wbox, WORD hbox));
LOCAL VOID    draw_lookups  _((WINDOWP window, WORD out_handle, WORD wbox, WORD hbox));
LOCAL BOOLEAN test_base     _((WINDOWP window));
LOCAL VOID    obj_selall    _((WINDOWP window));

LOCAL VOID    update_menu   _((WINDOWP window));
LOCAL VOID    handle_menu   _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow));
LOCAL BOOLEAN wi_test       _((WINDOWP window, WORD action));
LOCAL VOID    wi_open       _((WINDOWP window));
LOCAL VOID    wi_close      _((WINDOWP window));
LOCAL VOID    wi_delete     _((WINDOWP window));
LOCAL VOID    wi_draw       _((WINDOWP window));
LOCAL VOID    wi_arrow      _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap       _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop      _((WINDOWP window, SET objs, WORD ACTION));
LOCAL WORD    wi_drag       _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick    _((WINDOWP window));
LOCAL BOOLEAN wi_key        _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer      _((WINDOWP window));
LOCAL VOID    wi_top        _((WINDOWP window));
LOCAL VOID    wi_untop      _((WINDOWP window));
LOCAL VOID    wi_edit       _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_base ()

{
  WORD obj;

  init_newkey ();

  obj = ROOT;

  do
  {
    if (is_type (dbicons, obj, G_BUTTON))
      dbicons [obj].ob_y = 4;
  } while (! is_flags (dbicons, obj++, LASTOB));

  dbicons [ROOT].ob_width  = dbicons [1].ob_width  = desk.w;
  dbicons [ROOT].ob_height = dbicons [1].ob_height = dbicons [DBARROW].ob_y + dbicons [DBARROW].ob_height + 4;

  iconwidth  = dbicons->ob_width;
  iconheight = dbicons->ob_height + 1;


  newtable [NTSB].ob_x += 2;	/* looks better */

  return (TRUE);
} /* init_base */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_base ()

{
  return (TRUE);
} /* term_base */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_base (obj, menu, icon, basename, base_spec, doc, work)
OBJECT    *obj, *menu;
WORD      icon;
BYTE      *basename;
BASE_SPEC *base_spec;
LRECT     *doc;
RECT      *work;

{
  WINDOWP   window;
  WORD      inx, i;
  WORD      err;
  FULLNAME  tmpname;
  BOOLEAN   ok, new, untitled;
  FULLNAME  path;
  FILENAME  filename;
  EXT       suffix;
  LONGSTR   s;
  WINDOWP   winds [MAX_GEMWIND];
  BASE_SPEC *new_spec;

  inx = num_windows (CLASS_BASE, SRCH_ANY, winds);

  if (inx == MAX_GEMWIND - 1)
  {
    hndl_alert (ERR_MAXDB);                     /* to many dbs open */
    return (NULL);
  } /* if */

  new      = (base_spec == NULL) || (base_spec->base == NULL);
  untitled = *basename == EOS;
  if (untitled)
  {
    strcpy (basename, db_path);
    strcat (basename, FREETXT (FNOTITLE));      /* UNTITLED */
  } /* if */

  file_split (basename, NULL, db_path, db_name, suffix);
  untitled = strcmp (FREETXT (FNOTITLE), db_name) == 0;
  sprintf (basename, "%s%s", db_path, db_name);
  strcat (db_name, FREETXT (FDATSUFF) + 1);
  strcpy (tmpname, basename);

  for (i = 0; i < inx; i++)                     /* test if db already open */
  {
    new_spec = (BASE_SPEC *)winds [i]->special;
    strcpy (path, new_spec->basepath);
    strcat (path, new_spec->basename);

    if (strcmp (path, tmpname) == 0)
    {
      hndl_alert (ERR_SAMEBASE);                /* db already open */
      return (NULL);
    } /* if */
  } /* for */

  new_spec = (BASE_SPEC *)mem_alloc ((LONG)sizeof (BASE_SPEC));
  if (new_spec == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  if ((base_spec != NULL) && (! base_spec->new))        /* use existing spec */
    *new_spec = *base_spec;
  else
  {
    mem_set (new_spec, 0, sizeof (BASE_SPEC));

    file_split (basename, NULL, path, filename, suffix);
    strcpy (new_spec->basepath, path);
    strcpy (new_spec->basename, filename);

    new_spec->new         = new;
    new_spec->untitled    = untitled;
    new_spec->reorg       = FALSE;
    new_spec->in_memory   = TRUE;
    new_spec->del_trash   = FALSE;
    new_spec->oflags      = 0;
    new_spec->cflags      = 0;
    new_spec->datasize    = NEW_SIZE;
    new_spec->treesize    = NEW_SIZE;
    new_spec->datacache   = 8;
    new_spec->treecache   = 8;
    new_spec->cursors     = 10;
    new_spec->first_table = NUM_SYSTABLES;
    new_spec->show_full   = TRUE;
    new_spec->show_short  = TRUE;
    new_spec->font        = g_font;
    new_spec->point       = g_point;

    if (base_spec != NULL)
    {
      new_spec->new       = FALSE;
      new_spec->untitled  = FALSE;
      new_spec->base      = base_spec->base;
      new_spec->oflags    = base_spec->oflags;
      new_spec->cflags    = base_spec->cflags;
      new_spec->datasize  = base_spec->datasize;
      new_spec->treesize  = base_spec->treesize;
      new_spec->datacache = base_spec->datacache;
      new_spec->treecache = base_spec->treecache;
      new_spec->cursors   = base_spec->cursors;
      new_spec->font      = base_spec->font;
      new_spec->point     = base_spec->point;
      strcpy (new_spec->username, base_spec->username);
      strcpy (new_spec->password, base_spec->password);
    } /* if */
  } /* else */

  if (new)
  {
    if (! b_new_base (new_spec))
    {
      hndl_alert (ERR_NOMEMORY);
      mem_free (new_spec);
      return (NULL);
    } /* if */
  } /* if */
  else
  {
    err = b_load_base (new_spec);

    if (err != SUCCESS)
    {
      if (err == ERR_SUPERUSER)
      {
        sprintf (s, alerts [ERR_SUPERUSER], new_spec->username);
        open_alert (s);
      } /* if */
      else
        hndl_alert (err);

      mem_free (new_spec);
      return (NULL);
    } /* if */
  } /* else */

  ok = make_maskfile (new_spec);

  if (! ok)
  {
    mem_free (new_spec);
    hndl_alert (ERR_MASKFILE);
    return (NULL);
  } /* if */

  new_spec->abort      = FALSE;
  new_spec->modified   = FALSE;
  new_spec->show_star  = FALSE;
  new_spec->reorg      = FALSE;
  new_spec->in_memory  = TRUE;          /* now all information is in memory */
  new_spec->x_factor   = 100;           /* original screen = 100% */
  new_spec->y_factor   = 100;
  new_spec->show_tools = TRUE;
  new_spec->show_rels  = (new_spec->num_lookups == 0) && (new_spec->num_rels > 0);
  new_spec->tool       = DBARROW;

  menu_check (basemenu, MBFULL, new_spec->show_full);
  menu_check (basemenu, MBBESTFI, ! new_spec->show_full);
  menu_check (basemenu, MBRELS, base_spec->show_rels);
  menu_check (basemenu, MBLOOKUP, ! base_spec->show_rels);
  menu_check (basemenu, MBSHORT, base_spec->show_short);
  menu_check (basemenu, MBLONG, ! base_spec->show_short);

  menu_check (basemenu, MBTOOLS, new_spec->show_tools);

  vst_font (vdi_handle, new_spec->font);
  vst_point (vdi_handle, new_spec->point, &i, &i, &new_spec->wbox, &new_spec->hbox);
  new_spec->wbox = get_wbox (vdi_handle, 'x');

  new_spec->hbox += BOX_LDIST * new_spec->y_factor / 100;

  window = create_window (KIND, CLASS_BASE);

  if (window != NULL)
  {
    if (doc == NULL)
    {
      window->doc.x = 0;
      window->doc.y = 0;
      window->doc.w = doc_width;
      window->doc.h = doc_height;
    } /* if */
    else
      window->doc = *doc;

    if (work == NULL)
    {
      window->work.x = INITX + inx * gl_wbox;
      window->work.y = INITY + inx * gl_hbox;
      window->work.w = (win_width  - inx) * gl_wbox;
      window->work.h = (win_height - inx) * gl_hbox;
    } /* if */
    else
      window->work = *work;

    menu_height = (menu != NULL) ? gl_hattr : 0;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->scroll.x  = window->work.x;
    window->scroll.y  = window->work.y + menu_height + iconheight;
    window->scroll.w  = window->work.w;
    window->scroll.h  = window->work.h - menu_height - iconheight;
    window->bg_color  = -1;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)new_spec;
    window->object    = obj;
    window->menu      = menu;
    window->hndl_menu = handle_menu;
    window->updt_menu = update_menu;
    window->test      = wi_test;
    window->open      = wi_open;
    window->close     = wi_close;
    window->delete    = wi_delete;
    window->draw      = wi_draw;
    window->arrow     = wi_arrow;
    window->snap      = wi_snap;
    window->objop     = wi_objop;
    window->drag      = wi_drag;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->top       = wi_top;
    window->untop     = NULL;
    window->edit      = wi_edit;
    window->showinfo  = info_base;
    window->showhelp  = help_base;

    sprintf (window->name, " %s ", basename);
    new_spec->doc = window->doc;
  } /* if */
  else
  {
    del_maskfile (new_spec);
    mem_free (new_spec);
  } /* else */

  set_meminfo ();

  return (window);                      /* Fenster zurÅckgeben */
} /* crt_base */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_base (icon, basename, base_spec)
WORD      icon;
BYTE      *basename;
BASE_SPEC *base_spec;

{
  BOOLEAN ok;
  WINDOWP window;

  busy_mouse ();

  if ((icon != NIL) && (window = search_window (CLASS_BASE, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_BASE, SRCH_CLOSED, icon)) == NULL)
      window = crt_base (NULL, basemenu, icon, basename, base_spec, NULL, NULL);

    ok = window != NULL;

    if (ok)
    {
      ok = open_window (window);
      if (! ok) hndl_alert (ERR_NOOPEN);
    } /* if */
    else
      if (base_spec != NULL) close_db (base_spec);
  } /* else */

  arrow_mouse ();

  return (ok);
} /* open_base */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_base (window, icon)
WINDOWP window;
WORD    icon;

{
  BASE_SPEC *base_spec;

  if (icon != NIL) window = search_window (CLASS_BASE, SRCH_ANY, icon);

  if (window != NULL)
  {
    base_spec = (BASE_SPEC *)window->special;

    if (base_spec->new)
      hndl_alert (ERR_NOINFO);
    else
      mdbinfo (base_spec);
  } /* if */

  return (window != NULL);
} /* info_base */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_base (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HBASE));
} /* help_base */

/*****************************************************************************/

GLOBAL BOOLEAN close_bases ()

{
  WORD    num, i, wh;
  WINDOWP windows [MAX_GEMWIND];

  num = num_windows (CLASS_BASE, SRCH_OPENED, windows);
  for (i = 0; i < num; i++)
  {
    wh = windows [i]->handle;
    close_window (windows [i]);
    if (find_window (wh) != NULL) return (FALSE);
  } /* for */

  return (TRUE);
} /* close_bases */

/*****************************************************************************/

GLOBAL VOID save_base (window)
WINDOWP window;

{
  BOOLEAN   ok;
  WORD      result;
  FULLNAME  filename;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  ok        = TRUE;

  if (! close_masks (base_spec)) return;

  if (base_spec->abort)
    if (! test_base (window))
    {
      base_spec->abort = FALSE;
      return;
    } /* if */

  busy_mouse ();

  if (! base_spec->abort) ok = b_save_base (window);

  if (! ok)
  {
    if (base_spec->new)
      hndl_alert (ERR_DBCREATE);
    else
      hndl_alert (ERR_DBSAVE);

    base_spec->abort = TRUE;
    close_window (window);
    arrow_mouse ();
    return;
  } /* if */

  if (base_spec->num_users > 0)
    strcpy (base_spec->username, base_spec->sysuser [0].name);

  del_maskfile (base_spec);
  close_db (base_spec);
  mem_free (base_spec->systable);
  set_meminfo ();

  strcpy (filename, base_spec->basepath);
  strcat (filename, base_spec->basename);

  base_spec->base = open_db (filename,
                             base_spec->oflags,
                             base_spec->datacache,
                             base_spec->treecache,
                             base_spec->cursors,
                             base_spec->username,
                             base_spec->password,
                             &result);

  if ((result == SUCCESS) || (result == DB_DNOTCLOSED))
  {
    if (result == DB_DNOTCLOSED) dberror (result, base_spec->basename);

    if (b_load_base (base_spec) != SUCCESS)
    {
      hndl_alert (ERR_DBOPEN);
      base_spec->abort = TRUE;
      close_window (window);
      arrow_mouse ();
      return;
    } /* if */

    base_spec->untitled  = FALSE;
    base_spec->abort     = FALSE;
    base_spec->modified  = FALSE;
    base_spec->show_star = FALSE;
    base_spec->in_memory = TRUE;
    base_spec->imask     = 0;

    ok = make_maskfile (base_spec);
    if (! ok)
    {
      hndl_alert (ERR_MASKFILE);
      close_window (window);
    } /* if */

    b_wi_title (window);
    set_redraw (window, &window->scroll);
    set_meminfo ();
  } /* if */
  else
    if (result != DB_DNOLOCK)
    {
      dberror (result, base_spec->basename);
      close_window (window);
    } /* if, else */

  arrow_mouse ();
} /* save_base */

/*****************************************************************************/

GLOBAL VOID print_base (window)
WINDOWP window;

{
  WORD      out_handle;
  WORD      wchar, hchar, wbox, hbox;
  WORD      pgwidth, pgheight;
  WORD      device;
  WORD      llx, lly, urx, ury;
  WINDOW    win;
  FULLNAME  meta_name;
  LONGSTR   s;
  DEVINFO   dev_info;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  if (print2meta)
    device = METAFILE;
  else
    device = PRINTER;

  out_handle = open_work (device, &dev_info);

  if (out_handle > 0)
  {
    busy_mouse ();

    if (device == METAFILE)
    {
      sprintf (meta_name, "%s%s", base_spec->basepath, base_spec->basename);
      strcat (meta_name, ".GEM");
      vm_filename (out_handle, meta_name);
    } /* if */

    vst_load_fonts (out_handle, 0);
    set_meminfo ();

    vst_font (out_handle, base_spec->font);
    vst_point (out_handle, base_spec->point, &wchar, &hchar, &wbox, &hbox);

    if (device == METAFILE)
    {
      vst_font (vdi_handle, base_spec->font);
      vst_point (vdi_handle, base_spec->point, &wchar, &hchar, &wbox, &hbox);
    } /* if */

    wbox  = get_wbox (out_handle, 'x');
    wbox  = wbox * base_spec->x_factor / 100;   /* make it a little bit smaller on proportional fonts */
    hbox += BOX_LDIST;

    base_spec->wbox = wbox;
    base_spec->hbox = hbox;

    win = *window;
    b_get_doc (base_spec, window->xfac, window->yfac, &win.doc.w, &win.doc.h);

    win.doc.x     = 0;
    win.doc.y     = 0;
    win.scroll.x  = 0;
    win.scroll.y  = 0;
    win.scroll.w  = dev_info.dev_w - 1;
    win.scroll.h  = dev_info.dev_h - 1;

    set_clip (TRUE, &win.scroll);

    if (device == METAFILE)
    {
      set_clip (FALSE, &win.scroll);

      device_info (vdi_handle, &dev_info);

      llx = 0;
      lly = win.doc.h * YFAC;
      urx = win.doc.w * XFAC;
      ury = 0;

      pgwidth  = (LONG)dev_info.pix_w * urx / 100; /* 1/10 mm */
      pgheight = (LONG)dev_info.pix_h * lly / 100;

      v_meta_extents (out_handle, 0, 0, urx, lly);
/*      vm_pagesize (out_handle, 1905, 2540); */          /* Letter size = 7,5 x 10.00 inches */
      vm_pagesize (out_handle, pgwidth, pgheight);
      vm_coords (out_handle, llx, lly, urx, ury);
    } /* if */

    draw_base (&win, out_handle, wbox, hbox);

    if (device != METAFILE)
    {
      v_updwk (out_handle);
      v_clrwk (out_handle);
    } /* if */

    vst_unload_fonts (out_handle, 0);
    close_work (device, out_handle);

    reset_basefont (window);
    set_meminfo ();
    arrow_mouse ();

    if (device == METAFILE)
    {
      sprintf (s, alerts [ERR_METAOK], meta_name);
      open_alert (s);
    } /* if */
  } /* if */
  else
    hndl_alert (ERR_OUTDEVICE);
} /* print_base */

/*****************************************************************************/

GLOBAL VOID reset_basefont (window)
WINDOWP window;

{
  WORD      wchar, hchar, wbox, hbox;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  vst_font (vdi_handle, base_spec->font);
  vst_point (vdi_handle, base_spec->point, &wchar, &hchar, &wbox, &hbox);
  vst_height (vdi_handle, hchar * base_spec->y_factor / 100, &wchar, &hchar, &wbox, &hbox);

  wbox = get_wbox (vdi_handle, 'x');
  base_spec->wbox = wbox;
  base_spec->hbox = hbox + BOX_LDIST * base_spec->y_factor / 100;
} /* reset_basefont */

/*****************************************************************************/

LOCAL WORD get_wbox (out_handle, c)
WORD out_handle;
WORD c;

{
  WORD cell_width;

#if GEMDOS                      /* error in TURBO_C on ATARI ST */
  intin [0]  = c;
  contrl [0] = 117;
  contrl [1] = 0;
  contrl [3] = 1;
  contrl [6] = out_handle;

  vdi ();

  cell_width = ptsout [0];
#else
  {
    WORD r;
    vqt_width (out_handle, (BYTE)c, &cell_width, &r, &r);
  }
#endif

 return (cell_width);
} /* get_wbox */

/*****************************************************************************/

LOCAL VOID set_factor (window)
WINDOWP window;

{
  LONG      doc_w, doc_h;
  WORD      factor;
  WORD      xfac, yfac;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  xfac = base_spec->x_factor = 100;
  yfac = base_spec->y_factor = 100;
  reset_basefont (window);

  b_get_doc (base_spec, window->xfac, window->yfac, &doc_w, &doc_h);

  if (doc_w != 0) xfac = 100L * window->scroll.w / (doc_w * window->xfac);
  if (doc_h != 0) yfac = 100L * window->scroll.h / (doc_h * window->yfac);

  factor = min (xfac, yfac);
  xfac   = factor;
  yfac   = factor;

  if (xfac > 100) xfac = 100;
  if (yfac > 100) yfac = 100;

  base_spec->x_factor = xfac;
  base_spec->y_factor = yfac;

  reset_basefont (window);
} /* set_factor */

/*****************************************************************************/

LOCAL VOID draw_base (window, out_handle, wbox, hbox)
WINDOWP window;
WORD    out_handle;
WORD    wbox, hbox;

{
  WORD       table, start, end;
  WORD       l, len, ret, obj;
  WORD       shadow_x, shadow_y;
  WORD       field;
  WORD       index, multi_index;
  WORD       xy [10];
  WORD       x, y, w, h;
  WORD       wchar, hchar;
  WORD       extent [8];
  WORD       max_w, box_ldist;
  WORD       attribute;
  RECT       r, old_clip;
  RECT       frame;
  STRING     s, size;
  INDEXNAME  name;
  BASE_SPEC  *base_spec;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  INDEX_INFO index_info;

  base_spec = (BASE_SPEC *)window->special;
  start     = base_spec->first_table;
  box_ldist = BOX_LDIST * base_spec->y_factor / 100;

  text_default (out_handle);
  vst_font (out_handle, base_spec->font);
  vst_point (out_handle, base_spec->point, &wchar, &hchar, &ret, &ret);
  if (out_handle == vdi_handle) vst_height (out_handle, hchar * base_spec->y_factor / 100, &ret, &ret, &ret, &ret);

  for (table = start; table < base_spec->num_tables; table++)
  {
    b_get_rect (window, SEL_TABLE, NIL, table, &r, FALSE, FALSE);
    rect2xywh (&r, &x, &y, &w, &h);
    b_get_rect (window, SEL_TABLE, NIL, table, &frame, TRUE, FALSE);
    b_get_rect (window, SEL_TABLE, NIL, table, &r, TRUE, TRUE);

    if (rc_intersect (&clip, &r))
    {
      v_tableinfo (base_spec, table, &table_info);

      multi_index = 0;

      for (index = 0; index < table_info.indexes; index++)      /* check multi indexes */
        if (v_indexinfo (base_spec, table, index, &index_info) != FAILURE)
          if (index_info.inxcols.size / sizeof (INXCOL) > 1) multi_index++;

      rect2array (&frame, xy);
      vswr_mode (out_handle, MD_REPLACE);
      vsf_interior (out_handle, FIS_SOLID);
      vsf_color (out_handle, WHITE);
      vr_recfl (out_handle, xy);

      line_default (out_handle);
      b_get_shadow (out_handle, wbox, base_spec->x_factor, &shadow_x, &shadow_y);

      if (colors > 8)
        vsf_color (out_handle, DWHITE);
      else
      {
        vsf_color (out_handle, BLACK);
        vsf_interior (out_handle, FIS_PATTERN);
        vsf_style (out_handle, 4);
      } /* else */

      xy [0] = frame.x + frame.w;
      xy [1] = frame.y + shadow_y;
      xy [2] = xy [0] + shadow_x - 1;
      xy [3] = xy [1] + frame.h - 1;
      vr_recfl (out_handle, xy);

      xy [0] = frame.x + shadow_x;
      xy [1] = frame.y + frame.h;
      xy [2] = xy [0] + frame.w - 1;
      xy [3] = xy [1] + shadow_y - 1;
      vr_recfl (out_handle, xy);

      xy [0] = frame.x;
      xy [1] = frame.y;
      xy [2] = xy [0] + frame.w - 1;
      xy [3] = xy [1];
      xy [4] = xy [2];
      xy [5] = xy [1] + frame.h - 1;
      xy [6] = xy [0];
      xy [7] = xy [5];
      xy [8] = xy [0];
      xy [9] = xy [1];

      line_default (out_handle);
      vsl_color (out_handle, base_spec->systable [table].color);
      v_pline (out_handle, 5, xy);                      /* draw box */

      xy [0] = frame.x + 1;
      xy [1] = y + hbox - box_ldist;
      xy [2] = xy [0] + frame.w - 1 - box_ldist;
      xy [3] = xy [1];

      v_pline (out_handle, 2, xy);                      /* draw table separator */

      if (multi_index > 0)
      {
        xy [0] = frame.x + 1;
        xy [1] = y + h - multi_index * hbox - box_ldist;
        xy [2] = xy [0] + frame.w - 3;
        xy [3] = xy [1];

        vsl_udsty (out_handle, 0xAAAA);
        vsl_type (out_handle, USERLINE);
        v_pline (out_handle, 2, xy);                    /* draw multikey separartor */
      } /* if */

      vst_effects (out_handle, TXT_THICKENED);
      vst_color (out_handle, base_spec->systable [table].color);
      vst_alignment (out_handle, ALI_CENTER, ALI_TOP, &ret, &ret);
      vqt_extent (out_handle, table_info.name, extent);
      l = extent [2] - extent [0];
      l = min (l, w);

      v_justified (out_handle, x + w / 2, y, table_info.name, l, 0, l >= w);
      y += hbox;

      vst_color (out_handle, BLACK);
      vst_alignment (out_handle, ALI_LEFT, ALI_TOP, &ret, &ret);

      for (field = 1; field < table_info.cols; field++)
      {
        if (v_fieldinfo (base_spec, table, field, &field_info) != FAILURE)
        {
          attribute = TXT_NORMAL;

          if (field_info.flags & COL_ISINDEX)   /* was a single index field */
          {
            attribute = KEY_ATTRIBUTE;
            index = find_index (base_spec, table, field);
            v_indexinfo (base_spec, table, index, &index_info);
            if (index_info.flags & INX_PRIMARY) attribute |= TXT_UNDERLINED;
          } /* if */

          vst_effects (out_handle, attribute);
          vqt_extent (out_handle, field_info.name, extent);
          l     = extent [2] - extent [0];
          len   = 2 + LEN_TYPE + (base_spec->show_short ? 0 : LEN_SIZE);        /* ' ' + "*" */
          max_w = w - len * wbox;

          if (l >= max_w)
            v_justified (out_handle, x, y, field_info.name, max_w, 0, TRUE);
          else
            v_gtext (out_handle, x, y, field_info.name);

          vst_effects (out_handle, TXT_NORMAL);
          str_type (field_info.type, s);
          vqt_extent (out_handle, s, extent);
          l     = extent [2] - extent [0];
          max_w = LEN_TYPE * wbox;

          if (l >= max_w)
            v_justified (out_handle, x + w - len * wbox + wbox, y, s, max_w, 0, TRUE);
          else
            v_gtext (out_handle, x + w - len * wbox + wbox, y, s);

          if (! base_spec->show_short)
          {
            size2str (&field_info, size);
            sprintf (s, "%*s", LEN_SIZE, size);
            vqt_extent (out_handle, s, extent);
            l     = extent [2] - extent [0];
            max_w = LEN_SIZE * wbox;

            if (l >= max_w)
              v_justified (out_handle, x + w - max_w - wbox, y, s, max_w, 0, TRUE);
            else
              v_gtext (out_handle, x + w - max_w - wbox, y, s);
          } /* if */

          if (field_info.flags & (INS_FLAG | MOD_FLAG)) /* new or modifyable field */
            v_gtext (out_handle, x + w - wbox, y, "*");

          y += hbox;
        } /* if */
      } /* for */

      if (multi_index > 0)
      {
        for (index = 0; index < table_info.indexes; index++)
          if (v_indexinfo (base_spec, table, index, &index_info) != FAILURE)
            if (index_info.inxcols.size / sizeof (INXCOL) > 1)  /* was multi index */
            {
              if (index_info.name [0] == EOS)
                strcpy (name, index_info.indexname);
              else
                strcpy (name, index_info.name);

              attribute = KEY_ATTRIBUTE;
              if (index_info.flags & INX_PRIMARY) attribute |= TXT_UNDERLINED;

              vst_effects (out_handle, attribute);
              vqt_extent (out_handle, name, extent);
              l = extent [2] - extent [0];

              if (l >= w)
                v_justified (out_handle, x, y, name, w, 0, TRUE);
              else
                v_gtext (out_handle, x, y, name);

              if (index_info.flags & (INS_FLAG | MOD_FLAG))     /* new key */
              {
                vst_effects (out_handle, TXT_NORMAL);
                v_gtext (out_handle, x + w - wbox, y, "*");
              } /* if */

              y += hbox;
            } /* if, if , for */
      } /* if */

      if (sel.class != SEL_NONE) /* invert selected objects */
      {
        old_clip = clip;
        start    = 0;

        switch (sel.class)
        {
          case SEL_TABLE : start = table;
                           end   = table + 1;
                           break;
          case SEL_FIELD : end = base_spec->num_columns; break;
          case SEL_KEY   : end = base_spec->num_indexes; break;
          default        : end = NIL;                    break;
        } /* switch */

        if (window == sel_window)
          if ((sel.class == SEL_TABLE) || (table == sel.table))
            for (obj = start; obj < end; obj++)
              if (setin (sel_objs, obj))
              {
                b_get_rect (window, sel.class, obj, table, &frame, TRUE, FALSE);

                if (rc_intersect (&clip, &frame))
                {
                  set_clip (TRUE, &frame);
                  rect2array (&frame, xy);
                  vswr_mode (out_handle, MD_XOR);
                  vsf_interior (out_handle, FIS_SOLID);
                  vsf_color (out_handle, BLACK);
                  vr_recfl (out_handle, xy);
                  set_clip (TRUE, &old_clip);
                } /* if */
              } /* if, for */
      } /* if */
    } /* if */
  } /* for */

  hbox -= box_ldist;

  if (base_spec->show_rels)
    draw_rels (window, out_handle, wbox, hbox);
  else
    draw_lookups (window, out_handle, wbox, hbox);
} /* draw_base */

/*****************************************************************************/

LOCAL VOID draw_rels (window, out_handle, wbox, hbox)
WINDOWP window;
WORD    out_handle;
WORD    wbox, hbox;

{
  WORD      i, class, obj;
  WORD      xy [8], x1, y1, x2, y2;
  STRING    rel_type;
  RECT      frame, ref_rect, rel_rect;
  SYSREL    *sysrel;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  line_default (out_handle);
  vsl_ends (out_handle, SQUARED, ARROWED);
  sysrel = base_spec->sysrel;
  strcpy (rel_type, " ");
  x1 = y1 = x2 = y2 = 0;

  for (i = 0; i < base_spec->num_rels; i++, sysrel++)    /* draw rel arrows */
    if ((sysrel->flags != 0) && ! (sysrel->flags & DEL_FLAG))
    {
      b_get_rect (window, SEL_TABLE, NIL, sysrel->reftable, &frame, TRUE, FALSE);
      class = inx2obj (base_spec, sysrel->reftable, sysrel->refindex, &obj);
      b_get_rect (window, class, obj, sysrel->reftable, &ref_rect, TRUE, FALSE);
      ref_rect.x = frame.x;
      ref_rect.w = frame.w;

      b_get_rect (window, SEL_TABLE, NIL, sysrel->reltable, &frame, TRUE, FALSE);
      class = inx2obj (base_spec, sysrel->reltable, sysrel->relindex, &obj);
      b_get_rect (window, class, obj, sysrel->reltable, &rel_rect, TRUE, FALSE);
      rel_rect.x = frame.x;
      rel_rect.w = frame.w;

      if ((rel_rect.x + rel_rect.w + 4 * wbox <= ref_rect.x) || /* arrow <- */
          (rel_rect.x < ref_rect.x + ref_rect.w + 4 * wbox))
      {
        xy [0] = ref_rect.x - 1;
        xy [1] = ref_rect.y + hbox / 2;
        xy [2] = xy [0] - 2 * wbox + 1;
        xy [3] = xy [1];
        xy [4] = xy [2];
        xy [5] = rel_rect.y + hbox / 2;
        xy [6] = rel_rect.x + rel_rect.w + 1;
        xy [7] = xy [5];

        x1 = xy [0] - wbox;
        y1 = xy [1] - hbox;
        x2 = xy [6] + 3 * wbox / 2;
        y2 = xy [7] - hbox;

        if (rel_rect.x > ref_rect.x)
        {
          xy [6] = rel_rect.x - 1;
          x2     = xy [6] - 3 * wbox;
        } /* if */
        else
          if (rel_rect.x + rel_rect.w + 4 * wbox > ref_rect.x)
          {
            xy [2] = rel_rect.x - 4 * wbox;
            xy [3] = xy [1];
            xy [4] = xy [2];
            xy [5] = rel_rect.y + hbox / 2;
            xy [6] = rel_rect.x - 1;
            xy [7] = xy [5];

            x2 = xy [6] - 3 * wbox;
          } /* else */
      } /* if */
      else
      {
        xy [0] = ref_rect.x + ref_rect.w;
        xy [1] = ref_rect.y + hbox / 2;
        xy [2] = xy [0] + 2 * wbox - 1;
        xy [3] = xy [1];
        xy [4] = xy [2];
        xy [5] = rel_rect.y + hbox / 2;
        xy [6] = rel_rect.x - 1;
        xy [7] = xy [5];

        x1 = xy [0] + wbox / 2;
        y1 = xy [1] - hbox;
        x2 = xy [6] - 3 * wbox;
        y2 = xy [7] - hbox;

        if (rel_rect.x + rel_rect.w < ref_rect.x + ref_rect.w)
        {
          xy [6] = rel_rect.x + rel_rect.w + 1;
          x2     = xy [6] + 3 * wbox;
        } /* if */
      } /* if */

      rel_type [0] = (sysrel->flags & REL_11) ? REL_1 : REL_N;

      vsl_color (out_handle, base_spec->systable [sysrel->reftable].color);
      vst_color (out_handle, base_spec->systable [sysrel->reftable].color);
      v_pline (out_handle, 4, xy);
      v_gtext (out_handle, x1, y1, "1");
      v_gtext (out_handle, x2, y2, rel_type);
    } /* if, for */
} /* draw_rels */

/*****************************************************************************/

LOCAL VOID draw_lookups (window, out_handle, wbox, hbox)
WINDOWP window;
WORD    out_handle;
WORD    wbox, hbox;

{
  WORD      i;
  WORD      xy [8];
  RECT      frame, ref_rect, rel_rect;
  SYSLOOKUP *syslookup;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  line_default (out_handle);
  vsl_ends (out_handle, SQUARED, ARROWED);
  vsl_type (out_handle, LONGDASH);
  syslookup = base_spec->syslookup;

  for (i = 0; i < base_spec->num_lookups; i++, syslookup++)     /* draw lookup arrows */
    if (syslookup->table >= 0)
    {
      b_get_rect (window, SEL_TABLE, NIL, syslookup->reftable, &frame, TRUE, FALSE);
      b_get_rect (window, SEL_FIELD, syslookup->refcolumn, syslookup->reftable, &ref_rect, TRUE, FALSE);
      ref_rect.x = frame.x;
      ref_rect.w = frame.w;

      b_get_rect (window, SEL_TABLE, NIL, syslookup->table, &frame, TRUE, FALSE);
      b_get_rect (window, SEL_FIELD, syslookup->column, syslookup->table, &rel_rect, TRUE, FALSE);
      rel_rect.x = frame.x;
      rel_rect.w = frame.w;

      if ((rel_rect.x + rel_rect.w + 4 * wbox <= ref_rect.x) || /* arrow <- */
          (rel_rect.x < ref_rect.x + ref_rect.w + 4 * wbox))
      {
        xy [0] = ref_rect.x - 1;
        xy [1] = ref_rect.y + hbox / 2;
        xy [2] = xy [0] - 2 * wbox + 1;
        xy [3] = xy [1];
        xy [4] = xy [2];
        xy [5] = rel_rect.y + hbox / 2;
        xy [6] = rel_rect.x + rel_rect.w + 1;
        xy [7] = xy [5];

        if (rel_rect.x > ref_rect.x)
          xy [6] = rel_rect.x - 1;
        else
          if (rel_rect.x + rel_rect.w + 4 * wbox > ref_rect.x)
          {
            xy [2] = rel_rect.x - 4 * wbox;
            xy [3] = xy [1];
            xy [4] = xy [2];
            xy [5] = rel_rect.y + hbox / 2;
            xy [6] = rel_rect.x - 1;
            xy [7] = xy [5];
          } /* else */
      } /* if */
      else
      {
        xy [0] = ref_rect.x + ref_rect.w;
        xy [1] = ref_rect.y + hbox / 2;
        xy [2] = xy [0] + 2 * wbox - 1;
        xy [3] = xy [1];
        xy [4] = xy [2];
        xy [5] = rel_rect.y + hbox / 2;
        xy [6] = rel_rect.x - 1;
        xy [7] = xy [5];

        if (rel_rect.x + rel_rect.w < ref_rect.x + ref_rect.w)
          xy [6] = rel_rect.x + rel_rect.w + 1;
      } /* if */

      vsl_color (out_handle, base_spec->systable [syslookup->reftable].color);
      v_pline (out_handle, 4, xy);
    } /* if, for */
} /* draw_lookups */

/*****************************************************************************/

LOCAL BOOLEAN test_base (window)
WINDOWP window;

{
  BOOLEAN   ok, can_save;
  WORD      button;
  LONGSTR   s;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  if (! close_masks (base_spec)) return (FALSE);

  ok       = TRUE;
  can_save = base_spec->new || ! (base_spec->base->datainf->flags & BASE_RDONLY);

  if (base_spec->modified  && can_save)
  {
    sprintf (s, alerts [ERR_NOTSAVED], base_spec->basename);
    button = open_alert (s);

    switch (button)
    {
      case 1 : base_spec->abort = FALSE;        /* yes, save database */
               if (base_spec->untitled) base_spec->abort = ! msave_as (window);
               break;
      case 2 : base_spec->abort = TRUE;         /* no, don't save database */
               break;
      case 3 : ok = FALSE;
               break;                           /* user clicked on CANCEL button */
    } /* switch */
  } /* if */

  return (ok);
} /* test_base */

/*****************************************************************************/
/* MenÅbehandlung                                                            */
/*****************************************************************************/

LOCAL VOID obj_selall (window)
WINDOWP window;

{
  WORD      table;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  if (window != sel_window) unclick_window (sel_window);
  sel_window = window;
  sel.class  = SEL_TABLE;
  setclr (sel_objs);
  for (table = base_spec->first_table; table < base_spec->num_tables; table++) setincl (sel_objs, table);
  set_redraw (window, &window->scroll);
} /* obj_selall */

/*****************************************************************************/

LOCAL VOID table_info (window)
WINDOWP window;

{
  WORD      table;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  for (table = 0; table < base_spec->num_tables; table++)
    if (setin (sel_objs, table)) btblinfo (base_spec, table);
} /* table_info */

/*****************************************************************************/

LOCAL VOID update_menu (window)
WINDOWP window;

{
  BOOLEAN   can_format;
  BOOLEAN   can_delrule;
  BOOLEAN   card_one;
  BASE_SPEC *base_spec;

  base_spec   = (BASE_SPEC *)window->special;
  card_one    = (window == sel_window) && (setcard (sel_objs) == 1);
  can_format  = card_one && (sel.field >= 0);
  can_delrule = (window == sel_window) && mtestrules (base_spec, sel.class, sel_objs);

  if (base_spec->modified && ! base_spec->show_star)
  {
    base_spec->show_star = TRUE;
    b_wi_title (window);
  } /* if */

  menu_enable (window->menu, MBINFO, ! base_spec->new);
  menu_enable (window->menu, MBBASEIN, ! base_spec->new);
  menu_check  (window->menu, MBFULL, base_spec->show_full);
  menu_check  (window->menu, MBBESTFI, ! base_spec->show_full);
  menu_check  (window->menu, MBRELS, base_spec->show_rels);
  menu_check  (window->menu, MBLOOKUP, ! base_spec->show_rels);
  menu_check  (window->menu, MBSHORT, base_spec->show_short);
  menu_check  (window->menu, MBLONG, ! base_spec->show_short);
  menu_check  (window->menu, MBTOOLS, base_spec->show_tools);
  menu_enable (window->menu, MBTABLE, TRUE);
  menu_enable (window->menu, MBFIELD, card_one && (sel.field < 0) && (sel.key < 0));
  menu_enable (window->menu, MBKEY, card_one && (sel.field < 0) && (sel.key < 0));
  menu_enable (window->menu, MBSIZE, base_spec->show_full);
  menu_enable (window->menu, MBFONT, base_spec->show_full);
  menu_enable (window->menu, MBFORMAT, can_format);
  menu_enable (window->menu, MBDELRUL, can_delrule);
  menu_enable (window->menu, MBACCESS, base_spec->num_tables >= NUM_SYSTABLES);
  menu_enable (window->menu, MBTXT, base_spec->num_tables >= NUM_SYSTABLES);
  menu_enable (window->menu, MBCIFACE, base_spec->num_tables >= NUM_SYSTABLES);
} /* update_menu */

/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  WORD      table, field, key, obj;
  WORD      font, point;
  BOOLEAN   redraw;
  BOOLEAN   work;
  FONTDESC  fontdesc;
  SYSTATTR  *systattr;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  systattr  = base_spec->systattr;
  redraw    = FALSE;
  work      = FALSE;

  if (window != NULL) menu_normal (window, title, FALSE);

  switch (title)
  {
    case MBINFO   : if (item == MBBASEIN)
                      if ((sel.class == SEL_TABLE) && (window == sel_window))
                        wi_objop (window, sel_objs, OBJ_INFO);
                      else
                        if ((sel.class == SEL_NONE) || (window != sel_window))
                          info_base (window, NIL);
                        else
                          hndl_alert (ERR_NOINFO);
                    break;
    case MBVIEW   : switch (item)
                    {
                      case MBFULL   : redraw = ! base_spec->show_full;
                                      if (redraw)
                                      {
                                        base_spec->show_full = TRUE;
                                        base_spec->x_factor  = 100;
                                        base_spec->y_factor  = 100;
                                        reset_basefont (window);
                                        window->doc = base_spec->doc;
                                      } /* if */
                                      break;
                      case MBBESTFI : redraw = base_spec->show_full;
                                      if (redraw)
                                      {
                                        base_spec->show_full = FALSE;
                                        base_spec->doc       = window->doc;
                                        set_factor (window);

                                        window->doc.x = 0;
                                        window->doc.y = 0;
                                        window->doc.w = 0;
                                        window->doc.h = 0;
                                      } /* if */
                                      break;
                      case MBRELS   : redraw = ! base_spec->show_rels;
                                      base_spec->show_rels = TRUE;
                                      break;
                      case MBLOOKUP : redraw = base_spec->show_rels;
                                      base_spec->show_rels = FALSE;
                                      break;
                      case MBSHORT  : redraw = ! base_spec->show_short;
                                      base_spec->show_short = TRUE;
                                      for (table = 0; table < base_spec->num_tattrs;  table++)
                                        get_tblwh (base_spec, table, &systattr [table].width, &systattr [table].height);
                                      break;
                      case MBLONG   : redraw = base_spec->show_short;
                                      base_spec->show_short = FALSE;
                                      for (table = 0; table < base_spec->num_tattrs;  table++)
                                        get_tblwh (base_spec, table, &systattr [table].width, &systattr [table].height);
                                      break;
                    } /* switch */
                    break;
    case MBOPTION : switch (item)
                    {
                      case MBTOOLS  : if (base_spec->show_tools)   /* remove them */
                                      {
                                        window->scroll.y  = window->work.y + menu_height;
                                        window->scroll.h  = window->work.h - menu_height;
                                      } /* if */
                                      else
                                      {
                                        window->scroll.y = window->work.y + menu_height + iconheight;
                                        window->scroll.h = window->work.h - menu_height - iconheight;
                                        work = TRUE;
                                      } /* else */

                                      base_spec->show_tools ^= TRUE;
                                      redraw = TRUE;
                                      break;
                      case MBTABLE  : if (mnewtable (window, NULL, -1, -1, &table) == NTOK)
                                      {
                                        sel.class  = SEL_TABLE;
                                        sel.table  = table;
                                        sel_window = window;
                                        setincl (sel_objs, table);
                                      } /* if */
                                      break;
                      case MBFIELD  : if (mnewfield (window, sel.table, NULL, NULL, &field) == NFOK)
                                      {
                                        sel.class  = SEL_FIELD;
                                        sel.field  = field;
                                        sel_window = window;
                                        setincl (sel_objs, field);
                                      } /* if */
                                      break;
                      case MBKEY    : if (mnewkey (window, sel.table, NULL, &key) == NKOK)
                                      {
                                        sel.class  = inx2obj (base_spec, table, key, &obj);
                                        sel.field  = FAILURE;
                                        sel_window = window;
                                        setincl (sel_objs, obj);
                                      } /* if */
                                      break;
                      case MBMASK   : mselect (base_spec, sel.table);
                                      break;
                      case MBFORMAT : mformat (window, sel.table, sel.field, 0, NULL);
                                      break;
                      case MBICONS  : micons (base_spec);
                                      break;
                      case MBDELRUL : mdelrules (base_spec, sel.class, sel_objs);
                                      redraw = TRUE;
                                      break;
                    } /* switch */
                    break;
    case MBPARAM  : switch (item)
                    {
                      case MBFONT   : font  = base_spec->font;
                                      point = base_spec->point;

                                      fontdesc.font    = font;
                                      fontdesc.point   = point;
                                      fontdesc.effects = TXT_NORMAL;
                                      fontdesc.color   = BLACK;

                                      GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_HIDE_EFFECTS | FONT_FLAG_HIDE_COLOR | FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc);

                                      base_spec->font  = fontdesc.font;
                                      base_spec->point = fontdesc.point;

                                      if ((font != base_spec->font) || (point != base_spec->point))
                                      {
                                        redraw = TRUE;
                                        reset_basefont (window);
                                      } /* if */
                                      break;
                      case MBSIZE   : mselsize (&window->doc.w, &window->doc.h);
                                      set_sliders (window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);
                                      break;
                      case MBACCESS : maccess (base_spec);
                                      break;
                      case MBPARAMS : mdbparams (base_spec);
                                      break;
                      case MBTXT    : mdescription (base_spec);
                                      break;
                      case MBCIFACE : mcinterface (base_spec);
                                      break;
                    } /* switch */
                    break;
  } /* switch */

  if (redraw)
  {
    set_sliders (window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);

    if (work)
      set_redraw (window, &window->work);
    else
      set_redraw (window, &window->scroll);
  } /* if */

  if (window != NULL) menu_normal (window, title, TRUE);
} /* handle_menu */

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
  BOOLEAN   ret, ext;
  WORD      tables;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  tables    = base_spec->num_tables - base_spec->first_table;

  ret = TRUE;
  ext = (action & DO_EXTERNAL) != 0;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE;                                break;
    case DO_CUT    : ret = window == sel_window;                 break;
    case DO_COPY   : ret = window == sel_window;                 break;
    case DO_PASTE  : ret = ! empty_clipbrd (window, ext);        break;
    case DO_CLEAR  : ret = window == sel_window;                 break;
    case DO_SELALL : ret = (tables > 0) && (window->opened > 0); break;
    case DO_CLOSE  : ret = test_base (window);                   break;
    case DO_DELETE :                                             break;
  } /* switch */

  return (ret);
} /* wi_test */

/*****************************************************************************/
/* ôffne Fenster                                                             */
/*****************************************************************************/

LOCAL VOID wi_open (window)
WINDOWP window;

{
  box (window, TRUE);
} /* wi_open */

/*****************************************************************************/
/* Schlieûe Fenster                                                          */
/*****************************************************************************/

LOCAL VOID wi_close (window)
WINDOWP window;

{
  box (window, FALSE);
} /* wi_close */

/*****************************************************************************/
/* Lîsche Fenster                                                            */
/*****************************************************************************/

LOCAL VOID wi_delete (window)
WINDOWP window;

{
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  busy_mouse ();

  if (! base_spec->abort)
  {
    if (! b_save_base (window))
      if (base_spec->new)
        hndl_alert (ERR_DBCREATE);
      else
        hndl_alert (ERR_DBSAVE);
  } /* if */

  del_maskfile (base_spec);
  close_db (base_spec);
  mem_free (base_spec->systable);
  mem_free (base_spec);
  set_meminfo ();

  arrow_mouse ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  WORD       obj;
  RECT       r;
  BASE_SPEC  *base_spec;

  clr_scroll (window);

  base_spec = (BASE_SPEC *)window->special;

  if (base_spec->show_tools)
  {
    dbicons->ob_x = window->work.x;
    dbicons->ob_y = window->work.y + menu_height;

    xywh2rect (dbicons->ob_x, dbicons->ob_y, iconwidth, iconheight, &r);

    if (rc_intersect (&clip, &r))
    {
      for (obj = DBARROW; obj <= DBLINK; obj++) undo_state (dbicons, obj, SELECTED);
      do_state (dbicons, base_spec->tool, SELECTED);

      objc_draw (dbicons, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
    } /* if */
  } /* if */

  r = clip;

  if (rc_intersect (&window->scroll, &r))
  {
    if (! base_spec->show_full) set_factor (window);
    set_clip (TRUE, &r);
    draw_base (window, vdi_handle, base_spec->wbox, base_spec->hbox);
  } /* if */
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
    if (delta != 0)                             /* Scrolling nîtig */
    {
      window->doc.x = newpos;                   /* Neue Position */

      set_sliders (window, HORIZONTAL, SLPOS);  /* Schieber setzen */
      scroll_window (window, HORIZONTAL, delta * window->xfac);
    } /* if */
  } /* if */
  else                          /* Vertikale Pfeile und Schieber */
  {
    if (delta != 0)                             /* Scrolling nîtig */
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
  RECT      r, diff;
  WORD      wbox, hbox;
  LONG      max_xdoc, max_ydoc;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  wind_get (window->handle, WF_CXYWH, &r.x, &r.y, &r.w, &r.h);

  wbox   = window->xfac;
  hbox   = window->yfac;
  diff.x = (new->x - r.x) / 8 * 8;              /* Differenz berechnen */
  diff.y = (new->y - r.y) & 0xFFFE;
  diff.w = (new->w - r.w) / 8 * 8;
  diff.h = (new->h - r.h) / hbox * hbox;

  new->x = r.x + diff.x;                        /* Schnelle Position */
  new->y = r.y + diff.y;                        /* Y immer gerade */
  new->w = r.w + diff.w;                        /* Immer auf 8 Bit */

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

    if (! base_spec->show_full) set_redraw (window, &window->scroll);
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Objektoperationen von Fenster                                             */
/*****************************************************************************/

LOCAL VOID wi_objop (window, objs, action)
WINDOWP window;
SET     objs;
WORD    action;

{
  WORD      i, end;
  WORD      table, field, key;
  WORD      abs_col, abs_inx;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  switch (sel.class)
  {
    case SEL_NONE  : end = NIL;                    break;
    case SEL_TABLE : end = base_spec->num_tables;  break;
    case SEL_FIELD : end = base_spec->num_columns; break;
    case SEL_KEY   : end = base_spec->num_indexes; break;
    default        : end = NIL;                    break;
  } /* switch */

  for (i = 0; i <= end; i++)     /* look at all selected objects */
    if (setin (objs, i))
      switch (action)
      {
        case OBJ_OPEN : switch (sel.class)
                        {
                          case SEL_NONE  : hndl_alert (ERR_NOOPEN);
                                           break;
                          case SEL_TABLE : mnewtable (window, &base_spec->systable [i], -1, -1, &table);
                                           break;
                          case SEL_FIELD : abs_col = abscol (base_spec, sel.table, i);
                                           mnewfield (window, sel.table, &base_spec->syscolumn [abs_col], NULL, &field);
                                           break;
                          case SEL_KEY   : key = find_multikey (base_spec, sel.table, i);
                                           abs_inx = absinx (base_spec, sel.table, key);
                                           mnewkey (window, sel.table, &base_spec->sysindex [abs_inx], &key);
                                           break;
                          default        : hndl_alert (ERR_NOOPEN);
                                           break;
                        } /* switch */
                        break;
        case OBJ_INFO : if (sel.class == SEL_TABLE)
                          btblinfo (base_spec, i);
                        else
                          hndl_alert (ERR_NOINFO);
                        break;
        case OBJ_HELP : switch (sel.class)
                        {
                          case SEL_NONE  : hndl_alert (ERR_NOHELP); break;
                          case SEL_TABLE : hndl_help (HNEWTBL);     break;
                          case SEL_FIELD : hndl_help (HNEWFIEL);    break;
                          case SEL_KEY   : hndl_help (HNEWKEY);     break;
                          default        : hndl_alert (ERR_NOHELP); break;
                        } /* switch */
                        break;
      } /* switch, if, for */
} /* wi_objop */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  WORD action;

  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  action = DRAG_NOACTN;

  if (src_window->class == class_desk)          /* Objekte von Desktop */
  {
    switch (src_obj)
    {
      case ITRASH   : action = DRAG_NOACTN; break;
      case ICLIPBRD : action = DRAG_OK;     break;
    } /* switch */
  } /* if */

  return (action);
} /* wi_drag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  b_click (window, mk);
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
  b_unclick (window);
} /* wi_unclick */

/*****************************************************************************/
/* Taste fÅr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (menu_key (window, mk)) return (TRUE);

  if (mk->ascii_code == ESC)
  {
    set_redraw (window, &window->scroll);
    return (TRUE);
  } /* if */

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

LOCAL VOID wi_top (window)
WINDOWP window;

{
} /* wi_top */

/*****************************************************************************/
/* Cut/Copy/Paste fÅr Fenster                                                */
/*****************************************************************************/

LOCAL VOID wi_edit (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN ext;

  ext = (action & DO_EXTERNAL) != 0;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : break;
    case DO_CUT    : if (copy2clipbrd (window, sel.class, sel_objs, ext))
                       b_obj_clear (window, sel.class, sel_objs, NULL);
                     break;
    case DO_COPY   : copy2clipbrd (window, sel.class, sel_objs, ext);
                     break;
    case DO_PASTE  : paste_clipbrd (window, NULL, ext);
                     break;
    case DO_CLEAR  : b_obj_clear (window, sel.class, sel_objs, NULL);
                     break;
    case DO_SELALL : obj_selall (window);
                     break;
  } /* switch */
} /* wi_edit */

