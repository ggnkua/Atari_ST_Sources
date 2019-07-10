#undef REGEXP

/*
 * editor.c -- the Fnordadel message entry and editing stuff
 *
 * 91Feb21 AA	Hack getText() and editText() to handle room descriptions too.
 * 90Nov09 AA	Split out from old roomb.c
 *	.
 *	.
 *	.
 * 87Oct28 orc	Disallow ESC entry in getText()
 * 87Oct24 orc	Scrap novice menu bar, put in a new one.
 * 87Aug02 orc	shuffle order of novice menu bar
 * 87Jul24 orc	do proper backspacing over X'ed input in getString
 * 87Apr21 orc	Shared room code beaten into submission.
 * 87Mar30 orc	anonoymous room support & new room editing,
 *		invitation-only room stuff lifted from C-86.
 * 87Jan19 orc	#ifdef out networking stuff...
 * 86Dec28 orc	68K ho!
 *	.
 *	.
 *	.
 * 81Dec12 CrT	Started.
 */

#include "ctdl.h"
#include "net.h"
#include "protocol.h"
#include "editor.h"
#include "msg.h"
#include "log.h"
#include "room.h"
#include "config.h"
#include "citlib.h"
#include "citadel.h"	/* Declarations specific to citadel.tos */

#ifdef REGEXP
#include <regexp.h>
#endif

/*
 * editText()		handles the end-of-message-entry menu
 * getText()		reads a message in from user
 * matchString()	search for given string
 * replaceString() 	string-substitute for message entry
 */

static int maxtext;	/* Max # chars enterable in a message */

#ifdef REGEXP

void regerror(char *c)
{
    printf("%s\n", c);
}

/* Definition	number	opnd?	meaning */
#define	OP(p)	(*(p))
#define	NEXT(p)	(((*((p)+1)&0377)<<8) + (*((p)+2)&0377))

#define	END	0		/* no	End of program. */
#define	BOL	1		/* no	Match "" at beginning of line. */
#define	EOL	2		/* no	Match "" at end of line. */
#define	ANY	3		/* no	Match any one character. */
#define	ANYOF	4		/* str	Match any character in this string. */
#define	ANYBUT	5		/* str	Match any character not in this
			 * string. */
#define	BRANCH	6		/* node	Match this alternative, or the
			 * next... */
#define	BACK	7		/* no	Match "", "next" ptr points backward. */
#define	EXACTLY	8		/* str	Match this string. */
#define	NOTHING	9		/* no	Match empty string. */
#define	STAR	10		/* node	Match this (simple) thing 0 or more
			 * times. */
#define	PLUS	11		/* node	Match this (simple) thing 1 or more
			 * times. */
#define	OPEN	20		/* no	Mark this point in input as start of
			 * #n. */
 /* OPEN+1 is number 1, etc. */
#define	CLOSE	30		/* no	Analogous to OPEN. */

static char regdummy;

/*
 - regnext - dig the "next" pointer out of a node
 */
static char *regnext(p)
register char *p;
{
  register int offset;

  if (p == &regdummy) return((char *)NULL);

  offset = NEXT(p);
  if (offset == 0) return((char *)NULL);

  if (OP(p) == BACK)
	return(p - offset);
  else
	return(p + offset);
}

/*
 - regprop - printable representation of opcode
 */
static char *regprop(op)
char *op;
{
  register char *p;
  static char buf[50];

  (void) strcpy(buf, ":");

  switch (OP(op)) {
      case BOL:	p = "BOL";	  	break;
      case EOL:	p = "EOL";	  	break;
      case ANY:	p = "ANY";	  	break;
      case ANYOF:	p = "ANYOF";	  	break;
      case ANYBUT:	p = "ANYBUT";	  	break;
      case BRANCH:	p = "BRANCH";	  	break;
      case EXACTLY:	p = "EXACTLY";	  	break;
      case NOTHING:	p = "NOTHING";	  	break;
      case BACK:	p = "BACK";	  	break;
      case END:	p = "END";	  	break;
      case OPEN + 1:
      case OPEN + 2:
      case OPEN + 3:
      case OPEN + 4:
      case OPEN + 5:
      case OPEN + 6:
      case OPEN + 7:
      case OPEN + 8:
      case OPEN + 9:
	sprintf(buf + strlen(buf), "OPEN%d", OP(op) - OPEN);
	p = (char *)NULL;
	break;
      case CLOSE + 1:
      case CLOSE + 2:
      case CLOSE + 3:
      case CLOSE + 4:
      case CLOSE + 5:
      case CLOSE + 6:
      case CLOSE + 7:
      case CLOSE + 8:
      case CLOSE + 9:
	sprintf(buf + strlen(buf), "CLOSE%d", OP(op) - CLOSE);
	p = (char *)NULL;
	break;
      case STAR:	p = "STAR";	  	break;
      case PLUS:	p = "PLUS";	  	break;
      default:	regerror("corrupted opcode"); p = (char *) NULL; break;
  }
  if (p != (char *)NULL) (void) strcat(buf, p);
  return(buf);
}

