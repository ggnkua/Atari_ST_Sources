/* :ts=3 */

overlay "menu"

#ifdef NEVER
#define NOSAVE
#endif NEVER

#include <stdio.h>
#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\clip.h"
#include "..\\include\\color.h"
#include "..\\include\\acts.h"
#include "..\\include\\addr.h"
#include "..\\include\\menu.h"
#include "..\\include\\story.h"
#include "..\\include\\format.h"
#include "..\\include\\animath.h"
#include "..\\include\\control.h"
#include "..\\include\\script.h"
#include "..\\include\\io.h"
#include "..\\include\\poly.h"
#include "..\\include\\raster.h"
#include "..\\include\\replay.h"
#include "..\\include\\digitgau.h"

extern Script *cur_sequence;
extern struct cursor question_cursor, undo_cursor;
extern struct cursor box_cursor, wait_cursor, select_cursor;
extern crude_help(), cin_color(), solid_block();
extern hide_menu(), move_menu();
extern gen_cd(), snap_shot(), swap_undo();
extern WORD see_beginning;
extern Poly *which_poly();
extern WORD *act_from_poly();
extern Name_list *file_lst;
extern char *make_file_name();
extern struct name_list *sort_nlist();
extern char *cut_string();


#ifdef AMIGA
char *dot_script = ".script";
char *dot_pic = ".pic";
char *dot_win = ".win";
char *dot_msk = ".msk";
char *dot_poly = ".poly";
char *dot_col = ".col";
char *dot_strip = ".strip";
#endif AMIGA

#ifdef ATARI
char *dot_script = ".SCR";
char *dot_pic = ".NEO";
char *dot_pi1 = ".PI1";
char *dot_win = ".CEL";
char *dot_msk = ".MSK";
char *dot_poly = ".POL";
char *dot_col = ".COL";
char *dot_strip = ".STR";
#ifdef SLUFFED
char *dot_seq = ".SEQ";
#endif SLUFFED
#endif ATARI

char storage_help[] = "select title, suffix, action";

extern char *cut_suffix();

extern int get_bak();
extern int text_in_box();
extern int see_scroller();

extern int do_scroller();
extern char *getline();
extern int just_text();
extern int new_mode();
extern int  save_sequence();
extern struct digit_gauge sloop_gauge;
extern char *title;
static char *suffix;


struct select_column script_names = 
	{
	NULL,
	0,
	0,
	0,
	0,
	};


show_title(m,sel,color)
register struct menu *m;
register struct selection *sel;
int color;
{
sel_text(title,m,sel,color);
}

sel_text(string,m,sel,color)
char *string;
register struct menu *m;
register struct selection *sel;
int color;
{
gtext(string, m->xoff+sel->x_min_pos, m->yoff+sel->y_min_pos, color);
}

#ifdef ATARI
#define LB_MAX 13
#endif ATARI
#ifdef AMIGA
#define LB_MAX 33
#endif ATARI

char *
getline(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
static char line_buffer[LB_MAX];
register char *lpt = line_buffer;
register char c;

whipe_sel(m,sel);
sel->display_data = lpt;
*lpt = 0;
for(;;)
	{
	vis = await_keydn(USE_CURSOR);
	if (vis->result & CANCEL)
		{
		whipe_sel(m,sel);
		sel_text(line_buffer,m,sel,fore_color);
		return(NULL); /*cancel return: keep old name*/
		}
	c = vis->data;
#ifdef ATARI
	/* convert to upper case */
	if (c >= 'a' && c <= 'z')
		c += 'A' - 'a';
#endif ATARI
	switch(c)
		{
		case '\r':
		case '\n':
			return(line_buffer);
		case '\b':  /*backspace*/
			if (lpt>line_buffer)
			*(--lpt)=0;
			break;
		case 0:
			break;
		default:
			if (lpt < line_buffer+ LB_MAX - 1)
				{
				*(lpt++) = c;
				*lpt = 0;
				}
		break;
		}
	whipe_sel(m,sel);
	sel_text(line_buffer,m,sel,fore_color);
	}
}

save_bak(name)
char *name;
{
#ifdef DEBUG
ldprintf("save_bak(%s)\n",name);
#endif DEBUG
set_d2_back();
see_seq(cur_sequence);
set_d2_front();
save_frame(name);
}



