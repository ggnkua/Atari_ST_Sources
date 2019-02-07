/*
 * CARDUTIL.C
 *  Utilities for CardSTack...
 *
 */
 
#include "osbind.h"
#include "define.h"
#include "gemdefs.h"
#include "obdefs.h"
 
#include "cardextn.h"
#include "carddefn.h"
#include "cardstak.h"

/*page*/
/***************************
 *
 * Utility routines to hide and
 * show the mouse...
 */

hide_mouse()
{
	if(! hidden){
		graf_mouse(M_OFF,0x0L);
		hidden=TRUE;
	}
}

show_mouse()
{
	if(hidden){
		graf_mouse(M_ON,0x0L);
		hidden=FALSE;
	}
}
/*page*/
/******************************
 *
 * OPEN_VWORK()
 * Open a virtual workstation to the
 * screen...
 *
 */
open_vwork()
{
	v_opnvwk(work_in,&handle,work_out);

	xres=work_out[0]+1;
	yres=work_out[1]+1;
}
/*page*/
/*****************************
 *
 * SET_CLIP()
 * Set the clipping rectangle for
 * the screen...
 *
 */

set_clip(x,y,w,h)
int x,y,w,h;
{
	int clip[4];

	clip[0] = x;
	clip[1] = y;
	clip[2] = x + w;
	clip[3] = y + h;
	vs_clip(handle,1,clip);
}
/*page*/
/******************************
 *
 * CLR_CLIP
 * 	Clear clipping...
 *
 */
clr_clip()
{
int clip[4];
	vs_clip(handle,0,clip);
}
/*page*/
/***************************
 *
 * OPEN_WINDOW()
 *   Opens up a window...
 *
 */

open_window(size_x, size_y, size_w, size_h, window_number)
int size_x, size_y, size_w, size_h;
int window_number;
{
	int i;
	
	hide_mouse();

	w_inf[window_number].handle = wind_create(WI_KIND,
						  xdesk,
						  ydesk,
						  wdesk,
						  hdesk);

	wind_set(w_inf[window_number].handle, 
			 WF_NAME,
			 " CardSTack, by Alex Leavens ",
			 0,
			 0);

	graf_growbox(0, 0, 0, 0, size_x, size_y, size_w, size_h);

	wind_open(w_inf[window_number].handle, size_x, size_y, size_w, size_h);

	wind_get(w_inf[window_number].handle,
		 WF_WORKXYWH,
		 &w_inf[window_number].x,		 
		 &w_inf[window_number].y, 
		 &w_inf[window_number].w,
		 &w_inf[window_number].h);

	wind_get(w_inf[window_number].handle,
		 WF_CURRXYWH,
		 &w_inf[window_number].big_x,
		 &w_inf[window_number].big_y, 
		 &w_inf[window_number].big_w,
		 &w_inf[window_number].big_h);

	if(w_inf[window_number].handle < 0)
	{
		show_mouse();
		i = form_alert(1,"[1][ Window handle allocation | failure!! (Too many open | windows...) ][ Bomb out ]");
		Pterm(-1);
	}
	show_mouse();
}


/******************
 *
 * CLEAR_WINDOW()
 *
 */
 
clear_window(window_index)
int window_index;
{
	int temp[4];

	make_clip(window_index);
	hide_mouse();
		
	vsf_interior(handle, 1);		/* Set fill to solid */
	vsf_color(handle, 0);			/* Set color to white */
	vswr_mode(handle, 1);			/* Set writing mode to replace */
	temp[0]=w_inf[window_index].x;
	temp[1]=w_inf[window_index].y;
	temp[2]=w_inf[window_index].x + w_inf[window_index].w - 1;
	temp[3]=w_inf[window_index].y + w_inf[window_index].h - 1;
	v_bar(handle,temp);		/* blank the interior */
	show_mouse();
	clr_clip();
}
/*******************
 *
 * MAKE_CLIP()
 */
 
make_clip(window_index)
int window_index;
{
	set_clip(w_inf[window_index].x,
		 w_inf[window_index].y,
		 w_inf[window_index].w,
		 w_inf[window_index].h);
}
/******************
 *
 * MAKE_CLOSED()
 */
 
