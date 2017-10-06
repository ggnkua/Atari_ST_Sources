/****************************************************************************

 Module
  form.c
  
 Description
  Form handling routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)

 Revision history
 
  960101 cg
   Added standard header.
   Basic form_keybd() implemented with Form_keybd() and Form_do_keybd().
 
  960419 cg
   Fixed error in form_keybd(). The Compendium was wrong (again!).
   
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <mintbind.h>
#include <stdio.h>

#include "appl.h"
#include "debug.h"
#include "evnt.h"
#include "evnthndl.h"
#include "form.h"
#include "gemdefs.h"
#include "global.h"
#include "graf.h"
#include "mintdefs.h"
#include "objc.h"
#include "resource.h"
#include "rsrc.h"
#include "types.h"
#include "wind.h"

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/*form_do 0x0032*/

/****************************************************************************
 * Form_do_do                                                               *
 *  Implementation of form_do.                                              *
 ****************************************************************************/
WORD           /* Object that was selected.                                 */
Form_do_do(    /*                                                           */
WORD apid,     /* Application id.                                           */
WORD vid,      /* VDI workstation id.                                       */
WORD eventpipe,/* Event message pipe.                                       */
OBJECT *tree,  /* Resource tree.                                            */
WORD editobj)  /* Position of edit cursor.                                  */
/****************************************************************************/
{
	WORD buffer[16];
	WORD object,newobj,keyout;
	WORD idx;
	
	EVENTIN	ei = 	{
	  MU_BUTTON | MU_KEYBD,
	  2,
	  LEFT_BUTTON,
	  LEFT_BUTTON,
	  0,
	  {0,0,0,0},
	  0,
	  {0,0,0,0},
	  0,
	  0
	  };
							
	EVENTOUT	eo;

	if(editobj != 0) {
		Objc_do_edit(vid,tree,editobj,0,&idx,ED_INIT);
	};

	Evhd_gain_mctrl(apid,0);
	
	while(1) {
		Evnt_do_multi(apid,eventpipe,-1,&ei,(COMMSG *)buffer,&eo,0);

		if(eo.events & MU_BUTTON) {
			object = Objc_do_find(tree,0,9,eo.mx,eo.my,0);

			if(object >= 0) {
				if(!Form_do_button(apid,vid,eventpipe,tree,object,eo.mc,&newobj)) {
					if(editobj != 0) {
						Objc_do_edit(vid,tree,editobj,0,&idx,ED_END);
					};

					Evhd_release_mctrl();
					return newobj;
				}
				else {
					if((newobj != 0) && (newobj != editobj)) {
						if(editobj != 0) {
							Objc_do_edit(vid,tree,editobj,0,&idx,ED_END);
						};
				
						editobj = newobj;

						Objc_do_edit(vid,tree,editobj,0,&idx,ED_INIT);
					};
				};
			};
		};
		
		if(eo.events & MU_KEYBD) {
			if(!Form_do_keybd(vid,tree,editobj,eo.kc,&newobj,&keyout)) {
				if(editobj != 0) {
					Objc_do_edit(vid,tree,editobj,0,&idx,ED_END);
				};

				Evhd_release_mctrl();
				return newobj;
			}
			else if(newobj != editobj) {
				if(editobj != 0) {
					Objc_do_edit(vid,tree,editobj,0,&idx,ED_END);
				};
				
				editobj = newobj;

				if(editobj != 0) {
					Objc_do_edit(vid,tree,editobj,0,&idx,ED_INIT);
				};
			}
			else {
				if((editobj != 0) && (keyout != 0)) {
					Objc_do_edit(vid,tree,editobj,keyout,&idx,ED_CHAR);
				};
			};
		};
	};
}

void	Form_do(AES_PB *apb) {
	apb->int_out[0] = Form_do_do(apb->global->apid,
		apb->global->int_info->vid,
		apb->global->int_info->eventpipe,
		(OBJECT *)apb->addr_in[0],
		apb->int_in[0]);		
}

/*form_dial 0x0033*/

