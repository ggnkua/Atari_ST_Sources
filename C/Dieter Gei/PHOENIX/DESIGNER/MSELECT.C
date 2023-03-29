/*****************************************************************************
 *
 * Module : MSELECT.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 27.07.95
 *
 *
 * Description: This module implements the mask select dialog box.
 *
 * History:
 * 27.07.95: SM_SHOW_3d added in std_mask and in click_mselect
 * 22.03.95: Check on tablename in for loop removed in exist
 * 04.01.95: Using new function names of controls module
 * 18.08.94: SM_SHOW_INFO and SM_SHOW_MENU added in std_mask
 * 30.10.93: LBS_TOUCHEXIT removed in call to ListBoxSetStyle
 * 28.10.93: New 3D listboxes used
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
#include "mask.h"
#include "mclick.h"

#include "export.h"
#include "mselect.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD    exit_obj;     /* will be set on dialog exit */
LOCAL BYTE    *mnames;      /* pointer to mask names */
LOCAL HLPMASK hlpmask;
LOCAL WORD    index;
LOCAL BOOLEAN new;

/****** FUNCTIONS ************************************************************/

LOCAL LONG    callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));

LOCAL VOID    set_mselect   _((BASE_SPEC *base_spec, BYTE *name));
LOCAL VOID    close_mselect _((WINDOWP window));
LOCAL VOID    click_mselect _((WINDOWP window, MKINFO *mk));

LOCAL VOID    set_objs      _((WINDOWP window));
LOCAL BOOLEAN check_mask    _((BASE_SPEC *base_spec, WORD amount));
LOCAL VOID    del_mask      _((BASE_SPEC *base_spec, WORD index));
LOCAL VOID    set_names     _((BASE_SPEC *base_spec, BYTE device));
LOCAL WORD    exist         _((BASE_SPEC *base_spec, BYTE device, BYTE *name));

/*****************************************************************************/

GLOBAL VOID mselect (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  TABLE_INFO table_info;
  WINDOWP    window;
  WORD       ret;

  exit_obj = SMCANCEL;
  window   = search_window (CLASS_DIALOG, SRCH_ANY, SELMASK);

  if (window == NULL)
  {
    form_center (selmask, &ret, &ret, &ret, &ret);
    window = crt_dialog (selmask, NULL, SELMASK, FREETXT (FSELMASK), WI_MODAL);

    if (window != NULL)
    {
      window->close = close_mselect;
      window->click = click_mselect;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (selmask, ROOT, EDITABLE);
    window->edit_inx = NIL;
    window->special  = (LONG)base_spec;

    strcpy (table_info.name, "");
    if (table != FAILURE) v_tableinfo (base_spec, table, &table_info);
    set_mselect (base_spec, table_info.name);

    if (! open_dialog (SELMASK))
      hndl_alert (ERR_NOOPEN);
    else
      if (exit_obj == SMOPEN) open_mask (NIL, &hlpmask, base_spec, index, new);
  } /* if */
} /* mselect */

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  RECT         r;
  BYTE         *text;
  LB_OWNERDRAW *lb_ownerdraw;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&mnames [index * sizeof (FIELDNAME)]);
    case LBN_DRAWITEM   : lb_ownerdraw = p;
                          text = (BYTE *)ListBoxSendMessage (tree, obj, LBN_GETITEM, index, NULL);
                          r    = lb_ownerdraw->rc_item;
                          r.w  = 2 * gl_wbox;
                          DrawOwnerIcon (lb_ownerdraw, &r, &msk_icon, text, 2);
                          break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID set_mselect (base_spec, name)
BASE_SPEC *base_spec;
BYTE      *name;

