#include <stdio.h>

void main(int argc,char *argv[])
{
	int diffs[511],first,second,i,j,biggest=0;
	FILE *fp;

	if(argc!=2)
		return;
	fp = fopen(argv[1],"r");
	for (i=0;i<511;i++)
		diffs[i] = 0;
	first=getc(fp);

	while( (second=getc(fp))!=EOF)
	{
		diffs[second-first+255] += 1;
		first = second;
	}

	for (i=0;i<511;i++)
		if(diffs[i]>biggest)
			biggest=diffs[i];
	printf("biggest value = %d\n",biggest);
	for (i=0;i<510;i++) {
		printf("%4d ]",i-255);
		for (j=1;j<(((double)diffs[i]/biggest)*50.0);j++)
			printf("*");
		printf("\n");
	}
	return;
}