
#include <osbind.h>
#include <gemdefs.h>
#include "flicker.h"

 
extern WORD *cscreen;
extern WORD current_drive;
static struct neo_head n;
static struct degas_head d;

gmessage(s)	/* message with gem cursor ... the hassles of keeping the
			cursor visible during file io ... especially when you use
			a different cursor than GEM does */
char *s;
{
ghide_mouse();
top_print(s);
gshow_mouse();
}

gtop_line(s)
char *s;
{
ghide_mouse();
top_print(s);
gshow_mouse();
wait_ednkey();
}

checking_dfree(needs)
register long needs;
{
register long dfree;
long buf[4];
char cbuf[40];

sprintf(cbuf, "checking disk for %ld free bytes", needs);
gmessage(cbuf);
Dfree(buf, current_drive+1);
dfree = buf[0] * buf[2] * buf[3];
sprintf(cbuf, "%ld free bytes need %ld", dfree, needs);
gmessage(cbuf);
return( dfree >= needs );
}


file_truncated(name)
char *name;
{
char buf[50];

sprintf(buf, "file %s truncated", name);
gtop_line(buf);
}

couldnt_open(name)
char *name;
{
char buf[50];

sprintf(buf, "couldn't open %s", name);
gtop_line(buf);
}

load_pic(name)
register char *name;
{
register WORD fd;
WORD success = 0;

if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	goto loaded_pic;
	}
if (degas)
	{
	if ( Fread(fd, (long)sizeof(d), &d) < sizeof(d) )
		{
		file_truncated(name);
		goto loaded_pic;
		}
	}
else
	{
	if ( Fread(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		file_truncated(name);
		goto loaded_pic;
		}
	}
if (Fread(fd, (long)32000, screens[screen_ix]) < 32000)
	{
	file_truncated(name);
	goto loaded_pic;
	}
if (degas)
	put_cmap(d.colormap);
else
	put_cmap(n.colormap);
success = 1;
loaded_pic:
if (fd >= 0)
	Fclose(fd);
return(success);
}

save_pic(name)
register char *name;
{
register WORD fd;
WORD success = 0;

Fdelete(name);
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	goto saved_pic;
	}
if (degas)
	{
	word_zero(&d, sizeof(d)/sizeof(WORD) );
	copy_words(sys_cmap, d.colormap, 16);
	if ( Fwrite(fd, (long)sizeof(d), &d) < sizeof(d) )
		{
		file_truncated(name);
		goto saved_pic;
		}
	}
else
	{
	word_zero(&n, sizeof(n)/sizeof(WORD) );
	copy_words(sys_cmap, n.colormap, 16);
	n.slide_time = 10;
	n.width = 320;
	n.height = 200;
	if ( Fwrite(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		file_truncated(name);
		goto saved_pic;
		}
	}
if ( Fwrite(fd, (long)32000, screens[screen_ix]) < 32000 )
	{
	file_truncated(name);
	goto saved_pic;
	}
success = 1;
saved_pic:
if (fd >= 0)
	Fclose(fd);
return(success);
}

load_col(name)
register char *name;
{
register int fd;

if ((fd = Fopen(name, 0))<0)
	{
	couldnt_open(name);
	goto loaded_col;
	}
if (Fread(fd, (long)32, n.colormap) != 32)
	file_truncated(name);
else
	put_cmap(n.colormap);
loaded_col:
if (fd >= 0)
	Fclose(fd);
return;
}

save_col(name)
register char *name;
{
register int fd;

Fdelete(name);
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	goto saved_col;
	return;
	}
copy_words(sys_cmap, n.colormap, 16);
if (Fwrite(fd, (long)32, n.colormap) != 32)
	{
	file_truncated(name);
	}
saved_col:
if (fd >= 0)
	Fclose(fd);
return;
}


