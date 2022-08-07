
overlay "reader"

#include <osbind.h>
#include <neo.h>
#include "..\\include\\lists.h"
#include "..\\include\\raster.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"
#include "..\\include\\poly.h"


outta_memory()
{
bottom_line("outta memory");
}

struct bit_plane *
load_msk(name, x0, y0, x1, y1)
register char *name;
WORD *x0, *y0, *x1, *y1;
{
struct neo_head n;
register int fd;
register long length;
register struct bit_plane *mask;

if ((fd = Fopen(name, 0))<0)
	{
	couldnt_open(name);
	return(NULL);
	}
if (Fread(fd, (long)sizeof(n), &n) != sizeof(n) )
	{
	file_truncated(name);
	Fclose(fd);
	return(NULL);
	}
if ((mask = init_bit_plane(n.width, n.height) ) == NULL)
	{
	outta_memory();
	Fclose(fd);
	return(NULL);
	}
length = (mask->words_per_line<<1) * mask->height;
*x0 = n.xoff;
*y0 = n.yoff;
*x1 = n.xoff + n.width;
*y1 = n.yoff + n.height;

if (Fread(fd, length, mask->plane ) != length)
	file_truncated();

Fclose(fd);
return(mask);
}

struct atari_cel *
load_window(name, x0, y0, x1, y1)
register char *name;
WORD *x0, *y0, *x1, *y1;
{
struct neo_head n;
register int fd;
register long length;
register struct atari_cel *cel;

if ((fd = Fopen(name, 0))<0)
	{
	couldnt_open(name);
	return(NULL);
	}
if (Fread(fd, (long)sizeof(n), &n) != sizeof(n) )
	{
	file_truncated(name);
	Fclose(fd);
	return(NULL);
	}
if ((cel = init_atari_cel(n.width, n.height) ) == NULL)
	{
	outta_memory();
	Fclose(fd);
	return(NULL);
	}
length = cel->nxln * cel->height;
*x0 = n.xoff;
*y0 = n.yoff;
*x1 = n.xoff + n.width;
*y1 = n.yoff + n.height;

if (Fread(fd, length, cel->form ) != length)
	file_truncated();

if (!add_mask_to_cel(cel) )
	{
	outta_memory();
	Fclose(fd);
	free_atari_cel(cel);
	return(NULL);
	}
Fclose(fd);
return(cel);
}

save_mask(name, mask, xoff, yoff)
register char *name;
register struct bit_plane *mask;
WORD xoff, yoff;
{
struct neo_head n;
register int fd;
register long length;

block_stuff(&n, 0, sizeof(n) );
n.type = -2;
n.xoff = xoff;
n.yoff = yoff;
n.width = mask->width;
n.height = mask->height;
ani_to_atari_cmap( usr_cmap, n.colormap,  MAXCOL);
if ((fd = Fopen(name, 1)) < 0)
	{
	if ((fd = Fcreate(name, 0)) < 0)
		{
		couldnt_open(name);
		return(0);
		}
	}
if ( Fwrite(fd, (long)sizeof(n), &n) < sizeof(n) )
	{
	file_truncated(name);
	Fclose(fd);
	return(0);
	}
length = (mask->words_per_line<<1) * mask->height;
if ( Fwrite(fd, length, mask->plane) < length )
	{
	file_truncated(name);
	Fclose(fd);
	return(0);
	}
Fclose(fd);
return(1);
}

save_window(name, cel, xoff, yoff)
register char *name;
register struct atari_cel *cel;
WORD xoff, yoff;
{
struct neo_head n;
register int fd;
register long length;

block_stuff(&n, 0, sizeof(n) );
n.type = -1;
n.xoff = xoff;
n.yoff = yoff;
n.width = cel->width;
n.height = cel->height;
ani_to_atari_cmap( usr_cmap, n.colormap,  MAXCOL);
if ((fd = Fopen(name, 1)) < 0)
	{
	if ((fd = Fcreate(name, 0)) < 0)
		{
		couldnt_open(name);
		return(0);
		}
	}
if ( Fwrite(fd, (long)sizeof(n), &n) < sizeof(n) )
	{
	file_truncated(name);
	Fclose(fd);
	return(0);
	}
length = cel->nxln * cel->height;
if ( Fwrite(fd, length, cel->form) < length )
	{
	file_truncated(name);
	Fclose(fd);
	return(0);
	}
Fclose(fd);
return(1);
}
