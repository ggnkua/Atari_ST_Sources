/*	digitise.c	/	 9.3.92	/	MATRIX	/	WA	*/
/*	MatDigi		/	12.7.93	/	MATRIX	/	HG	*/

# define TEST 0

# include <stdio.h>

# include <ext.h>
# include <vdi.h>
# include <aes.h>
# include <global.h>
# include <traps.h>

# include "i2c_hdg.h"

# include "mdf_addr.h"
# include "mdf_lca.h"
# include "mdf_lcax.h"
# include "digitise.h"
# include "digitisx.h"

# define COLOUR TRUE
# define NO_COLOUR FALSE

/* slave addresses */
# define DMSDslave9051 0x8E
# define DMSDslave7191 0x8A

# define CSCslave 0xE2

/* status bits */

# define HCLK 		0x40
# define FIDT7191 	0x20
# define CODE7191	0x01

# define FIDT9051 	0x10
# define CODE9051	0x04

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
# define VTRbit7191 0x80
# define SECAMbit 0x01

# define IOCLOCKaddr7191 0x0E
# define CHAN1mask7191 0x78
# define CHAN2mask7191 0x79
# define CHAN3mask7191 0x7A
# define SVHSbit7191 0x04

# define CONTROL3addr7191 	0x0F
# define AUTOmask7191 		0x91
# define PAL_SECAMmask7191 	0x11
# define NTSCmask7191 		0x51
# define YC411_7191			0x00
# define YC422_7191			0x08

# define YCfmt7191			YC411_7191


# define IOCLOCKaddr9051 0x0A

# define CHAN1mask9051	 0x40
# define NTSC069051	 	 0x62
# define PAL069051	 	 0x02
# define NTSC089051	 	 0x77
# define PAL089051	 	 0x38

# define DMSD7191dataSize	0x19
unsigned char Dmsd7191Data[DMSD7191dataSize+1] = 
{
	0x00,							/* subaddress */
	0x50, 0x30, 0x00, 0xE8,			/* 0..3 */
	0xB6, 0xF4,						/* 4..5 */
	APERinit |
	  ( CORIinit << 2 ) |
	  ( BPSSinit << 4 ) |
	  ( PREFinit << 6 ) |
	  ( BYPSinit << 7 ),			/* 6 */
	0x00,							/* 7 */
	0xF8, 0xF8, SENSinit, SENSinit,	/* 8..B */
	0x00, VTRbit7191, CHAN3mask7191, AUTOmask7191|YCfmt7191,/* C..F */
	0x00, 0x59, 0x00, 0x00,			/* 10..13 */
	0x34, 0x0A, 0xF4, 0xCE,			/* 14..17 */
	0xF4							/* 18 */
} ;

I2CdataBuffer DmsdData7191 =
{
    DMSD7191dataSize,
    Dmsd7191Data
} ;

# define DMSD9051dataSize	0x0C
unsigned char Dmsd9051Data[DMSD9051dataSize+1] = 
{
	0x00,							/* subaddress */
	0x5E,      /*00*/
	0x37,      /*01*/
	0x07,      /*02*/
	0xF6,      /*03*/
	0xC7,      /*04*/
	0xFF,      /*05*/ 
	PAL069051,      /*06	bypass off, prefilter on, bp 0, coring off, aper corr 0.5 */
	0x00,      /*07*/
	PAL089051,      /*08	PLL, 50Hz, VTR, color ON, PAL, */
# if 1
	0xE0,      /*09	VNL, Yen, Cen	*/
# else
	0xE8,      /*09	VNL, Yen, Cen, color on!	*/
# endif
	CHAN1mask9051, /*0A	HSY/HCen, CVBS on, CVBS in, Ydel=0 */
	0x00       /*0B*/
} ;

I2CdataBuffer DmsdData9051 =
{
    DMSD9051dataSize,
    Dmsd9051Data
} ;


byte	*i2c_bus = I2Caddr ; /* global */

byte I2Cslave = DMSDslave9051 ;

TDmsdParameter DmsdParameterBlock = { 9051, PUP_FBAS, 1, PUP_PAL } ;

