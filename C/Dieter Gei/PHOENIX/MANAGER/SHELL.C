/*****************************************************************************
 *
 * Module : SHELL.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 26.12.02
 *
 *
 * Description: This module implements the program shell.
 *
 * History:
 * 26.12.02: New parameter (-M) for running Designer
 * 20.06.96: Paramters are enclosed in ' for running Designer
 * 16.11.93: Using new file selector
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "desktop.h"
#include "dialog.h"
#include "mfile.h"
#include "mlsconf.h"
#include "resource.h"

#include "export.h"
#include "shell.h"

/****** DEFINES **************************************************************/

#define DESIGNER "DESIGNER"

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

LOCAL WORD exit_button;         /* exit button from dialog */

/****** FUNCTIONS ************************************************************/

LOCAL VOID    run_program  _((BYTE *progname));
LOCAL BOOLEAN open_params  _((BYTE *filename));
LOCAL VOID    click_params _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_shell ()

{
  return (TRUE);
} /* init_shell */

/*****************************************************************************/

GLOBAL BOOLEAN term_shell ()

{
  return (TRUE);
} /* term_shell */

/*****************************************************************************/

GLOBAL VOID call_designer ()

{
  FULLNAME designer;
  EXT      ext;

  file_split (app_name, NULL, NULL, NULL, ext);
  sprintf (designer, "%s%s%c%s", app_path, DESIGNER, SUFFSEP, ext);	/* DESIGNER is on same path as manager */

  if (actdb == NULL)
    tail [0] = EOS;
  else
    sprintf (tail, "'%s%s%c%s'", actdb->base->basepath, actdb->base->basename, SUFFSEP, DATA_SUFF);

  run_program (designer);
} /* call_designer */

/*****************************************************************************/

GLOBAL VOID call_program ()

{
  FULLNAME progname;

  tail [0]     = EOS;
  progname [0] = EOS;

#if GEMDOS
  if (get_open_filename (FSELPROG, NULL, 0L, FFILTER_PRG_ACC_TOS_TTP, NULL, NULL, FPRGSUFF, progname, NULL))
     run_program (progname);
#endif

#if MSDOS
  if (get_open_filename (FSELPROG, NULL, 0L, FFILTER_APP_EXE, NULL, NULL, FAPPSUFF, progname, NULL))
     run_program (progname);
#endif

#if FLEXOS
  if (get_open_filename (FSELPROG, NULL, 0L, FFILTER_286_EXE, NULL, NULL, F286SUFF, progname, NULL))
     run_program (progname);
#endif
} /* call_program */

/*****************************************************************************/

LOCAL VOID run_program (progname)
BYTE *progname;

{
  WORD     drive, olddrive;
  FULLNAME path, oldpath, filename, cmdtail, s;
  FILENAME name;
  EXT      ext;
  BOOLEAN  call_gem, call_db;
  RECT     r;

  if (! file_exist (progname))
  {
    file_error (ERR_FILEOPEN, progname);
    return;
  } /* if */

  file_split (progname, &drive, path, name, ext);
  file_split (progname, NULL, NULL, filename, NULL);

  if (! open_params (filename)) return;

  if (exit_button == PARCANCE) return;

  get_ptext (params, PARPARAM, tail);

  call_gem = (strcmpi  (ext, "PRG")   == 0) ||
             (strncmpi (ext, "AC", 2) == 0) ||
             (strcmpi  (ext, "APP")   == 0) ||
             (strcmpi  (ext, "286")   == 0);

  call_db = strcmpi (name, DESIGNER) == 0;

	if ( call_db )
	{
		strcpy ( s, "-M ");
		strcat ( s, tail );
		strcpy ( tail, s );
	} /* if */

  strcpy (cmdtail + 1, tail);

#ifdef CONCATPROGNAME
  if (call_gem)
  {
    BYTE sep [2];

    sep [0] = PROGSEP;
    sep [1] = EOS;

    strcat (cmdtail + 1, sep);
    strcat (cmdtail + 1, app_path);
    strcat (cmdtail + 1, app_name);
  } /* if */
#endif

  cmdtail [0] = (BYTE)strlen (cmdtail + 1);

#if GEMDOS | MSDOS
  if (call_gem)
  {
    if (! check_close ()) return;
    close_all (FALSE, TRUE);
  } /* if */

  menu_bar (menu, FALSE);
#endif

  strcpy (s, app_path);
  strcat (s, FREETXT (FDESKNAM));
  str_rmchar (s, SP);
  strcat (s, FREETXT (FTMPSUFF) + 1);
  msave_config (s, FALSE, TRUE);

  if (call_db)
    while (num_opendb > 0) mclosedb ();

#if GEMDOS | MSDOS
  if (! call_gem)
  {
    hide_mouse ();

#if GEMDOS
    v_enter_cur (vdi_handle);
#endif
  } /* if */
#endif

  olddrive = get_drive ();
  get_path (oldpath);

  set_drive (drive);
  set_path (path);

  wind_update (END_UPDATE);
  busy_mouse ();

#if FLEXOS | UNIX
  if (! shel_write (TRUE, call_gem, 0, progname, cmdtail))
#endif

#if GEMDOS
  if (Pexec (0, progname, (VOID *)cmdtail, NULL) < 0)
#endif
    if (check_close ())
    {
      done = TRUE;
      strcpy (called_by, progname);     /* call via shel_write later */
    } /* if, if */

  arrow_mouse ();
  wind_update (BEG_UPDATE);

  if (! done)                           /* set path before exit program */
  {
    set_drive (olddrive);
    set_path (oldpath);
  } /* if */

#if GEMDOS
  if (! call_gem)
  {
    v_exit_cur (vdi_handle);
    form_dial (FMD_FINISH, 0, 0, 0, 0, desk.x, desk.y, desk.w, desk.h);
  } /* if */
#endif

#if GEMDOS | MSDOS
  if (call_gem) open_desktop (NIL);
  r.x = 0;
  r.y = 0;
  r.w = desk.w;
  r.h = gl_hattr;
  hide_mouse ();
  set_clip (FALSE, NULL);
  clr_area (&r);                        /* clear menu bar */
  show_mouse ();

  if (! call_gem) show_mouse ();
  menu_bar (menu, TRUE);
#endif

  if (! done)                           /* Pexec was ok */
  {
    if (call_db) mload_config (s, FALSE, TRUE);
    file_remove (s);
  } /* if */
} /* run_program */

/*****************************************************************************/

LOCAL BOOLEAN open_params (filename)
BYTE *filename;

{
  BOOLEAN ok;
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, PARAMS);

  if (window == NULL)
  {
    form_center (params, &ret, &ret, &ret, &ret);
    window = crt_dialog (params, NULL, PARAMS, FREETXT (FPROGPAR), WI_MODAL);

    if (window != NULL) window->click = click_params;
  } /* if */

  ok = window != NULL;

  if (ok)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (params, ROOT, EDITABLE);
      window->edit_inx = NIL;
      ret              = params [PARPROG].ob_width / gl_wbox;
      filename [ret]   = EOS;

      set_str (params, PARPROG, filename);
      set_ptext (params, PARPARAM, tail);
      exit_button = PARCANCE;
    } /* if */

    ok = open_dialog (PARAMS);
    if (! ok) hndl_alert (ERR_NOOPEN);
  } /* if */

  return (ok);
} /* open_params */

/*****************************************************************************/

LOCAL VOID click_params (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  switch (window->exit_obj)
  {
    case PAROK    : 
    case PARCANCE : exit_button = window->exit_obj;
                    break;
    case PARHELP  : hndl_help (HPROGPAR);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_params */

