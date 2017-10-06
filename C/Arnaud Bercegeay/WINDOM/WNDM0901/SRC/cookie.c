/*
 *	WinDom: Librairie Cookie
 */
#ifdef __PUREC__
	/* Pure C possäde des librairies non standard */
	#include <tos.h>
#else
	/* Gnu C, Sozobon, Lattice */
	#include <osbind.h>
	#include <fcntl.h>
#endif
#include <stdio.h>
#include <stdlib.h>

/* Une version mieux de get_cookie() */

static long cookieptr(void) { 
	return *((long *)0x5a0); 
}

int get_cookie (long cookie, long *p_value) {
	long *cookiejar = (long *)Supexec (cookieptr);
	if (!cookiejar) return 0;

	do {
		if (cookiejar[0] == cookie) {
			if (p_value) *p_value = cookiejar[1];
			return 1;
		}
		cookiejar += 2;
	} while (cookiejar[-2]);

	return 0;
}

int new_cookie (long id, long value) {
	long *cookiejar = (long *)Supexec (cookieptr);
	int  act_row = 0;
	
	if (cookiejar) {		
		while (*cookiejar) {
			cookiejar+=2;
			act_row++;
		}
		
		if (act_row < cookiejar[1]) {
			cookiejar[2] = cookiejar[0];
			cookiejar[3] = cookiejar[1];
			
			*cookiejar++ = id;
			*cookiejar++ = value;
			return(1);
		}
	}
	return(0);
}

int set_cookie(long cookie, long value) {
	long *cookiejar = (long *)Supexec (cookieptr);
	
	if (cookiejar) {
		while (*cookiejar) {
			if (*cookiejar==cookie) {
				if (value)
					*++cookiejar = value;
				return( 1);
			}
			cookiejar += 2;
		}
	}
	return( 0);
}
