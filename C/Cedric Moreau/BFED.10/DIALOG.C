/*
	file: dialog.c
	utility: Manage forms in windows
	date: 1996
	author: C. Moreau
	modifications:
		17 aug 96: C. Moreau: Suppressed separate title name for
		 forms dialogs.
		23 jan 97: C. Moreau: Changed all functions names to have
			window_ in firs.
 	comments: 
*/

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <tosbind.h>
#include <vdibind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"
#include "config.h"
#include "dialog.h"
#include "events.h"
#include "init.h"
#include "keys.h"
#include "search.h"
#include "wind.h"

#include "bfed_rsc.h"					/* resource */

/*
	Globals vars
*/
OBJECT *dinfo;
OBJECT *dsearch;
OBJECT *ddisk;
OBJECT *dprint;
OBJECT *dpos;

/*
	Locals vars
*/
static char dr_str[32] = {""};	/* for drive space function */

/*
	Locals functions
*/
static void dialog_print_init(void);
static void dialog_disk_init(void); 	
static void dialog_info_init(void);
static void dialog_search_init(void); 	
static void one_dialog(windowptr thewin, GRECT *r1);
static windowptr new_dialog(int thekind);

/*
	name: open_dialog
	utility: make or raise a specific dialog
	comment: (as open_window and new_window)
	parameters:
		int dialog_nb: number of the dialog
	return: none.
	date: 1996
	author: C.Moreau
	modifications:
*/
void open_dialog(int dialog_nb)
{
	windowptr thewin=firstwindow;
	OBJECT *dialog_addr;

	rsrc_gaddr(R_TREE, dialog_nb, &dialog_addr);
	
		/* look if the form is already opened */
	while(thewin)
	{
		if (thewin->form == dialog_addr)
		{
			window_put_top(thewin);
			return;
		}
		thewin = thewin->next;
	}

		/* There is no form */
	thewin = new_dialog(dialog_nb);

	if (thewin)
		window_open(thewin);
	else
		window_resources_dispose(thewin);
}

/*
	name: new_dialog
	utility: create & draw a new dialog.
	comment:
			 	1.)  create the window.
				2.)  draw the window with the wind_open()
				3.)  create and setup the window record.
				Adapted from new_window function.
		This is a Copy of new_window adapted for a dialog.
		Max size is the desktop: Doesn't have a fuller button.
		Title of the dialog is in index # 1 in the Object.
	parameters:
		int dialog_nb: index of dialog.
		*OBJECT dialog_addr: address of the form.
	return: windowptr: ptr on dialog window
	date: 12 may 96
	author: C. Moreau
	modifications: 
*/
static windowptr new_dialog(int dialog_nb)
{
	int handle;					/* window handle */
	int x,y,w,h;				/* window sizes */
	int thekind = NAME|CLOSER|MOVER;	/* window items */
	windowptr thewin=NULL;	/* window ptr */
	OBJECT *dialog_addr;		/* object ptr */

	rsrc_gaddr(R_TREE, dialog_nb, &dialog_addr);

		/*	Create the information for the window.
			Max size is the form. */
	wind_calc(WC_BORDER, thekind,										\
				dialog_addr->ob_x, dialog_addr->ob_y,				\
				dialog_addr->ob_width, dialog_addr->ob_height,	\
				&x, &y, &w, &h);
	
	handle = wind_create(thekind, x, y, w, h);
	if (handle < 0)
		rsc_alert(NOWIND_3);
	else
	{
			/*	Allocate space for window record. */
		thewin = (windowptr) malloc(sizeof(windowrec));
		if (!thewin)
		{
			wind_delete(handle); /* delete the window created above  */
			rsc_alert(NOMEM_5);
		}
		else
		{	 
				/*	Initialize window data structure. */
			thewin->next			= NULL;
			thewin->handle			= handle;
			thewin->kind			= thekind;
			thewin->fullsize		= TRUE;
			thewin->graf.handle 	= -1;
			thewin->updateproc 		= one_dialog;
			thewin->headptr	  		= NULL;
			thewin->startmark   	= 1;
			thewin->endmark	  		= 0;
			thewin->markson     	= 0;
			thewin->xcur		  	= 0;
			thewin->ycur		  	= 0;
			thewin->topchar	  		= 0;
			thewin->flen		  	= 0;
			thewin->position	  	= 0;
			thewin->vslidepos   	= 0;
			thewin->icount	  		= 0;
			thewin->changed	  		= FALSE;	
			thewin->prot		  	= TRUE;
			thewin->form 			= dialog_addr;
	
				/* 1st object contain the dialog title */
			wind_set(handle, WF_NAME, 
					dialog_addr[1].ob_spec.free_string, 0, 0);
	
			insertwindowptr(thewin);
		}
	}
	
	return(thewin);
}

