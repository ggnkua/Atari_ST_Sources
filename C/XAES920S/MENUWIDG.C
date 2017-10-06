/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <stdlib.h>
#include <string.h>

#include "xa_types.h"
#include "xa_globl.h"

#include "handler.h"
#include "menuwidg.h"
#include "c_window.h"
#include "rectlist.h"
#include RSCHNAME
#include "objects.h"
#include "widgets.h"
#include "taskman.h"
#include "app_man.h"
#include "xa_rsrc.h"

#if 0
#include "obsolete/dispmenu.h"
#endif

static MENU desk_popup;
bool menu_title(LOCK lock, struct xa_window *wind, struct xa_widget *widg, short locker);

static
bool barred(Tab *tab)
{
	return tab->ty == MENU_BAR or tab->ty == ROOT_MENU;
}

static
unsigned long menu_colors(void)
{
	return
	     (screen.dial_colours.fg_col << 12)		/* border */
	   | (screen.dial_colours.fg_col << 8)		/* text */
	   |  screen.dial_colours.bg_col			/* inside */
	   | (7 << 4)								/* solid fill */
	   | (1 << 7);								/* transparent text */
}

static
void menu_spec(OBJECT *root, short item)
{
	if (is_spec(root,item))
	{
		set_ob_spec(root,item,0xff0000L | menu_colors());
		root[item].ob_state |= SHADOWED;
	}
}

static
void change_title(Tab *tab, short state)
{
	MENU_TASK *k = &tab->task_data.menu;
	OBJECT *ob = k->root;
	short t = k->clicked_title;
	if (state)
		state = ob[t].ob_state | SELECTED;
	else
		state = ob[t].ob_state & ~SELECTED;
	ob->r.x = k->rdx;
	ob->r.y = k->rdy;
	change_object(	tab->lock,
					tab->widg->stuff,			/* HR 090501 menu in user window. */
					ob, t, nil, state, true, true);
}

static
void change_entry(Tab *tab, short state)
{
	MENU_TASK *k = &tab->task_data.menu;
	OBJECT *ob = k->root;
	short t = k->point_at_menu;
	if (state)
		state = ob[t].ob_state | SELECTED;
	else
		state = ob[t].ob_state & ~SELECTED;
	ob->r.x = k->rdx;
	ob->r.y = k->rdy;
	change_object(	tab->lock,
					tab->wind ? &tab->wind->tree_info : nil,
					ob, t, nil, state, true, true);
}

static
short is_attach(XA_CLIENT *client, OBJECT *menu, short item)
{
	XA_MENU_ATTACHMENT *at = client->attach;
	OBJECT *attach_to = menu + item;

/*  DIAG((D.menu,client->pid, "is_attach: at=%lx,flags=%x,type=%x, spec=%lx, mx=%lx\n",
	       at,attach_to->ob_flags,attach_to->ob_type,attach_to->ob_spec.attachment,at + ATTACH_MAX));
*/
	return (    at != nil
			and (attach_to->ob_flags&INDIRECT) != 0
			and (attach_to->ob_type&0xff) == G_STRING
			and attach_to->ob_spec.attachment >= at
			and attach_to->ob_spec.attachment < at + ATTACH_MAX
			);
}

/*
 * Attach a submenu to a menu entry
 */
