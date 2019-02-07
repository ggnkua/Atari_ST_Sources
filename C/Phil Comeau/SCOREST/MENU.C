/* menu: Library of menu-manipulation functions for Score
 * phil comeau 19-jan-88
 * last edited 15-jul-89 0006
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <mylib.h>
#include <graphics.h>
#include "graph.h"
#include "scorest.h"
#include "menu.h"

/* Menu Action Tables: tables of actions that are executed when a menu
 * event occurs.
 */
MNUACT InitMnuAct[] = {		/* Initial menu state. */
	{SELMNUITM, INFOITM},
	{SELMNUITM, OPENITM},
	{SELMNUITM, NEWITM},
	{DESELMNUITM, SVITM},
	{DESELMNUITM, SVASITM},
	{DESELMNUITM, CLSITM},
	{DESELMNUITM, PRTFITM},
	{DESELMNUITM, PRTDITM},
	{SELMNUITM, QUITITM},
	{DESELMNUITM, COPYITM},
	{DESELMNUITM, CUTITM},
	{DESELMNUITM, PSTITM},
	{DESELMNUITM, ERAITM},
	{SELMNUITM, LNWDITM},
	{SELMNUITM, LNPATITM},
	{SELMNUITM, LNENDITM},
	{SELMNUITM, TXTSZITM},
	{SELMNUITM, TXTATITM},
	{SELMNUITM, GRIDITM},
	{CHKMNUITM, GRIDITM},
	{DESELMNUITM, CRTPGITM},
	{DESELMNUITM, DELPGITM},
	{DESELMNUITM, TOPGITM},
	{DESELMNUITM, PRVPGITM},
	{DESELMNUITM, NXTPGITM},
	{DESELMNUITM, FSTPGITM},
	{DESELMNUITM, LSTPGITM},
	{-1, 0}
};

MNUACT FOpenMnuAct[] = {		/* file opened/new file created */
	{DESELMNUITM, OPENITM},
	{DESELMNUITM, NEWITM},
	{SELMNUITM, SVITM},
	{SELMNUITM, SVASITM},
	{SELMNUITM, CLSITM},
	{SELMNUITM, PRTFITM},
	{SELMNUITM, PRTDITM},
	{SELMNUITM, CRTPGITM},
	{SELMNUITM, DELPGITM},
	{SELMNUITM, TOPGITM},
	{SELMNUITM, PRVPGITM},
	{SELMNUITM, NXTPGITM},
	{SELMNUITM, FSTPGITM},
	{SELMNUITM, LSTPGITM},
	{-1, 0}
};

MNUACT FCloseMnuAct[] = {	/* current file closed. */
	{SELMNUITM, OPENITM},
	{SELMNUITM, NEWITM},
	{DESELMNUITM, SVITM},
	{DESELMNUITM, SVASITM},
	{DESELMNUITM, CLSITM},
	{DESELMNUITM, PRTFITM},
	{DESELMNUITM, PRTDITM},
	{DESELMNUITM, CRTPGITM},
	{DESELMNUITM, DELPGITM},
	{DESELMNUITM, TOPGITM},
	{DESELMNUITM, PRVPGITM},
	{DESELMNUITM, NXTPGITM},
	{DESELMNUITM, FSTPGITM},
	{DESELMNUITM, LSTPGITM},
	{-1, 0}
};

MNUACT CutMnuAct[] = {		/* something cut from page */
	{SELMNUITM, PSTITM},
	{-1, 0}
};

MNUACT SelMnuAct[] = {		/* something selected on page */
	{SELMNUITM, COPYITM},
	{SELMNUITM, CUTITM},
	{SELMNUITM, ERAITM},
	{-1, 0}
};

MNUACT DeSelMnuAct[] = {	/* selected things deselected */
	{DESELMNUITM, COPYITM},
	{DESELMNUITM, CUTITM},
	{DESELMNUITM, ERAITM},
	{-1, 0}
};

