#include <mgx_dos.h>
#include <stdio.h>

int errno;

extern long get_stack(void);

int main(void *userstack, void *tpa)
{
	long oldstack;
	long superstack;

	superstack = Supexec(get_stack);

	printf("TPA: %ld Pgmsize: %ld\n", (long)tpa, _PgmSize);
	printf("%ld\n", (long)userstack);

/*
	oldstack = Super(0L);
	superstack = get_stack();
	printf("%ld\n", (long)superstack);
	Super((void *)oldstack);
*/

	printf("%ld\n", (long)superstack);
	return 0;
}
