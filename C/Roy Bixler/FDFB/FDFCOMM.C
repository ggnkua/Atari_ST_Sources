/*
 * fdfcomm.c
 *
 * common functions for find duplicates program
 *
 * Roy Bixler
 * March 23, 1991
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
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <osbind.h>
#include <types.h>	/* must be included before stat.h */
#include <stat.h>
#include <unistd.h>

#include "cmp.h"
#include "fdfcomm.h"
#include "elib.h"



FILE_LIST *F_list = NULL, *I_del_menu[N_INTERACTIVE];
char Match_criteria = 0, Sort_criteria = 0, Sort_order = ASCENDING;
char i_flag = 0;	/* interactive delete mode */
char l_flag = 0;	/* long listing? */
char v_flag = 0;	/* verbose? */
static char Sorted;



/*
 * print_fdate
 *
 * given a dta structure, print out the date in it
 */
void print_fdate(struct _dta *dta)

{
	printf("%02d/%02d/%02d",
		   (dta->dta_date >> 9) + 80,
		   (dta->dta_date >> 5) & 0xf,
		   (dta->dta_date) & 0x1f);
}



/*
 * print_ftime
 *
 * given a dta structure, print out the time in it
 */
void print_ftime(struct _dta *dta)

{
	printf("%02d:%02d:%02d",
		   (dta->dta_time >> 11),
		   (dta->dta_time >> 5) & 0x3f,
		   (dta->dta_time & 0x1f));
}



/*
 * print_fdatetime
 *
 * print the given dta's date, a space and the dta's time
 */
void print_fdatetime(struct _dta *dta)

{
	print_fdate(dta);
	printf(" ");
	print_ftime(dta);
}



/*
 * print_fpath
 *
 * given a path and a dta, print the path with the dta's name tacked on the
 * end
 */
void print_fpath(char *path, char *f_name)

{
	static char *dir_sep = PATH_SEPARATOR;
	int path_len;

	if (path != NULL) {
		path_len = strlen(path);
		printf("%s%s%s", path,
			   ((path_len > 0) && (path[path_len-1] == dir_sep[0]))
				? ""
				: PATH_SEPARATOR,
			   f_name);
	}
}



/*
 * long_listing
 *
 * print out the complete information on the given file
 */
void long_listing(char *path, struct _dta *dta)

{
	if (path != NULL) {
		printf("%c ", (dta->dta_attribute == 0x10) ? 'd' : '-');
		print_fdatetime(dta);
		printf(" %8ld ", dta->dta_size);
		print_fpath(path, dta->dta_name);
		printf("\n");
	}
}



/*
 * print_match_header
 *
 * prints the first match of files
 */
void print_match_header(FILE_LIST *start)

{
	if (l_flag)
		return;	/* no header */
	else if (Match_criteria & NAMES_MATCH)
		printf("file %s found in directories:\n", start->dta.dta_name);
	else if (Match_criteria & CONTENTS_MATCH)
		printf("files with matching contents (size = %ld) found:\n",
			   start->dta.dta_size);
	else if (Match_criteria & SIZES_MATCH)
		printf("files of length %ld found:\n", start->dta.dta_size);
	else if (Match_criteria & TIMES_MATCH) {
		printf("files with timestamp ");
		print_fdatetime(&start->dta);
		printf(" found:\n");
	}
}



/*
 * print_next_match
 *
 * prints out any matches after the first one
 */
void print_next_match(FILE_LIST *next, int menu_num)

{
	if (menu_num >= 0)
		printf("%d)%s", menu_num, (l_flag) ? " " : "");
	if (l_flag)
		long_listing(next->path, &next->dta);
	else if (Match_criteria & NAMES_MATCH)
		printf("\t%s\n", next->path);
	else {
		printf("\t"); print_fpath(next->path, next->dta.dta_name);
		printf("\n");
	}

	next->printed = 1;
}



/*
 * print_id_menu
 *
 * given a starting point in the file list, print out an interactive delete
 * menu.
 */
void print_id_menu(FILE_LIST **menu, int num_items)

{
	int i;

	print_match_header(menu[0]);
	for (i = 0; i < num_items; i++)
		print_next_match(menu[i], i+1);
}



