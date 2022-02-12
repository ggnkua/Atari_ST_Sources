#include <lib.h>
/*
		(SVR3 system call emulation)

  last edit:	27-Oct-1988	D A Gwyn

  This single source file supports several different methods of
  getting directory entries from the operating system.  Define
  whichever one of the following describes your system:

  UFS	original UNIX filesystem (14-character name limit)
  BFS	4.2BSD (also 4.3BSD) native filesystem (long names)
  NFS	getdirentries() system call

  Also define any of the following flags that are pertinent:

  ATT_SPEC	check user buffer address for longword alignment
  BSD_SYSV	BRL UNIX System V emulation environment on 4.nBSD
  INT_SIGS	<signal.h> thinks that signal handlers have
		return type int (rather than the standard void)
  NEG_DELS	deleted entries have inode number -1 rather than 0
  UNK		have _getdents() system call, but kernel may not
		support it

  If your C library has a getdents() system call interface, but you
  can't count on all kernels on which your application binaries may
  run to support it, change the system call interface name to
  _getdents() and define "UNK" to enable the system-call validity
  test in this "wrapper" around _getdents().

  If your system has a getdents() system call that is guaranteed
  to always work, you shouldn't be using this source file at all.
*/

#define  UFS

#include	<string.h>
#include	<unistd.h>

#ifdef BSD_SYSV
#include	<sys/_dir.h>	/* BSD flavor, not System V */
#else
#include	<sys/dir.h>
#undef	MAXNAMLEN		/* avoid conflict with SVR3 */
 /* Good thing we don't need to use the DIRSIZ() macro! */
#ifdef d_ino			/* 4.3BSD/NFS using d_fileno */
#undef	d_ino			/* (not absolutely necessary) */
#else
#define	d_fileno	d_ino	/* (struct direct) member */
#endif
#endif
#include	<dirent.h>


/*==========================================================================*/
/* This was in the original sys/dirent.h. The local definitions don't work. */

#ifdef BSD_SYSV				/* (e.g., when compiling getdents.c) */
extern struct dirent	__dirent;	/* (not actually used) */
/* The following is portable, although rather silly. */
#define	DIRENTBASESIZ		(__dirent.d_name - (char *)&__dirent.d_ino)

#else
/* The following nonportable ugliness could have been avoided by defining
   DIRENTSIZ and DIRENTBASESIZ to also have (struct dirent *) arguments.
   There shouldn't be any problem if you avoid using the DIRENTSIZ() macro. */

#define	DIRENTBASESIZ		(((struct dirent *)0)->d_name \
				- (char *)&((struct dirent *)0)->d_ino)
#endif

#define	DIRENTSIZ( namlen )	((DIRENTBASESIZ + sizeof(long) + (namlen)) \
				/ sizeof(long) * sizeof(long))
/*==========================================================================*/

#include	<sys/stat.h>
#ifdef UNK
#ifndef UFS
#include "***** ERROR ***** UNK applies only to UFS"
/* One could do something similar for getdirentries(), but I didn't bother. */
#endif
#include	<signal.h>
#endif

#ifdef BSD_SYSV
struct dirent __dirent;		/* (just for the DIRENTBASESIZ macro) */
#endif

#ifdef UFS
#define	RecLen( dp )	(sizeof(struct direct))	/* fixed-length entries */
#else				/* BFS || NFS */
#define	RecLen( dp )	((dp)->d_reclen)	/* variable-length entries */
#endif

#ifdef NFS
#ifdef BSD_SYSV
#define	getdirentries	_getdirentries	/* package hides this system call */
#endif
extern int getdirentries();
PRIVATE long dummy;		/* getdirentries() needs basep */
#define	GetBlock( fd, buf, n )	getdirentries( fd, buf, (unsigned)n, &dummy )
#else				/* UFS || BFS */
#ifdef BSD_SYSV
#define read	_read		/* avoid emulation overhead */
#endif
#define	GetBlock( fd, buf, n )	read( fd, buf, n )
#endif

#ifdef UNK
extern int _getdents();		/* actual system call */
#endif

#ifdef NEG_DELS
#define	DELETED	(-1)
#else
#define	DELETED	0
#endif

#ifndef DIRENTSIZ
#define DIRENTSIZ(x)	(x)
#endif
#ifndef DIRENTBASESIZ
#define DIRENTBASESIZ 0
#endif
#ifndef DIRBLKSIZ
#define	DIRBLKSIZ	4096	/* directory file read buffer size */
#endif

#ifndef NULL
#define	NULL	0
#endif

#ifndef SEEK_CUR
#define	SEEK_CUR	1
#endif

#ifndef S_ISDIR			/* macro to test for directory file */
#define	S_ISDIR( mode )		(((mode) & S_IFMT) == S_IFDIR)
#endif

#ifdef UFS

/*
  The following routine is necessary to handle DIRSIZ-long entry names.
  Thanks to Richard Todd for pointing this out.
*/

PRIVATE _PROTOTYPE( int NameLen, (char *name));

PRIVATE int NameLen(name)	/* return # chars in embedded name */
char name[];			/* -> name embedded in struct direct */
{
  register char *s;		/* -> name[.] */
  register char *stop = &name[NAME_MAX];	/* -> past end of name field */

  for (s = &name[1];		/* (empty names are impossible) */
       *s != '\0'		/* not NUL terminator */
       && ++s < stop;		/* < DIRSIZ characters scanned */
	);

  return (s - name);		/* # valid characters in name */
}

