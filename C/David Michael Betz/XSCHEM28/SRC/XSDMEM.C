/* xsdmem.c - xscheme dynamic memory management routines */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include "xscheme.h"

/* virtual machine registers */
LVAL xlfun=NIL;		/* current function */
LVAL xlenv=NIL;		/* current environment */
LVAL xlval=NIL;		/* value of most recent instruction */
LVAL *xlsp=NULL;	/* value stack pointer */

/* stack limits */
LVAL *xlstkbase=NULL;	/* base of value stack */
LVAL *xlstktop=NULL;	/* top of value stack (actually, one beyond) */

/* variables shared with xsimage.c */
FIXTYPE total=0;	/* total number of bytes of memory in use */
FIXTYPE gccalls=0;	/* number of calls to the garbage collector */

/* node space */
NSEGMENT *nsegments=NULL;	/* list of node segments */
NSEGMENT *nslast=NULL;		/* last node segment */
int nscount=0;			/* number of node segments */
FIXTYPE nnodes=0;		/* total number of nodes */
FIXTYPE nfree=0;		/* number of nodes in free list */
LVAL fnodes=NIL;		/* list of free nodes */

/* vector (and string) space */
VSEGMENT *vsegments=NULL;	/* list of vector segments */
VSEGMENT *vscurrent=NULL;	/* current vector segment */
int vscount=0;			/* number of vector segments */
LVAL *vfree=NULL;		/* next free location in vector space */
LVAL *vtop=NULL;		/* top of vector space */

/* external variables */
extern LVAL s_unbound;		/* *UNBOUND* symbol */
extern LVAL obarray;		/* *OBARRAY* symbol */
extern LVAL default_object;	/* default object */
extern LVAL eof_object;		/* eof object */
extern LVAL true;		/* truth value */

/* external routines */
extern char *calloc();

/* forward declarations */
#ifdef __STDC__
static LVAL allocnode(int type);
static void findmemory(void);
static LVAL allocvector(int type,int size);
static int findvmemory(int size);
static void mark(LVAL ptr);
static void markvector(LVAL vect);
static void compact(void);
static void compact_vector(VSEGMENT *vseg);
static void sweep(void);
static void sweep_segment(NSEGMENT *nseg);
static void badobjtype(int type);
#else
static LVAL allocnode();
static LVAL allocvector();
static LVAL compact();
#endif

/* cons - construct a new cons node */
LVAL cons(x,y)
  LVAL x,y;
{
    LVAL nnode;

    /* get a free node */
    if ((nnode = fnodes) == NIL) {
	check(2);
	push(x);
	push(y);
	findmemory();
	if ((nnode = fnodes) == NIL)
	    xlabort("insufficient node space");
	drop(2);
    }

    /* unlink the node from the free list */
    fnodes = cdr(nnode);
    --nfree;

    /* initialize the new node */
    nnode->n_type = CONS;
    rplaca(nnode,x);
    rplacd(nnode,y);

    /* return the new node */
    return (nnode);
}

/* newframe - create a new environment frame */
LVAL newframe(parent,size)
  LVAL parent; int size;
{
    LVAL frame;
    frame = cons(newvector(size),parent);
    frame->n_type = ENV;
    return (frame);
}

/* cvstring - convert a string to a string node */
LVAL cvstring(str)
  char *str;
{
    LVAL val;
    val = newstring(strlen(str)+1);
    strcpy(getstring(val),str);
    return (val);
}

/* cvsymbol - convert a string to a symbol */
LVAL cvsymbol(pname)
  char *pname;
{
    LVAL val;
    val = allocvector(SYMBOL,SYMSIZE);
    cpush(val);
    setvalue(val,s_unbound);
    setpname(val,cvstring(pname));
    setplist(val,NIL);
    return (pop());
}

/* cvfixnum - convert an integer to a fixnum node */
LVAL cvfixnum(n)
  FIXTYPE n;
{
    LVAL val;
    if (n >= SFIXMIN && n <= SFIXMAX)
	return (cvsfixnum(n));
    val = allocnode(FIXNUM);
    val->n_int = n;
    return (val);
}

/* cvflonum - convert a floating point number to a flonum node */
LVAL cvflonum(n)
  FLOTYPE n;
{
    LVAL val;
    val = allocnode(FLONUM);
    val->n_flonum = n;
    return (val);
}

/* cvchar - convert an integer to a character node */
LVAL cvchar(ch)
  int ch;
{
    LVAL val;
    val = allocnode(CHAR);
    val->n_chcode = ch;
    return (val);
}

/* cvclosure - convert code and an environment to a closure */
LVAL cvclosure(code,env)
  LVAL code,env;
{
    LVAL val;
    val = cons(code,env);
    val->n_type = CLOSURE;
    return (val);
}

