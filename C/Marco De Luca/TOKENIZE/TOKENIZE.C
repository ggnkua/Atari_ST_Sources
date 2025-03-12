/********************************************************************/
/*																	*/
/*	TOKENIZE.C	30-06-94											*/
/*																	*/
/*	Processes textfiles into tokens, separated by tabs				*/
/*																	*/
/*	(c) 1994 pARTner												*/
/*			 sYSTems												*/
/*	----------///-----------------------							*/
/*	A handmade software by Marco De Luca							*/
/*																	*/
/********************************************************************/
#include <stdio.h>
#include <ext.h>
#include <string.h>

int tokenize (char *, char *);

#define NAME	"TOKENIZE"

/*	--------------------------------------------------------------	*/
/*	main															*/
/*	--------------------------------------------------------------	*/
main(int argc, char *argv[])
{
	if (argc < 3)
	{
		fprintf(stderr, NAME": Too few arguments (<infile> <outfile> expected)\n");
		return 1;
	}
	tokenize (argv[1], argv[2]);
	return 0;
}

/*	--------------------------------------------------------------	*/
/*	tokenize														*/
/*	--------------------------------------------------------------	*/
int tokenize (char *in_file, char *out_file)
{
	#define MAX_LEN	255

	FILE *in, *out;
	char line[MAX_LEN], *token;
	int tpl, l = 0;

	if ((in = fopen (in_file , "r")) == NULL)
	{
		perror (NAME);
		return 0;
	}

	if ((out= fopen (out_file, "w")) == NULL)
	{
		perror (NAME);
		return 0;
	}

	printf ("\033f\033E"NAME": Processing line ");
	while (fgets (line, MAX_LEN, in) != NULL)
	{
		printf ("\033Y%c%c%d",32 , 58, ++l);

		tpl = 0;
		token = strtok(line, " \t");		/*	get (first) token				*/
		while (1)
		{
			tpl++;							/*	count tokens per line			*/
			if (tpl == 1 && *token == '\n')	/*	1. token in line is newline?	*/
				break;						/*	...don't write it				*/

			fputs (token, out);				/*	write token						*/

			token = strtok(NULL, " \t");	/*	get next token					*/
			if (token == NULL)				/*	are we out of tokens?			*/
				break;						/*	let's get out of here			*/

			if (*token != '\n')				/*	is token a EOL?					*/
				fputc ('\t' , out);			/*	No? -> then write separator		*/
		}
	}

	fclose (in);
	fclose (out);

	return 0;
}
