/* Demo program showing fill patterns/styles in rounded filled boxes */
/*  By R.A.Waddilove    */

short	control[12],		/* These arrays are used by  */
		intin[128],			/* GEM and you don't need to */
		ptsin[128],			/* worry about them. Define  */
		intout[128],		/* them, then forget them.	 */
		ptsout[128];

short	work_in[11]={1,1,1,1,1,1,1,1,1,1,2},
		work_out[57],		/* holds various VDI parameters */
		handle,				/* virtual workstation handle */
		wchar,hchar,		/* character size */
		wbox,hbox;			/* character box size */

main()						/* void means we aren't passing parameters */
{
	short x,y,button,i,j,box[4],pat[16];
	appl_init();			/* initialise GEM AES arrays, return id */
	handle = graf_handle(&wchar,&hchar,&wbox, &hbox); /* GEM VDI handle */
	v_opnvwk(work_in, &handle, work_out);	/* open virtual workstation */
	v_hide_c(handle);						/* hide mouse */
	v_clrwk(handle);						/* clear the screen */


/* draw the fill patterns */
	vsf_color(handle,1);			/* colour=black */
	for ( x=0; x<24; ++x )	{		/* pattern styles 1-24 */
		vsf_interior(handle,2);		/* set patterned fill */
		vsf_style(handle,x+1);		/* choose pattern to fill with*/
		box[0] = x*26;				/* top left x */
		box[1] = 0;					/* top left y */
		box[2] = box[0]+23;			/* bottom right x */
		box[3] = box[1]+40;			/* bottom right y */
		v_rfbox(handle,box);		/* draw rounded filled box */
	}

/* draw the hatch patterns */
	vsf_color(handle,1);			/* colour=black */
	for ( x=0; x<12; ++x )	{		/* pattern styles 1-12 */
		vsf_interior(handle,3);		/* set hatch fill */
		vsf_style(handle,x+1);		/* choose pattern to fill with*/
		box[0] = x*52;				/* top left x */
		box[1] = 50;				/* top left y */
		box[2] = box[0]+48;			/* bottom right x */
		box[3] = box[1]+40;			/* bottom right y */
		v_rfbox(handle,box);		/* draw rounded filled box */
	}

/* Now for my own fill pattern! */
	pat[0] =  0x0F0F;
	pat[1] =  0x0F0F;
	pat[2] =  0x0000;
	pat[3] =  0x0000;
	pat[4] =  0xAAAA;
	pat[5] =  0xAAAA;
	pat[6] =  0xBBBB;
	pat[7] =  0xBBBB;
	pat[8] =  0xCCCC;
	pat[9] =  0xCCCC;
	pat[10] = 0xBBBB;
	pat[11] = 0xBBBB;
	pat[12] = 0x0000;
	pat[13] = 0x0000;
	pat[14] = 0x1234;
	pat[15] = 0x4321;
	vsf_udpat(handle,pat,1);
	vsf_interior(handle,4);		/* set user defined fill */
	box[0] = 40;				/* top left x */
	box[1] = 100;				/* top left y */
	box[2] = 600;				/* bottom right x */
	box[3] = 140;				/* bottom right y */
	v_rfbox(handle,box);		/* draw rounded filled box */

/* quit back to the desktop */
	do {
		vq_mouse(handle, &button, &x, &y);	/* get mouse x,y,button state */
	} while ( button==0 );		/* wait until a button is pressed */
	v_show_c(handle,1);			/* show mouse */
	v_clsvwk(handle);			/* close virtual workstation */
	appl_exit();				/* tell GEM we've finished */
}
