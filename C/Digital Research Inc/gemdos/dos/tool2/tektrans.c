/*
	Copyright 1984
	Alcyon Corporation
	8716 Production Ave.
	San Diego, CA  92121

	@(#)tektrans.c	1.2	8/1/84
*/

#include <stdio.h>

#define S_NAMLEN	9	/* added one byte for null terminator */

struct symtab {
	char s_name[S_NAMLEN];/*symbol name */
	int  s_flags;			/*bit flags */
	long s_value;			/*symbol value */
	struct symtab *s_next;	/*table link */
};

#define	NSYMS	128
struct symtab *symtab[NSYMS];

/* flags for symbols */
#define S_DEFINED	01		/*defined */
#define S_COMMON	02		/*COMM symbol */
#define	S_GLOBAL	04		/*global symbol*/



	/* miscellaneous variables */
FILE *infd;
FILE *outfd;
char symbol[S_NAMLEN];
char altsym[S_NAMLEN];
char mnusym[S_NAMLEN];
long conval;
char spval;
int section;
int newline;
int charcnt;
int line;

/* tokens from gettoken: */
#define SYMBOL		1
#define CONSTANT	2
#define SPECIAL		3
#define HEXCON		4
#define	PS_EVEN		5
#define	PS_GLOBL	6
#define	PS_TEXT		7
#define	PS_DATA		8
#define	PS_BSS		9
#define	PS_COMM		10
#define	PS_DCB		11
#define	PS_DCW		12
#define	PS_DCL		13
#define	REGNAME		14

struct pseudo {
	char *ps_name;
	int ps_type;
} pseudotab[] = {
	".EVEN",	PS_EVEN,
	".GLOBL",	PS_GLOBL,
	".TEXT",	PS_TEXT,
	".DATA",	PS_DATA,
	".BSS",		PS_BSS,
	".COMM",	PS_COMM,
	".DC.B",	PS_DCB,
	".DC.W",	PS_DCW,
	".DC.L",	PS_DCL,
	0,
};

struct symtab *lookup();
struct symtab *symalloc();
char *fixsym();

char longnum[20];
main(argc,argv)
int argc;
char **argv;
{
	register char *p;
	register int i;
	register char c;
	char *tempfn, *mktemp();
	long l;

	if (argc != 2) {
		fprintf(stderr,"Usage: tektrans inputfile\n");
		exit(1);
	}
	if ( (infd=fopen(argv[1],"r")) == NULL ) {
		fprintf(stderr,"can't open %s\n",argv[1]);
		exit(1);
	}
	if( (outfd=fopen(tempfn = mktemp("/tmp/tktrXXXXX"),"w+")) == NULL ) {
		fprintf(stderr,"can't create temp file: %s\n",tempfn);
		exit(1);
	}
	newline = 1;
	line = 1;	/*current line number */
	while( (i = gettoken()) != EOF ) {
doswt:
		switch(i) {	/*type of this token */

		case PS_EVEN:
			fprintf(outfd,"ORG /2\n");
			break;

		case PS_GLOBL:
			ignorebl();
			if( gettoken() != SYMBOL )
				abort("bad .globl");
			install(symbol,S_GLOBAL,(long)0);
			break;

		case PS_TEXT:
			outsect(0);
			break;

		case PS_DATA:
		case PS_BSS:
			outsect(1);
			break;
					
		case PS_COMM:
			ignorebl();
			if( gettoken() != SYMBOL )
				abort("bad .comm");
			strcpy(altsym,symbol);
			if( next(',') == 0 || gettoken() != CONSTANT )
				abort("bad .comm");
			install(altsym,S_COMMON,conval);
			break;

		case PS_DCB:
			strcpy(mnusym,"BYTE");
			fprintf(outfd," BYTE");
			continue;

		case PS_DCW:
			strcpy(mnusym,"WORD");
			fprintf(outfd," WORD");
			continue;

		case PS_DCL:
			strcpy(mnusym,"LONG");
			fprintf(outfd," LONG");
			continue;

		case REGNAME:
			if( next('-') ) {
				if( strcmp("D7",symbol) == 0 ) {
					if( (i = gettoken()) != REGNAME ||
							strcmp("D7",symbol) != 0 )
						fprintf(outfd,"D7-");
					goto doswt;
				}
				else if( strcmp("A5",symbol) == 0 ) {
					if( (i = gettoken()) != REGNAME ||
							strcmp("A5",symbol) != 0 )
						fprintf(outfd,"A5-");
					goto doswt;
				}
				ungetc('-',infd);
			}
			fprintf(outfd,"%s",symbol);
			continue;

		case SYMBOL:
			if( symbol[0] == '~' ) 
				break;
			if( next(':') ) {	/*label */
				fprintf(outfd,"%s EQU $\n",fixsym(symbol));
				install(symbol,S_DEFINED,(long)0);
				next('\n');
				newline++;
				continue;
			}
			if( newline ) {
				newline = 0;
				if( strcmp("CLR",symbol) == 0 ) {	/* 13 oct 83 */
					ignorebl();
					if( (i = gettoken()) == REGNAME ) {
						if( symbol[0] == 'A' )
							fprintf(outfd," SUBA %s,%s\n",symbol,symbol);
						else
							fprintf(outfd," CLR %s\n",symbol);
						break;
					}
					fprintf(outfd," CLR ");
					goto doswt;
				}
				if( strcmp("CLR.L",symbol) == 0 ) {
					ignorebl();
					if( (i = gettoken()) == REGNAME ) {
						if( symbol[0] == 'A' )
							fprintf(outfd," SUBA.L %s,%s\n",symbol,symbol);
						else
							fprintf(outfd," CLR.L %s\n",symbol);
						break;
					}
					fprintf(outfd," CLR.L ");
					goto doswt;
				}
				fprintf(outfd," %s",symbol);	/*must be mneumonic */
				if( equsub("AS",symbol) || equsub("LS",symbol) ||
						equsub("RO",symbol)) {	/*shifts or rotates */
					putc(' ',outfd);
					ignorebl();
					if( (i = gettoken()) == REGNAME ) {
						if( next(',') )
							fprintf(outfd,"#1,%s",symbol);
						else
							fprintf(outfd,"%s",symbol);
						continue;
					}
					goto doswt;
				}
			}
			else {
				if( symbol[0] == '.' || builtin() )	/*external symbol */
					install(symbol,0,(long)0);
				fprintf(outfd,"%s",fixsym(symbol));
			}
			continue;

		case CONSTANT:
			fprintf(outfd,longnum);
			continue;

		case HEXCON:
			fprintf(outfd,"0%sH",longnum);
			continue;

		case SPECIAL:
			if( newline && spval == '*' ) {		/*comment line */
				fprintf(outfd,"; ");
				copyrest();
				continue;
			}
			if( spval == '\n' )
				newline++;
			if( spval == ',' ) {
				if( charcnt > 60 ) {
					fprintf(outfd,"\n %s ",mnusym);
					charcnt = 6;
					continue;
				}
				putc(',',outfd);
				if((i = gettoken()) == SPECIAL && spval==' ')	/*ignore it */
					continue;
				goto doswt;
			}
			putc(spval,outfd);
			continue;
		}
		ignore();
	}
	doundefs();		/*make undefineds external */
	rewind(outfd);
	while( (c = getc(outfd)) != EOF )
		putchar(c);
	printf(" END\n");
	fclose(outfd);
	unlink(tempfn);
}