/* cvpromise - convert a procedure to a promise */
LVAL cvpromise(code,env)
  LVAL code,env;
{
    LVAL val;
    val = cons(cvclosure(code,env),NIL);
    val->n_type = PROMISE;
    return (val);
}

/* cvmethod - convert code and an environment to a method */
LVAL cvmethod(code,class)
  LVAL code,class;
{
    LVAL val;
    val = cons(code,class);
    val->n_type = METHOD;
    return (val);
}

/* cvsubr - convert a function to a subr/xsubr */
LVAL cvsubr(type,fcn,offset)
  int type; LVAL (*fcn)(); int offset;
{
    LVAL val;
    val = allocnode(type);
    val->n_subr = fcn;
    val->n_offset = offset;
    return (val);
}

/* cvport - convert a file pointer to an port */
LVAL cvport(fp,flags)
  FILE *fp; int flags;
{
    LVAL val;
    val = allocnode(PORT);
    setfile(val,fp);
    setsavech(val,'\0');
    setpflags(val,flags);
    return (val);
}

/* newvector - allocate and initialize a new vector */
LVAL newvector(size)
  int size;
{
    return (allocvector(VECTOR,size));
}

/* newstring - allocate and initialize a new string */
LVAL newstring(size)
  int size;
{
    LVAL val;
    val = allocvector(STRING,btow_size(size));
    val->n_vsize = size;
    return (val);
}

/* newcode - create a new code object */
LVAL newcode(nlits)
  int nlits;
{
    return (allocvector(CODE,nlits));
}

/* newcontinuation - create a new continuation object */
LVAL newcontinuation(size)
  int size;
{
    return (allocvector(CONTINUATION,size));
}

/* newobject - allocate and initialize a new object */
LVAL newobject(cls,size)
  LVAL cls; int size;
{
    LVAL val;
    val = allocvector(OBJECT,size+2); /* class, ivars */
    setclass(val,cls);
    return (val);
}

/* allocnode - allocate a new node */
static LVAL allocnode(type)
  int type;
{
    LVAL nnode;

    /* get a free node */
    if ((nnode = fnodes) == NIL) {
	findmemory();
	if ((nnode = fnodes) == NIL)
	    xlabort("insufficient node space");
    }

    /* unlink the node from the free list */
    fnodes = cdr(nnode);
    --nfree;

    /* initialize the new node */
    nnode->n_type = type;
    rplacd(nnode,NIL);

    /* return the new node */
    return (nnode);
}

/* findmemory - garbage collect, then add more node space if necessary */
static void findmemory()
{
    /* first try garbage collecting */
    gc();

    /* expand memory only if less than one segment is free */
    if (nfree < (long)NSSIZE)
	nexpand(NSSIZE);
}

/* nexpand - expand node space */
int nexpand(size)
  int size;
{
    NSEGMENT *newnsegment(),*newseg;
    LVAL p;
    int i;

    /* allocate the new segment */
    if ((newseg = newnsegment(size)) != NULL) {

	/* add each new node to the free list */
	p = &newseg->ns_data[0];
	for (i = NSSIZE; --i >= 0; ++p) {
	    p->n_type = FREE;
	    p->n_flags = 0;
	    rplacd(p,fnodes);
	    fnodes = p;
	}
    }
    return (newseg != NULL);
}

/* allocvector - allocate and initialize a new vector node */
static LVAL allocvector(type,size)
  int type,size;
{
    register LVAL val,*p;
    register int i;

    /* get a free node */
    if ((val = fnodes) == NIL) {
	findmemory();
	if ((val = fnodes) == NIL)
	    xlabort("insufficient node space");
    }

    /* unlink the node from the free list */
    fnodes = cdr(fnodes);
    --nfree;

    /* initialize the vector node */
    val->n_type = type;
    val->n_vsize = size;
    val->n_vdata = NULL;
    cpush(val);

    /* add space for the backpointer */
    ++size;
    
    /* make sure there's enough space */
    if (!VCOMPARE(vfree,size,vtop)
    &&  !checkvmemory(size)
    &&  !findvmemory(size))
	xlabort("insufficient vector space");

    /* allocate the next available block */
    p = vfree;
    vfree += size;
    
    /* store the backpointer */
    *p++ = top();
    val->n_vdata = p;

    /* set all the elements to NIL */
    for (i = size; i > 1; --i)
	*p++ = NIL;

    /* return the new vector */
    return (pop());
}

/* findvmemory - find vector memory */
static int findvmemory(size)
  int size;
{
    /* try garbage collecting */
    gc();

    /* check to see if we found enough memory */
    if (VCOMPARE(vfree,size,vtop) || checkvmemory(size))
	return (TRUE);

    /* expand vector space */
    return (makevmemory(size));
}

