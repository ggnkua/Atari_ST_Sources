/*

	Copyright (C) 1988 Free Software Foundation

GNU tar is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the GNU tar General Public License for full details.

Everyone is granted permission to copy, modify and redistribute GNU tar,
but only under the conditions described in the GNU tar General Public
License.  A copy of this license is supposed to have been given to you
along with GNU tar so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

In other words, go ahead and share GNU tar, but don't try to stop
anyone else from sharing it farther.  Help stamp out software hoarding!
*/

/*
 * Diff files from a tar archive.
 *
 * Written 30 April 1987 by John Gilmore, ihnp4!hoptoad!gnu.
 *
 * @(#) diffarch.c 1.10 87/11/11 - gnu
 */

#include <stdio.h>
#include <errno.h>
#ifdef atarist
#include <types.h>
#include <stat.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifdef BSD42
#include <sys/file.h>
#endif

#ifdef atarist
#include <file.h>
#endif

#ifdef USG
#include <fcntl.h>
#endif

/* Some systems don't have these #define's -- we fake it here. */
#ifndef O_RDONLY
#define	O_RDONLY	0
#endif
#ifndef	O_NDELAY
#define	O_NDELAY	0
#endif

#ifndef S_IFLNK
#define lstat stat
#endif

extern int errno;			/* From libc.a */
extern char *valloc();			/* From libc.a */

#include "tar.h"
#include "port.h"
#include "rmt.h"

extern union record *head;		/* Points to current tape header */
extern struct stat hstat;		/* Stat struct corresponding */
extern int head_standard;		/* Tape header is in ANSI format */

extern void print_header();
extern void skip_file();

extern FILE *msg_file;

int now_verifying = 0;		/* Are we verifying at the moment? */

char	*diff_name;		/* head->header.name */

int	diff_fd;		/* Descriptor of file we're diffing */

char	*diff_buf = 0;		/* Pointer to area for reading
					   file contents into */

char	*diff_dir;		/* Directory contents for LF_DUMPDIR */

int different = 0;

/*
 * Initialize for a diff operation
 */
diff_init()
{

	/*NOSTRICT*/
	diff_buf = (char *) valloc((unsigned)blocksize);
	if (!diff_buf) {
		msg("could not allocate memory for diff buffer of %d bytes\n",
			blocking);
		exit(EX_ARGSBAD);
	}
}

/*
 * Diff a file against the archive.
 */
