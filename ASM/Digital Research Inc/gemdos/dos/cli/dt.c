
/* dt.c - common C routines for DATE and TIME utilities
*/

#include <dt.h>

int
get_num(p)
char **p;
{
	int i, j;

    	j = -1;
	for (i = 0; (**p >= '0') && (**p <= '9'); j++,(*p)++)
	{
		i = **p - '0' + i *10;
	}
    	if (j == -1) return(j);
    	return(i);
}

put_num(i)
unsigned int i;
{
	unsigned int q, r;
	int j;
	j = i;
	if(j < 10)
		bdos(C_ConOut, '0');
	q = i/10;
	r = i%10;

	if (q)
		bdos(C_ConOut, q%10 + '0');

	bdos(C_ConOut, r + '0');
}
