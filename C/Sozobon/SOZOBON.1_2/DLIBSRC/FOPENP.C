#include <stdio.h>
#include <string.h>

FILE *fopenp(filename, mode)
	char *filename;
	char *mode;
	{
	register FILE *fp = NULL;
	char fn[128], *pfindfile();

	strcpy(fn, filename);
	if(strchr(fn, '.') == NULL)
		strcat(fn, ".");
	if(filename = pfindfile(NULL, fn, "\0"))
		fp = fopen(filename, mode);
	return(fp);
	}
