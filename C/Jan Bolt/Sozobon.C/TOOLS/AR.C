/* Copyright (c) 1988 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 * 18.05.90 modified by Jan Bolt
 */

long _STKSIZ = 8192;

static	char	Version[] =
"ar: version 1.01  Copyright (c) 1988 by Sozobon, Limited.";

/*
 * ar - archive manipulation program
 */

#include <stdio.h>
#include <fcntl.h>
#include <ar.h>

#ifndef	FALSE
#define	FALSE	(0)
#define	TRUE	!FALSE
#endif

/*
 * Program options
 */
int	vflag = FALSE;	/* verbose option */
int	cflag = FALSE;	/* suppress archive creation message */
int	Vflag = FALSE;	/* print the version message */

/*
 * Basic Command
 */
#define	NONE	0	/* missing command spec */
#define	DELETE	1	/* delete members */
#define	REPLACE	2	/* replace (or add) members */
#define	QAPPEND	3	/* quickly append to the archive */
#define	TABLE	4	/* table of contents */
#define	PRINT	5	/* print a member */
#define	MOVE	6	/* move to the end of the archive */
#define	EXTRACT	7	/* extract members */

int	cmd = 0;	/* the command we're executing */

char	*afile;		/* name of the archive we're messing with */
char	**files;	/* piece of argv starting at the file list */

#define	NAMLEN	14		/* length of a file name in the archive */

#define	TFILE	"ar_tmp.xxx"	/* temp file base name */
char	tfile[128];		/* actual temp file name */

extern	long	lseek();

usage()
{
	fprintf(stderr, "usage: ar {drqtpmx}[vcV] afile [name] ...\n");
	exit(1);
}

main(argc, argv)
int	argc;
char	*argv[];
{
	char	*strrchr();
	register int	status;
	register char	*s;

	if (argc < 2)
		usage();

	s = (argv[1][0] == '-') ? &argv[1][1] : &argv[1][0];

	/*
	 * Get the command character
	 */
	switch (*s) {

	case 'd':
		cmd = DELETE;	break;
	case 'r':
		cmd = REPLACE;	break;
	case 'q':
		cmd = QAPPEND;	break;
	case 't':
		cmd = TABLE;	break;
	case 'p':
		cmd = PRINT;	break;
	case 'm':
		cmd = MOVE;	break;
	case 'x':
		cmd = EXTRACT;	break;
	case 'V':
		Vflag = TRUE;	break;

	default:
		fprintf(stderr, "ar: invalid command character '%c'\n", *s);
		usage();
	}

	/*
	 * Check for optional flags
	 */
	for (++s; *s ;++s) {
		switch (*s) {
		case 'v':
			vflag = TRUE;	break;
		case 'c':
			cflag = TRUE;	break;
		case 'V':
			Vflag = TRUE;	break;
		default:
			fprintf(stderr, "ar: invalid option flag '%c'\n", *s);
			usage();
		}
	}

	if (Vflag)
		printf("%s\n", Version);

	if (argc < 3)
		usage();

	afile = argv[2];
	files = &argv[3];

	/*
	 * Construct the temp file name based on the directory of the
	 * archive file.
	 */
	if (strrchr(afile, '\\') != NULL) {
		strcpy(tfile, afile);
		s = strrchr(tfile, '\\');
		strcpy(s+1, TFILE);
	} else
		strcpy(tfile, TFILE);	/* in the current directory */

	switch (cmd) {

	case DELETE:
		status = dodelete();
		break;

	case REPLACE:
		status = doreplace();
		break;

	case QAPPEND:
		status = doqappend();
		break;

	case TABLE:
		status = dotable();
		break;

	case PRINT:
		status = doprint();
		break;

	case MOVE:
		status = domove();
		break;

	case EXTRACT:
		status = doextract();
		break;

	default:
		fprintf(stderr, "ar: invalid operation\n");
		usage();
	}

	exit(status);
}

