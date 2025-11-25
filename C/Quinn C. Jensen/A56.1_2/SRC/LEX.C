/*******************************************************
 *
 *  a56 - a DSP56001 assembler
 *
 *  Written by Quinn C. Jensen
 *  July 1990
 *
 *******************************************************\

/*
 *  lex.c - lexical analyzer envelope.  lexyy.c, included below,
 *  is the LEX-generated code.
 *
 */

#include "a56.h"
#include "gram.h"

int ldebug = 0;
#ifdef LDEBUG
#define RET(val) \
	{\
		if(ldebug) {\
			printf("[%s]", tok_print(val));\
			fflush(stdout);\
		}\
		return val;\
	}
#else
#define RET(val) {return val;}
#endif

extern YYSTYPE yyval;

double atof();

/**************** yylex - returns next token *****************************/

#define MAX_TOK 1024
char tok[MAX_TOK];

yylex()
{
	int ltok = next_tok();
	int itok;

	switch(ltok) {
	case EOF:
		if(yywrap() == 1)
			return 0;
		else
			return yylex();
		break;
	case SYM:
		if(itok = is_keyword(tok)) {
			RET(itok);
		} else {
			yylval.sval = strsave(tok);
			RET(SYM);
		}
		break;
	case CHEX:
		yylval.n.type = INT;
		yylval.n.val.i = strtol(tok, 0, 16);
		RET(CHEX);
		break;
	case CDEC:
		yylval.n.type= INT;
		yylval.n.val.i = atoi(tok);
		RET(CDEC);
		break;
	case FRAC:
		yylval.n.type = FLT;
		yylval.n.val.f = atof(tok);
		RET(FRAC);
	case CHAR:
		yylval.cval = *tok;
		RET(CHAR);
	case STRING:
		yylval.sval = (char *)fixstring(tok);
		yylval.sval = strsave(yylval.sval);
		RET(STRING);
	default:
		RET(ltok);
	}
}

is_keyword(tok)
char *tok;
{
	int kval = kparse(tok);
	if(kval > 0)
		return kval;

	return 0;
}

struct ascii_tab {
	char *str;
	int flags;
} ascii_tab[];
#define IS_NONE		0x0000
#define IS_NUM		0x0001
#define IS_ALPHA	0x0002
#define IS_HEX		0x0004
#define IS_WHITE	0x0008

extern FILE *yyin;