/*
 * cmpflist
 *
 * returns non-zero if the FILE_LIST parameter is less/greater than the given
 * dta/path combination according to the sort criteria.  If sort
 * order is ASCENDING,  non-zero returned if FILE_LIST less than dta/path
 * combo, vice-versa for DESCENDING order.
 */
int cmpflist(FILE_LIST *fd, char *path, struct _dta *dta)

{
	long cmptime_tmp;
	int tmp;

	switch (Sort_criteria) {
	case NAME_SORT:
		return (Sort_order == ASCENDING)
					? (((tmp = strcmp(fd->dta.dta_name, dta->dta_name)) < 0) ||
					   ((tmp == 0) && (strcmp(fd->path, path) <= 0)))
					: (((tmp = strcmp(fd->dta.dta_name, dta->dta_name)) > 0) ||
					   ((tmp == 0) && (strcmp(fd->path, path) >= 0)));
	case SIZE_SORT:
		return (Sort_order == ASCENDING)
					? ((fd->dta.dta_size < dta->dta_size) ||
					   ((fd->dta.dta_size == dta->dta_size) &&
						(strcmp(fd->dta.dta_name, dta->dta_name) < 0)) ||
					   ((fd->dta.dta_size == dta->dta_size) &&
						(strcmp(fd->path, path) <= 0)))
					: ((fd->dta.dta_size > dta->dta_size) ||
					   ((fd->dta.dta_size == dta->dta_size) &&
						(strcmp(fd->dta.dta_name, dta->dta_name) > 0)) ||
					   ((fd->dta.dta_size == dta->dta_size) &&
						(strcmp(fd->path, path) >= 0)));
	case TIME_SORT:
		return (Sort_order == ASCENDING)
					? (((cmptime_tmp = cmptime(&fd->dta, dta)) < 0) ||
					   ((cmptime_tmp == 0) &&
						((tmp = strcmp(fd->dta.dta_name,
									   dta->dta_name)) < 0)) ||
						((tmp == 0) && (strcmp(fd->path, path) <= 0)))
					: (((cmptime_tmp = cmptime(&fd->dta, dta)) > 0) ||
					   ((cmptime_tmp == 0) &&
						((tmp = strcmp(fd->dta.dta_name,
									   dta->dta_name)) > 0)) ||
						((tmp == 0) && (strcmp(fd->path, path) >= 0)));
	default:
		return 0;	/* unknown sort criteria */
	}
}



/*
 * cmpflist_eq
 *
 * returns non-zero if the two FILE_LIST parameters are equal according to the
 * sort criteria.
 */
int cmpflist_eq(FILE_LIST *fd1, FILE_LIST *fd2)

{
	if (fd1 == NULL)
		return (fd2 == NULL);
	else if (fd2 == NULL)
		return 0;
	switch (Sort_criteria) {
	case NAME_SORT:
		return !strcmp(fd1->dta.dta_name, fd2->dta.dta_name);
	case SIZE_SORT:
		return (fd1->dta.dta_size == fd2->dta.dta_size);
	case TIME_SORT:
		return !cmptime(&fd1->dta, &fd2->dta);
	default:
		return 0;	/* unknown sort criteria */
	}
}



/*
 * files_match
 *
 * return non-zero if the given two files 'match' according to names and the
 * criteria set by the flags (contents, date/time, size or almost any
 * combination of these).
 */
int files_match(FILE_LIST *file1, FILE_LIST *file2)

{
	return (((!(Match_criteria & NAMES_MATCH)) ||
			 (!strcmp(file1->dta.dta_name, file2->dta.dta_name))) &&
			((!(Match_criteria & SIZES_MATCH)) ||
			 (file1->dta.dta_size == file2->dta.dta_size)) &&
			((!(Match_criteria & TIMES_MATCH)) ||
			 (!cmptime(&file1->dta, &file2->dta))) &&
			((!(Match_criteria & CONTENTS_MATCH)) ||
			 (compare_path_name_files(file1->path, file1->dta.dta_name,
			 						  file2->path, file2->dta.dta_name))));
}



/*
 * gen_list
 *
 * given a path, generate a list of all files in the path and its
 * subdirectories.
 */
void gen_list(char *path)