error(s)
char	*s;
{
	fprintf(stderr, "ar: fatal error - %s\n", s);
	exit(1);
}

/*
 * inlist(f) - is file 'f' in the file list on the command line?
 */
int
inlist(f)
register char	*f;
{
	register int	i;

	for (i=0; files[i] != NULL ;i++) {
		if (strncmp(f, files[i], NAMLEN) == 0)
			return TRUE;
	}
	return FALSE;
}

/*
 * dellist(f) - remove file 'f' from the command line list
 *
 * We 'delete' an entry by truncating it to zero.
 */
dellist(f)
register char	*f;
{
	register int	i;

	for (i=0; files[i] != NULL ;i++) {
		if (strncmp(f, files[i], NAMLEN) == 0)
			files[i][0] = '\0';
	}
}

/*
 * copy(ofd, nfd, size) - copy a file
 *
 * Copies 'size' bytes from 'ofd' to 'nfd', which must both reference
 * open file descriptors.
 */
#define	BSIZE	8192	/* buffer size */

int
copy(ofd, nfd, size)
register int	ofd, nfd;
long	size;
{
	static	char	buf[BSIZE];
	register int	n;

	for (n = size; n >= BSIZE; n -= BSIZE) {
		if (read(ofd, buf, BSIZE) != BSIZE)
			return FALSE;
		if (write(nfd, buf, BSIZE) != BSIZE) {
			fprintf(stderr, "ar: disk out of space\n");
			return FALSE;
		}
	}

	if (n > 0) {
		if (read(ofd, buf, n) != n)
			return FALSE;
		if (write(nfd, buf, n) != n) {
			fprintf(stderr, "ar: disk out of space\n");
			return FALSE;
		}
	}
	return TRUE;
}

/*
 * chkhdr(fd) - make sure the magic number is right
 */
chkhdr(fd)
int	fd;
{
	int	magic;

	if (read(fd, &magic, 2) != 2)
		error("chkhdr: malformed archive");

	if (magic != ARMAG1 && magic != ARMAG2)
		error("chkhdr: bad magic");
}

/*
 * tostart(fd) - move to the start of the archive
 */
tostart(fd)
int	fd;
{
	lseek(fd, 2L, 0);
}

/*
 * gethdr(fd, a) - read a header at the current file position
 *
 * Returns TRUE on success, FALSE at eof.
 */
int
gethdr(fd, a)
int	fd;
struct	ar_hdr	*a;
{
	if (read(fd, a, ARHSZ) == ARHSZ)
		return (a->ar_name[0] != '\0');
	else
		return FALSE;
}

/*
 * skipit(fd, a) - skip the current archive element
 *
 * Assumes that we're still positioned right after the header.
 * Returns TRUE on success, FALSE on failure.
 */
int
skipit(fd, a)
int	fd;
struct	ar_hdr	*a;
{
	return (lseek(fd, a->ar_size, 1) >= 0);
}

/*
 * moveto(fd, name, ar) - find the object 'name' in the given archive
 *
 * Finds the given element in the archive referenced by the given
 * file desciptor. Leaves the file pointer positioned after the
 * header for the element, at the start of the contents. Return the
 * header via pointer 'ar'.
 *
 * Returns TRUE on success, FALSE if no such name found.
 */
int
moveto(fd, name, ar)
register int	fd;
register char	*name;
register struct	ar_hdr	*ar;
{
	tostart(fd);

	while (gethdr(fd, ar)) {
		if (strncmp(ar->ar_name, name, NAMLEN) == 0)
			return TRUE;
		if (!skipit(fd, ar))
			break;
	}

	return FALSE;
}

/*
 * modestr(mode) - return the string representation of a mode word
 */
