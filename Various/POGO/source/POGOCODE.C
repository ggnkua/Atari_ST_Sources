
/* Pogocode.c - most of what is done by the run-time pogo interpreter,
   and some little functions used by the code generator.  Also here's
   where we do constant folding for some reason... */

#include <stdio.h>
#include "pogo.h"
#include "dlist.h"


int active_frame;
struct func_frame *strace[RMAX];
Names *temps[RMAX];
int watchdog;

check_stack(fuf)
struct func_frame *fuf;
{
if (active_frame >= RMAX-1)
	{
	runtime_err("Recursion too deep");
	return(0);
	}
strace[active_frame++] = fuf;
return(1);
}

/* Interpret code stream - yer basic software simulated stack based 
   microprocessor */
void *
run_ops(op, ostack)
struct pogo_op *op;
register union pt_int *ostack;
{
register union pt_int *stack;
struct slist *s;
struct func_frame *fuf;
Names *n;
int t;

stack = ostack;
for (;;)
	{
	if (--watchdog <= 0)
		{
		watchdog = 200;
#ifdef LATER
		if (stack < ostack )
			{
			run_abort = 1;
			puts("Stack underflow");
			break;
			}
		if ( stack > dstack_buf+1000)
			{
			run_abort = 1;
			puts("Stack overflow");
			break;
			}
#endif LATER
		check_abort();
		}
	if (user_abort || run_abort)
		{
		if (run_abort || user_abort == 2)
			{
			dump_state(op, stack, ostack);
			user_abort = run_abort = 0;
			}
		if (user_abort == 1)
			return(NULL);
		}
	switch (op->type)
		{
		case OP_CON:	/* push a constant onto data stack */
			stack->p =  op->data.p;
			stack++;
			break;
		case OP_VAR:	/* push a variable onto data stack */
		case OP_SVAR:	/* push a variable onto data stack */
			stack->p = dstack_buf[op->data.i].p;
			stack++;
			break;
		case OP_LVAR:	/* push a local variable onto data stack */
		case OP_LSVAR:
			stack->p = ostack[op->data.i].p;
			stack++;
			break;
		case OP_ARR:	/* put an element of an array onto data stack */
		case OP_SARR:	/* put an element of an array onto data stack */
			stack[-1].p = dstack_buf[op->data.i + stack[-1].i].p;
			break;
		case OP_LARR:	/* put an element of a local array onto stack */
		case OP_LSARR:	/* put an element of a local array onto stack */
			stack[-1].p = ostack[op->data.i + stack[-1].i].p;
			break;
	#ifdef LATER
		case OP_SVAR:	/* push a string variable onto data stack */
			stack->p = dstack_buf[op->data.i].p;
			stack++;
			break;
		case OP_LSVAR:	/* push a local string variable onto data stack */
			s = ostack[op->data.i].p;
			stack->p = s->string;
			stack++;
			break;
		case OP_SARR:	/* put an element of a string array onto data stack */
			s = dstack_buf[op->data.i + stack[-1].i].p;
			stack[-1].p = s->string;
			break;
		case OP_LSARR:	/* put an element of a string array onto data stack */
			s = ostack[op->data.i + stack[-1].i].p;
			stack[-1].p = s->string;
			break;
	#endif LATER
		case OP_ADD:	/* replace top two elements of stack one result */
			stack[-2].i += stack[-1].i;
			stack -= 1;
			break;
		case OP_SUB:	/* replace top two elements of stack one result */
			stack[-2].i -= stack[-1].i;
			stack -= 1;
			break;
		case OP_MUL:	/* replace top two elements of stack one result */
			stack[-2].i *= stack[-1].i;
			stack -= 1;
			break;
		case OP_DIV:	/* replace top two elements of stack one result */
			stack[-2].i /= stack[-1].i;
			stack -= 1;
			break;
		case OP_MOD:	/* replace top two elements of stack one result */
			stack[-2].i %= stack[-1].i;
			stack -= 1;
			break;
		case OP_BOR:	/* replace top two elements of stack with binary or*/
			stack[-2].i |= stack[-1].i;
			stack -= 1;
			break;
		case OP_BAND:	/* replace top two elements with binary and */
			stack[-2].i &= stack[-1].i;
			stack -= 1;
			break;
		case OP_BXOR:	/* replace top two elements with binary xor */
			stack[-2].i ^= stack[-1].i;
			stack -= 1;
			break;
		case OP_LSHIFT: 
			stack[-2].i <<= stack[-1].i;
			stack -= 1;
			break;
		case OP_RSHIFT: 
			stack[-2].i >>= stack[-1].i;
			stack -= 1;
			break;
		case OP_LAND:
			stack[-2].i = stack[-2].i && stack[-1].i;
			stack -= 1;
			break;
		case OP_LOR:
			stack[-2].i = stack[-2].i || stack[-1].i;
			stack -= 1;
			break;
		case OP_NEG:	/* negate top of stack */
			stack[-1].i = -stack[-1].i;
			break;
		case OP_BNOT:	/* binary not top of stack */
			stack[-1].i = ~stack[-1].i;
			break;
		case OP_LNOT:	/* logical not top of stack */
			stack[-1].i = !stack[-1].i;
			break;


		/* String assigns */
		case OP_SASSIGN:	/* global string assignment */
			--stack;
			t = op->data.i;
			gentle_free(dstack_buf[t].p);
			dstack_buf[t].p = clone_string(stack->p);
			break;
		case OP_CSASSIGN:	/* local creature string assignment*/
			--stack;
			t = op->data.i;
			gentle_free(ostack[t].p);
			ostack[t].p = clone_string(stack->p);
			break;
		case OP_LSASSIGN: /* local function string assignment*/
			--stack;
			ostack[op->data.i].p = stack->p;
			break;
		case OP_ASASSIGN:	/* global string array assigment*/
			t = op->data.i + stack[-2].i;
			gentle_free(dstack_buf[t].p);
			dstack_buf[t].p = clone_string(stack[-1].p);
			stack -= 2;
			break;
		case OP_CASASSIGN:	/* creature string array assigment*/
			t = op->data.i + stack[-2].i;
			gentle_free(ostack[t].p);
			ostack[t].p = clone_string(stack[-1].p);
			stack -= 2;
			break;
		case OP_LASASSIGN: /* local string array assignment */
			ostack[op->data.i+stack[-2].i].p = stack[-1].p;
			stack -= 2;
			break;

		case OP_ASSIGN:	/* pop top of stack into a variable */
			--stack;
			dstack_buf[op->data.i].p = stack->p;
			break;
		case OP_LASSIGN: /* pop top of stack into a local variable */
			--stack;
			ostack[op->data.i].p = stack->p;
			break;
		case OP_AASSIGN:	/* pop top of stack into a variable */
			dstack_buf[op->data.i+stack[-2].i].p = stack[-1].p;
			stack -= 2;
			break;
		case OP_LAASSIGN: /* pop top of stack into a local variable */
			ostack[op->data.i+stack[-2].i].p = stack[-1].p;
			stack -= 2;
			break;
		case OP_CHECK:		/* make sure an array ref isn't out of bounds */
			t = stack[-1].i;
			if (t < 0)
				{
				char buf[80];

				sprintf(buf, "Negative array index: %d\n", t);
				runtime_err(buf);
				run_abort = 1;
				}
			else if (t >= op->data.i)
				{
				char buf[80];

				to_text();
				puts("Array index too large");
				sprintf(buf, "Index %d, max %d\n", t, op->data.i-1);
				runtime_err(buf);
				run_abort = 1;
				}
			break;
		case OP_RETRIEVE:	 /* move top of stack elsewhere in stack */
							/* generated save return value... */
			t = op->data.i;
			stack[t-1].p = stack[-1].p;
			stack += t;
			break;
		case OP_CBRA:	/* pop top of stack and branch if zero */
			--stack;
			if (!stack->i)
				{
				op += op->data.i;
				}
			break;
		case OP_BRA:	/* unconditional branch */
			op += op->data.i;
			break;
		case OP_EQ:		/* pop top 2 el's of stack and push EQ result */
			stack[-2].i = (stack[-2].i == stack[-1].i);
			stack -= 1;
			break;
		case OP_NE:		/* pop tow 2 el's of stack and push NE result */
			stack[-2].i = (stack[-2].i != stack[-1].i);
			stack -= 1;
			break;
		case OP_GT:
			stack[-2].i = (stack[-2].i > stack[-1].i);
			stack -= 1;
			break;
		case OP_LT:
			stack[-2].i = (stack[-2].i < stack[-1].i);
			stack -= 1;
			break;
		case OP_GE:
			stack[-2].i = (stack[-2].i >= stack[-1].i);
			stack -= 1;
			break;
		case OP_LE:
			stack[-2].i = (stack[-2].i <= stack[-1].i);
			stack -= 1;
			break;
		case OP_END:	/* finished instruction stream */
			/* return top of stack */
			return(stack[-1].p);
		case OP_CALLS:	/* call string function pointer */
			fuf = op->data.p;
			if (!check_stack(fuf))
				break;
			--active_frame;
			add_cr_string(stack->p = clone_string(run_ops(fuf->code,stack+1)));	
			if (temps[active_frame] != NULL)
				{
				free_nlist(temps[active_frame]);
				temps[active_frame] = NULL;
				}
			stack++;
			break;
		case OP_CALL:	/* call integer function */
			fuf = op->data.p;
			if (!check_stack(fuf))
				break;
			stack->p = run_ops(fuf->code, stack+1);	
			--active_frame;
			if (temps[active_frame] != NULL)
				{
				free_nlist(temps[active_frame]);
				temps[active_frame] = NULL;
				}
			stack++;
			break;
		case OP_PCALL:	/* call function no return value */
			fuf = op->data.p;
			if (!check_stack(fuf))
				break;
			run_ops(fuf->code, stack+1);	
			--active_frame;
			if (temps[active_frame] != NULL)
				{
				free_nlist(temps[active_frame]);
				temps[active_frame] = NULL;
				}
			break;
		case OP_PPREDEF:	/* call 'C' function no ret value */
			{
			typedef int func();
			func *f;

			f = (func *)op->data.p;
			(*f)(stack);
			}
			break;
		case OP_PREDEF:	/* call 'C' function on top of stack */
			{
			typedef int func();
			func *f;

			f = (func *)op->data.p;
			stack->i = (*f)(stack);
			stack++;
			}
			break;
		case OP_PREDEFL:	/* call 'C' function on top of stack */
			{
			typedef long lfunc();
			lfunc *f;

			f = (lfunc *)op->data.p;
			stack->l = (*f)(stack);
			stack++;
			}
			break;
		case OP_MOVES:	/* move data stack pointer */
			stack += op->data.i;
			break;
		case OP_SPAWN:	/* go spawn a new creature */
			stack[-5].i = go_spawn(stack);
			stack -= 4;
			break;
		case OP_EVOLVE: /* evolve creatures... */
			go_evolve(stack);
			break;
		case OP_KILL:
			--stack;
			go_kill(stack->i);
			break;
		case OP_STATEMENT:	/* statement ops don't do anything... */
			break;
		case OP_FREES:
			clear_frees();
			break;
		}
	op++;
	}
}

