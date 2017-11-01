/* statemen.c - Here's where pogo statements are parsed. */

#include <stdio.h>
#include "pogo.h"

/* Parse a list of statements */
get_states()
{
while (!got_stop)
	{
	if (!next_token())
		return;
	if (cttype == TOK_RBRACE)
		{
		pushback_token();
		return;
		}
	pushback_token();
	get_statement();
	}
}

Statement *slist, *stail;

add_statement()
{
Statement *ns;
extern int debug_statements;

if (!debug_statements)
	return;
if ((ns = beg_mem(sizeof(*ns))) == NULL)
	return;
if (line_pos == NULL)
	{
	ns->line_pos = line_count+1;
	ns->char_pos = 0;
	}
else
	{
	ns->line_pos = line_count;
	ns->char_pos = line_pos - line_buf;
	}
ns->next = NULL;
if (stail == NULL)
	{
	stail = slist = ns;
	}
else
	{
	stail = stail->next = ns;
	}
code_big(OP_STATEMENT, ns);
}

/* read a single statement - assign, if, print, loop, etc, or a block
   of statements enclosed by braces. */
get_statement()
{
Symbol *avar;
int start, middle, stop;
int vtype;
int lstart, lstop;
int for_step;
char fname[MAX_SYM_LEN];
Statement *st;
int oin_loop;
int ok;

if (got_stop)
	return;
if (got_stop)
	return;
if (need_token())
	{
	if (cttype == TOK_FUNCTION || cttype == TOK_TO)
		{
		get_function();
		}
	else if (cttype == TOK_CREATURE)
		{
		get_creature();
		}
	else if (cttype == TOK_SPAWN)
		{
		add_statement();
		get_spawn();
		code_num(OP_MOVES, (NUMBER)-1);	/* disregarding id of creature */
		}
	else if (cttype == TOK_KILL)
		{
		add_statement();
		if (!eat_token("("))
			return;
		get_iexpress();
		if (got_stop)
			return;
		if (!eat_token(")"))
			return;
		code_void(OP_KILL);
		}
	else if (cttype == TOK_CWRITE)
		{
		add_statement();
		get_cwrite();
		}
	else if (cttype == TOK_EVOLVE)
		{
		add_statement();
		get_evolve();
		}
	else if (cttype == TOK_INT)
		{
		get_int();
		}
	else if (cttype == TOK_STRING)
		{
		get_string();
		}
	else if (cttype == TOK_CONSTANT)
		{
		get_constant();
		}
	else if (cttype == TOK_LOOP)
		{
		add_statement();
		if (!loop_start())
			return;
		lstart = rframe->op_count;
		get_statement();
		loop_end(lstart);
		}
	else if (cttype == TOK_WHILE)
		{
		add_statement();
		if (!loop_start())
			return;
		lstart = rframe->op_count;
		get_iexpress();
		if (got_stop)
			return;
		if (!add_bfixup())			/* and code conditional branch */
			return;
		code_num(OP_CBRA, (NUMBER)-rframe->op_count-1);
		get_statement();
		if (got_stop)
			return;
		loop_end(lstart);
		}
	else if (cttype == TOK_FOR)
		{
		add_statement();
		if (!need_token())
			return;
		if (cttype != TOK_VAR)
			{
			want_variable();
			return;
			}
		avar = csym;
		get_array_ix(avar);
		if (got_stop)
			return;
		if (!need_token())
			return;
		if (cttype != '=')
			{
			expecting_got("=", ctoke);
			return;
			}
		finish_assign(avar);
		if (got_stop)	/* check for error in assignment expression */
			return;
		lstart = rframe->op_count;
		if (!loop_start())
			return;
		if (!need_token())
			return;
		if (cttype != TOK_TO)
			{
			expecting_got("to", ctoke);
			return;
			}
		/* add the conditional branch at beginning of for loop
			checking loop variable against ending value */
		code_arr_var(avar);
		get_iexpress();			/* and end expression */
		if (got_stop)
			return;
		/* now deal with optional step part (assumed 1 if absent) */
		for_step = 1;
		if (next_token())
			{
			if (cttype == TOK_STEP)
				{
				need_token();
				if (cttype == '-')
					{
					need_token();
					for_step = -1;
					}
				if (cttype != TOK_NUM)
					{
					expecting_got("Number", ctoke);
					return;
					}
				for_step *= cint;
				}
			else
				{
				pushback_token();
				}
			}
		if (for_step >= 0)			/* finish (implied) conditional expr */
			{
			code_void(OP_LE);
			}
		else
			{
			code_void(OP_GE);
			}
		if (!add_bfixup())			/* and code conditional branch */
			return;
		code_num(OP_CBRA, (NUMBER)-rframe->op_count-1);
		get_statement();		/* get the body of for */
		/* now add in code at end of for loop to increment loop var. */
		code_arr_var(avar);
		code_num(OP_CON, for_step );
		code_big(OP_ADD);
		code_arr_assign(avar);
		loop_end(lstart);
		}
	else if (cttype == TOK_BREAK)
		{
		add_statement();
		if (!in_loop)
			{
			say_fatal("Break outside of loop");
			return;
			}
		if (!add_bfixup())
			return;
		code_num(OP_BRA, (NUMBER)-rframe->op_count-1);
		}
	else if (cttype == TOK_IF)
		{
		add_statement();
		get_iexpress();
		code_num(OP_CBRA, (NUMBER)0);
		start = rframe->op_count;
		get_statement();
		if (!next_token())
			goto codeif;
		if (cttype == TOK_ELSE)
			{
			code_num(OP_BRA, (NUMBER)0);
			middle = rframe->op_count;
			get_statement();
			stop = rframe->op_count;
			rframe->code_buf[start-1].data.i = middle - start;
			rframe->code_buf[middle-1].data.i = stop - middle;
			}
		else
			{
			pushback_token();
codeif:
			stop = rframe->op_count;
			rframe->code_buf[start-1].data.i = stop - start;
			}
		}
	else if (cttype == TOK_GOTO)
		{
		add_statement();
		need_token();
		if (cttype == TOK_UNDEF)
			{
			if ((csym = new_symbol(ctoke, FLABEL, LOCAL, rframe)) == NULL)
				return;
			cttype = TOK_VAR;
			}
		if (cttype != TOK_VAR)
			{
			want_label();
			return;
			}
		vtype = csym->type;
		if (vtype != LABEL && vtype != FLABEL)
			{
			want_label();
			return;
			}
		code_num(OP_BRA, (NUMBER)csym->symval.i - rframe->op_count - 1);
		if (vtype == FLABEL)
			{
			add_fref(rframe->op_count-1, csym);
			}
		}
	else if (secret_assignment())
		;
	else if (cttype == TOK_VAR)
		{
		add_statement();
		if (csym->type == FUNC || csym->type == FFUNC || csym->type == PREDEF)
			{
			struct func_frame *fuf;

			fuf = csym->symval.p;
			call_func(csym,0,fuf->ret_type);
			}
		else 
			{
			most_of_assignment(csym);
			}
		}
	else if (cttype == TOK_RETURN)
		{
		add_statement();
		if (next_token())
			{
			if (cttype == '(')
				{
				pushback_token();
				ok = get_expression();
				if (got_stop)
					return;
				if (ok != fret_type)
					{
					say_fatal("Returning wrong type");
					type_mismatch(fret_type,ok);
					}
				code_void(OP_END);
				return;
				}
			else
				pushback_token();
			}
		code_big(OP_CON, 0L);	/* return 0 if not explicit */
		code_void(OP_END);
		}
	else if (cttype == TOK_RBRACE)
		{
		add_statement();
		pushback_token();
		return;
		}
	else if (cttype == TOK_LBRACE)
		{
		add_statement();
		get_states();
		if (got_stop)
			return;
		add_statement();
		if (!next_token() || cttype != TOK_RBRACE)
			{
			expecting_got("closing brace", ctoke);
			return;
			}
		}
	else if (cttype == TOK_UNDEF)
		{
		add_statement();
		strcpy(fname, ctoke);
		if (!precall_func(0,INT))
			{
			need_token();
			if (cttype != ':')
				{
				undefined(fname);
				return;
				}
			if ((avar = new_symbol(fname, LABEL, LOCAL, rframe)) == NULL)
				return;
			avar->symval.i = rframe->op_count;
			}
		}
	else
		{
		expecting_got("Statement", ctoke);
		return;
		}
	add_frees();
	}
}

