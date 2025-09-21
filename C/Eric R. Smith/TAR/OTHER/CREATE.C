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
 * Create a tar archive.
 *
 * Written 25 Aug 1985 by John Gilmore, ihnp4!hoptoad!gnu.
 *
 * @(#)create.c 1.36 11/6/87 - gnu
 */
#ifdef atarist
#include <types.h>
#include <stat.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif
#include <stdio.h>

/* JF: this one is my fault */
/* #include "utils.h" */

#ifndef V7
#include <fcntl.h>
#endif

#ifndef	MSDOS
#include <pwd.h>
#include <grp.h>
#endif

#ifdef BSD42
#include <sys/dir.h>
#else
#if (defined(MSDOS) && !defined(atarist))
#include <sys/dir.h>
#else
#ifdef USG
#include "dirent.h"
#define direct dirent
#define DP_NAMELEN(x) strlen((x)->d_name)
#else
/*
 * FIXME: On other systems there is no standard place for the header file
 * for the portable directory access routines.  Change the #include line
 * below to bring it in from wherever it is.
 */
#include "dirent.h"
#define direct dirent		/* If you have the POSIX version */
#define DP_NAMELEN(x) strlen((x)->d_name) /* ditto */
#endif
#endif
#endif

#ifndef DP_NAMELEN
#define DP_NAMELEN(x)	(x)->d_namlen
#endif

#ifdef USG
#include <sys/sysmacros.h>	/* major() and minor() defined here */
#endif

/*
 * V7 doesn't have a #define for this.
 */
#ifndef O_RDONLY
#define	O_RDONLY	0
#endif

/*
 * Most people don't have a #define for this.
 */
#ifndef	O_BINARY
#define	O_BINARY	0
#endif

#include "tar.h"
#include "port.h"

#ifdef atarist
#undef S_IFCHR
#endif

extern union record *head;		/* Points to current tape header */
extern struct stat hstat;		/* Stat struct corresponding */
extern int head_standard;		/* Tape header is in ANSI format */

/* JF */
extern struct name *gnu_list_name;

/*
 * If there are no symbolic links, there is no lstat().  Use stat().
 */
#ifndef S_IFLNK
#define lstat stat
#endif

extern char	*malloc();
extern char	*strcpy();
extern char	*strncpy();
extern void	bzero();
extern void	bcopy();
extern int	errno;

extern void print_header();

union record *start_header();
void finish_header();
void finduname();
void findgname();
char *name_next();
void to_oct();
void dump_file();

static nolinks;			/* Gets set if we run out of RAM */

void
create_archive()
{
	register char	*p;
	char *name_from_list();

	open_archive(0);		/* Open for writing */

	if(f_gnudump) {
		char buf[MAXNAMLEN],*q,*bufp;

		collect_and_sort_names();

		while(p=name_from_list())
			dump_file(p,-1);
		/* if(!f_dironly) { */
			blank_name_list();
			while(p=name_from_list()) {
				strcpy(buf,p);
				if(p[strlen(p)-1]!='/')
					strcat(buf,"/");
				bufp=buf+strlen(buf);
				for(q=gnu_list_name->dir_contents;*q;q+=strlen(q)+1) {
					if(*q=='Y') {
						strcpy(bufp,q+1);
						dump_file(buf,-1);
					}
				}
			}
		/* } */

	} else {
		while (p = name_next(1)) {
			dump_file(p, -1);
		}
	}

	write_eot();
	close_archive();
	name_close();
}

/*
 * Dump a single file.  If it's a directory, recurse.
 * Result is 1 for success, 0 for failure.
 * Sets global "hstat" to stat() output for this file.
 */
void
dump_file (p, curdev)
	char	*p;			/* File name to dump */
	int	curdev;			/* Device our parent dir was on */
{
	union record	*header;
	char type;
	extern char *save_name;		/* JF for multi-volume support */
	extern long save_totsize;
	extern long save_sizeleft;

	extern time_t new_time;

	if(f_confirm && !confirm("add",p))
		return;

	/*
	 * Use stat if following (rather than dumping) 4.2BSD's
	 * symbolic links.  Otherwise, use lstat (which, on non-4.2
	 * systems, is #define'd to stat anyway.
	 */
	if (0 != f_follow_links? stat(p, &hstat): lstat(p, &hstat))
	{
badperror:
		msg_perror("can't add file %s",p);
badfile:
		errors++;
		return;
	}

	/* See if we only want new files, and check if this one is too old to
	   put in the archive. */
	if(f_new_files && new_time>hstat.st_mtime &&
 	   new_time>hstat.st_ctime && (hstat.st_mode&S_IFMT)!=S_IFDIR) {
		if(curdev<0) {
			msg("%s: is unchanged; not dumped",p);
		}
		return;
	}

	/*
	 * See if we are crossing from one file system to another,
	 * and avoid doing so if the user only wants to dump one file system.
	 */
	if (f_local_filesys && curdev >= 0 && curdev != hstat.st_dev) {
		msg("%s: is on a different filesystem; not dumped",p);
		return;
	}

	/*
	 * Check for multiple links.
	 *
	 * We maintain a list of all such files that we've written so
	 * far.  Any time we see another, we check the list and
	 * avoid dumping the data again if we've done it once already.
	 */
	if (hstat.st_nlink > 1) switch (hstat.st_mode & S_IFMT) {
		register struct link	*lp;

	case S_IFREG:			/* Regular file */
#ifdef S_IFCTG
	case S_IFCTG:			/* Contigous file */
#endif
#ifdef S_IFCHR
	case S_IFCHR:			/* Character special file */
#endif

#ifdef S_IFBLK
	case S_IFBLK:			/* Block     special file */
#endif

#ifdef S_IFIFO
	case S_IFIFO:			/* Fifo      special file */
#endif

		/* First quick and dirty.  Hashing, etc later FIXME */
		for (lp = linklist; lp; lp = lp->next) {
			if (lp->ino == hstat.st_ino &&
			    lp->dev == hstat.st_dev) {
				/* We found a link. */
				hstat.st_size = 0;
				header = start_header(p, &hstat);
				if (header == NULL) goto badfile;
				strcpy(header->header.linkname,
					lp->name);
				header->header.linkflag = LF_LINK;
				finish_header(header);
		/* FIXME: Maybe remove from list after all links found? */
				return;		/* We dumped it */
			}
		}

		/* Not found.  Add it to the list of possible links. */
		lp = (struct link *) malloc( (unsigned)
			(strlen(p) + sizeof(struct link) - NAMSIZ));
		if (!lp) {
			if (!nolinks) {
				fprintf(stderr,
	"tar: no memory for links, they will be dumped as separate files\n");
				nolinks++;
			}
		}
		lp->ino = hstat.st_ino;
		lp->dev = hstat.st_dev;
		strcpy(lp->name, p);
		lp->next = linklist;
		linklist = lp;
	}

	/*
	 * This is not a link to a previously dumped file, so dump it.
	 */
	switch (hstat.st_mode & S_IFMT) {

	case S_IFREG:			/* Regular file */
#ifdef S_IFCTG
	case S_IFCTG:			/* Contigous file */
#endif
	{
		int	f;		/* File descriptor */
		long	bufsize, count;
		register long	sizeleft;
		register union record 	*start;

		sizeleft = hstat.st_size;
		/* Don't bother opening empty, world readable files. */
		if (sizeleft > 0 || 0444 != (0444 & hstat.st_mode)) {
			f = open(p, O_RDONLY|O_BINARY);
			if (f < 0) goto badperror;
		} else {
			f = -1;
		}

		header = start_header(p, &hstat);
		if (header == NULL) goto badfile;
#ifdef S_IFCTG
		/* Mark contiguous files, if we support them */
		if (f_standard && (hstat.st_mode & S_IFMT) == S_IFCTG) {
			header->header.linkflag = LF_CONTIG;
		}
#endif
		finish_header(header);

		while (sizeleft > 0) {
			if(f_multivol) {
				save_name = p;
				save_sizeleft = sizeleft;
				save_totsize = hstat.st_size;
			}
			start = findrec();
			bufsize = endofrecs()->charptr - start->charptr;
			if (sizeleft < bufsize) {
				/* Last read -- zero out area beyond */
				bufsize = (int)sizeleft;
				count = bufsize % RECORDSIZE;
				if (count) 
					bzero(start->charptr + sizeleft,
						(int)(RECORDSIZE - count));
			}
			count = read(f, start->charptr, bufsize);
			if (count < 0) {
				msg_perror("read error at byte %ld, reading\
 %d bytes, in file %s",  hstat.st_size - sizeleft, bufsize,p);
				goto padit;
			}
			sizeleft -= count;

			/* This is nonportable (the type of userec's arg). */
			userec(start+(count-1)/RECORDSIZE);

			if (count == bufsize) continue;
			msg( "file %s shrunk by %d bytes, padding with zeros.\n", p, sizeleft);
			goto padit;		/* Short read */
		}

		if(f_multivol)
			save_name = 0;

		if (f >= 0)
			(void)close(f);

		break;

		/*
		 * File shrunk or gave error, pad out tape to match
		 * the size we specified in the header.
		 */
	padit:
		while(sizeleft>0) {
			save_sizeleft=sizeleft;
			start=findrec();
			bzero(start->charptr,RECORDSIZE);
			userec(start);
			sizeleft-=RECORDSIZE;
		}
		if(f_multivol)
			save_name=0;
		if(f>=0)
			(void)close(f);
		break;
/*		abort(); */
	}

#ifdef S_IFLNK
	case S_IFLNK:			/* Symbolic link */
	{
		int size;

		hstat.st_size = 0;		/* Force 0 size on symlink */
		header = start_header(p, &hstat);
		if (header == NULL) goto badfile;
		size = readlink(p, header->header.linkname, NAMSIZ);
		if (size < 0) goto badperror;
		if (size == NAMSIZ) {
			msg("symbolic link %s too long\n",p);
			break;
		}
		header->header.linkname[size] = '\0';
		header->header.linkflag = LF_SYMLINK;
		finish_header(header);		/* Nothing more to do to it */
	}
		break;
#endif

	case S_IFDIR:			/* Directory */
	{
		register DIR *dirp;
		register struct direct *d;
		char namebuf[NAMSIZ+2];
		register int len;
		int our_device = hstat.st_dev;

		/* Build new prototype name */
		strncpy(namebuf, p, sizeof (namebuf));
		len = strlen(namebuf);
		while (len >= 1 && '/' == namebuf[len-1]) 
			len--;			/* Delete trailing slashes */
		namebuf[len++] = '/';		/* Now add exactly one back */
		namebuf[len] = '\0';		/* Make sure null-terminated */

		/*
		 * Output directory header record with permissions
		 * FIXME, do this AFTER files, to avoid R/O dir problems?
		 * If old archive format, don't write record at all.
		 */
		if (!f_oldarch) {
			hstat.st_size = 0;	/* Force 0 size on dir */
			/*
			 * If people could really read standard archives,
			 * this should be:		(FIXME)
			header = start_header(f_standard? p: namebuf, &hstat);
			 * but since they'd interpret LF_DIR records as
			 * regular files, we'd better put the / on the name.
			 */
			header = start_header(namebuf, &hstat);
			if (header == NULL)
				goto badfile;	/* eg name too long */

			if (f_gnudump)
				header->header.linkflag = LF_DUMPDIR;
			else if (f_standard)
				header->header.linkflag = LF_DIR;

			/* If we're gnudumping, we aren't done yet so don't close it. */
			if(!f_gnudump)
				finish_header(header);	/* Done with directory header */
		}

		/* Hack to remove "./" from the front of all the file names */
		if (len == 2 && namebuf[0] == '.') {
			len = 0;
		}

		if(f_gnudump) {
			int sizeleft;
			int totsize;
			int bufsize;
			union record *start;
			int count;
			char *buf,*p_buf;

			buf=gnu_list_name->dir_contents; /* FOO */
			totsize=0;
			for(p_buf=buf;*p_buf;) {
				int tmp;

				tmp=strlen(p_buf)+1;
				totsize+=tmp;
				p_buf+=tmp;
			}
			totsize++;
			to_oct((long)totsize,1+12,header->header.size);
			finish_header(header);
			p_buf=buf;
			sizeleft=totsize;
			while(sizeleft>0) {
				if(f_multivol) {
					save_name=p;
					save_sizeleft=sizeleft;
					save_totsize=totsize;
				}
				start=findrec();
				bufsize=endofrecs()->charptr - start->charptr;
				if(sizeleft<bufsize) {
					bufsize=sizeleft;
					count=bufsize%RECORDSIZE;
					if(count)
						bzero(start->charptr+sizeleft,RECORDSIZE-count);
				}
				bcopy(p_buf,start->charptr,bufsize);
				sizeleft-=bufsize;
				p_buf+=bufsize;
				userec(start+(bufsize-1)/RECORDSIZE);
			}
			if(f_multivol)
				save_name = 0;
			break;
		}

		/* Now output all the files in the directory */
		/* if (f_dironly)
			break;		/* Unless the cmdline said not to */

		
		errno = 0;
		dirp = opendir(p);
		if (!dirp) {
			if (errno) {
				msg_perror ("can't open directory %s",p);
			} else {
				msg("error opening directory %s",
					p);
			}
			break;
		}

		/* Should speed this up by cd-ing into the dir, FIXME */
		while (NULL != (d=readdir(dirp))) {
			/* Skip . and .. */
			if(is_dot_or_dotdot(d->d_name))
				continue;

			if (DP_NAMELEN(d) + len >= NAMSIZ) {
				msg("file name %s%s too long\n", 
					namebuf, d->d_name);
				continue;
			}
			strcpy(namebuf+len, d->d_name);
			if(f_exclude && check_exclude(namebuf))
				continue;
			dump_file(namebuf, our_device);
		}

		closedir(dirp);
	}
		break;

#ifdef S_IFCHR
	case S_IFCHR:			/* Character special file */
		type = LF_CHR;
		goto easy;
#endif

#ifdef S_IFBLK
	case S_IFBLK:			/* Block     special file */
		type = LF_BLK;
		goto easy;
#endif

#ifdef S_IFIFO
	case S_IFIFO:			/* Fifo      special file */
		type = LF_FIFO;
#endif

	easy:
		if (!f_standard) goto unknown;

		hstat.st_size = 0;		/* Force 0 size */
		header = start_header(p, &hstat);
		if (header == NULL) goto badfile;	/* eg name too long */

		header->header.linkflag = type;
		if (type != LF_FIFO) {
			to_oct((long) major(hstat.st_rdev), 8,
				header->header.devmajor);
			to_oct((long) minor(hstat.st_rdev), 8,
				header->header.devminor);
		}

		finish_header(header);
		break;

	default:
	unknown:
		msg("%s: Unknown file type; file ignored.\n", p);
		break;
	}
}


/*
 * Make a header block for the file  name  whose stat info is  st .
 * Return header pointer for success, NULL if the name is too long.
 */
union record *
start_header(name, st)
	char	*name;
	register struct stat *st;
{
	register union record *header;

	header = (union record *) findrec();
	bzero(header->charptr, sizeof(*header)); /* XXX speed up */

	/*
	 * Check the file name and put it in the record.
	 */
#ifdef MSDOS
	if(name[1]==':') {
		static int warned_once = 0;
		name+=2;
		if(!warned_once++) {
			msg("Removing drive spec from names in the archive");
		}
	}
#endif
	while ('/' == *name) {
		static int warned_once = 0;

		name++;				/* Force relative path */
		if (!warned_once++) {
			msg("Removing leading / from absolute path names in the archive.");
		}
	}
	strcpy(header->header.name, name);
	if (header->header.name[NAMSIZ-1]) {
		msg("%s: name too long\n", name);
		return NULL;
	}

	to_oct((long) (st->st_mode & ~S_IFMT),
					8,  header->header.mode);
	to_oct((long) st->st_uid,	8,  header->header.uid);
	to_oct((long) st->st_gid,	8,  header->header.gid);
	to_oct((long) st->st_size,	1+12, header->header.size);
	to_oct((long) st->st_mtime,	1+12, header->header.mtime);
	/* header->header.linkflag is left as null */
	if(f_gnudump) {
		to_oct((long) st->st_atime, 1+12, header->header.atime);
		to_oct((long) st->st_ctime, 1+12, header->header.ctime);
	}

#ifndef NONAMES
	/* Fill in new Unix Standard fields if desired. */
	if (f_standard) {
		header->header.linkflag = LF_NORMAL;	/* New default */
		strcpy(header->header.magic, TMAGIC);	/* Mark as Unix Std */
		finduname(header->header.uname, st->st_uid);
		findgname(header->header.gname, st->st_gid);
	}
#endif
	return header;
}

/* 
 * Finish off a filled-in header block and write it out.
 * We also print the file name and/or full info if verbose is on.
 */
void
finish_header(header)
	register union record *header;
{
	register int	i, sum;
	register char	*p;
	void bcopy();

	bcopy(CHKBLANKS, header->header.chksum, sizeof(header->header.chksum));

	sum = 0;
	p = header->charptr;
	for (i = sizeof(*header); --i >= 0; ) {
		/*
		 * We can't use unsigned char here because of old compilers,
		 * e.g. V7.
		 */
		sum += 0xFF & *p++;
	}

	/*
	 * Fill in the checksum field.  It's formatted differently
	 * from the other fields:  it has [6] digits, a null, then a
	 * space -- rather than digits, a space, then a null.
	 * We use to_oct then write the null in over to_oct's space.
	 * The final space is already there, from checksumming, and
	 * to_oct doesn't modify it.
	 *
	 * This is a fast way to do:
	 * (void) sprintf(header->header.chksum, "%6o", sum);
	 */
	to_oct((long) sum,	8,  header->header.chksum);
	header->header.chksum[6] = '\0';	/* Zap the space */

	userec(header);

	if (f_verbose) {
		/* These globals are parameters to print_header, sigh */
		head = header;
		/* hstat is already set up */
		head_standard = f_standard;
		print_header();
	}

	return;
}


/*
 * Quick and dirty octal conversion.
 * Converts long "value" into a "digs"-digit field at "where",
 * including a trailing space and room for a null.  "digs"==3 means
 * 1 digit, a space, and room for a null.
 *
 * We assume the trailing null is already there and don't fill it in.
 * This fact is used by start_header and finish_header, so don't change it!
 *
 * This should be equivalent to:
 *	(void) sprintf(where, "%*lo ", digs-2, value);
 * except that sprintf fills in the trailing null and we don't.
 */
void
to_oct(value, digs, where)
	register long	value;
	register int	digs;
	register char	*where;
{
	
	--digs;				/* Trailing null slot is left alone */
	where[--digs] = ' ';		/* Put in the space, though */

	/* Produce the digits -- at least one */
	do {
		where[--digs] = '0' + (char)(value & 7); /* one octal digit */
		value >>= 3;
	} while (digs > 0 && value != 0);

	/* Leading spaces, if necessary */
	while (digs > 0)
		where[--digs] = ' ';

}


/*
 * Write the EOT record(s).
 * We actually zero at least one record, through the end of the block.
 * Old tar writes garbage after two zeroed records -- and PDtar used to.
 */
write_eot()
{
	union record *p;
	int bufsize;
	void bzero();

	p = findrec();
	bufsize = endofrecs()->charptr - p->charptr;
	bzero(p->charptr, bufsize);
	userec(p);
}
