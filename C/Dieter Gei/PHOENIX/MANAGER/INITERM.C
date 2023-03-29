/*****************************************************************************
 *
 * Module : INITERM.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the initialization and termination functions.
 *
 * History:
 * 04.01.04: Alle freien Text sind in der Resoucedatei
 * 02.01.04: Es gibt fÅr die Texte zwei Dateien, deutsch und englisch
 * 22.06.03: Call term_clipbrd added
 * 02.11.02: Calls to init_av and term_av added
 * 23.02.97: Help databse is no longer being opened
 * 13.02.97: OLGA initialization added
 * 10.12.96: Calls to AccPrevInit and AccPrevTerm added
 * 20.10.96: Calls to AccountInit and AccountTerm added
 * 25.06.96: shel_write with empty program called in term_initerm
 * 18.06.96: StrTok used for command line parsing
 * 17.06.96: str_upr for command line removed
 * 16.06.96: strcmpi used
 * 07.10.95: Calls to module popup removed
 * 17.09.95: AccObj calls added
 * 14.08.95: Call to InitControls modified
 * 09.07.95: AccDef calls added
 * 31.12.94: Using new function names of controls module
 * 08.02.94: Including of blist etc. removed
 * 01.12.93: Calls to InitIcons and TermIcons added
 * 13.11.93: Call to init_userinterface modified
 * 04.11.93: Calls to InitCommDlg and TermCommDlg added
 * 01.11.93: Call to wind_update moved before init_resource
 * 03.10.93: User interface initialization added
 * 27.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#include "import.h"
#include <olga.h>
#include "global.h"

#include "av.h"

#include "windows.h"

#include "manager.h"

#include "database.h"

#include "resource.h"
#include "menu.h"
#include "controls.h"
#include "root.h"
#include "dialog.h"
#include "event.h"

#include "accdef.h"
#include "accobj.h"
#include "account.h"
#include "accprev.h"
#include "batch.h"
#include "calc.h"
/* [GS] 5.1c Start */
#include "clipbrd.h"
/* Ende */
#include "commdlg.h"
#include "delete.h"
#include "desktop.h"
#include "disk.h"
#include "edit.h"
#include "help.h"
#include "icons.h"
#include "image.h"
#include "images.h"
#include "impexp.h"
#include "list.h"
#include "mask.h"
#include "mconfig.h"
#include "meta.h"
#include "mfile.h"
#include "mimpexp.h"
#include "mlsconf.h"
#include "mpagefrm.h"
#include "order.h"

#include "olga_.h"

#include "printer.h"
#include "process.h"
#include "qbe.h"
#include "reorg.h"
#include "repmake.h"
#include "report.h"
#include "select.h"
#include "selwidth.h"
#include "shell.h"
#include "sql.h"
#include "trash.h"
#include "userintr.h"

#include "export.h"
#include "initerm.h"

/****** DEFINES **************************************************************/

#define RELEASE_VERSION 0

#define ACC_MENU        "  Manager"
#define MAX_RESWIND     40

#define MAX_USRBLK      700             /* max number of usrblks */
#define MAX_CICON         5             /* max number of coloricon blocks */

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/


/* [GS] 5.1f; alt:
/* [GS] 5.1d; Start: */

#include "manage_d.err"        /* local alert messages "alert_msgs" 			 */

/* Ende; alt:
#include "manage_d.msg"        /* local text messages  										 */

#include "manager.err"          /* local alert messages "alert_msgs" 				 */
*/
*/

LOCAL BOOLEAN gl_ok;            /* Initialisierung von global ok? 					 */
LOCAL BOOLEAN rsc_ok;           /* Initialisierung von resource ok? 				 */

/****** FUNCTIONS ************************************************************/

/* [GS] 5.2 old
LOCAL BOOLEAN install_check (VOID);
*/
LOCAL BYTE    *StrTok       (BYTE *pString, BYTE *pTokens);