char *
modestr(mode)
register int	mode;
{
	static	char	mstr[10];

	mstr[9] = '\0';

	mstr[8] = (mode & 0001) ? 'x' : '-';
	mstr[7] = (mode & 0002) ? 'w' : '-';
	mstr[6] = (mode & 0004) ? 'r' : '-';

	mstr[5] = (mode & 0010) ? 'x' : '-';
	mstr[4] = (mode & 0020) ? 'w' : '-';
	mstr[3] = (mode & 0040) ? 'r' : '-';

	mstr[2] = (mode & 0100) ? 'x' : '-';
	mstr[1] = (mode & 0200) ? 'w' : '-';
	mstr[0] = (mode & 0400) ? 'r' : '-';

	return mstr;
}

/*
 * ropen(f) - open archive 'f' for reading
 *
 * Open the named archive 'read only' and check the magic word.
 */
int
ropen(f)
char	*f;
{
	register int	fd;

	if ((fd = open(f, O_RDONLY)) < 0)
		return -1;

	chkhdr(fd);

	return fd;
}

/*
 * wopen(f) - open archive 'f' for writing
 *
 * If the archive already exists, open it and check it's magic.
 * If it doesn't exists, create it, and write a valid magic word.
 */
int
wopen(f, domsg)
char	*f;
int	domsg;
{
	register int	fd;
	int	magic;

	if ((fd = open(f, O_RDWR)) < 0) {	/* doesn't exist */
		if ((fd = creat(f, 0)) < 0) {
			fprintf(stderr, "ar: can't create archive '%s'\n", f);
			exit(1);
		}
		if (!cflag && domsg)
			printf("ar: creating archive '%s'\n", f);

		magic = ARMAG1;
		write(fd, &magic, 2);
	} else
		chkhdr(fd);

	return fd;
}

/*
 * wclose(f) - close archive opened with wopen.
 *
 * Write four null bytes to the end of the archive and then close
 * it. This doesn't bother anyone, and seems to make one of the
 * utilities with the 'aln' linker happy.
 */
int
wclose(fd)
int	fd;
{
	long	foo = 0;

	write(fd, &foo, 4);
	close(fd);
}

/*
 * putfile(fd, f, achar) - write file 'f' to an open archive file
 *
 * The file named by 'f' is written as an archive member to the open
 * file descriptor 'fd'. The "action" character 'achar' is used to
 * print a message if the verbose option is set.
 */
putfile(fd, f, achar)
register int	fd;
register char	*f;
char	achar;
{
	register int	xfd;
	struct	ar_hdr	a;
	register long	size;
	char	null = 0;

	if ((xfd = open(f, O_RDONLY)) < 0) {
		printf("%s: can't open\n", f);
		return;
	}
	strncpy(a.ar_name, f, NAMLEN);
	a.ar_date = 0;
	a.ar_uid = 0;
	a.ar_gid = 0;
	a.ar_mode = 0666;
	a.ar_fill = 0;
	/*
	 * Get the size of the file by doing an lseek. This is
	 * easier and more portable than doing the equivalent
	 * of an fstat().
	 */
	a.ar_size = size = lseek(xfd, 0L, 2);

	/*
	 * If the file size is odd, pad it out with an extra
	 * byte to be compatible with the Alcyon ar68.prg
	 */
	if (size & 1)
		a.ar_size++;

	if (write(fd, &a, ARHSZ) != ARHSZ)
		error("ar: can't write to archive");

	if (vflag)
		printf("%c %s\n", achar, f);

	lseek(xfd, 0L, 0);		/* rewind */
	if (!copy(xfd, fd, size))
		error("ar: can't write to archive");

	close(xfd);

	if (size != a.ar_size)		/* need a pad byte? */
		write(fd, &null, 1);
}

/*
 * Functions to perform the basic commands
 */

