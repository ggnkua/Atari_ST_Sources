/*
 * SPEW.C, Atari-Portierung. L„uft, wenn auch holprig, unter Pure C durch.
 *         Don't care about the warnings ;-)
 */
#ifndef lint
static char *cpr[]={
"  Copyright 1987 Greg Smith",
"  Permission is granted to freely use and distribute this software",
"provided this notice is left attached and no monetary gain is made."
};
#endif

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#ifdef unix
#include <strings.h>
#else
extern char *strcpy ();
#define index strchr
#define rindex strrchr
extern char *index ();
extern char *rindex ();
#endif

/* extern char *malloc(); */
char *my_alloc();
extern int atoi();
char *save();

#define TRUE 1
#define FALSE 0
#define MAGIC 4		/* distinguish compressed file from normal */

/*--------------- system configuration ------------------*/

/* define some parameters */

#define MAXCLASS 300		/* max # of classes */
#define MAXLINE 256		/* max size of input line */
#define MAXDEF 1000		/* max # bytes in a definition */

/* Define the default rulesfile */

#ifndef DEFFILE
#define DEFFILE "HEADLINE.TXT"
#endif

/* Define the environment variable which is to be interrogated for
   name of rules file before DEFFILE is used. Delete this to
   remove the code that calls getenv() */

/* #define ENVIRON "RULESFILE" */

/* Define the random number generator */

extern long getpid();
extern int rand();
extern void srand();

	/* SETRAND must be complete statement: note semicolon */
#define SETRAND (void)srand((int) time((long *)0) );

	/* ROLL(n) returns integer 0..n-1 */
#define ROLL(n) ((((long)rand()&0x7ffffff)>>5)%(n))

/* Enable '-d' dump debug option by defining DUMP */
#define DUMP

/*---------------------------------------------------*/

FILE *InFile;

typedef struct def_struct{
	int cumul;			/* cumulative weights */
	char *string;			/* string which defines it */
	struct def_struct *next;	/* link to next */
} defn;
defn *process();
/*
 * within a definition, names of subdefinitions are bracketed in BSLASH
 * and SLASH chars. The whole definition ends with a '\0'.
 * The SLASH character is always follwed by a variant tag - default is ' '.
 */
#define BSLASH '\\'
#define SLASH  '/'
#define VBAR	 '|'

typedef struct{
	int weight;	/* total weight of definitions in class */
	defn *list;	/* list of them */
	char *name;	/* name of this class */
	char *tags;	/* pointer to list of tags */
} class;

class * Class;	/* pointer to array of class records */
char *NullTags = " ";	/* default tags ( shared ) */
int Classes;	/* number of them */
int HowMany = 1;
int CompIn = FALSE;	/* is input file in compressed format? */
int CompMain;		/* class # of MAIN class when compressed */

char InLine[MAXLINE];

init(){
	int c;

	SETRAND		/* spin random number gen */
	c = getc( InFile );	/* is compressed? */
	CompIn = ( c== MAGIC );	/* set flag */
	if( CompIn ){
		readcomp();	/* read compressed version */
	}else{
		ungetc(c, InFile );
		readtext();
	}
}

main(argc, argv )
int argc;
char **argv;
{
	char *fname;
	char main_class[20];
	int i, c_flag = FALSE;
#ifdef DUMP
	int d_flag = FALSE;
#endif DUMP
#ifdef ENVIRON
	extern char *getenv();
	fname = getenv( ENVIRON );
#else
	fname = NULL;
#endif ENVIRON

	while( argc > 1 ){
		if( isdigit(*argv[1]) ){
			HowMany = atoi(*++argv);
			--argc;
		}else if( strcmp( argv[1], "-c") == 0 ){
			c_flag = TRUE; 	/* 'compress' option */
			--argc;
			++argv;
#ifdef DUMP
		}else if( strcmp( argv[1], "-d" )== 0 ){
			d_flag = TRUE;	/* 'dump' option */
			--argc;
			++argv;
#endif DUMP
		}else break;
	}
	if( argc > 1 ) fname = argv[1];
	if (fname == NULL ) fname = DEFFILE;
	InFile = fopen( fname, "r" );
	if( InFile == NULL ){
		fprintf( stderr, "Can\'t open: %s\n", fname );
		exit(1);
	}
	init();
#ifdef DUMP
	if( d_flag ){
		dump();
		exit(0);
	}
#endif DUMP
	if( c_flag ){
		compress();
	}else{
		if( CompIn ) sprintf( main_class, "%d/ ", CompMain);
		else	     strcpy( main_class, "MAIN/ ");
		printf("\n+++ Letzte Meldun%s\n",(HowMany==1)?"g:":"gen:");
		printf("------------------------------------------------------------------------------\n");
		for(i=0; i<HowMany; ++i) { display(main_class,' ');
					   printf("------------------------------------------------------------------------------\n"); }
	      }
	printf("\n");
	exit(0);
      }

