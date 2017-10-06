/* This is a excerpt of the mintlib
	especially made for XaAES compiled by using Pure C
 	H. Robbers November 17 1999.
*/

#include <compiler.h>
#include <stddef.h>
#include <stdlib.h>	/* both of these added for malloc() */
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>	/* for FSTAT */
#include <limits.h>
#include <sys/dirent.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include <mintbind.h>
#include <memory.h>
#include <time.h>
#include <fcntl.h>
#include <ctype.h>
#include <unistd.h>
#include <sysvars.h>
#include <mint/ssystem.h>
#include <sys/cookie.h>
#include <sys/param.h>
#include "lib.h"

/* HR: Get the stupid slashes out of the text
       In the seventies I worked on a system that had chosen
       the dot for directory name separator.   :-)
       (There was only 1 dot).
*/
#ifndef slash
#define slash '/'		/* should be really derived from Dpathconf */
#define sslash "/"
#define back_slash '\\'
#define sback_slash "\\"
#endif

ino_t __inode = 32; /* used in readdir, _do_stat, fstat */
uid_t __uid = 0;
gid_t __gid = 0;

int __has_no_ssystem;

long
get_sysvar(void *var)
{
    long ret;
    long save_ssp;

	if(__has_no_ssystem)
	{
    		save_ssp = (long) Super((void *) 0L);
    	/* note: dont remove volatile, otherwise gcc will reorder these
       	statements and we get bombs */
    		ret = *((volatile long *)var);
    		(void)Super((void *) save_ssp);
    		return ret;
	}
	else
		return Ssystem(S_GETLVAL, var, NULL);
}

void
set_sysvar_to_long(
	void *var,
	long val)
{
    long save_ssp;

	if(__has_no_ssystem)
	{
    		save_ssp = (long) Super((void *) 0L);
    		*((volatile long *)var) = val;
    		(void)Super((void *) save_ssp);
	}
	else
		(void)Ssystem(S_SETLVAL, var, val); /* note: root only! */
}

int
Getcookie (long cookie, long *p_value)
{
	if (__has_no_ssystem)
	{
		/* old method */
		long *cookieptr = (long*) get_sysvar(_p_cookies);
		
		if (cookieptr)
		{
			while (*cookieptr)
			{
				if (*cookieptr == cookie)
				{
					if (p_value)
						*p_value = cookieptr [1];
					
					return E_OK;
				}
				
				cookieptr += 2;
			}
		}
		if (p_value)
			*p_value = 0;
		return EERROR;
	}
	else
	{
		/* Ssystem supported, use it */
		int	r;
		long	v = -42;

		/* Make sure that P_VALUE is zeroed if the cookie can't
		   be found.  Reported by Tommy Andersen
		   (tommya@post3.tele.dk).  */
		if (p_value)
			*p_value = 0;
			
		r = Ssystem(S_GETCOOKIE, cookie, &v);
		/*
		 * Backward compatibility for MiNT 1.14.7:
		 * Ssystems() returns cookie value and ignores arg2!!
		 */
		if (r != -1 && v == -42)				
			v = r;
 
		if (r == -1)							/* not found */
		{
			v = 0;
			r = EERROR;
		}
		else
			r = E_OK;
		if (p_value)
			*p_value = v;
		return r;
	}
}

/* Convert a GEMDOS time to seconds since the epoch.
   The calculated value is always in local time.  */
static int const
mth_start[13] = { 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 };

time_t __unixtime (unsigned timestamp, unsigned datestamp)
{
  register int sec, min, hour;
  register int mday, mon, year;
  register long s;
  
  sec = (timestamp & 31) << 1;
  min = (timestamp >> 5) & 63;
  hour  = (timestamp >> 11) & 31;
  
  mday  = datestamp & 31;
  mon = ((datestamp >> 5) & 15) - 1;
  year  = 80 + ((datestamp >> 9) & 127);
  
  /* calculate tm_yday here */
  s = (mday - 1) + mth_start[mon] + /* Leap year correction.  */
    (((year % 4) != 0 ) ? 0 : (mon > 1));
  
  s = (sec) + (min * 60L) + (hour * 3600L) +
    (s * 86400L) + ((year - 70) * 31536000L) +
    ((year - 69) / 4) * 86400L;
  
  return s;
}

