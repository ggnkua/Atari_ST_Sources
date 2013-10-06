#ifndef	INCLUDED_PROFILER_H
#define	INCLUDED_PROFILER_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

#include	<GODLIB\PROGRAM\PROGRAM.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dPROFILER_ID		mSTRING_TO_U32( 'P', 'R', 'O', 'F' )
#define	dPROFILER_VERSION	0


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U32		ID;
	U32		Version;
	U16		GameBuildHi;
	U16		GameBuildLo;
	U32		pText;
	U32		EntryCount;		/* will be null when loaded/saved, tools have to calc this */
	char	DateText[ 24 ];
	char	TimeText[ 16 ];
} sProfilerHeader;


typedef struct
{
	sProgramSymbol	Symbol;
	U32				Count;
} sProfilerSymbol;

typedef struct
{
	U32				Count;
	U32				Size;
	U32				HitCount;
} sProfilerSymbolHeader;

typedef struct
{
	sProfilerSymbolHeader	Header;
	sProfilerSymbol			Symbol[1];
} sProfilerSymbolTable;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

U8		Profiler_Init( const U16 aGameBuildHi, const U16 aGameBuildLo );
void	Profiler_DeInit( void );
void	Profiler_Update( void );

void	Profiler_Enable( void );
void	Profiler_Disable( void );

U8		Profiler_IsProfiling( void );
U8		Profiler_IsValid( const sProfilerHeader * apProfilerHeader );

sProfilerHeader *		Profiler_LoadProfile( char * apFileName );
sProfilerSymbolTable *	Profiler_BuildSymbolTable( const sProgramHeader * apProgram, const sProfilerHeader * apProfile );
void					Profiler_AddHit( sProfilerSymbolTable * apTable, const U32 aAddress );
void					Profiler_SymbolTableAddressSort( sProfilerSymbolTable * apTable );
void					Profiler_SymbolTableCountSort(   sProfilerSymbolTable * apTable );


/* ################################################################################ */

#endif	/*	INCLUDED_PROFILER_H */