load_bak(name)
char *name;
{
#ifdef ATARI
extern WORD *bbm;
#endif ATARI
#ifdef AMIGA
extern struct BitMap *bbm;
#endif AMIGA

extern char *bbm_name;

#ifdef DEBUG
ldprintf("load_bak(%s)\n",name);
#endif DEBUG
if ( bbm = load_background(name))
	{
	save_undo();
	code(cur_sequence,
	LOAD_BACKGROUND, -2, 0, 0, bbm_name);
	code(cur_sequence,
	INIT_COLORS, -1, 0, MAXCOL, usr_cmap);
	retween_poly_list(cur_sequence);
	}
}

load_col(name)
char *name;
{
if (load_colors(name) )
	{
	save_undo();
	code(cur_sequence,
	INIT_COLORS, -1, 0, MAXCOL, usr_cmap);
	retween_poly_list(cur_sequence);
	put_cmap(usr_cmap, 0, MAXCOL);
#ifdef PL_CHANGE
	copy_structure(usr_cmap, cur_sequence->poly_list->cmap,
	MAXCOL * sizeof(struct color_def) );
#endif PL_CHANGE
	}
}


get_file_name(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
char *fname;
Name_list *nl;

show_help("type file name, return at end");
fname = getline(m,sel,vis);
if (fname)
	{
	free_string(title);
	title = clone_string(fname);  /*copy for title buffer*/
	}
}


char *
extract_from_list(list, ix)
Name_list *list;
WORD ix;
{
while ( --ix >= 0)
	{
	if (!list)
	return("extract_what");
	list = list->next;
	}
return(list->name);
}

storage_bars(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
if (script_names.name_count > 0)
	{
	do_scroller(m,sel,vis);
	free_string(title);
	title =  clone_string(
		extract_from_list(script_names.name_list, script_names.selected)  );
	}
}

#define DSCRIPT 0
#define DPIC	1
#define DPI1	2
#define DTEXT	3
#define DWIN	4
#define DMSK	5
#define DPOLY	6
#define DCOL	7
#define DSTRIP	8

WORD file_type = DSCRIPT;


struct one_of script_node =
	{
	&file_type,
	DSCRIPT,
	dot_script,
	};

struct one_of pic_node =
	{
	&file_type,
	DPIC,
	dot_pic,
	};

struct one_of pi1_node =
	{
	&file_type,
	DPI1,
	dot_pi1,
	};

struct one_of win_node =
	{
	&file_type,
	DWIN,
	dot_win,
	};

struct one_of msk_node =
	{
	&file_type,
	DMSK,
	dot_msk,
	};

struct one_of poly_node =
	{
	&file_type,
	DPOLY,
	dot_poly,
	};

struct one_of col_node =
	{
	&file_type,
	DCOL,
	dot_col,
	};

struct one_of strip_node =
	{
	&file_type,
	DSTRIP,
	dot_strip,
	};

change_file_mode(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
new_mode(m,sel,vis);
init_script_names();
}

init_script_names()
{
struct name_list *fl = file_lst; 
Name_list *next = NULL;
char *str;

switch(file_type)
	{
	case DSCRIPT:
		suffix = dot_script;
		break;
	case DPIC:
		suffix = dot_pic;
		break;
	case DPI1:
		suffix = dot_pi1;
		break;
	case DWIN:
		suffix = dot_win;
		break;
	case DMSK:
		suffix = dot_msk;
		break;
	case DPOLY:
		suffix = dot_poly;
		break;
	case DCOL:
		suffix = dot_col;
		break;
	case DSTRIP:
		suffix = dot_strip;
		break;
	default:
		suffix = "";
		break;
		}

free_name_list(script_names.name_list);
script_names.name_list = NULL;
script_names.name_count = 0;
script_names.top_name = 0;
script_names.selected = 0;
while (fl)
	{
	if (suffix_in(fl->name, suffix))
		{
		str = cut_suffix(fl->name, suffix);
		next = (Name_list *)alloc(sizeof(Name_list) );
		if (next)
			{
			next->name = str;
			next->next = script_names.name_list;
			script_names.name_list = next;
			script_names.name_count++;
			}
		}
	fl = fl->next;
	}
script_names.name_list = sort_nlist(script_names.name_list);
}

norecurse(name, strip)
char *name;
Script *strip;
{
Script **kids;
WORD i;

i = strip->child_count;
kids = strip->child_scripts;
while (--i >= 0)
	{
	strip = *kids++;
	if (jstrcmp(name, strip->name) == 0)
		return(0);
	if (!norecurse(name, strip) )
		return(0);
	}
return(1);
}

#ifdef ATARI
busy_mouse()
{
show_mouse();
graf_mouse(2, NULL);	/* bumblebee */
}
#endif ATARI

