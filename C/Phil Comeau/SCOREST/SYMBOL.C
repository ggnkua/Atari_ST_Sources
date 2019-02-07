/* symbol: Functions relating to Symbols
 * phil comeau 08-feb-88
 * last edited 11-oct-89 0016
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <math.h>
#include <mylib.h>
#include <graphics.h>
#include <dialog.h>
#include "graph.h"
#include "scoredef.h"
#include "symbol.h"
#include "entity.h"
#include "scorest.h"

/* noteMouse: Mouse form definition used for notes and other small staff-
 * position dependent symbols.
 */
static MSFORM noteMouse = {
	USER_DEF,		/* msTyp */
	{			/* msFormDef */
		3, 11,		/* hotspot */
		1,		/* rsvd */
		0, 1,		/* back/foreground colors */
		{		/* background image */
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000
		},
		{		/* foreground image */
			0x0000,
			0x0000,
			0x0000,
			0x1008,
			0x0000,
			0x55aa,
			0x0000,
			0x1008,
			0x45a2,
			0x1008,
			0x0000,
			0x55aa,
			0x0000,
			0x1008,
			0x0000,
			0x0000
		}
	}
};

/* raMouse: Mouse form definition used for large staff-position dependent
 * symbols.
 */
static MSFORM raMouse = {
	USER_DEF,		/* msTyp */
	{			/* msFormDef */
		3, 13,		/* hotspot */
		1,		/* rsvd */
		0, 1,		/* back/foreground colors */
		{		/* background image */
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000
		},
		{		/* foreground image */
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0x2000,
			0xffff,
			0x2000,
			0x2000
		}
	}
};

/* crossMouse: Crosshair mouse definition used for non-staff-position
 * dependent symbols.
 */
static MSFORM crossMouse = {
	USER_DEF,		/* msTyp */
	{			/* msFormDef */
		8, 7,		/* hotspot */
		1,		/* rsvd */
		0, 1,		/* back/foreground colors */
		{		/* background image */
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000,
			0x0000
		},
		{		/* foreground image */
			0x0080,
			0x0000,
			0x0080,
			0x0000,
			0x0080,
			0x0000,
			0x0080,
			0x5555,
			0x0080,
			0x0000,
			0x0080,
			0x0000,
			0x0080,
			0x0000,
			0x0080,
			0x0000
		}
	}
};

/* fingerMouse: Pointing-finger mouse definition used for selection
 * symbol.
 */
static MSFORM fingerMouse = {
	POINT_HAND,		/* msTyp */
	{0},			/* msFormDef */
};

/* Symbol table: Table defining the musical and graphical symbols that may
 * be drawn. One entry exists for each symbol type.
 */
