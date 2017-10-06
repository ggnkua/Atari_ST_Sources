void fix_menu(OBJECT *root)
{
	short pxy[8];
	short titles, ob, mnx = 0, mnh, mnw, temp;
	short menus, tbar, text, s_ob, t_ob;
	unsigned long cl;
	OBJC_COLORWORD colr;

#if 0
	colr.borderc = display.dial_colours.fg_col;		/* Menu match colour scheme */
	colr.textc = display.dial_colours.fg_col;
	colr.fillc = display.dial_colours.bg_col;
	colr.opaque = 1;
	colr.pattern = 7;
	cl = *((short *)&colr);
#endif

	cl = 0xff0000L;
	cl += display.dial_colours.fg_col << 12;
	cl += (display.dial_colours.fg_col << 8) + (1 << 7) + (7 << 4) + display.dial_colours.bg_col;

	DIAG(menu,("fixing menu @%lx\n", root));

	tbar = root[0].ob_head;
	titles = root[tbar].ob_head;
	menus = root[0].ob_tail;

	root[menus].ob_flags |= HIDETREE;	/* Hide the actual menus (The big ibox) */

	root[menus].r.x = display.c_max_w;	/* HR */
	root[menus].r.y = display.c_max_h + 3;

	t_ob = root[titles].ob_head;
	s_ob = root[menus].ob_head;

	while(t_ob != titles)				/* Fix title spacings (some resource editors don't set them up right) */
	{
		root[s_ob].r.x = mnx;
		root[s_ob].r.y = 0;

		root[s_ob].ob_flags |= HIDETREE;	/* Hide the actual menu */

		if (root[t_ob].ob_type == G_TITLE)
		{
			DIAG(menu,("title:[%d]=%s\n", t_ob, (char *)ob_spec(&root[t_ob])));
			vqt_extent(V_handle, (char *)ob_spec(&root[t_ob]), pxy);
			mnw = abs(pxy[2] - pxy[0]) + display.c_max_w;		/* HR: */ 
		} else
		{
			mnw = root[t_ob].r.w;
		}
		mnx += mnw;												/* HR: */ 
		root[t_ob].r.w = mnw;
		root[t_ob].r.h = display.c_max_h + 2;
		mnw = mnh = 0;

		set_obspec(root,s_ob,cl);
/*		root[s_ob].ob_flags |= FLD3DBAK;*/

/* Fix menu spacings */
		for(text = root[s_ob].ob_head; text != s_ob; text = root[text].ob_next)
		{
#if 0
			switch(root[text].ob_type)
			{
			case G_STRING:
			case G_SHORTCUT:			/* HR */
			case G_TITLE:
				vqt_extent(V_handle, (char *)root[text].ob_spec, pxy);
				temp = abs(pxy[2] - pxy[0]);
				root[text].r.h = abs(pxy[1] - pxy[5]);
				DIAG(menu,("entry(string):[%d]=%s\n", text, (char *)root[text].ob_spec));
				break;
			case G_TEXT:
				vqt_extent(V_handle, ((TEDINFO *)root[text].ob_spec)->te_ptext, pxy);
				temp = abs(pxy[2] - pxy[0]);
				root[text].r.h = abs(pxy[1] - pxy[5]);
				DIAG(menu,("entry(text):[%d]=%s\n", text, ((TEDINFO *)root[text].ob_spec)->te_ptext));
				break;
			default:
				/*obfix(root, text);*/
				temp = root[text].r.w;
				DIAG(menu,("entry(default)\n"));
				break;
			}

			DIAG(menu,("width=%d,height=%d\n", temp, root[text].r.h));
#endif
/*			root[text].r.x = 0;
			root[text].r.y = mnh;
			root[text].r.w = temp;
*/
			if (root[text].r.y + root[text].r.h > mnh)
				mnh = root[text].r.y + root[text].r.h;
			if (root[text].r.x + root[text].r.w > mnw)
				mnw = root[text].r.x + root[text].r.w;

/*			if (temp > mnw)
				mnw = temp;
*/							
		}
		root[s_ob].r.w = mnw;
		root[s_ob].r.h = mnh;

		t_ob = root[t_ob].ob_next;
		s_ob = root[s_ob].ob_next;
	}

	root[0].r.w  = mnx;
	root[0].r.h = display.c_max_h;
	root[tbar].r.w  = mnx;
	root[tbar].r.h = display.c_max_h + 2;		/* HR */
	root[menus].r.w  = mnx;
	root[menus].r.h = display.c_max_h;

	cl = 7 << 4;
	cl += (display.dial_colours.fg_col << 12) + (display.dial_colours.fg_col << 8) + display.dial_colours.bg_col;
	set_obspec(root,tbar,cl);
	
	DIAG(menu,("done fix_menu()\n"));
}
