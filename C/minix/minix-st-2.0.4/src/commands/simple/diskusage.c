/* Diskusg - determines usage disk	  Author: Don Chapman */

/*
 *
 * Diskusg -	Patterned after System V Administrative command
 *		but written for MINIX V1.5 or V1.6 from scratch.
 *		Does not access disk structures directly.  Should
 *		be fairly portable to C with dirent.  This version
 *		will count files that are linked to other names for
 *		each name.
 *
 * Output:	Output is a listing, on stdout, by uid of the blocks
 *		in use on a special device (block structured, ie. disk)
 *		sorted by uid.  Shows total blocks in use on the
 *		device for each uid. Form: uid username longint.
 *
 * Usage:	diskusg [-p fil] [-u fil] [-s] [-v] [-i flst] spec.file ...
 *
 * Flags:	-p fil	Use "fil" to obtain a list of the usernames and
 *			uids rather than /etc/passwd.  The file must be
 *			similar in form to /etc/passwd at least beyond
 *			the uid. eg: ast:Oky||V|yoZ7vO:8: or ast::8:
 *
 *		-u fil	Make an ascii list in "fil" of files that seem to
 *			belong to nobody.  The form of the list is:
 *			    special-file-name i-node-number user-ID.
 *
 *		-s	The input files are files of diskusg outputs and
 *			the new output should be the cumulative sum of the
 *			usages.  The files were probably made using the
 *			command diskusg /specdev > file.  This one deletes
 *			any duplicate usernames and charges all to the
 *			first username it sees.
 *
 *		-v	Verbose makes a listing on stderr of the files or
 *			directorys found with unknown owners.
 *
 *		-i flst	Ignore the data on the file systems whose name is
 *			in flst.  Flst is a list of names separated by
 *			commas or enclosed within quotes. Diskusg compares
 *			each name with the names on the spec. file relative
 *			to the root (/) of the spec. file.
 *			ie: dskusg -i /tmp/ignoreme,/joe,/lib /dev/fd1
 *
 *		specfil	The name of a special file (block structured) to be
 *			searched for disk usage.
 *			eg.: /dev/hd2
 *
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <dirent.h>
#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <ctype.h>
#include <unistd.h>
#include <stdio.h>

/* Un-comment or compile -DREMOVE_DUPES if you wish */
 /* #define REMOVE_DUPES *//* option to always remove duplicate usernames */
#define FALSE 0
#define TRUE ~FALSE
#define PWLEN 100
#define PLENGTH 40

#define USEREC struct userecord
USEREC {
  char *name;
  uid_t uid;
  long blocks;
  USEREC *next;
};

#define IGNREC struct ignrecord
IGNREC {
  char *structname;
  IGNREC *next;
};

static char *Version = "@(#) DISKUSG 1.00 D.E.C. (04/10/91)";

/* Globals */
char *progname;
char *passwd = "/etc/passwd";
char *ufile = NULL;
int uflag = FALSE;
FILE *ufd;
USEREC *list_head = NULL;
int verbose = FALSE;
int sflag = FALSE;
char *spec_name = "\0";
struct stat this_stat;
dev_t real_dev;
char *ilist = NULL;
int iflag = FALSE;
IGNREC *ign_head = NULL;
int didmount = FALSE;
int mountlength;

_PROTOTYPE(int exists, (USEREC * head, Uid_t uid));
_PROTOTYPE(void insert, (USEREC ** head, USEREC * rec));
_PROTOTYPE(void make_userlist, (void));
_PROTOTYPE(void showlist, (void));
_PROTOTYPE(int update_list, (Uid_t uid, off_t bytes));
_PROTOTYPE(void search_all, (char *cur_dir));
_PROTOTYPE(int ilist_search, (char *path));
_PROTOTYPE(void usage, (void));
_PROTOTYPE(int main, (int argc, char *argv[]));
_PROTOTYPE(void malloc_chk, (void *p));


/* For -s flag that builds the list as it goes */
int exists(head, uid)		/* See if uid already exists.    */
USEREC *head;			/* In -s list disallow dupes. */
Uid_t uid;
{
  USEREC *curs;
  for (curs = head; curs != NULL; curs = curs->next)
	if (curs->uid == uid) return(TRUE);
  return(FALSE);
}