/*******************************************************************
getcwd: returns current working directory. By ERS.
This routine is in the public domain.
********************************************************************/

extern char _rootdir;	/* in main.c: user's preferred root directory */

char *getcwd(buf, size)
char *buf; int size;
{
	char _path[PATH_MAX];
	char *path;
	char drv;
	int buf_malloced = 0;
	int r;

	if (!buf)
	{
		if ((buf = malloc((size_t)size)) == 0)
			return NULL;
		buf_malloced = 1;
	}

	drv = Dgetdrv() + 'a';
	_path[0] = drv;
	_path[1] = ':';
	_path[2] = '\0';
	path = _path + 2;

	r = (int) Dgetcwd(path, 0, size - 2);

	if (r != 0 && r != -EINVAL)
	{
			if (buf_malloced)
				free(buf);
			errno = -r;
			return NULL;
	} else if (r == -EINVAL)
	{
		(void)Dgetpath(path, 0);
	}

	if (_rootdir && drv == _rootdir)
	{
		if (!*path)
		{
			path[0] = back_slash;
			path[1] = '\0';
		}
		_dos2unx((char *)path, buf, size);
		return buf;
	}
	_dos2unx(_path, buf, size);	/* convert DOS filename to unix */
	return buf;
}

/*
Given a pathname for which some system call returned EPATH, this function
decides if UNIX would have returned ENOENT instead.
Warning: path must be in dos format.
*/

int
_enoent(path)
  char *path;
{
  register char *s;
  struct stat st;
  long oldmask, xattr;

  for (s = path; *s; s++)
    /* nop */;
  oldmask = Psigblock(~0L);

  for ( ; s != path; s--)
  {
    if (*s == back_slash)
    {
      *s = '\0';
      if ((xattr = Fxattr(0, path, &st)) == -EINVAL) {
         (void) Psigsetmask(oldmask);
         return 0;
      }   
      if ((xattr == 0) && ((st.st_mode & S_IFMT) != S_IFDIR))
      {
        *s = back_slash;
        (void) Psigsetmask(oldmask);
        return 0; /* existing non-directory file in path, ENOTDIR ok */
      }
      *s = back_slash;
    }
  }
  (void) Psigsetmask(oldmask);
  return 1; /* should have been ENOENT */
}

/***************************************************************
chdir: change the directory and (possibly) the drive.
By ERS: it's in the public domain.
****************************************************************/

int chdir(dir)
const char *dir;
{
	int drv, old;
	int r;
	char tmp[PATH_MAX];
	register char *d;

	(void)_unx2dos(dir, tmp, sizeof (tmp));	/* convert Unix filename to DOS */
	d = tmp;
	old = Dgetdrv();
	if (*d && *(d+1) == ':')
	{
		drv = toupper(*d) - 'A';
		d+=2;
		(void)Dsetdrv(drv);
	}

	if (!*d)
	{		/* empty path means root directory */
		*d = back_slash;
		*(d+1) = '\0';
	}
	if ((r = Dsetpath(d)) < 0)
	{
		(void)Dsetdrv(old);
		if ((r == -EPATH) && _enoent(tmp))
		{
			r = -ENOENT;
		}
		errno = -r;
		return -1;
	}
	return 0;
}

/* Important note: Metados can have opendir for some device and do not
 * have it for others, so there is no point in having a status variable
 * saying there is an opendir call. Check this every time.
 */

extern ino_t __inode;	/* in stat.c */

/* a new value for DIR->status, to indicate that the file system is not
 * case sensitive.
 */
#define _NO_CASE  8


