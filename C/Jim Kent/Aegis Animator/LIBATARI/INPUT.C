
overlay "find"

#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "..\\include\\lists.h"
#include "..\\include\\io.h"
#include "..\\include\\menu.h"
#include "..\\include\\story.h"
#include "..\\include\\script.h"
#include "..\\include\\vmodes.h"
#include "..\\include\\drawmode.h"
#include "..\\include\\poly.h"
#include "..\\include\\color.h"
#include "..\\include\\format.h"
#include "..\\include\\pull.h"


#define Gem_to_vis(a, b) ((a<<8) + b)
#define Gm_menu(a) (a>>8)
#define Gm_sel(a) (a&0xff)

#define MU_KEYBD 1
#define MU_BUTTON 2
#define MU_M1 4
#define MU_M2 8
#define MU_MESAG 16
#define MU_TIMER 32

extern char *aline;
extern WORD in_story_mode;
extern WORD ccolor;
extern WORD bop_mode;
extern WORD draw_mode;
extern WORD v_mode;
extern WORD s_mode;
extern WORD w_mode;
extern WORD ghost_mode;
extern WORD see_beginning;
extern WORD help_on;
extern WORD z_direction;
extern WORD rotate_axis;
extern (*v_dest)(), (*mv_dest)(), (*w_dest)();
extern struct menu morph_m;
extern struct selection morph_table[];
extern WORD glow_on;
extern WORD exchange_mode;
extern Pull root_pull, aroot_pull;

OBJECT *mmenu;
OBJECT *amenu;
Pull *pull_menu;

WORD contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];
WORD phys_handle, handle, wi_handle;

show_mouse()
{
v_show_c(handle, 0);
}

hide_mouse()
{
v_hide_c(handle, 0);
}


see_mbar()
{
pull_menu = &root_pull;
}

hide_mbar()
{
pull_menu = NULL;
}

see_abar()
{
pull_menu = &aroot_pull;
}

#ifdef SLUFFED
hide_abar()
{
pull_menu = NULL;
}
#endif SLUFFED

init_window()
{
WORD dummy, xdesk, ydesk, wdesk, hdesk;
WORD i;
WORD work_in[11];
WORD work_out[57];

phys_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
for (i=0; i<11; i++)
	{
	work_in[i] = 1;
	}
work_in[10] = 2;
v_opnvwk(work_in, &handle, work_out);
wi_handle = wind_create(0, xdesk, ydesk, wdesk, hdesk);
wind_open(wi_handle, xdesk, ydesk, wdesk, hdesk);
}

static char no_rsc[] =
"[0][ANI can't find ANI.RSC][SORRY]";

init_input()
{
if (!init_window())
	return(0);
hide_mouse();
return(1);
}


struct virtual_input virtual;
static WORD reuse = 0;

reuse_input()
{
reuse = 1;
}

struct virtual_input *
getcurvis()
{
return( &virtual);
}

sample_cancel()
{
unsigned WORD mousex, mousey, button;

vq_mouse(handle, &button, &mousex, &mousey);
return(button & 2);
}

sample_input()
{
register WORD ev_which = 0;
char message_buf[16];
unsigned WORD mousex, mousey, button;
unsigned long key;
static WORD steves = 0;
static WORD jims = 0;	/*like steves on other button */

if (glow_on)
	color_cycle(cycle_color);
/*get GEM's virtual input structure*/
vq_mouse(handle, &button, &mousex, &mousey);

/*do the xy pos part*/
virtual.curx = mousex;
virtual.cury = mousey;

/*start setting up the result*/

/*steves kinda funky way (oh its ok but been murrafied...) of
  setting up pjsdn() */
steves <<= 1;
if (  (button & 1) )
	steves |= 0x0001;
virtual.result = steves & 0x0003;

jims <<= 1;
if (button & 2)
	jims |= 1;
if ( (jims & 3) == 1)
	virtual.result |= CANCEL;

if (Cconis())
	{
	virtual.result |= KEYPRESS;
	key = Crawcin();
	virtual.data = (key>>8);	/* squeeze scan code into one byte */
	virtual.data += key;
	}
}

struct virtual_input *
getinput()
{
WORD pulled;

if (reuse)
	{
	reuse = 0;
	return(&virtual);
	}
sample_input();
if (pull_menu != NULL && (virtual.result & CANCEL) && virtual.cury < 10 )
	{
	pulled = pull(pull_menu);
	if (pulled >= 0)
		{
		virtual.result |= MENUPICKED;
		virtual.data = pulled;
		}
	}
return(&virtual);
}
		
gem_event(m, s, v)
register struct menu *m;
struct selection *s;
register struct virtual_input *v;
{
if (in_story_mode)
	do_story_menu(m, s, v);
else
	do_morph_menu(m, s, v);
}

static char abt_ani[] =
"[1][\
The Aegis Animator 2.10|\
   by Dancing Flame|\
   (c)1987 Jim Kent\
][ OK ]";

