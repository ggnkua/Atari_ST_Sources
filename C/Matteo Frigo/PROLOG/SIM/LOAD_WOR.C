/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* load_work.c */

#define DEBUG_OVERFLOW
/*
#define DEBUG_NAMESTRING
#define DEBUG_LOADWORK
*/

#include "sim.h"
#include "aux.h"
/* #include <stdio,h> */
#define ALIGN(type,ptr)  ptr = (type)(((LONG)ptr + 3) & 0xfffffffc)

/************************************************************************
*                                                                       *
*  The hash function uses the arity and character string associated     *
*  with a predicate, constant, or structure to find the proper bucket   *
*  (a bucket is a linked list within the pcs table) to insert or locate *
*  pcs entries.                                                         *
*                                                                       *
************************************************************************/

int hash(name, length, arity)  /* hashing function on name,returning a */
CHAR_PTR name;                 /* bucket number in the hash table      */
WORD     length;
BYTE     arity;
{
   int bucknum;

   bucknum = arity + 1;
   if (length > 0) {              /* first */
      bucknum = bucknum + *name;
      if (length > 1) {           /* last */
         bucknum = (bucknum << 2) + *(name + length - 1);
         if (length > 2) {        /* middle */
            bucknum = (bucknum << 2) + *(name + length / 2);
            if (length > 3)
               bucknum = (bucknum << 2) + *(name+(length / 2) - 1);
         }
      }
   }
   return abs(bucknum % BUCKET_CHAIN);

}  /* end of hash */

/******************************************************************************/

LONG_PTR search(name, length, arity, hash_ptr)
CHAR_PTR name;
BYTE     arity;
WORD     length;
LONG_PTR hash_ptr;
{
   PSC_REC_PTR psc_ptr;
   unsigned short i;
   struct booleans {
      unsigned eq   : 1;
      unsigned stop : 1;
   } flag;

   flag.eq   = FALSE;
   flag.stop = FALSE;

#ifdef  DEBUG_LOADWORK
   printf("search: name = %s   len = %d   arity = %d  ", name, length, arity);
   printf("hash = %08x\n", hash_ptr);
#endif

   while (!ISFREE(hash_ptr) && flag.stop == FALSE) {
      hash_ptr = (LONG_PTR)FOLLOW(hash_ptr);    /* pointer to pair */
      psc_ptr = (PSC_REC_PTR)FOLLOW(hash_ptr);  /* pointer to psc record */

#ifdef  DEBUG_LOADWORK
      printf("   hash_ptr  %08x   psc_ptr  %08x     *hash_ptr  %08x  \n",
             hash_ptr, psc_ptr, *hash_ptr);
#endif

      if (arity  == GET_ARITY(psc_ptr) && length == GET_LENGTH(psc_ptr)) {
         flag.eq = TRUE;
         for (i = 0; i < length && flag.eq == TRUE; i++)
            if (*(name + i) != *(GET_NAME(psc_ptr) + i))
               flag.eq = FALSE;
      }
      if (flag.eq == TRUE)
	 flag.stop = TRUE;
      else hash_ptr++;
  }

  return hash_ptr;

}  /* end of search */

/******************************************************************************/

