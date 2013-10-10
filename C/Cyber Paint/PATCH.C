
#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

extern char *title;
extern char *file_suffixes[];
extern struct slidepot pmemory_sl, pframes_sl, pstart_sl;
extern struct flicmenu menupatch, menu_save,
	ptc_memory, ptc_frames, ptc_start,
	ptc_lmemory, ptc_lframes, ptc_lstart,
	ptc_rmemory, ptc_rframes, ptc_rstart,
	ptc_load_switch, pd000, ptc_new;
extern long cel_mem_alloc;
extern WORD patch_file_type, save_file_type;
extern feel_number_slider(), inc_slider(), dec_slider();
extern long get_ss_ops(), get_one_ss_ops();
extern long *ss_offsets;
extern Ops_etc *ss_ops;

extern Seq_header ss_h;
extern struct neo_head ss_n;
extern WORD load_fd;



WORD got_patch;
#ifdef SLUFFED
WORD patch_start;
#endif SLUFFED
WORD patch_frames;
char do_patch;
char last_page;
char ss_at_first, ss_at_last;
char patch_name[128];

patch(m)
Flicmenu *m;
{
patch_sub_menu();
}

patch_sub_menu()
{
hide_mouse();
erase_seg(menu_save.y-1, menupatch.y - menu_save.y+1);
pmemory_sl.max  = (cel_mem_alloc>>10);	/* slider in K available */
if (pmemory_sl.value > pmemory_sl.max || pmemory_sl.value < 0)
	pmemory_sl.value = pmemory_sl.max/2;
do_patch = 1;
patch_file_type = SEQ;
draw_a_menu(&menupatch);
show_mouse();
do_menu(&menupatch);
hide_mouse();
draw_a_menu(cur_menu);
show_mouse();
}

#ifdef SLUFFED
change_patch_type(m)
Flicmenu *m;
{
unhi_group(&menupatch, m->group);
*(m->group) = save_file_type = m->identity;
hi_group(&menupatch, m->group);
}
#endif SLUFFED

n_patch()
{
ptc_memory.feelme = ptc_frames.feelme = ptc_start.feelme = feel_number_slider;
ptc_lmemory.feelme = ptc_lframes.feelme = ptc_lstart.feelme = dec_slider;
ptc_rmemory.feelme = ptc_rframes.feelme = ptc_rstart.feelme = inc_slider;
ptc_load_switch.children = &pd000;
}

new_patch()
{
got_patch = 0;
n_patch();
hide_mouse();
white_block(&ptc_load_switch);
draw_sub_menu(&pd000);
draw_sel(&ptc_memory);
draw_sel(&ptc_frames);
show_mouse();
}

add_ss_offs(offs, amount, frames)
register long *offs;
register long amount;
register WORD frames;
{
while (--frames >= 0)
	*offs++ += amount;
}

long
get_new_size(start, stop, frames)
WORD start, stop, frames;
{
WORD seek_first;
long acc;
WORD i;

if ((ss_offsets = (long *)begmem((frames+1)*sizeof(long))) == NULL)
	return(0);
if ((ss_ops = (Ops_etc *)laskmem((frames+1)*(long)sizeof(Ops_etc) )) == NULL)
	{
	freemem(ss_offsets);
	ss_offsets = NULL;
	outta_memory();
	return(0);
	}
seek_first = (ss_at_first ? 0 : start-1);
if (!seq_file_tseek(patch_name, pscreen, -1, seek_first))
	{
	freemem(ss_offsets);
	ss_offsets = NULL;
	freemem(ss_ops);
	ss_ops = NULL;
	return(0);
	}
copy_screen(pscreen, uscreen);	/* get copy of patch files frame - 1 */
ss_offsets[0] = 0;
if (ss_at_first)
	{
	acc = get_one_ss_ops(NULL, start_screen, bscreen, ss_ops);
	}
else
	{
	acc = get_one_ss_ops(pscreen, start_screen, bscreen, ss_ops);
	}
copy_screen(start_screen, pscreen);
for (i=1; i<frames; i++)
	{
	ss_offsets[i] = acc;
	copy_screen(pscreen, prev_screen);
	do_deltas(ram_screens[i], pscreen);
	qput_cmap(ram_screens[i]);
	acc += get_one_ss_ops(prev_screen, pscreen, bscreen, ss_ops+i);
	}
if (!ss_at_last)
	{
	ss_offsets[frames] = acc;
	copy_screen(pscreen, end_screen);	/* just a safe place ... */
	copy_screen(uscreen, pscreen);
	if (!seq_file_tseek(patch_name, pscreen, seek_first, stop))
		{
		freemem(ss_offsets);
		ss_offsets = NULL;
		freemem(ss_ops);
		ss_ops = NULL;
		return(0);
		}
	acc += get_one_ss_ops(end_screen, pscreen, bscreen, ss_ops+frames);
	copy_screen(pscreen, end_screen);
	}
return(acc);
}