WORD	Form_do_dial(WORD apid,WORD vid,WORD mode,RECT *r1,RECT *r2) {
	switch(mode) {
		case	FMD_GROW		:	/*0x0001*/
			Wind_beg_update();
			Graf_do_grmobox(vid,r1,r2);
			Wind_end_update();
			
			return 1;
					
		case	FMD_START	:	/*0x0000*/
			if((r2->width > 0) && (r2->height > 0)) {
				WORD	id;
				
				Rdwrs_operation(WSTARTWRITE);

				if((globals.win_vis->win->status & WIN_DIALOG)
					&& (globals.win_vis->win->owner == apid)) {
					id = globals.win_vis->win->id;
					
					Wind_do_close(vid,id);
					
					Wind_do_delete(vid,id);
				};

				id = Wind_do_create(apid,0
					,r2,WIN_DIALOG);
				
				Wind_do_open(vid,id,r2);

				Rdwrs_operation(WENDWRITE);

				return 1;
			}
			else {
				return 0;
			};

		case	FMD_SHRINK	:	/*0x0002*/
			Wind_beg_update();
			Graf_do_grmobox(vid,r2,r1);
			Wind_end_update();

		case	FMD_FINISH	:	/*0x0003*/
			Rdwrs_operation(WSTARTWRITE);

			if(globals.win_vis) {
				if((globals.win_vis->win->status & WIN_DIALOG)
					&& (globals.win_vis->win->owner == apid)) {
					WORD	id = globals.win_vis->win->id;
					
					Wind_do_close(vid,id);
					
					Wind_do_delete(vid,id);
				};
			};
			
			Rdwrs_operation(WENDWRITE);
			
			return 1;
			
		default	:
			return 0;
	};
}

void	Form_dial(AES_PB *apb) {
	apb->int_out[0] = Form_do_dial(apb->global->apid,
		apb->global->int_info->vid,apb->int_in[0],
		(RECT *)&apb->int_in[1],(RECT *)&apb->int_in[5]);
};

/*form_alert 0x0034*/