void insert(head, rec)		/* Sorted by uid (keep duplicates)   */
USEREC **head;			/* Normally there should be none but */
USEREC *rec;			/* I wanted option to see them...    */
{
  if (*head == NULL) {
	rec->next = *head;
	*head = rec;
#ifdef REMOVE_DUPES
  } else if ((*head)->uid == rec->uid) {
	return;
#endif
  } else if ((*head)->uid > rec->uid) {
	rec->next = *head;
	*head = rec;
  } else
	insert(&((*head)->next), rec);
}

void make_userlist()
{				/* Make list of known users.  */
  FILE *fp1;			/* do not remove duplicates   */
  USEREC *temp_rec;		/* however the blocks will    */
  char line[PWLEN];		/* counted against first name */
  char *p1;
  size_t name_length;

  fp1 = fopen(passwd, "r");
  while (!feof(fp1)) {
	if (fgets(line, PWLEN, fp1)) {
		temp_rec = (USEREC *) malloc(sizeof(USEREC));
		malloc_chk(temp_rec);
		p1 = line;
		name_length = 0;
		while (*p1 && *p1 != ':') {
			p1++;
			name_length++;
		}
		*p1++ = '\0';
		temp_rec->name = (char *) malloc(name_length + 1);
		malloc_chk(temp_rec);
		strcpy(temp_rec->name, line);
		while (*p1 && *p1 != ':') p1++;	/* skip passwd */
		temp_rec->uid = atoi(++p1);
		temp_rec->blocks = 0L;
		insert(&list_head, temp_rec);
	}
  }
  fclose(fp1);
}

void showlist()
{
  USEREC *curs;
  for (curs = list_head; curs != NULL; curs = curs->next)
	printf("%d\t%-14s\t%ld\n", curs->uid, curs->name, curs->blocks);
}

int update_list(uid, bytes)	/* Increment uid's total.   */
Uid_t uid;			/* If uid has duplicates    */
off_t bytes;			/* will be charged to first. */
{
  USEREC *curs;
  int found = 0;
  for (curs = list_head; curs != NULL; curs = curs->next) {
	if (curs->uid == uid) {
		found++;
		curs->blocks += (bytes + 1024 - 1) / 1024;	/* ceiling */
		break;
	}
  }
  return(found);		/* -u and -v option need to know */
}

/* Traverse recursively: all directories on volume. */
void search_all(cur_dir)		/* If another volume is mounted on this vol */
char *cur_dir;			/* only the files really on this volume are */
{				/* to be counted in the accumulated total.  */
  struct dirent *this_file;
  DIR *dp1;			/* Activation record 4 pointers 1 int so */
  char *next_entry;		/* should be able to recurse very deep.  */
  int dir_length;		/* Uses malloc and free for temporary space */
  int s;

  dir_length = strlen(cur_dir);
  next_entry = (char *) malloc(strlen(cur_dir) + NAME_MAX + 2);
  malloc_chk(next_entry);
  strcpy(next_entry, cur_dir);
  if (next_entry[dir_length - 1] != '/') {
	strcat(next_entry, "/");
	dir_length++;
  }
  dp1 = opendir(cur_dir);
  if (dp1 == NULL) {
	fprintf(stderr, "Opendir returned NULL.  (%s).\n", strerror(errno));
	exit(EXIT_FAILURE);
  }
  while ((this_file = readdir(dp1)) != NULL) {
	/* Iterate through this directory */
	if (strcmp(this_file->d_name, ".") &&
	    strcmp(this_file->d_name, "..")) {
		strcpy(&next_entry[dir_length], this_file->d_name);
		stat(next_entry, &this_stat);
		if (real_dev != this_stat.st_dev) continue;
		if (iflag) {
			if (ilist_search(next_entry)) continue;
		}
		if (S_ISDIR(this_stat.st_mode)) {
			/* Is a directory need to recurse */
			s = update_list((Uid_t) this_stat.st_uid, 
							   this_stat.st_size);
			if (!s) {
				if (verbose) fprintf(stderr,
						"%s: Directory, No Owner, %s\n",
					      progname, next_entry);
				if (uflag) fprintf(ufd, "%s %d %d\n",
						spec_name,
						this_stat.st_ino,
						this_stat.st_uid);
			}
			search_all(next_entry);	/* recursive call */
		} else {
			/* Is regular file or spec. file */
			if (S_ISREG(this_stat.st_mode)) {
				s = update_list((Uid_t) this_stat.st_uid,
							   this_stat.st_size);
				if (!s) {
					if (verbose) fprintf(stderr,
							"%s: File, No Owner, %s\n",
							progname, next_entry);
					if (uflag) fprintf(ufd, "%s %d %d\n",
						spec_name, this_stat.st_ino,
						this_stat.st_uid);
				}	/* endif !update */
			}	/* end S_ISREG */
			/* Ignores any Specials: b, c, pipe, etc. */
		}		/* endelse */
	}			/* endif "." */
  }				/* endwhile */
  closedir(dp1);
  free(next_entry);
}