gen_save(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
#ifndef NOSAVE
char *true_name;
Name_list *next;
WORD dosave;
char *same_as;

#ifdef AMIGA
bye_to_menu_bars();
#endif AMIGA
dosave = 1;
true_name = clone_string(lsprintf("%s%s",title,suffix) ) ;
	/*don't always use same_as, but code WORDer this way...*/
same_as = clone_string(lsprintf("overwrite old %s?", 
	true_name) );
if (file_type != DSCRIPT)	/*scripts let you update without questions...*/
	{
	if (in_name_list(true_name, file_lst)  )
	dosave = confirm(m, sel, vis, same_as);
	}
if (dosave)
	{
	maybe_clear_menu(m);
	new_cursor(&wait_cursor);
	switch(file_type)
		{
		case DSCRIPT:
			if ( in_name_list(title, script_names.name_list) )
				{
				if (jstrcmp( true_name, cur_sequence->name) != 0)
					{
					dosave = confirm(m, sel, vis, same_as );
					}
				else
					dosave = 1;
				}
			else
				dosave = 1;
			if (dosave)
				{
#ifdef ATARI
	busy_mouse();
#endif ATARI
				sv_scr(true_name, cur_sequence, 0);
#ifdef ATARI
	hide_mouse();
#endif ATARI
				free_string(cur_sequence->name);
				cur_sequence->name = clone_string( title );
				}
			break;
		case DPIC:
#ifdef ATARI
	busy_mouse();
#endif ATARI
			save_bak(true_name);
#ifdef ATARI
	hide_mouse();
#endif ATARI
			break;
		case DPI1:
#ifdef ATARI
	busy_mouse();
#endif ATARI
			save_bak(true_name);
#ifdef ATARI
	hide_mouse();
#endif ATARI
			break;
		case DWIN:
			{
			WORD x0, x1, y0, y1;
			register struct atari_cel *cel;
			extern WORD *s2;

			show_help("make a frame around area to save");
			if (get_frame(&x0, &y0, &x1, &y1))
				{
				cel = init_atari_cel(x1 - x0, y1 - y0);
				if (cel)
					{
					set_d2_back();
					make_frame(cur_sequence);
					set_d2_front();
					copy_blit(x1 - x0, y1 - y0, x0, y0, s2, 160,
					0, 0, cel->form, cel->nxln);
#ifdef ATARI
		busy_mouse();
#endif ATARI
					save_window(true_name, cel, x0, y0);
#ifdef ATARI
		hide_mouse();
#endif ATARI
					free_atari_cel(cel);
					show_help(storage_help);
					}
				}
			}
			break;
		case DMSK:
			{
			WORD x0, x1, y0, y1;
			register struct bit_plane *mask;
			extern WORD *s2;

			show_help("make a frame around area to save");
			if (get_frame(&x0, &y0, &x1, &y1))
				{
				mask = init_bit_plane(x1 - x0, y1 - y0);
				if (mask)
					{
					set_d2_back();
					make_frame(cur_sequence);
					set_d2_front();
					win2msk_blit(x1 - x0, y1 - y0, x0, y0, s2, 160,
					0, 0, mask->plane, mask->words_per_line<<1);
#ifdef ATARI
		busy_mouse();
#endif ATARI
					save_mask(true_name, mask, x0, y0);
#ifdef ATARI
		hide_mouse();
#endif ATARI
					free_bit_plane(mask);
					show_help(storage_help);
					}
				}
			}
			break;
		case DPOLY:
			{
			register Poly *poly;
			WORD poly_ix;
			WORD *act;
			FILE *fp;
			char *confirm_string;
			extern WORD s_mode;

			clear_menu(m);
			show_help("pick polygon to save");
			new_cursor(&select_cursor);
			vis = await_anydn(USE_CURSOR);
			if ( pjstdn(vis) )
			poly = which_poly(vis, cur_sequence, &poly_ix);
			if (poly && !(poly->type & IS_RASTER))
				{
				draw_pledge(poly, cycle_color, cur_sequence);
				confirm_string = clone_string(lsprintf("save poly as %s?",
					true_name)  );
				if (confirm(m, sel, vis, confirm_string) )
					{
#ifdef ATARI
	busy_mouse();
#endif ATARI
					fp = fopen(make_file_name(true_name), "w");
					if (fp != NULL)
						{
						act = act_from_poly(poly, 0, cur_sequence);
						if (act)
							{
							c_act(fp, act, 0);
							free_tube(act);
							}
						fclose(fp);
						show_help(storage_help);
						}
#ifdef ATARI
	hide_mouse();
#endif ATARI
					}
				free_string(confirm_string);
				}
			draw_cur_frame(m);
			}
			break;
		case DCOL:
#ifdef ATARI
	busy_mouse();
#endif ATARI
			save_colors(true_name);
#ifdef ATARI
	hide_mouse();
#endif ATARI
			break;
		case DSTRIP:
			if (norecurse(true_name, cur_sequence) )
				{
#ifdef ATARI
	busy_mouse();
#endif ATARI
				sv_scr(true_name, cur_sequence, 1);
#ifdef ATARI
	hide_mouse();
#endif ATARI
				}
			else
				ok_boss("strip would include itself");
			break;
#ifdef PARANOID
		default:
			ldprintf("\nunknown case %d in gen_save()\n",file_type);
			break;
#endif PARANOID
		} 
	if (!in_name_list(true_name, file_lst)  )
		{
		WORD otop;

		otop = script_names.top_name;
		add_file_to_list(true_name);
		init_script_names();
		script_names.top_name = otop;
		}
	}
free_string(true_name);
free_string(same_as);
new_cursor(&select_cursor);
#ifdef AMIGA
bring_back_menu_bars();
#endif AMIGA
#endif NOSAVE
}


