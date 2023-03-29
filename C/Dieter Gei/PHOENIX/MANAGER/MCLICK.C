/*****************************************************************************
 *
 * Module : MCLICK.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the clicking inside a mask window.
 *
 * History:
 * 08.09.04: m_winame: Der Name der Maske wird mit ausgegeben.
 * 08.02.04: sound.h auskommentiert.
 * 18.01.04: comm2menu entsprechend erweitert
 *					 MB_USERHELPST added in two function
 * 21.12.02: In m_edopen wird beim Feldtyp TYPE_CHAR nicht mehr abgefragt ob der
 *           Inhalt NULL ist.
 * 30.11.02: m_ed_next so erweitert, dass beim einem Ausgabefeld am Anfang und
 *           Ende der wieder am Ende/Anfang weiter gemacht wird.
 * 02.11.02: Bei show_extern werden alle unbekannten Arten per av_startprog an
 *					 AV-Server weitergegeben.
 * 19.03.97: Handle graphics objects at last in m_find_obj
 * 17.03.97: mGetPicFilename added
 * 11.03.97: Parameter is_graf added to m_find_obj
 * 10.03.97: Function button_account, call to AccountNameExec added
 * 06.03.97: MB_ACCOUNT added
 * 16.06.96: strcmp replaced by stricmp in mu_grafimp
 * 13.06.96: Function play_sound modified for new sound functions
 * 03.11.95: Function button_multi added
 * 12.10.95: DrawString called with default color in sm_as_mask
 * 21.09.95: Variable hbox corrected in get_fattr
 * 16.08.95: Setting of bk_color for checkboxes added to m_ed_index
 * 11.08.95: Drawing 3d added to m_draw_field
 * 07.08.95: 3D functionality added to m_get_rect, m_draw_cr
 * 03.05.95: Using dynamic memory for column names buffer size in sm2sql
 * 24.04.95: Call to set_clip moved beyond else in m_all_fields
 * 21.04.95: Function m_is_editable added
 * 30.03.95: Set warn_table to FALSE before sql_exec in m_sm_init
 * 23.03.95: Variable prn initialized to NULL in button_report
 * 22.03.95: Test on edobj added, searching also allowed in submasks in m_search
 * 15.03.95: Parameter asked added to m_save_rec
 * 14.03.95: Function m_save_all added
 * 04.03.95: Call to db_recloc moved from m_save to m_insert, m_update
 * 02.03.95: Function m_change_buffer added
 * 27.02.95: Parameter sub added to call to m_find_obj
 * 21.02.95: Call to med_first added to m_clear
 * 16.02.95: Fixed error in sb_scroll_list (rc_intersect with windows->scroll)
 * 12.02.95: Function m_get_mask_spec added
 * 07.02.95: Error when clicking in edit fields below any submask fixed in m_find_obj
 * 04.02.95: Handling of M_SUBMASK added to several functions
 * 02.02.95: Parameter bDrawAttributes added to m_all_fields
 * 31.01.95: Function sb_scroll_mask is using DrawString
 * 27.01.95: Function m_calc_sm_attr added
 * 23.01.95: Set cursor (act_obj) to -1 in m_sm_init
 * 19.01.95: Parameter window changed to mask_spec in all functions
 * 18.01.95: Parameter window changed to mask_spec in m_get_rect, m_get_edrect
 * 17.01.95: Parameter window changed to mask_spec in m_all_submasks when calling draw_sm
 * 11.01.95: Redraw only selected line in hndl_submask, character ' replaced with " in m_varsql2sql
 * 10.01.95: Function sb_scroll completed
 * 05.01.95: Functions m_sm_init & sm2sql moved from mutil.c
 * 04.01.95: Callback function sb_callback for scroll bars in submask added
 * 08.12.94: Function hndl_submask added
 * 24.11.94: Functions m_all_submasks, m_clr_submasks added
 * 21.11.94: Call to mu_sm_init added where necessary
 * 20.11.94: Call to draw_sm in m_all_fields added
 * 14.11.94: Function m_text_extend added
 * 17.10.94: Bounding rectabgle for submasks added to m_get_rect
 * 06.10.94: Handling of submasks added to m_get_rect
 * 24.08.94: Variable stdbuttons in MASK_SPEC changed to (sm_flags & SM_SHOW_ICONS)
 * 16.08.94: Variable act_use_fonts added
 * 03.08.94: Checkboxes can now be used with TYPE_FLOAT
 * 05.07.94: Call to db_reclock added to m_save_rec added
 * 04.06.94: Draw window->work if record not found in m_search_full
 * 26.05.94: Function upd_iconbar added
 * 19.05.94: Function m_search_full added
 * 17.05.94: Sequential search implemented in m_search
 * 25.04.94: ED_USEPOS used in m_ed_index
 * 29.03.94: Function v_text called with no last parameter
 * 19.03.94: Number of copies in call to do_report added
 * 08.01.94: Added 256 bytes instead of 100 for buffer in button_query
 * 05.01.94: ListBoxRedraw in m_search only if stdbuttons
 * 16.12.93: Call to global's scan_to_ascii used
 * 22.11.93: ListBoxRedraw in m_search added
 * 14.11.93: Using fontdesc
 * 08.10.93: Show more characters in ComboBox in new_index
 * 07.10.93: m_seticonpos moved to MASK.C to mfix_iconbar
 * 06.10.93: New combobox used, new_index moved from mask.c
 * 03.10.93: Call to window_button only if stdbuttons and test if state is SELECTED in m_click
 * 27.09.93: Call to window_button added to m_click
 * 24.09.93: Call to m_all_fields in m_delete modified
 * 09.09.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include <ctype.h>

#include "import.h"

#if GEMDOS
/* [GS] 5.1d alt:
#include <sound.h>
*/
#include <snd_lib.h>
#include <load_snd.h>
#endif

#include "global.h"
#include "av.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "cbobj.h"
#include "rbobj.h"
#include "editobj.h"
#include "emptyobj.h"
#include "gemobj.h"
#include "help.h"
#include "imageobj.h"

#include "accobj.h"
#include "account.h"
#include "batexec.h"
#include "dialog.h"
#include "edit.h"
#include "image.h"
#include "list.h"
#include "mask.h"
#include "maskobj.h"
#include "maskdraw.h"
#include "maskutil.h"
#include "meta.h"
#include "process.h"
#include "repmake.h"
#include "resource.h"
#include "sql.h"

#include "export.h"
#include "mclick.h"

/****** DEFINES **************************************************************/

#define BUTTON_SIZE       13	/* width and height of checkboxes and radio buttons in resource file */
#define BUTTONL_WIDTH     16	/* width and height of low resolution checkboxes and radio buttons */
#define BUTTONL_HEIGHT     8	/* width and height of low resolution checkboxes and radio buttons */

#define INX_VISIBLE	 6      /* number of visible indexes for new_index */
#define MIN_WICON       16      /* see smallest checkbox/rb icons in resource file */
#define MIN_HICON        5      /* see smallest checkbox/rb icons in resource file */
#define RADIO_DELIMITER '|'     /* delimiter for radio button choices */
#define CB_DELIMITER    '|'     /* delimiter for checkbox values */
#define MAX_COLBUFFER   8192	/* max size for buffering column names in sm2sql */

#define CHR_FIELDSEP     ','
#define CHR_TBLSEP       '.'
#define CHR_BRANCH       '>'
#define CHR_ORDERSEP     ';'
#define CHR_REPSEP       ';'
#define CHR_STRDEL       '\''
#define CHR_MULTISEP     ','	/* for multi buttons (name of button1, button2,...) */

#define IS_BLOB(type)   ((type == TYPE_VARBYTE) || (type == TYPE_VARWORD) || (type == TYPE_VARLONG))

/****** TYPES ****************************************************************/

typedef struct
{
  WORD dstcol;
  WORD refcol;
} LU;                           /* used in ins_lookup */

typedef struct
{
  WORD title;
  WORD item;
} MENUSPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD     act_font;        /* actual font in draw_text */
LOCAL WORD     act_point;       /* actual point in draw_text */
LOCAL BOOLEAN  act_use_fonts;   /* actual use_font in draw_text */
LOCAL WORD     dt_wbox [256];   /* width of boxes of whole charset for draw_text */
LOCAL BOOLEAN  alert_shown;     /* TRUE if alert message was on screen */
LOCAL BOOLEAN  init_sound;      /* TRUE if sound was initialized */
LOCAL WORD     num_chars;	/* number of characters for combobox */
LOCAL FULLNAME szOlgaFilename;	/* for OLGA communication, should be static */

LOCAL MENUSPEC comm2menu [MB_COMMANDS] =
{
  MMINFO,   MMASKINF,           /* MB_INFO        */

  MMRECORD, MMSAVE,             /* MB_SAVE        */
  MMRECORD, MMINSERT,           /* MB_INSERT      */
  MMRECORD, MMUPDATE,           /* MB_UPDATE      */
  MMRECORD, MMSEARCH,           /* MB_SEARCH      */
  MMRECORD, MMDELETE,           /* MB_DELETE      */
  MMRECORD, MMCALC,             /* MB_CALC        */

  MMACTION, MMCLEAR,            /* MB_CLEAR       */
  MMACTION, MMPREV,             /* MB_PREV        */
  MMACTION, MMNEXT,             /* MB_NEXT        */
  MMACTION, MMFIRST,            /* MB_FIRST       */
  MMACTION, MMLAST,             /* MB_LAST        */

  MMOPTION, MMIMPORT,           /* MB_IMPORT      */
  MMOPTION, MMEXPORT,           /* MB_EXPORT      */
  MMOPTION, MMOPEN,             /* MB_OPEN        */
  MMOPTION, MMFILENA,           /* MB_FILENAME    */
  MMOPTION, MMCHANGE,           /* MB_CHANGE      */
  MMOPTION, MMJOIN,             /* MB_JOIN_MASK   */
  MMOPTION, MMJOIN,             /* MB_JOIN_TABLE  */
  MMOPTION, MMJOIN,             /* MB_JOIN_NEW    */
  MMOPTION, MMPOPUP,            /* MB_POPUP       */

  FAILURE,  FAILURE,            /* MB_REPORT      */
  FAILURE,  FAILURE,            /* MB_PRINT       */
  FAILURE,  FAILURE,            /* MB_USERHELP    */
  FAILURE,  FAILURE,            /* MB_WINFULL     */
  FAILURE,  FAILURE,            /* MB_WINCLOSE    */
  FAILURE,  FAILURE,            /* MB_QUERY_MASK  */
  FAILURE,  FAILURE,            /* MB_QUERY_TABLE */
  FAILURE,  FAILURE,            /* MB_BATCH       */
  FAILURE,  FAILURE,            /* MB_MULTIBUTTON */
  FAILURE,  FAILURE,            /* MB_ACCOUNT     */
/* [GS] Start: */
  FAILURE,  FAILURE             /* MB_USERHELPST  */
/* Ende */
}; /* comm2menu */

/****** FUNCTIONS ************************************************************/

#if GEMDOS
EXTERN VOID vdi _((VOID));
#endif

LOCAL VOID upd_iconbar    (MASK_SPEC *mask_spec, WORD obj, WORD act_obj, BOOLEAN null);
LOCAL VOID new_index      (MASK_SPEC *mask_spec, MKINFO *mk);
LOCAL VOID m_save         (MASK_SPEC *mask_spec, WORD *edobj, MKINFO *mk);
LOCAL VOID m_insert       (MASK_SPEC *mask_spec, WORD *edobj);
LOCAL VOID m_update       (MASK_SPEC *mask_spec, WORD *edobj);
LOCAL VOID m_delete       (MASK_SPEC *mask_spec);
LOCAL VOID m_search       (MASK_SPEC *mask_spec, WORD edobj, MKINFO *mk);
LOCAL VOID m_next         (MASK_SPEC *mask_spec, WORD dir, MKINFO *mk);
LOCAL VOID m_clear        (MASK_SPEC *mask_spec, WORD null_flag, BOOLEAN rec_unlock);
LOCAL VOID m_calc         (MASK_SPEC *mask_spec, WORD obj);
LOCAL WORD ins_lookup     (MASK_SPEC *mask_spec);
LOCAL WORD fill_lus       (MASK_SPEC *mask_spec, LU *lu, WORD reftbl, WORD dsttbl);
LOCAL VOID get_fattr      (WORD out_handle, WORD wbox, WORD hbox, FATTR *fattr);
LOCAL VOID draw_checkbox  (WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color);
LOCAL VOID draw_rbutton   (WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color);
LOCAL VOID draw_pic       (MASK_SPEC *mask_spec, WORD edobj);
LOCAL VOID set_mredraw    (MASK_SPEC *mask_spec, WORD obj);

LOCAL VOID hndl_obj       (MASK_SPEC *mask_spec, MASK_SPEC *old_spec, WORD obj, MKINFO *mk, BOOLEAN arrow);
LOCAL VOID hndl_button    (MASK_SPEC *mask_spec, MASK_SPEC *sub_spec, WORD obj, MKINFO *mk);
LOCAL VOID hndl_submask   (MASK_SPEC *mask_spec, WORD sub, MKINFO *mk);
LOCAL VOID hndl_graf      (MASK_SPEC *mask_spec, MASK_SPEC *sub_spec, WORD obj, MKINFO *mk);
LOCAL WORD sm2sql         (MASK_SPEC *mask_spec, MSUBMASK *msubmask, BYTE *sql);
LOCAL VOID show_extern    (BYTE *filename);
LOCAL VOID open_sound     (BYTE *filename);
LOCAL VOID v_draw_text    (WORD out_handle, RECT *r, BYTE *p, WORD font, WORD point, BOOLEAN wordbreak);
LOCAL BYTE *next_line     (WORD width, BYTE *p, BYTE *s, WORD *wbox, BOOLEAN wordbreak);
LOCAL VOID get_wboxes     (WORD vdi_handle, WORD *boxes, WORD low, WORD high);
LOCAL VOID get_rtext      (BYTE *p, BYTE *s, WORD index);
LOCAL VOID get_cbsvals    (LONG size, BYTE *vals, BYTE *sel, BYTE *unsel);
LOCAL VOID get_cbwvals    (LONG size, BYTE *vals, WORD *sel, WORD *unsel);
LOCAL VOID get_cblvals    (LONG size, BYTE *vals, LONG *sel, LONG *unsel);
LOCAL VOID get_cbfvals    (LONG size, BYTE *vals, DOUBLE *sel, DOUBLE *unsel);
LOCAL VOID get_cbvals     (LONG size, WORD type, BYTE *p, BOOLEAN selected, VOID *buffer);
LOCAL WORD test_rec       (MASK_SPEC *mask_spec, WORD status);
LOCAL BOOL test_bounds    (BASE *base, WORD table, WORD field, VOID *buffer, BOOLEAN show_error, LONG lower, LONG upper);
LOCAL WORD get_cols       (BASE *base, WORD table, BYTE *colstr, WORD *cols);
LOCAL VOID check_where    (BYTE *s);

LOCAL VOID do_button      (MASK_SPEC *mask_spec, WORD command, CHAR *param, WORD obj, MKINFO *mk);
LOCAL VOID button_join    (MASK_SPEC *mask_spec, WORD command, BYTE *param);
LOCAL VOID button_report  (MASK_SPEC *mask_spec, BYTE *param, WORD device);
LOCAL VOID button_query   (MASK_SPEC *mask_spec, WORD command, BYTE *param);
LOCAL VOID button_batch   (MASK_SPEC *mask_spec, BYTE *param);
LOCAL VOID button_multi   (MASK_SPEC *mask_spec, BYTE *param, MKINFO *mk);
LOCAL VOID button_account (MASK_SPEC *mask_spec, BYTE *param, WORD device);

LOCAL LONG sb_callback    (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p);
LOCAL VOID sb_scroll_list (SUBMASK *submask, LONG old_pos, LONG new_pos);
LOCAL VOID sb_scroll_mask (SUBMASK *submask, LONG old_pos, LONG new_pos);

LOCAL VOID play_sound     (BYTE *buffer, BOOLEAN wait);

/*****************************************************************************/

GLOBAL VOID m_init ()

{
  act_font      = FAILURE;
  act_point     = FAILURE;
  act_use_fonts = use_fonts;
  init_sound    = FALSE;
  num_chars     = maskicon [MIINDEX].ob_width / gl_wbox;
} /* m_init */

/*****************************************************************************/

GLOBAL VOID m_exit ()

{
#if GEMDOS
/*  if (init_sound) Exit_PH_Sound ();*/

#endif
} /* m_exit */

/*****************************************************************************/

GLOBAL VOID m_click (MASK_SPEC *mask_spec, MKINFO *mk, BOOLEAN button)
{
  BOOLEAN    ok, modify, conv;
  BOOLEAN    null, in_arrow, is_button, is_graf, is_submask;
  WORD       obj, act_obj, sub;
  TABLE_INFO table_info;
  WINDOWP    window;
  MASK_SPEC  *sub_spec;

  window      = mask_spec->window;
  obj         = NIL;
  alert_shown = FALSE;
  conv        = FALSE;

  mfix_iconbar (window);
  sub_spec = m_get_mask_spec (mask_spec);

  if (inside (mk->mox, mk->moy, &window->scroll) && ! button)   /* inside scroll area */
  {
    obj = m_find_obj (mask_spec, mk, &in_arrow, &is_button, &is_submask, &is_graf, &sub);

    if (obj != NIL)
    {
      if (is_graf)
        hndl_graf (mask_spec, sub_spec, obj, mk);
      else
        if (is_button)
          hndl_button (mask_spec, sub_spec, obj, mk);
        else
          if (is_submask)
            hndl_submask (mask_spec, sub, mk);
          else
            hndl_obj (mask_spec, sub_spec, obj, mk, in_arrow);
    } /* if */
    else
      if (inside (mk->mox, mk->moy, &window->scroll))   /* inside scroll area */
        if (! (mk->shift || mk->ctrl)) unclick_window (window); /* deselect */
  } /* if */
  else                                                          /* handle predefined buttons */
  {
    act_obj = sub_spec->act_obj;
    obj     = objc_find (maskicon, ROOT, MAX_DEPTH, mk->mox, mk->moy);

    if (mask_spec->sm_flags & SM_SHOW_ICONS)
    {
      switch (obj)
      {
        case MIINDEX  : do_state (maskicon, obj, SELECTED);
                        draw_win_obj (window, maskicon, obj);
                        new_index (mask_spec, mk);
                        undo_state (maskicon, obj, SELECTED);
                        draw_win_obj (window, maskicon, obj);
                        return;
        case MIASC    :
        case MIDESC   : window_button (window, maskicon, obj, mk->breturn);
                        if (is_state (maskicon, MIASC,  SELECTED) && (mask_spec->dir != ASCENDING) ||
                            is_state (maskicon, MIDESC, SELECTED) && (mask_spec->dir != DESCENDING))
                          mmaskreverse (window);
                        return;
      } /* switch */

      if ((obj != MIPREV) && (obj != MINEXT))
      {
        window_button (window, maskicon, obj, mk->breturn);
        if (! is_state (maskicon, obj, SELECTED)) return;
      } /* if */
    } /* if */

    if ((obj < MIFIRST) || is_state (maskicon, obj, DISABLED)) return;	/* no bitmap button selected */

    if ((obj == MIFIRST) || (obj == MILAST)) mk->breturn = 2;	/* simulate double click on prev/next */

    if ((MIFIRST <= obj) && (obj <= MILAST))
      if (mask_spec->any_dirty)
      {
        conv = TRUE;
        ok   = m_ed2field (sub_spec, sub_spec->act_obj, FALSE);
        if (! ok) return;
        if (! m_save_all (mask_spec, &act_obj)) return;
        alert_shown = TRUE;
        set_redraw (window, &window->scroll);
      } /* if, if */

    set_clip (TRUE, &window->work);
    do_state (maskicon, obj, SELECTED);
    if (mask_spec->sm_flags & SM_SHOW_ICONS) objc_draw (maskicon, obj, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);

    null   = is_null (TYPE_DBADDRESS, mask_spec->buffer);
    modify = (obj == MISAVE);

    if (act_obj >= 0)
    {
      set_clip (TRUE, &window->scroll);
      m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
      if (! conv) ok = m_ed2field (sub_spec, sub_spec->act_obj, FALSE);

      if (ok || ! modify)
      {
        m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
        sub_spec->act_obj = FAILURE;
      } /* if */
      else
      {
        undo_state (maskicon, obj, SELECTED);
        if (mask_spec->sm_flags & SM_SHOW_ICONS) objc_draw (maskicon, obj, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
        m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
        return;
      } /* else */
    } /* if */

    mask_spec->clear_buffered = FALSE;

    switch (obj)
    {
      case MISAVE   : m_save (mask_spec, &act_obj, mk);        break;
      case MIDELETE : m_delete (mask_spec);                    break;
      case MISEARCH : m_search (mask_spec, act_obj, mk);       break;
      case MIFIRST  : m_next (mask_spec, -mask_spec->dir, mk); break;
      case MIPREV   : m_next (mask_spec, -mask_spec->dir, mk); break;
      case MINEXT   : m_next (mask_spec, mask_spec->dir,  mk); break;
      case MILAST   : m_next (mask_spec, mask_spec->dir,  mk); break;
      case MICLEAR  : m_clear (mask_spec, M_SET_NULL, TRUE);   break;
      case MICALC   : m_calc (mask_spec, FAILURE);             break;
    } /* switch */

    v_tableinfo (mask_spec->db, mask_spec->table, &table_info);
    if (table_info.recs <= 1)
     if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor))
       v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir);

    upd_iconbar (mask_spec, obj, act_obj, null);
    sub_spec = m_get_mask_spec (mask_spec);	/* sub_spec could have been changed in m_clear */
    m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
  } /* else */
} /* m_click */

/*****************************************************************************/

GLOBAL VOID m_unclick (MASK_SPEC *mask_spec)
{
} /* m_unclick */

/*****************************************************************************/

GLOBAL BOOL m_button_key (MASK_SPEC *mask_spec, MKINFO *mk)
{
  WORD      i;
  UWORD     key;
  BUTTON    *button;
  MASK_SPEC *sub_spec;

  button   = mask_spec->button;
  sub_spec = m_get_mask_spec (mask_spec);

  for (i = 0; i < mask_spec->buttons; i++, button++)
    if (button->alt_char != NUL)
    {
      key = scan_to_ascii (button->alt_char);
      if (key == mk->kreturn)
      {
        hndl_button (mask_spec, sub_spec, button->obj, mk);
        return (TRUE);
      } /* if */
    } /* if, for */

  return (FALSE);
} /* m_button_key */

/*****************************************************************************/

