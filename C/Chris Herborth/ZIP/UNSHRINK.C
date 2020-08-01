#include "unzip.h"

#ifdef NEW_UNSHRINK

/*---------------------------------------------------------------------------

  unshrink.c                     version 0.94                     26 Apr 94

  Shrinking is basically a dynamic LZW algorithm with allowed code sizes of
  up to 13 bits; in addition, there is provision for partial clearing of
  leaf nodes.  PKWARE uses the special code 256 (decimal) to indicate a
  change in code size or a partial clear of the code tree:  256,1 for the
  former and 256,2 for the latter.  See the notes in the code below about
  orphaned nodes after partial clearing.

  This replacement version of unshrink.c was written from scratch.  It is
  based only on the algorithms described in Mark Nelson's _The Data Compres-
  sion Book_ and in Terry Welch's original paper in the June 1984 issue of
  IEEE _Computer_; no existing source code, including any in Nelson's book,
  was used.

  Memory requirements are fairly large.  While the NODE struct could be mod-
  ified to fit in a single 64KB segment (as a "far" data structure), for now
  it is assumed that a flat, 32-bit address space is available.  outbuf2 is
  always malloc'd, and flush() is always called with unshrink == FALSE.

  Copyright (C) 1994 Greg Roelofs.  See the accompanying file "COPYING" in
  the UnZip 5.11 (or later) source distribution.

  ---------------------------------------------------------------------------*/


/* #include "unzip.h" */

#ifdef DEBUG
#  define OUTDBG(c)  if ((c)=='\n') {putc('^',stderr); putc('J',stderr);}\
                     else putc((c),stderr);
#else
#  define OUTDBG(c)
#endif

typedef struct leaf {
    struct leaf *parent;
    struct leaf *next_sibling;
    struct leaf *first_child;
    uch value;
} NODE;

static void  partial_clear  __((NODE *cursib));

static NODE *node, *bogusnode, *lastfreenode;


