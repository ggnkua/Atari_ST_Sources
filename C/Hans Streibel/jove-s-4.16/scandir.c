/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/*
 * This file is used as a compiled module by Jove and also included as
 * source in recover.c
 */
#ifndef TUNED
# include "jove.h"
#endif
#include "scandir.h"

#ifdef F_COMPLETION	/* the body is the rest of this file */

#ifdef UNIX

# include <sys/stat.h>

# if defined(M_XENIX) && !defined(M_UNIX)
   /* XENIX, but not SCO UNIX, which pretends to be XENIX! */
#  include <sys/ndir.h>
#  ifndef dirent
#   define dirent direct
#  endif
# endif

# ifdef BSD_DIR
#  include <sys/dir.h>
#  ifndef dirent
#   define dirent direct
#  endif
# endif

/* default to dirent.h */
# if !defined(dirent) && !defined(DIRENT_EMULATE)
#  include <dirent.h>
# endif

# ifdef DIRENT_EMULATE

typedef struct {
	int	d_fd;		/* File descriptor for this directory */
} DIR;

private int
closedir(dp)
DIR	*dp;
{
	(void) close(dp->d_fd);
	free((UnivPtr) dp);
	return 0;	/* don't know how to fail */
}

private DIR *
opendir(dir)
char	*dir;
{
	int	fd;

	if ((fd = open(dir, 0)) != -1) {
		struct stat	stbuf;

		if ((fstat(fd, &stbuf) != -1)
		&& (stbuf.st_mode & S_IFMT) == S_IFDIR)
		{
			/* Success! */
			DIR	*dp = (DIR *) emalloc(sizeof *dp);

			dp->d_fd = fd;
			return dp;
		}
		/* this isn't a directory! */
		(void) close(fd);
	}
	return NULL;
}

private dirent *
readdir(dp)
DIR	*dp;
{
	static dirent	dir;

	do {
		if (read(dp->d_fd, (UnivPtr) &dir, sizeof dir) != sizeof dir)
			return NULL;
	} while (dir.d_ino == 0);

	return &dir;
}

#endif /* DIRENT_EMULATE */

/* jscandir returns the number of entries or -1 if the directory cannot
   be opened or malloc fails. */

int
jscandir(dir, nmptr, qualify, sorter)
char	*dir;
char	***nmptr;
bool	(*qualify) ptrproto((char *));
int	(*sorter) ptrproto((UnivConstPtr, UnivConstPtr));
{
	DIR	*dirp;
	struct  dirent	*entry;
	char	**ourarray;
	unsigned int	nalloc = 10,
			nentries = 0;

	if ((dirp = opendir(dir)) == NULL)
		return -1;
	ourarray = (char **) emalloc(nalloc * sizeof (char *));
	while ((entry = readdir(dirp)) != NULL) {
		if (qualify != NULL && !(*qualify)(entry->d_name))
			continue;
		/* note: test ensures one space left in ourarray for NULL */
		if (nentries+1 == nalloc)
			ourarray = (char **) erealloc((UnivPtr) ourarray, (nalloc += 10) * sizeof (char *));
# ifdef DIRECTORY_ADD_SLASH
		/* ??? what the heck is this?  dirent doesn't have this info. */
		if ((entry.attrib&_A_SUBDIR) != 0)
			strcat(entry->d_name, "/");
# endif
		ourarray[nentries++] = copystr(entry->d_name);
	}
	closedir(dirp);
	ourarray[nentries] = NULL;

	if (sorter != NULL)
		qsort((UnivPtr) ourarray, nentries, sizeof (char **), sorter);
	*nmptr = ourarray;

	return nentries;
}

#endif /* UNIX */

#ifdef MSFILESYSTEM
bool	MatchDir = NO;
#endif

#ifdef MSDOS
# include <dos.h>

# ifndef ZTCDOS
#  include <search.h>
# endif

/* Scandir returns the number of entries or -1 if the directory cannot
   be opened or malloc fails. */