checking_dfree(needs, dev)
register long needs;
WORD dev;
{
register long dfree;
long buf[4];
char cbuf[40];

sprintf(cbuf, "checking disk for %ld free bytes", needs);
top_print(cbuf);
Dfree(buf, dev+1);
dfree = buf[0] * buf[2] * buf[3];
if (dfree < needs)
	{
	sprintf(cbuf, "%ld free bytes need %ld", dfree, needs);
	continu_line(cbuf);
	return(0);
	}
else
	return(1);
}

long
find_off_plus_one(frame)
WORD frame;
{
long offset;

/* seek to frame offset */
Fseek((long)(frame)*sizeof(long) + sizeof(ss_h), load_fd, 0);
if ( Fread(load_fd, (long)sizeof(offset), &offset) < sizeof(offset))
	{
	file_truncated(patch_name);
	return(0);
	}
Fseek(offset, load_fd, 0);	/*seek to last frame */
if (!next_seq_neo(patch_name))
	{
	return(0);
	}
offset += sizeof(ss_n) + ss_n.data_size;
return(offset);
}

s_patch()
{
long size_old, size_new;
long start_off, end_off, end_file_off;
Ops_etc op;
WORD i;
WORD end_frame;
long size_diff;
long frames_diff;
long offset_offset;
WORD my_frames;
long *loffsets;
WORD lcount;
WORD success = 0;

nohblanks();
if (!open_verify_seq(patch_name))
	return(0);
clean_ram_deltas(bscreen);
if (ss_h.cel_count < pstart_sl.value + patch_frames + 1)
	{
	continu_line("Patch mismatch! Aborting.");
	goto END_SAVE_PATCH;
	}

ss_at_first = (pstart_sl.value == 0);
ss_at_last = ((patch_frames+1) + pstart_sl.value >= ss_h.cel_count);
/* skip to beginning offset */
Fseek((long)pstart_sl.value * sizeof(long), load_fd, 1);
if ( Fread(load_fd, (long)sizeof(start_off), &start_off) < sizeof(start_off))
	{
	file_truncated(patch_name);
	goto END_SAVE_PATCH;
	}
end_frame = patch_frames + pstart_sl.value+1;
if (ss_at_last)
	end_frame -= 1;
if ((end_off = find_off_plus_one(end_frame)) == 0)
	{
	goto END_SAVE_PATCH;
	}
size_old = end_off - start_off;
if ((size_new = get_new_size(pstart_sl.value,  end_frame, screen_ct)) == 0)
	{
	goto END_SAVE_PATCH;
	}

size_diff = size_new - size_old;
size_diff += (long)(screen_ct - (patch_frames+1))*sizeof(long); 
if (size_diff > 0)
	{
	if (!checking_dfree(size_diff, 
		(patch_name[1] == ':' ? patch_name[0] - 'A' : 0)))
		{
		goto END_SAVE_PATCH;
		}
	}
Fclose(load_fd);
if ((load_fd = Fopen(patch_name, 2)) < 0)
	{
	couldnt_open(patch_name);
	goto END_SAVE_PATCH;
	}
if ((end_file_off = find_off_plus_one((int)ss_h.cel_count-1)) == 0)
	{
	goto END_SAVE_PATCH;
	}
frames_diff = screen_ct - (patch_frames + 1);
if (size_diff != 0)
	{
	if (size_diff > 0)	/* extend file for tos if too small */
		{
		Fseek(end_file_off, load_fd, 0);
		top_print("expanding file");
		if (!bulk_write(load_fd, prev_screen, size_diff))
			{
			file_truncated(patch_name);
			goto END_SAVE_PATCH;
			}
		}
	else
		top_print("shrinking file");
	if (!copy_file(load_fd, end_off, end_file_off - end_off, size_diff ))
		{
		goto END_SAVE_PATCH;
		}
	}
if (frames_diff != 0)
	{
	offset_offset = sizeof(ss_h)+(end_frame+1)*sizeof(long);
	if(!copy_file(load_fd, offset_offset, start_off - offset_offset,
		((long)screen_ct - patch_frames - 1)*sizeof(long)))
		{
		goto END_SAVE_PATCH;
		}
	}
my_frames = screen_ct;
if (!ss_at_last)
	my_frames++;
offset_offset = start_off + frames_diff*sizeof(long);
add_ss_offs(ss_offsets, offset_offset, my_frames);
if (frames_diff != 0)
	{
	Fseek(0L, load_fd, 0);
	Fread(load_fd, (long)sizeof(ss_h), &ss_h);
	ss_h.cel_count += frames_diff;
	Fseek(0L, load_fd, 0);
	Fwrite(load_fd, (long)sizeof(ss_h), &ss_h);
	}
Fseek((long)sizeof(ss_h)+pstart_sl.value*sizeof(long), load_fd, 0);
if (Fwrite(load_fd, (long)my_frames*sizeof(long), ss_offsets ) < 
	(long)my_frames * sizeof(long) )
	{
	file_truncated(patch_name);
	goto END_SAVE_PATCH;
	}
lcount = ss_h.cel_count - (my_frames + pstart_sl.value);
if (size_diff != 0 && lcount > 0)
	{
	if ((loffsets = (long *)begmem(lcount * sizeof(long))) == NULL)
		goto END_SAVE_PATCH;
	if (Fread(load_fd, (long)lcount*sizeof(long), loffsets) < 
		lcount*sizeof(long))
		{
		freemem(loffsets);
		file_truncated(patch_name);
		goto END_SAVE_PATCH;
		}
	add_ss_offs(loffsets, size_diff, lcount);
	Fseek(-(long)lcount*sizeof(long), load_fd, 1);
	if (Fwrite(load_fd, (long)lcount*sizeof(long), loffsets) < 
		lcount*sizeof(long))
		{
		freemem(loffsets);
		file_truncated(patch_name);
		goto END_SAVE_PATCH;
		}
	freemem(loffsets);
	}
Fseek( offset_offset, load_fd, 0);
copy_screen(uscreen, prev_screen);
copy_screen(start_screen, pscreen);
for (i=0; i<screen_ct; i++)
	{
	do_deltas(ram_screens[i], pscreen);
	qput_cmap(ram_screens[i]);
	if (!write_one_frame(load_fd, i, pscreen, patch_name, pstart_sl.value))
		{
		goto END_SAVE_PATCH;
		}
	}
if (!ss_at_last)
	{
	if (!write_one_frame(load_fd, i, end_screen, patch_name, 
		pstart_sl.value))
		{
		goto END_SAVE_PATCH;
		}
	}
success = 1;
dirty_file = 0;
dirty_frame = 0;

END_SAVE_PATCH:
make_end_screen();
abs_tseek(screen_ix, bscreen);
copy_screen(bscreen, uscreen);
if (load_fd >= 0)
	{
	Fclose(load_fd);
	load_fd = -1;
	}
free_ss_o();
n_patch();
return(success);
}

