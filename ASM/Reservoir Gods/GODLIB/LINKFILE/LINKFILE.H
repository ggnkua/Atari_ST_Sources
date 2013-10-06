#ifndef	INCLUDED_LINKFILE_H
#define	INCLUDED_LINKFILE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\FILE\FILE.H>

/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dLINKFILE_SENTINEL	0x10FFEB0DL


/* ###################################################################################
#  STRUCTS
################################################################################### */


typedef	struct
{
	U32		Size;
	U32		UnPackedSize;
	U32		Offset;
	U16		PackedFlag;
	U16		LoadedFlag;
	char *	pFileName;
} sLinkFileFile;


typedef	struct sLinkFileFolder
{
	U16							FileCount;
	U16							FolderCount;
	char *						pFolderName;
	sLinkFileFile *				pFiles;
	struct sLinkFileFolder *	pFolders;
} sLinkFileFolder;


typedef	struct
{
	U32					ID;
	U32					Version;
	U32					FatSize;
	U32					TotalFileCount;
	U16					InRamFlag;
	U16					TotalFolderCount;
	sFileHandle			FileHandle;
	sLinkFileFolder *	pRoot;
} sLinkFile;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sLinkFile *	LinkFile_Init( char * apLinkFileName );
sLinkFile *	LinkFile_InitToRAM( char * apLinkFileName );
void		LinkFile_DeInit(       sLinkFile * apLinkFile );

U8			LinkFile_FileExists(   sLinkFile * apLinkFile, char * apFileName );
void *		LinkFile_FileLoad(     sLinkFile * apLinkFile, char * apFileName, const U16 aDepackFlag, const U16 aSlowRamFlag );
U8			LinkFile_FileLoadAt(   sLinkFile * apLinkFile, char * apFileName, void * apBuffer, const U16 aDepackFlag );
S32			LinkFile_FileGetSize(  sLinkFile * apLinkFile, char * apFileName, const U16 aUnpackedSizeFlag );

sLinkFile *	LinkFile_Create( void );
U8			LinkFile_FileCreate( sLinkFileFolder * apFolder, char * apFileName );
S32			LinkFile_Save( sLinkFile * apLinkFile, char * apFileName );
void		LinkFile_BuildFromDirectory( char * apDirectoryName, char * apLinkFileName );
void		LinkFile_BuildFromFile( char * apFileName, char * apLinkFileName );


extern	void *	gpLinkFileLoadingBuffer;
extern	S32		gLinkFileLoadingSize;
extern	U8		gLinkFileLoadingFlag;

/* ################################################################################ */

#endif	/* INCLUDED_LINKFILE_H */