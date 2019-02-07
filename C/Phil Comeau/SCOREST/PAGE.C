/* page: library of page-related functions for Score
 * phil comeau 06-jan-88
 * last edited 11-oct-89 0010
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <mylib.h>
#include <dialog.h>
#include <list.h>
#include <graphics.h>
#include "graph.h"
#include "scoredef.h"
#include "symbol.h"
#include "page.h"
#include "entity.h"
#include "scorest.h"

/* Global Variables */
int NPages = 0;				/* Number of pages */
LIST PgLst;				/* List of active pages */
PAGE *CurPage = NULL;			/* Points to current page. */
static BOOLEAN Printing = FALSE;	/* TRUE if mouse is to be kept
					 * hidden at all costs. Used when
					 * printing to prevent mouse from
					 * corrupting printout.
					 */
static char LogScrArray[(SCSMAXX / 8) * SCSMAXY + 0x100];
static char *LogScr = &LogScrArray[0];	/* Pointer to a block of memory
					 * used as a logical screen when
					 * printing.
					 */

extern FILE *Debug;

/* initPg: Initialize the page list. */
initPg()
{
	char str[MAXSTR];
	extern char *lmalloc();
	int cmpPg();

	ListCreate(&PgLst, cmpPg);

	/* Adjust the logical screen buffer. It must be aligned on a 256-
	 * byte boundary.
	 */
	if (((long)LogScr & 0xff) != 0) {
		LogScr += 0x100 - ((long)LogScr & 0xff);
	}
}

/* setCurPg: Set the current page. Returns TRUE if page was set successfully.
 */
BOOLEAN setCurPg(pgNum)
register int pgNum;
{
	register PAGE *page;
	PAGE testPg;
	extern RECT2D WinWcsRct;
	extern void setThumbs();

	/* Save the window position in the current page. */
	bcopy(&WinWcsRct, &CurPage->pgWinWcsRct, sizeof(RECT2D));

	/* Determine if the specified page number exists. */
	testPg.pgNum = pgNum;
	if ((page = (PAGE *)ListFind(&PgLst, &testPg)) != NULL) {
		CurPage = page;

		/* Restore the new page's window position. */
		bcopy(&CurPage->pgWinWcsRct, &WinWcsRct, sizeof(RECT2D));
		setThumbs();
		return (TRUE);
	}

	return (FALSE);
}

/* addPg: Add a new page to the page list. Returns TRUE if the page was
 * added. The new page becomes the current page.
 */
BOOLEAN addPg(pgNum)
register int pgNum;
{
	register PAGE *page;
	PAGE testPg;
	extern char *Emalloc();
	extern RECT2D WinWcsRct;
	extern BOOLEAN FileDirty;
	extern int cmpEnt();
	extern void setThumbs();

	/* Determine if the specified page number already exists. */
	testPg.pgNum = pgNum;
	if ((page = (PAGE *)ListFind(&PgLst, &testPg)) == NULL) {

		/* Allocate space for the new page. */
		if ((page = (PAGE *)Emalloc(sizeof (PAGE))) == NULL) {
			return (FALSE);
		}
		page->pgNum = pgNum;
		page->pgSelActv = FALSE;
		page->nEnts = 0;
		COPYRECT(&WinWcsRct, &page->pgWinWcsRct);
		page->pgWinWcsRct.x = page->pgWinWcsRct.y = 0;
		bcopy(&page->pgWinWcsRct, &WinWcsRct, sizeof(RECT2D));
		setThumbs();

		/* Initialize the new page's entity list. */
		ListCreate(&page->pgEntLst, cmpEnt);

		/* Add the new page. */
		if (ListAdd(&PgLst, page) == NULL) {
			return (FALSE);
		}
		++NPages;
		CurPage = page;
		FileDirty = TRUE;
		return (TRUE);
	}
	else {
		return (FALSE);
	}
}

/* delPg: Delete a page from the page list. Returns TRUE if the page was
 * deleted.
 */