GLOBAL WORD m_get_rect (MASK_SPEC *mask_spec, WORD out_handle, WORD class, MOBJECT *mobject, RECT *rect, FATTR *fattr)
{
  WORD     x, y, w, h, strwidth;
  WORD     xy [4];
  WORD     wchar, hchar;
  WORD     wbox, hbox;
  WORD     minimum, maximum, width;
  WORD     distances [5], effects [3];
  WORD     extent [8];
#if 0
  WORD     cell_width, cell_height;
  WORD     yfac;
#endif
  UWORD    flags;
  STRING   s;
  BYTE     *p;
  MFIELD   *mfield;
  MLINE    *mline;
  MTEXT    *mtext;
  MSUBMASK *msubmask;
  SYSMASK  *sysmask;
  WINDOWP  window;

  window    = mask_spec->window;
  sysmask   = mask_spec->mask;
  mfield    = &mobject->mfield;
  mtext     = &mobject->mtext;
  mline     = &mobject->mline;
  msubmask  = &mobject->msubmask;
  strwidth  = 0;

  mem_set (rect,  0, sizeof (RECT));
  mem_set (fattr, 0, sizeof (FATTR));

  x = (LONG)mfield->x * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
  y = (LONG)mfield->y * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;
  w = (LONG)mfield->w * gl_wbox / M_XUNITS;
  h = (LONG)mfield->h * gl_hbox / M_YUNITS;

  switch (class)
  {
    case M_FIELD   : flags = mfield->flags;

                     text_default (out_handle);
                     vst_font (out_handle, mfield->font);
                     vst_point (out_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);

                     if (! (mfield->flags & MF_UNITWH))
                     {
                       w = mfield->w * wbox;
                       h = mfield->h * hbox;
                     } /* if */

                     if (flags & MF_STDLABEL)
                       p = &sysmask->mask.buffer [mfield->field_name];
                     else
                       p = &sysmask->mask.buffer [mfield->label_name];

                     if (*p)
                     {
                       strcpy (s, p);
                       strcat (s, "_");          /* " " doesn't work, so take any char */
                       vqt_extent (out_handle, s, extent);
                       strwidth = extent [2] - extent [0];
                     } /* if */

                     switch (mfield->type)
                     {
                       case MT_LCHECKBOX   : vqt_extent (out_handle, p, extent);
                                             strwidth = extent [2] - extent [0];
                                             w = 3 * gl_wbox /*MIN_WICON*/;
                                             h  = max (h, (gl_hbox <= 8) ? BUTTONL_HEIGHT : BUTTON_SIZE);
                                             break;
                       case MT_RCHECKBOX   : w = 2 * gl_wbox;
                                             h = max (h, (gl_hbox <= 8) ? BUTTONL_HEIGHT : BUTTON_SIZE);
                                             break;
                       case MT_RADIOBUTTON : h -= hbox / 2;
                                             break;
                       case MT_POPUP       : get_fattr (out_handle, wbox, hbox, fattr);
                       default             : x -= EDIT_FRAME;
                                             y -= EDIT_FRAME;
                                             w += 2 * EDIT_FRAME + fattr->w_shadow + fattr->w_attr;
                                             h += 2 * EDIT_FRAME + fattr->h_shadow;
                                             break;
                     } /* switch */

                     xywh2rect (x, y, w + strwidth, h, rect);
                     break;
     case M_LINE   : xy [0] = (LONG)mline->x1 * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
                     xy [1] = (LONG)mline->y1 * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;
                     xy [2] = (LONG)mline->x2 * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
                     xy [3] = (LONG)mline->y2 * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;

                     array2rect (xy, rect);

                     if (mline->width > 1)
                     {
                       w = mline->width + 1;
                       rect->x -= w / 2;
                       rect->y -= w / 2;
                       rect->w += w;
                       rect->h += w;
                     } /* if */
                     break;
    case M_BOX     :
    case M_RBOX    :
    case M_GRAF    :
    case M_BUTTON  : xywh2rect (x, y, w, h, rect);
                     break;
    case M_SUBMASK : if (msubmask->flags & MSM_SHOW_TABLE)	/* show only full lines if submask will be shown as table */
                     {
#if 0
                       text_default (out_handle);
                       vst_font (out_handle, msubmask->font);
                       vst_point (out_handle, msubmask->point, &wchar, &hchar, &wbox, &hbox);
                       m_text_extent (out_handle, "x", FALSE, &cell_width, &cell_height);
                       if (out_handle == vdi_handle)
                         if (msubmask->flags & MF_SYSTEMFONT) vst_point (out_handle, gl_point, &wchar, &hchar, &wbox, &hbox);

                       yfac = cell_height + ADD_LINES;
                       h    = (h / yfac) * yfac;
#endif
                     } /* if */

                     xywh2rect (x - 1, y - 1, w + 2, h + 2, rect);	/* generate bounding rectangle */
                     break;
    case M_TEXT    : text_default (out_handle);
                     vst_effects (out_handle, mtext->effects);
                     vst_font (out_handle, mtext->font);
                     vst_point (out_handle, mtext->point, &wchar, &hchar, &wbox, &hbox);
                     if (out_handle == vdi_handle)
                       if (mtext->flags & MF_SYSTEMFONT) vst_height (out_handle, gl_hchar, &wchar, &hchar, &wbox, &hbox);
                     vqt_font_info (out_handle, &minimum, &maximum, distances, &width, effects);

                     h = 0;
                     w = 0;
                     p = &sysmask->mask.buffer [mtext->text];

                     if (*p)
                     {
                       vqt_extent (out_handle, p, extent);
                       w  = extent [2] - extent [0] + effects [2];
                       h  = extent [5] - extent [3];
                     } /* if */

                     xywh2rect (x, y, w, h, rect);
                     break;
  } /* switch */

  return (strwidth);
} /* m_get_rect */

/*****************************************************************************/

GLOBAL RECT m_get_edrect (MASK_SPEC *mask_spec, MFIELD *mfield, BOOLEAN absolute)
{
  WORD    x, y, w, h, strwidth;
  WORD    wchar, hchar;
  WORD    wbox, hbox;
  WORD    extent [8];
  UWORD   flags;
  RECT    rect;
  STRING  s;
  BYTE    *p;
  SYSMASK *sysmask;
  WINDOWP window;

  window   = mask_spec->window;
  sysmask  = mask_spec->mask;
  strwidth = 0;

  xywh2rect (0, 0, 0, 0, &rect);

  flags = mfield->flags;

  text_default (vdi_handle);
  vst_font (vdi_handle, mfield->font);
  vst_point (vdi_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);

  x = (LONG)mfield->x * gl_wbox / M_XUNITS;
  y = (LONG)mfield->y * gl_hbox / M_YUNITS;

  if (mfield->flags & MF_UNITWH)
  {
    w = (LONG)mfield->w * gl_wbox / M_XUNITS;
    h = (LONG)mfield->h * gl_hbox / M_YUNITS;
  } /* if */
  else
  {
    w = mfield->w * wbox;
    h = mfield->h * hbox;
  } /* else */

  if (absolute)
  {
    x += window->scroll.x - window->doc.x * window->xfac;
    y += window->scroll.y - window->doc.y * window->yfac;
  } /* if */

  if (flags & MF_STDLABEL)
    p = &sysmask->mask.buffer [mfield->field_name];
  else
    p = &sysmask->mask.buffer [mfield->label_name];

  if (*p)
  {
    strcpy (s, p);
    strcat (s, "_");                            /* " " doesn't work good, so take any char */
    vqt_extent (vdi_handle, s, extent);
    strwidth = extent [2] - extent [0];
  } /* if */

  switch (mfield->type)
  {
    case MT_LCHECKBOX   : vqt_extent (vdi_handle, p, extent);
                          strwidth = extent [2] - extent [0];
                          w = 3 * gl_wbox /*MIN_WICON*/;
                          h  = max (h, (gl_hbox <= 8) ? BUTTONL_HEIGHT : BUTTON_SIZE);
                          xywh2rect (x, y, w + strwidth, h, &rect);
                          break;
    case MT_RCHECKBOX   : w = 2 * gl_wbox;
                          h = max (h, (gl_hbox <= 8) ? BUTTONL_HEIGHT : BUTTON_SIZE);
                          xywh2rect (x, y, w + strwidth, h, &rect);
                          break;
    case MT_RADIOBUTTON : h -= hbox / 2;
                          xywh2rect (x, y, w + strwidth, h, &rect);
                          break;
    default             : xywh2rect (x + strwidth, y, w, h, &rect);
                          break;
  } /* switch */

  return (rect);
} /* m_get_edrect */

/*****************************************************************************/

GLOBAL VOID m_get_doc (MASK_SPEC *mask_spec, LONG *docw, LONG *doch)
{
  LONG    w, h;
  WORD    xy [4];
  WORD    x, y, obj, ret;
  RECT    r, rect;
  FATTR   fattr;
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;
  WINDOWP window;

  window  = mask_spec->window;
  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;

  w = 0;
  h = 0;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;
    m_get_rect (mask_spec, vdi_handle, mfield->class, mobject, &r, &fattr);

    if (mfield->class == M_LINE)
    {
      xy [0] = (LONG)mfield->x * gl_wbox / M_XUNITS;
      xy [1] = (LONG)mfield->y * gl_hbox / M_YUNITS;
      xy [2] = (LONG)mfield->w * gl_wbox / M_XUNITS;
      xy [3] = (LONG)mfield->h * gl_hbox / M_YUNITS;
      array2rect (xy, &rect);
      rect2xywh (&rect, &x, &y, &ret, &ret);
    } /* if */
    else
    {
      x = (LONG)mfield->x * gl_wbox / M_XUNITS;
      y = (LONG)mfield->y * gl_hbox / M_YUNITS;
    } /* else */

    if (mfield->class == M_FIELD)
    {
      x -= EDIT_FRAME;
      y -= EDIT_FRAME;
    } /* if */

    w = max (w, x + r.w);
    h = max (h, y + r.h);
  } /* for */

  *docw = (w + window->xfac - 1) / window->xfac;
  *doch = (h + window->yfac - 1) / window->yfac;
} /* m_get_doc */

/*****************************************************************************/

GLOBAL PMASK_SPEC m_get_mask_spec (MASK_SPEC *mask_spec)
{
  return ((mask_spec->act_sub == FAILURE) ? mask_spec : mask_spec->Submask [mask_spec->act_sub].pMaskSpec);
} /* m_get_mask_spec */

/*****************************************************************************/

GLOBAL WORD m_find_obj (MASK_SPEC *mask_spec, MKINFO *mk, BOOLEAN *in_arrow, BOOLEAN *is_button, BOOLEAN *is_submask, BOOLEAN *is_graf, WORD *sub)
{
  WORD    obj, edobj;
  RECT    r, arrow;
  FATTR   fattr;
  EDFIELD *ed_field;
  MBUTTON *mbutton;
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask     = mask_spec->mask;
  mobject     = (MOBJECT *)sysmask->mask.buffer;
  *in_arrow   = FALSE;
  *is_button  = FALSE;
  *is_submask = FALSE;
  *is_graf    = FALSE;
  *sub        = 0;

  for (obj = edobj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield  = &mobject->mfield;
    mbutton = &mobject->mbutton;
    m_get_rect (mask_spec, vdi_handle, mfield->class, mobject, &r, &fattr);

    if (mfield->class == M_BUTTON)
      if (inside (mk->mox, mk->moy, &r))
      {
        if (mbutton->flags & MBF_HIDDEN) return (FAILURE);
        *is_button = TRUE;

        return (obj);
      } /* if, if */

    if (mfield->class == M_SUBMASK)
      if (inside (mk->mox, mk->moy, &r))
      {
        *is_submask = TRUE;
        return (edobj);
      } /* if, if */

    if (mfield->class == M_FIELD)
      if (inside (mk->mox, mk->moy, &r))
      {
        ed_field = &mask_spec->ed_field [edobj];
        if (ed_field->flags & (COL_OUTPUT | COL_HIDDEN)) return (FAILURE);

        r.w -= fattr.w_shadow + fattr.w_attr;
        r.h -= fattr.h_shadow;
        xywh2rect (r.x + r.w - 1, r.y, fattr.w_attr + 1, r.h, &arrow);
        if (inside (mk->mox, mk->moy, &arrow)) *in_arrow = TRUE;

        return (edobj);
      } /* if, if */

    if (m_is_editable (mobject)) edobj++;
    if (mfield->class == M_SUBMASK) (*sub)++;
  } /* for */

  sysmask = mask_spec->mask;				/* now search for background images */
  mobject = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;
    m_get_rect (mask_spec, vdi_handle, mfield->class, mobject, &r, &fattr);

    if (mfield->class == M_GRAF)
      if (inside (mk->mox, mk->moy, &r))
      {
        *is_graf = TRUE;

        return (obj);
      } /* if, if */
  } /* for */

  return (FAILURE);
} /* m_find_obj */

/*****************************************************************************/

GLOBAL VOID m_draw_field (MASK_SPEC *mask_spec, WORD out_handle, MFIELD *mfield, RECT *r, FATTR *fattr, WORD strwidth, WORD edobj)
{
  BOOLEAN    selected;
  WORD       table, field, index, i, bk_color;
  WORD       x, y, w, h;
  WORD       wchar, hchar, wbox, hbox;
  WORD       wsel;
  LONG       lsel;
  DOUBLE     dsel;
  STRING     ssel;
  LONGSTR    s;
  FIELD_INFO field_info;
  RECT       frame, old_clip;
  FONTDESC   fontdesc;
  BYTE       *p;
  BYTE       *field_name;
  BYTE       *buffer;
  EDFIELD    *ed_field;
  SYSMASK    *sysmask;

  sysmask  = mask_spec->mask;
  ed_field = &mask_spec->ed_field [edobj];
  buffer   = mask_spec->buffer;

  if (ed_field->flags & COL_HIDDEN) return;

  rect2xywh (r, &x, &y, &w, &h);

  r->x += EDIT_FRAME + strwidth;     /* frame for editable field */
  r->y += EDIT_FRAME;
  r->w -= 2 * EDIT_FRAME + strwidth + fattr->w_shadow + fattr->w_attr;
  r->h -= 2 * EDIT_FRAME + fattr->h_shadow;

  table      = ed_field->table;
  field_name = &sysmask->mask.buffer [mfield->field_name];
  strcpy (field_info.name, field_name);
  field = db_fieldinfo (mask_spec->db->base, table, FAILURE, &field_info);

  bk_color = is_null (TYPE_LONG, &sysmask->bkcolor) ? WHITE : IndexFromColor32 (sysmask->bkcolor);
  if (colors == 2) bk_color = WHITE;

  fontdesc.font    = mfield->font;
  fontdesc.point   = mfield->point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = mfield->color;

  switch (mfield->type)
  {
    case MT_NEUTRAL     :
    case MT_OUTLINED    :
    case MT_UNDERLINED  :
    case MT_POPUP       : if (field_info.type == TYPE_PICTURE)
                          {
                            draw_pic (mask_spec, edobj);
                            return;
                          } /* if */

                          if (mask_config.play_direct && IS_BLOB (field_info.type))
                          {
                            play_sound (buffer + field_info.addr, FALSE);
                            return;
                          } /* if */

                          vst_color (out_handle, mfield->color);
                          if ((mfield->font > FONT_SYSTEM) || (mfield->h > 1)) clr_area (r);

                          if (HASWILD (field_info.type) && (mfield->h > 1) || (mfield->font > FONT_SYSTEM))
                          {
                            if (HASWILD (field_info.type))
                              p = buffer + field_info.addr;
                            else
                            {
                              col2str (mask_spec->db, table, buffer, field, -mfield->w, s);
                              p = s;
                            } /* else */

                            frame    = *r;
                            old_clip = clip;

                            rc_intersect (&clip, &frame);
                            set_clip (TRUE, &frame);
                            v_draw_text (out_handle, r, p, mfield->font, mfield->point, mfield->flags & MF_WORDBREAK);
                            set_clip (TRUE, &old_clip);
                          } /* if */
                          else
                          {
                            col2str (mask_spec->db, table, buffer, field, -mfield->w, s);
                            v_gtext (out_handle, r->x, r->y, s);
                          } /* if */
                          break;
    case MT_LCHECKBOX   :
    case MT_RCHECKBOX   : p        = (mfield->extra == FAILURE) ? NULL : &sysmask->mask.buffer [mfield->extra];
                          buffer   = buffer + field_info.addr;
                          selected = FALSE;

                          switch (field_info.type)
                          {
                            case TYPE_CHAR  : get_cbsvals (field_info.size, p, ssel, NULL);
                                              selected = strncmp (buffer, ssel, (SIZE_T)field_info.size - 1) == 0;
                                              break;
                            case TYPE_WORD  : get_cbwvals (field_info.size, p, &wsel, NULL);
                                              selected = wsel == *(WORD *)buffer;
                                              break;
                            case TYPE_LONG  : get_cblvals (field_info.size, p, &lsel, NULL);
                                              selected = lsel == *(LONG *)buffer;
                                              break;
                            case TYPE_FLOAT : get_cbfvals (field_info.size, p, &dsel, NULL);
                                              selected = dsel == *(DOUBLE *)buffer;
                                              break;
                          } /* switch */

                          xywh2rect (x, y, w, h, &frame);

                          if (mfield->type == MT_LCHECKBOX)
                            DrawCheckRadio (out_handle, &frame, &clip, NULL, 0, selected ? SELECTED : NORMAL, bk_color, &fontdesc, FALSE);
                          else
                          {
                            frame.x += strwidth;
                            frame.w -= strwidth;

                            DrawCheckRadio (out_handle, &frame, &clip, NULL, 0, selected ? SELECTED : NORMAL, bk_color, &fontdesc, FALSE);
                          } /* else */
                          break;
    case MT_RADIOBUTTON : if (is_null (TYPE_LONG, &mfield->lower) ||
                              is_null (TYPE_LONG, &mfield->upper)) return;

                          vst_point (out_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);

                          y     += 2 * hbox;
                          index  = 0;
                          buffer = buffer + field_info.addr;
                          p      = (mfield->extra == FAILURE) ?  NULL : &sysmask->mask.buffer [mfield->extra];

                          frame.x = x + gl_wbox;
                          frame.y = y;
                          frame.w = w -  3 * gl_wbox;
                          frame.h = hbox;

                          for (i = mfield->lower; (i <= mfield->upper); i++, index++)
                          {
                             switch (field_info.type)
                             {
                               case TYPE_CHAR : get_rtext (p, s, index);
                                                selected = strncmp (buffer, s, (SIZE_T)field_info.size - 1) == 0;
                                                break;
                               case TYPE_WORD : selected = i == *(WORD *)buffer;
                                                break;
                               case TYPE_LONG : selected = i == *(LONG *)buffer;
                                                break;
                             } /* switch */

                             if (hbox < 13)	/* for compatibility of older masks using a small font */
                               draw_rbutton (out_handle, x + wbox, y, hbox, selected, mfield->color, bk_color);
                             else
                               DrawCheckRadio (out_handle, &frame, &clip, NULL, 0, selected ? SELECTED : NORMAL, bk_color, &fontdesc, TRUE);

                             y       += hbox;
                             frame.y += hbox;
                          } /* for */
                          break;
  } /* switch */
} /* m_draw_field */

/*****************************************************************************/

GLOBAL VOID m_all_fields (MASK_SPEC *mask_spec, BOOLEAN draw_submasks, BOOLEAN bDrawAttributes)
{
  WORD     obj, class, strwidth, edobj, sub, h;
  RECT     frame, r, rc, old_clip;
  FATTR    fattr;
  MFIELD   *mfield;
  MSUBMASK *msubmask;
  MOBJECT  *mobject;
  SUBMASK  *submask;
  SYSMASK  *sysmask;

  hide_mouse ();

  sysmask   = mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  text_default (vdi_handle);
  line_default (vdi_handle);

  vsf_perimeter (vdi_handle, FALSE);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_style (vdi_handle, 0);
  vsf_color (vdi_handle, WHITE);

  for (obj = edobj = sub = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield   = &mobject->mfield;
    msubmask = &mobject->msubmask;
    class    = mfield->class;
    strwidth = m_get_rect (mask_spec, vdi_handle, class, mobject, &frame, &fattr);
    r        = frame;

    if (rc_intersect (&clip, &frame))
    {
      if (class == M_FIELD)
      {
        vst_color (vdi_handle, mfield->color);
        m_draw_field (mask_spec, vdi_handle, mfield, &r, &fattr, strwidth, edobj);
      } /* if */

      if ((class == M_SUBMASK) && draw_submasks)
      {
        old_clip = clip;
        set_clip (TRUE, &frame);
        submask = &mask_spec->Submask [sub];
        vst_color (vdi_handle, msubmask->color);

        if (msubmask->flags & MSM_SHOW_TABLE)
          draw_sm (mask_spec, vdi_handle, mobject, &r, sub);
        else
        {
          m_all_fields (submask->pMaskSpec, FALSE, FALSE);	/* draw only fields, no attributes */

          if (bDrawAttributes)
          {
            rc = m_calc_sm_attr (vdi_handle, submask, &frame, SM_ATTR_RECCOUNT, &h);
            r  = m_calc_sm_attr (vdi_handle, submask, &frame, SM_ATTR_HSLIDER, &h);
            rc_union (&rc, &r);

            redraw_window (mask_spec->window, &r);		/* draw rec count and slider */
          } /* if */
        } /* else */

        set_clip (TRUE, &old_clip);				/* clipping will be destroyed in redraw window */
      } /* if */
    } /* if */

    if (m_is_editable (mobject)) edobj++;
    if (class == M_SUBMASK) sub++;
  } /* for */

  show_mouse ();
} /* m_all_fields */

/*****************************************************************************/

GLOBAL VOID m_all_submasks (MASK_SPEC *mask_spec)
{
  WORD     obj, class, sub, h;
  RECT     frame, r, rc;
  FATTR    fattr;
  MSUBMASK *msubmask;
  MOBJECT  *mobject;
  SUBMASK  *submask;
  SYSMASK  *sysmask;
  WINDOWP  window;

  window = mask_spec->window;

  hide_mouse ();
  set_clip (TRUE, &window->scroll);

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  text_default (vdi_handle);
  line_default (vdi_handle);

  vsf_perimeter (vdi_handle, FALSE);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_style (vdi_handle, 0);
  vsf_color (vdi_handle, WHITE);

  for (obj = sub = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    msubmask = &mobject->msubmask;
    class    = msubmask->class;
    m_get_rect (mask_spec, vdi_handle, class, mobject, &frame, &fattr);
    r = frame;
    set_clip (TRUE, &window->scroll);

    if (rc_intersect (&clip, &frame) && (class == M_SUBMASK))
    {
      set_clip (TRUE, &frame);
      submask = &mask_spec->Submask [sub];
      vst_color (vdi_handle, msubmask->color);

      if (msubmask->flags & MSM_SHOW_TABLE)
        draw_sm (mask_spec, vdi_handle, mobject, &r, sub);
      else
      {
        m_all_fields (submask->pMaskSpec, FALSE, FALSE);	/* draw only fields, no attributes */

        rc = m_calc_sm_attr (vdi_handle, submask, &frame, SM_ATTR_RECCOUNT, &h);
        r  = m_calc_sm_attr (vdi_handle, submask, &frame, SM_ATTR_HSLIDER, &h);
        rc_union (&rc, &r);

        redraw_window (mask_spec->window, &r);			/* draw rec count and slider */
        set_clip (TRUE, &frame);				/* clipping will be destroyed in redraw window */
      } /* else */

      sub++;
    } /* if */
  } /* for */

  show_mouse ();
} /* m_all_submasks */

/*****************************************************************************/

GLOBAL VOID m_clr_submasks (MASK_SPEC *mask_spec)
{
  WORD     obj, class, sub;
  RECT     frame, r;
  FATTR    fattr;
  MSUBMASK *msubmask;
  MOBJECT  *mobject;
  SYSMASK  *sysmask;
  WINDOWP  window;

  window = mask_spec->window;

  hide_mouse ();
  set_clip (TRUE, &window->scroll);

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  text_default (vdi_handle);
  line_default (vdi_handle);

  vsf_perimeter (vdi_handle, FALSE);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_style (vdi_handle, 0);
  vsf_color (vdi_handle, WHITE);

  for (obj = sub = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    msubmask = &mobject->msubmask;
    class    = msubmask->class;
    m_get_rect (mask_spec, vdi_handle, class, mobject, &frame, &fattr);
    r = frame;

    r.x += 1;	/* take only interior of submask (without border) */
    r.y += 1;
    r.w -= 2;
    r.h -= 2;

    if (rc_intersect (&clip, &frame) && (class == M_SUBMASK))
    {
      clr_area (&r);
      sub++;
    } /* if */
  } /* for */

  show_mouse ();
} /* m_clr_submasks */

/*****************************************************************************/

GLOBAL WORD m_sm_init (MASK_SPEC *mask_spec)
{
  BOOLEAN    ok, bWarnTable;
  WORD       obj, sub, err;
  WORD       char_width, char_height, cell_width, cell_height;
  UWORD      style;
  LONGSTR    s;
  SQL_RESULT sql_result;
  BYTE       *sql;
  BYTE       *pSubmaskName;
  MSUBMASK   *msubmask;
  SUBMASK    *submask;
  MOBJECT    *mobject;
  SYSMASK    *sysmask;

  sysmask  = mask_spec->mask;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  ok       = TRUE;
  sub      = 0;
  submask  = mask_spec->Submask;
  sql      = mask_spec->db->buffer;
  err      = SUCCESS;

  for (obj = 0; ok && (obj < mask_spec->objs); obj++, mobject++)
  {
    msubmask = &mobject->msubmask;

    if ((msubmask->class == M_SUBMASK) && (sub < MAX_SUBMASKS))
    {
      if (submask->pMaskSpec != NULL) mu_free (submask->pMaskSpec, TRUE);	/* release old submask */

      err = sm2sql (mask_spec, msubmask, sql);	/* convert submask definition to sql statement */
      ok  = err == SUCCESS;

      if (! ok) continue;

      mem_set (submask, 0, sizeof (SUBMASK));

      bWarnTable = warn_table;
      warn_table = FALSE;

      busy_mouse ();
      sql_exec (mask_spec->db, sql, "", FALSE, &sql_result);
      arrow_mouse ();

      warn_table = bWarnTable;

      if (sql_result.columns != NULL)
      {
        pSubmaskName = &sysmask->mask.buffer [msubmask->SourceObject];

        submask->pMaskSpec = mu_crt_spec (mask_spec->window, mask_spec, mask_spec->db, sql_result.table, sql_result.inx, sql_result.dir, pSubmaskName, NULL, 0L, NULL, FALSE, msubmask->x, msubmask->y, msubmask->flags & MSM_SHOW_MASK);

        ok = submask->pMaskSpec != NULL;

        if (ok)
        {
          mu_get_graf (submask->pMaskSpec);
          submask->pMaskSpec->act_obj = FAILURE;

          text_default (vdi_handle);

          style = SBS_NO3DBORDER;

          if (msubmask->flags & MSM_SHOW_TABLE)
          {
            vst_font (vdi_handle, msubmask->font);
            vst_point (vdi_handle, msubmask->point, &char_width, &char_height, &cell_width, &cell_height);
            vst_effects (vdi_handle, TXT_THICKENED);
            m_text_extent (vdi_handle, "x", FALSE, &cell_width, &cell_height);
            cell_height += ADD_LINES;
            style |= SBS_VERTICAL;
          } /* if */
          else
          {
            cell_width  = gl_wattr;
            cell_height = gl_hattr;
            style |= SBS_HORIZONTAL | SBS_REALTIME;
          } /* else */

          submask->obj      = obj;
          submask->cols     = sql_result.cols;
          submask->columns  = sql_result.columns;
          submask->colwidth = sql_result.colwidth;
          submask->doc.x    = 0;
          submask->doc.y    = 0;
          submask->doc.w    = get_width (submask->cols, submask->colwidth);
          submask->doc.h    = num_keys (mask_spec->db, sql_result.table, sql_result.inx);
          submask->xfac     = cell_width;
          submask->yfac     = cell_height;
          submask->xscroll  = show_left ? submask->xfac / 2 - 1 + ((INT)strlen (ltoa (submask->doc.h, s, 10)) + 1) * submask->xfac : 0;
          submask->yscroll  = show_top ? submask->yfac : 0;
          submask->act_rec  = 0;
          submask->sel_obj  = FAILURE;
          submask->flags    = msubmask->flags;
          submask->hsb      = ScrollBar_Create (style, NULL, submask->doc.h, 1L);

          submask->pMaskSpec->pSubmask = submask;

          ScrollBar_SetSpec (submask->hsb, (LONG)submask);
          ScrollBar_SetCallback (submask->hsb, sb_callback);

          build_colheader (mask_spec->db, sql_result.table, sql_result.cols, sql_result.columns, sql_result.colwidth, LONGSTRLEN, submask->colheader);
        } /* if */

        if (VTBL (sql_result.table)) free_vtable (sql_result.table);
        if (VINX (sql_result.inx)) free_vindex (sql_result.inx);

        sub++;
        submask++;
        mask_spec->num_submasks = sub;

        if (sub == MAX_SUBMASKS)
        {
          sprintf (s, alerts [ERR_SM_2MANY], sysmask->name);
          open_alert (s);
        } /* if */
      } /* if */
    } /* if */
  } /* for */

  return (err);
} /* m_sm_init */