SYMBOL SymTbl[] = {
	{SN1, IN1, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 12, 16, 8}, {3, 6}},
	{SR1, IR1, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {6, 13, 20, 7}, {5, 7}},
	{SN2UP, IN2UP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 4, 14, 24}, {3, 23}},
	{SN2DN, IN2DN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 3, 14, 25}, {1, 6}},
	{SR2, IR2, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL,	0, 0,				
	    {5, 11, 21, 5}, {5, 5}},
	{SN4UP, IN4UP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 5, 12, 23}, {1, 22}},
	{SN4DN, IN4DN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 3, 12, 25}, {1, 6}},
	{SR4, IR4, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {10, 5, 11, 21}, {0, 19}},
	{SN8UP, IN8UP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {6, 5, 18, 22}, {1, 20}},
	{SN8DN, IN8DN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 4, 12, 24}, {1, 6}},
	{SR8, IR8, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 7, 13, 18}, {1, 16}},
	{SN16UP, IN16UP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {6, 3, 19, 27}, {1, 25}},
	{SN16DN, IN16DN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 2, 12, 26}, {1, 6}},
	{SR16, IR16, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 7, 13, 18}, {1, 16}},
	{SN32UP, IN32UP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {6, 3, 19, 27}, {1, 26}},
	{SN32DN, IN32DN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 0, 12, 31}, {1, 7}},
	{SR32, IR32, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 8, 14, 18}, {1, 16}},
	{SN64UP, IN64UP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {6, 1, 19, 29}, {1, 27}},
	{SN64DN, IN64DN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 0, 12, 32}, {1, 6}},
	{SR64, IR64, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {7, 6, 16, 20}, {1, 18}},
	{SNAT, INAT, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {12, 10, 6, 15}, {0, 9}},
	{SSHARP, ISHARP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {11, 9, 8, 14}, {0, 9}},
	{SFLAT, IFLAT, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {12, 8, 8, 17}, {0, 13}},
	{SPIANO, IPIANO, RSTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {7, 9, 16, 18}, {6, 9}},
	{SMEZZO, IMEZZO, RSTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {8, 11, 15, 11}, {2, 9}},
	{SFORTE, IFORTE, RSTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {8, 6, 14, 21}, {5, 12}},
	{SN4HEAD, IN4HEAD, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 13, 12, 8}, {1, 6}},
	{SN2HEAD, IN2HEAD, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 12, 14, 8}, {2, 6}},
	{SDOT, IDOT, RSTSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {13, 10, 4, 4}, {2, 1}},
	{STCLEF, ITCLEF, RSTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {7, 0, 18, 40}, {2, 33}},
	{SBCLEF, IBCLEF, RSTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {6, 2, 21, 26}, {1, 24}},
	{SACLEF, IACLEF, RSTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {7, 2, 19, 27}, {1, 25}},
	{STURN, ITURN, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {8, 12, 12, 7}, {1, 6}},
	{SSTAC, ISTAC, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 10, 11, 10}, {0, 8}},
	{SSEGNE, ISEGNE, RSTSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {9, 6, 15, 19}, {7, 9}},
	{SCODA, ICODA, RSTSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {3, 2, 25, 25}, {12, 12}},
	{SUPCRV, IUPCRV, CRVSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0} },
	{SDNCRV, IDNCRV, CRVSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{STRILL, ITRILL, TRLSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{SBEAM, IBEAM, BEAMSYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{SLINE, ILINE, LINESYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{STEXT, ITEXT, TXTSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{SBRACE, IBRACE, BRACESYMCLASS, NULL, &crossMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{SLDGRLN, ILDGRLN, LDGRLNSYMCLASS, NULL, &crossMouse, (char *)NULL,			
	    0, 0, {0}, {0, 0}},
	{SSTAFF, ISTAFF, STFSYMCLASS, NULL, &raMouse, (char *)NULL, 0, 0,				
	    {0}, {0, 0}},
	{SSELECT, ISELECT, SELSYMCLASS, NULL, &fingerMouse, (char *)NULL,			
	    0, 0, {0}, {0, 0}},
	{SGRACE, IGRACE, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {9, 4, 12, 18}, {0, 16}},
	{SDSHARP, IDSHARP, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL, 0, 0,				
	    {11, 4, 11, 11}, {0, 8}},
	{SFERMATA, IFERMATA, RSTSYMCLASS, NULL, &noteMouse, (char *)NULL,			
	    0, 0, {5, 3, 22, 13}, {5, 13}},
	{-1}	/* end of table */
};

SYMBOL *CurSym = NULL;			/* points to the currently-selected
					 * symbol.
					 */
extern FILE *Debug;

/* Forward References. */
static void addRstSym(), addLineSym(), addTxtSym(), addTrlSym(),
    addCrvSym(), addLdgrLnSym(), addSelSym(), addStfSym(), addBraceSym(),
    addBeamSym();

/* selectSym:	Supervise a user's selection of a symbol from the Symbol
 *		Palette.
 */
void selectSym(msPos)
POINT2D *msPos;
{
	int iconObj, junk;
	register SYMBOL *sym;
	extern OBJECT *Palette;

	/* Determine if the user clicked the mouse over an icon in the
	 * Palette.
	 */
	if ((iconObj = objc_find(Palette, ROOT, 2, msPos->x,
	    msPos->y)) >= 0) {
		for (sym = SymTbl; sym->objId != iconObj && sym->symTyp >= 0;
		    ++sym) {
			/* Do nothing. */
		}
		if (sym->symTyp >= 0) {
			if (CurSym != NULL) {
				DlgDeselect(Palette, CurSym->objId, TRUE);
			}
			DlgSelect(Palette, sym->objId, TRUE);
			CurSym = sym;
		}
	}
}

/* addSym: Add a symbol starting at the specified position. The symbol
 * is drawn, and the entity representing the symbol is added to the
 * current page.
 */
void addSym(pos, sym, keyState, keyChar)
register POINT2D *pos;
register SYMBOL *sym;
register int keyState;
register char keyChar;
{
	register ENTITY *newEnt;
	extern BOOLEAN addEntPg();
	extern LINESTYLE LineStyle, BeamStyle;
	extern TXTSTYLE TxtStyle;
	extern RECT2D WinScsRct;
	extern ENTITY *LastEntAdded, *allocEnt();
	extern BOOLEAN LastEntValid;
	extern int LastEntPgNum;
	extern int getCurPgNum();

	if ((newEnt = allocEnt()) == NULL) {
		return;
	}

	/* Set the clipping rectangle to limit drawing to the window area.
	 */
	setClipRct(&WinScsRct);

	/* Construct an entity of the symbol's class. At this point, the
	 * user may change the symbol's position or extent. How this is
	 * actually accomplished depends on the symbol's class.
	 */
	newEnt->entSym = sym;
	switch (sym->symClass) {
	case RSTSYMCLASS:
		addRstSym(pos, newEnt);
		break;
	case LINESYMCLASS:

		/* Save the current line style with the line entity. */
		bcopy(&LineStyle, &newEnt->entInfo.lineEnt.lnStyle,
		    sizeof (LINESTYLE));
		addLineSym(pos, newEnt);
		break;
	case CRVSYMCLASS:
		newEnt->entInfo.crvEnt.crvDir = sym->symTyp == SUPCRV ?
		    UP : DOWN;
		newEnt->entInfo.crvEnt.crvLnWd = LineStyle.lnW;
		addCrvSym(pos, newEnt);
		break;
	case TXTSYMCLASS:

		/* Save the current text style with the text entity. */
		bcopy(&TxtStyle, &newEnt->entInfo.txtEnt.txtStyle,
		    sizeof (TXTSTYLE));
		newEnt->entInfo.txtEnt.txtChar = keyChar;
		addTxtSym(pos, newEnt);
		break;
	case TRLSYMCLASS:
		addTrlSym(pos, newEnt);
		break;
	case LDGRLNSYMCLASS:
		addLdgrLnSym(pos, newEnt);
		break;
	case SELSYMCLASS:
		addSelSym(pos, keyState);
		break;
	case STFSYMCLASS:
		addStfSym(pos, newEnt);
		break;
	case BRACESYMCLASS:
		newEnt->entInfo.braceEnt.braceLnWd = LineStyle.lnW;
		addBraceSym(pos, newEnt);
		break;
	case BEAMSYMCLASS:
		addBeamSym(pos, newEnt);
	}

	/* Create an entity on the current page, representing this
	 * symbol. Selection symbols are really actions, so they aren't
	 * instantiated as entities. Also, we don't add null text
	 * characters.
	 */
	if (sym->symClass != SELSYMCLASS && !(sym->symClass == TXTSYMCLASS &&
	    newEnt->entInfo.txtEnt.txtChar == (char)NULL)) {
		addEntPg(newEnt);

		/* Draw the new entity. */
		hideMouse();
		drwEnt(newEnt, MD_REPLACE);
		showMouse();

		/* Save the entity so it can be deleted easily. */
		copyEnt(newEnt, LastEntAdded);
		LastEntValid = TRUE;
		LastEntPgNum = getCurPgNum();
	}

	freeEnt(newEnt);
}

/* addRstSym: Supervise the user's placement of a raster-class symbol. */
static void addRstSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	SCSPTTOWCS(&oldPos, &ent->entInfo.rstEnt.rstOrg);

	/* Draw the raster initially to help orient the user. */
	hideMouse();
	drwEnt(ent, MD_XOR);
	showMouse();

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the previous image. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Redraw the raster in the new position. */
			SCSPTTOWCS(&newPos, &ent->entInfo.rstEnt.rstOrg);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Fill in the rectangle surrounding the entity. */
	SETRECT(&ent->entRct,
	    ent->entInfo.rstEnt.rstOrg.x - ent->entSym->symMsOff.x,
	    ent->entInfo.rstEnt.rstOrg.y - ent->entSym->symMsOff.y,
	    ent->entSym->symOrgRct.w, ent->entSym->symOrgRct.h);
}

/* addLineSym: Supervise the user's placement of a line-class symbol. */
static void addLineSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos;
	register int aura;
	register LINE2D *pLine;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	pLine = &ent->entInfo.lineEnt.line;
	SCSPTTOWCS(&oldPos, (POINT2D *)&pLine->x1);
	SCSPTTOWCS(&oldPos, (POINT2D *)&pLine->x2);

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old line. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new line. */
			SCSPTTOWCS(&newPos, (POINT2D *)&pLine->x2);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Fill in the rectangle surrounding the line. */
	aura = MAX(ent->entInfo.lineEnt.lnStyle.lnW, 3);
	SETRECT(&ent->entRct,
	    MIN(pLine->x1, pLine->x2) - aura,
	    MIN(pLine->y1, pLine->y2) - aura,
	    abs(pLine->x1 - pLine->x2) + aura + aura,
	    abs(pLine->y1 - pLine->y2) + aura + aura);
}

/* addTxtSym: Supervise the user's placement of a text-class symbol. */
static void addTxtSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	int distances[5], effects[3], junk, cellWd;
	register int cellHt, aura;
	static POINT2D curPos = {-1, -1}, orgPos = {-1, -1},
	    lastPos = {-1, -1};
	extern int GHandle;

	SCSPTTOWCS(pos, pos);

	/* Set the current position if there's no character to add. */
	if (ent->entInfo.txtEnt.txtChar == (char)NULL) {
		curPos.x = orgPos.x = lastPos.x = pos->x;
		curPos.y = orgPos.y = lastPos.y = pos->y;
	}
	else if (ent->entInfo.txtEnt.txtChar == '\b') {

		/* We're backspacing over the last character typed.
		 * Somebody else will delete the character; we just have
		 * to restore its position.
		 */
		if (lastPos.x >= 0 && lastPos.y >= 0) {
			COPYPOINT(&lastPos, &curPos);
		}
		ent->entInfo.txtEnt.txtChar = (char)NULL;
	}
	else {
		if (curPos.x >= 0 && curPos.y >= 0) {

			/* Determine the size of the character. */
			setTxtStyle(&ent->entInfo.txtEnt.txtStyle);
			vqt_fontinfo(GHandle, &junk, &junk, distances,
			    &cellWd, effects);
			cellHt = distances[0] + distances[4];
			COPYPOINT(&curPos, &ent->entInfo.txtEnt.txtOrg);

			/* The text entity's origin is at its lower left
			 * corner. Adjust its rectangle so it references
			 * the upper left corner.
			 */
			aura = 2;
			SETRECT(&ent->entRct, curPos.x - (effects[1] + aura),
			    curPos.y - (distances[4] + aura),
			    cellWd + effects[1] + effects[2] + aura + aura,
			    cellHt + aura + aura);

			/* Add or act on the character. */
			if (ent->entInfo.txtEnt.txtChar == '\r') {
				COPYPOINT(&curPos, &lastPos);
				SETPOINT(&curPos, orgPos.x,
				    curPos.y + cellHt);
				ent->entInfo.txtEnt.txtChar = '\0';
			}
			else {
				hideMouse();
				drwEnt(ent, MD_REPLACE);
				showMouse();
				COPYPOINT(&curPos, &lastPos);
				MOVEPOINT(&curPos, cellWd, 0);
			}
		}
	}
}

/* addTrlSym: Supervise the user's placement of a trill-class symbol. */
static void addTrlSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos, *pOrg, *pEnd;
	register int aura;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	pOrg = &ent->entInfo.trlEnt.trlOrg;
	pEnd = &ent->entInfo.trlEnt.trlEnd;
	SCSPTTOWCS(&oldPos, pOrg);
	SCSPTTOWCS(&oldPos, pEnd);

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old trill line. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new trill line. */
			SCSPTTOWCS(&newPos, pEnd);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Fill in the rectangle surrounding the trill line. */
	aura = NTRILLLINES / 2;
	SETRECT(&ent->entRct,
	    MIN(pOrg->x, pEnd->x) - (NTRILLLINES / 2 + aura),
	    MIN(pOrg->y, pEnd->y) - (NTRILLLINES / 2 + aura),
	    abs(pOrg->x - pEnd->x) + aura + NTRILLLINES + aura,
	    abs(pOrg->y - pEnd->y) + aura + NTRILLLINES + aura);
}

/* addCrvSym: Supervise the user's placement of a curve-class symbol. */
static void addCrvSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos, *pOrg, *pEnd;
	register int deltaX, deltaY, aura, crvHt;
	float dist;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	pOrg = &ent->entInfo.crvEnt.crvOrg;
	pEnd = &ent->entInfo.crvEnt.crvEnd;
	SCSPTTOWCS(&oldPos, pOrg);
	SCSPTTOWCS(&oldPos, pEnd);

	/* Draw the curve initially. */
	hideMouse();
	drwEnt(ent, MD_XOR);
	showMouse();

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old curve. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new curve. */
			SCSPTTOWCS(&newPos, pEnd);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Fill in the rectangle surrounding the curve.
	 * Calculate distance from origin.
	 */
	deltaX = MAX(abs(pEnd->x - pOrg->x), MINCRVWD);
	deltaY = abs(pEnd->y - pOrg->y);
	if (deltaX == 0) {
		dist = (float)deltaY;
	}
	else if (deltaY == 0) {
		dist = (float)deltaX;
	}
	else {
		dist = (float)sqrt((double)deltaX * deltaX +
		    deltaY * deltaY);
	}

	/* Calculate curve height. */
	crvHt = (dist / CRVWD) * CRVHT;

	aura = MAX(ent->entInfo.crvEnt.crvLnWd + 1, 2);
	if (ent->entInfo.crvEnt.crvDir == DOWN) {
		SETRECT(&ent->entRct,
		    MIN(pOrg->x, pEnd->x) - (crvHt + aura),
		    MIN(pOrg->y, pEnd->y) - (crvHt + aura),
		    deltaX + aura + crvHt + crvHt + aura,
		    deltaY + aura + crvHt + crvHt + aura);
	}
	else {
		SETRECT(&ent->entRct,
		    MIN(pOrg->x, pEnd->x) - (crvHt + aura),
		    MIN(pOrg->y, pEnd->y) - aura,
		    deltaX + aura + crvHt + crvHt + aura,
		    deltaY + aura + crvHt + aura);
	}
}

