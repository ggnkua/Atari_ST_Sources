/****************************************************************************

 Module
  menu.c
  
 Description
  Menu routines used in oAESis.
  
 Author(s)
 	cg     (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	marbud (Martin Budsj” <marbud@tripnet.se>) 

 Revision history
 
  951226 cg
   Concatenated menu_lib.c and menu_srv.c into menu.c.
   Added standard header.

  960101 cg
   menu_ienable() implemented in Menu_ienable().
   menu_icheck() implemented in Menu_icheck().
   menu_tnormal() implemented in Menu_tnormal().

  960306 kkp
   The menu structure integrated with AP_INFO.   
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <basepage.h>
#include <ctype.h>
#include <mintbind.h>
#include <process.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "appl.h"
#include "boot.h"
#include "debug.h"
#include "evnt.h"
#include "form.h"
#include "fsel.h"
#include "gemdefs.h"
#include "global.h"
#include "lxgemdos.h"
#include "mintdefs.h"
#include "menu.h"
#include "mesagdef.h"
#include "misc.h"
#include "objc.h"
#include "rdwrs.h"
#include "resource.h"
#include "rsrc.h"
#include "types.h"
#include "wind.h"

#include <sysvars.h>

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define MENU_GEN_ERR	0
#define MENU_GEN_OK		1

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

/*MENUREG is used to keep track of the application menu*/
typedef struct menureg {
	WORD apid;            /*Owner of entry       */
	BYTE *name;           /*Application name     */
	
	struct menureg *mn_next; /*Pointer to next entry*/
}MENUREG;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

/*
 *	Global struct for menu lib.. Created by menu_handl_init()
 */
struct {
	WORD menu_cur_apid;   /* Application id of the current menu owner.    */
	WORD menu_handl_apid; /* Set to the apid of the menu_handler process. */
	WORD winbar;          /* Window handle of the menu bar window         */
} mglob = {
	-1,
	-1,
	-1
};

static BYTE progpath[500],progfile[70];

static GLOBAL_ARRAY global_array;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/
/* 
	create_window creates a menu window with no attributes.
	
	Inputs:	maxsize = the maximum size of the window
	Return:	handle of the window
*/
static WORD	create_menu_window(RECT *maxsize) {
	WORD	wid;
	
	Rdwrs_operation(WSTARTWRITE);
	
	wid = Wind_do_create(0,0,maxsize,WIN_MENU);

	Rdwrs_operation(WENDWRITE);
		
	return wid;
}

static WORD menu_init_windows(void) {
	RECT	r;
	
	Wind_do_get(0,WF_FULLXYWH, &r.x, &r.y, &r.width, &r.height);
	
	r.height = r.y;
	r.y = 0;

	mglob.winbar = create_menu_window(&r);

	if (mglob.winbar < 0) {
		DB_printf("%s: Line %d: menu_init_windows\r\n"
							"Could not create menubar window.",
							__FILE__,__LINE__);
							
		return MENU_GEN_ERR;
	};

	Rdwrs_operation(WSTARTWRITE);

	Wind_do_open(global_array.int_info->vid,mglob.winbar,&r);

	Rdwrs_operation(WENDWRITE);


	return 0;
}

static void redraw_menu_bar(void) {
	OBJECT *menu;

	Wind_beg_update();

	Rdwrs_operation(MSTARTREAD);
	
	Rdwrs_operation(ASTARTREAD);
	
	menu = Appl_get_menu(TOP_MENU_OWNER);
	
	Rdwrs_quick(AENDREAD);

	if(menu) {
		RECT r;
		
		Wind_do_get(mglob.winbar,WF_FIRSTXYWH,&r.x,&r.y,&r.width,&r.height);
	
		while((r.width > 0) && (r.height > 0)) {
			Objc_do_draw(global_array.int_info->vid,menu,0,9,&r);
	
			Wind_do_get(mglob.winbar,WF_NEXTXYWH,&r.x,&r.y,&r.width,&r.height);
		};
/*
	}
	else {

		DB_printf("%s: Line %d: redraw_menu_bar:\r\n",
									"Couldn't find top menu",
									__FILE__,__LINE__);
*/
	};
	
	Rdwrs_quick(MENDREAD);

	Wind_end_update();
}

/*
 *	Menu install code.. 
 *
 *	Creates and updates the menu list entries for the specified menu. 
 *	Menu capid is unique. New capid => new menu. Old capid => update menu.
 *
 */