DIR *
opendir(uname)
	const char *uname;
{
	DIR *d;
	long r;
	_DTA *olddta;
	char name[PATH_MAX];
	char dirpath[PATH_MAX];
	char *p;

	d = malloc(sizeof(DIR));
	if (!d)
	{
		errno = ENOMEM;
		return d;
	}

	_unx2dos(uname, name, sizeof (name));

	r = Dopendir(name, 0);
	if (r != -EINVAL)
	{
		if ( (r & 0xff000000L) == 0xff000000L )
		{
			if ((r == -EPATH) && (_enoent(name)))
				r = -ENOENT;
			errno = (int) -r;
			free(d);
			return 0;
		}
		else
		{
			d->handle = r;
			d->buf.d_off = 0;

			/* test if the file system is case sensitive */
			r = Dpathconf(name, 6);
			if (r == 1 || r == -EINVAL)
				d->status = _NO_CASE;
			else
				d->status = 0;
			return d;
		}
	}
	d->handle = 0xff000000L;  /* indicate that the handle is invalid */

/* TOS emulation routines */

	p = name;
	if (p)
	{
	/* find the end of the string */
		for (p = name; *p; p++) ;

	/* make sure the string ends in '\' */
		if (*(p-1) != back_slash)
		{
			*p++ = back_slash;
		}
	}

	strcpy(p, "*.*");
	olddta = Fgetdta();
	Fsetdta(&(d->dta));
	r = Fsfirst(name, 0x17);
	Fsetdta(olddta);

	if (r == 0)
	{
		d->status = _STARTSEARCH;
	} else if (r == -ENOENT)
	{
		d->status = _NMFILE;
	} else
	{
		free(d);
		errno = (int) -r;
		return 0;
	}
	d->buf.d_off = 0;
/* for rewinddir: if necessary, build a relative path */
	if (name[1] == ':')
	{	/* absolute path, no problem */
		dirpath[0] = 0;
	} else
	{
		dirpath[0] = Dgetdrv() + 'A';
		dirpath[1] = ':';
		dirpath[2] = 0;
		if (*name != back_slash)
			(void)Dgetpath(dirpath+2, 0);
	}
	d->dirname = malloc(strlen(dirpath)+strlen(name)+1);
	if (d->dirname)
	{
		strcpy(d->dirname, dirpath);
		strcat(d->dirname, name);
	}
	return d;
}

/* Important note: the same comment for the status variable of
 * opendir/readdir under Metados applies also here.
 */

int
closedir(dirp)
	DIR *dirp;
{
	long r;

	/* The GNU libc closedir returns gracefully if a NULL pointer is
	   passed.  We follow here.  */
	if (dirp == NULL)
	{
		errno = EBADF;
		return -1;
	}
	
	if (dirp->handle != 0xff000000L)
		r = Dclosedir(dirp->handle);
	else
		r = 0;
	if (r == -EINVAL)
	{
		/* hmm, something went wrong, just ignore it. */
		r = 0;
	}
	free(dirp);
	return r;
}

/* Important note: under Metados, some file systems can have opendir/readdir/
 * closdir, so we must not have a status variable for these ones.
 * Instead, check the directory struct if there was an opendir call.
 */

struct dirent*
readdir(d)
	DIR *d;
{
	struct dbuf
	{
		long ino;
		char name[NAME_MAX + 1];
	} dbuf;
	long r;
	_DTA *olddta;
	struct dirent *dd = &d->buf;

	if (d == NULL)
	{
		errno = EBADF;
		return NULL;
	}
	
	if (d->handle != 0xff000000L)
	{
		/* The directory descriptor was optained by calling Dopendir(), as
		 * there is a valid handle.
		 */
		r = (int)Dreaddir((int)(NAME_MAX+1+sizeof(long)), d->handle, (char *) &dbuf);
		if (r == -ENMFIL)
			return 0;
		else if (r)
		{
			errno = (int) -r;
			return 0;
		}
		else
		{
			dd->d_ino = dbuf.ino;
			dd->d_off++;
			dd->d_reclen = (short)strlen(dbuf.name);
			strcpy(dd->d_name, dbuf.name);
			/* if file system is case insensitive, transform name to lowercase */
			if (d->status == _NO_CASE)
				strlwr(dd->d_name);
			return dd;
		}
	}
/* ordinary TOS search, using Fsnext. Note that the first time through,
 * Fsfirst has already provided valid data for us; for subsequent
 * searches, we need Fsnext.
 */
	if (d->status == _NMFILE)
		return 0;
	if (d->status == _STARTSEARCH)
	{
		d->status = _INSEARCH;
	} else
	{
		olddta = Fgetdta();
		Fsetdta(&(d->dta));
		r = Fsnext();
		Fsetdta(olddta);
		if (r == -ENMFIL)
		{
			d->status = _NMFILE;
			return 0;
		} else if (r)
		{
			errno = (int)-r;
			return 0;
		}
	}
	dd->d_ino = __inode++;
	dd->d_off++;
	_dos2unx(d->dta.dta_name, dd->d_name, sizeof (dd->d_name));
	dd->d_reclen = (short)strlen(dd->d_name);
	return dd;
}

