/*	TCXXINFO.C / 8.3.92 / MATRIX / WA	*/

# define VERSION	1
# define RELEASE	0
# define DATE		"17.10.92"


# define COPYRIGHT		"MatGraph - TCxx - Info %d.%d / %s"
# define WASinstalled	"- TCxx - Info war bereits installiert !\n"
# define INSTerror		"- TCxx - Info Fehler # %d !\n"
# define COOKIEnotInstd	"- Cookie kann nicht installiert werden !\n"
# define PRESSreturn	"- Weiter mit RETURN !\n"


# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <tos.h>

# include <global.h>
# include <error.h>
# include <cookie.h>

# include "\pc\tcxx\lib\scr_def.h"
# include "\pc\tcxx\lib\brd_def.h"
# include "\pc\tcxx\lib\tab_def.h"
# include "\pc\tcxx\lib\tab_defv.h"
# include "\pc\tcxx\lib\e2p_def.h"
# include "tcxxinfo.h"
# include "tcxx_acc.h"

char mat_cookie[4] = MATtcCookie ;

SCREENparameter scr_par[2] =
{
	DEFscreenParameter,
	DEFscreenParameter
} ;

MEMORY vram = DEFvramParameter ;

BOARDparameter brd_par[2] =
{
	DEFboardParameter,
	DEFboardParameter
} ;

KERNEL		 kernel	 = DEFkernel ;

E2Pparameter e2p_par = DEFe2pParameter ;

TCXXparameterBlock tcxx_par = { VERSION, RELEASE, DATE,
								scr_par, brd_par,
								&tc_tab_block, &e2p_par } ;

int cookie_write_ok = 0 ;
int verbose ;

/*--------------------------------------- write_tcxx_cookie --------*/
long write_tcxx_cookie ( void )
{
	cookie_write_ok = CK_WriteJar ( *(long *)mat_cookie, (long)&tcxx_par ) ;
	return 0 ;
}


/*------------------------------------------------- usage ----------*/
void usage ( void )
{
	printf ( "usage : tcxxinfo [ -v ] [ -io io-base-address ]\n" ) ;
	exit ( NotOK ) ;
}

# define IOaddressMask	0xffffL


/*------------------------------------------------- update_address ----------*/
void update_address ( void *address, ulong io_address )
{
	if ( verbose > 1 )
		printf ( "$%p : $%p ->", address, *(ulong *)address ) ;
	*(ulong *)address = io_address | ( *(ulong *)address & IOaddressMask ) ;
	if ( verbose > 1 )
		printf ( " $%p\n", *(ulong *)address ) ;
}


/*------------------------------------------------- update_io_address ----------*/
void update_io_address ( BOARDparameter *ebrdpar, ulong io_address )
{
	if ( verbose > 1 )
		printf ( "\n+ update_io_address : \n" ) ;
	if ( io_address != 0 )
	{
		update_address ( &ebrdpar->config,		io_address ) ;
		update_address ( &ebrdpar->clock_reg,	io_address ) ;
		update_address ( &ebrdpar->i2c,			io_address ) ;
		update_address ( &ebrdpar->vector,		io_address ) ;
		update_address ( &ebrdpar->gsp,			io_address ) ;
		update_address ( &ebrdpar->ram_dac,		io_address ) ;
		update_address ( &ebrdpar->csc,			io_address ) ;
	}
	if ( verbose > 1 )
		printf ( "\n" ) ;
}


/*----------------------------------------------------- main -------*/
int main ( int argc, char *argv[] )
{
	int result ;
	char *ioa_end ;
	ulong io_address ;
	BOARDparameter *ebrdpar ;

	result  = OK ;
	verbose = 0 ;
	io_address = 0L ;

	while ( argc > 1 && result == OK )
	{
		argv++ ;
		argc-- ;
		if ( verbose > 1 )
			printf ( " %d-opt:'%s'", argc, *argv ) ;
		if ( (*argv)[0] == '-' )
		{
			switch ( (*argv)[1] )
			{
	case 'v' :	verbose++ ;
				break;
	case 'i' :	argv++ ;
				argc-- ;
				if ( argc > 0 )
				{
					if ( verbose > 1 )
						printf ( " %d-par:'%s'", argc, *argv ) ;
					io_address = strtoul ( *argv, &ioa_end, 0 ) ;
					if ( *argv == ioa_end )
					{
						printf ( "- illegal address : '%s'\n", *argv ) ;
						result = NotOK ;
					}
					if ( verbose > 1 )
						printf ( "\nioa : %p\n", io_address ) ;
				}
				else
				{
					printf ( "- no address parameter\n" ) ;
					result = NotOK ;
				}
				break ;
	default :	result = NotOK ;
				break ;
			}
		}
		else
		{
			printf ( "- illegal option : '%s'\n", *argv ) ;
			result = NotOK ;
		}
	}

	ebrdpar = &tcxx_par.brd_par[EDITparameter] ;
	
	if ( verbose )
		printf( COPYRIGHT "(%d)\n", VERSION, RELEASE, DATE, result ) ;

	if ( result == OK )
	{
		switch ( ( result = info_installed() ) )
		{
	 case NOinfo :	ebrdpar->v_ram  = &vram ;
					ebrdpar->kernel = &kernel ;

	 				update_io_address ( ebrdpar, io_address ) ;
			
					Supexec ( write_tcxx_cookie ) ;
					if ( cookie_write_ok )
						Ptermres ( _PgmSize, 0 ) ;
					else
						printf ( COOKIEnotInstd ) ;
					break ;
	
	 case OK :		printf ( WASinstalled ) ;
	 				update_io_address ( board_parameter, io_address ) ;
	 				break ;
	
	 default :		printf ( INSTerror, result ) ;
	 				break ;
	 	}
	} 	
	 	
	if ( verbose || result != OK )
	{
		usage () ;
		printf ( PRESSreturn ) ;
		getchar() ;
	}
	return ( OK ) ;
}