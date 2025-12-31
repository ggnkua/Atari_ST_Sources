#include <stdio.h>

#define confuse(a,b) (a^=b^=a^=b)

void main(void)
{
int   a = 15,
		b = 13;
int * ap= &a,
	 * bp= &b;
	 		
printf("%d %d\n",a,b);
confuse(a,b);
printf("%d %d\n",a,b);
printf("%xl %xl\n",ap,bp);
confuse((long) ap,(long) bp);
printf("%xl %xl\n",ap,bp);
}