int next_tok()
{
	char *tp = tok;
	enum {S_TOP, S_HEXNUM, S_NUM, S_ALNUM, S_CHAR, S_ESC_CHAR, S_COMMENT,
		S_SQ_STRING, S_DQ_STRING, S_SHL, S_SHR} state = S_TOP;
	static int unget = 0;
	BOOL dot_seen = FALSE;

	for(;;) {
		int c = unget ? unget : lgetc(yyin);
		int flags;
		unget = 0;
		flags = ascii_tab[c & 0x7F].flags;
		if(tp > tok + MAX_TOK - 2) return LEXBAD;
		switch(state) {
		case S_TOP:
			if(c == EOF) {
				return EOF;
			} else if(flags & IS_WHITE) {
				/* ignore */ ;
			} else if(flags & IS_ALPHA) {
				*tp++ = c;
				state = S_ALNUM;
			} else if((flags & IS_NUM) || c == '.') {
				unget = c;
				state = S_NUM;
			} else {
				switch(c) {
				case '$': state = S_HEXNUM; break;
				case '"': state = S_DQ_STRING; break;
				case '\'': state = S_CHAR; break;
				case '>': state = S_SHR; break;
				case '<': state = S_SHL; break;
				case ';': state = S_COMMENT; break;
				case '\n': return EOL;
				case '@': return EOS;
				default: return c;
				}
			}
			break;
		case S_COMMENT:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return EOL;
			} else if(c == '\n') {
				return EOL;
			}
			break;
		case S_SHR:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return '>';
			} else if(c == '>') {
				return SHR;
			} else {
				unget = c;
				return '>';
			}
			break;
		case S_SHL:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return '<';
			} else if(c == '<') {
				return SHL;
			} else {
				unget = c;
				return '<';
			}
			break;
		case S_HEXNUM:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return CHEX;
			} else if(flags & IS_HEX) {
				*tp++ = c;
				break;
			} else {
				unget = c;
				*tp = '\0';
				return CHEX;
			}
			break;
		case S_ALNUM:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return SYM;
			} else if(c == ':') {
				*tp++ = c;
				*tp = '\0';
				return SYM;
				break;
			} else if(flags & (IS_ALPHA|IS_NUM)) {
				*tp++ = c;
				break;
			} else {
				unget = c;
				*tp = '\0';
				return SYM;
			}
			break;
		case S_NUM:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return dot_seen ? FRAC : CDEC;
			} else if((flags & IS_NUM) || (c == '.' && NOT dot_seen)) {
				*tp++ = c;
				if(c == '.') dot_seen = TRUE;
				break;
			} else {
				unget = c;
				*tp = '\0';
				return dot_seen ? FRAC : CDEC;
			}
			break;
		case S_CHAR:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return CHAR;
			} else if(c == '\\') {
				state = S_ESC_CHAR;
			} else if(c == '\'') {
				*tp = '\0';
				return CHAR;
			} else {
				*tp++ = c;
				if(tp > tok + 1)
					state = S_SQ_STRING;
			}
			break;
		case S_ESC_CHAR:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return CHAR;
			}
			switch(c) {
			case 'b': *tp = '\b'; break;
			case 'f': *tp = '\f'; break;
			case 'n': *tp = '\n'; break;
			case 'r': *tp = '\r'; break;
			case 't': *tp = '\t'; break;
			case '\\': *tp = '\\'; break;
			case '\'':
				*tp = '\0';
				return CHAR;
				break;
			default:
				*tp++ = c;
				state = S_SQ_STRING;
				break;
			}
			break;
		case S_SQ_STRING:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return STRING;
			} else if(c == '\'') {
				*tp = '\0';
				return STRING;
			} else {
				*tp++ = c;
			}
			break;
		case S_DQ_STRING:
			if(c == EOF) {
				unget = EOF;
				*tp = '\0';
				return STRING;
			} else if(c == '"') {
				*tp = '\0';
				return STRING;
			} else {
				*tp++ = c;
			}
			break;
		} /* switch(state) */
	} /* for(;;) */
}

