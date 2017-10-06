#include "header.h"

main(n,p)
int n;
char *p[];
{
	long i;
	long t;
	unsigned char *adr; 
	unsigned char *ptr;

	if (n==3)
	{
		if (bexist(p[1]))
		{
			t=bsize(p[1]);
			if (ptr=adr=memalloc(t))
			{
				bload(p[1],adr,0L,t);
				for(i=0;i<t;i++)
				{
					if (*ptr==13) *ptr=10;
					else
					if (*ptr==10) *ptr=13;
					ptr++;
				}
				bmake(p[2],adr,t);
				memfree(&adr);
			}
			else printf("not enough memory\n");
		}
		else printf("file not found");
	}
	else printf("usage: trans MacTextFile PCTextFile (or reverse)\n");
}
