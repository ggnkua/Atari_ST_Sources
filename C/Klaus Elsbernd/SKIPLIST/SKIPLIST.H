/* include file for skip-lists
 *
 * Klaus Elsbernd
 * TURBOC
 */

#ifndef Information
/* no allready defined by the user */
#define Information char
#endif

#define FALSE               0
#define TRUE                1
#define BOOLEAN             int

#define BitsInRandom        31

#define allowDuplicates

#define MaxNumberOfLevels   16
#define MaxLevel            (MaxNumberOfLevels-1)

#define newNodeOfLevel(l)                       \
      (node)malloc(sizeof(struct nodeStructure) \
                            + (l)*sizeof(node))

/* 2 structures needed: */
typedef struct nodeStructure *node;

typedef struct nodeStructure {
    Information *inf;
    /* variable sized array of forward pointer */
    node        forward[1];
};

typedef struct listStructure {
        /* Maximum level of the list (1 more than
         * the number of levels in the list) */
    int level;
    unsigned int no;/* number of nodes in list */
                 /* pointer to the firstheader */
    /* if you need information about used Memory,
     * uncomment the following statement
    unsigned long memory;
     */
    struct nodeStructure *header;
    struct nodeStructure *last;
         /* pointer to comparasion function with
          * two arguments
          * cmp_fun returns
          *   0 iff argument 1 == argument 2
          *   1 iff argument 1 >  argument 2
          *  -1 iff argument 1 <  argument 2
          */
    int (* cmp_fun)
                 (Information *x,Information *y);
    void (* free_fun)(Information *inf);
} *skip_list;

/* prototypes: */
void    init_skiplists(void);
skip_list new_skiplist(BOOLEAN (* cmp_fun)(),
                       void (* free_fun)());
void    free_skiplist(skip_list l);
int     skip_cmp_default(Information *x,
                         Information *y);
void    skip_free_default(Information *inf);

BOOLEAN skip_insert(skip_list l,
                    Information *inf,
                    BOOLEAN dp),
        skip_delete(skip_list l,
                    Information *inf);
node    skip_search(skip_list l,
                    Information *inf),
        skip_next(skip_list l);

/* externals: */
extern  int skip_cmp_default();
extern  void skip_free_default();
extern  BOOLEAN skip_insert(), skip_delete();
extern  node skip_search(), skip_next();
extern  void init_skiplists(), free_skiplist();
extern  skip_list new_skiplist();

