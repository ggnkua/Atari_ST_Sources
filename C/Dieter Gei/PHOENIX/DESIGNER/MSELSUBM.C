/*****************************************************************************
 *
 * Module : MSELSUBM.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 20.09.94
 * Last modification: 06.01.95
 *
 *
 * Description: This module implements the mask select submask dialog box.
 *
 * History:
 * 06.01.95: Search rels in both directions (1:n, n:1) if exit_obj == SSSOURCE in click_dlg
 * 04.01.95: Using new function names of controls module
 * 07.12.94: Variable obj_new defaults to SSTABLE if no flag is given in click_dlg
 * 10.10.94: Disable button Font when SSMASK selected in check_dlg
 * 25.09.94: handling of default relation added (get_rels)
 * 20.09.94: Creation of body
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
#include "mselsubm.h"

/****** DEFINES **************************************************************/

#define SRC_DST_LENGTH   50	/* see resource file */
#define FONTNAME_LENGTH  16	/* see resource file */
#define VISIBLE           6	/* number of lines in combobox */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD     obj;
  MSUBMASK msubmask;
  WINDOWP  window;	/* mask window */
} SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD exit_obj;
LOCAL SPEC spec;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback       _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box            _((WINDOWP window, BOOLEAN grow, WINDOWP mask_window, WORD obj));

LOCAL VOID    get_dlg        _((SPEC *spec));
LOCAL VOID    set_dlg        _((SPEC *spec, WINDOWP window, BOOLEAN show_error));
LOCAL VOID    open_dlg       _((WINDOWP window));
LOCAL VOID    close_dlg      _((WINDOWP window));
LOCAL VOID    click_dlg      _((WINDOWP window, MKINFO *mk));

LOCAL VOID    check_dlg      _((WINDOWP window));
LOCAL UWORD   get_flags      _((OBJECT *selsubm, WORD font, WORD point));
LOCAL BYTE    *get_recsource _((BASE_SPEC *base_spec, BYTE *pMaskName));
LOCAL BOOLEAN get_rels       _((BASE_SPEC *base_spec, WORD src_table, WORD dst_table, BYTE *src_str, BYTE *dst_str, USHORT *flags));

/*****************************************************************************/

