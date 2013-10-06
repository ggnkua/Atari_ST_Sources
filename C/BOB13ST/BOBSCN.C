/* bobscn.c - a lexical scanner */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

/*
	1.3ST	12/25/91	Ported to Atari ST and Mark Williams C
						Removed ANSI void * declarations
*/

#include <setjmp.h>
#include "bob.h"

/* useful definitions */
#define LSIZE	200

/* keyword table */
static struct { char *kt_keyword; int kt_token; } ktab[] = 
{
{ "class",		T_CLASS		},
{ "static",		T_STATIC	},
{ "if",			T_IF		},
{ "else",		T_ELSE		},
{ "while",		T_WHILE		},
{ "return",		T_RETURN	},
{ "for",		T_FOR		},
{ "break",		T_BREAK		},
{ "continue", 	T_CONTINUE	},
{ "do",			T_DO		},
{ "new",		T_NEW		},
{ "nil",		T_NIL		},
{ NULL,			0			}
};

/* token name table */
static char *t_names[] = 
{
	"<string>", "<identifier>", "<number>", "class", "static",
	"if", "else", "while", "return", "for", "break", "continue",
	"do", "new", "nil", "<=", "==", "!=", ">=", "<<", ">>", "&&",
	"||", "++", "--", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=",
	"<<=", ">>=", "::", "->"
};

/* global variables */
int t_value;			/* numeric value */
char t_token[TKNSIZE+1];/* token string */

/* local variables */
static int (*getcf)();	/* getc function */
static char *getcd;		/* getc data */
static int savetkn;		/* look ahead token */
static int savech;		/* look ahead character */
static int lastch;		/* last input character */
static char line[LSIZE];/* last input line */
static char *lptr;		/* line pointer */
static int lnum;		/* line number */

/* init_scanner - initialize the scanner */
init_scanner(gf,gd)
int (*gf)(); 
char *gd;
{
	getcf = gf; getcd = gd; 	/* remember the getc function and data */

	lptr = line; *lptr = '\0'; 	/* setup the line buffer */
	lnum = 0;

	savetkn = T_NOTOKEN; 		/* no lookahead yet */
	savech = '\0';

	lastch = '\0';				/* no last character */
}

/* token - get the next token */
int token()
{
	int tkn;

	if ((tkn = savetkn) != T_NOTOKEN)
		savetkn = T_NOTOKEN;
	else
		tkn = rtoken();
	return (tkn);
}

/* stoken - save a token */
stoken(tkn)
int tkn;
{
	savetkn = tkn;
}

/* tkn_name - get the name of a token */
char *tkn_name(tkn)
int tkn;
{
	static char tname[2];
	
	if (tkn == T_EOF)
		return ("<eof>");
	else 
		if (tkn >= _TMIN && tkn <= _TMAX)
			return (t_names[tkn-_TMIN]);
	tname[0] = tkn;
	tname[1] = '\0';
	return (tname);
}

/* rtoken - read the next token */
static int rtoken()
{
    int ch,ch2;

    for (;;)		 /* check the next character */
    {
		switch (ch = skipspaces()) 
		{
		case EOF:	
			return (T_EOF);
		case '"':	
			return (getstring());
		case '\'':	
			return (getcharacter());
		case '<':	
			switch (ch = getch()) 
			{
			case '=':
				return (T_LE);
			case '<':
				if ((ch = getch()) == '=')
					return (T_SHLEQ);
				savech = ch;
				return (T_SHL);
			default:
				savech = ch;
				return ('<');
			}
		case '=':	
			if ((ch = getch()) == '=')
				return (T_EQ);
			savech = ch;
			return ('=');
		case '!':	
			if ((ch = getch()) == '=')
				return (T_NE);
			savech = ch;
			return ('!');
		case '>':	
			switch (ch = getch()) 
			{
			case '=':
				return (T_GE);
			case '>':
				if ((ch = getch()) == '=')
					return (T_SHREQ);
				savech = ch;
				return (T_SHR);
			default:
				savech = ch;
				return ('>');
			}
		case '&':	
			switch (ch = getch()) 
			{
			case '&':
				return (T_AND);
			case '=':
				return (T_ANDEQ);
			default:
				savech = ch;
				return ('&');
			}
		case '|':	
			switch (ch = getch()) 
			{
			case '|':
				return (T_AND);
			case '=':
				return (T_OREQ);
			default:
				savech = ch;
				return ('|');
			}
		case '^':	
			if ((ch = getch()) == '=')
				return (T_XOREQ);
			savech = ch;
			return ('^');
		case '+':	
			switch (ch = getch()) 
			{
			case '+':
				return (T_INC);
			case '=':
				return (T_ADDEQ);
			default:
				savech = ch;
				return ('+');
			}
		case '-':	
			switch (ch = getch()) 
			{
			case '-':
				return (T_DEC);
			case '=':
				return (T_SUBEQ);
			case '>':
				return (T_MEMREF);
			default:
				savech = ch;
				return ('-');
			}
		case '*':	
			if ((ch = getch()) == '=')
				return (T_MULEQ);
			savech = ch;
			return ('*');
		case '/':	
			switch (ch = getch()) 
			{
			case '=':
				return (T_DIVEQ);
			case '/':
				while ((ch = getch()) != EOF)
					if (ch == '\n')
						break;
				break;
			case '*':
				ch = ch2 = EOF;
				for (; (ch2 = getch()) != EOF; ch = ch2)
					if (ch == '*' && ch2 == '/')
						break;
				break;
			default:
				savech = ch;
				return ('/');
			}
			break;
		case ':':	
			if ((ch = getch()) == ':')
				return (T_CC);
			savech = ch;
			return (':');
		default:	
			if (isdigit(ch))
				return (getnumber(ch));
			else 
				if (isidchar(ch))
					return (getid(ch));
				else 
				{
					t_token[0] = ch;
					t_token[1] = '\0';
					return (ch);
				}
		}
	}
}

