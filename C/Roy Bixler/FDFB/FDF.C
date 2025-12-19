/*
 * fdf.c
 *
 * find duplicates.  searches a given path and its sub-directories for
 * duplicate files.  Duplicate files have the same name, size, date and
 * contents.  However, the definition used by this program can be almost any
 * user-specified combination of the above.
 *
 * Roy Bixler (original development and Atari ST version, maintenance)
 * Ayman Barakat (idea)
 * David Oertel (MS-DOS version)
 *
 * Version 1.0: March 11, 1991 (known as 'mfd - Monk find duplicates')
 * Version 1.01: April 12, 1992 (now 'fdf - find duplicate files')
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 1, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


#include <ctype.h>
#include <osbind.h>
#include <param.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "fdfcomm.h"
#include "fdfstat.h"
#include "elib.h"
#include "fdf.h"


HASH_LIST *H_list[HASH_TAB_SIZE];



/*
 * print_help
 *
 * prints out the help message for the program
 */
void print_help()

{
	printf(FDF_USAGE, PROG_NAME, PROG_NAME);
}



/*
 * show_doc
 *
 * show full documentation
 */
void show_doc()

{
	printf(FDF_SCHPIEL);
}



/*
 * add_to_hash_table
 *
 * given a file and a hash table index, add the given file to the hash table
 * at the given index.  Addition is done by putting the new entry at the
 * head of a linked list.
 */
void add_to_hash_table(FILE_LIST *f_name, int h_idx)

{
	HASH_LIST *new_entry = malloc((size_t) sizeof(HASH_LIST));

	if (new_entry != NULL) {
		new_entry->f_name = f_name;
		new_entry->f_name->printed = 0;
		new_entry->next = H_list[h_idx];
		H_list[h_idx] = new_entry;
	}
}


/*
 * gen_hash
 *
 * given a linked list repesenting a list of files, generate a hash table for
 * it.
 */
void gen_hash(FILE_LIST *flist)

{
	for (;flist != NULL; flist = flist->next) {
		if (!flist->added) {
			if (v_flag) {
				update_total_bytes(flist->dta.dta_size);
				update_num_files();
			}
			if ((Match_criteria) & (NAMES_MATCH))
				add_to_hash_table(flist, hashpjw(flist->dta.dta_name));
			else if ((Match_criteria) & (SIZES_MATCH))
				add_to_hash_table(flist, flist->dta.dta_size % HASH_TAB_SIZE);
			else if ((Match_criteria) & (TIMES_MATCH))
				add_to_hash_table(flist,
								  ((((unsigned long)
									 (flist->dta.dta_date)) << 16) +
								   (unsigned long) (flist->dta.dta_time)) %
								  HASH_TAB_SIZE);
			flist->added = 1;
		}
	}
}



/*
 * find_duplicated_name
 *
 * scans the generated hash table for names which occur twice (or more).
 * Takes a pointer to hash table index to start the search at, modifies this
 * on return to indicate where it stopped looking (either because of end of
 * hash table or because a duplicated name found).  Return pointer to first
 * occurrence of duplicated name found or NULL if none found.
 */
HASH_LIST *find_duplicated_name(int *h_idx, HASH_LIST *last_found)

{
	int i;
	HASH_LIST *anchor, *cur;

	anchor = last_found;
	for (i = *h_idx; i < HASH_TAB_SIZE; i++)
		if (H_list[i] != NULL) {
			if (anchor == NULL)
				anchor = H_list[i];
			for (; anchor != NULL; anchor = anchor->next)
				if (!anchor->f_name->printed)
					for (cur = anchor->next; cur != NULL; cur = cur->next)
						if ((!cur->f_name->printed) &&
							(cmpflist_eq(anchor->f_name, cur->f_name))) {
							*h_idx = i;
							return anchor;
						}
		}

	*h_idx = i;
	return NULL;
}



/*
 * gen_id_menu
 *
 * given a starting point in the file list, generate an interactive delete
 * menu.  Return number of items put into the menu.
 */
int gen_id_menu(HASH_LIST *name_duped, FILE_LIST **menu, int max_items)

