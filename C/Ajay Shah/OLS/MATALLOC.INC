
/* No declaration; matalloc.c must declare the routines */
{
	MATTYPE *block;
	MATTYPE **m;
	int size, i, rowsize, numrows;

	rowsize = ch - cl + 1;	/* #locations consumed by 1 row */
	numrows = rh -rl + 1;
	size = numrows*rowsize;
	block = (MATTYPE *) malloc((unsigned) sizeof(MATTYPE )*size);
	if (block == NULL) 
		FatalError("malloc failure in matrix allocation\n");
	/* so we have the matrix. */

	/* Now for the row pointers */
	m = (MATTYPE **) malloc((unsigned) sizeof(MATTYPE *)*numrows);
	if (m == NULL) FatalError("malloc failure in matrix allocation\n");
	m -= rl;	/* fixup m pointer so m[rl] == old m[0] */

	/* Finally, setup pointers to rows */
	block -= cl;
	for (i=rl; i<=rh; i++) {
		m[i] = block;
		block += rowsize;
	}
	return m;
}

