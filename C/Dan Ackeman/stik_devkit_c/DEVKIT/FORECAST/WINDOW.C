#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <string.h>
#include "forecast.h"
#include "main.h"

/* Prototypes... */

	void	draw_win(void);
	void	create_win(const char *);
	void	open_win(void);
	void	close_win(void);
	void	delete_win(void);
	short	do_menu(short);
	short	dialog(OBJECT *, short);
	void	set_button(OBJECT *, short, short);
	short	get_button(OBJECT *, short);
	void	empty_edits(OBJECT *tree, int object);
	void 	set_tedinfo(OBJECT *tree,int obj,char *source);

/* Externals... */

	extern void	new_game(void);

	extern short	endmainloop;
	extern short	pause;
	extern short	vdi_handle, work_out[57];
	extern WINDOW	win;
	extern MFDB	work, screen;
	extern OBJECT	*menu_ptr, *about_ptr, *help_ptr;

	extern short	open;

	extern char out[80];
	extern char city_tla[3];


void draw_win(void)
	{
	short pxyarray[8];
	GRECT rect, deskrect;

	wind_get(DESK, WF_WXYWH, &deskrect.g_x, &deskrect.g_y, &deskrect.g_w, &deskrect.g_h);

	wind_update(BEG_UPDATE);
	wind_get(win.handle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);

	do
		{
		if (rc_intersect(&win.w_rect, &rect))
			{
			rc_intersect(&deskrect, &rect);
			pxyarray[4]=rect.g_x;
			pxyarray[5]=rect.g_y;
			pxyarray[6]=rect.g_x+rect.g_w-1;
			pxyarray[7]=rect.g_y+rect.g_h-1;
			pxyarray[0]=pxyarray[4]-win.w_rect.g_x;
			pxyarray[1]=pxyarray[5]-win.w_rect.g_y;
			pxyarray[2]=pxyarray[6]-win.w_rect.g_x;
			pxyarray[3]=pxyarray[7]-win.w_rect.g_y;
			Vsync();
			v_hide_c(vdi_handle);
			vro_cpyfm(vdi_handle, 3, pxyarray, &work, &screen);
			v_show_c(vdi_handle, 1);
			}
		wind_get(win.handle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
		}
	while (rect.g_w & rect.g_h);

	wind_info(win.handle, out);

	wind_update(END_UPDATE);
	}

void create_win(const char *title)
	{
/*	GRECT deskrect;*/
	GRECT windrect;

	wind_get(DESK, WF_WORKXYWH, &windrect.g_x, &windrect.g_y, &windrect.g_w, &windrect.g_h);

/*	wind_calc(WC_BORDER, WINTYPE, deskrect.g_x, deskrect.g_y, deskrect.g_w, deskrect.g_h,
			&windrect.g_x, &windrect.g_y, &windrect.g_w, &windrect.g_h);*/
 
/*	rc_center(&deskrect, &windrect);*/

	if (windrect.g_w>250)	windrect.g_w=250;
	if (windrect.g_h>200)	windrect.g_h=200;

	win.handle=wind_create(WINTYPE, windrect.g_x, windrect.g_y, windrect.g_w, windrect.g_h);
	if (win.handle>=0)
		{
		wind_title(win.handle, title);
		wind_open(win.handle, windrect.g_x, windrect.g_y, windrect.g_w, windrect.g_h);
		}

	win.b_rect=windrect;

	wind_calc(WC_WORK, WINTYPE, win.b_rect.g_x,  win.b_rect.g_y,  win.b_rect.g_w,  win.b_rect.g_h,
				   &win.w_rect.g_x, &win.w_rect.g_y, &win.w_rect.g_w, &win.w_rect.g_h);
	}

void open_win(void)
	{
	wind_open(win.handle, win.b_rect.g_x, win.b_rect.g_y, win.b_rect.g_w, win.b_rect.g_h);
	}

void close_win(void)
	{
	wind_close(win.handle);
	}

void delete_win(void)
	{
	wind_delete(win.handle);
	}

short do_menu(short menu_item)
	{
	switch (menu_item)
		{
		case MAbout:
			dialog(about_ptr, 0);
			break;

		case MFOpen:
			open=0x01;
			break;

		case MFQuit:
			endmainloop=TRUE;
			break;

		case M_HELP:
			dialog(help_ptr, 0);

		}

	/* Christoper Hewett == Mr. Belvedere */

	return (endmainloop);
	}

short dialog(OBJECT *obj, short edit)
	{
	GRECT rect;
	short exit;

	if (edit != 0)
		{
			empty_edits(obj,edit);
		}

	if ((edit == city)&&(city_tla!=NULL))
		{
			set_tedinfo(obj,edit,city_tla);
		}


	form_center(obj, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
	form_dial(FMD_START, 0, 0, 0, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	form_dial(FMD_GROW, rect.g_x+rect.g_w/2, rect.g_y+rect.g_h/2, 0, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);

	objc_draw(obj, ROOT, MAX_DEPTH, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	exit=form_do(obj, edit);

	form_dial(FMD_SHRINK, rect.g_x+rect.g_w/2, rect.g_y+rect.g_h/2, 0, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	form_dial(FMD_FINISH, 0, 0, 0, 0, rect.g_x, rect.g_y, rect.g_w, rect.g_h);
	obj[exit].ob_state&=~SELECTED;

	return (exit);
	}

void set_button(OBJECT *tree, short parent, short button)
{
	short b;
	
	for (b=tree[parent].ob_head; b!=parent; b=tree[b].ob_next)
		if (b==button)
			tree[b].ob_state|=SELECTED;
		else
			tree[b].ob_state&=~SELECTED;
}

short get_button(OBJECT *tree, short parent)
{
	short b;

	b=tree[parent].ob_head;
	for (; b!=parent && !(tree[b].ob_state&SELECTED); b=tree[b].ob_next)
		;

	return b;
}

void
empty_edits(OBJECT *tree, int object)
{
	set_tedinfo(tree,object,""); 
}

/*
 * copy a string into a TEDINFO structure.
 */
void set_tedinfo(OBJECT *tree,int obj,char *source)
{
	char *dest;
	
	dest=((TEDINFO *)tree[obj].ob_spec)->te_ptext;
	strcpy(dest,source);
}
