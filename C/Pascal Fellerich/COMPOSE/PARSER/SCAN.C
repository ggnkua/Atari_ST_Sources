/*==========================================================================*/
/* SCAN.C
 * ======
 *
 * universal scanner
 *
 * - provides the central function 'get_symbol()' to the parser
 *
 *
 * Author: Pascal Fellerich
 *
 * rev 1.0	08-may-1996	Creation, based on SCANNER.C from the OSCAR project
 *
 */
/*==========================================================================*/


#include "scanner.h"


/* === extended ctype: ============= */
/* for identifiers which are := isxalpha [{isxalnum}] */

#define isxalpha(x)		(isalpha(x) || (x)==USCORE || (x)=='$')
#define isxalnum(x)		(isalnum(x) || (x)==USCORE || (x)=='$')


/* to enable continuous read via get_symbol()
 *		when NEWLINE is encountered, the next line is read.
 *		when all lines are read, EOS (End Of Stream) is returned.
 */
#define CONTINUOUS_SCANNER_READ



/*==========================================================================*/
/*
 * DATA TABLES FOR THE SCANNER
 *
 * Format:
 *  name: 	the keyword template. If the first char is an alpha char,
 *			the keyword can be abbreviated. Mandatory chars must be uppercase,
 *			optional chars must be lowercase.
 *  symbol:	The symbol code as defined in the symbol enumeration.
 */
/*==========================================================================*/

/* terminal symbols.
 *  - if 1st char isascii, then it's a keyword
 *	- keywords may not be used as an identifier
 *	- keywords may be abbreviated (lowercase portions)
 */
Keyword keywords[] = {
	"(",		S_LPAREN,			/* SEPARATORS */
	")",		S_RPAREN,
	"{",		S_LBRACE,
	"}",		S_RBRACE,
	"[",		S_LBRACKET,
	"]",		S_RBRACKET,
	",",		S_COMMA,
	":",		S_COLON,
	";",		S_SEMICOLON,
	".",		S_DOT,
	"..",		S_DOUBLEDOT,

	"**",		OP_POWER,			/* OPERATORS */
	"*",		OP_MUL,
	"/",		OP_DIV,
	"+",		OP_PLUS,
	"-",		OP_MINUS,
	"%",		OP_MODULO,

	"!",		OP_NOT,
	"==",		OP_EQ,
	"!=",		OP_NE,
	">",		OP_GT,
	">=",		OP_GE,
	"<",		OP_LT,
	"<=",		OP_LE,
	"&&",		OP_AND,
	"||",		OP_OR,
	"^",		OP_XOR,
	"=",		OP_ASSIGN,

	"END",				K_END,			/* KEYWORDS */
	"KBTAB_Normal",		K_KBTAB_NORMAL,
	"KBTAB_Shift",		K_KBTAB_SHIFT,
	"KBTAB_CApslock",	K_KBTAB_CAPSLOCK,
	"KBTAB_COmpose",	K_KBTAB_COMPOSE,
	"NAME",				K_NAME,
	"SWITCHes",			K_SWITCHES,
	"COMPose",			K_COMPOSE,
	"DEADkey",			K_DEADKEY,
	"EXTKey",			K_EXTKEY,
	"ALT_Nnn",			K_ALT_NNN,
	"TABLE_APPLIES_TO",	K_TABLE_APPLIES_TO,
	"ON",				K_ON,
	"OFf",				K_OFF,
	"DEC_Mode",			K_DEC_MODE,
	"MULTichar",		K_MULTICHAR,
	"AUTOmulti",		K_AUTOMULTI,
	"NOAUtomulti",		K_NOAUTOMULTI,
	"ORDER",			K_ORDER,
	"NOORDER",			K_NOORDER,
	"NOTHing",			K_NOTHING,
	"KEYBoard",			K_KEYBOARD,
	"BOTH",				K_BOTH,

	"",			0
};


/*==========================================================================*/
/* GLOBAL I/O VARIABLES														*/
/*==========================================================================*/

Token	*symbol;						/* statically used */

long	cline;							/* current line number */
char	line[MAXLINE_LEN+1];			/* input line */
char	*lineptr;						/* read pointer */
char	*lastptr;						/* backtrack pointer */

BOOL	case_sensitive	= FALSE;		/* control flag */

/* BOOL	collapse		= TRUE;*/			/* ...for ltrim(); */


/*==========================================================================*/
/* internal prototypes are defined here: 													*/
/*==========================================================================*/

