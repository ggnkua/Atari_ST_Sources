
/* express.c - Parse out numerical expressions.  String stuff in stringy.c */

#include "stdio.h"
#include "pogo.h"

get_iexpress()
{
int ok;

ok = get_expression();
if (ok == STRING)
	{
	say_fatal("Expecting number got string");
	}
}

get_expression()
{
int ftype;
struct func_frame *fuf;
int ok;

ok = get_sexpress();
if (ok == UNKNOWN)
	{
	return(get_num_express());
	}
else
	return(ok);
}


/* get a numerical expression */
get_num_express()
{
return(get_logor());
}

need_2num(who,t1,t2)
char *who;
int t1,t2;
{
if (got_stop)
	return(0);
if (t1 != INT || t2 != INT)
	{
	expect_2num("||",t1,t2);
	return(0);
	}
return(1);
}

/* Are we part of a logical or expression? */
get_logor()
{
int t1,t2;

t1 = get_logand();
if (got_stop)
	return(BAD);
for (;;)
	{
	if (next_token())
		{
		if (cttype == TOK_LOR)
			{
			t2 = get_logor();
			if (!need_2num("||",t1,t2))
				return(BAD);
			code_op2(OP_LOR);
			return(INT);
			}
		else
			{
			pushback_token();
			return(t1);
			}
		}
	else
		return(t1);
	}
}

/* Maybe we're in a logical and? */
get_logand()
{
int t1, t2;

t1 = get_lognot();
if (got_stop)
	return;
for (;;)
	{
	if (next_token())
		{
		if (cttype == TOK_LAND)
			{
			t2 = get_logand();
			if (!need_2num("&&",t1,t2))
				return(BAD);
			code_op2(OP_LAND);
			}
		else
			{
			pushback_token();
			return(t1);
			}
		}
	else
		return(t1);
	}
}

/* Logical not - all alone on it's priority level */
get_lognot()
{
int t;

if (need_token())
	{
	if (cttype == '!')
		{
		if ((t = get_lognot()) == INT)
			{
			code_op1(OP_LNOT);
			return(INT);
			}
		else
			{
			want_int(t);
			return(BAD);
			}
		}
	else
		{
		pushback_token();
		return(get_compare());
		}
	}
}

/* All comparisons are same priority.  Don't allow them to chain.  Ie
   no  (a == b == c) expressions (legal but useless in C) */
get_compare()
{
int t1,t2;
char *ts;
int op;

t1 = get_adder();
if (got_stop)
	return(BAD);
if (next_token())
	{
	if (cttype == TOK_EQ || cttype == '=')
		{
		ts = "==";
		op = OP_EQ;
		}
	else if (cttype == TOK_NE)
		{
		ts = "!=";
		op = OP_NE;
		}
	else if (cttype == TOK_LE)
		{
		ts = "<=";
		op = OP_LE;
		}
	else if (cttype == TOK_GE)
		{
		ts = ">=";
		op = OP_GE;
		}
	else if (cttype == '<')
		{
		ts = "<";
		op = OP_LT;
		}
	else if (cttype == '>' )
		{
		ts = ">";
		op = OP_GT;
		}
	else
		{
		pushback_token();
		return(t1);
		}
	t2 = get_adder();
	if (!need_2num(ts,t1,t2))
		return(BAD);
	code_op2(op);
	}
return(t1);
}



/* get adder - next priority binary operations - addition and subtraction,
	and their binary logic equivalents - or, xor. 
   Left to right associativity */
get_adder()
{
int t1,t2;
char *ts;
int op;


t1 = get_factor();
if (got_stop)
	return;
for (;;)
	{
	if (next_token())
		{
		if (cttype == '+')
			{
			op = OP_ADD;
			ts = "+";
			}
		else if (cttype == '-')
			{
			op = OP_SUB;
			ts = "-";
			}
		else if (cttype == '|')
			{
			op = OP_BOR;
			ts = "|";
			}
		else if (cttype == '^')
			{
			op = OP_BXOR;
			ts = "^";
			}
		else
			{
			pushback_token();
			break;
			}
		t2 = get_factor();
		if (!need_2num(ts,t1,t2))
			return(BAD);
		code_op2(op);
		}
	else
		break;
	}
return(t1);
}