make_closed(window_index)
int window_index;
{
	w_inf[window_index].status = CLOSED;
}
/******************
 *
 * MAKE_OPEN()
 */
 
make_open(window_index)
int window_index;
{
	w_inf[window_index].status = OPEN;
}

/*page*/
/****************************
 *
 * SHO_1FORM()
 *
 * Sho_1form displays a dialog window (Such as "Do you really want to quit?"),
 * [note: not a GEM dialog box, but one that was created using the Resource
 * Construction Set, RCS]
 * accepts the input from the user (and locks everything else up until the
 * user inputs an answer), resets the object to non-highlighted (NORMAL),
 * and then returns to the calling routine what button was pressed to
 * exit the dialog...
 *
 */

sho_1form(what_tree, tree_offset)

int what_tree, tree_offset;
{
	int dummy;
	long boxadd;
	int x,y,w,h,xdial,ydial,wdial,hdial;
	int what_key;

	/* Turn mouse into arrow */
	
	graf_mouse(0,&dummy);

	x=y=w=h=0;	/* variables for growbox */

	/* get address of parent object */
	rsrc_gaddr(0, what_tree, &boxadd);

	/* find out the size and position of a centered box */
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );

	wind_update(TRUE);

	/* reserve room on the screen */
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );

	/* draw a growing box */
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* draw the dialog box */
	objc_draw ( boxadd, CARDMENU, 2, xdial, ydial, wdial, hdial );

	/* allow user input */
	what_key = form_do ( boxadd, 0 ); 

	/* clean up the button... */
	rsc_pointer[tree_offset + what_key].ob_state = NORMAL;

	/* draw shrinking box */
	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* free up screen area */
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

	wind_update(FALSE);

	return(what_key);
}

/******************
 *
 * Utility routines
 *
 */

do_pointer()	/* Turn the mouse into the arrow pointer */
{
	if(! hidden)
	{
		graf_mouse(0, 0x0L);
	}
}

do_bee()	/* Turn the mouse pointer into the busy bee. */
{
	if(! hidden)
	{
		graf_mouse(2, 0x0L);
	}
}

/*page*/
/******************************
 *
 * MAKE_STRING()
 *	Makes an ASCII string version of
 *	an int value.  Eg, 0x1234 becomes
 *	"0x1234".
 */
make_string(value)
int value;
{
	int hundreds, tens, ones, i;

	for (i = 0; i <= 9; i++)
		munch_buff[i] = 0x20;

	ones = value + 1;
	hundreds = tens = 0;
	while(ones >= 100)
	{
		hundreds++;
		ones -= 100;
	}
	while(ones >= 10)
	{
		tens++;
		ones -= 10;
	}
	

	if (hundreds != 0)
	{
		munch_buff[0] = digits[hundreds];
		munch_buff[1] = digits[tens];
		munch_buff[2] = digits[ones];
	}
	else
	{
		munch_buff[0] = 0x20;
		if (tens != 0)
		{
			munch_buff[1] = digits[tens];
		}
		else
			munch_buff[1] = 0x20;

		munch_buff[2] = digits[ones];
	}
}

/*page*/
/*********************************************
 *
 * DO_FILE_STUFF
 *	Handles the fsel_input end of the program, gets
 * file name to process...
 */

