/* Diese Routine lehnt sich an ein Beispiel von
 * William Pugh an. Er wurde um Funktionalit„t
 * verallgemeinert und anwenderfreundlicher
 * gestaltet.
 *
 * Klaus Elsbernd
 * entwickelt mit TURBOC
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <skiplist.h>

int randomLevel(void);

int randomsLeft;
long randomBits;

void
init_skiplists () /* --- initialize skip lists */
{
   /* get a 32 bits random level number! */
   randomBits = (rand()<<16)+rand();
   randomsLeft = BitsInRandom/2;
} /* init_skiplists */

int
skip_cmp_default (x,y) /* compares two strings */
char *x, *y;
{
  return(strcmp(x,y));
} /* skip_cmp_default */

void /* ----------- don't free the information */
skip_free_default (x)
char *x;
{
  return;
} /* skip_free_default */

skip_list            /* create a new skip list */
new_skiplist (cmp_fun,free_fun)
BOOLEAN (* cmp_fun)();
void (* free_fun)();
{
   skip_list l;
   int i;

   l = (skip_list)
       malloc(sizeof(struct listStructure));

   l->level = 0;
   l->cmp_fun = (cmp_fun != NULL)
                ? cmp_fun : skip_cmp_default;
   l->free_fun = (free_fun != NULL)
                ? free_fun : skip_free_default;
   l->header = newNodeOfLevel(MaxNumberOfLevels);
   l->last = NULL;
   l->no = 0; /* no of entries in the skiplist */

   /* If you need information about used memory,
    * uncomment the following statement
      l->memory = sizeof(struct listStructure)
              + sizeof(struct nodeStructure)
              + (MaxNumberOfLevels)*sizeof(node);
    */

   for (i = 0; i < MaxNumberOfLevels; i++)
     l->header->forward[i] = NULL;
   return(l);
} /* new_skiplist */

void
free_skiplist (l)/* free an allocated skiplist */
skip_list l;
{
   register node p, q;

   p = l->header;
   do {
     q = p->forward[0];
     /* free the information */
     (l->free_fun)(p->inf);
     free(p);             /* free node storage */
     p = q;
   } while (p != NULL);
   free(l->header);     /* free header storage */
   free(l);               /* free list storage */
} /* free_skiplist */

int
randomLevel ()  /* ---------- get random level */
{
  register int level = 0;
  register long b;

  /* While 2 consecutive bits of a random number
   * are != 0 add 1 to level;
   * It will be very unlikely, that many sequences
   * will result in high levels. */
  do {
    b = randomBits & 3;
    if (!b) level++;
    randomBits >>= 2;
    if (--randomsLeft == 0) {
        randomBits = (rand()<<16)+rand();
        randomsLeft = BitsInRandom/2;
    }
  } while (!b);
  return(level > MaxLevel ? MaxLevel : level);
} /* randomLevel */

BOOLEAN
skip_insert (l,inf,dp)  /*  insert information */
register skip_list l;
register Information *inf;
BOOLEAN dp;
{
  register int k;
  register node p, q;
  register int cmp;
  node update[MaxNumberOfLevels];

  p = l->header;
  /* Search first the skip list elements within
   * level k using the comparasion function
   * cmp_fun. Than decrement k down to level 0.
   */
  k = l->level;
  do {
    while (q = p->forward[k],
           q != NULL
           && (cmp = l->cmp_fun(q->inf,inf)) < 0) {
      p = q;
    }
    update[k] = p;
  } while (--k >= 0);

  /* If the key is already there and duplicates
   * are not allowed, than update the value
   */
  if (!dp && q != NULL && cmp == 0) {
      /* the last information will be stored */
      q->inf = inf;
      return(FALSE);
  }

  l->no++;            /* count number of nodes */
  /* Generate a new random level for the new key
   * and initialize it with the apropriate
   * pointers
   */
  k = randomLevel();
  /* Is the new level
   * greater than the old skiplist level? */
  if (k > l->level) {
      k = ++l->level;
      update[k] = l->header;
  }
  q = newNodeOfLevel(k);

/* If you need information about used memory,
 * uncomment the following statement
  l->memory += sizeof(struct nodeStructure)
               + (k)*sizeof(node);
 */

  q->inf = inf;
  do {               /* insert the new element */
      p = update[k];      /* save old pointers */
      q->forward[k] = p->forward[k];
      p->forward[k] = q; /* insert the new one */
  } while (--k >= 0);

  return(TRUE);
} /* skip_insert */

BOOLEAN
skip_delete (l,inf)      /* delete information */
register skip_list l;
register Information *inf;
{
  register int k, m;
  register int cmp;
  node update[MaxNumberOfLevels];
  register node p, q;

  p = l->header;
  k = m = l->level;
  do {                 /* find the information */
    while (q = p->forward[k],
           q != NULL
           && (cmp = l->cmp_fun(q->inf,inf)) < 0)
      p = q;
    update[k] = p;
  } while (--k >= 0);

  if (q != NULL && cmp == 0) {       /* found? */
      /* update all pointers pointing to the
       * information to be deleted */
      for (k = 0;
           k <= m
           && (p = update[k])->forward[k] == q;
           k++) {
        p->forward[k] = q->forward[k];
      }
      /* decrease the maximal skip list level,
       * if necessary */
      while (l->header->forward[m] == NULL
             && m > 0)
        m--;
      l->level = m;
      l->no--;
      (l->free_fun)(q->inf);
      free(q);
    /* If you need information about used memory,
     * uncomment the following statement
      l->memory -= sizeof(struct nodeStructure)
                   + (k)*sizeof(node);
     */
      return(TRUE);   /* true if key not found */
     }
     else
       return(FALSE);/* false if key not found */
} /* skip_delete */

node
skip_search (l,inf)  /* --------- search a key */
register skip_list l;
register Information *inf;
{
  register int k;
  register int cmp;
  register node p, q;

  p = l->header;
  k = l->level;
  do {
    while (q = p->forward[k],
           q != NULL
           && (cmp = l->cmp_fun(q->inf,inf)) < 0)
      p = q;
  } while (--k >= 0);
  l->last = q;  /* remember last searched cell */
  if (q != NULL && cmp != 0)
      return(NULL);
  return(q);
} /* skip_search */

node
skip_next (l)  /* search for next information */
register skip_list l;
{
  if (l->last == NULL)
      l->last = l->header;
  l->last = l->last->forward[0];
  return(l->last);
} /* skip_next */

