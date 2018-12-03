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
 * MERCURY UUCP SOURCECODE [unshar.c]
 */

static char sccsid[] = "@(#) MERCURY CORP. [uucp: unshar]";

#include <stdio.h>
#include <ctype.h>
#include <string.h>


#define F_OK	0
#define SIZEOFBUF 512		/* Max length of an input line */
#define STRLEN	512		/* Max length of a file name or delimiter */
#define CAT	"cat"           /* The name of the 'cat' program */
#define SED	"sed"           /* The name of the 'sed' program */
#define TEST	"if test"       /* Leader for test types */

main(argc, argv)
int	argc;
char  *argv[];
{
	int n,o;
	long _stksize = 16384l;

#if 0
	if (argc == 1)
	{
		fprintf(stderr,"Usage: unshar file1 [file2 ...]\n");
		exit(1);
	}
	
	for (n = 1; n < argc; n++)
	{
		o = unshar(argv[n]);
	}
#else
	if (argc != 2)
	{
		fprintf(stderr,"Usage: unshar file\n");
		exit(1);
	}

	o = unshar(argv[1]);
#endif
}





/*
 * This is a small routine that given the beginning of a quoted, backslashed
 * or just plain string, will return it in a given buffer.
 */
void
copystring(source, dest)
char *source, *dest;
{
	register int i = 0;
	char c;

	if ('\'' == *source || '\"' == *source) {/* Is it a quoted string? */
		c = *source;
		while (c != *++source)
			dest[i++] = *source;
		source++;
	} else if ('\\' == *source) {                   /* Is it a backslashed string? */
		while (!isspace(*++source))
			dest[i++] = *source;
	} else {								/* Just a string */
		while (!isspace(*source)) {
			dest[i++] = *source;
			source++;
		}
	}
	dest[i] = '\0';
}

wordcount(buf, filename, wc)
char *buf, *filename;
int wc;
{
	if (wc != atoi(buf)) {
		(void) printf("Error unsharing %s (wc should have been %d, but was %d)\n", filename, atoi(buf), wc);
	}
}

int
checkfile(string)
char *string;
{
	char filename[STRLEN];

	while (0 != isspace(*string))
		string++;

	copystring(string, filename);
	if (0 == access(filename, F_OK))
		return 1;

	return 0;
}

/*
 * This is a small routine that given a 'cat' or 'sed' string, will pull out
 * the end of file string and the file name
 */

getendfile(line, end, file)
char   *line,			/* The 'sed' or 'cat' string */
       *end,			/* Place to store the end of file marker */
       *file;			/* Place for the filename */
{
	char   *tmp;

	/*
	 * This section of code finds the end of file string.  It assumes
	 * that the eof string is the string of characters immediately
	 * following the last '<' and that it has either a '\' preceding it
	 * or is surrounded by single quotes.
	 */
	tmp = (char *) strrchr(line, '<');       /* Find the last '<' on the
											 * line */
	while (isspace(*++tmp))
		;	/* Do nothing */
	copystring(tmp, end);

	/*
	 * This section of code finds the name of the file.  It assumes that
	 * the name of the file is the string immediately following the last
	 * '>' in the line
	 */
	tmp = (char *) strrchr(line, '>');
	while (isspace(*++tmp))
		;	/* Do Nothing */
	copystring(tmp, file);

#ifdef DEBUG
	(void) printf("EOF = %s, FILE = %s\n", end, file);
#endif DEBUG
}






convert(s)
char *s;
{
	char c,*cp1,*cp2;
	extern char *rindex();

	if ((cp2 = rindex(s,'.')) == NULL)
		return(NULL);

	for (cp1 = s; cp1 < cp2; cp1++)
	{
		c = *cp1;
		*cp1 = (c == '.') ? '_' : c;
	}
}



int unshar(inpfile)
char *inpfile;
{
	FILE   *fp, *dfp;		/* input file pointer and dest file
					 * pointer */
	char	buf[SIZEOFBUF],		/* line buffer */
		prefix[STRLEN], 	/* SED leader if any */
		eotxt[STRLEN],		/* EOF marker */
		filename[STRLEN];	/* file name */
	int	infile = 0,			/* var to tell if we're in the middle of a
								 * file or not */
		wc = 0, 			/* variable to keep a word count */
			fileexists = 0; 	/* does the file exist? */


	if (NULL == (fp = fopen(inpfile, "r")))
	{
		fprintf(stderr,"unshar: cannot open input file %s\n",inpfile);
		return(1);
	}

	while (NULL != fgets(buf, SIZEOFBUF, fp)) {       /* while there are lines
							 * to get */
		if (0 == infile) {      /* if we are not in the middle of a
					 * file */
			if ('#' == buf[0])      /* comment? */
				continue;

			/* Is this a CAT type shar? */
			if (0 == strncmp(buf, CAT, strlen(CAT))) {
				prefix[0] = '\0';
				getendfile(buf, eotxt, filename);
				if (fileexists != 0) {
					fprintf(stderr, "File exists (%s), skipping\n", filename);
					fileexists = 0;
					continue;
				}

				convert(filename);

				if (NULL == (dfp = fopen(filename, "w"))) {
					(void) printf("Error opening output file %s\n", filename);
					return(1);
				}
				(void) printf("unshar: extracting %s... ", filename);
				(void) fflush(stdout);
				infile = 1;
				wc = 0;
				continue;
			}
			
			/* Is it a SED type shar? */
			if (0 == strncmp(buf, SED, strlen(SED)))
			{
				register int i = 0, j = 0;

				while ('^' != buf[i++])
					;
				while ('/' != buf[i]) {
					prefix[j++] = buf[i++];
				}
				prefix[j] = '\0';
				getendfile(&buf[i], eotxt, filename);
				if (fileexists != 0) {
					fprintf(stderr, "File exists (%s), skipping\n", filename);
					fileexists = 0;
					continue;
				}
				if (NULL == (dfp = fopen(filename, "w"))) {
					(void) printf("Error opening output file %s\n", filename);
					return(1);
				}
				(void) printf("unshar: extracting %s... ", filename);
				(void) fflush(stdout);
				infile = 1;
				wc = 0;
				continue;
			}

			/* Do we want to do a test of sorts on a file? */
			if (0 == strncmp(buf, TEST, strlen(TEST))) {
				register int i = 0;

				while(!isdigit(buf[i]) && buf[i] != '-' && buf[i])
					i++;

				if (0 != isdigit(buf[i])) {
					wordcount(&buf[i], filename, wc);
				}

				if ('f' == buf[++i]) {
					fileexists = checkfile(&buf[++i]);
				}
				continue;
			}
		}
		else
		{	/* We are in the middle of a file */

			if (0 == strncmp(buf, eotxt, strlen(eotxt))) {
				(void) printf("ok\n");
				(void) fclose(dfp);
				infile = 0;
				continue;
			}
			if ('\0' == prefix[0]) {
				fputs(buf, dfp);
				wc = wc + strlen(buf);
			}
			else
			{

				/*
				 * If it does have a prefix, is there one on
				 * this line?
				 */
				if (0 != strncmp(buf, prefix, strlen(prefix))) {
					fputs(buf, dfp);
				}
				else
				{
					fputs(&buf[strlen(prefix)], dfp);
					wc = wc + strlen(buf) - strlen(prefix);
				}
			}
		}
	}

	fclose(fp);
	return(0);
}


