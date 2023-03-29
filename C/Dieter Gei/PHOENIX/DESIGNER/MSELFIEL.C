/*****************************************************************************
 *
 * Module : MSELFIEL.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.01.95
 *
 *
 * Description: This module implements the mask select field dialog box.
 *
 * History:
 * 04.01.95: Using new function names of controls module
 * 15.04.94: New transparent modus added
 * 20.11.93: Old mselfont.h replaced with CommDlg functions
 * 18.11.93: GetFontDialog used instead of mselfont
 * 16.11.93: Draw font name and size if font selected
 * 04.11.93: Static strings cause small AES stack in callback changed
 * 27.10.93: List box initialisation corrected in set_field
 * 24.10.93: New 3D listboxes used
 * 08.09.93: set_ptext -> set_str
 * 01.09.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "commdlg.h"
#include "controls.h"
#include "dialog.h"
#include "mclick.h"

#include "export.h"
#include "mselfiel.h"

/****** DEFINES **************************************************************/

#define FONTNAME_LENGTH  16     /* see resource file */
#define RB_LINES          4     /* see resource file */
#define RB_COLS          60     /* see resource file */
#define MIN_RBHEIGHT      4     /* minimal height of a radio button object */
#define CB_DELIMITER    '|'     /* delimiter for checkbox values */
#define CB_CDEF         "*|"    /* default values for checkboxes (char, word, long) */
#define CB_WDEF         "1|"
#define CB_LDEF         "1|"

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    obj;
  MFIELD  mfield;
  LONGSTR crvals;               /* checkbox/radio button values */
  WINDOWP window;               /* mask window */
} SF_SPEC;

/****** VARIABLES ************************************************************/

LOCAL SF_SPEC sf_spec;
LOCAL LONGSTR crvals;
LOCAL WORD    exit_obj;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box           _((WINDOWP window, BOOLEAN grow, WINDOWP mask_window, WORD obj));

LOCAL VOID    get_field     _((SF_SPEC *sf_spec));
LOCAL WORD    set_field     _((SF_SPEC *sf_spec, WINDOWP window, BOOLEAN show_error));
LOCAL VOID    open_field    _((WINDOWP window));
LOCAL VOID    close_field   _((WINDOWP window));
LOCAL VOID    click_field   _((WINDOWP window, MKINFO *mk));

LOCAL VOID    check_ok      _((WINDOWP window));
LOCAL BOOLEAN xget_checkbox _((OBJECT *tree, WORD obj));
LOCAL UWORD   get_flags     _((OBJECT *selfield, WORD font, WORD point));

LOCAL VOID    mrbvals       _((BYTE *values));
LOCAL VOID    get_rbvals    _((BYTE *s));
LOCAL VOID    set_rbvals    _((BYTE *s));
LOCAL VOID    click_rbvals  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_rbvals    _((WINDOWP window, MKINFO *mk));

