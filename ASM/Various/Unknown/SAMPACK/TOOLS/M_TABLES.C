#include <stdio.h>

void main()
{
	int i,x;
	int table[10];
	char c;
	FILE *fp;
	
	table[0] = 0;
	table[9] = 256;
	for(i=1; i<9; i++)
	{
		printf("Value (0-255) %1d : ", i-1);
		scanf("%d",&table[i]);
	}
	fp = fopen("decrntab.bin","wb");
	for(i=1;i<9;i++)
	{
		c = table[i];
		fwrite(&c,1,1,fp);
	}
	for(i=1;i<9;i++)
	{
		c = (char) -table[i];
		fwrite(&c,1,1,fp);
	}
	fclose(fp);
	fp = fopen("crntab.bin","wb");
	for(i=0;i<9;i++)
	{
		for(x=table[i]; x<table[i+1]; x++)
		{
			c = i-1;
			fwrite(&c,1,1,fp);
		}
	}				
	fclose(fp);
}
