#include "record.h"

/* Creates a new record */
struct record * new_record (void) {
	struct record * rec = malloc (sizeof(struct record));
	struct data * data = malloc (sizeof(struct data));

	rec->rd = data;

	rec->rd->type = "";
	rec->rd->id = "";
	rec->rd->parsed_names = NULL;
	rec->rd->parsed_editors = NULL;
	rec->rd->values = NULL;
	rec->next = NULL;
	rec->prev = NULL;
	rec->rd->marked = false;

	return rec;
}

/* Creates a copy of given record, but preserves pointer to same
   data.
 */
struct record * copy_record (struct record * rec) {
	struct record * copy = malloc (sizeof(struct record));

	copy->rd = rec->rd;
	copy->next = NULL; /* we don't copy any linked records */
	copy->prev = NULL;

	return copy;
}

void free_record (struct record * rec) {
	struct keyval * next;
	struct name * nextn;

	free (rec->rd->type);
	free (rec->rd->id);
	next = rec->rd->values;

	/* free the list of key-value pairs */
	while (next != NULL) {
		struct keyval * oldnext;

		free (next->key);
		free (next->val);
		oldnext = next;
		next = next->next;
		free (oldnext);
	}

	/* free the lists of parsed_names */
	nextn = rec->rd->parsed_names;
	while (next != NULL) {
		struct name * (oldnext);

		free (nextn->first_name);
		free (nextn->von_part);
		free (nextn->last_name);
		free (nextn->jr_part);
		nextn = nextn->next;
		free (oldnext);
	}
	nextn = rec->rd->parsed_editors;
	while (next != NULL) {
		struct name * (oldnext);

		free (nextn->first_name);
		free (nextn->von_part);
		free (nextn->last_name);
		free (nextn->jr_part);
		nextn = nextn->next;
		free (oldnext);
	}
	free (rec->rd);

	/* free 'forwards' in the list only */
	if (rec->next != NULL) {
		free_record (rec->next);
	}
	free (rec);
}

/* Add given key-value to end of list of values in rec
 * Assumes rec acquires ownership of key and val strings.
 */
void add_key_value (struct record * rec, char * key, char * val) {
	struct keyval * kv = malloc (sizeof (struct keyval));
	struct keyval * last;

	kv->key = key;
	kv->val = val;
	kv->next = NULL;

	last = rec->rd->values;
	if (last == NULL) { /* first pair */
		rec->rd->values = kv;
	} else { /* find last pair, and connect kv as its next */
		while (last->next != NULL) {
			last = last->next;
		}
		last->next = kv;
	}
}

/* display given record on stdout */
void print_record (struct record * rec) {
	struct keyval * kv = rec->rd->values;

	printf ("Record %s (%s):\n", rec->rd->id, rec->rd->type);
	while (kv != NULL) {
		printf ("-- %s:\n     %s\n", kv->key, kv->val);
		kv = kv->next;
	}
}

/* display all records to stdout */
void print_records (struct record * rec) {
	while (rec != NULL) {
		print_record (rec);
		rec = rec->next;
	}
}

/* return a count of number of records in list */
int count_records (struct record * rec) {
	int count = 0;

	while (rec != NULL) {
		count += 1;
		rec = rec->next;
	}

	return count;
}

/* Case insensitive version of strstr
   Returns NULL if ct not in cs, else returns pointer to location.
*/
char * strstri (char * cs, char * ct) {
	int i; /* position in cs */
	int j; /* position in ct */
	int size_cs = strlen (cs);
	int size_ct = strlen (ct);

	if (cs == NULL || ct == NULL) return NULL; /* empty strings */
	if (size_ct > size_cs) return NULL; /* too long */

	for (i = 0; i < size_cs; i += 1) {
		int foundit = 1;

		for (j = 0; j < size_ct; j += 1) {
			if (i+j > size_cs || tolower(cs[i+j]) != tolower(ct[j])) {
				/* disagreement, so set flag to 0 and stop loop */
				foundit = 0;
				break;
			}
		}
		if (foundit) {
			/* found the string, so return pointer to start */
			return cs+i;
		}
	}

	/* If got here, then ct not found */
	return NULL;
}

