/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#define COMMAND	1
#define VARIABLE	2
#define MACRO		3
#define FULL_KEYMAP	4
#define SPARSE_KEYMAP	5
#ifdef MAC
# define BUFFER		6	/* menus can point to buffers, too */
# define STRING		7	/* a menu string or divider */
#endif

#define TYPEMASK	07
#define obj_type(o)	((o)->Type & TYPEMASK)
#define MAJOR_MODE	010
#define MINOR_MODE	020
#define MODIFIER	040
#define MODCMD		(COMMAND|MODIFIER)
#define MAJOR_SHIFT	8
#define DefMajor(x)	(COMMAND|MAJOR_MODE|((x) << MAJOR_SHIFT))
#define DefMinor(x)	(COMMAND|MINOR_MODE|((x) << MAJOR_SHIFT))

/* prefix of cmd, macro, keymap, variable, and sometimes buffer structs */
typedef struct {
	int	Type;
	char	*Name;
} data_obj;

extern data_obj	*LastCmd;	/* last command invoked */

extern char	*ProcFmt;	/* ": %f " -- name of LastCmd */

extern data_obj
	*findcom proto((const char *prompt)),
	*findmac proto((const char *prompt)),
	*findvar proto((const char *prompt));
