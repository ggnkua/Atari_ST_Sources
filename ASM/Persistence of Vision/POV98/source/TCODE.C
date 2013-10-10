/*
 * tcode.c
 */

#include <stdio.h>

#define FALSE 0
#define TRUE 1
#define IN_FILE "TEXT"
#define OUT_FILE "SCROLLER.TXT"


extern char
	*malloc ();


typedef unsigned char Byte;


Byte
	*data;

char
	letters[]=" !\"\'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ",
	*text;

int
	fsize;


main ()
{
	load_file (IN_FILE);
	code_file ();
	save_file (OUT_FILE);
	free_mem ();
}


load_file (filename)
char
	*filename;
{
	FILE
		*fd;

	if ((fd=fopen (filename, "br"))==NULL)
	{
		fprintf (stderr, "Cannot open %s\n", filename);
		exit (1);
	}
	fseek (fd, 0L, 2);
	fsize=(int)ftell (fd);
	rewind (fd);
	text=malloc (fsize);
	data=(Byte *)malloc (fsize);
	if (text==NULL || data==NULL)
	{
		fprintf (stderr, "Not enough memory.\n");
		exit (2);
	}
	fread (text, fsize, 1, fd);
	fclose (fd);
}


code_file ()
{
	int
		l_ptr,
		letter,
		found,
		d_ptr=0,
		loop;

	for (loop=0; loop<fsize; loop++)
	{
		letter=text[loop];
		found=FALSE;
		l_ptr=0;
		while (letters[l_ptr]!=NULL && found==FALSE)
		{
			if (letters[l_ptr]==letter)
				found=TRUE;
			else
				l_ptr++;
		}
		if (found)
		{
			data[d_ptr]=(Byte)l_ptr;
			d_ptr++;
		}
		else
		{
			if (letter!=0x0d && letter!=0x0a)
			{
				if (letter == '#')
				{
					data[d_ptr++] = (Byte)((text[loop+1] & 0x0f) | 0x80);
					loop++;
				}
				else
				{
					printf ("Not found %c\n", letter);
				}
			}
		}
	}
	fsize=d_ptr;
}


save_file (filename)
char
	*filename;
{
	FILE
		*fd;

	if ((fd=fopen (filename, "bw"))==NULL)
	{
		fprintf (stderr, "Cannot create %s\n", filename);
		exit (3);
	}
	fwrite ((char *)data, fsize, 1, fd);
	fputc (0xff, fd);
	fclose (fd);
}


free_mem ()
{
	free (text);
	free ((char *)data);
}
