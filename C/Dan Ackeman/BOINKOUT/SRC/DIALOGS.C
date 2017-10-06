/*  dialogs.c
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *   Electronic contact can be made via the following web address
 *  	http://www.netset.com/~baldrick/
 *
 * These are all the routines that handle what happens when
 * the user attempts to use one of the pretty windowed dialogs
 */

#include <stdio.h>

#include "boink.h"

int
do_title(void)
{
	int pxy[8];
	int x,y,wh;

	wh = new_window(about_dial,title_bar,0);

	if (wh >= 0)
	{
		win[ABOUT_WIN].handle = wh;
		win[ABOUT_WIN].window_obj = about_dial;
		win[ABOUT_WIN].title = title_bar;
		win[ABOUT_WIN].cur_item = -1;
		win[ABOUT_WIN].text_block = NULL;
		win[ABOUT_WIN].buf_size = 0;
		win[ABOUT_WIN].status = 1;
		win[ABOUT_WIN].edit = 0;
		win[ABOUT_WIN].type = 0;
			
		win[ABOUT_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[ABOUT_WIN].curr));
	}

	objc_offset(about_dial,RTITLE,&x,&y);

	pxy[0] = pxy[1] = 0;
	pxy[2] = tit_buf.fd_w - 1;
	pxy[3] = tit_buf.fd_h - 1;
	pxy[4] = x;
	pxy[5] = y;
	pxy[6] = x + pxy[2];
	pxy[7] = y + pxy[3];

	vro_cpyfm(vdi_handle,S_ONLY,pxy,&tit_buf,&screen_fdb);

	if (remap_pal == 0)
		load_about_colors();

	return(wh);
}

int
do_scorelist(void)
{
	int wh;

	reset_colors();

	wh = new_window(scorelist_dial,title_bar,0);

	if (wh >= 0)
	{
		win[SCORE_WIN].handle = wh;		
		win[SCORE_WIN].window_obj = scorelist_dial;
		win[SCORE_WIN].title = title_bar;
		win[SCORE_WIN].cur_item = -1;
		win[SCORE_WIN].text_block = NULL;
		win[SCORE_WIN].buf_size = 0;
		win[SCORE_WIN].status = 1;
		win[SCORE_WIN].edit = 0;
		win[SCORE_WIN].type = 0;
		
		win[SCORE_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[SCORE_WIN].curr));
	}

	return(wh);
}

int
do_loading(void)
{
	int wh;

	wh = new_window(loading_dial,title_bar,2);

	if (wh >= 0)
	{
		win[LOADING_WIN].handle = wh;
		win[LOADING_WIN].window_obj = loading_dial;
		win[LOADING_WIN].title = title_bar;
		win[LOADING_WIN].cur_item = -1;
		win[LOADING_WIN].text_block = NULL;
		win[LOADING_WIN].buf_size = 0;
		win[LOADING_WIN].status = 1;
		win[LOADING_WIN].edit = 0;
		win[LOADING_WIN].type = 2;
			
		win[LOADING_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[LOADING_WIN].curr));
	}

	return(wh);
}

int
do_jumpdial(void)
{
	int wh;
	char ft[80];

	wh = new_window(jump_dial,title_bar,0);

	if (wh >= 0)
	{
		win[JUMP_WIN].handle = wh;
		win[JUMP_WIN].window_obj = jump_dial;
		win[JUMP_WIN].title = title_bar;
		win[JUMP_WIN].cur_item = JUMP_SELECT;
		win[JUMP_WIN].text_block = NULL;
		win[JUMP_WIN].buf_size = 0;
		win[JUMP_WIN].status = 1;
		win[JUMP_WIN].edit = 1;
		win[JUMP_WIN].type = 2;
			
		win[JUMP_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[JUMP_WIN].curr));

		set_tedinfo(win[JUMP_WIN].window_obj, JUMP_LEVEL_NAME, name);

		sprintf(ft,"%d",file_levels);
		set_tedinfo(win[JUMP_WIN].window_obj, JUMP_LEVEL_NUM, ft);
	}

	return(wh);
}

int
do_objcolorsdial(void)
{
	int wh;

	wh = new_window(objcolor_dial,title_bar,0);

	if (wh >= 0)
	{
		win[OBJCOLOR_WIN].handle = wh;
		win[OBJCOLOR_WIN].window_obj = objcolor_dial;
		win[OBJCOLOR_WIN].title = title_bar;
		win[OBJCOLOR_WIN].cur_item = -1;
		win[OBJCOLOR_WIN].text_block = NULL;
		win[OBJCOLOR_WIN].buf_size = 0;
		win[OBJCOLOR_WIN].status = 1;
		win[OBJCOLOR_WIN].edit = 0;
		win[OBJCOLOR_WIN].type = 0;
			
		win[OBJCOLOR_WIN].icon_obj = icons_dial;

		wind_get(wh, WF_CURRXYWH, ELTR(win[OBJCOLOR_WIN].curr));
	}

	return(wh);
}
