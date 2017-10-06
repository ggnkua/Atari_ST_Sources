/* pre mouse rectangle version */
/* HR: This still works and is maintained.
	   I want to be able to switch off rectangle events. */
WidgetCallback click_menu_widget	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	extern Tab active_menu;
	XA_WIDGET_TREE *w_otree = widg->stuff;
	OBJECT *root;
	XA_CLIENT *client;
	MOOSE_DCLICK_COM moose_enable;
	short f, n;
	short t, titles, menus, about;
	short mx, my, mb;
	RECT r;
	MENU_TASK *k = &active_menu.task_data;

	rp_2_ap(wind, widg, &r);	/* Convert relative coords and window location to absolute screen location */
	root = w_otree->tree;
	root->r.x = r.x;
	root->r.y = r.y;
	titles = root[root[0].ob_head].ob_head;			/* HR */
	menus  = root[0].ob_tail;
	about = root[root[menus].ob_head].ob_head;

	if (!k->stage)
	{
		if (Psemaphore(2, UPDATE_LOCK, 0L) < -1)	/* Can't bring up menu without locking the screen */
		{
/* HR:  (*)() & void * */
			set_active_function(&active_menu, RETRY, repeat_menu_widget, wind, widg, 200);	/* Repeat on a time basis */
			return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
		}

		k->selected_menu = -1;
		k->point_at_menu = -1;
		vq_mouse(V_handle, &mb, &mx, &my);
		if (mb)							/* Exit conditions for the menu - mouse down/mouse up */
			k->exit_mb = 0;
		else
			k->exit_mb = 1;
#if TEAR_OFF
		if (wind == root_window)		/* Tear off menu bar support (root menu only) */
		{
			vq_key_s(V_handle, &t);
			if (t & 4)					/* CNTR key */
			{
				RECT cr = r;
				XA_WINDOW *new_menu_window;
				short w, max_w;
			
				max_w = 0;
				for(f = root[titles].ob_head; f != titles; f = root[f].ob_next)
				{
					w = root[f].r.x + root[f].r.w;
					if (w > max_w)
						max_w = w;
				}
/*				r.x, r.y + r.h, max_w + 34, r.h + 8
*/
				cr.y += r.h;
				cr.w += 34;
				cr.h += 8;
				new_menu_window = create_window(((XA_WIDGET_TREE *)root_window->widgets[XAW_MENU].stuff)->owner, CLOSE|NAME|MOVE|NO_MESSAGES|NO_WORK, cr);
				new_menu_window->is_open = TRUE;
				new_menu_window->widgets[XAW_TITLE].stuff = empty_title;
	
				set_menu_widget(new_menu_window, widg->loc, click_menu_widget, (OBJECT *)((XA_WIDGET_TREE *)root_window->widgets[XAW_MENU].stuff)->tree);
				new_menu_window->widgets[XAW_TITLE].loc.r.w = new_menu_window->widgets[XAW_CLOSE].loc.r.w;
				new_menu_window->widgets[XAW_TITLE].loc.r.x = new_menu_window->widgets[XAW_CLOSE].loc.r.x + new_menu_window->widgets[XAW_CLOSE].loc.r.w + 1;
				new_menu_window->widgets[XAW_MENU].loc.r.x = new_menu_window->widgets[XAW_TITLE].loc.r.x + new_menu_window->widgets[XAW_TITLE].loc.r.w;
				new_menu_window->widgets[XAW_MENU].loc.r.w = max_w;
				new_menu_window->widgets[XAW_MENU].loc.r.y = 2;
				((XA_WIDGET_TREE *)new_menu_window->widgets[XAW_MENU].stuff)->owner = ((XA_WIDGET_TREE *)root_window->widgets[XAW_MENU].stuff)->owner;
				pull_wind_to_top(new_menu_window);
				display_non_topped_window(new_menu_window, NULL);
				Psemaphore(3, UPDATE_LOCK, 0);	/* Unlock the screen, we're done */
				update_lock = FALSE;

				return FALSE;
			}
		}
#endif
		moose_enable.dclick_prefix = 0x4d44;	/* Disable moose to avoid click fall through */
		moose_enable.dclick_time = 0;
		Fwrite(MOUSE_dev, 4L, &moose_enable);

		vq_mouse(V_handle, &f, &k->omx, &k->omy);
/*		k->omx = r.x + widg->click_x;
		k->omy = r.y + widg->click_y;
*/		k->clicked_title = find_object(root, titles, 2, k->omx, k->omy);
DIAG(mouse,("title: %d,x:%d,y:%d\n",k->clicked_title,k->omx,k->omy));
	}

	if (   k->clicked_title > -1
		&& root[k->clicked_title].ob_type == G_TITLE
		&& !(root[k->clicked_title].ob_state & DISABLED)		/* HR */
		)
	{
		widg->stat = SELECTED; 
		root[menus].ob_flags &= ~HIDETREE;
/*		root[menus].r.y = 0;						!!!!!!!!!!!
HR: This not the right place to fringle with placement
	if you want it different from standard, do it in fix_menu()
	Now I can correctly use object_abs_coords()
	It is important to be true and exact so others can recognize what you do.
		see alse parameters for vro_cpyfm().
*/
		do
		{
			if (k->stage != 3)
			{
				n = root[menus].ob_head;
				for (f = root[titles].ob_head; f != titles; f = root[f].ob_next)
				{
					if (f == k->clicked_title)
						k->selected_menu = n;
					else
						root[f].ob_state &= ~SELECTED;
					n = root[n].ob_next;
				}
				root[k->clicked_title].ob_state |= SELECTED;

/* HR: if the most left title is clicked, built a new tree that
	includes the first 2 original entries followed by the names of the acc's
	followed by a seperator
	followed by all other clients,
	focus application checked.
*/
				object_abs_coords(root, k->selected_menu, &k->x, &k->y);

/* HR */ 		if (k->clicked_title == root[titles].ob_head)		/* desk menu title */
				{
					k->cur_drop = built_drop(&root[k->selected_menu],k->x, k->y),
					k->cur_drop_item = 0;		/* it must be a replaced tree */
				} else
				{
					k->cur_drop = &root[k->selected_menu],
					k->cur_drop_item = k->selected_menu;
					k->cur_drop->ob_flags &= ~HIDETREE;	/* Show the actual menu */
				}

				clear_clip();				/* Menus are always on top...so don't clip */
				k->drop = k->cur_drop->r;
				k->drop.x = k->x, k->drop.y = k->y;
				v_hide_c(V_handle);
				k->Mpreserve = form_save(1, k->drop, nil);
/* HR */		if (k->cur_drop_item == 0)
					draw_object_tree(k->cur_drop, 0, 2);
				else
					display_menu_widget(wind, widg);
				v_show_c(V_handle, 1);
			}
			
			k->stage = 1;
	
	/* Do a point-at-and-click menu selection */
/*			do {*/
				vq_mouse(V_handle, &mb, &mx, &my);
				
				if ((mx != k->omx) || (my != k->omy))
				{
					k->omx = mx;
					k->omy = my;
					
/* HR: This may look a little kludgy, but remember that objects are fixed in a array. */
 					if (k->cur_drop_item == 0)
					{
						t = find_object(k->cur_drop, 0, 2, mx, my);
						if (t != k->point_at_menu)
						{
							if (k->point_at_menu != -1)		/* De-select current selection (if any) */
								change_desk_menu(k->cur_drop,k->point_at_menu, 0);

							if ((t != -1) && (!(k->cur_drop[t].ob_state & DISABLED)))	/* Something selected at the moment? */
							{
								change_desk_menu(k->cur_drop, t, 1);	
								k->point_at_menu = t;
							}
							else
								k->point_at_menu = -1;

							clear_clip();
						}
					} else
					{
						t = find_object(root, k->selected_menu, 2, mx, my);
					
						if (t != k->point_at_menu)
						{
							if (k->point_at_menu != -1)		/* De-select current selection (if any) */
								change_menu(root, k->point_at_menu, 0);

							if ((t != -1) && (!(root[t].ob_state & DISABLED)))	/* Something selected at the moment? */
							{
								change_menu(root, t, 1);			/* Highlight current selection */
								k->point_at_menu = t;
							}
							else
								k->point_at_menu = -1;
	
							clear_clip();
						}
					}

					if (t == -1)		/* Not pointing at a menu item - check for a new title */
					{
						k->point_at_title = find_object(root, titles, 2, k->omx, k->omy);
						
						if (   k->point_at_title > -1
							&& k->point_at_title != k->clicked_title
							&& root[k->point_at_title].ob_type == G_TITLE
							&& !(root[k->point_at_title].ob_state & DISABLED)		/* HR */
						   )
							k->stage = 2;
					}
				}
/*			} while((mb != k->exit_mb) && (k->stage == 1));*/

			if((mb != k->exit_mb) && (k->stage == 1))			/* No change in status, can return and get back to it later */
			{
				k->stage = 3;
/*  HR:	(*)() &  void * */
				set_active_function(&active_menu, RETRY, repeat_menu_widget, wind, widg, 30);	/* Repeat on a time basis */
				return FALSE;	/* We return false here so the widget display status stays selected whilst it repeats */
			}

			root[k->clicked_title].ob_state &= ~SELECTED;	/* Deselect the title */
			root[k->selected_menu].ob_flags |= HIDETREE;		/* Hide the actual menu */
	
			clear_clip();
			v_hide_c(V_handle);
			form_restore(1, k->drop, k->Mpreserve);
			display_menu_widget(wind, widg);
			v_show_c(V_handle, 1);			/* HR: after display..... */

			if (mb == k->exit_mb)
				k->stage = 0;
			else
				k->clicked_title = k->point_at_title;

		} while(k->stage);
		
		root[menus].ob_flags |= HIDETREE;

		if (k->clicked_title == root[titles].ob_head && k->point_at_menu == 1 )	/* HR: replaced 'about' */
		{
			k->cur_drop[1].ob_state &= ~SELECTED;
			k->point_at_menu = about;											/* original 'about' */
		}

		if (   k->clicked_title != root[titles].ob_head
			|| k->point_at_menu == about)
		{
			if (k->point_at_menu != -1)			/* Exiting with a selection - send it */
			{
				root[k->point_at_menu].ob_state &= ~SELECTED;	/* Deselect the menu entry */
				if (w_otree->owner != AESpid)	/* If it's a client program menu, send it a little message to say hi.... */
				{
					DIAG(menu,("Calling send_app_message()\n"));
					DIAG(menu,("app=%d,title=%d,point_at=%d\n", w_otree->owner, k->clicked_title, k->point_at_menu));
						/* Note the AES4.0 extended message format...... */
					send_app_message(w_otree->owner,
								MN_SELECTED,
								AESpid,
								k->clicked_title,
								k->point_at_menu,
								(short)((long)root >> 16),
								(short)((long)root & 0xffff),
								k->selected_menu			);
				}
				else							/* Otherwise, process system menu clicks */
				{
					DIAG(menu,("do_system_menu()\n"));
					do_system_menu(k->clicked_title, k->point_at_menu);
				}
			}

		} else
		{
			XA_WIDGET_TREE *menu_bar = root_window->widgets[XAW_MENU].stuff;
			short pid = menu_regpid[k->point_at_menu - 1];
			if (pid > 0)
			{
				client = Pid2Client(pid);
				DIAG(menu,("got client pid=%d\n", pid));
				if (pid == AESpid)		/* HR */
					swap_menu(menu_bar, pid);
				else
					switch (client->client_type)
					{
					case XA_CT_ACC:		/* Accessory - send AC_OPEN */
						DIAG(menu,("is an accessory\n"));
/* HR: found the reason some acc's wouldnt wake up: msgbuf[4] must contain the meu_register reply
	which in our case is the pid.
	We need not worry about AC_CLOSE, because that one is for singletasking. */
						send_app_message(pid, AC_OPEN, AESpid, 0, pid, 0, 0, 0);
						break;
				
					case XA_CT_APP:		/* Application, swap topped app */
						DIAG(menu,("is a real GEM client\n"));
						swap_menu(menu_bar, pid);
						break;
					}
			}
		}

		widg->stat = NONE;

	}

	moose_enable.dclick_prefix = 0x4d44;			/* Re-enable moose */
	moose_enable.dclick_time = 50;
	Fwrite(MOUSE_dev, 4L, &moose_enable);

	Psemaphore(3, UPDATE_LOCK, 0);	/* Unlock the screen, we're done */

	clear_active_function(&active_menu);	/* We've finished with the active function now */
	Pid2Client(AESpid)->waiting_for = XAWAIT_MENU;		/* ready for next menu choice */
	return FALSE;		/* Return false so we don't re-display the widget */
}
