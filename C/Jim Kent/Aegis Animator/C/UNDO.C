

overlay "vsupport"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"
#include "..\\include\\menu.h"

extern struct s_sequence *cur_sequence;
extern Script *uclone_s_sequence();
extern struct slider gauge_sl;
extern struct BitMap *bbm;
extern char *bbm_name;
extern long mem_free;




struct s_sequence *back_sequence = NULL;

WORD mem_for_undo = 1;

mem_rejoice()
{
WORD i;

i = 5;
while (--i >= 0)
	{
	bottom_line("Yea, lots of memory, enabling undo!");
	wait(100);
	}
}

save_undo()
{
long guess_mem_needed;
static no_hassle = 5;

#ifdef DEBUG
printf("save_undo()\n");
lsleep(1);
#endif DEBUG

free_undo();

guess_mem_needed = gauge_sl.scale - mem_free; /*memory used*/
if (bbm)			/*undo doesn't duplicate background*/
	guess_mem_needed -= 40000;  
guess_mem_needed += 10000;  /*this is my guess.  Fraggy factor.*/
if (mem_for_undo)
	{
	if (guess_mem_needed > mem_free && no_hassle < 0)
	{
	mem_for_undo = !no_msv_confirm("Low on memory, disable undo?");
	if (mem_for_undo)
		{
		bottom_line("OK, have it YOUR way...");
		wait(1000);
		no_hassle = 5;
		}
	else
		{
		bottom_line("OK, better save it to disk LOTS!");
		wait(1000);
		}
	}
	--no_hassle;
	}
else
	{
	if (!mem_for_undo && 2*guess_mem_needed < mem_free)
	{
	mem_for_undo = 1;
	mem_rejoice();
	}
	}

if (mem_for_undo)
	{
	back_sequence = uclone_s_sequence(cur_sequence);
	if (!back_sequence)
	ldprintf("\nwarning - no memory for undo");
	}
}

static
free_tpls(s)
Script *s;
{
register Tween **tweens, *tween;
register WORD i;

i = s->tween_count;
tweens = s->tween_list;
while (--i >= 0)
	{
	tween = *tweens++;
	free_poly_list(tween->poly_list);
	tween->poly_list = NULL;
	}
}

swap_undo()
{
struct s_sequence *swapper;
struct poly_list *poly_list;

#ifdef DEBUG
printf("swap_undo()\n");
lsleep(1);
#endif DEBUG

if (mem_for_undo)
	{
	if (back_sequence)
		{
		show_help("restoring from undo buffer");
		/*swap back_sequence into cur_sequence */
		free_tpls(cur_sequence);
		swapper = cur_sequence;
		cur_sequence = back_sequence;
		back_sequence = swapper;
		tween_poly_list(cur_sequence);
		m_frame(cur_sequence);
		}
	}
else
	{
	ok_boss("undo disabled");
	}
}

free_undo()
{
#ifdef DEBUG
printf("free_undo()\n");
lsleep(1);
#endif DEBUG

free_s_sequence(back_sequence);
back_sequence = NULL;
}
