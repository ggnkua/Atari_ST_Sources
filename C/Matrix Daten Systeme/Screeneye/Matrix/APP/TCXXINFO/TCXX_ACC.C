/*
		tcxx_acc.c : MATRIX TCxx access parameter blocks

        (c) MATRIX Daten Systeme GmbH 1992
*/
	

# include <stddef.h>
# include <tos.h>

# include <global.h>
# include <readcook.h>

# include "..\lib\brd_par.h"

# define NOinfo				17	/*	s. lib\error.h */
# define NOTinitialised		18	/*	s. lib\error.h */

typedef void SCREENparameter ;	/*	s. lib\scr_def.h */
typedef void TCXXtables ;		/*	s. lib\tab_def.h */
typedef void E2Pparameter ;		/*	s. lib\e2p_def.h */

# include "tcxxinfo.h"
# include "tcxx_acc.h"

SCREENparameter *screen_parameter = NULL ;
BOARDparameter  *board_parameter  = NULL ;
TCXXtables	    *tcxx_tables	  = NULL ;
E2Pparameter	*e2prom_parameter = NULL ;

TCXXparameterBlock *tcxx_parameter = NULL ;


/*--------------------------------------- info_installed -----------*/
int info_installed ( void )
{
	if ( tcxx_parameter == NULL )
	{
		if ( read_cookie ( MATtcCookie, (long *)&tcxx_parameter ) != NULL )
		{
			screen_parameter = tcxx_parameter->scr_par ;
			board_parameter  = tcxx_parameter->brd_par ;
			tcxx_tables		 = tcxx_parameter->tables ;
			e2prom_parameter = tcxx_parameter->e2p_par ;
		}
		else
		{
			return ( NOinfo ) ;
		}
	}
	return ( OK ) ;
}

/*--------------------------------------- tcxx_initialised --------*/
int tcxx_initialised ( void )
{
	int result ;
	
	result = info_installed() ;
	if ( result == OK && board_parameter->init_state == NOinit )
		result = NOTinitialised ;
	return ( result ) ;
}