/*****************************************************************************/

GLOBAL WORD m_edit_obj (MASK_SPEC *mask_spec, WORD message, WORD wparam, MKINFO *mk)
{
  WORD       msg;
  RECT       r, pos, old_clip;
  FIELD_INFO field_info;
  EDFIELD    *ed_field;
  MFIELD     *mfield;

  if (mask_spec->act_obj < 0) return (MO_GENERAL);

  ed_field = &mask_spec->ed_field [mask_spec->act_obj];
  mfield   = ed_field->mfield;
  old_clip = clip;

  if (mfield->class == M_SUBMASK) return (MO_CHARNOTUSED);

  r = mask_spec->window->work;
  rc_intersect (&clip, &r);
  set_clip (TRUE, &r);

  if (IS_EDOBJ (mfield))
  {
    if ((ed_field->type == TYPE_PICTURE) && (message == MO_DRAW))
    {
      draw_pic (mask_spec, mask_spec->act_obj);
      return (MO_OK);
    } /* if */

    if ((ed_field->type == TYPE_PICTURE) || IS_BLOB (ed_field->type))
    {
      switch (message)
      {
        case MO_INIT       : message = EO_INIT;       break;
        case MO_EXIT       : message = EO_EXIT;       break;
        case MO_CLEAR      : message = EO_CLEAR;      break;
        case MO_DRAW       : message = EO_DRAW;       break;
        case MO_SHOWCURSOR : message = EO_SHOWCURSOR; break;
        case MO_HIDECURSOR : message = EO_HIDECURSOR; break;
        case MO_KEY        : message = EO_KEY;        break;
        case MO_CLICK      : message = EO_CLICK;      break;
      } /* switch */

      msg = empty_obj (&mask_spec->eo, message, wparam, mk);

      switch (msg)
      {
        case EO_OK            : msg = MO_OK;            break;
        case EO_WRONGMESSAGE  : msg = MO_WRONGMESSAGE;  break;
        case EO_GENERAL       : msg = MO_GENERAL;       break;
        case EO_BUFFERCHANGED : msg = MO_BUFFERCHANGED; break;
        case EO_CHARNOTUSED   : msg = MO_CHARNOTUSED;   break;
      } /* switch */

      if ((message == EO_KEY) && (mk->ascii_code == ESC))       /* clear the picture/blob */
      {
        if (ed_field->type == TYPE_PICTURE) m_exit_pic (mask_spec, ed_field->pic);
        db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);
        set_null (ed_field->type, (BYTE *)mask_spec->buffer + field_info.addr);
        pos = m_get_edrect (mask_spec, mfield, TRUE);
        clr_area (&pos);
        msg = MO_BUFFERCHANGED;
      } /* if */

      return (msg);
    } /* if */

    switch (message)
    {
      case MO_INIT       : message = ED_INIT;       break;
      case MO_EXIT       : message = ED_EXIT;       break;
      case MO_CLEAR      : message = ED_CLEAR;      break;
      case MO_DRAW       : message = ED_DRAW;       break;
      case MO_SHOWCURSOR : message = ED_SHOWCURSOR; break;
      case MO_HIDECURSOR : message = ED_HIDECURSOR; break;
      case MO_KEY        : message = ED_KEY;        break;
      case MO_CLICK      : message = ED_CLICK;      break;
      case MO_CUT        : message = ED_CUT;        break;
      case MO_COPY       : message = ED_COPY;       break;
      case MO_PASTE      : message = ED_PASTE;      break;
    } /* switch */

    msg = edit_obj (&mask_spec->ed, message, wparam, mk);

    switch (msg)
    {
      case ED_OK            : msg = MO_OK;            break;
      case ED_WRONGMESSAGE  : msg = MO_WRONGMESSAGE;  break;
      case ED_GENERAL       : msg = MO_GENERAL;       break;
      case ED_BUFFERCHANGED : msg = MO_BUFFERCHANGED; break;
      case ED_CHARNOTUSED   : msg = MO_CHARNOTUSED;   break;
      case ED_NOMEMORY      : msg = MO_NOMEMORY;      break;
    } /* switch */
  } /* if */

  if (IS_CHECKBOX (mfield))
  {
    switch (message)
    {
      case MO_INIT       : message = CB_INIT;       break;
      case MO_EXIT       : message = CB_EXIT;       break;
      case MO_CLEAR      : message = CB_CLEAR;      break;
      case MO_DRAW       : message = CB_DRAW;       break;
      case MO_SHOWCURSOR : message = CB_SHOWCURSOR; break;
      case MO_HIDECURSOR : message = CB_HIDECURSOR; break;
      case MO_KEY        : message = CB_KEY;        break;
      case MO_CLICK      : message = CB_CLICK;      break;
    } /* switch */

    msg = cb_obj (&mask_spec->cb, message, wparam, mk);

    switch (msg)
    {
      case CB_OK            : msg = MO_OK;            break;
      case CB_WRONGMESSAGE  : msg = MO_WRONGMESSAGE;  break;
      case CB_GENERAL       : msg = MO_GENERAL;       break;
      case CB_BUFFERCHANGED : msg = MO_BUFFERCHANGED; break;
      case CB_CHARNOTUSED   : msg = MO_CHARNOTUSED;   break;
    } /* switch */
  } /* if */

  if (IS_RBUTTON (mfield))
  {
    switch (message)
    {
      case MO_INIT       : message = RB_INIT;       break;
      case MO_EXIT       : message = RB_EXIT;       break;
      case MO_CLEAR      : message = RB_CLEAR;      break;
      case MO_DRAW       : message = RB_DRAW;       break;
      case MO_SHOWCURSOR : message = RB_SHOWCURSOR; break;
      case MO_HIDECURSOR : message = RB_HIDECURSOR; break;
      case MO_KEY        : message = RB_KEY;        break;
      case MO_CLICK      : message = RB_CLICK;      break;
    } /* switch */

    msg = rb_obj (&mask_spec->rb, message, wparam, mk);

    switch (msg)
    {
      case RB_OK            : msg = MO_OK;            break;
      case RB_WRONGMESSAGE  : msg = MO_WRONGMESSAGE;  break;
      case RB_GENERAL       : msg = MO_GENERAL;       break;
      case RB_BUFFERCHANGED : msg = MO_BUFFERCHANGED; break;
      case RB_CHARNOTUSED   : msg = MO_CHARNOTUSED;   break;
    } /* switch */
  } /* if */

  set_clip (TRUE, &old_clip);

  return (msg);
} /* m_edit_obj */

/*****************************************************************************/

GLOBAL WORD m_ed_index (MASK_SPEC *mask_spec, WORD index, WORD direction, MKINFO *mk)
{
  BOOLEAN    selected;
  WORD       wchar, hchar, wbox, hbox;
  WORD       err, old_index, button, bk_color;
  UWORD      flags;
  WORD       wsel;
  LONG       lsel;
  DOUBLE     dsel;
  STRING     ssel;
  LONG       size, i;
  RECT       frame, box;
  FIELD_INFO field_info;
  STRING     s;
  BYTE       *buffer;
  BYTE       *p, *q;
  EDFIELD    *ed_field;
  MFIELD     *mfield;
  SYSMASK    *sysmask;

  sysmask   = mask_spec->mask;
  buffer    = mask_spec->buffer;
  flags     = 0;
  old_index = mask_spec->act_obj;
  ed_field  = &mask_spec->ed_field [index];

  if (index < 0) return (FAILURE);
  if (mask_spec->edobjs == 0) return (FAILURE);

  if (direction > 0)
    while ((index < mask_spec->edobjs) && (ed_field->flags & (COL_OUTPUT | COL_HIDDEN)))
    {
      index++;
      ed_field++;
    } /* while, if */
  else
    while ((index >= 0) && (ed_field->flags & (COL_OUTPUT | COL_HIDDEN)))
    {
      index--;
      ed_field--;
    } /* while */

  if ((index == mask_spec->edobjs) || (index < 0)) index = old_index;
  if (index < 0) index = 0;

  ed_field = &mask_spec->ed_field [index];
  mfield   = ed_field->mfield;
  frame    = m_get_edrect (mask_spec, mfield, FALSE);

  bk_color = is_null (TYPE_LONG, &sysmask->bkcolor) ? WHITE : IndexFromColor32 (sysmask->bkcolor);
  if (colors == 2) bk_color = WHITE;

  mask_spec->act_obj = index;

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  if (IS_CHECKBOX (mfield))
  {
    if (mfield->extra == FAILURE)
      p = NULL;
    else
      p = &sysmask->mask.buffer [mfield->extra];

    box   = frame;
    box.w = 16;

    if (mfield->type == MT_RCHECKBOX) box.x = frame.x + frame.w - box.w;

    buffer   = buffer + field_info.addr;
    selected = FALSE;

    switch (field_info.type)
    {
      case TYPE_CHAR  : get_cbsvals (field_info.size, p, ssel, NULL);
                        selected = strncmp (buffer, ssel, (SIZE_T)field_info.size - 1) == 0;
                        break;
      case TYPE_WORD  : get_cbwvals (field_info.size, p, &wsel, NULL);
                        selected = wsel == *(WORD *)buffer;
                        break;
      case TYPE_LONG  : get_cblvals (field_info.size, p, &lsel, NULL);
                        selected = lsel == *(LONG *)buffer;
                        break;
      case TYPE_FLOAT : get_cbfvals (field_info.size, p, &dsel, NULL);
                        selected = dsel == *(DOUBLE *)buffer;
                        break;
    } /* switch */

    mask_spec->cb.window   = mask_spec->window;
    mask_spec->cb.text     = frame;
    mask_spec->cb.box      = box;
    mask_spec->cb.color    = mfield->color;
    mask_spec->cb.bk_color = bk_color;
    mask_spec->cb.flags    = (ed_field->flags & COL_OUTPUT) ? CB_OUTPUT : 0;

    err = m_edit_obj (mask_spec, MO_INIT, selected, mk);
  } /* if */

  if (IS_RBUTTON (mfield))
  {
    vst_font (vdi_handle, mfield->font);
    vst_point (vdi_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);

    buffer = buffer + field_info.addr;
    button = FAILURE;
    index  = 0;

    if (mfield->extra == FAILURE)
      p = NULL;
    else
      p = &sysmask->mask.buffer [mfield->extra];

    box.x = frame.x + gl_wbox;
    box.y = frame.y + 2 * hbox;
    box.w = frame.w - 3 * gl_wbox;
    box.h = hbox;

    switch (field_info.type)
    {
      case TYPE_CHAR : for (i = mfield->lower; (button == FAILURE) && (i <= mfield->upper); i++, index++)
                       {
                         get_rtext (p, s, index);
                         if (strncmp (buffer, s, (SIZE_T)field_info.size - 1) == 0) button = i - mfield->lower;
                       } /* for */
                       break;
      case TYPE_WORD : button = *(WORD *)buffer - (WORD)mfield->lower;
                       break;
      case TYPE_LONG : button = *(LONG *)buffer - (LONG)mfield->lower;
                       break;
    } /* switch */

    mask_spec->rb.window   = mask_spec->window;
    mask_spec->rb.pos      = box;
    mask_spec->rb.selected = button;
    mask_spec->rb.buttons  = mfield->upper - mfield->lower + 1;
    mask_spec->rb.color    = mfield->color;
    mask_spec->rb.bk_color = bk_color;
    mask_spec->rb.flags    = (ed_field->flags & COL_OUTPUT) ? RB_OUTPUT : 0;

    err = m_edit_obj (mask_spec, MO_INIT, 0, mk);
  } /* if */

  if (IS_EDOBJ (mfield))
  {
    if ((ed_field->type == TYPE_PICTURE) || IS_BLOB (ed_field->type))
    {
      frame.x -= EDIT_FRAME;
      frame.y -= EDIT_FRAME;
      frame.w += 2 * EDIT_FRAME;
      frame.h += 2 * EDIT_FRAME;

      mask_spec->eo.window  = mask_spec->window;
      mask_spec->eo.pos     = frame;
      return (m_edit_obj (mask_spec, MO_INIT, 0, mk));
    } /* if */

    if (HASWILD (field_info.type))
    {
      size = field_info.size - 1;       /* leave space for EOS char */

      if ((field_info.format != field_info.type) && (field_info.size <= LONGSTRLEN))
      {
        p = mask_spec->text;
        col2str (mask_spec->db, ed_field->table, buffer, ed_field->field, 0, p);
      } /* if */
      else
        p = buffer + field_info.addr;

      flags = ED_ALILEFT | ED_USEPOS;

      if (size > mfield->w) flags |= ED_AUTOHSCROLL;
      if (mfield->h > 1) flags |= ED_AUTOVSCROLL | ED_CRACCEPT;
      if (mfield->flags & MF_WORDBREAK) flags |= ED_WORDBREAK;
    } /* if */
    else
    {
      p     = mask_spec->text;
      *p    = EOS;
      size  = min (mfield->w, LONGSTRLEN);
      flags = ED_ALIRIGHT;

      if (! is_null (field_info.type, buffer + field_info.addr))
      {
        col2str (mask_spec->db, ed_field->table, buffer, ed_field->field, -mfield->w, p);

        if (*p != EOS)
        {
          q = p + strlen (p) - 1;
          while (*q == ' ') q--;
          q++;
          *q = EOS;
        } /* if */
      } /* if */
    } /* else */

    if ((mfield->type == MT_OUTLINED) ||
        (mfield->type == MT_POPUP)) flags |= ED_LINEONLAST;

    if (ed_field->flags & COL_OUTPUT) flags |= ED_OUTPUT;

    if ((ed_field->type == TYPE_WORD) ||
        (ed_field->type == TYPE_LONG) ||
        (ed_field->type == TYPE_FLOAT)) flags |= ED_NUMERIC;

    mask_spec->ed.window  = mask_spec->window;
    mask_spec->ed.pos     = frame;
    mask_spec->ed.text    = p;
    mask_spec->ed.bufsize = size;
    mask_spec->ed.actsize = strlen (p);
    mask_spec->ed.font    = mfield->font;
    mask_spec->ed.point   = mfield->point;
    mask_spec->ed.color   = mfield->color;
    mask_spec->ed.flags   = flags;

    err = m_edit_obj (mask_spec, MO_INIT, 0, mk);
  } /* if */

  return (err);
} /* m_ed_index */

/*****************************************************************************/

GLOBAL WORD m_ed_next (MASK_SPEC *mask_spec, WORD index, WORD direction)
{
  WORD    old_index;
  EDFIELD *ed_field;

  old_index = mask_spec->act_obj;
  ed_field  = &mask_spec->ed_field [index];

  if (index < 0) return (FAILURE);
  if (mask_spec->edobjs == 0) return (FAILURE);


  if (direction > 0)
    while ( (ed_field->flags & (COL_OUTPUT | COL_HIDDEN)) )
    {
      if ( index == old_index )	break;

      index++;
      ed_field++;

      if ( index == mask_spec->edobjs )
      {
      	index = 0;
			  ed_field  = &mask_spec->ed_field [index];
      }	/* if */
    } /* while, if */
  else
    while ( (ed_field->flags & (COL_OUTPUT | COL_HIDDEN)) )
    {
      if ( index == old_index )	break;

      index--;
      ed_field--;
      if ( index < 0 )
      {
      	index = mask_spec->edobjs - 1;
			  ed_field  = &mask_spec->ed_field [index];
      }	/* if */

    } /* while */

  if ((index == mask_spec->edobjs) || (index < 0)) index = old_index;
  if (index < 0) index = 0;

  return (index);
} /* m_ed_next */

/*****************************************************************************/

GLOBAL VOID m_edopen (MASK_SPEC *mask_spec)
{
  EXT        szExt;
  FULLNAME   szPath;
  FULLNAME   szFilename;
  FIELD_INFO field_info;
  PICOBJ     *picobj;
  BYTE       *buffer;
  EDFIELD    *ed_field;

  ed_field = &mask_spec->ed_field [mask_spec->act_obj];
  buffer   = mask_spec->buffer;

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  buffer += field_info.addr;

	if ( field_info.type != TYPE_CHAR )
	{
  	if (is_null (field_info.type, buffer)) return;
  } /* if */

  switch (field_info.type)
  {
    case TYPE_CHAR    :
    case TYPE_PICTURE : if (ed_field->szFilename [0] == EOS) temp_name (ed_field->szFilename);	/* create temp file for communication with OLGA server */

                        file_split (ed_field->szFilename, NULL, szPath, szFilename, szExt);	/* delete .TMP */
                        if (field_info.type == TYPE_CHAR)
                        {
                          strcpy (szExt, ".TXT");
                          sprintf (ed_field->szFilename, "%s%s%s", szPath, szFilename, szExt);
                          mu_textexp (mask_spec, ed_field->szFilename);
                        } /* if */
                        else
                        {
                          picobj = &mask_spec->dpicobj [ed_field->pic];
                          switch (picobj->type)
                          {
                            case PIC_META  : strcpy (szExt, FREETXT (FGEMSUFF) + 1); break;
                            case PIC_IMAGE : strcpy (szExt, FREETXT (FIMGSUFF) + 1); break;
                            case PIC_IFF   : strcpy (szExt, FREETXT (FIFFSUFF) + 1); break;
                            case PIC_TIFF  : strcpy (szExt, FREETXT (FTIFSUFF) + 1); break;
                          } /* switch */

                          sprintf (ed_field->szFilename, "%s%s%s", szPath, szFilename, szExt);
                          mu_grafexp (mask_spec, ed_field->szFilename);
                        } /* else */

                        str_upper (ed_field->szFilename);
                        str_upper (szExt);
                        OlgaLink (ed_field->szFilename, mask_spec->act_obj);
                        OlgaStartExt (szExt, ed_field->szFilename);
                        break;
    case TYPE_EXTERN  : show_extern (buffer);        break;
    case TYPE_VARBYTE :
    case TYPE_VARWORD :
    case TYPE_VARLONG : play_sound (buffer, FALSE);  break;
  } /* switch */
} /* m_edopen */

/*****************************************************************************/

GLOBAL BOOL m_ed2field (MASK_SPEC *mask_spec, WORD index, BOOLEAN draw)
{
  BOOLEAN    convert, unstructured;
  WORD       strwidth;
  RECT       r;
  FATTR      fattr;
  LONGSTR    s;
  FIELD_INFO field_info;
  BYTE       *buffer, *p;
  RBOBJ      *rb;
  EDFIELD    *ed_field;
  MFIELD     *mfield;
  SYSMASK    *sysmask;

  sysmask = mask_spec->mask;

  if (mask_spec->edobjs == 0) return (FALSE);
  if (index < 0) return (FALSE);

  ed_field = &mask_spec->ed_field [index];
  mfield   = ed_field->mfield;
  buffer   = mask_spec->buffer;

  if (mfield->class == M_SUBMASK) return (TRUE);

  db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

  convert = ! HASWILD (field_info.type) || IS_CHECKBOX (mfield) || IS_RBUTTON (mfield);

  if ((field_info.format != field_info.type) && (field_info.size <= LONGSTRLEN))
    convert = TRUE;

  if (convert)
  {
    unstructured = (ed_field->type == TYPE_PICTURE) || IS_BLOB (ed_field->type);

    if (unstructured)
      convert = FALSE;
    else
      if (IS_EDOBJ (mfield))
      {
        strcpy (s, mask_spec->text);
        str2col (mask_spec->db, ed_field->table, buffer, ed_field->field, s);
      } /* if */

    buffer += field_info.addr;

    if (IS_CHECKBOX (mfield))
    {
      set_null (field_info.type, buffer);
      p = (mfield->extra == FAILURE) ? NULL : &sysmask->mask.buffer [mfield->extra];
      get_cbvals (field_info.size, field_info.type, p, mask_spec->cb.selected, buffer);
    } /* if */

    if (IS_RBUTTON (mfield))
    {
      rb = &mask_spec->rb;
      set_null (field_info.type, buffer);

      if (mfield->extra == FAILURE)
        p = NULL;
      else
        p = &sysmask->mask.buffer [mfield->extra];

      if (rb->selected >= 0)
        switch (field_info.type)
        {
          case TYPE_CHAR : get_rtext (p, s, rb->selected);
                           s [field_info.size - 1] = EOS;
                           strcpy (buffer, s);
                           break;
          case TYPE_WORD : *(WORD *)buffer = rb->selected + (WORD)mfield->lower;
                           break;
          case TYPE_LONG : *(LONG *)buffer = rb->selected + (LONG)mfield->lower;
                           break;
        } /* switch, if */
    } /* if */
  } /* if */

  buffer = mask_spec->buffer;

  m_test_null (mask_spec->db->base, ed_field->table, ed_field->field, mask_spec->buffer, FALSE);

  if (mfield->flags & MF_USEBOUNDS)
    test_bounds (mask_spec->db->base, ed_field->table, ed_field->field, mask_spec->buffer, FALSE, mfield->lower, mfield->upper);
  
  if (IS_EDOBJ (mfield) &&
     ((mask_spec->ed.doc.x > 0) ||
      (mask_spec->ed.doc.y > 0)))
  {
    convert = TRUE;
    mask_spec->ed.doc.x = mask_spec->ed.doc.y = 0;
  } /* if */

  if (draw && convert)
  {
    strwidth = m_get_rect (mask_spec, vdi_handle, mfield->class, (MOBJECT *)mfield, &r, &fattr);
    m_draw_field (mask_spec, vdi_handle, mfield, &r, &fattr, strwidth, index);
  } /* if */

  return (TRUE);
} /* m_ed2field */

/*****************************************************************************/

GLOBAL WORD m_name2picobj (MASK_SPEC *mask_spec, BYTE *filename)
{
  WORD   i;
  PICOBJ *picobj;

  picobj = mask_spec->spicobj;

  for (i = 0; i < mask_spec->spicobjs; i++, picobj++)
    if (strcmp (filename, picobj->filename) == 0) return (i);

  return (FAILURE);
} /* m_name2picobj */

/*****************************************************************************/

GLOBAL VOID m_obj2pos (MASK_SPEC *mask_spec, WORD obj, RECT *r)
{
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  mobject = &mobject [obj];
  mfield  = &mobject->mfield;

  r->x = (LONG)mfield->x * gl_wbox / M_XUNITS;
  r->y = (LONG)mfield->y * gl_hbox / M_YUNITS;

  if (mfield->class != M_FIELD)
  {
    r->w = (LONG)mfield->w * gl_wbox / M_XUNITS;
    r->h = (LONG)mfield->h * gl_hbox / M_YUNITS;
  } /* if */
} /* m_obj2pos */

/*****************************************************************************/

GLOBAL VOID m_pos2obj (MASK_SPEC *mask_spec, WORD obj, RECT *r)
{
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  mobject = &mobject [obj];
  mfield  = &mobject->mfield;

  mfield->x = (LONG)r->x * M_XUNITS / gl_wbox;
  mfield->y = (LONG)r->y * M_YUNITS / gl_hbox;

  if (mfield->class != M_FIELD)
  {
    mfield->w = (LONG)r->w * M_XUNITS / gl_wbox;
    mfield->h = (LONG)r->h * M_YUNITS / gl_hbox;
  } /* if */
} /* m_pos2obj */

/*****************************************************************************/