BOOLEAN delPg(pgNum)
register int pgNum;
{
	register PAGE *page;
	PAGE testPg;
	int cmpPg();
	extern int free(), freeEnt();

	/* Determine if the specified page number exists. */
	testPg.pgNum = pgNum;
	if ((page = (PAGE *)ListFind(&PgLst, &testPg)) != NULL) {

		/* Delete the page's entity list. */
		ListDestroy(&page->pgEntLst, freeEnt);

		/* Delete the page. */
		ListDelete(&PgLst, page);
		free(page);

		--NPages;
		return (TRUE);
	}

	return (FALSE);
}

/* drwPg: Redraw the current page. Assumes a clipping rectangle has been
 * placed over the window area to be redrawn.
 */
drwPg()
{
	register LISTNODE *pEntLst;
	register ENTITY *ent;
	RECT2D clipRct, scsEntRct, junk;
	extern BOOLEAN ShowGrid;

	/* Make sure there's something to draw. */
	if (CurPage == NULL) {
		return;
	}

	hideMouse();

	/* Clear an area equal to the clipping rectangle. */
	setWrtMode(MD_REPLACE);
	getClipRct(&clipRct);
	clrRect(&clipRct);

	if (ShowGrid) {
		drwGrid();
	}

	/* Draw all the entities on this page that intersect with the
	 * clipping rectangle.
	 */
	for (pEntLst = ListNext(&CurPage->pgEntLst.head); pEntLst != NULL;
	    pEntLst = ListNext(pEntLst)) {
		ent = (ENTITY *)ListContents(pEntLst);
		WCSRCTTOSCS(&ent->entRct, &scsEntRct);
		if (rect_intersect(scsEntRct, clipRct, &junk)) {
			drwEnt(ent, MD_REPLACE);
		}
	}

	/* Draw the selection rectangle if this page has one active. */
	if (CurPage->pgSelActv) {
		reDrwSelRct();
	}

	if (!Printing) {
		showMouse();
	}
}

/* drwGrid: draw a grid showing inches over page. */
drwGrid()
{
	LINE2D wcsLine;
	int attrib[10];
	register int x, y, inch, cellWd, cellHt;
	char inchStr[10];
	RECT2D clipRct;
	static LINESTYLE gridLnStyle = {1, SQUAREEND, GRIDLNPAT};
	static TXTSTYLE gridTxtStyle = {0, GRIDTEXTSZ, LIGHTTEXT};
	extern int GHandle;
	extern RECT2D WinScsRct;

	/* Set the clipping rectangle to the full window. Because of an
	 * apparent bug in VDI, the dots in the dotted grid lines aren't
	 * always lined up when a partial redraw is done.
	 */
	getClipRct(&clipRct);
	setClipRct(&WinScsRct);

	/* Set the writing mode to transparent so previously-drawn entities
	 * come shining through the dotted grid lines.
	 */
	setWrtMode(MD_TRANS);

	/* Set the line attributes as needed for the grid lines. */
	setLnStyle(&gridLnStyle);

	/* Set the text size and attributes for the inch numbers. */
	setTxtStyle(&gridTxtStyle);

	/* Determine the current character cell width and height. */
	vqt_attributes(GHandle, attrib);
	cellWd = attrib[8];
	cellHt = attrib[9];

	/* Draw vertical grid lines in quarter-inch increments. The lines
	 * are calculated in WCS then converted to SCS.
	 */
	inch = 1;
	for (x = WCSHPPI / 4; x < WCSMAXX; x += (WCSHPPI / 4)) {

		/* Draw the grid line. */
		SETLINE(&wcsLine, x, 0, x, WCSMAXY - 1);
		WCSLNTOSCS(&wcsLine, &wcsLine);
		drwLine(&wcsLine);

		if (x % WCSHPPI == 0) {
			if (wcsLine.x1 >= WinScsRct.x &&
			    wcsLine.x1 < WinScsRct.x + WinScsRct.w) {

				/* This is a visible inch line. Draw the
				 * inch number beside the line.
			 	 */
				sprintf(inchStr, "%d", inch);
				v_gtext(GHandle, wcsLine.x1 - cellWd / 2,
			    	WinScsRct.y + cellHt, inchStr);
			}
			++inch;
		}
	}

	/* Draw horizontal grid lines in quarter-inch increments. The lines
	 * are calculated in WCS then converted to SCS.
	 */
	inch = 1;
	for (y = WCSVPPI / 4; y < WCSMAXY; y += (WCSVPPI / 4)) {

		/* Draw the grid line. */
		SETLINE(&wcsLine, 0, y, WCSMAXX - 1, y);
		WCSLNTOSCS(&wcsLine, &wcsLine);
		drwLine(&wcsLine);

		if (y % WCSVPPI == 0) {
			if (wcsLine.y1 >= WinScsRct.y &&
			    wcsLine.y1 < WinScsRct.y + WinScsRct.h) {

				/* This is a visible inch line. Draw the
				 * inch number beside the line.
				 */
				sprintf(inchStr, "%d", inch);
				v_gtext(GHandle, WinScsRct.x,
				    wcsLine.y1 + cellHt / 2, inchStr);
			}
			++inch;
		}
	}
	setClipRct(&clipRct);
}

