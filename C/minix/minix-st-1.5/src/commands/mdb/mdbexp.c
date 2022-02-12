/*
 * mdbexp.c - MINIX expresion parser
 *
 * Written by Bruce D. Szablak
 *
 * This free software is provided for non-commerical use. No warrantee
 * of fitness for any use is implied. You get what you pay for. Anyone
 * may make modifications and distribute them, but please keep this header
 * in the distribution. NOTE: A PORTION OF THIS FILE IS DERIVED FROM THE
 * SOURCE TO NM.C WHOSE AUTHOR IS UNKNOWN TO ME (AST?). BEWARE THAT
 * OTHER RESTRICTIONS MAY APPLY.
 * 
 * 11/02/90: modified to use a.out.h, F. Meulenbroeks.
 */

#include <sys/types.h>
#include <ctype.h>
#include <setjmp.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <a.out.h>
#include "user.h"

extern jmp_buf mainlp;
extern curpid;

int nsyms;
struct nlist *nbufp = (struct nlist *)NULL;
struct exec header;		/* header of a.out file */
long value(), strtol(), lookup(), ptrace();

#define idchar(c) (isalpha(c) || isdigit(c) || (c) == '_')

char *
addr_to_name(rel_addr, off_p)
	long rel_addr, *off_p;
{
	register int i, l = 0, r = nsyms;

	while (l < r)
	{
		i = (l + r) >> 1;
		if (rel_addr < nbufp[i].n_value) r = i;
		else if (rel_addr > nbufp[i].n_value) l = i + 1;
		else break;
	}
	if (l == nsyms || r == 0)
	{
		*off_p = rel_addr;
		return "_start";
	}
	if (rel_addr < nbufp[i].n_value) i--;
	*off_p = rel_addr - nbufp[i].n_value;
	return nbufp[i].n_name;
}

symbolic(addr, sep)
	long addr;
	char sep;
{
	long off;
	extern long saddr, eaddr;

	if (addr < saddr || addr > eaddr)
	{
		printf("0x%lx%c", addr, sep);
		return;
	}
	fputs(addr_to_name(addr - saddr, &off), stdout);
	if (off) printf("+0x%lx", off);
	fputc(sep, stdout);
}

char *
getexp(buf, exp_p, seg_p)
	char *buf;
	int *seg_p;
	long *exp_p;
{
	extern char *skip();
	long v = 0L;

	buf = skip(buf);
	if ((isalpha(*buf) && (isspace(buf[1]) || buf[1]==';'))
		|| *buf=='\n' || *buf==';' || *buf=='/' || *buf == '!')
	{
		*exp_p = 0L;
		return buf;
	}
	v = value(buf, &buf, seg_p);
	buf = skip(buf);
	if (*buf == '+')
	{
		v += value(skip(buf+1), &buf, seg_p);
	}
	else if (*buf == '-')
	{
		v -= value(skip(buf+1), &buf, seg_p);
	}
	*exp_p = v;
	return skip(buf);
}

long
reg_addr(s)
	char *s;
{
	long val;

	switch (*s++)
	{
	case	'a': case 'A': val = 32; break;
	case	'd': case 'D': val = 0; break;
	default: goto error;
	}
	if (*s >= '0' && *s <= '7')
	{
		return val + 4*(*s - '0');
	}

error:
	printf("Unknown register: %2.2s\n", s);
/*	longjmp(mainlp); --jrb */
	longjmp(mainlp, 1); /* ++jrb */
}

long
value(s, s_p, seg_p)
	char *s, **s_p;
	int *seg_p;
{
	long k;

	if (*s == '\'') /* handle character constants here */
	{
		*s_p = s + 2;
		return s[1];
	}
	if (*s == '-' || isdigit(*s))
	{
		return strtol(s, s_p, 0);
	}
	if (*s == '$')
	{
		k = reg_addr(s+1);
		*s_p = s + 3;
		return ptrace(3, curpid, k, 0L);
	}
	return lookup(s, s_p, seg_p);
}

long
lookup(s, s_p, seg_p)
	char *s, **s_p;
	int *seg_p;
{
	extern long saddr;
	char c;
	int i, l;

	for (l = 1; idchar(s[l]); ++l ) {}
	c = s[l]; s[l] = 0;
	
	if (strcmp("_start", s) == 0)
	{
		*seg_p = T;
		*(*s_p = s + 6) = c;
		return saddr;
	}
	for (i = 0; i < nsyms; i++)
		if (strncmp(nbufp[i].n_name, s, 8) == 0)
		{
			*seg_p = (nbufp[i].n_sclass & N_SECT) == N_TEXT ? T : D;
			*(*s_p = s + l) = c;
			return nbufp[i].n_value + saddr;
		}

	printf("%s: symbol not found\n", s);
/*	longjmp(mainlp); -- jrb */
	longjmp(mainlp, 1); /* ++jrb */
}

compare(p1, p2)
struct nlist	*p1, *p2;
{
	if (p1->n_value < p2->n_value) return -1;
	if (p1->n_value > p2->n_value) return 1;
	return 0;
}

getsyms(file)
char *file;
{
  int fd;

  fd = open(file, O_RDONLY);
  if (fd == -1) {
	fprintf(stderr, "can't open %s\n", file);
	return;
  }
  if (read_header(fd)) {
	fprintf(stderr, "%s: no executable file\n", file);
	close(fd);
	return;
  }
  if (header.a_syms != 0) {
    nbufp = (struct nlist *) malloc((int) (header.a_syms & 0xFFFF));
    if (nbufp == (struct nlist *)NULL) {
	fprintf(stderr, "db: out of memory on %s\n", file);
	exit(2);
	return;
    }
    if (read(fd, (char *) nbufp, (int) (header.a_syms & 0xFFFF))
        != (int) (header.a_syms & 0xFFFF)) {
	  fprintf(stderr, "%s: can't read symbol table\n", file);
	  return;
    }
    nsyms = (int) header.a_syms / sizeof(struct nlist);
    qsort(nbufp, nsyms, sizeof(struct nlist), compare);
    close(fd);
  }
}

read_header(fd)
int fd;
{
  if (read(fd, (char *) &header, sizeof(struct exec)) != sizeof(struct exec))
	return(1);
  if (BADMAG(header)) return(1);
  lseek(fd, A_SYMPOS(header), SEEK_SET);

  return(0);
}