{
	int n_found = 0;
	long n_bytes = 0L;
	HASH_LIST *cur;

	for (cur = name_duped->next;
		 ((cur != NULL) && (n_found < max_items));
		 cur = cur->next)
		if ((!cur->f_name->printed) &&
			(files_match(name_duped->f_name, cur->f_name))) {
			if (n_found == 0) {
				if (v_flag)
					n_bytes += name_duped->f_name->dta.dta_size;
				menu[n_found++] = name_duped->f_name;
			}
			if (v_flag)
				n_bytes += cur->f_name->dta.dta_size;
			menu[n_found++] = cur->f_name;
		}

	if ((n_found) && (v_flag)) {
		update_num_which_dupd();
		update_num_dups(n_found, n_bytes);
	}

	return n_found;
}



/*
 * id_dups
 *
 * given a pointer to a name which has been determined to be duplicated, print
 * all the names and their path's out and ask the user which ones to delete.
 */
void id_dups(HASH_LIST *start)

{
	int n_found, i, n_del;
	FILE_LIST *cur, *menu[N_INTERACTIVE];
	char menu_sel[MAX_STR], which_del[N_INTERACTIVE];

	if (!(n_found = gen_id_menu(start, menu, N_INTERACTIVE)))
		return;
	while (1) {
		print_id_menu(menu, n_found);
		printf("\nEnter list of files to delete (hit CR for none)\n");
		fgets(menu_sel, MAX_STR-1, stdin);
		zap_trailing_nl(menu_sel, MAX_STR-1, stdin);
		if (!mark_list(menu_sel, which_del, n_found)) {
			for (n_del=0, i=0; i < n_found; i++)
				if (which_del[i])
					if (!delete_path_name_file(menu[i]->path,
											   menu[i]->dta.dta_name, '\0')) {
						n_del++;
						if (v_flag) {
							update_total_del_bytes(menu[i]->dta.dta_size);
							if (v_flag > 1) {
								printf("Deleted ");
								print_fpath(menu[i]->path,
											menu[i]->dta.dta_name);
								printf("\n");
							}
						}
					}
			break;
		}
	} 

	if (n_del)
		printf("\n");
}



/*
 * print_dups
 *
 * given a pointer to a name which has been determined to be duplicated, print
 * all the names and their path's out.
 */
void print_dups(HASH_LIST *name_duped)	/* now, who's being duped here? */

{
	HASH_LIST *cur;

	for (cur = name_duped->next; cur != NULL; cur = cur->next)
		if ((!cur->f_name->printed) &&
			(files_match(name_duped->f_name, cur->f_name))) {
			if (!name_duped->f_name->printed) {
				if (v_flag) {
					update_num_which_dupd();
					update_num_dups(1U, name_duped->f_name->dta.dta_size);
				}
				print_match_header(name_duped->f_name);
				print_next_match(name_duped->f_name, -1);
			}
			if (v_flag)
				update_num_dups(1U, cur->f_name->dta.dta_size);
			print_next_match(cur->f_name, -1);
		}

	if (name_duped->f_name->printed)
		printf("\n");
}



/*
 * find_non_printed
 *
 * given a pointer to a FILE_LIST, return the pointer to the next element which
 * has not been printed yet.
 */
HASH_LIST *find_non_printed(HASH_LIST *file)

{
	for (; ((file != NULL) && (file->f_name->printed)); file = file->next);
	return file;
}



/*
 * find_dups
 *
 * given a path, find the duplicate files and dump them to the standard output.
 */
void find_dups()

{
	HASH_LIST *last_found, *f_found;
	int i;

	gen_hash(F_list);
	i = 0;
	last_found = NULL;
	while ((i < HASH_TAB_SIZE) &&
		   ((f_found = find_duplicated_name(&i, last_found)) != NULL)) {
		if (i_flag)
			id_dups(f_found);
		else
			print_dups(f_found);
		last_found = find_non_printed(f_found->next);
	}
}



/*
 * init_hash
 *
 * insure the hash table is empty
 */
void init_hash()