most_of_assignment(avar)
register Symbol *avar;
{
get_array_ix(avar);
if (got_stop)
	return;
need_token();
if (cttype == '=')
	{
	finish_some_assign(avar);
	}
else if (cttype == ':')
	{
	if (avar->type != FLABEL)
		redefined(avar->name);
	avar->symval.i = rframe->op_count;
	avar->type = LABEL;
	}
else
	{
	say_fatal("Expecting a statement");
	}
}

finish_array_ix(avar)
Symbol *avar;
{
char buf[80];

if (avar->elements == 0)
	{
	sprintf(buf, "%s not an array", avar->name);
	say_fatal(buf);
	return;
	}
get_iexpress();
code_num(OP_CHECK, (NUMBER)avar->elements);
if (got_stop)
	return;
if (!next_token() || cttype != ']')
	{
	expecting_got("]", ctoke);
	return;
	}
}

array_ix(avar)
Symbol *avar;
{
if (cttype == '[')
	{
	finish_array_ix(avar);
	}
else
	{
	if (avar->elements != 0)
		say_fatal("Array without an index");
	else
		pushback_token();
	}
}

get_array_ix(avar)
Symbol *avar;
{
if (!need_token())
	return;
array_ix(avar);
}


finish_assign(avar)
Symbol *avar;
{
if (avar->type != INT)
	{
	say_fatal("Expecting an integer assignment");
	return;
	}
finish_some_assign(avar);
}