LONG_PTR insert_temp(name, length, hash_ptr)
CHAR_PTR name;
WORD     length;
LONG_PTR hash_ptr;
{
   PSC_REC_PTR       psc_ptr;
   LONG_PTR          new_pair, stack_top, heap_top;
   register CHAR_PTR threg;
   LONG              i;

   /* check for heap overflow */
   stack_top = (breg < ereg) ? breg : ereg - ENV_SIZE(cpreg);
   heap_top  = hreg + 4 + ((length + 3) >> 2);
   if (stack_top < heap_top) {
      /* garbage_collection("insert_temp"); */
      if (stack_top < heap_top)    /* still too full */
         quit("Heap overflow\n");
   }
   new_pair = hreg++;
   FOLLOW(hash_ptr) = (LONG)new_pair;
   PUSHTRAIL((LONG)hash_ptr);         /* trail for backtracking */
   MAKE_FREE(LONG, *hreg);            /* 2nd of pair free */
   FOLLOW(new_pair) = (LONG)++hreg;   /* 1st of pair points to psc_rec */
   psc_ptr= (PSC_REC_PTR)hreg;        /* psc_ptr points to the psc entry */
   hreg += 2;                         /* reserve the space on the heap */
                                      /*   NO EP FIELD */

   /* make nameptr point to next available space on heap */

   GET_ETYPE(psc_ptr)  = T_ORDI;
   GET_ARITY(psc_ptr)  = 0;
   GET_LENGTH(psc_ptr) = length;
  /* GET_NAME(psc_ptr) = name; */

   threg = (CHAR_PTR)hreg;
   GET_NAME(psc_ptr) = threg;     /* copy name, since might write over it !! */
   for (i = 0; i < length; i++)
      *threg++ = *name++;

   hreg = (LONG_PTR)threg;
   ALIGN(LONG_PTR, hreg);

   return new_pair;

}  /* end of insert_temp */

/******************************************************************************/

LONG_PTR insert_perm(name, length, arity, hash_ptr)
CHAR_PTR name;
BYTE     arity;
WORD     length;
LONG_PTR hash_ptr;
{
   PSC_REC_PTR   psc_ptr;
   LONG_PTR      new_pair;
   register LONG i;

   ALIGN(CHAR_PTR, curr_fence);

   new_pair = (LONG_PTR)curr_fence;
   FOLLOW(hash_ptr) = (LONG)new_pair;           /* prev link to here */
   curr_fence += 4;                             /* point to 2nd of pair */
   MAKE_FREE(LONG_PTR,*(LONG_PTR *)curr_fence); /* set 2nd free */

#ifdef DEBUG_LOADWORK
   printf("insert_perm %8x %8x\n", curr_fence, *(LONG_PTR)curr_fence);
#endif

   curr_fence += 4;                             /* where we'll put psc_rec */
   FOLLOW(new_pair) = (LONG)curr_fence;         /* set 1st to pt to psc_rec */
   psc_ptr= (PSC_REC_PTR)curr_fence;            /* psc_ptr points there too */
   curr_fence += 12;                            /* 12 bytes for psc_rec */

   GET_ETYPE(psc_ptr)  = T_ORDI;
   GET_ARITY(psc_ptr)  = arity;
   GET_LENGTH(psc_ptr) = length;
   GET_NAME(psc_ptr)   = curr_fence;

   for (i = 0; i < length; i++)
      *curr_fence++ = *name++;

   ALIGN(CHAR_PTR, curr_fence);

   if (curr_fence >= max_fence) {
#ifdef DEBUG_OVERFLOW
      printf("Overflow in \"insert_perm\" curr_fence = %08x max_fence = %08x\n",
             curr_fence, max_fence);
#endif
      quit("Program area overflow\n");
   }

   return new_pair;

}  /*  end of insert_perm */

/******************************************************************************/

LONG_PTR insert(name, length, arity, perm)
CHAR_PTR name;
WORD     length;
BYTE     arity;
BYTE_PTR perm;
{
   int      bucket_no;
   LONG_PTR temp_ptr, perm_ptr, perm_hashptr, temp_hashptr, ret_ptr;

   bucket_no = hash(name, length, arity);
   perm_hashptr = (LONG_PTR)&hash_table[bucket_no][PERM];

#ifdef DEBUG_LOADWORK
   printf("insert: name = %s   len = %d   arity = %d  ", name, length, arity);
   printf("bucket = %d  perm = %08x  hash = %08x\n",
	  bucket_no, perm_hashptr, *perm_hashptr);
#endif

   perm_ptr = search(name, length, arity, perm_hashptr);
   if (!ISFREE(perm_ptr)) {   /* found perm psc record */
      if (!(*perm))
         *perm = PERM;        /* set perm flag parameter */
      return perm_ptr;        /* return permanent */
   }

   temp_hashptr = (LONG_PTR)&hash_table[bucket_no][TEMP];  /* look for temp */
   temp_ptr = search(name, length, arity, temp_hashptr);
   if (!ISFREE(temp_ptr)) {  /* found temp psc record */
      if (!(*perm))          /* temporary wanted */
         return temp_ptr;    /* return ptr to psc record */
      else {                 /* Perm wanted - convert temp to perm */
         /*printf("cvting temp to perm: %c %d %d\n", *name, length, arity);*/
         perm_ptr = insert_perm(name, length, arity, perm_ptr);
         FOLLOW(temp_ptr) = FOLLOW(perm_ptr);
         return perm_ptr;
      }
    } else {                 /* Insert constant where indicated */
      if (*perm)
         return insert_perm(name, length, arity, perm_ptr);
      else
         return insert_temp(name, length, temp_ptr);
   }
}  /* end of insert */