/*
 * 'read' functions - INTERNAL ONLY!!
 *
 * param:	string pointer
 *
 * return:	length of matching string (if any)
 *
 * global:	no global variables are modified
 */
size_t read_decimal(char *ptr);
size_t read_hexadecimal(char *ptr);
size_t read_octal(char *ptr);
size_t read_binary(char *ptr);
size_t read_signed_integer(char *ptr);
size_t read_number(char *ptr, int *type);


/*==========================================================================*/
/* MISCELLANEOUS FUNCTIONS													*/
/*==========================================================================*/

/* cmp_keyword:		compare the strings of two keyword structs,
 *					using stricmp()
 *					FOR USE WITH QSORT().
 */
int cmp_keyword(const Keyword *a, const Keyword *b)
{
	return stricmp( a->name, b->name );
}


/*
 * scanner_init:	this initializes the scanner table
 *
 * param:	none
 *
 * return:	TRUE on success.
 *
 */
BOOL scanner_init(void)
{
	Keyword	*rover, *new_table;
	size_t	entries;

	new_table=keywords;

	lineptr = line;

	if (symbol==NULL)
		symbol = tk_create(MAXLINE_LEN);	/* create new sym with max. size */

	if (new_table==NULL) return FALSE;

	/* first count the number of entries in that table */
	for (rover=new_table, entries=0;
					rover->sym!=NO_TOKEN; rover++, entries++);

	/* make sure the "NO_TOKEN" entry has a null string */
	if (rover->name[0]!=NUL)
		internal_error("bad scanner table format");

	/* quicksort the table */
	qsort(new_table, entries+1L, sizeof(Keyword), cmp_keyword);

	/* final check, then misuse the first entry: */
	if (new_table->sym!=NO_TOKEN)
		internal_error("scanner table init failed");

	new_table->sym = (int)entries;
	return TRUE;
}


/* 
 * scanner_exit:	cleanup scanner variables. To be called after last use.
 *		Also checks if all tokens are released!
 *
 * param:	none
 *
 * return:	none
 */
void scanner_exit(void)
{
	tk_dispose(symbol);				/* last token to be released */
	
	if (tk_disposed!=tk_created)
		internal_error("Not all tokens were released");
}



/*==========================================================================*/
/* MAIN SCANNER FUNCTIONS													*/
/*==========================================================================*/

/*
 * get_symbol: reads the next symbol which is either
 *				- a terminal symbol contained in the list
 *				- a constant
 *				- an identifier
 *				- NEWLINE token
 *				- EOS token (when end of file is encountered)
 *
 * param:	none
 *
 * return:	TRUE on success
 *
 * global:	symbol, lineptr, cline are updated
 *
 */
BOOL get_symbol(void)
{
	char	*p;

	lastptr	= lineptr;				/* last read position for unget_symbol */
	ltrim();						/* skip whitespaces */

	tk_zero(symbol);				/* zero out the current symbol */

	if (*lineptr==NUL)				/* check for NEWLINE */
	{
		symbol->token = NEWLINE;
#ifdef CONTINUOUS_SCANNER_READ
		if (newline()==FALSE)		/* advance to next line */
			symbol->token = EOS;	/* on EOS return corresponding symbol */
#endif
		return TRUE;
	};

	if (get_token(keywords))		return TRUE;
	if (get_constant())				return TRUE;
	if (get_identifier())			return TRUE;

	/* nothing found; then return NO_TOKEN and the offending input text */
	/* symbol->token = NO_TOKEN; */
	strncpy(symbol->name, lineptr, MAXNAME_LEN);
	for (p=symbol->name; *p && !isspace(*p); ) p++; *p=NUL;

	return FALSE;
}



/*
 * unget_symbol:	return last read symbol (by get_symbol) to input string
 *
 * param:	none
 *
 * return:	TRUE if retore was successful
 *
 * global:	lineptr is restored to previous position
 *			lastptr is cleared
 */
BOOL unget_symbol(void)
{
	if (lastptr!=NULL && lastptr<lineptr)
	{
		lineptr=lastptr; lastptr=NULL;
		return TRUE;
	}
	else return FALSE;
}



/*==========================================================================*/
/* MID-LEVEL SCANNER FUNCTIONS												*/
/*==========================================================================*/

