
#include <osbind.h>
#include "flicker.h"

static WORD err, fd;
static Seq_header h;
static struct neo_head n;
static Cel cel;

show_err(err, name)
WORD err;
char *name;
{
switch (err)
	{
	case NOMEM:
		outta_memory();
		break;
	case NOOPEN:
		couldnt_open(name);
		break;
	case TRUNCATED:
		file_truncated(name);
		break;
	case BADFILE:
		mangled();
		break;
	}
}

load_seq_overlay(name, nou, dx, dy)
char *name;
WORD nou;
WORD dx, dy;
{
WORD err;

return(l_seq_overlay(name, nou, 0, dx, dy));
}

char *abort_l_lines[] =
	{
	"Abort this load?",
	NULL,
	};

abort_load()
{
WORD ret;

hide_mouse();
check_input();
if (RJSTDN || key_hit)
	{
	copy_screen(cscreen, bscreen);
	ret = yes_no_from_menu(abort_l_lines);
	hide_mouse();
	copy_screen(bscreen, cscreen);
	return(ret);
	}
return(0);
}

prelim_load_over(name)
char *name;
{
err = 0;
hide_mouse();
cel.image = bscreen;
cel.mask = NULL;
if (!sub_ram_deltas(bscreen))
	{
	err = NOMEM;
	return(0);
	}
if ((fd = Fopen(name, 0)) < 0)
	{
	err = NOOPEN;
	return(0);
	}
if ( Fread(fd, (long)sizeof(h), &h) < sizeof(h) )
	{
	err = TRUNCATED;
	return(0);
	}
if (h.magic != 0xfedc && h.magic != 0xfedb)
	{
	err = BADFILE;
	return(0);
	}
Fseek( h.cel_count * sizeof(long), fd, 1);	/* skip past the offset lists */
return(1);
}

decode_frame()
{
if ( Fread(fd, (long)sizeof(n), &n) < sizeof(n) )
	{
	err = TRUNCATED;
	return(0);
	}
if (n.type != -1)
	{
	err = BADFILE;
	return(0);
	}
if (n.compress == NEO_UNCOMPRESSED)
	n.data_size = Raster_block(n.width, (long)n.height);
if (n.data_size > 0)
	{
	cel.width = n.width;
	cel.height = n.height;
	cel.xoff = n.xoff;
	cel.yoff = n.yoff;
	cel.image_size = Raster_block(n.width, n.height);
	if (n.compress == NEO_CCOLUMNS)
		{
		if (Fread(fd, n.data_size, uscreen) < n.data_size)
			{
			err = TRUNCATED;
			return(0);
			}
		word_uncompress(uscreen,  bscreen, n.data_size>>1);
		cscreen = uscreen;
		clear_screen();
		twist_copy_celblit(0, 0, &cel);
		}
	else
		{
		if (Fread(fd, cel.image_size, bscreen) < cel.image_size)
			{
			err = TRUNCATED;
			return(0);
			}
		cscreen = uscreen;
		clear_screen();
		copy_celblit(0, 0, &cel);
		}
	}
else
	{
	cscreen = uscreen;
	clear_screen();
	}
cscreen = pscreen;
return(1);
}

Cel *
load_first_frame(name)
char *name;
{
Cel *fframe;

fframe = NULL;
if (!prelim_load_over(name))
	{
	goto end_lseq;
	}
copy_screen(bscreen, pscreen);	/* screen only in pscreen now! */
if (!decode_frame())
	goto end_lseq;
if (!find_clip(uscreen) )
	{
	x_1 = XMAX;
	y_1 = YMAX;
	x_0 = 0;
	y_0 = 0;
	}
if ((fframe = alloc_cel(x_1-x_0, y_1-y_0)) == NULL)
	{
	err = NOMEM;
	goto end_lseq;
	}
fframe->xoff = x_0;
fframe->yoff = y_0;
clip_from_screen(fframe, uscreen);
copy_structure(n.colormap, fframe->cmap, COLORS*sizeof(WORD) );
if (!cfit_cel(fframe))
	{
	err = NOMEM;
	goto end_lseq;
	}
if (!mask_cel(fframe))
	{
	free_cel(fframe);
	fframe = NULL;
	err = NOMEM;
	goto end_lseq;
	}
end_lseq:
if (fd >= 0)
	{
	Fclose(fd);
	}
copy_screen(pscreen, uscreen);
copy_screen(pscreen, bscreen);
show_err(err, name);
if (err)
	{
	free_cel(fframe);
	fframe = NULL;
	}
return(fframe);
}