/*****************************************************************************/
/* [GS] 5.2 old
LOCAL BOOLEAN install_check (VOID)

{
  BYTE *serial, *company, *name;

  serial  = get_str (about, ASERIAL);
  company = get_str (about, ACOMPANY);
  name    = get_str (about, ANAME);

#if RELEASE_VERSION
  if ((serial  [0] == 's') && (serial  [1] == 's')  &&
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

  ok      = TRUE;
  gl_ok   = init_global (argc, argv, ACC_MENU, CLASS_DESK); /* Initialisiere global */
/* [GS] 5.1f alt:
  alerts  = alert_msgs;
*/
/* [GS] 5.1d alt:
  freetxt = free_text;
*/

  if (! gl_ok) return (FALSE);                  /* Keine Applikation mehr mîglich */

	init_olga ();

  ok &= InitControls (MAX_USRBLK, MAX_CICON, sizeof (bmbutton) / sizeof (BMBUTTON), bmbutton);

  rsc_ok = init_resource ();                    /* Initialisiere resource */
/* [GS] 5.1f Start: */
  alerts  = alertmsg;
/* Ende */
/* [GS] 5.1d Start */
  freetxt = alertmsg;
/* Ende */

  if (! rsc_ok) return (FALSE);                 /* Resourcen nicht ok */

/* [GS] 5.2 old
  if (! install_check ()) return (FALSE);       /* Software schon installiert worden? */
*/

  wind_update (BEG_UPDATE);                     /* Benutzer darf nicht agieren */

  if (strncmp (app_name, get_str (menu, MDESK) + 1, strlen (get_str (menu, MDESK) + 1)) != 0)
    strcpy (app_path, act_path);                /* Wegen Turbo-C */

  ok &= init_windows (NIL, MAX_RESWIND, CLASS_HELP);
  ok &= init_menu ();

  if (! deskacc && menu_fits) menu_bar (menu, TRUE);    /* MenÅzeile darstellen */

  busy_mouse ();

  ok &= init_root ();
  ok &= init_dialog (alerts, alert, ALERT, FREETXT (FDESKNAM));
  ok &= init_event ();

	ok &= init_av ();
  ok &= AccDefInit ();
  ok &= AccObjInit ();
  ok &= AccountInit ();
  ok &= AccPrevInit ();
  ok &= init_batch ();
  ok &= init_calc ();
  ok &= InitIcons ();
  ok &= InitCommDlg (ERR_NOOPEN, &FREETXT (FCOMMDLG_NAME), &FREETXT (FCOMMDLG_WHITE), IconsGetNumIconSuffixes (), IconsGetIconSuffixes ());
  ok &= init_delete ();
  ok &= init_desktop ();
  ok &= init_disk ();
  ok &= init_edit ();
  ok &= init_help (NULL, NULL, get_str (helpinx, HCONTENT));
  ok &= init_image ();
  ok &= init_impexp ();
  ok &= init_list ();
  ok &= init_mask ();
  ok &= init_mconfig ();
  ok &= init_meta ();
  ok &= init_mfile ();
  ok &= init_mimpexp ();
  ok &= init_mlsconf ();
  ok &= init_mpagefrm ();
  ok &= init_order ();
  ok &= init_printer ();
  ok &= init_process ();
  ok &= init_qbe ();
  ok &= init_reorg ();
  ok &= init_repmake ();
  ok &= init_report ();
  ok &= init_select ();
  ok &= init_selwidth ();
  ok &= init_shell ();
  ok &= init_sql ();
  ok &= init_trash ();
  ok &= init_userinterface (ERR_NOOPEN, &FREETXT (FCOMMDLG_WHITE), &FREETXT (FCOLOR_HIGHLIGHT), &FREETXT (FDLG_CHECK0), &FREETXT (FDLG_RADIO0), &FREETXT (FDLG_ARROW0));

