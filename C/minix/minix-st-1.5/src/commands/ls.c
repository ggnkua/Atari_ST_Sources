/* ls - list files			Author: Peter Housel */

/*@*Introduction.
 * This file is part of \fIls\fP for Minix. It was written in the spring
 * of 1989 by Peter S. Housel. This program is in the public domain and may
 * be redistributed without restriction. As such, no warranty of any kind
 * is provided.
 * .PP
 * The following changes to the program have been made:
 * .IP \(bu
 * Version 1.1 - removed references to \fB\-q\fP option, added |ONECOLUMN|
 * and other compile-time options.
 */

/*@ \fILs\fP is a version of standard Minix directory listing program. Because
 * it use so often used, it should be as fast as possible. It should be
 * somewhat "featureful" (Rob Pike nonwithstanding), but not in a way
 * that interferes with its use as a "software tool." It should take
 * up a small to medium amount of memory.
 * .PP
 * The program should be compiled using:
 * .nf
 *	\fBcc -o ls -D_MINIX -D_POSIX_SOURCE ls.c
 *	chmem =4096 ls\fP
 * or
 *	\fBcc -o ls -DATARI_ST ls.c\fP
 * .fi
 * If you do not want multi-column listings to be the default when
 * standard output is a tty, define |ONECOLUMN| (by adding
 * \fB\-DONECOLUMN\fP to the compile flags). Similarly, |NFILE|,
 * |STRINGSPACE|, and |LINEWIDTH| can be changed with appropriate
 * predefines.
 */

#define ONECOLUMN		/* default is 1 column listings */
#define major(x) ( (x>>8) & 0377)
#define minor(x) (x & 0377)

/*@ Since \fIls\fP has to know a lot about files, there are quite a few
 * headers to include.
 */
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <limits.h>
#include <dirent.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include <stdio.h>

extern int errno;

/*@ |DOTDIR()| determines whether or not a given |name| is one of the
 * special directory files "." or "..".
 */
#define DOTDIR(name)	\
  (name[0] == '.'	\
   && (name[1] == '\0' || (name[1] == '.' && name[2] == '\0')))

/*@ We use |getopt()| to parse the command-line flag arguments. This
 * annoys some people who are used to the (BSD pre-Tahoe release)
 * "infinte args \fIls\fP" that doesn't complain about anything.
 */
extern int getopt( 	/* int argc, char **argv, char *optstring */ );
extern char *optarg;
extern int optind;

/*@ It may be necessary to |stat()| each file that is listed.
 * The toplevel files (specified by the arguments) will need to be, to
 * determine which ones are directories. Several of the options will
 * make it necessary to have the |stat()| information (the \fB\-l\fP and
 * \fB\-R\fP options, for example), and we will turn on |stateach|
 * later on if any of these are set.
 */
int stateach;

/*@ \fILs\fP takes quite a few options: .IP \fB\-l\fP
 * Print in "long listing" format. Sets |flags_l|, unsets |flags_C|.
 * .IP \fB\-g\fP
 * Include the group ownership along with the user ownership in the long
 * format listing. Sets |flags_g|.
 * .IP \fB\-t\fP
 * Sort the listing by the modification time, with most recent times
 * printed first. Sets |flags_t|.
 * .IP \fB\-a\fP
 * Include all files. By default, files whose names begin with "." are not
 * included. Sets |flags_a|.
 * .IP \fB\-A\fP
 * Include all files, even those beginning with ".", except for "." and "..".
 * This flag is automatically turned on for the superuser. Sets |flags_A|.
 * .IP \fB\-s\fP
 * Print the size of the file (in kilobytes) with each file. Sets |flags_s|.
 * .IP \fB\-d\fP
 * List named directories explicitly instead of their contents. Sets
 * |flags_d|.
 * .IP \fB\-r\fP
 * Sort the listing in reverse order. Sets |flags_r|.
 * .IP \fB\-u\fP
 * Use the file access time instead of the modification time in the listings
 * (\fB\-l\fP option) and/or as the sort key (\fB\-t\fP option). Sets
 * |flags_u|. \fI(Currently ineffectual in Minix.)\fP
 * .IP \fB\-c\fP
 * Like \fB\-u\fP, except that the inode change time is used instead.
 * Sets |flags_c|.
 * .IP \fB\-i\fP
 * Print the file's inode number with each file. Sets |flags_i|.
 * .IP \fB\-f\fP
 * Force the named files to be interpreted as directories, whether they
 * are or not. (Actually, the POSIX-type directory routines cause problems
 * with this. They reqire that the file be a directory.) Sets |flags_f|
 * and |flags_a|, and unsets |flags_l|,
 * |flags_t|, |flags_s|, and |flags_r|.
 * .IP \fB\-F\fP
 * After the filenames of directories, print "/". After executable files,
 * print "*". Sets |flags_F|.
 * .IP \fB\-R\fP
 * Recursively print each subdirectory. Sets |flags_R|.
 * .IP \fB\-1\fP
 * Print in "one-column" format instead of columnar format. This is the
 * default if standard output is not a tty. Unsets |flags_C|.
 * .IP \fB\-C\fP
 * Print in columnar format. This is the default if standard output is
 * a tty, provided |ONECOLUMN| has not been defined. Sets |flags_C|.
 */
