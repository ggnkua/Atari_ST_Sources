#include <stdio.h>
#include <osbind.h>

/* Numbers of things */

#define XSTKDPTH	20	/* depth of expression stack */
#define HASHSIZE	500	/* should find a good prime number for this */

/* Constants */

#define GLOBAL		0	/* global symbol type */
#define LOCAL		1	/* local symbol type */
#define TEMP		2	/* Temporary symbol type */
#define SECTION		3	/* Section name symbol type */

#define UNDEFINED	0	/* Symbol undefined */
#define RELOC		1	/* Symbol relocatable */
#define ABSOLUTE	2	/* Symbol absolute */
#define CHANGABLE	3	/* Symbol defined by SET */

/* assembler errors */

/* Structures */

struct opr_stk {
	int	os_oper;	/* operation */
	int	os_type;	/* type of data, 0 = constant, 1 = sym */
	long	os_value;	/* constant value */
	struct sym_tbl	*os_sym;	/* pointer to symbol */
};

struct sym_tbl {
	char	st_type;	/* 0 = Global, 1 = Local,
				 2 = temporary, 3 = section */
	char	st_status;	/* 0 = undefined, 1 = absolute,
				 2 = relocatable, 3 = changeable */
	char	*st_name;	/* name of symbol */
	struct sym_tbl	*st_section;	/* section label defined within */
	struct usd_lst	*st_used;	/* start of cross reference */
	struct sym_tbl	*st_next;	/* used when hashed to same place */
};

struct usd_lst {
	long	usd_line;	/* line where used */
	int	usd_how;	/* 0 = read, 1 = written, 2 = defined */
	struct usd_lst	*usd_next;	/* next place used */
};

/* Global variables */

struct opr_stk	expr_stack[XSTKDPTH];	/* expression stack */
int	expr_index;			/* expression stack pointer */

int	n_symbols;			/* number of symbols */
struct sym_tbl	*hash_tbl[HASHSIZE];

union	{
	long		num;		/* current number */
	struct sym_tbl	*sym;		/* current symbol */
} cur,prev;

int	cur_nsym;		/* if true, current number is a sym */
int	cur_nrel;		/* which section reloc number is defined in.
					zero for absolute */
int	cur_nflg;		/* if true, current number is valid */
int	prev_nsym;		/* same for previous number */
int	prev_nrel;
int	prev_nflg;

char	input_f[100],output_f[100],list_f[100];	/* file names */
FILE	*infp,*outfp,*lstfp;			/* file pointers */

int	lflag = 0;		/* listing flag */
int	oflag = 1;		/* object flag */

main(argc,argv)
int	argc;
char	*argv[];
{

	parse_com(argc,argv);	/* parse command line */

}

