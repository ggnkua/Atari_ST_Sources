#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>

#include <global.h>

# include "drawwind.h"


/*... TIFF messages	...*/

void TIFFError(char *module, char *fmt, ... )
{
	char	format[128] ;

	if (module != NULL)
	{
		sprintf ( format, "%s: ", module) ;
		strcat ( format, fmt ) ;
		fmt = format ;
	}
	info_vprintf ( fmt, ... ) ;
}

void TIFFWarning(char *module, char *fmt, ... )
{
	TIFFError ( module, fmt, ... ) ;
}