/* getstring - get a string */
static int getstring()
{
    char *p;
    int ch;

    p = t_token; 			/* get the string */
    while ((ch = literalch()) != EOF && ch != '"')
		*p++ = ch;
    if (ch == EOF)
		savech = EOF;
    *p = '\0';
    return (T_STRING);
}

/* getcharacter - get a character constant */
static int getcharacter()
{
	t_value = literalch();
	t_token[0] = t_value;
	t_token[1] = '\0';
	if (getch() != '\'')
		parse_error("Expecting a closing single quote");
	return (T_NUMBER);
}

/* literalch - get a character from a literal string */
static int literalch()
{
	int ch;
	
	if ((ch = getch()) == '\\')
	{
		switch (ch = getch()) 
		{
		case 'n':  
			ch = '\n'; 
			break;
		case 't':  
			ch = '\t'; 
			break;
		case EOF:  
			ch = '\\'; 
			savech = EOF; 
			break;
		}
	}
	return (ch);
}

/* getid - get an identifier */
static int getid(ch)
int ch;
{
    char *p;
    int i;

    p = t_token; 			 /* get the identifier */
    *p++ = ch;
    while ((ch = getch()) != EOF && isidchar(ch))
		*p++ = ch;
    savech = ch;
    *p = '\0';

    for (i = 0; ktab[i].kt_keyword != NULL; ++i) /* check to see if it is a keyword */
		if (strcmp(ktab[i].kt_keyword,t_token) == 0)
			return (ktab[i].kt_token);
    return (T_IDENTIFIER);
}

/* getnumber - get a number */
static int getnumber(ch)
int ch;
{
    char *p;

    p = t_token;  				/* get the number */
    *p++ = ch; 
    t_value = ch - '0';
    while ((ch = getch()) != EOF && isdigit(ch)) 
    {
		t_value = t_value * 10 + ch - '0';
		*p++ = ch;
    }
    savech = ch;
    *p = '\0';
    return (T_NUMBER);
}

/* skipspaces - skip leading spaces */
static skipspaces()
{
    int ch;
    
    while ((ch = getch()) != '\0' && isspace(ch))
		;
    return (ch);
}

/* isidchar - is this an identifier character */
static int isidchar(ch)
int ch;
{
	return (isupper(ch) || islower(ch) || isdigit(ch) || ch == '_');
}

/* getch - get the next character */
static int getch()
{
    int ch;
    
    if ((ch = savech) != '\0') 	/* check for a lookahead character */
		savech = '\0';
    else  						/* check for a buffered character */
    {
		while ((ch = *lptr++) == '\0') 
		{

			if (lastch == EOF) 		/* check for being at the end of file */
				return (EOF);

			lptr = line; 			/* read the next line */
			while ((lastch = (*getcf)(getcd)) != EOF && lastch != '\n')
				*lptr++ = lastch;
			*lptr++ = '\n'; *lptr = '\0';
			lptr = line;
			++lnum;
		}
    }

    return (ch); 					/* return the current character */
}

/* parse_error - report an error in the current line */
parse_error(msg)
char *msg;
{
    extern jmp_buf error_trap;
    char buf[LSIZE],*src,*dst;

    sprintf(buf,">>> %s <<<\n>>> in line %d <<<\n%s",msg,lnum,line); /* redisplay the line with the error */
    osputs(buf);

    for (src = line, dst = buf; src < lptr-1; ++src) /* point to the position immediately following the error */
		*dst++ = (*src == '\t' ? '\t' : ' ');
    *dst++ = '^'; *dst++ = '\n'; *dst = '\0';
    osputs(buf);

    longjmp(error_trap,1); 							/* invoke the error trap */
}