int unshrink()
{
#ifdef MACOS
    static uch *stacktop = NULL;
#else
    static uch *stacktop = stack + 8192 - 1;
#endif
    register uch *newstr;
    int codesize=9, code, oldcode=0, len, KwKwK;
    unsigned int outbufsiz;
    NODE *freenode, *curnode, *lastnode=node, *oldnode;


/*---------------------------------------------------------------------------
    Initialize various variables.
  ---------------------------------------------------------------------------*/

#ifdef MACOS
    if (stacktop == NULL) stacktop = stack + 8192 - 1;
#endif

    if ((node = (NODE *)malloc(8192*sizeof(NODE))) == (NODE *)NULL)
        return PK_MEM3;
    bogusnode = node + 256;
    lastfreenode = node + 256;

#ifndef SMALL_MEM   /* always true, at least for now */
    /* non-memory-limited machines:  allocate second (large) buffer for
     * textmode conversion in flush(), but only if needed */
    if (pInfo->textmode && !outbuf2 &&
        (outbuf2 = (uch *)malloc(TRANSBUFSIZ)) == (uch *)NULL)
    {
        free(node);
        return PK_MEM3;
    }
#endif

    /* this stuff was an attempt to debug compiler errors(?) when had
     * node[8192] in union work area...no clues what was wrong (SGI worked)
    Trace((stderr, "\nsizeof(NODE) = %d\n", sizeof(NODE)));
    Trace((stderr, "sizeof(node) = %d\n", sizeof(node)));
    Trace((stderr, "sizeof(area) = %d\n", sizeof(area)));
    Trace((stderr, "address of node[0] = %d\n", (int)&node[0]));
    Trace((stderr, "address of node[6945] = %d\n", (int)&node[6945]));
     */

    for (code = 0;  code < 256;  ++code) {
        node[code].value = code;
        node[code].parent = bogusnode;
        node[code].next_sibling = &node[code+1];
        node[code].first_child = (NODE *)NULL;
    }
    node[255].next_sibling = (NODE *)NULL;
    for (code = 257;  code < 8192;  ++code)
        node[code].parent = node[code].next_sibling = (NODE *)NULL;

    outptr = outbuf;
    outcnt = 0L;
    if (pInfo->textmode)
        outbufsiz = RAWBUFSIZ;
    else
        outbufsiz = OUTBUFSIZ;

/*---------------------------------------------------------------------------
    Get and output first code, then loop over remaining ones.
  ---------------------------------------------------------------------------*/

    READBITS(codesize, oldcode)
    if (!zipeof) {
        *outptr++ = (uch)oldcode;
        OUTDBG((uch)oldcode)
        if (++outcnt == outbufsiz) {
            flush(outbuf, outcnt, FALSE);
            outptr = outbuf;
            outcnt = 0L;
        }
    }

    do {
        READBITS(codesize, code)
        if (zipeof)
            break;
        if (code == 256) {   /* GRR:  possible to have consecutive escapes? */
            READBITS(codesize, code)
            if (code == 1) {
                ++codesize;
                Trace((stderr, " (codesize now %d bits)\n", codesize));
            } else if (code == 2) {
                Trace((stderr, " (partial clear code)\n"));
#ifdef DEBUG
                fprintf(stderr, "   should clear:\n");
                for (curnode = node+257;  curnode < node+8192;  ++curnode)
                    if (!curnode->first_child)
                        fprintf(stderr, "%d\n", curnode-node);
                fprintf(stderr, "   did clear:\n");
#endif
                partial_clear(node);       /* recursive clear of leafs */
                lastfreenode = bogusnode;  /* reset start of free-node search */
            }
            continue;
        }

    /*-----------------------------------------------------------------------
        Translate code:  traverse tree from leaf back to root.
      -----------------------------------------------------------------------*/

        curnode = &node[code];
        newstr = stacktop;

        if (curnode->parent)
            KwKwK = FALSE;
        else {
            KwKwK = TRUE;
            Trace((stderr, " (found a KwKwK code %d; oldcode = %d)\n", code,
              oldcode));
            --newstr;   /* last character will be same as first character */
            curnode = &node[oldcode];
        }

        do {
            *newstr-- = curnode->value;
            curnode = curnode->parent;
        } while (curnode != bogusnode);

        len = stacktop - newstr++;
        if (KwKwK)
            *stacktop = *newstr;

    /*-----------------------------------------------------------------------
        Write expanded string in reverse order to output buffer.
      -----------------------------------------------------------------------*/

        Trace((stderr, "code %4d; oldcode %4d; char %3d (%c); string [", code,
          oldcode, (int)(*newstr), *newstr));
        {
            register uch *p;

            for (p = newstr;  p < newstr+len;  ++p) {
                *outptr++ = *p;
                OUTDBG(*p)
                if (++outcnt == outbufsiz) {
                    flush(outbuf, outcnt, FALSE);
                    outptr = outbuf;
                    outcnt = 0L;
                }
            }
        }

    /*-----------------------------------------------------------------------
        Add new leaf (first character of newstr) to tree as child of oldcode.
      -----------------------------------------------------------------------*/

        /* search for freenode */
        freenode = lastfreenode + 1;
        while (freenode->parent)       /* add if-test before loop for speed? */
            ++freenode;
        lastfreenode = freenode;
        Trace((stderr, "]; newcode %d\n", freenode-node));

        oldnode = &node[oldcode];
        if (!oldnode->first_child) {   /* no children yet:  add first one */
            if (!oldnode->parent) {
                /*
                 * oldnode is itself a free node:  the only way this can happen
                 * is if a partial clear occurred immediately after oldcode was
                 * received and therefore immediately before this step (adding
                 * freenode).  This is subtle:  even though the parent no longer
                 * exists, it is treated as if it does, and pointers are set as
                 * usual.  Thus freenode is an orphan, *but only until the tree
                 * fills up to the point where oldnode is reused*.  At that
                 * point the reborn oldnode "adopts" the orphaned node.  Such
                 * wacky guys at PKWARE...
                 *
                 * To mark this, we set oldnode->next_sibling to point at the
                 * bogus node (256) and then check for this in the freenode sec-
                 * tion just below.
                 */
                Trace((stderr, "  [%d's parent (%d) was just cleared]\n",
                  freenode-node, oldcode));
                oldnode->next_sibling = bogusnode;
            }
            oldnode->first_child = freenode;
        } else {
            curnode = oldnode->first_child;
            while (curnode) {          /* find last child in sibling chain */
                lastnode = curnode;
                curnode = curnode->next_sibling;
            }
            lastnode->next_sibling = freenode;
        }
        freenode->value = *newstr;
        freenode->parent = oldnode;
        if (freenode->next_sibling != bogusnode)  /* no adoptions today... */
            freenode->first_child = (NODE *)NULL;
        freenode->next_sibling = (NODE *)NULL;

        oldcode = code;
    } while (!zipeof);

/*---------------------------------------------------------------------------
    Flush any remaining data, free malloc'd space and return to sender...
  ---------------------------------------------------------------------------*/

    if (outcnt > 0L)
        flush(outbuf, outcnt, FALSE);

    free(node);
    return PK_OK;

} /* end function unshrink() */





