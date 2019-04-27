#include <stdio.h>
#include <stdlib.h>
#include "recdata.h"

/* set up the inital statistics for rd.
   current will point to start of currently displayed list. */
void recdata_initialise_stats (struct rec_data * rd) {
	if (rd->current == NULL) {
		rd->index = 0;
		rd->total = 0;
	} else {
		rd->index = 1;
		rd->total = count_records (rd->current);
	}
}

/* Read records from a file:
   -- currently assumes 'biblio.bib' is in current directory
   -- TODO: make this user definable somehow
   and sets up a new recdata instance.
   Returns NULL if failed to load records.
 */
struct rec_data * recdata_create (void) {
	FILE * fp;
	struct rec_data * rd = malloc (sizeof(struct recdata));

	fp = fopen("biblio.bib", "r");
	if (fp == NULL) { /* file not found */
		rd = NULL;
	} else {
		rd->all = read_records (fp);
		fclose (fp);

		rd->current = rd->all; /* current record is first of loaded records */
		rd->found = NULL; /* initial list of found records to NULL */
		recdata_initialise_stats (rd);
	}

	return rd;
}

/* Find records for given search terms, and update fields in rd */
void recdata_find (struct rec_data * rd, char * search_terms) {
	rd->found = find_records (rd->all, search_terms);
	rd->current = rd->found; /* current record is made first of found records */
	recdata_initialise_stats (rd);
}

/* Move to next record in found list.
   Return 1 if succeeds, or 0 if no next record. */
int recdata_next (struct rec_data * rd) {
	if (rd->current == NULL || rd->current->next == NULL) {
		return 0;
	} else {
		rd->current = rd->current->next;
		rd->index += 1;
	}
	return 1;
}

/* Move to previous record in found list.
   Return 1 if succeeds, or 0 if no next record. */
int recdata_previous (struct rec_data * rd) {
	if (rd->current == NULL || rd->current->prev == NULL) {
		return 0;
	} else {
		rd->current = rd->current->prev;
		rd->index -= 1;
	}
	return 1;
}

/* set all record marks to false */
void recdata_clear_marks (struct rec_data * rd) {
	struct record * cur = rd->all;

	while (cur != NULL) {
		cur->rd->marked = false;
		cur = cur->next;
	}
}

/* return a count of the number of marked records */
int recdata_num_marked (struct rec_data * rd) {
	int count = 0;
	struct record * cur = rd->all;

	while (cur != NULL) {
		if (cur->rd->marked) count += 1;
		cur = cur->next;
	}

	return count;
}

/* compare two given records, based on names in Harvard format */
int compare_records (const void * item1, const void * item2) {
	const struct record ** rec1 = item1; /* note qsort passes us pointers to our data type! */
	const struct record ** rec2 = item2;
	char * names1;
	char * names2;
	int result;

	names1 = record_harvard_name (*rec1);
	names2 = record_harvard_name (*rec2);

	result = strcmp (names1, names2);

	free (names1);
	free (names2);

	return result;
}

/* Place pointers to marked records in given array, and
   sort into alphabetical order of surname
 */
void recdata_get_marked_records (struct rec_data * rd, struct record * marked_recs[]) {
	struct record * cur = rd->all;
	int posn = 0;

	while (cur != NULL) {
		if (cur->rd->marked) {
			marked_recs[posn] = cur;
			posn += 1;
		}

		cur = cur->next;
	}

	/* Sort the records */
	qsort (marked_recs, posn, sizeof(struct record *),
			(int (*) ())compare_records);
}

struct strcount * make_strcount (void) {
	struct strcount * sc = malloc (sizeof(struct strcount));

	sc->str = NULL;
	sc->count = 0;
	sc->next = NULL;

	return sc;
}

void strcount_add_string (struct strcount * sc, char * str) {

	do {
		if (sc->str == NULL) { /* end of list, so add new entry */
			sc->str = str;
			sc->count = 1;
			sc->next = make_strcount ();
			return;
		} else if (strcmp (sc->str, str) == 0) { /* found it */
			sc->count += 1;
			return;
		} else  { /* check next item in list */
			sc = sc->next;
		}
	} while (sc != NULL);
}

/* Count the number of entries in given strcount */
int strcount_size (struct strcount * sc) {
	int count = 0;

	while (sc != NULL && sc->str != NULL) {
		count += 1;
		sc = sc->next;
	}

	return count;
}

/* Compute statistics on types of records in current list */
struct strcount * recdata_statistics_by_type (struct rec_data * rd) {
	struct strcount * sc = make_strcount ();
	int i;
	struct record * rec = (rd->found == NULL ? rd->all : rd->found);
	struct strcount * cur;

	/* work through all records, adding type to sc */
	while (rec != NULL) {
		strcount_add_string (sc, rec->rd->type);
		rec = rec->next;
	}

	return sc;
}

/* Compute statistics on years of records in current list */
struct strcount * recdata_statistics_by_year (struct rec_data * rd) {
	struct strcount * sc = make_strcount ();
	int i;
	struct record * rec = (rd->found == NULL ? rd->all : rd->found);
	struct strcount * cur;

	/* work through all records, adding type to sc */
	while (rec != NULL) {
		strcount_add_string (sc, get_value_for (rec, "year"));
		rec = rec->next;
	}

	return sc;
}

