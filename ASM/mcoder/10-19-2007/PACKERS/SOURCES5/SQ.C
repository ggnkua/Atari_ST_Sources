/* This program compresses a file without loosing information.
 * The "usq" program is required to unsqueeze the file
 * before it can be used.
 *
 * Typical compression rates are between 30 and 50 percent for text files.
 *
 * Squeezing a really big file takes a few minutes.
 *
 * Useage:
 *      sq [file1] [file2] ... [filen]
 *
 * where file1 through filen are the names of the files to be squeezed.
 * The file type (under CP/M or MS-DOS) is changed to ".SQ"; under UN*X,
 * ".SQ" is appended to the file name. The original file name is stored
 * in the squeezed file.
 *
 * If no file name is given on the command line you will be
 * prompted for commands (one at a time). An empty command
 * terminates the program.
 *
 * The transformations compress strings of identical bytes and
 * then encode each resulting byte value and EOF as bit strings
 * having lengths in inverse proportion to their frequency of
 * occurrance in the intermediate input stream. The latter uses
 * the Huffman algorithm. Decoding information is included in
 * the squeezed file, so squeezing short files or files with
 * uniformly distributed byte values will actually increase size.
 */

/* CHANGE HISTORY:
 * 1.3  Close files properly in case of error exit.
 * 1.4  Break up long introductory lines.
 * 1.4  Send introduction only to console.
 * 1.4  Send errors only to console.
 * 1.5  Fix BUG that caused a rare few squeezed files
 *      to be incorrect and fail the USQ crc check.
 *      The problem was that some 17 bit codes were
 *      generated but are not supported by other code.
 *      THIS IS A MAJOR CHANGE affecting TR2.C and SQ.H and
 *      requires recompilation of all files which are part
 *      of SQ. Two basic changes were made: tree depth is now
 *      used as a tie breaker when weights are equal. This
 *      makes the tree shallower. Although that may always be
 *      sufficient, an error trap was added to cause rescaling
 *      of the counts if any code > 16 bits long is generated.
 * 1.5  Add debugging displays option '-'.
 * 1.6  Fixed to work correctly under MP/M II.  Also shortened
 *      signon message.
 * 2.0  New version for use with CI-C86 compiler (CP/M-86 and MS-DOS)
 * 2.1  Converted for use in MLINK
 * 2.2  Converted for use with optimizing CI-C86 compiler (MS-DOS)
 * 3.0  Generalized for UN*X use, changed output file naming convention
 *
 * 3.2  Ported to Amiga & Lattice C.  Combined all files
 *      Rick Schaeffer [70120,174] 12/03/85
 * 3.25 Lattice compilation warnings corrected : John Hodgson 1/14/86
 */

#include <stdio.h>

/* eject
eject */

/*
 * The following define MUST be set to the maximum length of a file name
 * on the system "sq" is being compiled for.  If not, "sq" will not be
 * able to check for whether the output file name it creates is valid
 * or not.
 */

#define FNM_LEN 35
#define UNIX                            /* comment out for CP/M, MS-DOS versions */

#define VERSION "3.2   12/03/85"

/* Definitions and external declarations */

#define RECOGNIZE 0xFF76        /* unlikely pattern */

/* *** Stuff for first translation module *** */

#define DLE 0x90

unsigned int crc;        /* error check code */

/* *** Stuff for second translation module *** */

#define SPEOF 256       /* special endfile token */
#define NUMVALS 257     /* 256 data values plus SPEOF*/
/* Definitions and external declarations */

 char     debug;  /* Boolean flag */

/* *** Stuff for first translation module *** */

 int likect;      /*count of consecutive identical chars */
 int lastchar, newchar;
 char state;

/* states */

#define NOHIST  0       /*don't consider previous input*/
#define SENTCHAR 1      /*lastchar set, no lookahead yet */
#define SENDNEWC 2      /*newchar set, previous sequence done */
#define SENDCNT 3       /*newchar set, DLE sent, send count next */

/* *** Stuff for second translation module *** */

#define NOCHILD -1      /* indicates end of path through tree */
#define NUMNODES (NUMVALS + NUMVALS - 1)        /* nbr of nodes */

#define MAXCOUNT 0xFFFF /* biggest unsigned integer */

