/*----------------------------*/
/* display free RAM (roughly) */
/* Terry Billany 22/6/88      */
/* written in shareware C     */
/*----------------------------*/
/* saves about 4k by not      */
/* using printf!	      */
/*----------------------------*/
#include <osbind.h>
main() {
char strng[32];
	Cconws("free memory: ");
	itoa(Malloc(-1L), strng);
	Cconws(strng);
	return(0);
}
itoa(n, s) long n; char s[]; {
int i;
long sign;
	if ((sign=n) < 0)
		n = -n;
	i=0;
	do {
		s[i++] = n%10 + '0';
	}  while ((n /= 10) > 0);
	if (sign < 0)
		s[i++] = '-';
	s[i] = '\0';
	reverse(s);
}
reverse(s) char s[]; {
int c, i, j;
	for (i=0,j=strlen(s)-1; i < j; i++,j--)
	{  c=s[i];
	   s[i]=s[j];
	   s[j]=c;
	}
}	
