/* xsimage.c - xscheme memory image save/restore functions */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* virtual machine registers */
extern LVAL xlfun;		/* current function */
extern LVAL xlenv;		/* current environment */
extern LVAL xlval;		/* value of most recent instruction */

/* stack limits */
extern LVAL *xlstkbase;		/* base of value stack */
extern LVAL *xlstktop;		/* top of value stack */

/* node space */
extern NSEGMENT *nsegments;	/* list of node segments */

/* vector (and string) space */
extern VSEGMENT *vsegments;	/* list of vector segments */
extern LVAL *vfree;		/* next free location in vector space */
extern LVAL *vtop;		/* top of vector space */

/* global variables */
extern LVAL obarray,eof_object,default_object;
extern jmp_buf top_level;
extern FUNDEF funtab[];

/* local variables */
static OFFTYPE off,foff;
static FILE *fp;

/* external routines */
extern FILE *osbopen();

/* forward declarations */
#ifdef __STDC__
static void freeimage(void);
static void setoffset(void);
static void writenode(LVAL node);
static void writeptr(OFFTYPE off);
static void readnode(int type,LVAL node);
static OFFTYPE readptr(void);
static LVAL cviptr(OFFTYPE o);
static OFFTYPE cvoptr(LVAL p);
static LVAL *getvspace(LVAL node,unsigned int size);
#else
static OFFTYPE readptr();
static OFFTYPE cvoptr();
static LVAL cviptr();
static LVAL *getvspace();
#endif

/* xlisave - save the memory image */
int xlisave(fname)
  char *fname;
{
    unsigned char *cp;
    NSEGMENT *nseg;
    int size,n;
    LVAL p,*vp;

    /* open the output file */
    if ((fp = osbopen(fname,"w")) == NULL)
	return (FALSE);

    /* first call the garbage collector to clean up memory */
    gc();

    /* write out the stack size */
    writeptr((OFFTYPE)(xlstktop-xlstkbase));

    /* write out the *obarray* symbol and various constants */
    writeptr(cvoptr(obarray));
    writeptr(cvoptr(eof_object));
    writeptr(cvoptr(default_object));

    /* setup the initial file offsets */
    off = foff = (OFFTYPE)2;

    /* write out all nodes that are still in use */
    for (nseg = nsegments; nseg != NULL; nseg = nseg->ns_next) {
	p = &nseg->ns_data[0];
	n = nseg->ns_size;
	for (; --n >= 0; ++p, off += sizeof(NODE))
	    switch (ntype(p)) {
	    case FREE:
		break;
	    case CONS:
	    case CLOSURE:
	    case METHOD:
	    case PROMISE:
	    case ENV:
		setoffset();
		osbputc(p->n_type,fp);
		writeptr(cvoptr(car(p)));
		writeptr(cvoptr(cdr(p)));
		foff += sizeof(NODE);
		break;
	    case SYMBOL:
	    case OBJECT:
	    case VECTOR:
	    case CODE:
	    case CONTINUATION:
		setoffset();
		osbputc(p->n_type,fp);
		size = getsize(p);
		writeptr((OFFTYPE)size);
		for (vp = p->n_vdata; --size >= 0; )
		    writeptr(cvoptr(*vp++));
		foff += sizeof(NODE);
		break;
	    case STRING:
		setoffset();
		osbputc(p->n_type,fp);
		size = getslength(p);
		writeptr((OFFTYPE)size);
		for (cp = (unsigned char *)getstring(p); --size >= 0; )
		    osbputc(*cp++,fp);
		foff += sizeof(NODE);
		break;
	    default:
		setoffset();
		writenode(p);
		foff += sizeof(NODE);
		break;
	    }
    }

    /* write the terminator */
    osbputc(FREE,fp);
    writeptr((OFFTYPE)0);

    /* close the output file */
    osclose(fp);

    /* return successfully */
    return (TRUE);
}

/* xlirestore - restore a saved memory image */
int xlirestore(fname)
  char *fname;
{
    unsigned int ssize;
    unsigned char *cp;
    int size,type;
    LVAL p,*vp;

    /* open the file */
    if ((fp = osbopen(fname,"r")) == NULL)
	return (FALSE);

    /* free the old memory image */
    freeimage();

    /* read the stack size */
    ssize = (unsigned int)readptr();

    /* allocate memory for the workspace */
    xlminit(ssize);

    /* read the *obarray* symbol and various constants */
    obarray = cviptr(readptr());
    eof_object = cviptr(readptr());
    default_object = cviptr(readptr());
    
    /* read each node */
    for (off = (OFFTYPE)2; (type = osbgetc(fp)) >= 0; )
	switch (type) {
	case FREE:
	    if ((off = readptr()) == (OFFTYPE)0)
		goto done;
	    break;
	case CONS:
	case CLOSURE:
	case METHOD:
	case PROMISE:
	case ENV:
	    p = cviptr(off);
	    p->n_type = type;
	    rplaca(p,cviptr(readptr()));
	    rplacd(p,cviptr(readptr()));
	    off += sizeof(NODE);
	    break;
	case SYMBOL:
	case OBJECT:
	case VECTOR:
	case CODE:
	case CONTINUATION:
	    p = cviptr(off);
	    p->n_type = type;
	    p->n_vsize = size = (int)readptr();
	    p->n_vdata = getvspace(p,size);
	    for (vp = p->n_vdata; --size >= 0; )
		*vp++ = cviptr(readptr());
	    off += sizeof(NODE);
	    break;
	case STRING:
	    p = cviptr(off);
	    p->n_type = type;
	    p->n_vsize = size = (int)readptr();
	    p->n_vdata = getvspace(p,btow_size(size));
	    for (cp = (unsigned char *)getstring(p); --size >= 0; )
		*cp++ = osbgetc(fp);
	    off += sizeof(NODE);
	    break;
	case PORT:
	    p = cviptr(off);
	    readnode(type,p);
	    setfile(p,NULL);
	    off += sizeof(NODE);
	    break;
	case SUBR:
	case XSUBR:
	    p = cviptr(off);
	    readnode(type,p);
	    p->n_subr = funtab[getoffset(p)].fd_subr;
	    off += sizeof(NODE);
	    break;
	default:
	    readnode(type,cviptr(off));
	    off += sizeof(NODE);
	    break;
	}
done:

    /* close the input file */
    osclose(fp);

    /* collect to initialize the free space */
    gc();

    /* lookup all of the symbols the interpreter uses */
    xlsymbols();

    /* return successfully */
    return (TRUE);
}

