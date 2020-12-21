/*
 * stripex.c 
 * strip symbol table and GNU binutils aexec header from TOS executables.
 * Needed e.g. for SLB shared library files or CPX modules to get the header back
 * to the start of the text segment.
 *
 * BUGS:
 * - relocation table is not checked for validity. If it is corrupted,
 *   this program might crash and/or create corrupted output files.
 *   Should rarely be a problem, since the kernel does not check the table either.
 */

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#ifndef O_BINARY
#  ifdef _O_BINARY
#    define O_BINARY _O_BINARY
#  else
#    define O_BINARY 0
#  endif
#endif 

#define NEWBUFSIZ	16384L

static unsigned char mybuf[NEWBUFSIZ];
static int verbose;

static char tmpname[1024];

#if defined(__atarist__) && defined(__GNUC__)
long _stksize = 30000;
#endif

struct aexec
{
	short a_magic;						/* magic number */
	unsigned long a_text;				/* size of text segment */
	unsigned long a_data;				/* size of initialized data */
	unsigned long a_bss;				/* size of uninitialized data */
	unsigned long a_syms;				/* size of symbol table */
	unsigned long a_AZero1;				/* always zero */
	unsigned long a_AZero2;				/* always zero */
	unsigned short a_isreloc;			/* is reloc info present */
};

#define	CMAGIC	0x601A					/* contiguous text */

#define SIZEOF_SHORT 2
#define SIZEOF_LONG  4

#define SIZEOF_AEXEC (SIZEOF_SHORT + (6 * SIZEOF_LONG) + SIZEOF_SHORT)
#define SIZEOF_BINUTILS_AEXEC 228


static char *f_basename(char *name)
{
	char *p1, *p2;

	p1 = strrchr(name, '/');
	p2 = strrchr(name, '\\');
	if (p1 == NULL || p2 > p1)
		p1 = p2;
	if (p1 == NULL)
		p1 = name;
	else
		p1++;
	return p1;
}


static unsigned short read_beword(const unsigned char *p)
{
	return (p[0] << 8) | p[1];
}


static unsigned long read_belong(const unsigned char *p)
{
	return ((unsigned long)read_beword(p) << 16) | read_beword(p + 2);
}


static void write_beword(unsigned char *p, unsigned short v)
{
	p[0] = (v >> 8) & 0xff;
	p[1] = (v     ) & 0xff;
}


static void write_belong(unsigned char *p, unsigned long v)
{
	p[0] = (unsigned char)((v >> 24) & 0xff);
	p[1] = (unsigned char)((v >> 16) & 0xff);
	p[2] = (unsigned char)((v >>  8) & 0xff);
	p[3] = (unsigned char)((v      ) & 0xff);
}


/*
 * read header -- return -1 on error
 */
static int read_head(int fd, struct aexec *a)
{
	unsigned char buf[SIZEOF_AEXEC];
	
	if (read(fd, buf, SIZEOF_AEXEC) != SIZEOF_AEXEC)
		return -1;
	a->a_magic = read_beword(buf);
	a->a_text = read_belong(buf + 2);
	a->a_data = read_belong(buf + 6);
	a->a_bss = read_belong(buf + 10);
	a->a_syms = read_belong(buf + 14);
	a->a_AZero1 = read_belong(buf + 18);
	a->a_AZero2 = read_belong(buf + 22);
	a->a_isreloc = read_beword(buf + 26);

	return SIZEOF_AEXEC;
}


static int write_head(int fd, const struct aexec *a)
{
	unsigned char buf[SIZEOF_AEXEC];
	
	write_beword(buf, a->a_magic);
	write_belong(buf + 2, a->a_text);
	write_belong(buf + 6, a->a_data);
	write_belong(buf + 10, a->a_bss);
	write_belong(buf + 14, a->a_syms);
	write_belong(buf + 18, a->a_AZero1);
	write_belong(buf + 22, a->a_AZero2);
	write_beword(buf + 26, a->a_isreloc);

	if (write(fd, buf, SIZEOF_AEXEC) != SIZEOF_AEXEC)
		return -1;
	return SIZEOF_AEXEC;
}


/*
 * copy from, to in NEWBUFSIZ chunks upto bytes or EOF whichever occurs first
 * returns # of bytes copied
 */
