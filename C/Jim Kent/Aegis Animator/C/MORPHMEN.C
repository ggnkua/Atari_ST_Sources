
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\script.h"
#include "..\\include\\story.h"
#include "..\\include\\menu.h"
#include "..\\include\\addr.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\io.h"
#include "..\\include\\cursor.h"
#include "..\\include\\color.h"

extern struct selection morph_table[];
extern struct menu morph_m;
extern WORD sys_scale;

extern int vspike(), vloop(), vhook();
extern int vmove(), vrotate(), vsize(), vclone(), vkill(), vcolor();
extern int vbop(), vz();
extern int vsample();

int (*v_table[])() = 
	{
	vspike,
	vloop,
	vhook,
	vmove,
	vrotate,
	vsize,
	vclone,
	vkill,
	vcolor,
	vbop,
	vz,
	vsample,
	};

WORD v_mode = 0;
int (*mv_dest)() = vspike;


#ifdef AMIGA
extern struct Window	*MainWindow;
#endif AMIGA


goto_anim_menu()
{
extern struct control main_control;
extern WORD in_story_mode;
extern WORD cur_sequ_ix;  /*this guy is in wsubs.c */
extern struct menu anim_m;
extern struct menu *dissa_menu;
extern int anim_menu(), (*w_dest)();

#ifdef DEBUG
ldprintf("\ngoto_anim_menu()");
#endif DEBUG

free_undo();

in_story_mode = 1;
sys_scale = 1;
scale_rm_by_4();
story_board[cur_sequ_ix].sequence = cur_sequence;
cur_sequence = NULL;

main_control.m = &anim_m;
free_background();
clear_screen();
startup_story_board();
v_dest = w_dest;
c_dest = m_dest = anim_menu;
#ifdef AMIGA
set_aanim_menu();
#endif AMIGA
#ifdef ATARI
see_abar();
dissa_menu = NULL;
#endif ATARI
#ifdef SUN
draw_menu(&anim_m);
#endif SUN
show_help("storyboard");
}


goto_morph_menu()
{
extern struct control main_control;
extern WORD in_story_mode;
extern WORD cur_sequ_ix;  /*this guy is in wsubs.c */
extern struct menu morph_m;
extern int morph_menu(), (*w_dest)();

#ifdef DEBUG
printf("goto_morph_menu()\n");
#endif DEBUG

in_story_mode = 0;
sys_scale = 0;
free_rm_scales();

main_control.m = &morph_m;
v_dest = mv_dest;
c_dest = m_dest = morph_menu;

attatch_cur_sequence_to_story( story_board + cur_sequ_ix );

make_cur_frame(&morph_m);

#ifdef AMIGA
set_amorph_menu();
#endif AMIGA
#ifdef ATARI
see_mbar();
#endif ATARI
show_help("Aegis Animator 2.10 (c) 1987 Jim Kent");
}

morph_menu(control)
struct control *control;
{
struct menu *m = control->m;
struct selection *sel = control->sel;
struct virtual_input *vis = control->vis;
extern WORD in_story_mode;
extern Tween *m_insert_colors();

#ifdef DEBUG
printf("morph_menu\n");
#endif DEBUG

main_menu_driver(control, MOVE_MENU);
}


new_v_mode(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct one_of *one_of;

one_of = (struct one_of *)sel->display_data;
v_mode = one_of->i_am;
mv_dest = v_dest = v_table[v_mode];
}


new_s_mode(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct one_of *one_of;

one_of = (struct one_of *)sel->display_data;
s_mode = one_of->i_am;
}

