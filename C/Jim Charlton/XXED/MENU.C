
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

#include "xxed.h"  	/* contains definition of menubar */
#include "globals.h"	/* header file created by RCP     */

extern char *chk_sstr_len();
extern char *chk_rstr_len();

/*
	do_menu - determines which menu was selected and calls the
		appropriate routine to handle the item selected.
*/
do_menu(message)
	int *message;
{
	int menuid, itemid;

	menuid = message[3];
	itemid = message[4];

	switch(menuid) {
		case DESK:
				handle_desk(itemid);
				break;

		case FILE:
				handle_file(itemid);
				break;

		case EDIT:	handle_edit(itemid);
					break;
        case MARK: 	handle_marks(itemid);
                   	break;
		case SEARCH:	handle_search(itemid);
						break;
		case WINDOWS:	rot_wind();
	}

	menu_tnormal(menubar, menuid, 1);
}

handle_desk(itemid)
	int itemid;
{
	switch(itemid) {
		case ABOUT:	do_dialog(dialog2);
					dialog2[OK1].ob_state = NORMAL;
					break;
	}
}


/*
	handle_file - performs the appropriate action for the menu item selected.
*/
handle_file(itemid)
	int itemid;
{
	int  button;
	windowptr	thewin;

	switch(itemid) {
		case NEW:		new();
						break;
		case OPEN:
			thewin = new_window(UPARROW | DNARROW | VSLIDE | SIZER
									 | MOVER | FULLER | CLOSER | NAME);

			if(thewin==NULL) break; /* abort if no more window handles */

			if 	(button = getfile(thewin))
				{	if	(read_file(thewin))
						open_window(thewin);
					else
						dispose_win_resources(thewin);
				}
			else
				dispose_win_resources(thewin);
							break;
        case SAVE:		if(thewin=thefrontwin)
							save_file(thewin);
						break;
        case SAVEAS: 	if(thewin=thefrontwin)
							write_file(thewin);
				 		break;
		case CLOSE:		if (thewin=thefrontwin)
						{	dispose_buf(thewin);
							dispose_window(thewin);
						}
						break;
		case DELETE:	delfile();
						break;
		
		case SPACE:		drives();
						break;

		case PRINT:		if(thewin = thefrontwin)
							print(thewin);
						break;
        
		case QUIT:		shutdown(0);
						break;
	}
}

new()  /* opens a new window with associated file  */
{
	int	button;
	linkbufptr	bufptr;
	windowptr	thewin;

			thewin = new_window(UPARROW | DNARROW | VSLIDE | SIZER
									 | MOVER | FULLER | CLOSER | NAME);
			if(thewin==NULL)
 				return; /* abort if no more window handles */
            bufptr = addmember(thewin);
			if (bufptr == NULL)
				{ 	button = form_alert(1, "[1][ Out of memory. | Cannot create new workspace ][OK]");
					dispose_win_resources(thewin);
				}
			else
			{	open_window(thewin);
				if(getfile(thewin))
				{	bufptr->inuse=1;
					thewin->flen =1;
					ins = TRUE;
					thewin->prot = FALSE;
					menubar[PROTECT].ob_state = NORMAL;
					menubar[INSERT].ob_state = CHECKED;
					menubar[REPLACE].ob_state = NORMAL;
					wr_ins_rpl(ins);
				}
				else
				{	dispose_buf(thewin);
					dispose_window(thewin);
				}
			}
}

/*
	handle_mark - performs the appropriate action for the menu item selected.
*/
handle_marks(itemid)
	int itemid;
{
	char string[80]; 
	windowptr thewin;
       		
	switch(itemid) {
		case START	:   thewin = thefrontwin;
						if(thewin && thewin->flen)/* a window is open ?  */
						start_mark(thewin);
						break;
		 		

		case END	:	thewin = thefrontwin;
						if(thewin && thewin->flen)/* a window is open ?  */
						end_mark(thewin);
						break;

		case CLEAR	: 	thewin = thefrontwin;
						if(thewin && thewin->flen)/* a window is open ?  */
						clear_marks(thewin);
						break;


	}

}

