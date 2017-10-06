/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <mintbind.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "rectlist.h"
#include "objects.h"
#include RSCHNAME
#include "c_window.h"
#include "menuwidg.h"
#include "widgets.h"

#include "app_man.h"

#if GENERATE_DIAGS
global
bool check_tree(XA_CLIENT *client, OBJECT *tree, short item)
{
	long ltree = (long)tree;
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	RSHDR *rs;

	if (tree == menu_bar->tree and menu_bar->lastob)		/* set by AES menu_bar() */
	{
		if (item < 0 or item > menu_bar->lastob)
		{
			DIAGS(("***** MENU ITEM > LASTOB %d ***** tree %lx, item %d\n",menu_bar->lastob,tree,item));
			return false;				/* definetely wrong */
		}
	}
	else if (item < 0)
	{
		DIAGS(("***** ITEM ERROR ***** tree %lx, item %d\n",tree,item));
		return false;
	}
	else if (ltree < 0 or (ltree >= 0x400000 and ltree < 0x1000000) or ltree > 0x1400000)
	{
		DIAGS(("***** TREE ERROR ***** tree %lx, item %d\n",tree,item));
		return false;
	}
	else if (client)
	{
		int i;				/* Is it a tree of the resource? */
		OBJECT **tr, *ob;
		rs = client->std_resource;
		if (rs)
		{
			(long)tr = (long)rs + rs->rsh_trindex;
			for (i = 0; i < rs->rsh_ntree; i++)
			{
				ob = tr[i];
				if (ob == tree)
				{
					int j = 0;
					while ( (ob->ob_flags&LASTOB) == 0) ob++, j++;
					if (item > j)
					{
						DIAGS(("***** TREE ITEM > LASTOB %d ***** tree %lx, item %d\n",j,tree,item));
						return false;
					}	
				}
			}
		}
	}
/*	DIAGS(("check_tree ok: %lx, %d\n", tree, item));
*/	return true;					/* OK, or (foreign tree and item >= 0, have to accept) */
}
#else
#define check_tree(a,b,c) 1
#endif

/*
 *	This file provides the interface between XaAES's (somewhat strange) menu
 *	system and the standard GEM calls. Most GEM apps will only care about the
 *	menu they install onto the desktop, although XaAES can allow seperate menus
 *	for each window...
 */

/*
 * Install a menu bar onto the desktop window
 */
AES_function XA_menu_bar	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *menu_bar;
	OBJECT *mnu = pb->addrin[0];
	XA_WINDOW *wl;
	short i, owner_top_wm;

	CONTROL(1,1,1)

	if unlocked(winlist)
		Sema_Up(WIN_LIST_SEMA);

	menu_bar = root_window->widgets[XAW_MENU].stuff;

	pb->intout[0] = 0;

	DIAG((D.menu,-1,"menu_bar for %s(%d), %lx\n", client->name, client->pid, mnu));
	
	switch(pb->intin[0])
	{
	case MENU_INSTALL:
		DIAG((D.menu,-1,"MENU_INSTALL\n"));

		if (mnu)
		{
			fix_menu(mnu,true);		/* Do a special fix on the menu  */
			DIAG((D.menu,-1,"fixed menu\n"));

			mnu->r.w = mnu[mnu->ob_tail].r.w = mnu[mnu->ob_head].r.w = screen.r.w;
	
#if GENERATE_DIAGS
			i = 0;
			while ((mnu[i].ob_flags & LASTOB) == 0) i++;
			menu_bar->lastob = i;
#endif
/* HR: std_menu is now a complete widget_tree :-) */
			client->std_menu.tree = mnu;
			client->std_menu.pid = client->pid;
			swap_menu(lock|winlist, client->pid, false);			/* HR 060801 */
			pb->intout[0] = 1;
			DIAG((D.menu,-1,"done display, lastob = %d\n",client->std_menu.lastob));
		}
		break;

	case MENU_REMOVE:
		DIAG((D.menu,-1,"MENU_REMOVE\n"));
		remove_attachments(lock|winlist, client, client->std_menu.tree);	/* HR */
		client->std_menu.tree = nil;

		owner_top_wm = C.AESpid;
		wl = window_list;
		while (wl)
		{
			if ((wl->pid != client->pid) and wl->owner->std_menu.tree)
			{
				owner_top_wm = wl->pid;
				break;
			}
			wl = wl->next;
		}
		swap_menu(lock|winlist, owner_top_wm, false);			/* HR 060801 */
		pb->intout[0] = 1;
		break;
		
	case MENU_INQUIRE:
		DIAG((D.menu,-1,"MENU_INQUIRE := %d\n",menu_bar->pid));
		pb->intout[0] = menu_bar->pid;
		break;
	}

	if unlocked(winlist)
		Sema_Dn(WIN_LIST_SEMA);

	DIAG((D.menu,-1,"done menu_bar()\n"));

	return XAC_DONE;
}

/*
 * Highlight / un-highlight a menu title
 * - Actually, this isn't really needed as XaAES cancels the highlight itself...
 * ...it's only here for compatibility. 
 */
AES_function XA_menu_tnormal	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	OBJECT *tree = (OBJECT *)pb->addrin[0];
	
	CONTROL(2,1,1)

	if (pb->intin[1])			/* Change the highlight / normal status of a menu title */
		tree[pb->intin[0]].ob_state &= ~SELECTED;
	else
		tree[pb->intin[0]].ob_state |= SELECTED;

