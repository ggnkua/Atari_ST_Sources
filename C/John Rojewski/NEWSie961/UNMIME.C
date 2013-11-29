/* unmime.c  1995 jun 12  [gh]
+-----------------------------------------------------------------------------
| Abstract:
|    Sample application.
|
| History:
|    2.1 95 jun 11 [gh] Added -p option for YARN.
|    2.0 94 may 19 [gh] Wrote it as part of mimelite ver. 2.0.
|
| Authorship:
|    Copyright (c) 1995 Gisle Hannemyr.
|    Permission is granted to hack, make and distribute copies of this program
|    as long as this copyright notice is not removed.
|    Flames, bug reports, comments and improvements to:
|       snail: Gisle Hannemyr, Hegermannsgt. 13c, N-0478 Oslo, Norway
|       email: Inet: gisle@oslonett.no, gisle@ifi.uio.no
|
| Environment:
|    Unix or MSDOS (make sure that either __MSDOS_ or __UNIX_ is defined).
+---------------------------------------------------------------------------*/

#define MAIN

/* Canonize macroes predefined by the compiler. */
#define MSDOS
#ifdef MSDOS
#define __MSDOS__  1
#endif

#ifdef msdos
#define __MSDOS__  1
#endif

#ifdef unix
#define __UNIX__   1
#endif

/* #include "config.h" */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __MSDOS__
#include <conio.h>
#endif
#include "mimelite.h"

/*---( defines )------------------------------------------------------------*/

#define BUFFSIZ	    256			/* Input line buffer size	    */

#ifdef __MSDOS__
#define WMODE	    "wb"
#define RMODE	    "rb"
#endif
#ifdef __UNIX__
#define WMODE	    "w"
#define RMODE	    "r"
#endif


/*---( constants )----------------------------------------------------------*/

static char about[] = "\
This program (unmime) will convert a MIMEd message into plain text.\n\
It demonstrates some of the abilities of the mimelite library.  You\n\
may get the full library  (including source code)  by anonymous ftp\n\
from:\n\n\
   oslonett.no:Software/MsDos/Comm/Offline/mimeltXX.zip\n\n\
Bug reports, improvements, comments, suggestions and flames to:\n\
   snail: Gisle Hannemyr, Hegermannsgt. 13c, N-0478 Oslo, Norway\n\
   email: gisle@oslonett.no;\n";

static char usage[] = "\
   Usage: unmime [options] file_in [file_out]\n\
   Valid options:\n\
\t-a          -- about unmime\n\
\t-h          -- print this quick summary\n\
\t-b          -- decode base64 encoded body (no header)\n\
\t-q          -- decode quoted-printable encoded body (no header)\n\
\t-p[<lines>] -- page output (<lines> = page size, default: 24)\n\
\t-s          -- split (write only body to file_out)\n\n\
The program expects  file_in  to be a full mime message  (including\n\
headers).  It will parse the headers and decode the message. If you\n\
specify  the -b or the -q option,  unmime will assume this encoding\n\
and will process a message body without any headers.\n\n\
The decoded file will be written on file_out. If you do not specify\n\
this file, the result is written to standard output.\n\n";


/*---( globals )------------------------------------------------------------*/

int OpFilep;	/* zero if writing output is stdout, one if op is real file */
int Pausep=0;	/* zero if no pause, else lines we should pause after	    */


/*---( decode )-------------------------------------------------------------*/

/*
| Abs:
| Ret: Return 1 if abort.
*/
static int pressany(int endp)
{
    int cc;

#ifdef __MSDOS__
    fputs(endp ? "-- end --" : "-- more -- (Y/n) ", stdout);
    fflush(stdout);
    cc = getch();
    if ((cc == '\03') || (cc == 'n') || (cc == 'N')) {
        fputs("no\n", stdout);
	return(1);
    } /* if */
    fputs("\r                     \r", stdout);
#else
    fputs("-- more -- ", stdout);
    fflush(stdout);
    cc = getc(stdin);
    if ((cc == '\03') || (cc == 'n') || (cc == 'N')) return(1);
#endif
    return(0);
} /* pressany */


