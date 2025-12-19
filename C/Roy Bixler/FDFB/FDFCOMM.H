/*
 * fdcomm.h
 *
 * common functions for find duplicates.
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



#define ADD_TO_PATH		"*.*"
#define MAX_STR			80
#define N_INTERACTIVE	20	/* maximum number of interactive delete menu */
							/* entries */

/*
 * file matching criteria
 */
#define CONTENTS_MATCH	0x1
#define TIMES_MATCH		0x2
#define SIZES_MATCH		0x4
#define NAMES_MATCH		0x8
#define ALL_MATCH		(CONTENTS_MATCH|TIMES_MATCH|SIZES_MATCH|NAMES_MATCH)

/*
 * file sorting criteria
 */
#define TIME_SORT		0x1
#define SIZE_SORT		0x2
#define NAME_SORT		0x4

/*
 * file sort order
 */
#define ASCENDING		0x0
#define DESCENDING		0x1



typedef struct file_list {
	struct _dta dta;
	char *path;
	char added;
	char printed;
	struct file_list *next;
} FILE_LIST;



extern FILE_LIST *F_list;
extern char Match_criteria, Sort_criteria, Sort_order;
extern char i_flag;	/* interactive delete mode */
extern char l_flag;	/* long listing? */
extern char v_flag;	/* verbose? */



/* fdfcomm.c */
void print_fdate(struct _dta *dta);
void print_ftime(struct _dta *dta);
void print_fdatetime(struct _dta *dta);
void print_fpath(char *path, char *f_name);
void long_listing(char *path, struct _dta *dta);
void print_match_header(FILE_LIST *start);
void print_next_match(FILE_LIST *next, int menu_num);
void print_id_menu(FILE_LIST **menu, int num_items);
int cmpflist(FILE_LIST *fd, char *path, struct _dta *dta);
int cmpflist_eq(FILE_LIST *fd1, FILE_LIST *fd2);
int files_match(FILE_LIST *file1, FILE_LIST *file2);
void gen_list(char *path);
void add_file_to_list(char *path, struct _dta *dta);
void gen_list_of_dir(char *path, char *subdir);
void list_files(char *prog_name, char *path, char sorted);
void print_flist(FILE_LIST *flist);
int compare_path_name_files(char *path1, char *name1, char *path2, char *name2);
int delete_path_name_file(char *path, char *f_name, char force);
