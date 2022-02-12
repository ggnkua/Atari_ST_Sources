#include <lib.h>
PRIVATE _PROTOTYPE( void qsort1, (char *a1, char *a2, int width)	);
PRIVATE _PROTOTYPE( int (*qcompar), (const void *, const void *)	);
PRIVATE _PROTOTYPE( void qexchange, (char *p, char *q, int n)		);
PRIVATE _PROTOTYPE( void q3exchange, (char *p, char *q, char *r, int n)	);

void qsort(base, nel, width, compar)
void *base;
size_t nel, width;
_PROTOTYPE( int (*compar), (const void *, const void *));
{
  qcompar = compar;
  if (nel > 0)
  	qsort1((char *) base, (char *) base + (nel - 1) * width, width);
}

PRIVATE void qsort1(a1, a2, width)
char *a1, *a2;
register int width;
{
  register char *left, *right;
  register char *lefteq, *righteq;
  int cmp;

  for (;;) {
	if (a2 <= a1) return;
	left = a1;
	right = a2;
	lefteq = righteq = a1 + width * (((a2 - a1) + width) / (2 * width));
	/* Pick an element in the middle of the array. We will
	 * collect the equals around it. "lefteq" and "righteq"
	 * indicate the left and right bounds of the equals
	 * respectively. Smaller elements end up left of it, larger
	 * elements end up right of it. */
again:
	while (left < lefteq && (cmp = (*qcompar) (left, lefteq)) <= 0) {
		if (cmp < 0) {
			/* Leave it where it is */
			left += width;
		} else {
			/* Equal, so exchange with the element to the
			 * left of the "equal"-interval. */
			lefteq -= width;
			qexchange(left, lefteq, width);
		}
	}
	while (right > righteq) {
		if ((cmp = (*qcompar) (right, righteq)) < 0) {
			/* Smaller, should go to left part */
			if (left < lefteq) {
				/* Yes, we had a larger one at the
				 * left, so we can just exchange */
				qexchange(left, right, width);
				left += width;
				right -= width;
				goto again;
			}

			/* No more room at the left part, so we move
			 * the "equal-interval" one place to the
			 * right, and the smaller element to the left
			 * of it. This is best expressed as a
			 * three-way exchange. */
			righteq += width;
			q3exchange(left, righteq, right, width);
			lefteq += width;
			left = lefteq;
		} else if (cmp == 0) {
			/* Equal, so exchange with the element to the
			 * right of the "equal-interval" */
			righteq += width;
			qexchange(right, righteq, width);
		} else		/* just leave it */
			right -= width;
	}
	if (left < lefteq) {
		/* Larger element to the left, but no more room, so
		 * move the "equal-interval" one place to the left,
		 * and the larger element to the right of it. */
		lefteq -= width;
		q3exchange(right, lefteq, left, width);
		righteq -= width;
		right = righteq;
		goto again;
	}

	/* Now sort the "smaller" part */
	qsort1(a1, lefteq - width, width);
	/* And now the larger, saving a subroutine call because of
	 * the for(;;) */
	a1 = righteq + width;
  }

  /* NOTREACHED */
}

PRIVATE void qexchange(p, q, n)
register char *p, *q;
register int n;
{
  register int c;

  while (n-- > 0) {
	c = *p;
	*p++ = *q;
	*q++ = c;
  }
}

PRIVATE void q3exchange(p, q, r, n)
register char *p, *q, *r;
register int n;
{
  register int c;

  while (n-- > 0) {
	c = *p;
	*p++ = *r;
	*r++ = *q;
	*q++ = c;
  }
}
