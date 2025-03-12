/*  ARC - Archive utility - ARCSQ

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains the routines used to squeeze a file
         when placing it in an archive.

    Language:
         Computer Innovations Optimizing C86

    Programming notes:
         Most of the routines used for the Huffman squeezing algorithm
         were lifted from the SQ program by Dick Greenlaw, as adapted
         to CI-C86 by Robert J. Beilstein.
*/
#include <stdio.h>

#define int16size 16			/* 16 bits */

/* stuff for Huffman squeezing */

#define TRUE 1
#define FALSE 0
#define ERROR (-1)
#define SPEOF 256                      /* special endfile token */
#define NOCHILD -1                     /* marks end of path through tree */
#define NUMVALS 257                    /* 256 data values plus SPEOF*/
#define NUMNODES (NUMVALS+NUMVALS-1)   /* number of nodes */
#define MAXCOUNT (unsigned) 65535      /* biggest unsigned integer */

/* The following array of structures are the nodes of the
   binary trees. The first NUMVALS nodes become the leaves of the
   final tree and represent the values of the data bytes being
   encoded and the special endfile, SPEOF.
   The remaining nodes become the internal nodes of the final tree.
*/

struct nd                              /* shared by unsqueezer */
{   unsigned weight;                   /* number of appearances */
    int tdepth;                        /* length on longest path in tree */
    int lchild, rchild;                /* indices to next level */
}   node[NUMNODES];                    /* use large buffer */

static int dctreehd;                   /* index to head of final tree */

/* This is the encoding table:
   The bit strings have first bit in low bit.
   Note that counts were scaled so code fits unsigned integer.
*/

static int codelen[NUMVALS];           /* number of bits in code */
static unsigned code[NUMVALS];         /* code itself, right adjusted */
static unsigned tcode;                 /* temporary code value */
static long valcount[NUMVALS];         /* actual count of times seen */

/* Variables used by encoding process */

static int curin;                      /* value currently being encoded */
static int cbitsrem;                   /* # of code string bits left */
static unsigned ccode;                 /* current code right justified */

init_sq()                              /* prepare for scanning pass */
{
    int i;                             /* node index */

    /* Initialize all nodes to single element binary trees
       with zero weight and depth.
    */

    for(i=0; i<NUMNODES; ++i)
    {    node[i].weight = 0;
         node[i].tdepth = 0;
         node[i].lchild = NOCHILD;
         node[i].rchild = NOCHILD;
    }

    for(i=0; i<NUMVALS; i++)
         valcount[i] = 0;
}

scan_sq(c)                             /* add a byte to the tables */
int c;                                 /* byte to add */
{
    unsigned *wp;                      /* speeds up weight counting */

    /* Build frequency info in tree */

    if(c == EOF)                       /* it's traditional */
         c = SPEOF;                    /* dumb, but traditional */

    if(*(wp = &node[c].weight) !=  MAXCOUNT)
         ++(*wp);                      /* bump weight counter */

    valcount[c]++;                     /* bump byte counter */
}

long pred_sq()                         /* predict size of squeezed file */
{
    int i;
    int btlist[NUMVALS];               /* list of intermediate b-trees */
    int listlen;                       /* length of btlist */
    unsigned ceiling;                  /* limit for scaling */
    long size = 0;                     /* predicted size */
    int numnodes;                      /* # of nodes in simplified tree */

    scan_sq(EOF);                      /* signal end of input */

    ceiling = MAXCOUNT;

    /* Keep trying to scale and encode */

    do
    {    scale(ceiling);
         ceiling /= 2;                 /* in case we rescale */

         /* Build list of single node binary trees having
            leaves for the input values with non-zero counts
         */

         for(i=listlen=0; i<NUMVALS; ++i)
         {    if(node[i].weight != 0)
              {    node[i].tdepth = 0;
                   btlist[listlen++] = i;
              }
         }

         /* Arrange list of trees into a heap with the entry
            indexing the node with the least weight at the top.
         */

         heap(btlist,listlen);

         /* Convert the list of trees to a single decoding tree */

         bld_tree(btlist,listlen);

         /* Initialize the encoding table */

         init_enc();

         /* Try to build encoding table.
            Fail if any code is > 16 bits long.
         */
    }    while(buildenc(0,dctreehd) == ERROR);

    /* Initialize encoding variables */

    cbitsrem = 0;                      /* force initial read */
    curin = 0;                         /* anything but endfile */

    for(i=0; i<NUMVALS; i++)           /* add bits for each code */
         size += valcount[i] * codelen[i];

    size = (size+7)/8;                 /* reduce to number of bytes */

    numnodes = dctreehd<NUMVALS ? 0 : dctreehd-(NUMVALS-1);

    size += int16size + 2*numnodes*int16size;

    return size;
}