int
dodelete()
{
	register int	fd, tfd;
	register int	i;
	struct	ar_hdr	a;

	if (files[0] == NULL)	/* no work to do */
		return 0;

	tfd = wopen(tfile, FALSE);

	if ((fd = ropen(afile)) < 0)
		error("can't read archive");

	while (gethdr(fd, &a)) {

		if (inlist(a.ar_name)) {

			/*
			 * Skip over the copy in the original archive.
			 */
			if (!skipit(fd, &a)) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("delete: malformed archive");
			}
			if (vflag)
				printf("d %s\n", a.ar_name);

			dellist(a.ar_name);
	
		} else {	/* copy from the old archive */

			if (write(tfd, &a, ARHSZ) != ARHSZ) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("delete: can't write to archive");
			}
			copy(fd, tfd, a.ar_size);
		}
	}
	close(fd);
	wclose(tfd);

	/*
	 * Note any files not found
	 */
	for (i=0; files[i] != NULL ;i++) {
		if (files[i][0] != '\0')
			printf("%s: not found\n", files[i]);
	}

	/*
	 * Unlink the original archive and rename the
	 * temp file on top of it.
	 */
	unlink(afile);
	rename(tfile, afile);

	return 0;
}

int
doreplace()
{
	register int	fd, tfd;
	register int	i;
	struct	ar_hdr	a;

	if (files[0] == NULL)	/* no work to do */
		return 0;

	tfd = wopen(tfile, FALSE);

	/*
	 * If there's no current archive, skip the section dealing
	 * with updates, and just append the named files to the
	 * newly created archive.
	 */
	if ((fd = ropen(afile)) < 0) {
		if (!cflag)
			printf("ar: creating archive '%s'\n", afile);
		goto append;
	}

	while (gethdr(fd, &a)) {

		if (inlist(a.ar_name)) {

			/*
			 * Skip over the old copy in the original archive.
			 */
			if (!skipit(fd, &a)) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("doreplace: malformed archive");
			}

			putfile(tfd, a.ar_name, 'r');

			dellist(a.ar_name);

		} else {	/* copy from the old archive */

			if (write(tfd, &a, ARHSZ) != ARHSZ) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("replace: can't write to archive");
			}
			copy(fd, tfd, a.ar_size);
		}
	}
	close(fd);

	/*
	 * Now go back through the file list and append any files
	 * that didn't turn up in the old archive.
	 */
append:
	for (i=0; files[i] != NULL ;i++) {
		if (files[i][0] != '\0')	/* wasn't deleted before */
			putfile(tfd, files[i], 'a');
	}
	wclose(tfd);

	/*
	 * Unlink the original archive and rename the
	 * temp file on top of it.
	 */
	unlink(afile);
	rename(tfile, afile);

	return 0;
}

int
doqappend()
{
	register int	fd;
	register int	i;
	struct	ar_hdr	a;
	long	fpos;

	if (files[0] == NULL)	/* no work to do */
		return 0;

	fd = wopen(afile, TRUE);

	/*
	 * Get positioned just after the last member
	 */
	fpos = 2;
	while (gethdr(fd, &a)) {
		if (!skipit(fd, &a))
			error("doqappend: malformed archive");
		fpos = lseek(fd, 0L, 1);
	}
	/*
	 * Go back to the end of the last valid archive member
	 */
	lseek(fd, fpos, 0);

	for (i=0; files[i] != NULL ;i++)
		putfile(fd, files[i], 'a');

	wclose(fd);
	return 0;
}

int
dotable()
{
	register int	fd;
	register int	i;
	struct	ar_hdr	a;

	if ((fd = ropen(afile)) < 0)
		error("can't read archive");

	if (files[0] == NULL) {
		while (gethdr(fd, &a)) {
			if (vflag)
				printf("%s%6d/%6d%7ld %.14s\n",
					modestr(a.ar_mode),
					a.ar_uid, a.ar_gid,
					a.ar_size, a.ar_name);
			else
				printf("%.14s\n", a.ar_name);
			if (!skipit(fd, &a))
				break;
		}
		close(fd);
		return 0;
	}

	for (i=0; files[i] != NULL ;i++) {
		if (moveto(fd, files[i], &a)) {
			if (vflag)
				printf("%s%6d/%6d%7ld %.14s\n",
					modestr(a.ar_mode),
					a.ar_uid, a.ar_gid,
					a.ar_size, a.ar_name);
			else
				printf("%.14s\n", a.ar_name);
		} else
			fprintf(stderr, "%s: not found\n", files[i]);
	}
	close(fd);
	return 0;
}

