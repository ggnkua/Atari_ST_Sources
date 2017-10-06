
#include <stdio.h>
#include "pogo.h"

int fret_type = INT;

call_func(sym, rvalue, rtype)
Symbol *sym;
int rvalue;	/* returns a value? */
int rtype;
{
struct func_frame *fuf;
void *code;
unsigned char ptypes[MAX_PARAMS];
int pcount;

fuf = sym->symval.p;
if (fuf->ret_type != rtype)
	{
	say_fatal("function returns wrong type");
	return;
	}
need_token();
if (cttype != TOK_LPAREN)
	{
	expecting_got("(", ctoke);
	return;
	}
pcount = 0;
need_token();
if (cttype != TOK_RPAREN)
	{
	pushback_token();
	for (;;)
		{
		if ((ptypes[pcount] = get_expression()) == BAD)
			return;
		pcount++;
		if (got_stop)
			return;
		need_token();
		if (cttype == TOK_RPAREN)
			break;
		else if (cttype != ',')
			{
			expecting_com_rpar();
			return;
			}
		if (pcount >= MAX_PARAMS)
			{
			too_many_params();
			}
		}
	}
if (sym->type == FFFUNC)
	{
	fuf->pcount = pcount;
	sym->type = FFUNC;
	copy_bytes(ptypes, fuf->ptypes, pcount);
	}
if (!check_params(sym->name, fuf, ptypes, pcount))
	return;
if (sym->type == FUNC)
	{
	if (rvalue)
		{
		if (fuf->ret_type == STRING)
			code_big(OP_CALLS, fuf);
		else
			code_big(OP_CALL, fuf);
		}
	else
		code_big(OP_PCALL, fuf);
	}
else if (sym->type == PREDEF)
	{
	if (rvalue)
		{
		if (fuf->ret_type == STRING)
			code_big(OP_PREDEFL, fuf->code);
		else
			code_big(OP_PREDEF, fuf->code);
		}
	else
		code_big(OP_PPREDEF, fuf->code);
	}
else
	{
	if (!add_fff(sym) )
		return;
	if (rvalue)
		if (fuf->ret_type == STRING)
			code_big(OP_CALLS, fuf);
		else
			code_big(OP_CALL, fuf);
	else
		code_big(OP_PCALL, fuf);
	}
if (pcount != 0)
	{
	if (!rvalue) /* if it doesnt retunr a value just clear params */
		{
		code_num(OP_MOVES, (NUMBER)-pcount);
		}
	else
		{
		code_num(OP_RETRIEVE, (NUMBER)-pcount);
#ifdef LATER
		if (pcount != 1)
			code_num(OP_MOVES, (NUMBER)1-pcount);
#endif LATER
		}
	}
}


/* this puppy checks if an undefined name is the 1st part of a function
   call.  If not return 0.  If so go call func and return 1 */
precall_func(rvalue,rtype)
int rvalue;	/* returns a value */
int rtype;
{
char fname[MAX_SYM_LEN];
Symbol *ns;
struct func_frame *fuf;

strcpy(fname, ctoke);	/* save name */
if (!next_token())
	return(0);
pushback_token();
if (cttype == '(')
	{
	if ((fuf = beg_zero(sizeof(*fuf))) == NULL)
		return(0);
	/* Undefined functions get hung on global frame */
	if ((ns = new_symbol(fname, FFFUNC, GLOBAL, global_frame)) != NULL)
		{
		ns->symval.p = (void *)fuf;
		fuf->ret_type = rtype;
		call_func(ns, rvalue, rtype);
		if (global_err)
			{
			missing_function(fname);
			}
		}
	if (next_token())
		{
		if (cttype == TOK_LBRACE)
			{
			missing_function(fname);
			}
		pushback_token();
		}
	return(1);
	}
else
	{
	return(0);
	}
}

