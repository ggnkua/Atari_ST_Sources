#include "harvard.h"

char * harvard_body_article (struct record * rec) {
	char * res;
	int res_size = 1;
	char * title = get_value_for (rec, "title");
	char * journal = get_value_for (rec, "journal");
	char * volume = get_value_for (rec, "volume");
	char * pages = get_value_for (rec, "pages");

	if (title != NULL) res_size += strlen(title) + 2;
	if (journal != NULL) res_size += strlen(journal) + 2;
	if (volume != NULL) res_size += strlen(volume);
	if (pages != NULL) res_size += strlen(pages) + 3;

	res = malloc (sizeof(char) * (res_size+1));
	strcpy (res, "");

	if (title != NULL) {
		strcat (res, title);
		strcat (res, ", ");
	}
	if (journal != NULL) {
		strcat (res, journal);
		strcat (res, ", ");
	}
	if (volume != NULL) {
		strcat (res, volume);
	}
	if (pages != NULL) {
		if (volume == NULL) {
			strcat (res, "pp.");
		} else {
			strcat (res, ":");
		}
		strcat (res, pages);
	}

	free (title);
	free (journal);
	free (volume);
	free (pages);
	return res;
}

char * harvard_body_book (struct record * rec) {
	char * res = "";
	int res_size = 1;
	char * title = get_value_for (rec, "title");
	char * publisher = get_value_for (rec, "publisher");
	char * address = get_value_for (rec, "address");

	if (title != NULL) res_size += strlen(title) + 2;
	if (publisher != NULL) res_size += strlen(publisher) + 2;
	if (address != NULL) res_size += strlen(address) + 2;

	res = malloc (sizeof(char) * (res_size+1));
	strcpy (res, "");

	if (title != NULL) {
		strcat (res, title);
		strcat (res, ". ");
	}
	if (publisher != NULL && address != NULL) {
		strcat (res, "(");
		strcat (res, address);
		strcat (res, ": ");
		strcat (res, publisher);
		strcat (res, ")");
	} else if (publisher != NULL) {
		strcat (res, "(");
		strcat (res, publisher);
		strcat (res, ")");
	} else if (address != NULL) {
		strcat (res, "(");
		strcat (res, address);
		strcat (res, ")");
	}

	free (title);
	free (publisher);
	free (address);
	return res;
}

char * harvard_body_collection (struct record * rec) {
	char * res = "";
	int res_size = 1;
	char * title = get_value_for (rec, "title");
	char * publisher = get_value_for (rec, "publisher");
	char * address = get_value_for (rec, "address");
	char * editor = get_value_for (rec, "editor");
	char * booktitle = get_value_for (rec, "booktitle");
	char * volume = get_value_for (rec, "volume");
	char * pages = get_value_for (rec, "pages");
	char * editor_str;

	if (title != NULL) res_size += strlen(title) + 2;
	if (publisher != NULL) res_size += strlen(publisher) + 2;
	if (address != NULL) res_size += strlen(address) + 2;
	if (booktitle != NULL) res_size += strlen(booktitle) + 4;
	if (volume != NULL) res_size += strlen(volume) + 2;
	if (pages != NULL) res_size += strlen(pages) + 3;
	if (editor != NULL) {
		editor_str = harvard_names (rec->rd->parsed_editors);
		res_size += strlen(editor_str) + 8;
	}

	res = malloc (sizeof(char) * (res_size+1));
	strcpy (res, "");

	if (title != NULL) {
		strcat (res, title);
		strcat (res, ". ");
	}
	strcat (res, "In ");
	if (editor != NULL) {
		strcat (res, editor_str);
		strcat (res, " (Eds.), ");
	}
	if (booktitle != NULL) {
		strcat (res, booktitle);
		if (publisher != NULL || address != NULL || volume != NULL || pages != NULL) {
			strcat (res, ", ");
		}
	}
	if (publisher != NULL && address != NULL) {
		strcat (res, "(");
		strcat (res, address);
		strcat (res, ": ");
		strcat (res, publisher);
		strcat (res, ")");
	} else if (publisher != NULL) {
		strcat (res, "(");
		strcat (res, publisher);
		strcat (res, ")");
	} else if (address != NULL) {
		strcat (res, "(");
		strcat (res, address);
		strcat (res, ")");
	}
	if (volume != NULL) {
		if (publisher != NULL || address != NULL) {
			strcat (res, " ");
		}
		strcat (res, volume);
		if (pages != NULL) {
			strcat (res, ", ");
		}
	}
	if (pages != NULL) {
		strcat (res, "pp.");
		strcat (res, pages);
	}

	free (title);
	free (publisher);
	free (address);
	free (editor);
	free (booktitle);
	free (volume);
	free (pages);
	return res;
}

