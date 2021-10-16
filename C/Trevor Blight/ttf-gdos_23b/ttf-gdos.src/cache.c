/***** (C) 1998-2021 Trevor Blight ****************
*
*  $Id: cache.c 1.2 2001/03/23 22:09:52 tbb Exp $
*
*
* This file is part of ttf-gdos.
*
* ttf-gdos is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
***********************************************
*
* this is the cache manager
*
* public functions:
*
* install_cache( size )
* remove_cache()
* void find_mem( size, &pointer )
* use_mem( pointer )
*
* The cache is a series of blocks consisting of header & data areas
* each data area may be free or contain user data.
* each block belongs to 2 double linked lists ...
*   - a memory list
*   - a least recently used (lru) list or a free list
* The memory list simply links the blocks in the order they are stored in
* memory.  This list is needed for merging or splitting the blocks.
* the lru list links blocks containing user data in lru order.
* the free list links free blocks in size order.
*
* A client requests cache memory, and receives a pointer to the allocated
* cache data area.  The cache may move or remove this data area and the
* pointer will be updated accordingly.
* (SO DON'T KEEP MORE THAN ONE POINTER TO YOUR CACHED DATA, ONLY THE MASTER CAN BE
*  GUARANTEED CORRECT)
* To satisfy a request for cache memory, it may be necessary remove old blocks,
* and/or shuffle blocks down to coalesce free blocks.
* Whenever a block is freed, it is merged with adjoining free blocks.
*
*************************************/

#include <stddef.h>

#define DSHOW 1

#ifdef TEST
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

typedef char            int8;
typedef unsigned char   uint8;
typedef short           int16;
typedef unsigned short  uint16;
typedef long            int32;
typedef unsigned long   uint32;

#if D_SHOW
#define dprintf(s) printf s
#else
#define dprintf(s)
#endif
#define MEMSIZE 10000
#define MemAvail() (MEMSIZE*4)
#define hi_malloc(x) malloc(x)
#else
#include <osbind.h>
#include "ttf-gdos.h"
#include "ttf-defs.h"
#endif

/**********************************************/

#define ISDATA(p) ((p)->pbase != NULL )
#define ISFREE(p) ((p)->pbase == NULL )

typedef struct tMemHdr {
   #ifndef NDEBUG
   uint32 magic;
   #endif
   uint32 size;
   void  **pbase;
   struct tMemHdr *next_mem;
   struct tMemHdr *prev_mem;
   struct tMemHdr *next_list;
   struct tMemHdr *prev_list;
   uint32 data[0];
} tMemHdr;

static tMemHdr *head_data;	/* data list, oldest is at head of chain */
static tMemHdr *tail_data;	/* pointer to youngest data */
static tMemHdr *head_free;	/* free list, in order of decreasing size */
static tMemHdr *head_mem = NULL;	/* memory list */

static uint16 nr_blocks;
static uint32 total_used;
static uint32 total_free;
static uint32 total_size;

#ifdef TEST
static long conc = 0;
static long merged_prev = 0;
static long merged_next = 0;
#endif

#ifndef NDEBUG

#define MAGIC 0xAF8092C3

