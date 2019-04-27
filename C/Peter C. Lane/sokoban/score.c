#include "score.h"

/* internal method to find store */
struct scores * find_level_set (struct scores * s, char * t) {
	while (s != NULL) {
		if (strcmp (s->name, t) == 0) { /* found the level set */
			return s;
		}
		s = s->next;
	}
	return NULL; /* failed to find set */
}


struct score_level * scorelevel_new (char * l, int num_moves, int num_pushes) {
	struct score_level * new_l = malloc (sizeof (struct score_level));

	new_l->name = strdup (l);
	new_l->num_moves = num_moves;
	new_l->num_pushes = num_pushes;

	new_l->next = NULL;

	return new_l;
}

/* Create a new instance of scores for given set */
struct scores * scores_new (char * t, int total_levels) {
	struct scores * s = malloc (sizeof (struct scores));

	s->name = strdup (t);
	s->total_levels = total_levels;
	s->levels = NULL;

	s->next = NULL;

	return s;
}

/* Locate and load file "scores.txt", or return NULL
   Note: this is not robust to errors
 */
struct scores * scores_from_file (void) {
	struct scores * score = NULL;
	FILE * fp;
	char s[MAXLINE];

	fp = fopen ("scores.txt", "r");
	if (fp != NULL) {
		do {
			getline (fp, s, MAXLINE, false);
			if (strcmp (s, "[") == 0) {
				char title[MAXLINE];
				char size[MAXLINE];

				getline (fp, title, MAXLINE, false);
				getline (fp, size, MAXLINE, false);

				if (score == NULL) {
					score = scores_new (title, atoi(size));
				} else {
					scores_store_set (score, title, atoi(size));
				}

				while (!feof(fp)) {
					char level[MAXLINE];
					char moves[MAXLINE];
					char pushes[MAXLINE];

					getline (fp, level, MAXLINE, false);
					if (strcmp (level, "]") == 0) break; /* found end of set */
					getline (fp, moves, MAXLINE, false);
					getline (fp, pushes, MAXLINE, false);
					scores_store (score, title, level, atoi(moves), atoi(pushes));
				}
			}
		} while (!feof(fp));

		fclose (fp);
	}

	return score;
}

/* Store score information in fixed file */
void scores_save_file (struct scores * s) {
	FILE * fp;

	fp = fopen ("scores.txt", "w");
	if (fp != NULL) {
		while (s != NULL) {
			struct score_level * cur = s->levels;

			fprintf (fp, "[\n");
			fprintf (fp, "%s\n", s->name);
			fprintf (fp, "%d\n", s->total_levels);
			while (cur != NULL) {
				fprintf (fp, "%s\n", cur->name);
				fprintf (fp, "%d\n", cur->num_moves);
				fprintf (fp, "%d\n", cur->num_pushes);

				cur = cur->next;
			}
			fprintf (fp, "]\n");

			s = s->next;
		}
		fclose (fp);
	}
}

/* Return the number of levels with a score in given set */
int scores_number_done (struct scores * s, char * t) {
	struct scores * set = find_level_set (s, t);
	int count = 0;

	if (set != NULL) {
		struct score_level * cur = set->levels;

		while (cur != NULL) {
			count += 1;
			cur = cur->next;
		}
	}

	return count;
}

/* Update or add new set of scores */
void scores_store_set (struct scores * s, char * t, int total_levels) {
	while (s != NULL) {
		if (strcmp (s->name, t) == 0) break; /* already in list */
		if (s->next == NULL) { /* reached end, so add a new set to list */
			s->next = scores_new (t, total_levels);
			break; /* and end loop after adding new set */
		}
		s = s->next;
	}
}

/* Update or add score for level l of set t */
void scores_store (struct scores * s, char * t, char * l, int num_moves, int num_pushes) {
	struct scores * set = find_level_set (s, t);
	struct score_level * cur;

	if (set == NULL) return; /* this is an error */

	cur = set->levels;

	/* Check if there are no entries so far */
	if (cur == NULL) {
		set->levels = scorelevel_new (l, num_moves, num_pushes);
	} else {
		/* try to find level in list to update its score */
		struct score_level * prev = NULL;

		while (cur != NULL) {
			if (strcmp (cur->name, l) == 0) { /* found the level */
				if (num_moves < cur->num_moves) cur->num_moves = num_moves;
				if (num_pushes < cur->num_pushes) cur->num_pushes = num_pushes;
				break;
			}

			prev = cur;
			cur = cur->next;
		}
		if (cur == NULL) { /* need to add level */
			prev->next = scorelevel_new (l, num_moves, num_pushes);
		}
	}
}

/* Return best number of moves and pushes for given level l of set t
   in reference parameters.  Returns false if could not find, true otherwise.
 */
bool scores_find (struct scores * s, char * t, char * l, int * num_moves, int * num_pushes) {
	struct scores * set = find_level_set (s, t);
	struct score_level * cur;

	if (set == NULL) return false; /* this is an error */

	cur = set->levels;

	/* Check if there are no entries so far */
	if (cur == NULL) {
		return false; /* could not find level set */
	} else {
		/* try to find level in list to update its score */
		while (cur != NULL) {
			if (strcmp (cur->name, l) == 0) { /* found the level */
				*num_moves = cur->num_moves;
				*num_pushes = cur->num_pushes;
				return true;
			}
			cur = cur->next;
		}
	}
	return false;
}

