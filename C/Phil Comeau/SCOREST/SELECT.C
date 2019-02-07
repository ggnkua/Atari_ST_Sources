/* select: Functions supporting entity selection and operations on selected
 * entities in Score music layout program.
 * phil comeau 26-feb-88
 * last edited 11-oct-89 0007
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <mylib.h>
#include <list.h>
#include <graphics.h>
#include "page.h"
#include "graph.h"
#include "symbol.h"
#include "entity.h"
#include "scoredef.h"
#include "menu.h"

#define MINSELRCTDIM 10			/* smallest permissible selection
					 * rectangle dimension.
					 */

extern FILE *Debug;

/* Global variables */
static LIST SelList;			/* List of selected entities. */
static RECT2D SelRct;			/* Current selection rectangle. */
static LINESTYLE SelRctLnStyle =	/* Selection rectangle line style */
    {1, SQUAREEND, SOLIDLNPAT};

/* initSel: Initialize the selection mechanisms by initializing the
 * selection list.
 */
initSel()
{
	extern int cmpEnt();

	ListCreate(&SelList, cmpEnt);
}

/* msInSelRct: Determine if the mouse is positioned inside the selection
 * rectangle.
 */
BOOLEAN msInSelRct(msPos)
register POINT2D *msPos;
{
	extern BOOLEAN isActvSelPg();

	return (isActvSelPg() && POINTINRECT(msPos, &SelRct));
}

/* selRctLROk: Determine if a new lower-right corner position for the
 * selection rectangle is acceptable.
 */
BOOLEAN selRctLROk(msPos)
register POINT2D *msPos;
{
	extern BOOLEAN isActvSelPg();

	return (isActvSelPg() && msPos->x > SelRct.x &&
	    msPos->y > SelRct.y);
}

/* mvSelEnts: Move all currently-selected entities to a new page location
 * specified by the user.
 */
