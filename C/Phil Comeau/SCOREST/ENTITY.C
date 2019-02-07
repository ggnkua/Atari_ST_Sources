/* entity: Entity (instantiated symbol) specific functions
 * phil comeau 10-feb-88
 * last edited 14-oct-89 0010
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <math.h>
#include <osbind.h>
#include <mylib.h>
#include <list.h>
#include <graphics.h>
#include "graph.h"
#include "scoredef.h"
#include "symbol.h"
#include "entity.h"

/* ENTHANGER: A place to hang an entity. Used in entity storage management.
 */
typedef struct entHanger {
	struct entHanger *entLink;	/* link to the next hanger in list.
					 */
	ENTITY ent;
} ENTHANGER;

extern FILE *Debug;

/* Global variables. */

static ENTHANGER *FreeEnts = NULL;	/* List of free entities. */

/* cmpEnt: Compare two entities, returning a number indicating their
 * relative ordering on their page.
 */
int cmpEnt(ent1, ent2)
register ENTITY *ent1, *ent2;
{
	POINT2D ent1Org, ent2Org;

	/* Determine the entities' origins */
	getEntOrg(ent1, &ent1Org);
	getEntOrg(ent2, &ent2Org);

	/* Entities are ordered on the page vertically first, then
	 * horizontally.
	 */
	if (ent1Org.y > ent2Org.y) {
		return (1);
	}
	else if (ent1Org.y < ent2Org.y) {
		return (-1);
	}
	else {
		/* The entities are vertically parallel. */
		if (ent1Org.x > ent2Org.x) {
			return (1);
		}
		else if (ent1Org.x < ent2Org.x) {
			return (-1);
		}
		else {

			/* The entities are coincident. Differentiate them
			 * by type.
			 */
			return (ent1->entSym->symTyp -
			    ent2->entSym->symTyp);
		}
	}
}

/* getEntOrg: Determine the WCS origin of an entity. */
getEntOrg(ent, entOrg)
register ENTITY *ent;
register POINT2D *entOrg;
{
	switch (ent->entSym->symClass) {
	case RSTSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.rstEnt.rstOrg.x,
		    ent->entInfo.rstEnt.rstOrg.y);
		break;
	case LINESYMCLASS:
		SETPOINT(entOrg, ent->entInfo.lineEnt.line.x1,
		    ent->entInfo.lineEnt.line.y1);
		break;
	case CRVSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.crvEnt.crvOrg.x,
		    ent->entInfo.crvEnt.crvOrg.y);
		break;
	case TXTSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.txtEnt.txtOrg.x,
		    ent->entInfo.txtEnt.txtOrg.y);
		break;
	case TRLSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.trlEnt.trlOrg.x,
		    ent->entInfo.trlEnt.trlOrg.y);
		break;
	case LDGRLNSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.ldgrLnEnt.ldgrLnOrg.x,
		    ent->entInfo.ldgrLnEnt.ldgrLnOrg.y);
		break;
	case SELSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.selEnt.selRct.x,
		    ent->entInfo.selEnt.selRct.y);
		break;
	case STFSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.stfEnt.stfOrg.x,
		    ent->entInfo.stfEnt.stfOrg.y);
		break;
	case BRACESYMCLASS:
		SETPOINT(entOrg, ent->entInfo.braceEnt.braceOrg.x,
		    ent->entInfo.braceEnt.braceOrg.y);
		break;
	case BEAMSYMCLASS:
		SETPOINT(entOrg, ent->entInfo.beamEnt.beamLn.x1,
		    ent->entInfo.beamEnt.beamLn.y1);
		break;
	}
}

/* drwEnt: Draw an entity on the screen, using the specified writing mode.
 */