static WORD       /* .w return code.*/
menu_bar_install( /* menu_bar(MENU_INSTALL) */
OBJECT *tree,     /* object tree. Pointer to the menu's OBJECT	*/
WORD   capid)     /* Current application id. Menu owner	*/
{
	WORD         i;

  /* Lock the menu list from other processes.. 	*/

	Rdwrs_operation(MSTARTWRITE);
	
	Appl_set_menu(capid,tree);

	/*Unlock the menu list..				 	*/
	Rdwrs_quick(MENDWRITE);

	/* Modify height of bar and titles*/
	
	tree[tree[0].ob_head].ob_height = globals.clheight + 3;
	tree[tree[tree[0].ob_head].ob_head].ob_height = globals.clheight + 3;

	i = tree[tree[tree[0].ob_head].ob_head].ob_head;

	while(i != -1) {		
		tree[i].ob_height = globals.clheight + 3;
		
		if(i == tree[tree[i].ob_next].ob_tail) {
			break;
		};
		
		i = tree[i].ob_next;
	};

	/* Mark all drop down menus with HIDETREE and set y position */
	tree[tree[tree[0].ob_head].ob_next].ob_y = globals.clheight + 3;

	i = tree[tree[tree[0].ob_head].ob_next].ob_head;

	while(i != -1) {		
		tree[i].ob_flags |= HIDETREE;
		
		if(i == tree[tree[i].ob_next].ob_tail) {
			break;
		};
		
		i = tree[i].ob_next;
	};

	redraw_menu_bar();

	return MENU_GEN_OK;
}

/*
 * 	This one is simple.. Return the apid of the currently topped menu owner.
 * 
 */
static WORD         /* .w return code	*/
menu_bar_inquire(   /*	*/
void)               /*	*/
{
	WORD	ret;
	
	Rdwrs_operation(MSTARTREAD);
	
	ret = mglob.menu_cur_apid;
	
	Rdwrs_operation(MENDREAD);
	
	return ret;
}


/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Menu_init_module                                                         *
 *  Initialize menu module.                                                 *
 ****************************************************************************/
WORD                   /*                                                   */
Menu_init_module(void) /*                                                   */
/****************************************************************************/
{
	strcpy(progpath,"u:\\*");
	
	strcpy(progfile,"");

	return 0;
}

/****************************************************************************
 *  Menu_exit_module                                                        *
 *   Shutdown menu module.                                                  *
 ****************************************************************************/
void                   /*                                                   */
Menu_exit_module(void) /*                                                   */
/****************************************************************************/
{
  Appl_do_exit(mglob.menu_handl_apid,global_array.int_info->vid);
}


/****************************************************************************
 *  Menu_handler                                                            *
 *   Handle main menu events.                                               *
 ****************************************************************************/
