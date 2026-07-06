/************************************************************/
/*							    */
/*     3D GRAPHICS IN C. A PROGRAM TO SPIN A 3D IMAGE 	    */
/*							    */
/* An experiment to examine the efficiency of the compiler. */
/* This source file compiles with the Metacomco Lattice-C   */
/* compiler, and needs the GLIB library as well as CLIB.    */
/* It's just a re-work of the Assembler example GRAF3D.ASM  */
/* in C and to be honest, I'm suprised it's not much slower */
/* than the assembler version. HOWEVER it did cause a few   */
/* debugging problems whereas the assembler version worked  */
/* first time. (It did, honest, I didn't need SID at all.)  */
/*							    */
/*		by Andy Beveridge 1/4/86		    */
/*							    */
/************************************************************/
/* note the use of fixed point arithmetic for the trig calc */
/************************************************************/

#include	<stdio.h>
#include	<portab.h>
#include	<osbind.h>
#include	<math.h>

#define	ESC	27
#define	CX	320
#define	CY	200
#define	HORIZON	512

/* console key scan codes */

#define	SCANESC	0x01
#define	CLR	0x47
#define	UP	0x48
#define	LEFT	0x4b
#define	RIGHT	0x4d
#define	DOWN	0x50
#define	INSERT	0x52
#define	SCANS	0x1f

#define	NPOINTS	13

 WORD	xco[] = {-64, 64, 64,-64,-64, 64, 64,-64,-44,-44,  0, 44, 44} ;
 WORD	yco[] = {-64,-64, 64, 64,-64,-64, 64, 64, 44,-44, 20,-44, 44} ;
 WORD	zco[] = {-64,-64,-64,-64, 64, 64, 64, 64,-44,-44,-44,-44,-44} ;

 WORD	sintab[256],costab[256];

 WORD	order[] = { 0,1,1,2,2,3,3,0,4,5,5,6,6,7,7,4,0,
			4,1,5,2,6,3,7,8,9,9,10,10,11,11,12 };

 double	p2 = PI * 2;

 extern	a_init(), a_line(), a_color();	

cls()
{
	WORD	y;

	a_color(1);
	for(y=0; y<400; y++)
		a_line(0,y,639,y);
}

main()
{
	WORD	oldx[NPOINTS],oldy[NPOINTS],oldz[NPOINTS] ;
	WORD	newx[NPOINTS],newy[NPOINTS],newz[NPOINTS] ;
	WORD	x,y,z,p,r,sintheta,costheta;
	LONG	c,scalef;

	static	WORD	rx=0, ry=0, rz=0, xv=0, yv=1, zv=0;
	static	WORD	syncflag = 0;

	a_init();

	putch(ESC);	putch('E');	/* clear text screen */
	puts("Pre-calculating trig tables. Please wait...");

/* first build trig tables */	

	for(r=0;r<256;r++)
	{
		sintab[r] = (WORD) ( sin( (r*p2) / 256.0 ) * 127.0 );
		costab[r] = (WORD) ( cos( (r*p2) / 256.0 ) * 127.0 );
	}

	for(p=0; p<NPOINTS; p++)
	{
		oldx[p] = newx[p] = xco[p] + CX;
		oldy[p] = newy[p] = yco[p] + CY;
		oldz[p] = newz[p] = zco[p];
	}

	cls();	/* clear screen */
	c = 0;
    do
    {
	if( kbhit() )
	{
		c = Bconin( 2 ) >> 16;	/* get scancode from console */

		switch( c )
		{
			case CLR :
				if(zv > -8)
					zv--;	/* decrease Z axis rotation */
				break;
			case UP :
				if(xv > -8)
					xv--;	/* decrease X axis rotation */
				break;
			case LEFT :
				if(yv > -8)
					yv--;	/* decrease Y axis rotation */
				break;
			case RIGHT :
				if(yv < 8)
					yv++;	/* increase Y axis rotation */
				break;
			case DOWN :
				if(xv < 8)
					xv++;	/* increase X axis rotation */
				break;
			case INSERT :
				if(zv < 8)
					zv++;	/* increase Z axis rotation */
				break;
			case SCANS :		/* sync on-off toggle */
				syncflag = ~syncflag;	/* invert it */
				break;
			default :
				xv=yv=zv=0;	/* stop them all */
				break;
		} /* close the switch */
	}

/* calculate 3 new rotations */

	rx = (rx + xv) & 0x00ff;
	ry = (ry + yv) & 0x00ff;
	rz = (rz + zv) & 0x00ff;

	for(p=0; p<NPOINTS; p++)
	{
	/* rotate about Z axis */
		sintheta = sintab[rz];
		costheta = costab[rz];
		oldx[p] = newx[p]; oldy[p] = newy[p]; oldz[p] = newz[p];
		x = xco[p];	y = yco[p];	z = zco[p];
		newx[p] = (( x * costheta)>>7 ) + (( y * -sintheta)>>7);
		newy[p] = (( x * sintheta)>>7 ) + (( y *  costheta)>>7);
		newz[p] = z;

	/* rotate about X axis */
		sintheta = sintab[rx];
		costheta = costab[rx];
		x = newx[p];	y = newy[p];  z = newz[p];
		newx[p] = x;
		newy[p] = (( y * costheta)>>7 ) + (( z * -sintheta)>>7);
		newz[p] = (( y * sintheta)>>7 ) + (( z *  costheta)>>7);

	/* rotate about Y axis */
		sintheta = sintab[ry];
		costheta = costab[ry];
		x = newx[p];	y = newy[p];  z = newz[p];
		newx[p] = (( x *  costheta)>>7 ) + (( z *  sintheta)>>7);
		newy[p] = y;
		newz[p] = (( x * -sintheta)>>7 ) + (( z *  costheta)>>7);

		scalef = (HORIZON-128) - (long)newz[p];
		newx[p] = ( (long)newx[p] * scalef) / HORIZON;
		newy[p] = ( (long)newy[p] * scalef) / HORIZON;

		newx[p] += CX;
		newy[p] += CY;
	}

	if( syncflag )
		Vsync();	/* wait for video blanking ? */

/* undraw old */
	a_color(1);
	for(p=0; p<32; p+=2)
	{
		x = order[p]; y = order[p+1];
		a_line( oldx[x],oldy[x],oldx[y],oldy[y] );
	}

/* draw new */
	a_color(0);
	for(p=0; p<32; p+=2)
	{
		x = order[p]; y = order[p+1];
		a_line( newx[x],newy[x],newx[y],newy[y] );
	}

    } while( c != SCANESC );

} /* end program */
