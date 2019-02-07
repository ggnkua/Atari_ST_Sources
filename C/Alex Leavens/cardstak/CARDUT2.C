/*
 * CARDUT2.C
 *   More utilities for CardSTack
 *
 * By Alex Leavens
 * (C) Copyright 1988 by Dynamic Software Design
 *
 */
 
#include "osbind.h"
#include "define.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "stdio.h"
 
#include "cardextn.h"
#include "carddefn.h"
#include "cardstak.h"

/*******************
 *
 * UPDATE_HSLIDER()
 */
 
update_hslider(window_index, value)
int window_index;
unsigned value;
{
	if (value > 1000)
		value = 1000;
	if (w_inf[window_index].status != CLOSED)
	{
		wind_set(w_inf[window_index].handle,
			 WF_HSLIDE,
			 1 + value,
			 0,
			 0,
			 0);
	}
}
/*************************
 *
 * DO_MARK()
 *
 */
 
do_mark()
{
	int i;
	
	if (card_marks[card_index] & current_mark)
		i = form_alert(1,"[3][ This card is already marked! ][ Oh, wow... ]");
	else
		card_marks[card_index] |= current_mark;
	rebuild_window(MEMS_WIND);
}
/********************
 *
 * DO_SELECT_MARK()
 *
 */
 
do_select_mark()
{
	int i, j;
	
	rsc_pointer[T3OBJ + MARK1].ob_state = NORMAL;
	rsc_pointer[T3OBJ + MARK2].ob_state = NORMAL;
	rsc_pointer[T3OBJ + MARK3].ob_state = NORMAL;
	rsc_pointer[T3OBJ + MARK4].ob_state = NORMAL;
	rsc_pointer[T3OBJ + MARK5].ob_state = NORMAL;
	rsc_pointer[T3OBJ + MARK6].ob_state = NORMAL;

	for (i = 0; i <= 5; i++)
	{
		if (current_mark == mark_test[i])
		{
			rsc_pointer[T3OBJ + mark_resource[i]].ob_state = CHECKED;
		}
	}
			
	i = sho_1form(WHICHMRK, T3OBJ);
	if (i != CNCLMARK)
	{
		for (j = 0; j <= 5; j++)
		{
			if (i == mark_resource[j])
				current_mark = mark_test[j];
		}
	}

	rebuild_window(MEMS_WIND);
}
/***************************
 *
 * DO_UNMARK()
 *
 */
 
do_unmark()
{
	int i;
	
	if (!(card_marks[card_index] & current_mark))
	{
		i = form_alert(1,"[1][ This card isn't marked | with the current mark! ][ Like, wow... ]");
	}
	else
	{
		i = form_alert(1,"[3][ Are you sure you want | to unmark this card? ][ NO! | Yes ]");
		if (i != 1)
		{
			card_marks[card_index] ^= current_mark;
		}
	}
	rebuild_window(MEMS_WIND);
}
/*********************
 *
 * DO_ALL_UNMARK()
 *
 */
 
do_all_unmark()
{
	int i, used;
	
	used = FALSE;
	for (i = 0; i < MAX_CARDS; i++)
	{
		if (card_marks[i] & current_mark)
			used = TRUE;
	}
	if (used == FALSE)
	{
		i = form_alert(1,"[3][ No cards are marked with | this mark! ][ Far out... ]");
		return;
	}
	else
	{
		i = form_alert(1,"[1][ Last Chance! | Do you REALLY want to | unmark ALL cards with this mark? ][ NO! | Oh, I guess so ]");
		if (i != 1)
		{
			for (i = 0; i < MAX_CARDS; i++)
			{
				if (card_marks[i] & current_mark)
					card_marks[i] ^= current_mark;
			}
		}
	}
	rebuild_window(MEMS_WIND);
}
/**********************
 *
 * DO_SEARCH()
 *
 */
 
