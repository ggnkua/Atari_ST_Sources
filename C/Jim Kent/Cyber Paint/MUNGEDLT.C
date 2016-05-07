

#include "flicker.h"
#include "flicmenu.h"

extern long calc_dlt_size();
extern WORD *make_deltas();
extern WORD *make_literal_xor();

char dirty_file = 0, dirty_frame = 0;
WORD empty_size = 8+16*2;

dirtys()
{
dirty_file = dirty_frame = 1;
}


clean_ram_deltas(screen)
WORD *screen;
{
if (dirty_frame)
	{
	sub_ram_deltas(screen);
	dirty_frame = 0;
	}
}


WORD *
make_lit_deltas(lasts, thiss, buf, size, colormap)
WORD *lasts, *thiss, *buf;
long size;
WORD *colormap;
{
copy_words(colormap, buf, COLORS);
buf += COLORS;
if (size < 32002L+COLORS*sizeof(WORD))
	return(make_deltas(lasts, thiss, buf) );
else
	{
	return(make_literal_xor(lasts, thiss, buf) );
	}
}

long 
calc_lit_dlt_size(a, b)
WORD *a, *b;
{
long size;

size = calc_dlt_size(a, b);
if (size >= 32002L)
	size = 32002L;
size += COLORS*sizeof(WORD);
return(size);
}

add_empties_at_end(count)
WORD count;
{
long length_new;
char **rds;
WORD i;
char *buf;
WORD scmap[COLORS];

if (screen_ct + count > MAX_SCREENS)
	{
	too_many_frames();
	return(0);
	}
length_new = count*empty_size;
if (rd_alloc - rd_count < length_new)
	{
	outta_memory();
	return(0);
	}
copy_words(ram_screens[screen_ct-1], scmap, COLORS);
dirty_file = 1;
copy_lots((char *)ram_dlt-rd_count, (char *)ram_dlt - rd_count - length_new,
	rd_count);
rd_count += length_new;
rds = (char **)ram_screens;
i = screen_ct;
while (--i >= 0)
	*rds++ -= length_new;

buf = (char *)ram_dlt - length_new - empty_size;
/* overwrite last empty frame to refresh color map... and then do count 
   fresh ones...*/

i = count+1;

while (--i >= 0)
	{
	*rds++ = buf;
	empty_frame(buf, scmap);
	buf += empty_size;
	}
screen_ct += count;
}

/* use insert_to_ram_dlt when you know the size of a new frame and it's
   index.  This will rearrange the ram_screens and ram_dlt buffer so
   that all the old stuff is still valid data, and it will return you
   a pointer to the place to stuff your inserted data */
WORD *
insert_to_ram_dlt(size, ix)
long size;
WORD ix;
{
register char **rs;
char *return_buf;
long beginning_offset;
WORD i;


if (screen_ct >= MAX_SCREENS)
	{
	too_many_frames();
	return(NULL);
	}
if (rd_alloc - rd_count < size)
	{
	outta_memory();
	return(NULL);
	}
rs = (char **)(ram_screens+ix);
if (ix == screen_ct+1)
	*rs = (char *)ram_dlt;
return_buf = *rs;
copy_lots((char *)ram_dlt - rd_count, (char *)ram_dlt - rd_count - size,
	pt_to_long(return_buf) - (pt_to_long(ram_dlt) - rd_count));
return_buf -= size;

copy_pointers(rs, rs+1, screen_ct+1-ix);
rs += 1;
i = ix+1;
while (--i >= 0)
	{
	*(--rs) -= size;
	}
rd_count += size;
screen_ct += 1;
return( (WORD *)return_buf);
}

long
size_one_dlt(dlt)
WORD *dlt;
{
WORD i;

i = dlt[COLORS];
if (i == 0xffff)
	{
	return(32002L+COLORS*sizeof(WORD));
	}
else
	return((long)i*3L*sizeof(WORD) + sizeof(WORD)+COLORS*sizeof(WORD) );
}

/* expand2(size) - return a buffer size long for deltas while removing
   this and next deltas */