void                   /*                                                   */
Menu_handler(void)     /*                                                   */
/****************************************************************************/
{
  RECT    f;
  MENUMSG	msg;
	WORD    quit = FALSE;

	mglob.menu_handl_apid = Appl_do_init(&global_array);

	menu_init_windows();

	Menu_do_register(mglob.menu_handl_apid,"  oAESis");

	menu_bar_install(globals.menutad,mglob.menu_handl_apid);


  globals.deskbgtad[0].ob_x = globals.screen.x;
  globals.deskbgtad[0].ob_y = globals.screen.y + globals.clheight + 3;
  globals.deskbgtad[0].ob_width = globals.screen.width;
  globals.deskbgtad[0].ob_height = globals.screen.height - globals.clheight - 3;

	Rdwrs_operation(WSTARTWRITE);
	Appl_set_deskbg(mglob.menu_handl_apid,global_array.int_info->vid,globals.deskbgtad);
	Rdwrs_operation(WENDWRITE);

	Boot_start_programs();
							
  /* Start waiting for messages and rect 1 */
  while(!quit) {
  	EVENTIN  ei;
  	EVENTOUT eo;

		ei.events = MU_MESAG | MU_KEYBD;
		  	
		Evnt_do_multi(mglob.menu_handl_apid,
									global_array.int_info->eventpipe,
									global_array.int_info->msgpipe,
									&ei,(COMMSG *)&msg,&eo,0);
			   			
    if(MU_MESAG & eo.events) {
      switch(msg.type) {
      case MN_SELECTED:
				switch(msg.title) {
				case MENU_FILE:
					switch(msg.item) {
						case MENU_QUIT:
							quit = TRUE;
							break;

						case MENU_STARTPROG:
							{
								BYTE	execpath[128];
								BYTE	oldpath[128];
								BYTE *tmp;
								WORD button;


								Fsel_do_exinput(mglob.menu_handl_apid,
															global_array.int_info->vid,
															global_array.int_info->eventpipe,
															&button,
															"Select program to start",progpath,progfile);
						
								if(button == FSEL_OK) {
									LONG err;
									BYTE newpath[128];
									
									strcpy(newpath,progpath);
									
									tmp = strrchr(newpath,'\\');
									
									if(tmp) {
										*tmp = '\0';
										sprintf(execpath,"%s\\%s",newpath,progfile);
									}
									else {
										strcpy(execpath,progfile);
									};
									
									Dgetpath(oldpath,0);
								
									Misc_setpath(newpath);
									
									err = Pexec(100,execpath,0L,0L);
									
									Misc_setpath(oldpath);
									
									if(err < 0) {
										Form_do_error(mglob.menu_handl_apid,
																	global_array.int_info->vid,
																	global_array.int_info->eventpipe,
																	(WORD) -err - 31);
									};
								};
							};
							break;
					};
			    break;
			  
			  case MENU_OAESIS:
					switch(msg.item) {
					case MENU_INFO:
						Form_do_center(globals.informtad,&f);
						Form_do_dial(mglob.menu_handl_apid,
												global_array.int_info->vid,FMD_START,&f,&f);
						Objc_do_draw(global_array.int_info->vid,globals.informtad,0,9,&f);
						Form_do_do(mglob.menu_handl_apid,
												global_array.int_info->vid,
												global_array.int_info->eventpipe,
												globals.informtad,0);
						globals.informtad[INFOOK].ob_state &= ~SELECTED;
						Form_do_dial(mglob.menu_handl_apid,
												global_array.int_info->vid,FMD_FINISH,&f,&f);
						break;
					};
					break;
				};
				break;
	
			case MH_TOP:
				{
					if(Appl_top(((COMMSG *)&msg)->msg0,global_array.int_info->vid) != ((COMMSG *)&msg)->msg0) {
						Wind_appl_top(global_array.int_info->vid,((COMMSG *)&msg)->msg0);
					
						Rdwrs_operation(MSTARTWRITE);
						Rdwrs_operation(ASTARTREAD);
						Menu_update_appl();
						Rdwrs_operation(AENDREAD);
						Rdwrs_operation(MENDWRITE);

						if(Appl_get_menu(((COMMSG *)&msg)->msg0)) {
							redraw_menu_bar();
						};
					};
				};
				break;
					
      default:
      	DB_printf("Unknown message %d in Menu_handler\r\n",msg.type);
      };
    };
    
    if(MU_KEYBD & eo.events) {
      if((eo.kc & 0xff) == 'q') {
				quit = TRUE;
			};
    };
  };
}

/****************************************************************************
 * Menu_bar_remove                                                          *
 *  Remove menu.                                                            *
 ****************************************************************************/
WORD              /*                                                        */
Menu_bar_remove(  /*                                                        */
WORD apid)        /* Application whose menu is to be removed.               */
/****************************************************************************/
{
	/*	Lock the menu list.. */
	Rdwrs_operation(MSTARTWRITE);

	Appl_set_menu(apid,NULL);	

	Rdwrs_quick(MENDWRITE);

	redraw_menu_bar();

	return MENU_GEN_OK;
}


/****************************************************************************
 *  Menu_bar                                                                *
 *   0x001e menu_bar() library code.                                        *
 ****************************************************************************/
void              /*                                                        */
Menu_bar(         /*                                                        */
AES_PB *apb)      /* Pointer to AES parameter block.                        */
/****************************************************************************/
{
	switch(apb->int_in[0]) {
		case	MENU_INSTALL: 
			apb->int_out[0] = menu_bar_install((OBJECT *)apb->addr_in[0]
						,apb->global->apid);
			break;
			
		case	MENU_REMOVE:
			apb->int_out[0] = Menu_bar_remove(apb->global->apid);
			break;
			
		case	MENU_INQUIRE:
			apb->int_out[0] = menu_bar_inquire();
			break;
			
		default:
			apb->int_out[0] = MENU_GEN_ERR;
	};
}