do_file_stuff(change_name)
int change_name;
{
	int	fs_ireturn, fs_iexbutton;
	int	i, j;
	char	new_dir[108];

	new_dir[0] = 0;

	for(i = 0; i <= 107; i++)
	{
		wild_buf[i] = 0;
		tbuf[i] = 0;
	}
			
	cur_drive = Dgetdrv();
	Dgetpath(cur_dir, 0);
	wild_buf[0] = cur_drive + 'A';
	wild_buf[1] = ':';
	strcat(wild_buf, cur_dir);
	strcat(wild_buf, "\\");
	strcat(wild_buf, "*.CRD");

	wind_update(TRUE);	
	fs_ireturn = fsel_input(wild_buf, tbuf, &fs_iexbutton);
	wind_update(FALSE);

	if(fs_ireturn == 0)
	{
		i = form_alert(1, "[1][ File Error! ][ Oh, crap! ]");
	}
	else
	{
		if (fs_iexbutton != 1)
			return(fs_iexbutton);

		for (i = 0; i <= 107; i++)
		{
			if(wild_buf[i] == 0x2A)	/* asterisk... */
			{
				j = i;
				break;
			}
		}
		for (i = 0; i <= (107 - j); i++)
		{
			wild_buf[i + j] = tbuf[i];
			if ((i < 8) && (change_name == TRUE))
				name_is[i] = tbuf[i];
			if(tbuf[i] == 0)
				break;
		}
		for (i = 0; i <= 107; i++)
		{
			tbuf[i] = wild_buf[i];
		}
	}

	if (change_name == TRUE)
	{
		for (i = 0; i <= 7; i++)
		{
			if (name_is[i] == 0x00)
				name_is[i] = 0x20;
			else if (name_is[i] == '.')
			{
				name_is[i] = 0x20;
				for (j = i; j <= 7; j++)
					name_is[j] = 0x20;
				break;
			}
		}
	}
	return(fs_iexbutton);	
}

/**********************
 *
 * LOAD_CARD()
 *
 * Loads a card database...
 *
 */
 
static	char overwrite[]={
"[2][ Caution! Card NNN is already | in use!  Do you want to | overwrite it, load it at | the first empty slot, | or abort this load? ][Next|OverWrite|Abort]"
};

load_card(offset)
int offset;
{
	int f_handle, i, index, j;
	
	do_bee();
	f_handle = Fopen(&tbuf[0], 0);
	if (f_handle < 0)
	{
		do_pointer();
		i = form_alert(1,"[1][ File open error! ][ Oh, poop! ]");
	}
	else
	{
		while(1)
		{
			i = Fread(f_handle, 2L, &bufo.four_bytes[0]);
			if (i <= 0)
				break;
			index = bufo.two_ints[0];
			if ((index + offset) >= MAX_CARDS)
			{
				do_pointer();
				i = form_alert(1,"[1][ Illegal Card Number!! | Fatal Internal #370214 ][ Aaaargh! ]");
				Fclose(f_handle);
				return;
			}
			if (card_marks[index + offset] & CARD_IN_USE)
			{
				make_string(index + offset);
				overwrite[19] = munch_buff[0];
				overwrite[20] = munch_buff[1];
				overwrite[21] = munch_buff[2];
				i = form_alert(1,&overwrite[0]);
				if (i == 3)
				{
					Fclose(f_handle);
					do_pointer();
					return;
				}
				else if (i == 1)
				{
					j = 0;
					for (i = index + offset; i < MAX_CARDS; i++)
					{
						if (!(card_marks[i] & CARD_IN_USE))
						{
							j = i - (index + offset);
							offset += j;
							break;
						}
					}
					if (j == 0)
					{
						i = form_alert(1,"[3][ No more empty cards | above this one!][ Well, crud ]");
						Fclose(f_handle);
						do_pointer();
						return;
					}
				}
			}
			i = Fread(f_handle, 1L, &card_marks[index + offset]);
			if (i != 1)
			{
				do_pointer();
				i = form_alert(1,"[1][ Read error on file! | (at card_mark) ][ AAAAAARGH! ]");
				break;
			}
			i = Fread(f_handle, 510L, &data_space[index + offset][0]);
			if (i != 510)
			{
				do_pointer();
				i = form_alert(1,"[1][ Read error on file! | (at data_space) ][ AAAAAARGH! ]");
				break;
			}
		}
	}
	Fclose(f_handle);
	do_pointer();
}

/*********************
 *
 * SAVE_CARD()
 *  Saves a card file..
 */
 
