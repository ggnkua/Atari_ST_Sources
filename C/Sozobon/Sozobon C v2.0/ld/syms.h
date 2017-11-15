
/*
 * Copyright (c) 1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

struct sym {
	char name[8];
	unsigned char flags;
	unsigned char mark;
	long value;
};

#ifdef UNIXHOST
struct fsym {
	char name[8];
	unsigned char flags, mark;
	short value[2];
};
#endif

#define F_TEXT		2
#define F_DATA		4
#define F_BSS		1
#define F_COMM		8
#define F_GLBL		0x20
#define F_DEF		0x80

#define EXTREF		(F_DEF|F_COMM)
#define COMMDEF		(F_DEF|F_GLBL|F_COMM)

#define SYMSIZE		14

#define CHUNKMAX	(1000/SYMSIZE)

struct symchunk {
	struct symchunk *next;
	int nsyms;
	struct sym s[1];
};

#define XNAME	"SozobonX"
#define XFLAGS	0x42
#define XVALUE	0x87654321

struct sinfo {
	struct sinfo *next;
	unsigned char flags, mark;
	long value;
	struct oinfo *obj;
	char name[1];
};