int
jscandir(dir, nmptr, qualify, sorter)
char	*dir;
char	***nmptr;
bool	(*qualify) ptrproto((char *));
int	(*sorter) ptrproto((UnivConstPtr, UnivConstPtr));
{
	struct find_t entry;
	char	**ourarray;
	unsigned int	nalloc = 10,
			nentries = 0;

	{
		char dirname[FILESIZE];
		char *ptr;

		strcpy(dirname, dir);
		ptr = &dirname[strlen(dirname)-1];
		if (!((dirname[1] == ':' && dirname[2] == '\0') || *ptr == '/' || *ptr == '\\'))
			*++ptr = '/';
		strcpy(ptr+1, "*.*");

		if (_dos_findfirst(dirname, MatchDir? _A_SUBDIR : _A_NORMAL|_A_RDONLY|_A_HIDDEN|_A_SUBDIR, &entry))
		   return -1;
	}
	ourarray = (char **) emalloc(nalloc * sizeof (char *));
	do  {
		char filename[FILESIZE];

		if (MatchDir && (entry.attrib&_A_SUBDIR) == 0)
			continue;
		strlwr(entry.name);
		if (qualify != NULL && !(*qualify)(entry.name))
			continue;
		/* note: test ensures one space left in ourarray for NULL */
		if (nentries+1 == nalloc)
			ourarray = (char **) erealloc((char *) ourarray, (nalloc += 10) * sizeof (char *));
		strcpy(filename, entry.name);
#ifdef DIRECTORY_ADD_SLASH
		if ((entry.attrib&_A_SUBDIR) != 0)
			strcat(filename, "/");
#endif
		ourarray[nentries++] = copystr(filename);
	} while (_dos_findnext(&entry) == 0);
	ourarray[nentries] = NULL;

	if (sorter != (int (*) ptrproto((UnivConstPtr, UnivConstPtr)))NULL)
		qsort((char *) ourarray, nentries, sizeof (char **), sorter);
	*nmptr = ourarray;

	return nentries;
}

#endif /* MSDOS */

#ifdef WIN32

# include <windows.h>

/* Scandir returns the number of entries or -1 if the directory cannot
   be opened or malloc fails. */

int
jscandir(dir, nmptr, qualify, sorter)
char	*dir;
char	***nmptr;
bool	(*qualify) ptrproto((char *));
int	(*sorter) ptrproto((UnivConstPtr, UnivConstPtr));
{
	WIN32_FIND_DATA entry;
	HANDLE findHand;
	char	**ourarray;
	unsigned int	nalloc = 10,
			nentries = 0;

	{
		char dirname[_MAX_PATH];
		char *ptr;

		strcpy(dirname, dir);
		ptr = &dirname[strlen(dirname)-1];
		if (!((dirname[1] == ':' && dirname[2] == '\0') || *ptr == '/' || *ptr == '\\'))
			*++ptr = '/';
		strcpy(ptr+1, "*.*");

		if ((findHand = FindFirstFile(dirname, &entry)) == INVALID_HANDLE_VALUE)
			return -1;
	}
	ourarray = (char **) emalloc(nalloc * sizeof (char *));
	do  {
		char filename[_MAX_PATH];

		if (MatchDir && (entry.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY) == 0)
			continue;
		strcpy(filename, entry.cFileName);
		strlwr(entry.cFileName);
		if (qualify != NULL && !(*qualify)(entry.cFileName))
			continue;
		/* note: test ensures one space left in ourarray for NULL */
		if (nentries+1 == nalloc)
			ourarray = (char **) erealloc((char *) ourarray, (nalloc += 10) * sizeof (char *));
#ifdef DIRECTORY_ADD_SLASH
		if ((entry.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY) != 0)
			strcat(filename, "/");
#endif
		ourarray[nentries++] = copystr(filename);
	} while (FindNextFile(findHand, &entry));
	FindClose(findHand);
	ourarray[nentries] = NULL;

	if (sorter != (int (*)ptrproto((UnivConstPtr, UnivConstPtr)))NULL)
		qsort((char *) ourarray, nentries, sizeof (char **), sorter);
	*nmptr = ourarray;

	return nentries;
}

#endif /* WIN32 */

void
freedir(nmptr, nentries)
char	***nmptr;
int	nentries;
{
	char	**ourarray = *nmptr;

	while (--nentries >= 0)
		free((UnivPtr) *ourarray++);
	free((UnivPtr) *nmptr);
	*nmptr = NULL;
}
#endif /* F_COMPLETION */
