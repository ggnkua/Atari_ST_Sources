/*
 * General-purpose memory allocator, on the MWC arena model, with
 * this added feature:
 *
 * All blocks are coalesced when they're freed.  If this results in
 * an arena with only one block, and that free, it's returned to the
 * OS.
 *
 * The functions here have the same names and bindings as the MWC
 * memory manager, which is the same as the UNIX names and bindings.
 */

/* need osbind.h for Malloc call.  MWC might not call it this */
#include <osbind.h>

#define NULL ((char *)0)

#ifdef DEBUGON
#define DEBUG(c) Cconout(c)
#else
#define DEBUG(c) /*nothing*/
#endif

/*
 * block header: every memory block has one.
 * The size field is negative (i.e. -size) if the block is allocated.
 * Zero-length blocks are free; they hold space which might get coalesced
 * usefully later on.
 */

struct block {
    struct block *b_next;	/* NULL for last guy */
    long b_size;		/* negative for allocated blocks */
};

/*
 * arena header: every arena has one.  Each arena is always completely
 * filled with blocks; the first starts right after this header.
 */

struct arena {
    struct arena *a_next;
};

/*
 * Arena linked-list pointer, and block size.  The block size is initialized
 * to Malloc(-1L)/10 when you start up, because somebody said that 10
 * Malloc blocks per process was a reasonable maximum.  This is hopelessly
 * unbalanced: 50K on a 520ST and 400K on a Mega 4, so it's tempered by
 * the constant MAXARENA (I chose 100K, same as a 1040).
 */

static struct arena *a_first = NULL;
long minarena;
#define MAXARENA (100L*1024L)

char *lmalloc(size)
register long size;
{
    register struct arena *a;
    register struct block *b;
    register long temp;

    DEBUG('A');
    /* make sure size is even; fail if it's negative zero */
    if (size <= 0) return 0;
    size = (size+1) & ~1;

    for (a = a_first; a; a = a->a_next) {
	for (b = (struct block *)(a+1); b; b = b->b_next) {
	    /* if free & big enough, use it */
	    if (b->b_size >= size) {
		goto done;
	    }
	}
    }

    /* no block available: get a new arena */

    if (!minarena) {
	minarena = Malloc(-1L) / 10;
	if (minarena > MAXARENA) minarena = MAXARENA;
    }

    if (size < minarena) {
	DEBUG('m');
	temp = minarena;
    }
    else {
	DEBUG('s');
	temp = size;
    }

    a = Malloc(temp + sizeof(struct arena) + sizeof(struct block));

    /* if Malloc failed return failure */
    if (a == 0) {
    	DEBUG('x');
    	return 0;
    }

    a->a_next = a_first;
    a_first = a;
    b = (struct block *)(a+1);
    b->b_next = 0;
    b->b_size = temp;

done:
    cut(b,b->b_size,size);
    return (char *)(b+1);
}

/*
 * cut: given a block, b, its size, osize, and the first-half size, fsize,
 * split the block (if possible) so it's an allocated block fsize bytes 
 * long, and the rest of the original block becomes a new, free block
 * which is osize-fsize-sizeof(struct block) bytes long.
 *
 * Used on initially-free blocks by lmalloc, and initially-allocated
 * blocks by lrealloc.
 */

static cut(b,osize,fsize)
register struct block *b;
register long osize;
register long fsize;
{
    register long temp;
    register struct block *nb;
    
    /* set temp to size of remainder */
    temp = osize - fsize - sizeof(struct block);

    if (temp < 0) {
	/* original block too small to cut */
	b->b_size = -osize;
	return;
    }
    /* else block is big enough to cut */
    DEBUG((temp == 0 ? 7 : 'c'));
    nb = ((char *)(b+1)) + fsize;
    nb->b_size = temp;
    nb->b_next = b->b_next;
    b->b_size = -fsize;				/* negative: allocated */
    b->b_next = nb;
};

int free(fb)
struct block *fb;
{
    struct arena *a, **p;
    register struct block *b, *pb, *hold;
    register long temp;