/*
	name: one_dialog
	utility: do the redraw of a dialog.
	comment: 
	parameters:
		windowptr thewin: pointer on the window dialog struct.
		GRECT rect: rectangle to redraw
	return: none
	date: 12 may 96
	author: C.Moreau
	modifications: 
*/
static void one_dialog(windowptr thewin, GRECT *rect)
{
	objc_draw(thewin->form, 0, MAX_DEPTH,	\
			 	rect->g_x, rect->g_y, 		\
			 	rect->g_w, rect->g_h);			   	
}

/*
	name: init_dialog
	utility: initialise vars of dialog.c module
	comment: 
	parameters:none
	return: none
	date: 1995
	author: C.Moreau
	modifications: 
*/
void init_dialog(void)
{
	int dummy;
	
		/* Initialise the forms */
	rsrc_gaddr(R_TREE, DSEARCH, &dsearch);
	rsrc_gaddr(R_TREE, DINFO, &dinfo);
	rsrc_gaddr(R_TREE, DDISK, &ddisk);
	rsrc_gaddr(R_TREE, DPRINT, &dprint);
	rsrc_gaddr(R_TREE, DPOS, &dpos);
	
		/* Center forms */
	form_center(dsearch, &dummy, &dummy, &dummy, &dummy);
	form_center(dinfo, &dummy, &dummy, &dummy, &dummy);
	form_center(ddisk, &dummy, &dummy, &dummy, &dummy);
	form_center(dprint, &dummy, &dummy, &dummy, &dummy);
	form_center(dpos, &dummy, &dummy, &dummy, &dummy);

		/* init forms */
	dialog_search_init();
	dialog_info_init();
	dialog_print_init();
	dialog_disk_init();
}

/*
	name: dialog_search_init
	utility: Set up search Dialog
	comment: 
	parameters:none
	return: none
	date: 1996
	author: C.Moreau
	modifications: 
*/
static void dialog_search_init(void)
{
		/* init search/replace string */
	dsearch[SSTRING].ob_spec.tedinfo->te_ptext = s_str;
	dsearch[SSTRING].ob_spec.tedinfo->te_txtlen = MAX_SEARCH;
	dsearch[RSTRING].ob_spec.tedinfo->te_ptext = r_str;
	dsearch[RSTRING].ob_spec.tedinfo->te_txtlen = MAX_SEARCH;
}

/*
	name: dialog_search_exec
	utility: Actions on a dialog
	comment: Manage actions done on dialogs
		called only from button.c module.
		Exec the command associated to the form.
	parameters: none
	return: none
	date: 1996
	author: C. Moreau
	modifications: 
*/
void dialog_search_exec(void)
{
	if ( objet == CANCEL1 || objet == RBUT || objet == SBUT \
		|| objet == NBUT )
	{
		objc_change(dsearch, objet, 0, dsearch->ob_x,	\
					dsearch->ob_y, dsearch->ob_width,		\
					dsearch->ob_height,	NORMAL, REDRAW);
		if (objet != CANCEL1)
			find0(objet);
		else
			window_dispose(thefrontwin);	/* close window */
	}
	else if ( objet == RALL || objet == RVER			\
			|| objet == RCUTBUF || objet == SCUTBUF	\
			|| objet == RHEXA || objet == SHEXA )
	{
		if (dsearch[objet].ob_state == SELECTED)
			objc_change(dsearch, objet, 0, dsearch->ob_x,	\
						dsearch->ob_y, dsearch->ob_width,		\
						dsearch->ob_height,	NORMAL, REDRAW);
		else
			objc_change(dsearch, objet, 0, dsearch->ob_x,	\
						dsearch->ob_y, dsearch->ob_width,		\
						dsearch->ob_height,	SELECTED, REDRAW);				
	}
}

