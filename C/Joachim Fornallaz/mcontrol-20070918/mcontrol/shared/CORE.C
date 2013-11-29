/*----------------------------------------------------------------------------------------*/
/* Shared code for multiple applications 																	*/
/* Copyright 2000 by Joachim Fornallaz - all rights reserved										*/
/*----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include	<mgx_dos.h>
#include <types2b.h>
#include	<string.h>
#include <stdio.h>
#include	<ctype.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"core.h"

/*----------------------------------------------------------------------------------------*/
/* function definitions																							*/
/*----------------------------------------------------------------------------------------*/

CFDataRef    CFDataCreate( CFIndex bytes, CFDataType type )
{
    CFDataRef dref = (CFDataRef)Malloc((int32)sizeof(CFData)+(int32)bytes );
        
    if( dref )
    {
        dref->data = (StringPtr)(dref + 1);
        dref->type = type;
        memset( (void*)dref->data, 0, (size_t)bytes );
    }
    return dref;
}


boolean		CFDataClear( CFDataRef dref )
{
	int16	ret = 1;
	
	if( dref )
		ret = Mfree( dref );
		
	return( ret == 0 );
}

