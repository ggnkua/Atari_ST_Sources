/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* Macintosh related things. K. Mitchum 2/88 */

#ifdef MAC	/* the body is the rest of this file */

#include <Menus.h>

#define NMENUS 6
#define NMENUITEMS 40	/* This has GOT to be enough! */

typedef data_obj *menumap[NMENUITEMS];

struct menu {
	char *Name;
	int menu_id;
	MenuHandle Mn;
	menumap m;
};

struct stat {
	int st_dev;		/* volume number */
	long st_ino;		/* file number on volume */
	dev_t st_rdev;
	off_t st_size;		/* logical end of file */
	int st_mode;
	time_t st_mtime;	/* last modified */
};

/* mask and values for simulating file modes */
#define S_IFMT	03
#define S_IFREG	01
#define S_IFDIR 02

int stat proto((const char *, struct stat *));

#define SIGHUP	1	/* fake */

extern void	MarkVar proto((const struct variable *vp, int mnu, int itm));

extern jmp_buf auxjmp;

extern char
	*gethome proto((void)),
	*pfile proto((char *)),
	*gfile proto((char *));

extern int	getArgs proto((char ***));

extern bool	rawchkc proto((void));

extern void
	MacInit proto((void)),
	writetext proto((const unsigned char *, size_t)),
	NPlacur proto((int, int)),
	docontrols proto((void)),
	SetScrollBar proto((Window *)),
	RemoveScrollBar proto((Window *)),
	InitEvents proto((void)),
	menus_on proto((void));

extern bool
	Keyonly,
	Bufchange,
	Modechange,
	EventCmd,
	Windchange;

/* Variables: */

extern bool
	Macmode;	/* VAR: use Mac file selector */

#endif /* MAC */