/* The count of number of occurrances of each input value
   have already been prevented from exceeding MAXCOUNT.
   Now we must scale them so that their sum doesn't exceed
   ceiling and yet no non-zero count can become zero.
   This scaling prevents errors in the weights of the
   interior nodes of the Huffman tree and also ensures that
   the codes will fit in an unsigned integer. Rescaling is
   used if necessary to limit the code length.
*/

static scale(ceil)
unsigned ceil;                         /* upper limit on total weight */
{
    register int i,c;
    int ovflw, divisor;
    unsigned w, sum;
    unsigned char increased;           /* flag */

    do
    {    for(i=sum=ovflw=0; i<NUMVALS; ++i)
         {    if(node[i].weight > (ceil-sum))
                   ++ovflw;
              sum += node[i].weight;
         }

         divisor = ovflw + 1;

         /* Ensure no non-zero values are lost */

         increased = FALSE;
         for(i=0; i<NUMVALS; ++i)
         {    w = node[i].weight;
              if(w<divisor && w!=0)
              {    /* Don't fail to provide a code if it's used at all */

                   node[i].weight = divisor;
                   increased = TRUE;
              }
         }
    }    while(increased);

    /* Scaling factor choosen, now scale */

    if(divisor>1)
         for(i=0; i<NUMVALS; ++i)
              node[i].weight /= divisor;
}

/* heap() and adjust() maintain a list of binary trees as a
   heap with the top indexing the binary tree on the list
   which has the least weight or, in case of equal weights,   least depth in its longest path. The depth part is not
   strictly necessary, but tends to avoid long codes which
   might provoke rescaling.
*/

static heap(list,length)
int list[], length;
{
    register int i;

    for(i=(length-2)/2; i>=0; --i)
         adjust(list,i,length-1);
}

/* Make a heap from a heap with a new top */

static adjust(list,top,bottom)
int list[], top, bottom;
{
    register int k, temp;

    k = 2 * top + 1;                   /* left child of top */
    temp = list[top];                  /* remember root node of top tree */

    if(k<=bottom)
    {    if(k<bottom && cmptrees(list[k],list[k+1]))
              ++k;

         /* k indexes "smaller" child (in heap of trees) of top */
         /* now make top index "smaller" of old top and smallest child */

         if(cmptrees(temp,list[k]))
         {    list[top] = list[k];
              list[k] = temp;

              /* Make the changed list a heap */

              adjust(list,k,bottom);   /* recursive */
         }
    }
}

/* Compare two trees, if a > b return true, else return false.
   Note comparison rules in previous comments.
*/

static cmptrees(a,b)
int a, b;                              /* root nodes of trees */
{
    if(node[a].weight > node[b].weight)
         return TRUE;
    if(node[a].weight == node[b].weight)
         if(node[a].tdepth > node[b].tdepth)
              return TRUE;
    return FALSE;
}

/* HUFFMAN ALGORITHM: develops the single element trees
   into a single binary tree by forming subtrees rooted in
   interior nodes having weights equal to the sum of weights of all
   their descendents and having depth counts indicating the
   depth of their longest paths.

   When all trees have been formed into a single tree satisfying
   the heap property (on weight, with depth as a tie breaker)
   then the binary code assigned to a leaf (value to be encoded)
   is then the series of left (0) and right (1)
   paths leading from the root to the leaf.
   Note that trees are removed from the heaped list by
   moving the last element over the top element and
   reheaping the shorter list.
*/

static bld_tree(list,len)
int list[];
int len;
{
    register int freenode;             /* next free node in tree */
    register struct nd *frnp;          /* free node pointer */
    int lch, rch;                      /* temps for left, right children */
    int i;

    /* Initialize index to next available (non-leaf) node.
       Lower numbered nodes correspond to leaves (data values).
    */

    freenode = NUMVALS;

    while(len>1)
    {    /* Take from list two btrees with least weight
            and build an interior node pointing to them.
            This forms a new tree.
         */

         lch = list[0];                /* This one will be left child */

         /* delete top (least) tree from the list of trees */

         list[0] = list[--len];
         adjust(list,0,len-1);

         /* Take new top (least) tree. Reuse list slot later */

         rch = list[0];                /* This one will be right child */

         /* Form new tree from the two least trees using
            a free node as root. Put the new tree in the list.
         */

         frnp = &node[freenode];       /* address of next free node */
         list[0] = freenode++;         /* put at top for now */
         frnp->lchild = lch;
         frnp->rchild = rch;
         frnp->weight = node[lch].weight + node[rch].weight;
         frnp->tdepth = 1 + maxchar(node[lch].tdepth, node[rch].tdepth);

         /* reheap list  to get least tree at top */

         adjust(list,0,len-1);
    }
    dctreehd = list[0];                /* head of final tree */
}

static maxchar(a,b)
{
    return a>b ? a : b;
}

static init_enc()
{
    register int i;

    /* Initialize encoding table */

    for(i=0; i<NUMVALS; ++i)
         codelen[i] = 0;
}

