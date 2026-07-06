/******************************************************************
* a C library test set. Watch out for data sizes. All pointers in *
* arg lists of GEM functions must be 16 bit WORD's                *
* BYTE, WORD, LONG etc are defined in the portab.h include file   *
******************************************************************/


#include	<stdio.h>
#include	<gemlib.h>	/* assorted useful GEM macro's    */
#include	<portab.h>	/* include type def macro's etc   */

/* #include	<osbind.h> */	/* get osbind macros		  */
/* #include	<fcntl.h>  */	/* include file control header	  */

#define	MYLINE 0x5abc		/* a user defined line style mask */

/* GLOBALS needed below */
 WORD phys_handle,handle,dummy;
 WORD pxyarray[4];


setpxy(x1,y1,x2,y2)
WORD	x1,y1,x2,y2;
{
	pxyarray[0] = x1;	/* set global points array   */
	pxyarray[1] = y1;	/* from data points supplied */
	pxyarray[2] = x2;
	pxyarray[3] = y2;
}

line(x1,y1,x2,y2)
WORD	x1,y1,x2,y2;
{
	pxyarray[0]=x1;
	pxyarray[1]=y1;
	pxyarray[2]=x2;
	pxyarray[3]=y2;			/* set-up array for v_pline() */

	v_pline(handle,2,pxyarray);	/* call polyline to draw line */
	/* that was ( handle, npoints, array_of_points ) */
}

line_test()
{
	int   j; 			/* loop counter*/

	vsl_udsty(handle,MYLINE);	/* define user def. line  (No 7)   */

	/* polymarkers are point marker shapes for graphs etc */
	vsm_type(handle,4);		/* use square polymarker (1 to 6)  */
	vsm_height(handle,10);		/* and make it nice and big.       */
	vsm_color(handle,BLACK);	/* set marker color	           */

	for(j=1;j<8;j++){		/* draw lines with diff attributes */
	   vsl_type(handle,j);		/* try each line style             */
	   vsl_color(handle,j);		/* won't be much use in monochrome */
	/* You can set line termination style too */
	   vsl_ends(handle,j-1,j-1);	/* N.B: there are only 3 end types */
	   line( 10, j*10+10, 100, j*10+10 );	/* draw a line */
	   v_pmarker( handle, 2, pxyarray );	/* mark ends   */
	/* v_pmarker has same syntax as v_pline */
	}

	vsl_color(handle,BLACK);	/* reset */
	vsl_type(handle,SOLID);		/* and line type */
	vsl_ends(handle,ARROWED,ARROWED); /* set end type for thickness loop */

	for(j=1;j<10;j+=2){			/* i.e. for 1,3,5,7,9   */
	/* you can select line thickness too */
		vsl_width(handle,j);		/* set thickness        */
		line(105,j*10+10,195,j*10+10);	/* draw a line */
	}

	vsl_ends(handle,SQUARED,SQUARED);
	vsl_width(handle,1);	/* reset the width in case it's used again */

}

circ_test()
{
	int   radius,k;

	/* vsf_ functions select fill attributes */

	vsf_interior(handle,PATTERN);	/* tell gem to pattern fill */
	vsf_color(handle,BLACK);	/* in fill color black	*/

	for(k=10;k>0;k--){
		vsf_style(handle,k);		/* set fill pattern */
		radius=k*10;
		v_circle( handle, radius + 2, 200, radius );
	}
}

box_test()
{
	setpxy( 320, 5, 635, 395 );

	vsf_color( handle, BLACK );
	vsf_interior( handle, SOLID );
	v_bar( handle, pxyarray );	/* do a rectangle (no border) */

	setpxy(330,15,625,385);

	vsf_interior(handle,PATTERN);
	vsf_style(handle,DOTS);
 	vr_recfl(handle,pxyarray);	/* filled rectangle */

	setpxy(340,25,615,375);

	vsf_style(handle,BRICKS);
	v_rfbox(handle,pxyarray);	/* try a rounded & filled box */

	vsf_interior(handle,HATCH);
	vsf_style(handle,GRID);
	v_ellipse( handle, 479, 330, 150, 40 );	/* put filled ellipse */
	/* that was xpos, ypos, xradius, yradius */

}

