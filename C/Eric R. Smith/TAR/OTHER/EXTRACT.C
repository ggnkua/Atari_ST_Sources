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
 * Extract files from a tar archive.
 *
 * Written 19 Nov 1985 by John Gilmore, ihnp4!hoptoad!gnu.
 *
 * @(#) extract.c 1.32 87/11/11 - gnu
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

#ifdef USG
#include <fcntl.h>
#endif

#ifdef	MSDOS
#include <fcntl.h>
#endif	/* MSDOS */

/*
 * Some people don't have a #define for these.
 */
#ifndef	O_BINARY
#define	O_BINARY	0
#endif
#ifndef O_NDELAY
#define	O_NDELAY	0
#endif

#ifdef NO_OPEN3
/* We need the #define's even though we don't use them. */
#include "open3.h"
#endif

#ifdef EMUL_OPEN3
/* Simulated 3-argument open for systems that don't have it */
#include "open3.h"
#endif

extern int errno;			/* From libc.a */
extern time_t time();			/* From libc.a */
extern char *index();			/* From libc.a or port.c */

#include "tar.h"
#include "port.h"

extern FILE *msg_file;

extern union record *head;		/* Points to current tape header */
extern struct stat hstat;		/* Stat struct corresponding */
extern int head_standard;		/* Tape header is in ANSI format */

extern char *save_name;
extern long save_totsize;
extern long save_sizeleft;

extern void print_header();
extern void skip_file();
extern void pr_mkdir();

int make_dirs();			/* Makes required directories */

static time_t now = 0;			/* Current time */
static we_are_root = 0;			/* True if our effective uid == 0 */
static int notumask = ~0;		/* Masks out bits user doesn't want */

/*
 * Set up to extract files.
 */
extr_init()
{
	int ourmask;

	now = time((time_t *)0);
	if (geteuid() == 0)
		we_are_root = 1;

	/*
	 * We need to know our umask.  But if f_use_protection is set,
	 * leave our kernel umask at 0, and our "notumask" at ~0.
	 */
	ourmask = umask(0);		/* Read it */
	if (!f_use_protection) {
		(void) umask (ourmask);	/* Set it back how it was */
		notumask = ~ourmask;	/* Make umask override permissions */
	}
}


/*
 * Extract a file from the archive.
 */
void
extract_archive()
{
	register char *data;
	int fd, check, namelen, written, openflag;
	long size;
	time_t acc_upd_times[2];
	register int skipcrud;

	saverec(&head);			/* Make sure it sticks around */
	userec(head);			/* And go past it in the archive */
	decode_header(head, &hstat, &head_standard, 1);	/* Snarf fields */

	if(f_confirm && !confirm("extract",head->header.name)) {
		skip_file((long)hstat.st_size);
		saverec((union record **)0);
		return;
	}

	/* Print the record from 'head' and 'hstat' */
	if (f_verbose)
		print_header();

	/*
	 * Check for fully specified pathnames and other atrocities.
	 *
	 * Note, we can't just make a pointer to the new file name,
	 * since saverec() might move the header and adjust "head".
	 * We have to start from "head" every time we want to touch
	 * the header record.
	 */
	skipcrud = 0;
	while ('/' == head->header.name[skipcrud]) {
		static int warned_once = 0;

		skipcrud++;	/* Force relative path */
		if (!warned_once++) {
			msg("Removing leading / from absolute path names in the archive.");
		}
	}

	switch (head->header.linkflag) {

	default:
		msg("Unknown file type '%c' for %s, extracted as normal file",
			head->header.linkflag, skipcrud+head->header.name);
		/* FALL THRU */

	case LF_OLDNORMAL:
	case LF_NORMAL:
	case LF_CONTIG:
		/*
		 * Appears to be a file.
		 * See if it's really a directory.
		 */
		namelen = strlen(skipcrud+head->header.name)-1;
		if (head->header.name[skipcrud+namelen] == '/')
			goto really_dir;

		/* FIXME, deal with protection issues */
	again_file:
		openflag = f_keep?
			O_BINARY|O_NDELAY|O_WRONLY|O_APPEND|O_CREAT|O_EXCL:
			O_BINARY|O_NDELAY|O_WRONLY|O_APPEND|O_CREAT|O_TRUNC;
		if(f_exstdout) {
			fd = 1;
			goto extract_file;
		}
#ifdef O_CTG
		/*
		 * Contiguous files (on the Masscomp) have to specify
		 * the size in the open call that creates them.
		 */
		if (head->header.lnkflag == LF_CONTIG)
			fd = open(skipcrud+head->header.name, openflag | O_CTG,
				hstat.st_mode, hstat.st_size);
		else
#endif
		{
#ifdef NO_OPEN3
			/*
			 * On raw V7 we won't let them specify -k (f_keep), but
			 * we just bull ahead and create the files.
			 */
			fd = creat(skipcrud+head->header.name, 
				hstat.st_mode);
#else
			/*
			 * With 3-arg open(), we can do this up right.
			 */
			fd = open(skipcrud+head->header.name, openflag,
				hstat.st_mode);
#endif
		}

		if (fd < 0) {
			if (make_dirs(skipcrud+head->header.name))
				goto again_file;
			msg_perror("Could not create file %s",skipcrud+head->header.name);
			skip_file((long)hstat.st_size);
			goto quit;
		}

	extract_file:
		for (size = hstat.st_size;
		     size > 0;
		     size -= written) {

			if(f_multivol) {
				save_name=head->header.name;
				save_totsize=hstat.st_size;
				save_sizeleft=size;
			}

			/*
			 * Locate data, determine max length
			 * writeable, write it, record that
			 * we have used the data, then check
			 * if the write worked.
			 */
			data = findrec()->charptr;
			if (data == NULL) {	/* Check it... */
				msg("Unexpected EOF on archive file");
				break;
			}
			written = endofrecs()->charptr - data;
			if (written > size)
				written = size;
			errno = 0;
			check = write(fd, data, written);
			/*
			 * The following is in violation of strict
			 * typing, since the arg to userec
			 * should be a struct rec *.  FIXME.
			 */
			userec((union record *)(data + written - 1));
			if (check == written) continue;
			/*
			 * Error in writing to file.
			 * Print it, skip to next file in archive.
			 */
			if(check<0)
				msg_perror("couldn't write to file %s",skipcrud+head->header.name);
			else
				msg("could only write %d of %d bytes to file %s",written,check,skipcrud+head->header.name);
			skip_file((long)(size - written));
			break;	/* Still do the close, mod time, chmod, etc */
		}

		if(f_multivol)
			save_name = 0;

			/* If writing to stdout, don't try to do anything
			   to the filename; it doesn't exist, or we don't
			   want to touch it anyway */
		if(f_exstdout)
			break;

		check = close(fd);
		if (check < 0) {
			msg_perror("Error while closing %s",skipcrud+head->header.name);
		}
		
	set_filestat:
#ifdef atarist
	/* GEMDOS doesn't allow changing attributes of directories */
		if (hstat.st_mode & S_IFDIR)
			break;
#endif
		/*
		 * Set the modified time of the file.
		 * 
		 * Note that we set the accessed time to "now", which
		 * is really "the time we started extracting files".
		 * unless f_gnudump is used, in which case .st_atime is used
		 */
		if (!f_modified) {
			/* fixme if f_gnudump should set ctime too, but how? */
			if(f_gnudump) acc_upd_times[0]=hstat.st_atime;
			else acc_upd_times[0] = now;	         /* Accessed now */
			acc_upd_times[1] = hstat.st_mtime; /* Mod'd */
			if (utime(skipcrud+head->header.name,
			    acc_upd_times) < 0) {
				msg_perror("couldn't change access and modification times of %s",skipcrud+head->header.name);
			}
		}

		/*
		 * If we are root, set the owner and group of the extracted
		 * file.  This does what is wanted both on real Unix and on
		 * System V.  If we are running as a user, we extract as that
		 * user; if running as root, we extract as the original owner.
		 */
		if (we_are_root) {
			if (chown(skipcrud+head->header.name, hstat.st_uid,
				  hstat.st_gid) < 0) {
				msg_perror("cannot chown file %s to uid %d gid %d",skipcrud+head->header.name,hstat.st_uid,hstat.st_gid);
			}
		}

		/*
		 * If '-k' is not set, open() or creat() could have saved
		 * the permission bits from a previously created file,
		 * ignoring the ones we specified.
		 * Even if -k is set, if the file has abnormal
		 * mode bits, we must chmod since writing or chown() has
		 * probably reset them.
		 *
		 * If -k is set, we know *we* created this file, so the mode
		 * bits were set by our open().   If the file is "normal", we
		 * skip the chmod.  This works because we did umask(0) if -p
		 * is set, so umask will have left the specified mode alone.
		 */
		if ((!f_keep)
		    || (hstat.st_mode & (S_ISUID|S_ISGID|S_ISVTX))) {
			if (chmod(skipcrud+head->header.name,
				  notumask & (int)hstat.st_mode) < 0) {
				msg_perror("cannot change mode of file %s to %ld",skipcrud+head->header.name,notumask & (int)hstat.st_mode);
			}
		}

	quit:
		break;

	case LF_LINK:
	again_link:
		check = link (head->header.linkname,
			      skipcrud+head->header.name);
		if (check == 0)
			break;
		if (make_dirs(skipcrud+head->header.name))
			goto again_link;
		if(f_gnudump && errno==EEXIST)
			break;
		msg_perror("Could not link %s to %s",
			skipcrud+head->header.name,head->header.linkname);
		break;

#ifdef S_IFLNK
	case LF_SYMLINK:
	again_symlink:
		check = symlink(head->header.linkname,
			        skipcrud+head->header.name);
		/* FIXME, don't worry uid, gid, etc... */
		if (check == 0)
			break;
		if (make_dirs(skipcrud+head->header.name))
			goto again_symlink;
		msg_perror("Could not create symlink to %s",head->header.linkname);
		break;
#endif

#ifdef S_IFCHR
	case LF_CHR:
		hstat.st_mode |= S_IFCHR;
		goto make_node;
#endif

#ifdef S_IFBLK
	case LF_BLK:
		hstat.st_mode |= S_IFBLK;
		goto make_node;
#endif

#ifdef S_IFIFO
	/* If local system doesn't support FIFOs, use default case */
	case LF_FIFO:
		hstat.st_mode |= S_IFIFO;
		hstat.st_rdev = 0;		/* FIXME, do we need this? */
		goto make_node;
#endif

	make_node:
		check = mknod(skipcrud+head->header.name,
			      (int) hstat.st_mode, (int) hstat.st_rdev);
		if (check != 0) {
			if (make_dirs(skipcrud+head->header.name))
				goto make_node;
			msg_perror("Could not make %s",skipcrud+head->header.name);
			break;
		};
		goto set_filestat;

	case LF_DIR:
	case LF_DUMPDIR:
		namelen = strlen(skipcrud+head->header.name)-1;
	really_dir:
		/* Check for trailing /, and zap as many as we find. */
		while (namelen && head->header.name[skipcrud+namelen] == '/')
			head->header.name[skipcrud+namelen--] = '\0';
		if(f_gnudump) {		/* Read the entry and delete files
					   that aren't listed in the archive */
			gnu_restore(skipcrud+head->header.name);
		
		} else if(head->header.linkflag==LF_DUMPDIR)
			skip_file((long)(hstat.st_size));

	
	again_dir:
		check = mkdir(skipcrud+head->header.name,
			      0300 | (int)hstat.st_mode);
		if (check != 0) {
			if (make_dirs(skipcrud+head->header.name))
				goto again_dir;
			/* If we're trying to create '.', let it be. */
			if (head->header.name[skipcrud+namelen] == '.' && 
			    (namelen==0 ||
			     head->header.name[skipcrud+namelen-1]=='/'))
				goto check_perms;
			if(f_gnudump && errno==EEXIST)
				break;
			msg_perror("Could not make directory %s",skipcrud+head->header.name);
			break;
		}
		
	check_perms:
		if (0300 != (0300 & (int) hstat.st_mode)) {
			hstat.st_mode |= 0300;
			msg("Added write and execute permission to directory %s",
			  skipcrud+head->header.name);
		}
#ifdef atarist
		hstat.st_mode |= S_IFDIR;
#endif
		goto set_filestat;
		/* FIXME, Remember timestamps for after files created? */
		/* FIXME, change mode after files created (if was R/O dir) */
	case LF_VOLHDR:
		if(f_verbose) {
			printf("Reading %s\n",head->header.name);
		}
	case LF_MULTIVOL:
		msg("Can't extract '%s'--file is continued from another volume\n",head->header.name);
		skip_file((long)hstat.st_size);
		break;

	}

	/* We don't need to save it any longer. */
	saverec((union record **) 0);	/* Unsave it */
}

/*
 * After a file/link/symlink/dir creation has failed, see if
 * it's because some required directory was not present, and if
 * so, create all required dirs.
 */
int
make_dirs(pathname)
	char *pathname;
{
	char *p;			/* Points into path */
	int madeone = 0;		/* Did we do anything yet? */
	int save_errno = errno;		/* Remember caller's errno */
	int check;

#ifdef atarist
	if (errno != EPATH)
#else
	if (errno != ENOENT)
#endif
		return 0;		/* Not our problem */

	for (p = index(pathname, '/'); p != NULL; p = index(p+1, '/')) {
		/* Avoid mkdir of empty string, if leading or double '/' */
		if (p == pathname || p[-1] == '/')
			continue;
		/* Avoid mkdir where last part of path is '.' */
		if (p[-1] == '.' && (p == pathname+1 || p[-2] == '/'))
			continue;
		*p = 0;				/* Truncate the path there */
		check = mkdir (pathname, 0777);	/* Try to create it as a dir */
		if (check == 0) {
			/* Fix ownership */
			if (we_are_root) {
				if (chown(pathname, hstat.st_uid,
					  hstat.st_gid) < 0) {
					msg_perror("cannot change owner of %s to uid %d gid %d",pathname,hstat.st_uid,hstat.st_gid);
				}
			}
			pr_mkdir(pathname, p-pathname, notumask&0777);
			madeone++;		/* Remember if we made one */
			*p = '/';
			continue;
		}
		*p = '/';
		if (errno == EEXIST)		/* Directory already exists */
			continue;
		/*
		 * Some other error in the mkdir.  We return to the caller.
		 */
		break;
	}

	errno = save_errno;		/* Restore caller's errno */
	return madeone;			/* Tell them to retry if we made one */
}
