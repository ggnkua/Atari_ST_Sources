overlay "wtools"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\acts.h"
#include "..\\include\\poly.h"

extern Script *rclone_script();

static
offset_insert_strips(tween, offset)
Tween *tween;
WORD offset;
{
register WORD **acts, *act;
register WORD i;

i =  tween->act_count;
acts = tween->act_list;
while (--i >= 0)
	{
	act = *acts++;
	if (act[1] == INSERT_STRIP)
	act[3] += offset;
	}
}

struct s_sequence *
splice_script(seq1,seq2)
struct s_sequence *seq1, *seq2;
{
register WORD seq1_poly_count;
struct s_sequence *both;
register WORD i,j;
struct tween *tween, *tween1, *tween2;
struct tween **tweens, **tweens1, **tweens2;
register WORD **acts, *act;
register WORD **acts2, *act2;
extern Tween *clone_tween();
extern Script *clone_s_sequence();
extern Item_list *remake_raster_list();
 
/*deal with simple cases here to make life a little easier */
if (seq1->tween_count <= 0)
	return( clone_s_sequence(seq2) );
if (seq2->tween_count <= 0)
	return( clone_s_sequence(seq1) );

both = (struct s_sequence *)clone_structure(&generic_sequence, sizeof(Script) );

if (!both)
	{
#ifdef PARANOID
	printf("ss oops 0\n");
#endif PARANOID
	return(NULL);
	}

both->name = clone_string(seq1->name);
both->tween_count = both->tween_alloc = 
	seq1->tween_count + seq2->tween_count;
both->next_tween = both->tween_list = (struct tween **)
	alloc(both->tween_count * sizeof(struct tween *) );
both->local_time = 0;

/*block to take care of child scripts */	
	{
	register WORD i;
	register Script **s, **d, *child;

	both->child_count = seq1->child_count + seq2->child_count;
	both->child_scripts = d 
	= (Script **)alloc(both->child_count * sizeof(Script *) );
	s = seq1->child_scripts;
	i = seq1->child_count;
	while (--i >= 0)
	{
	child = *d++ = rclone_script(*s++, 1, 0);
	}
	s = seq2->child_scripts;
	i = seq2->child_count;
	while (--i >= 0)
	{
	child = *d++ = rclone_script(*s++, 1, 0);
	}
	}

if (both->tween_count > 0 && !both->next_tween)
	{
	mfree( both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 1\n");
#endif PARANOID
	return(NULL);
	}

tweens = both->tween_list;
tweens1 = seq1->tween_list;
tweens2 = seq2->tween_list;
seq1_poly_count = 0;

i = seq1->tween_count;
while (--i >= 0)
	{
	tween1 = *(tweens1++);
	seq1_poly_count += poly_balance(tween1);
	tween = clone_tween( tween1 , 1);
	if (!tween)
	{
	i = seq1->tween_count - i - 1;
	while (--i >= 0)
		fr_tween( *(--tweens) );
	mfree(both->tween_list, both->tween_count * sizeof(Tween *) );
	mfree(both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 2\n");
#endif PARANOID
	return(NULL);
	}
	*(tweens++) = tween;
	}

tween2 = *(tweens2++);
tween = (struct tween *)clone_structure(tween2, sizeof(struct tween) );
if (!tween)
	{
	i = seq1->tween_count;
	while (--i >= 0)
	fr_tween( *(--tweens) );
	mfree(both->tween_list, both->tween_count * sizeof(Tween *) );
	mfree(both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 3\n");
#endif PARANOID
	return(NULL);
	}
/*so far have finished with first sequence */


/*now will start second sequence, but first tween includes acts to kill all
  polygons in first sequence */
tween->tweening = (long)tween->tweening * seq1->speed/seq2->speed;
tween->act_count = seq1_poly_count + tween2->act_count;
acts = tween->act_list = (WORD **)alloc( tween->act_count * sizeof(WORD *) );
if (!acts)
	{
	mfree(tween, sizeof(Tween) );
	i = seq1->tween_count;
	while (--i >= 0)
	fr_tween( *(--tweens) );
	mfree(both->tween_list, both->tween_count * sizeof(Tween *) );
	mfree(both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 4\n");
#endif PARANOID
	return(NULL);
	}

j = seq1_poly_count;
while (--j >= 0)
	{
	act = (WORD *) alloc( lof_type(KILL_POLY)
	* sizeof(WORD) );
	if (!act)
	{
	j = seq1_poly_count - j - 1;
	while (--j >= 0)
		free_tube( *(--acts) );
	mfree( acts, tween->act_count * sizeof(WORD *) );

	mfree(tween, sizeof(Tween) );
	i = seq1->tween_count;
	while (--i >= 0)
		fr_tween( *(--tweens) );
	mfree(both->tween_list, both->tween_count * sizeof(Tween *) );
	mfree(both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 5\n");
#endif PARANOID
	return(NULL);
	}
	*(act) = lof_type(KILL_POLY);
	*(act+1) = KILL_POLY;
	*(act+2) = j;
	*acts++ = act;
	}
acts2 = tween2->act_list;
j = tween2->act_count;
while (--j>=0)
	{
	act2 = *(acts2++);
	act = (WORD *)clone_structure( act2, *act2 * sizeof(WORD));
	if (!act)
	{
	j = tween->act_count - j - 1;
	while (--j >= 0)
		free_tube( *(--acts) );
	mfree( acts, tween->act_count * sizeof(WORD *) );

	mfree(tween, sizeof(Tween) );
	i = seq1->tween_count;
	while (--i >= 0)
		fr_tween( *(--tweens) );
	mfree(both->tween_list, both->tween_count * sizeof(Tween *) );
	mfree(both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 6\n");
#endif PARANOID
	return(NULL);
	}
	*acts++ = act;
	}
tween->poly_list = empty_poly_list();
offset_insert_strips(tween, seq1->child_count);
*(tweens++) = tween;

i = seq2->tween_count - 1;
while (--i >= 0 )
	{
	tween2 = *(tweens2++);
	tween = clone_tween( tween2, 1 );
	if (!tween)
	{
	i = both->tween_count - i - 1;
	while (--i >= 0)
		fr_tween( *(--tweens) );
	mfree(both->tween_list, both->tween_count * sizeof(Tween *) );
	mfree(both, sizeof(Script) );
#ifdef PARANOID
	printf("ss oops 7\n");
#endif PARANOID
	return(NULL);
	}
	tween->tweening = (long)tween->tweening * seq1->speed/seq2->speed;
	offset_insert_strips(tween, seq1->child_count);
	*(tweens++) = tween;
	}
fix_tween_times(both);
tween_poly_list(both);

if (seq1->script_rasters || seq2->script_rasters)
	{
	if (!(both->script_rasters = remake_raster_list(both) ) )
	{
	free_s_sequence(both);
#ifdef PARANOID
	printf("ss oops 8\n");
#endif PARANOID
	return(NULL);
	}
	link_script_rasters(both);
	}
if ( !(both->next_poly_list = empty_poly_list() )  )
	{
	free_s_sequence(both);
#ifdef PARANOID
	printf("ss oops 9\n");
#endif PARANOID
	return(NULL);
	}
return(both);
}