drwEnt(ent, wrtMode)
register ENTITY *ent;
register int wrtMode;
{
	register int symClass;

	symClass = ent->entSym->symClass;

	if (symClass == RSTSYMCLASS) {
		if (wrtMode == MD_XOR) {
			wrtMode = S_XOR_D;
		}
		else if (wrtMode == MD_REPLACE || wrtMode == MD_TRANS) {
			wrtMode = S_OR_D;
		}
	}
	else if (symClass == TXTSYMCLASS) {
		if (wrtMode == MD_REPLACE) {
			wrtMode = MD_TRANS;
		}
	}
	setWrtMode(wrtMode);

	switch (ent->entSym->symClass) {
	case RSTSYMCLASS:
		drwRstEnt(ent, wrtMode);
		break;
	case LINESYMCLASS:
		drwLineEnt(ent);
		break;
	case CRVSYMCLASS:
		drwCrvEnt(ent);
		break;
	case TXTSYMCLASS:
		drwTxtEnt(ent);
		break;
	case TRLSYMCLASS:
		drwTrlEnt(ent);
		break;
	case LDGRLNSYMCLASS:
		drwLdgrLnEnt(ent);
		break;
	case SELSYMCLASS:
		drwSelEnt(ent);
		break;
	case STFSYMCLASS:
		drwStfEnt(ent);
		break;
	case BRACESYMCLASS:
		drwBraceEnt(ent);
		break;
	case BEAMSYMCLASS:
		drwBeamEnt(ent);
		break;
	}
}

/* drwRstEnt: Draw an entity of Raster symbol class */
drwRstEnt(ent, wrtMode)
register ENTITY *ent;
register int wrtMode;
{
	register SYMBOL *entSym;
	POINT2D wcsOrg, scsOrg;
	RECT2D scsRct;

	/* Translate the entity's origin (which is in WCS) to SCS. */
	SETPOINT(&wcsOrg, ent->entInfo.rstEnt.rstOrg.x,
	    ent->entInfo.rstEnt.rstOrg.y);
	WCSPTTOSCS(&wcsOrg, &scsOrg);

	/* Factor in the displacement to the entity's origin. */
	entSym = ent->entSym;
	MOVEPOINT(&scsOrg, -(entSym->symOrgRct.x + entSym->symMsOff.x),
	    -(entSym->symOrgRct.y + entSym->symMsOff.y));

	/* Build a rectangle describing the entity's screen location. */
	SETRECT(&scsRct, scsOrg.x, scsOrg.y, entSym->symImgWd,
	    entSym->symImgHt);

	/* Draw the raster entity. */
	drwRst(entSym->symImg, &scsRct, wrtMode);
}

/* drwLineEnt: Draw an entity of Line symbol class */
drwLineEnt(ent)
register ENTITY *ent;
{
	LINE2D scsLine;

	/* Set the line's appearance as specified in its style information.
	 */
	setLnStyle(&ent->entInfo.lineEnt.lnStyle);

	/* Convert the line's position to SCS. */
	WCSLNTOSCS(&ent->entInfo.lineEnt.line, &scsLine);

	drwLine(&scsLine);
}