/*
 * get_token:	isolate a terminal symbol from the input string.
 *
 *		To speed up the search, get_token() uses a binary search to find
 *		the first match. Since for identifier-type keywords abbreviations
 *		are allowed and for other types a 'maximum match' strategy is used,
 *		the binsearch method must be abandoned when the first partial match
 *		is found. Then, beginning from the mid point, the low and high ptrs
 *		are set to 'enclose' all keywords which fit the initial partial
 *		match - usually only a few elements. Between these boundaries, a
 *		linear search is used to determine the correct element.
 *
 *
 * param:	read pointer
 *			a list with possible keywords.
 *
 * return:	total length of identifier or 0L on error
 *
 * global:	'symbol' is overwritten on success (must be clean beforehand!)
 *			lineptr is incremented.
 *
 */
BOOL get_token(Keyword *list)
{
	long	patlen=0, i=0;
	int		low, mid, high, found, upper;
	size_t	len=0L;
	char	*template,*pattern;

	if (*lineptr==NUL) return FALSE;		/* check for empty line */

	/* first determine alphanumeric pattern length */
	pattern = lineptr;						/* current line pointer */
	while (isxalnum(pattern[patlen])) patlen++;

	/* check if list is properly initialized */
	if (list->name[0]!=NUL) {
		internal_error("non-initialized keyword list used");
		/* scanner_init(list); */
	}

	/* then initiate binary search algorithm */
	low = 1;								/* array[1] ... array[n] */
	upper = list[0].sym;
	high = upper;

	while (low <= high) {
		mid = (low+high)/2;
		template = list[mid].name;			/* template string from list */
		if (isxalnum(pattern[0]))			/* abbreviations allowed */
		{
			/* given string data must match with template up to pattern length */
			found = strnicmp(pattern,template,patlen);
			if (found==0)					/* pattern matched */
			{
				if (template[patlen] && isupper(template[patlen]))
				{							/* unsufficient match */
					low=mid-1;
					while (low>0 && 
						strnicmp(pattern,list[low].name,patlen)==0) low--;
					high=mid+1;
					while (high<upper && 
						strnicmp(pattern,list[high].name,patlen)==0) high++;
											/* locate best match */
					for (mid=low+1; mid<high; mid++)
					{
						template = list[mid].name;
						if (!template[patlen] || islower(template[patlen]))
							goto matchit1;
					}
					return FALSE;			/* no valid match. */
				}
			}
			matchit1: len=patlen;
		}
		else	/* non-identifier type terminal symbol -> full match required */
		{
			if (pattern[0]<template[0])	found = -1;
			else if (pattern[0]>template[0]) found = 1;
			else {
				found=0;
				low=mid-1;
				while (low>0 && pattern[0]==list[low].name[0]) low--;
				high=mid+1;
				while (high<upper && pattern[0]==list[high].name[0]) high++;
				for (mid=high-1; mid>low; mid--)
				{
					template = list[mid].name;
					i = strlen(template);
					if (strnicmp(pattern,template,i)==0)
						goto matchit2;
				}
				return FALSE;
			}
			matchit2: len=i;
		}

		/* divide and conquer the list: */
		if (found < 0)						/* take lower half */
			high = mid - 1;
		else if (found > 0)
			low  = mid + 1;					/* upper half... */
		else
		{									/* object located! */
			strncpy(symbol->name, list[mid].name, MAXNAME_LEN);
			symbol->token = list[mid].sym;
			lineptr += len;
			return TRUE;
		};

	}
	return FALSE;
}



/*
 * get_constant:	expect a constant value
 *
 * param:	none
 *
 * return:	T or F
 *
 * global:	'symbol' is overwritten on success (must be clean beforehand)
 *			lineptr is incremented.	
 */
