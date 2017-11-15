

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

#define ARMAG1	0xff65

struct ar_hdr {
	char	ar_name[14];
	short	ar_date[2];
	char	ar_uid, ar_gid;
	short	ar_mode;
	short	ar_size[2];
	short	ar_fill;
};

#define ARHSZ	28
