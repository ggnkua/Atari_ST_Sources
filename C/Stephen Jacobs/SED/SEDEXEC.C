#if 0					/* SAJ */
#include "compiler.h"
#ifdef LATTICE
#define void int
#endif

#endif					/* SAJ */
#include "debug.h"
/*
sedexec.c -- execute compiled form of stream editor commands

   The single entry point of this module is the function execute(). It
may take a string argument (the name of a file to be used as text)  or
the argument NULL which tells it to filter standard input. It executes
the compiled commands in cmds[] on each line in turn.
   The function command() does most of the work. Match() and advance()
are used for matching text against precompiled regular expressions and
dosub() does right-hand-side substitution.  Getline() does text input;
readout() and memcmp() are output and string-comparison utilities.  

==== Written for the GNU operating system by Eric S. Raymond ==== 
*/

#include <stdio.h>      /* {f}puts, {f}printf, getc/putc, f{re}open, fclose */
#include <ctype.h>      /* for isprint(), isdigit(), toascii() macros */
#include "sed.h"        /* command type structures & miscellaneous constants */

extern char     *strcpy();      /* used in dosub */

/***** shared variables imported from the main ******/

/* main data areas */
extern char     linebuf[];      /* current-line buffer */
extern sedcmd   cmds[];         /* hold compiled commands */
extern long     linenum[];      /* numeric-addresses table */

/* miscellaneous shared variables */
extern int      nflag;          /* -n option flag */
extern int      eargc;          /* scratch copy of argument count */
extern sedcmd   *pending;       /* ptr to command waiting to be executed */
extern char     bits[];         /* the bits table */

/***** end of imported stuff *****/

#define MAXHOLD         MAXBUF  /* size of the hold space */
#if 0		/* I had to leave this in.  Is it a joke, or what? 
		 *3 Hours single stepping a broken program isn't funny  SAJ */
#define GENSIZ          71      /* maximum genbuf size */
#endif
#define GENSIZ          500      /* maximum genbuf size */
#define TRUE            1
#define FALSE           0

static char LTLMSG[]    = "sed: line too long\n";

static char     *spend;         /* current end-of-line-buffer pointer */
static long     lnum = 0L;      /* current source line number */

/* append buffer maintenance */
static sedcmd   *appends[MAXAPPENDS];   /* array of ptrs to a,i,c commands */
static sedcmd   **aptr = appends;       /* ptr to current append */

/* genbuf and its pointers */
static char     genbuf[GENSIZ];
static char     *lcomend = genbuf + GENSIZ;
static char     *loc1;
static char     *loc2;
static char     *locs;

/* command-logic flags */
static int      lastline;               /* do-line flag */
static int      jump;                   /* jump to cmd's link address if set */
static int      delete;                 /* delete command flag */

/* tagged-pattern tracking */
static char     *bracend[MAXTAGS];      /* tagged pattern start pointers */
static char     *brastart[MAXTAGS];     /* tagged pattern end pointers */


void execute(file)
/* execute the compiled commands in cmds[] on a file */
char *file;             /* name of text source file to be filtered */
{
        register char           *p1, *p2;       /* dummy copy ptrs */
        register sedcmd         *ipc;           /* ptr to current command */
        char                    *execp;         /* ptr to source */
        char                    *getline();     /* input-getting functions */
        void                    command(), readout();

PASS("execute(): entry");

        if (file != NULL)       /* filter text from a named file */ 
                if (freopen(file, "r", stdin) == NULL)
                        fprintf(stderr, "sed: can't open %s\n", file);
PASS("execute(): reopen");

        if (pending)            /* there's a command waiting */
        {
                ipc = pending;          /* it will be first executed */
                pending = FALSE;        /*   turn off the waiting flag */
                goto doit;              /*   go to execute it immediately */
        }

        /* here's the main command-execution loop */
        for(;;)
        {
PASS("execute(): main loop entry");

                /* get next line to filter */
                if ((execp = getline(linebuf)) == BAD)
                        return;
PASS("execute(): getline");
                spend = execp;

                /* loop through compiled commands, executing them */
                for(ipc = cmds; ipc->command; )
                {
PASS("execute(): command loop entry");
                        /* all no-address commands are selected */
                        if (ipc->addr1 && !selected(ipc))
                        {
                                ipc++;
                                continue;
                        }
        doit:
PASS("execute(): doit");
                        command(ipc);   /* execute the command pointed at */
PASS("execute(): command");

                        if (delete)     /* if delete flag is set */
                                break;  /* don't exec rest of compiled cmds */

                        if (jump)       /* if jump set, follow cmd's link */
                        {
                                jump = FALSE;
                                if ((ipc = ipc->u.link) == 0)
                                {
                                        ipc = cmds;
                                        break;
                                }
                        }
                        else            /* normal goto next command */
                                ipc++;
PASS("execute(): end command loop");
                }
                /* we've now done all modification commands on the line */

                /* here's where the transformed line is output */
PASS("execute(): output");
                if (!nflag && !delete)
                {
                        for(p1 = linebuf; p1 < spend; p1++)
                                putc(*p1, stdout);
                        putc('\n', stdout);
                }

                /* if we've been set up for append, emit the text from it */
                if (aptr > appends)
                        readout();

                delete = FALSE; /* clear delete flag; about to get next cmd */
PASS("execute(): end main loop");
        }
PASS("execute(): end execute");
}