{
	int i;

	for (i=0; i<HASH_TAB_SIZE; i++)
		H_list[i] = NULL;
}



/*
 * set_sort_hash_criteria
 *
 * must guarantee that no matter what the matching criteria is, that
 * duplicate files will always go to the same hash table location.
 *
 * This is called to make sure that, when comparing two entries in the same
 * hash table bucket (i.e when calling 'cmpflist_eq()'), appropriate criteria
 * are used to determine if the two entries can possibly match.  There is no
 * real sorting with the hash table!
 */
void set_sort_hash_criteria()

{
	if ((Match_criteria) & (NAMES_MATCH))
		Sort_criteria = NAME_SORT;
	else if ((Match_criteria) & (SIZES_MATCH))
		Sort_criteria = SIZE_SORT;
	else if ((Match_criteria) & (TIMES_MATCH))
		Sort_criteria = TIME_SORT;
}



/*
 * get_options
 *
 * get the command-line options, check for consistency and set the appropriate
 * variables.
 */
int get_options(int argc, char **argv)

{
	extern int getopt(int argc, char **argv, char *opts);
	extern int Optind;
	extern char *optarg;
	int optchar;
	char a_flag = 0, c_flag = 0, d_flag = 0, n_flag = 0, s_flag = 0;

	if (argc < 2) {
		print_help();
		exit(-1);
	}

	while ((optchar = getopt(argc, argv, GETOPT_LIST)) != EOF) {
		if (isupper(optchar))
			optchar = tolower(optchar);
		switch (optchar) {
		case 'i':
			i_flag = 1;
			break;
		case 'l':
			l_flag = 1;
			break;
		case 'm':
			if ((optarg == NULL) || (strpbrk(optarg, "AaCcDdNnSs") != optarg)) {
				printf("%s: must specify 'a' or 'c', 'd', 'n' and/or 's' after -m\n", 
					   PROG_NAME);
				print_help();
				exit(-1);
			}
			for (;*optarg != '\0'; optarg++) {
				if (isupper(*optarg))
					*optarg = tolower(*optarg);
				switch (*optarg) {
				case 'a':
					a_flag = 1;
					break;
				case 'c':
					c_flag = 1;
					Match_criteria |= CONTENTS_MATCH;
					break;
				case 'd':
					d_flag = 1;
					Match_criteria |= TIMES_MATCH;
					break;
				case 'n':
					n_flag = 1;
					Match_criteria |= NAMES_MATCH;
					break;
				case 's':
					s_flag = 1;
					Match_criteria |= SIZES_MATCH;
					break;
				default:
					printf("%s: invalid match criteria '%c' specified\n", 
						   PROG_NAME, *optarg);
					print_help();
					exit(-1);
				}
			}
			break;
		case 'v':
			v_flag++;
			break;
		case '?':
			show_doc();
			exit(0);
		default:
			print_help();
			exit(-1);
		}
	}

	if (argc == Optind) {
		printf("%s: at least one path specification required\n", PROG_NAME);
		print_help();
		exit(-1);
	}
	else if (a_flag)
		if ((c_flag) || (d_flag) || (n_flag) || (s_flag)) {
			printf("%s: -ma option conflicts with -mc, -md, -mn or -ms\n",
				   PROG_NAME);
			print_help();
			exit(-1);
		}
		else
			Match_criteria = ALL_MATCH;
	else if (!Match_criteria)
		Match_criteria = (TIMES_MATCH|SIZES_MATCH|NAMES_MATCH);
	else if (Match_criteria & CONTENTS_MATCH)
		Match_criteria |= SIZES_MATCH;
	set_sort_hash_criteria();

	return Optind;
}



int main(int argc, char **argv)

{
	int i;
	char form_path[MAXPATHLEN];

	init_hash();
	for (i = get_options(argc, argv); i < argc; i++) {
		format_dir(argv[i], '\0', form_path);
		if (v_flag > 1)
			printf("finding duplicates under %s:\n\n", form_path);
		list_files(PROG_NAME, form_path, (char) 0);
	}

	find_dups();
	if (v_flag)
		print_stats();

	exit(0);
}
