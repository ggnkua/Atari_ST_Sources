/* _______________
** getstart, fatck - get starting cluster, FAT consistency check
** atari corp	(1 March 1988)  asm
**
** see GETSTART(3) manual pages
**
** Fatck and support algorithms are courtesy Derek Mui.
**
** $Header$
** $Source$
** $Author$
**
** $Revision$
** $Date$
** $State$
** $Locker$
** $Log$
*/



# include	<osbind.h>
# include	"getstart.h"

# define	OSIZE	(32767)		/* orphan list size in words */
# define	ROOT	(0)		/* root directory dummy cluster */
# define	EOFAT	(0xffff)	/* end of file allocation chain */

BPB *bp;				/* pointer to device BPB */
char *fat1buf;				/* first FAT buffer */
char *fat2buf;				/* second FAT buffer */
char *rootbuf;				/* root directory buffer */
char *clusbuf;				/* general-purpose cluster buffer */



/*
** Get starting cluster.
*/

GSINFO *getstart (orphans, clusno, devno)
register int *orphans;
register int clusno, devno;
{
   static GSINFO info;
   register unsigned i, fatlen;

   if ((long)orphans <= 0L)
      return ((GSINFO *)GOOFY);		/* FAT not validated by fatck */

   if (!allobuf (devno))		/* cache for FATs and root directory */
   {
      freebuf ();
      return (GFAIL);
   }
   if (!readfat (devno))		/* get first and second FATs */
   {
      freebuf ();
      return (GFAIL);
   }
   if (!readroo (devno))		/* get root directory */
   {
      freebuf ();
      return (GFAIL);
   }

   if (!nextcl (clusno))
   {
      freebuf ();
      return ((GSINFO *)GALLO);		/* current cluster not allocated */
   }
   if (bsearch ((orphans+1), *orphans, clusno))
   {
      freebuf ();
      return ((GSINFO *)GORPH);		/* orphan in FAT allocation chain */
   }

   info.gs_count = 1;			/* backtrack file allocation chain */
   info.gs_prev = 0;
   fatlen = bp->numcl + 2;
   while (1)				/* look up and down FAT */
   {
      for (i = clusno - 1; i >= 2; i--)
         if (nextcl (i) == clusno)
         {
            clusno = i;
            if (bsearch ((orphans+1), *orphans, clusno))
            {
               freebuf ();
               return ((GSINFO *)GORPH);
            }
            info.gs_count++;
            if (!info.gs_prev)
               info.gs_prev = clusno;
         }
      for (i = clusno + 1; i <= fatlen; i++)
         if (nextcl (i) == clusno)
         {
            clusno = i;
            if (bsearch ((orphans+1), *orphans, clusno))
            {
               freebuf ();
               return ((GSINFO *)GORPH);
            }
            info.gs_count++;
            if (!info.gs_prev)
               info.gs_prev = clusno;
            break;
         }
      if (i > fatlen)
         break;
   }
   info.gs_head = clusno;

   branch (devno, ROOT, clusno, &info);	/* find starting cluster */

   freebuf ();
   return (&info);
}



/*
** FAT consistency check.
*/

int *fatck (devno)
register int devno;
{
   static int olist[OSIZE];
   register unsigned i, fatlen;

   if (!allobuf (devno))		/* cache for FATs and root directory */
   {
      freebuf ();
      return (FFAIL);
   }
   if (!readfat (devno))		/* get first and second FATs */
   {
      freebuf ();
      return ((int *)FFATS);
   }
   if (!readroo (devno))		/* get root directory */
   {
      freebuf ();
      return ((int *)FROOT);
   }

   fatlen = bp->fsiz * bp->recsiz;	/* compare first and second FATs */
   for (i = 0; i < fatlen; i += sizeof(long))
      if (*((long *)(fat1buf+i)) != *((long *)(fat2buf+i)))
      {
         freebuf ();
         return ((int *)FCONF);		/* conflicting FAT entry */
      }

   fatlen = bp->numcl + 2;		/* zero tallies */
   for (i = 2; i <= fatlen; i += sizeof(long))
      *((long *)(fat2buf+i)) = 0L;

   branch (devno, ROOT, 0, 0L);		/* traverse entire directory tree */

   olist[0] = 0;			/* check tallies, build orphan list */
   for (i = 2; i <= fatlen; i++)
   {
      if (*(fat2buf+i) > 1)
      {
         freebuf ();
         return ((int *)FAMBI);		/* ambiguous FAT entry reference */
      }
      if (!(*(fat2buf+i)) && nextcl (i))
         olist[++olist[0]] = i;
   }

   freebuf ();
   return (&olist[0]);
}



/*
** Miscellaneous support functions.
*/

int allobuf (dev)			/* allocate memory for buffers */
int dev;
{
   if (!(bp = (BPB *)Getbpb (dev)))
      return (0);
   if (!(fat1buf = (char *)Malloc ((long)bp->fsiz * (long)bp->recsiz)))
      return (0);
   if (!(fat2buf = (char *)Malloc ((long)bp->fsiz * (long)bp->recsiz)))
      return (0);
   if (!(rootbuf = (char *)Malloc ((long)bp->rdlen * (long)bp->recsiz)))
      return (0);
   return ((int)(clusbuf = (char *)Malloc ((long)bp->clsiz
      * (long)bp->recsiz)));
}

