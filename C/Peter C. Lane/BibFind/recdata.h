#if !defined(RECDATA_H)
#define RECDATA_H

#include "record.h"

/* A structure to hold information about the records,
   the list of found records, the currently displayed record, etc.
 */
struct rec_data {
	struct record * all;    /* holds pointer to start of complete set of records */
	struct record * found;  /* holds pointer to start of list of records matching last search */
	struct record * current; /* holds pointer to currently displayed record */
	int index;              /* index of current record in found list */
	int total;              /* total number of records in found list */
};

struct rec_data * recdata_create (void);
void recdata_find (struct rec_data * rd, char * search_terms);
int recdata_next (struct rec_data * rd);
int recdata_previous (struct rec_data * rd);
void recdata_clear_marks (struct rec_data * rd);
int recdata_num_marked (struct rec_data * rd);
void recdata_get_marked_records (struct rec_data * rd, struct record * marked_recs[]);

/* ***** Statistics rely on following structure: string->count ***** */

struct strcount {
	char * str;
	int count;
	struct strcount * next;
};

int strcount_size (struct strcount * sc);

struct strcount * recdata_statistics_by_type (struct rec_data * rd);
struct strcount * recdata_statistics_by_year (struct rec_data * rd);

#endif