/* drwCrvEnt: Draw an entity of Curve symbol class */
drwCrvEnt(ent)
register ENTITY *ent;
{
	static POINT2D dnCrv[CRVSZ] = {{0, 0}, {20, -18}, {30, -24}, {40, -27},
	    {50, -30}, {60, -33}, {70, -36}, {80, -38}, {90, -39},
	    {100, -40}, {110, -42}, {140, -43}, {180, -45}, {220, -43},
	    {250, -42}, {260, -40}, {270, -39}, {280, -38}, {290, -36},
	    {300, -33}, {310, -30}, {320, -27}, {330, -24}, {340, -18},
	    {360, 0}
	};
	static POINT2D upCrv[CRVSZ] = {{0, 0}, {20, 18}, {30, 24}, {40, 27},
	    {50, 30}, {60, 33}, {70, 36}, {80, 38}, {90, 39},
	    {100, 40}, {110, 42}, {140, 43}, {180, 45}, {220, 43},
	    {250, 42}, {260, 40}, {270, 39}, {280, 38}, {290, 36},
	    {300, 33}, {310, 30}, {320, 27}, {330, 24}, {340, 18},
	    {360, 0}
	};
	POINT2D transCrv[CRVSZ];
	register POINT2D *pSrc, *pDst;
	register float scale, c, s, dist, angle, v;
	register int x, y, seg, deltaX, deltaY;
	static LINESTYLE crvStyle = {0, SQUAREEND, SOLIDLNPAT};
	extern int GHandle;

	/* Calculate distance from origin */
	deltaX = MAX(abs(ent->entInfo.crvEnt.crvEnd.x -
	    ent->entInfo.crvEnt.crvOrg.x), MINCRVWD);
	deltaY = abs(ent->entInfo.crvEnt.crvEnd.y -
	    ent->entInfo.crvEnt.crvOrg.y);
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

	/* Calculate angle from mouse position to origin */
	if (deltaX == 0) {
		angle = MAXCRVANGLE;
	}
	else if (deltaY == 0) {
		angle = 0.0;
	}
	else {
		v = (float)deltaX / dist;
		if (v > 0.99999999) {
			v = 0.99999999;
		}
		angle = (float)acos((double)v);
	}
	if (ent->entInfo.crvEnt.crvEnd.y <
	    ent->entInfo.crvEnt.crvOrg.y) {
		angle = 2.0 * dcpi - angle;
	}
	c = (float)cos((double)angle);
	s = (float)sin((double)angle);

	/* Calculate scale */
	scale = dist / CRVWD;

	/* Translate the curve to its new position. */
	pSrc = ent->entInfo.crvEnt.crvDir == UP ? upCrv : dnCrv;
	pDst = transCrv;
	for (seg = 0; seg < CRVSZ; ++seg) {
		x = scale * (pSrc->x * c - pSrc->y * s) +
		   ent->entInfo.crvEnt.crvOrg.x;
		pDst->y = scale * (pSrc->x * s + pSrc->y * c) +
		    ent->entInfo.crvEnt.crvOrg.y;
		pDst->y = MAX(pDst->y, 0);
		pDst->x = x;
		WCSPTTOSCS(pDst, pDst);
		++pSrc;
		++pDst;
	}

	/* Set the curve's line style. The line width is defined with the
	 * curve entity.
	 */
	crvStyle.lnW = ent->entInfo.crvEnt.crvLnWd;
	setLnStyle(&crvStyle);

	/* Draw the translated curve. */
	v_pline(GHandle, CRVSZ, transCrv);
}

/* drwTxtEnt: Draw an entity of Text symbol class */
drwTxtEnt(ent)
register ENTITY *ent;
{
	char txtStr[2];
	POINT2D scsPos;
	extern int GHandle;

	WCSPTTOSCS(&ent->entInfo.txtEnt.txtOrg, &scsPos);
	setTxtStyle(&ent->entInfo.txtEnt.txtStyle);
	txtStr[0] = ent->entInfo.txtEnt.txtChar;
	txtStr[1] = '\0';
	v_gtext(GHandle, scsPos.x, scsPos.y, txtStr);
}

