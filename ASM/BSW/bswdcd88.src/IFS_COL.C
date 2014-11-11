#include <stdlib.h>
#include <math.h>
#include <tos.h>

typedef enum
{
	FALSE,
	TRUE
}boolean;

#define NO (void*)-1

extern void plot(int x, int y);
extern void init(void);
extern void bye(void);
extern void cls_plane3(void);

extern int quit;

float ifscodes[20][6];
float ifsp[20];
int ifsmax, iter;
int xoffset, yoffset;
float xscale, yscale;

float ifsdet( int t )
{
	float d;
	
	d = (float)fabs( (double) ( ifscodes[t][0] * ifscodes[t][3] -
						   		ifscodes[t][1] * ifscodes[t][2] ) );
	if ( d == 0.0 )
		d = 0.01;
	return( d );
}

boolean calcprob(void)
{
	int i;
	float sum, pc;
	float p[20];
	
	sum = 0.0;
	for ( i = 0; i <= ifsmax; i++ )
		sum += ifsdet(i);
	pc = 0.0;
	for ( i = 0; i <= ifsmax; i++ ) {
		p[i] = ifsdet(i) / sum;
		pc += p[i];
		ifsp[i] = pc;
	}
	for ( i = 0; i < ifsmax; i++ )
		if ( fabs( (double) ( p[i] - p[i+1] ) ) > 0.01 )
			return(FALSE);
	return(TRUE);
}


void iterate( float *x, float *y )
{
	float rnd, newx, newy;
	int i;
	
	rnd = (float) ( random( 10000 ) / 10000.0 );
	i = -1;
	do {
		i++;
	} while ( ! ( rnd < ifsp[i] ) );
	newx = ifscodes[i][0] * *x + ifscodes[i][1] * *y + ifscodes[i][4];
	newy = ifscodes[i][2] * *x + ifscodes[i][3] * *y + ifscodes[i][5];
	*x = newx;
	*y = newy;
}

void iterdraw(void)
{
	float x, y;
	int i;
	
	x = y = 0.0;
	for ( i = 0; i <= 19; i++ )
		iterate( &x, &y );
	for ( i = 0; i < iter; i++ ) {
		iterate( &x, &y );
		plot( (int) ( x * xscale ) + xoffset,
		      (int) ( y * yscale ) + yoffset);
		if ( quit != 0 )
			return;
	}
}

void recus( int i, float x, float y )
{
	float newx, newy;
	int j;
	
	if ( i > 0 ) {
		for ( j = 0; j <= ifsmax; j++ ) {
			newx = ifscodes[j][0] * x + ifscodes[j][1] * y + ifscodes[j][4];
			newy = ifscodes[j][2] * x + ifscodes[j][3] * y + ifscodes[j][5];
			recus( i-1, newx, newy );
		}
	}
}