LOCAL VOID    mcbvals       _((BYTE *values));
LOCAL VOID    get_cbvals    _((BYTE *s));
LOCAL VOID    set_cbvals    _((BYTE *s));
LOCAL VOID    click_cbvals  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_cbvals    _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID mselfield (mask_window, obj, show_error)
WINDOWP mask_window;
WORD    obj;
BOOLEAN show_error;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, SELFIELD);

  if (window == NULL)
  {
    form_center (selfield, &ret, &ret, &ret, &ret);
    window = crt_dialog (selfield, NULL, SELFIELD, FREETXT (FFIELDAT), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_field;
      window->close   = close_field;
      window->click   = click_field;
      window->special = (LONG)&sf_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = SDLABEL;
    window->edit_inx = NIL;

    sf_spec.window = mask_window;
    sf_spec.obj    = obj;

    window->edit_obj = set_field (&sf_spec, window, show_error);

    if (! open_dialog (SELFIELD)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mselfield */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LOCAL STRING s;	/* static cause small AES stack */
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)FREETXT (FMNEUTRAL + index));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 2 * gl_wbox;
                            DrawOwnerIcon (lb_ownerdraw, &r, &tbl_icon, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxGetText (tree, obj, index, s);
                          strncpy (get_str (tree, obj), s, tree [obj].ob_width / gl_wbox);
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

LOCAL VOID box (window, grow, mask_window, obj)
WINDOWP window;
BOOLEAN grow;
WINDOWP mask_window;
WORD    obj;

{
  RECT      l, b;
  FATTR     fattr;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)mask_window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [obj];

  m_get_rect (mask_window, vdi_handle, M_FIELD, mobject, &l, &fattr);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID get_field (sf_spec)
SF_SPEC *sf_spec;

{
  WORD       type, old_type;
  WORD       font, point, color, table, field;
  LONGSTR    s;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *old, *p;
  MFIELD     *mfield;
  MOBJECT    *mobject;
  SYSMASK    *sysmask;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)sf_spec->window->special;
  base_spec = mask_spec->base_spec;
  mfield    = &sf_spec->mfield;
  type      = mfield->type;
  font      = mfield->font;
  point     = mfield->point;
  color     = mfield->color;

  sysmask  = &mask_spec->mask;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  mobject  = &mobject [sf_spec->obj];
  mfield   = &mobject->mfield;
  old_type = mfield->type;

  old = &sysmask->mask.buffer [mfield->table_name];
  get_ptext (selfield, SDTABLE, s);
  str_upper (s);
  if (strcmp (old, s) != 0)
  {
    del_str (mask_spec, mfield->table_name);
    mfield->table_name = add_str (mask_spec, s);
  } /* if */

  old = &sysmask->mask.buffer [mfield->field_name];
  get_ptext (selfield, SDFIELD, s);
  if (strcmp (old, s) != 0)
  {
    del_str (mask_spec, mfield->field_name);
    mfield->field_name = add_str (mask_spec, s);
  } /* if */

  old = &sysmask->mask.buffer [mfield->label_name];
  get_ptext (selfield, SDLABEL, s);
  if (strcmp (old, s) != 0)
  {
    del_str (mask_spec, mfield->label_name);
    mfield->label_name = add_str (mask_spec, s);
  } /* if */

  mfield->type  = type;
  mfield->flags = get_flags (selfield, font, point);

  mfield->x = get_word (selfield, SDX);
  mfield->y = get_word (selfield, SDY);
  mfield->w = get_word (selfield, SDW);
  mfield->h = get_word (selfield, SDH);

  mfield->lower = get_long (selfield, SDLOWER);
  mfield->upper = get_long (selfield, SDUPPER);

  mfield->font  = font;
  mfield->point = point;
  mfield->color = color;

  if (IS_CHECKBOX (old_type) || IS_RBUTTON (old_type))
  {
    del_str (mask_spec, mfield->extra);         /* radio/checkbox button values */
    mfield->extra = FAILURE;
  } /* if */

  if (IS_RBUTTON (type))
  {
    mfield->h = max (mfield->h, mfield->upper - mfield->lower + MIN_RBHEIGHT);
    if (sf_spec->crvals [0] != EOS) mfield->extra = add_str (mask_spec, sf_spec->crvals);
  } /* if */

  if (IS_CHECKBOX (type))
  {
    p = sf_spec->crvals;

    if ((p [0] == EOS) || (p [0] == CB_DELIMITER) && (p [1] == EOS))
    {
      field_info.type = FAILURE;

      strcpy (table_info.name, &sysmask->mask.buffer [mfield->table_name]);
      strcpy (field_info.name, &sysmask->mask.buffer [mfield->field_name]);
      table = v_tableinfo (base_spec, FAILURE, &table_info);
      field = v_fieldinfo (base_spec, table, FAILURE, &field_info);

      if (field != FAILURE)
        switch (field_info.type)
        {
          case TYPE_CHAR : strcpy (p, CB_CDEF); break;
          case TYPE_WORD : strcpy (p, CB_WDEF); break;
          case TYPE_LONG : strcpy (p, CB_LDEF); break;
        } /* switch, if */
    } /* if */

    mfield->extra = add_str (mask_spec, sf_spec->crvals);
  } /* if */
} /* get_field */

/*****************************************************************************/

LOCAL WORD set_field (sf_spec, window, show_error)
SF_SPEC *sf_spec;
WINDOWP window;
BOOLEAN show_error;

{
  WORD       obj, edit_obj, type;
  WORD       table, field;
  UWORD      flags;
  LONGSTR    s;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  MFIELD     *mfield;
  MOBJECT    *mobject;
  SYSMASK    *sysmask;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)sf_spec->window->special;
  base_spec = mask_spec->base_spec;
  obj       = sf_spec->obj;
  mfield    = &sf_spec->mfield;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [obj];
  edit_obj  = SDLABEL;

  ListBoxSetCallback (selfield, SDTYPE, callback);
  ListBoxSetStyle (selfield, SDTYPE, LBS_VSCROLL, FALSE);
/*  ListBoxSetStyle (selfield, SDTYPE, LBS_OWNERDRAW, (colors >= 16) && (gl_hbox > 8) && (tbl_icon.data != NULL));*/
  ListBoxSetLeftOffset (selfield, SDTYPE, gl_wbox / 2);
  ListBoxSetCount (selfield, SDTYPE, FMCOMBOBOX - FMNEUTRAL + 1, NULL);
  ListBoxSetCurSel (selfield, SDTYPE, 0);

  mem_move (mfield, mobject, sizeof (MFIELD));

  flags = mfield->flags;

  if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
    undo_state (selfield, SDVALUES, DISABLED);
  else
    do_state (selfield, SDVALUES, DISABLED);

  set_str (selfield, SDTABLE, &sysmask->mask.buffer [mfield->table_name]);
  set_str (selfield, SDFIELD, &sysmask->mask.buffer [mfield->field_name]);
  set_str (selfield, SDLABEL, &sysmask->mask.buffer [mfield->label_name]);

  set_str (selfield, SDLOWER, "");
  set_str (selfield, SDUPPER, "");

  undo_flags (selfield, SDTABLE,  EDITABLE);
  do_state (selfield, SDTABLE - 1, DISABLED);
  undo_flags (selfield, SDFIELD,  EDITABLE);
  do_state (selfield, SDFIELD - 1, DISABLED);

  set_checkbox (selfield, SDSTDLBL, flags & MF_STDLABEL);
  set_checkbox (selfield, SDHSLIDR, flags & MF_HSLIDER);
  set_checkbox (selfield, SDVSLIDR, flags & MF_VSLIDER);
  set_checkbox (selfield, SDWORDWR, flags & MF_WORDBREAK);
  set_checkbox (selfield, SDBOUNDS, flags & MF_USEBOUNDS);
  set_checkbox (selfield, SDNOCLEA, flags & MF_NOCLEAR);
  set_checkbox (selfield, SDWHUNIT, flags & MF_UNITWH);

  obj = SDREPLAC;
  if (flags & MF_TRANSPARENT) obj = SDTRANS;
  set_rbutton (selfield, obj, SDREPLAC, SDTRANS);

  set_word (selfield, SDX, mfield->x);
  set_word (selfield, SDY, mfield->y);
  set_word (selfield, SDW, mfield->w);
  set_word (selfield, SDH, mfield->h);

  type = FAILURE;

  get_ptext (selfield, SDTABLE, table_info.name);
  table = v_tableinfo (base_spec, FAILURE, &table_info);

  if (table == FAILURE)
  {
    sprintf (s, alerts [ERR_TABLENAME], table_info.name);
    if (show_error) open_alert (s);

    edit_obj = SDTABLE;
    do_flags (selfield, SDTABLE,  EDITABLE);
    undo_state (selfield, SDTABLE - 1, DISABLED);
  } /* if */
  else
  {
    get_ptext (selfield, SDFIELD, field_info.name);
    field = v_fieldinfo (base_spec, table, FAILURE, &field_info);

    if (field == FAILURE)
    {
      sprintf (s, alerts [ERR_FIELDNAME], field_info.name);
      if (show_error) open_alert (s);

      if (edit_obj == SDLABEL) edit_obj = SDFIELD;
      do_flags (selfield, SDFIELD,  EDITABLE);
      undo_state (selfield, SDFIELD - 1, DISABLED);
    } /* if */
    else
      type = field_info.type;
  } /* else */

  do_state (selfield, SDHSLIDR, DISABLED);	/* not yet implemented */
  do_state (selfield, SDVSLIDR, DISABLED);

  undo_flags (selfield, SDLOWER,  EDITABLE);
  do_state (selfield, SDLOWER - 1, DISABLED);
  undo_flags (selfield, SDUPPER,  EDITABLE);
  do_state (selfield, SDUPPER - 1, DISABLED);

#if 0
  do_state (popups, PMUNDERL, DISABLED);
  do_state (popups, PMCHECKL, DISABLED);
  do_state (popups, PMCHECKR, DISABLED);
  do_state (popups, PMRADIOB, DISABLED);
  do_state (popups, PMPOPUP,  DISABLED);
#endif

  if (type != TYPE_PICTURE)
  {
#if 0
    undo_state (popups, PMUNDERL, DISABLED);
    undo_state (popups, PMPOPUP,  DISABLED);
#endif
  } /* if */

  if ((type == TYPE_CHAR) ||
      (type == TYPE_WORD)  ||
      (type == TYPE_LONG)  ||
      (type == TYPE_FLOAT) ||
      (type == TYPE_CFLOAT))
  {
    do_flags (selfield, SDLOWER,  EDITABLE);
    undo_state (selfield, SDLOWER - 1, DISABLED);
    do_flags (selfield, SDUPPER,  EDITABLE);
    undo_state (selfield, SDUPPER - 1, DISABLED);

    if ((type == TYPE_CHAR) ||
        (type == TYPE_WORD) ||
        (type == TYPE_LONG))
    {
#if 0
      undo_state (popups, PMCHECKL, DISABLED);
      undo_state (popups, PMCHECKR, DISABLED);
      undo_state (popups, PMRADIOB, DISABLED);
#endif
    } /* if */

    set_long (selfield, SDLOWER, mfield->lower);
    set_long (selfield, SDUPPER, mfield->upper);
  } /* if */

  FontNameFromNumber (s, mfield->font);
  s [FONTNAME_LENGTH] = EOS;
  set_str (selfield, SDFONTN, s);

  sprintf (s, "%d", mfield->point);
  set_str (selfield, SDPOINT, s);

  ListBoxSetCurSel (selfield, SDTYPE, mfield->type);
  set_str (selfield, SDTYPE, FREETXT (FMNEUTRAL + mfield->type));

  if ((IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type)) && (mfield->extra >= 0))
    strcpy (sf_spec->crvals, &sysmask->mask.buffer [mfield->extra]);
  else
    strcpy (sf_spec->crvals, "");

  check_ok (window);

  return (edit_obj);
} /* set_field */