{
	struct _dta *odta, dta;
	char *path_list, *save_path;

	odta = (struct _dta *) Fgetdta();
	Fsetdta(&dta);

	if (path == NULL)
		return;
	path_list = append_dir_to_path(path, ADD_TO_PATH);
	if ((Fsfirst(path_list, -1) >= 0) &&
		((save_path = malloc((size_t) (strlen(path)+1))) != NULL)) {
		strcpy(save_path, path);
		do {
			if (dta.dta_attribute & FA_DIR)
				gen_list_of_dir(path, dta.dta_name);
			else
				add_file_to_list(save_path, &dta);
		} while (!Fsnext());
	}

	free(path_list);
	Fsetdta(odta);
}



/*
 * add_file_to_list
 *
 * given a path and a file on the path, add it to the list according to the
 * sort criteria.
 */
void add_file_to_list(char *path, struct _dta *dta)

{
	FILE_LIST *prev = NULL, *new, *cur = F_list;

	if (Sorted)
		while ((cur != NULL) && (cmpflist(cur, path, dta))) {
			prev = cur;
			cur = cur->next;
		}

	if ((new = malloc((size_t) sizeof(FILE_LIST))) == NULL) {
		printf("add_file_to_list: memory allocation failure\n");
		exit(-1);
	}
	else {
		memcpy(&new->dta, dta, sizeof(struct _dta));
		new->path = path;
		new->added = 0;
		new->printed = 0;
		new->next = cur;
		if (prev == NULL)
			F_list = new;
		else
			prev->next = new;
	}
}



/*
 * gen_list_of_dir
 *
 * given a path and a sub-directory, call 'gen_list()' to generate a list
 * of the sub-directory on the path.
 */
void gen_list_of_dir(char *path, char *subdir)

{
	char *new_path;

	if (!is_special(subdir)) {
		gen_list(new_path = append_dir_to_path(path, subdir));
		if (v_flag > 1) {
			printf("Searching    ");
			print_fpath(path, subdir);
			printf("\n");
		}
		free(new_path);
	}
}



/*
 * list_files
 *
 * given a path, generate a linked list of files on the path or (recursively)
 * its subdirectories.  If 'sorted' is non-zero, make sure the list is
 * sorted.
 */
void list_files(char *prog_name, char *path, char sorted)

{
	struct stat statbuf;

	if ((access(path, 0)) || ((!stat(path, &statbuf)) &&
							  (!(statbuf.st_mode & S_IFDIR)))) {
		printf("%s: directory %s does not exist\n", prog_name, path);
		print_help();
		exit(-1);
	}
	else {
		Sorted = sorted;
		gen_list(path);
		if (v_flag > 1)
			printf("\n");
	}
}



/*
 * print_flist
 *
 * given a pointer to the first entry of a file list, dump the list to standard
 * output
 */
void print_flist(FILE_LIST *flist)

{
	for (;flist != NULL; flist = flist->next)
		printf("path = %s\tname = %s\n", flist->path, flist->dta.dta_name);
}



/*
 * compare_path_name_files
 *
 * given a pair of files specified by path and name, return non-zero if their
 * contents match, zero if contents don't match.
 */
int compare_path_name_files(char *path1, char *name1, char *path2, char *name2)

{
	int ret_val;
	char *file1;
	char *file2;

	file1 = append_dir_to_path(path1, name1);
	file2 = append_dir_to_path(path2, name2);
	if ((file1 == NULL) || (file2 == NULL)) {
		printf("compare_path_name_files: memory allocation failed!\n");
		exit(-1);
	}

	ret_val = compare_files(file1, file2);

	free(file1);
	free(file2);

	return ret_val;
}



/*
 * delete_path_name_file
 *
 * given a file specified by path and name, return zero if the file was
 * successfully deleted, non-zero if not.  'force' parameter, if non-zero, will
 * try to change the mode of a file from read-only to delete it.
 */
int delete_path_name_file(char *path, char *f_name, char force)

{
	char *file = append_dir_to_path(path, f_name);
	int ret_val;

	if (file == NULL) {
		printf("delete_path_name_file: memory allocation failed\n");
		exit(-1);
	}

	ret_val = delete_file(file, force);

	free(file);

	return ret_val;
}
