/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

/*
 * Sound Tools miscellaneous stuff.
 */

#include "st.h"

EXPORT char *sizes[] = {
	"NONSENSE!",
	"bytes",
	"shorts",
	"longs",
	"32-bit floats",
	"64-bit floats",
	"IEEE floats"
};

EXPORT char *styles[] = {
	"NONSENSE!",
	"unsigned",
	"signed (2's complement)",
	"u-law",
	"a-law"
};

char readerr[] = "Premature EOF while reading sample file.";
char writerr[] = "Error writing sample file.  You are probably out of disk space.";

/* Utilities */

/* Read short, little-endian: little end first. VAX/386 style. */
unsigned short
rlshort(ft)
ft_t ft;
{
	unsigned char uc, uc2;
	uc  = getc(ft->fp);
	uc2 = getc(ft->fp);
	return (uc2 << 8) | uc;
}

/* Read short, bigendian: big first. 68000/SPARC style. */
unsigned short
rbshort(ft)
ft_t ft;
{
	unsigned char uc, uc2;
	uc2 = getc(ft->fp);
	uc  = getc(ft->fp);
	return (uc2 << 8) | uc;
}

/* Write short, little-endian: little end first. VAX/386 style. */
unsigned short
#ifdef	__STDC__
wlshort(ft_t ft, unsigned short us)
#else
wlshort(ft, us)
ft_t ft;
unsigned short us;
#endif
{
	putc(us, ft->fp);
	putc(us >> 8, ft->fp);
	if (ferror(ft->fp))
		fail(writerr);
}

/* Write short, big-endian: big end first. 68000/SPARC style. */
unsigned short
#ifdef	__STDC__
wbshort(ft_t ft, unsigned short us)
#else
wbshort(ft, us)
ft_t ft;
unsigned short us;
#endif
{
	putc(us >> 8, ft->fp);
	putc(us, ft->fp);
	if (ferror(ft->fp))
		fail(writerr);
}

/* Read long, little-endian: little end first. VAX/386 style. */
unsigned long
rllong(ft)
ft_t ft;
{
	unsigned char uc, uc2, uc3, uc4;
/*	if (feof(ft->fp))
		fail(readerr);		/* No worky! */
	uc  = getc(ft->fp);
	uc2 = getc(ft->fp);
	uc3 = getc(ft->fp);
	uc4 = getc(ft->fp);
	return ((long)uc4 << 24) | ((long)uc3 << 16) | ((long)uc2 << 8) | (long)uc;
}

/* Read long, bigendian: big first. 68000/SPARC style. */
unsigned long
rblong(ft)
ft_t ft;
{
	unsigned char uc, uc2, uc3, uc4;
/*	if (feof(ft->fp))
		fail(readerr);		/* No worky! */
	uc  = getc(ft->fp);
	uc2 = getc(ft->fp);
	uc3 = getc(ft->fp);
	uc4 = getc(ft->fp);
	return ((long)uc << 24) | ((long)uc2 << 16) | ((long)uc3 << 8) | (long)uc4;
}

/* Write long, little-endian: little end first. VAX/386 style. */
unsigned long
wllong(ft, ul)
ft_t ft;
unsigned long ul;
{
int datum;

	datum = (ul) & 0xff;
	putc(datum, ft->fp);
	datum = (ul >> 8) & 0xff;
	putc(datum, ft->fp);
	datum = (ul >> 16) & 0xff;
	putc(datum, ft->fp);
	datum = (ul >> 24) & 0xff;
	putc(datum, ft->fp);
	if (ferror(ft->fp))
		fail(writerr);
}

/* Write long, big-endian: big end first. 68000/SPARC style. */
unsigned long
wblong(ft, ul)
ft_t ft;
unsigned long ul;
{
int datum;

	datum = (ul >> 24) & 0xff;
	putc(datum, ft->fp);
	datum = (ul >> 16) & 0xff;
	putc(datum, ft->fp);
	datum = (ul >> 8) & 0xff;
	putc(datum, ft->fp);
	datum = (ul) & 0xff;
	putc(datum, ft->fp);
	if (ferror(ft->fp))
		fail(writerr);
}

/* Read and write words and longs in "machine format".  Swap if indicated. */

/* Read short. */
unsigned short
rshort(ft)
ft_t ft;
{
	unsigned short us;

/*	if (feof(ft->fp))
		fail(readerr);		/* No worky! */
	fread(&us, 2, 1, ft->fp);
	if (ft->swap)
		us = swapw(us);
	return us;
}

/* Write short. */
unsigned short
#ifdef	__STDC__
wshort(ft_t ft, unsigned short us)
#else
wshort(ft, us)
ft_t ft;
unsigned short us;
#endif
{
	if (ft->swap)
		us = swapw(us);
	if (fwrite(&us, 2, 1, ft->fp) != 1)
		fail(writerr);
}

/* Read long. */
unsigned long
rlong(ft)
ft_t ft;
{
	unsigned long ul;

/*	if (feof(ft->fp))
		fail(readerr);		/* No worky! */
	fread(&ul, 4, 1, ft->fp);
	if (ft->swap)
		ul = swapl(ul);
	return ul;
}

/* Write long. */
unsigned long
wlong(ft, ul)
ft_t ft;
unsigned long ul;
{
	if (ft->swap)
		ul = swapl(ul);
	if (fwrite(&ul, 4, 1, ft->fp) != 1)
		fail(writerr);
}

/* Byte swappers */

unsigned short
#ifdef	__STDC__
swapw(unsigned short us)
#else
swapw(us)
unsigned short us;
#endif
{
	return ((us >> 8) | (us << 8)) & 0xffff;
}

unsigned long
swapl(ul)
unsigned long ul;
{
	return (ul >> 24) | ((ul >> 8) & 0xff00) | ((ul << 8) & 0xff0000) | (ul << 24);
}

/* dummy routine for do-nothing functions */
int nothing() {;}

/* dummy drain routine for effects */
null_drain(effp, obuf, osamp)
eff_t effp;
long *obuf;
long *osamp;
{
	*osamp = 0;
}

/* here for linear interp.  might be useful for other things */
gcd(a, b) 
long a, b;
{
	if (b == 0)
		return a;
	else
		return gcd(b, a % b);
}

lcm(a, b) 
long a, b;
{
	return (a * b) / gcd(a, b);
}

/* sine wave gen should be here, also */
