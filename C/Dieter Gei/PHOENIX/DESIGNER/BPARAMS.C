/*****************************************************************************
 *
 * Module : BPARAMS.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 08.09.93
 *
 *
 * Description: This module implements the base params dialog box.
 *
 * History:
 * 08.09.93: set_ptext -> set_str
 * 31.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "root.h"
#include "resource.h"
#include "dialog.h"

#include "export.h"
#include "bparams.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    get_params    _((BASE_SPEC *base_spec));
LOCAL VOID    set_params    _((BASE_SPEC *base_spec));
LOCAL VOID    click_params  _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_params    _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID mdbparams (base_spec)
BASE_SPEC *base_spec;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, DBPARAMS);

  if (window == NULL)
  {
    form_center (dbparams, &ret, &ret, &ret, &ret);
    window = crt_dialog (dbparams, NULL, DBPARAMS, FREETXT (FDBPARAM), WI_MODAL);

    if (window != NULL)
    {
      window->click   = click_params;
      window->key     = key_params;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (dbparams, ROOT, EDITABLE);
      window->edit_inx = NIL;
      window->special  = (LONG)base_spec;

      set_params (base_spec);
    } /* if */

    if (! open_dialog (DBPARAMS)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mdbparams */

/*****************************************************************************/

LOCAL VOID get_params (base_spec)
BASE_SPEC *base_spec;

{
  base_spec->datasize = get_long (dbparams, BPDSIZE);
  base_spec->treesize = get_long (dbparams, BPTSIZE);

  if (base_spec->new)
  {
    if (get_checkbox (dbparams, BPDENCOD))
      base_spec->cflags |= DATA_ENCODE;
    else
      base_spec->cflags &= ~ DATA_ENCODE;

    if (get_checkbox (dbparams, BPTENCOD))
      base_spec->cflags |= TREE_ENCODE;
    else
      base_spec->cflags &= ~ TREE_ENCODE;
  } /* if */
} /* get_params */

/*****************************************************************************/

LOCAL VOID set_params (base_spec)
BASE_SPEC *base_spec;

{
  FULLNAME dbname;
  WORD     w;
  STRING   s;

  w = dbparams [BPBASE].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  strcpy (get_str (dbparams, BPBASE), dbname);

  sprintf (s, "%ld", base_spec->datasize);
  set_str (dbparams, BPDSIZE, s);
  set_checkbox (dbparams, BPDENCOD, (base_spec->cflags & DATA_ENCODE) != 0);

  sprintf (s, "%ld", base_spec->treesize);
  set_str (dbparams, BPTSIZE, s);
  set_checkbox (dbparams, BPTENCOD, (base_spec->cflags & TREE_ENCODE) != 0);

  if (base_spec->new)
  {
    undo_state (dbparams, BPDENCOD, DISABLED);
    undo_state (dbparams, BPTENCOD, DISABLED);
  } /* if */
  else
  {
    do_state (dbparams, BPDENCOD, DISABLED);
    do_state (dbparams, BPTENCOD, DISABLED);
  } /* else */
} /* set_params */

/*****************************************************************************/

LOCAL VOID click_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  LONG      datasize, treesize;
  UWORD     flags;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  switch (window->exit_obj)
  {
    case BPOK   : datasize = base_spec->datasize;
                  treesize = base_spec->treesize;
                  flags    = base_spec->cflags;

                  get_params (base_spec);

                  if ((datasize != base_spec->datasize) ||
                      (treesize != base_spec->treesize) ||
                      (flags    != base_spec->cflags))
                    base_spec->modified = TRUE;
                  break;
    case BPHELP : hndl_help (HDBPARAM);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_params */

/*****************************************************************************/

LOCAL BOOLEAN key_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE      *p1, *p2;
  LONG      datasize, treesize;
  LONG      datafile, treefile;
  BOOLEAN   too_small;
  BASE_INFO base_info;
  BASE_SPEC *base_spec;

  base_spec = (BASE_SPEC *)window->special;

  switch (window->edit_obj)
  {
    case BPDSIZE :
    case BPTSIZE : p1 = get_str (dbparams, BPDSIZE);
                   p2 = get_str (dbparams, BPTSIZE);

                   too_small = FALSE;
                   datasize  = get_long (dbparams, BPDSIZE);
                   treesize  = get_long (dbparams, BPTSIZE);

                   if (! base_spec->new)
                   {
                     db_baseinfo (base_spec->base, &base_info);

                     datafile  = base_info.data_info.file_size / 1024;
                     treefile  = base_info.tree_info.num_pages / 2;
                     too_small = (datasize < datafile) || (treesize < treefile);
                   } /* if */

                   if (((*p1 == EOS) || (*p2 == EOS) ||
                        (datasize == 0) || (treesize == 0) || too_small) == ! is_state (dbparams, BPOK, DISABLED))
                   {
                     flip_state (dbparams, BPOK, DISABLED);
                     draw_object (window, BPOK);
                   } /* if */
                   break;
  } /* switch */

  return (FALSE);
} /* key_params */