start_mark(thewin)
windowptr	thewin;
{	thewin->startmark = thewin->position;
	if( (thewin->startmark <= thewin->endmark)
				|| thewin->markson )
	{	send_redraw(thewin);
		thewin->markson = TRUE;
		menubar[CUT].ob_state = NORMAL;
		menubar[COPY].ob_state = NORMAL;
		menubar[ERASE].ob_state = NORMAL;
	}	
}

end_mark(thewin)
windowptr	thewin;
{	
	thewin->endmark = thewin->position<thewin->flen-1 ?
							 thewin->position : thewin->flen-2;
	if( (thewin->endmark >= thewin->startmark)
				|| thewin->markson )
	{	send_redraw(thewin);
		thewin->markson = TRUE;
		menubar[CUT].ob_state = NORMAL;
		menubar[COPY].ob_state = NORMAL;
		menubar[ERASE].ob_state = NORMAL;
	}
}

clear_marks(thewin)
windowptr	thewin;
	{	thewin->startmark = 1;
		thewin->endmark = 0;
		one_page(thewin,0);
		thewin->markson = FALSE;
		menubar[CUT].ob_state = DISABLED;
		menubar[COPY].ob_state = DISABLED;
		menubar[ERASE].ob_state = DISABLED;
	}


handle_edit(itemid)
	int itemid;
{
	char string[80]; 
	windowptr thewin;
	linkbufptr	amem;
	long pos;
       		
	switch(itemid) {
		case COPY	: 	if( (thewin = thefrontwin) && thewin->markson)
						{	copy(thewin);
							handle_marks(CLEAR);
							menubar[CUT].ob_state = DISABLED;
							menubar[COPY].ob_state = DISABLED;
							menubar[ERASE].ob_state = DISABLED;
							menubar[PASTE].ob_state = NORMAL;
						}
						break;
		 		

		case CUT	:	if( (thewin = thefrontwin) && thewin->markson)
						if (!thewin->prot)
						{	copy(thewin);
							cutit(thewin);
							send_vslid(thewin);
							thewin->changed = TRUE;
							handle_marks(CLEAR);
							menubar[CUT].ob_state = DISABLED;
							menubar[COPY].ob_state = DISABLED;
							menubar[ERASE].ob_state = DISABLED;
							menubar[PASTE].ob_state = NORMAL;
						}
						else
							prot_warn();
						break;

		case PASTE	: 	if(thewin = thefrontwin)
						if (!thewin->prot)
						{	paste(thewin);
							thewin->changed = TRUE;
						}
						else
							prot_warn();
						break;
		case ERASE	:	if( (thewin = thefrontwin) && thewin->markson)		
						if (!thewin->prot)
						{	cutit(thewin);
							send_vslid(thewin);
							thewin->changed = TRUE;
							handle_marks(CLEAR);
						}
						else
							prot_warn();
						break;
		case INSERT :	ins = TRUE;
						wr_ins_rpl(ins);
				        menubar[INSERT].ob_state = CHECKED;
						menubar[REPLACE].ob_state = NORMAL;
						break;
		case REPLACE :	ins = FALSE;
						wr_ins_rpl(ins);
				        menubar[INSERT].ob_state = NORMAL;
						menubar[REPLACE].ob_state = CHECKED;
						break;				
		case PROTECT :	if(thewin = thefrontwin)
						{	thewin->prot ^= 1;
							if(thewin->prot)
							menubar[PROTECT].ob_state = CHECKED;
							else
							menubar[PROTECT].ob_state = NORMAL;
						}
						break;
	}

}

prot_warn()
{
	int button;
	button = form_alert(1, "[1][ Read-only protection on. | Click 'protect' in edit menu | to allow editing. ][OK]");
}

handle_search(itemid)
	int itemid;
{
	char *sstr;
	windowptr	thewin; 

	if(thewin=thefrontwin)	
	{	switch(itemid) {
			case FIND	:		find0(thewin);
								break;
			case FORWARD	:	if(sstr = chk_sstr_len(thewin))
								forward1(thewin,sstr);
								check_scroll(thewin);
								break;
			case BACK	:		if(sstr = chk_sstr_len(thewin))
								back1(thewin,sstr);
								break;
						}
	}
}