/*------------------------------------------------ SetDmsdSlaveAddress ----*/
void SetDmsdSlaveAddress ( unsigned chip )
{
	switch ( chip )
	{
case 9051 :	I2Cslave = DMSDslave9051 ;	break ;
case 7191 :	I2Cslave = DMSDslave7191 ;	break ;
	}
}


/*------------------------------------------------ SetDmsdParameter ----*/
int SetDmsdParameter ( int chan, bool svhs )
{
	byte dat[2] ;
	
	switch ( DmsdParameterBlock.dmsd )
	{
case 7191 :	dat[0] = IOCLOCKaddr7191 ;
			dat[1] = CHAN1mask7191 + (chan-1) ;
			if ( svhs )
				dat[1] |= SVHSbit7191 ;
			break ;

case 9051 :	dat[0] = IOCLOCKaddr9051 ;
			dat[1] = CHAN1mask9051 | ((chan-1)<<3) ;
			break ;
	}

	return i2c_write ( i2c_bus, I2Cslave, 2, dat ) ;
}

/*------------------------------------------------ SetDmsdStandard ----*/
int SetDmsdStandard ( bool pal )
{
	byte dat[2] ;
	bool res1, res2 ;
	
	switch ( DmsdParameterBlock.dmsd )
	{
case 7191 :	break ; /* not implemented */

case 9051 :	if (pal)
			{
				dat[0] = 0x06 ;
				dat[1] = PAL069051 ;
				res1 = i2c_write ( i2c_bus, I2Cslave, 2, dat ) ;
				dat[0] = 0x08 ;
				dat[1] = PAL089051 ;
				res2 = i2c_write ( i2c_bus, I2Cslave, 2, dat ) ;
			}
			else
			{
				dat[0] = 0x06 ;
				dat[1] = NTSC069051 ;
				res1 = i2c_write ( i2c_bus, I2Cslave, 2, dat ) ;
				dat[0] = 0x08 ;
				dat[1] = NTSC089051 ;
				res2 = i2c_write ( i2c_bus, I2Cslave, 2, dat ) ;
			}
			
			break ;
	}

	return (res1||res2) ;
}


/*----------------------------------------- SelectDmsdRegisterSet -------*/
bool SelectDmsdRegisterSet ( I2CdataBuffer *i2cbuf )
{
	switch ( DmsdParameterBlock.dmsd )
	{
case 7191 :	*i2cbuf = DmsdData7191 ;
			return TRUE ;
case 9051 :	*i2cbuf = DmsdData9051 ;
			return TRUE ;
default :	printf ( "* unknown chip type : %u\n", DmsdParameterBlock.dmsd ) ;
			return FALSE ;
	}
}


/*----------------------------------------- AccessDmsdRegister -------*/
byte *AccessDmsdRegister ( unsigned regnum )
{
	I2CdataBuffer i2cbuf ;

	regnum++ ;	/* skip subaddress	*/
	if ( SelectDmsdRegisterSet ( &i2cbuf ) && regnum < i2cbuf.length )
		return &i2cbuf.data[regnum] ;
	else
		return NULL ;
}


/*----------------------------------------- GetSetDmsdRegister -----*/
int GetSetDmsdRegister ( unsigned regnum, int newval)
{
	byte *reg, oldval ;
	
	if ( ( reg = AccessDmsdRegister ( regnum ) ) != NULL )
	{
		oldval = *reg ;
		if ( newval )
			*reg = newval ;
		return oldval ;
	}
	else
		return -1 ;
}


/*----------------------------------------- LoadDmsdRegister -------*/
bool LoadDmsdRegister ( void )
{
	I2CdataBuffer i2cbuf ;

	if ( SelectDmsdRegisterSet ( &i2cbuf )
			&& i2c_write ( i2c_bus, I2Cslave, i2cbuf.length, i2cbuf.data ) == OK )
	{
		delay ( I2C_SETTLEtime ) ;
		return TRUE ;
	}
	else
		return FALSE ;
}


