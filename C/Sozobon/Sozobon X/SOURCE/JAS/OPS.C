
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

#include "jas.h"

INST itable[] = {
{"b$c$s",	O_LAB,	O_NONE,	S_BW,	"x6$c%0d",	F_PC|F_TXT },
{"",		0,	0,	0,	"",		0 },
{"s$C$s",	O_DST,	O_NONE,	S_B,	"x5$c11%0e",	F_B },
#	include "opcodes.h"
};

int ninsts = (sizeof itable) / (sizeof itable[0]);

INST *
ifind( token, misc )
	register char *token;
	short *misc;
{
	register int lo = 4;
	register int hi = ninsts-2;
	register int i, d;
	register INST *ip;

	while ( lo <= hi ) {
		i = (lo + hi) / 2;
		ip = &itable[i];
		d = icmpare( token, ip->mnemon, misc );
		if ( d == 0 ) {
			INST *jp;

			/*
			 * find the first item with this mnemonic
			 */
			for ( jp = ip-1; ; ip = jp-- ) {
				if ( *(ip->mnemon) != *(jp->mnemon) ) {
					break;
				}
				if ( strcmp( ip->mnemon, jp->mnemon) ) {
					break;
				}
			}
			return ip;
		} else if ( d < 0 ) {
			hi = i-1;
		} else {	/* d > 0 */
			lo = i+1;
		}
	}

	/*
	 * here is some special stuff for conditional branches and sets
	 * which were impractical to put in the standard table
	 */
	if ( *token == 'b' ) {
		ip = &itable[0];
		if (! icmpare( token, ip->mnemon, misc ) )
			return ip;
	} else if ( *token == 's' ) {
		ip = &itable[2];
		if (! icmpare( token, ip->mnemon, misc ) )
			return ip;
	}
	return (INST *) NULL;
}

int
icmpare( token, mnemon, misc )
	char *token;
	char *mnemon;
	short *misc;
{
	register int i;
	register char *tp, *mp;

	*misc = 0;
	for ( tp = token, mp = mnemon; *mp; mp++ ) {
		if ( *mp == '$' ) {
			switch ( *++mp ) {
			case 'c':
				i = chk_cond( tp, 0, misc );
				if ( i == 0 )
					return *tp ? *tp : -1;
				tp += i-1;
				break;
			case 'C':
				i = chk_cond( tp, 1, misc );
				if ( i == 0 )
					return *tp ? *tp : -1;
				tp += i-1;
				break;
			case 'd':
				if ( *tp == 'r' )
					*misc |= 0x00;
				else if ( *tp == 'l' )
					*misc |= 0x08;
				else
					return *tp ? *tp : -1;
				break;
			case 's':
				if ( *tp ) {
					if ( *tp != '.' )
						return *tp;
					switch ( *++tp ) {
					case 'b':
						*misc |= 0x01;
						break;
					case 'w':
						*misc |= 0x02;
						break;
					case 'l':
						*misc |= 0x04;
						break;
					default:
						return '.';
					}
				}
				break;
			}
		} else if ( *mp != *tp ) {
			return *tp - *mp;
		}
		if ( *tp )
			tp++;
	}

	return *tp;
}

struct hcc_bug {
	char cc[4];
	short en;
} cctab[] = {
	{ "ra", 0x1 },	/* dbcc start here */
	{ "f",  0x1 },
	{ "t",  0x0 },
	{ "eq", 0x7 },	/* bcc start here */
	{ "ne", 0x6 },
	{ "ge", 0xC },
	{ "gt", 0xE },
	{ "le", 0xF },
	{ "lt", 0xD },
	{ "cc", 0x4 },
	{ "hi", 0x2 },
	{ "ls", 0x3 },
	{ "cs", 0x5 },
	{ "hs", 0x4 },
	{ "lo", 0x5 },
	{ "mi", 0xB },
	{ "pl", 0xA },
	{ "vc", 0x8 },
	{ "vs", 0x9 },
	{ "", 0 }
};

chk_cond( tp, all, misc )
	register char *tp;
	int all;
	short *misc;
{
	register int i;

	i = all ? 0 : 3;
	for ( ; cctab[i].cc[0]; i++ ) {
		if (! strncmp( tp, cctab[i].cc, strlen(cctab[i].cc) ) ) {
			*misc |= ( cctab[i].en << 4 ); 
			return strlen( cctab[i].cc );
		}
	}
	return 0;
}