GLOBAL WORD mselsubmask (WINDOWP mask_window, WORD obj)
{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, SELSUBM);

  if (window == NULL)
  {
    form_center (selsubm, &ret, &ret, &ret, &ret);
    window = crt_dialog (selsubm, NULL, SELSUBM, FREETXT (FSUBMASK), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_dlg;
      window->close   = close_dlg;
      window->click   = click_dlg;
      window->special = (LONG)&spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (selsubm, ROOT, EDITABLE);
    window->edit_inx = NIL;

    spec.window = mask_window;
    spec.obj    = obj;

    set_dlg (&spec, window, FALSE);

    if (! open_dialog (SELSUBM)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (exit_obj);
} /* mselsubmask */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LOCAL STRING s;	/* static cause small AES stack */
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  HLPMASK      *sysmask;
  BASE_SPEC    *base_spec;
  MASK_SPEC    *mask_spec;
  SPEC         *spec;

  window    = (WINDOWP)ListBoxGetSpec (tree, obj);
  spec      = (SPEC *)window->special;
  mask_spec = (MASK_SPEC *)spec->window->special;
  base_spec = mask_spec->base_spec;

  switch (msg)
  {
    case LBN_GETITEM    : sysmask = &base_spec->sysmask [index];
                          return ((LONG)sysmask->name);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 2 * gl_wbox;
                            DrawOwnerIcon (lb_ownerdraw, &r, &msk_icon, text, 2);
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

  m_get_rect (mask_window, vdi_handle, M_SUBMASK, mobject, &l, &fattr);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID get_dlg (spec)
SPEC *spec;

{
  WORD       font, point, color;
  LONG       index;
  LONGSTR    s;
  MSUBMASK   *msubmask;
  MOBJECT    *mobject;
  SYSMASK    *sysmask;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)spec->window->special;
  msubmask  = &spec->msubmask;
  font      = msubmask->font;
  point     = msubmask->point;
  color     = msubmask->color;

  sysmask  = &mask_spec->mask;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  mobject  = &mobject [spec->obj];
  msubmask = &mobject->msubmask;

  s [0] = EOS;
  index = ListBoxGetCurSel (selsubm, SSSOURCE);
  if (index != FAILURE) ListBoxGetText (selsubm, SSSOURCE, index, s);

  del_str (mask_spec, msubmask->SourceObject);
  msubmask->SourceObject = add_str (mask_spec, s);

  del_str (mask_spec, msubmask->LinkMaster);
  msubmask->LinkMaster = add_str (mask_spec, get_str (selsubm, SSMASTER));

  del_str (mask_spec, msubmask->LinkChild);
  msubmask->LinkChild = add_str (mask_spec, get_str (selsubm, SSCHILD));

  msubmask->x = get_word (selsubm, SSX);
  msubmask->y = get_word (selsubm, SSY);
  msubmask->w = get_word (selsubm, SSW);
  msubmask->h = get_word (selsubm, SSH);

  msubmask->font  = font;
  msubmask->point = point;
  msubmask->color = color;
  msubmask->flags = get_flags (selsubm, font, point);
} /* get_dlg */

/*****************************************************************************/

LOCAL VOID set_dlg (spec, window, show_error)
SPEC *spec;
WINDOWP window;
BOOLEAN show_error;

{
  WORD      obj;
  LONG      index;
  LONGSTR   s;
  BYTE      *p;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  BASE_SPEC *base_spec;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)spec->window->special;
  base_spec = mask_spec->base_spec;
  obj       = spec->obj;
  msubmask  = &spec->msubmask;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [obj];

  ListBoxSetCallback (selsubm, SSSOURCE, callback);
  ListBoxSetStyle (selsubm, SSSOURCE, LBS_VSCROLL, FALSE);
  ListBoxSetLeftOffset (selsubm, SSSOURCE, gl_wbox / 2);
  ListBoxSetCount (selsubm, SSSOURCE, base_spec->num_masks, NULL);
  ListBoxSetSpec (selsubm, SSSOURCE, (LONG)window);

  mem_move (msubmask, mobject, sizeof (MSUBMASK));

  set_str (selsubm, SSSOURCE, &sysmask->mask.buffer [msubmask->SourceObject]);
  set_str (selsubm, SSMASTER, &sysmask->mask.buffer [msubmask->LinkMaster]);
  set_str (selsubm, SSCHILD,  &sysmask->mask.buffer [msubmask->LinkChild]);

  set_word (selsubm, SSX, msubmask->x);
  set_word (selsubm, SSY, msubmask->y);
  set_word (selsubm, SSW, msubmask->w);
  set_word (selsubm, SSH, msubmask->h);

  obj = SSTABLE;
  if (msubmask->flags & MSM_SHOW_MASK) obj = SSMASK;
  set_rbutton (selsubm, obj, SSTABLE, SSMASK);

  FontNameFromNumber (s, msubmask->font);
  s [FONTNAME_LENGTH] = EOS;
  set_str (selsubm, SSFONTN, s);

  sprintf (s, "%d", msubmask->point);
  set_str (selsubm, SSPOINT, s);

  p     = get_str (selsubm, SSSOURCE);
  index = ListBoxFindString (selsubm, SSSOURCE, 0, p);
  ListBoxSetCurSel (selsubm, SSSOURCE, index);

  check_dlg (window);

  exit_obj = SSCANCEL;
} /* set_dlg */

/*****************************************************************************/

LOCAL VOID open_dlg (window)
WINDOWP window;

{
  SPEC *spec;

  spec = (SPEC *)window->special;
  box (window, TRUE, spec->window, spec->obj);
} /* open_dlg */

/*****************************************************************************/

LOCAL VOID close_dlg (window)
WINDOWP window;

{
  SPEC *spec;

  spec = (SPEC *)window->special;
  box (window, FALSE, spec->window, spec->obj);
} /* close_dlg */

/*****************************************************************************/

LOCAL VOID click_dlg (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN    src_dst, dst_src;
  WORD       src_table, dst_table, obj_old, obj_new;
  USHORT     flags;
  LONG       index;
  STRING     s;
  LONGSTR    src_str, dst_str;
  TABLE_INFO table_info;
  FONTDESC   fontdesc;
  BYTE       *rs;
  MSUBMASK   *msubmask;
  SPEC       *spec;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *mask_spec;

  spec      = (SPEC *)window->special;
  mask_spec = (MASK_SPEC *)spec->window->special;
  base_spec = mask_spec->base_spec;
  msubmask  = &spec->msubmask;

  switch (window->exit_obj)
  {
    case SSSOURCE : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (VISIBLE, base_spec->num_masks));
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    index = ListBoxComboClick (window->object, window->exit_obj, mk);

                    if (index != FAILURE)
                    {
                      strncpy (table_info.name, mask_spec->mask.tablename, MAX_TABLENAME);
                      src_table = v_tableinfo (base_spec, FAILURE, &table_info);
                      dst_table = FAILURE;

                      ListBoxGetText (window->object, window->exit_obj, index, s);
                      if (s [0] != EOS)
                      {
                        rs = get_recsource (base_spec, s);
                        strncpy (table_info.name, rs, MAX_TABLENAME);
                        dst_table = v_tableinfo (base_spec, FAILURE, &table_info);
                      } /* if */

                      if ((src_table != FAILURE) && (dst_table != FAILURE))
                      {
                        src_dst = get_rels (base_spec, src_table, dst_table, src_str, dst_str, &flags);	/* check 1:1, 1:N */
                        dst_src = get_rels (base_spec, dst_table, src_table, dst_str, src_str, &flags);	/* check 1:1, N:1 */

                        if (src_dst || dst_src)		/* any relation was found */
                        {
                          src_str [SRC_DST_LENGTH] = EOS;
                          dst_str [SRC_DST_LENGTH] = EOS;
                          set_str (selsubm, SSMASTER, src_str);
                          set_str (selsubm, SSCHILD,  dst_str);
                          draw_object (window, SSMASTER);
                          draw_object (window, SSCHILD);
                          set_cursor (window, SSMASTER, NIL);

                          obj_old = get_rbutton (selsubm, SSTABLE);
                          obj_new = ((flags & REL_11) || ! src_dst) ? SSMASK : SSTABLE;	/* if relation was 1:1 or N:1 then take a mask as object */
                          if (obj_old != obj_new)
                          {
                            set_rbutton (selsubm, obj_new, SSTABLE, SSMASK);
                            draw_object (window, SSTABLE);
                            draw_object (window, SSMASK);
                          } /* if */
                        } /* if */
                      } /* if */
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SSFONT   : fontdesc.font    = msubmask->font;
                    fontdesc.point   = msubmask->point;
                    fontdesc.effects = TXT_NORMAL;
                    fontdesc.color   = msubmask->color;

                    if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_HIDE_EFFECTS | FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc))
                    {
                      msubmask->font  = fontdesc.font;
                      msubmask->point = fontdesc.point;
                      msubmask->color = fontdesc.color;

                      FontNameFromNumber (s, msubmask->font);
                      s [FONTNAME_LENGTH] = EOS;
                      set_str (selsubm, SSFONTN, s);

                      sprintf (s, "%-3d", msubmask->point);
                      set_str (selsubm, SSPOINT, s);

                      draw_object (window, SSFONTN);
                      draw_object (window, SSPOINT);
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SSOK     : get_dlg (spec);
                    set_redraw (spec->window, &spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case SSHELP   : hndl_help (HSUBMASK);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  exit_obj = window->exit_obj;

  check_dlg (window);
} /* click_dlg */

/*****************************************************************************/

LOCAL VOID check_dlg (window)
WINDOWP window;

{
  BOOLEAN    invalid;
  WORD       width, height;
  WORD       table, obj;
  LONG       index;
  LONGSTR    s;
  TABLE_INFO table_info;
  BYTE       *rs;
  BYTE       *p1, *p2, *p3, *p4, *p5, *p6, *p7;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *mask_spec;
  SPEC    *spec;

  spec      = (SPEC *)window->special;
  mask_spec = (MASK_SPEC *)spec->window->special;
  base_spec = mask_spec->base_spec;
  s [0]     = EOS;

  obj = get_rbutton (selsubm, SSTABLE);

  if ((obj == SSMASK) == ! is_state (selsubm, SSFONT, DISABLED))
  {
    flip_state (selsubm, SSFONT, DISABLED);
    draw_object (window, SSFONT);
  } /* if */

  index = ListBoxGetCurSel (selsubm, SSSOURCE);
  if (index != FAILURE) ListBoxGetText (selsubm, SSSOURCE, index, s);
  if (s [0] != EOS)
  {
    rs = get_recsource (base_spec, s);
    strncpy (table_info.name, rs, MAX_TABLENAME);
    table = v_tableinfo (base_spec, FAILURE, &table_info);
  } /* if */

  p1 = get_str (selsubm, SSSOURCE);
  p2 = get_str (selsubm, SSMASTER);
  p3 = get_str (selsubm, SSCHILD);
  p4 = get_str (selsubm, SSX);
  p5 = get_str (selsubm, SSY);
  p6 = get_str (selsubm, SSW);
  p7 = get_str (selsubm, SSH);

  width  = get_word (selsubm, SSW);
  height = get_word (selsubm, SSH);

  invalid = ((*p1 == EOS) ||
             (table != FAILURE) && ((*p2 == EOS) || (*p3 == EOS)) ||	/* if table given, you must provide LinkMaster and LinkChild */
             (*p4 == EOS) ||
             (*p5 == EOS) ||
             (*p6 == EOS) ||
             (*p7 == EOS) ||
             (width == 0) ||
             (height == 0));

  if (invalid == ! is_state (selsubm, SSOK, DISABLED))
  {
    flip_state (selsubm, SSOK, DISABLED);
    draw_object (window, SSOK);
  } /* if */
} /* check_dlg */

/*****************************************************************************/

LOCAL UWORD get_flags (selsubm, font, point)
OBJECT *selsubm;
WORD   font;
WORD   point;

{
  WORD  wchar, hchar, wbox, hbox;
  WORD  obj;
  UWORD flags;

  flags = 0;

  obj = get_rbutton (selsubm, SSTABLE);

  switch (obj)
  {
    case SSTABLE  : flags |= MSM_SHOW_TABLE; break;
    case SSMASK   : flags |= MSM_SHOW_MASK;  break;
  } /* switch */

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);
  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  return (flags);
} /* get_flags */

/*****************************************************************************/

LOCAL BYTE *get_recsource (BASE_SPEC *base_spec, BYTE *pMaskName)
{
  WORD    i;
  HLPMASK *sysmask;

  sysmask = base_spec->sysmask;

  for (i = 0; i < base_spec->num_masks; i++, sysmask++)
    if (strcmp (sysmask->name, pMaskName) == 0) return (sysmask->tablename);

  return (NULL);
} /* get_recsource */

/*****************************************************************************/

LOCAL BOOLEAN get_rels (base_spec, src_table, dst_table, src_str, dst_str, flags)
BASE_SPEC *base_spec;
WORD      src_table, dst_table;
BYTE      *src_str, *dst_str;
USHORT    *flags;

{
  WORD       i;
  WORD       src_index, dst_index;
  INDEX_INFO src_info, dst_info;
  SYSREL     *sysrel;

  src_index = find_primary (base_spec, src_table);
  if (src_index == FAILURE) return (FALSE);

  sysrel = base_spec->sysrel;

  for (i = 0; i < base_spec->num_rels; i++, sysrel++)
   if (sysrel->flags & MOD_FLAG)
    {
      if (! (sysrel->flags & DEL_FLAG)    &&
          (sysrel->reftable == src_table) &&
          (sysrel->refindex == src_index) &&
          (sysrel->reltable == dst_table))
      {
        dst_index = sysrel->relindex;

        v_indexinfo (base_spec, src_table, src_index, &src_info);
        v_indexinfo (base_spec, dst_table, dst_index, &dst_info);
        
        sprintf (src_str, "%s.%s", base_spec->systable [src_table].name, src_info.name);
        sprintf (dst_str, "%s.%s", base_spec->systable [dst_table].name, dst_info.name);

        *flags = sysrel->flags;

        return (TRUE);
      } /* if */
    } /* if */

  return (FALSE);
} /* get_rels */

