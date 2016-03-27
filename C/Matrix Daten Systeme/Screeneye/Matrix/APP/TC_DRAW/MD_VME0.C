/********************************************************************/
/* 				MATdigi - VMEbus Module								*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 17.08.92												*/
/*																	*/
/*  HDG - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

# define TEST 0

# if TEST
# include <stdio.h>
# else
# include <stddef.h.h>
# endif

# include <stdlib.h>
# include <tos.h>

# include <global.h>
# include <access.h>

# include "\pc\tcxx\chips\i2c_hdg.h"

# include "md_vme.h"

/*- Variables -*/
bool		vme_found  = FALSE;
byte		*i2c_bus   = (byte *)I2C_VME ;
byte 		dummy_MD   = ILLhardware ;
byte		dummy_i2c ;
byte 		*MDversion = (byte *)VERS_VME ;

/* ============================================================== */

/*------------------------------------------- check_i2c -----------*/
bool check_i2c (void)
# define DMSDsa 0x8E
{
	byte	dp[2] = {0, 0x50} ;
	
	i2c_release ( i2c_bus ) ;
	if ( i2c_write( i2c_bus, DMSDsa, 2, dp) != 0 )
	{
# if TEST == 3
		printf ( "i2c not found" ) ;
# endif TEST
		i2c_bus   = &dummy_i2c ;
		MDversion = &dummy_MD ;
		return ( FALSE ) ;
	}
# if TEST == 3
	printf ( "i2c found at 0x%p", i2c_bus ) ;
# endif TEST
	return ( TRUE ) ;
}


/*------------------------------------------- chk_vme -----------*/
bool chk_vme (void)
# define DMSDsa 0x8E
{
	if ( (vme_found = rd_acc_check (i2c_bus)) == FALSE )
	{
# if TEST == 3
		printf ( "no VME...check ROM port..." ) ;
# endif TEST
		i2c_bus   = (byte *)I2C_ROMPORT  ;
		i2c_romport = TRUE ;
		MDversion = (byte *)VERS_ROM ;
		if ( rd_acc_check (i2c_bus) )
			check_i2c () ;
# if TEST == 3
		else
			printf ( "i2c not found" ) ;
# endif TEST
	}
	else
	{
# if TEST == 3
		printf ( "check VME i2c..." ) ;
# endif TEST
		if ( ! check_i2c () )
		{
# if TEST == 3
			printf ( " ...check ROM port..." ) ;
# endif TEST
			i2c_bus   = (byte *)I2C_ROMPORT  ;
			i2c_romport = TRUE ;
			MDversion = (byte *)VERS_ROM ;
			check_i2c () ;
		}
	}
# if TEST == 3
	printf ( "\n" ) ;
# endif TEST
		
	return (vme_found);
} /*- chk_vme -*/
