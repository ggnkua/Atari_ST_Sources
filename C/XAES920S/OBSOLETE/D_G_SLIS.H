void display_list_element(SCROLL_ENTRY *this, short x, short y, short w, short sel)
{
	short coords[4], temp;
	
	if (sel)
	{
		vsf_color(V_handle, BLACK);
		coords[0] = x - 1;
		coords[1] = y + 1;
		coords[2] = x + w - display.c_max_w - 29;
		coords[3] = y + display.c_max_h;
		v_bar(V_handle, coords);
		vst_color(V_handle, WHITE);
		v_gtext(V_handle, x, y, this->text);
		vst_color(V_handle, BLACK);
		if (this->icon)
		{
			this->icon->ob_state |= SELECTED;
			display_object(this->icon, 0, x - 16, y);
			if (this->icon->r.h > display.c_max_h)
				y += this->icon->r.h - display.c_max_h;
			vswr_mode(V_handle, MD_TRANS);
		}
	} else
	{
		v_gtext(V_handle, x, y, this->text);
		if (this->icon)
		{
			this->icon->ob_state &= ~SELECTED;
			display_object(this->icon, 0, x - 16, y);
			if (this->icon->r.h > display.c_max_h)
				y += this->icon->r.h - display.c_max_h;
			vst_color(V_handle, BLACK);
			vswr_mode(V_handle, MD_TRANS);
		}
	}
}

ObjectDisplayCallback d_g_slist	/* (ODC_PARM *odc_p) */
{
	RECT r = odc_p->r;
	OBJECT *ob = odc_p->tree + odc_p->object;

	OBJC_COLORWORD *colourword;
	SCROLL_INFO *list;
	SCROLL_ENTRY *this;
	MFDB Mscreen;
	short border_thick = 0, coords[8], x, y, maxy, temp;

	list = (SCROLL_INFO *)ob_spec(ob);
	colourword = (OBJC_COLORWORD *)&list->scrl_colour;
	
	set_colours(ob, colourword);
	vswr_mode(V_handle, MD_TRANS);

	if (!list->scrl_status)
	{
		if (ob->ob_flags & FLD3DANY)
		{
			XA_3D_pushbutton(0, &r, ob->ob_state, 0, 1);
			done(SELECTED);
		} else
		{
			gbar(0, &r);
			if (border_thick)	/* Display a border? */
				g2d_box(border_thick, &r, colourword->borderc);
		}
	} else
	{
		switch(list->scrl_status)
		{
		case SCRLSTAT_UP:
			Mscreen.fd_addr = NULL;
			
			coords[0] = r.x + 4;
			coords[1] = r.y + display.c_max_h + 4;
			coords[2] = r.x + r.w - display.c_max_w - 5;
			coords[3] = r.y + r.h - 1 - display.c_max_h;
			coords[4] = coords[0];
			coords[5] = coords[1] + display.c_max_h;
			coords[6] = coords[2];
			coords[7] = coords[3] + display.c_max_h;
			
			vro_cpyfm(V_handle, S_ONLY, coords, &Mscreen, &Mscreen);

			x = r.x + 21;
			y = r.y + 5 + display.c_max_h;

			coords[3] = coords[5] - 1;
			v_bar(V_handle, coords);				

			display_list_element(list->scrl_dstart, x, y, r.w, (list->scrl_dstart == list->scrl_current));

			break;
				
		case SCRLSTAT_DOWN:
			Mscreen.fd_addr = NULL;
			
			coords[0] = r.x + 4;
			coords[1] = r.y + 5 + 2 * display.c_max_h;
			coords[2] = r.x + r.w - display.c_max_w - 5;
			coords[3] = r.y + r.h - 4;
			coords[4] = coords[0];
			coords[5] = coords[1] - display.c_max_h;
			coords[6] = coords[2];
			coords[7] = coords[3] - display.c_max_h;
			
			vro_cpyfm(V_handle, S_ONLY, coords, &Mscreen, &Mscreen);

			coords[1] = coords[7];
			v_bar(V_handle, coords);				
		
			x = r.x + 21;
			y = r.y + 5;
			maxy = r.y + r.h - 2 * display.c_max_h;
	
			for(this = list->scrl_dstart; (this) && ( y < maxy); this = this->next)
			{
				y += display.c_max_h;
				if (y > maxy - display.c_max_h)
					display_list_element(this, x, y, r.w, (this == list->scrl_current));
			}
			
			break;
		}
		
	}
	
	x = r.x + r.w - display.c_max_w - 4;
	y = r.y;
	
	vsf_color(V_handle, display.dial_colours.bg_col);
	vsf_interior(V_handle, FIS_SOLID);

	push_3d_button(-1, r.x, y, r.w, display.c_max_h, 0,0,1);

	coords[0] = x - 1;
	coords[1] = y + display.c_max_h;
	coords[2] = x + display.c_max_w + 3;
	coords[3] = y + r.h - 1;
	v_bar(V_handle, coords);

	push_3d_button(-1, x, y + display.c_max_h + 1, display.c_max_w + 4, display.c_max_h,
			(list->scrl_status & SCRLSTAT_UP) ? SELECTED : 0, 0, 1);
	push_3d_button(-1, x, y + r.h + 1 - display.c_max_h, display.c_max_w + 4, display.c_max_h,
			(list->scrl_status & SCRLSTAT_DOWN) ? SELECTED : 0, 0, 1);

	vswr_mode(V_handle, MD_TRANS);
	vst_alignment(V_handle, 1, 5, &temp, &temp);
	v_gtext(V_handle, r.x + (r.w / 2), r.y + 1,list->scrl_title);
	vst_alignment(V_handle, 0, 5, &temp, &temp);
	v_gtext(V_handle, x + 2, y + display.c_max_h + 2, "");
	v_gtext(V_handle, x + 2, y + r.h - display.c_max_h + 1, "");
	

	if (!list->scrl_status)
	{
		x = r.x + 21;
		y = r.y + 5 + display.c_max_h;
		maxy = r.y + r.h - display.c_max_h;
	
		for(this = list->scrl_dstart; (this) && (y < maxy); this = this->next)
		{
			display_list_element(this, x, y, r.w, (this == list->scrl_current));
			y += display.c_max_h;
		}
	}
}
