/*****************************************************************************
 *
 * Module : MASK.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the mask window.
 *
 * History:
 * 30.06.03: Beim MenÅpunkt "Schrift..." werden die Werte des ersten
 *           selektierten Objekt an den Schriftauswahldialog Åbergeben.
 * 16.03.97: Call to GetPicFilename in wi_message used
 * 10.03.97: GEM_UPDATE & IMG_UPDATE used in wi_message
 * 18.02.97: Function wi_message for use with OLGA added
 * 15.11.95: Call to clear_area moved before test on *p in draw_field
 * 31.10.95: Hidden buttons are drawed DISABLED in draw_button
 * 06.09.95: Drawing of right checkboxes corrected in draw_field
 * 28.08.95: Setting of dlg_colors changed in draw_mask
 * 10.08.95: Drawing 3d in draw_field completed
 * 19.07.95: Drawing 3d in draw_field added
 * 22.03.95: Test (mask_spec->objs > 0) removed in test_mask
 * 06.10.94: ERR_JOINMASK deleted in check_mask
 * 21.09.94: Handling of MIMASK, M_SUBMASK added
 * 25.07.94: Rounded button capability added to draw_button
 * 14.07.94: New 3D-DrawButton used in draw_button
 * 15.04.94: New transparent modus added to draw_field
 * 06.12.93: Button can use ALT_CHAR for marking keyboard interface
 * 22.11.93: Default color is WHITE on monochrome displays in draw_mask
 * 20.11.93: Old mselfont.h replaced with CommDlg functions
 * 10.11.93: GetFontDialog used instead of mselfont
 * 03.11.93: Drawing of background color added to draw_mask
 * 25.10.93: Test on BASE_RDONLY in test_mask added
 * 12.09.93: Update of toolbar corrected in handle_menu
 * 09.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 08.09.93: Modifications for user defined buttons added
 * 07.09.93: set_ptext -> set_str
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "clipbrd.h"
#include "commdlg.h"
#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "imageobj.h"
#include "base.h"

#include "mmaskinf.h"
#include "mload.h"
#include "mclick.h"
#include "mobjsize.h"
#include "mselbutt.h"
#include "mselfiel.h"
#include "mselgrid.h"
#include "mselfill.h"
#include "mselsize.h"
#include "mselsubm.h"
#include "mseltext.h"

#include "export.h"
#include "mask.h"

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
#define INITH  (desk.h - 5 * gl_hbox)   /* Anfangshîhe in Pixel */
#define MILLI  0                        /* Millisekunden fÅr Zeitablauf */

#define DOCW   400L                     /* document width for mask window */
#define DOCH   400L                     /* document height for mask window */