int ilist_search(path)
char *path;
{
  IGNREC *ptr;
  for (ptr = ign_head; ptr != NULL; ptr = ptr->next) {
	if (!strcmp(&path[mountlength], ptr->structname)) return(TRUE);
  }
  return(FALSE);
}

void usage()
{
  fprintf(stderr,
   "Usage: %s [-p file] [-s] [-u file] [-v] [spec file]\n", progname);
  exit(EXIT_FAILURE);
}

/* Later be sure have counted the directory file sizes too ! */
int main(argc, argv)
int argc;
char *argv[];
{
  FILE *mtb;
  FILE *dskusg;
  USEREC *m_rec;
  IGNREC *i_temp;
  char line[PLENGTH];
  char mountedon[PLENGTH];
  char mf1[PLENGTH], mf2[PLENGTH], mf3[PLENGTH], mf4[PLENGTH], mf5[PLENGTH];
  char *p1, *p2, *p3;
  int r;
  size_t siz;
  uid_t m_uid;
  long m_blocks;
  unsigned scan_uid;
  progname = argv[0];
  argc--;
  argv++;
  while (argv[0] != NULL && argv[0][0] == '-') {
	switch (argv[0][1]) {
	    case 'p':
		if (argc > 1) passwd = argv[1];
		argc--;
		argv++;
		break;
	    case 'v':	verbose++;	break;
	    case 'u':
		if (argc > 1) {
			ufile = argv[1];
			uflag++;
			argc--;
			argv++;
			break;
		} else
			usage();
	    case 'i':
		if (argc > 1) {
			ilist = argv[1];
			iflag++;
			argc--;
			argv++;
			break;
		} else
			usage();
	    case 's':	sflag++;	break;
	    default:	usage();
	}
	/* Else spec file ? */

	argc--;
	argv++;
  }				/* end while '-' */
  if (!argc) {
	fprintf(stderr, "Usage: %s special\n", progname);
	exit(EXIT_FAILURE);
  }
  if (!sflag) make_userlist();
  if (iflag) {			/* parse the ignore string and make list */
	p1 = p2 = ilist;
	if (!*p1) {
		fprintf(stderr, "%s: Bad -i list\n", progname);
		exit(EXIT_FAILURE);
	}
	while (*p1) {
		while (*p1 && !isspace(*p1) && *p1 != ',') p1++;
		if (*p1) {
			*p1 = '\0';
			p1++;
			while (isspace(*p1)) p1++;
		}
		i_temp = (IGNREC *) malloc(sizeof(IGNREC));
		malloc_chk(i_temp);
		siz = strlen(p2) + 1;
		p3 = (char *) malloc(siz);
		malloc_chk(p3);
		i_temp->structname = p3;
		strcpy(i_temp->structname, p2);
		p2 = p1;
		i_temp->next = ign_head;	/* just stack'em */
		ign_head = i_temp;
	}			/* end while */
  }				/* if iflag */
  if (uflag && !sflag) ufd = fopen(ufile, "w");

/* While there are more "files" to this command */
  while (argc > 0) {		/* more to do */
	spec_name = argv[0];
	argc--;
	argv++;

	/* Option -s sum values from previous diskusg output */
	if (sflag) {
		/* Read output of previous diskusg output and total it */
		if ((dskusg = fopen(spec_name, "r")) == NULL) {
			fprintf(stderr, "%s: -s open failed on %s\n", progname, spec_name);
			exit(EXIT_FAILURE);
		}
		while (fgets(line, PLENGTH, dskusg)) {
			sscanf(line, "%u%s%ld", &scan_uid, mf1, &m_blocks);
			m_uid = scan_uid;
			if (!exists(list_head, m_uid)) {
				m_rec = (USEREC *) malloc(sizeof(USEREC));
				malloc_chk(m_rec);
				m_rec->name = (char *) malloc(strlen(mf1) + 1);
				malloc_chk(m_rec->name);
				strcpy(m_rec->name, mf1);
				m_rec->uid = m_uid;
				m_rec->blocks = 0L;
				insert(&list_head, m_rec);
			}	/* if !exist */
			update_list((Uid_t) m_uid,
				    (off_t) 1024 * m_blocks);
		}		/* while fgets */
		fclose(dskusg);
		continue;	/* go on to next "while" file */
	}			/* if sflag */
	/* Search all the files on the special device (not option -s) */
	stat(spec_name, &this_stat);	/* will ignore "mounted on
					 * spec.dev" */
	real_dev = this_stat.st_rdev;	/* using only files really on
					 * device */
	/* See if is block special */
	if (!S_ISBLK(this_stat.st_mode)) usage();

	/* See if device is mounted already by searching mtab (old or new) */
	if ((mtb = fopen("/etc/mtab", "r")) == NULL) {
		fprintf(stderr, "%s: No /etc/mtab found.\n", progname);
		exit(EXIT_FAILURE);
	}
	mountedon[0] = '\0';
	while (!feof(mtb)) {	/* see if mounted already */
		if (fgets(line, PLENGTH, mtb)) {
			mf1[0] = mf2[0] = mf3[0] = mf4[0] = mf5[0] = '\0';
			r = sscanf(line, "%s%s%s%s%s", mf1, mf2, mf3, mf4, mf5);
			if (!strcmp(spec_name, mf1)) {
				if (r > 4)
					strcpy(mountedon, mf5);	/* hmmm.. old mtab */
				else {
					if (!strcmp(mf3, "root"))
						strcpy(mountedon, "/");	/* old mtab */
					else
						strcpy(mountedon, mf2);	/* new mtab */
				}
				break;
			}
		}
	}
	fclose(mtb);
	if (!mountedon[0]) {	/* not mounted so mount temporarily */
		strcpy(mountedon, "tmpXXXXXX");
		mktemp(mountedon);
		if (mkdir(mountedon, 0700)) {
			fprintf(stderr, "%s: Can not make a temporary directory in pwd\n", progname);
			exit(EXIT_FAILURE);
		}
		if (mount(spec_name, mountedon, 1)) {	/* read only */
			rmdir(mountedon);	/* clean up before leaving */
			if (geteuid() != 0) {
				fprintf(stderr, "%s: Must run as root in order to mount %s\n", progname, spec_name);
				exit(EXIT_FAILURE);
			}
			fprintf(stderr, "%s: Could not mount %s\n", progname, spec_name);
			exit(EXIT_FAILURE);
		}
		didmount = TRUE;
	}
	mountlength = strlen(mountedon);	/* Note: means -i names
						 * begin with / */
	search_all(mountedon);	/* call the "traverse and accumulate"
				 * routine */
	if (didmount) {
		umount(spec_name);
		rmdir(mountedon);
		didmount = FALSE;
	}
	spec_name[0] = '\0';
	mountedon[0] = '\0';
  }				/* while argc > 0 .. spec_name */
  if (uflag && !sflag) fclose(ufd);
  showlist();			/* list results to stdout */
  return(EXIT_SUCCESS);
}

void malloc_chk(ptr)
void *ptr;
{
  if (ptr == NULL) {
	fprintf(stderr, 
		  "Malloc returned NULL.  Use chmem to allocate more stack\n");
	exit(EXIT_FAILURE);
  }
}