/* check a symbol token for a register name and convert them if found */
regname()
{
	register char *p;
	register int rn;
	register char extc;

	p = symbol;
	if( strcmp("SP",p) == 0 )
		return(1);
	if( *p++ != 'R' )
		return(0);
	for( rn = 0; *p >= '0' && *p <= '9'; )
		rn = rn*10 + *p++ - '0';
	if( rn > 15 )
		return(0);
	if( *p != '\0' ) {
		if( *p++ != '.' || (*p != 'L' && *p != 'W' && *p != 'B') )
			return(0);
		extc = *p;
	}
	else
		extc = 0;
	p = symbol;
	if( rn > 7 ) {
		*p++ = 'A';
		rn -= 8;
	}
	else
		*p++ = 'D';
	*p++ = rn + '0';
	if( extc ) {
		*p++ = '.';
		*p++ = extc;
	}
	*p++ = 0;
	return(1);
}

/* get the next char from the input stream */
gchr()
{
	register char c;

	c = getc(infd);
	charcnt++;
	if( c == '\n' ) {
		line++;
		charcnt = 0;
	}
	else if( c >= 'a' && c <= 'z' )
		c += 'A'-'a';		/*convert to upper case */
	else if( c == '\t' || c < -1 )
		c = ' ';
	return(c);
}

/* get next token and return token type in toktyp */
gettoken()
{
	register int c;
	register int i;
	register char *p;
	register struct pseudo *psp;

	if( (c=gchr()) <= 0)
		return(EOF);
	if( c == '$' ) {	/*hex constant */
		conval = 0;
		p = longnum;
		while( 1 ) {
			if( (c = gchr()) >='0' && c <= '9')
				conval = conval*16 + c - '0';
			else if( c >= 'A' && c <= 'F' )
				conval = conval*16 + c - 'A' + 10;
			else
				break;
			*p++ = c;
		}
		*p = 0;
		ungetc(c,infd);
		return(HEXCON);
	}
	if( c >= '0' && c <= '9' ) {
		for( conval = 0, p = longnum; c >= '0' && c <= '9'; c = gchr() ) {
			conval = conval*10 + c - '0';
			*p++ = c;
		}
		*p = 0;
		ungetc(c,infd);
		return(CONSTANT);
	}
	if( alphanum(c) ) {
		for( p = symbol; alphanum(c); c = gchr() )
			*p++ = c;
		*p++ = 0;
		ungetc(c,infd);
		if( symbol[0] == '.' ) {
			for( psp = pseudotab; psp->ps_name != 0; psp++ )
				if( strcmp(symbol,psp->ps_name) == 0 )
					return(psp->ps_type);
		}
		for( p = symbol; *p ; p++ )
			if( *p == '_' )
				*p = '.';
		if( regname() )
			return(REGNAME);
		return(SYMBOL);
	}
	spval = c;
	return(SPECIAL);
}