static int selected(ipc)
/* is current command selected */
sedcmd  *ipc;
{
        register char   *p1 = ipc->addr1;       /* point p1 at first address */
        register char   *p2 = ipc->addr2;       /*   and p2 at second */
        char            c;

        if (ipc->flags.inrange)
        {
                if (*p2 == CEND)
                        p1 = NULL;
                else if (*p2 == CLNUM)
                {
                        c = p2[1];
                        if (lnum > linenum[c])
                        {
                                ipc->flags.inrange = FALSE;
                                if (ipc->flags.allbut)
                                        return(TRUE);
                                ipc++;
                                return(FALSE);
                        }
                        if (lnum == linenum[c])
                                ipc->flags.inrange = FALSE;
                }
                else if (match(p2, 0))
                        ipc->flags.inrange = FALSE;
        }
        else if (*p1 == CEND)
        {
                if (!lastline)
                {
                        if (ipc->flags.allbut)
                                return(TRUE);
                        ipc++;
                        return(FALSE);
                }
        }
        else if (*p1 == CLNUM)
        {
                c = p1[1];
                if (lnum != linenum[c])
                {
                        if (ipc->flags.allbut)
                                return(TRUE);
                        ipc++;
                        return(FALSE);
                }
                if (p2)
                        ipc->flags.inrange = TRUE;
        }
        else if (match(p1, 0))
        {
                if (p2)
                        ipc->flags.inrange = TRUE;
        }
        else
        {
                if (ipc->flags.allbut)
                        return(TRUE);
                ipc++;
                return(FALSE);
        }
        return(TRUE);		/* SAJ for Atari ST, Mark Williams C */
}

static int match(expbuf, gf)    /* uses genbuf */
/* match RE at expbuf against linebuf; if gf set, copy linebuf from genbuf */
char    *expbuf;
{
        register char   *p1, *p2, c;

        if (gf)
        {
                if (*expbuf)
                        return(FALSE);
                p1 = linebuf; p2 = genbuf;
                while (*p1++ = *p2++);
                locs = p1 = loc2;
        }
        else
        {
                p1 = linebuf;
                locs = FALSE;
        }

        p2 = expbuf;
        if (*p2++)
        {
                loc1 = p1;
                if(*p2 == CCHR && p2[1] != *p1) /* 1st char is wrong */
                        return(FALSE);          /*   so fail */
                return(advance(p1, p2));        /* else try to match rest */
        }

        /* quick check for 1st character if it's literal */
        if (*p2 == CCHR)
        {
                c = p2[1];              /* pull out character to search for */
                do {
                        if (*p1 != c)
                                continue;       /* scan the source string */
                        if (advance(p1, p2))    /* found it, match the rest */
                                return(loc1 = p1, 1);
                } while
                        (*p1++);
                return(FALSE);          /* didn't find that first char */
        }

        /* else try for unanchored match of the pattern */
        do {
                if (advance(p1, p2))
                        return(loc1 = p1, 1);
        } while
                (*p1++);

        /* if got here, didn't match either way */
        return(FALSE);
}

