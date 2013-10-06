#ifndef	INCLUDED_DRIVE_H
#define	INCLUDED_DRIVE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

S32		Drive_CreateDirectory( char * apDirName );
S32		Drive_DeleteDirectory( char * apDirName );

S32		Drive_GetFree(  U16 aDrive );

U16		Drive_GetDrive( void );
S32		Drive_SetDrive( U16 aDrive );

S32		Drive_GetPath( U16 aDrive, char * apPath );
S32		Drive_SetPath( char * apPath );


/* ################################################################################ */

#endif	/*	INCLUDED_DRIVE_H	*/