/* The following array of structures are the nodes of the
 * binary trees. The first NUMVALS nodes becomethe leaves of the
 * final tree and represent the values of the data bytes being
 * encoded and the special endfile, SPEOF.
 * The remaining nodes become the internal nodes of the final tree.
 */

 struct   nd {
        unsigned int weight;    /* number of appearances */
        char tdepth;            /* length on longest path in tre*/
        int lchild, rchild;     /* indexes to next level */
} node[NUMNODES];

 int dctreehd;    /*index to head node of final tree */

/* This is the encoding table:
 * The bit strings have first bit in  low bit.
 * Note that counts were scaled so code fits unsigned integer
 */

 char codelen[NUMVALS];           /* number of bits in code */
 unsigned int code[NUMVALS];      /* code itself, right adjusted */
 unsigned int tcode;              /* temporary code value */


/* Variables used by encoding process */

 int curin;               /* Value currently being encoded */
 char cbitsrem;           /* Number of code string bits remaining */
 unsigned int ccode;      /* Current code shifted so next code bit is at right */
#define ERROR -1
#define TRUE 1
#define FALSE 0

main(argc, argv)
int argc;
char *argv[];
{
        int i,c;
        char inparg[128];       /* parameter from input */

        debug = FALSE;
        printf("File squeezer version %s (original author: R. Greenlaw)\n\n", VERSION);

        /* Process the parameters in order */
        for(i = 1; i < argc; ++i)
                obey(argv[i]);

        if(argc < 2) {
                printf("Enter file names, one line at a time, or type <RETURN> to quit.");
                do {
                        printf("\n*");
                        for(i = 0; i < 16; ++i) {
                                if((c = getchar()) == EOF)
                                        c = '\n';       /* fake empty (exit) command */
                                if((inparg[i] = c) == '\n') {
                                        inparg[i] = '\0';
                                        break;
                                }
                        }
                        if(inparg[0] != '\0')
                                obey(inparg);
                } while(inparg[0] != '\0');
        }
}

/* eject
eject */

obey(p)
char *p;
{
        char *q;
        char *rindex();
        char outfile[128];      /* output file spec. */

        if(*p == '-') {
                /* toggle debug option */
                debug = !debug;
                return 0;
        }

        /* Check for ambiguous (wild-card) name */
        for(q = p; *q != '\0'; ++q)
                if(*q == '*' || *q == '?') {
                        printf("\nAmbiguous name %s ignored\n", p);
                        return 0;
        }
        /* First build output file name */
        strcpy(outfile, p);             /* copy input name to output */

        /* Find and change output file suffix */

        if ((q = rindex(outfile, '.')) == NULL) /* if no '.' in name */
                strcat(outfile, ".qq");
        else {
                strcat(q, "    ");              /* extend end of string marks */
                if (*++q == ' ')                /* if no next character */
                        *q = 'q';
                *++q = 'q';                     /* make file .?q? */
                if (*++q == ' ')                /* if no next character */
                        *q = '\0';              /*   terminate early */
                else
                        *++q = '\0';            /* terminate filename */
        }

        squeeze(p, outfile);
}

/* eject
eject */

squeeze(infile, outfile)
char *infile, *outfile;
{
        int c;
        FILE *inbuff, *outbuff;         /* file buffers */
        long    infilsiz;


        printf("%s -> %s: ", infile, outfile);

        if(!(inbuff=fopen(infile, "rb"))) {
                printf("Can't open %s for input pass 1\n", infile);
                return 0;
        }
        if(!(outbuff=fopen(outfile, "wb"))) {
                printf("Can't create %s\n", outfile);
                fclose(inbuff);
                return 0;
        }

        /* First pass - get properties of file */
        crc = 0;        /* initialize checksum */
        printf("analyzing, ");
        init_ncr();
        init_huff(inbuff);   
        infilsiz = ftell(inbuff);
        fclose(inbuff);

        /* Write output file header with decoding info */
        wrt_head(outbuff, infile);

        /* Second pass - encode the file */
        printf("squeezing,");
        if(!(inbuff=fopen(infile, "rb"))) {
                printf("Can't open %s for input pass 2\n", infile);
                goto closeout;
        }
        init_ncr();     /* For second pass */

        /* Translate the input file into the output file */
        while((c = gethuff(inbuff)) != EOF)
                putce(c, outbuff);
        oflush(outbuff);
        printf(" done.\n\t(%ld%% reduction.)\n",
                (infilsiz - ftell(outbuff))/(infilsiz / 100L));
closeall:
        fclose(inbuff);
closeout:
        fclose(outbuff);
}

