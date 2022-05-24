/* chain.c - screen file storage and display */
/* uses linked lists with each node defined as a struct strchain */

/* for Turbo C insert line "#define TURBOC 1" */


#include <stdio.h>

#if TURBOC
    #include <alloc.h>		/* Turbo C library file name */
#else
    #include <malloc.h>		/* Microsoft C library file name */
#endif

#include "standard.h"
#include "chain.h"		/* contains structure definition */



struct strchain *inpchain(file, maxlen)		/* read file into chain */
char *file;
int maxlen;
{
    FILE *stream;
    struct strchain *root;
    char *strbuf;

    strbuf = (char *) malloc(maxlen + 1);		/* set asside input buffer */

    stream = fopen(file, "r");
    
    root = NULL;
    while (fgets(strbuf, maxlen, stream) != NULL){
	root = chain(root, strbuf);
    }
    
    fclose(stream);
    free(strbuf);				/* free buff for other use */
    return(root);
}



struct strchain *chain(p,w)	/* add a string to end of linked list */
struct strchain *p;
char *w;
{
    if (p == NULL){
	p = chainalloc();
	p->line = strsave(w);
	p->next = NULL;
    }
    else{
	p->next = chain(p->next, w);
    }
    return(p);
}



dechain(p)	/* free all memory reserved for chain pointed to by p */
struct strchain *p;
{
    struct strchain *q;
    if (p != NULL){
	q = p->next;
	free(p->line);
	free(p);
	dechain(q);
    }
}



dispchain(p)			/* write all lines of list to stdout */
struct strchain *p;		/* standard console output version */
{
    if (p){
	fputs(p->line, stdout);
	dispchain(p->next);
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



/* the following are fast console display routines that work by writing to */
/* the video memory area.  The base address VIDMEM may have to me adjusted */
/* for operation on another machine.  Current base is for monochrome adapt.*/


#define VIDMEM	0xB0000000L	/* address of upper left corner of video mem */

fwriteword(mode, string, x, y)	/* write string to x,y on screen */
int mode, x, y;			/* use direct writing to screen memory */
char *string;
{
    unsigned int modebyte, offset;
    
    switch(mode){
    case(BWC):		/* normal chars */
	modebyte = 0x07;
	break;
    case(ULC):		/* underline */
	modebyte = 0x01;
	break;
    case(RVC):		/* reverse video */
	modebyte = 0x70;
	break;
    case(BRVC):		/* blinking reverse video */
	modebyte = 0xF0;
	break;
    default:
	modebyte = 0x07;
    }
    
    offset = (x * 2) + (y * SCRNWIDE * 2);
    
    while (*string != '\n' && *string){
	*(char far *)(VIDMEM + (offset++)) = *string++;
	*(char far *)(VIDMEM + (offset++)) = modebyte;
    }
}



fdispchain(p, y)		/* write all lines of list to console */
struct strchain *p;		/* fast output version */
int y;				/* y is line number to start output */
{
    if (p){
	fwriteword(BWC, p->line, 0, y);
	fdispchain(p->next, ++y);
    }
}


