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
 * 27.01.04: wi_message an neue öbergabe angepasst.
 * 28.12.02: Wird eine Verzweigung auf sich selbst dargestellt erscheint kein
 *           Compobox mehr (col_popup).
 *           Befindet sich die Compobax ausserhalb des Fensters wird sie nicht
 *					 mehr gezeichnet.
 * 21.12.02: Redraw in col_popup weiter nachhinten geschoben
 * 08.11.02: D&D fÅr Masken-Fenster
 * 19.03.97: HandleOlgaUpdated added for submask handling
 * 11.03.97: Function wi_message & RedrawPicobj for use with OLGA added
 * 08.10.96: Call to str2format added in m_varsql2sql
 * 15.11.95: Put actual item in db->buffer in col_popup
 * 09.10.95: Positioning error corrected in col_popup
 * 21.09.95: Function col_popup modified to work with new combo boxes
 * 30.03.95: Redraw all submasks on wi_top
 * 23.03.95: Wildcard * now allowed in m_varsql2sql
 * 20.03.95: SetBuffer added
 * 19.03.95: Cut, copy, paste is working with submasks now (see wi_edit)
 * 28.02.95: Variable initializing of act_obj, act_sub, last_obj moved to mu_crt_spec
 * 22.02.95: Call to mfix_iconbar in wi_draw moved before call to objc_draw
 * 21.02.95: Function med_first added
 * 16.02.95: Functions ed_next, ed_prev completed for submasks
 * 02.02.95: Parameter TRUE added to call to m_all_fields in m_do_undo
 * 27.01.95: Clear buffer can only be used if there are no submasks in a mask, see m_do_undo
 * 19.01.95: Parameter window changed to mask_spec in all functions
 * 17.01.95: Parameter window changed to mask_spec in wi_draw
 * 11.01.95: Character ' replaced with " in m_varsql2sql
 * 03.01.95: Using new function names of controls module
 * 13.12.94: Function GetParm, *_getparm added
 * 08.12.94: Parameter is_submask added in mset_buffer
 * 01.12.94: Function m_varsql2sql added
 * 21.11.94: Call to mu_sm_init added where necessary
 * 12.10.94: Call to mu_sm_init added in crt_mask
 * 11.10.94: Function mu_crt_spec will now be used in crt_mask
 * 27.08.94: Handling of SM_SHOW_INFO added
 * 24.08.94: Handling of SM_SHOW_MENU added
 * 16.08.94: Flag clear_bufferd set to FALSE in col_popup
 * 25.06.94: pCalcEntry & pCalcExit dynamic memory allocation error corrected in crt_mask
 * 19.05.94: Call to m_search_full used in mask_search
 * 17.05.94: Test on multi index in update_menu added
 * 14.05.94: Function mask_search added
 * 11.05.94: Clipping set correctly in wi_edit
 * 02.05.94: Info moved to MASKINFO struct in MASK.H
 * 25.04.94: Enable page up/down in multiline edit fields in wi_key
 * 21.04.94: Handling of cut, copy, paste added in wi_test
 * 06.12.93: Save old clipping on text import in handle_menu
 * 07.11.93: Height of masks with heights larger than screen height not subtracted by 4 * gl_hbox in ctr_mask
 * 04.11.93: Call to clr_scroll deleted in wi_draw
 * 02.11.93: No longer using large stack variables in callback
 * 28.10.93: Always using LBS_OWNERDRAW for comboboxes
 * 09.10.93: Info lines if redrawed if windows size changes in wi_snap
 * 08.10.93: New combobox used, new_index moved to mclick.c
 * 27.09.93: INITY changed
 * 09.09.93: Function set_redraw called because of smart redraws in wi_snap
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "dd.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "cbobj.h"
#include "rbobj.h"
#include "editobj.h"
#include "emptyobj.h"
#include "gemobj.h"
#include "imageobj.h"

#include "desktop.h"
#include "dialog.h"
#include "maskobj.h"
#include "maskdraw.h"
#include "maskutil.h"
#include "mclick.h"
#include "printer.h"
#include "resource.h"

#include "export.h"
#include "mask.h"

/****** DEFINES **************************************************************/

#define KIND    (NAME|CLOSER|FULLER|MOVER|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS   (WI_TOPMENU)
#define XFAC    gl_wbox                 /* X-Faktor */
#define YFAC    gl_hbox                 /* Y-Faktor */
#define XUNITS  1                       /* X-Einheiten fÅr Scrolling */
#define YUNITS  1                       /* Y-Einheiten fÅr Scrolling */
#define INITX   ( 2 * gl_wbox)          /* X-Anfangsposition */
#define INITY   ( 6 * gl_hbox + 10)     /* Y-Anfangsposition */
#define INITW   (74 * gl_wbox)          /* Anfangsbreite in Pixel */
#define INITH   (16 * gl_hbox)          /* Anfangshîhe in Pixel */
#define MILLI   0                       /* Millisekunden fÅr Zeitablauf */
#define START_X (20 * gl_wbox)          /* X-Anfangsposition fÅr Groûbildschirme */

#define COL_VISIBLE   6                 /* number of visible record for col_popup */

#define LU_DRAW       1                 /* draw lookup cols */
#define LU_COPY       2                 /* copy lookup cols */

#define CHR_MASKSEP    '.'		/* used in function m_varsql2sql, format is {MASK.FIELD} */
#define CHR_LEFTBRACK  '{'		/* enclosing variables */
#define CHR_RIGHTBRACK '}'

#define MAX_PARM       60		/* 40 chars max for parameters in get_getparm, see resource file */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD   dstcol;
  WORD   refcol;
  RECT   ed_pos;
  MFIELD *mfield;
} LU;

typedef struct
{
  LONGSTR   itemstr;
  MASK_SPEC *mask_spec;
  WORD      dsttbl;
  WORD      dstcol;
  WORD      reftbl;
  WORD      refcol;
  WORD      refinx;
  CURSOR    cursor;
  LONG      lastfetched;
  WINDOWP   window;
  WORD      num_lus;
  LU        lu [MAX_LUS];
  BOOLEAN   first;
  HLB       hlb;
  WORD      font;
  WORD      point;
  WORD      color;
} POPINFO;

/****** VARIABLES ************************************************************/

LOCAL WORD exit_obj;	/* for getparm dialog */
LOCAL BYTE *pDlgValue;	/* for getparm dialog */

/****** FUNCTIONS ************************************************************/