#define VALID_FLAGS	"lgtaAsdrucifFR1C"

int flags_l, flags_g, flags_t, flags_a, flags_A, flags_s, flags_d, flags_r, flags_u, flags_c, flags_i, flags_f, flags_F, flags_R, flags_C;

/*@ */
main(argc, argv)
int argc;
char *argv[];
{
  void add_args( 	/* int argc; char **argv; */ );
  void listall( 	/* void */ );

  int c;			/* option character */
#ifdef noperprintf
  noperprintf(stdout);
#endif

#ifndef ONECOLUMN
  if (isatty(1)) flags_C = 1;
#endif

  while ((c = getopt(argc, argv, VALID_FLAGS)) != EOF) {
	switch (c) {
	    case 'l':	flags_l = 1;	break;
	    case 'g':	flags_g = 1;	break;
	    case 't':	flags_t = 1;	break;
	    case 'a':	flags_a = 1;	break;
	    case 'A':	flags_A = 1;	break;
	    case 's':	flags_s = 1;	break;
	    case 'd':	flags_d = 1;	break;
	    case 'r':	flags_r = 1;	break;
	    case 'u':	flags_u = 1;	break;
	    case 'c':	flags_c = 1;	break;
	    case 'i':	flags_i = 1;	break;
	    case 'f':	flags_f = 1;	break;
	    case 'F':	flags_F = 1;	break;
	    case 'R':	flags_R = 1;	break;
	    case '1':	flags_C = 0;	break;
	    case 'C':	flags_C = 1;	break;

	    case '?':
		fprintf(stderr, "Usage: ls -%s [file ...]\n",
			VALID_FLAGS);
		exit(1);
	}
  }

  if (flags_f) {
	flags_l = flags_t = flags_s = flags_r = 0;
	flags_a = 1;
  }
  if (flags_l || flags_s || flags_i) flags_C = 0;

  flags_r = flags_r ? -1 : 1;	/* multiplier for comparisons */

  if (geteuid() == 0 && !flags_a) flags_A = 1;

  stateach = !flags_f;
  add_args(argc - optind + 1, argv + optind - 1);

  stateach = !flags_f && (flags_l || flags_t || flags_s || flags_i
			|| flags_F || flags_R);
  listall();

  exit(0);
}

/*@* The files table.
 * The |struct lsfile| structure is the main data structure used by
 * \fIls\fP. The |files| array is an array of these structures, with
 * each entry representing one file to be listed by the program.
 * The |f_stat| field is the result of a |stat()| call on the file, if
 * one has been done. The |f_name| field points to the filename, either
 * directly to the command-line argument, or to a copy in string space
 * of a name read from a directory. The |f_parent| field points to the
 * parent directory of a file, so that the entire relative pathname
 * can be constructed using the |pathname()| function below.
 * .PP
 * There are at most |NFILE| entries in the staticaly-allocated table.
 * Entries are added as a directory is read in, and removed when the
 * listing of that directory is done. The |filep| variable is used to
 * point to the next free entry.
 */
#ifndef NFILE
#define NFILE		512
#endif

struct lsfile {
  struct stat f_stat;		/* file information from inode */
  char *f_name;			/* file name */
  struct lsfile *f_parent;	/* parent directory, if any */
};

struct lsfile files[NFILE];
struct lsfile *filep = files;

/*@ When a directory is sorted, the time spent exchanging entries is reduced
 * by exchanging pointers to entries instead of the entries themselves.
 * When a listing is printed, the file table entries are accessed
 * indirectly through |sortindex| entries.
 */