arc_test()
{
	int   radius, revs, da, ang;

	radius = 10;		/* start with a radius of 10    */
	da = 450;		/* delta-angle for spiral steps */
	/* note: GEM angles are in tenths of a degree */

	vswr_mode(handle,MD_REPLACE);	/* make sure we're in replace mode */
	/* vswr_mode sets writing mode to one of 4 */

	vsl_width(handle,3);	/* use fairly thick lines */

/* now draw the spiral */

	for(revs=0;revs<6;revs++){
		for(ang=0;ang<3600;ang+=da){
			v_arc(handle,225,320,radius,ang,ang+da);
			radius++;
		}
	}

	vsl_width(handle,1);	/* re-set it in case used elsewhere */
}

pie_test()
{
	int   nsegs,da,ang,seg;

	vsf_interior(handle,HATCH);

	/* making pies has never been easier */

	nsegs = 12;		/* No. of segments in pie */
	da = 3600 / nsegs;	/* angle for each segment */

	for(seg=0;seg<nsegs;seg++){
		ang = seg*da;
		vsf_style(handle,seg+2);
		v_pieslice(handle,472,100,90,ang,ang+da);
	}
}

text_test()	
{

	int   s;		/* somewhere to put returned values */

/* load fonts not implemented in current ST GEM */
/*	s = vst_load_fonts(handle,0);
	printf(" %d extra fonts loaded.\n",s);  */

	vswr_mode(handle,MD_TRANS);	/* writing mode so only fg drawn */

	vst_height(handle,50,&dummy,&dummy,&dummy,&dummy);  /* BIG */
	s = vst_color(handle,BLACK);	/* text color */

	v_gtext(handle,390,200,"Metacomco!"); /* print text at x,y */

	vswr_mode(handle,MD_XOR);	/* change writing mode to XOR */

	vst_height(handle,100,&dummy,&dummy,&dummy,&dummy); /* BIGGER */
	s = vst_effects(handle,SKEWED);	/* make it skewed */
	v_justified( handle, 380, 355, "Hi There!", 180, 1, 1 );
	/* justified text is fill justified to required length (180) */
}

fill_test()
{
	vsf_interior(handle,HATCH);
	vsf_style(handle,GRID);
	vsf_color(handle,BLACK);
	v_contourfill(handle,5,5,-1);
/* that last value is the boundary color. -1 implies any color change is
   to be regarded as a boundary condition */
}

gem_close()
{

	/* anything to do just before finishing should go here */


	v_clsvwk(handle);	/* close virtual workstation */

}

gem_init()
{
	WORD  i;
	WORD  work_in[11],work_out[57];

	/* NOTE: if the data out from opnvwk() */
	/* is needed elsewhere it may be more  */
	/* convenient to declare it as an      */
	/*   external static or global         */

	appl_init();	/* open the application (tell GEM AES were here) */

	/* find system handle ... */
	phys_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);

	handle=phys_handle;	/* handle will contain our vdi handle */
	/* use this handle for all future VDI calls */

	for(i=0;i<10;i++)
		work_in[i] = 1;	/* set all defaults before we open it */
	work_in[10] = 2;	/* use raster co-ordinates */

	v_opnvwk(work_in,&handle,work_out);	/* open the workstation */

	v_hide_c(handle);			/* hide the mouse	*/
	v_clrwk(handle);			/* clear workstation	*/
	v_show_c(handle,1);			/* show the mouse again	*/

	/* turn clipping on to stop screen overflow... */
	setpxy(0,0,639,399);
	vs_clip(handle,TRUE,pxyarray);		/* clip full screen */

}

main()
{
	WORD	c;

	gem_init();	/* initialise a virtual workstation */

	line_test();	/* test polyline and polymarker f's */

	circ_test();	/* test circle & ellipse primitives */

	box_test();	/* test assorted square primitives  */

	arc_test();	/* test arc functions */

	pie_test();  	/* test pie segment functions */

	text_test();	/* test text related GEM functions  */

	fill_test();	/* test contour fill op */

	putchar(7);	/* ring bell */

	do {
		vq_mouse(handle,&c,&dummy,&dummy);
	/* reads mouse buttons (bits 0 & 1), xpos, ypos respect. */

	} while( !c );		/* loop until button pressed */

	gem_close();	/* close up the workstation */

}			/* before we exit */