save_patch()
{
WORD success;

got_patch = 0;
jimints_off();
success = s_patch();
jimints_on();
redraw_menu_frame();
return(success);
}

bulk_write(file, pt, count)
WORD file;
register char *pt;
register long count;
{
register long chunk_size;

while (count > 0)
	{
	chunk_size = 32000;
	if (chunk_size > count)
		chunk_size = count;
	if (Fwrite(file, chunk_size, pt) < chunk_size)
		return(0);
	pt += chunk_size;
	count -= chunk_size;
	}
return(1);
}

copy_file(file, start_move, size_move, extra_bytes)
WORD file;
long start_move;
long size_move;
long extra_bytes;
{
register long chunk_size;
long start_off;

if (extra_bytes >= 0)
	{
	while (size_move > 0)
		{
		chunk_size = 32000;
		if (size_move < chunk_size)
			chunk_size = size_move;
		Fseek(start_move + size_move - chunk_size, file, 0);
		if (Fread(file, chunk_size, prev_screen) < chunk_size )
			{
			file_truncated(patch_name);
			return(0);
			}
		Fseek(start_move + size_move - chunk_size + extra_bytes, file, 0);
		if (Fwrite(file, chunk_size, prev_screen) < chunk_size)
			{
			file_truncated(patch_name);
			return(0);
			}
		size_move -= chunk_size;
		}
	}
else
	{
	start_off = start_move;
	while (size_move > 0)
		{
		chunk_size = 32000;
		if (size_move < chunk_size)
			chunk_size = size_move;
		Fseek(start_off, file, 0);
		if (Fread(file, chunk_size, prev_screen) < chunk_size )
			{
			file_truncated(patch_name);
			return(0);
			}
		Fseek(start_off + extra_bytes, file, 0);
		if (Fwrite(file, chunk_size, prev_screen) < chunk_size)
			{
			file_truncated(patch_name);
			return(0);
			}
		size_move -= chunk_size;
		start_off += chunk_size;
		}
	}
return(1);
}