global
short attach_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, short item, MENU *mn)
{
	short ret = 0;
	XA_MENU_ATTACHMENT *at = client->attach;
	OBJECT *attach_to;

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

	attach_to = tree + item;

DIAG((D.menu,-1,"attach_menu for %s %lx + %d to %lx + %d\n", client->name, mn->tree, mn->menu, tree, item));
/* You can only attach submenu's to normal menu entries */
	if (   tree
		and mn
		and (attach_to->ob_flags&INDIRECT) == 0
		and (attach_to->ob_type&0xff) == G_STRING
		)
	{				/* Allocate a table for at least ATTACH_MAX attachments */
		if (!at)
		{
			at = xcalloc(ATTACH_MAX,sizeof(XA_MENU_ATTACHMENT),102);
			if (!at)
			{
				if unlocked(clients)
					Sema_Dn(CLIENTS_SEMA);
				return 0;
			}
		}

		client->attach = at;

		while(at)			/* find a free place in the table */
			if (at->text)
				at++;
			else
				break;

/* A menu is attached by replacing ob_spec (the text string)
   to point to a structure in the above allocated table.
   The text string pointer is moved to the very first location of that
   structure. The remainder being additional information.
 */
		if (at < at + ATTACH_MAX)		/* room left in table ? */
		{
			/* OK now we can attach the menu */
			menu_spec(mn->tree, mn->menu);
			at->text = attach_to->ob_spec.string;		/* displace string */
			attach_to->ob_flags |= INDIRECT|SUBMENU;
			attach_to->ob_spec.attachment = at;
			at->item = mn->menu;		/* This is the submenu */
			at->tree = mn->tree;
			at->text[strlen(at->text)-1] = mn == &desk_popup ? '\2' : '>';
			ret = 1;
		}
	}
	else
	{
		DIAG((D.menu,-1,"attach to already indirect, or no G_STRING\n"));
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	return ret;
}

global
short detach_menu(LOCK lock, XA_CLIENT *client, OBJECT *tree, short item)
{
	short ret = 0;
	OBJECT *attach_to = tree + item;

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

	if (is_attach(client,tree,item))
	{
		char *at;
		XA_MENU_ATTACHMENT *xt = attach_to->ob_spec.attachment;
DIAG((D.menu,-1,"detach_menu %lx + %d for %s %lx + %d\n", xt->tree, xt->item, client->name, tree, item));
		attach_to->ob_flags&=~(INDIRECT|SUBMENU);
		attach_to->ob_spec.string = xt->text;
		xt->text = nil;
		at = attach_to->ob_spec.string;
		at[strlen(at)-1] = ' ';
		ret = 1;
	}

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	return ret;
}

global
void remove_attachments(LOCK lock, XA_CLIENT *client, OBJECT *menu)
{
	if (menu)
	{
		short f = 0;
DIAG((D.menu, -1, "remove_attachments\n"));
		do
			detach_menu(lock, client, menu, f);
		while (!(menu[f++].ob_flags & LASTOB));	
	}
}

/*
 *	Really should get the multi-thread support in here...
 *	doesn't work at the moment though...
 *
 *  HR: well, some kind of multithreading is now implemented;
 *      some cooperative kind within the same process.
 */

static
Tab *nest_menutask(Tab *tab)
{
	MENU_TASK *b, *k;
	/* Check the nest maximimum in the caller!!! */
	C.menu_base = &C.active_menu[++C.menu_nest];
	memset(C.menu_base,0,sizeof(Tab));
	C.menu_base->nest = tab;
	b = &C.menu_base->task_data.menu,
	k = &tab->task_data.menu;
	C.menu_base->ty = b->ty = POP_UP;
	b->bar = k->bar;
	C.menu_base->ty = tab->ty;
	C.menu_base->pid = tab->pid;
	C.menu_base->pb = tab->pb;
	C.menu_base->lock = tab->lock;
	b->clicked_title = k->clicked_title;
	return C.menu_base;
}


#define MAX_MREG 32

static
OBJECT menu_reg[MAX_MREG];
static
char menu_regt[MAX_MREG][130];
static
short menu_regpid[MAX_MREG];

static OBJECT
drop_box =
{
  -1, 1, 2, G_BOX,   /* Object 0  */
  NONE, SHADOWED, 0x00FF1100L,
  0, 0, 12, 2,
},
drop_choice =		/* Object 1 to n */
{
  0,-1,-1, G_STRING,
  NONE, NORMAL, (long)"-",
  0, 1, 12, 1
};

static
OBJECT *built_desk_popup(LOCK lock, short x, short y)
{
	short n = 0, i = 0,
	    xw = 0, obs, split = 0;
	OBJECT *ob;
	XA_CLIENT *client;

	/* go throug all the clients, store pid and name */
	/* count in n */

	if unlocked(clients)
		Sema_Up(CLIENTS_SEMA);

	client = S.client_list;
	while(client)
	{
		if (  (   client->client_end
			   and client->type == XA_CT_ACC
			   )
			or client->pid == C.AESpid
		   )
		{
			menu_regpid[n] = client->pid;
			sdisplay(menu_regt[n],"  %d->%d %s",
					client->parent,
					menu_regpid[n],
					*client->name 
						? client->name + 2
						: client->proc_name);
			n++;
		}
		client = client->next;
	}

	menu_regpid[n] = -1;
	strcpy(menu_regt[n],"-");
	split = n++;

	client = S.client_list;
	while(client)
	{
		if (    client->client_end
			and client->type != XA_CT_ACC)
		{
			menu_regpid[n] = Client2Pid(client);
			sdisplay(menu_regt[n],"  %d->%d %s",
					client->parent,
					menu_regpid[n],
					*client->name 
						? client->name + 2		/* You can always do a menu_register in multitasking AES's  :-) */
						: client->proc_name);
			n++;
		}
		client = client->next;
	}

	if (split == n-1)		/* dont want to see split when last */
		n--;

	if unlocked(clients)
		Sema_Dn(CLIENTS_SEMA);

	obs = n+1;
	ob = menu_reg;

	ob[0] = drop_box;
	ob[0].ob_tail = obs-1;
	ob[0].r.h = obs-1;
	
	for (i=0; i<n; i++)		/* fix the tree */
	{
		int m;
		int j = i+(obs-n);
		ob[j] = drop_choice;
		if (i == split)
			ob[j].ob_state = DISABLED;
		ob[j].ob_spec.string = menu_regt[i];
		if (C.focus and menu_regpid[i] == C.focus->pid)
			ob[j].ob_state |= CHECKED;
		else
			ob[j].ob_state &= ~CHECKED;
		m = strlen(ob[j].ob_spec.string);
		if (m > xw)
			xw = m;
		ob[j].ob_next = j+1;
		ob[j].r.y = i;
	}
	ob[obs-1].ob_flags|=LASTOB;
	ob[obs-1].ob_next = 0;

	xw++;
	for (i=0; i<obs; i++)
		ob[i].r.w = xw;

	if (split < n)
	{
		memset(menu_regt[split],'-',xw);
		menu_regt[split][xw]=0;
	}

	for (i=0; i<obs; i++)
		obfix(ob,i);

	ob[0].r.x = x;
	ob[0].r.y = y;

	menu_spec(ob, 0);

	return menu_reg;
}

WidgetBehaviour click_menu_widget;

#if 1		/* HR: menu handling rewritten using mouse events and
       			task management. Also needed for sub menu's !!! */

static
short desk_menu(Tab *tab)
{
	MENU_TASK *k = &tab->task_data.menu;
	return    tab->ty == ROOT_MENU
	       and tab->nest == nil
	       and k->clicked_title == k->root[k->titles].ob_head;
}

static
Tab *menu_pop(Tab *tab)
{
	MENU_TASK *b,*k = &tab->task_data.menu;

	if (barred(tab))
	{
		if (!tab->nest)
		{
			if (k->clicked_title > 0)
				change_title(tab, 0);
			k->root[k->pop_item].ob_flags |= HIDETREE;
		}
		if (desk_menu(tab))
			detach_menu(tab->lock,C.Aes, k->root, k->about + 2);		/* remove attached clients popup */
	}
#if POPUP_IN_WINDOW
	if (k->popw)		/* Windowed popup's */
	{	
		close_window(tab->lock, k->popw);
		delete_window(tab->lock, k->popw);
		k->popw = nil;
	} else
#endif
	{
		hidem();
		form_restore(k->border, k->drop, k->Mpreserve);
		showm();
	}

	k->root[k->point_at_menu].ob_state&=~SELECTED;

	if (tab->nest)
	{
		C.menu_base = tab->nest;
		C.menu_nest--;
		b = &C.menu_base->task_data.menu;
		b->x = k->x;		/* pass back current x & y */
		b->y = k->y;
		tab = C.menu_base;
	}
	return tab;
}

static
TASK menu_finish
{
	XA_CLIENT *aes = C.Aes;
	MENU_TASK *k = &tab->task_data.menu;

DIAG((D.menu,-1,"menu_finish %d  dbgmenu_dn\n", tab->dbg2));
	if (barred(tab) and !tab->nest)
		k->root[k->menus].ob_flags |= HIDETREE;
	if (tab->widg)
		tab->widg->start = 0;
	tab->ty = NO_TASK;
	k->stage = NO_MENU;
	free_task(C.menu_base,&C.menu_nest);
	C.menu_base = nil;
	aes->waiting_for = XAWAIT_MENU;		/* ready for next menu choice */
	aes->em.flags = MU_M1|0;
#if POPUP_IN_WINDOW
	if ( ! cfg.menu_windowed )
#endif
	{
DIAG((D.menu,-1,"unlock_screen in menu_finish\n"));
		unlock_screen(tab->locker);
	}
}

static
Tab *collapse(Tab *tab,Tab *upto)
{
	DIAG((D.menu,-1,"collapse tab:%lx, upto:%lx\n", tab, upto));
#if VECTOR_VALIDATION
	if (xa_invalid(1, 1, upto, sizeof(*tab), true))
		return nil;
#endif
	while (tab != upto)
	{
		Tab *x;
#if VECTOR_VALIDATION
	if (xa_invalid(2, 1, tab, sizeof(*tab), true))
		return nil;
#endif
		x = tab;		/* N.B. tab doesnt change when the last drop is popped */
		tab = menu_pop(tab);
		if (!x->nest)
			break;
	}
	return tab;
}

static
TASK popout
{
	Tab *t;
	DIAG((D.menu,-1,"popout %d\n", tab->dbg));
	DIAG((D.menu,-1,"[1]collapse\n"));
	t = collapse(tab,nil);
	IFDIAG(tab->dbg2 = 1;)
	menu_finish(t);
}

static
RECT rc_inside(RECT r, RECT o)
{
	if (r.w < o.w and r.h < o.h)
	{
		if (r.x       < o.x      ) r.x = o.x;
		if (r.y       < o.y      ) r.y = o.y;
		if (r.x + r.w > o.x + o.w) r.x = o.x + o.w - r.w;
		if (r.y + r.h > o.y + o.h) r.y = o.y + o.h - r.h;
	}
	return r;
}

static
TASK display_popup
{
	MENU_TASK *k = &tab->task_data.menu;
	OBJECT *root = k->root;
	short item = k->pop_item;

	root->r.x = k->rdx;
	root->r.y = k->rdy;

	{
#if POPUP_IN_WINDOW
		XA_WINDOW *wind = tab->wind;
		RECT r;
		if (cfg.menu_windowed)
		{
			calc_window(C.AESpid, WC_BORDER, 0, &k->drop, &r);
			wind = create_window(tab->lock, nil, tab->pid, true,
									XaTOP|XaPOP, MG, r,
									nil, nil);
		}
		else
			wind = nil;
	
		if (wind)
		{
			open_window(tab->lock, tab->pid, wind->handle, r);
			k->popw = wind;
			hidem();
			DIAG((D.menu,-1,"wimdow pop draw %lx + %d\n", root, item));
			wr_mode(MD_TRANS);
			draw_object_tree(tab->lock, &wind->tree_info, root, item, 1, true, 4);
			showm();
		} else
#endif
		{
			hidem();
			k->Mpreserve = form_save(k->border, k->drop, nil);
			DIAG((D.menu,-1,"pop draw %lx + %d\n", root, item));
			wr_mode(MD_TRANS);
			draw_object_tree(tab->lock, nil, root, item, 1, true, 5);
			showm();
		}
	}
}

static
void do_popup(Tab *tab, OBJECT *root, short item, TASK *click, short rdx, short rdy)
{
	TASK popup;
	RECT r, rc;
	MENU_TASK *k = &tab->task_data.menu;

DIAG((D.menu, -1, "do_popup\n"));
	menu_spec(root,item);		/* HR 280501 */
	k->stage = IN_DESK;
	k->pop_item = item;
	k->point_at_menu = -1;
	k->entry = click;
	k->border = 0;
	root->r.x = rdx;
	root->r.y = rdy;
	object_area(&r, root, item);
	rc = rc_inside(r, screen.r);			/* HR */

	if (rc.x ne r.x /* or rc.y ne r.y */)
	{
		Tab *tx = tab->nest;
		if (tx and tx->ty eq POP_UP)
		{
			MENU_TASK *kx = &tx->task_data.menu;
			if (m_inside(rc.x, rc.y, &kx->drop))
			{
				rc.x = kx->drop.x - rc.w + 4;
				rc = rc_inside(rc, screen.r);
			}
		}
	}

	k->rdx = rdx - (r.x - rc.x);
	k->rdy = rdy - (r.y - rc.y);
	k->drop = rc;

	k->root = root;
	display_popup(tab);

	if (tab->nest)
	{
		TASK where_are_we;
		Tab *nx = tab->nest;
		MENU_TASK *kx = &nx->task_data.menu;

		kx->root->r.x = kx->rdx;
		kx->root->r.y = kx->rdy;
		object_area(&k->em.m1, kx->root, kx->point_at_menu);
		r = k->em.m1;
		k->em.flags |= MU_M1|1;	   		/* out of entry */
		k->em.t1 = where_are_we;
	}else
	{
		k->em.m1 = k->drop;
		k->em.flags = MU_M1|0;			/* into popup */
		k->em.t1 = popup;
	}
}

static
TASK click_desk_popup
{
	short m, pid;
	MENU_TASK *k = &tab->task_data.menu;
	XA_CLIENT *client;

	k->root->r.x = k->rdx;
	k->root->r.y = k->rdy;
	m = find_object(k->root, k->pop_item, 2, k->x, k->y);
	IFDIAG(tab->dbg = 1;)
	popout(tab);
	pid = menu_regpid[m - 1];
	if (pid > 0)
	{
		client = Pid2Client(pid);
		DIAG((D.menu,-1,"got client pid=%d\n", pid));
		if (pid == C.AESpid)
			app_in_front(tab->lock, pid);
		else
			switch (client->type)
			{
			case XA_CT_ACC:		/* Accessory - send AC_OPEN */
				DIAG((D.menu,-1,"is an accessory\n"));
/* HR: found the reason some acc's wouldnt wake up: msgbuf[4] must receive
*     the meu_register reply, which in our case is the pid.
*/
				send_app_message(tab->lock, tab->wind, pid, AC_OPEN, C.AESpid, 0, pid, 0, 0, 0);
				break;

			case XA_CT_APP:		/* Application, swap topped app */
				DIAG((D.menu,-1,"is a real GEM client\n"));
				app_in_front(tab->lock, pid);
				break;
			}
	}
}

static
short menu_pid(Tab *tab)
{
	if (desk_menu(tab))
		return C.AESpid;
	else if (tab->widg)
	{
		XA_TREE *wt;
		wt = tab->widg->stuff;
		return wt->pid;
	}
	else
		return tab->pid;
}

static
TASK popup		/* This is called by popup menu's as well */
{
	TASK where_are_we, click_popup_entry, click_menu_entry;
	MENU_TASK *k = &tab->task_data.menu;
	short m;

	k->stage = IN_MENU;
	k->root->r.x = k->rdx;
	k->root->r.y = k->rdy;

	m = find_object(k->root, k->pop_item, 2, k->x, k->y);

	if (m < 0)
	{
		k->stage = IN_DESK;		/* There is no specific rectangle to target */
		k->em.flags = MU_MX;		/* report any mouse movement */
		k->em.t1 = where_are_we;	/* This will sort it out. :-) */
	} else if (m == k->pop_item)		/* failsafe  HR 010501: check for pop_item (there could be space between entries) */
	{
		k->em.flags = MU_MX;		/* report any mouse movement */
		k->em.t1 = where_are_we;	/* This will sort it out. :-) */
	} else
	{
		bool dis = k->root[m].ob_state&DISABLED;

		if (m != k->point_at_menu)
		{
			if (    k->point_at_menu > -1
				and !(k->root[k->point_at_menu].ob_state&DISABLED)
				)
				change_entry(tab, 0);
			k->point_at_menu = m;
		}
		if ( ! dis)
			change_entry(tab, 1);

		if (   ! dis
		    and is_attach(Pid2Client(menu_pid(tab)),k->root,k->point_at_menu)
		    and C.menu_nest < CASCADE-1
		   )
		{
			short x,y,rdx,rdy;
			TASK *click =
						desk_menu(tab)
					  ? click_desk_popup
					  : (  tab->ty == POP_UP
					     ? click_popup_entry
					     : click_menu_entry
					    );
			XA_MENU_ATTACHMENT *at = k->root[k->point_at_menu].ob_spec.attachment;
			OBJECT *ob  = at->tree;
			Tab *new;

			object_offset(k->root, k->point_at_menu, &x, &y);

			ob->r.x = 0, ob->r.y = 0;
			object_offset(ob, at->item, &rdx, &rdy);

			rdx = x - rdx;
			rdy = y - rdy;

			if (click == click_desk_popup)
				rdy += screen.c_max_h;		/* HR: 031200 */
			else
				rdx += k->drop.w - 4;

			new = nest_menutask(tab);
			do_popup(new, ob, at->item, click, rdx, rdy);
		} else
		{
			object_area(&k->em.m1, k->root, m);
			k->em.flags = MU_M1|1;			/* out of entry */
			k->em.t1 = where_are_we;
		}
	}
}

static
Tab *any_pop(Tab *tab)
{
	MENU_TASK *k = &tab->task_data.menu;
	do
	{
		RECT r = tab->task_data.menu.drop;
		bool in = m_inside(k->x,k->y,&r);
		if (in)
			break;
		tab = tab->nest;
	}
	while (tab);
	return tab;
}

static
TASK where_are_we
{
	TASK new_title;
	MENU_TASK *k;
	Tab *any;;

	any = any_pop(tab);

	if (any and any == tab)
		popup(tab);
	else
	{
		if (any and any != tab)
		{
	DIAG((D.menu,-1,"[2]collapse\n"));
			tab = collapse(tab, any);
			k = &tab->task_data.menu;
		}

		k = &tab->task_data.menu;

		if (   barred(tab)
		    and m_inside(k->x,k->y,&k->bar) )
			new_title(tab);
		else				/* in desktop ? */
		if (    cfg.menu_behave == LEAVE
		 	and barred(tab)
		 	and !tab->nest
		 	and !any
		 	and !(   k->x >= k->drop.x
		 	     and k->x <  k->drop.x + k->drop.w		/* HR 020601: do not leave if mouse UNDER popup. */
		        )
		   )
		{
			DIAG((D.menu,-1,"popout for leave\n"));
			IFDIAG(tab->dbg = 2;)
			popout(tab);
		}
		else
		{
			k->stage = IN_DESK;		/* There is no specific rectangle to target */
			k->em.flags = MU_MX;		/* report any mouse movement */
			k->em.t1 = where_are_we;	/* This will sort it out. :-) */
		}
	}
}

static
TASK new_title
{
	if (tab->nest)
	{
		IFDIAG(tab->dbg = 3;)
		popout(tab);
	}
	else
	{
		short title;
		MENU_TASK *k = &tab->task_data.menu;
	
		k->stage = IN_TITLE;	
		k->root->r.x = k->rdx;
		k->root->r.y = k->rdy;
		title = find_object(k->root, k->titles, 2, k->x, k->y);
		if (title == k->clicked_title)		/* no change */
		{
			k->em.flags = MU_M1|1;		/* fill out rect event data; out of title */
			object_area(&k->em.m1, k->root, k->clicked_title);
			k->em.t1 = where_are_we;
		}
		else
		{
			tab = menu_pop(tab);
			/* click_menu_widget */
			if (!menu_title(tab->lock, tab->wind, tab->widg, tab->locker))
			{
				/* No popup has been drawn. */
				IFDIAG(tab->dbg2 = 3;)
				menu_finish(tab);
			}
		}
	}
}

static
TASK click_menu_entry
{
	MENU_TASK *k= &tab->task_data.menu;

DIAG((D.menu,-1,"click_menu_entry: stage=%d\n",k->stage));
	if (k->stage != IN_MENU)
	{
	DIAG((D.menu,-1,"[3]collapse\n"));
		tab = collapse(tab, nil);
	}
	else
	{
		OBJECT *root = k->root;
		XA_TREE *w_otree;
		XA_CLIENT *client;
		short m,d,titles,subm = tab->nest != nil,
			  about,
			  kc,
			  ks;

		root->r.x = k->rdx;
		root->r.y = k->rdy;
		m = find_object(root, 0, MAX_DEPTH, k->x, k->y);
		d = root[m].ob_state & DISABLED;

	DIAG((D.menu,-1,"[4]collapse\n"));
		tab = collapse(tab,nil);
		k = &tab->task_data.menu;

		w_otree = tab->widg->stuff;
		titles = k->titles,
		about = k->about,
		ks = k->pop_item;
		kc = k->clicked_title;

DIAG((D.menu,-1,"%s,ti=%d,ab=%d,kc=%d,ks=%d,m=%d\n",d ? "DISABLED" : "", titles,about,kc,ks,m));
		if ( m > -1 and !d )
		{	
			root[m].ob_state &= ~SELECTED;	/* Deselect the menu entry */
			if (tab->wind != root_window)
			{
				OBJECT *rs = root;
				DIAG((D.menu,-1,"indirect call\n"));
				tab->wind->send_message
							(	tab->lock,
								tab->wind,
								w_otree->pid,
								MN_SELECTED,
								C.AESpid,
								kc,
								m,
								(long)rs >> 16,
								(long)rs,
								ks
							);
			}
			else
			if (    subm
			    or (    !subm
			        and (   kc != root[titles].ob_head
				         or m == about
				       )
				   )
			   )
			{
				if (w_otree->pid != C.AESpid)	/* If it's a client program menu, send it a little message to say hi.... */
				{
					OBJECT *rs = root;
					DIAG((D.menu,-1,"Calling send_app_message()\n"));
					DIAG((D.menu,-1,"app=%d,title=%d,point_at=%d\n", w_otree->pid, kc, m));
						/* Note the AES4.0 extended message format...... */
					send_app_message
							(	tab->lock,
								tab->wind,
								w_otree->pid,
								MN_SELECTED,
								C.AESpid,
								kc,
								m,
								(long)rs >> 16,
								(long)rs,
								ks
							);
				}
				else							/* Otherwise, process system menu clicks */
				{
					DIAG((D.menu,-1,"do_system_menu()\n"));
					do_system_menu(tab->lock, kc, m);
				}
			}
		}
	}
	IFDIAG(tab->dbg2 = 2;)
	menu_finish(tab);		/* Oef, a hole was left in the if symmetrie. */
}

static
TASK click_popup_entry
{
	short m;
	MENU_TASK *k = &tab->task_data.menu;
	XA_CLIENT *client = Pid2Client(tab->pid);
	AESPB *pb = tab->pb;
	MENU *md = pb->addrin[1];

	md->tree = k->root;						/* HR: 8/10/00 */
	md->scroll = 0;
	vq_key_s(C.vh, &md->keystate);

	k->root->r.x = k->rdx;
	k->root->r.y = k->rdy;
	md->item = find_object(k->root, k->pop_item, 1, k->x, k->y);
	if (md->item >= 0 and (k->root[md->item].ob_state & DISABLED) != 0)
		md->item = -1;
	
DIAG((D.menu, -1, "click_popup_entry %lx + %d\n", md->tree, md->item));

	pb->intout[0] = md->item < 0 ? 0 : 1;

	IFDIAG(tab->dbg = 6;)
	popout(tab);			/* incl. screen unlock */

	Unblock(client, XA_OK, 2);
}

/*
 *  Root function of a popup menu task.
 */

/* N.B ! this is not a widget behaviour, but a true AES function */
global
TASK do_popup_menu
{
	AESPB *pb = tab->pb;
	MENU *mn = pb->addrin[0], *md = pb->addrin[1];
	short x, y;
	OBJECT *ob = mn->tree;

	tab->reply = false;

#if POPUP_IN_WINDOW
	if ( ! cfg.menu_windowed )
#endif
	if (!lock_screen(tab->locker, 0, nil))
		return;			/* already locked by other process. */

	*md = *mn;

/*	clear_clip();
*/	
DIAG((D.menu,-1,"menu_popup %lx + %d\n",ob, mn->menu));

	ob->r.x = 0;
	ob->r.y = 0;
	object_offset(mn->tree, mn->menu, &x, &y);
	tab->wind = nil;
	tab->widg = nil;
	tab->ty = POP_UP;
	memset(&tab->task_data.menu, 0, sizeof(MENU_TASK));
	do_popup(tab, ob, mn->menu, click_popup_entry, pb->intin[0] - x, pb->intin[1] - y);
	tab->reply = true;			/* OK, this blocks the app */
}

global
short menu_owner(void)		/* standard menu bar */
{
	XA_WIDGET *widg = root_window->widgets + XAW_MENU;
	XA_TREE *w_otree = widg->stuff;
DIAG((D.menu,-1,"menu_owner() --> %d\n", w_otree->pid));
	return w_otree->pid;
}

/*
 *	Menu Tree Widget display
 */
static
WidgetBehaviour display_menu_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	XA_TREE *wt = widg->stuff;
	OBJECT *root;

	DIAG((D.widg,-1,"display_menu_widget for %s(%d) wind=%d\n", wind->owner->name, wind->owner->pid, wind->handle));

	root = rp_2_ap(wind, widg, nil);	/* Convert relative coords and window location to absolute screen location */

	draw_object_tree(lock, wt, nil, widg->start , MAX_DEPTH, true, 6);

	if (!wt->zen)			/* HR 090501  menu in user window.*/
	{
		short titles;
		
		write_menu_line(&root->r);	/* HR: not in standard menu's object tree */

/* HR: Use the AES's client structure to register the rectangle for the current menu bar. */
		titles = root[root[0].ob_head].ob_head;
		C.Aes->waiting_for = XAWAIT_MENU;
		object_area(&C.Aes->em.m1, root, titles);
		C.Aes->em.flags = MU_M1|0;	/* into menu bar */
	}
	return true;
}

