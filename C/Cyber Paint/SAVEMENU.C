
#include <osbind.h>
#include "flicker.h"
#include "flicmenu.h"

extern Flicmenu menu_save, sframe_sel, sframes_sel;

extern WORD save_file_type, normal_over_under, got_patch;

char *title;

char dot_seq[] = "SEQ";
char dot_neo[] = "NEO";
char dot_cel[] = "CEL";
char dot_col[] = "COL";
char dot_dlt[] = "DLT";
char dot_pi1[] = "PI1";
char dot_pc1[] = "PC1";
char dot_bl1[] = "BL?";
char dot_str[] = "STR";
char dot_ado[] = "ADO";

char *file_suffixes[] =
	{
	dot_seq,
	dot_neo,
	dot_cel,
	dot_col,
	dot_str,
	dot_dlt,
	dot_pi1,
	dot_pc1,
	dot_bl1,
	dot_ado,
	};

get_title(with)
char *with;
{
register char *suffix;
char buf[40];

suffix = file_suffixes[save_file_type];
sprintf(buf, "%s %s File", with, suffix);
jimints_off();
set_for_gem();
gmessage(buf);
title = get_fname(suffix);
buf[0] = '.';
strcpy(buf+1, suffix);
suffix = buf;
if (title != NULL)
	{
	if (save_file_type == BL1)
		{
		suffix = title + strlen(title) - 1;
		if (suffix[0] == '?')
			suffix[0] = '1';
		suffix = ".BL1";
		}
	if (!suffix_in(title, suffix))
		{
		strcat(title, suffix);
		}
	}
set_for_jim();
return(title != NULL);
}

static char *oold[] = {
	"Write over old",
	NULL,
	NULL,
	};

overwrite_old(name)
char *name;
{
char sbuf[128];

sprintf(sbuf,"%s?", name);
oold[1] = sbuf;
return(yes_no_from(oold));
}


#ifdef SLUFFED
read_only(type)
char *type;
{
char buf1[40];
char *ronly[3];

ronly[0] = "Sorry, can only load";
ronly[1] = buf1;
ronly[2] = NULL;
sprintf(buf1, ".%s files", type);
continu_from(ronly);
}
#endif SLUFFED

char *wronly[] = {
	"Sorry, can only save",
	".STR files",
	NULL,
	};

write_only()
{
continu_from(wronly);
}

confirm_lots_cels()
{
char *lots[6];
char buf1[40];

lots[0] = "Save animation as .STR file";
lots[1] = "for use in Aegis Animator?";
lots[2] = "this will save each frame as";
lots[3] = buf1;
lots[4] = "CEL files (might take a while)?";
lots[5] = NULL;
sprintf(buf1, "a .CEL.  Ready to create %d", screen_ct);
return( yes_no_from(lots));
}


#ifdef SLUFFED
char *
pic_suffix()
{
switch (save_file_type)
	{
	case PI1:
		return(dot_pi1);
	case PC1:
		return(dot_pc1);
	case NEO:
		return(dot_neo);
	}
}
#endif SLUFFED

char *delete_for_sure[5] =
	{
	"Do you really want",
	"to remove the file",
	NULL,
	"from disk forever??",
	NULL,
	};

do_kill()
{
char *suffix;
char buf[20];

if (get_title("Kill") )
	{
	delete_for_sure[2] = title;
	if (yes_no_from(delete_for_sure))
		Fdelete(title);
	}
jimints_on();
hide_mouse();
redraw_menu_frame();
show_mouse();
}

confirm_segment_save()
{
if (select_mode != 1)	/* not segment */
	return(1);
return( really_segment("Save segment only?", NULL) );
}

do_save()
{
char *suffix;
char buf[20];
int fd;

switch(save_file_type)
	{
	case SEQ:
		if (!confirm_segment_save())
			goto end;
		break;
	case CEL:
	case BL1:
		if (  clipping == NULL)
			{
			continu_line("No Clip to Save!");
			goto end;
			}
		break;
	case NEO:
	case COL:
	case PI1:
	case PC1:
	case ADO:
		break;
	case DLT:
		if (!confirm_segment_save())
			goto end;
		break;
	case STR:
		if (!confirm_lots_cels())
			goto end;
		break;
#ifdef SLUFFED
	default:
		read_only(file_suffixes[save_file_type] );
		goto end;
#endif SLUFFED
	}
degas = (save_file_type == PI1 || save_file_type == DLT);
get_title("Save");
if (title != NULL)
	{
	clear_screen();
	if ( (fd = Fopen(title, 0)) >= 0)
		{
		int query = 1;

		Fclose(fd);
		if (save_file_type == SEQ || save_file_type == DLT)
			{
			if (got_patch)
				{
				if (strcmp(patch_name, title) == 0)
					{
					continu_line("Pick patch to save patch.");
					goto end;
					}
				}
			if (select_mode != 1 && !rd_more) /* not segment or more */
				{
				if (strcmp(rd_name, title) == 0)
					{
					query = 0;	/* let overwrite on edit w/out hassle */
					}
				}
			}
		if (query)
			{
			if (!overwrite_old(title))
				{
				goto end;
				}
			}
		}
	switch (save_file_type)
		{
		case SEQ:
			save_seq(title);
			if (select_mode != 1)	/* not segment */
				dirty_file = 0;
			break;
		case NEO:
		case PI1:
			save_pic(title);
			break;
		case PC1:
			save_pc1(title);
			break;
		case CEL:
			save_cel(title);
			break;
		case COL:
			save_col(title);
			break;
		case DLT:
			if (select_mode != 1)
				dirty_file = 0;
			save_dlt(title);
			break;
		case STR:
			save_str(title);
			break;
		case ADO:
			save_ado(title);
			break;
		case BL1:
			save_bl1(title);
			break;
		}
	}
end:
jimints_on();
hide_mouse();
redraw_menu_frame();
show_mouse();
}

