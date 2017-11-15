
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

#define OMAGIC 0x601a
#define AMAGIC 0xff65

struct generic {
	struct generic *next;
};

struct finfo {
	struct finfo *next;	/* must be first */
	char name[1];
};

struct hdr_l {
	long tsize, dsize, bsize;
	long syms;
};

#define HDRFILL	10
#define HDRSIZE	(2+HDRFILL+sizeof(struct hdr_l))

struct oinfo {
	struct oinfo *next;	/* must be first */
	struct finfo *finfo;
	char aname[14];
	struct hdr_l oh;
	struct symchunk *sp;
	int havex;
	long tbase, dbase, bbase;
};

struct ainfo {
	struct ainfo *next;	/* must be first */
	char aname[14];
	char used;
	long aoffs;
	struct hdr_l ah;
	struct symchunk *sp;
	int havex;
};

