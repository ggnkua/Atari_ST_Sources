/*****************************************************************************
 *
 * Module : RESOURCE.C
 * Author : Dieter Geiû
 *
 * Creation date    : 01.07.89
 * Last modification:
 *
 *
 * Description: This module implements the resources.
 *
 * History:
 * 04.01.04: Alle normlen rsrc_xxx Funktionen durch xrsrc_xxx ersetzt, damit
 *           Resourcen grîûer > 64KBytes bearbeitet werden kînnen.
 * 27.10.02: Neues Formular NEWPROCMENU_NEW erstellt
 *					 Neues Formular NEWPROCMENU_LIST erstellt
 * 28.05.02: RSC_CREATE auf 0 gesetzt, RSC_NAME Resourcename klein geschrieben.
 * 10.12.96: Object tree previcon added
 * 09.07.95: Object tree accicon added
 * 31.12.94: Using new function names of controls module
 * 08.12.94: Object tree getparm added
 * 19.11.94: No longer using ob_spec but get_ob_spec
 * 17.11.94: Initializing xrsrc module in init_resource
 * 24.09.94: No longer needing rsc_create
 * 19.03.94: Object tree copies added
 * 05.12.93: Object tree selpath added
 * 02.11.93: Object trees selfile and selfont added
 * 03.10.93: Background of dialog box is set according to sys_colors
 * 02.10.93: Object tree userintr added
 * 19.09.93: Y position of database combobox no longer corrected in low resolution
 * 16.09.93: Function switch_trees_3d added
 * 01.09.93: LISTICON added
 * 30.08.93: QBEICON added
 * 26.08.93: Modifications for user defined buttons added
 * 01.07.89: Creation of body
 *****************************************************************************/

#ifndef RSC_CREATE
#define RSC_CREATE 0                    /* Resource-File im Code */
#endif

#ifndef INTERFACE
#define INTERFACE 1                     /* Interface Resource Editor */
#endif

#include "import.h"
#include "global.h"

#include "manager.h"


#include "controls.h"

/* [GS] 5.1d Start: */
#include "xrsrc.h"
/* Ende */

#if RSC_CREATE
#if INTERFACE
#include "manager.rh"
#else
#include "rcm.h"
#endif
#include "manager.rsh"
                                        /* In RSH-Dateien fehlt das letzte CR/LF */
#endif

#include "export.h"
#include "resource.h"

/****** DEFINES **************************************************************/

#ifndef RSC_NAME
#define RSC_NAME   "manager.rsc"        /* Name der Resource-Datei */
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
  WORD    i, y;
  ICONBLK *p1, *p2;
	BYTE *str;
	WORD ap_gout1, ap_gout2, ap_gout3, ap_gout4;
	MENU mdata;

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
  EXTERN BOOLEAN init_xrsrc (WORD vdi_handle, RECT *desk, WORD gl_wbox, WORD gl_hbox);
