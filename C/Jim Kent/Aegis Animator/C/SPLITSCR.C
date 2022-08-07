
overlay "wtools"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\acts.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"

extern Script *rclone_script();

/**
	split_script

pass in sequence to split, where to split, and two pointers to where
to put the two halves.  It eats the start_seq.
**/

split_script(start_seq, split_ix, seq1pt ,seq2pt )
struct s_sequence *start_seq;
WORD split_ix;
struct s_sequence **seq1pt, **seq2pt;
{
Script *seq1, *seq2;
WORD **acts,*act;
WORD i,j;
Script **children;
struct poly_list *poly_list;
struct poly **polys;
struct tween *first_tween, *old_mid_tween;
long duration;

extern WORD *act_from_poly();
extern struct item_list *remake_raster_list();


#ifdef DEBUG
ldprintf("split_script()\n");
#endif DEBUB

loop_around_script(start_seq);
seq1 = (struct s_sequence *)clone_structure( start_seq,
	sizeof(struct s_sequence) );
seq1->next_poly_list = empty_poly_list();
seq1->tween_alloc = seq1->tween_count = split_ix;
seq1->tween_list = seq1->next_tween = (struct tween **)
	clone_structure(start_seq->tween_list,
	split_ix * sizeof(struct tween *) );

poly_list = empty_poly_list();

i = split_ix;
while (--i >= 0)
	{
	end_frame(poly_list, *(start_seq->next_tween), start_seq);
	start_seq->next_tween++;
	}

free_poly_list(start_seq->next_poly_list);
free_n_unlink_rasters(start_seq->script_rasters);

old_mid_tween = *(start_seq->next_tween++);
first_tween = (struct tween *)clone_structure( old_mid_tween,
	sizeof(struct tween) );
first_tween->act_count = old_mid_tween->act_count + poly_list->count+1;
acts = first_tween->act_list = (WORD **)
	alloc( first_tween->act_count * sizeof(WORD *) );

*(acts++) = act = (WORD *)alloc( (MAXCOL * 3 + 5) * sizeof(WORD) );
act[0] = MAXCOL*3 + 5;
act[1] = INIT_COLORS;
act[2] = -1;  /*  dummy "poly" number  */
act[3] = 0;
act[4] = MAXCOL;
copy_structure( poly_list->cmap, act+5, MAXCOL*3 * sizeof(WORD));
/*make up color map init for second half*/
#ifdef NEVER
#endif NEVER

i = poly_list->count;
polys = poly_list->list;
duration = script_duration(seq1);
for( i = 0; i< poly_list->count; i++)
	{
	*(acts++) = act = act_from_poly( *(polys++), i, seq1);

	if (act[1] == INSERT_STRIP)
		{
		register Script *kid;
		long d;

		kid = start_seq->child_scripts[ act[3] ];
		d = ((duration - kid->start_time)*kid->speed+16)>>5;
		d += kid->forward_offset;
		d %= script_duration(kid);
		act[10] = d/10000;
		act[11] = d%10000;
		}
	}
copy_structure( old_mid_tween->act_list,  acts,
	old_mid_tween->act_count * sizeof(WORD *) );
free_poly_list(poly_list);

mfree( old_mid_tween->act_list, old_mid_tween->act_count *
	sizeof(WORD *) );
mfree( old_mid_tween, sizeof(struct tween) );

seq2 = (struct s_sequence *)clone_structure( start_seq,
	sizeof(struct s_sequence) );
seq2->name = clone_string(seq2->name);
seq2->next_poly_list = empty_poly_list();
seq2->tween_alloc = seq2->tween_count = 
	start_seq->tween_count - seq1->tween_count;
seq2->tween_list = seq2->next_tween = (struct tween **)
	clone_structure(start_seq->tween_list + seq1->tween_count,
	seq2->tween_count * sizeof(struct tween *) );
*(seq2->tween_list) = first_tween;

/*both halfs of script get full child list just cause I'm lazy and all
  it does is waste a little dynamic memory... */
clone_kids(seq2, 0, 0);

mfree(start_seq->tween_list, start_seq->tween_alloc * sizeof(struct tween *) );
mfree(start_seq, sizeof(struct s_sequence) );

seq2->script_rasters = remake_raster_list(seq2);
link_script_rasters(seq2);
seq1->script_rasters = remake_raster_list(seq1);
link_script_rasters(seq1);

tween_poly_list(seq1);
m_frame(seq1);
*seq1pt = seq1;
fix_tween_times(seq2);
tween_poly_list(seq2);
m_frame(seq2);
*seq2pt = seq2;
}

