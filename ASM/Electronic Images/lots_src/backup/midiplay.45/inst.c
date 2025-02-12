/*
 *
 */
 
#include <stdio.h>
#include <e_gem.h>
#include "types.h"

void init_instlist(char ** ,int ,int * );
int selected_object_instlist(int);
int cdecl draw_instlist(PARMBLK *);
int cdecl do_instlist(OBJECT *,int,int,int,int);
int cdecl draw_deflist(PARMBLK *);

extern DIAINFO instlist_win;
extern OBJECT *instlist_tree;

Bool scroll;
int old_line,view_lines,lines;
char **list_ptr;
int scrllpos;
int *selected;
extern SLINFO sl_instlist;

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
		ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,FAIL,TRUE);
	}
	return (*selected);
}


int cdecl draw_instlist(PARMBLK *pb)
{	reg int y = pb->pb_y,x=pb->pb_x;
	reg int cnt_lines,start_line = scrllpos;
	reg int delta_lines=(scrllpos>old_line) ? (scrllpos-old_line) : (old_line-scrllpos);

	if (!scroll || (pb->pb_y+pb->pb_h)>max_h || delta_lines>=(view_lines-3) || delta_lines<=0)
		cnt_lines = view_lines;
	else
	{	reg GRECT source;
		reg int dy = delta_lines*gr_ch;
		source.g_x = x;
		source.g_y = y;
		source.g_w = pb->pb_w;
		source.g_h = pb->pb_h - dy;
		if (scrllpos>old_line)
		{	source.g_y += dy;
			rc_sc_copy(&source,x,y,3);
			if (pb->pb_hc>pb->pb_h)
				start_line += view_lines - delta_lines;
			else
			{	start_line += ((pb->pb_yc + pb->pb_hc - y)/gr_ch)-delta_lines;
				delta_lines++;
			}
		}
		else
		{	rc_sc_copy(&source,x,y + dy,3);
			if (pb->pb_hc<=pb->pb_h)
			{	start_line += (pb->pb_yc - y)/gr_ch;
				delta_lines++;
			}
		}
		start_line = max(start_line,scrllpos);
		cnt_lines = min(delta_lines,lines-start_line);
		if (start_line-scrllpos+cnt_lines>view_lines)
			cnt_lines = view_lines-start_line+scrllpos;
	}


	{	reg GRECT clear;
		y += (start_line-scrllpos )*gr_ch;
		clear.g_x = x;
		clear.g_y = y;
		clear.g_w = pb->pb_w;
		clear.g_h = cnt_lines*gr_ch;
		rc_intersect((GRECT *) &pb->pb_x,&clear);
		rc_sc_clear(&clear);
	}

	{	reg int index;
		v_set_text(ibm_font_id,ibm_font,-1,NULL);
		vsf_interior(x_handle,FIS_SOLID);
		for (index=cnt_lines;--index>=0;y += gr_ch)
		{	v_gtext(x_handle,x+2,y,list_ptr[start_line]);
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
	}
	return(0);
}

 
int cdecl do_instlist(OBJECT *obj,int pos,int prev,int max_pos,int top)
{	old_line = prev;
	scrllpos = pos;
	scroll = top;
	ob_draw_chg(&instlist_win,INSTLISTVIEW,NULL,FAIL,top);
	scroll = 0;
}

/*
 *
 */

extern int selected_channel;

/*
 *
 */

void init_deflist(void)
{	
}

/*
 *
 */

void redraw_selected_def(void )
{		ob_draw_chg(&instlist_win,DEFLISTVIEW,NULL,FAIL,TRUE);
}

void selected_object_deflist(int y)
{	int base_x,base_y,new_selected;
	objc_offset(instlist_tree,DEFLISTVIEW,&base_x,&base_y);
	new_selected = (y-base_y)/gr_ch;
	if (new_selected != (selected_channel))
	{	selected_channel = new_selected;
		ob_draw_chg(&instlist_win,DEFLISTVIEW,NULL,FAIL,TRUE);
	}
}

int cdecl draw_deflist(PARMBLK *pb)
{	reg int y = pb->pb_y,x=pb->pb_x;
	{	reg GRECT clear;
		clear.g_x = x;
		clear.g_y = y;
		clear.g_w = pb->pb_w;
		clear.g_h = 16*gr_ch;
		rc_intersect((GRECT *) &pb->pb_x,&clear);
		rc_sc_clear(&clear);
	}
	{	reg int index;
		v_set_text(ibm_font_id,ibm_font,-1,NULL);
		vsf_interior(x_handle,FIS_SOLID);
		for (index=0;index<16;y += gr_ch,index++)
		{	if 	(index == 9)			/* percussion */
				v_gtext(x_handle,x+2,y,gm_percussion[def_channel_list[index]]);
			else
				v_gtext(x_handle,x+2,y,gm_instrument[def_channel_list[index]]);
			if (index == selected_channel)
			{	int pxy[4];
				pxy[0]=x;			pxy[1]=y; 
				pxy[2]=pb->pb_x+pb->pb_w-1;	pxy[3]=y+gr_ch-1;
				vswr_mode(x_handle,MD_XOR);
				v_bar (x_handle,&pxy);
				vswr_mode(x_handle,MD_REPLACE);
			}
		}
	}
	return(0);
}