*/
  init_xrsrc (vdi_handle, &desk, gl_wbox, gl_hbox);
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

  fix_objs (&menu,     MENUE);
  fix_objs (&userimg,  USERIMG);
  fix_objs (&about,    ABOUT);
  fix_objs (&desktop,  DESKTOP);
  fix_objs (&alert,    ALERT);
  fix_objs (&selfile,  SELFILE);
  fix_objs (&selpath,  SELPATH);
  fix_objs (&selfont,  SELFONT);
  fix_objs (&helpinx,  HELPINX);
  fix_objs (&popup,    POPUP);
  fix_objs (&popups,   POPUPS);
  fix_objs (&icons,    ICONS);
  fix_objs (&listwidt, LISTWIDT);
  fix_objs (&months,   MONTHS);
  fix_objs (&loaddb,   LOADDB);
  fix_objs (&flushkey, FLUSHKEY);
  fix_objs (&infmeta,  INFMETA);
  fix_objs (&moreinfo, MOREINFO);
  fix_objs (&selbox,   SELBOX);
  fix_objs (&config,   CONFIG);
  fix_objs (&imexparm, IMEXPARM);
  fix_objs (&cfgprn,   CFGPRN);
  fix_objs (&queue,    QUEUE);
  fix_objs (&pageform, PAGEFORM);
  fix_objs (&userintr, USERINTR);
  fix_objs (&procbox,  PROCBOX);
  fix_objs (&opendb,   OPENDB);
  fix_objs (&dbinfo,   DBINFO);
  fix_objs (&tblinfo,  TBLINFO);
  fix_objs (&inxinfo,  INXINFO);
  fix_objs (&params,   PARAMS);
  fix_objs (&getparm,  GETPARM);
  fix_objs (&lockscrn, LOCKSCRN);
  fix_objs (&chngpass, CHNGPASS);
  fix_objs (&delrecs,  DELRECS);
  fix_objs (&remsel,   REMSEL);
  fix_objs (&copies,   COPIES);
  fix_objs (&clipname, CLIPNAME);
  fix_objs (&listsrch, LISTSRCH);
  fix_objs (&newwidth, NEWWIDTH);
  fix_objs (&order,    ORDER);
  fix_objs (&reorgpar, REORGPAR);
  fix_objs (&sorting,  SORTING);
  fix_objs (&statist,  STATIST);
  fix_objs (&newproc,  NEWPROC);
  fix_objs (&newprocmenu_new,  NEWPROCMENU_NEW);
  fix_objs (&newprocmenu_list,  NEWPROCMENU_LIST);
  fix_objs (&listicon, LISTICON);
  fix_objs (&qbeicon,  QBEICON);
  fix_objs (&rprticon, RPRTICON);
  fix_objs (&calcicon, CALCICON);
  fix_objs (&baticon,  BATICON);
  fix_objs (&accicon,  ACCICON);
  fix_objs (&previcon, PREVICON);
  fix_objs (&maskmenu, MASKMENU);
  fix_objs (&maskicon, MASKICON);
  fix_objs (&maskconf, MASKCONF);
  fix_objs (&join,     JOIN);
  fix_objs (&helpmenu, HELPMENU);
  fix_objs (&habout,   HABOUT);
/* [GS] 5.1f Start */
  fix_objs (&iconify_tree, WINICON);
