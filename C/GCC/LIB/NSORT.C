
/* jrd...
 * I found this sorter lying around on one of the MIT machines.
 * It had no commentary or docs that I could find, I've added some.
 * It seems to work, but I'm not sure whether to trust it.
 * I guess if the price is right I shouldn't complain...
 */

#define	T1	4			/* chunk size? */
#define	T2	6

/* I don't know why these are globals, not parameters... */

static  int	(*compare_elts)();
static  int	nbytes_elt;
static  int	seg_size;
static  int	seg_mid;

/* this entry pt added y jrd */

qsort (vect, n_elts, elt_size, compare_fun)
char * vect;
int n_elts, elt_size;
int (* compare_fun)();
{
  nsort(vect, n_elts, elt_size, compare_fun);
}


nsort(vect, n_elts, elt_size, compare_fun)
char	*vect;			/* the vector to be sorted */
int	n_elts;			/* n frobs */
int	elt_size;		/* size in bytes of a frob */
int	(* compare_fun)();	/* fun to compare two frobs */
{
  register char c, *i, *j, *elt_1, *elt_2;
  char *low_lim, *high_lim;

  if (n_elts <= 1)
	return;
  nbytes_elt = elt_size;
  compare_elts = compare_fun;
  seg_size = nbytes_elt * T1;
  seg_mid = nbytes_elt * T2;
  high_lim = vect + n_elts * nbytes_elt;
  if (n_elts >= T1) 
	{
	sort_chunk(vect, high_lim);
	elt_2 = vect + seg_size;
	}
    else
	{
	elt_2 = high_lim;
	}

  for (j = elt_1 = vect; (elt_1 += nbytes_elt) < elt_2; )
	if (compare_elts(j, elt_1) > 0)
		j = elt_1;
  if (j != vect)
	{
	/* swap j into place */
	for (i = vect, elt_2 = vect + nbytes_elt; i < elt_2; ) 
		{
		c = *j;
		*j++ = *i;
		*i++ = c;
		}
	}

  for (low_lim = vect; (elt_2 = low_lim += nbytes_elt) < high_lim; ) 
	{
	while (compare_elts(elt_2 -= nbytes_elt, low_lim) > 0)
		/* void */;
	if ((elt_2 += nbytes_elt) != low_lim) 
		{
		for (elt_1 = low_lim + nbytes_elt; --elt_1 >= low_lim; ) 
			{
			c = *elt_1;
			for (i = j = elt_1; (j -= nbytes_elt) >= elt_2; i = j)
				*i = *j;
			*i = c;
			}
		}
	}
}

static sort_chunk(vect, high_lim)
char *vect, *high_lim;
{
  register char c, *i, *j, *jj;
  register int ii;
  char *mid, *tmp;
  int lo, hi;

  lo = high_lim - vect;
  do
	{
	mid = i = vect + nbytes_elt * ((lo / nbytes_elt) >> 1);
	if (lo >= seg_mid) 
		{
		j = (compare_elts((jj = vect), i) > 0 ? jj : i);
		if (compare_elts(j, (tmp = high_lim - nbytes_elt)) > 0) 
			{
			j = (j == jj ? i : jj);
			if (compare_elts(j, tmp) < 0)
				j = tmp;
			}
		if (j != i) 
			{
			ii = nbytes_elt;
			do
				{
				c = *i;
				*i++ = *j;
				*j++ = c;
				} while (--ii);
			}
		}
	for (i = vect, j = high_lim - nbytes_elt; ; ) 
		{
		while (i < mid && compare_elts(i, mid) <= 0)
			i += nbytes_elt;
		while (j > mid) 
			{
			if (compare_elts(mid, j) <= 0) 
				{
				j -= nbytes_elt;
				continue;
				}
			tmp = i + nbytes_elt;
			if (i == mid) 
				{
				mid = jj = j;
				}
			    else 
				{
				jj = j;
				j -= nbytes_elt;
				}
			goto swap;
			}
		if (i == mid) 
			{
			break;
			}
		    else
			{
			jj = mid;
			tmp = mid = i;
			j -= nbytes_elt;
			}
		swap:
			ii = nbytes_elt;
			do	
				{
				c = *i;
				*i++ = *jj;
				*jj++ = c;
				} while (--ii);
			i = tmp;
		}
		i = (j = mid) + nbytes_elt;
		if ((lo = j - vect) <= (hi = high_lim - i)) 
			{
			if (lo >= seg_size)
				sort_chunk(vect, j);
			vect = i;
			lo = hi;
			}
		    else 
			{
			if (hi >= seg_size)
				sort_chunk(i, high_lim);
			high_lim = j;
			}
		} while (lo >= seg_size);
}