/* Returns 1 if given search_term is found inside rec.
   Otherwise, returns 0.
   Matching is case insensitive.
 */
 int contains_term (struct record * rec, char * search_term) {
 	struct keyval * kv;

 	if (strstri (rec->rd->id, search_term) != NULL) return 1;
 	if (strstri (rec->rd->type, search_term) != NULL) return 1;

	kv = rec->rd->values;
	while (kv != NULL) {
		if (strstri(kv->val, search_term) != NULL) return 1;

		kv = kv->next;
	}

 	return 0;
 }

/* Returns 1 if all search_terms are found inside rec.
   Otherwise, returns 0.
   Note: makes own copy of search_terms, so not to corrupt original.
 */
int contains_terms (struct record * rec, char * search_terms) {
	char * next_tok;
	char * copy_search = malloc((1+strlen(search_terms)) * sizeof(char));

	if (search_terms == NULL) return 0;

	strcpy (copy_search, search_terms);

	next_tok = strtok (copy_search, " ");
	while (next_tok != NULL) {
		if (!contains_term (rec, next_tok)) {
			/* failed to find term, so return false */
			free (copy_search);
			return 0;
		}

		next_tok = strtok (NULL, " ");
	}

	free (copy_search);
	/* as not exited yet, all search terms must be found */
	return 1;
}

/* Search for given search_terms: each term separated by a space.
   Return a list of records which contain all the search terms.
 */
struct record * find_records (struct record * rec, char * search_terms) {
	struct record * result = NULL;
	struct record * end_rec = NULL; /* point to last member of list */

	while (rec != NULL) {

		if (contains_terms (rec, search_terms)) {
			struct record * found = copy_record (rec);

			if (result == NULL) {
				result = found;
				result->next = NULL;
				result->prev = NULL;
				end_rec = result;
			} else { /* add to end of current list */
				found->next = NULL;
				found->prev = end_rec;
				end_rec->next = found;
				end_rec = found;
			}
		}

		rec = rec->next;
	}

	return result;
}

/* Skip white space in file */
void skip_whitespace (FILE * fp) {
	int c;

	do {
		c = fgetc (fp);
	} while (isspace (c) && !feof (fp));
	ungetc (c, fp); /* returns the non-space character to stream */
}

/* Read record type - all chars to { */
void read_record_type (FILE * fp, struct record * rec) {
	int c;
	struct inp * ip = new_string ();

	while ((c = fgetc (fp)) != '{') {
		add_char (ip, tolower((char)c)); /* NB: all lower for type */
	}
	rec->rd->type = read_string (ip);

	free_string (ip);
}

/* Read record id - all chars to , */
void read_record_id (FILE * fp, struct record * rec) {
	int c;
	struct inp * ip = new_string ();

	while ((c = fgetc (fp)) != ',') {
		add_char (ip, (char)c);
	}
	rec->rd->id = read_string (ip);

	free_string (ip);
}

/* Read key - all chars to = */
char * read_key (FILE * fp) {
	int c;
	char * key;
	struct inp * ip = new_string ();

	while ((c = fgetc (fp)) != '=') {
		if (c == ' ') continue; /* ignore spaces */
		add_char (ip, (char)c);
	}
	key = read_string (ip);

	free_string (ip);
	return key;
}

/* Read value - all chars to , or } */
char * read_value (FILE * fp) {
	int c, term, count; /* count used to count nesting { } */
	char * val;
	struct inp * ip = new_string ();

	skip_whitespace (fp);
	count = 0;
	term = fgetc (fp);
	if (term == '"' || term == '{') {

		while ((c = fgetc (fp))) {
			if (c == '"') break; /* hit end of value */
			if (c == '{') count += 1; /* nested { } */
			if (c == '}') {
				if (count > 0) {
					count -= 1; /* close nested { } */
				} else { /* count is 0, so end of value */
					break;
				}
			}
			if (c == '\\') { /* special character */
				add_char (ip, (char)c);
				c = fgetc (fp);
			}
			if (c == '\n' || c == '\r') continue; /* ignore newlines */
			if (c == '\t') c = ' '; /* convert tabs to spaces */
			/* otherwise, character is part of value, so store it */
			add_char (ip, (char)c);
		}
	}
	val = read_string (ip);

	free_string (ip);
	return val;
}

