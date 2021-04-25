/* check the library ordering */

#include "stdio.h"

int	last_def;
char	word[100];

main(argc, argv) char *argv[]; {
	int i;
	char *getword();
	FILE *fp;
	if ((fp = fopen(argv[1], "r")) == NULL) {
		printf("can't open %s\n", argv[1]);
		exit(0);
	}
	while (getword(fp, word)) {
		if (strcmp(word, ":") == 0) {
			define(getword(fp, word));
		}
		else if (strcmp(word, "jsr") == 0) {
			use(getword(fp, word));
		}
		else if (word[0] == 'l' && word[1] == 'g') {
			use(getword(fp, word));
		}
		else if (word[0] == 's' && word[1] == 'g') {
			getword(fp, word);
			use(getword(fp, word));
		}
	}
}

char *
getword(fp, s) FILE *fp; char *s; {
	int c;
	char *r = s;
	c = getc(fp);
	while (c != EOF && c <= ' ')
		c = getc(fp);
	if (c == EOF) return NULL;
	while (c != EOF && c > ' ') {
		*s++ = c;
		c = getc(fp);
	}
	*s = 0;
	return r;
}

#define S_NIL	0
#define MAXSYM	10000
#define MAXSPC	20000		/* max symbol space			*/

char 	sym[MAXSPC];		/* space for symbols			*/
int  	lsym = 0;			/* end of symbol space			*/
char 	*symptr[MAXSYM];	/* pointer to the symbol string		*/
int 	symtype[MAXSYM];	/* type of the symbol			*/
int	symval[MAXSYM];		/* value of a symbol			*/

lookup(nm) char *nm; {
	int i, start;
	start = i = *nm;
	while (symptr[i]) {
		if (strcmp(nm, symptr[i]) == 0) return i;
		i++;
		if (i == MAXSYM) i = 0;
		if (i == start) {
			fprintf(stderr, "symbol table full");
			return 0;
		}
	}
	symptr[i] = &sym[lsym];
	while (sym[lsym++] = *nm++)
		;
	sym[lsym++] = 0;
	symtype[i] = symval[i] = 0;
	if (lsym >= MAXSPC) {
		fprintf(stderr, "symbol space full");
		return 0;
	}
	return i;
}

define(s) char *s; {
	int id;
	if (s != NULL) {
		/* printf("define %s\n", s); */
		last_def = id = lookup(s);
		symval[id] = 1;
	}
}

use(s) char *s; {
	int id;
	if (s != NULL) {
		/* printf("    using %s in %s\n", s, symptr[last_def]); */
		id = lookup(s);
		if (symval[id])
			printf("%s should come after %s\n", 
				s, symptr[last_def]);
	}
}