extern struct raster_list *raster_master;
extern struct cursor grab_cursor;
extern struct s_sequence *ld_scr();

gen_load(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
char *true_name;
struct raster_list *next_raster;
struct s_sequence  *seq;
WORD orgx, orgy;

#ifdef AMIGA
bye_to_menu_bars();
#endif AMIGA

true_name = clone_string(lsprintf("%s%s",title,suffix) ) ;
clear_menu(m);
#ifdef AMIGA
new_cursor(&wait_cursor);
#endif AMIGA
switch(file_type)
	{
	case DSCRIPT:
		{
		/*if seems like actually going to load something, yeah
		  free up everything we can first*/
		if (in_name_list(true_name, file_lst))
			{
			free_background();
			free_undo();
			}
#ifdef ATARI
	busy_mouse();
#endif ATARI
		seq = ld_scr(true_name);
#ifdef ATARI
	hide_mouse();
#endif ATARI
		if (seq)
			{
			adjust_pos_in_tween(seq);
			save_undo();
			free_s_sequence(cur_sequence);
			cur_sequence = seq;
			}
		}
	break;
	case DPIC:
		{
#ifdef ATARI
busy_mouse();
#endif ATARI
		load_bak(true_name);
#ifdef ATARI
hide_mouse();
#endif ATARI
		}
	break;
	case DPI1:
		{
#ifdef ATARI
busy_mouse();
#endif ATARI
		load_bak(true_name);
#ifdef ATARI
hide_mouse();
#endif ATARI
		}
	break;
	case DWIN:
		{
		register struct atari_cel *bp;
		register WORD *act;
		WORD x0, x1, y0, y1;
		WORD new;
		struct atari_form form;

		if (next_raster = (struct raster_list *)
			in_name_list(true_name, raster_master))
			{
			bp = (struct atari_cel *)next_raster->raster;
			orgx = x0 = x1 = next_raster->xoff;
			orgy = y0 = y1 = next_raster->yoff;
			x1 += bp->width;
			y1 += bp->height;
			new = 0;
			}
		else
			{
#ifdef ATARI
busy_mouse();
#endif ATARI
			bp = load_window(true_name, &x0, &y0, &x1, &y1);
#ifdef ATARI
hide_mouse();
#endif ATARI
			orgx = x0;
			orgy = y0;
			new = 1;
			}
		if (bp)
			{
			if (!next_raster)
				{
				next_raster = Alloc_z(struct raster_list);
				next_raster->type = ATARI_CEL;
				next_raster->raster = (RASTER_POINTER)bp;
				}
			form.type = ATARI_CEL;
			form.pad1 = form.pad2 = 0;
			form.padpt = NULL;
			form.origin.x = (x0+x1)>>1;
			form.origin.y = (y0+y1)>>1;
			form.origin.z = ground_z;
			form.raster = next_raster;
			show_help("move raster to desired position");
			new_cursor(&grab_cursor);
			move_rub_frame(&x0, &y0, &x1, &y1, &form);
			if (new)
				{
				Free_a(next_raster);
				next_raster = 
					add_new_raster(bp, ATARI_CEL, true_name,
						orgx, orgy);
				}
			if (next_raster)
				{
				add_raster_to_script(next_raster,
					cur_sequence, true_name);
				save_undo();
				cope_exchange();
				act = (WORD *)alloc( lof_type(INSERT_RASTER)
					* sizeof(WORD) );
				if (act)
					{
					act[0] = lof_type(INSERT_RASTER);
					act[1] = INSERT_RASTER;
					act[2] = cur_sequence->next_poly_list->count;
					*( (struct raster_list **)(act+3)) = next_raster;
					act[5] = (x0 + x1)/2 * VRES;
					act[6] = (y0 + y1)/2 * VRES;
					act[7] = ground_z;
					add_act( *(cur_sequence->next_tween), act);
					insert_poly_in_s_sequence(cur_sequence, act[2]);
					retween_poly_list(cur_sequence);
					show_help(storage_help);
					}
				}
			else
				if (new)
					{
					free_atari_cel(bp);
					}
			}
		}
	break;
	case DMSK:
		{
		register struct bit_plane *bp;
		register WORD *act;
		WORD x0, x1, y0, y1;
		WORD new;
		struct bitplane_raster msk;

		if (next_raster = (struct raster_list *)
			in_name_list(true_name, raster_master))
			{
			bp = (struct bit_plane *)next_raster->raster;
			x0 = x1 = next_raster->xoff;
			y0 = y1 = next_raster->yoff;
			x1 += bp->width;
			y1 += bp->height;
			new = 0;
			}
		else
			{
#ifdef ATARI
busy_mouse();
#endif ATARI
			bp = load_msk(true_name, &x0, &y0, &x1, &y1);
#ifdef ATARI
hide_mouse();
#endif ATARI
			orgx = x0;
			orgy = y0;
			new = 1;
			}
		if (bp)
			{
			if (!next_raster)
				{
				next_raster = Alloc_z(struct raster_list);
				next_raster->type = BITPLANE_RASTER;
				next_raster->raster = (RASTER_POINTER)bp;
				}
			msk.type = BITPLANE_RASTER;
			msk.color0 = ccolor;
			msk.origin.x = (x0+x1)>>1;
			msk.origin.y = (y0+y1)>>1;
			msk.origin.z = ground_z;
			msk.pad1 = msk.pad2 = 0;
			msk.padpt = NULL;
			msk.raster = next_raster;
			show_help("move stencil to desired position");
			new_cursor(&grab_cursor);
			move_rub_frame(&x0, &y0, &x1, &y1, &msk);
			if (new)
				{
				Free_a(next_raster);
				next_raster
					= add_new_raster(bp, BITPLANE_RASTER,true_name,
						orgx, orgy);
				}
			if (next_raster)
				{
				add_raster_to_script(next_raster,
					cur_sequence, true_name);
				save_undo();
				cope_exchange();
				act = (WORD *)alloc( lof_type(INSERT_STENCIL)
					* sizeof(WORD) );
				if (act)
					{
					act[0] = lof_type(INSERT_STENCIL);
					act[1] = INSERT_STENCIL;
					act[2] = cur_sequence->next_poly_list->count;
					*( (struct raster_list **)(act+3)) = next_raster;
					act[5] = (x0+x1)/2 * VRES;
					act[6] = (y0+y1)/2 * VRES;
					act[7] = ground_z;
					act[8] = ccolor;
					add_act( *(cur_sequence->next_tween), act);
					insert_poly_in_s_sequence(cur_sequence, act[2]);
					retween_poly_list(cur_sequence);
					show_help(storage_help);
					}
				}
			else
				{
				if (new)
					free_bit_plane(bp);
				}
			}
		}
	break;
	case DPOLY:
	{
	struct poly *poly;
	extern Poly *load_poly();
	WORD *act;
	WORD lastx, lasty;

#ifdef ATARI
busy_mouse();
#endif ATARI
	poly = load_poly(true_name, cur_sequence);
#ifdef ATARI
hide_mouse();
#endif ATARI
	if (poly)
		{
		save_undo();
		draw_pl_with(poly, cur_sequence);
		show_help("move polygon to desired position");
		new_cursor(&grab_cursor);
		vis = await_anydn(USE_CURSOR);
		if ( pjstdn(vis) )
			{
			lastx = vis->curx * VRES;
			lasty = vis->cury * VRES;
			for (;;)
				{
				rub_poly(poly, cur_sequence);
				vis = quick_input();
				unrub_poly(poly, cur_sequence);
				if (!pdn(vis))
					break;
				move_poly(poly, poly,
					vis->curx * VRES - lastx, vis->cury * VRES - lasty);
				lastx = vis->curx * VRES;
				lasty = vis->cury * VRES;
				}
			}
		cope_exchange();
		act =
			act_from_poly(poly,
			cur_sequence->next_poly_list->count, cur_sequence);
		if (act)
			{
			cur_sequence->next_poly_list->count++;
			cken_polys(cur_sequence);
			copy_poly(poly,
			*(cur_sequence->next_poly_list->list + act[2])  );
			add_act(*(cur_sequence->next_tween), act );
			insert_poly_in_s_sequence(cur_sequence, act[2]);
			retween_poly_list(cur_sequence);
			show_help(storage_help);
			}
		free_poly(poly);
		}
	}
	break;
	case DCOL:
#ifdef ATARI
busy_mouse();
#endif ATARI
	load_col(true_name);
#ifdef ATARI
hide_mouse();
#endif ATARI
	break;
	case DSTRIP:
		{
		register WORD *act;
		WORD new;
		Square sq;
		struct ani_strip strip;
		WORD strip_ix;

		next_raster = (struct raster_list *)in_name_list(true_name,
			raster_master);
		if (!next_raster)
			{
#ifdef ATARI
busy_mouse();
#endif ATARI
			seq = ld_scr(true_name);
#ifdef ATARI
hide_mouse();
#endif ATARI
			new = 1;
			}
		else
			{
			seq = (Script *)next_raster->raster;
			new = 0;
			}
		if (!seq)
			break;

		strip_ix = add_a_strip(seq, cur_sequence);
		if (!bbox_script(seq, &sq) )
			{
			sq.x = sq.y = 0;
			sq.X = XMAX;
			sq.Y = YMAX;
			}
		strip.type = ANI_STRIP;
		strip.xhot = strip.origin.x = (sq.x + sq.X)/2;
		strip.yhot = strip.origin.y = (sq.y + sq.Y)/2;
		strip.zhot = strip.origin.z = ground_z;
		strip.script_ix = strip_ix;
		strip.padpt = NULL;
		strip.pad1 = strip.pad2 = 0;
		show_help("move strip to initial position\n");
		new_cursor(&grab_cursor);
		move_rub_frame( &sq.x, &sq.y, &sq.X, &sq.Y, &strip); 
		sloop_menu(m, sel, vis);
		if (!next_raster)
		next_raster = add_new_raster(seq, ANI_STRIP, true_name,
			sq.x, sq.y);
		add_raster_to_script(next_raster, cur_sequence, true_name);
		save_undo();
		cope_exchange();
		act = (WORD *)alloc( lof_type(INSERT_STRIP) * sizeof(WORD) );
		act[0] = lof_type(INSERT_STRIP);
		act[1] = INSERT_STRIP;
		act[2] = cur_sequence->next_poly_list->count;
		act[3] = strip_ix;
		act[4] = (sq.x + sq.X)/2;
		act[5] = (sq.y + sq.Y)/2;
		act[6] = ground_z;
		act[7] = strip.xhot;
		act[8] = strip.yhot;
		act[9] = strip.zhot;
		act[10] = 0;	/*forward offset units of 10000*/
		act[11] = 0;	/*forward offset units of 1*/
		act[12] = sloop_gauge.value;	/*times to loop, 0 = forever*/
		act[13] = 0;	/*speed if non-zero*/
		add_act( *(cur_sequence->next_tween), act);
		insert_poly_in_s_sequence(cur_sequence, act[2]);
		retween_poly_list(cur_sequence);
		show_help(storage_help);
		}
	break;
#ifdef PARANOID
	default:
	ldprintf("\nunknown case %d in gen_load()\n",file_type);
	break;
#endif PARANOID
	}
new_cursor(&select_cursor);
make_cur_frame(m);
free_string(true_name);
#ifdef AMIGA
bring_back_menu_bars();
#endif AMIGA
}


