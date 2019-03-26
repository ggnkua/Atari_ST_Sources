/* sol6.c: Hex dump */

#include "stdio.h"

main()    /* Program starts here! */
{
    int c;    /* temporary variable to store each
                 character read */
    int i;

    i = 0;
    c = getchar(); /* get the first character */

    while ( (c>=0) && (c<=255) ) {
	if (c<=0x0f) {
	    printf("0");
	}
	printf("%x ", c);
	i = i+1;
	if (i==16) {
		printf("\n");
		i = 0;
	}
	c = getchar();
    }
    printf("\n");
    return 0;      /* program finished OK */
}
