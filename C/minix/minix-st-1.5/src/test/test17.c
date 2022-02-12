/* Comment on usage and program: ark!/mnt/rene/prac/os/unix/comment.changes */

/* "const.h", created by Rene Montsma and Menno Wilcke */


#include <sys/types.h>		/* type defs */
#include <sys/stat.h>		/* struct stat */
#include <errno.h>		/* the error-numbers */
#include <fcntl.h>
#include <unistd.h>

#define NOCRASH 1		/* test11(), 2nd pipe */
#define PDPNOHANG  1		/* test03(), write_standards() */

#define USER_ID   12
#define GROUP_ID   1
#define FF        3		/* first free filedes. */
#define USER      1		/* uid */
#define GROUP     0		/* gid */

#define ARSIZE   256		/* array size */
#define PIPESIZE 3584		/* maximum number of bytes to be * written on
			 * pipe               */

#define MAXOPEN  17		/* maximum number of extra open files */

#define MAXLINK 0177		/* maximum number of links per file */
#define LINKCOUNT 5

#define MASK    0777		/* selects lower nine bits */

#define END_FILE     0		/* returned by read-call at eof */

#define OK      0
#define FAIL   -1

#define R       0		/* read (open-call) */
#define W       1		/* write (open-call) */
#define RW      2		/* read & write (open-call) */

#define RWX     7		/* read & write & execute (mode) */

#define NIL     ""
#define UMASK   "umask"
#define CREAT   "creat"
#define WRITE   "write"
#define READ    "read"
#define OPEN    "open"
#define CLOSE   "close"
#define LSEEK   "lseek"
#define ACCESS  "access"
#define CHDIR   "chdir"
#define CHMOD   "chmod"
#define LINK    "link"
#define UNLINK  "unlink"
#define PIPE    "pipe"
#define STAT    "stat"
#define FSTAT   "fstat"
#define DUP     "dup"
#define UTIME   "utime"

extern int errno;		/* the error-number */
int errct;

long lseek();

char *file[];
extern char *strcpy(), *strcat();
char *fnames[];
char *dir[];

/* "decl.c", created by Rene Montsma and Menno Wilcke */

/* Used in open_alot, close_alot */
char *file[20] = {"f0", "f1", "f2", "f3", "f4", "f5", "f6",
	  "f7", "f8", "f9", "f10", "f11", "f12", "f13",
	  "f14", "f15", "f16", "f17", "f18", "f19"}, *fnames[8] = {"---", "--x", "-w-", "-wx", "r--",
								   "r-x", "rw-", "rwx"}, *dir[8] = {"d---", "d--x", "d-w-", "d-wx", "dr--", "dr-x",
						    "drw-", "drwx"};
 /* Needed for easy creating and deleting of directories */

/* "test.c", created by Rene Montsma and Menno Wilcke */


/*****************************************************************************
 *                              TEST                                         *
 ****************************************************************************/
main(argc, argv)
int argc;
char *argv[];
{
  int n, mask;

  mask = (argc == 2 ? atoi(argv[1]) : 0xFFFF);

  if (fork()) {
	printf("Test 17 ");

	wait(&n);
	clean_up_the_mess();
	if (errct == 0)
		printf("ok\n");
	else
		printf("%d errors\n", errct);
	exit(0);
  } else {
	test(mask);
	exit(0);
  }
}



test(mask)
int mask;
{
  int n;
  umask(0);			/* not honest, but i always forget */

  if (mask & 00001) test01();
  if (mask & 00002) make_and_fill_dirs();
  if (mask & 00004) test02();
  if (mask & 00010) test08();
  if (mask & 00020) test09();
  if (mask & 00040) test10();
  if (mask & 00100) test11();
  if (mask & 00200) test12();
  if (mask & 00400) test13();
  if (mask & 01000) test14();
  umask(022);
}				/* test */






/* "t1.c" created by Rene Montsma and Menno Wilcke */

/*****************************************************************************
 *                              test UMASK                                   *
 ****************************************************************************/
test01()
{
  int oldvalue, newvalue, tempvalue;
  int nr;

  if ((oldvalue = umask(0777)) != 0) err(0, UMASK, NIL);

  /* Special test: only the lower 9 bits (protection bits) may part- *
   * icipate. ~0777 means: 111 000 000 000. Giving this to umask must*
   * not change any value.                                           */

  if ((newvalue = umask(~0777)) != 0777) err(1, UMASK, "illegal");
  if (oldvalue == newvalue) err(11, UMASK, "not change mask");

  if ((tempvalue = umask(0)) != 0) err(2, UMASK, "values");


  /* Now test all possible modes of umask on a file */
  for (newvalue = MASK; newvalue >= 0; newvalue -= 0111) {
	tempvalue = umask(newvalue);
	if (tempvalue != oldvalue) {
		err(1, UMASK, "illegal");
		break;		/* no use trying more */
	} else if ((nr = creat("file01", 0777)) < 0)
		err(5, CREAT, "'file01'");
	else {
		try_close(nr, "'file01'");
		if (get_mode("file01") != (MASK & ~newvalue))
			err(7, UMASK, "mode computed");
		try_unlink("file01");
	}
	oldvalue = newvalue;
  }

  /* The loop has terminated with umask(0) */
  if ((tempvalue = umask(0)) != 0)
	err(7, UMASK, "umask may influence rest of tests!");
}				/* test01 */



/*****************************************************************************
 *                              test CREAT                                   *
 ****************************************************************************/
