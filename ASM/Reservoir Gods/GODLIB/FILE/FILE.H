#ifndef	INCLUDED_FILE_H
#define	INCLUDED_FILE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\GEMDOS\GEMDOS.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

#define	sFileHandle	S16


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sFileHandle	File_Open(   char * apFname);
sFileHandle	File_Create( char * apFname);
S32			File_Read(  sFileHandle aHandle, U32 aBytes, void * apBuffer );
S32			File_Write( sFileHandle aHandle, U32 aBytes, void * apBuffer );
S32			File_Close( sFileHandle aHandle );

S32			File_SeekFromStart(   sFileHandle aHandle, S32 aOffset );
S32			File_SeekFromCurrent( sFileHandle aHandle, S32 aOffset );
S32			File_SeekFromEnd(     sFileHandle aHandle, S32 aOffset );

S32			File_Delete( char * apFname);
S32			File_Rename( char * apOldFname, char * apNewFname );

S32			File_GetAttribute( char * apFname);
S32			File_SetAttribute( char * apFname, U8 aAttrib );

S32			File_GetDateTime( sFileHandle aHandle, sGemDosDateTime * apDateTime );
S32			File_SetDateTime( sFileHandle aHandle, sGemDosDateTime * apDateTime );

void		File_SetDTA( sGemDosDTA * apDTA );

S32			File_ReadFirst( char * apFspec, U16 aAttribs );
S32			File_ReadNext( void );

U8			File_Exists(  char * apFileName );
S32			File_GetSize( char * apFileName );

void *		File_Load(   char * apFileName );
void *		File_LoadSlowRam( char * apFileName );
U8			File_LoadAt( char * apFileName, void * apBuffer );
void		File_UnLoad( void * apMem );

U8			File_Save( char * apFileName, void * apBuffer, U32 aBytes );


/* ################################################################################ */

#endif	/*	INCLUDED_FILE_H */