save_card(mark_flag)
int mark_flag;
{
	int f_handle, i, j;
	
	if (mark_flag == TRUE)
	{
		j = FALSE;
		for (i = 0; i < MAX_CARDS; i++)
		{
			if (card_marks[i] & current_mark)
				j = TRUE;
		}
		if (j == FALSE)
		{
			i = form_alert(1,"[3][ No marked cards to save! ][ Ooops! (Blush) ]");
			return;
		}
	}

	do_bee();
	f_handle = Fopen(tbuf, 0);
	if (f_handle < 0)
	{
		f_handle = Fcreate(tbuf, 0);
		if (f_handle < 0)
		{
			do_pointer();
			i = form_alert(1,"[1][ File create error! ][ Oh, _poop_! ]");
			return;
		}
	}
	else
	{
		do_pointer();
		i = form_alert(1, "[1][ File already exists, | overwrite it? ][ NO! | Yes ]");
		if (i != 1)
		{
			do_bee();
			Fdelete(tbuf);
			f_handle = Fcreate(tbuf, 0);
			if (f_handle < 0)
			{
				do_pointer();
				i = form_alert(1,"[1][ File create error! ][ Oh, poop! ]");
				return;
			}
		}
		else
		{
			return;
		}
		do_bee();
	}

	for (i = 0; i < MAX_CARDS; i++)
	{
		if (mark_flag == FALSE)
		{
			if (card_marks[i] & CARD_IN_USE)
			{
				bufo.two_ints[0] = i;
				j = Fwrite(f_handle, 2L, &bufo.four_bytes[0]);
				j = Fwrite(f_handle, 1L, &card_marks[i]);
				j = Fwrite(f_handle, 510L, &data_space[i][0]);
			}
		}
		else
		{
			if (card_marks[i] & current_mark)
			{
				bufo.two_ints[0] = i;
				j = Fwrite(f_handle, 2L, &bufo.four_bytes[0]);
				j = Fwrite(f_handle, 1L, &card_marks[i]);
				j = Fwrite(f_handle, 510L, &data_space[i][0]);
			}
		}
	}

	Fclose(f_handle);
	do_pointer();
}
/*****************
 *
 * CLEAR_CARDS()
 *
 */
 
clear_cards(zap_name)
int zap_name;
{
	int i, j;

	do_bee();

	for (i = 0; i < MAX_CARDS; i++)
	{
		for (j = 0; j <= 509; j++)
			data_space[i][j] = 0x20;
	}

	for (i = 0; i < MAX_CARDS; i++)
	{
		card_marks[i] = 0;
		for(j = 1; j <= 10; j++)
			data_space[i][j * 50 + (j-1)] = 0x00;
	}
	
	if (zap_name == TRUE)
	{
		for (i = 0; i <= 7; i++)
			name_is[i] = 0x20;

		name_is[0] = 'E';
		name_is[1] = 'm';
		name_is[2] = 'p';
		name_is[3] = 't';
		name_is[4] = 'y';
	}
		
	do_pointer();
}
/**************
 *
 * DO_LOAD()
 *   Performs all the stuff associated with loading a cardstack...
 *
 */
 
do_load()
{
	int i;
	
	i = form_alert(1,"[1][ Caution!  Loading a new | cardstack will erase the | one in memory.  Do you | really want to do | this? ][ Abort | Load ]");
	if (i != 1)
	{
		i = do_file_stuff(TRUE);
		if (i == 1)			/* User clicked OK... */
		{
			clear_cards(FALSE);
			load_card(0);
		}
	}
	rebuild_window(MEMS_WIND);
}
/****************
 *
 * DO_SAVE()
 *   Saves a cardstack...
 *
 */
 
do_save()
{
	int i;
	
	i = do_file_stuff(TRUE);
	if (i == 1)				/* User clicked OK... */
		save_card(FALSE);
	rebuild_window(MEMS_WIND);
}
/*******************
 *
 * DO_MERGE()
 *   Merge one cardstack into another...
 *
 */
 
do_merge()
{
	int i;

	i = do_file_stuff(FALSE);
	if (i == 1)			/* User clicked OK... */
	{
		load_card(0);
	}
	rebuild_window(MEMS_WIND);
}
/********************
 *
 * DO_MERGE_AT()
 *   Merge one cardstack into another at the current cursor position
 *
 */
 