test02()
{
  int n, n1, mode;
  char a[ARSIZE], b[ARSIZE];
  struct stat stbf1;

  mode = 0;
  /* Create twenty files, check filedes */
  for (n = 0; n < MAXOPEN; n++) {
	if (creat(file[n], mode) != FF + n)
		err(13, CREAT, file[n]);
	else {
		if (get_mode(file[n]) != mode)
			err(7, CREAT, "mode set while creating many files");

		/* Change  mode of file to standard mode, we want to *
		 * use a lot (20) of files to be opened later, see   *
		 * open_alot(), close_alot().                        */
		if (chmod(file[n], 0700) != OK) err(5, CHMOD, file[n]);

	}
	mode = (mode + 0100) % 01000;
  }

  /* Already twenty files opened; opening another has to fail */
  if (creat("file02", 0777) != FAIL)
	err(9, CREAT, "created");
  else
	check(CREAT, EMFILE);

  /* Close all files: seems blunt, but it isn't because we've  *
   * checked all fd's already                                  */
  if ((n = close_alot(MAXOPEN)) < MAXOPEN) err(5, CLOSE, "MAXOPEN files");

  /* Creat 1 file twice; check */
  if ((n = creat("file02", 0777)) < 0)
	err(5, CREAT, "'file02'");
  else {
	init_array(a);
	if (write(n, a, ARSIZE) != ARSIZE) err(1, WRITE, "bad");

	if ((n1 = creat("file02", 0755)) < 0)	/* receate 'file02' */
		err(5, CREAT, "'file02' (2nd time)");
	else {
		/* Fd should be at the top after recreation */
		if (lseek(n1, 0L, SEEK_END) != 0)
			err(11, CREAT, "not truncate file by recreation");
		else {
			/* Try to write on recreated file */
			clear_array(b);

			if (lseek(n1, 0L, SEEK_SET) != 0)
				err(5, LSEEK, "to top of 2nd fd 'file02'");
			if (write(n1, a, ARSIZE) != ARSIZE)
				err(1, WRITE, "(2) bad");

			/* In order to read we've to close and open again */
			try_close(n1, "'file02'  (2nd creation)");
			if ((n1 = open("file02", RW)) < 0)
				err(5, OPEN, "'file02'  (2nd recreation)");

			/* Continue */
			if (lseek(n1, 0L, SEEK_SET) != 0)
				err(5, LSEEK, "to top 'file02'(2nd fd) (2)");
			if (read(n1, b, ARSIZE) != ARSIZE)
				err(1, READ, "wrong");

			if (comp_array(a, b, ARSIZE) != OK) err(11, CREAT,
				    "not really truncate file by recreation");
		}
		if (get_mode("file02") != 0777)
			err(11, CREAT, "not maintain mode by recreation");
		try_close(n1, "recreated 'file02'");

	}
	remove(n, "file02");
  }

  /* Give 'creat' wrong input: dir not searchable */
  if (creat("drw-/file02", 0777) != FAIL)
	err(4, CREAT, "'drw-'");
  else
	check(CREAT, EACCES);

  /* Dir not writable */
  if (creat("dr-x/file02", 0777) != FAIL)
	err(12, CREAT, "'dr-x/file02'");
  else
	check(CREAT, EACCES);

  /* File not writable */
  if (creat("drwx/r-x", 0777) != FAIL)
	err(11, CREAT, "recreate non-writable file");
  else
	check(CREAT, EACCES);

  /* Try to creat a dir */
  if ((n = creat("dir", 040777)) != FAIL) {
	if (fstat(n, &stbf1) != OK)
		err(5, FSTAT, "'dir'");
	else if (stbf1.st_mode != 0100777)
		err(11, CREAT, "'creat' a new directory");
	remove(n, "dir");
  }

  /* We don't consider it to be a bug when creat * does not accept
   * tricky modes                */

  /* File is an existing dir */
  if (creat("drwx", 0777) != FAIL)
	err(11, CREAT, "create an existing dir!");
  else
	check(CREAT, EISDIR);
}				/* test02 */






test08()
{


  /* Test chdir to searchable dir */
  if (chdir("drwx") != OK)
	err(5, CHDIR, "to accessible dir");
  else if (chdir("..") != OK)
	err(11, CHDIR, "not return to '..'");


  /* Check the chdir(".") and chdir("..") mechanism */
  if (chdir("drwx") != OK)
	err(5, CHDIR, "to 'drwx'");
  else {
	if (chdir(".") != OK) err(5, CHDIR, "to working dir (.)");

	/* If we still are in 'drwx' , we should be able to access *
	 * file 'rwx'.                                              */
	if (access("rwx", 0) != OK) err(5, CHDIR, "rightly to '.'");

	/* Try to return to previous dir ('/' !!) */
	if (chdir("././../././d--x/../d--x/././..") != OK)
		err(5, CHDIR, "to motherdir (..)");

	/* Check whether we are back in '/' */
	if (chdir("d--x") != OK) err(5, CHDIR, "rightly to  a '..'");
  }

  /* Return to '..' */
  if (chdir("..") != OK) err(5, CHDIR, "to '..'");

  if (chdir("././././drwx") != OK)
	err(11, CHDIR, "not follow a path");
  else if (chdir("././././..") != OK)
	err(11, CHDIR, "not return to path");

  /* Try giving chdir wrong parameters */
  if (chdir("drwx/rwx") != FAIL)
	err(11, CHDIR, "chdir to a file");
  else
	check(CHDIR, ENOTDIR);

  if (chdir("drw-") != FAIL)
	err(4, CHDIR, "'/drw-'");
  else
	check(CHDIR, EACCES);



  /* To be sure: return to root */
  /* If (chdir("/") != OK) err(5, CHDIR, "to '/' (2nd time)"); */
}				/* test08 */