void
diff_archive()
{
	register char *data;
	int check, namelen;
	int err;
	long offset;
	struct stat filestat;
	char linkbuf[NAMSIZ+3];
	int compare_chunk();
	int compare_dir();
	dev_t	dev;
	ino_t	ino;
	char *get_dir_contents();
	long from_oct();
	long lseek();

#ifndef atarist
	errno = EPIPE;			/* FIXME, remove perrors */
#endif
	saverec(&head);			/* Make sure it sticks around */
	userec(head);			/* And go past it in the archive */
	decode_header(head, &hstat, &head_standard, 1);	/* Snarf fields */

	if(now_verifying)
		fprintf(msg_file,"Verify ");
	/* Print the record from 'head' and 'hstat' */
	if (f_verbose)
		print_header();

	diff_name = head->header.name;
	switch (head->header.linkflag) {

	default:
		msg("Unknown file type '%c' for %s, diffed as normal file\n",
			head->header.linkflag, diff_name);
		/* FALL THRU */

	case LF_OLDNORMAL:
	case LF_NORMAL:
	case LF_CONTIG:
		/*
		 * Appears to be a file.
		 * See if it's really a directory.
		 */
		namelen = strlen(diff_name)-1;
		if (diff_name[namelen] == '/')
			goto really_dir;

		
		if(do_stat(&filestat))
			goto quit;

		if ((filestat.st_mode & S_IFMT) != S_IFREG) {
			fprintf(msg_file, "%s: not a regular file\n",
				diff_name);
			skip_file((long)hstat.st_size);
			different++;
			goto quit;
		}

		filestat.st_mode &= ~S_IFMT;
		if (filestat.st_mode != hstat.st_mode)
			sigh("mode");
		if (filestat.st_uid  != hstat.st_uid)
			sigh("uid");
		if (filestat.st_gid  != hstat.st_gid)
			sigh("gid");
		if (filestat.st_mtime != hstat.st_mtime)
			sigh("mod time");
		if (filestat.st_size != hstat.st_size) {
			sigh("size");
			skip_file((long)hstat.st_size);
			goto quit;
		}

		diff_fd = open(diff_name, O_NDELAY|O_RDONLY);

		if (diff_fd < 0) {
			msg_perror("cannot open %s",diff_name);
			skip_file((long)hstat.st_size);
			different++;
			goto quit;
		}

		wantbytes((long)(hstat.st_size),compare_chunk);

		check = close(diff_fd);
		if (check < 0) {
			msg_perror("Error while closing %s",diff_name);
		}

	quit:
		break;

	case LF_LINK:
		if(do_stat(&filestat))
			break;
		dev = filestat.st_dev;
		ino = filestat.st_ino;
		err = stat(head->header.linkname, &filestat);
		if (err < 0) {
			if (errno==ENOENT) {
				fprintf(msg_file, "%s: does not exist\n",diff_name);
			} else {
				msg_perror("cannot stat file %s",diff_name);
			}
			different++;
			break;
		}
		if(filestat.st_dev!=dev || filestat.st_ino!=ino) {
			fprintf(msg_file, "%s not linked to %s\n",diff_name,head->header.linkname);
			break;
		}
		break;

#ifdef S_IFLNK
	case LF_SYMLINK:
		check = readlink(diff_name, linkbuf,
				 (sizeof linkbuf)-1);
		
		if (check < 0) {
			if (errno == ENOENT) {
				fprintf(msg_file,
					"%s: no such file or directory\n",
					diff_name);
			} else {
				msg_perror("cannot read link %s",diff_name);
			}
			different++;
			break;
		}

		linkbuf[check] = '\0';	/* Null-terminate it */
		if (strncmp(head->header.linkname, linkbuf, check) != 0) {
			fprintf(msg_file, "%s: symlink differs\n",
				head->header.linkname);
			different++;
		}
		break;
#endif

	case LF_CHR:
		hstat.st_mode |= S_IFCHR;
		goto check_node;

#ifdef S_IFBLK
	/* If local system doesn't support block devices, use default case */
	case LF_BLK:
		hstat.st_mode |= S_IFBLK;
		goto check_node;
#endif

#ifdef S_IFIFO
	/* If local system doesn't support FIFOs, use default case */
	case LF_FIFO:
		hstat.st_mode |= S_IFIFO;
		hstat.st_rdev = 0;		/* FIXME, do we need this? */
		goto check_node;
#endif

	check_node:
		/* FIXME, deal with umask */
		if(do_stat(&filestat))
			break;
		if(hstat.st_rdev != filestat.st_rdev) {
			fprintf(msg_file, "%s: device numbers changed\n", diff_name);
			different++;
			break;
		}
		if(hstat.st_mode != filestat.st_mode) {
			fprintf(msg_file, "%s: mode or device-type changed\n", diff_name);
			different++;
			break;
		}
		break;

	case LF_DUMPDIR:
		data=diff_dir=get_dir_contents(diff_name,0);
		wantbytes((long)(hstat.st_size),compare_dir);
		free(data);
		/* FALL THROUGH */

	case LF_DIR:
		/* Check for trailing / */
		namelen = strlen(diff_name)-1;
	really_dir:
		while (namelen && diff_name[namelen] == '/')
			diff_name[namelen--] = '\0';	/* Zap / */

		if(do_stat(&filestat))
			break;
		if((filestat.st_mode&S_IFMT)!=S_IFDIR) {
			fprintf(msg_file, "%s is no longer a directory\n",diff_name);
			different++;
			break;
		}
		if((filestat.st_mode&~S_IFMT) != hstat.st_mode)
			sigh("mode");
		break;

	case LF_VOLHDR:
		break;

	case LF_MULTIVOL:
		namelen = strlen(diff_name)-1;
		if (diff_name[namelen] == '/')
			goto really_dir;

		if(do_stat(&filestat))
			break;

		if ((filestat.st_mode & S_IFMT) != S_IFREG) {
			fprintf(msg_file, "%s: not a regular file\n",
				diff_name);
			skip_file((long)hstat.st_size);
			different++;
			break;
		}

		filestat.st_mode &= ~S_IFMT;
		offset = from_oct(1+12, head->header.offset);
		if (filestat.st_size != hstat.st_size + offset) {
			sigh("size");
			skip_file((long)hstat.st_size);
			different++;
			break;
		}

		diff_fd = open(diff_name, O_NDELAY|O_RDONLY);

		if (diff_fd < 0) {
			msg_perror("cannot open file %s",diff_name);
			skip_file((long)hstat.st_size);
			different++;
			break;
		}
		err = lseek(diff_fd, offset, 0);
		if(err!=offset) {
			msg_perror("cannot seek to %ld in file %s",offset,diff_name);
			different++;
			break;
		}

		wantbytes((long)(hstat.st_size),compare_chunk);

		check = close(diff_fd);
		if (check < 0) {
			msg_perror("Error while closing %s",diff_name);
		}
		break;

	}

	/* We don't need to save it any longer. */
	saverec((union record **) 0);	/* Unsave it */
}