readtext(){
	register class *cp;
	register defn *dp;
	defn **update;
	int clcomp();

	Class = (class *)my_alloc( (unsigned)(MAXCLASS * sizeof(class)) );
	Classes = 0;

	cp = Class;
	readline();
	if( InLine[0]!='%'){
		fprintf( stderr,"Class definition expected at: %s\n", InLine);
		exit(1);
	}
	while( InLine[1] != '%' ){
		if( Classes == MAXCLASS ){
			fprintf(stderr,"Too many classes -- max = %d\n", MAXCLASS);
			exit(1);
		}
		setup( cp );		/* set up the class struct */
		readline();
		if( InLine[0] == '%' ){
			fprintf( stderr, "Expected class instance at: %s\n", InLine);
			exit(1);
		}
		update = &(cp->list);	/* update pointer */
		do{
			dp = process();
			*update = dp;
			cp->weight += dp->cumul;	/* add new stuff */
			dp->cumul = cp->weight;		/* set breakpoint */
			update = &(dp->next);
		}while( readline(), InLine[0]!= '%' );
		++Classes;		/* count them */
		++cp;
		*update = NULL;
	}
	qsort( (char*)Class, Classes, sizeof( class ), clcomp);
}
/*
 * display is given a class name ( delimited by SLASH, not '\0' ),
 * and will (1) find its class descriptor, by calling lookup
 * (2) pick a definition  (3) output that definition, and
 * recursively display any definitions in it, and convert any escapes.
 * The variant tag after the SLASH is used to pick out the appropriate
 * variants. If that variant tag is '&', the tag 'deftag' is used, which
 * is the active variant of the containing activation.
 */
display(s,deftag)
char *s;
int deftag;
{
	register class *cp;
	register defn *dp;
	register char *p;
	class *lookup();
	int i,variant,incurly;
	register int c,writing;

	if( CompIn ){		/* input is compressed */
		cp = &Class[ atoi(s) ];		/* explicit class # */
	}else{
		cp = lookup(s);
		if( cp == NULL ) {		/* none found */
			printf("???");
			while( *s != SLASH ) putchar( *s++ );
			printf("???");
			return;
		}
	}
	c = index(s,SLASH)[1];		/* get variant tag */
	if( c != '&' ) deftag=c;	/* use given tag */
	p = index(cp->tags, deftag);		/* look it up */
	if(p == NULL ){
		variant = 0;
		printf("??/%c??", deftag );
		deftag = ' ';		/* for passing as deftag */
	}else variant = p - cp->tags;

	i = ROLL( cp->weight );
	dp = cp->list;
	while(dp->cumul <= i){	/* pick one based on cumul. weights */
		dp = dp->next;
	}

	incurly = 0;		/* not in curlies */
	writing = 1;		/* writing */
	p = dp->string;		/* this is the string */
	for(;;)switch(c = *p++){
		case '\0': return;
		case BSLASH:
			if(( c = *p++) == '\0' ) return; /* ?? */
			else if( c == '!' ){
				 if(writing)putchar('\n'); /* \! = newline */
			}else if( isalnum(c) ){	/* reference */
				if(writing)display(p-1,deftag);  /* recurse */
				while( *p!=SLASH )++p;
				p += 2;		/* skip variant tag */
			}else{
				if(writing) putchar(c);
			}
			break;
		case '{':
			if( !incurly ){
				incurly = 1;
				writing = (variant == 0 );
			}else{
				if( writing )putchar('{');
			}
			break;
		case VBAR:
			if( incurly ){
				writing = ( variant == incurly++ );
			}else{
				putchar(VBAR);
			}
			break;
		case '}':
			if( incurly ){
				writing = 1;
				incurly = 0;
			}else putchar('}');
			break;
		default:
			if( writing) putchar(c);
	}
}
class *
lookup( str )		/* delimited by SLASH, not '\0' */
char *str;
{
	int first, last, try, comp;
	int namecomp();

	first = 0;
	last = Classes-1;
	while( first <= last ){
		try = (first+last)>>1;
		comp = namecomp( str, Class[try].name );
		if( comp == 0 ) return &Class[try];
		if( comp > 0 ) first = try+1;
		else last = try-1;
	}
	return NULL;
}
int namecomp(a,b)	/* 'a' is delim. by SLASH, 'b' by NULL */
register char *a,*b;
{
	register int ac;
	for(;;){
		ac = *a++;
		if(ac == SLASH ) ac = '\0';
		if( ac < *b ) return -1;
		if( ac > *b++ ) return 1;
		if( ac == '\0' ) return 0;
	}
}
readline(){
	register char *p;
	do{
		if( fgets( InLine, MAXLINE, InFile ) == NULL ){
			InLine[0] = InLine[1] = '%';
			InLine[2] = '\0';	/* create EOF */
		}else if( (p=rindex( InLine, '\n'))!= NULL ) *p = '\0';
		p = InLine;
		while( (p = index( p, BSLASH )) != NULL ){
			if(p[1] == '*' ){
				*p = 0;	/* kill comment */
				break;
			}else ++p;
		}
	}while( InLine[0] == '\0' );
}

