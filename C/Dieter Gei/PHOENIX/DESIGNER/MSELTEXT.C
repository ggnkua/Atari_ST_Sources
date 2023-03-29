/*****************************************************************************
 *
 * Module : MSELTEXT.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 20.11.93
 *
 *
 * Description: This module implements the mask select text dialog box.
 *
 * History:
 * 20.11.93: Old mselfont.h replaced with CommDlg functions
 * 16.11.93: Draw font name and size if font selected
 * 10.11.93: GetFontDialog used instead of mselfont
 * 24.09.93: Call to draw_object in click_text on case STFONT added
 * 08.09.93: set_ptext -> set_str
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
#include "dialog.h"
#include "mclick.h"

#include "export.h"
#include "mseltext.h"

/****** DEFINES **************************************************************/

#define FONTNAME_LENGTH 16      /* see resource file */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    obj;
  MTEXT   mtext;
  WINDOWP window;       /* mask window */
} ST_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj;
LOCAL ST_SPEC st_spec;

/****** FUNCTIONS ************************************************************/

LOCAL VOID    box          _((WINDOWP window, BOOLEAN grow, WINDOWP mask_window, MOBJECT *mobject));

LOCAL VOID    get_text     _((ST_SPEC *st_spec));
LOCAL VOID    set_text     _((ST_SPEC *st_spec));
LOCAL VOID    open_text    _((WINDOWP window));
LOCAL VOID    close_text   _((WINDOWP window));
LOCAL VOID    click_text   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_text     _((WINDOWP window, MKINFO *mk));

LOCAL UWORD   get_flags    _((OBJECT *tree));
LOCAL BOOLEAN any_ed_empty _((OBJECT *tree, WORD start, WORD end));

/*****************************************************************************/

GLOBAL WORD mseltext (mask_window, obj)
WINDOWP mask_window;
WORD    obj;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, SELTEXT);

  if (window == NULL)
  {
    form_center (seltext, &ret, &ret, &ret, &ret);
    window = crt_dialog (seltext, NULL, SELTEXT, FREETXT (FTEXT), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_text;
      window->close   = close_text;
      window->click   = click_text;
      window->key     = key_text;
      window->special = (LONG)&st_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = STTEXT;
    window->edit_inx = NIL;

    st_spec.obj    = obj;
    st_spec.window = mask_window;

    set_text (&st_spec);

    if (! open_dialog (SELTEXT)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (exit_obj);
} /* mseltext */

/*****************************************************************************/

LOCAL VOID box (window, grow, mask_window, mobject)
WINDOWP window;
BOOLEAN grow;
WINDOWP mask_window;
MOBJECT *mobject;

{
  RECT  l, b;
  FATTR fattr;

  m_get_rect (mask_window, vdi_handle, M_TEXT, mobject, &l, &fattr);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID get_text (st_spec)
ST_SPEC *st_spec;

{
  WORD      wchar, hchar, wbox, hbox;
  WORD      font, point;
  UWORD     flags;
  STRING    s;
  MTEXT     *mtext;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)st_spec->window->special;
  mtext     = &st_spec->mtext;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [st_spec->obj];
  font      = mtext->font;
  point     = mtext->point;
  flags     = 0;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);
  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  mtext->effects = get_flags (seltext);
  mtext->wrmode  = get_rbutton (seltext, STREPLAC) - STREPLAC + 1;
  mtext->flags   = flags;

  get_ptext (seltext, STTEXT, s);
  del_str (mask_spec, mtext->text);
  mtext->text = add_str (mask_spec, s);

  mtext->x = get_word (seltext, STXPOS);
  mtext->y = get_word (seltext, STYPOS);
  mtext->w = strlen (s);

  mem_move (mobject, mtext, sizeof (MTEXT));
} /* get_text */

/*****************************************************************************/

LOCAL VOID set_text (st_spec)
ST_SPEC *st_spec;

{
  WORD      effects;
  STRING    s;
  BYTE      *p;
  MTEXT     *mtext;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)st_spec->window->special;
  mtext     = &st_spec->mtext;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [st_spec->obj];

  mem_move (mtext, mobject, sizeof (MTEXT));

  effects = mtext->effects;

  set_str (seltext, STTEXT, &sysmask->mask.buffer [mtext->text]);

  set_checkbox (seltext, STTHICK,  effects & TXT_THICKENED);
  set_checkbox (seltext, STLIGHT,  effects & TXT_LIGHT);
  set_checkbox (seltext, STSKEWED, effects & TXT_SKEWED);
  set_checkbox (seltext, STUNDERL, effects & TXT_UNDERLINED);
  set_checkbox (seltext, STOUTLIN, effects & TXT_OUTLINED);

  set_rbutton (seltext, STREPLAC + mtext->wrmode - 1, STREPLAC, STTRANS);

  set_word (seltext, STXPOS, mtext->x);
  set_word (seltext, STYPOS, mtext->y);

  FontNameFromNumber (s, mtext->font);
  s [FONTNAME_LENGTH] = EOS;
  set_str (seltext, STFONTN, s);

  sprintf (s, "%-3d", mtext->point);
  set_str (seltext, STPOINT, s);

  p = get_str (seltext, STTEXT);
  if ((any_ed_empty (seltext, STXPOS, STYPOS) || (*p == EOS)) == ! is_state (seltext, STOK, DISABLED)) flip_state (seltext, STOK, DISABLED);

  exit_obj = STCANCEL;
} /* set_text */