WORD	do_form_alert(WORD apid,WORD vid,WORD eventpipe,WORD def,BYTE *alertstring) {
	BYTE	*s = (BYTE *)Mxalloc(strlen(alertstring) + 1,PRIVATEMEM);
	
	WORD	i = 0;
	
	WORD	no_rows = 1,no_butts = 1;
	
	WORD	cwidth,cheight,width,height;
	
	WORD	but_chosen;
	
	OBJECT	*tree;
	TEDINFO	*ti;
	
	RECT	 clip;
	
	BYTE	 *icon,*text,*buttons;

	WORD	 textwidth = 0,buttonwidth = 0;
	
	Graf_do_handle(&cwidth,&cheight,&width,&height);
	
	strcpy(s,alertstring);
	
	while(s[i] != '[')
		i++;
	
	icon = &s[i + 1];
	
	while(s[i] != ']')
		i++;
	
	s[i] = 0;
		
	while(s[i] != '[')
		i++;
		
	text = &s[i + 1];
	
	while(s[i] != ']')
	{
		if(s[i] == '|')
		{
			s[i] = 0;
			no_rows++;
		};
		
		i++;
	};
	
	s[i] = 0;
	
	while(s[i] != '[')
		i++;
		
	buttons = &s[i + 1];
	
	while(s[i] != ']')
	{
		if(s[i] == '|')
		{
			s[i] = 0;
			no_butts++;
		};
		
		i++;
	};
		
	s[i] = 0;
	
	tree = (OBJECT *)Mxalloc((2 + no_butts + no_rows) * sizeof(OBJECT)
				,PRIVATEMEM);
	
	ti = (TEDINFO *)Mxalloc(no_rows * sizeof(TEDINFO),PRIVATEMEM);
	
	memcpy(&tree[0],&globals.alerttad[0],sizeof(OBJECT));
	
	tree[0].ob_head = -1;
	tree[0].ob_tail = -1;
	
	for(i = 0; i < no_rows; i ++) {
		memcpy(&tree[1 + i],&globals.alerttad[AL_TEXT],sizeof(OBJECT));
		memcpy(&ti[i],globals.alerttad[AL_TEXT].ob_spec.tedinfo
			,sizeof(TEDINFO));
		tree[i + 1].ob_width = (WORD)(strlen(text) * cwidth);
		tree[i + 1].ob_height = globals.clheight;
		tree[i + 1].ob_spec.tedinfo = &ti[i];
	
		tree[i + 1].ob_spec.tedinfo->te_ptext = text;
	
		tree[i + 1].ob_flags &= ~LASTOB;

		if(tree[i + 1].ob_width > textwidth)
			textwidth = tree[i + 1].ob_width;

		while(*text)
			text++;
			
		text++;
	
		do_objc_add(tree,0,i + 1);
	};

	for(i = 0; i < no_butts; i ++) {
		memcpy(&tree[1 + i + no_rows],&globals.alerttad[AL_BUTTON],sizeof(OBJECT));
	
		tree[i + 1 + no_rows].ob_y = no_rows * globals.clheight + 20;

		tree[i + 1 + no_rows].ob_height = globals.clheight;
	
		tree[i + 1 + no_rows].ob_spec.free_string = buttons;

		tree[i + 1 + no_rows].ob_flags &= ~LASTOB;

		width = (WORD)(strlen(buttons) * cwidth);

		if(width > buttonwidth)
			buttonwidth = width;
	
		while(*buttons)
			buttons++;
			
		buttons++;
	
		do_objc_add(tree,0,i + 1 + no_rows);
	};
	
	memcpy(&tree[1 + no_butts + no_rows],&globals.alerttad[AL_ICON],sizeof(OBJECT));

	do_objc_add(tree,0,1 + no_butts + no_rows);

	switch(*icon) {
	case '1':
		tree[1 + no_butts + no_rows].ob_spec.index = globals.aiconstad[AIC_EXCLAMATION].ob_spec.index;
		break;

	case '2':
		tree[1 + no_butts + no_rows].ob_spec.index = globals.aiconstad[AIC_QUESTION].ob_spec.index;
		break;

	case '3':
		tree[1 + no_butts + no_rows].ob_spec.index = globals.aiconstad[AIC_STOP].ob_spec.index;
		break;

	case '4':
		tree[1 + no_butts + no_rows].ob_spec.index = globals.aiconstad[AIC_INFO].ob_spec.index;
		break;

	case '5':
		tree[1 + no_butts + no_rows].ob_spec.index = globals.aiconstad[AIC_DISK].ob_spec.index;
		break;

	default:
	tree[1 + no_butts + no_rows].ob_flags |= HIDETREE;		
	};
		
	buttonwidth += 2;

	if(def) {
		tree[no_rows + def].ob_flags |= DEFAULT;
	};
	
	tree[no_rows + no_butts + 1].ob_flags |= LASTOB;

	tree[0].ob_width = (buttonwidth + 10) * no_butts + 10;
	
	if(textwidth + 28 + tree[1 + no_butts + no_rows].ob_width
			> tree[0].ob_width) {
		tree[0].ob_width = textwidth + 28 +
			tree[1 + no_butts + no_rows].ob_width;
	};
	
	tree[0].ob_height = globals.clheight * no_rows + 45;
	
	for(i = 0; i < no_rows; i++) {
		tree[i + 1].ob_x = (tree[0].ob_width - textwidth - 
			tree[1 + no_butts + no_rows].ob_width) / 2 +
			tree[1 + no_butts + no_rows].ob_width + 8;
		tree[i + 1].ob_y = i * globals.clheight + 10;
	};
	
	for(i = 0; i < no_butts; i++) {
		tree[i + no_rows + 1].ob_x = (buttonwidth + 10) * i
					+ ((tree[0].ob_width - (buttonwidth + 10) * no_butts
					+10) >> 1);
		tree[i + 1 + no_rows].ob_width = buttonwidth;
	};
	
	Form_do_center(tree,&clip);

	Form_do_dial(apid,vid,FMD_START,&clip,&clip);

	Objc_do_draw(vid,tree,0,9,&clip);

	but_chosen = Form_do_do(apid,vid,eventpipe,tree,0) & 0x7fff;
	
	Form_do_dial(apid,vid,FMD_FINISH,&clip,&clip);

	Mfree(ti);
	Mfree(tree);
	Mfree(s);
	
	return but_chosen - no_rows;
}

void	Form_alert(AES_PB *apb) {
	apb->int_out[0] = do_form_alert(apb->global->apid,
											apb->global->int_info->vid,
											apb->global->int_info->eventpipe,
											apb->int_in[0],
											(BYTE *)apb->addr_in[0]);
}

