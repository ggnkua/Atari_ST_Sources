/*******************************************************
 *
 *  a56 - a DSP56001 assembler
 *
 *  Written by Quinn C. Jensen
 *  July 1990
 *
 *******************************************************\

/*
 * Copyright (C) 1990-1994 Quinn C. Jensen
 *
 * Permission to use, copy, modify, distribute, and sell this software
 * and its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and
 * that both that copyright notice and this permission notice appear
 * in supporting documentation.  The author makes no representations
 * about the suitability of this software for any purpose.  It is
 * provided "as is" without express or implied warranty.
 *
 */
static char *Copyright = "Copyright (C) 1990-1994 Quinn C. Jensen";

/*
 *  main.c - The "main" code for the assembler.
 *
 */

#include "a56.h"

#define MAX 1024

int pass;
int error;
extern unsigned long pc;
extern int seg;
BOOL binary_listing = FALSE;
BOOL list_includes = FALSE;
FILE *obj = NULL;
extern BOOL list_on;
BOOL list_on_next = TRUE;
char *alloc();

main(argc,argv)
int argc;
char *argv[];
{
	int i;
	extern char *optarg;
	extern int optind;
	int c;
	char *output_file = "a56.out";
	char *input_file;

	while((c = getopt(argc, argv, "bldo:")) != EOF) switch (c) {
		case 'b':
			binary_listing++;
			break;
		case 'l':
			list_includes++;
			break;
		case 'd':
			ldebug++;
			break;
		case 'o':
			output_file = optarg;
			break;
		case '?':
		default:
			fatal("usage: a56  [-b]  [-l]  [-d]  [-o output-file]  input-file\n");
	}
	input_file = argv[optind++];
	obj = open_write(output_file);

	pc = 0;
	seg = 0;
	pass = 1;
	reset_psects();
	include(input_file);

	pc = 0;
	seg = 0;
	pass = 2;
	reset_psects();
	include(input_file);

	psect_summary();
	dump_symtab();
	fclose(obj);
	printf("errors=%d\n", error);
	return error ? 1 : 0;
}

struct inc inc[MAX_NEST];
int inc_p = 0;
FILE *yyin;

include(file)
char *file;
{
	FILE *fp = open_read(file);

	inc_p++;
	if(inc_p >= MAX_NEST)
		fatal("%s: include nesting too deep\n", file);

	inc[inc_p].file = file;
	inc[inc_p].fp = fp;
	inc[inc_p].line = 1;

	list_on_next = TRUE;
	if(inc_p > 1 && NOT list_includes)
		list_on_next = FALSE;

	yyin = inc[inc_p].fp;
	if(inc_p == 1)
#ifdef FLEX
	{
		static int started = 0;
		if(started)
			yyrestart(yyin);
		else
			started = 1;
		yyparse();
	}
#else
		yyparse();
#endif
}

yywrap()
{
	fclose(inc[inc_p].fp);
	inc_p--;
	list_on = list_on_next = TRUE;
	if(inc_p > 1)
		list_on = list_on_next = FALSE;
	if(inc_p) {
		yyin = inc[inc_p].fp;
		return 0;
	} else {
		return 1;
	}
}

struct n
sym_ref(sym)		/* return symbol value or UNDEF if not defined yet */
char *sym;
{
	struct sym *sp, *find_sym();
	struct n result;

	result.type = UNDEF;

	sp = find_sym(sym);
	if(NOT sp) {
		if(pass == 2) {
			yyerror("%s: undefined symbol", sym);
		}		   
		return result;
	}

	return sp->n;
}

#define HASHSIZE 128

#define HASH(sym) (((sym)[0] ^ sym[1]) % HASHSIZE)

struct sym *symtab[HASHSIZE];

sym_def(sym, type, i, f)
char *sym;
int type;
int i;
double f;
{
	struct sym *sp, **stop, *find_sym();

	if(pass == 1) {
		if(find_sym(sym)) {
			pass = 2;				/* what a kludge */
			yyerror("%s: multiply defined symbol", sym);
			pass = 1;
			return;
		}
		stop = &symtab[HASH(sym)];
		sp = NEW(struct sym);
		sp->next = *stop;
		*stop = sp;
		sp->name = strsave(sym);
		sp->n.type = type;
		if(type == INT)
			sp->n.val.i = i & 0xFFFFFF;
		else
			sp->n.val.f = f;
	} else {
		sp = find_sym(sym);
		if(NOT sp)
			fatal("internal error 304\n");
		if(sp->n.type != type ||
			type == INT && sp->n.val.i != (i & 0xFFFFFF) ||
			type == FLT && sp->n.val.f != f)
			yyerror("%s: assembler phase error", sym);
	}		
}

struct sym *find_sym(sym)
char *sym;
{
	struct sym *sp, **stop;

	stop = &symtab[HASH(sym)];
	for(sp = *stop; sp; sp = sp->next)
		if(strcmp(sp->name, sym) == 0)
			return sp;
		
	return NULL;
}