WORD old_cmap[COLORS];

go_ldpic()
{
int i;
int ok;

if (normal_over_under != 0)
	{
	if (!over_many())
		{
		return;
		}
	}
copy_structure(sys_cmap, old_cmap, sizeof(old_cmap) );
get_title("Load");
if (title != NULL)
	{
	copy_screen(bscreen, uscreen);
	if (save_file_type == PC1)
		ok = read_pc1(title);
	else
		ok = load_pic(title);
	dirtys();
	}
hide_mouse();
if (title != NULL && ok)
	{
	if (normal_over_under != 0)
		{
		underlay_pic();
		}
	}
jimints_on();
redraw_menu_frame();
show_mouse();
}

ovun_copy()
{
if (normal_over_under == 1)
	zscopy_screen(pscreen, bscreen, pscreen);
else
	zscopy_screen(bscreen, pscreen, pscreen);
}

underlay_pic()
{
WORD oscreen_ix = screen_ix;
WORD i;
Cel cel2;
WORD cmap2[COLORS];

/* on entry original frame held in uscreen/old_cmap, new frame in
   bscreen/sys_cmap */
copy_words(sys_cmap, cel2.cmap, COLORS );	/* grab color map */
copy_words(sys_cmap, cmap2, COLORS );		/* grab color map */
cel2.width = 320;
cel2.height = 200;
cel2.image = bscreen;
put_cmap(old_cmap);	/* restore color map */
copy_screen(uscreen, pscreen);	/* restore orig screen */
if (select_mode == 0)
	{
	if (!cfit_cel(&cel2))
		{
		copy_screen(pscreen, bscreen);
		outta_memory();
		return;
		}
	ovun_copy();
	copy_screen(pscreen, bscreen);
	dirtys();
	return;
	}
else
	{
	copy_screen(bscreen, uscreen);	/* save copy of pic just loaded*/
	clean_ram_deltas(pscreen);	/* save whatever changes... */
	dirtys();
	find_start_stop();		/* get section to effect */
	tseek(start_frame, pscreen);
	for (i=start_frame; i<=stop_frame; i++)
		{
		if (!words_same(cel2.cmap, sys_cmap, COLORS))
			{
			copy_screen(uscreen, bscreen);
			copy_words(cmap2, cel2.cmap, COLORS);
			if (!cfit_cel(&cel2))
				{
				outta_memory();
				break;
				}
			}
		ovun_copy();
		if (!s_ram_deltas(pscreen))
			{
			outta_memory();
			break;
			}
		screen_ix += 1;
		if (screen_ix < screen_ct)
			{
			advance_next_prev(pscreen);
			see_frame(pscreen, 1);
			}
		}
ENDOFIT:
	abs_tseek(oscreen_ix, bscreen);	/* restore current frame */
	copy_screen(bscreen, uscreen);
	}
}

go_ldbl1()
{
get_title("Load");
if (title != NULL)
	load_bl1(title);
hide_mouse();
buf_to_screen();
if (title != NULL && clipping != NULL)
	{
	rub_paste(clipping, 0, 0);	/* flash cel up on screen a second so user knows 
								it's really loaded */
	wait_a_jiffy(20);
	}
jimints_on();
redraw_menu_frame();
show_mouse();
}


go_ldcel()
{
get_title("Load");
hide_mouse();
if (title != NULL)
	load_cel(title);
buf_to_screen();
if (title != NULL && clipping != NULL)
	{
	rub_paste(clipping, 0, 0);	/* flash cel up on screen a second so user knows 
								it's really loaded */
	wait_a_jiffy(20);
	}
jimints_on();
redraw_menu_frame();
show_mouse();
}

go_ldado()
{
get_title("Load");
if (title != NULL)
	load_ado(title);
hide_mouse();
jimints_on();
redraw_menu_frame();
show_mouse();
}

extern WORD save_cmap[];

go_ldcol()
{
WORD ok;

copy_words(sys_cmap, save_cmap, COLORS); /* save copy for multi-seg restore */
get_title("Load");
if (title != NULL)
	{
	if (load_col(title))
		{
		dirtys();
		if (select_mode != 0)
			{
			hide_mouse();
			copy_screen(bscreen, pscreen);
			show_mouse();
			confirm_c_many(0, COLORS-1);
			}
		}
	}
hide_mouse();
jimints_on();
redraw_menu_frame();
show_mouse();
}