char *rindex(str,c)
char  *str;
char  c;
{
   int   i;

   for (i = strlen(str)-1; i >= 0; i--)
      if (str[i] == c)
         return(&str[i]);
   return(NULL);
}

/* First translation - encoding of repeated characters
 * The code is byte for byte pass through except that
 * DLE is encoded as DLE, zero and repeated byte values
 * are encoded as value, DLE, count for count >= 3.
 */

init_ncr()      /*initialize getcnr() */
{
        state = NOHIST;
}

int
getcnr(iob)
FILE *iob;
{
        switch(state) {
        case NOHIST:
                /* No relevant history */
                state = SENTCHAR;
                return lastchar = getc_crc(iob);   
        case SENTCHAR:
                /* Lastchar is set, need lookahead */
                switch(lastchar) {
                case DLE:
                        state = NOHIST;
                        return 0;       /* indicates DLE was the data */
                case EOF:
                        return EOF;
                default:
                        for(likect = 1; (newchar = getc_crc(iob)) == lastchar && likect < 255; ++likect)
                                ;
                        switch(likect) {
                        case 1:
                                return lastchar = newchar;
                        case 2:
                                /* just pass through */
                                state = SENDNEWC;
                                return lastchar;
                        default:
                                state = SENDCNT;
                                return DLE;
                        }
                }
        case SENDNEWC:
                /* Previous sequence complete, newchar set */
                state = SENTCHAR;
                return lastchar = newchar;
        case SENDCNT:
                /* Sent DLE for repeat sequence, send count */
                state = SENDNEWC;
                return likect;
        default:
                puts("Bug - bad state\n");
                exit(1);
        }
}

/******** Second translation - bytes to variable length bit strings *********/


/* This translation uses the Huffman algorithm to develop a
 * binary tree representing the decoding information for
 * a variable length bit string code for each input value.
 * Each string's length is in inverse proportion to its
 * frequency of appearance in the incoming data stream.
 * The encoding table is derived from the decoding table.
 *
 * The range of valid values into the Huffman algorithm are
 * the values of a byte stored in an integer plus the special
 * endfile value chosen to be an adjacent value. Overall, 0-SPEOF.
 *
 * The "node" array of structures contains the nodes of the
 * binary tree. The first NUMVALS nodes are the leaves of the
 * tree and represent the values of the data bytes being
 * encoded and the special endfile, SPEOF.
 * The remaining nodes become the internal nodes of the tree.
 *
 * In the original design it was believed that
 * a Huffman code would fit in the same number of
 * bits that will hold the sum of all the counts.
 * That was disproven by a user's file and was a rare but
 * infamous bug. This version attempts to choose among equally
 * weighted subtrees according to their maximum depths to avoid
 * unnecessarily long codes. In case that is not sufficient
 * to guarantee codes <= 16 bits long, we initially scale
 * the counts so the total fits in an unsigned integer, but
 * if codes longer than 16 bits are generated the counts are
 * rescaled to a lower ceiling and code generation is retried.
 */

/* Initialize the Huffman translation. This requires reading
 * the input file through any preceding translation functions
 * to get the frequency distribution of the various values.
 */

init_huff(ib)          
FILE *ib;
{
        int c, i;
        int btlist[NUMVALS];    /* list of intermediate binary trees */
        int listlen;            /* length of btlist */
        unsigned int *wp;       /* simplifies weight counting */
        unsigned int ceiling;   /* limit for scaling */

        /* Initialize tree nodes to no weight, no children */
        init_tree();

        /* Build frequency info in tree */
        do {
                c = getcnr(ib);        
                if(c == EOF)
                        c = SPEOF;
                if(*(wp = &node[c].weight) !=  MAXCOUNT)
                        ++(*wp);
        } while(c != SPEOF);
#ifdef DEBUG
        pcounts();      /* debugging aid */
#endif  
        ceiling = MAXCOUNT;

        do {    /* Keep trying to scale and encode */
                if(ceiling != MAXCOUNT)
                        printf("*** rescaling ***, ");
                scale(ceiling);
                ceiling /= 2;   /* in case we rescale */
#ifdef DEBUG
                pcounts();      /* debugging aid */
#endif

                /* Build list of single node binary trees having
                 * leaves for the input values with non-zero counts
                 */
                for(i = listlen = 0; i < NUMVALS; ++i)
                        if(node[i].weight != 0) {
                                node[i].tdepth = 0;
                                btlist[listlen++] = i;
                        }

                /* Arrange list of trees into a heap with the entry
                 * indexing the node with the least weight at the top.
                 */
                heap(btlist, listlen);

                /* Convert the list of trees to a single decoding tree */
                bld_tree(btlist, listlen);

                /* Initialize the encoding table */
                init_enc();

                /* Try to build encoding table.
                 * Fail if any code is > 16 bits long.
                 */
        } while(buildenc(0, dctreehd) == ERROR);
#ifdef DEBUG
        phuff();        /* debugging aid */
#endif
        /* Initialize encoding variables */
        cbitsrem = 0;   /*force initial read */
        curin = 0;      /*anything but endfile*/
}
/* ^L */
/* The count of number of occurrances of each input value
 * have already been prevented from exceeding MAXCOUNT.
 * Now we must scale them so that their sum doesn't exceed
 * ceiling and yet no non-zero count can become zero.
 * This scaling prevents errors in the weights of the
 * interior nodes of the Huffman tree and also ensures that
 * the codes will fit in an unsigned integer. Rescaling is
 * used if necessary to limit the code length.
 */

