/*****************************************************************************
 *
 * Module : RESOURCE.C
 * Author : JÅrgen Geiû
 *
 * Creation date    : 24.07.91
 * Last modification:
 *
 *
 * Description: This module implements the resource handling.
 *
 * History:
 * 09.01.04: Alle normlen rsrc_xxx Funktionen durch xrsrc_xxx ersetzt, damit
 *           Resourcen grîûer > 64KBytes bearbeitet werden kînnen.
 * 29.05.02: RSC_CREATE auf 0; RSC_NAME klein geschrieben
 * 04.01.95: Using new function names of controls module
 * 21.11.94: Initializing xrsrc module in init_resource
 * 06.10.94: No longer needing rsc_create
 * 20.09.94: Object tree seljoin changed to selsubm
 * 16.12.93: Object tree selpath added
 * 04.11.93: Object tree selfile added
 * 30.10.93: Object popup deleted
 * 11.10.93: Object tree USERINTR added, CONFMORE deleted
 * 27.09.93: Function switch_trees_3d added
 * 24.09.93: Variable confmore added
 * 06.09.93: dbiconsl & maskicnl deleted deleted
 * 01.09.93: is_dialog parameter in fix_objs deleted
 * 23.08.93: NoEcho flag set in resource
 * 20.08.93: New 3d controls added
 * 24.07.91: Creation of body
 *****************************************************************************/

#ifndef RSC_CREATE
#define RSC_CREATE 0                    /* Resource-File im Code 		 */
#endif

#ifndef INTERFACE
#define INTERFACE 1                     /* Interface Resource Editor */
#endif

#include "import.h"
#include "global.h"

#include "designer.h"

#include "controls.h"

/* [GS] 5.1d Start: */
#include "xrsrc.h"
/* Ende */

#if RSC_CREATE
#if INTERFACE
#include "designer.rh"
#else
#include "rcm.h"
#endif
#include "designer.rsh"
                                        /* In RSH-Dateien fehlt das letzte CR/LF */
#endif

#include "export.h"
#include "resource.h"

/****** DEFINES **************************************************************/

#ifndef RSC_NAME
#define RSC_NAME   "designer.rsc"       /* Name der Resource-Datei */
#endif

/****** TYPES ****************************************************************/

/****** VARIABLES ************************************************************/

/****** FUNCTIONS ************************************************************/

LOCAL VOID fix_objs _((OBJECT **treep, WORD tree_id));

/*****************************************************************************/
/* Initialisieren des Moduls                                                 */
/*****************************************************************************/

GLOBAL BOOLEAN init_resource ()

