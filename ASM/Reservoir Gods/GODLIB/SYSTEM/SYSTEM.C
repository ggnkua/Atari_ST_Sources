/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: SYSTEM.C
::
:: Machine capability enumeration
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"SYSTEM.H"

#include	<GODLIB\MFP\MFP.H>
#include	<GODLIB\VBL\VBL.H>
#include	<GODLIB\XBIOS\XBIOS.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dSYSTEM_CALIBVBL_LIMIT	64

#define	dSYSTEM_EMU_NONE		'Emu?'
#define	dSYSTEM_EMU_TOSBOX		'TBox'
#define	dSYSTEM_EMU_STEEM0		'STEe'
#define	dSYSTEM_EMU_STEEM1		'mEng'
#define	dSYSTEM_EMU_PACIFIST0	'Paci'
#define	dSYSTEM_EMU_PACIFIST1	'fiST'


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U32	Vectors[ 62 ];
} sSystemVectors;


/* ###################################################################################
#  DATA
################################################################################### */

sSYSTEM			gSystem;
sSystemVectors	gSystemVectors;

sTagString	gSystemNamesCPU[ CPU_LIMIT ] =
{
	{	CPU_UNKNOWN,	"unknown"	},
	{	CPU_68000,		"68000"		},
	{	CPU_68010,		"68010"		},
	{	CPU_68020,		"68020"		},
	{	CPU_68030,		"68030"		},
	{	CPU_68040,		"68040"		},
	{	CPU_68060,		"68060"		},
	{	CPU_G4,			"G4"		}
};

sTagString	gSystemNamesDSP[ DSP_LIMIT ] =
{
	{	DSP_NONE,		"none"		},
	{	DSP_UNKNOWN,	"unknown"	},
	{	DSP_56000,		"56000"		},
	{	DSP_56001,		"56001"		}
};

sTagString	gSystemNamesFPU[ FPU_LIMIT ] =
{
	{	FPU_NONE,		"none"		},
	{	FPU_UNKNOWN,	"unknown"	},
	{	FPU_SFP004,		"SFP004"	},
	{	FPU_68881,		"68881"		},
	{	FPU_68882,		"68882"		},
	{	FPU_68040,		"68040"		}
};

sTagString	gSystemNamesMCH[ MCH_LIMIT ] =
{
	{	MCH_UNKNOWN,	"unknown"	},
	{	MCH_ST,			"ST"		},
	{	MCH_STE,		"STe"		},
	{	MCH_STBOOK,		"ST Book"	},
	{	MCH_MEGASTE,	"Mega STe"	},
	{	MCH_TT,			"TT"		},
	{	MCH_FALCON,		"Falcon"	},
	{	MCH_MILAN,		"Milan"		},
	{	MCH_HADES,		"Hades"		},
	{	MCH_PHENIX,		"Phenix"	}
};

sTagString	gSystemNamesMON[ MON_LIMIT ]=
{
	{	MON_TV,			"TV"		},
	{	MON_RGB,		"RGB"		},
	{	MON_VGA,		"VGA"		},
	{	MON_MONO,		"Mono"		},
	{	MON_MULTISYNC,	"MultiSync"	},
	{	MON_HDTV,		"HDTV"		}

};

sTagString	gSystemNamesVDO[ VDO_LIMIT ] =
{
	{	VDO_UNKNOWN,	"unknown"	},
	{	VDO_ST,			"ST"		},
	{	VDO_STE,		"STe"		},
	{	VDO_TT,			"TT"		},
	{	VDO_FALCON,		"Falcon"	},
};

sTagString	gSystemNamesBLT[ BLT_LIMIT ] =
{
	{	BLT_NONE,		"None"		},
	{	BLT_BLITTER,	"Yes"		},
};

sTagString	gSystemNamesEMU[ EMU_LIMIT ] =
{
	{	EMU_NONE,		"NONE"		},
	{	EMU_UNKNOWN,	"UNKNOWN"	},
	{	EMU_PACIFIST,	"PACIFIST"	},
	{	EMU_STEEM,		"STEEM"		},
	{	EMU_STEEM,		"TOSBOX"	},
};


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