dump_symtab()
{
	struct sym *sp, **stop;
	int i;

	printf("\n\
Symbol Table\n\
-------------------------------------\n");
/*
SSSSSSSSSSSSSSSS XXXXXX
SSSSSSSSSSSSSSSS DDDDDDDDD.DDDDDDDDDD
*/

	for(i = 0, stop = symtab; i < HASHSIZE; i++, stop++) {
		for(sp = *stop; sp; sp = sp->next) {
			if(sp->n.type == INT)
				printf("%16s %06X\n", sp->name, sp->n.val.i);
			else
				printf("%16s %.10f\n", sp->name, sp->n.val.f);
		}
	}   
}

char *printcode(word)
int word;
{
	static char list[MAX], *lp;
	int i;

	word &= 0xFFFFFF;

	if(binary_listing) {
		sprintf(list, "%06X<", word);
		for(i = 0, lp = &list[7]; i < 24; i++, lp++) {
			*lp = word & 1 << 23 - i ? '1' : '0';
			if(i && i % 4 == 3)
				*++lp = i % 8 == 7 ? ' ' : ',';
		}
		lp[-1] = '>';
		lp[0] = '\0';
	} else {
		sprintf(list, "%06X", word);
	}
	return list;
}

char *spacespace[2] = {
/*P:XXXX_XXXXXX_*/
 "              ",
/*P:XXXX_XXXXXX(XXXX_XXXX_XXXX_XXXX_XXXX_XXXX)_*/
 "                                             "};
char *spaces(n)
int n;
{
	return spacespace[binary_listing ? 1 : 0] + n;
}

extern char segs[];

gencode(seg, pc, word)
int seg, pc, word;
{
	fprintf(obj, "%c %04X %06X\n", segs[seg], pc, word & 0xFFFFFF);
}

char fixbuf[1024];

char *fixstring(s)
char *s;
{
	char *bp = fixbuf;
	int ival;

	while(*s) {
		switch (*s) {
			case '\'':
			case '\"':
				s++;
				break;
			case '\\':
				switch (*++s) {
					case 'b': *bp++ = '\b'; break;
					case 'r': *bp++ = '\r'; break;
					case 'f': *bp++ = '\f'; break;
					case 'n': *bp++ = '\n'; break;
					case 't': *bp++ = '\t'; break;
					case '\\': *bp++ = '\\'; break;
					case '0':
						ival = 0;
						while(*s >= '0' && *s <= '9') {
							ival <<= 3;
							ival += *s++ - '0';
						}
						*bp++ = ival;
						break;
				}
				break;
			default:
				*bp++ = *s++;
				break;
		}
	}
	*bp = '\0';
	return fixbuf;
}

#define ONE 0x4000000

makefrac(s)
char *s;
{
	int frac = 0, div = 1;
	int scale = 1;

	while(*s) {
		switch(*s) {
			case '-':
				scale = -1;
				break;
			case '.':
				div = 10;
				break;
			default:
				frac += (*s - '0') * scale * ONE / div;
				div *= 10;
				break;
		}
		s++;
	}

	return frac + scale * 4 >> 3 & 0xFFFFFF;
}

/***************** psect stuff ************************/

struct psect *ptop = NULL, *cur_psect = NULL;

reset_psects()
{
	struct psect *pp;

	for(pp = ptop; pp; pp = pp->next) {
		pp->pc = pp->bottom;
	}

	set_psect(NULL);
}

psect_summary()
{
	printf("\nSummary of psect usage\n\n");

	printf("\
                 section seg base last top      used       avail    total\n\
-------------------------------------------------------------------------\n");
/*
SSSSSSSSSSSSSSSSSSSSSSSS  X  FFFF FFFF FFFF 99999 100%  99999 100%  99999
*/

	summarize(ptop);	/* do it recursively to place back in order */
	printf("\n");
}

summarize(pp)
struct psect *pp;
{
	int used = pp->pc - pp->bottom;
	int avail = pp->top - pp->pc;
	int of = pp->top - pp->bottom;

	if(pp == NULL)
		return;

	summarize(pp->next);

	printf("%24.24s  %c  %04X %04X %04X %5d %3d%%  %5d %3d%%  %5d\n",
		pp->name, segs[pp->seg], pp->bottom, pp->pc, pp->top,
		used, of ? used * 100 / of : 0, avail, of ? avail * 100 / of : 0,
		of);
}

struct psect *find_psect(name)
char *name;
{
	struct psect *pp;

	for(pp = ptop; pp; pp = pp->next)
		if(strcmp(pp->name, name) == 0)
			return pp;

	return NULL;
}

set_psect(pp)
struct psect *pp;
{
	cur_psect = pp;
}

check_psect(seg, pc)
int seg;
unsigned int pc;
{
	if(cur_psect) {
		if(seg == cur_psect->seg && pc >= cur_psect->bottom && 
			pc <= cur_psect->top) {
			cur_psect->pc = pc;
			return TRUE;
		} else {
			return FALSE;
		}
	} else {
		return TRUE;
	}
}

struct psect *new_psect(name, seg, bottom, top)
char *name;
int seg;
unsigned int bottom, top;
{
	struct psect *pp = find_psect(name);

	if(NOT pp) {
		pp = (struct psect *)alloc(sizeof *pp);
		pp->next = ptop;
		ptop = pp;
		pp->name = strsave(name);
		pp->seg = seg;
		pp->pc = bottom;
	}
	pp->bottom = bottom;
	pp->top = top;

	return pp;
}