/************************************?????????????????????*********/

set_temp_ep(psc_ptr, ep)
PSC_REC_PTR psc_ptr;
{
   if (ep >= 0) {
      GET_ETYPE(psc_ptr) = T_TEMP_PRED;
      GET_EP(psc_ptr) = (LONG_PTR)ep;
   }
}

/************************************?????????????????????*********/

set_real_ep(psc_ptr, base)
PSC_REC_PTR psc_ptr;
CHAR_PTR    base;
{
   if (GET_ETYPE(psc_ptr) == T_TEMP_PRED) {
      GET_EP(psc_ptr) = (LONG_PTR)(base + (int)GET_EP(psc_ptr));  /*???*/
      GET_ETYPE(psc_ptr) = T_PRED;
   }
}

/************************************?????????????????????*********/

/*
set_file_ptr(psc_ptr, file_ptr)
PSC_REC_PTR psc_ptr;
FILE        *file_ptr;
{
   GET_ETYPE(psc_ptr) = T_FILE;
   GET_EP(psc_ptr) = (WORD_PTR)(file_ptr);
}
*/

/************************************?????????????????????*********/

/*
unset_file_ptr(psc_ptr)
PSC_REC_PTR psc_ptr;
{
   GET_ETYPE(psc_ptr) = T_ORDI;
   GET_EP(psc_ptr) = 0;
}
*/

/************************************?????????????????????*********/

namestring(psc_ptr, s)
PSC_REC_PTR psc_ptr;
CHAR_PTR    s;
{
   LONG     i, len;
   CHAR_PTR st;

   len = GET_LENGTH(psc_ptr);
   st  = GET_NAME(psc_ptr);

#ifdef DEBUG_NAMESTRING
   printf("namestring: len = %d    string = %s\n", len, st);
#endif
   for (i = 0; i < len; i++)
      *s++ = *st++;
   *s = '\0';
}

/************************************?????????????????????*********/

LONG alloc_perm(size)   /* size should be a multiple of 4 */
LONG size;
{
   LONG        addr;
   PSC_REC_PTR psc_ptr;

   ALIGN(CHAR_PTR, curr_fence);
   addr = (LONG)curr_fence;
   psc_ptr = (PSC_REC_PTR)(curr_fence + 4);
   *(LONG_PTR)curr_fence = (LONG)psc_ptr;  /* pt to psc record being created */
   curr_fence += 12;                       /* no ep */
   GET_ETYPE(psc_ptr)  = T_BUFF;
   GET_ARITY(psc_ptr)  = 0;
   GET_LENGTH(psc_ptr) = size;
   GET_NAME(psc_ptr)   = curr_fence;
   curr_fence += size;
   ALIGN(CHAR_PTR, curr_fence);
   if (curr_fence >= max_fence) {
#ifdef DEBUG_OVERFLOW
      printf("Overflow in \"alloc_perm\" curr_fence = %08x max_fence = %08x\n",
             curr_fence, max_fence);
#endif
      quit("Program area overflow\n");
   }
   return addr;
}  /* end of alloc_perm */