char * harvard_body_misc (struct record * rec) {
	char * res = "";
	int res_size = 1;
	char * title = get_value_for (rec, "title");
	char * publisher = get_value_for (rec, "publisher");
	char * address = get_value_for (rec, "address");
	char * howpub = get_value_for (rec, "howpublished");
	char * url = get_value_for (rec, "url");
	char * note = get_value_for (rec, "note");

	if (title != NULL) res_size += strlen(title) + 2;
	if (publisher != NULL) res_size += strlen(publisher) + 2;
	if (address != NULL) res_size += strlen(address) + 2;
	if (howpub != NULL) res_size += strlen(howpub) + 2;
	if (url != NULL) res_size += strlen(url) + 2;
	if (note != NULL) res_size += strlen(note) + 2;

	res = malloc (sizeof(char) * (res_size+1));
	strcpy (res, "");

	if (title != NULL) {
		strcat (res, title);
		strcat (res, ". ");
	}
	if (howpub != NULL) {
		strcat (res, howpub);
		if (url != NULL || note != NULL) {
			strcat (res, ", ");
		}
	}
	if (url != NULL) {
		strcat (res, url);
		if (note != NULL) {
			strcat (res, ", ");
		}
	}
	if (note != NULL) {
		strcat (res, note);
	}
	if (howpub != NULL || url != NULL || note != NULL) {
		strcat (res, " ");
	}
	if (publisher != NULL && address != NULL) {
		strcat (res, "(");
		strcat (res, address);
		strcat (res, ": ");
		strcat (res, publisher);
		strcat (res, ")");
	} else if (publisher != NULL) {
		strcat (res, "(");
		strcat (res, publisher);
		strcat (res, ")");
	} else if (address != NULL) {
		strcat (res, "(");
		strcat (res, address);
		strcat (res, ")");
	}

	free (title);
	free (publisher);
	free (address);
	free (howpub);
	free (url);
	free (note);
	return res;
}

char * harvard_body (struct record * rec) {
	if (strcmp (rec->rd->type, "article") == 0) {
		return harvard_body_article (rec);
	}
	if (strcmp (rec->rd->type, "book") == 0) {
		return harvard_body_book (rec);
	}
	if (strcmp (rec->rd->type, "incollection") == 0 ||
		strcmp (rec->rd->type, "inproceedings") == 0) {
		return harvard_body_collection (rec);
	}
	if (strcmp (rec->rd->type, "misc") == 0) {
		return harvard_body_misc (rec);
	}
	return "unknown record type";
}


/* Create a Harvard style string for given author/editor names */
char * harvard_names (struct name * names) {
	char * str;
	int str_size;
	int number_names;
	struct name * next_name;

	/* -- look at all the parsed names, and also make a count */
	number_names = 0;
	next_name = names;
	while (next_name != NULL) { /* TODO von_part */
		str_size += strlen(next_name->first_name) + 2; /* 2 for comma and space */
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
		strcat (str, next_name->last_name);
		if (strcmp ("", next_name->jr_part) != 0) {
			strcat (str, " ");
			strcat (str, next_name->jr_part);
		}
		strcat (str, ", ");
		strcat (str, next_name->first_name);
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
