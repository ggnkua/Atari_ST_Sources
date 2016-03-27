/*	digitise.c	/	 9.3.92	/	MATRIX	/	WA	*/
/*	MatDigi		/	12.7.93	/	MATRIX	/	HG	*/

# define TEST 0

# if TEST
# include <stdio.h>
# include <vt52.h>
# endif

# include <ext.h>
# include <vdi.h>
# include <aes.h>
# include <global.h>

/* # include "\pc\cxxsetup\aesutils.h" */
# include "\pc\tcxx\chips\i2c_hdg.h"
# include "..\matdigi\md_vmer.h"

# ifdef __MATDIGI1__
# include "\pc\tcxx\lib\brd_def.h"
# include "\pc\tcxx\lib\scr_def.h"
# include "\pc\tcxx\tcxxinfo\tcxx_acc.h"
# include "\pc\tcxx\kernel\kernfast.h"
# include "\pc\tcxx\kernel\kern_fct.h"
#endif __MATDIGI1__

# include "digitise.h"

# define COLOUR TRUE
# define NO_COLOUR FALSE

/* slave addresses */
# define DMSDslave 0x8E
# define CSCslave 0xE2

/* status bits */
# define HCLK 0x40
# define FIDT 0x20
# define CODE 0x01

# define LUMICONTROLaddr 0x06
# define APERinit 0x01
# define CORIinit 0x00
# define BPSSinit 0x00
# define PREFinit 0x00
# define BYPSinit 0x00

# define PALSENSaddr 0x0A
# define SECAMSENSaddr 0x0B

# define GAINCNTRLaddr 0x0C
# define COLONbit 0x80

# define STDMODEaddr 0x0D
# define VTRbit 0x80
# define SECAMbit 0x01

# define IOCLOCKaddr 0x0E
# define CHAN1mask 0x78
# define CHAN2mask 0x79
# define CHAN3mask 0x7A
# define SVHSbit 0x04

# define CONTROL3addr 0x0F
# define AUTOmask 0x99
# define PAL_SECAMmask 0x19
# define NTSCmask 0x59

# ifdef __MATDIGI1__
/*------------------------------------------------ i2c_init -------*/
bool i2c_init ( unsigned format, unsigned source )
{
	byte	DMSDbuffer[26] = { 0x00,
							   0x50, 0x30, 0x00, 0xE8,			/* 0..3 */
							   0xB6, 0xF4,						/* 4..5 */
							     APERinit |
							   ( CORIinit << 2 ) |
							   ( BPSSinit << 4 ) |
							   ( PREFinit << 6 ) |
							   ( BYPSinit << 7 ),				/* 6 */
							   0x00,							/* 7 */
							   0xF8, 0xF8, SENSinit, SENSinit,	/* 8..B */
							   0x00, VTRbit, CHAN3mask, AUTOmask,/* C..F */
							   0x00, 0x59, 0x00, 0x00,			/* 10..13 */
							   0x34, 0x0A, 0xF4, 0xCE,			/* 14..17 */
							   0xF4 } ;							/* 18 */
	int		result ;

	DMSDbuffer[15] = CHAN1mask - 1 + source ; 
	if ( format == PUP_SVHS )
	{
		DMSDbuffer[15] |= SVHSbit ;
		DMSDbuffer[ 7] |= BIT(7) ;
	}
	result = i2c_write ( i2c_bus, DMSDslave, 26, DMSDbuffer ) ;
	return (bool) ( result == OK ) ;
}

# else __MATDIGIR__
/*------------------------------------------------ i2c_initrom -------*/
int i2c_initrom ( unsigned signal, unsigned source )
{
	byte	DMSDbuffer[26] = { 0x00,
							   0x50, 0x30, 0x00, 0xE8,			/* 0..3 */
							   0xB6, 0xF4,						/* 4..5 */
							     APERinit |
							   ( CORIinit << 2 ) |
							   ( BPSSinit << 4 ) |
							   ( PREFinit << 6 ) |
							   ( BYPSinit << 7 ),				/* 6 */
							   0x00,							/* 7 */
							   0xF8, 0xF8, SENSinit, SENSinit,	/* 8..B */
							   0x00, VTRbit, CHAN3mask, AUTOmask,/* C..F */
							   0x00, 0x59, 0x00, 0x00,			/* 10..13 */
							   0x34, 0x0A, 0xF4, 0xCE,			/* 14..17 */
							   0xF4 } ;							/* 18 */
	bool result = FALSE;

	DMSDbuffer[15] = CHAN1mask - 1 + source ;
	if ( signal == PUP_SVHS )
	{
		DMSDbuffer[15] |= SVHSbit ;
		DMSDbuffer[ 7] |= BIT(7) ;
	}
	i2c_write ( i2c_bus, DMSDslave, 26, DMSDbuffer ) ;
	i2c_write ( i2c_bus, DMSDslave, 26, DMSDbuffer ) ;
	result = (bool) ( i2c_write ( i2c_bus, DMSDslave, 26, DMSDbuffer ) == OK ) ;
	evnt_timer ( I2C_SETTLEtime, 0 ) ;
	return result ;
}
# endif __MATDIGIR__

