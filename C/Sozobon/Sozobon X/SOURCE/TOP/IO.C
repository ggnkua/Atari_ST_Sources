/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */
#include "top.h"

/*
 * Low-level i/o routines.
 */

/*
 * mode tells what kind of stuff we're reading at the moment.
 */
static	int	mode;

#define	BSS	0
#define	DATA	1
#define	TEXT	2

static	char	*mnames[] = {
	".bss",
	".data",
	".text"
};

/*
 * Tokens from the current line...
 */
char	*t_line;		/* the entire line */
char	*t_lab;			/* label, if any */
char	*t_op;			/* opcode */
char	*t_arg;			/* arguments */

#define	ISWHITE(c)	((c) == '\t' || (c) == ' ' || (c) == '\n')

#define	LSIZE	2048	/* max. size of an input line */

/*
 * readline() - read the next line from the file
 *
 * readline passes data and bss through to the output, only returning
 * when a line of text has been read. Returns FALSE on end of file.
 */
bool
readline()
{
	char	*fgets();
	static	void	tokenize();
	static	char	buf[LSIZE];

	/*
	 * Keep looping until we get a line of text
	 */
	for (;;) {
		if (fgets(buf, LSIZE, ifp) == NULL)
			return FALSE;
	
		t_line = buf;
	
		/*
		 * Find out if the mode is changing.
		 */
		tokenize(buf);
	
		/*
		 * If we see a "var" hint from the compiler, call addvar()
		 * to remember it for later use.
		 */
		if (t_lab[0] == ';') {
			if (strcmp(t_lab, ";var") == 0)
				addvar(atoi(t_op), atoi(t_arg));
			continue;
		}

		if (t_op[0] == '.') {	/* is it a pseudo-op? */
			if (strcmp(t_op, mnames[BSS]) == 0)
				mode = BSS;
			else if (strcmp(t_op, mnames[DATA]) == 0)
				mode = DATA;
			else if (strcmp(t_op, mnames[TEXT]) == 0) {
				mode = TEXT;
				continue;
			}
		}
		if (mode == TEXT)
			return TRUE;
		else
			fputs(buf, ofp);
	}
}

static void
tokenize(s)
register char	*s;
{
	static	char	label[LSIZE], opcode[LSIZE], args[LSIZE];
	register int	i;

	/*
	 * Grab the label, if any
	 */
	i = 0;
	while (*s && !ISWHITE(*s) && *s != ':')
		label[i++] = *s++;
	label[i] = '\0';

	if (*s == ':')
		s++;

	while (ISWHITE(*s))
		s++;

	/*
	 * Grab the opcode
	 */
	i = 0;
	while (*s && !ISWHITE(*s))
		opcode[i++] = *s++;
	opcode[i] = '\0';

	while (ISWHITE(*s))
		s++;

	/*
	 * Grab the arguments
	 */
	i = 0;
	while (*s && !ISWHITE(*s))
		args[i++] = *s++;
	args[i] = '\0';

	t_lab = label;
	t_op = opcode;
	t_arg = args;
}