/* New page */
/*****************************************************************************
 *                              test CHMOD                                   *
 ****************************************************************************/
test09()
{

  int n;

  /* Prepare file09 */
  if ((n = creat("drwx/file09", 0644)) != FF) err(5, CREAT, "'drwx/file09'");

  try_close(n, "'file09'");

  /* Try to chmod a file, check and restore old values, check */
  if (chmod("drwx/file09", 0700) != OK)
	err(5, CHMOD, "'drwx/file09'");	/* set rwx */
  else {
	/* Check protection */
	if (get_mode("drwx/file09") != 0700) err(7, CHMOD, "mode");

	/* Test if chmod accepts just filenames too */
	if (chdir("drwx") != OK)
		err(5, CHDIR, "to '/drwx'");
	else if (chmod("file09", 0177) != OK)	/* restore oldies */
		err(5, CHMOD, "'h1'");
	else
		/* Check if value has been restored */
	if (get_mode("../drwx/file09") != 0177)
		err(7, CHMOD, "restored mode");
  }

  /* Try setid and setgid */
  if ((chmod("file09", 04777) != OK) || (get_mode("file09") != 04777))
	err(11, CHMOD, "not set uid-bit");
  if ((chmod("file09", 02777) != OK) || (get_mode("file09") != 02777))
	err(11, CHMOD, "not set gid-bit");

  /* Remove testfile */
  try_unlink("file09");

  if (chdir("..") != OK) err(5, CHDIR, "to '..'");


  /* Try to chmod directory */
  if (chmod("d---", 0777) != OK)
	err(5, CHMOD, "dir 'd---'");
  else {
	if (get_mode("d---") != 0777) err(7, CHMOD, "protection value");
	if (chmod("d---", 0000) != OK) err(5, CHMOD, "dir 'a' 2nd time");

	/* Check if old value has been restored */
	if (get_mode("d---") != 0000)
		err(7, CHMOD, "restored protection value");
  }

  /* Try to make chmod failures */

  /* We still are in dir root */
  /* Wrong filename */
  if (chmod("non-file", 0777) != FAIL)
	err(3, CHMOD, NIL);
  else
	check(CHMOD, ENOENT);

}				/* test 09 */


/* New page */




/* "t4.c", created by Rene Montsma and Menno Wilcke */


/*****************************************************************************
 *                              test LINK/UNLINK                             *
 ****************************************************************************/
test10()
{
  int n, n1;
  char a[ARSIZE], b[ARSIZE], *f, *lf;

  f = "file10";
  lf = "linkfile10";

  if ((n = creat(f, 0702)) != FF)	/* no other open files */
	err(13, CREAT, f);
  else {

	/* Now link correctly */
	if (link(f, lf) != OK)
		err(5, LINK, lf);
	else if ((n1 = open(lf, RW)) < 0)
		err(5, OPEN, "'linkfile10'");
	else {
		init_array(a);
		clear_array(b);

		/* Write on 'file10' means being able to    * read
		 * through linked filedescriptor       */
		if (write(n, a, ARSIZE) != ARSIZE) err(1, WRITE, "bad");
		if (read(n1, b, ARSIZE) != ARSIZE) err(1, READ, "bad");
		if (comp_array(a, b, ARSIZE) != OK) err(8, "r/w", NIL);

		/* Clean up: unlink and close (twice): */
		remove(n, f);
		try_close(n1, "'linkfile10'");

		/* Check if "linkfile" exists and the info    * on it
		 * is correct ('file' has been deleted) */
		if ((n1 = open(lf, R)) < 0)
			err(5, OPEN, "'linkfile10'");
		else {
			/* See if 'linkfile' still contains 0..511 ? */

			clear_array(b);
			if (read(n1, b, ARSIZE) != ARSIZE)
				err(1, READ, "bad");
			if (comp_array(a, b, ARSIZE) != OK)
				err(8, "r/w", NIL);

			try_close(n1, "'linkfile10' 2nd time");
			try_unlink(lf);
		}
	}
  }

  /* Try if unlink fails with incorrect parameters */
  /* File does not exist: */
  if (unlink("non-file") != FAIL)
	err(2, UNLINK, "name");
  else
	check(UNLINK, ENOENT);

  /* Dir can't be written */
  if (unlink("dr-x/rwx") != FAIL)
	err(11, UNLINK, "could unlink in non-writable dir.");
  else
	check(UNLINK, EACCES);

  /* Try to unlink a dir being user */
  if (unlink("drwx") != FAIL)
	err(11, UNLINK, "unlink dir's as user");
  else
	check(UNLINK, EPERM);


  /* Try giving link wrong input */

  /* First try if link fails with incorrect parameters * name1 does not
   * exist.                             */
  if (link("non-file", "linkfile") != FAIL)
	err(2, LINK, "1st name");
  else
	check(LINK, ENOENT);

  /* Name2 exists already */
  if (link("drwx/rwx", "drwx/rw-") != FAIL)
	err(2, LINK, "2nd name");
  else
	check(LINK, EEXIST);

  /* Directory of name2 not writable:  */
  if (link("drwx/rwx", "dr-x/linkfile") != FAIL)
	err(11, LINK, "link non-writable  file");
  else
	check(LINK, EACCES);

  /* Try to link a dir, being a user */
  if (link("drwx", "linkfile") != FAIL)
	err(11, LINK, "link a dir without superuser!");
  else
	check(LINK, EPERM);


  /* File has too many links */
  if ((n = link_alot("drwx/rwx")) != LINKCOUNT - 1)	/* file already has one
							 * link */
	err(5, LINK, "many files");
  if (unlink_alot(n) != n) err(5, UNLINK, "all linked files");

}				/* test10 */