/*
 - regdump - dump a regexp onto stdout in vaguely comprehensible form
 */
void regdump(r)
regexp *r;
{
  register char *s;
  register char op = EXACTLY;	/* Arbitrary non-END op. */
  register char *next;

  s = r->program + 1;
  while (op != END) {		/* While that wasn't END last time... */
	op = OP(s);
	printf("%2d%s", (int) (s - r->program), regprop(s));	/* Where, what. */
	next = regnext(s);
	if (next == (char *)NULL)	/* Next ptr. */
		printf("(0)");
	else
		printf("(%d)", (int) (s - r->program) + (int) (next - s));
	s += 3;
	if (op == ANYOF || op == ANYBUT || op == EXACTLY) {
		/* Literal string, where present. */
		while (*s != '\0') {
			putchar(*s);
			s++;
		}
		s++;
	}
	putchar('\n');
  }

  /* Header fields of interest. */
  if (r->regstart != '\0') printf("start `%c' ", r->regstart);
  if (r->reganch) printf("anchored ");
  if (r->regmust != (char *)NULL) printf("must have \"%s\"", r->regmust);
  printf("\n");
}

#endif /* REGEXP */

/*
 * findString -- find a string (!)
 */
static char *
findString(char *buf, char *patt1, char *patt2, unsigned int *len)
{
    char *start, *end, *pc1, *pc2;
    char matched;

    for (start = ENDOFSTR(buf), matched = NO;  !matched && --start >= buf;) {
	for (pc1 = patt1, pc2 = start,	matched = YES;  *pc1 && matched;)
	    if (tolower(*pc1++) != tolower(*pc2++))
		matched = NO;
	if (matched && patt2[0]) {	/* searching for a block */
	    for (end = start + strlen(patt1), matched=NO;
		!matched && end++ < ENDOFSTR(buf); )
		for (pc1 = patt2, pc2 = end, matched = YES; *pc1 && matched; )
		    if (tolower(*pc1++) != tolower(*pc2++))
			matched = NO;
	}
    }
    if (matched) {
	if (patt2[0])
	   *len = (long)end + strlen(patt2) - (long)start; 
	else
	   *len = strlen(patt1);
    }
    return matched ? start : NULL;
}

/*
 * editChange() - perform deletes/replaces
 */
static void
editChange(char *loc, unsigned int len, char *new)
{
    char *pc;
    int size;

    /* delete old string: */
    for (pc=loc, size=len; *pc = *(pc+size); pc++)
	;
    
    /* make room for new string: */
    for (size=strlen(new); pc>=loc; pc--)
	*(pc+size) = *pc;

    /* insert new string: */
    for (pc=new; *pc; *loc++ = *pc++)
	;
}

/*
 * replaceString() in a message
 */

#define MAXRSIZE 256

