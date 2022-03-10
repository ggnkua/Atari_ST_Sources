/* global flags for bm */
int	cFlag=0, /* true if we want only a count of matching lines */
	eFlag=0, /* indicates that next argument is the pattern */
	fFlag=0, /* true if the patterns are to come from a file */
	lFlag=0, /* true if we want a list of files containing the pattern */
	nFlag=0, /* true if we want the character offset of the pattern */
	sFlag=0, /* true if we want silent mode */
	xFlag=0, /* true if we want only lines which match entirely */
	hFlag=0, /* true if we want no filenames in output */

	MatchCount=0; /* count of number of times a search string was found
	* in the text */
char *FileName = 0;
