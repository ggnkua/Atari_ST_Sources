/*****************************************************************************
 *
 * Module : ORDER.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 02.11.93
 *
 *
 * Description: This module implements the order dialog box.
 *
 * History:
 * 02.11.93: No longer using large stack variables in callback
 * 01.11.93: Tabstops used in listbox
 * 16.10.93: Callback routine improved
 * 17.09.93: New 3d listbox added
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
#include "sql.h"

#include "export.h"
#include "order.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL BOOLEAN exit_state;               /* exit state of dialog box */
LOCAL DB      *order_db;                /* order database */
LOCAL WORD    order_table;              /* order table */
LOCAL WORD    order_num;                /* number of ordered columns */
LOCAL WORD    order_cols [MAX_SORT];    /* ordered columns */
LOCAL BYTE    *columns;                 /* pointer to column names */
LOCAL BYTE    *indexes;                 /* pointer to index names */

LOCAL WORD    tabs [] = {4 * 8, 5 * 8, 22 * 8};
LOCAL WORD    tabstyles [] = {LBT_RIGHT, LBT_LEFT, LBT_LEFT};

/****** FUNCTIONS ************************************************************/

LOCAL LONG    cols_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL LONG    inxs_callback _((WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG item, VOID *p));
LOCAL VOID    set_columns   _((VOID));
LOCAL VOID    set_indexes   _((VOID));
LOCAL BOOLEAN col_in_order  _((WORD col));

LOCAL VOID    click_order   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_order ()

{
  return (TRUE);
} /* init_order */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_order ()

{
  return (TRUE);
} /* term_order */

/*****************************************************************************/

GLOBAL BOOLEAN hndl_order (db, table, numsort, colsort)
DB   *db;
WORD table, *numsort, *colsort;

{
  WINDOWP    window;
  WORD       ret;
  BASE_INFO  base_info;
  TABLE_INFO table_info;
  FULLNAME   dbname;
  WORD       w;

  exit_state  = FALSE;
  order_db    = db;
  order_table = table;
  order_num   = *numsort;
  mem_move (order_cols, colsort, sizeof (order_cols));

  window = search_window (CLASS_DIALOG, SRCH_ANY, ORDER);

  if (window == NULL)
  {
    form_center (order, &ret, &ret, &ret, &ret);
    window = crt_dialog (order, NULL, ORDER, FREETXT (FORDER), WI_MODAL);

    if (window != NULL) window->click = click_order;
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      db_baseinfo (db->base, &base_info);
      w = order [ORDBNAME].ob_width / gl_wbox;

      strcpy (dbname, base_info.basepath);
      strcat (dbname, base_info.basename);
      dbname [w] = EOS;
      set_str (order, ORDBNAME, dbname);

      db_tableinfo (db->base, table, &table_info);
      set_str (order, ORTABLE, table_info.name);

      columns = mem_alloc ((LONG)(table_info.cols - 1) * (sizeof (FIELDNAME)));
      indexes = mem_alloc ((LONG)MAX_SORT * (sizeof (FIELDNAME)));

      if ((columns == NULL) || (indexes == NULL))
      {
        mem_free (columns);
        mem_free (indexes);
        columns = NULL;
        indexes = NULL;
        hndl_alert (ERR_NOMEMORY);
        delete_window (window);
        return (FALSE);
      } /* if */

      ListBoxSetCallback (order, ORCOLS, cols_callback);
      ListBoxSetStyle (order, ORCOLS, LBS_VSCROLL | LBS_VREALTIME | LBS_SELECTABLE | LBS_MANDATORY, TRUE);
      ListBoxSetCount (order, ORCOLS, 0, NULL);
      ListBoxSetCurSel (order, ORCOLS, FAILURE);
      ListBoxSetTopIndex (order, ORCOLS, 0);
      ListBoxSetLeftOffset (order, ORCOLS, gl_wbox / 2);

      ListBoxSetCallback (order, ORINXS, inxs_callback);
      ListBoxSetStyle (order, ORINXS, LBS_VSCROLL | LBS_VREALTIME | LBS_MANDATORY, TRUE);
      ListBoxSetTabstops (order, ORINXS, sizeof (tabs) / sizeof (WORD), tabs, tabstyles);
      ListBoxSetCount (order, ORINXS, order_num, NULL);
      ListBoxSetCurSel (order, ORINXS, FAILURE);
      ListBoxSetTopIndex (order, ORINXS, 0);
      ListBoxSetLeftOffset (order, ORINXS, 0);

      set_meminfo ();
      set_columns ();
      set_indexes ();

      ListBoxSetCurSel (order, ORCOLS, 0);

      if (((order_num == MAX_SORT) || (ListBoxGetCount (order, ORCOLS) == 0)) == ! is_state (order, ORCOPY, DISABLED))
        flip_state (order, ORCOPY, DISABLED);

      if ((order_num == 0) == ! is_state (order, ORDELETE, DISABLED))
        flip_state (order, ORDELETE, DISABLED);

      if ((order_num == 0) == ! is_state (order, ORNEW, DISABLED))
        flip_state (order, ORNEW, DISABLED);
    } /* if */

    if (! open_dialog (ORDER)) hndl_alert (ERR_NOOPEN);

    mem_free (columns);
    mem_free (indexes);
    set_meminfo ();
    columns = NULL;
    indexes = NULL;
  } /* if */

  if (exit_state)
  {
    *numsort = order_num;
    mem_move (colsort, order_cols, sizeof (order_cols));
  } /* if */

  return (exit_state);
} /* hndl_order */

