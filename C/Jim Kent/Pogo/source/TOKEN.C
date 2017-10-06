
/* token.c - The pogo tokenizer. */

#include <stdio.h>
#include <ctype.h>
#include "pogo.h"

extern char *pget_line();

char *title;	
char line_buf[SZTOKE];
char *line_pos;
int line_count = 0;

/* variables maintained by next_token() */
char ctoke[SZTOKE];
Symbol *csym;
int cint;
int cttype;
int reuse;
Symbol *global_hash[256];


#ifdef CCODE
/* trivial utility routines */
copy_bytes(s, d, count)
register char *s, *d;
register int count;
{
while (--count >= 0)
	*d++ = *s++;
}
#endif CCODE

zero_bytes(d, count)
register char *d;
register int count;
{
while (--count >= 0)
	*d++ = 0;
}

dupe_bytes(d, val, count)
register char *d, val;
register int count;
{
while (--count >= 0)
	*d++ = val;
}

upper_case(s)
register unsigned char *s;
{
register unsigned char c;

while ((c = *s) != 0)
	{
	if (islower(c))
		*s += 'A' - 'a';
	s++;
	}
}

jstrcmp(a,b)
register char *a, *b;
{

if (a == b)
	return(0);
else if (a == NULL)
	return(1);
else if (b == NULL)
	return(-1);
else
	{
	return(strcmp(a,b));
	}
}


/*  Some memory allocation routines */
void *
beg_mem(size)
unsigned size;
{
char *pt;

pt = askmem(size);
if (pt == NULL)
	{
	outta_memory();
	}
return(pt);
}

void *
beg_zero(size)
int size;
{
char *pt;

if ((pt = (char *)beg_mem(size)) != NULL)
	zero_bytes(pt, size);
return(pt);
}

char *
clone_string(s)
char *s;
{
int size;
char *d;

if (s == NULL)
	return(NULL);
size = strlen(s)+1;
if ((d = (char *)beg_mem(size)) != NULL)
	copy_bytes(s, d, size);
return(d);
}

/* actually frees a generic list, not just a name list */
free_list(list)
Names *list;
{
Names *next;

while (list)
	{
	next = list->next;
	freemem(list);
	list = next;
	}
}

/* Symbol table management routines */
int
hash_function(string)
register unsigned char *string;
{
register int a, hash;

hash = 0;
while ((a = *string++)!= NULL)
	{
	hash <<= 1;
	hash ^= a;
	}
return(hash & 0xff);
}

add_hash(s)
Symbol *s;
{
int hash;

hash = hash_function(s->name);
s->next = global_hash[hash];
global_hash[hash] = s;
}

new_frame()
{
struct pogo_frame *pf;

if ((pf = (struct pogo_frame *)beg_zero(sizeof(*pf) ) ) == NULL)
	return(0);
pf->parent = rframe;
rframe = pf;
return(1);
}

old_frame()
{
struct pogo_frame *pf;

if (rframe != NULL)
	{
	pf = rframe->parent;
	freemem(rframe);
	rframe = pf;
	}
}

Symbol *
named_symbol(name, type, scope)
char *name;
int type;
int scope;
{
Symbol *ns;

if ((ns = (Symbol *)beg_zero(sizeof(*ns))) == NULL)
	return(NULL);
if ((ns->name = clone_string(name)) == NULL)
	{
	freemem(ns);
	return(NULL);
	}
ns->type = type;
ns->scope = scope;
ns->tok_type = TOK_VAR;
return(ns);
}

Symbol *
new_symbol(name, type, scope, frame)
char *name;
int type;
struct pogo_frame *frame;
{
Symbol *ns;

if ((ns = named_symbol(name, type, scope)) != NULL)
	{
	if (scope == LOCAL)
		{
		ns->next = frame->symbols;
		frame->symbols = ns;
		}
	else
		{
		add_hash(ns);
		}
	}
return(ns);
}


Symbol *
in_list(l, name)
register Symbol *l;
char *name;
{
while (l != NULL)
	{
	if (strcmp(l->name, name) == 0)
		return(l);
	l = l->next;
	}
return(NULL);
}

Symbol *
in_hash(name)
char *name;
{
return(in_list(global_hash[hash_function(name)], name) );
}

Symbol *
find_symbol(name)
char *name;
{
struct pogo_frame *p;
Symbol *s;

if ((s = in_hash(name)) != NULL)
	return(s);
if ((s = in_list(rframe->symbols, name)) != NULL)
	return(s);
return(NULL);
}

/* chop word ... put the next word in line
   into the buffer word points to, return what's left of the line, or
   NULL if at end of line */