static long copy(int from, int to, long bytes)
{
	register long todo;
	long done = 0L;
	long remaining = bytes;
	long actual;

	while (done != bytes)
	{
		todo = (remaining > NEWBUFSIZ) ? NEWBUFSIZ : remaining;
		if ((actual = read(from, mybuf, todo)) != todo)
		{
			if (actual < 0)
			{
				fprintf(stderr, "Error Reading\n");
				return -done;
			}
		}
		if (write(to, mybuf, actual) != actual)
		{
			fprintf(stderr, "Error Writing\n");
			return -done;
		}
		done += actual;
		if (actual != todo)				/* eof reached */
			return done;
		remaining -= actual;
	}
	return done;
}


static int relocate(const char *name, int fd, long reloc_pos)
{
	if (lseek(fd, reloc_pos, SEEK_SET) != reloc_pos)
	{
		perror(name);
		return 0;
	}
	if (read(fd, mybuf, SIZEOF_LONG) != SIZEOF_LONG)
	{
		perror(name);
		return 0;
	}
	write_belong(mybuf, read_belong(mybuf) - SIZEOF_BINUTILS_AEXEC);
	if (lseek(fd, reloc_pos, SEEK_SET) != reloc_pos)
	{
		perror(name);
		return 0;
	}
	if (write(fd, mybuf, SIZEOF_LONG) != SIZEOF_LONG)
	{
		perror(name);
		return 0;
	}
	return 1;
}


/* copy TOS relocation table from `from` to `to`. Copy bytes until NUL byte or
   first 4 bytes if == 0l.
   returns length of relocation table or -1 in case of an error */

static long copy_relocs(const char *name, int from, int to)
{
	long res = 0;
	long bytes;
	long rbytes = 0;
	long first_relo;
	long reloc_pos;
	
	res = read(from, mybuf, SIZEOF_LONG);
	if (res != 0 && res != SIZEOF_LONG)
	{
		fprintf(stderr, "Error reading\n");
		return -1;
	}

	if (res == 0)
	{
		/* I think empty relocation tables are allowed,
		   but could cause trouble with certain programs */
		fprintf(stderr, "Warning: %s: No relocation table\n", name);
		return 0;
	}
	first_relo = read_belong(mybuf);
	if (first_relo != 0)
	{
		first_relo -= SIZEOF_BINUTILS_AEXEC;
		write_belong(mybuf, first_relo);
	}
	
	if (write(to, mybuf, res) != res)
	{
		fprintf(stderr, "%s: Error writing\n", name);
		return -1;
	}

	rbytes = SIZEOF_LONG;
	if (first_relo == 0)
		return rbytes;						/* This is a clean version of an empty
										   relocation table                   */

	reloc_pos = SIZEOF_AEXEC + first_relo;
	if (relocate(name, to, reloc_pos) == 0)
		return -1;

	for (;;)
	{
		lseek(to, 0l, SEEK_END);
		if ((bytes = read(from, mybuf, 1)) < 0)
		{
			fprintf(stderr, "%s: Error reading\n", name);
			return -1;
		}
		if (bytes == 0)
		{
			fprintf(stderr, "Warning: %s: Unterminated relocation table\n", name);
			return rbytes;
		}
		if (write(to, mybuf, bytes) != bytes)
		{
			fprintf(stderr, "%s: Error writing\n", name);
			return -1;
		}
		rbytes += bytes;
		if (mybuf[0] == 0)
			break;
		if (mybuf[0] == 1)
		{
			reloc_pos += 254;
		} else
		{
			reloc_pos += mybuf[0];
			if (relocate(name, to, reloc_pos) == 0)
				return -1;
		}
	}
	return rbytes;
}