    DEBUG('F');
    /* set fb (and b) to header start; negate size */
    b = --fb;
    if ((b->b_size *= -1) < 0) {
	/* it was positive to begin with; this isn't an allocated block! */
	b->b_size *= -1;
	return -1;
    }

    /* hold gets addr of first block in this area; later, if the block	*/
    /* we free & coalesce starts at that addr, then it's the first	*/
    /* block in that arena.  If it's also the LAST block, arena's empty	*/
    /* and it gets freed.  p is used here, too: it points to the place	*/
    /* to stuff a->a_next in order to unlink a from the arena list.	*/

    for (a = *(p = &a_first); a; a = *(p = &a->a_next)) {
	for (pb = NULL, hold = b = (struct block *)(a+1); 
	     b; 
	     pb = b, b = b->b_next) {

	    if (b == fb) {
		/* Found it!  Coalesce backwards if any prev & it's free */
		if (pb != NULL && pb->b_size >= 0) {
		    DEBUG('b');
		    pb->b_size += sizeof(struct block) + b->b_size;
		    pb->b_next = b->b_next;
		    b = pb;
		}
		/* coalesce forwards if any next & it's free */
		if (b->b_next && (temp = b->b_next->b_size) >= 0) {
		    DEBUG('f');
		    b->b_size += temp + sizeof(struct block);
		    b->b_next = b->b_next->b_next;
		}
		if ((b == hold) && (b->b_next == 0)) {
		    /* this arena now contains one free block: Mfree it! */
		    DEBUG('!');
		    *p = a->a_next;
		    Mfree(a);
		}
		return 0;	/* success! */
	    }
	}
    }

    /* didn't find this block in any arena! */
    return -1;
}

char *malloc(size)
int size;
{
    return (lmalloc((unsigned long)size));
}

char *lcalloc(count,size)
long count;
register long size;
{
    register char *buf;
    register int *ptr;

    size *= count;
    ptr = buf = lmalloc(size);
    if (!buf) return 0;

    /* clear the last odd byte if any */
    if (size & 1) *(buf+size-1) = 0;

    /* clear complete words & return */
    size >>= 1;
    do {
	*ptr++ = 0;
    } while (--size);

    return buf;
}

char *calloc(count,size)
int count, size;
{
    return lcalloc((unsigned long)count,(unsigned long)size);
}

/*
 * realloc isn't quite as good as it could be: it doesn't check for a
 * free block BEFORE the block in question, which you could grow into
 * if it's big enough.  The logical place to check this is after coalescing
 * the block in question with the following block, if any.  However,
 * it would add overhead in looking through all the arenas for the
 * predecessor to this block.
 *
 * For that matter, it would help to coalesce previous, current, and next
 * block and copy the useful stuff down, because this would merge the previous
 * and next blocks if they're both free.  But not this time.
 */

char *lrealloc(ptr,size)
struct block *ptr;
register long size;
{
    register long osize, nextsize, savsize;
    register struct block *b;
    register int *p1, *p2;
    char *newblk;
    
    DEBUG('R');
    if (size <= 0) return 0;

    size = (size+1) & ~1;

    b = ptr - 1;

    /* remember the size of the original block */
    savsize = osize = -b->b_size;
    
    /* coalesce next block onto this one if there is one and it's free */

    if (b->b_next && ((nextsize = b->b_next->b_size) >= 0)) {
	/* tack the next (free) block onto this one */
	DEBUG('-');
	osize += sizeof(struct block) + nextsize;
	b->b_size = -osize;
	b->b_next = b->b_next->b_next;
    }

    /* take care of shrinking, and growing in place */

    if (osize >= size) {
	DEBUG('<');
	cut(b,osize,size);
	return (char *)(b+1);
    }

    /* growing the block and not room to do it in place */

    if ((newblk = p1 = lmalloc(size)) == 0) {
	DEBUG('>');
	return 0;
    }

    /* copy the original block into the new block */
    p2 = ptr;
    savsize >>= 1;
    do {
	*p1++ = *p2++;
    } while (--savsize);
    free(ptr);
    DEBUG('r');
    return newblk;
}

char *realloc(ptr,size)
char *ptr;
int size;
{
    return lrealloc(ptr,(unsigned long)size);
}
