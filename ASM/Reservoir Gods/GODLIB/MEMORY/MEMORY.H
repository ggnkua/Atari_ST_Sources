#ifndef	INCLUDED_MEMORY_H
#define	INCLUDED_MEMORY_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void * 	Memory_Alloc(  const U32 aSize );
void *	Memory_Calloc( const U32 aSize );

void *	Memory_ScreenAlloc(  const U32 aSize );
void *	Memory_ScreenCalloc( const U32 aSize );

S32		Memory_Release( void * apMem );

void	Memory_Clear( U32 aSize, void * apMem );
void	Memory_Copy(  U32 aSize, const void * apSrc, void * apDst );

U32		Memory_GetAllocCount( void );
U32		Memory_GetAllocatedSize( void );
U32		Memory_GetHighTide( void );
U32		Memory_GetLargestAlloc( void );
U32		Memory_GetSmallestAlloc( void );
U32		Memory_GetFailedSize( void );

U32		Memory_GetSize( void );


/* ################################################################################ */

#endif	/*	INCLUDED_MEMORY_H	*/