/* addLdgrLnSym: Supervise the user's placement of a ledgerLine-class
 * symbol.
 */
static void addLdgrLnSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos;
	register POINT2D *ldgrLnOrg, *ldgrLnEnd;
	register int aura, dir;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	ldgrLnOrg = &ent->entInfo.ldgrLnEnt.ldgrLnOrg;
	ldgrLnEnd = &ent->entInfo.ldgrLnEnt.ldgrLnEnd;
	SCSPTTOWCS(&oldPos, ldgrLnOrg);
	SCSPTTOWCS(&oldPos, ldgrLnEnd);

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old ledgerline. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new line. */

			SCSPTTOWCS(&newPos, ldgrLnEnd);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Fill in the rectangle surrounding the ledgerline. */
	aura = 4;
	dir = ldgrLnOrg->y > ldgrLnEnd->y ? UP : DOWN;
	SETRECT(&ent->entRct,
	    ldgrLnOrg->x - (LDGRLNWD / 2 + aura),
	    dir == UP ? ldgrLnEnd->y - aura : ldgrLnOrg->y - aura,
	    LDGRLNWD + aura + aura,
	    abs(ldgrLnOrg->y - ldgrLnEnd->y) + aura + aura);
}

/* addSelSym: Supervise the user's placement of a selection-class symbol.
 * "Selection" is really an action, not a symbol, but it's handled the
 * same way for symmetry.
 */