/* cmpPg: compare 2 pages for equality by comparing page numbers. */
int cmpPg(pg1, pg2)
PAGE *pg1, *pg2;
{
	return (pg1->pgNum - pg2->pgNum);
}

/* addEntPg: Add an entity to the current page. Returns TRUE if successful.
 */
BOOLEAN addEntPg(ent)
register ENTITY *ent;
{
	register ENTITY *newEnt;
	extern ENTITY *allocEnt();
	extern BOOLEAN FileDirty;

	/* Make a dynamic copy of the entity. */
	if ((newEnt = allocEnt()) == NULL) {
		return (FALSE);
	}
	copyEnt(ent, newEnt);

	/* Add the new entity to the current page's entity list. */
	if (ListAdd(&CurPage->pgEntLst, newEnt) == NULL) {
		return (FALSE);
	}
	++CurPage->nEnts;
	FileDirty = TRUE;
	updtWinTtl(FALSE);

	return (TRUE);
}

/* fndEntPt: Determine which entity (if any) is under a point on the
 * current page. Returns TRUE if an entity was found, and passed back a
 * pointer to the entity.
 */
BOOLEAN fndEntPt(pos, entPtr)
register POINT2D *pos;
register ENTITY **entPtr;
{
	register LISTNODE *pEntLst;
	register ENTITY *ent, *bestEnt;
	register int size, bestSize;
	extern BOOLEAN ptOnEnt();

	/* Look for the smallest entity under the point. This allows very
	 * specific targets to be located.
	 */
	bestSize = 30000;
	bestEnt = NULL;
	for (pEntLst = ListNext(&CurPage->pgEntLst.head); pEntLst != NULL;
	    pEntLst = ListNext(pEntLst)) {
		ent = (ENTITY *)ListContents(pEntLst);
		if (ptOnEnt(pos, ent)) {
			if ((size = ent->entRct.w * ent->entRct.h) <
			    bestSize) {
				bestSize = size;
				bestEnt = ent;
			}
		}
	}

	if (bestEnt != NULL) {
		*entPtr = bestEnt;
		return (TRUE);
	}

	return (FALSE);
}

/* actvSelPg: Indicate whether something is selected on the current page. */
actvSelPg(actv)
BOOLEAN actv;
{
	if (CurPage != NULL) {
		CurPage->pgSelActv = actv;
	}
}

/* isActvSelPg: Return TRUE if something is selected on the current page. */
BOOLEAN isActvSelPg()
{
	return (CurPage != NULL ? CurPage->pgSelActv : FALSE);
}

/* delEntPg: Delete an entity from the current page. */
delEntPg(ent)
register ENTITY *ent;
{
	extern int freeEnt();
	extern BOOLEAN FileDirty;

	(void)ListDelete(&CurPage->pgEntLst, ent);
	freeEnt(ent);
	--CurPage->nEnts;
	FileDirty = TRUE;
	updtWinTtl(FALSE);
}

/* fndEntPg: Locate an entity on the current page, given a model. Returns
 * NULL if the entity wasn't found.
 */
ENTITY *fndEntPg(ent)
register ENTITY *ent;
{
	return ((ENTITY *)ListFind(&CurPage->pgEntLst, ent));
}

