#include "file.h"
#include "dialog.h"

int save_resource(char *filename)
{
	
	return 0;
}

RO_Object *load_resource(char *filename)
{
	FILE *file;
	
	if( !filename )
		return 0;
		
	file = fopen(
	
	if( ! file )
		return 0;
}