extern char l_seq_end;

l_patch(name)
char *name;
{
WORD osave_file_type;
WORD success = 1;

nohblanks();
osave_file_type = save_file_type;
save_file_type = patch_file_type;
save_file_type = osave_file_type;
rd_frames = pstart_sl.value;
if (l_seq(name, pstart_sl.value,pframes_sl.value+1,
	(pmemory_sl.value+1)*1024L, 1))
	{
	strcpy(rd_name, name);
	strcpy(patch_name, name);
	last_page = l_seq_end;
	patch_frames = screen_ct-1;
#ifdef LATER
	pframes_sl.value = screen_ct-1;
	pmemory_sl.value = (rd_count >> 10);
#endif LATER
	ptc_memory.feelme = ptc_frames.feelme = ptc_start.feelme = 
		ptc_lmemory.feelme = ptc_lframes.feelme = ptc_lstart.feelme = 
		ptc_rmemory.feelme = ptc_rframes.feelme = ptc_rstart.feelme =
		NOFEEL;
	ptc_load_switch.children = &ptc_new;
	dirty_file = 0;
	dirty_frame = 0;
	}
else
	success = 0;
return(success);
}

load_patch(m)
Flicmenu *m;
{
WORD success = 0;

got_patch = 1;
if (!get_title("Load"))
	goto END_LP;
success = l_patch(title);
END_LP:
hide_mouse();
jimints_on();
redraw_menu_frame();
return(success);
}

page_patch()
{
WORD new_first;
WORD success = 0;
WORD savit;

jimints_off();
new_first = pstart_sl.value + screen_ct;
if (dirty_file || strcmp(rd_name, patch_name) != 0)
	{
	if (!s_patch())
		goto end;
	}
pstart_sl.value = new_first;
if (last_page)
	{
	n_patch();
	got_patch = 0;
	}
else
	l_patch(patch_name);
end:
hide_mouse();
jimints_on();
redraw_menu_frame();
return(0);
}


