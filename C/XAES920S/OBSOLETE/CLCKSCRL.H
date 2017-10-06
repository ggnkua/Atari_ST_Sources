void click_scroll_list(OBJECT *form, short objc, short cx, short cy)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = form + objc;
	MOOSE_DATA md;
	short mx, my, mb, y;	

	list = (SCROLL_INFO *)ob_spec(ob);

	object_abs_coords(form, objc, &mx, &my);

	cx -= mx;	/* Get click position relative to the scroller */
	cy -= my;

	if (cy < display.c_max_h)
		return;

#if 1
	md.x = cx;
	md.y = cy;
	md.state = 0;
	md.clicks = 1;
	if (!do_widgets(list->wi, &md))
#else
	if (cx > ob->r.w - display.c_max_w - 4)
	{
		DIAG((D.objc,-1,"click_scroll_list: cy=%x\n", cy));
		
		if ((cy > display.c_max_h + 1) && (cy < display.c_max_h * 2 + 4))
			list->state = SCRLSTAT_UP;
		else
		if(cy > ob->r.h - display.c_max_h - 1)
			list->state = SCRLSTAT_DOWN;

		vq_mouse(V_handle, &mb, &mx, &my);
		
		do
		{
			if ((list->state == SCRLSTAT_UP) && (list->top != list->start))
			{
				list->top = list->top->prev;
				v_hide_c(V_handle);
				draw_object_tree(form, objc, 1);
				v_show_c(V_handle, 1);
			}

			if ((list->state == SCRLSTAT_DOWN) && (list->top->next))
			{
				list->top = list->top->next;
				v_hide_c(V_handle);
				draw_object_tree(form, objc, 1);
				v_show_c(V_handle, 1);
			}
		
			Fselect(20, NULL, NULL, NULL);	/* Wait a while to slow the scrolling down */

			vq_mouse(V_handle, &mb, &mx, &my);
		} while(mb);
	
		list->state = SCRLSTAT_RDB;

	} else
#endif
	{
		
		y = 5 + 2 * display.c_max_h;
		this = list->top;
		while((this) && (y < cy))
		{
				this = this->next;
				y += display.c_max_h;
		}

		if (this)
		{
			list->current = this;
			list->state = 0;
			
			if (list->click)			/* Call the new object selected callback */
				(*list->click)(form, objc);
		} else
			list->state = SCRLSTAT_RDB;
	}
	
	v_hide_c(V_handle);
	draw_object_tree(form, objc, 1);
	v_show_c(V_handle, 1);
	list->state = 0;
}

void dclick_scroll_list(OBJECT *form, short objc, short cx, short cy)
{
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	OBJECT *ob = form + objc;
	short mx, my, mb, y;	

	list = (SCROLL_INFO *)ob_spec(ob);
	
	object_abs_coords(form, objc, &mx, &my);

	cx -= mx;	/* Get click position relative to the scroller */
	cy -= my;

	if (cy < display.c_max_h)
		return;

	if (cx > ob->r.w - display.c_max_w - 4)
		return;

	y = 5 + 2 * display.c_max_h;
	this = list->top;
	while((this) && (y < cy))
	{
		this = this->next;
		y += display.c_max_h;
	}

	if (this)
	{
		list->current = this;
		list->state = 0;
	} else
		list->state = SCRLSTAT_RDB;
	
	v_hide_c(V_handle);
	draw_object_tree(form, objc, 1);
	v_show_c(V_handle, 1);
	list->state = 0;
	
	if (list->dclick)
		(*list->dclick)(form, objc);
	
}
