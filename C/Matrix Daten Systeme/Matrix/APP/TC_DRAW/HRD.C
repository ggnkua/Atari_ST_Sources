/* hrd.c */

# include <stdio.h>
# include <string.h>

int ok = 1 ;

/*-------------------------------------------- iow -------------*/
void iow ( FILE *bf, FILE *tf, int n )
{
	int c0, c1 ;
	
	while ( n-- > 0 )
	{
		c0 = fgetc ( bf ) ;
		c1 = fgetc ( bf ) ;
		if ( c0 == EOF || c1 == EOF )
		{
			ok = 0 ;
			return ;
		}
		else
			fprintf ( tf, " %04x", ( c0 << 8 ) | ( c1 & 0xff ) ) ;
	}
}


/*-------------------------------------------- iob -------------*/
void iob ( FILE *bf, FILE *tf, int n )
{
	int c ;

	while ( n-- > 0 )
	{
		c = fgetc ( bf ) ;
		if ( c == EOF )
		{
			ok = 0 ;
			return ;
		}
		fprintf ( tf, " %02x", c ) ;
	}
}


/*-------------------------------------------- ios -------------*/
int ios ( FILE *bf, FILE *tf )
{
	int i, c ;
	
	for ( i = 0 ; ; i++ )
	{
		c = fgetc ( bf ) ;
		if ( c == EOF )
		{
			ok = 0 ;
			return i ;
		}
		if ( c == 0 )
			return i ;
		fprintf ( tf, "%c", c ) ;	
	}
}

/*-------------------------------------------- sios -------------*/
char *sios ( char *buffer, FILE *bf )
{
	int c, i ;
	char *buf ;
	
	for( buf = buffer, i = 0 ; ; i++ )
	{
		c = *buf++ ;
		if ( c <= ' ' )
			break ;
		fputc ( c, bf ) ;
	}
	fputc ( 0, bf ) ;
	if ( i > 8 )
		printf ( "size error '%s', l = %d\n", buffer, i ) ;
	return buf ;
}

/*-------------------------------------------- siow -------------*/
void siow ( char *buffer, FILE *bf, int n )
{
	int i ;

	while ( n-- > 0 )
	{
		i = (int)strtol ( buffer, &buffer, 16 ) ;
		fputc ( i >> 8,   bf ) ;
		fputc ( i & 0xff, bf ) ;
	}
}

/*--------------------------------------------- usage ---------------*/
void usage ( void )
{
	printf ( "usage : hrd in out\n   in / out = n.txt / n.hrd\n" ) ;
	printf ( "- press Return !\n" ) ;
	getchar();
}

/*--------------------------------------------- main ---------------*/
int main(int argc,char *argv[])
{
	FILE *hrd_file, *txt_file ;
	
	printf ( "HRD<->TEXT conversion / " __DATE__ " / " __TIME__ "\n" ) ;

	if ( argc != 3 )
	{
		usage () ;
		return 0 ;
	}

	strlwr ( argv[1] ) ;
	strlwr ( argv[2] ) ;
	
	if ( strstr ( argv[1], ".txt" ) && strstr ( argv[2], ".hrd" ) )
	{
		printf ( "text -> hrd\n" ) ;
		txt_file = fopen ( argv[1], "r" ) ;
		if ( txt_file != NULL )
		{ 
			hrd_file = fopen ( argv[2], "wb" ) ;
			if ( hrd_file != NULL )
			{
				char buffer[128] ;
				char *end ;
				
				if ( fgets ( buffer, 128, txt_file ) != NULL )
				{
					siow ( buffer, hrd_file, 6 ) ;

					while ( fgets ( buffer, 128, txt_file ) != NULL )
					{
						siow ( buffer, hrd_file, 1 ) ;
						if ( buffer[8] == '-' )
						{
							fputc ( 0, hrd_file ) ;	/* int 0	*/
							break ;
						}

						end = sios ( &buffer[8], hrd_file ) ;
						siow ( end, hrd_file, 2 ) ;
					}
				}
				else
					printf ( "- can't read %s\n", argv[1] ) ;
				fclose ( txt_file ) ;
			}
			else
				printf ( "- can't create %s\n", argv[2] ) ;
			fclose ( hrd_file ) ;
		}
		else
			printf ( "- can't open %s\n", argv[1] ) ;
	}
	else if ( strstr ( argv[1], ".hrd" ) && strstr ( argv[2], ".txt" ) )
	{
		printf ( "hrd -> text\n" ) ;
	
		hrd_file = fopen ( argv[1], "rb" ) ;
		if ( hrd_file != NULL )
		{ 
			txt_file = fopen ( argv[2], "w" ) ;
			if ( txt_file != NULL )
			{
				iow ( hrd_file, txt_file, 6 ) ;
				fprintf ( txt_file, "\n" ) ;
				for ( ;; )
				{
					iow ( hrd_file, txt_file, 1 ) ;
					if ( ! ok )	break ;
					fprintf ( txt_file, " : " ) ;
					if ( ios ( hrd_file, txt_file ) == 0 )
					{
						fprintf ( txt_file, "---\n" ) ;
						break ;
					}
					if ( ! ok )	break ;
					fprintf ( txt_file, "            " ) ;
					iow ( hrd_file, txt_file, 2 ) ;
					fprintf ( txt_file, "\n" ) ;
					if ( ! ok )	break ;
				}
				fclose ( txt_file ) ;
			}
			else
				printf ( "- can't create %s\n", argv[2] ) ;
			fclose ( hrd_file ) ;
		}
		else
			printf ( "- can't open %s\n", argv[1] ) ;
	}
	else
	{
		usage () ;
		return 0 ;
	}

	return ( 0 ) ;
}