do_search()
{
	TEDINFO *ted_pointer;
	int i, j, dummy, editing, obj_found;
	int tree_offset;
	int what_tree;
	int event, mx, my;
	long boxadd;
	int mgbuf[8];
	char foo[22];
	int x,y,w,h,xdial,ydial,wdial,hdial;
	int criteria;
	
/*-----------------------------------------------*/

	i = blank_space();
	if (i == TRUE)
		return;

	i = form_alert(1,"[3][ Erase current mark from | cards before searching? ][ no | yes ]");
	if (i != 1)
	{
		for (i = 0; i < MAX_CARDS; i++)
		{
			if (card_marks[i] & current_mark)
				card_marks[i] ^= current_mark;
		}
	}

	graf_mouse(0,&dummy);

	x=y=w=h=0;	/* variables for growbox */

	foo[21] = 0;

	tree_offset = T6OBJ;
	what_tree = SRCHNAME;

	for(i = 0; i < 20; i++)
		foo[i] = 0x20;

	foo[0] = 0;
	
	ted_pointer = (TEDINFO *)rsc_pointer[tree_offset + EDITBOX].ob_spec;
	ted_pointer->te_ptext = (char *)foo;

	rsrc_gaddr(0, what_tree, &boxadd);
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* redraw the dialog box, to update changes to the screen */
	wind_update(TRUE);
	objc_draw (boxadd,CARDMENU, 2, xdial, ydial, wdial, hdial );
	wind_update(FALSE);

	/* allow user input */
	editing = TRUE;

	while(editing == TRUE)
	{
	  event = evnt_multi(MU_BUTTON | MU_MESAG | MU_KEYBD,
		1,1,1,			/*evnt_button*/
		0,0,0,0,0,		/*evnt_mouse1*/
		0,0,0,0,0,		/*evnt_mouse2*/
		&mgbuf[0],		/*evnt_mesg*/
		0,0,			/*evnt_timer*/
		&mx,&my,		/*mouse x,y*/
		&dummy,			/*mouse button*/
		&dummy,			/*shift keys*/
		&dummy,			/*evnt_keyboard*/
		&dummy);		/*number of clicks*/

	if (event & MU_BUTTON)		/* user clicked on something.. */
	{
		obj_found = objc_find(boxadd,CARDMENU,2,mx,my);

		switch(obj_found){

		case EDITBOX:
			/* user's clicked in the name area of the object */
			/* so wait for them to enter a string, then      */
			/* press return.  string is validated by string  */
			/* mask contained in the resource file.          */
			/* allow user input */

			hide_mouse();
			wind_update(TRUE);
			dummy = form_do ( boxadd, EDITBOX );
			wind_update(FALSE);
			show_mouse();
			rsc_pointer[tree_offset + obj_found].ob_state = 
					NORMAL;
			break;
			
		case SRCHABRT:
			rsc_pointer[tree_offset + obj_found].ob_state = 
					NORMAL;
			editing = FALSE;
		    objc_draw (boxadd, SRCHABRT, 2, 
				xdial, ydial, wdial, hdial );
			form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
			form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 
			clear_window(MEMS_WIND);
			rebuild_window(MEMS_WIND);
			return;
			break;

		case SRCHOK:
			rsc_pointer[tree_offset + obj_found].ob_state = 
					NORMAL;
			wind_update(TRUE);
		    objc_draw (boxadd, SRCHOK, 2, 
				xdial, ydial, wdial, hdial );
		    wind_update(FALSE);
		    obj_found = 0;

			for (i = 0; i <= 19; i++)
			{
				if (foo[i] == 0x00)
				{
					length_1 = i;
					break;
				}
				card_1_buff[i] = foo[i];
			}

			/* now, get the field to search... */
			
			if ((i = Getrez()) == 1)		/* Color resolution */
				criteria = do_color_search_type();
			else
				criteria = do_search_type();
			rebuild_window(MEMS_WIND);

			if (criteria != ABRTSRCH)
			{
				do_bee();
	
				number_fields = find_field();
				for (j = 0; j < MAX_CARDS; j++)
				{
				  if (card_marks[j] & CARD_IN_USE)
				  {
					starting_2_point = find_edge(number_fields, j);
					length_2 = find_length(starting_2_point, j);
					for (i = 0; i < length_1; i++)
						card_2_buff[i] = data_space[j][starting_2_point + i + 51  * cursor_y];
			
					num_marked = strcmp (&card_1_buff[0], &card_2_buff[0]);
					if (((criteria & EQUAL) && (num_marked == 0)) ||
					    ((criteria & LESS_THAN) && (num_marked > 0))  ||
					    ((criteria & GREATER_THAN) && (num_marked < 0)))
				    	card_marks[j] |= current_mark;
				  }
				}
				do_pointer();
				i = form_alert(1,"[3][ All done! ][ Wowee! ]");
			}
			editing = FALSE;
				
			break;
			
		default:
			break;

		} /* end switch(obj_found) */

		if ((obj_found != -1) && (obj_found != 0))
		{
		  /* redraw the dialog box, to update changes to the screen */
		  wind_update(TRUE);
		  objc_draw (boxadd, obj_found, 2, 
				xdial, ydial, wdial, hdial );
		  wind_update(FALSE);
		}
	  } /* end if(event & mu_button) */

	  else if (event & MU_MESAG)
	  {
		/* ignore messages, reset the menu bar. */
		menu_tnormal(menuadd,mgbuf[3],1);
		form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
		form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 
		return;		
	  }
	  else
	  {
	    i = form_alert(1, "[3][ Please click on the edit box | before entering a search string. ][ Click here ]");
	  }
	} /* end while(editing)	*/
}
/**********************
 *
 * DO_SEARCH_TYPE()
 *
 */
 