MNUACT PstOffMnuAct[] = {	/* cut/paste buffer cleared, so there's */
	{DESELMNUITM, PSTITM},	/* nothing to paste */
	{-1, 0}
};

MNUACT GridOnMnuAct[] = {	/* Show Grid selected */
	{CHKMNUITM, GRIDITM},
	{-1, 0}
};

MNUACT GridOffMnuAct[] = {	/* Show Grid deselected */
	{UNCHKMNUITM, GRIDITM},
	{-1, 0}
};

MNUACT DeskMnuAct[] = {		/* item selected on Desk menu */
	{RESTOREMNU, DESKMNU},
	{-1, 0}
};

MNUACT FileMnuAct[] = {		/* item selected on File menu */
	{RESTOREMNU, FILEMNU},
	{-1, 0}
};

MNUACT EditMnuAct[] = {		/* item selected on Edit menu */
	{RESTOREMNU, EDITMNU},
	{-1, 0}
};

MNUACT OptMnuAct[] = {		/* item selected on Option menu */
	{RESTOREMNU, OPTMNU},
	{-1, 0}
};

MNUACT PgMnuAct[] = {		/* item selected on Page menu */
	{RESTOREMNU, PAGEMNU},
	{-1, 0}
};

MNUACT NPrtMnuAct[] = {		/* Printing is disabled */
	{DESELMNUITM, PRTFITM},
	{DESELMNUITM, PRTDITM},
	{-1, 0}
};

extern int showInfo(), openFile(), newFile(), saveFile(), svAsFile(),
	closeFile(), printFileD(), printFileF(), quitFile(), copyEdit(),
	cutEdit(), pasteEdit(), eraseEdit(), lnWdOpt(), lnPatOpt(),
	lnEndOpt(), txtSzOpt(), txtAtOpt(), gridOpt(), createPage(),
	delPage(), gotoPage(), gotoPrvPage(), gotoNxtPage(), goto1stPage(),
	gotoLstPage();

/* Menu Function Table. */
static MNUFUNC MenuFunc[] = {
	{DESKMNU, INFOITM, TRUE, showInfo, DeskMnuAct},
	{FILEMNU, OPENITM, TRUE, openFile, FileMnuAct},
	{FILEMNU, NEWITM, TRUE, newFile, FileMnuAct},
	{FILEMNU, SVITM, TRUE, saveFile, FileMnuAct},
	{FILEMNU, SVASITM, TRUE, svAsFile, FileMnuAct},
	{FILEMNU, CLSITM, TRUE, closeFile, FileMnuAct},
	{FILEMNU, PRTDITM, TRUE, printFileD, FileMnuAct},
	{FILEMNU, PRTFITM, TRUE, printFileF, FileMnuAct},
	{FILEMNU, QUITITM, TRUE, quitFile, FileMnuAct},
	{EDITMNU, COPYITM, TRUE, copyEdit, EditMnuAct},
	{EDITMNU, CUTITM, TRUE, cutEdit, EditMnuAct},
	{EDITMNU, PSTITM, TRUE, pasteEdit, EditMnuAct},
	{EDITMNU, ERAITM, TRUE, eraseEdit, EditMnuAct},
	{OPTMNU, LNWDITM, TRUE, lnWdOpt, OptMnuAct},
	{OPTMNU, LNPATITM, TRUE, lnPatOpt, OptMnuAct},
	{OPTMNU, LNENDITM, TRUE, lnEndOpt, OptMnuAct},
	{OPTMNU, TXTSZITM, TRUE, txtSzOpt, OptMnuAct},
	{OPTMNU, TXTATITM, TRUE, txtAtOpt, OptMnuAct},
	{OPTMNU, GRIDITM, TRUE, gridOpt, OptMnuAct},
	{PAGEMNU, CRTPGITM, TRUE, createPage, PgMnuAct},
	{PAGEMNU, DELPGITM, TRUE, delPage, PgMnuAct},
	{PAGEMNU, TOPGITM, TRUE, gotoPage, PgMnuAct},
	{PAGEMNU, PRVPGITM, TRUE, gotoPrvPage, PgMnuAct},
	{PAGEMNU, NXTPGITM, TRUE, gotoNxtPage, PgMnuAct},
	{PAGEMNU, FSTPGITM, TRUE, goto1stPage, PgMnuAct},
	{PAGEMNU, LSTPGITM, TRUE, gotoLstPage, PgMnuAct},
	{-1}	/* end of table */
};