{
  WORD i, y;

#if RSC_CREATE
#if INTERFACE
  for (i = 0; i < NUM_OBS; i++)
    rsrc_obfix (rs_trindex [0], i);

  alertmsg = rs_frstr;                          /* Adresse der Fehlermeldungen */
#else
  rsc_create (gl_wbox, gl_hbox, NUM_TREE, NUM_OBS, NUM_FRSTR, NUM_FRIMG,
              rs_strings, rs_frstr, rs_bitblk, rs_frimg, rs_iconblk,
              rs_tedinfo, rs_object, (OBJECT **)rs_trindex, (RS_IMDOPE *)rs_imdope);

  alertmsg = &rs_strings [FREESTR];             /* Adresse der Fehlermeldungen */
#endif
#else
  STRING s, rsc_name;

#if INTERFACE
/* [GS] 5.1d alt:
  EXTERN BOOLEAN init_xrsrc  (WORD vdi_handle, RECT *desk, WORD gl_wbox, WORD gl_hbox);
*/
  init_xrsrc  (vdi_handle, &desk, gl_wbox, gl_hbox);
#endif

  strcpy (rsc_name, RSC_NAME);

/* [GS] 5.1d Start */
#if INTERFACE
  if (! xrsrc_load (rsc_name, xrsrc_array ))
#else
  if (! rsrc_load (rsc_name))
#endif
/* Ende; alt:
  if (! rsrc_load (rsc_name))
*/
  {
    strcpy (s, "[3][Resource-File|");
    strcat (s, rsc_name);
    strcat (s, "?][ EXIT ]");
    beep ();
    form_alert (1, s);
    if (! deskacc) return (FALSE);
    menu_unregister (gl_apid);                  /* Wieder abmelden */
    while (TRUE) evnt_timer (0, 1);             /* Lasse andere Prozesse ran */
  } /* if */

/* [GS] 5.1d Start */
	#if INTERFACE
		xrsrc_gaddr (R_FRSTR, ROOT, &alertmsg , xrsrc_array ); /* Adresse der Fehlermeldungen */
	#else
	  rsrc_gaddr (R_FRSTR, ROOT, &alertmsg);       /* Adresse der Fehlermeldungen */
	 #endif
/* Ende; alt:
  rsrc_gaddr (R_FRSTR, ROOT, &alertmsg);        /* Adresse der Fehlermeldungen */
*/
#endif

  fix_objs (&userimg,  USERIMG);		/* Muû als erstes kommen */
  fix_objs (&menu,     MENU);
  fix_objs (&about,    ABOUT);
  fix_objs (&moreinfo, MOREINFO);
  fix_objs (&desktop,  DESKTOP);
  fix_objs (&alert,    ALERT);
  fix_objs (&selfile,  SELFILE);
  fix_objs (&selpath,  SELPATH);
  fix_objs (&selfont,  SELFONT);
  fix_objs (&helpinx,  HELPINX);
  fix_objs (&popups,   POPUPS);
  fix_objs (&config,   CONFIG);
  fix_objs (&params,   PARAMS);
  fix_objs (&userintr, USERINTR);
  fix_objs (&opendb,   OPENDB);
  fix_objs (&basemenu, BASEMENU);
  fix_objs (&maskmenu, MASKMENU);
  fix_objs (&dbicons,  DBICONS);
  fix_objs (&dbinfo,   DBINFO);
  fix_objs (&newtable, NEWTABLE);
  fix_objs (&newfield, NEWFIELD);
  fix_objs (&newkey,   NEWKEY);
  fix_objs (&doicons,  DOICONS);
  fix_objs (&formats,  FORMATS);
  fix_objs (&selmask,  SELMASK);
  fix_objs (&maskicon, MASKICON);
  fix_objs (&dbparams, DBPARAMS);
  fix_objs (&relrules, RELRULES);
  fix_objs (&selfield, SELFIELD);
  fix_objs (&selfill,  SELFILL);
  fix_objs (&selline,  SELLINE);
  fix_objs (&selgrid,  SELGRID);
  fix_objs (&selsize,  SELSIZE);
  fix_objs (&seltext,  SELTEXT);
  fix_objs (&objsize,  OBJSIZE);
  fix_objs (&picsize,  PICSIZE);
  fix_objs (&linesize, LINESIZE);
  fix_objs (&rbvalues, RBVALUES);
  fix_objs (&cbvalues, CBVALUES);
  fix_objs (&selsubm,  SELSUBM);
  fix_objs (&selbutto, SELBUTTO);
  fix_objs (&baccess,  BACCESS);
  fix_objs (&stdforma, STDFORMA);
  fix_objs (&maskinfo, MASKINFO);
  fix_objs (&tblinfo,  TBLINFO);
  fix_objs (&empty,    EMPTY);
  fix_objs (&helpmenu, HELPMENU);
  fix_objs (&habout,   HABOUT);

  if (desktop != NULL)                          /* Eigener Desktop */
  {
    if (desktop->ob_width < MIN_WDESK) desktop->ob_width = MIN_WDESK; /* FÅr niedrige Auflîsung */

    if (class_desk == DESK)
    {
      if ((desktop->ob_width > desk.x + desk.w) ||
          (desktop->ob_height > desk.y + desk.h)) class_desk = DESKWINDOW; /* Desktop im Fenster */
    } /* if */

    if (colors > 8) desktop->ob_spec = 0x117BL; /* DunkelgrÅner Desktop */

    if (colors > 8)
    {
      doicons [DICNBOX].ob_spec   = 0xFF1178L;  /* Icon Box grau */
      newtable [NTICNBOX].ob_spec = 0xFF1178L;
    } /* if */

    if (desk.x + desk.w > desktop->ob_width)    /* Falls Desktop breiter Objektbreite */
      desktop->ob_width = desk.x + desk.w;      /* Groûe Bildschirme */

    if (desk.y + desk.h > desktop->ob_height)   /* Falls Desktop hîher Objekthîhe */
      desktop->ob_height = desk.y + desk.h;     /* Groûe Bildschirme */

    desktop [FKEYS].ob_y = desk.y + ((desk.h - desktop [FKEYS].ob_height) & 0xFFF8);

    if (desk.w > MIN_WDESK)                     /* FÅr groûe Bildschirme */
      desktop [FKEYS].ob_x += (desk.w - MIN_WDESK) / 2; /* Zentrieren */

    if (is_flags (desktop, FKEYS, HIDETREE))
      y = desk.h - desktop [ITRASH].ob_height;
    else
      y = desktop [FKEYS].ob_y - desk.y - 8 - desktop [ITRASH].ob_height;

    y &= 0xFFF8;                             /* Auf Bytegrenzen */
    y += desk.y;                             /* Relativ zum Desktop */
    y += odd (desk.y);                       /* Nur gerade Zahlen */

    for (i = ITRASH; i < FKEYS; i++)
    {
      do_flags (desktop, i, HIDETREE);
      desktop [i].ob_y = y;
    } /* for */
  } /* if */

  return (TRUE);
} /* init_resource */

