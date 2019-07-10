#include <stdio.h>

main(int argc, char **argv)
{
	register int c, cr = 0;

	if (stdin == NULL || stdout == NULL)
		exit(-1);

	while ((c = getchar()) != EOF) {
		if (c == '\n') {
			cr++;
			if (cr < 3)
				putchar(c);
		}
		else {
			cr = 0;
			putchar(c);
		}
	}
	exit(0);
}