/* declare a function */
get_function()
{
Symbol *sym;
Symbol *parameters, *np;
struct func_frame *fuf;
int pcount, poff;
unsigned char ptypes[MAX_PARAMS];
int ptype;

if (in_func)
	{
	say_fatal("No functions defined in a function");
	return;
	}
if (in_loop)
	{
	say_fatal("No functions defined in a loop, while, or for");
	return;
	}
if (in_creature)
	{
	say_fatal("No functions defined in a creature");
	return;
	}
if (!need_token())
	return;
if (cttype == TOK_INT)
	fret_type = INT;
else if (cttype == TOK_STRING)
	fret_type = STRING;
else
	{
	fret_type = INT;
	pushback_token();
	}
if (!need_token())
	return;
if (cttype == TOK_VAR && csym->type == FFUNC)
	sym = csym;
else
	{
	if (cttype != TOK_UNDEF)
		{
		redefined(ctoke);
		return;
		}
	if ((sym = new_symbol(ctoke, FFUNC, GLOBAL, rframe)) == NULL)
		return;
	}
eat_token(LPAREN_STR);
if (!need_token())
	return;
parameters = NULL;
pcount = 0;
if (cttype != TOK_RPAREN)
	{
	pushback_token();
	for (;;)
		{
		if (!need_token())
			return;
		ptype = INT;
		if (cttype == TOK_INT)
			{
			}
		else if (cttype == TOK_STRING)
			{
			ptype = STRING;
			}
		else
			pushback_token();
		if (!need_token())
			return;
		if (cttype !=TOK_UNDEF)
			{
			if (cttype == TOK_VAR)
				redefined(ctoke);
			else
				expecting_got("name", ctoke);
			return;
			}
		if ((np = named_symbol(ctoke, ptype, LOCAL)) == NULL)
			return;
		np->next = parameters;
		np->assigned = 1;
		parameters = np;
		ptypes[pcount] = ptype;
		pcount++;
		if (!need_token())
			return;
		if (cttype == TOK_RPAREN)
			{
			break;
			}
		if (cttype != ',')
			{
			expecting_com_rpar();
			return;
			}
		if (pcount >= MAX_PARAMS)
			{
			too_many_params(sym->name);
			return;
			}
		}
	}
poff = -2;
np = parameters;
while (np != NULL)
	{
	np->doff = poff;
	np = np->next;
	poff -= 1;
	}
fuf = (struct func_frame *)sym->symval.p;
if (fuf == NULL)
	{
	if ((fuf = (struct func_frame *)beg_zero(sizeof(*fuf))) == NULL)
		{
		return;
		}
	sym->symval.p = (void *)fuf;
	fuf->pcount = pcount;
	copy_bytes(ptypes, fuf->ptypes, pcount);
	}
else
	{
	if (!check_params(sym->name, fuf, ptypes, pcount))
		{
		return;
		}
	}
if (!eat_token(LBRACE_STR))
	return;
new_frame();
rframe->pcount = pcount;
rframe->symbols = parameters;
rframe->ret_type = fret_type;
in_func = 1;
pogo_func(pcount);
if (got_stop)
	return;
in_func = 0;
if (!eat_token(RBRACE_STR))
	{
	return;
	}
save_function(sym, fuf);
sym->type = FUNC;
old_frame();
fret_type = INT;
return;
}


/* do what it takes to save code and symbols in function we just parsed */
/* do what forward reference fixup we can to the function (goto's) and */
/* proceed to transform static sized pogo_frame pointer to keep track of */
/* it all into a dynamically sized func_frame pointer */
save_function(fs, fuf)
Symbol *fs;
struct func_frame *fuf;
{
struct pogo_op *code;
int csize;
int cpsize;

/* want to hang function symbol on parent's frame */
cpsize = rframe->op_count + 1;
csize = cpsize * sizeof(*code);
if ((code = (struct pogo_op *)beg_mem(csize)) == NULL)
	{
	return(0);
	}
/* put in operation to skip past local variables on stack */
code->type = OP_MOVES;
code->data.p = NULL;	/* make disassembly look neater */
code->data.i = rframe->dcount+fuf->pcount;
/* copy rest of function as is */
copy_bytes(rframe->code_buf, code+1, csize-1*sizeof(*code));
fuf->code = code;
fuf->code_size = cpsize;
fuf->symbols = rframe->symbols;
fuf->ffixes = rframe->ffixes;
fuf->crw_fixes = rframe->crw_fixes;
fuf->dcount = rframe->dcount;
fuf->ret_type = rframe->ret_type;
fuf->name = fs->name;
fuf->next = ff_list;
ff_list = fuf;
fs->symval.p = fuf;
return(1);
}

