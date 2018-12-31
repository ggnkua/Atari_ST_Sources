/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

struct cmd {
	/* Type and Name must match data_obj */
	int	Type;
	char	*Name;
	void	(*c_proc) ptrproto((void));
#ifdef MAC
	char c_map;			/* prefix map for About Jove... */
	char c_key;			/* key binding for About Jove... */
#endif
};

extern const struct cmd	commands[];

extern const struct cmd
	*FindCmd proto((void (*proc) ptrproto((void))));

extern void
	ExecCmd proto((data_obj *cp));