static void addSelSym(pos, keyState)
register POINT2D *pos;
int keyState;
{
	POINT2D newPos;
	int msBtn, key, i;
	ENTITY *ent;
	extern BOOLEAN msInSelRct(), fndEntPt(), selRctLROk();
	extern RECT2D WinWcsRct, WinScsRct;

	SCSPTTOWCS(pos, pos);

	/* If the user is holding the mouse button down, he can either
	 * draw a selection rectangle or drag previously-selected
	 * entities.
	 */

	/* This loop is an experiment to solve a problem where it sometimes
	 * appears the user is holding the mouse down when in fact it was
	 * just clicked.
	 */
	for (i = 0; i < 50; ++i) {
	}

	graf_mkstate(&newPos.x, &newPos.y, &msBtn, &key);
	SCSPTTOWCS(&newPos, &newPos);

	if ((key & (LEFTSHIFT | RIGHTSHIFT)) != 0 && selRctLROk(&newPos)) {

		/* One of the shift keys is down. This means the user wants
		 * to change the lower-right corner of the selection
		 * rectangle.
		 */
		deselect();
		chgSelRctLR(&newPos);
		selEntsInRct();
	}
	else if ((msBtn & LEFTBUTTON) != 0) {

		/* The mouse button is still down. Determine if the mouse
		 * was placed within the selection rectangle.
		 */
		if (msInSelRct(&newPos)) {

			/* The mouse is inside the selection rectangle.
			 * Move the selection rectangle and its contents
			 * (selected entities) to a new location.
			 */
			mvSelEnts(&newPos);
		}
		else {

			/* The mouse is outside the selection rectangle.
			 * The user can define a new selection rectangle
			 * by dragging the mouse.
			 *
			 * Deselect any previously-selected entities.
			 */
			deselect();

			/* Draw a rubberband selection rectangle. */
			drawSelRct(&newPos);

			/* Select all entities that fall into the selection
			 * rectangle.
			 */
			selEntsInRct();
		}
	}
	else {

		/* See if the mouse was clicked on top of an entity. If so,
		 * select just that entity.
		 */
		if (fndEntPt(&newPos, &ent)) {
			deselect();
			setSelRct(&ent->entRct);
			selEnt(ent);
		}
		else {

			/* The mouse button was clicked in the middle of
			 * nowhere. Remove the selection rectangle.
			 */
			deselect();
		}
	}
}