static int strip(const char *name)
{
	register int fd;
	register int tfd;
	register long count, rbytes, sbytes;
	struct aexec ahead;
	unsigned char buf[2 * SIZEOF_LONG];
	long magic1, magic2;
	
	if ((fd = open(name, O_RDONLY | O_BINARY, 0755)) < 0)
	{
		perror(name);
		return 1;
	}
	if ((tfd = open(tmpname, O_RDWR | O_BINARY | O_TRUNC | O_CREAT, 0755)) < 0)
	{
		perror(tmpname);
		close(fd);
		return 1;
	}
	if (read_head(fd, &ahead) < 0 ||
		read(fd, buf, (2 * SIZEOF_LONG)) != (2 * SIZEOF_LONG))
	{
		perror(name);
		close(tfd);
		close(fd);
		return 1;
	}
	if (ahead.a_magic != CMAGIC)
	{
		fprintf(stderr, "%s: Bad Magic number\n", name);
		close(tfd);
		close(fd);
		return 1;
	}
	magic1 = read_belong(buf);
	magic2 = read_belong(buf + SIZEOF_LONG);
	if (!((magic1 == 0x283a001aL && magic2 == 0x4efb48faL) ||	/* Original binutils */
		  (magic1 == 0x203a001aL && magic2 == 0x4efb08faL)))		/* binutils >= 2.18-mint-20080209 */
	{
		fprintf(stderr, "%s: no aexec header\n", name);
		close(tfd);
		close(fd);
		return 1;
	}
	sbytes = ahead.a_syms;
	if (verbose)
	{
		printf("%s: text=0x%lx, data=0x%lx, syms=0x%lx\n", name, ahead.a_text, ahead.a_data, ahead.a_syms);
	}

	ahead.a_syms = 0;
	ahead.a_text -= SIZEOF_BINUTILS_AEXEC;
	if (ahead.a_AZero1 == 0x4d694e54l)		/* 'MiNT' extended exec header magic */
		ahead.a_AZero1 = 0;
	if (write_head(tfd, &ahead) < 0)
	{
		close(tfd);
		close(fd);
		return 1;
	}
	if (lseek(fd, SIZEOF_BINUTILS_AEXEC - (2 * SIZEOF_LONG), SEEK_CUR) < 0)
	{
		fprintf(stderr, "%s: seek error\n", name);
		close(tfd);
		close(fd);
		return 1;
	}
	if (verbose)
	{
		printf("%s: skipped 0x%x bytes aexec header\n", name, SIZEOF_BINUTILS_AEXEC);
	}

	count = ahead.a_text + ahead.a_data;
	if (copy(fd, tfd, count) != count)
	{
		close(tfd);
		close(fd);
		return 1;
	}
	if (verbose)
	{
		printf("%s: copied 0x%lx bytes text+data\n", name, count);
	}
	if (lseek(fd, sbytes, SEEK_CUR) < 0)
	{
		fprintf(stderr, "%s: seek error\n", name);
		close(tfd);
		close(fd);
		return 1;
	}
	if (sbytes != 0 && verbose)
	{
		printf("%s: skipped 0x%lx bytes symbols\n", name, sbytes);
	}
	rbytes = 0;
	if (ahead.a_isreloc == 0)
	{
		if ((rbytes = copy_relocs(name, fd, tfd)) < 0)
		{
			close(tfd);
			close(fd);
			return 1;
		}
		if (verbose)
		{
			printf("%s: copied 0x%lx bytes relocation table\n", name, rbytes);
		}
	}
	if (verbose)
	{
		unsigned long pos, size;
		
		pos = lseek(fd, 0L, SEEK_CUR);
		lseek(fd, 0L, SEEK_END);
		size = lseek(fd, 0L, SEEK_CUR);
		lseek(fd, pos, SEEK_SET);
		if (size > pos)
		{
			printf("%s: skipped 0x%lx bytes trailer\n", name, size - pos);
		}
	}

	close(tfd);
	close(fd);
	if (rename(tmpname, name) == 0)
		return 0;						/* try to rename it */
	if ((fd = open(name, O_WRONLY | O_BINARY | O_TRUNC | O_CREAT, 0755)) < 0)
	{
		perror(name);
		return 1;
	}
	if ((tfd = open(tmpname, O_RDONLY | O_BINARY, 0755)) < 0)
	{
		perror(tmpname);
		close(fd);
		return 1;
	}

	count = SIZEOF_AEXEC + ahead.a_text + ahead.a_data + rbytes;
	if (copy(tfd, fd, count) != count)
	{
		close(tfd);
		close(fd);
		return 1;
	}
	close(tfd);
	close(fd);
	return 0;
}


static void usage(const char *s)
{
	fprintf(stderr, "%s", s);
	fprintf(stderr, "Usage: stripex files ...\n");
	fprintf(stderr, "strip GNU-binutils aexec header from executables\n");
	exit(1);
}


int main(int argc, char **argv)
{
	int status = 0;

	verbose = 0;
	
	/* process arguments */
	while (argv++, --argc)
	{
		if ('-' != **argv)
			break;
		(*argv)++;
		switch (**argv)
		{
		case 'v':
			verbose = 1;
			break;
		default:
			usage("");
			break;
		}
	}

	if (argc < 1)
	{
		usage("");
	}
	
	do
	{
		const char *filename = *argv++;
		char *base;
		
		strcpy(tmpname, filename);
		base = f_basename(tmpname);
		strcpy(base, "STXXXXXX");
		mktemp(tmpname);
		status |= strip(filename);
		unlink(tmpname);
	} while (--argc > 0);

	return status;
}