struct lsfile *sortindex[NFILE];


/*@ The string area is used to store filenames read in from directories,
 * as well as the lines of output for columnar listings. Like the file
 * table, space in the string area is deallocated when it is no longer
 * needed.
 */
#ifndef STRINGSPACE
#define STRINGSPACE	8192
#endif

char strings[STRINGSPACE];
char *stringp = strings;

/*@ The |ADDSTRING()| macro is used to add characters to the string
 * table. A check for overflow is made.
 */
char stringerr[] = "ls: out of string space\n";
#define ADDSTRING(c) 				\
  if(stringp - strings >= STRINGSPACE)	\
    {					\
     fprintf(stderr, stringerr);		\
     exit(1);				\
    }					\
  else					\
     *stringp++ = c

/*@ These are the forward declarations for the files table section. */
void add_file(			/* char *filename, struct lsfile *parent,
            ino_t inum, int savename */ );
char *pathname( 	/* struct lsfile *entry */ );

/*@ The |add_args()| function is used to add the files specified
 * in the command line arguments to the files table. Note that
 * \fIls\fP without any file arguments is equivalent to "\fIls\ .\fP"
 */
void add_args(argc, argv)
int argc;
char *argv[];
{
  if (argc == 1)
	add_file(".", (struct lsfile *) NULL, 0, 0);
  else
	while (++argv, --argc) {
		add_file(*argv, (struct lsfile *) NULL, 0, 0);
	}
}


/*@ |add_dir()| opens a directory and adds the files it contains to the
 * files table. If "dot-files" are not being listed, they will be
 * omitted.
 */
void add_dir(entry)
struct lsfile *entry;
{
  DIR *dirp;
  struct dirent *dp;
  struct lsfile *parent = NULL;

  if (strcmp(entry->f_name, ".") != 0)	/* "./" is redundant */
	parent = entry;

  if ((dirp = opendir(pathname(entry))) == NULL) {
	fprintf(stderr, "ls: can't open directory %s\n", pathname(entry));
	perror("ls");
	return;
  }
  while ((dp = readdir(dirp)) != NULL) {
	if (dp->d_name[0] == '.' && !(flags_A || flags_a)) continue;
	if (DOTDIR(dp->d_name) && !flags_a) continue;
	add_file(dp->d_name, parent, (ino_t) dp->d_ino, 1);
  }

  (void) closedir(dirp);
}

/*@ |add_file()| does the actual work of entering files into the table.
 * If it is necessary to save the name in the string table, this is
 * done. Also, if it is necessary to |stat()| the file, we do it here.
 */

void add_file(filename, parent, inum, savename)
char *filename;
struct lsfile *parent;
ino_t inum;
int savename;
{
  if (filep - files >= NFILE) {
	fprintf(stderr, "ls: too many files\n");
	exit(1);
  }
  if (filename[0] == '\0') {	/* POSIX doesn't like null pathnames (?) */
	fprintf(stderr, "ls: invalid null filename\n");
	return;
  }
  if (savename) {
	filep->f_name = stringp;
	while (*filename) {
		ADDSTRING(*filename++);
	}
	ADDSTRING('\0');
  } else
	filep->f_name = filename;

  filep->f_parent = parent;
  filep->f_stat.st_ino = inum;

  sortindex[filep - files] = filep;

  if (stateach)
	if (stat(pathname(filep), &filep->f_stat) < 0) {
		int saverrno = errno;
		fprintf(stderr, "ls: cannot stat %s", pathname(filep));
		errno = saverrno;
		perror("");
		return;
	}
  ++filep;
}

/*@ The |pathname()| function reconstructs the relative pathname of a
 * file from a pointer to its table entry. As a base case, it returns
 * the stored filename of files which have no parents. Otherwise, it
 * recursively determines the pathname of the parent directory and
 * appends the stored name to it.
 * .PP
 * The name of the last parent directory searched is cached to save
 * on recursive calls.
 */
char *pathname(entry)
struct lsfile *entry;
{
  static char name[PATH_MAX + 1];

  static char parentname[PATH_MAX + 1];
  static struct lsfile *parent;

  register char *p, *q;

  if (entry->f_parent == NULL) return entry->f_name;

  if (entry->f_parent != parent) {
	strcpy(parentname, pathname(entry->f_parent));	/* recurse */
	parent = entry->f_parent;
  }
  for (q = parentname, p = name; *q;) *p++ = *q++;

