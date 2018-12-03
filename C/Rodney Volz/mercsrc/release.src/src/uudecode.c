/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [uudecode.c]
 */

static char sccsid[] = "@(#) MERCURY CORP. [uucp: uudecode]";

#include <stdio.h>
#include <ctype.h>

#define SUMSIZE 64
#define DEC(c)	(((c) - ' ') & 077)    /* single character decode */

main(argc, argv)
char **argv;
{
	FILE	*in, *out;
	int	through_loop=0; /* Dejavu indicator */
	int	mode;		/* file's mode (from header) */
	long	filesize;	/* theoretical file size (from header) */
	char	dest[128];
	char	buf[80];


	/* A filename can be specified to be uudecoded, or nothing can
    be specified, and the input will come from STDIN */

	if ((argc <= 1) || (argc > 3))
	{
		printf("Usage: %s input [output]\n",argv[0]);
		return(-1);
	}

	if ((in = fopen(argv[1], "rb")) == NULL)
	{
		fprintf(stderr, "ERROR: can't find %s\n", argv[1]);
		return(-1);
	}

	if (argc == 3)
	{
		if ((out = fopen(argv[2], "wb")) == NULL)
		{
			fprintf(stderr, "ERROR: can't write to %s\n", argv[2]);
			return(-1);
		}
	}




	for (;;)
	{
		/* search file for header line */
		for (;;)
		{
			if (fgets(buf, sizeof buf, in) == NULL)
			{
				if (!through_loop)
				{
					fprintf(stderr, "ERROR: no `begin' line!\n");
					exit(12);
				}
				else
				{
					exit(0);
				}
			}
			if (strncmp(buf, "begin ", 6) == 0)
				break;
		}
		sscanf(buf, "begin %o %s", &mode, dest);



		/* create output file */
		if ((argc < 3) && (out = fopen(dest, "wb")) == NULL)
		{
			fprintf(stderr, "ERROR: can't open output file %s\n", dest);
			exit(15);
		}


		decode(in, out, dest);

		if (fgets(buf, sizeof buf, in) == NULL || strncmp(buf,"end",3))
		{	       /* don't be overly picky about newline ^ */
			fprintf(stderr, "ERROR: no `end' line\n");
			exit(16);
		}

		if (!(fgets(buf,sizeof buf,in) == NULL || strncmp(buf,"size ",3)))
		{
			sscanf(buf, "size %ld", &filesize);
#ifndef ST
			if (ftell(out) != filesize)
			{
				fprintf(stderr, "ERROR: file should have been %ld bytes long but was %ld.\n", filesize, ftell(out));
				exit(17);
			}
#endif
		}
		through_loop = 1;
	}   /* forever */
}   /* main */

/*
 * Copy from in to out, decoding as you go.
 * If a return or newline is encountered too early in a line, it is
 * assumed that means that some editor has truncated trailing spaces.
 */
decode(in, out, dest)
FILE *in;
FILE *out;
char *dest;
{
	char buf[80];
	char *bp;
	int nosum=0;
#ifndef unix
	extern errno;
#endif
	register int j;
	register int n;
	int checksum, line;

	for (line = 1; ; line++)	/* for each input line */
	{
		if (fgets(buf, sizeof buf, in) == NULL)
		{
			fprintf(stderr, "ERROR: input ended unexpectedly!\n");
			exit(18);
		}

		/* Pad end of lines in case some editor truncated trailing
	   spaces */

		for (n=0;n<79;n++)  /* search for first \r, \n or \000 */
		{
			if(buf[n]=='\r'||buf[n]=='\n'||buf[n]=='\000')
				break;
		}
		for (;n<79;n++)     /* when found, fill rest of line with space */
		{
			buf[n]=' ';
		}
		buf[79]=0;	    /* terminate new string */

		checksum = 0;
		n = DEC(buf[0]);
		if (n <= 0)
			break;	/* 0 bytes on a line??	Must be the last line */

		bp = &buf[1];

		/* FOUR input characters go into each THREE output charcters */

		while (n >= 4)
		{
			j = DEC(bp[0]) << 2 | DEC(bp[1]) >> 4; 
			binputc(j, out); 
			checksum += j;
			j = DEC(bp[1]) << 4 | DEC(bp[2]) >> 2; 
			binputc(j, out); 
			checksum += j;
			j = DEC(bp[2]) << 6 | DEC(bp[3]);	   
			binputc(j, out); 
			checksum += j;
			checksum = checksum % SUMSIZE;
			bp += 4;
			n -= 3;
		}

		j = DEC(bp[0]) << 2 | DEC(bp[1]) >> 4;
		checksum += j;
		if (n >= 1)
			binputc(j, out);
		j = DEC(bp[1]) << 4 | DEC(bp[2]) >> 2;
		checksum += j;
		if (n >= 2)
			binputc(j, out);
		j = DEC(bp[2]) << 6 | DEC(bp[3]);
		checksum += j;
		if (n >= 3)
			binputc(j, out);
		checksum = checksum % SUMSIZE;
		bp += 4;
		n -= 3;

#ifndef unix
		/* Error checking under UNIX??? You must be kidding... */
		/* Check if an error occured while writing to that last line */
		if (errno)
		{
			fprintf(stderr, "ERROR: error writing to %s\n",dest);
			exit(19);
		}
#endif

		/* The line has been decoded; now check that sum */

		nosum |= !isspace(*bp);
		if (nosum)			/* Is there a checksum at all?? */
		{
#if 0
			if (checksum != DEC(*bp))	/* Does that checksum match? */
			{
				fprintf(stderr, "ERROR: checksum mismatch decoding %s, line %d.\n",dest, line);
			}
#endif
		}	/* sum */
	}	/* line */
}   /* function */

#ifdef unix
/*
 * Return the ptr in sp at which the character c appears;
 * 0 if not found
 */
char *
index(sp, c)
register char *sp, c;
{
	do
	{
		if (*sp == c)
			return(sp);
	}    while (*sp++);

	return(0);
}
#endif