/* Reentrant version of the above, use is deprecated because it imposes
   a performance loss.  The ordinary readdir() is already thread-safe
   in the MiNTLib but the existence of readdir_r() may facilitate 
   writing or compiling portable code.  */
int readdir_r (DIR *dirp, struct dirent *entry, struct dirent **result)
{
  if (result == NULL || *result == NULL || entry == NULL)
    {
      errno = EBADF;
      return -1;
    }
  *result = readdir (dirp);
  if (*result == NULL)
    return -1;
    
  *entry = **result;
  return 0;
}

/* for backwards compatibilty: if nonzero, files are checked to see if
 * they have the TOS executable magic number in them
 */

int	_x_Bit_set_in_stat = 0;

/* date for files (like root directories) that don't have one */
#define OLDDATE __unixtime(0,0)

/*
 * common routine for stat() and lstat(); if "lflag" is 0, then symbolic
 * links are automatically followed (like stat), if 1 then they are not
 * (like lstat)
 */

int
_do_stat(
	const char *_path,
	struct stat *st,
	int lflag)
{
	long	r;
	_DTA	*olddta;
	int	nval;
	char	path[PATH_MAX];
	char	*ext, drv;
	int	fd;
	short	magic;
	_DTA	d;
	int	isdot = 0;


	if (!_path)
	{
		errno = EFAULT;
		return -1;
	}

/*
 * _unx2dos returns 1 for device names (like /dev/con)
 */
	nval = _unx2dos(_path, path, sizeof (path));

	/* try to use the build in stat() call, but if the system does not
	 * have it, record that and never try again
	 */

	/* actually we can't do that, because Fxattr() works for MetaDOS devices
	 * but returns -EINVAL for other GEMDOS devices. Really unhappy solution.
	 * Since I don't want to patch chdir() and other calls I simply have to
	 * test the presence of Fxattr() every time the stat() is called.
	 * PS 970606
	 */

	r = Fxattr(lflag, path, st);
	if (r != -EINVAL)
	{
		if (r)
		{
			if ((r == -EPATH) && _enoent(path))
			{
				r = -ENOENT;
			}
			errno = (int) -r;
			return -1;
		}
		else
		{
			__UNIXTIME(st->st_mtime);
			__UNIXTIME(st->st_atime);
			__UNIXTIME(st->st_ctime);
		/* Most versions of Unix count in 512 byte blocks */
			st->st_blocks = (st->st_blocks * st->st_blksize) / 512;
		/* if we hit a symbolic link, try to get its size right */
			if (lflag && ((st->st_mode & S_IFMT) == S_IFLNK))
			{
				char buf[PATH_MAX + 1];
				char buf1[PATH_MAX + 1];
				r = Freadlink(PATH_MAX, buf, path);
				if (r < 0)
				  {
					errno = (int) -r;
					return -1;
				  }
				buf[PATH_MAX] = 0;
				_dos2unx (buf, buf1, sizeof (buf1));
				st->st_size = strlen (buf1);
			}
			return 0;
		}
	}

/* otherwise, check to see if we have a name like CON: or AUX: */
	if (nval == 1)
	{
		st->st_mode = S_IFCHR | 0600;
		st->st_attr = 0;
		st->st_ino = __inode++;
		st->st_rdev = 0;
		st->st_mtime = st->st_ctime = st->st_atime = 
			time((time_t *)0) - 2;
		st->st_dev = 0;
		st->st_nlink = 1;
		st->st_uid = geteuid();
		st->st_gid = getegid();
		st->st_size = st->st_blocks = 0;
		st->st_blksize = 1024;
		return 0;
	}

/* A file name: check for root directory of a drive */
	if (path[0] == back_slash && path[1] == 0)
	{
		drv = Dgetdrv() + 'A';
		goto rootdir;
	}

	if ( ((drv = path[0]) != 0) && path[1] == ':' &&
	     (path[2] == 0 || (path[2] == back_slash && path[3] == 0)) )
	{
rootdir:
		st->st_mode = S_IFDIR | 0755;
		st->st_attr = FA_DIR;
		st->st_dev = isupper(drv) ? drv - 'A' : drv - 'a';
		st->st_ino = 2;
		st->st_mtime = st->st_ctime = st->st_atime = OLDDATE;
		goto fill_dir;
	}

#if FIX_PC
#define index strchr
#endif

/* forbid wildcards in path names */
	if (index(path, '*') || index(path, '?'))
	{
		errno = ENOENT;
		return -1;
	}

/* OK, here we're going to have to do an Fsfirst to get the date */
/* NOTE: Fsfirst(".",-1) or Fsfirst("..",-1) both fail under TOS,
 * so we kludge around this by using the fact that Fsfirst(".\*.*"
 * or "..\*.*" will return the correct file first (except, of course,
 * in root directories :-( ).
 * NOTE2: Some versions of TOS don't like Fsfirst("RCS\\", -1) either,
 * so we do the same thing if the path ends in back_slash.
 */

/* find the end of the string */
	for (ext = path; ext[0] && ext[1]; ext++) ;

/* add appropriate kludge if necessary */
	if (*ext == '.' && (ext == path || ext[-1] == back_slash || ext[-1] == '.'))
	{
		isdot = 1;
		strcat(path, "" sback_slash "*.*");
	} else if (*ext == back_slash)
	{
		isdot = 1;
		strcat(path, "*.*");
	}
	olddta = Fgetdta();
	Fsetdta(&d);
	r = Fsfirst(path, 0xff);
	Fsetdta(olddta);
	if (r < 0)
	{
		if (isdot && r == -ENOENT) goto rootdir;
		errno = (int) -r;
		return -1;
	}	

	if (isdot && ((d.dta_name[0] != '.') || (d.dta_name[1])))
	{
		goto rootdir;
	}

	st->st_mtime = st->st_ctime = st->st_atime =
		__unixtime(d.dta_time, d.dta_date);
	if (((drv = *path) != 0) && path[1] == ':')
		st->st_dev = toupper(drv) - 'A';
	else
		st->st_dev = Dgetdrv();

	st->st_ino = __inode++;
	st->st_attr = d.dta_attribute;
/*
	if (__mint && st->st_dev == ('Q' - 'A'))
			st->st_mode = 0644 | S_IFIFO;
	else
*/
	{
		st->st_mode = 0644 | (st->st_attr & FA_DIR ?
			      S_IFDIR | 0111 : S_IFREG);
	}

	if (st->st_attr & FA_RDONLY)
		st->st_mode &= ~0222;	/* no write permission */
	if (st->st_attr & FA_HIDDEN)
		st->st_mode &= ~0444;	/* no read permission */

/* check for a file with an executable extension */
	ext = strrchr(_path, '.');
	if (ext)
	{
		if (!strcmp(ext, ".ttp") || !strcmp(ext, ".prg") ||
		    !strcmp(ext, ".tos") || !strcmp(ext, ".g") ||
		    !strcmp(ext, ".sh")	 || !strcmp(ext, ".bat"))
		{
			st->st_mode |= 0111;
		}
	}
	if ( (st->st_mode & S_IFMT) == S_IFREG)
	{
		if (_x_Bit_set_in_stat)
		{
			if ((fd = (int) Fopen(path,0)) < 0)
			{
				errno = -fd;
				return -1;
			}
			magic = 0;
			(void)Fread(fd,2,(char *)&magic);
			(void)Fclose(fd);
			if (magic == 0x601A	/* TOS executable */
			    || magic == 0x2321) /* "#!" shell file */
				st->st_mode |= 0111;
		}
		st->st_size = d.dta_size;
	/* in Unix, blocks are measured in 512 bytes */
		st->st_blocks = (st->st_size + 511) / 512;
		st->st_nlink = 1; /* we dont have hard links */
	} else
	{
fill_dir:
		st->st_size = 1024;
		st->st_blocks = 2;
		st->st_nlink = 2;	/* "foo" && "foo/.." */
	}

	st->st_rdev = 0;
	st->st_uid = geteuid();	/* the current user owns every file */
	st->st_gid = getegid();
	st->st_blksize = 1024;
	return 0;
}

