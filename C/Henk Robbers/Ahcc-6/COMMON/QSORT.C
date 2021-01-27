
#include <prelude.h>
#include <string.h>
#include <stddef.h>

char	*_qbuf = NULL;		/* pointer to storage for qsort() */

#define	PIVOT			((i+j)>>1)
#define moveitem(dst,src,size)	if (dst != src) memcpy(dst, src, size)

typedef short StdCompare(void *, void *);

typedef unsigned long ql;

static
void _wqsort(short *base, ql lo, ql hi, StdCompare *cmp)
{
	short k;
	ql i, j, t;
	short *p = &k;

	while(hi > lo)
	{
		i = lo;
		j = hi;
		t = PIVOT;
		*p = base[t];
		base[t] = base[i];
		base[i] = *p;

		while(i < j)
		{
			while(cmp(base+j, p) > 0)
				--j;
			base[i] = base[j];
			while(i < j && cmp(base+i, p) <= 0)
				++i;
			base[j] = base[i];
		}
		base[i] = *p;
		if (i - lo < hi - i)
		{
			_wqsort(base, lo, i - 1, cmp);
			lo = i + 1;
		}
		else
		{
			_wqsort(base, i + 1, hi, cmp);
			hi = i - 1;
		}
	}
}

static
void _lqsort(long *base, ql lo, ql hi, StdCompare *cmp)
{
	long k;
	ql i, j, t;
	long *p = &k;

	while(hi > lo)
	{
		i = lo;
		j = hi;
		t = PIVOT;
		*p = base[t];
		base[t] = base[i];
		base[i] = *p;

		while (i < j)
		{
			while (cmp(base+j, p) > 0)
				--j;
			base[i] = base[j];
			while (i < j && cmp(base+i, p) <= 0)
				++i;
			base[j] = base[i];
		}

		base[i] = *p;

		if (i - lo < hi - i)
		{
			_lqsort(base, lo, i - 1, cmp);
			lo = i + 1;
		}
		else
		{
			_lqsort(base, i + 1, hi, cmp);
			hi = i - 1;
		}
	}
}

static
void _nqsort(char *base, ql lo, ql hi, ql size, StdCompare *cmp)
{
	ql i, j;
	char *p = _qbuf;

	while (hi > lo)
	{
		i = lo;
		j = hi;
		p = (base+size*PIVOT);
		moveitem(_qbuf, p, size);
		moveitem(p, base+size*i, size);
		moveitem(base+size*i, _qbuf, size);
		p = _qbuf;

		while (i < j)
		{
			while (cmp((base+size*j), p) > 0)
				--j;
			moveitem((base+size*i), (base+size*j), size);
			while(i < j && cmp((base+size*i), p) <= 0)
				++i;
			moveitem(base+size*j, base+size*i, size);
		}

		moveitem(base+size*i, p, size);

		if ((i - lo) < (hi - i))
		{
			_nqsort(base, lo, i - 1, size, cmp);
			lo = i + 1;
		}
		else
		{
			_nqsort(base, i + 1, hi, size, cmp);
			hi = i - 1;
		}
	}
}

void qsort(void *base, size_t num, size_t size, StdCompare *cmp)
{
	char _qtemp[256];

	if (_qbuf == nil)
	{
		if (size > sizeof _qtemp)	/* records too large! */
			return;
		_qbuf = _qtemp;
	}

	if (size == sizeof(short))
		_wqsort(base, 0, num-1, cmp);
	else if (size == sizeof(long))
		_lqsort(base, 0, num-1, cmp);
	else
		_nqsort(base, 0, num-1, size, cmp);

	if (_qbuf == _qtemp)
		_qbuf = NULL;
}