/*****************************************************************************/

LOCAL VOID open_field (window)
WINDOWP window;

{
  SF_SPEC *sf_spec;

  sf_spec = (SF_SPEC *)window->special;
  box (window, TRUE, sf_spec->window, sf_spec->obj);
} /* open_field */

/*****************************************************************************/

LOCAL VOID close_field (window)
WINDOWP window;

{
  SF_SPEC *sf_spec;

  sf_spec = (SF_SPEC *)window->special;
  box (window, FALSE, sf_spec->window, sf_spec->obj);
} /* close_field */

/*****************************************************************************/

LOCAL VOID click_field (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      index;
  STRING    s;
  FONTDESC  fontdesc;
  MFIELD    *mfield;
  SF_SPEC   *sf_spec;
  MASK_SPEC *mask_spec;

  sf_spec   = (SF_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)sf_spec->window->special;
  mfield    = &sf_spec->mfield;

  switch (window->exit_obj)
  {
    case SDTYPE   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, FMCOMBOBOX - FMNEUTRAL + 1);                     
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    index = ListBoxComboClick (window->object, window->exit_obj, mk);
                    if (index != FAILURE) mfield->type = ListBoxGetCurSel (window->object, window->exit_obj);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SDVALUES : if (IS_CHECKBOX (mfield->type)) mcbvals (sf_spec->crvals);
                    if (IS_RBUTTON (mfield->type)) mrbvals (sf_spec->crvals);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SDFONT   : fontdesc.font    = mfield->font;
                    fontdesc.point   = mfield->point;
                    fontdesc.effects = TXT_NORMAL;
                    fontdesc.color   = mfield->color;

                    if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_HIDE_EFFECTS | FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc))
                    {
                      mfield->font  = fontdesc.font;
                      mfield->point = fontdesc.point;
                      mfield->color = fontdesc.color;

                      FontNameFromNumber (s, mfield->font);
                      s [FONTNAME_LENGTH] = EOS;
                      set_str (selfield, SDFONTN, s);

                      sprintf (s, "%-3d", mfield->point);
                      set_str (selfield, SDPOINT, s);

                      draw_object (window, SDFONTN);
                      draw_object (window, SDPOINT);
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SDOK     : get_field (sf_spec);
                    set_redraw (sf_spec->window, &sf_spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case SDHELP   : hndl_help (HFIELDAT);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  check_ok (window);
} /* click_field */

/*****************************************************************************/

LOCAL VOID check_ok (window)
WINDOWP window;

{
  BOOLEAN    invalid;
  WORD       width, height;
  WORD       table, field;
  LONG       lower, upper;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *p1, *p2, *p3, *p4, *p5, *p6;
  MFIELD     *mfield;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *mask_spec;
  SF_SPEC    *sf_spec;

  sf_spec   = (SF_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)sf_spec->window->special;
  base_spec = mask_spec->base_spec;
  mfield    = &sf_spec->mfield;
  field     = FAILURE;

  get_ptext (selfield, SDTABLE, table_info.name);
  table = v_tableinfo (base_spec, FAILURE, &table_info);

  if (table != FAILURE)
  {
    get_ptext (selfield, SDFIELD, field_info.name);
    field = v_fieldinfo (base_spec, table, FAILURE, &field_info);
  } /* if */

  p1 = get_str (selfield, SDTABLE);
  p2 = get_str (selfield, SDFIELD);
  p3 = get_str (selfield, SDX);
  p4 = get_str (selfield, SDY);
  p5 = get_str (selfield, SDW);
  p6 = get_str (selfield, SDH);

  width  = get_word (selfield, SDW);
  height = get_word (selfield, SDH);
  lower  = get_long (selfield, SDLOWER);
  upper  = get_long (selfield, SDUPPER);

  invalid = ((table == FAILURE) ||
             (field == FAILURE) ||
             (*p1 == EOS) ||
             (*p2 == EOS) ||
             (*p3 == EOS) ||
             (*p4 == EOS) ||
             (*p5 == EOS) ||
             (*p6 == EOS) ||
             (width == 0) ||
             (height == 0) ||
             (height > 1) && (mfield->type == MT_UNDERLINED) ||
             (mfield->type == MT_RADIOBUTTON) && (upper - lower + 1 < 2) ||     /* at least 2 choices */
             (lower > upper) && ! is_null (TYPE_LONG, &lower) && ! is_null (TYPE_LONG, &upper));

  if (invalid == ! is_state (selfield, SDOK, DISABLED))
  {
    flip_state (selfield, SDOK, DISABLED);
    draw_object (window, SDOK);
  } /* if */

  invalid = ! IS_CHECKBOX (mfield->type) && ! IS_RBUTTON (mfield->type);

  if (invalid == ! is_state (selfield, SDVALUES, DISABLED))
  {
    flip_state (selfield, SDVALUES, DISABLED);
    draw_object (window, SDVALUES);
  } /* if */

  invalid = ((field == FAILURE) ||
             (mfield->type != MT_NEUTRAL) &&
             (mfield->type != MT_OUTLINED) &&
             (mfield->type != MT_UNDERLINED) ||
             (field_info.type != TYPE_WORD) &&
             (field_info.type != TYPE_LONG) &&
             (field_info.type != TYPE_FLOAT));

  if (invalid == ! is_state (selfield, SDBOUNDS, DISABLED))
  {
    flip_state (selfield, SDBOUNDS, DISABLED);
    draw_object (window, SDBOUNDS);
  } /* if */
} /* check_ok */

/*****************************************************************************/

LOCAL BOOLEAN xget_checkbox (tree, obj)
OBJECT *tree;
WORD   obj;

{
  return (get_checkbox (tree, obj) && ! is_state (tree, obj, DISABLED));
} /* xget_checkbox */

/*****************************************************************************/

LOCAL UWORD get_flags (selfield, font, point)
OBJECT *selfield;
WORD   font;
WORD   point;
{
  WORD  wchar, hchar, wbox, hbox;
  UWORD flags;

  flags = 0;

  if (xget_checkbox (selfield, SDSTDLBL)) flags |= MF_STDLABEL;
  if (xget_checkbox (selfield, SDHSLIDR)) flags |= MF_HSLIDER;
  if (xget_checkbox (selfield, SDVSLIDR)) flags |= MF_VSLIDER;
  if (xget_checkbox (selfield, SDWORDWR)) flags |= MF_WORDBREAK;
  if (xget_checkbox (selfield, SDBOUNDS)) flags |= MF_USEBOUNDS;
  if (xget_checkbox (selfield, SDNOCLEA)) flags |= MF_NOCLEAR;
  if (xget_checkbox (selfield, SDWHUNIT)) flags |= MF_UNITWH;
  if (xget_checkbox (selfield, SDTRANS))  flags |= MF_TRANSPARENT;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);
  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  return (flags);
} /* get_flags */

