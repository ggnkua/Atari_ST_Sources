#include <stdio.h>

int
main()
{
	/*
	 * Check simple searching.
	 *
	 * Input consists of sets of three lines containing
	 *
	 *      text
	 *      pattern
	 *      expected new text
	 *
	 * See the file examples1
	 *
	 */

	extern int strcmp();
	extern char *strsed();

	char text[1024];
	char pat[1024];
	char ans[1024];
	register char *result;
	register int testno = 0;
	int error = 0;

	while (gets(text) && gets(pat) && gets(ans)){
		testno++;
		result = strsed(text, pat, 0);
		if (strcmp(ans, result)){
			error = 1;
			printf("WARNING (test %d)... strsed(%s, %s) returns '%s'\nExpected '%s'\n", 
				testno, text, pat, result, ans);
			fflush(stdout);
		}
	}

	if (!error){
		printf("Substitution and transliteration tests passed successfully.\n");
	}

	return 0;
}
