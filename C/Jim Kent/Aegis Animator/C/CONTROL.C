overlay "menu"


#include <stdio.h>
#include <osbind.h>
#include "..\\include\\lists.h"
#include "..\\include\\control.h"
#include "..\\include\\cursor.h"
#include "..\\include\\menu.h"
#include "..\\include\\font.h"
#include "..\\include\\clip.h"
#include "..\\include\\format.h"
#include "..\\include\\script.h"
#include "..\\include\\story.h"
#include "..\\include\\io.h"


extern int anim_menu(),morph_menu(), vspike(), s_points();
extern long atol();
extern struct menu morph_m, anim_m;
extern WORD glow_on;
extern long mem_free;
extern long ani_mem_alloc;
extern struct cursor grab_cursor;


WORD debug = 0;
char		x_animation;	/* exit paint system flag */

int		(*c_dest)() = morph_menu; /*function in actual control*/

int		(*m_dest)() = morph_menu; /*menu function */
int		(*v_dest)() = vspike; /*"v" function*/

Square terminal_square =
	{
	0, XMAX,
	CHAR_HEIGHT, YMAX,
	};
extern struct rast_font sail_font;

struct control main_control =
	{
	&morph_m,
	NULL,
	NULL,
	};

extern WORD cur_sequ_ix;

WORD cl_replay = 0;
char *title = NULL;


WORD init_depth;
main(argc, argv)
register int argc; 
register char *argv[];
{
int depth;
register WORD i;
register char *string;
struct virtual_input *v;


#ifdef DEBUG
printf("Ani alpha 0\n(c) 1986 Dancing Flame\n");
lsleep(1);
#endif DEBUG

#ifdef LATER
for (i=1; i<argc; i++)
	{
	string = argv[i];
	if (strlen(string) >= 2)
		{
		if (string[0] == '-')
			{
			switch (string[1])
				{
				case 'r':
					cl_replay = 1;
					glow_on = 0;
					break;
				}
			}
		else
			if (!title)
				title = string;
		}
	else
		if (!title)
			title = string;
	}
#endif LATER

init_depth = init_sys();

if (init_depth <= 0)
	{
	ani_cleanup();
	}


#ifdef LATER
if (cl_replay)
	{
	extern Script *ld_scr(), *cur_sequence;
	extern char *dot_script, *cut_suffix();
	char *true_title, *string;

	for (;;)
		{
		for (i=1; i<argc; i++)
			{
			string = argv[i];
			if ( string[0] != '-')
				{
				if (suffix_in(string, dot_script) )
					cur_sequence = ld_scr(string);
				else
					{
					true_title = 
					clone_string(lsprintf("%s%s", string, dot_script));
					cur_sequence = ld_scr(true_title);
					free_string(true_title);
					}
				if (cur_sequence)
					{
					replay_start_end(NULL, NULL, NULL);
					free_s_sequence(cur_sequence);
					v = getcurvis();
					if (v->result & CANCEL)
						goto all_over;
					}
				}
			}
		}
all_over:
	;
	}
else
#endif LATER
	{
	init_lists();
	if (mem_free < 80000)
		{
		ldprintf("WARNING ani's only got %ld bytes", mem_free);
		wait(2500);
		}

	if (title)
		{
		extern struct cursor wait_cursor;
		extern Script *ld_scr();
		Script *ss;
		extern char *dot_script, *cut_suffix();
		char *true_title;

		if (suffix_in(title, dot_script) )
			{
			title = cut_suffix(title, dot_script);
			}
		else
			{
			title = clone_string(title);
			}
		true_title = clone_string(lsprintf("%s%s", title, dot_script));
		new_cursor(&wait_cursor);
		ss = ld_scr(true_title);
		if (ss)
			{
			free_s_sequence(story_board[cur_sequ_ix].sequence);
			story_board[cur_sequ_ix].sequence = ss;
			}
		free_string(true_title);
		}
	else
		title = clone_string("NONAME");

	init_vterm(&terminal_square, 1, &sail_font);

	goto_morph_menu();

	x_animation = 1;
	do	
		{
#ifdef DEBUG
		printf("main_loop:\n\t main_control->(%lx %lx %lx)\n",
			main_control.m, main_control.sel, main_control.vis);
		for (i=0; i<30000; i++) ;
#endif DEBUG


			(*c_dest)(&main_control);	/* call a menu or vroutine */

		}
	while (  x_animation );
	}

ani_cleanup();
return(0);
}
/* exit_to_dos */