parse_com(argc,argv)
int	argc;
char	*argv[];
{
	char	*cp,*cp1;
	int	which_file = 0;

	for( i = 1; i < argc; i++ ) {
	    cp = argv[i];
	    if( *cp == '-' ) {
		switch( *++cp ) {
		default:
		    printf("-%c unrecognized switch\n",*cp);
		case '?':
		    printf("Usage: as65 [-?] [-l[<list_file>]] <input_file> <output_file>\n");
		    exit(0);
		case 'l':
		    if( *++cp ) {
		    	strcpy(list_f,cp);
		    }
		    lflag++;
		    break;
		case 'o':
		    oflag = 0;
		    break;
		}
	    }
	    else if( which_file == 0 ) {
		strcpy(input_f,cp);
		for( cp = input_f; *cp && *cp != '.'; cp++);
		if( !*cp )
		    strcpy(cp,".asm");
		which_file++;
	    }
	    else if( which_file == 1 ) {
		strcpy(output_f,cp);
		for( cp = output_f; *cp && *cp != '.'; cp++);
		if( !*cp )
		    strcpy(cp,".obj");
		which_file++;
		oflag = 1;
	    }
	    else {
		printf("Huh?  What's a '%s'?\n",cp);
		fclose(infp);
		exit(1);
	    }
	}
	if( which_file == 0 ) {
	    printf("Usage: as65 [-?][-l[<list_file>]] <input_file> [<output_file>]\n");
	    exit(0);
	}
	else if( which_file == 1 && oflag ) {
	    strcpy(output_f,input_f);
	    for( cp = output_f; *cp != '.'; cp++);
	    strcpy(cp,".rel");
	} 
	if( lflag && !*list_f ) {
	    strcpy(list_f,input_f);
	    for( cp = list_f; *cp != '.'; cp++);
	    strcpy(cp,".lst");
	}
	if( (infp = fopen(input_f,"r")) == NULL ) {
	    printf("Cannot open '%s' for input\n",input_f);
	    exit(1);
	}
	if( oflag && (outfp = fopen(output_f,"w")) == NULL) {
	    printf("Cannot open '%s' for output.\n",output_f);
	    fclose(infp);
	    exit(1);
	}
	if( lflag && (lstfp = fopen(list_f,"w")) == NULL ) {
	    printf("Cannot open '%s' for list file.\n,list_f);
	    fclose(infp);
	    if( outfp )
		fclose(outfp);
	    exit(1);
	}
}

/*
 *	Compute reduces a stacked expression as far as possible
 *	Should be called every time the 'current number' is changed
 *	Operators are:
 *	  0 = null operation
 *	  1 = add
 *	  2 = subtract
 *	  3 = multiply
 *	  4 = divide
 *	  5 = mod
 *	  6 = not
 *	  7 = XOR
 *	  8 = or
 *	  9 = and
 *	 10 = one's complement
 *	 11 = shift left
 *	 12 = shift right
 *	 13 = high byte
 *	 14 = low byte
 */
compute()
{

	while( cur_nflg ) {
	    switch( operator & 0xf ) {
	    case 0:		/* Null command */
		prev.num = cur.num;
		prev_nsym = cur_nsym;
		prev_nrel = cur_nrel;
		prev_nflg = cur_nflg;
		cur_nflg = 0;		/* invalidate current number */
		break;
	    case 1:		/* add */
		if( prev_nflg ) {
		    /* both relocatable or one is a symbol */
		    if( (prev_nrel && cur_nrel) ||
		        prev_nsym || cur_nsym ) {
		    	stack();
		    }
		    else {
		    	prev.num += cur.num;
		    	prev_nrel |= cur_nrel;
		    	cur_nflg = 0;
		    }
		else {
		    prev.num = cur.num;
		    prev_nsym = cur_nsym;
		    prev_nrel = cur_nrel;
		    prev_nflg = cur_nflg;
		    cur_nflg = 0;		/* invalidate current number */
		}
		operator = 0;
		break;
	    case 2:		/* subtract */
		if( prev_nsym || cur_nsym ) {
		    stack();	/* stack if symbols */
		}
		else if( prev_nrel == cur_nrel ) {
		    prev.num -= cur.num;
		    prev_nrel = 0;	/* difference of 2 relocs is absolute */
		    cur_nflg = 0;
		}
		else if( prev_nrel && !cur_nrel ) {
		    prev.num -= cur.num;
		    cur_nflg = 0;
		}
		else {
		    stack();
		}
		operator = 0;
		break;
	    case 3:		/* multiply */
		if( prev_nrel || cur_nrel )
	    case 4:		/* divide */
	    case 5:		/* mod */
	    case 6:		/* not */
	    case 7:		/* XOR */
	    case 8:		/* or */
	    case 9:		/* and */
	    case 10:		/* one's complement */
	    case 11:		/* shift left */
	    case 12:		/* shift right */
	    case 13:		/* high byte */
	    case 14:		/* low byte */
	
/*
 *	Hash table stuff
 *
 *	Find hashed value for a string
 */
hash_it(s)
char	*s;
{
	int	hash_val = 0;

	while( *s ) {
	    hash_val <<= 1;		/* 15 bit circular rotate */
	    if( hash_val < 0 )
		hash_val++;
	    hash_val ^= *s | (*s << 8);	/* xor to provide crc */
	}
	return( hash_val % HASHSIZE );	/* limit to hash table size */
}

/*
 *	Install a symbol
 */

install(s)
char	*s;
{
	int	hash;
	struct sym_tbl	*symp;

	hash = hash_it(s);
	symp = hash_tbl[hash];
	while( symp )
	    if( strcmp(s,symp->st_name) == 0 )
		break;			/* symbol already here */
	    else
		symp = symp->st_next;	/* go to next symbol in bucket */
	if( symp )
	    return(-1);	/* error */

	symp = malloc(sizeof(struct sym_tbl) + strlen(s) + 1));
	symp->st_next = hash_tbl[hash];		/* link to first sym in bucket */
	hash_tbl[hash] = symp;			/* link to hash table */
	return(0);
}

/*
 *	lookup symbol--returns pointer or null if not found
 */
struct sym_tbl *
lookup(s)
char	*s;
{
	int	hash;
	struct sym_tbl	*symp;

	hash = hash_it(s);
	symp = hash_tbl[hash];
	while( symp )
	    if( strcmp(s,symp->st_name) == 0 )
		break;			/* symbol already here */
	    else
		symp = symp->st_next;	/* go to next symbol in bucket */
	return( symp );
}
