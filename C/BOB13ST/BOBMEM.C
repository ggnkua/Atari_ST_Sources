/* bobmem.c - memory manager */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

#include <setjmp.h>
#include "bob.h"

/* allocation unit */
typedef char *AUNIT;
#define ALLOCSIZE(x)	(((x) + sizeof(AUNIT) - 1) / sizeof(AUNIT))

/* block flags */
#define MARK	1

/* size of each type of memory segment */
#define VSSIZE	10000	/* number of LVAL's per vector segment */
#define VCOMPARE(f,s,t)	((f) + (s) <= (t))

/* macros to compute the size of a segment */
#define vsegsize(n) (sizeof(VSEGMENT)+((n)-1)*sizeof(char *))

/* macro to convert a byte size to a word size */
#define btow_size(n)	(((n) + sizeof(char *) - 1) / sizeof(char *))

/* vector segment structure */
typedef struct vsegment {
    struct vsegment *vs_next;	/* next vector segment */
    AUNIT *vs_free;		/* next free location in this segment */
    AUNIT *vs_top;		/* top of segment (plus one) */
    AUNIT vs_data[1];		/* segment data */
} VSEGMENT;

/* global variables */
VALUE symbols;	/* the symbol table */
VALUE classes;	/* the class table */
VALUE nil;	/* the nil value */

/* vector (and string) space */
static VSEGMENT *vsegments=NULL;/* list of vector segments */
static VSEGMENT *vscurrent=NULL;/* current vector segment */
static AUNIT *vfree=NULL;	/* next free location in current segment */
static AUNIT *vtop=NULL;	/* top of current segment */

/* external variables */
extern jmp_buf error_trap;	/* the error trap target */
extern VECTOR *code;		/* currently executing code vector */

/* forward declarations */
void mark();
static HDR *allocmemory();
static void gc(),markclass(),markdictionary(),markentry(),markobject();
static void markvector(),compact(),compact_vector();
static DICT_ENTRY *newentry();

/* initialize - initialize the virtual machine */
int initialize(smax,cmax)
  int smax,cmax;
{
    int obj_class(),cls_new();
    char *calloc();
    
    /* setup an error trap handler */
    if (setjmp(error_trap) != 0)
	return (FALSE);

    /* allocate the stack */
    if ((stkbase = (VALUE *)calloc(1,smax * sizeof(VALUE))) == NULL)
	return (FALSE);
    stktop = sp = stkbase + smax;
    code = NULL;

    /* initialize the memory manager */
    vsegments = vscurrent = NULL;
    vfree = vtop = NULL;
    if (!vexpand(VSSIZE))
	return (FALSE);

    /* initialize the compiler */
    if (!init_compiler(cmax))
	return (FALSE);

    /* create the symbol and class tables */
    set_nil(&nil);
    set_dictionary(&symbols,newdictionary(&nil));
    set_dictionary(&classes,newdictionary(&nil));

    /* enter the built-in functions */
    init_functions();
    return (TRUE);
}

/* addentry - add an entry to a dictionary */
DICT_ENTRY *addentry(dict,key,type)
  VALUE *dict; char *key; int type;
{
    DICT_ENTRY *entry;
    if ((entry = findentry(dict,key)) == NULL) {
	check(1);
	push_var(newentry(dict,key,type));
	sp->v.v_var->de_next = *digetcontents(dict);
	dict->v.v_dictionary->di_contents = *sp;
	entry = deaddr(sp++);
    }
    return (entry);
}

/* findentry - find an entry in a dictionary */
DICT_ENTRY *findentry(dict,key)
  VALUE *dict; char *key;
{
    DICT_ENTRY *entry;
    for (entry = digetcontents(dict)->v.v_var;
	 entry != NULL;
	 entry = entry->de_next.v.v_var)
	if (strncmp(key,
		    strgetdata(&entry->de_key),
		    strgetsize(&entry->de_key)) == 0)
	    return (entry);
    return (NULL);
}

/* makestring - make an initialized string from a C-style string */
STRING *makestring(str)
  char *str;
{
    STRING *val;
    int len;
    len = strlen(str);
    val = newstring(len);
    strncpy(val->str_data,str,len);
    return (val);
}

/* getcstring - get a C-style version of a string */
char *getcstring(buf,max,str)
  char *buf; int max; VALUE *str;
{
    int len;
    if ((len = strgetsize(str)) >= max)
	len = max - 1;
    strncpy(buf,strgetdata(str),len);
    buf[len] = '\0';
    return (buf);
}

/* newstring - allocate a new string object */
STRING *newstring(n)
  int n;
{
    STRING *val;
    int size;
    char *p;
    size = sizeof(STRING) + n - 1;
    val = (STRING *)allocmemory(DT_STRING,size);
    val->str_size = n;
    for (p = val->str_data; --n >= 0; )
	*p++ = '\0';
    return (val);
}

