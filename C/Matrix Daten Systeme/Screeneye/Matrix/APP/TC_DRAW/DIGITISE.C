/*	digitise.c	/	 9.3.92	/	MATRIX	/	WA	*/
/*	MatDigi		/	30.7.92	/	MATRIX	/	HG	*/

# define TEST 0

# if TEST
# include <stdio.h>
# include <vt52.h>
# endif

# include <ext.h>

# include <vdi.h>
# include <aes.h>

# include <global.h>

# include "\pc\cxxsetup\aesutils.h"

# include <tab_def.h>
# include <brd_def.h>
# include <scr_def.h>
# include <tcxx_acc.h>

# include <kern_fct.h>

# include <i2c_hdg.h>

# include "md_vme.h"
# include "digitise.h"


/* Attached hardware :   bit 3 2 1 0
                             C G P M
   M = 0 for MATdigi2,				M = 1 for MATdigi1
   V = 0 for ROM PORT,				V = 1 for VMEbus
   G = 0 for ST/TT,					G = 1 for MATRIX card (Cxx or TC)
   C = 0 for Cxx 256 colours,		C = 1 for TC
*/
# define	DIGI			BIT(0)
# define	PORT			BIT(1)
# define	GRAPH			BIT(2)
# define	COLS			BIT(3)

# define	MATdigi1		1
# define	VMEport			2
# define	MATgraph		4
# define	TRUEcol			8

# define 	MD1		( hardware & DIGI ) == MATdigi1
# define 	MD2		( hardware & DIGI ) != MATdigi1
# define 	VMEbus	( hardware & PORT ) == VMEport
# define 	ROMport	( hardware & PORT ) != VMEport
	

bool video_on = FALSE ;

VIDEO_WINDOW video =  { 8, 0, { 0, 0, 0, 0 } } ;

VIDEO_WINDOW *curr_video = &video ;

int	hardware = ILLhardware ;
int pal_sens = ( ~ SENSinit ) & 0xFF ;
int secam_sens = ( ~ SENSinit ) & 0xFF ;

/*------------------------------------------------ digi_init -------*/
bool digi_init ( void )
{
	chk_vme () ;
	
	if ( *MDversion != ILLhardware )
	{
		hardware =  *MDversion & DIGI ;
# if 0
		if ( MDversion == (byte *)VERS_VME )
# endif
			hardware += VMEport ;
		return TRUE ;
	}
	else
	{
# if TEST == 3
		printf ( "Unknown or missing hardware! ... (wait)...\n" ) ;
		delay ( 5000 ) ;
# endif TEST
		return FALSE ;
	}
}


/*---------------------------------------------- toggle_hardware -------*/
void toggle_hardware ( void )
{
	if ( MD1 )
		hardware &= ~MATdigi1 ;
	else if ( MD2 )
		hardware |=  MATdigi1 ;
	i2c_init () ;
}


# define COLOUR TRUE
# define NO_COLOUR FALSE

/* slave addresses */
# define DMSDslave 0x8E
# define CSCslave 0xE2

# define VLUT_ALLaddr 0x04

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


/*------------------------------------------------ i2c_init -------*/
bool i2c_init ( void )
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
							   0x00, 0x00, CHAN1mask, AUTOmask,	/* C..F */
							   0x00, 0x59, 0x00, 0x00,			/* 10..13 */
							   0x34, 0x0A, 0xF4, 0xCE,			/* 14..17 */
							   0xF4 } ;							/* 18 */
	byte	CSCbuffRGB[2]  = { 0x00, 0xEA } ;
	byte	CSCbuffYC[2]   = { 0x00, 0xE4 } ;
	int		result ;

	if ( hardware != ILLhardware )
	{
# if TEST == 3
		printf ( "DMSD-SQP : PAL\n" ) ;
# endif TEST
		result = i2c_write ( i2c_bus, DMSDslave, 26, DMSDbuffer ) ;
		if ( result == OK )
		{
			if ( MD1 )
			{
# if TEST == 3
				printf ( "DCSC Bypassed\n" ) ;
# endif TEST
				result = i2c_write ( i2c_bus, CSCslave, 2, CSCbuffYC ) ;
			}
			else
			{
# if TEST == 3
				printf ( "DCSC YC 4:2:2 --> RGB 8-8-8\n" ) ;
# endif TEST
				result = i2c_write ( i2c_bus, CSCslave, 2, CSCbuffRGB ) ;
			}
		}
# if TEST == 3
		delay ( 3000 ) ;
# endif TEST
		return (bool) ( result == OK ) ;
	}
	else
		return FALSE ;
}


/*---------------------------------------------- i2c_status -------*/
byte i2c_status ( void )
{
	byte	status ;
	
	if ( i2c_read ( i2c_bus, DMSDslave, 1, &status ) == OK )
		return status ;
	else
		return 0 ;
}