/*------------------------------------------------ InitMdf -------*/
bool InitMdf ( unsigned signal, unsigned source, int chip )
{
	I2CdataBuffer i2cbuf ;
	bool result = FALSE;

	DmsdParameterBlock.dmsd = chip ;
	DmsdParameterBlock.signal = signal ;
	DmsdParameterBlock.source = source ;

	switch ( DmsdParameterBlock.dmsd )
	{
case 7191 :	i2cbuf = DmsdData7191 ;
			i2cbuf.data[IOCLOCKaddr7191+1] = CHAN1mask7191 + ( source - 1 ) ;
			if ( signal == PUP_SVHS )
			{
				i2cbuf.data[IOCLOCKaddr7191+1] |= SVHSbit7191 ;
				i2cbuf.data[ 7] 			   |= BIT(7) ;
			}
			if ( DmsdParameterBlock.standard == PUP_SECAM )
				i2cbuf.data[STDMODEaddr+1] |= BIT(0) ;
			else
				i2cbuf.data[STDMODEaddr+1] &= ~BIT(0) ;
			break ;

case 9051 :	i2cbuf = DmsdData9051 ;
			i2cbuf.data[IOCLOCKaddr9051+1] = CHAN1mask9051 | ((source-1)<<3) ;
			break ;

default :	printf ( "* unknown chip type : %u\n", chip ) ;
			return FALSE ;
	}

	result = (bool) ( i2c_write ( i2c_bus, I2Cslave, i2cbuf.length, i2cbuf.data ) == OK ) ;
	delay ( I2C_SETTLEtime ) ;
	return result ;
}



/*---------------------------------------------- ReadI2CStatus -------*/
int ReadI2CStatus ( void )
{
	byte status ;
	
	delay ( I2C_SETTLEtime ) ;
	if ( i2c_read ( i2c_bus, I2Cslave, 1, &status ) == OK )
		return status ;
	else
		return -1 ;
}

/*----------------------------------------- GetDmsdStatus ---------------*/
void GetDmsdStatus ( bool *locked, bool *code, bool *fidt )
{
	int	status ;
	
	if ( ( status = ReadI2CStatus () ) < 0 )
		status = 0 ;
	
	*locked = ( status & HCLK ) == 0 ;
		
	if ( DmsdParameterBlock.dmsd == 9051 )
	{
		*code = ( status & CODE9051 ) != 0 ;
		*fidt = ( status & FIDT9051 ) != 0 ;
	}
	else
	{
		*code = ( status & CODE7191 ) != 0 ;
		*fidt = ( status & FIDT7191 ) != 0 ;
	}
}


# define CHK_FLUKE 2
/*----------------------------------------- get_std ---------------*/
int get_std ( int colour )
{
	int		status ;
	byte	code, fidt ;
	bool 	locked = FALSE ;
	int		fluke ;
	
	if ( ( status = ReadI2CStatus () ) >= 0 && ! ( status & HCLK ) )
	{	/* PLL locked i.e. signal found - check if it was a fluke...*/
		locked = TRUE ;
		for ( fluke = CHK_FLUKE ; ( fluke > 0 ) && locked ; fluke-- )
		{
			status = ReadI2CStatus () ;
			locked = ! ( status & HCLK ) ;
		}
		
		if ( DmsdParameterBlock.dmsd == 9051 )
		{
			code = status & CODE9051 ;
			fidt = status & FIDT9051 ;
		}
		else
		{
			code = status & CODE7191 ;
			fidt = status & FIDT7191 ;
		}

		if ( locked )
		{	/* it really must be locked */	
			if ( (  code &&  colour ) || ( !code && !colour ) )
			{
				if ( ! fidt )
					return PUP_PAL ;	/* 50 Hz, PAL or SECAM */
				else
					return PUP_NTSC ;	/* 60 Hz, NTSC */
			}
			else if ( !code &&  colour && fidt )
			       return PUP_RS170 ;
		}
	}
	return PUP_AUTO ; /* Not locked */
}

