#if !defined(SCORE_H)
#define SCORE_H

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "getline.h"

/* Scores are stored in a nested list structure:
   top level is indexed by name of levels (e.g. filename),
   and points to start of list of levels.
   List of levels contains name of level and best scores.
 */

struct score_level {
	char * name; /* name of level */
	int num_moves; /* best number of moves */
	int num_pushes; /* best number of pushes */

	struct score_level * next; /* pointer to next in list */
};

struct scores {
	char * name; /* name of set of levels */
	int total_levels; /* number of known levels in current set */
	struct score_level * levels; /* start of list of level scores */

	struct scores * next; /* pointer to next in list */
};

/* Create a new instance of scores for given set */
struct scores * scores_new (char * t, int total_levels);

/* Read score information from fixed file */
struct scores * scores_from_file (void);

/* Store score information in fixed file */
void scores_save_file (struct scores * s);

/* Return the number of levels with a score in given set */
int scores_number_done (struct scores * s, char * t);

/* Update or add new set of scores */
void scores_store_set (struct scores * s, char * t, int total_levels);

/* Update or add score for level l of set t */
void scores_store (struct scores * s, char * t, char * l, int num_moves, int num_pushes);

/* Return best number of moves and pushes for given level l of set t
   in reference parameters.  Returns 0 if could not find, 1 otherwise.
 */
bool scores_find (struct scores * s, char * t, char * l, int * num_moves, int * num_pushes);

#endif