char *
chop_word(line, oword)
register char *line;
char *oword;
{
register char c;
register char *word;


word = oword;

while (isspace(*line) )
	line++;
c = *line;
if (c == 0)
	return(NULL);
else if (iscsymf(c) )
	{
	cttype = TOK_UNDEF;
	*word++ = c;
	line++;
	for (;;)
		{
		c = *line;
		if (!iscsym(c) )
			break;
		*word++ = c;
		line++;
		}
	oword[MAX_SYM_LEN-1] = 0;		/* chop long symbols */
	}
else if (isdigit(c) )
	{
	if (c == '0' && (line[1] == 'x' || line[1] == 'X'))
		{
		*word++ = 0;
		*word++ = 'x';
		line += 2;
		for (;;)
			{
			c = *line;
			if (!isxdigit(c))
				break;
			*word++ = c;
			line++;
			}
		}
	for (;;)
		{
		c = *line;
		if (!isdigit(c) )
			break;
		*word++ = c;
		line++;
		}
	cttype = TOK_NUM;
	}
else if (c == '"')
	{
	cttype = TOK_QUO;
	line++;
	for (;;)
		{
		c = *line;
		if (c == 0)
			{
			unmatched("\"");
			break;
			}
		if( c == '"')
			{
			line++;
			break;
			}
		*word++ = c;
		line++;
		}
	}
else if (c == TOK_SQUO)
	{
	if (line[2] != TOK_SQUO)
		unmatched("'");
	*word++ = line[1];
	line += 3;
	cttype = TOK_SQUO;
	}
else
	{
	/* process non-alphanumeric characters.  Most will be passed through
	   as single character tokens.  Some, like ==, !=, >= and <= are
	   easier to handle here than in parser (which only has one token
	   look-ahead. */
	switch (c)
		{
		case '=':
			if (line[1] == '=')	/* double equals */
				{
				*word++ = '=';
				*word++ = '=';
				line += 2;
				cttype = TOK_EQ;
				}
			else
				goto SIMPLE;
			break;
		case '!':
			if (line[1] == '=')	/* != */
				{
				*word++ = '!';
				*word++ = '=';
				line += 2;
				cttype = TOK_NE;
				}
			else
				goto SIMPLE;
			break;
		case '<':
			if (line[1] == '=')	/* <= */
				{
				*word++ = '<';
				*word++ = '=';
				line += 2;
				cttype = TOK_LE;
				}
			else if (line[1] == '<')	/* << */
				{
				*word++ = '<';
				*word++ = '<';
				line += 2;
				cttype = TOK_LSHIFT;
				}
			else if (line[1] == '>')	/* <> */
				{
				*word++ = '<';
				*word++ = '>';
				line += 2;
				cttype = TOK_NE;
				}
			else
				goto SIMPLE;
			break;
		case '>':
			if (line[1] == '=')	/* >= */
				{
				*word++ = '>';
				*word++ = '=';
				line += 2;
				cttype = TOK_GE;
				}
			else if (line[1] == '>')	/* >> */
				{
				*word++ = '>';
				*word++ = '>';
				line += 2;
				cttype = TOK_RSHIFT;
				}
			else
				goto SIMPLE;
			break;
		case '&':
			if (line[1] == '&')	/* logical and - && */
				{
				*word++ = '&';
				*word++ = '&';
				line += 2;
				cttype = TOK_LAND;
				}
			else
				goto SIMPLE;
			break;
		case '|':
			if (line[1] == '|')	/* logical or - || */
				{
				*word++ = '|';
				*word++ = '|';
				line += 2;
				cttype = TOK_LOR;
				}
			else
				goto SIMPLE;
			break;
		default:
SIMPLE:
			cttype = *word++ = c;
			line++;
			break;
		}
	}
*word++ = 0;
return(line);
}
	

/* make us reuse last token.  Can only pushback one token though */
pushback_token()
{
if (reuse)
	{
	say_fatal("Double pushback");
	}
reuse = 1;
}

/* Hex to int */
htoi(s)
char *s;
{
int acc;
char c;

acc = 0;
while ((c = *s++) != 0)
	{
	acc <<= 4;
	if (isdigit(c))
		acc += c - '0';
	else if (c >= 'a' && c <= 'f')
		acc += (c - 'a' + 10);
	else if (c >= 'A' && c <= 'F')
		acc += (c - 'A' + 10);
	}
return(acc);
}

/* Next token - fetches next word from input into ctoke, and classifies
   it with cttype. Determines if a plain old word is a variable. */
next_token()
{
if (reuse)
	{
	reuse = 0;
	return(1);
	}
for (;;)
	{
	if (line_pos == NULL)
		{
		line_count++;
		if ((line_pos = pget_line(line_buf, sizeof(line_buf))) == NULL)
			{
			puts("EOF");
			got_eof = got_stop = 1;
			return(0);
			}
		}
	if ((line_pos = chop_word(line_pos, ctoke)) != NULL)
		{
		if (cttype == ';')	/* line to right of ; ignored */
			line_pos = NULL;
		else
			break;
		}
	}
if (cttype == TOK_UNDEF)
	{
	upper_case(ctoke);
	if ((csym = find_symbol(ctoke)) != NULL)
		cttype = csym->tok_type;
	}
else if (cttype == TOK_NUM)
	{
	if (ctoke[1] == 'x')
		{
		cint = htoi(ctoke+2);
		}
	else
		cint = atoi(ctoke);
	}
else if (cttype == TOK_SQUO)
	{
	cttype = TOK_NUM;
	cint = ctoke[0];
	}
return(1);
}


free_literals()
{
Names *next;

while (literals)
	{
	freemem(literals->name);
	next = literals->next;
	freemem(literals);
	literals = next;
	}
}



need_token()
{
if (!next_token())
	{
	truncated(title);
	return(0);
	}
return(1);
}

