/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

struct variable {
	/* Type and Name must match data_obj */
	int	Type;		/* in this case a variable */
	char	*Name;		/* name is always second */
	UnivPtr	v_value;
	size_t	v_size;
	int	v_flags;	/* type and attributes */
};

#define V_TYPEMASK	017	/* mask for type part */

/* variable types (choose one)
 * Note: V_INT through V_NAT are used as subscripts in vset_aux.
 */

#define V_INT		001	/* integer */
#define V_WHOLEX	002	/* whole numbers, extended with -1 */
#define V_WHOLE		003	/* whole number */
#define V_NAT		004	/* natural number */
#define V_BOOL		005	/* is a boolean */
#define V_STRING	006	/* is a string */
#define V_CHAR		007	/* is a character */
#define V_FILENAME	010	/* a file name */

/* variable attributes (choose any set) */

#define V_FMODE		00020	/* number is a file mode: base 8 */
#define V_MODELINE	00040	/* update modeline */
#define V_CLRSCREEN	00100	/* clear and redraw screen */
#define V_TTY_RESET	00200	/* redo the tty modes */
#define V_LOCALE	00400	/* locale has changed -- do a setlocale */
#define V_UPDFREQ	01000	/* update-time-frequency -- reset alarm */

extern const struct variable	variables[];