#else				/* BFS || NFS */

#define	NameLen( name )	strlen( name )	/* names are always NUL-terminated */

#endif

#ifdef UNK
PRIVATE enum {
  maybe, no, yes
} state = maybe;

 /* Does _getdents() work? */

#ifdef INT_SIGS
#define	RET_SIG	int
#else
#define	RET_SIG	void
#endif

/*ARGSUSED*/
PRIVATE RET_SIG
 sig_catch(sig)
int sig;			/* must be SIGSYS */
{
  state = no;			/* attempted _getdents() faulted */
#ifdef INT_SIGS
  return (0);			/* telling lies */
#endif
}

#endif				/* UNK */

int getdents(fildes, buf, nbyte)/* returns # bytes read; 0 on EOF, -1 on
			 * error */
int fildes;			/* directory file descriptor */
char *buf;			/* where to put the (struct dirent)s */
unsigned nbyte;			/* size of buf[] */
{
  int serrno;			/* entry errno */
  off_t offset;			/* initial directory file offset */
  /* The following are PRIVATE just to keep the stack small. */
  PRIVATE struct stat statb;	/* fstat() info */
  PRIVATE union {
	char dblk[DIRBLKSIZ
#ifdef UFS
		  + 1		/* for last entry name terminator */
#endif
	];
	/* Directory file block buffer */
	struct direct dummy;	/* just for alignment */
  } u;				/* (avoids having to malloc()) */
  register struct direct *dp;	/* -> u.dblk[.] */
  register struct dirent *bp;	/* -> buf[.] */

#ifdef UNK
  if (state == yes)		/* _getdents() is known to work */
	return (_getdents(fildes, buf, nbyte));

  if (state == maybe) {		/* first time only */
	RET_SIG(*shdlr) ();	/* entry SIGSYS handler */
	register int retval;	/* return from _getdents() if any */

	shdlr = signal(SIGSYS, sig_catch);
	retval = _getdents(fildes, buf, nbyte);	/* try it */
	(void) signal(SIGSYS, shdlr);

	if (state == maybe) {	/* SIGSYS did not occur */
		state = yes;	/* so _getdents() must have worked */
		return (retval);
	}
  }

  /* State == no; perform emulation */
#endif

  if (buf == (char *)NULL
#ifdef ATT_SPEC
      || (unsigned long) buf % sizeof(long) != 0	/* ugh */
#endif
	) {
	errno = EFAULT;		/* invalid pointer */
	return (-1);
  }
  if (fstat(fildes, &statb) != 0) return (-1);	/* errno set by fstat() */

  if (!S_ISDIR(statb.st_mode)) {
	errno = ENOTDIR;	/* not a directory */
	return (-1);
  }
  if ((offset = lseek(fildes, (off_t) 0, SEEK_CUR)) < 0)
	return (-1);		/* errno set by lseek() */

#ifdef BFS			/* no telling what remote hosts do */
  if ((unsigned long) offset % DIRBLKSIZ != 0) {
	errno = ENOENT;		/* file pointer probably misaligned */
	return (-1);
  }
#endif

  serrno = errno;		/* save entry errno */

  for (bp = (struct dirent *) buf; bp == (struct dirent *) buf;) {	/* convert next
									 * directory block */
	int size;

	do
		size = GetBlock(fildes, u.dblk, DIRBLKSIZ);
	while (size == -1 && errno == EINTR);

	if (size <= 0) return (size);	/* EOF or error (EBADF) */

	for (dp = (struct direct *) u.dblk;
	     (char *) dp < &u.dblk[size];
	     dp = (struct direct *) ((char *) dp + RecLen(dp))
		) {
#ifndef UFS
		if (dp->d_reclen <= 0) {
			errno = EIO;	/* corrupted directory */
			return (-1);
		}
#endif

		if (dp->d_fileno != DELETED) {	/* non-empty; copy to
						 * user buffer */
			register int reclen =
			DIRENTSIZ(NameLen(dp->d_name));

			if ((char *) bp + reclen > &buf[nbyte]) {
				errno = EINVAL;
				return (-1);	/* buf too small */
			}
			bp->d_ino = dp->d_fileno;
			bp->d_off = offset + ((char *) dp - u.dblk);
			bp->d_reclen = reclen;

			{
#ifdef UFS
				/* Is the following kludge ugly?  You bet. */

				register char save = dp->d_name[NAME_MAX];
				/* Save original data */

				dp->d_name[NAME_MAX] = '\0';
				/* Ensure NUL termination */
#endif
				(void) strncpy(bp->d_name, dp->d_name,
					       reclen - DIRENTBASESIZ
					);	/* adds NUL padding */
#ifdef UFS
				dp->d_name[NAME_MAX] = save;
				/* Restore original data */
#endif
			}

			bp = (struct dirent *) ((char *) bp + reclen);
		}
	}

	if ((char *) dp > &u.dblk[size]) {
		errno = EIO;	/* corrupted directory */
		return (-1);
	}
  }

  errno = serrno;		/* restore entry errno */
  return((char *) bp - buf);	/* return # bytes read */
}