/* root function of a menu_bar task */
/* The task stages are driven by mouse rectangle events completely */
/* Called by XA_move_event()
   and by do_widgets() only for the menu_bar itself */
static
WidgetBehaviour click_menu_widget	/* (LOCK lock, XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short pid = C.AESpid;

	if (wind->owner->killed)
		return false;

DIAG((D.menu,-1,"click_menu_widget\n"));

#if POPUP_IN_WINDOW
	if ( ! cfg.menu_windowed )
#endif
	if (wind == root_window)		/* HR: only need locking when the menu is outside a app window. */
		if (!lock_screen(pid, 0, nil))	/* Can't bring up menu without locking the screen */
			return false;			/* We return false here so the widget display status stays selected whilst it repeats */

	if (!menu_title(lock, wind, widg, pid))
	{
DIAG((D.menu,-1,"unlock_screen in click_menu_widget\n"));
		unlock_screen(pid);			/* HR 140501: used incorrect pid. fixed. */
	}
	return false;
}

static
bool menu_title(LOCK lock, struct xa_window *wind, struct xa_widget *widg, short locker)
{
	RECT r;
	Tab *tab;
	MENU_TASK *k;
	XA_TREE *wt;
	OBJECT *root;
	short f, n;

DIAG((D.menu,-1,"menu_title\n"));
	tab = new_task(C.active_menu);
	k = &tab->task_data.menu;
	tab->lock = lock;
	tab->pid = locker;		/* HR 140501 */
	tab->locker = locker;
	tab->wind = wind;
	tab->widg = widg;
	wt = widg->stuff;
	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */
	
/* first entry into the menu_bar; initialize task */
	root = wt->tree;
	k->root = root;
	root->r.x = k->rdx = r.x;
	root->r.y = k->rdy = r.y;
	k->titles = root[root[0].ob_head].ob_head;
	k->menus  = root[0].ob_tail;
	k->about = root[root[k->menus].ob_head].ob_head;
	vq_mouse(C.vh, &f, &k->x, &k->y);
	k->clicked_title = find_object(root, k->titles, 2, k->x, k->y);
	k->point_at_menu = -1;

	if (    k->clicked_title > -1
		and root[k->clicked_title].ob_type == G_TITLE
		and !(root[k->clicked_title].ob_state & DISABLED)
		)
	{
	/*	clear_clip();				/* Menus are always on top...so don't clip */
	*/	C.menu_base = tab;			/* OK, can do */
		C.menu_nest = 0;
		tab->ty = k->ty = wind == root_window ? ROOT_MENU : MENU_BAR;
		k->stage = IN_TITLE;
		object_area(&k->bar,root, k->titles);
		change_title(tab, 1);
		root[k->menus].ob_flags &= ~HIDETREE;
		n = root[k->menus].ob_head;
		for (f = root[k->titles].ob_head; f != k->titles; f = root[f].ob_next)
		{
			if (f == k->clicked_title)
				k->pop_item = n;
			else
				root[n].ob_flags |= HIDETREE;
				
			n = root[n].ob_next;
		}
	
		root[k->pop_item].ob_flags &= ~HIDETREE;	/* Show the actual menu */
		object_area(&k->drop,root,k->pop_item);		/* Does border & shadow. */

		k->entry = click_menu_entry;		/* obeyed by XA_MOUSE.C */

		if (desk_menu(tab) and C.menu_nest < CASCADE-1)
		{
			desk_popup.tree = built_desk_popup(tab->lock, 24,24);
			desk_popup.menu = 0;
			desk_popup.item = 0;
			desk_popup.scroll = 0;
			desk_popup.keystate = 0;
			attach_menu(tab->lock, C.Aes, root, k->about + 2, &desk_popup);
		}

		display_popup(tab);

		k->em.flags = MU_M1|1;		/* fill out rect event data; out of title */
		object_area(&k->em.m1, root, k->clicked_title);
		k->em.t1 = where_are_we;
		return true;
	}
	else
	{
		C.menu_base = 0;
		return false;
	}
}

