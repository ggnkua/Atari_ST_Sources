/*****************************************************************************
 *
 * Module : MASKDRAW.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 15.11.95
 *
 *
 * Description: This module implements the drawing functions for a mask window.
 *
 * History:
 * 15.11.95: Call to clear_area moved before test on *p in draw_field
 * 03.11.95: Test on MBF_HIDDEN added to draw_button
 * 12.10.95: DrawString called with default color in sm_as_mask
 * 11.10.95: Variable steps in sm_as_table set correctly
 * 06.09.95: Drawing of right checkboxes corrected in draw_field
 * 11.08.95: IndexFromColor32 made global
 * 08.08.95: Drawing 3d in draw_mask, draw_field added
 * 04.05.95: Break when painting the header if header is empty in sm_as_table
 * 22.04.95: Function sm_as_table got its own buffer
 * 21.04.95: Call to IS_EDITABLE changed to m_is_editable in draw_mask
 * 30.03.95: Don't snap to full lines in sm_as_table
 * 31.01.95: Function sm_as_mask is using DrawString
 * 18.01.95: Function sm_as_mask added
 * 17.01.95: Parameter window changed to mask_spec in all drawing functions
 * 15.12.94: Drawing of scroll bar added to sm_as_table
 * 20.11.94: Function draw_sm added
 * 14.11.94: Include imageobj.h added
 * 18.10.94: Function sm_as_table added
 * 06.10.94: Function draw_submask added
 * 14.07.94: New 3D-DrawButton used in draw_button
 * 15.04.94: New transparent modus added to draw_field
 * 07.12.93: Drawing of underscore added to draw_button for keyboard interface
 * 22.11.93: Default color is WHITE on monochrome displays in draw_mask
 * 04.11.93: Drawing of background color added to draw_mask
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
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
#include "imageobj.h"
#include "dialog.h"

#include "maskobj.h"
#include "mclick.h"
#include "resource.h"

#include "export.h"
#include "maskdraw.h"

/****** DEFINES **************************************************************/

#define RADIO_DELIMITER '|'	/* delimiter for radio button choices */
#define STD_COLORS 16		/* use 16 standard colors for tables, mask background etc. */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID  draw_field       _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, FATTR *fattr, WORD strwidth, WORD edobj, WORD bk_color));
LOCAL VOID  draw_line        _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, WORD bk_color));
LOCAL VOID  draw_box         _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, BOOLEAN rounded, BOOLEAN selected, WORD bk_color));
LOCAL VOID  draw_text        _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID  draw_graf        _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID  draw_button      _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color));
LOCAL VOID  draw_submask     _((MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD sub, WORD bk_color));
LOCAL VOID  draw_checkbox    _((WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color));
LOCAL VOID  draw_rbutton     _((WORD out_handle, WORD x, WORD y, WORD h, BOOLEAN selected, WORD color, WORD bk_color));
LOCAL VOID  draw_rect        _((WORD out_handle, RECT *r));
LOCAL VOID  draw_arrow       _((WORD out_handle, RECT *r, WORD color));
LOCAL VOID  draw_acc_line    _((WORD vdi_handle, WORD inx, WORD x, WORD y, BYTE *text, BOOLEAN disabled, WORD dlg_colors, WORD bk_color, WORD text_color));
LOCAL VOID  sm_as_table      _((MASK_SPEC *mask_spec, WORD out_handle, MSUBMASK *msubmask, RECT *r, WORD sub));
LOCAL VOID  sm_as_mask       _((MASK_SPEC *mask_spec, WORD out_handle, MSUBMASK *msubmask, RECT *r, WORD sub));
LOCAL VOID  clear_area       _((WORD out_handle, RECT *area));
LOCAL VOID  fill_rect        _((RECT *rc, WORD color, BOOLEAN show_pattern));
LOCAL VOID  draw_3d_rect     _((RECT *rc, WORD color_highlight, WORD color_shadow));
LOCAL VOID  draw_border      _((RECT *rc));
LOCAL VOID  get_rtext        _((BYTE *p, BYTE *s, WORD index));

/*****************************************************************************/

