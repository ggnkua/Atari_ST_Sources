/* fixup.c - Routines to help resolve forward references */

#include <stdio.h>
#include "pogo.h"

/* Code to mark forward references in gotos */
add_fref(op, sym)
int op;
Symbol *sym;
{
if (rframe->fref_count >= FREFS)
	{
	say_fatal("Too many forward references");
	return;
	}
rframe->fref_ops[rframe->fref_count] = op;
rframe->fref_sym[rframe->fref_count] = sym;
rframe->fref_count++;
}

/* Code to resolve forward references in gotos */
fixup_fref()
{
int i;
Symbol *s;
struct pogo_op *code;

code = rframe->code_buf;
for (i=0; i<rframe->fref_count; i++)
	{
	s = rframe->fref_sym[i];
	if (s->type != LABEL)
		{
		printf("Undefined label %s\n", s->name);
		fatal();
		}
	code[rframe->fref_ops[i]].data.i += s->symval.i;
	}
rframe->fref_count = 0;
}

/* code to resolve forward references implied by break statements */
bfixup(endoff)
int endoff;
{
struct break_fixer *fixes;
struct pogo_op *code;

fixes = bfix_frame->fixes;
code = rframe->code_buf;
while (fixes != NULL)
	{
	code[fixes->code_offset].data.i += endoff;
	fixes = fixes->next;
	}
}

/* resolve all the forward function references in a given code body */
resolve_some_funcs(ff, code)
register struct func_forward *ff;
struct pogo_op *code;
{
struct func_frame *fuf;
Symbol *s;

while (ff != NULL)
	{
	s = ff->fsym;
	if (s->type == FFUNC)
		{
		printf("%s %d function %s undefined\n", title, ff->source_line, 
			s->name);
		fatal();
		break;
		}
	if (s->type == FCREATURE)
		{
		printf("%s %d creature %s undefined\n", title, ff->source_line, 
			s->name);
		fatal();
		break;
		}
#ifdef OLD
	if (s->type != CREATURE)
		{
		fuf = s->symval.p;
		code[ff->code_offset].data.p = fuf->code;
		}
#endif OLD
	ff = ff->next;
	}
}

/* resolve all the forward function references in a given code body */
resolve_crw(cc, code)
register struct crw_fixup *cc;
struct pogo_op *code;
{
Symbol *s, *ls;
struct func_frame *fuf;

while (cc != NULL)
	{
	s = cc->creature;
	if (s->type != CREATURE)
		{
		printf("%s %d - creature %s undefined\n", title, cc->source_line, 
			s->name);
		fatal();
		break;
		}
	fuf = s->symval.p;
	if ((ls = in_list(fuf->symbols, cc->lvar)) == NULL)
		{
		printf("%s %d - %s isn't a local variable of creature %d\n",
			title, cc->source_line, cc->lvar, s->name);
		fatal();
		break;
		}
	code[cc->code_offset].data.i = ls->doff;
	cc = cc->next;
	}
}

/* add a forward creature local variable fixup */
add_crw_fix(sym,lvar)
Symbol *sym;
char *lvar;
{
struct crw_fixup *ff;

if ((ff = beg_mem(sizeof(*ff))) == NULL)
	return(0);
if ((ff->lvar = clone_string(lvar)) == NULL)
	{
	freemem(ff);
	return(0);
	}
ff->source_line = line_count;
ff->creature = sym;
ff->code_offset = rframe->op_count;
ff->next = rframe->crw_fixes;
rframe->crw_fixes = ff;
return(1);
}

free_crw(oc)
struct crw_fixup *oc;
{
struct crw_fixup *c;

c = oc;
while (c != NULL)
	{
	freemem(c->lvar);
	c = c->next;
	}
free_list(oc);
}


/* resolve forward function references in code bodys of all functions,
   creatures, and the main body */
resolve_funcs()
{
struct func_frame *fuf;

fuf = ff_list;
while (fuf != NULL)
	{
	resolve_some_funcs(fuf->ffixes, fuf->code+1);
	free_list(fuf->ffixes);
	fuf->ffixes = NULL;
	resolve_crw(fuf->crw_fixes, fuf->code+1);
	free_crw(fuf->crw_fixes);
	fuf->crw_fixes = NULL;
	fuf = fuf->next;
	}
}

#ifdef LATER
/* make sure creatures all really defined */
creatures_all_there()
{
register Symbol *s;
int bad;

bad = 0;
s = ff_list->symbols;
while (s != NULL)
	{
	if (s->type == FCREATURE)
		{
		printf("Undefined creature %s\n", s->name);
		bad = 1;
		}
	s = s->next;
	}
if (bad)
	{
	fatal();
	wait_ok();
	}
}
#endif LATER

/* count pogo instructions in all functions */
count_is()
{
struct func_frame *fuf;
int acc;

acc = 0;
fuf = ff_list;
while (fuf != NULL)
	{
	acc += fuf->code_size;
	fuf = fuf->next;
	}
return(acc);
}

add_bfixup()
{
register struct break_fixer *bfx1;

if ((bfx1 = (struct break_fixer *)beg_zero(sizeof(*bfx1))) == NULL)
	return(0);
bfx1->code_offset = rframe->op_count;
bfx1->next = bfix_frame->fixes;
bfix_frame->fixes = bfx1;
return(1);
}

/* add a forward function fixup */
add_fff(sym)
Symbol *sym;
{
struct func_forward *ff;

if ((ff = beg_mem(sizeof(*ff))) == NULL)
	return(0);
ff->source_line = line_count;
ff->fsym = sym;
ff->code_offset = rframe->op_count;
ff->next = rframe->ffixes;
rframe->ffixes = ff;
return(1);
}