int
stat(
	const char *path,
	struct stat *st)
{
	return _do_stat(path, st, 0);
}


/* from Dale Schumacher's dLibs */
/* heavily modified by ers and jrb */

int	__mint;		/* 0 for TOS, MiNT version number otherwise */
int	_pdomain;       /* errorcode of Pdomain call */

char	_rootdir = 'u';	/* user's preferred root directory */

clock_t _starttime;	/* 200 HZ tick when we started the program */
clock_t _childtime;	/* time consumed so far by our children */
FILE	_iob[_NFILE];	/* stream buffers initialized below */

/* functions registered by user for calling at exit */
typedef void (*ExitFn) (void);
ExitFn *_at_exit;
int _num_at_exit;	/* number of functions registered - 1 */

/* Set to 1 if secure mode is advised.  */
int __libc_enable_secure = 1;

/* supplied by the user */
int main (int, char **, char **);

#if defined(__TURBOC__) && !defined(__NO_FLOAT__)
void _fpuinit(void); /* in PCFLTLIB.LIB */

long _fpuvect[10];
long _pfumode;
long _fpuctrl;
#endif


#if FIX_PC
int __default_mode__;
#endif

short
__main(
	long _argc,
	char **_argv, char **_envp)
{
	register FILE *f;
	register int i;
	char *s, *pconv;
	long l;
#if ! FIX_PC
	extern int __default_mode__;	/* in defmode.c or defined by user */
#endif
	extern short _app;	/* tells if we're an application or acc */

	char *p, *tmp;
	size_t len, cnt;
	
	_num_at_exit = 0;
	errno = 0;

#if defined(__TURBOC__) && !defined(__NO_FLOAT__)
	_fpuinit();
#endif

	__has_no_ssystem = Ssystem (-1, NULL, NULL);

	_starttime = get_sysvar (_hz_200);
	_childtime = 0;

/*
 * check for MiNT
 */
 	if (Getcookie (C_MiNT, &l) == C_FOUND)
 		__mint = (int) l;
 	else
 		__mint = 0;
 		
	if (_app)
		_pdomain = Pdomain(1);	/* set MiNT domain */

/* Check if we are suid or guid.  We simply use the bare operating
   system calls because we only check for differences.  If it fails
   once it will always fail.  */
   	if ((Pgeteuid () == Pgetuid ()) && (Pgetegid () == Pgetgid ()))
	     	__libc_enable_secure = 0;
     
/*
 * initialize UNIXMODE stuff. Note that this library supports only
 * a few of the UNIXMODE variables, namely "b" (binary mode default)
 * and "r<c>" (default root directory).
 */
 	if (__libc_enable_secure)
 	{
 	  /* Don't do any TOS nonsense in secure mode.  */
 	  __default_mode__ = _IOBIN;
 	  _rootdir = 'u';
	} else if ((s = getenv("UNIXMODE")) != 0)
	{
		while (*s)
		{
			if (*s == 'b')
				__default_mode__ = _IOBIN;
			else if (*s == 'r' && s[1])
				_rootdir = *++s;
			else if (*s == '.' && s[1])
				s++;	/* ignore */
			s++;
		}
	}

	if (_rootdir >= 'A' && _rootdir <= 'Z')
		_rootdir = _rootdir - 'A' + 'a';

/*
 * if we're running under MiNT, and the current drive is U:, then this
 * must be our preferred drive
 */
	if (!_rootdir && __mint >= 9)
	{
		if (Dgetdrv() == 'U'-'A')
			_rootdir = 'u';
	}

#if ! FIX_PC
	/* clear isatty status for dumped programs */
	for (i = 0; i < __NHANDLES; i++)
	  __open_stat[i].status = FH_UNKNOWN;
#endif

/* if stderr is not re-directed to a file, force 2 to console
 * (UNLESS we've been run from a shell we trust, i.e. one that supports
 *  the official ARGV scheme, in which case we leave stderr be).
 */
	if(!*_argv[0] && isatty(2))
	    (void)Fforce(2, -1);

#if ! FIX_PC
	stdin->_flag = _IOREAD|_IOFBF|__default_mode__;
	stdout->_flag = _IOWRT|_IOLBF|__default_mode__;
	stderr->_flag = _IORW|_IONBF|__default_mode__;
			 /* some brain-dead people read from stderr */

	for(i = 0, f = _iob; i < 3; ++i, ++f)
	{	/* flag device streams */
	    if(isatty(f->_file = i))
			f->_flag |= (__mint ? _IODEV|_IOBIN : _IODEV);
	    else
	        if(f == stdout)
	        { /* stderr is NEVER buffered */
	        /* if stdout re-directed, make it full buffered */
	            f->_flag &= ~(_IOLBF | _IONBF);
	            f->_flag |=  _IOFBF;
	        }
	    _getbuf(f);	/* get a buffer */
	}
 	for(i = 3; i < _NFILE; i++, f++)
 	{
	  f->_flag = 0;		/* clear flags, if this is a dumped program */
	}
#endif
	/* Fix up environment, if necessary. All variables listed in PCONVERT
	 * are affected (by default, only PATH will be converted).
	 * The "standard" path separators for PATH are
	 * ',' and ';' in the Atari world, but POSIX mandates ':'. This
	 * conflicts with the use of ':' as a drive separator, so we
	 * also convert names like A:\foo to /dev/A/foo
	 * NOTE: this conversion must be undone in spawn.c so that
	 * old fashioned programs will understand us!
	 */

	for (i = 0; (pconv = _envp[i]) != 0; i++)
	{
		if (! strncmp(pconv, "PCONVERT=", 9))
		{
			pconv += 9;
			break;
		}
	}

	for (i = 0; (s = _envp[i]) != 0; i++)
	{

		if (pconv)
		{

			p = pconv;
			while (*p)
			{
				
				tmp = p; len = 0;
				while (*tmp && *tmp != ',')
				{
					tmp++; len++;
				}
				
				if (!strncmp(s, p, len) && s[len] == '=')
				{
				  size_t size;
				  len++;
				  tmp = s + len; /* tmp now after '=' */
				  cnt = 1;
				  while (*tmp)
				  {  /* count words */
				    if (*tmp == ';' || *tmp == ',')
				      cnt++;
				    tmp++;
				  }
				  size = tmp - s + cnt * 5;
				  _envp[i] = malloc(size);
				  strncpy(_envp[i], s, len);
				  _path_dos2unx(s + len, _envp[i] + len,
						size - len);
				  _envp[i] = realloc(_envp[i], 
						        strlen(_envp[i]) + 1);
				  break;		
				}
				
				if (! *tmp) break;
				p = tmp + 1;
			}
		}	
		else	/* ! pconv */
		{
		/* PATH is always converted */
			if (s[0] == 'P' && s[1] == 'A' && s[2] == 'T' &&
			    s[3] == 'H' && s[4] == '=')
			{
			  size_t size;
			  tmp = s + 5; /* tmp now after '=' */	
			  cnt = 1;
			  while (*tmp)
			  {
			    /* count words */
			    if (*tmp == ';' || *tmp == ',')
			      cnt++;
			    tmp++;
			  }
			  size = tmp - s + cnt * 5;
			  _envp[i] = malloc(size);
			  strncpy(_envp[i], s, 5);
			  _path_dos2unx(s + 5, _envp[i] + 5, size - 5);
			  _envp[i] = (char *) realloc(_envp[i], 
			                              strlen(_envp[i]) + 1);
			  break;
			}
		}
	}

	return main(_argc, _argv, _envp);
}