GLOBAL VOID draw_mask (MASK_SPEC *mask_spec, WORD out_handle)
{
  BOOLEAN b3D;
  WORD    obj, sub, class, strwidth, edobj, bk_color, old_colors;
  WORD    xy [4];
  RECT    frame, r;
  FATTR   fattr;
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;
  WINDOWP window;

  window  = mask_spec->window;
  sysmask = mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;

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

  old_colors = dlg_colors;
  b3D        = (dlg_colors >= 16) && (sysmask->flags & SM_SHOW_3D);

  for (obj = edobj = sub = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield   = &mobject->mfield;
    class    = mfield->class;
    strwidth = m_get_rect (mask_spec, out_handle, class, mobject, &frame, &fattr);
    r        = frame;

    if (! b3D) dlg_colors = 2;
    if (b3D) rc_inflate (&frame, 1, 1);

    if (rc_intersect (&clip, &frame))
    {
      vswr_mode (out_handle, MD_REPLACE);
      vsl_type (out_handle, SOLID);
      vsl_width (out_handle, 1);
      vsl_ends (out_handle, SQUARED, SQUARED);

      switch (class)
      {
        case M_FIELD   : draw_field (mask_spec, out_handle, mobject, &r, &fattr, strwidth, edobj, bk_color); break;
        case M_LINE    : draw_line (mask_spec, out_handle, mobject, bk_color);                               break;
        case M_BOX     : draw_box (mask_spec, out_handle, mobject, &r, FALSE, FALSE, bk_color);              break;
        case M_RBOX    : draw_box (mask_spec, out_handle, mobject, &r, TRUE, FALSE, bk_color);               break;
        case M_TEXT    : draw_text (mask_spec, out_handle, mobject, &r, bk_color);                           break;
        case M_GRAF    : draw_graf (mask_spec, out_handle, mobject, &r, bk_color);                           break;
        case M_BUTTON  : draw_button (mask_spec, out_handle, mobject, &r, bk_color);                         break;
        case M_SUBMASK : draw_submask (mask_spec, out_handle, mobject, &r, sub, bk_color);                   break;
      } /* switch */
    } /* if */

    if (m_is_editable (mobject)) edobj++;
    if (class == M_SUBMASK) sub++;
  } /* for */

  dlg_colors = old_colors;
} /* draw_mask */

/*****************************************************************************/

GLOBAL VOID draw_sm (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD sub)
{
  clr_area (r);  
  draw_submask (mask_spec, out_handle, mobject, r, sub, WHITE);
} /* draw_sm */

/*****************************************************************************/

GLOBAL SHORT IndexFromColor32 (LONG lColor)
{
  SHORT sIndex;

  sIndex = (SHORT)((lColor >> 24) - 1);	/* WHITE (color #0) begins with index 1 */
  if ((sIndex < 0) || (sIndex >= STD_COLORS)) sIndex = 0;

  return (sIndex);
} /* IndexFromColor32 */

/*****************************************************************************/