int
doprint()
{
	register int	fd;
	register int	i;
	struct	ar_hdr	a;

	/*
	 * If no file names given, error.
	 */
	if (files[0] == NULL) {
		fprintf(stderr, "ar: no filenames given\n");
		return 1;
	}

	if ((fd = ropen(afile)) < 0)
		error("can't read archive");

	for (i=0; files[i] != NULL ;i++) {
		if (moveto(fd, files[i], &a))
			copy(fd, 1, a.ar_size);
		else
			fprintf(stderr, "%s: not found\n", files[i]);
	}
	close(fd);

	return 0;
}

int
domove()
{
	register int	fd, tfd;
	register int	i;
	struct	ar_hdr	a;

	if (files[0] == NULL)	/* no work to do */
		return 0;

	tfd = wopen(tfile, FALSE);

	if ((fd = ropen(afile)) < 0) {
		fprintf(stderr, "ar: can't open archive '%s'\n", afile);
		exit(1);
	}

	while (gethdr(fd, &a)) {

		if (inlist(a.ar_name)) {

			/*
			 * Don't copy anything that we need
			 * to move to the end.
			 */
			if (!skipit(fd, &a)) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("domove: malformed archive");
			}

		} else {	/* copy from the old archive */

			if (write(tfd, &a, ARHSZ) != ARHSZ) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("move: can't write to archive");
			}
			if (!copy(fd, tfd, a.ar_size)) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("move: can't write to archive");
			}
		}
	}

	/*
	 * Now everything that isn't to be moved has been copied
	 * to the temp file. Now go back and get the stuff to be
	 * moved and copy it.
	 */
	for (i=0; files[i] != NULL ;i++) {

		if (moveto(fd, files[i], &a)) {
			if (vflag)
				printf("m %s\n", files[i]);

			if (write(tfd, &a, ARHSZ) != ARHSZ) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("move: can't write to archive");
			}
			if (!copy(fd, tfd, a.ar_size)) {
				close(tfd);
				close(fd);
				unlink(tfile);
				error("move: can't write to archive");
			}
		} else
			printf("%s: not in archive\n", files[i]);
	}
	close(fd);
	wclose(tfd);

	/*
	 * Unlink the original archive and rename the
	 * temp file on top of it.
	 */
	unlink(afile);
	rename(tfile, afile);

	return 0;
}

int
doextract()
{
	register int	fd, xfd;
	register int	i;
	struct	ar_hdr	a;

	if ((fd = ropen(afile)) < 0)
		error("can't read archive");

	/*
	 * If no file names given, extract everything.
	 */
	if (files[0] == NULL) {
		while (gethdr(fd, &a)) {
			if ((xfd = creat(a.ar_name, 0)) < 0) {
				fprintf(stderr,"%s: can't create\n", a.ar_name);
				continue;
			}
			if (vflag)
				printf("x %s\n", a.ar_name);
			copy(fd, xfd, a.ar_size);
			close(xfd);
		}
		close(fd);
		return 0;
	}

	for (i=0; files[i] != NULL ;i++) {
		if (moveto(fd, files[i], &a)) {
			if ((xfd = creat(files[i], 0)) >= 0) {
				if (vflag)
					printf("x %s\n", a.ar_name);
				copy(fd, xfd, a.ar_size);
				close(xfd);
			} else
				fprintf(stderr, "%s: can't create\n", files[i]);
		} else
			fprintf(stderr, "%s: not found\n", files[i]);
	}
	close(fd);

	return 0;
}
