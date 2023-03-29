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
 * 19.01.04: m_click erweitert damit mit Funktion auf rechter Maustaste.
 * 08.08.02: Ausgabefelder werden nicht automatisch auf MT_UNDERLINED gesetzt.
 * 16.03.97: GetPicFilename added
 * 10.03.97: m_updpicfile added
 * 21.09.95: Variable hbox corrected in get_fattr
 * 28.07.95: Call to function rc_inflate added in m_obj_clear and hndl_mobj
 * 20.07.95: 3D functionality added to m_get_rect
 * 06.10.94: ERR_JOINMASK deleted in add_field
 * 23.09.94: Handling of submasks added in m_get_rect
 * 20.09.94: Handling of submasks (MIMASK) added
 * 03.08.94: tablename = dstmask->tablename added in hndl_mobj
 * 20.11.93: GetFontDialog used instead of mselfont
 * 10.11.93: Variable fontspec used in interface to set_objfont
 * 23.10.93: IndexFromColor32 & Color32FromIndex added
 * 12.09.93: Update of toolbar corrected in handle_menu
 * 09.09.93: Modifications for user defined buttons added
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
#include "menu.h"
#include "mmaskinf.h"
#include "mselbutt.h"
#include "mselfill.h"
#include "mselsubm.h"
#include "mseltext.h"

#include "export.h"
#include "mclick.h"

/****** DEFINES **************************************************************/

#define BUTTON_SIZE       13	/* width and height of checkboxes and radio buttons in resource file */
#define BUTTONL_WIDTH     16	/* width and height of low resolution checkboxes and radio buttons */
#define BUTTONL_HEIGHT     8	/* width and height of low resolution checkboxes and radio buttons */

#define MIN_WICON  16	/* see smallest checkbox/rb icons in resource file */
#define MIN_HICON   5	/* see smallest checkbox/rb icons in resource file */

#define STD_COLORS 16	/* use 16 standard colors for tables, mask background etc. */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    get_fattr    _((WORD out_handle, WORD factor, WORD wbox, WORD hbox, FATTR *fattr));
LOCAL BOOLEAN put_rect     _((MASK_SPEC *mask_spec, MOBJECT *mobject, WORD grid_x, WORD grid_y, RECT *diff));
LOCAL WORD    find_obj     _((WINDOWP window, MKINFO *mk));

LOCAL VOID    rub_box      _((MKINFO *mk, RECT *r));
LOCAL VOID    hndl_line    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    hndl_box     _((WINDOWP window, MKINFO *mk, BOOLEAN rounded));
LOCAL VOID    hndl_text    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    hndl_graf    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    hndl_button  _((WINDOWP window, MKINFO *mk));
LOCAL VOID    hndl_mask    _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN hndl_mobj    _((WINDOWP src_window, WINDOWP dst_window, WORD class, MOBJECT *mobject, RECT *diff, MKINFO *mk, RECT *r));
LOCAL VOID    hndl_objs    _((WINDOWP src_window, WINDOWP dst_window, SET objs, RECT *all, RECT *diff, MKINFO *mk));

LOCAL VOID    drag_objs    _((WINDOWP window, SET objs, MKINFO *mk));
LOCAL VOID    drag_line    _((RECT *r, RECT *diff, RECT *bound, WORD x_raster, WORD y_raster));
LOCAL VOID    draw_line    _((RECT *r, RECT *diff));
LOCAL VOID    fill_select  _((WINDOWP window, SET objs, RECT *area));
LOCAL VOID    invert_objs  _((WINDOWP window, SET objs));
LOCAL VOID    rubber_objs  _((WINDOWP window, MKINFO *mk));

LOCAL BOOLEAN field_exists _((MASK_SPEC *mask_spec, BYTE *tablename, BYTE *fieldname));

/*****************************************************************************/

GLOBAL VOID m_click (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN   ok, bSelected;
  WORD      old_tool;
  WORD      obj, menu_height;
  WORD      x, y;
  RECT      r;
  SET       new_objs;
  FONTDESC  fontdesc;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  obj       = NIL;

  if (sel_window != window) unclick_window (sel_window);

  if (inside (mk->mox, mk->moy, &window->scroll))       /* inside scroll area */
  {
    if (mask_spec->tool == MIARROW)
      obj = find_obj (window, mk);
    else
    {
      unclick_window (window);
/* [GS] 5.1d Start: */
			if ( mk->momask & 0x0002 )												/* Rechter Mausknopf	*/
			{
	      old_tool = mask_spec->tool;
	
	      menu_height   = (window->menu != NULL) ? gl_hattr : 0;
	      maskicon->ob_x = window->work.x;
	      maskicon->ob_y = window->work.y + menu_height;
	
	      mask_spec->tool = MIARROW;
	      window->mousenum = ARROW;
	
				set_mouse (ARROW, NULL);
        objc_offset (maskicon, old_tool, &x, &y);
        xywh2rect (x, y, maskicon [old_tool].ob_width, maskicon [old_tool].ob_height, &r);
        redraw_window (window, &r);
	
        objc_offset (maskicon, mask_spec->tool, &x, &y);
        xywh2rect (x, y, maskicon [mask_spec->tool].ob_width, maskicon [mask_spec->tool].ob_height, &r);
        redraw_window (window, &r);
			}
			else
			{
/* Ende */
      ok = ((mk->mobutton & 0x0001) != 0) || (mask_spec->tool == MITEXT);

      if ((mk->breturn == 1) && ok)
        switch (mask_spec->tool)
        {
          case MILINE   : hndl_line (window, mk);       break;
          case MIBOX    : hndl_box (window, mk, FALSE); break;
          case MIRBOX   : hndl_box (window, mk, TRUE);  break;
          case MITEXT   : hndl_text (window, mk);       break;
          case MIGRAF   : hndl_graf (window, mk);       break;
          case MIBUTTON : hndl_button (window, mk);     break;
          case MIMASK   : hndl_mask (window, mk);       break;
        } /* switch, if */
/* [GS] 5.1d Start: */
      } /* else */
/* Ende */
    } /* else */
  } /* if */
  else
    if (inside (mk->mox, mk->moy, &window->work))       /* handle icons */
    {
      old_tool = mask_spec->tool;

      menu_height   = (window->menu != NULL) ? gl_hattr : 0;
      maskicon->ob_x = window->work.x;
      maskicon->ob_y = window->work.y + menu_height;

      obj = objc_find (maskicon, ROOT, MAX_DEPTH, mk->mox, mk->moy);
      if ((MIARROW <= obj) && (obj <= MIMASK)) mask_spec->tool = obj;

      if (old_tool != mask_spec->tool)
      {
        objc_offset (maskicon, old_tool, &x, &y);
        xywh2rect (x, y, maskicon [old_tool].ob_width, maskicon [old_tool].ob_height, &r);
        redraw_window (window, &r);

        objc_offset (maskicon, mask_spec->tool, &x, &y);
        xywh2rect (x, y, maskicon [mask_spec->tool].ob_width, maskicon [mask_spec->tool].ob_height, &r);
        redraw_window (window, &r);
      } /* if */

      switch (mask_spec->tool)
      {
        case MIARROW  : window->mousenum = ARROW;      break;
        case MILINE   :
        case MIBOX    :
        case MIRBOX   :
        case MIBUTTON :
        case MIMASK   :
        case MIGRAF   : window->mousenum = THIN_CROSS; break;
        case MITEXT   : window->mousenum = TEXT_CRSR;  break;
        default       : window->mousenum = ARROW;      break;
      } /* switch */

      if (mk->breturn == 2)
      {
        switch (obj)
        {
          case MIFONT   :
          case MIPOINT  :
          case MITEXT   :
          case MIMASK   : fontdesc.font    = mask_spec->font;
                          fontdesc.point   = mask_spec->point;
                          fontdesc.effects = TXT_NORMAL;
                          fontdesc.color   = mask_spec->color;

                          bSelected = GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_HIDE_EFFECTS | FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc);

                          if (bSelected)
                          {
                            mask_spec->font  = fontdesc.font;
                            mask_spec->point = fontdesc.point;
                            mask_spec->color = fontdesc.color;
                          } /* if */
                          break;
          case MIBOX    :
          case MIRBOX   :
          case MIBUTTON :
          case MIFILL   : bSelected = mselfill (&mask_spec->color, &mask_spec->fill_style, &mask_spec->fill_index);
                          break;
          case MILINE   :
          case MILINES  : bSelected = mselline (&mask_spec->line_type,
                                                &mask_spec->line_width,
                                                &mask_spec->line_bstyle,
                                                &mask_spec->line_estyle);
                          break;
        } /* switch */

        if (bSelected && mask_spec->show_tools)
        {
          xywh2rect (maskicon->ob_x, maskicon->ob_y, maskicon->ob_width, maskicon->ob_height, &r);
          set_redraw (window, &r);
        } /* if */
      } /* if */

      return;
    } /* if, else */

  if (obj != NIL)
  {
    sel.class = SEL_MOBJ;
    setclr (new_objs);
    setincl (new_objs, obj);                            /* actual object */

    if (mk->shift)
    {
      invert_objs (window, new_objs);
      setxor (sel_objs, new_objs);
      if (! setin (sel_objs, obj)) obj = NIL;           /* deselect */
    } /* if */
    else
    {
      if (! setin (sel_objs, obj))                      /* deselect old objects */
      {
        invert_objs (window, sel_objs);
        setclr (sel_objs);
        invert_objs (window, new_objs);
      } /* if */

      setor (sel_objs, new_objs);
    } /* else */

    sel_window = setcmp (sel_objs, NULL) ? NULL : window;

    if ((sel_window != NULL) && (obj != NIL))
    {
      if ((mk->breturn == 1) && (mk->mobutton & 0x003)) /* drag operation */
        drag_objs (window, sel_objs, mk);

      if (mk->breturn == 2)                             /* double clicking on object */
        if (window->objop != NULL)
            (*window->objop) (sel_window, sel_objs, OBJ_OPEN);
    } /* if */
  } /* if */
  else
    if (mask_spec->tool == MIARROW)
      if (inside (mk->mox, mk->moy, &window->scroll))					/* inside scroll area */
      {
        if (! (mk->shift || mk->ctrl)) unclick_window (window); 			/* deselect */
        if ((mk->breturn == 1) && (mk->mobutton & 0x0001)) rubber_objs (window, mk);	/* rubber band operation */
        if (mk->breturn == 2) mmaskinfo (mask_spec);					/* double clicking on scroll area with no object */
      } /* if, if, else */
} /* m_click */

