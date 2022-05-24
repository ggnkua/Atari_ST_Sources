/* chain.c - screen file storage and display */
/* uses linked lists with each node defined as a struct strchain */

/* for Turbo C insert line "#define TURBOC 1" */
#if TURBOC
    #include <alloc.h>		/* Turbo C library file name */
#else
    #include <malloc.h>		/* Microsoft C library file name */
#endif

#include <stdio.h>
#include "standard.h"
#include "chain.h"		/* contains structure definition */


struct strchain *inpchain(file, maxlen)		/* read file into chain */
char *file;
int maxlen;
{
    FILE *stream;
    struct strchain *p, *root, *oldp;
    char *strbuf;

    strbuf = (char *) malloc(maxlen + 1);	/* set asside input buffer */

    stream = fopen(file, "r");

    p = root = chainalloc();
    while (fgets(strbuf, maxlen, stream) != NULL){
	p->line = strsave(strbuf);
	p->next = chainalloc();
        oldp = p;
	p = p->next;
    }
    oldp->next = NULL;				/* NULL marks chain end */
    free(p);					/* free unused end node */
    fclose(stream);
    free(strbuf);				/* free buff for other use */
    return(root);
}


dechain(p)	/* free all memory reserved for chain pointed to by p */
struct strchain *p;
{
    struct strchain *q;
    while (p != NULL){
	q = p->next;
	free(p->line);
	free(p);
	p = q;
    }
}


dispchain(p)			/* write all lines of list to stdout */
struct strchain *p;		/* standard console output version */
{
    while (p != NULL){
	fputs(p->line, stdout);
	p = p->next;
    }
}



struct strchain *chainalloc()	/* save memory space for next link */
{
    return((struct strchain *) malloc(sizeof(struct strchain)));
}



char *strsave(s)	/* save string s somewhere, K&R p 103 */
char *s;
{
    char *p;
    if ((p = (char *) malloc(strlen(s) + 1)) != NULL)
	strcpy(p,s);
    return(p);
}