int clcomp(a,b)			
register class *a,*b;
{
	if( a==b) return 0;
	return strcmp( a->name, b->name );
}
char *save(str)
char *str;
{
	register char *p;
	p = my_alloc( (unsigned)((strlen(str)+1)*sizeof(char)));
	return strcpy(p,str);
}
/*
 * setup a class record. The 'class' line is in InLine.
 */
setup(cp)
register class *cp;
{
	char temp[100];
	register char *p,*p2;

	p = &InLine[1];		/* point after the % */
	while( *p == ' ' )++p;
	if( !isalnum(*p) ) goto baddec;
	p2 = temp;
	do *p2++ = *p++; while( isalnum(*p));
	*p2 = '\0';
	cp->weight = 0;		/* save the name of it */
	cp->name = save( temp );
	cp->list = NULL;
	cp->tags = NullTags;	/* by default */
	for(;;)switch(*p++){
	case '\0':
		return;	/* all done; */
	case ' ':
		break;		/* allowed those */
	case '{':		/* tags list */
		if( cp->tags  != NullTags ) goto baddec; /* already */
		p2 = temp;
		*p2++ = ' ';	/* provide null tag */
		while(*p!='}'){
			if( !isalnum(*p)) goto baddec;
			*p2++ = *p++;
		}
		++p;	/* junk rh brace */
		*p2 = 0;
		cp->tags = save(temp);
		break;
	default: goto baddec;
	}
  baddec:
	fprintf(stderr,"Bad class header: %s\n", InLine );
	exit(1);
}
/*
 * create a 'processed' version of the InLine, and return a pointer to
 * the definition. The 'cumul' field is temporarily used to hold the
 * assigned weight of the line.
 */
defn *process(){
	static char stuff[ MAXDEF ];
	register char *p,*pout;
	register defn *dp;
	register int c;

	dp = (defn *) my_alloc( (unsigned) sizeof( defn ));

	p = InLine;
	pout = stuff;
	if( *p == '(' ){		/* get a weight */
		while(*++p ==' ');	/* scan */
		if(!isdigit(*p)) goto badweight;
		c = *p - '0';
		while(isdigit(*++p)) c = c*10 + (*p - '0' );
		while( *p == ' ')++p;
		if( *p != ')') goto badweight;
		++p;
		dp->cumul = c;
	}else{
		dp->cumul = 1;	/* default weight */
	}
	while((c = *p++)!='\0')switch(c){
	case BSLASH:
		*pout++ = BSLASH;
		if( isalnum(*p)){	/* is a ref */
			do{ *pout++ = *p++;
			}while( isalnum(*p));
			*pout++ = SLASH;		/* delimit */
			if( *p == SLASH ){	/* get variant char */
				++p;
				if( !isalnum(*p)&& *p!= ' ' && *p!= '&' ){
					*pout++ = ' ';
				}else *pout++ = *p++;
			}else *pout++ = ' ';
		}else{
			*pout++ = *p;
			if( *p!= '\0'){
				 ++p;
			}else{
				--pout;	/* delete spurious '\' */
				readline();	/* get new line */
				p = InLine;	/* point to it */
			}
		}
		break;
	default:
		*pout++ = c;
	}
	*pout = '\0';
	dp->string = save( stuff );
	return dp;

  badweight:
	fprintf(stderr, "Bad line weight: %s\n", InLine );
	exit(1);
	/*NOTREACHED*/
}
#ifdef DUMP
dump(){
	register class *cp;
	register defn *dp;
	register int i;
	for( i=0, cp=Class; i<Classes; ++cp,++i ){
		if( CompIn)
			printf("%d, {%s} %d:\n",i ,cp->tags, cp->weight );
		else
			printf("%s, {%s} %d:\n", cp->name,cp->tags, cp->weight );
		for( dp = cp->list; dp!=NULL; dp=dp->next ){
			printf("(%d)%s\n",dp->cumul, dp->string );
		}
	}
}
#endif DUMP

