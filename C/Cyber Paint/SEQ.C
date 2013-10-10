
#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"


extern struct slidepot speed_sl;



long *ss_offsets = NULL;
Ops_etc *ss_ops = NULL;
long ss_off_size;	/* sizeof ss_offsets */
long ss_cel_words;
Cel ss_cel;
Seq_header ss_h;
struct neo_head ss_n;

long 
get_one_ss_ops(lasts, thiss, bufs, op)
WORD *lasts, *thiss, *bufs;
register Ops_etc *op;
{
long this_size = 0;
long unc_size;
long xor_size;
long comp_size;

word_zero(op, sizeof(Ops_etc)/sizeof(WORD) );
if (find_clip(thiss))
	{
	op->width = ss_cel.width = x_1-x_0;
	op->height = ss_cel.height = y_1-y_0;
	op->xoff = ss_cel.xoff = x_0;
	op->yoff = ss_cel.yoff = y_0;
	ss_cel_words = this_size = unc_size = 
		Raster_block((long)ss_cel.width, ss_cel.height);
	ss_cel_words >>= 1; 
	ss_cel.image = bufs;
	zero_screen(bufs);
	untwist_clip_from_screen(&ss_cel, thiss);
	comp_size = calc_compress_length(bufs, ss_cel_words)<<1;
	if (this_size > comp_size)
		{
		op->compress = NEO_CCOLUMNS;
		this_size = comp_size;
		}
	if (lasts != NULL)	/* first frame always neo_copy */
		{
		xor_screen(thiss, lasts);	
		if (find_clip(lasts))
			{
			ss_cel.width = x_1-x_0;
			ss_cel.height = y_1-y_0;
			ss_cel.xoff = x_0;
			ss_cel.yoff = y_0;
			zero_screen(bufs);
			untwist_clip_from_screen(&ss_cel, lasts);
			ss_cel_words = 
				Raster_block((long)ss_cel.width, ss_cel.height)>>1;
			xor_size = 
				calc_compress_length(bufs, ss_cel_words)<<1;
			}
		else
			xor_size = 0;	
				/* whoopie... this picture same as last... */
		if (this_size > xor_size)
			{
			op->op = NEO_XOR;
			if (xor_size == 0)
				{
				op->width = op->height = op->xoff 
					= op->yoff = 0;
				}
			else
				{
				op->compress = NEO_CCOLUMNS;
				op->width = ss_cel.width;
				op->height = ss_cel.height;
				op->xoff = ss_cel.xoff;
				op->yoff = ss_cel.yoff;
				}
			this_size = xor_size;
			}
		}
	op->size = this_size;
	}
return(this_size + sizeof(ss_n));
}

long 
get_seg_ss_ops(skip_start, start_frame, stop_frame, frame_count, dir)
WORD skip_start;
WORD start_frame, stop_frame, frame_count, dir;
{
register long acc;
WORD i;
WORD *lscreen;
WORD count;

clean_ram_deltas(bscreen);	/* save changes have made already to this
							frame */

/* first do some pre-calculations.  Find out how much disk space it will
   take, and while we're at it make up offsets table, so file can be
   used with random access to cels later */
if ((ss_offsets = (long *)begmem(frame_count*sizeof(long))) == NULL)
	{
	return(0);
	}
if ((ss_ops = (Ops_etc *)begmem(frame_count*sizeof(Ops_etc))) == NULL)
	{
	freemem(ss_offsets);
	ss_offsets = NULL;
	return(0);
	}
acc = sizeof(Seq_header);	
ss_off_size = frame_count;
ss_off_size *= 4;
acc += ss_off_size;	
i = start_frame;
abs_tseek(start_frame, pscreen);
for (count=0; count<frame_count; count++)
	{
	ss_offsets[count] = acc;
	if (i == start_frame)
		{
		if (!skip_start)
			acc += get_one_ss_ops(NULL, pscreen, bscreen, ss_ops+count);
		}
	else
		acc += get_one_ss_ops(prev_screen, pscreen, bscreen, 
			ss_ops+count);
	copy_screen(pscreen, prev_screen);
	i += dir;
	if (i < 0 || i >= screen_ct)
		break;
	if (dir > 0)
		do_deltas(ram_screens[i], pscreen);
	else
		do_deltas(ram_screens[i+1], pscreen);
	qput_cmap(ram_screens[i]);
	}
return(acc);
}

