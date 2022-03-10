/*
**	File:	infocom.c
**
**	(C)opyright 1987-1992 InfoTaskforce.
*/

#include	"infocom.h"

int
main ( argc,argv )
int		argc ;
char	*argv[] ;
{
	extern boolean	attribute ;
	extern boolean	echo_in ;
	extern boolean	enhanced ;
	extern boolean	page_out ;
	extern boolean	pre_load ;
	extern boolean	xfer ;
	extern boolean	stop ;
	extern int		sig_async ;
	extern int		sig_action ;

	word			opt		= NO_OPTIONS ;
	int				i ;

	--argc ;
	if (( argc == 1 ) || ( argc == 2 ))
	{
		if ( argc == 2 )
		{
			if ( argv[1][0] == '-' )
			{
				i = 0 ;
				while ( argv[1][++i] != '\0' )
				{
					switch ( argv[1][i] )
					{
						case 'a':
									attribute = TRUE ;
									break ;
						case 'e':
									echo_in = TRUE ;
									break ;
						case 'h':
									opt |= HEAD_INFO ;
									break ;
						case 'l':
									pre_load = TRUE ;
									break ;
						case 'n':
									enhanced = TRUE ;
									break ;
						case 'o':
									opt |= OBJECTS ;
									break ;
						case 'p':
									page_out = TRUE ;
									break ;
						case 'r':
									opt |= TREE ;
									break ;
						case 's':
									opt |= SHOW_PROPS ;
									break ;
						case 't':
									xfer = TRUE ;
									break ;
						case 'v':
									opt |= VOCABULARY ;
									break ;
						case 'x':
									opt |= EXTENDED_VOCAB ;
									break ;
						default :
									printf ( "Unrecognised Option: %c\n",argv[1][i] ) ;
					}
				}
			}
			else
				usage ( argv[0] ) ;
		}
		INIT_SIGNAL () ;
		if ( open_file ( argv[argc] ) )
		{
			if ( stop == FALSE )
			{ /* Level 1 patch installed  -mlk */
				INIT_IO () ;
				init () ;
				init_script () ;
				if ( opt )
				{
					sig_async = SH_NO_IO ;
					if ( sig_action != SH_NO_SIGNAL )
						SIGNAL_QUIT ( sig_action ) ;
					options ( opt ) ;
					sig_async = SH_EXIT ;
					deallocate () ;
				}
				else
				{  /* level 1 patch installed  -mlk */
					if ( stop == FALSE )
					{
						init_interpreter ( TRUE ) ;
						sig_async = SH_NORMAL ;
						if ( sig_action != SH_NO_SIGNAL )
							SIGNAL_QUIT ( sig_action ) ;
						execute_opcode () ;
					}
					sig_async = SH_EXIT ;
					deallocate () ;
					EXIT_IO () ;
				}
			}
			close_script () ;
			close_file () ;
		}
		else
			printf ( "Failed to Open File %s\n",argv[argc] ) ;
	}
	else
		usage ( argv[0] ) ;
	if ( sig_action != SH_NO_SIGNAL )
		SIGNAL_QUIT ( sig_action ) ;

	return ( 0 ) ;
}

Void
usage ( program_name )
char	*program_name ;
{
	printf ( "Usage: %s [-aehlnoprstvx] <filename>\n",program_name ) ;
	exit ( 0 ) ;
}