link_alot(bigboss)
char *bigboss;
{
  int i;
  char *employee = {"aaaaa"};

  /* Every file has already got 1 link, so link 0176 times */
  for (i = 1; i < LINKCOUNT; i++) {
	if (link(bigboss, employee) != OK)
		break;
	else
		get_new(employee);
  }

  return(i - 1);		/* number of linked files */
}				/* link_alot */


unlink_alot(number)
int number;			/* number of files to be unlinked */
{
  int j;
  char *employee = {"aaaaa"};

  for (j = 0; j < number; j++) {
	if (unlink(employee) != OK)
		break;
	else
		get_new(employee);
  }

  return(j);			/* return number of unlinked files */
}				/* unlink_alot */


get_new(name)
char name[];
 /* Every call changes string 'name' to a string alphabetically          *
  * higher. Start with "aaaaa", next value: "aaaab" .                    *
  * N.B. after "aaaaz" comes "aaabz" and not "aaaba" (not needed).       *
  * The last possibility will be "zzzzz".                                *
  * Total # possibilities: 26+25*4 = 126 = MAXLINK -1 (exactly needed)   */
{

  int i;

  for (i = 4; i >= 0; i--)
	if (name[i] != 'z') {
		name[i]++;
		break;
	}
}				/* get_new */

/* New page */

/*****************************************************************************
 *                              test PIPE                                    *
 ****************************************************************************/
test11()
{
  int n, fd[2];
  char a[ARSIZE], b[ARSIZE];

  if (pipe(fd) != OK)
	err(13, PIPE, NIL);
  else {
	/* Try reading and writing on a pipe */
	init_array(a);
	clear_array(b);

	if (write(fd[1], a, ARSIZE) != ARSIZE)
		err(5, WRITE, "on pipe");
	else if (read(fd[0], b, (ARSIZE / 2)) != (ARSIZE / 2))
		err(5, READ, "on pipe (2nd time)");
	else if (comp_array(a, b, (ARSIZE / 2)) != OK)
		err(7, PIPE, "values read/written");
	else if (read(fd[0], b, (ARSIZE / 2)) != (ARSIZE / 2))
		err(5, READ, "on pipe 2");
	else if (comp_array(&a[ARSIZE / 2], b, (ARSIZE / 2)) != OK)
		err(7, PIPE, "pipe created");

	/* Try to let the pipe make a mistake */
	if (write(fd[0], a, ARSIZE) != FAIL)
		err(11, WRITE, "write on fd[0]");
	if (read(fd[1], b, ARSIZE) != FAIL) err(11, READ, "read on fd[1]");

	try_close(fd[1], "'fd[1]'");

	/* Now we shouldn't be able to read, because fd[1] has been closed */
	if (read(fd[0], b, ARSIZE) != END_FILE) err(2, PIPE, "'fd[1]'");

	try_close(fd[0], "'fd[0]'");
  }
  if (pipe(fd) < 0)
	err(5, PIPE, "2nd time");
  else {
	/* Test lseek on a pipe: should fail */
	if (write(fd[1], a, ARSIZE) != ARSIZE)
		err(5, WRITE, "on pipe (2nd time)");
	if (lseek(fd[1], 10L, SEEK_SET) != FAIL)
		err(11, LSEEK, "lseek on a pipe");
	else
		check(PIPE, ESPIPE);

	/* Eat half of the pipe: no writing should be possible */
	try_close(fd[0], "'fd[0]'  (2nd time)");

	/* This makes UNIX crash: omit it if pdp or VAX */
#ifndef NOCRASH
	if (write(fd[1], a, ARSIZE) != FAIL)
		err(11, WRITE, "write on wrong pipe");
	else
		check(PIPE, EPIPE);
#endif
	try_close(fd[1], "'fd[1]'  (2nd time)");
  }

  /* BUG :                                                            *
   * Here we planned to test if we could write 4K bytes on a pipe.    *
   * However, this was not possible to implement, because the whole   *
   * Monix system crashed when we tried to write more then 3584 bytes *
   * (3.5K) on a pipe. That's why we try to write only 3.5K in the    *
   * folowing test.                                                   */
  if (pipe(fd) < 0)
	err(5, PIPE, "3rd time");
  else {
	for (n = 0; n < (PIPESIZE / ARSIZE); n++)
		if (write(fd[1], a, ARSIZE) != ARSIZE)
			err(5, WRITE, "on pipe (3rd time) 4K");
	try_close(fd[1], "'fd[1]' (3rd time)");

	for (n = 0; n < (PIPESIZE / ARSIZE); n++)
		if (read(fd[0], b, ARSIZE) != ARSIZE)
			err(5, READ, "from pipe (3rd time) 4K");
	try_close(fd[0], "'fd[0]' (3rd time)");
  }

  /* Test opening a lot of files */
  if ((n = open_alot()) != MAXOPEN) err(5, OPEN, "MAXOPEN files");
  if (pipe(fd) != FAIL)
	err(9, PIPE, "open");
  else
	check(PIPE, EMFILE);
  if (close_alot(n) != n) err(5, CLOSE, "all opened files");
}				/* test11 */


/* New page */

/*****************************************************************************
 *                              test STAT/FSTAT                              *
 ****************************************************************************/