/* Read key-value pair.
 * Return 1 if ended with a }
 * else 0 if ended with a ,
 */
int read_key_value (FILE * fp, struct record * rec) {
	int c;
	char * key;
	char * val;

	skip_whitespace (fp);
	c = fgetc (fp);
	if (c == '}') return 1; /* reached end of set */
	ungetc (c, fp); /* not } so return to stream */

	key = read_key (fp);
	val = read_value (fp);
	add_key_value (rec, key, val);

	/* move to next non-whitespace character */
	skip_whitespace (fp);
	c = fgetc (fp);
	if (c == ',') {
		return 0; /* finished with reading , */
	} else { /* end of key=value pairs: c must have been } */
		return 1;
	}
}

/* Read a single record from fp */
struct record * read_record (FILE * fp) {
	int c;
	struct record * rec = new_record ();

	skip_whitespace (fp);
	c = fgetc (fp);
	if (feof (fp)) return NULL;

	if (c == '@') {
		read_record_type (fp, rec);
		read_record_id (fp, rec);
		while (read_key_value (fp, rec) == 0);
	} else {
		printf ("ERROR: no start of record\n");
		getchar ();
		exit (-1);
	}

	return rec;
}

/* Read zero or more records from fp
   Returns a pointer to a struct record, for caller to manage.
 */
struct record * read_records (FILE * fp) {
	struct record * rec = NULL; /* point to start of list */
	struct record * end_rec = NULL; /* point to last record in list */

	while(!feof(fp)) {
		struct record * next_rec = read_record (fp);
		if (next_rec != NULL) {
			/* add new record to end of current chain,
		       and keep the new record as new end of list */
			if (end_rec == NULL) { /* adding first one */
				next_rec->next = NULL;
				next_rec->prev = NULL;
				rec = next_rec;
				end_rec = next_rec;
			} else { /* add to end of current list */
				next_rec->next = NULL;
				next_rec->prev = end_rec;
				end_rec->next = next_rec;
				end_rec = next_rec;
			}
		}
	}

	return rec;
}

/* return the value of given key: returns NULL if key not found
   Note: makes a new copy of value */
char * get_value_for (struct record * rec, char * key) {
	struct keyval * search_key = rec->rd->values;

	while (search_key != NULL) {
		if (strcmp (search_key->key, key) == 0) {
			char * result = malloc (sizeof(char) * (strlen(search_key->val) + 1));
			strcpy (result, search_key->val);
			return result;
		}
		search_key = search_key->next;
	}
	return NULL;
}

/* Add a new parsed_name entry for given values.
   Makes our own copies of strings, for safety.
 */
struct name * add_parsed_name (struct name * names, char * first, char * von, char * last, char * jr) {
	char * cfirst = malloc (sizeof(char) * (strlen (first) + 1));
	char * cvon = malloc (sizeof(char) * (strlen (von) + 1));
	char * clast = malloc (sizeof(char) * (strlen (last) + 1));
	char * cjr = malloc (sizeof(char) * (strlen (jr) + 1));
	struct name * parsed_name = malloc (sizeof (struct name));

	strcpy (cfirst, first);
	strcpy (cvon, von);
	strcpy (clast, last);
	strcpy (cjr, jr);

	parsed_name->first_name = cfirst;
	parsed_name->von_part = cvon;
	parsed_name->last_name = clast;
	parsed_name->jr_part = cjr;
	parsed_name->next = NULL;

	if (names == NULL) {
		return parsed_name;
	} else {
		/* add to end of list */
		struct name * end_name = names;
		while (end_name->next != NULL) {
			end_name = end_name->next;
		}
		end_name->next = parsed_name;
	}
	return names;
}

