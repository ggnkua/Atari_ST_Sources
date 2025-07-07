/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
/* Routines for setting environment variables */
#include <osbind.h>
#include <basepage.h>
#include <string.h>
#include <stdlib.h>
#include <mintbind.h>
#include "xgem.h"
#include "toswin_w.h"
#include "twdefs.h"
#include "twproto.h"

/* which variables do we put in the environment */
int env_options = E_POSIX|E_TERMCAP|E_TERM|E_ARGV;

static char LINESprefix[] = "LINES=";
static char COLSprefix[] = "COLUMNS=";
static char TERMprefix[] = "TERM=";
static char TERMCAPprefix[] = "TERMCAP=";
static char ARGVprefix[] = "ARGV=";

/* templates for building a TERMCAP */
static char *TC1 = "TERMCAP=tw|tw52|toswin window mgr\
:al=\\EL:am:bl=^G:bs:cd=\\EJ:ce=\\EK:cl=\\EE:cm=\\EY%+ %+ :co#";

static char *TC2 =
    ":dc=\\Ea:dl=\\EM:do=\\EB:ei=\\Ei:eo:ho=\\EH:ic=:im=\\Eh:it#8:le=^H:li#";

static char *TC3 = ":md=\\EyA:me=\\Ez_:mh=\\EzB:mi:mr=\\Ep:ms:nd=\\EC\
:rc=\\Ek:rs=\\Ez_\\Eb@\\EcA:sc=\\Ej:se=\\Eq:sf=^J:sr=\\EI:so=\\Ep\
:ta=^I:ti=\\Eq\\Ev\\Ee:ue=\\EzH:us=\\EyH:up=\\EA:ve=\\Ee:vi=\\Ef:";

struct ereserved {
	char *prefix;
	int len;
	int bits;
} evar[] = {
	ARGVprefix, 6, E_ARGV,
	LINESprefix, 10, E_POSIX,
	COLSprefix, 12, E_POSIX,
	TERMprefix, 10, E_TERM,
	TERMCAPprefix, 512, E_TERMCAP,
	0L, 0, 0
};

/* returns 1 if "var" starts with the characters in "prefix", 0 otherwise */

static int
strprefix(var, prefix)
	char *var, *prefix;
{
	while (*var && *prefix) {
		if (*var++ != *prefix++) return 0;
	}
	if (*prefix) return 0;
	return 1;
}

/* copies "src" to "dest"; returns a pointer to the trailing 0 in dest
 * after the copy is finished
 */

static char *
copyprefix(dest, src)
	char *dest, *src;
{
	while (*src)
		*dest++ = *src++;
	*dest = 0;
	return dest;
}

/* copy an ASCII representation of the decimal number 'd' (0-999 inclusive)
 * into the string pointed to by 'to'; return a pointer to the new trailing
 * '\0'
 */

static char *
putdec(to, d)
	char *to;
	int d;
{
	char *val = valdec2(d);

	return copyprefix(to, val);
}

char *
envstr(progname, progargs, progdir, cols, rows)
	char *progname, *progargs, *progdir;
	int cols, rows;
{
	static char *oldenv = 0;
	char *from, *to;
	long nbytes;
	struct ereserved *ev;
	char *newenv;

	if (!oldenv)
		oldenv = _base->p_env;

	nbytes = 4;			/* for nulls and fluff */
	from = oldenv;
	while (from[0] || from[1]) {
		from++;
		nbytes++;
	}
	nbytes += 2*strlen(progargs) + strlen(progname);  /* ARGV=... */
	for (ev = evar; ev->prefix; ev++) {
		nbytes += ev->len;
	}
	newenv = malloc(nbytes);
	if (!newenv) return 0;

/* OK, now copy the environment over into "newenv" */
/* any environment variables that we're going to set, don't copy */

	from = oldenv;
	to = newenv;
	while (*from) {
		for (ev = evar; ev->prefix; ev++) {
			if ((env_options & ev->bits) && 
			    strprefix(from, ev->prefix)) {
				while(*from) from++;
				from++;
				goto endloop;
			}
		}
		while (*from)
			*to++ = *from++;
		*to++ = *from++;
	endloop: ;
	}

/* now we copy in our variables */
	if (env_options & E_POSIX) {
		to = copyprefix(to, LINESprefix);
		to = putdec(to, rows) + 1;
		to = copyprefix(to, COLSprefix);
		to = putdec(to, cols) + 1;
	}

	if (env_options & E_TERMCAP) {
		to = copyprefix(to, "TERM=tw52")+1;
		to = copyprefix(to, TC1);
		to = putdec(to, cols);
		to = copyprefix(to, TC2);
		to = putdec(to, rows);
		to = copyprefix(to, TC3)+1;
	}
	else if (env_options & E_TERM) {
		to = copyprefix(to, "TERM=st52")+1;
	}

	if (env_options & E_ARGV) {
		to = copyprefix(to, ARGVprefix) + 1;
		to = copyprefix(to, progname) + 1;
		if (*progargs) {
			while(*progargs) {
				from = nextword(&progargs);
				to = copyprefix(to, from) + 1;
			}
		}
	}

	*to++ = 0;	/* extra trailing 0 to close environment */
	return newenv;
}

void
setenvoptions()
{
	OBJECT *envdial;
	int x, y, w, h, ret;

	rsrc_gaddr(0, ENVDIAL, &envdial);
	form_center(envdial, &x, &y, &w, &h);

	envdial[POSIXBOX].ob_state = (env_options & E_POSIX) ?SELECTED : NORMAL;
	envdial[ARGVBOX].ob_state = (env_options & E_ARGV) ? SELECTED : NORMAL;
	envdial[TCAPBOX].ob_state = (env_options & E_TERMCAP) ? SELECTED : NORMAL;
	if ( (env_options & E_TERM) && !(env_options & E_TERMCAP) )
		envdial[TERMBOX].ob_state = SELECTED;
	else
		envdial[TERMBOX].ob_state = NORMAL;

	wind_update(1);
	form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
	if (win_flourishes)
		form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);

	objc_draw(envdial, 0, 2, x, y, w, h);

	ret = form_do(envdial, 0);
	if (win_flourishes)
		form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);

	form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
	objc_change(envdial, ret, 0, x, y, w, h, NORMAL, 0);
	wind_update(0);
	if (ret == ENVCAN) return;
	env_options = 0;
	if (envdial[TCAPBOX].ob_state == SELECTED)
		env_options |= E_TERMCAP|E_TERM;
	else if (envdial[TERMBOX].ob_state == SELECTED)
		env_options |= E_TERM;
	if (envdial[ARGVBOX].ob_state == SELECTED)
		env_options |= E_ARGV;
	if (envdial[POSIXBOX].ob_state == SELECTED)
		env_options |= E_POSIX;
}

/*
 * output a TERMCAP string to text window t, just as though
 * the user typed it
 */

static void
sendstr(t, s)
	TEXTWIN *t;
	char *s;
{
	long c;

	if (t->fd > 0) {
		while (*s) {
			c = *((unsigned char *)s);
			s++;
			(void)Fputchar(t->fd, c, 0);
		}
	}
}

void
output_termcap(t)
	TEXTWIN *t;
{
	sendstr(t, TC1);
	sendstr(t, valdec2(t->maxx));
	sendstr(t, TC2);
	sendstr(t, valdec2(NROWS(t)));
	sendstr(t, TC3);
	sendstr(t, "\r");
}