/* checkvmemory - check for vector memory (used by 'xsimage.c') */
int checkvmemory(size)
  int size;
{
    VSEGMENT *vseg;
    for (vseg = vsegments; vseg != NULL; vseg = vseg->vs_next)
	if (vseg != vscurrent && VCOMPARE(vseg->vs_free,size,vseg->vs_top)) {
	    if (vscurrent != NULL)
		vscurrent->vs_free = vfree;
	    vfree = vseg->vs_free;
	    vtop = vseg->vs_top;
	    vscurrent = vseg;
	    return (TRUE);
	}	
    return (FALSE);
}
    
/* makevmemory - make vector memory (used by 'xsimage.c') */
int makevmemory(size)
  int size;
{
    return (vexpand(size < VSSIZE ? VSSIZE : size));
}

/* vexpand - expand vector space */
int vexpand(size)
  int size;
{
    VSEGMENT *newvsegment(),*vseg;

    /* allocate the new segment */
    if ((vseg = newvsegment(size)) != NULL) {

	/* initialize the new segment and make it current */
	if (vscurrent != NULL)
	    vscurrent->vs_free = vfree;
	vfree = vseg->vs_free;
	vtop = vseg->vs_top;
	vscurrent = vseg;
    }
    return (vseg != NULL);
}

/* newnsegment - create a new node segment */
NSEGMENT *newnsegment(n)
  unsigned int n;
{
    NSEGMENT *newseg;

    /* allocate the new segment */
    if ((newseg = (NSEGMENT *)calloc(1,nsegsize(n))) == NULL)
	return (NULL);

    /* initialize the new segment */
    newseg->ns_size = n;
    newseg->ns_next = NULL;
    if (nsegments)
	nslast->ns_next = newseg;
    else
	nsegments = newseg;
    nslast = newseg;

    /* update the statistics */
    total += (long)nsegsize(n);
    nnodes += (long)n;
    nfree += (long)n;
    ++nscount;

    /* return the new segment */
    return (newseg);
}
 
/* newvsegment - create a new vector segment */
VSEGMENT *newvsegment(n)
  unsigned int n;
{
    VSEGMENT *newseg;

    /* allocate the new segment */
    if ((newseg = (VSEGMENT *)calloc(1,vsegsize(n))) == NULL)
	return (NULL);

    /* initialize the new segment */
    newseg->vs_free = &newseg->vs_data[0];
    newseg->vs_top = newseg->vs_free + n;
    newseg->vs_next = vsegments;
    vsegments = newseg;

    /* update the statistics */
    total += (long)vsegsize(n);
    ++vscount;

    /* return the new segment */
    return (newseg);
}
 
/* gc - garbage collect */
void gc()
{
    register LVAL *p,tmp;

    /* mark the obarray and the current environment */
    if (obarray && ispointer(obarray))
	mark(obarray);
    if (xlfun && ispointer(xlfun))
	mark(xlfun);
    if (xlenv && ispointer(xlenv))
	mark(xlenv);
    if (xlval && ispointer(xlval))
	mark(xlval);
    if (default_object && ispointer(default_object))
	mark(default_object);
    if (eof_object && ispointer(eof_object))
	mark(eof_object);
    if (true && ispointer(true))
	mark(true);

    /* mark the stack */
    for (p = xlsp; p < xlstktop; ++p)
	if ((tmp = *p) != NIL && ispointer(tmp))
	    mark(tmp);

    /* compact vector space */
    gc_protect(compact);

    /* sweep memory collecting all unmarked nodes */
    sweep();

    /* count the gc call */
    ++gccalls;
}

/* mark - mark all accessible nodes */
static void mark(ptr)
  LVAL ptr;
{
    register LVAL this,prev,tmp;

    /* initialize */
    prev = NIL;
    this = ptr;

    /* mark this node */
    for (;;) {

	/* descend as far as we can */
	while (!(this->n_flags & MARK))

	    /* mark this node and trace its children */
	    switch (this->n_type) {
	    case CONS:		/* mark cons-like nodes */
	    case CLOSURE:
	    case METHOD:
	    case PROMISE:
	    case ENV:
		this->n_flags |= MARK;
		if ((tmp = car(this)) != NIL && ispointer(tmp)) {
		    this->n_flags |= LEFT;
		    rplaca(this,prev);
		    prev = this;
		    this = tmp;
		}
		else if ((tmp = cdr(this)) != NIL && ispointer(tmp)) {
		    rplacd(this,prev);
		    prev = this;
		    this = tmp;
		}
		break;
	    case SYMBOL:	/* mark vector-like nodes */
	    case OBJECT:
	    case VECTOR:
	    case CODE:
	    case CONTINUATION:
		this->n_flags |= MARK;
		markvector(this);
		break;
	    case FIXNUM:	/* mark objects that don't contain pointers */
	    case FLONUM:
	    case STRING:
	    case PORT:
	    case SUBR:
	    case XSUBR:
	    case CSUBR:
	    case CHAR:
		this->n_flags |= MARK;
		break;
	    default:		/* bad object type */
		badobjtype(this->n_type);
		break;
	    }

	/* backup to a point where we can continue descending */
	for (;;)

	    /* make sure there is a previous node */
	    if (prev) {
		if (prev->n_flags & LEFT) {	/* came from left side */
		    prev->n_flags &= ~LEFT;
		    tmp = car(prev);
		    rplaca(prev,this);
		    if ((this = cdr(prev)) != NIL && ispointer(this)) {
			rplacd(prev,tmp);			
			break;
		    }
		}
		else {				/* came from right side */
		    tmp = cdr(prev);
		    rplacd(prev,this);
		}
		this = prev;			/* step back up the branch */
		prev = tmp;
	    }

	    /* no previous node, must be done */
	    else
		return;
    }
}

