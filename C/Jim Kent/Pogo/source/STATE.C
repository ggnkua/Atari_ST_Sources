
#define BREAKKEY 11779
#define DUMPKEY 8196

#include <stdio.h>
#include "pogo.h"
#include "dlist.h"

extern union pt_int *cr_data[];
extern int active_frame;
extern int debug_statements;
extern struct func_frame *strace[RMAX];
extern int in_graphics;

dump_state(code, stack, lvars)
struct pogo_op *code;
union pt_int *stack;
union pt_int *lvars;
{
union pt_int *data;
int i;
int c;
int oig;

oig = in_graphics;
to_text();
printf("Dumped ... cur_pid = %d\n", cur_pid);
if (cur_pid != 0)
	{
	data = cr_data[cur_pid];
	printf("creature type %s\n", data[CNAME].p);
	}
puts("");
for (i=0; i<active_frame; i++)
	{
	puts(strace[i]->name);
	}
if (debug_statements)
	{
	puts("Current statement:");
	print_last_statement(code);
	}
puts("<cont>C to exit, any other key to continue");
for (;;)
	{
	c = console();
	switch (c)
		{
		case 0:
			break;
		case BREAKKEY:
			quit();
			break;
		default:
			if (oig)
				to_graphics();
			return(0);
		}
	}
}

