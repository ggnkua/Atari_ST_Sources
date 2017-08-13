

#include <stdio.h>

#include "datatypes.h"


long filesize(FILE *stream);				// get filesize of FILE *stream


int load_file(char *filename, u8 *buffer);
int save_file(char *filename, u8 *buffer, int fsize);

int get_filesize(char *filename);


