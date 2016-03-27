/********************************************************************/
/* 				MATdigi - VMEbus Module								*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 25.08.92												*/
/*																	*/
/*  HDG - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

/* The True-Color board must have been initialised before the routine
   chk_vme() is called, otherwise the 12c bus on the TC card will not
   be found.
*/

# include <stdio.h>
# include <stdlib.h>
# include <ext.h>
# include <tos.h>

# include <global.h>
# include <access.h>

# include <brd_def.h>
# include <i2c_hdg.h>

# include "md_vme.h"

/*- Variables -*/
bool		vme_found  = FALSE;
byte		*i2c_bus ;
int dummy_MD = ILLhardware ;
extern int	verbose ;

# if 000000
int *MDversion = &dummy_MD ;
# else
int md_1 = 1 ;
int *MDversion = &md_1 ;
# endif

/* ============================================================== */

/*------------------------------------------- check_i2c -----------*/
bool check_i2c (void)
# define DMSDsa 0x8E
{
	byte	dp[2] = {0, 0x50} ;
	
	i2c_release ( i2c_bus ) ;
	if ( i2c_write( i2c_bus, DMSDsa, 2, dp) != 0 )
	{
		if ( verbose )
			printf ( "i2c not found" ) ;
		i2c_bus   = NULL ;
		MDversion = &dummy_MD ;
		return ( FALSE ) ;
	}
	if ( verbose )
		printf ( "i2c found at 0x%p", i2c_bus ) ;
	return ( TRUE ) ;
}


/*------------------------------------------- chk_vme -----------*/
bool chk_vme (void)
{
	i2c_bus   = board_parameter->i2c ;
# if 000000
	MDversion = (int *)( board_parameter->i2c + ( 0xFE380003L - 0xFE201003L ) ) ;
# endif
	if ( (vme_found = rd_acc_check (i2c_bus)) == FALSE )
	{
		if ( verbose )
			printf ( "no VME...check ROM port..." ) ;
		i2c_bus   = (byte *)I2C_ROMPORT  ;
		i2c_romport = TRUE ;
		MDversion = (int *)VERS_ROM ;
		if ( rd_acc_check (i2c_bus) )
			check_i2c () ;
		else if ( verbose )
			printf ( "i2c not found" ) ;
	}
	else
	{
		if ( verbose )
			printf ( "check VME i2c..." ) ;
		if ( ! check_i2c () )
		{
			if ( verbose )
				printf ( " ...check ROM port..." ) ;
			i2c_bus   = (byte *)I2C_ROMPORT  ;
			i2c_romport = TRUE ;
			MDversion = (int *)VERS_ROM ;
			check_i2c () ;
		}
	}
	if ( verbose )
		printf ( "\n" ) ;
		
	return (vme_found);
} /*- chk_vme -*/
