/*    Using the VDI     */
/* Monochrome Test Card */
/*  By R.A.Waddilove    */
/*    Lattice C v5      */

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
	handle = graf_handle(&wchar,&hchar,&wbox, &hbox); /* GEM VDI handle */
	v_opnvwk(work_in, &handle, work_out);	/* open virtual workstation */
	v_hide_c(handle);		/* hide mouse */
	v_clrwk(handle);		/* clear the screen */

/* draw the chessboard pattern */
	vsf_color(handle,1);			/* colour=black */
	vsf_interior(handle,0);			/* set hollow (no) fill */
	box[0] = 80;	box[1] = 0;		/* x,y */
	box[2] = 560;	box[3] = 399;	/* x,y */
	v_bar(handle,box);				/* draw a bordered filled box */
	vsf_interior(handle,2);			/* set patterned fill */
	vsf_style(handle,22);			/* choose fill pattern */
	flag = 0;
	for ( y=0; y<400; y += 50 )	{ 	/* draw chessboard */
		flag ^= 1;
		for ( x=80+flag*80; x<560; x += 160 ) {
			box[0] = x;		box[1] = y;
			box[2] = x+79;	box[3] = y+49;
			v_bar(handle,box);		/* draw another bordered filled box */
		}
	}

/* draw a large circle in the middle of the screen */
	vsf_interior(handle,1);			/* set patterned fill */
	v_circle(handle,320,200,180);

/* print some text on the screen */
	vst_color(handle,1);								/* black text */
	vst_height(handle,20,&wchar,&hchar,&wbox,&hbox);	/* new text height */
	v_gtext(handle,165,195," Atari ST User Test Card ");/* print some text */
	vst_height(handle,6,&wchar,&hchar,&wbox,&hbox);		/* new text height */
	v_gtext(handle,215,225," Click the mouse button! ");/* ...more text */

/* print the bars */
	vsl_color(handle,0);
	vsl_width(handle,1);
	for ( y=-1; y<2; y+=2 ) {
		line[0] = 180;					/* top left x */
		line[1] = 180 + y*64;			/* top left y */
		line[2] = line[0];				/* bottom right x */
		line[3] = line[1] + 40;			/* bottom right y */
		for ( i=1; i<8; ++i )
			for ( j=0; j<10; ++j ) {
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
		box[1] = y*16-8;		/* top left y */
		box[2] = 80;			/* bottom right x */
		box[3] = box[1] + 16;	/* bottom right y */
		v_rfbox(handle,box);	/* draw rounded filled box */
		box[0] = 560;
		box[1] = y*16-8;
		box[2] = 639;
		box[3] = box[1] + 16;
		v_rfbox(handle,box);	/* draw another rouded filled box */
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
wait(void)					/* wait until mouse button pressed */
{
	short x, y, button;
	do {
		vq_mouse(handle, &button, &x, &y);	/* get mouse x,y,button state */
	} while ( button==0 );	/* wait until a button is pressed */
	return(0);
}