# define CHK_TIMEOUT 3
/*------------------------------------------- chk_signal ----------*/
int chk_signal ( int chan, bool colour, bool svhs )
{
	int result = PUP_AUTO ;
	bool breakout = FALSE ;
	int timeout = CHK_TIMEOUT ;

	if ( DmsdParameterBlock.dmsd == 9051 && svhs )
		return FALSE ;
	SetDmsdStandard ( TRUE ) ; /* set to Pal Standard */

	do
	{
		if ( SetDmsdParameter ( chan, svhs ) == OK )
			result = get_std ( colour ) ;
		else
			breakout = TRUE ;
		timeout-- ;
	}	while ( ( result == PUP_AUTO ) && !breakout && ( timeout > 0 ) ) ;

	if (result == PUP_RS170) /* switch ntsc on an check for ntsc */
	{
		SetDmsdStandard ( FALSE ) ; /* set to Ntsc Standard */
		do
		{
			if ( SetDmsdParameter ( chan, svhs ) == OK )
				result = get_std ( colour ) ;
			else
				breakout = TRUE ;
			timeout-- ;
		}	while ( ( result == PUP_AUTO ) && !breakout && ( timeout > 0 ) ) ;
	}
	return ( result != PUP_AUTO ) ;
}


/*------------------------------------- chk_auto_channel ----------*/
void chk_auto_channel ( int *channel, int *signal )
/* Find any channel ( priority 3,2,1 ) if "Auto" selected 
  ( --> auto signal type ) or find first channel with fixed
  signal type ( S-VHS has priority over PAL ).
*/
{
	int chan, sig_stand ;

	if ( *channel == PUP_AUTO )
	{
		for ( chan = 3; chan >= 1 ; chan-- )
		{
			if ( *signal == PUP_SVHS )		/* check for S-VHS signal */
			{
				if ( chk_signal ( chan, COLOUR, TRUE ) )
				{
					*channel = chan ;
					break ;
				}
			}
			else if ( *signal == PUP_FBAS )
			{								/* check for FBAS signal */
				if ( chk_signal ( chan, COLOUR, FALSE ) )
				{
					*channel = chan ;
					break ;
				}
			}
			else if ( *signal == PUP_NTSC )
			{								/* check for NTSC signal */
				if ( chk_signal ( chan, COLOUR, FALSE ) )
				{
					*channel = chan ;
					break ;
				}
			}
			else if ( *signal == PUP_BAS )
			{								/* check for BAS signal */
				if ( chk_signal ( chan, NO_COLOUR, FALSE ) )
				{
					*channel = chan ;
					break ;
				}
			}
			else							/* Auto signal */
			{
				if ( chk_signal ( chan, COLOUR, TRUE ) )
				{
					*channel = chan ;
					*signal = PUP_SVHS ;
					break ;
				}
				else						/* not S-VHS */
				{	
											/* check for FBAS/NTSC signal */
					sig_stand = chk_signal ( chan, COLOUR, FALSE ) ;
					if ( sig_stand == PUP_FBAS )
					{
						*channel = chan ;
						*signal = PUP_FBAS ;
						break ;
					}
					else if ( sig_stand == PUP_NTSC )
					{
						*channel = chan ;
						*signal = PUP_NTSC ;
						break ;
					}
					else if ( chk_signal ( chan, NO_COLOUR, FALSE ) )
					{						/* check for BAS signal */
						*channel = chan ;
						*signal = PUP_BAS ;
						break ;
					}
				}
			}
		} /* FOR */
	}
}