static void
replaceString(char *buf, int size, int del, int block)
{
    char old1[MAXRSIZE];
    char old2[MAXRSIZE];
    char new[MAXRSIZE];
    char *loc, *last, temp, cmd;
    unsigned int len;
    int all, matched, done;

    old2[0] = 0;
    if (!block)
	getString("Search string", old1, MAXRSIZE, 0, YES);
    else {
	getString("Block start", old1, MAXRSIZE, 0, YES);
	if (!old1[0])
	    return;
	getString("Block end", old2, MAXRSIZE, 0, YES);
    }
    if (!old1[0])
	return;
    all = matched = done = 0;
    new[0] = 0;
    last = ENDOFSTR(buf);
    do {
	temp = *last;
	*last = 0;	/* End text at last location of search string */
	if (loc=findString(buf, old1, old2, &len)) {
	    *last = temp;
	    last = loc;
	    if (!del && !matched) {
		getString("Replacement", new, MAXRSIZE, 0, YES);
		if (strlen(buf)+strlen(new)-len >= size) {
		    mprintf("\007\rMessage overflow!\r");
		    break;
		}
	    }
	    ++matched;
	    temp = *loc;	/* Output some context & text to work on */
	    *loc = 0;
	    if ((loc - 10) <= buf)
		mformat(buf);
	    else {
		mformat("... ");
		mformat(loc - 10);
	    }
	    *loc = temp;
	    mformat(">>>");
	    temp = *(loc + len);
	    *(loc + len) = 0;
	    mformat(loc);
	    *(loc + len) = temp;
	    mformat("<<<");
	    if ((loc + len + 10) >= (buf + size))
		mformat(loc + len);
	    else {
		temp = *(loc + len + 10);
		*(loc + len + 10) = 0;
		mformat(loc + len);
		*(loc + len + 10) = temp;
		mformat(" ...");
	    }
	    if (!all) {
		do {
		    outFlag = IMPERVIOUS;
		    mprintf("\r%se this one? (Y/N/[A]ll/[Q]uit): ", del ?
			"Delet":"Replac");
		    cmd = toupper(getnoecho());
		    mprintf("%c\r", (cmd>=' ') ? cmd : '?');
		} while (onLine() && !(strchr("YNAQ",cmd)));
		outFlag = OUTOK;
		if (cmd == 'A')
		    all = 1;
	    }
	    else
		doCR();
	    if (all || cmd == 'Y') {
		editChange(loc, len, new);
		++done;
	    }
	}
	else {
	    *last = temp;
	    break;
	}
    } while (all || cmd != 'Q');
    mprintf("%d found / %d %sed\r", matched, done, 
	del ? "delet":"replac");
}

/*
 * insertParagraph() - inserts paragraph (CR/Space) into message
 */
static void
insertParagraph(char *buf, int size)
{
    char old[MAXRSIZE];
    char new[MAXRSIZE];
    char *loc;
    unsigned int len;

    if (strlen(buf)+2 >= size)
	mprintf("No room!\r");
    else {
	getString("At string", old, MAXRSIZE-2, 0, YES);
	if (old[0] == '\0')
	    return;
	if (loc=findString(buf, old, "", &len)) {
	    sprintf(new, "\n %s", old);
	    editChange(loc, len, new);
	}
    }
}

/*
 * editText() handles the end-of-message-entry menu.
 *
 * forwhich - as with getText().
 *
 * return YES to save message to disk,
 *	   NO to abort message, and
 *	ERROR if user decides to continue
 */
