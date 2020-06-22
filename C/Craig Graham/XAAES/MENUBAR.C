/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <STRING.H>
#include <VDI.H>
#include <memory.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "RECTLIST.H"
#include "OBJECTS.H"
#include "OBJCWIDG.H"
#include "SYSTEM.H"
#include "C_WINDOW.H"
#include "RESOURCE.H"
#include "RECTLIST.H"

/*
	This file provides the interface between XaAES's (somewhat strange) menu
	system and the standard GEM calls. Most GEM apps will only care about the
	menu they install onto the desktop, although XaAES can allow seperate menu's
	for each window.....
*/

/*
	Install a menu bar onto the desktop window
*/
unsigned long XA_menu_bar(short clnt_pid, AESPB *pb)
{
	XA_RECT_LIST *drl;
	XA_RECT_LIST *rl;
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	
	pb->intout[0]=1;
	
	switch(pb->intin[0])
	{
		case MENU_INSTALL:
			fix_menu((OBJECT*)pb->addrin[0]);	/* do a special fix on menu the menu  */
			clients[clnt_pid].std_menu=(OBJECT*)pb->addrin[0];
			menu_bar->tree=(OBJECT*)(pb->addrin[0]);
			menu_bar->owner=clnt_pid;

#if JOHAN_RECTANGLES
			if (!(rl = root_window->rl_full))
				rl = root_window->rl_full = generate_rect_list(root_window);
#else
			rl=generate_rect_list(root_window);
#endif

			v_hide_c(V_handle);
			while(rl)
			{
				drl=rl;
				set_clip(rl->x, rl->y, rl->w, rl->h);
				display_menu_widget(root_window, &root_window->widgets[XAW_MENU]);
				rl=rl->next;
#if JOHAN_RECTANGLES
#else
				free(drl);
#endif
			}
			clear_clip();
			v_show_c(V_handle,1);
			
			break;
		case MENU_REMOVE:
			clients[clnt_pid].std_menu=ResourceTree(system_resources,SYSTEM_MENU);
			menu_bar->owner=AESpid;
			menu_bar->tree=clients[clnt_pid].std_menu;
		
#if JOHAN_RECTANGLES
			if (!(rl = root_window->rl_full))
				rl = root_window->rl_full = generate_rect_list(root_window);
#else
			rl=generate_rect_list(root_window);
#endif		
			v_hide_c(V_handle);
			while(rl)
			{
				drl=rl;
				set_clip(rl->x, rl->y, rl->w, rl->h);
				display_menu_widget(root_window, &root_window->widgets[XAW_MENU]);
				rl=rl->next;
#if JOHAN_RECTANGLES
#else
				free(drl);
#endif
			}
			clear_clip();
			v_show_c(V_handle,1);
			break;
			
		case MENU_INQUIRE:
			pb->intout[0]=menu_bar->owner;
			break;
	}
	
	return XAC_DONE;
}

/*
	Highlight / un-highlight a menu title
	-actually, this isn't really needed as XaAES cancels the highlight itself....
	...it's only here for compatibility. 
*/
unsigned long XA_menu_tnormal(short clnt_pid, AESPB *pb)
{
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	OBJECT *tree=(OBJECT*)pb->addrin[0];
	
	if (pb->intin[1])			/* Change the highlight / normal status of a menu title */
		tree[pb->intin[0]].ob_state&=~SELECTED;
	else
		tree[pb->intin[0]].ob_state|=SELECTED;
	
/* If we just changed the main root window's menu, better redraw it */
	if ((tree==menu_bar->tree)&&(tree[pb->intin[0]].ob_type==G_TITLE))
	{
#if JOHAN_RECTANGLES
		XA_RECT_LIST *rl, *drl;
#else
		XA_RECT_LIST *drl;
		XA_RECT_LIST *rl=generate_rect_list(root_window);
#endif

#if JOHAN_RECTANGLES
		if (!(rl = root_window->rl_full))
			rl = root_window->rl_full = generate_rect_list(root_window);
#endif

		v_hide_c(V_handle);
		while(rl)
		{
			drl=rl;
			set_clip(rl->x, rl->y, rl->w, rl->h);
			display_menu_widget(root_window, &root_window->widgets[XAW_MENU]);
			rl=rl->next;
#if JOHAN_RECTANGLES
#else
			free(drl);
#endif
		}
		clear_clip();
		v_show_c(V_handle,1);
	}
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}