static int advance(lp, ep)
/* attempt to advance match pointer by one pattern element */
register char   *lp;            /* source (linebuf) ptr */
register char   *ep;            /* regular expression element ptr */
{
        register char   *curlp;         /* save ptr for closures */ 
        char            c;              /* scratch character holder */
        char            *bbeg;
        int             ct;

        for (;;)
                switch (*ep++)
                {
                case CCHR:              /* literal character */
                        if (*ep++ == *lp++)     /* if chars are equal */
                                continue;       /* matched */
                        return(FALSE);          /* else return false */

                case CDOT:              /* anything but newline */
                        if (*lp++)              /* first NUL is at EOL */
                                continue;       /* keep going if didn't find */
                        return(FALSE);          /* else return false */

                case CNL:               /* start-of-line */
                case CDOL:              /* end-of-line */
                        if (*lp == 0)           /* found that first NUL? */
                                continue;       /* yes, keep going */
                        return(FALSE);          /* else return false */

                case CEOF:              /* end-of-address mark */
                        loc2 = lp;              /* set second loc */
                        return(TRUE);           /* return true */

                case CCL:               /* a closure */
                        c = *lp++ & 0177;
                        if (ep[c>>3] & bits[c & 07])    /* is char in set? */
                        {
                                ep += 16;       /* then skip rest of bitmask */
                                continue;       /*   and keep going */
                        }
                        return(FALSE);          /* else return false */

                case CBRA:              /* start of tagged pattern */
                        brastart[*ep++] = lp;   /* mark it */
                        continue;               /* and go */

                case CKET:              /* end of tagged pattern */
                        bracend[*ep++] = lp;    /* mark it */
                        continue;               /* and go */

                case CBACK: 
                        bbeg = brastart[*ep];
                        ct = bracend[*ep++] - bbeg;

                        if (memcmp(bbeg, lp, ct))
                        {
                                lp += ct;
                                continue;
                        }
                        return(FALSE);

                case CBACK|STAR:
                        bbeg = brastart[*ep];
                        ct = bracend[*ep++] - bbeg;
                        curlp = lp;
                        while(memcmp(bbeg, lp, ct))
                                lp += ct;

                        while(lp >= curlp)
                        {
                                if (advance(lp, ep))
                                        return(TRUE);
                                lp -= ct;
                        }
                        return(FALSE);


                case CDOT|STAR:         /* match .* */
                        curlp = lp;             /* save closure start loc */
                        while (*lp++);          /* match anything */ 
                        goto star;              /* now look for followers */

                case CCHR|STAR:         /* match <literal char>* */
                        curlp = lp;             /* save closure start loc */
                        while (*lp++ == *ep);   /* match many of that char */
                        ep++;                   /* to start of next element */
                        goto star;              /* match it and followers */

                case CCL|STAR:          /* match [...]* */
                        curlp = lp;             /* save closure start loc */
                        do {
                                c = *lp++ & 0x7F;       /* match any in set */
                        } while
                                (ep[c>>3] & bits[c & 07]);
                        ep += 16;               /* skip past the set */
                        goto star;              /* match followers */

                star:           /* the recursion part of a * or + match */
                        if (--lp == curlp)      /* 0 matches */
                                continue;

                        if (*ep == CCHR)
                        {
                                c = ep[1];
                                do {
                                        if (*lp != c)
                                                continue;
                                        if (advance(lp, ep))
                                                return(TRUE);
                                } while
                                        (lp-- > curlp);
                                return(FALSE);
                        }

                        if (*ep == CBACK)
                        {
                                c = *(brastart[ep[1]]);
                                do {
                                        if (*lp != c)
                                                continue;
                                        if (advance(lp, ep))
                                                return(TRUE);
                                } while
                                        (lp-- > curlp);
                                return(FALSE);
                        }
        
                        do {
                                if (lp == locs)
                                        break;
                                if (advance(lp, ep))
                                        return(TRUE);
                        } while
                                (lp-- > curlp);
                        return(FALSE);

                default:
                        fprintf(stderr, "sed: RE error, %o\n", *--ep);
                }
}

static int substitute(ipc)
/* perform s command */
sedcmd  *ipc;                           /* ptr to s command struct */
{
        void dosub();                   /* for if we find a match */

        if (match(ipc->u.lhs, 0))               /* if no match */
                dosub(ipc->rhs);                /* perform it once */
        else
                return(FALSE);                  /* command fails */

        if (ipc->flags.global)                  /* if global flag enabled */
                while(*loc2)                    /* cycle through possibles */
                        if (match(ipc->u.lhs, 1))       /* found another */
                                dosub(ipc->rhs);        /* so substitute */
                        else                            /* otherwise, */
                                break;                  /* we're done */
        return(TRUE);                           /* we succeeded */
}