GLOBAL VOID m_exit_pic (MASK_SPEC *mask_spec, WORD pic)
{
  WORD   i, pics;
  PICOBJ *picobj;

  if (pic == FAILURE)
  {
    pic  = 0;
    pics = mask_spec->dpicobjs;
  } /* if */
  else
    pics = pic + 1;

  picobj = &mask_spec->dpicobj [pic];

  for (i = pic; i < pics; i++, picobj++)
    if (! (picobj->flags & PIC_INVALID))
    {
      switch (picobj->type)
      {
        case PIC_META  : gem_obj (&picobj->pic.gem, GEM_EXIT, 0, NULL);   break;
        case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_EXIT, 0, NULL); break;
        case PIC_IFF   :                                                  break;
        case PIC_TIFF  :                                                  break;
      } /* switch */

      picobj->flags |= PIC_INVALID;
    } /* if, for */
} /* m_exit_pic */

/*****************************************************************************/

GLOBAL VOID m_exit_rec (MASK_SPEC *mask_spec, WORD null_mode, BOOLEAN rec_unlock, BOOLEAN test_checkboxes)
{
  WORD       obj;
  FIELD_INFO field_info;
  BYTE       *bufp, *p;
  MFIELD     *mfield;
  EDFIELD    *ed_field;
  SYSMASK    *sysmask;

  if (! is_null (TYPE_DBADDRESS, mask_spec->buffer) && mask_spec->modify && rec_unlock)
  {
    db_recunlock (mask_spec->db->base, DB_ADR (mask_spec->buffer));
    dbtest (mask_spec->db);
  } /* if */

  switch (null_mode)
  {
    case M_SET_NOTNULL : break;
    case M_SET_NULL    : db_fillnull (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer);
                         break;
    case M_USE_MFFLAG  : set_null (TYPE_DBADDRESS, mask_spec->buffer);


                         ed_field = mask_spec->ed_field;
                         bufp     = mask_spec->buffer;

                         for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
                         {
                           if (ed_field->mfield->class == M_SUBMASK) continue;

                           db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);
                           if (! (ed_field->mfield->flags & MF_NOCLEAR)) set_null (field_info.type, bufp + field_info.addr);
                         } /* for */
                         break;
  } /* switch */

  sysmask  = mask_spec->mask;
  ed_field = mask_spec->ed_field;
  bufp     = mask_spec->buffer;

  for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
  {
    mfield = ed_field->mfield;
    if (mfield->class == M_SUBMASK) continue;

    if (ed_field->szFilename [0] != EOS)
    {
      OlgaUnlink (ed_field->szFilename, obj);
      file_remove (ed_field->szFilename);
      ed_field->szFilename [0] = EOS;
    } /* if */

    if (IS_CHECKBOX (mfield))
    {
      db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);
      bufp  = mask_spec->buffer;
      bufp += field_info.addr;
      if (is_null (field_info.type, bufp))
      {
        p = (mfield->extra == FAILURE) ? NULL : &sysmask->mask.buffer [mfield->extra];
        get_cbvals (field_info.size, field_info.type, p, FALSE, bufp);
      } /* if */
    } /* if */
  } /* for */
} /* m_exit_rec */

/*****************************************************************************/

GLOBAL BOOL m_save_rec (MASK_SPEC *mask_spec, WORD *edobj, BOOLEAN ask)
{
  BOOLEAN   ok;
  WORD      status, button, obj, err;
  MASK_SPEC *sub_spec;

  sub_spec = m_get_mask_spec (mask_spec);

  if (mask_spec->any_dirty)
  {
    button = ask ? hndl_alert (ERR_MODIFIED) : 1;	/* default YES */

    if (button == 3) return (FALSE);    /* CANCEL */

    if (button == 1)                    /* YES */
    {
      m_ed2field (sub_spec, sub_spec->act_obj, FALSE);

      obj = ins_lookup (mask_spec);
      if (obj != NIL)
      {
        *edobj = obj;
        m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
        m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
        m_ed_index (sub_spec, obj, 1, NULL);
        m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);

        return (FALSE);
      } /* if */

      if (mask_spec->pCalcExit != NULL)
      {
        err = v_execute (mask_spec->db, mask_spec->table, mask_spec->pCalcExit, mask_spec->buffer, 0L, NULL);
        if (err != SUCCESS)
        {
          hndl_alert (err);

          return (FALSE);
        } /* if */
      } /* if */
 
      if (is_null (TYPE_DBADDRESS, mask_spec->buffer))
        ok = db_insert (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer, &status);
      else
        ok = db_update (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer, &status);

      db_reclock (mask_spec->db->base, DB_ADR (mask_spec->buffer));

      if (ok)
        updt_lsall (mask_spec->db, mask_spec->table, FALSE, TRUE);
      else
      {
        obj = test_rec (mask_spec, status);
        if (obj != FAILURE) *edobj = obj;

        return (FALSE);
      } /* else */

      m_setdirty (mask_spec, FALSE);
    } /* if */
  } /* if */

  return (TRUE);
} /* m_save_rec */

/*****************************************************************************/

GLOBAL BOOL m_save_all (MASK_SPEC *mask_spec, WORD *edobj)
{
  BOOLEAN ok;
  WORD    i;
  SUBMASK *submask;

  ok = m_save_rec (mask_spec, edobj, TRUE);			/* save root mask */

  if (! ok) return (FALSE);

  submask = mask_spec->Submask;

  for (i = 0; i < mask_spec->num_submasks; i++, submask++)
    if (submask->flags & MSM_SHOW_MASK)
      m_save_rec (submask->pMaskSpec, edobj, FALSE);		/* save submask */

  return (TRUE);
} /* m_save_all */

/*****************************************************************************/

GLOBAL VOID m_setdirty (MASK_SPEC *mask_spec, BOOLEAN dirty)
{
  WORD    i;
  WINDOWP window;
  SUBMASK *submask;

  mask_spec->buf_dirty = dirty;
  mask_spec->any_dirty = dirty;

  window    = mask_spec->window;
  mask_spec = (MASK_SPEC *)window->special;

  if (mask_spec->num_submasks > 0)				/* check submasks */
  {
    submask = mask_spec->Submask;
    dirty   = mask_spec->buf_dirty;

    for (i = 0; i < mask_spec->num_submasks; i++, submask++)	/* set dirty flag if at least one submask contains dirty data */
      if (submask->pMaskSpec->buf_dirty) dirty = TRUE;

    mask_spec->any_dirty = dirty;
  } /* if */

  if (dirty != mask_spec->asterisk)
  {
    mask_spec->asterisk = dirty;
    m_winame (mask_spec);
  } /* if */
} /* m_setdirty */

/*****************************************************************************/

GLOBAL VOID m_change_buffer (MASK_SPEC *mask_spec)
{
  WORD       act_obj;
  WINDOWP    window;
  MASK_SPEC  *sub_spec;
  MASK_SPEC  *root_spec;

  window    = mask_spec->window;
  root_spec = (MASK_SPEC *)window->special;
  sub_spec  = m_get_mask_spec (mask_spec);

  act_obj = sub_spec->act_obj;
  m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
  m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
  m_exit_pic (mask_spec, FAILURE);
  sub_spec->act_obj = FAILURE;

  set_clip (TRUE, &window->scroll);

  if (mask_spec->pParentSpec == NULL) m_sm_init (root_spec);
  m_ed_index (sub_spec, act_obj, 1, NULL);
  m_all_fields (mask_spec, TRUE, TRUE);
  m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
} /* m_change_buffer */

/*****************************************************************************/

GLOBAL BOOL m_vread (MASK_SPEC *mask_spec, WORD vtable, VOID *buffer, CURSOR *cursor, LONG address, BOOLEAN modify)
{
  BOOLEAN ok;
  WORD    result;

  mask_spec->modify = modify;

  ok     = v_read (mask_spec->db, vtable, buffer, cursor, address, modify);
  result = db_status (mask_spec->db->base);

  if (result == DB_CDELETED) mask_spec->modify = FALSE;

  if (! ok && modify && (result == DB_CLOCK_ERR))       /* try again */
  {
    ok = v_read (mask_spec->db, vtable, buffer, cursor, address, FALSE);
    mask_spec->modify = FALSE;
  } /* if */

  return (ok);
} /* m_vread */

/*****************************************************************************/

GLOBAL VOID m_draw_cr (WORD out_handle, WORD x, WORD y, WORD hbox, BOOLEAN selected, WORD color, WORD bk_color, BOOLEAN checkbox)
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
} /* m_draw_cr */

/*****************************************************************************/

GLOBAL VOID m_winame (MASK_SPEC *mask_spec)
{
/* [GS] 5.1e Start */
	LONGSTR s;
/* alt:
  STRING  s;
 Ende */
  WINDOWP window;

  window    = mask_spec->window;
  mask_spec = (MASK_SPEC *)window->special;	/* get root mask spec */

  dbtbl_name (mask_spec->db, mask_spec->table, s);

/* [GS] 5.1e Start */
	strcat ( s, "[" );
	strcat ( s, mask_spec->maskname );
	strcat ( s, "]" );
/* Ende */
	
  if (mask_spec->any_dirty)
    strcpy (window->name, " *");
  else
    strcpy (window->name, " ");

  strcat (window->name, s + 1); /* don't use first blank from s */
  wind_set (window->handle, WF_NAME, ADR (window->name), 0, 0);
} /* m_winame */

/*****************************************************************************/

GLOBAL BOOL m_test_null (BASE *base, WORD table, WORD field, VOID *buffer, BOOLEAN show_error)
{
  BOOLEAN    ok;
  STRING     name;
  LONGSTR    s;
  FIELD_INFO field_info;

  db_fieldinfo (base, table, field, &field_info);

  ok = TRUE;

  if (is_null (field_info.type, (BYTE *)buffer + field_info.addr))
  {
    if (field_info.flags & COL_DEFAULT)
      set_default (field_info.type, (BYTE *)buffer + field_info.addr);
    else
      if (field_info.flags & COL_MANDATORY) ok = FALSE;

      if (! ok && show_error)
      {
        sprintf (name, FREETXT (FDATABAS), base->basename);
        sprintf (s, alerts [ERR_COLNULL], name, field_info.name);
        open_alert (s);
      } /* if */
  } /* if */

  return (ok);
} /* m_test_null */

/*****************************************************************************/

GLOBAL VOID m_print (MASK_SPEC *mask_spec)
{
  TABLENAME name;

  table_name (mask_spec->db, mask_spec->table, name);
  button_account (mask_spec, name, DEV_PRINTER);
} /* m_print */

/*****************************************************************************/

GLOBAL VOID m_search_full (MASK_SPEC *mask_spec, BOOLEAN cont)
{
  BOOLEAN    found, ready, asc, null;
  WORD       menu_height;
  WORD       field, selected, obj, edobj;
  LONG       count;
  STRING     s, col;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *p;
  EDFIELD    *ed_field;
  WINDOWP    window;

  window = mask_spec->window;

  get_ptext (listsrch, LISEARCH, s);

  if ((s [0] == EOS) || ! get_checkbox (listsrch, LITEXT))	/* no search criterion or no full text search: continue searching not allowed */
    cont = FALSE;

  selected = FAILURE;

  if (cont || search_dialog (mask_spec->db, mask_spec->table, FAILURE))	/* FAILURE means full text search without index */
  {
    get_ptext (listsrch, LISEARCH, s);

    if (get_checkbox (listsrch, LITEXT))		/* full text search */
    {
      if (! m_save_all (mask_spec, &edobj)) return;
      if (sel_window == window) unclick_window (window);

      v_tableinfo (mask_spec->db, mask_spec->table, &table_info);

      if (table_info.recs == 0)
      {
        db_fillnull (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer);
        return;
      } /* if */

      null = is_null (TYPE_DBADDRESS, mask_spec->buffer);
      obj  = mask_spec->act_obj;

      m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);
      m_ed2field (mask_spec, mask_spec->act_obj, TRUE);
      m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
      m_exit_pic (mask_spec, FAILURE);
      m_exit_rec (mask_spec, M_SET_NOTNULL, TRUE, FALSE);
      mask_spec->act_obj = FAILURE;

      busy_mouse ();

      asc = get_rbutton (listsrch, LIASC) == LIASC;

      m_setdirty (mask_spec, FALSE);

      if (! cont) v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir * (asc ? 1 : -1), mask_spec->cursor);

      found = FALSE;
      ready = FALSE;
      count = 0;

      v_tableinfo (mask_spec->db, mask_spec->table, &table_info);

      while (! ready && ! found)
      {
        ready = ! v_movecursor (mask_spec->db, mask_spec->cursor, asc ? mask_spec->dir : - mask_spec->dir);
        count++;

        if (! ready)
          if (count % 100 == 0)
            if (esc_pressed ())
              ready = TRUE;

        if (! ready)
          ready = ! v_read (mask_spec->db, mask_spec->table, mask_spec->db->buffer, mask_spec->cursor, 0L, FALSE);

        if (selected != FAILURE)				/* skip first try */
          selected = FAILURE;
        else
          if (! ready)
            for (field = 1; (field < table_info.cols) && ! found; field++)	/* don't take field "DbAddress" */
            {
              get_ptext (listsrch, LISEARCH, s);
              db_fieldinfo (mask_spec->db->base, rtable (mask_spec->table), field, &field_info);

              if (HASWILD (field_info.type))
                p = (BYTE *)mask_spec->db->buffer + field_info.addr;
              else
              {
                if (mask_spec->db->format != NULL)
                  if ((field_info.type == TYPE_DATE) || (field_info.type == TYPE_TIME) || (field_info.type == TYPE_TIMESTAMP))
                    if (! format2str (field_info.type, s, mask_spec->db->format [field_info.format]))
                      get_ptext (listsrch, LISEARCH, s);

                p = col;
                bin2str (field_info.type, (BYTE *)mask_spec->db->buffer + field_info.addr, col);
              } /* else */

              if (HASWILD (field_info.type))
                if (! get_checkbox (listsrch, LICASE))
                {
                  str_upper (s);
                  str_upper (p);
                } /* if, if */

              if (str_match (s, p) == 0)
                found = TRUE;
            } /* for, if, else */
      } /* while */

      menu_height                 = (window->menu != NULL) ? gl_hattr : 0;
      maskicon->ob_x              = window->work.x;
      maskicon->ob_y              = window->work.y + menu_height;
      maskicon [MIORDER].ob_width = window->work.w - 2 * gl_wbox + 2;

      m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);

      if (! found)
      {
        set_rbutton (listsrch, asc ? LIDESC : LIASC, LIASC, LIDESC);
        upd_iconbar (mask_spec, FAILURE, obj, null);
        set_redraw (window, &window->scroll);	/* show new mask, redraw will be done immediately on following hndl_alert or dbtest */

        if (db_status (mask_spec->db->base) == SUCCESS)
          hndl_alert (ERR_DBSEARCH);
        else
          dbtest (mask_spec->db);
      } /* if */
      else
      {
        field--;
        ed_field = mask_spec->ed_field;

        for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
          if ((ed_field->table == rtable (mask_spec->table)) && (ed_field->field == field)) break;

        if (obj == mask_spec->edobjs) obj = 0;	/* field not in mask, take edit object #0 */
        upd_iconbar (mask_spec, FAILURE, obj, null);

        m_sm_init (mask_spec);
        m_all_fields (mask_spec, TRUE, TRUE);
      } /* else */

      m_setdirty (mask_spec, FALSE);
      m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);

      arrow_mouse ();
    } /* if */
  } /* if */
} /* m_search_full */

/*****************************************************************************/

GLOBAL VOID m_text_extent (WORD vdi_handle, BYTE *text, BOOLEAN incl_effects, WORD *width, WORD *height)
{
  WORD minimum, maximum, w;
  WORD extent [8], distances [5], effects [3];

  vqt_extent (vdi_handle, text, extent);
  vqt_font_info (vdi_handle, &minimum, &maximum, distances, &w, effects);

  if (width != NULL)
    *width  = extent [2] - extent [0] + (incl_effects ? effects [2] : 0);

  if (height != NULL)
    *height = extent [5] - extent [3];
} /* m_text_extent */

/*****************************************************************************/

GLOBAL RECT m_calc_sm_attr (WORD vdi_handle, SUBMASK *submask, RECT *frame, WORD attr, WORD *h)
{
  WORD   w, ret;
  RECT   rc;
  STRING s;

  if (attr == SM_ATTR_VSLIDER)
  {
    rc    = *frame;
    rc.x += rc.w - (submask->yfac + 3) + 2;	/* put scrollbar at right edge */
    rc.y -= 2;
    rc.w  = submask->yfac + 3;
    rc.h += 4;
  } /* if */

  if ((attr == SM_ATTR_RECCOUNT) || (attr == SM_ATTR_HSLIDER))
  {
    sprintf (s, " %ld/%ld ", submask->doc.h, submask->doc.h);	/* take maximum width for calculating */

    text_default (vdi_handle);
    vst_font (vdi_handle, font_btntext);
    vst_point (vdi_handle, point_btntext, &ret, &ret, &ret, &ret);
    vst_effects (vdi_handle, effects_btntext);
    vst_color (vdi_handle, sys_colors [COLOR_BTNTEXT]);
    vst_alignment (vdi_handle, ALI_CENTER, ALI_TOP, &ret, &ret);
    m_text_extent (vdi_handle, s, TRUE, &w, h);
    w += 2;					/* leave at least 1 pixel at left and right edge of text */

    if (attr == SM_ATTR_RECCOUNT)
    {
      rc    = *frame;
      rc.x -= 1;				/* put actual record number at bottom of submask */
      rc.y += rc.h - submask->yfac + 1;
      rc.w  = w;
      rc.h  = submask->yfac;
    } /* if */

    if (attr == SM_ATTR_HSLIDER)
    {
      rc    = *frame;
      rc.x -= 3 - w;				/* put scrollbar at bottom of submask */
      rc.y += rc.h - submask->yfac;
      rc.w += 5 - w;
      rc.h  = submask->yfac + 2;
    } /* if */
  } /* if */

  return (rc);
} /* m_calc_sm_attr */

/*****************************************************************************/

GLOBAL BOOLEAN m_is_editable (MOBJECT *mobject)
{
  MFIELD   *mfield;
  MSUBMASK *msubmask;

  mfield   = &mobject->mfield;
  msubmask = &mobject->msubmask;

  if (mfield->class == M_FIELD) return (TRUE);

  if (mfield->class == M_SUBMASK)
    if (msubmask->flags & MSM_SHOW_MASK) return (TRUE);	/* submasks as mask can be edited */

  return (FALSE);
} /* m_is_editable */

/*****************************************************************************/

GLOBAL VOID mGetPicFilename (MASK_SPEC *mask_spec, BYTE *pPicFilename, BYTE *pFilename)
{
  FILENAME szName;

  strcpy (pPicFilename, pFilename);
  str_upper (pPicFilename);

  if (! file_exist (pPicFilename))	/* search on basepath */
  {
    file_split (pPicFilename, NULL, NULL, szName, NULL);
    strcpy (pPicFilename, mask_spec->db->base->basepath);
    strcat (pPicFilename, szName);

    if (! file_exist (pPicFilename))	/* should never happen */
    {
      file_error (ERR_FILEOPEN, pPicFilename);
      return;
    } /* if */;
  } /* if */
} /* mGetPicFilename */

/*****************************************************************************/

LOCAL VOID upd_iconbar (MASK_SPEC *mask_spec, WORD obj, WORD act_obj, BOOLEAN null)
{
  BOOLEAN top, invalid;
  RECT    r;
  WINDOWP window;

  window = mask_spec->window;
  r      = clip;

  set_clip (TRUE, &window->work);

  top     = find_top () == window;	/* help window could be top */
  invalid = (mask_spec->dir == ASCENDING) ? v_isfirst (mask_spec->db, mask_spec->cursor) : v_islast (mask_spec->db, mask_spec->cursor);

  if (invalid == ! is_state (maskicon, MIPREV, DISABLED))
  {
    flip_state (maskicon, MIFIRST, DISABLED);
    flip_state (maskicon, MIPREV,  DISABLED);
    if (top)
    {
      if (mask_spec->sm_flags & SM_SHOW_ICONS)
      {
        objc_draw (maskicon, MIFIRST, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
        objc_draw (maskicon, MIPREV,  MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
      } /* if */
    } /* if */
    else
    {
      set_mredraw (mask_spec, MIFIRST);
      set_mredraw (mask_spec, MIPREV);
    } /* else */
  } /* if */

  invalid = (mask_spec->dir == DESCENDING) ? v_isfirst (mask_spec->db, mask_spec->cursor) : v_islast (mask_spec->db, mask_spec->cursor);
  if (invalid == ! is_state (maskicon, MINEXT, DISABLED))
  {
    flip_state (maskicon, MINEXT, DISABLED);
    flip_state (maskicon, MILAST, DISABLED);
    if (top)
    {
      if (mask_spec->sm_flags & SM_SHOW_ICONS)
      {
        objc_draw (maskicon, MINEXT, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
        objc_draw (maskicon, MILAST, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
      } /* if */
    } /* if */
    else
    {
      set_mredraw (mask_spec, MINEXT);
      set_mredraw (mask_spec, MILAST);
    } /* else */
  } /* if */

  if (obj == MISEARCH)	/* index could have been changed */
  {
    mfix_iconbar (window);
    if (mask_spec->sm_flags & SM_SHOW_ICONS) draw_win_obj (window, maskicon, MIINDEX);
  } /* if */

  if (obj != FAILURE)
  {
    undo_state (maskicon, obj, SELECTED);

    if (top)
      if (mask_spec->sm_flags & SM_SHOW_ICONS)
        objc_draw (maskicon, obj, MAX_DEPTH, clip.x, clip.y, clip.w, clip.h);
      else
        set_mredraw (mask_spec, obj);
  } /* if */

  if (null != is_null (TYPE_DBADDRESS, mask_spec->buffer))  /* show new delete button */
    set_mredraw (mask_spec, MIDELETE);

  if (act_obj >= 0)   /* set cursor to actual field in new buffer */
  {
    if (top)
      r = window->scroll;
    else
    {
      rc_intersect (&window->scroll, &r);
      set_redraw (window, &window->scroll);
    } /* else */

    set_clip (TRUE, &r);

    mask_spec = m_get_mask_spec (mask_spec);

    if (mask_spec->act_obj == FAILURE) mask_spec->act_obj = act_obj;
    m_ed_index (mask_spec, mask_spec->act_obj, 1, NULL);
  } /* if */
} /* upd_iconbar */

/*****************************************************************************/

LOCAL VOID new_index (MASK_SPEC *mask_spec, MKINFO *mk)
{
  BOOLEAN found;
  WORD    edobj, act_obj;
  WORD    inx, x, y;
  RECT    r;
  LONG    item;
  WINDOWP window;

  window = mask_spec->window;

  if (VTBL (mask_spec->table) || (rtable (mask_spec->table) < NUM_SYSTABLES)) return;

  objc_offset (maskicon, LCINDEX, &x, &y);

  r.x = x;
  r.y = y + gl_hbox + 3;
  r.w = (num_chars + 4) * gl_wbox;	/* show 4 more characters */
  r.h = INX_VISIBLE * gl_hbox;

  ListBoxSetComboRect (maskicon, MIINDEX, &r, window->work.y - 1);

  if ((item = ListBoxComboClick (maskicon, MIINDEX, mk)) != FAILURE)
  {
    inx = indexnum (mask_spec->db, tableinx (mask_spec->db, mask_spec->table), (WORD)item);

    if (mask_spec->inx != inx)
    {
      if (! m_save_all (mask_spec, &edobj)) return;
      if (sel_window == window) unclick_window (window);

      m_edit_obj (mask_spec, MO_EXIT, 0, NULL);
      m_exit_pic (mask_spec, FAILURE);
      m_exit_rec (mask_spec, M_SET_NOTNULL, TRUE, FALSE);

      act_obj            = mask_spec->act_obj;
      mask_spec->inx     = inx;
      mask_spec->act_obj = FAILURE;

      if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor))
      {
        found = FALSE;

        if (is_null (TYPE_DBADDRESS, mask_spec->buffer))
          v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir);
        else
        {
          found = db_search (mask_spec->db->base, rtable (mask_spec->table), mask_spec->inx, ASCENDING, mask_spec->cursor, mask_spec->buffer, DB_ADR (mask_spec->buffer));
          if (! found)
          {
            if (db_status (mask_spec->db->base) == SUCCESS)
              hndl_alert (ERR_DBSEARCH);
            else
              dbtest (mask_spec->db);
          } /* if */
        } /* else */

        m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);

        if (found)
        {
          r   = window->work;
          r.h = window->work.h - window->scroll.h;
          set_redraw (window, &r);      /* update mask icons */
        } /* if */
        else
          set_redraw (window, &window->work);
      } /* if */

      m_ed_index (mask_spec, act_obj, 1, NULL);
      m_setdirty (mask_spec, FALSE);
    } /* if */
  } /* if */
} /* new_index */

/*****************************************************************************/

LOCAL VOID m_save (MASK_SPEC *mask_spec, WORD *edobj, MKINFO *mk)

{
  busy_mouse ();

  if (mk->shift || is_null (TYPE_DBADDRESS, mask_spec->buffer) || ! mask_spec->modify)
    m_insert (mask_spec, edobj);
  else
    m_update (mask_spec, edobj);

  arrow_mouse ();
} /* m_save */

/*****************************************************************************/