/* svPgFile: Save the pages to a file. */
BOOLEAN svPgsFile(fp)
register FILE *fp;
{
	long magic;
	register LISTNODE *pPgLst, *pEntLst;
	register PAGE *page;
	register ENTITY *ent;
	register int symTyp;
	int n;
	extern ENTITY *allocEnt();
	extern char Version[];

	if ((ent = allocEnt()) == NULL) {
		return (FALSE);
	}

	/* Write the magic number. */
	magic = MAGIC;
	if (fwrite(&magic, sizeof(magic), 1, fp) != 1) {
		return (FALSE);
	}

	/* Determine the Score version number, then write it. */
	n = atoi(&Version[strlen(Version) - (sizeof("0000") - 1)]);
	if (fwrite(&n, sizeof(n), 1, fp) != 1) {
		return (FALSE);
	}

	/* Write a dummy int ("reserved for future use") */
	if (fwrite(&n, sizeof(n), 1, fp) != 1) {
		return (FALSE);
	}

	/* Save the number of pages. */
	if (fwrite(&NPages, sizeof(NPages), 1, fp) != 1) {
		return (FALSE);
	}

	/* Save each page. */
	for (pPgLst = ListNext(&PgLst.head); pPgLst != NULL;
	    pPgLst = ListNext(pPgLst)) {
		page = (PAGE *)ListContents(pPgLst);
		if (fwrite(page, sizeof(PAGE), 1, fp) != 1) {
			return (FALSE);
		}

		/* Save all the entities on this page. */
		for (pEntLst = ListNext(&page->pgEntLst.head);
		    pEntLst != NULL; pEntLst = ListNext(pEntLst)) {

			/* Make a copy of the entity (we have to modify it)
			 */
			copyEnt((ENTITY *)ListContents(pEntLst), ent);

			/* Substitute the entity's symbol type for the
			 * pointer to its symbol.
			 */
			symTyp = ent->entSym->symTyp;
			ent->entSym = (SYMBOL *)symTyp;
			if (fwrite(ent, sizeof(ENTITY), 1, fp) != 1) {
				return (FALSE);
			}
		}
	}

	freeEnt(ent);
	return (TRUE);
}

/* rstPgsFile: Restore the pages from a file. */
BOOLEAN rstPgsFile(fp)
register FILE *fp;
{
	long magic;
	register int p, e, nEnts;
	int version, junk;
	register ENTITY *ent;
	extern char *Emalloc();
	extern int cmpEnt();
	BOOLEAN addEntPg();
	extern SYMBOL SymTbl[];
	register SYMBOL *sym;
	extern ENTITY *allocEnt();

	if ((ent = allocEnt()) == NULL) {
		return (FALSE);
	}

	/* Read and verify the magic number. */
	if (fread(&magic, sizeof(magic), 1, fp) != 1) {
		return (FALSE);
	}
	if (magic != MAGIC) {
		return (FALSE);
	}

	/* Read the version number. */
	if (fread(&version, sizeof(version), 1, fp) != 1) {
		return(FALSE);
	}

	/* Read the dummy "reserved" int. */
	if (fread(&junk, sizeof(junk), 1, fp) != 1) {
		return (FALSE);
	}

	/* Restore the number of pages. */
	if (fread(&NPages, sizeof(NPages), 1, fp) != 1) {
		return (FALSE);
	}

	/* Restore each page. */
	for (p = 0; p < NPages; ++p) {
		if ((CurPage = (PAGE *)Emalloc(sizeof(PAGE))) == NULL) {
			return (FALSE);
		}
		if (fread(CurPage, sizeof(PAGE), 1, fp) != 1) {
			return (FALSE);
		}
		if (ListAdd(&PgLst, CurPage) == NULL) {
			return (FALSE);
		}

		/* Nothing is selected when the page is restored. */
		CurPage->pgSelActv = FALSE;

		SETRECT(&CurPage->pgWinWcsRct, 0, 0, 0, 0);

		/* Restore this page's entity list. */
		ListCreate(&CurPage->pgEntLst, cmpEnt);
		nEnts = CurPage->nEnts;
		CurPage->nEnts = 0;
		for (e = 0; e < nEnts; ++e) {
			if (fread(ent, sizeof(ENTITY), 1, fp) != 1) {
				return (FALSE);
			}

			/* The pointer to the entity's symbol is stored
			 * on disk as the symbol type code. Locate
			 * the symbol associated with the type.
			 */
			for (sym = SymTbl; sym->symTyp != (int)ent->entSym &&
			    sym->symTyp >= 0; ++sym)
				;
			if (sym->symTyp == (int)ent->entSym) {
				ent->entSym = sym;
			}
			else {
				return (FALSE);
			}
			if (!addEntPg(ent)) {
				return (FALSE);
			}
		}
	}

	freeEnt(ent);
	return (TRUE);
}