load_cel(name)
register char *name;
{
struct neo_head n;
register int fd;
register long length;
register Cel *cel = NULL;

free_cel(clipping);
clipping = NULL;
if ((fd = Fopen(name, 0))<0)
	{
	couldnt_open(name);
	goto cleanup_lw;
	}
if (Fread(fd, (long)sizeof(n), &n) != sizeof(n) )
	{
	file_truncated(name);
	goto cleanup_lw;
	}
if ((cel = alloc_cel(n.width, n.height)) == NULL)
	{
	outta_memory();
	goto cleanup_lw;
	}
copy_words(n.colormap, cel->cmap, 16);
cel->xoff = n.xoff;
cel->yoff = n.yoff;

if (Fread(fd, (long)cel->image_size, cel->image ) != cel->image_size)
	file_truncated();
if (!mask_cel(cel))
	{
	outta_memory();
	free_cel(cel);
	cel = NULL;
	}
cleanup_lw:
if (fd >= 0)
	Fclose(fd);
clipping = cel;
return;
}

save_cel(name)
register char *name;
{
register WORD fd;
register Cel *cel;
WORD success = 0;

cel = clipping;
word_zero(&n, sizeof(n)/sizeof(WORD) );
n.type = -1;
n.xoff = cel->xoff;
n.yoff = cel->yoff;
n.width = cel->width;
n.height = cel->height;
n.slide_time = 10;
copy_words(sys_cmap, n.colormap, 16);
Fdelete(name);
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	goto saved_cel;
	}
if ( Fwrite(fd, (long)sizeof(n), &n) < sizeof(n) )
	{
	file_truncated(name);
	goto saved_cel;
	}
if ( Fwrite(fd, (long)cel->image_size, cel->image) < cel->image_size )
	{
	file_truncated(name);
	goto saved_cel;
	}
success = 1;
saved_cel:
if (fd >= 0)
	Fclose(fd);
return(success);
}

static long *offsets;

static
free_offsets()
{
if (offsets != NULL)
	mfree(offsets, screen_ct*sizeof(long) );
offsets = NULL;
}

save_seq(name)
char *name;
{
long dneeds;
Seq_header h;
int i;
WORD width, height;
register WORD maxwidth, maxheight;
register long acc;
long this_size;
long off_size;	/* sizeof offsets */
long cel_size;
WORD success = 0;
WORD *sscreen;
register WORD fd = -1;
register Cel *cel = NULL;


/* first do some pre-calculations.  Find out how much disk space it will
   take, and while we're at it make up offsets table, so file can be
   used with random access to cels later */
if ((offsets = (long *)alloc(screen_ct*sizeof(long))) == NULL)
	{
	outta_memory();
	goto done_sseq;
	}
maxwidth = maxheight = 0;
dneeds = sizeof(h);	
off_size = screen_ct;
off_size *= 4;
dneeds += off_size;	
acc = dneeds;
dneeds += (long)sizeof(n) * screen_ct;
for (i=0; i<screen_ct; i++)
	{
	offsets[i] = acc;
	if (find_clip(screens[i]))
		{
		width = x_1-x_0;
		height = y_1-y_0;
		if (width > maxwidth)
			maxwidth = width;
		if (height > maxheight)
			maxheight = height;
		this_size = Raster_block(width, height);
		dneeds += this_size;
		acc += this_size;
		acc += sizeof(n);
		}
	else
		{
		acc += sizeof(n);
		}
	}
if ( maxwidth == 0 && maxheight == 0)
	{
	maxwidth = maxheight = 1;
	}
if ( (cel = alloc_cel(maxwidth, maxheight)) == NULL)
	{
	outta_memory();
	goto done_sseq;
	}
Fdelete(name);
if (!checking_dfree(dneeds))
	{
	wait_a_jiffy(100);
	goto done_sseq;
	}
/* ok, now that we've got enough space ...	*/
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	goto done_sseq;
	}
word_zero(&h, sizeof(h)/sizeof(WORD) );
h.magic = 0xfedc;	/* write magic number */
h.version = 0;		/* well start at zero I guess */
h.cel_count = screen_ct;

