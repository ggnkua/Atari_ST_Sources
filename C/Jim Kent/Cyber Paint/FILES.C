
#include <osbind.h>
#include <gemdefs.h>
#include "flicker.h"
#include "jiff.h"

 

extern WORD *cscreen, *pscreen;
extern WORD current_drive;
static struct neo_head n;
static struct degas_head d;
extern long rd_alloc, rd_count;


gmessage(s)	/* message with gem cursor ... the hassles of keeping the
			cursor visible during file io ... especially when you use
			a different cursor than GEM does */
char *s;
{
top_print(s);
}

mangled()
{
char buf[80];

flash_bg(0x700);
continu_line("file mangled!" );
}

too_big()
{
continu_line("file too big");
}

#ifdef SLUFFED
too_many_screens()
{
continu_line("too many screens in file");
}
#endif SLUFFED


file_truncated(name)
char *name;
{
char *bufs[3];

bufs[0] = name;
bufs[1] = "File Truncated!";
bufs[2] = NULL;
flash_bg(0x700);
continu_from(bufs);
}

couldnt_open(name)
char *name;
{
char *bufs[3];

bufs[0] = name;
bufs[1] = "Couldn't Open!";
bufs[2] = NULL;
continu_from(bufs);
}

bad_magic()
{
continu_line("Bad Magic!");
}

load_pic(name)
char *name;
{
return(lpic(name, 1) );
}

lpic(name, err)
register char *name;
WORD err;
{
register WORD fd;
WORD success = 0;

if ((fd = Fopen(name, 0)) < 0)
	{
	if (err)
		couldnt_open(name);
	goto loaded_pic;
	}
if (degas)
	{
	if ( Fread(fd, (long)sizeof(d), &d) < sizeof(d) )
		{
		if (err)
			file_truncated(name);
		goto loaded_pic;
		}
	put_cmap(d.colormap);
	}
else
	{
	if ( Fread(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		if (err)
			file_truncated(name);
		goto loaded_pic;
		}
	put_cmap(n.colormap);
	}
if (Fread(fd, (long)32000, bscreen) < 32000)
	{
	if (err)
		file_truncated(name);
	goto loaded_pic;
	}
success = 1;
loaded_pic:
if (fd >= 0)
	Fclose(fd);
return(success);
}

save_pic(name)
char *name;
{
return(s_pic(name, bscreen) );
}

s_pic(name, screen)
register char *name;
WORD *screen;
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
if ( Fwrite(fd, (long)32000, screen) < 32000 )
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

long
compress_screen(s, d)
register char *s;
char *d;
{
int i, j;
char ravel_buf[Mask_line(XMAX)];
register char *dpt;
extern char *pack();
extern long pt_to_long();

#define Mask_line(width) ((((width)+15)>>3)&0xfffe)

i = YMAX;
dpt = d;
while (--i >= 0)
	{
	j = 4;
	while (--j >= 0)
		{
		ravel_line(s, ravel_buf, Mask_line(XMAX) );
		dpt = pack(ravel_buf, dpt, Mask_line(XMAX) );
		s += sizeof(WORD);
		}
	s += Raster_line(XMAX)-4*sizeof(WORD);
	}
return( pt_to_long(dpt) - pt_to_long(d) );
}

save_pc1(name)
char *name;
{
WORD success = 0;
WORD fd;
long size;

sub_ram_deltas(bscreen);

Fdelete(name);
if ((fd = Fcreate(name, 0)) < 0)
	{
	couldnt_open(name);
	goto saved_pic;
	}
word_zero(&d, sizeof(d)/sizeof(WORD) );
d.res = 0x8000;
copy_words(sys_cmap, d.colormap, 16);
if ( Fwrite(fd, (long)sizeof(d), &d) < sizeof(d) )
	{
	file_truncated(name);
	goto saved_pic;
	}
size = compress_screen(bscreen, prev_screen);
if (Fwrite(fd, size, prev_screen) < size)
	{
	file_truncated(name);
	goto saved_pic;
	}
success = 1;
saved_pic:
update_next_prev(bscreen);
if (fd >= 0)
	Fclose(fd);
return(success);
}

load_col(name)
register char *name;
{
register int fd;
int success;

success = 0;
if ((fd = Fopen(name, 0))<0)
	{
	couldnt_open(name);
	goto loaded_col;
	}
if (Fread(fd, (long)32, n.colormap) != 32)
	file_truncated(name);
else
	{
	put_cmap(n.colormap);
	success = 1;
	}
loaded_col:
if (fd >= 0)
	Fclose(fd);
return(success);
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
	file_truncated(name);
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
if (cel->image_size > 0)
	{
	if ( Fwrite(fd, (long)cel->image_size, cel->image) < cel->image_size )
		{
		file_truncated(name);
		goto saved_cel;
		}
	}
success = 1;
saved_cel:
if (fd >= 0)
	Fclose(fd);
return(success);
}

read_pc1(name)
char *name;
{
return(rpc1(name, 1));
}

rpc1(name, context)
char *name;
WORD context;
{
int fd;
long size;

if (context)
	sub_ram_deltas(bscreen);
if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	return(0);
	}
size = Fread(fd, 64000L, prev_screen);
Fclose(fd);
if (prev_screen[0] != 0x8000)
	{
	mangled();
	return(0);
	}
put_cmap(prev_screen+1);
unpack_screen(prev_screen+17, bscreen, Mask_line(320), 4, 200);
#ifdef LATER
	;unpack_screen(s, d, linebytes, planes, lines)
unpack(prev_screen+17, pscreen, Mask_line(320), 200*4);
unravelst(pscreen, bscreen, Mask_line(320), 200, 4);
#endif LATER

if (context)
	update_next_prev(uscreen);
return(1);
}

