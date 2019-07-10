/*
 * labelcmp.c
 *
 * 90Aug27 AA	Split from libhash.c.
 */

/*
 ********************************************************
 * labelcmp() - compare a nodename with a pattern.	*
 *	In nodenames, `_' is equivalent to space.	*
 ********************************************************
 */
labelcmp(p1, p2)
char *p1, *p2;
{
    register d1, d2;

    do {
	if (!*p1)
	    break;
	d1 = (*p1 == '_') ? ' ' : tolower(*p1);
	d2 = (*p2 == '_') ? ' ' : tolower(*p2);
	++p1, ++p2;
    } while (d1 == d2);
    return d1-d2;
}

