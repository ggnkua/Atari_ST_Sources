/*	SC	A Spreadsheet Calculator
 *		Lexical analyser
 *
 *		original by James Gosling, September 1982
 *		modifications by Mark Weiser and Bruce Israel,
 *			University of Maryland
 *
 *              More mods Robert Bond, 12/86
 *		Major mods to run on VMS and AMIGA, 1/17/87
 *
 */



#include "sc.h"
#include <ctype.h>
#ifdef VMS
#include "y_tab.h"
#else
#ifdef TOS
#include "y_tab.h"
#else
#include "y.tab.h"
#endif
#endif

extern char *malloc();
char *strtof();

struct key {
    char *key;
    int val;
};

struct key experres[] = {
#include "experres.h"
    0, 0};

struct key statres[] = {
#include "statres.h"
    0, 0};

#define ctl(x) ('x'&037)

yylex () {
    register char *p = line+linelim;
    int ret = -1;
    while (isspace(*p)) p++;
    if (*p==0) ret = -1;
    else if (isalpha(*p)) {
	char *tokenst = p;
	register tokenl;
	register struct key *tbl;
	while (isalpha(*p)) p++;
	if (p-tokenst <= 2) { /* a COL is 1 or 2 char alpha */
	    register  col;
	    ret = COL;
	    col = ((tokenst[0] & 0137) - 'A');
	    if (p == tokenst+2)
		col = (col + 1)*26 + ((tokenst[1] & 0137) - 'A');
	    yylval.ival =  col;
	} else {
	    ret = WORD;
	    tokenl = p-tokenst;
	    for (tbl = linelim ? experres : statres; tbl->key; tbl++)
		    if (((tbl->key[0]^tokenst[0])&0137)==0
		     && tbl->key[tokenl]==0) {
			register i = 1;
			while (i<tokenl && ((tokenst[i]^tbl->key[i])&0137)==0)
			    i++;
			if (i>=tokenl) {
			    ret = tbl->val;
			    break;
			}
		    }
	    if (ret==WORD) { 
		linelim = p-line;
		yyerror ("Unintelligible word");
	    }
	}
    } else if ((*p == '.') || isdigit(*p)) {
	register long v = 0;
	char *nstart = p;
	if (*p != '.') {
	    do v = v*10 + (*p-'0');
	    while (isdigit(*++p));
	}
	if (*p=='.' || *p == 'e' || *p == 'E') {
	    ret = FNUMBER;
	    p = strtof(nstart, &yylval.fval);
	} else {
            if((int)v != v)
            {
                ret = FNUMBER;
                yylval.fval = v;
            }
            else
            {
 
                ret = NUMBER;
                yylval.ival = v;
            }
	}
    } else if (*p=='"') {
	/* This storage is never freed.  Oh well.  -MDW */
	char *ptr;
        ptr = p+1;
        while(*ptr && *ptr++ != '"');
        ptr = (char *)malloc((unsigned)(ptr-p));
	yylval.sval = ptr;
	p += 1;
	while (*p && *p!='"') *ptr++ = *p++;
	*ptr = 0;
	if (*p) p += 1;
	ret = STRING;
    } else if (*p=='[') {
	while (*p && *p!=']') p++;
	if (*p) p++;
	linelim = p-line;
	return yylex();
    } else ret = *p++;
    linelim = p-line;
    return ret;
}

#define N_KEY 26

struct key_map {
    char *k_str;
    char k_val;
    char k_index;
}; 

struct key_map km[N_KEY];

initkbd()
{
    int i;

    /* cursor set mode */
    km[0].k_str  = "\033OD"; km[0].k_val  = ctl(b);
    km[1].k_str  = "\033OC"; km[1].k_val  = ctl(f);
    km[2].k_str  = "\033OA"; km[2].k_val  = ctl(p);
    km[3].k_str  = "\033OB"; km[3].k_val  = ctl(n);
    /* cursor reset mode */
    km[4].k_str  = "\033[D"; km[4].k_val  = ctl(b);
    km[5].k_str  = "\033[C"; km[5].k_val  = ctl(f);
    km[6].k_str  = "\033[A"; km[6].k_val  = ctl(p);
    km[7].k_str  = "\033[B"; km[7].k_val  = ctl(n);
    /* CSI arrows */
    km[8].k_str  = "\233D";  km[8].k_val  = ctl(b);
    km[9].k_str  = "\233C";  km[9].k_val  = ctl(f);
    km[10].k_str = "\233A";  km[10].k_val = ctl(p);
    km[11].k_str = "\233B";  km[11].k_val = ctl(n);
    /* application keypad mode */
    km[12].k_str = "\033Op"; km[12].k_val = '0';
    km[13].k_str = "\033Oq"; km[13].k_val = '1';
    km[14].k_str = "\033Or"; km[14].k_val = '2';
    km[15].k_str = "\033Os"; km[15].k_val = '3';
    km[16].k_str = "\033Ot"; km[16].k_val = '4';
    km[17].k_str = "\033Ou"; km[17].k_val = '5';
    km[18].k_str = "\033Ov"; km[18].k_val = '6';
    km[19].k_str = "\033Ow"; km[19].k_val = '7';
    km[20].k_str = "\033Ox"; km[20].k_val = '8';
    km[21].k_str = "\033Oy"; km[21].k_val = '9';
    km[22].k_str = "\033Om"; km[22].k_val = '-';
    km[23].k_str = "\033Ol"; km[23].k_val = ',';
    km[24].k_str = "\033On"; km[24].k_val = '.';
    km[25].k_str = "\033OM"; km[25].k_val = ctl(m);
}

