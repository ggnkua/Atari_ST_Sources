/*****************************************************************************
 *
 * Module : INITERM.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the initialization and termination functions.
 *
 * History:
 * 09.01.04: Alle freien Text sind in der Resoucedatei
 * 26.12.02: Neuer Parameter (-M), fÅr vom Manager gestartet.
 *					 OLGA Aufrufe verÑndert.
 * 11.03.97: Help databse is no longer being opened
 * 17.02.97: OLGA initialization added
 * 18.06.96: StrTok used for command line parsing
 * 17.06.96: str_upr for command line removed
 * 31.10.95: Call to InitControls modified
 * 04.01.95: Using new function names of controls module
 * 16.12.93: Calls to InitIcons and TermIcons added
 * 29.11.93: All icons for commdlg used
 * 20.11.93: Calls to build_icon added, old mselfont.h deleted
 * 07.11.93: Calls to InitCommDlg and TermCommDlg added
 * 03.11.93: Call to wind_update moved before init_resource
 * 11.10.93: User interface initialization added
 * 06.09.93: Modifications in init_message made
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"
#include "windows.h"

#include "designer.h"

#include "database.h"

#include "resource.h"
#include "controls.h"
#include "root.h"
#include "menu.h"
#include "dialog.h"
#include "event.h"

#include "base.h"
#include "clipbrd.h"
#include "commdlg.h"
#include "desktop.h"
#include "help.h"
#include "icons.h"
#include "images.h"
#include "mask.h"
#include "mfile.h"
#include "moptions.h"
#include "printer.h"
#include "olga_.h"
#include "userintr.h"

#include "export.h"
#include "initerm.h"

/****** DEFINES **************************************************************/

#define RELEASE_VERSION 0

#define ACC_MENU        "  Designer"
#define MAX_RESWIND     40

#define MAX_USRBLK     700	/* max number of usrblks */
#define MAX_CICON        5	/* max number of coloricon blocks */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

#include "designer.err"

LOCAL BOOLEAN gl_ok;            /* Initialisierung von global ok? */
LOCAL BOOLEAN rsc_ok;           /* Initialisierung von resource ok? */
LOCAL BOOLEAN manager_started;	/* Manager hat den Designer aufgerufen	*/

/****** FUNCTIONS ************************************************************/

/* [GS] 5.2 old:
LOCAL BOOLEAN install_check (VOID);
*/
LOCAL BYTE    *StrTok       (BYTE *pString, BYTE *pTokens);

/* [GS] 5.2 old:
LOCAL BOOLEAN install_check (VOID)

{
  BYTE *serial, *company, *name;

  serial  = get_str (about, ASERIAL);
  company = get_str (about, ACOMPANY);
  name    = get_str (about, ANAME);

#if RELEASE_VERSION
  if ((serial  [0] == 's') && (serial  [1] == 's') &&
      (company [0] == 'f') && (company [1] == 'f') &&
      (name    [0] == 'n') && (name    [1] == 'n')) return (FALSE);
#endif

  while (*serial)  *serial++  ^= 0xFF;
  while (*company) *company++ ^= 0xFF;
  while (*name)    *name++    ^= 0xFF;

  return (TRUE);
} /* install_check */
*/

/*****************************************************************************/

LOCAL BYTE *StrTok (BYTE *pString, BYTE *pTokens)
{
  LOCAL BYTE *p, *pRet, *pDst;

  if (pString != NULL)				/* first call */
  {
    p = pString;

    while ((*p != EOS) && (*p != '\'') && (strchr (pTokens, *p) != NULL))
      p++;
  } /* if */

  if (*p == EOS)				/* empty string or only tokens */
    pRet = NULL;
  else
  {
    pRet = pDst = p;

    while ((*p != EOS) && (strchr (pTokens, *p) == NULL))
      if ((*pTokens != EOS) && (*p == '\''))
      {
        p++;

        while ((*p != '\'') && (*p != EOS))	/* copy ' delimited string */
          *pDst++ = *p++;

        if (*p != EOS)
	  p++;
      } /* if */
      else
        *pDst++ = *p++;

    if (*p != EOS)				/* token at end of string found, delete it */
      *p++ = EOS;

    *pDst = EOS;				/* must be below line above because pDst and p could poiint to same char */

    while ((*p != EOS) && (*p != '\'') && (strchr (pTokens, *p) != NULL))
      p++;
  } /* else */

  return (pRet);
} /* StrTok */

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_initerm (argc, argv)
INT  argc;
BYTE *argv [];

