
#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

extern char rd_name[];
extern long rd_count, rd_alloc;


char *vquery[] =
	{
	"Advance to next part",
	NULL,
	"This will destroy frames",
	"in memory.",
	NULL,
	};

seriously_virtual(m)
Flicmenu *m;
{
char buf[80];

sprintf(buf, "of %s  ?", rd_name);
vquery[1] = buf;
return(yes_no_from_menu(vquery) );
}

char *virtual_when[] =
	{
	"Entire animation's in memory",
	"already. This option is",
	"for animations larger than can",
	"fit into memory.",
	NULL,
	};

virtual_next_frame(m)
Flicmenu *m;
{
if (rd_more)
	{
	if ( seriously_virtual())
		{
		jimints_off();
		rd_more = 0;
		if (suffix_in(rd_name, ".SEQ"))
			load_more_seq();
		else
			load_more_dlt();
		hide_mouse();
		jimints_on();
		redraw_menu_frame();
		show_mouse();
		}
	}
else
	continu_from_menu(virtual_when);
}