do_search_type()
{
	int i, dummy, editing, obj_found;
	int tree_offset;
	int what_tree;
	int event, mx, my;
	long boxadd;
	int mgbuf[8];
	int x,y,w,h,xdial,ydial,wdial,hdial;
	int types, search;
		
/*-----------------------------------------------*/

	
	x=y=w=h=0;	/* variables for growbox */

	tree_offset = T7OBJ;
	what_tree = SRCHTYPE;

	rsrc_gaddr(0, what_tree, &boxadd);
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 

	rsc_pointer[tree_offset + LESSSRCH].ob_state = NORMAL;
	rsc_pointer[tree_offset + EQUALSRC].ob_state = NORMAL;
	rsc_pointer[tree_offset + GRTRSRCH].ob_state = NORMAL;

	/* redraw the dialog box, to update changes to the screen */
	wind_update(TRUE);
	objc_draw (boxadd,CARDMENU, 2, xdial, ydial, wdial, hdial );
	wind_update(FALSE);

	/* allow user input */
	types = 0;
	editing = TRUE;

	while(editing == TRUE)
	{
	
	  event = evnt_multi(MU_BUTTON | MU_MESAG | MU_KEYBD,
		1,1,1,			/*evnt_button*/
		0,0,0,0,0,		/*evnt_mouse1*/
		0,0,0,0,0,		/*evnt_mouse2*/
		&mgbuf[0],		/*evnt_mesg*/
		0,0,			/*evnt_timer*/
		&mx,&my,		/*mouse x,y*/
		&dummy,			/*mouse button*/
		&dummy,			/*shift keys*/
		&dummy,			/*evnt_keyboard*/
		&dummy);		/*number of clicks*/

	if (event & MU_BUTTON)		/* user clicked on something.. */
	    {
		obj_found = objc_find(boxadd,CARDMENU,2,mx,my);

		switch(obj_found){

		case LESSSRCH:
			if (types & LESS_THAN)
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			else
				rsc_pointer[tree_offset + obj_found].ob_state = CHECKED;
			types ^= LESS_THAN;
			break;

		case EQUALSRC:
			if (types & EQUAL)
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			else
				rsc_pointer[tree_offset + obj_found].ob_state = CHECKED;
			types ^= EQUAL;
			break;

		case GRTRSRCH:
			if (types & GREATER_THAN)
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			else
				rsc_pointer[tree_offset + obj_found].ob_state = CHECKED;
			types ^= GREATER_THAN;
			break;
		

		case DONESRCH:
			if (types == 0)
			{
				i = form_alert(1,"[3][ You must select at least | one search criterion! ][ Gosh! ]");
			}
			else
			{
				search = TRUE;
				editing = FALSE;
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			}
			break;
			
		case ABRTSRCH:
			search = FALSE;
			editing = FALSE;
			rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			break;
			
		default:
			break;

		} /* end switch(obj_found) */

		if ((obj_found != -1) && (obj_found != 0))
		{
		  /* redraw the dialog box, to update changes to the screen */
		  wind_update(TRUE);
		  objc_draw (boxadd, obj_found, 2, 
				xdial, ydial, wdial, hdial );
		  wind_update(FALSE);
		}
	  } /* end if(event & mu_button) */

	  else if (event & MU_MESAG)
	  {
		/* ignore messages, reset the menu bar. */
		menu_tnormal(menuadd,mgbuf[3],1);
	  }
	} /* end while(editing)	*/

	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

	if (search == TRUE)
		return(types);
	else
		return(ABRTSRCH);
}
/**********************
 *
 * DO_COLOR_SEARCH_TYPE()
 *
 */
 
