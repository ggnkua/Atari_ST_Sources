/*****************************************************************************
 *
 * Module : MMASKINF.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 12.07.95
 *
 *
 * Description: This module implements the mask info dialog box.
 *
 * History:
 * 12.07.95: SM_SHOW_3D added
 * 04.01.95: Using new function names of controls module
 * 30.11.94: strupper (tablename) removed in get_maskinfo
 * 10.10.94: Test on tablename removed in set_maskinfo
 * 27.09.94: Test on tablename removed in key_maskinfo
 * 03.11.93: Redraw mask window if new background color set
 * 23.10.93: New color selection added
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
#include "controls.h"
#include "dialog.h"
#include "mclick.h"
#include "mload.h"

#include "export.h"
#include "mmaskinf.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD exit_obj;    /* will be set on dialog exit */

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback       _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    get_maskinfo   _((MASK_SPEC *mask_spec));
LOCAL VOID    set_maskinfo   _((MASK_SPEC *mask_spec));
LOCAL VOID    click_maskinfo _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_maskinfo   _((WINDOWP window, MKINFO *mk));

LOCAL WORD    find_user      _((BASE_SPEC *base_spec, BYTE *name));

/*****************************************************************************/

GLOBAL BOOLEAN mmaskinfo (mask_spec)
MASK_SPEC *mask_spec;

{
  WINDOWP window;
  WORD    ret;

  exit_obj = MICANCEL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, MASKINFO);

  if (window == NULL)
  {
    form_center (maskinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (maskinfo, NULL, MASKINFO, FREETXT (FMASKINF), WI_MODELESS);

    if (window != NULL)
    {
      window->click = click_maskinfo;
      window->key   = key_maskinfo;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (maskinfo, ROOT, EDITABLE);
    window->edit_inx = NIL;
    window->special  = (LONG)mask_spec;

    set_maskinfo (mask_spec);
    set_redraw (window, &window->scroll);

    if (! open_dialog (MASKINFO)) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (exit_obj == MIOK);
} /* mmaskinfo */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP      window;
  BOOLEAN      visible_part;
  LB_OWNERDRAW *lb_ownerdraw;
  RECT         r;
  BYTE         *text;

  window = (WINDOWP)ListBoxGetSpec (tree, obj);

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)(get_str (popups, COWHITE + (WORD)index) + 1));
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          visible_part = index == FAILURE;

                          if (visible_part)
                            index = ListBoxGetCurSel (tree, obj);

                          if (index != FAILURE)
                          {
                            text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                            r    = lb_ownerdraw->rc_item;
                            r.x++;
                            r.y++;
                            r.w  = 2 * gl_wbox;
                            r.h -= 2;

                            r.x++;
                            if (visible_part) r.y++;
                            r.w -= 2;
                            if (visible_part) r.h -= 2;
                            DrawOwnerColor (lb_ownerdraw, &r, (WORD)index, text, 2);
                          } /* if */
                          break;
    case LBN_SELCHANGE  : ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, TRUE);
                          draw_win_obj (window, tree, obj);
                          ListBoxSetStyle (tree, obj, LBS_COMBOTEXTREDRAW, FALSE);
                          break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID get_maskinfo (mask_spec)
MASK_SPEC *mask_spec;

{
  BOOLEAN bOld3D, bNew3D;
  SHORT   sIndex;
  LONG    bkcolor;
  SYSMASK *sysmask;

  sysmask = &mask_spec->mask;
  bkcolor = sysmask->bkcolor;
  bOld3D  = (sysmask->flags & SM_SHOW_3D) != 0;

  get_ptext (maskinfo, MINAME,   sysmask->name);
  get_ptext (maskinfo, MITABLE,  sysmask->tablename);
  get_ptext (maskinfo, MIUSER,   sysmask->username);
  get_ptext (maskinfo, MICENTRY, sysmask->calcentry);
  get_ptext (maskinfo, MICEXIT,  sysmask->calcexit);

  sysmask->x = get_word (maskinfo, MIX);
  sysmask->y = get_word (maskinfo, MIY);
  sysmask->w = get_word (maskinfo, MIW);
  sysmask->h = get_word (maskinfo, MIH);

  sysmask->flags &= ~ (SM_SHOW_ICONS | SM_SHOW_INFO | SM_SHOW_MENU | SM_SHOW_3D);

  if (get_checkbox (maskinfo, MIICONS)) sysmask->flags |= SM_SHOW_ICONS;
  if (get_checkbox (maskinfo, MIINFO))  sysmask->flags |= SM_SHOW_INFO;
  if (get_checkbox (maskinfo, MIMENU))  sysmask->flags |= SM_SHOW_MENU;
  if (get_checkbox (maskinfo, MI3D))    sysmask->flags |= SM_SHOW_3D;

  sIndex = ListBoxGetCurSel (maskinfo, MICOLOR);
  if (sysmask->flags & SM_SHOW_3D) sIndex = DWHITE;	/* GRAY */
  sysmask->bkcolor = Color32FromIndex (sIndex);

  bNew3D = (sysmask->flags & SM_SHOW_3D) != 0;

  if ((bkcolor != sysmask->bkcolor) || (bOld3D != bNew3D))	/* redraw only if old bkg color not new bkg color or 3d effects changed*/
    set_redraw (mask_spec->window, &mask_spec->window->scroll);
} /* get_maskinfo */

