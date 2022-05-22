/*
 *
 */
 
#include <stdio.h>
#include <e_gem.h>
#include "midiplay.h"
#include "types.h"

void init_instlist(char ** ,int ,int * );
int selected_object_instlist(int);
void do_instlist(OBJECT *,int,int,int,int);
int cdecl draw_instlist(PARMBLK *);
int cdecl draw_deflist(PARMBLK *);

extern DIAINFO instlist_win;
extern OBJECT *instlist_tree;

USERBLK	instlistblk = {draw_instlist,0};
USERBLK	deflistblk = {draw_deflist,0};

Bool scroll;
int old_line,view_lines,lines;
char **list_ptr;
int scrllpos;
int *selected;
extern SLINFO sl_instlist;
extern SLINFO sl_deflist;
/*
 *
 */

void Set_AutoTestPatch(Bool flag)
{	extern OBJECT *menu;
	if (flag == TRUE)
		ob_dostate(menu,MAUTO_TEST,CHECKED);
	else
		ob_undostate(menu,MAUTO_TEST,CHECKED);
	AutoTestPatchFlag = flag;
}

/*
 *
 */
 
void Set_AutoLoadMap(Bool flag)
{	extern OBJECT *menu;
	if (flag == TRUE)
		ob_dostate(menu,MAUTO_LOAD,CHECKED);
	else
		ob_undostate(menu,MAUTO_LOAD,CHECKED);
	AutoLoadMapFlag = flag;
}

/*
 *
 */

void Set_HQ_Mode(Bool flag)
{	extern OBJECT *menu;
	if (flag == TRUE)
		ob_dostate(menu,MHQ_MODE,CHECKED);
	else
		ob_undostate(menu,MHQ_MODE,CHECKED);
	HQModeFlag = flag;
}

void init_instlist(char **new_ptr,int new_lines,int *new_selected)
{	list_ptr = new_ptr;
	lines = new_lines;
	selected = new_selected;
	if (*selected < 4)
		scrllpos = 0;
	else if (*selected > (new_lines-5))
		scrllpos = new_lines -8  ;
	else
		scrllpos = *selected - 3;

	sl_instlist.sl_page = view_lines = instlist_tree[INSTLISTVIEW].ob_height/gr_ch;
	sl_instlist.sl_max = lines;
	sl_instlist.sl_pos = scrllpos;
	graf_set_slider(&sl_instlist,instlist_tree,GRAF_SET);
	if (instlist_win.di_flag>CLOSED)
		graf_set_slider(&sl_instlist,instlist_tree,GRAF_DRAW);

}

int selected_object_instlist(int y)
{	int base_x,base_y,new_selected;
	objc_offset(instlist_tree,INSTLISTVIEW,&base_x,&base_y);
	new_selected = scrllpos + (y-base_y) / gr_ch;
	if (new_selected != (*selected))
	{	(*selected)=new_selected;
		ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,0);
	}
	return (*selected);
}


int cdecl draw_instlist(PARMBLK *pb)
{	GRECT work = *(GRECT *) &pb->pb_x;
	reg int x = pb->pb_x,y = pb->pb_y,i,start_line = scrllpos,dlines = abs(scrllpos - old_line);
	int pxy[4];

	v_set_mode(MD_REPLACE);
	vsf_interior(x_handle,FIS_SOLID);
	v_set_text(ibm_font_id,ibm_font,BLACK,NULL);

	rc_intersect((GRECT *) &pb->pb_xc,&work);
	if (scroll)
	{	i = dlines*gr_ch;
		if (scrllpos<old_line)
			i = -i;
		if (!rc_sc_scroll(&work,0,i,&work))
			return (0);
		else
		{	rc_grect_to_array(&work,pxy);
			restore_clipping(pxy);
		}
	}

	rc_sc_clear(&work);

	start_line += (work.g_y - y)/gr_ch;
	y += (start_line - scrllpos)*gr_ch;

	i = min((work.g_y - y + work.g_h + gr_ch - 1)/gr_ch,lines-start_line);

	for (;--i>=0;y += gr_ch)
	{	if (list_ptr == gm_instrument)
			v_gtext(x_handle,x+2,y,&gm_instrument[start_line][0]);
		else
			v_gtext(x_handle,x+2,y,&gm_percussion[start_line][0]);
		if (start_line == *selected)
		{	int pxy[4];
			pxy[0]=x;			pxy[1]=y; 
			pxy[2]=pb->pb_x+pb->pb_w-1;	pxy[3]=y+gr_ch-1;
			vswr_mode(x_handle,MD_XOR);
			v_bar (x_handle,&pxy);
			vswr_mode(x_handle,MD_REPLACE);
		}
		start_line ++;
	}
	return(0);
}

 
void do_instlist(OBJECT *obj,int pos,int prev,int max_pos,int top)
{
	old_line = prev;
	scrllpos = pos;
	scroll = TRUE;
	ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,0);
	scroll = 0;
}


/*
 *
 */

extern int selected_channel;

/*
 *
 */

void Redraw_DefList(void )
{	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,DEFLISTVIEW,NULL,0);
}

void Redraw_InstList(void)
{	if (instlist_win.di_flag>CLOSED)
		ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,0);
}

void selected_object_deflist(int y)
{	int base_x,base_y,new_selected;
	objc_offset(instlist_tree,DEFLISTVIEW,&base_x,&base_y);
	new_selected = (y-base_y)/gr_ch;
	if (new_selected != (selected_channel))
	{	selected_channel = new_selected;
		Redraw_DefList();
	}
}

int cdecl draw_deflist(PARMBLK *pb)
{	GRECT work = *(GRECT *) &pb->pb_x;
	reg int x = pb->pb_x,y = pb->pb_y,i,start_line;
	int pxy[4];
	v_set_mode(MD_REPLACE);
	vsf_interior(x_handle,FIS_SOLID);
	v_set_text(ibm_font_id,ibm_font,BLACK,NULL);	

	rc_intersect((GRECT *) &pb->pb_xc,&work);
	rc_sc_clear(&work);
	start_line = (work.g_y - y)/gr_ch;
	y += (start_line*gr_ch);
	i = (work.g_y - y + work.g_h + gr_ch - 1)/gr_ch;

	for (;--i>=0;y += gr_ch)
	{	if 	(def_channel_type[start_line] == PERCUSSION_CHANNEL)		
			v_gtext(x_handle,x+2,y,&gm_percussion[def_channel_list[start_line]][0]);
		else
			v_gtext(x_handle,x+2,y,&gm_instrument[def_channel_list[start_line]][0]);
		if (start_line == selected_channel)
		{	int pxy[4];
			pxy[0]=x;			pxy[1]=y; 
			pxy[2]=pb->pb_x+pb->pb_w-1;	pxy[3]=y+gr_ch-1;
			vswr_mode(x_handle,MD_XOR);
			v_bar (x_handle,&pxy);
			vswr_mode(x_handle,MD_REPLACE);
		}
		start_line++;
	}
	return(0);
}