do_color_search_type()
{
	int i, dummy, editing, obj_found;
	int tree_offset;
	int what_tree;
	int event, mx, my;
	long boxadd;
	int mgbuf[8];
	int x,y,w,h,xdial,ydial,wdial,hdial;
	int types, search;
		
/*-----------------------------------------------*/

	
	x=y=w=h=0;	/* variables for growbox */

	tree_offset = T9OBJ;
	what_tree = SRCCOLOR;

	rsrc_gaddr(0, what_tree, &boxadd);
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 

	rsc_pointer[tree_offset + LESSCOLR].ob_state = NORMAL;
	rsc_pointer[tree_offset + EQULCOLR].ob_state = NORMAL;
	rsc_pointer[tree_offset + GRTRCOLR].ob_state = NORMAL;

	/* redraw the dialog box, to update changes to the screen */
	wind_update(TRUE);
	objc_draw (boxadd,CARDMENU, 2, xdial, ydial, wdial, hdial );
	wind_update(FALSE);

	/* allow user input */
	types = 0;
	editing = TRUE;

	while(editing == TRUE)
	{
	
	  event = evnt_multi(MU_BUTTON | MU_MESAG | MU_KEYBD,
		1,1,1,			/*evnt_button*/
		0,0,0,0,0,		/*evnt_mouse1*/
		0,0,0,0,0,		/*evnt_mouse2*/
		&mgbuf[0],		/*evnt_mesg*/
		0,0,			/*evnt_timer*/
		&mx,&my,		/*mouse x,y*/
		&dummy,			/*mouse button*/
		&dummy,			/*shift keys*/
		&dummy,			/*evnt_keyboard*/
		&dummy);		/*number of clicks*/

	if (event & MU_BUTTON)		/* user clicked on something.. */
	    {
		obj_found = objc_find(boxadd,CARDMENU,2,mx,my);

		switch(obj_found){

		case LESSCOLR:
			if (types & LESS_THAN)
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			else
				rsc_pointer[tree_offset + obj_found].ob_state = CHECKED;
			types ^= LESS_THAN;
			break;

		case EQULCOLR:
			if (types & EQUAL)
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			else
				rsc_pointer[tree_offset + obj_found].ob_state = CHECKED;
			types ^= EQUAL;
			break;

		case GRTRCOLR:
			if (types & GREATER_THAN)
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			else
				rsc_pointer[tree_offset + obj_found].ob_state = CHECKED;
			types ^= GREATER_THAN;
			break;
		

		case DONECOLR:
			if (types == 0)
			{
				i = form_alert(1,"[3][ You must select at least | one search criterion! ][ Gosh! ]");
			}
			else
			{
				search = TRUE;
				editing = FALSE;
				rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			}
			break;
			
		case ABRTCOLR:
			search = FALSE;
			editing = FALSE;
			rsc_pointer[tree_offset + obj_found].ob_state = NORMAL;
			break;
			
		default:
			break;

		} /* end switch(obj_found) */

		if ((obj_found != -1) && (obj_found != 0))
		{
		  /* redraw the dialog box, to update changes to the screen */
		  wind_update(TRUE);
		  objc_draw (boxadd, obj_found, 2, 
				xdial, ydial, wdial, hdial );
		  wind_update(FALSE);
		}
	  } /* end if(event & mu_button) */

	  else if (event & MU_MESAG)
	  {
		/* ignore messages, reset the menu bar. */
		menu_tnormal(menuadd,mgbuf[3],1);
	  }
	} /* end while(editing)	*/

	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

	if (search == TRUE)
		return(types);
	else
		return(ABRTSRCH);
}
/******************
 *
 * DO_PRINT()
 *	this prints a card, from starting line xx to
 * ending line yy.  note modularity of printer support functions
 * to this routine.
 */
 