LOCAL VOID m_insert (MASK_SPEC *mask_spec, WORD *edobj)
{
  WORD    status, obj, err, i;
  SUBMASK *submask;

  m_exit_rec (mask_spec, M_SET_NOTNULL, TRUE, TRUE);

  if (mask_spec->pCalcExit != NULL)
  {
    err = v_execute (mask_spec->db, mask_spec->table, mask_spec->pCalcExit, mask_spec->buffer, 0L, NULL);
    if (err != SUCCESS)
    {
      hndl_alert (err);
      return;
    } /* if */
  } /* if */

  obj = ins_lookup (mask_spec);
  if (obj != NIL)
  {
    *edobj = obj;
    return;
  } /* if */

  if (db_insert (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer, &status))
  {
    if (mask_spec->pParentSpec == NULL)				/* save all submasks */
    {
      mask_spec->db_adr = DB_ADR (mask_spec->buffer);
      submask = mask_spec->Submask;

      for (i = 0; i < mask_spec->num_submasks; i++, submask++)
        if (submask->flags & MSM_SHOW_MASK)
          m_save_rec (submask->pMaskSpec, edobj, FALSE);	/* save submask */
    } /* if */

    db_reclock (mask_spec->db->base, DB_ADR (mask_spec->buffer));
    if (mask_config.clear) m_clear (mask_spec, M_USE_MFFLAG, FALSE);
    updt_lsall (mask_spec->db, mask_spec->table, FALSE, TRUE);
    m_setdirty (mask_spec, FALSE);
  } /* if */
  else
  {
    obj = test_rec (mask_spec, status);
    if (obj != FAILURE) *edobj = obj;
  } /* else */
} /* m_insert */

/*****************************************************************************/

LOCAL VOID m_update (MASK_SPEC *mask_spec, WORD *edobj)
{
  WORD    status, obj, err, i;
  SUBMASK *submask;

  if (mask_spec->pCalcExit != NULL)
  {
    err = v_execute (mask_spec->db, mask_spec->table, mask_spec->pCalcExit, mask_spec->buffer, 0L, NULL);
    if (err != SUCCESS)
    {
      hndl_alert (err);
      return;
    } /* if */
  } /* if */

  obj = ins_lookup (mask_spec);
  if (obj != NIL)
  {
    *edobj = obj;
    return;
  } /* if */

  if (db_update (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer, &status))
  {
    db_reclock (mask_spec->db->base, DB_ADR (mask_spec->buffer));
    m_exit_pic (mask_spec, FAILURE);

    if (mask_spec->pParentSpec == NULL)				/* save all submasks */
    {
      submask = mask_spec->Submask;

      for (i = 0; i < mask_spec->num_submasks; i++, submask++)
        if (submask->flags & MSM_SHOW_MASK)
          m_save_rec (submask->pMaskSpec, edobj, FALSE);	/* save submask */

      m_sm_init (mask_spec);
      m_all_fields (mask_spec, TRUE, TRUE);
    } /* if */

    updt_lsall (mask_spec->db, mask_spec->table, FALSE, TRUE);
    m_setdirty (mask_spec, FALSE);
  } /* if */
  else
  {
    obj = test_rec (mask_spec, status);
    if (obj != FAILURE) *edobj = obj;
  } /* else */
} /* m_update */

/*****************************************************************************/

LOCAL VOID m_delete (MASK_SPEC *mask_spec)
{
  WORD       status;
  LONG       old_addr;
  TABLE_INFO table_info;

  if (mask_config.ask_delete)
    if (hndl_alert (ERR_DELETE) == 2) return;

  old_addr  = DB_ADR (mask_spec->buffer);
  m_exit_rec (mask_spec, M_SET_NOTNULL, TRUE, FALSE);

  busy_mouse ();

  if (db_delete (mask_spec->db->base, rtable (mask_spec->table), DB_ADR (mask_spec->buffer), &status))
  {
    if (VTBL (mask_spec->table)) check_vtable (mask_spec->table, old_addr);

    v_tableinfo (mask_spec->db, mask_spec->table, &table_info);
    if (table_info.recs == 0)
      db_fillnull (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer);
    else
    {
      v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir);
      m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);
    } /* else */

    m_exit_pic (mask_spec, FAILURE);

    if (mask_spec->pParentSpec == NULL)
    {
      m_sm_init (mask_spec);
      m_all_fields (mask_spec, TRUE, TRUE);
    } /* if */

    updt_lsall (mask_spec->db, mask_spec->table, FALSE, TRUE);
    m_setdirty (mask_spec, FALSE);
  } /* if */
  else
    dbtest (mask_spec->db);

  arrow_mouse ();
} /* m_delete */

/*****************************************************************************/

LOCAL VOID m_search (MASK_SPEC *mask_spec, WORD edobj, MKINFO *mk)
{
  BOOLEAN    found, ready, bMulti;
  WORD       inx, h;
  LONG       count;
  RECT       rc;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  WINDOWP    window;
  BYTE       *p, *q;
  EDFIELD    *ed_field;
  SUBMASK    *submask;

  if (edobj == FAILURE) return;

  mask_spec = m_get_mask_spec (mask_spec);
  submask   = mask_spec->pSubmask;
  window    = mask_spec->window;

  m_exit_rec (mask_spec, M_SET_NOTNULL, TRUE, FALSE);

  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);
  if (table_info.recs == 0)
  {
    db_fillnull (mask_spec->db->base, rtable (mask_spec->table), mask_spec->buffer);
    return;
  } /* if */

  ed_field = &mask_spec->ed_field [edobj];
  bMulti   = mk->alt;
  inx      = find_index (mask_spec->db->base, ed_field->table, ed_field->field);

  if ((inx == FAILURE) && bMulti) inx = mask_spec->inx;	/* don't change actual index, use multi index for searching */

  if (VINX (mask_spec->inx)) inx = mask_spec->inx;	/* don't change actual index if it's already a virtual index */

  if ((mask_spec->pParentSpec != NULL) && (inx > FAILURE)) inx = FAILURE;	/* if submask search always sequential */

  if ((mask_spec->inx != inx) || (inx <= FAILURE))
  {
    mask_spec->inx = (inx == FAILURE) ? 0 : inx;	/* 0 = sequential */
    if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor) &&
        v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir))
      if (mask_spec->pParentSpec == NULL) mset_info (mask_spec->window);
  } /* if */

  m_setdirty (mask_spec, FALSE);

  busy_mouse ();

  if (inx <= FAILURE) /* search sequential */
  {
    found = FALSE;
    ready = FALSE;
    count = 0;

    while (! ready && ! found)
    {
      count++;

      if (! ready)
        if (count % 100 == 0)
          if (esc_pressed ())
            ready = TRUE;

      if (! ready)
      {
        ready = ! v_read (mask_spec->db, mask_spec->table, mask_spec->db->buffer, mask_spec->cursor, 0L, FALSE);

        db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);

        p = (BYTE *)mask_spec->db->buffer + field_info.addr;	/* value fom database */
        q = (BYTE *)mask_spec->buffer + field_info.addr;	/* search value */

        if (HASWILD (field_info.type))	/* wildcard comparison */
        {
          str_upper (p);
          str_upper (q);

          if (str_match (q, p) == 0) found = TRUE;
        } /* if */
        else				/* binary comparison */
          if (cmp_vals (field_info.type, p, q) == 0) found = TRUE;
      } /* if */

      if (! found && ! ready) ready = ! v_movecursor (mask_spec->db, mask_spec->cursor, mask_spec->dir);
    } /* while */
  } /* if */
  else
    found = db_search (mask_spec->db->base, rtable (mask_spec->table), mask_spec->inx, ASCENDING, mask_spec->cursor, mask_spec->buffer, 0L);

  if (! found)
  {
    if (db_status (mask_spec->db->base) == SUCCESS)
      hndl_alert (ERR_DBSEARCH);
    else
      dbtest (mask_spec->db);
  } /* if */

  set_clip (TRUE, &window->scroll);

  m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);

  m_exit_pic (mask_spec, FAILURE);

  if (mask_spec->pParentSpec == NULL)
  {
    m_sm_init (mask_spec);
    m_all_fields (mask_spec, TRUE, TRUE);
  } /* if */
  else
  {
    m_all_fields (mask_spec, FALSE, FALSE);
    submask->doc.y = count - 1;
    ScrollBar_SetWindowHandle (submask->hsb, mask_spec->window->handle);
    ScrollBar_SetPos (submask->hsb, submask->doc.y, TRUE);
    rc = m_calc_sm_attr (vdi_handle, submask, &submask->frame, SM_ATTR_RECCOUNT, &h);

    set_clip (TRUE, &rc);
    redraw_window (mask_spec->window, &rc);			/* draw rec count */
    set_clip (TRUE, &window->scroll);				/* clipping will be destroyed in redraw window */
  } /* if */

  arrow_mouse ();
} /* m_search */

/*****************************************************************************/

LOCAL VOID m_next (MASK_SPEC *mask_spec, WORD dir, MKINFO *mk)
{
  BOOLEAN ok;
  WORD    button, ret, h;
  LONG    pos;
  RECT    rc;
  WINDOWP window;
  SUBMASK *submask;

  submask = mask_spec->pSubmask;
  window  = mask_spec->window;

  if (mk->breturn == 2)
  {
    dir = -dir;
    if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, dir, mask_spec->cursor))
      if (v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)dir))
      {
        m_exit_rec (mask_spec, M_SET_NULL, TRUE, FALSE);
        m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);
        m_exit_pic (mask_spec, FAILURE);

        if (mask_spec->pParentSpec != NULL)
        {
          if (! alert_shown) m_all_fields (mask_spec, FALSE, FALSE);
          pos = (dir > 0) ? 0 : submask->doc.h - 1;
          submask->doc.y = pos;
          ScrollBar_SetWindowHandle (submask->hsb, mask_spec->window->handle);
          ScrollBar_SetPos (submask->hsb, submask->doc.y, TRUE);
          rc = m_calc_sm_attr (vdi_handle, submask, &submask->frame, SM_ATTR_RECCOUNT, &h);

          set_clip (TRUE, &rc);
          redraw_window (mask_spec->window, &rc);			/* draw rec count */
          set_clip (TRUE, &window->scroll);				/* clipping will be destroyed in redraw window */
        } /* if */
        else
        {
          m_sm_init (mask_spec);
          if (! alert_shown) m_all_fields (mask_spec, TRUE, TRUE);
        } /* else */
      } /* if, if */
  } /* if */
  else
  {
    do
    {
      ok = v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)dir);

      if (ok)
      {
        m_exit_rec (mask_spec, M_SET_NULL, TRUE, FALSE);
        m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);
        m_exit_pic (mask_spec, FAILURE);
        if (! alert_shown) m_all_fields (mask_spec, FALSE, FALSE);

        if (mask_spec->pParentSpec != NULL)
        {
          pos = ScrollBar_GetPos (mask_spec->pSubmask->hsb);
          submask->doc.y = pos + dir;
          ScrollBar_SetWindowHandle (submask->hsb, mask_spec->window->handle);
          ScrollBar_SetPos (submask->hsb, submask->doc.y, TRUE);
          rc = m_calc_sm_attr (vdi_handle, submask, &submask->frame, SM_ATTR_RECCOUNT, &h);

          set_clip (TRUE, &rc);
          redraw_window (mask_spec->window, &rc);			/* draw rec count */
          set_clip (TRUE, &window->scroll);				/* clipping will be destroyed in redraw window */
        } /* if */
      } /* if */

      graf_mkstate (&ret, &ret, &button, &ret);

      if (mask_spec->pParentSpec == NULL)
        if ( ! (button & 0x003) || ! ok)
        {
          m_sm_init (mask_spec);
          m_all_submasks (mask_spec);	/* if mouse button was released, draw submasks */
        } /* if, if */
    } while ((button & 0x003) && ok);
  } /* else */

  m_setdirty (mask_spec, FALSE);
} /* m_next */

/*****************************************************************************/

LOCAL VOID m_clear (MASK_SPEC *mask_spec, WORD null_flag, BOOLEAN rec_unlock)
{
  WORD       obj, err;
  TABLE_INFO table_info;
  EDFIELD    *ed_field;

  ed_field = mask_spec->ed_field;

  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);

  if (! proc_used (mask_spec->db))      /* db->buffer used by any process of this db */
  {
    mask_spec->clear_buffered = TRUE;
    mem_lmove (mask_spec->db->buffer, mask_spec->buffer, table_info.size);
  } /* if */

  m_exit_rec (mask_spec, null_flag, rec_unlock, FALSE);
  m_exit_pic (mask_spec, FAILURE);

  if (mask_spec->pCalcEntry != NULL)
  {
    err = v_execute (mask_spec->db, mask_spec->table, mask_spec->pCalcEntry, mask_spec->buffer, 0L, NULL);
    if (err != SUCCESS) hndl_alert (err);
  } /* if */

  for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
    m_test_null (mask_spec->db->base, ed_field->table, ed_field->field, mask_spec->buffer, FALSE);

  if (mask_spec->pParentSpec == NULL)
  {
    m_sm_init (mask_spec);
    m_all_fields (mask_spec, TRUE, TRUE);
  } /* if */

  m_setdirty (mask_spec, FALSE);

  mask_spec->act_obj = FAILURE;
  med_first (mask_spec->window);

#if GEMDOS
/*  Stop_PH_Sound ();*/
  SND_stop ();
#endif
} /* m_clear */

/*****************************************************************************/

LOCAL VOID m_calc (MASK_SPEC *mask_spec, WORD obj)
{
  BOOLEAN    found;
  WORD       err, field, i;
  TABLE_INFO table_info;
  CALCOBJ    *calcobj;

  if (obj == FAILURE)
    m_ed2field (mask_spec, mask_spec->act_obj, FALSE);
  else
  {
    calcobj = mask_spec->calcobj;
    found   = FALSE;

    for (i = 0; (i < mask_spec->calcobjs) && ! found; i++, calcobj++)
      if (calcobj->obj == obj)
      {
        found = TRUE;
        break;
      } /* if, for */

    if (! found) return;
  } /* else */

  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);

  for (field = 1; field <table_info.cols; field++)
    m_test_null (mask_spec->db->base, rtable (mask_spec->table), field, mask_spec->buffer, FALSE);

  if (obj == FAILURE)
    err = v_execute (mask_spec->db, mask_spec->table, NULL, mask_spec->buffer, 0L, NULL);
  else
    err = v_execute (mask_spec->db, mask_spec->table, &calcobj->code, mask_spec->buffer, 0L, NULL);

  if (err != SUCCESS) hndl_alert (err);

  m_change_buffer (mask_spec);		/* show new changed buffer */
  m_setdirty (mask_spec, TRUE);
} /* m_calc */

/*****************************************************************************/

LOCAL WORD ins_lookup (MASK_SPEC *mask_spec)
{
  BOOLEAN    ok, same_ref;
  WORD       status, obj, result, num_lus, i, refcol;
  FIELD_INFO field_info;
  LU         lutab [MAX_LUS], *lu;
  BYTE       *buffer;
  DB         *db;
  MFIELD     *mfield;
  EDFIELD    *ed_field;

  ed_field = mask_spec->ed_field;
  db       = mask_spec->db;
  buffer   = db->buffer;
  ok       = TRUE;

  for (obj = 0; ok && (obj < mask_spec->edobjs); obj++, ed_field++)
  {
    mfield = ed_field->mfield;
    if (mfield->class == M_SUBMASK) continue;

    ok = m_test_null (mask_spec->db->base, ed_field->table, ed_field->field, mask_spec->buffer, TRUE);

    if (ok && (mfield->flags & MF_USEBOUNDS))
      ok = test_bounds (mask_spec->db->base, ed_field->table, ed_field->field, mask_spec->buffer, TRUE, mfield->lower, mfield->upper);
  } /* for */

  if (! ok) return (--obj);

  ed_field = mask_spec->ed_field;

  for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
  {
    if (ed_field->mfield->class == M_SUBMASK) continue;

    if ((ed_field->flags & COL_LOOKUP) && (ed_field->table != ed_field->lu_table))
    {
      db_fillnull (db->base, ed_field->lu_table, buffer);
      num_lus  = fill_lus (mask_spec, lutab, ed_field->lu_table, ed_field->table);
      lu       = lutab;
      same_ref = TRUE;
      refcol   = lu->refcol;

      for (i = 0; i < num_lus; i++, lu++)
        if (refcol != lu->refcol)
        {
          same_ref = FALSE;
          break;
        } /* if, for */

      if (same_ref)
      {
        db_fieldinfo (db->base, ed_field->table, ed_field->field, &field_info);
        db_setfield (db->base, ed_field->lu_table, ed_field->lu_field, buffer, (BYTE *)mask_spec->buffer + field_info.addr);
      } /* if */
      else
        for (i = 0, lu = lutab; i < num_lus; i++, lu++)
        {
          db_fieldinfo (db->base, ed_field->table, lu->dstcol, &field_info);
          db_setfield (db->base, ed_field->lu_table, lu->refcol, buffer, (BYTE *)mask_spec->buffer + field_info.addr);
        } /* for, else */

      ok     = db_insert (db->base, ed_field->lu_table, buffer, &status);
      result = db_status (db->base);

      if (ok)
        updt_lsall (db, ed_field->lu_table, FALSE, TRUE);
      else
        if ((result != DB_CNOTUNIQUE) &&
            (result != DB_CNULLCOL)) dbtest (db);
    } /* if */
  } /* for */

  return (NIL);         /* no objects with errors found */
} /* ins_lookup */

/*****************************************************************************/

LOCAL WORD fill_lus (MASK_SPEC *mask_spec, LU *lu, WORD reftbl, WORD dsttbl)
{
  WORD       recs, i, num_lus;
  TABLE_INFO table_info;
  SYSLOOKUP  *syslookup;

  db_tableinfo (mask_spec->db->base, SYS_LOOKUP, &table_info);
  recs      = table_info.recs;
  syslookup = mask_spec->db->syslookup;

  for (i = num_lus = 0; (i < recs) && (num_lus < MAX_LUS); i++, syslookup++)
    if ((syslookup->reftable == reftbl) && (syslookup->table == dsttbl))
    {
      lu->dstcol = syslookup->column;
      lu->refcol = syslookup->refcolumn;

      num_lus++;
      lu++;
    } /* if, for */

  return (num_lus);
} /* fill_lus */

/*****************************************************************************/

LOCAL VOID get_fattr (WORD out_handle, WORD wbox, WORD hbox, FATTR *fattr)
{
  fattr->w_shadow = fattr->h_shadow = 0;
  fattr->w_attr   = fattr->h_attr   = gl_wattr;

  if ((out_handle == vdi_handle) && (gl_hbox <= 8))     /* low resolution on screen */
  {
    fattr->h_shadow /= 2;
    fattr->w_attr   *= 2;
  } /* if */
} /* get_fattr */

/*****************************************************************************/

LOCAL VOID draw_checkbox (WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color)
{
  m_draw_cr (out_handle, x, y, h, selected, color, bk_color, TRUE);
} /* draw_checkbox */

/*****************************************************************************/

LOCAL VOID draw_rbutton (WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color)
{
  m_draw_cr (out_handle, x, y, h, selected, color, bk_color, FALSE);
} /* draw_rbutton */

/*****************************************************************************/

LOCAL VOID draw_pic (MASK_SPEC *mask_spec, WORD edobj)
{
  WORD       result;
  GEMOBJP    gem;
  IMGOBJP    img;
  RECT       pos;
  FIELD_INFO field_info;
  MFIELD     *mfield;
  BYTE       *buffer;
  LONG       *lbuffer;
  PICOBJ     *picobj;
  EDFIELD    *ed_field;
  WINDOWP    window;

  window   = mask_spec->window;
  ed_field = &mask_spec->ed_field [edobj];
  picobj   = &mask_spec->dpicobj [ed_field->pic];

  if (picobj->flags & PIC_INVALID)
  {
    db_fieldinfo (mask_spec->db->base, ed_field->table, ed_field->field, &field_info);
    buffer       = mask_spec->buffer;
    buffer       = buffer + field_info.addr;
    lbuffer      = (LONG *)buffer;
    picobj->type = (WORD)lbuffer [1];
    mfield       = ed_field->mfield;
    pos          = m_get_edrect (mask_spec, mfield, FALSE);

    if (is_null (TYPE_PICTURE, buffer))
    {
      pos.x += window->scroll.x - window->doc.x * window->xfac;
      pos.y += window->scroll.y - window->doc.y * window->yfac;
      clr_area (&pos);
      return;
    } /* if */

    switch (picobj->type)
    {
      case PIC_META  : gem             = &picobj->pic.gem;
                       gem->window     = window;
                       gem->pos        = pos;
                       gem->out_handle = vdi_handle;
                       gem->fsize      = lbuffer [0] - sizeof (LONG);      /* don't need type of picture */
                       result          = gem_obj (gem, GEM_INIT, GEM_MEM | GEM_BESTFIT, &lbuffer [2]);

                       switch (result)
                       {
                         case GEM_OK       : picobj->flags &= ~ PIC_INVALID; break;
                         case GEM_NOMEMORY : hndl_alert (ERR_NOMEMORY);      break;
                       } /* switch */
                       break;
      case PIC_IMAGE : img          = &picobj->pic.img;
                       img->window  = window;
                       img->pos     = pos;
                       result       = image_obj (img, IMG_INIT, IMG_MEM, &lbuffer [2]);
                       img->bufsize = lbuffer [0] - sizeof (LONG);      /* don't need type of picture */

                       switch (result)
                       {
                         case IMG_OK       : picobj->flags &= ~ PIC_INVALID; break;
                         case IMG_NOMEMORY : hndl_alert (ERR_NOMEMORY);      break;
                       } /* switch */
                       break;
      case PIC_IFF   : break;
      case PIC_TIFF  : break;
    } /* switch */
  } /* if */

  switch (picobj->type)
  {
    case PIC_META  : gem_obj (&picobj->pic.gem, GEM_DRAW, 0, NULL);   break;
    case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_DRAW, 0, NULL); break;
    case PIC_IFF   :                                                  break;
    case PIC_TIFF  :                                                  break;
  } /* switch */
} /* draw_pic */

/*****************************************************************************/

LOCAL VOID set_mredraw (MASK_SPEC *mask_spec, WORD obj)
{
  WORD      x, y;
  RECT      r;

  if (mask_spec->sm_flags & SM_SHOW_ICONS)
  {
    objc_offset (maskicon, obj, &x, &y);
    xywh2rect (x, y, maskicon [obj].ob_width, maskicon [obj].ob_height, &r);
    set_redraw (mask_spec->window, &r);
  } /* if */
} /* set_mredraw */

/*****************************************************************************/

LOCAL VOID hndl_obj (MASK_SPEC *mask_spec, MASK_SPEC *old_spec, WORD obj, MKINFO *mk, BOOLEAN arrow)
{
  BOOLEAN   ok;
  BOOLEAN   in_arrow, is_button, is_graf, is_submask, b3D;
  WORD      msg, old_obj, sub, old_colors;
  RECT      r;
  FATTR     fattr;
  WINDOWP   window;
  MFIELD    *mfield;
  EDFIELD   *ed_field, *old_field;
  MASK_SPEC *root_spec;
  SYSMASK   *sysmask;

  ok         = TRUE;
  ed_field   = &mask_spec->ed_field [obj];
  mfield     = ed_field->mfield;
  sysmask    = mask_spec->mask;
  old_colors = dlg_colors;
  b3D        = (dlg_colors >= 16) && (sysmask->flags & SM_SHOW_3D);

  if (! b3D) dlg_colors = 2;

  if ((mk->breturn == 1) && (mk->alt))
  {
    mfield->flags ^= MF_NOCLEAR;
    m_get_rect (mask_spec, vdi_handle, mfield->class, (MOBJECT *)mfield, &r, &fattr);
    set_redraw (mask_spec->window, &r);
    return;
  } /* if */

  if (! arrow) hide_mouse ();
  m_edit_obj (old_spec, MO_HIDECURSOR, 0, NULL);

  if ((mask_spec->act_obj != obj) || (mask_spec != old_spec))	/* set to new object */
  {
    ok = m_ed2field (old_spec, old_spec->act_obj, TRUE);
    if (ok)
    {
      m_edit_obj (old_spec, MO_EXIT, 0, NULL);	/* leave old object */
      old_spec->act_obj = FAILURE;

      window    = mask_spec->window;
      root_spec = (MASK_SPEC *)window->special;
      old_obj   = m_find_obj (root_spec, mk, &in_arrow, &is_button, &is_graf, &is_submask, &sub);	/* find submask */
      old_field = &root_spec->ed_field [old_obj];

      root_spec->last_obj = old_obj;		/* remember next edit object number for restoring when leaving submask */
      root_spec->act_obj  = FAILURE;		/* edit object is now in sub mask, so clear act obj number from parent mask */
      root_spec->act_sub  = old_field->sub;	/* act_sub is edit index of sub mask */

      mask_spec->act_obj  = 0;
      mask_spec->last_obj = 0;
      m_ed_index (mask_spec, obj, 1, mk);
    } /* if */
  } /* if */

  if (ok)
  {
    if (arrow)
      col_popup (mask_spec->window, mk, FALSE);
    else
    {
      msg = m_edit_obj (mask_spec, MO_CLICK, 0, mk);
      if (msg == MO_BUFFERCHANGED) m_setdirty (mask_spec, TRUE);
    } /* else */
  } /* if */

  if ((mk->breturn == 2) && ! arrow)
  {
    if (mk->alt)							/* Verzweigung							*/
      mjoin (mask_spec->window);
    else
      m_edopen (mask_spec);		/* double clicking on object */
  } /* if */

  m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
  if (! arrow) show_mouse ();

  dlg_colors = old_colors;
} /* hndl_obj */