/*****************************************************************************/

LOCAL LONG cols_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  WINDOWP          window;
  BOOLEAN          desc;
  WORD             col;
  LOCAL FIELD_INFO field_info;

  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&columns [index * sizeof (FIELDNAME)]);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : window = find_window (wh);
                          ListBoxGetText (tree, obj, index, field_info.name);
                          col = db_fieldinfo (order_db->base, order_table, FAILURE, &field_info);

                          do_state (window->object, ORCOPY, SELECTED);
                          draw_object (window, ORCOPY);
                          desc = get_rbutton (window->object, ORDESC) == ORDESC;
                          order_cols [order_num++] = col | (desc ? DESC_ORDER : 0);

                          ListBoxSetCount (tree, ORINXS, order_num, NULL);
                          ListBoxSetTopIndex (tree, ORINXS, order_num);

                          set_columns ();
                          set_indexes ();

                          ListBoxRedraw (tree, obj);
                          ListBoxRedraw (tree, ORINXS);

                          undo_state (window->object, ORCOPY, SELECTED);
                          draw_object (window, ORCOPY);
                          break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* cols_callback */

/*****************************************************************************/

LOCAL LONG inxs_callback (WORD wh, OBJECT *tree, WORD obj, WORD msg, LONG index, VOID *p)
{
  switch (msg)
  {
    case LBN_GETITEM    : return ((LONG)&indexes [index * sizeof (FIELDNAME)]);
    case LBN_DRAWITEM   : break;
    case LBN_SELCHANGE  : break;
    case LBN_DBLCLK     : break;
    case LBN_KEYPRESSED : break;
  } /* switch */

  return (0L);
} /* inxs_callback */

/*****************************************************************************/

LOCAL VOID set_columns ()

{
  WORD       i, num_items;
  BYTE       *mem;
  TABLE_INFO table_info;
  FIELD_INFO field_info;

  db_tableinfo (order_db->base, order_table, &table_info);

  num_items = 0;

  for (i = 1, mem = columns; i < table_info.cols; i++)
    if (! col_in_order (i))
      if (db_fieldinfo (order_db->base, order_table, i, &field_info) != FAILURE)
        if (db_acc_column (order_db->base, order_table, i) & GRANT_SELECT)
          if (printable (field_info.type))
          {
            num_items++;
            strcpy (mem, field_info.name);
            mem += sizeof (FIELDNAME);
          } /* if, if, if, if, for */

  ListBoxSetCount (order, ORCOLS, num_items, NULL);
  if (ListBoxGetCurSel (order, ORCOLS) >= num_items) ListBoxSetCurSel (order, ORCOLS, num_items - 1);
  if (ListBoxGetCurSel (order, ORCOLS) == FAILURE) ListBoxSetCurSel (order, ORCOLS, num_items - 1);
} /* set_columns */

