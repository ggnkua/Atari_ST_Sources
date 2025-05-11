/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A public domain implementation of BSD directory routines for MS-DOS/atari.
 *  Written by Michael Rendell ({uunet,utai}michael@garfield), August 1897
 *
 * $Header: opendir.c,v 1.2 88/01/29 18:03:58 m68k Exp $
 *
 * jrd 1.2
 *
 * $Log:	opendir.c,v $
 * Revision 1.1  88/01/29  18:03:58  m68k
 * Initial revision
 * 
 */
#ifdef gem
#define GEMDOS
# include <types.h>
# include <stat.h>
# include <dir.h>
# include <param.h>
# include <osbind.h>
#else /* !GEMDOS */
# include <sys/types.h>
# include <sys/stat.h>
# include <sys/dir.h>
# ifdef	MSDOS
# include	<dos.h>
# endif	/* MSDOS */
#endif	/* GEMDOS */
#include	<memory.h>
#include	<string.h>

#ifndef	NULL
# define	NULL	0
#endif	/* NULL */

#ifndef	MAXPATHLEN
# define	MAXPATHLEN	67
#endif	/* MAXPATHLEN */

#ifdef	MSDOS
/* file attribute stuff */
#define	FA_RONLY	0x01
#define	FA_HIDDEN	0x02
#define	FA_SYSTEM	0x04
#define	FA_LABEL	0x08
#define	FA_DIR		0x10
#define	FA_ARCHIVE	0x20

/* dos call values */
#define	DOSI_FINDF	0x4e
#define	DOSI_FINDN	0x4f
#define	DOSI_SDTA	0x1a

/* what find first/next calls look use */
struct _dta {
	char		dta_buf[21];
	char		dta_attribute;
	unsigned short	dta_time;
	unsigned short	dta_date;
	long		dta_size;
	char		dta_name[14];
};
#endif	/* MSDOS */

#define	Newisnull(a, t)		((a = (t *) malloc((u_long) sizeof(t))) == (t *) NULL)
#define	ATTRIBUTES		(FA_DIR | FA_HIDDEN | FA_SYSTEM)


static	char	*getdirent();
static	void	setdta();

static	struct _dta	dtabuf;
#ifdef	MSDOS
static	struct _dta	*dtapnt = &dtabuf;
static	union REGS	reg, nreg;

# if	defined(M_I86LM)
static	struct SREGS	sreg;
# endif
#endif	/* MSDOS */

DIR	*
opendir(name)
	char	*name;
{
	DIR			*dirp;
	char			c;
	char			*s;
	struct _dircontents	*dp;
	char			nbuf[MAXPATHLEN + 1];
	
#ifdef	MSDOS
	{
		struct	stat		statb;

		if (stat(name, &statb) < 0
			|| (statb.st_mode & S_IFMT) != S_IFDIR)
				return (DIR *) NULL;
		setdta();
	}
#endif	/* MSDOS */
#ifdef	GEMDOS
	{
		/* This bit of nastyness is due to the fact that Fattrib()
		 * does not do as it is ment to - i.e. it always fails when
		 * used on directories.  Piss me off!
		 */
		if (index(name, '*') || index(name, '?'))
			return (DIR *) NULL;
		setdta();
		if (getdirent(name) == (char *) NULL ||
			!(dtabuf.dta_attribute & FA_DIR))
				return (DIR *) NULL;
	}
#endif	/* GEMDOS */
	if (Newisnull(dirp, DIR))
		return (DIR *) NULL;
	if (*name && (c = name[strlen(name) - 1]) != '\\' && c != '/')
		(void) strcat(strcpy(nbuf, name), "\\*.*");
	else
		(void) strcat(strcpy(nbuf, name), "*.*");
	dirp->dd_loc = 0;
	dirp->dd_contents = dirp->dd_cp = (struct _dircontents *) NULL;
	if ((s = getdirent(nbuf)) == (char *) NULL)
		return dirp;
	do {
		if (Newisnull(dp, struct _dircontents) || (dp->_d_entry =
			malloc((u_long) (strlen(s) + 1))) == (char *) NULL)
		{
			if (dp)
				free((char *) dp);
			closedir(dirp);
			return (DIR *) NULL;
		}
		if (dirp->dd_contents)
			dirp->dd_cp = dirp->dd_cp->_d_next = dp;
		else
			dirp->dd_contents = dirp->dd_cp = dp;
		(void) strcpy(dp->_d_entry, s);
		dp->_d_next = (struct _dircontents *) NULL;
	} while ((s = getdirent((char *) NULL)) != (char *) NULL);
	dirp->dd_cp = dirp->dd_contents;

	return dirp;
}

#ifdef	MSDOS
static	char	*
getdirent(dir)
	char	*dir;
{
	if (dir != (char *) NULL) {		/* get first entry */
		reg.h.ah = DOSI_FINDF;
		reg.h.cl = ATTRIBUTES;
# if	defined(M_I86LM)
		reg.x.dx = FP_OFF(dir);
		sreg.ds = FP_SEG(dir);
# else
		reg.x.dx = (unsigned) dir;
# endif
	} else {				/* get next entry */
		reg.h.ah = DOSI_FINDN;
# if	defined(M_I86LM)
		reg.x.dx = FP_OFF(dtapnt);
		sreg.ds = FP_SEG(dtapnt);
# else
		reg.x.dx = (unsigned) dtapnt;
# endif
	}
# if	defined(M_I86LM)
	intdosx(&reg, &nreg, &sreg);
# else
	intdos(&reg, &nreg);
# endif
	if (nreg.x.cflag)
		return (char *) NULL;

	return dtabuf.dta_name;
}

static	void
setdta()
{
	reg.h.ah = DOSI_SDTA;
# if	defined(M_I86LM)
	reg.x.dx = FP_OFF(dtapnt);
	sreg.ds = FP_SEG(dtapnt);
	intdosx(&reg, &nreg, &sreg);
# else
	reg.x.dx = (int) dtapnt;
	intdos(&reg, &nreg);
# endif
}
#endif	/* MSDOS */

#ifdef	GEMDOS
static	char	*
getdirent(dir)
	char	*dir;
{
	if (dir ? Fsfirst(dir, ATTRIBUTES) : Fsnext())
		return (char *) NULL;

	return dtabuf.dta_name;
}

static	void
setdta()
{
	Fsetdta((char *) &dtabuf);
}
#endif	/* GEMDOS */
