/* wincap.c */

/*
 * Winchester Disk `capability' file parser.
 *
 *	int wgetent(name);
 *	char *name;
 *
 *	int wallents(buf);
 *	char *buf;
 *
 *	int wgetnum(id, anum);
 *	char *id;
 *	long *anum;
 *
 *	int wgetflag(id);
 *	char *id;
 *
 *	char *wgetstr(id);
 *	char *id;
 *
 *	int wclose();
 *
 */
#include <obdefs.h>
#include <osbind.h>
#include "fhdx.h"
#include "define.h"
#include "addr.h"


#define	WBUFSIZE	1024

extern char toupper();
extern char *getln();
extern cgetln();


char *wgetstr();
char *wfindid();

static char wbuf[WBUFSIZE];
static int wcapfd;
static int wcapopen = 0;


/*
 * Get an entry into the buffer.
 *
 */
wgetent(name, id)
char *name;
char *id;
{
    char *nm;

    if (wcapok() < 0) return ERROR;
    wreset();

    if (id == NULL)
	id = "mn";

    while (nextentry() == OK)
    {
	nm = wgetstr(id);
	if (nm != NULL &&
	    !strcmp(nm, name)) return OK;
    }
    return ERROR;
}


/*
 * Seek to beginning of wincap file
 * and reset the line demon.
 *
 */
wreset()
{
    Fseek(0L, wcapfd, 0);
    getln(-1);
}


/*
 * Get a list of all wcap entries;
 * stuff into the buffer, seperated by nulls;
 * final null marks last entry.
 *
 */
wallents(buf, id)
char *buf;
char *id;
{
    char *nm;

    if (id == NULL)
	id = "mn";

    if (wcapok() < 0) return ERROR;
    wreset();

    while (nextentry() == OK)
    {
	if ((nm = wgetstr(id)) == NULL)
	    continue;
	while (*nm)
	    *buf++ = *nm++;
	*buf++ = '\0';
    }

    *buf++ = '\0';
    return OK;
}


/*
 * Get number from wcap entry.
 *
 */
int wgetnum(id, anum)
char *id;
long *anum;
{
    char *ent;

    if ((ent = wfindid(id)) == NULL ||
	*ent++ != '#')
	    return ERROR;
    return getnum(ent, anum);
}


/*
 * Get flag from wcap entry.
 *
 */
wgetflag(id)
char *id;
{
    char *ent;

    if ((ent = wfindid(id)) == NULL)
	    return ERROR;

    return OK;
}


/*
 * Get string from wcap entry;
 * return NULL if the id doesn't exist.
 *
 */
char *wgetstr(id)
char *id;
{
    char *ent;

    if ((ent = wfindid(id)) == NULL ||
	*ent++ != '=')
	    return NULL;

    return ent;
}


/*
 * Find an id;
 * return pointer to rest of item (or NULL).
 *
 */
char *wfindid(id)
char *id;
{
    char *s;
    char *skipstr();

    s = &wbuf[0];
    s = skipstr(s);
    while (*s)
    {
	if (s[0] == id[0] &&
	    s[1] != '\0' && id[1] != '\0' &&
	    s[1] == id[1])
		return (s + 2);
	s = skipstr(s);
    }
    return NULL;
}


/*
 * Skip string;
 * return ptr to thing past the string's `\0'.
 *
 */
char *skipstr(s)
char *s;
{
    while (*s) ++s;
    return ++s;
}


/*
 * Get next entry from wincap file;
 * return ERROR if no more entries.
 *
 * Seperating `:'s are turned into \0,
 * `\' can prevent that.
 *
 ***************** ***************** ***************** *****************
 * Awww, shucks -- we need to do a "string delete" for that.  So '\'
 * doesn't work yet.
 ***************** ***************** ***************** *****************
 *
 */
nextentry()
{
    char *s;

    while (cgetln(wcapfd, wbuf))
    {
	if (wbuf[0] == '#' ||		/* comment or empty line */
	    wbuf[0] == '\0')
		continue;

	for (s = wbuf; *s; ++s)
	    switch (*s)
	    {
		case '\\':	++s;
				break;

		case ':':	*s = '\0';
				break;

		default:	continue;
	    }
	*s++ = '\0';
	return OK;
    }

    return ERROR;
}


/*
 * If the wcap file isn't open, then open it;
 * return ERROR if the file won't open.
 *
 */
wcapok()
{
    extern int running;

    if (!wcapopen &&
	(wcapfd = (int)Fopen(WCAPFILE, 0)) < 0)
    {
	running = 0;
	return err(nowincap);
    }

    wcapopen = 1;
    return OK;
}


/*
 * If the wcap file isn't closed, then close it;
 * return ERROR if the file won't close.
 *
 */
wclose()
{
    int ret;

    ret = OK;
    if (wcapopen)
        if ((ret = Fclose(wcapfd)) == OK)
	    wcapopen = 0;

    return ret;
}


/*
 * Parse number;
 *	octal numbers start with a leading `0';
 *	decimal numbers start with digits;
 *	hex numbers start with `0x' or `$';
 *	numbers may be terminated with a `k' (1,000)
 *	or `m' (1,000,000) multiplier.
 *
 */
getnum(s, av)
char *s;
long *av;
{
    static char numtab[] = "0123456789abcdefABCDEF";
    int base, i;
    long v;

    base = 10;
    v = 0L;
    if(*s == '$') {
	++s;
	base = 16;
    } else if (*s == '0' && toupper(s[1]) == 'X') {
	s += 2;
	base = 16;
    } else if (*s == '0')
	base = 8;

    while(*s) {
	for(i = 0; numtab[i]; ++i)
	    if(*s == numtab[i]) break;
	if(!numtab[i]) break;
	if(base == 16 && i >= 16) i-=6;
	if(i >= base) return ERROR;
	v = (v * base) + i;
	++s;
    }


    /* handle multiplier */
    switch (toupper(*s)) {
	case 'K':
		v *= 1024L;
		break;

	case 'M':
		v *= (1024L * 1024L);
		break;

	case '\0':
		break;

	default:
		return ERROR;
    }

    *av = v;
    return OK;
}