LOCAL LONG       cb_callback       (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL VOID       hndl_items        (POPINFO *popinfo, WORD mode, BYTE *buffer, BOOLEAN useref);
LOCAL WORD       fill_lus          (MASK_SPEC *mask_spec, POPINFO *popinfo, BOOLEAN do_it);
LOCAL PMASK_SPEC ed_first          (WINDOWP window);
LOCAL PMASK_SPEC ed_last           (WINDOWP window);
LOCAL PMASK_SPEC ed_next           (WINDOWP window);
LOCAL PMASK_SPEC ed_prev           (WINDOWP window);
LOCAL LONG       callback          (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL BOOLEAN    test_mask         (MASK_SPEC *mask_spec);
LOCAL BOOL       LoadCalc          (DB *db, SHORT sTable, BYTE *pCalcName, CALCCODE *pCalcCode);
LOCAL VOID       SetBuffer         (MASK_SPEC *mask_spec, DB *db, WORD table, LONG address, RECT *area);
LOCAL VOID       RedrawPicobj      (MASK_SPEC *mask_spec, WORD wPic);
LOCAL VOID       HandleOlgaUpdated (MASK_SPEC *mask_spec, BYTE *pFilename);

LOCAL VOID       click_mconfig     (WINDOWP window, MKINFO *mk);
LOCAL BOOLEAN    key_mconfig       (WINDOWP window, MKINFO *mk);

LOCAL BOOL       GetParm           (BYTE *pParm, BYTE *pValue);
LOCAL VOID       get_getparm       (VOID);
LOCAL VOID       set_getparm       (BYTE *pParm);
LOCAL VOID       click_getparm     (WINDOWP window, MKINFO *mk);

LOCAL VOID       msave             (WINDOWP window);
LOCAL VOID       minsert           (WINDOWP window);
LOCAL VOID       mupdate           (WINDOWP window);
LOCAL VOID       mdelete           (WINDOWP window);
LOCAL VOID       msearch           (WINDOWP window, BOOLEAN bMulti);
LOCAL VOID       mclear            (WINDOWP window);
LOCAL VOID       mprev             (WINDOWP window);
LOCAL VOID       mnext             (WINDOWP window);
LOCAL VOID       mfirst            (WINDOWP window);
LOCAL VOID       mlast             (WINDOWP window);
LOCAL VOID       mcalc             (WINDOWP window);

LOCAL BOOLEAN    can_save          (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_insert        (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_update        (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_delete        (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_search        (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_prev          (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_next          (MASK_SPEC *mask_spec);
LOCAL BOOLEAN    can_calc          (MASK_SPEC *mask_spec);

LOCAL VOID       update_menu       (WINDOWP window);
LOCAL VOID       handle_menu       (WINDOWP window, WORD title, WORD item);
LOCAL VOID       box               (WINDOWP window, BOOLEAN grow);
LOCAL BOOLEAN    wi_test           (WINDOWP window, WORD action);
LOCAL VOID       wi_open           (WINDOWP window);
LOCAL VOID       wi_close          (WINDOWP window);
LOCAL VOID       wi_delete         (WINDOWP window);
LOCAL VOID       wi_draw           (WINDOWP window);
LOCAL VOID       wi_arrow          (WINDOWP window, WORD dir, LONG oldpos, LONG newpos);
LOCAL VOID       wi_snap           (WINDOWP window, RECT *new, WORD mode);
LOCAL VOID       wi_objop          (WINDOWP window, SET objs, WORD action);
LOCAL WORD       wi_drag           (WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj);
LOCAL VOID       wi_click          (WINDOWP window, MKINFO *mk);
LOCAL VOID       wi_unclick        (WINDOWP window);
LOCAL BOOLEAN    wi_key            (WINDOWP window, MKINFO *mk);
LOCAL VOID       wi_timer          (WINDOWP window);
/* [GS] 5.1d Start: */
LOCAL BOOLEAN wi_message 					 (WINDOWP window, WORD *msg, MKINFO *mk);
/* Ende; alt:
LOCAL BOOLEAN wi_message      		 (WINDOWP window, WORD *msg);
*/
LOCAL VOID       wi_top            (WINDOWP window);
LOCAL VOID       wi_untop          (WINDOWP window);
LOCAL VOID       wi_edit           (WINDOWP window, WORD action);

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_mask ()

{
  WORD obj;

  obj = ROOT;

  do
  {
    if (is_type (maskicon, obj, G_BUTTON))
      maskicon [obj].ob_y = 4;
  } while (! is_flags (maskicon, obj++, LASTOB));

  maskicon [ROOT].ob_width   = maskicon [MIINFO].ob_width = maskicon [MIBOX].ob_width = desk.w;
  maskicon [MIBOX].ob_height = maskicon [MIASC].ob_y + maskicon [MIASC].ob_height + 4;
  maskicon [MIINFO].ob_height++;
  maskicon [MIBOX].ob_y      = maskicon [MIINFO].ob_height;
  maskicon [ROOT].ob_height  = maskicon [MIINFO].ob_height + maskicon [MIBOX].ob_height;
  maskicon [MIINDEX].ob_y    = (maskicon [MIBOX].ob_height - maskicon [MIINDEX].ob_height) / 2;
  maskicon [MIORDER].ob_y    = (maskicon [MIINFO].ob_height - maskicon [MIORDER].ob_height) / 2;

  mask_info.num_chars  = maskicon [MIINDEX].ob_width / gl_wbox;
  mask_info.infoheight = maskicon [MIINFO].ob_height;
  mask_info.iconwidth  = maskicon [MIDELETE].ob_x + maskicon [MIDELETE].ob_width + gl_wbox;	/* leave a litte space */
  mask_info.iconheight = maskicon->ob_height + 1 - mask_info.infoheight;

  ListBoxSetCallback (maskicon, MIINDEX, callback);
  ListBoxSetStyle (maskicon, MIINDEX, LBS_VSCROLL | LBS_VREALTIME | LBS_OWNERDRAW, TRUE);
  ListBoxSetLeftOffset (maskicon, MIINDEX, gl_wbox / 2);

  get_mconfig ();
  mu_init ();
  m_init ();

  return (TRUE);
} /* init_mask */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_mask ()

{
  m_exit ();

  return (TRUE);
} /* term_mask */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_mask (obj, menu, icon, db, table, inx, dir, maskname, keyval, address, db_buffer, rcSize, bCalcEntry)
OBJECT *obj, *menu;
WORD   icon;
DB     *db;
WORD   table, inx, dir;
BYTE   *maskname;
KEY    keyval;
LONG   address;
VOID   *db_buffer;
RECT   *rcSize;
BOOL   bCalcEntry;

{
  WORD      menu_height, num, diff, err;
  WORD      ob_height, ob_width;
  WORD      w, h, max_w, max_h;
  RECT      r;
  WINDOWP   window;
  MASK_SPEC *mask_spec;

  mask_spec = mu_crt_spec (NULL, NULL, db, table, inx, dir, maskname, keyval, address, db_buffer, bCalcEntry, 0, 0, TRUE);

  if (mask_spec == NULL) return (NULL);

  if (! (mask_spec->sm_flags & SM_SHOW_ICONS)) obj = NULL;
  ob_width   = (obj != NULL) ? mask_info.iconwidth  : 0;
  ob_height  = (obj != NULL) ? mask_info.iconheight : 0;

  if (mask_spec->sm_flags & SM_SHOW_INFO) ob_height += mask_info.infoheight;	/* show info bar */

  window = create_window (KIND, CLASS_MASK);

  if (window != NULL)
  {
    mask_spec->window = window;

    if (! (mask_spec->sm_flags & SM_SHOW_MENU)) menu = NULL;

    num         = num_windows (CLASS_MASK, SRCH_ANY, NULL);
    menu_height = (menu != NULL) ? gl_hattr : 0;

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
    window->scroll.x  = INITX + num * window->xfac;
    window->scroll.y  = INITY + num * window->yfac + menu_height + ob_height;
    window->scroll.w  = INITW;
    window->scroll.h  = INITH;
    window->work.x    = window->scroll.x;
    window->work.y    = window->scroll.y - menu_height - ob_height;
    window->work.w    = window->scroll.w;
    window->work.h    = window->scroll.h + menu_height + ob_height;
    window->mousenum  = ARROW;
    window->mouseform = NULL;
    window->milli     = MILLI;
    window->special   = (LONG)mask_spec;
    window->object    = NULL;
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
    window->objop     = NULL;
    window->drag      = wi_drag;
    window->click     = wi_click;
    window->unclick   = wi_unclick;
    window->key       = wi_key;
    window->timer     = NULL;
    window->message   = wi_message;
    window->top       = wi_top;
    window->untop     = wi_untop;
    window->edit      = wi_edit;
    window->showinfo  = info_mask;
    window->showhelp  = help_mask;

    m_get_doc (mask_spec, &window->doc.w, &window->doc.h);
    
    w = window->doc.w;
    h = window->doc.h;

    if (rcSize != NULL) rect2xywh (rcSize, &mask_spec->mask->x, &mask_spec->mask->y, &mask_spec->mask->w, &mask_spec->mask->h);
    
    if (! is_null (TYPE_WORD, &mask_spec->mask->x)) window->scroll.x = mask_spec->mask->x * window->xfac;
    if (! is_null (TYPE_WORD, &mask_spec->mask->y)) window->scroll.y = mask_spec->mask->y * window->yfac + menu_height + ob_height + desk.y;
    if (! is_null (TYPE_WORD, &mask_spec->mask->w)) w = mask_spec->mask->w;
    if (! is_null (TYPE_WORD, &mask_spec->mask->h)) h = mask_spec->mask->h;

    window->scroll.w = w * window->xfac + gl_wbox;	/* looks better cause of icon bar */
    window->scroll.h = h * window->yfac + gl_hbox;

    max_w = desk.x + desk.w - window->scroll.x - 4 * gl_wbox;
    max_h = desk.y + desk.h - window->scroll.y;

    if (h < max_h) max_h -= 4 * gl_hbox;	/* looks better for standard mask height */

    if (! is_null (TYPE_WORD, &mask_spec->mask->w))
      if (w * window->xfac > max_w) max_w = desk.x + desk.w - window->scroll.x - gl_wbox;

    if (! is_null (TYPE_WORD, &mask_spec->mask->h))
      if (h * window->yfac > max_h) max_h = desk.y + desk.h - window->scroll.y - gl_hbox;

    if (is_null (TYPE_WORD, &mask_spec->mask->w))
      if (window->scroll.w < ob_width) window->scroll.w = ob_width;

    if (menu != NULL)
    {
      ob_width = menu [THEACTIVE].ob_width;
      if (window->scroll.w < ob_width) window->flags |= WI_MNSCROLL;
    } /* if */

    if (window->scroll.w > max_w) window->scroll.w = max_w;

    window->scroll.w = window->scroll.w / window->xfac * window->xfac;
    window->scroll.h = min (window->scroll.h, max_h) / window->yfac * window->yfac;
    window->scroll.x = desk.x + desk.w - 4 * gl_wbox - window->scroll.w;        /* put it at right side of desktop */
    if (window->scroll.x > START_X) window->scroll.x = START_X;

    if (! is_null (TYPE_WORD, &mask_spec->mask->x)) window->scroll.x = mask_spec->mask->x * window->xfac;

    window->work.x = window->scroll.x;
    window->work.y = window->scroll.y - menu_height - ob_height;
    window->work.w = window->scroll.w;
    window->work.h = window->scroll.h + menu_height + ob_height;

    if (! is_null (TYPE_WORD, &mask_spec->mask->x))	/* if window is too large, correct the size */
    {
      wind_calc (WC_BORDER, window->kind, window->work.x, window->work.y, window->work.w, window->work.h, &r.x, &r.y, &r.w, &r.h);
      diff = r.w - desk.w;
      if (diff > 0)
      {
        window->scroll.w -= diff;
        window->scroll.w  = window->scroll.w / window->xfac * window->xfac;
        window->work.w    = window->scroll.w;
      } /* if */
    } /* if */

    if (! is_null (TYPE_WORD, &mask_spec->mask->y))	/* if window is too large, correct the size */
    {
      wind_calc (WC_BORDER, window->kind, window->work.x, window->work.y, window->work.w, window->work.h, &r.x, &r.y, &r.w, &r.h);
      diff = window->work.y - r.y;
      if (diff > 0)
      {
        window->scroll.y += diff;
        window->scroll.h -= diff;
        window->work.y   += diff;
        window->work.h   -= diff;
      } /* if */
    } /* if */

    err = m_sm_init (mask_spec);
    if (err != SUCCESS)
    {
      switch (err)
      {
        case MO_NOMEMORY : hndl_alert (ERR_NOMEMORY);
      } /* switch */

      delete_window (window);
      return (NULL);
    } /* if */

    ed_first (window);			/* set to first edit object */
    mu_get_graf (mask_spec);

    m_winame ((MASK_SPEC *)window->special);
    mset_info (window);
    set_meminfo ();
  } /* if */
  else
    mu_free (mask_spec, TRUE);

  return (window);                      /* Fenster zurÅckgeben */
} /* crt_mask */

/*****************************************************************************/
/* ôffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_mask (icon, db, table, inx, dir, maskname, keyval, address, db_buffer, rcSize, bCalcEntry)
WORD   icon;
DB     *db;
WORD   table, inx, dir;
BYTE   *maskname;
KEY    keyval;
LONG   address;
VOID   *db_buffer;
RECT   *rcSize;
BOOL   bCalcEntry;

{
  BOOLEAN ok;
  WINDOWP window;

  window = search_window (CLASS_MASK, SRCH_CLOSED, icon);
  if (window == NULL)
  {
    busy_mouse ();      /* creating takes some time */
    window = crt_mask (maskicon, maskmenu, icon, db, table, inx, dir, maskname, keyval, address, db_buffer, rcSize, bCalcEntry);
    arrow_mouse ();
  } /* if */

  ok = window != NULL;

  if (ok)
  {
    ok = open_window (window);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_mask */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_mask (window, icon)
WINDOWP window;
WORD    icon;

{
  if (icon != NIL)
    window = search_window (CLASS_MASK, SRCH_ANY, icon);

  if (window != NULL)
  {
    hndl_alert (ERR_NOINFO);
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

GLOBAL BOOLEAN close_mask (db)
DB *db;

{
  WORD      num, i;
  WINDOWP   window;
  WINDOWP   windows [MAX_GEMWIND];
  MASK_SPEC *mask_spec;

  num = num_windows (CLASS_MASK, SRCH_ANY, windows);

  for (i = 0; i < num; i++)
  {
    window    = windows [i];
    mask_spec = (MASK_SPEC *)window->special;

    if (mask_spec->db == db)
    {
      delete_window (window);
      if (search_window (CLASS_MASK, SRCH_ANY, NIL) == window) return (FALSE);
    } /* if */
  } /* for */

  return (TRUE);
} /* close_mask */

/*****************************************************************************/

GLOBAL VOID mmconfig ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, MASKCONF);

  if (window == NULL)
  {
    form_center (maskconf, &ret, &ret, &ret, &ret);
    window = crt_dialog (maskconf, NULL, MASKCONF, FREETXT (FMCONFIG), wi_modeless);

    if (window != NULL)
    {
      window->click = click_mconfig;
      window->key   = key_mconfig;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (maskconf, ROOT, EDITABLE);
      window->edit_inx = NIL;

      set_mconfig ();
    } /* if */

    if (! open_dialog (MASKCONF)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mconfig */

/*****************************************************************************/

GLOBAL VOID get_mconfig ()

{
  mask_config.clear       = get_checkbox (maskconf, MCCLEAR);
  mask_config.fsel        = get_checkbox (maskconf, MCFSEL);
  mask_config.pospopup    = get_checkbox (maskconf, MCPOSPOP);
  mask_config.ask_delete  = get_checkbox (maskconf, MCDELETE);
  mask_config.play_direct = get_checkbox (maskconf, MCPLAY);

  mask_config.volume = get_word (maskconf, MCVOLUME);
} /* get_mconfig */

/*****************************************************************************/

GLOBAL VOID set_mconfig ()

{
  BYTE *p;

  set_checkbox (maskconf, MCCLEAR,  mask_config.clear);
  set_checkbox (maskconf, MCFSEL,   mask_config.fsel);
  set_checkbox (maskconf, MCPOSPOP, mask_config.pospopup);
  set_checkbox (maskconf, MCDELETE, mask_config.ask_delete);
  set_checkbox (maskconf, MCPLAY,   mask_config.play_direct);

  set_word (maskconf, MCVOLUME, mask_config.volume);

  p =  get_str (maskconf, MCVOLUME);
  if ((*p == EOS) == ! is_state (maskconf, MCOK, DISABLED)) flip_state (maskconf, MCOK, DISABLED);
} /* set_mconfig */

/*****************************************************************************/

GLOBAL WORD find_index (base, table, col)
BASE *base;
WORD table;
WORD col;

{
  WORD       index;
  TABLE_INFO table_info;
  INDEX_INFO index_info;

  db_tableinfo (base, table, &table_info);

  for (index = 0; index < table_info.indexes; index++)
    if (db_indexinfo (base, table, index, &index_info) != FAILURE)
      if ((index_info.inxcols.size / sizeof (INXCOL) == 1) &&   /* single key field */
          (index_info.inxcols.cols [0].col == col)) return (index);

  return (FAILURE);
} /* find_index */

/*****************************************************************************/

GLOBAL WORD get_inxcols (base, table, inx, cols)
BASE *base;
WORD table;
WORD inx;
WORD *cols;

{
  WORD       num, i;
  INDEX_INFO index_info;

  if (db_indexinfo (base, table, inx, &index_info) != FAILURE)
  {
    num = index_info.inxcols.size / sizeof (INXCOL);
    for (i = 0; i < num; i++)
      cols [i] = index_info.inxcols.cols [i].col;

    return (num);
  } /* if */

  return (0);
} /* get_inxcols */

/*****************************************************************************/

GLOBAL VOID print_mask (window)
WINDOWP window;

{
  m_print ((MASK_SPEC *)window->special);
} /* print_mask */

/*****************************************************************************/

GLOBAL VOID mmaskreverse (window)
WINDOWP window;

{
  WORD      edobj;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  if (! m_save_all (mask_spec, &edobj)) return;

  if (sel_window == window) unclick_window (window);
  mask_spec->dir = -mask_spec->dir;

  if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor))
    if (v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir))
    {
      mask_spec->clear_buffered = FALSE;
      m_do_undo (window, FALSE);
    } /* if */

  mfix_iconbar (window);

  if (mask_spec->sm_flags & SM_SHOW_ICONS)
  {
    draw_win_obj (window, maskicon, MIASC);
    draw_win_obj (window, maskicon, MIDESC);

    draw_win_obj (window, maskicon, MIFIRST);
    draw_win_obj (window, maskicon, MIPREV);
    draw_win_obj (window, maskicon, MINEXT);
    draw_win_obj (window, maskicon, MILAST);
    draw_win_obj (window, maskicon, MISAVE);
    draw_win_obj (window, maskicon, MIDELETE);
  } /* if */

  mset_info (window);
} /* mmaskreverse */

/*****************************************************************************/

GLOBAL VOID mask_search (window, cont)
WINDOWP window;
BOOLEAN cont;

{
  m_search_full ((MASK_SPEC *)window->special, cont);
} /* mask_search */

/*****************************************************************************/

GLOBAL VOID mset_info (window)
WINDOWP window;

{
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  sort_name (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, window->info);
  if (window->opened > 0)
  {
    strcpy (get_str (maskicon, MIORDER), window->info);
    draw_win_obj (window, maskicon, MIORDER);
  } /* if */
} /* mset_info */

/*****************************************************************************/

GLOBAL VOID mset_buffer (window, db, table, address)
WINDOWP window;
DB      *db;
WORD    table;
LONG    address;

{
  BOOLEAN   in_arrow, is_button, is_graf, is_submask;
  WORD      obj, sub;
  MKINFO    mk;
  RECT      frame;
  FATTR     fattr;
  EDFIELD   *ed_field;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  frame     = mask_spec->window->scroll;

  graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
  obj = m_find_obj (mask_spec, &mk, &in_arrow, &is_button, &is_submask, &is_graf, &sub);

  if (is_submask)	/* update only frame of submask in SetBuffer */
  {
    sysmask   = mask_spec->mask;
    ed_field  = &mask_spec->ed_field [obj];
    mobject   = (MOBJECT *)sysmask->mask.buffer;
    mobject   = &mobject [ed_field->obj];
    msubmask  = &mobject->msubmask;
    m_get_rect (mask_spec, vdi_handle, msubmask->class, mobject, &frame, &fattr);
    mask_spec = mask_spec->Submask [sub].pMaskSpec;
  } /* if */

  SetBuffer (mask_spec, db, table, address, &frame);
} /* mset_buffer */

/*****************************************************************************/

GLOBAL VOID mfix_iconbar (WINDOWP window)
{
  WORD      menu_height;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  menu_height                 = (window->menu != NULL) ? gl_hattr : 0;
  maskicon->ob_x              = window->work.x;
  maskicon->ob_y              = window->work.y + menu_height;
  maskicon [MIORDER].ob_width = window->work.w - 2 * gl_wbox + 2;

  strcpy (get_str (maskicon, MIORDER), window->info);

  if (can_prev (mask_spec))
  {
    undo_state (maskicon, MIFIRST, DISABLED);
    undo_state (maskicon, MIPREV,  DISABLED);
  } /* if */
  else
  {
    do_state (maskicon, MIFIRST, DISABLED);
    do_state (maskicon, MIPREV,  DISABLED);
  } /* else */

  if (can_next (mask_spec))
  {
    undo_state (maskicon, MINEXT, DISABLED);
    undo_state (maskicon, MILAST, DISABLED);
  } /* if */
  else
  {
    do_state (maskicon, MINEXT, DISABLED);
    do_state (maskicon, MILAST, DISABLED);
  } /* else */

  if (can_save (mask_spec))
    undo_state (maskicon, MISAVE, DISABLED);
  else
    do_state (maskicon, MISAVE, DISABLED);

  if (can_delete (mask_spec))
    undo_state (maskicon, MIDELETE, DISABLED);
  else
    do_state (maskicon, MIDELETE, DISABLED);

  if (can_search (mask_spec))
    undo_state (maskicon, MISEARCH, DISABLED);
  else
    do_state (maskicon, MISEARCH, DISABLED);

  if (can_calc (mask_spec))
    undo_state (maskicon, MICALC, DISABLED);
  else
    do_state (maskicon, MICALC, DISABLED);

  if (VTBL (mask_spec->table) || (mask_spec->table < NUM_SYSTABLES))
  {
    strcpy (get_str (maskicon, MIINDEX), "");
    do_state (maskicon, MIINDEX, DISABLED);

    ListBoxSetCount (maskicon, MIINDEX, 0, NULL);
    ListBoxSetCurSel (maskicon, MIINDEX, FAILURE);
  } /* if */
  else
  {
    strncpy (get_str (maskicon, MIINDEX), mask_spec->db->t_info [tableinx (mask_spec->db, mask_spec->table)].i_info [indexinx (mask_spec->db, mask_spec->table, mask_spec->inx)].indexname, mask_info.num_chars);
    undo_state (maskicon, MIINDEX, DISABLED);

    ListBoxSetCount (maskicon, MIINDEX, mask_spec->db->t_info [tableinx (mask_spec->db, mask_spec->table)].indexes, NULL);
    ListBoxSetCurSel (maskicon, MIINDEX, indexinx (mask_spec->db, mask_spec->table, mask_spec->inx));
  } /* else */

  ListBoxSetSpec (maskicon, MIINDEX, (LONG)window);

  set_rbutton (maskicon, (mask_spec->dir == ASCENDING) ? MIASC : MIDESC, MIASC, MIDESC);

  if (mask_spec->sm_flags & SM_SHOW_INFO)
  {
    undo_flags (maskicon, MIINFO, HIDETREE);
    undo_flags (maskicon, MIORDER, HIDETREE);

    maskicon [MIBOX].ob_y     = maskicon [MIINFO].ob_height;
    maskicon [ROOT].ob_height = maskicon [MIINFO].ob_height + maskicon [MIBOX].ob_height;
  } /* if */
  else
  {
    do_flags (maskicon, MIINFO, HIDETREE);
    do_flags (maskicon, MIORDER, HIDETREE);

    maskicon [MIBOX].ob_y     = 0;
    maskicon [ROOT].ob_height = maskicon [MIBOX].ob_height;
  } /* if */
} /* mfix_iconbar */

/*****************************************************************************/

GLOBAL VOID mjoin (window)
WINDOWP window;

{
  mu_join ((MASK_SPEC *)window->special);
} /* mjoin */

/*****************************************************************************/

GLOBAL VOID mchange (window, mask_name)
WINDOWP window;
BYTE    *mask_name;

{
  mu_change ((MASK_SPEC *)window->special, mask_name);
} /* mchange */

/*****************************************************************************/

GLOBAL VOID med_first (WINDOWP window)
{
  ed_first (window);
} /* med_first */

/*****************************************************************************/

GLOBAL VOID mask_menu (window, title, item)
WINDOWP window;
WORD    title;
WORD    item;

{
  handle_menu (window, title, item);
} /* mask_menu */

/*****************************************************************************/

GLOBAL VOID m_do_undo (window, draw_icons)
WINDOWP window;
BOOLEAN draw_icons;

{
  WORD       act_obj;
  RECT       r;
  TABLE_INFO table_info;
  MASK_SPEC  *sub_spec;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sub_spec  = m_get_mask_spec (mask_spec);

  act_obj = sub_spec->act_obj;
  m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
  m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
  m_exit_pic (mask_spec, FAILURE);
  m_exit_rec (mask_spec, M_SET_NULL, TRUE, FALSE);
  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);
  sub_spec->act_obj = -1;

  if (mask_spec->clear_buffered && (mask_spec->num_submasks == 0))
    mem_lmove (mask_spec->buffer, mask_spec->db->buffer, table_info.size);
  else
  {
    if (! mask_spec->clear_buffered) mask_spec->db_adr = 0;

    if (table_info.recs != 0)
      m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, mask_spec->db_adr, TRUE);
  } /* else */

  if (draw_icons)
  {
    r   = window->work;
    r.h = window->work.h - window->scroll.h;
    set_redraw (window, &r);    /* update mask icons */
  } /* if */

  set_clip (TRUE, &window->scroll);
  m_sm_init (mask_spec);
  m_ed_index (sub_spec, act_obj, 1, NULL);
  m_all_fields (mask_spec, TRUE, TRUE);
  m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);

  m_setdirty (mask_spec, FALSE);
} /* m_do_undo */

/*****************************************************************************/

GLOBAL BOOLEAN m_varsql2sql (WINDOWP window, DB *db, BYTE *pVarSql, BYTE *pSql)
{
  BOOLEAN    bOk, bFound, bWild1, bWild2;
  WORD       num, i, len;
  STRING     szMask, szField;
  LONGSTR    s, szParam;
  FIELD_INFO field_info;
  WINDOWP    pWindow;
  WINDOWP    windows [MAX_GEMWIND];
  BYTE       *p, *q, *pLeft;
  MASK_SPEC  *mask_spec;

  szMask [0] = EOS;
  bWild1     = FALSE;
  bWild2     = FALSE;

  p = strchr (pVarSql, CHR_LEFTBRACK);
  q = pVarSql;

  if (p == NULL)
  {
    strcpy (pSql, pVarSql);
    return (TRUE);
  } /* if */

  *p = EOS;
  strcpy (pSql, q);
  p++;
  pLeft = p;

  while (*p != EOS)
  {
    if (*p == '*')				/* special case first char of param is '*' {*MASK.Field*} */
    {
      bWild1 = TRUE;
      p++;
    } /* if */

    q = p;					/* remark old position */

    strncpy (szParam, pLeft, LONGSTRLEN);	/* remark whole parameter from left to right bracket */
    szParam [LONGSTRLEN] = EOS;
    p = strchr (szParam, CHR_RIGHTBRACK);
    if (p != NULL) *p = EOS;

    p = strchr (q, CHR_MASKSEP);

    if (p != NULL)
    {
      *p = EOS;
      strcpy (szMask, q);
      p++;
      q = p;	/* remark old position */
    } /* if */

    p = strchr (q, CHR_RIGHTBRACK);

    if (p == NULL)
    {
      sprintf (s, alerts [ERR_SM_NO_FIELD], q, szMask);
      open_alert (s);
      return (FALSE);
    } /* if */

    *p = EOS;
    strcpy (szField, q);
    len = strlen (szField);

    if (szField [len - 1] == '*')		/* special case first char of param is '*' {*MASK.Field*} */
    {
      bWild2 = TRUE;
      szField [len - 1] = EOS;
    } /* if */

    p++;

    bFound = FALSE;
    num    = num_windows (CLASS_MASK, SRCH_ANY, windows);

    for (i = 0; (i < num) && ! bFound; i++)
    {
      pWindow = windows [i];

      if ((window != NULL) && (window->class == CLASS_MASK)) pWindow = window;

      mask_spec = (MASK_SPEC *)pWindow->special;
      strcpy (s, mask_spec->maskname);
      str_upper (s);
      str_upper (szMask);

      bFound = (mask_spec->db == db) && (strcmp (s, szMask) == 0);

      if (bFound)	/* mask found */
      {
        strcpy (field_info.name, szField);
        bOk = db_fieldinfo (db->base, rtable (mask_spec->table), FAILURE, &field_info) != FAILURE;
        if (bOk)
        {
          if (HASWILD (field_info.type))
          {
            strcpy (s, "\"");
            if (bWild1) strcat (s, "*");
            strncpy (s + strlen (s), (BYTE *)mask_spec->buffer + field_info.addr, LONGSTRLEN - 2);
            s [LONGSTRLEN - 2] = EOS;
            if (bWild2) strcat (s, "*");
            strcat (s, "\"");
          } /* if */
          else
          {
            bin2str (field_info.type, (BYTE *)mask_spec->buffer + field_info.addr, s);
            if (db->format != NULL) str2format (field_info.type, s, db->format [field_info.format]);
            if (s [0] == EOS) strcpy (s, "\"\"");
          } /* else */

          strcat (pSql, s);
        } /* if */
      } /* if */
    } /* for */

    if (! bFound)
    {
      if (GetParm (szParam, s) == GPOK)
      {
        strcat (pSql, "\"");
        strcat (pSql, s);
        strcat (pSql, "\"");
      } /* if */
      else
        return (FALSE);
    } /* if */

    while ((*p != CHR_LEFTBRACK) && (*p != EOS))
      chrcat (pSql, *p++);

    if (*p == CHR_LEFTBRACK)
    {
      *p = EOS;
      p++;
      pLeft = p;
    } /* if */
  } /* while */

  return (TRUE);
} /* m_varsql2sql */

/*****************************************************************************/

GLOBAL VOID col_popup (window, mk, hide_curs)
WINDOWP window;
MKINFO  *mk;
BOOLEAN hide_curs;

{
	BOOLEAN    own;
	BOOLEAN		 draw;
  BOOLEAN    null;
  WORD       wchar, hchar;
  WORD       wbox, hbox;
  WORD       strwidth;
  WORD       width, height;
  WORD       table, field, inx;
  WORD       type, i;
  LONG       address, moved;
  KEY        key;
  HLB        hlb;
  POPINFO    popinfo;
  INDEX_INFO index_info;
  RECT       ed_rect, r, old_clip, frame, arrow;
  FATTR      fattr;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  LU         *lu;
  DB         *db;
  EDFIELD    *ed_field;
  MFIELD     *mfield;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);
  ed_field  = &mask_spec->ed_field [mask_spec->act_obj];
  db        = mask_spec->db;
  mfield    = ed_field->mfield;
  table     = ed_field->lu_table;
  field     = ed_field->lu_field;
  strwidth  = m_get_rect (mask_spec, vdi_handle, mfield->class, (MOBJECT *)mfield, &r, &fattr);
  old_clip  = clip;

  inx = find_index (db->base, table, field);
  if (inx == FAILURE) inx = 0;

  vst_font (vdi_handle, mfield->font);
  vst_point (vdi_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);

  db_tableinfo (db->base, table, &table_info);
  db_fieldinfo (db->base, table, field, &field_info);

  if ((field_info.type == TYPE_PICTURE) || IS_BLOB (field_info.type)) return;

  if (table_info.recs == 0)
  {
    hndl_alert (ERR_NOLOOKUP);
    return;
  } /* if */

  type = field_info.type;

  db_fieldinfo (db->base, ed_field->table, ed_field->field, &field_info);

  if (type != field_info.type)
  {
    hndl_alert (ERR_LUNOMATCH);
    return;
  } /* if */

  height  = min (COL_VISIBLE, table_info.recs);
  height *= hbox;
  height  = max (height, 4 * gl_hattr);
  height  = height / hbox * hbox;
  if (table_info.recs <= COL_VISIBLE) height = table_info.recs * hbox;

  if (IS_CHECKBOX (mfield))
    width = mfield->w * wbox + strwidth;
  else
    width = mfield->w * wbox;

  width = min (width, desk.w - 2 * gl_wattr);

  r.x += strwidth;
  r.w -= strwidth;

  m_ed2field (mask_spec, mask_spec->act_obj, FALSE);
  ed_rect = m_get_edrect (mask_spec, mfield, TRUE);

  popinfo.mask_spec    = mask_spec;
  popinfo.dsttbl       = ed_field->table;
  popinfo.dstcol       = ed_field->field;
  popinfo.reftbl       = table;
  popinfo.refcol       = field;
  popinfo.refinx       = inx;
  popinfo.lastfetched  = FAILURE;
  popinfo.window       = window;
  popinfo.first        = TRUE;
  popinfo.num_lus      = fill_lus (mask_spec, &popinfo, FALSE);
  popinfo.font         = mfield->font;
  popinfo.point        = mfield->point;
  popinfo.color        = mfield->color;

  if (popinfo.num_lus == 0) /* use dest as source */
  {
    popinfo.lu [0].dstcol = field;
    popinfo.lu [0].refcol = field;
    popinfo.lu [0].ed_pos = m_get_edrect (mask_spec, mfield, TRUE);
    popinfo.lu [0].mfield = mfield;
    popinfo.num_lus++;
		own = TRUE;
  } /* if */
	else
		own = FALSE;
	
  hide_mouse ();
  if (hide_curs) m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);
  frame = r;
  rc_inflate (&frame, 1, 1);

  arrow.x = frame.x + frame.w - gl_wattr - 1;
  arrow.y = frame.y + 1;
  arrow.w = gl_wattr;
  arrow.h = frame.h - 2;

	draw = rc_intersect ( &window->scroll, &arrow );			/* Gibt es Åberhaupt was zu zeichnen? */

	if ( !own && draw )
  	DrawComboBox (vdi_handle, &frame, &arrow, NULL, LBS_SELECTED, WHITE, NULL, gl_wbox, gl_wattr, 0, NULL, NULL);	/* show selected arrow */
  set_clip (TRUE, &window->scroll);
  show_mouse ();

  xywh2rect (r.x - 1, ed_rect.y + ed_rect.h, r.w - 2, height, &r);

  popinfo.hlb = hlb = ListBox_Create (LBS_VREALTIME | LBS_NOSTANDARDKEYBOARD, &r, num_keys (db, popinfo.reftbl, popinfo.refinx));
  if (hlb == NULL) return;

  ListBox_SetCallback (hlb, cb_callback);
  ListBox_SetCurSel (hlb, 0);
  ListBox_SetComboRect (hlb, NULL, ed_rect.y - 1);
  ListBox_SetSpec (hlb, (LONG)&popinfo);
  ListBox_SetFont (hlb, mfield->font, mfield->point, TXT_NORMAL, mfield->color, WHITE);
  ListBox_SetItemHeight (hlb, hbox);
  ListBox_SetLeftOffset (hlb, 1);

  v_initcursor (db, popinfo.reftbl, popinfo.refinx, ASCENDING, &popinfo.cursor);
  set_clip (TRUE, &window->scroll);

  null = is_null (field_info.type, (BYTE *)mask_spec->buffer + field_info.addr);

  if ((inx > 0) && ! null && mask_config.pospopup)      /* move to selected field in popup */
  {
    busy_mouse ();
    v_indexinfo (db, popinfo.reftbl, popinfo.refinx, &index_info);
    mem_move (key, (BYTE *)mask_spec->buffer + field_info.addr, MAX_KEYSIZE - 1);
    if (HASWILD (index_info.type)) db_convstr (db->base, key);

    db_keysearch (db->base, table, inx, ASCENDING, &popinfo.cursor, key, 0L);
    address = db_readcursor (db->base, &popinfo.cursor, NULL);
    v_initcursor (db, popinfo.reftbl, popinfo.refinx, ASCENDING, &popinfo.cursor);
    v_movecursor (db, &popinfo.cursor, 1L);
    popinfo.lastfetched = moved = db_locateaddr (db->base, &popinfo.cursor, ASCENDING, address);

    ListBox_SetCurSel (hlb, moved);
    arrow_mouse ();
  } /* if */

  mask_spec->clear_buffered = FALSE;	/* db buffer has been used */

  if (ListBox_ComboClick (hlb, mk) != FAILURE)
    if (! (ed_field->flags & COL_OUTPUT))
    {
      m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
      ListBox_SendMessage (hlb, LBN_GETITEM, ListBox_GetCurSel (hlb), mk);			/* put actual item in db->buffer */
      hndl_items (&popinfo, LU_COPY, mask_spec->buffer, FALSE);
      m_ed_index (mask_spec, mask_spec->act_obj, 1, mk);
      m_setdirty (mask_spec, TRUE);

      /*ed_next (window);*/
    } /* if, if */

  lu = popinfo.lu;
  for (i = 0; i < popinfo.num_lus; i++, lu++)
    if ((lu->mfield->h > 1) || ! IS_EDOBJ (lu->mfield))
    {
     	r = lu->ed_pos;
    	r.x -=1;
    	r.y -=1;
    	r.w +=1;
    	r.h +=2;
    	set_redraw (window, &r);    /* redraw multiline edit fields, radio buttons, etc. */
   	} /* if */

  hide_mouse ();

	if ( !own && draw )
	  DrawComboBox (vdi_handle, &frame, &arrow, NULL, 0, WHITE, NULL, gl_wbox, gl_wattr, 0, NULL, NULL);	/* show normal arrow */
  set_clip (TRUE, &window->scroll);
  hndl_items (&popinfo, LU_DRAW, mask_spec->buffer, FALSE);
  ListBox_Delete (hlb);

  set_clip (TRUE, &window->scroll);
  if (hide_curs) m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
  set_clip (TRUE, &old_clip);
  show_mouse ();
} /* col_popup */

/*****************************************************************************/

LOCAL LONG cb_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  LONG       i;
  LONG       forw, back;
  BYTE       s [2];
  KEY        key, keyval;
  INDEX_INFO index_info;
  MKINFO     *mk;
  DB         *db;
  POPINFO    *popinfo;
  HLB        *hlb;

  hlb = (HLB)tree;
  popinfo = (POPINFO *)ListBox_GetSpec (hlb);
  db      = popinfo->mask_spec->db;
  mk      = (MKINFO *)p;

  switch (msg)
  {
    case LBN_GETITEM    : if (item > popinfo->lastfetched)
                          {
                            forw = item - popinfo->lastfetched;
                            back = ListBox_GetCount (hlb) - item;

                            if (forw < back)
                              v_movecursor (db, &popinfo->cursor, forw);
                            else
                            {
                              v_initcursor (db, popinfo->reftbl, popinfo->refinx, DESCENDING, &popinfo->cursor);
                              v_movecursor (db, &popinfo->cursor, -back);
                            } /* else */
                          } /* if */
                          else
                          {
                            forw = item + 1;
                            back = popinfo->lastfetched - item;

                            if (forw < back)
                            {
                              v_initcursor (db, popinfo->reftbl, popinfo->refinx, ASCENDING, &popinfo->cursor);
                              v_movecursor (db, &popinfo->cursor, forw);
                            }
                            else
                              v_movecursor (db, &popinfo->cursor, -back);
                          } /* else */

                          if (v_read (db, popinfo->reftbl, db->buffer, &popinfo->cursor, 0L, FALSE))
                            col2str (db, popinfo->reftbl, db->buffer, popinfo->refcol, 0, popinfo->itemstr);
                          else
                            popinfo->itemstr [0] = EOS;

                          popinfo->lastfetched = item;

                          if (popinfo->first && (item == ListBox_GetCurSel (hlb)))
                          {
                            popinfo->first = FALSE;
                            hndl_items (popinfo, LU_DRAW, db->buffer, TRUE);
                          } /* if */

                          return (LONG)popinfo->itemstr;
    case LBN_SELCHANGE  : ListBox_SendMessage (hlb, LBN_GETITEM, item, p);
                          hndl_items (popinfo, LU_DRAW, db->buffer, TRUE);
                          break;
    case LBN_KEYPRESSED : v_indexinfo (db, popinfo->reftbl, popinfo->refinx, &index_info);
                          s [0] = mk->ascii_code;
                          s [1] = EOS;

                          if (HASWILD (index_info.type))
                          {
                            busy_mouse ();
                            db_convstr (db->base, s);
                            str2bin (index_info.type, s, key);
                            ListBox_SendMessage (hlb, LBN_GETITEM, ListBox_GetCurSel (hlb), p);

                            for (i = 0; i < ListBox_GetCount (hlb); i++)
                            {
                              item = (ListBox_GetCurSel (hlb) + i + 1) % ListBox_GetCount (hlb);

                              if (item == 0) v_initcursor (db, popinfo->reftbl, popinfo->refinx, ASCENDING, &popinfo->cursor);
                              v_movecursor (db, &popinfo->cursor, 1L);
                              db_readcursor (db->base, &popinfo->cursor, keyval);

                              if (keyval [0] == key [0]) break;
                            } /* for */

                            arrow_mouse ();

                            popinfo->lastfetched = item;
                          } /* if */
                          break;
  } /* switch */

  return (item);
} /* cb_callback */

/*****************************************************************************/

LOCAL VOID hndl_items (popinfo, mode, buffer, useref)
POPINFO *popinfo;
WORD    mode;
BYTE    *buffer;
BOOLEAN useref;

{
  WORD       i, tbl, col, y;
  WORD       wchar, hchar, wbox, hbox;
  LONGSTR    s;
  RECT       old_clip, r, ed_pos;
  FIELD_INFO field_info;
  LU         *lu;
  DB         *db;

  db = popinfo->mask_spec->db;

  old_clip = clip;
  vswr_mode (vdi_handle, MD_REPLACE);

  lu = popinfo->lu;

  for (i = 0; i < popinfo->num_lus; i++, lu++)
  {
    ed_pos = lu->ed_pos;
    rc_intersect (&popinfo->window->scroll, &ed_pos);
    ListBox_GetComboRect (popinfo->hlb, &r, &y);

    if (! useref || ! rc_intersect (&ed_pos, &r))
    {
      if (useref)
      {
        tbl = popinfo->reftbl;
        col = lu->refcol;
      } /* if */
      else
      {
        tbl = popinfo->dsttbl;
        col = lu->dstcol;
      } /* if */

      switch (mode)
      {
        case LU_DRAW : if (IS_EDOBJ (lu->mfield) && (lu->mfield->h == 1))
                       {
                         col2str (db, tbl, buffer, col, 0, s);
                         set_clip (TRUE, &ed_pos);
                         clr_area (&ed_pos);

                         vst_font (vdi_handle, lu->mfield->font);
                         vst_point (vdi_handle, lu->mfield->point, &wchar, &hchar, &wbox, &hbox);
                         vst_color (vdi_handle, lu->mfield->color);
                         v_gtext (vdi_handle, lu->ed_pos.x, lu->ed_pos.y, s);

                         vst_font (vdi_handle, popinfo->font);      /* restore old values for list box which draws now it's items */
                         vst_point (vdi_handle, popinfo->point, &wchar, &hchar, &wbox, &hbox);
                         vst_color (vdi_handle, popinfo->color);
                       } /* if */
                       break;
        case LU_COPY : db_fieldinfo (db->base, popinfo->reftbl, lu->refcol, &field_info);
                       db_setfield (db->base, popinfo->dsttbl, lu->dstcol, buffer, (BYTE *)db->buffer + field_info.addr);
                       break;
      } /* switch */
    } /* if */
  } /* for */

  set_clip (TRUE, &old_clip);
} /* hndl_items */

/*****************************************************************************/

LOCAL WORD fill_lus (mask_spec, popinfo, do_it)
MASK_SPEC *mask_spec;
POPINFO   *popinfo;
BOOLEAN   do_it;

{
  BOOLEAN    first, found;
  WORD       recs, i, j, num_lus, multi;
  WORD       refcol;
  TABLE_INFO table_info;
  LU         *lu;
  MFIELD     *mfield;
  EDFIELD    *ed_field;
  SYSLOOKUP  *syslookup;

  db_tableinfo (mask_spec->db->base, SYS_LOOKUP, &table_info);
  recs      = table_info.recs;
  syslookup = mask_spec->db->syslookup;
  lu        = popinfo->lu;
  refcol    = -1;
  multi     = 0;
  first     = TRUE;

  /* test if multiple fields must be used from the lookup table */

  for (i = num_lus = 0; (i < recs) && (num_lus < MAX_LUS); i++, syslookup++)
    if ((syslookup->reftable == popinfo->reftbl) &&
        (syslookup->table    == popinfo->dsttbl))
    {
      if (first)
      {
        multi++;
        first  = FALSE;
        refcol = syslookup->refcolumn;
      } /* if */

      if (refcol != syslookup->refcolumn) multi++;
    } /* if, for */

  if (multi == 0) return (num_lus);     /* real lookup table does not exist */

  syslookup = mask_spec->db->syslookup;

  for (i = num_lus = 0; (i < recs) && (num_lus < MAX_LUS); i++, syslookup++)
    if ((syslookup->reftable == popinfo->reftbl) &&
        (syslookup->table    == popinfo->dsttbl))
    {
      found = FALSE;

      for (j = 0; (j < mask_spec->edobjs) && ! found; j++)      /* search mask field */
      {
        ed_field  = &mask_spec->ed_field [j];
        mfield    = ed_field->mfield;

        if ((ed_field->table == syslookup->table) && (ed_field->field == syslookup->column)) found = TRUE;
      } /* for */

      if (found)
        if ((multi > 1) || do_it || (syslookup->column == popinfo->dstcol))
        {
          lu->dstcol = syslookup->column;
          lu->refcol = syslookup->refcolumn;
          lu->ed_pos = m_get_edrect (mask_spec, mfield, TRUE);
          lu->mfield = mfield;

          num_lus++;
          lu++;
        } /* if, if */
    } /* if, for */

  return (num_lus);
} /* fill_lus */

/*****************************************************************************/

LOCAL PMASK_SPEC ed_first (window)
WINDOWP window;

{
  EDFIELD   *ed_field;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);	/* switch to submask eventually */

  m_ed2field (mask_spec, mask_spec->act_obj, TRUE);
  m_edit_obj (mask_spec, MO_EXIT, 0, NULL);

  if (mask_spec->pParentSpec != NULL)		/* leave submask, goto root mask */
  {
    mask_spec->act_obj = FAILURE;

    mask_spec = (MASK_SPEC *)window->special;

    mask_spec->act_sub = FAILURE;
  } /* if */

  ed_field = &mask_spec->ed_field [0];

  if (ed_field->mfield->class == M_SUBMASK)	/* if next field is a submask */
  {
    mask_spec->last_obj = 0;			/* remember last edit object number for restoring */
    mask_spec->act_obj  = FAILURE;		/* edit object is now in sub mask, so clear act obj number from parent mask */
    mask_spec->act_sub  = ed_field->sub;	/* act_sub is edit index of sub mask */

    mask_spec = mask_spec->Submask [ed_field->sub].pMaskSpec;
  } /* if */

  m_ed_index (mask_spec, 0, 1, NULL);

  return (mask_spec);
} /* ed_first */

/*****************************************************************************/

LOCAL PMASK_SPEC ed_last (window)
WINDOWP window;

{
  EDFIELD   *ed_field;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);	/* switch to submask eventually */

  m_ed2field (mask_spec, mask_spec->act_obj, TRUE);
  m_edit_obj (mask_spec, MO_EXIT, 0, NULL);

  if (mask_spec->pParentSpec != NULL)		/* leave submask, goto root mask */
  {
    mask_spec->act_obj = FAILURE;

    mask_spec = (MASK_SPEC *)window->special;

    mask_spec->act_sub = FAILURE;
  } /* if */

  ed_field = &mask_spec->ed_field [mask_spec->edobjs - 1];

  if (ed_field->mfield->class == M_SUBMASK)	/* if last field is a submask */
  {
    mask_spec->last_obj = mask_spec->edobjs - 1;/* remember next edit object number for restoring */
    mask_spec->act_obj  = FAILURE;		/* edit object is now in sub mask, so clear act obj number from parent mask */
    mask_spec->act_sub  = ed_field->sub;	/* act_sub is edit index of sub mask */

    mask_spec = mask_spec->Submask [ed_field->sub].pMaskSpec;
  } /* if */

  m_ed_index (mask_spec, mask_spec->edobjs - 1, -1, NULL);

  return (mask_spec);
} /* ed_last */