/* Recursive routine to walk the indicated subtree and level
   and maintain the current path code in bstree. When a leaf
   is found the entire code string and length are put into
   the encoding table entry for the leaf's data value .

   Returns ERROR if codes are too long.
*/

static int buildenc(level,root)
int level;              /* level of tree being examined, from zero */
int root;               /* root of subtree is also data value if leaf */
{
    register int l, r;

    l = node[root].lchild;
    r = node[root].rchild;

    if(l==NOCHILD && r==NOCHILD)
    {    /* Leaf. Previous path determines bit string
            code of length level (bits 0 to level - 1).
            Ensures unused code bits are zero.
         */

         codelen[root] = level;
         code[root] = tcode & (((unsigned)~0) >> (16-level));
         return (level>16) ? ERROR : NULL;
    }

    else
    {    if(l!=NOCHILD)
         {    /* Clear path bit and continue deeper */

              tcode &= ~(1 << level);
              if(buildenc(level+1,l)==ERROR)
                   return ERROR;       /* pass back bad statuses */
         }
         if(r!=NOCHILD)
         {    /* Set path bit and continue deeper */

              tcode |= 1 << level;
              if(buildenc(level+1,r)==ERROR)
                   return ERROR;       /* pass back bad statuses */
         }
    }
    return NULL;                       /* it worked if we reach here */
}

static put_int(n,f)                    /* output an integer */
int n;                                 /* integer to output */
FILE *f;                               /* file to put it to */
{
    putc_pak(n&0xff,f);                /* first the low byte */
    putc_pak(n>>8,f);                  /* then the high byte */
}

/* Write out the header of the compressed file */

static long wrt_head(ob)
FILE *ob;
{
    register int l,r;
    int i, k;
    int numnodes;                      /* # of nodes in simplified tree */

    /* Write out a simplified decoding tree. Only the interior
       nodes are written. When a child is a leaf index
       (representing a data value) it is recoded as
       -(index + 1) to distinguish it from interior indexes
       which are recoded as positive indexes in the new tree.

       Note that this tree will be empty for an empty file.
    */

    numnodes = dctreehd<NUMVALS ? 0 : dctreehd-(NUMVALS-1);
    put_int(numnodes,ob);

    for(k=0, i=dctreehd; k<numnodes; ++k, --i)
    {    l = node[i].lchild;
         r = node[i].rchild;
         l = l<NUMVALS ? -(l+1) : dctreehd-l;
         r = r<NUMVALS ? -(r+1) : dctreehd-r;
         put_int(l,ob);
         put_int(r,ob);
    }

    return int16size + numnodes*2*int16size;
}

/* Get an encoded byte or EOF. Reads from specified stream AS NEEDED.

   There are two unsynchronized bit-byte relationships here.
   The input stream bytes are converted to bit strings of
   various lengths via the static variables named c...
   These bit strings are concatenated without padding to
   become the stream of encoded result bytes, which this
   function returns one at a time. The EOF (end of file) is
   converted to SPEOF for convenience and encoded like any
   other input value. True EOF is returned after that.
*/

static int gethuff(ib)                 /* Returns bytes except for EOF */
FILE *ib;
{
    int rbyte;                         /* Result byte value */
    int need, take;                    /* numbers of bits */

    rbyte = 0;
    need = 8;                          /* build one byte per call */

    /* Loop to build a byte of encoded data.
       Initialization forces read the first time.
    */

loop:
    if(cbitsrem>=need)                 /* if current code is big enough */
    {    if(need==0)
              return rbyte;

         rbyte |= ccode << (8-need);   /* take what we need */
         ccode >>= need;               /* and leave the rest */
         cbitsrem -= need;
         return rbyte & 0xff;
    }

    /* We need more than current code */

    if(cbitsrem>0)
    {    rbyte |= ccode << (8-need);   /* take what there is */
         need -= cbitsrem;
    }

    /* No more bits in current code string */

    if(curin==SPEOF)
    {    /* The end of file token has been encoded. If
            result byte has data return it and do EOF next time.
         */

         cbitsrem = 0;
         return (need==8) ? EOF : rbyte + 0;
    }

    /* Get an input byte */

    if((curin=getc_ncr(ib)) == EOF)
         curin = SPEOF;                /* convenient for encoding */

    ccode = code[curin];               /* get the new byte's code */
    cbitsrem = codelen[curin];

    goto loop;
}

/*  This routine is used to perform the actual squeeze operation.  It can
    only be called after the file has been scanned.  It returns the true
    length of the squeezed entry.
*/

long file_sq(f,t)                      /* squeeze a file into an archive */
FILE *f;                               /* file to squeeze */
FILE *t;                               /* archive to receive file */
{
    int c;                             /* one byte of squeezed data */
    long size;                         /* size after squeezing */

    size = wrt_head(t);                /* write out the decode tree */

    while((c=gethuff(f))!=EOF)
    {    putc_pak(c,t);
         size++;
    }

    return size;                       /* report true size */
}
}