/*----------------------------------------- csc_vlut_init ----*/
bool csc_vlut_init ( void )
/* CSC VLUT RED, BLUE, GREEN ---> 1:1 */
{
	byte dat[3] ;
	bool result = TRUE ;
	int col ;
	
	dat[0] = VLUT_ALLaddr ;
	for ( col = 0 ; result && col <= 0xFF ; col++ )
	{
		dat[1] = (byte) col ;
		dat[2] = (byte) col ;
		result = (bool) ( i2c_write ( i2c_bus, CSCslave, 3, dat ) == OK ) ;
	}
	return result ;
}


/*----------------------------------------- set_source_and_std ----*/
bool set_source_and_std ( int source, int standard )
{
	byte	dat[2] ;
	bool	result ;
	
	dat[0] = STDMODEaddr ;
	dat[1] = 0 ;
	if ( source == PUP_VTR )
		dat[1] = VTRbit ;
	if ( standard == PUP_SECAM )
		dat[1] |= SECAMbit ;

	result = (bool ) ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK ) ;

	if ( result )
	{
		dat[0] = CONTROL3addr ;
		dat[1] = 0 ;
		if ( standard == PUP_AUTO )
			dat[1] = AUTOmask ;
		else if ( standard == PUP_PAL || standard == PUP_SECAM )
			dat[1] = PAL_SECAMmask ;
		else if ( standard == PUP_NTSC )
			dat[1] = NTSCmask ;
		result = (bool ) ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK ) ;
	}
	return result ;
}

/*----------------------------------------- get_std ---------------*/
int get_std ( bool colour )
{
	byte	status ;
	
	delay ( I2C_SETTLEtime ) ;
	if ( i2c_read ( i2c_bus, DMSDslave, 1, &status ) == OK )
	{
		if ( ( status & HCLK ) == 0 )
		{
			if ( ! colour || ( status & CODE ) == 1 )
			{
				if ( ( status & FIDT ) == 0 )
					return PUP_PAL ;	/* 50 Hz, PAL or SECAM */
				else
					return PUP_NTSC ;	/* 60 Hz, NTSC */
			}
		}
	}
	return PUP_AUTO ; /* Not locked */
}


/*----------------------------------------- chk_set_std ----------*/
void chk_set_std ( int source, int *standard, int *sensitivity )
{
	/* SECAM not yet fully implemented - HDG 9/6/92 @@@ */
	set_source_and_std ( source, *standard ) ;
	if ( *standard == PUP_AUTO )
		*standard = get_std ( COLOUR /*???*/ ) ;
	if ( *standard == PUP_PAL )
		*sensitivity = pal_sens ;
	else if ( *standard == PUP_SECAM )
		*sensitivity = secam_sens ;
	/* else NTSC doesn't alter or use "sensitivity" */
}


/*------------------------------------------- set_gain ----------*/
bool set_gain ( int gain )
{
	byte	dat[2] ;
	
	dat[0] = GAINCNTRLaddr ;
	dat[1] = ( gain << 5 ) ;
	
	return ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK ) ;
}


/*-------------------------------------- set_sensitivity ----------*/
bool set_sensitivity ( int standard, int sensitivity )
{
	byte	dat[2] ;

	if ( standard == PUP_PAL )
	{
		dat[0] = PALSENSaddr ;
		pal_sens = sensitivity ;
	}
	else if ( standard == PUP_SECAM	)
	{
		dat[0] = SECAMSENSaddr ;
		secam_sens = sensitivity ;
	}
	dat[1] = ( ( ~ sensitivity ) & 0xFF ) ;	/* 1's complement ! */
	
	return ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK ) ;
}


/*------------------------------------------- chk_signal ----------*/
bool chk_signal ( byte *dat, bool colour )
{
	if ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK )
		return ( get_std ( colour ) != PUP_AUTO ) ;
	else
		return FALSE ;
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
# if TEST == 4
	printf ( "chroma trap  = %d\n", *byps ) ;
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
# if TEST == 4
	printf ( "chroma trap  = %d\n", *byps ) ;
# endif TEST
}


/*-------------------------------- lumi_cntrl_init -----------------*/
void lumi_cntrl_init ( int *aper, int *cori, int *bpss, 
					   int *pref, int *byps )
{
	*aper = APERinit ;
	*cori = CORIinit ;
	*bpss = BPSSinit ;
	*pref = PREFinit ;
	*byps = BYPSinit ;
}


/*-------------------------------- set_lumi_cntrl -----------------*/
bool set_lumi_cntrl ( int aper, int cori, int bpss, 
					  int pref, int byps )
{
	byte dat[2] ;
	
	dat[0] = LUMICONTROLaddr ;
	dat[1] = aper | ( cori << 2 ) | ( bpss << 4 ) |
					( pref << 6 ) | ( byps << 7 ) ;
# if TEST == 4
	printf ( "LUMICONTROL = %d\n", dat[1] ) ;
# endif TEST
	return ( (bool) ( i2c_write ( i2c_bus, DMSDslave, 2, dat ) == OK ) ) ;
}


