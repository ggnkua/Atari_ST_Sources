
overlay "player"

#include <std..\\include\\io.h>
#include "..\\include\\lists.h"

#ifdef PLAYER

#include "..\\include\\format.h"
#include "..\\include\\io.h"
#include "..\\include\\script.h"


WORD glow_on = FALSE;
WORD perspective = TRUE;
WORD see_beginning = FALSE;
char dot_script[] = ".script";
char dot_pic[] = ".pic";
char dot_win[] = ".win";
char dot_msk[] = ".msk";

extern long mem_free;
extern struct	name_list		*file_lst;


char		x_animation;	/* exit paint system flag */


WORD cl_replay = 0;
char *title = NULL;
struct name_list *cl_words = NULL;

extern WORD in_wb;

WORD init_depth;
main(argc, argv)
int argc;
char *argv[];
{
struct virtual_input *vis;
int i;
Script *script;
char buf[108];

cope_workbench();

init_depth = init_sys();
if (init_depth <= 0)
	{
	uninit_sys(init_depth);
	return(-1);
	}

if (argc <= 1 || in_wb)
	{
	struct name_list *nl;

	init_file_linked_list();
	for (;;)
		{
		nl = file_lst;
		while (nl)
			{
			if (suffix_in(nl->name, dot_script))
				{
				if ( cur_sequence = ld_scr(nl->name) )
					{
					replay_start_end(NULL, NULL, NULL);
					vis = getcurvis();
					if (cancel(vis))
						goto end_show;
					free_s_sequence(cur_sequence);
					}
				}
			nl = nl->next;
			vis = getinput();
			if (cancel(vis))
				goto end_show;
			}
		vis = getinput();
		if (cancel(vis))
			goto end_show;
		}
	}
else if (argc == 2)
	{
	suffix_opt(buf, argv[1], dot_script);
	if (cur_sequence = ld_scr(buf) )
		{
		for (;;)
			{
			replay_start_end(NULL, NULL, NULL);
			vis = getcurvis();
			if (cancel(vis))
				goto end_show;
			}
		}
	}
else
	{
	for (;;)
		{
		for (i=1; i<argc; i++)
			{
			suffix_opt(buf, argv[i], dot_script);
			if (cur_sequence = ld_scr(buf) )
				{
				replay_start_end(NULL, NULL, NULL);
				vis = getcurvis();
				if (cancel(vis))
					goto end_show;
				free_s_sequence(cur_sequence);
				}
			}
		}
	}
end_show:
uninit_sys(init_depth);
return(0);
}
/* exit_to_dos */
#endif PLAYER