WORD *
expand2(size)
long size;
{
long osize;
long size_difference;
long beginning_offset;
long size_l, size_n;
char *return_buf;
WORD i;
char **rd;

osize = size_one_dlt(ram_screens[screen_ix]) +
	size_one_dlt(ram_screens[screen_ix+1] );
size_difference = size - osize;
if (rd_alloc - rd_count < size_difference)
	{
	return(NULL);
	}
return_buf = (char *)(ram_screens[screen_ix]);
if (size_difference != 0)
	{
	copy_lots((char *)ram_dlt - rd_count, 
		(char *)ram_dlt - rd_count - size_difference,
		pt_to_long(return_buf) - (pt_to_long(ram_dlt) - rd_count));
	rd = (char **)(ram_screens+screen_ix+1);
	i = screen_ix+1;
	while (--i >= 0)
		{
		*(--rd) -= size_difference;
		}
	}
return_buf -= size_difference;
rd_count += size_difference;
return((WORD *)return_buf);
}


sub_ram_deltas(screen)
WORD *screen;
{
if (!s_ram_deltas(screen))
	{
	outta_memory();
	copy_screen(prev_screen, screen);
	do_deltas(ram_screens[screen_ix], screen);
	return(0);
	}
return(1);
}

/* s_ram_deltas() - substitute ram deltas */
s_ram_deltas(screen)
WORD *screen;
{
long size_l, size_n;
long size, osize;
long size_difference;
long beginning_offset;
WORD *return_buf;
WORD i;
char **rd;
WORD next_cmap[COLORS];

if (screen_ix == 0)
	size_l = empty_size;
else
	size_l = calc_lit_dlt_size(screen, prev_screen);
if (screen_ix == screen_ct-1)
	size_n = empty_size;
else
	size_n = calc_lit_dlt_size(screen, next_screen);
copy_words(ram_screens[screen_ix+1], next_cmap, COLORS);
size = size_l + size_n;
return_buf = expand2(size);
if (return_buf == NULL)
	return(0);
if (screen_ix == 0)
	{
	copy_screen(screen, start_screen);
	empty_frame(return_buf, sys_cmap);
	return_buf += empty_size/sizeof(WORD);
	}
else
	return_buf = make_lit_deltas(screen, prev_screen, return_buf, size_l,
		sys_cmap);
ram_screens[screen_ix+1] = return_buf;
if (screen_ix == screen_ct-1)
	{
	copy_screen(screen, end_screen);
	empty_frame(return_buf, next_cmap);
	}
else
	make_lit_deltas(screen, next_screen, return_buf, size_n,
		next_cmap);
return(1);
}

empty_frame(buf, cmap)
register WORD *buf;
WORD *cmap;
{
copy_words(cmap, buf, COLORS);
buf += COLORS;
*buf++ = 1;
*buf++ = 0;
*buf++ = 0;
*buf++ = 0;
}


add_empty_frame(ix)
WORD ix;
{
register WORD *buf;

dirty_file = 1;
if ((buf = insert_to_ram_dlt((long)empty_size, ix)) == NULL)
	return(0);
empty_frame(buf, sys_cmap);
return(1);
}

empty_ram_dlt()
{
WORD *buf;

buf = ram_dlt-2*empty_size/sizeof(WORD);
rd_count = 2*empty_size;
empty_frame(buf, sys_cmap);
ram_screens[0] = buf;
buf += empty_size/sizeof(WORD);
empty_frame(buf, sys_cmap);
ram_screens[1] = buf;
}

offset_ram_screens(amount)
register long amount;
{
register char **rscr;
register WORD count;

rscr = (char **)ram_screens;
count = screen_ct+1;
while (--count >= 0)
	*rscr++ += amount;
}

do_append()
{
if (!sub_ram_deltas(cscreen))
	return(0);
if (!add_empty_frame(screen_ix+1))
	return(0);
copy_screen(cscreen, prev_screen);
copy_screen(cscreen, uscreen);
screen_ix++;
return(1);
}

do_insert()
{
if (!sub_ram_deltas(cscreen))
	return(0);
if (!add_empty_frame(screen_ix+1))
	return(0);
copy_screen(cscreen, next_screen);
copy_screen(cscreen, uscreen);
return(1);
}

update_next_prev(screen)
WORD *screen;
{
copy_screen(screen, prev_screen);
copy_screen(screen, next_screen);
do_deltas(ram_screens[screen_ix], prev_screen);
do_deltas(ram_screens[screen_ix+1], next_screen);
}