/* drwTrlEnt: Draw an entity of Trill symbol class */
drwTrlEnt(ent)
register ENTITY *ent;
{
	static int trill[] = {0x3c3c, 0x5e5e, 0x8f8f, 0x0707};
	static int trill45[] = {0x7777, 0xffff, 0xbbbb, 0x3333};
	register int deltaX, deltaY, xDbl, yDbl, xHalf, yHalf, ln, xAct,
	    yAct;
	LINE2D line;
	register BOOLEAN fortyFive;

	deltaX = abs(ent->entInfo.trlEnt.trlEnd.x -
	    ent->entInfo.trlEnt.trlOrg.x);
	deltaY = abs(ent->entInfo.trlEnt.trlEnd.y -
	    ent->entInfo.trlEnt.trlOrg.y);
	xDbl = deltaX * 2;
	yDbl = deltaY * 2;
	xHalf = deltaX / 2;
	yHalf = deltaY / 2;

	fortyFive = FALSE;

	/* Fix the endpoints so the trill is always drawn at multiples
	 * of 45 degrees.
	 */
	if (((deltaX >= deltaY && deltaX <= yDbl) ||
	    (deltaX <= deltaY && deltaX >= yHalf)) &&
	    ((deltaY >= deltaX && deltaY <= xDbl) ||
	    (deltaY <= deltaX && deltaY >= xHalf))) {

		/* 45 degrees */
		if (ent->entInfo.trlEnt.trlEnd.x >
		    ent->entInfo.trlEnt.trlOrg.x) {
			ent->entInfo.trlEnt.trlEnd.x =
			    ent->entInfo.trlEnt.trlOrg.x + deltaY;
		}
		else {
			ent->entInfo.trlEnt.trlEnd.x =
			    ent->entInfo.trlEnt.trlOrg.x - deltaY;
		}

		/* Determine what adjustments are needed as the trill
		 * line components are drawn. The trill is made up of 4
		 * line patterns. The endpoints of each line in the trill
		 * must be adjusted based on the trill's direction.
		 */
		if ((ent->entInfo.trlEnt.trlEnd.x >=
		    ent->entInfo.trlEnt.trlOrg.x &&
		    ent->entInfo.trlEnt.trlEnd.y >=
		    ent->entInfo.trlEnt.trlOrg.y) ||
		    (ent->entInfo.trlEnt.trlEnd.x <=
		    ent->entInfo.trlEnt.trlOrg.x &&
		    ent->entInfo.trlEnt.trlEnd.y <=
		    ent->entInfo.trlEnt.trlOrg.y)) {
			xAct = INCREMENT;
			yAct = DECREMENT;
		}
		else {
			xAct = yAct = INCREMENT;
		}
		fortyFive = TRUE;
	}
	else if (deltaX > deltaY) {

		/* 0 degrees (horizontal) */
		ent->entInfo.trlEnt.trlEnd.y = ent->entInfo.trlEnt.trlOrg.y;
		xAct = NOCHANGE;
		yAct = INCREMENT;
	}
	else if (deltaY > deltaX) {

		/* 90 degrees (vertical) */
		ent->entInfo.trlEnt.trlEnd.x = ent->entInfo.trlEnt.trlOrg.x;
		xAct = INCREMENT;
		yAct = NOCHANGE;
	}

	/* Set the trill's line style. */
	setLnWd(1);
	setLnEnd(SQUAREEND);

	/* Draw the line once for each line in the trill pattern. */
	switch (xAct) {
	case INCREMENT:
		line.x1 = ent->entInfo.trlEnt.trlOrg.x - NTRILLLINES / 2;
		line.x2 = ent->entInfo.trlEnt.trlEnd.x - NTRILLLINES / 2;
		break;
	case DECREMENT:
		line.x1 = ent->entInfo.trlEnt.trlOrg.x + NTRILLLINES / 2;
		line.x2 = ent->entInfo.trlEnt.trlEnd.x + NTRILLLINES / 2;
		break;
	case NOCHANGE:
		line.x1 = ent->entInfo.trlEnt.trlOrg.x;
		line.x2 = ent->entInfo.trlEnt.trlEnd.x;
		break;
	}

	switch (yAct) {
	case INCREMENT:
		line.y1 = ent->entInfo.trlEnt.trlOrg.y - NTRILLLINES / 2;
		line.y2 = ent->entInfo.trlEnt.trlEnd.y - NTRILLLINES / 2;
		break;
	case DECREMENT:
		line.y1 = ent->entInfo.trlEnt.trlOrg.y + NTRILLLINES / 2;
		line.y2 = ent->entInfo.trlEnt.trlEnd.y + NTRILLLINES / 2;
		break;
	case NOCHANGE:
		line.y1 = ent->entInfo.trlEnt.trlOrg.y;
		line.y2 = ent->entInfo.trlEnt.trlEnd.y;
	}
	WCSLNTOSCS(&line, &line);

	for (ln = 0; ln < NTRILLLINES; ++ln) {
		setLnTyp(fortyFive ? trill45[ln] : trill[ln]);
		drwLine(&line);
		switch (xAct) {
		case INCREMENT:
			++line.x1;
			++line.x2;
			break;
		case DECREMENT:
			--line.x1;
			--line.x2;
			break;
		}
		switch (yAct) {
		case INCREMENT:
			++line.y1;
			++line.y2;
			break;
		case DECREMENT:
			--line.y1;
			--line.y2;
		}
	}
}

/* drwLdgrLnEnt: Draw an entity of LedgerLine symbol class */
drwLdgrLnEnt(ent)
register ENTITY *ent;
{
	LINE2D ldgrLn;
	register int dir, line, distance, displacement, nLines;
	POINT2D ldgrLnOrg, ldgrLnEnd;
	static LINESTYLE ldgrLnStyle = {1, SQUAREEND, SOLIDLNPAT};

	WCSPTTOSCS(&ent->entInfo.ldgrLnEnt.ldgrLnOrg, &ldgrLnOrg);
	WCSPTTOSCS(&ent->entInfo.ldgrLnEnt.ldgrLnEnd, &ldgrLnEnd);
	dir = ldgrLnOrg.y > ldgrLnEnd.y ? UP : DOWN;
	distance = abs(ldgrLnOrg.y - ldgrLnEnd.y);
	nLines = distance / STAFFSPHT;
	displacement = dir == UP ? -STAFFSPHT : STAFFSPHT;
	SETLINE(&ldgrLn, ldgrLnOrg.x - LDGRLNWD / 2, ldgrLnOrg.y,
	    ldgrLn.x1 + LDGRLNWD, ldgrLnOrg.y);
	setLnStyle(&ldgrLnStyle);

	for (line = 0; line < nLines; ++line) {
		ldgrLn.y1 += displacement;
		ldgrLn.y2 += displacement;
		drwLine(&ldgrLn);
	}
}

