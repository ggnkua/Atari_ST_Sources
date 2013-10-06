/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: LINKFILE.C
::
:: LinkFile routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"LINKFILE.H"

#include	<STRING.H>
#include	<GODLIB\DEBUGLOG\DEBUGLOG.H>
#include	<GODLIB\DRIVE\DRIVE.H>
#include	<GODLIB\FILE\FILE.H>
#include	<GODLIB\GEMDOS\GEMDOS.H>
#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\PACKER\PACKER.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dLINKFILE_ID		0x12345678L
#define	dLINKFILE_VERSION	0x0L


/* ###################################################################################
#  DATA
################################################################################### */

sGemDosDTA	gLinkFileDTA;

void *	gpLinkFileLoadingBuffer;
S32		gLinkFileLoadingSize;
U8		gLinkFileLoadingFlag;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sLinkFile *			LinkFile_Serialise( sLinkFile * apLinkFile );
void				LinkFile_RelocateFolder( sLinkFileFolder * apFolder, sLinkFile * apLinkFile);
void				LinkFile_Relocate(   sLinkFile * apLinkFile );
sLinkFileFile *		LinkFile_GetpFile(   sLinkFile * apLinkFile, char * apFileName );
sLinkFileFolder *	LinkFile_GetpFolder( sLinkFileFolder * apFolder, char * apFileName );
U32					LinkFile_GrabDirectory( char * apDst, char * apFileName );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Init( char * apLinkFileName )
* ACTION   : opens a linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFile *	LinkFile_Init( char * apLinkFileName )
{
	sLinkFile 	lLinkFile;
	sLinkFile *	lpLinkFile;
	sFileHandle	lHandle;

/*	printf( "LinkFile_Init() : %s\n", apLinkFileName );*/

	lHandle = File_Open( apLinkFileName );
	if( lHandle < 0 )
	{
		DebugLog_Printf1( "LinkFile_Init() : ERROR : couldn't open linkfile %s\n", apLinkFileName );
		return( (sLinkFile*)0 );
	}

	if( sizeof(sLinkFile) != File_Read( lHandle, sizeof(sLinkFile), &lLinkFile ) )
	{
		DebugLog_Printf1( "LinkFile_Init() : ERROR : couldn't read header for %s \n", apLinkFileName );
		return( (sLinkFile*)0 );
	}

	lpLinkFile = Memory_Calloc( lLinkFile.FatSize );
	if( !lpLinkFile )
	{
		DebugLog_Printf1( "LinkFile_Init() : ERROR : couldn't allocate %ld bytes for FAT\n", lLinkFile.FatSize );
		return( (sLinkFile*)0 );
	}

	File_SeekFromStart( lHandle, 0 );
	if( (S32)lLinkFile.FatSize != File_Read( lHandle, lLinkFile.FatSize, lpLinkFile ) )
	{
		DebugLog_Printf1( "LinkFile_Init() : ERROR : couldn't read FAT for %s\n", apLinkFileName );
		Memory_Release( lpLinkFile );
		return( (sLinkFile*)0 );
	}

	LinkFile_Relocate( lpLinkFile );
	lpLinkFile->FileHandle = lHandle;
	lpLinkFile->InRamFlag  = 0;

	return( lpLinkFile );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Init( char * apLinkFileName )
* ACTION   : opens a linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFile *	LinkFile_InitToRAM( char * apLinkFileName )
{
	sLinkFile *		lpLinkFile;
	sPACKER_HEADER	lPackHead;
	sFileHandle		lHandle;
	S32				lSize;
	U32 *			lpBuffer;
	S32				lOffset;

	lHandle    = File_Open( apLinkFileName );
	lpLinkFile = 0;

	if( lHandle >= 0 )
	{
		File_Read( lHandle, sizeof(sPACKER_HEADER), &lPackHead );
		File_Close( lHandle );

		if( Packer_IsPacked( &lPackHead ) )
		{
			lSize      = Packer_GetDepackSize( &lPackHead );
			lpLinkFile = Memory_Alloc( lSize );

/*			lpBuffer = (U32*)Memory_Alloc( lSize );*/
			lpBuffer = (U32*)lpLinkFile;

			for( lOffset=0; lOffset<(lSize>>2); lOffset++ )
			{
				lpBuffer[ lOffset ] = dLINKFILE_SENTINEL;
			}

			gpLinkFileLoadingBuffer = lpBuffer;
			gLinkFileLoadingSize    = lSize;
			gLinkFileLoadingFlag    = 1;

			File_LoadAt( apLinkFileName, lpLinkFile );

			gLinkFileLoadingFlag    = 0;
		}
		else
		{

			lSize    = File_GetSize( apLinkFileName );
			lpBuffer = 0;
			if( lSize > 0 )
			{

				lHandle = File_Open( apLinkFileName );
				if( lHandle > 0 )
				{
					lpBuffer = (U32*)Memory_Alloc( lSize );

					for( lOffset=0; lOffset<(lSize>>2); lOffset++ )
					{
						lpBuffer[ lOffset ] = dLINKFILE_SENTINEL;
					}

					gpLinkFileLoadingBuffer = lpBuffer;
					gLinkFileLoadingSize    = lSize;
					gLinkFileLoadingFlag    = 1;


					File_Read( lHandle, lSize, lpBuffer );

					File_Close( lHandle );

					gLinkFileLoadingFlag = 0;
				}
			}

			lpLinkFile = (sLinkFile*)lpBuffer;
		}

		if( !lpLinkFile )
		{
			DebugLog_Printf1( "LinkFile_Init() : ERROR : couldn't open linkfile %s\n", apLinkFileName );
		}
		else
		{
			Packer_Depack( lpLinkFile );
			lpLinkFile->InRamFlag = 1;
			LinkFile_Relocate( lpLinkFile );
		}
	}

	return( lpLinkFile );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_DeInit( sLinkFile * apLinkFile )
* ACTION   : closes a linkfile, frees memory
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void		LinkFile_DeInit(       sLinkFile * apLinkFile )
{
	if( apLinkFile )
	{
		if( !apLinkFile->InRamFlag )
		{
			File_Close( apLinkFile->FileHandle );
		}
		Memory_Release( apLinkFile );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_FileExists(   sLinkFile * apLinkFile, char * apFileName )
* ACTION   : returns non zero result if apFileName exists in apLinkFile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U8			LinkFile_FileExists(   sLinkFile * apLinkFile, char * apFileName )
{
	return( 0 != LinkFile_GetpFile(apLinkFile,apFileName));
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_FileLoad(     sLinkFile * apLinkFile, char * apFileName, const U16 aDepackFlag )
* ACTION   : allocates memory for and loads apFileName from apLinkFile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void *		LinkFile_FileLoad(     sLinkFile * apLinkFile, char * apFileName, const U16 aDepackFlag, const U16 aSlowRamFlag )
{
	sLinkFileFile *	lpFile;
	U32				lSize;
	void *			lpMem;


	if( !apLinkFile )
	{
		return( 0 );
	}
	if( apLinkFile->FileHandle < 0 )
	{
		return( 0 );
	}

	lpFile = LinkFile_GetpFile( apLinkFile, apFileName );
	if( !lpFile )
	{
		return( 0 );
	}

	if( apLinkFile->InRamFlag )
	{
		lpMem = (void*)lpFile->Offset;
	}
	else
	{
		if( apLinkFile->FileHandle < 0 )
		{
			return( 0 );
		}
		if( aDepackFlag )
		{
			lSize = lpFile->UnPackedSize;
		}
		else
		{
			lSize = lpFile->Size;
		}

		if( aSlowRamFlag )
		{
			lpMem = Memory_ScreenAlloc( lSize );
		}
		else
		{
			lpMem = Memory_Alloc( lSize );
		}
		if( !lpMem )
		{
			DebugLog_Printf2( "LinkFile_FileLoad() : ERROR : alloc failed file %s size %ld", apFileName, lSize );
			return( 0 );
		}

		File_SeekFromStart( apLinkFile->FileHandle, lpFile->Offset );
		File_Read( apLinkFile->FileHandle, lpFile->Size, lpMem );

		if( aDepackFlag )
		{
			Packer_Depack( lpMem );
		}
	}

	return( lpMem );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_FileLoad(     sLinkFile * apLinkFile, char * apFileName, const U16 aDepackFlag )
* ACTION   : loads apFileName to apBuffer from apLinkFile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U8		LinkFile_FileLoadAt(   sLinkFile * apLinkFile, char * apFileName, void * apBuffer, const U16 aDepackFlag )
{
	sLinkFileFile *	lpFile;

/*	printf( "LinkFile_FileLoadAt() : %lX %s\n", apLinkFile, apFileName );*/

	if( !apLinkFile )
	{
		return( 0 );
	}

	lpFile = LinkFile_GetpFile( apLinkFile, apFileName );
	if( !lpFile )
	{
		return( 0 );
	}

	if( apLinkFile->InRamFlag )
	{
		Memory_Copy( lpFile->Size, (void*)lpFile->Offset, apBuffer );
	}
	else
	{
		if( apLinkFile->FileHandle < 0 )
		{
			return( 0 );
		}
		File_SeekFromStart( apLinkFile->FileHandle, lpFile->Offset );
		File_Read( apLinkFile->FileHandle, lpFile->Size, apBuffer );
	}

	if( aDepackFlag )
	{
		Packer_Depack( apBuffer );
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_FileGetSize(  sLinkFile * apLinkFile, char * apFileName, const U16 aUnpackedSizeFlag )
* ACTION   : loads apFileName to apBuffer from apLinkFile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

S32			LinkFile_FileGetSize(  sLinkFile * apLinkFile, char * apFileName, const U16 aUnpackedSizeFlag )
{
	sLinkFileFile *	lpFile;
	S32				lSize;

	if( !apLinkFile )
	{
		return( 0 );
	}
	lpFile = LinkFile_GetpFile( apLinkFile, apFileName );
	if( !lpFile )
	{
		return( 0 );
	}
	if( aUnpackedSizeFlag )
	{
		lSize = (S32)lpFile->UnPackedSize;
	}
	else
	{
		lSize = (S32)lpFile->Size;
	}

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Create( void )
* ACTION   : creates a linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFile *	LinkFile_Create( void )
{
	sLinkFile *			lpLinkFile;
	sLinkFileFolder *	lpFolder;
	char *				lpFolderName;

/*	mLinkFilePrintf( "LinkFile_Create()\n" );*/

	lpLinkFile = (sLinkFile*)Memory_Calloc( sizeof(sLinkFile) );
	if( !lpLinkFile )
	{
		return( (sLinkFile*)0 );
	}
	lpFolder = (sLinkFileFolder*)Memory_Calloc( sizeof(sLinkFileFolder) );
	if( !lpFolder )
	{
		Memory_Release( lpLinkFile );
		return( (sLinkFile*)0 );
	}

	lpFolderName = (char*)Memory_Calloc( 1 );
	if( !lpFolderName )
	{
		Memory_Release( lpLinkFile );
		Memory_Release( lpFolder   );
		return( (sLinkFile*)0 );
	}

	lpLinkFile->FatSize    =  0;
	lpLinkFile->ID         = dLINKFILE_ID;
	lpLinkFile->Version    = dLINKFILE_VERSION;
	lpLinkFile->pRoot      = lpFolder;

	lpFolder->FileCount   = 0;
	lpFolder->FolderCount = 0;
	lpFolder->pFolderName = lpFolderName;

	lpFolderName[ 0 ] = 0;

	return( lpLinkFile );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_FileCreate( sLinkFile * apLinkFile, char * apFileName, char * apSrcDirectory )
* ACTION   : adds a file into a linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U8		LinkFile_FileCreate( sLinkFileFolder * apFolder, char * apFileName )
{
	char				lString[ 256 ];
	sLinkFileFolder *	lpFolder;
	sLinkFileFile *		lpFiles;
	char *				lpFileName;
	U32					lDirLen;
	U32					lSize;
	U16					i;

/*	mLinkFilePrintf( "LinkFile_FileCreate() : %lX %s\n", apFolder, apFileName );*/

	lDirLen = LinkFile_GrabDirectory( lString, apFileName );

	if( lDirLen )
	{
		lpFolder = LinkFile_GetpFolder( apFolder, lString );
		if( !lpFolder )
		{
			lSize  = apFolder->FolderCount+1;
			lSize *= sizeof(sLinkFileFolder);

			lpFolder = Memory_Calloc( lSize );
			if( !lpFolder )
			{
				return( 0 );
			}
			lpFileName = Memory_Calloc( lDirLen+1 );
			if( !lpFileName )
			{
				Memory_Release( lpFolder );
				return( 0 );
			}
			strcpy( lpFileName, lString );
			for( i=0; i<apFolder->FileCount; i++ )
			{
				lpFolder->pFolders[ i ] = apFolder->pFolders[ i ];
			}
			Memory_Release( apFolder->pFolders );
			apFolder->pFolders = lpFolder;

			lpFolder[ apFolder->FolderCount ].FileCount   = 0;
			lpFolder[ apFolder->FolderCount ].FolderCount = 0;
			lpFolder[ apFolder->FolderCount ].pFiles      = 0;
			lpFolder[ apFolder->FolderCount ].pFolderName = lpFileName;
			lpFolder[ apFolder->FolderCount ].pFolders    = 0;

			lpFolder = &apFolder->pFolders[ apFolder->FolderCount ];

			apFolder->FolderCount++;
		}
		strcpy( lString, &apFileName[ lDirLen+1 ] );
		return( LinkFile_FileCreate( lpFolder, lString ) );
	}


	lSize  = apFolder->FileCount+1;
	lSize *= sizeof(sLinkFileFile);
	lpFiles = Memory_Calloc( lSize );
	if( !lpFiles )
	{
		return( 0 );
	}
	lpFileName = Memory_Calloc( strlen(apFileName)+1 );
	if( !lpFileName )
	{
		Memory_Release( lpFiles );
		return( 0 );
	}
	strcpy( lpFileName, apFileName );

	for( i=0; i<apFolder->FileCount; i++ )
	{
		lpFiles[ i ] = apFolder->pFiles[ i ];
	}
	Memory_Release( apFolder->pFiles );
	apFolder->pFiles = lpFiles;


	lpFiles[ apFolder->FileCount ].LoadedFlag   = 0;
	lpFiles[ apFolder->FileCount ].Offset       = 0;
	lpFiles[ apFolder->FileCount ].PackedFlag   = 0;
	lpFiles[ apFolder->FileCount ].pFileName    = lpFileName;
	lpFiles[ apFolder->FileCount ].Size         = 0;
	lpFiles[ apFolder->FileCount ].UnPackedSize = 0;
	apFolder->FileCount++;
	
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_RelocateFolder( sLinkFileFolder * apFolder, U32 aBase )
* ACTION   : relocates a folder and all subfolders it contains
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_RelocateFolder( sLinkFileFolder * apFolder, sLinkFile * apLinkFile )
{
	U16	i;

/*	printf( "LinkFile_RelocateFolder()\n" );*/

	*(U32*)&apFolder->pFolders    += (U32)apLinkFile;
	*(U32*)&apFolder->pFiles      += (U32)apLinkFile;
	*(U32*)&apFolder->pFolderName += (U32)apLinkFile;

	for( i=0; i<apFolder->FolderCount; i++ )
	{
		LinkFile_RelocateFolder( &apFolder->pFolders[ i ], apLinkFile );
	}
	for( i=0; i<apFolder->FileCount; i++ )
	{
		*(U32*)&apFolder->pFiles[ i ].pFileName += (U32)apLinkFile;

		if( apLinkFile->InRamFlag )
		{
			*(U32*)&apFolder->pFiles[ i ].Offset += (U32)apLinkFile;
		}
	}
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_RelocateFolder( sLinkFileFolder * apFolder, U32 aBase )
* ACTION   : relocates a folder and all subfolders it contains
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_DelocateFolder( sLinkFileFolder * apFolder, U32 aBase )
{
	U16	i;

/*	mLinkFilePrintf( "LinkFile_RelocateFolder()\n" );*/


	for( i=0; i<apFolder->FolderCount; i++ )
	{
		LinkFile_DelocateFolder( &apFolder->pFolders[ i ], aBase );
	}
	for( i=0; i<apFolder->FileCount; i++ )
	{
		*(U32*)&apFolder->pFiles[ i ].pFileName -= aBase;
	}
	*(U32*)&apFolder->pFolders    -= aBase;
	*(U32*)&apFolder->pFiles      -= aBase;
	*(U32*)&apFolder->pFolderName -= aBase;
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Relocate( sLinkFile * apLinkFile )
* ACTION   : relocates a linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_Relocate( sLinkFile * apLinkFile )
{
/*	printf( "LinkFile_Relocate()\n" );*/

	*(U32*)&apLinkFile->pRoot += (U32)apLinkFile;
	LinkFile_RelocateFolder( apLinkFile->pRoot, apLinkFile );
}



/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Relocate( sLinkFile * apLinkFile )
* ACTION   : relocates a linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_Delocate( sLinkFile * apLinkFile )
{
/*	mLinkFilePrintf( "LinkFile_Relocate()\n" );*/

	LinkFile_DelocateFolder( apLinkFile->pRoot, (U32)apLinkFile );
	*(U32*)&apLinkFile->pRoot -= (U32)apLinkFile;
}

/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GetpFolder( sLinkFileFolder * apFolder, char * apFolderName )
* ACTION   : returns a pointer to folder apFolderName if it exists, else 0
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFileFolder *	LinkFile_GetpFolder( sLinkFileFolder * apFolder, char * apFolderName )
{
	U16	i;

/*	printf( "LinkFile_GetpFolder() : %lX %s\n", apFolder, apFolderName );*/

	for( i=0; i<apFolder->FolderCount; i++ )
	{
		if( !strcmp( apFolder->pFolders[ i ].pFolderName, apFolderName ) )
		{
			return( &apFolder->pFolders[ i ] );
		}
	}

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GetpFile( sLinkFile * apLinkFile, char * apFileName )
* ACTION   : returns a pointer to a sLinkFileFile struct for file in linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFileFile *	LinkFile_GetpFile( sLinkFile * apLinkFile, char * apFileName )
{
	char				lString[ 256 ];
	char *				lpFileName;
	U8					lChar;
	sLinkFileFolder *	lpFolder;
	U16					i;

/*	printf( "LinkFile_GetpFile() : %lX %s\n", apLinkFile, apFileName);*/

	lpFolder = apLinkFile->pRoot;

	i=0;
	
	lpFileName = apFileName;
	while( (i<256) && (*lpFileName) )
	{
		if( (*lpFileName == '/') || (*lpFileName=='\\') )
		{
			if( i )
			{
				lString[ i ] = 0;

				lpFolder = LinkFile_GetpFolder( lpFolder, lString );

				if( !lpFolder )
				{
					return( (sLinkFileFile*)0 );
				}
			}
		}
		else
		{
			lChar = *lpFileName;
			if( (lChar >= 'a') && ( lChar <= 'z' ) )
			{
				lChar += 'A'-'a';
			}
			lString[ i ] = lChar;
			lpFileName++;
			i++;
		}
	}
	lString[ i ] = 0;

	if( i )
	{
		for( i=0; i<lpFolder->FileCount; i++ )
		{
			if( !strcmp( lString, lpFolder->pFiles[ i ].pFileName ) )
			{
				return( &lpFolder->pFiles[ i ] );
			}
		}
	}

	return( (sLinkFileFile*)0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GetStringSize( sLinkFileFolder * apFolder )
* ACTION   : returns total size of all strings in FAT
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U32	LinkFile_GetStringSize( sLinkFileFolder * apFolder )
{
	U32	lSize;
	U16	i;

/*	mLinkFilePrintf( "LinkFile_GetStringSize()\n" );*/

	lSize = 0;

	lSize += (strlen(apFolder->pFolderName) + 1L);

	for( i=0; i<apFolder->FolderCount; i++ )
	{
		lSize += LinkFile_GetStringSize( &apFolder->pFolders[ i ] );
	}
	for( i=0; i<apFolder->FileCount; i++ )
	{
		lSize += (strlen(apFolder->pFiles[ i ].pFileName)+1L);
	}

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GetFileCount( sLinkFileFolder * apFolder )
* ACTION   : returns total number of files in linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U32	LinkFile_GetFileCount( sLinkFileFolder * apFolder )
{
	U32	lCount;
	U16	i;

/*	mLinkFilePrintf( "LinkFile_GetFileCount()\n" );*/

	lCount = apFolder->FileCount;
	for( i=0; i<apFolder->FolderCount; i++ )
	{
		lCount += LinkFile_GetFileCount( &apFolder->pFolders[ i ] );
	}
	
	return( lCount );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GetDataSize( sLinkFileFolder * apFolder )
* ACTION   : returns size of all data in linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U32	LinkFile_GetDataSize( sLinkFileFolder * apFolder )
{
	U32	lSize = 0;
	U16	i;

/*	mLinkFilePrintf( "LinkFile_GetDataSize()\n" );*/

	for( i=0; i<apFolder->FileCount; i++ )
	{
		lSize += apFolder->pFiles[ i ].Size;
	}
	for( i=0; i<apFolder->FolderCount; i++ )
	{
		lSize += LinkFile_GetDataSize( &apFolder->pFolders[ i ] );
	}

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GetFolderCount( sLinkFileFolder * apFolder )
* ACTION   : returns count of folders in linkfile
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

U32	LinkFile_GetFolderCount( sLinkFileFolder * apFolder )
{
	U32	lCount;
	U16	i;

/*	mLinkFilePrintf( "LinkFile_GetFolderCount()\n" );*/

	lCount = 1;
	for( i=0; i<apFolder->FolderCount; i++ )
	{
		lCount += LinkFile_GetFolderCount( &apFolder->pFolders[ i ] );
	}
	
	return( lCount );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_SerialiseFolders( sLinkFileFolder * apDstFolder, sLinkFileFolder * apSrcFolder )
* ACTION   : serialises folders
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFileFolder *	LinkFile_SerialiseFolders( sLinkFileFolder * apDstFolder, sLinkFileFolder * apSrcFolder )
{
	sLinkFileFolder *	lpFolder;
	U16					i;

/*	mLinkFilePrintf( "LinkFile_SerialiseFolders()\n" );*/

	lpFolder = apDstFolder;

	*lpFolder = *apSrcFolder;
	apDstFolder++;

	lpFolder->pFolders  = apDstFolder;
	apDstFolder        += lpFolder->FolderCount;
	
	for( i=0; i<lpFolder->FolderCount; i++ )
	{
		apDstFolder = LinkFile_SerialiseFolders( apDstFolder, &apSrcFolder->pFolders[ i ] );
	}

	return( apDstFolder );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_SerialiseFiles( sLinkFileFolder * apFolder, sLinkFileFile * apFile )
* ACTION   : serialises files
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFileFile *	LinkFile_SerialiseFiles( sLinkFileFolder * apFolder, sLinkFileFile * apFile )
{
	U16				i;

/*	mLinkFilePrintf( "LinkFile_SerialiseFiles()\n" );*/

	apFolder->pFiles = apFile;
	apFile          += apFolder->FileCount;
	
	for( i=0; i<apFolder->FolderCount; i++ )
	{
		apFile = LinkFile_SerialiseFiles( &apFolder[ i ], apFile );
	}

	return( apFile );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_StringCopy( char * apDst, char * apSrc )
* ACTION   : string copy, returns pointer to end of string
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

char *	LinkFile_StringCopy( char * apDst, char * apSrc )
{
/*	mLinkFilePrintf( "LinkFile_StringCopy() : %s\n", apSrc );*/

	while( *apSrc )
	{ 
		*apDst++ = *apSrc++;
	}
	*apDst++ = 0;

	return( apDst );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_SerialiseStrings( sLinkFileFolder * apDstFolder, sLinkFileFolder * apSrcFolder, char * apMem )
* ACTION   : serialises strings
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

char *	LinkFile_SerialiseStrings( sLinkFileFolder * apDstFolder, sLinkFileFolder * apSrcFolder, char * apMem )
{
	U16				i;

/*	mLinkFilePrintf( "LinkFile_SerialiseStrings()\n" );*/

	apDstFolder->pFolderName = apMem;
	apMem                    = LinkFile_StringCopy( apMem, apSrcFolder->pFolderName );

	for( i=0; i<apDstFolder->FileCount; i++ )
	{
		apDstFolder->pFiles[ i ].pFileName = apMem;
		apMem = LinkFile_StringCopy( apMem, apSrcFolder->pFiles[ i ].pFileName );
	}

	for( i=0; i<apDstFolder->FolderCount; i++ )
	{
		apMem = LinkFile_SerialiseStrings( &apDstFolder->pFolders[ i ], &apSrcFolder->pFolders[ i ], apMem );
	}

	return( apMem );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_FolderFree( sLinkFileFolder * apFolder )
* ACTION   : releases memory allocated for folders, files & strings
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_FolderFree( sLinkFileFolder * apFolder )
{
	U16	i;

/*	mLinkFilePrintf( "LinkFile_FolderFree()\n" );*/

	Memory_Release( apFolder->pFolderName );

	if( apFolder->FileCount )
	{
		for( i=0; i<apFolder->FileCount; i++ )
		{
			Memory_Release( apFolder->pFiles[ i ].pFileName );
		}
		Memory_Release( apFolder->pFiles );
	}

	if( apFolder->FolderCount )
	{
		for( i=0; i<apFolder->FolderCount; i++ )
		{
			LinkFile_FolderFree( apFolder );
		}
		Memory_Release( apFolder->pFolders );
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Serialise( sLinkFile * apLinkFile )
* ACTION   : serialises the linkfile FAT
* CREATION : 02.09.01 PNK
*-----------------------------------------------------------------------------------*/

sLinkFile *		LinkFile_SerialiseFAT( sLinkFile * apLinkFile )
{
	sLinkFile *			lpLinkFile;
	U8 *				lpMem;
	U32					lStringSize;
	U32					lFileCount;
	U32					lFolderCount;
	U32					lSize;

/*	mLinkFilePrintf( "LinkFile_SerialiseFat()\n" );*/

	lStringSize  = LinkFile_GetStringSize(  apLinkFile->pRoot );
	lFolderCount = LinkFile_GetFolderCount( apLinkFile->pRoot );
	lFileCount   = LinkFile_GetFileCount(   apLinkFile->pRoot );

	lFileCount   *= sizeof( sLinkFileFile   );
	lFolderCount *= sizeof( sLinkFileFolder );

	lSize = lFileCount + lFolderCount + lStringSize + sizeof(sLinkFile);

	lpLinkFile = Memory_Calloc( lSize );
	if( !lpLinkFile )
	{
		return( (sLinkFile*)0 );
	}

	*lpLinkFile = *apLinkFile;

	lpLinkFile->FatSize = (lSize+3L)&0xFFFFFFFCL;

	lpMem  = (U8*)lpLinkFile;
	lpMem += sizeof(sLinkFile);
	lpLinkFile->pRoot = (sLinkFileFolder*)lpMem;

	lpMem = (U8*)LinkFile_SerialiseFolders( lpLinkFile->pRoot, apLinkFile->pRoot     );
	lpMem = (U8*)LinkFile_SerialiseFiles(   lpLinkFile->pRoot, (sLinkFileFile*)lpMem );
	lpMem = (U8*)LinkFile_SerialiseStrings( lpLinkFile->pRoot, apLinkFile->pRoot, (char*)lpMem );

	LinkFile_FolderFree( apLinkFile->pRoot );
	Memory_Release( apLinkFile );

	return( lpLinkFile );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_SetFileOffsets( sLinkFileFolder * apFolder,U32 aOffset,char * apSrcDirectory )
* ACTION   : LinkFile_SetFileOffsets
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	LinkFile_SetFileOffsets( sLinkFileFolder * apFolder,U32 aOffset,char * apSrcDirectory )
{
	sPACKER_HEADER	lHeader;
	sFileHandle		lHandle;
	char			lString[ 128 ];
	S32				lSize;
	U16				i;


/*	mLinkFilePrintf( "LinkFile_SetFileOffsets()\n" );*/

	for( i=0; i<apFolder->FolderCount; i++ )
	{
		sprintf( lString, "%s%s\\", apSrcDirectory, apFolder->pFolders[ i ].pFolderName );
		aOffset = LinkFile_SetFileOffsets( &apFolder->pFolders[ i ], aOffset, lString );
	}

	for( i=0; i<apFolder->FileCount; i++ )
	{
		sprintf( lString, "%s%s", apSrcDirectory, apFolder->pFiles[ i ].pFileName );
		lSize = File_GetSize( lString );
		if( lSize < 0 )
		{
			lSize = 0;
		}

		apFolder->pFiles[ i ].Size         = lSize;
		apFolder->pFiles[ i ].Offset       = aOffset;
		apFolder->pFiles[ i ].LoadedFlag   = 0;
		apFolder->pFiles[ i ].PackedFlag   = 0;
		apFolder->pFiles[ i ].UnPackedSize = lSize;

		lHeader.l0 = 0;
		lHeader.l1 = 0;
		lHeader.l2 = 0;

		lHandle = File_Open( lString );
		if( lHandle > 0 )
		{
			File_Read( lHandle, sizeof(sPACKER_HEADER), &lHeader );
			File_Close( lHandle );
			if( Packer_IsPacked(&lHeader) )
			{
				apFolder->pFiles[ i ].PackedFlag   = 1;
				apFolder->pFiles[ i ].UnPackedSize = Packer_GetDepackSize( &lHeader );
			}
		}

		aOffset += ((lSize+3L)&0xFFFFFFFCL);
	}

	return( aOffset );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_SaveData( sLinkFileFolder * apFolder,sFileHandle aHandle,char * apSrcDirectory )
* ACTION   : LinkFile_SaveData
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_SaveData( sLinkFileFolder * apFolder,sFileHandle aHandle,char * apSrcDirectory )
{
	char	lString[ 128 ];
	void *	lpFile;
	U16		i;

/*	mLinkFilePrintf( "LinkFile_SaveData()\n" );*/

	for( i=0; i<apFolder->FolderCount; i++ )
	{
		sprintf( lString, "%s%s\\", apSrcDirectory, apFolder->pFolders[ i ].pFolderName );
		LinkFile_SaveData( &apFolder->pFolders[ i ], aHandle, lString );
	}

	for( i=0; i<apFolder->FileCount; i++ )
	{
		sprintf( lString, "%s%s", apSrcDirectory, apFolder->pFiles[ i ].pFileName );
		lpFile = File_Load( lString );
		if( lpFile )
		{
			File_Write( aHandle, ((apFolder->pFiles[ i ].Size+3L)&0xFFFFFFFCL), lpFile );
			Memory_Release( lpFile );
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_Dump( sLinkFile * apLinkFile,char * apFileName,char * apSrcDirectory )
* ACTION   : LinkFile_Dump
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_Dump( sLinkFile * apLinkFile,char * apFileName,char * apSrcDirectory )
{
	sFileHandle		lHandle;
	sLinkFile *		lpLinkFile;

/*	mLinkFilePrintf( "LinkFile_Dump()\n" );*/

	lHandle = File_Create( apFileName );

	if( lHandle < 0 )
	{
		return;
	}

	lpLinkFile = LinkFile_SerialiseFAT( apLinkFile );
	LinkFile_SetFileOffsets( lpLinkFile->pRoot, lpLinkFile->FatSize, apSrcDirectory );

	LinkFile_Delocate( lpLinkFile );
	File_Write( lHandle, lpLinkFile->FatSize, lpLinkFile );
	LinkFile_Relocate( lpLinkFile );

	LinkFile_SaveData( lpLinkFile->pRoot, lHandle, apSrcDirectory );
	
	File_Close( lHandle );

	Memory_Release( lpLinkFile );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_GrabDirectory( char * apDst,char * apFileName )
* ACTION   : LinkFile_GrabDirectory
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	LinkFile_GrabDirectory( char * apDst,char * apFileName )
{
	U32	aIndex;
	U32	i;
	
/*	mLinkFilePrintf( "LinkFile_GrabDirectory() : %s\n", apFileName );*/

	aIndex = 0;

	while( apFileName[ aIndex ] )
	{
		if( (apFileName[ aIndex ] == '/') || (apFileName[ aIndex ] =='\\') )
		{
			for( i=0; i<aIndex; i++ )
			{
				apDst[ i ] = apFileName[ i ];
			}
			apDst[ aIndex ] = 0;
			return( aIndex );
		}

		aIndex++;
	}
	apDst[ 0 ] = 0;

	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_BuildFromDirectory( char * apDirectoryName,char * apLinkFileName )
* ACTION   : LinkFile_BuildFromDirectory
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_BuildFromDirectory( char * apDirectoryName,char * apLinkFileName )
{
	sGemDosDTA		lDta;
	sGemDosDTA *	lpOldDTA;
	sLinkFile *		lpLinkFile;
	S32				lLen;
	char *			lpDirectory;

	lpOldDTA    = GemDos_Fgetdta();

	lpDirectory = Memory_Calloc( strlen(apDirectoryName) + 8 );
	if( lpDirectory )
	{
		strcpy( lpDirectory, apDirectoryName );
		lLen = strlen(apDirectoryName);
		if( lLen )
		{
			if( lpDirectory[ lLen-1 ] != '\\' )
			{
				lpDirectory[ lLen   ] = '\\';
				lpDirectory[ lLen+1 ] = 0;
				lLen++;
			}
		}

		strcat( lpDirectory, "*.*" );
		GemDos_Fsetdta( &lDta );

		if( 0 == GemDos_Fsfirst( lpDirectory, dGEMDOS_FA_READONLY | dGEMDOS_FA_ARCHIVE ) )
		{
			lpLinkFile = LinkFile_Create();
			if( lpLinkFile )
			{
				do
				{
					if( 
						(lDta.FileName[0] != '.') && 
						(lDta.Length) 
						)
					{
						LinkFile_FileCreate( lpLinkFile->pRoot, &lDta.FileName[0] );
					}
				} while( 0==GemDos_Fsnext() );
				lpDirectory[ lLen ] = 0;
				LinkFile_Dump( lpLinkFile, apLinkFileName, lpDirectory );
			}
		}

		GemDos_Fsetdta( lpOldDTA );
		Memory_Release( lpDirectory );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : LinkFile_BuildFromFile( char * apFileName,char * apLinkFileName )
* ACTION   : LinkFile_BuildFromFile
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	LinkFile_BuildFromFile( char * apFileName,char * apLinkFileName )
{
	char		lDirectory[ 256 ];
	char		lFileName[ 256 ];
	sLinkFile *	lpLinkFile;
	char *		lpFile;
	S32			lFileSize;
	S32			lIndex;
	U32			i;

/*	mLinkFilePrintf( "LinkFile_BuildFromFile() : %s\n", apFileName );*/

	lFileSize = File_GetSize( apFileName );

	if( lFileSize <= 0 )
	{
		return;
	}
	lpFile = (char*)File_Load( apFileName );
	if( !lpFile )
	{
		return;		
	}


	lIndex     = 0;	
	while( (lIndex<lFileSize) && (lpFile[ lIndex ] != 10) && (lpFile[ lIndex ] != 13) )
	{
		lDirectory[ lIndex ] = lpFile[ lIndex ];
		lIndex++;
	}
	lDirectory[ lIndex ] = 0;

	if( !lIndex )
	{
		return;
	}

	while( (lIndex<lFileSize) && ((lpFile[ lIndex ] == 10) || (lpFile[ lIndex ] == 13)) )
	{
		lIndex++;
	}	


/*	mLinkFilePrintf( "SrcDir : %s", lDirectory );*/

	lpLinkFile = LinkFile_Create();
	if( !lpLinkFile )
	{
		return;
	}

	while( lIndex < lFileSize )
	{
		i      = 0;
		while( (lIndex<lFileSize) && (lpFile[ lIndex ] != 10) && (lpFile[ lIndex ] != 13) )
		{
			lFileName[ i ] = lpFile[ lIndex ];
			lIndex++;
			i++;
		}
		lFileName[ i ] = 0;

		while( (lIndex<lFileSize) && ((lpFile[ lIndex ] == 10) || (lpFile[ lIndex ] == 13)) )
		{
			lIndex++;
		}

		if( i )
		{
			LinkFile_FileCreate( lpLinkFile->pRoot, lFileName );
		}
	}

	LinkFile_Dump( lpLinkFile, apLinkFileName, lDirectory );
}


/* ################################################################################ */
