/*
 * ltb.c - Lexical Table Builder
 *
 * Functional description:
 *
 *	This program builds a file containing the data
 *	structures of a compile-time-initialised hash table.
 *	This hash table may later be used for lexical analysis,
 *	where number of symbols to look up is sufficiently large
 *	to avoid a run-time table initialization.
 *	In order to guarantee the success of this setup, the
 *	hash routine, the lookup and install routines should be
 *	the same between ltb and the lexical analysis.
 *
 * synopsis:
 *
 *	ltb <input file> [table name]
 *
 * input file format:
 *
 *	<token>  <value identifier> [flag value]
 *
 *	token: 		string of alphanumeric characters to be
 *		       	matched by the lexical analyser (no blanks).
 *			these token strings are "installed" to a hash
 *			table by ltb to avoid run-time overhead.
 *	value
 *	identifier:	A constant name to be used internally by the
 *			lexical analyser in place of the actual
 *			token value. a "#define <indentifier> <value>"
 *			is generated for each value identifier, where
 *			value is an odd and unique integer constant. If
 *			the value identifier is a `*' (star), then the
 *			previous value is repeated. Thus:
 *
 * 			      token   ident.   flag
 *
 *				sp	SP	1
 *				space	*	 	{ inherits SP  }
 *				blank	* 	 	{ inherits SP  }
 *				.	.	.
 *				.	.	.
 *
 *	flag value:	An additional integer field to pass flags etc. to
 *			the lexical analyser. If not specified, set to
 *			0. token value field must be present for this field
 *			to be obtained.
 *
 * outputs:
 *
 *	ltb generates two C include files:
 *
 *		[tablename].d:  compile time lexical constants (defines)
 *		[tablename].h:	initialised hash table.
 *
 *	where [tablename] is the name of the hash table as specified
 *	in the command line of ltb. If not specified, "lextab" is used
 *	as a default.
 *
 * routines used by LTB:
 *
 *	hash, lookup and a modified version of install routines,
 *	as defined in K&R, pp. 134 - 136.
 *
 * Application areas:
 *
 *	Lexical analysers for compilers, interpreters, spelling
 *	checkers.
 *
 * Author:
 *	Ozan S. Yigit
 *	Dept. of Computer Science
 *	York University
 *
 */

#define MAXLINE		80
#define MAXSYM		80

#include <stdio.h>
#include <ctype.h>
#include "lookup.h"

struct
lexlist	(*(*lextable))[];/* global pointer for lexical analyser hash table */

static struct lexlist *hashtab[HASHMAX];
static struct lexlist *defitab[HASHMAX];

char *tabnam;		/* table name */

extern int hash();
extern struct hashlist *lookup();
extern struct hashlist *install();
extern char *strsave();
extern struct lexlist *lexinstal();
extern struct lexlist *lexlook();
extern struct lexlist *remove();
extern FILE *fopen(), *fclose();

main(argc,argv)
int argc;
char *argv[];
{
	FILE *fp;
	char line[MAXLINE];
	char sym[MAXSYM],def[MAXSYM];
	register int val;
	register int prev, *p;
	register char *ptr;
	int flag;
	struct lexlist *np, *lexlook();

	if (argc <= 2) {
		fprintf(stderr,"%s [-<base>] <symbol file> [tablename]\r\n",
		argv[0]);
		exit(1);
	}

	if (*argv[1] == '-') {
		val = atoi(argv[1]+1);	/* skip "-" and convert */
		val = (val & 1) ? val : val+1;
		p = (int *)argv[2];
	}
	else {
		val = 1;
		p = (int *)argv[1];
	}

	if (argc < 3)
		tabnam = "lextab";
	else
		tabnam = argv[argc-1];

	if ((fp = fopen(p,"r")) == NULL) {
		fprintf(stderr,"%s:cannot open.\r\n",argv[1]);
		exit(1);
	}
	else {
		prev = val;
		while (fgets(line,MAXLINE,fp) != NULL) {
			if (*line != '!') {
				flag = 0;
				def[0] = '\0';
				ptr = line;
				while (isspace(*ptr))
					ptr++;
				if (*ptr == '\0')
					continue;
				sscanf(line,"%s %s %d",sym,def,&flag);
				if (!(def[0] == '*' && def[1] == '\0')) {
					if ((np = lexlook(def,defitab)) == NULL) {
						/* value define  */
						lexinstal(def,val,0,defitab);
						prev = val;
						val += 2;
					}
					else
						prev = np->val;
				}
				 /* lexical token */
				lexinstal(sym,prev,flag,hashtab);
			}
		}
		defgen();
		lexgen();
	}
}
/*
 * lexgen - print out the hash table in static form
 *
 */