int
compare_chunk(bytes,buffer)
int bytes;
char *buffer;
{
	int err;

	err=read(diff_fd,diff_buf,bytes);
	if(err!=bytes) {
		if(err<0) {
			msg_perror("can't read %s",diff_name);
		} else {
			fprintf(msg_file,"%s: could only read %d of %d bytes\n",err,bytes);
		}
		different++;
		return -1;
	}
	if(bcmp(buffer,diff_buf,bytes)) {
		fprintf(msg_file, "%s: data differs\n",diff_name);
		different++;
		return -1;
	}
	return 0;
}

int
compare_dir(bytes,buffer)
int bytes;
char *buffer;
{
	if(bcmp(buffer,diff_dir,bytes)) {
		fprintf(msg_file, "%s: data differs\n",diff_name);
		different++;
		return -1;
	}
	diff_dir+=bytes;
	return 0;
}

/*
 * Sigh about something that differs.
 */
sigh(what)
	char *what;
{

	fprintf(msg_file, "%s: %s differs\n",
		diff_name, what);
}

verify_volume()
{
	int status;
#ifdef MTIOCTOP
	struct mtop t;
	int er;
#endif

	if(!diff_buf)
		diff_init();
#ifdef MTIOCTOP
	t.mt_op = MTBSF;
	t.mt_count = 1;
	if((er=rmtioctl(archive,MTIOCTOP,&t))<0) {
		if(errno!=EIO || (er=rmtioctl(archive,MTIOCTOP,&t))<0) {
#endif
			if(rmtlseek(archive,0L,0)!=0) {
				/* Lseek failed.  Try a different method */
				msg_perror("Couldn't rewind archive file for verify");
				return;
			}
#ifdef MTIOCTOP
		}
	}
#endif
	ar_reading=1;
	now_verifying = 1;
	fl_read();
	for(;;) {
		status = read_header();
		if(status==0) {
			unsigned n;

			n=0;
			do {
				n++;
				status=read_header();
			} while(status==0);
			msg("VERIFY FAILURE: %d invalid header%s detected!",n,n==1?"":"s");
		}
		if(status==2 || status==EOF)
			break;
		diff_archive();
	}
	ar_reading=0;
	now_verifying = 0;
}

int do_stat(statp)
struct stat *statp;
{
	int err;

	err = f_follow_links ? stat(diff_name, statp) : lstat(diff_name, statp);
	if (err < 0) {
		if (errno==ENOENT) {
			fprintf(msg_file, "%s: does not exist\n",diff_name);
		} else
			msg_perror("can't stat file %s",diff_name);
		skip_file((long)hstat.st_size);
		different++;
		return 1;
	} else
		return 0;
}