test12()
{

  struct stat stbf1, stbf2;
  int n, n1;
  char a[ARSIZE];


  /* We now consecutively test after OPEN, CREAT, DUP, PIPE */

  /* Test after a CREAT */
  if ((n = creat("file12", 0702)) != FF)	/* no other open files left */
	err(5, CREAT, "'file12'");
  if (fstat(n, &stbf1) < 0)
	err(5, FSTAT, "'file12'");
  else {
	if (stbf1.st_mode != 0100702) err(7, FSTAT, "mode");
	if (stbf1.st_nlink != 1) err(7, FSTAT, "nlink");
	if (stbf1.st_size != 0L) err(7, FSTAT, "size");

	if (stat("file12", &stbf2) < 0)
		err(5, STAT, "'file12'");
	else
		comp_stats(&stbf1, &stbf2);	/* 'stat' & 'fstat'
						 * should deliver * the
						 * same information            */
  }
  try_close(n, "'file12'");

  /* Test after OPEN */
  /* Prepare */
  if (link("file12", "linkfile12") < 0) err(5, LINK, "'linkfile12'");
  if ((n1 = open("linkfile12", RW)) < 0)
	err(5, OPEN, "'linkfile12'");
  else {
	/* Give linkfile information */
	init_array(a);
	if (write(n1, a, ARSIZE) != ARSIZE) err(5, WRITE, "'linkfile12'");

	try_close(n1, "'linkfile12'");
  }


  if (stat("file12", &stbf1) < 0)
	err(5, STAT, "'file12'");
  else {
	if (stbf1.st_mode != 0100702) err(7, STAT, "mode");
	if (stbf1.st_nlink != 2) err(7, STAT, "nlink");
	if (stbf1.st_size != ((long) (ARSIZE))) err(7, STAT, "size");

	if ((n1 = open("linkfile12", RW)) < 0)
		err(5, OPEN, "'linkfile12' (2nd time)");

	if (fstat(n1, &stbf2) < 0)
		err(5, FSTAT, "'linkfile12'");
	else
		comp_stats(&stbf1, &stbf2);	/* should be equal */

	try_close(n1, "'linkfile12'");
  }

  /* Test after a DUP */
  if ((n = open("file12", RW)) < 0) err(5, OPEN, "'file12'");
  if ((n1 = dup(n)) < 0)
	err(5, DUP, "'file12'");
  else {
	if (fstat(n1, &stbf2) < 0)
		err(5, FSTAT, "duplicated fd 'file12'");
	else
		comp_stats(&stbf1, &stbf2);
	/* Stbf1 remained from OPEN test */

	try_close(n1, "duplicated fd 'file12'");
  }


  /* Remove testfile */
  remove(n, "file12");

  /* Remove linkfile */
  try_unlink("linkfile12");

  /* Try giving stat wrong input */
  /* First see if stat fails with incorrect input: non-existing file */
  if (stat("non-file", &stbf1) != FAIL)
	err(3, STAT, NIL);
  else
	check(STAT, ENOENT);

  /* Non-accessible file: dir's not searchable */
  if (stat("drw-/rwx", &stbf1) != FAIL)
	err(4, STAT, "'a'");
  else
	check(STAT, EACCES);
}				/* test12 */


comp_stats(stbf1, stbf2)
struct stat *stbf1, *stbf2;
{

  if (stbf1->st_dev != stbf2->st_dev) err(7, "st/fst", "'dev'");
  if (stbf1->st_ino != stbf2->st_ino) err(7, "st/fst", "'ino'");
  if (stbf1->st_mode != stbf2->st_mode) err(7, "st/fst", "'mode'");
  if (stbf1->st_nlink != stbf2->st_nlink) err(7, "st/fst", "'nlink'");
  if (stbf1->st_uid != stbf2->st_uid) err(7, "st/fst", "'uid'");
  if (stbf1->st_gid != stbf2->st_gid) err(7, "st/fst", "'gid'");
  if (stbf1->st_rdev != stbf2->st_rdev) err(7, "st/fst", "'rdev'");
  if (stbf1->st_size != stbf2->st_size) err(7, "st/fst", "'size'");
  if (stbf1->st_atime != stbf2->st_atime) err(7, "st/fst", "'atime'");
  if (stbf1->st_mtime != stbf2->st_mtime) err(7, "st/fst", "'mtime'");
}				/* comp_stats */


/* New page */




/* "t5.c", created by Rene Montsma and Menno Wilcke */


/*****************************************************************************
 *                              test DUP                                     *
 ****************************************************************************/