BOOL get_constant(void)
{
	size_t	len=0L;
	int		i, type=0;
	char	*ptr, *write, quote;

	ptr = lineptr; i=1;

	switch (toupper(*ptr))
	{
	case '.':	case '+':	case '-':
	case '0':	case '1':	case '2':	case '3':	case '4':
	case '5':	case '6':	case '7':	case '8':	case '9':
		len = read_number(ptr, &type);		/* the only possibility! */
		if (len==0L) type = 0;				/* signal failure */
		break;

	case '%':				/* binary constant: %0100100011111 */
		len = read_binary(ptr+i);
		if (len!=0L) {
			type = BINCONST;
			strncpy(symbol->name, ptr+i, len);
			len+=i;
		}
		break;

	case '$':				/* hexadecimal constant */
		len = read_hexadecimal(ptr+i);
		if (len!=0L) {
			type = HEXCONST;
			strncpy(symbol->name, ptr+i, len);
			len+=i;
		}
		break;

	case QUOTE:				/* 'string constant' */
	case DQUOTE:			/* "string constant" */
		quote = *ptr;				/* memorize quote character */
		write = symbol->name;

		while (TRUE)
		{
			while (ptr[i] && ptr[i]!=quote) *write++=ptr[i++];

			if (ptr[i]==quote && ptr[i+1]==quote) {				/* '' */
				*write++=quote;
				i+=2;
			}
			else break;										  	/* EOL */
		}
		len += ( ptr[i]==NUL ? i : (i+1) );		/* end quote included? */
		type = STRINGCONST;
		*write++=NUL;							/* NUL terminator */
		break;
	};

	if (type) {									/* success */
		/* sub = MIN(len,MAXNAME_LEN);
		   strncpy(symbol->name, ptr, sub);
		   symbol->name[sub]=NUL; */
		symbol->token = type;
		lineptr += len;
		return TRUE;
	}
	else return FALSE;
}



/*
 * get_identifier: reads an identifier from the input line.
 * = alpha {alnum|underscore}
 *
 * param:	none.
 *
 * return:	T or F
 *
 * global:	'symbol' is overwritten on success	
 *			lineptr is incremented
 */
BOOL get_identifier(void)
{
	size_t	len=0L, len2;
	char	*ptr;

	ptr = lineptr;
	if (isxalpha(ptr[len])) {					/* xalpha_char */
		len++;
		while (isxalnum(ptr[len])) len++;		/* {xalnum_char} */
	} else return FALSE;

	len2 = MIN(len, MAXNAME_LEN);
	strncpy(symbol->name, ptr, len2); symbol->name[len2]=NUL;
	if (!case_sensitive) strupr(symbol->name);
	symbol->token = IDENTIFIER;
	lineptr += len;
	return TRUE;
}



/*==========================================================================*/
/* BASIC READ FUNCTIONS														*/
/*==========================================================================*/

/*
 * read a decimal constant and return length of matching string segment
 * = {digit}
 */
size_t read_decimal(char *ptr)
{
	size_t len;
	for (len=0L; isdigit(*ptr); ptr++) len++;
	return len;
}


/*
 * read a hex constant and return length of matching string segment
 * = {hexdigit}
 */
size_t read_hexadecimal(char *ptr)
{
	size_t len;
	for (len=0L; isxdigit(*ptr); ptr++) len++;
	return len;
}


/*
 * read an octal constant and return length of matching string segment
 * = {octaldigit}
 */
size_t read_octal(char *ptr)
{
	size_t len;
	for (len=0L; '0'<=*ptr && *ptr<='7'; ptr++) len++;
	return len;
}


/*
 * read a binary constant and return length of matching string segment
 */
size_t read_binary(char *ptr)
{
	size_t len;
	for (len=0L; '0'<=*ptr && *ptr<='1'; ptr++) len++;
	return len;
}


/*
 * read a signed integer number:  [ '+' | '-' ] digit {digit}
 *						...and return length of matching string segment
 */
size_t read_signed_integer(char *ptr)
{
	size_t sublen, len=0;

	if (*ptr=='+' || *ptr=='-') {			/*   ['+'|'-']   	*/
		len++; ptr++;
	};
	sublen = read_decimal(ptr);				/*   digit {digit}	*/
	if (sublen==0L) return 0L;
	else 			return len+sublen;
}


/*
 * read a number: read a number and return length of matching segment
 *
 *	param:	char *p	- pointer to string to be analysed
 *			int *type - pointer to int in which the final type is written
 *
 *	return:	length of matching string segment.
 *
 * --------- implemented syntax is: ------------------------------
 *
 *	real	:= ['+'|'-'] ip '.' [fp] ['E' integer]		(1.1)
 *			 = ['+'|'-'] ip 'E' integer					(1.2)
 *			 = ['+'|'-'] '.' fp ['E' integer]			(1.3)
 *	
 *	integer := ['+'|'-'] ip								(2)
 *	
 *	ip		:= digit {digit}							(3)
 *	
 *	fp		:= digit {digit}							(4)
 *
 * ----------------------------------------------------------------	
 */

#define Is_EE(x)	((x)=='E' || (x)=='e')