LOCAL VOID draw_field (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, FATTR *fattr, WORD strwidth, WORD edobj, WORD bk_color)
{
  BOOLEAN   b3D;
  WORD      max_y, index, effects;
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
  EDFIELD   *ed_field;
  SYSMASK   *sysmask;

  sysmask  = mask_spec->mask;
  ed_field = &mask_spec->ed_field [edobj];
  mfield   = &mobject->mfield;
  flags    = mfield->flags;
  effects  = (mfield->flags & MF_NOCLEAR) ? TXT_LIGHT : TXT_NORMAL;
  b3D      = (dlg_colors >= 16) && (sysmask->flags & SM_SHOW_3D);

  if (ed_field->flags & COL_HIDDEN) return;

  rect2xywh (r, &x, &y, &w, &h);
  vsl_color (out_handle, mfield->color);
  vst_color (out_handle, mfield->color);
  vst_effects (out_handle, effects);

  fontdesc.font    = mfield->font;
  fontdesc.point   = mfield->point;
  fontdesc.effects = TXT_NORMAL;
  fontdesc.color   = mfield->color;

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
    case MT_LCHECKBOX   : DrawCheckRadio (out_handle, r, &clip, p, 0, NORMAL, bk_color, &fontdesc, FALSE);
                          break;
    case MT_RCHECKBOX   : vswr_mode (out_handle, b3D || (mfield->flags & MF_TRANSPARENT) ? MD_TRANS : MD_REPLACE);
                          vqt_extent (out_handle, p, extent);
                          h = extent [5] - extent [3];
                          y = r->y + (r->h - h) / 2;
                          v_gtext (out_handle, x, y, p);

                          frame    = *r;
                          frame.x += strwidth;
                          frame.w -= strwidth;

                          DrawCheckRadio (out_handle, &frame, &clip, NULL, 0, NORMAL, bk_color, &fontdesc, FALSE);
                          break;
    case MT_RADIOBUTTON : vst_point (out_handle, mfield->point, &wchar, &hchar, &wbox, &hbox);
                          xywh2rect (x, y + hbox, w, h - hbox, &frame);

                          DrawGroupBox (out_handle, &frame, &clip, p, 0, NORMAL, bk_color, &fontdesc);
                          vst_effects (out_handle, TXT_NORMAL);

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
                              draw_rbutton (out_handle, x + wbox, y, hbox, FALSE, mfield->color, bk_color);
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

  vst_effects (out_handle, TXT_NORMAL);

  if ((out_handle == vdi_handle) &&
      ! IS_BLOB (ed_field->type) &&
      (mask_spec->act_obj >= 0) &&
      (mfield == mask_spec->ed_field [mask_spec->act_obj].mfield))
    m_edit_obj (mask_spec, MO_DRAW, 0, NULL);
  else
    m_draw_field (mask_spec, out_handle, mfield, r, fattr, strwidth, edobj);
} /* draw_field */

/*****************************************************************************/

LOCAL VOID draw_line (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, WORD bk_color)
{
  WORD    xy [4];
  MLINE   *mline;
  WINDOWP window;

  window = mask_spec->window;
  mline  = &mobject->mline;

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

LOCAL VOID draw_box (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, BOOLEAN rounded, BOOLEAN selected, WORD bk_color)
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

  if (selected)                 /* used for selected buttons */
  {
    vswr_mode (out_handle, MD_XOR);
    vsf_interior (vdi_handle, FIS_SOLID);
    vsf_style (vdi_handle, 0);
    vsf_color (vdi_handle, BLACK);
    if (rounded)
      v_rfbox (out_handle, xy);
    else
      vr_recfl (out_handle, xy);
  } /* if */
} /* draw_box */

/*****************************************************************************/

LOCAL VOID draw_text (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color)
{
  WORD      x, y, w, h;
  WORD      minimum, maximum, width;
  WORD      distances [5], effects [3];
  BYTE      *p;
  MTEXT     *mtext;
  SYSMASK   *sysmask;

  sysmask = mask_spec->mask;
  mtext   = &mobject->mtext;

  rect2xywh (r, &x, &y, &w, &h);
  vswr_mode (out_handle, mtext->wrmode);
  vst_color (out_handle, mtext->color);
  vst_effects (out_handle, mtext->effects);
  vqt_font_info (out_handle, &minimum, &maximum, distances, &width, effects);

  p = &sysmask->mask.buffer [mtext->text];
  if (*p) v_gtext (out_handle, x + effects [2], y, p);
} /* draw_text */

/*****************************************************************************/