/*
 * returns 0 for ordinary files, 1 for special files (like /dev/tty)
 */

int
_unx2dos(
	const char *unx,
	char *dos,
	size_t len)
{
	const char *u;
	char *d, c;

	dos[0] = 0;
	len--;			/* for terminating NUL */
	u = unx; d = dos;
	if (!strncmp(u, "" sslash "dev" sslash "", 5))
	{
		u += 5;
	/* make /dev/A/foo the same as A:/foo */

	if (*u && isalpha (*u)
	    && (u[1] == 0 || (u[1] == slash || u[1] == back_slash)))
	{
		d[0] = *u++;
		d[1] = ':';
		d += 2;
		len -= 2;
	}

	/* check for a unix device name */
		else if (__mint)
		{
			strcpy(d, "U:" sback_slash "dev" sback_slash ""); d += 7;
			len -= 7;
		}
		else
		{
			strncpy(d, u, len);
			len -= strlen (u);
			strncat(d, ":", len);
			if (!strcmp(d, "tty:"))
				strcpy(d, "con:");
			return 1;
		}
	} else if (__mint && !strncmp(u, "" sslash "pipe" sslash "", 6))
	{
		u += 6;

		strcpy(d, "U:" sback_slash "pipe" sback_slash ""); d += 8;
		len -= 8;

	} else if (*u == slash && _rootdir)
	{
		*d++ = _rootdir;
		*d++ = ':';
		len -= 2;
	}

	while( (c = *u++) != 0 )
	{
		if (c == slash)
			c = back_slash;
		*d++ = c;
		len--;
		if (len == 0)
			break;
	}
	*d = 0;
	return 0;
}

