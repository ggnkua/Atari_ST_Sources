#include	<aesbind.h>
#include  <gemfast.h>
#include	<osbind.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<vdibind.h>

#define	WORD	int
#define NUM_EVENTS 10

void	main(void) {
	int	i,ne;
	
	EVNTREC	er[NUM_EVENTS];
	
	appl_init();
	
	graf_mouse(ARROW,0L);
	
	ne = appl_trecord(er,NUM_EVENTS);
	
	for(i = 0; i < ne; i++) {
		printf("%3d ap_event=%ld ap_value=%04lx\n",i,er[i].ap_event,er[i].ap_value);
	};		

	appl_exit();
}