/* make sure have enough code space */
check_cspace()
{
if (rframe->op_count >= CSZ - 1)  /* some extra space for folding routines*/
	{
	say_fatal("Out of code space");
	return(0);
	}
return(1);
}

/* insert code with pointer data */
code_big(type, p)
int type;
void *p;
{
register struct pogo_op *cs;

if (check_cspace())
	{
	cs = rframe->code_buf+rframe->op_count;
	cs->type = type;
	cs->data.p = p;
	rframe->op_count++;
	}
}

/* insert code with integer data */
code_num(type, con)
int type;
NUMBER con;
{
register struct pogo_op *cs;

if (check_cspace())
	{
	cs = rframe->code_buf+rframe->op_count;
	cs->type = type;
	cs->data.p = NULL;
	cs->data.i = con;
	rframe->op_count++;
	}
}

code_void(type)
int type;
{
register struct pogo_op *cs;

if (check_cspace())
	{
	cs = rframe->code_buf+rframe->op_count;
	cs->type = type;
	cs->data.p = NULL;
	rframe->op_count++;
	}
}

/* try to merge a unary operator with a constant */
fold1()
{
struct pogo_op *code;
union pt_int estack[3];
void *result;

code = rframe->code_buf + rframe->op_count - 2;
if (code->type == OP_CON)
	{
	code[2].type = OP_END;
	result = run_ops(code, estack);
	code->data.p = result;
	rframe->op_count -= 1;
	}
}

