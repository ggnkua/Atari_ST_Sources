
#include "flicker.h"
#include "flicmenu.h"

extern long rd_count, rd_alloc;

char *copyrt_lines[] =
	{
	"   Cyber Paint 2.0 5/3/88",
	"",
	"Developed for Antic Software by",
	" Dancing Flame, San Francisco.",
	"",
	" Copyright 1987,1988 Jim Kent",
	"     All Rights Reserved",
	NULL,
	};

copyright()
{
continu_from(copyrt_lines);
}

mshow_status(m)
Flicmenu *m;
{
hide_mouse();
if (m != NULL)
	hilight(m);
show_mouse();
show_status();
hide_mouse();
if (m != NULL)
	draw_sel(m);
show_mouse();
}

show_status()
{
char buf2[40], buf3[40], buf4[40], buf5[40], buf6[40], buf7[40], buf8[40];
char *stat[10];
extern long cel_mem_alloc;
extern long mem_free;
extern long largest_frag();
extern long size_one_dlt();

stat[0] = "  Memory Usage in Bytes";
stat[1] = "";
stat[2] = buf2;
stat[3] = buf3;
stat[4] = buf4;
stat[5] = buf5;
stat[6] = buf6;
stat[7] = buf7;
stat[8] = buf8;
stat[9] = NULL;
sprintf(buf2, "Total Free:       %8ld", 
	mem_free - rd_count - sizeof(struct mblock) );
sprintf(buf3, "Initial Free:     %8ld", cel_mem_alloc-8);
sprintf(buf4, "Largest Block:    %8ld", largest_frag());
sprintf(buf5, "Total in Frames:  %8ld", rd_count);
sprintf(buf6, "Last Frame Update:%8ld",
	size_one_dlt(ram_screens[screen_ix]));
sprintf(buf7, "Next Frame Update:%8ld", 
	size_one_dlt(ram_screens[screen_ix+1]));
sprintf(buf8, "Average Update:   %8ld", 
		(screen_ct > 1 ? (rd_count-2*empty_size)/(screen_ct-1) : 
		(long)empty_size));
continu_from(stat);
}

char *exit_lines[] = {
	"Leave  Cyber Paint?",
	NULL,
	NULL,
	NULL,
	NULL,
	};

char *clear_seq_lines[] = {
	"Clear all frames from memory?",
	"         ( no undo )         ",
	NULL,
	};

ok_clear_seq()
{
return(mquery(clear_seq_lines));
}

char *not_zero_lines[] = {
	"You can't have brush 1.",
	"Please select another",
	"brush and try again",
	NULL,
	};

char *over_all_lines[] =
	{
	"Do it over all frames?",
	"      (no undo)",
	NULL,
	};

over_many()
{
if (select_mode == 1)	/* over segment */
	return(really_segment("Do it over segment?", "    (no undo)"));
else if (select_mode == 2) /* over all */
	return(yes_no_from(over_all_lines) );
else
	return(1);
}

not_brush_0()
{
continu_from(not_zero_lines);
}

mquery(lines)
char *lines[];
{
WORD ret;

if (cur_menu == NULL)
	unzoom();
ret = yes_no_from_menu(lines);
if (cur_menu == NULL)
	rezoom();
return(ret);
}

mgo_byebye()
{
if (dirty_file)
	{
	exit_lines[1] = "";
	exit_lines[2] = "(You've made changes";
	exit_lines[3] = "you haven't saved.)";
	}
else
	exit_lines[1] = NULL;
if (mquery(exit_lines))
	go_byebye();
}