/* drwSelEnt: Draw an entity of Selection symbol class */

drwSelEnt(ent)
ENTITY *ent;
{
	/* Do nothing. */
}

/* drwStfEnt: Draw an entity of Staff symbol class */
drwStfEnt(ent)
register ENTITY *ent;
{
	LINE2D line;
	register int i, y;
	POINT2D p;
	static LINESTYLE stfLnStyle = {1, SQUAREEND, SOLIDLNPAT};

	/* Set the line style as needed for staff lines. */
	setLnStyle(&stfLnStyle);

	/* Draw the lines in the staff. Note that the staff origin
	 * references the LL corner of the staff.
	 */
	y = ent->entInfo.stfEnt.stfOrg.y;
	for (i = 0; i < LINESINSTAFF; ++i) {
		SETPOINT(&p, ent->entInfo.stfEnt.stfOrg.x, y);
		WCSPTTOSCS(&p, (POINT2D *)&line.x1);
		SETPOINT(&p, ent->entInfo.stfEnt.stfEnd.x, y);
		WCSPTTOSCS(&p, (POINT2D *)&line.x2);
		drwLine(&line);
		y -= STAFFSPHT;
	}
}

/* drwBraceEnt: Draw an entity of Brace symbol class */
drwBraceEnt(ent)
register ENTITY *ent;
{
	static POINT2D brace[BRACESZ] = {{0, 0}, {-1, 0}, {-3, -1}, {-4, -2},
	    {-4, -9}, {-5, -11}, {-7, -12}, {-5, -13}, {-4, -15}, {-4, -22},
	    {-3, -23}, {-1, -24}, {0, -24}
	};
	POINT2D transBrace[BRACESZ];
	register POINT2D *pSrc, *pDst;
	register float xScale, yScale;
	register int x, y, seg, deltaY;
	static LINESTYLE braceStyle = {0, SQUAREEND, SOLIDLNPAT};
	extern int GHandle;

	/* Calculate distance from origin */
	deltaY = abs(ent->entInfo.braceEnt.braceEnd.y -
	    ent->entInfo.braceEnt.braceOrg.y);

	/* Calculate scale */
	yScale = (float)deltaY / BRACEHT;
	if (yScale < 1.0) {
		yScale = 1.0;
	}
	xScale = yScale * BRACEXSCALE;
	if (ent->entInfo.braceEnt.braceEnd.y >
	    ent->entInfo.braceEnt.braceOrg.y) {
		yScale = -yScale;
	}

	/* Translate and scale the brace. */
	pSrc = brace;
	pDst = transBrace;
	for (seg = 0; seg < BRACESZ; ++seg) {
		pDst->x = xScale * pSrc->x +
		    ent->entInfo.braceEnt.braceOrg.x;
		pDst->y = yScale * pSrc->y +
		    ent->entInfo.braceEnt.braceOrg.y;
		pDst->y = MAX(pDst->y, 0);
		WCSPTTOSCS(pDst, pDst);
		++pSrc;
		++pDst;
	}

	/* Draw the translated, scaled brace. */
	braceStyle.lnW = ent->entInfo.braceEnt.braceLnWd;
	setLnStyle(&braceStyle);
	v_pline(GHandle, BRACESZ, transBrace);
}

