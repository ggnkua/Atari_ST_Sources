/*
	programme pour enlever les DC.W en double
*/
#include <stdio.h>
FILE *in;
FILE *out;
int main(void)
{
	unsigned int c,lastc;
	in=fopen("DCW.BIN","rb");
	if (in==(FILE *)NULL)
	{
		printf("fichier inexistant\n");
		return 1;
	}
	out=fopen("DC.ST","wb");

	lastc=0;
	while (feof(in)==0)
	{
		c=(fgetc(in)<<8)+fgetc(in);
		if (c!=lastc)
		{
			lastc=c;
			fputc(c>>8,out);
			fputc(c&0xff,out);
		}
	}
	fclose(in);
	fclose(out);
	return 0;
}