test13()
{
  int n, n1, i, fd[4];
  char a[ARSIZE], b[ARSIZE];


  /* We consecutively test 'dup' after CREAT, OPEN, PIPE */

  /* Test dup after a CREAT */
  if ((n = creat("file13", 0777)) != FF)	/* no other open files left */
	err(13, CREAT, "'file13'");
  else {
	if ((n1 = dup(n)) != n + 1) err(13, DUP, "dupped 'file13'");
	comp_inodes(n, n1);	/* should point to the same inode */
	try_close(n, "'file13'");
	try_close(n1, "duplicated fd 'file13'");
  }

  /* Now test with correct values with filedes returned from an * OPEN
   * call                                                  */
  if ((n = open("file13", RW)) < 0)
	err(5, OPEN, "'file13'");
  else {
	if ((n1 = dup(n)) != n + 1)
		err(13, DUP, "dupped fd 'file13'");
	else {
		comp_inodes(n, n1);
		try_close(n1, "duplicated 'file13'");
	}
	try_close(n, "'file13'");
  }

  /* Test with correct values after a  PIPE */
  if (pipe(fd) < 0)
	err(5, DUP, NIL);
  else if ((fd[2] = dup(fd[0])) < 0)
	err(5, DUP, "pipe 'fd[0]'");
  else {
	comp_inodes(fd[0], fd[2]);

	if ((fd[3] = dup(fd[1])) < 0)
		err(5, DUP, "pipe 'fd[1]'");
	else
		comp_inodes(fd[1], fd[3]);

	for (i = 0; i < 4; i++) try_close(fd[i], "a filedes");
  }

  /* Try writing and reading */
  if ((n = open("file13", RW)) < 0) err(5, OPEN, "'file13' 3rd time");
  if ((n1 = dup(n)) != n + 1)
	err(13, DUP, "dupped 'file13' 2nd time");
  else {
	init_array(a);
	clear_array(b);

	if (write(n, a, ARSIZE) != ARSIZE) err(1, WRITE, "bad");

	/* Set filedes back to be ready for a read */
	if (lseek(n1, 0L, SEEK_SET) != 0)
		err(5, LSEEK, "to beginning of 'file13'");

	if (read(n1, b, ARSIZE / 2) != ARSIZE / 2) err(1, READ, "bad");
	if (comp_array(a, b, ARSIZE / 2) != OK)
		err(7, DUP, "values read/written");

	clear_array(b);
	if (lseek(n1, 0L, SEEK_SET) != 0L)
		err(5, LSEEK, "to beginning of 'file13 (2nd time)'");
	if (read(n, b, ARSIZE) != ARSIZE) err(1, READ, "bad");
	if (comp_array(a, b, ARSIZE) != OK)
		err(7, DUP, "values read/written (2nd time)");

	try_close(n1, "duplicated fd 'file13'");
  }

  /* Remove testfile */
  remove(n, "file13");

  /* Try giving dup wrong input */

  /* Does dup take care of many open files ? */
  if ((n = open_alot()) != MAXOPEN)
	err(5, OPEN, "MAXOPEN files");
  else if (dup(n) != FAIL)
	err(9, DUP, "open");
  else
	check(DUP, EMFILE);
  if (close_alot(n) != n) err(5, CLOSE, "all opened files");

  /* Try to make dup accept illegal values */
  if ((n1 = dup(-1)) != FAIL)
	err(2, DUP, "filedes");
  else
	check(DUP, EBADF);
  if ((n1 = dup(MAXOPEN)) != FAIL)
	err(7, DUP, "filedes");
  else
	check(DUP, EBADF);
}				/* test13 */





comp_inodes(m, m1)
int m, m1;			/* twee filedes's */
{
  struct stat stbf1, stbf2;

  if (fstat(m, &stbf1) == OK)
	if (fstat(m1, &stbf2) == OK) {
		if (stbf1.st_ino != stbf2.st_ino)
			err(7, DUP, "inode number");
	} else
		err(100, "comp_inodes", "cannot 'fstat' (m1)");
  else
	err(100, "comp_inodes", "cannot 'fstat' (m)");
}				/* comp_inodes */

/* New page */
/*****************************************************************************
 *                              test UTIME                                   *
 ****************************************************************************/
test14()
{
  int n;
  long oldmtime;
  time_t timep[2];
  struct stat stbf1;

  if ((n = creat("file14", 0777)) != FF)	/* no other open files left */
	err(5, CREAT, "'file14'");
  else {
	if (fstat(n, &stbf1) != OK)
		err(5, FSTAT, "'file14'");
	else
		oldmtime = stbf1.st_mtime;

	/* N.B. We have noticed that the field 'atime' does not
	 * exist,  * but we decided not to mention it as a bug.                   */

	timep[0] = oldmtime - 1;
	timep[1] = oldmtime - 2;
	/* Change inode-info of 'file04' */
	if (utime("file14", timep) != OK)
		err(5, UTIME, "'file14'");
	else
	 /* Check if values in inode have been altered */ if (fstat(n, &stbf1) != OK)
		err(5, FSTAT, "'file14' (2nd time)");
	else if (stbf1.st_mtime != oldmtime - 2)
		err(7, UTIME, "st_mtime");
	remove(n, "file14");
  }


  /* Try giving utime wrong input */
  if (utime("non-file", timep) != FAIL)
	err(3, UTIME, NIL);
  else
	check(UTIME, ENOENT);
}				/* test14 */

access_standards()
{
  int i, mode = 0;

  for (i = 0; i < 8; i++)
	if (i == 0)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++)
	if (i < 2)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++)
	if (i == 0 || i == 2)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++)
	if (i < 4)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++)
	if (i == 0 || i == 4)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++)
	if (i == 0 || i == 1 || i == 4 || i == 5)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++)
	if (i % 2 == 0)
		try_access(fnames[mode], i, OK);
	else
		try_access(fnames[mode], i, FAIL);
  mode++;

  for (i = 0; i < 8; i++) try_access(fnames[mode], i, OK);
}				/* access_standards */



try_access(fname, mode, test)
int mode, test;
char *fname;
{
  if (access(fname, mode) != test)
	err(100, ACCESS, "incorrect access on a file (try_access)");
}				/* try_access */







/* "support.c", created by Rene Montsma and Menno Wilcke */


/* Err, make_and_fill_dirs, init_array, clear_array, comp_array,
   try_close, try_unlink, remove, get_mode, setid, check, open_alot,
   close_alot, clean_up_the_mess.
*/


/***********************************************************************
 *				EXTENDED FIONS			       *
 **********************************************************************/
/* First extended functions (i.e. not oldfashioned monixcalls.
   e(), nlcr(), octal.*/

