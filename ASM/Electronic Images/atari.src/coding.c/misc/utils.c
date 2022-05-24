#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <fcntl.h>
#include <io.h>

enum errs { OUT_MEM=1, DISK_ERR=2 };

void fatal_error(int error_no,int a,char *b)
{	SetMode(0x03);
    	switch (error_no)
	{	case 1: 	fprintf(stderr,"Out of Memory\n");
				fprintf(stderr,"Tried to Malloc:%d\n",a);
	    			break;
		case 2:		fprintf(stderr,"Disk Error\n");
				fprintf(stderr,"Reading File:%s\n",b);
				break;
	}
	exit(1);
}

void read_file(char *filename,char *data)
{	FILE *file = fopen(filename,"rb");
    	if (file != NULL)
	{	fread(data,1,1000000,file);
		fclose(file);
	}
}

char *alloc_read_file(char *filename)
{	FILE *file = fopen(filename,"rb");
    	if (file != NULL)
    	{	size_t flen = filelength(fileno(file));
    		char *data_ptr;
	    	if ((data_ptr = malloc(flen)) != NULL)
	    	{	fread(data_ptr,1,flen,file);
			fclose(file);
			return (char *) data_ptr;
		} else
			fatal_error(OUT_MEM,filelength,"");
	} else
			fatal_error(DISK_ERR,0,filename);
}
