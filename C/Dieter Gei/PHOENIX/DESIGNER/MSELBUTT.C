/*****************************************************************************
 *
 * Module : MSELBUTT.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 25.10.95
 *
 *
 * Description: This module implements the mask select button dialog box.
 *
 * History:
 * 25.10.95: Definition of MultiButton added
 * 04.01.95: Using new function names of controls module
 * 20.11.93: Old mselfont.h replaced with CommDlg functions
 * 18.11.93: GetFontDialog used instead of mselfont
 * 16.11.93: Draw font name and size if font selected
 * 04.11.93: Static strings cause small AES stack in callback changed
 * 30.10.93: #include popup.h deleted
 * 28.10.93: ListBoxSetComboRect call modified in click_nfield
 * 23.10.93: New 3D listboxes used
 * 08.09.93: set_ptext -> set_str
 * 06.09.93: Modifications for user defined buttons added
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
#include "mselbutt.h"

/****** DEFINES **************************************************************/

#define FONTNAME_LENGTH 16	/* see resource file */
#define SB_LINES         4	/* see resource file */
#define SB_COLS         52	/* see resource file */
#define VISIBLE          6	/* number of lines in combobox */

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    obj;
  MBUTTON mbutton;
  WINDOWP window;       /* mask window */
} SB_SPEC;

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj;
LOCAL WORD    command;
LOCAL SB_SPEC sb_spec;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    box          _((WINDOWP window, BOOLEAN grow, WINDOWP mask_window, MOBJECT *mobject));

LOCAL VOID    get_button   _((SB_SPEC *sb_spec));
LOCAL VOID    set_button   _((SB_SPEC *sb_spec));
LOCAL VOID    open_button  _((WINDOWP window));
LOCAL VOID    close_button _((WINDOWP window));
LOCAL VOID    click_button _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_button   _((WINDOWP window, MKINFO *mk));

LOCAL BOOLEAN any_ed_empty _((OBJECT *tree, WORD start, WORD end));
LOCAL VOID    get_param    _((BYTE *s));
LOCAL VOID    set_param    _((BYTE *s));

/*****************************************************************************/

GLOBAL WORD mselbutton (mask_window, obj)
WINDOWP mask_window;
WORD    obj;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, SELBUTTO);

  if (window == NULL)
  {
    form_center (selbutto, &ret, &ret, &ret, &ret);
    window = crt_dialog (selbutto, NULL, SELBUTTO, FREETXT (FBUTTON), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_button;
      window->close   = close_button;
      window->click   = click_button;
      window->key     = key_button;
      window->special = (LONG)&sb_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = SBTEXT;
    window->edit_inx = NIL;

    sb_spec.obj    = obj;
    sb_spec.window = mask_window;

    set_button (&sb_spec);

    if (! open_dialog (SELBUTTO)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (exit_obj);
} /* mselbutton */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  BOOLEAN      visible_part;
  RECT         r;
  WINDOWP      window;
  LOCAL STRING s;	/* static cause small AES stack */
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)FREETXT (FMASKINFO + index));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.w  = 2 * gl_wbox;
                            DrawOwnerIcon (lb_ownerdraw, &r, &cal_icon, text, 2);
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

LOCAL VOID box (window, grow, mask_window, mobject)
WINDOWP window;
BOOLEAN grow;
WINDOWP mask_window;
MOBJECT *mobject;