finish_some_assign(avar)
Symbol *avar;
{
char buf[80];
int ok;

ok = get_expression();
switch (ok)
	{
	case INT:
	case STRING:
		if (ok != avar->type)
			{
			say_fatal("Type mismatch in = statement"); 
			}
		else
			{
			code_arr_assign(avar);
			}
		avar->assigned = 1;
		break;
	case BAD:
		break;
	default:
		sprintf(buf, "= %s ?????", avar->name);
		say_fatal(buf);
		break;
	}
}

loop_start()
{
register struct break_frame *bfx;

if ((bfx = (struct break_frame *)beg_zero(sizeof(*bfx))) == NULL)
	return(0);
bfx->next = bfix_frame;
bfix_frame = bfx;
in_loop++;
return(1);
}

loop_end(lstart)
int lstart;
{
register struct break_frame *bfx;

code_num(OP_BRA, (NUMBER)lstart - rframe->op_count - 1);
--in_loop;
bfx = bfix_frame;
bfixup(rframe->op_count);
bfix_frame = bfx->next;
free_list(bfx->fixes);
freemem(bfx);
}


need_constant()
{
struct pogo_op *op;

get_iexpress();	/* code up an expression */
if (got_stop)
	return(0);
op = rframe->code_buf + rframe->op_count - 1;	
if (op->type != OP_CON)	/* make sure it was a constant expression */
	{
	say_fatal("Expecting a numerical constant");
	return(0);
	}
rframe->op_count -= 1;
return(op->data.i);
}

get_constant()
{
Symbol *ns;

for (;;)
	{
	if (!need_token())
		break;
	if (cttype != TOK_UNDEF)
		{
		redefined(ctoke);
		return;
		}
	if ((ns = new_symbol(ctoke, CONSTANT, 
		(rframe == global_frame ? GLOBAL : LOCAL), rframe)) == NULL)
		return;
	if (!eat_token("="))
		{
		expecting_got("=", ctoke);
		return;
		}
	ns->symval.i = need_constant();
	if (got_stop)
		return;
	if (!next_token())
		return;
	if (cttype != ',')
		{
		pushback_token();
		break;
		}
	}
}

/* declare a string valued variable */
get_string()
{
get_new_var(STRING);
}

/* declare an integer valued variable */
get_int()
{
get_new_var(INT);
}

get_new_var(type)
int type;
{
int count = 0;
struct pogo_op *op;
Symbol *ns;
int elements;

for (;;)
	{
	if (!next_token())
		{
		if (count == 0)
			want_variable();
		return;
		}
	if (cttype == TOK_VAR)
		{
		redefined(ctoke);
		return;
		}
	if (cttype != TOK_UNDEF)
		{
		if (count == 0)
			want_variable();
		return;
		}
	if ((ns = new_symbol(ctoke, type, 
		(rframe == global_frame ? GLOBAL : LOCAL), rframe)) == NULL)
		return;
	if (!next_token())
		return;
	ns->doff = rframe->dcount;	/* reserve space */
	if (cttype == '[')	/* it's an array, yay! */
		{
		get_iexpress();
		op = rframe->code_buf + rframe->op_count - 1;
		if (op->type != OP_CON)
			{
			say_fatal("Array dimension must be constant");
			return;
			}
		elements = op->data.i;
		if (elements <= 0)
			{
			say_fatal("Array dimension must be positive");
			return;
			}
		rframe->op_count -= 1;	/* clear constant from code stream */
		ns->elements = elements;
		rframe->dcount += elements;	/* reserve space */
		if (!need_token())
			return;
		if (cttype != ']')
			{
			expecting_got("]", ctoke);
			return;
			}
		}
	else
		{
		rframe->dcount += 1;	/* reserve space */
		pushback_token();
		}
	if (!next_token())
		return;
	if (cttype != ',')
		{
		pushback_token();
		return;
		}
	}
}

