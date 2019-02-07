/* Entity: Definitions used by Score Entities
 * phil comeau 12-jul-89
 * last edited 13-oct-89 0003
 *
 * Copyright 1990 Antic Publishing Inc.
 */

/* RSTENT: Raster-class entity information */
typedef struct {
	POINT2D rstOrg;			/* raster image origin (WCS) */
} RSTENT;

/* LINEENT: Line-class entity information */
typedef struct {
	LINE2D line;			/* line endpoints (WCS) */
	LINESTYLE lnStyle;		/* defines line characteristics */
} LINEENT;

/* TXTENT: Text-class entity information */
typedef struct {
	POINT2D txtOrg;			/* text origin (WCS) */
	TXTSTYLE txtStyle;		/* defines text characteristics */
	int txtChar;			/* text character */
} TXTENT;

/* BRACEENT: Brace-class entity information */

typedef struct {
	POINT2D braceOrg;		/* brace origin point (WCS)*/
	POINT2D braceEnd;		/* brace end point (WCS) */
	int braceLnWd;			/* brace line width */
} BRACEENT;

/* CRVENT: Curve-class entity information */
typedef struct {
	POINT2D crvOrg;			/* curve origin point (WCS) */
	POINT2D crvEnd;			/* curve end point (WCS) */
	char crvLnWd;			/* curve line width */
	char crvDir;			/* curve direction: UP or DOWN */
} CRVENT;

/* TRLENT: Trill-class entity information */
typedef struct {
	POINT2D trlOrg;			/* trill origin point (WCS) */
	POINT2D trlEnd;			/* trill ending point (WCS) */
} TRLENT;

/* STFENT: Staff-class entity information */
typedef struct {
	POINT2D stfOrg;			/* staff origin point (WCS) */
	POINT2D stfEnd;			/* staff end point (WCS) */
} STFENT;

/* LDGRLNENT: LedgerLine-class entity information */
typedef struct {
	POINT2D ldgrLnOrg;		/* ledgerLine origin point (WCS) */
	POINT2D ldgrLnEnd;		/* ledgerLine ending point (WCS) */
} LDGRLNENT;

/* SELENT: Selection-class entity information */

typedef struct {
	RECT2D selRct;			/* selection rectangle (WCS) */
} SELENT;

/* BEAMENT: Beam-class entity information. */
typedef struct {
	LINE2D beamLn;			/* beam endpoints */
} BEAMENT;

/* ENTITY:	Defines a symbol appearing on a page. NOTE: copyEnt() in
 *		entity.c must be changed if sizeof(ENTITY) != 26
 */
typedef struct {
	SYMBOL *entSym;			/* Pointer to the symbol which
					 * this entity is an instance of.
					 */
	RECT2D entRct;			/* rectangle (in WCS) surrounding
					 * entity.
					 */
	union {				/* entity-class specific
					 * information.
					 */
		RSTENT rstEnt;		/* raster-class entities */
		LINEENT lineEnt;	/* line-class entities */
		TXTENT txtEnt;		/* text-class entities */
		BRACEENT braceEnt;	/* brace-class entities */
		CRVENT crvEnt;		/* curve-class entities */
		TRLENT trlEnt;		/* trill-class entities */
		STFENT stfEnt;		/* staff-class entities */
		LDGRLNENT ldgrLnEnt;	/* ledgerLine-class entities */
		SELENT selEnt;		/* selection-class entities */
		BEAMENT beamEnt;	/* beam-class entities */
	} entInfo;
} ENTITY;