/*****************************************************************************/

GLOBAL VOID m_unclick (window)
WINDOWP window;

{
  invert_objs (window, sel_objs);

  sel.class = SEL_NONE;
  sel.table = FAILURE;
  sel.field = FAILURE;
  sel.key   = FAILURE;
} /* m_unclick */

/*****************************************************************************/

GLOBAL WORD m_get_rect (window, out_handle, class, mobject, rect, fattr)
WINDOWP window;
WORD    out_handle;
WORD    class;
MOBJECT *mobject;
RECT    *rect;
FATTR   *fattr;

{
  WORD      x, y, w, h, strwidth;
  WORD      xy [4];
  WORD      wchar, hchar;
  WORD      wbox, hbox;
  WORD      minimum, maximum, width;
  WORD      distances [5], effects [3];
  WORD      extent [8];
  UWORD     flags;
  STRING    s;
  BYTE      *p;
  MFIELD    *mfield;
  MLINE     *mline;
  MTEXT     *mtext;
  MSUBMASK  *msubmask;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mfield    = &mobject->mfield;
  mline     = &mobject->mline;
  mtext     = &mobject->mtext;
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
                     if (out_handle == vdi_handle)
                       if (flags & MF_SYSTEMFONT) vst_point (out_handle, gl_point, &wchar, &hchar, &wbox, &hbox);

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
                       case MT_POPUP       : get_fattr (out_handle, mask_spec->factor, wbox, hbox, fattr);
                       default             : x -= EDIT_FRAME;
                                             y -= EDIT_FRAME;
                                             w += 2 * EDIT_FRAME + fattr->w_shadow + fattr->w_attr;
                                             h += 2 * EDIT_FRAME + fattr->h_shadow;
                                             break;
                     } /* switch */

                     xywh2rect (x, y, w + strwidth, h, rect);
                     break;
    case M_LINE    : xy [0] = (LONG)mline->x1 * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
                     xy [1] = (LONG)mline->y1 * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;
                     xy [2] = (LONG)mline->x2 * gl_wbox / M_XUNITS - window->doc.x * window->xfac + window->scroll.x;
                     xy [3] = (LONG)mline->y2 * gl_hbox / M_YUNITS - window->doc.y * window->yfac + window->scroll.y;

                     array2rect (xy, rect);
                     if (rect->w < 4) rect->w = 4;       /* for better gripping with mouse */
                     if (rect->h < 4) rect->h = 4;

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
    case M_SUBMASK : text_default (out_handle);
                     vst_font (out_handle, msubmask->font);
                     vst_point (out_handle, msubmask->point, &wchar, &hchar, &wbox, &hbox);
                     if (out_handle == vdi_handle)
                       if (msubmask->flags & MF_SYSTEMFONT) vst_point (out_handle, gl_point, &wchar, &hchar, &wbox, &hbox);

                     xywh2rect (x, y, w, h, rect);
                     break;
    case M_TEXT    : text_default (out_handle);
                     vst_effects (out_handle, mtext->effects);
                     vst_font (out_handle, mtext->font);
                     vst_point (out_handle, mtext->point, &wchar, &hchar, &wbox, &hbox);
                     if (out_handle == vdi_handle)
                       if (mtext->flags & MF_SYSTEMFONT) vst_point (out_handle, gl_point, &wchar, &hchar, &wbox, &hbox);
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

GLOBAL VOID m_get_doc (window, docw, doch)
WINDOWP window;
LONG    *docw, *doch;

{
  LONG      w, h;
  WORD      xy [4];
  WORD      x, y, obj, ret;
  RECT      r, rect;
  FATTR     fattr;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  w = 0;
  h = 0;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;
    m_get_rect (window, vdi_handle, mfield->class, mobject, &r, &fattr);

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

GLOBAL VOID m_obj_clear (window, class, objs)
WINDOWP window;
WORD    class;
SET     objs;

{
  BOOLEAN   b3D;
  WORD      obj, end;
  RECT      r;
  FATTR     fattr;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  if (class != SEL_MOBJ) return;

  invert_objs (window, objs);

  mask_spec = (MASK_SPEC *)window->special;
  sysmask  = &mask_spec->mask;
  end      = mask_spec->objs;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  mobject  = &mobject [end - 1];

  for (obj = end - 1; obj >= 0; obj--, mobject--)
    if (setin (objs, obj))
    {
      mfield = &mobject->mfield;
      b3D    = (dlg_colors >= 16) && (sysmask->flags & SM_SHOW_3D);

      m_get_rect (window, vdi_handle, mfield->class, mobject, &r, &fattr);

      if (b3D) rc_inflate (&r, 1, 1);
      set_redraw (window, &r);
      del_mobject (mask_spec, obj);
    } /* if, for */

  setclr (objs);
  unclick_window (window);
} /* m_obj_clear */

/*****************************************************************************/

GLOBAL VOID m_snap_obj (mask_spec, mobject, grid_x, grid_y)
MASK_SPEC *mask_spec;
MOBJECT   *mobject;
WORD      grid_x, grid_y;

{
  RECT r;

  xywh2rect (0, 0, 0, 0, &r);
  put_rect (mask_spec, mobject, grid_x, grid_y, &r);
} /* m_snap_obj */

/*****************************************************************************/

GLOBAL WORD m_addfield (window, base_spec, table, field, r)
WINDOWP   window;
BASE_SPEC *base_spec;
WORD      table;
WORD      field;
RECT      *r;

{
  WORD       x, y, w, h;
  WORD       snap_y;
  WORD       wchar, hchar;
  WORD       wbox, hbox;
  WORD       font, point, type, obj;
  LONG       lower, upper, maxw;
  UWORD      flags;
  TABLENAME  table_name;
  FIELDNAME  field_name;
  STRING     label_name;
  MFIELD     mfield;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  v_tableinfo (base_spec, table, &table_info);
  v_fieldinfo (base_spec, table, field, &field_info);

  if (mask_spec->mask.tablename [0] == EOS) strcpy (mask_spec->mask.tablename, table_info.name);
  if (strcmp (mask_spec->mask.tablename, table_info.name) != 0) strcpy (table_info.name, mask_spec->mask.tablename);	/* was ERR_JOINMASK formerly */

  snap_y = gl_hbox * mask_spec->grid_y / M_YUNITS;
  r->y   = (r->y + snap_y - 1) / snap_y * snap_y;
  type   = field_info.type;

  x = r->x - window->scroll.x + window->doc.x * window->xfac;
  y = r->y - window->scroll.y + window->doc.y * window->yfac;
  w = std_width [field_info.type];
  h = 1;

  if (IS_BLOB (type) || IS_PICTURE (type))      /* default for pictures etc. */
  {
    w = 40;
    h = 10;
  } /* if */
  else
    if (w == 0)                                 /* default for strings etc. */
    {
      maxw = field_info.size - 1;               /* don't use EOS */
      if (maxw > 32767) maxw = 32767;
      w = maxw;

      if (w > 60)
      {
        h = w / 40 + 1;
        w = 40;
        if (h > 25) h = 25;                     /* 25 lines max default */
      } /* if */
    } /* if */
    else                                        /* numbers etc... use format */
      w = strlen (base_spec->sysformat [field_info.format].format);

  font  = mask_spec->font;
  point = mask_spec->point;

  set_null (TYPE_LONG, &lower);
  set_null (TYPE_LONG, &upper);

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);

  type  = MT_OUTLINED;
  if (h > 1) type = MT_OUTLINED;
  flags = MF_STDLABEL;
  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  strcpy (table_name, table_info.name);
  strcpy (field_name, field_info.name);
  strcpy (label_name, "");

  mfield.class      = M_FIELD;
  mfield.x          = x * M_XUNITS / gl_wbox;
  mfield.y          = y * M_YUNITS / gl_hbox;
  mfield.w          = w;
  mfield.h          = h;
  mfield.table_name = FAILURE;      /* will be set in add_mobject */
  mfield.field_name = FAILURE;      /* will be set in add_mobject */
  mfield.label_name = FAILURE;      /* will be set in add_mobject */
  mfield.font       = font;
  mfield.point      = point;
  mfield.color      = mask_spec->color;
  mfield.lower      = lower;
  mfield.upper      = upper;
  mfield.type       = type;
  mfield.extra      = FAILURE;
  mfield.flags      = flags;

  y    = r->y + 2 * EDIT_FRAME + 2 + h * hbox;
  r->y = (y + snap_y - 1) / snap_y * snap_y;

  return (add_mobject (mask_spec, (MOBJECT *)&mfield, table_name, field_name, label_name, NULL, &obj));
} /* m_addfield */