mvSelEnts(oldMsPos)
POINT2D *oldMsPos;
{
	POINT2D newMsPos, offset;
	LIST selEntLst;
	register LISTNODE *pLst;
	register ENTITY *ent;
	RECT2D scsSelRct, orgClipRct, clipRct;
	extern int freeEnt(), rect_intersect(), cmpEnt();
	BOOLEAN cpSelList();
	extern MNUACT SelMnuAct[];
	extern RECT2D WinScsRct;

	WCSRCTTOSCS(&SelRct, &scsSelRct);

	/* Make a list containing copies of all the selected entities.
	 * We're about to delete them, but we need to keep them around so
	 * we can modify their positions.
	 */
	ListCreate(&selEntLst, cmpEnt);
	if (!cpSelList(&selEntLst)) {
		ListDestroy(&selEntLst, freeEnt);
		return;
	}

	/* Delete the selected entities. Note that this deletes the
	 * entities themselves, but doesn't alter the selection list.
	 */
	delAllSelEnts();

	/* Clean out the contents of the selection rectangle by setting
	 * the clipping rectangle to the selection rectange and redrawing
	 * the page. Also hide the selection rectangle so it doesn't get
	 * in the user's way.
	 */
	rect_intersect(scsSelRct, WinScsRct, &clipRct);
	setClipRct(&clipRct);
	hideSelRct();
	actvSelPg(FALSE);
	drwPg();
	setClipRct(&WinScsRct);
	
	/* Draw the entities in XOR mode. This is necessary because they
	 * will be drawn in XOR when they're moved, and if we don't leave
	 * an XOR image on the screen to erase, garbage images will appear.
	 */
	hideMouse();
	drwEntsInLst(&selEntLst, MD_XOR);
	showMouse();

	/* Let the user drag the entities to their new location. */
	WCSPTTOSCS(oldMsPos, oldMsPos);
	dragEntsInLst(&selEntLst, oldMsPos, &offset);

	/* Re-add each entity to the current page, which effectively moves
	 * it to the new position.
	 */
	for (pLst = ListNext(&selEntLst.head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		ent = (ENTITY *)ListContents(pLst);
		addEntPg(ent);
	}

	/* Delete the copy list of selected entities. */
	ListDestroy(&selEntLst, freeEnt);

	/* Clean up the selection list. */
	deselAllEnts();

	/* Redraw the selection rectangle at the new place. */
	MOVERECT(&SelRct, offset.x, offset.y);
	MOVERECT(&scsSelRct, offset.x, offset.y);
	reDrwSelRct();

	/* Reselect the entities inside the selection rectangle. */
	selEntsInRct();
	actvSelPg(TRUE);
	execMnuAct(SelMnuAct);

	/* Redraw the screen area inside the selection rectangle. */
	setWrtMode(MD_REPLACE);
	rect_intersect(scsSelRct, WinScsRct, &clipRct);
	setClipRct(&clipRct);
	drwPg();
	setClipRct(&WinScsRct);
}

/* mvSelEntsKey: Move the selected entities by an amount and direction
 * given by an arrow keypress.
 */
mvSelEntsKey(keyChar)
int keyChar;
{
	POINT2D offset;
	LIST selEntLst;
	register LISTNODE *pLst;
	register ENTITY *ent;
	RECT2D scsSelRct, orgClipRct, clipRct;
	BOOLEAN cpSelList(), isSelRctVis();
	extern MNUACT SelMnuAct[];
	extern int freeEnt(), rect_intersect(), cmpEnt();
	extern RECT2D WinScsRct;
	extern BOOLEAN isActvSelPg();

	if (!isActvSelPg()) {
		return;
	}

	/* Determine how the selected entities will be moved. */
	SETPOINT(&offset, 0, 0);
	switch (keyChar) {
	case LARROWKEY:
		offset.x = -STAFFSPHT / 2;
		break;
	case RARROWKEY:
		offset.x = STAFFSPHT / 2;
		break;
	case UARROWKEY:
		offset.y = -STAFFSPHT / 2;
		break;
	case DARROWKEY:
		offset.y = STAFFSPHT / 2;
		break;
	case S_LARROWKEY:
		offset.x = -1;
		break;
	case S_RARROWKEY:
		offset.x = 1;
		break;
	case S_UARROWKEY:
		offset.y = -1;
		break;
	case S_DARROWKEY:
		offset.y = 1;
		break;
	}

	WCSRCTTOSCS(&SelRct, &scsSelRct);

	/* Make a list containing copies of all the selected entities.
	 * We're about to delete them, but we need to keep them around so
	 * we can modify their positions.
	 */
	ListCreate(&selEntLst, cmpEnt);
	if (!cpSelList(&selEntLst)) {
		ListDestroy(&selEntLst, freeEnt);
		return;
	}

	/* Delete the selected entities. Note that this deletes the
	 * entities themselves, but doesn't alter the selection list.
	 */
	delAllSelEnts();

	/* Clean out the contents of the selection rectangle by setting
	 * the clipping rectangle to the selection rectange and redrawing
	 * the page. Also hide the selection rectangle so it doesn't get
	 * in the user's way.
	 */
	if (isSelRctVis()) {
		rect_intersect(scsSelRct, WinScsRct, &clipRct);
		setClipRct(&clipRct);
		hideSelRct();
		actvSelPg(FALSE);
		drwPg();
		setClipRct(&WinScsRct);
	}

	/* Change each entity's origin by the offset, then re-add each
	 * entity to the current page, which effectively moves
	 * it to the new position.
	 */
	for (pLst = ListNext(&selEntLst.head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		ent = (ENTITY *)ListContents(pLst);
		mvEnt(ent, &offset);
		addEntPg(ent);
	}

	/* Delete the copy list of selected entities. */
	ListDestroy(&selEntLst, freeEnt);

	/* Clean up the selection list. */
	deselAllEnts();

	/* Redraw the selection rectangle at the new place. */
	MOVERECT(&SelRct, offset.x, offset.y);
	MOVERECT(&scsSelRct, offset.x, offset.y);
	reDrwSelRct();

	/* Reselect the entities inside the selection rectangle. */
	selEntsInRct();
	actvSelPg(TRUE);
	execMnuAct(SelMnuAct);

	/* Redraw the screen area inside the selection rectangle. */
	if (isSelRctVis()) {
		setWrtMode(MD_REPLACE);
		rect_intersect(scsSelRct, WinScsRct, &clipRct);
		setClipRct(&clipRct);
		drwPg();
		setClipRct(&WinScsRct);
	}
}

/* drawSelRct: Draw a selection rectangle by tracking the mouse. */
drawSelRct(msPos)
register POINT2D *msPos;
{
	RECT2D selRct;

	SETRECT(&selRct, msPos->x, msPos->y, 0, 0);
	WCSRCTTOSCS(&selRct, &selRct);
	graf_rubberbox(selRct.x, selRct.y, 1, 1, &selRct.w,
	    &selRct.h);
	SCSRCTTOWCS(&selRct, &selRct);
	selRct.w = MAX(selRct.w, MINSELRCTDIM);
	selRct.h = MAX(selRct.h, MINSELRCTDIM);
	setSelRct(&selRct);
}

/* setSelRct: Set the selection rectangle to rct */
setSelRct(rct)
register RECT2D *rct;
{
	extern MNUACT SelMnuAct[];

	COPYRECT(rct, &SelRct);
	reDrwSelRct();
	actvSelPg(TRUE);
	execMnuAct(SelMnuAct);
}

/* chgSelRctLR: Change the lower-right corner of the selection rectangle. */
chgSelRctLR(msPos)
register POINT2D *msPos;
{
	RECT2D selRct;
	POINT2D newPos;
	int msBtn, key;

	COPYRECT(&SelRct, &selRct);

	/* Determine if the mouse is still down. */
	graf_mkstate(&newPos.x, &newPos.y, &msBtn, &key);
	if ((msBtn & LEFTBUTTON) != 0) {

		/* It's still down. Let the user drag the new position. */
		WCSRCTTOSCS(&selRct, &selRct);
		graf_rubberbox(selRct.x, selRct.y, 1, 1, &selRct.w,
		    &selRct.h);
		SCSRCTTOWCS(&selRct, &selRct);
	}
	else {

		/* He just clicked. Set the new lower-right corner. */
		selRct.w = msPos->x - selRct.x;
		selRct.h = msPos->y - selRct.y;
	}
	selRct.w = MAX(selRct.w, MINSELRCTDIM);
	selRct.h = MAX(selRct.h, MINSELRCTDIM);
	setSelRct(&selRct);
}

/* selEntsInRct: Select all entities inside the current selection
 * rectangle.
 */
selEntsInRct()
{
	register LISTNODE *pEntLst;
	register ENTITY *ent;
	static MSFORM busyMsForm = {HOURGLASS, {0}};
	extern PAGE *CurPage;
	extern BOOLEAN rctInRct();

	/* Check all the entities on this page. */
	svMsForm();
	setMsForm(&busyMsForm);
	if (CurPage != NULL) {
		for (pEntLst = ListNext(&CurPage->pgEntLst.head);
		    pEntLst != NULL; pEntLst = ListNext(pEntLst)) {
			ent = (ENTITY *)ListContents(pEntLst);
			if (rctInRct(&ent->entRct, &SelRct)) {
				selEnt(ent);
			}
		}
	}
	rstMsForm();
}

/* isEntSel: Return TRUE if an entity is currently selected. */
BOOLEAN isEntSel(ent)
register ENTITY *ent;
{
	return (ListFind(&SelList, ent) != NULL);
}

/* selEnt: Add an entity to list of selected entities. */
selEnt(ent)
register ENTITY *ent;
{
	(void)ListAdd(&SelList, ent);
}

/* deselEnt: Remove an entity from the list of selected entities. */
deselEnt(ent)
register ENTITY *ent;
{
	(void)ListDelete(&SelList, ent);
}

/* deselect: Remove the selection rectangle and deselect any selected
 * entities.
 */
deselect()
{
	RECT2D scsSelRct, clipRct;
	BOOLEAN isSelRctVis();
	extern BOOLEAN isActvSelPg();
	extern MNUACT DeSelMnuAct[];
	extern int rect_intersect();
	extern RECT2D WinScsRct;

	deselAllEnts();
	execMnuAct(DeSelMnuAct);
	if (isActvSelPg() && isSelRctVis()) {
		WCSRCTTOSCS(&SelRct, &scsSelRct);
		rect_intersect(scsSelRct, WinScsRct, &clipRct);
		setClipRct(&clipRct);
		actvSelPg(FALSE);
		drwPg();
		setClipRct(&WinScsRct);
	}
}
	
/* deselAllEnts: Deselect all currently-selected entities. */
deselAllEnts()
{
	register LISTNODE *pLst;
	register ENTITY *ent;
	static MSFORM busyMsForm = {HOURGLASS, {0}};

	svMsForm();
	setMsForm(&busyMsForm);
	for (pLst = ListNext(&SelList.head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		ent = (ENTITY *)ListContents(pLst);
		(void)ListDelete(&SelList, ent);
	}
	rstMsForm();
}

/* cpSelList: Make a copy of the selection list, including a copy of
 * each entity it references. Returns TRUE if the list was copied
 * successfully. The list must have been previously initialized.
 */
BOOLEAN cpSelList(selListCp)
LIST *selListCp;
{
	extern BOOLEAN cpEntLst();

	return (cpEntLst(&SelList, selListCp));
}

/* delAllSelEnts: Delete all selected entities. */
delAllSelEnts()
{
	register LISTNODE *pSelLst;
	static MSFORM busyMsForm = {HOURGLASS, {0}};

	svMsForm();
	setMsForm(&busyMsForm);
	for (pSelLst = ListNext(&SelList.head); pSelLst != NULL;
	    pSelLst = ListNext(pSelLst)) {
		delEntPg((ENTITY *)ListContents(pSelLst));
	}
	rstMsForm();
}

/* reDrwSelRct: Redraw the selection rectangle. */
reDrwSelRct()
{
	RECT2D scsSelRct;
	BOOLEAN isSelRctVis();

	if (isSelRctVis()) {
		WCSRCTTOSCS(&SelRct, &scsSelRct);
		hideMouse();
		rstCopy(S_OR_NOTD, NULL, &scsSelRct, NULL, &scsSelRct);
		showMouse();
	}
}

/* hideSelRct: Remove the selection rectangle from view. */
hideSelRct()
{
	RECT2D scsSelRct;

	/* Just invert what reDrwSelRct does. */
	reDrwSelRct();
}

/* cpSelRct: Return a copy of the selection rectangle. */
cpSelRct(rct)
RECT2D *rct;
{
	COPYRECT(&SelRct, rct);
}

/* isSelRctVis: Return TRUE if any part of the selection rectangle is
 * visible.
 */
BOOLEAN isSelRctVis()
{
	RECT2D junk;
	extern RECT2D WinWcsRct;

	return (rect_intersect(SelRct, WinWcsRct, &junk));
}