#ifdef USE_PHOENIX_HELPDB
#if GEMDOS | FLEXOS
  strcpy (s, app_path);
  strcat (s, FREETXT (FHELPBAS));
  strcat (s, FREETXT (FDATSUFF) + 1);

  if (ok && file_exist (s))
  {
    RECT r;

    p = get_str (loaddb, LOADNAME);
    strncpy (p, app_path, 60);
    p [60] = EOS;
    strncat (p, FREETXT (FHELPBAS), 60);
    p [60] = EOS;
    opendial (loaddb, FALSE, NULL, NULL, NULL);
    form_center (loaddb, &r.x, &r.y, &r.w, &r.h);
    objc_draw (loaddb, ROOT, MAX_DEPTH, r.x, r.y, r.w, r.h);

    if (! open_dbhelp (FREETXT (FHELPBAS), app_path))
    {
      menu_enable (menu, MHELPCXT, FALSE);
      menu_enable (menu, MHELPINX, FALSE);
      menu_enable (menu, MHELPCON, FALSE);
      menu_enable (menu, MHELPOBJ, FALSE);
      set_helpfunc ((HELPFUNC)NULL);
    } /* if */

    closedial (loaddb, FALSE, NULL, NULL, NULL);
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

  return (ok);
} /* init_initerm */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_initerm ()

{
  BOOLEAN  ok, call_gem;
  FULLNAME s, path;
  EXT      ext;
  BYTE     sep [2];

  ok = TRUE;

  if (gl_ok && rsc_ok)
  {

		term_olga ();

    wind_update (BEG_UPDATE);
    busy_mouse ();

    strcpy (s, app_path);
    strcat (s, FREETXT (FDESKNAM));
    str_rmchar (s, SP);
    strcat (s, FREETXT (FINFSUFF) + 1);
    if (autosave) msave_config (s, TRUE, TRUE);

    if (*called_by)                             /* ZurÅck zum Aufrufer bzw. an OUTPUT */
    {
      file_split (called_by, NULL, NULL, NULL, ext);

      call_gem = (strcmpi (ext, "PRG") == 0) ||
                 (strcmpi (ext, "APP") == 0) ||
                 (strcmpi (ext, "286") == 0);

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

    wind_update (END_UPDATE);                   /* Fehler kînnten in mclosedb auftreten */

    while (num_opendb > 0) mclosedb ();

    wind_update (BEG_UPDATE);

    ok &= term_userinterface ();
    ok &= term_trash ();
    ok &= term_sql ();
    ok &= term_shell ();
    ok &= term_selwidth ();
    ok &= term_select ();
    ok &= term_report ();
    ok &= term_repmake ();
    ok &= term_reorg ();
    ok &= term_qbe ();
    ok &= term_process ();
    ok &= term_printer ();
    ok &= term_order ();
    ok &= term_mpagefrm ();
    ok &= term_mlsconf ();
    ok &= term_mimpexp ();
    ok &= term_mfile ();
    ok &= term_meta ();
    ok &= term_mconfig ();
    ok &= term_mask ();
    ok &= term_list ();
    ok &= term_impexp ();
    ok &= term_image ();
    ok &= term_help ();
    ok &= term_edit ();
    ok &= term_disk ();
    ok &= term_desktop ();
    ok &= term_delete ();
    ok &= TermCommDlg ();
    ok &= TermIcons ();
    ok &= term_calc ();
    ok &= term_batch ();
    ok &= AccPrevTerm ();
    ok &= AccountTerm ();
    ok &= AccObjTerm ();
    ok &= AccDefTerm ();
		ok &= term_av ();

    ok &= term_event ();
    ok &= term_dialog ();
    ok &= term_menu ();
    ok &= term_root ();
    ok &= term_windows ();
    ok &= term_resource ();
    ok &= TermControls ();

/* [GS] 5.1c Start: */
    ok &= term_clipbrd ();
/* Ende */

    arrow_mouse ();
    wind_update (END_UPDATE);
  } /* if */

  ok &= term_global ();                         /* Terminiere global */

  return (ok);
} /* term_initerm */

