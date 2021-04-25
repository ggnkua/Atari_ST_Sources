/* look for strings in a file */

#include "stdio.h"

#define MAXLINE	256

char 	line[MAXLINE];
char	str[MAXLINE];

main(argc, argv) char *argv[]; {
	int i;
	char *nm;
	FILE *f;
	if (argc == 1) {
		fprintf(stderr, "usage: grep pat file ...\n");
		exit(1);
	}

	strcpy(str, argv[1]);
	lower(str);
	nm = NULL;

	if (argc == 2) {
		grep(nm, str, stdin);
	}
	else for (i = 2; i < argc; i++) {
		if ((f = fopen(argv[i], "r")) != NULL) {
			if (argc > 3) nm = argv[i];
			grep(nm, str, f);
			fclose(f);
		}
		else 	fprintf(stderr, "can't open %s\n", argv[i]);
	}
}

lower(s) char *s; { /* don't need this if cmd works right */
	char c;
	while (c = *s) {
		if (c >= 'A' && c <= 'Z')
			*s = c - 'A' +  'a';
		s++;
	}
}

grep(name, str, f) char *name, *str; FILE *f; {
	while (fgets(line, MAXLINE, f)) {
		lower(line);
		if (in(str, line)) {
			if (name) printf("%s: ", name);
			printf("%s", line);
		}
	}
}

in(s, l) char *s, *l; {
	char c, i;
	i = 0;
	while (c = *l++) {
		if (c == s[i]) {
			i++;
			if (s[i] == 0) return 1;
		}
		else	i = 0;
	}
	return 0;
}

