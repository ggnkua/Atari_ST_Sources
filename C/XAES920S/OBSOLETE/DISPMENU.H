WidgetCallback display_menu_widget	/* (XA_WINDOW *wind, XA_WIDGET *widg) */
{
	short x, y;
	XA_WIDGET_TREE *w_otree = (XA_WIDGET_TREE *)widg->stuff;
#if 0
	XA_CLIENT *client;
	short this_t = -1, sel_t = -1, sel_t_menu, titles;
	short menu_x, menu_y;
	short menu_text, mty;
	short title;
	short pxy[4];
#endif
	OBJECT *root;
	short mx, my, mb;

	DIAG(menu,("display_menu_widget(wind=%d)\n", wind->handle));

	rp_2_ap(wind, widg, &x, &y);	/* Convert relative coords and window location to absolute screen location */
	
	root = w_otree->tree;
	DIAG(menu,("w_otree=%lx,root=%lx\n", w_otree, root));

	root->r.x = x;
	root->r.y = y;

	draw_object_tree(root, /* HR: */ widg->start , 10);	/* This should display a selected menu as well */

#if 0
	titles = root[root[0].ob_head].ob_head;			/* HR */
	vst_color(V_handle, BLACK);

	pxy[0] = x;
	pxy[1] = y;
	pxy[2] = wind->w + wind->x - x;
	pxy[3] = y + widg->h;
	vsf_color(V_handle, display.dial_colours.bg_col);
	v_bar(V_handle, pxy);
		
	vq_mouse(V_handle, &mb, &mx, &my);
	
	vsf_color(V_handle, BLACK);

	title = root[titles].ob_head;

	for(this_t = root[titles].ob_head;
				this_t != titles;
				this_t = root[this_t].ob_next
	   )
	{
		this_t++;
		if (root[title].ob_state & SELECTED)
			sel_t = this_t; 
	}

	if ((widg->stat == XAW_SELECTED) && (sel_t != -1))
	{			/* If a menu is selected, display the actual menu */
		sel_t_menu = root[root[0].ob_tail].ob_head;
		for(title = 0; (title != sel_t); title++)
			sel_t_menu = root[sel_t_menu].ob_next;
			
		if (sel_t != 0)
		{
			DIAG(menu,("displaying selected menu\n"));
			draw_object_tree(root, sel_t_menu, 5);
		} else {
			pxy[1] = y + widg->h; 
			pxy[2] = pxy[0] + root[sel_t_menu].r.w;
			pxy[3] = pxy[1] + root[sel_t_menu].r.h;
			XA_3D_rect(menu_x, menu_y + widg->h + 2, root[sel_t_menu].r.w + 10, root[sel_t_menu].r.h + 4, 2, 1);

			vsf_color(V_handle, BLACK);

			mty = menu_y + widg->h + 5;
		
			menu_text = root[sel_t_menu].ob_head;

			if (root[menu_text].ob_state & DISABLED)
			{			/* Disabled item? */
				vst_effects(V_handle, SHADED);
			} else {
				if (root[menu_text].ob_state & SELECTED) {		/* Selected menu item? */
					vst_color(V_handle, WHITE);
					pxy[0] = menu_x + 5;
					pxy[1] = mty;
					pxy[2] = pxy[0] + root[sel_t_menu].r.w + 1;
					pxy[3] = pxy[1] + display.c_max_h;
					v_bar(V_handle, pxy);
				}
			}
			v_gtext(V_handle, menu_x + 5, mty, (char *)root[menu_text].ob_spec);
			
			mty += display.c_max_h;
			pxy[0] = menu_x + 4;
			pxy[1] = pxy[3] = mty;
			pxy[2] = pxy[0] + root[sel_t_menu].r.w + 1;
			v_pline(V_handle, 2, pxy);
			
			mty += 3;
			
			for(client = FirstClient(); client != NULL; client = NextClient(client))
			{
				if (client->clnt_pipe_rd)
				{
					if (   mx > menu_x
					    && mx < menu_x + root[sel_t_menu].r.w
					    && my > mty
					    && my < mty + display.c_max_h
					   )
					{
						vst_color(V_handle, WHITE);
						vsf_color(V_handle, BLACK);
					} else {
						vst_color(V_handle, BLACK);
						vsf_color(V_handle, display.dial_colours.bg_col);
					}
					pxy[0] = menu_x + 5;
					pxy[1] = mty;
					pxy[2] = pxy[0] + root[sel_t_menu].r.w + 1;
					pxy[3] = pxy[1] + display.c_max_h;
					v_bar(V_handle, pxy);
					
					v_gtext(V_handle, menu_x + 5, mty, client->name);

					if (((XA_WIDGET_TREE *)root_window->widgets[XAW_MENU].stuff)->owner == Client2Pid(client)) {
						v_gtext(V_handle, menu_x + 5, mty, "");
					} else {
						if (client->client_type == XA_CT_ACC) {
							v_gtext(V_handle, menu_x + 5, mty, "ø");
						}
					}
					
					vst_color(V_handle, BLACK);
					mty += display.c_max_h;
				}
			}
		}
	}
#endif

	return TRUE;
}
