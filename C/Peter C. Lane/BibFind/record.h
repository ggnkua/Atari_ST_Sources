#if !defined(RECORD_H)
#define RECORD_H

/* Functions for holding bibtex records */

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "linein.h"
#include "harvard.h"
#include "ieee.h"

/* structure to define a linked list of key-value pairs */
struct keyval {
	char * key;
	char * val;
	struct keyval * next; /* pointer to next, or NULL */
};

/* structure to hold parts of author names
   Names have up to four parts:  L. van Beethoven, Sr
   first_name: L.
   von_part: van
   last_name: Beethoven
   jr_part: Sr
 */
struct name {
	char * first_name; /* holds the first and middle names */
	char * von_part;
	char * last_name;
	char * jr_part;
	struct name * next; /* pointer to next, or NULL */
};

/* structure to hold the actual record data separate from the list */
struct data {
	char * type;
	char * id;
	struct name * parsed_names;
	struct name * parsed_editors;
	struct keyval * values;
	bool marked; /* flag to indicate if in reserved list */
};

/* structure to hold the record structure, maintains two-way list */
struct record {
	struct data * rd; 		/* pointer to the actual data */
	struct record * next;
	struct record * prev;
};

struct record * new_record (void);
struct record * copy_record (struct record * rec);
void free_record (struct record * rec);
void add_key_value (struct record * rec, char * key, char * val);
char * get_value_for (struct record * rec, char * key);
void print_record (struct record * rec);
void print_records (struct record * rec);
int count_records (struct record * rec);
char * strstri (char * cs, char * ct);
int contains_term (struct record * rec, char * search_term);
int contains_terms (struct record * rec, char * search_terms);
struct record * find_records (struct record * rec, char * search_terms);
struct record * read_records (FILE * fp);
char * record_citation (struct record * rec);
char * record_harvard_name (struct record * rec);
char * record_harvard (struct record * rec);
char * record_ieee (struct record * rec);

#endif