/*
	name: dialog_info_init
	utility: Set up info Dialog
	comment: 
	parameters:none
	return: none
	date: 1996
	author: C.Moreau
	modifications: 
*/
static void dialog_info_init(void)
{
		/*put version number & proc type */
#if defined(M68K)
	strcpy(dinfo[DINFO_VERSION].ob_spec.tedinfo->te_ptext, "30+82");
#elif defined(M68030)
		strcpy(dinfo[DINFO_VERSION].ob_spec.tedinfo->te_ptext, "68030");
#elif defined(M68000)
		strcpy(dinfo[DINFO_VERSION].ob_spec.tedinfo->te_ptext, "68000");
#endif
	strcat(dinfo[DINFO_VERSION].ob_spec.tedinfo->te_ptext, VERSION);
	strcat(dinfo[DINFO_VERSION].ob_spec.tedinfo->te_ptext, __DATE__);
}

/*
	name: dialog_disk_init
	utility: Set up disk Dialog
	comment: 
		called from menu.c.
		Initialise the form: set the drive button to
		the right config (nb of disk).
		Note that we suppose that the form in the ressource
		contains disabled disk buttons. It put them to normal
		if the drive exist.
	parameters:none
	return: none
	date: 1996
	author: C.Moreau
	modifications: 
*/
#define NB_DISK	16
static void dialog_disk_init(void)
{
	unsigned long drvs = Drvmap();
	int	dr;
	const int drarray[NB_DISK] = {AA,BB,CC,DD,EE,FF,GG,HH,II,JJ,KK,LL,MM,NN,OO,PP};

		/* init disk size info string */
	ddisk[DRSTR1].ob_spec.tedinfo->te_ptext = dr_str;
		
		/* Enable only existing drives */
	for (dr = 1; dr <= NB_DISK; dr++, drvs >>= 1)
		if(drvs & 0x001)
			objc_change(ddisk, drarray[dr-1], 0,	\
				ddisk->ob_x, ddisk->ob_y,			\
		  		ddisk->ob_width, ddisk->ob_height,	\
		  		NORMAL, NO_REDRAW);
}


/*
	name: dialog_disk_exec
	utility: Actions on a dialog
	comment: Manage actions done on dialogs
	parameters: none
	return: none
	date: 1996
	author: C. Moreau
	modifications: 
*/
void dialog_disk_exec(void)
{
	int idr = 0, dr;
	const int drarray[NB_DISK] = {AA,BB,CC,DD,EE,FF,GG,HH,II,JJ,KK,LL,MM,NN,OO,PP};
	DISKINFO myinfo;
		
		/* find the choosen drive */
	for(dr = 1; dr <= NB_DISK; dr++)
		if(drarray[dr-1] == objet)
			idr = dr;

	graf_mouse(BUSYBEE, 0);
	Dfree(&myinfo, idr);
	graf_mouse(ARROW, 0);	

	{
		char *string;

		rsrc_gaddr(R_STRING, S_FREEBYTE, &string);
		sprintf(dr_str, string,										\
				myinfo.b_free*myinfo.b_clsiz*myinfo.b_secsiz,	\
				'A' + (idr-1));
	}
	
	objc_draw(ddisk, DRBOX, 1,				\
				ddisk->ob_x, ddisk->ob_y,	\
				ddisk->ob_width, ddisk->ob_height);
}

