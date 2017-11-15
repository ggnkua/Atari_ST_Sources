
/*
 * Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Joseph M Treat
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

struct reserved {
	char *name;
	int token;
	int value;
};

struct lexacts {
	unsigned acts;
	int retval;
};

struct lextab {
	int select;
	struct lexacts action;
};

/*
 * Types of actions
 */
#define L_SKIP  0x0
#define L_TOKEN 0x01
#define L_EXTRA 0x02
#define L_BEGID 0x04
#define L_MIDID 0x08
#define L_DIGIT 0x10
