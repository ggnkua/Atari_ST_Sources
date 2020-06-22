#include <stdio.h>

int
main()
{
	/*
	 * Check simple searching.
	 *
	 * Input consists of sets of four lines containing
	 *
	 *      text
	 *      pattern
	 *      expected start of match
	 *      expected end of match
	 *
	 * See the file examples2
	 *
	 */

	extern int atoi();
	extern char *strsed();

	char text[1024];
	char pat[1024];
	char ans1[10];
	char ans2[10];
	int range[2];
	int low;
	int high;
	register int testno = 0;
	int error = 0;

	while (gets(text) && gets(pat) && gets(ans1) && gets(ans2)){
		testno++;
		strsed(text, pat, range);
		low = atoi(ans1);
		high = atoi(ans2);
		if (low != range[0] || high != range[1]){
			error = 1;
			printf("WARNING (test %d)... strsed(%s, %s) returns range %d-%d (Expected %d-%d)\n", 
				testno, text, pat, range[0], range[1], low, high);
			fflush(stdout);
		}
	}

	if (!error){
		printf("Searching tests passed successfully.\n");
	}

	return 0;
}
