/*****************************************************************************
 *
 * Module : EVENT.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the event message dispatcher.
 *
 * History:
 * 26.01.04: hndl_mesag bekommt jetzt noch mk Åbergeben.
 * 26.12.02: In hndl_mesag sprung nach hndl_olga eingetragen.
 * 07.11.02: Aufrufe von hndl_av etwas nach hinten geschoben
 * 02.11.02: In hndl_mesag sprung nach hndl_av eingetragen.
 * 30.10.02: menu_pipe wird gefÅllt
 * 29.05.02: WM_BACKDROP und WM_BOTTOMED in hndl_mesag eingefÅgt.
 * 27.02.97: Handling of WM_SHADED and WM_UNSHADED added
 * 13.02.97: Unhandled messages are forwarded to all windows
 * 20.05.96: Shutdown functionality added
 * 15.03.94: Message VA_START handled
 * 16.11.93: Help function is not called if help button is hidden in modal dialog
 * 28.03.92: Left and right mouse button for X/GEM handling added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include "global.h"
#include "windows.h"
#include "av.h"

#include "desktop.h"
#include "menu.h"

#include "olga_.h"

#include "export.h"
#include "event.h"

/****** DEFINES **************************************************************/

#define EVENTS    (MU_KEYBD | MU_BUTTON  | MU_M1 | MU_MESAG | MU_TIMER)
#define MILLISECS 100L          /* Anzahl der Millisekunden fÅr timer */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID hndl_m1 _((WINDOWP top, UWORD *m1flags));

/*****************************************************************************/
/* Ereignis-Verarbeitung                                                     */
/*****************************************************************************/

LOCAL VOID hndl_m1 (top, m1flags)
WINDOWP top;
UWORD   *m1flags;

{
  if (*m1flags)
    set_mouse (ARROW, NULL);
  else
    if (top != NULL) set_mouse (top->mousenum, top->mouseform);

  *m1flags ^= TRUE;
} /* hndl_m1 */

/*****************************************************************************/

GLOBAL VOID hndl_keybd (mk)
MKINFO *mk;

{
  WORD    title, item;
  WINDOWP top;

  mk->ascii_code = mk->kreturn & 0x00FF;
  mk->scan_code  = mk->kreturn >> 8;

#if GEMDOS
  if ((mk->scan_code >= 71) && (mk->scan_code <= 82) && /* Shift-Pfeile */
      (mk->scan_code != 74) && (mk->scan_code != 78)) mk->ascii_code = 0;
#endif

  mk->kreturn = (mk->scan_code << 8) | mk->ascii_code;

  if ((mk->alt || mk->ctrl) && (mk->scan_code == ESCAPE)) cycle_window ();

  if (! key_all (mk))
    if (! deskacc)
      if (is_menu_key (menu, mk, &title, &item)) hndl_menu (NULL, title, item);

  top = find_top ();

  if (top != NULL)
    if (top->flags & WI_MODAL)
      if ((mk->scan_code == F1) || (mk->scan_code == HELP))
      {
        top->exit_obj = find_flags (top->object, ROOT, HELP_FLAG);

        if ((top->exit_obj != NIL) && ! is_state (top->object, top->exit_obj, DISABLED) && ! is_flags (top->object, top->exit_obj, HIDETREE))
        {
          do_state (top->object, top->exit_obj, SELECTED);
          draw_object (top, top->exit_obj);
          if (top->click != NULL) (*top->click) (top, mk);
        } /* if */
      } /* if, if, if */
} /* hndl_keybd */

/*****************************************************************************/

GLOBAL VOID hndl_button (mk)
MKINFO *mk;

