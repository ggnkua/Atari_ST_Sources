#include <minimal.h>
#include <aesbind.h>
#include <mintbind.h>

/* Gcc convention for accessories */

extern int _app;
char _stack_heap[8192];
void *_heapbase = (void *)_stack_heap;
long _stksize = sizeof(_stack_heap);

main()
{
	appl_init();
	while (1) {
		int j;
		evnt_multi(MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,&j,&j,&j,&j,&j,&j);
		Syield();
	}
}