eSYSTEM_MCH	System_CalcMCH( void );
void		System_SetMCH( eSYSTEM_MCH aMCH );
eSYSTEM_CPU	System_CalcCPU( void );
void		System_SetCPU( eSYSTEM_CPU aCPU );
eSYSTEM_FPU	System_CalcFPU( void );
void		System_SetFPU( eSYSTEM_FPU aFPU );
eSYSTEM_DSP	System_CalcDSP( void );
void		System_SetDSP( eSYSTEM_DSP aDSP );
eSYSTEM_VDO	System_CalcVDO( void );
void		System_SetVDO( eSYSTEM_VDO aVDO );
eSYSTEM_MON	System_CalcMON( void );
void		System_SetMON( eSYSTEM_MON aMON );
eSYSTEM_BLT	System_CalcBLT( void );
void		System_SetBLT( eSYSTEM_BLT aBLT );
eSYSTEM_EMU	System_CalcEMU( void );
void		System_SetEMU( eSYSTEM_EMU aEMU );
U16			System_CalcTosVersion( void );
void		System_SetTosVersion( const U16 aTos );
U16			System_CalcEmuVersion( void );
void		System_SetEmuVersion( const U16 aEmu );
sSystemEmuDesc *	System_CalcpEmuDesc( void );
void				System_SetpEmuDesc( sSystemEmuDesc * apDesc );
U32			System_CalcMemory( void );
void		System_SetMemory( const U32 aMem );
sSystemEmuDesc *	System_GetpEmuDesc( void );

void		System_SaveVectors( sSystemVectors * apVectors );
void		System_RestoreVectors( sSystemVectors * apVectors );

extern	void	System_SetDataCache030( U32 aFlag );
extern	void	System_HblTemp( void );
extern	void	System_200hzTemp( void );

extern	U32		gSystemHblTempCounter;
extern	U32		gSystem200hzTempCounter;

