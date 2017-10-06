
/* Pogo.c - doesn't contain much but the main() routine and some global
   variables.  */

#include <stdio.h>
#include <ctype.h>
#include "pogo.h"


/* frames for compiling */
struct pogo_frame *rframe;
struct pogo_frame *global_frame;

/* break fixup list */
struct break_frame *bfix_frame;

/* list of literal strings */
Names *literals;


/* yer basic error state */
int global_err;
int got_eof;
int got_stop;
int user_abort, run_abort;
int run_time;

/* some things can only be done inside a function */
int in_func;

/* some things only in a loop */
int in_loop;

/* some things in a creature */
int in_creature;


/* should we insert source level debugging stuff into the code stream?? */
int debug_statements;

/* This is where all the subroutines code get's hung after compile */
struct func_frame *ff_list;
struct func_frame *universe_function;



/* our data/evaluation stack */
union pt_int dstack_buf[SSZ];


Symbol *universe_symbol;


extern int randseed;
char tbuf[90];


main(argc, argv)
int argc;
char *argv[];
{
int i;
char *command = NULL;

if (argc < 2)
	{
	puts("Usage: pogo sourcefile");
	exit(0);
	}
else
	{
	debug_statements = 1;
	if (argc > 2)
		{
		command = argv[2];
		if (strcmp(command, "nodump") == 0)
			debug_statements = 0;
		if (strcmp(command, "dump") == 0)
			debug_statements = 1;
		}
	if (init_sys())
		{
		title = argv[1];
		if (!jexists(title))
			{
			sprintf(tbuf, "%s.POG", title);
			if (!jexists(tbuf))
				{
				printf("Couldn't find source file %s, sorry\n", title);
				quit();
				}
			title = tbuf;
			}
		pogo_file(command);
		close_pogo_file();
		}
	quit();
	}
}


quit()
{
cleanup();
exit(0);
}

extern Names *temps[];

pogo_file(command)
char *command;
{
if (!open_pogo_file(title))
	quit();
p_file(command);
close_pogo_file();
if (!global_err)
	{
	printf("%s %d instructions\n\n", title, count_is());
	run_time = 1;
	if (command == NULL)
		{
		if (!check_stack(universe_function))
			return;
		run_ops(universe_function->code, 
			dstack_buf + universe_function->pcount 
			+ universe_function->dcount);
		active_frame--;
		free_nlist(temps[active_frame]);
		temps[active_frame] = NULL;
		}
	else
		dump_code();
	}
if (user_abort)
	{
	to_text();
	puts("Exiting Pogo");
	}
}

/* go compile and run pogo on one file */
p_file(command)
char *command;
{
got_eof = got_stop = global_err = 0;
printf("Compiling %s\n", title);
new_frame();
global_frame = rframe;
if (!init_constants())
	return;
if (!init_predefs())
	return;
if (!init_keywords())
	return;
pogo_func(0);
if (!global_err)
	{
	if ((universe_symbol = new_symbol(" Universe", FUNC, GLOBAL, rframe)) 
		!= NULL)
		{
		if ((universe_function = 
			beg_zero(sizeof(*universe_function))) != NULL)
			{
			universe_symbol->symval.p = (void *)universe_function;
			}
		save_function(universe_symbol, universe_function);
		resolve_funcs();
		alloc_type_alive();
		}
	}
}


/* Code up a function body.  */
pogo_func()
{
get_states();
code_big(OP_CON, 0L);	/* return 0 if not explicit */
code_void(OP_END);
fixup_fref();
}

gentle_free(s)
void *s;
{
if (s != NULL)
	freemem(s);
}

