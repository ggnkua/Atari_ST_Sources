/*
 * sfdf.h
 *
 * prototypes for sfdf.c - find duplicates.
 *
 * Roy Bixler (original development and Atari ST version)
 * Ayman Barakat (idea)
 * David Oertel (MS-DOS version)
 *
 * Version 1.0: March 14, 1991
 * Version 1.01: April 12, 1992
 */



#define PROG_NAME	"sfdf"
#define GETOPT_LIST	"IiLlM:m:O:o:S:s:Vv?"
#define SFDF_USAGE \
"%s - sorted find duplicate files\
\nVersion 1.01, Copyright (c) 1992 Roy Bixler.\
\n    \"sfdf\" comes with ABSOLUTELY NO WARRANTY; for details type `sfdf -?'.\
\n    This is free software, and you are welcome to redistribute it\
\n    under certain conditions.\
\n\nusage: %s [-ma] [-m[cdns]] [-oa|d] [-sd|n|s] [-ilv?] path [...]\
\n   where 'path' is the starting directory for finding\
\n   duplicate files.\
\nmatching criteria: (default = -mdns)\
\n   -ma - consider name, size, date/time and contents\
\n   -m[cdns] - set the combination of matching criteria\
\n       c - file contents must match, implies 's' (sizes must match)\
\n       d - date/time of files must match\
\n       n - names must match\
\n       s - size of files must match\
\nsorting criteria: (default = -oa -sn)\
\n   -oa|d - sort in ascending/descending order\
\n   -sd|n|s - set the sorting criteria\
\n       d - sort output by date/time\
\n       n - sort output by name\
\n       s - sort output by size\
\noptions:\
\n   -i - interactive delete\
\n   -l - long listing of duplicate files\
\n   -v - verbose, print statistics\
\n   -vv - very verbose, also print activity report\
\n   -? - print full documentation and exit\n"

#define SFDF_SCHPIEL1 \
"sfdf - sorted find duplicate files\
\nVersion 1.01, Copyright (c) 1992 Roy Bixler.\
\n\
\nGeneral Idea:\
\n\
\n    This program finds duplicate files on your disk(s).  It is\
\n    possible to specify multiple disks and see duplicate files across\
\n    disks.  You have control over criteria for finding duplicate files\
\n    and the order in which the duplicates are presented.  For the\
\n    really business-like, there is an interactive delete mode that\
\n    presents you with menus asking which of the duplicate files to\
\n    delete.  As an option, a statistical summary of the duplicate\
\n    files is printed out at the end.\
\n\
\nUsage:\
\n\
\n    sfdf [-ma] [-m[cdns]] [-oa|d] [-sd|n|s] [-ilv?] path [...]\
\n        where 'path' is the starting directory for finding duplicate\
\n        files.\
\n\
\nMatching criteria:\
\n\
\n    Tells program what information to consider in determining whether\
\n    a pair of files are duplicates or not.  The default is to consider\
\n    files as duplicates if their names, modification date/times and\
\n    sizes match (i.e. -mdns).\
\n\
\n        -ma - All.\
\n            Consider name, size, date/time and contents.\
\n\
\n        -m[cdns] - Set the matching criteria.\
\n            c - Contents.\
\n                File contents must match, implies 's' (sizes must\
\n                match).\
\n\
\n            d - Dates.\
\n                Date/time of files must match.\
\n\
\n            n - Names.\
\n                Names must match.\
\n\
\n            s - Sizes.\
\n                Size of files must match.\
\n\
\nSorting criteria:\
\n\
\n    Tells program in what order to present the duplicate files.  The\
\n    default is to sort by names and paths only.  If any options are\
\n    specified below, the primary sort key is changed accordingly and\
\n    the names and paths become the secondary sort key.  The\
\n    performance will suffer noticeably if the primary sort key is not\
\n    one of the match criteria.  Defaults are to sort by name in\
\n    ascending order (i.e. -oa -sn).\
\n\
\n        -oa|d - Ordering.\
\n            Sort in ascending/descending order.\
\n\
\n        -sd|n|s - set the sorting criteria.\
\n            d - Dates.\
\n                Sort output by date/time.\
\n\
\n            n - Names.\
\n                Sort output by name.\
\n\
\n            s - Sizes.\
\n                Sort output by size.\n"


#define SFDF_SCHPIEL2 \
"\nOptions:\
\n\
\n        -i - Interactive delete mode.\
\n            Duplicate files are listed in menus.  Type in the numbers\
\n            of the files you wish to delete or just hit <Return> to\
\n            leave the files alone.  The numbers can be separated by\
\n            commas or spaces.  Ranges of numbers can be specified by\
\n            separating the lower and upper limits with a dash.\
\n\
\n        -l - Long listing of duplicate files.\
\n            Gives date/time and size information on each duplicated\
\n            file.\
\n\
\n        -v - Verbose, print statistics.\
\n            Give information on number of files, number of duplicated\
\n            files, number of duplicate names, total number of bytes\
\n            and averages of each at the end.  When in 'interactive\
\n            delete mode', also print out how many bytes in files you\
\n            deleted.\
\n\
\n        -vv - Very verbose, also print activity report.\
\n            In addition to printing statistics above, print out the\
\n            directories searched for duplicate files.\
\n\
\n        -?\
\n            Print full documentation and exit.  You are here!\
\n\
\nDifferences with 'fdf':\
\n\
\n    This program sorts the duplicate files list, which 'fdf' does not.\
\n    It is also slower than 'fdf', but uses less memory.\
\n\
\nLicense:\
\n\
\n    This program is free software; you can redistribute it and/or modify\
\n    it under the terms of the GNU General Public License as published by\
\n    the Free Software Foundation; either version 1, or (at your option)\
\n    any later version.\
\n\
\n    This program is distributed in the hope that it will be useful,\
\n    but WITHOUT ANY WARRANTY; without even the implied warranty of\
\n    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\
\n    GNU General Public License for more details.\
\n\
\n    You should have received a copy of the GNU General Public License\
\n    along with this program; if not, write to the Free Software\
\n    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.\
\n\
\n    Please send bug reports and/or suggestions to:\
\n        Roy Bixler\
\n        420 S. 13th\
\n        San Jose, CA 95112\
\n    Include the name of the program, version and operating system.\
\n\
\n    Bug reports and other comments can also be sent as e-mail on the\
\n        Internet to: rcb@netcom.com.\
\n        UUCP: uunet!netcom.com!rcb\n"



typedef struct hash_list {
	FILE_LIST *f_name;
	struct hash_list *next;
} HASH_LIST;



extern HASH_LIST *H_list[HASH_TAB_SIZE];



/* sfdf.c */
void print_help(void);
void show_doc(void);
int sort_eq_match(void);
void print_dups(FILE_LIST *start);
int gen_id_menu(FILE_LIST *start, FILE_LIST **menu, int max_items);
void id_dups(FILE_LIST *start);
FILE_LIST *find_non_printed(FILE_LIST *file);
void find_dups();
void count_total_stats(void);
int get_options(int argc, char **argv);
int main(int argc, char **argv);