/*****************************************************************************/

LOCAL VOID mrbvals (values)
BYTE *values;

{
  WINDOWP window;
  WORD    ret;

  exit_obj = RVCANCEL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, RBVALUES);

  if (window == NULL)
  {
    form_center (rbvalues, &ret, &ret, &ret, &ret);
    window = crt_dialog (rbvalues, NULL, RBVALUES, FREETXT (FRVALUES), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_rbvals;
      window->key   = key_rbvals;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (rbvalues, ROOT, EDITABLE);
    window->edit_inx = NIL;

    set_rbvals (values);

    if (! open_dialog (RBVALUES))
      hndl_alert (ERR_NOOPEN);
    else
      if (exit_obj == RVOK) strcpy (values, crvals);
  } /* if */
} /* mrbvals */

/*****************************************************************************/

LOCAL VOID get_rbvals (s)
BYTE *s;

{
  WORD i;
  BYTE *p;

  *s = EOS;

  for (i = 0; i < RB_LINES; i++)
  {
    p = get_str (rbvalues, RVTEXT1 + i);
    strcat (s, p);
  } /* for */
} /* get_rbvals */

/*****************************************************************************/

LOCAL VOID set_rbvals (s)
BYTE *s;

{
  WORD i, l;

  l = strlen (s);

  for (i = 0; i < RB_LINES; i++, l -= RB_COLS, s += RB_COLS)
    if (l > 0)
      set_str (rbvalues, RVTEXT1 + i, s);
    else
      set_str (rbvalues, RVTEXT1 + i, "");
} /* set_rbvals */