/* addStfSym: Supervise the user's placement of a staff-class symbol. */
static void addStfSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos, *pOrg, *pEnd;
	register int staffHt;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	pOrg = &ent->entInfo.stfEnt.stfOrg;
	pEnd = &ent->entInfo.stfEnt.stfEnd;
	SCSPTTOWCS(&oldPos, pOrg);
	SCSPTTOWCS(&oldPos, pEnd);

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old staff. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new staff. */
			SCSPTTOWCS(&newPos, pEnd);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	staffHt = (LINESINSTAFF - 1) * STAFFSPHT + 1;
	SETRECT(&ent->entRct,
	    pOrg->x - 1,
	    pOrg->y - staffHt,
	    (pEnd->x - ent->entRct.x) + 2,
	    staffHt + 2);
}

/* addBraceSym: Supervise the user's placement of a brace-class symbol. */
static void addBraceSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos, *pOrg, *pEnd;
	register int x, y, braceHt, braceWd, aura;
	BOOLEAN getMsPos();

	COPYPOINT(pos, &oldPos);
	pOrg = &ent->entInfo.braceEnt.braceOrg;
	pEnd = &ent->entInfo.braceEnt.braceEnd;
	SCSPTTOWCS(&oldPos, pOrg);
	SCSPTTOWCS(&oldPos, pEnd);

	/* Draw the brace initially. */
	hideMouse();
	drwEnt(ent, MD_XOR);
	showMouse();

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old brace. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new brace. */
			SCSPTTOWCS(&newPos, pEnd);
			pEnd->x = pOrg->x;
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Determine the rectangle surrounding the brace. */
	aura = MAX(ent->entInfo.braceEnt.braceLnWd, 2);
	braceHt = abs(pEnd->y - pOrg->y);
	if ((float)braceHt / BRACEHT < 1.0) {
		braceHt = BRACEHT;
		pEnd->y -= BRACEHT;
	}
	braceWd = BRACEWD * ((float)braceHt / BRACEHT) * BRACEXSCALE;
	SETRECT(&ent->entRct,
	    pOrg->x - (braceWd + aura),
	    MIN(pOrg->y, pEnd->y) - aura,
	    braceWd + aura + aura,
	    braceHt + aura + aura);
}