/* markvector - mark a vector-like node */
static void markvector(vect)
  LVAL vect;
{
    register LVAL tmp,*p;
    register int n;
    if ((p = vect->n_vdata) != NULL) {
	n = getsize(vect);
	while (--n >= 0)
	    if ((tmp = *p++) != NIL && ispointer(tmp))
		mark(tmp);
    }
}

/* compact - compact vector space */
static void compact()
{
    VSEGMENT *vseg;

    /* store the current segment information */
    if (vscurrent)
	vscurrent->vs_free = vfree;

    /* compact each vector segment */
    for (vseg = vsegments; vseg != NULL; vseg = vseg->vs_next)
	compact_vector(vseg);

    /* make the first vector segment current */
    if ((vscurrent = vsegments) != NULL) {
	vfree = vscurrent->vs_free;
	vtop = vscurrent->vs_top;
    }
}

/* compact_vector - compact a vector segment */
static void compact_vector(vseg)
  VSEGMENT *vseg;
{
    register LVAL *vdata,*vnext,*vfree,vector;
    register int vsize;

    vdata = vnext = &vseg->vs_data[0];
    vfree = vseg->vs_free;
    while (vdata < vfree) {
	vector = *vdata;
	vsize = (vector->n_type == STRING ? btow_size(vector->n_vsize)
					  : vector->n_vsize) + 1;
	if (vector->n_flags & MARK) {
	    if (vdata == vnext) {
		vdata += vsize;
		vnext += vsize;
	    }
	    else {
		vector->n_vdata = vnext + 1;
		while (--vsize >= 0)
		    *vnext++ = *vdata++;
	    }
	}
	else
	    vdata += vsize;
    }
    vseg->vs_free = vnext;
}

/* sweep - sweep all unmarked nodes and add them to the free list */
static void sweep()
{
    NSEGMENT *nseg;

    /* empty the free list */
    fnodes = NIL;
    nfree = 0L;

    /* sweep each node segment */
    for (nseg = nsegments; nseg != NULL; nseg = nseg->ns_next)
	sweep_segment(nseg);
}

/* sweep_segment - sweep a node segment */
static void sweep_segment(nseg)
  NSEGMENT *nseg;
{
    register FIXTYPE n;
    register LVAL p;

    /* add all unmarked nodes */
    for (p = &nseg->ns_data[0], n = nseg->ns_size; --n >= 0L; ++p)
	if (!(p->n_flags & MARK)) {
	    switch (p->n_type) {
	    case PORT:
		if (getfile(p))
		    osclose(getfile(p));
		break;
	    }
	    p->n_type = FREE;
	    rplacd(p,fnodes);
	    fnodes = p;
	    ++nfree;
	}
	else
	    p->n_flags &= ~MARK;
}

/* xlminit - initialize the dynamic memory module */
void xlminit(ssize)
  unsigned int ssize;
{
    unsigned int n;

    /* initialize our internal variables */
    gccalls = 0;
    total = 0L;

    /* initialize node space */
    nsegments = nslast = NULL;
    nscount = 0;
    nnodes = nfree = 0L;
    fnodes = NIL;

    /* initialize vector space */
    vsegments = vscurrent = NULL;
    vscount = 0;
    vfree = vtop = NULL;
    
    /* allocate the value stack */
    n = ssize * sizeof(LVAL);
    if ((xlstkbase = (LVAL *)calloc(1,n)) == NULL)
	xlfatal("insufficient memory");
    total += (long)n;

    /* initialize structures that are marked by the collector */
    obarray = default_object = eof_object = true = NIL;
    xlfun = xlenv = xlval = NIL;

    /* initialize the stack */
    xlsp = xlstktop = xlstkbase + ssize;
}

/* badobjtype - report a bad object type error */
static void badobjtype(type)
  int type;
{
    char buf[100];
    sprintf(buf,"bad object type - %d",type);
    xlfatal(buf);
}