/* freeimage - free the current memory image */
static void freeimage()
{
    NSEGMENT *nextnseg;
    VSEGMENT *nextvseg;
    FILE *fp;
    LVAL p;
    int n;

    /* close all open ports and free each node segment */
    while (nsegments != NULL) {
	nextnseg = nsegments->ns_next;
	p = &nsegments->ns_data[0];
	n = nsegments->ns_size;
	for (; --n >= 0; ++p)
	    switch (ntype(p)) {
	    case PORT:
		if ((fp = getfile(p)) != NULL
		 && (fp != stdin && fp != stdout && fp != stderr))
		    osclose(getfile(p));
		break;
	    }
	free((char *)nsegments);
	nsegments = nextnseg;
    }

    /* free each vector segment */
    while (vsegments != NULL) {
	nextvseg = vsegments->vs_next;
	free((char *)vsegments);
	vsegments = nextvseg;
    }
    
    /* free the stack */
    if (xlstkbase)
	free((char *)xlstkbase);
}

/* setoffset - output a positioning command if nodes have been skipped */
static void setoffset()
{
    if (off != foff) {
	osbputc(FREE,fp);
	writeptr(off);
	foff = off;
    }
}

/* writenode - write a node to a file */
static void writenode(node)
  LVAL node;
{
    char *p = (char *)&node->n_info;
    int n = sizeof(union ninfo);
    osbputc(node->n_type,fp);
    while (--n >= 0)
	osbputc(*p++,fp);
}

/* writeptr - write a pointer to a file */
static void writeptr(off)
  OFFTYPE off;
{
    char *p = (char *)&off;
    int n = sizeof(OFFTYPE);
    while (--n >= 0)
	osbputc(*p++,fp);
}

/* readnode - read a node */
static void readnode(type,node)
  int type; LVAL node;
{
    char *p = (char *)&node->n_info;
    int n = sizeof(union ninfo);
    node->n_type = type;
    while (--n >= 0)
	*p++ = osbgetc(fp);
}

/* readptr - read a pointer */
static OFFTYPE readptr()
{
    OFFTYPE off;
    char *p = (char *)&off;
    int n = sizeof(OFFTYPE);
    while (--n >= 0)
	*p++ = osbgetc(fp);
    return (off);
}

/* cviptr - convert a pointer on input */
static LVAL cviptr(o)
  OFFTYPE o;
{
    NSEGMENT *newnsegment(),*nseg;
    OFFTYPE off = (OFFTYPE)2;
    OFFTYPE nextoff;

    /* check for nil and small fixnums */
    if (o == (OFFTYPE)0 || (o & 1) == 1)
	return ((LVAL)o);

    /* compute a pointer for this offset */
    for (nseg = nsegments; nseg != NULL; nseg = nseg->ns_next) {
	nextoff = off + (OFFTYPE)(nseg->ns_size * sizeof(NODE));
	if (o >= off && o < nextoff)
	    return ((LVAL)((OFFTYPE)&nseg->ns_data[0] + o - off));
	off = nextoff;
    }

    /* create new segments if necessary */
    for (;;) {

	/* create the next segment */
	if ((nseg = newnsegment(NSSIZE)) == NULL)
	    xlfatal("insufficient memory - segment");

	/* check to see if the offset is in this segment */
	nextoff = off + (OFFTYPE)(nseg->ns_size * sizeof(NODE));
	if (o >= off && o < nextoff)
	    return ((LVAL)((OFFTYPE)&nseg->ns_data[0] + o - off));
	off = nextoff;
    }
}

/* cvoptr - convert a pointer on output */
static OFFTYPE cvoptr(p)
  LVAL p;
{
    OFFTYPE off = (OFFTYPE)2;
    NSEGMENT *nseg;

    /* check for nil and small fixnums */
    if (p == NIL || !ispointer(p))
	return ((OFFTYPE)p);

    /* compute an offset for this pointer */
    for (nseg = nsegments; nseg != NULL; nseg = nseg->ns_next) {
	if (INSEGMENT(p,nseg))
	    return (off + ((OFFTYPE)p - (OFFTYPE)&nseg->ns_data[0]));
	off += (OFFTYPE)(nseg->ns_size * sizeof(NODE));
    }

    /* pointer not within any segment */
    xlerror("bad pointer found during image save",p);
    return ((OFFTYPE)0); /* never reached */
}

/* getvspace - allocate vector space */
static LVAL *getvspace(node,size)
  LVAL node; unsigned int size;
{
    LVAL *p;
    ++size; /* space for the back pointer */
    if (!VCOMPARE(vfree,size,vtop)
    &&  !checkvmemory(size)
    &&  !makevmemory(size))
	xlfatal("insufficient vector space");
    p = vfree;
    vfree += size;
    *p++ = node;
    return (p);
}