LOCAL VOID draw_graf (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color)
{
  WORD      pic;
  WORD      xy [10];
  BYTE      *filename;
  PICOBJ    *picobj;
  MGRAF     *mgraf;
  SYSMASK   *sysmask;

  sysmask = mask_spec->mask;
  mgraf   = &mobject->mgraf;

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
    picobj = &mask_spec->spicobj [pic];

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

LOCAL VOID draw_button (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD bk_color)
{
  BOOLEAN   selected;
  WORD      x, y, w, h, i, pos;
  LONGSTR   text;
  FONTDESC  fontdesc;
  BYTE      *p;
  MBUTTON   *mbutton;
  SYSMASK   *sysmask;

  sysmask   = mask_spec->mask;
  mbutton   = &mobject->mbutton;
  selected  = mbutton->flags & MBF_SELECTED;

  if (mbutton->flags & MBF_HIDDEN) return;

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

  DrawButton (out_handle, r, &clip, text, pos, selected ? SELECTED : NORMAL, sys_colors [COLOR_BTNFACE], &fontdesc, FALSE, (mbutton->flags & MBF_ROUNDED) != 0, btn_shadow_width);
} /* draw_button */

/*****************************************************************************/

LOCAL VOID draw_submask (MASK_SPEC *mask_spec, WORD out_handle, MOBJECT *mobject, RECT *r, WORD sub, WORD bk_color)
{
  WORD     x, y, w, h;
  MSUBMASK *msubmask;

  msubmask  = &mobject->msubmask;

  rect2xywh (r, &x, &y, &w, &h);

  line_default (out_handle);
  text_default (out_handle);

  vsl_color (out_handle, msubmask->color);
  vst_color (out_handle, msubmask->color);
  vst_effects (out_handle, TXT_NORMAL);

  draw_rect (out_handle, r);

  if (msubmask->flags & MSM_SHOW_TABLE)
    sm_as_table (mask_spec, out_handle, msubmask, r, sub);
  else
    sm_as_mask (mask_spec, out_handle, msubmask, r, sub);
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
  m_draw_cr (out_handle, x, y, hbox, selected, color, TRUE, bk_color);
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
  m_draw_cr (out_handle, x, y, hbox, selected, color, bk_color, FALSE);
} /* draw_rbutton */

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

LOCAL VOID sm_as_mask (MASK_SPEC *mask_spec, WORD out_handle, MSUBMASK *msubmask, RECT *r, WORD sub)
{
  WORD     h;
  RECT     rc, old_clip, frame;
  STRING   s;
  SUBMASK  *submask;

  submask   = &mask_spec->Submask [sub];
  mask_spec = submask->pMaskSpec;		/* get mask_spec of submask and use it as new mask_spec */
  frame     = *r;
  old_clip  = clip;

  if (mask_spec == NULL) return;		/* no mask_spec pointer, if sql statement in mu_sql_init could not be executed */

  if (! (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_SELECT)) return;

  frame.x += 1;					/* leave bounding rect untouched */
  frame.y += 1;
  frame.w -= 2;
  frame.h -= 2;

  sprintf (s, " %ld/%ld ", submask->doc.y + 1, submask->doc.h);
  rc = m_calc_sm_attr (out_handle, submask, &frame, SM_ATTR_RECCOUNT, &h);

  draw_rect (out_handle, &rc);

  rc.x += 1;
  rc.y += 1;
  rc.w -= 2;
  rc.h -= 2;

  DrawString (out_handle, &rc, &clip, s, FAILURE, NORMAL | SS_CENTER | SS_OUTSIDE, FAILURE, NULL);

  rc = m_calc_sm_attr (out_handle, submask, &frame, SM_ATTR_HSLIDER, &h);

  frame.h -= submask->yfac - 1;			/* leave space for scroll bar */

  ScrollBar_SetRect (submask->hsb, &rc, FALSE);
  DrawScrollBar (out_handle, &rc, &clip, submask->hsb);

  rc_intersect (&frame, &clip);
  set_clip (TRUE, &clip);

  draw_mask (mask_spec, out_handle);

  set_clip (TRUE, &old_clip);
} /* sm_as_mask */

/*****************************************************************************/

LOCAL VOID sm_as_table (MASK_SPEC *mask_spec, WORD out_handle, MSUBMASK *msubmask, RECT *r, WORD sub)
{
  BOOLEAN    mode, more;
  WORD       i, j, ret, table;
  WORD       xfac, yfac, y, w, h;
  WORD       text_x, text_y, text_width, text_height;
  WORD       xy [4];
  WORD       width;
  LONG       x, steps;
  RECT       rc, save, old_clip, frame;
  LONGSTR    s, line;
  TABLE_INFO table_info;
  BYTE       *p, *q;
  VOID       *buffer;
  SUBMASK    *submask;

  submask   = &mask_spec->Submask [sub];
  mask_spec = submask->pMaskSpec;		/* get mask_spec of submask and use it as new mask_spec */
  xfac      = submask->xfac;
  yfac      = submask->yfac;
  frame     = *r;

  if (mask_spec == NULL) return;		/* no mask_spec pointer, if sql statement in mu_sql_init could not be executed */

  if (! (db_acc_table (mask_spec->db->base, rtable (mask_spec->table)) & GRANT_SELECT)) return;

  v_tableinfo (mask_spec->db, mask_spec->table, &table_info);
  buffer = mem_alloc (table_info.size);
  if (buffer == NULL) return;

  frame.x += 1;					/* leave bounding rect untouched */
  frame.y += 1;
  frame.w -= 2;
  frame.h -= 2;

  clear_area (out_handle, &frame);

  rc = m_calc_sm_attr (out_handle, submask, &frame, SM_ATTR_VSLIDER, &h);

  h = (frame.h - submask->yscroll) / yfac;	/* don't use header */
  ScrollBar_SetPageSize (submask->hsb, h, FALSE);
  ScrollBar_SetRect (submask->hsb, &rc, FALSE);
  DrawScrollBar (out_handle, &rc, &clip, submask->hsb);

  frame.w -= yfac;				/* leave space for scroll bar */

  ltoa (submask->doc.h, s, 10);

  line_default (out_handle);
  text_default (out_handle);
  vst_font (out_handle, msubmask->font);
  vst_point (out_handle, msubmask->point, &ret, &ret, &ret, &ret);
  vst_color (out_handle, msubmask->color);
  vst_effects (out_handle, TXT_THICKENED);

  old_clip = clip;
  rc_intersect (&frame, &clip);
  set_clip (TRUE, &clip);

  if (submask->yscroll > 0)
  {
    if (submask->xscroll > 0)
    {
      xywh2rect (frame.x, frame.y, submask->xscroll, submask->yscroll, &rc);
      fill_rect (&rc, sys_colors [COLOR_BTNFACE], show_pattern);
      draw_3d_rect (&rc, WHITE, BLACK);

      strcpy (s, "#");
      m_text_extent (out_handle, s, TRUE, &text_width, &text_height);

      text_x = frame.x + submask->xscroll - text_width - xfac / 2;
      text_y = frame.y + 2;
      vswr_mode (out_handle, MD_TRANS);
      v_text (out_handle, text_x, text_y, s);
      vswr_mode (out_handle, MD_REPLACE);
    } /* if */

    p = submask->colheader;
    x = frame.x + submask->xscroll;

    for (j = 0; j < submask->cols; j++, x += w)			/* paint header */
    {
      width = submask->colwidth [j];
      w     = abs (width) * xfac;

      if (*p == EOS) break;
      q = s;
      while (*p != COLUMNSEP) *q++ = *p++;
      *q = EOS;
      p++;

      if ((x + w > clip.x) && (x <= clip.x + clip.w))
      {
        save = clip;
        rc   = frame;
        rc_intersect (&rc, &clip);		        	/* don't paint over left column */
        set_clip (TRUE, &clip);

        xywh2rect ((WORD)x, frame.y, w, submask->yscroll, &rc);
        fill_rect (&rc, sys_colors [COLOR_BTNFACE], show_pattern);
        draw_3d_rect (&rc, WHITE, BLACK);

        m_text_extent (out_handle, s, TRUE, &text_width, &text_height);

        text_x = (WORD)x + xfac / 2 + 1;
        text_y = frame.y + 2;
        vswr_mode (out_handle, MD_TRANS);

        if (text_width > w - xfac)				/* use clipping */
        {
          xywh2rect (text_x, text_y, w - xfac, yfac, &rc);
          rc_intersect (&clip, &rc);
          set_clip (TRUE, &rc);
          v_text (out_handle, text_x, text_y, s);
        } /* if */
        else
        {
          if (width > 0)
            text_x = (WORD)x + w - text_width - xfac / 2 - 1;	/* right aligned */

          v_text (out_handle, text_x, text_y, s);
        } /* else */

        vswr_mode (out_handle, MD_REPLACE);
        set_clip (TRUE, &save);
      } /* if */
    } /* for */
  } /* if */

  x = frame.x + submask->xscroll + (submask->doc.w - submask->doc.x) * xfac;

  mode = set_alert (TRUE);                      /* alert boxes as dialog boxes */

  db_beg_trans (mask_spec->db->base, FALSE);

  y    = frame.y + submask->yscroll;
  h    = (frame.h - submask->yscroll + yfac - 1) / yfac;		/* don't use header */
#if 0
  h    = (frame.h - submask->yscroll) / yfac;				/* snap to full lines */
#endif
  more = TRUE;

  steps = submask->doc.y - submask->act_rec;
  submask->act_rec += steps;

  if (steps != 0) v_movecursor (mask_spec->db, mask_spec->cursor, mask_spec->dir * steps);
  if (submask->doc.y == 0) v_initcursor (mask_spec->db, mask_spec->table, mask_spec->inx, mask_spec->dir, mask_spec->cursor);

  for (i = 0; (i < h) && more; i++)		/* paint the data lines */
  {
    x = frame.x + submask->xscroll - submask->doc.x * xfac;
    p = line;

    if (v_movecursor (mask_spec->db, mask_spec->cursor, (LONG)mask_spec->dir)) /* move to new records */
    {
      if (i < MAX_ADR) submask->recaddr [i] = v_readcursor (mask_spec->db, mask_spec->cursor, NULL);

      if (! v_read (mask_spec->db, mask_spec->table, buffer, mask_spec->cursor, 0L, FALSE))
        db_fillnull (mask_spec->db->base, rtable (mask_spec->table), buffer);
      else
        if (use_calc) v_execute (mask_spec->db, mask_spec->table, NULL, buffer, submask->doc.y + i + 1, NULL);

      rec_to_line (submask->pMaskSpec->db, submask->pMaskSpec->table, buffer,
                   submask->cols, submask->columns, submask->colwidth, LONGSTRLEN, line);

      submask->act_rec++;
    } /* if */
    else
      more = FALSE;

    if (more)
    {
      if ((frame.x + submask->xscroll > clip.x) && (frame.x <= clip.x + clip.w) &&
          (y + yfac > clip.y) && (y < clip.y + clip.h))
      {
        xywh2rect (frame.x, y, submask->xscroll, yfac, &rc);
        fill_rect (&rc, sys_colors [COLOR_BTNFACE], show_pattern);
        draw_3d_rect (&rc, WHITE, BLACK);

        vswr_mode (out_handle, MD_TRANS);
        vst_effects (out_handle, TXT_THICKENED);
        ltoa (submask->doc.y + i + 1, s, 10);
        m_text_extent (out_handle, s, TRUE, &text_width, &text_height);

        text_x = frame.x + submask->xscroll - text_width - xfac / 2;
        text_y = y + 2;
        v_text (out_handle, text_x, text_y, s);
        vswr_mode (out_handle, MD_REPLACE);
      } /* if */

      for (j = 0; j < submask->cols; j++, x += w)			/* get every single column */
      {
        width = submask->colwidth [j];
        w     = abs (width) * xfac;

        q = s;
        while (*p != COLUMNSEP) *q++ = *p++;
        *q = EOS;
        p++;

        if (rtable (mask_spec->table) == SYS_DELETED)
        {
          table = (WORD)atoi (s);
          if (submask->columns [j] == 2) table_name (mask_spec->db, table, s);
        } /* if */

        if ((x + w > clip.x) && (x <= clip.x + clip.w) &&
            (y + yfac > clip.y) && (y < clip.y + clip.h))
        {
          save = clip;
          rc   = frame;
          rc_intersect (&rc, &clip);		        	/* don't paint over left column */
          set_clip (TRUE, &clip);

          if (show_grid)
          {
            xywh2rect ((WORD)x, y, w, yfac, &rc);
            draw_border (&rc);
          } /* if */

          vswr_mode (out_handle, MD_TRANS);
          vst_effects (out_handle, TXT_NORMAL);
          m_text_extent (out_handle, s, TRUE, &text_width, &text_height);

          text_x = (WORD)x + xfac / 2 + 1;
          text_y = y + 2;

          if (text_width > w - xfac)				/* use clipping */
          {
            xywh2rect (text_x, text_y, w - xfac, yfac, &rc);
            rc_intersect (&clip, &rc);
            set_clip (TRUE, &rc);
            v_text (out_handle, text_x, text_y, s);
          } /* if */
          else
          {
            if (width > 0)
              text_x = (WORD)x + w - text_width - xfac / 2 - 1;	/* right aligned */

            v_text (out_handle, text_x, text_y, s);
          } /* else */

          vswr_mode (out_handle, MD_REPLACE);
          set_clip (TRUE, &save);
        } /* if */
      } /* for */

      if (submask->sel_obj == i)
      {
        xywh2rect (frame.x + submask->xscroll, frame.y + submask->yscroll + i * yfac + 1, min (frame.w, (submask->doc.w - submask->doc.x) * xfac), yfac - 3, &rc);
        vswr_mode (out_handle, MD_XOR);
        vsf_interior (out_handle, FIS_SOLID);
        vsf_color (out_handle, BLACK);
        rect2array (&rc, xy);
        vr_recfl (out_handle, xy);
        vswr_mode (out_handle, MD_REPLACE);
      } /* if */

      y += yfac;
    } /* if */
  } /* for */

  db_end_trans (mask_spec->db->base);

  mem_free (buffer);

  set_clip (TRUE, &old_clip);
  set_alert (mode);                             /* restore old mode */
} /* sm_as_table */

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
    vsf_color (out_handle, WHITE);              /* Farbe weiž */
    rect2array (&r, xy);                        /* Bereich setzen */
    vr_recfl (out_handle, xy);                  /* Bereich l”schen */
  } /* if */
} /* clear_area */

