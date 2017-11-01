
/* stringy.c - string handling stuff */

#include <stdio.h>
#include "pogo.h"
#include "dlist.h"

extern Names *temps[];

extern void *linkt();
int do_frees;

add_frees()
{
if (do_frees)
	{
	code_void(OP_FREES);
	do_frees = 0;
	}
}

clear_frees()
{
free_nlist(temps[0]);
temps[0] = NULL;
}


free_nlist(s)
Names *s;
{
Names *n;

while (s != NULL)
	{
	n = s->next;
	freemem(s->name);
	freemem(s);
	s = n;
	}
}

add_cr_string(s)
char *s;
{
Names *ns;

if ((ns = beg_zero(sizeof(*ns))) != NULL)
	{
	ns->name = s;
	ns->next = temps[active_frame-1];
	temps[active_frame-1] = ns;
	}
}

/* stuff to take care of constant strings */
char *
add_string(s)
char *s;
{
Names *ns;

if ((ns = beg_mem(sizeof(*ns) ) ) != NULL)
	{
	if ((ns->name = clone_string(s)) == NULL)
		{
		freemem(ns);
		return(NULL);
		}
	ns->next = literals;
	literals = ns;
	return(ns->name);
	}
return(NULL);
}

char *
str_cat(p)
union pt_int *p;
{
char *s1,*s2;
int l1, l2;
char *d;

s1 = p[-2].p;
s2 = p[-1].p;
if (s1 == NULL)
	return(s2);
if (s2 == NULL)
	return(s1);
l1 = strlen(s1);
l2 = strlen(s2);
if ((d = beg_mem(l1+l2+1)) == NULL)
	return(s1);
strcpy(d,s1);
strcpy(d+l1,s2);
add_cr_string(d);
return(d);
}


get_sprim()
{
next_token();
if (cttype == TOK_QUO)
	{
	code_big(OP_CON, add_string(ctoke) );
	return(STRING);
	}
else if (cttype == TOK_NULL)
	{
	code_big(OP_CON, NULL);
	return(STRING);
	}
else if (cttype == TOK_CNAME)
	{
	if (!only_in_creature("CNAME"))
		return(BAD);
	code_num(OP_LVAR, 3 - SECRETS);
	return(STRING);
	}
else if (cttype == TOK_VAR)
	{
	if (csym->type == STRING)
		{
		push_var();
		return(STRING);
		}
	else if (
		(csym->type == FUNC || csym->type == FFUNC || csym->type == PREDEF))
		{
		struct func_frame *fuf;

		fuf = csym->symval.p;
		if (fuf->ret_type == STRING)
			{
			call_func(csym, 1, STRING);
			return(STRING);
			}
		}
	}
pushback_token();
return(UNKNOWN);
}

extern char *str_cat();

get_sadd()
{
int ok;

ok = get_sprim();
if (ok != STRING)
	return(ok);
if (next_token())
	{
	if (cttype == '+')
		{
		if (get_sadd() != STRING)
			{
			want_string();
			return(BAD);
			}
		code_big(OP_PREDEFL, str_cat);
		code_num(OP_RETRIEVE, -2);
		if (!in_func)	/* root function */
			do_frees = 1;
		}
	else
		{
		pushback_token();
		}
	}
return(STRING);
}

get_sexpress()
{
int ok;
int type;
extern pstrcmp(), psamename();

ok = get_sadd();
if (ok != STRING)
	return(ok);
if (next_token())
	{
	if (cttype == TOK_EQ || cttype == TOK_NE)
		{
		type = cttype;
		ok = get_sadd();
		if (ok != STRING)
			{
			want_string();
			return(BAD);
			}
		code_big(OP_PREDEF, (type == TOK_EQ ? psamename : pstrcmp));
		code_num(OP_RETRIEVE, -2);
		return(INT);
		}
	else
		{
		pushback_token();
		return(STRING);
		}
	}
}