/*****************************************************************************/

LOCAL VOID click_rbvals (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case RVOK     : get_rbvals (crvals);
                    break;
    case RVHELP   : hndl_help (HRVALUES);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  exit_obj = window->exit_obj;
} /* click_rbvals */

/*****************************************************************************/

LOCAL BOOLEAN key_rbvals (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONGSTR s;

  get_rbvals (s);

  if ((*s == EOS) == ! is_state (rbvalues, RVOK, DISABLED))
  {
    flip_state (rbvalues, RVOK, DISABLED);
    draw_object (window, RVOK);
  } /* if */

  return (FALSE);
} /* key_rbvals */

/*****************************************************************************/

LOCAL VOID mcbvals (values)
BYTE *values;

{
  WINDOWP window;
  WORD    ret;

  exit_obj = CVCANCEL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, CBVALUES);

  if (window == NULL)
  {
    form_center (cbvalues, &ret, &ret, &ret, &ret);
    window = crt_dialog (cbvalues, NULL, CBVALUES, FREETXT (FCVALUES), WI_MODAL);

    if (window != NULL)
    {
      window->click = click_cbvals;
      window->key   = key_cbvals;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (cbvalues, ROOT, EDITABLE);
    window->edit_inx = NIL;

    set_cbvals (values);

    if (! open_dialog (CBVALUES))
      hndl_alert (ERR_NOOPEN);
    else
      if (exit_obj == CVOK) strcpy (values, crvals);
  } /* if */
} /* mcbvals */