{
  WORD   size, w;
  STRING dbname;

  w = selmask [SMDBNAME].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy (get_str (selmask, SMDBNAME), dbname);

  set_str (selmask, SMNAME, name);
  set_rbutton (selmask, SMSCREEN, SMSCREEN, SMPRINTR);

  do_state (selmask, SMOPEN,   DISABLED);
  do_state (selmask, SMDELETE, DISABLED);

  ListBoxSetCallback (selmask, SMLIST, callback);
  ListBoxSetStyle (selmask, SMLIST, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE, TRUE);
  ListBoxSetStyle (selmask, SMLIST, LBS_OWNERDRAW, (colors >= 16) && (gl_hbox > 8) && (msk_icon.data != NULL));
  ListBoxSetLeftOffset (selmask, SMLIST, gl_wbox / 2);
  ListBoxSetCount (selmask, SMLIST, 0, NULL);
  ListBoxSetCurSel (selmask, SMLIST, FAILURE);
  ListBoxSetTopIndex (selmask, SMLIST, 0);

  if ((colors >= 16) && (gl_hbox > 8))
    ListBoxSetStyle (selmask, SMLIST, LBS_OWNERDRAW, msk_icon.data != NULL);

  size   = sizeof (FIELDNAME);
  mnames = mem_alloc ((LONG)base_spec->max_masks * size);

  if (mnames != NULL) set_names (base_spec, MASK_SCREEN);
  set_objs (search_window (CLASS_DIALOG, SRCH_ANY, SELMASK));
} /* set_mselect */

/*****************************************************************************/

LOCAL VOID close_mselect (window)
WINDOWP window;

{
  mem_free (mnames);
} /* close_mselect */

/*****************************************************************************/

LOCAL VOID click_mselect (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN   dclick;
  WORD      button, inx;
  BYTE      device;
  FIELDNAME name;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;
  dclick    = FALSE;

  if (window->exit_obj == SMLIST)
  {
    inx = ListBoxClick (window->object, window->exit_obj, mk);

    if (inx != FAILURE)
    {
      dclick = mk->breturn == 2;
      ListBoxGetText (window->object, window->exit_obj, inx, name);
      set_str (selmask, SMNAME, name);
      draw_object (window, SMNAME);
      set_cursor (window, SMNAME, NIL);
    } /* if */
  } /* if */

  inx    = ListBoxGetCurSel (selmask, SMLIST);
  button = get_rbutton (selmask, SMSCREEN);
  device = (button == SMSCREEN) ? MASK_SCREEN : MASK_PRINTER;

  if (dclick)
  {
    window->exit_obj  = SMOPEN;
    window->flags    |= WI_DLCLOSE;
  } /* if */

  switch (window->exit_obj)
  {
    case SMOPEN   : strcpy (name, get_str (selmask, SMNAME));
                    index = exist (base_spec, device, name);
                    new   = index == FAILURE;

                    if (new && ! check_mask (base_spec, 1))
                      hndl_alert (ERR_NOMASKS);
                    else
                    {
                      if (new)
                      {
                        mem_set (&hlpmask, 0, sizeof (HLPMASK));

                        strcpy (hlpmask.name, name);
                        hlpmask.device [0] = device;
                        hlpmask.findex     = FAILURE;
                        hlpmask.flags      = SM_SHOW_ICONS | SM_SHOW_INFO | SM_SHOW_MENU | SM_SHOW_3D;
                        hlpmask.version    = MASK_VERSION;

                        set_null (TYPE_WORD, &hlpmask.x);
                        set_null (TYPE_WORD, &hlpmask.y);
                        set_null (TYPE_WORD, &hlpmask.w);
                        set_null (TYPE_WORD, &hlpmask.h);
                        set_null (TYPE_LONG, &hlpmask.bkcolor);

                        if (hlpmask.flags & SM_SHOW_3D) hlpmask.bkcolor = Color32FromIndex (DWHITE);
                      } /* if */
                      else
                        hlpmask = base_spec->sysmask [index];
                    } /* else */
                    break;
    case SMDELETE : ListBoxGetText (window->object, SMLIST, inx, name);
                    index = exist (base_spec, device, name);
                    del_mask (base_spec, index);
                    set_names (base_spec, device);

                    ListBoxSetCurSel (window->object, SMLIST, FAILURE);
                    ListBoxSetTopIndex (window->object, SMLIST, 0);
                    ListBoxRedraw (window->object, SMLIST);

                    do_state (selmask, window->exit_obj, DISABLED);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SMHELP   : hndl_help (HSELMASK);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case SMSCREEN :
    case SMPRINTR : set_names (base_spec, device);
                    ListBoxSetCurSel (window->object, SMLIST, FAILURE);
                    ListBoxSetTopIndex (window->object, SMLIST, 0);
                    ListBoxRedraw (window->object, SMLIST);
                    break;
    case SMCANCEL : draw_growbox (window, FALSE);
                    break;
  } /* switch */

  set_objs (window);

  exit_obj = window->exit_obj;
} /* click_mselect */