/* get factor - highest priority binary operations - multiplication,
   division modulus shifts bitwise ands - left to right associativity */
get_factor()
{
int t1,t2;
char *ts;
int op;

t1 = get_signed_prim();
if (got_stop)
	return;
for (;;)
	{
	if (next_token())
		{
		if (cttype == '*')
			{
			op = OP_MUL;
			ts = "*";
			}
		else if (cttype == '/')
			{
			op = OP_DIV;
			ts = "/";
			}
		else if (cttype == '%')
			{
			op = OP_MOD;
			ts = "%";
			}
		else if (cttype == '&')
			{
			op = OP_BAND;
			ts = "&";
			}
		else if (cttype == TOK_LSHIFT)
			{
			op = OP_LSHIFT;
			ts = "<<";
			}
		else if (cttype == TOK_RSHIFT)
			{
			op = OP_RSHIFT;
			ts = ">>";
			}
		else
			{
			pushback_token();
			break;
			}
		t2 = get_signed_prim();
		if (!need_2num(ts,t1,t2))
			return(BAD);
		code_op2(op);
		}
	else
		break;
	}
return(t1);
}

/* get signed primitive - a primitive with unary plus or minus or
   bitwise not */
get_signed_prim()
{
int t;

if (!need_token())
	return;
if (cttype == '-')
	{
	if ((t = get_signed_prim()) == INT)
		code_op1(OP_NEG);
	else
		want_int(t);
	}
else if (cttype == '+')
	{
	if ((t = get_signed_prim()) != INT)
		want_int(t);
	}
else if (cttype == '~')
	{
	if ((t = get_signed_prim()) == INT)
		code_op1(OP_BNOT);
	}
else
	{
	pushback_token();
	return(get_prim());
	}
return(INT);
}

push_var()
{
Symbol *avar;

avar = csym;
if (next_token())
	array_ix(avar);
if (!got_stop)
	code_arr_var(avar);
if (avar->scope == LOCAL && !in_creature && avar->assigned == 0)
	{
	used_not_assigned(avar->name);
	}
avar->used = 1;
}

/* get primitive - a number, variable, or expression in parenthesis */
get_prim()
{
Symbol *avar;
int t;

if (!need_token())
	return(BAD);
if (ctoke[0] == TOK_LPAREN)
	{
	t = get_expression();
	if (got_stop)
		return(BAD);
	if (!next_token() || ctoke[0] != TOK_RPAREN)
		{
		say_fatal("Missing right parenthesis");
		return(BAD);
		}
	return(t);
	}
if (cttype == TOK_NUM)
	{
	code_num(OP_CON, (NUMBER)cint );
	}
else if (cttype == TOK_VAR)
	{
	if (csym->type == INT)
		{
		push_var();
		}
	else if (csym->type == CONSTANT)
		{
		code_num(OP_CON, (NUMBER)csym->symval.i);
		}
	else if (csym->type == FUNC || csym->type == FFUNC || csym->type == PREDEF)
		call_func(csym, 1, INT);
	else
		{
		want_prim();
		return(BAD);
		}
	}
else if (cttype == TOK_CLOSESTT)
	get_closestt();
else if (cttype == TOK_CREAD)
	get_cread();
else if (cttype == TOK_SPAWN)
	get_spawn();
else if (constant_secret(ctoke))
	;
else if (cttype == TOK_UNDEF)
	{
	char buf[80];

	strcpy(buf, ctoke);
	if (!precall_func(1,INT))
		{
		undefined(buf);
		return(BAD);
		}
	}
else
	{
	want_prim();
	return(BAD);
	}
return(INT);
}