#ifdef SLUFFED
long
get_ss_ops(skip_start)
WORD skip_start;
{
register long acc;
WORD i;
WORD *lscreen;


clean_ram_deltas(bscreen);	/* save changes have made already to this
							frame */

/* first do some pre-calculations.  Find out how much disk space it will
   take, and while we're at it make up offsets table, so file can be
   used with random access to cels later */
if ((ss_offsets = (long *)begmem(range_frames*sizeof(long))) == NULL)
	{
	return(0);
	}
if ((ss_ops = (Ops_etc *)begmem(range_frames*sizeof(Ops_etc))) == NULL)
	{
	freemem(ss_offsets);
	ss_offsets = NULL;
	return(0);
	}
acc = sizeof(Seq_header);	
ss_off_size = range_frames;
ss_off_size *= 4;
acc += ss_off_size;	
abs_tseek((start_frame==0 ? 0 : start_frame-1), pscreen);
for (i=start_frame; i<=stop_frame; i++)
	{
	ss_offsets[i-start_frame] = acc;
	/* ops default to nothing uncompressed etc */
	do_deltas(ram_screens[i], pscreen);
	qput_cmap(ram_screens[i]);
	if (i == start_frame)
		{
		if (!skip_start)
			acc += get_one_ss_ops(NULL, pscreen, bscreen, ss_ops+i-start_frame);
		}
	else
		acc += get_one_ss_ops(prev_screen, pscreen, bscreen, 
			ss_ops+i-start_frame);
	copy_screen(pscreen, prev_screen);
	}
return(acc);
}
#endif SLUFFED

free_ss_o()
{
gentle_free(ss_offsets);
ss_offsets = NULL;
gentle_free(ss_ops);
ss_ops = NULL;
}

save_seq(name)
char *name;
{
int i;
WORD success = 0;
register WORD fd = -1;
WORD start_frame, stop_frame;
WORD frame_count, count;
WORD dir;
WORD oscreen_ix;


oscreen_ix = screen_ix;
dir = 1;
if (select_mode == 1) /* range mode */
	{
	start_frame = trange.v1-1;
	stop_frame = trange.v2-1;
	frame_count = stop_frame - start_frame;
	if (start_frame > stop_frame)
		{
		frame_count = -frame_count;
		dir = -1;
		}
	frame_count += 1;
	}
else
	{
	start_frame = 0;
	stop_frame = screen_ct-1;
	frame_count = screen_ct;
	}
if (!get_seg_ss_ops(0, start_frame, stop_frame, frame_count, dir))
	{
	goto done_sseq;
	}
Fdelete(name);
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	goto done_sseq;
	}
word_zero(&ss_h, sizeof(ss_h)/sizeof(WORD) );
ss_h.magic =  0xfedb;	/* write magic number */
ss_h.version = 0;		/* well start at zero I guess */
ss_h.cel_count = frame_count;
ss_h.speed = (speed_sl.value+1)*100;

/* write out header */
if (Fwrite(fd, (long)sizeof(ss_h), &ss_h) < sizeof(ss_h) )
	{
	file_truncated(name);
	goto done_sseq;
	}

/* write out offsets */
if (Fwrite(fd, ss_off_size, ss_offsets) < ss_off_size)
	{
	file_truncated(name);
	goto done_sseq;
	}

/* pre-init neo header */
word_zero(&ss_n, sizeof(ss_n)/sizeof(WORD) );
ss_n.type = -1;

i = start_frame;
abs_tseek(start_frame, pscreen);
for (count=0; count<frame_count; count++)
	{
	copy_words(sys_cmap, ss_n.colormap, 16);
	if (!write_one_frame(fd, count, pscreen, name, 0))
		goto done_sseq;
	i += dir;
	if (i < 0 || i >= screen_ct)
		break;
	if (dir > 0)
		do_deltas(ram_screens[i], pscreen);
	else
		do_deltas(ram_screens[i+1], pscreen);
	qput_cmap(ram_screens[i]);
	}
success = 1;	/* whew, made it! */

done_sseq:
free_ss_o();
if (fd >= 0)
	Fclose(fd);
abs_tseek(oscreen_ix, bscreen);
return(success);
}