nmgetch() 
{
    register int c;
    register struct key_map *kp;
    register struct key_map *biggest;
    register int i;
    int almost;
    int maybe;

    static char dumpbuf[10];
    static char *dumpindex;

    void timeout();

    if (dumpindex && *dumpindex)
	    return (*dumpindex++);

    c = ttgetc();
    biggest = 0;
    almost = 0;

    for (kp = &km[0]; kp < &km[N_KEY]; kp++) {
	if (!kp->k_str)
	    continue;
	if (c == (kp->k_str[kp->k_index] & 0xFF)) {
	    almost = 1;
	    kp->k_index++;
	    if (kp->k_str[kp->k_index] == 0) {
		c = kp->k_val;
       	        for (kp = &km[0]; kp < &km[N_KEY]; kp++)
	            kp->k_index = 0;
	        return(c);
	    }
	}
	if (!biggest && kp->k_index)
	    biggest = kp;
        else if (kp->k_index && biggest->k_index < kp->k_index)
	    biggest = kp;
    }

    if (almost) return(nmgetch());

    if (biggest) {
	for (i = 0; i<biggest->k_index; i++) 
	    dumpbuf[i] = biggest->k_str[i];
	dumpbuf[i++] = c;
	dumpbuf[i] = 0;
	dumpindex = &dumpbuf[1];
       	for (kp = &km[0]; kp < &km[N_KEY]; kp++)
	    kp->k_index = 0;
	return (dumpbuf[0]);
    }

    return(c);
}


int dbline;

debug (fmt, a, b, c) {
	move(2+(dbline++%22),80-60);
	printw(fmt,a,b,c);
	clrtoeol();
}

/*
 * This converts a floating point number of the form
 * [s]ddd[.d*][esd*]  where s can be a + or - and e is E or e.
 * to floating point. 
 * p is advanced.
 */

char *
strtof(p, res)
register char *p;
double *res;
{
    double acc;
    int sign;
    double fpos;
    int exp;
    int exps;

    acc = 0.0;
    sign = 1;
    exp = 0;
    exps = 1;
    if (*p == '+')
        p++;
    else if (*p == '-') {
        p++;
        sign = -1;
    }
    while (isdigit(*p)) {
        acc = acc * 10.0 + (double)(*p - '0');
        p++;
    }
    if (*p == 'e' || *p == 'E') {
	    p++;
        if (*p == '+')
	    p++;
        else if (*p == '-') {
	    p++;
	    exps = -1;
        }
        while(isdigit(*p)) {
	    exp = exp * 10 + (*p - '0');
	    p++;
        }
    }
    if (*p == '.') {
	fpos = 1.0/10.0;
	p++;
	while(isdigit(*p)) {
	    acc += (*p - '0') * fpos;
	    fpos *= 1.0/10.0;
	    p++;
	}
    }
    if (*p == 'e' || *p == 'E') {
	exp = 0;
	exps = 1;
        p++;
	if (*p == '+')
	    p++;
	else if (*p == '-') {
	    p++;
	    exps = -1;
	}
	while(isdigit(*p)) {
	    exp = exp * 10 + (*p - '0');
	    p++;
	}
    }
    if (exp) {
	if (exps > 0)
	    while (exp--)
		acc *= 10.0;
	else
	    while (exp--)
		acc *= 1.0/10.0;
    }
    if (sign > 0)
        *res = acc;
    else
	*res = -acc;

    return(p);
}

help () {
    move(2,0);
    clrtobot();
    dbline = 0;
    debug ("                 Cursor cmds:");
    debug ("  ^n j next row       ^p k prev. row      ^g erase cmd");
    debug ("  ^f l fwd col        ^b h back col       ^r redraw screen");
    debug ("   0 $ first, end col");
    debug ("                 Cell cmds:");
    debug (" \" < > enter label       = enter value     x clear cell");
    debug ("     c copy cell         m mark cell      ^t line 1 on/off");  
    debug ("    ^a type value       ^e type expr.     ^v type vbl name");
    debug ("                 Row, Column cmds:");
    debug (" ar ac dup           ir ic insert      sr sc show");
    debug (" dr dc delete        zr zc hide        pr pc pull");
    debug (" vr vc value only        f format");
    debug ("                 File cmds:");
    debug ("     G get database      M merge database  T write tbl fmt");
    debug ("     P put database      W write listing");
    debug ("                 Misc. cmds:");
    debug (" ^c, q quit              / copy region    pm pull (merge)");
    debug ("                 Expression Operators");
    debug ("  +-*/ arithmetic     ?e:e conditional   & | booleans");
    debug (" < = > relations     <= >= relations      != relations");
    debug ("       @sum(v1:v2)         @avg(v1:v2)       @prod(v1:v2)");
}
