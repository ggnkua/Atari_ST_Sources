#include <tos.h>

extern void do_reset(void);

long premiere(void)
{
	do_reset();
	return(0);
}

void main(void)
{
	(void)Supexec(premiere);
}


