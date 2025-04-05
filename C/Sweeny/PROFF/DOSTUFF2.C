#include <stdio.h>
#include <ctype.h>
#include "proff.h"
#include "debug.h"

/*
 * dodef - define a command macro (".de xx" is in buf.)
 *
 */
dodef(buf,fd)
char buf[];
FILE *fd;
{
	char name[MAXNAME],defn[MAXDEF];
	int i,junk;

#ifdef DEBUG
	printf("dodef++: Fd %ld\n",fd);
#endif

	dprintf("dodef  ");
	i = 0;
	junk = getwrd(buf, &i, name);
	i = getwrd(buf, &i, name);	/* get the name */
	if (i == 0)
		error("missing name in command def.");
	i = 0;
	while (ngetln(buf,fd) != EOF) {
		if (buf[0] == cchar && buf[1] == 'e' &&
		    buf[2] == 'n' && !isalnum(buf[3]))
			break;
		junk = addstr(buf, defn, &i, MAXDEF);
	}
	if (addset(EOS, defn, &i, MAXDEF) == NO)
		error("definition too long.\n");
	if (install(name, defn, macrotab) == NULL)
		fprintf(stderr,"no room for new definition.\n");
#ifdef DEBUG
	printf("dodef: %s (name) %s (defn)\n",name,defn);
#endif
}

/*
 * doesc - expand escapes in buf
 *
 */
doesc(buf, tbuf, size)
char buf[];
char tbuf[];
int size;
{
	int i,j;

	dprintf("doesc  ");
	j = 0;
	for (i = 0; buf[i] != EOS && j < size-1; i++)
		/*
		 * clean up generic escapes along the way.
		 */
		if (buf[i] == genesc)
			tbuf[j++] = buf[++i];

		else if (buf[i] != ESCAPE) {
			tbuf[j] = buf[i];
			j++;
		}
		else if (buf[i+1] == 'n' &&
		    (buf[i+2] >= 'a' && buf[i+2] <= 'z')) {
			j += itoc(nr[buf[i+2] - 'a'],
			&tbuf[j], size - j - 1);
			i += 2;
		}
		else {
			tbuf[j] = buf[i];
			j++;
		}
	tbuf[j] = EOS;
	strcpy(buf, tbuf);
}

/*
 * dovar - expand variables in buf
 *
 */
dovar(tbuf, buf)
char *buf;
char *tbuf;
{
	register char *c, *p, t;
	struct hashlist *xp;

	while (*buf != '\0') {
		if (*buf == genesc) {
			*tbuf++ = *buf++;
			*tbuf++ = *buf;
		}
		else if (*buf != VESCAPE)
			*tbuf++ = *buf;
		else {
			buf++;	 /* skip the ESCAPE */
			if (*buf == '{')
				buf++;
			p = buf; /* save the beginning address of variable */
			while (isalnum(*buf))
				buf++;
			t = *buf;	/* save the character*/
			*buf = '\0';	/* hack a null there */
			if ((xp = lookup(p,gentab)) != NULL) {
				c = xp->def;	/* point to def */
				while (*c != '\0')
					*tbuf++ = *c++;
			}
			if (*(p-1) != '{')
				*tbuf++ = t;
			else if (t != '}')
				fprintf(stderr, "missing \"}\" in %s\n",p);
		}
		buf++;
	}
	*tbuf = '\0';
}


/*
 * dotabs - expand tabs in buf
 *
 */
dotabs(buf,tbuf,size)
char buf[];
char tbuf[];
int size;
{
	int i,j;
	dprintf("dotabs  ");

	j = 0;
	for (i = 0; buf[i] != EOS && j < size - 1; i++)
		if (buf[i] == '\t')
			while (j < size - 1) {
				tbuf[j] = ' ';
				j++;
				if (tabs[j] == YES || j > INSIZE)
					break;
			}
		else {
			tbuf[j] = buf[i];
			j++;
		}
	tbuf[j] = EOS;
	strcpy(buf, tbuf);
}

/*
 * docline - produce a "contents" line.
 *
 */
docline(str,width,cline,page)
char *str;
int width;
char *cline;
int page;
{
	int i;

	for (i = 0; i < width - 6 && cline[i] != '\0'; i++)
		str[i] = cline[i];
	while (i < width - 6)
		str[i++] = '.';
	sprintf(str+i,"%5d\n",page);
}

