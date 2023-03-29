/*****************************************************************************
 *
 * Module : MTBLINFO.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 01.11.93
 *
 *
 * Description: This module implements the table info dialog box.
 *
 * History:
 * 01.11.93: Tabstops used in listbox
 * 14.09.93: Local function box removed, draw_growbox used instead
 * 12.09.93: New 3d listbox added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "controls.h"
#include "desktop.h"
#include "dialog.h"
#include "resource.h"

#include "export.h"
#include "mtblinfo.h"

/****** DEFINES **************************************************************/

#define SIZE	50		/* size of one line in buffer */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BYTE *columns = NULL;	/* pointer to column names */

LOCAL WORD tabs [] = {1 * 8, 26 * 8, 40 * 8, 49 * 8};
LOCAL WORD tabstyles [] = {LBT_LEFT, LBT_LEFT, LBT_RIGHT, LBT_RIGHT};

/****** FUNCTIONS ************************************************************/

LOCAL LONG callback      _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID open_tblinfo  _((WINDOWP window));
LOCAL VOID close_tblinfo _((WINDOWP window));
LOCAL VOID click_tblinfo _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL VOID set_tblinfo ()

{
  BASE_INFO  base_info;
  TABLE_INFO table_info;
  FIELD_INFO field_info;
  FULLNAME  dbname;
  STRING    s;
  BYTE      *p, *mem;
  WORD      i, cols, w, size;
  CALCCODE  *c;

  if (db_baseinfo (actdb->base, &base_info))
  {
    w = tblinfo [TIDBNAME].ob_width / gl_wbox;

    strcpy (dbname, base_info.basepath);
    strcat (dbname, base_info.basename);
    dbname [w] = EOS;
    set_str (tblinfo, TIDBNAME, dbname);

    if (db_tableinfo (actdb->base, actdb->table, &table_info) != FAILURE)
    {
      p = actdb->t_info [actdb->t_inx].calcname;
      c = &actdb->t_info [actdb->t_inx].calccode;

      for (i = 1, cols = 0; i < table_info.cols; i++)
        if (db_acc_column (actdb->base, actdb->table, i) & GRANT_SELECT) cols++;

      set_str (tblinfo, TITABLE, table_info.name);
      set_long (tblinfo, TIRECS, table_info.recs);
      set_word (tblinfo, TICOLS, cols);
      set_word (tblinfo, TIINXS, actdb->t_info [actdb->t_inx].indexes);
      set_long (tblinfo, TISIZE, table_info.size);
      set_str (tblinfo, TICALC, ((*p == EOS) && (c->size != 0)) ? FREETXT (FNOTITLE) : p);

      if (columns != NULL) mem_free (columns);
      size    = SIZE;
      columns = mem_alloc ((LONG)cols * size);

      if (columns != NULL)
      {
        p = FREETXT (FCOLINFO);
        set_meminfo ();

        for (i = 1, mem = columns; i < table_info.cols; i++)
          if (db_acc_column (actdb->base, actdb->table, i))
          {
            db_fieldinfo (actdb->base, actdb->table, i, &field_info);
            str_type (field_info.type, s);
            sprintf (mem, p, field_info.name, s, field_info.addr, field_info.size);
            mem += size;
          } /* if, for */
      } /* if */

      ListBoxSetCallback (tblinfo, TILIST, callback);
      ListBoxSetStyle (tblinfo, TILIST, LBS_VSCROLL | LBS_VREALTIME | LBS_MANDATORY, TRUE);
      ListBoxSetTabstops (tblinfo, TILIST, sizeof (tabs) / sizeof (WORD), tabs, tabstyles);
      ListBoxSetCount (tblinfo, TILIST, cols, NULL);
      ListBoxSetCurSel (tblinfo, TILIST, FAILURE);
      ListBoxSetTopIndex (tblinfo, TILIST, 0);
      ListBoxSetLeftOffset (tblinfo, TILIST, 0);
    } /* if */
  } /* if */
} /* set_tblinfo */

/*****************************************************************************/

GLOBAL VOID check_tblinfo ()

{
  WINDOWP window;

  window = search_window (CLASS_DIALOG, SRCH_OPENED, TBLINFO);

  if (window != NULL)
    if (actdb != NULL)
    {
      set_tblinfo ();
      set_redraw (window, &window->scroll);
    } /* if */
    else
      close_window (window);
} /* check_tblinfo */

/*****************************************************************************/

GLOBAL VOID mtblinfo ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, TBLINFO);

  if (window == NULL)
  {
    form_center (tblinfo, &ret, &ret, &ret, &ret);
    window = crt_dialog (tblinfo, NULL, TBLINFO, FREETXT (FTBLINFO), wi_modeless);

    if (window != NULL)
    {
      window->open  = open_tblinfo;
      window->close = close_tblinfo;
      window->click = click_tblinfo;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0) set_tblinfo ();
    if (! open_dialog (TBLINFO)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mtblinfo */

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

