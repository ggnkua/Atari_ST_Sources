#include <stdio.h>
#include "bm.h"
int
GetPatFile(PatFile, DescVec)
char *PatFile;
struct PattDesc *DescVec[];
/* read patterns from a file and set up a pattern descriptor vector */
{
	extern char *malloc();
	FILE *PFile;
	int PatSize; /* the number of chars in all the patterns */
	char *PatBuff; /* hold the patterns */
        char *s;
        int readlen;

	if (!(strlen(PatFile))) {
		fprintf(stderr,"bm: no pattern file given\n");
		exit(2);
	} /* if */
	if (!strcmp(PatFile,"-")) {
		PatSize = PSIZEDEF;
                PFile = stdin;
        } else {
	        if (!(PFile = fopen(PatFile,"r"))) {
		        fprintf(stderr,
                                "bm: can't open pattern file %s\n",PatFile);
		        exit(2);
                }
	        if (fseek(PFile,0L,2) == -1) {
		        fprintf(stderr,"bm: can't fseek %s\n",PatFile);
		        exit(2);
	        } /* if */
                PatSize = ftell(PFile);
                rewind(PFile);
	        if (!PatSize) {
		        fprintf(stderr,"bm: pattern file is empty\n");
		        exit(2);
	        } /* if */
	} /* if */
	if (!(PatBuff = malloc(PatSize+1))) {
	        fprintf(stderr,"bm: insufficient memory to store patterns\n");
		exit(2);
	} /* if */
        for (s = PatBuff; (readlen = (PatBuff + PatSize) - s) > 0
                     && fgets(s,readlen,PFile) != (char *)0;
                    s += strlen(s)) {
        }
	/* make sure the patterns are null-terminated. We can't have
	* nulls in the patterns */
	if (s[-1] == '\n')
		s[-1] = '\0';
	else
		s[0] = '\0';
        if (PFile != stdin) {
	    fclose(PFile);
        } else {
	    clearerr(PFile);
        }
	return(MkDescVec(DescVec,PatBuff));
} /* GetPatFile */
