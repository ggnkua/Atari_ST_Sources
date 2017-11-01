
#include <stdio.h>
#include <ctype.h>
#include "pogo.h"

FILE *po_file;

jexists(name)
char *name;
{
FILE *f;

f = fopen(name, "r");
if (f != NULL)
	{
	fclose(f);
	return(1);
	}
return(0);
#ifdef LATER
#endif LATER
}

open_pogo_file(name)
char *name;
{
if ((po_file = fopen(name, "r")) == NULL)
	return(0);
else
	return(1);
#ifdef LATER
#endif LATER
}

close_pogo_file()
{
if (po_file != NULL)
	{
	fclose(po_file);
	po_file = NULL;
	}
#ifdef LATER
#endif LATER
}

/* some tokenizing stuff */
char *
pget_line(buf, max)
char *buf;
int max;
{
if (fgets(buf, max, po_file) == NULL)
	return(NULL);
return(buf);
#ifdef LATER
#endif LATER
}

#define FMAX 21

FILE *pgfiles[FMAX];

good_file(i)
int i;
{
if (i>0 && i < FMAX && pgfiles[i] != NULL)
	return(1);
else
	{
	say_fatal("Bad file parameter");
	return(0);
	}
}

popen(p)
union pt_int *p;
{
char *name, *mode;
FILE *f;
int i;

name = p[-2].p;
mode = p[-1].p;
if (name == NULL || mode == NULL)
	{
	return(0);
	}
for (i=1; i<FMAX+1; i++)
	{
	if (pgfiles[i] == NULL)
		{
		if ((f = fopen(name, mode)) == NULL)
			return(NULL);
		pgfiles[i] = f;
		return(i);
		}
	}
return(0);
}

pclose(p)
union pt_int *p;
{
int f;

f = p[-1].i;
if (good_file(f))
	{
	fclose(pgfiles[f]);
	pgfiles[f] = NULL;
	}
}

pgetchar(p)
union pt_int *p;
{
int f;

f = p[-1].i;
if (good_file(f))
	{
	return(getc(pgfiles[f]));
	}
else
	return(-1);
}

char *
pgetword(p)
union pt_int *p;
{
char buf[256];
int pf;
FILE *f;
int i;
int c;
char *s;

pf = p[-1].i;
if (good_file(pf))
	{
	f = pgfiles[pf];
	for (;;)
		{
		c = getc(f);
		if (!isspace(c))
			break;
		}
	if (c == EOF)
		return(NULL);
	for (i=0; i<255; i++)
		{
		buf[i] = c;
		c = getc(f);
		if (c == EOF || isspace(c))
			break;
		}
	buf[i+1] = 0;
	if ((s = clone_string(buf)) != NULL)
		add_cr_string(s);
	return(s);
	}
else
	return(NULL);
}

char *
pgetline(p)
union pt_int *p;
{
char buf[256];
int pf;
FILE *f;
int i;
int c;
char *s;

pf = p[-1].i;
if (good_file(pf))
	{
	f = pgfiles[pf];
	for (i=0; i<255; i++)
		{
		c = getc(f);
		if (c == EOF)
			{
			if (i == 0)
				return(NULL);
			break;
			}
		buf[i] = c;
		if (c == '\n')
			break;
		}
	buf[i+1] = 0;
	if ((s = clone_string(buf)) != NULL)
		add_cr_string(s);
	return(s);
	}
else
	return(NULL);
}

pputchar(p)
union pt_int *p;
{
int pf;
FILE *f;

pf = p[-2].i;
if (good_file(pf))
	{
	f = pgfiles[pf];
	if (putc(p[-1].i, f) == EOF)
		return(0);
	return(1);
	}
else
	return(0);
}

p_puts(p, nl)
union pt_int *p;
int nl;
{
int pf;
FILE *f;
register char *s;

pf = p[-2].i;
if (good_file(pf))
	{
	f = pgfiles[pf];
	s = p[-1].p;
	while (*s != NULL)
		{
		if (putc(*s++, f) == EOF)
			return(0);
		}
	if (nl)
		putc('\n', f);
	return(1);
	}
else
	return(0);
}

pputs(p)
union pt_int *p;
{
return(p_puts(p, 0));
}

pputline(p)
union pt_int *p;
{
return(p_puts(p, 1));
}