char *builts[] = {
	"LMUL",
	"LMULU",
	"LREM",
	"LREMU",
	"ALMUL",
	"ALDIV",
	"ALREM",
	"LDIV",
	"LDIVU",
	0
};

builtin()
{
	register char **p;

	for( p = builts; *p != 0; )
		if( strcmp(*p++,symbol) == 0 )
			return(1);
	return(0);
}

/* ignore rest of this line */
ignore()
{
	while( gchr() != '\n' )
		;
	newline++;
}

/* copy the rest of the line changing _ to .  as the first char of any symbol */
copyrest()
{
	register char c;

	while( (c = gchr()) != '\n') {
		if( c == '_' )
			c = '.';
		putc(c,outfd);
	}
	putc('\n',outfd);
	newline++;
}

alphanum(c)
register int c;
{
	return(((c >= 'A' && c<='Z') || c == '_' || c == '~' ||
			(c >= '0' && c <= '9') || c == '.'));
}

/* ignore blanks */
ignorebl()
{
	register char c;

	while( (c = gchr()) == ' ' )
		;
	ungetc(c,infd);
}

/* generate XREF for all undefined symbols */
doundefs()
{
	register struct symtab *sp;
	register char *p;
	register int i;

	for( i = 0; i < NSYMS; i++ )
		for( sp = symtab[i]; sp != 0; sp = sp->s_next )
			if( (sp->s_flags&S_COMMON) != 0 ) {
				p = fixsym(sp->s_name);
				printf(" GLOBAL %s\n",p);
				fprintf(outfd,"%s EQU $\n BLOCK %ld\n",p,sp->s_value);
			}
			else if( (sp->s_flags&S_GLOBAL) != 0 ||
					(sp->s_flags&S_DEFINED) == 0 )
				printf(" GLOBAL %s\n",fixsym(sp->s_name));
}

abort(s)
char *s;
{
	fprintf(stderr,"tektrans abort line %d: %s\n",line,s);
	exit(1);
}

/* try to match a substring anchored at beginning */
equsub(s,t)
char *s, *t;
{
	return( strncmp(s,t,strlen(s)) == 0 );
}

outcomm(asp)
char *asp;
{
	register char *sp;

	sp = asp;
	if(*sp == '_')
		sp++;
	install(sp,S_COMMON,(long)0);
}

char *secnam[] = {
	"TEXT",
	"DATA"
};

int doresum[2];

outsect(secno)
int secno;
{
	if( section != secno ) {
		if( doresum[secno] )
			fprintf(outfd," RESUME %s\n",secnam[secno]);
		else {
			fprintf(outfd," SECTION %s\n",secnam[secno]);
			doresum[secno] = 1;
		}
		section = secno;
	}
}

char tmpsym[S_NAMLEN+1];

char *fixsym(sp)
register char *sp;
{
	register char *p;
	register char c;

	p = tmpsym;
	if( *sp != '.' )
		return(sp);
	*p++ = 'C';
	while( *p++ = *sp++ )
		;
	*p = '\0';
	return(&tmpsym[0]);
}

struct symtab *lookup(s)
register char *s;
{
	register int i;
	register struct symtab *sp;

	i = hash(s);
	for( sp = symtab[i]; sp != 0; sp = sp->s_next )
		if( strcmp(s,sp->s_name) == 0 )
			return(sp);
	return(NULL);
}

install(s,flags,value)
register char *s;
int flags;
long value;
{
	register int i;
	register struct symtab *sp;

	if( (sp = lookup(s)) != NULL ) {
		if( (flags&S_DEFINED) != 0 )
			sp->s_flags |= S_DEFINED;
		if( (flags&S_COMMON) != 0 )
			sp->s_flags |= S_COMMON;
		if( (sp->s_flags&S_COMMON) != 0 && value > sp->s_value )
			sp->s_value = value;
		if( (flags&S_GLOBAL) != 0 )
			sp->s_flags |= S_GLOBAL;
	}
	else {
		sp = symalloc();
		sp->s_flags = flags;
		sp->s_value = value;
		strcpy(sp->s_name,s);
		i = hash(s);
		sp->s_next = symtab[i];
		symtab[i] = sp;
	}
}

hash(s)
register char *s;
{
	register int i;

	for( i = 0; *s; )
		i += *s++;
	return( i % NSYMS );
}

struct symtab *symap;
#define	NSYMAP	20
char *sbrk();

struct symtab *symalloc()
{
	register int i;
	register struct symtab *sp;

	if( symap == 0 ) {
		if( (symap = (struct symtab *)sbrk((sizeof *symap)*NSYMAP)) == NULL )
			abort("too many symbols");
		for( i = 0, sp = symap; i < NSYMAP-1; sp++, i++ )
			sp->s_next = sp + 1;
		sp->s_next = 0;
	}
	sp = symap;
	symap = sp->s_next;
	return(sp);
}

next(tc)
int tc;
{
	register char c;

	if( (c = gchr()) == tc )
		return(1);
	ungetc(c,infd);
	return(0);
}