  if (p[-1] != '/') *p++ = '/';

  for (q = entry->f_name; *q;) *p++ = *q++;

  *p = '\0';

  return name;
}

/*@*Listing files.
 * Most of the work of listing files is done in this section, in particular
 * by the |listfiles()| function.
 */

/*@ Forward declarations for this section: */
void listfiles( 	/* int baseindex; int lastindex */ );
void sortfiles( 	/* int baseindex; int nfiles */ );
void listone( 	/* struct lsfile *entry */ );
void listcol( 	/* struct lsfile *entry */ );
void prdate( 	/* time_t filetime */ );
void dumpcols( 	/* void */ );

char *owner( 	/* int uid */ );
char *groupname( 	/* int gid */ );

/*@ */
void listall()
{
  if (!flags_f) sortfiles(0, (int)(filep - files));
  listfiles(0, (int)(filep - files), flags_d);
}

/*@ The |listfiles()| function is, effectively, the "heart" of \fIls\fP.
 * First, the "total nnn" line (listing the total number of blocks
 * taken up by the listed files) is computed and printed if necessary.
 * Next, if we are listing files specified on the command line, list
 * all except the directories. Otherwise, list all of the files. Next,
 * go through all of the directories and recursively list them.
 */
void listfiles(baseindex, lastindex, include_dirs)
int baseindex;
int lastindex;
int include_dirs;
{
  int i;
  char *name;
  char *ostringp;

  if (flags_l || flags_s) {
	int total = 0;
	int counted = 0;
	for (i = baseindex; i < lastindex; ++i) {
		if (include_dirs
		    || (sortindex[i]->f_stat.st_mode & S_IFMT) != S_IFDIR) {
			counted = 1;
			total += nblocks(sortindex[i]->f_stat.st_size);
		}
	}
	if (counted) printf("total %d\n", total);
  }
  ostringp = stringp;

  for (i = baseindex; i < lastindex; ++i) {
	if (!(flags_f && baseindex == 0) && (include_dirs
	     || (sortindex[i]->f_stat.st_mode & S_IFMT) != S_IFDIR))
		if (flags_C)
			listcol(sortindex[i]);
		else
			listone(sortindex[i]);
  }

  if (flags_C) dumpcols();

  stringp = ostringp;

  fflush(stdout);
  if (flags_d || (baseindex > 0 && !flags_R)) return;

  for (i = baseindex; i < lastindex; ++i) {
	name = sortindex[i]->f_name;

	if ((flags_f && baseindex == 0)
	    || ((sortindex[i]->f_stat.st_mode & S_IFMT) == S_IFDIR
		&& (baseindex == 0 || !DOTDIR(name)))) {
		struct lsfile *ofilep;

		if (lastindex - baseindex > 1)
			printf("\n%s:\n", pathname(sortindex[i]));

		ofilep = filep;
		ostringp = stringp;

		add_dir(sortindex[i]);
		if (!flags_f) sortfiles((int)(ofilep - files), (int)(filep - ofilep));
		listfiles((int)(ofilep - files), (int)(filep - files), 1);

		filep = ofilep;
		stringp = ostringp;
	}
  }
}

/*@ Except for columnar listings, |listone()| does the work of listing
 * individual files, on lines by themselves, to standard output.
 * Special-case formatting is done for the "-l", "-s", "-i", and "-F"
 * options.
 */