/*****************************************************************************/

GLOBAL WORD m_name2picobj (mask_spec, filename)
MASK_SPEC *mask_spec;
BYTE      *filename;

{
  WORD   i;
  PICOBJ *picobj;

  picobj = mask_spec->picobj;

  for (i = 0; i < mask_spec->picptr; i++, picobj++)
    if (strcmp (filename, picobj->filename) == 0) return (i);

  return (FAILURE);
} /* m_name2picobj */

/*****************************************************************************/

GLOBAL VOID m_updpicfile (mask_spec, pic)
MASK_SPEC *mask_spec;
WORD      pic;

{
  WORD    obj;
  RECT    r;
  FATTR   fattr;
  BYTE    *pFilename;
  PICOBJ  *picobj;
  MGRAF   *mgraf;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask = &mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  picobj  = &mask_spec->picobj [pic];

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mgraf = &mobject->mgraf;

    if (mgraf->class == M_GRAF)
    {
      pFilename = &sysmask->mask.buffer [mgraf->filename];

      if (strcmp (pFilename, picobj->filename) == 0)
      {
        m_get_rect (mask_spec->window, vdi_handle, mgraf->class, mobject, &r, &fattr);
        set_redraw (mask_spec->window, &r);
      } /* if */
    } /* if */
  } /* for */
} /* m_updpicfile */

/*****************************************************************************/

GLOBAL VOID obj2pos (mask_spec, obj, r)
MASK_SPEC *mask_spec;
WORD      obj;
RECT      *r;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;

  sysmask = &mask_spec->mask;
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
} /* obj2pos */

/*****************************************************************************/

GLOBAL VOID pos2obj (mask_spec, obj, r)
MASK_SPEC *mask_spec;
WORD      obj;
RECT      *r;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;

  sysmask = &mask_spec->mask;
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
} /* pos2obj */

/*****************************************************************************/

GLOBAL VOID set_objfont (window, fontdesc)
WINDOWP  window;
FONTDESC *fontdesc;

{
  BOOLEAN   sysfont;
  UWORD     flag;
  WORD      obj;
  WORD      wchar, hchar, wbox, hbox;
  MFIELD    *mfield;
  MTEXT     *mtext;
  MBUTTON   *mbutton;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  vst_font (vdi_handle, fontdesc->font);
  vst_point (vdi_handle, fontdesc->point, &wchar, &hchar, &wbox, &hbox);

  sysfont = (fontdesc->font == FONT_SYSTEM) && (fontdesc->point == gl_point) && (wchar == gl_wchar);
  flag    = sysfont ? MF_SYSTEMFONT : 0;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    if (setin (sel_objs, obj))
    {
      mfield   = &mobject->mfield;
      mtext    = &mobject->mtext;
      mbutton  = &mobject->mbutton;
      msubmask = &mobject->msubmask;

      switch (mfield->class)
      {
        case M_FIELD   : mfield->font   = fontdesc->font;
                         mfield->point  = fontdesc->point;
/* GS 5.1 Start */
                         mfield->color  = fontdesc->color;
/* Ende */
                         mfield->flags &= ~MF_SYSTEMFONT;
                         mfield->flags |= flag;
                         break;
        case M_TEXT    : mtext->font    = fontdesc->font;
                         mtext->point   = fontdesc->point;
                         mtext->color   = fontdesc->color;
                         mtext->effects = fontdesc->effects;
                         mtext->flags &= ~MF_SYSTEMFONT;
                         mtext->flags |= flag;
                         break;
        case M_BUTTON  : mbutton->font   = fontdesc->font;
                         mbutton->point  = fontdesc->point;
/* GS 5.1 Start */
                         mbutton->color  = fontdesc->color;
/* Ende */
                         mbutton->flags &= ~MF_SYSTEMFONT;
                         mbutton->flags |= flag;
                         break;
        case M_SUBMASK : msubmask->font   = fontdesc->font;
                         msubmask->point  = fontdesc->point;
                         msubmask->flags &= ~MF_SYSTEMFONT;
                         msubmask->flags |= flag;
                         break;
      } /* switch */
    } /* if, for */

  mask_spec->modified = TRUE;
  set_redraw (window, &window->scroll);
} /* set_objfont */

/*****************************************************************************/

GLOBAL VOID set_objfill (window, style, index)
WINDOWP window;
WORD    style;
WORD    index;

{
  WORD      obj;
  MBOX      *mbox;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    if (setin (sel_objs, obj))
    {
      mbox = &mobject->mbox;

      switch (mbox->class)
      {
        case M_BOX  :
        case M_RBOX : mbox->style = style;
                      mbox->index = index;
                      break;
      } /* switch */
    } /* if, for */

  mask_spec->modified = TRUE;
  set_redraw (window, &window->scroll);
} /* set_objfill */

/*****************************************************************************/

GLOBAL VOID set_objcolor (window, color)
WINDOWP window;
WORD    color;

{
  WORD      obj;
  MFIELD    *mfield;
  MLINE     *mline;
  MBOX      *mbox;
  MTEXT     *mtext;
  MBUTTON   *mbutton;
  MSUBMASK  *msubmask;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    if (setin (sel_objs, obj))
    {
      mfield   = &mobject->mfield;
      mline    = &mobject->mline;
      mbox     = &mobject->mbox;
      mtext    = &mobject->mtext;
      mbutton  = &mobject->mbutton;
      msubmask = &mobject->msubmask;

      switch (mfield->class)
      {
        case M_FIELD   : mfield->color    = color; break;
        case M_LINE    : mline->color     = color; break;
        case M_BOX     :
        case M_RBOX    : mbox->color      = color; break;
        case M_TEXT    : mtext->color     = color; break;
        case M_BUTTON  : mbutton->color   = color; break;
        case M_SUBMASK : msubmask->color  = color; break;
      } /* switch */
    } /* if, for */

  mask_spec->modified = TRUE;
  set_redraw (window, &window->scroll);
} /* set_objcolor */

/*****************************************************************************/

GLOBAL VOID set_objline (window, type, width, bstyle, estyle)
WINDOWP window;
WORD    type;
WORD    width;
WORD    bstyle;
WORD    estyle;

{
  WORD      obj;
  MLINE     *mline;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
    if (setin (sel_objs, obj))
    {
      mline = &mobject->mline;

      if (mline->class == M_LINE)
      {
        mline->type   = type;
        mline->width  = width;
        mline->bstyle = bstyle;
        mline->estyle = estyle;
      } /* if */
    } /* if, for */

  mask_spec->modified = TRUE;
  set_redraw (window, &window->scroll);
} /* set_objline */

/*****************************************************************************/

GLOBAL WORD add_str (mask_spec, s)
MASK_SPEC *mask_spec;
BYTE      *s;

{
  WORD len;
  WORD low;
  SYSMASK *sysmask;

  len = strlen (s) + 1;                         /* + EOS */
  low = mask_spec->objs * sizeof (MOBJECT);

  if (low < mask_spec->str - len)
  {
    mask_spec->str -= len;
    sysmask         = &mask_spec->mask;

    strcpy (&sysmask->mask.buffer [mask_spec->str], s);
    return (mask_spec->str);
  } /* if */
  else
    return (FAILURE);
} /* add_str */

/*****************************************************************************/

GLOBAL VOID del_str (mask_spec, index)
MASK_SPEC *mask_spec;
WORD      index;