static int
editText(char *buf, int lim, int forwhich)
{
    while (onLine()) {
	outFlag = IMPERVIOUS;
	iprintf("\r(%s) entry cmd: ", roomBuf.rbname);
	switch (toupper(getnoecho())) {
	case 'A':
	    iprintf("abort- ");
	    if (getNo(confirm))
		return NO;
	    break;
	case 'C':
	    iprintf("continue\r");
	    return ERROR;
	case 'P':
	    iprintf("print formatted\r");
	    printdraft();
	    doCR();
	    break;
	case 'I':
	    iprintf("insert paragraph break\r");
	    insertParagraph(buf, lim);
	    break;
	case 'D':
	    iprintf("delete string\r");
	    replaceString(buf, lim, YES, NO);
	    break;
	case 'R':
	    iprintf("replace string\r");
	    replaceString(buf, lim, NO, NO);
	    break;
	case 'K':
	    iprintf("kill block\r");
	    replaceString(buf, lim, YES, YES);
	    break;
	case 'B':
	    iprintf("block replace\r");
	    replaceString(buf, lim, NO, YES);
	    break;
	case 'S':
	    iprintf("save %s\r", (forwhich == eINFO ? "room description" :
		"message"));
	    if (readbit(logBuf,uTWIT))
		return NO;
	    return YES;
/* 'O' command to toggle anonymous flag added by AA 89Sep11 */
	case 'O':
	    if (forwhich == eMESSAGE && readbit(roomBuf,ANON)) {
		flip(msgBuf,mANONMESSAGE);
		iprintf("message is%s anonymous.\r",
		    (readbit(msgBuf,mANONMESSAGE) ? "" : " not"));
#if 0
		if (!readbit(msgBuf,mANONMESSAGE))
		    strcpy(msgBuf.mbauth, logBuf.lbname);
		else
		    msgBuf.mbauth[0] = 0;
#endif
            }
	    else
		whazzit();
	    break;
        case 'H':
	    if (forwhich == eMESSAGE) {
		iprintf("hold message\r");
		if (heldMessage) {
		    if (!getNo("overwrite current held msg"))
			break;
		}
		if (heldMessage = loggedIn && puthold(logindex))
		    return NO;
	    }
	    else
		whazzit();
	    break;
	case 'L':
	    if (forwhich == eMESSAGE) {
		iprintf("local save\r");
		if (readbit(logBuf,uTWIT))
		    return NO;
		else {
		    NETADDR temp;

		    if (msgBuf.mbto[0])
			strcpy(temp, msgBuf.mbto);
		    else
			temp[0] = '\0';
		    Misvalid = NO;			/* do we need this? */
		    if (thisRoom == MAILROOM && !addressee(NO)) {
			if (temp[0])
			    strcpy(msgBuf.mbto, temp);
			break;
		    }
		    msgBuf.mbroute[0] = msgBuf.mboname[0] =
		    msgBuf.mborg[0] = msgBuf.mbdomain[0] = 0;
		    clear(msgBuf,mNETMESSAGE);
		    Mlocal = YES;
		    return YES;
		}
	    }
	    else
		whazzit();
	    break;
	case 'N':
	    if (forwhich == eMESSAGE) {
		iprintf("network save\r");
		if (readbit(logBuf,uTWIT))
		    return NO;
		if (permission(YES)) {
		    extern char Misvalid;

		    Misvalid = NO;		/* network promote-recalc address */
		    if (thisRoom != MAILROOM)
			promote();
		    else if (!addressee(YES))
			break;
		    return YES;
		}
	    }
	    else
		whazzit();
	    break;
#ifdef REGEXP
	case 'Z':
	    if (SomeSysop()) {
		char	foo[MAXRSIZE];
		regexp	*r;

		getString("Regexp", foo, MAXRSIZE, 0, YES);
		r = regcomp(foo);
		doCR();
		regdump(r);
		doCR();
		/* In following, NO means no use of ^, I think.  Dunno what */
		/* will happen if ^ is really used. */
		if (regexec(r, buf, NO))
		    mprintf("Matched.\r");
		else
		    mprintf("Didn't match.\r");
	    }
	    else
		whazzit();
	    break;
#endif
	case '?':
	    menu(forwhich == eMESSAGE ? "edit_msg" : "edit_inf");
	    break;
	default:
	    whazzit();
	}
    }
    return NO;
}

/*
 * stripnl() - removes all trailing new-lines from msgBuf.mbtext
 */
static int
stripnl(int idx)
{
    int i;

    i = idx;

    while ((i > 0) && (msgBuf.mbtext[i - 1] == '\n'))
	--i;		/* Throw away final \n's. */

    msgBuf.mbtext[i] = 0;		/* Terminate text. */
    return i;
}

/*
 * matchString() - search for match to given string.
 *
 * Runs backward through buffer so we get most recent error first.
 * Returns loc of match, else ERROR
 */
static char *
matchString(char *buf, char *pattern, char *bufEnd)
{
    char *loc, *pc1, *pc2;
    char matched;

    for (loc = bufEnd, matched = NO;  !matched && --loc >= buf;)
	for (pc1 = pattern, pc2 = loc,	matched = YES;  *pc1 && matched;)
	    if (tolower(*pc1++) != tolower(*pc2++))
		matched = NO;

    return matched ? loc : NULL;
}

/*
 * putBufChar() - write a character into msgBuf
 */
static int
putBufChar(int c)
{
    char result;

    if (masterCount > maxtext - 2)
	return 0;

    if (result = cfg.filter[c & 0x7f]) {
	msgBuf.mbtext[masterCount++] = result;
	msgBuf.mbtext[masterCount] = 0;	/* EOL just for luck	*/
    }
    return YES;
}

