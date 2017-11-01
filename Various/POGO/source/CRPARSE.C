
/* crparse.c - Code to help parse a creature.  */

#include <stdio.h>
#include "pogo.h"

int creature_count;

/* Is this a system maintained creature local variable? */
constant_secret()
{
if (cttype == TOK_CID)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CID);
	}
else if (cttype == TOK_CAGE)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CAGE );
	}
else if (cttype == TOK_CNEW)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CNEW );
	}
else if (cttype == TOK_CX)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CX );
	}
else if (cttype == TOK_CY)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CY );
	}
else if (cttype == TOK_CDX)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CDX );
	}
else if (cttype == TOK_CDY)
	{
	if (!only_in_creature(csym->name))
		return(1);
	code_num(OP_LVAR, (NUMBER)-SECRETS+CDY );
	}
else
	return(0);
return(1);
}

/* Writing to a system maintained creature local variable? */
secret_assignment()
{
static Symbol fake;
char nbuf[10];

if (cttype == TOK_CX)
	{
	if (!only_in_creature(csym->name))
		return(1);
	fake.doff = -SECRETS+CX;
	}
else if (cttype == TOK_CY)
	{
	if (!only_in_creature(csym->name))
		return(1);
	fake.doff = -SECRETS+CY;
	}
else if (cttype == TOK_CDX)
	{
	if (!only_in_creature(csym->name))
		return(1);
	fake.doff = -SECRETS+CDX;
	}
else if (cttype == TOK_CDY)
	{
	if (!only_in_creature(csym->name))
		return(1);
	fake.doff = -SECRETS+CDY;
	}
else
	return(0);
strcpy(nbuf, ctoke);
fake.name = nbuf;
fake.scope = LOCAL;
add_statement();
most_of_assignment(&fake);
return(1);
}

/* Code in an evolution call */
get_evolve()
{
if (!not_in_creature("Evolve()"))
	return;
if (!eat_token("(") )
	return;
if (!eat_token(")") )
	return;
code_void(OP_EVOLVE);
}

/* Make a symbol for a creature forward reference */
Symbol *
make_fcreature(name)
char *name;
{
Symbol *cs;

if ((cs = new_symbol(ctoke, FCREATURE, GLOBAL, rframe)) == NULL)
	return(NULL);
if ((cs->symval.p = beg_zero(sizeof(struct func_frame))) == NULL)
	{
	freemem(cs);
	return(NULL);
	}
cs->doff = creature_count++;
return(cs);
}

extern do_cread(), do_cwrite();

/* Grab the first 3 parameters for a Cread or Cwrite */
crw_params3()
{
Symbol *cs;

if (!eat_token(LPAREN_STR))
	return;
if (!need_token())
	return;
if (cttype == TOK_UNDEF)
	{
	if ((csym = make_fcreature(ctoke)) == NULL)
		return;
	cttype = TOK_VAR;
	}
if (cttype == TOK_VAR)
	{
	if (csym->type == CREATURE || csym->type == FCREATURE)
		{
		goto creatureok;
		}
	}
want_creature();
return;

creatureok:
cs = csym;
code_num(OP_CON, cs->doff);	/* push creature type */
if (!eat_token(","))
	return;
if (!need_token())
	return;
if (cs->type == FCREATURE)
	{
	add_crw_fix(cs,ctoke);
	code_num(OP_CON, 0);
	}
else
		/* push data offset of local */
	code_num(OP_CON,get_ldoff(cs->symval.p,ctoke));	
if (got_stop)
	return;
if (!eat_token(","))
	return;
get_iexpress();	/* push the creature id */
}

/* parse out and code up a cread function */
get_cread()
{
crw_params3();
if (got_stop)
	return;
if (!eat_token(RPAREN_STR))
	return;
if (got_stop)
	return;
finish_fp3(do_cread, OP_PREDEFL);
}

/* parse out and code up a cwrite function */
get_cwrite()
{
crw_params3();
if (got_stop)
	return;
if (!eat_token(","))
	return;
get_iexpress();
if (got_stop)
	return;
if (!eat_token(RPAREN_STR))
	return;
if (got_stop)
	return;
code_big(OP_PREDEF, do_cwrite);
code_num(OP_MOVES, (NUMBER)-5);
}