lexgen()
{
	register int i;
	register struct lexlist *np;
	char filebuf[12];
	char *file;
	FILE *op;

	file = filebuf;

	strncpy(file,tabnam,8);
	strcat(file,".h");

	if ((op = fopen(file,"w")) == NULL) {
		fprintf(stderr,"%s: cannot create.\r\n",file);
		exit(1);
	}

	fprintf(op,"#ifndef STRUC_DEFINED\n\n");
	fprintf(op,"\/\*\t%s\t\*\/\n\n%s\n%s\n%s\n%s\n%s\n",file,
	"struct _lex_h { 	char 	*__s;",
	"		  	int 	 __v;",
	"		  	int  	 __f;",
	"		struct  _lex_h  *__l;",
	"};");
	fprintf(op,"\n#define STRUC_DEFINED\n#endif\n");

	/*
			 * generate the hash table entries.
			 * each entry is followed by the next entry in its
			 * chain.
			 * In the operating systems with memory paging, this
			 * should have the extra advantage of localized
			 * memory referances.
			 *
	 */

	for (i=0; i < HASHMAX; i++)
		if ((np = hashtab[i]) != NULL)
			prnode(np,op);
	/*
			 * At last, we generate the pointer array (hashtable).
			 * this table should be assigned to lextable global
			 * variable before using with lexlook() or lexinstal().
			 * lextable is defined in lookup.h
			 *
	 */

	fprintf(op,"\n\n\/\*  Hash Table \*\/\n\n");
	fprintf(op,"struct _lex_h *%s[%d] = {\n\t",tabnam,HASHMAX);
	for (i=0; i < HASHMAX - 1; i++) {
		np = hashtab[i];
		if(np == NULL)
			fprintf(op,"NULL,\t");
		else
			fprintf(op,"\&__%s,\t", np->name);
		if (i % 4 == 0)
			fprintf(op,"\n\t");
	}
	np = hashtab[i];
	if (np == NULL)
		fprintf(op,"NULL  };\n");
	else
		fprintf(op,"\&__%s   };\n", np->name);

	fclose(op);
}

/*
 * prnode - print the current node. This routine is
 *	    recursive such that printing starts from
 *	    the end of the given list
 *
 */
prnode(np,op)
register struct
lexlist *np;
FILE *op;
{
	if (np->link != NULL)
		prnode(np->link,op);
	fprintf(op,"struct\n_lex_h __%s = {  ",
	np->name);
	fprintf(op,"\"%s\",\n              %6d,%6d,",
	np->name,
	np->val,
	np->flag);
	if (np->link != NULL)
		fprintf(op,"\&__%s };\n",
		(np->link)->name);
	else
		fprintf(op,"NULL };\n");
}	

/*
 * defgen - generate a file containing the lexical
 *	    constants to be equated to lexical symbols
 */
defgen()
{
	register int i;
	register struct lexlist *np;
	char *file;
	char filebuf[12];
	FILE *op;

	file = filebuf;
	strncpy(file,tabnam,8);
	strcat(file,".d");

	if ((op = fopen(file,"w")) == NULL) {
		fprintf(stderr,"%s: cannot create.\r\n",file);
		exit(1);
	}
	for (i=0; i < HASHMAX; i++) {
		for (np = defitab[i]; np != NULL; np = np->link)
			fprintf(op,"\#define  %s\t%d\n",
			np->name,
			np->val);
	}
	fclose(op);
}

