/*******************************************************************************
 *	Incomm.h	Internal commands info
 *******************************************************************************
 */

# define	INBIN	"/INBIN/"

struct Comm {
	char *c_name;			/* Command name */
	short	mode;			/* Mode of command (Setuid setgid) */
	int (*c_routine)();		/* Address of command */
};