{
  WORD     len, obj;
  BYTE     *s, *p;
  MFIELD   *mfield;
  MTEXT    *mtext;
  MGRAF    *mgraf;
  MBUTTON  *mbutton;
  MSUBMASK *msubmask;
  MOBJECT  *mobject;
  SYSMASK  *sysmask;

  if (index < 0) return;

  sysmask = &mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  s       = &sysmask->mask.buffer [mask_spec->str];
  p       = &sysmask->mask.buffer [index];
  len     = strlen (p) + 1;                     /* + EOS */
  mem_move (s + len, s, index - mask_spec->str);
  mask_spec->str += len;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;

    switch (mfield->class)
    {
      case M_FIELD   : mfield = &mobject->mfield;
                       if (mfield->table_name < index) mfield->table_name += len;
                       if (mfield->field_name < index) mfield->field_name += len;
                       if (mfield->label_name < index) mfield->label_name += len;

                       if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
                         if ((mfield->extra >= 0) && (mfield->extra < index)) mfield->extra += len;
                       break;
      case M_LINE    : break;
      case M_BOX     : break;
      case M_RBOX    : break;
      case M_TEXT    : mtext = &mobject->mtext;
                       if (mtext->text < index) mtext->text += len;
                       break;
      case M_GRAF    : mgraf = &mobject->mgraf;
                       if (mgraf->filename < index) mgraf->filename += len;
                       break;
      case M_BUTTON  : mbutton = &mobject->mbutton;
                       if (mbutton->text  < index) mbutton->text  += len;
                       if (mbutton->param < index) mbutton->param += len;
                       break;
      case M_SUBMASK : msubmask = &mobject->msubmask;
                       if (msubmask->SourceObject < index) msubmask->SourceObject += len;
                       if (msubmask->LinkMaster   < index) msubmask->LinkMaster   += len;
                       if (msubmask->LinkChild    < index) msubmask->LinkChild    += len;
                       break;
    } /* switch */
  } /* for */
} /* del_str */

/*****************************************************************************/

GLOBAL VOID add_picture (mask_spec, mgraf, filename)
MASK_SPEC *mask_spec;
MGRAF     *mgraf;
BYTE      *filename;

{
  WORD    result;
  RECT    pos;
  GEMOBJP gem;
  IMGOBJP img;
  WINDOWP window;
  PICOBJ  *picobj;

  if (mask_spec->picptr < mask_spec->max_pics)
  {
    pos.x = (LONG)mgraf->x * gl_wbox / M_XUNITS;
    pos.y = (LONG)mgraf->y * gl_hbox / M_YUNITS;
    pos.w = (LONG)mgraf->w * gl_wbox / M_XUNITS;
    pos.h = (LONG)mgraf->h * gl_hbox / M_YUNITS;

    window       = mask_spec->window;
    picobj       = &mask_spec->picobj [mask_spec->picptr];
    picobj->type = mgraf->type;
    strcpy (picobj->filename, filename);

    switch (picobj->type)
    {
      case PIC_META  : gem             = &picobj->pic.gem;
                       gem->window     = window;
                       gem->pos        = pos;
                       gem->out_handle = vdi_handle;
                       result          = gem_obj (gem, GEM_INIT, GEM_FILE | GEM_BESTFIT, filename);

                       switch (result)
                       {
                         case GEM_NOMEMORY     : hndl_alert (ERR_NOMEMORY);           break;
                         case GEM_FILENOTFOUND : file_error (ERR_FILEOPEN, filename); break;
                       } /* switch */
                       break;
      case PIC_IMAGE : img         = &picobj->pic.img;
                       img->window = window;
                       result      = image_obj (img, IMG_INIT, IMG_FILE, filename);

                       if (result == IMG_OK)  /* set objsize to pic size */
                       {
                         pos.w     = img->width;
                         pos.h     = img->height;
                         img->pos  = pos;
                         pos.h    += gl_hbox / M_YUNITS - 1;    /* if img->height is not even */
                         mgraf->w  = (LONG)pos.w * M_XUNITS / gl_wbox;
                         mgraf->h  = (LONG)pos.h * M_YUNITS / gl_hbox;
                       } /* if */
                       else
                         switch (result)
                         {
                           case IMG_NOMEMORY     : hndl_alert (ERR_NOMEMORY);           break;
                           case IMG_FILENOTFOUND : file_error (ERR_FILEOPEN, filename); break;;
                         } /* switch, else */
                       break;
      case PIC_IFF   : break;
      case PIC_TIFF  : break;
    } /* switch */

    mask_spec->picptr++;
    set_meminfo ();
  } /* if */
  else
    hndl_alert (ERR_NOPICS);
} /* add_picture */

/*****************************************************************************/

GLOBAL WORD add_mobject (mask_spec, mobject, s1, s2, s3, s4, obj)
MASK_SPEC *mask_spec;
MOBJECT   *mobject;
BYTE      *s1;
BYTE      *s2;
BYTE      *s3;
BYTE      *s4;
WORD      *obj;

{
  WORD     size;
  MOBJECT  *buffer;
  MFIELD   *mfield;
  MTEXT    *mtext;
  MGRAF    *mgraf;
  MBUTTON  *mbutton;
  MSUBMASK *msubmask;
  SYSMASK  *sysmask;

  *obj = FAILURE;
  size = sizeof (MOBJECT);
  if (s1 != NULL) size += strlen (s1) + 1;      /* EOS */
  if (s2 != NULL) size += strlen (s2) + 1;      /* EOS */
  if (s3 != NULL) size += strlen (s3) + 1;      /* EOS */
  if (s4 != NULL) size += strlen (s4) + 1;      /* EOS */
  if (mask_spec->str - mask_spec->objs * sizeof (MOBJECT) < size) return (ERR_NOOBJECTS);

  sysmask = &mask_spec->mask;
  mfield  = &mobject->mfield;
  m_snap_obj (mask_spec, mobject, mask_spec->grid_x, mask_spec->grid_y);

  switch (mfield->class)
  {
    case M_FIELD   : if (field_exists (mask_spec, s1, s2)) return (ERR_OBJEXISTS);

                     mfield->table_name = add_str (mask_spec, s1);
                     mfield->field_name = add_str (mask_spec, s2);
                     mfield->label_name = add_str (mask_spec, s3);

                     if (s4 != NULL) mfield->extra = add_str (mask_spec, s4);     /* radio button values */
                     break;
    case M_LINE    : break;
    case M_BOX     : break;
    case M_RBOX    : break;
    case M_TEXT    : mtext = &mobject->mtext;
                     mtext->text = add_str (mask_spec, s1);
                     break;
    case M_GRAF    : if (mask_spec->picptr >= mask_spec->max_pics) return (ERR_NOPICS);
                     mgraf = &mobject->mgraf;
                     mgraf->filename = add_str (mask_spec, s1);
                     add_picture (mask_spec, mgraf, s1);
                     break;
    case M_BUTTON  : mbutton = &mobject->mbutton;
                     mbutton->text  = add_str (mask_spec, s1);
                     mbutton->param = add_str (mask_spec, s2);
                     break;
    case M_SUBMASK : msubmask = &mobject->msubmask;
                     msubmask->SourceObject = add_str (mask_spec, s1);
                     msubmask->LinkMaster   = add_str (mask_spec, s2);
                     msubmask->LinkChild    = add_str (mask_spec, s3);
                     break;
    default        : return (ERR_UNKNOWNOBJ);
  } /* switch */

  buffer = (MOBJECT *)sysmask->mask.buffer;
  buffer [mask_spec->objs] = *mobject;

  *obj = mask_spec->objs;

  mask_spec->objs++;
  mask_spec->modified = TRUE;
  mask_spec->max_objs = mask_spec->str / sizeof (MOBJECT);

  return (SUCCESS);
} /* add_mobject */

/*****************************************************************************/

GLOBAL VOID del_mobject (mask_spec, obj)
MASK_SPEC *mask_spec;
WORD      obj;

{
  WORD     pic;
  BYTE     *filename;
  PICOBJ   *picobj;
  MFIELD   *mfield;
  MTEXT    *mtext;
  MGRAF    *mgraf;
  MBUTTON  *mbutton;
  MSUBMASK *msubmask;
  MOBJECT  *mobject;
  SYSMASK  *sysmask;

  sysmask = &mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;
  mobject = &mobject [obj];
  mfield  = &mobject->mfield;

  switch (mfield->class)
  {
    case M_FIELD   : mfield = &mobject->mfield;
                     del_str (mask_spec, mfield->table_name);
                     del_str (mask_spec, mfield->field_name);
                     del_str (mask_spec, mfield->label_name);

                     if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type)) del_str (mask_spec, mfield->extra);
                     break;
    case M_LINE    : break;
    case M_BOX     : break;
    case M_RBOX    : break;
    case M_TEXT    : mtext = &mobject->mtext;
                     del_str (mask_spec, mtext->text);
                     break;
    case M_GRAF    : mgraf = &mobject->mgraf;
                     filename = &sysmask->mask.buffer [mgraf->filename];
                     pic      = m_name2picobj (mask_spec, filename);

                     if (pic != FAILURE)
                     {
                       picobj = &mask_spec->picobj [pic];

                       switch (picobj->type)
                       {
                         case PIC_META  : gem_obj (&picobj->pic.gem, GEM_EXIT, 0, NULL);   break;
                         case PIC_IMAGE : image_obj (&picobj->pic.img, IMG_EXIT, 0, NULL); break;
                         case PIC_IFF   :                                                  break;
                         case PIC_TIFF  :                                                  break;
                       } /* switch, for */

                       mask_spec->picptr--;
                       mem_move (picobj, picobj + 1, (mask_spec->picptr - pic) * sizeof (PICOBJ));
                       set_meminfo ();
                     } /* if */

                     del_str (mask_spec, mgraf->filename);
                     break;
    case M_BUTTON  : mbutton = &mobject->mbutton;
                     del_str (mask_spec, mbutton->text);
                     del_str (mask_spec, mbutton->param);
                     break;
    case M_SUBMASK : msubmask = &mobject->msubmask;
                     del_str (mask_spec, msubmask->SourceObject);
                     del_str (mask_spec, msubmask->LinkMaster);
                     del_str (mask_spec, msubmask->LinkChild);
                     break;
  } /* switch */

  mem_move (mobject, mobject + 1, (mask_spec->objs - obj - 1) * sizeof (MOBJECT));

  mask_spec->objs--;
  mask_spec->modified = TRUE;
  mask_spec->max_objs = mask_spec->str / sizeof (MOBJECT);
} /* del_mobject */

