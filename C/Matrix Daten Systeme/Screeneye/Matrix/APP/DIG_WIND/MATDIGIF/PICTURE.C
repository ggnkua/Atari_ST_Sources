# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <tos.h>

# include <global.h>
# include <error.h>

# include "\pc\app\matdigi\tiff.h"

# include "picture.h"

/*------------------------------------------ WriteTiffFile ----------*/
int WriteTiffFile ( char *filename, void *data, int w, int h )
{
	int 	result ;
	TIFFpic *tiff ;
	
	tiff = init_tiff ( data, w, h, &result ) ;
	if ( result == OK )
	{
		result = write_tiff_picture ( filename, tiff, w, h ) ;
		free_tiff_pic ( tiff ) ;
	}
	return result ;
}