write_one_frame(fd, i, screen, name, ioff)
WORD fd;
WORD i;
WORD *screen;
char *name;
WORD ioff;
{
ss_n.slide_time = 10;
ss_n.data_size = ss_ops[i].size;
ss_n.compress = ss_ops[i].compress;
ss_n.op = ss_ops[i].op;
sprintf(ss_n.filename, "FLICKERS.%d", i+ioff);
ss_cel.width = ss_n.width = ss_ops[i].width;
ss_cel.height = ss_n.height = ss_ops[i].height;
ss_cel.xoff = ss_n.xoff = ss_ops[i].xoff;
ss_cel.yoff = ss_n.yoff = ss_ops[i].yoff;
if ( Fwrite(fd, (long)sizeof(ss_n), &ss_n) < sizeof(ss_n) )
	{
	file_truncated(name);
	return(0);
	}
if (ss_ops[i].size != 0)
	{
	zero_screen(bscreen);
	if (ss_ops[i].op == NEO_XOR)
		{
		xor_screen(screen, prev_screen);	/* xor with previous screen */
		clip_from_screen(&ss_cel, prev_screen);
		}
	else
		clip_from_screen(&ss_cel, screen);

	if (ss_ops[i].compress == NEO_CCOLUMNS)
		{
		untwist(ss_cel.width, ss_cel.height, bscreen, next_screen);
		ss_cel_words = Raster_block((long)ss_cel.width, ss_cel.height)>>1;
		word_compress(next_screen, bscreen, ss_cel_words);
		}
	if (Fwrite(fd, ss_n.data_size, bscreen) < ss_n.data_size)
		{
		file_truncated(name);
		return(0);
		}
	}
copy_screen(screen, prev_screen);
return(1);
}

extern long get_err_d0(), get_err_d7();

load_more_seq()
{
return(l_seq(rd_name, rd_frames, MAX_SCREENS, rd_alloc, 0) );
}

load_seq(name)
char *name;
{
rd_frames = 0;
strcpy(rd_name, name);
l_seq(name, 0, MAX_SCREENS, rd_alloc, 0);
}

WORD load_fd;