code_op1(type)
int type;
{
code_void(type);
fold1();
}



/* try to merge two constants and a binary operator into a single constant*/
fold2()
{
struct pogo_op *code;
union pt_int estack[4];
void *result;

code = rframe->code_buf + rframe->op_count - 3;
if (code[0].type == OP_CON && code[1].type == OP_CON)
	{
	code[3].type = OP_END;
	result = run_ops(code, estack);
	code->data.p = result;
	rframe->op_count -= 2;
	}
}


code_op2(type)
int type;
{
code_void(type);
fold2();
}


code_arr_var(v)
Symbol *v;
{
int element;

if (v->elements == 0)
	code_var(v);
else
	{
	switch (v->scope)
		{
		case GLOBAL:
			if (v->type == STRING)
				code_num(OP_SARR, (NUMBER)v->doff);
			else if (v->type == INT)
				code_num(OP_ARR, (NUMBER)v->doff);
			break;
		case LOCAL:
			if (v->type == STRING)
				code_num(OP_LSARR, (NUMBER)v->doff);
			else if (v->type == INT)
				code_num(OP_LARR, (NUMBER)v->doff);
			break;
		}
	}
}

code_var(v)
Symbol *v;
{
switch (v->scope)
	{
	case GLOBAL:
		if (v->type == STRING)
			code_num(OP_SVAR, v->doff);
		else if (v->type == INT)
			code_num(OP_VAR, (NUMBER)v->doff);
		break;
	case LOCAL:
		if (v->type == STRING)
			code_num(OP_LSVAR, v->doff);
		else if (v->type == INT)
			code_num(OP_LVAR, (NUMBER)v->doff);
		break;
	}
}

