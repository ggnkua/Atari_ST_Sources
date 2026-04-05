/* header file for POSIX directory access routines */

#ifndef _SYS_DIRENT_H
# define _SYS_DIRENT_H 1

#ifndef _FEATURES_H
# include <features.h>
#endif

__BEGIN_DECLS

#include <sys/types.h>

#include <bits/dirent.h>

/* This file defines `struct dirent'.

   It defines the macro `_DIRENT_HAVE_D_NAMLEN' iff there is a `d_namlen'
   member that gives the length of `d_name'.

   It defines the macro `_DIRENT_HAVE_D_RECLEN' iff there is a `d_reclen'
   member that gives the size of the entire directory entry.

   It defines the macro `_DIRENT_HAVE_D_OFF' iff there is a `d_off'
   member that gives the file offset of the next directory entry.

   It defines the macro `_DIRENT_HAVE_D_TYPE' iff there is a `d_type'
   member that gives the type of the file.
 */

#if (defined __USE_BSD || defined __USE_MISC) && !defined d_fileno
# define d_ino	d_fileno		 /* Backward compatibility.  */
#endif

/* These macros extract size information from a `struct dirent *'.
   They may evaluate their argument multiple times, so it must not
   have side effects.  Each of these may involve a relatively costly
   call to `strlen' on some systems, so these values should be cached.

   _D_EXACT_NAMLEN (DP)	returns the length of DP->d_name, not including
   its terminating null character.

   _D_ALLOC_NAMLEN (DP)	returns a size at least (_D_EXACT_NAMLEN (DP) + 1);
   that is, the allocation size needed to hold the DP->d_name string.
   Use this macro when you don't need the exact length, just an upper bound.
   This macro is less likely to require calling `strlen' than _D_EXACT_NAMLEN.
   */

#ifdef _DIRENT_HAVE_D_NAMLEN
# define _D_EXACT_NAMLEN(d) ((d)->d_namlen)
# define _D_ALLOC_NAMLEN(d) (_D_EXACT_NAMLEN (d) + 1)
#else
# define _D_EXACT_NAMLEN(d) (strlen ((d)->d_name))
# ifdef _DIRENT_HAVE_D_RECLEN
#  define _D_ALLOC_NAMLEN(d) (((char *) (d) + (d)->d_reclen) - &(d)->d_name[0])
# else
#  define _D_ALLOC_NAMLEN(d) (sizeof (d)->d_name > 1 ? sizeof (d)->d_name : \
			      _D_EXACT_NAMLEN (d) + 1)
# endif
#endif


/* This is the data type of directory stream objects.
   The actual structure is opaque to users.  */
typedef struct __dirstream DIR;

/* Open a directory stream on NAME.
   Return a DIR stream on the directory, or NULL if it could not be opened.  */
extern DIR *opendir (__const char *__name) __THROW;

/* Close the directory stream DIRP.
   Return 0 if successful, -1 if not.  */
extern int closedir (DIR *__dirp) __THROW;

/* Read a directory entry from DIRP.  Return a pointer to a `struct
   dirent' describing the entry, or NULL for EOF or error.  The
   storage returned may be overwritten by a later readdir call on the
   same DIR stream.  */
extern struct dirent *readdir (DIR *__dirp) __THROW;

#if defined __USE_POSIX || defined __USE_MISC
/* Reentrant version of `readdir'.  Return in RESULT a pointer to the
   next entry.  */
extern int readdir_r (DIR *__restrict __dirp,
		      struct dirent *__restrict __entry,
		      struct dirent **__restrict __result) __THROW;
#endif

/* Rewind DIRP to the beginning of the directory.  */
extern void rewinddir (DIR *__dirp) __THROW;

#if defined __USE_BSD || defined __USE_MISC || defined __USE_XOPEN

/* Seek to position POS on DIRP.  */
extern void seekdir (DIR *__dirp, long int __pos) __THROW;

/* Return the current position of DIRP.  */
extern long int telldir (DIR *__dirp) __THROW;

#endif /* Use BSD or misc or xopen.  */

#if defined __USE_BSD || defined __USE_MISC

/* Scan the directory DIR, calling SELECTOR on each directory entry.
   Entries for which SELECT returns nonzero are individually malloc'd,
   sorted using qsort with CMP, and collected in a malloc'd array in
   *NAMELIST.  Returns the number of entries selected, or -1 on error.  */
extern int scandir (__const char *__restrict __dir,
		    struct dirent ***__restrict __namelist,
		    int (*__selector) (__const struct dirent *),
		    int (*__cmp) (const struct dirent **, const struct dirent **)) __THROW;

/* Function to compare two `struct dirent's alphabetically.  */
extern int alphasort (const struct dirent **, const struct dirent **) __THROW;

# ifdef __USE_GNU
/* Function to compare two `struct dirent's by name & version.  */
extern int versionsort (const struct dirent **, const struct dirent **) __THROW;
# endif

#endif /* Use BSD or misc.  */


__END_DECLS

#endif /* _SYS_DIRENT_H */