int readfat (dev)			/* read first and second FATs */
int dev;
{
   if (Rwabs (0, fat1buf, bp->fsiz, bp->fatrec - bp->fsiz, dev))
      return (0);
   return (!Rwabs (0, fat2buf, bp->fsiz, bp->fatrec, dev));
}

int readroo (dev)			/* read root directory */
int dev;
{
   return (!Rwabs (0, rootbuf, bp->rdlen, bp->fatrec + bp->fsiz, dev));
}

int readclu (cl, dev)			/* read cluster */
int cl, dev;
{
   return (!Rwabs (0, clusbuf, bp->clsiz, (cl-2)*bp->clsiz+bp->datrec, dev));
}

int freebuf ()				/* free memory for buffers */
{
   Mfree (rootbuf);
   Mfree (fat1buf);
   Mfree (fat2buf);
   Mfree (clusbuf);
}

int branch (devo, clus, key, inf)	/* recursive branch traverse */
register int devo, clus, key;
register GSINFO *inf;
{
   register FCB *fp;
   register int fcount, fx;
   int sclus, nclus, px;
   if (clus != ROOT)
   {
      (*(fat2buf+clus))++;
      if (!readclu (clus, devo))
      {
         if (inf)
            inf->gs_fpath[0] = '\0';
         return (0);
      }
      fp = (FCB *)clusbuf;
      fcount = (bp->clsizb / sizeof(FCB)) - 1;
   }
   else
   {
      if (inf)
         inf->gs_fpath[px = 0] = '\0';
      fp = (FCB *)rootbuf;
      fcount = ((bp->rdlen * bp->recsiz) / sizeof(FCB)) - 1;
   }
   fx = 0;
   while (fx <= fcount)
   {
      if ((fp->f_name[0] != FN_FRE) && ((fp->f_name[0] & 0xff) != FN_DEL)
         && (fp->f_name[0] != FN_DIR) && fp->f_clust)
      {
         swapb (&fp->f_clust, &sclus);
         if (key == sclus)
         {
            inf->gs_dsect = ((clus != ROOT) ? (clus-2)*bp->clsiz+bp->datrec
               : (bp->fatrec + bp->fsiz) + (fx / (bp->recsiz / sizeof(FCB))));
            inf->gs_doff = (fx * sizeof(FCB)) % bp->recsiz;
            addfn (&fp->f_name[0], &inf->gs_fpath[0]);
            return (1);
         }
         if (fp->f_attrib == FA_SUB)
         {
            if (inf)
               px = addfn (&fp->f_name[0], &inf->gs_fpath[0]);
            if (branch (devo, sclus, key, inf))
               return (1);
            if (inf)
               inf->gs_fpath[px] = '\0';
            if (clus != ROOT)
               if (!readclu (clus, devo))
               {
                  if (inf)
                     inf->gs_fpath[0] = '\0';
                  return (0);
               }
         }
         else if (!key)
            leaf (sclus);
      }
      if ((clus != ROOT) && (fx == fcount)) 
      {
         nclus = nextcl (clus);
         if (!nclus || (nclus == EOFAT))
            break;
         if (*(fat2buf+nclus))
         {
            (*(fat2buf+nclus))++;
            break;
         }
         clus = nclus;
         (*(fat2buf+clus))++;
         if (!readclu (clus, devo))
         {
            if (inf)
               inf->gs_fpath[0] = '\0';
               return (0);
         }
         fp = (FCB *)clusbuf, fx = 0;
      }
      else
         fp++, fx++;
   }
   return (0);
}

int leaf (clus)				/* linear leaf traverse */
register int clus;
{
   register int nclus;
   (*(fat2buf+clus))++;
   nclus = nextcl (clus);
   while (nclus && (nclus != EOFAT))
   {
      if (*(fat2buf+nclus))
      {
         (*(fat2buf+nclus))++;
         break;
      }
      clus = nclus;
      (*(fat2buf+clus))++;
      nclus = nextcl (clus);
   }
}

int nextcl (cl)				/* next cluster in chain */
register int cl;
{
   unsigned ncl;
   if (bp->b_flags & BF_F16)
   {
      swapb (fat1buf+(cl*2), &ncl);
      ncl = ((ncl >= 0xfff0) && (ncl <= 0xffff)) ? EOFAT : ncl;
   }
   else
   {
      swapb (fat1buf+(cl+(cl/2)), &ncl);
      if (cl & 0x0001)
         ncl >>= 4;
      ncl &= 0x0fff;
      ncl = ((ncl >= 0x0ff0) && (ncl <= 0x0fff)) ? EOFAT : ncl;
   }
   return (ncl);
}

int addfn (src, dst)			/* add file name to path string */
register char *src, *dst;
{
   register int old, i;
   for (old = 0; *dst; dst++, old++);
   *dst++ = '\\';
   for (i = 0; i < 11; src++, i++)
   {
      if ((*src) && (*src != ' '))
      {
         if (i == 8)
            *dst++ = '.';
         *dst++ = *src;
      }
   }
   *dst = '\0';
   return (old);
}

int bsearch (list, len, key)		/* binary search a la k&r */
register int list[], len, key;
{
   register int low, mid, high;
   low = 0;
   high = len - 1;
   while (low <= high)
   {
      mid = (low + high) / 2;
      if (key < list[mid])
         high = mid - 1;
      else if (key > list[mid])
         low = mid + 1;
      else
         return (1);
   }
   return (0);
}

int swapb (from, to)			/* swap adjacent bytes */
register char *from, *to;
{
   register char temp;
   temp = *from++;
   *to++ = *from;
   *to = temp;
}