/*****************************************************************************/

GLOBAL VOID GetPicFilename (MASK_SPEC *mask_spec, BYTE *pPicFilename, BYTE *pFilename)
{
  FILENAME szName;

  strcpy (pPicFilename, pFilename);
  str_upper (pPicFilename);

  if (! file_exist (pPicFilename))	/* search on basepath */
  {
    file_split (pPicFilename, NULL, NULL, szName, NULL);
    strcpy (pPicFilename, mask_spec->base_spec->basepath);
    strcat (pPicFilename, szName);

    if (! file_exist (pPicFilename))	/* should never happen */
    {
      file_error (ERR_FILEOPEN, pPicFilename);
      return;
    } /* if */;
  } /* if */
} /* GetPicFilename */

/*****************************************************************************/

GLOBAL SHORT IndexFromColor32 (LONG lColor)
{
  SHORT sIndex;

  sIndex = (SHORT)((lColor >> 24) - 1);	/* WHITE (color #0) begins with index 1 */
  if ((sIndex < 0) || (sIndex >= STD_COLORS)) sIndex = 0;

  return (sIndex);
} /* IndexFromColor32 */

/*****************************************************************************/

GLOBAL LONG Color32FromIndex (SHORT sIndex)
{
  LONG lColor;

  if ((sIndex < 0) || (sIndex >= STD_COLORS)) sIndex = 0;

  lColor = sIndex;

  return (lColor + 1) << 24;	/* ColorIndex + 1 is in upper byte, colorref bbggrr are in lower 3 bytes */
} /* Color32FromIndex */

/*****************************************************************************/

LOCAL VOID get_fattr (out_handle, factor, wbox, hbox, fattr)
WORD  out_handle;
WORD  factor;
WORD  wbox, hbox;
FATTR *fattr;

{
  fattr->w_shadow = fattr->h_shadow = 0;
  fattr->w_attr   = fattr->h_attr   = gl_wattr * factor / 100;

  if ((out_handle == vdi_handle) && (gl_hbox <= 8))     /* low resolution on screen */
  {
    fattr->h_shadow /= 2;
    fattr->w_attr   *= 2;
  } /* if */
} /* get_fattr */

/*****************************************************************************/

LOCAL BOOLEAN put_rect (mask_spec, mobject, grid_x, grid_y, diff)
MASK_SPEC *mask_spec;
MOBJECT   *mobject;
WORD      grid_x, grid_y;
RECT      *diff;

{
  WORD      x, y, old_x, old_y;
  WORD      snap_x, snap_y;
  WORD      sign_x, sign_y;
  WORD      pic;
  RECT      r;
  GEMOBJP   gem;
  IMGOBJP   img;
  BYTE      *filename;
  PICOBJ    *picobj;
  MFIELD    *mfield;
  MLINE     *mline;
  MGRAF     *mgraf;
  SYSMASK   *sysmask;

  mfield = &mobject->mfield;
  mline  = &mobject->mline;

  old_x = mfield->x;
  old_y = mfield->y;

  x = mfield->x * gl_wbox / M_XUNITS;
  y = mfield->y * gl_hbox / M_YUNITS;

  snap_x = gl_wbox * grid_x / M_XUNITS;
  snap_y = gl_hbox * grid_y / M_YUNITS;

  x += diff->w;
  y += diff->h;

  sign_x = (x < 0) ? -1 : 1;
  sign_y = (y < 0) ? -1 : 1;

  x = (x + sign_x * snap_x / 2) / snap_x * snap_x;
  y = (y + sign_y * snap_y / 2) / snap_y * snap_y;

  mfield->x = x * M_XUNITS / gl_wbox;
  mfield->y = y * M_YUNITS / gl_hbox;

  if (mfield->class == M_LINE)
  {
    x = mline->x2 * gl_wbox / M_XUNITS;
    y = mline->y2 * gl_hbox / M_YUNITS;

    x += diff->w;
    y += diff->h;

    x = (x + sign_x * snap_x / 2) / snap_x * snap_x;
    y = (y + sign_y * snap_y / 2) / snap_y * snap_y;

    if (x < 0) x = 0;
    if (y < 0) y = 0;

    mline->x2 = x * M_XUNITS / gl_wbox;
    mline->y2 = y * M_YUNITS / gl_hbox;
  } /* if */

  if ((mfield->class == M_GRAF) && (mask_spec != NULL))
  {
    sysmask  = &mask_spec->mask;
    mgraf    = &mobject->mgraf;
    filename = &sysmask->mask.buffer [mgraf->filename];
    pic      = m_name2picobj (mask_spec, filename);

    if (pic != FAILURE)
    {
      picobj = &mask_spec->picobj [pic];

      r.x = (LONG)mgraf->x * gl_wbox / M_XUNITS;
      r.y = (LONG)mgraf->y * gl_hbox / M_YUNITS;
      r.w = (LONG)mgraf->w * gl_wbox / M_XUNITS;
      r.h = (LONG)mgraf->h * gl_hbox / M_YUNITS;

      switch (picobj->type)
      {
        case PIC_META  : gem      = &picobj->pic.gem;
                         gem->pos = r;
                         break;
        case PIC_IMAGE : img      = &picobj->pic.img;
                         img->pos = r;
                         break;
        case PIC_IFF   : break;
        case PIC_TIFF  : break;
      } /* switch */
    } /* if */
  } /* if */

  if ((old_x != mfield->x) || (old_y != mfield->y))
    return (TRUE);
  else
    return (FALSE);
} /* put_rect */

/*****************************************************************************/

LOCAL WORD find_obj (window, mk)
WINDOWP  window;
MKINFO   *mk;

{
  BOOLEAN   next;
  WORD      obj;
  RECT      r;
  FATTR     fattr;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [mask_spec->objs - 1];
  next      = mk->ctrl;

  for (obj = mask_spec->objs - 1; obj >= 0; obj--, mobject--)
  {
    mfield = &mobject->mfield;
    m_get_rect (window, vdi_handle, mfield->class, mobject, &r, &fattr);

    if (inside (mk->mox, mk->moy, &r))
    {
      if (next)
        next = FALSE;
      else
        return (obj);
    } /* if */
  } /* for */

  return (FAILURE);
} /* find_obj */

/*****************************************************************************/

LOCAL VOID rub_box (mk, r)
MKINFO *mk;
RECT   *r;

{
  r->x = mk->mox;
  r->y = mk->moy;

  graf_rubbox (r->x, r->y, -r->x, -r->y, &r->w, &r->h);
} /* rub_box */

/*****************************************************************************/

LOCAL VOID hndl_line (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      x1, y1, x2, y2;
  WORD      obj, err;
  RECT      bound, r, diff;
  MLINE     mline;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  r = bound = window->scroll;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  set_clip (TRUE, &desk);
  drag_line (&r, &diff, &bound, 1, 1);

  x1 = mk->mox - window->scroll.x + window->doc.x * window->xfac;
  y1 = mk->moy - window->scroll.y + window->doc.y * window->yfac;
  x2 = x1 + diff.w; /* - window->scroll.x + window->doc.x * window->xfac;*/
  y2 = y1 + diff.h; /* - window->scroll.y + window->doc.y * window->yfac;*/

  mline.class  = M_LINE;
  mline.x1     = x1 * M_XUNITS / gl_wbox;
  mline.y1     = y1 * M_YUNITS / gl_hbox;
  mline.x2     = x2 * M_XUNITS / gl_wbox;
  mline.y2     = y2 * M_YUNITS / gl_hbox;
  mline.color  = mask_spec->color;
  mline.type   = mask_spec->line_type;
  mline.width  = mask_spec->line_width;
  mline.bstyle = mask_spec->line_bstyle;
  mline.estyle = mask_spec->line_estyle;

  err = add_mobject (mask_spec, (MOBJECT *)&mline, NULL, NULL, NULL, NULL, &obj);
  if (err == SUCCESS)
    set_redraw (window, &window->scroll);
  else
    hndl_alert (err);
} /* hndl_line */

/*****************************************************************************/

LOCAL VOID hndl_box (window, mk, rounded)
WINDOWP window;
MKINFO  *mk;
BOOLEAN rounded;

