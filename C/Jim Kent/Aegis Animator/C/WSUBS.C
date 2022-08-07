
overlay "wtools"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\control.h"
#include "..\\include\\menu.h"
#include "..\\include\\story.h"

extern Item_list *remake_raster_list();
extern VIRTUAL_INPUT *advance_story_board();

sorry_no_mem()
{
ldprintf("sorry - not enough memory\n");
}

which_story(story_ix,vis)
WORD *story_ix;
struct virtual_input *vis;
{
struct story *story;
WORD i;
WORD x,y;

x = vis->curx;
y = vis->cury;

story = story_board;
for ( i=0; i<STORY_COUNT; i++)
	{
	if ( x>= story->x_min_pos && x< story->x_max_pos 
	&& y  >= story->y_min_pos && y < story->y_max_pos)
	break;
	story++;
	}
if (i>=STORY_COUNT)
	return(0);
else
	{
	*story_ix = i;
	return(1);
	}
}


extern struct s_sequence *merge_script(), *splice_script();
extern struct s_sequence *cursor_sequence;
extern WORD **expand_act_list();
extern struct point center_point;

extern struct menu anim_m;
extern WORD cur_sequ_ix;



wkill(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
WORD i;
struct s_sequence *story;
WORD story_ix;

new_cursor(&kill_cursor);
bottom_line("pendown over strip to kill");

for(;;)
	{
	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}

	if ( which_story(&story_ix, vis) )
	{
	free_s_sequence(story_board[story_ix].sequence );
	story = (struct s_sequence *)
		make_empty_script();
	story_board[story_ix].sequence = story;
	make_story_frame( &story_board[story_ix]);
	}
	}
}


wactivate(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct story *st;
WORD story_ix;

new_cursor(&breplay_cursor);
bottom_line("pendown to start/stop strip");

for(;;)
	{
	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}

	if ( which_story(&story_ix, vis) )
	story_board[story_ix].is_active ^= 1;
	startup_story_board();
	}
}

wsplice(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct s_sequence *seq1, *seq2, *new_seq;
WORD seq1_ix, seq2_ix;
extern WORD see_beginning;

#ifdef DEBUG
lprintf("wsplice()\n");
#endif DEBUG

for(;;)
	{
	bottom_line("splice - pendown to pick up strip");
	new_cursor(&splice_cursor);

	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}

	if (!which_story(&seq1_ix, vis) )
	break;

	bottom_line("pendown on strip to splice onto");
	seq1 = story_board[seq1_ix].sequence;
	if ( seq1->tween_count <= 0)
	break;
	/*
	new_cursor(seq1);
	*/

	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}
	if (!which_story(&seq2_ix, vis) )
	break;
	seq2 = story_board[seq2_ix].sequence;
	new_seq = splice_script(seq2,seq1);
	if (new_seq)
	{
	free_s_sequence( story_board[seq2_ix].sequence );
	adjust_pos_in_tween(new_seq, see_beginning);
	story_board[seq2_ix].sequence = new_seq;
	startup_story_board();
	}
	else
	sorry_no_mem();
	}
}


#ifdef NEVER
wclone(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct s_sequence *seq1, *seq2, *new_seq;
WORD seq1_ix, seq2_ix;
extern struct cursor overlay_cursor;
#ifdef DEBUG
lprintf("wclone()\n");
#endif DEBUG

for(;;)
	{
	new_cursor(&overlay_cursor);

	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}

	if (!which_story(&seq1_ix, vis) )
	break;
	seq1 = story_board[seq1_ix].sequence;
	/*
	new_cursor(seq1);
	*/

	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}
	if (!which_story(&seq2_ix, vis) )
	break;
	seq2 = story_board[seq2_ix].sequence;
	new_seq = merge_script(seq1,seq2);
	free_s_sequence( story_board[seq2_ix].sequence );
	story_board[seq2_ix].sequence = new_seq;
	startup_story_board();
	}
}
#endif NEVER

wscissors(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
struct s_sequence *seq1, *seq2, *start_seq;
WORD seq1_ix, seq2_ix;
WORD next_tween_ix;
extern struct cursor scissors_cursor;
extern struct s_sequence *clone_s_sequence();
extern WORD see_beginning;

#ifdef DEBUG
lprintf("wscissors()\n");
#endif DEBUG

for(;;)
	{
	bottom_line("pendown on strip to cut");
	new_cursor(&scissors_cursor);

	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}

	if (!which_story(&seq1_ix, vis) )
	break;
	start_seq = story_board[seq1_ix].sequence;
	if (start_seq->tween_count <= 0)
	return;

	next_tween_ix = start_seq->next_tween - start_seq->tween_list;

	start_seq = clone_s_sequence(start_seq);
	if (start_seq)
	{
	split_script(start_seq, next_tween_ix, &seq1, &seq2);
	bottom_line("pick place to put down 2nd half");

	/*
	new_cursor(seq2);
	*/

	for(;;)
		{
		vis = advance_story_board();
		if (in_menu(m,vis))
		{
		free_s_sequence( seq1 );
		free_s_sequence( seq2 );
		reuse_input();
		return;
		}
		if ( vis->result == CANCEL )
		{
		free_s_sequence( seq1 );
		free_s_sequence( seq2 );
		return;
		}
		if (pjstdn(vis) )
			break;
		}
	if (!which_story(&seq2_ix, vis) )
		{
		free_s_sequence( seq1 );
		free_s_sequence( seq2 );
		return;
		}
	else
		{
		free_s_sequence( story_board[seq2_ix].sequence );
		adjust_pos_in_tween(seq2, see_beginning);
		story_board[seq2_ix].sequence = seq2;

		free_s_sequence( story_board[seq1_ix].sequence );
		adjust_pos_in_tween(seq2, see_beginning);
		story_board[seq1_ix].sequence = seq1;
		}
	startup_story_board();
	}
	else
	sorry_no_mem();
	}
}

extern int morph_menu();
wedit(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
WORD i;
struct s_sequence *story;
WORD story_ix;
extern struct cursor into_cursor;

new_cursor(&into_cursor);

for(;;)
	{
	for(;;)
	{
	vis = advance_story_board();
	if (in_menu(m,vis))
		{
		reuse_input();
		return;
		}
	if ( vis->result == CANCEL )
		return;
	if (pjstdn(vis) ) break;
	}

	if ( which_story(&story_ix, vis) )
	{
	extern struct menu morph_m;

	cur_sequ_ix = story_ix;
	goto_morph_menu();
	return;
	}
	}
}