static char not_here1[] =
"[1][\
can't find|";
static char not_here2[] =
"][CONTINUE]";

write_error()
{
form_alert(1, "[1][Write Error!][CONTINUE]");
}

cant_find(name)
char *name;
{
extern char *lsprintf();

form_alert(1, lsprintf("%s%s%s", not_here1, name, not_here2));
}

ego_prop()
{
show_mouse();
form_alert(1, abt_ani);
hide_mouse();
}


#define ED_GO_INTO	0
#define ED_SPLICE	1
#define ED_CUT		2
#define ED_DELETE	3
#define ED_ACTIVATE	4
#define COUNT_ED	5

do_story_menu(m, s, v)
register struct menu *m;
struct selection *s;
register struct virtual_input *v;
{
register WORD which;
register WORD menu;

menu = v->data;
which = menu&0xff;
menu >>= 8;
switch ( menu )
	{
	case 0:
		switch(which)
			{
			case 0: /* about ani */
				ego_prop();
				break;
			case 1:	/* status */
				status_line();
				break;
			case 2:	/* quit */
				exit_anim(m, s, v);
				draw_cur_frame(NULL);
				break;
			}
		break;
	case 1:
		switch(which)
			{
			case 0:	/* go into */
				w_mode = WEDIT;
				w_dest = v_dest = w_table[WEDIT];
				show_help("select animation to enter");
				break;
			case 1:	/* splice */
				w_mode = WSPLICE;
				w_dest = v_dest = w_table[WSPLICE];
				break;
			case 2:	/* cut */
				w_mode = WSCISSORS;
				w_dest = v_dest = w_table[WSCISSORS];
				break;
			case 3:	/* delete */
				w_mode = WKILL;
				w_dest = v_dest = w_table[WKILL];
				break;
			case 4:	/* activate */
				w_mode = WACTIVATE;
				w_dest = v_dest = w_table[WACTIVATE];
				break;
			}
	break;
	}
amenu_hilights();
}

#define MU_UNDO		0
#define MU_HELP_BAR	1
#define MU_FAST_MENU	2

#define MK_POLY		0
#define MK_CIRCLE 	1
#define MK_STAR		2
#define MK_BLOCK 	3
#define MK_FILLED	5
#define MK_OUT_LINE	6
#define MK_LINE		7
#define MK_CLONE	9
#define MK_KILL		10
#define MK_INSERT	12
#define MK_EXCHANGE 13
#define COUNT_MK	14

#define MV_SIDEWAYS	0
#define MV_INTO		1
#define MV_OUT		2
#define MV_ROTATE	3
#define MV_XROTATE	4
#define MV_YROTATE	5
#define MV_BIGSMALL	6
#define MV_PATH		7
#define MV_COLOR	8
#define MV_MFILLED	9
#define MV_MOUT_LINE	10
#define MV_MLINE	11
#define MV_LOOP		12
#define MV_HOOK		13
#define COUNT_MV	14

#define COUNT_PICK	6

#define TI_NEXT		0
#define TI_PLAYTW	1
#define TI_PLAYAL	2
#define TI_PLAYLO	3
#define TI_GHOST	5
#define TI_ATEND	6
#define TI_ATSTART	7


/*I can't seem to get the RCS to put the color menu in the correct order, so
  I have this table to unscramble the results */
WORD fix_ccolor[16] = { 
0, 8, 1, 9, 10, 2, 3, 11, 12, 4, 5, 13, 6, 14, 7, 15};