{
  WORD      x, y, w, h;
  WORD      xy [4];
  WORD      obj, err;
  RECT      r;
  MBOX      mbox;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  set_clip (TRUE, &desk);
  rub_box (mk, &r);

  xy [0] = mk->mox - window->scroll.x + window->doc.x * window->xfac;
  xy [1] = mk->moy - window->scroll.y + window->doc.y * window->yfac;
  xy [2] = xy [0] + r.w;
  xy [3] = xy [1] + r.h;

  array2rect (xy, &r);
  rect2xywh (&r, &x, &y, &w, &h);

  mbox.class  = rounded ? M_RBOX : M_BOX;
  mbox.x      = x * M_XUNITS / gl_wbox;
  mbox.y      = y * M_YUNITS / gl_hbox;
  mbox.w      = w * M_XUNITS / gl_wbox;
  mbox.h      = h * M_YUNITS / gl_hbox;
  mbox.color  = mask_spec->color;
  mbox.style  = mask_spec->fill_style;
  mbox.index  = mask_spec->fill_index;

  err = add_mobject (mask_spec, (MOBJECT *)&mbox, NULL, NULL, NULL, NULL, &obj);
  if (err == SUCCESS)
    set_redraw (window, &window->scroll);
  else
    hndl_alert (err);
} /* hndl_box */

/*****************************************************************************/

LOCAL VOID hndl_text (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      wchar, hchar, wbox, hbox;
  WORD      font, point;
  WORD      x, y;
  WORD      obj, err;
  UWORD     flags;
  MTEXT     mtext;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  font      = mask_spec->font;
  point     = mask_spec->point;
  flags     = 0;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);

  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  x  = mk->mox - window->scroll.x + window->doc.x * window->xfac;
  y  = mk->moy - window->scroll.y + window->doc.y * window->yfac;
  y -= hbox / 2;        /* because text is drawn with "top line" */

  if (x < 0) x = 0;
  if (y < 0) y = 0;

  mtext.class   = M_TEXT;
  mtext.x       = x * M_XUNITS / gl_wbox;
  mtext.y       = y * M_YUNITS / gl_hbox;
  mtext.w       = 0;
  mtext.h       = 1;
  mtext.text    = FAILURE;
  mtext.font    = font;
  mtext.point   = point;
  mtext.color   = mask_spec->color;
  mtext.effects = TXT_NORMAL;
  mtext.wrmode  = MD_REPLACE;
  mtext.flags   = 0;

  err = add_mobject (mask_spec, (MOBJECT *)&mtext, "", NULL, NULL, NULL, &obj);
  if (err == SUCCESS)
  {
    set_mouse (ARROW, NULL);
    if (mseltext (window, obj) == STCANCEL) del_mobject (mask_spec, obj);
    last_mouse ();
    set_redraw (window, &window->scroll);
  } /* if */
  else
    hndl_alert (err);
} /* hndl_text */

/*****************************************************************************/

LOCAL VOID hndl_graf (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      x, y, w, h;
  WORD      xy [4];
  WORD      obj, type, err;
  EXT       suffix;
  FULLNAME  filename;
  LONGSTR   s;
  RECT      r;
  MGRAF     mgraf;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  set_clip (TRUE, &desk);
  rub_box (mk, &r);

  strcpy (filename, pic_path);
  strcat (filename, pic_name);

  if (! get_open_filename (FLOADGRF, NULL, 0L, FFILTER_IMG_GEM, NULL, pic_path, FINFSUFF, filename, pic_name)) return;

  str_upper (filename);
  file_split (filename, NULL, pic_path, pic_name, NULL);
  file_split (filename, NULL, NULL, NULL, suffix);

  type = FAILURE;

  if (strcmp (suffix, "GEM") == 0) type = PIC_META;
  if (strcmp (suffix, "IMG") == 0) type = PIC_IMAGE;
  if (strcmp (suffix, "IFF") == 0) type = PIC_IFF;
  if (strcmp (suffix, "TIF") == 0) type = PIC_TIFF;

  if (type == FAILURE)
  {
    sprintf (s, alerts [ERR_PICUNKNOWN], suffix);
    open_alert (s);
    return;
  } /* if */

  xy [0] = mk->mox - window->scroll.x + window->doc.x * window->xfac;
  xy [1] = mk->moy - window->scroll.y + window->doc.y * window->yfac;
  xy [2] = xy [0] + r.w;
  xy [3] = xy [1] + r.h;

  array2rect (xy, &r);
  rect2xywh (&r, &x, &y, &w, &h);

  mgraf.class    = M_GRAF;
  mgraf.x        = x * M_XUNITS / gl_wbox;
  mgraf.y        = y * M_YUNITS / gl_hbox;
  mgraf.w        = w * M_XUNITS / gl_wbox;
  mgraf.h        = h * M_YUNITS / gl_hbox;
  mgraf.filename = FAILURE;     /* will be set in add_mobject */
  mgraf.type     = type;
  mgraf.flags    = MG_DRAWFRAME;

  err = add_mobject (mask_spec, (MOBJECT *)&mgraf, filename, NULL, NULL, NULL, &obj);
  if (err == SUCCESS)
    set_redraw (window, &window->scroll);
  else
    hndl_alert (err);
} /* hndl_graf */

/*****************************************************************************/

LOCAL VOID hndl_button (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      wchar, hchar, wbox, hbox;
  WORD      font, point;
  WORD      x, y, w, h;
  WORD      obj, err;
  WORD      xy [4];
  UWORD     flags;
  RECT      r;
  MBUTTON   mbutton;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  font      = mask_spec->font;
  point     = mask_spec->point;
  flags     = 0;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);

  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  set_clip (TRUE, &desk);
  rub_box (mk, &r);

  xy [0] = mk->mox - window->scroll.x + window->doc.x * window->xfac;
  xy [1] = mk->moy - window->scroll.y + window->doc.y * window->yfac;
  xy [2] = xy [0] + r.w;
  xy [3] = xy [1] + r.h;

  array2rect (xy, &r);
  rect2xywh (&r, &x, &y, &w, &h);

  mbutton.class   = M_BUTTON;
  mbutton.x       = x * M_XUNITS / gl_wbox;
  mbutton.y       = y * M_YUNITS / gl_hbox;
  mbutton.w       = w * M_XUNITS / gl_wbox;
  mbutton.h       = h * M_YUNITS / gl_hbox;
  mbutton.text    = FAILURE;
  mbutton.param   = FAILURE;
  mbutton.font    = font;
  mbutton.point   = point;
  mbutton.color   = mask_spec->color;
  mbutton.command = MB_SAVE;
  mbutton.flags   = flags;

  err = add_mobject (mask_spec, (MOBJECT *)&mbutton, "", "", NULL, NULL, &obj);
  if (err == SUCCESS)
  {
    set_mouse (ARROW, NULL);
    if (mselbutton (window, obj) == SBCANCEL) del_mobject (mask_spec, obj);
    last_mouse ();
    set_redraw (window, &window->scroll);
  } /* if */
  else
    hndl_alert (err);
} /* hndl_button */

/*****************************************************************************/

LOCAL VOID hndl_mask (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  WORD      wchar, hchar, wbox, hbox;
  WORD      font, point;
  WORD      x, y, w, h;
  WORD      obj, err;
  WORD      xy [4];
  UWORD     flags;
  RECT      r;
  MSUBMASK  msubmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  font      = mask_spec->font;
  point     = mask_spec->point;
  flags     = 0;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);

  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  r.x = mk->mox;
  r.y = mk->moy;
  r.w = 0;
  r.h = 0;

  set_clip (TRUE, &desk);
  rub_box (mk, &r);

  xy [0] = mk->mox - window->scroll.x + window->doc.x * window->xfac;
  xy [1] = mk->moy - window->scroll.y + window->doc.y * window->yfac;
  xy [2] = xy [0] + r.w;
  xy [3] = xy [1] + r.h;

  array2rect (xy, &r);
  rect2xywh (&r, &x, &y, &w, &h);

  msubmask.class        = M_SUBMASK;
  msubmask.x            = x * M_XUNITS / gl_wbox;
  msubmask.y            = y * M_YUNITS / gl_hbox;
  msubmask.w            = w * M_XUNITS / gl_wbox;
  msubmask.h            = h * M_YUNITS / gl_hbox;
  msubmask.SourceObject = FAILURE;
  msubmask.LinkMaster   = FAILURE;
  msubmask.LinkChild    = FAILURE;
  msubmask.font         = font;
  msubmask.point        = point;
  msubmask.color        = mask_spec->color;
  msubmask.flags        = flags;

  err = add_mobject (mask_spec, (MOBJECT *)&msubmask, "", "", "", NULL, &obj);
  if (err == SUCCESS)
  {
    set_mouse (ARROW, NULL);
    if (mselsubmask (window, obj) == SSCANCEL) del_mobject (mask_spec, obj);
    last_mouse ();
    set_redraw (window, &window->scroll);
  } /* if */
  else
    hndl_alert (err);
} /* hndl_mask */

/*****************************************************************************/

LOCAL BOOLEAN hndl_mobj (src_window, dst_window, class, mobject, diff, mk, r)
WINDOWP src_window;
WINDOWP dst_window;
WORD    class;
MOBJECT *mobject;
RECT    *diff;
MKINFO  *mk;
RECT    *r;