/*
	Enable/Disable a menu item
*/
unsigned long XA_menu_ienable(short clnt_pid, AESPB *pb)
{
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	OBJECT *tree=(OBJECT*)pb->addrin[0];
	
	if (pb->intin[1])			/* Change the disabled status of a menu item */
		tree[pb->intin[0]].ob_state&=~DISABLED;
	else
		tree[pb->intin[0]].ob_state|=DISABLED;
	
/* If we just changed the main root window's menu, better redraw it */
	if ((tree==menu_bar->tree)&&(tree[pb->intin[0]].ob_type==G_TITLE))
	{
#if JOHAN_RECTANGLES
		XA_RECT_LIST *rl, *drl;
#else
		XA_RECT_LIST *drl;
		XA_RECT_LIST *rl=generate_rect_list(root_window);
#endif

#if JOHAN_RECTANGLES
		if (!(rl = root_window->rl_full))
			rl = root_window->rl_full = generate_rect_list(root_window);
#endif

		v_hide_c(V_handle);
		while(rl)
		{
			drl=rl;
			set_clip(rl->x, rl->y, rl->w, rl->h);
			display_menu_widget(root_window, &root_window->widgets[XAW_MENU]);
			rl=rl->next;
#if JOHAN_RECTANGLES
#else
			free(drl);
#endif
		}
		clear_clip();
		v_show_c(V_handle,1);
	}
	pb->intout[0]=1;

	return XAC_DONE;
}

/*
	Check / un-check a menu item
*/
unsigned long XA_menu_icheck(short clnt_pid, AESPB *pb)
{
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	OBJECT *tree=(OBJECT*)pb->addrin[0];
	
	if (pb->intin[1])			/* Change the disabled status of a menu item */
		tree[pb->intin[0]].ob_state|=CHECKED;
	else
		tree[pb->intin[0]].ob_state&=~CHECKED;
	
/* If we just changed the main root window's menu, better redraw it */
	if ((tree==menu_bar->tree)&&(tree[pb->intin[0]].ob_type==G_TITLE))
	{
#if JOHAN_RECTANGLES
		XA_RECT_LIST *rl, *drl;
#else
		XA_RECT_LIST *drl;
		XA_RECT_LIST *rl=generate_rect_list(root_window);
#endif

#if JOHAN_RECTANGLES
		if (!(rl = root_window->rl_full))
			rl = root_window->rl_full = generate_rect_list(root_window);
#endif		
		v_hide_c(V_handle);
		while(rl)
		{
			drl=rl;
			set_clip(rl->x, rl->y, rl->w, rl->h);
			display_menu_widget(root_window, &root_window->widgets[XAW_MENU]);
			rl=rl->next;
#if JOHAN_RECTANGLES
#else
			free(drl);
#endif
		}
		clear_clip();
		v_show_c(V_handle,1);
	}
	
	pb->intout[0]=1;

	return XAC_DONE;
}

/*
	Change a menu item's text
*/
unsigned long XA_menu_text(short clnt_pid, AESPB *pb)
{
	XA_WIDGET_TREE *menu_bar=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	OBJECT *tree=(OBJECT*)pb->addrin[0];
	char *text=(char*)pb->addrin[1];
	
	strcpy((char*)tree[pb->intin[0]].ob_spec,text);
	
/* If we just changed the main root window's menu, better redraw it */
	if ((tree==menu_bar->tree)&&(tree[pb->intin[0]].ob_type==G_TITLE))
	{
#if JOHAN_RECTANGLES
		XA_RECT_LIST *rl, *drl;
#else
		XA_RECT_LIST *drl;
		XA_RECT_LIST *rl=generate_rect_list(root_window);
#endif

#if JOHAN_RECTANGLES
		if (!(rl = root_window->rl_full))
			rl = root_window->rl_full = generate_rect_list(root_window);
#endif

		v_hide_c(V_handle);
		while(rl)
		{
			drl=rl;
			set_clip(rl->x, rl->y, rl->w, rl->h);
			display_menu_widget(root_window, &root_window->widgets[XAW_MENU]);
			rl=rl->next;
#if JOHAN_RECTANGLES
#else
			free(drl);
#endif
		}
		clear_clip();
		v_show_c(V_handle,1);
	}
	
	pb->intout[0]=1;

	return XAC_DONE;
}

/*
	Register an apps 'pretty' & 'official' names.
*/
unsigned long XA_menu_register(short clnt_pid, AESPB *pb)
{
	short f;
	
	if (pb->intin[0]!=-1)
	{
		strcpy(clients[clnt_pid].name,(char*)pb->addrin[0]);
	}else{
		strncpy(clients[clnt_pid].proc_name,(char*)pb->addrin[0],8);
		for(f=strlen(clients[clnt_pid].proc_name); f<8; f++)
			clients[clnt_pid].proc_name[f]=' ';
		clients[clnt_pid].proc_name[8]='\0';
	}
	
	return XAC_DONE;
}
