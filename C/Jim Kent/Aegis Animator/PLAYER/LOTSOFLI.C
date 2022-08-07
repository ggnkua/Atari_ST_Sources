

overlay "reader"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\control.h"
#include "..\\include\\color.h"
#include "..\\include\\story.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\menu.h"
#include "..\\include\\acts.h"

#ifdef ATARI
extern int *menu;
#endif ATARI

struct s_sequence *cur_sequence = NULL;
WORD cur_sequ_ix = 0;
WORD story_xoff, story_yoff;


#ifdef EDITOR
attatch_cur_sequence_to_story(st)
struct story *st;
{
WORD i;
extern WORD see_beginning;

#ifdef DEBUG
printf("attatch_cur_sequence_to_story(%lx)\n",st);
lsleep(1);
#endif DEBUG

cur_sequence = st->sequence;

st->sequence = NULL;
cur_sequence->xoff = cur_sequence->yoff = 0;
cur_sequence->xscale = cur_sequence->yscale = SCALE_ONE;
cur_sequence->width = XMAX;
cur_sequence->height = YMAX;
if ( cur_sequence->tween_count == 0)
	make_first_tween(cur_sequence);
adjust_pos_in_tween(cur_sequence, see_beginning);
save_undo();
}
#endif EDITOR

Poly_list *
empty_poly_list()
{
register Poly_list *plist;

plist = (Poly_list *)clone_structure(&grc_poly_list, sizeof(Poly_list) );
plist->cmap = (struct color_def *)clone_structure(usr_cmap,
	MAXCOL * sizeof(struct color_def) );
return(plist);
}

Script *
make_empty_script()
{
register Script *ss;

ss = (Script *)
	clone_structure(&generic_sequence, sizeof(Script) );
ss->next_poly_list = empty_poly_list();
return(ss);
}

make_first_tween(ss)
Script *ss;
{
struct tween *tween;
WORD *act;
extern struct n_slider tween_sl;
extern struct tween *m_insert_colors();
extern WORD *make_act();
extern WORD see_beginning;


ss->next_tween = ss->tween_list = (struct tween **)
	alloc(sizeof (struct tween *));
tween = (Tween *)
	clone_structure(&grc_tween, sizeof (struct tween));
tween->poly_list = empty_poly_list();
#ifdef EDITOR
act = make_act(REMOVE_BACKGROUND, -2, 0, 0, 0);
if (act)
	add_act(tween, act);
tween = m_insert_colors(tween,usr_cmap);
#endif EDITOR
*(ss->tween_list) = tween;
#ifdef EDITOR
ss->duration = tween->tweening = tween->stop_time = 
	tween_sl.value;
#endif EDITOR
ss->tween_count = ss->tween_alloc = 1;
startup_sequence(ss);
adjust_pos_in_tween(ss, see_beginning);
}

#ifdef EDITOR
init_lists()
{
struct story *storys;
struct s_sequence *ss;
char **names;
WORD i;

#ifdef DEBUG
lprintf("init_lists()\n");
#endif DEBUG

storys = story_board;
i = STORY_COUNT;

while (--i >= 0)
	{
	ss = make_empty_script();
	storys->sequence =  ss;
	storys++;
	}
}
#endif EDITOR

make_cur_frame(m)
struct menu *m;
{
extern int make_frame();
d_cur_frame(m, make_frame);
}

draw_cur_frame(m)
struct menu *m;
{
extern int see_seq();
d_cur_frame(m, see_seq);
}

extern struct menu morph_m;
struct menu *dissa_menu = &morph_m;

redraw_all()
{
draw_cur_frame(dissa_menu);
put_cmap(usr_cmap);
}

WORD in_story_mode = FALSE;
d_cur_frame(m, funct)
struct menu *m;
int (*funct)();
{
#ifdef DEBUG
printf("d_cur_frame()\n");
lsleep(1);
#endif DEBUG

#ifdef ATARI
wind_update(1);
#endif ATARI
#ifdef EDITOR
if (in_story_mode)
	startup_story_board();
else
#endif EDITOR
	{
	if (cur_sequence)
	{
	(*funct)(cur_sequence);
	copy_structure(cur_sequence->next_poly_list->cmap, usr_cmap,
		MAXCOL * sizeof(struct color_def) );
	put_cmap(usr_cmap, 0, MAXCOL);
	}
	}
#ifdef EDITOR
#ifdef ATARI
if (in_story_mode)
	see_abar();
else
	see_mbar();
#endif ATARI
plop_front_to_back();
if (m)
	maybe_draw_menu(m);
#endif EDITOR
#ifdef ATARI
wind_update(0);
#endif ATARI
}