struct ascii_tab ascii_tab[] = {
	{"\\z00",	IS_NONE					/* 0x00 */},
	{"\\z01",	IS_NONE					/* 0x01 */},
	{"\\z02",	IS_NONE					/* 0x02 */},
	{"\\z03",	IS_NONE					/* 0x03 */},
	{"\\z04",	IS_NONE					/* 0x04 */},
	{"\\z05",	IS_NONE					/* 0x05 */},
	{"\\z06",	IS_NONE					/* 0x06 */},
	{"\\z07",	IS_NONE					/* 0x07 */},
	{"\\b",		IS_NONE					/* 0x08 */},
	{"\\t",		IS_NONE|IS_WHITE		/* 0x09 */},
	{"\\n",		IS_NONE					/* 0x0A */},
	{"\\z0B",	IS_NONE					/* 0x0B */},
	{"\\z0C",	IS_NONE					/* 0x0C */},
	{"\\r",		IS_NONE					/* 0x0D */},
	{"\\z0E",	IS_NONE					/* 0x0E */},
	{"\\z0F",	IS_NONE					/* 0x0F */},
	{"\\z10",	IS_NONE					/* 0x10 */},
	{"\\z11",	IS_NONE					/* 0x11 */},
	{"\\z12",	IS_NONE					/* 0x12 */},
	{"\\z13",	IS_NONE					/* 0x13 */},
	{"\\z14",	IS_NONE					/* 0x14 */},
	{"\\z15",	IS_NONE					/* 0x15 */},
	{"\\z16",	IS_NONE					/* 0x16 */},
	{"\\z17",	IS_NONE					/* 0x17 */},
	{"\\z18",	IS_NONE					/* 0x18 */},
	{"\\z19",	IS_NONE					/* 0x19 */},
	{"\\z1A",	IS_NONE					/* 0x1A */},
	{"\\z1B",	IS_NONE					/* 0x1B */},
	{"\\z1C",	IS_NONE					/* 0x1C */},
	{"\\z1D",	IS_NONE					/* 0x1D */},
	{"\\z1E",	IS_NONE					/* 0x1E */},
	{"\\z1F",	IS_NONE					/* 0x1F */},
	{" ",		IS_NONE|IS_WHITE		/* 0x20 */},
	{"!",		IS_NONE					/* 0x21 */},
	{"\"",		IS_NONE					/* 0x22 */},
	{"#",		IS_NONE					/* 0x23 */},
	{"$",		IS_NONE					/* 0x24 */},
	{"%",		IS_NONE					/* 0x25 */},
	{"&",		IS_NONE					/* 0x26 */},
	{"'",		IS_NONE					/* 0x27 */},
	{"(",		IS_NONE					/* 0x28 */},
	{")",		IS_NONE					/* 0x29 */},
	{"*",		IS_NONE					/* 0x2A */},
	{"+",		IS_NONE					/* 0x2B */},
	{",",		IS_NONE					/* 0x2C */},
	{"-",		IS_NONE					/* 0x2D */},
	{".",		IS_NONE					/* 0x2E */},
	{"/",		IS_NONE					/* 0x2F */},
	{"0",		IS_NONE|IS_NUM|IS_HEX	/* 0x30 */},
	{"1",		IS_NONE|IS_NUM|IS_HEX	/* 0x31 */},
	{"2",		IS_NONE|IS_NUM|IS_HEX	/* 0x32 */},
	{"3",		IS_NONE|IS_NUM|IS_HEX	/* 0x33 */},
	{"4",		IS_NONE|IS_NUM|IS_HEX	/* 0x34 */},
	{"5",		IS_NONE|IS_NUM|IS_HEX	/* 0x35 */},
	{"6",		IS_NONE|IS_NUM|IS_HEX	/* 0x36 */},
	{"7",		IS_NONE|IS_NUM|IS_HEX	/* 0x37 */},
	{"8",		IS_NONE|IS_NUM|IS_HEX	/* 0x38 */},
	{"9",		IS_NONE|IS_NUM|IS_HEX	/* 0x39 */},
	{":",		IS_NONE					/* 0x3A */},
	{";",		IS_NONE					/* 0x3B */},
	{"<",		IS_NONE					/* 0x3C */},
	{"=",		IS_NONE					/* 0x3D */},
	{">",		IS_NONE					/* 0x3E */},
	{"?",		IS_NONE					/* 0x3F */},
	{"@",		IS_NONE					/* 0x40 */},
	{"A",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x41 */},
	{"B",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x42 */},
	{"C",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x43 */},
	{"D",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x44 */},
	{"E",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x45 */},
	{"F",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x46 */},
	{"G",		IS_NONE|IS_ALPHA		/* 0x47 */},
	{"H",		IS_NONE|IS_ALPHA		/* 0x48 */},
	{"I",		IS_NONE|IS_ALPHA		/* 0x49 */},
	{"J",		IS_NONE|IS_ALPHA		/* 0x4A */},
	{"K",		IS_NONE|IS_ALPHA		/* 0x4B */},
	{"L",		IS_NONE|IS_ALPHA		/* 0x4C */},
	{"M",		IS_NONE|IS_ALPHA		/* 0x4D */},
	{"N",		IS_NONE|IS_ALPHA		/* 0x4E */},
	{"O",		IS_NONE|IS_ALPHA		/* 0x4F */},
	{"P",		IS_NONE|IS_ALPHA		/* 0x50 */},
	{"Q",		IS_NONE|IS_ALPHA		/* 0x51 */},
	{"R",		IS_NONE|IS_ALPHA		/* 0x52 */},
	{"S",		IS_NONE|IS_ALPHA		/* 0x53 */},
	{"T",		IS_NONE|IS_ALPHA		/* 0x54 */},
	{"U",		IS_NONE|IS_ALPHA		/* 0x55 */},
	{"V",		IS_NONE|IS_ALPHA		/* 0x56 */},
	{"W",		IS_NONE|IS_ALPHA		/* 0x57 */},
	{"X",		IS_NONE|IS_ALPHA		/* 0x58 */},
	{"Y",		IS_NONE|IS_ALPHA		/* 0x59 */},
	{"Z",		IS_NONE|IS_ALPHA		/* 0x5A */},
	{"[",		IS_NONE					/* 0x5B */},
	{"\\",		IS_NONE					/* 0x5C */},
	{"]",		IS_NONE					/* 0x5D */},
	{"^",		IS_NONE					/* 0x5E */},
	{"_",		IS_NONE|IS_ALPHA		/* 0x5F */},
	{"`",		IS_NONE					/* 0x60 */},
	{"a",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x61 */},
	{"b",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x62 */},
	{"c",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x63 */},
	{"d",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x64 */},
	{"e",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x65 */},
	{"f",		IS_NONE|IS_ALPHA|IS_HEX	/* 0x66 */},
	{"g",		IS_NONE|IS_ALPHA		/* 0x67 */},
	{"h",		IS_NONE|IS_ALPHA		/* 0x68 */},
	{"i",		IS_NONE|IS_ALPHA		/* 0x69 */},
	{"j",		IS_NONE|IS_ALPHA		/* 0x6A */},
	{"k",		IS_NONE|IS_ALPHA		/* 0x6B */},
	{"l",		IS_NONE|IS_ALPHA		/* 0x6C */},
	{"m",		IS_NONE|IS_ALPHA		/* 0x6D */},
	{"n",		IS_NONE|IS_ALPHA		/* 0x6E */},
	{"o",		IS_NONE|IS_ALPHA		/* 0x6F */},
	{"p",		IS_NONE|IS_ALPHA		/* 0x70 */},
	{"q",		IS_NONE|IS_ALPHA		/* 0x71 */},
	{"r",		IS_NONE|IS_ALPHA		/* 0x72 */},
	{"s",		IS_NONE|IS_ALPHA		/* 0x73 */},
	{"t",		IS_NONE|IS_ALPHA		/* 0x74 */},
	{"u",		IS_NONE|IS_ALPHA		/* 0x75 */},
	{"v",		IS_NONE|IS_ALPHA		/* 0x76 */},
	{"w",		IS_NONE|IS_ALPHA		/* 0x77 */},
	{"x",		IS_NONE|IS_ALPHA		/* 0x78 */},
	{"y",		IS_NONE|IS_ALPHA		/* 0x79 */},
	{"z",		IS_NONE|IS_ALPHA		/* 0x7A */},
	{"{",		IS_NONE					/* 0x7B */},
	{"|",		IS_NONE					/* 0x7C */},
	{"}",		IS_NONE					/* 0x7D */},
	{"~",		IS_NONE					/* 0x7E */},
	{"\\z7F",	IS_NONE					/* 0x7F */},
};


/**************** lgetc - returns next character *************************/

#define INLINE 1024

char line_buf[INLINE];
char *cur_line = line_buf;		/* points to current line buffer */
char *clp = NULL;				/* where we're at in cur_line */

lgetc(fp)
FILE *fp;
{
	int c;

	if(clp == NULL) {
		if(fgets(cur_line, INLINE, fp) == NULL) {
			c = EOF;
		} else {
			clp = cur_line;
			c = *clp++;
		}
	} else {
		c = *clp++;
	}

	switch(c) {
	case EOF:
		/* at EOF: all done */
		if(ldebug)
			printf("<eof>\n");
		return EOF;
		break;
	case '\0':
		c = '\n';
	case '\n':
		clp = NULL;
		break;
	default:
		break;
	}

	if(ldebug)
		printf(c < ' ' ? "<\\z%02X>%s" : "<%c>", c, c == '\n' ? "\n" : "");

	return c;
}