/* parse the given authors and add to list structure of names.
   Function may handle author or editor fields.
  */
struct name * parse_names (struct name * names, char * author_str) {
	char * word;
	int terms;
	char * next_name;

	if (author_str == NULL) return names; /* nothing to do */

	/* take string, and split on 'and'
	   TODO: 'and' within { }, e.g. 'Barnes and Noble'
	 */
	do {
		next_name = strstr (author_str, " and ");
		if (next_name != NULL) {
		  	*next_name = 0; /* terminate at this 'and' */
		  	next_name += 1;
		}
		/* process this name */
		terms = 1; /* always at least one part to name */
		/* count the , to see how many terms */
		for (word = author_str; *word != 0; word += 1) {
			if (*word == ',') terms += 1;
		}
		/* reject spaces at start of author_str */
		while (*author_str == ' ') author_str += 1;

		/* based on the number of terms, decide what to do */
		switch (terms) {
			char * last_word;
			char * middle_word;
		    char * next_to_last;
			case 1:
				/* name is of form 'Ludwig Beethoven' */
				last_word = strrchr (author_str, ' ');
				/* make sure { } pairs are honoured
				   TODO: This fails with nested { }
				   */
				while (last_word > author_str &&
						strchr (last_word, '}') != NULL &&
				    	strchr (last_word, '{') == NULL) {
				    *last_word = 0;
				    next_to_last = strrchr (author_str, ' ');
				    *last_word = ' ';
				    last_word = next_to_last;
				}
				/* finally, remove the '}', assuming it ends the last name */
				if ((next_to_last = strrchr (last_word, '}')) != NULL) {
				  	*next_to_last = 0;
				}
				*last_word = 0;
				last_word += 1;
				while (*last_word == ' ' || *last_word == '{') last_word += 1;
				if (strlen (author_str) > 0 || strlen (last_word) > 0) {
					names = add_parsed_name (names, author_str, "", last_word, "");
				}
				break;

			case 2:
				/* name is of form 'Beethoven, Ludwig' */
				last_word = strrchr (author_str, ',');
				*last_word = 0;
				last_word += 1;
				while (*last_word == ' ') last_word += 1;
				if (strlen (author_str) > 0 || strlen (last_word) > 0) {
					names = add_parsed_name (names, last_word, "", author_str, "");
				}
				break;

			case 3:
				/* name is for form 'Beethoven, Sr, Ludwig' */
				last_word = strrchr (author_str, ',');
				*last_word = 0;
				last_word += 1;
				while (*last_word == ' ') last_word += 1;
				middle_word = strrchr (author_str, ',');
				*middle_word = 0;
				middle_word += 1;
				while (*middle_word == ' ') middle_word += 1;
				if (strlen(last_word) > 0 || strlen(author_str) > 0 || strlen(middle_word) > 0) {
					names = add_parsed_name (names, last_word, "", author_str, middle_word);
				}
				break;
		}
		if (next_name == NULL) break; /* no more names */
		while (*next_name == ' ') next_name += 1;
		/* if there's another name, must be joined by 'and' */
		if (strlen (next_name) > 4 && next_name[0] == 'a' &&
			next_name[1] == 'n' && next_name[2] == 'd' &&
			next_name[3] == ' ') {
			author_str = next_name + 4;
		} else {
			author_str = next_name;
		}
	} while (strcmp (author_str, "") != 0);

	return names;
}

/* Create an (author, year) style of citation for record.
   Uses names in 'author' field if available, else uses
   those in the 'editor' field.
 */