{
  WORD    wh;
  WINDOWP window;

#if GEM & XGEM
  if (bstate == 0x0000)
    bstate = 0x0001;                            /* Warte auf Knopf unten */
  else
  {
    bstate = 0x0000;                            /* Warte auf Knopf oben */
#else
  if (bclicks == 0x0002)
    bclicks = 0x0102;                           /* Warte auf Knopf unten */
  else
  {
    bclicks = 0x0002;                           /* Warte auf Knopf oben */
#endif
    wh      = wind_find (mk->mox, mk->moy);     /* Hole Window Handle */
    window  = find_window (wh);                 /* Hole Window */

    if (window != NULL)
    {
      if (window->menu != NULL)
        if (menu_manager (window, mk->mox, mk->moy, mk->mobutton, mk->breturn)) return; /* Erledigt */

      click_window (window, mk);                /* Selektiere */
    } /* if */
    else                                        /* Nur fÅr Desktop */
      if (sel_window != NULL) unclick_window (sel_window); /* Deselektiere */
  } /* else */
} /* hndl_button */

/*****************************************************************************/

/* [GS] 5.1d Start */
GLOBAL VOID hndl_mesag ( WORD *msgbuff, MKINFO *mk )
/* Ende; alt.
GLOBAL VOID hndl_mesag (msgbuff)
WORD *msgbuff;
*/
{
  WORD    wh;                           /* Aktuelles Window Handle */
  RECT    r;                            /* Koordinaten fÅr Fenster */
  WINDOWP window;                       /* Aktuelles Fenster */
	WORD i;

	for ( i = 0; i < 8; i++ )
		menu_pipe [i] = msgbuff [i];

  acc_close = msgbuff [0] == AC_CLOSE;  /* Accessory soll geschlossen werden */
  wh        = msgbuff [3];              /* Meistens Window Handle */
  window    = find_window (wh);         /* Zugehîriges Fenster */
  r.x       = msgbuff [4];              /* Meistens Koordinaten */
  r.y       = msgbuff [5];
  r.w       = msgbuff [6];
  r.h       = msgbuff [7];

 	if ( hndl_av ( msgbuff ) )						/* VA-Protokoll bearbeiten	*/
		return;

 	if ( hndl_olga ( msgbuff ) )					/* OLGA-Protokoll bearbeiten*/
		return;

  switch (msgbuff [0])                  /* Art der Nachricht */
  {
    case MN_SELECTED : hndl_menu (NULL, msgbuff [3], msgbuff [4]);                                          break;
    case WM_REDRAW   : redraw_window (window, &r);                                                          break;
    case WM_TOPPED   : top_window (window);                                                                 break;
    case WM_CLOSED   : close_window (window);                                                               break;
    case WM_FULLED   : full_window (window);                                                                break;
    case WM_ARROWED  : arrow_window (window, msgbuff [4], 1);                                               break;
    case WM_HSLID    : h_slider (window, msgbuff [4]);                                                      break;
    case WM_VSLID    : v_slider (window, msgbuff [4]);                                                      break;
    case WM_SIZED    : size_window (window, &r);                                                            break;
    case WM_MOVED    : move_window (window, &r);                                                            break;
    case WM_BACKDROP :
    case WM_BOTTOMED :
    case WM_UNTOPPED : untop_window (window);                                                               break;
/* [GS] 5.1e Start: not ready
    case WM_ICONIFY  : iconify_window (window, msgbuff);																										break;
    case WM_UNICONIFY: uniconify_window (window, msgbuff);																									break;
 End; */
    case AC_OPEN     : if (msgbuff [4] == menu_id) open_desktop (NIL);                                      break;
    case AC_CLOSE    : if (msgbuff [3] == menu_id) close_all (FALSE, TRUE);                                 break;
    case VA_START    : hndl_va_start ((BYTE *)(((LONG)msgbuff [4] & 0xFFFFL) | ((LONG)msgbuff [3] << 16))); break;
    case AP_TERM     : hndl_ap_term (msgbuff [1], msgbuff [5]);                                             break;
    case WM_SHADED   : window->flags |= WI_SHADED;                                                          break;
    case WM_UNSHADED : window->flags &= ~ WI_SHADED;                                                        break;
/* [GS] 5.1d; Start */
    default          : message_all (msgbuff, mk );                                                         break;
/* Ende; alt:
    default          : message_all (msgbuff);                                                               break;
*/
  } /* switch */
} /* hndl_mesag */

/*****************************************************************************/

GLOBAL VOID hndl_timer (millisecs)
LONG millisecs;

{
  if (millisecs == 0) millisecs = 1;    /* Mindestens 1 Millisekunde vergangen */

  timer_all (millisecs);
} /* hndl_timer */

/*****************************************************************************/

GLOBAL VOID hndl_events ()

{
  WORD    event;                        /* Eingetretenes Ereignis */
  WORD    msgbuff [8];                  /* Event Message Puffer */
  WORD    new_top, old_top;             /* Window-Handles */
  WORD    ret;                          /* Dummy Return-Wert */
  WINDOWP top;                          /* Oberstes Fenster */
  MKINFO  mk;                           /* Maus und Tastatur Info */
  UWORD   m1flags;                      /* Mausereignis-Flags */
  RECT    m1;                           /* Mausereignis-Koordinaten */

  m1flags = FALSE;                      /* Bei Eintritts-Ereignis */

  wind_get (DESK, WF_TOP, &new_top, &ret, &ret, &ret);
  shel_write (SHW_INFRECGN, TRUE, 0, NULL, NULL);

  do
  {
    updt_menu (NULL);                   /* Eine Aktion kann MenÅs verÑndern */

    events  |= MU_M1;
    old_top  = new_top;
    top      = find_top ();             /* Hole oberstes Fenster von diesem Prozeû */

    wind_get (DESK, WF_TOP, &new_top, &ret, &ret, &ret);

    if ((top != NULL) && (new_top == top->handle) &&
        (top->opened > 0) && (top->flags & WI_MOUSE))
      m1 = top->scroll;                 /* Warte auf Mausereignis */
    else
    {
      events  &= ~ MU_M1;               /* Kein Maus-Ereignis mehr */
      m1flags  = FALSE;
      xywh2rect (0, 0, 0, 0, &m1);
    } /* else */

    if (old_top != new_top)             /* Mausform durch Schlieûen oder... */
    {                                   /* ...ôffnen von Fenstern zu Ñndern */
      m1flags = FALSE;                  /* Auf jeden Fall auf Eintritt warten */
      set_mouse (ARROW, NULL);          /* ZunÑchst wieder Pfeil setzen */
    } /* if */

    event = evnt_multi (events,
                        bclicks, bmask, bstate,
                        m1flags, m1.x, m1.y, m1.w, m1.h,
                        0, 0, 0, 0, 0,
                        msgbuff,
                        (UWORD)(millisecs & 0xFFFF), (UWORD)(millisecs >> 16),
                        &mk.mox, &mk.moy,
                        &mk.momask, &mk.kstate,
                        &mk.kreturn, &mk.breturn);

    wind_update (BEG_UPDATE);           /* Keine Interaktion zulassen */

    graf_mkstate (&ret, &ret, &mk.mobutton, &mk.kstate); /* Werte nach Ereignis */

#if MSDOS
    if (mk.momask == 0x0000) mk.momask = 0x0001;         /* Irgendein Knopf ist linker Knopf */
#endif

    mk.shift  = (mk.kstate & (K_RSHIFT | K_LSHIFT)) != 0;
    mk.ctrl   = (mk.kstate & K_CTRL) != 0;
    mk.alt    = (mk.kstate & K_ALT) != 0;
    acc_close = FALSE;

    if (event & MU_KEYBD ) hndl_keybd (&mk);
    if (event & MU_BUTTON) hndl_button (&mk);
    if (event & MU_M1    ) hndl_m1 (top, &m1flags);
/* [GS] 5.1d Start */
    if (event & MU_MESAG ) hndl_mesag (msgbuff, &mk);
/* Ende; alt:
    if (event & MU_MESAG ) hndl_mesag (msgbuff);
*/
    if (event & MU_TIMER ) hndl_timer (millisecs);

    if (deskacc)
    {
      if (acc_close) term_menu ();      /* Gib Fonts frei */

      if (done)
      {
        close_all (FALSE, TRUE);        /* Schlieûe alle Fenster */
        done = FALSE;                   /* Verlasse Programm nie */
      } /* if */
    } /* if */

#if GEM & XGEM
    if (find_top () == NULL)
    {
      done          = TRUE;             /* Keine Fenster mehr offen */
      called_by [0] = EOS;              /* Programm ganz beenden */
    } /* if */
#endif

    wind_update (END_UPDATE);           /* Benutzer darf wieder agieren */
  } while (! done);
} /* hndl_events */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_event ()

{
  events    = EVENTS;                   /* Warte auf einzutretende Ereigneisse */
  millisecs = MILLISECS;                /* Anzahl der Standard-Millisekunden */
#if GEM & XGEM
  bclicks   = 0x0002;                   /* Warte auf Doppeklick */
  bmask     = 0x0001;                   /* Warte auf linken Mausknopf */
  bstate    = 0x0001;                   /* Warte auf linken Mausknopf unten */
#else
  bclicks   = 0x0102;                   /* Benutze beide Mausknîpfe mit Doppelklick (Sonderfall) */
  bmask     = 0x0003;                   /* Warte auf beide Mausknîpfe */
  bstate    = 0x0000;                   /* Warte auf beide Mausknîpfe oben */
#endif

  return (TRUE);
} /* init_event */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_event ()

{
  return (TRUE);
} /* term_event */

