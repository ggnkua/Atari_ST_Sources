#ifndef	INCLUDED_DEBUGLOG_H
#define	INCLUDED_DEBUGLOG_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<STRING.H>
#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  VARIABLE PROTOTYPES
################################################################################### */

extern	char gDebugLogString[ 1024 ];


/* ###################################################################################
#  FUNCTION PROTOTYPES
################################################################################### */

void	DebugLog_Init( char * apFileName );
void	DebugLog_DeInit( void );
void	DebugLog_AddString( char * apString );


/* ###################################################################################
#  MACROS
################################################################################### */

#ifdef	dDEBUG

#define	DebugLog_Printf0(S)			DebugLog_AddString( S )
#define	DebugLog_Printf1(S,A)		sprintf( gDebugLogString, S, A ); DebugLog_AddString( gDebugLogString )
#define	DebugLog_Printf2(S,A,B)		sprintf( gDebugLogString, S, A, B ); DebugLog_AddString( gDebugLogString )
#define	DebugLog_Printf3(S,A,B,C)	sprintf( gDebugLogString, S, A, B, C ); DebugLog_AddString( gDebugLogString )
#define	DebugLog_Printf4(S,A,B,C,D)	sprintf( gDebugLogString, S, A, B, C, D ); DebugLog_AddString( gDebugLogString )

#else

#define	DebugLog_Printf0(S)
#define	DebugLog_Printf1(S,A)
#define	DebugLog_Printf2(S,A,B)
#define	DebugLog_Printf3(S,A,B,C)
#define	DebugLog_Printf4(S,A,B,C,D)

#endif


/* ################################################################################ */

#endif	/*	INCLUDED_DEBUGLOG_H	*/