/*****************************************************************************/

LOCAL VOID set_indexes ()

{
  WORD       i, col;
  BYTE       *mem;
  FIELD_INFO field_info;

  for (i = 0, mem = indexes; i < order_num; i++)
  {
    col = order_cols [i];
    db_fieldinfo (order_db->base, order_table, col & ~ DESC_ORDER, &field_info);
    sprintf (mem, "%d.\t%s\t%c", i + 1, field_info.name, (col & DESC_ORDER) ? '-' : '+');
    mem += sizeof (FIELDNAME);
  } /* for */
} /* set_indexes */

/*****************************************************************************/

LOCAL BOOLEAN col_in_order (col)
WORD col;

{
  REG WORD i;

  for (i = 0; i < order_num; i++)
    if ((order_cols [i] & ~ DESC_ORDER) == col)
      return (TRUE);

  return (FALSE);
} /* col_in_order */

/*****************************************************************************/

LOCAL VOID click_order (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BOOLEAN put_field;

  exit_state = window->exit_obj == OROK;
  put_field  = FALSE;

  ListBoxSetWindowHandle (order, ORCOLS, window->handle);	/* window handle is vaild now */
  ListBoxSetWindowHandle (order, ORINXS, window->handle);

  switch (window->exit_obj)
  {
    case ORCOLS   :
    case ORINXS   : ListBoxClick (window->object, window->exit_obj, mk);
                    break;
    case ORCOPY   : put_field = TRUE;
                    break;
    case ORDELETE : order_num--;
                    ListBoxSetCount (order, ORINXS, order_num, NULL);
                    ListBoxSetTopIndex (order, ORINXS, order_num);
                    set_columns ();
                    set_indexes ();
                    ListBoxRedraw (order, ORCOLS);
                    ListBoxRedraw (order, ORINXS);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
     case ORASC   : 
     case ORDESC  : put_field = (mk->breturn == 2) && ! is_state (window->object, ORCOPY, DISABLED);
                    break;
     case OROK    : break;
     case ORNEW   : order_num = 0;
                    ListBoxSetCount (order, ORINXS, 0, NULL);
                    ListBoxSetTopIndex (order, ORINXS, 0);
                    set_columns ();
                    set_indexes ();
                    ListBoxSetCurSel (order, ORCOLS, 0);
                    ListBoxSetTopIndex (order, ORCOLS, 0);
                    ListBoxRedraw (order, ORCOLS);
                    ListBoxRedraw (order, ORINXS);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
    case ORHELP   : hndl_help (HORDER);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */

  if (order_num < MAX_SORT)
    if (put_field)
      cols_callback (window->handle, order, ORCOLS, LBN_DBLCLK, ListBoxGetCurSel (order, ORCOLS), NULL);

  if (((order_num == MAX_SORT) || (ListBoxGetCount (order, ORCOLS) == 0)) == ! is_state (order, ORCOPY, DISABLED))
  {
    flip_state (order, ORCOPY, DISABLED);
    draw_object (window, ORCOPY);
  } /* if */

  if ((order_num == 0) == ! is_state (order, ORDELETE, DISABLED))
  {
    flip_state (order, ORDELETE, DISABLED);
    draw_object (window, ORDELETE);
  } /* if */

  if ((order_num == 0) == ! is_state (order, ORNEW, DISABLED))
  {
    flip_state (order, ORNEW, DISABLED);
    draw_object (window, ORNEW);
  } /* if */
} /* click_order */

/*****************************************************************************/

