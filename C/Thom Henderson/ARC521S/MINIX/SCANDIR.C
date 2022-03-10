/*
**  SCANDIR
**  Scan a directory, collecting all (selected) items into a an array.
*/
#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>

#ifdef	RCSID
static char RCS[] = "$Header: scandir.c,v 1.1 87/12/29 21:35:56 rsalz Exp $";
#endif	/* RCSID */

/* Initial guess at directory size. */
#define INITIAL_SIZE	20

/* A convenient shorthand. */
typedef struct dirent	 ENTRY;

/* Linked in later. */
#ifndef __STDC__
extern char		*malloc();
extern char		*realloc();
#else
extern void		*malloc();
extern void		*realloc();
#endif
extern char		*strcpy();


int
scandir(Name, List, Selector, Sorter)
    char		  *Name;
    ENTRY		***List;
    int			 (*Selector)();
    int			 (*Sorter)();
{
    register ENTRY	 **names;
    register ENTRY	  *E;
    register DIR	  *Dp;
    register int	   i;
    register int	   size;

    /* Get initial list space and open directory. */
    size = INITIAL_SIZE;
    if ((names = (ENTRY **)malloc(size * sizeof names[0])) == NULL
     || (Dp = opendir(Name)) == NULL)
	return(-1);

    /* Read entries in the directory. */
    for (i = 0; E = readdir(Dp); )
	if (Selector == NULL || (*Selector)(E)) {
	    /* User wants them all, or he wants this one. */
	    if (++i >= size) {
		size <<= 1;
		names = (ENTRY **)realloc((char *)names, size * sizeof names[0]);
		if (names == NULL) {
		    closedir(Dp);
		    return(-1);
		}
	    }

	    /* Copy the entry. */
#ifdef atarist
	    if ((names[i - 1] = (ENTRY *)malloc(DIRSIZ)) == NULL) { 
#else
	    if ((names[i - 1] = (ENTRY *)malloc(E->d_reclen)) == NULL) { 
#endif
		closedir(Dp);
		return(-1);
	    }
	    names[i - 1]->d_ino = E->d_ino;
#ifndef atarist
	    names[i - 1]->d_off = E->d_off;
	    names[i - 1]->d_reclen = E->d_reclen;
#endif
	 /*   names[i - 1]->d_namlen = E->d_namlen; */
	    (void)strcpy(names[i - 1]->d_name, E->d_name);
	}

    /* Close things off. */
    names[i] = NULL;
    *List = names;
    closedir(Dp);

    /* Sort? */
    if (i && Sorter)
	qsort((char *)names, i, sizeof names[0], Sorter);

    return(i);
}
