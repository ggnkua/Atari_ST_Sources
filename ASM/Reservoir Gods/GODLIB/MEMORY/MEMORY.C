/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: MEMORY.C
::
:: Low level memory management routines
::
:: This file contains all the platform specific memory management routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"MEMORY.H"

#include	<GODLIB\GEMDOS\GEMDOS.H>
#include	<GODLIB\DEBUG\DEBUG.H>
#include	<GODLIB\DEBUGLOG\DEBUGLOG.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dMEMORY_RECORD_LIMIT	2048


/* ###################################################################################
#  ENUMERATED TYPES
################################################################################### */

enum
{
	eMX_STRAM = 0,
	eMX_TTRAM = 1,
	eMX_PREFSTRAM = 2,
	eMX_PREFTTRAM = 2
};


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	void *	pMem;
	U32		Size;
} sMemoryTrackRecord;

sMemoryTrackRecord	gMemoryRecord[ dMEMORY_RECORD_LIMIT ];


/* ###################################################################################
#  DATA
################################################################################### */

U32	gMemoryAllocCount    = 0;
U32	gMemoryAllocatedSize = 0;
U32	gMemoryFailedSize    = 0;
U32	gMemoryHighTide      = 0;
U32 gMemoryLargestAlloc  = 0;
U32	gMemorySmallestAlloc = 0x7FFFFFFL;