void listone(entry)
register struct lsfile *entry;
{
  unsigned short mode;
  char c, fchar( 	/* unsigned short mode */ );

  if (flags_i) printf("%5d ", entry->f_stat.st_ino);

  if (flags_s) printf("%4d ", nblocks(entry->f_stat.st_size));

  mode = entry->f_stat.st_mode;

  if (flags_l) {
	static char *rwx[] = {"---", "--x", "-w-", "-wx",
			      "r--", "r-x", "rw-", "rwx"};
	char bits[11];

	switch (mode & S_IFMT) {
	    case S_IFDIR:	bits[0] = 'd';	break;
	    case S_IFBLK:	bits[0] = 'b';	break;
	    case S_IFCHR:	bits[0] = 'c';	break;
	    case S_IFIFO:	bits[0] = 'p';	break;
	    default:	bits[0] = '-';	break;
	}

	strcpy(&bits[1], rwx[(mode >> 6) & 7]);
	strcpy(&bits[4], rwx[(mode >> 3) & 7]);
	strcpy(&bits[7], rwx[(mode & 7)]);
	if (mode & S_ISUID) bits[3] = 's';
	if (mode & S_ISGID) bits[6] = 's';
/*  if(mode & S_ISVTX) bits[9] = 't';		NOT IMPLEMENTED */
	printf("%s %2d %-8.8s ", bits, entry->f_stat.st_nlink,
	       owner(entry->f_stat.st_uid));
	if (flags_g) printf("%-8.8s ", groupname(entry->f_stat.st_gid));

	if ((mode & S_IFMT) == S_IFCHR || (mode & S_IFMT) == S_IFBLK) {
		printf("%3d, %3d ", major(entry->f_stat.st_rdev),
		       minor(entry->f_stat.st_rdev));
	} else
		printf("%8ld ", (long) entry->f_stat.st_size);

	if (flags_u)
		prdate(entry->f_stat.st_atime);
	else if (flags_c)
		prdate(entry->f_stat.st_ctime);
	else
		prdate(entry->f_stat.st_mtime);
  }
  printf("%s", entry->f_name);

  if (flags_F && (c = fchar(mode)) != '\0') putchar(c);
  putchar('\n');
}

/*@ When the "-F" option is being used, |fchar()| computes the character
 * which will follow the filename - '/' for directories, and '*' for
 * executable files. If there were sockets, FIFO's and symbolic links,
 * they would have cases here too.
 */
char fchar(mode)
unsigned short mode;
{
  if ((mode & S_IFMT) == S_IFDIR)
	return '/';
  else if (mode & 0111)
	return '*';
  else
	return '\0';
}

/*@*Listing in columns.
 * When the "-C" option is used, or an ordinary listing is done to
 * a terminal, then the listing is in columns. As many columns as will
 * fit on the screen are used. The |listcol()| function is used to
 * add an entry to the column entries table, and is called instead
 * of |listone()|. The string which will be printed for each file
 * is stored in the string table. When the listing is done, |dumpcol()|
 * will print it out.
 */
#ifndef LINEWIDTH
#define LINEWIDTH	79
#endif

int maxwidth = 0;
char *colentries[NFILE];
char **colentp = colentries;

/*@ For now, |listcol()| copies the filename to the string table
 * and leaves a pointer in the column entries table, optinally adding
 * the postfix character for the "-F" option. It also maintains
 * a "maximum width" so that |dumpcols()| can determine how many
 * columns will fit on a terminal line.
 */
void listcol(entry)
register struct lsfile *entry;
{
  char *p;
  char c;
  int width;

  *colentp = stringp;
  for (p = entry->f_name; *p;) {
	ADDSTRING(*p++);
  }

  width = stringp - *colentp;
  if (width > maxwidth) maxwidth = width;

  if (flags_F && (c = fchar(entry->f_stat.st_mode)) != '\0') ADDSTRING(c);

  ADDSTRING('\0');
  ++colentp;
}

/*@ |dumpcols()| computes how many columns will fit on the output
 * line, and prints the filenames.
 */
void dumpcols()
{
  int ncols;			/* number of columns that will fit */
  int nrows;			/* number of rows required */
  int colwidth;			/* how wide the evenly spaced columns are */
  int i;
  char **cp;			/* pointer to column entries */

  if (maxwidth == 0) return;

  ncols = LINEWIDTH / (maxwidth + 2);
  if (ncols == 0) ncols = 1;
  colwidth = LINEWIDTH / ncols;
  nrows = (colentp - colentries) / ncols;
  if ((colentp - colentries) % ncols > 0) ++nrows;

  for (i = 0; i < nrows; ++i) {	/* loop on rows */
	for (cp = &colentries[i]; cp < colentp; cp += nrows) {	/* loop on columns */
		printf("%-*.*s", colwidth, colwidth, *cp);
	}
	putchar('\n');
  }

  colentp = colentries;		/* re-initialize for next listing */
  maxwidth = 0;
}

/*@*Sorting lists.
 * Sorting is done using the standard library |qsort()| function.
 * Depending on the options, either the file access time, the file
 * modify time, the inode change time, or the filename will be used
 * as the sort key. |sortfiles()| determines what comparison function to
 * use based on this and calls |qsort()|.
 */
