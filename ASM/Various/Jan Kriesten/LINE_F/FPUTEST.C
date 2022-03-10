/* 		Kurzer Funktionstest fÅr LFED 
		Smart Systems 03/92				
*/
					
#include <math.h>
#include <time.h>
#include <ext.h>
#include <stdio.h>

int main( void )
{
	double	sinus, cosinus, tangens, lauf_var;
	long	zeit, zaehler;
	
	zaehler = 0L;
	zeit    = clock( );
	
	for( lauf_var=0; lauf_var<=2*M_PI; lauf_var+=0.0001 )
	{
		++zaehler;
		cosinus = cos( lauf_var );
		sinus   = sin( lauf_var );
		tangens = tan( lauf_var );
	};
			
	zeit = clock( ) - zeit;
	printf( "\nLaufzeit mit FPU: %.2f Sekunden (%ld Ticks)", zeit / 200., zeit );
	printf( "\nfÅr %ld DurchlÑufe", zaehler);
	printf( "\n\nInhalte der Variblen:\n\nCosinus: %.16f\nSinus: %.16f\nTangens: %.16f\n", cosinus, sinus, tangens ); 
	getchar( );

	return( 0 );
};