do_print( card, start_line, end_line, header )
int card, start_line, end_line, header;
{
	int i;
	FILE *fp, *fopen();
	
	if ((fp = fopen("prn:","w")) == NULL)
	{
		i = form_alert(1,"[1][ Cannot open printer | for output! check | cables, power, etc... ][ Oh, _fine_. ]");
		return;
	}

	if (header == TRUE)
	{
		set_info(i, FALSE, card);
		fprintf(fp, info_line);
		fprintf(fp, "\n\n");
	}

	for (i = start_line; i <= end_line; i++)
	{
		fprintf(fp, &data_space[card][i * 51]);
		fprintf(fp, "\n");
	}
	fprintf(fp, "\n\n");
	fclose(fp);
}
/******************
 *
 * PRINT_ALL()
 *
 */
static	char lineto[]={
"[2][ Print from line AA | to line BB? ][ No | Yes ]"
};
 
print_all()
{
	int i, header;
	int start, end;

	i = form_alert(1,"[1][ Print header info on each card? ][ No | Yes ]");
	if (i != 1)
		header = TRUE;
	else
		header = FALSE;

	if (print_using == TRUE)
	{
		if (old_y < new_y)
		{
			start = old_y;
			end = new_y;
		}
		else
		{
			start = new_y;
			end = old_y;
		}
		make_string(start);
		lineto[21] = munch_buff[1];
		lineto[22] = munch_buff[2];
		make_string(end);
		lineto[34] = munch_buff[1];
		lineto[35] = munch_buff[2];
		i = form_alert(1,&lineto[0]);
		if (i == 1)
			return;
	}
	else
	{
		start = 0;
		end = 9;
	}
		
	for (i = 0; i < MAX_CARDS; i++)
	{
		if (card_marks[i] & CARD_IN_USE)
		{
			do_print(i, start, end, header);
		}
	}
}
/***************
 *
 * PRINT_SOME()
 *
 */
 
print_some()
{
	int i, header;
	int start, end;

	i = form_alert(1,"[1][ Print header info on each card? ][ No | Yes ]");
	if (i != 1)
		header = TRUE;
	else
		header = FALSE;
	
	if (print_using == TRUE)
	{
		if (old_y < new_y)
		{
			start = old_y;
			end = new_y;
		}
		else
		{
			start = new_y;
			end = old_y;
		}
		make_string(start);
		lineto[21] = munch_buff[1];
		lineto[22] = munch_buff[2];
		make_string(end);
		lineto[34] = munch_buff[1];
		lineto[35] = munch_buff[2];
		i = form_alert(1,&lineto[0]);
		if (i == 1)
			return;
	}
	else
	{
		start = 0;
		end = 9;
	}
		
	for (i = 0; i < MAX_CARDS; i++)
	{
		if (card_marks[i] & current_mark)
		{
			do_print(i, start, end, header);
		}
	}
}
/***************
 *
 * REBUILD_WINDOW()
 *
 */

rebuild_window(wind_index)
int wind_index;
{ 
	int i;

	hide_mouse();
/*	clear_window(wind_index); */
	set_info(card_index, TRUE, 0);
	vst_color( handle, 1 );		/* set text color to black */
	vswr_mode( handle, 1 );		/* set writing mode to transparent */
	hide_mouse();
	for (i = 0; i <= 9; i++)
	{
		v_gtext( handle,
			 	 w_inf[wind_index].x + 2,
			     w_inf[wind_index].y + 2 + gl_hchar * (i + 1),
			     &data_space[card_index][i * 51]);
	}
	vswr_mode( handle, 3 );		/* set writing mode to xor		  */
	show_mouse();
}
/************************
 *
 * GET_INDEX()
 *
 */
 
