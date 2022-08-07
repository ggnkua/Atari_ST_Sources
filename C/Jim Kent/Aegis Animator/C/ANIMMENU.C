
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\io.h"
#include "..\\include\\story.h"

extern struct menu anim_m;
extern short sys_scale;

extern int wclone(), wsplice(), wedit(), wactivate(), wkill();
extern int wscissors();


int (*w_table[])() = 
	{
	wactivate,
	wedit,
	NULL,	/*used to be wclone*/
	wsplice,
	wkill,
	wscissors,
	};

short w_mode = 1;
int (*w_dest)() = wedit;

anim_menu(control)
struct control *control;
{
main_menu_driver(control, 0);
}


#ifdef SUN
new_w_mode(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
struct one_of *one_of;

one_of = (struct one_of *)sel->display_data;
w_mode = one_of->i_am;
w_dest = v_dest = w_table[w_mode];
}
#endif SUN