/* Ende */
  if (dlg_colors >= 16)
  {
    undo_state (lockscrn, LOCKBOX, OUTLINED);
    lockscrn [LOCKBOX].ob_spec = 0x00011170L | sys_colors [COLOR_DIALOG];
  } /* if */
  else
  {
    do_state (lockscrn, LOCKBOX, OUTLINED);
    lockscrn [LOCKBOX].ob_spec = 0x00021100L;
  } /* else */

	if ( appl_xgetinfo ( 9, &ap_gout1, &ap_gout2, &ap_gout3, &ap_gout4 ) )
	{
		if ( ap_gout1 && ap_gout4 )
		{
			str = get_str ( menu, MPNEW );						/* MenÅkÅrzel lîschen		*/
      for (i = strlen (str); (i >= 0) && (str [i] != SP); i--);

      if ((i >= 0) && (strlen (str + i) >= 2))  /* Leerzeichen und ein Buchstabe */
      {
      	while ( *(str+i) != EOS )
      		*(str+ (i++)) = SP;
			} /* if */
			mdata.mn_tree  = newprocmenu_new;
			mdata.mn_menu  = ROOT;
			mdata.mn_item  = 1;
			mdata.mn_scroll= 0;
			menu_attach ( 1, menu, MPNEW, &mdata);
			str = get_str ( menu, MPLIST );						/* MenÅkÅrzel lîschen		*/
      for (i = strlen (str); (i >= 0) && (str [i] != SP); i--);

      if ((i >= 0) && (strlen (str + i) >= 2))  /* Leerzeichen und ein Buchstabe */
      {
      	while ( *(str+i) != EOS )
      		*(str+ (i++)) = SP;
			} /* if */
			mdata.mn_tree  = newprocmenu_list;
			mdata.mn_menu  = ROOT;
			mdata.mn_item  = 1;
			mdata.mn_scroll= 0;
			menu_attach ( 1, menu, MPLIST, &mdata);
		} /* if */
	} /* if */

  if (desktop != NULL)                          /* Eigener Desktop */
  {
    if (desktop->ob_width < MIN_WDESK) desktop->ob_width = MIN_WDESK; /* FÅr niedrige Auflîsung */

    if (class_desk == DESK)
    {
      if ((desktop->ob_width > desk.x + desk.w) ||
          (desktop->ob_height > desk.y + desk.h)) class_desk = DESKWINDOW; /* Desktop im Fenster */
    } /* if */

    if (colors > 8) desktop->ob_spec = 0x117BL; /* DunkelgrÅner Desktop */

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

    for (i = ITABLE; i < ITRASH; i++)
    {
      do_flags (desktop, i, HIDETREE);
      desktop [i].ob_y += desk.y + odd (desk.y);
    } /* for */

    for (i = ITRASH; i < FKEYS; i++) desktop [i].ob_y = y;

    p1 = (ICONBLK *)get_ob_spec (desktop, IPROCESS);

    for (i = IPROCESS + 1; i < ITRASH; i++)     /* Iconblocks angleichen */
    {
      p2 = (ICONBLK *)get_ob_spec (desktop, i);

      p2->ib_pmask = p1->ib_pmask;
      p2->ib_pdata = p1->ib_pdata;
      p2->ib_xicon = p1->ib_xicon;
      p2->ib_yicon = p1->ib_yicon;
      p2->ib_wicon = p1->ib_wicon;
      p2->ib_hicon = p1->ib_hicon;
    } /* for */

    desktop [DTABLES].ob_y = desk.y + 8;
    desktop [ICONBAR].ob_y = desk.y + 8;

    for (i = ICNEW; i < ITABLE; i++)
      desktop [i].ob_y = 4;

    desktop [ICONBAR].ob_width  = desktop [ICONBAR + 1].ob_width  = desktop [ITABLE - 1].ob_x + desktop [ITABLE - 1].ob_width + gl_wbox;
    desktop [ICONBAR].ob_height = desktop [ICONBAR + 1].ob_height = desktop [ICNEW].ob_y + desktop [ICNEW].ob_height + 4;
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
  ok = rsrc_free () != 0;               		/* Resourcen freigeben 					 */
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
  SwitchTree3D (desktop);
  SwitchTree3D (alert);
  SwitchTree3D (selfile);
  SwitchTree3D (selpath);
  SwitchTree3D (selfont);
  SwitchTree3D (helpinx);
  SwitchTree3D (popup);
  SwitchTree3D (popups);
  SwitchTree3D (icons);
  SwitchTree3D (listwidt);
  SwitchTree3D (months);
  SwitchTree3D (loaddb);
  SwitchTree3D (flushkey);
  SwitchTree3D (infmeta);
  SwitchTree3D (moreinfo);
  SwitchTree3D (selbox);
  SwitchTree3D (config);
  SwitchTree3D (imexparm);
  SwitchTree3D (cfgprn);
  SwitchTree3D (queue);
  SwitchTree3D (pageform);
  SwitchTree3D (userintr);
  SwitchTree3D (procbox);
  SwitchTree3D (opendb);
  SwitchTree3D (dbinfo);
  SwitchTree3D (tblinfo);
  SwitchTree3D (inxinfo);
  SwitchTree3D (params);
  SwitchTree3D (getparm);
  SwitchTree3D (lockscrn);
  SwitchTree3D (chngpass);
  SwitchTree3D (delrecs);
  SwitchTree3D (remsel);
  SwitchTree3D (copies);
  SwitchTree3D (clipname);
  SwitchTree3D (listsrch);
  SwitchTree3D (newwidth);
  SwitchTree3D (order);
  SwitchTree3D (reorgpar);
  SwitchTree3D (sorting);
  SwitchTree3D (statist);
  SwitchTree3D (newproc);
  SwitchTree3D (listicon);
  SwitchTree3D (qbeicon);
  SwitchTree3D (rprticon);
  SwitchTree3D (calcicon);
  SwitchTree3D (baticon);
  SwitchTree3D (accicon);
  SwitchTree3D (previcon);
  SwitchTree3D (maskmenu);
  SwitchTree3D (maskicon);
  SwitchTree3D (maskconf);
  SwitchTree3D (join);
  SwitchTree3D (helpmenu);
  SwitchTree3D (habout);
} /* switch_trees_3d */

/*****************************************************************************/

LOCAL VOID fix_objs (treep, tree_id)
OBJECT  **treep;
WORD    tree_id;

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

