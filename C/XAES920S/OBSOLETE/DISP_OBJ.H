void display_object(OBJECT *tree, short object, short parent_x, short parent_y)
{
	OBJC_COLORWORD *colourword;
	OBJECT *ob = tree + object;
	ObjectDisplayCallback *display_routine;
	ODC_PARM odc_p;
	unsigned short zap;
	short coords[10];
	short colourmode = !MONO;
	short state_mask = (SELECTED|CROSSED|CHECKED|DISABLED); /* -> G_PROGDEF */
	short obx = parent_x + ob->r.x;
	short oby = parent_y + ob->r.y;
	short obx2 = obx + ob->r.w - 1;
	short oby2 = oby + ob->r.h - 1;
	short t;
#if 0			/* HR: Dangerous, if the writing mode setting has a hole somewhere */
								and what about shadow & outline etcetera? */	
	if (   obx  > global_clip[2]			/* Exit immediately if object is totally outside clip area */
		|| obx2 < global_clip[0]
		|| oby  > global_clip[3]
		|| oby2 < global_clip[1]
		)
		return;
#endif
	t = ob->ob_type & 0xff;

	colourword = (OBJC_COLORWORD *) & zap;

/* This is completely catered for in d_g_button, (well ... since we have tha latest XA_3D_pushbutton.) */
	if (   (ob->ob_flags & DEFAULT)		/* Default exit object */
		&& (t == G_BUTTON)				/* Only BUTTONS change appearance! */
		&& (ob->ob_flags & FLD3DANY)) 	/* 2D buttons are handled elsewhere */
	{
		vsf_color(V_handle, BLACK);
		vsf_interior(V_handle, FIS_SOLID);
		if MONO		/* HR: 3D mono */
		{
			vsl_color(V_handle, BLACK);
			bar(V_handle,obx-3,oby-3,ob->r.w+6,ob->r.h+6);
		} else
		{
			vsf_color(V_handle, BLACK);
			p_bar(V_handle,obx-2,oby-2,ob->r.w+4,ob->r.h+4);
		}
	}

	display_routine = objc_jump_table[t];	/* Get display routine for this type of object from jump table */

	if (display_routine == NULL)			/* If we don't have a display routine for a given object type, draw a box instead */
		display_routine = objc_jump_table[G_IBOX];

	odc_p.tree = tree;					/* Fill in the object display parameter structure */
	odc_p.object = object;					
	odc_p.parent_x = parent_x;
	odc_p.parent_y = parent_y;
	odc_p.x = obx;
	odc_p.y = oby;
	odc_p.state_mask = &state_mask;

	(*display_routine)(&odc_p);			/* Call the appropriate display routine */

	vswr_mode(V_handle, MD_TRANS);

/* HR: zap, to which colourword points to is not initialized!!! */
	if (ob->ob_state & CROSSED)
	{
		vsl_color(V_handle, colourword->borderc);
		coords[0] = parent_x + ob->r.x;
		coords[1] = parent_y + ob->r.y;
		coords[2] = parent_x + ob->r.x + ob->r.w - 1;
		coords[3] = parent_y + ob->r.y + ob->r.h - 1;
		v_pline(V_handle, 2, coords);
		coords[0] = parent_x + ob->r.x + ob->r.w - 1;
		coords[2] = parent_x + ob->r.x;
		v_pline(V_handle, 2, coords);
	}

	/* Handle CHECKED object state: */
	if ((ob->ob_state & state_mask) & CHECKED)
	{
		vst_color(V_handle, BLACK);
		v_gtext(V_handle, obx + 2, oby, "\10");	/* ASCII 8 = checkmark */
	}
/* HR: why twice ?, anyhow border_thick was zero anyway. */
	/* Handle CROSSED object state: */
	if ((ob->ob_state & state_mask) & CROSSED)
	{
		coords[0] = coords[4] = obx - border_thick;
		coords[1] = coords[7] = oby - border_thick;
		coords[2] = coords[6] = obx2 + border_thick;
		coords[3] = coords[5] = oby2 + border_thick;

		vsl_color(V_handle, WHITE);
		vsl_width(V_handle, 1);
		vsl_type(V_handle, 1);
		v_pline(V_handle, 2, &coords[0]);
		v_pline(V_handle, 2, &coords[4]);
	}

	coords[0] = obx;		/* HR: same here: border_thick is zero */
	coords[1] = oby;
	coords[2] = obx2;
	coords[3] = oby2;
	if (border_thick > 0)	/* Inside border */
	{
		coords[0] += border_thick;
		coords[1] += border_thick;
		coords[2] -= border_thick;
		coords[3] -= border_thick;
	}


	/* Handle DISABLED state: */
	/* (May not look too hot in colour mode, but it's better than
		no disabling at all...) */
	if ((ob->ob_state & state_mask) & DISABLED)
	{
		static short pattern[16] =
		{
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa,
			0x5555, 0xaaaa, 0x5555, 0xaaaa
		};

		vsf_color(V_handle, WHITE);
		vsf_udpat(V_handle, pattern, 1);
		vsf_interior(V_handle, FIS_USER);
		v_bar(V_handle, coords);
	}
/* HR: but it is too late! it is already done for some! */
	/* Handle SELECTED state only in non-colour mode: */
	if (   (   MONO
			&& ((ob->ob_state & state_mask) & SELECTED)
		   )
		&& (!(ob->ob_flags & FLD3DANY))
		)
	{
		vswr_mode(V_handle, MD_XOR);
		vsf_color(V_handle, BLACK);
		vsf_interior(V_handle, FIS_SOLID);
		v_bar(V_handle, coords);
		vswr_mode(V_handle, MD_TRANS);
	}
}
