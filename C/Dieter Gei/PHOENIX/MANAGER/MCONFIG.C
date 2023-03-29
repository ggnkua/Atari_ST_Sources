/*****************************************************************************
 *
 * Module : MCONFIG.C
 * Author : Dieter Geiž
 *
 * Creation date    : 01.07.89
 * Last modification: 21.12.02
 *
 *
 * Description: This module implements the config dialog box.
 *
 * History:
 * 08.09.04: Handling of variable TabSize added
 * 21.12.02: Statt minimize wird jetzt minimize_process benutzt
 * 16.06.96: Call to str_upper removed
 * 31.01.95; Handling of variable warn_table added
 * 25.03.94: Changing of show_info, show_top, and show_left will change list windows immediately
 * 12.03.94: Handling of variables show_info added
 * 10.03.94: List windows are redraw if show_pattern changes
 * 05.03.94: Handling of variables show_top, show_left, and show_pattern added
 * 29.01.94: GetPathNameDialog receives correct help string
 * 05.12.93: GetPathNameDialog used to get path name
 * 03.11.93: LoadFonts and UnloadFonts from CommDlg used
 * 07.10.93: Cache configuration added
 * 04.10.93: Desktop configuration move to userintr.c
 * 11.09.93: Managing of max_records removed
 * 27.08.93: Variable hide_iconbar added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"

#include "manager.h"

#include "database.h"
#include "root.h"

#include "commdlg.h"
#include "desktop.h"
#include "dialog.h"
#include "list.h"
#include "qbe.h"
#include "resource.h"

#include "export.h"
#include "mconfig.h"

/****** DEFINES **************************************************************/

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID    click_config _((WINDOWP window, MKINFO *mk));
LOCAL BOOLEAN key_config   _((WINDOWP window, MKINFO *mk));

/*****************************************************************************/

GLOBAL BOOLEAN init_mconfig ()

{
  set_ptext (config, CTMPDIR, "");
  set_ptext (config, CMAXIND, "");
  set_ptext (config, CMAXDAT, "");
  get_config ();

  return (TRUE);
} /* init_mconfig */

/*****************************************************************************/

GLOBAL BOOLEAN term_mconfig ()

{
  return (TRUE);
} /* term_mconfig */

/*****************************************************************************/

GLOBAL VOID get_config ()

{
  BYTE    *p;
  WORD    l;
  WINDOWP window;
  RECT    border;

  get_ptext (config, CTMPDIR, tmpdir);

  if (tmpdir [0] == EOS)
    if (((p = getenv ("TEMP")) != NULL) || ((p = getenv ("TMP")) != NULL))
      strcpy (tmpdir, p);

  l = strlen (tmpdir);

  if (l > 0)
    if (tmpdir [l - 1] != PATHSEP)
    {
      tmpdir [l]     = PATHSEP;
      tmpdir [l + 1] = EOS;
    } /* if, if */

  blinkrate       	= get_word (config, CBLINK);
/* [GS] 5.1e Start */
  TabSize       		= get_word (config, CTABSIZE);
/* Ende */
  ring_bell       	= get_checkbox (config, CBEEP);
  proc_beep       	= get_checkbox (config, CPRBEEP);
  grow_shrink     	= get_checkbox (config, CGROW);
  autosave        	=	 get_checkbox (config, CAUTO);
  use_fonts       	= get_checkbox (config, CUSEFONT);
  hide_func       	= get_checkbox (config, CHIDEFNC);
  hide_iconbar    	= get_checkbox (config, CHIDEICO);
  show_queried    	= get_checkbox (config, CQUERY);
  use_calc        	= get_checkbox (config, CUSECALC);
  minimize_process  = get_checkbox (config, CMINIMIZ);
  warn_table      	= get_checkbox (config, CWARNTAB);
  show_grid       	= get_checkbox (config, CGRID);
  show_info       	= get_checkbox (config, CINFO);
  show_top        	= get_checkbox (config, CTOP);
  show_left       	= get_checkbox (config, CLEFT);
  show_pattern    	= get_checkbox (config, CPATTERN);
  max_treecache   	= get_long (config, CMAXIND);
  max_datacache   	= get_long (config, CMAXDAT);

  if (use_fonts)
  {
    LoadFonts (vdi_handle);
    set_meminfo ();
  } /* if */
  else
    UnloadFonts (vdi_handle);

  if (hide_func != is_flags (desktop, FKEYS, HIDETREE))
  {
    flip_flags (desktop, FKEYS, HIDETREE);
    window = find_desk ();

    if (window != NULL)
    {
      get_border (window, FKEYS, &border);
      set_redraw (window, &border);
    } /* if */
  } /* if */

  if (hide_iconbar != is_flags (desktop, ICONBAR, HIDETREE))
  {
    flip_flags (desktop, ICONBAR, HIDETREE);
    window = find_desk ();

    if (window != NULL)
    {
      get_border (window, ICONBAR, &border);
      set_redraw (window, &border);
    } /* if */
  } /* if */

  set_meminfo ();
} /* get_config */