/* If we just changed the main root window's menu, better redraw it */
	if ((tree == menu_bar->tree) and (tree[pb->intin[0]].ob_type == G_TITLE))
		redraw_menu(lock);

	pb->intout[0] = 1;

	return XAC_DONE;
}

/*
 * Enable/Disable a menu item
 */
AES_function XA_menu_ienable	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	OBJECT *tree = (OBJECT *)pb->addrin[0];
	
	CONTROL(2,1,1)

	if (pb->intin[1])			/* Change the disabled status of a menu item */
		tree[pb->intin[0]].ob_state &= ~DISABLED;
	else
		tree[pb->intin[0]].ob_state |= DISABLED;

/* If we just changed the main root window's menu, better redraw it */
	if ((tree == menu_bar->tree) and (tree[pb->intin[0]].ob_type == G_TITLE))
		redraw_menu(lock);

	pb->intout[0] = 1;

	return XAC_DONE;
}

/*
 * Check / un-check a menu item
 */
AES_function XA_menu_icheck	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	OBJECT *tree = (OBJECT *)pb->addrin[0];
	
	CONTROL(2,1,1)

	if (pb->intin[1])			/* Change the disabled status of a menu item */
		tree[pb->intin[0]].ob_state |= CHECKED;
	else
		tree[pb->intin[0]].ob_state &= ~CHECKED;

/* If we just changed the main root window's menu, better redraw it */
	if ((tree == menu_bar->tree) and (tree[pb->intin[0]].ob_type == G_TITLE))
		redraw_menu(lock);
	
	pb->intout[0] = 1;

	return XAC_DONE;
}

/*
 *	Change a menu item's text
 */
AES_function XA_menu_text		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	char *text = (char *)pb->addrin[1];

	XA_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
	OBJECT *tree = (OBJECT *)pb->addrin[0];
	
	CONTROL(1,1,2)

	strcpy(get_ob_spec(&tree[pb->intin[0]])->string, text);

/* If we just changed the main root window's menu, better redraw it */
	if ((tree == menu_bar->tree) and (tree[pb->intin[0]].ob_type == G_TITLE))
		redraw_menu(lock);
	
	pb->intout[0] = 1;

	return XAC_DONE;
}

/*
 * Register an apps 'pretty' & 'official' names.
 */
AES_function XA_menu_register		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	short f; char *n = pb->addrin[0];
	
	CONTROL(1,1,1)

	if (n)  /* HR */
	{
		pb->intout[0] = client->pid;
		if (pb->intin[0] != -1)
		{
			short l = strlen(n);
			if (l >= NICE_NAME)			/* HR: space available */
				strncpy(client->name, n, NICE_NAME-1),
				*(client->name + NICE_NAME - 1) = 0;
			else
				strcpy(client->name, n);
DIAGS(("menu_register 'nice' for %d: '%s'\n", client->pid, client->name));
		} else
		{
			strncpy(client->proc_name, n,8);
			client->proc_name[8] = '\0';
			for (f = strlen(client->proc_name); f < 8; f++)
				client->proc_name[f] = ' ';
			strnupr(client->proc_name, 8);		/* HR */
DIAGS(("menu_register 'proc' for %d: '%s'\n", client->pid, client->proc_name));
		}
	}
	else
		pb->intout[0] = -1;
	return XAC_DONE;
}

/*
 * Display and handle a popup menu.  HR: march 2000
 */

AES_function XA_menu_popup		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(2,1,2)

	pb->intout[0] = 0;

	if (pb->addrin[0] and pb->addrin[1])
	{
		Tab *tab = C.active_menu;

		C.menu_base = tab;

		if (tab->ty == NO_TASK)		/* else already locked */
		{
			tab->pb = pb;
			tab->pid = client->pid;
			tab->locker = tab->pid;
			tab->client = client;
			tab->lock = lock;
			do_popup_menu (tab);
	
			if (tab->reply)
				return XAC_BLOCK;
		}
	}

 	return XAC_DONE;
}

/*
 * Attach a submenu to a menu item.  HR: march 2000
 */
AES_function XA_menu_attach		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(2,1,2)

DIAG((D.menu,client->pid,"menu_attach\n"));
	if (pb->addrin[0] and pb->addrin[1])
		if (pb->intin[0] == ME_ATTACH)
			pb->intout[0] = attach_menu(
								lock,
								client,
								pb->addrin[0],
								pb->intin[1],
								pb->addrin[1]);
		else
			pb->intout[0] = detach_menu(
								lock,
								client,
								pb->addrin[0],
								pb->intin[1]);
	else
		pb->intout[0] = 1;
 	return XAC_DONE;
}

/*
 * Align a submenu.  HR: march 2000
 */
AES_function XA_menu_istart		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,1,1)

DIAG((D.menu,client->pid,"menu_istart\n"));
	pb->intout[0] = 0;
 	return XAC_DONE;
}

/*
 * Influence behaviour.  HR: march 2000
 */
AES_function XA_menu_settings		/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	CONTROL(1,1,1)

DIAG((D.menu,-1,"menu_settings %d\n", pb->intin[0]));
	pb->intout[0] = 1;			/* accepted, no implementation planned */
	if (pb->intin[0] == 0)
	{
		MN_SET *mn = pb->addrin[0];
		mn->display = 200;
		mn->drag = 10000;
		mn->delay = 250;
		mn->speed = 0;
		mn->height = (screen.r.h/screen.c_max_h) - 4;
	}
	return XAC_DONE;
}