/*****************************************************************************/

LOCAL PMASK_SPEC ed_next (window)
WINDOWP window;

{
  WORD      next;
  EDFIELD   *ed_field;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);	/* switch to submask eventually */

  if (m_ed2field (mask_spec, mask_spec->act_obj, TRUE))
  {
    m_edit_obj (mask_spec, MO_EXIT, 0, NULL);

    next = (mask_spec->act_obj + 1) % mask_spec->edobjs;
    next = m_ed_next (mask_spec, next, 1);

    if ((next <= mask_spec->act_obj) && (mask_spec->pParentSpec != NULL))	/* leave submask, goto parent mask */
    {
      mask_spec->act_obj = FAILURE;

      mask_spec = mask_spec->pParentSpec;	/* get new mask spec */

      mask_spec->act_obj = mask_spec->last_obj;
      mask_spec->act_sub = FAILURE;
      next = (mask_spec->act_obj + 1) % mask_spec->edobjs;
      next = m_ed_next (mask_spec, next, 1);
    } /* if */

    ed_field = &mask_spec->ed_field [next];

    if (ed_field->mfield->class == M_SUBMASK)	/* if next field is a submask enter it */
    {
      mask_spec->last_obj = next;		/* remember next edit object number for restoring */
      mask_spec->act_obj  = FAILURE;		/* edit object is now in sub mask, so clear act obj number from parent mask */
      mask_spec->act_sub  = ed_field->sub;	/* act_sub is edit index of sub mask */

      mask_spec = mask_spec->Submask [ed_field->sub].pMaskSpec;

      mask_spec->act_obj  = 0;
      mask_spec->last_obj = 0;
      m_ed_index (mask_spec, 0, 1, NULL);

      return (mask_spec);
    } /* if */

    m_ed_index (mask_spec, next, 1, NULL);
  } /* if */

  return (mask_spec);
} /* ed_next */

