#include <stdio.h>

void main( void )
{
	long	a, b;

	for ( a = 8193; a < 16387; a += 2 )
	{
		for ( b = a >> 1; b > 1; --b )
		{
			if (( a % b ) == 0 )
			{
				break;
			}
		}
		if ( b == 1 )
		{
			printf( "%ld is prime\n", a );
		}
	}
}
