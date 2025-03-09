/* kompaktes Beispielprogramm, daž die Anwendung
 * der Speicherverwaltung an einem Beispiel
 * testet.
 * Die Verwaltungsroutinen k”nnen ohne weiteres
 * eigene Programme eingebunden werden.
 * Kompiliert mit TURBO-C
 *
 * Klaus Elsbernd
 * Hilgardring 32
 * 6750 Kaiserslautern
 */

#include <stdio.h>
#include <aes.h>
#include <stdlib.h>
#include <string.h>

   /* size of cell table */
#define CELLTABSIZE     512
   /* Number of Bytes in one block */
#define BLOCKBYTES      8192

/* control-blk for alloc of memory of same size*/
struct memcntrl { /*!*/
  long **memtab;        /* current memtab */
  long memtabidx;       /* idx in memtabentry */
  long memtabsize;      /* max of memblocks */
  long memblockidx;     /* idx memblockentry */
  long memblocksize;    /* no entries in block */
  unsigned int  memsize;/* size memblock entry */
  long *memfreelist;    /* points to ... */
  long *memblockptr;    /* points to curr blk */
  long memstatentries;  /* no allocated entries*/
  long memstatuentries; /* no of used entries */
  long memstatfentries; /* no of free entries */
  struct memcntrl *memnext;/* next memory-def */
};

/* memory description */
typedef struct memcntrl *kernmem;

/* start of memory-control */
struct memcntrl *sysmem;

/* das ist meine Datenstruktur */
struct myrecord {
        struct myrecord *meinZeiger;
        long            meineZahl;
        int             meinIndex;
};

typedef struct myrecord    *MYrec;

#define CONVmyrec(x) (MYrec)(x)

void faterr(char *str),  /* ANSI-C l„žt gržen */
     freemem(long size, long *ptr);
char *new(unsigned int size);
kernmem newmemcntrl(long size),
        searchmemcntrl(long);
long *collectgarb(void), *freshmem(kernmem);
MYrec mkrec(void);

char err_memory[] =
       "[1][No more | memory available!][Abort]";
int phase1 = 1;      /* block allocation phase */

void
faterr (str)  /*  prints a fatal error message */
char *str;
{
        form_alert(1,str);
        exit(1);
} /* faterr */

char *
new (size)  /* -------- allocates 'size' bytes */
unsigned int size;
{
   char *res;

        /*! alloc minimal 1 byte */
        if (!size) size = 1;
        if ((res = malloc(size)) == NULL) {
           /* terminate block allocation phase */
           phase1 = 0;
           { register kernmem mem = sysmem;
             while (mem != NULL) {
               mem->memtabsize =
                              mem->memtabidx + 1;
               mem = mem->memnext;
             }
           }
           collectgarb();
           /* try again */
           if ((res = malloc(size)) == NULL)
              faterr(err_memory);
        }
        return(res);
} /* new */

kernmem
newmemcntrl (size)  /* new memory control blk */
long size;
{
   kernmem mem = (kernmem)
      new((unsigned int)sizeof(struct memcntrl));
   long idx = (int)(BLOCKBYTES/size);

  mem->memtab = (long **)
                new((unsigned int)
                   (CELLTABSIZE*sizeof(long *)));
  mem->memtabidx = -1;
  mem->memtabsize = CELLTABSIZE;
  if (idx == 0) idx = 1;
  mem->memblockidx = mem->memblocksize =
                                 BLOCKBYTES/size;
  mem->memsize = (unsigned int)size;
  mem->memfreelist = mem->memblockptr = NULL;
  mem->memnext = NULL;
  mem->memstatentries = mem->memstatuentries =
                        mem->memstatfentries = 0;
  return(mem);
} /* newmemcntrl */

