

#include <stdio.h>

#include "datatypes.h"
#include "filestuff.h"




long filesize(FILE *stream)					// get filesize of FILE *stream
{
   long curpos, length;
   curpos = ftell(stream);
   fseek(stream, 0L, SEEK_END);
   length = ftell(stream);
   fseek(stream, curpos, SEEK_SET);
   return length;
}


int load_file(char *filename, u8 *buffer)
{
	FILE *file; int fsize;
	file=fopen(filename,"rb");
	if(file) {
		fsize=filesize(file);
		fread(buffer, fsize, 1, file);		//	load to buffer, fsize bytes
		fclose(file);
		return fsize;
	}
	return -1; // ERROR //
}

int save_file(char *filename, u8 *buffer, int fsize)
{
	FILE *file;
	file=fopen(filename,"wb");
	if(file) {
		fwrite(buffer, fsize, 1, file);		//	save buffer, fsize bytes
		fclose(file);
		return fsize;
	}
	return -1; // ERROR //
}

int get_filesize(char *filename)
{
	FILE *file;  int fsize;
	file=fopen(filename,"rb");
	if(file) {
		fsize=filesize(file);
		fclose(file);
		return fsize;
	}
	return (-1);
}