/****************************************************************************
 *  Menu_icheck                                                             *
 *   0x001f menu_icheck().                                                  *
 ****************************************************************************/
void              /*                                                        */
Menu_icheck(      /*                                                        */
AES_PB *apb)      /* Pointer to AES parameter block.                        */
/****************************************************************************/
{
	switch(apb->int_in[1]) {
	case UNCHECK:
		((OBJECT *)apb->addr_in[0])[apb->int_in[0]].ob_state &= ~CHECKED;
		apb->int_out[0] = 1;
		break;
	
	default:
		((OBJECT *)apb->addr_in[0])[apb->int_in[0]].ob_state |= CHECKED;
		apb->int_out[0] = 1;
	}
}

/****************************************************************************
 *  Menu_ienable                                                            *
 *   0x0020 menu_ienable().                                                 *
 ****************************************************************************/
void              /*                                                        */
Menu_ienable(     /*                                                        */
AES_PB *apb)      /* Pointer to AES parameter block.                        */
/****************************************************************************/
{
	switch(apb->int_in[1]) {
	case DISABLE:
		((OBJECT *)apb->addr_in[0])[apb->int_in[0]].ob_state |= DISABLED;
		apb->int_out[0] = 1;
		break;

	default:
		((OBJECT *)apb->addr_in[0])[apb->int_in[0]].ob_state &= ~DISABLED;
		apb->int_out[0] = 1;
	};
}

/****************************************************************************
 *  Menu_tnormal                                                            *
 *   0x0021 menu_tnormal().                                                 *
 ****************************************************************************/
void              /*                                                        */
Menu_tnormal(     /*                                                        */
AES_PB *apb)      /* Pointer to AES parameter block.                        */
/****************************************************************************/
{
	switch(apb->int_in[1]) {
	case UNHIGHLIGHT:
		((OBJECT *)apb->addr_in[0])[apb->int_in[0]].ob_state &= ~SELECTED;
		apb->int_out[0] = 1;
		break;

	case HIGHLIGHT:
		((OBJECT *)apb->addr_in[0])[apb->int_in[0]].ob_state |= SELECTED;
		apb->int_out[0] = 1;
		break;
	default:
		DB_printf("%s: Line %d: Menu_tnormal:\r\n"
						"Unknown mode %d!\r\n",__FILE__,__LINE__,apb->int_in[1]);
		apb->int_out[0] = 0;
	};
}


/****************************************************************************
 *  Menu_text                                                               *
 *   0x0022 menu_text().                                                    *
 ****************************************************************************/
void              /*                                                        */
Menu_text(        /*                                                        */
AES_PB *apb)      /* Pointer to AES parameter block.                        */
/****************************************************************************/
{
	OBJECT  *ob = (OBJECT *)apb->addr_in[0];
	TEDINFO *ti;
	
	if(ob->ob_flags & INDIRECT) {
		ti = ob->ob_spec.indirect->tedinfo;
	}
	else {
		ti = ob->ob_spec.tedinfo;
	};

	strcpy(ti->te_ptext,
					(BYTE *)apb->addr_in[1]);
					
	apb->int_out[0] = 1;
}

/****************************************************************************
 * Menu_update_appl                                                         *
 *  Update the application menu.                                            *
 ****************************************************************************/
WORD                   /* Top application id.                               */
Menu_update_appl(void) /*                                                   */
/****************************************************************************/
{
	AP_LIST *mwalk;
	WORD    rwalk;
	WORD    topappl;
	
	topappl = Appl_get_top();

	mwalk = globals.applmenu;
	rwalk = PMENU_FIRST;
	
	while(mwalk) {
		strcpy(globals.pmenutad[rwalk].ob_spec.free_string,mwalk->ai->name);

		if(mwalk->ai->id == topappl) {
			globals.pmenutad[rwalk].ob_state |= CHECKED;
		}
		else {
			globals.pmenutad[rwalk].ob_state &= ~CHECKED;
		};
	
		globals.pmenutad[rwalk].ob_flags &= ~HIDETREE;
		globals.pmenutad[rwalk].ob_state &= ~DISABLED;

		mwalk = mwalk->mn_next;
		rwalk++;
	};
	
	if(globals.accmenu) {
		strcpy(globals.pmenutad[rwalk].ob_spec.free_string,
						"----------------------");
		globals.pmenutad[rwalk].ob_flags &= ~HIDETREE;
		globals.pmenutad[rwalk].ob_state &= ~CHECKED;
		globals.pmenutad[rwalk].ob_state |= DISABLED;
		rwalk++;
	};

	mwalk = globals.accmenu;
	
	while(mwalk) {
		strcpy(globals.pmenutad[rwalk].ob_spec.free_string,mwalk->ai->name);

		if(mwalk->ai->id == topappl) {
			globals.pmenutad[rwalk].ob_state |= CHECKED;
		}
		else {
			globals.pmenutad[rwalk].ob_state &= ~CHECKED;
		};
	
		globals.pmenutad[rwalk].ob_flags &= ~HIDETREE;
		globals.pmenutad[rwalk].ob_state &= ~DISABLED;

		mwalk = mwalk->mn_next;
		rwalk++;
	};

	globals.pmenutad[rwalk].ob_flags |= HIDETREE;
	
	globals.pmenutad[0].ob_height = globals.pmenutad[rwalk].ob_y;
	
	return topappl;
}

