/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: DRIVE.C
::
:: Low level drive access routines
::
:: This file contains all the platform specific drive manipulation routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"DRIVE.H"

#include	<GODLIB\GEMDOS\GEMDOS.H>


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_CreateDirectory( char * apDirName )
* ACTION   : creates a directory with the specified name
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		Drive_CreateDirectory( char * apDirName )
{
	return( GemDos_Dcreate( apDirName ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_DeleteDirectory( char * apDirName )
* ACTION   : deletes a directory with the specified name
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		Drive_DeleteDirectory( char * apDirName )
{
	return( GemDos_Ddelete( apDirName ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_GetFree( U16 aDrive )
* ACTION   : returns the number of free bytes left on drive aDrive
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32		Drive_GetFree( U16 aDrive )
{
	sGemDosDiskInfo	lDiskInfo;
	S32				lFree;

	lFree = GemDos_Dfree( &lDiskInfo, aDrive );

	if( lFree >= 0 )
	{
		lFree = lDiskInfo.FreeClusterCount * lDiskInfo.SectorsPerCluster * lDiskInfo.SectorSize;
	}

	return( lFree );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_GetDrive()
* ACTION   : gets the number of the currently active drive
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

U16	Drive_GetDrive()
{
	return( GemDos_Dgetdrv() );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_SetDrive( U16 aDrive )
* ACTION   : sets the number of the currently active drive
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32	Drive_SetDrive( U16 aDrive )
{
	return( GemDos_Dsetdrv( aDrive ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_GetPath( U16 aDrive, char * apPath )
* ACTION   : reads current path of aDrive into character buffr apPath
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32	Drive_GetPath( U16 aDrive, char * apPath )
{
	return( GemDos_Dgetpath( apPath, aDrive) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Drive_SetPath( char * apPath )
* ACTION   : sets current path 
* CREATION : 11.09.99 PNK
*-----------------------------------------------------------------------------------*/

S32	Drive_SetPath( char * apPath )
{
	return( GemDos_Dsetpath( apPath ) );
}


/* ################################################################################ */
