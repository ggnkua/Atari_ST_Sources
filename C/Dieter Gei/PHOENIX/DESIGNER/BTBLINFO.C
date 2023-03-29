/*****************************************************************************
 *
 * Module : BTBLINFO.C
 * Author : Jrgen Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 04.01.95
 *
 *
 * Description: This module implements the table info dialog box.
 *
 * History:
 * 04.01.95: effects TXT_NORMAL added in call to ListBoxSetFont
 * 04.11.93: bk_color WHITE added in call to ListBoxSetFont
 * 13.10.93: Local function box removed, draw_growbox used instead
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "btblinfo.h"

/****** DEFINES **************************************************************/

#define SIZE	50		/* size of one line in buffer */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE *columns = NULL;	/* pointer to column names */

/****** FUNCTIONS ************************************************************/

LOCAL LONG callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID set_tblinfo   _((BASE_SPEC *base_spec, WORD table));
LOCAL VOID open_tblinfo  _((WINDOWP window));
LOCAL VOID close_tblinfo _((WINDOWP window));
LOCAL VOID click_tblinfo _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

LOCAL LONG callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&columns [index * SIZE]);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* callback */

/*****************************************************************************/

LOCAL VOID set_tblinfo (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  WORD       i, w, size;
  STRING     s;
  FULLNAME   dbname;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  BYTE       *p, *mem;

  w = tblinfo [TIDBNAME].ob_width / gl_wbox;

  strcpy (dbname, base_spec->basepath);
  strcat (dbname, base_spec->basename);
  dbname [w] = EOS;
  set_str (tblinfo, TIDBNAME, dbname);

  if (v_tableinfo (base_spec, table, &table_info) != FAILURE)
  {
    set_str (tblinfo, TITABLE, table_info.name);
    set_long (tblinfo, TIRECS, table_info.recs);
    set_word (tblinfo, TICOLS, table_info.cols);
    set_word (tblinfo, TIINXS, table_info.indexes);
    set_long (tblinfo, TISIZE, table_info.size);

    if (columns != NULL) mem_free (columns);
    size    = SIZE;
    columns = mem_alloc ((LONG)table_info.cols * size);

    if (columns != NULL)
    {
      p = FREETXT (FCOLINFO);
      set_meminfo ();

      for (i = 0, mem = columns; i < table_info.cols; i++)
      {
        v_fieldinfo (base_spec, table, i, &field_info);
        str_type (field_info.type, s);
        sprintf (mem, p, field_info.name, s, field_info.addr, field_info.size);
        mem += size;
      } /* for */
    } /* if */

    ListBoxSetCallback (tblinfo, TILIST, callback);
    ListBoxSetFont (tblinfo, TILIST, FONT_SYSTEM, gl_point, TXT_NORMAL, BLACK, WHITE);
    ListBoxSetStyle (tblinfo, TILIST, LBS_VSCROLL | LBS_VREALTIME | LBS_MANDATORY, TRUE);
    ListBoxSetCount (tblinfo, TILIST, table_info.cols, NULL);
    ListBoxSetCurSel (tblinfo, TILIST, FAILURE);
    ListBoxSetTopIndex (tblinfo, TILIST, 0);
  } /* if */
} /* set_tblinfo */

/*****************************************************************************/

GLOBAL VOID btblinfo (base_spec, table)
BASE_SPEC *base_spec;
WORD      table;

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, TBLINFO);

  if (window == NULL)
  {
    form_center (tblinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (tblinfo, NULL, TBLINFO, FREETXT (FTBLINFO), WI_MODAL);

    if (window != NULL)
    {
      window->open  = open_tblinfo;
      window->close = close_tblinfo;
      window->click = click_tblinfo;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0) set_tblinfo (base_spec, table);
    if (! open_dialog (TBLINFO)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* btblinfo */

/*****************************************************************************/

LOCAL VOID open_tblinfo (window)
WINDOWP window;

{
  draw_growbox (window, TRUE);
  ListBoxSetWindowHandle (tblinfo, TILIST, window->handle);
} /* open_tblinfo */

/*****************************************************************************/

LOCAL VOID close_tblinfo (window)
WINDOWP window;

{
  draw_growbox (window, FALSE);
  ListBoxSetWindowHandle (tblinfo, TILIST, FAILURE);
  mem_free (columns);
  columns = NULL;
  set_meminfo ();
} /* close_tblinfo */

/*****************************************************************************/

LOCAL VOID click_tblinfo (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case TILIST : ListBoxClick (window->object, window->exit_obj, mk);
                  break;
    case TIOK   : break;
    case TIHELP : hndl_help (HTBLINFO);
                  undo_state (window->object, window->exit_obj, SELECTED);
                  draw_object (window, window->exit_obj);
                  break;
  } /* switch */
} /* click_tblinfo */

/*****************************************************************************/