static void dosub(rhsbuf)               /* uses linebuf, genbuf, spend */
/* generate substituted right-hand side (of s command) */
char    *rhsbuf;        /* where to put the result */
{
        register char   *lp, *sp, *rp;
        int             c;
        char            *place();

        /* copy linebuf to genbuf up to location  1 */
        lp = linebuf; sp = genbuf;
        while (lp < loc1) *sp++ = *lp++;

        for (rp = rhsbuf; c = *rp++; )
        {
                if (c == '&')
                {
                        sp = place(sp, loc1, loc2);
                        continue;
                }
                else if (c & 0200 && (c &= 0177) >= '1' && c < MAXTAGS+'1')
                {
                        sp = place(sp, brastart[c-'1'], bracend[c-'1']);
                        continue;
                }
                *sp++ = c & 0177;
                if (sp >= genbuf + MAXBUF)
                        fprintf(stderr, LTLMSG);
        }
        lp = loc2;
/* MRY  loc2 = sp - genbuf + linebuf; */
        loc2 = sp - (genbuf - linebuf);
        while (*sp++ = *lp++)
                if (sp >= genbuf + MAXBUF)
                        fprintf(stderr, LTLMSG);
        lp = linebuf; sp = genbuf;
        while (*lp++ = *sp++);
        spend = lp-1;
}

static char *place(asp, al1, al2)               /* uses genbuf */
/* place chars at *al1...*(al1 - 1) at asp... in genbuf[] */
register char   *asp, *al1, *al2;
{
        while (al1 < al2)
        {
                *asp++ = *al1++;
                if (asp >= genbuf + MAXBUF)
                        fprintf(stderr, LTLMSG);
        }
        return(asp);
}

static void listto(p1, fp)
/* write a hex dump expansion of *p1... to fp */
register char   *p1;            /* the source */
FILE            *fp;            /* output stream to write to */
{
        p1--;
        while(*p1++)
                if (isprint(*p1))
                        putc(*p1, fp);          /* pass it through */
                else
                {
                        putc('\134', fp);               /* emit a backslash */
                        switch(*p1)
                        {
                        case '\10':     putc('b', fp); break;   /* BS */
                        case '\11':     putc('t', fp); break;   /* TAB */
/* \11 was \9 --MRY */
                        case '\12':     putc('n', fp); break;   /* NL */
                        case '\15':     putc('r', fp); break;   /* CR */
                        case '\33':     putc('e', fp); break;   /* ESC */
                        default:        fprintf(fp, "%02x", *p1 & 0xFF);
                        }
                }
        putc('\n', fp);
}