char * record_citation (struct record * rec) {
	char * str;
	char * year;
	int str_size;
	int number_names;
	struct name * next_name;

	/* ensure the names are parsed */
	if (rec->rd->parsed_names == NULL) {
		rec->rd->parsed_names = parse_names (rec->rd->parsed_names, get_value_for (rec, "author"));
	}
	if (rec->rd->parsed_editors == NULL) {
		rec->rd->parsed_editors = parse_names (rec->rd->parsed_editors, get_value_for (rec, "editor"));
	}

	/* compute size of string */
	str_size = 3; /* for brackets and closing 0 */
	str_size += 6; /* for year, comma and space */
	/* -- look at all the parsed names, and also make a count */
	number_names = 0;
	next_name = rec->rd->parsed_names;
	if (next_name == NULL) next_name = rec->rd->parsed_editors;

	while (next_name != NULL) { /* TODO von_part */
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

	sprintf (str, "(");

	/* -- loop through names, adding them to str */
	next_name = rec->rd->parsed_names;
	if (next_name == NULL) next_name = rec->rd->parsed_editors;
	while (next_name != NULL) {
		strcat (str, next_name->last_name);
		if (strcmp ("", next_name->jr_part) != 0) {
			strcat (str, " ");
			strcat (str, next_name->jr_part);
		}
		number_names -= 1;
		 if (number_names == 1) {
			strcat (str, " and ");
		} else {
			strcat (str, ", ");
		}
		next_name = next_name->next;
	}

	year = get_value_for (rec, "year");
	if (year == NULL) {
		strcat (str, "n.d.");
	} else {
		strcat (str, year);
	}
	strcat (str, ")");

	return str;
}

/* Create Harvard style list of names for record */
char * record_harvard_name (struct record * rec) {
	char * author;

	/* ensure the names are parsed */
	if (rec->rd->parsed_names == NULL) {
		rec->rd->parsed_names = parse_names (rec->rd->parsed_names, get_value_for (rec, "author"));
	}
	if (rec->rd->parsed_editors == NULL) {
		rec->rd->parsed_editors = parse_names (rec->rd->parsed_editors, get_value_for (rec, "editor"));
	}

	if (rec->rd->parsed_names != NULL) {
		author = harvard_names (rec->rd->parsed_names);
	} else {
		author = harvard_names (rec->rd->parsed_editors);
	}

	return author;
}

/* Create a Harvard style reference for record */
char * record_harvard (struct record * rec) {
	char * str;
	int str_size;
	char * year;
	char * body;
	char * author;

	author = record_harvard_name (rec);
	body = harvard_body (rec);

	/* compute size of string */
	str_size = 3; /* for brackets and closing 0 */
	str_size += 8; /* for year, comma, space and fullstop */
	str_size += strlen (author) + 1;
	str_size += strlen (body);

	/* create string */
	str = malloc (sizeof(char) * str_size);

	sprintf (str, "");

	strcat (str, author);
	strcat (str, " (");
	year = get_value_for (rec, "year");
	if (year == NULL) {
		strcat (str, "n.d.");
	} else {
		strcat (str, year);
	}
	strcat (str, "). ");
	strcat (str, body);

	free (body);
	return str;
}

/* Create an IEEE style reference for record */
char * record_ieee (struct record * rec) {
	char * str;
	int str_size;
	char * year;
	char * body;
	char * author;

	/* ensure the names are parsed */
	if (rec->rd->parsed_names == NULL) {
		rec->rd->parsed_names = parse_names (rec->rd->parsed_names, get_value_for (rec, "author"));
	}
	if (rec->rd->parsed_editors == NULL) {
		rec->rd->parsed_editors = parse_names (rec->rd->parsed_editors, get_value_for (rec, "editor"));
	}

	if (rec->rd->parsed_names != NULL) {
		author = ieee_names (rec->rd->parsed_names);
	} else {
		author = ieee_names (rec->rd->parsed_editors);
	}
	body = ieee_body (rec);

	/* compute size of string */
	str_size = 1; /* closing 0 */
	str_size += 7; /* for year, comma and space */
	str_size += strlen (author) + 2;
	str_size += strlen (body);

	/* create string */
	str = malloc (sizeof(char) * str_size);

	sprintf (str, "");

	strcat (str, author);
	strcat (str, ", ");
	strcat (str, body);
	strcat (str, ", ");
	year = get_value_for (rec, "year");
	if (year == NULL) {
		strcat (str, "n.d.");
	} else {
		strcat (str, year);
	}

	free (body);
	return str;
}

