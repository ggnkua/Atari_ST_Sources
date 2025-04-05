/*
 *	GEM calculator
 *	resource dependent part: screen input & output
 *	Copyright 1985 Axel T. Schreiner, Ulm, W-Germany
 */

#include <obdefs.h>
#include <gemdefs.h>
#include "b:\calc\calc.h"			/* resource */

/*
 *	tunable
 */

#define	RESOURCE	"calc.rsc"	/* resource file */
#define	DELAY		300, 0		/* button animation time */

/*
 *	macros
 */

#define	Grect(p)	(p)->g_x, (p)->g_y, (p)->g_w, (p)->g_h
#define	aGrect(p)	&(p)->g_x, &(p)->g_y, &(p)->g_w, &(p)->g_h

/*
 *	calculator globals
 */

OBJECT * Resource;			/* main tree of resource */
char Name[] = " Calculator ";		/* main tree window name */

/*
 *	initialization
 *
 *		get resource
 *		determine addresses
 *		initialize calculator execution
 *
 *	must initialize Resource and Name
 */

int Load()				/* true if loaded ok */
{	OBJECT * op;
	TEDINFO * tp;
	char * cp;

	return	rsrc_load(RESOURCE)
		&& rsrc_gaddr(R_TREE, RCALC, & Resource)
		&& rsrc_gaddr(R_OBJECT, RDISPLAY, & op)
		&& op->ob_type == G_BOXTEXT
		&& (tp = (TEDINFO *) op->ob_spec)
		&& (cp = (char *) tp->te_ptext)
		&& ! Calc(BCLEAR, cp, tp->te_txtlen);
}

/*
 *	keyboard input
 */

int Keyboard(key)			/* true if task should terminate */
	int key;			/* coded keyboard key */
{	static struct map { int ch, code; } map[] = {
		'0', BZERO,		'1', BONE,
		'2', BTWO,		'3', BTHREE,
		'4', BFOUR,		'5', BFIVE,
		'6', BSIX,		'7', BSEVEN,
		'8', BEIGHT,		'9', BNINE,

		'a', BA, 'A', BA,	'b', BB, 'B', BB,
		'c', BC, 'C', BC,	'd', BD, 'D', BD,
		'e', BE, 'E', BE,	'f', BF, 'F', BF,

		/* 0: not available from keyboard */

		0, BDEC,	'O', BOCT,	'H', BHEX,
		0, BCLEAR,
		'=', BEQUAL,	'\n', BEQUAL,	'\r', BEQUAL,
		'|', BOR,	'^', BXOR,	'&', BAND,
		'<', BLSH,	'>', BRSH,
		'+', BADD,	'-', BSUB,
		'*', BMULT,	'/', BDIV,	'%', BREM,
		'(', BLPAR,	')', BRPAR,
		0, BMINUS,	'~', BCOMP,
		0, BCENTRY,

		/* table scanned to code < 0 */

		0, -1 };
	struct map * mp;

	if (key &= 0x7f)		/* ASCII part only */
		for (mp = map; mp->code >= 0; ++ mp)
			if (mp->ch == key)
				return Button(mp->code);
	return 0;
}

/*
 *	click on object
 */

int Button(code)			/* true if task should terminate */
	int code;			/* button index in Resource */
{	int i;
	OBJECT * op;

	if (! rsrc_gaddr(R_OBJECT, code, & op)
	    || ! (op->ob_flags & SELECTABLE))
		return 0;
	objc_change(Resource, code, 0, Resource->ob_x, Resource->ob_y,
		Resource->ob_width, Resource->ob_height, SELECTED, 1);
	if (! (i = Calc(code)))
		objc_draw(Resource, RDISPLAY, 1,
			Resource->ob_x, Resource->ob_y,
			Resource->ob_width, Resource->ob_height);
	evnt_timer(DELAY);
	objc_change(Resource, code, 0, Resource->ob_x, Resource->ob_y,
		Resource->ob_width, Resource->ob_height, NORMAL, 1);
	return i;
}
