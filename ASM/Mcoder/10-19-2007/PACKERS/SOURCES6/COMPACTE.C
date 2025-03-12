/*
	COMPACTE.C

 routine de compactage

*/
#include <stdio.h>
FILE *in,*out;

char *name="off.bin";
char *dest="off.cmp";

#define longueur 31899		/* longueur du fichier */
unsigned char t[longueur];
unsigned char u[longueur];

main()
{
	unsigned char c;
	unsigned int i,j,k,l;
	unsigned long n,nn;

	in=fopen(name,"rb");
	if (!in)
	{
		printf("Je n'arrive pas … ouvrir %s\n",name);
		exit (1);
	}
	out=fopen(dest,"w");

	n=0;
	t[0]=1;
	u[0]=getc(in);
	for (i=1;i<longueur;i++)
	{
		c=getc(in);
		if ((c==u[n])&&(t[n]<255))
		{
			t[n]++;
		}
		else
		{
			n++;
			t[n]=1;
			u[n]=c;
		}
	}
	nn=n;
	printf("Passe 1 : %ld\n",nn*2);

	for (i=0;i<=nn;)
	{
		if ((t[i]==1)&&(t[i+1]==1))
		{
			j=2;
			l=i;
			i+=2;
			for (;;)
			{
				if (t[i]!=1) break;
				if (j==255) break;
				j++;
				i++;
				n++;
			}
			fprintf(out,"%c",0);
			fprintf(out,"%c",j);
			for (k=1;k<j;k++)
			{
				fprintf(out,"%c",u[k+l]);
			}
		}
		else
		{
			fprintf(out,"%c",t[i]);
			fprintf(out,"%c",u[i]);
			i++;
		}
	}
	printf("Passe 2 : %ld\n",nn+n);

	fclose(in);
	fclose(out);
}