open_verify_seq(name)
char *name;
{
if ((load_fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	return(0);
	}
if ( Fread(load_fd, (long)sizeof(ss_h), &ss_h) < sizeof(ss_h) )
	{
	file_truncated(name);
	goto BADEXIT;
	}
if (ss_h.magic != 0xfedc && ss_h.magic != 0xfedb)
	{
	bad_magic();
	goto BADEXIT;
	}
return(1);
BADEXIT:
Fclose(load_fd);
load_fd = -1;
return(0);
}

next_seq_neo(name)
char *name;
{
if (abort_load())
	{
	rd_abort = 1;
	return(0);
	}
if ( Fread(load_fd, (long)sizeof(ss_n), &ss_n) < sizeof(ss_n) )
	{
	file_truncated(name);
	return(0);
	}
if (ss_n.type != -1)
	{
	top_line("bad cel magic");
	return(0);
	}
if (ss_n.compress == NEO_UNCOMPRESSED)
	ss_n.data_size = Raster_block(ss_n.width, (long)ss_n.height);
return(1);
}

char l_seq_end;

l_splice(name, xoff, yoff)
char *name;
{
register WORD i;
long est_mem;
long rd_free;
WORD success = 0;
WORD *buf;
char nomem = 0;
long dlt_size;
WORD *rd_start;
WORD start = 0;
WORD screens = MAX_SCREENS;
long mem_to_use = rd_alloc;

clean_ram_deltas(bscreen);
if ( !open_verify_seq(name) )
	goto end_lseq;
Fseek( ss_h.cel_count * sizeof(long), load_fd, 1);	
	/* skip past the offset lists */
ss_cel.image = bscreen;	/* use buffer for something decent! */
ss_cel.mask = NULL;
/* get pointer to start of compression area */
rd_start = ram_dlt - rd_alloc/sizeof(WORD);
/* move existing images to start */
copy_lots((char *)ram_dlt - rd_count, rd_start, rd_count);
offset_ram_screens(rd_count - rd_alloc);
/* point buf to first free space */
buf = rd_start + rd_count/sizeof(WORD) - empty_size/sizeof(WORD);
/* previous screen is last current screen */
copy_screen(end_screen, prev_screen);
for (i=0; i<ss_h.cel_count; i++)
	{
	if (screen_ct >= screens)
		goto end_loops;
	ram_screens[screen_ct] = buf;
	if (!next_seq_neo(name) )
		goto end_loops;
	if (ss_n.data_size > 0)
		{
		ss_cel.width = ss_n.width;
		ss_cel.height = ss_n.height;
		ss_cel.xoff = ss_n.xoff;
		ss_cel.yoff = ss_n.yoff;
		ss_cel.image_size = Raster_block(ss_n.width, (long)ss_n.height);
		if (ss_n.compress == NEO_CCOLUMNS)
			{
			if (ss_n.data_size > 32000)
				{
				mangled(name);
				goto end_loops;
				}
			if (Fread(load_fd, ss_n.data_size, next_screen) < ss_n.data_size)
				{
				file_truncated(name);
				goto end_loops;
				}
			word_uncompress(next_screen,  bscreen, ss_n.data_size>>1);
			}
		else
			{
			if (Fread(load_fd, ss_cel.image_size, bscreen) < ss_cel.image_size)
				{
				file_truncated(name);
				goto end_loops;
				}
			}
		if (ss_n.op != NEO_XOR )
			{
			clear_screen();
			if (ss_n.compress == NEO_CCOLUMNS)
				twist_copy_celblit(xoff, yoff, &ss_cel);
			else
				copy_celblit(xoff, yoff, &ss_cel);
			}
		else
			{
			if (ss_n.compress == NEO_CCOLUMNS)
				twist_xor_celblit(xoff, yoff, &ss_cel);
			else
				xor_celblit(xoff, yoff, &ss_cel);
			}
		}
	else
		{
		if (ss_n.op != NEO_XOR )
			clear_screen();
		}
	qput_cmap(ss_n.colormap);
	rd_free = mem_to_use - rd_count - empty_size;
	if ( (dlt_size=calc_lit_dlt_size(pscreen, prev_screen)) <= rd_free)
		{
		buf = make_lit_deltas(pscreen, prev_screen, buf, dlt_size,
			ss_n.colormap);
		}
	else
		{
		nomem = 1;
		rd_more = 1;
		goto end_loops;
		}
	rd_count = pt_to_long(buf) - pt_to_long(rd_start);
	screen_ct++;
	copy_screen(pscreen, prev_screen);
	}
end_loops:
copy_screen(prev_screen, end_screen);
empty_frame(buf, sys_cmap);
ram_screens[screen_ct] = buf;
rd_count += empty_size;
buf += empty_size/sizeof(WORD);
rd_count = pt_to_long(buf) - pt_to_long(rd_start);
copy_lots(rd_start, (char *)ram_dlt - rd_count, rd_count);
offset_ram_screens(rd_alloc - rd_count);
screen_ix = screen_ct-1;
copy_screen(end_screen, pscreen);
copy_screen(end_screen, bscreen);
copy_screen(end_screen, uscreen);
update_next_prev(bscreen);
success = 1;

end_lseq:
if (load_fd >= 0)
	Fclose(load_fd);
return(success);
}

l_seq(name, start, screens, mem_to_use, patch)
char *name;
WORD start;
WORD screens;
long mem_to_use;
WORD patch;
{
register WORD i;
long est_mem;
long rd_free;
WORD success = 0;
WORD *buf;
char nomem = 0;
long dlt_size;
WORD *rd_start;
WORD empty;

l_seq_end = 0;
if (mem_to_use > rd_alloc)
	mem_to_use = rd_alloc;
if ( !open_verify_seq(name) )
	goto end_lseq;
Fseek( ss_h.cel_count * sizeof(long), load_fd, 1);	
	/* skip past the offset lists */
if (ss_h.cel_count > screens + start)
	{
	rd_more = 1;
	}
if (ss_h.speed != 0)
	{
	speed_sl.value = ss_h.speed/100-1;
	clip_slider(&speed_sl);
	}
ss_cel.image = bscreen;	/* use buffer for something decent! */
ss_cel.mask = NULL;
screen_ix = screen_ct = 0;
rd_start = buf = ram_dlt - rd_alloc/sizeof(WORD);
rd_count = 0;
for (i=0; i<ss_h.cel_count; i++)
	{
	if (screen_ct >= screens)
		goto end_loops;
	empty = 0;
	ram_screens[screen_ct] = buf;
	if (!next_seq_neo(name) )
		goto end_loops;
	qput_cmap(ss_n.colormap);
	if (ss_n.data_size > 0)
		{
		ss_cel.width = ss_n.width;
		ss_cel.height = ss_n.height;
		ss_cel.xoff = ss_n.xoff;
		ss_cel.yoff = ss_n.yoff;
		ss_cel.image_size = Raster_block(ss_n.width, (long)ss_n.height);
		if (ss_n.compress == NEO_CCOLUMNS)
			{
			if (ss_n.data_size > 32000)
				{
				mangled(name);
				goto end_loops;
				}
			if (Fread(load_fd, ss_n.data_size, next_screen) < ss_n.data_size)
				{
				file_truncated(name);
				goto end_loops;
				}
			word_uncompress(next_screen,  bscreen, ss_n.data_size>>1);
			}
		else
			{
			if (Fread(load_fd, ss_cel.image_size, bscreen) < ss_cel.image_size)
				{
				file_truncated(name);
				goto end_loops;
				}
			}
		if (ss_n.op != NEO_XOR )
			{
			clear_screen();
			if (ss_n.compress == NEO_CCOLUMNS)
				twist_copy_celblit(0, 0, &ss_cel);
			else
				copy_celblit(0, 0, &ss_cel);
			}
		else
			{
			if (ss_n.compress == NEO_CCOLUMNS)
				twist_xor_celblit(0, 0, &ss_cel);
			else
				xor_celblit(0, 0, &ss_cel);
			}
		}
	else
		{
		if (ss_n.op != NEO_XOR )
			clear_screen();
		else
			empty = 1;
		}
	if (i <= start)
		{
		copy_screen(pscreen, start_screen);
		}
	if (i == start)
		copy_screen(pscreen, prev_screen);
	if (i >= start)
		{
		rd_free = mem_to_use - rd_count - empty_size;
		if ( (dlt_size=calc_lit_dlt_size(pscreen, prev_screen)) <= rd_free)
			{
			if (!empty)
				buf = make_lit_deltas(pscreen, prev_screen, buf, dlt_size,
					ss_n.colormap);
			else
				{
				empty_frame(buf, ss_n.colormap);
				buf += empty_size/sizeof(WORD);
				}
			}
		else
			{
			nomem = 1;
			rd_more = 1;
			goto end_loops;
			}
		rd_count = pt_to_long(buf) - pt_to_long(rd_start);
		screen_ct++;
		}
	copy_screen(pscreen, prev_screen);
	}
l_seq_end = 1;
end_loops:
copy_screen(prev_screen, end_screen);
empty_frame(buf, sys_cmap);
ram_screens[i-start] = buf;
rd_count += empty_size;
buf += empty_size/sizeof(WORD);
rd_count = pt_to_long(buf) - pt_to_long(rd_start);
copy_lots(rd_start, (char *)ram_dlt - rd_count, rd_count);
offset_ram_screens(rd_alloc - rd_count);
copy_screen(start_screen, pscreen);
copy_screen(start_screen, bscreen);
copy_screen(start_screen, uscreen);
qput_cmap(ram_screens[0]);
update_next_prev(bscreen);
rd_frames += screen_ct;
success = 1;

end_lseq:
if (rd_abort && (screen_ct < ss_h.cel_count))
	rd_more = 1;
if (load_fd >= 0)
	Fclose(load_fd);
if (screen_ct == 0)
	_clear_seq();
sput_cmap();
return(success);
}

read_one_sframe(name, screen, buf_screen1, buf_screen2)
char *name;
WORD *screen;
WORD *buf_screen1;
WORD *buf_screen2;
{
WORD *ocscreen = cscreen;

cscreen = screen;
if (!next_seq_neo(name) )
	return(0);
if (ss_n.data_size > 0)
	{
	ss_cel.width = ss_n.width;
	ss_cel.height = ss_n.height;
	ss_cel.xoff = ss_n.xoff;
	ss_cel.yoff = ss_n.yoff;
	ss_cel.image_size = Raster_block(ss_n.width, (long)ss_n.height);
	ss_cel.image = buf_screen1;
	if (ss_n.compress == NEO_CCOLUMNS)
		{
		if (Fread(load_fd, ss_n.data_size, buf_screen2) < ss_n.data_size)
			{
			file_truncated(name);
			return(0);
			}
		word_uncompress(buf_screen2,  buf_screen1, ss_n.data_size>>1);
		}
	else
		{
		if (Fread(load_fd, ss_cel.image_size, buf_screen1) < ss_cel.image_size)
			{
			file_truncated(name);
			return(0);
			}
		}
	if (ss_n.op != NEO_XOR )
		{
		clear_screen();
		if (ss_n.compress == NEO_CCOLUMNS)
			twist_copy_celblit(0, 0, &ss_cel);
		else
			copy_celblit(0, 0, &ss_cel);
		}
	else
		{
		if (ss_n.compress == NEO_CCOLUMNS)
			twist_xor_celblit(0, 0, &ss_cel);
		else
			xor_celblit(0, 0, &ss_cel);
		}
	}
else
	{
	if (ss_n.op != NEO_XOR )
		clear_screen();
	}
cscreen = ocscreen;
return(1);
}

seq_file_tseek(name, screen, start, seekto)
char *name;
WORD *screen;
WORD start, seekto;
{
if (start < 0)
	{
	Fseek((long)ss_h.cel_count*sizeof(long)+sizeof(ss_h), load_fd, 0);
	if (!read_one_sframe(name, screen, prev_screen, next_screen))
		return(0);
	start = 0;
	}
while (start < seekto)
	{
	if (!read_one_sframe(name, screen, prev_screen, next_screen))
		return(0);
	start++;
	}
return(1);
}
