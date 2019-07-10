/*
 * hothelp.c -- Menu-driven help functions for citadel
 *
 * 88Jul20 orc	Adapted/rewritten for STadel
 */

#include "ctdl.h"
#include "config.h"
#include "log.h"
#include "msg.h"
#include "protocol.h"
#include "citlib.h"
#include "citadel.h"	/* declarations specific to citadel.tos */

/*
 * Notes:
 *
 * In CTDL.C instead of have the doHelp() call tutorial() it should now
 * call hothelp(filename).
 * The code isn't commented, but you should be able to see what's happening,
 * it is very straightforward. If you can't decipher something drop me a
 * note.
 *
 * In the HeLP files, you insert lines containing % sign followed by the
 * topic (read: filename) of the entries you want to have displayed in
 * the menu. Add a space and then enter text to describe it.
 * For example, an excerpt from a help file:
 *
 * %FILES This menu item will display FILES.HLP
 * %DOHELP This entry will re-show the main help file
 * %FOO Help for idiots... :-)
 *
 * etc...
 *
 * The file name will be padded out to 8 characters and a letter inside
 * square brackets will be added. The above will format into:
 *
 * [a] FILES     This menu item will display FILES.HLP
 * [b] DOHELP    This entry will reshow the main help file
 * [c] FOO       Help for idiots... :-)
 *
 * And then the prompt asking for a choice will appear. Every help file
 * can contain these entries, and there is no limit to the depth that
 * this routine can display menus.  If there are no % signs in the help
 * file then no prompt for a choice is printed (cause no choices were
 * displayed, right?).  I believe these are all the changes I have made,
 * I put these routines in MISC.C...
 *
 *             Paul Gauthier
 */

typedef char aMenu[26][9];

#define helpline() \
if (usingWCprotocol == ASCII && !readbit(logBuf,uEXPERT)) \
mformat("\r[J]ump [P]ause [S]top\r")

/*
 * printhelpfile() - print out a helpfile.
 *
 * If a source* line begins with a %, it indicates a menu line
 * in the helpfile.  Menu items are go from 'a' to 'z', with additional
 * entries being ignored.  SPECIAL CASE: Lines beginning with '%%' are
 * printed (sans '%%') iff we're processing '%' menu lines.  It returns
 * the # of menu choices found.  The 'do_menu' flag controls whether
 * '%' lines are menu-ised or swallowed.
 */
static int
printhelpfile(FILE *helpfile, aMenu menu, int do_menu)
{
    char buf[MAXWORD];
    int count = 0;		/* # items found			*/
    char *selection;
    char *menutext;
    int flag = NO;

    doCR();
    while (fgets(buf, MAXWORD-1, helpfile) && outFlag != OUTSKIP) {
	if (buf[0] == '%') {
	    if (do_menu) {
		if (buf[1] == '%')
		    mformat(&buf[2]);
		else if (count < 26) {	/* menu time!	*/
		    selection = strtok(1+buf, "\t ");
		    if (menutext = strtok(NULL, "\n")) {
			strupr(selection);
			copystring(menu[count], selection, 9);
			if (flag)
			    doCR();
			CRfill = "%17c ";
			CRftn = retfmt;
			mprintf("  [%c] %-8s %s", 'a' + count, selection,
				menutext);
			CRftn = NULL;
			doCR();
			count++;
			flag = NO;
		    }
		}
	    }
	    /* NOTE: we swallow any % lines we can't or don't want to use. */
	}
	else {
	    flag = YES;
	    mformat(buf);
	}
    }
    if (flag)
	doCR();
    return count;
}

/*
 * hothelp() - does a tree structured help tutorial
 */
int
hothelp(char *filename)
{
    FILE *helpfile;
    PATHBUF fn;
    char nextfile[9];
    aMenu list;
    int  more, count, key;

    strcpy(nextfile, filename);
    do {
	more = NO;
	ctdlfile(fn, cfg.helpdir, "%s.hlp", nextfile);
	if (helpfile=safeopen(fn, "r")) {
	    outFlag = OUTOK;
	    helpline();
	    if ((count = printhelpfile(helpfile, list, YES))
	    	&& outFlag != OUTSKIP) {
		outFlag = OUTOK;
		mprintf("\rPress the letter [a-%c] of your choice or [return]: ",
			(('a'-1) + count));
		while ((key=tolower(getnoecho())) != '\n' && onLine())
		    if (key >= 'a' && key <= ('a'-1)+count) {
			oChar(key);
			strcpy(nextfile, list[key-'a']);
			more = YES;
			break;
		    }
		    else oChar(7);
	    }
	    fclose(helpfile);
	}
	else {
	    mprintf("No %s\r", nextfile);
	    return NO;
	}
    } while (more);
    if (outFlag == OUTSKIP)
	outFlag = OUTOK;
    doCR();
    return YES;
}

int
blurb(char *name, int impervious)
{
	PATHBUF fn;
	FILE *f;

	ctdlfile(fn, cfg.helpdir, "%s.blb", name);
	if ((f = fopen(fn, "r")) == NULL)
		return NO;
	if (impervious)
		outFlag = IMPERVIOUS;
	(void) printhelpfile(f, NULL, NO);
	outFlag = OUTOK;
	fclose(f);
	return YES;
}

/*
 * dobanner -- Spit out random rotating banner
 */
int
dobanner(void)
{
	static int oldbanner = 0;
	int i;
	PATHBUF fn;
	FILE *f;

	for (;;) {
	    i = (int)Random();
	    i = (ABS(i) % cfg.numbanners);
	    if (i != oldbanner)
		break;
	}
	oldbanner = i;

	ctdlfile(fn, cfg.helpdir, "%s.%d", "banner", i);
	if ((f = fopen(fn, "r")) == NULL)
	    return NO;
	(void) printhelpfile(f, NULL, NO);
	fclose(f);
	return YES;
}

void
menu(char *name)
{
	PATHBUF fn;
	FILE *f;
	
	helpline();
	ctdlfile(fn, cfg.helpdir, "%s.mnu", name);
	if ((f = fopen(fn, "r")) == NULL) {
		mprintf("%s not found; alert the Sysop!\r", fn);
		return;
	}
	(void) printhelpfile(f, NULL, NO);
	if (outFlag == OUTSKIP) {
		outFlag = OUTOK;
		doCR();
	}
	fclose(f);
	return;
}

int
help(char *name, int impervious)
{
	PATHBUF fn;
	FILE *f;
	
	if (!impervious)
		helpline();
	ctdlfile(fn, cfg.helpdir, "%s.hlp", name);
	if ((f = fopen(fn, "r")) == NULL) {
		mprintf("%s not found; alert the Sysop!\r", fn);
		return NO;
	}
	if (impervious)
		outFlag = IMPERVIOUS;
	(void) printhelpfile(f, NULL, NO);
	outFlag = OUTOK;
	fclose(f);
	return YES;
}