/*---------------------------------------------- i2c_status -------*/
byte i2c_status ( void )
{
	byte	status ;
	
	evnt_timer ( I2C_SETTLEtime, 0 ) ;
	if ( i2c_read ( i2c_bus, DMSDslave, 1, &status ) == OK )
		return status ;
	else
		return 0 ;
}

# define CHK_FLUKE 4
/*----------------------------------------- get_std ---------------*/
int get_std ( bool colour )
{
	byte	status ;
	bool 	locked = FALSE ;
	int		fluke ;
	
	status = i2c_status () ;
	if ( ! ( status & HCLK ) )
	{	/* PLL locked i.e. signal found - check if it was a fluke...*/
		locked = TRUE ;
		for ( fluke = CHK_FLUKE ; ( fluke > 0 ) && locked ; fluke-- )
		{
			status = i2c_status () ;
			locked = ! ( status & HCLK ) ;
		}
		
		if ( locked )
		{	/* it really must be locked */	
			if ( (  ( status & CODE ) &&  colour ) ||
				 ( !( status & CODE ) && !colour )    )
			{
				if ( ! ( status & FIDT ) )
					return PUP_PAL ;	/* 50 Hz, PAL or SECAM */
				else
					return PUP_NTSC ;	/* 60 Hz, NTSC */
			}
		}
	}
	return PUP_AUTO ; /* Not locked */
}

# define CHK_TIMEOUT 3
/*------------------------------------------- chk_signal ----------*/
bool chk_signal ( byte *dat, bool colour )
{
	int result = PUP_AUTO ;
	bool breakout = FALSE ;
	int timeout = CHK_TIMEOUT ;
	
	do
	{
		if ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK )
			result = get_std ( colour ) ;
		else
			breakout = TRUE ;
		timeout-- ;
	}	while ( ( result == PUP_AUTO ) && !breakout && ( timeout > 0 ) ) ;
	
	return ( result != PUP_AUTO ) ;
}


/*------------------------------------- chk_auto_channel ----------*/
void chk_auto_channel ( int *channel, int *signal )
/* Find any channel ( priority 3,2,1 ) if "Auto" selected 
  ( --> auto signal type ) or find first channel with fixed
  signal type ( S-VHS has priority over PAL ).
*/
{
	byte dat[2] ;
	bool error = FALSE ;

	if ( *channel == PUP_AUTO )
	{
		dat[0] = IOCLOCKaddr ;
		for ( dat[1] = CHAN3mask ; !error && dat[1] >= CHAN1mask ;
			  dat[1]-- )
		{
			if ( *signal == PUP_SVHS )		/* check for S-VHS signal */
			{
				dat[1] |= SVHSbit ;
				if ( chk_signal ( dat, COLOUR ) )
				{
					*channel = ( dat[1] &= ~SVHSbit ) - CHAN1mask + 1 ;
					break ;
				}
			}
			else if ( *signal == PUP_FBAS )
			{								/* check for FBAS signal */
				if ( chk_signal ( dat, COLOUR ) )
				{
					*channel = dat[1] - CHAN1mask + 1 ;
					break ;
				}
			}
			else if ( *signal == PUP_BAS )
			{								/* check for BAS signal */
				if ( chk_signal ( dat, NO_COLOUR ) )
				{
					*channel = dat[1] - CHAN1mask + 1 ;
					break ;
				}
			}
			else							/* Auto signal */
			{
				dat[1] |= SVHSbit ;			/* check for S-VHS signal */
				if ( chk_signal ( dat, COLOUR ) )
				{
					*channel = ( dat[1] & ~SVHSbit ) - CHAN1mask + 1 ;
					*signal = PUP_SVHS ;
					break ;
				}
				else						/* not S-VHS */
				{							/* check for FBAS signal */
					dat[1] &= ~SVHSbit ;
					if ( chk_signal ( dat, COLOUR ) )
					{
						*channel = dat[1] - CHAN1mask + 1 ;
						*signal = PUP_FBAS ;
						break ;
					}
					else if ( chk_signal ( dat, NO_COLOUR ) )
					{						/* check for BAS signal */
						*channel = dat[1] - CHAN1mask + 1 ;
						*signal = PUP_BAS ;
						break ;
					}
				}
			}
			dat[1] &= ~SVHSbit ;	/* ensure S-VHS turned off before decrementing */
		} /* FOR */
	}
}


