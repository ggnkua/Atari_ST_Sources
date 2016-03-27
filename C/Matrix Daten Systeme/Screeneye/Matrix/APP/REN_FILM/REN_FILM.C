# include <stdio.h>
# include <tos.h>
# include <ext.h>

char *new_name = "a.tga" ;

int main ( void )
{
	int result ;
	DTA  dta ;
	int n, handle ;
	
	if ( ( Dsetdrv ( 2 ) & (1<<2) ) != 0 )
	{
		if ( Dsetpath( "\\film" ) == 0 )
		{

			Fsetdta ( &dta ) ;
	
			result = Fsfirst ( "*.tga", 0 ) ;
			for ( n = 1; result == 0; n++ )
			{
				printf ( "%3d : %s -> %s\n", n, dta.d_fname, new_name ) ;
				
				printf ( "Fopen : %d\n", handle = Fopen ( dta.d_fname, FO_READ ) ) ;
				Fclose ( handle ) ;
				printf ( "\n any key !\n" ) ;	getch();
				
				printf ( "rename : %d\n", (int)Frename ( 0, dta.d_fname, new_name ) );
				printf ( "\n any key !\n" ) ;	getch();
				result = Fsnext ( ) ;
				(*new_name)++ ;
			}
		}
		else
			printf ( "? Dsetpath\n" ) ;
	}
	else
		printf ( "? Dsetdrv\n" ) ;
	
	printf ( "\n any key !\n" ) ;	getch();
	return 0 ;
}
 