/* delPgs: Delete all the pages and their contents. Restores everything to
 * its initial state.
 */
delPgs()
{
	/* Delete all the entity lists on all the pages. */
	delPgLst(&PgLst);

	/* Deselect anything that's selected. */
	deselect();

	NPages = 0;
}

/* delPgLst: Delete a page list. */
delPgLst(pgLst)
register LIST *pgLst;
{
	register LISTNODE *pPgLst;
	register PAGE *page;
	extern int free(), freeEnt();

	/* Delete all the entity lists on all the pages. */
	for (pPgLst = ListNext(&pgLst->head); pPgLst != NULL;
	    pPgLst = ListNext(pPgLst)) {
		page = (PAGE *)ListContents(pPgLst);
		ListDestroy(&page->pgEntLst, freeEnt);
	}

	/* Delete all the pages. */
	ListDestroy(pgLst, free);
}

/* cpPgLst: Copy a page list. */
cpPgLst(srcLst, dstLst)
LIST *srcLst;
register LIST *dstLst;
{
	register PAGE *srcPage, *dstPage;
	register LISTNODE *pS;
	extern char *Emalloc();
	int cmpPg();
	extern int cmpEnt();

	for (pS = ListNext(&srcLst->head); pS != NULL; pS = ListNext(pS)) {
		srcPage = (PAGE *)ListContents(pS);
		if ((dstPage = (PAGE *)Emalloc(sizeof(PAGE))) == NULL) {
			return;
		}
		bcopy(srcPage, dstPage, sizeof(PAGE));
		ListCreate(&dstPage->pgEntLst, cmpEnt);
		cpEntLst(&srcPage->pgEntLst, &dstPage->pgEntLst);
		if (ListAdd(dstLst, dstPage) == NULL) {
			return;
		}
	}
}

#if 0
/* dumpPgs: dump information about all the pages (for debugging) */
dumpPgs()
{
	register LISTNODE *pgLst;
	register PAGE *srcPage;

	for (pgLst = ListNext(&PgLst.head); pgLst != NULL;
	    pgLst = ListNext(pgLst)) {
		srcPage = (PAGE *)ListContents(pgLst);
		fprintf(Debug, "0x%lx Page: pgNum=%d pgEntLst.lstNxt=0x%lx ",
		    srcPage, srcPage->pgNum,
		    ListNext(&srcPage->pgEntLst.head));
		fprintf(Debug, "pgSelActv=%d nEnts=%d\n", srcPage->pgSelActv,
		    srcPage->nEnts);
		dumpEntLst(&srcPage->pgEntLst);
	}
	fflush(Debug);
}
#endif

/* getCurPgNum: Return the current page number. */
int getCurPgNum()
{
	return (CurPage->pgNum);
}