/*****************************************************************************/

LOCAL VOID hndl_button (MASK_SPEC *mask_spec, MASK_SPEC *sub_spec, WORD obj, MKINFO *mk)
{
  BOOLEAN   ok;
  WORD      command, title, item;
  WORD      msgbuff [8];
  RECT      r, old_clip;
  FATTR     fattr;
  TABLENAME name;
  BYTE      *p;
  MBUTTON   *mbutton;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  WINDOWP   window;

  window   = mask_spec->window;
  sysmask  = mask_spec->mask;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  mobject  = &mobject [obj];
  mbutton  = &mobject->mbutton;
  command  = mbutton->command;
  p        = &sysmask->mask.buffer [mbutton->param];
  old_clip = clip;

  hide_mouse ();
  m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
  ok = m_ed2field (sub_spec, sub_spec->act_obj, TRUE);
  if (ok)
  {
    m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
    m_ed_index (sub_spec, sub_spec->act_obj, 1, mk);
  } /* if */

  m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
  show_mouse ();
  if (! ok) return;

  table_name (mask_spec->db, mask_spec->table, name);
  m_get_rect (mask_spec, vdi_handle, M_BUTTON, mobject, &r, &fattr);
  mbutton->flags |= MBF_SELECTED;
  redraw_window (mask_spec->window, &r);	/* show selected button */
  set_clip (TRUE, &old_clip);

  if (mask_spec->pParentSpec != NULL)		/* handle button in submask */
  {
    do_button (mask_spec, command, p, obj, mk);
    mbutton->flags &= ~ MBF_SELECTED;
    redraw_window (window, &r);
    return;
  } /* if */

  if (mk->breturn == 2)
  {
    switch (command)
    {
      case MB_PREV : command = MB_FIRST; break;
      case MB_NEXT : command = MB_LAST;  break;
    } /* switch */
  } /* if */

  title = comm2menu [command].title;
  item  = comm2menu [command].item;

  switch (command)
  {
    case MB_CALC        : if (*p == EOS)
                            mask_menu (window, title, item);
                          else
                            m_calc (mask_spec, obj);
                          break;
    case MB_CHANGE      : if (*p == EOS)
                            mask_menu (window, title, item);
                          else
                            mchange (window, p);
                          break;
    case MB_JOIN_MASK   :
    case MB_JOIN_NEW    :
    case MB_JOIN_TABLE  : if (*p == EOS)
                            mask_menu (window, title, item);
                          else
                            button_join (mask_spec, command, p);
                          break;
    case MB_REPORT      : button_report (mask_spec, p, DEV_SCREEN);
                          break;
    case MB_PRINT       : button_report (mask_spec, table_name (mask_spec->db, mask_spec->table, name), DEV_PRINTER);
                          break;
    case MB_USERHELP    : open_help (FREETXT (FHELPBAS), app_path, p);
                          break;
    case MB_WINFULL     : 
    case MB_WINCLOSE    : mem_set (msgbuff, 0, sizeof (msgbuff));
                          msgbuff [0] = (command == MB_WINFULL) ? WM_FULLED : WM_CLOSED;
                          msgbuff [1] = gl_apid;
                          msgbuff [3] = window->handle;
                          appl_write (gl_apid, sizeof (msgbuff), msgbuff);
                          break;
    case MB_QUERY_MASK  :
    case MB_QUERY_TABLE : button_query (mask_spec, command, p);
                          break;
    case MB_BATCH       : button_batch (mask_spec, p);
                          break;
    case MB_MULTIBUTTON : button_multi (mask_spec, p, mk);
                          break;
    case MB_ACCOUNT     : button_account (mask_spec, p, DEV_SCREEN);
                          break;
/* [GS] 5.1d */
    case MB_USERHELPST	: user_help ( p );
    											break;
/* Ende */
    default             : mask_menu (window, title, item);
  } /* switch */

  mbutton->flags &= ~ MBF_SELECTED;
  redraw_window (window, &r);
} /* hndl_button */

/*****************************************************************************/

LOCAL VOID hndl_submask  (MASK_SPEC *mask_spec, WORD sub, MKINFO *mk)
{
  BOOLEAN   in_arrow, is_button, is_graf, is_submask;
  WORD      y, h, obj;
  RECT      rc, frame;
  FATTR     fattr;
  MOBJECT   *mobject;
  SUBMASK   *submask;
  SYSMASK   *sysmask;
  MASK_SPEC *org_spec;

  org_spec  = m_get_mask_spec (mask_spec);
  sysmask   = mask_spec->mask;
  submask   = &mask_spec->Submask [sub];
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [submask->obj];
  mask_spec = submask->pMaskSpec;			/* get mask_spec of submask and use it as new mask_spec */

  m_get_rect (mask_spec, vdi_handle, M_SUBMASK, mobject, &frame, &fattr);

  if (mask_spec == NULL) return;			/* no mask_spec pointer, if sql statement in mu_sql_init could not be executed */

  frame.x += 1;						/* leave bounding rect untouched */
  frame.y += 1;
  frame.w -= 2;
  frame.h -= 2;

  submask->index = sub;
  submask->frame = frame;

  if (submask->flags & MSM_SHOW_TABLE)
  {
    rc = m_calc_sm_attr (vdi_handle, submask, &frame, SM_ATTR_VSLIDER, &h);

    if (inside (mk->mox, mk->moy, &rc))
    {
      ScrollBar_SetWindowHandle (submask->hsb, mask_spec->window->handle);
      ScrollBar_SetRect (submask->hsb, &rc, FALSE);
      ScrollBar_Click (submask->hsb, mk);

      return;
    } /* if */

    y   = frame.y + submask->yscroll;
    obj = (mk->moy - y) / submask->yfac;
    if (obj >= submask->doc.h) return;

    if (mk->breturn == 2)
    {
      frame.y += submask->yscroll + obj * submask->yfac;
      frame.w -= rc.w;					/* leave space for scroll bar */
      frame.h  = submask->yfac;

      submask->sel_obj = obj;
      redraw_window (mask_spec->window, &frame);	/* show selected line in submask list */

      open_mask (NIL, mask_spec->db, mask_spec->table, mask_spec->inx, ASCENDING, "", NULL, submask->recaddr [obj], NULL, NULL, FALSE);

      submask->sel_obj = FAILURE;
      set_redraw (mask_spec->window, &frame);		/* show selected button */
    } /* if */
  } /* if */
  else
  {
    rc = m_calc_sm_attr (vdi_handle, submask, &frame, SM_ATTR_HSLIDER, &h);

    if (inside (mk->mox, mk->moy, &rc))
    {
      if (mask_spec->buf_dirty)
      {
        if (! m_ed2field (mask_spec, mask_spec->act_obj, FALSE)) return;
        if (m_save_rec (mask_spec, &obj, TRUE)) m_setdirty (mask_spec, FALSE);

        return;
      } /* if, if */

      ScrollBar_SetWindowHandle (submask->hsb, mask_spec->window->handle);
      ScrollBar_SetRect (submask->hsb, &rc, FALSE);
      ScrollBar_Click (submask->hsb, mk);
    } /* if */
    else				/* inside scroll area of submask */
    {
      obj = m_find_obj (mask_spec, mk, &in_arrow, &is_button, &is_submask, &is_graf, &sub);

      if (obj != NIL)
      {
        if (is_graf)
          hndl_graf (mask_spec, org_spec, obj, mk);
        else
          if (is_button)
            hndl_button (mask_spec, org_spec, obj, mk);
          else
            if (is_submask)
              hndl_submask (mask_spec, sub, mk);
            else
              hndl_obj (mask_spec, org_spec, obj, mk, in_arrow);
      } /* if */
    } /* else */
  } /* else */
} /* hndl_submask */

/*****************************************************************************/

LOCAL VOID hndl_graf (MASK_SPEC *mask_spec, MASK_SPEC *sub_spec, WORD obj, MKINFO *mk)
{
  FULLNAME szExt;
  BYTE     *pFilename;
  MGRAF    *mgraf;
  MOBJECT  *mobject;
  SYSMASK  *sysmask;

  if (mk->breturn == 2)
  {
    sysmask   = sub_spec->mask;
    mobject   = (MOBJECT *)sysmask->mask.buffer;
    mobject   = &mobject [obj];
    mgraf     = (MGRAF *)mobject;
    pFilename = &sysmask->mask.buffer [mgraf->filename];

    mGetPicFilename (mask_spec, szOlgaFilename, pFilename);
    strcpy (szExt, ".");
    file_split (szOlgaFilename, NULL, NULL, NULL, &szExt [1]);

    OlgaStartExt (szExt, szOlgaFilename);
  } /* if */
} /* hndl_graf */

/*****************************************************************************/

LOCAL WORD sm2sql (MASK_SPEC *mask_spec, MSUBMASK *msubmask, BYTE *sql)
{
  BOOL       ok, found;
  WORD       table, field, err, obj;
  LONGSTR    szLinkMaster, szLinkChild;
  LONGSTR    szMasterIndex, s;
  STRING     szFormat;
  TABLENAME  szChildTable;
  INDEXNAME  szChildIndex;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  MASK_SPEC  tmp_spec;
  CURSOR     cursor;
  MFIELD     *mfield;
  MOBJECT    *mobject;
  BYTE       *pColBuf, *p, *field_name;
  BYTE       *pSubmaskName;
  SYSMASK    *sysmask, *tmp_sysmask;
  SYSQUERY   *sysquery;

  mem_set (&tmp_spec, 0, sizeof (MASK_SPEC));

  sysmask      = mask_spec->mask;
  tmp_spec.db  = mask_spec->db;
  pSubmaskName = &sysmask->mask.buffer [msubmask->SourceObject];

  db_beg_trans (mask_spec->db->base, FALSE);
  err = mu_load (&tmp_spec, MASK_SCREEN, pSubmaskName);	/* load submask to check the fields */
  db_end_trans (mask_spec->db->base);

  if (err != SUCCESS)
  {
    switch (err)
    {
      case ERR_NOMEMORY   :
      case ERR_NOMASK     : hndl_alert (err);
                            break;
      case ERR_NOUSERMASK : sprintf (s, alerts [err], mask_spec->db->base->username);
                            open_alert (s);
                            break;
    } /* switch */

    return (FAILURE);
  } /* if */

  strcpy (szLinkMaster, &sysmask->mask.buffer [msubmask->LinkMaster]);
  strcpy (szLinkChild , &sysmask->mask.buffer [msubmask->LinkChild]);

  if ((szLinkMaster [0] != EOS) && (szLinkChild [0] != EOS))
  {
    p = strchr (szLinkMaster, CHR_TBLSEP);	/* TABLE.index or TABLE.field */

    if (p == NULL)				/* if no table name only index/field name is given */
      p = szLinkMaster;
    else
      p++;

    strcpy (field_info.name, p);
    field = db_fieldinfo (mask_spec->db->base, rtable (mask_spec->table), FAILURE, &field_info);
    if (field == FAILURE)
    {
      mem_free (tmp_spec.mask);
      hndl_alert (ERR_SM_LINK_OBJ);
      return (ERR_SM_LINK_OBJ);
    } /* if */

    if (HASWILD (field_info.type))
    {
      strncpy (szMasterIndex,  (BYTE *)mask_spec->buffer + field_info.addr, LONGSTRLEN);
      szMasterIndex [LONGSTRLEN] = EOS;
    } /* if */
    else
      bin2str (field_info.type, (BYTE *)mask_spec->buffer + field_info.addr, szMasterIndex);

    p = strchr (szLinkChild, CHR_TBLSEP);	/* TABLE.index or TABLE.field */

    if (p == NULL)
    {
      mem_free (tmp_spec.mask);
      hndl_alert (ERR_SM_LINK_OBJ);
      return (ERR_SM_LINK_OBJ);
    } /* if */

    *p = EOS;
    strcpy (szChildTable, szLinkChild);
    p++;
    strcpy (szChildIndex, p);

    pColBuf = mem_alloc ((LONG)MAX_COLBUFFER);
    if (pColBuf == NULL) return (ERR_NOMEMORY);
    pColBuf [0] = EOS;

    tmp_sysmask = tmp_spec.mask;
    mobject     = (MOBJECT *)tmp_sysmask->mask.buffer;

    for (obj = 0; obj < tmp_spec.objs; obj++, mobject++)	/* get columns & their width */
    {
      mfield = &mobject->mfield;

      if (mfield->class == M_FIELD)
      {
        strcpy (table_info.name, tmp_sysmask->tablename);
        table = db_tableinfo (mask_spec->db->base, FAILURE, &table_info);
        if (table == FAILURE) continue;

        field_name = &tmp_sysmask->mask.buffer [mfield->field_name];
        strcpy (field_info.name, field_name);
        field = db_fieldinfo (mask_spec->db->base, table, FAILURE, &field_info);
        if (field != FAILURE)
        {
          if (HASWILD (field_info.type))
            sprintf (szFormat, "%s:-%d,", field_name, mfield->w);
          else
            sprintf (szFormat, "%s:%d,", field_name, mfield->w);

          strcat (pColBuf, szFormat);
        } /* if */
      } /* if */
    } /* for */

    p = strrchr (pColBuf, ',');		/* delete last "," */
    if (p != NULL) *p = EOS;
    if (pColBuf [0] == EOS) strcpy (pColBuf, "*");

    sprintf (sql, "SELECT %s FROM %s WHERE %s = \"%s\";", pColBuf, szChildTable, szChildIndex, szMasterIndex);

    mem_free (pColBuf);
  } /* if */
  else	/* try to get the query from the submask */
  {
    ok = FALSE;

    sysquery = (SYSQUERY *)mem_alloc ((LONG)sizeof (SYSQUERY));
    if (sysquery == NULL) return (ERR_NOMEMORY);

    strcpy (sysquery->name, tmp_spec.mask->tablename);	/* query name can be found in tablename of mask */

    if (sysquery->name [0] != EOS)
    {
      found = db_search (mask_spec->db->base, SYS_QUERY, 1, ASCENDING, &cursor, sysquery, 0L);
      if (found) ok = v_read (mask_spec->db, SYS_QUERY, sysquery, &cursor, 0L, FALSE);
    } /* if */

    if (ok && found)
    {
      strcpy (sql, sysquery->query);
      ok = m_varsql2sql (mask_spec->window, mask_spec->db, sysquery->query, sql);
      mem_free (sysquery);

      if (! ok)
      {
        mem_free (sysquery);
        mem_free (tmp_spec.mask);
        return (FAILURE);
      } /* if */
    } /* if */
    else
    {
      mem_free (sysquery);
      mem_free (tmp_spec.mask);
      sprintf (s, alerts [ERR_SM_NOTABLE], tmp_spec.mask->tablename, sysmask->name);
      open_alert (s);
      return (FAILURE);
    } /* else */
  } /* else */

  mem_free (tmp_spec.mask);

  return (SUCCESS);
} /* sm2sql */

/*****************************************************************************/

LOCAL VOID show_extern (BYTE *filename)
{
  BOOLEAN ok, blob;
  WORD    type;
  EXT     ext;

  file_split (filename, NULL, NULL, NULL, ext);

  type = FAILURE;
  blob = stricmp (ext, FREETXT (FSAMSUFF) + 2) == 0;

  if (stricmp (ext, FREETXT (FGEMSUFF) + 2) == 0) type = PIC_META;
  if (stricmp (ext, FREETXT (FIMGSUFF) + 2) == 0) type = PIC_IMAGE;
  if (stricmp (ext, FREETXT (FIFFSUFF) + 2) == 0) type = PIC_IFF;
  if (stricmp (ext, FREETXT (FTIFSUFF) + 2) == 0) type = PIC_TIFF;

  if (! blob)   /* was graphics or text */
  {
    switch (type)
    {
      case PIC_META   : ok = open_meta (NIL, filename);            break;
      case PIC_IMAGE  : ok = open_image (NIL, filename);           break;
      case PIC_IFF    : ok = FALSE;                                break;
      case PIC_TIFF   : ok = FALSE;                                break;
			default         : send_avstartprog ( filename, 0xabcd );		 break;

    } /* switch */

    if (! ok) hndl_alert (ERR_NOOPEN);

    return;
  } /* if */

  type = FAILURE;
  ok   = TRUE;

  if (stricmp (ext, FREETXT (FSAMSUFF) + 2) == 0) type = BLOB_SOUND;

  if (blob)
    switch (type)
    {
      case BLOB_SOUND : open_sound (filename); break;
      case BLOB_MIDI  : ok = FALSE;            break;
      default         : ok = FALSE;            break;
    } /* switch */

  if (! ok) hndl_alert (ERR_NOOPEN);
} /* show_extern */

/*****************************************************************************/

