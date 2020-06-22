#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFSIZE 200

void main(int argc, char *argv[])
{
	char buf[BUFSIZE], *comment, *tmp;
	FILE *infile, *outfile;
	int i, n;

	if (argc < 2) {
		printf("Usage: xlc2gcc infiles\n");
		exit(-1);
	}

	for(i = 1;i <= argc;i++)
	{	
		sprintf(buf,"new\\%s",argv[i]);
		printf("Original: %s    New: %s\n", argv[i], buf);

		if ((infile = fopen(argv[i],"r")) == NULL)
		{
			printf("Can't find file!\n");
			exit(-1);
		}

		if ((outfile = fopen(buf,"w")) == NULL)
		{
			printf("Can't open file!\n");
			fclose(infile);
			exit(-1);
		}
	
		fgets(buf, BUFSIZE, infile);
		do {
			if (comment = strstr(buf, "//"))
			{
				comment[1] = '*';
				for(tmp = &buf[strlen(buf)];*tmp < ' ';tmp--)
					*tmp = '\0';
				strcat(buf, " */\n");
			}
			fputs(buf, outfile);
			buf[0] = '\0';
			fgets(buf, BUFSIZE, infile);
		} while (!feof(infile));
	
		if (strlen(buf))
			fputs(buf, outfile);

		fclose(outfile);
		fclose(infile);
	}
}

