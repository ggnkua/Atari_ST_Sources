/* File names and variables for bison,
   Copyright (C) 1984 Bob Corbett and Free Software Foundation, Inc.

BISON is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the BISON General Public License for full details.

Everyone is granted permission to copy, modify and redistribute BISON,
but only under the conditions described in the BISON General Public
License.  A copy of this license is supposed to have been given to you
along with BISON so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

 In other words, you are welcome to use, share and improve this program.
 You are forbidden to forbid anyone else to use, share and improve
 what you give them.   Help stamp out software-hoarding!  */

/* These two should be pathnames for opening the sample parser files.
   When bison is installed, they should be absolute pathnames.
   XPFILE1 and XPFILE2 normally come from the Makefile.  */

#ifdef atarist
#define PFILE "f:\\gnu\\bison\\bison.sim"
#define PFILE1 "f:\\gnu\\bison\\bison.hai"
#else
#define PFILE	XPFILE		/* Simple parser */
#define PFILE1	XPFILE1		/* Semantic parser */
#endif

extern FILE *finput;   /* read grammar specifications */
extern FILE *foutput;  /* optionally output messages describing the actions taken */
extern FILE *fdefines; /* optionally output #define's for token numbers. */
extern FILE *ftable;   /* output the tables and the parser */
extern FILE *fattrs;   /* if semantic parser, output a .h file that defines YYSTYPE */
		       /* and also contains all the %{ ... %} definitions.  */
extern FILE *fguard;   /* if semantic parser, output yyguard, containing all the guard code */
extern FILE *faction;  /* output all the action code; precise form depends on which parser */
/* JF nowaday fparser is used for whatever parser is in use, instead of
   opening both of them. */
extern FILE *fparser;  /* read the semantic parser to copy into ftable */
/* JF   extern FILE *fparser1; /* read the simple parser to copy into ftable */

extern char *infile;
extern char *outfile;
extern char *defsfile;
extern char *tabfile;
extern char *attrsfile;
extern char *guardfile;
extern char *actfile;
/* JF nobody seems to care about these
extern char *pfile;
extern char *pfile1; */
