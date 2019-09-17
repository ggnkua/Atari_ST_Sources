
/*			 graph.c			*/
/*	        graphic device primitives		*/
/*		    default attributes 			*/

int contrl[12];			/* arrays for communication to */
int intin[128];			/* and from GEM                */
int ptsin[128];
int intout[128];
int ptsout[128];

main()				/* beginning of program */

{
int handle, gr_1, i, dumvar1, l_intin[11], l_intout[57];
int pxy[4], x, y, rad, beg, end, xrad, yrad, xy[4];
int m_state, x1, x2, y1, y2;
				
appl_init();			/* initialization of application */

handle=graf_handle( &gr_1, &gr_1, &gr_1, &gr_1);  /* unique identifier */
v_hide_c( handle); 		/* hide mouse */
v_clrwk( handle);			/* clear screen */

l_intin[0] = 1;
for (i = 1; i < 10; i++)
    l_intin[i] =1;
l_intin[10] = 2;			/* RC coordinates */
v_opnvwk( l_intin, &handle, l_intout);  /* open virtual work station */

x1 = x2 = 50;		/* x and y coordinates for feedback */
y1 = 15;
y2 = 30;

v_clrwk( handle);			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "bar primitive" );
	pxy[0] = 130;	/* x-coordinate of corner of bar */
	pxy[1] = 80;    /* y-coordinate of corner of bar */
	pxy[2] = 500;   /* x-coordinate of opposite corner of bar */
	pxy[3] = 150;   /* y-coordinate of opposite corner of bar */
	v_bar( handle, pxy );	/* bar primitive function */

m_state = 0;
while ( m_state==0 )		/* wait for click on left side of mouse */
	vq_mouse( handle, &m_state, &x, &y );

for ( i=0; i<20000; i++ ) ; /* for timing loop to hold program */

v_clrwk( handle);			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "arc primitive" );

	x = 320;		/* x coordinate of center of arc */
	y = 100;	/* y coordinate of center of arc */
	rad = 150;	/* radius of arc in x coordinate points */
	beg = 0;	/* beginning of arc in tenths of degrees */
	end = 3000;	/* ending of arc in tenths of degrees */
	v_arc( handle, x, y, rad, beg, end);   /* arc prim. function call */
	
m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;
		
v_clrwk( handle);			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "pie slice primitive" );

	x = 320;		/* x coordinate of center of pieslice */
	y = 100;	/* y coordinate of center of arc */
	rad = 150;	/* radius of pieslice */
	beg = 0;	/* beginning of pieslice in tenths of degrees */
	end = 3000;	/* ending of pieslice in tenths of degrees */
	v_pieslice( handle, x, y, rad, beg, end);		
			/* pieslice prim. funct. call */
  
m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;

v_clrwk( handle);			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "circle primitive" );

	x = 320;		  /* x coordinate center for circle */
	y = 125;  		  /* y coordinate center for circle */
	rad = 100;		  /* radius in x coordinate points */
	v_circle( handle, x, y, rad );  /* circle primitive function call */
					
m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<2000; i++ ) ;

v_clrwk( handle);			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, " elliptical arc primitive" );
	x = 320;          /* x coordinate of center of elliptical arc */
	y = 120;          /* y coordinate of center of elliptical arc */
	xrad = 200;       /* radius of elliptical in x coordinate points */
	yrad = 30;       /* radius of elliptical in y coordinate points */
	beg = 0;        /* beginning angle of elliptical arc */
	end = 2700;        /* ending angle of elliptical arc */
	v_ellarc( handle, x, y, xrad, yrad, beg, end); 
  			   /* elliptical arc primitive function call */
m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;
 
v_clrwk( handle);			/* clear screen */
v_curhome( handle );
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "elliptical pie primitive" );
	x = 320;  /* x coordinate of center of elliptical pie */
	y = 120;  /* y coordinate of center of elliptical pie */
	xrad = 200;  /* radius of elliptical pie in x coordinate points */
	yrad = 30;  /* radius of elliptical pie in y coordinate points */
	beg = 0;   /* beginning angle of elliptical pie */
	end = 2700;   /* ending angle of elliptical pie */
	v_ellpie( handle, x, y, xrad, yrad, beg, end);
		
m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;

v_clrwk(handle);  			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "ellipse primitive" );

	x = 320;	/* x coordinate of center of ellipse */ 
	y = 125;	/* y coordinate of center of ellipse */
	xrad = 200;	/* radius of ellipse in x coordinate points */
	yrad = 10;	/* radius of ellipse in y coordinate points */
	v_ellipse( handle, x, y, xrad, yrad );  /* ellipse primitive function call */

m_state = 0; 
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;

v_clrwk( handle);			/* clear screen */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "rounded rectangle primitive" );
	
	xy[0] = 100;	/* x coordinate of one corner of rectangle */
	xy[1] = 50;  	/* y coordinate of one corner of rectangle */
	xy[2] = 540;	/* x coordinate of opposite corner of rectangle */
	xy[3] = 150;	/* y coordinate of opposite corner of rectangle */
	v_rbox( handle, xy ); /* rounded rectangle primitive function call */

m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;

v_clrwk(handle);  			/* clear workstation */
v_gtext( handle, x1, y1, "GENERALIZED DRAWING PRIMITIVE" );
v_gtext( handle, x2, y2, "rounded filled rectangle primitive" );

	xy[0] = 100;	/* see rounded rectangle primitive above */
	xy[1] = 50;
	xy[2] = 540;
	xy[3] = 150;			
	v_rfbox( handle, xy ); /* rounded filled rectangle primitive function call */

m_state = 0;
while ( m_state==0 )
	vq_mouse( handle, &m_state, &x, &y );
for ( i=0; i<20000; i++ ) ;
    
v_clsvwk(handle);  			/* close workstation */
appl_exit();				/* exit application */
_exit(0);
 }					/* end of program */
