/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: PROFILER.C
::
:: Interrupt based function profiling
::
:: [c] 2001 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"PROFILER.H"

#include	<STRING.H>

#include	<GODLIB\FILE\FILE.H>
#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\PROGRAM\PROGRAM.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dPROFILER_BUFFER_LIMIT	(32L*1024L)
#define	dPROFILER_SAVE_LIMIT	((dPROFILER_BUFFER_LIMIT*3)/4)


/* ###################################################################################
#  DATA
################################################################################### */

U32 *		gpProfilerBuffer = 0;
U32			gProfilerIndex;
U32			gProfilerOldHBL;
U8			gProfilerOnFlag;
sFileHandle	gProfilerHandle;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void	Profiler_HBL( void );
extern	void	Profiler_VBL( void );
extern	void	__text( void );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_Init( const U16 aGameBuildHi, const U16 aGameBuildLo)
* ACTION   : allocates memory for profiler buffer
* CREATION : 11.05.01 PNK
*-----------------------------------------------------------------------------------*/

U8		Profiler_Init( const U16 aGameBuildHi, const U16 aGameBuildLo)
{
	sProfilerHeader	lHeader;	

	gProfilerIndex  = 0;

	gProfilerOldHBL  = *(U32*)0x68;
	gProfilerOnFlag  = 0;
	gpProfilerBuffer = (U32*)Memory_Calloc( dPROFILER_BUFFER_LIMIT );
	gProfilerHandle  = File_Create( "PROFILE.PRO" );

	if( (!gpProfilerBuffer) || (gProfilerHandle <0) )
	{
		return( 0 );
	}

	lHeader.ID          = dPROFILER_ID;
	lHeader.Version     = 0;
	lHeader.EntryCount  = 0;
	lHeader.pText       = (U32)__text;
	lHeader.GameBuildHi = aGameBuildHi;
	lHeader.GameBuildLo = aGameBuildLo;
	strcpy( lHeader.DateText, __DATE__ );
	strcpy( lHeader.TimeText, __TIME__ );

	
	File_Write( gProfilerHandle, sizeof(sProfilerHeader), &lHeader );

	Vbl_AddCall( Profiler_VBL );

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_DeInit( void )
* ACTION   : releases memory allocated for profiler buffer
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void		Profiler_DeInit( void )
{
	Profiler_Disable();
	*(U32*)0x68 = gProfilerOldHBL;
	File_Close( gProfilerHandle );
	Memory_Release( gpProfilerBuffer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_Update( void )
* ACTION   : updates profiler
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void		Profiler_Update( void )
{
	if( gProfilerOnFlag )
	{
		if( gProfilerIndex > dPROFILER_SAVE_LIMIT )
		{
			Profiler_Disable();
			File_Write( gProfilerHandle, gProfilerIndex, gpProfilerBuffer );
			Profiler_Enable();
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_Enable( void )
* ACTION   : enables interrupt based profiling
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void	Profiler_Enable( void )
{
	if( gpProfilerBuffer )
	{
		gProfilerIndex  = 0;
		*(U32*)0x68     = (U32)Profiler_HBL;
		gProfilerOnFlag = 1;
		System_SetIML( 1 );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_Disable( void )
* ACTION   : enables interrupt based profiling
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void	Profiler_Disable( void )
{
	gProfilerOnFlag = 0;
	if( gpProfilerBuffer )
	{
		*(U32*)0x68     = gProfilerOldHBL;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_IsProfiling( void )
* ACTION   : returns true if the profiler has been initialised
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

U8		Profiler_IsProfiling( void )
{
	return( 0 != gpProfilerBuffer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_LoadProfile( char * apFileName )
* ACTION   : loads a profile file and fixes up the entry count
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

sProfilerHeader	*	Profiler_LoadProfile( char * apFileName )
{
	sProfilerHeader *	lpHeader;
	S32					lSize;

	lSize = File_GetSize( apFileName );
	if( lSize < sizeof(sProfilerHeader ) )
	{
		return( 0 );
	}

	lpHeader = File_Load( apFileName );
	if( lpHeader )
	{
		lSize -= sizeof(sProfilerHeader);
		lpHeader->EntryCount = lSize >> 2L;
	}

	return( lpHeader );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_BuildSymbolTable( const sProgramHeader * apProgram, const sProfilerHeader * apProfile )
* ACTION   : creates symbol table of count sorted symbols 
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

sProfilerSymbolTable *	Profiler_BuildSymbolTable( const sProgramHeader * apProgram, const sProfilerHeader * apProfile )
{
	sProfilerSymbolTable *	lpTable;
	sProgramSymbol *	lpSym;
	U32 *				lpEntries;
	U32					lValidCount;
	U32					lSymbolCount;
	U32					lTemp;
	U32					i,j;

	if( !apProgram )
	{
		return( 0 );
	}

	lValidCount = 0;

	lSymbolCount = apProgram->SymbolTableSize / sizeof(sProgramSymbol);

	lTemp  = (U32)apProgram;
	lTemp += sizeof(sProgramHeader);
	lTemp += apProgram->TextSize;
	lTemp += apProgram->DataSize;
	lpSym  = (sProgramSymbol *)lTemp;

	for( i=0; i<lSymbolCount; i++ )
	{
		if( ( lpSym[ i ].Type & (dPROGRAM_SYMBOL_GLOBAL | dPROGRAM_SYMBOL_EXTERN | dPROGRAM_SYMBOL_DATA | dPROGRAM_SYMBOL_TEXT | dPROGRAM_SYMBOL_BSS ) )
			&& (lpSym[ i ].Name[ 0 ] != '.' ) )
		{
			lValidCount++;
		}
	}

	printf( "valid count :%ld\n", lValidCount );

	if( !lValidCount )
	{
		return( 0 );
	}

	lTemp  = sizeof(sProfilerSymbol);
	lTemp *= lValidCount+1;
	lTemp += sizeof(sProfilerSymbolHeader);
	lpTable = (sProfilerSymbolTable*)Memory_Calloc( lTemp );

	lpTable->Header.Count = lValidCount;
	j = 0;
	for( i=0; i<lSymbolCount; i++ )
	{
		if( ( lpSym[ i ].Type & (dPROGRAM_SYMBOL_GLOBAL | dPROGRAM_SYMBOL_EXTERN | dPROGRAM_SYMBOL_DATA | dPROGRAM_SYMBOL_TEXT | dPROGRAM_SYMBOL_BSS ) )
			&& (lpSym[ i ].Name[ 0 ] != '.' ) )
		{
			lpTable->Symbol[ j ].Symbol = lpSym[ i ];
			lpTable->Symbol[ j ].Count  = 0;
			j++;
		}
	}
	lpTable->Header.Size = apProgram->TextSize + apProgram->DataSize + apProgram->BSSSize;
	strcpy( lpTable->Symbol[ lValidCount ].Symbol.Name, "DA_END" );
	lpTable->Symbol[ lValidCount ].Symbol.Value = lpTable->Header.Size;

	
	printf( "program size %ld\n", lpTable->Header.Size );
	printf( "pText %lX\n", apProfile->pText );

	Profiler_SymbolTableAddressSort( lpTable );


	lTemp  = (U32)apProfile;
	lTemp += sizeof(sProfilerHeader);
	lpEntries = (U32*)lTemp;
	lpTable->Header.HitCount = 0;
	for( i=0; i<apProfile->EntryCount; i++ )
	{
		Profiler_AddHit( lpTable, lpEntries[ i ] - (U32)apProfile->pText );
	}

	Profiler_SymbolTableCountSort( lpTable );

	return( lpTable );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_AddHit( sProfilerSymbolTable * apTable, const U32 aAddress )
* ACTION   : adds a hit of function at aAddress to apTable
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void	Profiler_AddHit( sProfilerSymbolTable * apTable, const U32 aAddress )
{
	U32		i;
	U32		lStep;

	if( aAddress < apTable->Header.Size )
	{
		lStep = (apTable->Header.Count+1) >> 1;
		i     = lStep;

		while( lStep > 1 )
		{
			lStep = (lStep+1) >> 1;

			if( aAddress >= apTable->Symbol[ i ].Symbol.Value )
			{
				if( aAddress < apTable->Symbol[ i+1 ].Symbol.Value )
				{
					apTable->Header.HitCount++;
					apTable->Symbol[ i ].Count++;
					return;
				}
				i += lStep;
			}
			else
			{
				i -= lStep;
			}
		}
		if( aAddress >= apTable->Symbol[ i ].Symbol.Value )
		{
			if( aAddress < apTable->Symbol[ i+1 ].Symbol.Value )
			{
				apTable->Header.HitCount++;
				apTable->Symbol[ i ].Count++;
				return;
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_SymbolAddressCmp( const sProfilerSymbol * apSym0,  const sProfilerSymbol * apSym1 )
* ACTION   : address comparison for symbol table qsort
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

int		Profiler_SymbolAddressCmp( const sProfilerSymbol * apSym0,  const sProfilerSymbol * apSym1 )
{
	S32	lVal;

	lVal  = apSym0->Symbol.Value;
	lVal -= apSym1->Symbol.Value;

	if( lVal > 0 )
	{
		return( 1 );
	}
	if( lVal < 0 )
	{
		return( -1 );
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_SymbolCountCmp( const sProfilerSymbol * apSym0,  const sProfilerSymbol * apSym1 )
* ACTION   : count comparison for symbol table qsort
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

int		Profiler_SymbolCountCmp( const sProfilerSymbol * apSym0,  const sProfilerSymbol * apSym1 )
{
	S32	lVal;

	lVal  = apSym0->Count;
	lVal -= apSym1->Count;

	if( lVal > 0 )
	{
		return( -1 );
	}
	if( lVal < 0 )
	{
		return( 1 );
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_SymbolTableAddressSort( sProfilerSymbolTable * apTable )
* ACTION   : sorts symbol table by address
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void	Profiler_SymbolTableAddressSort( sProfilerSymbolTable * apTable )
{
	qsort( &apTable->Symbol[ 0 ], apTable->Header.Count, sizeof(sProfilerSymbol), Profiler_SymbolAddressCmp );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_SymbolTableCountSort( sProfilerSymbolTable * apTable )
* ACTION   : sorts symbol table by count
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

void	Profiler_SymbolTableCountSort( sProfilerSymbolTable * apTable )
{
	qsort( &apTable->Symbol[ 0 ], apTable->Header.Count, sizeof(sProfilerSymbol), Profiler_SymbolCountCmp );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Profiler_IsValid( const sProfilerHeader * apHeader )
* ACTION   : returns true if profiler file format is valid
* CREATION : 01.05.01 PNK
*-----------------------------------------------------------------------------------*/

U8		Profiler_IsValid( const sProfilerHeader * apHeader )
{
	if( !apHeader )
	{
		return( 0 );
	}
	return( apHeader->ID == dPROFILER_ID );
}


/* ################################################################################ */