add_a_strip(child, script)
Script *child, *script;
{
Script **sc;
WORD scount;

scount = script->child_count;
sc = (Script **)alloc((scount+1) * sizeof(Script *));
copy_structure(script->child_scripts, sc, scount * sizeof(Script *));
child = sc[scount] = Clone_a(child, Script);
child->next_poly_list = empty_poly_list();
clone_kids(child, 1, 0);
loop_around_script(child);
if (!see_beginning)
	advance_timer(child, 
	 ((long)child->speed*(*(script->next_tween))->tweening)>>5,
	 REPLAY_LOOP);
m_frame(child);
mfree(script->child_scripts, scount *
	sizeof(Script *) );
script->child_scripts = sc;
script->child_count++;
return(scount);
}


free_last_strip(ss)
Script *ss;
{
Script **new_list;
WORD new_length;

ss->child_count -= 1;
rfree_s_sequence(ss->child_scripts[ss->child_count], 1);
new_length = (ss->child_count)*sizeof(Script *);
new_list = (Script **)clone_structure( ss->child_scripts, new_length);
mfree(ss->child_scripts, new_length + sizeof(Script *) );
ss->child_scripts = new_list;
}


gen_kill(m,sel,vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
char *true_name;
WORD otop;


true_name = clone_string(lsprintf("%s%s",title,suffix) ) ;
if (confirm( m, sel, vis, lsprintf("delete %s?", true_name) ))
	{
#ifdef ATARI
busy_mouse();
#endif ATARI
	if ( lunlink(true_name) != -1 )
		{
		otop = script_names.top_name;
		file_lst = remove_name_from_list( true_name, file_lst);
		init_script_names();
		if ( (script_names.top_name = otop - 1) < 0)
			script_names.top_name = 0;
		}
#ifdef ATARI
	hide_mouse();
#endif ATARI
	}
free_string(true_name);
}