/*form_error 0x0035*/

/****************************************************************************
 *  Form_do_error                                                           *
 *   Display pre-defined error alert box.                                   *
 ****************************************************************************/
WORD              /* Exit button.                                           */
Form_do_error(    /*                                                        */
WORD   apid,      /* Application id number.                                 */
WORD   vid,       /* VDI workstation id.                                    */
WORD   eventpipe, /* Event message pipe.                                    */
WORD   error)     /* Error code.                                            */
/****************************************************************************/
{
	BYTE	s[100];
	BYTE	*sp = s;
	
	switch(error)
	{
		case	FERR_FILENOTFOUND:
		case	FERR_PATHNOTFOUND:
		case	FERR_NOFILES:
			sp = globals.fr_string[ERROR_2_3_18];
			break;
		case	FERR_NOHANDLES:
			sp = globals.fr_string[ERROR_4];
			break;
		case	FERR_ACCESSDENIED:
			sp = globals.fr_string[ERROR_5];
			break;
		case	FERR_LOWMEM:
		case	FERR_BADENVIRON:
		case	FERR_BADFORMAT:
			sp = globals.fr_string[ERROR_8_10_11];
			break;
		case	FERR_BADDRIVE:
			sp = globals.fr_string[ERROR_15];
			break;
		case	FERR_DELETEDIR:
			sp = globals.fr_string[ERROR_16];
			break;
		default:
			sprintf(s,globals.fr_string[ERROR_GENERAL],error);
	};
	
	return do_form_alert(apid,vid,eventpipe,1,sp);
}

void	Form_error(AES_PB *apb) {
	apb->int_out[0] = Form_do_error(apb->global->apid,
											apb->global->int_info->vid,
											apb->global->int_info->eventpipe,
											apb->int_in[0]);
}

/*form_center 0x0036*/

void	Form_do_center(OBJECT *tree,RECT *clip) {
	tree[0].ob_x = globals.screen.x +
		((globals.screen.width - tree[0].ob_width) >> 1);
	tree[0].ob_y = globals.screen.y +
		((globals.screen.height - tree[0].ob_height) >> 1);
	
	Objc_area_needed(tree,0,clip);
}

void	Form_center(AES_PB *apb) {
	Form_do_center((OBJECT *)apb->addr_in[0],(RECT *)&apb->int_out[1]);
};

/****************************************************************************
 *  Form_do_keybd                                                           *
 *   Process key input to form.                                             *
 ****************************************************************************/
WORD              /* 0 if an exit object was selected, or 1.                */
Form_do_keybd(    /*                                                        */
WORD   vid,       /* VDI workstation handle.                                */
OBJECT *tree,     /* Resource tree of form.                                 */
WORD   obj,       /* Object with edit focus (0 => none).                    */
WORD   kc,        /* Keypress to process.                                   */
WORD   *newobj,   /* New object with edit focus.                            */
WORD   *keyout)   /* Keypress that couldn't be processed.                   */
/****************************************************************************/
{
	switch(kc) {
	case 0x0f09: /* tab */
	case 0x5000: /* arrow down */
		{
			WORD i = obj + 1;
			
			*newobj = obj;
			*keyout = 0;
			
			if((obj != 0) && !(tree[obj].ob_flags & LASTOB)) {
				while(1) {
					if(tree[i].ob_flags & EDITABLE) {
						*newobj = i;

						break;
					};
	
					if(tree[i].ob_flags & LASTOB) {
						break;
					};
				
					i++;
				};
			};
		};
		return 1;
	case 0x4800: /* arrow up */
		{
			WORD i = obj - 1;
			
			*newobj = obj;
			*keyout = 0;
			
			while(i >= 0) {
				if(tree[i].ob_flags & EDITABLE) {
					*newobj = i;

					break;
				};

				i--;
			};
		};
		return 1;
	case 0x1c0d: /* return */
		{
			WORD i = 0;
			
			*newobj = -1;
			
			while(1) {
				if(tree[i].ob_flags & DEFAULT) {
					RECT clip;
					
					*newobj = i;
					*keyout = 0;
					
					Objc_calc_clip(tree,i,&clip);
					Objc_do_change(vid,tree,i,&clip,SELECTED,REDRAW);
					
					return 0;
				};
	
				if(tree[i].ob_flags & LASTOB) {
					break;
				};
				
				i++;
			};
		};
		break;
	};	
	
	*newobj = obj;
	*keyout = kc;

	return 1;
}

