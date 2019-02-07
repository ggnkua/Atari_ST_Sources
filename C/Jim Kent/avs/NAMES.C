/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include "flicker.h"

suffix_in(string, suff)
char *string, *suff;
{
string += strlen(string) - strlen(suff);
return( strcmp(string, suff) == 0);
}

char *
clone_string(name)
char *name;
{
char *d;
int size;

size = strlen(name);
if ((d = askmem(size+1)) != NULL)
	{
	strcpy(d, name);
	}
return(d);
}

