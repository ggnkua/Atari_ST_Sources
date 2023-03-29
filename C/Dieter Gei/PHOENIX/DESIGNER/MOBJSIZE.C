/*****************************************************************************
 *
 * Module : MOBJSIZE.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification: 16.03.97
 *
 *
 * Description: This module implements the dialog boxes for size, picture size and line size
 *
 * History:
 * 16.03.97: Check for existence of file before calling OlgaStart
 * 19.02.97: OLGA functionality (edit_pic) added
 * 05.01.91: Not modified until OLGA implementation
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "dialog.h"
#include "mclick.h"

#include "export.h"
#include "mobjsize.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

typedef struct
{
  WORD    obj;
  WINDOWP window;       /* mask window */
} SIZE_SPEC;

/****** VARIABLES ************************************************************/

LOCAL SIZE_SPEC size_spec;
LOCAL FULLNAME  szOlgaFilename;	/* for OLGA communication, should be static */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    box          _((WINDOWP window, BOOLEAN grow, WINDOWP mask_window, WORD obj));
LOCAL VOID    open_size    _((WINDOWP window));
LOCAL VOID    close_size   _((WINDOWP window));

LOCAL VOID    get_size     _((SIZE_SPEC *size_spec));
LOCAL VOID    set_size     _((SIZE_SPEC *size_spec));
LOCAL VOID    click_size   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_size     _((WINDOWP window, MKINFO *mk));

LOCAL VOID    edit_pic      _((SIZE_SPEC *size_spec));
LOCAL VOID    get_psize     _((SIZE_SPEC *size_spec));
LOCAL VOID    set_psize     _((SIZE_SPEC *size_spec));
LOCAL VOID    click_psize   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_psize     _((WINDOWP window, MKINFO *mk));

LOCAL VOID    get_lsize     _((SIZE_SPEC *size_spec));
LOCAL VOID    set_lsize     _((SIZE_SPEC *size_spec));
LOCAL VOID    click_lsize   _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_lsize     _((WINDOWP window, MKINFO *mk));

LOCAL BOOLEAN any_ed_empty _((OBJECT *tree));

/*****************************************************************************/

