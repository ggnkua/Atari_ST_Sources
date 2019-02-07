/*
 * CARDS.C
 *	An interesting little card file database
 *  (C) Copyright 1988 by Dynamic Software Design
 *
 * 	Written by Alex Leavens
 *
 */

#include "osbind.h"
#include "define.h"
#include "gemdefs.h"
#include "obdefs.h"
 
#include "cardextn.h"
#include "carddefn.h"
#include "cardstak.h"

/*********************
 *
 * MAIN()
 *
 */
 
main()
{
	int i, flag;
	
	appl_init();

	handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	open_vwork();

	if ((i = Getrez()) == 0)
	{
		i = form_alert(1,"[1][ CardSTack requires medium | or high resolution | in order to run ][ Darn! ]");
		goto exit;
	}
	
	i = rsrc_load("CARDSTAK.RSC");
	if (i == 0)
	{
	    i = form_alert(1, "[3][ERROR!  CARDSTAK.RSC not found! | CardSTack won't run without it.][ Bummer... ]");
	    goto exit;
	}

	rsrc_gaddr(0,CARDMENU,&menuadd);
	menu_bar(menuadd,1);
	rsc_pointer = (OBJECT *)menuadd;

	show_mouse();
	graf_mouse(0, 0x0L);

	/* Setup initial state stuff... */

	old_y = new_y = 0;
	flag = 1;
	card_index = 0;
	current_mark = MARK_1;
	global_mode = NORMAL_MODE;

	search_direction = LOOK_RIGHT;
	menu_icheck( menuadd, LOOKRITE, 1);
	search_alpha_direction = A_TO_Z;
	menu_icheck( menuadd, SORTATOZ, 1);
	
	do_bee();
	clear_cards();
	do_pointer();
	
	for (i = 0; i <= 7; i++)
		name_is[i] = start_name[i];
	
	while(flag == 1)
	{
		flag = do_cards();
	}	

exit:
	v_clsvwk(handle);
	i = appl_exit();
	
	/* Leave program */
}

/*********************
 *
 * UPDATE_WINDOW_INFO()
 *
 */
 
update_window_info(window_number)
int window_number;
{
	if (w_inf[window_number].handle != 0xFFFF)
	{
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
	}
}
/*********************
 *
 * SHRINK_WINDOW()
 *
 */
 
shrink_window(window_index)
int window_index;
{
graf_shrinkbox(w_inf[window_index].x + w_inf[window_index].w / 2,
               w_inf[window_index].y + w_inf[window_index].h / 2,
               gl_wbox,
               gl_hbox,
               w_inf[window_index].x,
               w_inf[window_index].y,
               w_inf[window_index].w,
               w_inf[window_index].h);
}
/*page*/
/********************************
 *
 * DO_CARDS()
 *
 * This actually opens up the window, and does the
 * main card stack stuff...
 *
 */
 