static void partial_clear(cursib)   /* like, totally recursive, eh? */
    NODE *cursib;
{
    NODE *lastsib=(NODE *)NULL;

    /* Loop over siblings, removing any without children; recurse on those
     * which do have children.  This hits even the orphans because they're
     * always adopted (parent node is reused) before tree becomes full and
     * needs clearing.
     */
    do {
        if (cursib->first_child) {
            partial_clear(cursib->first_child);
            lastsib = cursib;
        } else if ((cursib - node) > 256) {  /* no children (leaf):  clear it */
            Trace((stderr, "%d\n", cursib-node));
            if (!lastsib)
                cursib->parent->first_child = cursib->next_sibling;
            else
                lastsib->next_sibling = cursib->next_sibling;
            cursib->parent = (NODE *)NULL;
        }
        cursib = cursib->next_sibling;
    } while (cursib);
    return;
}



#else /* !NEW_UNSHRINK */



/*---------------------------------------------------------------------------

  unshrink.c

  Shrinking is a dynamic Lempel-Ziv-Welch compression algorithm with partial
  clearing.  Sadly, it uses more memory than any of the other algorithms (at
  a minimum, 8K+8K+16K, assuming 16-bit short ints), and this does not even
  include the output buffer (the other algorithms leave the uncompressed data
  in the work area, typically called slide[]).  For machines with a 64KB data
  space, this is a problem, particularly when text conversion is required and
  line endings have more than one character.  UnZip's solution is to use two
  roughly equal halves of outbuf for the ASCII conversion in such a case; the
  "unshrink" argument to flush() signals that this is the case.

  For large-memory machines, a second outbuf is allocated for translations,
  but only if unshrinking and only if translations are required.

              | binary mode  |        text mode
    ---------------------------------------------------
    big mem   |  big outbuf  | big outbuf + big outbuf2  <- malloc'd here
    small mem | small outbuf | half + half small outbuf

  This version contains code which is copyright (C) 1989 Samuel H. Smith.
  See the accompanying file "COPYING" in the UnZip 5.11 (or later) source
  distribution.

  ---------------------------------------------------------------------------*/


/* #include "unzip.h" */

/*      MAX_BITS   13   (in unzip.h; defines size of global work area)  */
#define INIT_BITS  9
#define FIRST_ENT  257
#define CLEAR      256

#define OUTB(c) {\
    *outptr++=(uch)(c);\
    if (++outcnt==outbufsiz) {\
        flush(outbuf,outcnt,TRUE);\
        outcnt=0L;\
        outptr=outbuf;\
    }\
}

static void partial_clear __((void));

int codesize, maxcode, maxcodemax, free_ent;




/*************************/
/*  Function unshrink()  */
/*************************/

