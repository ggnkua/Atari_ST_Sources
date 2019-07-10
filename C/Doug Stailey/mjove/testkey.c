#include <osbind.h>
#include <stdio.h>

#ifndef FALSE
#define FALSE 0
#define TRUE !FALSE
#endif

bgetkey(int *speckey)
{
	union scancode {
		long	scan;
		short	scarray[2];
	} sc;

	sc.scan = Bconin(2);
	if (sc.scarray[1]) {
		*speckey = FALSE;
		return (sc.scarray[1]);
	}
	else {
		*speckey = TRUE;
		return (sc.scarray[0]);
	}
}

main()
{
	int special;
	unsigned char c;

	do {
		c = bgetkey(&special);
		if (!special)
			printf("Regular Key: %c\n", c);
		else
			printf("Special Key: 0x%x\n", c);
	} while (c != 'q');
}
