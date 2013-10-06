/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: FILE.C
::
:: Low level file access routines
::
:: This file contains all the platform specific file manipulation routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"FILE.H"

#include	<GODLIB\GEMDOS\GEMDOS.H>
#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Open( char * apFname )
* ACTION   : opens a file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

sFileHandle		File_Open( char * apFname )
{
	return( (sFileHandle)GemDos_Fopen( apFname, dGEMDOS_S_READWRITE ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Create( char * apFname )
* ACTION   : creates a file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

sFileHandle		File_Create( char * apFname )
{
	return( (sFileHandle)GemDos_Fcreate( apFname, 0 ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Read( sFileHandle aHandle U32 aBytes, void * apBuffer )
* ACTION   : reads aBytes from file with handle aHandle to buffer apBuffer
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_Read( sFileHandle aHandle, U32 aBytes, void * apBuffer )
{
	return( GemDos_Fread( aHandle, aBytes, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Write( sFileHandle aHandle U32 aBytes, void * apBuffer )
* ACTION   : writes aBytes from file with handle aHandle to buffer apBuffer
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_Write( sFileHandle aHandle, U32 aBytes, void * apBuffer )
{
	return( GemDos_Fwrite( aHandle, aBytes, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_SeekFromStart( sFileHandle aHandle, S32 aOffset )
* ACTION   : seeks aOffset bytes from start of file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_SeekFromStart( sFileHandle aHandle, S32 aOffset )
{
	return( GemDos_Fseek( aOffset, aHandle, SEEK_SET ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_SeekFromCurrent( sFileHandle aHandle, S32 aOffset )
* ACTION   : seeks aOffset bytes from current file position
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_SeekFromCurrent( sFileHandle aHandle, S32 aOffset )
{
	return( GemDos_Fseek( aOffset, aHandle, SEEK_SET ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_SeekFromEnd( sFileHandle aHandle, S32 aOffset )
* ACTION   : seeks aOffset bytes from end of file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_SeekFromEnd( sFileHandle aHandle, S32 aOffset )
{
	return( GemDos_Fseek( aOffset, aHandle, SEEK_END ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Close( S32 aHandle )
* ACTION   : closes currently open file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_Close( sFileHandle aHandle )
{
	return( GemDos_Fclose( aHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Delete( char * apFname )
* ACTION   : deletes a file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_Delete( char * apFname )
{
	return( GemDos_Fdelete( apFname ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Rename( char * apOldFname, char * apNewFname )
* ACTION   : renames a file - can also be used to move a file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_Rename( char * apOldFname, char * apNewFname )
{
	return( GemDos_Frename( 0, apOldFname, apNewFname ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_GetAttribute( char * apFname )
* ACTION   : gets attribute of specified file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_GetAttribute( char * apFname )
{
	return( GemDos_Fattrib( apFname, 0, 0 ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_SetAttribute( char * apFname, U8 aAttrib )
* ACTION   : sets attribute of specified file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_SetAttribute( char * apFname, U8 aAttrib )
{
	return( GemDos_Fattrib( apFname, 1, aAttrib ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_GetDateTime( sFileHandle aHandle, DOSTIME * apDateTime )
* ACTION   : gets date & time of specified file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_GetDateTime( sFileHandle aHandle, sGemDosDateTime * apDateTime )
{
	return( GemDos_Fdatime( apDateTime, aHandle, 0 ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_SetDateTime( sFileHandle aHandle, DOSTIME * apDateTime )
* ACTION   : gets date & time of specified file
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_SetDateTime( sFileHandle aHandle, sGemDosDateTime * apDateTime )
{
	return( GemDos_Fdatime( apDateTime, aHandle, 1 ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_SetDTA( DTA * apDTA )
* ACTION   : sets default DTA address
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

void	File_SetDTA( sGemDosDTA * apDTA )
{
	GemDos_Fsetdta( apDTA );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_ReadFirst( char * apFspec, U16 aAttribs )
* ACTION   : reads DTA of first file in directory with file spec apFspec
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_ReadFirst( char * apFspec, U16 aAttribs )
{
	return( GemDos_Fsfirst( apFspec, aAttribs ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_ReadNext()
* ACTION   : reads DTA of next file in directory with file spec from File_ReadFirst()
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_ReadNext()
{
	return( GemDos_Fsnext() );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Exists( char * apFileName )
* ACTION   : checks to see if file exits
* RETURNS  : 1 : file exits
*            0 : file not found
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U8		File_Exists( char * apFileName )
{
	sFileHandle	lHandle;

	lHandle = File_Open( apFileName );
	if( lHandle > 0 )
	{
		File_Close( lHandle );
		return( 1 );
	}
	return( 0 );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_GetSize( char * apFileName )
* ACTION   : gets size of a file
* RETURNS  : file size (positive )
*            or negative error code
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		File_GetSize( char * apFileName )
{
	sFileHandle	lHandle;
	S32				lSize;

	lHandle = File_Open( apFileName );
	if( lHandle <= 0 )
	{
		return( lHandle );
	}

	lSize = File_SeekFromEnd( lHandle, 0 );
	File_Close( lHandle );

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_Load( char * apFileName )
* ACTION   : allocates memory and loads a file
* RETURNS  : pointer to file in memory
* CREATION : 11.01.99 PNK
*-----------------------------------------------------------------------------------*/

void *	File_Load( char * apFileName )
{
	sFileHandle	lHandle;
	S32				lSize;
	void *			lpBuffer;

	lSize = File_GetSize( apFileName );
	if( lSize <= 0 )
	{
		return( 0 );
	}

	lHandle = File_Open( apFileName );
	if( lHandle <= 0 )
	{
		return( 0 );
	}

	lpBuffer = Memory_Alloc( lSize );

	File_Read( lHandle, lSize, lpBuffer );

	File_Close( lHandle );

	return( lpBuffer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : File_LoadSlowRam( char * apFileName )
* ACTION   : allocates memory and loads a file
* RETURNS  : pointer to file in memory
* CREATION : 11.01.99 PNK
*-----------------------------------------------------------------------------------*/

void *	File_LoadSlowRam( char * apFileName )
{
	sFileHandle	lHandle;
	S32				lSize;
	void *			lpBuffer;

	lSize = File_GetSize( apFileName );
	if( lSize <= 0 )
	{
		return( 0 );
	}

	lHandle = File_Open( apFileName );
	if( lHandle <= 0 )
	{
		return( 0 );
	}

	lpBuffer = Memory_ScreenAlloc( lSize );

	File_Read( lHandle, lSize, lpBuffer );

	File_Close( lHandle );

	return( lpBuffer );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : File_LoadAt( char * apFileName, void * apBuffer )
* ACTION   : loads a file to apBuffer
* RETURNS  : 1 load successful
*            0 load error
* CREATION:  11.01.99 PNK
*-----------------------------------------------------------------------------------*/

U8	File_LoadAt( char * apFileName, void * apBuffer )
{
	sFileHandle	lHandle;
	S32				lSize;

	lSize = File_GetSize( apFileName );
	if( lSize <= 0 )
		return( 0 );

	lHandle = File_Open( apFileName );
	if( lHandle <= 0 )
	{
		return( 0 );
	}

	File_Read( lHandle, lSize, apBuffer );

	File_Close( lHandle );

	return( 1 );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : File_UnLoad( void * apMem )
* ACTION   : File_UnLoad
* CREATION : 05.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	File_UnLoad( void * apMem )
{
	Memory_Release( apMem );	
}



/*-----------------------------------------------------------------------------------*
* FUNCTION : FileSave( char * apFileName, void * apBuffer, U32 aBytes )
* ACTION   : saves a file from apBuffer
* RETURNS  : 1 load successful
*            0 load error
* CREATION : 11.01.99 PNK
*-----------------------------------------------------------------------------------*/

U8	File_Save( char * apFileName, void * apBuffer, U32 aBytes )
{
	sFileHandle	lHandle;


	lHandle = File_Create( apFileName );
	if( lHandle <= 0 )
	{
		return( 0 );
	}

	File_Write( lHandle, aBytes, apBuffer);
	File_Close( lHandle );

	return( 1 );
}


/* ################################################################################ */