void sortfiles(baseindex, nfiles)
int baseindex;
int nfiles;
{
  int (*compare) ();
  int comp_atime(), comp_ctime(), comp_mtime(), comp_name();

  if (nfiles < 2) return;
  if (flags_t) {
	if (flags_u)
		compare = comp_atime;
	else if (flags_c)
		compare = comp_ctime;
	else
		compare = comp_mtime;
  } else
	compare = comp_name;

  qsort(&sortindex[baseindex], nfiles, sizeof sortindex[0], compare);
}

int comp_atime(one, two)	/* compare access times */
struct lsfile **one;
struct lsfile **two;
{
  register time_t diff;

  diff = (*one)->f_stat.st_atime - (*two)->f_stat.st_atime;

  if (diff == 0)
	return 0;
  else if (diff < 0)
	return flags_r;
  else
	return -flags_r;
}

int comp_ctime(one, two)	/* compare inode change times */
struct lsfile **one;
struct lsfile **two;
{
  register time_t diff;

  diff = (*one)->f_stat.st_ctime - (*two)->f_stat.st_ctime;

  if (diff == 0)
	return 0;
  else if (diff < 0)
	return flags_r;
  else
	return -flags_r;
}

int comp_mtime(one, two)	/* compare file modify times */
struct lsfile **one;
struct lsfile **two;
{
  register time_t diff;

  diff = (*one)->f_stat.st_mtime - (*two)->f_stat.st_mtime;

  if (diff == 0)
	return 0;
  else if (diff < 0)
	return flags_r;
  else
	return -flags_r;
}

int comp_name(one, two)		/* compare filenames */
struct lsfile **one;
struct lsfile **two;
{
  return flags_r * strcmp((*one)->f_name, (*two)->f_name);
}

/*@*User and group id's.
 * |owner()| and |groupname()| are used to translate user and group
 * id's to names for the long-format listing. The last id translated
 * is cached.
 */
char *owner(uid)
int uid;
{
  static int ouid = -1;
  static char uname[16];
  struct passwd *pw, *getpwuid( /* int uid */ );

  if (uid == ouid) return uname;

  if ((pw = getpwuid(uid)) == NULL)
	sprintf(uname, "%d", uid);
  else
	strcpy(uname, pw->pw_name);

  return uname;
}

char *groupname(gid)
int gid;
{
  static int ogid = -1;
  static char gname[16];
  struct group *gr, *getgrgid( 	/* int gid */ );

  if (gid == ogid) return gname;

  if ((gr = getgrgid(gid)) == NULL)
	sprintf(gname, "%d", gid);
  else
	strcpy(gname, gr->gr_name);

  return gname;
}

/*@*Date and time. |prdate()| prints the specified time in the format used by
 * the long-format listing. The month and day are printed, along with the
 * time of day if the time is recent. If it is not, the year is printed
 * instead.
 */

#define LONGAGO	((365L * 86400L) / 2L)	/* about six months */

void prdate(filetime)
time_t filetime;
{
  struct tm *timep, *localtime( /* time_t *clock */ );
  static time_t now;		/* approximate current time */

  static char *months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
			 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

  if (now == 0) time(&now);

  timep = localtime(&filetime);

  printf("%s %2d ", months[timep->tm_mon], timep->tm_mday);

  if (now - filetime >= LONGAGO || filetime > now)
	printf(" %d ", timep->tm_year + 1900);
  else
	printf("%02d:%02d ", timep->tm_hour, timep->tm_min);
}

/*@*Counting blocks.
 * This code is 'stolen' almost verbatim from Andrew S. Tanenbaum's
 * original Minix "ls.c" program. It is the primary non-POSIX (OS-dependant)
 * function in the program.
 */
#include <minix/config.h>
#include <minix/const.h>
#include <minix/type.h>
#include "../fs/const.h"
#include "../fs/type.h"

int nblocks(size)
long size;
{
/* Convert file length to blocks, including indirect blocks. */

  int blocks, fileb;

  fileb = (size + (long) BLOCK_SIZE - 1) / BLOCK_SIZE;
  blocks = fileb;
  if (fileb <= NR_DZONE_NUM) return(blocks);
  blocks++;
  fileb -= NR_DZONE_NUM;
  if (fileb <= NR_INDIRECTS) return(blocks);
  blocks++;
  fileb -= NR_INDIRECTS;
  blocks += (fileb + NR_INDIRECTS - 1) / NR_INDIRECTS;
  return(blocks);
}