/*****************************************************************************/

LOCAL VOID open_text (window)
WINDOWP window;

{
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;
  ST_SPEC   *st_spec;

  st_spec   = (ST_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)st_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [st_spec->obj];

  box (window, TRUE, st_spec->window, mobject);
} /* open_text */

/*****************************************************************************/

LOCAL VOID close_text (window)
WINDOWP window;

{
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;
  ST_SPEC   *st_spec;

  st_spec   = (ST_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)st_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [st_spec->obj];

  box (window, FALSE, st_spec->window, mobject);
} /* close_text */

/*****************************************************************************/

LOCAL VOID click_text (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  STRING    s;
  FONTDESC  fontdesc;
  MTEXT     *mtext;
  ST_SPEC   *st_spec;
  MASK_SPEC *mask_spec;

  st_spec   = (ST_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)st_spec->window->special;
  mtext     = &st_spec->mtext;

  switch (window->exit_obj)
  {
    case STFONT   : fontdesc.font    = mtext->font;
                    fontdesc.point   = mtext->point;
                    fontdesc.effects = get_flags (seltext);
                    fontdesc.color   = mtext->color;

                    if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc))
                    {
                      mtext->font    = fontdesc.font;
                      mtext->point   = fontdesc.point;
                      mtext->effects = fontdesc.effects;
                      mtext->color   = fontdesc.color;

                      FontNameFromNumber (s, mtext->font);
                      s [FONTNAME_LENGTH] = EOS;
                      set_str (seltext, STFONTN, s);

                      sprintf (s, "%-3d", mtext->point);
                      set_str (seltext, STPOINT, s);

                      set_checkbox (seltext, STTHICK,  mtext->effects & TXT_THICKENED);
                      set_checkbox (seltext, STLIGHT,  mtext->effects & TXT_LIGHT);
                      set_checkbox (seltext, STSKEWED, mtext->effects & TXT_SKEWED);
                      set_checkbox (seltext, STUNDERL, mtext->effects & TXT_UNDERLINED);
                      set_checkbox (seltext, STOUTLIN, mtext->effects & TXT_OUTLINED);

                      draw_object (window, STFONTN);
                      draw_object (window, STPOINT);
                      draw_object (window, STTHICK);
                      draw_object (window, STLIGHT);
                      draw_object (window, STSKEWED);
                      draw_object (window, STUNDERL);
                      draw_object (window, STOUTLIN);
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case STOK     : get_text (st_spec);
                    set_redraw (st_spec->window, &st_spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case STHELP   : hndl_help (HTEXT);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  exit_obj = window->exit_obj;
} /* click_text */

/*****************************************************************************/

LOCAL BOOLEAN key_text (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;

  p = get_str (seltext, STTEXT);

  if ((any_ed_empty (seltext, STXPOS, STYPOS) || (*p == EOS)) == ! is_state (seltext, STOK, DISABLED))
  {
    flip_state (seltext, STOK, DISABLED);
    draw_object (window, STOK);
  } /* if */

  return (FALSE);
} /* key_text */

/*****************************************************************************/

LOCAL UWORD get_flags (tree)
OBJECT *tree;

{
  UWORD flags;

  flags = 0;

  if (get_checkbox (tree, STTHICK))  flags |= TXT_THICKENED;
  if (get_checkbox (tree, STLIGHT))  flags |= TXT_LIGHT;
  if (get_checkbox (tree, STSKEWED)) flags |= TXT_SKEWED;
  if (get_checkbox (tree, STUNDERL)) flags |= TXT_UNDERLINED;
  if (get_checkbox (tree, STOUTLIN)) flags |= TXT_OUTLINED;

  return (flags);
} /* get_flags */

/*****************************************************************************/

LOCAL BOOLEAN any_ed_empty (tree, start, end)
OBJECT *tree;
WORD   start;
WORD   end;

{
  WORD obj;
  BYTE *p;

  obj = start;

  for (obj = start; obj <= end; obj++)
    if (is_flags (tree, obj, EDITABLE) &&
       ((OB_TYPE (tree, obj) == G_FTEXT) || (OB_TYPE (tree, obj) == G_FBOXTEXT)))
    {
      p = get_str (tree, obj);
      if (*p == EOS) return (TRUE);
    } /* if, for */

  return (FALSE);
} /* any_ed_empty */
