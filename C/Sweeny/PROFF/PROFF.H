

#include "defs.h"
#include "lookup.h"

#ifndef GLOBALS
#ifdef vms
#define extern globalref
#endif
	/* next available char; init = 0 */
extern int bp;
	/* pushed-back characters */
extern char buf[BUFSIZE];
	/* stack of file descriptors */
extern FILE *infile[NFILES];
	/* current file is infile[level] */
extern int level;
	/* stack of output file descriptors */
extern FILE *outfile[NFILES];
	/* current output file is outfile[olevel] */
extern int olevel;
	/* current output file pointer */
extern FILE *poutput;
	/* system registers a..z */
extern int nr[26];
	/* last char position in outbuf; init = 0 */
extern int outp;
	/* width of text currently in outbuf; init = 0 */
extern int outw;
	/* number of words in outbuf; init = 0 */
extern int outwds;
	/* lines to be filled collect here */
extern char outbuf[MAXOUT];
                       /* word in outbuf; init=0 */
	/* current output page number; init = 0 */
extern int curpag;
	/* next output page number; init = 1 */
extern int newpag;
	/* next line to be printed; init = 0 */
extern int lineno;
	/* page length in lines; init = PAGELEN = 66 */
extern int plval;
	/* page length save area */
extern int savpl;
	/* margin before and including header */
extern int m1val;
	/* margin after header */
extern int m2val;
	/* margin after last text line */
extern int m3val;
	/* bottom margin, including footer */
extern int m4val;
	/* last live line on page, = plval-m3val-m4val */
extern int bottom;
	/* top of page title for even pages;init=NEWLINE */
extern char ehead[MAXLINE];
	/* top of page title for odd  pages;init=NEWLINE */
extern char ohead[MAXLINE];
	/* left,right margins for even header;init=inval,rmval */
extern int ehlim[2];
	/* left,right margins for odd  header;init=inval,rmval */
extern int ohlim[2];
	/* bot of page title for even pages;init=NEWLINE */
extern char efoot[MAXLINE];
	/* bot of page title for odd  pages;init=NEWLINE */
extern char ofoot[MAXLINE];
	/* left,right margins for even footer;init=inval,rmval */
extern int eflim[2];
	/* left,right margins for odd  footer;init=inval,rmval */
extern int oflim[2];
	/* flag for pausing between pages */
extern int stopx;
	/* first page to begin printing with */
extern int frstpg;
	/* last page to be printed */
extern int lastpg;
	/* flag to indicate whether page should be printed */
extern int print;
	/* number of blanks to offset page by; init = 0 */
extern int  offset;
	/* verbose option; init = FALSE */
extern int verbose;
	/* bolding option; init = YES; */
extern char bolding;
	/* fill if YES; init = YES */
extern int fill;
	/* current line spacing; init = 1 */
extern int lsval;
	/* current indent; >= 0; init = 0 */
extern int inval;
	/* current right margin; init = PAGEWIDTH = 60 */
extern int rmval;
	/* current temporary indent; init = 0 */
extern int tival;
	/* number of lines to center; init = 0 */
extern int ceval;
	/* flag for continuous center */
extern char CEon;
	/* number of lines to underline; init = 0 */
extern int ulval;
	/* flag for continuous underline */
extern char ULon;
	/* number of lines to boldface; init = 0 */
extern int boval;
	/* flag for continuous bolding */
extern char BDon;
	/* justification types for heads and foots; */
extern int tjust[3];          /* init = LEFT, CENTER, RIGHT */
	/* number of lines to blank suppress; init=0 */
extern int bsval;
	/* right justify filled lines if YES; init=YES */
extern int rjust;
	/* tab stops; init every 8 spaces */
extern int tabs[INSIZE];
	/* line control character; init = PERIOD */
extern char cchar;
	/* universal escape - init = UNDERBAR */
extern char genesc;
	/* character used to underline a BLANK; init = BLANK */
extern char ulblnk;
	/* scratch arrays for use by various routines */
extern char tbuf1[MAXLINE];
extern char tbuf2[MAXLINE];
extern char tbuf3[MAXLINE];
extern char ttl[MAXLINE];
	/* flag to process runoff symbols only */
extern char onlyrunoff;
	/* flag to turn paging off */
extern char paging;
	/* page number in roman numerals. Init = NO */
extern char roman;
	/* autopar flag. Init = NO */
extern char autopar;
	/* temporary indent value for autopar */
extern int autoprv;
	/* hash tables for macros and variables */
extern struct hashlist *macrotab[HASHMAX];
extern struct hashlist *gentab[HASHMAX];
	/* linked list entries for contents	*/
extern struct clist *chead;
extern struct clist *clast;
	/* keep track of the work - VERBOSE opt.*/

extern int p_txtlines;
extern int p_outlines;
extern int p_outpages;
extern int p_memoryus;

#ifdef vms
#undef extern
#endif

#endif

 	/* Why the hell can't people decare the routines they use */

#ifndef INLOOK
extern int hash();
extern struct hashlist *lookup();
extern struct hashlist *install();
extern char *strsave();
extern struct lexlist *lexinstal();
extern struct lexlist *lexlook();
extern struct lexlist *remove();
#endif

extern char *strcpy(), *strcat(), *malloc();
extern unsigned int strlen();
extern FILE *fopen(), *fclose();