scale(ceil)
unsigned int ceil;      /* upper limit on total weight */
{
        int ovflw, divisor, i;
        unsigned int w, sum;
        char increased;         /* flag */

        do {
                for(i = sum = ovflw = 0; i < NUMVALS; ++i) {
                        if(node[i].weight > (ceil - sum))
                                ++ovflw;
                        sum += node[i].weight;
                }

                divisor = ovflw + 1;

                /* Ensure no non-zero values are lost */
                increased = FALSE;
                for(i = 0; i < NUMVALS; ++i) {
                        w = node[i].weight;
                        if (w < divisor && w > 0) {
                                /* Don't fail to provide a code if it's used at all */
                                node[i].weight = divisor;
                                increased = TRUE;
                        }
                }
        } while(increased);

        /* Scaling factor choosen, now scale */
        if(divisor > 1)
                for(i = 0; i < NUMVALS; ++i)
                        node[i].weight /= divisor;
}
/* ^L */
/* heap() and adjust() maintain a list of binary trees as a
 * heap with the top indexing the binary tree on the list
 * which has the least weight or, in case of equal weights,
 * least depth in its longest path. The depth part is not
 * strictly necessary, but tends to avoid long codes which
 * might provoke rescaling.
 */

heap(list, length)
int list[], length;
{
        int i;

        for(i = (length - 2) / 2; i >= 0; --i)
                adjust(list, i, length - 1);
}

/* Make a heap from a heap with a new top */

adjust(list, top, bottom)
int list[], top, bottom;
{
        int k, temp;
        char cmptrees();

        k = 2 * top + 1;        /* left child of top */
        temp = list[top];       /* remember root node of top tree */
        if( k <= bottom) {
                if( k < bottom && cmptrees(list[k], list[k + 1]))
                        ++k;

                /* k indexes "smaller" child (in heap of trees) of top */
                /* now make top index "smaller" of old top and smallest child */
                if(cmptrees(temp, list[k])) {
                        list[top] = list[k];
                        list[k] = temp;
                        /* Make the changed list a heap */
                        adjust(list, k, bottom); /*recursive*/
                }
        }
}

/* Compare two trees, if a > b return true, else return false
 * note comparison rules in previous comments.
 */

char    /* Boolean */
cmptrees(a, b)
int a, b;       /* root nodes of trees */
{
        if(node[a].weight > node[b].weight)
                return TRUE;
        if(node[a].weight == node[b].weight)
                if(node[a].tdepth > node[b].tdepth)
                        return TRUE;
        return FALSE;
}
/* ^L */
/* HUFFMAN ALGORITHM: develops the single element trees
 * into a single binary tree by forming subtrees rooted in
 * interior nodes having weights equal to the sum of weights of all
 * their descendents and having depth counts indicating the
 * depth of their longest paths.
 *
 * When all trees have been formed into a single tree satisfying
 * the heap property (on weight, with depth as a tie breaker)
 * then the binary code assigned to a leaf (value to be encoded)
 * is then the series of left (0) and right (1)
 * paths leading from the root to the leaf.
 * Note that trees are removed from the heaped list by
 * moving the last element over the top element and
 * reheaping the shorter list.
 */