/* get data  offset of creature local variable */
get_ldoff(fuf, name)
struct func_frame *fuf;
char *name;
{
Symbol *s;

if (((s = in_list(fuf->symbols, name)) == NULL) || s->type != INT)
	{
	expecting_got("creature local variable", name);
	return(0);
	}
return(s->doff);
}

extern fclosestt();
extern int get_ta;

/* parse out a ClosestT() call */
get_closestt()
{
char cname[80];
Symbol *cs;

strcpy(cname, ctoke);
if (!eat_token(LPAREN_STR))
	return;
if (!need_token())
	return;
if (cttype == TOK_UNDEF)
	{
	if ((cs = make_fcreature(cname)) == NULL)
		goto gotsym;
	}
else if (cttype == TOK_VAR)
	{
	if (csym->type == FCREATURE || csym->type == CREATURE)
		{
		cs = csym;
		goto gotsym;
		}
	else
		{
		want_creature();
		return;
		}
	}
else
	{
	want_creature();
	return;
	}
gotsym:
code_num(OP_CON, cs->doff);
if (!eat_token(","))
	return;
get_iexpress();
if (got_stop)
	return;
if (!eat_token(","))
	return;
get_iexpress();
if (got_stop)
	return;
if (!eat_token(RPAREN_STR))
	return;
get_ta = 1;
finish_fp3(fclosestt, OP_PREDEF);
}

finish_fp3(f,op)
function *f;
int op;
{
code_big(op, f);
code_num(OP_RETRIEVE, (NUMBER)-3);
#ifdef LATER
code_num(OP_MOVES, (NUMBER)-2);
#endif LATER
}


/* parse out a spawn call */
get_spawn()
{
int stype;
Symbol *crsym;
struct func_frame *fuf;
int i;

if (!eat_token("(") )
	return;
if (!need_token())
	return;
if (cttype == TOK_UNDEF)
	{
	if ((csym = make_fcreature(ctoke)) == NULL)
		return;
	cttype = TOK_VAR;
	}
if (cttype == TOK_VAR)
	{
	crsym = csym;
	stype = crsym->type;
	if (stype == FCREATURE)
		{
		add_fff(crsym);
		code_big(OP_CON, crsym->symval.p); /* push creatures func_frame */
		}
	else if (stype == CREATURE)
		{
		code_big(OP_CON, crsym->symval.p); /* push creatures func_frame */
		}
	else
		{
		spawn_usage();
		return;
		}
	}
else
	{
	spawn_usage();
	return;
	}
if (!need_token())
	{
	return;
	}
if (cttype != ',')
	{
	spawn_usage();
	return;
	}
i = 3;
while (--i >= 0)
	{
	get_iexpress();
	if (got_stop)
		{
		spawn_usage();
		return;
		}
	if (!need_token())
		{
		return;
		}
	if (cttype != ',')
		{
		spawn_usage();
		return;
		}
	}
get_iexpress();
if (got_stop)
	return;
if (!eat_token(")") )
	{
	return;
	}
code_void(OP_SPAWN);
}

/* Go define a creature */
get_creature()
{
Symbol *sym;
struct func_frame *fuf;

if (in_loop)
	{
	say_fatal("No creatures inside loops, whiles, or fors");
	return;
	}
if (in_func)
	{
	say_fatal("No creatures inside function declarations");
	return;
	}
if (in_creature)
	{
	say_fatal("No creatures inside other creatures");
	return;
	}
if (!need_token())
	return;
if (cttype == TOK_VAR && csym->type == FCREATURE)
	sym = csym;
else
	{
	if (cttype != TOK_UNDEF)
		{
		redefined(ctoke);
		return;
		}
	if ((sym = make_fcreature(ctoke)) == NULL)
		return;
	}
if (!eat_token(LBRACE_STR))
	return;
new_frame();
in_creature = 1;
get_states();
code_void(OP_END);
fixup_fref();
if (got_stop)
	return;
in_creature = 0;
if (!eat_token(RBRACE_STR))
	{
	return;
	}
fuf = sym->symval.p;
save_function(sym, fuf);
fuf->crtype = sym->doff;
sym->type = CREATURE;
fuf->got_strings = got_strings(fuf->symbols);
old_frame();
}

got_strings(s)
Symbol *s;
{
while (s != NULL)
	{
	if (s->type == STRING)
		return(1);
	s = s->next;
	}
return(0);
}