/*--------------------------------------- chk_set_signal ----------*/
void chk_set_signal ( int channel, int *signal, int *byps )
/* If channel fixed , find signal if "Auto" selected or
   set a fixed signal type ( otherwise ignore ) .
*/
{
	byte dat[2] ;
	
	if ( channel != PUP_AUTO )
	{
		dat[0] = IOCLOCKaddr ;
		dat[1] = ( CHAN1mask + channel - 1 ) ;
		if ( *signal == PUP_AUTO )
		{
			dat[1] |= SVHSbit ;			/* check for S-VHS signal */
			if ( ! chk_signal ( dat, COLOUR ) )
			{
				dat[1] &= ~SVHSbit ;	/* check for (F)BAS signal */
				if ( chk_signal ( dat, COLOUR ) )
					*signal = PUP_FBAS ;
				else if ( chk_signal ( dat, NO_COLOUR ) )
					*signal = PUP_BAS ;
			}
			else
				*signal = PUP_SVHS  ;
		}
		else /* fixed signal S-VHS or FBAS or BAS */
		{
			if ( *signal == PUP_SVHS )		/* set S-VHS signal */
			{
				dat[1] |= SVHSbit ;
				chk_signal ( dat, COLOUR ) ;
			}
			else if ( *signal == PUP_FBAS )	/* set FBAS signal */
			{
				dat[1] &= ~SVHSbit ;
				chk_signal ( dat, COLOUR ) ;
			}
			else if ( *signal == PUP_BAS )	/* set BAS signal */
			{
				dat[1] &= ~SVHSbit ;
				chk_signal ( dat, NO_COLOUR ) ;
			}
		}
	}
	*byps = (int) ( *signal == PUP_SVHS ) ;
	set_lumi_cntrl ( APERinit, CORIinit, BPSSinit, PREFinit, *byps ) ;
# if TEST == 4
	printf ( "chroma trap  = %d\n", *byps & 0x1 ) ;
# endif TEST
}


/*------------------------------------- chk_set_chan_sig ----------*/
void chk_set_chan_sig ( int *channel, int *signal, int *byps )
/* Find channel if "Auto" selected ( --> auto signal type )
   or set a fixed channel ( --> auto signal type ).
*/
{
	byte dat[2] ;
	
	if ( *channel == PUP_AUTO )
		chk_auto_channel ( channel, signal ) ;
	else /* fixed channels 1, 2 or 3 */
	{
		dat[0] = IOCLOCKaddr ;
		dat[1] = CHAN1mask + *channel - 1 ;		/* fixed channel */
		i2c_write ( i2c_bus, DMSDslave, 2, dat ) ;
		if ( *signal == PUP_AUTO )
		{
			dat[0] = IOCLOCKaddr ;
			dat[1] |= SVHSbit ;			/* check for S-VHS signal */
			if ( ! chk_signal ( dat, COLOUR ) )
			{
				dat[1] &= ~SVHSbit ;	/* check for FBAS signal */
				if ( chk_signal ( dat, COLOUR ) )
					*signal = PUP_FBAS ;
				else if ( chk_signal ( dat, NO_COLOUR ) ) /* check for BAS signal */
					*signal = PUP_BAS ;
			}
			else
				*signal = PUP_SVHS ;
		}
	}
	*byps = (int) ( *signal == PUP_SVHS ) ;
	set_lumi_cntrl ( APERinit, CORIinit, BPSSinit, PREFinit, *byps ) ;
# if TEST == 4
	printf ( "chroma trap  = %d\n", *byps & 0x1 ) ;
# endif TEST
}


/*-------------------------------- set_lumi_cntrl -----------------*/
bool set_lumi_cntrl ( int aper, int cori, int bpss, 
					  int pref, int byps )
{
	byte dat[2] ;
	
	dat[0] = LUMICONTROLaddr ;
	dat[1] =   ( aper & 0x3 ) |
			 ( ( cori & 0x3 ) << 2 ) |
			 ( ( bpss & 0x1 ) << 4 ) |
			 ( ( pref & 0x1 ) << 6 ) |
			 ( ( byps & 0x1 ) << 7 ) ;
# if TEST == 4
	printf ( "LUMICONTROL = %d\n", dat[1] ) ;
# endif TEST
	return ( (bool) ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK ) ) ;
}

# ifdef __MATDIGI1__
/*----------------------------------- g_check_init -----------------*/
int g_check_init ( void )
{
	if ( ! g_initialised() )
	{
		if ( tcxx_initialised() != OK )
			return 1 ;
		if ( ! ( board_parameter->kernel->state & KERNloaded ) )
			return 2 ;
		if ( ! g_init() || ( g_ready() != OK ) )
			return 3 ;
	}
	return OK ;
}


/*------------------------------------------------ digi_init -------*/
bool digi_init ( void )
{
	if ( g_check_init() == OK )
		return TRUE ;
# if 0
	{
		chk_vme () ;
		if ( *MDversion != ILLhardware )
		{
			hardware =  *MDversion & DIGI ;
			if ( MDversion == (byte *)VERS_VME )
				hardware += VMEport ;
			return TRUE ;
		}
	}
# endif
	return FALSE ;
}
# endif __MATDIGI1__