#else
#include "obsolete/menu.h"
#endif

/*
 * Attach a menu to a window...probably let this be access via wind_set one day
 */
/* HR: Define loc completely outside this function,
       Click behaviour is a parameter (for popup's).
       Destructor for freeing the XA_TREE (x)calloc.  */
global
void set_menu_widget(XA_WINDOW *wind,
					 XA_TREE *menu)		/* HR tree --> widget */
{
	XA_TREE *nt = xcalloc(1,sizeof(XA_TREE),103);		/* HR: use calloc */
	XA_WIDGET *wi = &wind->widgets[XAW_MENU];		/* HR */
	OBJECT *obj = menu->tree;

	DIAG((D.widg,-1,"set_menu_widget(wind=%d):new@%lx\n", wind->handle, nt));

	if (!nt)
	{
		DIAG((D.widg,-1," - unable to allocate widget.\n"));
		return;
	}

	/* additional fix if in window */
	obj->r.w = obj[obj->ob_head].r.w = obj[obj->ob_tail].r.w = wind->wa.w;

	*nt = *menu;			/* HR menu widget.tree */

	wi->behaviour[XACB_DISPLAY] = display_menu_widget;
	wi->behaviour[XACB_CLICK]   = click_menu_widget;
	wi->behaviour[XACB_DCLICK] = nil;
	wi->behaviour[XACB_DRAG] = nil /* click_menu_widget */;
	wi->state = NONE;
	wi->stuff = nt;
	wi->start = 0;
	if (wind != root_window)		/* HR 090501  menu in user window.*/
		nt->zen = true;
/*	HR: See create_window(...XaMENU....) 
	calc_work_area(wind);			/* Recalculate the work area to include the new menu widget */
*/
}