/*****************************************************************************/

LOCAL PMASK_SPEC ed_prev (window)
WINDOWP window;

{
  WORD      next;
  EDFIELD   *ed_field;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);	/* switch to submask eventually */
  next      = mask_spec->act_obj;

  if (m_ed2field (mask_spec, mask_spec->act_obj, TRUE))
  {
    m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
    next--;
    if (next < 0) next = mask_spec->edobjs - 1;	/* set to last edit object */
    next = m_ed_next (mask_spec, next, -1);

    if ((next >= mask_spec->act_obj) && (mask_spec->pParentSpec != NULL))	/* leave submask, goto parent mask */
    {
      mask_spec->act_obj = FAILURE;

      mask_spec = mask_spec->pParentSpec;	/* get new mask spec */

      mask_spec->act_obj = mask_spec->last_obj;
      mask_spec->act_sub = FAILURE;
      next = mask_spec->act_obj - 1;
      if (next < 0) next = mask_spec->edobjs - 1;	/* set to last edit object */
      next = m_ed_next (mask_spec, next, -1);
    } /* if */

    ed_field = &mask_spec->ed_field [next];

    if (ed_field->mfield->class == M_SUBMASK)	/* if previous field is a submask */
    {
      mask_spec->last_obj = next;		/* remember next edit object number for restoring */
      mask_spec->act_obj  = FAILURE;		/* edit object is now in sub mask, so clear act obj number from parent mask */
      mask_spec->act_sub  = ed_field->sub;	/* act_sub is edit index of sub mask */

      mask_spec = mask_spec->Submask [ed_field->sub].pMaskSpec;

      mask_spec->act_obj  = mask_spec->edobjs - 1;
      mask_spec->last_obj = mask_spec->edobjs - 1;
      m_ed_index (mask_spec, mask_spec->act_obj, -1, NULL);

      return (mask_spec);
    } /* if */

    m_ed_index (mask_spec, next, 1, NULL);
  } /* if */

  return (mask_spec);
} /* ed_prev */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP          window;
  MASK_SPEC        *mask_spec;
  BOOLEAN          visible_part;
  WORD             inx;
  RECT             r;
  BYTE             *text;
  LB_OWNERDRAW     *lb_ownerdraw;
  LOCAL INDEX_INFO index_info;
  WORD             num_cols;

  window    = (WINDOWP)ListBoxGetSpec (tree, obj);
  mask_spec = (MASK_SPEC *)window->special;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)mask_spec->db->t_info [tableinx (mask_spec->db, mask_spec->table)].i_info [index].indexname);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)callback (wh, tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = (dlg_colors >= 16) && (gl_hbox > 8) ? 16 : 0;
                            v_indexinfo (mask_spec->db, mask_spec->table, mask_spec->db->t_info [tableinx (mask_spec->db, mask_spec->table)].i_info [index].indexnum, &index_info);
                            num_cols = index_info.inxcols.size / sizeof (INXCOL);
                            DrawOwnerIcon (lb_ownerdraw, &r, (dlg_colors >= 16) && (gl_hbox > 8) ? (num_cols == 1) ? &toolinx_icon : &toolmul_icon : NULL, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : inx = indexnum (mask_spec->db, tableinx (mask_spec->db, mask_spec->table), (WORD)index);
                          sort_name (mask_spec->db, mask_spec->table, inx, mask_spec->dir, window->info);
                          strcpy (get_str (tree, MIORDER), window->info);
                          strncpy (get_str (tree, obj), mask_spec->db->t_info [tableinx (mask_spec->db, mask_spec->table)].i_info [index].indexname, mask_info.num_chars);
                          draw_win_obj (window, tree, MIORDER);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL BOOLEAN test_mask (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;
  WORD    edobj;

  ret = done || acc_close;

  if (! ret) return (m_save_all (mask_spec, &edobj));

  return (TRUE);
} /* test_mask */

/*****************************************************************************/

LOCAL BOOL LoadCalc (DB *db, SHORT sTable, BYTE *pCalcName, CALCCODE *pCalcCode)
{
  BOOL    bOk;
  CURSOR  cursor;
  SYSCALC *syscalc;

  syscalc = (SYSCALC *)mem_alloc ((LONG)sizeof (SYSCALC));
  if (syscalc == NULL) return (FALSE);

  bOk = FALSE;

  strcpy (syscalc->tablename, db_tablename (db->base, rtable (sTable)));
  strcpy (syscalc->name, pCalcName);

  if (db_search (db->base, SYS_CALC, 1, ASCENDING, &cursor, syscalc, 0L))
    if (db_read (db->base, SYS_CALC, syscalc, &cursor, 0L, FALSE))
    {
      *pCalcCode = syscalc->code;
      bOk = TRUE;
    } /* if */

  mem_free (syscalc);

  return (bOk);
} /* LoadCalc */

/*****************************************************************************/

LOCAL VOID SetBuffer (MASK_SPEC *mask_spec, DB *db, WORD table, LONG address, RECT *area)
{
  BOOLEAN    fast, in_arrow, is_button, is_graf, is_submask;
  WORD       obj, act_obj, num_lus, i, sub;
  POPINFO    popinfo;
  FIELD_INFO field_info;
  MKINFO     mk;
  WINDOWP    window;
  LU         *lu;
  EDFIELD    *ed_field;
  MASK_SPEC  *sub_spec;
  MASK_SPEC  *root_spec;

  window    = mask_spec->window;
  fast      = find_top () == window;
  root_spec = (MASK_SPEC *)window->special;
  sub_spec  = m_get_mask_spec (mask_spec);

  if (db != mask_spec->db) return;

  if (rtable (table) != rtable (mask_spec->table))      /* try to find & fill lookup fields */
  {
    popinfo.dsttbl = rtable (mask_spec->table);
    popinfo.reftbl = rtable (table);
    popinfo.dstcol = -1;
    popinfo.refcol = -1;

    graf_mkstate (&mk.mox, &mk.moy, &mk.mobutton, &mk.kstate);
    obj = m_find_obj (mask_spec, &mk, &in_arrow, &is_button, &is_submask, &is_graf, &sub);

    if ((obj != FAILURE) && ! is_button && ! is_submask)
    {
      ed_field       = &mask_spec->ed_field [obj];
      popinfo.dstcol = ed_field->field;
    } /* if */

    num_lus = fill_lus (mask_spec, &popinfo, popinfo.dstcol == -1);
    if (num_lus == 0) return;

    act_obj = sub_spec->act_obj;

    m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
    m_ed2field (sub_spec, sub_spec->act_obj, TRUE);
    m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
    m_exit_pic (sub_spec, FAILURE);
    m_exit_rec (sub_spec, M_SET_NOTNULL, TRUE, FALSE);
    sub_spec->act_obj = FAILURE;

    m_vread (mask_spec, table, mask_spec->db->buffer, NULL, address, TRUE);

    lu = popinfo.lu;

    for (i = 0; i < num_lus; i++, lu++)
    {
      db_fieldinfo (db->base, popinfo.reftbl, lu->refcol, &field_info);
      db_setfield (db->base, popinfo.dsttbl, lu->dstcol, mask_spec->buffer, (BYTE *)mask_spec->db->buffer + field_info.addr);
      set_redraw (window, &lu->ed_pos);
    } /* for */

    if (mask_spec->pParentSpec == NULL) m_sm_init (root_spec);
    m_all_submasks (mask_spec);

    m_ed_index (sub_spec, act_obj, 1, NULL);
    m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
    m_setdirty (mask_spec, TRUE);

    return;
  } /* if */
  else
    if (fast)
    {
      m_vread (mask_spec, table, mask_spec->db->buffer, NULL, address, TRUE);
      mask_spec->clear_buffered = TRUE;
      m_do_undo (window, TRUE);
      mask_spec->clear_buffered = FALSE;
    } /* else */
    else
    {
      act_obj = sub_spec->act_obj;

      m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
      m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
      m_exit_pic (sub_spec, FAILURE);
      m_exit_rec (sub_spec, M_SET_NULL, TRUE, FALSE);
      sub_spec->act_obj = FAILURE;

      m_vread (mask_spec, table, mask_spec->buffer, NULL, address, TRUE);

      if (mask_spec->pParentSpec == NULL) m_sm_init (root_spec);
      set_redraw (window, area);

      m_ed_index (sub_spec, act_obj, 1, NULL);
      m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
      m_setdirty (mask_spec, FALSE);
    } /* else, else */
} /* SetBuffer */

/*****************************************************************************/

LOCAL VOID RedrawPicobj (MASK_SPEC *mask_spec, WORD wPic)
{
  WORD    obj;
  RECT    r;
  FATTR   fattr;
  BYTE    *pFilename;
  PICOBJ  *spicobj;
  MGRAF   *mgraf;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  spicobj = &mask_spec->spicobj [wPic];

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mgraf = &mobject->mgraf;

    if (mgraf->class == M_GRAF)
    {
      pFilename = &sysmask->mask.buffer [mgraf->filename];

      if (strcmp (pFilename, spicobj->filename) == 0)
      {
        m_get_rect (mask_spec, vdi_handle, mgraf->class, mobject, &r, &fattr);
        set_redraw (mask_spec->window, &r);
      } /* if */
    } /* if */
  } /* for */
} /* RedrawPicobj */

/*****************************************************************************/

LOCAL VOID HandleOlgaUpdated (MASK_SPEC *mask_spec, BYTE *pFilename)
{
  WORD      i, obj, act_obj;
  RECT      old_clip;
  FULLNAME  szFilename;
  PICOBJ    *spicobj;
  EDFIELD   *ed_field;

  spicobj = mask_spec->spicobj;	/* static pictures */

  for (i = 0; i < mask_spec->spicobjs; i++, spicobj++)
  {
    mGetPicFilename (mask_spec, szFilename, spicobj->filename);

    if (strcmp (pFilename, szFilename) == 0)
    {
      switch (spicobj->type)
      {
        case PIC_META  : gem_obj (&spicobj->pic.gem, GEM_UPDATE, 0, NULL);
                         break;
        case PIC_IMAGE : image_obj (&spicobj->pic.img, IMG_UPDATE, 0, NULL);
                         break;
        case PIC_IFF   : break;
        case PIC_TIFF  : break;
      } /* switch */

      RedrawPicobj (mask_spec, i);
    } /* if */
  } /* for */

  ed_field = mask_spec->ed_field;	/* check all edit fields */

  for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
  {
    if (strcmp (pFilename, ed_field->szFilename) == 0)
      switch (ed_field->type)
      {
        case TYPE_CHAR    : act_obj = mask_spec->act_obj;
                            m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);
                            m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
                            mask_spec->act_obj = -1;

                            old_clip  = clip;
                            mu_textimp (mask_spec, pFilename, obj);	/* clipping will be destroyed when using commdlg */
                            set_clip (TRUE, &old_clip);

                            m_ed_index (mask_spec, act_obj, 1, NULL);
                            m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
                            break;
        case TYPE_PICTURE : mu_grafimp (mask_spec, pFilename, obj);
                            break;
      } /* switch, if */
  } /* for */
} /* HandleOlgaUpdated */