static OBJECT *MenuBar;			/* menu bar object pointer */

/* Forward references. */
static MNUFUNC *findMenuFunc();

extern FILE *Debug;

/* initMenu: Initially display the menu bar. */
initMenu()
{
	extern RECT2D DeskScsRct;

	/* Get a pointer to the menu bar object structure. */
	if (rsrc_gaddr(R_TREE, MENUBAR, &MenuBar) == 0) {
		Error("Resource file is corrupt.");
	}

	/* Display the menu bar. */
	menu_bar(MenuBar, TRUE);

	/* Set the menu items to their initial states. */

	execMnuAct(InitMnuAct);
}

/* execMnuAct: Execute a list of actions corresponding to a change in the
 * program's status.
 */
execMnuAct(mnuAct)
MNUACT mnuAct[];
{
	register MNUACT *pMnuAct;
	register MNUFUNC *pMnuFunc;

	/* Execute all the actions associated with the event. */
	for (pMnuAct = mnuAct; pMnuAct->action >= 0; ++pMnuAct) {
		pMnuFunc = findMenuFunc(pMnuAct->menu);
		switch (pMnuAct->action) {
		case SELMNUITM:

			/* Make the specified item selectable. */
			menu_ienable(MenuBar, pMnuAct->menu, TRUE);
			pMnuFunc->enabled = TRUE;
			break;
		case DESELMNUITM:

			/* Prevent the specified item from being selected. */
			menu_ienable(MenuBar, pMnuAct->menu, FALSE);
			pMnuFunc->enabled = FALSE;
			break;
		case RESTOREMNU:

			/* Restore a menu's title to normal video after
			 * one of its items was selected.
			 */
			menu_tnormal(MenuBar, pMnuAct->menu, TRUE);
			break;
		case CHKMNUITM:

			/* Place a check mark beside a menu item. */
			menu_icheck(MenuBar, pMnuAct->menu, TRUE);
			break;
		case UNCHKMNUITM:

			/* Remove a check mark from a menu item. */
			menu_icheck(MenuBar, pMnuAct->menu, FALSE);
			break;
		}
	}
}

/* execMnuFunc:	Invoke a function associated with a menu item. */
execMnuFunc(menu, menuItm)
register int menu, menuItm;
{
	MNUFUNC *pFuncTbl;

	pFuncTbl = findMenuFunc(menuItm);
	if (pFuncTbl != NULL && pFuncTbl->enabled) {

		/* Invoke the function. */
		(*pFuncTbl->menuFunc)();

		/* Perform the menu action associated with making a
		 * selection from this menu.
		 */
		execMnuAct(pFuncTbl->menuAct);
	}
}

/* closeMenu: Remove the menu bar from the screen. */
closeMenu()
{
	menu_bar(MenuBar, FALSE);
}

/* findMenuFunc:	Locate the Menu Function table entry associated
 *			with a menu item.
 */
static MNUFUNC *findMenuFunc(menuItm)
register int menuItm;
{
	register MNUFUNC *pFuncTbl;

	/* Locate the indicated menu item in the Menu Function table. */
	for (pFuncTbl = MenuFunc; pFuncTbl->menu >= 0 &&
	    pFuncTbl->menuItm != menuItm; ++pFuncTbl) {
		/* Do nothing. */
	}

	return (pFuncTbl->menu >= 0 ? pFuncTbl : NULL);
}