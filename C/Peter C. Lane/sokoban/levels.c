#include "levels.h"

#include <ctype.h>

/* Line is a valid problem definition if its first non-space character
   is a wall, or a box on a goal state.  Otherwise, treat as blank.
 */
bool is_blankline (char s[], int len) {
	int i;

	for (i = 0; s[i] != 0 && i < len; i += 1) {
		if (isspace(s[i])) {
			; /* continue looking, if space */
		} else if (s[i] == '#' || s[i] == '*') {
			return false; /* is a wall or box-on-goal, so part of definition */
		} else {
			return true; /* anything else, treat as blank */
		}
	}

	return true;
}

struct level_data * leveldata_create (void) {
	struct level_data * ld = malloc (sizeof(struct level_data));

	ld->size = 0;
	ld->levels = NULL;

	return ld;
}

void leveldata_free (struct level_data * ld) {
	leveldata_clear (ld);
	free (ld);
}

/* Remove all levels in level_data */
void leveldata_clear (struct level_data * ld) {
	struct level * l;

	ld->size = 0;
	l = ld->levels;
	ld->levels = NULL;

	while (l != NULL) {
		struct level * m = l->next;
		free (l->title);
		free (l->definition);
		free (l);
		l = m;
	}
}

/* Replace levels in level_data with levels from given file.
   Return -1 if there is a problem, 0 if all ok.
   Note: clears out all levels in ld.
   win_handle is used to output progress to INFO line.
 */
int leveldata_load (struct level_data * ld, char * title, char * filename, int win_handle) {
	FILE * fp;
	char str[250]; /* long enough for a long file name */
	char * definition;
	char * new_defn;
	int definition_size = 10;

	leveldata_clear (ld);
	ld->title = strdup (title);

	fp = fopen(filename, "r");
	if (fp ==  NULL) return -1;

	wind_set (win_handle, WF_INFO, "Loading levels ...", 0, 0);
	definition = malloc (sizeof(char) * definition_size);

	do {
		char s[MAXLINE];
		int len;

		/* skip blank lines */
		do {
			len = getline (fp, s, MAXLINE, true);
		} while (is_blankline (s, len) && !feof(fp));

		if (feof(fp)) break;

		/* expand size of definition, if needed */
		if (len > definition_size) {
			definition_size = len * 2;
			definition = malloc(sizeof(char)*(definition_size+1));
		}
		definition[0] = '\0';

		if (!is_blankline (s, len)) {
			strcpy (definition, s); /* clear previous definition */
		}

		/* read until blank lines */
	 	while (!feof(fp)) {
			len = getline (fp, s, MAXLINE, true);
			if (is_blankline (s, len)) break;

			/* expand size of definition, if needed */
			if ((strlen(s) + strlen(definition)) > definition_size) {
				definition_size = (strlen(s) + strlen(definition)) * 2;
				new_defn = malloc(sizeof(char)*(definition_size+1));
				strcpy (new_defn, definition);
				free (definition);
				definition = new_defn;
			}
			/* attach new string to definition */
			strcat (definition, s);
		}

		/* add it in */
		if (strlen (definition) > 0) {
			sprintf (str, "%s %d", title, ld->size+1);
			leveldata_add_level (ld, strdup(str), strdup(definition));
			sprintf (str, "Read %d levels", ld->size);
			wind_set (win_handle, WF_INFO, strdup(str), 0, 0);
		}
	} while (!feof(fp));

	fclose (fp);

	return 0;
}

/* Replace levels in level_data with the builtin levels. */
int leveldata_classic (struct level_data * ld) {
	char str[30];
	int i;

	leveldata_clear (ld);
	ld->title = "Classic";
	i = 0;

	while (classic_levels[i] != NULL) {
		sprintf (str, "%s %d", ld->title, i+1);
		leveldata_add_level (ld, strdup(str), strdup(classic_levels[i]));
		i += 1;
	}

	return 0;
}

/* Add given level to end of level list */
void leveldata_add_level (struct level_data * ld, char * title, char * definition) {
	struct level * l = malloc(sizeof(struct level));
	l->title = title;
	l->definition = definition;
	l->next = NULL;

	if (ld->levels == NULL) {
		ld->levels = l;
	} else { /* find the last level, and add l to it */
		struct level * end = ld->levels;

		while (end->next != NULL) {
			end = end->next;
		}
		end->next = l;
	}
	ld->size += 1;
}

/* Retrieve the nth level from level list, counting from 0 */
struct level * leveldata_nth (struct level_data * ld, int n) {
	struct level * l = ld->levels;

	while (n != 0 && l != NULL) {
		l = l->next;
		n -= 1;
	}

	return l;
}