/****************************************************************************
 *  Form_keybd                                                              *
 *   0x0037 form_keybd()                                                    *
 ****************************************************************************/
void              /*                                                        */
Form_keybd(       /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = Form_do_keybd(apb->global->int_info->vid,
										(OBJECT *)apb->addr_in[0],apb->int_in[0],
										apb->int_in[1],&apb->int_out[1],
										&apb->int_out[2]);
}


/*form_button 0x0038*/

/****************************************************************************
 * Form_do_button                                                           *
 *  Implementation of form_button.                                          *
 ****************************************************************************/
WORD            /* 0 if exit object was found or 1.                         */
Form_do_button( /*                                                          */
WORD apid,      /* Application id.                                          */
WORD vid,       /* VDI workstation id.                                      */
WORD eventpipe, /* Event message pipe.                                      */
OBJECT *tree,   /* Resource tree.                                           */
WORD obj,       /* Object to try the clicks on.                             */
WORD clicks,    /* Number of clicks.                                        */
WORD *newobj)   /* Next object to gain edit focus, or 0.                    */
/****************************************************************************/
{
	WORD	dummy;

	*newobj = 0;

	if(tree[obj].ob_flags & (EXIT | SELECTABLE)) {
		RECT clip;
		
		if(tree[obj].ob_flags & RBUTTON) {
			if(!(tree[obj].ob_state & SELECTED)) {
				WORD i = obj;
				
				while(1) {
					if(tree[tree[i].ob_next].ob_tail == i) {
						i = tree[tree[i].ob_next].ob_head;
					}
					else {
						i = tree[i].ob_next;
					};
					
					if(i == obj) {
						break;
					};
					
					if(tree[i].ob_state & SELECTED) {
						Objc_calc_clip(tree,i,&clip);
						Objc_do_change(vid,tree,i,&clip,
							tree[i].ob_state &= ~SELECTED,REDRAW);
					};					
				};				

				Objc_calc_clip(tree,obj,&clip);
				Objc_do_change(vid,tree,obj,&clip,
					tree[i].ob_state |= SELECTED,REDRAW);
			};
			
			Evnt_do_button(apid,eventpipe,0,LEFT_BUTTON,0,&dummy,&dummy,&dummy,&dummy);
			
			if(tree[obj].ob_flags & (TOUCHEXIT | EXIT)) {
				*newobj = obj;
				
				if((tree[obj].ob_flags & TOUCHEXIT) && (clicks >= 2)) {
					*newobj |= 0x8000;
				};

				return 0;
			}
			else {
				return 1;
			};
		}
		else {
			WORD instate = tree[obj].ob_state;
			WORD outstate = instate;

			if(tree[obj].ob_flags & SELECTABLE) {
				instate ^= SELECTED;
			};
	
			if((Graf_do_watchbox(apid,vid,eventpipe,tree,obj,instate,outstate) == 1) &&
					(tree[obj].ob_flags & (EXIT | TOUCHEXIT))) {
	
				*newobj = obj;
	
				if((tree[obj].ob_flags & TOUCHEXIT) && (clicks >= 2)) {
					*newobj |= 0x8000;
				};
				
				return 0;
			}
			else {
				return 1;
			};
		};
	}
	else if(tree[obj].ob_flags & TOUCHEXIT) {
		*newobj = obj;
		
		if(clicks >= 2) {
			*newobj |= 0x8000;
		};
	
		return 0;
	}
	else if(tree[obj].ob_flags & EDITABLE) {
		*newobj = obj;
		
		return 1;
	};
		
	return 1;
}

void	Form_button(AES_PB *apb) {
	apb->int_out[0] = Form_do_button(apb->global->apid,
												apb->global->int_info->vid,
												apb->global->int_info->eventpipe,
												(OBJECT *)apb->addr_in[0],
												apb->int_in[0],apb->int_in[1],&apb->int_out[1]);
}