/*****************************************************************************/

LOCAL VOID click_mconfig (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case MCOK     : get_mconfig ();
                    break;
    case MCCANCEL : set_mconfig ();
                    break;
    case MCHELP   : hndl_help (HMCONFIG);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_mconfig */

/*****************************************************************************/

LOCAL BOOLEAN key_mconfig (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;

  switch (window->edit_obj)
  {
    case MCVOLUME : p = get_str (maskconf, MCVOLUME);

                    if ((*p == EOS) == ! is_state (maskconf, MCOK, DISABLED))
                    {
                      flip_state (maskconf, MCOK, DISABLED);
                      draw_object (window, MCOK);
                    } /* if */
  } /* switch */

  return (FALSE);
} /* key_mconfig */

/*****************************************************************************/

LOCAL WORD GetParm (BYTE *pParm, BYTE *pValue)
{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, GETPARM);

  if (window == NULL)
  {
    form_center (getparm, &ret, &ret, &ret, &ret);
    window = crt_dialog (getparm, NULL, GETPARM, FREETXT (FGETPARM), WI_MODAL);

    if (window != NULL)
      window->click = click_getparm;
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (getparm, ROOT, EDITABLE);
    window->edit_inx = NIL;

    set_getparm (pParm);
    pDlgValue = pValue;

    if (! open_dialog (GETPARM)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (exit_obj);
} /* GetParm */

/*****************************************************************************/

LOCAL VOID get_getparm (VOID)
{
  get_ptext (getparm, GPVALUE, pDlgValue);
  pDlgValue [MAX_PARM] = '*';
  pDlgValue [MAX_PARM + 1] = EOS;
} /* get_getparm */

/*****************************************************************************/

LOCAL VOID set_getparm (BYTE *pParm)
{
  pParm [MAX_PARM - 1] = EOS;
  set_str (getparm, GPPARM, pParm);
  set_str (getparm, GPVALUE, "");
  exit_obj = GPCANCEL;
} /* set_getparm */

/*****************************************************************************/

LOCAL VOID click_getparm (WINDOWP window, MKINFO *mk)
{
  switch (window->exit_obj)
  {
    case GPOK   : get_getparm ();
                  break;
    case GPHELP : hndl_help (HGETPARM);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */

  exit_obj = window->exit_obj;
} /* click_getparm */

/*****************************************************************************/

LOCAL VOID msave (window)
WINDOWP window;

{
  MKINFO mk;

  objc_offset (maskicon, MISAVE, &mk.mox, &mk.moy);
  mk.shift = FALSE;
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* msave */

/*****************************************************************************/

LOCAL VOID minsert (window)
WINDOWP window;

{
  MKINFO mk;

  objc_offset (maskicon, MISAVE, &mk.mox, &mk.moy);
  mk.shift = TRUE;
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* minsert */

/*****************************************************************************/

LOCAL VOID mupdate (window)
WINDOWP window;

{
  msave (window);
} /* mupdate */

/*****************************************************************************/

LOCAL VOID mdelete (window)
WINDOWP window;

{
  MKINFO mk;

  objc_offset (maskicon, MIDELETE, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mdelete */

/*****************************************************************************/

LOCAL VOID msearch (window, bMulti)
WINDOWP window;

{
  MKINFO mk;

  mk.alt = bMulti;
  objc_offset (maskicon, MISEARCH, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* msearch */

/*****************************************************************************/

LOCAL VOID mclear (window)
WINDOWP window;

{
  MKINFO mk;

  objc_offset (maskicon, MICLEAR, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mclear */

/*****************************************************************************/

LOCAL VOID mprev (window)
WINDOWP window;

{
  MKINFO mk;

  mk.breturn = 1;
  objc_offset (maskicon, MIPREV, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mprev */

/*****************************************************************************/

LOCAL VOID mnext (window)
WINDOWP window;

{
  MKINFO mk;

  mk.breturn = 1;
  objc_offset (maskicon, MINEXT, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mnext */

/*****************************************************************************/

LOCAL VOID mfirst (window)
WINDOWP window;

{
  MKINFO mk;

  mk.breturn = 1;
  objc_offset (maskicon, MIFIRST, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mfirst */

/*****************************************************************************/

LOCAL VOID mlast (window)
WINDOWP window;

{
  MKINFO mk;

  mk.breturn = 1;
  objc_offset (maskicon, MILAST, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mlast */

/*****************************************************************************/

LOCAL VOID mcalc (window)
WINDOWP window;

{
  MKINFO mk;

  mk.breturn = 1;
  objc_offset (maskicon, MICALC, &mk.mox, &mk.moy);
  m_click ((MASK_SPEC *)window->special, &mk, TRUE);
} /* mcalc */

/*****************************************************************************/

LOCAL BOOLEAN can_save (mask_spec)
MASK_SPEC *mask_spec;

{
  return (can_insert (mask_spec) || can_update (mask_spec));
} /* can_save */

/*****************************************************************************/

LOCAL BOOLEAN can_insert (mask_spec)
MASK_SPEC *mask_spec;

{
  return (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_INSERT);
} /* can_insert */

/*****************************************************************************/

LOCAL BOOLEAN can_update (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;

  ret = ! is_null (TYPE_DBADDRESS, mask_spec->buffer) &&
        mask_spec->modify &&
        (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_UPDATE);

  return (ret);
} /* can_update */

/*****************************************************************************/

LOCAL BOOLEAN can_delete (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;

  ret = ! is_null (TYPE_DBADDRESS, mask_spec->buffer) &&
        mask_spec->modify &&
        (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_DELETE);

  return (ret);
} /* can_delete */

/*****************************************************************************/

LOCAL BOOLEAN can_search (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;

/*  ret = VTBL (mask_spec->table) || (mask_spec->inx == 0); */

  ret = FALSE;
  ret = ! ret && (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_SELECT);

  return (ret);
} /* can_search */

/*****************************************************************************/

LOCAL BOOLEAN can_prev (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;

  ret = (mask_spec->dir == ASCENDING) ? v_isfirst (mask_spec->db, mask_spec->cursor) : v_islast (mask_spec->db, mask_spec->cursor);
  ret = ! ret && (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_SELECT);

  return (ret);
} /* can_prev */

/*****************************************************************************/

LOCAL BOOLEAN can_next (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;

  ret = (mask_spec->dir == ASCENDING) ? v_islast (mask_spec->db, mask_spec->cursor) : v_isfirst (mask_spec->db, mask_spec->cursor);
  ret = ! ret && (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_SELECT);

  return (ret);
} /* can_next */

/*****************************************************************************/

LOCAL BOOLEAN can_calc (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN ret;
  WORD    table;

  table = rtable (mask_spec->table);
  ret   = (table >= NUM_SYSTABLES) && (mask_spec->db->t_info [tableinx (mask_spec->db, table)].calccode.size != 0);

  return (ret);
} /* can_calc */

/*****************************************************************************/
/* menu handling                                                             */
/*****************************************************************************/

LOCAL VOID update_menu (window)
WINDOWP window;

{
  BOOLEAN    open, popup, join, multi;
  INDEX_INFO index_info;
  EDFIELD    *ed_field;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);
  open      = FALSE;
  popup     = FALSE;
  join      = FALSE;
  multi     = FALSE;

  m_setdirty (mask_spec, mask_spec->buf_dirty);

  if (mask_spec->act_obj != FAILURE)
  {
    ed_field = &mask_spec->ed_field [mask_spec->act_obj];
    open     = (ed_field->type == TYPE_EXTERN) || IS_BLOB (ed_field->type);
    join     = (ed_field->type != TYPE_PICTURE) && ! IS_BLOB (ed_field->type);
    popup    = join;
  } /* if */

  if (v_indexinfo (mask_spec->db, mask_spec->table, mask_spec->inx, &index_info) != FAILURE)
    if ((index_info.inxcols.size / sizeof (INXCOL) > 1)) multi = TRUE;	/* multi index found */

  menu_enable (window->menu, MMPREV,   can_prev (mask_spec));
  menu_enable (window->menu, MMFIRST,  can_prev (mask_spec));
  menu_enable (window->menu, MMNEXT,   can_next (mask_spec));
  menu_enable (window->menu, MMLAST,   can_next (mask_spec));
  menu_enable (window->menu, MMSAVE,   can_save (mask_spec));
  menu_enable (window->menu, MMINSERT, can_insert (mask_spec));
  menu_enable (window->menu, MMUPDATE, can_update (mask_spec));
  menu_enable (window->menu, MMDELETE, can_delete (mask_spec));
  menu_enable (window->menu, MMSEARCH, can_search (mask_spec));
  menu_enable (window->menu, MMMULTI,  multi);
  menu_enable (window->menu, MMCALC,   can_calc (mask_spec));

  menu_enable (window->menu, MMIMPORT, ed_field->flags & (GRANT_INSERT | GRANT_UPDATE));
  menu_enable (window->menu, MMEXPORT, ed_field->flags & GRANT_SELECT);
  menu_enable (window->menu, MMOPEN,   open);
  menu_enable (window->menu, MMJOIN,   join);
  menu_enable (window->menu, MMPOPUP,  popup);
} /* update_menu */

/*****************************************************************************/

LOCAL VOID handle_menu (window, title, item)
WINDOWP window;
WORD    title, item;

{
  BOOLEAN    is_graf, is_blob, is_text;
  WORD       act_obj;
  RECT       old_clip;
  MKINFO     mk;
  EDFIELD    *ed_field;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  mask_spec = m_get_mask_spec (mask_spec);
  ed_field  = &mask_spec->ed_field [mask_spec->act_obj];

  is_graf = ed_field->type == TYPE_PICTURE;
  is_blob = IS_BLOB (ed_field->type);
  is_text = ! (is_graf || is_blob);

  if (window != NULL) menu_normal (window, title, FALSE);       /* invert title */

  mfix_iconbar (window);

  switch (title)
  {
    case MMINFO   : if (item == MMASKINF) hndl_alert (ERR_NOINFO);
                    break;
    case MMRECORD : switch (item)
                    {
                      case MMSAVE   : msave (window);          break;
                      case MMINSERT : minsert (window);        break;
                      case MMUPDATE : mupdate (window);        break;
                      case MMSEARCH : msearch (window, FALSE); break;
                      case MMMULTI  : msearch (window, TRUE);  break;
                      case MMDELETE : mdelete (window);        break;
                      case MMCALC   : mcalc (window);          break;
                    } /* switch */
                    break;
    case MMACTION : switch (item)
                    {
                      case MMCLEAR : mclear (window); break;
                      case MMPREV  : mprev (window);  break;
                      case MMNEXT  : mnext (window);  break;
                      case MMFIRST : mfirst (window); break;
                      case MMLAST  : mlast (window);  break;
                    } /* switch */
                    break;
    case MMOPTION : switch (item)
                    {
                      case MMIMPORT : if (is_graf) mu_grafimp (mask_spec, NULL, mask_spec->act_obj);
                                      if (is_blob) mu_blobimp (mask_spec);
                                      if (is_text)
                                      {
                                        act_obj = mask_spec->act_obj;
                                        m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);
                                        m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
                                        mask_spec->act_obj = -1;

                                        old_clip  = clip;
                                        mu_textimp (mask_spec, NULL, act_obj);	/* clipping will be destroyed when using commdlg */
                                        set_clip (TRUE, &old_clip);

                                        m_ed_index (mask_spec, act_obj, 1, NULL);
                                        m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
                                      } /* if */
                                      break;
                      case MMEXPORT : if (is_graf) mu_grafexp (mask_spec, NULL);
                                      if (is_blob) mu_blobexp (mask_spec);
                                      if (is_text) mu_textexp (mask_spec, NULL);
                                      break;
                      case MMOPEN   : m_edopen (mask_spec);
                                      break;
                      case MMFILENA : mu_sel_ext (mask_spec);
                                      break;
                      case MMCHANGE : mu_change (mask_spec, "");
                                      break;
                      case MMJOIN   : mjoin (window);
                                      break;
                      case MMPOPUP  : mk.momask   = 0x0001;
                                      mk.mobutton = 0x0000;
                                      mk.breturn  = 1;
                                      col_popup (window, &mk, TRUE);
                                      break;
                    } /* switch */
                    break;
  } /* switch */

  if (window != NULL) menu_normal (window, title, TRUE);        /* normalize title */
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
  WORD      message;
  EDFIELD   *ed_field;
  MFIELD    *mfield;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  ret = TRUE;
  ext = (action & DO_EXTERNAL) != 0;
ext = ext; /* dummy */

  switch (action & 0x00FF)
  {
    case DO_UNDO   : ret = TRUE;
                     break;

    case DO_CUT    :
    case DO_COPY   :
    case DO_PASTE  :
    case DO_CLEAR  :
    case DO_SELALL : if (mask_spec->act_obj < 0) return (ret);
                     ed_field = &mask_spec->ed_field [mask_spec->act_obj];
                     mfield   = ed_field->mfield;

                     if (IS_EDOBJ (mfield) && (ed_field->type != TYPE_PICTURE) && ! IS_BLOB (ed_field->type))
                     {
                       switch (action & 0x00FF)
                       {
                         case DO_CUT    : message = ED_CANCUT;    break;
                         case DO_COPY   : message = ED_CANCOPY;   break;
                         case DO_PASTE  : message = ED_CANPASTE;  break;
                         case DO_CLEAR  : message = ED_CANCLEAR;  break;
                         case DO_SELALL : message = ED_CANSELALL; break;
                       } /* switch */

                       return (edit_obj (&mask_spec->ed, message, 0, NULL));
                     } /* if */
                     break;

    case DO_CLOSE  : ret = test_mask (mask_spec);
                     break;
    case DO_DELETE : ret = TRUE;
                     break;
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
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  if (mask_spec->edobjs > 0) m_edit_obj (mask_spec, MO_EXIT, 0, NULL);

  mu_free (mask_spec, TRUE);
  set_meminfo ();
} /* wi_delete */

/*****************************************************************************/
/* Zeichne Fensterinhalt                                                     */
/*****************************************************************************/

LOCAL VOID wi_draw (window)
WINDOWP window;

{
  WORD      x, y, height;
  WORD      menu_height;
  RECT      r;
  MASK_SPEC *mask_spec;

  mask_spec   = (MASK_SPEC *)window->special;
  menu_height = (window->menu != NULL) ? gl_hattr : 0;

  x = window->work.x;
  y = window->work.y + menu_height;

  height  = 0;
  height += (mask_spec->sm_flags & SM_SHOW_INFO)  ? mask_info.infoheight : 0;
  height += (mask_spec->sm_flags & SM_SHOW_ICONS) ? mask_info.iconheight : 0;

  xywh2rect (x, y, maskicon->ob_width, height, &r);

  if (rc_intersect (&clip, &r))
  {
    mfix_iconbar (window);
    objc_draw (maskicon, ROOT, MAX_DEPTH, r.x, r.y, r.w, r.h);
  } /* if */

  r = clip;

  if (rc_intersect (&window->scroll, &r))
  {
    set_clip (TRUE, &r);

    mask_spec = m_get_mask_spec (mask_spec);	/* switch to submask eventually */
    m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);

    draw_mask ((MASK_SPEC *)window->special, vdi_handle);

    m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
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

  wind_get (window->handle, WF_CURRXYWH, &r.x, &r.y, &r.w, &r.h);

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

    if (diff.w != 0)				/* Wegen SS_INSIDE */
    {
      r    = window->work;
      r.y += (window->menu != NULL) ? gl_hattr : 0;
      r.h  = mask_info.infoheight;
      set_redraw (window, &r);
    } /* if */
  } /* if */
} /* wi_snap */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  return (DRAG_NOACTN);
} /* wi_drag */

/*****************************************************************************/
/* Selektieren des Fensterinhalts                                            */
/*****************************************************************************/

LOCAL VOID wi_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (find_top () == window)
  {
    if (sel_window != window) unclick_window (sel_window);
    set_clip (TRUE, &window->scroll);
    m_click ((MASK_SPEC *)window->special, mk, FALSE);
  } /* if */
} /* wi_click */

/*****************************************************************************/

LOCAL VOID wi_unclick (window)
WINDOWP window;

{
  m_unclick ((MASK_SPEC *)window->special);
} /* wi_unclick */

/*****************************************************************************/
/* Taste fÅr Fenster                                                         */
/*****************************************************************************/

LOCAL BOOLEAN wi_key (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD       msg;
  FIELD_INFO field_info;
  BYTE       *buffer;
  EDFIELD    *ed_field;
  MFIELD     *mfield;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  if (find_top () != window) return (FALSE);

  if (mk->alt)
    if (m_button_key (mask_spec, mk)) return (TRUE);

  if ((mk->ctrl) || (mk->alt))
    if (menu_key (window, mk)) return (TRUE);

  set_period (mk);

  set_clip (TRUE, &window->scroll);
  mfix_iconbar (window);

  if ((mk->shift) && (mk->scan_code == ENTER))
  {
    msave (window);
    return (TRUE);
  } /* if */

  if ((mk->shift) && (mk->scan_code == RETURN))
  {
    minsert (window);
    return (TRUE);
  } /* if */

  if (mk->scan_code == TAB)
  {
    hide_mouse ();
    mask_spec = m_get_mask_spec (mask_spec);
    m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);

    if (mk->shift)
      mask_spec = ed_prev (window);
    else
      mask_spec = ed_next (window);

    m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
    show_mouse ();

    ed_field = &mask_spec->ed_field [mask_spec->act_obj];
    buffer   = mask_spec->buffer;

    db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

    if (is_null (field_info.type, buffer + field_info.addr) && mask_config.fsel)
      switch (ed_field->type)
      {
        case TYPE_EXTERN  : mu_sel_ext (mask_spec);                           break;
        case TYPE_PICTURE : mu_grafimp (mask_spec, NULL, mask_spec->act_obj); break;
        case TYPE_VARBYTE :
        case TYPE_VARWORD :
        case TYPE_VARLONG : mu_blobimp (mask_spec);                           break;
      } /* switch */

    return (TRUE);
  } /* if */

  if (mk->shift)
  {
    if ((mk->scan_code == UP) || (mk->scan_code == DOWN))
    {
      mask_spec = m_get_mask_spec (mask_spec);
      ed_field  = &mask_spec->ed_field [mask_spec->act_obj];
      mfield    = ed_field->mfield;

      if ((mfield->h > 1) && IS_EDOBJ (mfield))	/* enable page up/down with shift up/down on multiline fields */
      {
        m_edit_obj (mask_spec, MO_KEY, 0, mk);
        return (TRUE);
      } /* if */

      hide_mouse ();
      m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);

      if (mk->scan_code == UP)
        mask_spec = ed_first (window);
      else
        mask_spec = ed_last (window);

      m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
      show_mouse ();

      return (TRUE);
    } /* if */
  } /* if */

  mask_spec = m_get_mask_spec (mask_spec);

  msg = m_edit_obj (mask_spec, MO_KEY, 0, mk);
  switch (msg)
  {

    case MO_OK            : return (TRUE);
    case MO_CHARNOTUSED   : if (mk->ascii_code == CR)
                            {
                              mk->scan_code = TAB;
                              mk->shift     = FALSE;
                              wi_key (window, mk);
                              return (TRUE);
                            } /* if */

                            return (FALSE);
    case MO_BUFFERCHANGED : m_setdirty (mask_spec, TRUE);
                            return (TRUE);
  } /* switch */

  return (FALSE);
} /* wi_key */

/*****************************************************************************/

/* [GS] 5.1d Start: */
LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg, MKINFO *mk)
/* Ende; alt:
LOCAL BOOLEAN wi_message (WINDOWP window, WORD *msg)
*/
{
/* [GS] 5.1c Start: */
  WORD      err;
  EDFIELD   *ed_field;
  MFIELD    *mfield;
  VOID      *buffer;

  BOOLEAN    in_arrow, is_button, is_graf, is_submask;
  WORD       obj, sub;
  MASK_SPEC  *sub_spec;
/* Ende */

  WORD      i;
  BYTE      *pFilename;
  SUBMASK   *submask;
  MASK_SPEC *mask_spec;

  if (msg [0] == OLGA_UPDATED)
  {
    if (olga_apid >= 0)				/* search for objects with corresponding filename */
    {
      mask_spec = (MASK_SPEC *)window->special;
      pFilename = (BYTE *)*(LONG *)(msg + 3);
      str_upper (pFilename);

      HandleOlgaUpdated (mask_spec, pFilename);

      if (mask_spec->num_submasks > 0)		/* check also submasks for modified olga objects */
      {
        submask = mask_spec->Submask;

        for (i = 0; i < mask_spec->num_submasks; i++, submask++)
          HandleOlgaUpdated (submask->pMaskSpec, pFilename);
      } /* if */
    } /* if */

    return (FALSE);	/* let other mask windows also handle this message */
  } /* if */

/* [GS] 5.1c Start: */
	if ( msg [0] == AP_DRAGDROP  && msg [3] == window->handle)			/* sind wir gemeint?	*/
	{
		mk->mox = msg [4];
		mk->moy = msg [5];
		mask_spec = (MASK_SPEC *)window->special;
		sub_spec = m_get_mask_spec (mask_spec);

    obj = m_find_obj (mask_spec, mk, &in_arrow, &is_button, &is_submask, &is_graf, &sub);

		if ( obj == NIL || is_button || is_submask || is_graf )
			return TRUE;

		if (sub_spec->act_obj < 0)
			return TRUE;
		ed_field = &sub_spec->ed_field [ obj ];
		mfield   = ed_field->mfield;
		
		if (IS_EDOBJ (mfield) && (ed_field->type != TYPE_PICTURE) && ! IS_BLOB (ed_field->type))
		{
		 buffer = dd_start ( msg );
		 if ( buffer != NULL )
		 {
			 err = edit_obj (&mask_spec->ed, ED_PASTETXT, 0, buffer);
			 redraw_window ( window , &window->work );
			 if (err != ED_OK)
			 {
			   switch (err)
			   {
			     case ED_NOMEMORY      : hndl_alert (ERR_NOMEMORY);    break;
			     case ED_BUFFERCHANGED : m_setdirty (mask_spec, TRUE); break;
			     case ED_2MANYLINES    : hndl_alert (ERR_2MANYLINES);  break;
			   } /* switch */
			 } /* if */
			 dd_end ();
			} /* if */
		} /* if */

		return TRUE;
	} /* if */
/* Ende */

  return (FALSE);
} /* wi_message */

/*****************************************************************************/

LOCAL VOID wi_top (window)
WINDOWP window;

{
  m_all_submasks ((MASK_SPEC *)window->special);
} /* wi_top */

/*****************************************************************************/

LOCAL VOID wi_untop (window)
WINDOWP window;

{
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  mask_spec->clear_buffered = FALSE;
} /* wi_untop */

/*****************************************************************************/
/* Cut/Copy/Paste fÅr Fenster                                                */
/*****************************************************************************/

LOCAL VOID wi_edit (window, action)
WINDOWP window;
WORD    action;

{
  BOOLEAN   ext;
  WORD      message, err;
  EDFIELD   *ed_field;
  MFIELD    *mfield;
  MASK_SPEC *mask_spec;

  ext = (action & DO_EXTERNAL) != 0;
ext = ext;

  switch (action & 0x00FF)
  {
    case DO_UNDO   : m_do_undo (window, TRUE);
                     break;

    case DO_CUT    :
    case DO_COPY   :
    case DO_PASTE  :
    case DO_CLEAR  :
    case DO_SELALL : mask_spec = (MASK_SPEC *)window->special;
                     mask_spec = m_get_mask_spec (mask_spec);
                     if (mask_spec->act_obj < 0) return;
                     ed_field = &mask_spec->ed_field [mask_spec->act_obj];
                     mfield   = ed_field->mfield;

                     if (IS_EDOBJ (mfield) && (ed_field->type != TYPE_PICTURE) && ! IS_BLOB (ed_field->type))
                     {
                       switch (action & 0x00FF)
                       {
                         case DO_CUT    : message = ED_CUT;    break;
                         case DO_COPY   : message = ED_COPY;   break;
                         case DO_PASTE  : message = ED_PASTE;  break;
                         case DO_CLEAR  : message = ED_CLEAR;  break;
                         case DO_SELALL : message = ED_SELALL; break;
                       } /* switch */

                       set_clip (TRUE, &window->scroll);	/* set clipping to window so cut and clear can draw edit field */
                       err = edit_obj (&mask_spec->ed, message, 0, NULL);

                       if (err != ED_OK)
                       {
                         switch (err)
                         {
                           case ED_NOMEMORY      : hndl_alert (ERR_NOMEMORY);    break;
                           case ED_BUFFERCHANGED : m_setdirty (mask_spec, TRUE); break;
                           case ED_2MANYLINES    : hndl_alert (ERR_2MANYLINES);  break;
                         } /* switch */
                       } /* if */
                     } /* if */
                     break;
  } /* switch */
} /* wi_edit */