WORD pffx, pffy;

position_first_frame()
{
WORD startx, starty;
Cel *fframe, *oclip;

pffx = pffy = 0;
fframe = load_first_frame(title);
hide_mouse();
if (fframe)
	{
	startx = fframe->xoff;
	starty = fframe->yoff;
	restore_menu();
	oclip = clipping;
	clipping = fframe;
	position_clip();
	clipping = oclip;
	hide_mouse();
	save_menu();
	draw_on_screen();
	pffx = fframe->xoff - startx;
	pffy = fframe->yoff - starty;
	free_cel(fframe);
	}
return(fframe != NULL);
}

char *confirm_splice[] =
	{
	"Splice SEQ to end of",
	"sequence in memory?",
	"     (no undo)",
	NULL,
	};

load_splice(name)
char *name;
{
hide_mouse();
copy_screen(bscreen, pscreen);
tseek(screen_ct-1, pscreen);
copy_screen(pscreen, bscreen);
if (!position_first_frame())
	return;
if (yes_no_from(confirm_splice))
	{
	l_splice(name, pffx, pffy);
	dirty_file = 1;
	}
}

char *confirm_overlay[] =
	{
	"Merge in this .SEQ",
	"starting with this frame?",
	"     (no undo)",
	NULL,
	};

load_overlay()
{
if (normal_over_under == NOU_OVER || normal_over_under == NOU_UNDER)
	{
	if (!position_first_frame())
		return;
	if (yes_no_from(confirm_overlay))
		{
		load_seq_overlay(title, normal_over_under, pffx, pffy);
		dirty_file = 1;
		}
	}
else
	{
	load_seq_overlay(title, normal_over_under, pffx, pffy);
	dirty_file = 1;
	}
}

char *more_lines[] =
	{
	"File too large to fit into",
	"memory.  Select more in",
	"Time dialog to view rest",
	"of file.",
	NULL,
	};

go_ldseq()
{
get_title("Load");
hide_mouse();
if (title != NULL)
	{
	rd_more = 0;
	rd_abort = 0;
	strcpy(rd_name, title);
	if (degas)
		{
		load_dlt(title);
		dirty_file = 0;
		}
	else
		{
		if (normal_over_under == NOU_NORMAL)
			{
			load_seq(title);
			dirty_file = 0;
			}
		else if (normal_over_under == NOU_SPLICE)
			load_splice(title);
		else
			load_overlay();
		}
	}
jimints_on();
redraw_menu_frame();
if (title != NULL && rd_more && !rd_abort)
	{
	continu_from_menu(more_lines);
	}
show_mouse();
}


Vector load_functs[] =
	{
	go_ldseq, 
	go_ldpic,
	go_ldcel,
	go_ldcol,
	write_only,
	go_ldseq, 
	go_ldpic,
	go_ldpic,
	go_ldbl1,
	go_ldado,
	};

do_load()
{
Vector pt;

degas = (save_file_type == PI1 || save_file_type == DLT);
if ((pt = load_functs[save_file_type]) != NULL)
	{
	(*pt)();
	}
}


new_file_type(m)
Flicmenu *m;
{
unhi_group(&menu_save, m->group);
*(m->group) = m->identity;
hi_group(&menu_save, m->group);
}

sadd_10(m)
struct Flicmenu *m;
{
hide_mouse();
hilight(m);
clean_ram_deltas(bscreen);
add_empties_at_end(10);
update_next_prev(bscreen);
draw_sel(m);
draw_sel(&sframe_sel);
show_mouse();
}


splay_backwards(m)
Flicmenu *m;
{
aplay_backwards(m, &sframe_sel);
}

splay_forwards(m)
Flicmenu *m;
{
aplay_forwards(m, &sframe_sel);
}

srewind(m)
Flicmenu *m;
{
arewind(m, &sframe_sel);
}

sfast_forward(m)
Flicmenu *m;
{
afast_forward(m, &sframe_sel);
}

sgo_last(m)
Flicmenu *m;
{
ago_last(m, &sframe_sel);
}

sgo_first(m)
struct Flicmenu *m;
{
ago_first(m, &sframe_sel);
}

smlast_frame(m)
struct Flicmenu *m;
{
amlast_frame(m, &sframe_sel);
}

smnext_frame(m)
struct Flicmenu *m;
{
amnext_frame(m, &sframe_sel);
}

sappend(m)
struct Flicmenu *m;
{
aappend(m);
draw_sel(m);
draw_sel(&sframe_sel);
draw_sel(&sframes_sel);
show_mouse();
}

sinsert(m)
struct Flicmenu *m;
{
ainsert(m);
draw_sel(m);
draw_sel(&sframe_sel);
draw_sel(&sframes_sel);
show_mouse();
}

change_dev(m)
Flicmenu *m;
{
if (Dsetdrv(m->identity) >= 0)
	{
	change_mode(m);
	init_fname();
	}
}

go_save()
{
hide_mouse();
draw_a_menu(&menu_save);
do_menu(&menu_save);
}