/* write out header */
if (Fwrite(fd, (long)sizeof(h), &h) < sizeof(h) )
	{
	file_truncated(name);
	goto done_sseq;
	}

/* write out offsets */
if (Fwrite(fd, off_size, offsets) < off_size)
	{
	file_truncated(name);
	goto done_sseq;
	}

/* pre-init neo header */
word_zero(&n, sizeof(n)/sizeof(WORD) );
copy_words(sys_cmap, n.colormap, 16);
n.type = -1;
for (i=0; i<screen_ct; i++)
	{
	sscreen = screens[i];
	ghide_mouse();
	copy_screen(sscreen, cscreen);
	gshow_mouse();
	if (find_clip(screens[i]))
		{
		n.width = cel->width = x_1-x_0;
		n.height = cel->height = y_1-y_0;
		n.xoff = cel->xoff = x_0;
		n.yoff = cel->yoff = y_0;
		n.slide_time = 10;
		cel_size = Raster_block(n.width, n.height);
		word_zero(cel->image, (int)cel_size/sizeof(WORD) );
		clip_from_screen(cel, sscreen);
		}
	else
		{
		n.width = n.height = n.xoff = n.yoff = 
			cel->width = cel->height = cel->xoff = cel->yoff = 0;
		n.slide_time = 10;
		cel_size = 0;
		}
	if ( Fwrite(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		file_truncated(name);
		goto done_sseq;
		}
	if (cel_size > 0)
		{
		if (Fwrite(fd, cel_size, cel->image) < cel_size)
			{
			file_truncated(name);
			goto done_sseq;
			}
		}
	}
success = 1;	/* whew, made it! */

done_sseq:
free_offsets();
free_cel(cel);
if (fd >= 0)
	Fclose(fd);
return(success);
}

load_seq(name)
char *name;
{
register WORD fd;
Seq_header h;
register WORD i;
long est_mem;
register Cel *cel = NULL;
WORD success = 0;

if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	goto end_lseq;
	}
if ( Fread(fd, (long)sizeof(h), &h) < sizeof(h) )
	{
	file_truncated(name);
	goto end_lseq;
	}
if (h.magic != 0xfedc )
	{
	gtop_line("magic not $fedc!");
	goto end_lseq;
	}
if (h.cel_count > MAX_SCREENS)
	{
	gtop_line("too many screens in file");
	goto end_lseq;
	}
clear_seq();
est_mem = h.cel_count * 32000 + 8000;  /* rude to get memory too low */
if (mem_free < est_mem)
	{
	gtop_line("not enough memory for that file");
	goto end_lseq;
	}
for (i = 1; i<h.cel_count; i++)	/* allocate all the screens it will take */
	{
	if ( (screens[i] = alloc(32000) ) == NULL)
		{
		outta_memory();
		goto end_lseq;
		}
	screen_ct++;
	}
Fseek( h.cel_count * sizeof(long), fd, 1);	/* skip past the offset lists */
for (i=0; i<h.cel_count; i++)
	{
	if ( Fread(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		file_truncated(name);
		goto end_lseq;
		}
	if (n.width > 0 && n.height > 0)
		{
		if ((cel = alloc_cel(n.width, n.height)) == NULL)
			{
			outta_memory();
			goto end_lseq;
			}
		cel->xoff = n.xoff;
		cel->yoff = n.yoff;
		if (Fread(fd, (long)cel->image_size, cel->image) < cel->image_size)
			{
			file_truncated(name);
			goto end_lseq;
			}
		}
	ghide_mouse();
	put_cmap(n.colormap);
	clear_screen();
	if (cel != NULL)
		copy_celblit(0, 0, cel);
	copy_screen(cscreen, screens[i]);
	gshow_mouse();
	free_cel(cel);
	cel = NULL;
	}
success = 1;

end_lseq:
free_cel(cel);
if (fd >= 0)
	Fclose(fd);
return(success);
}