#if 1
/*
 *	Perform a few fixes on a menu tree prior to installing it
 *	(ensure title spacing & items fit into their menus)
 */

/* HR: N.B. Using standard draw_object_tree for the menu bar has many advantages :-)
            There is however 1 disadvantage: TOS doesnt do this, so we may expect some
            incompatabilities.
*/

/* HR: Removed all spacing corrections. */
global
void fix_menu(OBJECT *root, bool desk)		/* Called by menu_bar() only */
{
	short titles, menus, tbar, s_ob, t_ob;

	DIAG((D.menu,-1,"fixing menu @%lx\n", root));

	tbar = root[0].ob_head;
	titles = root[tbar].ob_head;
	menus = root[0].ob_tail;

/* HR: */
	root->r.w = root[tbar].r.w = root[menus].r.w = screen.r.w;
	set_ob_spec(root,tbar, menu_colors());

	root[menus].ob_flags |= HIDETREE;	/* Hide the actual menus (The big ibox) */

	t_ob = root[titles].ob_head;
	s_ob = root[menus].ob_head;

	while(t_ob != titles)
	{
		root[s_ob].ob_flags |= HIDETREE;	/* Hide the actual menu */
		menu_spec(root, s_ob);
		t_ob = root[t_ob].ob_next;
		s_ob = root[s_ob].ob_next;
	}


/*  fix desk menu */
	if (desk)
	{
		s_ob = root[menus].ob_head;
		t_ob = root[s_ob ].ob_head;
		root[s_ob].r.h = root[t_ob+3].r.y - root[s_ob].r.y;
		t_ob+=2;
		root[t_ob++].ob_spec.string = "  Clients \3";
		while (t_ob != s_ob)
		{
			root[t_ob].ob_flags |= HIDETREE|DISABLED;
			t_ob = root[t_ob].ob_next;
		}
	}
	DIAG((D.menu,-1,"done fix_menu()\n"));
}

#else
#include "obsolete/fix_menu.h"
#endif
