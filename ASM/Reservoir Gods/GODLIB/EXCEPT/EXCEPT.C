/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"EXCEPT.H"

#include	<GODLIB\FONT8X8\FONT8X8.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>

/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dEXCEPT_LIMIT	(64-(2+7+4))


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U32	DataRegs[ 8 ];
	U32	AddressRegs[ 8 ];
	U32	PC;
	U16	SR;
	U16	ExceptType;
} sExceptInfo;


/* ###################################################################################
#  DATA
################################################################################### */

char *	gExceptStrings[] =
{
	"0",					/*	0	0x00 */
	"4",					/*	1	0x04 */
	"BUS ERROR",			/*	2	0x08 */
	"ADDRESS ERROR",		/*	3	0x0C */
	"ILLEGAL",				/*	4	0x10 */
	"DIVIDE BY ZERO",		/*	5	0x14 */
	"CHK/CHK2",				/*	6	0x18 */
	"TRAPcc",				/*	7	0x1C */
	"PRIV VIOLATION",		/*	8	0x20 */
	"TRACE",				/*	9	0x24 */
	"LINE-A",				/* 10	0x28 */
	"LINE-F",				/* 11	0x2C */
	"RESERVED",				/* 12	0x30 */
	"CO-PRO VIOLATION",		/* 13	0x34 */
	"FORMAT ERROR",			/* 14	0x38 */
	"UNINIT INTERRUPT",		/* 15	0x3C */
	"RESERVED",				/* 16	0x40 */
	"RESERVED",				/* 17	0x44 */
	"RESERVED",				/* 18	0x48 */
	"RESERVED",				/* 19	0x4C */
	"RESERVED",				/* 20	0x50 */
	"RESERVED",				/* 21	0x54 */
	"RESERVED",				/* 22	0x58 */
	"RESERVED",				/* 23	0x5C */
	"SPURIOUS INTERRUPT",	/* 24	0x60 */
	"LEVEL 1 INT",			/* 25	0x64 */
	"LEVEL 2 INT",			/* 26	0x68 */
	"LEVEL 3 INT",			/* 27	0x6C */
	"LEVEL 4 INT",			/* 28	0x70 */
	"LEVEL 5 INT",			/* 29	0x74 */
	"LEVEL 6 INT",			/* 30	0x78 */
	"LEVEL 7 INT",			/* 31	0x7C */
	"TRAP #0",				/* 32	0x80 */
	"TRAP #1",				/* 33	0x84 */
	"TRAP #2",				/* 34	0x88 */
	"TRAP #3",				/* 35	0x8C */
	"TRAP #4",				/* 36	0x90 */
	"TRAP #5",				/* 37	0x94 */
	"TRAP #6",				/* 38	0x98 */
	"TRAP #7",				/* 39	0x9C */
	"TRAP #8",				/* 40	0xA0 */
	"TRAP #9",				/* 41	0xA4 */
	"TRAP #10",				/* 42	0xA8 */
	"TRAP #11",				/* 43	0xAC */
	"TRAP #12",				/* 44	0xB0 */
	"TRAP #13",				/* 45	0xB4 */
	"TRAP #14",				/* 46	0xB8 */
	"TRAP #15",				/* 47	0xBC */
	"FP BRANCH",			/* 48	0xC0 */
	"FP INEXACT RESULT",	/* 49	0xC4 */
	"FP DIVIDE BY ZERO",	/* 50	0xC8 */
	"FP UNDERFLOW",			/* 51	0xCC */
	"FP OP ERROR",			/* 52	0xD0 */
	"FP OVERFLOW",			/* 53	0xD4 */
	"FP NAN",				/* 54	0xD8 */
	"FP DATA ERROR",		/* 55	0xDC */
	"MMU CONFIG ERROR",		/* 56	0xE0 */
	"MMU ILLEGAL OP",		/* 57	0xE4 */
	"MMU ACCESS VIOLATE",	/* 58	0xEC */
	"RESERVED",				/* 59	0x58 */
	"RESERVED",				/* 60	0x5C */
	"RESERVED",				/* 61	0x60 */
	"RESERVED",				/* 62	0x64 */
	"RESERVED",				/* 63	0x68 */
};

U16 *			gpExceptScreen;
sExceptInfo		gExceptInfo;

U16				gExceptVecIndices[ dEXCEPT_LIMIT ] =
{
	    2, 3, 4, 5, 6, 7, 8, 9,11,
	12,13,14,15,16,17,18,19,20,21,
	22,23,24,32,35,36,37,38,39,40,
	41,42,43,44,47,48,49,50,51,52,
	53,54,55,56,57,58,59,60,60,60,
	60,60
};

U32				gExceptOldVectors[ dEXCEPT_LIMIT ];


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

U16 *	Except_GetpPhysic( void );
void	Except_ShowRegisters( sExceptInfo * apInfo);
void	Except_InitScreen( void );
void	Except_ClearScreen( void );
void	Except_SetPal( void );
U16 *	Except_GetpPhysic( void );

