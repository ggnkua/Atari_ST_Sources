/* global flags for bm */
extern int	cFlag, /* true if we want only a count of matching lines */
	eFlag, /* indicates that next argument is the pattern */
	fFlag, /* true if the patterns arew to come from a file */
	lFlag, /* true if we want a list of files containing the pattern */
	nFlag, /* true if we want the character offset of the pattern */
	sFlag, /* true if we want silent mode */
	xFlag, /* true if we want only lines which match entirely */
	hFlag, /* true if we want no filenames in output */

	MatchCount; /* count of number of times a search string was found
	* in the text */
extern char *FileName;