get_index(requested)
int requested;
{
	int i, j;

	if (search_mode == FALSE)
		return(requested);
	else
	{
		if (requested < 0)	/* search left */
		{
			for (i = card_index - 1; i >= 0; i--)
			{
				if (card_marks[i] & current_mark)
				{
					j = (card_index - i) * -1;
					return(j);
				}
			}
			return(0);
		}
		else			/* search right */
		{
			for (i = card_index + 1; i < MAX_CARDS; i++)
			{
				if (card_marks[i] & current_mark)
				{
					j = i - card_index;
					return(j);
				}
			}
			return(0);
		}
	}
}
/******************
 *
 * PREV_CARD()
 *
 */
 
prev_card()
{
	card_index += get_index(-1);
	clear_window(MEMS_WIND);
	set_info(card_index, TRUE, 0);
	rebuild_window(MEMS_WIND);
	cursor_x = cursor_y = 0;
	update_hslider(MEMS_WIND, 2 * card_index);
}
/****************
 *
 * NEXT_CARD()
 *
 */
 
next_card()
{
	card_index += get_index(1);
	clear_window(MEMS_WIND);
	set_info(card_index, TRUE, 0);
	rebuild_window(MEMS_WIND);
	cursor_x = cursor_y = 0;
	update_hslider(MEMS_WIND, 2 * card_index);
}
/*****************
 *
 * DO_GET_MARK()
 *
 */
 
do_get_mark()
{
	if (global_mode == MARK_MODE)
	{
		global_mode = NORMAL_MODE;
		search_mode = FALSE;
		menu_icheck( menuadd, GETMARK, 0);
	}
	else
	{
		global_mode = MARK_MODE;
		search_mode = TRUE;
		menu_icheck( menuadd, GETMARK, 1);
	}
}
/****************
 *
 * COMPRESS_IT()
 *
 */
 
compress_it()
{
	int i, j, k, got_one;

	for (i = 0; i < MAX_CARDS; i++)
	{
		if (!(card_marks[i] & CARD_IN_USE))
		{
			got_one = FALSE;
			for (j = i + 1; j < MAX_CARDS; j++)
			{
				if (card_marks[j] & CARD_IN_USE)
				{
					for (k = 0; k < 510; k++)
						data_space[i][k] = data_space[j][k];
					card_marks[i] = card_marks[j];
					delete_card(j);
					got_one = TRUE;
					break;
				}
			}
			if (got_one == FALSE)
			{
				return;
			}
		}
	}
}
/*****************
 *
 * DO_COMPRESS()
 *   get rid of blank (deleted or empty)
 * cards in the middle of a database...
 *
 */
 
do_compress()
{
	int i, k;
	
	i = form_alert(1,"[3][ Caution! Compressing the | stack will rearrange the | order of the cards.| do you  really want | to do this? ][ Nope. | Oh, go ahead ]");
	if (i != 1)
	{
		compress_it();
		k = form_alert(1,"[3][ Compression complete! ][ Ok, fine ]");
	}
	cursor_x = cursor_y = 0;
	card_index = 0;
	update_hslider(MEMS_WIND, 0);
	rebuild_window(MEMS_WIND);
}
/*******************
 *
 * DO_SORT()
 *
 */
 
