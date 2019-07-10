/*
 * format.c -- Formatted output for Citadel
 *
 * 90Nov05 AA	Hacked a bit.
 * 89Mar31 orc	Written.
 */

#include <stdarg.h>
#include "ctdl.h"
#include "config.h"
#include "msg.h"
#include "log.h"
#include "citlib.h"
#include "citadel.h"

/*
 * printword()	prints out a whitespace-delimited word
 * mformat()	prints out a string
 * mprintf()	printf-via-mformat
 */

extern char	prevchar;		/* previous char output		*/

int		column = 1;		/* where mformat thinks we are	*/
char		_nl_[] = "\n\r\f";	/* soft nl, hard nl, formfeed	*/

/*
 * outspaces() - format out spacer characters.
 */
static char *
outspaces(register char *word)
{
    while (*word && *word <= ' ') {		/* display leading spaces */
	switch (*word++) {
	case '\f':			/* formfeed - nl + page eject */
	    oChar('^');
	    oChar('L');
	    if (outFlag == OUTPARAGRAPH)
		outFlag = OUTOK;
	    doNL('\f');
	    break;
	case '\r':			/* hard newline */
	    if (outFlag == OUTPARAGRAPH && prevchar == '\r')
		outFlag = OUTOK;
	    doCR();
	    break;
	case '\b':
	    if (column > 0) {
		oChar('\b');
		oChar(' ');
		oChar('\b');
		column--;
	    }
	    break;
	case ESC:			/* special case for ESCape */
	    if (cfg.filter[ESC]) {	/* on ESCape-enabled systems */
		oChar(prevchar=ESC);
		break;
	    }
	default:			/* _ANYTHING_ else becomes a space */
	    if (prevchar == '\n') {
		if (outFlag == OUTPARAGRAPH)
		    outFlag = OUTOK;
		doNL('\n');
		oChar(' ');		/* TODO:  column++; ???? */
	    }
	    else if (word[-1] != '\n' && ++column >= logBuf.lbwidth) {
		doNL('\n');		/* Too wide, so		*/
		while (*word == ' ')	/* eat leading spaces	*/
		    *word++;
	    }
	    else {
		oChar(' ');		/* TODO:  column++; ???? */
		prevchar = word[-1];	/* Record what the char really was */
	    }
	    break;
	}
    }
    return word;
}

/*
 * printword() - formats out one word (<spaces><word><spaces>) to whereever
 */
char *
printword(register char *word)
{
    register wordwidth;
    register char *p;

    /*
     * deal with leading whitespace
     */
    word = outspaces(word);
    /*
     * the word itself
     */
    for (wordwidth = 0, p = word; *p > ' '; ++p, ++wordwidth)
	;
    if (column + wordwidth >= logBuf.lbwidth)
	doNL('\n');
    while (*word > ' ') {
	if (++column >= logBuf.lbwidth)
	    doNL('\n');
	oChar(*word++);
    }
    /*
     * and trailing whitespace
     * (return the rest of the string, if any such thing exists)
     */
    return outspaces(word);
}

/*
 * mformat() - format-prints a string
 */
void
mformat(register char *string)
{
    while (*string && (outFlag == OUTOK || outFlag == OUTPARAGRAPH
					|| outFlag == IMPERVIOUS)) {
	string = printword(string);
	mAbort();
    }
}

/*
 * mprintf() - printf via mformat
 */
void
mprintf(char *format, ...)
{
    va_list arg;
    char string[MAXWORD];

    va_start(arg, format);
    vsprintf(string, format, arg);
    va_end(arg)
    mformat(string);
}