/* drwBeamEnt: Draw an entity of Beam symbol class */
drwBeamEnt(ent)
register ENTITY *ent;
{
	LINE2D scsLine, line;
	extern LINESTYLE BeamStyle;
	register int w, i;

	/* Set the line's appearance as specified in the Beam style
	 * information.
	 */
	setLnStyle(&BeamStyle);

	/* Convert the beam line's position to SCS. */
	WCSLNTOSCS(&ent->entInfo.beamEnt.beamLn, &scsLine);

	/* Draw the beam line to the required thickness so that the
	 * endpoints all have the same x origin.
	 */
	COPYLINE(&scsLine, &line);
	drwLine(&line);
	i = 1;
	for (w = 1; w < BEAMWD; w += 2) {
		SETLINE(&line, scsLine.x1, scsLine.y1 - i, scsLine.x2,
		    scsLine.y2 - i);
		drwLine(&line);
		SETLINE(&line, scsLine.x1, scsLine.y1 + i, scsLine.x2,
		    scsLine.y2 + i);
		drwLine(&line);
		++i;
	}
}

/* ptOnEnt: Determine if a point is contained within the rectangle
 * surrounding an entity. Return TRUE if so.
 */
BOOLEAN ptOnEnt(pos, ent)
register POINT2D *pos;
register ENTITY *ent;
{
	return (POINTINRECT(pos, &ent->entRct));
}

/* mvEnt: Move an entity's page position by a specified offset. */
mvEnt(ent, offset)
register ENTITY *ent;
register POINT2D *offset;
{
	switch (ent->entSym->symClass) {
	case RSTSYMCLASS:
		MOVEPOINT(&ent->entInfo.rstEnt.rstOrg, offset->x, offset->y);
		break;
	case LINESYMCLASS:
		MOVELINE(&ent->entInfo.lineEnt.line, offset->x, offset->y);
		break;
	case TXTSYMCLASS:
		MOVEPOINT(&ent->entInfo.txtEnt.txtOrg, offset->x, offset->y);
		break;
	case CRVSYMCLASS:
		MOVEPOINT(&ent->entInfo.crvEnt.crvOrg, offset->x, offset->y);
		MOVEPOINT(&ent->entInfo.crvEnt.crvEnd, offset->x, offset->y);
		break;
	case TRLSYMCLASS:
		MOVEPOINT(&ent->entInfo.trlEnt.trlOrg, offset->x, offset->y);
		MOVEPOINT(&ent->entInfo.trlEnt.trlEnd, offset->x, offset->y);
		break;
	case LDGRLNSYMCLASS:
		MOVEPOINT(&ent->entInfo.ldgrLnEnt.ldgrLnOrg, offset->x,
		    offset->y);
		MOVEPOINT(&ent->entInfo.ldgrLnEnt.ldgrLnEnd, offset->x,
		    offset->y);
		break;
	case SELSYMCLASS:

		/* No-op. */
		break;
	case STFSYMCLASS:
		MOVEPOINT(&ent->entInfo.stfEnt.stfOrg, offset->x, offset->y);
		MOVEPOINT(&ent->entInfo.stfEnt.stfEnd, offset->x, offset->y);
		break;
	case BRACESYMCLASS:
		MOVEPOINT(&ent->entInfo.braceEnt.braceOrg, offset->x,
		    offset->y);
		MOVEPOINT(&ent->entInfo.braceEnt.braceEnd, offset->x,
		    offset->y);
		break;
	case BEAMSYMCLASS:
		MOVELINE(&ent->entInfo.beamEnt.beamLn, offset->x, offset->y);
		break;
	}

	/* Adjust the entity's rectangle. */
	MOVERECT(&ent->entRct, offset->x, offset->y);
}

/* dragEntsInLst: Drag all the entities in a list by tracking the mouse. */
dragEntsInLst(lst, initMsPos, offset)
LIST *lst;
register POINT2D *initMsPos, *offset;
{
	POINT2D oldPos, newPos;
	register LISTNODE *pLst;
	ENTITY *ent;
	extern BOOLEAN getMsPos();

	COPYPOINT(initMsPos, &oldPos);

	while (getMsPos(initMsPos, &newPos)) {
		if (!POINTEQUAL(&newPos, &oldPos)) {

			/* Move the entities by the offset from
			 * their original location.
		 	 */
			SETPOINT(offset, newPos.x - oldPos.x,
			    newPos.y - oldPos.y);

			for (pLst = ListNext(&lst->head); pLst != NULL;
	    		    pLst = ListNext(pLst)) {
				ent = (ENTITY *)ListContents(pLst);
				hideMouse();
				drwEnt(ent, MD_XOR);
				mvEnt(ent, offset);
				drwEnt(ent, MD_XOR);
				showMouse();
			}
			COPYPOINT(&newPos, &oldPos);
		}
	}

	/* Calculate a final offset. */
	SETPOINT(offset, newPos.x - initMsPos->x, newPos.y - initMsPos->y);
}

