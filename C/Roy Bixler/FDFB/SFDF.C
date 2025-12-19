/*
 * sfdf.c
 *
 * find duplicates.  searches a given path and its sub-directories for
 * duplicate files.  Duplicate files have the same name, size, date and
 * contents.  However, the definition used by this program can be any
 * user-specified combination of the above.
 *
 * Roy Bixler (original development and Atari ST version)
 * Ayman Barakat (idea)
 * David Oertel (MS-DOS version)
 *
 * Version 1.0: March 11, 1991
 * Version 1.01: April 12, 1992
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
#include "sfdf.h"



/*
 * print_help
 *
 * prints out the help message for the program
 */
void print_help()

{
	printf(SFDF_USAGE, PROG_NAME, PROG_NAME);
}



/*
 * show_doc
 *
 * show full documentation
 */
void show_doc()

{
	printf(SFDF_SCHPIEL1);
	printf(SFDF_SCHPIEL2);
}



/*
 * sort_eq_match
 *
 * returns non-zero if the sort criteria is also one of the match criteria.
 */
int sort_eq_match()

{
	return (((Sort_criteria & NAME_SORT) && (Match_criteria & NAMES_MATCH)) ||
			((Sort_criteria & SIZE_SORT) && (Match_criteria & SIZES_MATCH)) ||
			((Sort_criteria & TIME_SORT) && (Match_criteria & TIMES_MATCH)));
}



/*
 * print_dups
 *
 * given a pointer to a name which has been determined to be duplicated, print
 * all the names and their path's out.  Return where a mismatch is found.
 */
void print_dups(FILE_LIST *start)

{
	int n_found = 0;
	long n_bytes = 0L;
	FILE_LIST *cur;

	for (cur = start->next;
		 ((cur != NULL) && ((!sort_eq_match()) || (cmpflist_eq(start, cur))));
		 cur = cur->next)
		if ((!cur->printed) && (files_match(start, cur))) {
			if (!n_found++) {
				n_found++;
				if (v_flag)
					n_bytes += start->dta.dta_size;
				print_match_header(start);
				print_next_match(start, -1);
			}
			if (v_flag)
				n_bytes += cur->dta.dta_size;
			print_next_match(cur, -1);
		}

	if (n_found) {
		if (v_flag) {
			update_num_dups(n_found, n_bytes);
			update_num_which_dupd();
		}
		printf("\n");
	}
}



/*
 * gen_id_menu
 *
 * given a starting point in the file list, generate an interactive delete
 * menu.  Return number of items put into the menu.
 */
int gen_id_menu(FILE_LIST *start, FILE_LIST **menu, int max_items)

{
	int n_found = 0;
	long n_bytes = 0L;
	FILE_LIST *cur;

	for (cur = start->next;
		 ((cur != NULL) && (cmpflist_eq(start, cur)) && (n_found < max_items));
		 cur = cur->next)
		if ((!cur->printed) && (files_match(start, cur))) {
			if (n_found == 0) {
				if (v_flag)
					n_bytes += start->dta.dta_size;
				menu[n_found++] = start;
			}
			if (v_flag)
				n_bytes += cur->dta.dta_size;
			menu[n_found++] = cur;
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
void id_dups(FILE_LIST *start)

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
 * find_non_printed
 *
 * given a pointer to a FILE_LIST, return the pointer to the next element which
 * has not been printed yet.
 */
FILE_LIST *find_non_printed(FILE_LIST *file)

{
	for (; ((file != NULL) && (file->printed)); file = file->next);
	return file;
}



/*
 * find_dups
 *
 * given a path, find the duplicate files and dump them to the standard output.
 */
void find_dups()

{
	FILE_LIST *f_found;

	for (f_found = F_list; (f_found != NULL);
		 f_found = find_non_printed(f_found->next))
		if (i_flag)
			id_dups(f_found);
		else
			print_dups(f_found);
}



/*
 * count_total_stats
 *
 * go back over the linked list and count the number of files and the total
 * bytes in the files
 */
void count_total_stats()

{
	FILE_LIST *cur;

	for (cur = F_list; cur != NULL; cur = cur->next) {
		update_num_files();
		update_total_bytes(cur->dta.dta_size);
	}
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
		case 'o':
			if ((optarg == NULL) || (strpbrk(optarg, "AaDd") != optarg)) {
				printf("%s: must specify 'a' or 'd' after -o\n", PROG_NAME);
				print_help();
				exit(-1);
			}
			if (isupper(*optarg))
				*optarg = tolower(*optarg);
			if (*optarg == 'a')
				Sort_order = ASCENDING;
			else if (*optarg == 'd')
				Sort_order = DESCENDING;
			break;
		case 's':
			if ((optarg == NULL) || (strpbrk(optarg, "DdNnSs") != optarg)) {
				printf("%s: must specify 'd', 'n' or 's' after -s\n",
					   PROG_NAME);
				print_help();
				exit(-1);
			}
			if (isupper(*optarg))
				*optarg = tolower(*optarg);
			switch (*optarg) {
			case 'd':
				Sort_criteria = TIME_SORT;
				break;
			case 'n':
				Sort_criteria = NAME_SORT;
				break;
			case 's':
				Sort_criteria = SIZE_SORT;
				break;
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
	if (!Sort_criteria)
		Sort_criteria = NAME_SORT;

	return Optind;
}



int main(int argc, char **argv)

{
	int i;
	char form_path[MAXPATHLEN];

	for (i = get_options(argc, argv); i < argc; i++) {
		format_dir(argv[i], '\0', form_path);
		if (v_flag > 1)
			printf("finding duplicates under %s:\n\n", form_path);
		list_files(PROG_NAME, form_path, (char) 1);
	}

	find_dups();
	if (v_flag) {
		count_total_stats();
		print_stats();
	}

	exit(0);
}