/* prtPgs: Print all pages in the page list at the specified quality. */
prtPgs(qual)
register int qual;
{
	register LISTNODE *pPgLst;
	register PAGE *page, *svCurPage;
	register int wcsY;
	register char *physScr, *p;
	register BOOLEAN svShowGrid, cancel;
	RECT2D svWcsRct, svScsRct;
	extern RECT2D WinScsRct, WinWcsRct;
	extern BOOLEAN ShowGrid;
	extern int prtScr(), prtInit(), prtTerm(), prtNewPage(), GHandle;

	svCurPage = CurPage;
	svShowGrid = ShowGrid;
	COPYRECT(&WinWcsRct, &svWcsRct);
	COPYRECT(&WinScsRct, &svScsRct);

	/* Temporarily hide the grid. */
	ShowGrid = FALSE;

	hideMouse();
	Printing = TRUE;

	/* Set the logical screen address to the allocated buffer. */
	physScr = (char *)Physbase();
	Setscreen(LogScr, physScr, -1);

	cancel = FALSE;

	/* Initialize the printer. */
	if (prtInit(qual) == CANCEL) {
		cancel = TRUE;
	}

	/* Set the clipping rectangle to window half the screen size in
	 * the middle of the screen. There is a bug in vdi that causes
	 * things drawn near the top of the screen to screw up when
	 * clipping is enabled.
	 */
	SETRECT(&WinScsRct, 0, SCSMAXY / 4, SCSMAXX, SCSMAXY / 2);
	setClipRct(&WinScsRct);

	/* Print each page. */
	for (pPgLst = ListNext(&PgLst.head); pPgLst != NULL && !cancel;
	    pPgLst = ListNext(pPgLst)) {
		page = (PAGE *)ListContents(pPgLst);
		CurPage = page;

		/* Each page will be drawn in 4 chunks, with each chunk
		 * half as high as the screen.
		 */
		for (wcsY = 0; wcsY < WCSMAXY; wcsY += SCSMAXY / 2) {
			SETRECT(&WinWcsRct, 0, wcsY, WCSMAXX, SCSMAXY / 2);
			hideMouse();
			drwPg();

			if (prtScr(LogScr + (SCSMAXY / 4) * (SCSMAXX / 8),
			    SCSMAXY / 2, qual) == CANCEL) {
				cancel = TRUE;
			}
		}

		/* We've printed an entire physical printer page. Move to
		 * the next one.
		 */
		if (!cancel) {
			if (prtNewPage(qual) == CANCEL) {
				cancel = TRUE;
			}
		}
	}

	/* Reset the printer. */
	if (!cancel) {
		if (prtTerm(qual) == CANCEL) {
			cancel = TRUE;
		}
	}

	/* Fix the damage that's been done. */
	Setscreen(physScr, physScr, -1);
	showMouse();
	Printing = FALSE;
	ShowGrid = svShowGrid;
	CurPage = svCurPage;
	COPYRECT(&svWcsRct, &WinWcsRct);
	COPYRECT(&svScsRct, &WinScsRct);

	/* Force a new clipping rectangle. */
	SETRECT(&svScsRct, 0, 0, 0, 0);
	setClipRct(&svScsRct);
	setClipRct(&WinScsRct);
}

/* createPage: Supervise user's creation of a new page. */
createPage()
{
	register LISTNODE *pPgLst;
	register PAGE *page;
	OBJECT *crtPgForm;
	GRECT formRct;
	char pgNumStr[MAXSTR], str[MAXSTR];
	register int pgNum, exitBtn;
	BOOLEAN addPg();
	register BOOLEAN success, cancel;
	extern RECT2D WinScsRct, WinWcsRct;

	/* Save the window position of the current page. */
	COPYRECT(&WinWcsRct, &CurPage->pgWinWcsRct);

	/* Display the page number selection form. */
	rsrc_gaddr(R_TREE, CRTPGDLG, &crtPgForm);
	pgNumStr[0] = '\0';
	SETTEDTEXT(crtPgForm, CRTPGFLD, pgNumStr, MAXSTR);

	success = cancel = FALSE;
	do {
		DlgDisplay(crtPgForm, &formRct);
		if ((exitBtn = DlgExecute(crtPgForm)) == CRTPGOK) {

			if (pgNumStr[0] == '\0') {

				/* The user didn't enter a page number.
				 * Add a page after the last page.
				 */
				for (pPgLst = &PgLst.head;
				    ListNext(pPgLst) != NULL;
				    pPgLst = ListNext(pPgLst)) {
					/* Do nothing. */
				}
				if (pPgLst == &PgLst.head) {

					/* There are no pages. */
					pgNum = 1;
				}
				else {
					page = (PAGE *)ListContents(pPgLst);
					pgNum = page->pgNum + 1;
				}
			}
			else {
				pgNum = TEDTEXTTOINT(crtPgForm, CRTPGFLD);
			}

			/* Attempt to add the page. */
			if (addPg(pgNum)) {
				success = TRUE;
			}
			else {
				sprintf(str, "[2][%s|%s][Continue|Cancel]",
				    "A page with that number",
				    "already exists.");
				if (form_alert(1, str) == 2) {
					cancel = TRUE;
				}
			}
		}
		else {
			cancel = TRUE;
		}
		DESELOBJ(crtPgForm, exitBtn);
	} while (!success && !cancel);

	DlgErase(crtPgForm, &formRct);

	if (success) {

		/* The new page was created and is now the current page.
		 * Draw it so the user can start using it.
		 */
		setClipRct(&WinScsRct);
		drwPg();
		updtWinTtl(FALSE);
	}
}