/*
| Abs: Decode a message.
| Par: inp = input  file
|      oup = output file
|      nam = name of output file
|      spl = nonzero if header and body should be split beteen stdout and oup
|      enc = encoding to use (or CE_PRSHEAD if parse to heading to find out)
| Des: ml_unmimeline returns:
|      0: nothing special
|      1: line is null line separating header from body
|      2: found junk trailing BASE64 encoding
|      3: dumping attachement to named file
| Ret: Lines written.
*/
static int decode(FILE *inp, FILE *oup, char *nam, int spl, int enc)
{
    unsigned char buff[BUFFSIZ];
    FILE *ofile;
    int state, sep, bsiz, ll;

    ml_unmimsetup(CS_ISOL1, enc, AC_DOITALL);	    /* Set up state machine */
    sep = (enc == CE_PRSHEAD) && !(OpFilep || spl); /* Print separators?    */
    ll = 0;
    
    if (sep) fputs("============================================================================\n",  stdout);

    if (spl) ofile = stdout;
    else     ofile = oup;
    while (fgets(buff, BUFFSIZ, inp)) {
	state = ml_unmimeline(buff, &bsiz);
	if (Pausep && ((ll++) >= Pausep)) {
	    ll = 0;
	    if (pressany(0)) return(ll);
	} /* if */
	    
	/* printf("DB: state = %d [%s]\n", state, buff); */
	if (state == 1) {
	    if (sep) fputs("----------------------------------------------------------------------------",  stdout);

	    /* Don't fold if we don't know it (probably binary data)	    */
	    if (Charset == CS_PRIVT) {
		if (!ml_foldinit(CS_UNKWN, CS_UNKWN)) { fputs("*** bad i/p cset\n", stderr); return(0); }
	    } /* if (probably binary data) */

	    fwrite(buff, bsiz, 1, ofile);
	    if (NamePar) {
		printf("    [[ writing named file to \"%s\" ]]\n", NamePar);
	    } /* if (decoding attachement) */
	    if (spl) {
		ofile = oup;
		printf("    [[ body is extracted to file \"%s\" ]]\n\n",  nam);
	    } /* if (split) */
	} else if ((state == 2) && spl) {
	    fflush(oup);	/* flush it */
	    fclose(oup);	/* close it */
	    OpFilep = 0;	/* no longer writing to oup */
	    ofile = stdout;	/* dump rest on stdout */
	} else if (state == 3) {
	    /* fputc('#', stdout); */
	} else {
	    fwrite(buff, bsiz, 1, ofile);
	    ll += bsiz/80;
	} /* if (end of header) print separator, else print buffer */
    } /* while */

    if (sep) {
	state = strlen(buff);
	if (state) state--;
	if (buff[state] != '\n') { ll++; fputc('\n', stdout); }
	fputs("============================================================================\n",  stdout);
	ll++;
    } /* if */
    ml_unmimedone();
    return(ll);

} /* decode */


/*---( main )---------------------------------------------------------------*/

int main(int  argc, char *argv[])
{
    FILE *inp, *oup;
    char *target;
    int   tarcnt;
    int b64flag, q_pflag, splflag;
    int cset, enc, ll;
    char cc;

    tarcnt = 0;
#ifdef __MSDOS__
    target = "MSDOS";
    tarcnt++;
    cset   = CS_CP850; /* Change this to CS_CP437 if that's your codepage */
#endif
#ifdef __UNIX__
    target = "UNIX";
    tarcnt++;
    cset   = CS_ISOL1;
#endif
    if (tarcnt != 1) {
	fputs("*** I'm confused about what system we are running on.\n", stderr);
	return(3);
    } /* if confusing environment) */


    fprintf(stderr,"unmime (%s)  ver. %s; Copyright (c) 1995 Gisle Hannemyr\n\n", target, VERSION);

    enc = CE_PRSHEAD;
    b64flag = q_pflag = splflag = 0;
    argc--; argv++;           /* skip program name  */
    while (argc && (**argv == '-')) {
	(*argv)++;            /* skip initial '-'   */
	cc = **argv;          /* option letter      */
	(*argv)++;             /* skip option letter */
        switch (cc) {
          case 'a': fputs(about, stderr);		return(0);
          case 'b': b64flag = 1; enc = CE_BASE064;	break;
          case 'h': fputs(usage,stderr);		return(0);
          case 'p': if (**argv != '\0') Pausep = atoi(*argv) - 2;
		    else Pausep = 22;			break;
          case 'q': q_pflag = 1; enc = CE_QUOTEDP;	break;
          case 's': splflag = 1;	  		break;
          default : fputs(usage,stderr);		return(1);
        } /* switch */
        argc--; argv++;
    } /* while options */

    if ((argc < 1) || (argc > 2)) { fputs(usage,stderr); return(1); }
    if ((splflag + b64flag + q_pflag) > 1) {
	fputs("*** Incompatible options (type: unmime -h for help).\n",stderr);
	return(1);
    } /* incompatible options */

    if (Pausep && (argc > 1)) {
	fputs("*** Can't page when writing to file.\n",stderr);
	return(1);
    } /* incompatible options */

    if (splflag && (argc != 2)) {
	fputs("*** You need to specify file_out to split.\n",stderr);
	return(1);
    } /* incompatible options */

    if (!(inp = fopen (*argv, RMODE))) {
	printf("*** Error while opening input-file %s.\n", *argv);
	return(2);
    }

    argc--; argv++;
    if (argc) {
	if (!(oup = fopen (*argv, WMODE))) {
	    printf("*** Error while opening output-file %s\n", *argv);
	    return(2);
	}
	OpFilep = 1;
    } else {
	oup = stdout;
	OpFilep = 0;
    }


    if (!ml_foldinit(CS_ISOL1, cset)) {
        fputs("*** bad o/p charset\n", stderr);
	return(4);
    } /* if */

    if (Pausep) fputs("\n\n", stdout);
    ll = decode(inp, oup, *argv, splflag, enc);

    if (OpFilep) fclose(oup);
    fclose(inp);

    if (ll && Pausep) pressany(1);

    return(0);

} /* main */

/* EOF */