do_sort()
{
	int m;
/*-------------------------------------------*/

	i = blank_space();
	if (i == TRUE)
		return;

	card_1_buff[51] = card_2_buff[51] = 0;
	
	i = form_alert(1,"[1][ Caution!  Rearranging the | cards will permanently | change their order!  Do you | REALLY want to do this?][ NO! | Yes ]");
	if (i != 1)
	{
		do_bee();
		compress_it();
		if (!(card_marks[0] & CARD_IN_USE))
		{
			do_pointer();
			return;
		}
		number_fields = find_field();

		/* now, do a bubble sort on the records.  yeah, i know this */
		/* sucks, but i'm so tired i can't come up with anything better */
		
		while(1)
		{
			swap_flag = FALSE;
			card_1 = 0;
			card_2 = MAX_CARDS;
			for (i = card_1 + 1; i < MAX_CARDS; i++)
			{
				if (card_marks[i] & CARD_IN_USE)
				{
					card_2 = i;
					break;
				}
			}
			if (card_2 == MAX_CARDS)
			{
				do_pointer();
				return;
			}
			flag = 0;
			while(flag == 0)
			{
				for (m = 0; m <= 50; m++)
					card_1_buff[m] = card_2_buff[m] = 0x00;

				starting_1_point = find_edge(number_fields, card_1);
				length_1 = find_length(starting_1_point, card_1);
				for (i = 0; i < length_1; i++)
					card_1_buff[i] = data_space[card_1][starting_1_point + i + 51  * cursor_y];

				starting_2_point = find_edge(number_fields, card_2);
				length_2 = find_length(starting_2_point, card_2);
				for (i = 0; i < length_1; i++)
					card_2_buff[i] = data_space[card_2][starting_2_point + i + 51  * cursor_y];
			
				num_marked = strcmp (&card_1_buff[0], &card_2_buff[0]);

				/* card 1 comes before card 2 */
				if (((num_marked <= 0) && (search_alpha_direction == A_TO_Z)) ||
				    ((num_marked >= 0) && (search_alpha_direction == Z_TO_A)))
				{
					card_1 = card_2;
					card_2 = MAX_CARDS;
					for (i = card_1 + 1; i < MAX_CARDS; i++)
					{
						if(card_marks[i] & CARD_IN_USE)
						{
							card_2 = i;
							break;
						}
					}
					if (card_2 == MAX_CARDS)
						flag = 1;
				}

				/* card 1 comes after card 2 */
				else if (((num_marked > 0) && (search_alpha_direction == A_TO_Z)) ||
				         ((num_marked < 0) && (search_alpha_direction == Z_TO_A)))
				{
					swap_cards(card_1, card_2);
					swap_flag = TRUE;
				}
			}
			if (swap_flag == FALSE)
			{
				do_pointer();
				i =  form_alert(1,"[1][ All done! ][ I _like_ it! ]");
				cursor_x = cursor_y = 0;
				card_index = 0;
				update_hslider(MEMS_WIND, 0);
				rebuild_window(MEMS_WIND);
				return;
			}
		}
			
	}
}
/*****************
 *
 * find_field()
 *
 */
 
find_field()
{
	int i, number_fields;
	
	if (search_direction == LOOK_LEFT)
	{
		number_fields = 0;
		for (i = 49; i >= cursor_x; i--)
		{
			if (data_space[card_index][i + 51 * cursor_y] != 0x20)
			{
				number_fields++;
				while(data_space[card_index][i + 51 * cursor_y] != 0x20)
				{
					if (i <= 0)
						break;
					i--;
				}
			}
			if (i < cursor_x)
				break;
		}
		return(number_fields);
	}
	else if (search_direction == LOOK_RIGHT)
	{
		number_fields = 0;
		for (i = 0; i <= cursor_x; i++)
		{
			if (data_space[card_index][i + 51 * cursor_y] != 0x20)
			{
				number_fields++;
				while(data_space[card_index][i + 51 * cursor_y] != 0x20)
				{
					if (i >= 49)
						break;
					i++;
				}
			}
			if (i > cursor_x)
				break;
		}
		return(number_fields);
	}
	else	/* search absolute */
	{
		return(0);
	}
}
/*****************
 *
 * find_edge()
 *
 */
 
find_edge(num_fields, card)
int num_fields, card;
{
	int i, j, edge;
	
	if (search_direction == LOOK_LEFT)
	{
		edge = j = 49;
		for (i = 0; i < num_fields; i++)
		{
			while(data_space[card][j + cursor_y * 51] == 0x20)
			{
				if (j <= 0)
					break;
				j--;
			}
			while(data_space[card][j + cursor_y * 51] != 0x20)
			{
				if (j <= 0)
					break;
				j--;
			}
			edge = j+1;
		}
		return(edge);
	}
	else if (search_direction == LOOK_RIGHT)
	{
		edge = j = 0;
		for (i = 0; i < num_fields; i++)
		{
			while(data_space[card][j + cursor_y * 51] == 0x20)
			{
				if (j >= 49)
					break;
				j++;
			}
			edge = j;
			while(data_space[card][j + cursor_y * 51] != 0x20)
			{
				if (j >= 49)
					break;
				j++;
			}
		}
		return(edge);
	}
	else
	{
		return(cursor_x);
	}
}
/****************
 *
 * find_length()
 *
 */
 
