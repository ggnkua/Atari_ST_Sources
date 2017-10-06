/* error.c - Routines to tell you what line you forgot to close 
	that parenthesis etc. */
#include <stdio.h>
#include "pogo.h"

err_info(s)
char *s;
{
if (run_time)
	{
	to_text();
	puts(s);
	}
else
	printf("%s line %d: %s\n", title, line_count, s);
}

wait_ok()
{
puts("Press <return> to continue kind sir or madam");
getchar();
}

/* error handling messages */
say_err(s)
char *s;
{
if (!run_time)
	printf("%s", line_buf);
err_info(s);
wait_ok();
}

fatal()
{
global_err = 1;
got_stop = 1;
run_abort = 1;
}

say_fatal(s)
char *s;
{
say_err(s);
fatal();
}

outta_memory()
{
say_fatal("Out of memory");
}

cant_create(n)
char *n;
{
char buf[120];

sprintf(buf, "Can't create file %s", n);
puts(buf);
say_fatal("Disk full or write protected?");
}

cant_find(n)
char *n;
{
char buf[120];

sprintf(buf, "Can't find file %s", n);
say_fatal(buf);
}

mangled(n)
char *n;
{
char buf[120];

sprintf(buf, "File %s is damaged or wrong type", n);
say_fatal(buf);
}


truncated(n)
char *n;
{
char buf[120];

sprintf(buf, "Unexpected end of file %s\n", n);
say_fatal(buf);
}

#define BSZ 80
expecting_got(e, g)
char *e, *g;
{
char buf[BSZ];

g[BSZ/2] = 0;		/* don't weird out on real long tokens */
sprintf(buf, "Expecting %s got %s\n", e, g);
say_fatal(buf);
}

unmatched(s)
char *s;
{
char buf[40];

sprintf(buf, "Unmatched %s", s);
say_fatal(buf);
}

runtime_err(s)
char *s;
{
to_text();
puts(s);
run_abort = 1;
wait_ok();
}

graphics_only(s)
char *s;
{
char buf[80];

sprintf(buf, "%s only available after a ToGraphics call", s);
runtime_err(buf);
}

no_such_creature(s, id)
char *s;
int id;
{
char buf[80];

sprintf(buf, "Can't %s(%d) - creature # %d doesn't exist", s, id, id);
runtime_err(buf);
}


not_in_creature(what)
char *what;
{
char buf[80];

if (in_creature)
	{
	sprintf(buf, "%s not allowed inside creature", what);
	say_fatal(buf);
	return(0);
	}
return(1);
}


only_in_creature(what)
char *what;
{
char buf[80];

if (!in_creature)
	{
	sprintf(buf, "%s only allowed inside creature", what);
	say_fatal(buf);
	return(0);
	}
return(1);
}

expecting_com_rpar()
{
expecting_got(", or )", ctoke);
}

too_many_params(name)
char *name;
{
char buf[80];

sprintf(buf, "%s - more than max %d parameters", name);
say_fatal(buf);
}


choke()
{
puts(line_buf);
puts(ctoke);
say_fatal("Pogo doesn't understand");
}

want_creature()
{
expecting_got("creature", ctoke);
}

want_string()
{
expecting_got("string", ctoke);
}


want_label()
{
say_fatal("Expecting a label");
}

want_closing()
{
expecting_got("}", ctoke);
}

want_opening()
{
expecting_got("{", ctoke);
}

want_prim()
{
say_fatal("Expecting a number, variable, or string");
}

redefined(s)
char *s;
{
char buf[80];

sprintf(buf, "%s redefined", s);
say_fatal(buf);
}

undefined(s)
char *s;
{
char buf[80];

sprintf(buf, "%s undefined", s);
say_fatal(buf);
}

want_variable()
{
if (cttype == TOK_UNDEF)
	{
	undefined(ctoke);
	}
else
	{
	expecting_got("Variable", ctoke);
	}
}

eat_token(tok)
char *tok;
{
if (!need_token())
	return(0);
if (strcmp(tok, ctoke) != 0)
	{
	expecting_got(tok, ctoke);
	return(0);
	}
return(1);
}

char *tnames[] = 
	{
	"int",
	"func",
	"label",
	"forward label",
	"forward function",
	"first forward function",
	"built in function",
	"string",
	"action",
	"bad",
	"creature",
	"fcreature",
	"constant",
	"unknown",
	};

type_mismatch(right,wrong)
int right, wrong;
{
printf("Should be a %s, but it's a %s\n", tnames[right], tnames[wrong]);
}

check_params(name, fuf, ptypes, pcount)
char *name;
struct func_frame *fuf;
unsigned char *ptypes;
int pcount;
{
int i;
unsigned char *optypes;
char buf[90];
int o, p;

optypes = fuf->ptypes;
if (pcount != fuf->pcount)
	{
	sprintf(buf, "%s needs %d parameters but has %d",  name,
		fuf->pcount, pcount);
	say_fatal(buf);
	return(0);
	}
for (i=1; i<=pcount; i++)
	{
	o = *optypes++;
	p = *ptypes++;
	if (o != p)
		{
		printf("%s", line_buf);
		sprintf(buf, "%s's parameter #%d isn't right type.", name, i);
		err_info(buf);
		type_mismatch(o,p);
		fatal();
		wait_ok();
		return(0);
		}
	}
return(1);
}

spawn_usage()
{
printf("%s", line_buf);
err_info("Bad Spawn");
puts("Usage:  Spawn(creature, xpos, ypos, xspeed, yspeed)");
fatal();
wait_ok();
}

missing_function(fname)
char *fname;
{
char buf[80];

sprintf(buf, "missing 'to' before %s???", fname);
say_err(buf);
}

used_not_assigned(name)
char *name;
{
char buf[100];

sprintf(buf, "possible use of %s before assignment.", name);
say_err(buf);
}

expect_2num(who,t1,t2)
char *who;
int t1,t2;
{
char buf[80];

sprintf(buf, "%s %s %s ???", tnames[t1], who, tnames[t2]);
say_fatal(buf);
}

want_int(t)
int t;
{
expecting_got("numerical expression", tnames[t]);
}
