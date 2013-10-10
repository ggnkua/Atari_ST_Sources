/* vectors.c print exception vector table
 *-----------------------------------------------------------------------
 */
#include <stdio.h>
#include <osbind.h>

long *vecno;

long
getvec(void)
{
	return *vecno;
}

int
main(void)
{
	int i;
	for (i = 0; i < 16; i++)
	{
		vecno = (long *)(i*4);
		printf("$%p = $%p\n", vecno, Supexec(getvec));
	}
	return 0;
}