/*****************************************************************************/

LOCAL VOID fill_rect (RECT *rc, WORD color, BOOLEAN show_pattern)
{
  RECT r;
  WORD xy [8];

  r = *rc;

  rect2array (&r, xy);
  vswr_mode (vdi_handle, MD_REPLACE);
  vsf_color (vdi_handle, (dlg_colors < 16) ? WHITE : color);
  vsf_interior (vdi_handle, FIS_SOLID);
  vsf_perimeter (vdi_handle, FALSE);

  if (show_pattern)
    if ((color == sys_colors [COLOR_BTNFACE]) && (dlg_colors < 16))
    {
      vsf_color (vdi_handle, BLACK);
      vsf_interior (vdi_handle, FIS_PATTERN);
      vsf_style (vdi_handle, 1);
    } /* if, if */

  vr_recfl (vdi_handle, xy);			/* fill the interior */
} /* fill_rect */

/*****************************************************************************/

LOCAL VOID draw_3d_rect (RECT *rc, WORD color_highlight, WORD color_shadow)
{
  WORD xy [6];

  xy [0] = rc->x;
  xy [1] = rc->y + rc->h - 1;
  xy [2] = xy [0];
  xy [3] = rc->y;
  xy [4] = rc->x + rc->w - 1;
  xy [5] = xy [3];

  vswr_mode (vdi_handle, MD_REPLACE);
  vsl_type (vdi_handle, SOLID);
  vsl_color (vdi_handle, color_highlight);

  if (dlg_colors >= 16)
    v_pline (vdi_handle, 3, xy);

  xy [0] = rc->x + rc->w - 1;
  xy [1] = rc->y;
  xy [2] = xy [0];
  xy [3] = rc->y + rc->h - 1;
  xy [4] = rc->x;
  xy [5] = xy [3];

  vsl_color (vdi_handle, color_shadow);
  v_pline (vdi_handle, 3, xy);
} /* draw_3d_rect */

/*****************************************************************************/

LOCAL VOID draw_border (RECT *rc)
{
  WORD xy [6];

  vswr_mode (vdi_handle, MD_REPLACE);

  if (colors >= 16)
    vsl_color (vdi_handle, DWHITE);             /* grey line */
  else
  {
    vsl_color (vdi_handle, BLACK);
    vsl_type (vdi_handle, USERLINE);            /* dotted line */
    vsl_udsty (vdi_handle, 0xAAAA);
  } /* else */

  xy [0] = rc->x + rc->w - 1;
  xy [1] = rc->y;
  xy [2] = xy [0];
  xy [3] = rc->y + rc->h - 1;
  xy [4] = rc->x;
  xy [5] = xy [3];

  v_pline (vdi_handle, 3, xy);
} /* draw_border */

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