/*****************************************************************************/

LOCAL VOID get_cbvals (s)
BYTE *s;

{
  BYTE *sel, *unsel;

  sel   = get_str (cbvalues, CVSEL);
  unsel = get_str (cbvalues, CVUNSEL);

  sprintf (s, "%s%c%s", sel, CB_DELIMITER, unsel);
} /* get_cbvals */

/*****************************************************************************/

LOCAL VOID set_cbvals (s)
BYTE *s;

{
  BOOLEAN invalid;
  BYTE    *sel, *unsel;
  LONGSTR str;

  strcpy (str, s);

  invalid = *s == EOS;
  if (invalid) sprintf (str, "%c", CB_DELIMITER);

  sel   = str;
  unsel = strchr (sel, CB_DELIMITER);

  if (unsel == NULL) return;

  *unsel = EOS;
  unsel++;

  set_str (cbvalues, CVSEL, sel);
  set_str (cbvalues, CVUNSEL, unsel);

  if (invalid == ! is_state (cbvalues, CVOK, DISABLED)) flip_state (cbvalues, CVOK, DISABLED);
} /* set_cbvals */

/*****************************************************************************/

LOCAL VOID click_cbvals (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case CVOK     : get_cbvals (crvals);
                    break;
    case CVHELP   : hndl_help (HCVALUES);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  exit_obj = window->exit_obj;
} /* click_cbvals */

/*****************************************************************************/

LOCAL BOOLEAN key_cbvals (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONGSTR s;

  get_cbvals (s);

  if ((strlen (s) == 1) == ! is_state (cbvalues, CVOK, DISABLED))
  {
    flip_state (cbvalues, CVOK, DISABLED);
    draw_object (window, CVOK);
  } /* if */

  return (FALSE);
} /* key_cbvals */
