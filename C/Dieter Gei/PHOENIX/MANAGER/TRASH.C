/*****************************************************************************
 *
 * Module : TRASH.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 06.08.95
 *
 *
 * Description: This module implements the trash list window.
 *
 * History:
 * 06.08.95: Handling of class CLASS_ACCDEF in function wi_drag added
 * 04.11.93: Using fontdesc
 * 11.09.93: Using of variable max_columns removed
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "accdef.h"
#include "desktop.h"
#include "dialog.h"
#include "disk.h"
#include "list.h"

#include "export.h"
#include "trash.h"

/****** DEFINES **************************************************************/

#define KIND   (NAME|CLOSER|FULLER|MOVER|INFO|SIZER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE)
#define FLAGS  (WI_RESIDENT|WI_CURSKEYS)
#define XFAC   gl_wbox                  /* X-Faktor */
#define YFAC   gl_hbox                  /* Y-Faktor */
#define XUNITS 1                        /* X-Einheiten fr Scrolling */
#define YUNITS 1                        /* Y-Einheiten fr Scrolling */
#define INITX  ( 2 * gl_wbox)           /* X-Anfangsposition */
#define INITY  ( 6 * gl_hbox)           /* Y-Anfangsposition */
#define INITW  (36 * gl_wbox)           /* Anfangsbreite in Pixel */
#define INITH  ( 8 * gl_hbox)           /* Anfangsh”he in Pixel */
#define MILLI  0                        /* Millisekunden fr Zeitablauf */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    update_menu _((WINDOWP window));
LOCAL VOID    handle_menu _((WINDOWP window, WORD title, WORD item));
LOCAL VOID    box         _((WINDOWP window, BOOLEAN grow));
LOCAL BOOLEAN wi_test     _((WINDOWP window, WORD action));
LOCAL VOID    wi_open     _((WINDOWP window));
LOCAL VOID    wi_close    _((WINDOWP window));
LOCAL VOID    wi_delete   _((WINDOWP window));
LOCAL VOID    wi_draw     _((WINDOWP window));
LOCAL VOID    wi_arrow    _((WINDOWP window, WORD dir, LONG oldpos, LONG newpos));
LOCAL VOID    wi_snap     _((WINDOWP window, RECT *new, WORD mode));
LOCAL VOID    wi_objop    _((WINDOWP window, SET objs, WORD action));
LOCAL WORD    wi_drag     _((WINDOWP src_window, WORD src_obj, WINDOWP dest_window, WORD dest_obj));
LOCAL VOID    wi_click    _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_unclick  _((WINDOWP window));
LOCAL BOOLEAN wi_key      _((WINDOWP window, MKINFO *mk));
LOCAL VOID    wi_timer    _((WINDOWP window));
LOCAL VOID    wi_top      _((WINDOWP window));
LOCAL VOID    wi_untop    _((WINDOWP window));
LOCAL VOID    wi_edit     _((WINDOWP window, WORD action));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_trash ()

{
  return (TRUE);
} /* init_trash */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_trash ()

{
  return (TRUE);
} /* term_trash */

/*****************************************************************************/
/* Kreieren eines Fensters                                                   */
/*****************************************************************************/

GLOBAL WINDOWP crt_trash (obj, menu, icon)
OBJECT *obj, *menu;
WORD   icon;

{
  WINDOWP window;
  WORD    cols, *columns, *colwidth;

  if (actdb == NULL) return (NULL);

  cols    = 1;
  columns = (WORD *)mem_alloc (2L * cols * sizeof (WORD));  /* mem_free in module list */

  if (columns == NULL)
  {
    hndl_alert (ERR_NOMEMORY);
    return (NULL);
  } /* if */

  set_meminfo ();

  colwidth     = columns + cols;
  columns [0]  = 2;
  colwidth [0] = - MAX_FIELDNAME - 1;   /* table number -> table name */
  window       = crt_list (NULL, NULL, icon, actdb, SYS_DELETED, 0, DESCENDING, cols, columns, colwidth, &fontdesc, NULL, NULL);

  if (window != NULL)
  {
    window->class    = CLASS_TRASH;     /* want to have a list window with my class */
    window->flags    = FLAGS;
    window->drag     = wi_drag;
    window->showinfo = info_trash;
    window->showhelp = help_trash;

    strcpy (window->name, FREETXT (FTRASHNA));
  } /* if */

  return (window);                      /* Fenster zurckgeben */
} /* crt_trash */

/*****************************************************************************/
/* ™ffnen des Objekts                                                        */
/*****************************************************************************/

GLOBAL BOOLEAN open_trash (icon)
WORD icon;

{
  BOOLEAN ok;
  WINDOWP window;

  if ((window = search_window (CLASS_TRASH, SRCH_OPENED, icon)) != NULL)
  {
    ok = TRUE;
    top_window (window);
  } /* if */
  else
  {
    if ((window = search_window (CLASS_TRASH, SRCH_CLOSED, icon)) == NULL)
      window = crt_trash (NULL, NULL, icon);

    ok = window != NULL;

    if (ok) ok = open_window (window);
  } /* else */

  return (ok);
} /* open_trash */

/*****************************************************************************/
/* Info des Objekts                                                          */
/*****************************************************************************/

GLOBAL BOOLEAN info_trash (window, icon)
WINDOWP window;
WORD    icon;

{
  if (icon != NIL)
    window = search_window (CLASS_TRASH, SRCH_ANY, icon);

  if (window != NULL) info_list (window, NIL);

  return (window != NULL);
} /* info_trash */

/*****************************************************************************/
/* Hilfe des Objekts                                                         */
/*****************************************************************************/

GLOBAL BOOLEAN help_trash (window, icon)
WINDOWP window;
WORD    icon;

{
  return (hndl_help (HTRASH));
} /* help_trash */

/*****************************************************************************/

GLOBAL BOOLEAN close_trash ()

{
  WINDOWP window;

  window = search_window (CLASS_TRASH, SRCH_ANY, ITRASH);

  if (window != NULL) delete_window (window);   /* trash no longer valid */

  return (TRUE);
} /* close_trash */

/*****************************************************************************/
/* Ziehen in das Fenster                                                     */
/*****************************************************************************/

LOCAL WORD wi_drag (src_window, src_obj, dest_window, dest_obj)
WINDOWP src_window;
WORD    src_obj;
WINDOWP dest_window;
WORD    dest_obj;

{
  WORD action;

  if (src_window->handle == dest_window->handle) return (DRAG_SWIND); /* Im gleichen Fenster */
  if (src_window->class == dest_window->class) return (DRAG_SCLASS);  /* Gleiche Fensterart */

  action = DRAG_NOACTN;
 
  if (src_window->class == class_desk)          /* Objekte von Desktop */
  {
    action = DRAG_OK;

    switch (src_obj)
    {
      case ITRASH   : action = DRAG_NOACTN;       break;
      case IDISK    : icons_disk (IDISK, ITRASH); break;
      case IPRINTER : action = DRAG_NOACTN;       break;
      case ICLIPBRD : action = DRAG_NOACTN;       break;
    } /* switch */
  } /* if */

  if (src_window->class == CLASS_LIST) action = DRAG_OK;
  if (src_window->class == CLASS_ACCDEF) action = DRAG_OK;

  return (action);
} /* wi_drag */

/*****************************************************************************/