/* drwEntsInLst: Draw the entities in a list. */
drwEntsInLst(lst, wrtMode)
register LIST *lst;
register int wrtMode;
{
	register LISTNODE *pLst;

	for (pLst = ListNext(&lst->head); pLst != NULL;
	    pLst = ListNext(pLst)) {
		drwEnt((ENTITY *)ListContents(pLst), wrtMode);
	}
}

/* cpEntLst: Copy a list of entities. */
BOOLEAN cpEntLst(srcLst, dstLst)
LIST *srcLst;
register LIST *dstLst;
{
	register ENTITY *ent;
	register LISTNODE *pS;
	static MSFORM busyMsForm = {HOURGLASS, {0}};
	ENTITY *allocEnt();
	int cmpEnt();

	svMsForm();
	setMsForm(&busyMsForm);
	for (pS = ListNext(&srcLst->head); pS != NULL; pS = ListNext(pS)) {

		/* Copy the entity's contents. */
		if ((ent = allocEnt()) == NULL) {
			return (FALSE);
		}
		copyEnt((ENTITY *)ListContents(pS), ent);
		if (ListAdd(dstLst, ent) == NULL) {
			return (FALSE);
		}
	}

	rstMsForm();
	return (TRUE);
}

#ifdef DEBUG
/* dumpEntLst: dump a list of entities (for debugging) */
dumpEntLst(lst)
struct List *lst;
{
	struct List *pLst;
	ENTITY *ent;

	for (pLst = ListNext(lst); pLst != NULL; pLst = ListNext(pLst)) {
		ent = (ENTITY *)ListContents(pLst);
		fprintf(Debug, "pLst=0x%lx pLst->ListNext=0x%lx\n", pLst,
		    pLst->ListNext);
		fprintf(Debug, "0x%lx Entity: entSym=0x%lx symTyp=%d ",
		    ent, ent->entSym, ent->entSym->symTyp);
		fprintf(Debug, "entRct=(%d,%d) [%d,%d]\n", ent->entRct.x,
		    ent->entRct.y, ent->entRct.w, ent->entRct.h);
	}
	fflush(Debug);
}
#endif

/* allocEnt: Allocate a new entity. Returns NULL if there's no more room. */
ENTITY *allocEnt()
{
	register ENTHANGER *blk, **pPrev;
	register int i;
	register long avail, entsInBlk;
	extern char *malloc();

	/* See if we have to allocate a block of entities. */
	if (FreeEnts == NULL) {

		/* The free list is empty. Allocate 1/4 the available
		 * memory for a block of entities.
		 */
		avail = Malloc(-1L);
		entsInBlk = (avail / 4) / sizeof(ENTITY);
		if ((blk =
		    (ENTHANGER *)Malloc(entsInBlk * sizeof(ENTHANGER))) ==
		    NULL) {
			return (NULL);
		}

		/* Add the allocated entities to the free list. */
		pPrev = &FreeEnts;
		for (i = 0; i < entsInBlk; ++i) {
			*pPrev = blk;
			pPrev = &blk->entLink;
			++blk;
		}
		*pPrev = NULL;
	}

	/* Allocate the next entity. */
	blk = FreeEnts;
	FreeEnts = FreeEnts->entLink;
	return (&blk->ent);
}

/* freeEnt: Return the space allocated to an entity. */
freeEnt(ent)
register char *ent;
{
	register ENTHANGER *entHanger;

	/* Adjust the entity pointer back to the hanger's link. */
	entHanger = (ENTHANGER *)(ent - sizeof(ENTHANGER *));

	/* Add the freed entity to the head of the free list. */
	entHanger->entLink = FreeEnts;
	FreeEnts = entHanger;
}

/* copyEnt: Copy one entity to another. */
copyEnt(entSrc, entDst)
register ENTITY *entSrc, *entDst;
{
	/* WARNING: This assumes sizeof(ENTITY) == 26! */
	asm {
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
		move.w	(entSrc)+,(entDst)+
	}
}