/*****************************************************************************/

LOCAL VOID set_objs (window)
WINDOWP window;

{
  BYTE *name;

  name = get_str (selmask, SMNAME);

  if ((*name == EOS) == ! is_state (selmask, SMOPEN, DISABLED))
  {
    flip_state (selmask, SMOPEN, DISABLED);
    draw_object (window, SMOPEN);
  } /* if */

  if ((ListBoxGetCurSel (selmask, SMLIST) == FAILURE) == ! is_state (selmask, SMDELETE, DISABLED))
  {
    flip_state (selmask, SMDELETE, DISABLED);
    draw_object (window, SMDELETE);
  } /* if */
} /* set_objs */

/*****************************************************************************/

LOCAL BOOLEAN check_mask (base_spec, amount)
BASE_SPEC *base_spec;
WORD      amount;

{
  return (base_spec->num_masks + amount <= base_spec->max_masks);
} /* check_format */

/*****************************************************************************/

LOCAL VOID del_mask (base_spec, index)
BASE_SPEC *base_spec;
WORD      index;

{
  HLPMASK *sysmask;

  sysmask = &base_spec->sysmask [index];

  if (sysmask->flags & MOD_FLAG)
    sysmask->flags |= DEL_FLAG;
  else
    sysmask->flags = 0;

  sysmask->device [0]    = EOS;
  sysmask->tablename [0] = EOS;
  base_spec->modified    = TRUE;
} /* del_mask */

/*****************************************************************************/

LOCAL VOID set_names (base_spec, device)
BASE_SPEC *base_spec;
BYTE      device;

{
  WORD    i, num_items;
  BYTE    *mem;
  HLPMASK *sysmask;

  num_items = 0;
  mem       = mnames;
  sysmask   = base_spec->sysmask;

  for (i = 0; i < base_spec->num_masks; i++, sysmask++)
    if (sysmask->device [0] == device)
    {
      num_items++;
      sprintf (mem, "%s", sysmask->name);
      mem += sizeof (FIELDNAME);
    } /* if, for */

  ListBoxSetCount (selmask, SMLIST, num_items, NULL);
} /* set_names */

/*****************************************************************************/

LOCAL WORD exist (base_spec, device, name)
BASE_SPEC *base_spec;
BYTE      device;
BYTE      *name;

{
  WORD    i;
  STRING  s, mname;
  HLPMASK *sysmask;

  if (*name == EOS) return (FAILURE);

  sysmask = base_spec->sysmask;
  strcpy (s, name);

  if (base_spec->base == NULL)
  {
    str_ascii (s);
    str_upper (s);
  } /* if */
  else
    db_convstr (base_spec->base, s);

  for (i = 0; i < base_spec->num_masks; i++, sysmask++)
    if (sysmask->device [0] == device)
    {
      strcpy (mname, sysmask->name);

      if (base_spec->base == NULL)
      {
        str_ascii (mname);
        str_upper (mname);
      } /* if */
      else
        db_convstr (base_spec->base, mname);

      if (strcmp (mname, s) == 0) return (i);
    } /* if */

  return (FAILURE);
} /* exist */

/*****************************************************************************/

