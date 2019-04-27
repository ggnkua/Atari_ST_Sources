/*
 * For reading characters with unknown length
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct inp {
	int size;    /* the maximum size of str */
	int posn;    /* the current top of str */
	char * str;  /* the characters currently read */
};

struct inp * new_string (void);
void free_string (struct inp * input);
void add_char (struct inp * input, char c);
char * read_string (struct inp * input);