int
_dos2unx(
	const char *dos,
	char *unx,
	size_t len)
{
	register char c;

	len--;			/* for terminating NUL */
	/* replace A:\x with /dev/a/x,
	 * replace A:\x with /x, if _rootdir is 'a',
	 * replace A:\x with /a/x, if _rootdir is 'u'.
	 * BUG/FEATURE: A:x is converted to A:\x, you lose the feature
	 *              of one current directory per device.
	 *              This is because we assume that /dev/a/x is always 
	 *              an absolute path.
	 */ 
	if (*dos && dos[1] == ':')
	{
		register char dev = tolower(*dos);
		dos += 2;
		if (dev != _rootdir)
		{
			if (_rootdir != 'u')
			{
				*unx++ = slash; *unx++ = 'd'; 
				*unx++ = 'e'; *unx++ = 'v';
				len -= 4;
			}
			*unx++ = slash;
			*unx++ = dev;
			len -= 2;
		}
		if (*dos != slash && *dos != back_slash)
		{
				*unx++ = slash;
				len--;
		}
	}
	/* convert slashes
	 */
	while ( (c = *dos++) != 0)
	{
		if (c == back_slash)
			c = slash;
		else if (__mint < 7)
			c = tolower(c);
		*unx++ = c;
		len--;
		if (len == 0)
			break;
	}
	*unx = 0;
	return 0;
}