U8	gMemoryTrackInitialised = 0;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void					Memory_TrackInit( void );
void					Memory_TrackAlloc( const void * apMem, const U32 aSize );
void					Memory_TrackFree( const void * apMem );
sMemoryTrackRecord *	Memory_TrackGetFreeRecord( void );
sMemoryTrackRecord *	Memory_TrackFindRecord( const void * apMem );


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_TrackInit()
* ACTION   : initialises memory tracking
* CREATION : 16.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Memory_TrackInit()
{
	U16	i;

	gMemoryAllocCount    = 0;
	gMemoryAllocatedSize = 0;
	gMemoryHighTide      = 0;
	gMemoryLargestAlloc  = 0;
	gMemoryFailedSize    = 0;
	gMemorySmallestAlloc = 0x7FFFFFFFL;

	for( i=0; i<dMEMORY_RECORD_LIMIT; i++ )
	{
		gMemoryRecord[ i ].pMem = 0;
		gMemoryRecord[ i ].Size = 0;
	}

	gMemoryTrackInitialised = 1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_TrackGetFreeRecord()
* ACTION   : returns a free space in records array
* CREATION : 16.01.01 PNK
*-----------------------------------------------------------------------------------*/

sMemoryTrackRecord *	Memory_TrackGetFreeRecord()
{
	U16	i;

	for( i=0; i<dMEMORY_RECORD_LIMIT; i++ )
	{
		if( !gMemoryRecord[ i ].pMem )
		{
			return( &gMemoryRecord[ i ] );
		}
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_TrackFindRecord( const void * apMem )
* ACTION   : finds record with specified address
* CREATION : 16.01.01 PNK
*-----------------------------------------------------------------------------------*/

sMemoryTrackRecord *	Memory_TrackFindRecord( const void * apMem )
{
	U16	i;

	for( i=0; i<dMEMORY_RECORD_LIMIT; i++ )
	{
		if( apMem == gMemoryRecord[ i ].pMem )
		{
			return( &gMemoryRecord[ i ] );
		}
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_TrackAlloc( const void * apMem )
* ACTION   : tracks memory allocations
* CREATION : 16.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Memory_TrackAlloc( const void * apMem, const U32 aSize )
{
	sMemoryTrackRecord *	lpRecord;

	if( !gMemoryTrackInitialised )
	{
		Memory_TrackInit();
	}

	if( !apMem )
	{
		gMemoryFailedSize += aSize;
		return;
	}

	gMemoryAllocCount++;
	gMemoryAllocatedSize += aSize;
	if( aSize > gMemoryLargestAlloc )
	{
		gMemoryLargestAlloc = aSize;
	}
	if( aSize < gMemorySmallestAlloc )
	{
		gMemorySmallestAlloc = aSize;
	}
	if( gMemoryAllocatedSize > gMemoryHighTide )
	{
		gMemoryHighTide = gMemoryAllocatedSize;
	}

	lpRecord = Memory_TrackGetFreeRecord();
	if( lpRecord )
	{
		lpRecord->pMem = (void*)apMem;
		lpRecord->Size = aSize;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_TrackFree( const void * apMem )
* ACTION   : tracks memory frees
* CREATION : 16.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Memory_TrackFree( const void * apMem )
{
	sMemoryTrackRecord *	lpRecord;

	if( !gMemoryTrackInitialised )
		Memory_TrackInit();

	if( !apMem )
		return;


	gMemoryAllocCount--;

	lpRecord = Memory_TrackFindRecord( apMem );
	if( lpRecord )
	{
		gMemoryAllocatedSize -= lpRecord->Size;

		lpRecord->pMem = 0;
		lpRecord->Size = 0;
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_Alloc( const U32 aSize )
* ACTION   : allocates memory of specified size
*            FastRAM allocated if available. memory is not cleared.
*            do NOT use this call to allocate memory for the screen!
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

void *	Memory_Alloc( const U32 aSize )
{
	void *	lpMem;

	if( System_GetTosVersion() > 0x200 )
	{
		lpMem = GemDos_Mxalloc( aSize, eMX_PREFTTRAM );
	}
	else
	{
		lpMem = GemDos_Malloc( aSize );
	}
	Debug_Action( Memory_TrackAlloc( lpMem, aSize ) );

	return( lpMem );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_ScreenAlloc( U32 aSize )
* ACTION   : allocates memory of specified size
*            allocates ST RAM for the screen. memory not cleared.
*            only use this call to allocate memory for the screen!
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

void * 	Memory_ScreenAlloc( const U32 aSize )
{
	void *	lpMem;

	if( System_GetTosVersion() > 0x200 )
	{
		lpMem = GemDos_Mxalloc( aSize, eMX_STRAM );
	}
	else
	{
		lpMem = GemDos_Malloc( aSize );
	}
	
	if( !lpMem )
	{
		DebugLog_Printf1( "Memory_ScreenAlloc() : failed %ld bytes\n", aSize );
	}

	
	Debug_Action( Memory_TrackAlloc( lpMem, aSize ) );

	return( lpMem );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_Calloc( U32 aSize )
* ACTION   : allocates memory of specified size and clears it
*            FastRAM allocated if available.
*            do NOT use this call to allocate memory for the screen!
* CREATION : 11.04.99 PNK
*-----------------------------------------------------------------------------------*/

void *	Memory_Calloc( const U32 aSize )
{
	void * lpMem;

	lpMem = Memory_Alloc( aSize );

	if( lpMem )
	{
		Memory_Clear( aSize, lpMem );
	}
	else
	{
		DebugLog_Printf1( "Memory_Calloc() : failed %ld bytes\n", aSize );
	}

	return( lpMem );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_ScreenCalloc( U32 aSize )
* ACTION   : allocates screen memory of specified size and clears it
*            ST RAM only allocated.
*            only use this call to allocate memory for the screen!
* CREATION : 11.04.99 PNK
*-----------------------------------------------------------------------------------*/

void *	Memory_ScreenCalloc( const U32 aSize )
{
	void * lpMem;

	lpMem = Memory_ScreenAlloc( aSize );

	if( lpMem )
	{
		Memory_Clear( aSize, lpMem );
	}
	else
	{
		DebugLog_Printf1( "Memory_ScreenCalloc() : failed %ld bytes\n", aSize );
	}

	return( lpMem );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_Release( void * apMem )
* ACTION   : frees memory
*            error handling included. returns error code or 0
* CREATION : 11.04.99 PNK
*-----------------------------------------------------------------------------------*/

S32		Memory_Release( void * apMem )
{
	if( apMem )
	{
		Debug_Action( Memory_TrackFree( apMem ) );
		return( (S32)GemDos_Mfree( apMem ) );
	}
	else
	{
		DebugLog_Printf0( "Memory_Release() : failed %lX\n" );
		return( -1 );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_Clear( U32 aSize, void * apMem)
* ACTION   : clear aSize bytes from pMem
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

void	Memory_Clear( U32 aSize, void * apMem )
{
	U8	*	lpMem;

	if( apMem )
	{
		lpMem = (U8 *)apMem;

		while( aSize-- )
		{
			*lpMem++ = 0;
		}
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_Copy( U32 aSize, void * apSrc, void * apDst )
* ACTION   : copies size bytes from src to dest
*            error handling included
*            this routine needs optimizing!
* CREATION : 11.04.99 PNK
*-----------------------------------------------------------------------------------*/

void	Memory_Copy( U32 aSize, const void * apSrc, void * apDst )
{
	U8 *	lpSrc;
	U8 *	lpDst;

	lpSrc = (U8 *)apSrc;
	lpDst = (U8 *)apDst;

	if( (lpSrc) && (lpDst) )
	{
		if( lpSrc < lpDst )
		{
			lpSrc += aSize;
			lpDst += aSize;
			while( aSize-- )
			{
				*--lpDst = *--lpSrc;
			}
		}
		else
		{
			while( aSize-- )
			{
				*lpDst++ = *lpSrc++;
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetFree( void )
* ACTION   : returns amount of free memory
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U32		Memory_GetFree( void )
{
	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetAllocCount( void )
* ACTION   : returns number 
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetAllocCount( void )
{
	return( gMemoryAllocCount );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetAllocatedSize( void )
* ACTION   : returns amount of memory allocated
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetAllocatedSize( void )
{
	return( gMemoryAllocatedSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetHighTide( void )
* ACTION   : returns high tide for memory allocations
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetHighTide( void )
{
	return( gMemoryHighTide );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetLargestAlloc( void )
* ACTION   : returns size of largest alloc
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetLargestAlloc( void )
{
	return( gMemoryLargestAlloc );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetSmallestAlloc( void )
* ACTION   : returns size of smallest alloc
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetSmallestAlloc( void )
{
	return( gMemorySmallestAlloc );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetFailedSize( void )
* ACTION   : Memory_GetFailedSize
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetFailedSize( void )
{
	return( gMemoryFailedSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Memory_GetSize( void )
* ACTION   : Memory_GetSize
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	Memory_GetSize( void )
{
	U32 *	lpRamTop;

	lpRamTop = (U32*)0x42EL;
	return( *lpRamTop );
}


/* ################################################################################ */