/* addBeamSym: Supervise the user's placement of a beam-class symbol. */
static void addBeamSym(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	POINT2D oldPos, newPos;
	LINE2D *pLine;
	register int aura;
	BOOLEAN getMsPos();
	extern LINESTYLE BeamStyle;

	COPYPOINT(pos, &oldPos);
	pLine = &ent->entInfo.beamEnt.beamLn;
	SCSPTTOWCS(&oldPos, (POINT2D *)&pLine->x1);
	SCSPTTOWCS(&oldPos, (POINT2D *)&pLine->x2);

	while (getMsPos(pos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Erase the old beam line. */
			hideMouse();
			drwEnt(ent, MD_XOR);

			/* Draw the new beam line. */
			SCSPTTOWCS(&newPos, (POINT2D *)&pLine->x2);
			drwEnt(ent, MD_XOR);
			showMouse();

			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Fill in the rectangle surrounding the beam line. */
	aura = BEAMWD;
	SETRECT(&ent->entRct,
	    MIN(pLine->x1, pLine->x2) - aura,
	    MIN(pLine->y1, pLine->y2) - aura,
	    abs(pLine->x1 - pLine->x2) + aura + aura,
	    abs(pLine->y1 - pLine->y2) + aura + aura);
}

/* initSymTbl: Load Symbol Table with initial values that must be obtained
 * at runtime.
 */
void initSymTbl()
{
	register SYMBOL *sym;
	register ICONBLK *icon;
	extern OBJECT *Palette;

	rsrc_gaddr(R_TREE, ICONS, &Palette);
	for (sym = SymTbl; sym->symTyp >= 0; ++sym) {
		if (sym->symClass == RSTSYMCLASS) {

			/* Initialize the raster symbol's image bitmask
			 * and size.
			 */
			icon = (ICONBLK *)Palette[sym->objId].ob_spec;
			sym->symImg = (char *)icon->ib_pdata;
			sym->symImgWd = icon->ib_wicon;
			sym->symImgHt = icon->ib_hicon;
		}
	}
}

/* getMsPos: Determine the current position of the mouse. Limits movement
 * of the mouse to 90-degree increments if the shift key is held down.
 * Returns TRUE if the left mouse button is down.
 */
BOOLEAN getMsPos(oldPos, newPos)
register POINT2D *oldPos, *newPos;
{
	int msBtn, key;
	register int deltaX, deltaY;

	graf_mkstate(&newPos->x, &newPos->y, &msBtn, &key);

	/* If the control key is down, limit the mouse position
	 * to 90-degree angles from the origin.
	 */
	if ((key & CTRLKEY) != 0) {

		deltaX = abs(newPos->x - oldPos->x);
		deltaY = abs(newPos->y - oldPos->y);

		if (deltaX >= deltaY) {

			/* Horizontal */
			newPos->y = oldPos->y;
		}
		else if (deltaY >= deltaX) {

			/* Vertical */
			newPos->x = oldPos->x;
		}
	}
	return ((msBtn & LEFTBUTTON) != 0);
}
