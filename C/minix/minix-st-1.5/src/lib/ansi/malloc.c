#include <lib.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Replace undef by define */
#define	 DEBUG			/* check assertions */
#undef	 SLOWDEBUG		/* some extra test loops (requires DEBUG) */

#ifdef DEBUG
PRIVATE _PROTOTYPE( void assert_failed, (void));
#define	ASSERT(b)	if (!(b)) assert_failed();
#else
#define	ASSERT(b)		/* empty */
#endif

#if (CHIP == INTEL)
#define	ptrint		int
#endif

#if (CHIP == M68000)
#define	ptrint		long
#endif

#define BRKSIZE		1024
#define	PTRSIZE		sizeof(char *)
#define Align(x,a)	(((x) + (a - 1)) & ~(ptrint)(a - 1))
#define NextSlot(p)	(* (char **) ((p) - PTRSIZE))
#define NextFree(p)	(* (char **) (p))

/* A short explanation of the data structure and algorithms.
 * An area returned by malloc() is called a slot. Each slot
 * contains the number of bytes requested, but preceeded by
 * an extra pointer to the next the slot in memory.
 * '_bottom' and '_top' point to the first/last slot.
 * More memory is asked for using brk() and appended to top.
 * The list of free slots is maintained to keep malloc() fast.
 * '_empty' points the the first free slot. Free slots are
 * linked together by a pointer at the start of the
 * user visable part, so just after the next-slot pointer.
 * Free slots are merged together by free().
 */

extern char *sbrk(), *brk();
PRIVATE char *_bottom, *_top, *_empty;

PRIVATE _PROTOTYPE( int grow, (unsigned len));

PRIVATE int grow(len)
unsigned len;
{
  register char *p;

  ASSERT(NextSlot(_top) == 0);
  p = (char *) Align((ptrint) _top + len, BRKSIZE);
  if (p < _top || brk(p) != 0) return(0);
  NextSlot(_top) = p;
  NextSlot(p) = 0;
  free(_top);
  _top = p;
  return(1);
}

void *malloc(size)
unsigned size;
{
  register char *prev, *p, *next, *new;
  register unsigned len, ntries;

  if (size == 0) size = PTRSIZE;/* avoid slots less that 2*PTRSIZE */
  for (ntries = 0; ntries < 2; ntries++) {
	if ((len = Align(size, PTRSIZE) + PTRSIZE) < 2 * PTRSIZE)
		return(0);	/* overflow */
	if (_bottom == 0) {
		if ((p = sbrk(2 * PTRSIZE)) == (char *) -1) return(0);
		p = (char *) Align((ptrint) p, PTRSIZE);
		ASSERT(p + PTRSIZE > p);	/* sbrk amount stops
						 * overflow */
		p += PTRSIZE;
		_top = _bottom = p;
		NextSlot(p) = 0;
	}
#ifdef SLOWDEBUG
	for (p = _bottom; (next = NextSlot(p)) != 0; p = next)
		ASSERT(next > p);
	ASSERT(p == _top);
#endif
	for (prev = 0, p = _empty; p != 0; prev = p, p = NextFree(p)) {
		next = NextSlot(p);
		new = p + len;	/* easily overflows!! */
		if (new > next || new <= p) continue;	/* too small */
		if (new + PTRSIZE < next) {	/* too big, so split */
			/* + PTRSIZE avoids tiny slots on free list */
			ASSERT(new + PTRSIZE > new);	/* space above next */
			NextSlot(new) = next;
			NextSlot(p) = new;
			NextFree(new) = NextFree(p);
			NextFree(p) = new;
		}
		if (prev)
			NextFree(prev) = NextFree(p);
		else
			_empty = NextFree(p);
		return((void *)p);
	}
	if (grow(len) == 0) break;
  }
  ASSERT(ntries != 2);
  return((void *)NULL);
}

void *realloc(oldfix, size)
void *oldfix;
unsigned size;
{
  register char *prev, *p, *next, *new;
  register unsigned len, n;
  char *old = (char *) oldfix;

  if (size > -2 * PTRSIZE) return(0);
  len = Align(size, PTRSIZE) + PTRSIZE;
  next = NextSlot(old);
  n = (int) (next - old);	/* old length */
  /* Extend old if there is any free space just behind it */
  for (prev = 0, p = _empty; p != 0; prev = p, p = NextFree(p)) {
	if (p > next) break;
	if (p == next) {	/* 'next' is a free slot: merge */
		NextSlot(old) = NextSlot(p);
		if (prev)
			NextFree(prev) = NextFree(p);
		else
			_empty = NextFree(p);
		next = NextSlot(old);
		break;
	}
  }
  new = old + len;		/* easily overflows!! */
  /* Can we use the old, possibly extended slot? */
  if (new <= next && new >= old) {	/* it does fit */
	if (new + PTRSIZE < next) {	/* too big, so split */
		/* + PTRSIZE avoids tiny slots on free list */
		ASSERT(new + PTRSIZE > new);
		NextSlot(new) = next;
		NextSlot(old) = new;
		free(new);
	}
	return((void *)old);
  }
  if ((new = (char *)malloc(size)) == (char *)NULL)/* it didn't fit */
	return((void *)NULL);
  memcpy(new, old, (size_t)n);		/* n < size */
  free(old);
  return((void *)new);
}

void *calloc(n, size)
unsigned n, size;
{
  register char *p, *cp;

  n *= size;
  cp = (char *)malloc(n);
  if (cp == (char *) 0) return((void *) 0);
  for (p = cp; n-- != 0;) *p++ = '\0';
  return((void *)cp);
}

void free(pfix)
void *pfix;
{
  register char *prev, *next;
  char *p = (char *) pfix;

  ASSERT(NextSlot(p) > p);
  for (prev = 0, next = _empty; next != 0; prev = next, next = NextFree(next))
	if (p < next) break;
  NextFree(p) = next;
  if (prev)
	NextFree(prev) = p;
  else
	_empty = p;
  if (next) {
	ASSERT(NextSlot(p) <= next);
	if (NextSlot(p) == next) {	/* merge p and next */
		NextSlot(p) = NextSlot(next);
		NextFree(p) = NextFree(next);
	}
  }
  if (prev) {
	ASSERT(NextSlot(prev) <= p);
	if (NextSlot(prev) == p) {	/* merge prev and p */
		NextSlot(prev) = NextSlot(p);
		NextFree(prev) = NextFree(p);
	}
  }
}

#ifdef DEBUG
PRIVATE void assert_failed()
{
  write(2, "assert failed in lib/malloc.c\n", 30);
  abort();
}

#endif
