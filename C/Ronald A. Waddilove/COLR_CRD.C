/* Using the VDI: Program 3 */
/*     Colour Test Card     */
/*     By R.A.Waddilove     */
/*       Lattice C v5       */

#include <vdi.h>

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

main(void)					/* void means we aren't passing parameters */
{
	short x,y,flag,i,j,box[4],line[4];
	appl_init();			/* initialise GEM AES arrays, return id */
	handle = graf_handle(&wchar,&hchar,&wbox, &hbox);	/* GEM VDI handle */
	v_opnvwk(work_in, &handle, work_out);	/* open virtual workstation */
	v_hide_c(handle);		/* hide mouse */
	v_clrwk(handle);		/* clear the screen */

/* draw the chessboard pattern */
	box[0] = 40;	box[1] = 0;		/* x,y */
	box[2] = 280;	box[3] = 199;	/* x,y */
	vsf_interior(handle,0);			/* set hollow (no) fill */
	v_bar(handle,box);				/* draw a bordered box */
	vsf_color(handle,1);			/* colour=black */
	vsf_interior(handle,2);			/* set patterned fill */
	vsf_style(handle,22);			/* choose pattern to fill */
	flag = 0;
	for ( y=0; y<200; y += 25 )	{ 	/* draw chessboard */
		flag ^= 1;
		for ( x=40+flag*40; x<280; x += 80 ) {
			box[0] = x;			/* top left x */
			box[1] = y;			/* top left y */
			box[2] = x+39;		/* bottom right x */
			box[3] = y+24;		/* bottom right y */
			v_bar(handle,box);	/* draw a bordered box */
		}
	}

/* draw a large circle in the middle of the screen */
	vsf_interior(handle,1);			/* set solid fill */
	vsf_color(handle,1);			/* colour=black */
	v_circle(handle,160,100,90);	/* draw circle */

/* print some text on the screen */
	vst_color(handle,1);	/* black text */
	vst_height(handle,10,&wchar,&hchar,&wbox,&hbox);	/* new text height */
	v_gtext(handle,86,95," Test Card ");				/* print some text */
	vst_height(handle,4,&wchar,&hchar,&wbox,&hbox);		/* new text height */
	v_gtext(handle,85,112," Click the mouse button! ");	/* ...more text */

/* print the bars */
	vsl_color(handle,0);		/* colour=white */
	vsl_width(handle,1);		/* line width=1 pixel */
	for ( y=-1; y<2; y+=2 ) {
		line[0] = 91;			/* start x */
		line[1] = 90 + y*32;	/* start y */
		line[2] = line[0];		/* end x */
		line[3] = line[1] + 20;	/* end y */
		for ( i=1; i<5; ++i )
			for ( j=0; j<14; ++j ) {
				v_pline(handle,2,line);	/* draw line */
				line[0] += i;
				line[2] += i;
			}
	}

/* draw the fill patterns */
	vsf_color(handle,1);			/* colour=black */
	for ( y=1; y<25; ++y )	{
		vsf_interior(handle,2);	/* set patterned fill */
		vsf_style(handle,y);	/* choose pattern to fill with*/
		box[0] = 0;				/* top left x */
		box[1] = y*8-4;			/* top left y */
		box[2] = 40;			/* bottom right x */
		box[3] = box[1] + 8;	/* bottom right y */
		v_rfbox(handle,box);	/* draw a filled rounded box */
		box[0] = 280;
		box[1] = y*8-4;
		box[2] = 319;
		box[3] = box[1] + 8;
		v_rfbox(handle,box);	/* draw another filled rounded box */
	}

/* draw the colour bars */
	vsf_interior(handle,1);		/* set solid fill */
	for ( i=1; i<16; ++i ) {
		vsf_color(handle,i);	/* set colour */
		box[0] = 24+i*16;		/* top left x */
		box[1] = 0;				/* top left y */
		box[2] = box[0] + 16;	/* bottom right x */
		box[3] = box[1] + 12;	/* bottom right y */
		vr_recfl(handle,box);	/* draw a filled borderless box */
		box[3] = 199;
		box[1] = box[3] - 12;
		vr_recfl(handle,box);	/* draw another filled borderless box */
	}

/* quit back to the desktop */
	wait();					/* wait for mouse click */
	v_show_c(handle,1);		/* show mouse */
	v_clsvwk(handle);		/* close virtual workstation */
	appl_exit();			/* tell GEM we've finished */
}


/***********************************/
/* wait until mouse button pressed */
/***********************************/
wait()						/* wait until mouse button pressed */
{
	short x, y, button;
	do {
		vq_mouse(handle, &button, &x, &y);	/* get mouse x,y,button state */
	} while ( button==0 );	/* wait until a button is pressed */
}