/* delPage: supervise user's deletion of the current page. */
delPage()
{
	register LISTNODE *pPgLst;
	register PAGE *newCurPg;
	char str[MAXSTR];
	LISTNODE *fndCurPg();
	extern BOOLEAN FileDirty;
	extern RECT2D WinScsRct, WinWcsRct;
	extern void setThumbs();

	/* Save the window position of the current page. */
	COPYRECT(&WinWcsRct, &CurPage->pgWinWcsRct);

	/* See if there's anything in this page. If so, double check with
	 * the user before deleting it.
	 */
	if (CurPage->nEnts > 0) {
		sprintf(str, "[2][%s|%s|%s][Delete it|Cancel]",
		    "This page isn't empty.",
		    "Are you sure you want to",
		    "delete it?");
		if (form_alert(2, str) == 2) {
			return;
		}
	}

	/* Locate the list entry containing the current page. */
	pPgLst = fndCurPg();

	/* We have to leave the user positioned somewhere. Deleting a page
	 * is like pulling a page out of a book: you're left looking at
	 * the following page (if there is one). Determine what the new
	 * current page will be after the present current page is deleted.
	 */
	if ( ListNext(pPgLst) != NULL) {
		newCurPg = (PAGE *)ListContents(ListNext(pPgLst));
	}
	else if (ListPrev(pPgLst) != NULL) {
		newCurPg = (PAGE *)ListContents(ListPrev(pPgLst));
	}
	else {

		/* We'll be deleting the only page. */
		newCurPg = NULL;
	}

	/* Delete the current page. */
	delPg(CurPage->pgNum);

	/* Establish the new current page. */
	if (newCurPg == NULL) {

		/* There are no pages left. Create one. */
		addPg(1);
	}
	else {
		CurPage = newCurPg;
	}

	FileDirty = TRUE;

	/* Draw the new current page. */
	COPYRECT(&CurPage->pgWinWcsRct, &WinWcsRct);
	setThumbs();
	setClipRct(&WinScsRct);
	drwPg();
	updtWinTtl(FALSE);
}

/* gotoPage: Supervise user's positioning at new page */
gotoPage()
{
	OBJECT *gotoPgForm;
	GRECT formRct;
	char pgNumStr[MAXSTR], str[MAXSTR];
	register int pgNum, exitBtn;
	BOOLEAN setCurPg(), success, cancel;
	extern RECT2D WinScsRct;

	/* Display the page number selection form. */
	rsrc_gaddr(R_TREE, TOPGDLG, &gotoPgForm);
	pgNumStr[0] = '\0';
	SETTEDTEXT(gotoPgForm, TOPGFLD, pgNumStr, MAXSTR);

	success = cancel = FALSE;
	do {
		DlgDisplay(gotoPgForm, &formRct);
		if ((exitBtn = DlgExecute(gotoPgForm)) == TOPGOK) {
			pgNum = TEDTEXTTOINT(gotoPgForm, TOPGFLD);

			/* Attempt to set the page. */
			if (setCurPg(pgNum)) {
				success = TRUE;
			}
			else {
				sprintf(str, "[2][%s|%s][Continue|Cancel]",
				    "There is no page with",
				    "that page number.");
				if (form_alert(1, str) == 2) {
					cancel = TRUE;
				}
			}
		}
		else {
			cancel = TRUE;
		}
		DESELOBJ(gotoPgForm, exitBtn);
	} while (!success && !cancel);

	DlgErase(gotoPgForm, &formRct);

	if (success) {

		/* The selected page is now the current page.
		 * Draw it so the user can start using it.
		 */
		setClipRct(&WinScsRct);
		drwPg();
		updtWinTtl(FALSE);
	}
}