#define FONT_NAMELEN    10              /* width of font info box in window */
#define RADIO_DELIMITER '|'             /* delimiter for radio button choices */
#define ALT_CHAR        '~'		/* char for activating buttons with alt key in keyboard interface */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD iconwidth;	/* width of iconbar */
LOCAL WORD iconheight;	/* height of iconbar */
LOCAL WORD menu_height;	/* height of menu */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    draw_mask     _((WINDOWP window, WORD out_handle));
LOCAL VOID    draw_field    _((WINDOWP window, WORD out_handle, MOBJECT *mobject, RECT *r, FATTR *fattr, WORD strwidth, WORD bk_color));
LOCAL VOID    draw_line     _((WINDOWP window, WORD out_handle, MOBJECT *mobject, WORD bk_color));
LOCAL VOID    draw_box      _((WINDOWP window, WORD out_handle, MOBJECT *mobject, RECT *r, BOOLEAN rounded, WORD bk_color));
LOCAL VOID    draw_text     _((WINDOWP window, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID    draw_graf     _((WINDOWP window, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID    draw_button   _((WINDOWP window, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID    draw_submask  _((WINDOWP window, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID    draw_checkbox _((WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color));
LOCAL VOID    draw_rbutton  _((WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color));
LOCAL VOID    draw_anybox   _((WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color, BOOLEAN checkbox));
LOCAL VOID    draw_rect     _((WORD out_handle, RECT *r));
LOCAL VOID    draw_arrow    _((WORD out_handle, RECT *r, WORD color));
LOCAL VOID    draw_acc_line _((WORD vdi_handle, WORD inx, WORD x, WORD y, BYTE *text, BOOLEAN disabled, WORD dlg_colors, WORD bk_color, WORD text_color));
LOCAL VOID    clear_area    _((WORD out_handle, RECT *area));

LOCAL BOOLEAN check_mask    _((MASK_SPEC *mask_spec));
LOCAL BOOLEAN test_mask     _((MASK_SPEC *mask_spec));
LOCAL VOID    get_rtext     _((BYTE *p, BYTE *s, WORD index));

LOCAL VOID    mselobj       _((WINDOWP window, WORD obj));
LOCAL VOID    get_graf      _((WINDOWP window));
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
LOCAL BOOLEAN wi_message    _((WINDOWP window, WORD *msg));
LOCAL VOID    wi_top        _((WINDOWP window));
LOCAL VOID    wi_untop      _((WINDOWP window));
LOCAL VOID    wi_edit       _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_mask ()

{
  WORD obj, min_height, icn_height;

  obj = ROOT;

  icn_height = maskicon [MIARROW].ob_height;
  min_height = max (maskicon [ROOT].ob_height, icn_height + 8);	/* leave a little space */

  do
  {
    if (is_type (maskicon, obj, G_BUTTON))
      maskicon [obj].ob_y = (min_height - icn_height) / 2;
  } while (! is_flags (maskicon, obj++, LASTOB));

  maskicon [ROOT].ob_width  = maskicon [1].ob_width  = desk.w;
  maskicon [ROOT].ob_height = maskicon [1].ob_height = min_height;

  iconwidth  = maskicon->ob_width;
  iconheight = maskicon->ob_height + 1;

  return (TRUE);
} /* init_mask */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_mask ()

{
  return (TRUE);
} /* term_mask */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_mask (obj, menu, icon, hlpmask, base_spec, index, new)
OBJECT    *obj, *menu;
WORD      icon;
HLPMASK   *hlpmask;
BASE_SPEC *base_spec;
WORD      index;
BOOLEAN   new;

{
  WINDOWP   window;
  WORD      inx, i;
  LONG      size;
  FULLNAME  tmpname;
  STRING    name1, name2;
  MASK_SPEC *mask_spec;
  BOOLEAN   ok;
  WINDOWP   winds [MAX_GEMWIND];

  strcpy (tmpname, hlpmask->name);
  if (tmpname [0] == EOS) strcpy (tmpname, FREETXT (FNOTITLE)); /* UNTITLED */

  strcpy (name1, tmpname);
  str_upper (name1);

  inx = num_windows (CLASS_MASK, SRCH_ANY, winds);

  for (i = 0; i < inx; i++)                     /* test if mask already open */
  {
    mask_spec = (MASK_SPEC *)winds [i]->special;
    strcpy (name2, mask_spec->mask.name);
    str_upper (name2);

    if ((base_spec == mask_spec->base_spec) &&
        (strcmp (name1, name2) == 0)        &&
        (mask_spec->mask.device [0] == hlpmask->device [0]))
    {
      hndl_alert (ERR_SAMEMASK);                /* mask already open */
      return (NULL);
    } /* if */
  } /* for */

  size      = sizeof (MASK_SPEC) + work_spec.pics * sizeof (PICOBJ);
  mask_spec = (MASK_SPEC *)mem_alloc (size);
  if (mask_spec == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  mem_set (mask_spec, 0, sizeof (MASK_SPEC));

  mask_spec->memsize       = size;
  mask_spec->mask.address  = hlpmask->address;
  mask_spec->new           = new;
  mask_spec->show_full     = TRUE;
  mask_spec->base_spec     = base_spec;
  mask_spec->mindex        = index;
  mask_spec->findex        = hlpmask->findex;
  mask_spec->str           = MAX_MASK;
  mask_spec->objs          = 0;
  mask_spec->max_objs      = MAX_MASK / sizeof (MOBJECT);
  mask_spec->factor        = 100;
  mask_spec->grid_x        = g_xgrid;
  mask_spec->grid_y        = g_ygrid;
  mask_spec->tool          = MIARROW;
  mask_spec->font          = g_font;
  mask_spec->point         = g_point;
  mask_spec->color         = BLACK;
  mask_spec->line_type     = SOLID;
  mask_spec->line_width    = 1;
  mask_spec->line_bstyle   = SQUARED;
  mask_spec->line_estyle   = SQUARED;
  mask_spec->fill_style    = FIS_HOLLOW;
  mask_spec->fill_index    = 0;
  mask_spec->max_pics      = work_spec.pics;
  mask_spec->picobj        = (PICOBJ *)((BYTE *)mask_spec + sizeof (MASK_SPEC));

  if (new)
    ok = m_new_mask (mask_spec);
  else                                  /* old mask, so read it */
    ok = m_load_mask (mask_spec);

  if (! ok)
  {
    hndl_alert (new ? ERR_MASKNEW : ERR_MASKLOAD);
    mem_free (mask_spec);
    return (NULL);
  } /* if */

  strcpy (mask_spec->mask.name, tmpname);
  strcpy (mask_spec->mask.calcentry, hlpmask->calcentry);
  strcpy (mask_spec->mask.calcexit,  hlpmask->calcexit);

  mask_spec->mask.device [0] = hlpmask->device [0];
  mask_spec->mask.flags      = hlpmask->flags;
  mask_spec->mask.version    = hlpmask->version;
  mask_spec->mask.x          = hlpmask->x;
  mask_spec->mask.y          = hlpmask->y;
  mask_spec->mask.w          = hlpmask->w;
  mask_spec->mask.h          = hlpmask->h;
  mask_spec->mask.bkcolor    = hlpmask->bkcolor;

  mask_spec->abort        = FALSE;
  mask_spec->modified     = FALSE;
  mask_spec->show_star    = FALSE;
  mask_spec->show_tools   = TRUE;
  mask_spec->printer_mask = mask_spec->mask.device [0] == MASK_PRINTER;

  window = create_window (KIND, CLASS_MASK);

  if (window != NULL)
  {
    inx += num_windows (CLASS_MASK, SRCH_ANY, winds);

    menu_height = (menu != NULL) ? gl_hattr : 0;

    window->flags     = FLAGS;
    window->icon      = icon;
    window->doc.x     = 0;
    window->doc.y     = 0;
    window->doc.w     = doc_width;
    window->doc.h     = doc_height;
    window->xfac      = XFAC;
    window->yfac      = YFAC;
    window->xunits    = XUNITS;
    window->yunits    = YUNITS;
    window->work.x    = INITX + inx * gl_wbox;
    window->work.y    = INITY + inx * gl_hbox;
    window->work.w    = (win_width  - inx) * gl_wbox;
    window->work.h    = (win_height - inx) * gl_hbox;
    window->scroll.x  = window->work.x;
    window->scroll.y  = window->work.y + menu_height + iconheight;
    window->scroll.w  = window->work.w;
    window->scroll.h  = window->work.h - menu_height - iconheight;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)mask_spec;
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
    window->message   = wi_message;
    window->top       = wi_top;
    window->untop     = NULL;
    window->edit      = wi_edit;
    window->showinfo  = info_mask;
    window->showhelp  = help_mask;

    m_wi_title (window);
    mask_spec->window = window;
    get_graf (window);
  } /* if */
  else
    mem_free (mask_spec);

  set_meminfo ();

  return (window);                      /* Fenster zurÅckgeben */
} /* crt_mask */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_mask (icon, hlpmask, base_spec, index, new)
WORD      icon;
HLPMASK   *hlpmask;
BASE_SPEC *base_spec;
WORD      index;
BOOLEAN   new;

{
  BOOLEAN ok;
  WINDOWP window;

  busy_mouse ();

  if ((icon != NIL) && (window = search_window (CLASS_MASK, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_MASK, SRCH_CLOSED, icon)) == NULL)
      window = crt_mask (NULL, maskmenu, icon, hlpmask, base_spec, index, new);

    ok = window != NULL;

    if (ok)
    {
      ok = open_window (window);
      if (! ok) hndl_alert (ERR_NOOPEN);
    } /* if */
  } /* else */

  arrow_mouse ();

  return (ok);
} /* open_mask */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_mask (window, icon)
WINDOWP window;
WORD    icon;

{
  MASK_SPEC *mask_spec;

  if (icon != NIL) window = search_window (CLASS_MASK, SRCH_ANY, icon);

  if (window != NULL)
  {
    mask_spec = (MASK_SPEC *)window->special;
    mmaskinfo (mask_spec);
  } /* if */

  return (window != NULL);
} /* info_mask */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_mask (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HMASK));
} /* help_mask */

/*****************************************************************************/

GLOBAL BOOLEAN close_masks (base_spec)
BASE_SPEC *base_spec;

{
  WORD      num, i, wh;
  MASK_SPEC *mask_spec;
  WINDOWP   window;
  WINDOWP   windows [MAX_GEMWIND];

  num = num_windows (CLASS_MASK, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window    = windows [i];
    mask_spec = (MASK_SPEC *)window->special;

    if (mask_spec->base_spec == base_spec)
    {
      wh = window->handle;
      close_window (window);
      if (find_window (wh) != NULL) return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_masks */

/*****************************************************************************/

GLOBAL VOID save_mask (window)
WINDOWP window;

{
  BOOLEAN   ok;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  busy_mouse ();

  if (! mask_spec->abort)
  {
    ok = m_save_mask (mask_spec);

    if (ok)
    {
      mask_spec->abort     = FALSE;
      mask_spec->modified  = FALSE;
      mask_spec->show_star = FALSE;
      mask_spec->new       = FALSE;

      m_wi_title (window);
    } /* if */
    else
      hndl_alert (ERR_MASKSAVE);
  } /* if */

  arrow_mouse ();
} /* save_mask */

/*****************************************************************************/

GLOBAL VOID print_mask (window)
WINDOWP window;

{
  WINDOW    win;
  DEVINFO   dev_info;
  WORD      out_handle;
  WORD      wchar, hchar, wbox, hbox;
  WORD      pgwidth, pgheight;
  WORD      device;
  WORD      llx, lly, urx, ury;
  FULLNAME  meta_name;
  LONGSTR   s;
  BASE_SPEC *base_spec;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  base_spec = mask_spec->base_spec;

  mask_spec = (MASK_SPEC *)window->special;

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
      sprintf (meta_name, "%s%s", base_spec->basepath, mask_spec->mask.name);
      strcat (meta_name, ".GEM");
      str_upper (meta_name);
      str_rmchar (meta_name, ' ');
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

    win = *window;
    m_get_doc (window, &win.doc.w, &win.doc.h);

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
      lly = win.doc.h * win.yfac;
      urx = win.doc.w * win.xfac;
      ury = 0;

      pgwidth  = (LONG)dev_info.pix_w * urx / 100; /* 1/10 mm */
      pgheight = (LONG)dev_info.pix_h * lly / 100;

      v_meta_extents (out_handle, 0, 0, urx, lly);
/*        vm_pagesize (out_handle, 1905, 2540); */          /* Letter size = 7,5 x 10.00 inches */
      vm_pagesize (out_handle, pgwidth, pgheight);
      vm_coords (out_handle, llx, lly, urx, ury);
    } /* if */

    draw_mask (&win, out_handle);

    if (device != METAFILE)
    {
      v_updwk (out_handle);
      v_clrwk (out_handle);
    } /* if */

    vst_unload_fonts (out_handle, 0);
    close_work (device, out_handle);

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
} /* print_mask */

/*****************************************************************************/

LOCAL VOID draw_mask (window, out_handle)
WINDOWP window;
WORD    out_handle;

{
  BOOLEAN   b3D;
  WORD      obj, class, strwidth, bk_color, old_colors;
  WORD      xy [4];
  RECT      old_clip, frame, r;
  FATTR     fattr;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec  = (MASK_SPEC *)window->special;
  sysmask    = &mask_spec->mask;
  mobject    = (MOBJECT *)sysmask->mask.buffer;
  old_clip   = clip;
  old_colors = dlg_colors;

  text_default (out_handle);
  line_default (out_handle);

  bk_color = is_null (TYPE_LONG, &sysmask->bkcolor) ? WHITE : IndexFromColor32 (sysmask->bkcolor);

  if (colors == 2) bk_color = WHITE;

  if ((bk_color == WHITE) || (bk_color == BLACK) || ! is_null (TYPE_LONG, &sysmask->bkcolor))
  {
    vsf_interior (out_handle, FIS_SOLID);
    vsf_color (out_handle, bk_color);
    rect2array (&window->scroll, xy);
    vr_recfl (out_handle, xy);
  } /* if */

  b3D = (dlg_colors >= 16) && (sysmask->flags & SM_SHOW_3D);

  if (! b3D) dlg_colors = 2;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield   = &mobject->mfield;
    class    = mfield->class;
    strwidth = m_get_rect (window, out_handle, class, mobject, &frame, &fattr);
    r        = frame;

    if (b3D) rc_inflate (&frame, 1, 1);

    if (rc_intersect (&clip, &frame))
    {
      vswr_mode (out_handle, MD_REPLACE);
      vsl_type (out_handle, SOLID);
      vsl_width (out_handle, 1);
      vsl_ends (out_handle, SQUARED, SQUARED);

      switch (class)
      {
        case M_FIELD   : draw_field (window, out_handle, mobject, &r, &fattr, strwidth, bk_color); break;
        case M_LINE    : draw_line (window, out_handle, mobject, bk_color);                        break;
        case M_BOX     : draw_box (window, out_handle, mobject, &r, FALSE, bk_color);              break;
        case M_RBOX    : draw_box (window, out_handle, mobject, &r, TRUE, bk_color);               break;
        case M_TEXT    : draw_text (window, out_handle, mobject, &r, bk_color);                    break;
        case M_GRAF    : draw_graf (window, out_handle, mobject, &r, bk_color);                    break;
        case M_BUTTON  : draw_button (window, out_handle, mobject, &r, bk_color);                  break;
        case M_SUBMASK : draw_submask (window, out_handle, mobject, &r, bk_color);                 break;
      } /* switch */

      if ((window == sel_window) && (sel.class == SEL_MOBJ))
        if (setin (sel_objs, obj))
          if (rc_intersect (&clip, &frame))
          {
            set_clip (TRUE, &frame);
            vswr_mode (out_handle, MD_XOR);
            vsl_color (out_handle, BLACK);
            vsl_ends (out_handle, SQUARED, SQUARED);
            vsl_udsty (out_handle, 0x5555);
            vsl_type (out_handle, USERLINE);
            vsl_width (out_handle, 1);

            draw_rect (out_handle, &r);
            set_clip (TRUE, &old_clip);
          } /* if, if, if */
    } /* if */
  } /* for */

  dlg_colors = old_colors;
} /* draw_mask */

/*****************************************************************************/

LOCAL VOID draw_field (window, out_handle, mobject, r, fattr, strwidth, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
RECT    *r;
FATTR   *fattr;
WORD    strwidth;
WORD    bk_color;

{
  BOOLEAN   b3D;
  WORD      max_y, index;
  WORD      x, y, w, h;
  WORD      wchar, hchar, wbox, hbox;
  WORD      xy [10];
  WORD      extent [8];
  LONG      i;
  UWORD     flags;
  STRING    s;
  RECT      frame;
  FONTDESC  fontdesc;
  BYTE      *p;
  MFIELD    *mfield;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mfield    = &mobject->mfield;
  flags     = mfield->flags;
  b3D       = (dlg_colors >= 16) && (sysmask->flags & SM_SHOW_3D);

  rect2xywh (r, &x, &y, &w, &h);
  vsl_color (out_handle, mfield->color);
  vst_color (out_handle, mfield->color);

  if (flags & MF_STDLABEL)
    p = &sysmask->mask.buffer [mfield->field_name];
  else
    p = &sysmask->mask.buffer [mfield->label_name];

  if (! (mfield->flags & MF_TRANSPARENT))	/* clear area beneath label */
    if (! b3D) clear_area (out_handle, r);

  if ((mfield->type == MT_NEUTRAL)    ||
      (mfield->type == MT_OUTLINED)   ||
      (mfield->type == MT_UNDERLINED) ||
      (mfield->type == MT_POPUP))
  {
    frame    = *r;
    frame.x += strwidth;
    frame.w -= strwidth;
    clear_area (out_handle, &frame);

    if (*p != EOS)
    {
      vswr_mode (out_handle, b3D || (mfield->flags & MF_TRANSPARENT) ? MD_TRANS : MD_REPLACE);
      v_gtext (out_handle, x + EDIT_FRAME, y + EDIT_FRAME, p);
      vswr_mode (out_handle, MD_REPLACE);
      x += strwidth;
      w -= strwidth;
    } /* if */
  } /* if */

  fontdesc.font    = mfield->font;
  fontdesc.point   = mfield->point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = mfield->color;

  switch (mfield->type)
  {
    case MT_NEUTRAL     : break;
    case MT_OUTLINED    : xywh2rect (x, y, w, h, &frame);

                          if (b3D)
                          {
                            draw_3d (out_handle, frame.x - 0, frame.y - 0, 1, frame.w + 0, frame.h + 0, sys_colors [COLOR_BTNSHADOW], sys_colors [COLOR_BTNHIGHLIGHT], sys_colors [COLOR_BTNFACE], FALSE);
                            draw_3d (out_handle, frame.x + 1, frame.y + 1, 1, frame.w - 2, frame.h - 2, BLACK, sys_colors [COLOR_BTNFACE], sys_colors [COLOR_BTNSHADOW], FALSE);
                          } /* if */
                          else
                            draw_rect (out_handle, &frame);
                          break;
    case MT_POPUP       : xywh2rect (x, y, w, h, &frame);
                          rc_inflate (&frame, 1, 1);
                          DrawComboBox (out_handle, &frame, &clip, NULL, 0, WHITE, &fontdesc, gl_wbox, gl_wattr, 0, NULL, NULL);
                          break;
    case MT_UNDERLINED  : xy [0] = x;
                          xy [1] = y + h - 1;
                          xy [2] = x + w - 1;
                          xy [3] = xy [1];

                          v_pline (out_handle, 2, xy);
                          break;
    case MT_LCHECKBOX   : DrawCheckRadio (out_handle, r, &clip, p, 0, SELECTED, bk_color, &fontdesc, FALSE);
                          break;
    case MT_RCHECKBOX   : vswr_mode (out_handle, b3D || (mfield->flags & MF_TRANSPARENT) ? MD_TRANS : MD_REPLACE);
                          vqt_extent (out_handle, p, extent);
                          h = extent [5] - extent [3];
                          y = r->y + (r->h - h) / 2;
                          v_gtext (out_handle, x, y, p);

                          frame    = *r;
                          frame.x += strwidth;
                          frame.w -= strwidth;

                          DrawCheckRadio (out_handle, &frame, &clip, NULL, 0, SELECTED, bk_color, &fontdesc, FALSE);
                          break;
    case MT_RADIOBUTTON : vst_point (out_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);
                          xywh2rect (x, y + hbox, w, h - hbox, &frame);

                          DrawGroupBox (out_handle, &frame, &clip, p, 0, NORMAL, bk_color, &fontdesc);

                          if (is_null (TYPE_LONG, &mfield->lower) ||
                              is_null (TYPE_LONG, &mfield->upper)) return;

                          max_y  = y + h - hbox;
                          y     += 2 * hbox;
                          index  = 0;
                          p      = (mfield->extra == FAILURE) ? NULL : &sysmask->mask.buffer [mfield->extra];

                          frame.x = x + gl_wbox;
                          frame.y = y;
                          frame.w = r->w -  3 * gl_wbox;
                          frame.h = hbox;

                          for (i = mfield->lower; (i <= mfield->upper) && (y < max_y); i++, index++)
                          {
                            get_rtext (p, s, index);

                            if (hbox < 13)	/* for compatibility of older masks using a small font */
                            {
                              draw_rbutton (out_handle, x + wbox, y, hbox, i == mfield->lower, mfield->color, bk_color);
                              v_gtext (out_handle, x + wbox + 24, y, s);
                            } /* if */
                            else
                              DrawCheckRadio (out_handle, &frame, &clip, s, 0, (i == mfield->lower) ? SELECTED : NORMAL, bk_color, &fontdesc, TRUE);
                            y       += hbox;
                            frame.y += hbox;
                          } /* for */
                          break;
    default             : v_gtext (out_handle, x, y, "?");
                          break;
  } /* switch */
} /* draw_field */

/*****************************************************************************/

LOCAL VOID draw_line (window, out_handle, mobject, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
WORD    bk_color;

{
  WORD  xy [4];
  MLINE *mline;

  mline = &mobject->mline;

  vsl_color (out_handle, mline->color);
  vsl_ends (out_handle, mline->bstyle, mline->estyle);
  vsl_type (out_handle, mline->type);
  vsl_width (out_handle, mline->width);

  xy [0] = (LONG)mline->x1 * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
  xy [1] = (LONG)mline->y1 * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;
  xy [2] = (LONG)mline->x2 * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
  xy [3] = (LONG)mline->y2 * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;

  v_pline (out_handle, 2, xy);
} /* draw_line */

/*****************************************************************************/

LOCAL VOID draw_box (window, out_handle, mobject, r, rounded, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
RECT    *r;
BOOLEAN rounded;
WORD    bk_color;

{
  WORD  xy [10];
  MBOX  *mbox;

  mbox = &mobject->mbox;

  line_default (out_handle);
  vsf_perimeter (out_handle, TRUE);
  vsf_interior (out_handle, mbox->style);
  vsf_style (out_handle, mbox->index);
  vsf_color (out_handle, mbox->color);
  vsl_color (out_handle, mbox->color);

  switch (mbox->style)
  {
    case FIS_HOLLOW : vswr_mode (out_handle, MD_TRANS); break;
    case FIS_SOLID  : vsf_color (out_handle, WHITE);    break;
  } /* switch */

  rect2array (r, xy);

  if (rounded)
  {
    if (mbox->style != FIS_HOLLOW) v_rfbox (out_handle, xy);
    v_rbox (out_handle, xy);
  } /* if */
  else
  {
    if (mbox->style != FIS_HOLLOW) vr_recfl (out_handle, xy);

    vswr_mode (out_handle, MD_REPLACE);
    draw_rect (out_handle, r);
  } /* else */
} /* draw_box */

/*****************************************************************************/

LOCAL VOID draw_text (window, out_handle, mobject, r, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
RECT    *r;
WORD    bk_color;

{
  WORD      x, y, w, h;
  WORD      minimum, maximum, width;
  WORD      distances [5], effects [3];
  BYTE      *p;
  MTEXT     *mtext;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mtext     = &mobject->mtext;

  rect2xywh (r, &x, &y, &w, &h);
  vswr_mode (out_handle, mtext->wrmode);
  vst_color (out_handle, mtext->color);
  vst_effects (out_handle, mtext->effects);
  vqt_font_info (out_handle, &minimum, &maximum, distances, &width, effects);

  p = &sysmask->mask.buffer [mtext->text];
  if (*p) v_gtext (out_handle, x + effects [2], y, p);
} /* draw_text */

/*****************************************************************************/

LOCAL VOID draw_graf (window, out_handle, mobject, r, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
RECT    *r;
WORD    bk_color;

{
  WORD      pic;
  WORD      xy [10];
  BYTE      *filename;
  PICOBJ    *picobj;
  MGRAF     *mgraf;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mgraf     = &mobject->mgraf;

  rect2array (r, xy);

  line_default (out_handle);
  text_default (out_handle);
  vsf_interior (out_handle, FIS_SOLID);
  vsf_color (out_handle, WHITE);
  vr_recfl (out_handle, xy);

  filename = &sysmask->mask.buffer [mgraf->filename];
  pic      = m_name2picobj (mask_spec, filename);

  if (pic != FAILURE)
  {
    picobj = &mask_spec->picobj [pic];

    switch (picobj->type)
    {
      case PIC_META  : gem_obj (&picobj->pic.gem, GEM_DRAW, 0, NULL);   break;
      case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_DRAW, 0, NULL); break;
      case PIC_IFF   :                                                  break;
      case PIC_TIFF  :                                                  break;
    } /* switch */
  } /* if */

  if (mgraf->flags & MG_DRAWFRAME)
  {
    line_default (out_handle);
    draw_rect (out_handle, r);
  } /* if */
} /* draw_graf */

/*****************************************************************************/

LOCAL VOID draw_button (window, out_handle, mobject, r, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
RECT    *r;
WORD    bk_color;

{
  WORD      x, y, w, h, i, pos, state;
  LONGSTR   text;
  FONTDESC  fontdesc;
  BYTE      *p;
  MBUTTON   *mbutton;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mbutton   = &mobject->mbutton;

  strcpy (text, &sysmask->mask.buffer [mbutton->text]);
  p   = text;
  pos = FAILURE;

  if (strchr (p, ALT_CHAR) != NULL)	/* alternate control char */
  {
    for (i = 0; p [i] != ALT_CHAR; i++);
    pos = i + 1;			/* get position of underbar char */

    strcpy (p + i, p + i + 1);		/* delete ALT_CHAR */
  } /* if */

  rect2xywh (r, &x, &y, &w, &h);

  fontdesc.font    = mbutton->font;
  fontdesc.point   = mbutton->point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = mbutton->color;

  state = NORMAL;
  if (mbutton->flags & MBF_HIDDEN) state |= DISABLED;

  DrawButton (out_handle, r, &clip, text, pos, state, sys_colors [COLOR_BTNFACE], &fontdesc, FALSE, (mbutton->flags & MBF_ROUNDED) != 0, btn_shadow_width);
} /* draw_button */

/*****************************************************************************/

LOCAL VOID draw_submask (window, out_handle, mobject, r, bk_color)
WINDOWP window;
WORD    out_handle;
MOBJECT *mobject;
RECT    *r;
WORD    bk_color;

{
  WORD      x, y, w, h;
  BYTE      *p;
  MSUBMASK  *msubmask;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  msubmask  = &mobject->msubmask;

  rect2xywh (r, &x, &y, &w, &h);

  vsl_color (out_handle, msubmask->color);
  vst_color (out_handle, msubmask->color);
  vst_effects (out_handle, TXT_NORMAL);

  draw_rect (out_handle, r);

  p = &sysmask->mask.buffer [msubmask->SourceObject];
  if (*p) v_gtext (out_handle, x + 1, y + 1, p);	/* leave a little space */
} /* draw_submask */

/*****************************************************************************/

LOCAL VOID draw_checkbox (out_handle, x, y, hbox, selected, color, bk_color)
WORD    out_handle;
WORD    x, y;
WORD    hbox;
BOOLEAN selected;
WORD    color;
WORD    bk_color;

{
  draw_anybox (out_handle, x, y, hbox, selected, color, bk_color, TRUE);
} /* draw_checkbox */

/*****************************************************************************/

LOCAL VOID draw_rbutton (out_handle, x, y, hbox, selected, color, bk_color)
WORD    out_handle;
WORD    x, y;
WORD    hbox;
BOOLEAN selected;
WORD    color;
WORD    bk_color;

{
  draw_anybox (out_handle, x, y, hbox, selected, color, bk_color, FALSE);
} /* draw_rbutton */

/*****************************************************************************/

LOCAL VOID draw_anybox (out_handle, x, y, hbox, selected, color, bk_color, checkbox)
WORD    out_handle;
WORD    x, y;
WORD    hbox;
BOOLEAN selected;
WORD    color;
WORD    bk_color;
BOOLEAN checkbox;

{
  MFDB   s, d;
  BITBLK *bitblk;
  WORD   obj;
  WORD   pxy [8];
  WORD   index [2];

  if (checkbox)
  {
    if (selected)
      obj = (hbox >= 12) ? CBHSEL : (hbox >= 7) ? CB7SEL : CB5SEL;
    else
      obj = (hbox >= 12) ? CBHNORM : (hbox >= 7) ? CB7NORM : CB5NORM;
  } /* if */
  else
  {
    if (selected)
      obj = (hbox >= 12) ? RBHSEL : (hbox >= 7) ? RB7SEL : RB5SEL;
    else
      obj = (hbox >= 12) ? RBHNORM : (hbox >= 7) ? RB7NORM : RB5NORM;
  } /* else */

  if (gl_hbox <= 8)     /* low resolution like CGA */
  {
    switch (obj)        /* use same buttons as dialogue boxes */
    {
      case CB7SEL  : obj = CBLSEL;  break;
      case CB7NORM : obj = CBLNORM; break;
      case RB7SEL  : obj = RBLSEL;  break;
      case RB7NORM : obj = RBLNORM; break;
    } /* switch */
  } /* if */

  bitblk = (BITBLK *)userimg [obj].ob_spec;

  d.mp  = NULL;                                 /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = bitblk->bi_wb >> 1;
  s.ff  = FALSE;
  s.np  = 1;

  y += (hbox - s.fh) / 2;                       /* center box */

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = x;
  pxy [5] = y;
  pxy [6] = x + pxy [2];
  pxy [7] = y + pxy [3];

  index [0] = color;
  index [1] = (dlg_colors < 16) ? WHITE : bk_color;

  vrt_cpyfm (out_handle, MD_REPLACE, pxy, &s, &d, index);    /* copy it */
} /* draw_anybox */

/*****************************************************************************/

LOCAL VOID draw_rect (out_handle, r)
WORD out_handle;
RECT *r;

{
  WORD xy [10];

  xy [0] = r->x;
  xy [1] = r->y;
  xy [2] = xy [0] + r->w - 1;
  xy [3] = xy [1];
  xy [4] = xy [2];
  xy [5] = xy [1] + r->h - 1;
  xy [6] = xy [0];
  xy [7] = xy [5];
  xy [8] = xy [0];
  xy [9] = xy [1] + 1;

  v_pline (out_handle, 5, xy);
} /* draw_rect */

/*****************************************************************************/

LOCAL VOID draw_arrow (out_handle, r, color)
WORD out_handle;
RECT *r;
WORD color;

{
  WORD   h, obj;
  WORD   x, y;
  WORD   pxy [8];
  WORD   index [2];
  RECT   box;
  MFDB   s, d;
  BITBLK *bitblk;

  box = *r;

  box.x += EDIT_FRAME;          /* interior of box */
  box.y += EDIT_FRAME;
  box.w -= 2 * EDIT_FRAME;
  box.h -= 2 * EDIT_FRAME;

  h = min (box.w, box.h);

  if (h >= 32)
    obj = ARROW32;
  else
    if (h >= 16)
      obj = ARROW16;
    else
      if (h >= 14)
        obj = ARROW14;
      else
        if (h >= 12)
          obj = ARROW12;
        else
          if (h >= 10)
            obj = ARROW10;
          else
            if (h >= 8)
              obj = ARROW8;
            else
              obj = ARROW6;

  switch (obj)
  {
    case ARROW6  : h =  6; break;
    case ARROW8  : h =  8; break;
    case ARROW10 : h = 10; break;
    case ARROW12 : h = 12; break;
    case ARROW14 : h = 14; break;
    case ARROW16 : h = 16; break;
    case ARROW32 : h = 32; break;
  } /* switch */

  x = box.x + (box.w - h) / 2;
  y = box.y + (box.h - h) / 2;

  bitblk = (BITBLK *)userimg [obj].ob_spec;

  d.mp  = NULL;                                 /* screen */
  s.mp  = (VOID *)bitblk->bi_pdata;
  s.fwp = bitblk->bi_wb << 3;
  s.fh  = bitblk->bi_hl;
  s.fww = bitblk->bi_wb >> 1;
  s.ff  = FALSE;
  s.np  = 1;

  pxy [0] = 0;
  pxy [1] = 0;
  pxy [2] = s.fwp - 1;
  pxy [3] = s.fh - 1;
  pxy [4] = x;
  pxy [5] = y;
  pxy [6] = x + pxy [2];
  pxy [7] = y + pxy [3];

  index [0] = color;
  index [1] = WHITE;

  vrt_cpyfm (out_handle, MD_TRANS, pxy, &s, &d, index);    /* copy it */
} /* draw_arrow */

/*****************************************************************************/

LOCAL VOID draw_acc_line (WORD vdi_handle, WORD inx, WORD x, WORD y, BYTE *text, BOOLEAN disabled, WORD dlg_colors, WORD bk_color, WORD text_color)
{
  WORD    w, h, xy [4];
  WORD    minimum, maximum, width;
  WORD    extent [8], distances [5], effects [3];
  LONGSTR s;

  if (inx != 0)
  {
    vqt_font_info (vdi_handle, &minimum, &maximum, distances, &width, effects);

    strncpy (s, text, LONGSTRLEN);
    s [inx - 1] = EOS;

    vqt_extent (vdi_handle, s, extent);

    w = extent [2] - extent [0] + effects [2];
    h = extent [5] - extent [3];

    xy [0] = x + w;
    xy [1] = y + h - ((gl_hbox <= 8) ? 1 : 2);

    s [0] = text [inx - 1];
    s [1] = EOS;

    vqt_extent (vdi_handle, s, extent);

    w = extent [2] - extent [0] + effects [2];
    h = extent [5] - extent [3];

    xy [2] = xy [0] + w - 1;
    xy [3] = xy [1];

    vswr_mode (vdi_handle, MD_TRANS);
    vsl_udsty (vdi_handle, 0xAAAA);
    vsl_type (vdi_handle, disabled ? (dlg_colors < 16) ? USERLINE : SOLID : SOLID);
    vsl_color (vdi_handle, disabled ? (dlg_colors < 16) ? BLACK : sys_colors [COLOR_DISABLED] : text_color);
    v_pline (vdi_handle, 2, xy);

    if (dlg_colors >= 16)
    {
      vsl_type (vdi_handle, SOLID);
      vsl_color (vdi_handle, disabled ? WHITE : bk_color);

      xy [0]++;
      xy [1]++;
      xy [2]++;
      xy [3]++;

      v_pline (vdi_handle, 2, xy);
    } /* if */
  } /* if */
} /* draw_acc_line */

/*****************************************************************************/

LOCAL VOID clear_area (out_handle, area)
WORD out_handle;
RECT *area;

{
  WORD xy [4];
  RECT r;

  r = *area;

  if ((r.w > 0) && (r.h > 0))
  {
    vswr_mode (out_handle, MD_REPLACE);         /* Modus = replace */
    vsf_interior (out_handle, FIS_SOLID);       /* Muster */
    vsf_color (out_handle, WHITE);              /* Farbe weiû */
    rect2array (&r, xy);                        /* Bereich setzen */
    vr_recfl (out_handle, xy);                  /* Bereich lîschen */
  } /* if */
} /* clear_area */

/*****************************************************************************/

LOCAL BOOLEAN check_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN    ok;
  WORD       obj, button;
  WORD       table, field;
  LONGSTR    s;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *tablename;
  BYTE       *fieldname;
  MFIELD     *mfield;
  MOBJECT    *mobject;
  SYSFORMAT  *sysformat;
  SYSMASK    *sysmask;
  BASE_SPEC  *base_spec;

  if (mask_spec->objs == 0) return (TRUE);

  base_spec = mask_spec->base_spec;
  sysformat = base_spec->sysformat;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [mask_spec->objs - 1];
  ok        = TRUE;

  for (obj = mask_spec->objs - 1; obj >= 0; obj--, mobject--)
  {
    mfield = &mobject->mfield;

    if (mfield->class == M_FIELD)
    {
      tablename = &sysmask->mask.buffer [mfield->table_name];
      fieldname = &sysmask->mask.buffer [mfield->field_name];

      strcpy (table_info.name, tablename);
      strcpy (field_info.name, fieldname);

      table = v_tableinfo (base_spec, FAILURE, &table_info);
      if (table == FAILURE)
      {
        ok = FALSE;
        sprintf (s, alerts [ERR_CHECKTABLE], table_info.name);
        button = open_alert (s);

        if (button == 1)
          mselfield (mask_spec->window, obj, FALSE);
        else
          del_mobject (mask_spec, obj);
      } /* if */
      else
      {
        field = v_fieldinfo (base_spec, table, FAILURE, &field_info);
        if (field == FAILURE)
        {
          ok = FALSE;
          sprintf (s, alerts [ERR_CHECKFIELD], field_info.name);
          button = open_alert (s);

          if (button == 1)
            mselfield (mask_spec->window, obj, FALSE);
          else
            del_mobject (mask_spec, obj);
        } /* if */
        else
          if (mfield->w < strlen (sysformat [field_info.format].format))
          {
            ok = FALSE;
            sprintf (s, alerts [ERR_FORMAT2LONG], field_info.name);
            open_alert (s);
          } /* if, else */
      } /* else */
    } /* if */
  } /* for */

  return (ok);
} /* check_mask */

/*****************************************************************************/

LOCAL BOOLEAN test_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ok, can_save;
  WORD    button;
  LONGSTR s;
  SYSMASK *sysmask;

  ok       = TRUE;
  sysmask  = &mask_spec->mask;
  can_save = mask_spec->base_spec->new || ! (mask_spec->base_spec->base->datainf->flags & BASE_RDONLY);

  check_mask (mask_spec);

  if (mask_spec->modified && can_save)
  {
    if (sysmask->tablename [0] == EOS)
    {
      button = hndl_alert (ERR_NOTBLNAME);
      if (button == 1)                  /* OK */
        if (mmaskinfo (mask_spec)) return (FALSE);

      mask_spec->abort = TRUE;
      return (TRUE);
    } /* if */

    sprintf (s, alerts [ERR_MNOTSAVED], mask_spec->base_spec->basename, mask_spec->mask.name);
    button = open_alert (s);

    switch (button)
    {
      case 1 : mask_spec->abort = FALSE;
               break;
      case 2 : mask_spec->abort = TRUE; /* don't save mask */
               break;
      case 3 : ok = FALSE;
               break;                   /* user clicked on CANCEL button */
    } /* switch */
  } /* if */

  return (ok);
} /* test_mask */

/*****************************************************************************/

LOCAL VOID get_rtext (p, s, index)
BYTE *p;
BYTE *s;
WORD index;

{
  WORD i;

  i  = 0;
  *s = EOS;

  if (p == NULL) return;

  while ((i < index) && (*p))
  {
    if (*p == RADIO_DELIMITER) i++;
    p++;
  } /* while */

  while ((*p != RADIO_DELIMITER) && (*p)) *s++ = *p++;

  *s = EOS;
} /* get_rtext */

/*****************************************************************************/

LOCAL VOID mselobj (window, obj)
WINDOWP window;
WORD    obj;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [obj];
  mfield    = &mobject->mfield;

  switch (mfield->class)
  {
    case M_FIELD   : mselfield (window, obj, TRUE); break;
    case M_LINE    : mlinesize (window, obj);       break;
    case M_BOX     : mobjsize (window, obj);        break;
    case M_RBOX    : mobjsize (window, obj);        break;
    case M_TEXT    : mseltext (window, obj);        break;
    case M_GRAF    : mpicsize (window, obj);        break;
    case M_BUTTON  : mselbutton (window, obj);      break;
    case M_SUBMASK : mselsubmask (window, obj);     break;
  } /* switch */
} /* mselobj */

/*****************************************************************************/

LOCAL VOID get_graf (window)
WINDOWP window;

{
  WORD      obj, pic, result;
  RECT      pos;
  GEMOBJP   gem;
  IMGOBJP   img;
  FULLNAME  path, s;
  FILENAME  name;
  BYTE      *filename;
  PICOBJ    *picobj;
  MGRAF     *mgraf;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;
  BASE_SPEC *base_spec;

  mask_spec = (MASK_SPEC *)window->special;
  base_spec = mask_spec->base_spec;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mgraf = &mobject->mgraf;

    if (mgraf->class == M_GRAF)
    {
      if (mask_spec->picptr >= mask_spec->max_pics)
      {
        hndl_alert (ERR_NOPICS);
        return;
      } /* if */

      obj2pos (mask_spec, obj, &pos);
      pic    = mask_spec->picptr;
      picobj = &mask_spec->picobj [pic];

      picobj->type = mgraf->type;
      filename     = &sysmask->mask.buffer [mgraf->filename];
      strcpy (picobj->filename, filename);
      strcpy (s, filename);

      switch (picobj->type)
      {
        case PIC_META  : gem             = &picobj->pic.gem;
                         gem->window     = window;
                         gem->pos        = pos;
                         gem->out_handle = vdi_handle;
                         result          = gem_obj (gem, GEM_INIT, GEM_FILE | GEM_BESTFIT, s);

                         if (result == GEM_FILENOTFOUND)        /* try again on basepath */
                         {
                           file_split (filename, NULL, path, name, NULL);
                           strcpy (s, base_spec->basepath);
                           strcat (s, name);
                           result = gem_obj (gem, GEM_INIT, GEM_FILE | GEM_BESTFIT, s);
                         } /* if */

                         switch (result)
                         {
                           case GEM_OK           : mask_spec->picptr++;             break;
                           case GEM_NOMEMORY     : hndl_alert (ERR_NOMEMORY);       break;
                           case GEM_FILENOTFOUND : file_error (ERR_FILEOPEN, name); break;
                         } /* switch */
                         break;
        case PIC_IMAGE : img         = &picobj->pic.img;
                         img->window = window;
                         img->pos    = pos;
                         result      = image_obj (img, IMG_INIT, IMG_FILE, s);

                         if (result == IMG_FILENOTFOUND)        /* try again on basepath */
                         {
                           file_split (filename, NULL, path, name, NULL);
                           strcpy (s, base_spec->basepath);
                           strcat (s, name);
                           result = image_obj (img, IMG_INIT, IMG_FILE, s);
                         } /* if */

                         switch (result)
                         {
                           case IMG_OK           : mask_spec->picptr++;             break;
                           case IMG_NOMEMORY     : hndl_alert (ERR_NOMEMORY);       break;
                           case IMG_FILENOTFOUND : file_error (ERR_FILEOPEN, name); break;
                         } /* switch */
                         break;
        case PIC_IFF   : break;
        case PIC_TIFF  : break;
      } /* switch */
    } /* if */
  } /* for */
} /* get_graf */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

LOCAL VOID obj_selall (window)
WINDOWP window;

{
  WORD      obj;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  if (window != sel_window) unclick_window (sel_window);
  sel_window = window;
  sel.class  = SEL_MOBJ;
  for (obj = 0; obj < mask_spec->objs; obj++) setincl (sel_objs, obj);
  set_redraw (window, &window->scroll);
} /* obj_selall */

/*****************************************************************************/

LOCAL VOID update_menu (window)
WINDOWP window;

{
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  if (mask_spec->modified && ! mask_spec->show_star)
  {
    mask_spec->show_star = TRUE;
    m_wi_title (window);
  } /* if */

  menu_check  (window->menu, MMTOOLS, mask_spec->show_tools);
} /* update_menu */

/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  BOOLEAN   redraw;
  BOOLEAN   work;
  RECT      r;
  FONTDESC  fontdesc;
  MASK_SPEC *mask_spec;

/* GS 5.1c Start: */
  WORD      obj;
  MFIELD    *mfield;
  MTEXT     *mtext;
  MBUTTON   *mbutton;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
/* Ende */

  mask_spec = (MASK_SPEC *)window->special;
  redraw    = FALSE;
  work      = FALSE;

  if (window != NULL) menu_normal (window, title, FALSE);

  switch (title)
  {
    case MMINFO   : if (item == MMASKINF)
                      if ((sel.class == SEL_NONE) || (window != sel_window))
                        info_mask (window, NIL);
                      else
                        hndl_alert (ERR_NOINFO);
                    break;
    case MMOPTION : xywh2rect (maskicon->ob_x, maskicon->ob_y, maskicon->ob_width, maskicon->ob_height, &r);

                    switch (item)
                    {
                      case MMTOOLS  : if (mask_spec->show_tools)   /* remove them */
                                      {
                                        window->scroll.y = window->work.y + menu_height;
                                        window->scroll.h = window->work.h - menu_height;
                                      } /* if */
                                      else
                                      {
                                        window->scroll.y = window->work.y + menu_height + iconheight;
                                        window->scroll.h = window->work.h - menu_height - iconheight;
                                        work = TRUE;
                                      } /* else */

                                      mask_spec->show_tools ^= TRUE;
                                      redraw = TRUE;
                                      break;
                      case MMCHECK  : check_mask (mask_spec);
                                      break;
                      case MMSORT   : unclick_window (window);
                                      m_sort_mask (mask_spec);
                                      mask_spec->modified = TRUE;
                                      redraw = TRUE;
                                      break;
                      case MMFONT   : fontdesc.font    = mask_spec->font;
                                      fontdesc.point   = mask_spec->point;
                                      fontdesc.effects = TXT_NORMAL;
                                      fontdesc.color   = BLACK;
/* GS 5.1c Start */
																		  sysmask   = &mask_spec->mask;
																		  mobject   = (MOBJECT *)sysmask->mask.buffer;
																		
																		  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
																		    if (setin (sel_objs, obj))
																		    {
																		      mfield   = &mobject->mfield;
																		      mtext    = &mobject->mtext;
																		      mbutton  = &mobject->mbutton;
																		
																		      switch (mfield->class)
																		      {
																		        case M_FIELD   : fontdesc.font  = mfield->font;
																		                         fontdesc.point = mfield->point;
																		                         fontdesc.color = mfield->color;
																		                         obj = mask_spec->objs;						/* Damit Schleife abgebrochen wird */
																		                         break;
																		        case M_TEXT    : fontdesc.font    = mtext->font;
																		                         fontdesc.point   = mtext->point;
																		                         fontdesc.color   = mtext->color;
																		                         fontdesc.effects = mtext->effects;
																		                         obj = mask_spec->objs;						/* Damit Schleife abgebrochen wird */
																		                         break;
																		        case M_BUTTON  : fontdesc.font  = mbutton->font;
																		                         fontdesc.point = mbutton->point;
																		                         fontdesc.color = mbutton->color;
																		                         obj = mask_spec->objs;						/* Damit Schleife abgebrochen wird */
																		                         break;
																		      } /* switch */
																		    } /* if, for */
/* Ende */
                                      if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc))
                                      {
                                        mask_spec->font  = fontdesc.font;
                                        mask_spec->point = fontdesc.point;

                                        if (sel.class == SEL_MOBJ) set_objfont (window, &fontdesc);
                                        if (mask_spec->show_tools) set_redraw (window, &r);
                                      } /* if */
                                      break;
                      case MMFILL   : if (mselfill (&mask_spec->color, &mask_spec->fill_style, &mask_spec->fill_index))
                                      {
                                        if (sel.class == SEL_MOBJ) set_objfill (window, mask_spec->fill_style, mask_spec->fill_index);
                                        if (mask_spec->show_tools) set_redraw (window, &r);
                                      } /* if */
                                      break;
                      case MMCOLOR  : if (mselfill (&mask_spec->color, &mask_spec->fill_style, &mask_spec->fill_index))
                                      {
                                        if (sel.class == SEL_MOBJ) set_objcolor (window, mask_spec->color);
                                        if (mask_spec->show_tools) set_redraw (window, &r);
                                      } /* if */
                                      break;
                      case MMLINES  : if (mselline (&mask_spec->line_type,
                                                    &mask_spec->line_width,
                                                    &mask_spec->line_bstyle,
                                                    &mask_spec->line_estyle))
                                      {
                                        if (sel.class == SEL_MOBJ) set_objline (window, mask_spec->line_type,
                                                                                        mask_spec->line_width,
                                                                                        mask_spec->line_bstyle,
                                                                                        mask_spec->line_estyle);
                                        set_redraw (window, &r);
                                      } /* if */
                                      break;
                      case MMGRID   : mselgrid (&mask_spec->grid_x, &mask_spec->grid_y);
                                      break;
                      case MMSIZE   : mselsize (&window->doc.w, &window->doc.h);
                                      set_sliders (window, HORIZONTAL + VERTICAL, SLPOS + SLSIZE);
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
  WORD      objs;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  objs      = mask_spec->objs;

  ret = TRUE;
  ext = (action & DO_EXTERNAL) != 0;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = FALSE;                              break;
    case DO_CUT    : ret = window == sel_window;               break;
    case DO_COPY   : ret = window == sel_window;               break;
    case DO_PASTE  : ret = ! empty_clipbrd (window, ext);      break;
    case DO_CLEAR  : ret = window == sel_window;               break;
    case DO_SELALL : ret = (objs > 0) && (window->opened > 0); break;
    case DO_CLOSE  : ret = test_mask (mask_spec);              break;
    case DO_DELETE :                                           break;
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
  WORD      i;
  PICOBJ    *picobj;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  busy_mouse ();

  if (! mask_spec->abort)
    if (! m_save_mask (mask_spec)) hndl_alert (ERR_MASKSAVE);

  picobj = mask_spec->picobj;

  for (i = 0; i < mask_spec->picptr; i++, picobj++)
    switch (picobj->type)
    {
      case PIC_META  : gem_obj (&picobj->pic.gem, GEM_EXIT, 0, NULL);   break;
      case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_EXIT, 0, NULL); break;
      case PIC_IFF   :                                                  break;
      case PIC_TIFF  :                                                  break;
    } /* switch, for */

  mem_free (mask_spec);
  set_meminfo ();
  arrow_mouse ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  WORD      xy [4];
  WORD      x, y, w, h, obj;
  RECT      r, old_clip;
  MBOX      mbox;
  STRING    name;
  BYTE      *p;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  if (mask_spec->show_tools)
  {
    x = window->work.x;
    y = window->work.y + menu_height;

    maskicon->ob_x = x;
    maskicon->ob_y = y;

    xywh2rect (x, y, iconwidth, iconheight, &r);

    if (rc_intersect (&clip, &r))
    {
      old_clip = clip;

      for (obj = MIARROW; obj <= MIMASK; obj++) undo_state (maskicon, obj, SELECTED);
      do_state (maskicon, mask_spec->tool, SELECTED);

      FontNameFromNumber (name, mask_spec->font);
      name [FONT_NAMELEN] = EOS;

      p = &name [strlen (name) - 1];    /* kill blanks at right edge */
      while (*p == ' ') p--;
      p++;
      *p = EOS;

      set_str (maskicon, MIFONT, name);

      sprintf (name, "%2d", mask_spec->point);
      p = get_str (maskicon, MIPOINT);
      *p++ = name [0];
      *p++ = name [1];

      objc_draw (maskicon, ROOT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

      objc_offset (maskicon, MIFILL, &x, &y);
      xywh2rect (x, y, maskicon [MIFILL].ob_width, maskicon [MIFILL].ob_height, &r);

      mbox.color = mask_spec->color;
      mbox.style = mask_spec->fill_style;
      mbox.index = mask_spec->fill_index;
      draw_box (window, vdi_handle, (MOBJECT *)&mbox, &r, FALSE, WHITE);

      objc_offset (maskicon, MILINES, &x, &y);
      w = maskicon [MILINES].ob_width;
      h = maskicon [MILINES].ob_height;

      xywh2rect (x, y, w, h, &r);
      rc_intersect (&clip, &r);
      set_clip (TRUE, &r);

      xy [0] = x + gl_wbox;
      xy [1] = y + h / 2;
      xy [2] = x + w - 1 - gl_wbox;
      xy [3] = xy [1];

      line_default (vdi_handle);
      vsl_type (vdi_handle, mask_spec->line_type);
      vsl_width (vdi_handle, mask_spec->line_width);
      vsl_ends (vdi_handle, mask_spec->line_bstyle, mask_spec->line_estyle);
      vsl_color (vdi_handle, mask_spec->color);
      v_pline (vdi_handle, 2, xy);

      set_clip (TRUE, &old_clip);
    } /* if */
  } /* if */

  r = clip;

  if (rc_intersect (&window->scroll, &r))
  {
    set_clip (TRUE, &r);
    draw_mask (window, vdi_handle);
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
  RECT r, diff;
  WORD wbox, hbox;
  LONG max_xdoc, max_ydoc;

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
  WORD      i;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  for (i = 0; i < mask_spec->objs; i++)         /* look at all selected objects */
    if (setin (objs, i))
      switch (action)
      {
        case OBJ_OPEN : switch (sel.class)
                        {
                          case SEL_MOBJ : mselobj (window, i);
                                          break;
                          default       : hndl_alert (ERR_NOOPEN);
                                          break;
                        } /* switch */
                        break;
        case OBJ_INFO : if (sel.class == SEL_NONE)
                          mmaskinfo (mask_spec);
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

  if (src_window->class == CLASS_BASE) action = DRAG_OK;

  return (action);
} /* wi_drag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  m_click (window, mk);
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
  m_unclick (window);
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

LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg)
{
  WORD      i;
  FULLNAME  szFilename;
  PICOBJ    *picobj;
  BYTE      *pFilename;
  MASK_SPEC *mask_spec;

  if (msg [0] == OLGA_UPDATED)
  {
    if (olga_apid >= 0)		/* search for objects with corresponding filename */
    {
      pFilename = (BYTE *)*(LONG *)(msg + 3);
      mask_spec = (MASK_SPEC *)window->special;
      picobj    = mask_spec->picobj;

      str_upper (pFilename);

      for (i = 0; i < mask_spec->picptr; i++, picobj++)
      {
        GetPicFilename (mask_spec, szFilename, picobj->filename);

        if (strcmp (pFilename, szFilename) == 0)
        {
          switch (picobj->type)
          {
            case PIC_META  : gem_obj (&picobj->pic.gem, GEM_UPDATE, 0, NULL);
                             break;
            case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_UPDATE, 0, NULL);
                             break;
            case PIC_IFF   : break;
            case PIC_TIFF  : break;
          } /* switch */

          m_updpicfile (mask_spec, i);
        } /* if */
      } /* for */
    } /* if */

    return (FALSE);	/* let other mask windows also handle this message */
  } /* if */

  return (FALSE);
} /* wi_message */

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
                       m_obj_clear (window, sel.class, sel_objs);
                     break;
    case DO_COPY   : copy2clipbrd (window, sel.class, sel_objs, ext);
                     break;
    case DO_PASTE  : paste_clipbrd (window, NULL, ext);
                     break;
    case DO_CLEAR  : m_obj_clear (window, sel.class, sel_objs);
                     break;
    case DO_SELALL : obj_selall (window);
                     break;
  } /* switch */
} /* wi_edit */