code_arr_assign(v)
Symbol *v;
{
if (v->elements == 0)
	code_assign(v);
else
	{
	switch (v->scope)
		{
		case GLOBAL:
			if (v->type == STRING)
				code_num(OP_ASASSIGN, (NUMBER)v->doff);
			else if (v->type == INT)
				code_num(OP_AASSIGN, (NUMBER)v->doff);
			break;
		case LOCAL:
			if (v->type == STRING)
				{
				if (in_creature)
					code_num(OP_LASASSIGN, (NUMBER)v->doff);
				else
					code_num(OP_CASASSIGN, (NUMBER)v->doff);
				}
			else if (v->type == INT)
				code_num(OP_LAASSIGN, (NUMBER)v->doff);
			break;
		}
	}
}

code_assign(v)
Symbol *v;
{
switch (v->scope)
	{
	case GLOBAL:
		if (v->type == STRING)
			code_num(OP_SASSIGN, (NUMBER)v->doff);
		else if (v->type == INT)
			code_num(OP_ASSIGN, (NUMBER)v->doff);
		break;
	case LOCAL:
		if (v->type == STRING)
			{
			if (in_creature)
				code_num(OP_CSASSIGN, (NUMBER)v->doff);
			else
				code_num(OP_LSASSIGN, (NUMBER)v->doff);
			}
		else if (v->type == INT)
			code_num(OP_LASSIGN, (NUMBER)v->doff);
		break;
	}
}

/* returns TYPE of last code ... (to see if it's constant maybe... */
top_op()
{
return(rframe->code_buf[rframe->op_count-1].type);
}