{
  BOOLEAN    copy, b3D;
  WORD       table, field;
  WORD       obj, err;
  WORD       x, y, grid_x, grid_y;
  RECT       old, new;
  FATTR      fattr;
  LONGSTR    s;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *tablename;
  BYTE       *fieldname;
  BYTE       *s1, *s2, *s3, *s4;
  MOBJECT    dst_obj;
  MFIELD     *mfield;
  MLINE      *mline;
  MTEXT      *mtext;
  MGRAF      *mgraf;
  MBUTTON    *mbutton;
  MSUBMASK   *msubmask;
  SYSTABLE   *systable;
  SYSCOLUMN  *syscolumn;
  SYSMASK    *srcmask;
  SYSMASK    *dstmask;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *src_spec;
  MASK_SPEC  *dst_spec;

  src_spec = (MASK_SPEC *)src_window->special;
  dst_spec = (MASK_SPEC *)dst_window->special;
  srcmask  = &src_spec->mask;
  dstmask  = &dst_spec->mask;
  dst_obj  = *mobject;
  mfield   = &dst_obj.mfield;
  copy     = mk->shift;
  grid_x   = src_spec->grid_x;
  grid_y   = src_spec->grid_y;
  b3D      = (dlg_colors >= 16) && (dstmask->flags & SM_SHOW_3D);

  if ((diff->w == 0) && (diff->h == 0)) return (TRUE);

  if ((src_window == dst_window) && ! copy)                     /* move field coordinates */
  {
    m_get_rect (src_window, vdi_handle, class, mobject, &old, &fattr);

    if (put_rect (src_spec, mobject, grid_x, grid_y, diff))     /* coordinates have been changed */
    {
      src_spec->modified = TRUE;
      m_get_rect (src_window, vdi_handle, class, mobject, &new, &fattr);        /* get new rect */

      if (b3D)
      {
        rc_inflate (&old, 1, 1);
        rc_inflate (&new, 1, 1);
      } /* if */

      set_redraw (src_window, &old);
      set_redraw (src_window, &new);
    } /* if */
  } /* if */
  else                                  /* src_window != dst_window or copy */
  {
    if (mfield->class == M_FIELD)       /* check, if field is unique */
    {
      base_spec = src_spec->base_spec;

      if (dstmask->tablename [0] != EOS)
        tablename = dstmask->tablename;
      else
        tablename = &srcmask->mask.buffer [mfield->table_name];

      fieldname = &srcmask->mask.buffer [mfield->field_name];

      strcpy (table_info.name, tablename);
      strcpy (field_info.name, fieldname);

      table = v_tableinfo (base_spec, FAILURE, &table_info);
      if (table == FAILURE)
      {
        sprintf (s, alerts [ERR_TABLENAME], table_info.name);
        open_alert (s);
        return (FALSE);
      } /* if */

      field = v_fieldinfo (base_spec, table, FAILURE, &field_info);
      if (field == FAILURE)
      {
        sprintf (s, alerts [ERR_FIELDNAME], field_info.name);
        open_alert (s);
        return (FALSE);
      } /* if */
    } /* if */

    x = r->x + diff->w - dst_window->scroll.x + dst_window->doc.x * dst_window->xfac;
    y = r->y + diff->h - dst_window->scroll.y + dst_window->doc.y * dst_window->yfac;

    mfield->x = x * M_XUNITS / gl_wbox;
    mfield->y = y * M_YUNITS / gl_hbox;

    s1 = s2 = s3 = s4 = NULL;

    switch (mfield->class)
    {
      case M_FIELD   : s1 = tablename;
                       s2 = fieldname;
                       s3 = &srcmask->mask.buffer [mfield->label_name];
                       if (IS_CHECKBOX (mfield->type) || IS_RBUTTON (mfield->type))
                         if (mfield->extra >= 0) s4 = &srcmask->mask.buffer [mfield->extra];
                       break;
      case M_LINE    : mline = &mobject->mline;
                       x     = diff->w;
                       y     = diff->h;
 
                       x -= dst_window->scroll.x - dst_window->doc.x * dst_window->xfac -
                            src_window->scroll.x + src_window->doc.x * src_window->xfac;
                       y -= dst_window->scroll.y - dst_window->doc.y * dst_window->yfac -
                            src_window->scroll.y + src_window->doc.y * src_window->yfac;

                       mfield->x = mline->x1 + x * M_XUNITS / gl_wbox;
                       mfield->y = mline->y1 + y * M_YUNITS / gl_hbox;
                       mfield->w = mline->x2 + x * M_XUNITS / gl_wbox;
                       mfield->h = mline->y2 + y * M_YUNITS / gl_hbox;
                       break;
      case M_BOX     :
      case M_RBOX    : break;
      case M_TEXT    : mtext = &mobject->mtext;
                       s1    = &srcmask->mask.buffer [mtext->text];
                       break;
      case M_GRAF    : mgraf = &mobject->mgraf;
                       s1    = &srcmask->mask.buffer [mgraf->filename];
                       break;
      case M_BUTTON  : mbutton = &mobject->mbutton;
                       s1      = &srcmask->mask.buffer [mbutton->text];
                       s2      = &srcmask->mask.buffer [mbutton->param];
                       break;
      case M_SUBMASK : msubmask = &mobject->msubmask;
                       s1       = &srcmask->mask.buffer [msubmask->SourceObject];
                       s2       = &srcmask->mask.buffer [msubmask->LinkMaster];
                       s3       = &srcmask->mask.buffer [msubmask->LinkChild];
                       break;
    } /* switch */

    err = add_mobject (dst_spec, &dst_obj, s1, s2, s3, s4, &obj);

    if (err != SUCCESS)
      switch (err)
      {
        case ERR_OBJEXISTS  : systable  = &base_spec->systable [table];
                              syscolumn = &base_spec->syscolumn [abscol (base_spec, table, field)];
                              sprintf (s, alerts [ERR_OBJEXISTS], systable->name, syscolumn->name);
                              open_alert (s);
                              break;
        default             : hndl_alert (err);
                              break;
      } /* switch, if */

    if (dstmask->tablename [0] == EOS) strcpy (dstmask->tablename, srcmask->tablename);

    m_get_rect (dst_window, vdi_handle, mfield->class, &dst_obj, &new, &fattr);
    if (b3D) rc_inflate (&new, 1, 1);
    set_redraw (dst_window, &new);
  } /* else */

  return (TRUE);
} /* hndl_mobj */

/*****************************************************************************/

LOCAL VOID hndl_objs (src_window, dst_window, objs, all, diff, mk)
WINDOWP src_window;
WINDOWP dst_window;
SET     objs;
RECT    *all;
RECT    *diff;
MKINFO  *mk;

{
  WORD      i, obj, class;
  BOOLEAN   ok;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)src_window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  ok  = TRUE;
  obj = 0;

  for (i = 0; ok && (i < mask_spec->objs); i++, mobject++)
    if (setin (objs, i))
    {
      mfield = &mobject->mfield;
      class  = mfield->class;
      ok     = hndl_mobj (src_window, dst_window, class, mobject, diff, mk, &all [obj]);

      obj++;
    } /* if, for */
} /* hndl_objs */

/*****************************************************************************/

LOCAL VOID drag_objs (window, objs, mk)
WINDOWP window;
SET     objs;
MKINFO  *mk;

{
  BOOLEAN   move_back;
  RECT      r, bound, ob;
  FATTR     fattr;
  WORD      i, result, num_objs;
  WORD      dest_obj;
  WORD      x, y;
  WINDOWP   dest_window;
  SET       inv_objs;
  RECT      all [MAX_SELOBJ];
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  if (window != NULL)
  {
    mask_spec = (MASK_SPEC *)window->special;
    sysmask   = &mask_spec->mask;
    mobject   = (MOBJECT *)sysmask->mask.buffer;

    bound.x = -desk.w;
    bound.y = -desk.h;
    bound.w = 32767;
    bound.h = 32767;

    setclr (inv_objs);
    for (i = ITRASH; i < FKEYS; i++) setincl (inv_objs, i);

    for (i = 0, num_objs = 0; i < mask_spec->objs; i++, mobject++)
      if (setin (objs, i))
      {
        mfield = &mobject->mfield;
        m_get_rect (window, vdi_handle, mfield->class, mobject, &all [num_objs++], &fattr);
      } /* if, for */

    x = mask_spec->grid_x * gl_wbox / M_XUNITS;
    y = mask_spec->grid_y * gl_hbox / M_YUNITS;

    set_mouse (FLAT_HAND, NULL);
    drag_boxes (num_objs, all, find_desk (), inv_objs, &r, &bound, x, y);
    last_mouse ();
    graf_mkstate (&mk->mox, &mk->moy, &result, &result);

    result = drag_to_window (mk->mox, mk->moy, window, 0, &dest_window, &dest_obj);

    if ((result == DRAG_SWIND) ||       /* move or copy objects */
        (result == DRAG_SCLASS))
      hndl_objs (window, dest_window, objs, all, &r, mk);
    else
    if (dest_window != NULL)
    {
      move_back = FALSE;

      if (dest_window->class == class_desk)
      {
        if (result == DRAG_OK)
          switch (dest_obj)
          {
            case ITRASH   : m_obj_clear (window, sel.class, objs);
                            break;
            case ICLIPBRD : if (copy2clipbrd (window, sel.class, objs, (ccp_ext & DO_EXTERNAL) != 0))
                              if (! mk->shift) m_obj_clear (window, sel.class, objs);
                            break;
            default       : move_back = TRUE;
                            break;
          } /* switch, if */
      } /* if */
      else
        move_back = TRUE;

      if (move_back)
      {
        mobject = (MOBJECT *)sysmask->mask.buffer;
        for (i = 0; i < mask_spec->objs; i++, mobject++)
          if (setin (objs, i))
          {
            mfield = &mobject->mfield;
            m_get_rect (window, vdi_handle, mfield->class, mobject, &ob, &fattr);
            graf_mbox (ob.w, ob.h, ob.x + r.w, ob.y + r.h, ob.x, ob.y);
          } /* if, for */
      } /* if */
    } /* if */
  } /* if */
} /* drag_objs */