e(string)
char *string;
{
  printf("Test program error: %s\n", string);
}

nlcr()
{
  printf("\n");
}

str(s)
char *s;
{
  printf(s);
}


/*****************************************************************************
*                                                                            *
*                               ERR(or) messages                             *
*                                                                            *
*****************************************************************************/
err(number, scall, name)
 /* Give nice error messages */

char *scall, *name;
int number;

{
  e("");
  str("\t");
  switch (number) {
      case 0:
	str(scall);
	str(": illegal initial value.");
	break;
      case 1:
	str(scall);
	str(": ");
	str(name);
	str(" value returned.");
	break;
      case 2:
	str(scall);
	str(": accepting illegal ");
	str(name);
	str(".");
	break;
      case 3:
	str(scall);
	str(": accepting non-existing file.");
	break;
      case 4:
	str(scall);
	str(": could search non-searchable dir (");
	str(name);
	str(").");
	break;
      case 5:
	str(scall);
	str(": cannot ");
	str(scall);
	str(" ");
	str(name);
	str(".");
	break;
      case 7:
	str(scall);
	str(": incorrect ");
	str(name);
	str(".");
	break;
      case 8:
	str(scall);
	str(": wrong values.");
	break;
      case 9:
	str(scall);
	str(": accepting too many ");
	str(name);
	str(" files.");
	break;
      case 10:
	str(scall);
	str(": even a superuser can't do anything!");
	break;
      case 11:
	str(scall);
	str(": could ");
	str(name);
	str(".");
	break;
      case 12:
	str(scall);
	str(": could write in non-writable dir (");
	str(name);
	str(").");
	break;
      case 13:
	str(scall);
	str(": wrong filedes returned (");
	str(name);
	str(").");
	break;
      case 100:
	str(scall);		/* very common */
	str(": ");
	str(name);
	str(".");
	break;
      default:	str("errornumber does not exist!\n");
  }
  nlcr();
}				/* err */


/*****************************************************************************
*                                                                            *
*                          MAKE_AND_FILL_DIRS                                *
*                                                                            *
*****************************************************************************/

make_and_fill_dirs()
 /* Create 8 dir.'s: "d---", "d--x", "d-w-", "d-wx", "dr--", "dr-x",     *
  * "drw-", "drwx".                                     * Then create 8 files
  * in "drwx", and some needed files in other dirs.  */
{
  int mode, i;

  for (i = 0; i < 8; i++) {
	mkdir(dir[i], 0700);
	chown(dir[i], USER_ID, GROUP_ID);
  }
  setuid(USER_ID);
  setgid(GROUP_ID);

  for (mode = 0; mode < 8; mode++) put_file_in_dir("drwx", mode);

  put_file_in_dir("d-wx", RWX);
  put_file_in_dir("dr-x", RWX);
  put_file_in_dir("drw-", RWX);

  chmod_8_dirs(8);		/* 8 means; 8 different modes */

}				/* make_and_fill_dirs */

/* This function is not used */
create_8_dirs()
{
  switch (fork()) {
      case -1:
	printf("create_8_dirs: failed fork .\n");
	break;
      case 0:
	execl("/bin/mkdir", "mkdir", "d---", "d--x",
	      "d-w-", "d-wx", "dr--", "dr-x", "drw-", "drwx", 0);
	printf("mkdir: something went wrong.\n");
	exit(1);
      default:
	printf("waiting\n");
	wait(0);
  }
}



put_file_in_dir(dirname, mode)
char *dirname;
int mode;
 /* Fill directory 'dirname' with file with mode 'mode'.   */
{
  int nr;


  if (chdir(dirname) != OK)
	err(5, CHDIR, "to dirname (put_f_in_dir)");
  else {
	/* Creat the file */
	if ((nr = creat(fnames[mode], mode * 0100, 0)) < 0)
		err(13, CREAT, fnames[mode]);
	else
		try_close(nr, fnames[mode]);

	if (chdir("..") != OK)
		err(5, CHDIR, "to previous dir (put_f_in_dir)");
  }
}				/* put_file_in_dir */


/*****************************************************************************
*                                                                            *
*                               MISCELLANEOUS                                *
*                                                                            *
*(all about arrays, 'try_close', 'try_unlink', 'remove', 'get_mode', 'setid')*
*                                                                            *
*****************************************************************************/


init_array(a)
char *a;
{
  int i;

  i = 0;
  while (i++ < ARSIZE) *a++ = 'a' + (i % 26);
}				/* init_array */

clear_array(b)
char *b;
{
  int i;

  i = 0;
  while (i++ < ARSIZE) *b++ = '0';

}				/* clear_array */


int comp_array(a, b, range)
char *a, *b;
int range;
{
  if ((range < 0) || (range > ARSIZE)) {
	err(100, "comp_array", "illegal range");
	return(FAIL);
  } else {
	while (range-- && (*a++ == *b++));
	if (*--a == *--b)
		return(OK);
	else
		return(FAIL);
  }
}				/* comp_array */


try_close(filedes, name)
int filedes;
char *name;
{
  if (close(filedes) != OK) err(5, CLOSE, name);
}				/* try_close */


try_unlink(fname)
char *fname;
{
  if (unlink(fname) != 0) err(5, UNLINK, fname);
}				/* try_unlink */


remove(fdes, fname)
int fdes;
char *fname;
{
  try_close(fdes, fname);
  try_unlink(fname);
}				/* remove */


