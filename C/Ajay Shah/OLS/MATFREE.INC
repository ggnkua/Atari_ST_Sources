
{
	free(&(M[rl][cl]));	/* gets rid of matrix */
	free(&(M[rl]));	/* gets rid of column of row pointers */
}

/*

The data structure is:

M --> [0 1 2]
	 | | |
       | | |
       | | +----> [21 22 23]
       | +------> [11 12 13]
       +--------> [01 02 03]

The elements 01..03..13..23 are one memory block.  So issuing a
free with the pointer to 01 frees the entire block.  Once that is
done, we can free the row of pointers.
*/

