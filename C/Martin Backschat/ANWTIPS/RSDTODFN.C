#include <stdio.h>
#include <string.h>

typedef struct {
	int count;
	int index;
	int type;
	char name[8];
} DFN;

typedef struct {
	int count;
	int filler;
	int index;
	int type;
	char name[8];
} RSD;

int intel(unsigned i)
{
	return (i>>8)+((i&0xff)<<8);
}

int main(int argc,char *argv[])
{
DFN d;
RSD r;
FILE *infile,*outfile;

	if (argc != 3) {
		printf("usage: RSDTODFN rsdfile dfnfile\n");
		return -1;
	}
	if ((infile=fopen(argv[1],"rb"))==NULL) {
		printf("can't open %s\n",argv[1]);
		return -33;
	}
	if ((outfile=fopen(argv[2],"wb"))==NULL) {
		printf("can't create %s\n",argv[2]);
		return -37;
	}
	if(fread(&r,sizeof(RSD),1,infile)!=1) {
		printf("can't read from %s\n",argv[1]);
		return -1;
	}
	do {
		d.count=intel((unsigned) r.count);
		d.index=intel((unsigned) r.index);
		d.type=intel((unsigned) r.type);
		strcpy(d.name,r.name);
		fwrite(&d,sizeof(DFN),1,outfile);
	} while (fread(&r,sizeof(RSD),1,infile)==1);
	fclose(infile);
	fclose(outfile);
	return 0;
}