delete_ram_frame(screen)
WORD *screen;
{
long size_new, size_old, size_difference;
char *start_new;
char **rd;
WORD i;
WORD scmap[COLORS];

if (screen_ct < 2)
	{
	_clear_seq();
	return;
	}
if (screen_ix == 0)
	{
	copy_screen(next_screen, start_screen);
	copy_screen(next_screen, prev_screen);
	}
if (screen_ix == screen_ct-1)
	{
	copy_screen(prev_screen, end_screen);
	copy_screen(prev_screen, next_screen);
	}
copy_words(ram_screens[screen_ix+1], scmap, COLORS);
size_old = size_one_dlt(ram_screens[screen_ix]) +
	size_one_dlt(ram_screens[screen_ix+1]);
size_new = calc_lit_dlt_size(next_screen, prev_screen);
size_difference = size_new - size_old;
start_new = (char *)(ram_screens[screen_ix]);
copy_lots((char *)ram_dlt - rd_count, 
	(char *)ram_dlt - rd_count - size_difference,
	pt_to_long(start_new) - (pt_to_long(ram_dlt) - rd_count));
rd = (char **)(ram_screens+screen_ix);
i = screen_ix;
while (--i >= 0)
	{
	*(--rd) -= size_difference;
	}
start_new -= size_difference;
rd_count += size_difference;
copy_pointers(ram_screens+screen_ix+1, 
	ram_screens+screen_ix, screen_ct + 1 - screen_ix-1);
ram_screens[screen_ix] = (WORD *)start_new;
make_lit_deltas(next_screen, prev_screen, start_new, size_new, scmap );
screen_ct -= 1;
if (screen_ix == screen_ct)
	screen_ix -= 1;
copy_screen(next_screen, screen);
put_cmap(ram_screens[screen_ix]);
update_next_prev(screen);
}

d_range(screen)
WORD *screen;
{
WORD swap;
long size_new;
long size_old;
long size_difference;
WORD oscreen_ix;
char *start_new;
char **rd;
WORD i;
WORD scmap[COLORS];

oscreen_ix = screen_ix;
if (range_frames == screen_ct)
	{
	_clear_seq();
	return;
	}
dirty_file = 1;
sub_ram_deltas(screen);
if (stop_frame == screen_ct-1)
	{
	if (start_frame == 0)
		{
		_abs_tseek(0, end_screen);
		copy_words(ram_screens[0], scmap, COLORS);
		}
	else
		{
		_abs_tseek(start_frame-1, end_screen);
		copy_words(ram_screens[start_frame-1], scmap, COLORS);
		}
	}
else
	{
	_abs_tseek(stop_frame+1, next_screen);
	copy_words(ram_screens[stop_frame+1], scmap, COLORS);
	}
if (start_frame == 0)
	{
	_abs_tseek(stop_frame+1, start_screen);
	copy_screen(start_screen, prev_screen);
	}
else
	{
	_abs_tseek(start_frame-1, prev_screen);
	}
if (stop_frame == screen_ct-1)
	{
	copy_screen(prev_screen, next_screen);
	}
size_new = calc_lit_dlt_size(next_screen, prev_screen);
size_old = 0;
for (i=start_frame; i<= stop_frame+1; i++)
	{
	size_old += size_one_dlt(ram_screens[i]);
	}
size_difference = size_new - size_old;
start_new = (char *)(ram_screens[start_frame]);
copy_lots((char *)ram_dlt - rd_count, 
	(char *)ram_dlt - rd_count - size_difference,
	pt_to_long(start_new) - (pt_to_long(ram_dlt) - rd_count));
rd = (char **)(ram_screens+start_frame);
i = start_frame;
while (--i >= 0)
	{
	*(--rd) -= size_difference;
	}
start_new -= size_difference;
rd_count += size_difference;
copy_pointers(ram_screens+stop_frame+1, 
	ram_screens+start_frame, screen_ct + 1 - stop_frame-1);
screen_ct -= range_frames;
ram_screens[start_frame] = (WORD *)start_new;
make_lit_deltas(next_screen, prev_screen, start_new, size_new, scmap );
if (oscreen_ix >= start_frame+1)
	{
	if (oscreen_ix < stop_frame+1)
		oscreen_ix = start_frame;
	else
		oscreen_ix -= range_frames;
	}
if (oscreen_ix < 0)
	oscreen_ix = 0;
if (oscreen_ix >= screen_ct)
	oscreen_ix = screen_ct-1;
abs_tseek(oscreen_ix, screen);
return;
}

delete_ram_range(screen)
WORD *screen;
{
range_start_stop();
d_range(screen);
}