/*****************************************************************************/

LOCAL VOID drag_line (r, diff, bound, x_raster, y_raster)
RECT *r, *diff, *bound;
WORD x_raster, y_raster;

{
  WORD    event, ret;
  WORD    x_offset, y_offset, x_last, y_last;
  WORD    i, delta;
  RECT    startbox, box;
  MKINFO  mk, start;

  graf_mkstate (&start.mox, &start.moy, &start.mobutton, &start.kstate);
  mk  = start;
  box = startbox = *r;

  diff->w = diff->h = 0;

  if (bound == NULL) bound = &desk;

  line_default (vdi_handle);
  vswr_mode (vdi_handle, MD_XOR);               /* Modi einstellen */
  vsl_color (vdi_handle, RED);

  draw_line (r, diff);

  x_last = start.mox;
  y_last = start.moy;

  do
  {
    event = evnt_multi (MU_BUTTON | MU_M1,
                        1, start.mobutton, 0x0000,
                        TRUE, mk.mox, mk.moy, 1, 1,
                        0, 0, 0, 0, 0,
                        NULL,
                        0, 0,
                        &mk.mox, &mk.moy,
                        &mk.momask, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate);

    if (event & MU_M1)
      if ((x_raster != 0) && ((abs (mk.mox - x_last)) >= x_raster) ||
          (y_raster != 0) && ((abs (mk.moy - y_last)) >= y_raster))
      {
        x_last = mk.mox;
        y_last = mk.moy;

        x_offset = mk.mox - start.mox;
        y_offset = mk.moy - start.moy;

        if (x_raster != 0) x_offset = x_offset / x_raster * x_raster;
        if (y_raster != 0) y_offset = y_offset / y_raster * y_raster;

        box.x = startbox.x + x_offset;
        box.y = startbox.y + y_offset;

        delta = 0;
        i     = bound->x - box.x;
        if (i > 0) delta = i;                   /* left edge */

        i = bound->x + bound->w - (box.x + box.w + delta);
        if (i < 0) delta += i;                  /* right edge */

        x_offset += delta;

        delta = 0;
        i     = bound->y - box.y;
        if (i > 0) delta = i;                   /* upper edge */

        i = bound->y + bound->h - (box.y + box.h + delta);
        if (i < 0) delta += i;                  /* lower edge */

        y_offset += delta;

        if ((diff->w != x_offset) || (diff->h != y_offset)) /* anything changed */
        {
          draw_line (r, diff);

          diff->w = x_offset;
          diff->h = y_offset;

          if (x_offset / x_raster == 0) x_offset += 0; /* ! dummy */

          draw_line (r, diff);
        } /* if */
      } /* if, if */
  } while (! (event & MU_BUTTON));

  draw_line (r, diff);

  diff->x = mk.mox;
  diff->y = mk.moy;
} /* drag_line */

/*****************************************************************************/

LOCAL VOID draw_line  (r, diff)
RECT *r, *diff;

{
  WORD xy [4];
  WORD x_corr;
  WORD y_corr;

  x_corr = (diff->w <= 0) ? 0 : 1;
  y_corr = (diff->h <= 0) ? 0 : 1;

  xy [0] = r->x;
  xy [1] = r->y;
  xy [2] = xy [0] + diff->w - x_corr;
  xy [3] = xy [1] + diff->h - y_corr;

  hide_mouse ();
  v_pline (vdi_handle, 2, xy);
  show_mouse ();
} /* draw_line */

/*****************************************************************************/

LOCAL VOID fill_select (window, objs, area)
WINDOWP window;
SET     objs;
RECT    *area;

{
  WORD      obj;
  RECT      r;
  FATTR     fattr;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;

  setclr (objs);

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;
    m_get_rect (window, vdi_handle, mfield->class, mobject, &r, &fattr);

    if (rc_intersect (area, &r))
      if (rc_intersect (&window->scroll, &r)) setincl (objs, obj);
  } /* for */
} /* fill_select */

/*****************************************************************************/

LOCAL VOID invert_objs (window, objs)
WINDOWP window;
SET     objs;

{
  WORD      obj;
  RECT      r, frame;
  FATTR     fattr;
  WORD      x, y, w, h;
  WORD      xy [10];
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  if (sel.class == SEL_NONE) return;

  mask_spec = (MASK_SPEC *)window->special;
  sysmask   = &mask_spec->mask;

  wind_update (BEG_UPDATE);
  hide_mouse ();

  wind_get (window->handle, WF_FIRSTXYWH, &r.x, &r.y, &r.w, &r.h);

  while ((r.w != 0) && (r.h != 0))
  {
    if (rc_intersect (&window->scroll, &r))
    {
      mobject = (MOBJECT *)sysmask->mask.buffer;

      for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
        if (setin (objs, obj))
        {
          mfield = &mobject->mfield;
          m_get_rect (window, vdi_handle, mfield->class, mobject, &frame, &fattr);
          rect2xywh (&frame, &x, &y, &w, &h);

          if (rc_intersect (&r, &frame))
          {
            set_clip (TRUE, &frame);
            vswr_mode (vdi_handle, MD_XOR);
            vsl_color (vdi_handle, BLACK);
            vsl_ends (vdi_handle, SQUARED, SQUARED);
            vsl_udsty (vdi_handle, 0x5555);
            vsl_type (vdi_handle, USERLINE);
            vsl_width (vdi_handle, 1);

            xy [0] = x;
            xy [1] = y;
            xy [2] = x + w - 1;
            xy [3] = y;
            xy [4] = xy [2];
            xy [5] = y + h - 1;
            xy [6] = x;
            xy [7] = xy [5];
            xy [8] = x;
            xy [9] = y + 1;

            v_pline (vdi_handle, 5, xy);
          } /* if */
        } /* if, for */
    } /* if */

    wind_get (window->handle, WF_NEXTXYWH, &r.x, &r.y, &r.w, &r.h);
  } /* while */

  show_mouse ();
  wind_update (END_UPDATE);
} /* invert_objs */

/*****************************************************************************/

LOCAL VOID rubber_objs (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  RECT r;
  SET  new_objs;

  r.x = mk->mox;
  r.y = mk->moy;

  set_mouse (POINT_HAND, NULL);
  graf_rubbox (r.x, r.y, -r.x, -r.y, &r.w, &r.h);
  last_mouse ();

  if (r.w < 0)
  {
    r.x += r.w;
    r.w  = - r.w;
  } /* if */

  if (r.h < 0)
  {
    r.y += r.h;
    r.h  = - r.h;
  } /* if */

  sel.class = SEL_MOBJ;

  if (mk->shift)                                /* Auschliežlich odernd ausw„hlen */
  {
    fill_select (window, new_objs, &r);
    invert_objs (window, new_objs);
    setxor (sel_objs, new_objs);
  } /* if */
  else
    if (mk->ctrl)                               /* Zus„tzlich ausw„hlen */
    {
      fill_select (window, new_objs, &r);
      setnot (sel_objs);
      setand (new_objs, sel_objs);
      setnot (sel_objs);
      invert_objs (window, new_objs);
      setor (sel_objs, new_objs);
    } /* if */
    else                                        /* Ausw„hlen */
    {
      fill_select (window, sel_objs, &r);
      invert_objs (window, sel_objs);
    } /* else */

  sel_window = setcmp (sel_objs, NULL) ? NULL : window;
} /* rubber_objs */

/*****************************************************************************/

LOCAL BOOLEAN field_exists (mask_spec, tablename, fieldname)
MASK_SPEC *mask_spec;
BYTE      *tablename;
BYTE      *fieldname;

{
  WORD    obj;
  BYTE    *table;
  BYTE    *field;
  MFIELD  *mfield;
  MOBJECT *mobject;
  SYSMASK *sysmask;

  sysmask = &mask_spec->mask;
  mobject = (MOBJECT *)sysmask->mask.buffer;

  for (obj = 0; obj < mask_spec->objs; obj++, mobject++)
  {
    mfield = &mobject->mfield;

    if (mfield->class == M_FIELD)
    {
      table = &sysmask->mask.buffer [mfield->table_name];
      field = &sysmask->mask.buffer [mfield->field_name];

      if ((strcmp (table, tablename) == 0) && (strcmp (field, fieldname) == 0)) return (TRUE);
    } /* if */
  } /* for */

  return (FALSE);
} /* field_exists */

