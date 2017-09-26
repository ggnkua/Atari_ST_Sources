/* erzeugt mit RSM2CS V1.01 Beta von Armin Diedering aus "H:\SRC\THING\THINGRUN\SRC\THINGRUN.RSC" */
/* nach Sourcen von Holger Weets */

#include <portab.h>

#include <gem.h>

static char rs_s0[] = "";
static char rs_s1[] = "";

#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

#define RS_NTED 1

TEDINFO rs_tedinfo[] = {
	"AAAAAAAA.AAA",
	rs_s0,
	rs_s1,
	IBM, 0, TE_CNTR, 4480, 0, 0, 13, 1
};

#define RS_NOBS 1

OBJECT rs_obj[] = {
#define TR0 0
/* TREE 0 */
	-1, -1, -1, G_BOXTEXT,			/*** 0 ***/
	OF_LASTOB,
	OS_NORMAL,
	(long) &rs_tedinfo[0],
	0, 0, 34, 1
};

OBJECT *rs_tree[] = {
&rs_obj[TR0]
};

#define RS_NFSTR 3

char *rs_fstr[] = {
	"[0][ThingRun 1.11|Copyright \275 1995 Arno Welzel|Copyright \275 1996-98 T. Binder][  OK  ]",
	"[3][Es steht nicht mehr gen\201gend|Arbeitsspeicher zur Verf\201gung!| |Not enough memory!][Abbruch / Cancel]",
	"Programm beendet, Taste dr\201cken / Program terminated, press any key"
};