do_cards()
{
	int wx, wy, wh, ww, cx, cy, ch, cw;
	int flag = 1;
	int i, poot;
	int two_events;
	char foobar;
	int use_new_cursor;

	use_new_cursor = TRUE;

	if ((i = Getrez()) == 2)	/* Monochrome mode */
	{
		open_window( 5, 
				 2 * gl_hchar,
				 51 * gl_wchar,
				 14 * gl_hchar, 
				 MEMS_WIND);
		top_cursor = 5;
		bottom_cursor = 1;
	}
	else						/* Medium rez color... */
	{
		open_window( 5, 
				 2 * gl_hchar,
				 51 * gl_wchar,
				 15 * gl_hchar, 
				 MEMS_WIND);
		top_cursor = 4;
		bottom_cursor = -1;
	}

	clear_window(MEMS_WIND);
	make_open(MEMS_WIND);
	
	flag = 1;
	cursor_x = cursor_y = 0;
	set_info(card_index, TRUE, 0);
	two_events = 0;
		
	while(flag == 1)
	{
	event = evnt_multi( MU_MESAG | 
						MU_BUTTON | 
						MU_KEYBD,		/* types of events      */
						1,1,1,			/* button event         */
						0,0,0,0,0,		/* 1st rectangle event  */
						0,0,0,0,0,		/* 2nd rectangle event  */
						msgbuff,			/* message buffer       */
						1000,0,				/* timer event	        */
						&mx,&my, 	/* mouse pos at event   */
						&buttons,	/* button state at event*/
						&keys,		/* state of shift keys at event   */
						&what_key,	/* what key pressed     */
						&dummy);	/* # of button clicks   */

	  display_cursor();			/* Turn cursor OFF... */
	  if (event & MU_MESAG)
	  {
	  	use_new_cursor = TRUE;
	  	
		switch(msgbuff[0]){
			
		/* A drop down got hit... */
		
		case MN_SELECTED:
		    menu_tnormal( menuadd, msgbuff[3], 1 );
		    switch (msgbuff[4]) {

			case SORTATOZ:
				menu_icheck( menuadd, SORTATOZ, 1 );
				menu_icheck( menuadd, SORTZTOA, 0 );
				search_alpha_direction = A_TO_Z;
				break;

			case SORTZTOA:
				menu_icheck( menuadd, SORTATOZ, 0 );
				menu_icheck( menuadd, SORTZTOA, 1 );
				search_alpha_direction = Z_TO_A;
				break;

			case PRNTUSNG:
				if (print_using == TRUE)
				{
					print_using = FALSE;
					menu_icheck(menuadd, PRNTUSNG, 0);
				}
				else
				{
					print_using = TRUE;
					menu_icheck(menuadd, PRNTUSNG, 1);
				}
				break;
				
			case LOOKLEFT:
				menu_icheck( menuadd, LOOKLEFT, 1 );
				menu_icheck( menuadd, LOOKRITE, 0 );
				menu_icheck( menuadd, ABSOLUTE, 0 );
				search_direction = LOOK_LEFT;
				break;
				
			case LOOKRITE:
				menu_icheck( menuadd, LOOKLEFT, 0 );
				menu_icheck( menuadd, ABSOLUTE, 0 );
				menu_icheck( menuadd, LOOKRITE, 1 );
				search_direction = LOOK_RIGHT;
				break;			

			case ABSOLUTE:
				menu_icheck( menuadd, LOOKLEFT, 0 );
				menu_icheck( menuadd, ABSOLUTE, 1 );
				menu_icheck( menuadd, LOOKRITE, 0 );
				search_direction = LOOK_ABSOLUTE;
				break;

			case CLERCARD:
				do_clear();
				break;
				
			case LOADCARD:
				do_load();
				break;

			case GETMARK:
				do_get_mark();
				break;
				
			case COMPRESS:
				do_compress();
				break;

			case SAVECARD:
				do_save();
				break;
				
			case SAVEMARK:
				do_mark_save();
				break;

			case SRCHCARD:
				do_search();
				break;

			case FASTSRCH:
				do_fast_search();
				break;

			case SORT:
				do_sort();
				break;

			case MERGCARD:
				do_merge();
				break;
								
			case MERGEAT:
				do_merge_at();
				break;

			case SHOWFUNK:
				i = sho_1form(FUNKEYS, T5OBJ);
				break;
				
			case SLCTMARK:
				do_select_mark();
				break;

			case UNMKALL:
				do_all_unmark();
				break;
				
			case MARKCARD:
				do_mark();
				break;
				
			case UNMARK:
				do_unmark();
				break;

			case CARDINFO:
				i = sho_1form(INFOBOX, T1OBJ);
				break;

			case QUITCARD:
				flag = do_quit();
				break;

			case DELTCARD:
				do_delete(card_index);
				break;

			case CUTCARD:
				do_cut();
				break;

			case PASTCARD:
				do_paste();
				break;
				
			case PRINTALL:
				print_all();
				break;

			case PRNTCARD:
				print_some();
				break;

			default:
				break;
			}
		two_events = msgbuff[0];
		break;
		
		/* Window handling stuff here... */

		case WM_NEWTOP:
		case WM_TOPPED:
		    wind_set(w_inf[MEMS_WIND].handle,WF_TOP,0,0,0,0);
		    two_events = WM_NEWTOP;
		    break;

		case WM_CLOSED:
		    flag = do_quit();
		    two_events = WM_CLOSED;
		    break;

		case WM_REDRAW:
			wind_get(w_inf[MEMS_WIND].handle, WF_TOP,
						 &cx, &cy, &cw, &ch);

			if (cx == w_inf[MEMS_WIND].handle)
			{
				wind_update(TRUE);
				clear_window(MEMS_WIND);
				rebuild_window(MEMS_WIND);
		  	    wind_update(FALSE);
		  	}
		    break;
		    
		case WM_HSLID:			/* Horizontal slider... */
			card_index = msgbuff[4] / 2;
			if (card_index >= MAX_CARDS)
				card_index = MAX_CARDS - 1;
			if (card_index < 0)
				card_index = 0;
			update_hslider(MEMS_WIND, 2 * card_index);
			rebuild_window(MEMS_WIND);
			break;
			
		case WM_ARROWED:		/* Arrow or page... */
			switch(msgbuff[4]){
				case ARRW_LF:
					if (card_index > 0)
						prev_card();
					break;
				case ARRW_RT:
					if (card_index < (MAX_CARDS-1))
						next_card();
					break;
				case PAGE_LF:
					if (card_index >= 10)
					{
						card_index += get_index(-10);
						clear_window(MEMS_WIND);
						set_info(card_index, TRUE, 0);
						rebuild_window(MEMS_WIND);
						cursor_x = cursor_y = 0;
						two_events = PAGE_LF;
						update_hslider(MEMS_WIND,
							       2 * card_index);
					}
					break;
				case PAGE_RT:
					if (card_index <= (MAX_CARDS - 10))
					{
						card_index += get_index(10);
						clear_window(MEMS_WIND);
						set_info(card_index, TRUE, 0);
						rebuild_window(MEMS_WIND);
						cursor_x = cursor_y = 0;
						two_events = PAGE_RT;
						update_hslider(MEMS_WIND,
							       2 * card_index);
					}
					break;
				default:
					break;
				}		/* End switch msgbuff[4] */
			break;
			
		default:
		    break;

		} /* switch (msgbuff[0]) */

  	    display_cursor();	/* Show cursor here... */
		
	   }   /* End of (if event * MU_MESAG) */
	   
	  /* Read mouse button clicks... */

	  else if (event & MU_BUTTON)
	  {
		if (use_new_cursor == TRUE)
		{
			old_y = new_y;
			use_new_cursor = FALSE;
		}
		if ( (mx > w_inf[MEMS_WIND].x) &&
		     (mx < (w_inf[MEMS_WIND].x + w_inf[MEMS_WIND].w)) &&
		     (my > w_inf[MEMS_WIND].y) &&
		     (my < (w_inf[MEMS_WIND].y + w_inf[MEMS_WIND].h)))
		{
			
			old_y = new_y;
			i = (mx - w_inf[MEMS_WIND].x - 2) / gl_wchar;
			if ( (i <= 49) && (i >= 0))
				cursor_x = i;
			i = (my - w_inf[MEMS_WIND].y - top_cursor) / gl_hchar;
			if ( (i < 10) && (i >= 0))
			cursor_y = i;
			new_y = cursor_y;
		}
		two_events = WM_NEWTOP;
		display_cursor();
	  }

	  /* Check out the keyboard... */
	  
	  else if (event & MU_KEYBD)
	  {
	  	use_new_cursor = TRUE;
		two_events = WM_NEWTOP;
	  	what_key &= 0xFF00;
	  	what_key >>= 8;			/* Get low value of key... */
	  	
		i = graf_mkstate(&mx, &my, &dummy, &keys);
		if ((keys & 0x04) ||		/* Control key down... */
		    ((what_key >= 0x3B) && (what_key <= 0x44)))  /* FUNCTION KEY */
		{
			switch(what_key){
				case 0x13:		/* CTL-R, sort */
					do_sort();
					break;
				case 0x2C:		/* CTL-Z, save marked */
					do_mark_save();
					break;
				case 0x22:		/* CTL-G, Get mark */
					do_get_mark();
					break;
				case 0x26:		/* CTL-L, Load card */
				case 0x3B:		/* F1	*/
					do_load();
					break;
				case 0x1F:		/* CTL-S, save card */
				case 0x3C:		/* F2	*/
					do_save();
					break;
				case 0x10:		/* CTL-Q, quit.. */
					flag = do_quit();
					break;
				case 0x32:		/* CTL-M, Merge card */
				case 0x3D:		/* F3				 */
					do_merge();
					break;
				case 0x18:		/* CTL-O, Merge at... */
					do_merge_at();
					break;
				case 0x24:		/* CTL-J, Compress    */
					do_compress();
					break;
				case 0x11:		/* CTL-W, clear all */
				case 0x3E:		/* F4				*/
					do_clear();
					break;
				case 0x20:		/* CTL-D, delete record... */
				case 0x3F:		/* F5				*/
					do_delete(card_index);
					break;
				case 0x2E:		/* CTL-C	*/
				case 0x40:		/* F6,  Cut card */
					do_cut();
					break;
				case 0x19:		/* CTL-P, paste card */
				case 0x41:		/* F7				*/
					do_paste();
					break;
				case 0x31:		/* CTL-N, mark record */
				case 0x42:		/* F8 */
					do_mark();
					break;
				case 0x12:		/* CTL-E, Select mark... */
				case 0x43:		/* F9,  Select Mark */
					do_select_mark();
					break;
				case 0x16:		/* CTL-U, Unmark Card... */
					do_unmark();
					break;
				case 0x21:		/* CTL-F, search for record */
				case 0x44:		/* F10, search for mark */
					do_search();
					break;
				case 0x27:		/* CTL-; fast search... */
					do_fast_search();
					break;
				default:
					break;
			}
		}
		else		/* No control key... */
		{
	  	  switch(what_key){
	  		case 0x02:
	  		case 0x03:
	  		case 0x04:
	  		case 0x05:
	  		case 0x06:
	  		case 0x07:
	  		case 0x08:
	  		case 0x09:
	  		case 0x0A:
	  		case 0x0B:
	  		case 0x0C:
	  		case 0x0D:
	  		case 0x10:
	  		case 0x11:
	  		case 0x12:
	  		case 0x13:
	  		case 0x14:
	  		case 0x15:
	  		case 0x16:
	  		case 0x17:
	  		case 0x18:
	  		case 0x19:
	  		case 0x1A:
	  		case 0x1B:
	  		case 0x1E:
	  		case 0x1F:
	  		case 0x20:
	  		case 0x21:
	  		case 0x22:
	  		case 0x23:
	  		case 0x24:
	  		case 0x25:
	  		case 0x26:
	  		case 0x27:
	  		case 0x28:
	  		case 0x29:
	  		case 0x2B:
	  		case 0x2C:
	  		case 0x2D:
	  		case 0x2E:
	  		case 0x2F:
	  		case 0x30:
	  		case 0x31:
	  		case 0x32:
	  		case 0x33:
	  		case 0x34:
	  		case 0x35:
	  		case 0x39:
				if (keys & 0x03)		/* Either shift key... */
		  			data_space[card_index][cursor_x + 51 * cursor_y] = 
		  											shifted[what_key];
		  		else
		  			data_space[card_index][cursor_x + 51 * cursor_y] = 
		  											unshifted[what_key];
				redraw_line(cursor_x, cursor_y);
				update_cursor();
				if (!(card_marks[card_index] & CARD_IN_USE))
					set_info(card_index,TRUE,0);
				card_marks[card_index] |= CARD_IN_USE;
				break;

			case 0x63:
			case 0x64:
			case 0x65:
			case 0x67:
			case 0x68:
			case 0x69:
			case 0x6A:
			case 0x6B:
			case 0x6C:
			case 0x6D:
			case 0x6E:
			case 0x6F:
			case 0x70:
			case 0x71:
				data_space[card_index][cursor_x + 51 * cursor_y] =
										key_convert[what_key - 0x63];
				redraw_line(cursor_x, cursor_y);
				update_cursor();
				if (!(card_marks[card_index] & CARD_IN_USE))
					set_info(card_index,TRUE,0);
				card_marks[card_index] |= CARD_IN_USE;
				break;

			case 0x66:				/*  *   */
			case 0x4A:				/*  -   */
			case 0x4E:				/*  +   */
				switch(what_key){
					case 0x66:
						foobar = '*';
						break;
					case 0x4A:
						foobar = '-';
						break;
					case 0x4E:
						foobar = '+';
						break;
					default:
						foobar = '?';
						break;
					}
				data_space[card_index][cursor_x + 51 * cursor_y] = foobar;
				redraw_line(cursor_x, cursor_y);
				update_cursor();
				if (!(card_marks[card_index] & CARD_IN_USE))
					set_info(card_index,TRUE,0);
				card_marks[card_index] |= CARD_IN_USE;
				break;
			
			case 0x1C:		/* RETURN */
			case 0x72:		/* ENTER  */
				cursor_x = 0;
				if (cursor_y < 9)
					cursor_y++;
				break;
	  		
			case 0x0E:		/* BACKSPACE */
				if (cursor_x > 0)
				{
					cursor_x--;
					data_space[card_index][cursor_x + 51 * cursor_y] = 0x20;
					redraw_line(0, cursor_y);
				}
				break;

			case 0x53:		/* DELETE.. */
				data_space[card_index][cursor_x + 51 * cursor_y] = 0x20;
				redraw_line(0, cursor_y);
				break;

			case 0x48:		/* Up Arrow */
				search_mode = FALSE;
				global_mode = MARK_MODE;
				do_get_mark();
				if (cursor_y > 0)
					cursor_y--;
				break;


			case 0x50:		/* Down Arrow */
				search_mode = FALSE;
				global_mode = MARK_MODE;
				do_get_mark();
				if (cursor_y < 9)
					cursor_y++;
				break;

			case 0x4B:		/* Left Arrow */
				i = graf_mkstate(&mx, &my, &dummy, &keys);
				if (keys & 0x03)	/* Control key down... */
				{
					if (card_index > 0)
						prev_card();
				}
				else
				{
					search_mode = FALSE;
					global_mode = MARK_MODE;
					do_get_mark();
					if (cursor_x > 0)
						cursor_x--;
					else if (cursor_y > 0)
					{
						cursor_x =	49;
						cursor_y --;
					}
				}
				break;

			case 0x4D:		/* Right Arrow */
				i = graf_mkstate(&mx, &my, &dummy, &keys);
				if (keys & 0x03)	/* Control key down... */
				{
					if (card_index < (MAX_CARDS - 1))
						next_card();
				}
				else
				{
					search_mode = FALSE;
					global_mode = MARK_MODE;
					do_get_mark();
					if (cursor_x < 49)
						cursor_x++;
					else if (cursor_y < 9)
					{
						cursor_x = 0;
						cursor_y++;
					}
				}
				break;
					
	  		default:
	  			break;
	  	  }	/* End switch (what_key) */

	    }	/* End else... (No control key...) */

	  	display_cursor();					/* Now turn cursor back ON... */
		two_events = 0;
	    
	  } /* End else if (event * MU_KEYBD) */
	} /* End while(flag == 1) */

    wind_close(w_inf[MEMS_WIND].handle);
    shrink_window(MEMS_WIND);
    wind_delete(w_inf[MEMS_WIND].handle);

	make_closed(MEMS_WIND);
      
	return(0);
}