/*
 * getText() - reads a message from the user
 *
 * forwhich --> 0 == eMESSAGE == normal message
 *		1 == eINFO    == room Info entry
 */
int
getText(char WCmode, int forwhich)
{
    int  idx, rc, foo;
    char lc, c, prev, beeped = NO;
    char msg[80];
    int holdpos = loggedIn ? logindex : ERROR;

    if (thisRoom == MAILROOM && !loggedIn && cfg.anonmailmax)
	maxtext = cfg.anonmailmax;
    else if (forwhich == eINFO && !readbit(logBuf,uAIDE))
	maxtext = cfg.infomax;
    else
	maxtext = MAXTEXT;

    idx = strlen(msgBuf.mbtext);

/* Set up last char entered to control system behavior if CR hit right away. */
    if (!idx)		/* Brand new message.			*/
	lc = '\n';	/* Exit text entry after one CR hit.	*/
    else {		/* Continuing previous message.		*/
	lc = '.';	/* Exit text entry after two CRs hit.	*/
	idx = stripnl(idx);	/* Strip trailing \n's.		*/
    }

    if (!WCmode) {
	if (!readbit(logBuf,uEXPERT)) {
	    (void) blurb("entry", NO);
	    mprintf("Enter %s (end with empty line)\r",
		(forwhich == eINFO ? "room description" : "message"));
	}
	printdraft();
    }
    else {
	sprintf(msg, "Ready for %s transfer", protocol[WCmode]);
	if (!getYesNo(msg))
	    return NO;
	iprintf("Hit ^X once or twice to cancel...\n");
	masterCount = 0;
	if (!enterfile(putBufChar, WCmode))
	    return NO;
	idx = strlen(msgBuf.mbtext);	/* Get length of uploaded message. */
	idx = stripnl(idx);	/* Strip trailing \n's. */
	if (idx > 0)
	    lc = '.';		/* Exit editting after two CRs hit. */
    }

    while (onLine()) {
	outFlag = OUTOK;
	if (!WCmode) {
	    while (idx < maxtext - 1 && onLine()
				 && !((c=iChar()) == '\n' && lc == '\n')) {
		lc = c;
		if (c == BACKSPACE) {
		    if (idx > 0 && msgBuf.mbtext[idx-1] != '\n') {
			oChar(' ');
			oChar(BACKSPACE);
			idx--;
		    }
		    else
			oChar(BELL);
		}
		else if (c && c != ESC /* kill ANSI <- & ->*/ ) {
		    msgBuf.mbtext[idx++] = c;
		    if (idx > maxtext - 80 && !beeped) {
			oChar(BELL);
			beeped = YES;
		    }
		}
		else
		    oChar(BELL);
	    }
	    if (idx >= maxtext - 1)
		mprintf("\007\rMessage overflow!  Limit is %d characters.\r",
		    maxtext - 1);
	}

	if (idx > 0)
	    lc = '.';		/* next [C] to start after last	    */

	idx = stripnl(idx);		/* Throw away the final \n's. */

/* Eliminate all CRs that are not followed by whitespace - added AA 89Dec10 */
	for (prev = msgBuf.mbtext[0], foo = 1; foo < idx;
		prev = msgBuf.mbtext[foo], foo++)
	    if ((prev == '\n') && (msgBuf.mbtext[foo] > ' '))
		msgBuf.mbtext[foo-1] = ' '; 

	WCmode = ASCII;
	if ((rc = editText(msgBuf.mbtext, maxtext - 1, forwhich)) != ERROR)
	    break;
	else {		/* Output some context when [C]ontinue used */
	    idx = strlen(msgBuf.mbtext);
	    if (idx > 35) {
		mformat("... ");
		mformat(msgBuf.mbtext + idx - 35);
	    }
	    else
		mformat(msgBuf.mbtext);
	}
    }

    /*
     * rc was YES if we want to save the {message|description},
     * or NO if we want to abort it.
     */
    if (rc && onLine())	{		/* Filter null messages */
	while (idx>0)
	    if (isprint(msgBuf.mbtext[--idx]))
		return YES;
    }
    else if (forwhich == eMESSAGE && !onLine()
			&& (holdpos != ERROR && (cfg.flags.KEEPHOLD)))
	puthold(holdpos);
    return NO;
}