long *
freshmem (mem)  /*  returns a fresh memory-blk */
kernmem mem;
{
   long *memblockptr;

  if (phase1) { /* in this phase storage is still
                 * available */
      if (mem->memblockidx++ >=mem->memblocksize)
          {       /* get it from current block */

          if (++mem->memtabidx < mem->memtabsize)
              {/* create a new block */
              if ((mem->memtab[mem->memtabidx]
                  = mem->memblockptr
                  = (long *)malloc((size_t)
                                  (mem->memsize *
                              mem->memblocksize))
                  ) == NULL) {
                  mem->memtabsize=mem->memtabidx;
                  /* run out of storage -->
                   * phase2 */
                  goto phase2;
              }
              memset(mem->memblockptr,'\0',
                     (size_t)(mem->memsize *
                             mem->memblocksize));
              mem->memblockidx = 1;
          }
          else goto phase2;
      }
     /* count number of demanded memory-entries*/
     ++mem->memstatentries;
     ++mem->memstatuentries;
     memblockptr = mem->memblockptr;
     (char *)mem->memblockptr += mem->memsize;
     return(memblockptr);
phase2:  /* in this phase storage is exhausted */
     phase1 = 0;
  }
  if (mem->memfreelist == NULL) {
      /* try garbage collecting */
      if (collectgarb() == NULL)
          faterr(err_memory);
  }

  /*! count number of demanded block entries */
  ++mem->memstatuentries;
  mem->memstatfentries--;
  memblockptr = mem->memfreelist;
  mem->memfreelist = (long *)(*mem->memfreelist);
  return(memblockptr);
} /* freshmem */

kernmem
searchmemcntrl (size)  /* search for cntrl blk */
register long size;
{
   register kernmem mem = sysmem,
            *pmem = &sysmem;

  while (mem != NULL && mem->memsize < size) {
    /* save a pointer to the last controlblock */
    pmem = &mem->memnext;
    mem = mem->memnext;
  }
  if (mem == NULL || mem->memsize != size ){
      /* insert new memory */
      *pmem = newmemcntrl(size);
      (*pmem)->memnext = mem;
      mem = *pmem;
  }
  return(mem);
} /* searchmemcntrl */

void
freemem (size,ptr)  /* free a record im mem-blk*/
long size;
long *ptr;
{
   kernmem mem = searchmemcntrl(size);

        /* concatenate memory-blocks */
        *ptr = (long)mem->memfreelist;
        mem->memfreelist = ptr;
        mem->memstatfentries++;
} /* freemem */

long *
collectgarb ()  /* ----------- collect garbage */
{
        /* was auch immer hier gemacht wird,
         * (wie Mll eingesammelt werden kann),
         * es sollte die Freispeicherliste
         * zurckgegeben werden */
        return(sysmem->memfreelist);
} /* collectgarb */

MYrec
mkrec ()  /*! ----------- make a record object */
{
   register MYrec rec;

  rec = CONVmyrec(freshmem(searchmemcntrl((long)
                    (sizeof(struct myrecord)))));
  /* oder alternativ, wenn es nur ein Record-typ:
     rec = CONVmyrec(freshmem(&sysmem)); */
  rec->meinZeiger = NULL;
  rec->meineZahl = 0;
  rec->meinIndex = 0;
  return(rec);
} /* mkrec */

void
main ()  /* -- Programm test memory-allocation */
{
   int i, j;
   register MYrec startrecord, record;

   /* Schleife, die in jedem Durchlauf 387
    * Datenstrukturen anfordert und diese
    * anschliežend wieder freigibt.
    */
   for (i = 0; i < 3000; i++) {
     for (startrecord = mkrec(),
          record = startrecord, j = 0;
          j < 387; j++) {
        record->meinZeiger = mkrec();
        record = record->meinZeiger;
     }
     for (record = startrecord, j = 0;
          j < 387; j++) {
        startrecord = record->meinZeiger;
        freemem((long)(sizeof(struct myrecord)),
                (long *)record);
        record = startrecord;
     }
   }
} /* main */