/*********************
 *
 * REDRAW_LINE()
 *   Redraws a line of the current card
 *
 */
 
redraw_line(x_pos, y_pos)
int x_pos, y_pos;
{
	hide_mouse();
	vst_color( handle, 1 );		/* Set text color to black */
	vswr_mode( handle, 1 );		/* Set writing mode to transparent */
	v_gtext( handle,
			 w_inf[MEMS_WIND].x + 2 + x_pos * gl_wchar, 
		     w_inf[MEMS_WIND].y + 2 + gl_hchar * (y_pos + 1),
		     &data_space[card_index][x_pos + y_pos * 51]);
	vswr_mode( handle, 3 );		/* Set writing mode to XOR		  */
	show_mouse();
}

/*****************
 *
 * UPDATE_CURSOR()
 *  Updates the cursor position in the card...
 *
 */
 
update_cursor()
{
	if ((cursor_y >= 10) || ((cursor_x == 49) && (cursor_y == 9)))
		return;
 	cursor_x++;
	if (cursor_x >= 50)
	{
		cursor_x = 0;
		if (cursor_y <= 8)
			cursor_y++;
	}
}
/*****************
 *
 * DISPLAY_CURSOR()
 *
 */
 
display_cursor()
{
	int box[4];
	
	box[0] = w_inf[MEMS_WIND].x + 2 + cursor_x * gl_wchar;
	box[1] = w_inf[MEMS_WIND].y + top_cursor + cursor_y * gl_hchar;
	box[2] = box[0] + gl_wchar;
	box[3] = box[1] + gl_hchar + bottom_cursor;
	
	vsf_interior( handle, 1 );		/* Set fill type to solid... */
	vsf_color( handle, 1 );			/* Set fill color to black... */
	vswr_mode( handle, 3 );			/* Set write mode to XOR... */
	vsf_perimeter( handle, 0 );		/* No perimeter around the box */	

	hide_mouse();
	v_bar( handle, box );
	show_mouse();
}
/*******************
 *
 * REDRAW_WINDOW()
 *  Redraws an entire card image...
 *
 */
 
redraw_window()
{
	int i;
	
	for (i = 0; i <= 9; i++)
		redraw_line(0, i);
		
	display_cursor();
}
/*******************
 *
 * SET_INFO()
 *
 *  Sets the information line...
 *
 */
 
set_info(card_number, change, value)
int card_number, change, value;
{
	int i, use_me;

	if (change == TRUE)
		use_me = card_number;
	else
		use_me = value;

	make_string(use_me);

	for (i = 0; i <= 2; i++)
		info_line[6 + i] = munch_buff[i];


	if (card_marks[use_me] & CARD_IN_USE)
		info_line[27] = '*';
	else
		info_line[27] = 0x20;

	for (i = 0; i <= 5; i++)
	{
		if (!(card_marks[use_me] & mark_test[i]))
			info_line[21 + i] = 0x20;
		else
			info_line[21 + i] = '1' + i;
	}
		
	for (i = 0; i <= 7; i++)
		info_line[i + 36] = name_is[i];

	if (change == TRUE)
	{
		wind_set(w_inf[MEMS_WIND].handle,
				 WF_INFO,
				 &info_line[0],
				 0,
				 0 );
	}
}