/* newobject - allocate a new object */
OBJECT *newobject(class)
  VALUE *class;
{
    OBJECT *val;
    int size,n;
    VALUE *p;
    n = clgetsize(class);
    size = sizeof(OBJECT) + (n - 1) * sizeof(VALUE);
    val = (OBJECT *)allocmemory(DT_OBJECT,size);
    val->obj_class = *class;
    for (p = val->obj_members; --n >= 0; ++p)
	p->v_type = DT_NIL;
    return (val);
}

/* newvector - allocate a new vector */
VECTOR *newvector(n)
  int n;
{
    VECTOR *val;
    VALUE *p;
    int size;
    size = sizeof(VECTOR) + (n - 1) * sizeof(VALUE);
    val = (VECTOR *)allocmemory(DT_VECTOR,size);
    val->vec_size = n;
    for (p = val->vec_data; --n >= 0; ++p)
	p->v_type = DT_NIL;
    return (val);
}

/* newclass - create a new class */
CLASS *newclass(name,base)
  char *name; VALUE *base;
{
    /* allocate the memory for the new class */
    check(1);
    push_class((CLASS *)allocmemory(DT_CLASS,sizeof(CLASS)));
    set_nil(&sp->v.v_class->cl_name);
    set_nil(&sp->v.v_class->cl_members);
    set_nil(&sp->v.v_class->cl_functions);

    /* initialize */
    sp->v.v_class->cl_base = *base;
    set_string(&sp->v.v_class->cl_name,makestring(name));
    set_dictionary(&sp->v.v_class->cl_members,newdictionary(sp));
    set_dictionary(&sp->v.v_class->cl_functions,newdictionary(sp));
    sp->v.v_class->cl_size = 0;

    /* return the new class */
    return (claddr(sp++));
}

/* newdictionary - create a new dictionary */
DICTIONARY *newdictionary(class)
  VALUE *class;
{
    DICTIONARY *dict;
    dict = (DICTIONARY *)allocmemory(DT_DICTIONARY,sizeof(DICTIONARY));
    dict->di_class = *class;
    set_nil(&dict->di_contents);
    return (dict);
}

/* newentry - allocate a new dictionary entry */
static DICT_ENTRY *newentry(dict,key,type)
  VALUE *dict; char *key; int type;
{
    check(1);
    push_var((DICT_ENTRY *)allocmemory(DT_VAR,sizeof(DICT_ENTRY)));
    sp->v.v_var->de_dictionary = *dict;
    sp->v.v_var->de_type = type;
    set_nil(&sp->v.v_var->de_key);
    set_nil(&sp->v.v_var->de_value);
    set_nil(&sp->v.v_var->de_next);
    set_string(&sp->v.v_var->de_key,makestring(key));
    return (deaddr(sp++));
}

