/*
 *	Heap sorting functions
 */

static _wsift(base, i, n, cmp)
	register int *base;
	register int i;
	register int n;
	register int (*cmp)();
	{
	register int j, t;

	while((j = ((i << 1) + 1)) < n)
		{
		if((j < (n - 1)) && ((*cmp)((base+j), (base+j+1)) < 0))
			++j;
		if((*cmp)((base+i), (base+j)) < 0)
			{
			t = base[i];
			base[i] = base[j];
			base[j] = t;
			i = j;
			}
		else
			break;
		}
	}

static _whsort(base, num, cmp)
	register int *base;
	register int num;
	register int (*cmp)();
	{
	register int i, j;

	for(i = ((num >> 1) - 1); (i > 0); --i)
		_wsift(base, i, num, cmp);
	i = num;
	while(i > 1)
		{
		_wsift(base, 0, i--, cmp);
		j = *base;
		*base = *(base + i);
		*(base + i) = j;
		}
	}

static _lsift(base, i, n, cmp)
	register long *base;
	register int i;
	register int n;
	register int (*cmp)();
	{
	register int j;
	register long t;

	while((j = ((i << 1) + 1)) < n)
		{
		if((j < (n - 1)) && ((*cmp)((base+j), (base+j+1)) < 0))
			++j;
		if((*cmp)((base+i), (base+j)) < 0)
			{
			t = base[i];
			base[i] = base[j];
			base[j] = t;
			i = j;
			}
		else
			break;
		}
	}

static _lhsort(base, num, cmp)
	register long *base;
	register int num;
	register int (*cmp)();
	{
	register int i;
	register long j;

	for(i = ((num >> 1) - 1); (i > 0); --i)
		_lsift(base, i, num, cmp);
	i = num;
	while(i > 1)
		{
		_lsift(base, 0, i--, cmp);
		j = *base;
		*base = *(base + i);
		*(base + i) = j;
		}
	}

static _nswap(pa, pb, n)
	register char *pa;
	register char *pb;
	register int n;
	{
	register char c;

	while(n--)
		{
		c = *pa;
		*pa++ = *pb;
		*pb++ = c;
		}
	}

static _nsift(base, i, n, size, cmp)
	register char *base;
	register int i;
	register int n;
	register int size;
	register int (*cmp)();
	{
	register int j;
	register char *p;

	while((j = ((i << 1) + 1)) < n)
		{
		p = (base+size*j);
		if((j < (n - 1)) && ((*cmp)(p, p+size) < 0))
			{
			++j;
			p += size;
			}
		if((*cmp)((base+size*i), p) < 0)
			{
			_nswap((base+size*i), p, size);
			i = j;
			}
		else
			break;
		}
	}

static _nhsort(base, num, size, cmp)
	register char *base;
	register int num;
	register int size;
	register int (*cmp)();
	{
	register int i, j;

	for(i = ((num >> 1) - 1); (i > 0); --i)
		_nsift(base, i, num, size, cmp);
	i = num;
	while(i > 1)
		{
		_nsift(base, 0, i--, size, cmp);
		_nswap(base, (base+size*i), size);
		}
	}

hsort(base, num, size, cmp)
	char *base;
	int num;
	int size;
	int (*cmp)();
	{
	if(size == 2)
		_whsort(base, num, cmp);
	else if(size == 4)
		_lhsort(base, num, cmp);
	else
		_nhsort(base, num, size, cmp);
	}