GLOBAL VOID mobjsize (mask_window, obj)
WINDOWP mask_window;
WORD    obj;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, OBJSIZE);

  if (window == NULL)
  {
    form_center (objsize, &ret, &ret, &ret, &ret);
    window = crt_dialog (objsize, NULL, OBJSIZE, FREETXT (FOBJSIZE), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_size;
      window->close   = close_size;
      window->click   = click_size;
      window->key     = key_size;
      window->special = (LONG)&size_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (objsize, ROOT, EDITABLE);
    window->edit_inx = NIL;

    size_spec.obj    = obj;
    size_spec.window = mask_window;

    set_size (&size_spec);

    if (! open_dialog (OBJSIZE)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mobjsize */

/*****************************************************************************/

GLOBAL VOID mpicsize (mask_window, obj)
WINDOWP mask_window;
WORD    obj;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, PICSIZE);

  if (window == NULL)
  {
    form_center (picsize, &ret, &ret, &ret, &ret);
    window = crt_dialog (picsize, NULL, PICSIZE, FREETXT (FPICSIZE), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_size;
      window->close   = close_size;
      window->click   = click_psize;
      window->key     = key_psize;
      window->special = (LONG)&size_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (picsize, ROOT, EDITABLE);
    window->edit_inx = NIL;

    size_spec.obj    = obj;
    size_spec.window = mask_window;

    set_psize (&size_spec);

    if (! open_dialog (PICSIZE)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mpicsize */

/*****************************************************************************/

GLOBAL VOID mlinesize (mask_window, obj)
WINDOWP mask_window;
WORD    obj;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, LINESIZE);

  if (window == NULL)
  {
    form_center (linesize, &ret, &ret, &ret, &ret);
    window = crt_dialog (linesize, NULL, LINESIZE, FREETXT (FLINESIZ), WI_MODAL);

    if (window != NULL)
    {
      window->open    = open_size;
      window->close   = close_size;
      window->click   = click_lsize;
      window->key     = key_lsize;
      window->special = (LONG)&size_spec;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    window->edit_obj = find_flags (linesize, ROOT, EDITABLE);
    window->edit_inx = NIL;

    size_spec.obj    = obj;
    size_spec.window = mask_window;

    set_lsize (&size_spec);

    if (! open_dialog (LINESIZE)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mlinesize */

/*****************************************************************************/

LOCAL VOID box (window, grow, mask_window, obj)
WINDOWP window;
BOOLEAN grow;
WINDOWP mask_window;
WORD    obj;

{
  RECT      l, b;
  FATTR     fattr;
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)mask_window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [obj];
  mfield    = &mobject->mfield;

  m_get_rect (mask_window, vdi_handle, mfield->class, mobject, &l, &fattr);

  wind_calc (WC_BORDER, window->kind,       /* Rand berechnen */
             window->work.x, window->work.y, window->work.w, window->work.h,
             &b.x, &b.y, &b.w, &b.h);

  if (grow)
    growbox (&l, &b);
  else
    shrinkbox (&l, &b);
} /* box */

/*****************************************************************************/

LOCAL VOID get_size (size_spec)
SIZE_SPEC *size_spec;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mfield    = (MFIELD *)mobject;

  mfield->x = get_word (objsize, OSX);
  mfield->y = get_word (objsize, OSY);
  mfield->w = get_word (objsize, OSW);
  mfield->h = get_word (objsize, OSH);
} /* get_size */

/*****************************************************************************/

LOCAL VOID set_size (size_spec)
SIZE_SPEC *size_spec;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mfield    = (MFIELD *)mobject;

  set_word (objsize, OSX, mfield->x);
  set_word (objsize, OSY, mfield->y);
  set_word (objsize, OSW, mfield->w);
  set_word (objsize, OSH, mfield->h);
} /* set_size */

/*****************************************************************************/

LOCAL VOID open_size (window)
WINDOWP window;

{
  SIZE_SPEC *size_spec;

  size_spec = (SIZE_SPEC *)window->special;
  box (window, TRUE, size_spec->window, size_spec->obj);
} /* open_size */

/*****************************************************************************/

LOCAL VOID close_size (window)
WINDOWP window;

{
  SIZE_SPEC *size_spec;

  size_spec = (SIZE_SPEC *)window->special;
  box (window, FALSE, size_spec->window, size_spec->obj);
} /* close_size */

/*****************************************************************************/

LOCAL VOID click_size (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  SIZE_SPEC *size_spec;
  MASK_SPEC *mask_spec;

  size_spec = (SIZE_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)size_spec->window->special;

  switch (window->exit_obj)
  {
    case OSOK     : get_size (size_spec);
                    set_redraw (size_spec->window, &size_spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case OSHELP   : hndl_help (HOBJSIZE);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_size */

/*****************************************************************************/

LOCAL BOOLEAN key_size (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (any_ed_empty (objsize) == ! is_state (objsize, OSOK, DISABLED))
  {
    flip_state (objsize, OSOK, DISABLED);
    draw_object (window, OSOK);
  } /* if */

  return (FALSE);
} /* key_size */

/*****************************************************************************/

LOCAL VOID edit_pic (size_spec)
SIZE_SPEC *size_spec;

{
  LONGSTR   szExt;
  BYTE      *pFilename;
  MGRAF     *mgraf;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mgraf     = (MGRAF *)mobject;
  pFilename = &sysmask->mask.buffer [mgraf->filename];

  GetPicFilename (mask_spec, szOlgaFilename, pFilename);
  strcpy (szExt, ".");
  file_split (szOlgaFilename, NULL, NULL, NULL, &szExt [1]);

  OlgaStartExt (szExt, szOlgaFilename);
} /* edit_pic */

/*****************************************************************************/

LOCAL VOID get_psize (size_spec)
SIZE_SPEC *size_spec;

{
  MGRAF     *mgraf;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mgraf     = (MGRAF *)mobject;

  mgraf->x = get_word (picsize, PSX);
  mgraf->y = get_word (picsize, PSY);
  mgraf->w = get_word (picsize, PSW);
  mgraf->h = get_word (picsize, PSH);

  mgraf->flags &= ~ MG_DRAWFRAME;
  if (get_checkbox (picsize, PSFRAME)) mgraf->flags |= MG_DRAWFRAME;
  m_snap_obj (mask_spec, (MOBJECT *)mgraf, mask_spec->grid_x, mask_spec->grid_y);
} /* get_psize */

/*****************************************************************************/

LOCAL VOID set_psize (size_spec)
SIZE_SPEC *size_spec;

{
  WORD      w;
  LONGSTR   s;
  MGRAF     *mgraf;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mgraf     = (MGRAF *)mobject;

  strcpy (s, &sysmask->mask.buffer [mgraf->filename]);
  w     = picsize [PSFNAME].ob_width / gl_wbox;
  s [w] = EOS;
  set_str (picsize, PSFNAME, s);

  set_word (picsize, PSX, mgraf->x);
  set_word (picsize, PSY, mgraf->y);
  set_word (picsize, PSW, mgraf->w);
  set_word (picsize, PSH, mgraf->h);

  set_checkbox (picsize, PSFRAME, mgraf->flags & MG_DRAWFRAME);
} /* set_psize */

/*****************************************************************************/

LOCAL VOID click_psize (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  SIZE_SPEC *size_spec;
  MASK_SPEC *mask_spec;

  size_spec = (SIZE_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)size_spec->window->special;

  switch (window->exit_obj)
  {
    case PSOK     : get_psize (size_spec);
                    set_redraw (size_spec->window, &size_spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case PSEDIT   : edit_pic (size_spec);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case PSHELP   : hndl_help (HPICSIZE);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_psize */

/*****************************************************************************/

LOCAL BOOLEAN key_psize (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (any_ed_empty (picsize) == ! is_state (picsize, PSOK, DISABLED))
  {
    flip_state (picsize, PSOK, DISABLED);
    draw_object (window, PSOK);
  } /* if */

  return (FALSE);
} /* key_psize */

/*****************************************************************************/

LOCAL VOID get_lsize (size_spec)
SIZE_SPEC *size_spec;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mfield    = (MFIELD *)mobject;

  mfield->x = get_word (linesize, LSX1);
  mfield->y = get_word (linesize, LSY1);
  mfield->w = get_word (linesize, LSX2);
  mfield->h = get_word (linesize, LSY2);
} /* get_lsize */

/*****************************************************************************/

LOCAL VOID set_lsize (size_spec)
SIZE_SPEC *size_spec;

{
  MFIELD    *mfield;
  MOBJECT   *mobject;
  SYSMASK   *sysmask;
  MASK_SPEC *mask_spec;

  mask_spec = (MASK_SPEC *)size_spec->window->special;
  sysmask   = &mask_spec->mask;
  mobject   = (MOBJECT *)sysmask->mask.buffer;
  mobject   = &mobject [size_spec->obj];
  mfield    = (MFIELD *)mobject;

  set_word (linesize, LSX1, mfield->x);
  set_word (linesize, LSY1, mfield->y);
  set_word (linesize, LSX2, mfield->w);
  set_word (linesize, LSY2, mfield->h);
} /* set_lsize */

/*****************************************************************************/

LOCAL VOID click_lsize (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  SIZE_SPEC *size_spec;
  MASK_SPEC *mask_spec;

  size_spec = (SIZE_SPEC *)window->special;
  mask_spec = (MASK_SPEC *)size_spec->window->special;

  switch (window->exit_obj)
  {
    case LSOK     : get_lsize (size_spec);
                    set_redraw (size_spec->window, &size_spec->window->scroll);
                    mask_spec->modified = TRUE;
                    break;
    case LSHELP   : hndl_help (HLINESIZ);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_lsize */

/*****************************************************************************/

LOCAL BOOLEAN key_lsize (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  if (any_ed_empty (linesize) == ! is_state (linesize, LSOK, DISABLED))
  {
    flip_state (linesize, LSOK, DISABLED);
    draw_object (window, LSOK);
  } /* if */

  return (FALSE);
} /* key_lsize */

/*****************************************************************************/

LOCAL BOOLEAN any_ed_empty (tree)
OBJECT *tree;

{
  WORD obj;
  BYTE *p;

  obj = 0;

  do
  {
    if (is_flags (tree, obj, EDITABLE) &&
       ((OB_TYPE (tree, obj) == G_FTEXT) || (OB_TYPE (tree, obj) == G_FBOXTEXT)))
    {
      p = get_str (tree, obj);
      if (*p == EOS) return (TRUE);
    } /* if */
  } while (! is_flags (tree, obj++, LASTOB));

  return (FALSE);
} /* any_ed_empty */