void ifs(int nr)
{

	switch( nr ) {
	case 0:
	
/* Sierpinsky-Pfeilspitze */	

	ifsmax = 3 - 1;
	iter = 3000;
	xoffset = 60;
	yoffset = 60;
	xscale = 100.0;
	yscale = 100.0;
	
	ifscodes[0][0] = 0.500;
	ifscodes[0][1] = 0.000;
	ifscodes[0][2] = 0.000;
	ifscodes[0][3] = 0.500;
	ifscodes[0][4] = 0.000;
	ifscodes[0][5] = 0.000;
	
	ifscodes[1][0] = 0.500;
	ifscodes[1][1] = 0.000;
	ifscodes[1][2] = 0.000;
	ifscodes[1][3] = 0.500;
	ifscodes[1][4] = 1.000;
	ifscodes[1][5] = 0.000;
	
	ifscodes[2][0] = 0.500;
	ifscodes[2][1] = 0.000;
	ifscodes[2][2] = 0.000;
	ifscodes[2][3] = 0.500;
	ifscodes[2][4] = 0.500;
	ifscodes[2][5] = 0.500;
	break;

	case 1:
/* Drachenfl„che */

	ifsmax = 2 - 1;
	iter = 5000;
	xoffset = 136;
	yoffset = 75;
	xscale = 50.0;
	yscale = 50.0;
		
	ifscodes[0][0] = 0.500;
	ifscodes[0][1] = -.500;
	ifscodes[0][2] = 0.500;
	ifscodes[0][3] = 0.500;
	ifscodes[0][4] = 0.000;
	ifscodes[0][5] = 0.000;
	
	ifscodes[1][0] = 0.500;
	ifscodes[1][1] = -.500;
	ifscodes[1][2] = 0.500;
	ifscodes[1][3] = 0.500;
	ifscodes[1][4] = 1.000;
	ifscodes[1][5] = 0.000;
	break;

	case 2:
/* Schneeflocke */

	ifsmax = 6 - 1;
	iter = 6000;
	xoffset = 40;
	yoffset = 60;
	xscale = 40.0;
	yscale = 40.0;
	
	ifscodes[0][0] = 0.333;
	ifscodes[0][1] = 0.000;
	ifscodes[0][2] = 0.000;
	ifscodes[0][3] = 0.333;
	ifscodes[0][4] = 0.000;
	ifscodes[0][5] = 0.000;
	
	ifscodes[1][0] = 0.333;
	ifscodes[1][1] = 0.000;
	ifscodes[1][2] = 0.000;
	ifscodes[1][3] = 0.333;
	ifscodes[1][4] = 4.000;
	ifscodes[1][5] = 0.000;
	
	ifscodes[2][0] = 0.167;
	ifscodes[2][1] = -.500;
	ifscodes[2][2] = 0.167;
	ifscodes[2][3] = 0.167;
	ifscodes[2][4] = 1.000;
	ifscodes[2][5] = 1.000;

	ifscodes[3][0] = 0.167;
	ifscodes[3][1] = 0.500;
	ifscodes[3][2] = -.167;
	ifscodes[3][3] = 0.167;
	ifscodes[3][4] = 4.000;
	ifscodes[3][5] = 2.000;
	
	ifscodes[4][0] = 0.333;
	ifscodes[4][1] = 0.000;
	ifscodes[4][2] = 0.000;
	ifscodes[4][3] = 0.333;
	ifscodes[4][4] = 2.000;
	ifscodes[4][5] = 2.000;
	
	ifscodes[5][0] = -.333;
	ifscodes[5][1] = 0.000;
	ifscodes[5][2] = 0.000;
	ifscodes[5][3] = -.333;
	ifscodes[5][4] = 4.000;
	ifscodes[5][5] = 0.000;
	break;
	
	case 3:
/* Farnblatt */

	ifsmax = 4 - 1;
	iter = 5000;
	xoffset = 160;
	yoffset = 10;
	xscale = 17.0;
	yscale = 17.0;
		
	ifscodes[0][0] = 0.000;
	ifscodes[0][1] = 0.000;
	ifscodes[0][2] = 0.000;
	ifscodes[0][3] = 0.160;
	ifscodes[0][4] = 0.000;
	ifscodes[0][5] = 0.000;
	
	ifscodes[1][0] = 0.200;
	ifscodes[1][1] = -.260;
	ifscodes[1][2] = 0.230;
	ifscodes[1][3] = 0.220;
	ifscodes[1][4] = 0.000;
	ifscodes[1][5] = 1.600;
	
	ifscodes[2][0] = -.150;
	ifscodes[2][1] = 0.280;
	ifscodes[2][2] = 0.260;
	ifscodes[2][3] = 0.240;
	ifscodes[2][4] = 0.000;
	ifscodes[2][5] = 0.440;

	ifscodes[3][0] = 0.850;
	ifscodes[3][1] = 0.040;
	ifscodes[3][2] = -.040;
	ifscodes[3][3] = 0.850;
	ifscodes[3][4] = 0.000;
	ifscodes[3][5] = 1.600;
	break;
	
	case 4:
/* Spirale */

	ifsmax = 2 - 1;
	iter = 5000;
	xoffset = 90;
	yoffset = 30;
	xscale = 12.0;
	yscale = 15.0;
		
	ifscodes[0][0] = 0.779;
	ifscodes[0][1] = -.294;
	ifscodes[0][2] = 0.257;
	ifscodes[0][3] = 0.824;
	ifscodes[0][4] = 3.148;
	ifscodes[0][5] = 0.342;
	
	ifscodes[1][0] = -.273;
	ifscodes[1][1] = -.294;
	ifscodes[1][2] = 0.079;
	ifscodes[1][3] = -.235;
	ifscodes[1][4] = 11.716;
	ifscodes[1][5] = 2.599;
	break;	
	} /*switch*/
				
	calcprob();
	iterdraw();
}

int main(void)
{
	int nr;
	int file_nr;	
	
	init();
	nr = 0;
	while ( quit == 0 ) {
		cls_plane3();
		ifs(nr++);
		if ( nr == 5 )
			nr = 0;
	}
	file_nr = quit;
	bye();
	return( file_nr );
}

		