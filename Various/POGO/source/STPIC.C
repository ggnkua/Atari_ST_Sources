
#include <aline.h>
#include <osbind.h>
#include <stdio.h>
#include <ctype.h>
#include "pogo.h"
#include "neo.h"

extern WORD in_graphics;
extern WORD *cscreen, *physcreen;
extern WORD *sys_cmap;

ustrcmp(a, b)
char *a, *b;
{
char aa, bb;
int diff;

if (a == b)
	return(0);
if (a == NULL)
	return(-1);
if (b == NULL)
	return(1);
for (;;)
	{
	aa = *a++;
	if (islower(aa))
		aa = aa + 'A' - 'a';
	bb = *b++;
	if (islower(bb))
		bb = bb + 'A' - 'a';
	diff = aa - bb;
	if (diff != 0)
		return(diff);
	if (aa == 0)
		return(0);
	}
}

suffix_in(str, suff)
char *str, *suff;
{
str += strlen(str) - strlen(suff);
return(ustrcmp(str, suff) == 0);
}

is_neo(name)
char *name;
{
return(suffix_in(name, ".NEO"));
}

is_pi1(name)
char *name;
{
return(suffix_in(name, ".PI1"));
}

pload_pic(p)
union pt_int *p;
{
char *name;

if ((name = p[-1].p) == NULL)
	return(0);
to_graphics();
if (is_neo(name))
	return(rneo(name));
if (is_pi1(name))
	return(rpi1(name));
return(rpc1(name));
}

rpi1(name)
char *name;
{
int fd;
struct degas_head deg;
int ok = 0;

if ((fd = Fopen(name, 0)) < 0)
	{
	cant_find(name);
	return(0);
	}
if (Fread(fd, (long)sizeof(deg), &deg) != sizeof(deg))
	{
	truncated(name);
	goto OUT;
	}
if (deg.res != 0)
	{
	mangled(name);
	return(0);
	}
if (Fread(fd, 32000L, cscreen) != 32000L)
	{
	truncated(name);
	goto OUT;
	}
put_cmap(deg.colormap);
ok = 1;
OUT:
Fclose(fd);
return(ok);
}


rneo(name)
char *name;
{
int fd;
struct neo_head neo;
int ok = 0;

if ((fd = Fopen(name, 0)) < 0)
	{
	cant_find(name);
	return(0);
	}
if (Fread(fd, (long)sizeof(neo), &neo) != sizeof(neo))
	{
	truncated(name);
	goto OUT;
	}
if (neo.type != 0 && neo.type != 1)
	{
	mangled(name);
	goto OUT;
	}
if (Fread(fd, 32000L, cscreen) != 32000L)
	{
	truncated(name);
	goto OUT;
	}
put_cmap(neo.colormap);
ok = 1;
OUT:
Fclose(fd);
return(ok);
}

rpc1(name)
char *name;
{
int fd;
long size;
WORD *prev_screen;

if ((fd = Fopen(name, 0)) < 0)
	{
	cant_find(name);
	return(0);
	}
if ((prev_screen = beg_mem((unsigned)40000)) == NULL)
	{
	Fclose(fd);
	return(0);
	}
size = Fread(fd, 40000L, prev_screen);
Fclose(fd);
if (prev_screen[0] != 0x8000)
	{
	mangled(name);
	freemem(prev_screen);
	return(0);
	}
put_cmap(prev_screen+1);
unpack_screen(prev_screen+17, cscreen, 40, 4, 200);
freemem(prev_screen);
return(1);
}

psave_pic(p)
union pt_int *p;
{
char *name;

name = p[-1].p;
if (name == NULL)
	return(0);
if (is_neo(name))
	return(sneo(name));
if (is_pi1(name))
	return(spi1(name));
return(spc1(name));
}

createnew(name)
char *name;
{
Fdelete(name);
return(Fcreate(name, 0));
}

spc1(name)
char *name;
{
int success = 0;
int *cbuf;
int fd;
long size;
struct degas_head d;

if ((cbuf = beg_mem((unsigned)40000)) == NULL)
	return(0);
if ((fd = createnew(name)) < 0)
	goto saved_pic;
d.res = 0x8000;
copy_bytes(sys_cmap, d.colormap, 32);
if ( Fwrite(fd, (long)sizeof(d), &d) < sizeof(d) )
	{
	goto saved_pic;
	}
size = compress_screen(cscreen, cbuf);
if (size == 0)
	goto saved_pic;
if (Fwrite(fd, size, cbuf) < size)
	{
	goto saved_pic;
	}
success = 1;
saved_pic:
free(cbuf);
if (fd >= 0)
	Fclose(fd);
if (!success)
	Fdelete(name);
return(success);
}

spi1(name)
char *name;
{
int success = 0;
int fd;
long size;
struct degas_head d;

if ((fd = createnew(name)) < 0)
	goto saved_pic;
d.res = 0x0000;
copy_bytes(sys_cmap, d.colormap, 32);
if ( Fwrite(fd, (long)sizeof(d), &d) < sizeof(d) )
	{
	goto saved_pic;
	}
if (Fwrite(fd, 32000L, cscreen) < 32000L)
	{
	goto saved_pic;
	}
success = 1;
saved_pic:
if (fd >= 0)
	Fclose(fd);
if (!success)
	Fdelete(name);
return(success);
}

sneo(name)
char *name;
{
int success = 0;
int fd;
long size;
struct neo_head neo;

if ((fd = createnew(name)) < 0)
	goto saved_pic;
zero_bytes(&neo, sizeof(neo));
copy_bytes(sys_cmap, neo.colormap, 32);
if ( Fwrite(fd, (long)sizeof(neo), &neo) < sizeof(neo) )
	{
	goto saved_pic;
	}
if (Fwrite(fd, 32000L, cscreen) < 32000L)
	{
	goto saved_pic;
	}
success = 1;
saved_pic:
if (fd >= 0)
	Fclose(fd);
if (!success)
	Fdelete(name);
return(success);
}


