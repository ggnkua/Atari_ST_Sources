/********************************************
	file: menu.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: 
*********************************************/

/********************************************
	includes
*********************************************/
#include <stdio.h>
#include <string.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"
#include "bufman.h"
#include "dialog.h"
#include "edit.h"
#include "files.h"
#include "init.h"
#include "keys.h"
#include "main.h"
#include "menu.h"
#include "printer.h"
#include "search.h"
#include "send.h"
#include "slider.h"
#include "wind.h"

#include "bfed_rsc.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/

/********************************************
	globals vars declarations
*********************************************/
char moderp[15];
char modein[15];
OBJECT *menu;

/********************************************
	locals functions declarations
*********************************************/
static void handle_file(int itemid);
static void handle_edit(int itemid);
static void handle_search(int itemid);
static void handle_windows(int itemid);
static void handle_desk(int itemid);
static void handle_options(int itemid);

/********************************************
	globals functions definitions
*********************************************/
/*
	name: do_menu
	utility: determines which menu was selected and calls the
		appropriate routine to handle the item selected. 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
void do_menu(int menuid, int itemid)
{
	switch(menuid)
	{
		case DESK:
			handle_desk(itemid);
			break;
		case FILE:
			handle_file(itemid);
			break;
		case EDIT:
			handle_edit(itemid);
			break;
		case SEARCH:
			handle_search(itemid);
			break;
		case WINDOWS:
			handle_windows(itemid);
			break;
		case OPTIONS:
			handle_options(itemid);
			break;
	}
	menu_tnormal(menu, menuid, UNHIGHLIGHT);
}

/*
	name: handle_desk
	utility:  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
static void handle_desk(int itemid)
{
	switch(itemid)
	{
		case ABOUT:
			open_dialog(DINFO);	/* open form */
			break;
	}
}

/*
	name: handle_file
	utility: performs the appropriate action for the menu item selected. 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
		10 may 96: C. Moreau: Take off fileselector in New file function
*/
static void handle_file(int itemid)
{
	const int thewin_kind =   UPARROW | DNARROW | VSLIDE | SIZER |	\
							 MOVER | FULLER | CLOSER | NAME | 		\
							 INFO | SMALLER;
	windowptr	thewin=thefrontwin;
	linkbufptr	bufptr;

	switch(itemid)
	{
		case NEW:	/* opens a new window with associated file  */
			thewin = window_new(thewin_kind);
			
			if(thewin) /* abort if no more window handles */
			{
				bufptr = addmember(thewin);
				if (!bufptr)	/* if no buffer allocated */
				{
					window_resources_dispose(thewin);
					rsc_alert(NOMEM_4);
				}
				else
				{
					bufptr->inuse = 1;
					thewin->flen = 1;
					ins = TRUE;
					thewin->prot = FALSE;
					update_menu();
					window_open(thewin);
				}
			}
			else
			{
				rsc_alert(NOWIND);
			}
			break;
		case OPEN:
			thewin = window_new(thewin_kind);

			if (thewin) /* abort if no more window handles */
			{
				char *string;
	
				rsrc_gaddr(R_STRING, S_LOADFILE, &string);
				if (getfile(thewin, string)
					&& read_file(thewin))
					window_open(thewin);
				else
					window_resources_dispose(thewin);
			}
			break;
		case SAVE:
			if (thewin)
				if (!thewin->form)
					save_file(thewin);
			break;
		case SAVEAS:
		 	if (thewin)
		 		if (!thewin->form)
					write_file(thewin);
			break;
		case CLOSE:
			if (thewin)
				if (!thewin->form)
				{
					dispose_buf(thewin);
					window_dispose(thewin);
				}
			break;
		case DELETE:
			delfile();
			break;
		case SPACE:
			open_dialog(DDISK);
			break;
		case PRINT:
			if (thewin)
				if (!thewin->form)
					print(thewin);
			break;
   	case SETPRINT:
   		open_dialog(DPRINT);
			break;
		case QUIT:
			shutdown(0);
			break;
	}
}