bld_tree(list, len)
int list[];
int len;
{
        int freenode;           /* next free node in tree */
        int lch, rch;           /* temporaries for left, right children */
        struct nd *frnp;        /* free node pointer */
        char maxchar();

        /* Initialize index to next available (non-leaf) node.
         * Lower numbered nodes correspond to leaves (data values).
         */
        freenode = NUMVALS;

        while(len > 1) {
                /* Take from list two btrees with least weight
                 * and build an interior node pointing to them.
                 * This forms a new tree.
                 */
                lch = list[0];  /* This one will be left child */

                /* delete top (least) tree from the list of trees */
                list[0] = list[--len];
                adjust(list, 0, len - 1);

                /* Take new top (least) tree. Reuse list slot later */
                rch = list[0];  /* This one will be right child */

                /* Form new tree from the two least trees using
                 * a free node as root. Put the new tree in the list.
                 */
                frnp = &node[freenode]; /* address of next free node */
                list[0] = freenode++;   /* put at top for now */
                frnp->lchild = lch;
                frnp->rchild = rch;
                frnp->weight = node[lch].weight + node[rch].weight;
                frnp->tdepth = 1 + maxchar(node[lch].tdepth, node[rch].tdepth);
                /* reheap list  to get least tree at top*/
                adjust(list, 0, len - 1);
        }
        dctreehd = list[0];     /*head of final tree */
}
/* ^L */
char
maxchar(a, b)
char a, b;
{
        return a > b ? a : b;
}
/* Initialize all nodes to single element binary trees
 * with zero weight and depth.
 */

init_tree()
{
        int i;

        for(i = 0; i < NUMNODES; ++i) {
                node[i].weight = 0;
                node[i].tdepth = 0;
                node[i].lchild = NOCHILD;
                node[i].rchild = NOCHILD;
        }
}

init_enc()
{
        int i;

        /* Initialize encoding table */
        for(i = 0; i < NUMVALS; ++i) {
                codelen[i] = 0;
        }
}
/* ^L */
/* Recursive routine to walk the indicated subtree and level
 * and maintain the current path code in bstree. When a leaf
 * is found the entire code string and length are put into
 * the encoding table entry for the leaf's data value.
 *
 * Returns ERROR if codes are too long.
 */

int             /* returns ERROR or NULL */
buildenc(level, root)
int level;/* level of tree being examined, from zero */
int root; /* root of subtree is also data value if leaf */
{
        int l, r;

        l = node[root].lchild;
        r = node[root].rchild;
#ifdef DEBUG
        if (debug) printf("level=%d,root=%d,l=%d,r=%d,tcode=%04x\n",level,root,l,r,tcode);
#endif
        if( l == NOCHILD && r == NOCHILD) {
                /* Leaf. Previous path determines bit string
                 * code of length level (bits 0 to level - 1).
                 * Ensures unused code bits are zero.
                 */
                codelen[root] = level;
                code[root] = tcode & ((unsigned int)(~0) >> ((sizeof(int) * 8) - level));
#ifdef DEBUG
                if (debug) printf("  codelen[%d]=%d,code[%d]=%02x\n",root,codelen[root],root,code[root]);
#endif
                return( (level > 16) ? ERROR : 0);
        } else {
                if( l != NOCHILD) {
                        /* Clear path bit and continue deeper */
                        tcode &= ~(1 << level);
                        /* NOTE RECURSION */
                        if(buildenc(level + 1, l) == ERROR)
                                return ERROR;
                }
                if(r != NOCHILD) {
                        /* Set path bit and continue deeper */
                        tcode |= 1 << level;
                        /* NOTE RECURSION */
                        if(buildenc(level + 1, r) == ERROR)
                                return ERROR;
                }
        }
        return NULL;    /* if we got here we're ok so far */
}
/* ^L */
/* Write out the header of the compressed file */