static void command(ipc)
/* execute compiled command pointed at by ipc */
sedcmd  *ipc;
{
        static int      didsub;                 /* true if last s succeeded */
        static char     holdsp[MAXHOLD];        /* the hold space */
        static char     *hspend = holdsp;       /* hold space end pointer */
        register char   *p1, *p2, *p3;
        register int    i;
        char            *execp;

        switch(ipc->command)
        {
        case ACMD:              /* append */
                *aptr++ = ipc;
                if (aptr >= appends + MAXAPPENDS)
                        fprintf(stderr,
                                "sed: too many appends after line %ld\n",
                                lnum);
                *aptr = 0;
                break;

        case CCMD:              /* change pattern space */
                delete = TRUE;
                if (!ipc->flags.inrange || lastline)
                        printf("%s\n", ipc->u.lhs);             
                break;

        case DCMD:              /* delete pattern space */
                delete++;
                break;

        case CDCMD:             /* delete a line in hold space */
                p1 = p2 = linebuf;
                while(*p1 != '\n')
                        if (delete = (*p1++ == 0))
                                return;
                p1++;
                while(*p2++ = *p1++) continue;
                spend = p2-1;
                jump++;
                break;

        case EQCMD:             /* show current line number */
                fprintf(stdout, "%ld\n", lnum);
                break;

        case GCMD:              /* copy hold space to pattern space */
                p1 = linebuf;   p2 = holdsp;    while(*p1++ = *p2++);
                spend = p1-1;
                break;

        case CGCMD:             /* append hold space to pattern space */
                *spend++ = '\n';
                p1 = spend;     p2 = holdsp;
                while(*p1++ = *p2++)
                        if (p1 >= linebuf + MAXBUF)
                                break;
                spend = p1-1;
                break;

        case HCMD:              /* copy pattern space to hold space */
                p1 = holdsp;    p2 = linebuf;   while(*p1++ = *p2++);
                hspend = p1-1;
                break;

        case CHCMD:             /* append pattern space to hold space */
                *hspend++ = '\n';
                p1 = hspend;    p2 = linebuf;
                while(*p1++ = *p2++)
                        if (p1 >= holdsp + MAXBUF)
                                break;
                hspend = p1-1;
                break;

        case ICMD:              /* insert text */
                printf("%s\n", ipc->u.lhs);
                break;

        case BCMD:              /* branch to label */
                jump = TRUE;
                break;

        case LCMD:              /* list text */
                listto(linebuf, (ipc->fout != NULL)?ipc->fout:stdout); break;

        case NCMD:      /* read next line into pattern space */
                if (!nflag)
                        puts(linebuf);  /* flush out the current line */
                if (aptr > appends)
                        readout();      /* do pending a, r commands */
                if ((execp = getline(linebuf)) == BAD)
                {
                        pending = ipc;
                        delete = TRUE;
                        break;
                }
                spend = execp;
                break;

        case CNCMD:     /* append next line to pattern space */
                if (aptr > appends)
                        readout();
                *spend++ = '\n';
                if ((execp = getline(spend)) == BAD)
                {
                        pending = ipc;
                        delete = TRUE;
                        break;
                }
                spend = execp;
                break;

        case PCMD:              /* print pattern space */
                puts(linebuf);
                break;

        case CPCMD:             /* print one line from pattern space */
                cpcom:          /* so s command can jump here */
                for(p1 = linebuf; *p1 != '\n' && *p1 != '\0'; )
                        putc(*p1++, stdout);
                putc('\n', stdout);
                break;

        case QCMD:              /* quit the stream editor */
                if (!nflag)
                        puts(linebuf);  /* flush out the current line */
                if (aptr > appends)
                        readout();      /* do any pending a and r commands */
                exit(0);

        case RCMD:              /* read a file into the stream */
                *aptr++ = ipc;
                if (aptr >= appends + MAXAPPENDS)
                        fprintf(stderr,
                                "sed: too many reads after line %ld\n",
                                lnum);
                *aptr = 0;
                break;

        case SCMD:              /* substitute RE */
                didsub = substitute(ipc);
                if (ipc->flags.print && didsub)
                        if (ipc->flags.print == TRUE)
                                puts(linebuf);
                        else
                                goto cpcom;
                if (didsub && ipc->fout)
                        fprintf(ipc->fout, "%s\n", linebuf);
                break;

        case TCMD:              /* branch on last s successful */
        case CTCMD:             /* branch on last s failed */
                if (didsub == (ipc->command == CTCMD))
                        break;          /* no branch if last s failed, else */
                didsub = FALSE;
                jump = TRUE;            /*  set up to jump to assoc'd label */
                break;

        case CWCMD:             /* write one line from pattern space */
                for(p1 = linebuf; *p1 != '\n' && *p1 != '\0'; )
                        putc(*p1++, ipc->fout);
                putc('\n', ipc->fout);
                break;

        case WCMD:              /* write pattern space to file */
                fprintf(ipc->fout, "%s\n", linebuf);
                break;

        case XCMD:              /* exchange pattern and hold spaces */
                p1 = linebuf;   p2 = genbuf;    while(*p2++ = *p1++) continue;
                p1 = holdsp;    p2 = linebuf;   while(*p2++ = *p1++) continue;
                spend = p2 - 1;
                p1 = genbuf;    p2 = holdsp;    while(*p2++ = *p1++) continue;
                hspend = p2 - 1;
                break;

        case YCMD:
                p1 = linebuf;   p2 = ipc->u.lhs;
                while(*p1 = p2[*p1])
                        p1++;
                break;
        }
}

static char *getline(buf)
/* get next line of text to be filtered */
register char   *buf;           /* where to send the input */
{
        if (gets(buf) != NULL)
        {
                lnum++;                 /* note that we got another line */
                while(*buf++);          /* find the end of the input */
                return(--buf);          /* return ptr to terminating null */ 
        }
        else
        {
                if (eargc == 0)                 /* if no more args */
                        lastline = TRUE;        /*    set a flag */
                return(BAD);
        }
}

static int memcmp(a, b, count)
/* return TRUE if *a... == *b... for count chars, FALSE otherwise */
register char   *a, *b;
{
        while(count--)                  /* look at count characters */
                if (*a++ != *b++)       /* if any are nonequal   */
                        return(FALSE);  /*    return FALSE for false */
        return(TRUE);                   /* compare succeeded */
}

static void readout()
/* write file indicated by r command to output */
{
        register char   *p1;    /* character-fetching dummy */
        register int    t;      /* hold input char or EOF */
        FILE            *fi;    /* ptr to file to be read */

        aptr = appends - 1;     /* arrange for pre-increment to work right */
        while(*++aptr)
                if ((*aptr)->command == ACMD)           /* process "a" cmd */
                        printf("%s\n", (*aptr)->u.lhs);
                else                                    /* process "r" cmd */
                {
                        if ((fi = fopen((*aptr)->u.lhs, "r")) == NULL)
                                continue;
                        while((t = getc(fi)) != EOF)
                                putc((char) t, stdout);
                        fclose(fi);
                }
        aptr = appends;         /* reset the append ptr */
        *aptr = 0;
}

/* sedexec.c ends here */
