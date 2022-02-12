/*
 * (c) copyright 1988 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the file "../Copyright".
 */
#include <out.h>
#include <arch.h>
#include <ranlib.h>
#include "object.h"

extern long		lseek();

/*
 * Parts of the output file.
 */
#define	PARTEMIT	0
#define	PARTRELO	1
#define	PARTNAME	2
#define	PARTCHAR	3
#ifdef SYMDBUG
#define PARTDBUG	4
#else
#define PARTDBUG	3
#endif
#define	NPARTS		(PARTDBUG + 1)

static int		outfile;
static long		outseek[NPARTS];
static long		currpos;
static long		rd_base;
#define OUTSECT(i) \
	(outseek[PARTEMIT] = offset[i])
#define BEGINSEEK(p, o) \
	(outseek[(p)] = (o))

static int sectionnr;

static
OUTREAD(p, b, n)
	char *b;
	long n;
{
	register long l = outseek[p];

	if (currpos != l) {
		lseek(outfile, l, 0);
	}
	rd_bytes(outfile, b, n);
	l += n;
	currpos = l;
	outseek[p] = l;
}

static int offcnt;

rd_fdopen(fd)
{
	register int i;

	for (i = 0; i < NPARTS; i++) outseek[i] = 0;
	offcnt = 0;
	rd_base = lseek(fd, 0L, 1);
	if (rd_base < 0) {
		return 0;
	}
	currpos = rd_base;
	outseek[PARTEMIT] = currpos;
	outfile = fd;
	sectionnr = 0;
	return 1;
}

rd_ohead(head)
	register struct outhead	*head;
{
	register long off;

	OUTREAD(PARTEMIT, (char *) head, (long) SZ_HEAD);
#if ! (BYTES_REVERSED || WORDS_REVERSED)
	if (sizeof(struct outhead) != SZ_HEAD)
#endif
	{
		register char *c = (char *) head + (SZ_HEAD-4);
		
		head->oh_nchar = get4(c);
		c -= 4; head->oh_nemit = get4(c);
		c -= 2; head->oh_nname = uget2(c);
		c -= 2; head->oh_nrelo = uget2(c);
		c -= 2; head->oh_nsect = uget2(c);
		c -= 2; head->oh_flags = uget2(c);
		c -= 2; head->oh_stamp = uget2(c);
		c -= 2; head->oh_magic = uget2(c);
	}
	off = OFF_RELO(*head) + rd_base;
	BEGINSEEK(PARTRELO, off);
	off += (long) head->oh_nrelo * SZ_RELO;
	BEGINSEEK(PARTNAME, off);
	off += (long) head->oh_nname * SZ_NAME;
	BEGINSEEK(PARTCHAR, off);
#ifdef SYMDBUG
	off += head->oh_nchar;
	BEGINSEEK(PARTDBUG, off);
#endif
}

rd_name(name, cnt)
	register struct outname	*name;
	register unsigned int cnt;
{

	OUTREAD(PARTNAME, (char *) name, (long) cnt * SZ_NAME);
#if ! (BYTES_REVERSED || WORDS_REVERSED)
	if (sizeof(struct outname) != SZ_NAME)
#endif
	{
		register char *c = (char *) name + (long) cnt * SZ_NAME;

		name += cnt;
		while (cnt--) {
			name--;
			c -= 4; name->on_valu = get4(c);
			c -= 2; name->on_desc = uget2(c);
			c -= 2; name->on_type = uget2(c);
			c -= 4; name->on_foff = get4(c);
		}
	}
}

rd_string(addr, len)
	char *addr;
	long len;
{
	
	OUTREAD(PARTCHAR, addr, len);
}

#ifdef SYMDBUG
rd_dbug(buf, size)
	char		*buf;
	long		size;
{
	OUTREAD(PARTDBUG, buf, size);
}
#endif

int
rd_arhdr(fd, arhdr)
	register struct ar_hdr	*arhdr;
{
#if WORDS_REVERSED && ! BYTES_REVERSED
	if (sizeof (struct ar_hdr) != AR_TOTAL)
#endif
	{	
		char buf[AR_TOTAL];
		register char *c = buf;
		register char *p = arhdr->ar_name;
		register int i;

		i = read(fd, c, AR_TOTAL);
		if (i == 0) return 0;
		if (i < 0 || i != AR_TOTAL) {
			rd_fatal();
		}
		i = 14;
		while (i--) {
			*p++ = *c++;
		}
		arhdr->ar_date = ((long)get2(c)) << 16; c += 2;
		arhdr->ar_date |= get2(c) & 0xffff; c += 2;
		arhdr->ar_uid = *c++;
		arhdr->ar_gid = *c++;
		arhdr->ar_mode = get2(c); c += 2;
		arhdr->ar_size = ((long)get2(c)) << 16; c += 2;
		arhdr->ar_size |= get2(c) & 0xffff;
	}
#if WORDS_REVERSED && !BYTES_REVERSED
	else	{
		register int i;
		i = read(fd, (char *) arhdr, AR_TOTAL);
		if (i == 0) return 0;
		if (i < 0 || i != AR_TOTAL) rd_fatal();
	}
#endif
	return 1;
}
#define MININT		(1 << (sizeof(int) * 8 - 1))
#define MAXCHUNK	(~MININT)	/* Highest count we read(2).	*/
/* Unfortunately, MAXCHUNK is too large with some  compilers. Put it in
   an int!
*/

static int maxchunk = MAXCHUNK;

/*
 * We don't have to worry about byte order here.
 * Just read "cnt" bytes from file-descriptor "fd".
 */
int 
rd_bytes(fd, string, cnt)
	register char	*string;
	register long	cnt;
{

	while (cnt) {
		register int n = cnt >= maxchunk ? maxchunk : cnt;

		if (read(fd, string, n) != n)
			rd_fatal();
		string += n;
		cnt -= n;
	}
}

unsigned int
rd_unsigned2(fd)
{
	char buf[2];

	rd_bytes(fd, buf, 2L);
	return uget2(buf);
}
