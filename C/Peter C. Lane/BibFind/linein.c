#include "linein.h"

/* Create a new struct inp, and return a pointer to it */
struct inp * new_string (void) {
	struct inp * input = malloc(sizeof (struct inp));
	input->size = 2;
	input->posn = 0;
	input->str = malloc (3*sizeof(char));
	input->str[0] = input->str[1] = 0;

	return input;
}

/* Free memory held by a given struct inp
 *
 * TODO: doesn't input->str need to be freed?  Gives errors if done.
 */
void free_string (struct inp * input) {
	free (input);
}

/* Add a char to the string held by a given struct inp.
 * The storage space for str is increased if necessary.
 */
void add_char (struct inp * input, char c) {
	char * new_str;

	/* first see if array needs increasing in size */
	if (input->posn+1 == input->size) {
		input->size *= 2; /* double available size */
		if (input->size > 8000) {
			printf ("ERROR : input string exceeds 8000 characters\n");
			exit (-1);
		}
		new_str = malloc(sizeof(char) * (input->size+1));
		strcpy (new_str, input->str);
		free(input->str);
		input->str = new_str;
	}
	/* array must be large enough, so add the character */
	input->str[input->posn] = c;
	input->posn += 1;
	/* retain a 0 at end so always a valid string */
	input->str[input->posn] = 0;
}

/*
 * Return a copy of the string held in inp->str
 * Caller responsible for freeing this string.
 */
char * read_string (struct inp * input) {
	char * result = malloc (sizeof(char) * (strlen(input->str)+1));
	strcpy (result, input->str);
	return result;
}

