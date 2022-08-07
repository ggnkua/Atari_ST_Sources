
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\menu.h"
#include "..\\include\\format.h"


static char ani_drawer[33];
#ifdef SLUFFED
static char ani_path[66];
#endif SLUFFED

#ifdef AMIGA
char *
make_file_name(fil_nam)
char *fil_nam;
{
register char   *pdst = ani_path;
register char   *psrc = ani_drawer;
register char   c = ':';

while ( *psrc )
  *pdst++ = c = *psrc++;
if ( c != ':' )   *pdst++ = '/';

psrc = fil_nam;
while ( *pdst++ = *psrc++ )
  ;
return(ani_path);
}
#endif AMIGA

#ifdef ATARI
char *
make_file_name(fil_nam)
char *fil_nam;
{
return(fil_nam);
#ifdef LATER
register char   *pdst = ani_path;
register char   *psrc = ani_drawer;
register char   c = '\\';


while ( *psrc )
  *pdst++ = c = *psrc++;
if ( c != '\\')
  *pdst++ = '\\';

psrc = fil_nam;
while ( *pdst++ = *psrc++ )
	{
	}
return(ani_path);
#endif LATER
}
#endif ATARI

gen_cd(m,sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
extern char *last_path;
extern char *request_line();
register char *new_path;

new_path = request_line(m,sel,vis, "new directory?");
if (new_path)
	{			/*if new disk or first time*/
#ifdef AMIGA
	strcpy(ani_drawer, new_path);
#endif AMIGA
	close_file_linked_list();
	lchdir(new_path);
	init_file_linked_list(ani_drawer);
	init_script_names();
	}
}


