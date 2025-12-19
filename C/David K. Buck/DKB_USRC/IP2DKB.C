/*


IP2DKB - 1.00  01/05/90  FPW2
		 1.10  05/07/90  AAC

         Do what you want with this, but leave this comment, my name,  and
         copyright intact.

         DigiView IP format for color is basically the red, green, and blue
         arrays (left to right, top to bottom) back to back with a 12 byte
         trailer ($8000 $8000 $8000 $8000 $8000 $8000).  Since DigiView only
         digitizes to 2 million levels, raw data from the digitizer itself
         will have the LSB set to zero.


   I can be reached on a few Denver Amiga BBS's, at fweed@nyx.cs.du.edu and
uunet!isis!nyx!ufweed!fweed on UseNet, and at the following address:

              Frank P. Weed II
              P.O. Box 28184 #16
              Lakewood, CO  80228


         Version 1.10 - Modified to semi-ANSI "C" for greater portability.

			  Aaron A. Collins
*/

#include <stdio.h>
#include <stdlib.h>


/* Functions Prototypes */
void Title(void);
void ShowUsage(void);
void CleanUp(int);
void Validate(void);
void Convert(void);

#ifndef FALSE
#define FALSE	0
#endif

#ifndef TRUE
#define TRUE	!FALSE
#endif

FILE *input, *output;
unsigned short lines, width;
int filepos, position;
int checks = FALSE;
char *IPBuf = NULL;

void Title()
{
	printf("\033[2;33mIP2DKB\033[0m - Version 1.10\n");
	printf("\033[2;32mCopyright (c) 1991 Frank P. Weed II\n\033[0m");
}

void ShowUsage()
{
	printf("\n");
	printf("  Usage: \033[2;33mIP2DKB\033[0m <infile> <outfile>\n");
	printf("\n");
	exit(5);
}

void CleanUp(n)
int n;
{
	if (IPBuf)
		free(IPBuf);
	exit(n);
}

void Validate()
{
	long	filelen;

	fseek(input, 0L, 2);
	filelen = ftell(input);
	if (((long)width * lines * 3 + 12) == filelen)
		checks = TRUE;
	if (!checks)
		{
		printf("Input didn't pass validation\n");
		CleanUp(1);
		}
	rewind(input);
}

void Convert()
{
	int w,h;
	unsigned char Hi,Lo;
	char *rptr,*gptr,*bptr;

	printf("Width and height? ");
	scanf("%d %d", &w, &h);
	width = w; lines = h;
	Validate();
	IPBuf = (char *)malloc(width*lines*3);
	if (IPBuf == NULL)
		{
		printf("Couldn't grab enough memory\n");
		CleanUp(5);
		}
	printf("Reading...");
	fread(IPBuf, width*lines*3, 1, input);
	printf("done\n");
	Hi = (unsigned char)(width % 256);
	fwrite(&Hi, 1, 1, output);
	Lo = (unsigned char)(width / 256);
	fwrite(&Lo, 1, 1, output);
	Hi = (unsigned char)(lines % 256);
	fwrite(&Hi, 1, 1, output);
	Lo = (unsigned char)(lines / 256);
	fwrite(&Lo, 1, 1, output);
	rptr = IPBuf;
	gptr = IPBuf + (width * lines);
	bptr = IPBuf + (2 * width * lines);
	for (filepos=0; (unsigned short) filepos < lines; filepos++)
		{
		Hi = (unsigned char)(filepos % 256);
		Lo = (unsigned char)(filepos / 256);
		printf("Writing line #%d\n\033[0F", filepos);
		fwrite(&Hi, 1, 1, output);
		fwrite(&Lo, 1, 1, output);
		fwrite(rptr, 1, width, output);
		fwrite(gptr, 1, width, output);
		fwrite(bptr, 1, width, output);
		rptr += width;
		gptr += width;
		bptr += width;
		}
	printf("\n");
}

void main(argc,argv)
int	argc;
char	*argv[];
{
	Title();
	if (argc != 3)
		ShowUsage();
	input = fopen(argv[1],"rb");
	if (input == NULL)
		{
		printf("Can't find input file\n");
		CleanUp(5);
		}
	output = fopen(argv[2],"wb");
	if (output == NULL)
		{
		printf("Can't make output file\n");
		CleanUp(5);
		}
	Convert();
	printf("Finished\n");
	CleanUp(0);
}