{
  RECT  l, b;
  FATTR fattr;

  m_get_rect (mask_window, vdi_handle, M_BUTTON, mobject, &l, &fattr);

  wind_calc (WC_BORDER, window->kind,           /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID get_button (sb_spec)
SB_SPEC *sb_spec;

{
  WORD      wchar, hchar, wbox, hbox;
  WORD      font, point, color, form;
  UWORD     flags;
  LONGSTR   s;
  MBUTTON   *mbutton;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec  = (MASK_SPEC *)sb_spec->window->special;
  mbutton    = &sb_spec->mbutton;
  font       = mbutton->font;
  point      = mbutton->point;
  color      = mbutton->color;
  form       = get_rbutton (selbutto, SBROUND);
  flags      = get_checkbox (selbutto, SBHIDDEN) ? MBF_HIDDEN: 0;
  flags     |= (form == SBROUND) ? MBF_ROUNDED : MBF_RECTANGLE;

  sysmask  = &mask_spec->mask;
  mobject  = (MOBJECT *)sysmask->mask.buffer;
  mobject  = &mobject [sb_spec->obj];
  mbutton  = &mobject->mbutton;

  vst_font (vdi_handle, font);
  vst_point (vdi_handle, point, &wchar, &hchar, &wbox, &hbox);
  if ((font == FONT_SYSTEM) && (point == gl_point) && (wchar == gl_wchar)) flags |= MF_SYSTEMFONT;

  get_ptext (selbutto, SBTEXT, s);
  del_str (mask_spec, mbutton->text);
  mbutton->text = add_str (mask_spec, s);

  get_param (s);
  del_str (mask_spec, mbutton->param);
  mbutton->param = add_str (mask_spec, s);

  mbutton->x       = get_word (selbutto, SBX);
  mbutton->y       = get_word (selbutto, SBY);
  mbutton->w       = get_word (selbutto, SBW);
  mbutton->h       = get_word (selbutto, SBH);
  mbutton->font    = font;
  mbutton->point   = point;
  mbutton->color   = color;
  mbutton->command = ListBoxGetCurSel (selbutto, SBFUNC);
  mbutton->flags   = flags;
} /* get_button */

/*****************************************************************************/

LOCAL VOID set_button (sb_spec)
SB_SPEC *sb_spec;

{
  WORD      chars, form;
  STRING    s;
  MBUTTON   *mbutton;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)sb_spec->window->special;
  mbutton   = &sb_spec->mbutton;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [sb_spec->obj];
  chars     = selbutto [SBFUNC].ob_width / gl_wbox - 1; /* 1 blank at beginning */

  mem_move (mbutton, mobject, sizeof (MBUTTON));

  ListBoxSetCallback (selbutto, SBFUNC, callback);
  ListBoxSetStyle (selbutto, SBFUNC, LBS_VSCROLL | LBS_VREALTIME, TRUE);
  ListBoxSetStyle (selbutto, SBFUNC, LBS_OWNERDRAW, (colors >= 16) && (gl_hbox > 8) && (cal_icon.data != NULL));
  ListBoxSetLeftOffset (selbutto, SBFUNC, gl_wbox / 2);
  ListBoxSetCount (selbutto, SBFUNC, MB_COMMANDS, NULL);
  ListBoxSetCurSel (selbutto, SBFUNC, mbutton->command);

  strcpy (s, " ");
  strcat (s, FREETXT (FMASKINFO + mbutton->command));
  s [chars] = EOS;
  command   = mbutton->command;

  set_str (selbutto, SBTEXT, &sysmask->mask.buffer [mbutton->text]);
  set_param (&sysmask->mask.buffer [mbutton->param]);
  set_str (selbutto, SBFUNC, s);

  set_word (selbutto, SBX, mbutton->x);
  set_word (selbutto, SBY, mbutton->y);
  set_word (selbutto, SBW, mbutton->w);
  set_word (selbutto, SBH, mbutton->h);

  form = (mbutton->flags & MBF_ROUNDED) ? SBROUND : SBRECT;
  set_rbutton (selbutto, form, SBROUND, SBRECT);

  set_checkbox (selbutto, SBHIDDEN, mbutton->flags & MBF_HIDDEN);

  FontNameFromNumber (s, mbutton->font);
  s [FONTNAME_LENGTH] = EOS;
  set_str (selbutto, SBFONTN, s);

  sprintf (s, "%-3d", mbutton->point);
  set_str (selbutto, SBPOINT, s);

  if (any_ed_empty (selbutto, SBX, SBH) == ! is_state (selbutto, SBOK, DISABLED)) flip_state (selbutto, SBOK, DISABLED);

  exit_obj = SBCANCEL;
} /* set_button */

/*****************************************************************************/

LOCAL VOID open_button (window)
WINDOWP window;

{
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;
  SB_SPEC   *sb_spec;

  sb_spec   = (SB_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)sb_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [sb_spec->obj];

  box (window, TRUE, sb_spec->window, mobject);
} /* open_button */

/*****************************************************************************/

LOCAL VOID close_button (window)
WINDOWP window;

{
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;
  SB_SPEC   *sb_spec;

  sb_spec   = (SB_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)sb_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [sb_spec->obj];

  box (window, FALSE, sb_spec->window, mobject);
} /* close_button */

/*****************************************************************************/

LOCAL VOID click_button (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  STRING    s;
  FONTDESC  fontdesc;
  MBUTTON   *mbutton;
  SB_SPEC   *sb_spec;
  MASK_SPEC *mask_spec;

  sb_spec   = (SB_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)sb_spec->window->special;
  mbutton   = &sb_spec->mbutton;

  switch (window->exit_obj)
  {
    case SBFUNC   : ListBoxSetComboRect (window->object, window->exit_obj, NULL, VISIBLE);
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    ListBoxComboClick (window->object, window->exit_obj, mk);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SBFONT   : fontdesc.font    = mbutton->font;
                    fontdesc.point   = mbutton->point;
                    fontdesc.effects = TXT_NORMAL;
                    fontdesc.color   = mbutton->color;

                    if (GetFontDialog (FREETXT (FFONT), get_str (helpinx, HSELFONT), FONT_FLAG_HIDE_EFFECTS | FONT_FLAG_SHOW_ALL, vdi_handle, &fontdesc))
                    {
                      mbutton->font  = fontdesc.font;
                      mbutton->point = fontdesc.point;
                      mbutton->color = fontdesc.color;

                      FontNameFromNumber (s, mbutton->font);
                      s [FONTNAME_LENGTH] = EOS;
                      set_str (selbutto, SBFONTN, s);

                      sprintf (s, "%-3d", mbutton->point);
                      set_str (selbutto, SBPOINT, s);

                      draw_object (window, SBFONTN);
                      draw_object (window, SBPOINT);
                    } /* if */

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SBOK     : get_button (sb_spec);
                    set_redraw (sb_spec->window, &sb_spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case SBHELP   : hndl_help (HBUTTON);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  exit_obj = window->exit_obj;
} /* click_button */

/*****************************************************************************/

LOCAL BOOLEAN key_button (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (any_ed_empty (selbutto, SBX, SBH) == ! is_state (selbutto, SBOK, DISABLED))
  {
    flip_state (selbutto, SBOK, DISABLED);
    draw_object (window, SBOK);
  } /* if */

  return (FALSE);
} /* key_button */

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

/*****************************************************************************/

LOCAL VOID get_param (s)
BYTE *s;

{
  WORD i;
  BYTE *p;

  *s = EOS;

  for (i = 0; i < SB_LINES; i++)
  {
    p = get_str (selbutto, SBPARAM1 + i);
    strcat (s, p);
  } /* for */
} /* get_param */

/*****************************************************************************/

LOCAL VOID set_param (s)
BYTE *s;

{
  WORD i, l;

  l = strlen (s);

  for (i = 0; i < SB_LINES; i++, l -= SB_COLS, s += SB_COLS)
    if (l > 0)
      set_str (selbutto, SBPARAM1 + i, s);
    else
      set_str (selbutto, SBPARAM1 + i, "");
} /* set_param */

/*****************************************************************************/