do_merge_at()
{
	int i;
	
	i = do_file_stuff(FALSE);
	if (i == 1)
	{
		load_card(card_index);
	}
	rebuild_window(MEMS_WIND);
}
/********************
 *
 * DO_CLEAR()
 *   Clear a cardstack...
 *
 */
 
do_clear()
{
	int i;

	i = form_alert(1,"[2][ Do you REALLY want to clear | the entire card workspace? ][ NO!! | Yes ]");
	if (i != 1)
		clear_cards(TRUE);
	cursor_x = cursor_y = 0;
	rebuild_window(MEMS_WIND);
}
/***************
 *
 * DO_QUIT()
 *
 */
do_quit()
{
	int i; 

	i = sho_1form(QUITRUSR, T2OBJ);
	if (i == YESQUIT)
		return(0);
	else
		return(1);
}
/******************
 *
 * DO_DELETE()
 *
 */
 
do_delete(c_index)
int c_index;
{
	int i;
	
	i = form_alert(1,"[1][ Do you REALLY want to | delete this card?? ][ No! | Yes ]");
	if (i != 1)
	{
		delete_card(c_index);
	}
	rebuild_window(MEMS_WIND);
}
/****************
 *
 * DELETE_CARD()
 *   Delete a card from the database.
 * Empties out (clears) the card's information,
 * and marks it as unused.
 */
 
delete_card(c_index)
int c_index;
{
	int j;

	for(j = 0; j < 510; j++)
	{
		data_space[c_index][j] = 0x20;	/* SPACE */
	}
	for(j = 0; j < 10; j++)
		data_space[c_index][(j+1) * 50] = 0x00;	/* NULL */

	card_marks[c_index] = UNUSED;
}
/********************
 *
 * CUT_CARD()
 *
 */
 
cut_card(c_index)
int c_index;
{
	int i;
	
	do_bee();
	for (i = 0; i < 510; i++)
		paste_buff[i] = data_space[c_index][i];
	paste_mark = card_marks[c_index];
	do_pointer();
	i = form_alert(1,"[1][ The card has been saved into | the PASTE buffer. ][ Isn't that SPECIAL? ]");
}
/********************
 *
 * PASTE_CARD()
 *
 */
 
paste_card(c_index)
int c_index;
{
	int i;
	
	do_bee();
	for (i = 0; i < 510; i++)
		data_space[c_index][i] = paste_buff[i];
	card_marks[c_index] = paste_mark;
	do_pointer();
}
/**********************
 *
 * DO_CUT()
 *
 */
 
do_cut()
{
	int i;
	
	if (card_marks[card_index] & CARD_IN_USE)
	{
		if (paste_mark & CARD_IN_USE)
		{
			i = form_alert(1,"[3][ Overwrite current | paste buffer? ][ NO! | Yes ]");
			if (i != 1)
				cut_card(card_index);
		}
		else
		{
			cut_card(card_index);
		}
	}
	else
	{
		i = form_alert(1,"[1][ This card isn't in use! ][ Oh, OK ]");
	}
}
/**********************
 *
 * DO_PASTE()
 *
 */
 
do_paste()
{
	int i;
	
	if (paste_mark & CARD_IN_USE)
	{
		if (card_marks[card_index] & CARD_IN_USE)
		{
			i = form_alert(1,"[3][ Overwrite current card?? ][ NO! | Yes ]");
			if (i != 1)
			{
				paste_card(card_index);
			}
		}
		else
			paste_card(card_index);
	}
	else
		i = form_alert(1,"[3][ The Paste Buffer is | currently empty! ][ Oh, sure ]");
	rebuild_window(MEMS_WIND);
}
/******************
 *
 * DO_MARK_SAVE()
 *
 *	Save marked cards...
 */
 
do_mark_save()
{
	int i;
	
	i = do_file_stuff(FALSE);
	if (i == 1)				/* User clicked OK... */
		save_card(TRUE);
	rebuild_window(MEMS_WIND);
}

/*********
 *
 * PUTZ()
 */
 
putz()
{
	/* DU-uh... */
}