/* gotoPrvPage: Position user at previous page */
gotoPrvPage()
{
	register LISTNODE *pPgLst;
	LISTNODE *fndCurPg();
	extern RECT2D WinScsRct, WinWcsRct;
	extern void setThumbs();

	/* Save the window position of the current page. */
	COPYRECT(&WinWcsRct, &CurPage->pgWinWcsRct);

	/* Locate the list entry containing the current page. */
	pPgLst = fndCurPg();

	/* Try to move to the previous page. */
	if ((pPgLst = ListPrev(pPgLst)) != &PgLst.head) {
		CurPage = (PAGE *)ListContents(pPgLst);

		COPYRECT(&CurPage->pgWinWcsRct, &WinWcsRct);
		setThumbs();

		/* Draw the new current page. */
		setClipRct(&WinScsRct);
		drwPg();
		updtWinTtl(FALSE);
	}
}

/* gotoNxtPage: Position user at next page */
gotoNxtPage()
{
	register LISTNODE *pPgLst;
	LISTNODE *fndCurPg();
	extern RECT2D WinScsRct, WinWcsRct;
	extern void setThumbs();

	/* Save the window position of the current page. */
	COPYRECT(&WinWcsRct, &CurPage->pgWinWcsRct);

	/* Locate the list entry containing the current page. */
	pPgLst = fndCurPg();

	/* Try to move to the next page. */
	if ((pPgLst = ListNext(pPgLst)) != NULL) {
		CurPage = (PAGE *)ListContents(pPgLst);

		COPYRECT(&CurPage->pgWinWcsRct, &WinWcsRct);
		setThumbs();

		/* Draw the new current page. */
		setClipRct(&WinScsRct);
		drwPg();
		updtWinTtl(FALSE);
	}
}

/* goto1stPage: Position user at first page */
goto1stPage()
{
	register LISTNODE *pPgLst;
	extern RECT2D WinScsRct, WinWcsRct;
	extern void setThumbs();

	/* Save the window position of the current page. */
	COPYRECT(&WinWcsRct, &CurPage->pgWinWcsRct);

	if ((pPgLst = ListNext(&PgLst.head)) != NULL) {
		CurPage = (PAGE *)ListContents(pPgLst);

		COPYRECT(&CurPage->pgWinWcsRct, &WinWcsRct);
		setThumbs();

		/* Draw the new current page. */
		setClipRct(&WinScsRct);
		drwPg();
		updtWinTtl(FALSE);
	}
}

/* gotoLstPage: Position user at last page */
gotoLstPage()
{
	register LISTNODE *pPgLst;
	extern RECT2D WinScsRct, WinWcsRct;
	extern void setThumbs();

	/* Save the window position of the current page. */
	COPYRECT(&WinWcsRct, &CurPage->pgWinWcsRct);

	/* Locate the last page. */
	for (pPgLst = &PgLst.head; ListNext(pPgLst) != NULL;
	    pPgLst = ListNext(pPgLst)) {
		/* Do nothing. */
	}
	if (pPgLst != &PgLst.head) {
		CurPage = (PAGE *)ListContents(pPgLst);

		COPYRECT(&CurPage->pgWinWcsRct, &WinWcsRct);
		setThumbs();

		/* Draw the new current page. */
		setClipRct(&WinScsRct);
		drwPg();
		updtWinTtl(FALSE);
	}
}

/* fndCurPg: Return the list node containing the current page. */
LISTNODE *fndCurPg()
{
	register LISTNODE *pPgLst, *pLstEnt;
	register BOOLEAN found;
	register PAGE *page;

	found = FALSE;
	pLstEnt = (PAGE *)NULL;
	for (pPgLst = ListNext(&PgLst.head); pPgLst != NULL && !found;
	    pPgLst = ListNext(pPgLst)) {
		pLstEnt = pPgLst;
		page = (PAGE *)ListContents(pPgLst);
		found = page->pgNum == CurPage->pgNum;
	}

	if (found) {
		return (pLstEnt);
	}
	return (NULL);
}