int unshrink()   /* return PK-type error code */
{
    register int code;
    register int stackp;
    int finchar;
    int oldcode;
    int incode;
    unsigned int outbufsiz;


    /* non-memory-limited machines:  allocate second (large) buffer for
     * textmode conversion in flush(), but only if needed */
#ifndef SMALL_MEM
    if (pInfo->textmode && !outbuf2 &&
        (outbuf2 = (uch *)malloc(TRANSBUFSIZ)) == (uch *)NULL)
        return PK_MEM3;
#endif

    outptr = outbuf;
    outcnt = 0L;
    if (pInfo->textmode)
        outbufsiz = RAWBUFSIZ;
    else
        outbufsiz = OUTBUFSIZ;

    /* decompress the file */
    codesize = INIT_BITS;
    maxcode = (1 << codesize) - 1;
    maxcodemax = HSIZE;         /* (1 << MAX_BITS) */
    free_ent = FIRST_ENT;

    code = maxcodemax;
/*
    OvdL: -Ox with SCO's 3.2.0 cc gives
    a. warning: overflow in constant multiplication
    b. segmentation fault (core dumped) when using the executable
    for (code = maxcodemax; code > 255; code--)
        prefix_of[code] = -1;
 */
    do {
        prefix_of[code] = -1;
    } while (--code > 255);

    for (code = 255; code >= 0; code--) {
        prefix_of[code] = 0;
        suffix_of[code] = (uch)code;
    }

    READBITS(codesize,oldcode)  /* ; */
    if (zipeof)
        return PK_COOL;
    finchar = oldcode;

    OUTB(finchar)

    stackp = HSIZE;

    while (!zipeof) {
        READBITS(codesize,code)  /* ; */
        if (zipeof) {
            if (outcnt > 0L)
                flush(outbuf, outcnt, TRUE);   /* flush last, partial buffer */
            return PK_COOL;
        }

        while (code == CLEAR) {
            READBITS(codesize,code)  /* ; */
            switch (code) {
                case 1:
                    codesize++;
                    if (codesize == MAX_BITS)
                        maxcode = maxcodemax;
                    else
                        maxcode = (1 << codesize) - 1;
                    break;

                case 2:
                    partial_clear();
                    break;
            }

            READBITS(codesize,code)  /* ; */
            if (zipeof) {
                if (outcnt > 0L)
                    flush(outbuf, outcnt, TRUE);   /* partial buffer */
                return PK_COOL;
            }
        }


        /* special case for KwKwK string */
        incode = code;
        if (prefix_of[code] == -1) {
            stack[--stackp] = (uch)finchar;
            code = oldcode;
        }
        /* generate output characters in reverse order */
        while (code >= FIRST_ENT) {
            if (prefix_of[code] == -1) {
                stack[--stackp] = (uch)finchar;
                code = oldcode;
            } else {
                stack[--stackp] = suffix_of[code];
                code = prefix_of[code];
            }
        }

        finchar = suffix_of[code];
        stack[--stackp] = (uch)finchar;


        /* and put them out in forward order, block copy */
        if ((HSIZE - stackp + outcnt) < outbufsiz) {
            /* GRR:  this is not necessarily particularly efficient:
             *       typically output only 2-5 bytes per loop (more
             *       than a dozen rather rare?) */
            memcpy(outptr, &stack[stackp], HSIZE - stackp);
            outptr += HSIZE - stackp;
            outcnt += HSIZE - stackp;
            stackp = HSIZE;
        }
        /* output byte by byte if we can't go by blocks */
        else
            while (stackp < HSIZE)
                OUTB(stack[stackp++])


        /* generate new entry */
        code = free_ent;
        if (code < maxcodemax) {
            prefix_of[code] = oldcode;
            suffix_of[code] = (uch)finchar;

            do
                code++;
            while ((code < maxcodemax) && (prefix_of[code] != -1));

            free_ent = code;
        }
        /* remember previous code */
        oldcode = incode;
    }

    /* never reached? */
    /* flush last, partial buffer */
    if (outcnt > 0L)
        flush(outbuf, outcnt, TRUE);

    return PK_OK;

} /* end function unshrink() */



/******************************/
/*  Function partial_clear()  */
/******************************/

static void partial_clear()
{
    register int pr;
    register int cd;

    /* mark all nodes as potentially unused */
    for (cd = FIRST_ENT; cd < free_ent; cd++)
        prefix_of[cd] |= 0x8000;

    /* unmark those that are used by other nodes */
    for (cd = FIRST_ENT; cd < free_ent; cd++) {
        pr = prefix_of[cd] & 0x7fff;    /* reference to another node? */
        if (pr >= FIRST_ENT)    /* flag node as referenced */
            prefix_of[pr] &= 0x7fff;
    }

    /* clear the ones that are still marked */
    for (cd = FIRST_ENT; cd < free_ent; cd++)
        if ((prefix_of[cd] & 0x8000) != 0)
            prefix_of[cd] = -1;

    /* find first cleared node as next free_ent */
    cd = FIRST_ENT;
    while ((cd < maxcodemax) && (prefix_of[cd] != -1))
        cd++;
    free_ent = cd;
}


#endif /* ?NEW_UNSHRINK */