char *my_alloc(n)
unsigned n;
{
/*	register char *p; */
	unsigned char *p;
	p = malloc( n );
	if( p==NULL ){
		fprintf(stderr, "Out Of Memory\n");
		exit(1);
	}
	return p;
}

/*
 * write the file to the standard output in compressed form, prepending
 * the MAGIC byte for identification.
 */
compress(){
	register class *cp;
	register int i;

	putchar( MAGIC );
	putw( Classes, stdout );	/* write the number of classes */
	putw( -Classes, stdout );	/* write this to make sure */

	if( !CompIn ){
		cp = lookup("MAIN/ ");		/* get main */
		if( cp == NULL ){
			fprintf(stderr, "MAIN undefined\n");
			exit(1);
		}
		CompMain = cp - Class;
	}
	putw( CompMain, stdout );
	cp = Class;
	i  = Classes;
	while(i--) comp1(cp++);
}
/*
 * write a 'class' record in compressed format
 */
comp1(cp)
register class *cp;
{
	register char *p;
	register defn *dp;
	register int n;

	putw( cp->weight, stdout );	/* write total weight */
	p = cp->tags;
	if( strcmp(p,NullTags) != 0 )	/* special case " " -> "" */
		fputs( p, stdout );		/* write tags */
	putchar(0);			/* delimiter */
	n = 0;
	dp = cp->list;
	while( dp!= NULL ){
		++n;		/* count the defs */
		dp = dp->next;
	}
	putw( n, stdout );	/* write the count of them */
	dp = cp->list;
	while( dp != NULL ){
		compdef(dp);
		dp = dp->next;	/* compress them */
	}
}
compdef(dp)
register defn *dp;
{
	register char *p;
	register int c;
	putw( dp-> cumul , stdout );	/* write its cumul weight */
	p = dp->string;
	while( (c = *p++) != '\0' ){
		if( c==BSLASH){
			if(!CompIn && isalnum(*p) ){	/* a ref */
				class *cp;
				cp = lookup(p);		/* find it */
				if( cp == NULL ){
					fprintf( stderr, "Undefined class: ");
					while( *p != SLASH ) fputc( *p++, stderr);
					fputc('\n', stderr );
					exit(1);
				}else{
					printf("%c%d", BSLASH, cp-Class );
					while( *p != SLASH ) ++p;
				}
			}else{		/* is escape seq */
				putchar( BSLASH );
				putchar( *p++ );
			}
		}else{
			putchar(c);
		}
	}
	putchar(0);
}

/*
 * readcomp reads the compressed format of the file into core.
 * the MAGIC char has been read already.
 */
readcomp(){
	register class *cp;
	register int i;
	Classes = getw( InFile );
	if( Classes <= 0 || getw( InFile ) + Classes != 0 )
		badfile();	/* format check */
	CompMain = getw( InFile );		/* read that next */
	Class = (class*) my_alloc( (unsigned)(Classes*sizeof(class)) );
	for( i= Classes, cp = Class; i--; ++cp)readcclass(cp);
}

readcclass(cp)
register class *cp;
{
	register int n;
	register defn *dp;
	defn **dput;

	char store[MAXDEF];	/* for tags */
	cp->weight = getw( InFile );
	instring(store,MAXDEF);
	cp->tags = ( store[0] == '\0' )? NullTags: save( store );
	n = getw( InFile );
	if( n<=0 ) badfile();
	dput = &(cp->list);	/* link on here */
	while(n--){
		dp = (defn *)my_alloc( (unsigned) sizeof( defn));
		*dput = dp;
		dp->cumul = getw( InFile );
		instring(store, MAXDEF );
		dp->string = save( store );
		dput = &(dp->next);
	}
	*dput = NULL;		/* last one */
}

instring( where, how_many )
register char *where;
register int how_many;
{
	register int c;
	do{
		c = getc( InFile );
		if( c == EOF ) badfile();
		*where++ = c;
		if( c== '\0' ) return;
	}while(--how_many);
	badfile();
}
badfile(){
	fprintf(stderr,"Bad file format\n");
	exit(1);
}

#ifndef unix

putw (word, stream)
int word;
FILE *stream;
{
	fwrite ((char *) &word, sizeof(int), 1, stream);
	return (0);	/* we don't use it */
}

getw (stream)
FILE *stream;
{
	int word;

	fread ((char *) &word, sizeof(int), 1, stream);
	return (word);
}

#endif