/*----------------------------------- g_check_init -----------------*/
int g_check_init ( void )
{
	if ( ! g_initialised() )
	{
		if ( tcxx_initialised() != OK )
			return 1 ;
		if ( ! ( board_parameter->kernel->state & KERNloaded ) )
			return 2 ;
		if ( ! g_init() || ( g_wait() != OK ) )
			return 3 ;
	}
	return OK ;
}


/*----------------------------------------------- tcbpp ------------*/
bool tcbpp ( int *bpp )
{
	if ( g_check_init() == OK )
	{
		*bpp = tcxx_tables->PlaneTable [ screen_parameter->bits_per_pixel ] ;
		return TRUE ;
	}
	return FALSE ;
}


/*----------------------------------- digitiser_running ------------*/
bool digitiser_running ( void )
{
# if TEST == 2
	printf ( CURSORhome "   frame count : %u   ", g_count() ) ;
# endif
	return ( g_busy() ) ;
}

/*----------------------------------- current_frame ------------*/
int current_frame ( void )
{
	return ( curr_video->frames - g_count() ) ;
}


/*----------------------------------- digitiser_stop ---------------*/
void digitiser_stop ( void )
{
	g_stop() ;
	g_wait() ;
	switch_vdi ( 1 ) ;
	video_on = FALSE ;
}

/*----------------------------------- mfactor ---------------*/
int mfactor ( int factor, int dmode )
{
	int		multiplex ;
	int		matbpp ;
	
	if ( tcbpp ( &matbpp ) )
	{
		switch ( matbpp )
		{
/*	@@@@@
	1. case 2 ????
	2. "multiplex" only valid for IMAGIC-MD2 !!!.
	    MD1 & MD2 values to be added.
*/
	case 8	:	multiplex = 0x0018 ;
				break ;
	case 16	:	multiplex = 0x0008 ;
				break ;
	case 32	:	multiplex = 0x0020 ;
				break ;
	default :	multiplex = 0x0000 ;	
		}
		if ( ( matbpp == 8 || matbpp == 32 ) && dmode == GREY_DISPLAY )
			multiplex |= 0x80 ; /* fast grey mode bit --> define @@ */
		return ( ( ( factor & 0x000F ) - 1 ) | multiplex ) ;
	}
	
	return factor ;
}


/*----------------------------------- digitise_video ---------------*/
int digitise_video ( bool with_grab, int dmode, int matbpp )
# define FULLvideoFactor 8
# define HALFvideoFactor 4
{
	int result, flags ;
	int max_w, max_h ;
	
	if ( ( result = g_check_init() ) == OK )
	{
		if ( digitiser_running() )
			return 5 ;

		max_w = FULLpixPerLine * curr_video->factor / FULLvideoFactor ;
		max_h = MAXdigLine * curr_video->factor / FULLvideoFactor ;
# if 0
		g_fetch ( curr_video->window.x, curr_video->window.y,
				  min(curr_video->window.w,max_w), min(curr_video->window.h,max_h),
				  max_w, curr_video->factor,
				  curr_video->frames, with_grab ) ;
# else
		if ( ! with_grab )
			flags = 0 ;
		else if ( dmode == GREY_DISPLAY )
		{
			if ( matbpp == 8 || matbpp == 32 )
				flags = VIDwithGrab + VIDNoYcToRgb + VIDfastGrey ;
			else /* 16 bpp */
				flags = VIDwithGrab + VIDNoYcToRgb ;
		}
		else
			flags = VIDwithGrab ;

		if ( MD1 )
		{
			if ( curr_video->factor == HALFvideoFactor )
				g_digig ( curr_video->window.x, curr_video->window.y,
						  min(curr_video->window.w,max_w), min(curr_video->window.h,max_h),
						  max_w/2,HALFvideoFactor-1,
					  	  curr_video->frames, flags ) ;
			else
				g_digi1 ( curr_video->window.x, curr_video->window.y,
					  	  min(curr_video->window.w,max_w), min(curr_video->window.h,max_h),
					      max_w, FULLvideoFactor-1,
					      curr_video->frames, flags ) ;
		}
		else if ( MD2 )
		{
			g_digi2 ( curr_video->window.x, curr_video->window.y,
					  min(curr_video->window.w,max_w), min(curr_video->window.h,max_h),
					  max_w, mfactor ( curr_video->factor, dmode ),
					  curr_video->frames, flags ) ;
		}		
# endif
		switch_vdi ( 0 ) ;
		video_on = TRUE ;
	}
	return result ;
}


# if TEST == 1
printf ( "* window %d:%d(%d:%d)(%d:%d),ppl=%d, vfac=%d, N=%d, key !\n",
			VALrect ( curr_video->window ),
			min(curr_video->window.w,max_w), min(curr_video->window.h,max_h),
			max_w, curr_video->factor, curr_video->frames ) ;
getchar();
# endif