size_t read_number(char *p, int *type)
{
	size_t	len = 0,
			sub;

	*type = REALCONST;

	if (*p=='+' || *p=='-')	len++;			/*		['+'|'-']		*/
	
	if (isdigit(p[len]))					/* case 1.1, 1.2 or 2 	*/
	{
		len += read_decimal(&p[len]);		/*		ip				*/
		if (p[len]=='.')					/* case 1.1				*/
		{
			sub = read_decimal(&p[++len]);	/*		[fp]			*/
			if (sub==0L)
			{
				if (isalpha(p[len]))
				{					/* special case: (1.) is legal */
					*type = INTEGERCONST; return --len;
				}
				else return len;
			};
			len += sub;
			if (Is_EE(p[len]))				/*		['E' integer ]	*/
			{
				sub = read_signed_integer(&p[++len]);
				if (sub==0L) return 0L;
				len += sub;
			};
		}
		else if (Is_EE(p[len]))				/* case 1.2				*/
		{
			sub = read_signed_integer(&p[++len]);
			if (sub==0L) return 0L;			/* 		'E' integer		*/
			len += sub;
		}
		else								/* case 2				*/
			*type = INTEGERCONST;
		return len;
	}
	else if (p[len]=='.')					/* case 1.3 */
	{
		sub = read_decimal(&p[++len]);
		if (sub==0L) return 0L;				/*		fp				*/
		len += sub;
		if (Is_EE(p[len]))					/*		['E' integer ]	*/
		{
			sub = read_signed_integer(&p[++len]);
			if (sub==0L) return 0L;
			len += sub;
		};
		return len;
	}
	else return 0L;							/* illegal number syntax */
}


/*==========================================================================*/
/* DATA INPUT FUNCTIONS														*/
/*==========================================================================*/

/*
 * newline:	get the next line and update internal variables
 *
 * param:	none
 *
 * return:	TRUE if read was successful; FALSE if EOS reached.
 *
 * call:	ReadLine (external function)
 */
BOOL newline(void)
{
	int	nlines;

	lineptr = line;					/* line pointer */
	lastptr = line;					/* previous line ptr for unget_symbol */
	*lineptr = NUL;

	nlines = ReadLine(line, MAXLINE_LEN);
	if (nlines>0)
	{
		cline += nlines;			/* how many lines were read */
		return TRUE;
	}
	else return FALSE;
}



/*
 * flushline:	clear the current line
 *
 * Param:	none
 *
 * Return:	TRUE on success
 *
 * Global:	lineptr, lastptr are updated. 
 *			get_symbol() is called
 *
 */
BOOL flushline(void)
{
	*lineptr=NUL;	lastptr=NULL;

#ifdef CONTINUOUS_SCANNER_READ
	return get_symbol();				/* read the NEWLINE symbol! */
#else
	return TRUE;
#endif

}



/*
 * ltrim:	advance the read pointer 'lineptr' to the next symbol.
 *			i.e. skip all whitespaces.
 *
 * param:	none
 *
 * return:	void
 */
void ltrim(void)
{
	/* skip all leading whitespaces */
	while (*lineptr && isspace(*lineptr)) lineptr++; 						
}



/* for VMS only! */
#ifdef __VMS__

/*
 * case insensitive strncmp();
 */
int strnicmp(const char *a, const char *b, size_t n)
{
	while (n>0L)
	{
		if (*a==NUL && *b==NUL) return 0;
		if (*a==NUL && *b!=NUL) return -1;
		if (*a!=NUL && *b==NUL) return 1;
		if (toupper(*a)>toupper(*b)) return 1;
		if (toupper(*a)<toupper(*b)) return -1;
		a++; b++; n--;
	}
	return 0;
}

/*
 * case insensitive strcmp();
 */
int stricmp(const char *a, const char *b)
{
	while (TRUE)
	{
		if (*a==NUL && *b==NUL) return 0;
		if (*a==NUL && *b!=NUL) return -1;
		if (*a!=NUL && *b==NUL) return 1;
		if (toupper(*a)>toupper(*b)) return 1;
		if (toupper(*a)<toupper(*b)) return -1;
		a++; b++;
	}
	return 0;
}


/*
 * convert a string to into UPPERCASE letters
 */
char *strupr(char *s)
{
	char	*tmp;

	for (tmp=s; *tmp!=NUL; )
	{
		*tmp=toupper(*tmp);
		tmp++;
	}
	return tmp;
}

#endif

/*==========================================================================*/
/* EOF																		*/
/*==========================================================================*/