l_seq_overlay(name, nou, first_only, dx, dy)
char *name;
WORD nou;
WORD first_only;
WORD dx, dy;
{
register WORD i;
long est_mem;
long rd_free;
WORD *buf;
WORD oscreen_ix;
long dlt_size;
Cel cel2;
WORD got_end = 0;

if (!prelim_load_over(name))
	{
	goto end_lseq;
	}
oscreen_ix = screen_ix;
if (nou >= NOU_MASK)
	abs_tseek(0, bscreen);
copy_screen(bscreen, pscreen);
cel2.image = uscreen;
cel2.width = 320;
cel2.height = 200;
cel2.xoff = dx;
cel2.yoff = dy;
i = 0;
for (;;)
	{
	if (i >= h.cel_count && nou != NOU_MASK && nou != NOU_IMASK)
		break;
	if ( abort_load())
		{
		goto end_lseq;
		}
	if (i < h.cel_count)
		{
		if (!decode_frame())
			goto end_lseq;
		if (n.op == NEO_XOR)
			xor_screen(end_screen, uscreen);
		copy_screen(uscreen, end_screen);
		}
	else
		{
		copy_screen(end_screen, uscreen);
		}
	copy_structure(n.colormap, cel2.cmap, COLORS*sizeof(WORD) );
	if (nou == NOU_MASK || nou == NOU_IMASK)
		{
		qput_cmap(n.colormap);
		}
	else
		{
		if (!cfit_cel(&cel2))
			{
			err = NOMEM;
			goto end_lseq;
			}
		}
	switch (nou)
		{
		case NOU_UNDER:
			{
			if (dx == 0 && dy == 0)
				zscopy_screen(uscreen, pscreen, pscreen);
			else
				{
				zero_screen(bscreen);
				copy_blit(320, 200,
					0, 0, uscreen, Raster_line(320),
					dx, dy, bscreen, Raster_line(320));
				zscopy_screen(bscreen, pscreen, pscreen);
				}
			}
			break;
		case NOU_OVER:
			{
			if (dx == 0 && dy == 0)
				zscopy_screen(pscreen, uscreen, pscreen);
			else
				{
				zero_screen(bscreen);
				copy_blit(320, 200,
					0, 0, uscreen, Raster_line(320),
					dx, dy, bscreen, Raster_line(320));
				zscopy_screen(pscreen, bscreen, pscreen);
				}
			}
			break;
		case NOU_MASK:
			mask_screen(pscreen);
			and_screen(uscreen, pscreen);
			break;
		case NOU_IMASK:
			imask_screen(pscreen);
			and_screen(uscreen, pscreen);
			break;
		case NOU_MERGE:
			xor_screen(uscreen, pscreen);
			break;
		}
	if (!sub_ram_deltas(pscreen) )
		{
		err = NOMEM;
		goto end_lseq;
		}
	if (screen_ix == screen_ct-1)
		break;
	screen_ix += 1;
	advance_next_prev(pscreen);
	do_deltas(ram_screens[screen_ix], pscreen);
	qput_cmap(ram_screens[screen_ix]);
	i++;
	}
end_lseq:
if (fd >= 0)
	{
	Fclose(fd);
	}
make_end_screen();
abs_tseek(oscreen_ix, bscreen);	/* restore current frame */
copy_screen(bscreen, uscreen);
show_err(err, name);
return(err == 0);
}

