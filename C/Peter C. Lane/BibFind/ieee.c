#include "ieee.h"

/* Body of records is same in Harvard as IEEE */
char * ieee_body (struct record * rec) {
	return harvard_body (rec);
}

/* Create an IEEE style string for given author/editor names */
char * ieee_names (struct name * names) {
	char * str;
	int str_size;
	int number_names;
	struct name * next_name;

	/* -- look at all the parsed names, and also make a count */
	number_names = 0;
	next_name = names;
	while (next_name != NULL) { /* TODO von_part */
		str_size += strlen(next_name->first_name) + 1; /* 1 for space */
		str_size += strlen(next_name->last_name) + 2; /* 2 for comma and space */
		if (strcmp ("", next_name->jr_part) != 0) {
			str_size += strlen(next_name->jr_part) + 1;
		}
		number_names += 1;
		next_name = next_name->next;
	}
	if (number_names > 1) str_size += 2; /* for 'and' on last name */

	/* create string */
	str = malloc (sizeof(char) * str_size);

	sprintf (str, "");

	/* -- loop through names, adding them to str */
	next_name = names;
	while (next_name != NULL) { /* TODO von_part */
		strcat (str, next_name->first_name);
		strcat (str, " ");
		if (strcmp ("", next_name->jr_part) != 0) {
			strcat (str, next_name->jr_part);
			strcat (str, " ");
		}
		strcat (str, next_name->last_name);

		number_names -= 1;

		if (number_names == 0) {
			;
		} else if (number_names == 1) {
			strcat (str, " and ");
		} else {
			strcat (str, ", ");
		}
		next_name = next_name->next;
	}

	return str;
}