wrt_head(ob, infile)
FILE *ob;
char *infile;   /* input file name (w/ or w/o drive) */
{
        int i, k, l, r;
        int numnodes;           /* nbr of nodes in simplified tree */

        putwe(RECOGNIZE, ob);   /* identifies as compressed */
        putwe(crc, ob);         /* unsigned sum of original data */

        /* Record the original file name w/o drive */
        if(*(infile + 1) == ':')
                infile += 2;    /* skip drive */

        do {
                putce(*infile, ob);
        } while(*(infile++) != '\0');


        /* Write out a simplified decoding tree. Only the interior
         * nodes are written. When a child is a leaf index
         * (representing a data value) it is recoded as
         * -(index + 1) to distinguish it from interior indexes
         * which are recoded as positive indexes in the new tree.
         * Note that this tree will be empty for an empty file.
         */

        numnodes = dctreehd < NUMVALS ? 0 : dctreehd - (NUMVALS -1);
        putwe(numnodes, ob);

        for(k = 0, i = dctreehd; k < numnodes; ++k, --i) {
                l = node[i].lchild;
                r = node[i].rchild;
                l = l < NUMVALS ? -(l + 1) : dctreehd - l;
                r = r < NUMVALS ? -(r + 1) : dctreehd - r;
                putwe(l, ob);   /* left child */
                putwe(r, ob);   /* right child */
        }
}
/* ^L */
/* Get an encoded byte or EOF. Reads from specified stream AS NEEDED.
 *
 * There are two unsynchronized bit-byte relationships here.
 * The input stream bytes are converted to bit strings of
 * various lengths via the static variables named c...
 * These bit strings are concatenated without padding to
 * become the stream of encoded result bytes, which this
 * function returns one at a time. The EOF (end of file) is
 * converted to SPEOF for convenience and encoded like any
 * other input value. True EOF is returned after that.
 *
 * The original gethuff() called a seperate function,
 * getbit(), but that more readable version was too slow.
 */

int                             /*  Returns byte values except for EOF */
gethuff(ib)
FILE *ib;
{
        unsigned int rbyte;     /* Result byte value */
        char need;        /* numbers of bits */

        rbyte = 0;
        need = 8;               /* build one byte per call */

        /* Loop to build a byte of encoded data
         * Initialization forces read the first time
         */

loop:
        if(cbitsrem >= need) {
                /* Current code fullfills our needs */
                if(need == 0)
                        return (int)(rbyte & 0xff);
                /* Take what we need */
                rbyte |= ccode << (8 - need);
                /* And leave the rest */
                ccode >>= need;
                cbitsrem -= need;
                return (int)(rbyte & 0xff);
        }

        /* We need more than current code */
        if(cbitsrem > 0) {
                /* Take what there is */
                rbyte |= ccode << (8 - need);
                need -= cbitsrem;
        }
        /* No more bits in current code string */
        if(curin == SPEOF) {
                /* The end of file token has been encoded. If
                 * result byte has data return it and do EOF next time
                 */
                cbitsrem = 0;

                return (need == 8) ? EOF : (int)(rbyte & 0xff);
        }

        /* Get an input byte */
        if((curin = getcnr(ib)) == EOF)
                curin = SPEOF;  /* convenient for encoding */

        /* Get the new byte's code */
        ccode = code[curin];
        cbitsrem = codelen[curin];

        goto loop;
}


/* Get next byte from file and update checksum */

int
getc_crc(ib)
FILE *ib;
{
        int c;

        c = getc(ib);
        if (c != EOF)
                crc += c;               /* checksum */
        return c;
}

/* Output functions with error reporting */

static char obuf[128];
static int oblen = 0;

putce(c,  iob)
int c;
FILE *iob;
{
        obuf[oblen++] = c;
        if (oblen >= sizeof(obuf)) oflush(iob);
}

putwe(w,  iob)
int w;
FILE *iob;
{
        obuf[oblen++] = w;
        if (oblen >= sizeof(obuf)) oflush(iob);
        obuf[oblen++] = w >> 8;
        if (oblen >= sizeof(obuf)) oflush(iob);
}

oflush(iob)                             /* flush output buffer */
FILE *iob;
{
        if (oblen && !fwrite(obuf, oblen, 1, iob)) {
                printf("Error writing output file\n");
                exit(1);
        }
        oblen = 0;
}

/* Debugging aids for SQ and related modules */

pcounts()
{
        int i;

        if(debug) {
                printf("\nCounts after 1st algorithm and maybe scaling");
                for(i = 0; i < NUMVALS; ++i) {
                        if(i%8 == 0)
                                printf("\n%4x  ", i);
                        printf("%5u  ", node[i].weight);
                }
        printf("\n\n");
        }
}

phuff()
{
        int i;

        if(debug) {
                printf("\nEncoding tree - root=%3d\n", dctreehd);
                for(i = 0; i < NUMNODES; ++i)
                        if(node[i].weight != 0)
                                printf("%3d  w=%5u d=%3d l=%3d r=%3d\n", i, node[i].weight, node[i].tdepth, node[i].lchild, node[i].rchild);

                printf("\nHuffman codes\n");
                for(i = 0; i < NUMVALS; ++i) {
                        if(codelen[i] > 0)
                                printf("%3d  %4x l=%2d c=%4x\n", i, i, codelen[i], code[i]);
                }
        }
}
