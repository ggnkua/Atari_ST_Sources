#include "getline.h"

/* From K&R book: read a line of text into s, returning length */
int getline (FILE * fp, char s[], int lim, bool keep_newline) {
	int c, i;

	i = 0;
	while (--lim > 0 && (c = fgetc(fp)) != EOF && c != '\n') {
		s[i++] = c;
	}
	if (keep_newline && c == '\n') {
		s[i++] = c;
	}
	s[i] = '\0';

	return i;
}
