#include <stdio.h>
PutUsage()
{
	fprintf(stderr,
	"bm: search for a given string or strings in a file or files\n");
	fprintf(stderr,
	"synopsis: bm [option]* [string(s)] [file]*\n");
	fprintf(stderr,
	"options:\n");
	fprintf(stderr,
	"-c print only a count of matching lines \n");
	fprintf(stderr,
	"-e Take next argument as the pattern\n");
	fprintf(stderr,
	"-f PFile read patterns from a file PFile\n");
	fprintf(stderr,
	"-h Do not print file names\n");
	fprintf(stderr,
	"-l print a list of files containing the pattern(s) \n");
	fprintf(stderr,
	"-n print the character offset of the pattern(s) \n");
	fprintf(stderr,
	"-s silent mode. Return only success (0) or failure (1)\n");
	fprintf(stderr,
	"-x print only lines which match entirely \n");
} /*PutUsage */