/*****************************************************************************/

GLOBAL VOID set_config ()

{
  set_ptext (config, CTMPDIR, tmpdir);
  set_word (config, CBLINK, blinkrate);
/* [GS] 5.1e Start */
  set_word (config, CTABSIZE, TabSize);
/* Ende */
  set_checkbox (config, CBEEP, ring_bell);
  set_checkbox (config, CPRBEEP, proc_beep);
  set_checkbox (config, CGROW, grow_shrink);
  set_checkbox (config, CAUTO, autosave);
  set_checkbox (config, CUSEFONT, use_fonts);
  set_checkbox (config, CHIDEFNC, hide_func);
  set_checkbox (config, CHIDEICO, hide_iconbar);
  set_checkbox (config, CQUERY, show_queried);
  set_checkbox (config, CUSECALC, use_calc);
  set_checkbox (config, CMINIMIZ, minimize_process);
  set_checkbox (config, CWARNTAB, warn_table);
  set_checkbox (config, CGRID, show_grid);
  set_checkbox (config, CINFO, show_info);
  set_checkbox (config, CTOP, show_top);
  set_checkbox (config, CLEFT, show_left);
  set_checkbox (config, CPATTERN, show_pattern);
  set_long (config, CMAXIND, max_treecache);
  set_long (config, CMAXDAT, max_datacache);

  undo_state (config, COK, DISABLED);
} /* set_config */

/*****************************************************************************/

GLOBAL VOID mconfig ()

{
  WINDOWP window;
  WORD    ret;

  window = search_window (CLASS_DIALOG, SRCH_ANY, CONFIG);

  if (window == NULL)
  {
    form_center (config, &ret, &ret, &ret, &ret);
    window = crt_dialog (config, NULL, CONFIG, FREETXT (FCONFIG), wi_modeless);

    if (window != NULL)
    {
      window->click = click_config;
      window->key   = key_config;
    } /* if */
  } /* if */

  if (window != NULL)
  {
    if (window->opened == 0)
    {
      window->edit_obj = find_flags (config, ROOT, EDITABLE);
      window->edit_inx = NIL;
      set_config ();
    } /* if */

    if (! open_dialog (CONFIG)) hndl_alert (ERR_NOOPEN);
  } /* if */
} /* mconfig */

/*****************************************************************************/

LOCAL VOID click_config (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  FULLNAME path;
  WORD     i, num;
  WINDOWP  winds [MAX_GEMWIND];
  BOOLEAN  redraw_all;

  switch (window->exit_obj)
  {
    case CTMPLABE : if (mk->breturn == 2)
                    {
                      get_ptext (window->object, CTMPDIR, path);

                      if (GetPathNameDialog (FREETXT (FTMPDIR), get_str (helpinx, HSELPATH), 0L, path))
                      {
                        set_ptext (window->object, CTMPDIR, path);
                        draw_object (window, CTMPDIR);
                      } /* if */
                    } /* if */
                    break;
    case COK      : if ((show_grid != get_checkbox (config, CGRID)) ||
                        (show_info != get_checkbox (config, CINFO)) ||
                        (show_top != get_checkbox (config, CTOP)) ||
                        (show_left != get_checkbox (config, CLEFT)) ||
                        (show_pattern != get_checkbox (config, CPATTERN)))
                    {
                      num = num_windows (CLASS_LIST, SRCH_OPENED | SRCH_SUB, winds);
                      for (i = 0; i < num; i++)
                        set_redraw (winds [i], &winds [i]->work);
                    } /* if */

                    if (show_pattern != get_checkbox (config, CPATTERN))
                    {
                      num = num_windows (CLASS_QBE, SRCH_OPENED | SRCH_SUB, winds);
                      for (i = 0; i < num; i++)
                        set_redraw (winds [i], &winds [i]->work);
                    } /* if */

                    redraw_all = (use_fonts != get_checkbox (config, CUSEFONT));

                    if (redraw_all)
                    {
                      num = num_windows (NIL, SRCH_OPENED, winds);
                      for (i = 0; i < num; i++)
                        set_redraw (winds [i], &winds [i]->work);
                    } /* if */

                    get_config ();
                    break;
    case CCANCEL  : set_config ();
                    break;
    case CHELP    : hndl_help (HCONFIG);
                    undo_state (window->object, window->exit_obj, SELECTED);
                    draw_object (window, window->exit_obj);
                    break;
  } /* switch */
} /* click_config */

/*****************************************************************************/

LOCAL BOOLEAN key_config (window, mk)
WINDOWP window;
MKINFO  *mk;

{
  BYTE *p;

  switch (window->edit_obj)
  {
    case CBLINK : p = get_str (config, CBLINK);

                  if ((*p == EOS) == ! is_state (config, COK, DISABLED))
                  {
                    flip_state (config, COK, DISABLED);
                    draw_object (window, COK);
                  } /* if */
                  break;
  } /* switch */

  return (FALSE);
} /* key_config */

/*****************************************************************************/

