/* the obligatory "Hello world" program. Does a few tests, too. */

#include <stdio.h>
#include <osbind.h>

enum {TEST_ENUM_0, TEST_ENUM_1, TEST_ENUM_2};

struct { int a,b,c; } teststruct = {0,1,2};

void main()
{
	int   i = 0;
	long  l = 0;
	
	printf("\n");
	fprintf(stderr,"Hello, from your brand new modified Sozobon compiler.\n");
	fprintf(stdout,"Your compiler is working correctly if...\n\n");
	printf("  1 == %d\n", 1 == (i=1));
	printf("  2 == %ld\n", 2 * (l + 1));  
	printf("  3 == %d\n", TEST_ENUM_1 + teststruct.c);
	printf("  4 == %d\n", sizeof(long)); 
	
}
