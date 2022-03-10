#include <stdio.h>
#include "bm.h"
extern char *malloc();

MakeSkip(Pattern,Skip1,Skip2,PatLen)
char Pattern[];
unsigned short int Skip1[], Skip2[];
int PatLen;
/* generate the skip tables for Boyer-Moore string search algorithm.
* Skip1 is the skip depending on the character which failed to match
* the pattern, and Skip2 is the skip depending on how far we got into
* the pattern. Pattern is the search pattern and PatLen is strlen(Pattern) */
{
	int *BackTrack; /* backtracking table for t when building skip2 */
	int c; /* general purpose constant */
	int j,k,t,tp; /* indices into Skip's and BackTrack */

	if (!(BackTrack = (int *) malloc(PatLen * (sizeof (int))))){
		fprintf(stderr,"bm: can't allocate space\n");
		exit(2);
	} /* if */
	for (c=0; c<=MAXCHAR; ++c)
		Skip1[c] = PatLen;
	for (k=0;k<PatLen;k++) {
		Skip1[Pattern[k]] = PatLen - k - 1;
		Skip2[k] = 2 * PatLen - k - 1;
	} /* for */
	for (j=PatLen - 1,t=PatLen;j >= 0; --j,--t) {
		BackTrack[j] = t;
		while (t<PatLen && Pattern[j] != Pattern[t]) {
			Skip2[t] = min(Skip2[t], PatLen - j - 1);
			t = BackTrack[t];
		} /* while */
	} /* for */
	for (k=0;k<=t;++k)
		Skip2[k] = min(Skip2[k],PatLen+t-k);
	tp=BackTrack[t];
	while(tp<PatLen) {
		while(t<PatLen) {
			Skip2[t] = min(Skip2[t],tp-t+PatLen);
			++t;
		} /* while */
		tp = BackTrack[tp];
	} /* while */
	cfree(BackTrack);
} /* MakeSkip */