/**************************************
* functions to check block and cache for consistency
* return 1 if OK, 0 if failure found
*/
static int check_block( tMemHdr *t )
{
int result = 1;
   if( t == NULL ) {
      dprintf(( "memory block is NULL\n" ));
      return head_mem == NULL;
   } /* if */

   if( t->magic != MAGIC ) {
      dprintf(("memory block(%ld) has no magic number\n", (long)t->data[0] ));
      result = 0;
   } /* if */
   if( (t->size & 3) != 0 ) {
      dprintf(("memory block(%ld) size is %ld, sb exact nr longs\n", (long)t->data[0], (long)t->size ));
      result = 0;
   } /* if */
   if( t->size > total_size ) {
      dprintf(("memory block(%ld) size is out of range (%ld)\n", (long)t->data[0], (long)t->size ));
      result = 0;
   } /* if */
   if( t->next_mem != NULL && t->next_mem < t + 1 ){
      dprintf(("memory block(%ld) next mem is wrong\n", (long)t->data[0] ));
      result = 0;
   } /* if */
   if( t->prev_mem != NULL && t->prev_mem >= t ){
      dprintf(("memory block(%ld) prev mem is wrong\n", (long)t->data[0] ));
      result = 0;
   } /* if */
   if( t->next_mem != NULL && (uint32)t->data + t->size != (uint32)t->next_mem ){
      dprintf(("memory block(%ld) size and next are inconsistent\n", (long)t->data[0] ));
      result = 0;
   } /* if */
#if 0
//   if( t->next_mem != NULL && t->next_mem->prev_mem != t) {
//      dprintf(("memory block(%ld) next doesn't link back\n", (long)t->data[0] ));
//   } /* if */
//   if( t->prev_mem != NULL && t->next_mem->prev_mem != t) {
//      dprintf(("memory block(%ld) prev doesn't link back\n", (long)t->data[0] ));
//   } /* if */
#endif
   if( ISDATA(t) ) {
      if( t->next_list == NULL && t != tail_data ) {
         dprintf(("memory block(%ld) is at end of data list, but doesn't match tail_data\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_list == NULL && t != head_data ) {
         dprintf(("memory block(%ld) is at head of data list, but doesn't match head_data\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( *t->pbase == NULL ) {
         dprintf(("memory block(%ld) contains data, but *pbase is NULL\n", (long)t->data[0] ));
         result = 0;
      } /* if */
   }
   else {
      if( (t->next_mem != NULL) && ISFREE(t->next_mem) ) {
         dprintf(("memory block(%ld) is free and so is next block\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( (t->prev_mem != NULL) && ISFREE(t->prev_mem) ) {
         dprintf(("memory block(%ld) is free and so is prev block\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( (t->prev_list != NULL) && (t->size > t->prev_list->size) ) {
         dprintf(("memory block(%ld) is larger than next in free list\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( (t->next_list != NULL) && (t->size < t->next_list->size) ) {
         dprintf(("memory block(%ld) is smaller than prev in free list\n", (long)t->data[0] ));
         result = 0;
      } /* if */
   } /* if */
   return result;
} /* check_block() */


static int check_cache( void )
{
int result = 1;
uint16 nd, nd1;
uint16 nf, nf1;
uint32 tf, tf1;
uint32 td, td1;
tMemHdr *t;

   /** run thru mem list ... */
   nd1= nf1 = 0;
   tf1 = td1 = 0;
   t = head_mem;
   if( t == NULL ) {
      dprintf(( "head_mem is NULL!!, cache doesn't exist\n" ));
      return 1;
   } /* if */

   while( t != NULL ) {
      if( check_block(t) == 0 ) result = 0;
      if( ISDATA(t) ) {
         nd1++;
         td1 += t->size;
      }
      else {
         nf1++;
         tf1 += t->size;
      } /* if */
      t->magic = 0;
      if( t->next_mem != NULL && (uint32)(t+1) + t->size != (uint32)t->next_mem  ) {
         dprintf(( "memory block(%ld) & next are not contiguous\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_mem != NULL && (uint32)(t->prev_mem+1) + t->prev_mem->size != (uint32)t ) {
         dprintf(( "memory block(%ld) & prev are not contiguous\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->next_mem != NULL && t->next_mem->prev_mem != t) {
         dprintf(( "memory block(%ld) next doesn't link back\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_mem != NULL && t->prev_mem->next_mem != t) {
         dprintf(( "memory block(%ld) prev doesn't link back\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->next_mem == NULL && (uint32)(t+1) + t->size != (uint32)(head_mem+1) + total_size ) {
         dprintf(( "last memory block(%ld) in wrong place\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      t = t->next_mem;
   } /* while */
   if( nd1 + nf1 != nr_blocks ) {
      dprintf(( "nr_blocks count is %d, counted %d\n", nr_blocks, nd1+nf1 ));
      result = 0;
   } /* if */
   if( tf1 != total_free ) {
      dprintf(( "total_free is %ld, counted %ld\n", total_free, tf1 ));
      result = 0;
   } /* if */

   /** run thru free list ... */
   nf = 0;
   tf = 0;
   t = head_free;
   while( t != NULL ) {
      nf++;
      tf += t->size;
      if( t->magic != 0 ) {
         dprintf(( "memory block(%ld) in free list, not in mem list\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      t->magic = MAGIC;
      if( !ISFREE(t) ) {
         dprintf(( "free memory block(%ld) marked as data\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->next_list != NULL && t->next_list->size > t->size ) {
         dprintf(( "free memory block(%ld) smaller than next\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_list != NULL && t->prev_list->size < t->size ) {
         dprintf(( "free memory block(%ld) larger than prev\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_list != NULL && t->prev_list->next_list != t ) {
         dprintf(( "free memory block(%ld) doesn't link back\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->next_list != NULL && t->next_list->prev_list != t ) {
         dprintf(( "free memory block(%ld) doesn't link forward\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      t = t->next_list;
   } /* while */
   if( nf != nf1 ) {
      dprintf(( "miscounted free blocks, mem chain ==> %d, free list ==> %d\n", nf1, nf ));
      result = 0;
   } /* if */
   if( tf != tf1 ) {
      dprintf(( "miscounted free mem, mem chain ==> %ld, free list ==> %ld\n", tf1, tf ));
      result = 0;
   } /* if */
   if( tf != total_free ) {
      dprintf(( "total_free is %ld, counted %ld\n", total_free, tf ));
      result = 0;
   } /* if */

   /** run thru data list ... */
   nd = 0;
   td = 0;
   t = head_data;
   if( (head_data == NULL) != (tail_data == NULL) ) {
      dprintf(( "head_data & tail_data disagree\n" ));
      result = 0;
   } /* if */
   while( t != NULL ) {
      nd++;
      td += t->size;
      if( t->magic != 0 ) {
         dprintf(( "memory block(%ld) in data list, not in mem list\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      t->magic = MAGIC;
      if( ISFREE(t) ) {
         dprintf(( "data memory block(%ld) marked as free\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_list == NULL && t != head_data ) {
         dprintf(( "block(%ld) with null prev link not at head\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->next_list == NULL && t != tail_data ) {
         dprintf(( "block(%ld) with null next link not at tail\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->prev_list != NULL && t->prev_list->next_list != t ) {
         dprintf(( "data memory block(%ld) doesn't link back\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( t->next_list != NULL && t->next_list->prev_list != t ) {
         dprintf(( "data memory block(%ld) doesn't link forward\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      if( *t->pbase != t->data ) {
         dprintf(( "base block(%ld) doesn't link to data\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      t = t->next_list;
   } /* while */
   if( nd != nd1 ) {
      dprintf(( "miscounted data blocks, mem chain ==> %d, free list ==> %d\n", nd1, nd ));
      result = 0;
   } /* if */
   if( td != td1 ) {
      dprintf(( "miscounted data mem, mem chain ==> %ld, free list ==> %ld\n", td1, td ));
      result = 0;
   } /* if */
   if( td != total_used ) {
      dprintf(( "total_used is %ld, counted %ld\n", total_used, td ));
      result = 0;
   } /* if */

   if( nd+nf != nr_blocks ) {
      dprintf(( "lost blocks, nr blocks is %d, nd is %d, nf is %d\n", nr_blocks, nd, nf ));
      result = 0;
   } /* if */

   t = head_mem;
   while( t != NULL ) {
      if( t->magic != MAGIC ) {
         dprintf(( "memory block(%ld) is lost\n", (long)t->data[0] ));
         result = 0;
      } /* if */
      t = t->next_mem;
   } /* while */

   return result;

} /* check_cache() */
#endif NDEBUG


/***************************************
* install the cache memory
* the largest available memory block must be size bytes
* return actual amount of memory available,
* ie size of largest available block
*/
uint32 install_cache( uint32 size )
{
register uint32 s = size;
uint32   a = MemAvail();	/* available memory */

   assert( head_mem == NULL );	/* must not already be installed !! */

   /* restrict size to range 60k .. (mem available - 60k) */
   if( s == 0 ) s = a/4;	/* default value */
   if( s < 60000 ) s = 60000;	/* min size */
   if( 60000+s > a ) s = a/2;	/* too big ==> use 50% available memory */

   s = ((s+3)&~3)+sizeof(tMemHdr);	/* round up to exact number of longs */
   assert( (sizeof(tMemHdr)&3) == 0 );	/* exact nr longs */

   head_free = head_mem = (tMemHdr*)hi_malloc( s );

   if( head_mem == NULL ) {
      /* pathological case ... */
      nr_blocks = 0;
      total_size = 0;
   }
   else {
      total_size = head_mem->size = s - sizeof(tMemHdr);
      #ifndef NDEBUG
      head_free->magic = MAGIC;
      head_free->data[0] = -1;
      #endif
      head_free->pbase = NULL;
      head_free->next_mem = NULL;
      head_free->prev_mem = NULL;
      head_free->next_list = NULL;
      head_free->prev_list = NULL;
      head_data = tail_data = NULL;
      nr_blocks = 1;
   } /* if */

   total_used = 0;
   total_free = total_size;

   assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );
   assert( check_block(head_free) );
   assert( check_cache() );

   return total_size;

} /* install_cache() */


/******************************
* remove an installed cache
* all application pointers to memory blocks 
* must be set to NULL to mark memory blocks as released
*/
void remove_cache( void )
{
   if( head_mem != NULL ) {
   register tMemHdr *tr;
      /** mark all application pointers free **/
      for( tr=head_data; tr!=NULL; tr=tr->next_list ) {
         *tr->pbase = NULL;       /* tell application this block has been released */
      } /* for */
      free( head_mem );
      head_mem = NULL;
   } /* if */
   total_size = 0;
} /* remove_cache() */


/******************************************
* refresh a block of memory by moving it to the tail of the data chain
* called by user to refresh a block of memory
* NB: p0 is pointer to the data, need to find pointer to MemHdr first
*/
void use_mem( void *const p0 )
{
register tMemHdr *const p = ((tMemHdr*)( (uint32)p0 - offsetof(tMemHdr, data) )); /* <<< size_t */
register tMemHdr *t0 = p->prev_list;
register tMemHdr *t1 = p->next_list;

   assert( head_mem != NULL );	/* there must be a cache !! */

   assert( p->magic == MAGIC );
   assert( check_block(p) );
   assert( ISDATA(p) );

   assert( head_data != NULL );
   assert( tail_data != NULL );
   assert( t1 != NULL || p == tail_data );
   assert( t0 != NULL || p == head_data );

   if( t1 != NULL ) {

      /** not already at the end, remove block from chain **/

      assert( head_data->next_list != NULL );	/* must be at least 2 blocks - this one & the one at the end */

      t1->prev_list = t0;
      if( t0 != NULL ) {
         t0->next_list = t1;
      }
      else {
         head_data = t1;
      } /* if */

      /** append p to current end of data chain */
      p->prev_list = tail_data;
      tail_data->next_list = p;
      p->next_list = NULL;
      tail_data = p;

   } /* if */

   assert( check_cache() );
   assert( tail_data->data == p0 );

} /* use_mem() */


/****************************
* add block to free list
* check_block() is called when block added to free list
*/
static void add_free( tMemHdr *const tr )
{
register tMemHdr *t0;
register tMemHdr *t1;

   assert( tr != NULL );
   assert( tr->magic == MAGIC );
   assert( ISFREE(tr) );

   /** find where to put tr into free list **/

   t0 = NULL;
   t1 = head_free;
   while( t1 != NULL && t1->size > tr->size ) {
      assert( t1->next_list == NULL || t1->next_list->prev_list == t1 );
      assert( t1->prev_list == t0 );
      t0 = t1;
      t1 = t1->next_list;
      assert( t0 != NULL );
   } /* while */

   tr->next_list = t1;
   tr->prev_list = t0;
   if( t1 != NULL ) {
      t1->prev_list = tr;
   } /* if */
   if( t0 == NULL ) {
      /* the free list is empty, or this is the largest block */
      head_free = tr;
   }
   else {
      t0->next_list = tr;
   } /* if */

   assert( head_free != NULL );
   assert( t1 == NULL || t1->next_list == NULL || t1->next_list->prev_list == t1 );
   assert( t1 == NULL || t1->prev_list == NULL || t1->prev_list->next_list == t1 );
   assert( tr->next_list == NULL || tr->next_list->prev_list == tr );
   assert( tr->prev_list == NULL || tr->prev_list->next_list == tr );
   assert( check_block( tr ) );

} /* add_free() */


/****************************
* remove block from free list
* the block might still be under construction, so no check_block()
*/
static void rem_free( tMemHdr *const tr )
{
register tMemHdr *t0 = tr->prev_list;
register tMemHdr *t1 = tr->next_list;

   assert( head_mem != NULL );	/* the cache exists */ 
   assert( tr->magic == MAGIC );
   assert( ISFREE(tr) );
   assert( tr->next_mem == NULL || tr->next_mem->prev_mem == tr);
   assert( tr->prev_mem == NULL || tr->prev_mem->next_mem == tr);

   if( t1 != NULL ) {
      assert( tr->size >= t1->size );	/* decreasing size */
      t1->prev_list = t0;
   } /* if */
   if( t0 != NULL ) {
      assert( tr->size <= t0->size );	/* decreasing size */
      t0->next_list = t1;
   }
   else {
      head_free = t1;
   } /* if */

   assert( tr->next_mem == NULL || tr->next_mem->prev_mem == tr);
   assert( tr->prev_mem == NULL || tr->prev_mem->next_mem == tr);

} /* rem_free() */


/*************************************************************
* move a block of memory from the data chain to the free chain
* merge with next & previous blocks if possible
*/
static void release_block( register tMemHdr *tr )
{
register tMemHdr *t0;
register tMemHdr *t1;
   assert( tr == NULL || tr->next_mem == NULL || tr->next_mem->prev_mem == tr );
   assert( tr == NULL || tr->prev_mem == NULL || tr->prev_mem->next_mem == tr );
   assert( tr == NULL || tr->next_list == NULL || tr->next_list->prev_list == tr );
   assert( tr == NULL || tr->prev_list == NULL || tr->prev_list->next_list == tr );
   assert( check_block(tr) );
   assert( ISDATA(tr) );
   total_free += tr->size;
   total_used -= tr->size;
   *tr->pbase = NULL;       /* tell application this block has been released */
   tr->pbase = NULL;        /* flag this block as free */
   t0 = tr->prev_list;
   t1 = tr->next_list;
   if( t0 == NULL ) {
      head_data = t1;
   }
   else {
      t0->next_list = t1;
   } /* if */
   if( t1 == NULL ) {
      tail_data = t0;
   }
   else {
      t1->prev_list = t0;
   } /* if */

   /** block removed from data chain, now try merge with next, previous **/

   t1 = tr->next_mem;
   if( t1 != NULL && ISFREE(t1) ) {

      /** we can absorb the next mem block **/
      #ifdef TEST
      merged_next++;
      dprintf(( "merging block(%ld, size %ld) & following(%ld, size %ld)\n", (long)tr->data[0], (long)tr->size, (long)tr->next_mem->data[0], (long)tr->next_mem->size ));
      #endif

      rem_free( t1 );    /** remove next from free list **/

      /** remove tr->next_mem from memory list **/
      tr->size += t1->size + sizeof(tMemHdr);
      tr->next_mem = t0 = t1->next_mem;
      if( t0 != NULL ) {
         t0->prev_mem = tr;
      } /* if */

      assert( tr->next_mem == NULL || tr->next_mem->prev_mem == tr );
      assert( tr->next_mem == NULL || (uint32)tr + sizeof(tMemHdr) + tr->size == (uint32)tr->next_mem );

      dprintf(( "size of merged block is %ld\n", (long)tr->size ));
      total_free += sizeof( tMemHdr );
      nr_blocks--;
   } /* if */
   assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );

   t0 = tr->prev_mem;
   if( t0 != NULL && ISFREE(t0) ) {

      /** we can merge into the prev mem block **/

      #ifdef TEST
      dprintf(( "merging block(%ld, size %ld) & previous(%ld, size %ld)\n", (long)tr->data[0], (long)tr->size, (long)tr->prev_mem->data[0], (long)tr->prev_mem->size ));
      merged_prev++;
      #endif

      rem_free( t0 );     /** remove prev from free list **/

      /** remove tr from memory list **/
      t1 = t0->next_mem = tr->next_mem;
      if( t1 != NULL ) {
         t1->prev_mem = t0;
      } /* if */
      assert( t0->next_mem == NULL || t0->next_mem->prev_mem == t0 );
      assert( t1 == NULL || t1->prev_mem->next_mem == t1 );

      t0->size += tr->size + sizeof( tMemHdr );
      total_free += sizeof( tMemHdr );
      nr_blocks--;

      tr = t0;	/* tr is adr of merged block */
      dprintf(( "size of merged block is %ld\n", (long)tr->size ));
      assert( tr->next_mem == NULL || (uint32)tr + sizeof(tMemHdr) + tr->size == (uint32)tr->next_mem );
      assert( tr->next_mem == NULL || tr->next_mem->prev_mem == tr);
   } /* if */

   assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );

   add_free( tr );
   assert( check_cache() );
} /* release_block() */


/******************************************
* release a block of memory by removing it from the data chain
* called by user
* NB: p0 is pointer to the data, need to find pointer to MemHdr first
*/
void release_mem( void *const p0 )
{
register tMemHdr *const p = ((tMemHdr*)( (uint32)p0 - offsetof(tMemHdr, data) )); /* <<< size_t */

   assert( head_mem != NULL );	/* there must be a cache !! */
   assert( p->magic == MAGIC );	/* must be a valid block */
   assert( ISDATA(p) );          /* must be a data block */
   assert( head_data != NULL );  /* data chain can't be empty */
   assert( tail_data != NULL );
   assert( p->next_list != NULL || p == tail_data );
   assert( p->prev_list != NULL || p == head_data );
   assert( check_block(p) );

   release_block( p );

} /* release_mem() */


/*********************************************
* create new block of requested size by removing oldest memory blocks
* block contents are not initialised
* size is rounded up to exact nr longs
* base for removed blocks is set to NULL
* *pbase := adr of block, 
*       or null if cache is unable to supply enough memory
* return null
*/
void find_mem( uint32 rq_size, void **const base )
{
register tMemHdr *tr;
register tMemHdr *t0;
register tMemHdr *t1;

   assert( head_mem != NULL );	/* there must be a cache !! */
   assert( base != NULL );

   assert( rq_size <= ((rq_size+3)&~3) );
   assert( rq_size+4 > ((rq_size+3)&~3) );
   rq_size = (rq_size+3)&~3;

   if(( rq_size > total_size) ) {
      /* request fails - it is too large for cache */
      dprintf(( "requested mem (%ld) larger than cache size (%ld)\n", rq_size, total_size ));
      *base = NULL;
      return;
   } /* if */

   /** loop to remove old data until there is enough free space for current request **/

   dprintf(( "rq_size is %ld\n", (long)rq_size ));
   assert( head_free != NULL || total_free == 0 );

   /* note the special case when total free == 0 (so head_free == NULL)
   ** and rq_size is 0. */

   while( rq_size > total_free || total_free == 0 ) {

      dprintf(("need to remove lru data block(%ld), size (%ld)\n", (long)head_data->data[0], (long)head_data->size ));
      assert( head_data != NULL || rq_size <= total_free );
      assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );

      assert( head_data->prev_list == NULL );
      release_block( head_data );      /* remove lru data block */

      assert( head_data != NULL || rq_size <= total_free );
      assert( head_data != NULL || total_used == 0 );
      assert( head_data == NULL || head_data->prev_list == NULL);

   } /* while */

   assert( total_free >= rq_size );
   assert( head_free != NULL );

   /**********************************************************
   * there is now enough space in the cache to fulfil the request
   * but it may need to be gathered together into one block
   * move all data blocks down to the start of the cache 
   * this leaves one free block at the end of the cache
   **********************************************************/

   if( head_free->size < rq_size ) {
   register uint32 *free_p;	/** free space pointer **/

      /* the memory is fragmented, so move all data down memory
      ** to concentrate the free mem into one block at the end
      ** note: fragmented ==> at least one data block & 2 free blocks */

      #ifdef TEST
      conc++;
      dprintf(( "concentrating data...(this is the %ldth time)\n", conc ));
      #endif

      assert( head_data != NULL );

      t1 = head_mem;
      while( ISDATA(t1) ) {
         assert( check_block(t1) );
         assert( t1->next_mem != NULL );	/* there are at least two free blocks following */
         t1 = t1->next_mem;
      } /* while */

      assert( ISFREE(t1) );

      free_p = (uint32*)t1;   		/* the first free area */
      t0 = t1->prev_mem;	   /* the last data block so far, or NULL */
      assert( t0 == NULL || check_block(t0) );
      assert( t0 == NULL || ISDATA(t0) );
      assert( t0 == NULL || (uint32*)free_p == (uint32*)(t0->next_mem) );

      /** loop to copy data blocks down
      **  t1 scans thru mem blocks,
      **  t0 follows one behind, it is the latest concentrated block
      **/
      do {
         assert( t1->magic == MAGIC ); /* t1->prev?? may have been overwritten */
         if( ISDATA(t1) ) {
         register int32 i = t1->size + sizeof(tMemHdr); /* nr bytes to move */
         register uint32 *s1 = (uint32*)t1;             /* src address */

            /**** 
            ** move data block at t1 down to free_p, 
            ** adjust t0 = new conc'd data block, adjust t1
            *****/

            assert( t0 == NULL || (uint32*)free_p == (uint32*)(t0->next_mem) );

            tr = (tMemHdr*) free_p;  /* relocate block pointer */
            assert( tr != NULL );
            assert( tr < t1 );	/* there is a gap between end of t0 & start of t1 */
            t1 = t1->next_mem;	/* data at t1 will be overwritten if data size > gap too free_p */

            assert( (i&3) == 0 );	/* data & header both exact nr longs */
            i >>= 2; /* nr longs */
            while( --i >= 0 ) {	/* copy header & data of block */
               *free_p++ = *s1++;
            } /* if */

            /* note: free_p now points to new free area, at end of tr */

            assert( (uint32)tr->data + tr->size == (uint32)free_p );

            *tr->pbase = tr->data;
            tr->next_mem = (tMemHdr*)free_p;	/* adjust links */
            tr->prev_mem = t0;
            assert( (t0 == NULL && tr == head_mem) || t0->next_mem == tr );
            if( tr->next_list != NULL ) {
               tr->next_list->prev_list = tr;
            }
            else {
               tail_data = tr;
            } /* if */
            if( tr->prev_list != NULL ) {
               tr->prev_list->next_list = tr;
            }
            else {
               head_data = tr;
            } /* if */

            t0 = tr;
            assert( ISDATA(t0) );
            assert( check_block(t0) );
            assert( t0->prev_mem == NULL || t0->prev_mem->next_mem == t0);
         }
         else {
            nr_blocks--;   /* removed a free block */
            total_free += sizeof(tMemHdr);
            t1 = t1->next_mem;
         } /* if */
      } while( t1 != NULL );
      assert( t0 != NULL );

      /** now create one free block at the end of the cache */

      t1 = head_free = t0->next_mem;
      assert( head_free == (tMemHdr*)free_p );
      t1->next_mem = t1->next_list = t1->prev_list = NULL;
      t1->prev_mem = t0;
      total_free -= sizeof(tMemHdr);
      assert( total_free == (uint32)head_mem + total_size - (uint32)t1);
      t1->size = total_free;
      t1->pbase = NULL;
      #ifndef NDEBUG
      t1->magic = MAGIC;
      t1->data[0] = -2;
      #endif

      nr_blocks++;
      assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );
   } /* if */

   assert( head_free->size >= rq_size );
   assert( total_free >= rq_size );
   assert( head_free != NULL );
   assert( check_cache() );

   /** now find best-fit free block for rq_size **/

   tr = head_free;
   assert( tr != NULL );
   while( (t1 = tr->next_list)!=NULL && t1->size > rq_size ) {
      assert( tr->size >= t1->size );
      tr = t1;
      assert( tr != NULL );
   } /* if */

   assert( tr->size >= rq_size );
   assert( tr->next_list == NULL || tr->next_list->size <= rq_size );

   /** tr is the memory to use, remove it from the free list **/
   assert( check_block(tr) );
   rem_free( tr );
   tr->pbase = base; /* mark as data block */
   *tr->pbase = tr->data;

   /** split the memory block, unless it is too small **/
   if( tr->size > rq_size + sizeof(tMemHdr) ) {
      t1 = (tMemHdr*)((uint32)tr->data + rq_size);
      t1->prev_mem = tr;
      t1->next_mem = tr->next_mem;
      if( t1->next_mem != NULL ) t1->next_mem->prev_mem = t1;
      tr->next_mem = t1;
      t1->pbase = NULL;
      #ifndef NDEBUG
      t1->magic = MAGIC;
      #endif
      t1->size = tr->size - rq_size - sizeof(tMemHdr);
      assert( (t1->size&3) == 0 );
      tr->size = rq_size;
      total_free -= sizeof(tMemHdr);
      add_free( t1 );      /* add t1 to free list */
      assert( head_free != NULL );
      nr_blocks++;
      assert( (uint32)tr->data + tr->size == (uint32)t1 );
      assert( t1->next_mem == NULL || t1->next_mem->prev_mem == t1);
      assert( t1->prev_mem == NULL || t1->prev_mem->next_mem == t1);
   } /* if */
   assert( total_free >= tr->size );
   total_free -= tr->size;
   total_used += tr->size;

   /** append tr to data chain **/
   if( head_data == NULL ) {
      head_data = tr;
      tr->prev_list = NULL;
   }
   else {
      assert( tail_data->next_list == NULL );
      t1 = tail_data;
      t1->next_list = tr;
      tr->prev_list = t1;
   } /* if */
   tr->next_list = NULL;
   tail_data = tr;
   if( head_free == NULL && total_free != 0 ) dprintf(( "%d: head_free is NULL and total_free is %ld\n", (int)__LINE__, (long)total_free ));
   dprintf(( "base is at %p\n", tail_data->pbase ));
   assert( tail_data->data == *tail_data->pbase );
   assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );
   assert( head_free != NULL || total_free == 0 );
   assert( check_cache() );

} /* find_mem() */


#ifdef TEST /* ................................................ */

#define NRDATA 100
#define MAXI   10000L

struct {
   uint32 *p;
   long  s;
} mem[NRDATA];

int main( void )
{
long i, i1;
int a;

   for( i=0; i<NRDATA; i++ ) {
      mem[i].p = NULL;
      mem[i].s = -1;
   } /* if */

   i = MAXI;   
   srand(1);
   printf( "starting up ..." );
   printf( "installed cache size is %ld\n", install_cache( MEMSIZE ) );
   assert( head_data == NULL );
   printf( "done, total free is %ld\n generate & use blocks ...\n", (long)total_free );
   while( i-- > 0 ) {
   int all_data = 1;
      a = (int)(i%NRDATA);
      if( mem[a].p == NULL ) {                            
         int r = rand();
         find_mem( (mem[a].s = ((long)MEMSIZE/2)*r/RAND_MAX*r/RAND_MAX), &(mem[a].p) );
         if( mem[a].p == NULL ) {
         	printf( "couldn't find mem (%ld bytes)\n", mem[a].s );
         }
         else {
/*         	printf( "base is at %p, mem is at %p\n", tail_data->pbase, &mem[a].p ); */
         } /* if */
         assert( mem[a].p == NULL || tail_data->pbase == &mem[a].p );
         assert( mem[a].p == NULL || tail_data->data == mem[a].p );
         all_data = 0;
      } /* if */
/*      assert( check_block(mem[a].p) ); */
      assert( total_free + total_used + (nr_blocks-1)*sizeof(tMemHdr) == total_size );
/*      assert( ISDATA(mem[a].p) ); */
/*      assert( &mem[a].p == mem[a].p->pbase ); */
      if( mem[a].p != NULL ) {
      	memset( mem[a].p, (char)i, mem[a].s );
      	if( mem[a].s >= 4 ) mem[a].p[0] = i;
      	printf( "%ld: got new block(%ld) of size %ld, total used/free/blocks is now %ld/%ld/%d\n", (long)i, (long)mem[a].p[0], (long)mem[a].s, (long)total_used, (long)total_free, nr_blocks );
      } /* if */
      
      a = rand()%NRDATA;
      if( mem[a].p != NULL ) {
         printf( "use data(%d/%ld), size %ld\n", (int)a, (long)mem[a].p[0], (long)mem[a].s );
         /* assert( check_block(mem[a].p) ); */
         /* assert( &mem[a].p == mem[a].p->pbase ); */
         use_mem( mem[a].p );
         assert( tail_data->pbase == &mem[a].p );
         assert( tail_data->data == mem[a].p );
         assert( head_data != NULL );
         assert( check_block(tail_data) );
      } /* if */
      if( all_data ) {
         printf( "all data contained in cache\n" );
         break;
      } /* if */

      /** check all data is correct **/
      for( i1=0; i1<NRDATA; i1++ ) {
         if( mem[i1].p != NULL ) {
         long z = mem[i1].p[0];
            if( mem[i1].s >= 4 ) {
               assert( z <= MAXI );
               if( z==MAGIC ) printf( "z is MAGIC\n" );
               if( z<0 ) printf( "z is %ld\n", z );
               assert( z >= 0 );
               if( mem[i1].s > 4 ) assert( ((char*)(mem[i1].p))[mem[i1].s-1] == (char)z );
#if 0
//            }
//            else if( mem[i1].s == 0 && mem[i1].p->next_mem != NULL ) {
//               //printf( "z is %ld, \t next block(%ld, size %ld) magic is %ld\n", z, mem[i1].p->next_mem->data[0], mem[i1].p->next_mem->size, mem[i1].p->next_mem->magic );
//               assert( z == MAGIC );
#endif
            } /* if */
         } /* if */
      } /* for */
   } /* while */

   printf(  "finished\n" 
   			"%ld use iterations on cache\n"
            "cache was concentrated %ld times\n"
            "merged with previous %ld times\n"
            "merged with next %ld times\n", (long)MAXI, conc, merged_prev, merged_next );

   return 0;
   
} /* main() */
#endif

/*********** end of file ***************/