LOCAL VOID open_sound (BYTE *filename)
{
  LONG    size;
  FHANDLE f;
  LONG    *buffer;

  size   = file_length (filename) + 2 * sizeof (LONG);
  buffer = mem_alloc (size);

  if (buffer == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  f = file_open (filename, O_RDONLY);
  if (f >= 0)
  {
    buffer [0]  = size;
    buffer [1]  = BLOB_SOUND;
    size       -= 2 * sizeof (LONG);

    if (file_read (f, size, &buffer [2]) != size)
      file_error (ERR_FILEREAD, filename);
    else
      play_sound ((BYTE *)buffer, FALSE);

    file_close (f);
    mem_free (buffer);
  } /* if */
  else
    file_error (ERR_FILEOPEN, filename);
} /* open_sound */

/*****************************************************************************/

LOCAL VOID v_draw_text (WORD out_handle, RECT *r, BYTE *p, WORD font, WORD point, BOOLEAN wordbreak)
{
  WORD    wchar, hchar, wbox, hbox;
  WORD    minimum, maximum, width;
  WORD    distances [5], effects [3];
  WORD    x, y, i, start;
  LONGSTR s;

  vst_font (out_handle, font);
  vst_point (out_handle, point, &wchar, &hchar, &wbox, &hbox);

  if (wordbreak)
    if ((act_font != font) || (act_point != point) || (act_use_fonts != use_fonts))
    {
      vqt_font_info (out_handle, &minimum, &maximum, distances, &width, effects);
      act_font      = font;
      act_point     = point;
      act_use_fonts = use_fonts;

      for (i = 0; i < 256; i++) dt_wbox [i] = wbox;

      if (font > FONT_SYSTEM) get_wboxes (out_handle, dt_wbox, minimum, maximum);
    } /* if */

  start = (clip.y - r->y) / hbox;
  x     = r->x;
  y     = r->y + start * hbox;

  while (start > 0)
  {
    p = next_line (r->w, p, s, dt_wbox, wordbreak);
    start--;
  } /* while */

  while ((y < clip.y + clip.h) && (*p != EOS))
  {
    p = next_line (r->w, p, s, dt_wbox, wordbreak);
    v_text (out_handle, x, y, s);
    y += hbox;
  } /* while */
} /* v_draw_text */

/*****************************************************************************/

LOCAL BYTE *next_line (WORD width, BYTE *p, BYTE *s, WORD *wbox, BOOLEAN wordbreak)
{
  WORD  w, i, blank;
  UBYTE c;

  w     = 0;
  i     = 0;
  blank = 0;
  *s    = EOS;

  if (wordbreak)
  {
    while (*p && (*p != CR) && (w < width) && (i < LONGSTRLEN))
    {
      c   = (UBYTE)*p;
      *s  = *p;
      w  += wbox [c];

      if (w < width)
      {
        if (c == SP) blank = i;

        p++;
        s++;
        i++;
      } /* if */
    } /* while */

    if ((w >= width) && (blank > 0))
    {
     p -= i - blank - 1;
     s -= i - blank - 1;
    } /* if */
  } /* if */
  else
  {
    while (*p && (*p != CR) && (i < LONGSTRLEN))
    {
      *s++ = *p++;
      i++;
    } /* while */
  } /* else */

  if (*p == CR) p += 2;       /* CR & LF */
  *s = EOS;

  return (p);
} /* next_line */

/*****************************************************************************/

LOCAL VOID get_wboxes (WORD vdi_handle, WORD *boxes, WORD low, WORD high)
{
  WORD c;
  WORD cell_width;
  WORD *wboxes;

  wboxes = &boxes [low];

  for (c = low; c <= high; c++, wboxes++)
  {
#if GEMDOS                      /* error in TURBO_C on ATARI ST */
    intin [0]  = c;
    contrl [0] = 117;
    contrl [1] = 0;
    contrl [3] = 1;
    contrl [6] = vdi_handle;

    vdi ();

    cell_width = ptsout [0];
#else
    {
      WORD r;
      vqt_width (vdi_handle, (BYTE)c, &cell_width, &r, &r);
    }
#endif

    *wboxes = cell_width;
  } /* for */

  cell_width = boxes [SP];      /* use blank for undefined control chars */
  wboxes     = boxes;
  for (c = 0; c < ' '; c++) wboxes [c] = cell_width;
} /* get_wboxes */

/*****************************************************************************/

LOCAL VOID get_rtext (BYTE *p, BYTE *s, WORD index)
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

LOCAL VOID get_cbsvals (LONG size, BYTE *vals, BYTE *sel, BYTE *unsel)
{
  LONGSTR s;
  BYTE    *psel, *punsel;

  if (sel   != NULL) *sel   = EOS;
  if (unsel != NULL) *unsel = EOS;

  if ((vals == NULL) || (*vals == EOS)) return;

  strcpy (s, vals);

  psel   = s;
  punsel = strchr (s, CB_DELIMITER);

  if (punsel == NULL) return;

  *punsel = EOS;
  punsel++;

  if (sel != NULL)
  {
    psel [size - 1] = EOS;
    strcpy (sel, psel);
  } /* if */

  if (unsel != NULL)
  {
    punsel [size - 1] = EOS;
    strcpy (unsel, punsel);
  } /* if */
} /* get_cbsvals */

/*****************************************************************************/

LOCAL VOID get_cbwvals (LONG size, BYTE *vals, WORD *sel, WORD *unsel)
{
  STRING ssel, sunsel;

  get_cbsvals ((LONG)STRLEN, vals, ssel, sunsel);
  if (sel   != NULL) str2bin (TYPE_WORD, ssel, sel);
  if (unsel != NULL) str2bin (TYPE_WORD, sunsel, unsel);
} /* get_cbwvals */

/*****************************************************************************/

LOCAL VOID get_cblvals (LONG size, BYTE *vals, LONG *sel, LONG *unsel)
{
  STRING ssel, sunsel;

  get_cbsvals ((LONG)STRLEN, vals, ssel, sunsel);
  if (sel   != NULL) str2bin (TYPE_LONG, ssel, sel);
  if (unsel != NULL) str2bin (TYPE_LONG, sunsel, unsel);
} /* get_cblvals */

/*****************************************************************************/

LOCAL VOID get_cbfvals (LONG size, BYTE *vals, DOUBLE *sel, DOUBLE *unsel)
{
  STRING ssel, sunsel;

  get_cbsvals ((LONG)STRLEN, vals, ssel, sunsel);
  if (sel   != NULL) str2bin (TYPE_FLOAT, ssel, sel);
  if (unsel != NULL) str2bin (TYPE_FLOAT, sunsel, unsel);
} /* get_cbfvals */

/*****************************************************************************/

LOCAL VOID get_cbvals (LONG size, WORD type, BYTE *p, BOOLEAN selected, VOID *buffer)
{
  if (p == NULL) return;

  if (selected)
    switch (type)
    {
      case TYPE_CHAR  : get_cbsvals (size, p, (BYTE   *)buffer, NULL); break;
      case TYPE_WORD  : get_cbwvals (size, p, (WORD   *)buffer, NULL); break;
      case TYPE_LONG  : get_cblvals (size, p, (LONG   *)buffer, NULL); break;
      case TYPE_FLOAT : get_cbfvals (size, p, (DOUBLE *)buffer, NULL); break;
    } /* switch */
  else
    switch (type)
    {
      case TYPE_CHAR  : get_cbsvals (size, p, NULL, (BYTE   *)buffer); break;
      case TYPE_WORD  : get_cbwvals (size, p, NULL, (WORD   *)buffer); break;
      case TYPE_LONG  : get_cblvals (size, p, NULL, (LONG   *)buffer); break;
      case TYPE_FLOAT : get_cbfvals (size, p, NULL, (DOUBLE *)buffer); break;
    } /* switch */
} /* get_cbvals */

/*****************************************************************************/

LOCAL WORD test_rec (MASK_SPEC *mask_spec, WORD status)
{
  WORD       obj, table, field;
  STRING     name;
  LONGSTR    s;
  FIELD_INFO field_info;
  INDEX_INFO index_info;
  BYTE       *p;
  EDFIELD    *ed_field;

  table = rtable (mask_spec->table);
  field = FAILURE;
  obj   = FAILURE;

  sprintf (name, FREETXT (FDATABAS), mask_spec->db->base->basename);

  switch (db_status (mask_spec->db->base))
  {
    case DB_CNOTUNIQUE :
    case DB_CNOINSERT  :
    case DB_CNODELETE  :
    case DB_CNOUPDATE  : switch (db_status (mask_spec->db->base))
                         {
                           case DB_CNOTUNIQUE : p = alerts [ERR_INXNOTUNIQUE]; break;
                           case DB_CNOINSERT  : p = alerts [ERR_NOINSERT];     break;
                           case DB_CNODELETE  : p = alerts [ERR_NODELETE];     break;
                           case DB_CNOUPDATE  : p = alerts [ERR_NOUPDATE];     break;
                         } /* switch */
                         db_indexinfo (mask_spec->db->base, table, status, &index_info);
                         sprintf (s, p, name, (*index_info.name != EOS) ? index_info.name : index_info.indexname);
                         open_alert (s);
                         field = index_info.inxcols.cols [0].col;
                         break;
    case DB_CNULLCOL   : db_fieldinfo (mask_spec->db->base, table, status, &field_info);
                         sprintf (s, alerts [ERR_COLNULL], name, field_info.name);
                         open_alert (s);
                         field = status;
                         break;
    default            : dbtest (mask_spec->db);
                         break;
  } /* switch */

  if (field != FAILURE)   /* search for edit object number */
  {
    ed_field = mask_spec->ed_field;

    for (obj = 0; obj < mask_spec->edobjs; obj++, ed_field++)
      if ((ed_field->table == table) && (ed_field->field == field)) break;

    if (obj == mask_spec->edobjs) obj = 0;	/* field not in mask, take edit object #0 */
  } /* if */

  return (obj);
} /* test_rec */

/*****************************************************************************/

LOCAL BOOL test_bounds (BASE *base, WORD table, WORD field, VOID *buffer, BOOLEAN show_error, LONG lower, LONG upper)
{
  BOOLEAN    ok;
  BOOLEAN    lower_null, upper_null;
  WORD       w, type;
  LONG       l;
  DOUBLE     d;
  STRING     slower, supper;
  LONGSTR    s;
  FIELD_INFO field_info;
  VOID       *value;

  db_fieldinfo (base, table, field, &field_info);
  type = field_info.type;

  if (is_null (field_info.type, (BYTE *)buffer + field_info.addr)) return (TRUE);
  if ((type != TYPE_WORD) && (type != TYPE_LONG) && (type != TYPE_FLOAT)) return (TRUE);

  value      = (BYTE *)buffer + field_info.addr;
  lower_null = is_null (TYPE_LONG, &lower);
  upper_null = is_null (TYPE_LONG, &upper);
  ok         = TRUE;

  switch (type)
  {
    case TYPE_WORD  : w = *(WORD *)value;
                      if (! lower_null && (w < lower)) ok = FALSE;
                      if (! upper_null && (w > upper)) ok = FALSE;
                      break;
    case TYPE_LONG  : l = *(LONG *)value;
                      if (! lower_null && (l < lower)) ok = FALSE;
                      if (! upper_null && (l > upper)) ok = FALSE;
                      break;
    case TYPE_FLOAT : d = *(DOUBLE *)value;
                      if (! lower_null && (d < lower)) ok = FALSE;
                      if (! upper_null && (d > upper)) ok = FALSE;
                      break;
  } /* switch */

  if (! ok && show_error)
  {
    sprintf (slower, "%ld", lower);
    sprintf (supper, "%ld", upper);

    if (lower_null) strcpy (slower, "-");
    if (upper_null) strcpy (supper, "-");

    sprintf (s, alerts [ERR_NOTINBOUND], field_info.name, slower, supper);
    open_alert (s);
  } /* if */

  return (ok);
} /* test_bounds */

/*****************************************************************************/

LOCAL WORD get_cols (BASE *base, WORD table, BYTE *colstr, WORD *cols)
{
  WORD       num_cols, col;
  BYTE       field_sep [2];
  LONGSTR    s;
  FIELD_INFO field_info;
  BYTE       *p, *name;

  field_sep [0] = CHR_FIELDSEP;
  field_sep [1] = EOS;

  strcpy (s, colstr);
  strcat (s, field_sep);
  num_cols = 0;
  name     = s;
  p        = strchr (name, CHR_FIELDSEP);

  while ((p != NULL) && (num_cols < MAX_INXCOLS))
  {
    *p = EOS;
    strcpy (field_info.name, name);
    name = ++p;

    col = db_fieldinfo (base, table, FAILURE, &field_info);
    if (col == FAILURE) return (0);
    cols [num_cols++] = col;
    p = strchr (name, CHR_FIELDSEP);
  } /* while */

  return (num_cols);
} /* get_cols */

/*****************************************************************************/

LOCAL VOID check_where (BYTE *s)
{
  if (strlen (s) > 40)	/* 40 chars significance is enough for where conditions */
  {
    s [39] = WILD_CHARS;
    s [40] = EOS;
  } /* if */

  while (*s)
  {
    if (*s == CHR_STRDEL) *s = WILD_CHAR;	/* matches any character */
    s++;
  } /* while */
} /* check_where */

/*****************************************************************************/

LOCAL VOID do_button (MASK_SPEC *mask_spec, WORD command, CHAR *param, WORD obj, MKINFO *mk)
{
  BOOLEAN    ok, modify, conv;
  WORD       act_obj, title, item;
  WORD       msgbuff [8];
  TABLE_INFO table_info;
  WINDOWP    window;
  MASK_SPEC  *sub_spec;

  window      = mask_spec->window;
  sub_spec    = m_get_mask_spec (mask_spec);
  alert_shown = FALSE;
  conv        = FALSE;
  act_obj     = sub_spec->act_obj;

  if ((MB_PREV <= command) && (command <= MB_LAST))
    if (mask_spec->any_dirty)
    {
      conv = TRUE;
      if (! m_save_rec (sub_spec, &act_obj, TRUE)) return;
      alert_shown = TRUE;
      set_redraw (window, &window->scroll);
    } /* if, if */

  modify = (obj == MISAVE);

  if (act_obj >= 0)
  {
    set_clip (TRUE, &window->scroll);
    m_edit_obj (sub_spec, MO_HIDECURSOR, 0, NULL);
    if (! conv) ok = m_ed2field (sub_spec, sub_spec->act_obj, FALSE);

    if (ok || ! modify)
    {
      m_edit_obj (sub_spec, MO_EXIT, 0, NULL);
      sub_spec->act_obj = FAILURE;
    } /* if */
    else
    {
      m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
      return;
    } /* else */
  } /* if */

  title = comm2menu [command].title;
  item  = comm2menu [command].item;

  if ((command == MB_FIRST) || (command == MB_LAST)) mk->breturn = 2;	/* simulate double click on prev/next */

  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);

  switch (command)
  {
    case MB_SAVE        : m_save (mask_spec, &act_obj, mk);
                          break;
    case MB_INSERT      : m_insert (mask_spec, &act_obj);
                          break;
    case MB_UPDATE      : m_update (mask_spec, &act_obj);
                          break;
    case MB_SEARCH      : m_search (mask_spec, act_obj, mk);
                          break;
    case MB_DELETE      : m_delete (mask_spec);
                          break;
    case MB_CALC        : m_calc (mask_spec, obj);
                          break;
    case MB_CLEAR       : m_clear (mask_spec, M_SET_NULL, TRUE);
                          break;
    case MB_FIRST       : mk->breturn = 2;			/* simulate double click on prev/next and fall through */
    case MB_PREV        : m_next (mask_spec, -mask_spec->dir, mk);
                          break;
    case MB_LAST        : mk->breturn = 2;			/* simulate double click on prev/next and fall through */
    case MB_NEXT        : m_next (mask_spec, mask_spec->dir,  mk);
                          break;
    case MB_CHANGE      : break;				/* not implemented */
    case MB_JOIN_MASK   :
    case MB_JOIN_TABLE  :
    case MB_JOIN_NEW    : button_join (mask_spec, command, param);
                          break;
    case MB_REPORT      : button_report (mask_spec, param, DEV_SCREEN);
                          break;
    case MB_PRINT       : button_account (mask_spec, table_info.name, DEV_PRINTER);
                          break;
    case MB_USERHELP    : open_help (FREETXT (FHELPBAS), app_path, param);
                          break;
    case MB_WINFULL     : 
    case MB_WINCLOSE    : mem_set (msgbuff, 0, sizeof (msgbuff));
                          msgbuff [0] = (command == MB_WINFULL) ? WM_FULLED : WM_CLOSED;
                          msgbuff [1] = gl_apid;
                          msgbuff [3] = window->handle;
                          appl_write (gl_apid, sizeof (msgbuff), msgbuff);
                          break;
    case MB_QUERY_MASK  :
    case MB_QUERY_TABLE : button_query (mask_spec, command, param);
                          break;
    case MB_BATCH       : button_batch (mask_spec, param);
                          break;
    case MB_MULTIBUTTON : button_multi (mask_spec, param, mk);
                          break;
    case MB_ACCOUNT     : button_account (mask_spec, param, DEV_SCREEN);
                          break;
/* [GS] 5.1d */
    case MB_USERHELPST	: user_help ( param );
    											break;
/* Ende */
    default             : mask_menu (window, title, item);
  } /* switch */

  if (table_info.recs <= 1)
   if (v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor))
     v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir);

  sub_spec = m_get_mask_spec (mask_spec);	/* sub_spec could have been changed in m_clear */
  m_ed_index (sub_spec, act_obj, 1, NULL);
  m_edit_obj (sub_spec, MO_SHOWCURSOR, 0, NULL);
} /* do_button */

/*****************************************************************************/

LOCAL VOID button_calc (MASK_SPEC *mask_spec, WORD obj)
{
  BOOLEAN    found;
  WORD       err, field, i;
  TABLE_INFO table_info;
  CALCOBJ    *calcobj;

  calcobj = mask_spec->calcobj;
  found   = FALSE;

  for (i = 0; (i < mask_spec->calcobjs) && ! found; i++, calcobj++)
    if (calcobj->obj == obj)
    {
      found = TRUE;
      break;
    } /* if, for */

  if (! found) return;

  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);

  for (field = 1; field <table_info.cols; field++)
    m_test_null (mask_spec->db->base, rtable (mask_spec->table), field, mask_spec->buffer, FALSE);

  err = v_execute (mask_spec->db, mask_spec->table, &calcobj->code, mask_spec->buffer, 0L, NULL);

  if (err != SUCCESS) hndl_alert (err);

  m_change_buffer (mask_spec);		/* show new changed buffer */
  m_setdirty (mask_spec, TRUE);
} /* button_calc */

/*****************************************************************************/

LOCAL VOID button_join (MASK_SPEC *mask_spec, WORD command, BYTE *param)
{
  WORD       src_tbl, src_col, src_inx, src_type;
  WORD       dst_tbl, dst_col, dst_inx, dst_type;
  WORD       src_cols [MAX_INXCOLS], dst_cols [MAX_INXCOLS];
  WORD       i, dir, num_srccols, num_dstcols;
  LONGSTR    where, order;
  STRING     src_str, dst_str;
  LONGSTR    s, t, sql;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  INDEX_INFO index_info;
  SQL_RESULT sql_result;
  BYTE       *p, *q;
  DB         *db;

  db      = mask_spec->db;
  src_tbl = rtable (mask_spec->table);
  dir     = ASCENDING;

  strcpy (s, param);
  q = s;
  p = strchr (q, CHR_ORDERSEP);

  if (p != NULL)
  {
    *p = EOS;
    p++;
    strcpy (order, p);
  } /* if */
  else
    order [0] = EOS;

  p = strchr (q, CHR_BRANCH);

  if (p == NULL)
  {
    hndl_alert (ERR_BRANCHSEP);
    return;
  } /* if */

  *p = EOS;
  p++;
  strcpy (t, q);
  str_rmchar (t, ' ');
  strcpy (src_str, t);
  strcpy (field_info.name, t);
  strcpy (index_info.name, t);

  if (command == MB_JOIN_NEW)   /* use format col1, col2,... */
  {
    num_srccols = get_cols (db->base, src_tbl, t, src_cols);
    if (num_srccols == 0)
    {
      src_col = FAILURE;
      src_inx = FAILURE;
    } /* if */
    else
    {
      src_col = db_fieldinfo (db->base, src_tbl, src_cols [0], &field_info);
      src_inx = db_indexinfo (db->base, src_tbl, FAILURE, &index_info);
    } /* else */
  } /* if */
  else
  {
    src_col = db_fieldinfo (db->base, src_tbl, FAILURE, &field_info);
    src_inx = db_indexinfo (db->base, src_tbl, FAILURE, &index_info);

    if (src_inx != FAILURE)
      num_srccols = get_inxcols (db->base, src_tbl, src_inx, src_cols);
    else
    {
      num_srccols  = 1;
      src_cols [0] = src_col;
    } /* if */
  } /* else */

  if ((src_col == FAILURE) && (src_inx == FAILURE))
  {
    sprintf (s, alerts [ERR_SRCINX], t);
    open_alert (s);
    return;
  } /* if */

  src_type = (src_inx == FAILURE) ? field_info.type : index_info.type;
  q        = p;
  p        = strchr (q, CHR_TBLSEP);

  if (p == NULL)
  {
    hndl_alert (ERR_TBLSEP);
    return;
  } /* if */

  *p = EOS;
  p++;

  strcpy (table_info.name, q);
  str_rmchar (table_info.name, ' ');
  dst_tbl = db_tableinfo (db->base, FAILURE, &table_info);

  if (dst_tbl == FAILURE)
  {
    sprintf (s, alerts [ERR_DSTTBL], table_info.name);
    open_alert (s);
    return;
  } /* if */

  q = p;
  strcpy (t, q);
  str_rmchar (t, ' ');
  strcpy (dst_str, t);
  strcpy (field_info.name, t);
  strcpy (index_info.name, t);

  if (command == MB_JOIN_NEW)   /* use format col1, col2,... */
  {
    num_dstcols = get_cols (db->base, dst_tbl, t, dst_cols);
    if (num_dstcols == 0)
    {
      dst_col = FAILURE;
      dst_inx = FAILURE;
    } /* if */
    else
    {
      dst_col = db_fieldinfo (db->base, dst_tbl, dst_cols [0], &field_info);
      dst_inx = db_indexinfo (db->base, dst_tbl, FAILURE, &index_info);
    } /* else */
  } /* if */
  else
  {
    dst_col = db_fieldinfo (db->base, dst_tbl, FAILURE, &field_info);
    dst_inx = db_indexinfo (db->base, dst_tbl, FAILURE, &index_info);

    if (dst_inx != FAILURE)
      num_dstcols = get_inxcols (db->base, dst_tbl, dst_inx, dst_cols);
    else
    {
      num_dstcols  = 1;
      dst_cols [0] = dst_col;
    } /* if */
  } /* else */

  if ((dst_col == FAILURE) && (dst_inx == FAILURE))
  {
    sprintf (s, alerts [ERR_DSTINX], t);
    open_alert (s);
    return;
  } /* if */

  dst_type = (dst_inx == FAILURE) ? field_info.type : index_info.type;

  if (src_type != dst_type)
  {
    hndl_alert (ERR_INXTYPE);
    return;
  } /* if */

  if (num_srccols != num_dstcols)
  {
    sprintf (s, alerts [ERR_INXCOLS], src_str, dst_str);
    open_alert (s);
    return;
  } /* if */

  if (dst_inx == FAILURE) dst_inx = 0;
  db_fillnull (db->base, dst_tbl, db->buffer);
  where [0] = EOS;

  for (i = 0; i < num_srccols; i++)     /* build sql WHERE condition */
  {
    db_fieldinfo (db->base, dst_tbl, dst_cols [i], &field_info);
    p = (BYTE *)db->buffer + field_info.addr;
    db_getfield (db->base, src_tbl, src_cols [i], mask_spec->buffer, p);
    col2str (db, src_tbl, mask_spec->buffer, src_cols [i], 0, t);

    if (HASWILD (field_info.type))
    {
      strncpy (t, p, LONGSTRLEN);		/* use original string (col2str expands \r\n to blanks) */
      check_where (t);				/* remove special chars like ' */
      sprintf (s, "%s = '%s'", field_info.name, t);
    } /* if */
    else
    {
      if (t [0] == EOS) strcpy (t, "''");       /* is NULL */
      sprintf (s, "%s = %s", field_info.name, t);
    } /* else */

    strcat (where, s);
    if (i < num_srccols - 1) strcat (where, " AND ");
  } /* for */

  sprintf (sql, "SELECT * FROM %s WHERE %s %s;", table_info.name, where, order);
  where [STRLEN] = EOS;
  str_rmchar (where, ' ');

  switch (command)
  {
    case MB_JOIN_MASK  : sql_exec (db, sql, where, FALSE, &sql_result);
                         if (sql_result.columns != NULL)
                         {
                           mem_free (sql_result.columns);
                           open_mask (NIL, db, sql_result.table, sql_result.inx, sql_result.dir, "", NULL, 0L, NULL, NULL, FALSE);
                           if (VTBL (sql_result.table)) free_vtable (sql_result.table);
                           if (VINX (sql_result.inx)) free_vindex (sql_result.inx);
                         } /* if */
                         break;
    case MB_JOIN_NEW   : open_mask (NIL, db, dst_tbl, dst_inx, dir, "", NULL, 0L, db->buffer, NULL, TRUE);
                         break;
    case MB_JOIN_TABLE : sql_exec (db, sql, where, TRUE, NULL);
                         break;
  } /* switch */
} /* button_join */

/*****************************************************************************/

LOCAL VOID button_report (MASK_SPEC *mask_spec, BYTE *param, WORD device)
{
  BOOLEAN    ok;
  WORD       inx, dir, vtable;
  STRING     reportname;
  LONGSTR    s;
  FULLNAME   filename;
  TABLE_INFO table_info;
  CURSOR     cursor;
  BYTE       *p, *q, *report, *prn;
  DB         *db;
  VTABLE     *vtablep;
  SYSREPORT  *sysreport;

  db  = mask_spec->db;
  dir = ASCENDING;
  prn = NULL;

  if (is_null (TYPE_DBADDRESS, mask_spec->buffer))
  {
    hndl_alert (ERR_RECINVALID);
    return;
  } /* if */

  strcpy (s, param);
  q = s;
  p = strchr (q, CHR_REPSEP);

  if (p != NULL)
  {
    *p = EOS;
    p++;
    strcpy (filename, p);

    prn = strchr (filename, CHR_REPSEP);

    if (prn != NULL)
    {
      *prn = EOS;
      prn++;
    } /* if */
  } /* if */
  else
    filename [0] = EOS;

  if (strlen (filename) == 1)
  {
    switch (ch_upper (filename [0]))
    {
      case 'S' : device = DEV_SCREEN;  break;
      case 'P' : device = DEV_PRINTER; break;
      default  : device = FAILURE;     break;
    } /* switch */

    filename [0] = EOS;
  } /* if */

  strcpy (reportname, q);

  sysreport = db->buffer;
  report    = sysreport->report;
  inx       = 1;                /* index is SYSREPORT.name */
  strcpy (sysreport->name, reportname);

  ok = db_search (db->base, SYS_REPORT, inx, ASCENDING, &cursor, sysreport, 0L);
  ok = ok && db_read (db->base, SYS_REPORT, sysreport, &cursor, 0L, FALSE);

  if (! ok)
  {
    sprintf (s, alerts [ERR_NOREPORT], reportname);
    open_alert (s);
    dbtest (db);
    return;
  } /* if */

  db_tableinfo (db->base, rtable (mask_spec->table), &table_info);
  vtable = new_vtable (db, rtable (mask_spec->table), 1, table_info.cols);

  if (vtable != FAILURE)
  {
    vtablep = VTABLEP (vtable);

    vtablep->recaddr [0] = DB_ADR (mask_spec->buffer);
    vtablep->recs        = 1;

    do_report (db, vtable, mask_spec->inx, dir, report, filename, device, minimize, 1, prn);

    free_vtable (vtable);
  } /* if */
} /* button_report */

/*****************************************************************************/

LOCAL VOID button_query (MASK_SPEC *mask_spec, WORD command, BYTE *param)
{
  WORD       table, i, num_cols;
  WORD       fields [MAX_INXCOLS];
  STRING     order, cols;
  LONGSTR    s, t;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  SQL_RESULT sql_result;
  EDFIELD    *ed_field;
  BYTE       *p, *q, *where, *sql;
  DB         *db;

  db    = mask_spec->db;
  table = rtable (mask_spec->table);
  where = db->buffer;

  db_tableinfo (db->base, table, &table_info);

  strcpy (s, param);
  q = s;
  p = strchr (q, CHR_ORDERSEP);

  if (p != NULL)
  {
    *p = EOS;
    p++;
    strcpy (order, p);
  } /* if */
  else
    order [0] = EOS;

  if (*q == EOS)
    strcpy (cols, "*");
  else
    strcpy (cols, q);

  ed_field = mask_spec->ed_field;
  num_cols = 0;

  for (i = 0; i < mask_spec->edobjs; i++, ed_field++)   /* get all fields != NULL */
  {
    if (ed_field->mfield->class == M_SUBMASK) continue;
    db_fieldinfo (db->base, table, ed_field->field, &field_info);

    if (! is_null (field_info.type, (BYTE *)mask_spec->buffer + field_info.addr) && PRINTABLE (field_info.type))
      fields [num_cols++] = ed_field->field;
  } /* for */

  if (num_cols == 0) return;

  where [0] = EOS;

  for (i = 0; i < num_cols; i++)        /* build sql WHERE condition */
  {
    db_fieldinfo (db->base, table, fields [i], &field_info);
    col2str (db, table, mask_spec->buffer, fields [i], 0, t);
    p = (BYTE *)mask_spec->buffer + field_info.addr;

    if (HASWILD (field_info.type))
    {
      strncpy (t, p, LONGSTRLEN);	/* use original string (col2str expands \r\n to blanks) */
      check_where (t);			/* remove special chars like ' */
      sprintf (s, "%s = '%s'", field_info.name, t);
    } /* if */
    else
      sprintf (s, "%s = %s", field_info.name, t);

    strcat (where, s);
    if (i < num_cols - 1) strcat (where, " AND ");
  } /* for */

  sql = mem_alloc (table_info.size + 256); /* leave some room for SELECT etc. */

  if (sql == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return;
  } /* if */

  sprintf (sql, "SELECT %s FROM %s WHERE %s %s;", cols, table_info.name, where, order);
  str_rmchar (where, ' ');
  where [STRLEN] = EOS;

  switch (command)
  {
    case MB_QUERY_MASK  : sql_exec (db, sql, where, FALSE, &sql_result);
                          if (sql_result.columns != NULL)
                          {
                            mem_free (sql_result.columns);
                            open_mask (NIL, db, sql_result.table, sql_result.inx, sql_result.dir, "", NULL, 0L, NULL, NULL, FALSE);
                            if (VTBL (sql_result.table)) free_vtable (sql_result.table);
                            if (VINX (sql_result.inx)) free_vindex (sql_result.inx);
                          } /* if */
                          break;
    case MB_QUERY_TABLE : sql_exec (db, sql, where, TRUE, NULL);
                          break;
  } /* switch */

  mem_free (sql);
} /* button_query */

/*****************************************************************************/

LOCAL VOID button_batch (MASK_SPEC *mask_spec, BYTE *param)
{
  exec_batch (mask_spec->db, param);
} /* button_batch */

/*****************************************************************************/

LOCAL VOID button_multi (MASK_SPEC *mask_spec, BYTE *param, MKINFO *mk)
{
  WORD      i;
  LONGSTR   s;
  BYTE      *p, *q, *t;
  BUTTON    *button;
  MASK_SPEC *sub_spec;
  MBUTTON   *mbutton;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;

  sysmask  = mask_spec->mask;
  sub_spec = m_get_mask_spec (mask_spec);

  strcpy (s, param);

  p = s;

  while ((p != NULL) && (*p != EOS))
  {
    q = strchr (p, CHR_MULTISEP);

    if (q != NULL)
    {
      *q = EOS;
      q++;
      while (*q == ' ') q++;	/* eat leading spaces */
    } /* if */

    button = mask_spec->button;

    for (i = 0; i < mask_spec->buttons; i++, button++)
    {
      mobject  = (MOBJECT *)sysmask->mask.buffer;
      mobject  = &mobject [button->obj];
      mbutton  = &mobject->mbutton;
      t        = &sysmask->mask.buffer [mbutton->text];

      if (strcmp (p, t) == 0)
        hndl_button (mask_spec, sub_spec, button->obj, mk);
    } /* for */

    p = q;
  } /* while */
} /* button_multi */

/*****************************************************************************/