/*****************************************************************************/

LOCAL VOID set_maskinfo (mask_spec)
MASK_SPEC *mask_spec;

{
  FULLNAME   dbname;
  WORD       w;
  SYSMASK    *sysmask;
  BASE_SPEC  *base_spec;

  base_spec = mask_spec->base_spec;
  sysmask   = &mask_spec->mask;

  w = maskinfo [MIDBNAME].ob_width / gl_wbox;
  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy (get_str (maskinfo, MIDBNAME), dbname);

  if (sysmask->device [0] == MASK_SCREEN)
    strcpy (get_str (maskinfo, MIDEVICE), FREETXT (FSCREEN));
  else
    strcpy (get_str (maskinfo, MIDEVICE), FREETXT (FPRINTER));

  set_str (maskinfo, MINAME,   sysmask->name);
  set_str (maskinfo, MITABLE,  sysmask->tablename);
  set_str (maskinfo, MIUSER,   sysmask->username);
  set_str (maskinfo, MICENTRY, sysmask->calcentry);
  set_str (maskinfo, MICEXIT,  sysmask->calcexit);

  set_word (maskinfo, MIX, sysmask->x);
  set_word (maskinfo, MIY, sysmask->y);
  set_word (maskinfo, MIW, sysmask->w);
  set_word (maskinfo, MIH, sysmask->h);

  sprintf (get_str (maskinfo, MIOBJS), "%d", mask_spec->objs);
  sprintf (get_str (maskinfo, MIMAXOBJ), "%d", mask_spec->max_objs);

  set_checkbox (maskinfo, MIICONS, sysmask->flags & SM_SHOW_ICONS);
  set_checkbox (maskinfo, MI3D,    sysmask->flags & SM_SHOW_3D);
  set_checkbox (maskinfo, MIINFO,  (sysmask->flags & SM_SHOW_INFO) || (sysmask->version < 1));
  set_checkbox (maskinfo, MIMENU,  (sysmask->flags & SM_SHOW_MENU) || (sysmask->version < 1));

  ListBoxSetCallback (maskinfo, MICOLOR, callback);
  ListBoxSetStyle (maskinfo, MICOLOR, LBS_OWNERDRAW, TRUE);
  ListBoxSetStyle (maskinfo, MICOLOR, LBS_VSCROLL, FALSE);
  ListBoxSetCount (maskinfo, MICOLOR, min (colors, 16), NULL);
  ListBoxSetCurSel (maskinfo, MICOLOR, IndexFromColor32 (sysmask->bkcolor));
  ListBoxSetLeftOffset (maskinfo, MICOLOR, 0);
} /* set_maskinfo */

/*****************************************************************************/

LOCAL VOID click_maskinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONG      w, h;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;

  switch (window->exit_obj)
  {
    case MICOLOR  : ListBoxSetComboRect (window->object, window->exit_obj, NULL, min (colors, 16));
                    ListBoxSetSpec (window->object, window->exit_obj, (LONG)window);
                    ListBoxComboClick (window->object, window->exit_obj, mk);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case MIGETSIZ : m_get_doc (mask_spec->window, &w, &h);

                    set_long (maskinfo, MIW, w);
                    set_long (maskinfo, MIH, h);

                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    draw_object (window, MIW);
                    draw_object (window, MIH);
                    break;
    case MIOK     : get_maskinfo (mask_spec);
                    mask_spec->modified = TRUE;
                    m_wi_title (mask_spec->window);
                    break;
    case MIHELP   : hndl_help (HMASKINF);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  exit_obj = window->exit_obj;
} /* click_maskinfo */

/*****************************************************************************/

LOCAL BOOLEAN key_maskinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN    user_ok;
  WORD       user;
  BYTE       *p1, *p2, *p3;
  BASE_SPEC  *base_spec;
  MASK_SPEC  *mask_spec;

  mask_spec = (MASK_SPEC *)window->special;
  base_spec = mask_spec->base_spec;

  switch (window->edit_obj)
  {
    case MINAME :
    case MITABLE: 
    case MIUSER : p1 = get_str (maskinfo, MINAME);
                  p2 = get_str (maskinfo, MITABLE);
                  p3 = get_str (maskinfo, MIUSER);

                  user    = find_user (base_spec, p3);
                  user_ok = (user != FAILURE) || (*p3 == EOS);

                  if (((*p1 == EOS) ||
                       (*p2 == EOS) || 
                       ! user_ok) == ! is_state (maskinfo, MIOK, DISABLED))
                  {
                    flip_state (maskinfo, MIOK, DISABLED);
                    draw_object (window, MIOK);
                  } /* if */
                  break;
  } /* switch */

  return (FALSE);
} /* key_maskinfo */

/*****************************************************************************/

LOCAL WORD find_user (base_spec, name)
BASE_SPEC *base_spec;
BYTE      *name;

{
  WORD    user;
  SYSUSER *sysuser;

  sysuser = base_spec->sysuser;

  for (user = 0; user < base_spec->num_users; user++, sysuser++)
    if (strcmp (sysuser->name, name) == 0) return (user);

  return (FAILURE);
} /* find_user */