/******************PRINT**************************/
/*
	name: dialog_print_init
	utility: Set up printer Dialog
	comment: 
	parameters:none
	return: none
	date: 1996
	author: C.Moreau
	modifications: 
*/
static void dialog_print_init(void)
{
			 /* enable/disable Gdos buttons */
	if (vq_gdos)	/* Bugged fn in Pure C V 1.0 should return -2 if not GDOS */
	{
		const int rsc_array[10]={ PRINT_GDOS, PRINT_ID_PLUS,PRINT_ID_MOINS,
							PRINT_ID, PRINT_NAME,PRINT_FN_PLUS,
							PRINT_FN_MOINS,FONT_ID,FONT_NAME, -1};
		register int i=0;
		
		while (rsc_array[i] != -1)
		{
			objc_change(dprint, rsc_array[i], 0, dprint->ob_x, dprint->ob_y,
						dprint->ob_width, dprint->ob_height, DISABLED, NO_REDRAW); 
			i++;
		}
	}

				/* Find default Device & Fnt */
			/****************/
}

/*
	name: dialog_print_exec
	utility: Actions on a dialog
	comment: Manage actions done on dialogs
	parameters: none
	return: none
	date: 1996
	author: C. Moreau
	modifications: 
*/
void dialog_print_exec(void)
{
	if ( objet == PRINT_OK || objet == PRINT_ANN				\
		|| objet == PRINT_ID_PLUS || objet == PRINT_ID_MOINS	\
		|| objet == PRINT_FN_PLUS || objet == PRINT_FN_MOINS )
	{
		objc_change(dprint, objet, 0, dprint->ob_x,	\
					dprint->ob_y, dprint->ob_width,	\
					dprint->ob_height, NORMAL, REDRAW); 
		if ( objet == PRINT_OK || objet == PRINT_ANN )
			window_dispose(thefrontwin);	/* close window */
	}
	else if (objet == PRINT_GDOS)
	{
		if (vq_gdos != 0)		/* Warning this is an other bugged function of Pure
									it should return -2 if no Gdos */
			objc_change(dprint, PRINT_GDOS, 0, dprint->ob_x,	\
						dprint->ob_y, dprint->ob_width,			\
						dprint->ob_height, NORMAL, REDRAW); 
	}
}

/****************** POS **************************/
/*
	name: dialog_pos_exec
	utility: Take params for going to a position
	comment: Manage actions done on a dialog
	parameters: none
	return: none
	date: 1996
	author: C. Moreau
	modifications: 
*/
void dialog_pos_exec(void)
{
	const windowptr theformwin=thefrontwin;

	if (objet == GO_POS_OK)
	{
		long position;
		windowptr theworkwin = find_workwind();

		objc_change(dpos, GO_POS_OK, 0,	dpos->ob_x,	\
				dpos->ob_y, dpos->ob_width,			\
				dpos->ob_height, NORMAL, REDRAW); 
	
			/* put cursor at position */
		if (dpos[GO_POS_HEXA].ob_state == SELECTED)
		{
			char string[12]="0x";
			register int idx=0;
			
			strcat(string, dpos[GO_POS_IDX].ob_spec.tedinfo->te_ptext);

				/* transform in Upper case */
			while (string[idx])
			{
				string[idx] = toupper(string[idx]);
				idx ++;
			}	
			
			position = strtoul(string, NULL, 16);	/* take New position from string */			
		}
		else
		{						
			position = strtoul(dpos[GO_POS_IDX].ob_spec.tedinfo->te_ptext, NULL,	10); 					
		}

		if (position <= theworkwin->flen)
		{
			theworkwin->position = position;
			check_scroll(theworkwin);
			window_dispose(theformwin);				
		}
		else
			rsc_alert(WRONG_POS);
	}
	else if (objet == GO_POS_ANN)
	{
		objc_change(dpos, objet, 0, dpos->ob_x,		\
					dpos->ob_y, dpos->ob_width,		\
					dpos->ob_height, NORMAL, REDRAW); 
		window_dispose(theformwin);				
	}
}