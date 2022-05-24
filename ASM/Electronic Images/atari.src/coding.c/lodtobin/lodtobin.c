/*
 * 		LOD to Binary convertor.
 */

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>
#include <ctype.h>

static char buffer[128000l];

void usage(void )
{	fprintf(stderr,"\nUsage: LODTOBIN <filename> \n\n");
	exit(0);
}


void main(int argc, char *argv[]) 
{
    FILE *stream;
    long a;
    char lodname[256];
    char binname[256];
    if (argc < 2)
		usage();
	else
	{	strcpy(lodname,argv[1]);
		strcpy(binname,argv[1]);
		strcat(lodname,".LOD");
		strcat(binname,".BIN");
		if ((a = Dsp_LodToBinary(lodname,buffer)) < 0)
		{	fprintf(stderr,"Error: LOD to binary call failed. \n");
			exit(1);
		}	
    	if ((stream = fopen(binname,"wb")) == NULL) 
	    {	fprintf(stderr,"Error: Failed to open failed.\n");
			exit(2);
		}
		if (fwrite(buffer,(a*3),1l,stream) < 0)
	    {	fprintf(stderr,"Error: Failed to write file.\n");
			exit(3);
		}
	
		fclose(stream);
		fprintf(stderr,"%s -> %s \n",lodname,binname);
	}

}

