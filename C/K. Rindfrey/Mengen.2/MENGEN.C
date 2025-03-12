/*----------------------------------------------------------------*/
/* 												Mengen-Bibliothek       								*/
/*																																*//* 									 		 Autor:  K. Rindfrey  										*//* 									(c) 1992 Maxon Computer GmbH									*/
/*----------------------------------------------------------------*/

#include  <stdio.h>
#include	<tos.h>
#include  "m_typ.h"

#define BPI  16   /* Bits pro int . */

/* Zwei Makros zum Ansprechen eines Elements e: */

#define BSINDEX(e)   ((e) / BPI)
/* Liefert den Index fuer bitset[] .        */

#define ELEMMASK(e)   (0x01 << ((e) % BPI))
/* Zum Maskieren des e repraesentierenden
 *  Bits in bitset[BSINDEX(e)] .            */

BitSetDefType *bs_newsettype(mine, maxe)
 int mine, maxe;
/*
 * Liefert Zeiger auf neuen Mengentyp mit mine als kleinst
 * moeglichem und maxe als groesst moeglichem Element.
 * Sinnvoll nur, wenn mine < maxe ( wird nicht geprueft ).  */
{
   BitSetDefType *bsdp;     /* Zeiger auf Mengentyp. */
   unsigned msk = 0, card;  /* Maske, Kardinalitaet. */

   bsdp = (BitSetDefType *) Malloc((long)sizeof(BitSetDefType));
   if(bsdp == NULL) return(NULL);
   card = maxe - mine + 1;     /*  Max. Kardinalitaet .    */
   bsdp->arrlen = card / BPI;  /*  Laenge von bitset[] .   */
   if(card % BPI != 0){        /* Kardinalitaet kein Viel- */
      (bsdp->arrlen)++;        /* faches von BPI --> Maske */
      msk = (0x01 << card % BPI) - 1; /* Maske berechnen . */
   }
   bsdp->maxcard = card;
   bsdp->minelem = mine;
   bsdp->maxelem = maxe;
   bsdp->mask = msk;
   return(bsdp);
}

BitSetType *bs_createset(bsd)
 BitSetDefType *bsd;
/*
 * Erzeugt neue, leere Menge vom Typ *bsd.
 * Rueckgabe : Zeiger auf die Menge.          */
{
   BitSetType *bset;      /* Zeiger auf Menge.    */
   register unsigned *ip, /* Zeiger auf bitset[]. */
                      i;  /* Schleifenzaehler.    */
   long s;               /* Speichergroesse.     */

   s = sizeof(BitSetType) + (bsd->arrlen * sizeof(int));
   bset = (BitSetType *) Malloc(s);
   ip = bset->bitset;
   for(i = 0; i < bsd->arrlen; i++)
      *ip++ = 0;        /* Alles = 0 --> leere Menge. */
   bset->bsdef = bsd;   /* Zeiger auf Mengendefinition. */
   return(bset);
}

int bs_2setop(bs1, bs2, erg, opid)
 BitSetType *bs1, *bs2, *erg;
 BS_OpId opid; /* Gewuenschte Operation. */
/*
 * Fuehrt Mengenoperation mit 2 Operanden aus :
 *    *bs1 <opid> *bs2 --> *erg .
 * Die drei Mengentypen muessen gleich sein. Rueckgabe
 * FALSE, falls falsche Mengentypen, sonst TRUE.   */ 
{
   BitSetDefType *bsd;    /* Zeiger auf Mengentyp . */
   register unsigned *ip1, *ip2, *ipe,/* Zeiger auf bitsets. */
                      i;  /* Schleifenzaehler.      */

   bsd = bs1->bsdef;
   if((bsd != bs2->bsdef) || (bsd != erg->bsdef))
      return(FALSE); /* -->  Typen stimmen nicht ueberein ! */
   else{
      ip1 = bs1->bitset;  /* Zeiger auf die bitsets. */
      ip2 = bs2->bitset;
      ipe = erg->bitset;
      switch(opid){
         case BS_UNION :       /* Vereinigungsmenge. */
            for(i = 0; i < bsd->arrlen; i++)
                *ipe++ = *ip1++ | *ip2++;
            return(TRUE);
         case BS_INTERSECT :   /* Schnittmenge.      */
            for(i = 0; i < bsd->arrlen; i++)
                *ipe++ = *ip1++ & *ip2++;
            return(TRUE);
         case BS_DIFFERENCE :  /* Differenzmenge.    */
            for(i = 0; i < bsd->arrlen; i++)
                *ipe++ = *ip1++ & ~(*ip2++);
            return(TRUE);
      }
   }
   return(FALSE);
}

