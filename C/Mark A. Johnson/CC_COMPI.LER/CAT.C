/* output some files */

#include "stdio.h"

main(argc, argv) char *argv[]; {
	int i;
	FILE *f;
	if (argc == 1) {
		cat(stdin);
	}
	else for (i = 1; i < argc; i++) {
		if ((f = fopen(argv[i], "r")) != NULL) {
			cat(f);
			fclose(f);
		}
		else 	fprintf(stderr, "can't open %s\n", argv[i]);
	}
}

cat(f) FILE *f; {
	int c;
	while ((c = getc(f)) != EOF)
		putc(c, stdout);
}
