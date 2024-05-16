// --------------------------------------------------------------------------------------------------------------
/*
	OffsetScroll.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _FILEIO_H
#define _FILEIO_H

#include <mint/osbind.h>
#include <mint/falcon.h>
#include <3rd_party/Falcon_MP2/mp2.h>
#include <stdlib.h>

// --------------------------------------------------------------------------------------------------------------

inline void* LoadFile ( const char* pFileName, u32* fileSize = NULL)
{
	static _DTA	dta;
	
	Fsetdta (&dta);
	Fsfirst ( pFileName, 0 );
	
	void* pMemory = malloc ( dta.dta_size+1 );
	
	u32 handle = Fopen ( pFileName, 0 );
	Fread ( handle, dta.dta_size, pMemory );
	Fclose ( handle );
	
	if ( fileSize != NULL )
	{
		*fileSize = dta.dta_size;
	}
	
	MP2Feed(); 
	
	return pMemory;
}

// --------------------------------------------------------------------------------------------------------------

#endif // _FILEIO_H