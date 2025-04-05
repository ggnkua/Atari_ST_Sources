char *version = "v.1.1";

#define GLOBALS 1

#include <stdio.h>
#include <ctype.h>
#include "debug.h"
#include "defs.h"
#include "lookup.h"

#define brk brrk

/*
 * G L O B A L S
 *
 */
#ifndef vms
#define globaldef
#endif

	/* next available char; init = 0 */
globaldef int bp = -1;
	/* pushed-back characters */
globaldef char buf[BUFSIZE];
	/* stack of file descriptors */
globaldef FILE *infile[NFILES];
	/* current file is infile[level] */
globaldef int level;
	/* stack of output file descriptors */
globaldef FILE *outfile[NFILES];
	/* current output is outfile[olevel]; */
globaldef int olevel;
	/* current output file pointer */
globaldef FILE *poutput;
	/* number registers a..z */
globaldef int nr[26] = {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	/* system registers a..z */
globaldef int sr[26] = {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	/* last char position in outbuf; init = 0 */
globaldef int outp = 0;
	/* width of text currently in outbuf; init = 0 */
globaldef int outw = 0;
	/* number of words in outbuf; init = 0 */
globaldef int outwds = 0;
	/* lines to be filled collect here */
globaldef char outbuf[MAXOUT];
                       /* word in outbuf; init=0 */
	/* current output page number; init = 0 */
globaldef int curpag = 0;
	/* next output page number; init = 1 */
globaldef int newpag = 1;
	/* next line to be printed; init = 0 */
globaldef int lineno = 0;
	/* page length in lines; init = PAGELEN = 66 */
globaldef int plval = PAGELEN;
	/* page length save area */
globaldef int savpl = PAGELEN;
	/* margin before and including header */
globaldef int m1val = 3;
	/* margin after header */
globaldef int m2val = 2;
	/* margin after last text line */
globaldef int m3val = 2;
	/* bottom margin, including footer */
globaldef int m4val = 3;
	/* last live line on page, = plval-m3val-m4val */
globaldef int bottom = PAGELEN - 5;
	/* top of page title for even pages;init=NEWLINE */
globaldef char ehead[MAXLINE];
	/* top of page title for odd  pages;init=NEWLINE */
globaldef char ohead[MAXLINE];
	/* left,right margins for even header;init=inval,rmval */
globaldef int ehlim[2] = { 0, PAGEWIDTH };
	/* left,right margins for odd  header;init=inval,rmval */
globaldef int ohlim[2] = { 0, PAGEWIDTH };
	/* bot of page title for even pages;init=NEWLINE */
globaldef char efoot[MAXLINE];
	/* bot of page title for odd  pages;init=NEWLINE */
globaldef char ofoot[MAXLINE];
	/* left,right margins for even footer;init=inval,rmval */
globaldef int eflim[2] = { 0, PAGEWIDTH };
	/* left,right margins for odd  footer;init=inval,rmval */
globaldef int oflim[2] = { 0, PAGEWIDTH };
	/* flag for pausing between pages */
globaldef int stopx = 0;
	/* first page to begin printing with */
globaldef int frstpg = 0;
	/* last page to be printed */
globaldef int lastpg = HUGE;
	/* flag to indicate whether page should be printed */
globaldef int print = YES;
	/* number of blanks to offset page by; init = 0 */
globaldef int  offset = 0;
	/* verbose option; init = NO */
globaldef int verbose = NO;
	/* bolding option; init = YES; */
globaldef char bolding = YES;
	/* fill if YES; init = YES */
globaldef int fill = YES;
	/* current line spacing; init = 1 */
globaldef int lsval = 1;
	/* current indent; >= 0; init = 0 */
globaldef int inval = 0;
	/* current right margin; init = PAGEWIDTH = 60 */
globaldef int rmval = PAGEWIDTH;
	/* current temporary indent; init = 0 */
globaldef int tival = 0;
	/* number of lines to center; init = 0 */
globaldef int ceval = 0;
	/* flag for continuous center */
globaldef char CEon = FALSE;
	/* number of lines to underline; init = 0 */
globaldef int ulval = 0;
	/* flag for continuous underline */
globaldef char ULon = FALSE;
	/* number of lines to boldface; init = 0 */
globaldef int boval = 0;
	/* flag for continuous bolding */
globaldef char BDon = FALSE;
	/* justification types for heads and foots; */
	/* init = LEFT, CENTER, RIGHT */
globaldef int tjust[3] = { LEFT, CENTER, RIGHT };
	/* number of lines to blank suppress; init=0 */
globaldef int bsval = 0;
	/* right justify filled lines if YES; init=YES */
globaldef int rjust = YES;
	/* tab stops; init every 8 spaces */
globaldef int tabs[INSIZE];
	/* line control character; init = PERIOD */
globaldef char cchar = '.';
	/* universal escape - init = UNDERBAR */
globaldef char genesc = '_';
	/* character used to underline a BLANK; init = BLANK */
globaldef char ulblnk = ' ';
	/* scratch arrays for use by various routines */
globaldef char tbuf1[MAXLINE];
globaldef char tbuf2[MAXLINE];
globaldef char tbuf3[MAXLINE];
globaldef char ttl[MAXLINE];
	/* flag to process runoff symbols only */
globaldef char onlyrunoff = NO;
	/* Flag to turn paging off */
globaldef char paging = YES;
	/* page number in roman numerals. Init = NO */
globaldef char roman = NO;
	/* autopar flag. Init = NO */
globaldef char autopar = NO;
	/* temporary indent value for autopar */
globaldef int autoprv = 5;
	/* hash tables for macros and variables */
globaldef struct hashlist *macrotab[HASHMAX];
globaldef struct hashlist *gentab[HASHMAX];
	/* linked list entries for contents	*/
globaldef struct clist *chead = NULL;
globaldef struct clist *clast = NULL;
	/* keep track of what is done - VERBOSE */
globaldef int p_txtlines = 0;
globaldef int p_outlines = 0;
globaldef int p_outpages = 0;
globaldef int p_memoryus = 0;



/*
 * M A I N L I N E   OF   P R O F F
 *
 */

main(argc,argv)
int argc;
char *argv[];
{
        int i,j,val,type;
        char *p,c;
        FILE *fp, *fopen();

        for (i = 1; i < argc; i++) {
                p = argv[i];
                if (*p == '-') {
                        ++p;
                        if (isalpha(*p)) {
                                c = *p++;
                                switch(c) {

/* verbose stats */		case 'v':
				case 'V':
					verbose = TRUE;
					break;
/* runoff only   */		case 'r':
				case 'R':
					onlyrunoff = TRUE;
					break;
/* stop for page */             case 's':
                                case 'S':
                                        stopx = 1;
                                        break;
/* page offset   */             case 'p':
                                case 'P':
                                        if (*p == 'o' || *p == 'O') {
                                                p++;
                                                j = 0;
                                                val = getval(p, &j, &type);
                                                set(&offset, val, type, 0, 0,
                                                    rmval - 1);
                                        }
                                        else
                                                usage();
                                        break;
/* include file  */ 		case 'i':
				case 'I': /* simulate .so <filename> */
					pbstr("\n");
					pbstr(p);
					pbstr(".so ");
					break;

/* disable some  */		case 'd':
				case 'D':
					switch (*p) {

					case 'b':
					case 'B':
						bolding = NO;
						break;
					case 'p':
					case 'P':
						paging = NO;
						break;
					default:
						break;
					}
					break;

/* garbage       */             default:
                                        usage();
                                }
                        }
                        else
			         lastpg = atoi(p);
                }
                else if (*p == '+') {
                        p++;
                        if ((frstpg = atoi(p)) == 0)
                                usage();
                }
                else
                        break;
        }
        if (i == argc)
                usage();
        if ((fp = fopen(argv[i], "r")) == NULL) {
                fprintf(stderr, "%s: cannot open.\n",argv[i]);
                exit(1);
        }

#ifdef DEBUG
	fprintf(stderr,"OPened %s for Input Fp = %ld\n",argv[i],fp);
#endif
        if (p = argv[++i]) {
                if ((outfile[0] = fopen(p, "w")) == NULL) {
                        fprintf(stderr,"%s: cannot create.\n\n", p);
                        exit(1);
                }
#ifdef DEBUG
	fprintf(stderr,"OPened %s for Output\n",p);
#endif

	}
	else
	{
		outfile[0] = stdout;
#ifdef DEBUG
	fprintf(stderr,"USing stdout for output\n");
#endif
	}

			/* set output file level */
	olevel = 0;
	poutput = outfile[0];
	/*
	 * some minor initialisation
	 */

	for (i = 0; i < INSIZE; i++)
		if (i % 8 == 0)
			tabs[i] = YES;
		else
			tabs[i] = NO;

	ehead[0] = '\n';
	ehead[1] = EOS;
	ohead[0] = '\n';
	ohead[1] = EOS;
	efoot[0] = '\n';
	efoot[1] = EOS;
	ofoot[0] = '\n';
	ofoot[1] = EOS;

			/* initialise contents linked list */

	chead = (struct clist *) malloc(sizeof(struct clist));
	clast = chead;
	p_memoryus += sizeof(struct clist);

        doroff(fp);
        brk();
        if (plval <= 100 && (lineno > 0 | outp > 0))
                space(HUGE);
        putchar('\n');

	if(verbose) {
		fprintf(stderr,"proff read in %6d textlines to produce\n",
			p_txtlines);
		fprintf(stderr,"              %6d lines\n",
			p_outlines);
		fprintf(stderr,"              %6d pages of formatted text.\n",
			p_outpages);
		fprintf(stderr,"\n%d bytes of memory was required\n",
			p_memoryus);
		fprintf(stderr,"for internal tables and lists.\n");
	}
#ifdef vms
        exit(1);
#else
        exit(0);
#endif
}