int 
_path_dos2unx(
	const char *dos,
	char *unx,
	size_t len)
{
	char buf[MAXPATHLEN], *s;

	while (*dos)
	{
		s = buf;
		while (*dos)
		{
			if (*dos == ';' || *dos == ',')
			{
				dos++;
				break;
			}
			if (s < buf + sizeof (buf) - 1)
				*s++ = *dos;
			dos++;
		}
		*s = 0;
		_dos2unx(buf, unx, len);
		while (*unx)
		{
			unx++;
			len--;
		}
		if (len <= 10)
			break;
		if (*dos)
		{
			*unx++ = ':';
			len--;
		}
	}

	*unx = 0;
	return 0;
}

extern gid_t __gid;

gid_t
getgid(void)
{
	long r;
	static short have_getgid = 1;

	if (have_getgid)
	{
		r = Pgetgid();
		if (r == -EINVAL)
			have_getgid = 0;
		else
			return (gid_t)r;
	}
	return __gid;
}

gid_t
getegid(void)
{
	long r;
  	static short have_getegid = 1;

  	if (have_getegid)
  	{
		r = Pgetegid();
                if (r == -EINVAL)
 			have_getegid = 0;
		else
			return (gid_t)r;
	}
	return getgid();	     
}

extern uid_t __uid;

uid_t
getuid(void)
{
	long r;
	static short have_getuid = 1;

	if (have_getuid)
	{
		r = Pgetuid();
		if (r == -EINVAL)
			have_getuid = 0;
		else
			return (uid_t)r;
	}
	return __uid;
}

uid_t
geteuid(void)
{
	long r;
  	static short have_geteuid = 1;

  	if (have_geteuid)
  	{
		r = Pgeteuid();
                if (r == -EINVAL)
 			have_geteuid = 0;
		else
			return (uid_t)r;
	}
	return getuid();
}