extern	U32					System_GetEmuName0( void );
extern	U32					System_GetEmuName1( void );
extern	sSystemEmuDesc *	System_GetpEmuDescLL( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_Init()
* ACTION   : determines FUNCTIONality of system
* CREATION : 04.01.00 PNK
*-----------------------------------------------------------------------------------*/

void	System_Init()
{
	System_SetMCH( System_CalcMCH() );
	System_SetCPU( System_CalcCPU() );
	System_SetFPU( System_CalcFPU() );
	System_SetDSP( System_CalcDSP() );
	System_SetMON( System_CalcMON() );
	System_SetVDO( System_CalcVDO() );
	System_SetTosVersion( System_CalcTosVersion() );
	System_SetBLT( System_CalcBLT() );
	System_SetEMU( System_CalcEMU() );
	System_SetpEmuDesc( System_CalcpEmuDesc() );
	System_SetEmuVersion( System_CalcEmuVersion() );
	System_SetMemory( System_CalcMemory() );

	System_SaveVectors( &gSystemVectors );
	Mfp_Init();
	System_Calibrate();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_DeInit()
* ACTION   : determines FUNCTIONality of system
* CREATION : 23.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	System_DeInit()
{
	Mfp_DeInit();
	System_RestoreVectors( &gSystemVectors );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetMCH( eSYSTEM_MCH aMCH )
* ACTION   : sets machine variable of system structure
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

void		System_SetMCH( eSYSTEM_MCH aMCH )
{
	gSystem.MCH = aMCH;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetMCH()
* ACTION   : returns machine type of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_MCH	System_GetMCH()
{
	return( gSystem.MCH );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcMCH()
* ACTION   : calcs machine type of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_MCH	System_CalcMCH()
{
	U32	lCookie;

	if( CookieJar_Exists() )
	{
		if( CookieJar_CookieExists( '_MCH' ) )
		{
			lCookie  = CookieJar_GetCookieValue( '_MCH' );
			if( lCookie == 0x00000L )
				return( MCH_ST );
			if( lCookie == 0x10000L )
				return( MCH_STE );
			if( lCookie == 0x10008L )
				return( MCH_STBOOK );
			if( lCookie == 0x10010L )
				return( MCH_MEGASTE );
			if( lCookie == 0x20000L )
				return( MCH_TT );
			if( lCookie == 0x30000L )
				return( MCH_FALCON );
		}
		if( CookieJar_CookieExists( '_VDO' ) )
		{
			lCookie   = CookieJar_GetCookieValue( '_VDO' );
			lCookie >>= 16;
			if( lCookie == 0 )
				return( MCH_ST );
			if( lCookie == 1 )
				return( MCH_STE );
			if( lCookie == 2 )
				return( MCH_TT );
			if( lCookie == 3 )
				return( MCH_FALCON );			
		}
		return( MCH_ST );
	}
	return( MCH_ST );	/* hack remove */
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetCPU( eSYSTEM_CPU aCPU )
* ACTION   : sets CPU variable of system structure
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

void		System_SetCPU( eSYSTEM_CPU aCPU )
{
	gSystem.CPU = aCPU;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetCPU()
* ACTION   : returns CPU type of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_CPU	System_GetCPU()
{
	return( gSystem.CPU );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcCPU( eSYSTEM_CPU aCPU )
* ACTION   : calculates cpu of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_CPU	System_CalcCPU()
{
	eSYSTEM_CPU	lCPU;
	U32			lCookie;

	if( CookieJar_Exists() )
	{
		if( CookieJar_CookieExists( '_CPU' ) )
		{
			lCookie  = CookieJar_GetCookieValue( '_CPU' );
			lCookie &= 0x0000FFFFL;
			switch( (U16)lCookie )
			{
			case 0:
				lCPU = CPU_68000;
				break;

			case 10:
				lCPU = CPU_68010;
				break;

			case 20:
				lCPU = CPU_68020;
				break;

			case 30:
				lCPU = CPU_68030;
				break;

			case 40:
				lCPU = CPU_68040;
				break;

			case 60:
				lCPU = CPU_68060;
				break;

			default:
				lCPU = CPU_UNKNOWN;
				break;
			}
		}
		else
		{
			lCPU = CPU_68000;
		}
	}
	else
	{
		lCPU = CPU_68000;
	}
	return( lCPU );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetFPU( eSYSTEM_FPU aFPU )
* ACTION   : sets FPU variable of system structure
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

void		System_SetFPU( eSYSTEM_FPU aFPU )
{
	gSystem.FPU = aFPU;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetFPU()
* ACTION   : returns FPU type of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_FPU	System_GetFPU()
{
	return( gSystem.FPU );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcFPU()
* ACTION   : calculates fpu of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_FPU	System_CalcFPU()
{
	U32	lCookie;

	if( CookieJar_Exists() )
	{
		if( CookieJar_CookieExists( '_FPU' ) )
		{
			lCookie   = CookieJar_GetCookieValue( '_FPU' );
			lCookie >>= 16;
			if( lCookie == 0 )
				return( FPU_NONE );
			if( lCookie == 1 )
				return( FPU_SFP004 );
			if( (lCookie >= 2) && (lCookie <=5) )
				return( FPU_68881 );
			if( (lCookie == 6) || (lCookie ==7) )
				return( FPU_68882 );
			if( (lCookie == 8) || (lCookie ==9) )
				return( FPU_68040 );
			return( FPU_UNKNOWN);
		}
	}
	return( FPU_NONE );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetDSP( eSYSTEM_DSP aDSP )
* ACTION   : sets DSP variable of system structure
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

void		System_SetDSP( eSYSTEM_DSP aDSP )
{
	gSystem.DSP = aDSP;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : System_GetDSP()
* ACTION : returns DSP type of system
* CREATION      : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_DSP	System_GetDSP()
{
	return( gSystem.DSP );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcDSP()
* ACTION   : calculates DSP of system
* CREATION : 09.01.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_DSP	System_CalcDSP()
{
	U32	lCookie;

	if( CookieJar_Exists() )
	{
		if( CookieJar_CookieExists( '_SND' ) )
		{
			lCookie   = CookieJar_GetCookieValue( '_SND' );
			if( lCookie & (1<<4) )
				return( DSP_56000 );
		}
	}
	return( DSP_NONE );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetVDO( eSYSTEM_VDO aVDO )
* ACTION   : sets video card type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	System_SetVDO( eSYSTEM_VDO aVDO )
{
	gSystem.VDO = aVDO;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetVDO()
* ACTION   : returns video card type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_VDO	System_GetVDO()
{
	return( gSystem.VDO );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcVDO()
* ACTION   : determines video card type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_VDO	System_CalcVDO()
{
	U32	lCookie;

	if( CookieJar_Exists() )
	{
		if( CookieJar_CookieExists( '_VDO' ) )
		{
			lCookie   = CookieJar_GetCookieValue( '_VDO' );
			lCookie >>= 16L;
			switch( (U16)lCookie )
			{
			case 0:
				return( VDO_ST );
			case 1:
				return( VDO_STE );
			case 2:
				return( VDO_TT );
			case 3:
				return( VDO_FALCON );
			default:
				return( VDO_ST );
			}
		}
	}
	return( VDO_ST );/* hack remove */
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetMON( eSYSTEM_MON aMON )
* ACTION   : sets monitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	System_SetMON( eSYSTEM_VDO aMON )
{
	gSystem.MON = aMON;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetMON()
* ACTION   : returns monitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_VDO	System_GetMON()
{
	return( gSystem.MON );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcMON()
* ACTION   : determines monitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_MON	System_CalcMON()
{
	eSYSTEM_MON	lMon;
	U8			lReg;

	switch( System_CalcMCH() )
	{

	case MCH_ST:
	case MCH_STE:
		lReg = *(U8 *)0xFFFF8260L;
		if( lReg == 2 )
		{
			lMon = MON_MONO;
		}
		else
		{
			lMon = MON_TV;
		}
		break;

	case MCH_TT:
		break;

	case MCH_FALCON:
		lReg   = *(U8 *)0xFFFF8006L;
		lReg >>= 6;
		switch( lReg & 3 )
		{
		case 0:
			lMon = MON_MONO;
			break;
		case 1:
			lMon = MON_RGB;
			break;
		case 2:
			lMon = MON_VGA;
			break;
		case 3:
		default:
			lMon = MON_TV;
			break;
		}
		break;

	default:
		lMon = MON_TV;
		break;

	}
	return( lMon );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameCPU( void )
* ACTION   : returns name string of CPU type of system
* CREATION : 27.11.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameCPU( void )
{
	return( sTagString_GetpString( System_GetCPU(), gSystemNamesCPU, CPU_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameDSP( void )
* ACTION   : returns name string of DSP type of system
* CREATION : 27.11.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameDSP( void )
{
	return( sTagString_GetpString( System_GetDSP(), gSystemNamesDSP, DSP_LIMIT ) );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameFPU( void )
* ACTION   : returns name string of FPU type of system
* CREATION : 27.11.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameFPU( void )
{
	return( sTagString_GetpString( System_GetFPU(), gSystemNamesFPU, FPU_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameMCH( void )
* ACTION   : returns name string of machine type of system
* CREATION : 27.11.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameMCH( void )
{
	return( sTagString_GetpString( System_GetMCH(), gSystemNamesMCH, MCH_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameMON( void )
* ACTION   : returns name string of monitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameMON( void )
{
	return( sTagString_GetpString( System_GetMON(), gSystemNamesMON, MON_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameVDO( void );
* ACTION   : returns name string of video system type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameVDO( void )
{
	return( sTagString_GetpString( System_GetVDO(), gSystemNamesVDO, VDO_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetBLT( eSYSTEM_BLT aBLT )
* ACTION   : sets blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	System_SetBLT( eSYSTEM_BLT aBLT )
{
	gSystem.BLT = aBLT;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetBLT()
* ACTION   : returns blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_BLT	System_GetBLT()
{
	return( gSystem.BLT );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcBLT()
* ACTION   : determines BLTitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_BLT	System_CalcBLT()
{
	eSYSTEM_BLT	lBlt;

	if( System_GetTosVersion() >= 0x102 )
	{
		lBlt = (Xbios_Blitmode( -1 ))&1;
	}
	else
	{
		lBlt = BLT_NONE;
	}

	return( lBlt );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameBLT( void );
* ACTION   : returns name string of blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameBLT( void )
{
	return( sTagString_GetpString( System_GetBLT(), gSystemNamesBLT, BLT_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetEMU( eSYSTEM_EMU aEMU )
* ACTION   : sets blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	System_SetEMU( eSYSTEM_EMU aEMU )
{
	gSystem.EMU = aEMU;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetEMU()
* ACTION   : returns blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_EMU	System_GetEMU()
{
	return( gSystem.EMU );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcEMU()
* ACTION   : determines EMUitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

eSYSTEM_EMU	System_CalcEMU()
{
	eSYSTEM_EMU	lEmu;
	U32			lID0;
	U32			lID1;

	lID0 = System_GetEmuName0();
	lID1 = System_GetEmuName1();

	if( lID0 == dSYSTEM_EMU_NONE )
	{
		lEmu = EMU_NONE;
	}
	else if( lID0 == dSYSTEM_EMU_TOSBOX )
	{
		lEmu = EMU_TOSBOX;
	}
	else if( (lID0 == dSYSTEM_EMU_STEEM0) &&  (lID1 == dSYSTEM_EMU_STEEM1) )
	{
		lEmu = EMU_STEEM;
	}
	else if( (lID0 == dSYSTEM_EMU_PACIFIST0) &&  (lID1 == dSYSTEM_EMU_PACIFIST1) )
	{
		lEmu = EMU_PACIFIST;
	}
	else
	{
		lEmu = EMU_UNKNOWN;
	}

	return( lEmu );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetNameEMU( void );
* ACTION   : returns name string of blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

char *		System_GetNameEMU( void )
{
	return( sTagString_GetpString( System_GetEMU(), gSystemNamesEMU, EMU_LIMIT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetMemory( U32 aMem )
* ACTION   : sets blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	System_SetMemory( const U32 aMem )
{
	gSystem.Memory = aMem;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetMemory()
* ACTION   : returns blitter type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

U32		System_GetMemory()
{
	return( gSystem.Memory );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalcMemory()
* ACTION   : determines Memoryitor type of system
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

U32	System_CalcMemory()
{
	U32	lMem;

	gSystem.RamST = *(U32*)0x42EL;

	if( 0x1357BD13L == *(U32*)0x5A8L )
	{
		gSystem.RamTT = *(U32*)0x5A4L - 0x01000000L;
	}
	else
	{
		gSystem.RamTT = 0;
	}

	lMem  = gSystem.RamST;
	lMem += gSystem.RamTT;

	return( lMem );
}


U32			System_GetRamST( void )
{
	return( gSystem.RamST );
}

U32			System_GetRamTT( void )
{
	return( gSystem.RamTT );
}

void		System_Calibrate( void )
{
	sMfpTimer	lOldTD;
	sMfpTimer	lNewTD;
	U32			lCounterTC;
	U32			lCounterHBL;
	U32			lRate;
	U32			lOldHBL;
	U16			lOldIML;
	U16			i;

	Mfp_GetTimerD( &lOldTD );

	lOldIML = System_GetIML();
	lOldHBL = *(U32*)0x68L;

	System_SetIML( 7 );

	lNewTD.Data      = 0xC0;
	lNewTD.Enable    = 1;
	lNewTD.Mask      = 1;
	lNewTD.Mode      = 5;
	lNewTD.TimerFunc = System_200hzTemp;

	Mfp_InstallTimerD( &lNewTD );


	*(U32*)0x68L = (U32)System_HblTemp;

	System_SetIML( 1 );

	Vbl_WaitVbl();
	gSystemHblTempCounter   = 0;
	gSystem200hzTempCounter = 0;

	for( i=0; i<dSYSTEM_CALIBVBL_LIMIT; i++ )
	{
		Vbl_WaitVbl();
	}
	
	lCounterHBL = gSystemHblTempCounter;
	lCounterTC  = gSystem200hzTempCounter;
	if( !lCounterTC )
	{
		lCounterTC = 1;
	}

	lRate  = dSYSTEM_CALIBVBL_LIMIT * 200L * 0x10000L;
	lRate /= lCounterTC;

	gSystem.RefreshRate.w.w1 = (U16)(lRate>>16L);
	gSystem.RefreshRate.w.w0 = (U16)(lRate&0xFFFF);

	lRate  = lCounterHBL * 0x10000L;
	lRate /= lCounterTC;
	lRate *= 200L;


	gSystem.HblRate.w.w1 = (U16)(lRate>>16L);
	gSystem.HblRate.w.w0 = (U16)(lRate&0xFFFF);

	System_SetIML( lOldIML );
	*(U32*)0x68L = (U32)lOldHBL;
	Mfp_InstallTimerD( &lOldTD );

}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_CalibrateVbl( void )
* ACTION   : System_CalibrateVbl
* CREATION : 27.11.2002 PNK
*-----------------------------------------------------------------------------------*/

void	System_CalibrateVbl( void )
{
	U32			lCounterTC;
	U32			lRate;
	U16			i;

	Vbl_WaitVbl();
	lCounterTC = Mfp_GetCounter200hz();

	for( i=0; i<dSYSTEM_CALIBVBL_LIMIT; i++ )
	{
		Vbl_WaitVbl();
	}
	
	lCounterTC  = Mfp_GetCounter200hz() - lCounterTC;
	if( !lCounterTC )
	{
		lCounterTC = 1;
	}

	lRate  = dSYSTEM_CALIBVBL_LIMIT * 200L * 0x10000L;
	lRate /= lCounterTC;

	gSystem.RefreshRate.w.w1 = (U16)(lRate>>16L);
	gSystem.RefreshRate.w.w0 = (U16)(lRate&0xFFFFL);
	
}

uU32 *		System_GetRefreshRate( void )
{
	return( &gSystem.RefreshRate );
}

uU32 *		System_GetHblRate( void )
{
	return( &gSystem.HblRate );
}

void		System_DataCacheDisable( void )
{
	if( gSystem.CPU == CPU_68030 )
	{
		System_SetDataCache030( 0 );
	}
	else if( gSystem.MCH == MCH_MEGASTE )
	{
		*(U8*)0xFFFF8E21L &= 0x1;
	}
}

void		System_DataCacheEnable( void )
{
	if( gSystem.CPU == CPU_68030 )
	{
		System_SetDataCache030( 1 );
	}
	else if( gSystem.MCH == MCH_MEGASTE )
	{
		*(U8*)0xFFFF8E21L |= 0xFE;
	}
}

void	System_CalcInfo( void )
{
	System_SetMCH( System_CalcMCH() );
	System_SetCPU( System_CalcCPU() );
	System_SetFPU( System_CalcFPU() );
	System_SetDSP( System_CalcDSP() );
	System_SetMON( System_CalcMON() );
	System_SetVDO( System_CalcVDO() );
	System_SetTosVersion( System_CalcTosVersion() );
	System_SetBLT( System_CalcBLT() );
	System_SetEMU( System_CalcEMU() );
	System_SetEmuVersion( System_CalcEmuVersion() );
}

U16		System_CalcTosVersion( void )
{
	U16 *	lpVer;

	lpVer = (U16*)2L;
	return( *lpVer );
}

void		System_SetTosVersion( const U16 aTos )
{
	gSystem.TosVersion = aTos;
}

U16		System_GetTosVersion( void )
{
	return( gSystem.TosVersion );
}

U16		System_CalcEmuVersion( void )
{
	U16 	lVer;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lVer   = System_GetpEmuDesc()->VersionMajor;
		lVer <<= 8;
		lVer  |= System_GetpEmuDesc()->VersionMinor;
	}
	else
	{
		lVer = 0;
	}
	return( lVer );
}

void		System_SetEmuVersion( const U16 aVer )
{
	gSystem.EmuVersion = aVer;
}

U16		System_GetEmuVersion( void )
{
	return( gSystem.EmuVersion );
}

sSystemEmuDesc *		System_CalcpEmuDesc( void )
{
	sSystemEmuDesc * 	lpDesc;

	lpDesc = System_GetpEmuDescLL();
	if( (U32)lpDesc != 0x00FFC100L )
	{
		lpDesc = 0L;
	}
	return( lpDesc );
}

void		System_SetpEmuDesc( sSystemEmuDesc * apDesc )
{
	gSystem.pEmuDesc = apDesc;
}

sSystemEmuDesc *		System_GetpEmuDesc( void )
{
	return( gSystem.pEmuDesc );
}

U8			System_GetMhz( void )
{
	U8	lMhz;
	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lMhz = System_GetpEmuDesc()->Mhz;
	}
	else
	{
		switch( System_GetMCH() )
		{
		case	MCH_ST:
		case	MCH_STE:
		case	MCH_STBOOK:
		case	MCH_MEGASTE:
			lMhz = 8;
			break;
		case	MCH_TT:
			lMhz = 32;
			break;
		case	MCH_FALCON:
			lMhz = 16;
			break;
		default:
			lMhz = 8;
			break;
		}
	}

	return( lMhz );
}

U8			System_GetSlowMotionFlag( void )
{
	U8	lFlag;
	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lFlag = System_GetpEmuDesc()->SlowMotionFlag;
	}
	else
	{
		lFlag = 0;
	}

	return( lFlag );
}

U8			System_GetSlowMotionSpeed( void )
{
	U8	lSpeed;
	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lSpeed = System_GetpEmuDesc()->SlowMotionSpeed;
	}
	else
	{
		lSpeed = 0;
	}

	return( lSpeed );
}

U8			System_GetSnapShotFlag( void )
{
	U8	lFlag;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lFlag = System_GetpEmuDesc()->SnapShotFlag;
	}
	else
	{
		lFlag = 0;
	}

	return( lFlag );
}

void		System_SetSnapShotFlag( const U8 aFlag )
{
	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		System_GetpEmuDesc()->SnapShotFlag = aFlag;
	}
}

U8			System_GetFastForwardFlag( void )
{
	U8	lFlag;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lFlag = System_GetpEmuDesc()->FastForwardFlag;
	}
	else
	{
		lFlag = 0;
	}

	return( lFlag );
}

U8			System_GetDebugBuildFlag( void )
{
	U8	lFlag;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lFlag = System_GetpEmuDesc()->DebugBuildFlag;
	}
	else
	{
		lFlag = 0;
	}

	return( lFlag );
}

U16			System_GetCurrentSpeed( void )
{
	U16	lSpeed;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lSpeed = System_GetpEmuDesc()->CurrentSpeed;
	}
	else
	{
		lSpeed = 100;
	}

	return( lSpeed );
}
U16			System_GetRunSpeed( void )
{
	U16	lSpeed;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lSpeed = System_GetpEmuDesc()->RunSpeed;
	}
	else
	{
		lSpeed = 100;
	}

	return( lSpeed );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : System_GetCycleCounter( void )
* ACTION   : System_GetCycleCounter
* CREATION : 16.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	System_GetCycleCounter( void )
{
	U32	lCount;

	if( (System_GetEMU() == EMU_STEEM) && (System_GetpEmuDesc()) )
	{
		lCount = System_GetpEmuDesc()->CycleCounter;
	}
	else
	{
		lCount = 0;
	}

	return( lCount );
	
}



/*-----------------------------------------------------------------------------------*
* FUNCTION : System_SetCPUSpeed( const U16 aMhz )
* ACTION   : System_SetCPUSpeed
* CREATION : 16.11.2002 PNK
*-----------------------------------------------------------------------------------*/

void	System_SetCPUSpeed( const U16 aMhz )
{
	if( System_GetMCH() == MCH_MEGASTE )
	{
		if( aMhz > 8 )
		{
			*(U8*)0xFFFF8E21L |= 0x1;
		}
		else
		{
			*(U8*)0xFFFF8E21L &= 0xFE;
		}
	}
}


/* ################################################################################ */
