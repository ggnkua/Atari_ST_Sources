# define TEST 0
# if TEST
#include <ext.h>
# define tprintf(p) 	printf( "\033Y K" p ) ;		delay(1000)
# define tprintf2(p,q)	printf( "\033Y K" p, q ) ;	delay(1000)
# endif



# include <global.h>
# include <stdlib.h>
# include <stdio.h>
# include <string.h>
# include <ctype.h>

# include <global.h>

# include "\pc\cxxsetup\files.h"

# include "tdconfig.h"

CONFIGURATION configuration = {
	'?',			/*	in_window	*/
	'1',			/*	menu		*/
	"",				/*	picpath		*/
	{ 0, 0, 0, 0 },	/*	work window	*/
	0				/*	test		*/
} ;


/*------------------------------------------ load_config ----*/
int load_config ( char *cfg_name )
{
	FILE *cfg_file ;
	char line[128], *ss, *es ;
	
	cfg_file = fopen ( cfg_name, "r" ) ;	
	if ( cfg_file != NULL )
	{
# if TEST
		tprintf2 ( "%s open", cfg_name ) ;
# endif
	    while( fgets( line, (int)sizeof(line)-1, cfg_file ) != NULL )
	    {
# if TEST
			tprintf2 ( "'%s'", line ) ;
# endif
	    	if ( line[0] == '#' )
	    	{
	    		switch ( tolower ( line[1] ) )
	    		{
	    	case 't' :	/* #T<n>	*/
						configuration.test = atoi ( line+2 ) ;
						break ;
	    	case 'w' :	/* #W0|1|?	*/
						configuration.in_window = line[2] ;
						break ;
	    	case 'm' :	/* #M0|1	*/
						configuration.menu = line[2] ;
						break ;
	    	case 'r' :	/* 0123456789012345678901	*/
						/* #R 1234 1234 1234 1234 	*/
						ss = line + 2 ;
						          configuration.work.x = (int) strtol ( ss, &es, 10 ) ;
						ss = es ; configuration.work.y = (int) strtol ( ss, &es, 10 ) ;
						ss = es ; configuration.work.w = (int) strtol ( ss, &es, 10 ) ;
						ss = es ; configuration.work.h = (int) strtol ( ss, &es, 10 ) ;
# if TEST
						printf ( "\033Y K" "W=%c R={%4d,%4d,%4d,%4d}",
								configuration.in_window,
								configuration.work.x,
								configuration.work.y,
								configuration.work.w,
								configuration.work.h
								) ;
						delay(1000) ;
# endif
						break ;
	    	case 'p' :	/* #P path	*/
	    				for ( ss = line; *ss != 0; )
	    				{
	    					if ( *ss < ' ' )
	    						*ss = 0 ;
	    					else
	    						ss++ ;
	    				}
						strncpy ( configuration.picpath, line+3,
									STPATHLEN ) ;
						break ;
				}
			}
		}
    	fclose ( cfg_file ) ;
    	return ( OK ) ;
	}
	return 1 ;
}


/*------------------------------------------ save_config ----*/
int save_config ( char *cfg_name )
{
	FILE *cfg_file ;
	
	cfg_file = fopen ( cfg_name, "w" ) ;	
	if ( cfg_file != NULL )
	{
		fprintf ( cfg_file, "#W%c\n", configuration.in_window ) ;
		fprintf ( cfg_file, "#M%c\n", configuration.menu ) ;
		fprintf ( cfg_file, "#R%5d%5d%5d%5d\n",
								configuration.work.x,
								configuration.work.y,
								configuration.work.w,
								configuration.work.h ) ;
		fprintf ( cfg_file, "#P %s\n", configuration.picpath ) ;
		if ( configuration.test != 0 )
			fprintf ( cfg_file, "#W%d\n", configuration.test ) ;
    	fclose ( cfg_file ) ;
    	return ( OK ) ;
	}
	return 1 ;
}
	