/****************************************************************************
 * Menu_unregister                                                          *
 *  Remove menu entry of application.                                       *
 ****************************************************************************/
void              /*                                                        */
Menu_unregister(  /*                                                        */
WORD apid)        /* Application id.                                        */
/****************************************************************************/
{
	AP_LIST **mwalk;
	
	Rdwrs_operation(MSTARTWRITE);
	Rdwrs_operation(ASTARTREAD);
	
	mwalk = &globals.applmenu;
	
	while(*mwalk) {
		if((*mwalk)->ai->id == apid) {
			*mwalk = (*mwalk)->mn_next;
			break;
		};
		mwalk = &(*mwalk)->mn_next;
	};

	mwalk = &globals.accmenu;
	
	while(*mwalk) {
		if((*mwalk)->ai->id == apid) {
			*mwalk = (*mwalk)->mn_next;
			break;
		};
		mwalk = &(*mwalk)->mn_next;
	};

	Rdwrs_operation(AENDREAD);
	Rdwrs_quick(MENDWRITE);
}

/****************************************************************************
 * Menu_do_register                                                         *
 *  Implementation of menu_register().                                      *
 ****************************************************************************/
WORD              /* Menu identification, or -1.                            */
Menu_do_register( /*                                                        */
WORD apid,        /* Application id, or -1.                                 */
BYTE *title)      /* Title to register application under.                   */
/****************************************************************************/
{
	AP_LIST **mwalk;
	AP_LIST *ap;
	WORD    n_menu = apid;
	
	Rdwrs_operation(MSTARTWRITE);	
	Rdwrs_operation(ASTARTREAD);
	
	ap = Appl_search_apid(apid);
	
	if(!ap) {
		Rdwrs_operation(AENDREAD);
		Rdwrs_operation(MENDWRITE);
		
		return -1;
	};
	
/* if the menu have been registered then unlink it again */	
	if(ap->ai->type & APP_ACCESSORY) {
		mwalk = &globals.accmenu;
	}
	else {
		mwalk = &globals.applmenu;	
	};
	
	while(*mwalk) {
		if(*mwalk == ap) {
			*mwalk = (*mwalk)->mn_next;
			break;
		};
		
		mwalk = &(*mwalk)->mn_next;
	}

/* now find a new position to enter the menu */
	
	if(ap->ai->type & APP_ACCESSORY) {
		mwalk = &globals.accmenu;
	}
	else {
		mwalk = &globals.applmenu;
	}
	
	while(*mwalk) {	
		if(stricmp((*mwalk)->ai->name, title) > 0) {
			break;
		};
		
		mwalk = &(*mwalk)->mn_next;
	};

/* insert the menu */	

	ap->mn_next = *mwalk;
	*mwalk = ap;		
	strncpy(ap->ai->name,title,20);
	
	Menu_update_appl();
	
	Rdwrs_operation(AENDREAD);
	Rdwrs_quick(MENDWRITE);

	return n_menu;
}

/****************************************************************************
 * Menu_register                                                            *
 *  0x0023 menu_register().                                                 *
 ****************************************************************************/
void              /*                                                        */
Menu_register(    /*                                                        */
AES_PB *apb)      /* Pointer to AES parameter block.                        */
/****************************************************************************/
{
	apb->int_out[0] = Menu_do_register(/*apb->global->apid,*/apb->int_in[0],
													(BYTE *)apb->addr_in[0]);
}