{
  BOOLEAN  ok;
  BYTE     *p;
  FULLNAME s, prefix, path;
  WORD     drive;
  FILENAME filename;
  EXT      ext;

#ifdef USE_PHOENIX_HELPDB
#if GEMDOS | FLEXOS
  MFDB     screen, buf;
  RECT     r;
#endif
#endif

  ok      = TRUE;
  gl_ok   = init_global (argc, argv, ACC_MENU, CLASS_DESK); /* Initialisiere global */
/* [GS] 5.1f alt:
  alerts  = alert_msgs;
*/
/* [GS] 5.1d alt:
  freetxt = free_text;
*/
	manager_started = FALSE;

  if (! gl_ok) return (FALSE);                  /* Keine Applikation mehr mîglich */

/* GS 5.b Start */
	init_olga ();
/* Ende; alt:
  olga_apid = appl_find ("OLGA    ");

  if (olga_apid >= 0)
  {
    WORD msg [8];

    msg [0] = OLE_INIT;
    msg [1] = gl_apid;
    msg [2] = 0;
    msg [3] = OL_CLIENT;
    msg [4] = 0;
    msg [5] = 0;
    msg [6] = 0;
    msg [7] = 0x4442;														/* DB	*/

    appl_write (olga_apid, sizeof (msg), msg);
  } /* if */
*/

  ok &= InitControls (MAX_USRBLK, MAX_CICON, sizeof (bmbutton) / sizeof (BMBUTTON), bmbutton);

  rsc_ok = init_resource ();                    /* Initialisiere resource */
  if (! rsc_ok) return (FALSE);                 /* Resourcen nicht ok */
/* [GS] 5.1f Start: */
  alerts  = alertmsg;
/* Ende */
/* [GS] 5.1d Start */
  freetxt = alertmsg;
/* Ende */

/* [GS] 5.2 old:
  if (! install_check ()) return (FALSE);       /* Software schon installiert worden? */
*/

  wind_update (BEG_UPDATE);                     /* Benutzer darf nicht agieren */

  if (strncmp (app_name, get_str (menu, MDESK) + 1, strlen (get_str (menu, MDESK) + 1)) != 0)
    strcpy (app_path, act_path);                /* Wegen Turbo-C */

  ok &= init_windows (NIL, MAX_RESWIND, CLASS_HELP);
  ok &= init_menu ();

  if (! deskacc && menu_fits) menu_bar (menu, TRUE);    /* MenÅzeile darstellen */

  busy_mouse ();                                /* Biene zeigen */

  ok &= init_root ();
  ok &= init_dialog (alerts, alert, ALERT, FREETXT (FDESKNAM));
  ok &= init_event ();

  ok &= init_clipbrd ((ccp_ext & DO_EXTERNAL) != 0);
  ok &= InitIcons ();
  ok &= InitCommDlg (ERR_NOOPEN, &FREETXT (FCOMMDLG_NAME), &FREETXT (FCOMMDLG_WHITE), IconsGetNumIconSuffixes (), IconsGetIconSuffixes ());
  ok &= init_desktop ();
  ok &= init_help (NULL, NULL, get_str (helpinx, HCONTENT));
  ok &= init_printer ();
  ok &= init_mfile ();
  ok &= init_moptions ();
  ok &= init_base ();
  ok &= init_mask ();
  ok &= init_userinterface (ERR_NOOPEN, &FREETXT (FCOMMDLG_WHITE), &FREETXT (FCOLOR_HIGHLIGHT), &FREETXT (FDLG_CHECK0), &FREETXT (FDLG_RADIO0), &FREETXT (FDLG_ARROW0));

#ifdef USE_PHOENIX_HELPDB
#if GEMDOS | FLEXOS
  strcpy (s, app_path);
  strcat (s, FREETXT (FHELPBAS));
  strcat (s, FREETXT (FDATSUFF) + 1);

  if (ok && file_exist (s))
  {
    sprintf (filename, "%s%s", app_path, FREETXT (FHELPBAS));
    sprintf (s, FREETXT (FOPEN), filename);
    init_message (NIL, &r, &screen, &buf, s);

    if (! open_dbhelp (FREETXT (FHELPBAS), app_path))
    {
      menu_enable (menu, MHELPCXT, FALSE);
      menu_enable (menu, MHELPINX, FALSE);
      menu_enable (menu, MHELPCON, FALSE);
      menu_enable (menu, MHELPOBJ, FALSE);
      set_helpfunc ((HELPFUNC)NULL);
    } /* if */

    exit_message (&r, &screen, &buf);
  } /* if */