struct selection storage_table[] = 
	{
		{
		MARGIN, MARGIN,
		MARGIN + CHAR_HEIGHT, CHAR_HEIGHT,

		0,

		(char *) &box_cursor,FIRST_TIME,
		cin_color,

		NULL, RETURN_SOMETHING,
		hide_menu,

		NULL,NO_DOUBLE,

		"close menu", crude_help,
		},

		{
		MARGIN + CHAR_HEIGHT + 1, MARGIN,
		M_WIDTH - MARGIN, CHAR_HEIGHT,

		0,

		(char *) 0,FIRST_TIME,
		solid_block,

		NULL, GO_SUB_REMENU,
		move_menu,

		NULL,NO_DOUBLE,

		"move menu", crude_help,
		},

		{
		2*MARGIN, S_HEIGHT/2 + CHAR_HEIGHT,
		8*S_WIDTH/2, 10*S_HEIGHT/2 + CHAR_HEIGHT + 4,

		0,

		(char *)&script_names, FIRST_TIME,
		see_scroller,

		NULL,GO_SUB_REMENU,
		storage_bars,

		NO_DOUBLE,NO_DOUBLE,

		"select file name", crude_help,
		},

#define COM_START (S_HEIGHT/2 + CHAR_HEIGHT)
		{
		13*S_WIDTH/2,COM_START,
		18*S_WIDTH/2, COM_START + S_HEIGHT/2,

		0,

		"load", FIRST_TIME,
		just_text,

		NULL,GO_SUBBER,
		gen_load,

		NO_DOUBLE,NO_DOUBLE,

		"load file", crude_help,
		},

#ifdef NOSAVE
		{
		13*S_WIDTH/2,COM_START + 2*S_HEIGHT/3,
		18*S_WIDTH/2, COM_START + 2*S_HEIGHT/3 + S_HEIGHT/2,

		0,

		"save", DISABLED,
		just_text,

		NULL,GO_SUB_REMENU,
		NULL,

		NO_DOUBLE,NO_DOUBLE,

		"save file", crude_help,
		},

#else NOSAVE
		{
		13*S_WIDTH/2,COM_START + 2*S_HEIGHT/3,
		18*S_WIDTH/2, COM_START + 2*S_HEIGHT/3 + S_HEIGHT/2,

		0,

		"save", FIRST_TIME,
		just_text,

		NULL,GO_SUB_REMENU,
		gen_save,

		NO_DOUBLE,NO_DOUBLE,

		"save file", crude_help,
		},
#endif NOSAVE

		{
		13*S_WIDTH/2,COM_START + 4*S_HEIGHT/3,
		18*S_WIDTH/2, COM_START + 4*S_HEIGHT/3 + S_HEIGHT/2,

		0,

		"kill", FIRST_TIME,
		just_text,

		NULL,GO_SUB_REMENU,
		gen_kill,

		NO_DOUBLE,NO_DOUBLE,

		"delete file", crude_help,
		},

		{
		13*S_WIDTH/2,COM_START + 6*S_HEIGHT/3,
		18*S_WIDTH/2, COM_START + 6*S_HEIGHT/3 + S_HEIGHT/2,

		0,

		"cd", FIRST_TIME,
		just_text,

		NULL,GO_SUB_REMENU,
		gen_cd,

		NO_DOUBLE,NO_DOUBLE,

		"change directory", crude_help,
		},


		{
		12*S_WIDTH/2, COM_START + 5*S_HEIGHT/2 + 6,
		14*S_WIDTH/2, COM_START + 7*S_HEIGHT/2 + 6,
		0,
		(char *)&camera_cursor, FIRST_TIME,
		cin_color,

		NULL, GO_SUBBER,
		snap_shot,

		NULL, NO_DOUBLE,

		"advance to next tween", crude_help,
		},


		{
		14*S_WIDTH/2, COM_START + 5*S_HEIGHT/2 + 6,
		16*S_WIDTH/2, COM_START + 7*S_HEIGHT/2 + 6,
		0,
		(char *)&undo_cursor, FIRST_TIME,
		cin_color,

		NULL, GO_SUB_REDRAW,
		swap_undo,

		NULL, NO_DOUBLE,

		"forget last action", crude_help,
		},


		{
		16*S_WIDTH/2, COM_START + 5*S_HEIGHT/2 + 6,
		18*S_WIDTH/2, COM_START + 7*S_HEIGHT/2 + 6,
		0,
		(char *)&question_cursor, FIRST_TIME,
		cin_color,

		NO_DATA,HELP,
		NULL,

		NO_DOUBLE,NO_DOUBLE,

		"explain icon", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,1*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 2*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&script_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"animation metamorphic script file", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,2*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 3*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&pic_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"full screen 16 color neochrome picture", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,3*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 4*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&pi1_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"full screen 16 color degas picture", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,4*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 5*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&win_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"16 color clipping off a picture", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,  5*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 6*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&msk_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"1 color image (mask) file", crude_help,
		},


		{
		-8 + 8*S_WIDTH/2,  6*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 7*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&poly_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"a single polygon", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,  7*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 8*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&col_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"color map - 16 colors", crude_help,
		},

		{
		-8 + 8*S_WIDTH/2,  8*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 9*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&strip_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"sub-animation file", crude_help,
		},

#ifdef LATER
		{
		-8 + 8*S_WIDTH/2,  8*S_HEIGHT/2 + CHAR_HEIGHT,
		-8 + 12*S_WIDTH/2, 9*S_HEIGHT/2 + CHAR_HEIGHT,

		0,

		(char *)&seq_node, ONE_OF,
		just_text,

		NULL,GO_SUB_REMENU,
		change_file_mode,

		NO_DOUBLE,NO_DOUBLE,

		"sequence of cels (raster) animation file", crude_help,
		},
#endif LATER


		{
		10*S_WIDTH/2, 9*S_HEIGHT/2 + CHAR_HEIGHT + 3,
		18*S_WIDTH/2, 11*S_HEIGHT/2 + CHAR_HEIGHT,

		1,  /*hilit permenantly */

		NULL, FIRST_TIME,
		show_title,

		NULL,GO_SUB_REMENU,
		get_file_name,

		NO_DOUBLE,NO_DOUBLE,

		"type in file name", crude_help,
		},

	
	};
	