/* allocmemory - allocate a block of memory */
static HDR *allocmemory(type,size)
  int type,size;
{
    HDR *val;

    /* make sure there's enough space */
    size = ALLOCSIZE(size);
    if (!VCOMPARE(vfree,size,vtop)
    &&  !checkvmemory(size)
    &&  !findvmemory(size))
	error("Insufficient memory");

    /* allocate the next available block */
    val = (HDR *)vfree;
    vfree += size;
    
    /* return the new block of memory */
    val->hdr_type = type;
    val->hdr_flags = 0;
    val->hdr_chain = NULL;
    return (val);
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
static int checkvmemory(size)
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
static int makevmemory(size)
  int size;
{
    return (vexpand(size < VSSIZE ? VSSIZE : size));
}

/* vexpand - expand vector space */
static int vexpand(size)
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

/* newvsegment - create a new vector segment */
static VSEGMENT *newvsegment(n)
  unsigned int n;
{
    char *calloc();
    VSEGMENT *newseg;

    /* allocate the new segment */
    if ((newseg = (VSEGMENT *)calloc(1,vsegsize(n))) == NULL)
	return (NULL);

    /* initialize the new segment */
    newseg->vs_free = newseg->vs_data;
    newseg->vs_top = newseg->vs_free + n;
    newseg->vs_next = vsegments;
    vsegments = newseg;

    /* return the new segment */
    return (newseg);
}
 
/* gc - garbage collect */
static void gc()
{
    extern unsigned char *cbase,*pc;
    VALUE codeval,*p;
    LITERAL *lit;
    int pcoff;

    /* protect the current bytecode vector */
    if (code) {
	set_bytecode(&codeval,code);
	pcoff = pc - cbase;
	mark(&codeval);
    }

    /* mark all reachable values */
    mark(&symbols);
    mark(&classes);

    /* mark the stack */
    for (p = sp; p < stktop; )
	mark(p++);

    /* mark compiler variables */
    mark_compiler();

    /* compact all active blocks */
    compact();

    /* reload the interpreter's registers */
    if (code) {
	code = codeval.v.v_vector;
	cbase = code->vec_data[0].v.v_string->str_data;
	pc = cbase + pcoff;
    }
}

/* mark - mark all accessible nodes */
void mark(val)
  VALUE *val;
{
    HDR *hdr;
    switch (val->v_type) {
    case DT_CLASS:
    case DT_OBJECT:
    case DT_VECTOR:
    case DT_BYTECODE:
    case DT_STRING:
    case DT_DICTIONARY:
    case DT_VAR:
	hdr = val->v.v_hdr;
	val->v.v_chain = hdr->hdr_chain;
	hdr->hdr_chain = val;
	if ((hdr->hdr_flags & MARK) == 0) {
	    hdr->hdr_flags |= MARK;
	    switch (hdr->hdr_type) {
	    case DT_CLASS:
		markclass((CLASS *)hdr);
		break;
	    case DT_OBJECT:
		markobject((OBJECT *)hdr);
		break;
	    case DT_VECTOR:
		markvector((VECTOR *)hdr);
		break;
	    case DT_DICTIONARY:
		markdictionary((DICTIONARY *)hdr);
		break;
	    case DT_VAR:
		markentry((DICT_ENTRY *)hdr);
		break;
	    }
	}
	break;
    }
}

/* markclass - mark a class */
static void markclass(class)
  CLASS *class;
{
    mark(&class->cl_name);
    mark(&class->cl_base);
    mark(&class->cl_members);
    mark(&class->cl_functions);
}

/* markdictionary - mark a dictionary */
static void markdictionary(dict)
  DICTIONARY *dict;
{
    VALUE *next,*val;
    mark(&dict->di_class);
    for (val = &dict->di_contents;
	 !isnil(val);
	 val = next) {
	next = degetnext(val);
	mark(val);
    }
}

/* markentry - mark a dictionary entry */
static void markentry(entry)
  DICT_ENTRY *entry;
{
    mark(&entry->de_dictionary);
    mark(&entry->de_key);
    mark(&entry->de_value);
}

/* markobject - mark an object */
static void markobject(obj)
  OBJECT *obj;
{
    VALUE *p;
    int n;
    p = obj->obj_members;
    n = clgetsize(&obj->obj_class);
    while (--n >= 0)
	mark(p++);
}

/* markvector - mark a vector */
static void markvector(vect)
  VECTOR *vect;
{
    VALUE *p;
    int n;
    p = vect->vec_data;
    n = vect->vec_size;
    while (--n >= 0)
	mark(p++);
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

/* getblocksize - get the size of a block */
static int getblocksize(hdr)
  HDR *hdr;
{
    switch (hdr->hdr_type) {
    case DT_CLASS:
	return (ALLOCSIZE(sizeof(CLASS)));
    case DT_OBJECT:
	return (ALLOCSIZE(sizeof(OBJECT)
	     +  (clgetsize(&((OBJECT *)hdr)->obj_class) - 1) * sizeof(VALUE)));
    case DT_VECTOR:
	return (ALLOCSIZE(sizeof(VECTOR)
	     +  (((VECTOR *)hdr)->vec_size - 1) * sizeof(VALUE)));
    case DT_STRING:
	return (ALLOCSIZE(sizeof(STRING)
	     +  ((STRING *)hdr)->str_size - 1));
    case DT_DICTIONARY:
	return (ALLOCSIZE(sizeof(DICTIONARY)));
    case DT_VAR:
	return (ALLOCSIZE(sizeof(DICT_ENTRY)));
    }
    error("Bad block type: %d",hdr->hdr_type);
    return (0);
}

/* compact_vector - compact a vector segment */
static void compact_vector(vseg)
  VSEGMENT *vseg;
{
    AUNIT *vdata,*vnext,*vfree;
    VALUE *vp,*nextvp;
    int vsize;
    HDR *hdr;

    /* update pointers */
    vdata = vnext = vseg->vs_data;
    vfree = vseg->vs_free;
    while (vdata < vfree) {
	hdr = (HDR *)vdata;
	vsize = getblocksize(hdr);
	if (hdr->hdr_flags & MARK) {
	    for (vp = hdr->hdr_chain; vp != NULL; vp = nextvp) {
		nextvp = vp->v.v_chain;
		vp->v.v_hdr = (HDR *)vnext;
	    }
	    hdr->hdr_chain = NULL;
	    vnext += vsize;
	}
	vdata += vsize;
    }

    /* compact free space */
    vdata = vnext = vseg->vs_data;
    vfree = vseg->vs_free;
    while (vdata < vfree) {
	hdr = (HDR *)vdata;
	vsize = getblocksize(hdr);
	if (hdr->hdr_flags & MARK) {
	    hdr->hdr_flags &= ~MARK;
	    if (vdata == vnext) {
		vdata += vsize;
		vnext += vsize;
	    }
	    else
		while (--vsize >= 0)
		    *vnext++ = *vdata++;
	}
	else
	    vdata += vsize;
    }
    vseg->vs_free = vnext;
}
