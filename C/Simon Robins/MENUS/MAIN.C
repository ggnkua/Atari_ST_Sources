#define ELTS(r)	r.g_x,r.g_y,r.g_w,r.g_h

#include <string.h>

#include <aes.h>
#include <vdi.h>
#include "menu.h"
#include "menux.h"

OBJECT *menu, *parent1, *parent2;

MENU Menu1, Menu2, Menu3;

typedef struct
{
	short msg;
	short apid;
	short len;
	short title;
	short item;
	OBJECT *tree;
	short parent;
} SUB_MENU;

char *get_title(int title)
{
	switch(title)
	{
	case T_TITLE1:
		return "Title 1 | ";
	case T_TITLE2:
		return "Title 2 | ";
	default:
		return "Unknown title | ";
	}
}

char *get_item(OBJECT *tree, int item)
{
	if(tree == menu)
	{
		switch(item)
		{
		case MENU1:
			return "Menu 1 | ";
		case MENU2:
			return "Menu 2 | ";
		case MENU3:
			return "Menu 3 | ";
		case MENU4:
			return "Menu 4 | ";
		case MENU5:
			return "Menu 5 | ";
		case MENU6:
			return "Menu 6 | ";
		default:
			return "Unknown sub/menu | ";
		}
	}
	else if(tree == parent1)
	{
		switch(item)
		{
		case SUBMENU1:
			return "Submenu 1 | ";
		case SUBMENU2:
			return "Submenu 2 | ";
		case SUBMENU3:
			return "Submenu 3 | ";
		case SUBMENU4:
			return "Submenu 4 | ";
		case SUBMENU5:
			return "Submenu 5 | ";
		case SUBMENU6:
			return "Submenu 6 | ";
		default:
			return "Unknown sub/menu | ";
		}
	}
	else if(tree == parent2)
	{
		switch(item)
		{
		case SUBMENU7:
			return "Submenu 7 | ";
		case SUBMENU8:
			return "Submenu 8 | ";
		case SUBMENU9:
			return "Submenu 9 | ";
		default:
			return "Unknown sub/menu | ";
		}
	}
	else
		return "Unknown sub/menu | ";
		
}
char *get_tree(OBJECT *tree)
{
	if(tree == menu)
		return "Main menu tree| ";
	else if(tree == parent1)
		return "Sub menu tree 1 | ";
	else if(tree == parent2)
		return "Sub menu tree 2 | ";
	else
		return "Unknown tree | ";
}

char *get_parent(int parent)
{
	switch(parent)
	{
	case T1_PARENT:
		return "Parent of Menu 1/2/3";
	case T2_PARENT:
		return "Parent of Menu 4/5/6";
	case M1_PARENT:
		return "Parent of Submenu 1/2/3";
	case M2_PARENT:
		return "Parent of Submenu 4/5/6";
	case M3_PARENT:
		return "Parent of Submenu 7/8/9";
	default:
		return "Unknown parent ";
	}
}

void do_options(short *msg)
{
	SUB_MENU *menu = (SUB_MENU *)msg;
	char alert[256];
	char *title, *item, *tree, *parent;

	title = get_title(menu->title);
	item = get_item(menu->tree, menu->item);
	tree = get_tree(menu->tree);
	parent = get_parent(menu->parent);
	strcpy(alert, "[1][ A menu has been selected | ");
	strcat(alert, title);
	strcat(alert, item);
	strcat(alert, tree);
	strcat(alert, parent);
	strcat(alert, " ][ OK ]");
	form_alert(1, alert);
}

#if 0
void do_popup(MENU *menu)
{
	char alert[256];
	char *item, *tree, *parent;

	item = get_item(menu->mn_tree, menu->mn_item);
	tree = get_tree(menu->mn_tree);
	parent = get_parent(menu->mn_menu);
	strcpy(alert, "[1][ A menu has been selected | ");
	strcat(alert, item);
	strcat(alert, tree);
	strcat(alert, parent);
	strcat(alert, " ][ OK ]");
	form_alert(1, alert);
}
#endif

void set_menu(OBJECT *tree, int parent, int item, int scroll, MENU *data)
{
	data->mn_tree = tree;
	data->mn_menu = parent;
	data->mn_item = item;
	data->mn_scroll = scroll;
}

char Address[] =	"[2][ Submenu test program |"
					"Please report all bugs to:- | |"
					"NeST: 90:100/102 |"
					"srobins@cix.compulink.co.uk ]"
					"[Simon Robins 1994 ]";

static char alert[] = "[1][ Main handle 0 ][ OK ]";

short in[11] = {1,1,1,1,1,1,1,1,1,1,2};
short out[57];

main(void)
{
	int quit;
	short msg[8];
	short mask;
	int x, y, button, kstate, kreturn, breturn;
	short handle, j;

	appl_init();

	rsrc_load("menux.rsc");
	rsrc_gaddr(R_TREE, MAINMENU, &menu);
	rsrc_gaddr(R_TREE, PARENT1, &parent1);
	rsrc_gaddr(R_TREE, PARENT2, &parent2);

	set_menu(parent1, M1_PARENT, SUBMENU1, 0, &Menu1);
	set_menu(parent1, M2_PARENT, SUBMENU4, 0, &Menu2);
	set_menu(parent2, M3_PARENT, SUBMENU7, 0, &Menu3);

	menu_bar(menu, 1);

	menu_attach(ME_ATTACH, menu, MENU1, &Menu1);
	menu_attach(ME_ATTACH, menu, MENU2, &Menu2);
	menu_attach(ME_ATTACH, menu, MENU3, &Menu3);
	menu_attach(ME_ATTACH, menu, MENU4, &Menu1);
	menu_attach(ME_ATTACH, menu, MENU5, &Menu2);
	menu_attach(ME_ATTACH, menu, MENU6, &Menu3);

	graf_mouse(0, NULL);

	handle = graf_handle(&j, &j, &j, &j);
	v_opnvwk(in, &handle, out);
	alert[17] = handle + '0';
	form_alert(1, alert);

	quit = 0;
	while(!quit)
	{
		mask = evnt_multi(MU_MESAG | MU_KEYBD | MU_BUTTON,
			2,1,1,
			0,0,0,0,0,
			0,0,0,0,0,
			msg,
			0,0,
			&x,&y,&button,&kstate,
			&kreturn,
			&breturn);

		if(mask & MU_MESAG)
			if(msg[0] == MN_SELECTED)
			{
				switch(msg[3])
				{
				case T_DESK:
					form_alert(1, Address);
					break;
				case T_FILE:
					quit = 1;
					break;
				case T_TITLE1:
				case T_TITLE2:
					do_options(msg);
					break;
				}
				menu_tnormal(menu, msg[3], 1);
			}

		if(mask & MU_KEYBD)
			if(kreturn == 0x1011)
				quit = 1;
#if 0
		if(mask & MU_BUTTON)
			if(breturn == 1)
			{
				if(menu_popup(&Menu2, x, y, &Menu2))
					do_popup(&Menu2);
				else
					form_alert(1, "[1][ No popup item selected ][ OK ]");
			}else{
				if(menu_popup(&Menu3, x, y, &Menu3))
					do_popup(&Menu3);
				else
					form_alert(1, "[1][ No popup item selected ][ OK ]");
			}
#endif
	}

	v_clsvwk(handle);
	menu_bar(menu, 0);
	rsrc_free();
	appl_exit();
	return 0;
}
