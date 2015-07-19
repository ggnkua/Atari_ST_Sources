#include <stdio.h>
#include <string.h>

FILE	*in,*out;
char	filein[100],fileout[100];

int cdecl main(int argc,char **argv)
{
	int		narg;
	int		c,lastc;
	long	length,i;
	if (argc<2)
	{
		printf("Unixdos: Usage:\n\tunixdos filename\n");
		return 1;
	}
	for (narg=1;narg<argc;narg++)
	{
		strcpy(filein,argv[narg]);
		strcpy(fileout,"$$$");

		printf("Reading: %s... ",filein);
		in=fopen(filein,"rb");
		if (in == (FILE *) NULL)
		{
			printf("Unixdos: File %s not found\n",filein);
			return 2;
		}

		out = fopen(fileout,"wb");
		fseek(in,0L,SEEK_END);
		length=ftell(in);
		fseek(in,0L,SEEK_SET);

		lastc=0;
		for (i=0;i<length;i++)
		{
			c=fgetc(in);
			switch(c)
			{
			case 10:
			case 13:
				if (lastc!=13 || c!=10)
				{
					fputc(13,out);
					fputc(10,out);
				}
				break;
			default:
				fputc(c,out);
				break;
			}
			lastc=c;
		}
		fclose(in);
		fclose(out);
		printf("Writing: %s... ",filein);
		remove(filein);
		rename(fileout,filein);

		printf("\n");
	}
	return 0;
}
