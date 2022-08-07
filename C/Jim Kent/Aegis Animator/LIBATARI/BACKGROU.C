
overlay "reader"

#include <osbind.h>
#include <neo.h>
#include "..\\include\\lists.h"
#include "..\\include\\color.h"
#include "..\\include\\poly.h"

extern WORD *s2;
char *bbm_name = NULL;
WORD *bbm = NULL;

free_background()
{
if (bbm != NULL)
	{
	mfree(bbm, 32000);
	bbm = NULL;
	}
if (bbm_name != NULL)
	{
	free_string(bbm_name);
	bbm_name = NULL;
	}
}

file_truncated(name)
char *name;
{
ldprintf("file %s truncated", name);
}

couldnt_open(name)
char *name;
{
ldprintf("couldn't open %s", name);
}
 
extern char *dot_pi1;

struct degas_head
	{
	WORD res;
	WORD colormap[16];
	};

WORD *
load_background(name)
register char *name;
{
register int fd;
struct neo_head n;
struct degas_head d;
int degasp;

degasp = suffix_in(name, dot_pi1);
if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	return(NULL);
	}
if (degasp)
	{
	if ( Fread(fd, (long)sizeof(d), &d) < sizeof(d) )
		{
		file_truncated(name);
		Fclose(fd);
		return(NULL);
		}
	atari_to_ani_cmap(d.colormap, usr_cmap, MAXCOL);
	}
else
	{
	if ( Fread(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		file_truncated(name);
		Fclose(fd);
		return(NULL);
		}
	atari_to_ani_cmap(n.colormap, usr_cmap, MAXCOL);
	}
if (bbm == NULL)
	{
	if ((bbm = (WORD *)alloc(32000)) == NULL)
		{
		Fclose(fd);
		return(NULL);
		}
	}
if (Fread(fd, (long)32000, bbm) < 32000)
	{
	file_truncated(name);
	}
Fclose(fd);
if (bbm_name)
	free_string(bbm_name);
bbm_name = clone_string(name);
return(bbm);
}


load_colors(name)
register char *name;
{
register int fd;
WORD c_arr[MAXCOL];

if ((fd = Fopen(name, 0)) < 0)
	{
	couldnt_open(name);
	Fclose(fd);
	return(0);
	}
if ((Fread(fd, (long)sizeof(c_arr), c_arr)) < sizeof(c_arr) )
	{
	file_truncated(name);
	return(0);
	}
Fclose(fd);
atari_to_ani_cmap(c_arr, usr_cmap, MAXCOL);
return(1);
}

save_colors( name)
register char *name;
{
register int fd;
WORD c_arr[MAXCOL];

ani_to_atari_cmap(usr_cmap, c_arr, MAXCOL);
if ((fd = Fopen(name, 1)) < 0)
	{
	if ((fd = Fcreate(name, 0)) < 0)
		{
		couldnt_open(name);
		return(0);
		}
	}
if ((Fwrite(fd, (long)sizeof(c_arr), c_arr)) < sizeof(c_arr) )
	{
	file_truncated(name);
	return(0);
	}
Fclose(fd);
return(1);
}

save_frame(name)
register char *name;
{
register int fd;
struct neo_head n;
struct degas_head d;
int degasp;

degasp = suffix_in(name, dot_pi1);
if ((fd = Fopen(name, 1)) < 0)
	{
	if ((fd = Fcreate(name, 0)) < 0)
		{
		couldnt_open(name);
		return(0);
		}
	}
if (degasp)
	{
	block_stuff(&d, 0, sizeof(d) );
	ani_to_atari_cmap(usr_cmap, d.colormap, MAXCOL);
	if ( Fwrite(fd, (long)sizeof(d), &d) < sizeof(d) )
		{
		file_truncated(name);
		Fclose(fd);
		return(0);
		}
	}
else
	{
	block_stuff(&n, 0, sizeof(n) );
	ani_to_atari_cmap(usr_cmap, n.colormap, MAXCOL);
	if ( Fwrite(fd, (long)sizeof(n), &n) < sizeof(n) )
		{
		file_truncated(name);
		Fclose(fd);
		return(0);
		}
	}
if ( Fwrite(fd, (long)32000, s2) < 32000 )
	{
	file_truncated(name);
	Fclose(fd);
	return(0);
	}
return(1);
}