do_morph_menu( m, s, v)
register struct menu *m;
struct selection *s;
register struct virtual_input *v;
{
register WORD which;
register WORD menu;

menu = v->data;
which = menu&0xff;
menu >>= 8;
switch ( menu )
	{
	case 0:
		switch(which)
			{
			case 0:
				ego_prop();
				break;
			case 1:	/* undo */
				swap_undo();
				make_cur_frame(NULL);
				break;
			case 2:	/*toggle help bar*/
				help_on = !help_on;
				make_cur_frame(NULL);
				break;
			case 3:	/*toggle fast menu*/
				morph_m.visible = !morph_m.visible;
				if (!morph_m.visible)
					clear_menu(m);
				break;
			case 4:	/* storage */
				storage_menu(m, s, v);		
				break;
			case 5:	/* storyboard */
				goto_anim_menu();
				m = NULL;	/* no redraw menu kludge */
				break;
			case 6:	/* color menu */
				color_menu(m, s, v);
				break;
			case 7:	/* time menu */
				time_menu(m, s, v);
				break;
			case 8:	/* new script */
				if (confirm(m, s, v, "abandon this script?") )
					{
					free_background();
					save_undo();
					free_s_sequence(cur_sequence);
					cur_sequence = make_empty_script();
					make_first_tween(cur_sequence);
					make_cur_frame(NULL);
					}
				break;
			case 9:	/* status */
				status_line();
				break;
			case 10:	/* quit */
				exit_anim(m, s, v);
				break;
			}
		break;
	case 1:
		switch (which)
			{
			case MK_POLY:	/* polygon */
				v_mode = VSPIKE;
				mv_dest = v_dest = v_table[VSPIKE];
				draw_mode = FREE_HAND;
				break;
			case MK_CIRCLE:	/*circle */
				v_mode = VSPIKE;
				mv_dest = v_dest = v_table[VSPIKE];
				draw_mode = CIRCLE;
				break;
			case MK_STAR:	/* star */
				v_mode = VSPIKE;
				mv_dest = v_dest = v_table[VSPIKE];
				draw_mode = STAR;
				break;
			case MK_BLOCK:	/*block */
				v_mode = VSPIKE;
				mv_dest = v_dest = v_table[VSPIKE];
				draw_mode = BLOCK;
				break;
			case MK_FILLED:	/* filled */
				bop_mode = FILLED;
				break;
			case MK_OUT_LINE:	/* outline */
				bop_mode = OUT_LINE;
				break;
			case MK_LINE:	/* line */
				bop_mode = JUST_LINE;
				break;
			case MK_CLONE:	/* clone */
				v_mode = VCLONE;
				mv_dest = v_dest = v_table[VCLONE];
				break;
			case MK_KILL:	/* destroy */
				v_mode = VKILL;
				mv_dest = v_dest = v_table[VKILL];
				break;
			case MK_INSERT:
				exchange_mode = 0;
				break;
			case MK_EXCHANGE:
				exchange_mode = 1;
				break;
			}
		break;
	case 2:
		switch (which)
			{
			case MV_SIDEWAYS:	/*sideways */
				v_mode = VMOVE;
				mv_dest = v_dest = v_table[VMOVE];
				break;
			case MV_INTO:	/* into screen */
				v_mode = VZ;
				mv_dest = v_dest = v_table[VZ];
				z_direction = 'd';
				break;
			case MV_OUT:	/* out of screen */
				v_mode = VZ;
				mv_dest = v_dest = v_table[VZ];
				z_direction = 'u';
				break;
			case MV_ROTATE:	/* rotate */
				v_mode = VROTATE;
				mv_dest = v_dest = v_table[VROTATE];
				rotate_axis = 'z';
				break;
			case MV_XROTATE:	/* x rotate */
				v_mode = VROTATE;
				mv_dest = v_dest = v_table[VROTATE];
				rotate_axis = 'x';
				break;
			case MV_YROTATE:	/* y rotate */
				v_mode = VROTATE;
				mv_dest = v_dest = v_table[VROTATE];
				rotate_axis = 'y';
				break;
			case MV_BIGSMALL:	/* big/small */
				v_mode = VSIZE;
				mv_dest = v_dest = v_table[VSIZE];
				break;
			case MV_PATH:	/* along path */
				v_mode = VSAMPLE;
				mv_dest = v_dest = v_table[VSAMPLE];
				break;
			case MV_COLOR:	/* change color */
				v_mode = VCOLOR;
				mv_dest = v_dest = v_table[VCOLOR];
				break;
			case MV_MFILLED:	/* make filled */
				v_mode = VBOP;
				mv_dest = v_dest = v_table[VBOP];
				bop_mode = FILLED;
				break;
			case MV_MOUT_LINE:	/* make outline */
				v_mode = VBOP;
				mv_dest = v_dest = v_table[VBOP];
				bop_mode = OUT_LINE;
				break;
			case MV_MLINE:	/* make line */
				v_mode = VBOP;
				mv_dest = v_dest = v_table[VBOP];
				bop_mode = JUST_LINE;
				break;
			case MV_LOOP:	/* loop */
				v_mode = VLOOP;
				mv_dest = v_dest = v_table[VLOOP];
				break;
			case MV_HOOK:	/* hook */
				v_mode = VHOOK;
				mv_dest = v_dest = v_table[VHOOK];
				break;
			}
		break;
	case 3:
		s_mode = which;
		break;
	case 4:
		switch (which)
			{
			case 0:	/* next tween */
				snap_shot(m, s, v);
				break;
			case 1:	/* play tween */
				lreplay(m, s, v);
				break;
			case 2:	/* play all */
				replay_start_end(m, s, v);
				break;
			case 3:	/* play loop */
				breplay(m, s, v);
				break;
			/* there is no case 4 */
			case 5:	/* ghost mode */
				ghost_mode = !ghost_mode;
				make_cur_frame(NULL);
				break;
			case 6:	/* at end */
				redo_see_beginning(m, s, v, 0);
				m = NULL;
				break;
			case 7:	/* at start */
				redo_see_beginning(m, s, v, 1);
				m = NULL;
				break;
			}
		break;
	case 5:
		ccolor = which;
		break;
	}
mmenu_hilights();
if (m != NULL)
	maybe_draw_menu(m);
}