#endif
#endif

  if (*scrapdir == EOS) hndl_alert (ERR_SCRAPDIR);

  if (! ok)
    called_by [0] = EOS;
  else
    if (! deskacc)
    {
      open_desktop (NIL);                       /* Desktop îffnen */

      if (*tail)                                /* ParamterÅbergabe */
      {
        p          = tail;
        prefix [0] = EOS;

        for (p = StrTok (tail, " "); p != NULL; p = StrTok (NULL, " "))
        {
          if ((*p == '/') || (*p == '-'))
          {
            if (p [1] != EOS)
              switch (toupper (p [1]))                  /* Optionen */
              {
								case 'M':																/* Vom Manager gestartet	*/
									manager_started = TRUE;
								break;
                default  : break;
              } /* switch, if */
          } /* if */
          else
          {
            strcpy (s, p);

            file_split (s, &drive, path, filename, ext);

            if (*prefix == EOS)                         /* Merke PrÑfix */
            {
              strcpy (prefix, "A:");
              prefix [0] += (BYTE)drive;
              strcat (prefix, path);
            } /* if */

            if (strchr (s, PATHSEP) == NULL)            /* Kein Pfad vorhanden */
              sprintf (s, "%s%s%c%s", prefix, filename, SUFFSEP, ext); /* Benutze letzten Pfad */

            if ((strcmpi (ext, FREETXT (FINDSUFF) + 2) == 0) ||
                (strcmpi (ext, FREETXT (FDATSUFF) + 2) == 0)) mopendb (s, TRUE);
          } /* else */
        } /* for */

        tail [0] = EOS;                                 /* Nicht mehr benîtigt */
      } /* if */
    } /* if, else */

  arrow_mouse ();
  wind_update (END_UPDATE);                     /* Benuzter darf wieder agieren */

  return (ok);                                  /* Alles gut verlaufen */
} /* init_initerm */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_initerm ()

{
  BOOLEAN  ok, call_gem;
  FULLNAME s, path;
  BYTE     sep [2];
  EXT      ext;

  ok = TRUE;

  if (gl_ok && rsc_ok)
  {

		if ( !manager_started )
			term_olga ();

    wind_update (BEG_UPDATE);
    busy_mouse ();

    if (*called_by)                             /* ZurÅck zum Aufrufer bzw. an OUTPUT */
    {
      file_split (called_by, NULL, NULL, NULL, ext);

      call_gem = (strcmp (ext, "PRG") == 0) ||
                 (strcmp (ext, "APP") == 0) ||
                 (strcmp (ext, "286") == 0);

      sep [0] = PROGSEP;
      sep [1] = EOS;

      strcpy (s + 1, tail);

      if (call_gem)
      {
        strcat (s + 1, sep);
        strcat (s + 1, app_path);
        strcat (s + 1, app_name);
      } /* if */

      s [0] = (BYTE)strlen (s + 1);

      shel_write (TRUE, call_gem, 1, called_by, s);

      strcpy (path, app_path);
      path [strlen (path) - 1] = EOS;

      shel_wdef (app_name, path);
    } /* if */
    else
    {
      shel_write (FALSE, TRUE, 1, NULL, NULL);
      shel_wdef ("DESKTOP.APP", "");
    } /* else */

    if (menu_fits) menu_bar (menu, FALSE);      /* MenÅzeile freigeben */

    ok &= term_userinterface ();
    ok &= term_mask ();
    ok &= term_base ();
    ok &= term_moptions ();
    ok &= term_mfile ();
    ok &= term_printer ();
    ok &= term_help ();
    ok &= term_desktop ();
    ok &= TermCommDlg ();
    ok &= TermIcons ();
    ok &= term_clipbrd ();

    ok &= term_event ();
    ok &= term_dialog ();
    ok &= term_menu ();
    ok &= term_root ();
    ok &= term_windows ();
    ok &= term_resource ();
    ok &= TermControls ();

/* [GS] 5.1f alt:
    mem_free (alerts);
    mem_free (alert_msgs);
*/

    arrow_mouse ();
    wind_update (END_UPDATE);
  } /* if */

  ok &= term_global ();                         /* Terminiere global */

  return (ok);
} /* term_initerm */

/*****************************************************************************/

