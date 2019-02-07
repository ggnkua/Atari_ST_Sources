/* edit:	Functions involved in editing Scores (using the clipboard)
 * phil comeau 31-jan-88
 * last edited 10-oct-89 0008
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
#include "graph.h"
#include "menu.h"
#include "symbol.h"
#include "entity.h"

/* Global Variables */
BOOLEAN Pasting = FALSE;		/* TRUE if the user has asked to
					 * paste something.
					 */
static BOOLEAN ClipBoardActv = FALSE;	/* TRUE if there's something in the
					 * clipboard.
					 */
static RECT2D ClipBoardRct;		/* Defines clipboard area. */
static LIST ClipBoardLst;		/* List containing entities in the
					 * clipboard.
					 */

extern FILE *Debug;

/* copyEdit: Copy the currently-selected area into the clipboard without
 * removing it from the page.
 */
copyEdit()
{
	doCopy();
}

/* cutEdit: Copy the currently-selected area into the clipboard and
 * remove it from the page.
 */
cutEdit()
{
	RECT2D clipRct, orgClipRct, scsRct;
	extern int rect_intersect();

	doCopy();
	delAllSelEnts();
	deselect();
	getClipRct(&orgClipRct);
	WCSRCTTOSCS(&ClipBoardRct, &scsRct);
	rect_intersect(scsRct, orgClipRct, &clipRct);
	setClipRct(&clipRct);
	drwPg();
	setClipRct(&orgClipRct);
}

/* pasteEdit: (Prepare to) paste the contents of the clipboard onto the page.
 */
pasteEdit()
{
	int junk, msBtn;

	/* Set the Pasting switch. The next time the mouse is clicked
	 * over the window, rspBtnEvt will call doPaste, which will
	 * actually do the pasting.
	 */
	Pasting = TRUE;

	/* Wait for the mouse button to cool off. This is needed because
	 * of an apparent bug in the Megamax Shell, where mouse clicks
	 * appear to bounce.
	 */
	do {
		graf_mkstate(&junk, &junk, &msBtn, &junk);
	} while ((msBtn & LEFTBUTTON) != 0);
}

/* eraseEdit: Remove the currently-selected area from the page. */
eraseEdit()
{
	RECT2D clipRct, orgClipRct, scsRct;
	extern int rect_intersect();

	cpSelRct(&ClipBoardRct);
	delAllSelEnts();
	deselect();
	getClipRct(&orgClipRct);
	WCSRCTTOSCS(&ClipBoardRct, &scsRct);
	rect_intersect(scsRct, orgClipRct, &clipRct);
	setClipRct(&clipRct);
	drwPg();
	setClipRct(&orgClipRct);
}

/* doCopy: Copy the currently-selected stuff into the clipboard. */
doCopy()
{
	register LISTNODE *pLst;
	register ENTITY *ent;
	POINT2D offset;
	extern int freeEnt(), cmpEnt();
	extern MNUACT CutMnuAct[];

	if (ClipBoardActv) {

		/* Remove the clipboard contents. */
		ListDestroy(&ClipBoardLst, freeEnt);
	}
	else {

		/* The clipboard is virginal. Initialize it. */
		ListCreate(&ClipBoardLst, cmpEnt);
	}

	/* Obtain a copy of the selection list. */
	cpSelList(&ClipBoardLst);

	/* Obtain a copy of the selection rectangle. */
	cpSelRct(&ClipBoardRct);

	/* Modify the entities in the clipboard so their origins are
	 * relative to the cut/paste rectangle.
	 */
	for (pLst = ListNext(&ClipBoardLst.head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		ent =  (ENTITY *)ListContents(pLst);
		SETPOINT(&offset, -ClipBoardRct.x, -ClipBoardRct.y);
		mvEnt(ent, &offset);
	}
 
	/* Enable selection of the "paste" menu item. */
	execMnuAct(CutMnuAct);

	ClipBoardActv = TRUE;
}

/* doPaste: Paste the contents of the clipboard onto the page. */
doPaste(msPos)
register POINT2D *msPos;
{
	POINT2D offset;
	register LISTNODE *pLst;
	RECT2D scsRct, clipRct;
	LIST tmpClipBoardLst;
	extern RECT2D WinScsRct;
	extern int freeEnt(), cmpEnt();

	/* Make a copy of the clipboard. We have to change the entities
	 * contained within it, and we don't want to affect any subsequent
	 * pastes the user might make.
	 */
	ListCreate(&tmpClipBoardLst, cmpEnt);
	cpClipBoardLst(&ClipBoardLst, &tmpClipBoardLst);

	/* Adjust the origins of the entities in the clipboard. The entities
	 * are stored with their origins relative to the clipboard rectangle,
	 * so we have to move them so their origins are relative to the
	 * current mouse position.
	 */
	SCSPTTOWCS(msPos, &offset);
	for (pLst = ListNext(&tmpClipBoardLst.head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		mvEnt((ENTITY *)ListContents(pLst), &offset);
	}

	/* Draw the entities in XOR mode. This is necessary because they
	 * will be drawn in XOR when they're moved, and if we don't leave
	 * an XOR image on the screen to erase, garbage images will appear.
	 */
	hideMouse();
	drwEntsInLst(&tmpClipBoardLst, MD_XOR);
	showMouse();

	/* Let the user drag the entities to their new location. */
	dragEntsInLst(&tmpClipBoardLst, msPos, &offset);

	/* Re-add each entity to the current page, which effectively moves
	 * it to the new position.
	 */
	for (pLst = ListNext(&tmpClipBoardLst.head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		addEntPg((ENTITY *)ListContents(pLst));
	}

	/* Redraw the area of the screen around the pasted entities. Since
	 * the clipboard rectangle was set when the entities were cut or
	 * copied, we know this area will be equivalent to the *size* of the
	 * clipboard rectangle.
	 */
	setWrtMode(MD_REPLACE);
	SETRECT(&scsRct, msPos->x + offset.x, msPos->y + offset.y,
	    ClipBoardRct.w, ClipBoardRct.h);
	rect_intersect(scsRct, WinScsRct, &clipRct);
	setClipRct(&clipRct);
	drwPg();
	setClipRct(&WinScsRct);

	/* The user gets only one shot at pasting per request. */
	Pasting = FALSE;

	ListDestroy(&tmpClipBoardLst, freeEnt);
}

/* cpClipBoardLst: Copy the clipboard list */
cpClipBoardLst(srcLst, dstLst)
LIST *srcLst, *dstLst;
{
	cpEntLst(srcLst, dstLst);
}
