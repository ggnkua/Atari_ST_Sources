
overlay "reader"

#include <osbind.h>
#include "..\\include\\lists.h"
#include "..\\include\\storage.h"

struct name_list *file_lst = NULL;

#ifdef SLUFFED
char disk_dta[128];
char disk_fcb[36];
#endif SLUFFED

#ifdef UNUSED
lopen(path, flags)
char *path;
int flags;
{
}

lclose(fd)
int fd;
{
}
#endif UNUSED

lunlink(path)
char *path;
{
if (Fdelete(path) < 0)
	return(-1);
else
	return(0);
}

lchdir(path)
register char *path;
{
if (strlen(path) > 1)
	{
	if (path[1] == ':')
	{
	if (Dsetdrv(path[0] - 'A') < 0)
		{
		return(-1);
		}
	path += 2;
	if (path[0] == 0)
		*(--path) = '\\';
	}
	}
if (Dsetpath(path) < 0)
	return(-1);
else
	return(0);
}


#ifdef UNUSED
char *lgetwd()
{
return(NULL);
}
#endif UNUSED


init_file_linked_list()
{
register char *dta;

show_mouse();
graf_mouse(2, NULL);	/* bumblebee */
dta = (char *)Fgetdta();
if ( Fsfirst("*.*", 0) != 0)
	return;

add_file_to_list(dta+30);

for (;;)
	{
	if (Fsnext() != 0)
		break;
	add_file_to_list(dta+30);
	}
hide_mouse();
}

close_file_linked_list()
{
free_name_list(file_lst);
file_lst = NULL;
}

add_file_to_list(path)
register char *path;
{
register Name_list *nl;

if ((nl = Alloc_a(Name_list)) == NULL)
	return;
if ((path = clone_string(path)) == NULL)
	{
	Free_a(nl);
	return;
	}
nl->next = file_lst;
nl->name = path;
file_lst = nl;
}

lsleep(seconds)
int seconds;
{
int delay;

seconds *= 6;
while (--seconds >= 0)
	{
	for (delay = 0; delay < 32000; delay++)
		;
	}
}