static int wbitcount(w)
 register unsigned w;
/*
 * Zaehlt die in w gesetzten Bits. */
{
   register int i,         /* Schleifenzaehler. */
               count = 0;  /* Zaehlt die Bits.  */

   for(i = 0; i < BPI; i++){
      if((w & 0x01) != 0)/* Bit 0 in w gesetzt ? */
          count++;       /* Dann Zaehler erhoehen. */
      w >>= 1;           /* w nach rechts shiften. */
   }
   return(count);
}

int bs_1setop(bsp, opid)
 BitSetType *bsp;
 BS_OpId opid; /* Gewuenschte Operation */
/*
 * Fuehrt Mengenoperationen mit 1 Operanden (bsp) aus.    */
{
   register unsigned i,         /* Schleifenzaehler.   */
                    *ip,        /* Zeigt auf bitset[]. */
                     count = 0; /* Fuer Kardinalitaet. */

	static int wbitcount(register unsigned w);
	
	
   ip = bsp->bitset;
   switch(opid){
      case BS_CARDINAL :   /* Kardinalitaet berechnen. */
         for(i = 0; i < (bsp->bsdef->arrlen); i++)
            count += wbitcount(*ip++);
         return((int)count);
      case BS_COMPLEMENT :  /* Komplement berechnen. */
         for(i = 0; i < (bsp->bsdef->arrlen) - 1; i++){
            *ip = ~(*ip);
            ip++;
         }
         *ip = ~(*ip) & (bsp->bsdef->mask); /* !! Maskieren !! */
         return(TRUE);
   }
   return(FALSE);
}

int bs_elemop(e, bsp, opid)
 int e;
 BitSetType *bsp;
 BS_OpId opid; /* Gewuenschte Operation. */
/*
 * Fuehrt Operationen mit einem Element e und einer
 * Menge (bsp) als Operanden durch.                    */
{
   register BitSetDefType *bsdp;

   bsdp = bsp->bsdef;
   e -= bsdp->minelem;
   if((e < 0) || (e > bsdp->maxcard))
      return(FALSE);
   else{
      switch(opid){
         case BS_INCLUDE :  /* Element einfuegen.   */
            (bsp->bitset[BSINDEX(e)]) |= ELEMMASK(e);
            return(TRUE);
         case BS_EXCLUDE :  /* Element entfernen.   */
            (bsp->bitset[BSINDEX(e)]) &= ~ELEMMASK(e);
            return(TRUE);
         case BS_ISELEMENT : /* Pruefe Element-von. */
            if((ELEMMASK(e) & (bsp->bitset[BSINDEX(e)])) != 0)
                 return(TRUE);
            else return(FALSE);
      }
   }
   return(FALSE);
}

int bs_cmpset(bs1, bs2, opid)
 BitSetType *bs1, *bs2; /* Operanden. */
 BS_OpId opid; /* Gewuenschte Operation. */
/*
 * Fuert Vergleichsoperationen aus.   */
{
   register unsigned i,        /* Schleifenzaehler.    */
                   *ip1, *ip2; /* Zeiger auf bitset[]. */
   register BitSetDefType *bsdp;/* Zeiger auf Mengendef. */

   if((bsdp = bs1->bsdef) != bs2->bsdef)
      return(FALSE);
   else{
         ip1 = bs1->bitset;
         ip2 = bs2->bitset;
         switch(opid){
            case BS_ISSUBSET : /* Pruefe Teilmenge.  */
               for(i = 0; i < bsdp->arrlen; i++)
                  if((*ip1++ & ~(*ip2++)) != 0)
                     return(FALSE);
               return(TRUE);
            case BS_ISEQUAL :  /* Pruefe Gleichheit. */
               for(i = 0; i < bsdp->arrlen; i++)
                  if(*ip1++ != *ip2++) return(FALSE);
               return(TRUE);
         }
      }
      return(FALSE);
}

unsigned bs_maxcard(bs)
 BitSetType *bs;
/*
 * Liefert maximale Kardinalitaet.       */
{
   return(bs->bsdef->maxcard);
}