int get_mode(name)
char *name;
{
  struct stat stbf1;

  if (stat(name, &stbf1) != OK) {
	err(5, STAT, name);
	return(stbf1.st_mode);	/* return a mode which will cause *
				 * error in the calling function  *
				 * (file/dir bit)                 */
  } else
	return(stbf1.st_mode & 07777);	/* take last 4 bits */
}				/* get_mode */

setid(newid)
int newid;
{
  if (setuid(newid) != OK) printf("setid: setuid called.\n");
  /* Err(100, "setid", "cannot change 'uid'"); */
}



/*****************************************************************************
*                                                                            *
*                                  CHECK                                     *
*                                                                            *
*****************************************************************************/


check(scall, number)
int number;
char *scall;
{
  if (errno != number) {
	e(NIL);
	str("\t");
	str(scall);
	str(": bad errno-value: ");
	put(errno);
	str(" should have been: ");
	put(number);
	nlcr();
  }
}				/* check */

put(nr)
int nr;
{
  switch (nr) {
      case 0:	str("unused");	  	break;
      case 1:	str("EPERM");	  	break;
      case 2:	str("ENOENT");	  	break;
      case 3:	str("ESRCH");	  	break;
      case 4:	str("EINTR");	  	break;
      case 5:	str("EIO");	  	break;
      case 6:	str("ENXIO");	  	break;
      case 7:	str("E2BIG");	  	break;
      case 8:	str("ENOEXEC");	  	break;
      case 9:	str("EBADF");	  	break;
      case 10:	str("ECHILD");	  	break;
      case 11:	str("EAGAIN");	  	break;
      case 12:	str("ENOMEM");	  	break;
      case 13:	str("EACCES");	  	break;
      case 14:	str("EFAULT");	  	break;
      case 15:	str("ENOTBLK");	  	break;
      case 16:	str("EBUSY");	  	break;
      case 17:	str("EEXIST");	  	break;
      case 18:	str("EXDEV");	  	break;
      case 19:	str("ENODEV");	  	break;
      case 20:	str("ENOTDIR");	  	break;
      case 21:	str("EISDIR");	  	break;
      case 22:	str("EINVAL");	  	break;
      case 23:	str("ENFILE");	  	break;
      case 24:	str("EMFILE");	  	break;
      case 25:	str("ENOTTY");	  	break;
      case 26:	str("ETXTBSY");	  	break;
      case 27:	str("EFBIG");	  	break;
      case 28:	str("ENOSPC");	  	break;
      case 29:	str("ESPIPE");	  	break;
      case 30:	str("EROFS");	  	break;
      case 31:	str("EMLINK");	  	break;
      case 32:	str("EPIPE");	  	break;
      case 33:	str("EDOM");	  	break;
      case 34:	str("ERANGE");	  	break;
  }
}


/*****************************************************************************
*                                                                            *
*                                ALOT-functions                              *
*                                                                            *
*****************************************************************************/




int open_alot()
{
  int i;

  for (i = 0; i < MAXOPEN; i++)
	if (open(file[i], R) == FAIL) break;
  if (i == 0) err(5, "open_alot", "at all");
  return(i);
}				/* open_alot */


int close_alot(number)
int number;
{
  int i, count = 0;

  if (number > MAXOPEN)
	err(5, "close_alot", "accept this argument");
  else
	for (i = FF; i < number + FF; i++)
		if (close(i) != OK) count++;

  return(number - count);	/* return number of closed files */
}				/* close_alot */


/*****************************************************************************
*                                                                            *
*                         CLEAN UP THE MESS                                  *
*                                                                            *
*****************************************************************************/


clean_up_the_mess()
{
  int i;
  char dirname[6], filename[9], dotdot[60];
  static char comm[60];


  /* First remove 'alot' files */
  for (i = 0; i < MAXOPEN; i++) try_unlink(file[i]);

  /* Unlink the files in dir 'drwx' */
  if (chdir("drwx") != OK)
	err(5, CHDIR, "to 'drwx'");
  else {
	for (i = 0; i < 8; i++) try_unlink(fnames[i]);
	if (chdir("..") != OK) err(5, CHDIR, "to '..'");
  }


  /* Before unlinking files in some dirs, make them writable */
  chmod_8_dirs(RWX);

  /* Unlink files in other dirs */
  try_unlink("d-wx/rwx");
  try_unlink("dr-x/rwx");
  try_unlink("drw-/rwx");

  /* Unlink dirs */
  for (i = 0; i < 8; i++) {
	strcpy(dirname, "d");
	strcat(dirname, fnames[i]);

	/* 'dirname' contains the directoryname */
	rmdir(dirname);
  }

  /* FINISH */
}				/* clean_up_the_mess */

chmod_8_dirs(sw)
int sw;				/* if switch == 8, give all different
			 * mode,else the same mode */
{
  int mode;
  int i;
  static char comm[60], dirname[6], filename[9];

  if (sw == 8)
	mode = 0;
  else
	mode = sw;

  for (i = 0; i < 8; i++) {
	chmod(dir[i], 040000 + mode * 0100);
	if (sw == 8) mode++;
  }
}


strappend(d, s1, s2)
char *d, *s1, *s2;
{
  while (*s1 != 0) *d++ = *s1++;
  while (*s2 != 0) *d++ = *s2++;
  *d = 0;
}


char *strcpy(s1, s2)
register char *s1, *s2;

{
  register char *rp;

  rp = s1;
  while (*s1++ = *s2++);
  return(rp);
}
char *strcat(s1, s2)
register char *s1, *s2;
{
  register char *rp;

  rp = s1;
  while (*s1++);
  --s1;
  while (*s1++ = *s2++);
  return(rp);

}