/*
	name: handle_edit
	utility: performs the appropriate action for the menu item selected. 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
static void handle_edit(int itemid)
{
	if (thefrontwin && !thefrontwin->form)
	{
		switch(itemid)
		{
			case START:
				start_mark(thefrontwin);
				break;
			case END:
				end_mark(thefrontwin);
				break;
			case CLEAR:
				clear_marks(thefrontwin);
				break;
			case SELECT_ALL:
				{	
					const long old_pos = thefrontwin->position;
					
					thefrontwin->position = 0;	
					start_mark(thefrontwin);
					thefrontwin->position = thefrontwin->flen-1;	
					end_mark(thefrontwin);
					thefrontwin->position = old_pos;
				}
				break;
			case COPY	:
				if (thefrontwin->markson)
				{	
					copy(thefrontwin);
					clear_marks(thefrontwin);
					menu_ienable(menu, PASTE, ENABLE);
				}
				break;
			case CUT	:
				if (thefrontwin->markson)
				{
					if (!thefrontwin->prot)
					{
						copy(thefrontwin);
						cutit(thefrontwin);
						send_vslid(thefrontwin);
						thefrontwin->changed = TRUE;
						clear_marks(thefrontwin);
						menu_ienable(menu, PASTE, ENABLE);
					}
					else
						rsc_alert(PROTECTED);
				}
				break;
			case PASTE	:
				if (!thefrontwin->prot)
				{
					paste(thefrontwin);
					thefrontwin->changed = TRUE;
				}
				else
					rsc_alert(PROTECTED);
				break;
			case ERASE	:
				if (thefrontwin->markson)
				{
					if (!thefrontwin->prot)
					{
						cutit(thefrontwin);
						send_vslid(thefrontwin);
						thefrontwin->changed = TRUE;
						clear_marks(thefrontwin);
					}
					else
						rsc_alert(PROTECTED);
				}
				break;
			case INSERT :
				ins ^= TRUE;
				update_menu();
				break;
			case PROTECT :
				thefrontwin->prot ^= TRUE;
				update_menu();
				break;
		}
	}
}

/*
	name: handle_search
	utility:  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
static void handle_search(int itemid)
{
	if (thefrontwin)
	{
		switch(itemid)
		{
			case GO_POS:
				open_dialog(DPOS);
				break;
			case FIND:
			case REPLACE:
				open_dialog(DSEARCH);
				break;
			case FINDAGAIN:
				break;
			case REPLACEAGAIN:
				break;
		}
	}
}

/*
	name: handle_windows
	utility:  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
static void handle_windows(int itemid)
{
	if (thefrontwin)
	{
		switch(itemid) 
		{
			case ROTATE			:
				window_rot();
				break;
			case TILE_HORIZ 	:
				window_tile(TRUE);
				break;
			case TILE_VERTIC	:
				window_tile(FALSE);
				break;
			case STACK			:
	
				break;
			case ICONIFY		:
				window_iconify(thefrontwin);
				break;
			case UNICONIFY		:
				window_uniconify(thefrontwin);
				break;
			case ICONIFY_ALL		:
				window_iconify_all();
				break;
		}
	}
}

/*
	name: handle_options
	utility:  
	comment: 
	parameters:
	return:
	date: 13 may 96
	author: C. Moreau
	modifications: 
*/
static void handle_options(int itemid)
{
	switch(itemid) 
	{
		case BLACK_WHITE	:
			black_white ^= TRUE;
			send_redraw_all();		/* redraw all windows */
			break;
		case GROW_SHRINK	:
			grow_shrink ^= TRUE;
			break;
		case INFO_HEXA		:
			info_hexa ^= TRUE;
			break;
		case CLIPBOARD		:
		case SAVEOPTS		:
		case LOADOPTS		:
			break;
	}
	update_menu();
}

/*
	name: init_menu
	utility: sets up menu bar
	comment: 
	parameters: none
	return: none
	date: 1995
	author: C.Moreau
	modifications:
*/
void init_menu(void)
{
	char *string;
	
	rsrc_gaddr(R_STRING, S_MODERP, &string);
	strcpy(moderp, string);
	rsrc_gaddr(R_STRING, S_MODEIN, &string);
	strcpy(modein, string);

	rsrc_gaddr(R_TREE, MENU, &menu);

	if (ver_aes >= 0x410)
	{
		menu_ienable(menu, ICONIFY, ENABLE);
		menu_ienable(menu, UNICONIFY, ENABLE);
		menu_ienable(menu, ICONIFY_ALL, ENABLE);
	}
	else
	{
		menu_ienable(menu, ICONIFY, DISABLE);
		menu_ienable(menu, UNICONIFY, DISABLE);
		menu_ienable(menu, ICONIFY_ALL, DISABLE);
	} 

	menu_bar(menu, MENU_INSTALL);
	update_menu();
}

/*
	name: update_menu
	utility: update the menu bar with globals vars
	comment: 
	parameters: none
	return: none
	date: 11 may 96
	author: C.Moreau
	modifications:
*/
void update_menu(void)
{
	menu_icheck(menu, BLACK_WHITE, (black_white?CHECK:UNCHECK));
	menu_icheck(menu, GROW_SHRINK, (grow_shrink?CHECK:UNCHECK));
	menu_icheck(menu, INFO_HEXA, (info_hexa?CHECK:UNCHECK));
	menu_text(menu, INSERT, (ins?moderp:modein));

	if (thefrontwin && !thefrontwin->form)
	{
		const prot = thefrontwin->prot;
		
	 	if (thefrontwin->markson)
	 	{
			menu_ienable(menu, CUT, ENABLE);
			menu_ienable(menu, COPY, ENABLE);
			menu_ienable(menu, ERASE, ENABLE);
		}
		else
		{
			menu_ienable(menu, CUT, DISABLE);
			menu_ienable(menu, COPY, DISABLE);
			menu_ienable(menu, ERASE, DISABLE);
		}
		
		menu_icheck(menu, PROTECT, prot?CHECK:UNCHECK);
	}
}