find_length(original_x, card)
int original_x, card;
{
	int i, k;
	
	k = 0;
	for (i = original_x; i <= 49; i++)
	{
		if (data_space[card][i + 51 * cursor_y] == 0x20)
			break;
		else
			k++;
	}
	return(k);
}
/******************
 *
 * swap_cards()
 *
 */
 
swap_cards(card_1, card_2)
int card_1, card_2;
{
	int i, mark_buff;
	char holding_tank[510];
	
	for (i = 0; i < 510; i++)
		holding_tank[i] = data_space[card_1][i];
	mark_buff = card_marks[card_1];
	
	for (i = 0; i < 510; i++)
		data_space[card_1][i] = data_space[card_2][i];
	card_marks[card_1] = card_marks[card_2];
	
	for (i = 0; i < 510; i++)
		data_space[card_2][i] = holding_tank[i];
	card_marks[card_2] = mark_buff;
}

/****************
 *
 * blank_space()
 *
 */
 
blank_space()
{
		
    if (data_space[card_index][cursor_x + 51 * cursor_y] == 0x20)
    {
    	i = form_alert(1,"[1][ You're not in a word! | (Cursor must be on a | non-blank character) ][ I made a boo-boo ]");
    	rebuild_window(MEMS_WIND);
    	return(TRUE);
    }
    else
    	return(FALSE);
}
/*********************
 *
 * do_fast_search()
 *
 */
 
do_fast_search()
{
	TEDINFO *ted_pointer;
	int i, j, dummy;
	int tree_offset;
	int what_tree;
	long boxadd;
	char foo[22];
	int x,y,w,h,xdial,ydial,wdial,hdial;
	
/*-----------------------------------------------*/

	i = blank_space();
	if (i == TRUE)
		return;

	graf_mouse(0,&dummy);

	x=y=w=h=0;	/* variables for growbox */

	foo[21] = 0;

	tree_offset = T8OBJ;
	what_tree = DOFAST;

	for(i = 0; i < 20; i++)
		foo[i] = 0x20;

	foo[0] = 0;
	
	ted_pointer = (TEDINFO *)rsc_pointer[tree_offset + FASTBOX].ob_spec;
	ted_pointer->te_ptext = (char *)foo;

	rsrc_gaddr(0, what_tree, &boxadd);
	form_center ( boxadd, &xdial, &ydial, &wdial, &hdial );
	form_dial ( 0, x, y, w, h, xdial, ydial, wdial, hdial );
	form_dial ( 1, x, y, w, h, xdial, ydial, wdial, hdial ); 

	/* redraw the dialog box, to update changes to the screen */
	wind_update(TRUE);
	objc_draw (boxadd,CARDMENU, 2, xdial, ydial, wdial, hdial );
	wind_update(FALSE);

	hide_mouse();
	wind_update(TRUE);
	dummy = form_do ( boxadd, FASTBOX );
	wind_update(FALSE);
	show_mouse();

	for (i = 0; i <= 19; i++)
	{
		if (foo[i] == 0x00)
		{
			length_1 = i;
			break;
		}
		card_1_buff[i] = foo[i];
	}

	rsc_pointer[tree_offset + FASTBOX].ob_state = NORMAL;
	wind_update(TRUE);
    objc_draw (boxadd, CARDMENU, 2, xdial, ydial, wdial, hdial );
	wind_update(FALSE);

	form_dial ( 2, x, y, w, h, xdial, ydial, wdial, hdial ); 
	form_dial ( 3, x, y, w, h, xdial, ydial, wdial, hdial ); 

	rebuild_window(MEMS_WIND);
	do_bee();

	number_fields = find_field();
	for (j = 0; j < MAX_CARDS; j++)
	{
	  if (card_marks[j] & CARD_IN_USE)
	  {
		starting_2_point = find_edge(number_fields, j);
		length_2 = find_length(starting_2_point, j);
		for (i = 0; i < length_1; i++)
			card_2_buff[i] = data_space[j][starting_2_point + i + 51  * cursor_y];
		
		num_marked = strcmp (&card_1_buff[0], &card_2_buff[0]);
		if (num_marked == 0)
		    card_marks[j] |= current_mark;
	  }
	}

	do_pointer();
	i = form_alert(1,"[3][ All done! ][ Wowee! ]");
}