struct menu storage_m =
	{
	1,
	1,
	XMAX - M_WIDTH - 1, YMAX - M_HEIGHT - CHAR_HEIGHT - 1,
	M_WIDTH, M_HEIGHT + CHAR_HEIGHT + S_HEIGHT/2,
	sizeof(storage_table) / sizeof(struct selection),
	sizeof(storage_table) / sizeof(struct selection),
	storage_table,
	await_input,
	0,
	0,
	};


#ifdef SLUFFED
char *last_path = NULL;
#endif SLUFFED


/*this is called as a SUB_MENU */
storage_menu(menu,sel,vis)
struct menu *menu;
struct selection *sel;
struct virtual_input *vis;
{
char *path;
struct control local_control;
char *str;

#ifdef DEBUG
ldprintf("\nstorage_menu()");
#endif DEBUG
if ( file_lst == NULL)
	{			/*if new disk or first time*/
	init_file_linked_list("");
	init_script_names();
	}
show_help(storage_help);

local_control.m = &storage_m;
local_control.sel = NULL;
local_control.vis = vis;

copy_menu_offsets(menu, &storage_m);

storage_m.visible = 1;
draw_menu(&storage_m);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(&storage_m);
#ifdef AMIGA
maybe_disable_move();
#endif AMIGA

copy_menu_offsets(&storage_m, menu);
}

#include "sloopdat.c"
