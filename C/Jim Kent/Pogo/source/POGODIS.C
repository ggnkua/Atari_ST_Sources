
/* pogodis.c - The pogo dis-assembler.  Prints out the virtual machine
   code our little pogo compiler produced.  For debugging purposes. */

#include <stdio.h>
#include "pogo.h"

extern int active_frame;
extern struct func_frame *strace[RMAX];


char *op_names[] = {
"OP_CON",
"OP_VAR",
"OP_ADD",
"OP_SUB",
"OP_DIV",
"OP_MUL",
"OP_NEG",
"OP_ASSIGN",
"OP_SPAWN",
"OP_CBRA",
"OP_BRA",
"OP_EQ",
"OP_NE",
"OP_LT",
"OP_GT",
"OP_END",
"OP_FUN",
"OP_EVOLVE",
"OP_MOD",
"OP_BAND",
"OP_BOR",
"OP_BXOR",
"OP_BNOT",
"OP_CALL",
"OP_LNOT",
"OP_LE",
"OP_GE",
"OP_RSHIFT",
"OP_LSHIFT",
"OP_LAND",
"OP_LOR",
"OP_RETRIEVE",
"OP_LVAR",
"OP_LASSIGN",
"OP_ARR",
"OP_LARR",
"OP_AASSIGN",
"OP_LAASSIGN",
"OP_CHECK",
"OP_MOVES",
"OP_PREDEF",
"OP_KILL",
"OP_PCALL",
"OP_PREDEFL",
"OP_PPREDEF",
"OP_CHECKTYPE",
"OP_STATEMENT",
"OP_SVAR",
"OP_LSVAR",
"OP_SARR",
"OP_LSARR",
"OP_SASSIGN",
"OP_LSASSIGN",
"OP_ASASSIGN",
"OP_LASASSIGN",
"OP_FREES",
"OP_CSASSIGN",
"OP_CASASSIGN",
"OP_CALLS",
};

Names *source_lines;
Names *source_tail;

extern char *pget_line();
extern char line_buf[SZTOKE];

read_source()
{
Names *ns;

if (!open_pogo_file(title))
	quit();
if ((ns = beg_mem(sizeof(*ns))) == NULL)
	quit();
source_lines = source_tail = ns;
ns->next = NULL;
ns->name = clone_string("");
while (pget_line(line_buf, sizeof(line_buf)) != NULL)
	{
	if ((ns = beg_mem(sizeof(*ns))) == NULL)
		quit();
	ns->next = NULL;
	ns->name = clone_string(line_buf);
	source_tail = source_tail->next = ns;
	}
close_pogo_file();
}

free_source()
{
Names *next;

while (source_lines != NULL)
	{
	next = source_lines->next;
	freemem(source_lines->name);
	freemem(source_lines);
	source_lines = next;
	}
source_tail = NULL;
}



Names *
name_ix(ix)
int ix;
{
Names *s;

s = source_lines;
while (--ix >= 0)
	{
	s = s->next;
	if (s == NULL)
		break;
	}
return(s);
}

print_statement(s)
Statement *s;
{
Names *n;

if ((n = name_ix(s->line_pos)) != NULL)
	printf("%s %d:\t%s", title, s->line_pos, n->name);
}



pogo_dis(code, count)
struct pogo_op *code;
int count;
{
int i;

for (i=0; i<count; i++)
	{
	if (code->type == OP_STATEMENT)
		{
		print_statement(code->data.p);
		}
	else
		{
		printf("\t%x %12s %8lx %d\n", i, op_names[code->type], code->data.p,
			code->data.i);
		}
	code++;
	}
}

dump_code()
{
struct func_frame *f;

read_source();

f = ff_list;
while (f != NULL)
	{
	puts(f->name);
	pogo_dis(f->code, f->code_size);
	puts("");
	f = f->next;
	}
free_source();
}

#define SLIM 40

print_last_statement(code)
struct pogo_op *code;
{
struct func_frame *cfuf;
struct pogo_op *cbegin;

read_source();
cfuf = strace[active_frame-1];
cbegin = cfuf->code;
while (--code >= cbegin)
	{
	if (code->type == OP_STATEMENT)
		{
		print_statement(code->data.p);
		break;
		}
	}
free_source();
}