LOCAL VOID button_account (MASK_SPEC *mask_spec, BYTE *param, WORD device)
{
  WORD       dir, vtable;
  STRING     accountname;
  LONGSTR    s;
  FULLNAME   filename;
  TABLE_INFO table_info;
  BYTE       *p, *q;
  DB         *db;
  VTABLE     *vtablep;

  db  = mask_spec->db;
  dir = ASCENDING;

  if (is_null (TYPE_DBADDRESS, mask_spec->buffer))
  {
    hndl_alert (ERR_RECINVALID);
    return;
  } /* if */

  strcpy (s, param);
  q = s;
  p = strchr (q, CHR_REPSEP);

  if (p != NULL)
  {
    *p = EOS;
    p++;
    strcpy (filename, p);
  } /* if */
  else
    filename [0] = EOS;

  if (strlen (filename) == 1)
  {
    switch (ch_upper (filename [0]))
    {
      case 'S' : device = DEV_SCREEN;  break;
      case 'P' : device = DEV_PRINTER; break;
      default  : device = FAILURE;     break;
    } /* switch */

    filename [0] = EOS;
  } /* if */

  strcpy (accountname, q);

  db_tableinfo (db->base, rtable (mask_spec->table), &table_info);
  vtable = new_vtable (db, rtable (mask_spec->table), 1, table_info.cols);

  if (vtable != FAILURE)
  {
    vtablep = VTABLEP (vtable);

    vtablep->recaddr [0] = DB_ADR (mask_spec->buffer);
    vtablep->recs        = 1;

    AccountNameExec (accountname, db, vtable, mask_spec->inx, dir, device, minimize, 1);

    free_vtable (vtable);
  } /* if */
} /* button_account */

/*****************************************************************************/

LOCAL LONG sb_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p)
{
  SUBMASK *submask;

  submask = (SUBMASK *)ScrollBar_GetSpec ((HSB)tree);

  switch (msg)
  {
    case SBN_CHANGED : if (submask->flags & MSM_SHOW_TABLE)
                           sb_scroll_list (submask, submask->doc.y, item);
                         else
                           sb_scroll_mask (submask, submask->doc.y, item);
                       break;
  } /* switch */

  return (0L);
} /* sb_callback */

/*****************************************************************************/

LOCAL VOID sb_scroll_list (SUBMASK *submask, LONG old_pos, LONG new_pos)
{
  LONG    max_pos, delta;
  RECT    r, rc, scroll;
  BOOLEAN fits;
  WINDOWP window;

  window    = submask->pMaskSpec->window;
  scroll    = submask->frame;
  scroll.y += submask->yscroll;
  scroll.h -= submask->yscroll;

  rc = window->scroll;
  rc_intersect (&rc, &scroll);

  ScrollBar_GetRect (submask->hsb, &rc);
  scroll.w -= rc.w;

  max_pos = submask->doc.h - scroll.h / submask->yfac;
  r       = scroll;

  rc_intersect (&desk, &r);
  fits = rc_equal (&r, &scroll);			/* fits into desktop completely */

  if (max_pos < 0) max_pos = 0;

  if (new_pos > max_pos) new_pos = max_pos;
  if (new_pos < 0) new_pos = 0;

  submask->doc.y = new_pos;

  delta = new_pos - old_pos;

  if (delta != 0)
  {
    if ((labs (delta) >= (LONG)scroll.h / submask->yfac) || ! fits)
    {
      set_clip (TRUE, &scroll);
      redraw_window (window, &scroll);
    } /* if */
    else
    {
      r  = scroll;

      if (delta > 0)
      {
        r.y += (WORD)(submask->yfac * delta);
        r.h -= (WORD)(submask->yfac * delta);
        scroll_area (&r, VERTICAL, (WORD)(submask->yfac * delta));

        r = scroll;
        r.y += r.h - submask->yfac * delta;
        r.h  = submask->yfac * delta;
        set_clip (TRUE, &r);
        redraw_window (window, &r);
      } /* if */
      else
      {
        r.h += (WORD)(submask->yfac * delta);
        scroll_area (&r, VERTICAL, (WORD)(submask->yfac * delta));

        r   = scroll;
        r.h = submask->yfac * labs (delta);
        set_clip (TRUE, &r);
        redraw_window (window, &r);
      } /* else */
    } /* else */
  } /* if */
} /* sb_scroll_list */

/*****************************************************************************/

LOCAL VOID sb_scroll_mask (SUBMASK *submask, LONG old_pos, LONG new_pos)
{
  BOOLEAN   ok;
  WORD      h;
  RECT      rc;
  STRING    s;
  WINDOWP   window;
  MASK_SPEC *mask_spec;

  mask_spec = submask->pMaskSpec;

  sprintf (s, " %ld/%ld ", new_pos + 1, submask->doc.h);
  rc = m_calc_sm_attr (vdi_handle, submask, &submask->frame, SM_ATTR_RECCOUNT, &h);

  rc.x += 1;
  rc.y += 1;
  rc.w -= 2;
  rc.h -= 2;

  window = submask->pMaskSpec->window;
  set_clip (TRUE, &window->scroll);
  DrawString (vdi_handle, &rc, &clip, s, FAILURE, NORMAL | SS_CENTER | SS_OUTSIDE, FAILURE, NULL);

  ok = v_movecursor (mask_spec->db, mask_spec->cursor, new_pos - old_pos);

  m_edit_obj (mask_spec, MO_HIDECURSOR, 0, NULL);

  if (ok)
  {
    m_exit_rec (mask_spec, M_SET_NULL, TRUE, FALSE);
    m_vread (mask_spec, mask_spec->table, mask_spec->buffer, mask_spec->cursor, 0L, TRUE);
    m_exit_pic (mask_spec, FAILURE);
    if (! alert_shown) m_all_fields (mask_spec, FALSE, FALSE);
    submask->doc.y = new_pos;
    m_ed_index (mask_spec, mask_spec->act_obj, 1, NULL);
  } /* if */

  m_edit_obj (mask_spec, MO_SHOWCURSOR, 0, NULL);
} /* sb_scroll_mask */

/*****************************************************************************/

#define malloc(l) Mxalloc (l, 0);
#define free(l) Mfree (l);

void change_vorz(SOUNDINFO *si);
void get_pfad(char *p);
int fselect(char *pfad,char *fname, char *ext, char *text);
int load_sound(SOUNDINFO *sin, char *path);
void change_freq(SOUNDINFO *si, long new_freq, int nstereo, int nbitsps);

/* LOAD_SND.C
 *
 * Routinen zum Laden diverser Sampelformate:
 * HSN, AVR, SMP, SND, IFF, WAV, VOC und Unbekannte
 *
 * (c)1995 by Richard Kurz, Vogelherdbogen 62, 88069 Tettnang
 *
 * Maus @ LI
 * Compuserve 100025,2263
 *
 */

/*
#include <aes.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "load_snd.h"
*/

#define E_MEM       -1
#define E_8BIT      -2
#define E_NOPEN     -4
#define E_UNKNOWN   -5

static char puffer[512];

static int load_hsn(int fp, SOUNDINFO *sin)
{
    HSN_NEW s;

    Fread(fp,sizeof(s),&s);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(s.laenge);
    if(sin->anfang==NULL) return(E_MEM);
    sin->laenge=s.laenge;
    sin->frequenz=s.frequenz;
    sin->stereo=s.stereo;
    sin->bitsps=s.bitsps;

    sin->dm_laut   = s.dm_laut;
    sin->dm_links  = s.dm_links;
    sin->dm_rechts = s.dm_rechts;
    sin->dm_hoehen = s.dm_hoehen;
    sin->dm_tiefen = s.dm_tiefen;

    Fread(fp,s.laenge,sin->anfang);
    return(0);
}/* load_hsn */

static int load_hsn_alt(int fp, SOUNDINFO *sin)
{
    HSN_ALT s;

    Fread(fp,sizeof(s),&s);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(s.laenge);
    if(sin->anfang==NULL) return(E_MEM);
    sin->laenge=s.laenge;
    sin->frequenz=s.frequenz;
    sin->stereo=s.stereo;
    sin->bitsps=s.bitsps;

    sin->dm_laut   = s.dm_laut;
    sin->dm_links  = s.dm_links;
    sin->dm_rechts = s.dm_rechts;
    sin->dm_hoehen = s.dm_hoehen;
    sin->dm_tiefen = s.dm_tiefen;

    Fread(fp,s.laenge,sin->anfang);
    return(0);
}/* load_hsn_alt */

static int load_avr(int fp, SOUNDINFO *sin)
{
    long l;
    int sign;

    Fread(fp,0x80L,puffer);
                       
    l= *((long*) &puffer[26]);
    if(puffer[15]>8)
    {
        sin->bitsps=16;
        l*=2;
    }
    if(puffer[12])
    {
        sin->stereo=TRUE;
        l*=2;
    }
    else sin->stereo=FALSE;
    sign=puffer[17];
	
    sin->laenge=l;
    puffer[22]=0;
    sin->frequenz=(int)(*((long*) &puffer[22])/10);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL) return(E_MEM);
    Fread(fp,l,sin->anfang);
    if(!sign) change_vorz(sin);
    return(0);
} /* load_avr */

static int load_smp(int fp, SOUNDINFO *sin)
{
    long l;

    Fread(fp,8L,puffer);                   
    l=(long)(*((int*)&puffer[4]) + *((int*)&puffer[6]));
    Fread(fp,l,&puffer[8]);
    if((int)puffer[16]!=8)  return(E_8BIT);
    sin->laenge=l= *((long*) &puffer[8]);
    sin->stereo=(int)puffer[23]-1;
    sin->frequenz=(int)(*((long*) &puffer[18])/10L);

    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    change_vorz(sin);
    return(0);
} /* load_smp */

static int load_snd(int fp, SOUNDINFO *sin)
{
    long l;

    l=Fseek(0,fp,2)-10;
    Fseek(0,fp,0);
    Fread(fp,10L,puffer);                   

    sin->laenge=l;
    if(puffer[9]&0x80)
    {
        sin->stereo=FALSE;
        puffer[9]&=~0x80;
    }
    else
    {
        sin->stereo=TRUE;
    }
    switch(puffer[9])
    {
        case 0: sin->frequenz=625; break;
        case 1: sin->frequenz=1250; break;
        case 2: sin->frequenz=2500; break;
        case 3: sin->frequenz=5000; break;
        default: sin->frequenz=1250; break;
    }
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    return(0);
} /* load_snd */

static int load_iff(int fp, SOUNDINFO *sin)
{
    long l,i,j;

    Fseek(0,fp,0);
    Fread(fp,48L,puffer);                   

    sin->frequenz=(*(int*)&puffer[32])/10;
    if(*((long*)&puffer[40])!='BODY')
    {
        l=(*(long*)&puffer[44]);l+=l%2;
        for(i=0;i<10;i++)
        {
            if(l>510) return(E_UNKNOWN);
            Fread(fp,l+8L,puffer);                   
            if(*((long*)&puffer[l])=='BODY')
            {
                j=l+4;
                break;
            }
            l=(*(long*)&puffer[l+4]);l+=l%2;
        }
    }
    else j=44;
    sin->laenge=l=(*(long*)&puffer[j]);
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    return(0);
} /* load_iff */

static int load_blob(int fp, SOUNDINFO *sin)
{
    long l;

    l=Fseek(0,fp,2);
    Fseek(0,fp,0);
    sin->laenge=l;
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL) return(E_MEM);
    Fread(fp,l,sin->anfang);
    return(0);
} /* load_blob */

/* Konvertierungsroutinen --> Intel nach Motorola */

static long l_i2m(char *s)
/* Intel LONG nach Motorola LONG */
{
    char p[4];
    
    p[0]=s[3];
    p[1]=s[2];
    p[2]=s[1];
    p[3]=s[0];
    
    return(*((long*)p));
}/* l_i2m */

static long l3_i2m(char *s)
/* Intel 3Byte-Zahl nach Motorola LONG */
{
    char p[4];
    
    p[0]=0;
    p[1]=s[2];
    p[2]=s[1];
    p[3]=s[0];
    
    return(*((long*)p));
}/* l3_i2m */

static int w_i2m(char *s)
/* Intel WORD nach Motorola WORD */
{
    char p[2];
    
    p[0]=s[1];
    p[1]=s[0];
    
    return(*((int*)p));
}/* w_i2m */

static int load_wav(int fp, SOUNDINFO *sin)
{
    long l;

    l=Fseek(0,fp,2)-48;
    Fseek(0,fp,0);
    Fread(fp,44L,puffer);                   

    if(puffer[34]>8)
    {
        sin->bitsps=16;
    }
    sin->laenge=l;
    sin->frequenz=(int)l_i2m(&puffer[24])/10;
    
    sin->stereo=puffer[22]-1;
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    Fread(fp,l,sin->anfang);
    change_vorz(sin);
    return(0);
} /* load_wav */

static int load_voc(int fp, SOUNDINFO *sin)
{
    long l,ss,i,ofs;
    int ok,first=TRUE;
    char *z;
    
    Fseek(0,fp,0);

    Fread(fp,25L,puffer);                   
    ofs=w_i2m(&puffer[20]);
    if(puffer[22]>10 || puffer[23]!=01) return(E_UNKNOWN);

    Fseek(ofs,fp,0);
    l=0;
    for(ok=TRUE;ok;)
    {
        Fread(fp,1,puffer);
        switch(puffer[0])
        {
            case 0:
                ok=FALSE;break;
            case 1:
                Fread(fp,5,puffer);
                ss=l3_i2m(puffer)-2;
                if(first)
                {
                    sin->frequenz=(int)((-1000000L/((unsigned char)puffer[3]-256L))/10L);
                    first=FALSE;
                }
                l+=ss;
                if(Fseek(ss,fp,1)<0) return(E_UNKNOWN);
                break;
            case 2:
                Fread(fp,3,puffer);
                ss=l3_i2m(puffer)-2;
                l+=ss;
                if(Fseek(ss,fp,1)<0) return(E_UNKNOWN);
                break;
            case 3:
                if(Fread(fp,6,puffer)<0) return(E_UNKNOWN);
                ss=l3_i2m(puffer);
                l+=ss;
                break;
            default:
                return(E_UNKNOWN);
        }
    }
    
    sin->laenge=l;
    if(sin->anfang) free(sin->anfang);
    sin->anfang=(char *)malloc(l);
    if(sin->anfang==NULL)return(E_MEM);
    z=sin->anfang;
    
    Fseek(ofs,fp,0);
    for(ok=TRUE;ok;)
    {
        Fread(fp,1,puffer);
        switch(puffer[0])
        {
            case 0:
                ok=FALSE;break;
            case 1:
                Fread(fp,5,puffer);
                ss=l3_i2m(puffer)-2;
                if(Fread(fp,ss,z)<0) return(E_UNKNOWN);
                z+=ss;
                break;
            case 2:
                Fread(fp,3,puffer);
                ss=l3_i2m(puffer)-2;
                if(Fread(fp,ss,z)<0) return(E_UNKNOWN);
                z+=ss;
                break;
            case 3:
                if(Fread(fp,6,puffer)<0) return(E_UNKNOWN);
                ss=l3_i2m(puffer);
                for(i=0;i<ss;i++,z++) *z=0;
                break;
            default:
                return(E_UNKNOWN);
        }
    }
    change_vorz(sin);
    return(0);
} /* load_voc */


static int file_fehler(int f)
{
    int i;
    
    switch(f)
    {
        case E_8BIT:
            i=form_alert(1,"[2][|Das ist kein 8 Bit Sample!| |Trotzdem laden?][ Ja | Nein ]");
            break;
        case E_UNKNOWN:
            i=form_alert(1,"[2][|Unbekanntes Sample-Format!| |Trotzdem laden?][ Ja | Nein ]");
            break;
        case E_MEM:
            form_alert(1,"[3][|Nicht genug Speicher frei!][ Abbruch ]");
            return(FALSE);
        case E_NOPEN:
            form_alert(1,"[3][|Datei konnte nicht|ge”ffnet werden!][ Abbruch ]");
            return(FALSE);
        default: 
            form_alert(1,"[3][|Allgemeiner Fehler!][ Abbruch ]");
            return(FALSE);
    }
    if(i==1) return(TRUE);
    return(FALSE);
}/* file_fehler */


void change_vorz(SOUNDINFO *si)
/* Macht aus signed Samples unsigned und zurck */
{
    long i;
    char *p;
    int *wp;
    
    if(si->bitsps<=8)
    {   
        for(i=0,p=si->anfang;i<si->laenge;i++)
            p[i]^=0x80;
    }
    else
    {
        for(i=0,wp=(int *)si->anfang;i<(si->laenge/2);i++)
            wp[i]^=0x8000;
    }
        
}/* change_vorz */

void get_pfad(char *p)
/* L„dt den kompletten Zugriffs-Pfad.                           */
{
    static char tp[128];
    
    Dgetpath(tp,0);
    if(tp[strlen(tp)-1]!='\\') strcat(tp,"\\");
    strcpy(&p[2],tp);
    p[0]='A'+Dgetdrv(); p[1]=':';
} /* get_pfad */

int fselect(char *pfad,char *fname, char *ext, char *text)
/* Komfortion”se Datei-Auswahl.                                 */
{
    int ok,knopf;
    char *s;
    
    s=strrchr(pfad,'\\');
    if(s!=NULL) strcpy(++s,"*.");
    else strcpy(pfad,"*.");
    strcat(pfad,ext);

    if((Sversion()>>8)<=20) ok=fsel_input(pfad,fname,&knopf);
    else ok=fsel_exinput(pfad,fname,&knopf,text);

    if(!ok || !knopf)
    {
        s=strrchr(pfad,'\\');
        if(s!=NULL) s[1]=0;
        else pfad[0]=0;
        return(FALSE);
    }
    
    s=strrchr(pfad,'\\');
    if(s != NULL) strcpy(++s,fname);
    else strcpy(pfad,fname);
    return(TRUE);
}/* fselect */

int load_sound(SOUNDINFO *sin, char *path)
/* L„dt ein Sample und gibt bei Erfolg eine positive Nummer zurck, */
/* sonst FALSE. Die Daten des Samples werden in 'sin' eingetragen.  */
/* Wird in 'path' NULL bergeben, kommt die File-Select-Box zum     */
/* Einsatz.                                                         */
{
    static char sal_pfad[256];
    static char sal_name[20];
    int fp,typ,re;
    char *s;

    if(path)
    {   
        fp=Fopen(path,0);
        if(fp<0)
        {
            file_fehler(E_NOPEN);
            return(FALSE);                     
        }
        strcpy(sal_pfad,path);
        s=strrchr(path,'\\');
        if(s) strcpy(sal_name,++s);
        else
        {
            s=strrchr(path,':');
            if(s) strcpy(sal_name,++s);
            else strcpy(sal_name,path);
        }
    }
    else
    {
        if(!sal_pfad[0]) get_pfad(sal_pfad);
        if(!fselect(sal_pfad,sal_name,"*","Sample laden"))
            return(E_MEM);
        fp=Fopen(sal_pfad,0);
        if(fp<0)
        {
            file_fehler(E_NOPEN);
            return(FALSE);                     
        }
    }
    
    memset(puffer,0,128);
    Fread(fp,128L,puffer);
    Fseek(0,fp,0);

    if(!strncmp(puffer,"HSND1.0",7))            typ=1;  /* HSN */
    else if(!strncmp(puffer,"HSND1.1",7))       typ=2;  /* HSN */
    else if(*((long*)puffer)=='2BIT')           typ=3;  /* AVR */
    else if(*((long*)puffer)==0x7E817E81L)      typ=4;  /* SMP */
    else if(*((long*)puffer)=='STE.')           typ=5;  /* SND */
    else if((*((long*)puffer)=='FORM')&&
            (*((long*)&puffer[8])=='8SVX')&&
            (*((long*)&puffer[12])=='VHDR'))    typ=6;  /* IFF */
    else if((*((long*)puffer)=='RIFF')&&
            (*((long*)&puffer[8])=='WAVE')&&
            (*((long*)&puffer[12])=='fmt '))    typ=7;  /* WAV */
    else if(!strncmp(puffer,
            "Creative Voice File\032",19))      typ=8;  /* VOC */
    else                                        typ=99; /* ??? */
        
    sin->frequenz=1250;
    sin->stereo=FALSE;
    sin->bitsps=8;

    switch(typ)
    {
        case 1: re=load_hsn_alt(fp,sin); break;
        case 2: re=load_hsn(fp,sin); break;
        case 3: re=load_avr(fp,sin); break;
        case 4: re=load_smp(fp,sin); break;
        case 5: re=load_snd(fp,sin); break;
        case 6: re=load_iff(fp,sin); break;
        case 7: re=load_wav(fp,sin); break;
        case 8: re=load_voc(fp,sin); break;
        default: re=E_UNKNOWN; break;
    }

    if(re)
    {
        if(file_fehler(re))
        {
            Fseek(0,fp,0);
            re=load_blob(fp,sin);
            if(re)
            {
                Fclose(fp);
                file_fehler(re);
                return(FALSE);
            }
        }
        else
        {
            Fclose(fp);
            return(FALSE);
        }
    }

    Fclose(fp);
    strcpy(sin->name,sal_name);

    if(sin->frequenz>6000||sin->frequenz<=0) sin->frequenz=1250;
    else if(sin->frequenz>623&&sin->frequenz<627) sin->frequenz=625;
    else if(sin->frequenz>817&&sin->frequenz<821) sin->frequenz=819;
    else if(sin->frequenz>981&&sin->frequenz<985) sin->frequenz=983;
    else if(sin->frequenz>1227&&sin->frequenz<1231) sin->frequenz=1229;
    else if(sin->frequenz>1248&&sin->frequenz<1252) sin->frequenz=1250;
    else if(sin->frequenz>1692&&sin->frequenz<1696) sin->frequenz=1694;
    else if(sin->frequenz>2075&&sin->frequenz<2079) sin->frequenz=2077;
    else if(sin->frequenz>2456&&sin->frequenz<2460) sin->frequenz=2458;
    else if(sin->frequenz>2498&&sin->frequenz<2502) sin->frequenz=2500;
    else if(sin->frequenz>3386&&sin->frequenz<3390) sin->frequenz=3388;
    else if(sin->frequenz>4915&&sin->frequenz<4919) sin->frequenz=4917;
    else if(sin->frequenz>4998&&sin->frequenz<5002) sin->frequenz=5000;

    return(typ);
}/* load_sound */

/*****************************************************************************/

#if 0
LOCAL VOID play_sound (BYTE *buffer, BOOLEAN wait)
{
#if GEMDOS
  WORD  ret, button;
  ULONG size;
  VOID  *sound;

  if (! init_sound)
  {
    Init_PH_Sound ();
    init_sound = TRUE;
  } /* if */

  size  = *(ULONG *)buffer;
  sound = buffer + 2 * sizeof (LONG);   /* size & type in first 2 longs */

  if (is_null (TYPE_VARBYTE, buffer))
  {
    Stop_PH_Sound ();
    return;
  } /* if */

  Set_PH_Sound_Volume (mask_config.volume);

  do
  {
    Play_PH_Sound (sound, size);
    graf_mkstate (&ret, &ret, &button, &ret);

    if ((button & 0x003) || wait)
      while (PH_Sound_Is_Playing ());   /* wait for end of sound */
  } while (button & 0x003);
#endif
} /* play_sound */
#endif

/*****************************************************************************/

LOCAL VOID play_sound (BYTE *buffer, BOOLEAN wait)
{
#if GEMDOS
  BOOL            ok;
  WORD            ret, button;
  LONG            file_size;
  ULONG           size;
  HFILE           f;
  VOID            *sound;
  CHAR            *pTmpFile;
  FILENAME        szFile;
  FULLNAME        szFileName;
  LOCAL SOUNDINFO si;

  if (! init_sound)
  {
    SND_init ();
    init_sound = TRUE;
  } /* if */

  size  = *(ULONG *)buffer;
  sound = buffer + 2 * sizeof (LONG);   /* size & type in first 2 longs */

  if (is_null (TYPE_VARBYTE, buffer))
  {
    SND_stop ();
    init_sound = FALSE;
    return;
  } /* if */

  pTmpFile = temp_name (NULL);

  f  = file_create (pTmpFile);
  ok = f >= 0;

  if (! ok)	/* maybe wrong tmp path, try on root of drive c: */
  {
    file_split (pTmpFile, NULL, NULL, szFile, NULL);
    sprintf (szFileName, "c:\\%s", szFile);
    pTmpFile = szFileName;

    f  = file_create (pTmpFile);
    ok = f >= 0;
  } /* if */

  if (! ok)
  {
    file_error (ERR_FILECREATE, pTmpFile);
    return;
  } /* if */
  else
  {
    file_size = file_write (f, size, sound);

    if (file_size < size)
    {
      ok = FALSE;
      file_error (ERR_FILEWRITE, pTmpFile);
    } /* if */
    else

    file_close (f);
  } /* else */

  if (! ok) return;

  if (si.anfang != NULL)
  {
    free (si.anfang);
    si.anfang = NULL;
  } /* if */

  ret = load_sound (&si, pTmpFile);

/*
  if ((ret == 1) || (ret == 2)) SND_set_vol (&si);
*/

  do
  {
    ret = SND_play (&si);
    graf_mkstate (&ret, &ret, &button, &ret);

    if ((button & 0x003) || wait)
      while (FALSE);   /* wait for end of sound */
/*      while (PH_Sound_Is_Playing ()); */
  } while (button & 0x003);

  file_remove (pTmpFile);
#endif
} /* play_sound */

/*****************************************************************************/

#undef malloc