/*--------------------------------------- chk_set_signal ----------*/
void chk_set_signal ( int channel, int *signal, int *byps )
/* If channel fixed , find signal if "Auto" selected or
   set a fixed signal type ( otherwise ignore ) .
*/
{
	if ( channel != PUP_AUTO )
	{
		if ( *signal == PUP_AUTO )
		{
			if ( ! chk_signal ( channel, COLOUR, TRUE ) )
			{
				if ( chk_signal ( channel, COLOUR, FALSE ) )
					*signal = PUP_FBAS ;
				else if ( chk_signal ( channel, NO_COLOUR, FALSE ) )
					*signal = PUP_BAS ;
			}
			else
				*signal = PUP_SVHS  ;
		}
		else /* fixed signal S-VHS or FBAS or BAS */
		{
			if ( *signal == PUP_SVHS )		/* set S-VHS signal */
				chk_signal ( channel, COLOUR, TRUE ) ;
			else if ( *signal == PUP_FBAS )	/* set FBAS signal */
				chk_signal ( channel, COLOUR, FALSE ) ;
			else if ( *signal == PUP_BAS )	/* set BAS signal */
				chk_signal ( channel, NO_COLOUR, FALSE ) ;
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
	if ( *channel == PUP_AUTO )
		chk_auto_channel ( channel, signal ) ;
	else /* fixed channels 1, 2 or 3 */
	{
		SetDmsdParameter ( *channel, FALSE ) ;
		if ( *signal == PUP_AUTO )
		{
			if ( ! chk_signal ( *channel, COLOUR, TRUE ) )
			{
				if ( chk_signal ( *channel, COLOUR, FALSE ) == PUP_FBAS )
					*signal = PUP_FBAS ;
				else if ( chk_signal ( *channel, COLOUR, FALSE ) == PUP_NTSC )
					*signal = PUP_NTSC ;
				else if ( chk_signal ( *channel, NO_COLOUR, FALSE ) ) /* check for BAS signal */
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


/*-------------------------------- chk_set_video_standard -----------------*/
int chk_set_video_standard ( unsigned standard )
{
	byte dat[2] ;

	if ( standard == PUP_AUTO )
		standard = PUP_PAL ;

	if ( DmsdParameterBlock.dmsd == 7191 )
	{
		if ( DmsdParameterBlock.standard == PUP_SECAM )
			DmsdData7191.data[STDMODEaddr+1] |= BIT(0) ;
		else
			DmsdData7191.data[STDMODEaddr+1] &= ~BIT(0) ;
	
		dat[0] = STDMODEaddr ;
		dat[1] = DmsdData7191.data[STDMODEaddr+1] ;

		i2c_write ( i2c_bus, I2Cslave, 2, dat ) ;
	}

	DmsdParameterBlock.standard = standard ;

	return standard ;
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
		return ( (bool) ( i2c_write ( i2c_bus, I2Cslave, 2, dat ) == OK ) ) ;
}

# define _read_access(a)	if(*(a)) ;

extern void ResetLCA ( unsigned port ) ;

/*----------------------------------------- CheckScreenEyeHardware ---------------*/
unsigned CheckScreenEyeHardware ( void )
{
	unsigned found_dmsd ;
	
	inst_buserr();

	found_dmsd = NOdmsd ;
	_read_access ( I2Caddr ) ;
	if ( ! berr_flag )
	{
		_read_access ( INportYC ) ;
		if ( ! berr_flag )
		{
			*GRABcntrlReg = 0 ;
			_read_access ( GRABcntrlReg ) ;
			if ( ! berr_flag )
			{
				ResetLCA ( 0 ) ;
				_read_access ( MATDIGIFaddress + LCAdataOffset ) ;
				if ( ! berr_flag )
				{
					SetDmsdSlaveAddress ( 9051 ) ;
					LoadMdfLcaDataBlock ( NULL ) ;
					if ( ReadI2CStatus () >= 0 )
					{
						found_dmsd = 9051 ;
					}
					else
					{
						SetDmsdSlaveAddress ( 7191 ) ;
						LoadMdfLcaDataBlock ( NULL ) ;
						if ( ReadI2CStatus () >= 0 )
							found_dmsd = 7191 ;
					}
				}
			}
		}
	}

	remove_buserr();
	
	return found_dmsd ;
}


/*----------------------------------------- InitDmsd ---------------*/
int InitDmsd ( unsigned chip )
{
	int dummy, result ;
	
    if ( verbose )
    	printf ( "init DMSD %u\n", chip );

	if ( ( result = InitMdf ( PUP_FBAS, 1, chip ) ) != 0 )
		return result ;

	chk_set_chan_sig ( &DmsdParameterBlock.source, &DmsdParameterBlock.signal, &dummy ) ;

	if ( verbose )
	{
		if ( ( DmsdParameterBlock.signal != PUP_AUTO ||
			   DmsdParameterBlock.source != PUP_AUTO ) )
			printf ( "source : %u, signal : %u\n", DmsdParameterBlock.source, DmsdParameterBlock.signal ) ;
		else
			printf ( "* no signal found\n" ) ;

	    printf ( "DMSD status: $%02x\n", ReadI2CStatus() ) ;
	}

    return 0 ;
}