extern	U32		gExcept_HandlersTable[ 64 ];
extern	void	Except_Handler68000( void );
extern	void	Except_Handler68030( void );
extern	void	__text( void );


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_Init( void )
* ACTION   : inits exception handler
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_Init()
{
	U32 *	lpVecs;
	U32		lHandler;
	U16		i;

	lpVecs = (U32*)0;

	for( i=0; i<dEXCEPT_LIMIT; i++ )
	{
		gExceptOldVectors[ i ] = lpVecs[ gExceptVecIndices[i] ];
	}

	switch( System_GetCPU() )
	{
	case	CPU_68030:
		lHandler = (U32)Except_Handler68030;
		for( i=2; i<10; i++ )
		{
			lpVecs[ i ] = lHandler;
		}
		for( i=12; i<25; i++ )
		{
			lpVecs[ i ] = lHandler;
		}
		lpVecs[ 32 ] = lHandler;
		for( i=35; i<45; i++ )
		{
			lpVecs[ i ] = lHandler;
		}
		for( i=47; i<64; i++ )
		{
			lpVecs[ i ] = lHandler;
		}
		break;
	default:
		for( i=2; i<10; i++ )
		{
			lpVecs[ i ] = gExcept_HandlersTable[ i ];
		}
		for( i=12; i<25; i++ )
		{
			lpVecs[ i ] = gExcept_HandlersTable[ i ];
		}
		lpVecs[ 32 ] = gExcept_HandlersTable[ 32 ];
		for( i=35; i<45; i++ )
		{
			lpVecs[ i ] = gExcept_HandlersTable[ i ];
		}
		for( i=47; i<64; i++ )
		{
			lpVecs[ i ] = gExcept_HandlersTable[ i ];
		}
		break;
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_DeInit( void )
* ACTION   : deinits exception handler
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_DeInit()
{
	U32 *	lpVecs;
	U16		i;

	lpVecs = (U32*)0;

	for( i=0; i<dEXCEPT_LIMIT; i++ )
	{
		lpVecs[ gExceptVecIndices[i] ] = gExceptOldVectors[ i ];
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_Main()
* ACTION   : displays crash info and freezes
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_Main()
{
	Except_InitScreen();
	Except_ShowRegisters( &gExceptInfo );
	while( 1 )
	{
		Except_SetPal();
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_ShowRegisters( sExceptInfo * apInfo)
* ACTION   : displays registers
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_ShowRegisters( sExceptInfo * apInfo)
{
	char	lString[ 96 ];
	U8 *	lpStack;
	U16		lY;
	U16		lX;
	U16		i;

	lY = 0;
	for( i=0; i<8; i++ )
	{
		sprintf( lString, "D%d: %08lX    A%d: %08lX", i, apInfo->DataRegs[ i ], i, apInfo->AddressRegs[ i ] );
		Font8x8_Print( lString, Except_GetpPhysic(), 0, lY );
		lY += 8;
	}
	sprintf( lString, "SR   : %04X", apInfo->SR );
	Font8x8_Print( lString, Except_GetpPhysic(), 0, lY );
	lY += 8;

	sprintf( lString, "CRASH: %s", gExceptStrings[ apInfo->ExceptType & 63 ] );
	Font8x8_Print( lString, Except_GetpPhysic(), 0, lY );
	lY += 8;

	sprintf( lString, "PC   : %08lX", apInfo->PC );
	Font8x8_Print( lString, Except_GetpPhysic(), 0, lY );
	lY += 8;

	sprintf( lString, "TEXT : %08lX", __text );
	Font8x8_Print( lString, Except_GetpPhysic(), 0, lY );
	lY += 8;

	sprintf( lString, "OFF  : %08lX", apInfo->PC - (U32)__text );
	Font8x8_Print( lString, Except_GetpPhysic(), 0, lY );
	lY += 8;

	Font8x8_Print( "STACK:", Except_GetpPhysic(), 0, lY );
	lX = (7*8);

	lpStack = (U8*)apInfo->AddressRegs[ 7 ];
	for( i=0; i<10; i++ )
	{
		sprintf( lString, "%02X%02X %02X%02X %02X%02X %02X%02X %02X%02X",
			lpStack[ 0 ],lpStack[ 1 ],lpStack[ 2 ],lpStack[ 3 ],
			lpStack[ 4 ],lpStack[ 5 ],lpStack[ 6 ],lpStack[ 7 ],
			lpStack[ 8 ],lpStack[ 9 ] );
		Font8x8_Print( lString, Except_GetpPhysic(), lX, lY );
		lY += 8;
		lpStack += 10;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_InitScreen( void )
* ACTION   : inits screen
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_InitScreen( void )
{
	U32	lScr0;
	U32	lScr1;
	U32	lScr2;

	lScr0 = *(U8*)0xFFFF8201L;
	lScr1 = *(U8*)0xFFFF8203L;
	lScr2 = *(U8*)0xFFFF820DL;

	lScr0 &= 0xFF;
	lScr1 &= 0xFF;
	lScr2 &= 0xFF;

	lScr0 <<= 16;
	lScr1 <<= 8;

	lScr0 |= lScr1;
	lScr1 |= lScr2;

	gpExceptScreen = (U16*)lScr0;
	Except_ClearScreen();
	Except_SetPal();
	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_ClearScreen( void )
* ACTION   : clears screen
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_ClearScreen( void )
{
	U16 *	lpScreen;
	U16		i;

	lpScreen = Except_GetpPhysic();
	for( i=0; i<(32000/2); i++ )
	{
		*lpScreen++ = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_SetPal( void )
* ACTION   : sets palette
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

void	Except_SetPal( void )
{
	U16 *	lpPal;
	U16		i;

	lpPal = (U16*)0xFFFF8240L;

	lpPal[ 0 ] = 0;
	for( i=1; i<16; i++ )
	{
		lpPal[ i ] = 0x0777;
	}
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : Except_GetpPhysic( void )
* ACTION   : returns pointer to physical screen
* CREATION : 16.11.01 PNK
*-----------------------------------------------------------------------------------*/

U16 *	Except_GetpPhysic( void )
{
	return( gpExceptScreen );
}