/*****************************************************************************/
/* Terminieren des Moduls                                                    */
/*****************************************************************************/

GLOBAL BOOLEAN term_resource ()

{
  BOOLEAN ok;

  ok = TRUE;

#if (RSC_CREATE == 0)
  ok = rsrc_free () != 0;               		/* Resourcen freigeben 						*/
/* [GS] 5.1d Start */
#else
	#if INTERFACE
		ok = xrsrc_free ( xrsrc_array ) != 0;   /* Resourcen freigeben 					 */
	#endif
/* Ende */
#endif

  return (ok);
} /* term_resource */

/*****************************************************************************/

GLOBAL VOID switch_trees_3d ()
{
  SwitchTree3D (userimg);
  SwitchTree3D (menu);
  SwitchTree3D (about);
  SwitchTree3D (moreinfo);
  SwitchTree3D (desktop);
  SwitchTree3D (alert);
  SwitchTree3D (selfile);
  SwitchTree3D (selpath);
  SwitchTree3D (selfont);
  SwitchTree3D (helpinx);
  SwitchTree3D (popups);
  SwitchTree3D (config);
  SwitchTree3D (params);
  SwitchTree3D (userintr);
  SwitchTree3D (opendb);
  SwitchTree3D (basemenu);
  SwitchTree3D (maskmenu);
  SwitchTree3D (dbicons);
  SwitchTree3D (dbinfo);
  SwitchTree3D (newtable);
  SwitchTree3D (newfield);
  SwitchTree3D (newkey);
  SwitchTree3D (doicons);
  SwitchTree3D (formats);
  SwitchTree3D (selmask);
  SwitchTree3D (maskicon);
  SwitchTree3D (dbparams);
  SwitchTree3D (relrules);
  SwitchTree3D (selfield);
  SwitchTree3D (selfill);
  SwitchTree3D (selline);
  SwitchTree3D (selgrid);
  SwitchTree3D (selsize);
  SwitchTree3D (seltext);
  SwitchTree3D (objsize);
  SwitchTree3D (picsize);
  SwitchTree3D (linesize);
  SwitchTree3D (rbvalues);
  SwitchTree3D (cbvalues);
  SwitchTree3D (selsubm);
  SwitchTree3D (selbutto);
  SwitchTree3D (baccess);
  SwitchTree3D (stdforma);
  SwitchTree3D (maskinfo);
  SwitchTree3D (tblinfo);
  SwitchTree3D (empty);
  SwitchTree3D (helpmenu);
  SwitchTree3D (habout);
} /* switch_trees_3d */

/*****************************************************************************/

LOCAL VOID fix_objs (treep, tree_id)
OBJECT **treep;
WORD   tree_id;

{
#if RSC_CREATE
  *treep = (OBJECT *)rs_trindex [tree_id];
#else

/* [GS] 5.1d Start */
	#if INTERFACE
		xrsrc_gaddr (R_TREE, tree_id, treep , xrsrc_array );
	#else
	  rsrc_gaddr (R_TREE, tree_id, treep);
	 #endif
/* Ende; alt:
  rsrc_gaddr (R_TREE, tree_id, treep);
*/
#endif

  FixTree (*treep);
} /* fix_objs */

/*****************************************************************************/

